; Graoumf Is Not So Damn Slow v1.2
;
; main.s
;
; August 11, 2001
;
; Anders Eriksson
; ae@dhs.nu


		comment HEAD=%111	
		output .ttp
		opt	p=68030,NOCASE

ttpfile:	equ	1					;0=use fixed filename 1=commandline


		section	text

begin:		include	'init.s'				;release memory check dsp etc
		include	'cmdline.s'				;check commandline
		include	'loader.s'				;load file

		move.l	#front_text,d0				;print gids text
		bsr.w	print					;

		move.l	filename,d0				;print filename
		bsr.w	print					;

		move.l	#new_row,d0				;print new row
		bsr.w	print					;

		include	'parse.s'				;check gt2 file

		bsr.w	gt_init					;init graoumf
		bsr.w	gt_on					;start graoumf

		move.l	#new_row,d0				;print new row
		bsr.w	print					;

		move.l	#key_text,d0				;print pres ay key
		bsr.w	print					;

		move.w	#7,-(sp)				;crawcin()
		trap	#1					;
		addq.l	#2,sp					;


		bsr.w	gt_off					;stop graoumf
		bsr.w	gt_exit					;exit graoumf

		include	'exit.s'				;exit program

		include	'gt\gt.s'				;graoumf player


print:		tst.w	quiet					;quiet mode?
		bne.s	.no					;
		move.l	d0,-(sp)				;textprint
		move.w	#9,-(sp)				;
		trap	#1					;
		addq.l	#6,sp					;
.no:		rts

unlocksnd:	move.w	#$81,-(sp)				;Unlocksnd()
		trap	#14					;
		addq.l	#2,sp					;
		rts


		section	data


	ifeq	ttpfile

gt2name:	dc.b	'd:\temp\mod2.gt2',0
		even

	endc


front_text:	dc.b	'Graoumf Is Not So Damn Slow v1.2.',13,10
		dc.b	'---------------------------------',13,10,13,10
		dc.b	'  Filename: ',0
		even

key_text:	dc.b	'Press any key to stop playing.',13,10,0
		even

new_row:	dc.b	13,10,0
		even
		
error_text:	dc.l	new_row
		even
		
version_text:	dc.b	'GT2 Format: v0.7--',13,10,0
		even

songname_text:	dc.b	'  Songname: ',0
		even

tracker_text:	dc.b	'   Tracker: ',0
		even

channels_text:	dc.b	'  Channels: --',13,10,0
		even

positions_text:	dc.b	' Positions: --',13,10,0
		even

patterns_text:	dc.b	'  Patterns: --',13,10,0
		even

freq_text:	dc.b	'ReplayFreq: xxxxx xx',13,10,0
		even
		
ascii_lut:	dc.b	'0 1 2 3 4 5 6 7 8 9 10111213141516171819202122232425262728293031'
		dc.b	'3233343536373839404142434445464748495051525354555657585960616263'
		dc.b	'6465666768697071727374757677787980818283848586878889909192939495'
		dc.b	'979899'
		even

freq_cmp_tab:	dc.b	'f1f2f3f4f5f6f7f8'
		even

freq_ascii:	dc.b	'--------','49170 Hz','32780 Hz','24585 Hz','19668 Hz','16390 Hz','--------','12292 Hz','--------','9834 Hz ','--------','8295 Hz '
		even

prediv_tab:	dc.w	11,9,7,5,4,3,2,1
		even

		section	bss

quiet:		ds.w	1					;quite mode 
filelength:	ds.l	1					;length in bytes of loaded file
filename:	ds.l	1					;address to filename to load
file_error:	ds.l	1					;error check
filenumber:	ds.w	1					;filenumber
filebuffer:	ds.l	1					;address to loader dest buffer

save_dta:	ds.l	1					;old dta address
dta:		ds.l	11					;new dta buffer



		end