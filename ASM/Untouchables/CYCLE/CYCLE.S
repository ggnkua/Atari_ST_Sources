
; Raster Color cycling !!
; Draw your picture with 1 color -the very last one ($ffff825e.w).
; by Tony -B- 1990


	pea	0.w
	move	#32,-(Sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,oldstk
	
	clr	-(sp)
	pea	-1.w
	pea	-1.w
	move	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	movem.l	d0-d7,$ffff8240.w

	lea	pic+34(pc),a0
	move.l	$44e.w,a1
	move	#7999,d0
copy
	move.l	(a0)+,(a1)+
	dbf	d0,copy
	
	bsr	set_ints		; save/install interrupts

*---------
scan:	cmp.b	#57,$fffffc02.w
	bne.s	scan
*---------

	bsr	rem_ints		; remove interrupts
	
	move.l	#gempal,$45a.w
	
	move.l	oldstk(pc),-(sp)
	move	#32,-(Sp)
	trap	#1
	addq.l	#6,sp
	
	clr	-(sp)
	trap	#1



*---------
newhbl	clr.b	$fffffa1b.w
	pea	(a1)
	move.l	pointer(pc),a1	; get next color
	move	(a1)+,$ffff825e.w
	move.l	a1,pointer	; next color now in pointer
	move.l	(sp)+,a1
	move.b	#6,$fffffa21.w	;set timer for every 6 scanlines
	move.b	#8,$fffffa1b.w
	bclr	#0,$fffffa0f.w
	rte


*---------
newvbl	clr.b	$fffffa1b.w
	move.b	#1,$fffffa21.w	;start timer B on line 1
	move.b	#8,$fffffa1b.w
	
	addq	#2,counter	;increase offset into palette
	cmp	#2400,counter	;end of pal?
	bne.s	not_yet
	clr	counter
	
not_yet	lea	palettes(pc),a0	;load the palettes into a0
	add	counter(pc),a0	;plus value in counter to make
	move.l	a0,pointer	;it scroll

	rte


*---------
set_ints	move	#$2700,sr
	move.l	$120.w,oldhbl+2
	move.l	$70.w,oldvbl+2
	lea	mfp(pc),a0
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa11.w,(a0)+
	move.b	$fffffa1b.w,(a0)+
	move.b	$fffffa0f.w,(a0)+
	move.b	$fffffa13.w,(a0)+
	move.b	$fffffa21.w,(a0)+
	andi.b	#$fe,$fffffa07.w	; disable timer b
	andi.b	#$df,$fffffa09.w	; disable timer c
	move.l	#newvbl,$70.w
	move.l	#newhbl,$120.w
	ori.b	#1,$fffffa07.w	; enable timer b
	ori.b	#1,$fffffa13.w	; set timer b mask
	move	#$2300,sr
	rts


*---------
rem_ints	move	#$2700,sr
	lea	mfp(pc),a0
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
	move.b	(a0)+,$fffffa11.w
	move.b	(a0)+,$fffffa1b.w
	move.b	(a0)+,$fffffa0f.w
	move.b	(a0)+,$fffffa13.w
	move.b	(a0)+,$fffffa21.w
oldvbl	move.l	#0,$70.w
oldhbl	move.l	#0,$120.w
	move	#$2300,sr
	rts



*---------
	data
gempal:	dc.w	$777,$700,$070,$000,$007,$707,$077,$555
	dc.w	$333,$733,$373,$773,$337,$737,$377,$000
	
pointer	dc.l	0
counter	dc.w	0


palettes	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
cyan	dc.w	$11,$11,$11,$11,$22,$22,$22,$22,$33,$33,$33,$33,$44,$44,$44,$44,$55,$55,$55,$55
	dc.w	$66,$66,$66,$66,$77,$77,$77,$77,$66,$66,$66,$66,$55,$55,$55,$55,$44,$44,$44,$44
	dc.w	$33,$33,$33,$33,$22,$22,$22,$22,$11,$11,$11,$11
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
purple	dc.w	$101,$101,$101,$101,$202,$202,$202,$202,$303,$303,$303,$303,$404,$404,$404,$404
	dc.w	$505,$505,$505,$505,$606,$606,$606,$606,$707,$707,$707,$707
	dc.w	$606,$606,$606,$606,$505,$505,$505,$505,$404,$404,$404,$404,$303,$303,$303,$303
	dc.w	$202,$202,$202,$202,$101,$101,$101,$101
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
yellow	dc.w	$110,$110,$110,$110,$220,$220,$220,$220,$330,$330,$330,$330,$440,$440,$440,$440
	dc.w	$550,$550,$550,$550,$660,$660,$660,$660,$770,$770,$770,$770
	dc.w	$660,$660,$660,$660,$550,$550,$550,$550,$440,$440,$440,$440,$330,$330,$330,$330
	dc.w	$220,$220,$220,$220,$110,$110,$110,$110
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
silver	dc.w	$111,$111,$111,$111,$222,$222,$222,$222,$333,$333,$333,$333,$444,$444,$444,$444
	dc.w	$555,$555,$555,$555,$666,$666,$666,$666,$777,$777,$777,$777
	dc.w	$666,$666,$666,$666,$555,$555,$555,$555,$444,$444,$444,$444,$333,$333,$333,$333
	dc.w	$222,$222,$222,$222,$111,$111,$111,$111
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
red	dc.w	$100,$100,$100,$100,$200,$200,$200,$200,$300,$300,$300,$300,$400,$400,$400,$400
	dc.w	$500,$500,$500,$500,$600,$600,$600,$600,$700,$700,$700,$700
	dc.w	$600,$600,$600,$600,$500,$500,$500,$500,$400,$400,$400,$400,$300,$300,$300,$300
	dc.w	$200,$200,$200,$200,$100,$100,$100,$100
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
blue	dc.w	1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,6,6,6,6,7,7,7,7
	dc.w	6,6,6,6,5,5,5,5,4,4,4,4,3,3,3,3,2,2,2,2,1,1,1,1
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
green	dc.w	$10,$10,$10,$10,$20,$20,$20,$20,$30,$30,$30,$30,$40,$40,$40,$40,$50,$50,$50,$50
	dc.w	$60,$60,$60,$60,$70,$70,$70,$70
	dc.w	$60,$60,$60,$60,$50,$50,$50,$50,$40,$40,$40,$40,$30,$30,$30,$30,$20,$20,$20,$20
	dc.w	$10,$10,$10,$10
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0

oldstk:	ds.l	1
mfp:	ds.b	8

pic	incbin	a:\picture\*.pi1
