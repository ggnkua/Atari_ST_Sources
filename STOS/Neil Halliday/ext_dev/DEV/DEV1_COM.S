* STORM Development Extension (Part I) - COMPILER VERSION 0.4(beta)
*
* WRITTEN BY NEIL HALLIDAY 1995
* (C)1995 STORM Developments.
*
* FULL VERSION!
*
* SET UP SYSTEM VARIABLES

debut	equ	$92c
error	equ	$93c
flagem	equ	$9a0

* Define extension addresses

start	dc.l	para-start		; parameter definitions
	dc.l	data-start		; reserve data area for program
	dc.l	lib1-start		; start of library
	
catalog	dc.w	lib2-lib1		; length of routine 1 (hardscreen)
	dc.w	lib3-lib2		; length of routine 2 (padup)
	dc.w	lib4-lib3		; length of routine 3 (hardlinewid)
	dc.w	lib5-lib4		; length of routine 4 (paddown)
	dc.w	lib6-lib5		; length of routine 5 (hardpixel)
	dc.w	lib7-lib6		; length of routine 6 (padleft)
	dc.w	lib8-lib7		; length of routine 7 (auxout)
	dc.w	lib9-lib8		; length of routine 8 (padright)
	dc.w	lib10-lib9		; length of routine 9 (hardrest)
	dc.w	lib11-lib10		; length of routine 10 (padpause)
	dc.w	lib12-lib11		; length of routine 11 (csticks on)
	dc.w	lib13-lib12		; length of routine 12 (padafire)
	dc.w	lib14-lib13		; length of routine 13 (csticks off)
	dc.w	lib15-lib14		; length of routine 14 (padbfire)
	dc.w	lib16-lib15		; length of routine 15 (screensaver on)
	dc.w	lib17-lib16		; length of routine 16 (padcfire)
	dc.w	lib18-lib17		; length of routine 17 (screen saver off)
	dc.w	lib19-lib18		; length of routine 18 (padoption)
	dc.w	lib20-lib19		; length of routine 19 (set clock)
	dc.w	lib21-lib20		; length of routine 20 (padbutton)
	dc.w	lib22-lib21		; length of routine 21 (hardscroll)
	dc.w	lib23-lib22		; length of routine 22 (cstick up)
	dc.w	lib24-lib23		; length of routine 23 (auxset)
	dc.w	lib25-lib24		; length of routine 24 (cstick down)
	dc.w	lib26-lib25		; length of routine 25 (bfcopy)
	dc.w	lib27-lib26		; length of routine 26 (cstick left)
	dc.w	lib28-lib27		; length of routine 27 (bfskopy) 
	dc.w	lib29-lib28		; length of routine 28 (cstick right)
	dc.w	lib30-lib29		; length of routine 29 (bscancopy) 
	dc.w	lib31-lib30		; length of routine 30 (cstick fire)
	dc.w	lib32-lib31		; length of routine 31 (bscanskopy) 
	dc.w	libex-lib32		; length of routine 32 (auxstat)
			
para	dc.w	32			; number of library routines
	dc.w	32			; number of extension commands

	dc.w	l001-para		; hardscreen 
	dc.w	l002-para		; padup
	dc.w	l003-para		; hardlinewid
	dc.w	l004-para		; paddown
	dc.w	l005-para		; hardpixel
	dc.w	l006-para		; padleft
	dc.w	l007-para		; auxout
	dc.w	l008-para		; padright
	dc.w	l009-para		; hardreset
	dc.w	l010-para		; padpause
	dc.w	l011-para		; csticks on		
	dc.w	l012-para		; padafire
	dc.w	l013-para		; csticks off
	dc.w	l014-para		; padbfire
	dc.w	l015-para		; screensaver on
	dc.w	l016-para		; padcfire
	dc.w	l017-para		; screensaver off
	dc.w	l018-para		; padoption
	dc.w	l019-para		; setclock
	dc.w	l020-para		; padbutton 
	dc.w	l021-para		; hardscroll		 
	dc.w	l022-para		; cstick up  
	dc.w	l023-para		; auxset		 
	dc.w	l024-para		; cstick down 
	dc.w	l025-para		; bfcopy
	dc.w	l026-para		; cstick left 
	dc.w	l027-para		; bfskopy
	dc.w	l028-para		; cstick right 
	dc.w	l029-para		; bscancopy
	dc.w	l030-para		; cstick fire 
	dc.w	l031-para		; bscanskopy
	dc.w	l032-para		; auxstat

* Parameter defininitions

I	equ	0
F	equ	$40
S	equ	$80

* "," forces a comma between any commands
* 1   indicates the end of one set of parameters for an instrucion
* 1,0 indicates the end of the commands entire parameter definition

l001	dc.b	0,I,1,1,0		; Hardscreen
l002	dc.b	I,I,1,1,0		; Pad up
l003	dc.b	0,I,1,1,0		; Hardlinewid
l004	dc.b	I,I,1,1,0		; Pad down
l005	dc.b	0,I,1,1,0		; Hardpixel
l006	dc.b	I,I,1,1,0		; Pad left
l007	dc.b	0,I,1,1,0		; Auxout
l008	dc.b	I,I,1,1,0		; Pad right
l009	dc.b	0,1,1,0			; Hardreset
l010	dc.b	I,I,1,1,0		; Pad pause
l011	dc.b	0,1,1,0			; Csticks on
l012	dc.b	I,I,1,1,0		; Pad afire
l013	dc.b	0,1,1,0			; Csticks off
l014	dc.b	I,I,1,1,0		; Pad bfire
l015	dc.b	0,1,1,0			; Screensaver on
l016	dc.b	I,I,1,1,0		; Pad cfire
l017	dc.b	0,1,1,0			; Screensaver off
l018	dc.b	I,I,1,1,0		; Pad option
l019	dc.b	0,1,1,0			; Set clock
l020	dc.b	I,I,1,1,0		; Pad button
l021	dc.b	0,I,",",I,",",I,","
	dc.b      I,",",I,",",I,1,1,0	; Hardscroll			
l022	dc.b	I,I,1,1,0		; Cstick up		
l023	dc.b	0,I,",",I,1,1,0		; Auxset			
l024	dc.b	I,I,1,1,0		; Cstick down		
l025	dc.b	0,I,",",I,1,1,0		; Bfcopy
l026	dc.b	I,I,1,1,0		; Cstick left		
l027	dc.b	0,I,",",I,1,1,0		; Bfskopy
l028	dc.b	I,I,1,1,0		; Cstick right	
l029	dc.b	0,I,",",I,",",I,","
	dc.b	  I,",",I,1,1,0		; Bscancopy
l030	dc.b	I,I,1,1,0		; Cstick fire
l031	dc.b	0,I,",",I,",",I,","
	dc.b	  I,",",I,1,1,0		; Bscanskopy
l032	dc.b	I,1,1,0			; Auxstat	


* End of parameter definition

	even
	
* Initialisation section
* This code is loaded into memory during initialisation
* It can be accessed using address placed in the DEBUT variable

data	bra	init

init	lea	end(pc),a2		; load position of end into A2
	rts
	
end	rts



* Extension library



**     COMMAND:	HARDSCREEN
**  	SYNTAX:	HARDSCREEN addr
**
** DESCRIPTION:	Set STE hardware scroll screen address

lib1:	dc.w	0			; no library routines
	move.l	(a6)+,d0		; Get screen address
	move.l	d0,d1			; Copy it
	move.l	d0,d2
	
	andi.l	#$FF0000,d0		; Mask 8 bit data
	andi.l	#$ff00,d1
	andi.l	#$ff,d2
	
	ror.l	#8,d0			; Adjust >255 values
	ror.l	#8,d0			; d0 is done twice to make 16
	ror.l	#8,d1
	
	move.b	d0,$ff8201		; Store values
	move.b	d1,$ff8203
	move.b	d2,$ff820d
	rts
	even
	
	
**     COMMAND:	PADUP
**  	SYNTAX:	x=PADUP(n)
**
** DESCRIPTION:	Returns if the pad in STE Analogue port N is up.
**		Values returned are TRUE/FALSE (-1/0)

lib2	dc.w	0			; No library calls

	move.l	(a6)+,d4		; Get port number
	move.b	d4,d0
	clr.l	d3			; Clear return variable
	clr.w	d1			; Clear d1
	lea	$ff9202,a0
	move.w  #%11101110,(a0)		; Set Directions
	move.w  (a0),d1			; Read 

	cmp.b	#0,d0			; Port B?
	bne	.portb
	
	btst	#8,d1			; Port A up?
	beq	.yes
	move.l	#0,d3			; No, False
	bra	.exit
			
.portb
	btst	#12,d1			; Port B up?
	beq	.yes

	move.l	#0,d3
	bra	.exit
				
.yes	move.l	#-1,d3			; Return True
.exit	move.l	d3,-(a6)		; Return
	rts
	even



**     COMMAND:	HARDLINEWID
**  	SYNTAX:	HARDLINEWID
**
** DESCRIPTION:	Sets the STE overlength line width

lib3	dc.w	0			; no library calls
	move.l	(a6)+,d0		; Get line width
	move.b	d0,$ff820f		; Send to hardware
	rts
	even
	
	
**     COMMAND:	PADDOWN
**  	SYNTAX:	x=PADDOWN(n)
**
** DESCRIPTION:	Returns if the pad in STE Analogue port N is down.
**		Values returned are TRUE/FALSE (-1/0)

lib4	dc.w	0			; No library calls

	move.l	(a6)+,d4		; Get port number
	move.b	d4,d0
	clr.l	d3			; Clear return variable
	clr.w	d1			; Clear d1
	lea	$ff9202,a0
	move.w  #%11101110,(a0)		; Set Directions
	move.w  (a0),d1			; Read 

	cmp.b	#0,d0			; Port B?
	bne	.portb
	
	btst	#9,d1			; Port A?
	beq	.yes
	move.l	#0,d3			; No, False
	bra	.exit
			
.portb
	btst	#13,d1			; Port B?
	beq	.yes

	move.l	#0,d3
	bra	.exit
				
.yes	move.l	#-1,d3			; Return True
.exit	move.l	d3,-(a6)		; Return
	rts
	even



**     COMMAND:	HARDPIXEL
**  	SYNTAX:	HARDPIXEL
**
** DESCRIPTION:	Sets the STE pixel scroll offset

lib5	dc.w	0			; no library calls
	move.l	(a6)+,d0		; Get scroll offset
	move.b	d0,$ff8265		; Send to hardware
	rts
	even

	
**     COMMAND:	PADLEFT
**  	SYNTAX:	x=PADLEFT(n)
**
** DESCRIPTION:	Returns if the pad in STE Analogue port N is LEFT.
**		Values returned are TRUE/FALSE (-1/0)

lib6	dc.w	0			; No library calls

	move.l	(a6)+,d4		; Get port number
	move.b	d4,d0
	clr.l	d3			; Clear return variable
	clr.w	d1			; Clear d1
	lea	$ff9202,a0
	move.w  #%11101110,(a0)		; Set Directions
	move.w  (a0),d1			; Read 

	cmp.b	#0,d0			; Port B?
	bne	.portb
	
	btst	#10,d1			; Port A?
	beq	.yes
	move.l	#0,d3			; No, False
	bra	.exit
			
.portb
	btst	#14,d1			; Port B?
	beq	.yes

	move.l	#0,d3
	bra	.exit
				
.yes	move.l	#-1,d3			; Return True
.exit	move.l	d3,-(a6)		; Return
	rts
	even



**     COMMAND:	AUXOUT
**  	SYNTAX:	AUXOUT val
**
** DESCRIPTION:	Send a byte to the AUX port
**		


lib7:	dc.w	0			; No library calls
	move.l	(a6)+,d0		; Get byte
	move.w	d0,-(sp)		; Byte
	move.w	#1,-(sp)		; AUX
	move.w	#3,-(sp)		; Bconout
	trap	#13
	lea	6(sp),sp
	rts
	even	
	
	
	
**     COMMAND:	PADRIGHT
**  	SYNTAX:	x=PADRIGHT(n)
**
** DESCRIPTION:	Returns if the pad in STE Analogue port N is right.
**		Values returned are TRUE/FALSE (-1/0)

lib8	dc.w	0			; No library calls

	move.l	(a6)+,d4		; Get port number
	move.b	d4,d0
	clr.l	d3			; Clear return variable
	clr.w	d1			; Clear d1
	lea	$ff9202,a0
	move.w  #%11101110,(a0)		; Set Directions
	move.w  (a0),d1			; Read 

	cmp.b	#0,d0			; Port B?
	bne	.portb
	
	btst	#11,d1			; Port A?
	beq	.yes
	move.l	#0,d3			; No, False
	bra	.exit
			
.portb
	btst	#15,d1			; Port B?
	beq	.yes

	move.l	#0,d3
	bra	.exit
				
.yes	move.l	#-1,d3			; Return True
.exit	move.l	d3,-(a6)		; Return
	rts
	even



**     COMMAND:	HARDRESET
**  	SYNTAX:	HARDRESET
**
** DESCRIPTION:	Reset the STE hardware after a Hardscroll session

lib9:	dc.w	0			; No library calls
	move.b	#0,$ff8265		; Set pixel offset to 0
	move.b	#0,$ff820f		; Set linwidth to 0
	rts



**     COMMAND:	PADPAUSE
**  	SYNTAX:	x=PADPAUSE(n)
**
** DESCRIPTION:	Returns if the pad in STE Analogue port N is pause.
**		Values returned are TRUE/FALSE (-1/0)

lib10	dc.w	0			; No library calls

	move.l	(a6)+,d4		; Get port number
	move.b	d4,d0
	clr.l	d3			; Clear return variable
	clr.w	d1			; Clear d1
	lea	$ff9202,a0
	move.w  #%11101110,(a0)		; Set Directions
	move.b	$ff9201,d1		; Read fire

	cmp.b	#0,d0			; Port B?
	bne	.portb
	
	btst	#0,d1			; Port A?
	beq	.yes
	move.l	#0,d3			; No, False
	bra	.exit
			
.portb
	btst	#2,d1			; Port B?
	beq	.yes

	move.l	#0,d3
	bra	.exit
				
.yes	move.l	#-1,d3			; Return True
.exit	move.l	d3,-(a6)		; Return
	rts
	even



**     COMMAND:	CSTICKS ON
**  	SYNTAX:	CSTICKS ON
**
** DESCRIPTION:	Turn the CENTRONICS interface on, ready for joysticks

lib11	dc.w	0			; No library calls
	move.b	#7,$ff8800		; Write psg(7)
	move.b	#0,$ff8802
	rts
	even



**     COMMAND:	PADAFIRE
**  	SYNTAX:	x=PADAFIRE(n)
**
** DESCRIPTION:	Returns if the pad in STE Analogue port N is firea.
**		Values returned are TRUE/FALSE (-1/0)

lib12	dc.w	0			; No library calls

	move.l	(a6)+,d4		; Get port number
	move.b	d4,d0
	clr.l	d3			; Clear return variable
	clr.w	d1			; Clear d1
	lea	$ff9202,a0
	move.w  #%11101110,(a0)		; Set Directions
	move.b	$ff9201,d1		; Read fire

	cmp.b	#0,d0			; Port B?
	bne	.portb
	
	btst	#1,d1			; Port A?
	beq	.yes
	move.l	#0,d3			; No, False
	bra	.exit
			
.portb
	btst	#3,d1			; Port B?
	beq	.yes

	move.l	#0,d3
	bra	.exit
				
.yes	move.l	#-1,d3			; Return True
.exit	move.l	d3,-(a6)		; Return
	rts
	even




**     COMMAND:	CSTICKS OFF
**  	SYNTAX:	CSTICKS OFF
**
** DESCRIPTION:	Turn the CENTRONICS interface off

lib13	dc.w	0			; No library calls
	move.b	#7,$ff8800		; Write psg(7)
	move.b	#245,$ff8802
	rts
	even





**     COMMAND:	PADBFIRE
**  	SYNTAX:	x=PADBFIRE(n)
**
** DESCRIPTION:	Returns if the pad in STE Analogue port N is fireb.
**		Values returned are TRUE/FALSE (-1/0)

lib14	dc.w	0			; No library calls

	move.l	(a6)+,d4		; Get port number
	move.b	d4,d0
	clr.l	d3			; Clear return variable
	clr.w	d1			; Clear d1
	lea	$ff9202,a0
	move.w  #%11011101,(a0)		; Set Directions
	move.b	$ff9201,d1		; Read fire

	cmp.b	#0,d0			; Port B?
	bne	.portb
	
	btst	#1,d1			; Port A?
	beq	.yes
	move.l	#0,d3			; No, False
	bra	.exit
			
.portb
	btst	#3,d1			; Port B?
	beq	.yes

	move.l	#0,d3
	bra	.exit
				
.yes	move.l	#-1,d3			; Return True
.exit	move.l	d3,-(a6)		; Return
	rts
	even



*

lib15	dc.w	0			; No library calls
	rts
	even


**     COMMAND:	PADCFIRE
**  	SYNTAX:	x=PADCFIRE(n)
**
** DESCRIPTION:	Returns if the pad in STE Analogue port N is firec.
**		Values returned are TRUE/FALSE (-1/0)

lib16	dc.w	0			; No library calls

	move.l	(a6)+,d4		; Get port number
	move.b	d4,d0
	clr.l	d3			; Clear return variable
	clr.w	d1			; Clear d1
	lea	$ff9202,a0
	move.w  #%10111011,(a0)		; Set Directions
	move.b	$ff9201,d1		; Read fire

	cmp.b	#0,d0			; Port B?
	bne	.portb
	
	btst	#1,d1			; Port A?
	beq	.yes
	move.l	#0,d3			; No, False
	bra	.exit
			
.portb
	btst	#3,d1			; Port B?
	beq	.yes

	move.l	#0,d3
	bra	.exit
				
.yes	move.l	#-1,d3			; Return True
.exit	move.l	d3,-(a6)		; Return
	rts
	even




*

lib17	dc.w	0			; No library calls
	rts
	even


**     COMMAND:	PADOPTION
**  	SYNTAX:	x=PADOPTION(n)
**
** DESCRIPTION:	Returns if the pad in STE Analogue port N is option.
**		Values returned are TRUE/FALSE (-1/0)

lib18	dc.w	0			; No library calls

	move.l	(a6)+,d4		; Get port number
	move.b	d4,d0
	clr.l	d3			; Clear return variable
	clr.w	d1			; Clear d1
	lea	$ff9202,a0
	move.w  #%01110111,(a0)		; Set Directions
	move.b	$ff9201,d1		; Read fire

	cmp.b	#0,d0			; Port B?
	bne	.portb
	
	btst	#1,d1			; Port A?
	beq	.yes
	move.l	#0,d3			; No, False
	bra	.exit
			
.portb
	btst	#3,d1			; Port B?
	beq	.yes

	move.l	#0,d3
	bra	.exit
				
.yes	move.l	#-1,d3			; Return True
.exit	move.l	d3,-(a6)		; Return
	rts
	even


*

lib19	dc.w	0			; No library calls
	rts
	even



**     COMMAND:	PADBUTTON
**  	SYNTAX:	x=PADBUTTON(n)
**
** DESCRIPTION: Returns a 16 bit vector containing values for all 
*		the extra buttons of the powerpad (functionkeys).
*		Layout of value returned..
*
*  Bitnumber.. 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
*  
*  Key:..	.  .  .  .  *  #  9  8  7  6  5  4  3  2  1  0


lib20:	dc.w	0			; No library calls
	move.l	(a6)+,d3		; Get value
	move.b	d3,d0			; As a bytes please

	move.b	#8,d1			; Set values for reading
	move.b	#9,d2			; port A.
	move.b	#10,d3
	move.b	#11,d4
	
	cmp.b	#1,d0			; Port B?
	bne	.no			; No, direct read
	
** Adjust values for reading port B

	add.b	#4,d1			; Adjust values ready
	add.b	#4,d2			; For reading port B
	add.b	#4,d3
	add.b	#4,d4

.no	clr.l	d6			; Erase space for end value

** Read.. *,7,4,1

	clr.w	d0			; Clear value
	move.w  #%11011101,$ff9202	; Set read mode
	move.w  $ff9202,d0		; Read Values

.star	btst	d1,d0			; *?
	bne	.7
	bset	#11,d6			; "*" is pressed
.7	btst	d2,d0			; 7?
	bne	.4
	bset	#7,d6			; "7" is pressed
.4	btst	d3,d0			; 4?
	bne	.1
	bset	#4,d6			; "4" is pressed
.1	btst	d4,d0			; 1?
	bne	.0
	bset	#1,d6			; "1" is pressed	


** Read.. 0,8,5,2

.0	clr.w	d0			; Clear d0
	move.w	#%10111011,$ff9202	; Set read mode
	move.w	$ff9202,d0		; Read values
	
	btst	d1,d0			; 0?
	bne	.8
	bset	#0,d6			; "0" is pressed
.8	btst	d2,d0			; 8?
	bne	.5			
	bset	#8,d6			; "8" is pressed
.5	btst	d3,d0			; 5?
	bne	.2		
	bset	#5,d6			; "5" is pressed
.2	btst	d4,d0			; 2?
	bne	.hash			
	bset	#2,d6			; "2" is pressed


** Read.. #,9,6,3
	
.hash	clr.w	d0			; Clear d0
	move.w	#%01110111,$ff9202	; Set read mode
	move.w	$ff9202,d0		; Read values

	btst	d1,d0			; 0?
	bne	.9
	bset	#10,d6			; "#" is pressed
.9	btst	d2,d0			; 9?
	bne	.6			
	bset	#9,d6			; "9" is pressed
.6	btst	d3,d0			; 6?
	bne	.3		
	bset	#6,d6			; "6" is pressed
.3	btst	d4,d0			; 3?
	bne	.exit			
	bset	#3,d6			; "3" is pressed
		
.exit:	move.l	d6,-(a6)		; Return false
	rts



**     COMMAND:	HARDSCROLL
**  	SYNTAX:	HARDSCROLL screen,xpos,ypos,width,height,mode
**
** DESCRIPTION: Sets up and looks after an STE hardware scrolling screen.
**		All line widths and screen offsets are handled by this 
**		routine.

lib21	dc.w	0			; No library calls
	move.l	(a6)+,d3		; Mode
	move.w	d3,.mode
	move.l	(a6)+,.ytmp		; Height in pixels
	move.l	(a6)+,.xtmp		; Width in pixels
	move.l	(a6)+,d3		; Ypos
	move.w	d3,.ypos
	move.l	(a6)+,d3		; Xpos
	move.w	d3,.xpos
	move.l	(a6)+,.scrn		; Screen address
	
.check:	cmpi.w	#0,.mode		; Turn off interupt?
	beq	.off
	cmpi.w	#1,.mode		; Turn on interupt?
	beq	.on
	
	bra	.vbl			; Must be an update
		
.off:	move.l	#0,$4d2			; Turn off
	bra	.out
.on:	move.l	.xtmp,d0		; Convert Xmax to words
	sub.l	#320,d0			; Get rid of the first 320 pixels 
	divu	#2,d0			; Number of bytes over 
	move.l	d0,.ymax		; Store offset to next scanline			
	add.l	#160,.ymax		; Add a complete scanline to it
	divu	#2,d0			; Number of words over
	move.b	d0,.xm			; 
	move.b	#0,.pixl		; Set initial scroll value
;	move.l	#.vbl,$4d2		; Turn on
	bra	.vbl			; Update screen
	
.pixl	ds.b	1			; Pixel offset
.xm	ds.b	1			; Overlength line width
	even
.mode	ds.w	1			; Space for mode
.xpos	ds.w	1			; Space for co-ords
.ypos	ds.w	1		
.xtmp	ds.l	1			; Overlength Width in words
.ytmp	ds.l	1
.ymax	ds.l	1			; Overlength Height in bytes
.scrn	ds.l	1			; Space for screen

** STE Hardscroll interupt

.vbl:	movem.l	a0/d0-d4,-(a7)		; Save registers
	move.b	.pixl,$ff8265		; Set pixel offset
	move.w	.xpos,d0		; Load xposition
	move.w	.ypos,d1		; Load yposition
	move.l	.scrn,a0		; Load screen

	move.b	.pixl,d2
	move.b	.xm,d3			; Get overlength width
	cmpi.b	#0,d2			; Are we on 16 boundary?
	beq	.cont			; Yes, line width is fine
	sub.b	#4,d3			; Adjust line width	
.cont:	move.b	d3,$ff820f		; Set line width
	ext.l	d1			; Extend d1 to a long word
	move.l	.ymax,d4		; Load number of bytes to next line
	mulu	d4,d1			; Ypositon in bytes
	add.l	d1,a0			; Add Yposition to screen 
	move.w	d0,d2			; Make a copy
	ext.l	d0			; Extend d0 to a long word
	divu	#16,d0			; Number of 16 blocks to skip
	mulu	#8,d0			; Number of bytes
	add.l	d0,a0			; Add Xoffset to screen
	
	move.l	a0,d0			; Set screen address for next VBL
	move.l	d0,d1
	lsr.l	#8,d0
	move.b	d0,$ff8203		; Middle byte
	lsr.l	#8,d0
	move.b	d0,$ff8201		; High byte
	move.b	d1,$ff820d		; Low byte

	andi.w	#%0000000000001111,d2	; Mask data
	move.b	d2,.pixl		; Store pixel offset
	movem.l	(a7)+,a0/d0-d4		; Restore registers	
;	rts
.out	rts

	even



**     COMMAND:	CSTICK UP 
**  	SYNTAX:	x=CSTICK UP(n)
**
** DESCRIPTION:	Return if joystick in centronics joystick port n
** 		is in the up position	

lib22	dc.w	0			; No library calls
	move.l	(a6)+,d3		
	move.w	d3,d1			; port/stick number

	clr.l	d0
	
	move.b	#15,$ff8800		; Select PSG 15 - port B I/O
	move.b	$ff8800,d0		; Read port into d0

	mulu.w	#4,d1			; Multiply port to find correct
					; test bit
		
	btst	d1,d0			; Test bit d1 of d0
	bne	.no			; If bit is 0 then stick is up

	move.l	#-1,d3			; True
	bra	.exit
		
.no	move.l	#0,d3			; Send d3 as false
	
.exit	move.l	d3,-(a6)		; Return value
	rts
	even



**     COMMAND:	AUXSET 
**  	SYNTAX:	AUXSET baud,handshake
**
** DESCRIPTION:	Return if joystick in centronics joystick port n

lib23	dc.w	0			; No library calls
	move.l	(a6)+,d1		; Handshake
	move.l	(a6)+,d0		; Baud
	move.w	#-1,-(sp)
	move.w	#-1,-(sp)	
	move.w	#-1,-(sp)
	move.w	#-1,-(sp)
	move.w	d1,-(sp)		; Handshake
	move.w	d0,-(sp)		; Baud
	move.w	#15,-(sp)
	trap 	#14
	lea	14(sp),sp
	rts
	even




**     COMMAND:	CSTICK DOWN 
**  	SYNTAX:	x=CSTICK DOWN(n)
**
** DESCRIPTION:	Return if joystick in centronics joystick port n
** 		is in the down position	

lib24	dc.w	0			; No library calls
	move.l	(a6)+,d3		
	move.w	d3,d1			; port/stick number

	clr.l	d0
	
	move.b	#15,$ff8800		; Select PSG 15 - port B I/O
	move.b	$ff8800,d0		; Read port into d0

	mulu.w	#4,d1			; Multiply port to find correct
					; test bit
	add	#1,d1
		
	btst	d1,d0			; Test bit d1 of d0
	bne	.no			; If bit is 0 then stick is down

	move.l	#-1,d3			; True
	bra	.exit
		
.no	move.l	#0,d3			; Send d3 as false
	
.exit	move.l	d3,-(a6)		; Return value
	rts
	even



**     COMMAND:	BFCOPY
**  	SYNTAX:	BFCOPY source,destination
**
** DESCRIPTION: Copy an entire fours plane screen using the blitter chip	

lib25	dc.w	0			; No library calls
	move.l	(a6)+,a1		; Destination screen
	move.l	(a6)+,a0		; Source screen
	
	move.w	#2,$ff8a20		; Source x inc
	move.w	#2,$ff8a22		; Source y inc
	move.w	#2,$ff8a2e		; Destination x inc
	move.w	#2,$ff8a30		; Destination y inc
	move.l	a0,$ff8a24		; Source address
	move.l	a1,$ff8a32		; Destination address
	move.w	#80,$ff8a36		; 160 byte x counter
	move.w	#200,$ff8a38		; 200 scanline y counter
	move.w	#$ffff,$ff8a28		; End mask (Left)
	move.w	#$ffff,$ff8a2a		; End mask (Middle)
	move.w	#$ffff,$ff8a2c		; End mask (Right)
	move.b	#2,$ff8a3a		; Blitter Halftone Operation
					; (Blit Hop)
	move.b	#3,$ff8a3b		; Blitter Operation (Blit Op)
	move.b	#0,$ff8a3d		; Skew,nfsr,fxsr
	move.b	#192,$ff8a3c		; Execute blitter operation

	rts
	even




**     COMMAND:	CSTICK LEFT 
**  	SYNTAX:	x=CSTICK LEFT(n)
**
** DESCRIPTION:	Return if joystick in centronics joystick port n
** 		is in the left position	

lib26	dc.w	0			; No library calls
	move.l	(a6)+,d3		
	move.w	d3,d1			; port/stick number

	clr.l	d0
	
	move.b	#15,$ff8800		; Select PSG 15 - port B I/O
	move.b	$ff8800,d0		; Read port into d0

	mulu.w	#4,d1			; Multiply port to find correct
					; test bit
	add	#2,d1
			
	btst	d1,d0			; Test bit d1 of d0
	bne	.no			; If bit is 0 then stick is left

	move.l	#-1,d3			; True
	bra	.exit
		
.no	move.l	#0,d3			; Send d3 as false
	
.exit	move.l	d3,-(a6)		; Return value
	rts
	even




**     COMMAND:	BFSKOPY
**  	SYNTAX:	BFSKOPY source,destination
**
** DESCRIPTION: Copy an entire single plane screen using the blitter chip	

lib27	dc.w	0			; No library calls
	move.l	(a6)+,a1		; Destination screen
	move.l	(a6)+,a0		; Source screen
	
	move.w	#8,$ff8a20		; Source x inc
	move.w	#8,$ff8a22		; Source y inc
	move.w	#8,$ff8a2e		; Destination x inc
	move.w	#8,$ff8a30		; Destination y inc
	move.l	a0,$ff8a24		; Source address
	move.l	a1,$ff8a32		; Destination address
	move.w	#20,$ff8a36		; 40 byte x counter
	move.w	#200,$ff8a38		; 200 scanline y counter
	move.w	#$ffff,$ff8a28		; End mask (Left)
	move.w	#$ffff,$ff8a2a		; End mask (Middle)
	move.w	#$ffff,$ff8a2c		; End mask (Right)
	move.b	#2,$ff8a3a		; Blitter Halftone Operation
					; (Blit Hop)
	move.b	#3,$ff8a3b		; Blitter Operation (Blit Op)
	move.b	#0,$ff8a3d		; Skew,nfsr,fxsr
	move.b	#192,$ff8a3c		; Execute blitter operation

	rts
	even




**     COMMAND:	CSTICK RIGHT 
**  	SYNTAX:	x=CSTICK RIGHT(n)
**
** DESCRIPTION:	Return if joystick in centronics joystick port n
** 		is in the right position	

lib28	dc.w	0			; No library calls
	move.l	(a6)+,d3		
	move.w	d3,d1			; port/stick number

	clr.l	d0
	
	move.b	#15,$ff8800		; Select PSG 15 - port B I/O
	move.b	$ff8800,d0		; Read port into d0

	mulu.w	#4,d1			; Multiply port to find correct
					; test bit
	add	#3,d1
		
	btst	d1,d0			; Test bit d1 of d0
	bne	.no			; If bit is 0 then stick is right

	move.l	#-1,d3			; True
	bra	.exit
		
.no	move.l	#0,d3			; Send d3 as false
	
.exit	move.l	d3,-(a6)		; Return value
	rts
	even



**     COMMAND:	BSCANCOPY
**  	SYNTAX:	BSCANCOPY source,ypos,length,destination,ypos
**
** DESCRIPTION:	Copy a scanline block in four planes


lib29	dc.w	0			; No library calls
	move.l	(a6)+,.dypos		; Destination ypos	
	move.l	(a6)+,a1		; Destination screen
	move.l	(a6)+,.len		; Length of block
	move.l	(a6)+,.sypos		; Source ypos
	move.l	(a6)+,a0		; Source screen

	move.l	.dypos,d0
	mulu	#160,d0			; Calc offsets
	add.l	d0,a1
	move.l	.sypos,d0
	mulu	#160,d0			; Calc offsets
	add.l	d0,a0
	
	move.w	#2,$ff8a20		; Source x inc
	move.w	#2,$ff8a22		; Source y inc
	move.w	#2,$ff8a2e		; Destination x inc
	move.w	#2,$ff8a30		; Destination y inc
	move.l	a0,$ff8a24		; Source address
	move.l	a1,$ff8a32		; Destination address
	move.w	#80,$ff8a36		; 160 byte x counter
	move.l	.len,d0
	move.w	d0,$ff8a38		; No of scanlines
	move.w	#$ffff,$ff8a28		; End mask (Left)
	move.w	#$ffff,$ff8a2a		; End mask (Middle)
	move.w	#$ffff,$ff8a2c		; End mask (Right)
	move.b	#2,$ff8a3a		; Blitter Halftone Operation
					; (Blit Hop)
	move.b	#3,$ff8a3b		; Blitter Operation (Blit Op)
	move.b	#0,$ff8a3d		; Skew,nfsr,fxsr
	move.b	#192,$ff8a3c		; Execute blitter operation
	rts
	
.dypos	ds.l	1
.sypos	ds.l	1
.len	ds.l	1

	even




**     COMMAND:	C FIRE
**  	SYNTAX:	x=C FIRE(n)
**
** DESCRIPTION:	Return if the joystick n, on the CENTRONICS/PRINTER
**		port is having fire pressed


lib30	dc.w	0			; No library calls
	move.l	(a6)+,d3		; Get parameter
	move.b	d3,d1			; port/stick number
	
	cmp.b	#1,d1			; Stick 1
	beq	.stick1
	
.stick0	move.b	#14,$ff8800		; Select PSG 14 - port A I/O
	move.b	$ff8800,d0		; Read port into d0

	btst	#5,d0			; Fire?
	beq	.yes			; Yes 
	bra	.no			; No

.stick1	move.b	$fffa01,d0		; Read MFP GP I/O

	btst	#0,d0			; Fire?
	beq	.yes			; Yes 


.no	move.l	#0,d3			; Send d3 as false
	bra	.exit
	
.yes	move.l	#-1,d3			; Send d3 as true
.exit	move.l	d3,-(a6)		; Return number
	rts
	even
	
	
**     COMMAND:	BSCANSKOPY
**  	SYNTAX:	BSCANSKOPY source,ypos,length,destination,ypos
**
** DESCRIPTION:	Copy a scanline block in a single plane


lib31	dc.w	0			; No library calls
	move.l	(a6)+,.dypos		; Destination ypos	
	move.l	(a6)+,a1		; Destination screen
	move.l	(a6)+,.len		; Length of block
	move.l	(a6)+,.sypos		; Source ypos
	move.l	(a6)+,a0		; Source screen

	move.l	.dypos,d0
	mulu	#160,d0			; Calc offsets
	add.l	d0,a1
	move.l	.sypos,d0
	mulu	#160,d0			; Calc offsets
	add.l	d0,a0
	
	move.w	#8,$ff8a20		; Source x inc
	move.w	#8,$ff8a22		; Source y inc
	move.w	#8,$ff8a2e		; Destination x inc
	move.w	#8,$ff8a30		; Destination y inc
	move.l	a0,$ff8a24		; Source address
	move.l	a1,$ff8a32		; Destination address
	move.w	#20,$ff8a36		; 160 byte x counter
	move.l	.len,d0
	move.w	d0,$ff8a38		; No of scanlines
	move.w	#$ffff,$ff8a28		; End mask (Left)
	move.w	#$ffff,$ff8a2a		; End mask (Middle)
	move.w	#$ffff,$ff8a2c		; End mask (Right)
	move.b	#2,$ff8a3a		; Blitter Halftone Operation
					; (Blit Hop)
	move.b	#3,$ff8a3b		; Blitter Operation (Blit Op)
	move.b	#0,$ff8a3d		; Skew,nfsr,fxsr
	move.b	#192,$ff8a3c		; Execute blitter operation
	rts
	
.dypos	ds.l	1
.sypos	ds.l	1
.len	ds.l	1

	even
	
	
**     COMMAND:	AUXSTAT
**  	SYNTAX:	x=AUXSTAT
**
** DESCRIPTION:	Return if the any data is ready to be inputted

lib32	dc.w	0			; No library calls
	move.w	#1,-(sp)		; Bconstat
	move.w	#1,-(sp)
	trap	#13
	lea	4(sp),sp
	move.l	d0,-(a6)		; Return number
	rts
	even


libex	dc.w	0			; end of library  
