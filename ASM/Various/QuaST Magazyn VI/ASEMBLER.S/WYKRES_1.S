***************************************************************************
* Q u a s t  V I - programowanie w assemblerze							  *
***************************************************************************
* program  		 - Wykresy - czyli drgamy w rytm muzyki              	  *
* autor    		 - Van Eijk											      *
* typ Atari		 - ST/E												      *
***************************************************************************

START:
	clr	-(sp)				* Supervisor
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp

	move.w #0,-(sp)     	* wlaczenie niskiej rozdzielczosci
	move.l #-1,-(sp)
	move.l #-1,-(sp)
	move.w #5,-(sp)
	trap #14
	add.l #12,sp                                                                                               

	move.l #KLAWISZE,-(sp)	* wylaczenie myszki
	move.w #0,-(sp)
	move.w #25,-(sp)
   	trap #14
	addq.l #8,sp

    clr.w -(A7)                    
    pea $78000                     
    pea $78000                     
    move.w #5,-(A7)                
    trap #14                       
    adda.l #12,A7       	* ustawiamy adres ekranu

	bclr #0,$484.w			* wylaczamy dzwiek klawiszy
	moveq #1,d0				* wybieramy muzyczke o nr.1
	jsr MUSIC				
	move.w #$0,$ffff8240

	move.l #KOLORY,KOL      * paleta kolorow do rastra
	move.l #SAFEREG,a0		* zapamietujemy wartosci zegarow i przerwan
	move.b $fffa07,(a0)+
	move.b $fffa09,(a0)+
	move.b $fffa0b,(a0)+
	move.b $fffa0f,(a0)+
	move.b $fffa13,(a0)+
	move.b $fffa17,(a0)+
	move.b $fffa1b,(a0)+
	move.b $fffa1d,(a0)+
	move.b $fffa21,(a0)+
	move.l $70,OLDVBL
	move.l $120,OLDTIMERB

	move.b #8,$fffa1b		* ustawiamy nowe wartosci zegarow i przerwan
	move.b #1,$fffa21
	ori.b #%00000001,$fffa07
	andi.b #%11011111,$fffa09
	ori.b #%00000001,$fffa13
	move.l #VBL,$70
	move.l #TIMERB,$120

LOOP:						* oczekiwanie na klawisz
	cmp.b #185,$fffc02		* jesli nie wcisniety to idz do LOOP
	bne.s LOOP

END:
	move.l OLDVBL,$70		* zwrocenie starych wartosci przerwan i zegarow
	move.l OLDTIMERB,$120
	move.w #$0,$ff8240                
	move.l #SAFEREG,a0
	move.b (a0)+,$fffa07
	move.b (a0)+,$fffa09
	move.b (a0)+,$fffa0b
	move.b (a0)+,$fffa0f
	move.b (a0)+,$fffa13
	move.b (a0)+,$fffa17
	move.b (a0)+,$fffa1b
	move.b (a0)+,$fffa1d
	move.b (a0)+,$fffa21
	move.b #$f7,$fffa23
	
	moveq #0,d0				* wylaczenie muzyczki
	jsr MUSIC

	move.l #KLAWISZE2,-(sp)	* wlaczenie myszki
	move.w #0,-(sp)
	move.w #25,-(sp)
	trap #14
	addq.l #8,sp
	move.w #$777,$ffff8240  * kolor tla na bialy
	move.w #$000,$ffff8246  * kolor liter na czarny
	clr.w  -(sp)			* wyjscie z programu
	trap 	#1

VBL:						* przerwania VBLa
	move.l #KOLORY,KOL
	jsr WYKRESY
	jsr MUZYKA
	rte

WYKRESY:					* procedura rysowania i scierania wykresow
	move.l #$78000+160*199+8,a0
	move.w #110,d0
CZYSC:    					* czyszczenie ekranu
	clr.w 	(a0)
	clr.w 	8(a0)
	clr.w 	16(a0)
	clr.w	24(a0)
	clr.w	32(a0)
	clr.w	48(a0)
	clr.w	48+8(a0)
	clr.w	48+16(a0)
	clr.w	48+24(a0)
	clr.w	48+32(a0)
	clr.w	96(a0)
	clr.w	96+8(a0)
	clr.w	96+16(a0)
	clr.w	96+24(a0)
	clr.w	96+32(a0)
	sub.l #160,a0
	dbf d0,CZYSC

	move.l #$78000+160*199+8,a0			* pierwszy wykres
	clr.l d0
	move.b #8,$ff8800
	move.b $ff8800,d0

SLUPEK1:
	move.w #%1111111111111111,-320(a0)
	move.w #%1111111111111111,-480(a0)
	move.w #%1111111111111111,-640(a0)
	move.w #%1111111111111111,-800(a0)
	move.w #%1111111111111111,-960(a0)
	move.w #%1111111111111111,-1120(a0)
	move.w #%1111111111111111,-1280(a0)
	move.w #%1111111111111111,-1440(a0)
	move.w #%1111111111111111,-320+8(a0)
	move.w #%1111111111111111,-480+8(a0)
	move.w #%1111111111111111,-640+8(a0)
	move.w #%1111111111111111,-800+8(a0)
	move.w #%1111111111111111,-960+8(a0)
	move.w #%1111111111111111,-1120+8(a0)
	move.w #%1111111111111111,-1280+8(a0)
	move.w #%1111111111111111,-1440+8(a0)
	move.w #%1111111111111111,-320+16(a0)
	move.w #%1111111111111111,-480+16(a0)
	move.w #%1111111111111111,-640+16(a0)
	move.w #%1111111111111111,-800+16(a0)
	move.w #%1111111111111111,-960+16(a0)
	move.w #%1111111111111111,-1120+16(a0)
	move.w #%1111111111111111,-1280+16(a0)
	move.w #%1111111111111111,-1440+16(a0)
	move.w #%1111111111111111,-320+24(a0)
	move.w #%1111111111111111,-480+24(a0)
	move.w #%1111111111111111,-640+24(a0)
	move.w #%1111111111111111,-800+24(a0)
	move.w #%1111111111111111,-960+24(a0)
	move.w #%1111111111111111,-1120+24(a0)
	move.w #%1111111111111111,-1280+24(a0)
	move.w #%1111111111111111,-1440+24(a0)
	move.w #%1111111111111111,-320+32(a0)
	move.w #%1111111111111111,-480+32(a0)
	move.w #%1111111111111111,-640+32(a0)
	move.w #%1111111111111111,-800+32(a0)
	move.w #%1111111111111111,-960+32(a0)
	move.w #%1111111111111111,-1120+32(a0)
	move.w #%1111111111111111,-1280+32(a0)
	move.w #%1111111111111111,-1440+32(a0)
	sub.l #960,a0
	dbf d0,SLUPEK1

	move.l #$78000+160*199+48,a0		* drugi wykres
	add.l #8,a0
	clr.l d0
	move.b #9,$ff8800
	move.b $ff8800,d0

SLUPEK2:
	move.w #%1111111111111111,-320(a0)
	move.w #%1111111111111111,-480(a0)
	move.w #%1111111111111111,-640(a0)
	move.w #%1111111111111111,-800(a0)
	move.w #%1111111111111111,-960(a0)
	move.w #%1111111111111111,-1120(a0)
	move.w #%1111111111111111,-1280(a0)
	move.w #%1111111111111111,-1440(a0)
	move.w #%1111111111111111,-320+8(a0)
	move.w #%1111111111111111,-480+8(a0)
	move.w #%1111111111111111,-640+8(a0)
	move.w #%1111111111111111,-800+8(a0)
	move.w #%1111111111111111,-960+8(a0)
	move.w #%1111111111111111,-1120+8(a0)
	move.w #%1111111111111111,-1280+8(a0)
	move.w #%1111111111111111,-1440+8(a0)
	move.w #%1111111111111111,-320+16(a0)
	move.w #%1111111111111111,-480+16(a0)
	move.w #%1111111111111111,-640+16(a0)
	move.w #%1111111111111111,-800+16(a0)
	move.w #%1111111111111111,-960+16(a0)
	move.w #%1111111111111111,-1120+16(a0)
	move.w #%1111111111111111,-1280+16(a0)
	move.w #%1111111111111111,-1440+16(a0)
	move.w #%1111111111111111,-320+24(a0)
	move.w #%1111111111111111,-480+24(a0)
	move.w #%1111111111111111,-640+24(a0)
	move.w #%1111111111111111,-800+24(a0)
	move.w #%1111111111111111,-960+24(a0)
	move.w #%1111111111111111,-1120+24(a0)
	move.w #%1111111111111111,-1280+24(a0)
	move.w #%1111111111111111,-1440+24(a0)
	move.w #%1111111111111111,-320+32(a0)
	move.w #%1111111111111111,-480+32(a0)
	move.w #%1111111111111111,-640+32(a0)
	move.w #%1111111111111111,-800+32(a0)
	move.w #%1111111111111111,-960+32(a0)
	move.w #%1111111111111111,-1120+32(a0)
	move.w #%1111111111111111,-1280+32(a0)
	move.w #%1111111111111111,-1440+32(a0)
	sub.l #960,a0
	dbf d0,SLUPEK2

	move.l #$78000+160*199+88,a0		* trzeci wykres
	add.l #16,a0
	clr.l d0
	move.b #10,$ff8800
	move.b $ff8800,d0

SLUPEK3:
	move.w #%1111111111111111,-320(a0)
	move.w #%1111111111111111,-480(a0)
	move.w #%1111111111111111,-640(a0)
	move.w #%1111111111111111,-800(a0)
	move.w #%1111111111111111,-960(a0)
	move.w #%1111111111111111,-1120(a0)
	move.w #%1111111111111111,-1280(a0)
	move.w #%1111111111111111,-1440(a0)
	move.w #%1111111111111111,-320+8(a0)
	move.w #%1111111111111111,-480+8(a0)
	move.w #%1111111111111111,-640+8(a0)
	move.w #%1111111111111111,-800+8(a0)
	move.w #%1111111111111111,-960+8(a0)
	move.w #%1111111111111111,-1120+8(a0)
	move.w #%1111111111111111,-1280+8(a0)
	move.w #%1111111111111111,-1440+8(a0)
	move.w #%1111111111111111,-320+16(a0)
	move.w #%1111111111111111,-480+16(a0)
	move.w #%1111111111111111,-640+16(a0)
	move.w #%1111111111111111,-800+16(a0)
	move.w #%1111111111111111,-960+16(a0)
	move.w #%1111111111111111,-1120+16(a0)
	move.w #%1111111111111111,-1280+16(a0)
	move.w #%1111111111111111,-1440+16(a0)
	move.w #%1111111111111111,-320+24(a0)
	move.w #%1111111111111111,-480+24(a0)
	move.w #%1111111111111111,-640+24(a0)
	move.w #%1111111111111111,-800+24(a0)
	move.w #%1111111111111111,-960+24(a0)
	move.w #%1111111111111111,-1120+24(a0)
	move.w #%1111111111111111,-1280+24(a0)
	move.w #%1111111111111111,-1440+24(a0)
	move.w #%1111111111111111,-320+32(a0)
	move.w #%1111111111111111,-480+32(a0)
	move.w #%1111111111111111,-640+32(a0)
	move.w #%1111111111111111,-800+32(a0)
	move.w #%1111111111111111,-960+32(a0)
	move.w #%1111111111111111,-1120+32(a0)
	move.w #%1111111111111111,-1280+32(a0)
	move.w #%1111111111111111,-1440+32(a0)
	sub.l #960,a0
	dbf d0,SLUPEK3
 	rts

TIMERB:						* przerwanie TIMERa B
	movem.l a0-a1,-(sp)
	move.b #4,$fffa21
	move.l KOL,a1
	move.w (a1),$ff8242
	move.w (a1)+,$ff8246
	move.l a1,KOL
	bclr.b #0,$fffa0f
	movem.l (sp)+,a0-a1
	rte						* powrot z przerwania

MUZYKA:	
	movem.l d0-d7/a0-a6,-(sp)			* zapamietanie rejestrow
	bsr (MUSIC+8)				        * skok do muzyki
	movem.l (sp)+,d0-d7/a0-a6			* zwrocenie rejestrow
	rts					call old vbl
MUSIC:		incbin "a:\asembler.s\dane.dat\big_alec.mus"

KLAWISZE:	dc.b $12
KLAWISZE2:	dc.b  $08

KOL: 		ds.l 1
OLDVBL:		ds.l 1
OLDTIMERB: 	ds.l 1
SAFEREG: 	ds.b 10
	even

KOLORY:						* kolory w wykresach
		dc.w $100,$200,$300,$400,$500
		dc.w $600,$700,$710,$720,$730
		dc.w $740,$750,$760,$770,$771
		dc.w $772,$773,$774,$774,$774
		dc.w $777,0,0,0

		dc.w $001,$002,$003,$004
		dc.w $005,$006,$007,$117
		dc.w $227,$337,$447,$557
		dc.w $667,$766,$755
		dc.w $744,$733,$722,$711
		dc.w $700,$600,$500,$400
		dc.w $300,$200,$1000
 
