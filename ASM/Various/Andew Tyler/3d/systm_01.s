* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*			systm_01.s                            *
*            Calls to the Operating System                    *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
                          
* find the screen addresses
find_screens:
	move.w	#2,-(sp)	xbios _physbase
	trap	#14		xbios call
	addq.w	#2,sp		tidy stack
* the physical screen base address is returned in d0 and saved 
	move.l	d0,screen2	as screen2
* calculate the address of the logical screen and save it
	sub.l	#$8000,d0	another 32k screen to draw on
	move.l	d0,screen1	called screen1
	rts

draw1_disp2:
* DRAW ON SCREEN 1, DISPLAY SCREEN 2 (AT VBLNK)
	move.w	#-1,-(sp)	ignore resolution
	move.l	screen2,-(sp)	display 2
	move.l	screen1,-(sp)	draw on 1
	move.w	#5,-(sp)	xbios_setscreen
	trap	#14
	add.l	#12,sp		tidy
*	lea	scrn1_tbl,a0	tell the program
*	move.l	a0,screen
* wait for it
	move.w	#$25,-(sp)	xbios wait for vblank
	trap	#14
	addq.l	#2,sp		trap 14
	rts

draw2_disp1:
* DRAW ON SCREEN 2, DISPLAY SCREEN 1
	move.w	#-1,-(sp)	ignore resolution
	move.l	screen1,-(sp)	display 2
	move.l	screen2,-(sp)	draw on 1
	move.w	#5,-(sp)	xbios_setscreen
	trap	#14
	add.l	#12,sp		tidy
*	lea	scrn2_tbl,a0	tell the program
*	move.l	a0,screen
* wait for it
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	rts	

* CLEAR SCREEN 1 (by wiping out 10 long words at a time)
clear1	move.l	screen1,a3	screen1 base
	adda.l	#32000,a3	point to top
	move.w	#799,d7
	moveq.l	#0,d0
	move.l	d0,d1
	move.l	d1,d2
	move.l	d2,d3
	move.l	d3,d4
	move.l	d4,d5
	move.l	d5,d6
	movea.l	d6,a0
	movea.l	a0,a1
	movea.l	a1,a2
clr1_1	movem.l	d0-d6/a0-a2,-(a3)
	dbf	d7,clr1_1
	rts
* CLEAR SCREEN 2
clear2	move.l	screen2,a3	screen 2 base
	adda.l	#32000,a3
	move.w	#799,d7
	moveq.l	#0,d0
	move.l	d0,d1
	move.l	d1,d2
	move.l	d2,d3
	move.l	d3,d4
	move.l	d4,d5
	move.l	d5,d6
	movea.l	d6,a0
	movea.l	a0,a1
	movea.l	a1,a2
clr2_1	movem.l	d0-d6/a0-a2,-(a3)
	dbf	d7,clr2_1
	rts

 