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

	PHASE	TPA

	ld	sp, stack

	ld	b, 33
	ld	hl, SFCB
	ld	de, DFCB
	; Move destination fcb
-	ld	a, (hl)
	ld	(de), a
	inc	hl
	inc	de
	djnz	-

	xor	a
	ld	(DFCB_CR), a

	ld	a, 'E'
	ld	(DFCB+9), A
	ld	a, 'N'
	ld	(DFCB+10), A
	ld	a, 'C'
	ld	(DFCB+11), A


	ld	de, banner
	ld	c, printf
	call	BDOS

	ld	de, seed
	ld	c, printf
	call	BDOS

-	ld	c, 6
	ld	e, 0xFF
	call	BDOS
	or	A
	jr	nz, -

.loop:	call	random
	ld	c, 6
	ld	e, 0xFF
	call	BDOS
	or	a
	jr	z, .loop


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


banner:	db	"Kouvosto Telecom WannaCry v0.01\r\n$"
seed:	db	"Press a button to seed the key\r\n$"
nofile:	db	"no source file$"
nodir:	db	"no directory space$"
space:	db	"no space$"
wrprot:	db	"write protected$"
normal:	db	"Encrypted. Pay the ransom of 1 495 801 111 416 RAH to Kouvostopankki to decrypt your files.$"

LFSR:	db	0xDE, 0xAD

KEY:	DS	128

DFCB:	DS	33
DFCB_CR	EQU	DFCB+32

	DS	256
stack:
	DS	256
	END