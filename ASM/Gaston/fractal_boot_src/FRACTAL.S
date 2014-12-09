;########################################################################
;#----------------------------------------------------------------------#
;#                                                                      #
;# BOOT-SECTOR FRACTAL LANDSCAPE                (C) 1994 DYNO / GASTON. #
;#                                                                      #
;# v 1.00, 28 August 1996.                                              #
;#                                                                      #
;#----------------------------------------------------------------------#
;########################################################################
;#----------------------------------------------------------------------#
;#                                                                      #
;# HOW DOES IT WORK ?                                                   #
;#                                                                      #
;# To create a fractal landscape, we are going to use a recursive       #
;# process described here :                                             #
;#                                                                      #
;# At the beginning of the program, a big array (corresponding to the   #
;# screen size) is divided into smaller square arrays,                  #
;# each vertex value of every square being initialized with a random    #
;# value. Here is shown a square with the vertex values represented by  #
;# a figure rounded by two parenthesis :                                #
;#                                                                      #
;#  (1)-----(2)                                                         #
;#   |       |                                                          #
;#   |       |                                                          #
;#   |       |                                                          #
;#  (3)-----(4)                                                         #
;#                                                                      #
;# At each step of the recursive process, each square is divided into   #
;# 4 smaller squares (half the size of the square from the previous     #
;# step)                                                                #
;#                                                                      #
;#  (1)--*--(2)                                                         #
;#   |   |   |                                                          #
;#   *---+---*                                                          #
;#   |   |   |                                                          #
;#  (3)--*--(4)                                                         #
;#                                                                      #
;# Then, each new side value (here, a '*') is computed by taking the    #
;# average value of the two opposite vertex values, then adding a       #
;# random perturbation value (its amplitude decreasing with the square  #
;# size). So, we obtain four new value :                                #
;#                                                                      #
;#  (1)--(5)--(2)                                                       #
;#   |    |    |                                                        #
;#  (6)---+---(8)                                                       #
;#   |    |    |                                                        #
;#  (3)--(7)--(4)                                                       #
;#                                                                      #
;# The center value (here, a '+') is computed by taking the average     #
;# value of the four side values, and adding a random perturbation      #
;# value :                                                              #
;#                                                                      #
;#  (1)--(5)--(2)                                                       #
;#   |    |    |                                                        #
;#  (6)--(9)--(8)                                                       #
;#   |    |    |                                                        #
;#  (3)--(7)--(4)                                                       #
;#                                                                      #
;# Then, the process is repeated until a square cannot be divided into  #
;# four smaller squares.                                                #
;# At the end, when all the values are generated, we only have to       #
;# display the map with a visual algorithm, here the map is displayed   #
;# in 2D on the screen, like a road map.                                #
;#                                                                      #
;#----------------------------------------------------------------------#
;########################################################################



;#-------+--------------------------------------------------------------#
;# GEM   | 0 = Boot-sector version, 1 = GEM version                     #
;# DEBUG | 0 = final version, 1 = debug version                         #
;#-------+--------------------------------------------------------------#

GEM	=	1
DEBUG	=	0

	IFEQ	DEBUG-1
	opt	x+
	ENDC
	opt	o+



;########################################################################
;#----------------------------------------------------------------------#
;# Initialisations:                                                     #
;# Switch into supervisor mode, and let a6 point on the data area used  #
;# in this program (see at the bottom of the source).                   #
;#----------------------------------------------------------------------#
;########################################################################

	IFEQ GEM-1
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	movea.l	#area,a6	; Address in Bss section
	ELSE
	movea.l	$432.w,a6	; Beginning of the user memory
	ENDC


	
;########################################################################
;#----------------------------------------------------------------------#
;# Let the screen address be divisible by 256, and a5 point on it.      #
;#----------------------------------------------------------------------#
;########################################################################

	move.l	a6,d0
	clr.b	d0
	add.l	#((512+385*257+256)/256+1)*256,d0
	move.l	d0,a5



;########################################################################
;#----------------------------------------------------------------------#
;# Test if we are on a Falcon ... does not work on ST !                 #
;#----------------------------------------------------------------------#
;########################################################################

	movea.l	$4f2.w,a0
	cmpi.w	#$400,2(a0)
	bge.s	Continue
Not_cool:	RTS		; Also quit if monochrome monitor
Continue:



;########################################################################
;#----------------------------------------------------------------------#
;# Save the screen address, and set the 384*240 true colour mode.       #
;#----------------------------------------------------------------------#
;########################################################################

	IFEQ	DEBUG
	move.l	$44e.w,-(sp)	; Save the screen address

	moveq.w	#$0044,d7		; (modecode=4)=320*200 TC
	move.b	$ffff8006.w,d0	; Monitor type
	lsr.b	#6,d0
	beq.s	Not_cool		; =0: monochrome
	subq.b	#2,d0		; =2: Vga
	bne.s	not_vga
	move.w	#$0114,d7
	move.w	#321,dim_x
	move.w	#6-1,nbr_x
not_vga:
	movea.l	a5,a0
	moveq.l	#-1,d1
	move.w	#384*240/2-1,d0
clrscr0:	move.l	d1,(a0)+
	dbra	d0,clrscr0
	bsr	setscreen
	movea.l	a5,a0
	move.w	#384*240/2-1,d0
clrscr:	clr.l	(a0)+
	dbra	d0,clrscr
	clr.l	$ffff9800.w		; Black background
	ENDC



;########################################################################
;#----------------------------------------------------------------------#
;# Create the colour degrade used to display the landscape.             #
;#----------------------------------------------------------------------#
;########################################################################

	movea.l	a6,a0
	clr.w	d0
	lea	degrade(pc),a1
	moveq.w	#5-1,d2
make_deg:	move.w	(a1)+,d3
	moveq.w	#31-1,d4
interpolate:move.w	d0,(a0)+
	move.w	d0,(a0)+
	add.w	d3,d0
	dbra	d4,interpolate
	dbra	d2,make_deg



;########################################################################
;#----------------------------------------------------------------------#
;# Initialise the height array with the height of the firsts points.    #
;#----------------------------------------------------------------------#
;########################################################################

	lea	512(a6),a1
	move.w	$464.w,d0	; Seed of the random generator
	bset	#0,d0	; Must not be divisible by 2
	move.w	dim_x(pc),d1
	mulu	#63,d1
	moveq.w	#5-1,d6
init_lin:	move.w	nbr_x(pc),d5
init_row:	mulu	#16807,d0
	move.b	d0,(a1)
	lea	64(a1),a1
	dbra	d5,init_row
	lea	-64+1(a1,d1.l),a1
	dbra	d6,init_lin



;########################################################################
;#----------------------------------------------------------------------#
;# And now, from only 6*5=30 points, we compute a splendid full-screen  #
;# fractal landscape.                                                   #
;#----------------------------------------------------------------------#
;########################################################################

	BSR.S	COMPUTE_MAP



;########################################################################
;#----------------------------------------------------------------------#
;# We now display the landscape on the screen, thanks to the height     #
;# array and to the colour degrade.                                     #
;#----------------------------------------------------------------------#
;########################################################################

	lea	512(a6),a0
	movea.l	a5,a1
	clr.w	d7
	move.w	#240-1,d0
display_l:	move.w	dim_x(pc),d1
	subq.w	#2,d1
display_r:	move.b	(a0)+,d7
	move.w	(a6,d7.w*2),(a1)+
	dbra	d1,display_r
	addq.l	#1,a0
	dbra	d0,display_l



;########################################################################
;#----------------------------------------------------------------------#
;# Press space to continue the boot sequence.                           #
;#----------------------------------------------------------------------#
;########################################################################

WAITSPACE:	cmpi.b	#57,$fffffc02.w
	bne.s	WaitSpace



;########################################################################
;#----------------------------------------------------------------------#
;# Restoration of the initial video mode.                               #
;#----------------------------------------------------------------------#
;########################################################################

	IFEQ	DEBUG
	not.l	$ffff9800.w	; White background
	move.l	(sp)+,a5	; Old screen address
	move.w	#$0089,d7
	ENDC
	
	IFEQ	GEM-1
 	bsr.s	setscreen
	clr.w	(sp)
	trap	#1
	ENDC	



;########################################################################
;#----------------------------------------------------------------------#
;# Set the chosen video mode, with d7=modecode and a5=screen address.   #
;#----------------------------------------------------------------------#
;########################################################################

SETSCREEN:	move.w	d7,-(sp)
	move.w	#3,-(sp)
	pea	(a5)
	pea	(a5)
	move.w	#5,-(sp)
	trap	#14
	lea	14(sp),sp
	RTS



;########################################################################
;#----------------------------------------------------------------------#
;# Compute the fractal landscape from the 6*5=30 initial points.        #
;#----------------------------------------------------------------------#
;########################################################################

COMPUTE_MAP:

	moveq.l	#7,d0	; Seed of the 2nd random generator
	moveq.w	#32,d1
	move.w	dim_x(pc),d2
	lsl.w	#5,d2
	moveq.w	#1,d7	; Depth level => 320*256
	clr.w	d5
	clr.w	d6
	moveq.w	#%00111111,d3
	
NEXT_LEVEL:
	lea	512(a6),a4

	move.w	d7,d5	; -(sp) <= 4*2^d7
	lsl.w	#2,d5
	move.w	d5,-(sp)
DO_LIN:
	move.l	a4,a1
	
	move.w	d7,d5	; -(sp) <= 5*2^d7
	mulu	nbr_x(pc),d5
	move.w	d5,-(sp)
DO_ROW:		
	lea	(a1,d2.w),a2
	lea	(a2,d2.w),a3
	suba.l	a0,a0
	
	; (1)
	move.b	(a1,d1.w*2),d5	; d5= Top Right
	move.b	(a1),d6		; d6= Top Left
	add.w	d6,d5
	bsr.s	RANDOM
	move.b	d5,(a1,d1.w)
	; (2)
	move.b	(a3),d5		; d5= Bottom Left
	add.w	d6,d5
	bsr.s	RANDOM
	move.b	d5,(a2)
	; (4)
	move.b	(a3),d5		; d5= Bottom Left
 	move.b	(a3,d1.w*2),d6	; d6= Bottom Right
	add.w	d6,d5
	bsr.s	RANDOM
	move.b	d5,(a3,d1.w)
	; (3)
	move.b	(a1,d1.w*2),d5	; d5= Top Right
	add.w	d6,d5
	bsr.s	RANDOM
	move.b	d5,(a2,d1.w*2)
	; (5)
	move.w	a0,d5
	lsr.w	#1,d5
	bsr.s	RANDOM
	move.b	d5,(a2,d1.w)
		
	lea	(a1,d1.w*2),a1
	subq.w	#1,(sp)
	bne.s	DO_ROW
	addq.l	#2,sp

	lea	(a4,d2.w*2),a4
	subq.w	#1,(sp)
	bne.s	DO_LIN
	addq.l	#2,sp

	lsr.w	#1,d1	; Width / 2
	lsr.w	#1,d2	; Width*dim_x / 2
	lsr.w	#1,d3

	lsl.w	#1,d7
	cmpi.w	#%01000000,d7
	bne.s	NEXT_LEVEL
	
RANDOM:
	lsr	#1,d5
	addq.l	#4,d0	; New value of the generator
	move.w	d0,d4
	and.w	d3,d4
	sub.w	d1,d4	; Same value of d1 from compute_map
	add.w	d4,d5
	cmpi.w	#255,d5
	bls.s	ok1
	move.w	#255,d5
ok1:	tst.w	d5
	bhs.s	ok2
	clr.w	d5
ok2:	
	add.w	d5,a0
	RTS



;########################################################################
;#----------------------------------------------------------------------#
;# The data.                                                            #
;#----------------------------------------------------------------------#
;########################################################################

	SECTION DATA

degrade:	dc.w	%0000000000100001	;0FF
	dc.w	-%0000000000100001	;000
	dc.w	%0000000000100000	
	dc.w	%0000000000100000	;0F0
	dc.w	%0000100000000001	;FFF

dim_x:	dc.w	385
;# dim_y: 	dc.w	257
nbr_x:	dc.w	7-1
;# nbr_y: 	dc.w	5-1



;########################################################################
;#----------------------------------------------------------------------#
;# This area contains in:                                               #
;# - area+0: Colour degrade (256 words)                                 #
;# - area+512: Heights of all the points of the fractal                 #
;#  ( dim_x * dim_y bytes)                                              #
;# - area+512+dim_x*dim_y+xxx: The screen. (384*240*2 bytes) xxx is     #
;#  computed so that the screen address is divisible by 256             #
;#----------------------------------------------------------------------#
;########################################################################

	SECTION BSS

	IFEQ	GEM-1
area:	ds.b	300000
	ENDC



;########################################################################
;#----------------------------------------------------------------------#
	END
;#----------------------------------------------------------------------#
;########################################################################
	