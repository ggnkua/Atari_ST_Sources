***********************************************************************
* Link file basic1.s, is linked with the main program whose entry	*
* routine must have the name main.		*
* U.B. 11.85			 *
***********************************************************************

*\	.globl	wait,wait1,drawl,ddrawl
*\	.globl	grafhand
*\	.globl	grhandle
*\	.globl	global,contrl,intin,intout,ptsin,ptsout,addrin,addrout
*\	.globl	apinit,openwork,clwork,aes,vdi
*\	.globl	inkey
*\	.globl	mouse_on,mouse_off,printf
*\
*\	.text


***********************************************************************
* Entry to the program, initialization of all operating system	*
* functions and creation of the Y-tables (For computers with color	*
* monitors, replace "jsr start1" with "jsr start2".	*
* Furthermore when using a color monitor, replace all	*
* "jsr drawl" calls in the main program with "jsr ddrawl".	*
***********************************************************************


sstart				* initialize the program
	move.l	a7,a5		* Base page address is on the stack 
	move.l	4(a5),a5	* base page address = program start - $100
	move.l	$c(a5),d0	* Program length 
	add.l	$14(a5),d0 	* Length of initialized data area 
	add.l	$1c(a5),d0 	* Length of data area not initialized 
	add.l	#$1100,d0	* 4 K-Byte user stack=sufficient space 
	move.l	a5,d1		* Starting address of the program 
	add.l	d0,d1		* Plus number of reserved bytes = space required 
	and.l	#-2,d1		* even address for stack
	move.l	d1,a7		* User stackpointer to last 4K- byte
	move.l	d0,-(sp)	* Length of reserved area 
	move.l	a5,-(sp)	* Beginning address of reserved area 
	move.w	d0,-(sp)	* Dummy-Word
	move.w	#$4a,-(sp) 	* GEM DOS function SETBLOCK
	trap	#1
	add.l	#12,sp		* old stack address restored again 
	jsr	start1		* Create Y-table 
	jsr	main		* Jump to main program. ( User-created )
	move.l	#0,-(a7)	* Terminate program running 
	trap	#1		* Back to Gem-Desktop

********************************************************************
*	Call a AES-Routine, where the parameters are passed to	*
*	to the various arrays (contrl,etc.)		*
********************************************************************

aes	move.l	#aespb,d1	* call the AES routines 
	move.w	#$c8,d0
	trap	#2
	rts

*********************************************************************
*	Call a VDI-Routine			*
*********************************************************************

vdi	move.l	#vdipb,d1	* call the VDI routines 
	move.w	#$73,d0
	trap	#2
	rts

**********************************************************************
*	Announce the program			*
**********************************************************************

apinit	clr.l	d0	* Announce the program as 
	move.l	d0,ap1resv	* Application 
	move.l	d0,ap2resv
	move.l	d0,ap3resv
	move.l	d0,ap4resv
	move.w	#10,opcode
	move.w	#0,sintin
	move.w	#1,sintout
	move.w	#0,saddrout
	move.w	#0,saddrin
	jsr	aes
	rts
***********************************************************************
* Check on screen handler and store for other functions	*
***********************************************************************

grafhand move.w	#77,contrl	* Get the screen handler	
	move.w	#0,contrl+2	* and store it in the global	
	move.w	#5,contrl+4	* Variable grhandle 
	move.w	#0,contrl+6
	move.w	#0,contrl+8
	jsr	aes
	move.w	intout,grhandle
	rts

***********************************************************************
* Open a Virtual Screen Work Station where all GEM drawing functions	*
* will occur.			*
***********************************************************************

openwork move.w	#100,opcode	* open a workstation	
	move.w	#1,d0
	move.w	#0,contrl+2
	move.w	#11,contrl+6
	move.w	grhandle,contrl+12	* screen handler 
	move.w	d0,intin
	move.w	d0,intin+2
	move.w	d0,intin+4
	move.w	d0,intin+6
	move.w	d0,intin+8
	move.w	d0,intin+10
	move.w	d0,intin+12
	move.w	d0,intin+14
	move.w	d0,intin+16
	move.w	d0,intin+18
	move.w	#2,intin+20
	jsr	vdi
	rts

***********************************************************************
* Clear the workstation			*
***********************************************************************

clwork	move.w	#3,contrl	* Clear workstation
	move.w	#0,contrl+2	* clear the screen	
	move.w	#1,contrl+6
	move.w	grhandle,contrl+12
	jsr	vdi
	rts

***********************************************************************
* Turn on the mouse and its control.		*
***********************************************************************

mouse_on	move.w	#122,contrl	* turn on the mouse and 
	move.w	#0,contrl+2	* its control 
	move.w	#1,contrl+6
	move.w	grhandle,contrl+12
	move.w	#0,intin
	jsr	vdi
	rts


***********************************************************************
*	Turn off the mouse and control.		*
***********************************************************************

mouse_off	move.w	#123,contrl	* turn off the mouse and 
	move.w	#0,contrl+2	* its control 
	move.w	#0,contrl+6
	move.w	grhandle,contrl+12
	jsr	vdi
	rts


***********************************************************************
*	Write a string on the screen		*
***********************************************************************

printf	move.l	a0,-(a7)	* write the string, whose 
	move.w	#9,-(a7)	* beginning address is in 
	trap	#1	* register A0, on the screen.
	addq.l	#6,a7	* String must terminate with 
	rts		* zero.

wait1	dbra	d0,wait1	* Time loop, counts the d0-Register
	rts		* down to -1 

wait	move.w	#1,-(a7)	* wait for a key stroke 
	trap	#1	* GEM-DOS-Call 
	addq.l	#2,a7
	rts


***********************************************************************
*	Sense keyboard status (does not wait for keypress) and return key *
*	code and also the scan code.		*
***********************************************************************

inkey	move.w	#2,-(a7)	* Sense keyboard, does not wait for key	
	move.w	#1,-(a7)	* activation and return an ASCII-code
	trap	#13	* of an activated key in the lower half 
	addq.l	#4,a7	* of the long word of D0, and the scan code 
	tst.w	d0	* in the upper half of the long word of	
	bpl	endkey	* D0.
	move.w	#7,-(a7)
	trap	#1
	addq.l	#2,a7
endkey	rts


***********************************************************************
* Draw-line-routine, draws directly into the screen storage and is	*
* used only for the high resolution mode (640*400 Points ). For color *
* monitor use ddrawl			*
***********************************************************************

drawl	move.l	d7,-(a7)	* Save register 
	move.l	#ytab,a0	* Address of the Y-table 
	clr.l	d4
	move.w	#1,a4	* X step = +1
	move.w	a4,a5	* Y step = +1
	move.w	a2,d6
	sub.w	d2,d6	* DX in d6 = X2 - X1
	bge	dxispos

	neg.w	d6	* If DX is negative, then	
	move.w	#-1,a4	* make positive through negation 
dxispos	move.w	a3,d7
	sub.w	d3,d7	* DY in d7
	bgt	plotit	* If DY is larger than zero draw then
	beq	dyis_0	* first point 
	neg.w	d7	* DY is negative, make positive 
	move.w	#-1,a5	* Y-Step is then -1
	bra	plotit
dyis_0	not.w	d4	* If DY = 0 then parallel to X-Axis 

plotit	tst.w	d2	* Test if drawing area was 
	bmi	draw_it	* exceeded
	tst.w	d3
	bmi	draw_it
	cmp.w	#639,d2
	bhi	draw_it
	cmp.w	#399,d3
	bhi	draw_it
	move.w	d3,d0	* Y-value times two for access to 
	lsl.w	#2,d0	* Plot table 
	move.l	0(a0,d0.w),a1	* Screen address	
	move.w	d2,d1	* X-value
	lsr.w	#3,d1	* INT (X/8)
	move.w	d2,d0	* X-value
	not.w	d0	* -X
**********************************
*	Here the point is drawn	*
**********************************
	bset	d0,0(a1,d1.w)	* 7-(X MOD 8) with the bset-command

draw_it	cmp.w	d2,a2	* End X reached?
	bne	notend	* no
	cmp.w	d3,a3	* End Y reached?
	beq	endit	* no 
notend	tst.w	d4	* D > 0 => Y step 
	bge	ystep
xstep	add.w	a4,d2	* else X step X=X+-1
	add.w	d7,d4	* ND = D + DY
	bra	plotit
ystep	add.w	a5,d3	* Y=Y +- 1
	sub.w	d6,d4	* ND = D - DX
	bra	plotit
drawend
endit	movem.l (a7)+,d7	* restore register 
	rts		* Return to calling program


**********************************************************************
*	This Draw-line-routine is universal for all monitor types and	*
*	can be used with all resolutions.		*
**********************************************************************

ddrawl	move.l	d7,-(a7)
	move.l	lineavar,a0
	move.w	d2,38(a0)	* X1
	move.w	d3,40(a0)	* Y1
	move.w	a2,42(a0)	* X2
	move.w	a3,44(a0)	* Y2
	dc.w	$a003	* draw line 
	move.l	(a7)+,d7
	rts

**********************************************************************
* Initialize the Line-A variables and store the address of the	*
* Variable block in lineavar.		*
**********************************************************************

inlinea
	dc.w	$a000	* initialize the Line A variable.
	move.l	a0,lineavar
	move.w	#0,32(a0)
	move.w	#$ffff,34(a0) * Sample of the line
	move.w	#0,36(a0)	* Writing mode
	move.w	#1,24(a0)	* drawing color 
	rts


**********************************************************************
*	Creation of the Y table for the highest graphic mode (640*400)	*
**********************************************************************

start1
	move.w	#2,-(a7)	* checks the screen address of the 
	trap	#14	* System, recognizes which computer
	addq.l	#2,a7
	move.l	d0,physbase	* Display start minus 32 K-Byte
	move.l	#399,d1	* Number of lines minus one
	move.l	#ytab,a0	* Physical address 

stloop1	move.l	d0,(a0)+	* New address equals old address
	add.l	#80,d0	* plus 80
	dbra	d1,stloop1
	rts

********************************************************************
*	Line-A initialization			*
********************************************************************

start2	jsr	inlinea	* Initialize line A 
	rts

********************************************************************
* Variables of the basic program		*
********************************************************************

	even

lineavar	ds.l	1	* Storage for address of Line-A variable
physbase	ds.l	1	* Storage for screen address.

ytab	ds.l	400	* Storage for the Y table 
contrl		* Arrays for AES and VDI functions 
opcode	ds.w	1
sintin	ds.w	1
sintout	ds.w	1
saddrin	ds.w	1
saddrout	ds.w	1
	ds.w	6

global
apversion 	ds.w	1
apcount	ds.w	1
apid		ds.w	1
apprivate	ds.l	1
apptree	ds.l	1
ap1resv	ds.l	1
ap2resv	ds.l	1
ap3resv	ds.l	1
ap4resv	ds.l	1

intin		ds.w	128
ptsin		ds.w	256
intout		ds.w	128
ptsout		ds.w	128
addrin		ds.w	128
addrout	ds.w	128
grhandle	ds.w	1


vdipb	dc.l	contrl,intin,ptsin,intout,ptsout
aespb	dc.l	contrl,global,intin,intout,addrin,addrout

*\	.end
