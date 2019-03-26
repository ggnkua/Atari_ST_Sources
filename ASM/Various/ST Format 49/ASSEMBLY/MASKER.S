*Substitute the name of the Degas sprite file
*and the destination mask file in the lines 
*backdrop	dc.b	'A:\sprites.PI1',0
*mask_file	dc.b	'A:\mymask.msk',0
*below
*Or you can write your own file select
*routine to input the file names

stacksize equ $1000
	include	gmdosmac.i
	include	xbiosmac.i
	include	biosmac.i

	move.l	4(a7),a3
	move.l	#ourstack+(stacksize*2),a7	
	bsr	initialise_program	
read_only	equ	0
dont_change	equ	-1
 
				
	bsr	is_rez_ok
	bsr	load_palette
	bsr	load_file

here
	lea	backdrop_buffer,a0
	lea	mask_buffer,a1
	move.w	#4000-1,d6
next_word
	clr.w	d4
	clr.w	d5
	movem.w	(a0)+,d0-d3
	move.w	#15,d7
next_pixel	
	btst	d7,d0
	bne	mask_it
	btst	d7,d1
	bne	mask_it
	btst	d7,d2
	bne	mask_it
	btst	d7,d3
	bne	mask_it
	bset	d7,d4
mask_it	dbra	d7,next_pixel
	move.w	d4,(a1)+
	move.w	d4,(a1)+
	move.w	d4,(a1)+
	move.w	d4,(a1)+
	dbra	d6,next_word
	Fcreate	#0,#mask_file
	move.w	d0,filehandle
	Fwrite	#degas_res,#2,filehandle	
	Fwrite	#our_palette,#32,filehandle
	Fwrite	#mask_buffer,#32000,filehandle	
	Fclose	filehandle
	Pterm	#0
	
is_rez_ok 
	Fopen	#read_only,#backdrop
	move.w	d0,filehandle	
	bpl	opened_ok	
				
				
				
				
	move.l	#file_error,a1		
	bra	print_error	
opened_ok	Fread	#degas_res,#2,filehandle	
	cmpi.w	#0,d0
	bpl	read_ok
	move.l	#file_error,a1	
	bra	print_error	
read_ok	move.w	degas_res,d0
	cmp.w	our_rez,d0	
	rts

load_palette	
	moveq.w	#0,d2
	move.l	#old_palette,a2	
next_colour
	Setcolor	#dont_change,d2
					
	move.w	d0,(a2)+		
	addq.w	#1,d2			
	cmpi.w	#15,d2			
	bls	next_colour		
					

	Fread	#our_palette,#32,filehandle
						
	cmpi.w	#0,d0
	bpl	read1_ok
	move.l	#file_error,a1	
	bra	print_error	
read1_ok	rts

load_file	Fread	#backdrop_buffer,#32000,filehandle	
								
	cmpi.w	#0,d0
	bpl	read2_ok
	move.l	#file_error,a1	
	bra	print_error	
read2_ok	Fclose	filehandle	
	rts
	
print_error
	move.w	d0,error_number
	Cconws	a1		
				
				
				
				
				
	Bconin	#2
	Pterm	error_number	
	

initialise_program	
	move.l	$c(a3),d0	*length of text
	add.l	$14(a3),d0	*length of data
	add.l	$1c(a3),d0	*length of BSS
	add.l	#$100,d0	*length of basepage
	Mshrink	d0,a3		*Macro to return unwanted memory
	rts
	data
backdrop	dc.b	'A:\sprites.PI1',0
mask_file	dc.b	'A:\mymask.msk',0
init_error	dc.b	'Error while initialising the program',0
file_error	dc.b	'Error reading file',0
res_error	dc.b	'We are in the wrong resolution for that picture',0
	bss
	even
backdrop_buffer	ds.b	32000
mask_buffer	ds.b	32000
error_number	ds.w	1
our_rez	ds.w	1
filehandle	ds.w	1	
degas_res	ds.w	1
our_palette	ds.w	16
old_palette	ds.w	16
ourstack	ds.w	stacksize
