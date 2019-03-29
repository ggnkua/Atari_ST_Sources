;
;                  flexi-scroll source lalala
;
; SORRY for the englishmen,englishwoomen,bref,the no-speaker in french
; cause my english is awful.toutefois, you can look at the schema in
; my article peut etre que you were understand more enfin you are doing
; what you want...In fact i am good in english cause it's only about
; seven years before i begin to learn english at school ...
;  (incredible,no?)
;

;
;                    SOURCE MACHIN EN POINT
;
; coded by TARIUS and GLOKY y'a 2 ans 
; fonte by TSB
; prog originale avec quelque modifs sans consequences..
; (comme l'allegement du fichier fonte,l'astuce des movems expliqu‚e
; dans l'article,et ces macros tres inutiles...
; (je les ai jamais utilis‚ car je suis trop bordelique !!!)

; 300 KILO A l'ASSEMBLAGE feront toujours la differences...


super	macro
	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #2,sp
	move.l d0,(sp)
	endm
rez	macro 
	move.b #\1,$ffff8260.w
	endm
init_pal	macro
	lea \2,a1
	lea $ffff8240.w,a0
	movem.l (a0),d0-d7
	movem.l d0-d7,(a1)
	lea \1,a1
	movem.l (a1),d0-d7
	movem.l d0-d7,(a0)
	endm

move_32	macro 
	movem.l \1,d0-d7
	movem.l d0-d7,\2
	endm
ze_end	macro	
	move.w #$20,-(sp)
	trap #1
	addq.l #2,sp
	clr.w -(sp)
	trap #1
	endm
vsync	macro
	move.w #$25,-(sp)
	trap #14
	addq.l #2,sp
	endm	

cls	macro
	move.l \1,a0
	move.w #7999,d0
	moveq #0,d1
	move.l d1,(a0)+
	dc.l $51c8fffc
	endm

*allons y !!!
ICI:
DEBUT:
START:
COMMENCEMENT:
ouaiiii	super
	rez 0
	init_pal palette,spalette
	move.l $44e.w,screen
	cls screen

*******************************
** ON GENERE LA TABLE DE EOR **
*******************************

	lea lettres,a1
	lea mega,a0
	lea tabl_lettre,a2
	moveq #7,d7	; d7 numero de bit  } = "compteur"
	moveq #0,d6	; d6 octet (offset)	} =
	move.w #60,d5
	move.b (a1)+,d6	; 1er octet (aah c'est emouvant...)
;			(surtout que j'ai passer 2h a chercher un
;			bug la ou y'en avait pas a cause de ce move
;			stupide  qui se trouvait pas ou il fallait
;			(du coup un decalage de trop a chaque fois))
all_letters
	move.w #32*32-1,d0
	moveq.w #0,d1	; offset
	moveq #0,d3	; compteur de point d'affill‚	
	moveq #0,d4	; d4=flag 
	move.l a0,(a2)+

one_letter
; balayage fichier

.si	btst d7,d6	;
	beq.s .0
	or.w #$FF00,d6	; flag=true    d6.w =|flag|octet|
	bra .1
.0	and.w #$00FF,d6 	; flag=false : pas de point
.1	subq.w #1,d7	; mise a jour no bit
	bpl.s .2		
	moveq #7,d7	; si d7 < 0
	move.b (a1)+,d6

; TEST : y'a t'il un point ? (d'apres flag)
.2	move.w d6,d4	TEST FLAG 
	lsr #8,d4
	tst.b d4		;
	bne .sinon
; ici y'a pas de point
	tst d3		; oui mais y'a eu des points avant ?
	bne.s .ya_des_points	;
	addq.w #4,d1	
	bra .finsi
.sinon	addq.w #1,d3
	cmp.w #4,d3
	beq.w .point4	; cas ou compteur au maximum....
	ADDQ.W #4,D1
	bra .finsi

.ya_des_points		; routine en fonction de d3
	cmp.w #1,d3	;   d3= nb de points
	beq.s .normal	
	move.w d3,-(sp)
	lsl #2,d3
	sub.w d3,d1
	move.w (sp),d3
	jsr .code_movem
	move.w (sp)+,d3
	lsl #2,d3
	add.w d3,d1
	addq.w #4,d1
	clr.w d3
	bra .finsi
	
.normal	subq.w #4,d1
	move.w #$3229,(a0)+
	move.w d1,(a0)+
	addq.w #2,d1
	move.w #$3029,(a0)+
	move.w d1,(a0)+
	addq.w #6,d1		; ?? SURE ?
	move.l #$b1701000,(a0)+
	clr.w d3
.finsi
	dbf d0,one_letter
	
	move.w #$4e75,(a0)+

	dbf d5,all_letters				
	bra big_bcl
*****************************************
* routine plusieurs points consecutifs. *
*****************************************
.instruction
	dc.w $F,$3f,$ff
.ins1	eor.w d1,(a0,d0.w)
	eor.w d3,(a0,d2.w)
	eor.w d5,(a0,d4.w)
	eor.w d7,(a0,d6.w)

; movem + eors en fonction de d3	d3=2,3 ou 4 = nb de point
;				d1=offset premier point
.code_movem
	
	move.w d3,-(sp)
	move.w d1,d4	; offset
	subq.w #2,d3	; 2-4 --> 0-2
	lsl #1,d3		; d3*2   0,2,4
	lea .instruction,a3	; ??? utilis‚ ???
	move.w #$4CA9,(a0)+	; = MOVEM
	move.w (a3,d3.w),(a0)+	; code du movem +0000
	move.w d4,(a0)+	; + offset de depart

	lea .ins1,a4	; adresse code EOR
	move.w (sp)+,d3	; n=2,3 ou 4
	lsl.w #1,d3	; proportionnel
	subq.w #1,d3
.loop	move.w (a4)+,(a0)+
	dbra.w d3,.loop
	CLR.W D3
.ICI	rts
************************************************
.point4	sub.w #12,d1
	jsr .code_movem
	add.w #16,d1
	clr.w d3
	bra .finsi
************************************************

big_bcl	move.w #0,$ffff8240.w

wvbl	vsync
	cmp.b #$38,$fffffc02.w
	bne no_tps	
	move.w #7,$ffff8240.w	
no_tps	moveq.l #1,d3
dodo	
	move.l screen,a0
	move.l ouaffiche,a1
	move.l (a1),a1
	;lea 16*4*10(a1),a1
	move.l outexte,a5
	move.l decal,d5
	add.l d5,a1 
	move.l #10,d6

affiche_letter
	clr.l d5
	move.b (a5)+,d5

	sub.b #32,d5
	add.w d5,d5
	add.w d5,d5
	lea tabl_lettre,a3

	add.l d5,a3
	move.l (a3),a3
	MOVEM.W D0-D7,-(SP)
	jsr (a3)
	MOVEM.W (SP),D0-D7
	LEA 16(SP),SP
	add.l #32*4*32,a1
	dbf d6,affiche_letter

	cmp.b #36,(a5)
	bne .finsit
	add.l #4,ouaffiche
	move.l ouaffiche,a5
	add.l #1,outexte
	tst.l (a5)
	bne .finsit
	move.l #affiches,ouaffiche
.finsit

	sub.l #32*4,decal
	cmp.l #0,decal
	bge .finsi2
	move.l #32*31*4,decal
	add.l #1,outexte
	move.l outexte,a5
	cmp.l #fintexte,a5
	bne .finsi2
	move.l #texte,outexte
	add.l #4,ouaffiche
	move.l ouaffiche,a5

	tst.l (a5)
	bne .finsi2
	move.l #affiches,ouaffiche	
.finsi2
	
	dbf d3,dodo
	
	cmp.b #$b9,$fffffc02.w
	bne big_bcl
	
fin	move_32 spalette,$ffff8240.w
	ze_end

	DATA
lettres	incbin	fonte.fnt

affiche	ds.l 32*32
	incbin	cercle2.tab
	ds.l 32*32

affiche2	ds.l 32*32
	incbin	cercle.tab
	ds.l 32*32

affiche3	ds.l 32*32
	incbin	xcarre.tab
	ds.l 32*32

ouaffiche	dc.l affiches
affiches	dc.l affiche,affiche2,affiche3,0

DECAL	dc.l 32*4*31
addtable	dc.w 19200
outexte	dc.l texte

texte	DCB.B 12,32
	dc.b ' EH OUI JE CHANGE DE SCROLLTEXT'
	DC.B ' AUJOURD HUI 23/12/1991 A 3:00'
	DCB.B 12,32
	dc.b 36

	DCB.B 12,32
	DC.B ' JE SUIS CONTENT DE VIVRE MAIS UN PEU'
	DC.B ' FATIGUE..GLOKMAN NE VEUT PAS PRENDRE DE CAFE'
	DC.B '    ...    TANT PIS    ...      SNIFF'
fintexte	DCB.B 25,32
	DC.B 0
	even

palette	dc.w 0
	dc.w $421,$7,$117
	dcb.w 12,7
	
	BSS
spalette	ds.w 16
screen	ds.l 1
tabl_lettre	ds.l 61	
mega	ds.b 30000	; plus si les fontes plus compliqu‚		
