
demostart:
	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp

	;dc.w $a00a

	lea ptrscr,a0
	move.l #screen+256,d0
	clr.b d0
	move.l d0,(a0)+
	add.l #32000,d0
	move.l d0,(a0)
	


	jsr wvbl
	move.b $ffff8260.w,demostart
	move.b #0,$ffff8260.w
	move.w #$2700,sr
	move.l $70.w,demostart+2
	move.l #itvbl,$70.w
	move.w #$2300,sr

	MOVE.L ptrscr,a0
	moveq #0,d0
	move.w #7999,d1
cls	move.l d0,(a0)+
	move.l d0,(a0)+
	dbf d1,cls

	lea $ffff8240.w,a0
	lea demostart+6,a1
	move.l (a0)+,(a1)+
		
	

	jsr init_generatedCode
	jsr init_cls
	jsr prepbloccode
;	moveq #64-1,d7
;loop:	move.w d7,-(sp)
;
;	lea lstptrcode,a6
;	move d7,d0
;	mulu #16*4,d0
;	add d0,a6
;	move.l (a6),a6
;
;	move.b #%10000000,d0
;	move.b #%1000000,d1
;	move.b #%100000,d2
;	move.b #%10000,d3
;	move.b #%1000,d4
;	move.b #%100,d5
;	move.b #%10,d6
;	move.b #%1,d7
;	move.l $44e.w,a0
;	jsr (a6)
;
;	move.w (sp)+,d7
;
;	dbra d7,loop
;	
	jsr initWaves

	move.w #0,$ffff8240.w
	move.w #$777,$ffff8242.w 

main
	cmp.b #$b9,$fffffc02.w
	beq.w fin
	
	        * not.w $ffff8240.w

	;jsr waitscanline40
	move.w #$131,$ffff8240.w
	jsr calcwave
	;move.w #$30,$ffff8240.w



	move.l ptrscr,a0
	moveq #0,d0
	jsr codecls
	;jsr clear_circle

	

	;move.w #$300,$ffff8240.w	
	move.b #%10000000,d0
	move.b #%1000000,d1
	move.b #%100000,d2
	move.b #%10000,d3
	move.b #%1000,d4
	move.b #%100,d5
	move.b #%10,d6
	move.b #%1,d7
	lea result,a6
	move.l ptrscr,a0

	move.w #$2700,sr
	move.l sp,arrivepc+6
	lea result,sp
	;move.w #$2300,sr
	rts
;	rept 96*2
;	move.l (a6)+,a5
;	jsr (a5)
	
;	endr
	
arrivepc: move.w #$2700,sr
	  move.l #$12345678,sp
	  move.w #$2300,sr

	;move.w #0,$ffff8240.w	

	
	*not.w $ffff8240.w
	
	
	move.l ptrscr,d0
	lsr.w #8,d0
	move.l d0,$ffff8200.w

	move.l ptrscr,d0
	move.l ptrscr+4,d1
	move.l d1,ptrscr
	move.l d0,ptrscr+4


	;not $ffff8240.w
	;not $ffff8240.w
	jsr wvbl

	
	bra main
itvbl	addq.l #1,$466.w
	rte

fin
	
	jsr wvbl
	move.l $44e.w,d0
	lsr.w #8,d0
	move.l d0,$ffff8200.w
	move.w #$777,$ffff8240.w
	move.b demostart,$ffff8260.w
	move.w #$2700,sr
	move.l demostart+2,$70.w
	move.w #$2300,sr
	move.l  demostart+6,$ffff8240.w
	jsr wvbl
	;dc.w $a009

	clr.w -(sp)
	trap #1
	

wvbl:	move.w $468.w,d0
.loop	cmp.w $468.w,d0
		beq.s .loop
		rts




init_generatedCode
;_mkconvx
	lea convX,a0
	moveq #0,d1
	move.w #$0200,d2	+0200= or.b d1,dep(a0) puis or.b d2,dep(a0), etc..

.0	move #$8128,d0
.1	
	move.w d0,(a0)+
	move.w d1,(a0)+
	add d2,d0
	cmp.w #$8128+8*$200,d0
	bne.s .1
	
	addq #1,d1
	move.w #$8128,d0
.2	
	move.w d0,(a0)+
	move.w d1,(a0)+
	
	add d2,d0
	cmp.w #$8128+8*$200,d0
	bne.s .2
	addq #7,d1
	
	cmp.w #8*20,d1
	bne.s .0
;_mkconvx fin

	lea lstptrcode,a3
	lea bsscode,a1
	lea convX,a2
	
	
	moveq #96-1,d7
.looptaille:
	

	move.w d7,d6
	addq #4,d6
	add d6,d6			; d6=64*2 au depart
	
	move.w #16-1,d5			nombre de position intermediaire (anglewrap)
	lea circletable,a0
	
.loopAngle:
	move.w d5,-(sp)
	move.l a1,(a3)+
	
	move.w #32-1,d5
.loopCircle
	
	move.w (a0)+,d0		; x
	move.w (a0)+,d1		; y
	ext.l d0
	ext.l d1
	
	muls d6,d0
	muls d6,d1
	swap d0
	swap d1
	;add.w #96-48,d0		; + centre
	add.w #159,d0		; 160
	add.w #99,d1

	;move.w d6,d3		
	;lsr #2,d3
	;add d3,d0

	; now a partir de d2 et d3 on creer un or.b dn,dep(a0)
	; a2 = convX 1 pixel (pas de subpixel)
	; d0 = x
	move.w d0,d3
	add d3,d3
	add d3,d3
	move.l (a2,d3),d4
	; calcul de l'offset adequat: int(d2/16)*8+d3*160
	
	; mulu #160,d1
	lsl #5,d1  *32
	move.w d1,d3
	; * 128 + *32
	;lsl #2,d3  *128;
	add d3,d3
	add d3,d3
	add d3,d1  *160
	
	add d1,d4
	move.l d4,(a1)+
	dbra d5,.loopCircle
	move.w #$4e75,(a1)+
	
	move.w (sp)+,d5
	dbra d5,.loopAngle
	
	dbra d7,.looptaille
	rts

init_cls:
	lea lstptrcode,a6
	move.l ptrscr,a0
	move.w #96*16-1,d0
	move.w #$e5e5,d1
	move.w d1,d2
	move.w d1,d3
	move.w d1,d4
	move.w d1,d5
	move.w d1,d6
	move.w d1,d7
.loop
	move.w d0,-(sp)
	move.w #$ffff,d0

	move.l (a6)+,a5
	jsr (a5)
	move.w (sp)+,d0
	dbf d0,.loop
	lea codecls,a1
	move.l ptrscr,a0
	moveq #0,d5
	move.w #20*200-1,d2
.scan	move.w (a0)+,d0
	tst.w d0
	beq.s .ok
	move.w #$3140,(a1)+
	move.w d5,(a1)+
.ok
	addq.l #6,a0
	addq.w #8,d5
	dbf d2,.scan
	move.w #$4e75,(a1)+
	moveq #0,d0
	move.l ptrscr,a0
	jsr codecls
	rts 

initOneWave
; d0 = rayon
; d1 = pas interne
	lea sinwave,a0
	lea buffer1,a1
	move.w #511,d7
		
	move.w d0,d2
	add d2,d2
	
.loop
	move.w (a0)+,d4
	muls d2,d4
	swap d4
	add d0,d4
	add d4,d4
	add d4,d4
	move.w d4,(a1)+
	dbf d7,.loop
	
	lea buffer1,a0
	move.l a6,a1			; reftablesinus
	move.w d1,d0			; pas interne
	move.w #96*2,d1
	move.w #512,d2
	bsr createSpecialSin
	
	rts
	
initWaves
		move.w #50,d0
		move.w #512-2,d1
		LEA memoire,a2
		lea refs1,a6
		bsr initOneWave
	
		move.w #64,d0
		move.w #4,d1
		lea refs2,a6
		bsr initOneWave
		
		move.w #65,d0
		move.w #512-1,d1
		lea refs3,a6
		bsr initOneWave

		move.w #20,d0
		move.w #5,d1
		lea refs4,a6
		bsr initOneWave


		
		rts
prepbloccode
		lea cgcalcul1,a0

		move.w #95,d0
.loop0		lea bloccode1,a1
		lea finbloccode1,a2
		bsr .cpy
;.cpy		move.w (a1)+,(a0)+
;		cmp.l a1,a2
;		bne.s .cpy
		dbf d0,.loop0
		move.w #$4e75,(a0)+
		
		lea cgcalcul2,a0
		move.w #95,d0
.loop1		lea bloccode2,a1
		lea finbloccode2,a2
		bsr .cpy
;.cpy2		move.w (a1)+,(a0)+
;		cmp.l a1,a2
;		bne.s .cpy2
		dbf d0,.loop1
		move.w #$4e75,(a0)+
		rts
.cpy		move.w (a1)+,(a0)+
		cmp.l a1,a2
		bne.s .cpy
		rts
bloccode1
		lea -64(a5),a5
bloccode2	move.w (a0)+,d0
		add (a1)+,d0
		add (a2)+,d0
		add (a3)+,d0
		lsr #2,d0
		and d1,d0
		move.l (a5,d0.w),(a6)+
finbloccode1
		lea 64(a5),a5
finbloccode2


	
calcwave
		lea refs1,a6
		move.w curangle1,d0
		add d0,d0
		add d0,d0
		move.l (a6,d0),a0
		
		lea refs2,a6
		move.w curangle2,d0
		add d0,d0
		add d0,d0
		move.l (a6,d0),a1
		
		lea refs3,a6
		move.w curangle3,d0
		add d0,d0
		add d0,d0
		move.l (a6,d0),a2

		lea refs4,a6
		move.w curangle4,d0
		add d0,d0
		add d0,d0
		move.l (a6,d0),a3


		
		lea result,a6
		lea lstptrcode+64*96,a5
		move.w #%0000000000111100,d1
		jsr cgcalcul1
;		moveq #23,d2
;.bcl1		rept 4
;		lea -64(a5),a5
;		move.w (a0)+,d0
;		add (a1)+,d0
;		add (a2)+,d0
;		add (a3)+,d0
;		lsr #1,d0
;		and d1,d0
;		move.l (a5,d0.w),(a6)+
;		;lea 32(a5),a5
;		endr
;		dbf d2,.bcl1
		lea lstptrcode,a5


;		moveq #23,d2
		jsr cgcalcul2
;.bcl2		rept 4
;		
;		move (a0)+,d0
;		add (a1)+,d0
;		add (a2)+,d0
;		add (a3)+,d0
;		lsr #1,d0
;		and d1,d0
;		move.l (a5,d0.w),(a6)+
;		lea 64(a5),a5
;		endr
;		dbf d2,.bcl2
	
		move.l #arrivepc,(a6)+

		
		move.w curangle1,d0
		add #5,d0
		and #511,d0
		move.w d0,curangle1
		
		move.w curangle2,d0
		add #512-1,d0
		and #511,d0
		move.w d0,curangle2
		
		move.w curangle3,d0
		add #3,d0
		and #511,d0
		move.w d0,curangle3

		move.w curangle4,d0
		add #1,d0
		and #511,d0
		move.w d0,curangle4
		
		rts	
	
createSpecialSin
; a0 = table sinus de n element
; a1 = reftablesinus
; a2 = buffer resultat
; d0 = pas interne
; d1 = nombre de copie de valeur
; d2 = nombre n d'element de la table sinus
; retour = d1 : nombre de memoire occupé sur buffer resultat

	move.w d2,d3
	lea bufferFlag,a3
	subq #1,d3
.clrflag
	clr.b (a3)+
	dbra d3,.clrflag
	

	move.w d2,d3	; 512 ou 1024
	subq #1,d3		; 511  ou 1023 pour le and de l'angle

	lea bufferFlag,a3
	subq #1,d2		; 511 ou 1023 iteration
	moveq #0,d4		; angle
.loop
	tst.b (a3,d4)	; flag a 1 ?
	bne.s .flagA1
.flagA0
	move.w d4,d5
	add d5,d5
	move.w (a0,d5),(a2)
	add d5,d5
	move.l a2,(a1,d5)			; a2 referencer en reftable+angle*4
	addq.l #2,a2
	st (a3,d4)		positione flag(angle) a 1
	add d0,d4		; pas interne
	and d2,d4		; mod 512 ou 1022
	bra.s .loop
.flagA1	; copier d1 fois les valeurs suivante
	move.w d4,d5		; angle courant copier sur d5
	move.w d1,d7
	subq #1,d7
.cpy
	move.w d5,d6
	add d6,d6
	move.w (a0,d6),(a2)+
	add d0,d5	
	and d2,d5
	dbf d7,.cpy
	
	sub d0,d4
	addq #1,d4
	and d2,d4
	tst.b (a3,d4)
	bne.s .fin
	bra .flagA0
.fin
	rts
	
;clear_circle:
;		; a0 = ecran+offset ou on doit effacer l'effet
;
;	lea 32(a0),a0	
;	moveq #0,d0
;	move.w #99,d7		; 64*2 ligne = 128 lignes
;	
;.loop
;	move.w d0,(a0)
;	move.w d0,8(a0)
;	move.w d0,16(a0)
;	move.w d0,24(a0)
;	move.w d0,32(a0)
;	move.w d0,40(a0)
;	move.w d0,48(a0)
;	move.w d0,56(a0)
;	move.w d0,64(a0)
;	move.w d0,72(a0)
;	move.w d0,80(a0)
;	move.w d0,88(a0)
;
;	move.w d0,160(a0)
;	move.w d0,168(a0)
;	move.w d0,176(a0)
;	move.w d0,184(a0)
;	move.w d0,192(a0)
;	move.w d0,200(a0)
;	move.w d0,208(a0)
;	move.w d0,216(a0)
;	move.w d0,224(a0)
;	move.w d0,232(a0)
;	move.w d0,240(a0)
;	move.w d0,248(a0)
;	
;	lea 320(a0),a0
;	dbf d7,.loop
;	rts
	
	

	DATA
sinwave:	incbin 'sinwave.dat'
circletable: incbin 'cerc512.dat'
curangle1	dc.w 0
curangle2	dc.w 2
curangle3	dc.w 10
curangle4	dc.w 100
	BSS

ptrscr
	ds.l 2
screen	ds.b 256
	ds.w 32000

lstptrcode	ds.l 64*96*4
buffer1	ds.w 512
bufferFlag	ds.b 512
refs1	ds.l 512
refs2	ds.l 512
refs3	ds.l 512
refs4	ds.l 512
	ds.l 50		; pour it
result	ds.l 96*2
	ds.l 1
	
convX	ds.l 320
bsscode	ds.l 512*96		; 64 cercle de 256 bset
		ds.w 16*96		; 8 'angle'*64 cercles rts

codecls	ds.l 4001
cgcalcul1	ds.b 22*96+2
cgcalcul2	ds.b 22*96+2
memoire	ds.l 32000
		
