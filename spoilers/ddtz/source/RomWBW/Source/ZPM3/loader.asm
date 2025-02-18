;===============================================================================
; LOADER.ASM
;
; BOOTLOADER FOR ROMWBW DISK OPERATING SYSTEMS.
;
; CP/M DISK FORMATS ALLOW FOR RESERVED TRACKS THAT CONTAIN AN IMAGE OF THE
; OPERATING SYSTEM TO BE LOADED WHEN THE DISK IS BOOTED.  THE OPERATING SYSTEM
; IMAGE ITSELF IS NORMALLY PREFIXED BY A 1-N SECTORS CONTAINING OS BOOTSTRAP
; CODE AND DISK METADATA.
;
; THE RETROBREW COMPUTING GROUP HAS BEEN USING A CONVENTION OF PREFIXING THE
; OS IMAGE WITH 3 SECTORS (512 BYTES X 3 FOR A TOTAL OF 1536 BYTES):
;
;   SECTOR 1: IBM-PC STYLE BOOT BLOCK CONTAINING BOOTSTRAP, 
;             PARTITION TABLE, AND BOOT SIGNATURE
;   SECTOR 2: RESERVED
;   SECTOR 3: METADATA
;
; THE HARDWARE BIOS IS EXPECTED TO READ AND LOAD THE FIRST TWO SECTORS FROM THE
; DISK TO MEMORY ADDRESS $8000 AND JUMP TO THAT LOCATION TO BEGIN THE BOOT
; PROCESS.  THE BIOS IS EXPECTED TO VERIFY THAT A STANDARD BOOT SIGNATURE
; OF $55, $AA IS PRESENT AT OFFSET $1FE-$1FF.  IF THE SIGNATURE IS NOT FOUND,
; THE BIOS SHOULD ASSUME THE DISK HAS NOT BEEN PROPERLY INITIALIZED AND SHOULD
; NOT JUMP TO THE LOAD ADDRESS.
;
;===============================================================================
;
#INCLUDE "../ver.inc"
;
; BELOW, SYS_END MUST BE SET TO THE SIZE OF CPMLDR.BIN + SYS_LOC.  IF
; THE SIZE OF ZPMLDR.BIN CHANGES, SYS_SIZ MUST BE UPDATED!!!
;
SYS_SIZ		.EQU	$0F00		; SIZE OF CPMLDR.BIN
SYS_ENT		.EQU	$0100		; SYSTEM (OS) ENTRY POINT ADDRESS
SYS_LOC		.EQU	$0100		; STARTING ADDRESS TO LOAD SYSTEM IMAGE
SYS_END		.EQU	SYS_SIZ + SYS_LOC	; ENDING ADDRESS OF SYSTEM IMAGE
;
SEC_SIZE	.EQU	512		; DISK SECTOR SIZE
BLK_SIZE	.EQU	128		; OS BLOCK/RECORD SIZE
;
PREFIX_SIZE	.EQU	(SEC_SIZE * 3)	; 3 SECTORS
;
META_SIZE	.EQU	32		; SEE BELOW
META_LOC	.EQU	(PREFIX_SIZE - META_SIZE)
;
PT_LOC		.EQU	$1BE
PT_SIZ		.EQU	$40
;
;-------------------------------------------------------------------------------
; SECTOR 1
;
;   THIS SECTOR FOLLOWS THE CONVENTIONS OF AN IBM-PC MBR CONTAINING THE OS
;   BOOTSTRAP CODE, PARTITION TABLE, AND BOOT SIGNATURE
;
;----------------------------------------------------------------------------
;
; THE FOLLOWING BOOTSTRAP CODE IS BUILT TO ASSUME IT WILL BE EXECUTED AT A STARTING
; ADDRESS OF $8000.  THIS CODE IS *ONLY* FOR UNA.  THE ROMWBW ROM BOOTLOADER
; USES THE METADATA TO LOAD THE OS DIRECTLY.
;
	.ORG	$8000
	JR	BOOT
;
BOOT:
	LD	DE,STR_LOAD	; LOADING STRING
	CALL	PRTSTR		; PRINT
	CALL	PRTDOT		; PROGRESS
;
	LD	BC,$00FC	; UNA FUNC: GET BOOTSTRAP HISTORY
	CALL	$FFFD		; CALL UNA
	JR	NZ,ERROR	; HANDLE ERROR
	CALL	PRTDOT		; PROGRESS
	LD	B,L		; MOVE BOOT UNIT ID TO B
;
	LD	C,$41		; UNA FUNC: SET LBA
	LD	DE,0		; HI WORD ALWAYS ZERO
	LD	HL,3		; IMAGE STARTS AT FOURTH SECTOR
	CALL	$FFFD		; SET LBA
	JR	NZ,ERROR	; HANDLE ERROR
	CALL	PRTDOT		; PROGRESS
;
	LD	C,$42		; UNA FUNC: READ SECTORS
	LD	DE,$D000	; STARTING ADDRESS FOR IMAGE
	LD	L,22		; READ 22 SECTORS
	CALL	$FFFD		; DO READ
	JR	NZ,ERROR	; HANDLE ERROR
	CALL	PRTDOT		; PROGRESS
;
	LD	DE,STR_DONE	; DONE MESSAGE
	CALL	PRTSTR		; PRINT IT
;
	LD	D,B		; PASS BOOT UNIT TO OS
	LD	E,0		; ASSUME LU IS ZERO
	JP	SYS_ENT		; GO TO SYSTEM
;
PRTCHR:
	PUSH	BC
	PUSH	DE
	LD	BC,$0012	; UNIT 0, WRITE CHAR
	LD	E,A		; CHAR TO PRINT
	CALL	$FFFD		; PRINT
	POP	DE
	POP	BC
	RET
;
PRTSTR:
	PUSH	BC
	PUSH	HL
	LD	BC,$0015	; UNIT 0, WRITE CHARS UNTIL TERMINATOR
	LD	L,0		; TERMINATOR IS NULL
	CALL	$FFFD		; PRINT
	POP	HL
	POP	BC
	RET
;
PRTDOT:
	LD	A,'.'		; DOT CHARACTER
	JR	PRTCHR		; PRINT AND RETURN
;
; PRINT THE HEX BYTE VALUE IN A
;
PRTHEXBYTE:
	PUSH	AF
	PUSH	DE
	CALL	HEXASCII
	LD	A,D
	CALL	PRTCHR
	LD	A,E
	CALL	PRTCHR
	POP	DE
	POP	AF
	RET
;
; CONVERT BINARY VALUE IN A TO ASCII HEX CHARACTERS IN DE
;
HEXASCII:
	LD	D,A
	CALL	HEXCONV
	LD	E,A
	LD	A,D
	RLCA
	RLCA
	RLCA
	RLCA
	CALL	HEXCONV
	LD	D,A
	RET
;
; CONVERT LOW NIBBLE OF A TO ASCII HEX
;
HEXCONV:
	AND	$0F	     ;LOW NIBBLE ONLY
	ADD	A,$90
	DAA	
	ADC	A,$40
	DAA	
	RET	
;
ERROR:
	LD	DE,STR_ERR		; POINT TO ERROR STRING
	CALL	PRTSTR			; PRINT IT
	HALT				; HALT
;
; DATA
;
STR_LOAD	.DB	"\r\nLoading",0
STR_DONE	.DB	"\r\n",0
STR_ERR		.DB	" Read Error!",0
;
	.ORG	$ - $8000		; BACK TO ABSOLUTE ADDRESS
;
	.FILL	PT_LOC - $,0		; FILL TO START OF PARTITION TABLE
;
; STANDARD IBM-PC PARTITION TABLE.  ALTHOUGH A
; PARTITION TABLE IS NOT RELEVANT FOR A FLOPPY DISK, IT DOES NO HARM.
; THE CONTENTS OF THE PARTITION TABLE CAN BE MANAGED BY FDISK80.
;
; BELOW WE ALLOW FOR 32 SLICES OF ROMWBW CP/M FILESYSTEMS
; FOLLOWED BY A FAT16 PARTITION.  THE SLICES FOLLOW THE ORIGINAL
; HD512 ROMWBW FORMAT.  IF THE DISK IS USING HD1K, A SEPARATE
; PARTITION TABLE WILL BE IN PLACE AND RENDER THIS PARTITION TABLE
; IRRELEVANT.
;
; THE CYL/SEC FIELDS ENCODE CYLINDER AND SECTOR AS:
;	CCCCCCCC:CCSSSSSS
;	76543210:98543210
;
PART0:
	.DB	0			; ACTIVE IF $80
	.DB	0			; CHS START ADDRESS (HEAD)
	.DW	0			; CHS START ADDRESS (CYL/SEC)
	.DB	0			; PART TYPE ID
	.DB	0			; CHS LAST ADDRESS (HEAD)
	.DW	0			; CHS LAST ADDRESS (CYL/SEC)
	.DW	0,0			; LBA FIRST (DWORD)
	.DW	0,0			; LBA COUNT (DWORD)
PART1:
	.DB	0			; ACTIVE IF $80
	.DB	0			; CHS START ADDRESS (HEAD)
	.DW	%1111111111000001	; CHS START ADDRESS (CYL/SEC)
	.DB	6			; PART TYPE ID
	.DB	15			; CHS LAST ADDRESS (HEAD)
	.DW	%1111111111010000	; CHS LAST ADDRESS (CYL/SEC)
	.DW	$4000,$0010		; LBA FIRST (DWORD)
	.DW	$0000,$000C		; LBA COUNT (DWORD)
PART2:
	.DB	0			; ACTIVE IF $80
	.DB	0			; CHS START ADDRESS (HEAD)
	.DW	0			; CHS START ADDRESS (CYL/SEC)
	.DB	0			; PART TYPE ID
	.DB	0			; CHS LAST ADDRESS (HEAD)
	.DW	0			; CHS LAST ADDRESS (CYL/SEC)
	.DW	0,0			; LBA FIRST (DWORD)
	.DW	0,0			; LBA COUNT (DWORD)
PART3:
	.DB	0			; ACTIVE IF $80
	.DB	0			; CHS START ADDRESS (HEAD)
	.DW	0			; CHS START ADDRESS (CYL/SEC)
	.DB	0			; PART TYPE ID
	.DB	0			; CHS LAST ADDRESS (HEAD)
	.DW	0			; CHS LAST ADDRESS (CYL/SEC)
	.DW	0,0			; LBA FIRST (DWORD)
	.DW	0,0			; LBA COUNT (DWORD)
;
; THE END OF THE FIRST SECTOR MUST CONTAIN THE TWO BYTE BOOT SIGNATURE.
;
BOOTSIG	.DB	$55,$AA			; STANDARD BOOT SIGNATURE
;
;-------------------------------------------------------------------------------
; SECTOR 2
;
;   THIS SECTOR HAS NOT BEEN DEFINED AND IS RESERVED.
;
;----------------------------------------------------------------------------
;
	.FILL	SEC_SIZE,0			; JUST FILL SECTOR WITH ZEROES
;
;-------------------------------------------------------------------------------
; SECTOR 3
;
;   OS AND DISK METADATA
;
;----------------------------------------------------------------------------
;
	.FILL	(BLK_SIZE * 3),0	; FIRST 384 BYTES ARE NOT YET DEFINED
;
; THE FOLLOWING TWO BYTES ARE AN ADDITIONAL SIGNATURE THAT IS VERIFIED BY
; SOME HARDWARE BIOSES.
;
PR_SIG		.DB	$5A,$A5		; SIGNATURE GOES HERE
;
		.FILL	(META_LOC - $),0
;
; METADATA
;
PR_WP		.DB	0		; (1) WRITE PROTECT BOOLEAN
PR_UPDSEQ	.DW	0		; (2) PREFIX UPDATE SEQUENCE NUMBER (DEPRECATED?)
PR_VER		.DB	RMJ,RMN,RUP,RTP	; (4) OS BUILD VERSION
PR_LABEL	.DB	"Unlabeled$$$$$$$","$"	; (17) DISK LABEL (EXACTLY 16 BYTES!!!)
		.DW	0		; (2) DEPRECATED
PR_LDLOC	.DW	SYS_LOC		; (2) ADDRESS TO START LOADING SYSTEM
PR_LDEND	.DW	SYS_END		; (2) ADDRESS TO STOP LOADING SYSTEM
PR_ENTRY	.DW	SYS_ENT		; (2) ADDRESS TO ENTER SYSTEM (OS)
;
#IF (META_SIZE != ($ - META_LOC))
	.ECHO "META_SIZE VALUE IS WRONG!!!\r\n"
	!!!
#ENDIF
;
#IF ($ != PREFIX_SIZE)
	.ECHO "LOADER PREFIX IS WRONG SIZE!!!\r\n"
	!!!
#ENDIF
;
	.END
