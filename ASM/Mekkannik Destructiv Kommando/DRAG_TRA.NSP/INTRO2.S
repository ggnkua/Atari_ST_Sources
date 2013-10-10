
*                     MEKANNIK DESTRUCTIV KOMMANDO

* Creation   : 02/10/1988
* Modif.     : 16/10/1988

*----------------------------------------------------------------
*     Buffers pour le scolling du bas et lettres sur ecran
*----------------------------------------------------------------

* occupation des buf(i) = 15360 octets = $3C00
tab_buf  equ $70000 

buf1     equ tab_buf+160*24*0     
buf2     equ tab_buf+160*24*1
buf3     equ tab_buf+160*24*2
buf4     equ tab_buf+160*24*3


* occupation des st(i) = 768 octets = $300

tab_st   equ tab_buf+160*24*5
st1      equ tab_st+8*24*0
st2      equ tab_st+8*24*1
st3      equ tab_st+8*24*2
st4      equ tab_st+8*24*3   

* 9 buffers pour 9 lettres ... occupation = 2340 = $924
buf_sp   equ tab_st+8*24*4

bufsp    equ buf_sp+(4+16*16)*0
bufs1    equ buf_sp+(4+16*16)*1
bufs2    equ buf_sp+(4+16*16)*2
bufs3    equ buf_sp+(4+16*16)*3
bufs4    equ buf_sp+(4+16*16)*4
bufs5    equ buf_sp+(4+16*16)*5
bufs6    equ buf_sp+(4+16*16)*6

buffer   equ buf_sp+(4+16*16)*7
buffer1  equ buffer+24*160
* occupation total des tabst(i)+tabbuf(i)+bufsp(i) = 18468 = $4824

*----------------------------------------------------------------
*          Adresse des pages DEGAS decompactees
*----------------------------------------------------------------
* une image = 32000 octets = $7D00

degas1     equ $68000       * reste $300 octets jusqu'a $70000
degas2     equ $78000       * affichage du dragon
Music      equ $4F34C
*----------------------------------------------------------------
*               Constantes dues au chargement 
*----------------------------------------------------------------

filedat   equ $4F2AA-28           * adresse de chargement du fichier "data.mdk"
longdat   equ 50000            * longueur du fichier "data.mdk"
musicgo   equ filedat+28
tf0       equ filedat+$2170
tf1       equ filedat+$21DE
tf2       equ filedat+$224C
tf3       equ filedat+$22BA
col2      equ filedat+$2328
d_coo_met equ filedat+$23D8
f_coo_met equ filedat+$2618
d_coo_cra equ filedat+$2618
f_coo_cra equ filedat+$2820
d_coo_moe equ d_coo_cra
f_coo_moe equ f_coo_cra
d_coo_zeb equ d_coo_met
f_coo_zeb equ f_coo_met
pic1      equ filedat+$2820
pic2      equ filedat+$7382
texte     equ filedat+$c104
lettres   equ filedat+$C206-4*48
fin       equ filedat+$C206

*----------------------------------------------------------------
*                Constantes diverses pour les sprites
*----------------------------------------------------------------

nblet    equ 7
metal    equ degas1+88*160
crack    equ degas1+105*160
moebi    equ degas1+122*160
zebeh    equ degas1+139*160

*----------------------------------------------------------------
*                  Debut du programme  INTRO2
*----------------------------------------------------------------
debut  bra reserv
       dc.b " This intro was coded by Metal68"
       dc.b " from Mekannik Destruktiv Kommando  "
       even 

reserv movea.l sp,a5
       movea.l 4(a5),a5
       move.l  $C(a5),d0
       add.l   $14(a5),d0
       add.l   $1C(a5),d0
       add.l   #$100,d0
       move.l  d0,-(sp)
       move.l  a5,-(sp)
       clr.w   -(sp)
       move.w  #$4A,-(sp)
       trap    #1
       lea.l  12(sp),sp

Superv move.l  #$7FFF0,-(sp)
       move.w  #$20,-(sp)
       trap    #1
       addq.l  #6,sp
       move.l  d0,stack

Basrez clr.w   -(sp)                   * Basse resolution
       move.l  #$78000,-(sp)           * adresse ecran = $78000 (520)
       move.l  #$78000,-(sp)
       move.w  #$05,-(sp)
       trap    #14
       lea.l   12(sp),sp
   
       dc.w $A00A

Lddat  lea data,a0                     * charge : DATA.MDK
       lea filedat-28,a1
       lea longdat,a2
       bsr Load

       lea     degas1,a3                * decompacte l'image degas
       lea     pic1+34,a5
       bsr     Compact
       
       lea     degas2,a3
       lea     pic2+34,a5
       bsr     Compact
       
       movea.l #$78000+160*130,a0
       movea.l #buffer,a1
       move.w  #960-1,d0
sss    move.l  (a0)+,(a1)+
       dbra    d0,sss

       move.b  #5,$4F317
       jsr musicgo

 
       movea.l #col2,a0
       movea.l #coldec,a1
      
Decom  moveq   #0,d0
       move.b  (a0)+,d0
       bne     Decom1
       move.b  (a0)+,d0
       subq    #1,d0
Decom6 clr.w   (a1)+
       dbra    d0,Decom6
       bra     Decom
Decom1 cmpi.b  #$FF,d0
       beq     Decom3
       movea.l #tf0,a2
       move.b   #$F0,d1
Decom2 cmp.b   d0,d1
       beq     Decom4
       addq.w  #1,d1
       adda.l  #5*11*2,a2
       bra     Decom2
Decom4 moveq   #10,d0
Decom5 move.l  (a2)+,(a1)+
       move.l  (a2)+,(a1)+
       move.w  (a2)+,(a1)+
       dbra    d0,Decom5 
       bra     Decom       
Decom3 move.w  #$FFFF,(a1)
       
       
       move.b  #$12,$FFFC02
       andi.b  #$F8,$484
   
       bsr     Detour
       
Debut  
       move.b  $FFFC02,d0
       cmpi.b  #$39,d0
       bne     Debut
Fin    jmp    $FC0000

adscreen dc.l $78000
stack    dc.l 0

*--------------------------------------------------------------
*           effacer les 4 buffers de scrolling 
*--------------------------------------------------------------

Razbuf movea.l #tab_buf,a0
       moveq   #0,d1
       move.w  #17328/16-1,d0
Razbu1 move.l  d1,(a0)+
       move.l  d1,(a0)+
       move.l  d1,(a0)+
       move.l  d1,(a0)+
       dbra    d0,Razbu1
       rts
        
*---------------------------------------------------------------
*               Chargement du fichier Data
*--------------------------------------------------------------

;      a0: adresse du nom
;      a1: adresse du buffer
;      a2: longueur

Load  move.w  #0,-(sp)
      move.l  a0,-(sp)
      move.w  #$3D,-(sp)
      trap    #1
      addq.l  #8,sp
      tst.w   d0
      bpl     read

error clr.l   -(sp)
      trap    #1
      
read  move.w  d0,d3
      move.l  a1,-(sp)
      move.l  a2,-(sp)
      move.w  d3,-(sp)
      move.w  #$3F,-(sp)
      trap    #1
      adda.l  #12,sp

close move.w  d3,-(sp)
      move.w  #$3E,-(sp)
      trap    #1
      addq.l  #4,sp
      rts
      
data  dc.b 'DATA.MDK',0,0
music dc.b 'MUSIC.MDK',0

*----------------------------------------------------------------
*          Detournement des interruption VBL et HBL 
*----------------------------------------------------------------

Detour move.w  #$2700,sr
       move.l  $118,acia1+2
       move.l  #acia,$118
               
       move.b  #%11001111,$FFFA09
       clr.b   $FFFA07
       move.l  #Hbl_1,$120
       move.b  #%11011111,$FFFA07
       move.b  #%00010001,$FFFA13
   
       move.l  #Vbl,$70
       move.w  #$2300,sr
       rts

*----------------------------------------------------------------
*            Interruption acia ( clavier ou midi )
*----------------------------------------------------------------

acia   move.w  #$2500,sr
acia1  jmp     $FC281C

*----------------------------------------------------------------
*      Interruption VBL et reinitialisation des couleurs
*----------------------------------------------------------------

Vbl    clr.b   $FFFA1B
       move.b  #1,$FFFA21
       move.b  #8,$FFFA1B
       bclr    #0,$FFFA0F
             
Vblbis movem.l d0-a6,-(sp)
       jsr     Scroll
       jsr     Music
       jsr     Mdk
Vblb1  movem.l (sp)+,d0-a6
       rte

*----------------------------------------------------------------
*                     Interruption HBL  ( bleu )
*----------------------------------------------------------------

Hbl_1  movem.l d0/d1/a4-a6,-(sp)
       movea.w #$FA00,a6
       clr.b   $1B(a6)
       move.b  #laps1,$21(a6)
       move.b  #8,$1B(a6)
       movea.w #$8240,a4
       movea.l #cola,a5
       moveq   #5,d0
Hbl_10 move.b  $21(a6),d1
Hbl_11 cmp.b   $21(a6),d1
       beq     Hbl_11
       nop
       nop
       nop
       nop
       move.w  (a5)+,(a4)
       dbra    d0,Hbl_10
       lea     couleur,a5
       movem.l (a5)+,d0-d1
       movem.l d0-d1,12(a4)
       movem.l (a5)+,d0-d1
       movem.l d0-d1,20(a4)
       movem.l (sp)+,d0/d1/a4-a6
       move.l  #Hbl_1a,$120
       move.b  #0,$FFFA0F
       rte   

couleur dc.w $111,$222,$333,$444,$555,$666,$777,$000
        

Hbl_1a  movem.l d0-d3/a4-a6,-(sp)
       movea.w #$FA00,a6
       clr.b   $1B(a6)
       move.b  #laps2,$21(a6)
       move.b  #8,$1B(a6)
       movea.w #$8240,a4
       movea.l #colb,a5
       moveq   #5,d0
Hbl_10a move.b  $21(a6),d1
Hbl_11a cmp.b   $21(a6),d1
       beq     Hbl_11a
       nop
       nop
       nop
       nop
       move.w  (a5)+,(a4)
       dbra    d0,Hbl_10a
       lea     colc,a5
       movem.l (a5)+,d0-d3
       movem.l d0-d3,(a4)
       movem.l (a5)+,d0-d3
       movem.l d0-d3,16(a4)
       movem.l (sp)+,d0-d3/a4-a6
       move.l  #Hbl_1,$120
       rte   
       
laps1  equ  31
laps2  equ  200

   
cola   dc.w $003,$005,$007,$005,$003,$000
colb   dc.w $003,$005,$007,$005,$003,$000

colc   dc.w $000,$036,$720,$015,$300,$500,$740,$520
       dc.w $600,$761,$772,$774,$400,$421,$200,$777

Hbl_2  movem.l d0-a6,-(sp)
       movea.w #$FA00,a6
       clr.b   $1B(a6)
       move.b  #42,$21(a6)
       move.b  #8,$1B(a6)
       movea.w #$8240,a5 
       movea.l ptcol2,a4
      
       moveq   #40,d0
Hbl_21 movem.l (a4),d1-d5
       move.w  20(a4),d6
       move.b  $21(a6),d7
Hbl_22 cmp.b   $21(a6),d7
       beq     Hbl_22
       nop
       nop
       nop
       cmp.w   #000,(a4)
       beq     Hbl_23
       movem.l d1-d5,(a5)
       move.w  d6,20(a5)
       adda.l  #22,a4
       dbra    d0,Hbl_21
       move.w  #$2200,sr
       movem.l (sp)+,d0-a6
       rte
Hbl_23 movea.l #col3,a3
       movem.l (a3),d1-d6
       movem.l d1-d6,(a5)
       addq.l  #2,a4
       dbra    d0,Hbl_21
       move.w  #$2200,sr
       movem.l (sp)+,d0-a6
       rte
              
col3  dc.w $000,$003,$005,$007,$027,$057,$777,$666
      dc.w $555,$444,$333,$777,$777,$777,$777,$777

*      DIFFERENTES   TACHES   SOUS   INTERRUPTION   VBL         
*     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        
*----------------------------------------------------------------
* Gestion du scrolling horizontal de MEKANNIK DESTRUCTIV KOMMANDO                                         
*----------------------------------------------------------------

Mdk     move.w  temps,d0
        beq     Mdk1
        subq.w  #1,temps
        rts
        
Mdk1    subq.w  #1,fois
        bne     Mdk3
        move.w  #200,temps
        move.w  #18,fois
        movea.l admek1,a0
        cmpa.l  #degas1+160*66,a0
        bne     Mdk2
        move.l  #degas1,admek1
        move.l  #degas1,admek
        rts
Mdk2    add.l   #160*22,admek1
        move.l  admek1,admek
        rts
Mdk3    bsr decband
        movea.l admek1,a0
        adda.l  #112,a0
        cmpa.l  admek,a0
        beq     Mdk4
        movea.l #$78000+160*9+152,a0
        movea.l admek,a1
        moveq   #21,d0
Mdk5    move.l  (a1),(a0)
        move.l  4(a1),4(a0)
        lea.l   160(a0),a0
        lea.l   160(a1),a1
        dbra    d0,Mdk5
        addq.l  #8,admek
Mdk4    rts

 
decband moveq   #21,d0
        movea.l #$78000+9*160,a6
decban1 movem.l 8(a6),d1-a4 
        movem.l d1-a4,0(a6) 
        movem.l $38(a6),d1-a4
        movem.l d1-a4,$30(a6) 
        movem.l $68(a6),d1-a4 
        movem.l d1-a4,$60(a6)
        movem.l $98(a6),d1-d2
        movem.l d1-d2,$90(a6)
        lea.l   $A0(a6),a6
        dbra    d0,decban1
        rts

fois dc.w 18
temps dc.w 0
admek dc.l degas1
admek1 dc.l degas1
        
*----------------------------------------------------------------
*            Deplacement des couleurs pour le roulement 
*----------------------------------------------------------------
Roule   subq.w  #1,tempo
        bne     Roule1
        move.w  #3,tempo
        add.l   #282,ptcol2
        movea.l ptcol2,a0
        cmp.w   #$FFFF,(a0)
        bne     Roule1
        move.l  #coldec,ptcol2
Roule1  rts

tempo   dc.w 3      
ptcol2  dc.l coldec

*----------------------------------------------------------------
*               Gestion du scrolling horizontal
*----------------------------------------------------------------

Scroll   move.w branch,D2     
        addq.w #1,branch     
        andi.w #3,branch
scroll1 asl.w #2,d2          
        movea.l #adresse,a2   
        movea.l 0(a2,d2.w),a2 
        jmp (A2)              

ad1     movea.l  #buf4,a6
        bsr     scroh
        movea.l #buf3,a6    
        movea.l #st3,a5
        bra scrolh

ad2     movea.l  #buf3,a6
        bsr     scroh
        movea.l #buf2,a6
        movea.l #st2,a5
        bra scrolh

ad3     movea.l #buf2,a6
        bsr     scroh
        movea.l #buf1,a6
        movea.l #st1,a5
        bra scrolh

ad4     movea.l #buf1,a6
        bsr     scroh

        movea.l #texte,a0     
        movea.l #lettres,a1     

scrolh1 move.w  cmpt_let,d0 
        move.b  (a0,d0.w),d1 
        cmpi.b  #52,d1       
        bne    scrolh2       
        clr.w  cmpt_let      
        bra scrolh1          

scrolh2 ext.w d1             
        asl.w #2,d1          
        move.l 0(a1,d1.w),mem1
        addq.w #1,cmpt_let     
        move.w cmpt_let,d0
        move.b  (a0,d0.w),d1   
        cmpi.b  #52,d1         
        bne    scrolh3         
        move.b (a0),d1         
scrolh3 ext.w d1               
        asl.w #2,d1
        move.l 0(a1,d1.w),mem2 
        bsr masque     

        movea.l #buf4,a6 
        movea.l #st4,a5       

scrolh  moveq   #23,d0      
scrolh4 movem.l 8(a6),d1-a4 
        movem.l d1-a4,0(a6) 
        movem.l $38(a6),d1-a4
        movem.l d1-a4,$30(a6) 
        movem.l $68(a6),d1-a4 
        movem.l d1-a4,$60(a6)
        movem.l $98(a6),d1-d2
        movem.l d1-d2,$90(a6)
        adda.l #$98,a6
        move.l  (a5)+,(a6)+   
        move.l  (a5)+,(a6)+   
        dbra    d0,scrolh4
        rts

masque  movem.l d0-d6/a0-a2,-(sp)
        move.l  mem1,d4      
        move.l  mem2,d5      
masq1   moveq   #23,d0       
        move.l  d5,a1        
        movea.l #st1,a0      
masq2   move.l  0(a1),(a0)+  
        move.l  4(a1),(a0)+  
        lea.l   160(a1),a1
        dbra    d0,masq2

        moveq #3,d2          
        moveq #4,d3          
        moveq #12,d6         
masq3   movea.l #tab1,a0     
        movea.l 0(a0,d6.w),a0 
        movea.l d4,a1         
        movea.l d5,a2         
        moveq   #23,d0        
masq4   move.w 0(a1),d1
        swap d1
        move.w 0(a2),d1
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

        lea.l 160(a1),a1        
        lea.l 160(a2),a2        
        dbra d0,masq4
        addq.l   #4,d3        
        subq.l   #4,d6        
        subq.l   #1,d2        
        bne masq3
        movem.l (sp)+,d0-d6/a0-a2
        rts


scroh   movea.l #adscro,a5
        movea.l #buffer,a4  
        moveq   #23,d0
scro1
        rept 20
        move.l (a6)+,d2
        move.l (a6)+,d3
        move.l (a4)+,d4
        move.l (a4)+,d5
        bsr trans
        endr
        dbra    d0,scro1
        rts

trans   move.l  d2,d7    
        or.l    d3,d7
        move.l  d7,d6
        swap    d6
        or.l    d6,d7
        not.l   d7
        and.l   d7,d4
        and.l   d7,d5
        or.l    d2,d4
        or.l    d3,d5 
        move.l  d4,(a5)+
        move.l  d5,(a5)+
        rts
           
adscro equ $78000+160*130
*----------------------------------------------------------------
*         Gestion des sprites baladeurs sur l'ecran
*----------------------------------------------------------------
Anime   subq.w  #1,glop
        beq     an0
        rts

an0     move.w  #3,glop
        movea.l #colc,a0       * rotation de couleurs pour les
        move.w  22(a0),d0      * flammes du dragon
        move.w  20(a0),22(a0)
        move.w  18(a0),20(a0)
        move.w  d0,18(a0)
        
        movea.l tab_nom,a0     * pointeur sur le tab_n(i)
an1     movea.l (a0)+,a5       * adresse du nom
        movea.l (a0)+,a3       * adresse de debut coord
        movea.l (a0),a2        * adresse de fin coord
        
        movea.l #bufs6,a4      * adresse du buffer de la 9eme lettre
        adda.l  #8*6,a5        * adresse de la 9eme lettre du mot

        movea.l ptcoord,a6
        suba.l  #4*4*8,a6    
        cmpa.l  a2,a6           * la derniere lettre est elle a la fin
        ble     Anime0          * du tab_coord
  
        addq.w  #1,num_nom      * si oui passer au nom suivant
        and.w   #03,num_nom
        movea.l #tab_n0,a0        * recherche des parametres du nom        
        move.w  num_nom,d0
        beq     an2
an3     adda.l  #12,a0
        subq    #1,d0
        bne     an3
an2     move.l  a0,tab_nom
        move.l  4(a0),ptcoord
        rts
                            
Anime0  movem.l a2/a3,-(sp)
        bsr     restsp
        movem.l (sp)+,a2/a3
        moveq   #nblet-1,d5
Anime1  cmpa.l  a3,a6              * est on avant le deb du tab_coord
        blt     Anime2             * si a6<a3 alors ne pas traiter
        cmpa.l  a2,a6              * a t on depasser la fin
        bge     Anime3             * si oui alors on sort
        move.w  0(a6),d1           * coordonnee x
        move.w  2(a6),d0           * coordonnee y
        movem.l a2,-(sp)
        bsr     affiche
        movem.l (sp)+,a2
Anime2  suba.l  #4+16*16,a4    * buffer precedent
        subq.l  #8,a5          * lettre precedente
        adda.l  #4*4,a6        * coordonnee pour la lettre precedente
        dbra    d5,Anime1
Anime3  addq.l  #4,ptcoord
        rts
        
glop dc.w 3
* entree : D1 coordonnee x
*          D0 coordonnee y
*          A2 adresse buffer de sauvegarde
*          A0 adresse du sprite a afficher
 
affiche movea.l a4,a2
        movea.l a5,a0
        andi.l  #$FF,d0
        mulu    #160,d0
        move.w  d1,d7
        andi.l  #$1F0,d1
        lsr.w   #1,d1
        add.w   d1,d0
        add.l   #$78000,d0
        movea.l d0,a1           * adresse ecran de l'affichage
        andi.l  #15,d7
aff0    move.l  a1,(a2)+        * sauve adresse d'affichage
        moveq   #15,d6          * sprite 16 lignes
aff1    moveq   #0,d0
        moveq   #0,d1
        moveq   #0,d2
        moveq   #0,d3
        move.w  0(a0),d0
        move.w  2(a0),d1
        move.w  4(a0),d2
        move.w  6(a0),d3
        move.l  d0,d4
        or.l    d1,d4
        or.l    d2,d4
        or.l    d3,d4
        not.l   d4
        ror.l   d7,d0
        ror.l   d7,d1
        ror.l   d7,d2
        ror.l   d7,d3
        ror.l   d7,d4
        move.w  (a1),(a2)+
        and.w   d4,(a1)
        or.w    d0,(a1)+
        move.w  (a1),(a2)+
        and.w   d4,(a1)
        or.w    d1,(a1)+
        move.w  (a1),(a2)+
        and.w   d4,(a1)
        or.w    d2,(a1)+
        move.w  (a1),(a2)+
        and.w   d4,(a1)
        or.w    d3,(a1)+ 
        swap    d0
        swap    d1
        swap    d2
        swap    d3
        swap    d4
        move.w  (a1),(a2)+
        and.w   d4,(a1)
        or.w    d0,(a1)+
        move.w  (a1),(a2)+
        and.w   d4,(a1)
        or.w    d1,(a1)+
        move.w  (a1),(a2)+
        and.w   d4,(a1)
        or.w    d2,(a1)+
        move.w  (a1),(a2)+
        and.w   d4,(a1)
        or.w    d3,(a1)+ 
        adda.l  #$90,a1
        adda.l  #$A0,a0
        dbra    d6,aff1
        rts

*---------------------------------------------------------------
*         Restoration du fond efface par les lettres
*--------------------------------------------------------------

restsp  moveq   #0,d0
        movea.l #bufsp,a3
restsp1 bsr     restsp2
        addq.w  #1,d0
        adda.l  #4+16*16,a3
        cmpi.w  #nblet+1,d0
        bne     restsp1
        rts
        
restsp2 movea.l a3,a2              * a2 = adresse du buffer de la lettre               
        moveq   #15,d6
        movea.l (a2)+,a1
        cmpa.l  #0,a1
        beq     restsp5
restsp4 movem.l (a2)+,d1-d4
        movem.l d1-d4,(a1)
        adda.l  #$A0,a1
        dbra    d6,restsp4
restsp5 rts
        
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
         
num_nom  dc.w 0
ptcoord  dc.l d_coo_cra
tab_nom  dc.l tab_n0

tab_n0  dc.l crack
        dc.l d_coo_cra
        dc.l f_coo_cra
        
tab_n1  dc.l metal
        dc.l d_coo_met
        dc.l f_coo_met
        
tab_n2  dc.l moebi
        dc.l d_coo_moe
        dc.l f_coo_moe
       
tab_n3  dc.l zebeh
        dc.l d_coo_zeb
        dc.l f_coo_zeb
       

*   couleurs decompactees --> laisser a la fin
coldec 
    