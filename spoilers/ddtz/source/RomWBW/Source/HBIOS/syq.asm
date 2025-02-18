;
;=============================================================================
;   SYQ DISK DRIVER
;=============================================================================
;
; PARALLEL PORT INTERFACE FOR ATA DISK DEVICES USING A PARALLEL PORT
; ADAPTER.  PRIMARILY TARGETS PARALLEL PORT SYQUEST DRIVES.
;
; INTENDED TO CO-EXIST WITH LPT DRIVER.
;
; CREATED BY WAYNE WARTHEN FOR ROMWBW HBIOS.
; MUCH OF THE CODE IS DERIVED FROM LINUX AND FUZIX (ALAN COX).
; - https://github.com/EtchedPixels/FUZIX
; - https://github.com/torvalds/linux
;
; 05/29/2023 WBW - INITIAL RELEASE
; 06/06/2023 WBW - OPTIMIZE BLOCK READ AND WRITE
;
;=============================================================================
;
;  IBM PC STANDARD PARALLEL PORT (SPP):
;  - NHYODYNE PRINT MODULE
;
;  PORT 0 (OUTPUT):
;
;	D7	D6	D5	D4	D3	D2	D1	D0
;     +-------+-------+-------+-------+-------+-------+-------+-------+
;     | PD7   | PD6   | PD5   | PD4   | PD3   | PD2   | PD1   | PD0   |
;     +-------+-------+-------+-------+-------+-------+-------+-------+
;
;  PORT 1 (INPUT):
;
;	D7	D6	D5	D4	D3	D2	D1	D0
;     +-------+-------+-------+-------+-------+-------+-------+-------+
;     | /BUSY | /ACK  | POUT  | SEL   | /ERR  | 0     | 0     | 0     |
;     +-------+-------+-------+-------+-------+-------+-------+-------+
;
;  PORT 2 (OUTPUT):
;
;	D7	D6	D5	D4	D3	D2	D1	D0
;     +-------+-------+-------+-------+-------+-------+-------+-------+
;     | STAT1 | STAT0 | ENBL  | PINT  | SEL   | RES   | LF    | STB   |
;     +-------+-------+-------+-------+-------+-------+-------+-------+
;
;=============================================================================
;
;  MG014 STYLE INTERFACE:
;  - RCBUS MG014 MODULE
;
;  PORT 0 (OUTPUT):
;
;	D7	D6	D5	D4	D3	D2	D1	D0
;     +-------+-------+-------+-------+-------+-------+-------+-------+
;     | PD7   | PD6   | PD5   | PD4   | PD3   | PD2   | PD1   | PD0   |
;     +-------+-------+-------+-------+-------+-------+-------+-------+
;
;  PORT 1 (INPUT):
;
;	D7	D6	D5	D4	D3	D2	D1	D0
;     +-------+-------+-------+-------+-------+-------+-------+-------+
;     |	      |	      |	      | /ERR  | SEL   | POUT  | BUSY  | /ACK  |
;     +-------+-------+-------+-------+-------+-------+-------+-------+
;
;  PORT 2 (OUTPUT):
;
;	D7	D6	D5	D4	D3	D2	D1	D0
;     +-------+-------+-------+-------+-------+-------+-------+-------+
;     | LED   |	      |	      |	      | /SEL  | /RES  | /LF   | /STB  |
;     +-------+-------+-------+-------+-------+-------+-------+-------+
;
;=============================================================================
;
; TODO:
;
; NOTES:
;
; - TESTED ON THE SYQUEST SPARQ ONLY.
;
; - THIS DRIVER OPERATES USES NIBBLE READ MODE.  ALTHOUGH THE 8255
;   (MG014) CAN READ OR WRITE TO PORT A (DATA), IT "GLITCHES" WHEN
;   THE MODE IS CHANGED CAUSING THE CONTROL LINES TO CHANGE AND
;   BREAKS THE PROTOCOL.  I SUSPECT THE MBC SPP CAN SUPPORT FULL BYTE
;   MODE, (PS2 STYLE), BUT I HAVE NOT ATTEMPTED IT.
;
; - RELATIVE TO ABOVE, THIS BEAST IS SLOW.  IN ADDITION TO THE
;   NIBBLE MODE READS, THE MG014 ASSIGNS SIGNALS DIFFERENTLY THAN
;   THE STANDARD IBM PARALLEL PORT WHICH NECESSITATES A BUNCH OF EXTRA
;   BIT FIDDLING ON EVERY READ.
;
; - SOME OF THE DATA TRANSFERS HAVE NO BUFFER OVERRUN CHECKS.  IT IS
;   ASSUMED SCSI DEVICES WILL SEND/REQUEST THE EXPECTED NUMBER OF BYTES.
;
; SYQ PORT OFFSETS
;
SYQ_IODATA	.EQU	0		; PORT A, DATA, OUT
SYQ_IOSTAT	.EQU	1		; PORT B, STATUS, IN
SYQ_IOCTRL	.EQU	2		; PORT C, CTRL, OUT
SYQ_IOSETUP	.EQU	3		; PPI SETUP
;
; THIS INTERFACE TRANSLATES BETWEEN PPI AND ATA.  THE ATA REGSITERS
; CAN BE ACCESSED THROUGH THE INTERFACE.  THE INTERFACE ALSO HAS
; REGISTERS OF ITS OWN.
;
SYQ_REG_NAT	.EQU	0		; START OF NATIVE INTERFACE REGISTERS
SYQ_REG_PRI	.EQU	$18		; START OF PRIMARY ATA REGISTERS
SYQ_REG_ALT	.EQU	$10		; START OF ALTERNATE ATA REGISTERS
;
SYQ_REG_DATA	.EQU	SYQ_REG_PRI + $00	; DATA 	/OUTPUT (R/W)
SYQ_REG_ERR	.EQU	SYQ_REG_PRI + $01	; ERROR REGISTER (R)
SYQ_REG_FEAT	.EQU	SYQ_REG_PRI + $01	; FEATURES REGISTER (W)
SYQ_REG_COUNT	.EQU	SYQ_REG_PRI + $02	; SECTOR COUNT REGISTER (R/W)
SYQ_REG_SECT	.EQU	SYQ_REG_PRI + $03	; SECTOR NUMBER REGISTER (R/W)
SYQ_REG_CYLLO	.EQU	SYQ_REG_PRI + $04	; CYLINDER NUM REGISTER (LSB) (R/W)
SYQ_REG_CYLHI	.EQU	SYQ_REG_PRI + $05	; CYLINDER NUM REGISTER (MSB) (R/W)
SYQ_REG_DRVHD	.EQU	SYQ_REG_PRI + $06	; DRIVE/HEAD REGISTER (R/W)
SYQ_REG_LBA0	.EQU	SYQ_REG_PRI + $03	; LBA BYTE 0 (BITS 0-7) (R/W)
SYQ_REG_LBA1	.EQU	SYQ_REG_PRI + $04	; LBA BYTE 1 (BITS 8-15) (R/W)
SYQ_REG_LBA2	.EQU	SYQ_REG_PRI + $05	; LBA BYTE 2 (BITS 16-23) (R/W)
SYQ_REG_LBA3	.EQU	SYQ_REG_PRI + $06	; LBA BYTE 3 (BITS 24-27) (R/W)
SYQ_REG_STAT	.EQU	SYQ_REG_PRI + $07	; STATUS REGISTER (R)
SYQ_REG_CMD	.EQU	SYQ_REG_PRI + $07	; COMMAND REGISTER (EXECUTE) (W)
SYQ_REG_XAR	.EQU	SYQ_REG_ALT + $00	; ECB DIDE EXTERNAL ADDRESS REGISTER (W)
SYQ_REG_ALTSTAT	.EQU	SYQ_REG_ALT + $06	; ALTERNATE STATUS REGISTER (R)
SYQ_REG_CTRL	.EQU	SYQ_REG_ALT + $06	; DEVICE CONTROL REGISTER (W)
SYQ_REG_DRVADR	.EQU	SYQ_REG_ALT + $07	; DRIVE ADDRESS REGISTER (R)
;
; ATA COMMAND BYTES
;
SYQ_CMD_NOP		.EQU	$00
SYQ_CMD_DEVRES		.EQU	$08
SYQ_CMD_RECAL		.EQU	$10
SYQ_CMD_READ		.EQU	$20
SYQ_CMD_WRITE		.EQU	$30
SYQ_CMD_DEVDIAG		.EQU	$90
SYQ_CMD_IDPKTDEV	.EQU	$A1
SYQ_CMD_MEDIASTATUS	.EQU	$DA
SYQ_CMD_IDDEV		.EQU	$EC
SYQ_CMD_SETFEAT		.EQU	$EF
;
; POST-COMMAND DATA TRANSFER OPTIONS
;
SYQ_XFR_NONE		.EQU	0	; NO DATA TRANSFER FOR CMD
SYQ_XFR_READ		.EQU	1	; CMD IS A READ OPERATION
SYQ_XFR_WRITE		.EQU	2	; CMD IS A WRITE OPERATION
;
; SYQ DEVICE STATUS
;
SYQ_STOK	.EQU	0
SYQ_STNOMEDIA	.EQU	-1
SYQ_STCMDERR	.EQU	-2
SYQ_STIOERR	.EQU	-3
SYQ_STTO	.EQU	-4
SYQ_STNOTSUP	.EQU	-5
;
; SYQ DEVICE CONFIGURATION
;
SYQ_CFGSIZ	.EQU	12		; SIZE OF CFG TBL ENTRIES
;
; PER DEVICE DATA OFFSETS IN CONFIG TABLE ENTRIES
;
SYQ_DEV		.EQU	0		; OFFSET OF DEVICE NUMBER (BYTE)
SYQ_MODE	.EQU	1		; OPERATION MODE: SYQ MODE (BYTE)
SYQ_STAT	.EQU	2		; LAST STATUS (BYTE)
SYQ_IOBASE	.EQU	3		; IO BASE ADDRESS (BYTE)
SYQ_MEDCAP	.EQU	4		; MEDIA CAPACITY (DWORD)
SYQ_LBA		.EQU	8		; OFFSET OF LBA (DWORD)
;
; THE SYQ_WAITXXX FUNCTIONS ARE BUILT TO TIMEOUT AS NEEDED SO DRIVER WILL
; NOT HANG IF DEVICE IS UNRESPONSIVE.  DIFFERENT TIMEOUTS ARE USED DEPENDING
; ON THE SITUATION.  THE SLOW TIMEOUT IS USED TO WAIT FOR A DEVICE TO
; BECOME READY AFTER A HARD RESET (SPIN UP, ETC.).  THE NORMAL TIMEOUT
; IS USED DURING NORMAL OPERATION FOR ALL I/O OPERATIONS WHICH SHOULD
; OCCUR PRETTY FAST.  NOTE THAT THE ATA SPEC ALLOWS UP TO 30 SECONDS
; FOR DEVICES TO RESPOND.  WE ARE USING MUCH MORE AGGRESSIVE VALUES
; BASED ON REAL WORLD EXPERIENCE.
;
SYQ_TOSLOW	.EQU	120		; SLOW TIMEOUT IS 30 SECS (30 / .25)
SYQ_TONORM	.EQU	4		; NORMAL TIMEOUT IS 1 SEC (1 / .25)
;
; MACROS
;
#DEFINE SYQ_W0(VAL)	LD A,VAL \ CALL SYQ_WRITEDATA
#DEFINE SYQ_R1		CALL SYQ_READSTATUS
#DEFINE SYQ_W2(VAL)	LD A,VAL \ CALL SYQ_WRITECTRL
;
#DEFINE SYQ_WR(REG,VAL)	LD C,REG \ LD A,VAL \ CALL SYQ_WRITEREG
#DEFINE SYQ_RR(REG)	LD C,REG \ CALL SYQ_READREG
;
; INCLUDE MG014 NIBBLE MAP FOR MG014 MODE
;
#IF (SYQMODE == SYQMODE_MG014)
  #DEFINE MG014_MAP
#ENDIF
;
;=============================================================================
; INITIALIZATION ENTRY POINT
;=============================================================================
;
SYQ_INIT:
	; COMPUTE CPU SPEED COMPENSATED TIMEOUT SCALER
	; ONE INTERNAL LOOP IN WAITBSY IS 489TS.  ON A 1 MHZ CPU, 1 TS
	; TAKES 1NS.  SO 1/4 SECOND IS 250000 TS ON A 1 MHZ CPU.
	; SINCE 1 INTERNAL LOOP IS 489 TS, IT TAKES 250000 / 489 = 511
	; INTERNAL LOOPS FOR 1/10 SECOND.  SO, WE WANT TO USE
	; 511 * CPU MHZ FOR INTERNAL LOOP COUNT.
	LD	DE,511			; LOAD SCALER FOR 1MHZ
	LD	A,(CB_CPUMHZ)		; LOAD CPU SPEED IN MHZ
	CALL	MULT8X16		; HL := DE * A
	LD	(SYQ_TOSCALER),HL	; SAVE IT
;
	LD	IY,SYQ_CFG		; POINT TO START OF CONFIG TABLE
;
SYQ_INIT1:
	LD	A,(IY)			; LOAD FIRST BYTE TO CHECK FOR END
	CP	$FF			; CHECK FOR END OF TABLE VALUE
	JR	NZ,SYQ_INIT2		; IF NOT END OF TABLE, CONTINUE
	XOR	A			; SIGNAL SUCCESS
	RET				; AND RETURN
;
SYQ_INIT2:
	CALL	NEWLINE			; FORMATTING
	PRTS("SYQ:$")			; DRIVER LABEL
;
	PRTS(" IO=0x$")			; LABEL FOR IO ADDRESS
	LD	A,(IY+SYQ_IOBASE)	; GET IO BASE ADDRES
	CALL	PRTHEXBYTE		; DISPLAY IT
;
	PRTS(" MODE=$")			; LABEL FOR MODE
	LD	A,(IY+SYQ_MODE)		; GET MODE BITS
	LD	HL,SYQ_STR_MODE_MAP
	ADD	A,A
	CALL	ADDHLA
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	CALL	WRITESTR
;
	; CHECK FOR HARDWARE PRESENCE
	CALL	SYQ_DETECT		; PROBE FOR INTERFACE
	JR	Z,SYQ_INIT4		; IF FOUND, CONTINUE
	CALL	PC_SPACE		; FORMATTING
	LD	DE,SYQ_STR_NOHW		; NO SYQ MESSAGE
	CALL	WRITESTR		; DISPLAY IT
	JR	SYQ_INIT6		; SKIP CFG ENTRY
;
SYQ_INIT4:
	; UPDATE DRIVER RELATIVE UNIT NUMBER IN CONFIG TABLE
	LD	A,(SYQ_DEVNUM)		; GET NEXT UNIT NUM TO ASSIGN
	LD	(IY+SYQ_DEV),A		; UPDATE IT
	INC	A			; BUMP TO NEXT UNIT NUM TO ASSIGN
	LD	(SYQ_DEVNUM),A		; SAVE IT
;
	; ADD UNIT TO GLOBAL DISK UNIT TABLE
	LD	BC,SYQ_FNTBL		; BC := FUNC TABLE ADR
	PUSH	IY			; CFG ENTRY POINTER
	POP	DE			; COPY TO DE
	CALL	DIO_ADDENT		; ADD ENTRY TO GLOBAL DISK DEV TABLE
;
	CALL	SYQ_RESET		; RESET/INIT THE INTERFACE
#IF (SYQTRACE <= 1)
	CALL	NZ,SYQ_PRTSTAT
#ENDIF
	JR	NZ,SYQ_INIT6
;
	; START PRINTING DEVICE INFO
	CALL	SYQ_PRTPREFIX		; PRINT DEVICE PREFIX
;
SYQ_INIT5:
	; PRINT STORAGE CAPACITY (BLOCK COUNT)
	PRTS(" BLOCKS=0x$")		; PRINT FIELD LABEL
	LD	A,SYQ_MEDCAP		; OFFSET TO CAPACITY FIELD
	CALL	LDHLIYA			; HL := IY + A, REG A TRASHED
	CALL	LD32			; GET THE CAPACITY VALUE
	CALL	PRTHEX32		; PRINT HEX VALUE
;
	; PRINT STORAGE SIZE IN MB
	PRTS(" SIZE=$")			; PRINT FIELD LABEL
	LD	B,11			; 11 BIT SHIFT TO CONVERT BLOCKS --> MB
	CALL	SRL32			; RIGHT SHIFT
	CALL	PRTDEC32		; PRINT DWORD IN DECIMAL
	PRTS("MB$")			; PRINT SUFFIX
;
SYQ_INIT6:
	LD	DE,SYQ_CFGSIZ		; SIZE OF CFG TABLE ENTRY
	ADD	IY,DE			; BUMP POINTER
	JP	SYQ_INIT1		; AND LOOP
;
;----------------------------------------------------------------------
; PROBE FOR SYQ HARDWARE
;----------------------------------------------------------------------
;
; ON RETURN, ZF SET INDICATES HARDWARE FOUND
;
SYQ_DETECT:
;
#IF (SYQTRACE >= 3)
	PRTS("\r\nDETECT:$")
#ENDIF
;
#IF (SYQMODE == SYQMODE_MG014)
	; INITIALIZE 8255
	LD	A,(IY+SYQ_IOBASE)	; BASE PORT
	ADD	A,SYQ_IOSETUP		; BUMP TO SETUP PORT
	LD	C,A			; MOVE TO C FOR I/O
	LD	A,$82			; CONFIG A OUT, B IN, C OUT
	OUT	(C),A			; DO IT
	CALL	DELAY			; BRIEF DELAY FOR GOOD MEASURE
#ENDIF
;
	; WE USE THIS SEQUENCE TO DETECT AN ACTUAL SYQ DEVICE ON THE
	; PARALLEL PORT.  THE VALUES RECORDED IN THE FINAL CALL TO
	; SYQ_DISCONNECT ARE USED TO CONFIRM DEVICE PRESENCE.
	; NO ACTUAL ATA COMMANDS ARE USED.
	CALL	SYQ_DISCONNECT
	CALL	SYQ_CONNECT
	CALL	SYQ_DISCONNECT
;
	; THE SYQ_SN VALUES ARE RECORDED IN THE CPP ROUTINE USED BY
	; SYQ_CONNECT/DISCONNECT.
	; EXPECTING S1=$B8, S2=$18, S3=$38
	LD	A,(SYQ_S1)
	CP	$B8
	RET	NZ
	LD	A,(SYQ_S2)
	CP	$18
	RET	NZ
	LD	A,(SYQ_S3)
	CP	$38
	RET	NZ
;
	; PRESENCE CHECK
	CALL	SYQ_CONNECT
;
#IF (SYQTRACE >= 3)
	PRTS(" CHK:$")
#ENDIF
;
	SYQ_WR($18+2,$AA)
	SYQ_WR($18+3,$55)
	SYQ_RR($18+2)
#IF (SYQTRACE >= 3)
	CALL	PC_SPACE
	CALL	PRTHEXBYTE
#ENDIF
	LD	H,A
	SYQ_RR($18+3)
#IF (SYQTRACE >= 3)
	CALL	PC_SPACE
	CALL	PRTHEXBYTE
#ENDIF
	LD	L,A
	CALL	SYQ_DISCONNECT
;
	LD	A,H
	CP	$AA
	RET	NZ
	LD	A,L
	CP	$55
	RET
;
;=============================================================================
; DRIVER FUNCTION TABLE
;=============================================================================
;
SYQ_FNTBL:
	.DW	SYQ_STATUS
	.DW	SYQ_RESET
	.DW	SYQ_SEEK
	.DW	SYQ_READ
	.DW	SYQ_WRITE
	.DW	SYQ_VERIFY
	.DW	SYQ_FORMAT
	.DW	SYQ_DEVICE
	.DW	SYQ_MEDIA
	.DW	SYQ_DEFMED
	.DW	SYQ_CAP
	.DW	SYQ_GEOM
#IF (($ - SYQ_FNTBL) != (DIO_FNCNT * 2))
	.ECHO	"*** INVALID SYQ FUNCTION TABLE ***\n"
#ENDIF
;
SYQ_VERIFY:
SYQ_FORMAT:
SYQ_DEFMED:
	SYSCHKERR(ERR_NOTIMPL)		; NOT IMPLEMENTED
	RET
;
;
;
SYQ_READ:
	CALL	HB_DSKREAD		; HOOK DISK READ CONTROLLER
	LD	B,SYQ_XFR_READ		; READ TRANSFER MODE
	LD	C,SYQ_CMD_READ		; READ COMMAND BYTE
	JP	SYQ_IO			; DO THE I/O
;
;
;
SYQ_WRITE:
	CALL	HB_DSKWRITE		; HOOK DISK WRITE CONTROLLER
	LD	B,SYQ_XFR_WRITE		; WRITE TRANSFER MODE
	LD	C,SYQ_CMD_WRITE		; WRITE COMMAND BYTE
	JP	SYQ_IO			; DO THE I/O
;
;
;
SYQ_IO:
;
	PUSH	BC			; SAVE MODE/COMMAND
	PUSH	HL			; SAVE DISK BUF PTR
	CALL	SYQ_CHKERR		; CHECK FOR ERR STATUS AND RESET IF SO
	POP	HL			; RECOVER DISK BUF PTR
	POP	BC			; RECOVER MODE/COMMAND
	JR	NZ,SYQ_IO1		; BAIL OUT ON ERROR
;
	LD	A,B			; XFR MODE TO ACCUM
	LD	(SYQ_XFRMODE),A		; AND SAVE IT FOR CMD
	LD	(SYQ_DSKBUF),HL		; SAVE DISK BUFFER ADDRESS
	LD	A,SYQ_LBA		; LBA OFFSET IN CONFIG
	CALL	LDHLIYA			; POINT TO LBA DWORD
#IF (DSKYENABLE)
  #IF (DSKYDSKACT)
	CALL	HB_DSKACT		; SHOW ACTIVITY
  #ENDIF
#ENDIF
	CALL	LD32			; SET DE:HL TO LBA
;
	CALL	SYQ_CMDSETUP		; SETUP ATA COMMAND BUF
	CALL	SYQ_RUNCMD		; RUN COMMAND
	JR	NZ,SYQ_IO1		; IF ERR, SKIP INCREMENT
;
	; INCREMENT LBA
	LD	A,SYQ_LBA		; LBA OFFSET
	CALL	LDHLIYA			; HL := IY + A, REG A TRASHED
	CALL	INC32HL			; INCREMENT THE VALUE
;
	; INCREMENT DMA
	LD	HL,SYQ_DSKBUF+1		; POINT TO MSB OF BUFFER ADR
	INC	(HL)			; BUMP DMA BY
	INC	(HL)			; ... 512 BYTES
;
	XOR	A			; SIGNAL SUCCESS
;
SYQ_IO1:
	LD	HL,(SYQ_DSKBUF)		; CURRENT DMA TO HL
	OR	A			; SET FLAGS
	RET				; AND DONE
;
;
;
SYQ_STATUS:
	; RETURN UNIT STATUS
	LD	A,(IY+SYQ_STAT)		; GET STATUS OF SELECTED DEVICE
	OR	A			; SET FLAGS
	RET				; AND RETURN
;
;
;
SYQ_RESET:
	JP	SYQ_INITDEV		; JUST (RE)INIT DEVICE
;
;
;
SYQ_DEVICE:
	LD	D,DIODEV_SYQ		; D := DEVICE TYPE
	LD	E,(IY+SYQ_DEV)		; E := PHYSICAL DEVICE NUMBER
	LD	C,%01111001		; C := REMOVABLE HARD DISK
	LD	H,(IY+SYQ_MODE)		; H := MODE
	LD	L,(IY+SYQ_IOBASE)	; L := BASE I/O ADDRESS
	XOR	A			; SIGNAL SUCCESS
	RET
;
; SYQ_GETMED
;
SYQ_MEDIA:
	LD	A,E			; GET FLAGS
	OR	A			; SET FLAGS
	JR	Z,SYQ_MEDIA1		; JUST REPORT CURRENT STATUS AND MEDIA
;
	CALL	SYQ_RESET		; RESET INCLUDES MEDIA CHECK
;
SYQ_MEDIA1:
	LD	A,(IY+SYQ_STAT)		; GET STATUS
	OR	A			; SET FLAGS
	LD	D,0			; NO MEDIA CHANGE DETECTED
	LD	E,MID_HD		; ASSUME WE ARE OK
	RET	Z			; RETURN IF GOOD INIT
	LD	E,MID_NONE		; SIGNAL NO MEDIA
	LD	A,ERR_NOMEDIA		; NO MEDIA ERROR
	OR	A			; SET FLAGS
	RET				; AND RETURN
;
;
;
SYQ_SEEK:
	BIT	7,D			; CHECK FOR LBA FLAG
	CALL	Z,HB_CHS2LBA		; CLEAR MEANS CHS, CONVERT TO LBA
	RES	7,D			; CLEAR FLAG REGARDLESS (DOES NO HARM IF ALREADY LBA)
	LD	(IY+SYQ_LBA+0),L	; SAVE NEW LBA
	LD	(IY+SYQ_LBA+1),H	; ...
	LD	(IY+SYQ_LBA+2),E	; ...
	LD	(IY+SYQ_LBA+3),D	; ...
	XOR	A			; SIGNAL SUCCESS
	RET				; AND RETURN
;
;
;
SYQ_CAP:
	LD	A,(IY+SYQ_STAT)		; GET STATUS
	PUSH	AF			; SAVE IT
	LD	A,SYQ_MEDCAP		; OFFSET TO CAPACITY FIELD
	CALL	LDHLIYA			; HL := IY + A, REG A TRASHED
	CALL	LD32			; GET THE CURRENT CAPACITY INTO DE:HL
	LD	BC,512			; 512 BYTES PER BLOCK
	POP	AF			; RECOVER STATUS
	OR	A			; SET FLAGS
	RET
;
;
;
SYQ_GEOM:
	; FOR LBA, WE SIMULATE CHS ACCESS USING 16 HEADS AND 16 SECTORS
	; RETURN HS:CC -> DE:HL, SET HIGH BIT OF D TO INDICATE LBA CAPABLE
	CALL	SYQ_CAP			; GET TOTAL BLOCKS IN DE:HL, BLOCK SIZE TO BC
	LD	L,H			; DIVIDE BY 256 FOR # TRACKS
	LD	H,E			; ... HIGH BYTE DISCARDED, RESULT IN HL
	LD	D,16 | $80		; HEADS / CYL = 16, SET LBA CAPABILITY BIT
	LD	E,16			; SECTORS / TRACK = 16
	RET				; DONE, A STILL HAS SYQ_CAP STATUS
;
;=============================================================================
; FUNCTION SUPPORT ROUTINES
;=============================================================================
;
;
;
SYQ_IDENTIFY:
#IF (SYQTRACE >= 3)
	CALL	SYQ_PRTPREFIX
	PRTS(" IDDEV$")
#ENDIF
;
	LD	C,SYQ_CMD_IDDEV
	LD	DE,0
	LD	HL,0
	CALL	SYQ_CMDSETUP
;
	LD	HL,HB_WRKBUF
	LD	(SYQ_DSKBUF),HL
	LD	A,SYQ_XFR_READ
	LD	(SYQ_XFRMODE),A
;
	JP	SYQ_RUNCMD
;
;
;
SYQ_MEDIASTATUS:
#IF (SYQTRACE >= 3)
	CALL	SYQ_PRTPREFIX
	PRTS(" MEDIASTATUS$")
#ENDIF
;
	LD	C,SYQ_CMD_MEDIASTATUS
	LD	DE,0
	LD	HL,0
	CALL	SYQ_CMDSETUP
;
	LD	HL,0
	LD	(SYQ_DSKBUF),HL
	LD	A,SYQ_XFR_NONE
	LD	(SYQ_XFRMODE),A
;
	JP	SYQ_RUNCMD
;
; DE:HL LBA
; C: COMMAND
;
SYQ_CMDSETUP:
	XOR	A
	LD	(SYQ_CMD_FEAT),A
	INC	A
	LD	(SYQ_CMD_COUNT),A
	LD	(SYQ_CMD_LBA0),HL
	LD	(SYQ_CMD_LBA2),DE
	LD	A,$E0
	LD	(SYQ_CMD_DRV),A
	LD	A,C
	LD	(SYQ_CMD_OP),A
	RET
;
;=============================================================================
; COMMAND PROCESSING
;=============================================================================
;
; RUN AN ATA COMMAND USING CMD BUFFER IN SYQ_CMDBUF.
; DATA TRANSFER MODE IN SYQ_XFRMODE: SYQ_XFR_[NONE|READ|WRITE]
; DATA TRANSFER BUFFER PTR IN SYQ_DSKBUF.
;
SYQ_RUNCMD:
;
#IF (SYQTRACE >= 3)
	PRTS(" RUNCMD:$")
#ENDIF
;
	CALL	SYQ_CONNECT		; CONNECT TO DEVICE
;
	LD	(SYQ_CMD_STKSAV),SP	; SAVE STACK FOR ERR EXITS
	LD	HL,SYQ_CMD_EXIT		; SETUP NORMAL RETURN VIA
	PUSH	HL			; ... SYQ_CMDEXIT
	CALL	SYQ_WAITRDY		; WAIT FOR DRIVE READY
;
	LD	B,7
	LD	C,SYQ_REG_PRI + 1
	LD	HL,SYQ_CMDBUF + 1
SYQ_RUNCMD1:
	LD	A,(HL)
#IF (SYQTRACE >= 3)
	CALL	PC_SPACE
	CALL	PRTHEXBYTE
#ENDIF
	PUSH	BC
	CALL	SYQ_WRITEREG
	POP	BC
	INC	HL
	INC	C
	DJNZ	SYQ_RUNCMD1
;
#IF (SYQTRACE >= 3)
	PRTS(" -->$")
#ENDIF
;
	
	LD	A,SYQ_TOSLOW
	LD	(SYQ_TIMEOUT),A
	
	
	LD	A,(SYQ_TIMEOUT)
	PUSH	AF
	LD	A,SYQ_TOSLOW
	CALL	SYQ_WAITBSY		; WAIT FOR DRIVE READY (COMMAND DONE)
	POP	AF
	LD	(SYQ_TIMEOUT),A
	CALL	SYQ_GETRES
;
	LD	A,(SYQ_XFRMODE)		; DATA TRANSFER?
	OR	A			; SET FLAGS
	JR	Z,SYQ_CMD_EXIT		; IF NONE, EXIT, A IS ZERO
	CP	SYQ_XFR_READ		; READ?
	JP	Z,SYQ_GETBUF		; READ DATA TO BUFFER
	CP	SYQ_XFR_WRITE		; WRITE?
	JP	Z,SYQ_PUTBUF		; WRITE DATA FROM BUFFER
	JR	SYQ_CMD_CMDERR		; INVALID VALUE FOR XFR
;
SYQ_CMD_CMDERR:
	LD	A,SYQ_STCMDERR		; SIGNAL COMMAND ERROR
	JR	SYQ_CMD_EXIT		; AND EXIT
;
SYQ_CMD_IOERR:
	LD	A,SYQ_STIOERR		; SIGNAL IO ERROR
	JR	SYQ_CMD_EXIT		; AND EXIT
;
SYQ_CMD_TIMEOUT:
	LD	A,SYQ_STTO		; SIGNAL TIMEOUT ERROR
	JR	SYQ_CMD_EXIT		; AND EXIT
;
SYQ_CMD_EXIT:
	LD	SP,(SYQ_CMD_STKSAV)	; UNWIND STACK
	PUSH	AF			; SAVE RESULT
	CALL	SYQ_DISCONNECT		; DISCONNECT
	POP	AF			; RESTORE RESULT
	OR	A			; ERROR?
	JP	NZ,SYQ_ERR		; IF SO, HANDLE IT
	RET				; NORMAL RETURN
;
;
;
SYQ_GETRES:
	SYQ_RR(SYQ_REG_STAT)
#IF (SYQTRACE >= 3)
	CALL	PC_SPACE
	CALL	PRTHEXBYTE
#ENDIF
	AND	%00000001		; ERROR BIT SET?
	RET	Z			; NOPE, RETURN WITH ZF
;
	SYQ_RR(SYQ_REG_ERR)
#IF (SYQTRACE >= 3)
	CALL	PC_SPACE
	CALL	PRTHEXBYTE
#ENDIF
	JP	SYQ_CMD_CMDERR
;
;
;
SYQ_GETBUF:
	SYQ_W0(7)
	SYQ_W2(1)
	SYQ_W2(3)
	SYQ_W0($FF)

	LD	B,0			; LOOP COUNTER
	LD	DE,(SYQ_DSKBUF)		; INIT BUFFER PTR
	EXX				; SWITCH TO ALT REGS
	EX	AF,AF'			; SWITCH TO ALT AF
	; SAVE ALT REGS
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	; C: PORT C	
	LD	A,(IY+SYQ_IOBASE)	; BASE PORT
	INC	A			; STATUS PORT
	LD	(SYQ_GETBUF_A),A	; FILL IN
	LD	(SYQ_GETBUF_B),A	; ... DYNAMIC BITS OF CODE
	LD	(SYQ_GETBUF_C),A	;
	LD	(SYQ_GETBUF_D),A	;
	INC	A			; CONTROL PORT
	LD	C,A			; ... TO C
#IF (SYQMODE == SYQMODE_MG014)
	; HL: STATMAP
	LD	H,MG014_STATMAPLO >> 8
#ENDIF
	EXX				; SWITCH TO PRI REGS
	EX	AF,AF'			; SWITCH TO PRI AF
	CALL	SYQ_GETBUF1		; 256 WORDS
	; RESTORE ALT REGS
	EXX				; SWITCH TO ALT REGS
	EX	AF,AF'			; SWITCH TO ALT AF
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	EXX				; SWITCH TO PRI REGS
	EX	AF,AF'			; SWITCH TO PRI AF
	SYQ_W0(0)
	SYQ_W2(4)
;
	XOR	A			; SIGNAL SUCCESS
	RET
;
SYQ_GETBUF1:
;
	; FIRST BYTE
	EXX				; ALT REGS
;
	; DE: CLOCK VALUES FOR FIRST BYTE
#IF (SYQMODE == SYQMODE_MG014)
	LD	D,$06 ^ ($0B | $80)
	LD	E,$04 ^ ($0B | $80)
#ENDIF
#IF (SYQMODE == SYQMODE_SPP)
	LD	D,$06
	LD	E,$04
#ENDIF
	OUT	(C),D			; FIRST CLOCK
	NOP				; SMALL DELAY SEEMS TO BE NEEDED
SYQ_GETBUF_A	.EQU	$+1
	IN	A,($FF)			; GET LOW NIBBLE
#IF (SYQMODE == SYQMODE_MG014)
	AND	$0F			; RELEVANT BITS ONLY
	ADD	A,MG014_STATMAPLO & $FF	; LOW BYTE OF MAP PTR
	LD	L,A			; PUT IN L
	LD	A,(HL)			; LOOKUP LOW NIBBLE VALUE
	EX	AF,AF'			; ALT AF, SAVE NIBBLE
#ENDIF
#IF (SYQMODE == SYQMODE_SPP)
	AND	$F0			; RELEVANT BITS ONLY
	RLCA				; MOVE TO LOW NIBBLE
	RLCA				; MOVE TO LOW NIBBLE
	RLCA				; MOVE TO LOW NIBBLE
	RLCA				; MOVE TO LOW NIBBLE
	LD	L,A			; SAVE NIBBLE IN L
#ENDIF
	OUT	(C),E			; SECOND CLOCK
	NOP				; SMALL DELAY SEEMS TO BE NEEDED
SYQ_GETBUF_B	.EQU	$+1
	IN	A,($FF)			; GET HIGH NIBBLE
#IF (SYQMODE == SYQMODE_MG014)
	AND	$0F			; RELEVANT BITS ONLY
	ADD	A,MG014_STATMAPHI & $FF	; HIGH BYTE OF MAP PTR
	LD	L,A			; PUT IN L
	EX	AF,AF'			; PRI AF, RECOVER LOW NIBBLE VALUE
	OR	(HL)			; COMBINE WITH HIGH NIB VALUE
#ENDIF
#IF (SYQMODE == SYQMODE_SPP)
	AND	$F0			; RELEVANT BITS ONLY
	OR	L			; COMBINE WITH HIGH NIB VALUE
#ENDIF
	EXX				; SWITCH TO PRI REGS
	LD	(DE),A			; SAVE BYTE
	INC	DE			; BUMP BUF PTR
;
	; SPECIAL HANDLING FOR LAST BYTE
	LD	A,B			; GET ITERATION COUNTER
	DEC	A			; SET ZF IF ON LAST ITERATION
	JR	NZ,SYQ_GETBUF2		; IF NOT SET, SKIP OVER
	LD	A,$FF			; VALUE TO WRITE
	CALL	SYQ_WRITEDATA		; PUT VALUE ON DATA BUS
;
SYQ_GETBUF2:
	; SECOND BYTE
	EXX				; ALT REGS
;
	; DE: CLOCK VALUES FOR SECOND BYTE
#IF (SYQMODE == SYQMODE_MG014)
	LD	D,$07 ^ ($0B | $80)
	LD	E,$05 ^ ($0B | $80)
#ENDIF
#IF (SYQMODE == SYQMODE_SPP)
	LD	D,$07
	LD	E,$05
#ENDIF
	OUT	(C),D			; FIRST CLOCK
	NOP				; SMALL DELAY SEEMS TO BE NEEDED
SYQ_GETBUF_C	.EQU	$+1
	IN	A,($FF)			; GET LOW NIBBLE
#IF (SYQMODE == SYQMODE_MG014)
	AND	$0F			; RELEVANT BITS ONLY
	ADD	A,MG014_STATMAPLO & $FF	; LOW BYTE OF MAP PTR
	LD	L,A			; PUT IN L
	LD	A,(HL)			; LOOKUP LOW NIBBLE VALUE
	EX	AF,AF'			; ALT AF, SAVE NIBBLE
#ENDIF
#IF (SYQMODE == SYQMODE_SPP)
	AND	$F0			; RELEVANT BITS ONLY
	RLCA				; MOVE TO LOW NIBBLE
	RLCA				; MOVE TO LOW NIBBLE
	RLCA				; MOVE TO LOW NIBBLE
	RLCA				; MOVE TO LOW NIBBLE
	LD	L,A			; SAVE NIBBLE IN L
#ENDIF
	OUT	(C),E			; SECOND CLOCK
	NOP				; SMALL DELAY SEEMS TO BE NEEDED
SYQ_GETBUF_D	.EQU	$+1
	IN	A,($FF)			; GET HIGH NIBBLE
#IF (SYQMODE == SYQMODE_MG014)
	AND	$0F			; RELEVANT BITS ONLY
	ADD	A,MG014_STATMAPHI & $FF	; HIGH BYTE OF MAP PTR
	LD	L,A			; PUT IN L
	EX	AF,AF'			; PRI AF, RECOVER LOW NIBBLE VALUE
	OR	(HL)			; COMBINE WITH HIGH NIB VALUE
#ENDIF
#IF (SYQMODE == SYQMODE_SPP)
	AND	$F0			; RELEVANT BITS ONLY
	OR	L			; COMBINE WITH HIGH NIB VALUE
#ENDIF
	EXX				; SWITCH TO PRI REGS
	LD	(DE),A			; SAVE BYTE
	INC	DE			; BUMP BUF PTR
;
	DJNZ	SYQ_GETBUF1		; LOOP
	RET				; DONE
;
;
;
SYQ_PUTBUF:
	SYQ_W0($67)
	SYQ_W2(1)
	SYQ_W2(5)
;
	LD	DE,(SYQ_DSKBUF)		; INIT BUFFER PTR
	LD	B,0			; READ 256 WORDS
	LD	A,(IY+SYQ_IOBASE)	; GET BASE IO ADR
	LD	(SYQ_PUTBUF_A),A	; FILL IN
	LD	(SYQ_PUTBUF_B),A	; ... DYNAMIC BITS OF CODE
	INC	A			; STATUS PORT
	INC	A			; CONTROL PORT
	LD	C,A			; ... TO C
	; HL: CLOCK VALUES
#IF (SYQMODE == SYQMODE_MG014)
	LD	H,$04 ^ ($0B | $80)
	LD	L,$05 ^ ($0B | $80)
#ENDIF
#IF (SYQMODE == SYQMODE_SPP)
	LD	H,$04
	LD	L,$05
#ENDIF
	CALL	SYQ_PUTBUF1		; ONE LOOP CUZ BYTE PAIRS
	SYQ_W2(7)
	SYQ_W2(4)
;
	XOR	A
	RET
;
SYQ_PUTBUF1:
	LD	A,(DE)			; GET NEXT BYTE
SYQ_PUTBUF_A	.EQU	$+1
	OUT	($FF),A			; PUT ON BUS
	INC	DE			; INCREMENT BUF POS
	OUT	(C),H			; FIRST CLOCK
	LD	A,(DE)			; GET NEXT BYTE
SYQ_PUTBUF_B	.EQU	$+1
	OUT	($FF),A			; PUT ON BUS
	INC	DE			; INCREMENT BUF POS
	OUT	(C),L			; SECOND CLOCK
	DJNZ	SYQ_PUTBUF1		; LOOP
	RET				; DONE
;
; (RE)INITIALIZE DEVICE
;
SYQ_INITDEV:
;
#IF (SYQTRACE >= 3)
	PRTS("\r\nINITDEV:$")
#ENDIF
;
#IF (SYQMODE == SYQMODE_MG014)
	; INITIALIZE 8255
	LD	A,(IY+SYQ_IOBASE)	; BASE PORT
	ADD	A,SYQ_IOSETUP		; BUMP TO SETUP PORT
	LD	C,A			; MOVE TO C FOR I/O
	LD	A,$82			; CONFIG A OUT, B IN, C OUT
	OUT	(C),A			; DO IT
	CALL	DELAY			; SHORT DELAY FOR BUS SETTLE
#ENDIF
;
	CALL	SYQ_CONNECT		; NOW CONNECT TO BUS
	CALL	SYQ_DISCONNECT		; DISCONNECT FIRST JUST IN CASE
	CALL	SYQ_CONNECT		; NOW CONNECT TO BUS
;
	; ATA SOFT RESET
	LD	C,SYQ_REG_CTRL
	LD	A,%00001010
	CALL	SYQ_WRITEREG
	CALL	DELAY
	LD	C,SYQ_REG_CTRL
	LD	A,%00001110
	CALL	SYQ_WRITEREG
	CALL	DELAY
	LD	C,SYQ_REG_CTRL
	LD	A,%00001010
	CALL	SYQ_WRITEREG
	CALL	DELAY

#IF (SYQTRACE >= 3)
	; SELECT PRIMARY IDE DRIVE
	LD	C,SYQ_REG_DRVHD
	LD	A,$A0
	CALL	SYQ_WRITEREG
;
	PRTS(" ATA REGS:$")
	CALL	SYQ_REGDUMP		; DUMP ATA PRIMARY REGISTERS
#ENDIF
;
	CALL	SYQ_DISCONNECT
;
	; ISSUE DEVICE IDENTIFY COMMAND TO READ AND RECORD
	; DEVICE CAPACITY.
	CALL	SYQ_IDENTIFY		; RUN IDENTIFY COMMAND
	RET	NZ			; BAIL OUT ON ERROR
;
	LD	DE,HB_WRKBUF		; POINT TO BUFFER
#IF (SYQTRACE >= 4)
	CALL	DUMP_BUFFER		; DUMP IT IF DEBUGGING
#ENDIF
;
	; GET DEVICE CAPACITY AND SAVE IT
	LD	A,SYQ_MEDCAP		; OFFSET TO CAPACITY FIELD
	CALL	LDHLIYA			; HL := IY + A, REG A TRASHED
	PUSH	HL			; SAVE POINTER
	LD	HL,HB_WRKBUF		; POINT TO BUFFER START
	LD	A,120			; OFFSET OF SECTOR COUNT
	CALL	ADDHLA			; POINT TO ADDRESS OF SECTOR COUNT
	CALL	LD32			; LOAD IT TO DE:HL
	POP	BC			; RECOVER POINTER TO CAPACITY ENTRY
	CALL	ST32			; SAVE CAPACITY
;
	; ISSUE MEDIA STATUS A FEW TIMES TO CLEAR ANY PENDING ERRORS
	; (LIKE MEDIA CHANGE) AND DETERMINE IF MEDIA IS LOADED.  IF
	; AN ERROR IS STILL OCCURRING AFTER MULTIPLE ATTEMPTS, WE
	; ASSUME MEDIA IS NOT LOADED IN DEVICE.
	LD	B,4			; 4 TRIES
SYQ_INITDEV1:
	PUSH	BC
	CALL	SYQ_MEDIASTATUS
	POP	BC
	JR	Z,SYQ_INITDEV2		; MOVE ON IF NO ERROR
	DJNZ	SYQ_INITDEV1		; LOOP AS NEEDED
	JP	SYQ_NOMEDIA		; EXIT W/ NO MEDIA STATUS
;
SYQ_INITDEV2:
;
	; RECORD STATUS OK
	XOR	A			; A := 0 (STATUS = OK)
	LD	(IY+SYQ_STAT),A		; SAVE IT
;
	RET				; RETURN, A=0, Z SET
;
;=============================================================================
; INTERFACE SUPPORT ROUTINES
;=============================================================================
;
; OUTPUT BYTE IN A TO THE DATA PORT
;
SYQ_WRITEDATA:								; 17 (CALL)
	LD	C,(IY+SYQ_IOBASE)	; DATA PORT IS AT IOBASE	; 19
	OUT	(C),A			; WRITE THE BYTE		; 12
	;CALL	DELAY			; IS THIS NEEDED???
	RET				; DONE				; 10
;									; --> 58
;
;
SYQ_WRITECTRL:								; 17 (CALL)
	; IBM PC INVERTS ALL BUT C2 ON THE BUS, MG014 DOES NOT.
	; BELOW TRANSLATES FROM IBM -> MG014.	IT ALSO INVERTS THE
	; MG014 LED SIMPLY TO MAKE IT EASY TO KEEP LED ON DURING
	; ALL ACTIVITY.
;
#IF (SYQMODE == SYQMODE_MG014
	XOR	$0B | $80		; HIGH BIT IS MG014 LED
#ENDIF
	LD	C,(IY+SYQ_IOBASE)	; GET BASE IO ADDRESS		; 19
	INC	C			; BUMP TO CONTROL PORT		; 4
	INC	C							; 4
	OUT	(C),A			; WRITE TO CONTROL PORT		; 12
	;CALL	DELAY			; IS THIS NEEDED?
	RET				; DONE				; 10
;									; --> 49
; READ THE PARALLEL PORT INPUT LINES (STATUS) AND MAP SIGNALS FROM
; MG014 TO IBM STANDARD.  NOTE POLARITY CHANGE REQUIRED FOR BUSY.
;
; 	MG014		IBM PC (SPP)
;	--------	--------
;	0: /ACK		6: /ACK
;	1: BUSY		7: /BUSY
;	2: POUT		5: POUT
;	3: SEL		4: SEL
;	4: /ERR		3: /ERR
;
SYQ_READSTATUS:								; 17 (CALL)
	LD	C,(IY+SYQ_IOBASE)	; IOBASE TO C			; 19
	INC	C			; BUMP TO STATUS PORT		; 4
	IN	A,(C)			; READ IT			; 12
;
#IF (SYQMODE == SYQMODE_MG014
;
	; SHUFFLE BITS ON MG014
	LD	C,0			; INIT RESULT
	BIT	0,A			; 0: /ACK
	JR	Z,SYQ_READSTATUS1
	SET	6,C			; 6: /ACK
SYQ_READSTATUS1:
	BIT	1,A			; 1: BUSY
	JR	NZ,SYQ_READSTATUS2	; POLARITY CHANGE!
	SET	7,C			; 7: /BUSY
SYQ_READSTATUS2:
	BIT	2,A			; 2: POUT
	JR	Z,SYQ_READSTATUS3
	SET	5,C			; 5: POUT
SYQ_READSTATUS3:
	BIT	3,A			; 3: SEL
	JR	Z,SYQ_READSTATUS4
	SET	4,C			; 4: SEL
SYQ_READSTATUS4:
	BIT	4,A			; 4: /ERR
	JR	Z,SYQ_READSTATUS5
	SET	3,C			; 3: /ERR
SYQ_READSTATUS5:
	LD	A,C			; RESULT TO A
;
#ENDIF
;
	RET								; 10
;									; --> 62
; SIGNAL SEQUENCE TO CONNECT/DISCONNECT
; VALUE IN A IS WRITTEN TO DATA PORT DURING SEQUENCE
;
SYQ_CPP:
	PUSH	AF
	SYQ_W2(4)
	SYQ_W0($22)
	SYQ_W0($AA)
	SYQ_W0($55)
	SYQ_W0(0)
	SYQ_W0($FF)
;
	CALL	SYQ_READSTATUS
	AND	$B8
	LD	(SYQ_S1),A
;
	SYQ_W0($87)
;
	CALL	SYQ_READSTATUS
	AND	$B8
	LD	(SYQ_S2),A
;
	SYQ_W0($78)
;
	CALL	SYQ_READSTATUS
	AND	$38
	LD	(SYQ_S3),A
;
	POP	AF
	CALL	SYQ_WRITEDATA
	SYQ_W2(4)
	SYQ_W2(5)
	SYQ_W2(4)
	SYQ_W0($FF)
;
	; CONNECT: S1=$B8 S2=$18 S3=$30
	; DISCONNECT: S1=$B8 S2=$18 S3=$38

#IF (SYQTRACE >= 4)
	PRTS(" CPP: S1=$")
	LD	A,(SYQ_S1)
	CALL	PRTHEXBYTE
	PRTS(" S2=$")
	LD	A,(SYQ_S2)
	CALL	PRTHEXBYTE
	PRTS(" S3=$")
	LD	A,(SYQ_S3)
	CALL	PRTHEXBYTE
#ENDIF
;
	XOR	A		; ASSUME SUCCESS FOR NOW
	RET
;
SYQ_S1	.DB	0
SYQ_S2	.DB	0
SYQ_S3	.DB	0
;
; SEQUENCE TO CONNECT TO DEVICE ON PARALLEL PORT BUS.
;
SYQ_CONNECT:
;
#IF (SYQTRACE >= 3)
	PRTS(" CONNECT:$")
#ENDIF
;
	LD	A,$00		; INITIALIZE THE CHIP
	CALL	SYQ_CPP
;
	LD	A,$E0		; CONNECT TO THE CHIP
	CALL	SYQ_CPP
;
	SYQ_W0(0)
	SYQ_W2(1)
	SYQ_W2(4)
;
	SYQ_WR($08,$10)
	SYQ_WR($0C,$14)
	SYQ_WR($0A,$38)
	SYQ_WR($12,$10)
;
	RET
;
; SEQUENCE TO DISCONNECT FROM DEVICE ON PARALLEL PORT BUS.
; THE FINAL SYQ_WRITECTRL IS ONLY TO TURN OFF THE MG014 STATUS LED.
;
SYQ_DISCONNECT:
;
#IF (SYQTRACE >= 3)
	PRTS(" DISCON:$")
#ENDIF
;
	LD	A,$30		; DISCONNECT FROM THE CHIP
	CALL	SYQ_CPP
;
	; TURNS OFF MG014 LED
	SYQ_W2($8C)
;
	RET
;
; WRITE VALUE IN A TO ATA REGISTER IN C
;
SYQ_WRITEREG:
	PUSH	AF
	LD	A,$60
	ADD	A,C
	CALL	SYQ_WRITEDATA
	SYQ_W2(1)
	POP	AF
	CALL	SYQ_WRITEDATA
	SYQ_W2(4)
	RET
;
; READ VALUE FROM ATA REGISTER IN C
;
SYQ_READREG:				; 17 (CALL)
	LD	A,C			; 4
	CALL	SYQ_WRITEDATA		; 58
	SYQ_W2(1)			; 49 + 7
	SYQ_W2(3)			; 49 + 7
	CALL	SYQ_READSTATUS		; 62
	AND	$F0			; 7
	RRCA				; 4
	RRCA				; 4
	RRCA				; 4
	RRCA				; 4
	LD	C,A			; 4
	PUSH	BC			; 11
	SYQ_W2(4)			; 49 + 7
	CALL	SYQ_READSTATUS		; 62
	AND	$F0			; 7
	POP	BC			; 10
	OR	C			; 4
	RET				; 10
;					; --> 440
; CHECK CURRENT DEVICE FOR ERROR STATUS AND ATTEMPT TO RECOVER
; VIA RESET IF DEVICE IS IN ERROR.
;
SYQ_CHKERR:
	LD	A,(IY+SYQ_STAT)		; GET STATUS
	OR	A			; SET FLAGS
	CALL	NZ,SYQ_RESET		; IF ERROR STATUS, RESET BUS
	RET
;
;
;
SYQ_WAITRDY:
	LD	A,(SYQ_TIMEOUT)		; GET TIMEOUT IN 0.05 SECS
	LD	B,A			; PUT IN OUTER LOOP VAR
SYQ_WAITRDY1:
	LD	A,B
	LD	DE,(SYQ_TOSCALER)	; CPU SPPED SCALER TO INNER LOOP VAR
SYQ_WAITRDY2:
	SYQ_RR(SYQ_REG_STAT)
	LD	C,A			; SAVE IT???
	AND	%11000000		; ISOLATE BUSY AND RDY BITS
	XOR	%01000000		; WE WANT BUSY(7) TO BE 0 AND RDY(6) TO BE 1
	RET	Z			; ALL SET, RETURN WITH Z SET
	DEC	DE
	LD	A,D
	OR	E
	JR	NZ,SYQ_WAITRDY2		; INNER LOOP RETURN
	DJNZ	SYQ_WAITRDY1		; OUTER LOOP RETURN
	JP	SYQ_CMD_TIMEOUT		; EXIT WITH RDYTO ERR
;
;
;
SYQ_WAITDRQ:
	LD	A,(SYQ_TIMEOUT)		; GET TIMEOUT IN 0.1 SECS
	LD	B,A			; PUT IN OUTER LOOP VAR
SYQ_WAITDRQ1:
	LD	DE,(SYQ_TOSCALER)	; CPU SPPED SCALER TO INNER LOOP VAR
SYQ_WAITDRQ2:
	SYQ_RR(SYQ_REG_STAT)
	LD	C,A			; SAVE IT???
	AND	%10001000		; TO FILL (OR READY TO FILL)
	XOR	%00001000
	RET	Z
	DEC	DE
	LD	A,D
	OR	E
	JR	NZ,SYQ_WAITDRQ2
	DJNZ	SYQ_WAITDRQ1
	JP	SYQ_CMD_TIMEOUT		; EXIT WITH BUFTO ERR
;
;
;
SYQ_WAITBSY:
	LD	A,(SYQ_TIMEOUT)		; GET TIMEOUT IN 0.1 SECS
	LD	B,A			; PUT IN OUTER LOOP VAR
SYQ_WAITBSY1:
	LD	DE,(SYQ_TOSCALER)	; CPU SPPED SCALER TO INNER LOOP VAR
SYQ_WAITBSY2:
	SYQ_RR(SYQ_REG_STAT)								; 440 + 7
	LD	C,A			; SAVE IT???					; 4TS
	AND	%10000000		; TO FILL (OR READY TO FILL)			; 7TS
	RET	Z									; 5TS
	DEC	DE									; 6TS
	LD	A,D									; 4TS
	OR	E									; 4TS
	JR	NZ,SYQ_WAITBSY2								; 12TS
	DJNZ	SYQ_WAITBSY1								; -----
	JP	SYQ_CMD_TIMEOUT		; EXIT WITH BSYTO ERR				; 489
;
;=============================================================================
; ERROR HANDLING AND DIAGNOSTICS
;=============================================================================
;
; ERROR HANDLERS
;
SYQ_NOMEDIA:
	LD	A,SYQ_STNOMEDIA
	JR	SYQ_ERR
;
SYQ_CMDERR:
	LD	A,SYQ_STCMDERR
	JR	SYQ_ERR
;
SYQ_IOERR:
	LD	A,SYQ_STIOERR
	JR	SYQ_ERR
;
SYQ_TO:
	LD	A,SYQ_STTO
	JR	SYQ_ERR
;
SYQ_NOTSUP:
	LD	A,SYQ_STNOTSUP
	JR	SYQ_ERR
;
SYQ_ERR:
	LD	(IY+SYQ_STAT),A		; SAVE NEW STATUS
;
SYQ_ERR2:
#IF (SYQTRACE >= 2)
	CALL	SYQ_PRTSTAT
#ENDIF
	OR	A			; SET FLAGS
	RET
;
;
;
SYQ_PRTERR:
	RET	Z			; DONE IF NO ERRORS
	; FALL THRU TO SYQ_PRTSTAT
;
; PRINT FULL DEVICE STATUS LINE
;
SYQ_PRTSTAT:
	PUSH	AF
	PUSH	DE
	PUSH	HL
	LD	A,(IY+SYQ_STAT)
	CALL	SYQ_PRTPREFIX		; PRINT UNIT PREFIX
	CALL	PC_SPACE		; FORMATTING
	CALL	SYQ_PRTSTATSTR
	POP	HL
	POP	DE
	POP	AF
	RET
;
; PRINT STATUS STRING
;
SYQ_PRTSTATSTR:
	PUSH	AF
	PUSH	DE
	PUSH	HL
	LD	A,(IY+SYQ_STAT)
	NEG
	LD	HL,SYQ_STR_ST_MAP
	ADD	A,A
	CALL	ADDHLA
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	CALL	WRITESTR
	POP	HL
	POP	DE
	POP	AF
	RET
;
; PRINT ALL REGISTERS DIRECTLY FROM DEVICE
; DEVICE MUST BE CONNECTED AND SELECTED PRIOR TO CALL
;
SYQ_REGDUMP:
	PUSH	AF
	PUSH	BC
	CALL	PC_SPACE
	CALL	PC_LBKT
	LD	B,8
	LD	C,SYQ_REG_PRI
SYQ_REGDUMP1:
	PUSH	BC
	CALL	SYQ_READREG
	POP	BC
	CALL	PRTHEXBYTE
	INC	C
	DEC	B
	CALL	NZ,PC_SPACE
	JR	NZ,SYQ_REGDUMP1
	CALL	PC_RBKT
	POP	BC
	POP	AF
	RET
;
; PRINT DEVICE/UNIT PREFIX
;
SYQ_PRTPREFIX:
	PUSH	AF
	CALL	NEWLINE
	PRTS("SYQ$")
	LD	A,(IY+SYQ_DEV)		; GET CURRENT DEVICE NUM
	CALL	PRTDECB
	CALL	PC_COLON
	POP	AF
	RET
;
;=============================================================================
; STRING DATA
;=============================================================================
;
SYQ_STR_ST_MAP:
	.DW		SYQ_STR_ST_OK
	.DW		SYQ_STR_ST_NOMEDIA
	.DW		SYQ_STR_ST_CMDERR
	.DW		SYQ_STR_ST_IOERR
	.DW		SYQ_STR_ST_TO
	.DW		SYQ_STR_ST_NOTSUP
;
SYQ_STR_ST_OK		.TEXT	"OK$"
SYQ_STR_ST_NOMEDIA	.TEXT	"NO MEDIA$"
SYQ_STR_ST_CMDERR	.TEXT	"COMMAND ERROR$"
SYQ_STR_ST_IOERR	.TEXT	"IO ERROR$"
SYQ_STR_ST_TO		.TEXT	"TIMEOUT$"
SYQ_STR_ST_NOTSUP	.TEXT	"NOT SUPPORTED$"
SYQ_STR_ST_UNK		.TEXT	"UNKNOWN ERROR$"
;
SYQ_STR_MODE_MAP:
	.DW	SYQ_STR_MODE_NONE
	.DW	SYQ_STR_MODE_SPP
	.DW	SYQ_STR_MODE_MG014
;
SYQ_STR_MODE_NONE	.TEXT	"NONE$"
SYQ_STR_MODE_SPP	.TEXT	"SPP$"
SYQ_STR_MODE_MG014	.TEXT	"MG014$"
;
SYQ_STR_NOHW		.TEXT	"NOT PRESENT$"
;
;=============================================================================
; DATA STORAGE
;=============================================================================
;
SYQ_DEVNUM	.DB	0		; TEMP DEVICE NUM USED DURING INIT
SYQ_CMDSTK	.DW	0		; STACK PTR FOR CMD ABORTING
SYQ_DSKBUF	.DW	0		; WORKING DISK BUFFER POINTER
SYQ_XFRLEN	.DW	0		; WORKING TRANSFER LENGTH
SYQ_CMD		.DB	0		; CURRENT ATA COMMAND
SYQ_XFRMODE	.DB	0		; COMMAND DATA TRANSFER MODE
SYQ_CMD_STKSAV	.DW	0		; STACK FOR CMD ERROR EXIT
;
SYQ_CMDBUF:
SYQ_CMD_DATA	.DB	0
SYQ_CMD_FEAT	.DB	0
SYQ_CMD_COUNT	.DB	0
SYQ_CMD_LBA0	.DB	0
SYQ_CMD_LBA1	.DB	0
SYQ_CMD_LBA2	.DB	0
SYQ_CMD_DRV	.DB	0
SYQ_CMD_OP	.DB	0
;
SYQ_TIMEOUT	.DB	SYQ_TONORM	; WAIT FUNCS TIMEOUT IN TENTHS OF SEC
SYQ_TOSCALER	.DW	CPUMHZ * 511	; WAIT FUNCS SCALER FOR CPU SPEED
;
; SYQ DEVICE CONFIGURATION TABLE
;
SYQ_CFG:
;
#IF (SYQCNT >= 1)
;
SYQ0_CFG:	; DEVICE 0
	.DB	0			; DRIVER DEVICE NUMBER (FILLED DYNAMICALLY)
	.DB	SYQMODE			; DRIVER DEVICE MODE
	.DB	0			; DEVICE STATUS
	.DB	SYQ0BASE		; IO BASE ADDRESS
	.DW	0,0			; DEVICE CAPACITY
	.DW	0,0			; CURRENT LBA
;
	DEVECHO	"SYQ: MODE="
  #IF (SYQMODE == SYQMODE_SPP)
	DEVECHO	"SPP"
  #ENDIF
  #IF (SYQMODE == SYQMODE_MG014)
	DEVECHO	"MG014"
  #ENDIF
	DEVECHO	", IO="
	DEVECHO	SYQ0BASE
	DEVECHO	"\n"
#ENDIF
;
#IF (SYQCNT >= 2)
;
SYQ1_CFG:	; DEVICE 1
	.DB	0			; DRIVER DEVICE NUMBER (FILLED DYNAMICALLY)
	.DB	SYQMODE			; DRIVER DEVICE MODE
	.DB	0			; DEVICE STATUS
	.DB	SYQ1BASE		; IO BASE ADDRESS
	.DW	0,0			; DEVICE CAPACITY
	.DW	0,0			; CURRENT LBA
;
	DEVECHO	"SYQ: MODE="
  #IF (SYQMODE == SYQMODE_SPP)
	DEVECHO	"SPP"
  #ENDIF
  #IF (SYQMODE == SYQMODE_MG014)
	DEVECHO	"MG014"
  #ENDIF
	DEVECHO	", IO="
	DEVECHO	SYQ1BASE
	DEVECHO	"\n"
#ENDIF
;
#IF ($ - SYQ_CFG) != (SYQCNT * SYQ_CFGSIZ)
	.ECHO	"*** INVALID SYQ CONFIG TABLE ***\n"
#ENDIF
;
	.DB	$FF			; END MARKER
