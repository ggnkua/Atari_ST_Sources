
*                     MEKANNIK DESTRUCTIV KOMMANDO

		OPT O+,W-

*----------------------------------------------------------------
*     Buffers pour le scolling du bas et lettres sur ecran
*----------------------------------------------------------------

* occupation des buf(i) = 15360 octets = $3C00
tab_buf  equ $70000 

buf1     equ tab_buf+160*26*0     
buf2     equ tab_buf+160*26*1
buf3     equ tab_buf+160*26*2
buf4     equ tab_buf+160*26*3

* occupation des st(i) = 768 octets = $300

tab_st   equ tab_buf+160*26*4
st1      equ tab_st+8*26*0
st2      equ tab_st+8*26*1
st3      equ tab_st+8*26*2
st4      equ tab_st+8*26*3   

* occupation total des tabst(i)+tabbuf(i)+bufsp(i) =  $3F00


degas2 equ $68000
sp1     equ degas2+160*130+32  		* adresse du M ( dans MDK )
arc	equ degas2+160*130      	* adresse de l'arc bris‚
land1   equ degas2+160*130+80
land2   equ degas2+160*136+80
land3   equ degas2+160*142+80
land4   equ degas2+160*148+80
land5   equ degas2+160*130+80+32
land6   equ degas2+160*136+80+32
land7   equ degas2+160*142+80+32
name1   equ degas2+160*153+32
name2   equ degas2+160*171+32
	
reserv	move.l  sp,pile       
	movea.l #$80000-4,sp    

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
               
	lea     degas2,a3                * decompacte les fontes
	lea     pic2+34,a5
	bsr     Compact

	movea.l #arc,a2			* affiche l'arc en ciel
	movea.l #$78000+64,a1
	move.w  #70-1,d0
Dp	movem.l (a2),d1-a0
	movem.l d1-a0,(a1)
	lea     160(a2),a2
	lea     160(a1),a1
	dbra    d0,Dp
	
	lea	name1,a0
	lea	name2,a6
	lea	$78000+172*160,a1
	moveq	#17,d0
na1	movem.l (a0),d1-d7/a2-a4
	movem.l d1-d7/a2-a4,(a1)
 	movem.l (a6),d1-d7/a2-a4
	movem.l d1-d7/a2-a4,96(a1)
	
	movem.l 40(a0),d1-d7/a2-a4
	movem.l d1-d7/a2-a4,40(a1)
 	movem.l 40(a6),d1-d7/a2
	movem.l d1-d7/a2-a4,136(a1)
	
	lea	160(a0),a0
	lea	160(a1),a1
	lea	160(a6),a6
	dbra	d0,na1
	
	
	move.l  #sp1,a5
	move.l  #buffsp1,a6
	move.l  #$78000+56+160*24,a0
	jsr	affmdk
	
	move.l  #sp1+16,a5
	move.l  #buffsp1+22*16+4,a6
	move.l  #$78000+72+160*24,a0
	jsr	affmdk
	
        move.l  #sp1+32,a5
	move.l  #buffsp1+(22*16+4)*2,a6
	move.l  #$78000+88+160*24,a0
	jsr	affmdk
	
        jsr    zic+$BC
	bsr     Razbuf			*efface les buffers
	bsr     table			*init table d'adresse des lettres
        bsr     rotate
	bsr     detour
       
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
       
	move.l  stack(pc),-(sp)         * passage en utilisateur
	move.w  #$20,-(sp)              * restitution de la pile superviseur
	trap    #1
	addq.l  #6,sp
	move.l  pile(pc),sp             * retitution de la pile systeme
        movem.l zero(pc),d0-a6
	CLR.W -(SP)
	TRAP #1
	
pile  dc.l 0
stack dc.l 0     
zero  ds.l 16
*--------------------------------------------------------------
*           effacer les 4 buffers de scrolling 
*--------------------------------------------------------------

Razbuf movea.l #tab_buf,a0
       moveq   #0,d1
       move.w  #18000/16,d0
Razbu1 move.l  d1,(a0)+
       move.l  d1,(a0)+
       move.l  d1,(a0)+
       move.l  d1,(a0)+
       dbra    d0,Razbu1
       rts
        
*-------------------------------------------------------------*
*  vecteur des lettres
*-------------------------------------------------------------*
       
table  movea.l #degas2,a0
       movea.l #lettre,a2
       moveq   #4,d0
ta2    movea.l a0,a3
       moveq   #19,d1
ta1    move.l  a0,(a2)+
       adda.l  #8,a0
       dbra    d1,ta1
       move.l  a3,a0
       adda.l  #26*160,a0
       dbra    d0,ta2
       rts
       
*---------------------------------------------------------------
*        Rotation des plan du scroll differentiel
*---------------------------------------------------------------

rotate  lea	land1,a5
	lea	buffpa1,a6
	bsr	rot_dep
	lea	buffpa1,a0
	moveq   #1,d7
	moveq   #63-1,d4
	bsr  	rotat1

	lea	land2,a5
	lea	buffpa2,a6
	bsr	rot_dep
	lea	buffpa2,a0
	moveq   #2,d7
	moveq   #31-1,d4
	bsr  	rotat1

	lea	land2,a5
	lea	buffpa3,a6
	bsr	rot_dep
	lea	buffpa3,a0
	moveq   #3,d7
	moveq   #20-1,d4
	bsr  	rotat1
	
	lea	land3,a5
	lea	buffpa4,a6
	bsr	rot_dep
	lea	buffpa4,a0
	moveq   #4,d7
	moveq   #15-1,d4
	bsr  	rotat1

	lea	land3,a5
	lea	buffpa5,a6
	bsr	rot_dep
	lea	buffpa5,a0
	moveq   #5,d7
	moveq   #12-1,d4
	bsr  	rotat1

	lea	land4,a5
	lea	buffpa6,a6
	bsr	rot_dep
	lea	buffpa6,a0
	moveq   #6,d7
	moveq   #10-1,d4
	bsr  	rotat1

	lea	land4,a5
	lea	buffpa7,a6
	bsr	rot_dep
	lea	buffpa7,a0
	moveq   #7,d7
	moveq   #8-1,d4
	bsr  	rotat1

	lea	land5,a5
	lea	buffpa8,a6
	bsr	rot_dep
	lea	buffpa8,a0
	moveq   #8,d7
	moveq   #7-1,d4
	bsr  	rotat1

	lea	land5,a5
	lea	buffpa9,a6
	bsr	rot_dep
	lea	buffpa9,a0
	moveq   #9,d7
	moveq   #6-1,d4
	bsr  	rotat1

	lea	land6,a5
	lea	buffpa10,a6
	bsr	rot_dep
	lea	buffpa10,a0
	moveq   #11,d7
	moveq   #5-1,d4
	bsr  	rotat1

	lea	land7,a5
	lea	buffpa11,a6
	bsr	rot_dep
	lea	buffpa11,a0
	moveq   #13,d7
	moveq   #4-1,d4
	bsr  	rotat1
	rts


rot_dep	moveq	#5-1,d0
rot_de1	movem.l (a5),d1-a0          * 64 bits = 32octets
	movem.l d1-a0,(a6)
	adda.l 	#160,a5
	adda.l	#32,a6
	dbra	d0,rot_de1
	rts
	
rotat1	lea     5*32(a0),a1
rotat4  moveq   #5-1,d3

rotat3  moveq   #4-1,d2
rotat2  move.w  $00(a0),d1
	swap	d1
	move.w	$08(a0),d1
	rol.l	d7,d1
	swap	d1
	move.w	d1,$00(a1)
	
	move.w  $08(a0),d1
	swap	d1
	move.w	$10(a0),d1
	rol.l	d7,d1
	swap	d1
	move.w	d1,$08(a1)
	
	move.w  $10(a0),d1
	swap	d1
	move.w	$18(a0),d1
	rol.l	d7,d1
	swap	d1
	move.w	d1,$10(a1)
	
	move.w  $18(a0),d1
	swap	d1
	move.w	$00(a0),d1
	rol.l	d7,d1
	swap	d1
	move.w	d1,$18(a1)
	
	addq.l  #2,a0
	addq.l  #2,a1
	dbra    d2,rotat2       * rotation d'une ligne (64bits)

	adda.l  #24,a0
	adda.l  #24,a1
	dbra    d3,rotat3       * multiplier par nbre ligne

	dbra    d4,rotat4       * nombre total de pix 
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
	
        move.l  #mdk,$4CE
	move.l  #Sc_diff,$4D2
        move.l  #Scroll,$4D6
        move.l  #zic+$120,$4DA
        move.l  #cal_dif,$4DE
	move.l	#dec_col,$4E2
        move.w  #1,$452
        move.w  #6,$454
             
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

vbl      clr.b   $FFFA1B
         move.b  #36,$FFFA21
         move.b  #8,$FFFA1B
         move.l  #Hbl_1,$120
         clr.b   $FFFA0F
         movem.l d0-d7,-(sp)
         movem.l couleur,d0-d7
         movem.l d0-d7,$FF8240
         movem.l (sp)+,d0-d7
         move.l  #ligne,lghbl
         move.l  #clarc,clhbl 
vbl1	 jmp     $00000000

couleur dc.w $000,$700,$060,$770,$007,$706,$740,$222
        dc.w $333,$444,$555,$666,$777,$111,$456,$000
               
*----------------------------------------------------------------
*                     Interruption HBL  arc en ciel
*----------------------------------------------------------------

Hbl_1  clr.b   $FFFA1B
       movem.l d1/a5/a6,-(sp)
       movea.w #$FA21,a6
       movea.l lghbl,a5
       move.b  (a5)+,(a6)
       move.l  a5,lghbl
       move.b  #8,$FFFA1B
       move.l  clhbl,a5
       move.b  (a6),d1
Hbl_11 cmp.b   (a6),d1
       beq     Hbl_11
       nop
       nop
       nop
       nop
       cmp.w   #$FFF,(a5)
       beq     Hbl_2
       move.w  (a5)+,$FF8240
       move.l  a5,clhbl
       movem.l (sp)+,d1/a5/a6
       move.b  #0,$FFFA0F
       rte   

Hbl_2  addq.l  #2,a5
       move.l  (a5)+,$FF8240
       move.l  (a5)+,$FF8244
       move.l  (a5)+,$FF8248
       move.l  (a5)+,$FF824C
       move.l  (a5)+,$FF8250
       move.l  (a5)+,$FF8254
       move.l  (a5)+,$FF8258
       move.l  (a5)+,$FF825C
       move.l  a5,clhbl
       move.l  #Hbl_3,$120
       movem.l (sp)+,d1/a5/a6
       move.b  #0,$FFFA0F
       rte   

Hbl_3	clr.b   $FFFA1B
	movem.l a0/d1,-(sp)
	move.l  lghbl,a0
	move.b  (a0)+,$FFFA21
	move.l  a0,lghbl
        move.b  #8,$FFFA1B
       move.l  clhbl,a0
       move.b  $FFFA21,d1
Hbl_31 cmp.b   $FFFA21,d1
       beq     Hbl_31
       nop
       nop
       nop
       nop
	move.l (a0)+,$FF8240
	move.l (a0)+,$FF8244
	move.l (a0)+,$FF8248
	move.l a0,clhbl
	movem.l (sp)+,a0/d1
	move.l  #Hbl_4,$120
	move.b  #0,$FFFA0F
       rte   

Hbl_4	clr.b   $FFFA1B
	movem.l a0/d1,-(sp)
	move.l  lghbl,a0
	move.b  (a0)+,$FFFA21
	move.l  a0,lghbl
        move.b  #8,$FFFA1B
       move.l  #pal_name,a0
       move.b  $FFFA21,d1
Hbl_41 cmp.b   $FFFA21,d1
       beq     Hbl_41
       nop
       nop
       nop
       nop
	move.l (a0)+,$FF8242
	move.l (a0)+,$FF8246
	move.l (a0)+,$FF824A
	move.l (a0)+,$FF824E
	move.l (a0)+,$FF8252
	move.l (a0)+,$FF8256
	move.l (a0)+,$FF825A
	movem.l (sp)+,a0/d1
	move.b  #0,$FFFA0F
       rte   
       
lghbl dc.l ligne
ligne dc.b 2,2,2,2,2,2,21,40,60,100
 even
clhbl dc.l clarc
clarc dc.w $700,$740,$770,$060,$007,$706,$000,$FFF
coul_text dc.w $000,$111,$222,$333,$444,$555,$666,$777
          dc.w $110,$220,$330,$440,$550,$660,$770,$777
coul_diff dc.w $000,$267,$047,$036,$025,$014 

*---------------------------------------------------------------*
*         scrolling differenciel
*---------------------------------------------------------------*

Sc_diff	lea	$78000+160*110,a5
	lea	buff_ad,a4
	moveq	#11-1,d1
Sc_dif1	move.l  (a4)+,a6
	bsr	diff
	dbra	d1,Sc_dif1
	rts
	
* entree : a6: adresse du buffer a afficher (64bits)
*          a5: adresse ecran

diff	move.w  #5-1,d0
dif1	movem.l (a6)+,d2-a1
	movem.l d2-a1,$00(a5)
	movem.l d2-a1,$20(a5)
	movem.l d2-a1,$40(a5)
	movem.l d2-a1,$60(a5)
	movem.l d2-a1,$80(a5)
	lea     160(a5),a5
	dbra	d0,dif1
        rts

cal_dif move.l	#32*5,d1
	lea	buff_ad,a6
	lea	buff_tab,a5
	moveq	#11-1,d0
cal_di1 move.l	(a6),d2
	add.l	d1,d2
	cmp.l	4(a5),d2
	bne	cal_di2
	move.l	(a5),d2
cal_di2 move.l	d2,(a6)+
        addq.l	#4,a5
	dbra	d0,cal_di1
	rts

*---------------------------------------------------------------*
*       decalage des couleurs
*---------------------------------------------------------------*
dec_col	tst.w	fois
	bne	dec_co1
	move.w	#6,fois
        move.w	pal_name+28,d0
	movem.l pal_name,d1-d7
	movem.l d1-d7,pal_name+2
	move.w  d0,pal_name
dec_co1 subq.w  #1,fois
	rts
fois	dc.w 5
	
*---------------------------------------------------------------*
*        Gestion des mouvements des 3 sprites M D K             *
*---------------------------------------------------------------*

mdk     tst.b   buff_coord
	bne     mdk0
	move.l  adoffset,a1
	move.l	(a1)+,buff_coord
	cmp.l   #end_offset,a1
	bne	mdk_a
	move.l	#deb_offset,a1
mdk_a	move.l  a1,adoffset

mdk0	move.l	#buffsp1,a6      adresse du buffer
	move.l  #sp1,a5          adresse du sprite
	move.l  #buff_coord+1,a1
	moveq   #3-1,d5
	
mdk1	move.l  (a6),a0		 adresse ecran actuelle
        move.b  (a1)+,d1         offset de deplacement
	ext.w   d1
	beq	mdk4             si = 0 alors pas de deplacement
	bpl	mdk3             si positif aller vers le bas
mdk2	suba.l  #160,a0
	addq	#1,d1
	bne	mdk2
	bra	mdk4
mdk3	adda.l  #160,a0
	subq	#1,d1
	bne	mdk3
*                     ici a0= nouvelle adresse ecran
*                     a5= adresse sprite, a6= adresse buff
mdk4    move.l  a6,a3
	bsr	restofd
	move.l  a3,a6
	movem.l a5/a6,-(sp)
	bsr	affmdk
	movem.l (sp)+,a5/a6
	adda.l	#16,a5
	adda.l  #22*16+4,a6
	dbra	d5,mdk1
	sub.b   #1,buff_coord
	rts
	

* entree : a6 : adresse du buffer	

restofd moveq	#11-1,d0
	move.l  (a6)+,a2
restof1 movem.l (a6)+,d1-d4
	movem.l d1-d4,(a2)
	lea	160(a2),a2
	movem.l (a6)+,d1-d4
	movem.l d1-d4,(a2)
	lea	160(a2),a2
	dbra	d0,restof1
	rts

* entree : a5 : adresse du sprite
*          a6 : adresse du buffer
*          a0 : adresse ecran 

affmdk  moveq	#22-1,d0
        move.l  a0,(a6)+
affmd1	move.l  (a5)+,d1
	move.l  (a5)+,d2
	move.l  (a0),d3
	move.l  4(a0),d4
	move.l  d3,(a6)+
	move.l  d4,(a6)+
	
	move.l  d1,d7
	or.l    d2,d7
	move.l  d7,d6
	swap    d6
	or.l    d6,d7
	not.l   d7         masque obtenu
	
	and.l   d7,d3
	and.l   d7,d4
	or.l    d1,d3
	or.l    d2,d4
	move.l  d3,(a0)+ 	        
        move.l  d4,(a0)+

	move.l  (a5)+,d1
	move.l  (a5)+,d2
	move.l  (a0),d3
	move.l  4(a0),d4
	move.l  d3,(a6)+
	move.l  d4,(a6)+
	
	move.l  d1,d7
	or.l    d2,d7
	move.l  d7,d6
	swap    d6
	or.l    d6,d7
	not.l   d7         masque obtenu
	
	and.l   d7,d3
	and.l   d7,d4
	or.l    d1,d3
	or.l    d2,d4
	move.l  d3,(a0)+ 	        
        move.l  d4,(a0)+
        lea	160-16(a5),a5
        lea	160-16(a0),a0
        dbra	d0,affmd1
        rts
        
buff_coord dc.b 0,0,0,0

*----------------------------------------------------------------
*               Gestion du scrolling horizontal
*----------------------------------------------------------------

Scroll  move.w branch,D2     
        addq.w #1,branch
        and.w  #3,branch     
scroll1 asl.w #2,d2          
        movea.l #adresse,a2   
        movea.l 0(a2,d2.w),a2 
        jmp (A2)              

ad1     movea.l #buf4,a6    
        bsr scroh
        movea.l #buf3,a6    
        movea.l #st3,a5
        bra scrolh

ad2     movea.l #buf3,a6
        bsr scroh
        movea.l #buf2,a6
        movea.l #st2,a5
        bra scrolh

ad3     movea.l #buf2,a6
        bsr scroh
        movea.l #buf1,a6
        movea.l #st1,a5
        bra scrolh

ad4     movea.l #buf1,a6    
        bsr scroh

        movea.l #texte,a0     
        movea.l #lettre,a1     

scrolh1 move.w  cmpt_let,d0 
        move.b  (a0,d0.w),d1 
        cmpi.b  #96,d1       
        bne    scrolh2       
        clr.w  cmpt_let      
        bra scrolh1          

scrolh2 ext.w d1             
        asl.w #2,d1          
        move.l 0(a1,d1.w),mem1
        addq.w #1,cmpt_let     
        move.w cmpt_let,d0
        move.b  (a0,d0.w),d1   
        cmpi.b  #96,d1         
        bne    scrolh3         
        move.b (a0),d1         
scrolh3 ext.w d1               
        asl.w #2,d1
        move.l 0(a1,d1.w),mem2 
        bsr masque     

        movea.l #buf4,a6 
        movea.l #st4,a5       

scrolh  moveq   #25,d0      
scrolh4 movem.l 8(a6),d1-a4 
        movem.l d1-a4,0(a6) 
        movem.l $38(a6),d1-a4
        movem.l d1-a4,$30(a6) 
        movem.l $68(a6),d1-a4 
        movem.l d1-a4,$60(a6)
        movem.l $98(a6),d1-d2
        movem.l d1-d2,$90(a6)
        lea     $98(a6),a6
        move.l  (a5)+,(a6)+   
        move.l  (a5)+,(a6)+   
        dbra    d0,scrolh4
        rts

masque  movem.l d0-d6/a0-a2,-(sp)
        move.l  mem1,d4      
        move.l  mem2,d5      
masq1   moveq   #25,d0       
        move.l  d5,a1        
        movea.l #st1,a0      
masq2   move.l  (a1),(a0)+  
        move.l  4(a1),(a0)+  
        lea     160(a1),a1
        dbra    d0,masq2

        moveq #3,d2          
        moveq #4,d3          
        moveq #12,d6         
masq3   movea.l #tab1,a0     
        movea.l (a0,d6.w),a0 
        movea.l d4,a1         
        movea.l d5,a2         
        moveq   #25,d0        
masq4   move.w (a1),d1
        swap d1
        move.w (a2),d1
        rol.l d3,d1
        swap d1
        move.w d1,(a0)+
        move.w 2(a1),d1
        swap d1
        move.w 2(a2),d1
        rol.l d3,d1
        swap d1
        move.w d1,(a0)+
        move.w 4(a1),d1
        swap d1
        move.w 4(a2),d1
        rol.l d3,d1
        swap d1
        move.w d1,(a0)+
        move.w 6(a1),d1
        swap d1
        move.w 6(a2),d1
        rol.l d3,d1
        swap d1
        move.w d1,(a0)+

        lea    160(a1),a1        
        lea    160(a2),a2        
        dbra   d0,masq4
        addq.l   #4,d3        
        subq.l   #4,d6        
        subq.l   #1,d2        
        bne masq3
        movem.l (sp)+,d0-d6/a0-a2
        rts


scroh   movea.l #$78000+160*80,a5      
        moveq   #25,d0         
scro1   movem.l $00(a6),d1-a4  
        movem.l d1-a4,$00(a5)
        movem.l $30(a6),d1-a4
        movem.l d1-a4,$30(a5)
        movem.l $60(a6),d1-a4
        movem.l d1-a4,$60(a5)
        movem.l $90(a6),d1-d4
        movem.l d1-d4,$90(a5)
        lea     160(a5),a5
        lea     160(a6),a6
        dbra    d0,scro1
        rts

        
*---------------------------------------------------------------*
*         Decompacteur d'images au format DEGAS (PC1)           *
*                    en basse resolution                        *
* Par  - Metal68 -  from  MEKANNIK DESTRUCTIV KOMMANDO          *
* Le 02/10/1988                                                 *
*---------------------------------------------------------------*
        
Compact move.l  #199,d4
        movea.l #6,a0
        moveq   #4,d6
        moveq   #40,d7
Compac1 clr.b   d1
        movea.l a3,a4
Compac3 move.l  a4,-(sp)
        clr.b   d3
Compac2 move.b  (a5)+,d0
        tst.b   d0
        bmi     Compac6
        addq.b  #1,d0
Compac4 move.b  (a5)+,(a4)+
        addq.b  #1,d3
        move.l  a4,d5
        btst    #0,d5
        bne     Compac8
        add.l   a0,a4
Compac8 subq.b  #1,d0
        bne     Compac4
        bra     Compac7
Compac6 neg.b   d0
        addq.b  #1,d0
        move.b  (a5)+,d2
Compac5 move.b  d2,(a4)+
        addq.b  #1,d3
        move.l  a4,d5
        btst    #0,d5
        bne     Compac9
        add.l   a0,a4
Compac9 subq.b  #1,d0
        bne     Compac5
Compac7 cmp.b   d7,d3
        bne     Compac2
        move.l  (sp)+,a4
        addq.l  #2,a4
        addq.b  #1,d1
        cmp.b   d6,d1
        bne     Compac3
        add.l   #160,a3
        dbra    d4,Compac1              
        rts

*----------------------------------------------------------------
*                             Data
*----------------------------------------------------------------
               

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

*--------------------------------------------------------*
* table des adresses de debut de chaque buffer de scroll *
*--------------------------------------------------------*

buff_ad dc.l buffpa1
	dc.l buffpa2
	dc.l buffpa3
	dc.l buffpa4
	dc.l buffpa5
	dc.l buffpa6
	dc.l buffpa7
	dc.l buffpa8
	dc.l buffpa9
	dc.l buffpa10
	dc.l buffpa11

*----------------------------------------------------*
* table des pointeurs sur les buffers a afficher     *
*----------------------------------------------------*
         
buff_tab dc.l buffpa1
	 dc.l buffpa2
	 dc.l buffpa3
	 dc.l buffpa4
	 dc.l buffpa5
	 dc.l buffpa6
	 dc.l buffpa7
	 dc.l buffpa8
	 dc.l buffpa9
	 dc.l buffpa10
	 dc.l buffpa11
	 dc.l buffpa12

pal_name dc.w $100,$200,$300,$400,$500,$600,$700,$720
	 dc.w $000,$000,$000,$000,$000,$000,$000

adoffset dc.l deb_offset
deb_offset    * max = +24 et -24

 dc.b 24,1,1,1
 dc.b 48,-1,-1,-1
 dc.b 48,1,0,0
 dc.b 48,-1,0,0
 dc.b 48,0,1,0
 dc.b 48,0,-1,0
 dc.b 48,0,0,1
 dc.b 48,0,0,-1
 dc.b 48,1,1,0
 dc.b 48,-1,-1,0
 dc.b 48,0,1,1
 dc.b 48,0,-1,-1
 dc.b 48,1,0,1
 dc.b 48,-1,0,-1
 dc.b 24,0,2,1
 dc.b 24,1,-1,1
 dc.b 16,1,-1,-3
 dc.b 8,1,-1,0
 dc.b 8,-3,3,3
  
* ici tout est a 24,24,24
 dc.b 8,-3,3,3      * ici 0,48,48
 dc.b 16,1,-2,-3
 dc.b 8,1,-2,1
 dc.b 24,1,1,1
 dc.b 16,0,1,1
 dc.b 8,-3,1,-3
 dc.b 8,-3,0,-3            * ici 0,48,0
 dc.b 24,2,0,2
 dc.b 16,0,-3,-3
 dc.b 16,0,0,3             * ici 48,0,48
 dc.b 12,-2,2,-2
 dc.b 12,-2,2,2
 dc.b 12,4,0,0
 dc.b 12,0,-4,-4            * ici 48,0,0
 dc.b 16,-2,3,1
 dc.b 8,-2,-1,1          
 dc.b 24,2,-1,1
 dc.b 16,-3,-1,-3         * ici 0,0,0
 dc.b 12,4,0,4
 dc.b 12,-2,4,-2
 dc.b 12,-2,-3,-2
 dc.b 4,6,-3,6
 dc.b 4,6,2,6
 dc.b 20,0,2,0
 dc.b 48,-1,0,-1
 dc.b 12,0,-4,0		* ici 0,0,0
 dc.b 12,4,0,4
 dc.b 12,-3,0,-3
 dc.b 12,3,0,3
 dc.b 12,-2,0,-2
 dc.b 12,2,1,2
 dc.b 12,-1,1,-1
 dc.b 12,1,1,1
 dc.b 6,-1,2,-1
 dc.b 6,1,-1,1
 dc.b 6,-4,1,-4
 dc.b 6,-4,0,-4       * ici 0,48,0
 dc.b 24,0,-2,2       * 0,0,48
 dc.b 24,1,1,-2
 dc.b 24,1,1,1
 dc.b 24,-2,-1,1
 dc.b 8,0,3,-3
 dc.b 8,4,-4,-3
 dc.b 4,4,-4,0      * 48,0,0
 dc.b 12,0,0,3
 dc.b 12,0,2,-1
 dc.b 12,0,1,1
 dc.b 12,0,1,1
 dc.b 8,-1,0,0
 dc.b 8,1,0,0
 dc.b 1,-8,-8,-8
 dc.b 3,-4,-4,-4
 dc.b 4,-3,-3,-3
 dc.b 5,-2,-2,-2
 dc.b 6,-1,-1,-1         * 0,0,0
 dc.b 6,0,0,1
 dc.b 6,0,1,1
 dc.b 6,2,1,1
 dc.b 6,2,2,1             * 24,24,24
 *------------------*
 
 dc.b 12,2,2,2      * 48,48,48
 dc.b 12,0,-1,-2
 dc.b 12,-1,-1,-2
 dc.b 12,-1,-2,1
 dc.b 12,-1,3,2
 dc.b 4,-1,3,2
 dc.b 4,-2,0,1      * 0,48,48
 
 dc.b 12,4,-2,-3
 dc.b 4,-2,-2,-3
 dc.b 8,-2,-2,0
 dc.b 12,-2,3,3
 dc.b 4,0,2,2
 dc.b 4,0,1,1          * 0,48,48
 
 dc.b 12,1,-2,-2
 dc.b 12,1,2,2
 dc.b 12,1,-1,-1
 dc.b 12,1,1,1
 dc.b 12,-2,-1,-1
 dc.b 12,-2,1,1
 dc.b 12,0,-4,-2           * 0,0,24
 
 dc.b 12,1,1,-2
 dc.b 12,1,1,2
 
end_offset

pic2   incbin   arc_ciel\fnt2vide.pc1
texte  incbin   arc_ciel\texte.mdk
zic    incbin  arc_ciel\music.b

 section bss
 
buffsp1 ds.b 22*16+4        buffer de sauvegarde des 3 sprites MDK
	ds.b 22*16+4
	ds.b 22*16+4
lettre  ds.l 100

buffpa1                      			*ds.b 5*32*64
buffpa2 equ buffpa1+5*32*64	       		*ds.b 5*32*32
buffpa3 equ buffpa2+5*32*32			*ds.b 5*32*21
buffpa4 equ buffpa3+5*32*21			*ds.b 5*32*16
buffpa5 equ buffpa4+5*32*16			*ds.b 5*32*13
buffpa6 equ buffpa5+5*32*13			*ds.b 5*32*11
buffpa7 equ buffpa6+5*32*11			*ds.b 5*32*9
buffpa8 equ buffpa7+5*32*9			*ds.b 5*32*8
buffpa9 equ buffpa8+5*32*8			*ds.b 5*32*7
buffpa10 equ buffpa9+5*32*7			*ds.b 5*32*6
buffpa11 equ buffpa10+5*32*6			*ds.b 5*32*5	
buffpa12 equ buffpa11+5*32*5			*ds.b 5*32*0

