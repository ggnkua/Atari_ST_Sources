;*------------------------------------------------------------------------*
;*  QuaST Magazyn IX (C) 28.12.1975 QuaST Club / dysk #C - procedury *.S  *
;*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*
;|																		  |
;|	 					   Intro - Intro z zoomem		  				  |
;|  																	  |
;| autor: Van Eijik		    											  |
;| uwagi: Takie malutkie demo, zeby chodzilo na ST, trzeba zmienic		  |
;|        adresy ekranow i procedure ich przelaczania					  |
;*------------------------------------------------------------------------*

EKRAN0:		equ		$c6000
EKRAN1:		equ		$c6000
EKRAN2:		equ		$c6000+48000

*-+---------------------------------------------------------------------+-*

			clr.l	-(sp)
			move.w	#32,-(sp)
			trap	#1
			addq.l	#6,sp

			jsr		CIEMNO

			move.w	#0,-(sp)
			move.l	#EKRAN0,-(sp)
			move.l	#EKRAN0,-(sp)
			move.w	#5,-(sp)
			trap	#14
			add.l	#12,sp

			move.l	#EKRAN0,a0
			move.w	#600*40,d0
OP:			clr.l	(a0)+
			dbf		d0,OP
			move.w	#0,KIE
			move.w	#0,KIC
			move.w	#0,KID
			move.l	#TOR,TOREK

*-+---------------------------------------------------------------------+-*
		
			move.l  #SAFEREG,a0
			move.l	$70,(a0)+
			move.l	$118,(a0)+
			move.l	$120,(a0)+
			move.l	$134,(a0)+
			move.b  $fffa07,(a0)+
			move.b  $fffa09,(a0)+
			move.b  $fffa0b,(a0)+
			move.b  $fffa0f,(a0)+
			move.b  $fffa13,(a0)+
			move.b  $fffa15,(a0)+
			move.b  $fffa17,(a0)+
			move.b  $fffa19,(a0)+	
			move.b  $fffa1f,(a0)+	
			move.b  $fffa1b,(a0)+
			move.b  $fffa1d,(a0)+		
			move.b  $fffa21,(a0)+
			move.w 	#$2700,SR
			moveq	#1,d0
			jsr		MUSIC
			move.b	#0,$484
			move.b	#18,$fffc02
			move.b 	#8,$fffa1b
			move.b 	#4,$fffa21
			clr.b  	$fffffa19		
			move.b 	#$21,$fffffa07	
			move.b 	#$21,$fffffa13	
			bclr   	#3,$fffffa17	
			clr.b	$fffffa09
			clr.b	$fffffa15
			move.l 	#VBL,$70
			move.l	#STRONICE,$118
			move.l 	#TIMER000,$120
			move.l 	#TIMER_A,$134
			move.w 	#$2300,sr		

*-+---------------------------------------------------------------------+-*

WAIT:		bra		WAIT

*-+---------------------------------------------------------------------+-*

KONIEC:		move.w	#$2700,sr
			move.l  #SAFEREG,a0
			move.l	(a0)+,$70
			move.l	(a0)+,$118
			move.l	(a0)+,$120
			move.l	(a0)+,$134
			move.b  (a0)+,$fffa07
			move.b  (a0)+,$fffa09
			move.b  (a0)+,$fffa0b                              
			move.b  (a0)+,$fffa0f
			move.b  (a0)+,$fffa13
			move.b  (a0)+,$fffa15
			move.b  (a0)+,$fffa17
			move.b  (a0)+,$fffa19	
			move.b  (a0)+,$fffa1f	
			move.b  (a0)+,$fffa1b
			move.b  (a0)+,$fffa1d
			move.b  (a0)+,$fffa21
			move.b  (a0)+,$fffa23
			move.w	#$2300,sr		
			jsr		MUSIC+4
			move.b	#255,$484
			move.b	#8,$fffc02
			move.w	#0,$fff8246
			move.w	#$fff,$fff8240
			clr.l	-(sp)
			trap	#1
			rts

*-+---------------------------------------------------------------------+-*

VBL:		clr.b	$fffffa19		
			move.b	#100,$fffffa1f	
			move.b	#4,$fffffa19	
			clr.b	$fffffa1b		
			move.b	#1,$fffffa21	
			move.l	#TIMER00,$120
			move.b	#8,$fffffa1b	
			cmp.b	#57,$fffc02
			beq		KONIEC
			jsr		MUSIC+8
			jsr		ZOOM
			rte

*-+---------------------------------------------------------------------+-*

ZOOM:		movem.l	a0-a7/d0-d7,-(sp)
			cmp.w	#5,KIE
			bne		J01
			clr.w	KIE
			move.l	TOREK,a0
			cmp.w	#9999,02(a0)
			bne		J04
			move.l	#TOR,TOREK
			move.l	TOREK,a0
J04:		move.w	(a0)+,d0
			move.l	a0,TOREK
			move.w	d0,KIC
J01:		cmp.w	#0,KID
			bne		J02
			move.l	#EKRAN2+640,a0
			move.l	#EKRAN2+1128+6,a6
J02:		cmp.w	#1,KID
			bne		J03
			move.l	#EKRAN1+640,a0
			move.l	#EKRAN1+1128+6,a6
J03:		move.w	KIE,d0
			mulu.w	#13*640,d0
			add.l	d0,a0
			move.l	#RYS,a2
			add.w	KIC,a2
			clr.l	d0
			move.w	KIE,d0
			mulu.w	#13*160,d0
			add.w	d0,a2
			move.w	#12,d0
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
			add.w	#160-40,a2
			add.w	#480,a0
			dbf		d0,J00
			eori.w	#%0111110001111000,000(a6)
			eori.w	#%1111110011111100,160(a6)
			eori.w	#%0000000000001100,320(a6)
			eori.w	#%1100000011001100,480(a6)
			eori.w	#%1100000011001100,640(a6)
			eori.w	#%1111110011111100,800(a6)
			eori.w	#%0111110001111000,960(a6)
			eori.w	#%1111100011111100,008(a6)
			eori.w	#%1111110011111100,168(a6)
			eori.w	#%0000110000000000,328(a6)
			eori.w	#%1100110011111100,488(a6)
			eori.w	#%1100110011000000,648(a6)
			eori.w	#%1111110011111100,808(a6)
			eori.w	#%1111100011111100,968(a6)
			eori.w	#%1111100011001100,008+16(a6)
			eori.w	#%1111110011001100,168+16(a6)
			eori.w	#%0000110000001100,328+16(a6)
			eori.w	#%1111100001111000,488+16(a6)
			eori.w	#%1100110000110000,648+16(a6)
			eori.w	#%1111110000110000,808+16(a6)
			eori.w	#%1111100000110000,968+16(a6)
			eori.w	#%1111110011111100,008+32(a6)
			eori.w	#%1111110011111100,168+32(a6)
			eori.w	#%0000000000000000,328+32(a6)
			eori.w	#%1111100000110000,488+32(a6)
			eori.w	#%1100000000110000,648+32(a6)
			eori.w	#%1111110011111000,808+32(a6)
			eori.w	#%1111110011111100,968+32(a6)
			eori.w	#%1111110011000111,008+40(a6)
			eori.w	#%1111110011001110,168+40(a6)
			eori.w	#%0000110000011100,328+40(a6)
			eori.w	#%0000110011110000,488+40(a6)
			eori.w	#%0000110011011100,648+40(a6)
			eori.w	#%0111110011001110,808+40(a6)
			eori.w	#%1111100011000111,968+40(a6)
			add.w	#1,KIE
			cmp.w	#5,KIE
			bne		J05			
			jsr		SWAPSCREEN
J05:		movem.l	(sp)+,a0-a7/d0-d7
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
			move.b	3(a0),$fff820d
SW02:		cmp.w	#1,KID
			bne		SW03
			move.l	#EKRAN2,(a0)
			move.b	1(a0),$fff8201
			move.b	2(a0),$fff8203
			move.b	3(a0),$fff820d
SW03:		rts

*-+---------------------------------------------------------------------+-*

STRONICE:	rte

*-+---------------------------------------------------------------------+-*

TIMER000:rte

TIMER00:	move.l	#TIMER01,$120
*			move.w	#$000,$fff8240
			move.w	#$888,$fff8242
			move.w	#$111,$fff8244
			move.w	#$999,$fff8246
			move.w	#$222,$fff8248
			move.w	#$aaa,$fff824a
			move.w	#$333,$fff824c
			move.w	#$bbb,$fff824e
			rte
TIMER01:	move.l	#TIMER02,$120
			move.w	#$444,$fff8250
			move.w	#$ccc,$fff8252
			move.w	#$555,$fff8254
			move.w	#$ddd,$fff8256
			move.w	#$666,$fff8258
			move.w	#$eee,$fff825a
			move.w	#$777,$fff825c
			move.w	#$fff,$fff825e
			rte
TIMER02:	move.l	#TIMER03,$120
			rte
TIMER03:	move.l	#TIMER04,$120
			rte
TIMER04:	move.l	#TIMER05,$120
			rte
TIMER05:	move.l	#TIMER06,$120
			rte
TIMER06:	move.l	#TIMER07,$120
			rte
TIMER07:	move.l	#TIMER08,$120
			rte
TIMER08:	move.l	#TIMER09,$120
			rte
TIMER09:	move.l	#TIMER10,$120
			rte 
TIMER10:	move.l	#TIMER11,$120
			rte
TIMER11:	move.l	#TIMER12,$120
			rte
TIMER12:	move.l	#TIMER13,$120
			rte
TIMER13:	move.l	#TIMER14,$120
			rte
TIMER14:	move.l	#TIMER15,$120
			rte
TIMER15:	move.l	#TIMER16,$120
			rte
TIMER16:	move.l	#TIMER17,$120
			rte
TIMER17:	move.l	#TIMER18,$120
			rte
TIMER18:	move.l	#TIMER19,$120
			rte
TIMER19:	move.l	#TIMER20,$120
			rte
TIMER20:	move.l	#TIMER21,$120
			rte
TIMER21:	move.l	#TIMER22,$120
			rte
TIMER22:	move.l	#TIMER23,$120
			rte
TIMER23:	move.l	#TIMER24,$120
			rte
TIMER24:	move.l	#TIMER25,$120
			rte
TIMER25:	move.l	#TIMER26,$120
			rte
TIMER26:	move.l	#TIMER27,$120
			rte
TIMER27:	move.l	#TIMER28,$120
			rte
TIMER28:	move.l	#TIMER29,$120
			rte
TIMER29:	move.l	#TIMER30,$120
			rte
TIMER30:	move.l	#TIMER31,$120
			rte
TIMER31:	move.l	#TIMER32,$120
			rte
TIMER32:	move.l	#TIMER33,$120
			rte
TIMER33:	move.l	#TIMER34,$120
			rte
TIMER34:	move.l	#TIMER35,$120
			rte
TIMER35:	move.l	#TIMER36,$120
			rte
TIMER36:	move.l	#TIMER37,$120
			rte
TIMER37:	move.l	#TIMER38,$120
			rte
TIMER38:	move.l	#TIMER39,$120
			rte
TIMER39:	move.l	#TIMER40,$120
			rte
TIMER40:	move.l	#TIMER41,$120
			rte
TIMER41:	move.l	#TIMER42,$120
			rte
TIMER42:	move.l	#TIMER43,$120
			rte
TIMER43:	move.l	#TIMER44,$120
			rte
TIMER44:	move.l	#TIMER45,$120
			rte
TIMER45:	move.l	#TIMER46,$120
			rte
TIMER46:	move.l	#TIMER47,$120
			rte
TIMER47:	move.l	#TIMER48,$120
			rte
TIMER48:	move.l	#TIMER49,$120
			rte
TIMER49:	move.l	#TIMER50,$120
			rte
TIMER50:	move.l	#TIMER51,$120
			rte
TIMER51:	move.l	#TIMER52,$120
			rte
TIMER52:	move.l	#TIMER53,$120
			rte
TIMER53:	move.l	#TIMER54,$120
			rte
TIMER54:	move.l	#TIMER55,$120
			rte
TIMER55:	move.l	#TIMER56,$120
			rte
TIMER56:	move.l	#TIMER57,$120
			rte
TIMER57:	move.l	#TIMER58,$120
			rte
TIMER58:	move.l	#TIMER59,$120
			rte
TIMER59:	move.l	#TIMER60,$120
			rte
TIMER60:	move.l	#TIMER61,$120
			rte
TIMER61:	move.l	#TIMER62,$120
			rte
TIMER62:	move.l	#TIMER63,$120
			rte
TIMER63:	move.l	#TIMER64,$120
			rte
TIMER64:	move.l	#TIMER65,$120
			rte
TIMER65:	move.l	#TIMER66,$120
			rte
TIMER66:	move.l	#TIMER67,$120
			rte
TIMER67:	move.l	#TIMER68,$120
			rte
TIMER68:	move.l	#TIMER69,$120
			rte
TIMER69:	move.l	#TIMER70,$120
			rte
TIMER70:	move.l	#TIMER71,$120
			rte
TIMER71:	move.l	#TIMER72,$120
			rte
TIMER72:	move.l	#TIMER73,$120
			rte
TIMER73:	move.l	#TIMER74,$120
			rte
TIMER74:	move.l	#TIMER75,$120
			rte
TIMER75:	move.l	#TIMER76,$120
			rte
TIMER76:	move.l	#TIMER77,$120
			rte
TIMER77:	move.l	#TIMER78,$120
			rte
TIMER78:	move.l	#TIMER79,$120
			rte
TIMER79:	move.l	#TIMER80,$120
			rte
TIMER80:	move.l	#TIMER81,$120
			rte
TIMER81:	move.l	#TIMER82,$120
			rte
TIMER82:	move.l	#TIMER83,$120
			rte
TIMER83:	move.l	#TIMER84,$120
			rte
TIMER84:	move.l	#TIMER85,$120
			rte
TIMER85:	move.l	#TIMER86,$120
			rte
TIMER86:	move.l	#TIMER87,$120
			rte
TIMER87:	move.l	#TIMER88,$120
			rte
TIMER88:	move.l	#TIMER89,$120
			rte
TIMER89:	move.l	#TIMER90,$120
			rte
TIMER90:	move.l	#TIMER91,$120
			rte
TIMER91:	move.l	#TIMER92,$120
			rte
TIMER92:	move.l	#TIMER93,$120
			rte
TIMER93:	move.l	#TIMER94,$120
			rte
TIMER94:	move.l	#TIMER95,$120
			rte
TIMER95:	move.l	#TIMER96,$120
			rte
TIMER96:	move.l	#TIMER97,$120
			rte
TIMER97:	move.l	#TIMER98,$120
			rte
TIMER98:	move.l	#TIMER99,$120
			rte
TIMER99:	move.l	#TIMERBB,$120
			rte
TIMERBB:	move.l	#TIMER_B,$120
			bclr.b 	#0,$fffa0f
			move.b 	#0,$fffa1b
			move.b 	#228-101,$fffa21
			move.b 	#8,$fffa1b
			rte

*-+---------------------------------------------------------------------+-*

TIMER_B:	move.w	d6,-(sp)		
			rept	24		
			nop			nop 
			endr			
			clr.w	d6		
			move.b	$ffff8209,d6
			neg.b	d6
			add.b	#192,d6
			lsl.b	d6,d6	
			move.w	#18,d6		
PAUSE:		dbra	d6,PAUSE		
	  		move.b	#0,$ffff820a	
			rept	12		
			nop			nop 
			endr			
			move.b	#2,$ffff820a	
			move.w	(sp)+,d6		
			rte

*-+---------------------------------------------------------------------+-*

TIMER_A:	move.w	#$2100,sr
			stop	#$2100		
			clr.b	$fffffa19	
			rept	78		
			nop
			endr			
			clr.b	$ffff820a
			nop
			nop
			move.b	#2,$ffff820a	
			rte			

*-+---------------------------------------------------------------------+-*

CIEMNO:		move.w	#$000,$fff8240
			move.w	#$000,$fff8242
			move.w	#$000,$fff8244
			move.w	#$000,$fff8246
			move.w	#$000,$fff8248
			move.w	#$000,$fff824a
			move.w	#$000,$fff824c
			move.w	#$000,$fff824e
			move.w	#$000,$fff8250
			move.w	#$000,$fff8252
			move.w	#$000,$fff8254
			move.w	#$000,$fff8256
			move.w	#$000,$fff8258
			move.w	#$000,$fff825a
			move.w	#$000,$fff825c
			move.w	#$000,$fff825e
			rts

*-+---------------------------------------------------------------------+-*

SAFEREG: 	ds.l 	10
			even
KID:		dc.w	1
			even
KIE:		dc.w	1
			even
KIC:		dc.w	1
			even
PAM:		dc.l	1
			even
TAB:		incbin	"\asembler.s\dane.dat\DAT00000.VAN"
			even
TOR:		incbin	"\asembler.s\dane.dat\TOR.VA1"
			dc.w	9999,9999
TOREK:		dc.l	1
			even
RYS:		incbin	"\asembler.s\dane.dat\TOR1.VAN"
			even
MUSIC:		incbin	"\asembler.s\dane.dat\SECTORI1.MUS"
			even

*-+---------------------------------------------------------------------+-*
