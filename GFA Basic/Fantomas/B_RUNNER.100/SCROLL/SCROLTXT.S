; *----------------------------------------------------*
; 
; ð Scroll 1 plan en mode 256 couleurs pour falcon 030 ð
;           ½ Michel Goux (Fantomas) 1995 
;
; *----------------------------------------------------*


	opt	o+

           lea txt(pc),a0
           lea ptr(pc),a1
           move.l a0,(a1)
           lea scroll_vbl(pc),a0
           move.l a0,$4d6
           rts

; ---------------------------------
;
; Routine install‚e sous VBL -$4d6-
;
; ---------------------------------

scroll_vbl:
	movem.l 	d0-d7/a0-a6,-(sp)
           lea 	txt(pc),a4
           lea 	ptr(pc),a5
           lea 	bit(pc),a6
           moveq 	#0,d0
           move.b 	(a6),d0
           cmp.b 	#8,d0
           bne.s 	plusloin3
           clr.b 	(a6)
           move.l 	(a5),a1
           moveq 	#0,d0
           move.b 	(a1),d0
           cmp.b 	#255,d0
           bne.s 	lsuite
	move.l 	a4,(a5)
           move.l 	(a5),a1
           moveq 	#0,d0
           move.b 	(a1),d0
lsuite:
	addq.l 	#1,(a5)
           asl.l 	#3,d0
           lea 	font(pc),a1
           add.l 	d0,a1
           lea 	buffer(pc),a2

; --- CARACTERE -> BUFFER ---

           move.b 	(a1)+,(a2)
           move.b 	(a1)+,2(a2)
           move.b 	(a1)+,4(a2)
           move.b 	(a1)+,6(a2)
           move.b 	(a1)+,8(a2)
           move.b 	(a1)+,10(a2)
           move.b 	(a1)+,12(a2)
plusloin3:
	add.b 	#2,(a6)

; --- Buffer + petit scroll a gauche ---

           moveq	#1,d0
one_more:
	lea 	trav(pc),a1
           lea 	buffer(pc),a2
           moveq 	#6,d1
encore:
	roxl 	(a2)+
           roxl 	38(a1)
           roxl 	36(a1)
           roxl 	34(a1)
           roxl 	32(a1)
           roxl 	30(a1)
           roxl 	28(a1)
           roxl 	26(a1)
           roxl 	24(a1)
           roxl 	22(a1)
           roxl 	20(a1)
           roxl 	18(a1)
           roxl 	16(a1)
           roxl 	14(a1)
           roxl 	12(a1)
           roxl 	10(a1)
           roxl 	8(a1)
           roxl 	6(a1)
           roxl 	4(a1)
           roxl 	2(a1)
           roxl 	(a1)
           lea 	40(a1),a1
           dbra 	d1,encore
           dbra 	d0,one_more      

; --- TRAVAIL -> ECRAN ---

           move.l 	$44e,a1
           add.l	#192*320,a1
           lea 	trav(pc),a2
           moveq 	#6,d0
gloop:
	move.w 	(a2)+,(a1)
           move.w 	(a2)+,16(a1)
           move.w 	(a2)+,32(a1)
           move.w 	(a2)+,48(a1)
           move.w 	(a2)+,64(a1)
           move.w 	(a2)+,80(a1)
           move.w 	(a2)+,96(a1)
           move.w 	(a2)+,112(a1)
           move.w 	(a2)+,128(a1)
           move.w 	(a2)+,144(a1)
           move.w 	(a2)+,160(a1)
           move.w 	(a2)+,176(a1)
           move.w 	(a2)+,192(a1)
           move.w 	(a2)+,208(a1)
           move.w 	(a2)+,224(a1)
           move.w 	(a2)+,240(a1)
           move.w 	(a2)+,256(a1)
           move.w 	(a2)+,272(a1)
           move.w 	(a2)+,288(a1)
           move.w 	(a2)+,304(a1)
           lea 	320(a1),a1
           dbra 	d0,gloop

           movem.l 	(sp)+,d0-d7/a0-a6
           rts

; ****************************
;
; DONNEES ET VARIABLES LSCROLL
;
; ****************************

ptr:
	dc.l 	0
trav:
	dc.w 	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
           dc.w 	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
           dc.w 	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
           dc.w 	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
           dc.w 	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
           dc.w 	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
           dc.w 	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
buffer:
	dc.w 	0,0,0,0,0,0,0,0
bit:
        	dc.b 	0
fla:
        	dc.b 	0
font:
	incbin 	"FONT_8X8.DAT"
txt:
	incbin 	"TEXTE.DAT"
	dc.b	255

	rts
	rts

