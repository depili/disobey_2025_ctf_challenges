	CPU	8051
	INCLUDE	p80c51fa.inc
	INCLUDE paulmon_v3.0.inc

	EQU	base, 0000h

	EQU	lcd_cmd, 6020h
	EQU	lcd_data, 6021h
	EQU	kb_data, 60FCh
	EQU	leds_1, 60E0h
	EQU	leds_spacing, 4
	EQU	leds_registers, 5
	EQU	numbers, 10

	ORG 	base

	SEGMENT	DATA
	ORG	40h
numbers_store:
	DB	numbers dup(?)

	DB	? 				; Junk
bitmap_store:
	DB	5 dup(?)
	DB	?				; Junk
leds_buffer:
	DB	5 dup(?)
leds_buffer2:
	DB	5 dup(?)
galois_state:
	DB	4 dup(?)

	SEGMENT	CODE

	jmp	gen_presses

	ORG	base + 500h
	db	0A5H,0E5H,0E0H,0A5H		; signature
	db	254,'A',0,0			; id (254=user installed command)
	db	0,0,0,0				; prompt code vector
	db	0,0,0,0				; reserved
	db	0,0,0,0				; reserved
	db	0,0,0,0				; reserved
	db	0,0,0,0				; user defined
	db	255,255,255,255			; length and checksum (255=unused)
	db	"Lights challenge",0
	ORG	base + 540h


gen_presses:
	mov	sp, #stack
	call	get_key

	call	clear_leds
	call	lcd_init
	mov	dptr, #banner
	call	lcd_print
	call	lcd_line_2
	call	lcd_print


	; Fill numbers with 0xff
	mov	a, #0ffh
	mov	r0, #numbers_store
	mov	r5, #numbers
-	mov	@r0, a
	inc	r0
	djnz	r5, -

	mov	r1, #numbers_store
	mov	r5, #numbers			; Unique numbers
.number	mov	r4, #0
	mov	r6, #5				; Bits per
-	call	galois				; new bit in C
	mov	a, r4
	rlc	A
	mov	r4, a
	djnz	r6, -
	cjne	a, #20, +
	jmp	.number
+	jnc	.number

	; Check for duplicates

	mov	r0,	#numbers_store
	mov	r6,	#numbers

-	mov	a, r4
	subb	a, @r0
	jz	.duplicate

	inc	r0
	djnz	r6, -

	; No duplicates found
	jmp	.store

.duplicate:
	jmp	.number

.store:
	mov	@r1, a
	inc	r1
	djnz	r5, .number				; R5 = numbers to generate

	; We have the unique buttons...

	mov	a, #0ffh
	mov	r0, #bitmap_store
	mov	r2, #5
-	mov	@r0, a
	inc	r0
	djnz	r2, -

	mov	r0, #numbers_store
	mov	r5, #numbers

-	mov	a, @r0
	mov	r7, #1
	call	bitmap_xor
	inc	r0
	djnz	r5, -



	call	.set_leds
	call	get_key
	call	lcd_home
	mov	dptr, #response
	call	lcd_print
	call	lcd_line_2
	call	lcd_print
	call	lcd_line_2

.solve:
	mov	r0, #leds_buffer2
	mov	r1, #5
-	mov	@r0, #0FFh
	inc	r0
	djnz	r1, -

	mov	a, #0ffh
	mov	dptr, #leds_1
	movx	@dptr, a
	mov	dptr, #(leds_1 + leds_spacing)
	movx	@dptr, a
	mov	dptr, #(leds_1 + (leds_spacing * 2))
	movx	@dptr, a
	mov	dptr, #(leds_1 + (leds_spacing * 3))
	movx	@dptr, a
	mov	dptr, #(leds_1 + (leds_spacing * 4))
	movx	@dptr, a

	; Get the solution
	mov	r3, #numbers

-	call	get_key		; A, R7, DPTR
	call	key_to_led	; R1, R5, R6, R7, DPTR
	mov	r7, #1
	call	bitmap_xor	; A, R1, R2, R4

;	call	.set_leds


	mov	a, #"*"
	call	lcd_putc	; R4, DPTR
	djnz	r3, -


	; Check solution
	mov	r0, #bitmap_store
	mov	r1, #5
-	cjne	@r0, #0FFH, .fail
	inc	r0
	djnz	r1, -
	; WIN

	call	lcd_home
	mov	dptr, #flag
	call	lcd_print
	call	lcd_line_2
	call	lcd_print

	jmp	gen_presses
.fail:
	call	lcd_home
	mov	dptr, #wrong
	call	lcd_print
	call	lcd_line_2
	call	lcd_print

	jmp	gen_presses

; Destroys R0, R1, DPTR, ACC
.set_leds:
	mov	r0, #bitmap_store
	mov	r1, #5
	mov	dptr, #leds_1
-	mov	a, @r0
	movx	@dptr, a
	inc	r0
	inc	dptr
	inc	dptr
	inc	dptr
	inc	dptr
	djnz	r1, -
	ret


huge_delay:
	mov	r0, #30
.loop1	mov	r1, #0
.loop2	mov	r2, #0
.loop3	djnz	r2, .loop3
	djnz	r1, .loop2
	djnz	r0, .loop1
	ret

	; A - input
	; R7 - led, 1 or 2
	; Destroys A, R1, R2, R4
bitmap_xor:
	mov	r2, a			; Save lower 2 bits
	clr	c
	rrc	a
	clr	c
	rrc	a
	add	a, #bitmap_store	; Store location
	mov	r1, a
	mov	a, r2
	anl	a, #3			; Lower 2 bits
	mov	r2, a
	mov	a, R7

-	cjne	r2, #00, +
	mov	R4, A
	xrl	A, @r1
	mov	@r1, A

	inc	R1
	mov	A, R4
	xrl	A, @R1
	mov	@R1, A

	dec	R1
	dec	R1
	mov	A, R4
	xrl	A, @R1
	mov	@R1, A

	inc	R1

	mov	A, R4

	clr	C
	rrc	A
	clr	C
	rrc	A
	xrl	A, @r1
	mov	@r1, a

	mov	A, R4
	clr	C
	rlc	A
	clr	C
	rlc	A
	xrl	A, @r1
	mov	@r1, a
	ret
+	rl	a
	rl	a
	dec	r2
	jmp	-



; Destroys A, R7
get_key:
	MOV	DPTR, #kb_data
	MOVX	A, @DPTR
	MOV	R7, A
.loop:
	call	galois
	MOVX	A, @DPTR
	PUSH	ACC
	XRL	A, R7
	JNZ	.changed
	POP	ACC
	JMP	.loop
.changed:
	POP	ACC
	JB	ACC.7, get_key		; Key down event
	RET

; Destroys A
galois:
	mov	A, R7
	push	acc
	mov	A, R0
	push	acc
	mov	A, galois_state
	orl	A, galois_state+1
	orl	A, galois_state+2
	orl	A, galois_state+3
	jnz	.process
	; Initialize the LFSR, as 0 is a lock-up state
	mov	galois_state, #42
.process:
	clr	C
	mov	R0, #galois_state
	mov	R7, #4
.loop:
	mov	A, @R0
	rrc	A
	mov 	@R0, A
	inc	R0
	djnz	R7, .loop
	jc	.carry
	jmp	.end
.carry:
	mov	A, galois_state
	xrl	A, #0A3h
	mov	galois_state, A
	setb	C
.end:
	pop	acc
	mov	R0, A
	pop	acc
	mov	R7, A
	ret

clear_leds:
	PUSH	DPL
	PUSH	DPH
	PUSH	ACC
	MOV	DPTR, #leds_1
	MOV	R7, #leds_registers
	MOV	R0, #leds_buffer
.loop:
	MOV	A, #0FFh
	MOVX	@DPTR, A
	MOV	@R0, A
	MOV	A, DPL
	ADD	A, #leds_spacing
	MOV	DPL, A
	INC	R0
	DJNZ	R7, .loop
	POP	ACC
	POP	DPH
	POP	DPL
	CLR	TR0
	RET

; Destroys R1, R5, R6, R7, DPTR
key_to_led:
	PUSH	ACC
	MOV	R7, A		; R7 = keycode
	ANL	A, #03h
	MOV	R6, A		; R6 = The in-byte offset
	MOV	A, R7
	ANL	A, #07Ch	; The register offset
	MOV	R5, A		; R5 = register offset

	MOV	DPTR, #leds_1
	MOV	A, DPL
	ADD	A, R5
	MOV	DPL, A		; DPTR = register address
	MOV	A, R5
	RR	A
	RR	A
	ADD	A, #leds_buffer2
	MOV	R1, A
	MOV	A, R7
	MOV	A, #02h
.bit_loop:
	RL	A
	RL	A
	DEC	R6
	CJNE	R6, #0, .bit_loop
	XRL	A, @R1
	MOVX	@DPTR, A
	MOV	@R1, A

	POP	ACC
	RET

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
	INC	AUXR1
	MOV	dptr, #lcd_cmd
	MOV	A, #0C0h			; Set dram address 0x40
	MOVX	@dptr, A
	CALL	delay_long
	INC	AUXR1
	RET

; Destroys dptr, R4
lcd_putc:
	INC	AUXR1
	MOV	dptr, #lcd_data
	MOVX	@dptr, A
	call	delay				; R4
	INC	AUXR1
	RET

lcd_print:
	INC	AUXR1
	MOV	dptr, #lcd_data
	INC	AUXR1
.loop:
	CLR	A
	MOVC	A, @a+dptr
	INC	dptr
	JZ	.end
	INC	AUXR1
	MOVX	@dptr, A
	INC	AUXR1
	CALL	delay
	SJMP	.loop
.end
	RET

delay:
;	MOV 	r5, #0ffh
-	MOV 	r4, #028h
	DJNZ 	r4, $
;	DJNZ 	r5, -
	RET

delay_long:
	MOV 	r5, #02fh
-	MOV 	r4, #0ffh
	DJNZ 	r4, $
	DJNZ 	r5, -
	RET

banner:
	DB	"Kouvosto Telecom", 0
banner2:
	DB	"Enter response: ", 0

response:
	DB	"Enter Code:     ", 0
response2:
	DB	"                ", 0

wrong:
	DB	"Wrong code!     ", 0
wrong2:
	DB	"** Try harder **", 0

flag:
	DB	"DISOBEY[triple  ", 0
flag2:
	DB	"check files...] ", 0
