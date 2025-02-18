;	Z80
;***********************************
;*	Z80 TEST PROTOTYPE
;*	LOAD MONITOR FROM ROM INTO RAM AND EXECUTE PROGRAM
;*	ANDREW LYNCH
;*	LYNCHAJ@YAHOO COM
;*	15 FEB 2007
;***********************************


;********************* CONSTANTS ****************************************

RAMTOP:		 .EQU	0FFFFh	; HIGHEST ADDRESSABLE MEMORY LOCATION
MONSTART:	 .EQU	08000h	; START OF 6116 SRAM 2KB X 8 RAM F800H-FFFFH
RAMBOTTOM:	 .EQU	08000h	; BEGINNING OF UPPER 32K RAM PAGE
END:		 .EQU	0FFh	; MARK END OF TEXT
CR:		 .EQU	0DH	; ASCII CARRIAGE RETURN CHARACTER
LF:		 .EQU	0AH	; ASCII LINE FEED CHARACTER
ESC:		 .EQU	1BH	; ASCII ESCAPE CHARACTER

ROMSTART_MON:	 .EQU	00200h	; WHERE THE DBGMON IS STORED IN ROM
RAMTARG_MON:	 .EQU	08000h	; WHERE THE DBGMON STARTS IN RAM (ENTRY POINT)
MOVSIZ_MON:	 .EQU	01000h	; DBGMON IS 4096 BYTES IN LENGTH

MON_ENTRY:	 .EQU	08000h	; DBGMON ENTRY POINT (MAY CHANGE)



;*******************************************************************
;*	START AFTER RESET
;*	FUNCTION	: READY SYSTEM, LOAD MONITOR INTO RAM AND START
;*******************************************************************

	.ORG	00100h

;	DI			; DISABLE INTERRUPT
	LD	SP,RAMTOP	; SET STACK POINTER TO TOP OF RAM
;	IM	1		; SET INTERRUPT MODE 1

	LD	HL,ROMSTART_MON	; WHERE IN ROM DBGMON IS STORED (FIRST BYTE)
	LD	DE,RAMTARG_MON	; WHERE IN RAM TO MOVE MONITOR TO (FIRST BYTE)
	LD	BC,MOVSIZ_MON	; NUMBER OF BYTES TO MOVE FROM ROM TO RAM
	LDIR			; PERFORM BLOCK COPY OF DBGMON TO UPPER RAM PAGE

;	EI			; ENABLE INTERRUPTS (ACCESS TO MONITOR WHILE CP/M RUNNING)

	JP	MON_ENTRY	; JUMP TO START OF MONITOR

	.FILL	001FFh-$

	.ORG	001FFh
FLAG:
	.DB	0FFh

	.END
