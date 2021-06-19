**************************************************************************
***                                                                    ***
***         Routines disque et d‚compression huffman                   ***
***         ----------------------------------------                   ***
***             assembl‚ en BOOT_ST.O entre DEBUT et FIN               ***
***             plac‚ en memoire en $f8000 - 50000                     ***
***             charg‚ par AMAUP.S (assembleur link‚ au PASCAL)        ***
***             il contient les noms des fichiers en TABFIC:           ***
***             et le r‚pertoire courant en adnom:                     ***
***                                                                    ***
***             C'est ce programme qu'il faut utiliser pour            ***
***                 la version intermediaire (Huffman)                 ***
***                         avec les lieux                             ***
***                                                                    ***
**************************************************************************

NBLIEU:    EQU  33      ;reporter valeur dans MAUPASS

NBPOSTES:  EQU  388     ;nombre de sous-fichiers max dans un fichier

*** ASSEMBLE ET SAUVER DE DEBUT A FIN (BOOT_ST.O) ***
ORG        $2A0000-40000-10000
LOAD       $2A0000-40000-10000

;MAIN:
;            MOVE    #11,D0
;            MOVE    #0,D1
;            MOVE.L  #XBUFLOAD,A0
;            MOVE.L  #XBUFDEC,A1
;            JSR     XLOADOBJ
;            ILLEGAL
;XBUFLOAD:   BLK.L   15000
;XBUFDEC:    BLK.L   15000
DEBUT:                          ;debut de sauvegarde fichier image
           JMP     FCLOSE
           JMP     XMAKEKEY
           JMP     XCALCHUFF
           JMP     XHUFFMAN
           JMP     XBLOAD
           JMP     XREAD
           JMP     XWRITE
           JMP     XINDISK
           JMP     XTSTFACE
           JMP     XLOADOBJ
INTERUPT:
           RTE
XMAKEKEY:
           MOVEM.L D1-D7/A0-A6,-(A7)
           BSR     MAKEKEY
           MOVEM.L (A7)+,D1-D7/A0-A6
           MOVE    #-1,$3A
ADRTS:     RTS
XCALCHUFF:
           MOVEM.L D2-D7/A0-A6,-(A7)
           BSR     CALCHUFF
           MOVEM.L (A7)+,D2-D7/A0-A6
           RTS
XHUFFMAN:
           MOVEM.L D0-D7/A0-A6,-(A7)
           BSR     HUFFMAN
           MOVEM.L (A7)+,D0-D7/A0-A6
           MOVE    #-1,$3A
           RTS
XBLOAD:
;          MOVEM.L D0-D7/A0-A6,-(A7)
;          BSR     BLOAD
;          MOVEM.L (A7)+,D0-D7/A0-A6
;          MOVE    #-1,$3A
;          RTS
XREAD:
           MOVEM.L D0-D7/A0-A6,-(A7)
           BSR     READ
           MOVEM.L (A7)+,D0-D7/A0-A6
           MOVE    #-1,$3A
           RTS
XWRITE:
           MOVEM.L D0-D7/A0-A6,-(A7)
           BSR     WRITE
           MOVEM.L (A7)+,D0-D7/A0-A6
           MOVE    #-1,$3A
           RTS
XINDISK:
XTSTFACE:
XLOADOBJ:
           MOVEM.L D1-D7/A0-A6,-(A7)
           BSR     LOADOBJ
           MOVEM.L (A7)+,D1-D7/A0-A6
           RTS
   
;***************************************************************************
;**                                                                       **
;**                 ROUTINES DE CHARGEMENT                                **
;**                                                                       **
;***************************************************************************

nboctet:    dc.l    0
identif:    dc.w    -1
offset:     dc.l    0
dumoff:     dc.l    0
adrload:    dc.l    0
bufload:    dc.l    0
numfic:     dc.w   -1
num:        dc.w    0
bufdecomp:  dc.l    0

ADRSRC:     dc.l    0
ADRDEST:    dc.l    0
SYNC:       EQU     $07

REELTAIL: dc.l  0       ;taille du fichier avec ses $07
DEBDATA:  dc.l  0       ;debut des datas dans le buffer de piste
NBTRANS:  dc.l  0       ;nombre d'octets transferes

readfic:
        movem.l d0-d7/a0-a6,-(a7)

        CLR.W   -(A7)               ;FSEEK
        move    identif(pc),-(A7)
        move.l  offset(pc),-(A7)
        move    #$42,-(A7)
        trap    #1
        lea     10(A7),A7

        MOVE.L  ADRSRC(pc),-(A7)    ;FREAD
        move.l  nboctet(pc),-(A7)
        move.w  identif(pc),-(A7)
        move.w  #$3f,-(A7)
        trap    #1
        lea     12(A7),A7

        TST     flg_huff
        BNE.S   ffindec

        move.l  ADRSRC(pc),A0
        move.l  A0,A2
        MOVE.L  nboctet(pc),D1
decode:                         ;checksum et decodage fichier
        MOVE.B  (A0)+,D0
        CMPI.B  #SYNC,D0
        BNE.S   pas03
        SUBQ.L  #1,D1
        BLT.S   findecod
decode1:
        MOVE.B  (A0)+,D0
pas03:  MOVE.B  D0,(A2)+
        DBF     D1,decode
findecod:                       ;checksum sur fin de la piste
        MOVE.L  A0,D4
        SUB.L   ADRSRC(pc),D4
        MOVE.L  D4,REELTAIL     ;nombre d'octets reellement charges
ffindec:
        movem.l (a7)+,d0-d7/a0-a6

        RTS                     ;fin de lecture de fichier
SELLIEU:
         LEA     NOMLIEU(PC),A2
         MOVE    LENLIEU(PC),D1
         ADD     D1,A2
         SUB     #1000,D0
         DIVU    #10,D0
         ADD.B   #'0',D0
         MOVE.B  D0,(A2)+
         SWAP    D0
         ADD.B   #'0',D0
         MOVE.B  D0,(A2)+
         LEA     NOMLIEU(PC),A2
         BRA     SELBIS        ;ferme ancien fic et ouvre nouveau
SELFIC:                                 ;selection pour fichiers normaux
         LEA     TABFIC(pc),A2
         BRA.S   SEL0FIC
SEL1FIC: TST.B   (A2)+
         BNE.S   SEL1FIC
SEL0FIC: DBF     D0,SEL1FIC
SELBIS:  BSR     FCLOSE 
         LEA     xadnom(pc),A3
SEL2FIC: MOVE.B  (A2)+,(A3)+
         BNE.S   SEL2FIC
         MOVEM.L D0-D7/A0-A6,-(A7)
         CLR     -(A7)               ;FOPEN
         pea     adnom(pc)
         move    #$3d,-(A7)
         trap    #1
         addq    #8,A7
         move    D0,identif
         MOVEM.L (A7)+,D0-D7/A0-A6
         RTS
FCLOSE:
         TST     identif
         BLT.S   FFCLOSE
         MOVEM.L D0-D7/A0-A6,-(A7)
         MOVE.W  IDENTIF(pc),-(A7)       ;FCLOSE
         move.w  #$3e,-(A7)
         trap    #1
         addq    #4,A7
         MOVEM.L (A7)+,D0-D7/A0-A6
FFCLOSE: RTS

******** fin du module de lecture: readfic et routines associees *********

********************* Lecture fichier de sauvegarde **********************
*** D0 = numero de piste
*** D1 = premier secteur
*** D2 = nombre de secteurs
*** Retour D0 = adresse buffer de piste

READ:
    RTS

********************* Ecriture fichier de sauvegarde **********************
*** D0 = numero de piste
*** D2 = nombre de secteurs

WRITE:
    RTS

********** ouverture et lecture : positionne adnom offset etc... ********** 
*** D0.W = numero du fichier
*** D1.L = nombre d'octets a lire
*** A0   = adresse de chargement
*** Pas de retour

OPEN:
*           BSR         SELFIC
*           MOVE.L      D1,nboctet
*           CLR.L       offset
*           CLR.L       dumoff
*           MOVE.L      A0,ADRSRC
*           BSR         readfic
*           RTS

********** ouverture et lecture complete.. ********** 
*** D0.W = numero du fichier
*** A0   = adresse de chargement
*** Pas de retour

BLOAD:
*           BSR         SELFIC
*           MOVE.L      adnom(PC),D1
*           MOVE.L      4(A2,D0.W),nboctet
*           SUB.L       D1,nboctet
*           cmpi        #148,d0              ;fichier TLONG
*           bne         rototo
*           move.l      #3172,nboctet
rototo:
*           CLR.L       offset
*           CLR.L       dumoff
*           MOVE.L      A0,ADRSRC
*           BSR         readfic
*           RTS

******** fin du module de lecture: readfic et routines associees *********


***************************************************************************
***                                                                     ***
***                                                                     ***
***                     DECOMPRESSION HUFFMAN                           ***
***                                                                     ***
***                                                                     ***
***************************************************************************

;     ; S_LEN    taille source charge en memoire
;     ; ADRSRC   adresse fichier source
;     ; BUFDEST  adresse fichier dest

*********************** RECHERCHE DES CLES HUFFMAN *************************
*** D0.W = numero du fichier
*** A0   = adresse de chargement
*** Pas de retour

OLDFIC:     DC.W        -1

MAKEKEY:
            CMPI        #NBLIEU,D0
            BGE.S       NORMMKEY
            ADD         #1000,D0        ;indique fichier lieu
            MOVE        D0,OLDFIC
            BSR         SELLIEU
            BRA.S       LMAKEY
NORMMKEY:                               ;charge fichiers normaux
            SUB         #NBLIEU,D0
            CMP         OLDFIC(PC),D0   ;entete deja charge
            BEQ.S       ENDPACK
            MOVE        D0,OLDFIC
            BSR         SELFIC
LMAKEY:
            MOVE.L      #4,nboctet
            CLR.L       offset
            CLR.L       dumoff
            MOVE.L      A0,ADRSRC
            BSR         readfic
            MOVE.L      ADRSRC(pc),A4
            TST.B       (A4)
            BNE.S       MAKE0KEY

            MOVE        2(A4),HEAD_LEN
            MOVE        #1,flg_huff       ;pour indiquer pas huffman
            MOVE.L      #NBPOSTES*4,nboctet
            CLR.L       offset
            CLR.L       dumoff
            BSR         readfic

* Transfert sans decompression
 
            MOVE.L      ADRSRC(pc),A4
            ADDQ        #4,A4
            LEA         tab_len(PC),A0
            MOVE        #NBPOSTES-1,D0
TRSFERT:
            MOVE.L      (A4)+,(A0)+
            DBF         D0,TRSFERT

ENDPACK:
            RTS


MAKE0KEY:
            CLR         flg_huff          ;pour indiquer huffman

            MOVE.L      #1000,nboctet
            CLR.L       offset
            CLR.L       dumoff
            BSR         readfic
            MOVE.W      REELTAIL+2(pc),HEAD_LEN
            CLR.L       offset
            CLR.L       dumoff
            MOVE.L      A0,D0
            ADDQ        #1,D0
            BCLR        #0,D0
            MOVE.L      D0,ADRSRC
            MOVE.L      D0,A4

HUFFKEY:    ADDQ        #1,A4
            CLR.L       ROOT
            CLR.L       D2
            MOVE.B      (A4)+,HEADER      ; Header de compression.
            LEA         tab_len(PC),A0
HUFF1:      MOVE.L      (A4)+,(A0)+
            CMPI.L      #-1,-4(A0)
            BNE.S       HUFF1
            CLR.B       (A4)+             ; Vide octet d'alignement
            MOVE.B      (A4)+,D2          ; Information g‚n‚ralle.
            MOVE.B      D2,D1
            AND.B       #$07,D1           ; Root: plus petite longueur
            MOVE.B      D1,ROOT+1         ; de clef.
            SUBQ.B      #1,D1
            MOVE.B      D1,ROOT+3 
            LSR.B       #3,D2             ; NBBIT: nombre de bit pour coder
            MOVE.B      D2,D3             ; la longueur des clefs dans les
*                                         ; 256*NBBIT bits qui suivent.
            LSL.L       #5,D2             ; Nb. d'octets de la table KEY_INF.
            MOVEQ       #0,D0             ; I initial = 0.
            LEA         KEY_LEN1(PC),A1   ; Adr. des profondeurs de clefs.
            MOVEQ       #$20,D7           ; Indexe sur D6.
            MOVE.L      (A4)+,D6          ; Multi-KEY_INF.
BUILD_K0:   MOVEQ       #0,D4             ; Profondeur de la clef I.
            MOVE.B      D3,D2             ; Indexe sur D4.
BUILD_K1:   ROXL.L      #1,D6             ; Transfert d'un bit de D6 vers D4.
            ROXL.L      #1,D4
            SUBQ.B      #1,D7
            BNE         BUILD_K2
            MOVEQ       #$20,D7
            MOVE.L      (A4)+,D6
BUILD_K2:   SUBQ.B      #1,D2             ; Dernier bit pour fin de clef ?
            BNE         BUILD_K1          ; Non.
            TST.B       D4                ; Oui, clef donne une feuille ?
            BEQ         BUILD_K3          ; Non.
            ADD.B       D1,D4             ; Oui, LG+Root-1 -> LG.
BUILD_K3:   MOVE.B      D4,(A1)+          ; Stocke la profondeur de clef.
            ADDQ.B      #1,D0
            BNE         BUILD_K0

* Ici toutes les profondeurs de clef de chaque octet sont stock‚es dans
* la table KEY_LEN1. Il reste … les ranger par ordre croissant.

REORDER:    LEA         KEY_LEN0(PC),A0   ; Adr. des longueurs tri‚es.
            LEA         TBYTE(PC),A2      ; Adr. de v‚ritable valeur d'octet.
            LEA         KEY_LEN1(PC),A3   ; Adr. des longueurs non tri‚es.
            MOVEQ       #0,D5             ; Nombre de feuilles initiales.
            MOVEQ       #0,D2

REORDER0:   MOVE.L      A3,A1
            MOVEQ       #0,D0             ; d‚bute … l'octet 0.
REORDER1:   MOVE.B      (A1)+,D1
            BNE         REORDER2
            ADDQ.B      #1,D0
            BEQ         REORDEREND        ; Tout est nul, plus de feuille.
            BRA         REORDER1
REORDER2:   MOVE.B      D0,D2             ; Ici, D1 > 0.
            ADDQ.B      #1,D0
            BEQ         REORDER5
REORDER3:   MOVE.B      (A1)+,D3
            BEQ         REORDER4          ; D3=0, pas une feuille, on passe.
            CMP.B       D3,D1             ; D3>0, D1<= D3 ?
            BLT         REORDER4          ; Oui, on passe.
            MOVE.B      D3,D1             ; Non, D1=D3.
            MOVE.B      D0,D2             ; D2= nouvel octet min.
REORDER4:   ADDQ.B      #1,D0             ; Prochain octet ?
            BNE         REORDER3          ; Oui.
REORDER5:   MOVE.B      D1,(A0)+          ; Non, donc dans D1 minimum.
            MOVE.W      D2,(A2)+          ; D2 son octet correspondant.
            CLR.B       $0(A3,D2.W)       ; On ote l'octet de la liste.
            ADDQ.W      #1,D5             ; Nombre de feuille ++.
            BRA         REORDER0
            
REORDEREND:
* Ici tout est tri‚ en ordre croissant sauf les non-feuilles.

* On peut maintenant leur attribuer leur valeur de codage: leur CLEF.

MK_KEY:     MOVE.B      #-1,(A0)
            MOVE.B      -(A0),D2          ; Longueur maximale de clef.
            MOVE.W      D2,D7
            
            LEA         KEY(PC),A1        ; Adr. des clefs.
            MOVE.W      D5,D0
            LSL.W       #1,D0
            ADDA.L      D0,A1             ; Adr. de la clef la plus longue.
            MOVEQ       #0,D4             ; Clef initiale.

MK_KEY0:    MOVE.W      D4,-(A1)          ; On stocke la clef.
            ADDQ.W      #1,D4             ; Nouvelle clef.
            SUBQ.B      #1,D5
            BEQ         MK_KEY_END
            MOVE.B      -(A0),D3
MK_KEY1:    CMP.B       D3,D2             ; Meme longueur ?
            BEQ         MK_KEY0           ; Oui.
            SUBQ.B      #1,D2             ; Non, longueur de clef --.
            LSR.W       #1,D4             ; on racourcit la clef.
            BRA         MK_KEY1

MK_KEY_END:
            SUBQ        #4,A4
            MOVE.B      (A4)+,HEAD_LEN    ; longueur du header sur disque
            MOVE.B      (A4)+,HEAD_LEN+1
            MOVE.L      A4,ADRSRC         ; Else Debut data's compression
***** MODIF POUR OPTIMISATION
NOMEMKEY:
        LEA.L   NBR_LARG(PC),A3
        MOVEQ  #-1,D2
        MOVEQ  #16,D0
BMO1:   MOVE.L  D2,(A3)+
        DBF     D0,BMO1
        LEA.L   NBR_LARG(PC),A3
        SUB.W   ROOT+2(PC),D7
        LSL.W   #1,D7
        MOVE.W  #-2,0(A3,D7.W)
        LEA.L   KEY_LEN0(PC),A0
        MOVE.W  #255,D0
        MOVE.W  ROOT(PC),D1
        MOVEQ   #0,D2
BMOUN:  MOVE.B  (A0)+,D2
        BLT.S   FBMOUN
        SUB.B   D1,D2
        LSL.B   #1,D2
        ADDQ.W  #1,0(A3,D2.W)
        DBF     D0,BMOUN
FBMOUN: LEA.L   KEY(PC),A1
TRICLE: MOVE.W  (A3)+,D2
        BLT.S   FTRICLE
        BNE.S   PCLES
        LEA.L   2(A1),A1
        BRA.S   TRICLE
PCLES:  MOVE.W  D2,D3
        LSL.W   #1,D3
        MOVE.W  D3,-2(A3)
        ADD.W   D3,A1
        MOVE.L  A1,A2
        MOVE.W  512(A1),D6
        MOVE.W  (A1)+,D4
        SUBQ.W  #1,D2
BTCLE:  MOVE.W  -(A2),D5
        MOVE.W  D5,2(A2)
        MOVE.W  512(A2),514(A2)
        DBF     D2,BTCLE
        MOVE.W  D4,(A2)
        MOVE.W  D6,512(A2)
        BRA.S   TRICLE
FTRICLE:
        CMP.W   #-1,D2
        BEQ.S   TRICLE
;       CLR     D0              ;CLES CREES!!!!!!
;ERRMAKE:
        RTS

************ CALC OFFSET DISQUE, TAILLE SRC, TAILLE TJT *******************
*   Numero de chapitre dans D0
*   Retour dans D0 = nboctet, D1 = taille fic mem

CALCHUFF:
CALC0HUF:   LEA     tab_len(PC),A1
            LSL     #2,D0
            CLR.L   T_LEN
            CLR.L   nboctet
            MOVE.W  0(A1,D0.W),T_LEN+2
            MOVE.W  2(A1,D0.W),nboctet+2
            MOVE.L  dumoff(PC),A0
            SUBQ    #4,D0
            BLT.S   PRHUFF
            CLR.L   D1
PR1HUFF:    MOVE    2(A1,D0.W),D1
            ADD.L   D1,A0
            SUBQ    #4,D0
            BGE.S   PR1HUFF
PRHUFF:
PR2HUFF:    ADD.W   HEAD_LEN(PC),A0              ; offset du header et tab_len
            MOVE.L  A0,offset
            MOVE.L  nboctet(PC),D0               ;source
            MOVE.L  T_LEN(PC),D1                 ;tarjet
            RTS

************************ DECOMPRESSION HUFFMAN *****************************

* A0 adresse fichier source
* A1 adresse fichier dest
* Pas de retour

HUFFMAN:
            TST.L       T_LEN
            BNE.S       HUFFIC
            RTS
HUFFIC:
            TST         flg_huff
            BEQ.S       HUFFMAN0
            MOVE.L      A1,ADRSRC
            BSR         readfic
            RTS
HUFFMAN0:   
            MOVE.L      A1,ADRDEST
            MOVE.L      A0,ADRSRC
            BSR         readfic
HUFFMAN1:   MOVE.L      ADRSRC(PC),A0     ; Adr data's source
            LEA         KEY(PC),A6        ; Adr. des clefs encod‚es.
            LEA         NBR_LARG(PC),A5   ; Adr. des valeurs d‚cod‚es.
            LEA         TBYTE(PC),A4      ; Adr. des longueurs des clefs.
            MOVE.L      ADRDEST(PC),A1
            CLR.L       D4                ; Clef initiale, vide.
            MOVE.W      ROOT+2(PC),D6
            MOVE.W      D6,D3 
            MOVE.L      T_LEN(PC),D2      ; Nombre d'octets … d‚coder.
            SUBQ.W      #1,D2
UNPACK:     
* D‚but de la routine de d‚compression.

            MOVE.w      (A0)+,D4          ; Portion de code.
            MOVEQ       #$F,D5
            swap        d4
GROWTOROOT: 
* Augmenter la taille de la clef jusqu'… Root (Profondeur minimale)

GTOROOT0:   
            ROL.l      #1,D4
            DBF         D5,GTOROOT1       ; test nbr bit restant
            MOVEQ       #$F,D5            ; Il n'y en a plus … passer.
            swap        d4
            MOVE.w      (A0)+,D4          ; Nouvelle portion cod‚e.
            swap        d4
GTOROOT1:   DBF         D3,GTOROOT0
            
* Ici, D4 a la taille de la plus petite des clefs d‚finies.

            MOVE.L      A6,A2             ; Adr. tableau des long. de clefs.
            MOVE.L      A5,A3             ; Adr. tableau des clefs.
            MOVE.W      (A3)+,D3
SEARCHKEY: 
* Chercher dans le tableau des clefs les clefs de longueur D3.
* Puis trouver une clef correspondant au code dans D4.

SEARKEY0:   CMP.W       (A2)+,D4
            BLT.S       SEARRU1
            BEQ.S       KEY_FND
            SUB.W       (A2)+,D4
            ASL.W       #1,D4
            SUB.W       D4,A2
KEY_FND:    
* Ici une clef a ‚t‚ trouv‚e.
            MOVE.W      D6,D3
            MOVE.W      510(A2),D4        ; Octet d‚cod‚.
            CMP.B       HEADER(PC),D4     ; Est-ce un HEADER ?
            BEQ.S       SEARCH_N          ; Oui, trouver le nombre de r‚p‚t.
            MOVE.B      D4,(A1)+          ; Non, stocker D4 dans buffer tjt.
            CLR.B       D4
            DBF         D2,GROWTOROOT
            BRA         ENDPACK           ; Fin de d‚compression.

SEARRU1:    ADD.W       D3,A2
SEARKEY1:   
            ROL.l      #1,D4
            DBF         D5,SEARKEY2       ; test nbr bit restant
            MOVEQ       #$F,D5
            swap        d4
            MOVE.w      (A0)+,D4
            swap        d4
SEARKEY2:   MOVE.W      (A3)+,D3
            BGE.S       SEARKEY0
            CMP.W       #-1,D3
            BEQ.S       SEARKEY1

SEARCH_N:   
* On a trouv‚ HEADER recherche de N.

            CLR.B       D4
            
NTOROOT0:   
            ROL.l      #1,D4
            DBF         D5,NTOROOT1       ; test nbr bit restant
            MOVEQ       #$F,D5            ; Il n'y en a plus … passer.
            swap        d4
            MOVE.w      (A0)+,D4          ; Nouvelle portion cod‚e.
            swap        d4
NTOROOT1:   DBF         D3,NTOROOT0
            
* Ici, D4 a la taille de la plus petite des clefs d‚finies.

            MOVE.L      A6,A2             ; Adr. tableau des long. de clefs.
            MOVE.L      A5,A3             ; Adr. tableau des clefs.
            MOVE.W      (A3)+,D3
SEARCHNEY: 
* Chercher dans le tableau des clefs les clefs de longueur D3.
* Puis trouver une clef correspondant au code dans D4.

SEARNEY0:   CMP.W       (A2)+,D4
            BLT.S       SEARRU2
            BEQ.S       NEY_FND
            SUB.W       (A2)+,D4
            ASL.W       #1,D4
            SUB.W       D4,A2
NEY_FND:    
* Ici, on a trouv‚ le nombre de r‚p‚titions.
            MOVE.W      D6,D3
            MOVE.W      510(A2),D4        ; Nombre de r‚p‚tition(s).
            CMP.W       #$2,D4            ; < #$2 ?
            BGE.S       SEARBYTE          ; Oui, chercher l'octet … r‚p‚ter.
WRTHD:      MOVE.B      HEADER(PC),(A1)+  ; Non, HEADER … r‚p‚ter.
            SUBQ.L      #1,D2             ; Nombre d'octet d‚cod‚s ++.
            DBF         D4,WRTHD
            CLR.W       D4
            TST.L       D2                ; Fin de d‚compression ?
            BGE         GROWTOROOT        ; Autre recherche de clef.
            BRA         ENDPACK           ; Oui.
SEARRU2:    ADD.W       D3,A2
SEARNEY1:   ROL.l      #1,D4
            DBF         D5,SEARNEY2       ; test nbr bit restant
            MOVEQ       #$F,D5
            swap        d4
            MOVE.w      (A0)+,D4
            swap        d4
SEARNEY2:   MOVE.W      (A3)+,D3
            BGE.S       SEARNEY0
            CMP.W       #-1,D3
            BEQ.S       SEARNEY1
SEARBYTE: 
* Nombre de r‚p‚tition > 1, chercher l'octet … r‚p‚ter.

            MOVE.W      D4,D1             ; Nombre de r‚p‚titions sauvegard‚e.
            CLR.B       D4

BTOROOT0:   
            ROL.l      #1,D4
            DBF         D5,BTOROOT1       ; test nbr bit restant
            MOVEQ       #$F,D5            ; Il n'y en a plus … passer.
            swap        d4
            MOVE.w      (A0)+,D4          ; Nouvelle portion cod‚e.
            swap        d4
BTOROOT1:   DBF         D3,BTOROOT0
            
* Ici, D4 a la taille de la plus petite des clefs d‚finies.

            MOVE.L      A6,A2             ; Adr. tableau des long. de clefs.
            MOVE.L      A5,A3             ; Adr. tableau des clefs.
            MOVE.W      (A3)+,D3
SEARCHBEY: 
* Chercher dans le tableau des clefs les clefs de longueur D3.
* Puis trouver une clef correspondant au code dans D4.

SEARBEY0:   CMP.W       (A2)+,D4
            BLT.S       SEARRU3
            BEQ.S       BEY_FND
            SUB.W       (A2)+,D4
            ASL.W       #1,D4
            SUB.W       D4,A2
BEY_FND:    
* Ici, on a trouv‚ l'octet … r‚p‚ter.
            MOVE.W      D6,D3
            MOVE.W      510(A2),D4        ; Octet … r‚p‚ter.

WRTBY:      MOVE.B      D4,(A1)+
            SUBQ.L      #1,D2             ; Nombre d'octets d‚cod‚s.
            DBF         D1,WRTBY
            CLR.B       D4
            TST.L       D2                ; Tous les octets sont d‚cod‚s ?
            BGE         GROWTOROOT        ; Autre recherche.
            BRA         ENDPACK           ; Oui, fin de d‚compression.
SEARRU3:    ADD.W       D3,A2
SEARBEY1:   ROL.l      #1,D4
            DBF         D5,SEARBEY2       ; test nbr bit restant
            MOVEQ       #$F,D5
            swap        d4
            MOVE.w      (A0)+,D4
            swap        d4
SEARBEY2:   MOVE.W      (A3)+,D3
            BGE.S       SEARBEY0
            CMP.W       #-1,D3
            BEQ.S       SEARBEY1

****************************************************************************
***
***
***             D0 = NUMERO DE FICHIER
***             D1 = NUMERO D'OBJET
***             A0 = BUFFER DE CHARGEMENT
***             A1 = ADRESSE DE CHARGEMENT
***
***
****************************************************************************

LOADOBJ:
            MOVE    D1,num
            MOVE.L  A0,bufload
            MOVE.L  A1,adrload
            MOVE    D0,D1
            ADD     #30,D1
            CMP     numfic,D1                  ; 31 pour objet, 32 anim ...
            BEQ.S   noobkey                    ; oui pas de recherche de cle
            MOVE    D1,numfic
            MOVE.W  D1,D0       ;num
            MOVE.L  bufload,A0  ;ADRSRC
            JSR     MAKEKEY
noobkey:
            MOVE    num,D0
            JSR     CALCHUFF
            MOVE.L  bufload,A0
            MOVE.L  adrload,A1
            JSR     HUFFMAN                    ; charge et decomp chap. num
            RTS
adnom:
            DC.B    'E:\SECTE.ESS\'
xadnom:
            BLK.B   14
            EVEN
NOMLIEU:    DC.B     'LIEU00.SYN',0
LENLIEU:    DC.W     4

TABFIC:
            DC.B    'OBJETS.SYN',0
            DC.B    'TEXTES.SYN',0
            DC.B    'DOGRO.SYN',0
            DC.B    'PERSO.SYN',0
            DC.B    'GENE.SYN',0
            DC.B    'SECTASS.SYN',0
            DC.B    'SECTOSS.SYN',0
            DC.B    'GENER1.SYN',0
            DC.B    0
            DC.B    0
            DC.B    0
            DC.B    0
            DC.B    0
            DC.B    0
            DC.B    'PRGMUS.SYN',0
            DC.B    0
            DC.B    0
            DC.B    0
            DC.B    'DATGEN.SYN',0
            DC.B    'ECHGEN.SYN',0
            DC.B    'TSON.SYN',0
            DC.B    'GENERI.SYN',0
            DC.B    'PTRS.SYN',0
;DEMO                                   NUM 24
            DC.B    0                   ;FIC POUR RECHARGER PROT
;PIANO
            DC.B    'MORPIAN.SYN',0
;520
            DC.B    'EC520.SYN',0
            DC.B    'MU520.SYN',0
;1040
            DC.B    'ECDBF.SYN',0
            DC.B    'MUDBF.SYN',0
;MUSEK (POUR 520 DF)
            DC.B    'MUSEQ.SYN',0
;ECH GEN SF
            DC.B    'ECGENSF.SYN',0
            DC.B    'DATGENSF.SYN',0
    EVEN
FIN:        ;fin de sauvegarde du fichier image

flg_huff:    DC.W  0
tab_len:     BLK.L NBPOSTES*4
T_LEN:       DC.L  $00000000         ; Nombre d'octets du fichier tarjet.

HEAD_LEN:    DC.W  0                 ; Taille Header disque
HEADER:      DC.B  $00,0             ; Valeur de HEADER.
ROOT:        DC.W  $00               ; Plus petite longueur de clef.
ROOT1:       DC.W  $00               ; ROOT - 1

KEY:         BLK.W  $100             ; Clefs des octets (correspond au codage).
TBYTE:       BLK.W  $100             ; V‚ritable octet une fois d‚cod‚.
KEY_LEN0:    BLK.B  $100             ; Longueur des clefs stock‚es dans KEY.
KEY_LEN1:    BLK.B  $100
NBR_LARG:    BLK.W  34
DATA:
