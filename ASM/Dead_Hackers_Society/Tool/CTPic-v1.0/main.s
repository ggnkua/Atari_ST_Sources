;
; CTPic v1.0
;
; July 25, 2004
; Anders Eriksson
; ae@dhs.nu
;
; main.s
;
; A small utility to change the targa image of your
; CT60 FlasROM, read the documentation for 
; instructions.

		
		comment HEAD=%111
		opt p=68040
		output	.ttp

		section	text

start:		include	'init.s'			;leave back mem, setup dta, store commandline addr, enter MiNT domain

		move.l	#titletext,d0			;print title text
		bsr.w	cconws				;
		
		include	'tgaload.s'			;load and check targa file
		include	'patch.s'			;load and patch ct60tos.bin		

		move.l	#patchoktext,d0			;succeded text
		bsr.w	cconws				;


exit:		move.l	save_dta,-(sp)			;fsetdta() restore dta
		move.w	#$1a,-(sp)			;
		trap	#1				;
		addq.l	#6,sp				;


		move.l	#press_any_key,d0		;exit text
		bsr.w	cconws				;

		bsr.w	crawcin				;waitkey
		
		clr.w	-(sp)				;pterm();
		trap	#1				;
		


		include	'subs.s'			;various subroutines
				



		section	data


titletext:	dc.b	'CTPic v1.0',13,10
		dc.b	'----------',13,10,13,10,0
		even

filenotfound:
		dc.b	'ERROR: A file could not be found:',13,10,0
		even

press_any_key:	dc.b	13,10,'Press any key to exit.',13,10,0
		even

badtga:		dc.b	'ERROR: This Targa header is inccorect.',13,10
		dc.b	'Wrong resolution or Targa format?',13,10
		dc.b	'Should be 320x240x24bpp unpacked Targa!',13,10,0
		even

tgasize:	dc.b	'ERROR: Wrong Targa filesize.',13,10
		dc.b	'Should be 230418 bytes!',13,10,0
		even
		
goodtga:	dc.b	'-> 320x240x24bpp Targa loaded OK.',13,10,13,10,0
		even

goodpatch:	dc.b	'-> The flashimage loaded OK.',13,10,13,10,0
		even
		
not_enough_ram:	dc.b	'ERROR: Not enough memory to load file!',13,10,0
		even

notgainflash:	dc.b	'ERROR: No Targa found in loaded Flashimage.',13,10
		dc.b	'Is the ct60tos.bin correct?',13,10,0
		even

patchoktext:	dc.b	'Everything seems to have gone well.',13,10
		dc.b	'When you exit there should be a new file',13,10
		dc.b	'called newtos.bin in the directory where',13,10
		dc.b	'you started the patch program.',13,10,13,10
		dc.b	'The patched file is ready for flashing.',13,10,13,10
		dc.b	'-------------------------------------------------',13,10
		dc.b	'*** IMPORTANT !!! ***',13,10
		dc.b	'YOU ARE UPDATING YOUR FLASHROM AT YOUR OWN RISK!!',13,10
		dc.b	'-------------------------------------------------',13,10,0

br:		dc.b	13,10,13,10,0
		even

tgahead:	dc.w	$0000,$0200,$0000,$0000,$0000
		dc.w	$0000,$4001,$f000,$1800
		even

flashname:	dc.b	'ct60tos.bin',0
		even

outputname:	dc.b	'newtos.bin',0
		even
		
		section	bss


filenumber:	ds.w	1
filename:	ds.l	1
filelength:	ds.l	1
filebuffer:	ds.l	1
flashbuffer:	ds.l	1
save_dta:	ds.l	1
dta:		ds.l	11

		end
