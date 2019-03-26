*Before assembling, insert the name of your picture file in line 189
*If you are not sure how filepaths work, then make sure your picture
*is in the root directory (not in a folder) of drive A. Otherwise, change
*line 188 accordingly
*When debugging this with MON(st), switch the Screen timer off, (Control P)
*We'll bring you the complete gemdos macros next month, for now we'll
*include a shortened version of gmdosmac.i containing only the calls we 
*need. Simply substitute the new file next month. Make sure these files
*are also in the root directory of drive A.
	include	"a:\gmdosmac.i"
	include	"a:\biosmac.i"
	include	"a:\xbiosmac.i"
*The next few lines assign values to labels. Whenever the compiler comes
*across the label it will substitute the value in the final program, for
*instance 0 will be substituted for read_only. 
*This in no way alters the final program, but it makes the listing easier
*to read, and easier to update if you ever want to change a value.
read_only	equ	0
dont_change	equ	-1
screen		equ	2
keyboard	equ	2
stacksize	equ	100
*The next three commands load the basepage, an area of memory that contains
*information about the size of our program, into a3. The stack pointer (a7)
*is then loaded with the address of the end of the stack - numbers are
*always pushed onto the stack from high memory downwards. The routine
*initialise_program then gives back any memory we don't need to the operating
*system. It is a good idea to include these 3 lines and the routine at the 
*start of all your stand alone programs, (desk accessories are different)
*If you need a larger stack, simply change the value of stacksize above.

	move.l	4(a7),a3
	move.l	#ourstack+(stacksize*2),a7	*The compiler will do the 
						*maths 	for you
	bsr	initialise_program	
	cmpi.w	#0,d0		*if there was a problem in initialise_program
				*d0 will not contain 0
				*cmpi = compare immediate, only if you use #
*from here on, I'll put the compare command in the routines themselves
*just before the rts
	beq	init_ok		*If it does contain 0, continue
	move.l	#init_error,a1	*Else display error message and exit
	bra	print_error	*branch to the routine that prints the
				*string pointed to by a1, and quits	
*The Atari can have two areas of memory which hold the data for the screen 
*you can only see one of them on your monitor or TV. We will use the one
*you can't see to load the picture, that way you won't see the picture being
*drawn. The two screens are then switched, now you see it, now you don't!
 
init_ok	bsr	set_2_screens	*This routine sets up 2 screens
	Getrez			*This Macro ask TOS what resolution we
				*are running at, high medium or low
	move.w	d0,our_rez	*TOS loads d0 accordingly - we just save
				*the number at the address our_rez, below.
				*high = 2 medium = 1 low = 0
*The first word (2bytes) of the Degas file tell us which resolution the 
*picture is. The routine is_rez_ok checks we are in the same resolution
	bsr	is_rez_ok
	beq	rez_ok
	move.l	#res_error,a1	
	bra	print_error	*display error message and quit

*Now we load the palette from the Degas file into memory
rez_ok	bsr	load_palette
*This is a Macro to set the palette to the Degas palette, stored at
*the address our_palette, below.
	Setpalette	#our_palette
*Now the picture data itself is loaded into the invisible screen
	bsr	load_file
*Vsync, another Macro which waits until the screen has been redrawn
*which happens 50 to 70 times a second. This makes the screen switch
*smoother
	Vsync
*And we swap the screens. The Setscreen Macro takes three parameters,
*the first alters the resolution, the second the physical (visible)
*screen, and the third the logical (invisible) screen. All drawing
*operations, for instance:-
*	Bconout	#'A',#screen
*which prints the letter A on the screen, are drawn on the logical 
*screen, you can only see the drawing take place if the physical and 
*logical screens are set to the same address.
*If a parameter of -1 is used for any of these, then the current setting
*is unaltered. Notice how we have defined dont_change to equal -1 at the
*top of our program, making the listing easier to read.
	Setscreen	#dont_change,address_2nd_screen,address_1st_screen
*Now we wait for a keypress. Again we have defined keyboard equ 2 for 
*easier reading
	Bconin	#keyboard
*Before quitting we can restore the old screen and palette
	Setpalette	#old_palette
	Setscreen	#dont_change,address_1st_screen,address_1st_screen
	Pterm	#0	

initialise_program	
	move.l	$c(a3),d0	*length of text
	add.l	$14(a3),d0	*length of data
	add.l	$1c(a3),d0	*length of BSS
	add.l	#$100,d0	*length of basepage
	Mshrink	d0,a3		*Macro to return unwanted memory
	rts
	
	
set_2_screens
	Logbase		*Macro that returns the address of the logical
			*screen in d0
	move.l	d0,address_1st_screen	*save it for later
	move.l	#second_screen,d0

	addi.l	#256,d0			*These two commands ensure the new
	andi.l	#$ffffff00,d0		*screen begins on a 256 byte
					*boundary (ie divisible exactly
					*by 256). Early versions of TOS 
					*expect this.
	move.l	d0,address_2nd_screen	*save it for later
	rts

is_rez_ok 
	Fopen	#read_only,#filename
	move.w	d0,filehandle	*the move instruction also alters the flags
	bpl	opened_ok	*so we can check if d0 contained a negative
				*error number simply by moving its contents.
				*bpl means branch plus, ie if d0 is positive.
				*(we'll deal with positive and negative
				*numbers later in the series
	move.l	#file_error,a1		
	bra	print_error	*display error message and quit
opened_ok	Fread	#degas_res,#2,filehandle	*read the first
						*2 bytes of our file
						*these contain the 
						*resolution
	cmpi.w	#0,d0
	bpl	read_ok
	move.l	#file_error,a1	
	bra	print_error	*display error message and quit
read_ok	move.w	degas_res,d0
	cmp.w	our_rez,d0	*check if they are the same	
	rts

load_palette	
*This routine begins by reading all 16 colour registers, and storing the 
*result. d2 contains the colour register we want to read. By 
*incrementing it each time round, we can ask for registers 0 to 16.
*Note the use of (a2)+ to store each colour at the next address.	
	moveq.w	#0,d2
	move.l	#old_palette,a2	
next_colour
	Setcolor	#dont_change,d2		*Macro to read the current
						*palette settings
	move.w	d0,(a2)+		*save this colour
	addq.w	#1,d2			*ask for next colour
	cmpi.w	#15,d2			*is d2 greater than 15
	bls	next_colour		*branch back if d2 lower or same
					*as 15

	Fread	#our_palette,#32,filehandle	*The next 32 bytes contain
						*palette information
	cmpi.w	#0,d0
	bpl	read1_ok
	move.l	#file_error,a1	
	bra	print_error	*display error message and quit
read1_ok	rts

load_file	Fread	address_2nd_screen,#32000,filehandle	*now load 
								*the picture
	cmpi.w	#0,d0
	bpl	read2_ok
	move.l	#file_error,a1	
	bra	print_error	*display error message and quit
read2_ok	Fclose	filehandle	*Close the file now we've finished
					*with it
	rts
	
print_error
	move.w	d0,error_number
	Cconws	a1		*Macro that prints a null-terminated string
				*(a collection of characters ending 
				*with ASCII zero)
				*a1 contains the address of the string
				*See the first 4 lines of data below for 
				*examples of null-terminated strings
	Bconin	#keyboard	*Macro that waits for a keypress
	Pterm	error_number	*Macro to quit, returning the error_number
				*to whatever called this program
				*(Neodesk for instance)
	

	data
*this section contains our null-terminated strings
filename	dc.b	'A:\*.*',0	*Replace *.* with the name of 
					*the picture file
init_error	dc.b	'Error while initialising the program',0
file_error	dc.b	'Error reading file',0
res_error	dc.b	'We are in the wrong resolution for that picture',0
	bss
error_number	ds.w	1
our_rez	ds.w	1
address_1st_screen	ds.l	1
address_2nd_screen	ds.l	1
second_screen	ds.b	32000+256
filehandle	ds.w	1	
degas_res	ds.w	1
our_palette	ds.w	16
old_palette	ds.w	16
ourstack	ds.w	stacksize
