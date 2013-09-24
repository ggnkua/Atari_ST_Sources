; Nullos Tracker Krap v1.0
;
; main.s
;
; August 14, 2001
;
; Anders Eriksson
; ae@dhs.nu

		comment HEAD=%111	
		output .ttp
		opt	p=68030,NOCASE

ttpfile:	equ	1					;0=use fixed filename 1=commandline
type_mix:	equ	1


		section	text

begin:		include	'init.s'				;release memory check dsp etc
		include	'loader.s'				;load file
		
		move.l	#playmodule,d0
		bsr.w	dosupexec

		move.l	#front_text,d0				;print gids text
		bsr.w	print					;

		move.l	filename,d0				;print filename
		bsr.w	print					;

		move.l	#new_row,d0				;print new row
		bsr.w	print					;

		move.l	#channels_text,d0			;print channels
		bsr.w	print

		move.l	#key_text,d0				;print pres ay key
		bsr.w	print					;

		move.w	#7,-(sp)				;crawcin()
		trap	#1					;
		addq.l	#2,sp					;

		move.l	#stopmodule,d0
		bsr.w	dosupexec


		include	'exit.s'				;exit program


print:		tst.w	quiet					;quiet mode?
		bne.s	.no					;
		move.l	d0,-(sp)				;textprint
		move.w	#9,-(sp)				;
		trap	#1					;
		addq.l	#6,sp					;
.no:		rts

dosupexec:	move.l	d0,-(sp)				;supexec()
		move.w	#$26,-(sp)				;
		trap	#14					;
		addq.l	#6,sp					;
		rts						;

		include	'dnt/player.s'


		section	data


	ifeq	ttpfile

ntkname:	dc.b	'd:\temp\mod.ntk',0
		even

	endc


front_text:	dc.b	'Nullos Tracker Krap v1.0',13,10
		dc.b	'------------------------',13,10,13,10
		dc.b	'  Filename: ',0
		even

channels_text:	dc.b	'  Channels: 4',13,10,0
		even
		

key_text:	dc.b	13,10,'Press any key to stop playing.',13,10,0
		even

new_row:	dc.b	13,10,0
		even
		
error_text:	dc.l	new_row
		even
		
		section	bss

filelength:	ds.l	1					;length in bytes of loaded file
filename:	ds.l	1					;address to filename to load
file_error:	ds.l	1					;error check
filenumber:	ds.w	1					;filenumber
filebuffer:	ds.l	1					;address to loader dest buffer

save_dta:	ds.l	1					;old dta address
dta:		ds.l	11					;new dta buffer

		end