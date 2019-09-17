***************************************************************************
* NOBORDER.S : SOURCE TO THE NO BOTTOM BORDER DOC, BY THE DEICIDE. THIS   *
* SOURCE IS COMMENTED, SO YOU SHOULDN'T HAVE DIFFICULTY WORKING IT OUT.IN *
* MY DOC, I SAID THE PICCY WILL BE DISPLAYED APPROX 30 LINES DOWN. WELL I * 						  
* HAD TO CHANGE IT TO 52, BECAUSE THE BOTTOM OF THE PICCY WAS NOT IN THE  *
* BORDER, SO I ADDED AND EXTRA 22 LINES  		DPG		  *
* DON'T RUN AFTER OTHER PROGRAMS, AS IT CAN SOMETIMES CRASH, DUE TO VBL'S *
***************************************************************************
	pea	0				set up super-mode
	move.w	#$20,-(sp)
	trap	#1
	lea	6(sp),sp
	move.l	d0,stack			save stack
	move.w	#3,-(sp)			get old base
	trap	#14
	lea	2(sp),sp
	move.l	d0,base				store in 'base'
	move.w	#4,-(sp)			get rez
	trap	#14			
	lea	2(sp),sp
	move.w	d0,rez				store in 'rez'
	cmp.w	#2,d0				if high rez, then quit
	bne.s	start
	clr.w	-(sp)
	trap	#1

start	move.b	#$12,$fffffc02.w		disable mouse
	movem.l	$ffff8240,d0-7			get old pallette
	movem.l	d0-7,pal			and store in 'pal'
	lea	screen,a0			put our screen address in a0
	move.l	a0,d0				and also d0
	clr.b	d0				clear word
	move.l	d0,screen_base			put remainder in screen base
	move.l	screen_base,a0			screen_base into a0
	move.w	#0,-(sp)			set up low rez, without
	move.l	a0,-(sp)			the bottom border
	pea	-1				logical screen address
	move.w	#5,-(sp)			
	trap	#14
	lea	12(sp),sp			adjust stack
	add.w	#32000,a0			our screen
	move.w	#20,d0
clr1	move.w	#8*40-1,d1			plus an extra 40 lines
clr2	clr.l	(a0)+
	dbf	d1,clr2
	dbf	d0,clr1
	bclr	#0,$484.w			turn off key-click
	move.l	#1,D0				select tune
	jsr	music				and initialise
	movem.l	pic+2,d0-d7			get pic's pallette
	movem.l	d0-d7,$fff8240			and install it
	lea	pic+34,a2			show our piccy
	move.l	screen_base,a3
	move.w	#8000-1+(160*52),d0		do our piccy 52 lines down
	add.w	#160*52,a3			we must also add 52 to the screen 
dpg	move.l	(a2)+,(a3)+			address, otherwise, we get a
	dbf	d0,dpg				corrupted/mixed display
	bsr	install				set up new vbl/hbl

loop	move.w	pic+2,$ffff8240.w
	cmp.b	#$39,$fffc02			space bar ?
	beq	exit				yes, then quit
	bra	loop				no, then loop

exit	bsr	reset				reset old vbl/hbl
	move.w	rez,-(sp)			restore old rez
	move.l	base,a0				restore old base
	pea	-1				leave logic
	move.w	#5,-(sp)			set screen
	trap	#14				xbios
	lea	12(sp),sp			adjust stack
	movem.l	pal,d0-d7			restore old pallette
	movem.l	d0-7,$fff8240
	move.b	#8,$fffffc02.w			enable mouse
	bset	#0,$484.w			turn key-click on
	moveq.l	#0,d0				turn off the music
	jsr	music				by de-selecting the tune
	move.l	#0,$4d6.w			
	move.l	stack,-(sp)			reset old stack pointer
	move.w	#$20,-(sp)			then quit, quite peacefully
	trap	#1				then go to sleep, as it's
	lea	6(sp),sp			very late - 3am
	clr.w	-(sp)				clear stack
	trap	#1				exit

install
	ori.w	#$700,sr				
	move.l	$70,old70				save old vbl
	move.l	$120,old120				save old hbl
	lea	$fffffa00.w,a0
	lea	mfp(pc),a1
	move.b	$7(a0),(a1)+			save old timer b vectors
	move.b	$9(a0),(a1)+	
 	move.b	$1b(a0),(a1)+	
	move.b	$13(a0),(a1)+	
	move.b	$21(a0),(a1)	
	move.L	#vbl,$70.W				install new vbl
	move.L	#hbl,$120.W				install new hbl
	move.b	#1,$FFFFFA07.W				timer b data-every scan line
	clr.b	$FFFFFA09.W				stop timer b
	bclr	#0,$FFFFFA0F.W
	bset	#0,$FFFFFA13.W
	bclr	#3,$FFFFFA17.W
	clr.b	$FFFFFA1B.W
	clr.b	$FFFFFA21.W
	move.w	#$2300,SR
	rts

reset	move.w	#$2700,sr				stop all timers/vectors
	move.l	old120,$120				reset old hbl
	move.l	old70,$70				reset old vbl
	lea	mfp(pc),a0
	lea	$fffffa00.w,a1
	move.b	(a0)+,$7(a1)
	move.b	(a0)+,$9(a1)
	move.b	(a0)+,$1b(a1)
	move.b	(a0)+,$13(a1)
	move.b	(a0),$21(a1)
	move.w	#$2300,SR
	rts

vbl	movem.l	d0-d7/a0-a6,-(sp)		save registers
	bsr	music+8				play music
	movem.l	(sp)+,d0-d7/a0-a6		reset registers
	move.b	#8,$fffffa1b.w			start timer b
	move.b	#199,$fffffa21.w		on line 199
	rte					end of vbl

hbl
	move.b	#0,$fffffa1b.w			stop timer b
	REPT	108				wait a bit
	nop
	ENDR
	clr.b	$ffff820a.w			change to 60 hertz
	REPT	22				wait a bit
	nop
	ENDR
	move.b	#2,$ffff820a.w			back to 50 hertz
	bclr	#0,$fffa0f			end of timer b routine
	rte					end of hbl

	SECTION DATA

screen_base	dc.l	0			screen address			
rez		dc.w	0			rez storage
stack		dc.l	0			stack storage
old70		dc.l	0			old vbl storage
old120		dc.l	0			old hbl storage
mfp		ds.b	5
	even
base		dc.l	0
music	incbin	madmax40.mus
pic	incbin	piccy.pi1
	even
pal	ds.w	16
	ds.b	256
screen	ds.b	32000

