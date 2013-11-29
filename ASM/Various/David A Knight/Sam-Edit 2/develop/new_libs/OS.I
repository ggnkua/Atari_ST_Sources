;-----------------------------------------------
;
; Gemdos Macros 
;
; Author: David Knight
;
; Version 1.0
;
; Date: 22/09/1997
;
;-----------------------------------------------

gemdos	equ	1

	SECTION	text

;--------------
; Call Gemdos
;--------------

Call_GEMDOS
	move.l	(sp)+,return_address
	trap	#gemdos
	add.l	stack_correction,sp
	move.l	return_address,-(sp)
	rts

	SECTION	bss

stack_correction	ds.l	1
return_address	ds.l	1

******************************************

	SECTION	text

;------------------
; Gemdos functions
;------------------


p_term0	macro		; Terminate Process (old form)
	clr.w	-(sp)
	move.l	#2,stack_correction
	jsr	Call_GEMDOS
	endm

c_conin	macro		; Read character from keyboard
	move.w	#$1,-(sp)
	move.l	#2,stack_correction
	jsr	Call_GEMDOS
	endm

c_conout	macro		; Write character to screen
	move.w	\1,-(sp)
	move.w	#$2,-(sp)
	move.l	#4,stack_correction
	jsr	Call_GEMDOS
	endm

c_auxin	macro		; Read character from serial port
	move.w	#$3,-(sp)
	move.l	#2,stack_correction
	jsr	Call_GEMDOS
	endm

c_auxout	macro		; Write character to serial port
	move.w	\1,-(sp)
	move.w	#$4,-(sp)
	move.l	#4,stack_correction
	jsr	Call_GEMDOS
	endm

c_prnout	macro		; Write character to printer
	move.w	\1,-(sp)
	move.w	#$5,-(sp)
	move.l	#4,stack_correction
	jsr	Call_GEMDOS
	endm

c_rawio	macro		; Raw I\O to standard I\O
	move.w	\1,-(sp)
	move.w	#$6,-(sp)
	move.l	#4,stack_correction
	jsr	Call_GEMDOS
	endm

c_rawin	macro		; Raw input from keyboard
	move.w	#$7,-(sp)
	move.l	#2,stack_correction
	jsr	Call_GEMDOS
	endm

c_necin	macro		; Read character from keyboard, no echo
	move.w	#$8,-(sp)
	move.l	#2,stack_correction
	jsr	Call_GEMDOS
	endm

c_conws	macro		; write string to screen
	move.l	\1,-(sp)
	move.w	#$9,-(sp)
	move.l	#6,stack_correction
	jsr	Call_GEMDOS
	endm

c_conrs	macro		; read edited string from keyboard
	move.l	\1,-(sp)
	move.w	#$a,-(sp)
	move.l	#6,stack_correction
	jsr	Call_GEMDOS
	endm

c_conis	macro		; Check status of Keyboard
	move.w	#$b,-(sp)
	move.l	#2,stack_correction
	jsr	Call_GEMDOS
	endm

d_setdrv	macro		; Set default drive
	move.w	\1,-(sp)
	move.w	#$e,-(sp)
	move.l	#4,stack_correction
	jsr	Call_GEMDOS
	endm

c_conos	macro		; Check status of standard output
	move.w	#$10,-(sp)
	move.l	#2,stack_correction
	jsr	Call_GEMDOS
	endm

c_prnos	macro		; Check status of printer
	move.w	#$11,-(sp)
	move.l	#2,stack_correction
	jsr	Call_GEMDOS
	endm

c_auxis	macro		; Check status of serial port input
	move.w	#$12,-(sp)
	move.l	#2,stack_correction
	jsr	Call_GEMDOS
	endm

c_auxos	macro		; Check status of serial port output
	move.w	#$13,-(sp)
	move.l	#2,stack_correction
	jsr	Call_GEMDOS
	endm

m_addalt	macro		; Inform GEMDOS of alternative memory
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.w	#$14,-(sp)
	move.l	#10,stack_correction
	jsr	Call_GEMDOS
	endm

d_getdrv	macro		; Get default drive
	move.w	#$19,-(sp)
	move.l	#2,stack_correction
	jsr	Call_GEMDOS
	endm

f_setdta	macro		; Set disk transfer address
	move.l	\1,-(sp)
	move.w	#$1a,-(sp)
	move.l	#6,stack_correction
	jsr	Call_GEMDOS
	endm

super	macro		; Get into Supervisor\User Mode
	move.l	\1,-(sp)
	move.w	#$20,-(sp)
	move.l	#6,stack_correction
	jsr	Call_GEMDOS
	endm

t_getdate	macro		; Get date
	move.w	#$2a,-(sp)
	move.l	#2,stack_correction
	jsr	Call_GEMDOS
	endm

t_setdate	macro		; Set date
	move.w	\1,-(sp)
	move.w	#$2b,-(sp)
	move.l	#4,stack_correction
	jsr	Call_GEMDOS
	endm

t_gettime	macro		; Get time
	move.w	#$2c,-(sp)
	move.l	#2,stack_correction
	jsr	Call_GEMDOS
	endm

t_settime	macro		; Set time
	move.w	\1,-(sp)
	move.w	#$2d,-(sp)
	move.l	#4,stack_correction
	jsr	Call_GEMDOS
	endm

f_getdta	macro		; Get disk transfer address
	move.w	#$2f,-(sp)
	move.l	#2,stack_correction
	jsr	Call_GEMDOS
	endm

s_version	macro		; Get GEMDOS version number
	move.w	#$30,-(sp)
	move.l	#2,stack_correction
	jsr	Call_GEMDOS
	endm

p_termres	macro		; Terminate and stay resident
	move.w	\1,-(sp)
	move.l	\2,-(sp)
	move.w	#$31,-(sp)
	move.l	#8,stack_correction
	jsr	Call_GEMDOS
	endm

d_free	macro		; Get drive free space
	move.w	\1,-(sp)
	move.l	\2,-(sp)
	move.w	#$36,-(sp)
	move.l	#8,stack_correction
	jsr	Call_GEMDOS
	endm

d_create	macro		; Create a sub-directory
	move.l	\1,-(sp)
	move.w	#$39,-(sp)
	move.l	#6,stack_correction
	jsr	Call_GEMDOS
	endm

d_delete	macro		; Delete a sub-directory
	move.l	\1,-(sp)
	move.w	#$3a,-(sp)
	move.l	#6,stack_correction
	jsr	Call_GEMDOS
	endm

d_setpath	macro		; Set current directory
	move.l	\1,-(sp)
	move.w	#$3b,-(sp)
	move.l	#6,stack_correction
	jsr	Call_GEMDOS
	endm

f_create	macro		; Create a file
	move.w	\1,-(sp)
	move.l	\2,-(sp)
	move.w	#$3c,-(sp)
	move.l	#8,stack_correction
	jsr	Call_GEMDOS
	endm

f_open	macro		; Open a file
	move.w	\1,-(sp)
	move.l	\2,-(sp)
	move.w	#$3d,-(sp)
	move.l	#8,stack_correction
	jsr	Call_GEMDOS
	endm

f_close	macro		; Close file
	move.w	\1,-(sp)
	move.w	#$3e,-(sp)
	move.l	#4,stack_correction
	jsr	Call_GEMDOS
	endm

f_read	macro		; Read file
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.w	\3,-(sp)
	move.w	#$3f,-(sp)
	move.l	#12,stack_correction
	jsr	Call_GEMDOS
	endm

f_write	macro		; Write file
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.w	\3,-(sp)
	move.w	#$40,-(sp)
	move.l	#12,stack_correction
	jsr	Call_GEMDOS
	endm

f_delete	macro		; Delete file
	move.l	\1,-(sp)
	move.w	#$41,-(sp)
	move.l	#6,stack_correction
	jsr	Call_GEMDOS
	endm

f_seek	macro		; Seek file pointer
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.l	\3,-(sp)
	move.w	#$42,-(sp)
	move.l	#10,stack_correction
	jsr	Call_GEMDOS
	endm

f_attrib	macro		; Get/Set file attributes
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.l	\3,-(sp)
	move.w	#$43,-(sp)
	move.l	#10,stack_correction
	jsr	Call_GEMDOS
	endm

f_dup	macro		; Duplicate file handle
	move.w	\1,-(sp)
	move.w	#$45,-(sp)
	move.l	#4,stack_correction
	jsr	Call_GEMDOS
	endm

f_force	macro		; Force file handle
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.w	#$46,-(sp)
	move.l	#6,stack_correction
	jsr	Call_GEMDOS
	endm

d_getpath	macro		; Get current directory
	move.w	\1,-(sp)
	move.l	\2,-(sp)
	move.w	#$47,-(sp)
	move.l	#8,stack_correction
	jsr	Call_GEMDOS
	endm

m_xalloc	macro		; Allocate Memory with prefetence
	move.w	\1,-(sp)
	move.l	\2,-(sp)
	move.w	#$48,-(sp)
	move.l	#8,stack_correction
	jsr	Call_GEMDOS
	endm

m_alloc	macro		; Allocate Memory
	move.l	\1,-(sp)
	move.w	#$48,-(sp)
	move.l	#6,stack_correction
	jsr	Call_GEMDOS
	endm

m_free	macro		; Free Allocate Memory
	move.l	\1,-(sp)
	move.w	#$49,-(sp)
	move.l	#6,stack_correction
	jsr	Call_GEMDOS
	endm

m_shrink	macro		; Shrink allocated Memory
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	move.l	#12,stack_correction
	jsr	Call_GEMDOS
	endm

p_exec	macro		; Load or Execute a Program
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.l	\3,-(sp)
	move.w	\4,-(sp)
	move.w	#$4b,-(sp)
	move.l	#16,stack_correction
	jsr	Call_GEMDOS
	endm

p_term	macro		; Terminate Program
	move.w	\1,-(sp)
	move.w	#$4c,-(sp)
	move.l	#4,stack_correction	; not needed
	jsr	Call_GEMDOS
	endm

f_sfirst	macro		; Search for First
	move.w	\1,-(sp)
	move.l	\2,-(sp)
	move.w	#$4e,-(sp)
	move.l	#8,stack_correction
	jsr	Call_GEMDOS
	endm

f_snext	macro		; Search for next occurence
	move.w	#$4f,-(sp)
	move.l	#2,stack_correction
	jsr	Call_GEMDOS
	endm

f_rename	macro		; Rename a file
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	clr.w	-(sp)
	move.w	#$56,-(sp)
	move.l	#12,stack_correction
	jsr	Call_GEMDOS
	endm

f_datime	macro		; Get.Set Date & Time Stamp
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.l	\3,-(sp)
	move.w	#$57,-(sp)
	move.l	#10,stack_correction
	jsr	Call_GEMDOS
	endm

;-----------------------------------------------
;
; Bios Macros 
;
; Author: David Knight
;
; Version 1.0
;
; Date: 22/09/1997
;
;-----------------------------------------------

bios	equ	13

	SECTION	text

;--------------
; Call Bios
;--------------

Call_BIOS
	move.l	(sp)+,return_address
	trap	#bios
	add.l	stack_correction,sp
	move.l	return_address,-(sp)
	rts

******************************************

;------------------
; Bios functions
;------------------

bconstat	macro		; Return device input status
	move.w	\1,-(sp)
	move.w	#$1,-(sp)
	move.l	#4,stack_correction
	jsr	Call_BIOS
	endm

bconin	macro		; Return a character from a device
	move.w	\1,-(sp)
	move.w	#$2,-(sp)
	move.l	#4,stack_correction
	jsr	Call_BIOS
	endm

bconout	macro		; Write a character to a device
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.w	#$3,-(sp)
	move.l	#6,stack_correction
	jsr	Call_BIOS
	endm

rwabs	macro		; Read/Write logical sectors on a device
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.w	\3,-(sp)
	move.l	\4,-(sp)
	move.w	\5,-(sp)
	move.w	#$4,-(sp)
	move.l	#14,stack_correction
	jsr	Call_BIOS
	endm

setexc	macro		; Set exception vector
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	move.w	#$5,-(sp)
	move.l	#8,stack_correction
	jsr	Call_BIOS
	endm

tickcal	macro		; Get system timer 'tick' interval
	move.w	#$6,-(sp)
	move.l	#2,stack_correction
	jsr	Call_BIOS
	endm

getbpb	macro		; Get BIOS paramter block for a device
	move.w	\1,-(sp)
	move.w	#$7,-(sp)
	move.l	#4,stack_correction
	jsr	Call_BIOS
	endm

bcostat	macro		; Return device output status
	move.w	\1,-(sp)
	move.w	#$8,-(sp)
	move.l	#4,stack_correction
	jsr	Call_BIOS
	endm

mediach	macro		; Return media change status
	move.w	\1,-(sp)
	move.w	#$9,-(sp)
	move.l	#4,stack_correction
	jsr	Call_BIOS
	endm

drvmap	macro		; Return bitmap of mounted drives
	move.w	#$a,-(sp)
	move.l	#2,stack_correction
	jsr	Call_BIOS
	endm

kbshift	macro		; Find state of keyboard 'shift' keys
	move.w	\1,-(sp)
	move.w	#$b,-(sp)
	move.l	#4,stack_correction
	jsr	Call_BIOS
	endm

;-----------------------------------------------
;
; XBios Macros 
;
; Author: David Knight
;
; Version 1.0
;
; Date: 22/09/1997
;
;-----------------------------------------------

xbios	equ	14

	SECTION	text

;--------------
; Call XBios
;--------------

Call_XBIOS
	move.l	(sp)+,return_address
	trap	#xbios
	add.l	stack_correction,sp
	move.l	return_address,-(sp)
	rts

******************************************

;------------------
; XBios functions
;------------------

initmous	macro		; Set mouse mode and packet handler
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.w	\3,-(sp)
	clr.w	-(sp)
	move.l	#12,stack_correction
	jsr	Call_XBIOS
	endm

physbase	macro		; Get physical screen address
	move.w	#$2,-(sp)
	move.l	#2,stack_correction
	jsr	Call_XBIOS
	endm

logbase	macro		; Get logical screen address
	move.w	#$3,-(sp)
	move.l	#2,stack_correction
	jsr	Call_XBIOS
	endm

getrez	macro		; Get screen resolution
	move.w	#$4,-(sp)
	move.l	#2,stack_correction
	jsr	Call_XBIOS
	endm

setscreen	macro		; Set screen address & mode
	move.w	\1,-(sp)
	move.l	\2,-(sp)
	move.l	\3,-(sp)
	move.w	#$5,-(sp)
	move.l	#12,stack_correction
	jsr	Call_XBIOS
	endm

setpalette	macro		; Set display palette
	move.l	\2,-(sp)
	move.w	#$6,-(sp)
	move.l	#6,stack_correction
	jsr	Call_XBIOS
	endm

setcolor	macro		; Set display palette
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.w	#$7,-(sp)
	move.l	#6,stack_correction
	jsr	Call_XBIOS
	endm

floprd	macro		; Read sectors from a floppy disk
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.w	\3,-(sp)
	move.w	\4,-(sp)
	move.w	\5,-(sp)
	move.l	\6,-(sp)
	move.l	\7,-(sp)
	move.w	#$8,-(sp)
	move.l	#20,stack_correction
	jsr	Call_XBIOS
	endm

flopwr	macro		; Write sectors to a floppy disk
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.w	\3,-(sp)
	move.w	\4,-(sp)
	move.w	\5,-(sp)
	move.l	\6,-(sp)
	move.l	\7,-(sp)
	move.w	#$9,-(sp)
	move.l	#20,stack_correction
	jsr	Call_XBIOS
	endm

flopfmt	macro		; Format a track on a floppy disk
	move.w	\1,-(sp)
	move.l	\2,-(sp)
	move.w	\3,-(sp)
	move.w	\4,-(sp)
	move.w	\5,-(sp)
	move.w	\6,-(sp)
	move.w	\7,-(sp)
	move.l	\8,-(sp)
	move.l	\9,-(sp)
	move.w	#$a,-(sp)
	move.l	#26,stack_correction
	jsr	Call_XBIOS
	endm

midiws	macro		; Write string to MIDI port
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	move.w	#$c,-(sp)
	move.l	#8,stack_correction
	jsr	Call_XBIOS
	endm

mfpint	macro		; Set the MFP interrupt handler
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	move.w	#$d,-(sp)
	move.l	#8,stack_correction
	jsr	Call_XBIOS
	endm

iorec	macro		; Find serial device
	move.w	\1,-(sp)
	move.w	#$e,-(sp)
	move.l	#4,stack_correction
	jsr	Call_XBIOS
	endm

rsconf	macro		; Configure rs232 port
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.w	\3,-(sp)
	move.w	\4,-(sp)
	move.w	\5,-(sp)
	move.w	\6,-(sp)
	move.w	#$f,-(sp)
	move.l	#14,stack_correction
	jsr	Call_XBIOS
	endm

keytbl	macro		; Get/Set keyboard translation tables
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.l	\3,-(sp)
	move.w	#$10,-(sp)
	move.l	#14,stack_correction
	jsr	Call_XBIOS
	endm

random	macro		; Obtain random number
	move.w	#$11,-(sp)
	move.l	#2,stack_correction
	jsr	Call_XBIOS
	endm

protobt	macro		; Build prototype boot sector
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.l	\3,-(sp)
	move.l	\4,-(sp)
	move.w	#$12,-(sp)
	move.l	#14,stack_correction
	jsr	Call_XBIOS
	endm

flopver	macro		; Verify sectors from a floppy disk
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.w	\3,-(sp)
	move.w	\4,-(sp)
	move.w	\5,-(sp)
	move.l	\6,-(sp)
	move.l	\7,-(sp)
	move.w	#$13,-(sp)
	move.l	#20,stack_correction
	jsr	Call_XBIOS
	endm

scrdmp	macro		; Copy screen to printer
	move.w	#$14,-(sp)
	move.l	#2,stack_correction
	jsr	Call_XBIOS
	endm

cursconf	macro		; Configure VT52 cursor
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.w	#$15,-(sp)
	move.l	#6,stack_correction
	jsr	Call_XBIOS
	endm

settime	macro		; Set IKBD time
	move.l	\1,-(sp)
	move.w	#$16,-(sp)
	move.l	#6,stack_correction
	jsr	Call_XBIOS
	endm

gettime	macro		; Get IKBD time
	move.w	#$17,-(sp)
	move.l	#2,stack_correction
	jsr	Call_XBIOS
	endm

bioskeys	macro		; Reset keyboard translation tables
	move.w	#$18,-(sp)
	move.l	#2,stack_correction
	jsr	Call_XBIOS
	endm

ikbdws	macro		; Write string to keyboard processor
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	move.w	#$19,-(sp)
	move.l	#8,stack_correction
	jsr	Call_XBIOS
	endm

jdisint	macro		; Disable 68901 interrupt
	move.w	\1,-(sp)
	move.w	#$1a,-(sp)
	move.l	#4,stack_correction
	jsr	Call_XBIOS
	endm

jenabint	macro		; Enable 68901 interrupt
	move.w	\1,-(sp)
	move.w	#$1b,-(sp)
	move.l	#4,stack_correction
	jsr	Call_XBIOS
	endm

giaccess	macro		; Read/Write sound chip registers
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.w	#$1c,-(sp)
	move.l	#6,stack_correction
	jsr	Call_XBIOS
	endm

offgibit	macro		; Reset bit on port A of sound chip
	move.w	\1,-(sp)
	move.w	#$1d,-(sp)
	move.l	#4,stack_correction
	jsr	Call_XBIOS
	endm

ongibit	macro		; Set bit on port A of sound chip
	move.w	\1,-(sp)
	move.w	#$1e,-(sp)
	move.l	#4,stack_correction
	jsr	Call_XBIOS
	endm

Xbtimer	macro		; Configure MFP timer
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	move.w	\3,-(sp)
	move.w	\4,-(sp)
	move.w	#$1f,-(sp)
	move.l	#12,stack_correction
	jsr	Call_XBIOS
	endm

dosound	macro		; Initialise sound daemon
	move.l	\1,-(sp)
	move.w	#$20,-(sp)
	move.l	#6,stack_correction
	jsr	Call_XBIOS
	endm

setprt	macro		; Set/Get printer configuration
	move.w	\1,-(sp)
	move.w	#$21,-(sp)
	move.l	#4,stack_correction
	jsr	Call_XBIOS
	endm

kbdvbase	macro		; Get system ACIA dispatch handler
	move.w	#$22,-(sp)
	move.l	#2,stack_correction
	jsr	Call_XBIOS
	endm

kbrate	macro		; Get/Set keyboard repeat and delay
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.w	#$23,-(sp)
	move.l	#6,stack_correction
	jsr	Call_XBIOS
	endm

prtblk	macro		; Print bitmap
	move.l	\1,-(sp)
	move.w	#$24,-(sp)
	move.l	#6,stack_correction
	jsr	Call_XBIOS
	endm

vsync	macro		; Wait for vertical sync to occur
	move.w	#$25,-(sp)
	move.l	#2,stack_correction
	jsr	Call_XBIOS
	endm

supexec	macro		; Call supervisor routine
	move.l	\1,-(sp)
	move.w	#$26,-(sp)
	move.l	#6,stack_correction
	jsr	Call_XBIOS
	endm

puntaes	macro		; Discard AES
	move.w	#$27,-(sp)
	move.l	#2,stack_correction
	jsr	Call_XBIOS
	endm

floprate	macro		; Set floppy disk step rate
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.w	#$29,-(sp)
	move.l	#6,stack_correction
	jsr	Call_XBIOS
	endm

dmaread	macro		; Read sectors from a device
	move.w	\1,-(sp)
	move.l	\2,-(sp)
	move.w	\3,-(sp)
	move.l	\4,-(sp)
	move.w	#$2a,-(sp)
	move.l	#14,stack_correction
	jsr	Call_XBIOS
	endm

dmawrite	macro		; Write sectors to a device
	move.w	\1,-(sp)
	move.l	\2,-(sp)
	move.w	\3,-(sp)
	move.l	\4,-(sp)
	move.w	#$2b,-(sp)
	move.l	#14,stack_correction
	jsr	Call_XBIOS
	endm

bconmap	macro		; Get/Set mapping of AUX device
	move.w	\1,-(sp)
	move.w	#$2c,-(sp)
	move.l	#4,stack_correction
	jsr	Call_XBIOS
	endm

nvmaccess	macro		; Access non-volatile memory
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	move.w	\3,-(sp)
	move.w	\4,-(sp)
	move.w	#$2e,-(sp)
	move.l	#12,stack_correction
	jsr	Call_XBIOS
	endm

blitmode	macro		; Get/Set blitter configuration
	move.w	\1,-(sp)
	move.w	#$40,-(sp)
	move.l	#4,stack_correction
	jsr	Call_XBIOS
	endm

esetshift	macro		; Set current video shift mode
	move.w	\1,-(sp)
	move.w	#$50,-(sp)
	move.l	#4,stack_correction
	jsr	Call_XBIOS
	endm

egetshift	macro		; Gett current video shift mode
	move.w	#$51,-(sp)
	move.l	#2,stack_correction
	jsr	Call_XBIOS
	endm

esetbank	macro		; Get/Set colour look up bank
	move.w	\1,-(sp)
	move.w	#$52,-(sp)
	move.l	#4,stack_correction
	jsr	Call_XBIOS
	endm

esetcolor	macro		; Get/Set a single colour entry
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.w	#$53,-(sp)
	move.l	#6,stack_correction
	jsr	Call_XBIOS
	endm

esetpalette	macro		; Set look up table registers
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	move.w	\3,-(sp)
	move.w	#$54,-(sp)
	move.l	#10,stack_correction
	jsr	Call_XBIOS
	endm

egetpalette	macro		; Get look up table registers
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	move.w	\3,-(sp)
	move.w	#$55,-(sp)
	move.l	#10,stack_correction
	jsr	Call_XBIOS
	endm

esetgray	macro		; Get/Set grey mode
	move.w	\1,-(sp)
	move.w	#$56,-(sp)
	move.l	#4,stack_correction
	jsr	Call_XBIOS
	endm

esetsmear	macro		; Get/Set video smear mode
	move.w	\1,-(sp)
	move.w	#$57,-(sp)
	move.l	#4,stack_correction
	jsr	Call_XBIOS
	endm