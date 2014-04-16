;
; DUMP v1.71
;
; May 9, 2005
; Anders Eriksson
; ae@dhs.nu
;
; main.s

ttpfile:	equ	1					;1=take commandline 0=use internal


		comment	HEAD=%101
		
		output	.ttp

		section	text

begin:
		include	'init.s'				;init and check for commandlines
		include	'loader.s'				;load module
		include	'modtype.s'				;check moduletype
		include	'texts.s'				;text printing
		include	'samples.s'				;samplenames printing


		move.l	#dspmod_begin,d0			;start module
		bsr.w	supexec					;

mainloop:
		bsr.w	crawcin

		cmp.b	#"i",d0	 				;i
		beq.w	toggle_interpol				;

		cmp.b	#"I",d0	 				;I
		beq.w	toggle_interpol				;

		cmp.b	#"s",d0	 				;s
		beq.w	toggle_surround				;

		cmp.b	#"S",d0	 				;S
		beq.w	toggle_surround				;

		

		move.l	#dspmod_end,d0				;stop module
		bsr.w	supexec					;


		include	'exit.s'				;exit
		include	'dspmod.s'				;moduleplayer routines



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



print:		tst.w	quiet
		bne.s	.no
		move.l	d0,-(sp)				;
		move.w	#9,-(sp)				;print tos text
		trap	#1					;input: move.l #mytextadr,textadr
		addq.l	#6,sp					;
.no:		rts



		section	data


	ifeq	ttpfile
fixedname:	dc.b	'd:\temp\mod.mod',0			;internal filename
		even
	endc



title_text:	dc.b	'DUMP v1.71',13,10			;title
		dc.b	'Press any key to stop',13,10,13,10,0	;
		even

songname_text:	dc.b	'Songname: ',0				;Songname:
		even						;

filename_text:	dc.b	'Filename: ',0				;Filename:
		even						;

inter_text:	dc.b	'Interpol:     '			;Interpol:
		dc.b	' (press `i` to toggle)',13,10,0	;
		even

surr_text:	dc.b	'Surround:     '			;Surround:
		dc.b	' (press `s` to toggle)',13,10,0	;
		even

newrow_text:	dc.b	13,10,0					;new row
		even

channels_text:	dc.b	'Channels:  ',13,10,0			;Channels:
		even

samp_head_txt:	dc.b	'Samplenames:',13,10,0			;Samplenames:


samples_numb:	dc.b	' 01 ',' 02 ',' 03 ',' 04 ',' 05 '	;sample numbers
		dc.b	' 06 ',' 07 ',' 08 ',' 09 ',' 10 '
		dc.b	' 11 ',' 12 ',' 13 ',' 14 ',' 15 '
		dc.b	' 16 ',' 17 ',' 18 ',' 19 ',' 20 '
		dc.b	' 21 ',' 22 ',' 23 ',' 24 ',' 25 '
		dc.b	' 26 ',' 27 ',' 28 ',' 29 ',' 30 '
		dc.b	' 31 '



		section	bss



samples_text:	ds.b	33*28+4					;samplenames text
samples_break:	ds.w	1					;linebreak counter

;commandline parameters
quiet:		ds.w	1					;0=print 1=silent
surround:	ds.w	1
interpolation:	ds.w	1
samplenames:	ds.w	1

save_dta:	ds.l	1					;old dta
dta:		ds.l	11					;new dta

dma_pointer:	ds.l	1					;pointer to 8000 bytes stram buffer

filelength:	ds.l	1					;filelength
filebuffer:	ds.l	1					;filebuffer address
filename:	ds.l	1					;filename address
filenumber:	ds.w	1					;filenumber

		end