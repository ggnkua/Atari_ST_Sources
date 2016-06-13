*                     MEKANNIK DESTRUCTIV KOMMANDO


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

tab_st   equ tab_buf+160*24*4
st1      equ tab_st+8*24*0
st2      equ tab_st+8*24*1
st3      equ tab_st+8*24*2
st4      equ tab_st+8*24*3   

* occupation total des tabst(i)+tabbuf(i)+bufsp(i) =  $3F00

*----------------------------------------------------------------
*          Adresse des pages DEGAS decompactees
*----------------------------------------------------------------
* une image = 32000 octets = $7D00

degas1     equ $68000       * reste $300 octets jusqu'a $70000
degas2     equ $70000       * affichage du dragon
Music      equ $4F34C
coldec     equ $68000+88*160
lettre     equ $78000-320
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
pic1      equ filedat+$23D8
pic2      equ filedat+$3F20

*----------------------------------------------------------------
*                  Debut du programme  INTRO
*----------------------------------------------------------------

reserv	move.l  sp,pile       
	movea.l $04(sp),a5
	move.l  $08(a5),begin    
	movea.l #$80000,sp    
	
	lea data,a0                     * charge : DATA.MDK
	lea filedat-28,a1
	lea longdat,a2
	bsr Load

	clr.l   -(sp)         
	move.w  #$20,-(sp)    
	trap    #1
	addq.l  #6,sp
	move.l  d0,stack      
 
        movem.l buffer,d0-d7
	movem.l d0-d7,$FF8240
	    
        dc.w    $A00A
        move.b  #$12,$FFFC02
        
	clr.w   -(sp)         
	move.l  #$78000,-(sp)
	move.l  #$78000,-(sp)
	move.w  #$05,-(sp)
	trap    #14
	lea     12(sp),sp
               
	lea     degas1,a3                * decompacte l'image degas
	lea     pic1+34,a5
	bsr     Compact
       
	lea     degas2,a3
	lea     pic2+34,a5
	bsr     Compact

	movea.l #degas2,a0		* affiche la licorne
	movea.l #$78000+35*160,a1
	move.w  #20*123-1,d0
Dp	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	dbra    d0,Dp
	
       
	movea.l #col2,a0		*decompacte les tubes
	movea.l #coldec,a1
	bsr     Decom   
	bsr     Razbuf			*efface les buffers
	bsr     table			*init table d'adresse des lettres
	bsr     detour
	jsr     musicgo
       
Debut  move.w  #7,-(sp)
       trap    #1
       addq.l  #2,sp
       cmpi.b  #' ',d0
       bne     Debut

Fin    	lea     $4CE,a1
	lea     buffer,a0
	move.l  (a0)+,$452
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
	
	clr.w   -(sp)        
	move.l  #-1,-(sp)
	move.l  #-1,-(sp)
	move.w  #$05,-(sp)
	trap    #14
	add.l   #12,sp
	
	move.b  #3,$484
	dc.w    $A009
	move.b  #$08,$FFFC02
       
*----------------------------------------------------------*
*              RELOCATION DE L'EXECUTABLE                  *
*----------------------------------------------------------*
       
reloc  move.l   #fblock-dblock,d0   * mise hors de porter du soft de
       movea.l  #$70000,a0       * relocation
       movea.l  #dblock,a1
dsds   move.b   (a1)+,(a0)+
       dbra     d0,dsds
       jmp      $70000
       
*-----------------------------------------------------------*
*                     Soft de relocation                    *
*-----------------------------------------------------------*
loading equ $20000
longexe equ 90000

dblock lea      soft(pc),a0   * chargement du fichier binaire
       movea.l  #loading,a1   * a l'adresse $20000
       movea.l  #longexe,a2
       jsr      Load(pc)
       
       move.l   begin(pc),a6
       
*-----------------------------------------------------------*
*  reloger le fichier par rapport a son adresse veritable   *
*-----------------------------------------------------------*
    
       movea.l  loading+02,a0    * longueur du code
       adda.l   loading+06,a0    * + longueur des data
       move.l   a6,d1            * adresse de base de la relocation
       move.l   #loading+28,d2   * adresse de debut du prog
        
       movea.l  d2,a2       
       movea.l  d2,a3
       adda.l   a0,a3
       move.l   (a3)+,d0        * 1er offset sur un mot long
       beq      reloc3          * si = 0 alors pas de relocation
       clr.l    -4(a3)
reloc1 adda.l   d0,a2           * pointer sur la prochaine adresse a changer 
       moveq    #0,d0           
       add.l    d1,(a2)         * ajouter l'adresse de base
reloc2 move.b   (a3),d0      
       beq      reloc3          * si = 0 alors fin de la relocation
       clr.b    (a3)+
       cmp.b    #1,d0           * si = 1 alors saut de 254 octets
       bne      reloc1
       adda.l   #254,a2
       bra      reloc2
reloc3 lea      -$100(a6),a6
       move.l   loading+2,$C(a6)    * long du texte
       move.l   loading+6,$14(a6)   * long des data
       move.l   loading+10,$1C(a6)  * long des BSS
       move.l   $8(a6),$10(a6)
       move.l   $C(a6),d0
       add.l    d0,$10(a6)         * adresse des DATA
       move.l   $10(a6),$18(a6)
       move.l   $14(a6),d0
       add.l    d0,$18(a6)         * adresse des BSS       
       
       movea.l #loading+28,a0
       movea.l a0,a1
       adda.l  #longexe,a1
       movea.l begin(pc),a2
rel1   move.l  (a0)+,(a2)+
       cmpa.l  a0,a1
       bge     rel1
       
	move.l  stack(pc),-(sp)         * passage en utilisateur
	move.w  #$20,-(sp)              * restitution de la pile superviseur
	trap    #1
	addq.l  #6,sp
	move.l  pile(pc),sp             * retitution de la pile systeme

        move.l  begin(pc),a0
        suba.l  #$100,a0
	move.l  a0,4(sp)       * adresse du header dans pile+4
	jmp     $100(a0)

begin dc.l 0

pile  dc.l 0
stack dc.l 0     

*---------------------------------------------------------------
*               Chargement d'un fichier 
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

soft	dc.b 	"PROGRAMM.MDK",0
 even
data    dc.b '\licorne\DATA.MDK',0
 even
fblock

*--------------------------------------------------------------
*           effacer les 4 buffers de scrolling 
*--------------------------------------------------------------

Razbuf movea.l #tab_buf,a0
       moveq   #0,d1
       move.w  #16128/16-1,d0
Razbu1 move.l  d1,(a0)+
       move.l  d1,(a0)+
       move.l  d1,(a0)+
       move.l  d1,(a0)+
       dbra    d0,Razbu1
       rts
        
*-------------------------------------------------------------*
*  vecteur des lettres
*-------------------------------------------------------------*
       
table  movea.l #degas2+126*160,a0
       movea.l #lettre,a2
       moveq   #2,d0
ta2    movea.l a0,a3
       moveq   #19,d1
ta1    move.l  a0,(a2)+
       adda.l  #8,a0
       dbra    d1,ta1
       move.l  a3,a0
       adda.l  #25*160,a0
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
	
        move.l  #Scroll,$4CE
        move.l  #Mdk,$4D2   
        move.l  #Roule,$4D6   
             
	move.w  (sp)+,sr
	rts
	
buffer	dc.l 0	* 452 et 454
        dc.l 0  * 4CE
        dc.l 0  * 4D2
        dc.l 0  * 4D6
        dc.l 0  * 4DA
        dc.l 0  * 4DE
        dc.l 0  * 502
        dc.l 0  * 70
        dc.l 0  * 118
        dc.l 0  * 120
        dc.l 0  * FA07,09,0F,13
        dc.w 0  * FA1B,21
        
*----------------------------------------------------------------
*            Interruption acia ( clavier ou midi )
*----------------------------------------------------------------

acia   move.w  #$2500,sr
acia1  jmp     $00000000

*----------------------------------------------------------------
*      Interruption VBL et reinitialisation des couleurs
*----------------------------------------------------------------

vbl      clr.b   $FFFA1B
         move.b  #1,$FFFA21
         move.b  #8,$FFFA1B
         move.l  #Hbl_1,$120
         clr.b   $FFFA0F 
vbl1	 jmp     $00000000
       
*----------------------------------------------------------------
*                     Interruption HBL  ( bleu )
*----------------------------------------------------------------

Hbl_1  movem.l d0/d1/a4-a6,-(sp)
       move.w  #$2700,sr
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
       move.w  #$2200,sr
       move.b  #0,$FFFA0F
       rte   

couleur dc.w $111,$222,$333,$444,$555,$666,$777,$000
        

Hbl_1a  movem.l d0-d3/a4-a6,-(sp)
       move.w  #$2700,sr
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
       move.l  #Hbl_2,$120
       move.w  #$2200,sr
       bclr    #0,$FFFA0F
       rte   
       
laps1  equ  29
laps2  equ  128
   
cola   dc.w $003,$005,$007,$005,$003,$002
colb   dc.w $003,$005,$007,$005,$003,$000

colc   dc.w $000,$043,$112,$122,$123,$223,$234,$334
       dc.w $344,$445,$455,$555,$556,$666,$667,$777

Hbl_2  movem.l d0-a6,-(sp)
       move.w  #$2700,sr
       movea.w #$FA00,a6
       clr.b   $1B(a6)
       move.b  #42,$21(a6)
       move.b  #8,$1B(a6)
       movea.w #$8240,a5 
       movea.l ptcol2,a4
      
       moveq   #40,d0
Hbl_21 movem.l (a4),d1-d5
       move.w  20(a4),d6
       move.b  #$0,$FF820A
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
       move.b  #$2,$FF820A
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
        movea.l #$78000+160*7+152,a0
        movea.l admek,a1
        moveq   #21,d0
Mdk5    move.l  (a1),(a0)
        move.l  4(a1),4(a0)
        adda.l  #160,a0
        adda.l  #160,a1
        dbra    d0,Mdk5
        add.l   #8,admek
Mdk4    rts

 
decband moveq   #21,d0
        movea.l #$78000+7*160,a6
decban1 movem.l 8(a6),d1-a4 
        movem.l d1-a4,0(a6) 
        movem.l $38(a6),d1-a4
        movem.l d1-a4,$30(a6) 
        movem.l $68(a6),d1-a4 
        movem.l d1-a4,$60(a6)
        movem.l $98(a6),d1-d2
        movem.l d1-d2,$90(a6)
        adda.l  #$A0,a6
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

Scroll  move.w branch,D2     
        addq.w #1,branch     
        cmpi.w #3,d2         
        bne scroll1        
        clr.w branch         
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
        adda.l  #160,a1
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

        lea    160(a1),a1        
        lea    160(a2),a2        
        dbra   d0,masq4
        addq.l   #4,d3        
        subq.l   #4,d6        
        subq.l   #1,d2        
        bne masq3
        movem.l (sp)+,d0-d6/a0-a2
        rts


scroh   movea.l #$78000+160*167,a5      
        moveq   #23,d0         
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
*----------------------------------------
*	decompacte les tubes
*-----------------------------------------

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
         
texte  incbin   b:licorne\texte.mdk