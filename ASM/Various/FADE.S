start	clr.l	-(sp)			* Enter Supervisor mode
	move.w	#32,-(sp)
	trap	#1
	addq.l	#2,sp
	move.l	d0,super
	bclr	#0,$484.w		* Get rid of the fuckin' keyclick
	dc.w	$a00a			* Hide mousepointer

*	move.w	#0,-(sp)
*	move.l	#-1,-(sp)
*	move.l	#-1,-(sp)
*	move.w	#5,-(sp)
*	trap	#14
*	add.l	#12,sp

*	move.l	#$70000,a1		* Erase both screens
*	jsr	clr_scr
*	move.l	#$78000,a1
*	jsr	clr_scr

	movem.l	$ff8240,d0-d7		* Install new palette
	movem.l	d0-d7,oldpal
*	movem.l	palett,d0-d7
*	movem.l	d0-d7,$ff8240

	jsr	fade_up_to_white
	jsr	fade_down_to_black

main	*cmp.b	#1,$fffc02		* Somebody pressed <ESC>?
	*bne	main			* If not so back to Main

restore
	movem.l	oldpal,d0-d7		* Restore old palette
	movem.l	d0-d7,$ff8240

	move.l	super,-(sp)		* Back into User mode
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.w	-(sp)			* Quit program
	trap	#1

*	Here are all the subroutines

swap1	move.w	#-1,-(sp)		* Swap screens
	move.l	#$78000,-(sp)
	move.l	#$70000,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	move.l	#$70000,screen
	rts

swap2	move.w	#-1,-(sp)		* Swap screens
	move.l	#$70000,-(sp)
	move.l	#$78000,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	move.l	#$78000,screen
	rts

tst_scr	cmpi.l	#$78000,screen
	bne.s	swp_2
	jsr	swap1
	rts
swp_2	jsr	swap2
	rts

waitvbl	movem.l	d0-a6,-(sp)
	move.w	#37,-(sp)		* Wait for Vertical Blank
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-a6
	rts

fade_down_to_black
	move.w	#7,d7
	move.w	#$777,d0
	move.w	d0,d1
	move.w	d0,d2

fade	move.w	d0,$ff8240
	lsr.w	#8,d0
	and.w	#%0000000000001111,d0	* Red
	beq	next1
	sub.w	#1,d0

next1	lsr.w	#4,d1
	and.w	#%0000000000001111,d1	* Green
	beq	next2
	sub.w	#1,d1

next2	and.w	#%0000000000001111,d2	* Blue
	beq	next3
	sub.w	#1,d2

next3	mulu.w	#$100,d0
	mulu.w	#$10,d1
	add.w	d2,d1
	add.w	d1,d0
	jsr	waitvbl
	jsr	waitvbl
	jsr	waitvbl
	dbra	d7,fade
	rts

fade_up_to_white
	move.w	#7,d7
	move.w	#$253,d0
	move.w	d0,d1
	move.w	d0,d2

.fade	move.w	d0,$ff8240
	lsr.w	#8,d0
	and.w	#%0000000000001111,d0	* Red
	cmp.w	#7,d0
	beq	.next1
	add.w	#1,d0

.next1	lsr.w	#4,d1
	and.w	#%0000000000001111,d1	* Green
	cmp.w	#7,d1
	beq	.next2
	add.w	#1,d1

.next2	and.w	#%0000000000001111,d2	* Blue
	cmp.w	#7,d2
	beq	.next3
	add.w	#1,d2

.next3	mulu.w	#$100,d0
	mulu.w	#$10,d1
	add.w	d2,d1
	add.w	d1,d0
	jsr	waitvbl
	jsr	waitvbl
	jsr	waitvbl
	dbra	d7,.fade
	rts

clr_scr	move.w	#40*200,d0		* Clear whole screen,
clr	clr.l	(a1)+			* all 4 bitplanes
	dbra	d0,clr
	rts

	section	data
super	dc.l	0
screen	dc.l	$f8000
palett	dc.w	$000,$777,$555,$444,$222,$555,$666,$777
	dc.w	$007,$017,$027,$037,$047,$057,$067,$777

	section	bss
oldpal	ds.l	8
