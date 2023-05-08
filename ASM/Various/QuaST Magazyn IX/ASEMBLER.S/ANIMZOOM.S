;*------------------------------------------------------------------------*
;*  QuaST Magazyn IX (C) 28.12.1975 QuaST Club / dysk #C - procedury *.S  *
;*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*
;|																		  |
;|             Animacja - Animowanie 10 screenow. Screeny sa zoomowane    |
;|  																	  |
;| autor: Van Eijk														  |
;| uwagi: kazdy rysunek do animacji zajmuje 2 KB, czyli na 800 Kb wejdzie |
;|        400 rysunkow, a to juy bylaby niezla animacja.				  |
;*------------------------------------------------------------------------*


EKRAN1:		equ		$f8000
EKRAN2:		equ		$f8000-190*256

			clr.l	-(sp)
			move.w	#32,-(sp)
			trap	#1
			addq.l	#6,sp

			move.w	#0,-(sp)
			move.l	#EKRAN1,-(sp)
			move.l	#EKRAN1,-(sp)
			move.w	#5,-(sp)
			trap	#14
			add.l	#12,sp

			move.b	#0,$484
			move.w	#0,KIE
			move.w	#0,KIC
			move.w	#0,KID
			move.l	#PAL,-(sp)
			move.w	#6,-(sp)
			trap	#14
			addq.l	#6,sp

			move.l	$70,PAM
			move.l	#VBL,$70

*-+---------------------------------------------------------------------+-*

WAIT:		bra		WAIT

*-+---------------------------------------------------------------------+-*

KONIEC:		move.w	#$2700,SR
			move.l	PAM,$70
			move.b	#255,$484
			move.w	#0000,$ff8246
			move.w	#$fff,$ff8240
			move.w	#$2300,SR
			clr.l	-(sp)
			trap	#1


*-+---------------------------------------------------------------------+-*

VBL:		cmp.b	#57,$ffffc02
			bne		NIE
			jsr		KONIEC
NIE:		move.w	#$222,$fff8240
			jsr		ZOOM
			move.w	#$000,$fff8240
			rte

*-+---------------------------------------------------------------------+-*

ZOOM:		cmp.w	#5,KIE
			bne		J01
			clr.w	KIE
			add.w	#1,KIC
			cmp.w	#10,KIC
			bne		J01
			clr.w	KIC
J01:		cmp.w	#0,KID
			bne		J02
			move.l	#EKRAN2,a0
J02:		cmp.w	#1,KID
			bne		J03
			move.l	#EKRAN1,a0
J03:		move.w	KIE,d0
			mulu.w	#6400,d0
			add.w	d0,a0
			move.l	#RYS,a2
			move.w	KIE,d0
			mulu.w	#400,d0
			add.w	d0,a2
			move.w	KIC,d0
			mulu.w	#2000,d0
			add.w	d0,a2
			move.w	#9,d0
J00:		rept	20
			move.l	#TAB,a1
			clr.w	d1
			move.b	(a2)+,d1
			lsl.l	#2,d1
			add.w	d1,a1
			move.b	(a1)+,0(a0)
			move.b	(a1)+,2(a0)
			move.b	(a1)+,4(a0)
			move.b	(a1)+,6(a0)
			move.l	#TAB,a1
			clr.w	d1
			move.b	(a2)+,d1
			lsl.l	#2,d1
			add.w	d1,a1
			move.b	(a1)+,1(a0)
			move.b	(a1)+,3(a0)
			move.b	(a1)+,5(a0)
			move.b	(a1)+,7(a0)
			addq	#8,a0
			endr
			move.l	-160(a0),000(a0)
			move.l	-156(a0),004(a0)
			move.l	-152(a0),008(a0)
			move.l	-148(a0),012(a0)
			move.l	-144(a0),016(a0)
			move.l	-140(a0),020(a0)
			move.l	-136(a0),024(a0)
			move.l	-132(a0),028(a0)
			move.l	-128(a0),032(a0)
			move.l	-124(a0),036(a0)
			move.l	-120(a0),040(a0)
			move.l	-116(a0),044(a0)
			move.l	-112(a0),048(a0)
			move.l	-108(a0),052(a0)
			move.l	-104(a0),056(a0)
			move.l	-100(a0),060(a0)
			move.l	-096(a0),064(a0)
			move.l	-092(a0),068(a0)
			move.l	-088(a0),072(a0)
			move.l	-084(a0),076(a0)
			move.l	-080(a0),080(a0)
			move.l	-076(a0),084(a0)
			move.l	-072(a0),088(a0)
			move.l	-068(a0),092(a0)
			move.l	-064(a0),096(a0)
			move.l	-060(a0),100(a0)
			move.l	-056(a0),104(a0)
			move.l	-052(a0),108(a0)
			move.l	-048(a0),112(a0)
			move.l	-044(a0),116(a0)
			move.l	-040(a0),120(a0)
			move.l	-036(a0),124(a0)
			move.l	-032(a0),128(a0)
			move.l	-028(a0),132(a0)
			move.l	-024(a0),136(a0)
			move.l	-020(a0),140(a0)
			move.l	-016(a0),144(a0)
			move.l	-012(a0),148(a0)
			move.l	-008(a0),152(a0)
			move.l	-004(a0),156(a0)
			move.l	-160(a0),160+000(a0)
			move.l	-156(a0),160+004(a0)
			move.l	-152(a0),160+008(a0)
			move.l	-148(a0),160+012(a0)
			move.l	-144(a0),160+016(a0)
			move.l	-140(a0),160+020(a0)
			move.l	-136(a0),160+024(a0)
			move.l	-132(a0),160+028(a0)
			move.l	-128(a0),160+032(a0)
			move.l	-124(a0),160+036(a0)
			move.l	-120(a0),160+040(a0)
			move.l	-116(a0),160+044(a0)
			move.l	-112(a0),160+048(a0)
			move.l	-108(a0),160+052(a0)
			move.l	-104(a0),160+056(a0)
			move.l	-100(a0),160+060(a0)
			move.l	-096(a0),160+064(a0)
			move.l	-092(a0),160+068(a0)
			move.l	-088(a0),160+072(a0)
			move.l	-084(a0),160+076(a0)
			move.l	-080(a0),160+080(a0)
			move.l	-076(a0),160+084(a0)
			move.l	-072(a0),160+088(a0)
			move.l	-068(a0),160+092(a0)
			move.l	-064(a0),160+096(a0)
			move.l	-060(a0),160+100(a0)
			move.l	-056(a0),160+104(a0)
			move.l	-052(a0),160+108(a0)
			move.l	-048(a0),160+112(a0)
			move.l	-044(a0),160+116(a0)
			move.l	-040(a0),160+120(a0)
			move.l	-036(a0),160+124(a0)
			move.l	-032(a0),160+128(a0)
			move.l	-028(a0),160+132(a0)
			move.l	-024(a0),160+136(a0)
			move.l	-020(a0),160+140(a0)
			move.l	-016(a0),160+144(a0)
			move.l	-012(a0),160+148(a0)
			move.l	-008(a0),160+152(a0)
			move.l	-004(a0),160+156(a0)
			move.l	-160(a0),320+000(a0)
			move.l	-156(a0),320+004(a0)
			move.l	-152(a0),320+008(a0)
			move.l	-148(a0),320+012(a0)
			move.l	-144(a0),320+016(a0)
			move.l	-140(a0),320+020(a0)
			move.l	-136(a0),320+024(a0)
			move.l	-132(a0),320+028(a0)
			move.l	-128(a0),320+032(a0)
			move.l	-124(a0),320+036(a0)
			move.l	-120(a0),320+040(a0)
			move.l	-116(a0),320+044(a0)
			move.l	-112(a0),320+048(a0)
			move.l	-108(a0),320+052(a0)
			move.l	-104(a0),320+056(a0)
			move.l	-100(a0),320+060(a0)
			move.l	-096(a0),320+064(a0)
			move.l	-092(a0),320+068(a0)
			move.l	-088(a0),320+072(a0)
			move.l	-084(a0),320+076(a0)
			move.l	-080(a0),320+080(a0)
			move.l	-076(a0),320+084(a0)
			move.l	-072(a0),320+088(a0)
			move.l	-068(a0),320+092(a0)
			move.l	-064(a0),320+096(a0)
			move.l	-060(a0),320+100(a0)
			move.l	-056(a0),320+104(a0)
			move.l	-052(a0),320+108(a0)
			move.l	-048(a0),320+112(a0)
			move.l	-044(a0),320+116(a0)
			move.l	-040(a0),320+120(a0)
			move.l	-036(a0),320+124(a0)
			move.l	-032(a0),320+128(a0)
			move.l	-028(a0),320+132(a0)
			move.l	-024(a0),320+136(a0)
			move.l	-020(a0),320+140(a0)
			move.l	-016(a0),320+144(a0)
			move.l	-012(a0),320+148(a0)
			move.l	-008(a0),320+152(a0)
			move.l	-004(a0),320+156(a0)
			add.w	#480,a0
			dbf		d0,J00
			add.w	#1,KIE
			cmp.w	#5,KIE
			beq		SWAPSCREEN
			rts

*-+---------------------------------------------------------------------+-*

SWAPSCREEN:	add.w	#1,KID
			cmp.w	#2,KID
			bne		SW01
			clr.w	KID
SW01:		cmp.w	#0,KID
			bne		SW02
			move.l	#EKRAN1,(a0)
			move.b	1(a0),$fff8201
			move.b	2(a0),$fff8203
SW02:		cmp.w	#1,KID
			bne		SW03
			move.l	#EKRAN2,(a0)
			move.b	1(a0),$fff8201
			move.b	2(a0),$fff8203
SW03:		rts

*-+---------------------------------------------------------------------+-*

KID:		dc.w	1
			even
KIE:		dc.w	1
			even
KIC:		dc.w	1
			even
PAM:		ds.l	1
			even
PAL:		dc.w	$000,$888,$111,$999,$222,$aaa,$333,$bbb,$444,$ccc,$555
			dc.w	$ddd,$666,$eee,$777,$fff
			even
TAB:		incbin	"\asembler.s\dane.dat\DAT00000.VAN"
			even
RYS:		incbin	"\asembler.s\dane.dat\DAT2.VAN"
			even
