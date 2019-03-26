*BEFORE COMPILING, you will need 
*to create some sprites in Degas
*format, and a mask file using
*the masker.s listing.
*You will also need a Degas background
*picture. Substitute the pathnames
*of these 3 files in the lines
*labelled sprites, mask and backdrop


*If you want to see the mask 
*and sprites as they are drawn,
*remove the * from the next line
*SHOW_DRAW	EQU	1
*press a key to show the next redraw



stacksize equ $1000
	include	gmdosmac.i
	include	xbiosmac.i
	include	biosmac.i

	move.l	4(a7),a3
	move.l	#ourstack+(stacksize*2),a7	
	bsr	initialise_program	
read_only	equ	0
dont_change	equ	-1
init_ok	bsr	set_2_screens	
	Getrez			
				
	move.w	d0,our_rez	
				
				
	bsr	is_rez_ok
	beq	rez_ok
	move.l	#res_error,a1	
	bra	print_error	

rez_ok	bsr	load_palette
	Setpalette	#our_palette
	bsr	load_file
	bsr	init_blit

	IFD	SHOW_DRAW
	move.l	address_1st_screen,a0
	bsr	redraw_screen
	ENDC
x_start	equ	80	These are the 
y_start	equ	130	initial coordinates
			*for the 
			*sprites

	move.w	#x_start,d4
	move.w	#y_start,d5


*x_fr and y_fr define the coordinates
*of the sprite in the sprite picture
*if you are using more than one
*sprite for animation etc,
*you're program will need to calculate
*the coordinates of the relevant
*sprite and place the values in
*S_XMIN and S_YMIN 


x_fr	equ	10	*Try other
y_fr	equ	10	*values
main_loop
	IFD	SHOW_DRAW
	Vsync
	Setscreen	 #dont_change,address_2nd_screen,address_1st_screen
	ENDC
	move.l	address_2nd_screen,a0
	bsr	redraw_screen
	move.w	#x_fr,S_XMIN
	move.w	#y_fr,S_YMIN
	move.w	d4,D_XMIN
	move.w	d5,D_YMIN
	move.l	#mask+34,S_FORM
	move.l	address_2nd_screen,D_FORM
	move.l	#$01010101,OP_TAB
	lea	blit,a6
	dc.w	$a007
	IFD	SHOW_DRAW
	Bconin	#2
	ENDC
	move.l	#sprites+34,S_FORM
	move.l	address_2nd_screen,D_FORM
	move.l	#$07070707,OP_TAB
	lea	blit,a6
	dc.w	$a007
	IFD	SHOW_DRAW
	Bconin	#2
	ENDC
	Vsync
	Setscreen	 #dont_change,address_2nd_screen,address_1st_screen
	movem.l	address_1st_screen,a0-a1	get our two screens
	exg	a0,a1				swap them
	movem.l	a0-a1,address_1st_screen	and save them
	subq.w	#1,d5
	subq.w	#1,d4
	bne	main_loop
	Bconin	#2
	Setpalette	#old_palette
	Setscreen	 #dont_change,address_1st_screen,address_1st_screen
				
	Pterm	#0
	
redraw_screen
*copies backdrop_buffer to screen
*on entry a0 contains address of screen to be redrawn
	move.l	#backdrop_buffer,a1
	add.l	#32000,a0
	add.l	#32000,a1
	move.w	#32000/4-1,d3
move_screen
	move.l	-(a1),-(a0)
	dbra	d3,move_screen
	rts
	
set_2_screens
	Logbase		*Macro that returns the address of the logical
			*screen in d0
	move.l	d0,address_1st_screen	*save it for later
	move.l	#second_screen,d0

	addi.l	#256,d0			*These two commands ensure the new
	andi.l	#$ffffff00,d0		*screen begins on a 256 byte
					*boundary (ie divisible exactly
					*by 256). Early versions of TOS 					*expect this.
	move.l	d0,address_2nd_screen	*save it for later
	rts

is_rez_ok 	Fopen	#read_only,#backdrop
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

init_blit
	lea	blit,a3
	move.w	#$10,(a3)+
	move.w	#$10,(a3)+
	move.w	#$04,(a3)+
	move.w	#$01,(a3)+
	move.w	#$0,(a3)+
	move.l	#$01010101,(a3)+
	move.w	#$0,(a3)+
	move.w	#$0,(a3)+
	move.l	#$0,(a3)+
	move.w	#$8,(a3)+
	move.w	#$a0,(a3)+
	move.w	#$2,(a3)+
	move.w	#$80,(a3)+
	move.w	#$80,(a3)+
	move.l	#$0,(a3)+
	move.w	#$8,(a3)+
	move.w	#$a0,(a3)+
	move.w	#$2,(a3)+
	move.l	#$0,(a3)+
	rts
initialise_program	
	move.l	$c(a3),d0	*length of text
	add.l	$14(a3),d0	*length of data
	add.l	$1c(a3),d0	*length of BSS
	add.l	#$100,d0	*length of basepage
	Mshrink	d0,a3		*Macro to return unwanted memory
	rts
*incbin is an easy way of including
*sprite data in your programs
*The sprites become part of the 
*compiled program and don't have
*to be loaded from disk
sprites	incbin	A:\MYSPRITE.pi1
mask	incbin	A:\MYMASK.msk
	data
backdrop	dc.b	'A:\BACKDROP.PI1',0
init_error	dc.b	'Error while initialising the program',0
file_error	dc.b	'Error reading file',0
res_error	dc.b	'We are in the wrong resolution for that picture',0
	bss
**************************
*KEEP THESE TOGETHER
blit	
B_WD	ds.w	1
B_HT	ds.w	1
	ds.w	1
	ds.w	1
	ds.w	1
OP_TAB	ds.l	1
S_XMIN	ds.w	1
S_YMIN	ds.w	1
S_FORM	ds.l	1
	ds.w	1
	ds.w	1
	ds.w	1
D_XMIN	ds.w	1
D_YMIN	ds.w	1
D_FORM	ds.l	1
	ds.w	1
	ds.w	1
	ds.w	1
	ds.l	1
	ds.w	1
	ds.w	1
	ds.w	1
	ds.w	1
	REPT	12
	ds.w	1
	ENDR
*********************************
	even
backdrop_buffer	ds.b	32066
error_number	ds.w	1
our_rez	ds.w	1
**************************
*KEEP THESE TOGETHER
address_1st_screen	ds.l	1
address_2nd_screen	ds.l	1
**************************
second_screen	ds.b	32000+256
filehandle	ds.w	1	
degas_res	ds.w	1
our_palette	ds.w	16
old_palette	ds.w	16
ourstack	ds.w	stacksize