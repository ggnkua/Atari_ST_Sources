************************************
* DESASS.S  desassembleur maison   *
*                                  *
*  15/06/86  v1.0                  *
************************************
* ODOSB *
*********
.data
.even

VPILUT    equ $300       ;nb byte a reserver pour pile util.
ESC       equ $1d        ;
LFEED     equ $d         ;codes ascii
RC        equ $a         ;
LISTPLUS  equ $40        ;increments pour compteur list et dump
DUMPPLUS  equ $140       ;

vcmdtab : dc.w 'D '      ;tableau des commandes. Pour chaque commande,
          dc.l ldump0    ;  2 bytes pour le codage de la commande
          dc.w 'ED'      ;  4 bytes pour l'adresse de la routine associee
          dc.l lseled0
          dc.w 'Q '
          dc.l lexit0
          dc.w 'L '
          dc.l llist0
          dc.w 'LO'
          dc.l load0
          dc.w 'HE'
          dc.l lhelp0
          dc.l 0


vlinst1 : dc.l lnoin     ;table de redirection propre a linst
          dc.l l1in,l2in,l3in,l4in,l5in,l6in,l7in,l8in
          dc.l l9in,l10in,l11in,l12in,l13in,l14in,l15in,l16in
          dc.l l17in,l18in,l19in,l20in,l21in,l22in,l23in,l24in
          dc.l l25in

vlecop1 : dc.l lecop1    ;table une de redirection pour lecop
          dc.l lecop2,lecop3,lecop4,lecop5,lecop6,lecop7,lecop8
vlecop2 : dc.l lecop9    ;table deux
          dc.l lecop10,lecop11,lecop12,lecop13

vl3in   : dc.l $3c       ;table de redirection propre a l3in
          dc.l $7c,$23c,$27c,$a3c,$a7c,0
          dc.l l3in4,l3in3,l3in4,l3in3,l3in4,l3in3,l3in5

vrmsk1  : dc.l $80004000  ;donnees propres a l18in
          dc.l $20001000,$08000400,$02000100
          dc.l $00800040,$00200010,$00080004,$00020001
vrmsk2  : dc.l $00010002,$00040008,$00100020,$00400080
          dc.l $01000200,$04000800,$10002000,$40008000

vdumpos1 : dc.l 0         ;variables bornes
vdumpos2 : dc.l 0         ;  pour le dump
vlispos1 : dc.l 0         ;pour le desassemblage
vlispos2 : dc.l 0         ;

vmodedi  : dc.b 1         ;mode edition init sur console
           dc.b 0         ;dummy





mpres   : dc.b 'Desassembleur maison  15/06/86  v1.0. ',LFEED,LFEED,0
mbye    : dc.b LFEED,RC,'Press RETURN to exit.',0
mplus   : dc.b LFEED,RC,0
mtab    : dc.b '  ',0
mprompt : dc.b LFEED,LFEED,RC,'-',0

merr1   : dc.b LFEED,RC,'Commande inconnue.',0
mhelp   : dc.b LFEED,RC,'Usage : HELP  '
          dc.b LFEED,RC,'Usage : LO ficname'
          dc.b LFEED,RC,'Usage : D ad1 ad2'
          dc.b LFEED,RC,'Usage : L ad1 ad2'
mseled  : dc.b LFEED,RC,'Usage : ED n   avec  : ',LFEED,RC
          dc.b '  n=1=console / n=2=imprimante / n=4=fichier.',0
mseled2 : dc.b LFEED,RC,'Nom de fichier SVP : ',0
mseled3 : dc.b LFEED,RC,'Echec sur creation fichier  ',0
mseled4 : dc.b LFEED,RC,'Echec sur fermeture fichier courant',0
mseled5 : dc.b LFEED,RC,'Fichier existant, on ecrase ? (o/n) ',0
mbadsiz : dc.b 'illegal size field',0
mlecop  : dc.b '(PC)',0
mnoin   : dc.b 'illegal instruction format',0
ml24in  : dc.b 'illegal control register',0
mload1  : dc.b LFEED,RC,'Echec sur chargement fichier  ',0
mload2  : dc.b LFEED,RC,'ADRESSE = 00000000     LENGTH = 00000000  ',0


.bss
.even

vbpa   : ds.l 1           ;base page adress
vhiprg : ds.l 1           ;haut de prg
vbuff1 : ds.l 20          ;buffer de 80 caracteres
vbuff2 : ds.l 8           ;autre buffer de 16 caracteres
vsavssp : ds.l 1          ;sauvegarde de ptr ssp
vdot   : ds.l 1           ;
vsdot  : ds.l 1           ;variables ptrs adresse memoire
vinstr : ds.w 1           ;contenu d'une instruction en desassemb.
v2modedi : ds.b 1         ;doublure de modedi
           ds.b 1         ;  dummy
vnomf0 : ds.w 1           ;
vnomf  : ds.l 4           ;nom du fichier courant
vfd    : ds.w 1           ;file descriptor ficcour




.text
.even

**************************************************
*  D E B U T     P R O G R A M M E               *
**************************************************


liniprg : move.l  $4(a7),a5    ;
          move.l  a5,vbpa      ;recup base page adress

          move.l  #VPILUT,d0   ;calcul de la long prg
          add.l   $c(a5),d0    ;  pile util.+long text
          add.l   $14(a5),d0   ;  +long data
          add.l   $1c(a5),d0   ;  +long bss

          move.l  d0,d1        ;
          add.l   a5,d1        ;positionnement pile util.
          and.b   #$fe,d1      ;
          move.l  d1,a7        ;
          add.l   #$10,d1      ;et sauve dans variable
          move.l  d1,vhiprg    ;

          move.l  d0,-(a7)     ;
          move.l  a5,-(a7)     ;
          clr.w   -(a7)        ;mshrink pour rendre mev non
          move.w  #$4a,-(a7)   ;  utilisee au gemdos
          trap    #1           ;
          add.l   #$c,a7

          bra     lsuit0        ;saute les sous-prg generaux


******************************************************************
*   ENSEMBLE DES PROGRAMMES SOURCES GENERAUX                     *
******************************************************************
* laffi     ljmpwo   lclos              *
* lgets     lkey     llens              *
* lhtoi     limpr    litoa              *
* litohf    lgeton   lopen              *
* ljmpsp    lcrea                       *
*****************************************


********************************************
*  laffi = SS-PRG GAL                      *
*        affichage d'un  message a l'ecran *
*                                          *
* 29/02/86 v1.0    15/06/86 v2.0           *
********************************************
*  Entree = (pile.l) ptr msg null termine  *
*                                          *
*  Sortie = affichage realise              *
********************************************
laffi : link    a6,#0
        move.l  a0,-(a7)     ;sauve a0 perturbe par le trap

        move.l  $8(a6),-(a7) ;empile ptr vers msg
        move.w  #9,-(a7)     ;
        trap    #1           ;appel os pour exec  cette fonction
        add.l   #6,a7        ;

        move.l  (a7)+,a0     ;recup des registres
        unlk    a6
        rtsø


*******************************************
*  laffii = SS-PRG GAL                    *
*          affichage d'un entier a l'ecran*
*                                         *
* 07/04/86  v1.1   15/06/86 v2.0          *
*******************************************
*  Entree = (pile.w) entier a ecrire      *
*                                         *
*  Sortie = affichage realise             *
*******************************************
* Utilise :  laffi                        *
*            litoa                        *
*******************************************
laffii : link     a6,#-8       ;reserve place pour buffer

         move.l   a6,-(a7)     ;
         sub.l    #8,(a7)      ;empile le ptr vers buffer
         move.w   $8(a6),-(a7) ; puis le nb

         bsr      litoa        ;transfo du nb en chaine
         add.l    #2,a7        ; reste dans la pile le ptr vers buffer
         bsr      laffi        ;affiche le resultat
         add.l    #4,a7        ;
         unlk     a6
         rts


***************************************
*  lclos  = SS PRG GAL                *
*           fermeture de fichier      *
*                                     *
* 15/06/86 v1.0                       *
***************************************
* Entree : (pile.w) handle du fichier *
*                                     *
* Sortie : fermeture realisee         *
*          d0=0 ou code erreur        *
***************************************
lclos  : link    a6,#0
         movem.l d1/a0-a1,-(a7) ;
         move.w  $8(a6),-(a7)   ;appel systeme
         move.w  #$3e,-(a7)     ;
         trap    #1
         add.l   #4,a7
         movem.l (a7)+,d1/a0-a1
         unlk    a6
         rts


**************************************
* lcrea  = SS PRG GAL                *
*       creation + ouverture fichier *
*                                    *
*  15/06/86  v1.0                    *
**************************************
* Entree : (pile.l) ptr vers nom fic *
*                                    *
* Sortie : d0=handle ou code erreur  *
**************************************
* MODCREA definit le mode fichier    *
**************************************
MODCREA equ $0
lcrea  : link    a6,#0
         movem.l a0-a1,-(a7)
         move.w  #MODCREA,-(a7) ;
         move.l  $8(a6),-(a7)   ;appel systeme
         move.w  #$3c,-(a7)     ;
         trap    #1
         add.l   #8,a7
         movem.l (a7)+,a0-a1
         unlk    a6
         rts

**************************************
*  lgeton = SS PRG GAL               *
*           dial operateur           *
*           recup de 'o' ou 'n'      *
*                                    *
*           07/04/86 V1.0            *
**************************************
* Entree :                           *
* Sortie : d0=0 si 'n', d0=1 si 'o'  *
**************************************
lgeton : move.l #1,d0     ;init de d0 pour 'o'
lgeton1: move.w #8,-(a7)  ;
         trap   #1        ;lecture clavier sans echo
         add.l  #2,a7     ;  de 1 char

         cmp.b  #$60,d0   ;frappe de minuscules ?
         ble    lgeton2   ;non, on suit
         sub.b  #$20,d0   ;oui, on se ramene aux majuscules

lgeton2: cmp.b  #$4f,d0   ;'o' ?
         beq    lgetonfin ;  si oui on sort (d0=1)

         cmp.b  #$4e,d0   ;'n'?
         bne    lgeton1   ;ni 'o' ni 'n' on reviendra en 2eme semaine
         clr.l  d0        ;'n', on met d0<-0

lgetonfin : rts


***************************************
*  lgets = SS PRG GAL                 *
*          lecture d'une string       *
*                                     *
* 07/0/86 V1.0   15/06/86 v2.0        *
***************************************
* Entree : (pile.l) ptr chaine cible  *
*                                     *
* Sortie : la chaine est valorisee    *
***************************************
lgets  : link    a6,#0
         movem.l d0/a0,-(a7)

         move.l  $8(a6),-(a7)  ;ptr buffer
         move.w  #$a,-(a7)     ;
         trap    #1            ;lecture de la chaine
         add.l   #6,a7         ;  toutes fcts disponibles

         move.l  $8(a6),a0     ;
         clr.l   d0            ;
         move.b  $1(a0),d0     ;met null+null en fin de chaine
         add.l   d0,a0         ;
         move.b  #0,$2(a0)
         move.b  #0,$3(a0)

         movem.l (a7)+,d0/a0
         unlk    a6
         rts


**************************************
*  lhtoi = SS PRG GAL                *
*          transfo hexa -> entier    *
*                                    *
* 13/04/86 v1.0   15/06/86 v2.0      *
**************************************
* Entree : (pile.l) ptr chaine hexa  *
*                                    *
* Sortie : d0=nb resultat            *
**************************************
lhtoi  : link    a6,#0
         movem.l d7/a0,-(a7)
         clr.l   d0             ;init du resultat
         move.l  $8(a6),a0      ;ptr chaine hexa

lhtoi1 : move.b  (a0)+,d7       ;recup du caractere a traiter
         cmp.b   #$30,d7        ;
         blt     lhtoifin       ;si code car < '0' on sort (car non hexa)
         cmp.b   #$39,d7        ;
         ble     lhtoi3         ;ici car numerique on va en lhtoi2

*        ici car non numerique
         cmp.b   #$60,d7        ;
         ble     lhtoi2         ;passage minuscule majuscule
         sub.l   #$20,d7        ;

lhtoi2 : cmp.b   #$41,d7        ;
         blt     lhtoifin       ;si car non compris de 'a' a 'f'
         cmp.b   #$46,d7        ;  on sort
         bgt     lhtoifin       ;

         add.b   #9,d7          ;d7= $4a a $4f 

*        ici code = $30 a $39  ou  $4a a $4f
lhtoi3 : and.b   #$f,d7         ;recup du dernier nibble faible(4 bits)
         lsl.l   #4,d0          ;
         or.b    d7,d0          ;d0 <- d0*16+d7
         bra     lhtoi1         ;boucle pour carsuiv

lhtoifin : movem.l (a7)+,d7/a0
           unlk    a6
           rts


**************************************
*  limpr = SS PRG GAL                *
*          impression d'une chaine   *
*          sur imprimante            *
*                                    *
* 15/06/86 v1.0                      *
**************************************
* Entree = (pile.l) ptr sur chaine   *
*                                    *
* Sortie = impression realisee       *
**************************************

limpr  : link    a6,#0
         movem.l d0-d1/a0-a1,-(a7)
         move.l  $8(a6),a0         ;ptr chaine a traiter

         move.w  #$11,-(a7)        ;
         trap    #1                ;imprimante disponible ?
         add.l   #2,a7             ;

         tst.w   d0                ;
         bne     limpr1            ;si dispo on saute

         move.l  #mlimpr1,-(a7)    ;affiche msg echec
         bsr     laffi             ;
         add.l   #4,a7             ;
         bra     limprfin          ;et bye
mlimpr1  : dc.b LFEED,RC,'Imprimante non prete.',0

limpr1 : move.b  (a0)+,d0          ;d0=carcour et carsuiv
         ext.w   d0                ;
         tst.w   d0                ;si termine on sort
         beq     limprfin          ;

         move.w  d0,-(a7)          ;
         move.w  #5,-(a7)          ;envoi de carcour a imprimante
         trap    #1                ;
         add.l   #4,a7             ;
         bra     limpr1            ;et boucle sur carsuiv
limprfin : movem.l (a7)+,d0-d1/a0-a1
           unlk    a6
           rts


**************************************
*  litoa = SS PRG GAL                *
*          transfo entier -> ascii   *
*                                    *
* 07/04/86 V1.0    15/06/86 v2.0     *
**************************************
* Entree : (pile.w) entier a coder   *
*          (pile.l) ptr chaine cible *
*                                    *
* Sortie : chaine valorisee          *
**************************************
litoa  : link     a6,#0
         movem.l  d6-d7/a0,-(a7)

         move.w   $8(a6),d6      ;
         ext.l    d6             ;recup du nb a coder
         move.l   $a(a6),a0      ; et du ptr buffer

         move.l   #$20202020,(a0)  
         move.l   #$20300000,$4(a0) ;init du tampon resultat
         move.l   #5,d7             ;init du ptr deplacement

         tst.l    d6             ;d6 positif ?
         bpl      litoa1         ;oui on passe
         neg.l    d6             ;non d6<-|d6|

litoa1 : tst.l    d6             ;termine ?
         beq      litoa2         ;

         divs     #10,d6         ;
         swap     d6             ;decompose d6 en base 10
         move.b   d6,$0(a0,d7)   ;
         add.b    #$30,$0(a0,d7) ;met le code ascii du reste dans
         sub.w    #1,d7          ;  la chaine. maj le ptr deplacement
         swap     d6             ;
         ext.l    d6             ;recup du resultat de la decomposition
         bra      litoa1         ;  et boucle

litoa2 : tst.w    $8(a6)         ;entier positif ?
         bpl      litoafin       ;oui on passe
         move.b   #$2d,$0(a0,d7) ;non, place '-' dans la chaine

litoafin : movem.l (a7)+,d6-d7/a0
           unlk    a6
           rts


******************************************
* litohf = SS-PRG GAL                    *
*          entier -> hexa ,format libre  *
*                                        *
* 15/06/86 v1.0                          *
******************************************
* Entree = (pile.l) ptr chaine cible     *
*          (pile.w) format desire en bits*
*          (pile.l) nb a traiter         *
*                                        *
* Sortie = chaine cible valorisee + null *
******************************************

litohf   : link    a6,#0
           move.l  d0,-(a7)
           movem.l d5-d7/a0,-(a7)

           move.l  $8(a6),d6    ;nb a traiter
           move.w  $c(a6),d7    ;format
           move.l  $e(a6),a0    ;ptr chaine cible

litohf1  : tst.w   d7           ;termine ?
           beq     litohffin    ;

           sub.w   #4,d7        ;
           move.l  d6,d0        ;d0<-nibble poids fort
           asr.l   d7,d0        ;
           and.l   #$f,d0       ;

           cmp.b   #$a,d0
           blt     litohf2
           add.b   #7,d0        ;transfo chiffre de 0 a 15
litohf2  : add.b   #$30,d0      ;  en code hexa

           move.b  d0,(a0)+     ;met le code dans le tampon
           bra     litohf1      ;et boucle

litohffin : clr.b  (a0)+        ;met null a a la fin
           movem.l (a7)+,d5-d7/a0
           move.l  (a7)+,a0
           unlk    a6
           rts



***********************************************
*  ljmpsp   =  SS-PRG GAL                     *
*              saut des blancs dans la phrase *
*                                             *
* 29/02/86 v1.0     07/04/86   v1.1           *
* 15/06/86 v2.0                               *
***********************************************
* Entree = (pile.l) ptr car qq d'une chaine   *
*             null terminee                   *
*                                             *
* sortie = d0 pointe null, rc  ou le 1er      *
*             caractere <> ' ' rencontre      *
***********************************************
ljmpsp  :  link   a6,#0
           move.l a0,-(a7)

           move.l $8(a6),a0    ;ptr chaine

ljmpsp1 :  tst.b  (a0)         ;si null termine
           beq    ljmpspfin    ;

           cmp.b  #$20,(a0)+   ;si  space on boucle
           beq    ljmpsp1      ;

           sub.l  #1,a0

ljmpspfin : move.l a0,d0
           move.l (a7)+,a0
           unlk   a6
           rts



*********************************************
*  ljmpwo   = SS PRG GAL                    *
*             saut d'un mot (ensemble de    *
*             caracteres non blancs)        *
*                                           *
* 22/02/86 v1.0   15/06/86 v2.0             *
*********************************************
* Entree = (pile.l) ptr caractere non blanc *
*             dans une chaine terminee par  *
*             null, composee de lignes      *
*             separees par des RC           *
*                                           *
* Sortie = d0 pointe 1er car suivant le mot *
*********************************************
ljmpwo   : link    a6,#0
           move.l  a0,-(a7)

           move.l  $8(a6),a0   ;ptr carcour

ljmpwo1  : tst.b   (a0)        ;
           beq     ljmpwofin   ;si (a0)=null ou ' ' ou rc
           cmp.b   #$d,(a0)    ;  on sort
           beq     ljmpwofin   ;
           cmp.b   #$20,(a0)+  ;
           bne     ljmpwo1     ;sinon boucle

           sub.l   #1,a0       ;

ljmpwofin: move.l  a0,d0       ;
           move.l  (a7)+,a0
           unlk    a6
           rts



******************************************
*  lkey = SS-PRG GAL                     *
*         lecture etat clavier           *
*                                        *
*  15/06/86 v1.0                         *
******************************************
* Entree = neant                         *
*                                        *
* Sortie = d0=0 si pas de frappe         *
*          ou d0=code du car frappe      *
******************************************

lkey   : move.w  #$b,-(a7)
         trap    #1             ;lecture etat clavier
         add.l   #2,a7          ;

         tst.w   d0
         beq     lkeyfin

         move.w  #7,-(a7)       ;un car frappe, on le lit
         trap    #1             ;
         add.l   #2,a7

lkeyfin : rts


************************************
* llens  = SS PRG GAL              *
*          longueur d'une + null   *
*                                  *
*  15/06/86  v1.0                  *
************************************
* Entree : (pile.l) ptr vers chaine*
*                                  *
* Sortie : d0=longueur chaine      *
************************************
llens  : link    a6,#0
         move.l  a0,-(a7)
         clr.l   d0        ;init du compteur
         move.l  $8(a6),a0 ;pointe le debut chaine

llens1 : tst.b   (a0)+     ;carsuiv, fin de chaine ?
         beq     llensfin  ;  oui bye
         add.l   #1,d0     ;plus 1 au cptr
         bra     llens1    ;boucle

llensfin : move.l (a7)+,a0
           unlk   a6
           rts

*****************************************
*  lopen = SS-PRG GAL                   *
*          ouverture de fichier         *
*                                       *
* 22/02/86   v1.1   15/06/86            *
*****************************************
* Entree = (pile.l) ptr filename + null *
*                                       *
* Sortie = open realise. d0=handle ou   *
*          code d'erreur                *
*****************************************
MODOPEN equ 0
lopen  : link     a6,#0
         move.w   #MODOPEN,-(a7) ;mode desire lect/ecri/append
         move.l   $8(a6),-(a7)   ;ptr filename
         move.w   #$3d,-(a7)     ;appel au gemdos
         trap     #1             ;
         add.l    #8,a7          ;

         unlk     a6
         rts


*********************************************************
*  P R O G R A M M E    P R I N C I P A L   S U I T E   *
*********************************************************
lsuit0 : move.l  #mpres,-(a7)   ;
         bsr     laffi          ;affiche msg de presentation
         add.l   #4,a7          ;

lsuit1 : move.l  #mprompt,-(a7) ;
         bsr     laffi          ;affiche le prompt pour
         add.l   #4,a7          ;  entree commande

         move.l  #vbuff1,a1     ;ptr buffer de saisie commande
         move.w  #$4800,(a1)    ;  init 1er mot du buffer
         move.l  a1,-(a7)       ;
         bsr     lgets          ;lecture de la commande
         add.l   #4,a7          ;

         move.b  $1(a1),d0      ;
         beq     lsuit1         ;d0=nb de bytes lus
         and.l   #$ff,d0        ;  si zero,boucle sur lect.cmde
         add.l   #2,a1          ;a1 pointe 1er car frappe

lsuit2 : cmp.b   #$60,(a1)      ;passage minuscule->majuscules
         blt     lsuit3         ;  si besoin
         sub.b   #$20,(a1)      ;

lsuit3 : tst.b   (a1)+          ;on est a la fin de la chaine ?
         bne     lsuit2         ;  non, on boucle sur carsuiv

*
*le buffer est prepare, caracteres majuscules
*

         move.l  #vbuff1,a1     ;a1 pointe le premier caractere
         add.l   #2,a1          ;  frappe

         move.l  a1,-(a7)       ;
         bsr     ljmpsp         ;saute les blancs en debut ligne
         add.l   #4,a7          ;  retour, d0 pointe le 1er car
         move.l  d0,a1          ;  non blanc

         tst.b   (a1)           ;pointe la fin de chaine ?
         beq     lsuit1         ;  oui, ligne blanche,
         cmp.b   #RC,(a1)       ;  on boucle sur saisie commande
         beq     lsuit1         ;

*
*il y a frappe, recherche de la commande
*

         move.l  #vcmdtab,a5    ;a5 pointe le debut du tableau
         move.b  (a1),d5        ;d5<-code commande
         lsl.l   #8,d5          ;  sur 2 octets
         move.b  $1(a1),d5      ;

         tst.b   d5             ;
         bne     lsuit4         ;si null suit la commande 
         move.b  #$20,d5        ;  ajoute ' '

lsuit4 : tst.w   (a5)           ;si tableau non fini
         bne     lsuit5         ;  on regarde si c'est la bonne cmde

        move.l  #merr1,-(a7)    ;ici la table est finie, commande
         bsr     laffi          ;  inconnue, affichage msg
         add.l   #4,a7          ;  et boucle sur saisie cmde
         bra     lsuit1         ;

lsuit5 : cmp.w   (a5),d5        ;bonne commande ?
         beq     lsuit6         ;  oui on suit...
         add.l   #6,a5          ;  non, elt suivant de la table
         bra     lsuit4         ;  et boucle

*
*on a trouve la commande desiree dans la table
*on se branche sur la routine adaptee
*

lsuit6 : add.l   #2,a1          ;a1 pointe 1er car apres la cmde

         move.l  $2(a5),a5      ;
         jsr     (a5)           ;appel routine adaptee

         bra     lsuit1         ;retour exec cmde, nouvelle saisie




*****************************************
* SS PROGRAMME   HELP                   *
*****************************************

lhelp0  : move.l  #mhelp,-(a7)
          bsr     laffi
          add.l   #4,a7
          rts


**********************************************
* SS PROGRAMME DE DUMP                       *
**********************************************

ldump0  : move.l  vdumpos1,vdumpos2
          add.l   #DUMPPLUS,vdumpos2 ;init des variables bornes du dump
          move.l  #vbuff2,a5       ;
          move.b  #$a,(a5)+        ;
          move.b  #$d,(a5)+        ;init envoi de retour chariot
          clr.b   (a5)
          move.l  #vbuff2,a0
          bsr     ledi

          move.l  #DUMPPLUS,-(a7)  ;
          move.l  #vdumpos1,-(a7)  ;
          bsr     litborn          ;recup des bornes
          add.l   #8,a7            ;  dans la ligne de cde

          clr.l   -(a7)            ;
          move.w  #$20,-(a7)       ;passage en superviseur
          trap    #1               ;
          add.l   #6,a7
          move.l  d0,vsavssp

ldump1  : move.l  #vbuff1,a1       ;pointe le debut du buffer
          move.l  vdumpos1,d0      ;affiche l'adresse
          bsr     lechl            ;

          move.b  #$20,(a1)+
          move.b  #$20,(a1)+

          move.l  vdumpos1,a5      ;
          clr.w   d7               ;var de boucle

ldump2  : move.b  #$20,(a1)+       ;
          move.l  (a5,d7.w),d0     ;
          bsr     lechl            ;affiche le dump de vdumpos1 
          add.w   #4,d7            ;  +0 a +$f
          cmp.w   #$c,d7           ;
          ble     ldump2           ;boucle

          move.b  #$20,(a1)+
          move.b  #$20,(a1)+

          move.b  #$a,$10(a1)      ;
          move.b  #$d,$11(a1)      ;ajoute retour chariot
          move.b  #0,$12(a1)       ;  et null
          move.w  #$f,d7           ;

ldump3  : move.b  (a5,d7.w),d6     ;
          move.b  d6,(a1,d7.w)     ;met le code car dans le buffer
          cmp.b   #$21,d6          ;
          blt     ldump4           ;car affichable ?
          cmp.b   #$7e,d6          ;
          ble     ldump5

ldump4  : move.b  #$2e,(a1,d7.w)   ;si non affich, met '.'

ldump5  : dbra    d7,ldump3

          move.l  #vbuff1,a0       ;affiche la ligne
          bsr     ledi             ;  selon le mode d'edition courant

          move.l  vdumpos1,d7      ;
          add.l   #$10,d7          ;borne inf progresse
          move.l  d7,vdumpos1      ;
          cmp.l   vdumpos2,d7      ;on continue si borne inf
          blt     ldump1           ;  < borne sup

          move.l  vsavssp,-(a7)    ;
          move.w  #$20,-(a7)       ;passage utilisateur
          trap    #1               ;
          add.l   #6,a7            ;

ldumpfin : rts


***************************************************
* SOUS - PROGRAMME  SELECTION EDITION             *
***************************************************

lseled0 : move.l  a1,-(a7)       ;
          bsr     ljmpsp         ;saute les blancs et pointe le 1er
          add.l   #4,a7          ;  car non blanc derriere la cmde
          move.l  d0,a1          ;
          tst.b   (a1)           ;caractere null ?
          beq     lseled1        ;  oui erreur

          move.l  a1,-(a7)       ;
          bsr     ljmpwo         ;
          add.l   #4,a7          ;pointe le 1er car derriere le mot
          move.l  d0,a5          ;  et y met null
          clr.b   (a5)           ;

          move.l  a1,-(a7)       ;transfo hexa->entier
          bsr     lhtoi          ;
          add.l   #4,a7          ;

          cmp.b   #1,d0          ;
          blt     lseled1        ;si demande non comprise de 1 a 7
          cmp.b   #7,d0          ;  il y a erreur
          ble     lseled2        ;

lseled1 : move.l  #mseled,-(a7)  ;erreur
          bsr     laffi          ;  affich msg et bye
          add.l   #4,a7          ;
          bra     lseledfin      ;

lseled2 : move.b  d0,v2modedi    ;sauve le format demande
          btst    #2,v2modedi    ;edition > fichier ?
          beq     lseled6        ;  non ...
          btst    #2,vmodedi     ;deja le cas ?
          beq     lseled3        ;
          bra     lseledok       ;demande>fichier + deja le cas

lseled3 : move.l  #mseled2,-(a7) ;demande>fichier + avant rien
          bsr     laffi          ;
          add.l   #4,a7          ;
          clr.w   vnomf          ;init des buffers
          move.w  #$1000,vnomf0

          move.l  #vnomf0,-(a7)  ;obtention nom fichier
          bsr     lgets
          add.l   #4,a7
          move.l  #vnomf,-(a7)   ;et essai ouverture
          bsr     lopen
          add.l   #4,a7
          tst.w   d0
          bmi     lseled4

          move.l  #mseled5,-(a7) ;open ok,attention a ecraser
          bsr     laffi
          add.l   #4,a7
          bsr     lgeton
          tst.w   d0
          beq     lseledfin      ;si infirmer on ne fait rien

lseled4 : move.l  #vnomf,-(a7)   ;essai creation+open
          bsr     lcrea
          add.l   #4,a7
          tst.w   d0
          bpl     lseled5

          move.l  #mseled3,a0
          bsr     lerror
          bra     lseledfin

lseled5 : move.w  d0,vfd
          bra     lseledok

lseled6 : btst    #2,vmodedi     ;pas>fichier, existait avant ?
          beq     lseledok       ;  non ...
          move.w  vfd,-(a7)      ;oui on close
          bsr     lclos
          add.l   #2,a7
          tst.w   d0
          bpl     lseledok

          move.l  #mseled4,a0    ;echec fermeture
          bsr     lerror
          bra     lseledfin

lseledok : move.b v2modedi,vmodedi

lseledfin : rts


************************************************
* SOUS-PROGRAMME EXIT                          *
************************************************

lexit0 : clr.w    -(a7)         ;bye bye
         move.w   #$4c,-(a7)    ;  en fermant tout
         trap     #1

*********************************************
*  SOUS PROGRAMME  LOAD                     *
*********************************************

load0 : move.l  a1,-(a7)     ;
        bsr     ljmpsp       ;saute les blancs
        add.l   #4,a7        ;
        move.l  d0,a1
        tst.b   (a1)         ;fin commande ?
        bne     load1
        move.l  #mhelp,-(a7) ;oui erreur
        bsr     laffi        ;
        add.l   #4,a7
        bra     loadfin

load1 : move.l  a1,-(a7)     ;
        bsr     ljmpwo       ;saute le mot
        add.l   #4,a7        ;  et met null derriere
        move.l  d0,a5
        clr.b   (a5)

        move.l  a1,-(a7)     ;essai open
        bsr     lopen
        add.l   #4,a7
        tst.w   d0
        bpl     load2        ;si ok on passe
        move.l  #mload1,a0
        bsr     lerror       ;sinon affiche msg et code erreur
        bra     loadfin

load2 : move.l  d0,d7
        move.w  #2,-(a7)
        move.w  d7,-(a7)     ;recherche fdf
        clr.l   -(a7)        ;  pour calcul longueur
        move.w  #$42,-(a7)
        trap    #1
        add.l   #$a,a7
        move.l  d0,d6
        clr.w   -(a7)
        move.w  d7,-(a7)     ;replace en debut fichier
        clr.l   -(a7)        ;
        move.w  #$42,-(a7)
        trap    #1
        add.l   #$a,a7

        move.l  vhiprg,-(a7)
        move.l  d6,-(a7)
        move.w  d7,-(a7)     ;lecture du fichier
        move.w  #$3f,-(a7)   ;  buffer a #vhiprg, handle=d7, nb byte=d6
        trap    #1
        add.l   #$c,a7
        move.w  d7,-(a7)     ;puis fermeture fichier
        bsr     lclos
        add.l   #2,a7

        move.l  #mload2,a1
        add.l   #$c,a1
        move.l  vhiprg,d0
        bsr     lechl        ;affichage donnant
        move.b  #$20,(a1)    ;  adresse de chargement
        add.l   #$e,a1       ;  et longueur prg
        move.l  d6,d0
        bsr     lechl
        move.l  #mload2,-(a7)
        bsr     laffi
        add.l   #4,a7

        move.l  vhiprg,vdumpos1 ;valorisation des bornes
        move.l  vhiprg,vlispos1

loadfin : rts


***********************************************
* SOUS-PROGRAMME DE DESSASSEMBLAGE            *
***********************************************

llist0 : move.l  vlispos1,vlispos2
         add.l   #LISTPLUS,vlispos2 ;init variable borne
         move.l  #vbuff2,a5      ;
         move.b  #$a,(a5)+       ;
         move.b  #$d,(a5)+       ;envoi retour chariot
         clr.b   (a5)            ;  aux periph
         move.l  #vbuff2,a0      ;
         bsr     ledi            ;

         move.l  #LISTPLUS,-(a7) ;
         move.l  #vlispos1,-(a7) ;
         bsr     litborn         ;obtention des bornes sur la
         add.l   #8,a7           ;  ligne de cmde

         clr.l   -(a7)           ;
         move.w  #$20,-(a7)      ;
         trap    #1              ;passage en superviseur
         add.l   #6,a7           ;
         move.l  d0,vsavssp      ;sauve ptr ssp

llist1 : move.l  #vbuff1,a1      ;
         move.l  vlispos1,d0     ;affiche l'adresse en
         bsr     lechl           ;  traitement
         move.b  #$20,(a1)+      ;
         move.b  #$20,(a1)+      ;

         move.l  vlispos1,vdot   ;
         move.l  vlispos1,vsdot  ;init des variables
         add.l   #2,vsdot        ;

         bsr     linst           ;appel du programme de decodage

         move.b  #$a,(a1)+       ;
         move.b  #$d,(a1)+       ;terminaison de string a afficher
         clr.b   (a1)            ;

         move.l  #vbuff1,a0      ;affiche la ligne
         bsr     ledi            ;

         move.l  vsdot,d0        ;
         move.l  d0,vlispos1     ;boucle terminee ?
         cmp.l   vlispos2,d0     ;
         blt     llist1          ;non, on boucle

llist2 : move.l  vsavssp,-(a7)   ;
         move.w  #$20,-(a7)      ;passage utilisateur
         trap    #1              ;
         add.l   #6,a7           ;

         rts

***********************

linst  : move.l  vdot,a5       ;
         move.w  (a5),vinstr   ;init,vinstr le 1er mot a decoder
         move.l  #vopdtab,a5   ;

linst1 : move.w  (a5),d0       ;recherche dans la table
         and.w   vinstr,d0     ;  des mnemoniques
         cmp.w   $2(a5),d0     ;
         beq     linst2        ;

         add.l   #$e,a5        ;elt suivant de la table
         bra     linst1        ;

linst2 : move.l  a5,a0         ;on a trouve la mnemo
         add.l   #6,a0         ;  on la met dans le buffer
         bsr     lecs          ;
         move.b  #$20,(a1)+    ;

         move.w  $4(a5),d7     ;
         tst.w   d7            ;si code associe a mnemo = 0
         beq     linst3        ;  fini

         move.l  #vlinst1,a5   ;calcul de la redirection a
         ext.l   d7            ;  effectuer
         lsl.l   #2,d7         ;
         add.l   d7,a5         ;
         move.l  (a5),a5       ;effectue appel ss-prg adapte
         jsr     (a5)          ;

linst3 : rts

*************************************************

*****************************
* lnoin  cas a priori vide  *
* entree= neant             *
*****************************
lnoin : move.l  a0,-(a7)
        move.l  #mnoin,a0
        bsr     lecs
        move.l  (a7)+,a0
        rts

*****************************
* l1in                      *
*****************************
l1in  : move.l  d0,-(a7)
        move.w  vinstr,d6
        and.w   #$e00,d6
        move.l  #9,d7
        asr.w   d7,d6

        move.w  vinstr,d0
        btst    #$3,d0
        beq     l1in1

        and.w   #7,d0
        bsr     lecpari
        move.b  #$2c,(a1)+ ; ','
        move.w  d6,d0
        bsr     lecpari
        bra     l1in2

l1in1 : and.w   #7,d0
        bsr     lecdr
        move.b  #$2c,(a1)+ ; ','
        move.w  d6,d0
        bsr     lecdr

l1in2 : move.l  (a7)+,d0
        rts

********************************
* l2in                         *
********************************
l2in  : move.l  d0,-(a7)
        move.w  vinstr,d6
        and.w   #$e00,d6
        move.l  #9,d7
        asr.w   d7,d6

        move.w  vinstr,d0
        and.w   #$c0,d0
        cmp.w   #$c0,d0
        bne     l2in2

        move.l  #1,d7
        move.w  vinstr,d0
        and.w   #$1c0,d0
        cmp.w   #$1c0,d0
        bne     l2in1

        move.l  #2,d7

l2in1 : add.l   #8,d6
        bra     l2in3

l2in2 : move.l  #6,d7
        asr.w   d7,d0
        move.l  d0,d7

l2in3 : cmp.w   #7,d6
        bgt     l2in4

        btst    #0,vinstr
        bne     l2in5

l2in4 : move.w  d7,-(a7)
        move.w  vinstr,-(a7)
        and.w   #$3f,(a7)
        bsr     lecop
        add.l   #4,a7
        move.b  #$2c,(a1)+   ; ','
        move.w  d6,d0
        bsr     lecreg
        bra     l2in6

l2in5 : move.w  d6,d0
        bsr     lecreg
        move.b  #$2c,(a1)+   ; ','
        move.w  d7,-(a7)
        move.w  vinstr,-(a7)
        and.w   #$3f,(a7)
        bsr     lecop
        add.l   #4,a7

l2in6 : move.l  (a7)+,d0
        rts

***********************************
* l3in                            *
***********************************
l3in  : move.l  d0,-(a7)
        move.w  vinstr,d6
        and.w   #$c0,d6
        move.l  #6,d7
        asr.w   d7,d6

        move.l  d6,d0
        bsr     lecimm
        move.b  #$2c,(a1)+   ; ','

        move.w  vinstr,d0
        ext.l   d0
        move.l  #vl3in,a5
l3in1 : cmp.l   (a5),d0
        beq     l3in2
        tst.l   (a5)
        beq     l3in2
        add.l   #4,a5
        bra     l3in1

l3in2 : move.l  $1c(a5),a5
        jmp     (a5)

l3in3 : move.b  #$53,(a1)+   ; 'SR'
        move.b  #$52,(a1)+
        bra     l3infin

l3in4 : move.b  #$43,(a1)+
        move.b  #$43,(a1)+  ; 'CCR'
        move.b  #$52,(a1)+
        bra     l3infin

l3in5 : move.w  d6,-(a7)
        move.w  vinstr,-(a7)
        and.w   #$3f,(a7)
        bsr     lecop
        add.l   #4,a7

l3infin : move.l (a7)+,d0
          rts

*******************************
* l4in                        *
*******************************
l4in  : move.l  d0,-(a7)
        move.w  vinstr,d6
        and.w   #$e00,d6
        move.l  #9,d7
        asr.w   d7,d6

        tst.w   d6
        bne     l4in1
        move.w  #8,d6
l4in1 : move.b  #$23,(a1)+   ; '#$'
        move.b  #$24,(a1)+
        move.w  d6,d0
        bsr     lechb
        move.b  #$2c,(a1)+   ; ','
        move.w  #1,-(a7)
        move.w  vinstr,-(a7)
        and.w   #$3f,(a7)
        bsr     lecop
        add.l   #4,a7
        move.l  (a7)+,d0
        rts

****************************
* l5in                     *
****************************
l5in  : move.w  vinstr,d6
        and.w   #$600,d6

        tst.w   d6
        bne     l5in1
        move.b  #$53,(a1)+  ; 'SR,'
        move.b  #$52,(a1)+
        move.b  #$2c,(a1)+

l5in1 : cmp.w   #$200,d6
        bne     l5in2
        move.b  #$43,(a1)+
        move.b  #$43,(a1)+  ; 'CCR,'
        move.b  #$52,(a1)+
        move.b  #$2c,(a1)+

l5in2 : move.w  #1,-(a7)
        move.w  vinstr,-(a7)
        and.w   #$3f,(a7)
        bsr     lecop
        add.l   #4,a7

        cmp.w   #$400,d6
        bne     l5in3
        move.b  #$2c,(a1)+
        move.b  #$43,(a1)+
        move.b  #$43,(a1)+  ; ',CCR'
        move.b  #$52,(a1)+

l5in3 : cmp.w   #$600,d6
        bne     l5in4
        move.b  #$2c,(a1)+
        move.b  #$53,(a1)+  ; ',SR'
        move.b  #$52,(a1)+

l5in4 : rts

***************************
* l6in                    *
***************************
l6in  : move.l  d0,-(a7)
        move.w  vinstr,d6
        and.w   #$e00,d6
        move.l  #9,d7
        asr.w   d7,d6

        move.w  vinstr,d5
        btst    #$5,d5
        beq     l6in1

        move.l  d6,d0
        bsr     lecdr
        bra     l6in3

l6in1 : tst.w   d6
        bne     l6in2
        move.w  #8,d6
l6in2 : move.b  #$23,(a1)+   : '#'
        move.l  d6,d0
        bsr     lechb

l6in3 : move.b  #$2c,(a1)+   ; ','
        move.w  vinstr,d0
        and.w   #7,d0
        bsr     lecreg

        move.l  (a7)+,d0
        rts

*****************************
* l7in                      *
*****************************
l7in  : move.w  #1,-(a7)
        move.w  vinstr,-(a7)
        and.w   #$3f,(a7)
        bsr     lecop
        add.l   #4,a7
        rts

****************************
* l8in                     *
****************************
l8in  : move.l  d0,-(a7)
        move.w  vinstr,d6
        move.b  d6,d6
        ext.w   d6
        ext.l   d6

        tst.w   d6
        beq     l8in1

        move.l  vsdot,d0
        add.l   d6,d0
        bra     l8in2

l8in1 : move.l  vsdot,a5
        move.w  (a5),d0
        ext.l   d0
        add.l   a5,d0
        add.l   #2,vsdot

l8in2 : move.b  #$24,(a1)+ ; '$'
        bsr     lechl
        move.l  (a7)+,d0
        rts

***************************
* l9in                    *
***************************
l9in  : move.l  d0,-(a7)
        move.w  #1,-(a7)
        move.w  vinstr,-(a7)
        and.w   #$3f,(a7)
        bsr     lecop
        add.l   #4,a7
        move.b  #$2c,(a1)+   ; ','
        move.w  vinstr,d6
        and.w   #$800,d6
        move.l  #9,d7
        asr.w   d7,d6
        move.l  d6,d0
        bsr     lecdr
        move.l  (a7)+,d0
        rts

*****************************
* l10in                     *
*****************************
l10in  : move.l  d0,-(a7)
         move.w  vinstr,d6

         btst    #8,d6
         beq     l10in1

         and.w   #$e00,d6
         move.l  #9,d7
         asr.w   d7,d6
         move.l  d6,d0
         bsr     lecdr
         bra     l10in2

l10in1 : move.l  #1,d0
         bsr     lecimm

l10in2 : move.b  #$2c,(a1)+   ; ','
         move.w  #1,-(a7)
         move.w  vinstr,-(a7)
         and.w   #$3f,(a7)
         bsr     lecop
         add.l   #4,a7

         move.l  (a7)+,d0
         rts

*******************************
* l11in                       *
*******************************
l11in  : move.l  d0,-(a7)
         move.w  vinstr,d0
         and.w   #7,d0
         bsr     lecarip
         move.b  #$2c,(a1)+
         move.w  vinstr,d0
         and.w   #$e00,d0
         move.l  #9,d7
         asr.w   d7,d0
         bsr     lecarip
         move.l  (a7)+,d0
         rts

****************************
* l12in                    *
****************************
l12in  : move.l  d0,-(a7)
         move.l  vinstr,d0
         and.w   #7,d0
         bsr     lecdr
         move.b  #$2c,(a1)+
         move.l  vsdot,a5
         move.w  (a5),d0
         add.l   #2,vsdot
         ext.l   d0
         add.l   a5,d0
         bsr     lechl
         move.l  (a7)+,d0
         rts

****************************
* l13in                    *
****************************
l13in  : move.l  d0,-(a7)
         move.w  vinstr,d6
         and.w   #$e00,d6
         move.l  #9,d7
         asr.w   d7,d6
         move.w  vinstr,d5
         and.w   #$f8,d5
         move.w  vinstr,d4
         and.w   #7,d4

         cmp.w   #$48,d5
         bne     l13in1

         add.l   #8,d6
         add.l   #8,d4
         bra     l13in2

l13in1 : cmp.w   #$88,d5
         bne     l13in2
         add.l   #8,d4

l13in2 : move.l  d6,d0
         bsr     lecreg
         move.b  #$2c,(a1)+
         move.l  d4,d0
         bsr     lecreg

         move.l  (a7)+,d0
         rts

*****************************
* l14in                     *
*****************************
l14in  : move.l  d0,-(a7)
         move.w  vinstr,d0
         and.w   #7,d0
         bsr     lecdr
         move.l  (a7)+,d0
         rts

******************************
* l15in                      *
******************************
l15in  : move.l  d0,-(a7)
         move.w  vinstr,d0
         and.w   #7,d0
         bsr     lecar
         move.b  #$2c,(a1)+
         move.b  #$23,(a1)+   ; ',#$'
         move.b  #$14,(a1)+
         move.l  vsdot,a5
         move.w  (a5),d0
         add.l   #2,vsdot
         bsr     lechw
         move.l  (a7)+,d0
         rts

*******************************
* l16in                       *
*******************************
l16in  : move.l  d0,-(a7)
         move.w  vinstr,d6
         and.w   #$3000,d6

         tst.w   d6
         bne     l16in1
         bsr     lbadsiz
         bra     l16in4

l16in1 : cmp.w   #$1000,d6
         bne     l16in2
         clr.l   d7
         bra     l16in4

l16in2 : cmp.w   #$3000,d6
         bne     l16in3
         move.l  #1,d7
         bra     l16in4

l16in3 : move.l  #2,d7

l16in4 : move.w  d7,-(a7)
         move.w  vinstr,-(a7)
         and.w   #$3f,(a7)
         bsr     lecop
         add.l   #4,a7
         move.b  #$2c,(a1)+   ; ','

         move.w  vinstr,d6
         and.w  #$e00,d6
         move.l  #9,d0
         asr.w   d0,d6
         move.w  vinstr,d0
         and.w   #$1c0,d0
         asr.w   #3,d0

         or.w    d0,d6
         move.w  d7,-(a7)
         move.w  d6,-(a7)
         bsr     lecop
         add.l   #4,a7

         move.l  (a7)+,d0
         rts

***************************
* l17in                   *
***************************
l17in  : move.l  d0,-(a7)
         move.w  vinstr,d0
         and.w   #7,d0
         move.w  vinstr,d7
         btst    #$3,d7
         beq     l17in1

         move.b  #$55,(a1)+
         move.b  #$53,(a1)+   ; 'USP,'
         move.b  #$50,(a1)+
         move.b  #$2c,(a1)+
         bsr     lecar
         bra     l17in2

l17in1 : bsr     lecar
         move.b  #$2c,(a1)+
         move.b  #$55,(a1)+
         move.b  #$53,(a1)+   ; ',USP'
         move.b  #$50,(a1)+

l17in2 : move.l  (a7)+,d0
         rts

***************************
* l18in                   *
***************************
l18in  : move.l  d0,-(a7)
         move.l  vsdot,a5
         add.l   #2,vsdot
         move.w  (a5),d6

         btst    #2,vinstr
         beq     l18in1

         move.w  #1,-(a7)
         move.w  vinstr,-(a7)
         and.w   #$3f,(a7)
         bsr     lecop
         add.l   #4,a7
         move.b  #$2c,(a1)+  ; ','
         move.w  d6,-(a7)
         move.l  #vrmsk2,-(a7)
         bsr     leclisr
         add.l   #6,a7
         bra     l18in4

l18in1 : move.w  vinstr,d7
         and.w   #$38,d7
         cmp.w   #$20,d7
         bne     l18in2

         move.w  d6,-(a7)
         move.l  #vrmsk1,-(a7)
         bsr     leclisr
         add.l   #6,a7
         bra     l18in3

l18in2 : move.w  d6,-(a7)
         move.l  #vrmsk2,-(a7)
         bsr     leclisr
         add.l   #6,a7

l18in3 : move.b  #$2c,(a1)+  ; ','
         move.w  #1,-(a7)
         move.w  vinstr,-(a7)
         and.w   #$3f,(a7)
         bsr     lecop
         add.l   #4,a7

l18in4 : move.l  (a7)+,d0
         rts

*********************************
* l19in                         *
*********************************
l19in  : move.l  d0,-(a7)
         move.w  vinstr,d6
         and.w   #$180,d6

         cmp.w   #$180,d6
         bne     l19in1
         move.w  vinstr,d0
         and.w   #$e00,d0
         move.l  #9,d7
         asr.w   d7,d0
         bsr     lecreg
         move.b  #$2c,(a1)+  ; ','

l19in1 : move.l  vsdot,a5
         move.w  (a5),d0
         add.l   #2,vsdot
         bsr     lechw
         move.w  vinstr,d0
         and.w   #7,d0
         bsr     lecari

         cmp.w   #$100,d6
         bne     l19in2
         move.b  #$2c,(a1)+  ; ','
         move.w  vinstr,d0
         and.w   #$e00,d0
         move.l  #9,d7
         asr.w   d7,d0
         bsr     lecreg

l19in2 : move.l  (a7)+,d0
         rts

*****************************
* l20in                     *
*****************************
l20in  : move.l  d0,-(a7)
         move.b  #$23,(a1)+  ; '#$'
         move.b  #$24,(a1)+
         move.w  vinstr,d0
         and.w   #$ff,d0
         bsr     lechb
         move.b  #$2c,(a1)+  ; ','
         move.w  vinstr,d0
         and.w   #$e00,d0
         move.l  #9,d7
         asr.w   d7,d0
         bsr     lecreg

         move.l  (a7)+,d0
         rts

****************************
* l21in                    *
****************************
l21in  : move.l  d0,-(a7)
         move.l  #1,d0
         bsr     lecimm
         move.l  (a7)+,d0
         rts

***************************
* l22in                   *
***************************
l22in  : move.l  d0,-(a7)
         move.w  vinstr,d0
         and.w   #$f,d0
         bsr     lecreg
         move.l  (a7)+,d0
         rts

****************************
* l23in                    *
****************************
l23in  : move.l  d0,-(a7)
         move.b  #$23,(a1)+  ; '#$'
         move.b  #$24,(a1)+
         move.w  vinstr,d0
         and.w   #$f,d0
         bsr     lechb
         move.l  (a7)+,d0
         rts

**************************
* l24in                  *
**************************
l24in  : move.l  d0,-(a7)
         move.l  vsdot,a5
         move.w  (a5),d6
         add.l   #2,vsdot
         and.w   #$f000,d6
         move.l  #9,d7
         asr.w   d7,d6
         move.w  (a5),d7
         and.w   #$fff,d7

         move.w  vinstr,d5
         btst    #0,d5
         beq     l24in1
         move.l  d6,d0
         bsr     lecreg

l24in1 : cmp.w   #0,d7
         bne     l24in2
         move.b  #$53,(a1)+
         move.b  #$46,(a1)+  ; 'SFC'
         move.b  #$43,(a1)+
         bra     l24in6

l24in2 : cmp.w  #1,d7
         bne    l24in3
         move.b  #$44,(a1)+
         move.b  #$46,(a1)+  ; 'DFC'
         move.b  #$43,(a1)+
         bra     l24in6

l24in3 : cmp.w   #$800,d7
         bne     l24in4
         move.b  #$55,(a1)+
         move.b  #$53,(a1)+  ; 'USP'
         move.b  #$50,(a1)+
         bra     l24in6

l24in4 : cmp.w   #$801,d7
         bne     l24in5
         move.b  #$56,(a1)+
         move.b  #$42,(a1)+  ; 'VBR'
         move.b  #$52,(a1)+
         bra     l24in6

l24in5 : move.l  #ml24in,a0
         bsr     lecs

l24in6 : btst    #0,d5
         bne     l24in7
         move.b  #$2c,(a1)+  ; ','
         move.l  d6,d0
         bsr     lecreg

l24in7 : move.l  (a7)+,d0
         rts

**************************
* l25in                  *
**************************
l25in  : move.l  d0,-(a7)
         move.w  vinstr,d7
         and.w   #$c0,d7
         move.l  vsdot,a5
         move.w  (a5),d6
         add.l   #2,vsdot
         and.w   #$f000,d6
         move.l  #$c,d0
         asr.w   d0,d6
         and.w   #$f,d6

         move.w  (a5),d5
         btst    #$b,d5
         beq     l25in1
         move.l  d6,d0
         bsr     lecreg
         move.b  #$2c,(a1)+

l25in1 : move.w  d7,-(a7)
         move.w  vinstr,-(a7)
         and.w   #$3f,(a7)
         bsr     lecop
         add.l   #4,a7

         btst    #3,vinstr
         bne     l25in2
         move.b  #$2c,(a1)+
         move.l  d6,d0
         bsr     lecreg

l25in2 : move.l  (a7)+,d0
         rts





****************************************************
*  SS PROGRAMMES LOCAUX                            *
****************************************************

***********************************
* lerror : affiche une erreur     *
* entree= a0=ptr msg erreur       *
*         d0=code erreur          *
***********************************
lerror : move.l  a0,-(a7)
         bsr     laffi     ;affiche le msg
         add.l   #4,a7
         move.w  d0,-(a7)
         bsr     laffii    ;et le code erreur
         add.l   #2,a7
         rts



************************************
* lith = lit un nb hexa dans un    *
*        tampon                    *
* entree= a1 pointe le tampon      *
* sortie= d0 le resultat decimal   *
************************************
lith  : move.l  a5,-(a7)   ;
        move.l  a1,-(a7)   ;a1 pointe carcour
        bsr     ljmpsp     ;saute les blancs
        add.l   #4,a7      ;
        move.l  d0,a1      ;pointe le 1er caractere non blanc

        tst.b   (a1)       ;
        beq     lith1      ;pointe la fin du buffer ?
        cmp.b   #RC,(a1)   ;  oui, on sort avec d5<0
        beq     lith1      ;

        move.l  a1,-(a7)   ;pointe 1er car de la chaine hexa
        bsr     ljmpwo     ;cherche la fin de l'hexa
        add.l   #4,a7      ;
        move.l  d0,a5      ;
        clr.b   (a5)       ;met null derrierre cette chaine

        move.l  a1,-(a7)   ;transforme hexa->decimal
        bsr     lhtoi      ;  dans d0
        add.l   #4,a7      ;
        and.l   #$fffffffe,d0 ;mis a even adress

        move.l  a5,a1      ;pointe le 1er car derriere
        add.l   #1,a1      ;la chaine traitee
        bra     lith2      ;

lith1 : move.l  #-1,d0     ;sortie sans nb hexa

lith2 : move.l (a7)+,a5
        rts


*************************************
* litborn = lecture dans une ligne  *
*       de saisie les valeurs de    *
*       debut et fin de travail     *
*                                   *
* entree= (pile.l) increment        *
*         (pile.l) 1ere+2eme borne  *
*         a1 pointe la chaine       *
* sortie= les bornes sont valorisees*
*************************************
litborn  : link    a6,#0
           movem.l d0/a5,-(a7)

           bsr     lith       ;lit le 1er nb
           tst.l   d0         ;nb trouve ?
           bmi     litbornfin ;  non bye

           move.l  $8(a6),a5
           move.l  d0,(a5)    ;oui on sauve dans la 1ere var
           add.l   $c(a6),d0  ;  et la 2eme
           move.l  d0,$4(a5)  ;

           bsr     lith       ;lit le 2eme nb
           tst.l   d0         ;nb trouve ?
           bmi     litbornfin ;  non bye

           move.l  $8(a6),a5
           cmp.l   (a5),d0    ;oui, nb plausible ?
           blt     litbornfin ;  non bye

           move.l  d0,$4(a5)  ;oui on valorise la 2eme var

litbornfin : movem.l (a7)+,d0/a5
             unlk    a6
             rts

************************************
* ledi = edition selon vmodedi     *
*        sur console ou imprimante *
*        ou fichier                *
* entree= a0 pointe la chaine      *
************************************
ledi  : movem.l d0-d1/a0-a1,-(a7)

        btst    #0,vmodedi   ;edition sur console ?
        beq     ledi1        ;  non on passe
        move.l  a0,-(a7)     ;
        bsr     laffi        ;appel ss-prg gal affichage ecran
        move.l  (a7)+,a0     ;recup du a0 initial

ledi1 : btst    #1,vmodedi   ;edition sur imprimante ?
        beq     ledi2        ;  non on passe
        move.l  a0,-(a7)     ;
        bsr     limpr        ;appel ss-prg gal adapte
        move.l  (a7)+,a0     ;recup du a0 initial

ledi2 : btst    #2,vmodedi   ;edition sur fichier ?
        beq     ledifin      ;
        move.l  a0,-(a7)     ;recherche le nb de byte de
        bsr     llens        ;  la chaine
        add.l   #4,a7
        tst.l   d0
        beq     ledifin      ;si longueur nullr bye bye
        move.l  a0,-(a7)     ;
        move.l  d0,-(a7)
        move.w  vfd,-(a7)    ;appel au systeme
        move.w  #$40,-(a7)   ;
        trap    #1
        add.l   #$c,a7

ledifin : movem.l (a7)+,d0-d1/a0-a1
          rts


***********************************
* lechl = ecriture dans buffer    *
*         d'un nb en hexa long    *
* entree= d0,le nb en question    *
***********************************
lechl  : move.l  a1,-(a7)
         move.w  #$20,-(a7)
         move.l  d0,-(a7)    ;appel de la routine generale
         bsr     litohf      ;  avec param appropries
         add.l   #$a,a7      ;
         add.l   #8,a1       ;fait progresser le pointeur de chaine
         rts

*********************************
* lechw  ecriture nb hexa mot   *
* entree= d0=nb                 *
*********************************
lechw  : move.l  a1,-(a7)
         move.w  #$10,-(a7)
         move.l  d0,-(a7)    ;appel routine generale
         bsr     litohf      ;  avec param adaptes
         add.l   #$a,a7      ;
         add.l   #4,a1       ;
         rts

********************************
* lechb  ecriture nb hexa byte *
* entree= d0=nb                *
********************************
lechb  : move.l  a1,-(a7)
         move.w  #$8,-(a7)
         move.l  d0,-(a7)    ;appel routine generale
         bsr     litohf      ;  avec param adaptes
         add.l   #$a,a7      ;
         add.l   #2,a1       ;
         rts

*******************************
* lecreg  ecrit. An/Dn        *
* entree= d0=num reg 0 a 15   *
*******************************
lecreg  : move.l  d0,-(a7)   ;
          cmp.w   #7,d0      ;si d0<=7 on saute
          ble     lecreg1    ;
          sub.w   #8,d0      ;ici d0>7 An
          bsr     lecar      ;
          bra     lecreg2    ;
lecreg1 : bsr     lecdr      ;ici d0<=7 Dn
lecreg2 : move.l  (a7)+,d0
          rts

******************************
* lecdr  ecrit. Dn           *
* entree= d0=num reg 0 a 7   *
******************************
lecdr : move.l  d0,-(a7)   ;
        move.b  #$44,(a1)+ ;affiche 'D'
        add.b   #$30,d0    ;
        move.b  d0,(a1)+   ;  puis n
        move.l  (a7)+,d0   ;
        rts

*****************************
* lecar  ecrit An           *
* entree= d0=num reg 0 a7   *
*****************************
lecar : move.l  d0,-(a7)   ;
        move.b  #$41,(a1)+ ;affiche 'A'
        add.b   #$30,d0    ;
        move.b  d0,(a1)+   ;  puis n
        move.l  (a7)+,d0   ;
        rts

*****************************
* lecdri ecrit '(Dn)'       *
* entree= d0=num reg  0 a 7 *
*****************************
lecdri : move.b  #$28,(a1)+ ;affiche '('
         bsr     lecdr      ;  puis 'Dn'
         move.b  #$29,(a1)+ ;  puis ')'
         rts

****************************
* lecari ecrit '(An)'      *
* entree= d0=num reg  0 a 7*
****************************
lecari : move.b  #$28,(a1)+ ;affiche '('
         bsr     lecar      ;  puis 'An'
         move.b  #$29,(a1)+ ;  puis ')'
         rts

****************************
* lecpari ecrit '-(An)'    *
* entree= d0=num reg 0 a 7 *
****************************
lecpari : move.b  #$2d,(a1)+ ;affiche '-'
          bsr     lecari     ;  puis '(An)'
          rts

****************************
* lecarip ecrit '(An)+'    *
* entree= d0=num reg 0 a 7 *
****************************
lecarip : bsr     lecari     ;affiche '(An)'
          move.b  #$2b,(a1)+ ;  puis '+'
          rts


**********************************
*  lecs = eciture d'une string   *
*         dans le tampon         *
* entree= a0 pointe la chaine    *
* sortie= le tampon(ptr a1) valor*
**********************************
lecs  : move.l  a0,-(a7)    ;
lecs1 : tst.b   (a0)        ;fin de chaine ?
        beq     lecsfin     ;

        move.b  (a0)+,(a1)+ ;traite carcour
        bra     lecs1       ;boucle sur carsuiv

lecsfin : move.l  (a7)+,a0  ;
          rts

**********************************
* lecdisp                        *
* entree= neant                  *
* sortie= $mot affiche           *
**********************************
lecdisp :movem.l d0/a5,-(a7) ;
         move.b  #$24,(a1)+  ;affiche '$'
         move.l  vsdot,a5    ;
         move.w  (a5),d0     ;
         add.l   #2,vsdot    ;affiche le mot
         bsr     lechw       ;
         movem.l (a7)+,d0/a5 ;
         rts

**********************************
* lbadsiz                        *
* entree= neant                  *
* sortie= msg erreur affiche     *
**********************************
lbadsiz : move.l  a0,-(a7)
          move.l  #mbadsiz,a0 ;affiche le msg
          bsr     lecs        ;  d'erreur
          move.l  (a7)+,a0    ;
          rts

**********************************
* lecimm  adresage immediat      *
* entree= d0=2 ou <>2            *
* sortie= affiche '#$mot'        *
**********************************
lecimm  : movem.l d0/a5,-(a7)
          move.l  vsdot,a5    ;
          move.b  #$23,(a1)+  ;affiche '#$'
          move.b  #$24,(a1)+  ;

          cmp.b   #2,d0       ;d0 = 2 ?
          bne     lecimm1     ;

          add.l   #4,vsdot    ;ici d0=2
          move.l  (a5),d0     ;  recup du long mot
          bsr     lechl       ;affiche le long mot
          bra     lecimm2     ;

lecimm1 : add.l   #2,vsdot    ;d0<>2
          move.w  (a5),d0     ;  recup du mot
          ext.l   d0          ;
          bsr     lechw       ;affiche le mot

lecimm2 : movem.l (a7)+,d0/a5 ;
          rts

**********************************
* lecind                         *
* entree= d0=num registre 0 a 16 *
* sortie=affiche                 *
**********************************
lecind  : movem.l d0/a5,-(a7)
          move.l  vsdot,a5    ;

          move.b  #$24,(a1)+  ;affiche '$1er byte'
          move.w  (a5),d0     ;
          add.l   #2,vsdot
          and.l   #$ff,d0
          bsr     lechb
          move.l  (a7),d0     ;restit d0 param initial

          move.b  #$28,(a1)+  ;affiche '('
          cmp.b   #$10,d0     ;
          bne     lecind1     ;
          move.b  #$50,(a1)+  ;  et 'PC' si d0=16
          move.b  #$43,(a1)+  ;
          bra     lecind2     ;
lecind1 : bsr     lecar       ;  et An sinon

lecind2 : move.b  #$2c,(a1)+  ;affiche ','
          move.w  (a5),d0     ;
          move.l  #$c,d7      ;affiche Rn
          asr.w   d7,d0
          and.w   #$f,d0
          bsr     lecreg

          move.w  (a5),d7
          btst    #$b,d7
          beq     lecind3     ;
          move.b  #$2e,(a1)+  ;plus si besoin '.l'
          move.b  #$6c,(a1)+  ;

lecind3 : move.b  #$29,(a1)+  ;affiche ')'
          movem.l (a7)+,d0/a5 ;
          rts

********************************
* leclisr  ecrit  Rn-Rn/Rn-Rn  *
* entree= (pile.w)             *
*         (pile.l)             *
********************************
leclisr  : link    a6,#0
           move.l  d0,-(a7)
           movem.l d5-d7/a5,-(a7)

           move.l  $8(a6),a5
           move.w  #-1,d6
           clr.w   d7

leclisr1 : move.w  $c(a6),d5
           and.w   (a5)+,d5
           tst.w   d5
           beq     leclisr4

           tst.w   d6
           bne     leclisr2
           move.b  #$2f,(a1)+ ; '/'

leclisr2 : cmp.w   #1,d6
           beq     leclisr3
           move.w  d7,d0
           bsr     lecreg
           move.b  #$2d,(a1)+ ; '-'

leclisr3 : move.w  #1,d6
           bra     leclisr5

leclisr4 : cmp.w   #1,d6
           bne     leclisr5
           move.w  d7,d0
           sub.w   #1,d0
           bsr     lecreg
           clr.w   d6

leclisr5 : add.w   #1,d7
           cmp.w   #$f,d7
           ble     leclisr1

           cmp.w   #1,d6
           bne     leclisr6
           move.w  #$f,d0
           bsr     lecreg

leclisr6 : movem.l (a7)+,d5-d7/a5
           move.l  (a7)+,d0
           unlk    a6
           rts


************************************
* lecop  ecriture operande         *
* entree= (pile.w)                 *
*         (pile.w) instruc codee   *
************************************
lecop   : link    a6,#0
          movem.l d0/a0,-(a7)
          movem.l d6-d7/a5,-(a7)

          move.w  $8(a6),d7
          and.w   #$38,d7
          asr.w   #3,d7
          move.w  $8(a6),d0
          and.w   #7,d0

          move.l  #vlecop1,a5
          lsl.w   #2,d7
          ext.l   d7
          add.l   d7,a5
          move.l  (a5),a5
          jmp     (a5)

lecop1  : bsr     lecdr
          bra     lecopfin
lecop2  : bsr     lecar
          bra     lecopfin
lecop3  : bsr     lecari
          bra     lecopfin
lecop4  : bsr     lecarip
          bra     lecopfin
lecop5  : bsr     lecpari
          bra     lecopfin
lecop6  : bsr     lecdisp
          bsr     lecari
          bra     lecopfin
lecop7  : bsr     lecind
          bra     lecopfin

lecop8  : move.l  #vlecop2,a5
          lsl.w   #2,d0
          ext.l   d0
          add.l   d0,a5
          clr.l   d0
          move.l  (a5),a5
          jmp     (a5)

lecop9  : move.l  vsdot,a5
          move.w  (a5),d6
          add.l   #2,vsdot
          ext.l   d6
          move.l  d6,d7
          and.l   #$ffff8000,d6
          beq     lecop9a
          or.l    #$ffff0000,d7
lecop9a : move.l  d7,d0
          bsr     lechl
          bra     lecopfin

lecop10 : move.l  vsdot,a5
          move.l  (a5),d0
          add.l   #4,vsdot
          move.b  #$24,(a1)+  ; '$'
          bsr     lechl
          bra     lecopfin

lecop11 : bsr     lecdisp
          move.l  #mlecop,a0
          bsr     lecs
          bra     lecopfin

lecop12 : move.b  #$10,d0
          bsr     lecind
          bra     lecopfin

lecop13 : move.w  $a(a6),d0
          bsr     lecimm

lecopfin : movem.l (a7)+,d6-d7/a5
           movem.l (a7)+,d0/a0   
           unlk    a6
           rts



************************* DATA SUITE ET FIN ******************
.data
.even

vopdtab  :
  dc.w $ffff,$023c,$0003
  dc.b 'andi.b ',0
  dc.w $ffff,$027c,$0003
  dc.b 'andi.w ',0
  dc.w $ffff,$0a3c,$0003
  dc.b 'eori.b ',0
  dc.w $ffff,$0a7c,$0003
  dc.b 'eori.w ',0
  dc.w $ffff,$4afa,$0000
  dc.b 'illegal',0
  dc.w $ffff,$4afb,$0000
  dc.b 'illegal',0
  dc.w $ffff,$4afc,$0000
  dc.b 'illegal',0
  dc.w $ffff,$4e71,$0000
  dc.b 'nop    ',0
  dc.w $ffff,$0003c,$0003
  dc.b 'ori.b  ',0
  dc.w $ffff,$007c,$0003
  dc.b 'ori.w  ',0
  dc.w $ffff,$4e70,$0000
  dc.b 'reset  ',0
  dc.w $ffff,$4e74,$0015
  dc.b 'rtd    ',0
  dc.w $ffff,$4e73,$0000
  dc.b 'rte    ',0

  dc.w $ffff,$4e77,$0000
  dc.b 'rtr    ',0
  dc.w $ffff,$4e75,$0000
  dc.b 'rts    ',0
  dc.w $ffff,$4e72,$0015
  dc.b 'stop   ',0
  dc.w $ffff,$4e76,$0000
  dc.b 'trapv  ',0
  dc.w $fffe,$4e7a,$0018
  dc.b 'movec  ',0
  dc.w $fff8,$50c8,$000c
  dc.b 'dbt    ',0
  dc.w $fff8,$51c8,$000c
  dc.b 'dbf    ',0
  dc.w $fff8,$52c8,$000c
  dc.b 'dbhi   ',0
  dc.w $fff8,$53c8,$000c
  dc.b 'dbls   ',0
  dc.w $fff8,$54c8,$000c
  dc.b 'dbcc   ',0
  dc.w $fff8,$55c8,$000c
  dc.b 'dbcs   ',0
  dc.w $fff8,$56c8,$000c
  dc.b 'dbne   ',0
  dc.w $fff8,$57c8,$000c
  dc.b 'dbeq   ',0
  dc.w $fff8,$58c8,$000c
  dc.b 'dbvc   ',0
  dc.w $fff8,$59c8,$000c
  dc.b 'dbvs   ',0
  dc.w $fff8,$5ac8,$000c
  dc.b 'dbpl   ',0

  dc.w $fff8,$5bc8,$000c
  dc.b 'dbmi   ',0
  dc.w $fff8,$5cc8,$000c
  dc.b 'dbge   ',0
  dc.w $fff8,$5dc8,$000c
  dc.b 'dblt   ',0
  dc.w $fff8,$5ec8,$000c
  dc.b 'dbgt   ',0
  dc.w $fff8,$5fc8,$000c
  dc.b 'dble   ',0
  dc.w $fff8,$4880,$000e
  dc.b 'ext.w  ',0
  dc.w $fff8,$48c0,$000e
  dc.b 'ext.l  ',0
  dc.w $fff8,$4e50,$000f
  dc.b 'link   ',0
  dc.w $fff8,$4e60,$0011
  dc.b 'move.l ',0
  dc.w $fff8,$4e68,$0011
  dc.b 'move.l ',0
  dc.w $fff8,$4840,$0016
  dc.b 'swap   ',0
  dc.w $fff8,$4e58,$0016
  dc.b 'unlk   ',0
  dc.w $fff0,$4e40,$0017
  dc.b 'trap   ',0
  dc.w $ffc0,$0600,$0003
  dc.b 'addi.b ',0
  dc.w $ffc0,$0640,$0003
  dc.b 'addi.w ',0
  dc.w $ffc0,$0680,$0003
  dc.b 'addi.l ',0

  dc.w $ffc0,$0200,$0003
  dc.b 'andi.b ',0
  dc.w $ffc0,$0240,$0003
  dc.b 'andi.w ',0
  dc.w $ffc0,$0280,$0003
  dc.b 'andi.l ',0
  dc.w $ffc0,$e1c0,$0007
  dc.b 'asl    ',0
  dc.w $ffc0,$e0c0,$0007
  dc.b 'asr    ',0
  dc.w $ffc0,$0840,$000a
  dc.b 'bchg   ',0
  dc.w $ffc0,$0880,$000a
  dc.b 'bclr   ',0
  dc.w $ffc0,$08c0,$000a
  dc.b 'bset   ',0
  dc.w $ffc0,$0800,$000a
  dc.b 'btst   ',0
  dc.w $ffc0,$4200,$0007
  dc.b 'clr.b  ',0
  dc.w $ffc0,$4240,$0007
  dc.b 'clr.w  ',0
  dc.w $ffc0,$4280,$0007
  dc.b 'clr.l  ',0
  dc.w $ffc0,$0c00,$0003
  dc.b 'cmpi.b ',0
  dc.w $ffc0,$0c40,$0003
  dc.b 'cmpi.w ',0
  dc.w $ffc0,$0c80,$0003
  dc.b 'cmpi.l ',0
  dc.w $ffc0,$0a00,$0003
  dc.b 'eori.b ',0

  dc.w $ffc0,$0a40,$0003
  dc.b 'eori.w ',0
  dc.w $ffc0,$0a80,$0003
  dc.b 'eori.l ',0
  dc.w $ffc0,$4ec0,$0007
  dc.b 'jmp    ',0
  dc.w $ffc0,$4e80,$0007
  dc.b 'jsr    ',0
  dc.w $ffc0,$e3c0,$0007
  dc.b 'lsl    ',0
  dc.w $ffc0,$e2c0,$0007
  dc.b 'lsr    ',0
  dc.w $ffc0,$42c0,$0005
  dc.b 'move.w ',0
  dc.w $ffc0,$44c0,$0005
  dc.b 'move.w ',0
  dc.w $ffc0,$46c0,$0005
  dc.b 'move.w ',0
  dc.w $ffc0,$40c0,$0005
  dc.b 'move.w ',0
  dc.w $ffc0,$4c80,$0012
  dc.b 'movem.w',0
  dc.w $ffc0,$4cc0,$0012
  dc.b 'movem.l',0
  dc.w $ffc0,$4880,$0012
  dc.b 'movem.w',0
  dc.w $ffc0,$48c0,$0012
  dc.b 'movem.l',0
  dc.w $ffc0,$0e00,$0019
  dc.b 'moves.b',0
  dc.w $ffc0,$0e40,$0019
  dc.b 'moves.w',0

  dc.w $ffc0,$0e80,$0019
  dc.b 'moves.l',0
  dc.w $ffc0,$4800,$0007
  dc.b 'nbcd   ',0
  dc.w $ffc0,$4400,$0007
  dc.b 'neg.b  ',0
  dc.w $ffc0,$4440,$0007
  dc.b 'neg.w  ',0
  dc.w $ffc0,$4480,$0007
  dc.b 'neg.l  ',0
  dc.w $ffc0,$4000,$0007
  dc.b 'negx.b ',0
  dc.w $ffc0,$4040,$0007
  dc.b 'negx.w ',0
  dc.w $ffc0,$4080,$0007
  dc.b 'negx.l ',0
  dc.w $ffc0,$4600,$0007
  dc.b 'not.b  ',0
  dc.w $ffc0,$4640,$0007
  dc.b 'not.w  ',0
  dc.w $ffc0,$4680,$0007
  dc.b 'not.l  ',0
  dc.w $ffc0,$0000,$0003
  dc.b 'ori.b  ',0
  dc.w $ffc0,$0040,$0003
  dc.b 'ori.w  ',0
  dc.w $ffc0,$0080,$0003
  dc.b 'ori.l  ',0
  dc.w $ffc0,$4840,$0007
  dc.b 'pea    ',0
  dc.w $ffc0,$e7c0,$0007
  dc.b 'rol    ',0

  dc.w $ffc0,$e6c0,$0007
  dc.b 'ror    ',0
  dc.w $ffc0,$e5c0,$0007
  dc.b 'roxl   ',0
  dc.w $ffc0,$e4c0,$0007
  dc.b 'roxr   ',0
  dc.w $ffc0,$50c0,$0007
  dc.b 'st     ',0
  dc.w $ffc0,$51c0,$0007
  dc.b 'sf     ',0
  dc.w $ffc0,$52c0,$0007
  dc.b 'shi    ',0
  dc.w $ffc0,$53c0,$0007
  dc.b 'sls    ',0
  dc.w $ffc0,$54c0,$0007
  dc.b 'scc    ',0
  dc.w $ffc0,$55c0,$0007
  dc.b 'scs    ',0
  dc.w $ffc0,$56c0,$0007
  dc.b 'sne    ',0
  dc.w $ffc0,$57c0,$0007
  dc.b 'seq    ',0
  dc.w $ffc0,$58c0,$0007
  dc.b 'svc    ',0
  dc.w $ffc0,$59c0,$0007
  dc.b 'svs    ',0
  dc.w $ffc0,$5ac0,$0007
  dc.b 'spl    ',0
  dc.w $ffc0,$5bc0,$0007
  dc.b 'smi    ',0
  dc.w $ffc0,$5cc0,$0007
  dc.b 'sge    ',0

  dc.w $ffc0,$5dc0,$0007
  dc.b 'slt    ',0
  dc.w $ffc0,$5ec0,$0007
  dc.b 'sgt    ',0
  dc.w $ffc0,$5fc0,$0007
  dc.b 'sle    ',0
  dc.w $ffc0,$0400,$0003
  dc.b 'subi.b ',0
  dc.w $ffc0,$0440,$0003
  dc.b 'subi.w ',0
  dc.w $ffc0,$0480,$0003
  dc.b 'subi.l ',0
  dc.w $ffc0,$4ac0,$0007
  dc.b 'tas.b  ',0
  dc.w $ffc0,$4a00,$0007
  dc.b 'tst.b  ',0
  dc.w $ffc0,$4a40,$0007
  dc.b 'tst.w  ',0
  dc.w $ffc0,$4a80,$0007
  dc.b 'tst.l  ',0
  dc.w $ff00,$6200,$0008
  dc.b 'bhi    ',0
  dc.w $ff00,$6300,$0008
  dc.b 'bls    ',0
  dc.w $ff00,$6400,$0008
  dc.b 'bcc    ',0
  dc.w $ff00,$6500,$0008
  dc.b 'bcs    ',0
  dc.w $ff00,$6600,$0008
  dc.b 'bne    ',0
  dc.w $ff00,$6700,$0008
  dc.b 'beq    ',0
  dc.w $ff00,$6800,$0008
  dc.b 'bvc    ',0
  dc.w $ff00,$6900,$0008
  dc.b 'bvs    ',0
  dc.w $ff00,$6a00,$0008
  dc.b 'bpl    ',0
  dc.w $ff00,$6b00,$0008
  dc.b 'bmi    ',0
  dc.w $ff00,$6c00,$0008
  dc.b 'bge    ',0
  dc.w $ff00,$6d00,$0008
  dc.b 'blt    ',0
  dc.w $ff00,$6e00,$0008
  dc.b 'bgt    ',0
  dc.w $ff00,$6f00,$0008
  dc.b 'ble    ',0
  dc.w $ff00,$6000,$0008
  dc.b 'bra    ',0
  dc.w $ff00,$6100,$0008
  dc.b 'bsr    ',0

  dc.w $f1f8,$c100,$0001
  dc.b 'abcd   ',0
  dc.w $f1f8,$c108,$0001
  dc.b 'abcd   ',0
  dc.w $f1f8,$d100,$0001
  dc.b 'addx.b ',0
  dc.w $f1f8,$d140,$0001
  dc.b 'addx.w ',0
  dc.w $f1f8,$d180,$0001
  dc.b 'addx.l ',0
  dc.w $f1f8,$d108,$0001
  dc.b 'addx.b ',0
  dc.w $f1f8,$4148,$0001
  dc.b 'addx.w ',0
  dc.w $f1f8,$4188,$0001
  dc.b 'addx.l ',0
  dc.w $f1f8,$c140,$0001
  dc.b 'exg    ',0
  dc.w $f1f8,$c148,$0001
  dc.b 'exg    ',0
  dc.w $f1f8,$c188,$0001
  dc.b 'exg    ',0
  dc.w $f1f8,$e100,$0006
  dc.b 'asl.b  ',0
  dc.w $f1f8,$e140,$0006
  dc.b 'asl.w  ',0
  dc.w $f1f8,$e180,$0006
  dc.b 'asl.l  ',0
  dc.w $f1f8,$e120,$0006
  dc.b 'asl.b  ',0
  dc.w $f1f8,$e160,$0006
  dc.b 'asl.w  ',0
  dc.w $f1f8,$e1a0,$0006
  dc.b 'asl.l  ',0
  dc.w $f1f8,$e000,$0006
  dc.b 'asr.b  ',0
  dc.w $f1f8,$e040,$0006
  dc.b 'asr.w  ',0
  dc.w $f1f8,$e080,$0006
  dc.b 'asr.l  ',0
  dc.w $f1f8,$e020,$0006
  dc.b 'asr.b  ',0
  dc.w $f1f8,$e060,$0006
  dc.b 'asr.w  ',0
  dc.w $f1f8,$e0a0,$0006
  dc.b 'asr.l  ',0

  dc.w $f1f8,$b108,$000b
  dc.b 'cmpm.b ',0
  dc.w $f1f8,$b148,$000b
  dc.b 'cmpm.w ',0
  dc.w $f1f8,$b188,$000b
  dc.b 'cmpm.l ',0
  dc.w $f1f8,$e108,$0006
  dc.b 'lsl.b  ',0
  dc.w $f1f8,$e148,$0006
  dc.b 'lsl.w  ',0
  dc.w $f1f8,$e188,$0006
  dc.b 'lsl.l  ',0
  dc.w $f1f8,$e128,$0006
  dc.b 'lsl.b  ',0
  dc.w $f1f8,$e168,$0006
  dc.b 'lsl.w  ',0
  dc.w $f1f8,$e1a8,$0006
  dc.b 'lsl.l  ',0
  dc.w $f1f8,$e008,$0006
  dc.b 'asr.b  ',0
  dc.w $f1f8,$e048,$0006
  dc.b 'asr.w  ',0
  dc.w $f1f8,$e088,$0006
  dc.b 'asr.l  ',0
  dc.w $f1f8,$e028,$0006
  dc.b 'asr.b  ',0
  dc.w $f1f8,$e068,$0006
  dc.b 'asr.w  ',0
  dc.w $f1f8,$e0a8,$0006
  dc.b 'asr.l  ',0
  dc.w $f1f8,$0108,$0013
  dc.b 'movep.w',0
  dc.w $f1f8,$0148,$0013
  dc.b 'movep.l',0
  dc.w $f1f8,$0188,$0013
  dc.b 'movep.w',0
  dc.w $f1f8,$01c8,$0013
  dc.b 'movep.l',0
  dc.w $f1f8,$e118,$0006
  dc.b 'rol.b  ',0
  dc.w $f1f8,$e158,$0006
  dc.b 'rol.w  ',0
  dc.w $f1f8,$e198,$0006
  dc.b 'rol.l  ',0
  dc.w $f1f8,$e138,$0006
  dc.b 'rol.b  ',0
  dc.w $f1f8,$e178,$0006
  dc.b 'rol.w  ',0
  dc.w $f1f8,$e1b8,$0006
  dc.b 'rol.l  ',0
  dc.w $f1f8,$e018,$0006
  dc.b 'ror.b  ',0
  dc.w $f1f8,$e058,$0006
  dc.b 'ror.w  ',0
  dc.w $f1f8,$e098,$0006
  dc.b 'ror.l  ',0
  dc.w $f1f8,$e038,$0006
  dc.b 'ror.b  ',0
  dc.w $f1f8,$e078,$0006
  dc.b 'ror.w  ',0
  dc.w $f1f8,$e0b8,$0006
  dc.b 'ror.l  ',0

  dc.w $f1f8,$e110,$0006
  dc.b 'roxl.b ',0
  dc.w $f1f8,$e150,$0006
  dc.b 'roxl.w ',0
  dc.w $f1f8,$e190,$0006
  dc.b 'roxl.l ',0
  dc.w $f1f8,$e130,$0006
  dc.b 'roxl.b ',0
  dc.w $f1f8,$e170,$0006
  dc.b 'roxl.w ',0
  dc.w $f1f8,$e1b0,$0006
  dc.b 'roxl.l ',0
  dc.w $f1f8,$e010,$0006
  dc.b 'roxr.b ',0
  dc.w $f1f8,$e050,$0006
  dc.b 'roxr.w ',0
  dc.w $f1f8,$e090,$0006
  dc.b 'roxr.l ',0
  dc.w $f1f8,$e030,$0006
  dc.b 'roxr.b ',0
  dc.w $f1f8,$e070,$0006
  dc.b 'roxr.w ',0
  dc.w $f1f8,$e0b0,$0006
  dc.b 'roxr.l ',0

  dc.w $f1f8,$8100,$0001
  dc.b 'sbcd   ',0
  dc.w $f1f8,$8108,$0001
  dc.b 'sbcd   ',0
  dc.w $f1f8,$9100,$0002
  dc.b 'subx.b ',0
  dc.w $f1f8,$9140,$0002
  dc.b 'subx.w ',0
  dc.w $f1f8,$9180,$0002
  dc.b 'subx.l ',0
  dc.w $f1f8,$9108,$0002
  dc.b 'subx.b ',0
  dc.w $f1f8,$9148,$0002
  dc.b 'subx.w ',0
  dc.w $f1f8,$9188,$0002
  dc.b 'subx.l ',0
  dc.w $f1c0,$d000,$0002
  dc.b 'add.b  ',0
  dc.w $f1c0,$d040,$0002
  dc.b 'add.w  ',0
  dc.w $f1c0,$d080,$0002
  dc.b 'add.l  ',0
  dc.w $f1c0,$d100,$0002
  dc.b 'add.b  ',0
  dc.w $f1c0,$d140,$0002
  dc.b 'add.w  ',0
  dc.w $f1c0,$d180,$0002
  dc.b 'add.l  ',0

  dc.w $f1c0,$d0c0,$0002
  dc.b 'adda.w ',0
  dc.w $f1c0,$d1c0,$0002
  dc.b 'adda.l ',0
  dc.w $f1c0,$5000,$0004
  dc.b 'addq.b ',0
  dc.w $f1c0,$5040,$0004
  dc.b 'addq.w ',0
  dc.w $f1c0,$5080,$0004
  dc.b 'addq.l ',0
  dc.w $f1c0,$c000,$0002
  dc.b 'and.b  ',0
  dc.w $f1c0,$c040,$0002
  dc.b 'and.w  ',0
  dc.w $f1c0,$c080,$0002
  dc.b 'and.l  ',0
  dc.w $f1c0,$c100,$0002
  dc.b 'and.b  ',0
  dc.w $f1c0,$c140,$0002
  dc.b 'and.w  ',0
  dc.w $f1c0,$c180,$0002
  dc.b 'and.l  ',0
  dc.w $f1c0,$0140,$000a
  dc.b 'bchg   ',0
  dc.w $f1c0,$0180,$000a
  dc.b 'bclr   ',0
  dc.w $f1c0,$01c0,$000a
  dc.b 'bset   ',0
  dc.w $f1c0,$0100,$000a
  dc.b 'btst   ',0
  dc.w $f1c0,$4180,$0009
  dc.b 'chk    ',0
  dc.w $f1c0,$b000,$0002
  dc.b 'cmp.b  ',0
  dc.w $f1c0,$b040,$0002
  dc.b 'cmp.w  ',0
  dc.w $f1c0,$b080,$0002
  dc.b 'cmp.l  ',0
  dc.w $f1c0,$b0c0,$0002
  dc.b 'cmpa.w ',0
  dc.w $f1c0,$b1c0,$0002
  dc.b 'cmpa.l ',0
  dc.w $f1c0,$81c0,$0009
  dc.b 'divs   ',0
  dc.w $f1c0,$80c0,$0009
  dc.b 'divu   ',0
  dc.w $f1c0,$b100,$0002
  dc.b 'eor.b  ',0
  dc.w $f1c0,$b140,$0002
  dc.b 'eor.w  ',0
  dc.w $f1c0,$b180,$0002
  dc.b 'eor.l  ',0

  dc.w $f1c0,$41c0,$0002
  dc.b 'lea    ',0
  dc.w $f1c0,$3040,$0010
  dc.b 'movea.w',0
  dc.w $f1c0,$2040,$0010
  dc.b 'movea.l',0
  dc.w $f1c0,$c1c0,$0009
  dc.b 'muls   ',0
  dc.w $f1c0,$c0c0,$0009
  dc.b 'mulu   ',0
  dc.w $f1c0,$8000,$0002
  dc.b 'or.b   ',0
  dc.w $f1c0,$8040,$0002
  dc.b 'or.w   ',0
  dc.w $f1c0,$8080,$0002
  dc.b 'or.l   ',0
  dc.w $f1c0,$8100,$0002
  dc.b 'or.b   ',0
  dc.w $f1c0,$8140,$0002
  dc.b 'or.w   ',0
  dc.w $f1c0,$8180,$0002
  dc.b 'or.l   ',0

  dc.w $f1c0,$9000,$0002
  dc.b 'sub.b  ',0
  dc.w $f1c0,$9040,$0002
  dc.b 'sub.w  ',0
  dc.w $f1c0,$9080,$0002
  dc.b 'sub.l  ',0
  dc.w $f1c0,$9100,$0002
  dc.b 'sub.b  ',0
  dc.w $f1c0,$9140,$0002
  dc.b 'sub.w  ',0
  dc.w $f1c0,$9180,$0002
  dc.b 'sub.l  ',0
  dc.w $f1c0,$90c0,$0002
  dc.b 'suba.w ',0
  dc.w $f1c0,$91c0,$0002
  dc.b 'suba.l ',0
  dc.w $f1c0,$5100,$0004
  dc.b 'subq.b ',0
  dc.w $f1c0,$5140,$0004
  dc.b 'subq.w ',0
  dc.w $f1c0,$5180,$0004
  dc.b 'subq.l ',0

  dc.w $f100,$7000,$0014
  dc.b 'moveq.l',0
  dc.w $f000,$1000,$0010
  dc.b 'move.b ',0
  dc.w $f000,$3000,$0010
  dc.b 'move.w ',0
  dc.w $f000,$2000,$0010
  dc.b 'move.l ',0
  dc.w $0000,$0000,$0000
  dc.b '?_instr',0

* ODOSB *
.end




