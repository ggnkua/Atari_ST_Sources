		
		move.l	#$0058ffff,-(sp)
		trap	#14
		addq.l	#4,sp
		move.w	d0,old_mode

		clr.l	-(sp)
		move.w	#32,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,old_user

		move.w	#$2700,sr
		lea	new_stack,sp
		moveq	#0,d0
		movec	d0,cacr

		move.b	$ffff8006.w,d0
		lsr.w	#6,d0
		and.w	#%11,d0
		tst.w	(monitors.l,d0.w)
		bmi	no_run

		bsr	save_screen
		bsr	save_ints
		bsr	clr_ints
		
		bsr	main
	
		bsr	clr_ints
		bsr	rest_screen
		bsr	rest_ints
		bsr	flush_keyboard

		move.w	old_mode,-(sp)
		move.w	#88,-(sp)
		trap	#14
		addq.l	#4,sp

no_run:		move.l	old_user,-(sp)
		move.w	#32,-(sp)
		trap	#1
		addq.l	#6,sp
		clr.w	-(sp)
		trap	#1

save_screen:	lea	old_screen,a0
		lea	$ffff8200.w,a1
		move.l	$44e.w,(a0)+
		move.b	$01(a1),(a0)+
		move.b	$03(a1),(a0)+
		move.b	$0d(a1),(a0)+
		move.b	$0a(a1),(a0)+
		move.l	$0e(a1),(a0)+
		move.b	$65(a1),(a0)+
		
		movem.l	$40(a1),d0-d7
		movem.l	d0-d7,old_pal1
		lea	$ffff9800.w,a0
		lea	old_pal2,a1
		moveq	#32-1,d0
save_pal2:	movem.l	(a0)+,d1-d7/a2
		movem.l	d1-d7/a2,(a1)
		lea	8*4(a1),a1
		dbra	d0,save_pal2
		
		rts

save_ints:	lea	old_ints,a0
		lea	$fffffa00.w,a1
		movep.w	$07(a1),d0
		movep.l	$13(a1),d1
		movep.l	$1b(a1),d2
		move.w	d0,(a0)+
		move.l	d1,(a0)+
		move.l	d2,(a0)+
		move.l	$60.w,(a0)+
		move.l	$68.w,(a0)+
		move.l	$70.w,(a0)+
		move.l	$10c.w,(a0)+
		move.l	$110.w,(a0)+
		move.l	$114.w,(a0)+
		move.l	$118.w,(a0)+
		move.l	$120.w,(a0)+
		move.l	$134.w,(a0)+
		move.l	$13c.w,(a0)+
		
		move.b	$ffff8007.w,(a0)+
		rts
		
rest_screen:	lea	old_screen,a0
		lea	$ffff8200.w,a1
		stop	#$2300
		move.l	(a0)+,$44e.w
		move.b	(a0)+,$01(a1)
		move.b	(a0)+,$03(a1)
		move.b	(a0)+,$0d(a1)
		move.b	(a0)+,$0a(a1)
		move.l	(a0)+,$0e(a1)
		move.b	(a0)+,$65(a1)
		stop	#$2300
		
		movem.l	old_pal1,d0-d7
		movem.l	d0-d7,$40(a1)
		lea	$ffff9800.w,a0
		lea	old_pal2,a1
		moveq	#32-1,d0
rest_pal:	movem.l	(a1)+,d1-d7/a2
		movem.l	d1-d7/a2,(a0)
		lea	4*8(a0),a0
		dbra	d0,rest_pal
		
		stop	#$2300
		rts	
	
rest_ints:	move.w	#$2700,sr
		lea	old_ints,a0
		lea	$fffffa00.w,a1
		move.w	(a0)+,d0
		move.l	(a0)+,d1
		move.l	(a0)+,d2
		movep.w	d0,$07(a1)
		movep.l	d1,$13(a1)
		movep.l	d2,$1b(a1)
		move.l	(a0)+,$60.w
		move.l	(a0)+,$68.w
		move.l	(a0)+,$70.w
		move.l	(a0)+,$10c.w
		move.l	(a0)+,$110.w
		move.l	(a0)+,$114.w
		move.l	(a0)+,$118.w
		move.l	(a0)+,$120.w
		move.l	(a0)+,$134.w
		move.l	(a0)+,$13c.w	
		
		move.b	(a0)+,$ffff8007.w
		move.w	#$2300,sr
		rts
	
clr_ints:	move.w	#$2700,sr
		bsr	flush_keyboard
		lea	$fffffa00.w,a0
		lea	rte_rout,a1
		moveq	#0,d0
		movep.w	d0,$07(a0)
		movep.l	d0,$13(a0)
		movep.l	d0,$1b(a0)
		move.b	#$40,$17(a0)
		move.l	a1,$60.w
		move.l	a1,$68.w
		move.l	a1,$10c.w
		move.l	a1,$110.w
		move.l	a1,$114.w
		move.l	a1,$120.w
		move.l	a1,$134.w
		move.l	a1,$13c.w
		move.l	#temp_vbl,$70.w
		move.b	#%100101,$ffff8007.w
		bsr	flush_keyboard
		move.w	#$2300,sr
		rts
	
temp_vbl:	addq.l	#1,vbl_ctr
		addq.l	#1,$466.w
rte_rout:	rte

flush_keyboard:	btst	#1,$fffffc00.w
		bne.s	no_flush
		move.b	$fffffc02.w,d0
		bra.s	flush_keyboard
no_flush:	move.b	$fffffc02.w,d0
		rts

calc_mode:	moveq	#0,d6				;VM
		move.w	(Res_List.l,d2.w*2),SPSHIFT	;SPSHIFT
		mulu	#5,d0				
		add.w	d2,d0
		lsl.w	#4,d0
		lsl.w	#4,d1
		
		move.b	$ffff8006.w,d2
		lsr.w	#6,d2
		and.w	#%11,d2
		move.l	(Mon_List.l,d2.w*4),a0
	
		move.w	d0,a1			* Hsyncs
		add.l	(a0),a1
		tst.w	(a1)
		bmi.s	.not_possible
		or.w	(a1)+,d6
		move.w	(a1)+,VWRAP
		lea	Hsyncs,a2
		move.l	(a1)+,(a2)+
		move.l	(a1)+,(a2)+
		move.l	(a1)+,(a2)+

		move.w	d1,a1			* VSyncs
		add.l	4(a0),a1
		tst.w	(a1)
		bmi.s	.not_possible
		or.w	(a1)+,d6
		lea	Vsyncs,a2
		move.l	(a1)+,(a2)+
		move.l	(a1)+,(a2)+
		move.l	(a1)+,(a2)+		
* Special		
		move.w	d6,VM
		move.l	8(a0),a1
		jsr	(a1)

		st	syncs_valid
		moveq	#0,d0
		rts

.not_possible:	sf	syncs_valid
		moveq	#-1,d0
		rts

set_mode:	tst.b	syncs_valid
		beq.s	.no_set
		
		lea	Hsyncs,a0
		lea	$ffff8282.w,a1
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		clr.l	(a1)+
		lea	Vsyncs,a0
		lea	$ffff82a2.w,a1
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		clr.w	$ffff820e.w
		move.w	VWRAP,$ffff8210.w
		move.w	VM,$ffff82c2.w
		move.w	VCO,$ffff82c0.w
		clr.w	$ffff8266.w
		tst.w	SPSHIFT
		bmi.s	.set_60
		move.w	SPSHIFT,$ffff8266.w
.no_set:	rts
.set_60:	move.b	SPSHIFT+1,$ffff8260.w
		move.w	VWRAP,$ffff8210.w
		rts

SM124_Fixer:	rts
SC1224_Fixer:	move.w	#$183,VCO
		rts
TV_Fixer:	move.w	#$183,VCO
		rts
VGA_Fixer:	move.w	#$186,VCO
		rts

		DATA
	
monitors:	dc.b	-1,0,0,0		
	
Mon_List:	dc.l	SM124_Lists
		dc.l	SC1224_lists
		dc.l	VGA_Lists
		dc.l	TV_Lists

Res_List:	dc.w	$0400,$ff01,$0000,$0010,$0100
conv_list:	dc.b	0,1,2,3,4,4,4,4,5,6,7,8,9,9,9,9		
		
SM124_Lists:	dc.l	SM124_Hsyncs
		dc.l	SM124_Vsyncs
		dc.l	SM124_Fixer
		
SC1224_lists:	dc.l	SC1224_Hsyncs
		dc.l	SC1224_Vsyncs
		dc.l	SC1224_Fixer				
	
SM124_Hsyncs:	dc.l	-1
SM124_Vsyncs:	dc.l	-1

*** TV SYNCS **************************************************************

TV_Lists:	dc.l	TV_Hsyncs
		dc.l	TV_Vsyncs
		dc.l	TV_Fixer

TV_Hsyncs:	dc.w	-1,0,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff  ;320x2
		dc.w	0,40,$003e,$0030,$0008,$0239,$0012,$0034  ;320x4
		dc.w	0,80,$00fe,$00cb,$0027,$000c,$006d,$00d8  ;320x16
		dc.w	0,160,$00fe,$00cb,$0027,$001c,$007d,$00d8 ;320x256
		dc.w	0,320,$00fe,$00cb,$0027,$002e,$008f,$00d8 ;320xTC
		dc.w	4,40,$01fe,$0199,$0050,$03ef,$00a0,$01b2  ;640x2
		dc.w	4,80,$003e,$0030,$0008,$0002,$0020,$0034  ;640x4
		dc.w	4,160,$01fe,$0199,$0050,$0071,$0122,$01b2 ;640x16
		dc.w	4,320,$01fe,$0199,$0050,$005d,$010e,$01b2 ;640x256
		dc.w	4,640,$01fe,$0199,$0050,$004d,$00fe,$01b2 ;640xTC
		dc.w	4,48,$01fe,$0199,$0050,$03af,$00ed,$01b2  ;768x2
		dc.w	4,96,$003e,$0030,$0008,$0237,$0020,$0034  ;768x4
		dc.w	4,192,$01fe,$0199,$0050,$000d,$013e,$01b2 ;768x16
		dc.w	4,384,$01fe,$0199,$0050,$001d,$014e,$01b2 ;768x256
		dc.w	4,768,$01fe,$0199,$0050,$0031,$0162,$01b2 ;768xTC
		dc.w	8,400,$003e,$0032,$0009,$023d,$002e,$0034 ;1600x16

TV_Vsyncs:	dc.w	0,$0271,$0265,$002f,$007f,$020f,$026b,0 ;200
		dc.w	0,$0271,$0265,$002f,$0057,$0237,$026b,0 ;240
		dc.w	2,$0270,$0265,$002f,$007e,$020e,$026b,0 ;400
		dc.w	2,$0270,$0265,$002f,$0056,$0236,$026b,0 ;480
		dc.w	2,$0270,$026c,$000f,$000f,$026a,$026a,0	;600 MS

*** SC1224 SYNCS **********************************************************

SC1224_Hsyncs = TV_Hsyncs
SC1224_Vsyncs = TV_Vsyncs

*** VGA SYNCS *************************************************************

VGA_Lists:	dc.l	VGA_Hsyncs
		dc.l	VGA_Vsyncs
		dc.l	VGA_Fixer

VGA_Hsyncs:	dc.w	-1,0,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff  ;320x2
		dc.w	4,40,$0017,$0012,$0001,$020a,$0009,$0011  ;320x4
		dc.w	4,80,$00c6,$008d,$0015,$028a,$006b,$0096  ;320x16
		dc.w	4,160,$00c6,$008d,$0015,$029a,$007b,$0096 ;320x256
		dc.w	4,320,$00c6,$008d,$0015,$02ac,$0091,$0096 ;320xTC
		dc.w	8,40,$00c6,$008d,$0015,$0273,$0050,$0096  ;640x2
		dc.w	8,80,$0017,$0012,$0001,$0273,$000d,$0011  ;640x4
		dc.w	8,160,$00c6,$008d,$0015,$02a3,$007c,$0096 ;640x16
		dc.w	8,320,$00c6,$008d,$0015,$02ab,$0084,$0096 ;640x256
		dc.w	-1,0,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff  ;640xTC
		dc.w	-1,0,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff  ;768x2
		dc.w	-1,0,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff  ;768x4
		dc.w	-1,0,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff  ;768x16
		dc.w	-1,0,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff  ;768x256
		dc.w	-1,0,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff  ;768xTC
		dc.w	8,400,$003e,$0032,$0009,$023d,$002e,$0034 ;1600 MS
	
VGA_Vsyncs:	dc.w	1,$0419,$03af,$008f,$008f,$03af,$0415,0	;200
		dc.w	1,$0419,$03ff,$003f,$003f,$03ff,$0415,0	;240
		dc.w	0,$0419,$03af,$008f,$008f,$03af,$0415,0	;400
		dc.w	0,$0419,$03ff,$003f,$003f,$03ff,$0415,0	;480 
		dc.w	2,$0270,$026c,$000f,$000f,$026a,$026a,0	;600 MS

		bss			
old_user:	ds.l	1
old_mode:	ds.w	1
old_ints:	ds.w	5
		ds.l	10
		ds.w	1
old_screen:	ds.l	3
		ds.w	1
old_pal1:	ds.w	16
old_pal2:	ds.l	256

vbl_ctr:	ds.l	1
				
VCO:		ds.w	1
VM:		ds.w	1
SPSHIFT:	ds.w	1
VWRAP:		ds.w	1
syncs_valid:	ds.w	1
Hsyncs:		ds.w	6
Vsyncs:		ds.w	6
				
		ds.l	1024
new_stack:	ds.l	2
