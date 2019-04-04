 ************************************ START **************************************

		include	d:gemmacro.s

* the program proper

start		move.l	4(a7),a3		base page
		move.l	#mystack,a7
		move.l	$c(a3),d0		text len
		add.l	$14(a3),d0		data len
		add.l	$1c(a3),d0		BSS len
		add.l	#$100,d0		basepage
		move.l	d0,-(a7)
		move.l	a3,-(a7)
		clr.w	-(a7)
		move.w	#$4a,-(a7)
		trap	#1			shrink memory
		lea	12(a7),a7

		appl_init
		move.w	d0,ap_id		store the application id

		graf_handle
		move.w	d0,current_handle	Desktop's VDI handle

* start by opening a virtual workstation

		lea	intin,a0
		moveq	#10-1,d0		-1 for DBF
.fill		move.w	#1,(a0)+		most params are 1
		dbf	d0,.fill
		move.w	#2,(a0)+		use RC system

		v_opnvwk			open it

		v_hide_c

********************************************************************************
		include	d:macros.s

************************************ MAIN **************************************
	
* what is the current resolution?  Store it in mode1!
		xbcall	#4,2
		move.w	d0,mode1

* where are the physbase and logbase?  Store them in orig1 and orig2!
		xbcall	#2,2
		move.l	d0,orig1

		xbcall	#3,2
		move.l	d0,orig2
	
* allocates 96k, enough for 3 screens!
		m_alloc	#96256,m_start1

* finds a good starting address for the first screen...
		scr_a_c	m_start1,screen1

* makes screen3 = screen1, then adds 32000 to screen1
		move.l	screen1,screen3
		add.l	#32000,screen1

* makes screen2 = screen1, then adds 32000 to screen1
		move.l	screen1,screen2
		add.l	#32000,screen1

* now we clear all the screens...
		set_scr	#-1,screen3
		v_clrwk	
		set_scr	#-1,screen2
		v_clrwk
		set_scr	#-1,screen1
		v_clrwk

* opens the PI1 file with my screen data...
		f_open	0,f_name1,f_hand1

* gets resolution and sets it...
		f_read	#mode2,#2,f_hand1
		rez	mode2

* gets palette and sets it...
		f_read	#palette,#32,f_hand1
		set_palette palette

* reads in screen data and displays it...only 9600 bytes/60 scan lines
		f_read	screen1,#9600,f_hand1

* closes file...
		f_close	f_hand1

* Sets up MFDB1
		move.l	screen1,address1
		move.w	#320,widthnpix1
		move.w	#200,heightnpix1
		move.w	#20,widthnwords1
		move.w	#1,formflag1
		move.w	#4,numofplanes1
		move.l	#0,reserveda1
		move.l	#0,reservedb1

* Sets up MFDB2
		move.l	screen2,address2
		move.w	#320,widthnpix2
		move.w	#200,heightnpix2
		move.w	#20,widthnwords2
		move.w	#1,formflag2
		move.w	#4,numofplanes2
		move.l	#0,reserveda2
		move.l	#0,reservedb2

* Sets up MFDB3
		move.l	screen3,address3
		move.w	#320,widthnpix3
		move.w	#200,heightnpix3
		move.w	#20,widthnwords3
		move.w	#1,formflag3
		move.w	#4,numofplanes3
		move.l	#0,reserveda3
		move.l	#0,reservedb3

* set up variables for the rasters....
x1		ds.w	1		upper left corner of source
y1		dc.w	1		y1.w = 1 forever and ever....
x2		ds.w	1		lower right corner of source
y2 		dc.w	60		y2.w = 60 forever and ever... 

x3		ds.w	1		upper left x of dest...
y3		ds.w	1		upper left y of dest...
x4		ds.w	1		lower right x of dest...
y4		ds.w	1		lower right y of dest...

* sets up our source values...
		move.w	#10,d4
		move.w	#4,d5
		move.w	#1,x1
		move.w	#49,x2

* sets our destinations to values...
		move.w	#0,x3		x3 = 0
		move.w	#70,y3		y3 = 70
		move.w	#47,x4		x4 = 47
		move.w	#130,y4		y4 = 130


loop1

part1 
* moves visible raster...
		move.w	x1,ptsin
		move.w	y1,ptsin+2
		move.w	x2,ptsin+4
		move.w	y2,ptsin+6

		move.w	x3,ptsin+8
		move.w	y3,ptsin+10
		move.w	x4,ptsin+12
		move.w	y4,ptsin+14
 	
		vro_cpyfm #3,#mfdb1,#mfdb2  

		set_scr	screen2,screen3
		xbcall	#37,2
		xbcall	#37,2
		xbcall	#37,2
		v_clrwk   

* swaps screen values...
		move.l	screen3,dummyL
		move.l	screen2,screen3
		move.l	dummyL,screen2

* adjusts a values in MFDB2 and MFDB3 for the screen...
		move.l	screen2,address2
		move.l	screen3,address3

* waits for keypress...
* 		inkey 

* moves the window in the source raster...	
		add.w	#49,x1
		add.w	#49,x2

* adds to destination...
		add.w	#4,x3
		add.w	#4,x4

	  	cmp.w	#319,x4
		bge	termn8

* loops until d5 is content with life...
		dbra	d5,loop1


* resets the screen variables...
		sub.w	#98,x1
		sub.w	#98,x2
		move.w	#2,d5
       
loop2

* creates a new raster!
		move.w	x1,ptsin
		move.w	y1,ptsin+2
		move.w	x2,ptsin+4
		move.w	y2,ptsin+6
	
		move.w	x3,ptsin+8
		move.w	y3,ptsin+10
		move.w	x4,ptsin+12
		move.w	y4,ptsin+14

		vro_cpyfm #3,#mfdb1,#mfdb2
	
		set_scr	screen2,screen3
		xbcall	#37,2
		xbcall	#37,2
		xbcall	#37,2
		v_clrwk
   
* swaps screen values...
		move.l	screen3,dummyL
		move.l	screen2,screen3
		move.l	dummyL,screen2

* adjusts a values in MFDB2 and MFDB3 for the screen...
		move.l	screen2,address2
		move.l	screen3,address3
 
* waits for keypress...
*		inkey

* moves the window in the source raster...	
		sub.w	#49,x1
		sub.w	#49,x2

* adds to destination...
		add.w	#4,x3
		add.w	#4,x4

		cmp.w	#319,x4
		bge	termn8

* loops until d5 is content with life...
		dbra	d5,loop2
	
* resets source info...
		move.w	#1,x1
		move.w	#48,x2
		move.w	#4,d5

		dbra	d4,loop1

termn8	
		m_free	m_start1     
		set_palette palinfo
		set_scr	orig1,orig2
		rez	#1
		bra	terminate

********************************************************************************
		include	d:errors.s
		include	d:terminat.s

********************************************************************************

		SECTION	DATA

* The six files I will be messing with......

f_name1		dc.b	'\run_man.pi1',0

* Stuff for my kinda online monitoring....by seeing output as i go!

crlf		dc.b	13,10,0			values for a cr/lf 

* Variable containing some generic palette data for the editor...

palinfo		dc.w	$777,$700,$070,$000,$000,$000,$000,$000
		dc.w	$000,$000,$000,$000,$000,$000,$000,$000

* global constants

	SECTION	BSS
********************************************************************************

* Used in the application's "startup" sequence....vroom!

ap_id		ds.w 	1

		ds.l	100		stack space

mystack		ds.w	1		(stacks go backwards)

********************************************************************************
* Used for m_alloc and m_free calls.  I define as many of these as I think
* I will need.....3 is about the maximum for what I plan to do!

ram_free	ds.l	1		amount of RAM in bytes

m_start1	ds.l	1		address of first m_alloc call
m_start2	ds.l	1		address of 2nd   "    "   "
m_start3	ds.l	1		address of 3rd   "    "   "

m_error		ds.w	1		space for error

********************************************************************************
* Now, some variables for file handling.......
* I don't think I'll personally use more than 6 files at once...

f_hand1		ds.w	1		word for file #1's handle
f_hand2		ds.w	1		"  "  "   "   #2's  "  "
f_hand3		ds.w	1		"  "  "   "   #3's  "  "
f_hand4		ds.w	1		"  "  "   "   #4's  "  "
f_hand5		ds.w	1		"  "  "   "   #5's  "  "
f_hand6		ds.w	1		"  "  "   "   #6's  "  "

fname1		ds.b	13		12 bytes terminated with a 0
	
		even

file_size	ds.l	1

********************************************************************************		
* Now.....to go thru the arduous process of creating the offsets for the 
* Line-A calls.  Sure, I can call stuff thru GEM, but what if I don't want
* to?  Riiiiiiight!

orig1		ds.l	1		ptr to original screen1
orig2		ds.l	1		ptr to original screen2

screen1		ds.l	1		address of screen1
screen2		ds.l	1		address of screen2
screen3		ds.l	1		address of screen3

palette		ds.w	16		pointer to palette
mode1		ds.w	1		space for mode
mode2		ds.w	1		

dummyL		ds.l	1		dummy variable

mfdb1		
address1	ds.l	1
widthnpix1	ds.w	1
heightnpix1	ds.w	1
widthnwords1	ds.w	1
formflag1	ds.w	1		usually 1
numofplanes1	ds.w	1		number of bit planes
reserveda1	ds.w	2		set to 0...reserved
reservedb1	ds.w	2		"   "  "  "  "   "
reservedc1	ds.w	1		"   "  "  "  "   "

mfdb2
address2	ds.l	1
widthnpix2	ds.w	1
heightnpix2	ds.w	1
widthnwords2	ds.w	1
formflag2	ds.w	1		usually 1
numofplanes2	ds.w	1		number of bit planes
reserveda2	ds.w	2		set to 0...reserved
reservedb2	ds.w	2		"   "  "  "  "   "
reservedc2	ds.w	1		"   "  "  "  "   "


mfdb3
address3	ds.l	1
widthnpix3	ds.w	1
heightnpix3	ds.w	1
widthnwords3	ds.w	1
formflag3	ds.w	1		usually 1
numofplanes3	ds.w	1		number of bit planes
reserveda3	ds.w	2		set to 0...reserved
reservedb3	ds.w	2		"   "  "  "  "   "
reservedc3	ds.w	1		"   "  "  "  "   "

* if not linking then include the run-times

	include	d:aeslib.s
	include	d:vdilib.s
