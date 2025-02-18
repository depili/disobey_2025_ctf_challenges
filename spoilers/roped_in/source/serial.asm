		CPU     8051

		INCLUDE p80c51fa.inc


T2_RELOAD       EQU     0FFF3H          ; 38,4kbit/s @ 16 MHz
BUF_LEN         EQU     16              ; Serial receive buffer size
rx_buf          EQU     30H             ; Serial receive buffer location, idata
stack           EQU     40H             ; Stack start location, idata

lcd_cmd         EQU     6020h           ; LCD command register address, extmem
lcd_data        EQU     6021h           ; LCD data register address, extmem


		.EQU	paulmon2, 0

	.equ	pm.phex1,	36h + paulmon2	; Print a single hex digit

	.equ    pm.cout,	38h + paulmon2	; Send Acc to serial port

	.equ    pm.cin, 	3Ah + paulmon2	; Get Acc from serial port

	.equ    pm.phex, 	3Ch + paulmon2	; Print Hex value of Acc

	.equ    pm.phex16, 	3Eh + paulmon2	; Print Hex value of DPTR


		ORG     2000H           ; Program location

		USING	0

; -----------------------------------------------
		MOV     SP,#stack-1                     ; Set the application stack address

		MOV     RCAP2H,#T2_RELOAD >> 8          ; load 16-bit value to timer
		MOV     RCAP2L,#T2_RELOAD & 0FFH
		MOV     T2CON,#34H                      ; TCLK + RCLK + TR2

		MOV     SCON,#50H                       ; mode 1 + REN
		SETB    TI                              ; Set transmitter empty status bit
		CLR     RI                              ; Clear receiver buffer full bit
start:

		ANL     AUXR1, #0FEh                    ; Clear DPS bit in AUXR1, setting DPTR0 as active

		MOV     DPTR, #lcd_cmd                  ; Load lcd command register address
		MOV     A, #00111000b                   ; Hitachi lcd command: display function set: 8bit interface, 2 lines, 5x8 font
		MOVX     @DPTR, A
		CALL    lcd_delay_long                  ; Delay for LCD command processing

		MOV     A, #00001100b                   ; LCD command; display set, set display off, no cursor, no blink
		MOVX    @DPTR, A
		CALL    lcd_delay_long

		MOV     A, #1                           ; LCD command: clear display
		MOVX    @DPTR, A
		CALL    lcd_delay_long

		MOV     A, #2                           ; LCD command: home cursor
		MOVX    @DPTR, A
		CALL    lcd_delay_long

		MOV     DPTR, #lcd_glyph                ; Load LCD custom glyph data pointer
		CALL    lcd_setup_glyph                 ; Setup custom character

		MOV     DPTR, #lcd_string               ; Load LCD welcome message pointer
		CALL    lcd_print                       ; Print the message from code

.receive_loop:                                          ; Loop for reading data from UART and then printing it out on the LCD
		MOV     DPTR, #lcd_cmd
		MOV     A, #11000000b                   ; LCD command, set DDRAM address to 64, start of row 2
		MOVX    @DPTR, A
		CALL    lcd_delay_long

		CALL    receive_string                  ; Receive a string up to 16 characters long from serial
		MOV     R0, #rx_buf                     ; Load a pointer to the received string
		CALL    lcd_print_idata                 ; Print the string on the LCD
		JMP     .receive_loop                   ; Loop again

; Setup a custom character by loading 8 bytes of data pointed by DPTR into CGRAM starting at location 0
; Destroys A, R0, second DPTR
lcd_setup_glyph:
		INC     AUXR1                           ; Switch to the second DPTR
		MOV     DPTR, #lcd_cmd
		MOV     A, #01000000b                   ; LCD command: Set CGRAM address 0
		MOVX    @DPTR, A
		CALL    lcd_delay_long
		MOV     DPTR, #lcd_data                 ; Set the second DPTR to LCD data register
		MOV     R0, #8                          ; Lenght of the custom glyph
		INC     AUXR1                           ; Switch back to the original DPTR, pointing to the glyph data
.loop:
		CLR     A
		MOVC    A, @A+DPTR                      ; Read the glyph byte from code
		INC     DPTR                            ; Increment the DPTR to the next byte
		INC     AUXR1                           ; Switch to the second DPTR pointing to the lcd data register
		MOVX    @DPTR, A                        ; Send the glyph byte to the LCD
		CALL    lcd_delay                       ; Delay for LCD data input
		INC     AUXR1                           ; Switch DPTR to the glyph data pointer
		DJNZ    R0, .loop                       ; Decrement R0, loop again if not zero
		MOV     DPTR, #lcd_cmd
		MOV     A, #2                           ; LCD command: Home cursor, switces writes back to DDRAM
		MOVX    @DPTR, A
		CALL    lcd_delay_long                  ; LCD command delay
		RET

; Print a string from idata pointed by R0 to the LCD
; Destroys DPTR, A
lcd_print_idata:
		MOV     DPTR, #lcd_data                 ; Set DPTR to lcd data register
.lcd_loop:
		MOV     A, @R0                          ; Read a byte from idata via R0
		JZ      .end                            ; If the byte was 0 return
		INC     R0                              ; Increment R0
		MOVX    @dptr, A                        ; Load the byte into LCD data pointer
		CALL    lcd_delay                       ; LCD write delay
		JMP     .lcd_loop                       ; Loop again
.end:
		RET

print_flag:
		MOV	DPTR, #flag
		CJNE	A, #0Dh, +
		LJMP	++
+		LJMP	print_regs
+		CJNE	R7, #2Ah, +
		LJMP	++
+		LJMP	print_regs
+		CJNE	R6, #42h, +
		LJMP	++
+		LJMP	print_regs
+		CALL	send_string_code
		LJMP	start
		POP	ACC
		RET


; Print a string from code memory pointed by DPTR to the LCD
; Destroys A, second DPTR
lcd_print:
		INC     AUXR1                           ; Switch to second DPTR
		MOV     DPTR, #lcd_data                 ; Set it to point to LCD data register
		INC     AUXR1                           ; Switch back to the string DPTR
.lcd_loop:
		CLR     A
		MOVC    A, @a+dptr                      ; Load a byte of the string into A
		JZ      .end                            ; If A is zero return
		INC     DPTR                            ; Increment the string pointer
		INC     AUXR1                           ; Switch to the LCD data pointer
		MOVX    @dptr, A                        ; Send the string byte to the LCD
		CALL    lcd_delay                       ; LCD write delay
		INC     AUXR1                           ; Switch back to string pointer
		JMP     .lcd_loop                       ; Loop again
.end:
		RET

; LCD custom glyph
lcd_glyph:
	DB      011h,00Ah,00Ah,000h,011h
	POP	AR6
	RET

lcd_string:
	DB      "Kouvosto Telecom", 8, 0

; Short LCD write delay
lcd_delay:
	PUSH	AR7
	MOV     r7, #018h
	DJNZ    r7, $
	POP	AR7
	RET

; LCD command delay
lcd_delay_long:
	MOV     r7, #00Fh
-       MOV     r6, #0FFh
	DJNZ    r6, $
	DJNZ    r7, -
	RET


; -----------------------------------------------
; Send zero-terminated string from CODE pointed by DPTR
send_string_code:
		CLR     A
		MOVC    A,@A+DPTR
		JZ      .done
		CALL    send_char

		INC     DPTR
		JMP     send_string_code
.done:
		RET

; -----------------------------------------------
; Send zero-terminated string from IDATA pointed by R0
send_string_idata:
		MOV     A,@R0
		JZ      .done
		CALL    send_char

		INC     R0
		JMP     send_string_idata
.done:
		RET

; -----------------------------------------------
; Wait for previous char to be sent, send char in A
send_char:
		JNB     TI,$
		CLR     TI
		MOV     SBUF,A
		RET


		subb	a, r6
		ret


; -----------------------------------------------
; Wait for string from UART. When enter (CR) pressed,
; return string in rx_buf
receive_string:
		MOV     R0,#rx_buf
.loop:
		CALL    receive_char

		CJNE    A,#'\r', .not_cr            ; out from loop if CR
		JMP     .cr_got

.not_cr:        CJNE    A,#' ',$+3                  ; strip control chars ( < ' ')
		JC      .loop

		MOV     @R0,A                       ; char to buf
		INC     R0

		CALL    send_char                   ; echo
		JMP     .loop
.cr_got:
		MOV     @R0,#0                      ; string end marker

		MOV     DPTR,#crlf_text             ; echo CR as CR+LF
		CALL    send_string_code

		RET

; -----------------------------------------------
; Wait for char from UART, return in A
receive_char:
		JNB     RI,$                        ; wait for received char
		CLR     RI
		MOV     A,SBUF
		RET

hello_text:     DB      '*** UART test ***\r\n',0
received_text:  DB      'Received: ',0
crlf_text:      DB      '\r\n',0
harder:		DB	"Trying harder!", 0
flag: 		DB	"DISOBEY[are you into bondage?]", 0

try_hard:
	mov	dptr, #harder
	call	send_string_code
	jmp	0


print_regs:
	push	acc
	mov	a, #"A"
	call	send_char
	mov	a, #" "
	call	send_char
	pop	acc
	call	pm.phex
	mov	a, #" "
	call	send_char
	mov	a, #"6"
	call	send_char
	mov	a, #" "
	call	send_char
	MOV	A, r6
	call	pm.phex
	mov	a, #" "
	call	send_char
	mov	a, #"7"
	call	send_char
	mov	a, #" "
	call	send_char
	mov	a, r7
	call	pm.phex
	jmp	0
