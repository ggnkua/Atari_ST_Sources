****************************************************************************
*
*   COMPRESSION HUFFMAN AVEC SYNC
*
****************************************************************************

PREMLIEU:   EQU 0
MAXLIEU:    EQU 32

MAIN:
        MOVE.L  #CLNWDK,string      ; Ecran propre !!!!!
        BSR     PRINT
        MOVE    #PREMLIEU,NUMLIEU
BCLLIEU:
        MOVE.L  #ADNLIEU,A0
        MOVE.L  #LENLIEU,A1
        MOVEQ   #0,D2
        MOVE    NUMLIEU(PC),D2
        DIVU    #10,D2
        ADD.B   #'0',D2
        SWAP    D2
        ADD.B   #'0',D2
BCL1LIEU:
        MOVE    (A1)+,D0
        MOVE.L  (A0)+,D1
        BEQ.S   BCL0LIEU
        MOVE.L  D1,A2
        MOVE.B  D2,1(A2,D0.W)
        SWAP    D2
        MOVE.B  D2,0(A2,D0.W)
        SWAP    D2
        BRA.S   BCL1LIEU
BCL0LIEU:
        MOVE.L  #tjt_name,A2
        MOVE    lentjt,D0
        MOVE.B  D2,1(A2,D0.W)
        SWAP    D2
        MOVE.B  D2,0(A2,D0.W)

        CLR.W   -(A7)               ; Cree fichier dest
        MOVE.L  #tjt_name,-(A7)
        MOVE.W  #$3C,-(A7)
        TRAP    #1
        ADDQ    #8,A7
        MOVE.W  D0,tjt_hdl

        CLR.L   tjt_pos             ; Pointeur debut fichier disque
        CLR     nbr_len
        CLR.L   tot_len             ; Taille du fichier objet

        LEA     tab_len,A4          ; Init. table longueur
        MOVE.L  #buffer,adr_cur
        MOVE.L  adr_cur,src_adr
        MOVE.L  #OBJETS,ad_nom

;**************  Palettes et dessin principal ***************

DOBJET:
        CLR.W   cur_len
        BSR     COPYNOM
        CMPI.B  #'X',nom_fic
        BEQ.S   FOBJET
        CLR.L   src_dep
        CLR.L   src_len
        MOVE.L  #src_nom,src_name
        BSR     LOAD
        BSR     ALTEROCT
        BRA.S   DOBJET
FOBJET:
        MOVE.W  #-1,(A4)+           ; Fin table fichier
        BSR     COMPRESS

        MOVE.W  tjt_hdl,-(A7)       ; Ferme fichier dest
        MOVE.W  #$3E,-(A7)
        TRAP    #1
        ADDQ    #4,A7
        MOVE.L  #fin_cmp,string
        BSR     PRINT
FIN:
        MOVE.W  #7,-(A7)
        TRAP    #1
        ADDQ    #2,A7

        ADDQ    #1,NUMLIEU
        CMPI    #MAXLIEU,NUMLIEU
        BLE.L   BCLLIEU
        ILLEGAL

NUMLIEU:  dc.w   0

LOAD:
        MOVEM.L D0-D7/A0-A6,-(A7)
        CLR.W   -(A7)               ; Ouvre en lecture
        MOVE.L  src_name,-(A7)
        MOVE.W  #$3D,-(A7)
        TRAP    #1
        ADDQ    #8,A7
        MOVE.W  D0,src_hdl
        BGE.S   OKLOAD
        MOVE.L  #err_read,string
        BSR     PRINT
        MOVE.L  src_name,string
        BSR     PRINT
        CLR.L   src_len
        BRA     FINLOAD
OKLOAD:
        TST.L   src_len
        BNE.S   LSEEK
        MOVE.W  #2,-(A7)            ; Taille fichier
        MOVE.W  src_hdl,-(A7)
        CLR.L   -(A7)
        MOVE.W  #$42,-(A7)
        TRAP    #1
        LEA     10(A7),A7
        MOVE.L  D0,src_len

LSEEK:
        CLR.W   -(A7)               ; Et repositionne a l'offset demande
        MOVE.W  src_hdl,-(A7)
        MOVE.L  src_dep,-(A7)
        MOVE.W  #$42,-(A7)
        TRAP    #1
        LEA     10(A7),A7

        MOVE.L  adr_cur,-(A7)       ; Lecture a l'adresse pointee
        MOVE.L  src_len,-(A7)       ; par adr_cur
        MOVE.W  src_hdl,-(A7)
        MOVE.W  #$3F,-(A7)
        TRAP    #1
        LEA     12(A7),A7

        MOVE.W  src_hdl,-(A7)      ; Fermeture fichier
        MOVE.W  #$3E,-(A7)
        TRAP    #1
        ADDQ    #4,A7

        MOVE.L  src_len,D0          ; Adresse suivante
        ADD.L   D0,adr_cur          ; de chargement
        ADD.W   D0,cur_len          ; Taille de la portion homogene
FINLOAD:
        MOVEM.L (A7)+,D0-D7/A0-A6
        RTS

COPYNOM:
        MOVE.L  ad_nom,A1
        LEA     nom_fic,A2
COPN1:  MOVE.B  (A1)+,(A2)+
        BNE.S   COPN1
        MOVE.L  A1,ad_nom           ; Vers nom suivant
        RTS
TPRINTN:
        BSR     PRINT
        BSR     PRINTN
        RTS
PRINTN:  
        MOVEM.L D0-D7/A0-A6,-(A7)
        LEA     str_nb,A0
        MOVE.L  nombre,D0
        MOVE.L  #10000,D1
        CLR     D2
PT2N:
        DIVU    D1,D0
        BNE.S   PT1N
        TST     D2
        BNE.S   PT1N
        MOVE.B  #' ',(A0)+
        BRA.S   PT3N
PT1N:
        MOVEQ   #1,D2
        ADD.B   #'0',D0
        MOVE.B  D0,(A0)+
PT3N: 
        CLR     D0
        SWAP    D0
        DIVU    #10,D1
        BNE.S   PT2N
        TST     D2
        BNE.S   PT4N
        MOVE.B  #'0',-1(A0)
PT4N:   
        CLR.B   (A0)
        PEA     str_nb
        MOVE.W  #9,-(A7)
        TRAP    #1
        ADDQ    #6,A7
        MOVEM.L (A7)+,D0-D7/A0-A6
        RTS

PRINT:
        MOVEM.L D0-D7/A0-A6,-(A7)
        MOVE.L  string,-(A7)
        MOVE.W  #9,-(A7)
        TRAP    #1
        ADDQ    #6,A7
        MOVEM.L (A7)+,D0-D7/A0-A6
        RTS

****************** MODIFICATIONS  NOUVEAU COMPRESSEUR *********************

ALTEROCT:
        MOVEM.L D1/A1,-(A7)
        MOVE.W  cur_len,(A4)+       ; Taille portion avant compression
        ADDQ    #1,nbr_len
        TST.W   cur_len
        BEQ.S   ALTERFIN
        MOVE.L  adr_cur,A1
        MOVE.B  -1(A1),D1           ; Alterer le dernier octet lu.
        EOR.B   #1,D1
        MOVE.B  D1,0(A1)
        ADDQ.L  #2,adr_cur
        ADDQ    #2,-2(A4)
ALTERFIN:
        MOVEM.L (A7)+,D1/A1
        RTS

COMPRESS:
        MOVEM.L D0-D7/A0-A6,-(A7)

        MOVE.L  adr_cur,D0
        SUB.L   src_adr,D0
        MOVE.L  D0,src_len          ; Si 0 pas de sauvegarde

        MOVE.L  #strlen,string
        BSR     PRINT
        MOVE.L  src_len,nombre
        BSR     PRINTN
        TST.L   src_len
        BEQ.S   FCOMP
        BSR     HUFFMAN
        MOVE.L  tjt_len,D0
        ADD.L   D0,tot_len
        ADD.L   D0,tjt_pos
FCOMP:
        MOVEM.L (A7)+,D0-D7/A0-A6
        RTS
;   Parametres d'entree
    
;       src_len = D0 Longueur fichier source
;       src_adr = A0 Adresse du fichier source
;       
;   Parametres de retour

;       tjt_len:  Longueur du fichier compresse
    
;   PremiŠre lecture du fichier source pour former les tables d'occurences.
;   C'est le Pr‚lude … la phase 1.
HUFFMAN:
            MOVE.L      A7,savpile

            LEA         buffer,A0
            ADDA.L      B_LEN,A0
            ADDA.L      C_LEN,A0
            MOVE.L      A0,dest_cur       ; Adr buffer avec octets sync

            CLR.L       tjt_len           ; Taille portion compressee
            LEA.L       Occ1,A0           ; Clear la zone non initialis‚e.
            MOVE.W      #$600,D0
CLNNINIT:   CLR.L       (A0)+
            DBF         D0,CLNNINIT

            LEA         I_LEN,A0
            MOVE.L      #Occ1,D0
            SUB.L       #I_LEN,D0
            LSR.L       #2,D0

CLRVAR:     CLR.L       (A0)+
            DBF         D0,CLRVAR

            MOVE.L      src_adr,A0
            MOVE.L      src_len,D0

            LEA.L       OccG,A6
            LEA.L       OccN,A5
            LEA.L       OccM,A4
            LEA.L       Occ3,A3
            LEA.L       Occ2,A2
            LEA.L       Occ1,A1
            MOVEM.L     A1-A6,-(A7)
            MOVEQ       #0,D4             ; Nombre de HEADER.
PREP1:      MOVE.B      (A0)+,D3
            SUBQ.L      #1,D0
PREP2:      MOVEQ       #1,D1             ; Nombre de repetitions initiales.
            MOVE.B      D3,D2
PREP3:      MOVE.B      (A0)+,D3
            SUBQ.L      #1,D0
            CMP.B       D3,D2             ; Repetition ?
            BNE         PREP4             ; Non.
            ADDQ.W      #1,D1             ; Oui, incrementer le compteur de
                                          ; r‚p‚tition.
            CMP.W       #$101,D1          ; 257 r‚p‚titions ?
            BEQ         PREPV0            ; Oui, risque de d‚passement.
            TST.L       D0                ; Plus d'octet dans le buffer src ?
            BNE         PREP3             ; Non, autre r‚p‚tition ?
            
PREPV0:     ; Emettre une TRAME 'HEADER #$FF D2'
            AND.W       #$FF,D2           ; Incrementer OccM(D2).
            LSL.W       #2,D2
            ADD.L       #1,$00(A4,D2.W)

            ADD.L       #$FD,$00(A6,D2.W) ; Gain d'octets D2, OccG(D2) + 253.

            ADDQ.L      #1,D4             ; Incr‚menter le compteur de HEADER

            ADD.L       #1,$03FC(A5)      ; Incr‚menter le compteur OccN(255).

            TST.L       D0                ; Dernier octet du buffer source ?
            BNE         PREP2             ; Non, chercher autre r‚p‚tition.
            MOVEQ       #1,D1             ; Non, dernier traitement
            BRA         PREP4b            ; avant de quitter.
            
PREP4:      ; Il n'y a plus r‚p‚tition.
            CMP.W       #$03,D1
            BGT         MULTI_REP         ; + de 3 r‚p‚titions -> TRAME.
PREP4b:     SUBQ.L      #1,D1             ; - de 3 r‚p‚titions,
            LSL.W       #8,D1             ; Calcul du num‚ro de tableau
            AND.W       #$FF,D2           ; (Occ1 … Occ3) et la position dans
            ADD.W       D1,D2             ; le tableau.
            LSL.W       #2,D2
            ADD.L       #1,$00(A1,D2.W)   ; Incr‚menter Occ{D1}({D2})
            
PREP5:      TST.L       D0                ; Dernier octet du buffer source ?
            BNE         PREP2             ; Non, chercher autre r‚p‚tition.
            
            BRA         ENDPREP           ; Non, fin de traitement !!!!!!

MULTI_REP:  ; Envoyer une TRAME 'HEADER N-1 OCTET' (HEADER {D1-1} {D2})

            MOVE.L      D1,D5             ; Gain de D2 (OccG(D2)) + D1 - 3.
            SUBQ.L      #3,D5
            AND.W       #$FF,D2           
            LSL.W       #2,D2             
            ADD.L       D5,$00(A6,D2.W)   

            ADD.L       #1,$00(A4,D2.W)   ; Incr‚menter le compteur OccM(D2).

            SUBQ.W      #1,D1             ; Incr‚menter le compteur OccN(D1-1).
            AND.W       #$FF,D1
            LSL.W       #2,D1             
            ADD.L       #1,$00(A5,D1.W)   

            ADDQ.L      #1,D4             ; Incr‚menter le compteur de HEADER.
            TST.L       D0                ; Dernier octet du buffer source ?
            BNE         PREP2             ; Non, chercher autre r‚p‚tition.
ENDPREP:    MOVE.L      D4,HDNB
            
;     Les tables d'occurences sont form‚es, choisir HEADER (abr‚viation : H).
;     CritŠre de choix : Occ1(H) le plus petit possible.
;     Occ2(H)+Occ3(H)+OccM(H)+OccN(H) le plus grand pour tenter de descendre
;     le moins possible en profondeur dans l'arbre binaire.
;     (Nouvelle optimisation de l'arbre : le 23 Mars 1989)

HDSEARCH0:  MOVEQ       #0,D1                   ; Position dans les tables.
            MOVEQ       #0,D2                   ; Header initial = 0.
            MOVE.L      (A1),D4                 ; Occ1(Header initial).
            CLR.L       D5                      ; Occ2(H)+Occ3(H)+OccM(H)+OccN(H)
                                                ; Que nous appelerons OCC(H).
            CLR.L       D6                      ; Gain initial de la Phase_1.
HDSEARCH1:  MOVE.L      (A1)+,D3                ; Occ1(Octet).
            CMP.L       D3,D4                   ; Occ1(Octet)>Occ1(H) ?
            BLT         HDSEARCH3               ; Oui, prochain octet.
            BNE         HDSEARCH2               ; Non, Occ1(Octet) < Occ1(H)
            MOVE.L      (A2),D3                 ; Ici, Occ1(Octet) = Occ1(H)
            ADD.L       (A3),D3                 ; Alors: on teste des autres
            ADD.L       (A4),D3                 ; occurences.
            ADD.L       (A5),D3
            CMP.L       D3,D5                   ; OCC(Octet)<OCC(H)
            BLT         HDSEARCH3               ; Oui, prochain octet.
            MOVE.W      D1,D2                   ; Non, HEADER = Octet.
            MOVE.L      D3,D5                   ; OCC(H)=Occ(Octet).
            BRA         HDSEARCH3               ; Prochain octet.

HDSEARCH2:  MOVE.L      D1,D2                   ; Ici, Occ1(Octet) < Occ1(H)
            MOVE.L      D3,D4                   ; Occ1(H) = Occ1(Octet)
            MOVE.L      (A2),D5                 ; Nouveau OCC(H)
            ADD.L       (A3),D5
            ADD.L       (A4),D5
            ADD.L       (A5),D5

HDSEARCH3:  ADD.L       (A6)+,D6                ; Gain Phase_1 += OccG(Octet)
            ADDQ.L      #4,A2
            ADDQ.L      #4,A3
            ADDQ.L      #4,A4
            ADDQ.L      #4,A5
            ADDQ.B      #1,D1                   ; Nouvel Octet ?
            BNE         HDSEARCH1               ; Oui, on y va !
                                                ; Non, fin de la recherche.

;     D2 : num‚ro d'octet qui represente le HEADER.
;     D4 : Occ1(H). 
;     D6 : Gain total de la phase_1.

;     Efficience de la phase 1.

            MOVEM.L     (A7)+,A1-A6             ; RecupŠre les adresses des
                                                ; tables d'occurences.
            SUBA.L      #$00000018,A7           ; Re-sauvegarde des table.
            
            SUB.L       D4,D6                   ; Les octets perdus … cause
                                                ; des occurences simples de H
                                                ; annulent-ils l'effet de la
                                                ; compression ?
            BLT         NOPHASE_1               ; Oui, pas de phase_1 !
            MOVE.B      D2,HEADER               ; Non, Phase_1 efficiente.
            MOVE.L      D6,GAIN1                ; Sauvegarde Gain de Phase_1.
            MOVE.B      #1,PHASE_FLG

            ADD.L       D4,(A5)                 ; OccN(0)+=Occ1(H).
            LSL.W       #2,D2
            MOVE.L      $00(A2,D2.W),D3
            ADD.L       D3,D4                   ; Occ1(H)+Occ2(H)
            ADD.L       D3,$04(A5)              ; OccN(1)+=Occ2(H)
            MOVE.L      $00(A3,D2.W),D3
            ADD.L       D3,$8(A5)               ; OccN(2)+=Occ3(H)
            ADD.L       $00(A4,D2.W),D3
            LSL.L       #1,D3                   ; 2*(Occ3(H)+OccM(H))
            ADD.L       D3,D4
            ADD.L       $00(A5,D2.W),D4         ; Occ1(H)+Occ2(H)+OccN(H)+
                                                ; 2*(Occ3(H)+OccM(H))
            ADD.L       HDNB,D4                 ; + nombre de TRAME.
            CLR.L       $00(A2,D2.W)            ; Occ2(H)=0.
            CLR.L       $00(A3,D2.W)            ; Occ3(H)=0.
            CLR.L       $00(A4,D2.W)            ; OccM(H)=0.
            CLR.L       $00(A5,D2.W)            ; OccN(H)=0.
            CLR.L       $00(A6,D2.W)            ; OccG(H)=0.
            
            MOVE.L      $8(A1),D3               ; Occ1(2).
            MOVE.L      $8(A2),D5               ; Occ2(2).
            MOVE.L      $8(A3),D6               ; Occ3(2).
            ADD.L       D6,D5
            LSL.L       #1,D5                   ; 2*(Occ2(2)+Occ3(2)).
            ADD.L       D5,D3
            ADD.L       $8(A4),D3
            ADD.L       $8(A5),D3               ; Occ1(2)+2*(Occ2(2)+Occ3(2))
            MOVE.L      D3,$8(A1)               ; +OccM(2)+OccN(2).
            CLR.L       $8(A2)                  ; Occ2(2)=0.
            CLR.L       $8(A3)                  ; Occ3(2)=0.
            CLR.L       $8(A4)                  ; OccM(2)=0.
            CLR.L       $8(A5)                  ; OccN(2)=0.
            CLR.L       $8(A6)                  ; OccG(2)=0.
            
            CMP.L       D3,D4                   ; Occ1(2)>Occ1(H) ?
            BGT         OCCTP0                  ; Oui.
            ADD.L       D6,D3                   ; Occ1(2)+=Occ3(2).
            BRA         OCCTP1
OCCTP0:     ADD.L       D6,D4                   ; Occ1(H)+=Occ3(2).
OCCTP1:     MOVE.L      D4,D5
            ADD.L       D3,D5                   ; Occ1(H)+Occ1(2).
            MOVEQ       #$00,D0                 ; I initial = 0.
OCCTP2:     MOVE.L      (A2),D2
            LSL.L       #1,D2                   ; 2*Occ2(I)
            ADD.L       (A1),D2                 ; +Occ1(I)
            ADD.L       (A4),D2                 ; +OccM(I)
            ADD.L       (A5),D2                 ; +OccN(I)
            MOVE.L      (A3),D1
            ADD.L       D1,D2                   ; +Occ3(I)
            MOVE.L      D2,D7
            LSL.L       #1,D7                   ; 2*OccT(I)
            CMP.L       D7,D5                   ; 2*OccT(I)>OccT(H)+OccT(2) ?
            BGE         OCCTP3                  ; Non.
            CMP.B       HEADER,D0               ; I=HEADER ?
            BEQ         OCCTP4                  ; Oui.
            LSL.L       #1,D1
            ADD.L       D1,D2                   ; OccT(I)+=2*Occ3(I).
            BRA         OCCTP4
OCCTP3:     ADD.L       D1,D4                   ; OccT(H)+=Occ3(I).
            ADD.L       D1,D3                   ; OccT(2)+=Occ3(I).
            LSL.L       #1,D1
            ADD.L       D1,D5                   ; OccT(H)+OccT(2)+=2*Occ3(I).

OCCTP4:     MOVE.L      D2,(A1)+                ; OccT(I).
            CLR.L       (A2)+                   ; Occ2(I)=0.
            CLR.L       (A3)+                   ; Occ3(I)=0.
            CLR.L       (A4)+                   ; OccM(I)=0.
            CLR.L       (A5)+                   ; OccN(I)=0.
            CLR.L       (A6)+                   ; OccG(I)=0.
            
            ADDQ.B      #1,D0                   ; I+=1.(++I).
            BNE         OCCTP2                  ; Si I<256 on continue.

            CLR.W       D2
            MOVE.B      HEADER,D2
            LSL.W       #2,D2
            LEA.L       Occ1,A1
            MOVE.L      D3,$8(A1)               ; OccT(2).
            MOVE.L      D4,$0(A1,D2.W)          ; OccT(HEADER)

            BRA         REORDER

NOPHASE_1:  CLR.B       PHASE_FLG               ; Phase_1 non efficiente.
            CLR.L       GAIN1                   ; Pas de Gain de Phase_1.

;           Occurences= occurences r‚elles(celles du fichier)
;           OccT(I)=Occ1(I)+2*Occ2(I)+3*(Occ3(I)+OccM(I))+OccG(I).

            MOVE.L      #$FF,D0                 ; I initial = 255.

OCCTN0:     MOVE.L      (A3),D2                 ; Occ3(I).
            ADD.L       (A4),D2                 ; +OccM(I).
            MOVE.L      D2,D1
            LSL.L       #1,D2
            ADD.L       D1,D2                   ; 3*(Occ3(I)+OccM(I)).
            MOVE.L      (A2),D1
            LSL.L       #1,D1
            ADD.L       D1,D2                   ; +2*Occ2(I).
            ADD.L       (A6),D2                 ; +OccG(I).
            ADD.L       D2,(A1)+                ; +Occ1(I).
            CLR.L       (A2)+                   ; Occ2(I)=0.
            CLR.L       (A3)+                   ; Occ3(I)=0.
            CLR.L       (A4)+                   ; OccM(I)=0.
            CLR.L       (A5)+                   ; OccN(I)=0.
            CLR.L       (A6)+                   ; OccG(I)=0.
            
            DBF         D0,OCCTN0               ; Prochain I=I-1.
            
REORDER:    ; Ordonner les futures feuilles par ordre croissant.
            LEA.L       OccG,A1
            MOVE.L      A1,A2
            ADDA.L      #$400,A2
            LEA.L       Occ1,A3
            MOVEQ       #$00,D7

REORDER0:   MOVEQ       #$00,D0                 ; OccT(Max) initiale.
            MOVE.L      #$FF,D1                 ; MAX initial = 255.
            LEA.L       Occ2,A0

REORDER1:   MOVE.L      -(A0),D2                ; OccT(I)
            CMP.L       D2,D0                   ; OccT(MAX)>OccT(I) ?
            BGE         REORDER2                ; Oui.
            MOVE.L      D2,D0                   ; Non, OccT(MAX)=OccT(I).
            MOVE.L      D1,D3                   ; MAX=I.
REORDER2:   DBF         D1,REORDER1             ; Prochain I.
            TST.L       D0
            BEQ         REORDEREND              ; Plus de feuilles.
            MOVE.L      D0,-(A1)                ; On sauve OccT(MAX).
            MOVE.L      D3,-(A2)                ; On sauve MAX.
            LSL.W       #2,D3
            CLR.L       $0(A3,D3.W)             ; OccT(MAX)=0.
            SUBQ.B      #1,D7                   ; Une feuille en plus.
            BNE         REORDER0

REORDEREND: ; D7.B contient 256 - Nombre_de_feuilles.
            MOVE.W      D7,NBLEAVE

            CLR.L       D0
            MOVE.W      D7,D0
            LSL.W       #2,D0
            LEA.L       OccN,A2
            ADDA.L      D0,A2
            MOVE.L      (A2),D2                 ; OccT(PF).
            MOVE.L      $4(A2),D3               ; OccT(P2F).
            LEA.L       Occ1,A1                 ; Occurence des Nodes.
            LEA.L       OccN,A5                 ; Occurence des feuilles.
            LEA.L       OccM,A4                 ; Appartenance au node dans le
                                                ; Byte de poids faible et
                                                ; Profondeur dans l'arbre
                                                ; dans le byte suivant.
            CLR.L       D6                      ; Nombre de Nodes initiaux.
            

MKNOD:      ; Faire un node avec NF et N2F.
            
            CLR.L       D0
            MOVE.W      NXTNOD,D0               ; Prochain node … cr‚er.
            ADD.W       #$100,D0
            MOVE.L      D0,-$0400(A2)           ; Node appartenance de PF.
            MOVE.L      D0,-$03FC(A2)           ; Node appartenence de P2F.
            ADD.L       D2,D3                   ; OccT(PF)+OccT(P2F).
            AND.W       #$FF,D0
            LSL.W       #2,D0
            MOVE.L      D3,$00(A1,D0.W)         ; Occurence du Node.
            ADD.W       #1,NXTNOD
            ADDQ.L      #8,A2
            ADDQ.B      #1,D6                   ; + 1 node.
            ADDQ.B      #2,D7                   ; - 2 feuilles.

PNP2N:      ; Trouver PN et P2N.
            CLR.L       D0
            MOVE.W      NXTNOD,D0
            LSL.W       #2,D0                   ; I initial.
            MOVE.L      A1,A3
            ADDA.L      D0,A3
            MOVE.L      #$7FFFFFFF,D1
            
PNP2N0:     SUBQ.W      #4,D0
            MOVE.L      -(A3),D2
            CMP.L       D2,D1
            BLT         PNP2N1                  ; OccT(PN)<OccT(I).
            MOVE.L      D1,D3                   ; P2N=PN
            MOVE.W      D4,D5
            MOVE.L      D2,D1                   ; PN=I
            MOVE.W      D0,D4
            BNE         PNP2N0
            BRA         PNP2NEND
PNP2N1:     CMP.L       D2,D3
            BLE         PNP2N2
            MOVE.L      D2,D3                   ; P2N=I
            MOVE.W      D0,D5
PNP2N2:     TST.W       D0
            BNE         PNP2N0
            
PNP2NEND:   ; Dans D4 PN*4, dans D5 P2N*4

            MOVE.L      (A2),D2                 ; OccT(PF).
            MOVE.L      $04(A2),D3              ; OccT(P2F).

            TST.B       D7
            BNE         MAINTST0                ; Il reste des feuilles.
            CMP.B       #1,D6                   ; Non, un seul node ?
            BEQ         BUILDEND                ; Oui, arbre final.
            
            
FUSNOD:     ; Fusionner les deux nodes PN et P2N dans PN.
            
            MOVE.L      $00(A1,D5.W),D0         ; OccT(P2N)
            ADD.L       D0,$00(A1,D4.W)         ; +OccT(PN).
            MOVE.L      #$7FFFFFFF,$00(A1,D5.W) ; OccT(P2N)=0.
            MOVE.L      A2,A3
            SUBA.L      #$400,A3
            MOVE.W      NBLEAVE,D0
            LSR.W       #2,D4
            LSR.W       #2,D5

FUSNOD0:    MOVE.L      -(A3),D1
            CMP.B       D1,D4                   ; Appartient au node D4 ?
            BEQ         FUSNOD1                 ; Oui.
            CMP.B       D1,D5                   ; Appartient au node D5 ?
            BNE         FUSNOD2                 ; Non.
            MOVE.B      D4,D1                   ; Oui, maintenant au node D4.
FUSNOD1:    ADD.W       #$100,D1                ; Profondeur + 1.
            MOVE.L      D1,(A3)
FUSNOD2:    ADDQ.W      #1,D0
            CMP.B       D0,D7                   ; Prochaine feuille ?
            BNE         FUSNOD0

            SUBQ.L      #1,D6                   ; Un node en moins.
            BRA         PNP2N
            
MAINTST0:   CMP.L       $00(A1,D4.W),D2         ; OccT(PN), OccT(PF).
            BGE         NBNODE
            CMP.B       #$FF,D7                 ; Une seule feuille ?
            BEQ         PF_PN                   ; Oui.
            CMP.L       $00(A1,D4.W),D3         ; Non, OccT(PN)>OccT(P2F) ?
            BLT         MKNOD                   ; Oui.
            BRA         PF_PN                   ; Non, PF -> Node PN.

NBNODE:     CMP.B       #$1,D6                  ; Un seul node ?
            BEQ         PF_PN                   ; Oui, PF -> Node Pn.
            CMP.L       $00(A1,D5.W),D2         ; Non, OccT(PF)<OccT(P2N) ?
            BGE         FUSNOD                  ; PN,P2N -> PN.
            
PF_PN:      ; Greffer la feuille PF dans le node PN.

            ADD.L       D2,$0(A1,D4.W)          ; OccT(PN)+=OccT(PF)
            MOVE.L      #$100,D1                ; Profondeur de PF=1.
            LSR.W       #2,D4
            MOVE.B      D4,D1                   ; PF appartient au node D4.
            MOVE.L      D1,-$0400(A2)
            MOVE.L      A2,A3
            SUBA.L      #$400,A3
            MOVE.W      NBLEAVE,D0              ; I initial.

PF_PN0:     MOVE.L      -(A3),D1
            CMP.B       D1,D4                   ; I appartient au node D4 ?
            BNE         PF_PN1
            ADD.L       #$100,(A3)              ; Oui, Profondeur ++.
PF_PN1:     ADDQ.B      #1,D0
            CMP.B       D0,D7                   ; Prochaine feuille ?
            BNE         PF_PN0                  ; Oui.

            ADDQ.L      #4,A2                   ; Prochaine Feuille change.
            ADDQ.L      #1,D7                   ; - une feuille.
            BRA         PNP2N
            
BUILDEND:   ; L'arbre est construit !
            ; Dans OccM AND #$FF00 : Profondeur dans l'arbre * 256.


;     Efficience de la phase PSEUDO-HUFFMAN.
;     Multiplication de l'occurence par la profondeur pour tous les octets.
;     La somme totale de ces multiplications sera divis‚e par 8.
;     Si le chiffre obtenu est sup‚rieur au total des occurences il n'y
;     aura pas de compression.

            CLR.L       D0
            MOVE.W      NBLEAVE,D0
            LSL.W       #2,D0
            LEA.L       OccN,A2
            ADDA.L      D0,A2
            LEA.L       OccG,A3
            MOVEQ       #7,D6                   ; Nombre de bits.
            CLR.L       D7                      ; Nombre d'octets.
            MOVE.B      -$3FE(A2),D1            ; Plus grande profondeur.
            CMP.B       #$20,D1                 ; <= 32 ?
            BLE         EFFPH0                  ; Oui.
            MOVE.L      #errOVlen,-(A7)         ; Non, erreur,
            BRA         MSG_UNP                 ; on ne compresse pas

EFFPH0:     MOVE.B      -$03FE(A2),D1
            MOVE.L      (A2)+,D2
EFFPH1:     MOVE.B      -$03FE(A2),D3
            CMP.B       D3,D1
            BNE         MX0
            CMPA.L      A3,A2
            BEQ         MX0
            ADD.L       (A2)+,D2                ; Somme des occurences des
            BRA         EFFPH1                  ; feuilles de meme profondeur.


MX0:        TST.B       D1                      ; Multiplication.
            BEQ         MXEND
            LSR.B       #1,D1
            BCC         MX1
            ADD.L       D2,D6
            BCC         MX1
            ADDQ.L      #1,D7
MX1:        LSL.L       #1,D2
            BCC         MX0
            ADDQ.L      #1,D7
            BRA         MX0
MXOVER:     MOVE.L      #errOvByte,-(A7)
            BRA         MSG_UNP

MXEND:      ; Fin de la multiplication.

            CMPA.L      A3,A2                   ; Reste des occurences.
            BNE         EFFPH0                  ; Oui.

            LSR.L       #3,D6
            CMP.L       #7,D7
            BGT         MXOVER
            ROR.L       #4,D7
            ADD.L       D6,D7
            BCS         MXOVER
            
            MOVE.L      src_len,D1              ; Phase_2 efficiente ?
            SUB.L       GAIN1,D1
            MOVE.L      D1,I_LEN                ; Longueur interm‚diaire.
            SUB.L       D7,D1                   ; Phase_2 efficiente ?
            BLT         NOPHASE_2               ; Non.
            OR.B        #2,PHASE_FLG            ; Oui.
            MOVE.L      D1,GAIN2                ; Gain de compression Phase_2.
            BSR         SHOW_PC                 ; Montre les pourcentages.
; Reordonner par rapport aux longueurs binaires.
; OccG : v‚ritable valeur de l'octet.
; OccM : Profondeur dans l'arbre.
; NBLEAVE : Nombre de feuilles.

P_ORDER:    LEA.L       OccM,A0

P_ORDER0:   LEA.L       OccN,A1
            MOVE.W      NBLEAVE,D4
            MOVE.L      #$100,D3
            CLR.L       D1

P_ORDER1:   MOVE.L      -(A1),D0
            CMP.L       D0,D1
            BGT         P_ORDER4
            BNE         P_ORDER2
            MOVE.L      $800(A1),D2
            CMP.L       D2,D3
            BGT         P_ORDER3
            BRA         P_ORDER4
P_ORDER2:   MOVE.L      D0,D1
P_ORDER3:   MOVE.L      $800(A1),D3
            MOVE.L      A1,A2
P_ORDER4:   ADDQ.B      #1,D4
            BNE         P_ORDER1

            TST.L       D1
            BEQ         P_ORDERED
            AND.L       #$FF00,D1
            OR.B        D3,D1
            MOVE.L      D1,-(A0)
            CLR.L       (A2)
            BRA         P_ORDER0

P_ORDERED:  MOVE.W      NBLEAVE,D4
            LEA.L       OccM,A0
            LEA.L       OccM,A1
            LSL.W       #2,D4
            ADDA.L      D4,A1
            LSR.W       #2,D4
            CLR.L       D1

P_ORDERED0: MOVE.L      -(A0),D0
            MOVE.B      D0,D1
            CLR.B       D0
            MOVE.L      D1,$800(A1)
            MOVE.L      D0,(A1)+

            ADDQ.B      #1,D4
            BNE         P_ORDERED0


;     Attribution des nouvelles valeurs binaires des octets.

            LEA.L       Occ1,A1                 ; Clearer la zone non utilis‚e.
            MOVE.W      #$2FF,D0
CNUAZ:      CLR.L       (A1)+
            DBF         D0,CNUAZ

            CLR.L       D0
            MOVE.W      NBLEAVE,D0
            LSL.W       #2,D0
            LEA.L       OccM,A4
            LEA.L       Occ1,A1
            LEA.L       Occ2,A2
            ADDA.L      D0,A4                   ; Adr. de la premiŠre feuille.
            MOVEQ       #0,D3                   ; PremiŠre clef.
            MOVE.L      (A4),D1                 ; Plus grande longueur de clef.
            MOVE.W      D1,D4
            LSR.W       #8,D4
            MOVE.B      D4,DEEPTH               ; Plus profonde clef.
            LSR.W       #2,D0
            MOVE.L      D1,D2

MKKEY0:     MOVE.L      D3,D4                   ; Inverse la clef.
            CLR.L       D5
            LSR.W       #8,D2                   ; Profondeur de la clef.
MKKEY1:     ROXR.L      #1,D4                   ; Passage d'un bit de D4
            ROXL.L      #1,D5                   ; … D5.
            SUBQ.W      #1,D2                   ; Encore des bits … passer ?
            BNE         MKKEY1                  ; Oui.
            MOVE.L      $0800(A4),D4            ; Veritable octet.
            LSL.W       #2,D4
            MOVE.L      D5,$0(A1,D4.W)          ; Stocke la clef.
            MOVE.L      D1,D2
            LSR.W       #8,D2                   ; Longueur de la clef.
            MOVE.L      D2,$0(A2,D4.W)          ; Stock‚e !
            CLR.L       $0800(A4)
            CLR.L       (A4)+

            ADDQ.L      #1,D3                   ; Nouvelle clef.
            ADDQ.B      #1,D0
            BEQ         MKKEY3
            MOVE.L      (A4),D2

MKKEY2:     CMP.W       D2,D1                   ; Nouvelle longueur ?
            BEQ         MKKEY0                  ; Non.
            LSR.L       #1,D3                   ; Longueur de clef -1.
            SUB.W       #$100,D1
            BRA         MKKEY2

MKKEY3:     LSR.W       #8,D1
            MOVE.B      D1,ROOT

; Optimisation: Gain de bits, N*X en bits < bits(H N-1 X) ? (2 < N < 8).

DILEM:      BTST        #0,PHASE_FLG            ; Phase_1 ?
            BEQ         DILEMEND                ; Non.
            CLR.W       D0
            MOVE.B      HEADER,D0
            LSL.W       #2,D0
            LEA.L       Occ3,A3
            MOVE.L      $0(A2,D0.W),D1          ; Longueur en bits de HEADER.
            MOVEQ       #0,D4                   ; I initial = 0.

DILEM0:     MOVEQ       #$0,D7
            CMP.B       HEADER,D4               ; I=HEADER ?
            BEQ         DILEM3
            MOVEQ       #$2,D2
            MOVEQ       #$8,D3                  ; Indexe sur la longueur de I.
            MOVE.L      -$400(A3),D6            ; Longueur clef de I (LG(I)).
            MOVE.L      D6,D0
DILEM1:     ADD.L       D6,D0                   ; + LG(I).
            MOVE.L      $0(A2,D3.W),D5          ; LG(N).
            ADD.W       D1,D5                   ; LG(N)+LG(H).
            CMP.L       D5,D0                   ; LG(N)+LG(I)>N*LG(I) ?
            BGE         DILEM2                  ; Non.
            BSET        D2,D7                   ; Oui, bit positionn‚.
DILEM2:     ADDQ.W      #$4,D3
            ADDQ.B      #1,D2                   ; Prochain bit.
            CMP.B       #$20,D2                 ; 32 iŠme ?
            BNE         DILEM1                  ; Non.
DILEM3:     MOVE.L      D7,(A3)+

            ADDQ.B      #1,D4                   ; Prochain octet.
            BNE         DILEM0                  ; On y va !

DILEMEND:   ; Si compression de Phase_1 les dilemmes sont r‚gl‚s.

            BRA         CRT_TJT

NOPHASE_2:  ; Compression phase pseudo huffman non-efficiente.
            BSR         SHOW_PC                 ; Montre les pourcentages
            TST.B       PHASE_FLG               ; Phase_1 OK ?
            BNE         NPH20
            MOVE.L      #nopack,-(A7)
            BRA         MSG_UNP
NPH20:      MOVE.L      #ppack1,-(A7)           ; Message d'utilisation du
            BRA         MSG_UNP                 ; compresseur type 1.

CRT_TJT:    ; Cr‚er le fichier tarjet et y ‚crire les informations pour
            ; le d‚compresseur associ‚ : 'UNPAK2.PRG'

HDMK:       ; Fabrique l'entete du fichier tarjet.

;   1 octet = 1 si fichier compresse
;   1 octet = HEADER
;   2 word  = Taille fichier normal/Taille fichier Huffman
;   2 word  =    ..........
;   2 word  = -1 Fin des fichiers
;   1 octet = 0 remplissage
;   1 octet = info generale
;   n long  = tables  
            MOVE.L      A1,-(A7)
            LEA         Head,A0
            MOVE.B      #1,(A0)+                ; Compresse
            MOVE.B      HEADER,(A0)+            ; HEADER.
            MOVE.W      nbr_len,D0
            LEA         tab_len,A1
HDMK1:      MOVE.W      (A1)+,(A0)+             ; Taille normal
            MOVE.W      #-1,(A0)+               ; Taille Huffman
            DBF         D0,HDMK1
            CLR.B       (A0)+                   ; Remplissage      
            MOVE.L      (A7)+,A1
            
PRE_INF:    ; Fabrique PRE_INF l'octet en d‚but de la table des KEY_INFO.
            ; 3 bits faibles = ROOT, 3 bits suivants repr‚sentent la
            ; longueur de chaque KEY_INFO.

            CLR.L       D0
            MOVE.B      ROOT,D0
            MOVE.B      DEEPTH,D1
            SUB.B       D0,D1
            ADDQ.B      #1,D1                   ; = DEEPTH-ROOT+1.
            OR.B        #$30,D0
            MOVEQ       #5,D2
PRE_INF0:   BTST        D2,D1                   ; Bit set ?
            BEQ         PRE_INF1
            SUBQ.L      #1,D2
            SUBQ.B      #8,D0                   ; BPKEY-1.
            BRA         PRE_INF0
PRE_INF1:   ; Dans D0 se trouve PRE_INF.
            MOVE.B      D0,(A0)+                ; PRE_INF stock‚.
            LSR.B       #3,D0

MK_INF:     ; Fabrication des KEY_INFO.

            CLR.W       D1                      ; I initial = 0.
            MOVEQ       #$20,D2                 ; Bit-position dans D4.
MK_KEY0:    MOVE.L      (A2)+,D3                ; Profondeur de la feuille.
            BEQ         MK_KEY1                 ; Pas une feuille.
            SUB.B       ROOT,D3
            ADDQ.L      #1,D3                   ; LG(I)- ROOT+1.
MK_KEY1:    MOVE.B      D0,D5                   ; indexe dans D3.
            ROR.B       D0,D3                   ; Premier … sortir … gauche.
MK_KEY2:    ROXL.B      #1,D3                   ; Transfert d'un bit de D3
            ROXL.L      #1,D4                   ; vers D4.
            SUBQ.B      #1,D2                   ; Dernier bit de D4 ?
            BNE         MK_KEY3                 ; Non.
            MOVE.L      D4,(A0)+                ; Oui, on stocke.
            MOVEQ       #$20,D2                 ; Nouvel indexe de D4.
MK_KEY3:    SUBQ.B      #1,D5                   ; Dernier bit de D3 sorti ?
            BNE         MK_KEY2                 ; Non, on continu !
            ADDQ.B      #1,D1                   ; Oui, Dernier octet ?
            BNE         MK_KEY0                 ; Non.
            CMP.B       #$20,D2                 ; Oui, D4 contient qque chose ?
            BEQ         MK_KEYEND               ; Non.
            MOVE.L      D4,(A0)+                ; Oui, on stocke !
            
MK_KEYEND:  ; Toutes les Key_INFOs sont calcul‚es et stock‚es !
            MOVE.B      -1(A0),LAST_OCT         ; Pour encodage SYNC 
            LSL.L       #5,D0                   ; Nombre d'octets de KEY_INF.
            ADD.L       #$0004,D0               ; Plus autres infos.
            MOVE.W      nbr_len,D1
            ADDQ        #1,D1
            LSL         #2,D1
            ADD         D1,D0
            MOVE.L      D0,head_len             ; Conserve pour reecriture

;     2Šme lecture du fichier source avec compression et ‚criture du fichier
;     tarjet.

PACK:       ; Ici v‚ritable routine de compression Multipl‚x‚e.

            CLR         nb_len
            CLR.L       src_len
            MOVE.L      src_adr,adr_cur
BLPACK:
            LEA         tab_len,A2
            MOVE        nb_len,D0
            LSL         #1,D0
            MOVE.W      0(A2,D0.W),src_len+2
            BEQ         END2PACK                ; Pas de comp. si 0

            MOVE.L      #packing,-(A7)          ; Signaler le d‚but de la
            MOVE.W      #$0009,-(A7)            ; Compression.
            TRAP        #1
            ADDQ.L      #6,A7

            CLR.W       D0
            MOVE.B      HEADER,D0
            LSL.W       #2,D0
            LEA.L       Occ1,A1                 ; Adr. des clefs d'encodage.
            LEA.L       Occ2,A4                 ; Adr. des longueurs des clefs.
            LEA.L       Occ3,A3                 ; Adr. des d‚cision Dilemme.
            MOVE.L      $0(A4,D0.W),HDLG
            MOVE.L      $0(A1,D0.W),HDKEY
            
            MOVEQ       #$20,D6                 ; Indexe du Long tarjet (D5).
            MOVE.L      C_LEN,D7                ; Longueur du buffer tarjet.
            MOVE.L      src_adr,A2
            ADDQ.L      #4,A2
            ADDA.L      B_LEN,A2                ; Adr. des data tarjet.
            MOVE.B      HEADER,D1               ; Valeur du HEADER.

            MOVE.L      adr_cur,A0
            MOVE.L      src_len,D0
            
PACK1:      MOVE.B      (A0)+,D3
            SUBQ.L      #1,D0
PACK2:      MOVEQ       #1,D4                   ; R‚p‚titions initialis‚es.
            MOVE.B      D3,D2
PACK3:      MOVE.B      (A0)+,D3
            SUBQ.L      #1,D0
            CMP.B       D3,D2                   ; R‚p‚tition ?
            BNE         PACK4                   ; Non.
            ADDQ.W      #1,D4                   ; Oui, r‚p‚tition++.
            CMP.W       #$101,D4                ; 257 r‚p‚titions ?
            BEQ         PACKV                   ; Oui, risque de d‚bordement.
            TST.L       D0                      ; Dernier octet du buffer ?
            BGE         PACK3                   ; Non, on continu.
            BRA         PACK4                   ; Oui, fin de traitement.

PACKV:      ; Emetre une TRAME 'H #$FF D2'

            MOVE.L      D3,A6                   ; Sauvegarde de D3.
            AND.W       #$FF,D2
            LSL.W       #2,D2
            SUBQ.W      #2,D4
            AND.W       #$FF,D4

TRAMEV:     MOVE.L      HDKEY,D1                ; Clef du HEADER.
            MOVE.L      HDLG,D3                 ; Longueur de cette Clef.
TRAMEV0:    ROXR.L      #1,D1                   ; Transfert d'un bit de D1
            ROXL.L      #1,D5                   ; vers D5.
            SUBQ.B      #1,D6                   ; Dernier bit … recevoir ?
            BNE         TRAMEV1                 ; Non.
            MOVEQ       #$20,D6                 ; Oui, envoier D5 dans le
            MOVE.L      D5,(A2)+                ; buffer tarjet.
            SUBQ.L      #4,D7                   ; + 4 octets dans ce buffer.
            BGT         TRAMEV1                 ; il peut encore supporter !
            BSR         WRITEPAGE               ; Ecrire le buffer tarjet !
TRAMEV1:    SUBQ.B      #1,D3                   ; Dernier bit … etre envoier?
            BNE         TRAMEV0
            LSL.W       #2,D4
            MOVE.L      $0(A1,D4.W),D1          ; Clef de N-1.
            MOVE.L      $0(A4,D4.W),D3          ; Longueur de cette clef.
TRAMEV2:    ROXR.L      #1,D1                   ; Transfert d'un bit de D1
            ROXL.L      #1,D5                   ; vers D5.
            SUBQ.B      #1,D6                   ; Dernier bit … recevoir ?
            BNE         TRAMEV3                 ; Non.
            MOVEQ       #$20,D6                 ; Oui, envoier D5 dans le
            MOVE.L      D5,(A2)+                ; buffer tarjet.
            SUBQ.L      #4,D7                   ; + 4 octets dans ce buffer.
            BGT         TRAMEV3                 ; il peut encore supporter !
            BSR         WRITEPAGE               ; Ecrire le buffer tarjet !
TRAMEV3:    SUBQ.B      #1,D3                   ; Dernier bit … etre envoier?
            BNE         TRAMEV2
            MOVE.L      $0(A1,D2.W),D1          ; Clef de D2.
            MOVE.L      $0(A4,D2.W),D3          ; Longueur de cette clef.
TRAMEV4:    ROXR.L      #1,D1                   ; Transfert d'un bit de D1
            ROXL.L      #1,D5                   ; vers D5.
            SUBQ.B      #1,D6                   ; Dernier bit … recevoir ?
            BNE         TRAMEV5                 ; Non.
            MOVEQ       #$20,D6                 ; Oui, envoier D5 dans le
            MOVE.L      D5,(A2)+                ; buffer tarjet.
            SUBQ.L      #4,D7                   ; + 4 octets dans ce buffer.
            BGT         TRAMEV5                 ; il peut encore supporter !
            BSR         WRITEPAGE               ; Ecrire le buffer tarjet !
TRAMEV5:    SUBQ.B      #1,D3                   ; Dernier bit … etre envoier?
            BNE         TRAMEV4
            MOVE.L      A6,D3                   ; R‚cup‚ration de D3.
            MOVE.B      HEADER,D1

            TST.L       D0                      ; Dernier octet du buffer src?
            BGE         PACK2                   ; Non, on continu !
            MOVE.B      HEADER,D1
            MOVE.L      A6,D2                   ; Oui, recupŠre D3 dans D2,
            MOVEQ       #1,D4                   ; dernier traitement avant de
            BRA         PACK4b                  ; quitter.

PACK4:      ; Il n'y a plus r‚p‚tition.
            CMP.W       #$02,D4
            BGT         PACKTRAME               ; + de 2 r‚p‚titions.
            MOVE.L      D3,A6                   ; Sauvegarde de D3.
PACK4b:     SUBQ.W      #1,D4                   ; N -> N-1(r‚p‚titions).
            CMP.B       D2,D1                   ; X est-il HEADER ?
            BNE         PACK4c                  ; Non.

TRAMEH:     ; TRAME 'H N-1'
            MOVE.L      HDKEY,D1                ; Clef du HEADER.
            MOVE.L      HDLG,D3                 ; Longueur de cette Clef.
TRAMEH0:    ROXR.L      #1,D1                   ; Transfert d'un bit de D1
            ROXL.L      #1,D5                   ; vers D5.
            SUBQ.B      #1,D6                   ; Dernier bit … recevoir ?
            BNE         TRAMEH1                 ; Non.
            MOVEQ       #$20,D6                 ; Oui, envoier D5 dans le
            MOVE.L      D5,(A2)+                ; buffer tarjet.
            SUBQ.L      #4,D7                   ; + 4 octets dans ce buffer.
            BGT         TRAMEH1                 ; il peut encore supporter !
            BSR         WRITEPAGE               ; Ecrire le buffer tarjet !
TRAMEH1:    SUBQ.B      #1,D3                   ; Dernier bit … etre envoier?
            BNE         TRAMEH0
            AND.W       #$FF,D4
            LSL.W       #2,D4
            MOVE.L      $0(A1,D4.W),D1          ; Clef de N-1.
            MOVE.L      $0(A4,D4.W),D3          ; Longueur de cette clef.
TRAMEH2:    ROXR.L      #1,D1                   ; Transfert d'un bit de D1
            ROXL.L      #1,D5                   ; vers D5.
            SUBQ.B      #1,D6                   ; Dernier bit … recevoir ?
            BNE         TRAMEH3                 ; Non.
            MOVEQ       #$20,D6                 ; Oui, envoier D5 dans le
            MOVE.L      D5,(A2)+                ; buffer tarjet.
            SUBQ.L      #4,D7                   ; + 4 octets dans ce buffer.
            BGT         TRAMEH3                 ; il peut encore supporter !
            BSR         WRITEPAGE               ; Ecrire le buffer tarjet !
TRAMEH3:    SUBQ.B      #1,D3                   ; Dernier bit … etre envoier?
            BNE         TRAMEH2
            MOVE.L      A6,D3
            MOVE.B      HEADER,D1

            TST.L       D0                      ; Dernier octet src du buffer?
            BGE         PACK2                   ; Non, autre r‚p‚tition ?
            BRA         PACKEND                 ; Oui, fin de compression !

PACK4c:     ; Envoier D4 fois la clef de D2 ( Ici D2 != HEADER).
            AND.W       #$FF,D2
            LSL.W       #2,D2
            
TRAMEC0:    ; Envoier un caractŠre D2.
            MOVE.L      $0(A1,D2.W),D1          ; Clef de D2.
            MOVE.L      $0(A4,D2.W),D3          ; Longueur de cette clef.
TRAMEC1:    ROXR.L      #1,D1                   ; Transfert d'un bit de D1
            ROXL.L      #1,D5                   ; vers D5.
            SUBQ.B      #1,D6                   ; Dernier bit … recevoir ?
            BNE         TRAMEC2                 ; Non.
            MOVEQ       #$20,D6                 ; Oui, envoier D5 dans le
            MOVE.L      D5,(A2)+                ; buffer tarjet.
            SUBQ.L      #4,D7                   ; + 4 octets dans ce buffer.
            BGT         TRAMEC2                 ; il peut encore supporter !
            BSR         WRITEPAGE               ; Ecrire le buffer tarjet !
TRAMEC2:    SUBQ.B      #1,D3                   ; Dernier bit … etre envoier?
            BNE         TRAMEC1
            SUBQ.W      #1,D4                   ; Autre caractŠre … emetre ?
            BGE         TRAMEC0
            MOVE.L      A6,D3                   ; R‚cup‚ration de D3.
            MOVE.B      HEADER,D1
            
            TST.L       D0                      ; Dernier octet src du buffer?
            BGE         PACK2                   ; Non, autre r‚p‚tition ?
            BRA         PACKEND                 ; Oui, fin de compression !

PACKTRAME:  ; Envoie d'une trame ou multi octet selon dilemme.
            SUBQ.W      #1,D4                   ; N devient N-1(r‚p‚titions).
            AND.W       #$FF,D4
            MOVE.L      D3,A6                   ; Sauvegarde de D3.
            AND.W       #$FF,D2
            LSL.W       #2,D2
            CMP.W       #$20,D4                 ; + de 32 r‚p‚titions ?
            BGE         TRAME                   ; Oui, c'est une trame.
            MOVE.L      $0(A3,D2.W),D3
            BTST        D4,D3                   ; Choix du dilemme ?
            BNE         TRAMEC0                 ; Choix de REPETITION.

            ; Choix de la TRAME.
TRAME:      MOVE.L      HDKEY,D1                ; Clef du HEADER.
            MOVE.L      HDLG,D3                 ; Longueur de cette Clef.
TRAME0:     ROXR.L      #1,D1                   ; Transfert d'un bit de D1
            ROXL.L      #1,D5                   ; vers D5.
            SUBQ.B      #1,D6                   ; Dernier bit … recevoir ?
            BNE         TRAME1                  ; Non.
            MOVEQ       #$20,D6                 ; Oui, envoier D5 dans le
            MOVE.L      D5,(A2)+                ; buffer tarjet.
            SUBQ.L      #4,D7                   ; + 4 octets dans ce buffer.
            BGT         TRAME1                  ; il peut encore supporter !
            BSR         WRITEPAGE               ; Ecrire le buffer tarjet !
TRAME1:     SUBQ.B      #1,D3                   ; Dernier bit … etre envoier?
            BNE         TRAME0
            LSL.W       #2,D4
            MOVE.L      $0(A1,D4.W),D1          ; Clef de N-1.
            MOVE.L      $0(A4,D4.W),D3          ; Longueur de cette clef.
WDK_SPY:    BNE         TRAME2
            MOVE.L      #KRITIK_WDK,-(A7)       ; Erreur critique, ne devrait
            BRA         MSG_UNP                 ; survenir, mais garantie une
                                                ; compression coh‚rente.
TRAME2:     ROXR.L      #1,D1                   ; Transfert d'un bit de D1
            ROXL.L      #1,D5                   ; vers D5.
            SUBQ.B      #1,D6                   ; Dernier bit … recevoir ?
            BNE         TRAME3                  ; Non.
            MOVEQ       #$20,D6                 ; Oui, envoier D5 dans le
            MOVE.L      D5,(A2)+                ; buffer tarjet.
            SUBQ.L      #4,D7                   ; + 4 octets dans ce buffer.
            BGT         TRAME3                  ; il peut encore supporter !
            BSR         WRITEPAGE               ; Ecrire le buffer tarjet !
TRAME3:     SUBQ.B      #1,D3                   ; Dernier bit … etre envoier?
            BNE         TRAME2
            MOVE.L      $0(A1,D2.W),D1          ; Clef de D2.
            MOVE.L      $0(A4,D2.W),D3          ; Longueur de cette clef.
TRAME4:     ROXR.L      #1,D1                   ; Transfert d'un bit de D1
            ROXL.L      #1,D5                   ; vers D5.
            SUBQ.B      #1,D6                   ; Dernier bit … recevoir ?
            BNE         TRAME5                  ; Non.
            MOVEQ       #$20,D6                 ; Oui, envoier D5 dans le
            MOVE.L      D5,(A2)+                ; buffer tarjet.
            SUBQ.L      #4,D7                   ; + 4 octets dans ce buffer.
            BGT         TRAME5                  ; il peut encore supporter !
            BSR         WRITEPAGE               ; Ecrire le buffer tarjet !
TRAME5:     SUBQ.B      #1,D3                   ; Dernier bit … etre envoier?
            BNE         TRAME4
            MOVE.L      A6,D3                   ; R‚cup‚ration de D3.
            MOVE.B      HEADER,D1
            
            TST.L       D0                      ; Dernier octet src du buffer ?
            BGE         PACK2                   ; Non, autre r‚p‚tition ?
            
PACKEND:    ; Fin de traitement, vider D5 dans buffer tjt,
            ; et vider buffer tjt dans le fichier tjt.

            LSL.L       D6,D5
TWILIGHT:   CMP.B       #$20,D6
            BGE         NO_SD5                  ; Pas de sauvegarde de D5.
            MOVE.L      D5,(A2)+
            SUBQ.L      #4,D7
NO_SD5:     CMP.L       C_LEN,D7
            BEQ         NO_WRT                  ; Pas d'‚criture du buffer.
            BSR         WRITEPAGE
NO_WRT:

;     ~~~~~~~~~~~~~~~~~~~~~~
;     FIN DE LA COMPRESSION.
;     ~~~~~~~~~~~~~~~~~~~~~~

ENDPACK:
;            MOVE.L      #gaintpc,-(A7)          ; Afficher le pourcentage
;            MOVE.W      #$0009,-(A7)            ; de compression totale.
;            TRAP        #1
;            ADDQ.L      #6,A7
;            MOVE.L      src_len,DVPC
;            MOVE.L      GAIN1,D0
;            ADD.L       GAIN2,D0
;            MOVE.L      D0,NMPC
;            BSR         POURCENT
END1PACK:
            MOVE.W      nbr_len,D0
            SUBQ        #1,D0
            CMP         nb_len,D0
            BLE.S       TOTENDP
            CLR.L       D0
            MOVE.W      nb_len,D0
            ADD         D0,D0
            LEA         tab_len,A0
            MOVE.W      0(A0,D0.W),D0
;            ADDQ        #2,D0           ; car 2 octets vide a la fin
            ADD.L       D0,adr_cur
            ADDQ        #1,nb_len
            BRA         BLPACK
END2PACK:
            LEA         Head+4,A0         ; Met taille du fichier
            MOVE.W      nb_len,D1         ; compresse
            LSL         #2,D1             ; dans le header
            CLR.W       0(A0,D1)          ;  ...
            BRA          END1PACK
TOTENDP:
;Ecrit Header
            LEA         Head,A2
            LEA         buffer,A1
            MOVE.L      Head_len,D1
            MOVE.L      D1,NB_ECRIT
            MOVE.B      #$07,LAST_OCT
            BSR         PREPARE
            ADDQ.L      #4,NB_ECRIT
            MOVE.L      NB_ECRIT,Head_len
            MOVE.B      Head_len+2,(A1)+  ;Octet fort Head_len 
            MOVE.B      #SYNC,(A1)+
            MOVE.B      Head_len+3,(A1)+  ;Octet faible Head_len
            MOVE.B      #SYNC,(A1)+
            MOVE.L      #buffer,-(A7)
            MOVE.L      NB_ECRIT,-(A7)
            MOVE.W      tjt_hdl,-(A7)
            MOVE.W      #$40,-(A7)
            TRAP        #1
            LEA         12(A7),A7
;Ecrit datas
            LEA         buffer,A0
            ADD.L       B_LEN,A0
            ADD.L       C_LEN,A0
            MOVE.L      A0,-(A7)
            MOVE.L      tjt_len,-(A7)
            MOVE.W      tjt_hdl,-(A7)
            MOVE.W      #$40,-(A7)
            TRAP        #1
            LEA         12(A7),A7
            MOVE.L      Head_len,D0
            ADD.L       D0,tjt_len
            MOVE.L      savpile,A7
            RTS                        ; Fin de l'algorithme.

; Fin avec erreur disque
            MOVE.L      #end_msg,-(A7)
MSG_END:    MOVE.W      #$0009,-(A7)    
            TRAP        #1
            ADDQ        #6,A7
            MOVE.W      #$0007,-(A7)
            TRAP        #1
            ADDQ        #2,A7
            MOVE.L      savpile,A7
            ILLEGAL

; Fin sans compression
MSG_UNP:
            MOVE        #9,-(A7)
            TRAP        #1
            ADDQ        #6,A7
            LEA         Head,A0             ; Entete non compresse
            MOVE.L      src_len,(A0)        ; 0 dans 1er octet longueur
            PEA         Head
            MOVE.L      #$4,-(A7)
            MOVE.W      tjt_hdl,-(A7)
            MOVE.W      #$40,-(A7)
            TRAP        #1
            LEA         12(A7),A7
            MOVE.L      adr_cur,-(A7)       ; Sauvegarde
            MOVE.L      src_len,-(A7)
            MOVE.W      tjt_hdl,-(A7)
            MOVE.W      #$0040,-(A7)
            TRAP        #1
            ADDA.L      #$0000000C,A7
            ADD.L       #4,D0
            MOVE.L      D0,tjt_len
            MOVE.L      savpile,A7
            RTS
savpile:
           DC.L         0
;     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;     ~~                Segment des Sous-Routines.                ~~
;     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


SHOW_PC:    ; Affiche les pourcentages de compression.

            MOVE.L      #gain1pc,-(A7)          ; Afficher le pourcentage
            MOVE.W      #$0009,-(A7)            ; de la compression Phase_1.
            TRAP        #1
            ADDQ.L      #6,A7
            MOVE.L      src_len,DVPC
            MOVE.L      GAIN1,NMPC
            BSR         POURCENT
            MOVE.L      #gain2pc,-(A7)          ; Afficher le pourcentage
            MOVE.W      #$0009,-(A7)            ; de la compression Phase_2.
            TRAP        #1
            ADDQ.L      #6,A7
            MOVE.L      I_LEN,DVPC
            MOVE.L      GAIN2,NMPC
            BSR         POURCENT
            RTS

;                  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

WRITEPAGE:  ; Ecriture d'une portion du fichier tarjet.
            ; Avec encodage des octets SYNC
            ; Dans le buffer dest_cur: 
            ; ATTENTION :     Meme restriction que pour READPAGE.
            ; Au retour D7 contient C_LEN (..et A2 l'Adr. du buffer tarjet..)

            MOVEM.L     D0-D1/A0,-(A7)    ; Sauvegarde de registres sur la pile.
            MOVE.L      src_adr,A2
            ADDQ.L      #4,A2
            ADDA.L      B_LEN,A2          ; Adresse des octets tarjet.
            MOVE.L      C_LEN,D1
            SUB.L       D7,D1             ; Nombre d'octets a ecrire
            MOVE.L      D1,NB_ECRIT
            MOVE.L      dest_cur,A1
            CLR.L       SURPLUS_LONG
            BSR         PREPARE
            MOVE.L      C_LEN,D7
WRITEPAGE0: MOVE.L      NB_ECRIT,D0       ; Nombre d'octets reel
            ADD.L       D0,tjt_len
            ADD.L       D0,dest_cur       ; Nouvelle adresse du fichier
            LEA         Head+4,A0         ; Met taille du fichier
            MOVE.W      nb_len,D1         ; compresse
            LSL         #2,D1             ; dans le header
            MOVE.W      D0,0(A0,D1)       ;  ...
            MOVE.L      #strprint,string
            MOVE.L      D0,nombre
            BSR         TPRINTN
            MOVEM.L     (A7)+,D0-D1/A0    ; Restitution des registers sauv‚s.
            RTS
strprint:
            DC.B        'Write Page ',0
;                  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

PRTHEX:     ; DGPRT en binaire : bit 76543210
            ; bits 210: nombre de digit-1 … afficher.
            ; bit 7: 1 -> afficher la chaine point‚e par HDSTR avant les digits.
            ; bit 6: 1 -> afficher la chaine point‚e par ENDSTR aprŠs les digits
            ; bit 5: 1 -> Attendre une touche.
            ; bit 4: 1 -> transmettre la touche press‚e dans DGPRT.
            ; bit 3: pas encore d'utilisation, ca viendra peut-etre !
            
            MOVEM.L     D0-D2/A0,-(A7)
            CLR.W       D2
            MOVE.B      DGPRT,D2
            BPL         NOHEADSTR         ; Pas de chaine … afficher avant.
            MOVE.L      HDSTR,-(A7)       ; Adresse de la chaine.
            MOVE.W      #$0009,-(A7)      ; Ecrire la chaine.
            TRAP        #1                ; Execution !
            ADDQ.L      #6,A7             ; Corection de la pile.
NOHEADSTR:  AND.B       #$07,D2           ; Nombre de digit-1.
            MOVE.L      TOPRT,D1          ; Valeur … afficher.
            MOVE.W      D2,D0
            LSL.W       #2,D0
            ROR.L       D0,D1             ; Positionnement sur le premier
                                          ; digit … afficher.
PRTHEX0:    MOVE.B      D1,D0             ; Transmition du quartet (demi-octet)
            AND.W       #$F,D0
            ADD.W       #$30,D0           ; Devient le code ASCII.
            CMP.B       #$3A,D0           ; serait une lettre (A-F) ?
            BLT         PRTHEX1
            ADDQ.L      #7,D0             ; Oui, on corrige le code ASCII.
PRTHEX1:    MOVE.W      D0,-(A7)
            MOVE.W      #$0002,-(A7)      ; Ecrire le code ASCII.
            TRAP        #1                ; Execution !
            ADDQ.L      #4,A7             ; Correction de la pile.
            ROL.L       #4,D1             ; Prochain quartet … transmettre.
            DBF         D2,PRTHEX0
            BTST        #6,DGPRT          ; Chaine … la fin ?
            BEQ         NOENDSTR          ; Non.
            MOVE.L      ENDSTR,-(A7)      ; Oui, on l'affiche.
            MOVE.W      #$0009,-(A7)
            TRAP        #1                ; Execution !
            ADDQ.L      #6,A7             ; Correction de la pile.
NOENDSTR:   BTST        #5,DGPRT          ; Attendre une touche ?
            BEQ         PRTHEX2           ; Non, on quitte.
            MOVE.W      #$0007,-(A7)      ; Oui, on y va !
            TRAP        #1                ; Execution !
            ADDQ.L      #2,A7             ; Correction de la pile.
            BTST        #4,DGPRT          ; Transmettre le code de la touche?
            BEQ         PRTHEX2           ; Non, on quitte.
            MOVE.B      D0,DGPRT          ; Oui, code -> DGPRT (Byte => pas de
                                          ; Scan Code, seulement ASCII).
PRTHEX2:    MOVEM.L     (A7)+,D0-D2/A0
            RTS

POURCENT:   ; Routine qui affiche le pourcentage de NMPC/DVPC.

            MOVEM.L     D0-D3,-(A7)
            BSR         MAINPC            ; Chiffre avant la virgule.
            MOVE.W      #$0025,-(A7)      ; Affiche le caractŠre '%'.
            MOVE.W      #$0002,-(A7)
            TRAP        #1
            ADDQ.L      #4,A7
            BSR         MAINPC            ; Decimales du pourcentage.
            MOVE.W      #$002E,-(A7)      ; Affiche le caractŠre '.'.
            MOVE.W      #$0002,-(A7)
            TRAP        #1
            ADDQ.L      #4,A7
            MOVEM.L     (A7)+,D0-D3
            RTS

MAINPC:     MOVE.L      DVPC,D0
            LSR.L       #2,D0
            MOVE.L      D0,DVPC           ; DVPC/4.
            MOVE.L      NMPC,D1
            MOVE.L      D1,D2
            LSL.L       #3,D2
            ADD.L       D2,D1
            LSL.L       #1,D2
            ADD.L       D2,D1             ; NMPC*25.
            CLR.B       D2                ; NB=0.
            MOVEQ       #1,D3

MAINPC0:    CMP.L       D1,D0             ; NMPC<DVPC ?
            BGT         MAINPCEND         ; Oui.
            SUB.L       D0,D1             ; NMPC-=DVPC.
            ABCD        D3,D2             ; NB++.
            BRA         MAINPC0
MAINPCEND:  MOVE.L      D1,NMPC
            MOVE.B      D2,D0
            LSR.B       #4,D0
            AND.W       #$F,D0
            ADD.L       #$30,D0           ; Code ASCII des dizaines.
            MOVE.W      D0,-(A7)
            MOVE.W      #$0002,-(A7)
            TRAP        #1
            AND.W       #$F,D2
            ADD.B       #$30,D2           ; Code ASCII des unit‚s.
            MOVE.W      D2,$02(A7)
            TRAP        #1
            ADDQ.L      #4,A7
            RTS

;     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;     ~~                     Codage fichier                         ~~
;     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;*******   MODULE DE CODAGE DONNEES POUR INSTALLATION SUR UNE PISTE 
;*******   SANS SECTEUR:  INTERCALE DES 'SYNC' ENTRE DEUX OCTETS
;*******   FORMANT UNE PAIRE CRITIQUE    
;*******   A2: ADRESSE DU BUFFER A ENCODER
;*******   A1: ADRESSE BUFFER DESTINATION
;*******   D1: TAILLE A ENCODER
;*******   LAST_OCT:     EN ENTREE #SYNC SI DEBUT DE FICHIER
;*******                 OU DERNIER OCTET SI PARTIE DE FICHIER
;*******                 EN SORTIE DERNIER OCTET ENCODE
;*******   SURPLUS_LONG: NOMBRE DE #SYNC AJOUTES LORS DE L'ENCODAGE

SYNC:       EQU     $07
        
PREPARE:
            CLR.L   SURPLUS_LONG
            MOVEM.L D0-D7/A0/A2-A6,-(A7)
            SUBQ    #1,D1
            CLR.W   D0
            MOVE.B  LAST_OCT,D0
            ADD     D0,D0
            LEA     MFMDAT,A3
            MOVE    0(A3,D0.W),D3
PREP_BCL:   CLR.W   D0
            MOVE.B  (A2)+,D0
            ADD     D0,D0
            MOVE    0(A3,D0.W),D0
            BTST    #0,D3
            BEQ.S   HIGHBIT
            BCLR    #15,D0
HIGHBIT:    SWAP    D3
            MOVE    D0,D3
TESTERR:    LEA     TABERR,A4
SUIVERR:    MOVE.L  D3,D0
            ANDI.L  (A4)+,D0
            CMP.L   (A4)+,D0
            BNE.S   PASERR
            MOVE.B  #SYNC,(A1)+
            MOVE.B  -1(A2),(A1)+
            ADDQ.L  #1,SURPLUS_LONG
            DBF     D1,PREP_BCL
            BRA.S   PREP_FIN
PASERR:     CMPI.L  #-1,(A4)
            BNE.S   SUIVERR
            MOVE.B  -1(A2),(A1)+
            CMPI.B  #SYNC,-1(A1)
            BNE.S   NOTSYNC
            NOP
            MOVE.B  #SYNC,(A1)+
            ADDQ.L  #1,SURPLUS_LONG
NOTSYNC:    DBF     D1,PREP_BCL
PREP_FIN:   MOVE.B  #SYNC,(A1)+
            MOVE.B  -1(A1),LAST_OCT
            ADDQ.L  #1,SURPLUS_LONG
            MOVE.L  SURPLUS_LONG,D0
            ADD.L   D0,NB_ECRIT
            MOVEM.L (A7)+,D0-D7/A0/A2-A6
            RTS
NB_ECRIT:
            DC.L    0
SURPLUS_LONG:
            DC.L    0
LAST_OCT:
            DC.B    0
    EVEN
TABERR:
    DC.L    %11111111111111100000000000000000   ;$C2 EN MFM
    DC.L    %10100100010010000000000000000000
    DC.L    %00111111111111111000000000000000
    DC.L    %00101001000100100000000000000000
    DC.L    %00001111111111111110000000000000
    DC.L    %00001010010001001000000000000000
    DC.L    %00000011111111111111100000000000
    DC.L    %00000010100100010010000000000000
    DC.L    %00000000111111111111111000000000
    DC.L    %00000000101001000100100000000000
    DC.L    %00000000001111111111111110000000
    DC.L    %00000000001010010001001000000000
    DC.L    %00000000000011111111111111100000
    DC.L    %00000000000010100100010010000000
    DC.L    %00000000000000111111111111111000
    DC.L    %00000000000000101001000100100000
    DC.L    %00000000000000001111111111111110
    DC.L    %00000000000000001010010001001000

    DC.L    %11111111111111100000000000000000   ;$A1 EN MFM
    DC.L    %10001001000100100000000000000000
    DC.L    %00111111111111111000000000000000
    DC.L    %00100010010001001000000000000000
    DC.L    %00001111111111111110000000000000
    DC.L    %00001000100100010010000000000000
    DC.L    %00000011111111111111100000000000
    DC.L    %00000010001001000100100000000000
    DC.L    %00000000111111111111111000000000
    DC.L    %00000000100010010001001000000000
    DC.L    %00000000001111111111111110000000
    DC.L    %00000000001000100100010010000000
    DC.L    %00000000000011111111111111100000
    DC.L    %00000000000010001001000100100000
    DC.L    %00000000000000111111111111111000
    DC.L    %00000000000000100010010001001000
    DC.L    %00000000000000001111111111111110
    DC.L    %00000000000000001000100100010010
    DC.L    -1

MFMDAT:
    DC.W    $AAAA,$AAA9,$AAA4,$AAA5,$AA92,$AA91,$AA94,$AA95
    DC.W    $AA4A,$AA49,$AA44,$AA45,$AA52,$AA51,$AA54,$AA55
    DC.W    $A92A,$A929,$A924,$A925,$A912,$A911,$A914,$A915
    DC.W    $A94A,$A949,$A944,$A945,$A952,$A951,$A954,$A955
    DC.W    $A4AA,$A4A9,$A4A4,$A4A5,$A492,$A491,$A494,$A495
    DC.W    $A44A,$A449,$A444,$A445,$A452,$A451,$A454,$A455
    DC.W    $A52A,$A529,$A524,$A525,$A512,$A511,$A514,$A515
    DC.W    $A54A,$A549,$A544,$A545,$A552,$A551,$A554,$A555
    DC.W    $92AA,$92A9,$92A4,$92A5,$9292,$9291,$9294,$9295
    DC.W    $924A,$9249,$9244,$9245,$9252,$9251,$9254,$9255
    DC.W    $912A,$9129,$9124,$9125,$9112,$9111,$9114,$9115
    DC.W    $914A,$9149,$9144,$9145,$9152,$9151,$9154,$9155
    DC.W    $94AA,$94A9,$94A4,$94A5,$9492,$9491,$9494,$9495
    DC.W    $944A,$9449,$9444,$9445,$9452,$9451,$9454,$9455
    DC.W    $952A,$9529,$9524,$9525,$9512,$9511,$9514,$9515
    DC.W    $954A,$9549,$9544,$9545,$9552,$9551,$9554,$9555
    DC.W    $4AAA,$4AA9,$4AA4,$4AA5,$4A92,$4A91,$4A94,$4A95
    DC.W    $4A4A,$4A49,$4A44,$4A45,$4A52,$4A51,$4A54,$4A55
    DC.W    $492A,$4929,$4924,$4925,$4912,$4911,$4914,$4915
    DC.W    $494A,$4949,$4944,$4945,$4952,$4951,$4954,$4955
    DC.W    $44AA,$44A9,$44A4,$44A5,$4492,$4491,$4494,$4495
    DC.W    $444A,$4449,$4444,$4445,$4452,$4451,$4454,$4455
    DC.W    $452A,$4529,$4524,$4525,$4512,$4511,$4514,$4515
    DC.W    $454A,$4549,$4544,$4545,$4552,$4551,$4554,$4555
    DC.W    $52AA,$52A9,$52A4,$52A5,$5292,$5291,$5294,$5295
    DC.W    $524A,$5249,$5244,$5245,$5252,$5251,$5254,$5255
    DC.W    $512A,$5129,$5124,$5125,$5112,$5111,$5114,$5115
    DC.W    $514A,$5149,$5144,$5145,$5152,$5151,$5154,$5155
    DC.W    $54AA,$54A9,$54A4,$54A5,$5492,$5491,$5494,$5495
    DC.W    $544A,$5449,$5444,$5445,$5452,$5451,$5454,$5455
    DC.W    $552A,$5529,$5524,$5525,$5512,$5511,$5514,$5515
    DC.W    $554A,$5549,$5544,$5545,$5552,$5551,$5554,$5555

dest_cur:
        DC.L    0
;     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;     ~~                       Segment Data                         ~~
;     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

********************** FIN MODIFICATIONS COMPRESSEUR ***********************

end_msg:     DC.B  $a,$d," Compression termin‚e !",$7,$a,$d,$0
ppack1:      DC.B  $a,$d," Utiliser le compresseur de type 1, bye!",$0
bad_len:     DC.B  $a,$d," Ce fichier fait moins de 256 octets, bye !",$a,$d,$0
nopack:      DC.B  $a,$d," Compression in‚fficace, bye !",$a,$d,$0
errwrite:    DC.B  $a,$d," Erreur d'‚criture du fichier tarjet, bye !",$a,$d,$0
errOVlen:    DC.B  $a,$d," Erreur, d‚bordement de l'arbre en profondeur, bye!",$a,$d
errOvByte:   DC.B  $a,$d," D‚bordement de taille fichier, bye!",$a,$d,$0
KRITIK_WDK:  DC.B  $a,$d,">>> Erreur Tragique <<< Clef non d‚finie, Bye",$a,$a,$d,$0
gain1pc:     DC.B  $a,$a,$d," Pourcentage de compression Phase_1 : ",$0
gain2pc:     DC.B  $a,$d," Pourcentage de compression Phase_2 : ",$0
gaintpc:     DC.B  $a,$d," Pourcentage de compression totale  : ",$0
packing:     DC.B  $a,$d," La compression commence ....",$0
             even
B_LEN:       DC.L  $00040000         ; 256 K-Octets pour le compresseur.
C_LEN:       DC.L  $00020000         ; 128 K-Octets zone de compression.

I_LEN:       DC.L  $00000000         ; Nombre d'octet aprŠs Phase_1

GAIN1:       DC.L  $00000000         ; Gain du … la phase 1.
GAIN2:       DC.L  $00000000         ; Gain du … la phase 2.
HDNB:        DC.L  $00000000         ; Nombre de HEADER en TRAME.

NXTNOD:      DC.W  $0000             ; Prochain node … etre cr‚‚.
NBLEAVE:     DC.W  $0000             ; Nombre de feuilles de l'arbre.

HEADER:      DC.B  $00               ; Valeur du header.
PHASE_FLG:   DC.B  $00
ROOT:        DC.B  $00               ; Plus petite clef.
DEEPTH:      DC.B  $00               ; Plus grande clef.

DGPRT:       DC.B  $00               ;
             even
KEY_RET:     DC.W  $0000             ;       Voir la routine PRTHEX
HDSTR:       DC.L  $00000000         ;       pour informations sur :
ENDSTR:      DC.L  $00000000         ;    DGPRT, KEY_PRT, HDSTR et ENDSTR.
TOPRT:       DC.L  $00000000         ;

HDKEY:       DC.L  $00000000         ; Codage binaire de HEADER.
HDLG:        DC.L  $00000000         ; Longueur du codage de HEADER.

DVPC:        DC.L  $00000000         ; Dividende du pourcentage.
NMPC:        DC.L  $00000000         ; Num‚rateur du pourcentage.

;           Section reservation.
head_len:
             DC.L   0
Head:        BLK.L  $200

Occ1:        BLK.L  $100              ; Table des occurences simples.
Occ2:        BLK.L  $100              ; Table des occurences doubles.
Occ3:        BLK.L  $100              ; Table des occurences triples.
OccM:        BLK.L  $100              ; Table des occurences … repetition >3.
OccN:        BLK.L  $100              ; Table des occurences en tant que N-1.
OccG:        BLK.L  $101              ; Nombre d'octets I gagn‚s par la phase 1.

tot_len:
        DC.L    0
strlen:
        DC.B    $d,$a,'Taille Fichier: ',0
invvideo:
        DC.B    $1b,'q',0,0
str_nb:
        DC.B    '123456',0
        EVEN
nombre:
        DC.L    0
fin_cmp:
        DC.B    $d,$a,'Fin de compression',0
err_read:
        DC.B    $d,$a,'Fichier introuvable:',0
CLNWDK:
        DC.B    $1B,$45,$7,$0
RET:
        DC.B    $d,$a,0,0
string:
        DC.L    0

************************ FICHIERS LIEUX ******************

src_nom:
        DC.B    'E:\SECTE.ESS\'
nom_fic:
        BLK.B   14
        EVEN
tjt_name:
        DC.B    'E:\SECTE.ESS\LIEUX00.SYN',0
        EVEN
lentjt: dc.w    18
OBJETS:
N1:     DC.B    'DES00.O',0
N2:     DC.B    'LIEU00.O',0
N3:     DC.B    'OFPA00.O',0
N4:     DC.B    'ASON00.O',0
N5:     DC.B    'AIDE00.O',0
N6:     DC.B    'ANIC00.O',0
N7:     DC.B    'ANIS00.O',0
N8:     DC.B    'ANIM00.O',0
N9:     DC.B    'ANIP00A.O',0
NA:     DC.B    'ANIP00B.O',0
NB:     DC.B    'ANIP00C.O',0
        DC.B    'X',0                   ; Fin des Fichiers
        EVEN
ADNLIEU:    DC.L     N1,N2,N3,N4,N5,N6,N7,N8,N9,NA,NB,0
LENLIEU:    DC.W     3,4,4,4,4,4,4,4,4,4,4

tjt_adr:
        DC.L    0
tjt_hdl:
        DC.W    0
tjt_len:
        DC.L    0
tjt_pos:
        DC.L    0
src_adr:
        DC.L    0    
src_hdl:
        DC.W    0
src_len:
        DC.L    0
nbr_len:
        DC.W    0
nb_len:
        DC.W    0
cur_len:
        DC.W    0
tab_len:
        BLK.W   100
src_dep:
        DC.L    0
src_name:
        DC.L    0
ad_nom:
        DC.L    0
adr_cur:
        DC.L    0
buffer:                                 ; Buffer de chargement
        BLK.L   1000
