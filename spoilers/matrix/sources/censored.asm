	CPU	8051
	INCLUDE	p80c51fa.inc

	EQU	lcd_cmd, 6020h
	EQU	lcd_data, 6021h



dbounce	MACRO	pin
	JB	pin, ++
-	CJNE	R6, #0FFh, +
	CJNE	R6, #0FFh, +
	DEC	R6
+	INC	R6
	JNB	pin, -
	CJNE	R6, #0FFh, +
	ENDM

pkey	MACRO	key
;	MOV	A, #key
;	CALL	key_out
	ENDM

stkey	MACRO	key
	MOV	A, R7
	ADD	A, #(key+1)
	MOV	R7, A
	ENDM


C1	BIT	P1.0
C2	BIT	P1.1
C3	BIT	P1.2
C4	BIT	P1.3

V1	BIT	P1.4
V2	BIT	P1.5
V3	BIT	P1.6
V4	BIT	P1.7


	ORG	0000h

	; Gets a "single" keypress
	; Destroys A, R6, R7, C
	; Returns the keycode in R7

	EQU	code_len, 6
	EQU	code_loc, 40h


main:
	call	lcd_init
	MOV	dptr, #banner
	call	lcd_print
	call	lcd_line_2
	MOV	dptr, #prompt
	call	lcd_print

	MOV	R3, #0		; Chars entered
	MOV	R1, #code_loc	; Store ptr

-	MOV	@R1, #0
	INC	R1
	CJNE	R1, #(code_loc + code_len), -
	MOV	R1, #code_loc

.new_key:
.print_entry:
	call	lcd_line_2
	mov	dptr, #prompt
	call	lcd_print

	MOV	A, R3
-	JZ	.clear
	PUSH	ACC
	MOV	A, #"*"
	CALL	lcd_putc
	POP	ACC
	DEC	A
	JMP	-
.clear:
	MOV	A, #" "
	CALL	lcd_putc
	CALL	lcd_putc
	CALL	lcd_putc
	CALL	lcd_putc
	CALL	lcd_putc
	CALL	lcd_putc
.loop:
	MOV	A, #"\n"
	CALL	cout

	CALL	get_key
	CJNE	R7, #37, .not_c
	; C
	CJNE	R1, #code_loc, +
	JMP	.loop
+	DEC	R1
	DEC	R3
	JMP	.new_key
.not_c:
	CJNE	R7, #36, .not_e
	; E
	JMP	main
.not_e:
	CJNE	R7, #35, .not_minus
	; -
	JMP	.loop
.not_minus:
	CJNE	R7, #34, .not_s
	; S
	JMP	.loop
.not_s:
	CJNE	R7, #33, .not_left
	; <-
	JMP	.loop
.not_left:
	CJNE	R7, #32, .not_right
	; ->
	JMP	.loop
.not_right:
	MOV	A, R7
	MOV	@R1, A
	INC	R1
	INC	R3
	CJNE	R3, #code_len, .new_key
	jmp	check_code
	RET



check_code:
	MOV	dptr, #matrix
	MOV	R1, #code_len
-	MOV	R0, #code_loc
	CLR	A
	MOV	R2, #0
	MOV	R3, #0
-	CLR	A
	MOVC	A, @A+DPTR
	MOV	B, @R0
	MUL	AB
	ADD	A, R2
	MOV	R2, A
	INC	R0
	INC	DPTR
	CJNE	R0, #(code_loc+code_len), -

	MOV	50h, R2
;	MOV	A, R2
;	call	pm.phex

	CLR	A
	MOVC	A, @A+DPTR


	CJNE	A, 50h, .wrong		; Wrong code
;	MOV	A, #"."
;	CALL	cout
	DEC	R1
	INC	DPTR
	MOV	A, R1
	JZ	.correct
	JMP	--
.wrong:
	CALL	lcd_line_2
	MOV	dptr, #wrong
	CALL	lcd_print
	CALL	huge_delay
	JMP	main
.correct:
	CALL	lcd_line_2
	MOV	dptr, #flag
	CALL	lcd_print
	CALL	huge_delay
	JMP	main

huge_delay:
	MOV	A, #0FFh
-	CALL	delay_long
	CALL	delay_long
	DEC	A
	JNZ	-
	RET

matrix:
	DB	1, 0, 8, 0, 0, 2, 54
	DB	0, 9, 5, 5, 0, 5, 101
	DB	4, 11, 0, 4, 0, 4, 76
	DB	7, 7, 7, 7, 7, 7, 224
	DB	2, 1, 11, 2, 0, 13, 152
	DB	7, 5, 5, 11, 2, 4, 114

get_key:
	SETB	C1
	SETB	C2
	SETB	C3
	SETB	C4
.loop:
	CLR	A
	MOV	R6, #0		; Debounce
	MOV	R7, #0FFh	; Keycode
.row4:
	CALL	kb_setup
	CLR	V4

	dbounce	C1		; 7
	pkey	"C"
	stkey	7
+:
	dbounce	C2		; 8
	pkey	"D"
	stkey	8
+:
	dbounce	C3		; 9
	pkey	"E"
	stkey	9
+:
	dbounce	C4		; ->
	pkey	"F"
	stkey	32
+:
	CALL	kb_setup
	CLR	V3

	dbounce	C1		; 4
	pkey	"9"
	stkey	4
+:
	dbounce	C2		; 5
	pkey	"0"
	stkey	5
+:
	dbounce	C3		; 6
	pkey	"A"
	stkey	6
+:
	dbounce	C4		; <-
	pkey	"B"
	stkey	33
+:
	CALL	kb_setup
	CLR	V2

	dbounce	C1		; 1
	pkey	"5"
	stkey	1
+:
	dbounce	C2		; 2
	pkey	"6"
	stkey	2
+:
	dbounce	C3		; 3
	pkey	"7"
	stkey	3
+:
	dbounce	C4		; S
	pkey	"8"
	stkey	34
+:

	CALL	kb_setup
	CLR	V1

	dbounce	C1		; 0
	pkey	"1"
	stkey	0
+:
	dbounce	C2		; -
	pkey	"2"
	stkey	35
+:
	dbounce	C3		; E
	pkey	"3"
	stkey	36
+:
	dbounce	C4		; C
	pkey	"4"
	stkey	37
+:
	CJNE	R7, #0FFH, .end
	jmp	.loop
.end:
;	MOV	A, R7
;	call	pm.phex
	ret

pstr:
	push	acc
.loop:
	clr	a
	movc	a, @a+dptr
	inc	dptr
	jz	.end
	acall	cout
	sjmp	.loop
.end:
	pop	acc
	ret


key_out:
	push	acc
	mov	dptr, #key

-	clr	a
	movc	a, @a+dptr
	inc	dptr
	jz	.break
	call	cout
	jmp	-
.break:
	pop	acc
cout:
	jnb	ti, cout
	clr	ti		; clr ti before the mov to sbuf!
	mov	sbuf, a
	ret

key:
	DB	"\nKey: ",0


lcd_init:
	MOV	dptr, #lcd_cmd
	MOV	A, #38h				; 8 bit interface, 2 rows, 5x8 font
	MOVX	@dptr, A
	CALL	delay_long
	MOV	A, #0Ch				; Display on, cursor off, blink off
	MOVX	@dptr, A
	CALL	delay_long
	MOV	A, #02h				; Home display
	MOVX	@dptr, A
	CALL	delay_long
	MOV	A, #01h				; Clear display
	MOVX	@dptr, A
	CALL	delay_long
	RET

lcd_home:
	MOV	dptr, #lcd_cmd
	MOV	A, #02h				; Home display
	MOVX	@dptr, A
	CALL	delay_long
	RET

lcd_line_2:
	MOV	dptr, #lcd_cmd
	MOV	A, #0C0h				; Set dram address 0x40
	MOVX	@dptr, A
	CALL	delay_long
	RET

lcd_putc:
	INC	AUXR1
	MOV	dptr, #lcd_data
	MOVX	@dptr, A
	call	delay
	INC	AUXR1
	RET

lcd_print:
	INC	AUXR1
	MOV	dptr, #lcd_data
	INC	AUXR1
.loop:
	CLR	A
	MOVC	A, @a+dptr
	INC	AUXR1
	JZ	.end
	MOVX	@dptr, A
	INC	AUXR1
	INC	dptr
	CALL	delay
	SJMP	.loop
.end
	RET



delay:
;	MOV 	r5, #0ffh
-	MOV 	r4, #018h
	DJNZ 	r4, $
;	DJNZ 	r5, -
	RET

delay_long:
	MOV 	r5, #00fh
-	MOV 	r4, #0ffh
	DJNZ 	r4, $
	DJNZ 	r5, -
	RET


kb_setup:

	SETB	V1
	SETB	V2
	SETB	V3
	SETB	V4
	ret

banner:
	DB	"Kouvosto Telecom", 0
prompt:
	DB	"Code: ", 0
flag:
	DB	"****  FLAG  ****", 0
wrong:
	DB	"** WRONG CODE **", 0
