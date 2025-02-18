	ifndef  p80c51fainc     ; avoid multiple inclusion
		equ     p80c51fainc, 1
		save
		listing off   ; no listing over this file

;****************************************************************************
;*                                                                          *
;*   File p80c51fa.inc                                                      *
;*   								            *
;*   Holds SFR and Bit Definitions for P80C51FA processor                   *
;* 									    *
;****************************************************************************

	if      MOMPASS=1
		message "P80C51FA SFR Definitions (C) 2024 Vesa-Pekka Palmu"
		message "including \{MOMCPU} SFRs"
	endif

;----------------------------------------------------------------------------
; first of all, the things that exist (almost) everywhere:

P0		SFRB    80h             ; I/O Ports
P1		SFRB	90h
P2              SFRB    0a0h
P3		SFRB	0b0h
RD		BIT	P3.7		; Port 3: Write Line
WR		BIT	P3.6		;         Read Line
T1              BIT     P3.5            ;         Test Line 1
T0		BIT	P3.4		;         Test Line 0
INT1		BIT	P3.3		;         External Interrupt 1
INT0		BIT	P3.2		;	  External Interrupt 0
TXD		BIT	P3.1		;	  Serial Output
RXD		BIT	P3.0		;	  Serial Input

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

SP		SFR	81h		; Stack Pointer
DPL		SFR	82h		; Data Pointer Bits 0..7
DPH		SFR	83h		;      "       Bits 8..15

PSW		SFRB	0d0h		; Processor Status Word
CY		BIT	PSW.7
AC		BIT	PSW.6
F0		BIT	PSW.5
RS1		BIT	PSW.4
RS0		BIT	PSW.3
OV		BIT	PSW.2
P		BIT	PSW.0
ACC		SFRB	0e0h		; Accumulator
B		SFRB	0f0h		; Auxiliary Accumulator for MUL/DIV

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Aux registers

AUXR		SFR	08eh		; Auxiliary
AUXR1		SFR	0a2h		; Auxiliary 1, data pointer selection

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Serial

SCON		SFRB	98h		; Serial Interface: Control Register
SM0		BIT     SCON.7          ; Operating Modes
SM1		BIT     SCON.6
SM2		BIT     SCON.5
REN		BIT	SCON.4		; Receiver Enable
TB8		BIT	SCON.3		; 9th Bit to be sent
RB8		BIT	SCON.2		; 9th received bit
TI		BIT	SCON.1		; Transmit Interrupt Flag
RI		BIT	SCON.0		; Receive Interrupt Flag
SBUF		SFR	99h		; Data Register

SADDR		SFR	0a9h            ; Serial Port Slave Address
SADEN		SFR	0b9h            ; Enable Bits in SADDR

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

PCON		SFR	87h		;  Power Management

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Timer registers

TCON		SFRB	88h		; Timer 0/1 Control Register
TF1		BIT	TCON.7		; Timer 1 Overflow
TR1		BIT	TCON.6		; Timer 1 Start
TF0		BIT	TCON.5		; Timer 0 Overflow
TR0		BIT	TCON.4		; Timer 0 Start
IE1		BIT	TCON.3		; External Interrupt 1 Flag
IT1		BIT	TCON.2		; External Interrupt 1 Edge Select
IE0		BIT	TCON.1		; External Interrupt 0 Flag
IT0		BIT	TCON.0		; External Interrupt 0 Edge Select
TMOD		SFR 	89h		; Timer 0/1 Operating Modes Register
TL0		SFR	8ah		; Timer 0 Data
TL1		SFR	8bh
TH0		SFR	8ch		; Timer 1 Data
TH1		SFR	8dh

T2CON	 	SFRB	0c8h		; Timer 2 Control Register
T2MOD		SFR	0c9h		; Timer 2 mode
TL2	 	SFR	0cch		; Timer 2 Data
TH2	 	SFR	0cdh

RCAP2L	 	SFR	0cah		; Capture Register
RCAP2H	 	SFR	0cbh
TF2		BIT	T2CON.7		; Timer 2 Overflow
EXF2		BIT	T2CON.6		; Reload Occured
RCLK		BIT	T2CON.5		; Timer 2 Delivers RxD-Takt
TCLK		BIT	T2CON.4		; Timer 2 Delivers TxD-Takt
EXEN2		BIT	T2CON.3		; Timer 2 External Enable
TR2		BIT	T2CON.2		; Timer 2 Start
CT2		BIT	T2CON.1		; Timer 2 as Counter
CPRL2		BIT	T2CON.0		; Enable Capture

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; PCA registers

CCAP0H		SFR	0fah		; Module 0 capture high
CCAP0L		SFR	0eah		; Module 0 capture low
CCAPM0		SFR	0dah		; Module 0 mode

CCAP1H		SFR	0fbh		; Module 1 capture high
CCAP1L		SFR	0ebh		; Module 1 capture low
CCAPM1		SFR	0dbh		; Module 1 mode

CCAP2H		SFR	0fch		; Module 2 capture high
CCAP2L		SFR	0ech		; Module 2 capture low
CCAPM2		SFR	0dch		; Module 2 mode

CCAP3H		SFR	0fdh		; Module 3 capture high
CCAP3L		SFR	0edh		; Module 3 capture low
CCAPM3		SFR	0ddh		; Module 3 mode

CCAP4H		SFR	0feh		; Module 4 capture high
CCAP4L		SFR	0eeh		; Module 4 capture low
CCAPM4		SFR	0deh		; Module 4 mode

CCON		SFRB	0d8h		; PCA Counter control
CF		BIT	CCON.7
CR		BIT	CCON.6
CCF4		BIT	CCON.4
CCF3		BIT	CCON.3
CCF2		BIT	CCON.2
CCF1		BIT	CCON.1
CCF0		BIT	CCON.0

CH		SFR	0f9h		; PCA counter high
CL		SFR	0e9h		; PCA counter low

CMOD		SFR	0d9h		; PCA counter mode

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Interrupt Control Register

IE		SFRB	0a8h		; Interrupt Enable
EA		BIT	IE.7		; Global Interrupt Enable
EC		BIT	IE.6
ET2		BIT	IE.5		; Timer 2 interrupt enable
ES		BIT	IE.4		; Serial Interface Interrupts Enable
ET1		BIT	IE.3		; Timer 1 Interrupt Enable
EX1		BIT	IE.2		; External Interrupt 1 Enable
ET0		BIT	IE.1		; Timer 0 Interrupt Enable
EX0		BIT	IE.0		; External Interrupt 0 Enable

IP		SFRB	0b8h		; Interrupt Priorities
PPC		BIT	IP.6
PT2		BIT	IP.5		; Timer 2 Interrupt Priority
PS		BIT	IP.4		; Serial Interrupt Priority
PT1		BIT	IP.3		; Timer 1 Interrupt Priority
PX1		BIT	IP.2		; External Interrupt 1 Priority
PT0		BIT	IP.1		; Timer 0 Interrupt Priority
PX0		BIT	IP.0		; External Interrupt 0 Priority

IPH		SFR	0b7h		; Interrupt priority high

;---------------------------------------------------------------------------
; Since the 8051 has no instructions to push the registers, this has to be done
; via direct addressing, which requires knowledge of the currently active bank.
; The macro USING is provided for doing this.  It holds the addresses of the
; currently active registers in symbols AR0..AR7.  USING expects the bank
; number as argument.

Bank0		equ	0		; For Completeness...
Bank1		equ	1
Bank2		equ	2
Bank3		equ	3

using		macro	bank
		if	(bank<0)||(bank>3)          ; only bank 0..3 allowed
                 error  "Wrong bank number: \{BANK}"
                endif

                ifdef	RegUsage	; Book-Keeping about Used Banks
RegUsage	 set	RegUsage|(2^bank)
		elseif
RegUsage	 set	2^bank
		endif

ar0		set	bank*8		; Set Symbols
ar1		set	ar0+1
ar2		set	ar0+2
ar3		set	ar0+3
ar4		set	ar0+4
ar5		set	ar0+5
ar6		set	ar0+6
ar7		set	ar0+7
		endm

                restore                 ; re-allow listing

                endif			; stddef51inc
