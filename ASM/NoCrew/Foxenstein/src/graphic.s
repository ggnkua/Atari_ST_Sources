; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;          - Foxenstein -
;    a NoCrew production MCMXCV
;
;    (c) Copyright NoCrew 1995
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Graphic module.

SCREEN_MEM_SIZE	equ	2*320*240

	section	text
* Save old_mode, old_phys and old_log etc.
save_video	lea	$ffff9800.w,a0
	lea	old_palett,a1
	move.w	#256-1,d0
.old_colors	move.l	(a0)+,(a1)+
	dbra	d0,.old_colors

	move.w	#89,-(sp)
	trap	#14		* mon_type
	addq.w	#2,sp
	clr.w	VGA_mode
	cmp.w	#2,d0
	bne.s	.no_VGA
	move.w	#1,VGA_mode
.no_VGA	move.b	$ffff8201.w,old_physic+1
	move.b	$ffff8203.w,old_physic+2
	move.b	$ffff820d.w,old_physic+3

	lea	old_VIDEL,a0
	move.l	$ffff8282.w,(a0)+
	move.l	$ffff8286.w,(a0)+
	move.l	$ffff828a.w,(a0)+
	move.l	$ffff82a2.w,(a0)+
	move.l	$ffff82a6.w,(a0)+
	move.l	$ffff82aa.w,(a0)+
	move.w	$ffff820a.w,(a0)+
	move.w	$ffff82c0.w,(a0)+
	move.w	$ffff8266.w,(a0)+
	move.w	$ffff8266.w,(a0)+
	move.w	$ffff82c2.w,(a0)+
	move.w	$ffff8210.w,(a0)+
	rts

* Restores resolution and screen.
restore_video	* Restore resolution and screen address.
	move.b	old_physic+1,$ffff8201.w
	move.b	old_physic+2,$ffff8203.w
	move.b	old_physic+3,$ffff820d.w

	lea	old_VIDEL,a0
	move.l	(a0)+,$ffff8282.w
	move.l	(a0)+,$ffff8286.w
	move.l	(a0)+,$ffff828a.w
	move.l	(a0)+,$ffff82a2.w
	move.l	(a0)+,$ffff82a6.w
	move.l	(a0)+,$ffff82aa.w
	move.w	(a0)+,$ffff820a.w
	move.w	(a0)+,$ffff82c0.w
	move.w	(a0)+,$ffff8266.w
	move.w	(a0)+,$ffff8266.w
	move.w	(a0)+,$ffff82c2.w
	move.w	(a0)+,$ffff8210.w

	lea	old_palett,a0
	lea	$ffff9800.w,a1
	move.w	#256-1,d0
.old_colors	move.l	(a0)+,(a1)+
	dbra	d0,.old_colors
	rts

* Sets resolution, screen address and offset to next line.
new_video	* Set screen address at an even 256 address.
	move.l	#screen_mem+256,d0
	and.l	#$ffffff00,d0
	move.l	d0,logic
	add.l	#2*320*240,d0
	move.l	d0,physic

	lea	$ffff9800.w,a0
	move.w	#256-1,d0
.dark_colors	clr.l	(a0)+
	dbra	d0,.dark_colors

	bsr.w	cls
	bsr.w	flipp
	bsr.w	cls

	tst.w	VGA_mode
	beq.w	.TV
.VGA	move.l   #$620046,$ffff8282.w	; 160x200 50 Hz
	move.l   #$a024d,$ffff8286.w
	move.l   #$46004b,$ffff828a.w
	move.l   #$4eb04d1,$ffff82a2.w
	move.l   #$3f00f5,$ffff82a6.w
	move.l   #$41504e7,$ffff82aa.w
	move.w   #$200,$ffff820a.w
	move.w   #$186,$ffff82c0.w
	clr.w    $ffff8266.w
	move.w   #$100,$ffff8266.w
	move.w   #$1,$ffff82c2.w
	move.w   #$A0,$ffff8210.w
	move.l	#160,screen_w
	move.l	#200,screen_h
	move.l	#160,real_screen_w
	move.l	#200,real_screen_h
	bra.s	.resume
.TV	move.l   #$c700a0,$ffff8282.w	; 320x200 50Hz
	move.l   #$1f02c7,$ffff8286.w
	move.l   #$9600aa,$ffff828a.w
	move.l   #$2710265,$ffff82a2.w
	move.l   #$2f008b,$ffff82a6.w
	move.l   #$21b026b,$ffff82aa.w
	move.w   #$200,$ffff820a.w
	move.w   #$186,$ffff82c0.w
	clr.w    $ffff8266.w
	move.w   #$100,$ffff8266.w
	move.w   #$0,$ffff82c2.w
	move.w   #$140,$ffff8210.w
	move.l	#320,screen_w
	move.l	#200,screen_h
	move.l	#320,real_screen_w
	move.l	#200,real_screen_h

.resume	clr.l	$ffff9800.w	* Dark borders.
	rts

* Switch logical and physical screen address.
flipp	move.l	logic(pc),d0
	move.l	physic(pc),logic
	move.l	d0,physic
	move.b	physic+1,$ffff8201.w
	move.b	physic+2,$ffff8203.w
	move.b	physic+3,$ffff820d.w
	rts

* Clear screen.
cls	tst.w	VGA_mode
	beq.w	.TV
.VGA	move.l	logic(pc),a0
	add.l	#2*320*240,a0
	movem.l	void,d1-d7/a1-a6
	move.w	#184-1,d0
.VGA_loop	rept	16
	movem.l	d1-d7/a1-a6,-(a0)
	endr
	dbra	d0,.VGA_loop
	rept	9
	movem.l	d1-d7/a1-a6,-(a0)
	endr
	movem.l	d1-d7/a1-a4,-(a0)
	rts
.TV	move.l	logic(pc),a0
	add.l	#2*320*200,a0
	movem.l	void,d1-d7/a1-a6
	move.w	#307-1,d0
.TV_loop	rept	8
	movem.l	d1-d7/a1-a6,-(a0)
	endr
	dbra	d0,.TV_loop
	rept	5
	movem.l	d1-d7/a1-a6,-(a0)
	endr
	movem.l	d1-d7,-(a0)
	rts

	section	data
logic	dc.l	0
physic	dc.l	0
void	dcb.w	128,$0000

VGA_mode	dc.w	0	* set if VGA, otherwise 0.

	section	bss
old_physic	ds.l	1
old_palett	ds.l	256
old_VIDEL	ds.l	9
	* Two 320x240 True color screens
screen_mem	ds.b	SCREEN_MEM_SIZE
	ds.b	SCREEN_MEM_SIZE
	ds.b	256
