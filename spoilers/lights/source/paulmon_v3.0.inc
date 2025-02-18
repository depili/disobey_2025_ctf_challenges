; If you include these lines in your program, you can easily
; make calls to the routines built-in to PAULMON2.

	.equ	paulmon2,	0000h
	.equ	vector, 02000H			; Location to LJMP interrupt vectors

; Memory map setup. Programs and extensions are scanned on the regions defined by
; bmem - emem and bflash - eflash. All IO should be outside these regions.

	.equ	pgm, 02000H			; Default location for the user program
	.equ	bmem, 01000H			; Where is the beginning of memory
	.equ	emem, 03FFFH			; End of the memory

	.equ	has_flash, 1			; Set to non-zero value if flash installed
	.equ	bflash, 08000H			; First memory location of Flash ROM
	.equ	eflash, 0FFFFH			; Last memory location of Flash ROM

	.equ	eintmem, 000h		; End of intmem, set to 0 for 256 bytes

; Key bindings, do not use lowercase.

	.equ	help_key, '?'			; Help screen
	.equ	dir_key,  'M'			; Directory
	.equ	run_key,  'R'			; Run program
	.equ	dnld_key, 'D'			; Download
	.equ	upld_key, 'U'			; Upload
	.equ	nloc_key, 'N'			; New memory location
	.equ	jump_key, 'J'			; Jump to memory location
	.equ	dump_key, 'H'			; Hex dump memory
	.equ	intm_key, 'I'			; Hex dump internal memory
	.equ	edit_key, 'E'			; Edit memory
	.equ	clrm_key, 'C'			; Clear memory
	.equ	erfr_key, 'Z'			; Erase flash rom
	.equ	dump_strings_key, 'X'		; Dump compressed strings

	.equ	list_key, 'L'			; List (disassemble)
	.equ	step_key, 'S'			; Single step run
	.equ	vtedit_key, 'E'			; Memory editor

; These symbols configure paulmon2's internal memory usage.
; It is usually not a good idea to change these unless you
; know that you really have to.

	.equ	psw_init, 0			; Value for psw (which reg bank to use)
	USING	Bank0

	.equ	dnld_parm, 010H			; Block of 16 bytes for download
	.equ	stack, 080H			; Location of the stack
	.equ	baud_save, 078H			; Save baud for warm boot, 4 bytes
	.equ	state, 02fh
ioSkip	bit 	state.0
	.equ	lastpc, 07CH			; Two bytes for single step


	.equ	backspace, 008h
	.equ	CR_char, 00dh
	.equ	esc_char, 01bh
	.equ	delete_char, 07fh
	.equ	xoff, 013h
	.equ	xon, 011h

; Library routines
	.equ	pm.phex1,	36h + paulmon2	; Print a single hex digit

	.equ    pm.cout,	38h + paulmon2	; Send Acc to serial port

	.equ    pm.cin, 	3Ah + paulmon2	; Get Acc from serial port

	.equ    pm.phex, 	3Ch + paulmon2	; Print Hex value of Acc

	.equ    pm.phex16, 	3Eh + paulmon2	; Print Hex value of DPTR

	.equ    pm.pstr,	40h + paulmon2	; Print string pointed to by DPTR,
						; must be terminated by 0 or a high bit set
						; pressing ESC will stop the printing

	.equ    pm.ghex,	42h + paulmon2	; Get Hex input into Acc
						; Carry set if ESC has been pressed

	.equ    pm.ghex16,	44h + paulmon2	; Get Hex input into DPTR
						; Carry set if ESC has been pressed

	.equ    pm.esc,		46h + paulmon2	; Check for ESC key
						; Carry set if ESC has been pressed

	.equ    pm.upper,	48h + paulmon2	; Convert Acc to uppercase
						; Non-ASCII values are unchanged

	.equ    pm.autobaud,	4Ah + paulmon2	; Initialize serial port

	.equ	pm.pcstr,	4Dh + paulmon2	; Print string in compressed format (no docs)

	.equ	pm.newline,	50h + paulmon2	; Print CR/LF (13 and 10)

	.equ	pm.lenstr,	52h + paulmon2	; Return the length of a string @DPTR (in R0)

	.equ    pm.pint8u,	55h + paulmon2	; Print Acc at an integer, 0 to 255

	.equ    pm.pint8,	58h + paulmon2	; Print Acc at an integer, -128 to 127

	.equ    pm.pint16u,	5Bh + paulmon2	; Print DPTR as an integer, 0 to 65535

	.equ	pm.smart_wr,	5Eh + paulmon2	; Write Acc @DPTR (RAM or flash), C=1 if error

	.equ	pm.prgm,	61h + paulmon2	; Write Acc @DPTR to Flash ROM, C=1 if error

	.equ	pm.erall,	64h + paulmon2	; Erase the Flash ROM chip, C=1 if error

	.equ	pm.find,	67h + paulmon2	; Find next program header in memory

	.equ	pm.cin_filter,	6Ah + paulmon2	; Like cin, but scan for arrow keys, pgup/pgdn

	.equ	pm.asc2hex,	6Dh + paulmon2	; Convert character 0-9,A-F to number 0-15.
