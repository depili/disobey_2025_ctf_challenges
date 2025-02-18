	CPU	Z180
	RELAXED	ON

BOOT	EQU	0
BDOS	EQU	0x0005
FCBL	EQU	0x005C
SFCB	EQU	FCBL
FCB2	EQU	0x006C
DBUFF	EQU	0x0080
TPA	EQU	0x0100

readc	EQU	1
putc	EQU	2
printf	EQU	9
constat	EQU	11
openf	EQU	15
closef	EQU	16
deletef	EQU	19
readf	EQU	20
writef	EQU	21
makef	EQU	22

flag_len	EQU	nofile - flag

	PHASE	TPA

	ld	sp, stack

	; Print banner
	ld	de, banner
	ld	c, printf
	call	BDOS

	; RNG seed
	ld	de, seed
	ld	c, printf
	call	BDOS

	; Drain any keypresses
-	ld	c, 6
	ld	e, 0xFF
	call	BDOS
	or	A
	jr	nz, -

	; Do random reads until a key is pressed
.loop:	call	random
	ld	c, 6
	ld	e, 0xFF
	call	BDOS
	or	a
	jr	z, .loop

	; Prompt for the response
	ld	de, prompt
	ld	c, printf
	call	BDOS

	call	random
	call	phex
	call	random
	call	phex

	ld	a, "\r"
	call	printc
	ld	a, "\n"
	call	printc

	; Check the response....
	call	read_byte
	ld	B, A
;	call	phex
	call	read_byte
	ld	C, A
;	call	phex

	call	random
	cp	C
	jr	nz, wrong
	call	random
	cp	B
	jr	nz, wrong

	jp	print_flag

wrong:
	ld	de, error
	ld	c, printf
	call	BDOS

	jp	boot


print_flag:
	ld	de, normal
	ld	c, printf
	call	BDOS

-	call	random
	cp	0xF0
	jr	nz, -
	call	random
	cp	0x0D
	jr	nz, -

	ld	B, flag_len
	ld	hl, flag
-	ld	c, (hl)
	call	random
	xor	c
	call	printc
	inc	hl
	djnz	-

	jp	boot

	; Provide the flag....


	; Generate the keystream with 16 bit galois LFSR
	ld	b, 128
	ld	hl, KEY
-	call	random
	ld	(hl), a
;	call	phex
	inc	hl
	djnz	-

;	ld	A, "\r"
;	call	printc
;	ld	A, "\n"
;	call	printc

	ld	de, SFCB
	call	open
	ld	de, nofile
	inc	a
	jp	z, finish

	ld	de, DFCB
	call	delete

	ld	de, DFCB
	call	make
	ld	de, nodir
	inc	a
	jp	z, finish
copy:
	ld	de, SFCB
	call	read
	or	a
	jr	nz, eofile

	ld	hl, key
	ld	de, DBUFF
	ld	b, 128

-	ld	a, (de)
	xor	(hl)
	ld	(de), a
;	call	phex
	inc	de
	inc	hl
	djnz	-

	ld	de, DFCB
	call	write
	ld	de, space
	or	a
	jp	nz, finish
	jp	copy
eofile:
	ld	de, DFCB
	call	close
	ld	de, wrprot
	inc	a
	jr	z, finish
	ld	de, normal
finish:
	ld	A, "\r"
	call	printc
	ld	A, "\n"
	call	printc

	ld	c, printf
	call	BDOS
	jp	boot



phex:
	push	af
	rra
	rra
	rra
	rra
	call	.conv
	pop	af
.conv:
	push	af
	and	0x0F
	add	a, 0x90
	daa
	adc	a, 0x40
	daa
	call	printc
	pop	af
	ret

cin:
	push	bc
	push	de
	push	hl
	ld	C, readc
	call	BDOS
	pop	hl
	pop	de
	pop	bc
	ret


read_byte:
	LD	D, 00h		;Set up
	CALL	HEXCON		;Get byte and convert to hex
	ADD	A,A		;First nibble so
	ADD	A,A		;multiply by 16
	ADD	A,A		;
	ADD	A,A		;
	LD	D,A		;Save hi nibble in D
HEXCON:
	CALL	cin		;Get next chr
	SUB	30h		;Makes '0'-'9' equal 0-9
	CP	0Ah		;Is it 0-9 ?
	JR	C,NALPHA	;If so miss next bit
	SUB	07h		;Else convert alpha
NALPHA:
	OR	D		;Add hi nibble back
	RET


printc:
	push	af
	push	bc
	push	de
	push	hl

	ld	C, putc
	ld	e, a
	call	BDOS

	pop	hl
	pop	de
	pop	bc
	pop	af
	ret
open:
	ld	C, openf
	jp	BDOS

close:
	ld	C, closef
	jp	BDOS

delete:
	ld	C, deletef
	jp	BDOS

read:
	ld	C, readf
	jp	BDOS

write:
	ld	C, writef
	jp	BDOS

make:
	ld	C, makef
	jp	BDOS

random:
	PUSH	HL
	PUSH	BC
	ld	B, 8
	ld	C, 0
.loop:
	ld	hl, LFSR
	srl	(hl)
	inc	hl
	RR	(hl)
	JR	C, .carry
	JR	.loop_end
.carry:
	ld	hl, LFSR
	ld	a, 0xB4
	xor	(hl)
	ld	(hl), a
	SCF
.loop_end:
	RR	C
	djnz	.loop
.end:
	ld	A, C
	POP	BC
	POP	HL
	RET


banner:	db	"Kouvosto Telecom Keyserver v0.01 rc 666\r\n$"
seed:	db	"Press a button to seed the keygenerator\r\n$"
prompt:	db	"Enter response for challenge: $"
error:	db	"\r\nInvalid resonse, KIA has been notified.\r\n$"
flag:	db	0x19, 0x4E, 0x08, 0x31, 0xB6, 0x08, 0x01, 0xCE, 0x60, 0x92, 0xD9, 0xF1, 0x1C, 0xD6, 0xBB, 0xC9, 0x46, 0xF5, 0x11, 0x0B, 0xB5, 0x4A, 0x17, 0xD2, 0xBE, 0xB3, 0xA3, 0xE6, 0xAE, 0x2D, 0x0D
;flag:	db	"DISOBEY[old tools for old jobs]"
nofile:	db	"no source file$"
nodir:	db	"no directory space$"
space:	db	"no space$"
wrprot:	db	"write protected$"
normal:	db	"\r\nEnjoy your flag: $"

LFSR:	db	0xDE, 0xAD

KEY:	DS	128

DFCB:	DS	33
DFCB_CR	EQU	DFCB+32

	DS	256
stack:
	DS	256
	END