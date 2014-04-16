;
; APXconv v1.1
; 
; February 22, 2003
; Anders Eriksson
; ae@dhs.nu
; 
; main.s
;
; Supposed to convert APEX block files (.apx) into
; IFF (CLUT) / TARGA (HICOL)

		output	.ttp
		comment HEAD=%111
		opt	p=68030


		section	text

		include	'init.s'		;get commandline, mshrink, dta etc
		include	'loader.s'		;load .apx-file
		include	'convert.s'		;convert .apx-file to IFF or TARGA


pterm:		tst.l	exit_text_adr		;error message to print?
		beq.s	.noerror		;no
		
		move.l	exit_text_adr,d0	;yes
		bsr.w	cconws			;
		bsr.w	crawcin			;waitkey
		

.noerror:	clr.w	-(sp)			;pterm()
		trap	#1			;
		

		include	'c2p_8bpl.s'		;chunky to planar converter
		include	'iff.s'			;iff converting
		include	'targa.s'		;targa converting
		include	'subs.s'		;all common subroutines
		include	'texts.s'		;all text datas to print



		section	data


exit_text_adr:	dc.l	0
chunky:		dc.w	0
bplsize:	dc.l	0

		section	bss

filename:	ds.l	1
filelength:	ds.l	1		
filenumber:	ds.w	1
save_dta:	ds.l	1
dta:		ds.l	11

source_adr:	ds.l	1
dest_adr:	ds.l	1		
c2p_adr:	ds.l	1
imgdata_size:	ds.l	1
totalimg_size:	ds.l	1
x_res:		ds.w	1
y_res:		ds.w	1
		end