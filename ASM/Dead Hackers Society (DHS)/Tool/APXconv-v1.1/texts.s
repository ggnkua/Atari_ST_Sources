;
; APXconv
; 
; February 22, 2003
; Anders Eriksson
; ae@dhs.nu
; 
; texts.s


		section	data

iff_filename:	dc.b	'output.iff',0
		even

targa_filename:	dc.b	'output.tga',0
		even

title_text:	dc.b	'APXconv v1.1',13,10
		dc.b	'------------',13,10,13,10,0
		even
				
noram_text:	dc.b	'Not enough memory!',13,10,0
		even
		
nofile_text:	dc.b	'File not found!',13,10,0
		even		

unknown_text:	dc.b	'The fileformat is not recognized!',13,10,0
		even
				
planes_text:	dc.b	'Converting from APX 8bit-plane',13,10
		dc.b	'file to IFF.',13,10,0
		even

chunky_text:	dc.b	'Converting from APX 8bit-chunky',13,10
		dc.b	'file to IFF.',13,10,0
		even

hicol_text:	dc.b	'Converting from APX 16bit-HiColour',13,10
		dc.b	'file to TARGA.',13,10,0
		even
		

		
		section	text
