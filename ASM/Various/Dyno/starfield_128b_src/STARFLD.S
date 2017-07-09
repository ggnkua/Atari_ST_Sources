;########################################################################
;#----------------------------------------------------------------------#
;#						#
;# 128-BYTES PALETTE STARFIELD		       (C) 1996 DYNO.	#
;#						#
;# v 1.00, 28 August 1996.				#
;#						#
;#----------------------------------------------------------------------#
;########################################################################
;#----------------------------------------------------------------------#
;#						#
;# HOW DOES IT WORK ?					#
;#						#
;# This starfield is a palette effect, that is to say you obtain this	#
;# effect by changing the palette each VBL.			#
;# 						#
;# First of all, the screen is filled with the same pattern on every	#
;# line, randomly left or right shifted. The pattern consist of a	#
;# degrade from color 1 to color 255 then back from color 1 to color	#
;# 255 :						#
;#						#
;#	+-----+-----+-   -+-----+-----+-----+-----+-		#
;#	| 001 | 002 | ... | 254 | 255 | 001 | 002 | ...		#
;#	+-----+-----+-   -+-----+-----+-----+-----+-		#
;#						#
;# Then, each star is represented by an index value between 1 and 255.	#
;# At each VBL, the color indexed by this value takes a value	#
;# corresponding to the star plane (dark grey for the background plane,	#
;# white for the foreground plane), then the index is decremented (by a	#
;# value depending on the current plane) to obtain the scrolling	#
;# effect.						#
;#						#
;# With this technique, when you move only one star in the palette, you	#
;# can see one or more stars per line, that is to say a lot on the	#
;# whole screen. By managing only 12 stars on a 320x200 screen,	#
;# 12*(320/256)*200 = 3000 stars are displayed ; By managing 24 stars	#
;# a 640*480 screen, 24*(640/256)*480 = 28800 stars are displayed.	#
;#						#
;#----------------------------------------------------------------------#
;########################################################################


;#------------+---------------------------------------------------------#
;# DEBUG      | 0 = final version, 1 = debug version		#
;# SCR_WIDTH  | Screen width in pixels			#
;# SCR_HEIGHT | Screen height in pixels (must be <= 1024)		#
;# NB_PLANES  | Number of star planes			#
;# NB_STARS   | Number of stars per line (multiple of 4,		#
;#	  |	must be <= 1024)			#
;# SEED       | Seed of the random number generator		#
;# COLOR_INC  | For each plane, the color increments from dark grey to	#
;#	  |	white				#
;#------------+---------------------------------------------------------#

DEBUG	= 0		
SCR_WIDTH	= 384
SCR_HEIGHT	= 240		
NB_PLANES	= 4		
NB_STARS	= NB_PLANES*3	
SEED	= 23		
COLOR_INC	= $3F3F3F3F	

	IFEQ	DEBUG-1
	opt	x+
	ELSE
	opt	x-
	ENDC
	opt	o+
	opt	p=68030


;########################################################################
;#----------------------------------------------------------------------#
;# Switch into supervisor mode ...				#
;#----------------------------------------------------------------------#
;########################################################################

	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	
;#----------------------------------------------------------------------#
;# If debug mode, install the new context (video-mode) ...		#
;#----------------------------------------------------------------------#

	IFEQ	DEBUG-1
	addq.l	#6,sp
	move.l	$44e.w,old_scr
	move.l	#scr,d2
	clr.b	d2
	add.l	#256,d2
	move.w	#%1000011,-(sp)
	move.w	#3,-(sp)
	move.l	d2,-(sp)
	move.l	d2,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	14(sp),sp
	clr.l	$ffff9800.w
	ENDC

;########################################################################
;#----------------------------------------------------------------------#
;# Some important initialisation ...			#
;#----------------------------------------------------------------------#
;########################################################################

	dc.w	$a000		; Initialize Line-A
	movem.l	(a0),a1-a4		; a3=intin a4=ptsin
	moveq.w	#SEED,d5		; Initial seed
	clr.l	d6
	not.b	d6		; d6.l=$000000FF
	dc.w	$a00a		; Hide mouse cursor

;########################################################################
;#----------------------------------------------------------------------#
;# Display the randomly shifted color-degrades on the screen.	#
;# At the same time, initialize the star indexes.		#
;#----------------------------------------------------------------------#
;########################################################################

	IFEQ	DEBUG-1
	bsr	LOAD_COORD
	ELSE
	bsr.s	CLR_PALETTE
	ENDC

	move.w	#SCR_HEIGHT-1,d4
ALL_THE_LINES:	
	mulu	#3,d5
	clr.b	(a5)+
	move.b	d5,(a5)+

	move.w	#SCR_WIDTH-1,d3
ONE_LINE:	move.w	d5,(a3)
	movem.w	d3-d4,(a4)
	dc.w	$a001
inc_color:	addq.b	#1,d5
	beq.s	inc_color
	DBRA	D3,ONE_LINE
	
	DBRA	D4,ALL_THE_LINES

;########################################################################
;#----------------------------------------------------------------------#
;# Beginning of the demo, wait for the VBL ...			#
;#----------------------------------------------------------------------#	
;########################################################################

REPEAT:	move.w	#37,(sp)
	trap	#14

;########################################################################
;#----------------------------------------------------------------------#	
;# Display the palette, and compute the new one ...		#
;#----------------------------------------------------------------------#	
;########################################################################

	bsr.s	CLR_PALETTE
	
	moveq.w	#NB_PLANES-1,d2
PLANE:	
	add.l	#COLOR_INC,d0

	moveq.w	#NB_STARS/NB_PLANES-1,d1
DISPLAY:	move.w	(a5),d7
	move.l	d0,(a1,d7.w*4)

	addq.w	#NB_PLANES,d7
	sub.w	d2,d7
	cmp.w	d6,d7
	bls.s	next
	sub.w	d6,d7
next:	
	move.w	d7,(a5)+
	DBRA	D1,DISPLAY
	
	DBRA	D2,PLANE

;#----------------------------------------------------------------------#
;# If debug mode, we test the end of the program ...		#
;#----------------------------------------------------------------------#

	IFEQ	DEBUG-1
	cmpi.b	#57,$fffffc02.w	
	beq.s	End_repeat		
	ENDC

;########################################################################
;#----------------------------------------------------------------------#
;# Let's wrap, there is no way to quit this demo ...		#
;#----------------------------------------------------------------------#
;########################################################################

	BRA.S	REPEAT

;#----------------------------------------------------------------------#
;# If debug mode, we can now quit the program ...		#
;#----------------------------------------------------------------------#	

End_repeat:
	IFEQ	DEBUG-1
	dc.w	$a009
	move.w	#1,-(sp)
	move.l	old_scr(pc),-(sp)
	move.l	old_scr(pc),-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	clr.w	(sp)
	trap	#1
	ENDC

;########################################################################
;#----------------------------------------------------------------------#	
;# Clear the palette : all the colors take the black (=0) value ...	#
;#----------------------------------------------------------------------#
;########################################################################

CLR_PALETTE:lea	$ffff9C00.w,a1
	move.l	d6,d0
coppal:	clr.l	-(a1)
	dbra	d0,coppal
	
LOAD_COORD:	lea	coordinates(pc),a5
	RTS

;########################################################################
;#----------------------------------------------------------------------#	
;# The star indexes in the palette ...			#
;#----------------------------------------------------------------------#	
;########################################################################

	SECTION BSS

coordinates:ds.w	1024

;#----------------------------------------------------------------------#	
;# Old screen address, and memory area used to store the new screen ...	#
;#----------------------------------------------------------------------#	

	IFEQ	DEBUG-1
old_scr:	ds.l	1
scr:	ds.b	SCR_WIDTH*SCR_HEIGHT*2
	ENDC



;########################################################################
;#----------------------------------------------------------------------#	
	END
;#----------------------------------------------------------------------#	
;########################################################################
	