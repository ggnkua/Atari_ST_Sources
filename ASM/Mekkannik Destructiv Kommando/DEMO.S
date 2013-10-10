 * SCROLLING TEXTE 4 PLAN PAR OCTET 
	
        movea.l sp,a5
        move.l 	4(a5),d0
        move.l	d0,savepage
        bra	debintro
chargeprg:
        
        move.l	savepage,a5
        move.l	#$300,d0
        move.l	d0,d1
        add.l	a5,d1
        andi.l  #$fffffffe,d1
        move.l	d1,sp
        move.l  d0,-(sp)
        move.l  a5,-(sp)
        clr.w   -(sp)
        move.w  #$004a,-(sp)
        trap    #1
        adda.l  #$0000000c,sp
        
        pea	env			* charge le prg
	pea	com
	pea	fil
	move.w	#$0003,-(sp)
	move.w	#$004b,-(sp)
	trap	#1
	adda.l	#$00000010,sp
	
*	move.l	d0,a0			*modifie le debut du prg
*	add.l	#$100,a0		          * contre les connards
*	move.l	#$2f3c0000,(a0)		* ds le prg a lancer
					* sous mutil relever en $1c le premier
					* long mot c a d les 8 premiers
					* chiffres et les mettre ici a la place
					* $42sp3f3c et sous mutil en $1c remplacer
					* les 8 chiffres releves par $ffffffff
					
	
	move.l	d0,-(sp)		* lance le prg
	move.l	d0,-(sp)
	move.l	d0,-(sp)
	move.w	#$0004,-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	adda.l	#$10,sp
	

        
debintro:
	move.w	#0,-(sp)	* reso ecran
        move.l	#-1,-(sp)
        move.l	#-1,-(sp)
        move.w	#5,-(sp)
        trap	#14
        adda.l	#12,sp
        
        move.w	#2,-(sp)	*adresse phys memoire ecran
        trap	#14
        addq.l 	#2,sp
        move.l	d0,screedep
        
        bsr     super
	move.b	#$12,$fffc02		* mouse hs
	move.l	#hard,$502		* alt+help hs
        bsr     hide
        bsr	zic_on
        bsr     init_col
        bsr     inter_on
        bsr     cal_pos
        move.w	#1,d4
	bsr     swap
        bsr     clear
        bsr	aff_blk
        bsr	swap
        bsr	clear
        bsr	aff_blk
fin     clr.l   point_text
        move.b  #1,cmt_lettre
debg    bsr     new_lt?
        bsr     scrolg
        *bsr     scroh
        bsr     swap
        bsr	vsync
        bsr     touche
        bra     debg
        
        bsr     cal_pos
        move.l  fin_blk,a1
        move.w  #19,d6
        
        clr.w   -(sp)
        trap #1
        
aff_blk	movea.l phys,a1          * RETOUR DANS A1
        move.w  #300,d0           * NOMBRE DE LIGNE
        movea.l bufdes2,a0       * ADRESSE DU DESSIN
	add.l	#34,a0
aff_lin rept	40
	move.l  (a0)+,(a1)+
        endr
        dbf     d0,aff_lin
        rts
        

scrolg  move.l	#160*160,deca
	move.l  deb_blk,a1
        move.l  a1,a2
        addq.l  #8,a2
        move.l  a1,a0
        move.l  ad_copy,a5
        move.w  #33,d1
sc_blkg REPT    38
        move.l  (a2)+,(a0)+
        ENDR
        move.l  a0,a2
        move.l  a5,a4
        REPT    2
        move.l  (a4)+,(a2)+
        ENDR
        move.l  a0,a2
        move.b  1(a2),(a0)+         * ROUTINE DE DECALAGE OCTET PAR OCTET
        move.b  0(a3),(a0)+         * SUR 8 MOTS C A D 32 PIXELS
        move.b  3(a2),(a0)+         * A EFFECTUER 10 FOIS POUR UN DECALAGE
        move.b  2(a3),(a0)+         * TRANSFERT PLUS INTERRESSENT QUE
        move.b  5(a2),(a0)+         * CEUX DU TYPE move.b 1(a2),0(a2)
        move.b  4(a3),(a0)+         * QUI PRENNENT 20 CYCLES CE TYPE
        move.b  7(a2),(a0)+         * N'EN PREND QUE 16 PAR INSTRUCTION
        move.b  6(a3),(a0)+
        move.l  a0,a2
        addq.l  #8,a2
        add.l   #160,a5
        add.l   #160,a3             * POINTEUR DECALE DE 20 OCTETS=40 PIXELS 
        dbf     d1,sc_blkg
        rts
        
cal_pos move.w  tab_ypos,d0                      * TABLEAU DES POSITIONS VERTICALES
        mulu    #320/2,d0
        move.l  d0,deca                         * CALCUL LIGNE DEPART
        rts
        
vsync   movem.l d0-d3/a0-a3,save_reg
        move.w  #$25,-(sp)                       * SYNCHRO VERTICALE
        trap #14
        addq.l  #2,sp
        movem.l save_reg,d0-d3/a0-a3
        rts
        
clear   move.w  #60,d0                           * EFFACE L'ECRAN
        mulu #200,d0
        subq.w  #1,d0
        move.l  phys,a0
loop    clr.l      (a0)+
        dbf     d0,loop
        rts
        
hide    dc.w $a00a                        * EFFACE LA SOURIS
                rts
                
super   clr.l   -(sp)                     * SUPERVISEUR MODE
        move.w  #$20,-(sp)
        trap #1
        addq.l  #6,sp
        rts
                
mousoff	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#0,-(sp)
	move.w	#0,-(sp)
	trap	#14
	add.l	#12,sp
	rts
       
        
init_col
        lea     palette,a0                       * INITIALISE LA PALETTE
        lea     $ffff8240,a1
        moveq   #7,d4
color   move.l  (a0)+,(a1)+
        dbf     d4,color
        rts
        
ec_phys move.w  #2,-(sp)                 * CHERCHE ADRESSE ECRAN_PHYSIQUE               
        trap #14
        addq.l  #2,sp
        move.l  d0,phys
        rts
        
new_lt? clr.l   d0
        clr.l   d1
        sub.b   #1,cmt_lettre     * TEST DU NOMBRE DE DECALAGE EFFECTUE
        tst.b   cmt_lettre        * SUR UN LETTRE
        bne     end_sc
        move.b  #5,cmt_lettre     * REMET LE COMPTEUR A 4
nvlet   lea     text,a0           * POSITION SUR LA LETTRE A LIRE
        add.l   point_text,a0     * RETOUR DE SON CODE ASCII DS D0
        move.b  (a0),d0
        addq.l  #1,point_text     * INCREMMENTE LE POINTEUR POSITION
	cmp.b	#1,d0
	bcs	nv1
	cmp.b	#7,d0
	bhi	nv1
	move.b	d0,type
	bra	nvlet
nv1	cmp.b   #65,d0                  * TEST DES CARACTERES DE A-Z
        bcs     excla
        sub.b   #65,d0
        bsr     impair
        bra     cont_sc
excla   cmp.b   #33,d0
        bne     parent
        moveq.b #26,d0
        bsr     impair
        bra     cont_sc
parent  cmp.b   #39,d0           * TEST DES CARACTERES ',(,) (27,28,29)
        bcs     trait
        cmp     #41,d0
        bhi     trait
        sub.b   #39,d0
        add.b   #27,d0
        bsr     impair
        bra     cont_sc
trait   cmp.b   #45,d0            * TEST DU CARACTERE '-'
        bne     point
        moveq.b #30,D0
        bsr     impair
        bra     cont_sc
point   cmp.b   #46,d0
        bne     interr
        moveq.b #31,d0
        bsr     impair
        bra     cont_sc
interr  cmp.b   #63,d0
        bne     zero
        moveq.b #32,d0
        bsr     impair
        bra     cont_sc
zero 	cmp.b   #0,d0
        bne     dpoint
        clr.l   point_text
        move.b  #3,cmpt
dpoint  cmp.b	#58,d0
	bne	chiffre
	moveq.b #33,d0
        bsr     impair
        bra     cont_sc
chiffre cmp.b   #48,d0           * TEST DES CARACTERES ',(,) (27,28,29)
        bcs     virg
        cmp     #57,d0
        bhi     virg
        sub.b   #48,d0
        add.b   #34,d0
        bsr     impair
        bra     cont_sc
virg	cmp.b	#44,d0
	bne	space
	moveq.b	#44,d0
	bsr	impair
	bra	cont_sc
space	moveq.b	#45,d0
	bsr	impair
	bra	cont_sc
end_sc  move.l  buf_let,a3
        move.l  inc_sc,d0        * CHERCHE LA VALEUR D'INCREMENTATION
        swap d0                  * DU SCROLL SUR LA LETTRE EN MEMOIRE
        move.l  d0,inc_sc
        ext.l   d0
        add.l   d0,a3
        move.l  a3,buf_let
cont_sc move.l  buf_let,a3
        rts
        
impair  move.l  #$00010007,inc_sc
        move.l  d0,-(sp)
        divu #2,d0
        swap d0
        tst.w   d0
        beq     f_imp
        moveq.l #17,d3
        move.l  #$00070001,inc_sc
        bra     s_imp
f_imp   moveq.l #20,d3
s_imp   move.l  (sp)+,d0
        moveq.l #0,d1
        moveq.l #0,d2
        divu #8,d0
        move.w  d0,d1
        swap d0
        move.w  d0,d2
        tst.b   d2
        bne     mu_imp1
        moveq.l #0,d3
        bra     mu_imp
mu_imp1 subq.w  #1,d2
mu_imp  mulu #5440,d1
        mulu #20,d2
        add.l   d1,d2
        add.l   d2,d3
        add.l   buf_des,d3
        move.l  d3,buf_let
        rts
        
zic_on	st		musik+4730
	move.l	#musik+48,musik+2	
	move.l	#musik+48,musik+12
	move.l	#musik+48,musik+22
	jsr	musik
	rts
	
swap    move.l  sw_ec,d0        * SWAP ECRAN sw_ec=$00080009
        swap    d0              * SWAP LES 2 MOTS
        move.l  d0,sw_ec        * ET RESAUVE
        ext.l   d0
        swap    d0
        add.l   deca,d0
        add.l   #152,d0
        move.l  d0,ad_copy
        move.l  sw_ec,d0
        move.b  d0,$ff8201      * OCTET DE POIDS FORT AD_ECRAN
        move.b  #0,$ff8203      * OCTET DE POIDS FAIBLE AD_ECRAN
        swap    d0
        ext.l   d0
        swap    d0
        move.l  d0,phys         * DETERMINE L'ECRAN PHYSIQUE
        add.l   deca,d0         * DETERMINE LE DECALAGE DU SCROLL PAR
        move.l  d0,deb_blk      * PAR RAPPORT AU BORD DROIT (OCTET) 
        rts
        
inter_on move.l $120,anchbl
        
        move.l  $456,a0
        clr.l   d1
newvec  tst.l   $00(a0,d1.l)
        beq     initvbl
        add.w   #$04,d1
        bra     newvec
        
initvbl lea     $00(a0,d1.l),a2
        lea     vbl,a3
        move.l  a3,(a2)
        move.l  a2,ancvbl
        move.b  $fffa09,d0
        move.b  d0,anca09
        andi.b  #$df,d0
        move.b  d0,$fffa09
        move.b  $fffa07,d0
        move.b  d0,anca07
        andi.b  #$fe,d0
        move.b  d0,$fffa07
        lea     hbl,a0
        move.l  a0,$120
        move.b  $fffa07,d0
        ori.b   #1,d0
        move.b  d0,$fffa07
        move.b  $fffa13,d0
        ori.b   #1,d0
        move.b  d0,$fffa13
        rts
        
touche  move.w  #$00ff,-(sp)
        move.w  #6,-(sp)
        trap    #1
        addq.l  #4,sp
        cmp.b   #$20,d0
        beq     inter_off
        rts 
   
inter_off move.b        anca09,d0
        move.b  d0,$fffa09
        move.b  anca07,d0
        move.b  d0,$fffa07
        move.b  anchbl,$120
        move.l  ancvbl,a0
        clr.l   (a0)
        clr.l	$4d2
        
        move.l  #palette1,-(sp)
        move.w  #6,-(sp)
        trap    #14
        addq.l  #6,sp
        
        move.l	screedep,d0
        swap	d0
        move.b  d0,$ff8201      * OCTET DE POIDS FORT AD_ECRAN
        rol.l	#8,d0
        move.b  d0,$ff8203
       	move.b	#$8,$fffc02	     *souris r‚tablie
        
        *clr.w	-(sp)		* SI TU DEBUG C'EST POUR REVENIR A GENST
        *trap	#1
        
        bra	chargeprg
        

        
vbl     clr.w	$ff8240
	move.b  #0,$fffa1b
        move.w  #0,tabcoul
loop1   move.b  #3,$fffa21
        cmp.b   #3,$fffa21
        bne     loop1
        move.b  #8,$fffa1b
        rts
       
hbl     movem.l  d0/a0,-(sp)
        lea     tabcoul,a0
        move.w  (a0),d0
        move.w  2(a0,d0),$ff8240
        addq.w  #2,(a0)
        cmp.b  #0,d0
        beq    cont1
	*cmp.b  #40,d0
	*beq    cont
mod1    cmp.b  #102,d0
        beq    cont2
	cmp.b  #100,d0
mod2    bne    fhbl
        move.l #$ff8240,a0
        move.w #$732,2(a0)
        move.w #$765,4(a0)
        move.w #$754,6(a0)
        move.w #$643,8(a0)
        move.w #$532,10(a0)
        move.w #$421,12(a0)
        bra    fhbl
cont1	move.l    #$ff8240,a0	* COULEUR DU DESSIN
     	move.w    #$732,2(a0)
     	move.w    #$765,4(a0)
     	move.w    #$754,6(a0)
     	move.w    #$643,8(a0)
     	move.w    #$532,10(a0)
     	move.w    #$421,12(a0)
     	move.w	#$445,14(a0)
     	move.w	#$334,16(a0)
     	move.w	#$223,18(a0)
     	move.w	#$012,20(a0)
     	move.w	#$102,22(a0)
     	move.w	#$556,24(a0)
     	move.w	#$002,26(a0)
     	move.w	#$000,28(a0)
     	bra  fhbl
cont    move.l    #$ff8240,a0
        move.w #$732,2(a0)
        move.w #$765,4(a0)
        move.w #$754,6(a0)
        move.w #$643,8(a0)
        move.w #$532,10(a0)
        move.w #$421,12(a0)
        move.w #$445,14(a0)
        move.w #$534,16(a0)
        move.w #$223,18(a0)
        move.w #$012,20(a0)
        move.w #$102,22(a0)
        move.w #$556,24(a0)
        move.w #$002,26(a0)
        move.w #$707,28(a0)
        bra    fhbl
cont2     move.l    #$ff8240,a0		* COULEUR DES LETTRES
        move.w #$111,2(a0)
        move.w #$222,4(a0)
        move.w #$333,6(a0)
        move.w #$444,8(a0)
        move.w #$555,10(a0)
        move.w #$666,12(a0)
        move.w #$444,14(a0)
        move.w #$555,16(a0)
        move.w #$222,18(a0)
        move.w #$111,20(a0)
        move.w #$333,22(a0)
        move.w #$335,24(a0)
        move.w #$555,26(a0)
        move.w #$444,28(a0)
fhbl    cmp.w #196,d0
     	bne ciao
     	move.b   #1,$fffa21
cont3     cmp.w    #136,d0
     	bne ciao
     	move.b   #4,$fffa21
     	move.l   #hbl2,$120
ciao 	movem.l  (sp)+,d0/a0
        bclr    #0,$fffa0f
        rte
        
hbl2    move.b  #0,$ff820a
        nop
        nop
        nop
        nop
        move.b  #2,$ff820a
        move.l  a0,-(sp)
        lea     hbl,a0
        move.l  a0,$120
        move.l  (sp)+,a0
        bclr    #0,$fffa0f
        rte

sw_ec   dc.l    $00030004
handle  ds.w    1
phys    ds.l 1                         * ADRESSE DEBUT ECRAN PHYSIQUE
save_reg        ds.l $30
buf_des dc.l charge                     * ADRESSE DE CHARGEMENT DU DESSIN
palette dc.w $0,$127,$137,$147,$157,$167,$177,$334,$555,$222
      dc.w $111,$333,$337,$555,$444,$777
        
nom1 dc.b "asdemo.pi1",0
hard	rts
tab_ypos        dc.w 210           * POSITION DU BLOC EN Y
tab_xpos        dc.w 160                * POSITION DU BLOC EN X     
deb_blk ds.l 1                   * ADRESSE DU COIN SUPERIEUR GAUCHE
fin_blk ds.l 1                   * ADRESSE DU COIN INFERIEUR DROIT
hauteur dc.w 13                  * HAUTEUR DU CARACTERE
cmt_lettre      dc.b 1           * COMPTEUR DU NOMBRE DE DECALAGE
                                  * D'UN OCTET SUR UNE LETTRE (4 MAX)
point_text      dc.l 0           * NIEME POSITION SUR 'text'
text	dc.b	13
        dc.B    " FRODON, MAJOR, ET STIX PRESENTE ENCORE UN NOUVEAU JEU QUI A ETE DISTRIBUE PAR LES FAMEUX GROUPES STRANGERS ET ZUUL ! BON, JE PRESENTE LES FAMEUX" 
        DC.B    " ZUUL ET STRANGERS QUI SONT CONSTITUES DE : MAJOR (DIT LE BOUCHER, IL S'EST FAIT ASSASSINER PAR CINQUANTE MILLES MECS EN FURIE MAIS IL EST TOUJOURS VIVANT, QUELLE POISSE !)), NAZGUL"
	DC.B	" (OUAIS ! NAZE GHOULS, MAJOR NE VEUT RIEN TE DIRE !?!),"
        DC.B    " VYPER (LE SWAPPER (EN GENERAL !)),"
        DC.B    " ERNEST (GRAPHISTE, J'ADORE TON NOUVEAU LOGO ! (NOUVEAU MEMBRE MAIS TRES BON !)),"
        DC.B    " ZOMBI (T'AS ESSAYE MON SOUND-TRACKER ! (MERCI NAZGUL !)), STIX (PROGRAMMEUR CONFIRME ET CODEUR, C'EST COOL, NON !), STAR (OUAIS, SUPER !), NUCLEAR (LE BIG GRAPHISTE !), ET FRODON (LE GRAND PATRON ! ET LE MEILLEUR EN SOMME !)..."
        DC.B    " MEGA-GREETINGS A EXIALS TITAN,  THE CRUSADERS (SURTOUT ALTAIR !), BUSCHWAKERS, ARCONIX, F.O.F.T., B.O.S.S., ALL MEMBERS OF THE EMPIRE, LOST BOYS, BBC 89, HIGLANDERS (DES SURVIVANTS !!), " 
        DC.B    " THIERRY (LE RECELEUR !), STARFIRES, JACQUES MAZEAUT (DANS CE GENRE, LA !), ROBERT (DIT LE DEALER ! MERCI POUR L'HERO, HA! HA! HA!), ST-CNX, CHAPI-CHAPO, MEGABLAST, SNOOKER, R.G., STARFIX (LE MEILLEUR GRAPHISTE QUE JE"
	DC.B	" CONNAISSE ! MERCI, POUR TON DESSIN (EN HAUT !), REPLICANTS (MERCI POUR VOS JEUX, FATAL VOTRE DERNIERE DEMO !), MCA, YODA (BIEN TA DERNIERE DEMO !), BLACK-KNIGHT, EQUINOX, ARIOCH, MEDWAYS-BOYS, AUTOMATION, TCB, MAD-MAX, CAREBEARS,"
	DC.B	" CST, ALLIANCE, TEX, ZOLD, SYNC, OMEGA, MIKO, BEESTY, WORLOCK, THE LAST ALLIANCE (SURTOUT LES PARA-MAGNETICS !), UNION, MDK, FRODON (MERDE ! QU'EST-CE-QUE JE FAIS LA ? APRES TOUT !)..."
	DC.B    " ET BIEN SUR J'ALLAIS TOTALEMENT OUBLIE MON PERE (SANS LUI, JE NE SERAI PAS LA !!!), MA MERE (IDEM !), AINSI QUE TOUTE MA FAMILLE (NON MAIS J'AI LE DROIT ?), ET ON CONTINUE ..."                   "  
        DC.B    " HE !!! EST-CE QUE VOUS AVEZ LA ZUUL COMPIL DEMO NUMBERS ONE ET TWO ... NON ! FRANCHEMENT ALLEZ DONC LES CHERCHER CHEZ LE PIRATE DU COIN ET S'IL NE L'A PAS,                FRAPPEZ-LE (DE MA PART !)..." 
        DC.B    " BON, SI VOUS SENTEZ CAPABLE DE FAIRE PARTIE DE NOTRE GROUPE OU PARLER AFFAIRE AVEC NOUS ALORS CONTACTEZ LE PATRON (SUR RTEL BAL TGN PRECISEZ QUE C'EST POUR FRODON !)."
        DC.B	" EN PARLANT DE MINITEL ! BOSS ARRETES TES CONNERIES (ON T'AS RECONNU ! CA PUE, FRANCHEMENT !). COMME VOUS AVEZ PU VOIR, LE GROUPE ZUUL A SUBIT UNE FUSION AVEC LE GROUPE : - THE STRANGERS - ... ET PEUT-ETRE A L'AVENIR AVEC LE"
	DC.B    " OUTSIDERS... ET D'AUTRES QUE NOUS POUVONS CITER ! VOUS RISQUEZ PARLER DES MEMBRES DE ZUUL, NON MAIS !"
        DC.B    " CE SCROLL A ETE FAIT A LA GRACE DES MEMBRES DE ZUUL QUI SONT COMPLETEMENT FRAPPES DU CERVEAU MAIS SURTOUT FRODON !"                                                                             
        DC.B    " MESSAGE DE MAJOR POUR BOX (BOSSU) :" 
        DC.B    " QUAND ON NE SAIT PAS PROGRAMMER, ON NE CRITIQUE PAS MES DEMOS ! ON NE VOLE PAS LES DEMOS DES AUTRES EN DISANT QUE C'EST MOI QUI L'AI FAIT. POUR CEUX"
	DC.B	" QUI N'AURAIT PAS SUIVI (JE SAIS PAS QUOI METTRE EN TERMINAISON, J'SUIS UN MATHEUX MOI !!! CA C'EST UN BOULOT POUR NAZE GHOULS) TOUTE L'HISTOIRE"
	DC.B	" CE CRAPAUD DE BOSS S'EST POINTE CHEZ MOI AVEC DE SUPERBES DEMOS EN CRIANT A QUI VOULAIT BIEN L'ENTENDRE : ' J'AI FAIT !! ' EN FAIT CE CRAPAUD RECUPERE"
	DC.B	" LES SOURCES QU'ON LUI AVAIT GENTIMENT DONNE ET CHANGEAIT LE TEXTE. DE PLUS CETTE E.N..E NE VOULAIT PAS ME LES FILER SUREMENT DE PEUR QUE J'APPRENNE"
	DC.B	" L'ASSEMBLEUR ET QUE JE L'ECRASE. MAIS MON IMMENSE AMI FRODON ME LES A PROCURER. DESOLE DE VOUS AVOIR PRIS LE CHOU AINSI, MAIS J'ESTIME QUE CETTE MISE AU POINT"
	DC.B	" ETAIT NECESSAIRE. JE PENSE QUE MAINTENANT JE NE PARLERAIS PLUS DE CETTE E.F...E (MAIS SI TU VEUX ME DEMANDER DES DEMOS OU ASTUCES (AH, NON CA FAUT DEJA AVOIR"
	DC.B	" DES RUDIMENTS POUR UTILISER LES ASTUCES !!)). TU PEUX TOUJOURS ME CONTACTER (EN PASSANT PAR FRODON, MOI, JE NE VEUX PAS TE VOIR.) (AH NAN FRODON VEUT PAS TE VOIR NON PLUS"
	DC.B	" DESOLE !!) ALORS LA T'ES CUIT PERSONNE NE VEUT TE VOIR. TU PEUX TE TATER. ADIIIIEUUUUUUUUU......"
	DC.B	" SOYONS SERIEUX UN PEU ET OUBLIONS CE DEGENERE. POUR VOUS DIRE AU REVOIR JE VOULAIS VOUS DIRE : ' QUE LE KI SOIT AVEC VOUS ' MAIS VOYONS FRODON TIRANT UNE GUEULE (BONJOUR !!)"
	DC.B	" IL FAUT QUE JE VOUS EXPLIQUE RAPIDEMENT CE QUE C'EST. LE KI EST EN GROS UNE ENERGIE INTERNE QUE NOUS POSSEDONS TOUS, MAIS QUE TRES PEU DE PERSONNES SAVENT UTILISER."
	DC.B	" COMME JE VOIS QUE CELA VOUS INTERESSE DORENAVANT DANS CHAQUE DEMO JE VOUS DONNERAIS UN COURS AYANT UN RAPPORT AVEC LES ART-MARTIAUX (NINJA, SPORT, SCIENCES ETC...)."
	DC.B	" BON JE VOUS LAISSE. J'EN GARDE POUR LA PROCHAINE FOIS ET FRODON VEUT TAPER (DU TEXTE EH! OH! PAS MOI). ALLEZ MAINTENANT JE PEUX LE DIRE : QUE LE KI SOIT AVEC VOUS !!!!"
	DC.B	" BON, LACHE CE CLAVIER ! A MOI (FRODON !) PARLER : CA SE VOIT QUE MAJOR DETESTE BOSS (BON ! ENFIN, PASSONS !)... JE SAIS QUE MAJOR VOUS A PRIS LA TETE AVEC SON QI (OU PLUTOT KI VOCIFERA MAJOR !). JE TIENS A ME REMERCIER,"
	DC.B	" JE VAIS VOUS CONFIER UN SECRET (VOUS L'AVEZ BIEN MERITE CAR IL FAUT COMPRENDRE MAJOR QUI NE POSSEDE AUCUNE PONCTUATION  -,.:?!). POUR RENTREZ CHEZ NAZGUL : IL FAUT POSSEDER"
	DC.B	" 5 M16 A2, 12 LANCES-FLAMMES, (PUTAIN ! ON SE CROIT A DOGS OF WAR !), UN HELICOPTERE (BON, ARRETEZ LA LISTE EST TROP LONGUE !)... BON SALUT A NAZGUL, MAJOR, STIX, FRODON (MOI !)"
        DC.B	" VYPER, NUCLEAR, ERNEST, MEGABLAST, SNOOKER, TGN, STAR, MAVERICK, MC BEST (POUR AINSI DIRE LE TEXTE EST FINIE ET LA ZUUL COMPIL DEMO 3 AUSSI ! IL MANQUE UNE DEMO DE MAJOR, STIX, NAZGUL, ETC..."
	DC.B    " ET LES MALHEUREUX QUI ONT LU CE SCROLL JUSQU'A LA FIN... BYE ... BYE ... BYE ...                        CA RECOMMENCE !              OH ! NON !                                     ",0

inc_sc  ds.l 7            * VALEUR D'INCREMENTATION =7 OU =1
buf_let ds.l 1
ad_copy ds.l 1        
deca    ds.l 1 
       


tabcoul	dc.w	200
	rept	51
	dc.w	0
	endr
	dc.w	$737,$727,$717,$707,$706,$705,$704,$703,$702,$701,$701,$700,$700,$700,$0
	
        
palette1        dc.w    $777,$111,$222,$333,$111,$222,$333,$444,$555
        dc.w    $000,$001,$100,$200,$020,$002,$123      

anchbl  ds.l    1
ancvbl  ds.l    1
anca09  ds.b    1
anca07  ds.b    1
charge  INCBIN  "pic.pac"
bufdes2 dc.l	charge2
charge2	INCBIN	"ninjafix.pi1"
cmpt 	dc.b 	3
	dc.b	0
        
musik	INCBIN	"thrust.bin"
fmusik	
pas	dc.w	0	
senscol	ds.w	1        
last	ds.w	1
chbl	dc.w	0

cst	ds.l	1
ss	dc.l	1
cmptcst	dc.b	0
cst1	ds.l	1
ss1	dc.l	1
cmptcst1	dc.b	0
type	dc.b	0
savepage	ds.l	1
screedep	ds.l	1
fil:	dc.b	"game.dat"
com:	dc.b	0
env:      dc.b      0

