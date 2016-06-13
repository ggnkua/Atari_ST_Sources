
*                     MEKANNIK DESTRUCTIV KOMMANDO

		OPT O+,W-

*----------------------------------------------------------------
*     Buffers pour le scolling du bas et lettres sur ecran
*----------------------------------------------------------------

* occupation des buf(i) = 15360 octets = $3C00
tab_buf  equ $68000 

buf1     equ tab_buf+160*13*0     
buf2     equ tab_buf+160*13*1
buf3     equ tab_buf+160*13*2
buf4     equ tab_buf+160*13*3

* occupation des st(i) = 768 octets = $300

tab_st   equ tab_buf+160*13*4
st1      equ tab_st+8*13*0
st2      equ tab_st+8*13*1
st3      equ tab_st+8*13*2
st4      equ tab_st+8*13*3   

* occupation total des tabst(i)+tabbuf(i)+bufsp(i) =  $3F00

*------------------------

degas2	equ $70000

*------------------------------------------------*
*            Debut de l'intro			 *
*------------------------------------------------*
debut 	bra	start
	
	dc.b	'cette intro a ete programmee par Metal68 de M.D.K'
	
start	move.l  sp,pile       
	movea.l $04(sp),a5
        move.l  $08(a5),begin

	move.l  #$7FFF0,-(sp)         
	move.w  #$20,-(sp)    
	trap    #1
	addq.l  #6,sp
	move.l  d0,stack      
 
        movem.l buffer,d0-d7
	movem.l d0-d7,$FF8240
	    
        dc.w    $A00A
        move.b  #$12,$FFFC02
        
        move.w 	#2,-(sp)
        trap #14
        addq.l  #2,sp
        move.l  d0,adecran
        
	clr.w   -(sp)         
	move.l  #$78000,-(sp)
	move.l  #$78000,-(sp)
	move.w  #$05,-(sp)
	trap    #14
	lea     12(sp),sp
               
	lea     $78000,a3 		* affiche le dessin
	lea     pic+34,a5
	bsr     Compact

	lea     degas2,a3 		* decompacte les lettres
	lea     lettre+34,a5
	bsr     Compact

	bsr     Razbuf			*efface les buffers
	bsr     table			*init table d'adresse des lettres
	bsr     detour
 	bsr     music
 	
Debut   move.b $FFFC02,d0
	cmpi.b #$39,d0
	bne    Debut

Fin    	lea     $4CE,a1
	lea     buffer,a0
	move.l  (a0)+,$452
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)
	move.l  (a0)+,$502
        move.l  (a0)+,$70
        move.l  (a0)+,$118
        move.l  (a0)+,$120
        lea     $FFFA00,a1
        move.b  (a0)+,$07(a1)
        move.b  (a0)+,$09(a1)       
        move.b  (a0)+,$0F(a1)    
        move.b  (a0)+,$13(a1)     
        move.b  (a0)+,$1B(a1)      
        move.b  (a0)+,$21(a1)
    
	move.b #$07,$FF8800
	ori.b  #$3F,$FF8802
	
	move.w  #0,-(sp)        
	move.l  adecran,-(sp)
	move.l  adecran,-(sp)
	move.w  #$05,-(sp)
	trap    #14
	add.l   #12,sp
	
	move.b  #3,$484
	dc.w    $A009
	move.b  #$08,$FFFC02

	move.l  stack,-(sp)         
	move.w  #$20,-(sp)    
	trap    #1
	addq.l  #6,sp
	move.l  pile,sp      

	clr.l -(sp)
	trap #1
	
 include reloc.s       
*--------------------------------------------------------------
*           effacer les 4 buffers de scrolling 
*--------------------------------------------------------------

Razbuf 	lea	tab_buf,a0
       	lea	tab_st,a1
    	moveq  	#0,d0
Razbu1 	move.w 	d0,(a0)+
	cmpa.l	a0,a1
	bne	Razbu1
   	rts
        
*-------------------------------------------------------------*
*  vecteur des lettres
*-------------------------------------------------------------*
       
table  movea.l #degas2,a0       * les pointeurs sont mis a la place
       movea.l #lettre1,a2       * des lettres compactees
       moveq   #4,d0
ta2    movea.l a0,a3
       moveq   #19,d1
ta1    move.l  a0,(a2)+
       adda.l  #8,a0
       dbra    d1,ta1
       move.l  a3,a0
       adda.l  #13*160,a0
       dbra    d0,ta2
       rts

*----------------------------------------------------------------
*          Detournement des interruption VBL et HBL 
*----------------------------------------------------------------

detour	move.w  sr,-(sp)
	ori.w   #$700,sr
	lea     $4CE,a0
	lea     buffer,a1
	move.l  $452,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0),(a1)+
	move.l  $502,(a1)+
	move.l  $70,(a1)+
	move.l  $118,(a1)+
	move.l  $120,(a1)+
        lea     $FFFA00,a0
        move.b  $07(a0),(a1)+
        move.b  $09(a0),(a1)+        
        move.b  $0F(a0),(a1)+        
        move.b  $13(a0),(a1)+        
        move.b  $1B(a0),(a1)+        
        move.b  $21(a0),(a1)+ 
               
        move.l  $118,acia1+2
        move.l  #acia,$118
        
        move.l  $70,vbl1+2
        move.l  #vbl,$70

	andi.b  #$DE,$FFFA07
	andi.b  #$CF,$FFFA09
	move.l  #Hbl_1,$120
	ori.b   #1,$FFFA07
	ori.b   #1,$FFFA13
	
	move.l  #alt_help,$502
	
	move.l  #inverse,$4CE
        move.l  #Scroll,$4D2
        move.l  #rebond,$4D6
* 4DA : music
        move.w  #4,$452
        move.w  #4,$454
             
	move.w  (sp)+,sr
	rts
	
buffer	dc.l 0	* 452 et 454
        dc.l 0  * 4CE
        dc.l 0  * 4D2
        dc.l 0  * 4D6
        dc.l 0  * 4DA
        dc.l 0  * 4DE
        dc.l 0  * 4E2
        dc.l 0  * 502
        dc.l 0  * 70
        dc.l 0  * 118
        dc.l 0  * 120
        dc.l 0  * FA07,09,0F,13
        dc.w 0  * FA1B,21

alt_help rts        

*----------------------------------------------------------------
*            Interruption acia ( clavier ou midi )
*----------------------------------------------------------------

acia   move.w  #$2300,sr
acia1  jmp     $00000000

*----------------------------------------------------------------
*      Interruption VBL et reinitialisation des couleurs
*----------------------------------------------------------------

vbl      movem.l d0-d7,-(sp)

         clr.b   $FFFA1B
         move.b  #80,$FFFA21
         move.b  #8,$FFFA1B
         move.l  #Hbl_1,$120

         movem.l pic+2,d0-d7
         movem.l d0-d7,$FF8240

         movem.l (sp)+,d0-d7
vbl1	 jmp     $00000000

*----------------------------------------------------------------
*                     Interruption HBL  
*----------------------------------------------------------------


Hbl_1	clr.b   $FFFA1B
	movem.l d0-d7,-(sp)
	movem.l lettre+2,d0-d7
	movem.l d0-d7,$FF8240
	movem.l (sp)+,d0-d7
	move.b  #15,$FFFA21
	move.b  #8,$FFFA1B
	move.l  #Hbl_2,$120
	move.b  #0,$FFFA0F
        rte   


Hbl_2   clr.b   $FFFA1B
        movem.l d1/a5/a6,-(sp)
        
        movea.w #$824A,a6
        movea.l #couleur,a5
        moveq #4,d1
H1	move.l (a5)+,(a6)+
	dbra d1,H1
	move.w (a5),(a6)

        movea.w #$FA21,a6
	move.b  #2,(a6)
        move.b  #8,$FFFA1B
        move.b  (a6),d1
Hbl_21  cmp.b   (a6),d1
        beq     Hbl_21
        nop
        nop
        nop
        nop
	move.l ptcoul,a5
	move.l (a5)+,$FF8246
   	move.l (a5)+,$FF8242
	move.l a5,ptcoul
	cmp.l  #0,(a5)
        beq    fin_hbl       
        movem.l (sp)+,d1/a5/a6
        move.b  #0,$FFFA0F
        rte   


fin_hbl	subq.w #1,time
	beq    Hbl_120
	sub.l  #2*36*4,ptcoul
	bra    fin_h1
Hbl_120	move.w #3,time
	addq.l #8,ptcoul
 
fin_h1	movem.l (sp)+,d1/a5/a6
        clr.b   $FFFA1B
        move.b  #0,$FFFA0F
        rte   


couleur dc.w $001,$002,$103,$214
	dc.w $325,$436,$547,$657,$320,$540,$760
time dc.w 3
*------------------------------------
*-------------------------------------
rebond	subq.w #1,bfois
	bne	re7
	move.w  #6,bfois
	
	lea	$78000+160*104,a3
	move.w	b1,d0
	addq.w	#1,b1
	and.w	#7,b1
	asl.w	#2,d0
	lea	tabal1,a0
	move.l  (a0,d0.w),a0
	move.w	b2,d0
	addq.w	#1,b2
	and.w	#7,b2
	asl.w	#2,d0
	lea	tabal2,a1
	move.l  (a1,d0.w),a1
	
	moveq	#40,d0
re6	movem.l (a0),d1-d4	* adresse 1ere balle
	movem.l (a1),d5-d7/a6	* adresse 2eme balle
	movem.l d1-d4,(a3)
	movem.l d5-d7/a6,144(a3) * adresse ecran
	lea	160(a0),a0
	lea	160(a1),a1
	lea	160(a3),a3
	dbra	d0,re6
re7	rts
	
bfois dc.w 6
b1 dc.w 0
b2 dc.w 2
tabal1	dc.l balle+16*0
	dc.l balle+16*1
	dc.l balle+16*2
	dc.l balle+16*3
	dc.l balle+16*3
	dc.l balle+16*2
	dc.l balle+16*1
	dc.l balle+16*0
	
tabal2	dc.l balle+16*7
	dc.l balle+16*6
	dc.l balle+16*5
	dc.l balle+16*4
	dc.l balle+16*4
	dc.l balle+16*5
	dc.l balle+16*6
	dc.l balle+16*7
	
*--------------
*inverse
*----------

inverse	cmp.l 	#fincoul,ptcoul
	bne	inv3
	movea.l #coula,a0
inv1	move.l  (a0),d0
	swap    d0
	move.l  d0,(a0)+
	cmp.l	#fincoul,a0
	bne	inv1
	move.l  #coula,ptcoul
inv3	rts	
*------------------------------------------------------
*      routines de scroll (Scroll ) et decompactage (decom)
*------------------------------------------------------

 include sc_dec.s
music include soccer.s
 
*----------------------------------------------------------------
*                             Data
*----------------------------------------------------------------
	section data               

adecran dc.l 0
cmpt_let dc.w 0000
branch   dc.w 0000
mem1     dc.l 0000
mem2     dc.l 0000
tab1     dc.l st1
         dc.l st2
         dc.l st3
         dc.l st4
adresse  dc.l ad4
         dc.l ad1
         dc.l ad2
         dc.l ad3

ptcoul  dc.l coula

coula	
	dc.w $111,$413,4,7

	dc.w $504,$111,4,7

	dc.w $111,$514,4,7
	dc.w $504,$111,4,7

	dc.w $514,$222,4,7
	dc.w $605,$333,4,7
	dc.w $111,$514,4,7
	
	dc.w $222,$605,4,7
	dc.w $333,$625,4,7
	dc.w $444,$706,4,7
	dc.w $555,$716,4,7
	
	dc.w $625,$222,$000,$413
	dc.w $706,$333,$111,$504
	dc.w $716,$444,$222,$514
	dc.w $726,$555,$333,$605
	dc.w $736,$666,$444,$625
	
	dc.w $222,$706,$504,$000
	dc.w $333,$716,$514,$111
	dc.w $444,$726,$605,$222
	dc.w $555,$736,$625,$333
	dc.w $666,$746,$706,$444
	dc.w $666,$746,$706,$444
	dc.w $777,$756,$716,$555

	dc.w $726,$222,$000,$605
	dc.w $736,$333,$111,$625
	dc.w $736,$333,$111,$625
	dc.w $746,$444,$222,$706
	dc.w $746,$444,$222,$706
	dc.w $756,$555,$333,$716
	dc.w $756,$555,$333,$716
	dc.w $766,$666,4,7
	dc.w $766,$666,4,7
	dc.w $777,$777,4,7
	dc.w $777,$777,4,7
	dc.w $766,$666,4,7
	dc.w $746,$444,4,7
	dc.l 0,0
coulb	
	dc.w $413,$111,4,7

	dc.w $111,$504,4,7

	dc.w $514,$111,4,7
	dc.w $111,$514,4,7

	dc.w $504,$111,4,7
	dc.w $514,$222,4,7
	dc.w $605,$333,4,7
	
	dc.w $222,$514,4,7
	dc.w $333,$605,4,7
	dc.w $444,$625,4,7
	dc.w $555,$706,4,7
	
	dc.w $555,$716,$514,$333
	dc.w $706,$222,$000,$504
	dc.w $716,$333,$111,$514
	dc.w $726,$444,$222,$605
	dc.w $736,$555,$333,$625
	
	dc.w $736,$666,$444,$625
	dc.w $222,$706,$504,$000
	dc.w $333,$716,$514,$111
	dc.w $444,$726,$605,$222
	dc.w $555,$736,$625,$333
	dc.w $555,$736,$625,$333
	dc.w $666,$746,$706,$444

	dc.w $666,$746,$706,$444
	dc.w $777,$756,$716,$555
	dc.w $726,$333,$111,$605
	dc.w $736,$333,$111,$625
	dc.w $746,$444,$222,$706
	dc.w $746,$444,$222,$706
	dc.w $756,$555,$333,$716
	dc.w $756,$555,4,7
	dc.w $766,$666,4,7
	dc.w $766,$666,4,7
	dc.w $777,$777,4,7
	dc.w $766,$666,4,7
	dc.w $746,$444,4,7
	dc.l 0,0

coulc	
	dc.w $111,$413,4,7

	dc.w $504,$111,4,7

	dc.w $514,$111,4,7
	dc.w $111,$514,4,7

	dc.w $222,$514,4,7
	dc.w $514,$111,4,7
	dc.w $605,$222,4,7
	
	dc.w $625,$333,4,7
	dc.w $222,$605,4,7
	dc.w $333,$625,4,7
	dc.w $444,$706,4,7
	
	dc.w $444,$716,$514,$222
	dc.w $555,$726,$605,$333
	dc.w $716,$222,$000,$514
	dc.w $726,$333,$111,$605
	dc.w $736,$444,$222,$625
	
	dc.w $736,$555,$333,$625
	dc.w $746,$666,$444,$706
	dc.w $222,$716,$514,$000
	dc.w $333,$726,$605,$111
	dc.w $444,$736,$625,$222
	dc.w $555,$736,$625,$333
	dc.w $555,$746,$706,$333

	dc.w $666,$746,$706,$444
	dc.w $666,$756,$716,$444
	dc.w $777,$756,$716,$555
	dc.w $726,$333,$111,$605
	dc.w $736,$444,$222,$625
	dc.w $746,$444,$222,$706
	dc.w $746,$555,$333,$706
	dc.w $756,$555,4,7
	dc.w $756,$666,4,7
	dc.w $766,$666,4,7
	dc.w $766,$666,4,7
	dc.w $756,$555,4,7
	dc.w $746,$444,4,7
	dc.l 0,0

could	
	dc.w $413,$111,4,7

	dc.w $111,$504,4,7

	dc.w $504,$111,4,7
	dc.w $111,$504,4,7

	dc.w $222,$605,4,7
	dc.w $605,$111,4,7
	dc.w $625,$222,4,7
	
	dc.w $706,$333,4,7
	dc.w $716,$444,4,7
	dc.w $222,$625,4,7
	dc.w $333,$706,4,7
	
	dc.w $444,$716,$514,$222
	dc.w $555,$726,$605,$333
	dc.w $666,$736,$625,$444
	dc.w $716,$222,$000,$514
	dc.w $726,$333,$111,$605
	
	dc.w $736,$333,$111,$625
	dc.w $746,$444,$222,$706
	dc.w $756,$555,$333,$716
	dc.w $756,$666,$444,$716
	dc.w $222,$726,$605,$000
	dc.w $333,$736,$625,$111
	dc.w $444,$746,$706,$222

	dc.w $555,$746,$706,$333
	dc.w $555,$756,$716,$333
	dc.w $666,$756,$716,$444
	dc.w $666,$756,$716,$444
	dc.w $777,$766,$726,$555
	dc.w $777,$766,$726,$555
	dc.w $736,$444,$222,$625
	dc.w $746,$444,4,7
	dc.w $746,$555,4,7
	dc.w $756,$555,4,7
	dc.w $756,$666,4,7
	dc.w $746,$555,4,7
	dc.w $736,$333,4,7
	dc.l 0,0

coule	
	dc.w $111,$413,4,7

	dc.w $504,$111,4,7

	dc.w $514,$111,4,7
	dc.w $111,$514,4,7

	dc.w $222,$605,4,7
	dc.w $333,$625,4,7
	dc.w $605,$111,4,7
	
	dc.w $625,$222,4,7
	dc.w $625,$333,4,7
	dc.w $706,$444,4,7
	dc.w $222,$706,4,7
	
	dc.w $333,$706,$504,$111
	dc.w $444,$716,$514,$222
	dc.w $555,$726,$605,$333
	dc.w $666,$736,$625,$444
	dc.w $716,$222,$000,$514
	
	dc.w $726,$333,$111,$605
	dc.w $736,$444,$222,$625
	dc.w $746,$555,$333,$706
	dc.w $746,$666,$444,$706
	dc.w $756,$666,$444,$716
	dc.w $766,$777,$555,$726
	dc.w $222,$736,$625,$000

	dc.w $333,$736,$625,$111
	dc.w $444,$746,$706,$222
	dc.w $444,$746,$706,$222
	dc.w $555,$756,$716,$333
	dc.w $555,$756,$716,$333
	dc.w $666,$766,$726,$444
	dc.w $666,$766,$726,$444
	dc.w $777,$766,4,7
	dc.w $777,$777,4,7
	dc.w $756,$555,4,7
	dc.w $766,$666,4,7
	dc.w $756,$555,4,7
	dc.w $736,$333,4,7
	dc.l 0,0

fincoul
pic	incbin	total.pc1
lettre	incbin	metal.pc1
lettre1 equ lettre+34
balle equ degas2+160*66
texte       incbin 	texte.mdk
