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

*----------------------------------------------------------------
*          Adresse des pages DEGAS decompactees
*----------------------------------------------------------------
* une image = 32000 octets = $7D00

degas1     equ $68000       * reste $300 octets jusqu'a $70000
lettre     equ $78000-420
*----------------------------------------------------------------
*               Constantes dues au chargement 
*----------------------------------------------------------------
adscreen equ $78000

*----------------------------------------------------------------
*                  Debut du programme  INTRO
*----------------------------------------------------------------

reserv	move.l  sp,pile       
	movea.l $04(sp),a5
        move.l  $08(a5),begin
	movea.l #$80000,sp    
	
	clr.l   -(sp)         
	move.w  #$20,-(sp)    
	trap    #1
	addq.l  #6,sp
	move.l  d0,stack      
 
        movem.l $FF8240,d0-d7
        movem.l d0-d7,coulsys
        movem.l buffer1,d0-d7
	movem.l d0-d7,$FF8240
	    
        dc.w    $A00A
        move.b  #$12,$FFFC02
        
	clr.w   -(sp)         
	move.l  #adscreen,-(sp)
	move.l  #adscreen,-(sp)
	move.w  #$05,-(sp)
	trap    #14
	lea     12(sp),sp
               
	lea     degas1,a3                * decompacte l'image degas
	lea     pic1+34,a5
	bsr     Compact
       
        BSR     L18E66   * decompactage
	bsr     depzic
	bsr     Razbuf			*efface les buffers
	bsr     table			*init table d'adresse des lettres
	jsr  $5091E
        bsr     bande
	bsr     detour
       
Debut  	move.b  $FFFC02,d0
        cmpi.b  #$39,d0
        bne     Debut
       
Fin    	lea     $4CE,a1
	lea     buffer1,a0
	move.l  (a0)+,$452
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.w  (a0)+,$4EE
	move.l  (a0)+,$502
        move.l  (a0)+,$70
        move.l  (a0)+,$118

	move.b #$07,$FF8800
	ori.b  #$3F,$FF8802
	move.b #3,$484
	
	clr.w   -(sp)        
	move.l  #-1,-(sp)
	move.l  #-1,-(sp)
	move.w  #$05,-(sp)
	trap    #14
	add.l   #12,sp
	movem.l coulsys,d0-d7
	movem.l d0-d7,$FF8240
	
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
        movem.l zero(pc),d0-a6
        move.l  begin(pc),a0
        suba.l  #$100,a0
	move.l  a0,4(sp)       * adresse du header dans pile+4
	jmp     $100(a0)

begin dc.l 0
pile  dc.l 0
stack dc.l 0     
zero  ds.l 16
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

soft	dc.b 	"v.prg",0
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
       
table  movea.l #degas1,a0
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

bande  lea     degas1+160*136,a4
       lea     adscreen+160*148,a5
       lea     adscreen+160*190,a6
       moveq   #8,d0
bande1 movem.l (a4)+,d1-a2
       movem.l d1-a2,(a5)
       movem.l d1-a2,(a6)
       movem.l (a4)+,d1-a2
       movem.l d1-a2,40(a5)
       movem.l d1-a2,40(a6)
       movem.l (a4)+,d1-a2
       movem.l d1-a2,80(a5)
       movem.l d1-a2,80(a6)
       movem.l (a4)+,d1-a2
       movem.l d1-a2,120(a5)
       movem.l d1-a2,120(a6)
       lea     160(a5),a5
       lea     160(a6),a6
       dbra    d0,bande1
       rts       
*----------------------------------------------------------------
*          Detournement des interruption VBL et HBL 
*----------------------------------------------------------------

detour	move.w  sr,-(sp)
	ori.w   #$700,sr
	lea     $4CE,a0
	lea     buffer1,a1
	move.l  $452,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0),(a1)+
	move.w  $4EE,(a1)+
	move.l  $502,(a1)+
	move.l  $70,(a1)+
	move.l  $118,(a1)+
               
        move.l  $118.W,acia1+2
        move.l  #acia,$118.W
        
        move.l  #alt,$502.W
        move.w  #1,$4EE.W
	move.l  #L18F66,$4CE.W
        move.l  #choose,$4D2.W             
 	move.l  #$50F94,$4D6.W
	move.l  #$00010003,$452.W
	move.w  (sp)+,sr
	rts
	
buffer1	dc.l 0	* 452 et 454
        dc.l 0  * 4CE
        dc.l 0  * 4D2
        dc.l 0  * 4D6
        dc.l 0  * 4DA
        dc.l 0  * 4DE
        dc.w 0  * 4EE
        dc.l 0  * 502
        dc.l 0  * 70
        dc.l 0  * 118
coulsys ds.w 16        
*----------------------------------------------------------------
*            Interruption acia ( clavier ou midi )
*----------------------------------------------------------------

acia   move.w  #$2500,sr
acia1  jmp     $00000000

alt    rts

*      DIFFERENTES   TACHES   SOUS   INTERRUPTION   VBL         
*     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*----------------------------------------------------------------
*               Gestion du scrolling horizontal
*----------------------------------------------------------------
choose  move.b $FFFC02,d0
        cmpi.b #$39,d0
        bne    Scroll
        rts


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
        adda.l #$98,a6
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
        moveq   #25,d0        
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


scroh   movea.l #$78000+160*161,a5      
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
Compac8 subq.b  #1,d0I9`v
à™
P#ïVTíU†"ì`ÇÄ·e Çä™ÉÖe$ä
â 	»®Iòê ®$£*$®).PAFUY@ÑT`∞®ää∞!Q:1"t¢≤Çí  í*™j¢™≤¢∞ˆÇrÅî`à®¨º±°yUAeUaQe
A	9y9au	ä
®´•	’Â$îEDÅ‘$™¢)+*'"Æ$A^UHê™ä§å§≤®íÅ†8Ä¡e@¬¬¢ ÑÑîît ‚P UP–!W0%/*§¨†K* L/$AaQ`"¢r@ÄÂeA9A%1%yy9pz
À H–Jòêä®h*(™à´ I)“PRH √LI^D^NT0®™äêA"*¢jÚíJrÚr
2™`ÒWëï$$$†$óïHÅ†Å
π(≤Å0™§∞<DDïï‰ÂLr ÄƒE@àFØ),$BP UP’0* B®"™$ß@H"$ 2TPÄT  nÄ‡º¶ºú≤Å2®í§†8Ñ4	T‰ET	DT	ÂTÑe%‰Âî	ÖDEE≈DÂEQ¬'@@§PI@ê™≤Å±°XPU@âTD§íÅ∞ë	îí(&Ø*¨†B)$ÆKÄúÄëUT¿å®Å4§Å2º§äÅ ö®∞ò9Ä’Ç‰≤Çí'’Â4Å(â+»ã…»™I*	»®© C\UTUFT@Çà^NJ^UI@êêíÄíF@åPUE@ô A†·5yUeQI@tâ¬JÇ
í"¢≤¢r*Ä¸UíËeD	•$¬(™	ƒïÂî	T¿Å¢Ñï≈$Å
I»™â) ÑUU#ë<+À+*àã…»ËE^UYFÄñPR@Bä™ÅÑTïÅ‡™Å®Å®í≤ºúú®≤Å2†ö®úäÅ*ä§å¢<EDîËÑã  …ê$'
HUU&î#WïVP$ìà®Ä!eeQ#BÚJ¢rÇj•T
	À(J
*®àDTV^@äT@ç@"Pàºúú®í†§π!xïRVQ")®'$hUN@âPAA^\∞§&™, C*,†NP•î)(*°†AG)'%($¿!^IEFÄôXRTNXTY@îEXRtîtBÚr`ED’ÂUîe%ïïDË•…D‰	≈îE·“ Ø*§†C( @†ëa	AI9QPBÚí ¢!Ñƒï‰E‰‰’ETTÅ‘( ™$†AB*†@ÅQQÄ|Ñ°†≤òayIJ:AQ-YAIPz
â 	»®IÇUP÷
E$îÜ	p*´ï&îê&WîëP$U#WïVP!áÄ@D/'#@F(XBP¿ L#(&©*$†AYyI
1%yy9BJA%Q%.aAe4y	´ H®*©éîóíP!0,¢™ L0YY@ÇàD¢ J'&)'#@@®,¨Ø'*·BJBtRDÖï$è
*™à 	K…(´ ®ÉBRTñP!î'"™ H&™, LØ' H¢·
yUUyiI5yaI1Q%AYA)y%BJ:)L}®ñP$!( D™+,XRTIFÄäT\††§°A5yUeay91IQ%U9eQa%Q
5yUerA5Q-!IQ9YQ%IQ2s
	(H»ä
®® »)ÉêNDIH∞¨†îºíÅ"™§Å ?Ä<¨™",pPUXUNT@Å\∞ä™†ä§ºúÅ-?!%º™íÅ<9‰Tîä¬¢ZrÇZ‚™ÄÙ‡$ëê#QP WñVUP%`%îc`$a†$b`'Gú∞†!Z1AYYQe
UAIpz
…»*à	+ H®ãÀã(…à™	(P–©»Jà K»*¯Z ¢ìë†$RUPñÅÅA¬íQe%y@{ä™àRê†"ìê&TïQP$#î◊Qñá‡¨†îºíà¡eI1%yy9
YyIBJ5Mx{
Br™¬2¢ÇJ`ÖDîÂEçŸQqA!A1"p//-,$TWí,¢®$¨(UTñë†%ñ"QP †WïRP$ìñTê!íWG¿åÄ¡`CEPP†HLRNRT@îE@ÜP@ãUULÇ¬Ú≤
¬DEEe‰	ò	Uïï$		$d	eÂU·»*ß(Tóê!%îóíR`≤ä§Ü∞!9A-qU3ÄpÅ:QQeYA	|	*ä®h*™H…»® ®
à+	+»»»J´**´ì£‡FP@åRNT 
jà† !¿
*ã   âÀ
äÉ§P `¡<Ñê¿.^N@êÑÄá  ê‡!–L ê‡!¿CÄá 	 (g'C .
Ä0 @/   ‰0Äà@D¿Ã "†™ÄÓ
ÇÖâ êhÄ¿ÄÅÇˇÅ –@   ‡+ »D¿¿ÄÇÿDA@ @ øê@8AX¸`!p(ÄÄÅÄ@@  @êL (Ä B ∏ˇ¸C Å ®A ¯@‡  H)	  '  ¨˛	Çp @Al"@¿@ø`Äp0Çÿ¯x"@æ @ƒ  Ç @ËBê PA¡ x BÄ(   8  /ˇ˛P ? b«¸  	)Ç ÉÄP @¿?ˇ‡ ¿ ˇ¡–9¡< |  ∂êo∞BÄ(AB  ?«¡¿ <@à¿ÄÉ‡Ä@ àRÄ
" ò#ÄÑP  Ñ Ä 	ˇ˛8‡
 ? „¿$Ä8<˚" p 
Ö à  ‡Ä_√ø√‡¸?Û?ˇ?œ < 0Å è¸p‚ ¯ _ÛüÛ–Ê„¸ @¬ l/é t@ˇ ÄD> ‡ˇÃˇ¸ˇ< @ @ˇ¿ ÒÇ¬‡B ÅÄ |¸‡ú t ‡ô ˘ádDû ~ ôòx‡ ò1Ü?~ >Dg˝·¯< ffxÅ˛Ò¬!<ˇÛÒé |…ì¡‡>  	ñ8g˜Ò‡Ã¸√ÛœÄ0pé·¯‡"œÑ@¸pÊfÅ¯ @pàsÃ¸@Éã0¯ÛÉ§YôÅ¯~‡p≥¸œƒ>8«Ä Ä ¿ >><–8: ¯ @ 83 œÄÄÄ ÄÄ| ôôÁ·Ä~  û¯áÅÄkÊû|áÄff·¯™pàpˇÃ<C„ÄÕõ>®@ ﬁ‹/£·ÄÊa˘ˇ  ‡"√É	ü¬ ~8ÃÃÛ¿?  8D&Å ‡73œ¯  ¸ôûÜ  3ˇ¿Òé q 0  ¿Å?èƒééÄ>   <·‡  ƒ s¿ Û3<Ã ?¿ 3è¿¿ÄÃ√Û˛ ¿Ã¸?÷8D'ü˘û q¿ô3Ê¬¸ 3Ú|·üôüÊp —¬#œ<Côˇ˘‚ ˘ôûf ‡"@à pgÊg˘ú Äff{	¬œˇœD@Éè Ä sBxˇ@8‡ x ¯ @ 8fyÄ  ? àÍ@ 9ôô‡f¯ ò˛y8  ∆~fô¿ 8faÅÁ¯«áˇˇƒ8ÃŸè0?¿ ùß•¿F 8Ãˇœ0¿:8DüÅ ?Ûˇ‡33<¿ˇ ‡·ûò ‡˘ü˘‡F 8ôòf˛áÄÄœ¸ˇ«8«‡: Å #B¯Û@8‡ ¯ x @ 8ô‡ p˛¯ @ =/ˇ  œÛ4‰Ñp# ê @¬?¸¸|#ÄÑˇˇ˜¯ ˘œ˛à¯Òˇ¯G8áÄ#˘ˇÁ„· ¸ Ñ/ÔC‡pˇ√ˇè¿p ¸  ?¸¸|#Äx  Éƒ@üÁ ÄÄ è¿”Áø ‡ ‡‡  „‡ˇ‡ÄÊ¿ÁÁòÄ‡g‡«ˇa @ˇÅúÄˇ¯ˇ˛x G¯88ﬂ¯Á˚ ≥ˇ≈ ¯ˇ¯>ÿ@?‚« ˇ àˇˇ< #¸Ô¸ÚÉê0)¯>ÿ@?Á ÅÄˇÄˇÁÄÉèÄÄpxà‡M„Û |„Ä Ä rd‰Û˙√¯G ‡‡  ÁÄü‡‡˘‡ÅÁˇ ‡Á·˘˛a @ˇÉÄ ?ˇ¸ #¸8À¸Ûˇ¿eø€ |ˇÉ<;ˇ» Ò£ê  ÁÄ B?¡√Ä<ø¿¿? 9 3Áá˘É˛pÄ ?ˇ¸ #¸x   p‡q„œ |„Å√†Ä sq„˜∏HCÅ@ÑPA‡ Ä ‡Á‡˘Áü ‡Á„ﬂ¸A `ˇûÄˇ¯ˇ˘¯G¯8¯¯Á˚¿∑øéá ∏«œ¯≤ ¡ˇ 9 0¯GˇÁ‡‡„‡_‡`îÄÅO«œ¯≤ ¡ˇ8@ˇ¸ ˇ¸¸#¸|   p‡O„√ |„Äx x¿ :Ù&π˝ú a¿< =ì»X „ˇ00–”‡¸|¸ sC¿ œ ∆Ñ <Ñ  ¯x¯¿8‡œ˛¯Û¸–Ï˛çœ  ¯ ˛„ ˘ˇ˛·Ç    œ¯†ÏÄˇá˚˛| {ˇ«¯?˜¯üˇÁˇ¯„áÊxô˘Gõ¿#–W·lˇî1Œ Ä ~Å~