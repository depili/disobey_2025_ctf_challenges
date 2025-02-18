	CPU	8051
	INCLUDE ../p80c51fa.inc
	INCLUDE ../paulmon2/paulmon_v3.0.inc

	ORG	0000h

	MOV	DPTR, #flag
	MOV	R0, #0
	clr 	p1.7
	clr 	p3.2
	clr 	p3.3
	clr 	p3.4
	clr 	p3.5
.larson:
	setb	p1.7
	clr	p3.2
	call	get_flag
	setb	p3.2
	clr	p1.7
	call	get_flag
	setb	p3.3
	clr	p3.2
	call	get_flag
	setb	p3.4
	clr	p3.3
	call	get_flag
	setb	p3.5
	clr	p3.4
	call	get_flag
	setb	p3.4
	clr	p3.5
	call	get_flag
	setb	p3.3
	clr	p3.4
	call	get_flag
	setb	p3.2
	clr	p3.3
	call	get_flag
	jmp	.larson

get_flag:
	MOV	A, R0
	MOVC	A, @A+DPTR
	JZ	.reset
	INC	R0
	RET
.reset:
	MOV	R0, #0
	RET


	ORG	5555h

flag:
	DB	"DISOBEY{can you get to 1Mhz?}",0