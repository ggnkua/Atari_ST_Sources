.globl	packen
*************************************************************************
* STAD - Packroutine (c) Peter Melzer
*
* 10.6.86 (erstes dokumentiertes Datum)
* Last Touch:	14.2.90
* Screen im STAD 1.x Format packen nur bei 640*400.
*
* IN:	a2	Screen
*	a3	dorthin packen, max. Grîûe 2*$7d00+?(ca. 100)
* OUT:	d3.L	>0	gepackte LÑnge, ok
*	d0.w	0 	ok
*		$ff00	Fehler horipack, Screen wird grîûer als $7d00
*		$f0ff   Fehler veripack, "
*		$ffff	bei beiden
*	a3	dort stehts
********************************* packen ********************************
packen:
	move.l	a3,packstart	* merken
        movea.l	a3,a1		* Statistik aufstellen
        moveq	#127,d0
        moveq	#0,d1
pckclrstat:
        move.l	d1,(a1)+
        dbf     d0,pckclrstat   * 512 bytes lîschen
        movea.l	a2,a4		* Screenadresse
        movea.l	a3,a1     	* 256.w feld fÅr jede rel. adresse
        move.w  #31999,d1       *  hÑufigkeit der adr=byte im feld
packstat:
        clr.w   d0
        move.b  (a4)+,d0
        add.w   d0,d0
        addq.w  #1,(a1,d0)                
        dbf     d1,packstat
        movea.l	a3,a1     	* minimum suchen
        moveq   #2,d1           * die beiden minimums suchen (<>0)
        moveq   #2,d2
        move.w  (a1,d1),d0
        addq.w  #2,d1
packmins:
        cmp.w   (a1,d1),d0
        ble     packmin1
        move.w  (a1,d1),d0
        move.w  d1,d2           * neues Minimum (jetzt 1.)
packmin1:
        addq.w  #2,d1
        cmpi.w  #512,d1
        blt     packmins
        move.w  d2,packbyte     * doppeltes minium <> 0 wird packbyte

        moveq   #2,d1           * die beiden minimums suchen (<>0)
        moveq   #2,d2
        move.w  (a1,d1),d0
        addq.w  #2,d1
packmns:
        cmp.w   (a1,d1),d0
        ble     packmn1
        cmp.w   packbyte,d1     * falls packbyte, dann nicht
        beq     packmn1
        move.w  (a1,d1),d0
        move.w  d1,d2           * neues Minimum (jetzt 1.)
packmn1:
        addq.w  #2,d1
        cmpi.w  #512,d1
        blt     packmns
*
        cmp.w   packbyte,d2
        bne     packm3
        addq.w  #2,d2           * falls gleich !!
        cmpi.w  #$200,d2
        bne     packm3
        addq.w  #2,d2
packm3:
        move.w  d2,packspez     * wird packspez byte
*
        clr.w   d1
        clr.w   d2
        move.w  (a1,d1),d0      * wert des maximums suchen
pakmi:
        addq.w  #2,d1
        cmp.w   (a1,d1),d0
        bge     pakm2
        move.w  (a1,d1),d0
        move.w  d1,d2
pakm2:
        cmpi.w  #512,d1
        bne     pakmi
        move.w  d2,packwert     * dopp. byte, das am hÑufigsten vorkommt
        clr.w   pckerrflag
        bsr     horipack        * horiz. packen nach a3
	move.l	a3,d0      	
	btst	#0,d0
	beq	packnext
	addq.l	#1,a3
packnext:
	lea	20(a3),a3	* neue Startposition, gerade, kl. Buffer
	move.l	a3,-(a7)	
        bsr     vertpack        * verti. packen
	move.l	(a7)+,a3
	move.w	pckerrflag,d0
	bmi	pack_err
	move.l	packanz,d3
	cmp.l	packhanz,d3
	ble	pack_err     	* VERT. war besser
	movea.l	packstart,a3 	* HORI. war besser
	move.l	packhanz,d3
pack_err:
	tst.w	d0
	rts
******************************* horiz packen ***************************
* IN:	a2	Base
*	a3	dorthin
* OUT:	a3	bis dahin
* anzahl in packhanz
horipack:
        move.l  #7,packhanz
        clr.w   pckfflag        * wichtig fÅr ende
        move.w  packbyte,d4
        lsr.w   #1,d4
        move.w  packspez,d5
        lsr.w   #1,d5
        move.w  packwert,d6
        lsr.w   #1,d6
        movea.l a2,a4
        move.l  #$704d3835,(a3)+        * Kennung pM85
        move.b  d4,(a3)+                * packbyte
        move.b  d6,(a3)+                * packwert
        move.b  d5,(a3)+                * packspez
        move.w  #32000,d2
        clr.w   d0
        move.b  (a4)+,d0
pckhl0:
        clr.w   d1
pckhl1:
        subq.w  #1,d2
        bpl     pckhnofin
        st      pckfflag        * Ende signalisieren
        bra     pckhchange
pckhnofin:
        cmp.b   (a4)+,d0
        bne     pckhchange
        addq.w  #1,d1
        cmpi.w  #256,d1
        bne     pckhl1
        subq.w  #1,d1
        bra     pckh1
pckhchange:
        cmpi.w  #2,d1
        bge     pckh1           * falls >=3
        cmpi.w  #1,d1
        blt     pckh0
        cmp.b   d0,d5
        beq     pckh2
        cmp.b   d0,d4
        beq     pckh2
        move.b  d0,(a3)+        * nur zweimal
        move.b  d0,(a3)+
        addq.l  #2,packhanz
        bra     pckhcall
pckh0:
        cmp.b   d0,d5
        beq     pckh2
        cmp.b   d0,d4
        beq     pckh2
        move.b  d0,(a3)+
        addq.l  #1,packhanz
        bra     pckhcall
pckh1:
        cmp.b   d0,d6
        bne     pckh2
        move.b  d4,(a3)+        * packbyte
        move.b  d1,(a3)+        * Anzahl 1 weniger ! der d6'en
        addq.l  #2,packhanz
        bra     pckhcall
pckh2:
        move.b  d5,(a3)+        * packspez
        move.b  d0,(a3)+        * byte
        move.b  d1,(a3)+        * Anzahl
        addq.l  #3,packhanz
pckhcall:
        cmpi.l  #$7d00,packhanz
        bgt     pckherrfin
        move.b  -1(a4),d0
        tst.w   pckfflag        * Ende
        beq     pckhl0
        rts
pckherrfin:
        or.w    #$ff00,pckerrflag
        rts
        
************************* vertikal packen ********************************
* IN:	a2	Base
*	a3	dorthin
vertpack:
        move.l  #7,packanz
        clr.w   pckfflag
        move.w  packbyte,d4
        lsr.w   #1,d4
        move.w  packspez,d5
        lsr.w   #1,d5
        move.w  packwert,d6
        lsr.w   #1,d6
	movea.l	a2,a4
	movea.l	a3,a2			* war halt so ..
        lea	-80(a4),a4
        movea.l a4,a3
        move.l  #$704d3836,(a2)+        * Kennung pM86
        move.b  d4,(a2)+
        move.b  d6,(a2)+
        move.b  d5,(a2)+
        move.w  #32000,d2
        move.w  #400,d3  * zeilen
        lea	80(a3),a3
        move.b  (a3),d0         * erstes byte 
pckvrl0:
        clr.w   d1
pckvrl1:
        subq.w  #1,d2
        bpl     pckvnofin       * ende wie bei horiz. packen
        st      pckfflag
        bra     pckvchange
pckvnofin:
        sub.w   #1,d3
        bne     pckvr0
        move.w  #400,d3
        movea.l a4,a3
        addq.l  #1,a3
        movea.l a3,a4
pckvr0:
        lea	80(a3),a3
        cmp.b   (a3),d0
        bne     pckvchange
        addq.w  #1,d1
        cmpi.w  #256,d1
        bne     pckvrl1
        subq.w  #1,d1
        bra     pckv1
pckvchange:
        cmpi.w  #2,d1
        bge     pckv1           * falls >=3
        cmpi.w  #1,d1
        blt     pckv0
        cmp.b   d0,d5
        beq     pckv2
        cmp.b   d0,d4
        beq     pckv2
        move.b  d0,(a2)+        * nur zweimal
        move.b  d0,(a2)+
        addq.l  #2,packanz
        bra     pckvcall
pckv0:
        cmp.b   d0,d5
        beq     pckv2
        cmp.b   d0,d4
        beq     pckv2
        move.b  d0,(a2)+
        addq.l  #1,packanz
        bra     pckvcall
pckv1:
        cmp.b   d0,d6
        bne     pckv2
        move.b  d4,(a2)+        * packbyte
        move.b  d1,(a2)+        * Anzahl 1 weniger ! der d6'en
        addq.l  #2,packanz
        bra     pckvcall
pckv2:
        move.b  d5,(a2)+        * packspez
        move.b  d0,(a2)+        * byte
        move.b  d1,(a2)+        * Anzahl
        addq.l  #3,packanz
pckvcall:
        cmpi.l  #$7d00,packanz
        bgt     pckverrfin
        move.b  (a3),d0
        tst     pckfflag
        beq     pckvrl0
        rts
pckverrfin:
        or.w    #$F0FF,pckerrflag
        rts
.data
pckfflag:
	.dc.w	0
packhanz:
	.dc.l	0
packanz:
	.dc.l	0
pckerrflag:
	.dc.w	0
packwert:
	.dc.w	0
packspez:
	.dc.w	0
packbyte:
	.dc.w	0
packstart:
	.dc.l	0
		

