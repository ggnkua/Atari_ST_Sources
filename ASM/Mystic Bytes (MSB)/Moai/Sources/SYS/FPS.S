; FPS counter by Earx/Lineout

; $466 - pocet vbl-iek, ak mam vlastne vbl, musim sa o to starat ja :-)
;		move.w	$468.w,d0
;.waitvbl:	cmp.w	$468.w,d0
;		beq.s	.waitvbl
; $4ba - 200 hz counter

; ------------------------------------------------------
		SECTION	TEXT
; ------------------------------------------------------

fps_print:	move.l	frmcnt,d1
		clr.l	d2
		move.l	copy_4ba,d0
		sub.l	starttime,d0
		mulu.l	#200,d1
		divu.l	d0,d2:d1
		swap	d2
		divu.l	d0,d2
		move.l	d1,d0
		moveq	#-1,d7
.loop1:		divu.w	#10,d0
		swap	d0
		addi.b	#'0',d0
		move.b	d0,-(sp)
		clr.w	d0
		swap	d0
		addq.w	#1,d7
		tst.w	d0
		bne.s	.loop1

		lea	.alertpre_txt(pc),a1
		lea	.temp_txt(pc),a0
		lea	(a1),a6
.bloop1:	move.b	(a1),(a0)+
		cmpi.b	#"]",(a1)+
		bne.s	.bloop1
.bloop2:	move.b	(a1),(a0)+
		cmpi.b	#"]",(a1)+
		bne.s	.bloop2
		subq	#1,a0
		subq	#1,a1

.plop1:		move.b	(sp)+,(a0)+
		dbra	d7,.plop1
.pre2:		move.b	#'.',(a0)+
		moveq	#5-1,d7
		mulu.l	#$000186a0,d0:d2		
		move.w	d0,d2
		swap	d2
		move.l	d2,d0
.loop2:		divu.w	#10,d0
		swap	d0
		addi.b	#'0',d0
		move.b	d0,-(sp)
		clr.w	d0
		swap	d0
		dbra	d7,.loop2
		moveq	#5-1,d7
.plop2:		move.b	(sp)+,(a0)+
		dbra	d7,.plop2

		move.l	#" fps",(a0)+
		move.b	#".",(a0)+

.0loop:		move.b	(a1)+,(a0)+
		bne.s	.0loop
 
		move.w	#1,intin
		move.l	#.temp_txt,addrin
		move.l	#.alert_tbl,aespb
		move.l	#aespb,d1
		clr.l	d0
		move.b	#$c8,d0
		trap	#2
		rts

.temp_txt:	DS.B	256
.alertpre_txt:	DC.B	"[1][ Average framerate: | ][ OK ]",0
		EVEN

.alert_tbl:	DC.W	$0034,$0001,$0001,$0001,$0000
	

; ------------------------------------------------------
		SECTION	DATA
; ------------------------------------------------------

* AES parameter block
aespb:		DC.L	contrl,global,intin,intout,addrin,addrout


; ------------------------------------------------------
		SECTION	BSS
; ------------------------------------------------------

* GEM-shit
contrl:		DS.W    12
intin:		DS.W    128
intout:		DS.W    128
global:		DS.W    16
addrin:		DS.W    128
addrout:	DS.W    128

* Counter and timer shit
frmcnt:		DS.L	1
lastframecount:	DS.L	1
starttime:	DS.L	1

copy_4ba:	ds.l	1

; ------------------------------------------------------
		SECTION	TEXT
; ------------------------------------------------------
