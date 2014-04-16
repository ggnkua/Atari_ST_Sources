;
; GODconv v1.0
; 
; April 16, 2004
; Anders Eriksson
; ae@dhs.nu
; 
; main.s
;
; Supposed to convert GODpaint picture (.god) into Targa

		output	.ttp
		comment HEAD=%111
		opt	p=68030


		section	text

		include	'init.s'		;get commandline, mshrink, dta etc
		include	'loader.s'		;load .god-file
		include	'targa.s'		;convert .god-file to TARGA


pterm:		tst.l	exit_text_adr		;error message to print?
		beq.s	.noerror		;no
		
		move.l	exit_text_adr,d0	;yes
		bsr.w	cconws			;
		bsr.w	crawcin			;waitkey
		

.noerror:	clr.w	-(sp)			;pterm()
		trap	#1			;
		

		include	'subs.s'		;all common subroutines
		include	'texts.s'		;all text datas to print



		section	data


exit_text_adr:	dc.l	0

		section	bss

filename:	ds.l	1
filelength:	ds.l	1		
filenumber:	ds.w	1
save_dta:	ds.l	1
dta:		ds.l	11

source_adr:	ds.l	1
dest_adr:	ds.l	1		
imgdata_size:	ds.l	1
totalimg_size:	ds.l	1
x_res:		ds.w	1
y_res:		ds.w	1
		end