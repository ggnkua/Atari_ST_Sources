;SOURCE DE L'INTRO OYA SHIVO
;ASSEMBLE AVEC PROFIMAT


 CLR.W -(A7)
 PEA VOL3
 MOVE.W #$3D,-(A7)
 TRAP #1
 ADDA.L #8,A7
 TST.W D0
 BMI FIN
                                       ;LOAD FILE "VOL3"
 MOVE.W D0,D7
 PEA $1FD5E
 MOVE.L #$BB8,-(A7)
 MOVE.W D7,-(A7)
 MOVE.W #$3F,-(A7)
 TRAP #1
 ADDA.L #12,A7
 TST.L D0
 BMI FIN

 MOVE.W D7,-(A7)                       ;CLOSE FILE "VOL3"
 MOVE.W #$3E,-(A7)
 TRAP #1
 ADDQ.L #4,A7
 TST.W D0
 BMI FIN

 CLR.W -(A7)                           ;OPEN FILE "VOL4"
 PEA VOL4
 MOVE.W #$3D,-(A7)
 TRAP #1
 ADDA.L #8,A7
 TST.W D0
 BMI FIN

 MOVE.W D0,D7                          ;LOAD FILE "VOL4"
 PEA $26C10
 MOVE.L #$5DC0,-(A7)
 MOVE.W D7,-(A7)
 MOVE.W #$3F,-(A7)
 TRAP #1
 ADDA.L #12,A7
 TST.L D0
 BMI FIN

 MOVE.W D7,-(A7)                       ;CLOSE FILE "VOL4"
 MOVE.W #$3E,-(A7)
 TRAP #1
 ADDQ.L #4,A7
 TST.W D0
 BMI FIN

 MOVEQ #0,D0                           ;PASSAGE EN SUPERVISEUR
 BSR SUPER                             ;D0=VALEUR A EMPILER

 AND.W #$FB,$484                       ;TOUCHES INSONORES
 MOVE.B #$12,$FFFFFC02                 ;SOURIS INHIBEE

 BSR INST_COUNT

 MOVE.L $70,ADVECT
 MOVE.L #ROUTINE1,$70

 CLR.B $FF8201

 MOVE.W #1,$274B2                      ;MUSIQUE INHIBEE

 MOVE.L $44E,A5                        ;A5=ADRESSE ECRAN
 MOVE.L A5,SCREEN1                     ;SAUVEGARDEE DANS SCREEN1

 LEA PALETTE,A0
 LEA $FFFF8240,A1
 MOVE.W #$F,D0
SETCOLORS:
 MOVE.W (A0)+,(A1)+
 DBRA D0,SETCOLORS

 LEA SCREEN,A0                         ;A0=ADRESSE DESSIN
 MOVE.W #999,D0
 MOVE.L #BUFFER+5632,D1                ;CALCUL DE L'ADRESSE DU 2EME
 CLR.B D1                              ;ECRAN
 MOVE.L D1,SCREEN2                     ;SAUVEGARDE DANS SCREEN2
 MOVE.L D1,A1                          ;A1=CETTE ADRESSE

AFFICHE0:                              ;TRANSFERT DU DESSIN VERS
 MOVE.L (A0),(A5)+                     ;L'ECRAN NORMAL (A5)
 MOVE.L (A0)+,(A1)+                    ;ET LE 2EME ECRAN (A1)
 MOVE.L (A0),(A5)+
 MOVE.L (A0)+,(A1)+
 MOVE.L (A0),(A5)+
 MOVE.L (A0)+,(A1)+
 MOVE.L (A0),(A5)+
 MOVE.L (A0)+,(A1)+
 MOVE.L (A0),(A5)+
 MOVE.L (A0)+,(A1)+
 MOVE.L (A0),(A5)+
 MOVE.L (A0)+,(A1)+
 MOVE.L (A0),(A5)+
 MOVE.L (A0)+,(A1)+
 MOVE.L (A0),(A5)+
 MOVE.L (A0)+,(A1)+
 DBRA D0,AFFICHE0


 MOVE.W #2,$274B2                      ;MUSIQUE AUTORISEE (Nø1)
 LEA FONTE,A5                          ;A5=ADRESSE DE LA FONTE

BOUCLE0:
 LEA MSG,A6                            ;A6=ADRESSE DU MESSAGE

BOUCLE:

 MOVEQ #0,D0
 MOVE.B (A6)+,D0                       ;DO=CODE ASCII DU CARACTERE
 TST.W D0                              ;SI NUL FIN DU MESSAGE
 BEQ.S BOUCLE0
 SUB.W #32,D0                          ;CALCUL DE L'ADRESSE OU EST
 LSL.W #8,D0                           ;STOCKE LE CARACTERE (256 OCTETS
 ADD.L A5,D0                           ;PAR CARACTERE)

 MOVE.L D0,A0                          ;A0=CETTE ADRESSE
 LEA LBUF,A1                           ;A1=ADRESSE DU BUFFER UTILISE POUR
 MOVEQ #7,D0                           ;LE SCROLLING

TRANSFERT:                             ;TRANSFERT DU CARACTERE VERS LE
 MOVE.L (A0)+,(A1)+                    ;TAMPON DE SCROLLING
 MOVE.L (A0)+,(A1)+
 MOVE.L (A0)+,(A1)+
 MOVE.L (A0)+,(A1)+
 MOVE.L (A0)+,(A1)+
 MOVE.L (A0)+,(A1)+
 MOVE.L (A0)+,(A1)+
 MOVE.L (A0)+,(A1)+
 DBRA D0,TRANSFERT

 MOVEQ #7,D0                           ;8 SCROLLINGS A FAIRE (2 PIXELS
                                       ;A LA FOIS)
MAIN:
 MOVE.W D0,POINTEUR                    ;SAUVEGARDE DU POINTEUR DE BOUCLE
                                       ;(NOMBRE DE SCROLLINGS)
 LEA FLAG,A0                           ;TEST DU FLAG D'ECRAN
 TST.W (A0)
 BEQ.S SC2
 MOVE.L SCREEN1,A4                     ;NON NUL:ON TRAVAILLE SUR L'ECRAN
 CLR.W (A0)                            ;NUMERO 1,ET ON ANNULLE LE FLAG
 BRA MAINSUITE

SC2:                                   ;FLAG NUL
 MOVE.L SCREEN2,A4                     ;ON TRAVAILLE SUR L'ECRAN Nø2
 MOVE.W #$FFFF,(A0)                    ;ET ON MET LE FLAG A -1

MAINSUITE:                             ;A4=ADRESSE DE L'ECRAN DE TRAVAIL
 MOVE.L A4,A3                          ;A3=ADRESSE DU FOND A PRESERVER
 ADD.L #24640,A3                       ;DANS L'ECRAN DE TRAVAIL

 BSR HSCROLL                           ;SCROLLING DU MESSAGE:A LIEUX DANS
                                       ;UN BUFFER
 MOVE.L A3,A1                          ;A1=ADRESSE DU FOND SUR ECRAN DE TRAVAIL
 MOVE.L #SCREEN+24640,A0               ;A0=ADRESSE DU FOND DANS LE PROGRAMME
 MOVE.W #179,D0                        ;ON REAFFICHE LE FOND SUR L'ECRAN
TRANSFERT2:                            ;DE TRAVAIL
 MOVE.L (A0)+,(A1)+
 MOVE.L (A0)+,(A1)+
 MOVE.L (A0)+,(A1)+
 MOVE.L (A0)+,(A1)+
 MOVE.L (A0)+,(A1)+
 MOVE.L (A0)+,(A1)+
 MOVE.L (A0)+,(A1)+
 MOVE.L (A0)+,(A1)+
 DBRA D0,TRANSFERT2

 LEA X,A0                              ;A0 POINTE LES VARIABLE POUR SPRITE
 CLR.W (A0)+                           ;X=0
 MOVE.W #2,(A0)+                       ;Y=2
 MOVE.W #32,(A0)+                      ;HAUTEUR=32 LIGNES
 MOVE.W #20,(A0)+                      ;LARGEUR=20 COLONNES DE 16 PIXELS
 MOVE.L #BUFFER,(A0)+                  ;ADRESSE SPRITE=BUFFER SCROLLING
 MOVE.L A3,(A0)                        ;ADRESSE ECRAN:ADRESSE FOND SUR ECRAN
 BSR SPRITE                            ;DE TRAVAIL,ON AFFICHE LE MESSAGE
                                       ;SCROLLE EN SPRITE
 LEA X,A0
 CLR.L (A0)+                           ;X=Y=0
 MOVE.W #36,(A0)+                      ;HAUTEUR=36 PIXELS
 MOVE.W #2,(A0)+                       ;LARGEUR=2*16 PIXELS
 MOVE.L #BONHOMME,(A0)                 ;ADRESSE SPRITE=BONHOMME
 BSR SPRITE                            ;ADRESSE ECRAN INCHANGEE,ON AFFICHE
                                       ;LE BONHOMME EN SPRITE
 LEA X,A0
 MOVE.W #288,(A0)                      ;IDEM MAIS EN X=288
 BSR SPRITE
                                       ;D0=ADRESSE ECRAN DE TRAVAIL
 MOVE.L A4,D0                          ;ON INSTALLE L'ECRAN DE TRAVAIL
 LSR.W #8,D0                           ;C'EST A DIRE QUE C'EST LUI
 MOVE.B D0,$FFFF8203                   ;QU'ON VA VOIR DESORMAIS...
 SWAP D0
 MOVE.B D0,$FFFF8201

 MOVE.B $FFFFFC02,D0                   ;D0=CODE TOUCHE PRESSEE

 CMP.B #$6D,D0                         ;TOUCHE 1 DU PAVE NUMERIQUE ?
 BEQ MUSIK1                            ;OUI,ON INSTALLE MUSIQUE Nø1
 CMP.B #$6E,D0                         ;TOUCHE 2 ?
 BEQ MUSIK2
 CMP.B #$6F,D0                         ;TOUCHE 3 ?
 BEQ MUSIK3
 CMP.B #$39,D0                         ;BARRE ESPACE ?
 BEQ FIN_PRG                           ;ON SORT DU PROGRAMME

MAIN_END:
 MOVE.W POINTEUR,D0                    ;RECUPERE POINTEUR DE BOUCLE
 DBRA D0,MAIN                          ;(NOMBRE DE SCROLLINGS)
 BRA BOUCLE                            ;ON RECOMMENCE

FIN_PRG:                               ;SORTIE DU PROGRAMME

 MOVE.W #1,$274B2                      ;MUSIQUE INHIBEE

 MOVE.L SCREEN1,D0                     ;REINSTALLATION DE L'ECRAN NORMAL
 LSR.W #8,D0
 MOVE.B D0,$FFFF8203
 SWAP D0
 MOVE.B D0,$FFFF8201

 MOVE.L ADVECT,$70                     ;DESINSTALLATION DES ROUTINES VBL

 MOVE.W SR,-(A7)
 OR.W #$2700,SR                        ;PAS D'INTERRUPTIONS

 CLR.B $FFFA1B
 MOVE.L VECT_MFP,$120

 MOVE.W (A7)+,SR                       ;INTERRUPTIONS AUTORISEES

 MOVE.B #8,$FFFFFC02                   ;SOURIS AUTORISEE

 MOVE.L PILE,D0                        ;RETOUR EN MODE UTILISATEUR
 BSR SUPER

FIN:

 CLR.W -(A7)                           ;RETOUR AU GEM
 TRAP #1

MUSIK1:                                ;INSTALLE MUSIQUE Nø1
 MOVE.W #2,$274B2
 BRA MAIN_END
MUSIK2:
 MOVE.W #7,$274B2                      ;IDEM Nø2
 BRA MAIN_END
MUSIK3:
 MOVE.W #8,$274B2                      ;IDEM Nø3
 BRA MAIN_END


INST_COUNT:

 MOVE.W SR,-(A7)
 OR.W #$2700,SR
 LEA $FFFFFA01,A0

 BCLR #0,$12(A0)
 BCLR #0,$E(A0)
 BCLR #0,$A(A0)
 BCLR #0,6(A0)

 MOVE.L $120,VECT_MFP                  ;SAUVEGARDE VECTEUR INITIAL
 MOVE.L #ROUTINE2,$120                 ;INSTALLE NOUVEAU VECTEUR

 CLR.B $1A(A0)

 MOVE.B #2,$20(A0)

 BSET #0,6(A0)
 BSET #0,$12(A0)
 BCLR #5,8(A0)
 BCLR #4,8(A0)

 RTE

ROUTINE1:                              ;ROUTINE VBL
 MOVEM.L D0-A6,-(A7)
 CLR.W COUNT                           ;COMPTEUR DE LIGNES
 CLR.W COUNT4                          ;COMPTEUR BOUDIN
 MOVE.W COUNT2,D0                      ;COMPTEUR POUR TABLE ALTITUDE
 ADDQ.W #2,D0
 CMP.W #88,D0
 BLE.S VSUITE
 MOVEQ #0,D0
VSUITE:
 MOVE.W D0,COUNT2
 LEA ALT,A0
 MOVE.W (A0,D0.W),COUNT3               ;COMPTEUR LIGNE DU BOUDIN
 MOVE.B #8,$FFFA1B
 LEA COLTAB,A0                         ;INSTALLE PALETTE VERTE
 MOVEM.L (A0),D0-D4
 LEA $FF8242,A0
 MOVEM.L D0-D4,(A0)
 JSR $1FD5E
 MOVEM.L (A7)+,D0-A6
 RTE

ROUTINE2: 
 MOVEM.L D0-D4/A0,-(A7)

 MOVE.W COUNT,D0
 ADDQ.W #2,D0
 CMP.W #142,D0
 BNE.S MSUITE

 CLR.B $FFFA1B
 CLR.W $FF8240
 LEA COLTAB2,A0                        ;INSTALLE PALETTE BLEUE
 MOVEM.L (A0),D0-D4
 LEA $FF8242,A0
 MOVEM.L D0-D4,(A0)
 BCLR #0,$FFFA0F
 MOVEM.L (A7)+,D0-D4/A0
 RTE

MSUITE:
 MOVE.W D0,COUNT
 CMP.W COUNT3,D0
 BGE.S MSUITE2

MSUITE1:
 CLR.W $FF8240
 MOVEM.L (A7)+,D0-D4/A0
 BCLR #0,$FFFA0F
 RTE

MSUITE2:
 MOVE.W COUNT4,D0
 CMP.W #14,D0
 BGE.S MSUITE1
 ADDQ.W #2,D0
 MOVE.W D0,COUNT4
 LEA BOUDIN,A0
 MOVE.W (A0,D0.W),$FF8240
 MOVEM.L (A7)+,D0-D4/A0
 BCLR #0,$FFFA0F
 RTE

HSCROLL:                               ;ROUTINE DE SCROLLING HORIZONTAL
 LEA BUFFER+5120,A0                    ;A0=POINTE LA FIN DU BUFFER DE
                                       ;SCROLLING
 MOVEA.L A0,A1                         ;IDEM POUR A1
 
 MOVE.W #31,D7                         ;D7=NOMBRE DE LIGNES

 LEA LBUF+256,A2                       ;A2 POINTE FIN DU BUFFER OU EST
                                       ;STOCKE LE DERNIER CARACTERE
HILOOP:                                ;BOUCLE LIGNE
 MOVEQ #19,D6                          ;D6=NOMBRE DE GROUPES DE 16 PIXELS (20)
 MOVE.L -(A2),D4                       ;INSTALLATION DU 'MASQUE' DE FIN
 ROL.L #2,D4                           ;DE LIGNE
 MOVE.L D4,(A2)                        ;ET ROTATION DU CARACTERE
 MOVE.L -(A2),D5                       ;D4 CONTIENT LES PLANS 3 ET 4
 ROL.L #2,D5                           ;D5 LES PLANS 1 ET 2
 MOVE.L D5,(A2)
 ANDI.L #$00030003,D4                  ;DONT ON NE GARDE QUE LES 2 POINTS
 ANDI.L #$00030003,D5                  ;DE DROITE

HJLOOP:                                ;BOUCLE COLONNES
 MOVEQ #0,D0                           ;INITIALISE REGISTRES
 MOVEQ #0,D1
 MOVEQ #0,D2
 MOVEQ #0,D3
 MOVE.W -(A0),D0                       ;D0=PLAN 4
 MOVE.W -(A0),D1                       ;D1=PLAN 3
 MOVE.W -(A0),D2                       ;D2=PLAN 2
 MOVE.W -(A0),D3                       ;D3=PLAN 1
 ROL.L #2,D0                           ;ROTATION DES PLANS
 ROL.L #2,D1
 ROL.L #2,D2
 ROL.L #2,D3
 OR.W D4,D0                            ;AJOUT DES PIXELS DE LA COLONNES
 SWAP D4                               ;SUIVANTE,PLAN 4
 OR.W D4,D1                            ;PLAN 3
 OR.W D5,D2                            ;PLAN 2
 SWAP D5
 OR.W D5,D3                            ;PLAN 1
 MOVE.W D0,-(A1)                       ;SAUVEGARDE DES NOUVEAUX PLANS 4
 MOVE.W D1,-(A1)                       ;3
 MOVE.W D2,-(A1)                       ;2
 MOVE.W D3,-(A1)                       ;1
 SWAP D0                               ;SAUVEGARDE DES PIXELS DE GAUCHE
 SWAP D1
 SWAP D2
 SWAP D3
 MOVE.W D1,D4                          ;PLAN 3
 SWAP D4
 MOVE.W D0,D4                          ;PLAN 4
 MOVE.W D3,D5                          ;PLAN 1
 SWAP D5
 MOVE.W D2,D5                          ;PLAN 2
 DBRA D6,HJLOOP                        ;FIN DE LA COLONNE
 DBRA D7,HILOOP                        ;FIN DE LA LIGNE
 RTS

SPRITE:                                ;ROUTINE DE SPRITE
 MOVEQ #0,D0
 MOVE.W Y,D0                           ;D0=Y
 MOVE.W X,D1                           ;D1=X
 MOVE.L AD,A0                          ;A0=ADRESSE DU SPRITE

 MOVE.W D0,D2
 LSL.W #2,D2                           ;CALCUL DE L'ADRESSE DE LA LIGNE
 ADD.W D2,D0
 LSL.W #5,D0                           ;D0=Y*160

 MOVEQ #0,D7
 MOVE.W D1,D7                          ;CALCUL DE L'ADRESSE DE LA COLONNE
 LSR.W #4,D1
 LSL.W #3,D1
 ADD.W D1,D0
 ADD.L ECRAN,D0                        ;D0=ADRESSE POINT SUPERIEUR GAUCHE
 MOVE.L D0,A1                          ;DU SPRITE,SAUVE DANS A1
 AND.W #15,D7                          ;D7=NOMBRE DE ROTATIONS A FAIRE
 BEQ.S NUL                             ;SI CORRESPOND A UNE COLONNE,PAS DE
                                       ;ROTATION A FAIRE:PLUS RAPIDE
 MOVE.W H,D6                           ;D6=HAUTEUR
 SUBQ.W #1,D6

SP0:                                   ;BOUCLE LIGNES

 MOVE.W L,D5                           ;D5=LARGEUR
 SUBQ.W #1,D5

SP1:                                   ;BOUCLE COLONNES

 MOVEQ #0,D0                           ;INITIALISE REGISTRES
 MOVEQ #0,D1
 MOVEQ #0,D2
 MOVEQ #0,D3

 MOVE.W (A0)+,D0                       ;D0=PLAN 1
 MOVE.W (A0)+,D1                       ;PLAN 2
 MOVE.W (A0)+,D2                       ;PLAN 3
 MOVE.W (A0)+,D3                       ;PLAN 4

 MOVE.L D0,D4                          ;CALCUL DU MASQUE
 OR.W D1,D4
 OR.W D2,D4
 OR.W D3,D4
 NOT.L D4

 ROR.L D7,D0                           ;ROTATION DES PLANS
 ROR.L D7,D1
 ROR.L D7,D2
 ROR.L D7,D3
 ROR.L D7,D4                           ;ET DU MASQUE

 AND.W D4,(A1)                         ;AFFICHAGE DES PLANS
 OR.W D0,(A1)+
 AND.W D4,(A1)
 OR.W D1,(A1)+
 AND.W D4,(A1)
 OR.W D2,(A1)+
 AND.W D4,(A1)
 OR.W D3,(A1)+

 SWAP D0                               ;RECUPERATION DES PIXELS SORTIS
 SWAP D1                               ;DE LA COLONNE PAR LA ROTATION
 SWAP D2
 SWAP D3
 SWAP D4

 AND.W D4,(A1)                         ;AFFICHAGE PLANS SUR COLONNE SUIVANTE
 OR.W D0,(A1)+
 AND.W D4,(A1)
 OR.W D1,(A1)+
 AND.W D4,(A1)
 OR.W D2,(A1)+
 AND.W D4,(A1)
 OR.W D3,(A1)+

 SUBQ.L #8,A1                          ;A1 POINTE CETTE COLONNE SUIVANTE
 DBF D5,SP1                            ;FIN DE LA COLONNE
 
 MOVEQ.L #0,D0
 MOVE.W L,D0
 LSL.W #3,D0
 ADD.L #160,A1                         ;A1 POINTE LA LIGNE SUIVANTE
 SUB.L D0,A1
 DBF D6,SP0                            ;FIN DE LA LIGNE

 RTS

NUL:                                   ;IDEM MAIS PAS DE ROTATION
                                       ;DONC SUR UNE SEULE COLONNE A LA FOIS
 MOVE.W H,D6
 SUBQ.W #1,D6

SP0L:

 MOVE.W L,D5
 SUBQ.W #1,D5

SP1L:

 MOVE.W (A0)+,D0
 MOVE.W (A0)+,D1
 MOVE.W (A0)+,D2
 MOVE.W (A0)+,D3

 MOVE.W D0,D4
 OR.W D1,D4
 OR.W D2,D4
 OR.W D3,D4
 NOT.W D4

 AND.W D4,(A1)
 OR.W D0,(A1)+
 AND.W D4,(A1)
 OR.W D1,(A1)+
 AND.W D4,(A1)
 OR.W D2,(A1)+
 AND.W D4,(A1)
 OR.W D3,(A1)+

 DBF D5,SP1L
 
 MOVEQ.L #0,D0
 MOVE.W L,D0
 LSL.W #3,D0
 ADD.L #160,A1
 SUB.L D0,A1
 DBF D6,SP0L

 RTS

SUPER:                                 ;PASSAGE EN SUPERVISEUR
 MOVE.L D0,-(A7)
 MOVE.W #$20,-(A7)
 TRAP #1
 ADDQ.L #6,A7
 LEA PILE,A0                           ;SAUVEGARDE PILE SUPERVISEUR
 MOVE.L D0,(A0)
 RTS

 DATA

PILE: DC.L 0                           ;PILE SUPERVISEUR

ADVECT:  DC.L 0                        ;ADRESSE FIN DE TABLE VBL

VECT_MFP:                              ;VECTEUR MFP ORIGINAL
 DC.L 0

X:     DC.W 0                          ;DEBUT VARIABLES SPRITES
Y:     DC.W 0
H:     DC.W 0                          ;HAUTEUR
L:     DC.W 0                          ;LARGEUR (NBRE DE FOIS 16 PIXELS)
AD:    DC.L 0                          ;ADRESSE DU SPRITE
ECRAN: DC.L 0                          ;ADRESSE DE L'ECRAN

FLAG:    DC.W 0                        ;FLAG POUR CHOIX ECRAN DE TRAVAIL
SCREEN1: DC.L 0                        ;ECRAN NORMAL
SCREEN2: DC.L 0                        ;SECOND ECRAN

PALETTE:                               ;PALETTE
 IBYTES PALETTE.DAT,32

COLTAB:                                ;PALETTE DEBUT DE L'ECRAN
 DC.W $010,$020,$030,$040,$450,$550,$740,$100
COLTAB2:                               ;PALETTE FIN DE L'ECRAN
 DC.W $001,$002,$003,$004,$005,$006,$007,$100

ALT:
 DC.W 02,02,02,04
 DC.W 06,08,10,14
 DC.W 18,22,26,32
 DC.W 38,44,50,58
 DC.W 66,74,84,92
 DC.W 102,112
 DC.W 124
 DC.W 112,102
 DC.W 92,84,74,66
 DC.W 58,50,44,38
 DC.W 32,26,22,18
 DC.W 14,10,08,06
 DC.W 04,02,02,02

BOUDIN: DC.W $100,$300,$500,$700,$500,$300,$100,0

COUNT:                                 ;COMPTEUR HBL
 DC.W 0
COUNT2:
 DC.W 0
COUNT3:
 DC.W 0
COUNT4:
 DC.W 0

POINTEUR:                              ;NOMBRE DE SCROLLINGS HORIZONTAUX
 DC.W 0

VOL3: DC.B 'VOL3',0                    ;FICHIERS
VOL4: DC.B 'VOL4',0

MSG: DC.B 'OYA SHIVO IS PROUD TO PRESENT HIS FIRST INTRO AS MEMBER'
     DC.B ' OF THE REPLICANTS....THE REPLICANTS ARE: R.AL,COBRA'
     DC.B ',DOM,RANK XEROX,EXCALIBUR,HANNIBAL,KNIGHT 2001'
     DC.B ',GO HAINE,THE SNAKE,AND,LAST BUT NOT LEAST,OYA SHIVO'
     DC.B '....THE REPLICANTS NOW BELONG TO THE UNION,HI TO THE '
     DC.B 'OTHER MEMBERS OF THE UNION WHO ARE: TEX,TNT-CREW,LEVEL 16,'
     DC.B 'HOWDY,DELTA FORCE AND THE SOFTRUNNER GROUP....'
     DC.B 'PRESS 1 TO 3 TO CHANGE MUSIC,SPACE TO LOAD GAME....'
     DC.B 'CODE AND GRAPHICS BY OYA SHIVO,MUSIC FROM THE GAME "ECO"'
     DC.B '....HAVE FUN WITH THE REPLICANTS !!!!!....'
     DC.B 0
     DC.W 0

SCREEN:                                ;DESSIN
 IBYTES MAIDEN.DAT,32000

BONHOMME:                              ;SPRITE BONHOMME
 IBYTES SPRITES.DAT

LBUF:                                  ;BUFFER POUR CARACTERE
 DEFS 256,0


FONTE:                                 ;FONTE
 IBYTES FONTE.DAT

BUFFER:                                ;POINTEUR SUR FIN DU PROGRAMME
 DC.L 0                                ;BUFFER POUR SCROLLING HORIZONTAL

 END
 