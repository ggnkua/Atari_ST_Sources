;
; GODconv
; 
; April 16, 2004
; Anders Eriksson
; ae@dhs.nu
; 
; texts.s


		section	data

targa_filename:	dc.b	'output.tga',0
		even

title_text:	dc.b	'GODconv v1.0',13,10
		dc.b	'------------',13,10,13,10,0
		even
				
noram_text:	dc.b	'Not enough memory!',13,10,0
		even
		
nofile_text:	dc.b	'File not found!',13,10,0
		even		

unknown_text:	dc.b	'The fileformat is not recognized!',13,10,0
		even
				
hicol_text:	dc.b	'Converting from GOD 16bit-HiColour',13,10
		dc.b	'file to 24-bit TARGA.',13,10,0
		even
		

		
		section	text
