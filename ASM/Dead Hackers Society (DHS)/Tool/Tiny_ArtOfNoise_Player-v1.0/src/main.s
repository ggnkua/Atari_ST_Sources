;
; TAP
; Tiny ArtOfNoise Player v1.0
;
; May 31, 2000
;
; Anders Eriksson
; ae@dhs.nu
;
; main.s


TTPFILE:	equ	1					;1=take commandline 0=use internal

		output	.ttp
		comment	HEAD=%111
		opt p=68030,NOCASE


		section	text

begin:
		include	'init.s'				;init and check for commandlines
		include	'loader.s'				;load module
		include	'filechck.s'				;check type

		move.l	#music_on,d0
		bsr.w	supexec

mainloop:
		bsr.w	crawcin

		move.l	#music_off,d0
		bsr.w	supexec


		include	'exit.s'				;exit



; subroutines


supexec:	move.l	d0,-(sp)				;supexec()
		move.w	#$26,-(sp)				;
		trap	#14					;
		addq.l	#6,sp					;
		rts						;

crawcin:	move.w	#7,-(sp)				;crowkin()
		trap	#1					;
		addq.l	#2,sp					;
		rts


mxallocttram:	move.w	#3,-(sp)				;mxalloc() - prefer fastram
		move.l	d0,-(sp)				;bytes wanted
		move.w	#$44,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;
		rts

print:		tst.w	quiet
		bne.s	.no
		move.l	d0,-(sp)				;
		move.w	#9,-(sp)				;print tos text
		trap	#1					;
		addq.l	#6,sp					;
.no:		rts

newrow:		move.l	#.var,d0
		bsr.w	print
		rts
.var:		dc.b	13,10,0,0


		include	'aon-ssi.s'
		even

		section	data


	ifeq	ttpfile
fixedname:	dc.b	'mod.aon',0				;internal filename
		even
	endc



title_text:	dc.b	'Tiny ArtOfNoise Player v1.0',13,10	;title
		dc.b	'Press any key to stop',13,10,13,10,0	;
		even

channels_text:	dc.b	'Channels: x',0
		even

songname_name:	dc.b	'Songname: ',0
		even
		
composer_name:	dc.b	'Composer: ',0
		even
		
date_name:	dc.b	'    Date: ',0
		even
		
filename_name:	dc.b	'Filename: ',0
		even

remark_name:	dc.b	'  Remark: ',0
		even
		
		
		
		section	bss

songname_text:	ds.b	2048
composer_text:	ds.b	2048
date_text:	ds.b	2048
remark_text:	ds.b	2048

;commandline parameters
quiet:		ds.w	1					;0=print 1=silent


save_dta:	ds.l	1					;old dta
dta:		ds.l	11					;new dta

filelength:	ds.l	1					;filelength
filebuffer:	ds.l	1					;filebuffer address
filename:	ds.l	1					;filename address
filenumber:	ds.w	1					;filenumbers