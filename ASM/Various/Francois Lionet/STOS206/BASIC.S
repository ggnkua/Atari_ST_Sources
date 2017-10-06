

	Output	Stos\Basic208.Bin

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;09/11/89;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

          bra cold

;-------> Buffer pour le menage / securite de pile
bmenage:	ds.l 64
;-------> Pile basic
          ds.l $100
pile:     equ *

;-----------------------------------------    --- ----- ---   ---    -------
;   -----------------------------------      |      |  |   | |
;   |       DONNEES DE L'EDITEUR      |       ---   |  |   |  ---
;   -----------------------------------          |  |  |   |     |
;-----------------------------------------    ---       ---   ---    -------
          dc.b "Bdebut"       ;repere: adresse de DEBUT du basic
          even
; DEFINITION DE LA WORKSTATION
work:     ds.b $180
; BUFFER DE DECONVERSION FLOAT
defloat:  ds.b 256
; BUFFER DE CALCUL
          ds.b 256
bufcalc:  equ *
; BUFFER D'ENTREE/SORTIE
buffer:   ds.b 512
; BUFFER DE TOKENISATION
buftok:   ds.b 736
fintok:   ds.b 32          ;securite de tokenisation!
;BUFFER DE SAUVEGARDE SEARCHE/SEARCHE NEXT
bs:       ds.b 84
;BUFFER DU FOLLOW
fb:       ds.b 120
maxfb:equ *
          ds.b 8           ;securite!
fl:       dc.b 30,"Line ",0
          dc.b 30,"Ligne ",0
fl1:      dc.b ": ",0
fl2:      dc.b "=",0
fl3:      dc.b ", ",0
fl4:      dc.b "          ",0
; SURE (Y/N) ?
ct:       dc.b 13,10,"Sure ? (Y/N) "
          dc.b 0
          even
;BUFFER D'ECHANGE AVEC LA DISQUETTE
dta:      ds.b 48
;STOCKAGE DES NOMS POUR LE DISQUE
name1:    equ buffer
name2:    equ buffer+64
bas:      dc.b ".BAS",0
bak:      dc.b ".BAK",0
etoile:   dc.b "*.*",0
acb:      dc.b ".ACB",0
; NOMS DE RECONNAISSANCE DES FICHIERS
nomdisk:  dc.b "neo",0,"pi1",0,"pi2",0,"pi3",0
          dc.b "mbk",0,"mbs",0,"prg",0,"var",0,"asc",0
; FABRICATION DU .PRG
prg:      dc.b ".PRG",0
prgrun:   dc.b "RUN__206.BIN",0
stos:     dc.b "STOS\",0
prgmes:   dc.b "Insert a disk which has a",13,10
          dc.b "STOS folder into drive,",13,10
          dc.b "then press any key...",13,10,0
          dc.b "Introduisez dans le lecteur un",13,10
          dc.b "disque contenant le dossier STOS,",13,10
          dc.b "puis pressez une touche...",13,10,0
          even
;MESSAGE DU DIRECTORY
msd0:     dc.b "Drive ",0,"Lecteur ",0
msd1:     dc.b ", path: ",0,", dir: ",0
msd2:     dc.b " bytes used.",0," octets utilis‚s.",0
msd3:     dc.b " byte used",0," octet utilise",0
ssdir1:   dc.b "* -----------> ",0
          even
; CONFIG.ENV / AUTOEXEC.BAS
cfenv:    dc.b "stos\editor.env",0
cfau:     dc.b "autoexec.bas",0
cfrau:    dc.b "run ",34,"autoexec",34,"`",0
cfld:     dc.b 13,"Loading : ",0,13,"Je charge : ",0
cfef:     dc.b 13,"                         ",13,0
          even
;FLOAD/FSAVE messages
fs:       dc.b "          SAVE file.",0
          dc.b "      SAUVER un fichier.",0
fc:       dc.b "          LOAD file.",0
          dc.b "      CHARGER un ficher.",0
          even
;FILE SELECTOR
fswind:   dc.w 1,3,2,34,21    
          dc.w 2,23,2,34,21
          dc.w 3,23,2,34,21
fst:      dc.b "FILE SELECTOR",0
          dc.b "SELECTEUR DE FICHIER",0
fst1:     dc.b "     UP     ",0
          dc.b "    HAUT    ",0
fst2:     dc.b "    DOWN    ",0
          dc.b "    BAS     ",0
fst3:     dc.b "PREVIOUS",0
          dc.b "ARRIERE ",0
fst4:     dc.b "  DIR.  ",0
          dc.b "  DIR.  ",0
fst5:     dc.b "  QUIT  ",0
          dc.b "QUITTER ",0
fst6:     dc.b " RETURN ",0
          dc.b "   OK   ",0
fst7:     dc.b "            ",0
fst8:     dc.b "                                "
          dc.b "                               ",0
fsr:      dc.b 3,32,3,0
          even
fsc:      dc.w 0,2,16,15
          dc.w 16,2,10,3
          dc.w 16,5,10,3
          dc.w 16,8,10,3
          dc.w 16,11,10,3
          dc.w 16,14,16,3
fstext:   dc.l fst1
          dc.w 2,2
          dc.l fst2
          dc.w 2,16
          dc.l fst3
          dc.w 17,3
          dc.l fst4
          dc.w 17,6
          dc.l fst5
          dc.w 17,9
          dc.l fst6
          dc.w 17,12
          dc.l fst7
          dc.w 18,15
          dc.l fst8
          dc.w 0,17
fsdriv:   dc.w 26,2,29,2
          dc.w 26,5,29,5
          dc.w 26,8,29,8
          dc.w 26,11,29,11
          even
;MESSAGE DE RECONNAISSANCE DU BASIC: FICHIER SOURCE BASIC
cbs:      dc.b "Lionpoulos"
;MESSAGE DE RECONNAISSANCE D'UN FICHIER BANQUES BASIC
cbk:      dc.b "Lionpoubnk"
;MESSAGE DE RECONNAISSANCE D'UN FICHIER DE VARIABLES
cvr:      dc.b "Lionpouvar"
          even
;TABLE DES DIX FICHIERS OUVERTS SUR LA DISQUETTE
fha:      equ 2     ;numero de handle.w
fhl:      equ 4     ;taille du fichier.l
fht:      equ 8     ;taille totale du champ.w
fhc:      equ 10    ;taille des champs.w
fhs:      equ 42    ;adresse des variables des champs.l
tfiche:   equ 106   ;106 octets par fichier
fichiers: ds.b tfiche*10
          even
; MESSAGE DE BIENVENUE
w:        dc.b 10,"STOS",191," BASIC V 2.8",10,10,0
          dc.b "By F. Lionet & C. Sotiropoulos",10,0
          dc.b 189," 1988 Jawx / Mandarin",10,0
          dc.b "All Rights Reserved.",10,0,255
w1:       dc.b 10,"BASIC STOS",191," V 2.8",10,10,0
          dc.b "Par F. Lionet et C. Sotiropoulos",10,0
          dc.b 189," 1988 Jawx / Mandarin",10,0
          dc.b "Tous droits r‚serv‚s.",10,0,255
w2:       dc.b " Bytes Free.",10,10,13,0
          dc.b " Octets libres.",10,10,13,0
          even
;COULEURS PAR DEFAUT
pd:       dc.w $000,$700,$070,$000,$770,$420,$430,$450
          dc.w $555,$333,$733,$373,$773,$337,$737,$377
db:       dc.w $203,$157      ;0
          dc.w $000,$666
          dc.w $666,$000
          dc.w $500,$666
          dc.w $030,$666      ;3
          dc.w $666,$020
          dc.w $004,$664
          dc.w $665,$113
          dc.w $266,$400      ;7
          dc.w $706,$077
          dc.w $157,$603
          dc.w $213,$652
          dc.w $413,$055      ;11
          dc.w $105,$263
dh:       dc.w 0,1,0,1,0,1,0,1,0,1,0,1
;FLASH DU CURSEUR PAR DEFAUT
fd:       dc.b "(000,2)(220,2)(440,2)(550,2)(660,2)(770,2)(772,2)(774,2)"
          dc.b "(776,2)(777,2)(557,2)(446,2)(335,2)(113,2)(002,2)(001,2)",0
          even
;FENETRES DE L'EDITEUR
fe:       dc.w 0,0,1,0,4,40,21,1,0     ;0:fond partiel
          dc.w 0,0,2,0,4,80,21,1,0
          dc.w 0,0,3,0,2,80,23,1,0
          dc.w 1,1,1,0,4,40,11,1,0     ;1:fenetre moitie #1
          dc.w 1,1,2,0,4,80,11,1,0
          dc.w 1,1,1,0,4,80,23,1,0
          dc.w 2,1,1,0,15,40,10,1,0    ;2:fenetre moitie #2
          dc.w 2,1,2,0,15,80,10,1,0
          dc.w 2,1,1,0,27,80,23,1,0
          dc.w 3,1,1,0,4,20,11,1,0     ;3:fenetre quart #1
          dc.w 3,1,2,0,4,40,11,1,0
          dc.w 3,1,1,0,4,40,23,1,0
          dc.w 4,1,1,20,4,20,11,1,0    ;4:fenetre quart #2
          dc.w 4,1,2,40,4,40,11,1,0
          dc.w 4,1,1,40,4,40,23,1,0
          dc.w 5,1,1,0,15,20,10,1,0    ;5:fenetre quart #3
          dc.w 5,1,2,0,15,40,10,1,0
          dc.w 5,1,1,0,27,40,23,1,0
          dc.w 6,1,1,20,15,20,10,1,0   ;6:fenetre quart #4
          dc.w 6,1,2,40,15,40,10,1,0
          dc.w 6,1,1,40,27,40,23,1,0
          dc.w 14,7,1,0,5,40,19,0,1    ;7:fenetre HELP
          dc.w 14,7,2,20,5,40,19,0,1
          dc.w 14,7,2,20,16,40,19,0,1
          dc.w 15,1,1,0,0,40,4,1,0     ;8: fenetre de fonction
          dc.w 15,1,2,0,0,80,4,1,0
          dc.w 15,1,1,0,0,80,4,1,0
          dc.w 0,0,1,0,1,40,24,1,0     ;9: fond partiel menu UNE LIGNE
          dc.w 0,0,2,0,1,80,24,1,0
          dc.w 0,0,3,0,1,80,24,1,0
          dc.w 15,0,1,0,0,40,1,1,0     ;10: fenetre de menu UNE LIGNE
          dc.w 15,0,2,0,0,80,1,1,0
          dc.w 15,0,3,0,0,80,1,1,0
          dc.w 0,0,1,0,2,40,23,1,0     ;11: fond partiel menu DEUX LIGNES
          dc.w 0,0,2,0,2,80,23,1,0
          dc.w 0,0,3,0,2,80,23,1,0
          dc.w 15,0,1,0,0,40,2,1,0     ;12: fenetre de menus DEUX LIGNES
          dc.w 15,0,2,0,0,80,2,1,0
          dc.w 15,0,3,0,0,80,2,1,0
;TABLE DES ECRAN A L'AUTRE POUR MULTI ET FULL
tt:       dc.b 0,255,0,0,0
          dc.b 0,0,0,0,0
          dc.b 1,2,255,0,0
          dc.b 1,5,6,255,0
          dc.b 3,4,5,6,255
ps:       dc.b 255,0,0,0      ;origine 0->0
          dc.b 0,0,0,0
          dc.b 1,2,255,0      ;->2
          dc.b 1,5,6,255      ;->3
          dc.b 3,4,5,6        ;->4
          dc.b 0,0,0,0
          dc.b 0,0,0,0
          dc.b 0,0,0,0
          dc.b 0,0,0,0
          dc.b 0,0,0,0
          dc.b 0,255,0,0      ;origine 2->0
          dc.b 0,0,0,0
          dc.b 255,0,0,0      ;->2
          dc.b 5,6,255,0      ;->3
          dc.b 3,4,5,6        ;->4
          dc.b 0,255,0,0      ;origine 3->0
          dc.b 0,0,0,0
          dc.b 2,255,0,0      ;->2
          dc.b 255,0,0,0      ;->3
          dc.b 3,4,255,0      ;->4
          dc.b 0,255,0,0      ;origine 4->0
          dc.b 0,0,0,0
          dc.b 1,2,255,0      ;->2
          dc.b 1,255,0,0      ;->3
          dc.b 255,0,0,0      ;->4
; tfenecran:dc.b 0,2,2,4,4,4,4  ;fen ---> ecran par defaut
tb:       dc.b 0,1,2,1,2,3,4  ;conversion fenetre reelle/fen utilisateur
tc:       dc.b 0,-1,-1,-1,-1
          dc.b 0,-1,-1,-1,-1
          dc.b 0,1,2,-1,-1
          dc.b 0,1,-1,5,6
          dc.b 0,3,4,5,6
          even
; TABLE D'ACTIVATION MULTIPLE DES FENETRES, POUR EFFACR HELP
effachelp:dc.w 0,-1           ;plein ecran
          dc.w -1
          dc.w 1,2,-1         ;multi 2
          dc.w 1,5,6,-1       ;multi 3
          dc.w 3,4,5,6,-1     ;multi 4
          even
; TABLE DES ZONES EN FONCTION DES MODES D'ECRAN
modezone: dc.w 11,0,320,32,200,0,0,0,0,0,0,0,0,0,0,0,0,-1
          dc.w 11,0,640,32,200,0,0,0,0,0,0,0,0,0,0,0,0,-1
          dc.w 11,0,640,32,400,0,0,0,0,0,0,0,0,0,0,0,0,-1
          dc.w 11,8,311,40,103,8,311,120,191,0,0,0,0,0,0,0,0,-1
          dc.w 11,8,639,40,103,8,639,120,191,0,0,0,0,0,0,0,0,-1
          dc.w 11,8,639,40,207,8,639,224,391,0,0,0,0,0,0,0,0,-1
          dc.w 11,8,311,40,103,8,311,40,103,8,151,120,191,168,311,120,191,-1
          dc.w 11,8,639,40,103,8,639,60,103,8,311,120,191,328,631,120,191,-1
          dc.w 11,8,639,40,207,8,639,40,207,8,311,224,391,328,631,224,391,-1
          dc.w 11,8,151,40,103,168,311,40,103,8,151,120,191,168,311,120,191,-1
          dc.w 11,8,311,40,103,328,631,40,103,8,311,120,191,328,631,120,191,-1
          dc.w 11,8,311,40,207,328,631,40,207,8,311,224,391,328,631,224,391,-1
errmult:  dc.b "This multi-screen mode DOES NOT contain windows selected for"
          dc.b " program # ",0
          dc.b "Ce mode d'ecran ne PERMET PAS l'‚dition du programme ",0
errmult2: dc.b "  !",13,10,0

          even
; FENETRE HELP
thelp1:   dc.b "Editing program :  ",3,0
          dc.b "Programme  ‚dit‚:  ",3,0
thelp2:   dc.b "|P|  Size  |Wd #1|Wd #2|Wd #3|Wd #4|",10,0
          dc.b "|P| Taille |Fn #1|Fn #2|Fn #3|Fn #4|",10,0
thelp3:   dc.b "Basic accessories loaded :",10,0
          dc.b "Accessoires basic charg‚s:",10,0
thelp4:   dc.b "Remaining memory:          bytes.",0
          dc.b "M‚moire restante:          bytes.",0
helptext: dc.b " ",10,0
          dc.b "------------------------------------",10,0
          dc.b "| |        |     |     |     |     |",10,0
          dc.b "------------------------------------",10,0
          dc.b "|1|        |     |     |     |     |",10,0
          dc.b "|2|        |     |     |     |     |",10,0
          dc.b "|3|        |     |     |     |     |",10,0
          dc.b "|4|        |     |     |     |     |",10,0
          dc.b "------------------------------------",10,0
          dc.b " ",10,0
          dc.b " ",10,0
          dc.b "f1-         f5-          f9-        ",10,0
          dc.b "f2-         f6-         f10-        ",10,0
          dc.b "f3-         f7-         f11-        ",10,0
          dc.b "f4-         f8-         f12-        ",10,0
          dc.b " ",10,0
          dc.b " ",0
          dc.b 255
helpend:  dc.b " end ",0
effhelp:  dc.b "     ",0
effsize:  dc.b "        ",0
          even
tposhelp: dc.b 4,4,13,4,19,4,25,4,31,4            ;tableau
          dc.b 4,5,13,5,19,5,25,5,31,5
          dc.b 4,6,13,6,19,6,25,6,31,6
          dc.b 4,7,13,7,19,7,25,7,31,7
          dc.b 4,11,4,12,4,13,4,14,0,0            ;accessoires
          dc.b 16,11,16,12,16,13,16,14,0,0
          dc.b 29,11,29,12,29,13,29,14,0,0
          dc.b 20,16                              ;remaining
; nom des fichiers accessoires
accnames: dcb.b 12*8,32
; Ok:
ready:    dc.b 13,10,"Ok",13,10,0
rchar:    dc.b 13,10,0
; LIST BANQUES: TABLES
lbk0:     dc.b 13,10,"Reserved memory banks:",13,10,0
          dc.b 13,10,"Banques m‚moire r‚serv‚es:",13,10,0
lbk1:     dc.b 0
lbk2:     dc.b " work   ",0
lbk3:     dc.b " screen ",0
lbk4:     dc.b " program",0
lbk5:     dc.b " data   ",0
lbk6:     dc.b " dscreen",0
lbk7:     dc.b " sprites",0
lbk8:     dc.b " icons  ",0
lbk9:     dc.b " music  ",0
lbk9a:    dc.b " 3D     ",0
lbk9b:    dc.b " menus  ",0
lbk9c:    dc.b " chr set",0
lbk10:    dc.b " S:",0
lbk11:    dc.b " E:",0
lbk12:    dc.b " L:",0
          even
lbktext:  dc.l lbk2,lbk3,lbk9b,lbk1,lbk5,lbk6,lbk4,lbk9c
          dc.l lbk7,lbk8,lbk9,lbk9a
          even
; BUFFER DES TOUCHES DE FONCTIONS
buffonc:  ds.b 40*20
          ds.b 64                     ;buffer pour PUT KEY
          even
;TOUCHES DE FONCTION PAR DEFAUT
deffonc:  dc.b " ",0             ;0
          dc.b "list ",0         ;1
          dc.b "listbank`",0     ;2
          dc.b "fload",34,"*.bas",34,"`",0   ;3
          dc.b "fsave",34,"*.bas",34,"`",0   ;4
          dc.b "run`",0          ;5
          dc.b "dir`",0      ;6
          dc.b "dir$= dir$ + ",34,"\`",0      ;7
          dc.b "previous`",0                 ;8
          dc.b "off`",0      ;9
          dc.b "full`",0        ;10
          dc.b "multi 2`",0      ;11
          dc.b "multi 3`",0      ;12
          dc.b "multi 4`",0      ;13
          dc.b "mode 0`",0       ;14
          dc.b "mode 1`",0       ;15
          dc.b "accnew:accload",34,"*",34,"`",0 ;16
          dc.b "default`",0      ;17
          dc.b "env`",0          ;18
          dc.b "key list`",0     ;19
          even
; AFFICHAGE DES TOUCHES DE FONCTION: NOMS
foncnom:  dc.b "f1: ",0,"f2: ",0,"f3: ",0,"f4: ",0,"f5: ",0
          dc.b "f6: ",0,"f7: ",0,"f8: ",0,"f9: ",0,"f10:",0
          dc.b "f11:",0,"f12:",0,"f13:",0,"f14:",0,"f15:",0
          dc.b "f16:",0,"f17:",0,"f18:",0,"f19:",0,"f20:",0
          even
; ZONE SOURIS DANS LES TOUCHES
z1:       dc.w 1,24,72,0,15,80,128,0,15,136,184,0,15        ;lowres
          dc.w 192,240,0,15,248,296,0,15
          dc.w 24,72,15,31,80,128,15,31,136,184,15,31
          dc.w 192,240,15,31,248,296,15,31-1
z2:       dc.w 1,24,138,0,15,146,258,0,15,266,372,0,15      ;midres
          dc.w 380,492,0,15,500,612,0,15
          dc.w 24,138,15,31,146,258,15,31,266,372,15,31
          dc.w 380,492,15,31,500,612,15,31,-1
z3:       dc.w 1,24,138,0,15,146,258,0,15,266,372,0,15      ;hires
          dc.w 380,492,0,15,500,612,0,15
          dc.w 24,138,15,31,146,258,15,31,266,372,15,31
          dc.w 380,492,15,31,500,612,15,31,-1
          even
; TABLEAU DES CODES CLAVIERS VALIDES
; 0: pas valide
; <32: envoyer a la trappe directement
; 31<x<64: numero de la touche de fonction+32
; >128: traiter specialement
; en premier: non shift‚
          dc.b "Scantb"       ;repere SCAN TABLES
scan:     dc.b $00,$82,$00,$00,$00,$00,$00,$00    ;0-7
          dc.b $00,$00,$00,$00,$00,$00,$08,$83    ;8-f
          dc.b $00,$00,$00,$00,$00,$00,$00,$00    ;10-17
          dc.b $00,$00,$00,$00,$80,$00,$00,$00    ;18-1f
          dc.b $00,$00,$00,$00,$00,$00,$00,$00    ;20-27
          dc.b $00,$00,$00,$00,$00,$00,$00,$00    ;28-2f
          dc.b $00,$00,$00,$00,$00,$00,$00,$00    ;30-37
          dc.b $00,$00,$00,$20,$21,$22,$23,$24    ;38-3f
          dc.b $25,$26,$27,$28,$29,$00,$00,$1e    ;40-47
          dc.b $0b,$00,$00,$03,$00,$09,$00,$00    ;48-4f
          dc.b $0a,$00,$81,$1a,$2a,$2b,$2c,$2d    ;50-57
          dc.b $2e,$2f,$30,$31,$32,$33,$00,$00    ;58-5f
          dc.b $00,$85,$84,$00,$00,$00,$00,$00    ;60-67
          dc.b $00,$00,$00,$00,$00,$00,$00,$00    ;68-6f
          dc.b $00,$00,$80,$00,$00,$00,$00,$00    ;70-77
          dc.b $00,$00,$00,$00,$00,$00,$00,$00    ;78-7f
; clavier shifte:
scanshft: dc.b $00,$82,$00,$00,$00,$00,$00,$00    ;0-7
          dc.b $00,$00,$00,$00,$00,$00,$08,$83    ;8-f
          dc.b $00,$00,$00,$00,$00,$00,$00,$00    ;10-17
          dc.b $00,$00,$00,$00,$00,$00,$00,$00    ;18-1f
          dc.b $00,$00,$00,$00,$00,$00,$00,$00    ;20-27
          dc.b $00,$00,$00,$00,$00,$00,$00,$00    ;28-2f
          dc.b $00,$00,$00,$00,$00,$00,$00,$00    ;30-37
          dc.b $00,$00,$00,$20,$21,$22,$23,$24    ;38-3f
          dc.b $25,$26,$27,$28,$29,$00,$00,$0c    ;40-47
          dc.b $0b,$00,$00,$01,$00,$02,$00,$00    ;48-4f
          dc.b $0a,$00,$81,$18,$2a,$2b,$2c,$2d    ;50-57
          dc.b $2e,$2f,$30,$31,$32,$33,$00,$00    ;58-5f
          dc.b $00,$85,$84,$00,$00,$00,$00,$00    ;60-67
          dc.b $00,$00,$00,$00,$00,$00,$00,$00    ;68-6f
          dc.b $00,$00,$00,$00,$00,$00,$00,$00    ;70-77
          dc.b $00,$00,$00,$00,$00,$00,$00,$00    ;78-7f
          even
; ADRESSE DES TRAITEMENTS SPECIAUX
          dc.b "Tspeci"       ;repere TRAITEMENTS SPECIAUX
adspecial:dc.l return
          dc.l insere
          dc.l windnext
          dc.l return
          dc.l help
          dc.l undo
          even
; BRUIT DES TOUCHES
b1:       dc.b 8,$10,9,$10,10,$10,11,0,12,$10,13,9
          dc.b 0,239,1,0,2,190,3,0,4,159,5,0,6,0,7,$f8,$ff,0
b2:       dc.b 8,$10,9,0,10,0,11,0,12,5,13,9
          dc.b 0,219,1,1,2,0,3,0,4,0,5,0,6,0,7,$fe,$ff,0
b3:       dc.b 8,$10,9,0,10,0,11,0,12,2,13,3
          dc.b 0,119,1,0,2,0,3,0,4,0,5,0,6,0,7,$fe,$ff,0
b4:       dc.b 8,$10,9,0,10,0,13,3,11,$80,12,1
          dc.b 0,80,1,0,2,0,3,0,4,0,5,0,6,0,7,$fe,$ff,0
; BRUITS PREFORMES
tshoot:   dc.b 0,0,1,0,2,0,3,0,4,0,5,0,6,12
          dc.b 8,$10,9,$10,10,$10,11,0,12,12,13,9,7,$c0,$ff,0
texplode: dc.b 0,0,1,0,2,0,3,0,4,0,5,0,6,31
          dc.b 8,$10,9,$10,10,$10,11,0,12,50,13,9,7,$c0,$ff,0
tping:    dc.b 8,$10,9,0,10,0,11,0,12,20,13,9
          dc.b 0,47,1,0,2,47,3,0,4,47,5,0,6,0,7,$f8,$ff,0
; INSTRUCTION NOISE
tn:       dc.b 6,0,0,0,1,0,2,0,3,0,4,0,5,0,7,$c0,$ff,0
tn1:      dc.b 6,0,0,0,1,0,$ff,0
tn2:      dc.b 6,0,2,0,3,0,$ff,0
tn3:      dc.b 6,0,4,0,5,0,$ff,0
; INSTRUCTION NOTE
te:       dc.b 0,0,2,0,4,0,1,0,3,0,5,0,7,$f8,$ff,0
te1:      dc.b 0,0,1,0,$ff,0
te2:      dc.b 2,0,3,0,$ff,0
te3:      dc.b 4,0,5,0,$ff,0
tfreq:    dc.w 0
          dc.w 3822,3608,3405,3214,3034,2863,2703,2551,2408,2273,2145,2025
          dc.w 1911,1804,1703,1607,1517,1432,1351,1276,1204,1136,1073,1012
          dc.w 956,902,851,804,758,716,676,638,602,568,536,506
          dc.w 476,451,426,402,379,358,338,319,301,284,268,253
          dc.w 239,225,213,201,190,179,169,159,150,142,134,127
          dc.w 119,113,106,100,95,89,84,80,75,71,67,63
          dc.w 60,56,53,50,47,45,42,40,38,36,34,32
          dc.w 30,28,27,25,24,22,21,20,19,18,17,16

;-----------------------------------------    --- ----- ---   ---    -------
;   -----------------------------------      |      |  |   | |
;   |    DONNEES DE L'INTERPRETEUR    |       ---   |  |   |  ---
;   -----------------------------------          |  |  |   |     |
;-----------------------------------------    ---       ---   ---    -------
; TABLE DES TOKENS PRIORITAIRES
minitok:  dc.b "to",$80,"step",$81,"then",$9a,"else",$9b
          dc.b "xor",$eb,"or",$ec,"and",$ed
          dc.b "goto",$98,"gosub",$99
          dc.b "<>",$ee,"><",$ee,"<=",$ef,"=<",$ef
          dc.b ">=",$f0,"=>",$f0,"=",$f1,"<",$f2,">",$f3
          dc.b "+",$f4,"-",$f5,"mod",$f6,"*",$f7,"/",$f8,"^",$f9
          dc.b "as",$a0,$d3,0,0

          dc.b 254  ;securite pour detokenisation
; INSTRUCTIONS
tokens:   dc.b "to",$80,"step",$81,"next",$82,"wend",$83
          dc.b "until",$84,"dim",$85,"poke",$86,"doke",$87
          dc.b "loke",$88,"read",$89,"rem",$8a,"'",$8a,"return",$8b
          dc.b "pop",$8c,"resume next",$8d,"resume",$8e,"on error",$8f
          dc.b "screen copy",$90,"swap",$91,"plot",$92,"pie",$93
          dc.b "draw",$94,"polyline",$95,"polymark",$96     ;une place!
          dc.b "goto",$98,"gosub",$99,"then",$9a,"else",$9b
          dc.b "restore",$9c,"for",$9d,"while",$9e,"repeat",$9f
          dc.b "print",$a1,"?",$a1,"if",$a2,"update",$a3,"sprite",$a4
          dc.b "freeze",$a5,"off",$a6,"on",$a7
          dc.b "locate",$a9,"paper",$aa,"pen",$ab           ;.EXT: $a8
          dc.b "home",$ac,".b",$ad,".w",$ae,".l",$af
          dc.b "cup",$b0,"cdown",$b1,"cleft",$b2,"cright",$b3
          dc.b "cls",$b4,"inc",$b5,"dec",$b6,"screen swap",$b7
; FONCTIONS
debfonc:  equ $b8
          dc.b "psg",$b9,"scrn",$ba,"dreg",$bb
          dc.b "areg",$bc,"point",$bd,"drive$",$be,"dir$",$bf
          dc.b "abs",$c1,"colour",$c2,"fkey",$c3               ;.EXT: $c0
          dc.b "sin",$c4,"cos",$c5,"drive",$c6,"timer",$c7
          dc.b "logic",$c8,"fn",$c9,"not",$ca,"rnd",$cb
          dc.b "val",$cc,"asc",$cd,"chr$",$ce,"inkey$",$cf
          dc.b "scancode",$d0,"mid$",$d1,"right$",$d2,"left$",$d3
          dc.b "length",$d4,"start",$d5,"len",$d6,"pi",$d7
          dc.b "peek",$d8,"deek",$d9,"leek",$da,"zone",$db
          dc.b "x sprite",$dc,"y sprite",$dd,"x mouse",$de,"y mouse",$df
          dc.b "mouse key",$e0,"physic",$e1,"back",$e2,"log",$e3
          dc.b "pof",$e4,"mode",$e5,"time$",$e6,"date$",$e7
          dc.b "screen$",$e8,"default",$e9
; OPERATEURS
debop:    equ $ea
          dc.b " xor ",$eb," or ",$ec," and ",$ed
          dc.b "<>",$ee,"><",$ee,"<=",$ef,"=<",$ef
          dc.b ">=",$f0,"=>",$f0,"=",$f1,"<",$f2,">",$f3
          dc.b "+",$f4,"-",$f5," mod ",$f6,"*",$f7,"/",$f8,"^",$f9
; variables: $fa
; constantes: (binaire $fb)(alpha $fc)(hexa $fd)(entier $fe)(float $ff)
; TABLE DES FONCTIONS ETENDUES: $b8 + code token
foncext:  dc.b "hsin",$b8,$80
          dc.b "hcos",$b8,$81,"htan",$b8,$82
          dc.b "asin",$b8,$83,"acos",$b8,$84
          dc.b "atan",$b8,$85,"upper$",$b8,$86
          dc.b "lower$",$b8,$87,"current",$b8,$88
          dc.b "match",$b8,$89,"errn",$b8,$8a
          dc.b "errl",$b8,$8b,"varptr",$b8,$8c
          dc.b "input$",$b8,$8d,"flip$",$b8,$8e
          dc.b "free",$b8,$8f,"str$",$b8,$90
          dc.b "hex$",$b8,$91,"bin$",$b8,$92
          dc.b "string$",$b8,$93,"space$",$b8,$94
          dc.b "instr",$b8,$95,"max",$b8,$96
          dc.b "min",$b8,$97,"lof",$b8,$98
          dc.b "eof",$b8,$99,"dir first$",$b8,$9a
          dc.b "dir next$",$b8,$9b,"btst",$b8,$9c
          dc.b "collide",$b8,$9d,"accnb",$b8,$9e
          dc.b "language",$b8,$9f,"hunt",$b8,$a1           ;token $a0!!!!
          dc.b "true",$b8,$a2,"false",$b8,$a3
          dc.b "xcurs",$b8,$a4,"ycurs",$b8,$a5
          dc.b "jup",$b8,$a6,"jleft",$b8,$a7
          dc.b "jright",$b8,$a8,"jdown",$b8,$a9
          dc.b "fire",$b8,$aa,"joy",$b8,$ab
          dc.b "movon",$b8,$ac,"icon$",$b8,$ad
          dc.b "tab",$b8,$ae,"exp",$b8,$af
          dc.b "charlen",$b8,$b0,"mnbar",$b8,$b1
          dc.b "mnselect",$b8,$b2,"windon",$b8,$b3
          dc.b "xtext",$b8,$b4,"ytext",$b8,$b5
          dc.b "xgraphic",$b8,$b6,"ygraphic",$b8,$b7
          dc.b "sqr",$b8,$b9                              ;token $b8!!!!
          dc.b "divx",$b8,$ba,"divy",$b8,$bb
          dc.b "ln",$b8,$bc,"tan",$b8,$bd
          dc.b "drvmap",$b8,$be,"file select$",$b8,$bf
          dc.b "dfree",$b8,$c0,"sgn",$b8,$c1     
          dc.b "port",$b8,$c2,"pvoice",$b8,$c3
          dc.b "int",$b8,$c4,"detect",$b8,$c5
          dc.b "deg",$b8,$c6,"rad",$b8,$c7

; TABLE DES TOKENS ETENDUS: $a0 + code token > $70
tokext:   dc.b "dir/w",$a0,$70,"fade",$a0,$71
          dc.b "bcopy",$a0,$72,"square",$a0,$73      
          dc.b "previous",$a0,$74,"transpose",$a0,$75   
          dc.b "shift",$a0,$76,"wait key",$a0,$77
          dc.b "dir",$a0,$78,"ldir",$a0,$79
          dc.b "bload",$a0,$7a,"bsave",$a0,$7b
          dc.b "qwindow",$a0,$7c,"as set",$a0,$7d
          dc.b "charcopy",$a0,$7e,"under",$a0,$7f
          dc.b "menu$",$a0,$80,"menu",$a0,$81,"title",$a0,$82
          dc.b "border",$a0,$83,"hardcopy",$a0,$84
          dc.b "windcopy",$a0,$85,"redraw",$a0,$86
          dc.b "centre",$a0,$87,"tempo",$a0,$88
          dc.b "volume",$a0,$89,"envel",$a0,$8a
          dc.b "boom",$a0,$8b,"shoot",$a0,$8c
          dc.b "bell",$a0,$8d,"play",$a0,$8e
          dc.b "noise",$a0,$8f,"voice",$a0,$90,"music",$a0,$91
          dc.b "box",$a0,$92,"rbox",$a0,$93,"bar",$a0,$94,"rbar",$a0,$95
          dc.b "appear",$a0,$96,"bclr",$a0,$97
          dc.b "bset",$a0,$98,"rol",$a0,$99
          dc.b "ror",$a0,$9a,"curs",$a0,$9b
          dc.b "clw",$a0,$9c,"bchg",$a0,$9d
          dc.b "call",$a0,$9e,"trap",$a0,$9f
          dc.b "run",$a0,$a1,"clear key",$a0,$a2
          dc.b "line input",$a0,$a3,"input",$a0,$a4
          dc.b "clear",$a0,$a5,"data",$a0,$a6
          dc.b "end",$a0,$a7,"erase",$a0,$a8
          dc.b "reserve",$a0,$a9,"as datascreen",$a0,$aa
          dc.b "as work",$a0,$ab,"as screen",$a0,$ac
          dc.b "as data",$a0,$ad,"copy",$a0,$ae
          dc.b "def",$a0,$af
          dc.b "hide",$a0,$b0,"show",$a0,$b1
          dc.b "change mouse",$a0,$b2,"limit mouse",$a0,$b3
          dc.b "move x",$a0,$b4,"move y",$a0,$b5
          dc.b "fix",$a0,$b6,"bgrab",$a0,$b7
; fonctions etendues: $b8
          dc.b "fill",$a0,$b9,"key list",$a0,$ba
          dc.b "key speed",$a0,$bb,"move",$a0,$bc
          dc.b "anim",$a0,$bd,"unfreeze",$a0,$be
          dc.b "set zone",$a0,$bf,"reset zone",$a0,$c0
          dc.b "limit sprite",$a0,$c1,"priority",$a0,$c2
          dc.b "reduce",$a0,$c3,"put sprite",$a0,$c4
          dc.b "get sprite",$a0,$c5,"load",$a0,$c6
          dc.b "save",$a0,$c7,"palette",$a0,$c8
          dc.b "synchro",$a0,$c9,"error",$a0,$ca 
          dc.b "break",$a0,$cb,"let",$a0,$cc
          dc.b "key",$a0,$cd,"open in",$a0,$ce,"open out",$a0,$cf
          dc.b "open",$a0,$d0,"close",$a0,$d1
          dc.b "field",$a0,$d2," as",$a0,$d3
          dc.b "put key",$a0,$d4,"get palette",$a0,$d5
          dc.b "kill",$a0,$d6,"rename",$a0,$d7
          dc.b "rm dir",$a0,$d8,"mk dir",$a0,$d9
          dc.b "stop",$a0,$da,"wait vbl",$a0,$db
          dc.b "sort",$a0,$dc,"get",$a0,$dd
          dc.b "flash",$a0,$de,"using",$a0,$df
          dc.b "lprint",$a0,$e0,"auto back",$a0,$e1
          dc.b "set line",$a0,$e2,"gr writing",$a0,$e3
          dc.b "set mark",$a0,$e4,"set paint",$a0,$e5
          dc.b "set pattern",$a0,$e7              ;une place
          dc.b "clip",$a0,$e8,"arc",$a0,$e9
          dc.b "polygon",$a0,$ea,"circle",$a0,$eb
          dc.b "earc",$a0,$ec,"epie",$a0,$ed
          dc.b "ellipse",$a0,$ee,"writing",$a0,$ef
          dc.b "paint",$a0,$f0,"ink",$a0,$f1
          dc.b "wait",$a0,$f2,"click",$a0,$f3
          dc.b "put",$a0,$f4,"zoom",$a0,$f5
          dc.b "set curs",$a0,$f6,"scroll down",$a0,$f7
          dc.b "scroll up",$a0,$f8,"scroll",$a0,$f9
          dc.b "inverse",$a0,$fa,"shade",$a0,$fb
          dc.b "windopen",$a0,$fc,"window",$a0,$fd
          dc.b "windmove",$a0,$fe,"windel",$a0,$ff

; TABLE DES TOKENS DIRECTS: $a0 + $00 < code token < $20
          dc.b "listbank",$a0,$00,"llistbank",$a0,$01
          dc.b "follow",$a0,$02,"frequency",$a0,$03
          dc.b "cont",$a0,$04,"change",$a0,$05
          dc.b "search",$a0,$06,"delete",$a0,$07
          dc.b "merge",$a0,$08,"auto",$a0,$09
          dc.b "new",$a0,$0a,"unnew",$a0,$0b
          dc.b "fload",$a0,$0c,"fsave",$a0,$0d
          dc.b "reset",$a0,$0e,"system",$a0,$0f,"env",$a0,$10
          dc.b "renum",$a0,$11,"multi",$a0,$12
          dc.b "full",$a0,$13,"grab",$a0,$14
          dc.b "list",$a0,$15,"llist",$a0,$16
          dc.b "hexa",$a0,$17                     ;une place libre!
          dc.b "accload",$a0,$19,"accnew",$a0,$1a
          dc.b "lower",$a0,$1b,"upper",$a0,$1c
          dc.b "english",$a0,$1d,"francais",$a0,$1e
          dc.b 0
          even
; ADRESSE DES ROUTINES D'EXECUTION
          dc.b "Jinstr"       ;repere JUMPS instructions
jumps:    dc.l syntax,syntax,next,wend,until,dim,poke,doke
          dc.l loke,read,data,retourne,pop,resnext,resume,onerror ;$80-$8f
          dc.l scrcopy,swap,plot,pie,draw,polyline,polymark,pasimp
          dc.l goto,gosub,syntax,else,restore,for,while,repeat    ;$90-$9f
          dc.l etendu,print,if,update,sprite,freeze,auff,on
          dc.l extinst,locate,paper,pen,home,syntax,syntax,syntax
          dc.l curup,curdown,curleft,curight,cls,inc,dec,scrswap
; fonctions/instructions
          dc.l syntax,psginst,syntax,instdreg,instareg,syntax,drived,dirinst
          dc.l syntax,syntax,color,syntax,syntax,syntax,drive,setimer
          dc.l loginst,syntax,syntax,syntax,syntax,syntax,syntax,syntax
          dc.l syntax,midinst,rightinst,leftinst,syntax,syntax,syntax,syntax ;$d0-$df
          dc.l syntax,syntax,syntax,syntax,syntax,syntax,xminst,yminst
          dc.l syntax,physinst,backinst,syntax,pofins,setmode,settime,setdate
          dc.l scrinst,defolt,syntax,syntax,syntax,syntax,syntax,syntax
          dc.l syntax,syntax,syntax,syntax,syntax,syntax,syntax,syntax ;$f0-$ff
          dc.l syntax,syntax,let,syntax,syntax,syntax,syntax,syntax

; ADRESSE DES FONCTIONS
          dc.b "Jfonct"                 ;repere JUMPS FONCTIONS
opejumps: dc.l fetendu,psgfonc,screen,dreg,areg,point,fndrived,fndir
          dc.l extfunc,abs,colorf,fonkey,sin,cos,fndrive,getimer
          dc.l logical,fn,naut,rnd,val,asc,chr,inkey
          dc.l scancode,mid,right,left,length,start,len,pi
          dc.l peek,deek,leek,zone,xsprite,ysprite,xmouse,ymouse
          dc.l mousekey,physical,backgrnd,log10,pofonc,fnmode,time,date
          dc.l scrfonc,default
; operateurs: ne peuvent etre appeles que par EVALUE
          dc.l syntax,syntax,syntax,syntax,syntax,syntax  ;debut des operateurs
          dc.l syntax,syntax,syntax,syntax,syntax,syntax,syntax,syntax
          dc.l syntax,syntax,findvar,entier,alpha,entier,entier,float

; ADRESSE DES OPERATEURS
evajumps: dc.l syntax,opxor,opor,opand
          dc.l diff,infeg,supeg,egale,inf,sup
          dc.l plus,moins,modulo,multiplie,divise,puissant
          dc.l syntax,syntax,syntax,syntax,syntax       ;debut des constantes

; ADRESSE DES FONCTIONS ETENDUES
          dc.b "Jfctex"       ;repere JUMPS FONCTIONS ETENDUES
extfonc:  dc.l sinh,cosh,tanh,asin,acos,atan,fnlower,fnupper
          dc.l current,dichot,errnumber,errline,varptr,inputn,flip,free
          dc.l str,hex,bin,string,space,instr,max,min
          dc.l lof,eof,dirfirst,dirnext,btest,collide,accnb,langage
          dc.l syntax,faind,vrai,faux,cursx,cursy,jup,jleft
          dc.l jright,jdown,fire,joy,movon,icon,tab,exp
          dc.l charlen,choice,item,fwindon,xtext,ytext,xgraphic,ygraphic
          dc.l syntax,sqr,divx,divy,log,tan,drvmap,fselector
          dc.l dfree,sgn,port,pvoice,int,dtct,deg,rad

; ADRESSE DES ROUTINES DIRECTES $60< token < $80
          dc.b "Jdirec"       ;repere JUMPS FONCTIONS DIRECTES
dirjumps: dc.l listbank,llistbank,follow,freq,cont,exchange,search,delete
          dc.l merge,auto,new,unnew,fload,fsave,warm,system
          dc.l ambiance,renum,multi,fullscreen,grab,list,llist,hexa
          dc.l pasimp,accload,accnew,upper,lower,english,francais,pasimp

; ADRESSE DES ROUTINES ETENDUES
          dc.b "Jexten"
extjumps: dc.l dirw,fde,bcopy,textbox
          dc.l previous,transpose,colshift,waitkey
          dc.l dir,ldir,bload,bsave,qwindow,syntax,charcopy,underline
          dc.l menu,menuonof,title,border,hardcopy,windcopy,redraw,center
          dc.l tempo,volume,envel,explode,shoot,ping,note,noise
          dc.l voice,music,box,rbox,bar,rbar,appear,bclair
          dc.l bsait,raul,raur,curs,clw,bchge,call,trahp
          dc.l syntax,run,clearkey,lineinput,input,clear,data,end
          dc.l erase,reserve,syntax,syntax,syntax,syntax,copy,def
          dc.l hide,show,chgmouse,limouse,mouvex,mouvey,fix,bgrab
          dc.l pasimp,fill,keylist,keyspeed,mouve,anime,unfreeze,setzone
          dc.l reszone,limsprite,priority,reduce,putspr,getspr,load,save
          dc.l palet,sync,erraur,breaque,llet,keyfnc,openin,openout
          dc.l hopen,klose,field,syntax,putkey,getpalet,kill,rename
          dc.l rmdir,mkdir,stop,waitvbl,sort,get,flash,syntax
          dc.l lprint,sautoback,setline,setwrite,setmark,setpaint,pasimp
          dc.l setpatt
          dc.l clip,arc,polygone,circle,earc,epie,ellipse,writing
          dc.l paint,setink,wait,clik,put,zoom,setcurs,scrolldn
          dc.l scrollup,scroll,inverse,shade,windopen,window,windmov,windel

; TABLE DES ADRESSE UTILES POUR LES ROUTINES D'EXTENTION
routines: dc.l buffer,fltoint,inttofl,dta               ;$00
          dc.l fichiers,erreur,err2,demande             ;$10
          dc.l start1,leng1,transmem,fe                 ;$20
          dc.l jumps,opejumps,evajumps,extfonc          ;$30
          dc.l dirjumps,extjumps,merreur,vecteurs       ;$40
          dc.l mode,contrl,intin,ptsin                  ;$50
          dc.l intout,ptsout,vdipb,chrget               ;$60
          dc.l chaine,dechaine,active,savect            ;$70
          dc.l loadvect,menage,adoubank,adecran         ;$80
          dc.l abck,abis,buffonc,deffonc                ;$90
	dc.l foncnom			      ;$A0

; EXTENSION NON PRESENTE
pxt:      dc.b "extension #"
pxt1:     dc.b 0,$80
          even
;RESOLUTION--> coordonnees/couleur maxi
maxmode:  dc.w 320,200,16,0,640,200,4,0,640,400,2,0
          even
;RESOLUTION--> donnees VDI
vdimode:  dc.w $13f,$c7,0,$152,$174     ;VDI 1, lowres, taille$5a
          dc.w 3,7,0,6,8,1,$18,$c
          dc.w $10,$a,1,2,3,4,5,6
          dc.w 7,8,9,$a,3,0,3,3
          dc.w 3,0,3,0,3,2,1,1
          dc.w 1,0,$200,2,1,1,1,2
          dc.w 5,4,7,$d                 ;VDI 2: taille $18
          dc.w 1,0,$28,0,$f,$b,$78,$58
          dc.w $27f,$c7,0,$a9,$174      ;VDI 1, midres
          dc.w 3,7,0,6,8,1,$18,$c
          dc.w 4,$a,1,2,3,4,5,6
          dc.w 7,8,9,$a,3,0,3,3
          dc.w 3,0,3,0,3,2,1,1
          dc.w 1,0,$200,2,1,1,1,2
          dc.w 5,4,7,$d                 ;VDI 2
          dc.w 1,0,$28,0,$f,$b,$78,$58
          dc.w $27f,$18f,0,$174,$174    ;VDI1, hires
          dc.w 3,7,0,6,8,1,$18,$c
          dc.w 2,$a,1,2,3,4,5,6
          dc.w 7,8,9,$a,3,0,3,3
          dc.w 3,0,3,0,3,2,0,1
          dc.w 1,0,2,2,1,1,1,2
          dc.w 5,4,7,$d                 ;VDI 2
          dc.w 1,0,$28,0,$f,$b,$78,$58
          even
; TABLES POUR LE VDI
          dc.b "Vditab"       ;repere TABLES DU VDI
contrl:   ds.w 12
intin:    ds.w 128
ptsin:    ds.w 128
intout:   ds.w 128
ptsout:   ds.w 128
vdipb:    dc.l contrl,intin,ptsin,intout,ptsout
          even
; COULEURS INK--->VDI
vdink2:   dc.w 0,2,3,6,4,7,5,8,9,10,11,14,12,15,13,1        ;lowres
vdink1:   dc.w 0,2,3,1                                      ;midres
; TABLE DE DEFSCROLL (8 def scroll maxi!)
dfst:     ds.w 16*8
          even
;TABLE DES MULTIPLES DE DIX
multdix:  dc.l 1000000000,100000000,10000000,1000000
          dc.l 100000,10000,1000,100,10,1,0
;TABLE DES FIX ASCII
fixtable: dc.b "0800010203040506070809101112131415"
;FAUSSE PUISSANCE POUR PRINT USING
uspuiss:  dc.b "E+000  "
; LIGNE TROP LONGUE!
cantex:   dc.b "This line can't be changed:",13,10,0
          dc.b "Cette ligne n'a pu etre chang‚e:",13,10,0
; MESSAGES D'ERREUR DE L'INPUT
redofrom: dc.b 13,10,"Please redo from start.",13,10,0
          dc.b 13,10,"Recommencer au d‚but S.V.P.",13,10,0
encore:   dc.b 13,10,"?? ",0
          even
; MESSAGES D'ERREUR
merreur:  dc.b "Not done",0                          ;0---> erreurs editeur
          dc.b "Non effectu‚",0
          dc.b "Bad file format",0                   ;1
          dc.b "Mauvais format de fichier",0
          dc.b "Out of memory",0                     ;2
          dc.b "M‚moire pleine",0
          dc.b "This line does not exist",0          ;3
          dc.b "Cette ligne n'existe pas",0
          dc.b "This line already exists",0          ;4
          dc.b "Cette ligne existe d‚j…",0
          dc.b "Search failed",0                     ;5
          dc.b "La recherche a ‚chou‚",0
          dc.b "Line too long",0                     ;6
          dc.b "Ligne trop longue",0
          dc.b "Can't continue",0                    ;7
          dc.b "Impossible de continuer",0
          dc.b "Out of memory",0                     ;8 ---> erreurs fatales
          dc.b "Memoire pleine",0
          dc.b "Follow too long",0                   ;9
          dc.b "Follow trop long",0
          dc.b "Printer not ready",0                 ;10
          dc.b "L'imprimante n'est pas prŠte",0
          dc.b "Can't renum",0                       ;11
          dc.b "Renum‚rotation impossible",0
          dc.b "Syntax error",0                      ;12--> erreurs normales
          dc.b "Erreur de syntaxe",0
          dc.b "Illegal function call",0             ;13
          dc.b "Appel ill‚gal de fonction",0
          dc.b "Illegal direct mode",0               ;14
          dc.b "Instruction interdite en mode direct",0
          dc.b "Direct command used",0               ;15
          dc.b "Instruction interdite en mode programme",0
          dc.b "In/Out error",0                      ;16
          dc.b "Erreur d'entr‚e/sortie",0
          dc.b "Break",0                             ;17
          dc.b "Stop",0
          dc.b "Non declared array",0                ;18
          dc.b "Tableau non d‚clar‚",0
          dc.b "Type mismatch",0                     ;19
          dc.b "Types de variable incompatibles",0
          dc.b "Function not implemented",0          ;20
          dc.b "Fonction non impl‚ment‚e",0
          dc.b "Overflow error",0                    ;21
          dc.b "D‚passement de capacit‚",0
          dc.b "For without next",0                  ;22
          dc.b "For sans next",0
          dc.b "Next without for",0                  ;23
          dc.b "Next sans for",0
          dc.b "While without wend",0                ;24
          dc.b "While sans wend",0
          dc.b "Wend without while",0                ;25
          dc.b "Wend sans while",0
          dc.b "Repeat without until",0              ;26
          dc.b "Repeat sans until",0
          dc.b "Until without repeat",0              ;27
          dc.b "Until sans repeat",0
          dc.b "Array already dimensioned",0         ;28
          dc.b "Tableau d‚ja d‚fini",0
          dc.b "Undefined line number",0             ;29
          dc.b "Numero de ligne non d‚fini",0
          dc.b "String too long",0                   ;30
          dc.b "Chaine trop longue",0
          dc.b "Bus error",0                         ;31
          dc.b "Erreur de bus",0
          dc.b "Address error",0                      ;32
          dc.b "Erreur d'adresse",0
          dc.b "No data on this line",0             ;33
          dc.b "Pas de 'data' sur cette ligne",0
          dc.b "No more data",0                     ;34
          dc.b "Plus de donn‚e",0
          dc.b "Too many gosubs",0                   ;35
          dc.b "Trop de gosubs",0
          dc.b "Return without gosub",0              ;36
          dc.b "Return sans gosub",0
          dc.b "Pop without gosub",0                 ;37
          dc.b "Pop sans gosub",0
          dc.b "Resume without error",0              ;38
          dc.b "Resume sans erreur",0
          dc.b "User function not defined",0         ;39
          dc.b "Fonction utilisateur non definie",0
          dc.b "Illegal user-function call",0        ;40
          dc.b "Mauvais appel de fonction utilisateur",0
          dc.b "Memory bank already reserved",0      ;41
          dc.b "Banque m‚moire d‚j… r‚serv‚e",0
          dc.b "Memory bank not defined as screen",0 ;42
          dc.b "Banque m‚moire non ‚cran",0
          dc.b "Bad screen address",0                ;43
          dc.b "Mauvaise adresse d'‚cran",0
          dc.b "Memory bank not reserved",0          ;44
          dc.b "Banque m‚moire non r‚serv‚e",0
          dc.b "Resolution not allowed",0            ;45
          dc.b "R‚solution non autoris‚e",0
          dc.b "Division by zero",0                  ;46
          dc.b "Division par z‚ro",0
          dc.b "Illegal negative operand",0         ;47
          dc.b "Op‚rande n‚gatif",0
          dc.b "File not found",0                    ;48
          dc.b "Fichier introuvable",0
          dc.b "Drive not ready",0                   ;49
          dc.b "Lecteur pas prŠt",0
          dc.b "Disc is write protected",0           ;50
          dc.b "Disquette prot‚g‚e",0
          dc.b "Disc full",0                         ;51
          dc.b "Disquette pleine",0
          dc.b "Disc error",0                        ;52
          dc.b "Erreur disquette",0
          dc.b "Bad file name",0                     ;53
          dc.b "Mauvais nom de fichier",0
          dc.b "Bad time",0                          ;54
          dc.b "Mauvaise heure",0
          dc.b "Bad date",0                          ;55
          dc.b "Mauvaise date",0
          dc.b "Sprite error",0                      ;56
          dc.b "Erreur de sprite",0
          dc.b "Movement declaration error",0        ;57
          dc.b "Mauvais appel de MOVE",0
          dc.b "Animation declaration error",0       ;58
          dc.b "Mauvais appel d'ANIM",0
          dc.b "File not open",0                     ;59
          dc.b "Fichier non ouvert",0
          dc.b "File type mismatch",0                ;60
          dc.b "Melange de types de fichiers",0
          dc.b "Input string too long",0             ;61
          dc.b "Chaine en entree trop longue",0
          dc.b "File already open",0                 ;62
          dc.b "Fichier d‚j… ouvert",0
          dc.b "File already closed",0               ;63
          dc.b "Fichier d‚j… ferm‚",0
          dc.b "End of file",0                       ;64
          dc.b "Fin de fichier",0
          dc.b "Input string too long",0             ;65
          dc.b "Chaine en entr‚e trop longue",0
          dc.b "Field too long",0                    ;66
          dc.b "Champ trop long",0
          dc.b "Flash declaration error",0           ;67
          dc.b "Mauvais appel de FLASH",0
          dc.b "Window parameter out of range",0     ;68
          dc.b "ParamŠtre de fenetre trop grand",0
          dc.b "Window already opened",0             ;69
          dc.b "FenŠtre d‚j… ouverte",0
          dc.b "Window not opened",0                 ;70
          dc.b "FenŠtre non ouverte",0
          dc.b "Window too small",0                  ;71
          dc.b "FenŠtre trop petite",0
          dc.b "Window too large",0                  ;72
          dc.b "FenŠtre trop grande",0
          dc.b "Character set not defined",0         ;73
          dc.b "Jeux de caractŠres non d‚fini",0
          dc.b "No more text buffer space",0         ;74
          dc.b "Buffer texte plein",0
          dc.b "Music not defined",0                 ;75
          dc.b "Musique non d‚finie",0
          dc.b "System window called",0              ;76
          dc.b "Appel d'une fenŠtre systŠme",0
          dc.b "System character set called",0       ;77
          dc.b "Appel d'un jeu de caractŠres systŠme",0
          dc.b "Character set not found",0           ;78
          dc.b "Jeu de caractŠres introuvable",0
          dc.b "Menu not defined",0                  ;79
          dc.b "Menu non d‚fini",0
          dc.b "Bank 15 already reserved",0          ;80
          dc.b "La banque 15 est d‚j… r‚serv‚e",0
          dc.b "Bank 15 is reserved for menus",0     ;81
          dc.b "La banque 15 est r‚serv‚e pour les menus",0
          dc.b "Illegal instruction",0               ;82
          dc.b "Instruction illegale",0
          dc.b "Drive not connected",0               ;83
          dc.b "Lecteur non connect‚",0
          dc.b "Extension not present",0             ;84
          dc.b "Extension non charg‚e",0
          dc.b "Subscript out of range",0            ;85
          dc.b "Indice trop grand",0
          dc.b "Scrolling not defined",0             ;86
          dc.b "Scrolling non defini",0
          dc.b "String is not a screen bloc",0       ;87
          dc.b "La chaine n'est pas un bloc ecran",0          
inline:   dc.b " in line ",0," en ligne ",0
          even
          dc.b "Varsys"       ;repere GENIAL ---> debut des variables
; VARIABLES SYSTEME DIVERSES
vecteurs: ds.l 8              ;copie des vecteurs systeme
anc400:   dc.l 0              ;vecteur 50 herz!!!
runonly:  dc.w 0              ;flag RUN ONLY ou NORMAL     
ronom:    dc.l 0              ;adresse du nom du RUN ONLY
roold:    dc.l 0              ;ancien directory
ada:      dc.l 0              ;adresse des adresses
adm:      dc.l 0              ;adresse tables souris
adk:      dc.l 0              ;adresse buffer clavier
ads:      dc.l 0              ;adresse depart sons
adc:      dc.l 0              ;adresse command tail
runflg:   dc.w 0
langue:   dc.w 0              ;langue utilisee: 0=GB/1=F/2=D
foncon:   dc.w 0              ;touches de fonction en route?
fonction: dc.w 0
ins:      dc.w 0              ;insertion M/A
oldi:     dc.w 0              ;ancien INS pendant une touche de fonction
undoflg:  dc.w 0
remflg:   dc.w 0
interflg: dc.w 0              ;flag break/interruption/etc...
ancdb8:   dc.w 0              ;test du contrl/c
bip:      dc.w 0              ;BIP des touches on/off
waitcpt:  dc.l 0              ;compteur a rebour: 50 herz
timer:    dc.l 0              ;compteur timer
coldflg:  dc.w 0              ;flag demarrage a froid
shift:    dc.w 0              ;touches de fonction actuellement affichees
impflg:   dc.w 0              ;flag imprimante en marche
lbkflg:   dc.w 0              ;liste banques en HEXA ou DECIMAL
handle:   dc.w 0              ;handle du fichier ouvert
upperflg: dc.w 0              ;listing en minuscule ou majuscule
unewpos:  dc.l 0              ;taille de la premiere ligne lors d'unnew
unewbank: ds.l 16             ;recopie des banques lors de NEW
unewhi:   dc.l 0              ;debut des banques de donnee
searchd:  dc.w 0              ;debut du search
searchf:  dc.w 0              ;fin du search
mousflg:  dc.w 0              ;anti rebond souris
inputflg: dc.w 0              ;si INPUT, plus de souris dans KEY!
inputype: dc.w 0              ;input ou lineinput?
orinput:  dc.w 0              ;input sur clavier ou fichier?
oradinp:  dc.l 0              ;si fichier: tampon pour l'adresse
flginp:   dc.w 0              ;flg pour input: return=13/10 ou caractere
chrinp:   dc.w 0              ;caractere servant de return pour input #
autoflg:  dc.w 0              ;auto en marche?
autostep: dc.w 0              ;STEP de l'auto
lastline: dc.w 0              ;dernier numero de ligne entr‚
parenth:  dc.w 0              ;niveau de parentheses
gotovar:  dc.w 0              ;flag pour les GOTO VARIABLE
printflg: dc.w 0              ;flag pour SSPRINT
printpos: dc.l 0              ;recuperation du print apres un menage
printype: dc.w 0              ;     "                  "
printfile:dc.l 0              ;     "                  "
usingflg: dc.w 0              ;print using en route???
sortflg:  dc.w 0              ;flag: sort de findvar
tokvar:   dc.l 0              ;tokenisation: adresse du flag variable
varlong:  dc.w 0              ;tokenisation: flag de la variable en question!
tokch:    dc.l 0              ;tokenisation: adresse du flag chaine
chlong:   dc.w 0              ;tokenisation: longueur de la chaine
nboucle:  dc.w 0              ;nombre de boucles ouvertes en ce moment
tstnbcle: dc.w 0              ;numero de la premiere boucle a tester
posbcle:  dc.l 0              ;adresse dans la pile des boucles
tstbcle:  dc.l 0              ;ou commencer a tester lors d'un goto
posgsb:   dc.l 0              ;adresse dans la pile des gosub
cptnext:  dc.w 0              ;recherche des FOR/NEXT dans le source
oldfind:  dc.l 0              ;recherche ancien ligneact
nbdim:    dc.w 0              ;nombre de dimensions pendant DIM
scankey:  dc.w 0              ;scancode du dernier inkey
datastart:dc.l 0              ;adresse de la ligne contenant le premier DATA
dataline: dc.l 0              ;adresse de la ligne du data actuel
datad:    dc.l 0              ;adresse du data actuel
folflg:   dc.w 0
erroron:  dc.w 0              ;erreur en route?
onerrline:dc.l 0              ;adresse ou se brancher en cas d'erreur
errornb:  dc.w 0              ;numero de la derniere erreur
errorline:dc.l 0              ;adresse de la ligne de la derniere erreur
errorchr: dc.l 0              ;position du chrget lors de l'erreur
contflg:  dc.w 0              ;autorisation du cont?
contchr:  dc.l 0              ;chrget lors du break/erreur pour cont
contline: dc.l 0              ;ligne  ------------------------------
brkinhib: dc.w 0              ;inhibition du break
foldeb:   dc.w 0              ;debut des ligne followed
folend:   dc.w 0              ;fin -------------------
ancrnd1:  dc.w 0              ;ancien chiffre au hasard
ancrnd2:  dc.l 0
ancrnd3:  dc.l 0
fixflg:   dc.w 0              ;nombre de decimales
expflg:   dc.w 0              ;flag representation exponantielle
callreg:  ds.l 8+7            ;sauvegarde des registres lors de CALL/TRAP
trahpile: dc.l 0              ;sauve la pile pour CALL
cursflg:  dc.l 0              ;flag: curseur en FLASH?
dirsize:  dc.l 0              ;taille totale des fichiers
;-----------------------------Graphique
mode:     dc.w 0              ;mode d'ecran 0-1-2
deflog:   dc.l 0              ;logical & physical par defaut
defback:  dc.l 0              ;background par defaut
adback:   dc.l 0              ;adresse actuelle du decor
adphysic: dc.l 0              ;adresse actuelle de l'ecran physique
adlogic:  dc.l 0              ;adresse actuelle de l'ecran logique
ambia:    dc.w 0              ;position de l'ambiance
laad:     dc.l 0              ;adresse des variables de la ligne A
laintin:  dc.l 0              ;intin pour la ligne A
laptsin:  dc.l 0              ;ptsin pour la ligne A
xmax:     dc.l 0              ;limite en X (640/320)
ymax:     dc.l 0              ;limite en Y (400/200)
colmax:   dc.l 0              ;limite de la couleur
ink:      dc.w 0              ;encre d'ecriture
inkvdi:   dc.w 0              ;   "       "     de cette merde de VDI
plan0:    dc.w 0,0,0,0        ;4 plans de couleur---> ligne A
autoback: dc.w 0              ;graphique + sprite????
xgraph:   dc.w 0              ;curseur graphique: X
ygraph:   dc.w 0              ;   "         "
grwrite:  dc.w 0              ;writing graphique (0-->3)
grh:      dc.w 0              ;handle graphique
actualise:dc.w 0              ;dessin automatique des sprites
valpen:   dc.w 0
valpaper: dc.w 0
nbjeux:   dc.w 0              ;nombre de jeux de caracteres des fenetres
defmod:   dc.w 0              ;mode par defaut
;-----------------------------sons
volumes:  dc.l 0
          even
;-----------------------------Gestionneur de memoire
;programme edite
dbufprg:  dc.l 0              ;debut du buffer de stockage
lbufprg:  dc.l 0              ;longueur du buffer de stockage
program:  dc.w 0              ;programme actuellement edite
adatabank:dc.l 0              ;adresse dans la databank
adataprg: dc.l 0              ;adresse dans la dataprg
dsource:  dc.l 0              ;adresse du source edite
fsource:  dc.l 0              ;fin du source/debut des chaines
hichaine: dc.l 0              ;fin des chaines
lowvar:   dc.l 0              ;debut des variables
himem:    dc.l 0              ;fin memoire basic (et des variables)
topmem:   dc.l 0              ;fin memoire donnees
acldflg:  dc.w 0              ;flag: chargement d'accessoires
posacc:   dc.w 0              ;position du dernier accessoire
accflg:   dc.w 0              ;programme accessoire?
reactive: dc.w 0              ;programme a activer a la sortie d'un accessoire
avanthelp:dc.w 0              ;fenetre activee avant l'appel de HELP
;autres PROGRAMMES: 16 en tout
dataprg:  ds.l 16*2           ;en premier: ADPRG, puis LPRG
fbufprg:  dc.l 0              ;FUTE! fin de la memoire des programmes
;BANKS de memoire dans les programmes: 16/PROGRAMMES
databank: ds.l 16*16
;Multifenetrage
fenetre:  dc.w 0              ;fenetre actuellement ouverte
typecran: dc.w 0              ;full:0, 2,3,4 actuellement active
;table de repartition des programmes dans les fenetres
reparti:  ds.l 16
;-----------------------------MENUS DEROULANTS
mnd:    
          dc.w 0              ;0 menuflg
          dc.w 0              ;2 oldmnflg
          dc.w 0              ;4 menuchg
          dc.w 0              ;6 menukey
          dc.w 0              ;8 menuhaut
          dc.w 0              ;10 menuline
          dc.w 0              ;12 menubar
          dc.w 0              ;14 menubank
          dc.w 0              ;16 menutemp
          dc.w 0              ;18 menuchoix
          dc.w 0              ;20 menusschx
          dc.w 0              ;22 menutx
          dc.w 0              ;24 menunb
          dc.w 0              ;26 menutour
          dc.w 0              ;28 menupen
          dc.w 0              ;30 menupaper
          dc.w 0              ;32 menuold
          ds.w 16             ;34 menutext  
          ds.w 16             ;34+32=66 menumous
          dc.w 0              ;34+32+32=98 onmnflg
          ds.l 10             ;100 onmnjmp
;-----------------------------FILE SELECTOR
fsd:                          ;DATAS FILE SELECTOR
          dc.w 0              ;+0: fsnb
          dc.w 0              ;+2: fspos position de la fenetre fichiers
          dc.w 0              ;+4: fsflg dernier affichage inverse/normal
          dc.w 0              ;+6: fschoix dernier choix avec la souris
          dc.w 0              ;+8: fskey anti rebond souris
          dc.l 0              ;+10: fsd+10 position curseur memo
          dc.w 0              ;+14: fsd+14 curseur dans NOM ou PATH
          dc.w 0              ;+16: fsd+16 longueur du nom
          dc.w 0              ;+18: fsd+18 longueur du filtre
          dc.w 0              ;+20: fslpath longueur du path
          dc.w 0              ;+22: fsd+22 bordure
          dc.w 0              ;+24: fstle flag titre
          dc.w 0              ;+26: ffflg+26 flag pour FSAVE/FLOAD
;fsmouse    equ defloat+16      ;fsmouse tests de la souris
;fspath1:  equ name1           ;path
fsname:   equ buffer+256      ;nom recherche
fsbuff:   equ buffer+256+32
          even
;-----------------------------EXTENSIONS BASIC
adext:    dc.l 0              ;adresse des routine/routine chargee
datext:   ds.l 26*2           ;table tokenisation/table jumps
extchr:   dc.l 0              ;chrget lors de l'appel
;-----------------------------PILE DES BOUCLES
maxbcle:  ds.b 38*10          ;assez pour 10 for/next
bufbcle:  equ *
          dcb.b 38,$ff        ;securite!
          even
;---------pile des gosub: 14 octets par gosub
maxgsb:   ds.b 14*15
bufgsb:   equ *
          even
; --------------------------------------------------------------
precold:  move.l $ffff0,a0    ;recupere l'adresse des extensions  
          move.l $ffff4,a1
          move.l $ffff8,a2
          moveq #0,d0
          lea pile,sp
; DEPART A FROID
cold:     move d0,runonly     ;flag NORMAL/RUN ONLY    
          move.l a0,adext     ;adresse de la table des extensions
          move.l a1,ronom     ;adresse du nom du fichier
          move.l a2,roold     ;adresse du oldpath
          move.l a4,adc       ;adresse command tail
; adaptation a l'ordinateur     
          move.l a3,ada       ;adresse adaptation
          move.l (a3),adm     ;adresse souris
          move.l 8(a3),adk    ;adresse clavier
          move.l 24(a3),ads   ;adresse sons

          move.l (sp),vecteurs  	;Adresse de retour
          clr.l -(sp)         	;passage en mode SUPERVISEUR
          move.w #$20,-(sp)
          trap #1
          addq.l #6,sp

          bsr savect          	;fait tout demarrer
          lea pile,sp

;INITIALISATION DE LA MEMOIRE: TROUVE LA TAILLE DE LA MEMOIRE
          move.l #bufprg,d0   ;TROUVE LES ECRANS
          and.l #$fffffffe,d0
          move.l d0,a0
          move.l d0,dbufprg
          move.l $42e,d0      ;fin de la memoire physique
          sub.l #$8000,d0     ;moins 32 k
          move.l d0,deflog    ;= ecran logique & physique
          sub.l #$8000,d0     ;moins 32 k
          move.l d0,defback   ;= decor des sprites
          and.l #$fffffffe,d0 ;rend pair
          move.l d0,fbufprg
          sub.l dbufprg,d0
          move.l d0,lbufprg   ;longueur utilisable
          lsr.l #6,d0         ;divise par 64
ig1:      clr.l (a0)+         ;nettoie la memoire VITE
          clr.l (a0)+
          clr.l (a0)+
          clr.l (a0)+
          clr.l (a0)+           ;4
          clr.l (a0)+
          clr.l (a0)+
          clr.l (a0)+
          clr.l (a0)+           ;8
          clr.l (a0)+
          clr.l (a0)+
          clr.l (a0)+
          clr.l (a0)+           ;12
          clr.l (a0)+
          clr.l (a0)+
          clr.l (a0)+
          dbra d0,ig1
 
          clr program
          lea dataprg,a0      ;premier programme
          move.l a0,adataprg  ;adresse dans dataprg
          move.l dbufprg,d1
          move.l d1,(a0)+     ;adresse absolue,
          move.l #2,(a0)+     ;longueur totale
          move.l d1,dsource
          move.l d1,fsource
          add.l #2,fsource
          move.l d1,a1        ;initialise les autres programmes
          add.l lbufprg,a1
          sub.l #2*16,a1
          move.l a1,d2
          clr.b d2            ;rend TOPMEM multiple de 256!
ig0:      move.l d2,himem     ;fin de la memoire basic
          move.l d2,topmem    ;pas de donnee
          addq.l #2,a1
          move #14,d0
ig2:      move.l a1,(a0)+
          move.l #2,(a0)+
          addq.l #2,a1
          dbra d0,ig2
          lea databank,a0     ;initialise les banques de memoire
          move.l a0,adatabank ;adresse dans la databank
          move #15,d0
ig3:      move.l #2,(a0)+     ;premiere banque: source de deux octets
          move #14,d1
ig4:      clr.l (a0)+         ;autre banques: longueur nulle
          dbra d1,ig4
          dbra d0,ig3

; Touches de fonction par defaut
          lea deffonc,a0        ;initialisation des touches de fonction
          lea buffonc,a1
          move #19,d0
cd0:      move.l a1,a2
cd1:      move.b (a0)+,(a2)+
          bne.s cd1
          add #40,a1
          dbra d0,cd0
; Initialisation diverses
          bsr setdta          ;zone E/S disque
          move #4,posacc      ;premier accessoire a charger
          clr upperflg        ;listing en minuscule
          clr mnd+14
          move #1,coldflg
          move #0,langue      ;En Anglais par defaut
          clr.b buffer+810    ;Marque la position accessoires charges
          move.w #1,defmod    ;Mode couleur par defaut: 1

; Chargement du EDITOR.ENV s'il existe
          lea cfenv,a0
          moveq #0,d0
          bsr sfirst          ;Pas trouve!
          bne warm
;          move.l -4(a0),d0    ;Taille du fichier
;          cmp.l #968,d0       ;968 octets!
;          bne warm
          lea cfenv,a0        ;ouvre le fichier
          moveq #0,d0
          bsr open
          bmi warm
          move.w d0,handle
          lea buffer,a0       ;lis le fichier dans le buffer
          move.l #968,d0
          bsr readisk
          move.l d0,-(sp)
          bsr close           ;ferme le fichier
          move.l (sp)+,d0
          tst.l d0
          bmi warm
; Change le mode de resolution si couleur et si different de l'actuel
          lea buffer,a6
          move.w (a6),defmod    ;Mode par defaut!
          move.w #4,-(sp)
          trap #14
          addq.l #2,sp
          cmp.w #2,d0
          beq.s cf1
          cmp.w (a6),d0
          beq.s cf1
          move.w (a6),-(sp)
          move.l #-1,-(sp)
          move.l #-1,-(sp)
          move.w #5,-(sp)
          trap #14
          add.l #12,sp
; Poke la palette d'environnement
cf1:      addq.l #2,a6
          move.w (a6)+,d0       ;Inverse/normal
          move.w d0,dh
          move.w (a6)+,d0       ;Paper
          move.w d0,db
          move.w (a6)+,d0       ;Pen
          move.w d0,db+2
; Poke la langue de demarrage
          move.w (a6)+,langue
; Poke les touches de fonction
          move.w #20*40-1,d0
          lea buffonc,a0
cf2:      move.b (a6)+,(a0)+
          dbra d0,cf2

; Ancien - DEPART A CHAUD
warm:     lea pile,sp
          clr runflg
          clr folflg          ;pas de follow!
          clr undoflg
          move #10,autostep
          move #10,lastline
          clr scankey
          clr acldflg
          move #1,actualise
          clr interflg
          clr ambia

          tst runonly
          bne cd3
          bsr redessin        ;affiche l'ecran par defaut

          tst coldflg
          beq ok
; FIN DU DEPART A FROID
; affiche le message de bienvenue
          tst langue          ;trouve la bonne langue
          beq.s langgb
          lea w1,a0
          bra.s affwell
langgb:   lea w,a0            ;message de bienvenue
affwell:  bsr tcentre
          lea buffer,a5       ;affichage de nombre de Bytes Free
          move.l lbufprg,d0
          move #-1,d3
          bsr longdec
          lea w2,a0
          bsr traduit         ;va traduire
          move.l a5,a1
          bsr transtext
          lea buffer,a0
          move #18,d7
          trap #3
; initialisation des extensions
cd3:      move.l adext,a5
          clr d5
          lea datext,a6
cd4:      tst.l (a5)
          beq.s cd5
          move.l (a5),a1      ;adresse d'appel
          lea routines,a0     ;envoie les adresses des routines
	sub.l a4,a4	;A4= 0 avant!
          jsr (a1)
          move.l a1,(a5)      ;a1= RAZ lors de clearvar
          move.l a2,(a6)      ;a2= adresse table tokens
          move.l a3,4(a6)     ;a3= adresse table jumps          
	move.l a4,26*4(a5)	;a4= adresse ARRET
          bsr traduit
          tst runonly
          bne.s cd5
          moveq #18,d7        ;message de l'extension
          trap #3
cd5:      addq.l #8,a6
          addq.l #4,a5
          addq #1,d5
          cmp #26,d5
          bne.s cd4
; fin du depart a froid
          bsr repartini       ;initialisation fenetres multi
          bsr clearvar        ;RAZ des variables
          clr coldflg

; charge le RUNTIME s'il faut!
          tst runonly
          beq.s cd7
          lea cfenv,a0
          lea name1,a1
cd5a:     move.b (a0)+,d0     ;recopie STOS\
          move.b d0,(a1)+
          cmp.b #"\",d0
          bne.s cd5a
          move.l ronom,a0
cd6:      move.b (a0)+,(a1)+  ;recopie le nom dans NAME1, apres STOS\
          bne.s cd6
          bsr setdta
          clr acldflg
          bsr load3           ;va charger le programme
          move.l roold,a0
          move.l a0,-(sp)     ;remet OLDPATH
          move.w #$3b,-(sp)
          trap #1
          tst.w d0
          bne diskerr
          move #2,runonly
          jsr redessin
          jmp run3            ;fait demarrer!

; Si EDITOR.ENV, charge les accessoires
cd7:      bsr retour           ;Curseur---> en bas
          bsr retour
          lea buffer+810,a0     ;Pointe le debut des accessoires
          tst.b (a0)
          beq.s cd8
cf4:      move.l a0,-(sp)
          lea cfld,a0           ;Affiche LOADING
          bsr traduit
          moveq #1,d7
          trap #3
          move.l (sp),a0        ;Affiche le nom du programme
          moveq #1,d7
          trap #3
          move.l (sp),a0
          bsr accldbis
          lea cfef,a0           ;Efface la ligne
          moveq #1,d7
          trap #3
          move.l (sp)+,a0
          add.l #13,a0
          tst.b (a0)
          bne.s cf4

; Command tail?, si oui, ecrit RUN "xxxxxx" dans le buffer fonction!
cd8:      tst.l adc
          beq.s cd11
          move.l adc,a2
          lea 40*20+buffonc,a0
          move.b #'r',(a0)+
          move.b #'u',(a0)+
          move.b #'n',(a0)+
          move.b #' ',(a0)+
          move.b #'"',(a0)+
          moveq #12,d2        ;pas plus de 12 caracteres
cd9:      move.b (a2)+,d0     ;filtre les codes de fonction
          beq.s cd10
          cmp.b #32,d0
          bcs.s cd9
          move.b d0,(a0)+
          dbra d2,cd9
cd10:     move.b #'"',(a0)+
          move.b #'`',(a0)+
          clr.b (a0)
          move.w #40*20+1,fonction
          bra boucle

; AUTOEXEC.BAS sur la disquette? si oui, ecrit RUN...
cd11:     bsr setdta
          lea cfau,a0
          moveq #0,d0
          bsr sfirst
          bne.s ok
          lea cfrau,a2
          lea 40*20+buffonc,a0
cd12:     move.b (a2)+,(a0)+
          bne.s cd12
          move.w #40*20+1,fonction
          bra boucle

; BOUCLE D'ATTENTE DE L'INTERPRETEUR
ok:       lea pile,sp         ;RESET de la pile
          tst accflg          ;revient d'un accessoire!!!
          bne retacc
          tst runonly         ;RUN ONLY: revient au systeme!
          bne sysbis
          lea ready,a0
          move #1,d7
          trap #3             ;affichage du OK

boucle:   lea pile,sp         ;RESET de la pile
          clr inputflg
          bsr key
          tst.b d1
          beq.s bc1           ;d1=0: code ascii direct
          bmi special
          move.b d1,d0        ;d1<32: code de fonction DIRECT
          clr undoflg
          bra.s bc10
bc1:      clr undoflg
          cmp.b #10,d0        ;CONTROL-J: join deux ligne
          beq.s bc11
          cmp.b #32,d0        ;filtre les code ASCII < 32
          bcs.s boucle
          cmp.b #255,d0       ;Caractere FIN DE LIGNE?
          beq.s boucle        ;OUI: on ne l'affiche pas!
          move d0,-(sp)
          tst ins
          bne.s bc8           ;insertion automatique
          moveq #17,d7
          trap #3             ;ramene la position du curseur
          move d0,d1
          swap d0
          moveq #5,d7         ;caractere sous le curseur
          trap #3
          cmp.b #255,d0
          bne.s bc9
bc8:      moveq #20,d7        ;appel de AUTOINS (#20)
          move (sp)+,d0
          trap #3
          bra boucle
bc9:      move (sp)+,d0
bc10:     clr d7              ;affichage du caractere
          trap #3
          bra.s boucle
bc11:     moveq #21,d7        ;fonction #21: JOIN
          trap #3
          bra boucle
; traitement special des fonctions: d1=code de celle ci
special:  and #$7f,d1
          lsl #2,d1
          lea adspecial,a0
          move.l 0(a0,d1.w),a0
          jsr (a0)            ;branchement a la fonction speciale
          bra boucle

; SAVECT: SAUVE LES VECTEURS D'EXEPTION / DEPART DES INTERRUPTIONS
savect:   lea vecteurs+4,a6   ;pile deja stockee
          move.l $8,(a6)+     ;puis BUS ERROR
          move.l $c,(a6)+     ;puis ADRESS ERROR
          move.l $404,(a6)+   ;puis CRITICAL ERROR
          move.l $10,(a6)+    ;puis INSTRUCTION ILLEGALE
          move.l $14,(a6)+    ;puis DIVISION PAR ZERO
; depart des interruptions!
          move.l #errbus,$8
          move.l #erradr,$c
          move.l #critic,$404
          move.l #illinst,$10
          move.l #dbyzero,$14
          moveq #30,d0        ;init INTERRUPTIONS TRAPPE #5
          lea interflg,a0     ;flag DOIT ACTUALISER
          trap #5
          moveq #15,d7        ;init INTERRUPTIONS TRAPPE #3
          trap #3
          moveq #7,d0         ;init INTERRUPTIONS TRAPPE #7
          trap #7
          move.l adk,a0
          move 8(a0),ancdb8   ;empeche le CLICK!
          move.l $400,anc400
          move.l #inter50,$400  ;branche les interruptions a 50 herz
critic:   rts                   ;critical error pointe sur RTS

; LOADVECT: REMET LES VECTEURS, ARRET DES INTERRUPTIONS
loadvect: move.l anc400,$400
          moveq #8,d0         ;arret interruptions de la trappe #7
          trap #7
          moveq #7,d7         ;arret interruptions de la trappe #3
          trap #3
          moveq #31,d0        ;arret interruptions de la trappe #5
          trap #5
; enleve la workstation
          move.l $84,buffer   ;met la fausse trappe
          move.l #trp1,$84
          move #101,contrl
          clr contrl+2
          clr contrl+6
          move grh,contrl+12
          jsr vdi
          move.l buffer,$84   ;remet la vraie trappe
; remet tout le reste
          lea vecteurs+4,a6
          move.l (a6)+,$8     ;remet BUS ERROR
          move.l (a6)+,$c     ;remet ADRESS ERROR
          move.l (a6)+,$404   ;remet CRITICAL ERROR
          move.l (a6)+,$10    ;remet ILLEGAL INTRUCTION
          move.l (a6)+,$14    ;remet DIVISION BY ZERO
          move.b #7,$484      ;click des touches!
          rts

; ARRETE LES EXTENSIONS
StopExt:	move.l adext,a6
	moveq #26-1,d6
Ste1:	tst.l (a6)
	beq.s Ste2
	move.l 26*4(a6),a0
	cmp.l #0,a0
	beq.s Ste2
	movem.l a6/d6,-(sp)
	jsr (a0)
	movem.l (sp)+,d6/a6
Ste2:	addq.l #4,a6
	dbra d6,Ste1
	rts 

; SYSTEM: RETOUR AU DOS
system:   tst.b (a6)
          bne syntax
          bsr sure
          bne notdone
sysbis:   bsr clause          	;Ferme tous les fichiers!
	bsr stopext		;Arrete les extensions
          bsr loadvect        	;Remet les vecteurs
          move.l vecteurs,a0
	move.l DefLog,sp		;Restore la pile de merde
	lea -12(sp),sp
	jmp (a0)

; SURE (Y/N): retour BEQ= OUI / BNE= NON
sure:     jsr clearkey
          lea ct,a0
          moveq #1,d7
          trap #3
se:       bsr incle
          tst.l d0
          beq.s se
          move d0,-(sp)
	clr impflg
          bsr impretour
          move (sp)+,d0
          cmp.b #"y",d0
          beq.s se1
          cmp.b #"Y",d0
se1:      rts          

; REDESSINE L'ECRAN DE L'EDITEUR?
redessin: movem.l d0-d7/a0-a6,-(sp)
          move.l defback,d3   ;retabli le DECOR
          jsr backbis
          move.l deflog,d0    ;retabli ecran physique et logique
          move.l d0,adlogic
          move.l d0,adphysic
          move.w #-1,-(sp)
          move.l d0,-(sp)
          move.l d0,-(sp)
          move #5,-(sp)
          trap #14
          add.l #12,sp        
          move.w #4,-(sp)     ;Met le mode defini par defaut
          trap #14
          addq.l #2,sp
          move d0,mode
          cmp.w #2,d0
          beq.s red1
          cmp.w defmod,d0
          beq.s red1
          moveq #0,d3
          move.w defmod,d3
          jsr maude
          bra.s red1
; Entree pour CLS: ne change pas le mode par defaut
Red:      movem.l d0-d7/a0-a6,-(sp)
red1:     clr d0
          tst runonly         ;remet les touches de fonction si NORMAL
          bne.s red0
          moveq #1,d0         ;si RUNONLY: ne les met pas par defaut
red0:     move d0,foncon 
          move #1,cursflg     ;remet le curseur
          clr mnd+12          ;plus de barre de menu!!!
          jsr menuoff
          jsr modebis         ;va tout terminer: couleurs, tfonction, etc...
          jsr zonecran        ;tant pis si c'est fait deux fois!
          jsr pokeamb
          moveq #17,d0
          clr.l d1
          trap #5             ;remet la souris: SHOW ON
          moveq #0,d0
          trap #7             ;arret de la musique
          move.b #6,$484      ;init pas de clic, repetition....CLAVIER
          clr.b bip           ;BIP des touches
          bsr ains            ;Pas d'insertion!
          movem.l (sp)+,d0-d7/a0-a6
          rts

; ACTIVATION DE LA FENETRE EDITEUR PAR DEFAUT d0
defaut:   movem.l d1-d7/a0,-(sp)
          lea fe,a0
          mulu #3*18,d0       ;pointe la bonne
          move mode,d1
          mulu #18,d1
          add d1,d0
          add d0,a0           ;pointe la fenetre du mode
          move (a0)+,d0       ;numero de la fenetre
          move (a0)+,d1       ;bords
          swap d1
          move (a0)+,d1       ;jeu de car
          move (a0)+,d2       ;dx
          move (a0)+,d3       ;dy
          move (a0)+,d4       ;tx
          move (a0)+,d5       ;ty
          move (a0)+,d6       ;pen
          swap d6
          move (a0),d6        ;paper
          move #6,d7
          trap #3
          movem.l (sp)+,d1-d7/a0
          rts

; AFFICHAGE TEXTE CENTRE POINTE PAR A0
tcentre:  cmp.b #255,(a0)
          beq.s tc1
          move #18,d7
          trap #3
          bra.s tcentre
tc1:      rts

; ENVOI D'UNE LISTE DE ZONES (pointee par a2) AU TESTEUR DE ZONES
envzone:  move (a2)+,d6
envz:     move (a2)+,d2
          bmi.s ev2
	move (a2)+,d3
          bne.s ev1
          clr d4
          clr d5
          addq.l #4,a2
          bra.s ev3
ev1:      move (a2)+,d4
          move (a2)+,d5
          add #640,d2
          add #640,d3
          add #400,d4
          add #400,d5
ev3:      move d6,d1
          move #25,d0
          trap #5
          addq #1,d6
          bra.s envz
ev2:      rts

; RETOUR CHARIOT
retour:   lea rchar,a0
          move #1,d7
          trap #3
          rts

; Fonction speciale: RETURN
return:   clr undoflg
          move #11,d7         ;ne teste pas si la ligne est tronquee!
          lea buffer,a0
          move #510,d0
          trap #3             ;rempli le buffer et met le curseur
          tst d0
          bne toolong
          bsr retour          ;effectue le return dans l'ecran
          bsr tokenise
          bra boucle

; fonction speciale INSERE
insere:   clr undoflg
          tst ins
          bne.s ains
; MISE EN ROUTE insertion
mins:     move #1,ins
          moveq #23,d7
          trap #3
          rts
; ARRET insertion
ains:     clr ins
          moveq #22,d7
          trap #3
          rts

; UNDO
undo:     tst runflg          ;pas en mode programme!
          bne.s ud1
          add #1,undoflg
          cmp #2,undoflg      ;appuyer DEUX FOIX de suite sur UNDO!
          bne.s ud2
          clr brkinhib        ;reautorise BREAK
          bsr redessin        ;permet de s'en sortir!!!
          move errornb,d0
          beq.s ud1           ;reliste le message d'erreur s'il y en a!
          jmp erreur
ud1:      clr undoflg
ud2:      rts

; TEST DES TOUCHES ET DES TOUCHES DE FONCTION
key:      move fonction,d0
          beq.s k0
          subq #1,d0
          lea buffonc,a0
          move.b 0(a0,d0.w),d0
          beq.s fct2
          cmp.b #'`',d0
          beq.s fct1
          clr d1
          add #1,fonction
          rts
fct1:     move.b #13,d0       ;ascii: return
          move.b #$80,d1      ;special: return
          clr fonction
          tst.w oldi          ;remet ou non l'insertion
          bne mins  
          rts
fct2:     clr fonction
          tst.w oldi
          beq.s k0
          bsr mins
;attente d'une touche avec actualisation des touches de fonction
k0:       move.w #-1,-(sp)    ;test des shifts et capslock
          move.w #11,-(sp)
          trap #13
          addq.l #4,sp
          move d0,d2
          tst inputflg        ;si INPUT, plus de souris!
          bne.s k1
          tst mnd+12
          bne.s k1
          move #21,d0         ;test des touches de la souris
          trap #5
          btst #1,d0
          beq.s k1
          bset #1,d2
k1:       and #$3,d2          ;isolement des shifts
          cmp shift,d2
          beq.s k2
          move d2,shift
          bsr affonc          ;reaffichage des touches de fonction
;test de la souris et des zones choisies
k2:       tst inputflg        ;si INPUT, plus de souris!!!
          bne.s k3
          tst mnd+12
          bne.s k3
          move #21,d0
          trap #5
          btst #0,d0
          beq.s k3
          tst mousflg
          bne.s k4
          move #1,mousflg
          clr d1
          move #26,d0         ;recherche les zones
          trap #5
          tst d1              ;pas dans une zone!
          beq clck1		;Essaie de positionner quand meme!
          cmp #11,d1
          bge clickfen        ;on clique une fenetre!
          tst foncon
          beq.s k4            ;si les touches sont arretees
          subq #1,d1
          move shift,d0
          and #3,d0
          beq.s k9            ;branche aux touches de fonction
          add #10,d1
          bra.s k9            ;idem
k3:       clr mousflg
k4:       jsr avantint
          bsr incle           ;INKEY$
          tst.l d0
          beq k0              ;NON! on boucle

          move shift,d1
          and #$0003,d1       ;isolation des shifts
          beq.s k5
          lea scanshft,a0
          bra.s k6
k5:       lea scan,a0
k6:       clr d1
          swap d0             ;code ascii en D0
          move.b d0,d1        ;scancode en d1
          swap d0
          move.b 0(a0,d1.w),d1  ;correspondance tables du clavier en D1
          cmp #32,d1
          blt.s k7
          cmp #64,d1
          bge.s k7
          sub #32,d1          ;appui sur une touche de fonction
k9:       mulu #40,d1
          addq #1,d1
          move d1,fonction
          move ins,oldi ;ancienne insertion
          bsr ains            ;plus d'insertion (ca fait nul !!!)
          bra key             ;commence a lire la table
k7:       rts

; INKEY$: retour d0.l: 0 si rien
incle:    movem.l d1-d7/a0-a6,-(sp)
          move.w #2,-(sp)
          move.w #1,-(sp)
          trap #13            ;caractere disponible au clavier?
          addq.l #4,sp
          tst d0
          bne.s ic
          movem.l (sp)+,d1-d7/a0-a6
          clr.l d0
          rts
ic:       move.w #2,-(sp)     ;OUI: on va le chercher
          move.w #2,-(sp)
          trap #13            ;conin
          addq.l #4,sp
          movem.l (sp)+,d1-d7/a0-a6
          rts
  
; AFFICHAGE DES TOUCHES DE FONCTION
affonc:   move.l a5,-(sp)
          tst mnd+12
          bne af10        ;les menus sont actives!
          tst foncon          
          beq af10        ;les touches ne sont pas en route!
          move #13,d7
          trap #3             ;getcourante
          move d0,-(sp)
          move #15,d0
          move #16,d7
          trap #3             ;activation rapide: windon #15
          lea defloat,a5
          move.b #30,(a5)+    ;Home
af1:      move shift,d1       ;position des shifts
          and #$3,d1          ;isolement des shifts (pas la peine!)
          bne.s af0
          clr d0
          clr d1
          bra.s af05
af0:      move #50,d0
          move #400,d1
af05:     lea foncnom,a3
          lea 0(a3,d0.w),a3   ;a3 pointe le NOM des touches
          lea buffonc,a1
          lea 0(a1,d1.w),a1   ;a1 pointe sur les touches de fonction
          tst mode
          beq.s af2
          move #10,d2
          bra.s af3
af2:      move #6,d2          ;limite en base resolution
af3:      move #1,d1
af4:      move.b #32,(a5)+    ;deux blancs au debut de la ligne
          move.b #32,(a5)+
af5:      move.l a1,a2
          clr d3
          tst mode
          beq.s af6
          move.b #21,(a5)+    ;inverse ON
          move.l a3,a0
af5a:     move.b (a0)+,(a5)+  ;poke le nom
          bne.s af5a
          subq.l #1,a5
af6:      move.b (a2)+,d0
          beq.s af7
          move.b d0,(a5)+
          addq #1,d3
          cmp d2,d3
          blt.s af6
          bge af8
af7:      cmp d2,d3           ;bourre de #32--->10 caracteres
          bge.s af8
          move.b #32,(a5)+
          addq #1,d3
          bra.s af7

af8:      move.b #18,(a5)+    ;blanc normal entre les touches
          move.b #32,(a5)+
          addq #1,d1          ;touche suivante
          add #40,a1
          add #5,a3
          cmp #6,d1
          blt.s af5
          bne.s af9
          move.b #32,(a5)+    ;fin de la ligne
          bra af4
af9:      cmp #11,d1
          bne af5
          clr.b (a5)
          lea defloat,a0      ;affichage rapide de toutes les touches
          move #1,d7
          trap #3
          move (sp)+,d0
          move #16,d7
          trap #3             ;reactivation rapide de la fenetre de travail
af10:     move.l (sp)+,a5
          rts

;-----------------------------------------    --- ----- ---   ---    -------
;   -----------------------------------      |      |  |   | |
;   | STOCKAGE/EFFACEMENT DES  LIGNES |       ---   |  |   |  ---
;   -----------------------------------          |  |  |   |     |
;-----------------------------------------    ---       ---   ---    -------
; MINI CHRGET POUR LES CONVERSIONS
minichr:  move.b (a6)+,d2
          beq.s mc1
          cmp.b #32,d2
          beq minichr
          cmp.b #"a",d2       ;si minuscule: majuscule
          bcs.s mc0
          sub.b #"a"-"A",d2
mc0:      sub.b #48,d2
          rts
mc1:      move.b #-1,d2
          rts

; CONVERSION DECIMAL->HEXA SUR DEUX OCTETS, NON SIGNE!
dechexa:  bsr declong
          bne.s dh0
          cmp.l #65536,d0
          bcc.s dh2
          clr d1
dh0:      rts

; CONVERSION DECIMAL->HEXA SUR QUATRE OCTETS, SIGNE!
declong:  clr.l d0
          clr.l d2
          clr d3
          move.l a6,a0
dh1:      bsr minichr
dh1a:     cmp.b #10,d2
          bcc.s dh5
          move d0,d1
          mulu #10,d1
          swap d0
          mulu #10,d0
          swap d0
          tst d0
          bne.s dh2
          add.l d1,d0
          bcs.s dh2
          add.l d2,d0
          bmi.s dh2
          addq #1,d3
          bra.s dh1
dh2:      move.l a0,a6
          move #1,d1          ;out of range: bpl, et recupere l'adresse
          rts
dh5:      subq.l #1,a6
          tst d3
          beq.s dh7
          clr d1              ;OK: chiffre en d0, et beq
          rts
dh7:      move #-1,d1         ;pas de chiffre: bmi
          rts

; CONVERSION HEXA-ASCII EN HEXA-HEXA
hexalong: clr.l d0
          clr d2
          clr d3
          move.l a6,a0
hh1:      bsr minichr
          cmp.b #10,d2
          bcs.s hh2
          cmp.b #17,d2
          bcs.s dh5
          sub #7,d2
hh2:      cmp.b #16,d2
          bcc.s dh5
          lsl.l #4,d0
          or.b d2,d0
          addq #1,d3
          cmp #9,d3
          bne.s hh1
          beq.s dh2

; CONVERSION BINAIRE ASCII ---> HEXA SUR QUATRE OCTETS
binlong:  clr.l d0
          clr d2
          clr d3
          move.l a6,a0
bh1:      bsr minichr
          cmp.b #2,d2
          bcc.s dh5
          roxr #1,d2
          roxl.l #1,d0
          bcs.s dh2
          addq #1,d3
          cmp #33,d3
          bne.s bh1
          beq.s dh2

; CONVERSION HEXA--->DECIMAL SUR QUATRE OCTETS
longdec1: move #-1,d3         ;proportionnel
          moveq #1,d4         ;avec signe
          bra.s longent
longdec:  clr.l d4            ;proportionnel, sans espace si positif!
          move.l #-1,d3
; conversion proprement dite: LONG-->ENTIER
longent:  tst.l d0            ;test du signe!
          bpl.s hexy
          move.b #"-",(a5)+
          neg.l d0
          bra.s hexz
hexy:     tst d4
          beq.s hexz
          move.b #32,(a5)+
hexz:     tst.l d3
          bmi.s hexv
          neg.l d3
          add.l #10,d3
hexv:     move.l #9,d4
          lea multdix,a0
hxx0:     move.l (a0)+,d1     ;table des multiples de dix
          move.b #$ff,d2
hxx1:     addq.b #1,d2
          sub.l d1,d0
          bcc.s hxx1
          add.l d1,d0
          tst.l d3
          beq.s hxx4
          bpl.s hxx3
          btst #31,d4
          bne.s hxx4
          tst d4
          beq.s hxx4
          tst.b d2
          beq.s hxx5
          bset #31,d4
          bra.s hxx4
hxx3:     subq.l #1,d3
          bra.s hxx5
hxx4:     add #48,d2
          move.b d2,(a5)+
hxx5:     dbra d4,hxx0
          rts

; CONVERSION HEXA-HEXA -> HEXA-ASCII
longascii:move.b #"$",(a5)+
          tst.l d3
          bmi.s ha0
          neg.l d3
          add.l #8,d3
ha0:      clr d4
          move #7,d2
ha1:      rol.l #4,d0
          move.b d0,d1
          and.b #$0f,d1
          cmp.b #10,d1
          bcs.s ha2
          add.b #7,d1
ha2:      tst.l d3
          beq.s ha4
          bpl.s ha3
          tst d4
          bne.s ha4
          tst d2
          beq.s ha4
          tst.b d1
          beq.s ha5
          move #1,d4
          bra.s ha4
ha3:      subq.l #1,d3
          bra.s ha5
ha4:      add #48,d1
          move.b d1,(a5)+
ha5:      dbra d2,ha1
          rts

; CONVERSION HEXA -> BINAIRE, avec choix du nombre de decimales!!!
longbin:  move.b #"%",(a5)+
          tst.l d3
          bmi.s hb0
          neg.l d3
          add.l #32,d3
hb0:      clr d4
          move #31,d2
hb1:      clr d1
          roxl.l #1,d0
          addx.b d1,d1
          tst.l d3            ;si d3<0: representation PROPORTIONNELLE
          beq.s hb3
          bpl.s hb2
          tst d4
          bne.s hb3
          tst d2
          beq.s hb3
          tst.b d1
          beq.s hb4
          move #1,d4
          bra.s hb3
hb2:      subq.l #1,d3
          bra.s hb4
hb3:      add.b #48,d1
          move.b d1,(a5)+
hb4:      dbra d2,hb1
          rts

; CONVERSION D'UN CHIFFRE FLOAT (d3/d4) EN ASCII ---> (a5), FIX=d0
strflasc: movem.l d0/a0/a1,-(sp)	;Teste le signe
	move.w #$ff01,d0		;SI >=0 ---> espace
	trap #6
	tst.w d0
	bmi.s sfl
	move.b #32,(a5)+
sfl:	movem.l (sp)+,d0/a0/a1	 
floatasc: move.l d3,d1
          move.l d4,d2
          clr.l d5
          move d0,-(sp)
          addq #1,d0
          lsl #1,d0
          lea fixtable,a0
          move.w 0(a0,d0.w),d3
          clr.l d5
          move expflg,d5
          move (sp)+,d4
; entree pour la tokenisation
dtokfl:   lea defloat,a0      ;buffer d'ecriture du float
          moveq #$c,d0
          trap #6
          tst d4
          bmi.s p0b
p0a:      move.b (a0)+,(a5)+  ;FIX: imprime tout defloat!
          bne.s p0a
          bra p7
p0b:      move.l a0,a2
p1:       move.b (a2)+,d0
          cmp.b #".",d0
          beq.s p1a
          move.b d0,(a5)+
          bne.s p1
          bra.s p7
p1a:      move.l a2,a1        ;a1= ancien non nul
          move.l a2,a0
p2:       move.b (a0)+,d0
          beq.s p3
          cmp.b #"E",d0
          beq.s p3
          cmp.b #"0",d0
          beq.s p2
          move.l a0,a1
          bra.s p2
p3:       subq.l #1,a0
          move.l a0,d0        ;adresse de la fin du chiffre
          cmp.l a2,a1         ;imprime les chiffres utiles
          beq.s p5
          move.b #".",(a5)+
p4:       move.b (a2)+,(a5)+
          cmp.l a2,a1
          bne.s p4
p5:       move.l d0,a2
          cmp.b #"E",(a2)
          bne.s p6
          move.b #32,(a5)+    ;imprime un espace avant le E
p6:       move.b (a2)+,(a5)+
          bne.s p6
p7:       subq.l #1,a5        ;a5 pointe le zero de fin!
          rts

; AUTO
auto:     tst.b (a6)
          beq.s aut5
          bsr expentier
          cmp.l #$10000,d3
          bcc foncall
aut1:     tst d3
          beq syntax
          move d3,lastline
aut2:     tst.b (a6)
          beq.s aut5
          cmp.b #",",(a6)+
          bne syntax
          bsr expentier
          cmp.l #$10000,d3
          bcc foncall
          tst d3
          beq syntax
          move d3,autostep
          tst.b (a6)
          bne syntax
aut5:     move #1,autoflg
          bsr affauto
          bra boucle
; affichage du prochain numero de ligne
affauto:  clr.l d0
          move lastline,d0
          lea buffer,a5
          bsr longdec
          move.b #32,(a5)+
          clr.b (a5)
          lea buffer,a0
          move #1,d7
          trap #3
          rts

; POKEPAIR: POKE UN MOT LONG A UNE ADRESSE PAIRE (a5)
pokepair: move d0,-(sp)
          move a5,d0
          btst #0,d0
          beq.s pkp
          clr.b (a5)+
pkp:      move (sp)+,d0
          move.l d0,(a5)+
          rts

; LINE TOO LONG ERROR
toolong:  move #6,d0
          bra erreur

; SOUS ROUTINE DE TOKENISATION: EXPLORE UNE TABLE TERMINEE PAR ZERO!
sstok:    move.l a6,a4
          subq.l #1,a4
so1:      move.b (a3)+,d1
          beq.s so11          ;pas trouve!
          bmi.s so10            ;token trouve!
          cmp.b #32,d1
          beq.s so1           ;saute les espaces des mots clef!
so2:      move.b (a4)+,d0
          beq.s so7
          bpl.s so3           ;ne prend que les codes ascii
          move.b #".",d0
so3:      cmp.b #32,d0        ;sauter aussi les espaces
          beq.s so2
so4:      cmp.b #65,d0        ;si majuscule...
          bcs.s so5
          cmp.b #91,d0
          bcc.s so5
; Lettre: compare aux mots cle
          add.b #97-65,d0     ;...transforme en minuscule
so5:      cmp.b d0,d1
so6:      bne.s so7           ;essai du token
          beq.s so1           ;essai de la lettre suivante
; Passe au token suivant
so7:      move.b (a3)+,d1
          bpl.s so7
so8:      cmp.b #$a0,d1       ;code d'extention
          beq.s so9
          cmp.b #$b8,d1
          bne.s sstok         ;reinitialise le pointeur sur la lettre
so9:      addq.l #1,a3
          bra sstok
; Token trouve! BEQ
so10:     clr d0
          rts
; pas trouve! BNE
so11:     moveq #1,d0
          rts

; TOKENISATION DU BUFFER D'ENTREE ---> BUFFER DE TOKENISATION
tokenise: lea buffer,a6
          lea buftok,a5
          clr d5              ;flags a zero
          bsr dechexa         ;cherche un numero de ligne
          beq.s t2
          bpl syntax          ;out of range: syntax error
          bmi.s btoken        ;pas de numero de ligne
t2:       clr.w (a5)+         ;place pour le link
          move d0,(a5)+       ;numero de ligne: cree la ligne
          beq syntax          ;pas de numero de ligne nul!
          bset #2,d5          ;flag: ligne a entrer!
t3:       bclr #3,d5          ;pas de variable en cours!

; ---------------------------> BOUCLE DE TOKENISATION
btoken:   cmp.l #fintok,a5    ;debordement du buffer de tokenisation?
          bcc toolong
          move.b (a6)+,d0     ;caractere suivant
          beq tik0
bt1:      btst #0,d5          ;rem: on doit tout
          bne t20           ;saisir
; ---------------------------> TOKENISATION DES CHAINES
          cmp.b #34,d0        ;guillemets?
          bne.s tch2
          btst #1,d5
          bne.s tch1
; OUVERTURE DES GUILLEMETS
          bclr #4,d5          ;plus de FN
          move.b #$fc,(a5)+   ;token ALPHA
          clr.l d0
          bsr pokepair
          move.l a5,tokch     ;sauve l'adresse du debut de la chaine
          clr chlong          ;longueur chaine a zero!
          bset #1,d5          ;met le flag en route
          bra btoken
; FERMETURE DE GUILLEMETS
tch1:     move.l tokch,a0
          clr.l d0
          move chlong,d0
          move.l d0,-4(a0)    ;poke dans le buftok
          bclr #1,d5          ;RAZ le flag
          bra btoken
tch2:     btst #1,d5          ;guillemets ouverts: tout saisir
          beq.s t6
; ACQUISITION DE LA CHAINE
          add #1,chlong       ;longueur plus un
          move.b d0,(a5)+
          bra btoken

; ---------------------------> ESSAI DE TOKENISER EN MOT CLE
t6:       cmp.b #32,d0
          beq btoken          ;sauter les espaces
; C'est une lettre: on essaie de voir si c'est le debut d'un mot cle
          btst #3,d5          ;variable en route?
          beq.s t7
; variable en route: tokenisation reduite
          lea minitok,a3    
          bsr sstok
          beq t17
          bne rate
; pas de variable en route: explore les mots cle normaux
t7:       lea tokens,a3
          bsr sstok
          beq t17           ;trouve un token normal!
; explore les extensions
          move.l adext,a1
          lea datext,a2
          moveq #0,d2
t8:       tst.l (a1)
          beq.s t9
          move.l (a2),a3      ;adresse de la table de l'extension
          bsr sstok
          beq.s t10
t9:       addq.l #4,a1
          addq.l #8,a2
          addq #1,d2
          cmp #26,d2
          bne.s t8
          bra rate
; token extension TROUVE! PAIR: instruction, IMPAIR:fonction
t10:      btst #0,d1
          bne.s t11
          move.b #$a8,(a5)+   ;token .EXT instructions
          bra.s t12
t11:      move.b #$c0,(a5)+   ;token .EXT fonctions
t12:      move.b d2,(a5)+     ;numero de l'extension
          move.b d1,(a5)+     ;puis token
          clr d1
          bra.s t18b          ;va tout finir
; Token normal trouve! le poke
t17:      move.b d1,(a5)+
          cmp.b #$8a,d1       ;est-ce une REM?
          bne.s pasrem
          bset #0,d5          ;oui: on saisit tout ce qui suit!
pasrem:   cmp.b #$a0,d1       ;est-ce un token d'extention?
          beq.s t17a
          cmp.b #$b8,d1
          bne.s t18
t17a:     move.b (a3)+,(a5)+  ;oui: on poke le code d'extention
t18:      cmp.b #$98,d1       ;est-ce un token a branchement?
          bcs.s t18b
          cmp.b #$a0,d1
          bcc.s t18b
          clr.l d0            ;laisse la place pour l'adresse 
          bsr pokepair
t18b:     move.l a4,a6        ;change le pointeur CHRGET
          btst #3,d5
          beq.s t18c
          clr d0              ;variable a fermer!
          bra tikd
t18c:     bclr #4,d5
          cmp.b #$c9,d1       ;est le token de FN?
          bne btoken
          bset #4,d5
          bra btoken

; FIN DE LA LIGNE: y a t'il une chaine ou une variable a fermer???
tik0:     btst #3,d5
          bne tikc            ;encore une variable ouverte
          btst #1,d5
          beq t25
          subq.l #1,a6        ;reste sur le zero!
          bra tch1          ;va fermer la chaine

; ---------------------------> RATE! C'EST PAS UN TOKEN
rate:     subq.l #1,a6
          move.b (a6)+,d0
; Cherche a faire une VARIABLE ou une CONSTANTE
t19:      cmp.b #97,d0        ;si c'est une minuscule...
          bcs.s tik1
          cmp.b #123,d0
          bcc.s tik1
          sub.b #97-65,d0     ;...la transforme en majuscule
tik1:     move d0,d6
          btst #3,d5          ;variable en route?
          bne.s tika
; PREMIERE LETTRE D'UNE VARIABLE
          cmp.b #"A",d0       ;est-ce une lettre?
          bcs tik2
          cmp.b #"Z",d0
          bhi tik2
          bset #3,d5          ;oui: flag en marche
          move.b #$fa,(a5)+   ;token variable
          clr.l d0
          bsr pokepair        ;place pour l'adresse
          lea -4(a5),a0
          move.l a0,tokvar    ;sauve l'adresse du flag pour apres!
          move #1,varlong
          bra tik10
; CORPS DE LA VARIABLE
tika:     cmp.b #95,d0        ;lettre ou chiffre ou _
          beq.s tikb
          cmp.b #"Z",d0
          bhi.s tikc
          cmp.b #"A",d0
          bcc.s tikb
          cmp.b #"9",d0
          bhi.s tikc
          cmp.b #"0",d0
          bcs.s tikc
tikb:     add #1,varlong      ;une lettre de plus!
          cmp #$1e,varlong
          bcs t20
; FIN DE LA VARIABLE
tikc:     subq.l #1,a6        ;reste sur la meme lettre
tikd:     move varlong,d3
          bclr #3,d5          ;arret de la variable
          btst #4,d5          ;est-ce une variable FN?
          bne.s tikj
          tst.b d0
          beq.s tiki
          cmp.b #"(",d0
          beq.s tikh
          cmp.b #"#",d0
          beq.s tike
          cmp.b #"$",d0
          bne.s tiki
          or.b #$80,d3        ;chaine
          bra.s tikf
tike:     or.b #$40,d3        ;float
tikf:     addq #1,d3
          addq.l #1,a6
          move.b d0,(a5)+
tikg:     cmp.b #"(",(a6)
          bne.s tiki
tikh:     or.b #$20,d3        ;tableau
tiki:     move.l tokvar,a0    ;nettoie le listing 
          move.b d3,(a0)      ;et poke le flag!
          bra btoken
; c'est une variable de USER'S FUNCTION!
tikj:     move.l tokvar,a0
          move.l a0,a1
          addq.l #4,a0
          add d3,a0
          move.b 1(a0),2(a0)  ;avance les deux tokens de devant
          move.b (a0),1(a0)   ;d'une case pour laisser
          move.b #32,(a0)     ;un espace a la fin! GENIAL!
          addq #1,d3          ;un caractere de plus (l'espace)
          move.b d3,(a1)      ;poke le flag: toujours une variable "entiere"
          addq.l #1,a5        ;un caractere de plus tout de meme!
          bclr #4,d5
          bra btoken

; PAS DE VARIABLE EN ROUTE: ESSAIE DE CONVERTIR
tik2:     bclr #4,d5          ;plus de FN!!!
          subq.l #1,a6
          bsr valprg          ;va essayer de convertir
          bne.s tik9            ;pas marche!
          move.b d1,(a5)+     ;poke le type de conversion
          move.l d3,d0
          bsr pokepair        ;poke le premier chiffre
          cmp.b #$ff,d1
          bne btoken
          move.l d4,(a5)+     ;poke le deuxieme chiffre si FLOAT
          bra btoken
; RIEN N'A MARCHE: POKE DIRECTEMENT LA LETTRE
tik9:     addq.l #1,a6
tik10:    exg d6,d0           ;puis met la lettre ou le chiffre!
t20:      move.b d0,(a5)+
          bra btoken

; ---------------------------> FINI: fin de la ligne
t25:      clr.b (a5)+         ;fin de la ligne
          btst #2,d5          ;numero de ligne?
          bne t28

;COMMANDE IMMEDIATE: stocke dans le buffer de f1 et effectue
          lea buffer,a6
          lea buffonc,a0
          tst.b (a6)
          beq.s t29
          move #37,d0         ;seulement 40 caracteres
t30:      move.b (a6)+,(a0)+
          tst.b (a6)
          beq.s t31
          dbra d0,t30
          bra.s t32
t31:      move.b #"`",(a0)+
t32:      clr.b (a0)
          bsr affonc          ;reaffiche les touches
t29:      lea buftok,a6       ;NON: effectuer!
          lea pile,sp
          bra chrget          ;lis le premier caractere!

;NUMERO DE LIGNE: calcule la longueur et la stocke
t28:      move.l a5,d0
          sub.l #buftok,d0
          btst #0,d0
          beq.s t27
          addq #1,d0          ;si impair: L=L+1
          clr.b (a5)
t27:      lea buftok,a5
          move.w d0,(a5)      ;stocke la longueur de la ligne
          lea buftok,a6

; STOCKAGE-EFFACEMENT D'UNE LIGNE DE SOURCE DANS LA MEMOIRE
stockage: movem.l d0-d7/a0-a6,-(sp)
;quelque chose apres le numero de ligne?
          tst.b 4(a6)
          bne.s sk10
; essaie d'effacer la ligne
          tst autoflg         ;si auto en route
          beq.s sk0
          clr autoflg         ;on arrete auto, et on efface pas la ligne
          bra boucle
sk0:      move.w 2(a6),d0
          bsr findligne       ;la ligne existe-elle?
          bne.s sk1
          bsr deligne         ;enleve la ligne
          bra.s finsk        ;c'est fait
sk1:      move #3,d0          ;line does not exist
          bra erreur
; essaie de stocker la ligne
sk10:     move.w 2(a6),d0
          bsr findligne       ;la ligne existe-elle?
          beq.s sk15
; stockage simple: pas de ligne pre-existante
          move.w (a6),d0      ;longueur a liberer
          move 2(a6),d4
          bsr place           ;fait de la place
sk11:     subq #1,d0
sk12:     move.b (a6)+,(a5)+
          dbra d0,sk12
; fin du stockage: teste si il faut ecrire un numero de ligne (auto)
finsk:    tst autoflg
          beq.s finst1
          add autostep,d4
          bcs.s finst0
          move d4,lastline    ;derniere ligne entree en AUTO
          bsr affauto         ;va afficher le numero de la ligne suivante
          bra.s finst1
finst0:   clr autoflg
finst1:   bsr clearvar        ;va effacer les variables
          movem.l (sp)+,d0-d7/a0-a6
          rts
; il y a deja une ligne a cette adresse!
sk15:     tst autoflg         ;si AUTO
          beq.s sk15b
          clr autoflg         ;on l'arrete,
          move #4,d0         ;message: this line already exists
          bra erreur
sk15b:    move.w (a6),d0
          cmp.w (a5),d0
          beq.s sk11         ;chance! les lignes ont la meme taille!
          bcs.s sk16
          sub.w (a5),d0       ;nombre d'octets a rajouter
          bsr place           ;fait de la place
          move.w (a6),d0
          bra.s sk11
sk16:     clr.l d0
          move.w (a5),d0
          sub.w (a6),d0       ;nombre d'octets a enlever
          bsr delsrce         ;reduit le source
          move.w (a6),d0
          bra.s sk11

; TROUVE LA LIGNE D0 DANS LE SOURCE--->ADRESSE DANS A5 si trouve
findbis:  move.l a1,a5
          bra.s fd0
findligne:move.l dsource,a5            ; precedente dans a4
fd0:      sub.l a4,a4
fd1:      move.w (a5),d1
          beq.s fd4
          cmp.w 2(a5),d0
          beq.s fd2
          bcs.s fd3
          move.l a5,a4 
          add.w d1,a5
          bra.s fd1
fd2:      clr d1              ;z=1: trouve juste
          rts
fd3:      move #1,d1          ;z=0: trouve au dessus strictement
          rts
fd4:      move #-1,d1         ;tombe sur fin source: tester a4
          rts

; ENLEVE LA LIGNE POINTEE PAR A5
deligne:  clr.l d0
          move (a5),d0
delsrce:  move.l a5,a0        ;deuxieme entree: enleve d0 octets
          move.l a5,a1
          add.l d0,a0
          move.l fsource,d1
          sub.l a0,d1
          lsr.l #1,d1
del1:     move.w (a0)+,(a1)+
          subq.l #1,d1
          bne.s del1
del2:     sub.l d0,fsource    ;recule la fin du source
          rts

; FAIT DE LA PLACE POUR D0 CARACTERES A PARTIR DE A5
place:    move.l fsource,a0
          add.w d0,a0
          cmp.l himem,a0
          bcc.s outofmem
          move.l a0,fsource   ;avance la fin du programme
          move.l a0,a1
          sub.w d0,a0
pla1:     move.w -(a0),-(a1)
          cmp.l a5,a0
          bcc.s pla1
          rts
outofmem: move #2,d0          ;out of memory
          bra erreur

; INSTRUCTION UPPER
upper:    clr upperflg
          rts

; INSTRUCTION LOWER
lower:    move #1,upperflg
          rts

; DETOKENISATION DU BUFFER DE TOKENISATION--->BUFFER D'ENTREE
detokbuf: lea buftok,a6
detok:    movem.l d0-d7/a0-a6,-(sp)
          sub.l a3,a3
          move (a6),a3
          add.l a6,a3         ;adresse de fin de la ligne en a3
          lea buffer,a5
          addq.l #2,a6
          clr.l d0
          move.w (a6)+,d0
          bsr longdec         ;numero de ligne
          move.b #32,(a5)+
          move.b #$ff,d1      ;pas d'espace apres!
          clr remflg

dt1:      cmp.l a3,a6         ;fin de la ligne?
          bcc dt20
          move.b (a6)+,d0
          tst remflg          ;si REM: affiche tout!
          bne dt5a
          tst.b d0
          bmi dt2

; CE N'EST PAS UN TOKEN
          cmp.b #":",d0
          bne.s dt1a
          move.b #32,(a5)+    ;deux points, toujours avec des espaces!
          move.b #":",(a5)+
          move.b #32,(a5)+
          move.b #$ff,d1
          bra.s dt1
dt1a:     tst.b d1
          beq.s dt1b           ;pas un token: pas d'espace
          cmp.b #$b0,d1
          bcc.s dt1b         ;une fonction/operateur: pas d'espace!
          move.b #32,(a5)+    ;met un espace!
dt1b:     tst upperflg
          beq.s dt5a
          cmp.b #"A",d0       ;transforme en minuscule si flg a un!
          bcs.s dt5a
          cmp.b #"Z",d0
          bhi.s dt5a
          add.b #$20,d0
dt5a:     move.b d0,(a5)+     ;on stocke
          clr d1
          bra dt1            ;et on boucle

; C'EST UN TOKEN
dt2:      cmp.b #$98,d0       ;token particulier?
          bcs dt10
          cmp.b #$a0,d0
          bcs dr0
          cmp.b #$fa,d0
          bcs dt10
; DETOKENISE LES CODES PARTICULIERS
dr0:      move a6,d2          ;format: TOKEN/pair/ADRESSE MOT LONG/
          btst #0,d2
          beq.s dr1
          addq.l #1,a6        ;si impair: rend pair
dr1:      cmp.b #$a0,d0
          bcs dr21         ;branchement: va detokeniser
          tst.b d1
          beq.s dr1a         ;si lettre avant: RIEN
          cmp.b #$ea,d1
          bcc.s dr1a       ;si OPERATEUR avant: RIEN
          move.b #32,(a5)+
dr1a:     cmp.b #$fa,d0       ;variable ?
          beq dr19
; CHIFFRE HEXA
          cmp.b #$fd,d0
          bne.s dr2
          move.l (a6),d0
          move.l #-1,d3       ;representation limitee
          bsr longascii
          bra dr19
; CHIFFRE ENTIER
dr2:      cmp.b #$fe,d0
          bne.s dr3
          move.l (a6),d0      ;chiffer ENTIER
          bsr longdec
          bra dr19
; CHAINE ALPHANUMERIQUE
dr3:      cmp.b #$fc,d0
          bne.s dr6
          move.b #'"',(a5)+   ;guillemets!
          move.l (a6)+,d0
          subq #1,d0
          bmi.s dr5
dr4:      move.b (a6)+,(a5)+  ;recopie la chaine
          dbra d0,dr4
dr5:      move.b #'"',(a5)+   ;guillemets!
          clr d1              ;simule une lettre avant
          bra dt1
; CHIFFRE BINAIRE
dr6:      cmp.b #$fb,d0
          bne.s dr7
          move.l #-1,d3       ;representation limitee
          move.l (a6),d0
          bsr longbin
          bra dr19
; CHIFFRE FLOAT
dr7:      cmp.b #$ff,d0
          bne dt10
          move.l (a6)+,d1
          move.l (a6),d2
          move.l a5,-(sp)
          move #$3134,d3      ;jusqu'a 14 chiffres apres la virgule
          moveq #-1,d4        ;representation normale des floats
          moveq #0,d5         ;mode listings!
          bsr dtokfl
          move.l (sp)+,a0
          move.l a5,d1
          sub.l a0,d1         ;taille du chiffre float
          subq #1,d1
dr8:      cmp.b #".",(a0)     ;recherche un point
          beq.s dr19
          cmp.b #"E",(a0)+    ;ou un exposant
          beq.s dr19
          dbra d1,dr8
          move.b #".",(a5)+   ;y'en a pas: le met!
          move.b #"0",(a5)+
; FIN DES TOKENS PARTICULIERS
dr19:     clr d1              ;simule une lettre AVANT!
dr20:     addq.l #4,a6
          bra dt1
; TOKEN A BRANCHEMENT: saute l'adresse et dtokenise!
dr21:     addq.l #4,a6

; DETOKENISE LES TOKENS NORMAUX
dt10:     cmp.b #$ea,d1       ;si operateur avant: pas d'espace
          bcc.s dt10aa
          cmp.b #$ea,d0       ;si operateur: pas d'espace
          bcc.s dt10aa
          cmp.b #$b8,d0       ;si instruction: espace!
          bcs.s dt10ac
          tst.b d1            ;si fonction ET lettre avant: pas d'espace
          beq.s dt10aa
dt10ac:   move.b #32,(a5)+    ;espace!
dt10aa:   cmp.b #$8a,d0
          bne.s dt10ab
          move #1,remflg      ;si une REM: doit TOUT afficher apres!!!
dt10ab:   move.b d0,d1
          cmp.b #$a0,d0       ;est-ce un token etendu?
          bne.s dt10a
          lea tokext,a4       ;instruction etendue
          bra.s dt10b
dt10a:    cmp.b #$b8,d0       ;fonction etendue?
          bne.s dt11
          lea foncext,a4
dt10b:    move.b (a6)+,d0     ;prend le second code
; trouve un token etendu
dt10c:    cmp.b (a4)+,d1      ;cherche un code d'extension
          bne.s dt10c
          cmp.b (a4)+,d0      ;compare le second code
          bne.s dt10c
          subq.l #2,a4
dt10d:    move.b -(a4),d0
          bpl.s dt10d
          cmp.b d0,d1
          bne.s dt15
          addq.l #1,a4
          bra dt15
; est-ce une .EXT?
dt11:     cmp.b #$a8,d1       ;instruction .EXT
          beq.s dt11y
          cmp.b #$c0,d1       ;fonction .EXT
          bne dt11z
dt11y:    addq.l #2,a6        ;saute l'extension
          clr d0
          move.b -2(a6),d0    ;prend le numero de l'extension
          move.l adext,a0
          lsl #2,d0
          tst.l 0(a0,d0.w)    ;l'extension est-elle presente?
          bne.s dt11b
dt11a:    lea pxt-1,a4        ;l'extension n'est pas presente! EXTEND
          move.b -2(a6),pxt1
          add.b #"A",pxt1
          bra dt15
dt11b:    lea datext,a4
          lsl #1,d0
          move.l 0(a4,d0.w),a4
          move.b -1(a6),d2    ;prend le token
dt11c:    move.b (a4)+,d0
          beq.s dt11a         ;protection si l'extension n'est pas la bonne!
          cmp.b d0,d2
          bne.s dt11c
          subq.l #1,a4
dt11d:    tst.b -(a4)
          bpl.s dt11d
          bra dt15
; token NORMAL
dt11z:    lea tokens,a4
dt12:     cmp.b (a4)+,d1      ;exploration rapide de toute la table
          bne.s dt12
          subq.l #1,a4
dt13:     move.b -(a4),d0     ;le token est trouve
          bpl.s dt13         ;on retourne en arriere pour trouver le debut
; affiche le nom
dt15:     addq.l #1,a4        ;pointe le debut
dt16:     move.b (a4)+,d0     ;transfert du mot
          bmi dt1
          tst upperflg        ;si flg a un: transforme en majuscule
          beq.s dt17
          cmp.b #"a",d0
          bcs.s dt17
          cmp.b #"z",d0
          bhi.s dt17
          sub.b #$20,d0
dt17:     move.b d0,(a5)+
          bra.s dt16
; fin de la dtokenisation
dt20:     clr.b (a5)+         ;fin du buffer
          movem.l (sp)+,d0-d7/a0-a6
          rts                 ;retour de sous programme

;-----------------------------------------    --- ----- ---   ---    -------
;   -----------------------------------      |      |  |   | |
;   |     COMMANDES DE L'EDITEUR      |       ---   |  |   |  ---
;   -----------------------------------          |  |  |   |     |
;-----------------------------------------    ---       ---   ---    -------
; ACQUISITION DES PARAMETRES forme: XXXXX-YYYYY (a6 contient ad dans buftok)
params:   move.l dsource,a1
parambis: clr d4
          move #65535,d5
          move.b (a6),d0
          beq.s par2
          cmp.b #$f5,d0
          beq.s par3
          movem.l d5/a1,-(sp)
          bsr opentier        ;ramene un operande ENTIER
          movem.l (sp)+,d5/a1
          cmp.l #$10000,d3
          bcc foncall
          move d3,d4          ;premier numero!
          beq syntax
par2:     move.b (a6),d0
          bne.s par3
          tst d4
          beq.s par10
          move d4,d5
          bra.s par10
par3:     cmp.b #$f5,d0
          bne syntax
          addq.l #1,a6
          move.b (a6),d0
          beq.s par10
          movem.l a1/d4-d5,-(sp)
          bsr opentier
          movem.l (sp)+,a1/d4-d5
          cmp.l #$10000,d3
          bcc foncall
          move d3,d5

par10:    move.l a1,a6
          tst d4
          beq.s par13
par12:    move d4,d0
          bsr findbis
          move.l a5,a6
par13:    rts

;TEST TOUCHES LIST: 0=rien, >0=space, -1=ESC ou CTRL-C
ttlist:   bsr incle
          tst.l d0            ;pas d'appui sur une touche
          beq.s tl2
          cmp.b #32,d0
          beq.s tl3
          cmp.b #3,d0         ;CTRL C
          beq.s tl1
          swap d0
          cmp.b #1,d0         ;ESC
          beq.s tl1
          clr d0
          rts
tl1:      move #-1,d0
tl2:      rts
tl3:      move #1,d0
          rts

; RETOUR CHARIOT SUR ECRAN OU IMPRIMANTE
impretour:lea rchar,a0
; SORT SUR ECRAN OU IMPRIMANTE UNE CHAINE
impchaine:tst impflg
          bne.s ip
          move #1,d7          ;sur l'ecran!
          trap #3
          jmp avantint        ;teste les interruptions et revient!
; sortie sur imprimante
ip:       movem.l a3/d3,-(sp) 
          move.l a0,a3
          move.w #400,d3
          bra.s ip2
ip1:      jsr waitvbl
ip2:      clr.w -(sp)         ;bcostat sur l'imprimante
          move.w #8,-(sp)
          trap #13
          addq.l #4,sp
          tst d0              ;attend que l'imprimante soit prete
          bne.s ip3           ;en gerant les interruptions
          jsr avantint         
          dbra d3,ip1         ;compte les balayages d'ecran!
          bra prtnotr         ;printer not ready!
ip3:      clr.w d0
          move.b (a3)+,d0     ;c'est pret! envoyez c'est pes‚!
          beq.s fip
          move.w d0,-(sp)
          clr.w -(sp)
          move.w #3,-(sp)
          trap #13
          addq.l #6,sp
          move.w #400,d3      ;autorise +/- 7 secondes de delai
          bra.s ip2
fip:      move.l a3,a0
          movem.l (sp)+,a3/d3
          jmp avantint        ;teste les interruptions et revient

; PLUS RETOUR: ADDITIONNE UN RETOUR CHARIOT A LA FIN DU BUFFER
plusr:    move.l a0,-(sp)
plu:      tst.b (a0)+
          bne.s plu
          move.b #13,-1(a0)
          move.b #10,(a0)
          clr.b 1(a0)
          move.l (sp)+,a0
          rts

;LLIST
llist:    move #1,impflg
          bra.s lt0
;LIST
list:     clr impflg
lt0:      bsr params
          clr d2
          lea reparti,a4
          move program,d0
          lsl #4,d0
          add d0,a4          ;a4 pointe le debut table reparti
          move fenetre,d0
          beq.s lt1            ;fenetre zero: on lte tout!
          tst impflg
          bne.s lt1            ;imprimante: on liste tout!
          bsr fenconv
          subq #1,d0
          lsl #2,d0
          add.w d0,a4        ;pointe la fenetre dans le programme
          cmp.w (a4),d5
          bcs.s lt11           ;pas ltable!
          cmp.w 2(a4),d4
          bhi.s lt11           ; "     "
          cmp.w (a4),d4
          bcc.s lst0
          move.w (a4),d4
lst0:     cmp.w 2(a4),d5
          bls.s lst1
          move.w 2(a4),d5
lst1:     bsr par10          ;recalcule!

lt1:      tst (a6)
          beq.s lt10
          cmp 2(a6),d5        ;d5 dernier numero valable
          bcs.s lt11
          bsr detok
          lea buffer,a0       ;impression a l'ecran
          bsr plusr
          bsr impchaine
          add (a6),a6         ;pointe la ligne suivante
          bsr ttlist
          beq.s lt1           ;pas d'appui
          bmi.s lt11          ;appui sur ESC
lt6:      bsr ttlist
          beq.s lt6
          bmi.s lt11
          bra.s lt1
lt10:     bsr lstbk1          ;on liste-->fin, imprime les banques
lt11:     bra ok

; DELETE
delete:   bsr params
          tst d4
          beq notdone
          cmp #65535,d5
          beq notdone
          move.l a6,a5
dl1:      tst (a6)            ;trouve debut/fin a enlever
          beq.s dl2
          cmp 2(a6),d5
          bcs.s dl2
          add (a6),a6
          bra.s dl1
dl2:      move.l a6,d0        ;calcule la longueur
          sub.l a5,d0
          bsr delsrce         ;delete!
          bsr clearvar        ;efface les variables!
          bra ok
notdone:  move #0,d0
          bra erreur

; RENUM [debut,pas,10-1000]
renum:    bsr clear           ;TOUT TOUT PROPRE !!!
          jsr finie
          bne.s r1
          moveq #10,d3
          bra.s r2
r1:       bsr expentier
          tst.l d3
          beq foncall
          cmp.l #65535,d3
          bcc foncall
r2:       move d3,buffer
          jsr finie
          bne.s r3
          moveq #10,d3
          bra.s r4
r3:       cmp.b #",",(a6)+
          bne syntax
          bsr expentier
          tst.l d3
          beq foncall
          cmp.l #65535,d3
          bcc foncall
r4:       move d3,buffer+2
          jsr finie
          beq.s r4a
          cmp.b #",",(a6)+
          bne syntax
r4a:      bsr params
          move.l a6,buffer+4
          move d4,buffer+8
          move d5,buffer+10
          move.l a6,a1
; construit la table
          move.l hichaine,a2  ;table des changements!
          move.l lowvar,a3    ;maximum!
          move.w buffer,d2    ;debut
          move.w buffer+2,d3  ;pas
r5:       cmp.l a3,a2
          bcc outofmm         ;cant renum!
          tst (a1)
          beq.s r6
          move 2(a1),d0
          cmp d0,d5
          bcs.s r6
          move.w d0,(a2)+
          move.w d2,(a2)+
          add.w d3,d2         ;ca va trop loin!
          bcs cantren
          add.w (a1),a1
          bra.s r5
r6:       cmp.l hichaine,a2   ;on a rien fait!
          beq ok
; verifie que la renumerotation est possible!
          move.w buffer,d2    ;bas de la renumerotation
          move.w -2(a2),d3    ;haut
          move.l dsource,a1
r10:      tst.w (a1)
          beq.s r13
          move.w 2(a1),d0
          cmp d4,d0           ;une ligne INFERIEURE
          bcc.s r11
          cmp d2,d0           ;doit rester INFERIEURE!
          bcc cantren
r11:      cmp d5,d0           ;une ligne SUPERIEURE
          bcs.s r12
          cmp d3,d0           ;doit rester SUPERIEURE!
          bls cantren
r12:      add (a1),a1
          bra.s r10
; on peut renumeroter: change tous les GOTO/GOSUB etc!!!
r13:      move.l dsource,a0
r15:      tst.w (a0)
          beq r30
          lea 4(a0),a1
          clr d2
r16:      move.b (a1)+,d0
          beq.s r19
          bpl.s r16
          cmp.b #$a0,d0
          beq.s r17
          cmp.b #$b8,d0
          beq.s r17
          cmp.b #$a8,d0
          beq.s r16a
          cmp.b #$c0,d0
          bne.s r18
r16a:     addq.l #1,a1
r17:      addq.l #1,a1
          bra.s r16
r18:      cmp.b #$fa,d0
          bcc.s r18a
          cmp.b #$98,d0
          bcs.s r18d
          cmp.b #$a0,d0
          bcc.s r16
r18a:     move a1,d1          ;rend pair
          btst #0,d1
          beq.s r18b
          addq.l #1,a1
r18b:     cmp.b #$ff,d0       ;constante float?
          bne.s r18c
          addq.l #4,a1
r18c:     addq.l #4,a1
          cmp.b #$9c,d0       ;restore
          bls.s r20
          bra.s r16
r18d:     cmp.b #$8e,d0       ;resume
          beq.s r20
          bra r16
r19:      add (a0),a0         ;ligne suivante
          bra r15
; renumerote un goto/gosub/restore/resume/then/else NORMAL
r20:      cmp.b #$fe,(a1)     ;veut une CONSTANTE DECIMALE ENTIERE
          bne r16
          addq.l #1,a1
          move a1,d1
          btst #0,d1
          beq.s sn2
          addq.l #1,a1
sn2:      move.l (a1)+,d1     ;si SYNTAX ERREUR: on ne fait rien!
          cmp.l #65535,d1
          bhi sn5
          move.l hichaine,a3  ;explore la table
sn3:      cmp.w (a3),d1
          beq.s sn4
          addq.l #4,a3
          cmp.l a2,a3
          bcs.s sn3
          bra.s sn5
sn4:      move.w 2(a3),d1     ;RENUMEROTE!!!
          move.l d1,-4(a1)
sn5:      cmp.b #",",(a1)     ;si une virgule apres,
          bne r16
          addq.l #1,a1
          bra r20
; change les numeros des lignes
r30:      move.l buffer+4,a1
          move.w buffer+10,d5
          move.w buffer,d2
          move.w buffer+2,d3
r31:      tst.w (a1)          ;OUF!!!
          beq ok
          cmp.w 2(a1),d5
          bcs ok
          move.w d2,2(a1)
          add.w d3,d2
          add.w (a1),a1
          bra r31
cantren:  moveq #11,d0
          jmp erreur

; NEW
new:      movem.l a4-a6,-(sp)
; effacement du programme
          move.l dsource,a0
          move.l (a0),unewpos ;sauve pour un unnew
          clr (a0)
          add.l #2,a0
          move.l a0,fsource
; effacement des banques 
          bsr stopall         ;va tout arreter
          move.l himem,-(sp)
          move.l topmem,himem ;efface les banques
          move.l adatabank,a0
          lea unewbank,a1
          move #15,d0
new1:     move.l (a0),(a1)+   ;sauve les banques des donnee
          clr.l (a0)+         ;les efface!
          dbra d0,new1
          bsr clearvar
          move.l (sp)+,unewhi ;ancien himem
; Remet l'auto en 10
          move.w #10,autostep
          move.w #10,lastline
          movem.l (sp)+,a4-a6
          rts

; UNNEW
unnew:    move.l adatabank,a0
          cmp.l #2,(a0)+
          bne notdone         ;si on a entre du source entretemps: ZOB!
          move #14,d0
unew0:    tst.l (a0)+         ;si on a initialise un banque
          bne notdone         ;entretemps: BERNIQUE!
          dbra d0,unew0
          move.l lowvar,d0    ;si une variable a ete initialisee: rien!
          cmp.l himem,d0
          bne notdone
          move.l unewhi,d0    ;cretin: pas de NEW avant!
          beq notdone
; fait le unnew
          move.l d0,himem
          lea unewbank,a0
          move.l (a0),d0      ;premiere banque= longueur du source
          add.l dsource,d0
          move.l d0,fsource
          move.l adatabank,a1
          move #15,d0
unew1:    move.l (a0)+,(a1)+  ;recopie les banques de donnee
          dbra d0,unew1
          move.l dsource,a0   ;repoke la premiere ligne
          move.l unewpos,(a0)
          bsr clearvar
          bra ok

;TROUVE: CHERCHE UNE CHAINE DANS LE BUFFER a partir de d0,a5=ad chaine
trouve:   lea buffer,a0
          lea bs,a5
tv1:      clr d1
          move d0,d4        ;d4= position de la chaine dans le buffer
tv2:      move.b 0(a5,d1.w),d3
          beq.s tv4        ;tv‚!
          move.b 0(a0,d0.w),d2
          beq.s tv5        ;pas tv‚!
          cmp.b d2,d3
          beq.s tv3
          addq #1,d0
          bra.s tv1
tv3:      addq #1,d1
          addq #1,d0
          bra.s tv2
tv4:      move #1,d2          ;tve: z=1
tv5:      rts                 ;pas trouve: z=0

; SEARCH: TROUVE UNE CHAINE DANS LE SOURCE
search:   tst.b (a6)
          beq searnext
          bsr expalpha        ;va chercher la chaine
          cmp.l #40,d2
          bcc syntax          ;40 caracteres seulement
          lea bs,a0
          bsr chverbuf2
          cmp.b #",",(a6)+
          beq.s sh3
          subq.l #1,a6
sh3:      bsr params          ;parametres
          move d4,searchd     ;numero de la 1ere ligne
          move d5,searchf     ;numero de la derniere ligne
searnext: lea bs,a0
          tst.l searchd
          beq shfail
          tst.b (a0)          ;pas de chaine!
          beq shfail
          move searchf,d6     ;fin de la recherche
          move searchd,d0
          bsr findligne       ;numero de ligne en a6
          move.l a5,a6
sh0:      bsr ttlist
          bmi braik
          tst.w (a6)
          beq shfail
          cmp 2(a6),d6
          bcs shfail
          bsr detok           ;detokenise dans le BUFFER
          add (a6),a6         ;actualise le pointeur pour search next
          tst.w (a6)
          bne.s sh1
          clr.l searchd
          bra.s sh2
sh1:      move 2(a6),searchd
sh2:      clr d0              ;trouve le premier
          bsr trouve          ;cherche dans le buffer
          beq.s sh0
;trouv‚!
          lea buffer,a0
          move #1,d7
          trap #3
          bsr retour
          bra ok
;la recherche a echoue!
shfail:   clr.l searchd      ;empeche un nouveau search next
          move #5,d0
          bra erreur

;EXCHANGE
exchange: bsr expalpha        ;premiere chaine
          tst d2
          beq syntax
          cmp.l #40,d2
          bcc syntax
          lea bs,a0
          bsr chverbuf2
          cmp.b #$80,(a6)+    ;token de TO
          bne syntax
          bsr expalpha        ;deuxieme chaine
          tst d2
          beq syntax
          cmp.l #40,d2
          bcc syntax
          move d2,-(sp)       ;taille de la deuxieme chaine
          lea bs,a0
          add #42,a0
          bsr chverbuf2
          cmp.b #",",(a6)+
          beq.s ex0
          subq.l #1,a6
ex0:      bsr params
          move (sp)+,d6       ;d6=taille deuxieme chaine
;detokenise une nouvelle ligne
ex1:      tst (a6)
          beq ok
          cmp 2(a6),d5
          bcs ok
          bsr detok           ;detokenise dans le buffer
          clr d0              ;recherche depuis le debut
          clr d7              ;flag a zero
ex2:      bsr trouve
          beq ex10            ;ligne suivante
;le premier mot est trouve: enleve l'ancien mot
          tst d4              ;ne change pas les numeros de ligne!!!!
          beq ex10
          lea buffer,a0
          add d4,a0
          move.l a0,a2        ;copie pour plus tard
ex4:      move.b 0(a0,d1.w),(a0)+
          bne.s ex4
;fait la place pour le nouveau mot
          move.l a0,a1
          add d6,a1
          cmp.l #buftok,a1    ;deborde la taille du buffer!
          bcc ex12
ex5:      move.b -(a0),-(a1)  ;fait la place!
          cmp.l a2,a0
          bcc.s ex5
;poke le nouveau mot
          move #1,d7          ;FLAG: la ligne a ete changee!
          add #42,a5
ex6:      move.b (a5)+,d1
          beq.s ex7
          move.b d1,(a2)+
          bra.s ex6
ex7:      move.l a2,d0
          sub.l #buffer,d0    ;le nouveau pointeur!
          bra ex2           ;cherche a partir de l…...
;met la ligne dans le source s'il faut
ex10:     tst d7
          beq.s ex11
          movem.l d0-d7/a0-a6,-(sp)
          bsr tokenise
          movem.l (sp)+,d0-d7/a0-a6
ex11:     add (a6),a6         ;ligne suivante
          bsr ttlist          ;appui sur ctrl-c ou esc?
          bpl ex1
          bra braik
; ne peut pas changer la ligne!
ex12:     lea cantex,a0
          move #1,d7
          trap #3
          bsr detok           ;remet la ligne
          lea buffer,a0       ;va l'afficher
          trap #3
          bsr retour
          add (a6),a6         ;passe a la ligne suivante
          bra ex1

;AMBIANCE: passe a la palette suivante
ambiance: tst.b (a6)
          bne syntax
          add #1,ambia
          cmp #13,ambia
          bcs.s pokeamb
          clr ambia
;poke la palette pointee
pokeamb:  lea pd,a0
          move.l adlogic,a1
          add.l #32000,a1
          move.l a1,a2
          moveq #15,d0
amb0:     move.w (a0)+,(a2)+
          dbra d0,amb0
          move ambia,d0
          cmp #2,mode
          beq.s amb2 
          lea db,a0
          lsl #2,d0
          move.l 0(a0,d0.w),(a1)
          bra.s amb3
amb2:     lea dh,a0
          lsl #1,d0
          move.w 0(a0,d0.w),(a1)
amb3:     bsr setpalet        ;l'envoie au XBIOS en revient
; fait flasher la couleur du curseur si mode COULEUR!
flashcur: cmp #2,mode
          beq.s amb7
          lea fd,a0
          moveq #2,d1
          moveq #40,d0        ;flashinit couleur #2
          trap #5
amb7:     rts

; FREQUENCE: PASSE EN 60/50 HERZ SI COULEUR!
freq:     cmp #2,mode         ;pas en HIRES
          beq foncall
          bchg #1,$ff820a     ;change dans le circuit
          rts

;-----------------------------------------------------------------------------
;LOAD/SAVE et assimiles
;-----------------------------------------------------------------------------
;SETDTA: initialise la zone d'echange avec la disquette
setdta:   move.l #dta,-(sp)
          move.w #$1a,-(sp)
          trap #1
          addq.l #6,sp
          rts

;SFIRST: CHERCHE UN NOM SUR LE DISQUE (A0) POINTE LE NOM
sfirst:   move.w d0,-(sp)
          move.l a0,-(sp)
          move.w #$4e,-(sp)
          trap #1
          addq.l #8,sp
          lea dta,a0          ;pointe le nom du fichier!!!
          add #30,a0
          tst d0
          rts

; SNEXT
snext:    move.w #$4f,-(sp)
          trap #1
          addq.l #2,sp
          lea dta,a0
          add #30,a0          ;pointe le nom du fichier
          tst d0
          rts

;UNLINK: KILL UN FICHIER SUR LE DISQUE
unlink:   move.l a0,-(sp)
          move.w #$41,-(sp)
          trap #1
          add.l #6,sp
          tst d0
          rts

;RENAME
renome:   move.l a1,-(sp)               ;new name
          move.l a0,-(sp)               ;old name
          clr.w -(sp)
          move #$56,-(sp)
          trap #1
          add.l #12,sp
          tst d0
          rts

;CREATE: CREE UN FICHIER SUR LA DISQUETTE
create:   move.w d0,-(sp)
          move.l a0,-(sp)
          move.w #$3c,-(sp)
          trap #1
          add.l #8,sp
          tst d0
          rts

;OPEN: OUVRE UN FICHIER DEJA CREE
open:     move.w d0,-(sp)
          move.l a0,-(sp)
          move.w #$3d,-(sp)
          trap #1
          add.l #8,sp
          tst d0
          rts

;WRITE: ECRIS LES DONNEES POINTEES PAR A0 LONG D0, EN HANDLE D7
write:    move.l d1,-(sp)     ;sauve D1
          move.l a0,-(sp)
          move.l d0,-(sp)
          move.w handle,-(sp)
          move.w #$40,-(sp)
          trap #1
          addq.l #4,sp
          move.l (sp)+,d1
          addq.l #4,sp
          tst.l d0
          bmi.s WF   
          cmp.l d0,d1         ;Si longueur sauvee<>longueur demandee
          beq.s WF            ;alors erreur: disk full!
          moveq #-39,d0
WF:       move.l (sp)+,d1     ;recupere D1
          tst.l d0
          rts

;READ: LIS LES DONNEES DANS UN TAMPON (A0) LONG D0
readisk:  move.l a0,-(sp)
          move.l d0,-(sp)
          move.w handle,-(sp)
          move.w #$3f,-(sp)
          trap #1
          add.l #12,sp
          tst.l d0
          rts

;CLOSE: FERME LE FICHIER SYSTEME
close:    move.w handle,d0
          beq close2
          clr handle
close1:   move d0,-(sp)       ;entree pour l'instruction close
          move.w #$3e,-(sp)
          trap #1
          addq.l #4,sp
          tst d0
close2:   rts

;TRANSTEXT: TRANSFERT UN TEXTE DE (A0)--->(A1) zero a la fin
transtext:move.b (a0)+,(a1)+
          bne transtext
          rts

;PREND UN NOM DISQUE ET LE VERIFIE: RETOUR 1 SI IL Y A UNE EXTENSION
namedisk: bsr expalpha        ;va chercher la chaine
namedbis: 
;          cmp #2,d2
;          bcs.s nd0
;          cmp.b #":",1(a2)    ;changes drive
;          bne.s nd0
;          clr.l d3
;          move.b (a2),d3
;          addq.l #2,a2
;          subq #2,d2
;          movem.l d2/a2,-(sp)
;          bsr drived0
;          movem.l (sp)+,d2/a2      
nd0:
          tst d2
          beq badname
          cmp #63,d2
          bcc foncall
          subq #1,d2
          move d2,d1
          lea name1,a1
nd1:      move.b (a2)+,(a1)+  ;recopie dans name1
          dbra d2,nd1
          clr.b (a1)          ;avec un zero a la fin
          move.l a1,a0
nd2:      cmp.b #".",-(a0)    ;explore le nom par la fin
          beq.s nd5
          cmp.b #"\",(a0)
          beq.s nd3
          dbra d1,nd2
nd3:      move.l a1,a0        ;zero: pas d'extension, a0/a1 pointe fin de nom
          clr.l d0
          rts
nd5:      addq.l #1,a0        ;un: extension, a0 pointe le debut de l'ext
          moveq #1,d0
          rts

; FSAVE: SAUVE UN FICHIER AVEC LE FILE SELECTOR
fsave:    lea fs,a0
          bsr traduit
          bsr ffsel
          bsr setdta
          clr.l d2
          move.l d3,a2
          move.w (a2)+,d2
          beq notdone
          bsr namedbis        ; si l'extension est .BAS, enleve
          beq.s fsa2          ; pour faire un .BAK
          cmp.b #"B",(a0)
          bne.s fsa2
          cmp.b #"A",1(a0)
          bne.s fsa2
          cmp.b #"S",2(a0)
          bne.s fsa2
          subq.l #1,a0
          move.l a0,a1
          clr.b (a0)
          bra.s fsa2
fsa1:     moveq #1,d0 
fsa2:     bsr save3
          bra ok
          
;SAVE: FAIT UN .BAK SI IL N'Y A PAS D'EXTENSION
save:     bsr setdta
          bsr namedisk        ;va chercher le nom du fichier
save3:    beq save0           ;pas d'extension: on fait un .bak
; verifie l'extension: branche aux routines
          bsr disknom
          tst d0
          beq save2           ;une extension non reconnue: fichier BASIC
          cmp #4,d0
          bls picsave         ;.NEO/.PI1/.PI2./PI3
          cmp #5,d0
          beq savembk         ;sauve une banque memoire
          cmp #6,d0
          beq savembs         ;sauve toutes les banques memoire
          cmp #7,d0
          beq saveprg         ;faire un .PRG
          cmp #8,d0
          beq savevar
          cmp #9,d0
          beq savasc
          bra badname         ;IMPOSSIBLE!
; fabrique l'extension
save0:    tst runflg
          bne illegal         ;interdit dans un programme
          lea bak,a0
          move.l a1,-(sp)
          bsr transtext       ;ecris .bak apres le nom
          lea name1,a0
          lea name2,a1
          bsr transtext       ;NAME2: XXXXXXXX.BAK
          move.l (sp)+,a1
          lea bas,a0
          bsr transtext       ;NAME1: XXXXXXXX.BAS
; fabrique le .BAK
          lea name1,a0
          clr d0
          bsr sfirst          ;cherche le .bas
          bne.s save2
          lea name2,a0
          clr d0
          bsr sfirst          ;cherche le .bak
          bne.s save1
          lea name2,a0
          bsr unlink          ;efface le .bak
          bmi diskerr
save1:    lea name1,a0
          lea name2,a1
          bsr renome
          bmi diskerr
; ecris le fichier BASIC
save2:    tst runflg          ;interdit en programme
          bne illegal
          bsr chaine          ;chaine toutes les parties du programme
          clr d0              ;fichier lecture/ecriture
          lea name1,a0
          bsr create
          bmi saverr
          move d0,handle
          lea cbs,a0
          move.l #10,d0
          bsr write           ;ecris la reconnaissance du basic
          bmi saverr
          move.l adataprg,a0
          addq.l #4,a0
          moveq #4,d0
          bsr write           ;ecris la longueur DATAPRG
          bmi saverr
          move.l adatabank,a0
          move.l #16*4,d0
          bsr write           ;ecris DATABANK
          bmi saverr
          move.l adataprg,a1
          move.l (a1)+,a0     ;adresse de la premiere banque
          move.l (a1),d0      ;longueur totale du programme
          bsr write           ;ecris le source
          bmi saverr
          bsr close           ;ferme le fichier
          bsr dechaine        ;rechaine les banques de memoire BUGBUGBUGBUG!
          rts
saverr:   move.l d0,-(sp)
          bsr dechaine        ;DECHAINE le programme!!!
          move.l (sp)+,d0
          bra varserr         ;efface le peu ecrit sur le disque!!
; ERREURS DE DISQUE
diskerr:  tst acldflg         ;charge-t-on un accessoire?
          beq dkerr0
          bsr close           ;si OUI: on ferme le fichier systeme 
          moveq #1,d0         ;et on revient tout de suite
          rts
dkerr0:   cmp #-33,d0
          beq.s dk1
          cmp #-39,d0
          beq.s dk2
          cmp #-2,d0
          beq.s dk3
          cmp #-13,d0
          beq.s dk4
dk:       moveq #52,d0
          bra erreur
dk1:      moveq #48,d0         ;file not found
          bra erreur
dk2:      moveq #51,d0
          bra erreur
dk3:      moveq #49,d0
          bra erreur
dk4:      moveq #50,d0
          bra erreur
filopen:  moveq #62,d0         ;file already open
          bra erreur
fileclos: moveq #63,d0         ;file already closed
          bra erreur
filtmis:  moveq #60,d0         ;file type mismatch
          bra erreur
filnotop: moveq #59,d0         ;file not open
          bra erreur
eofmet:   moveq #64,d0         ;End of file
          bra erreur
inptoolg: moveq #65,d0         ;input string too long
          bra erreur
fldtoolg: moveq #66,d0         ;Field too long
          bra erreur
; BAD DISK NAME
badname:  moveq #53,d0
          bra erreur
; DRIVE NOT CONNECTED
drvnotc:  moveq #83,d0
          bra erreur

; SAVE "nom.PRG": sauve le programme en  !!! RUN ONLY !!! GENIAL !!!
saveprg:  tst runflg
          bne illegal
          clr.b -1(a0)        ;enleve l'extension 
          bsr sure
          bne notdone
          move.l himem,a0
          sub.l fsource,a0
          cmp.l #4000,a0      ;il faut au moins 4K pour travailler!
          bcs outofmm         
          lea name1,a0
          lea name2,a1
          move.l a0,a2
sg:       move.b (a0)+,d0     ;recopie name2--> name2
          move.b d0,(a1)+
          beq.s sg1
          cmp.b #"\",d0       ;repere la fin du path
          bne.s sg
sg0:      move.l a0,a2        
          bra.s sg
sg1:      move.l a2,a1
          lea name2,a0
sg2:      move.b (a1)+,(a0)+  ;recopie le nom dans NAME2
          bne.s sg2
          move.l a2,-(sp)     ;ancien path
          lea stos,a1
sg3:      move.b (a1)+,(a2)+  ;folder STOS\ ajoute a NAME1
          bne.s sg3
          subq.l #1,a2        ;a2 pointe la fin du path dans name1
          move.l a2,-(sp)
; message
          lea prgmes,a0
          bsr traduit
          moveq #1,d7
          trap #3             ;introduce and press...
          bsr clearkey
          bsr waitkey         ;attend
; sauve le programme.BAS
          move.l (sp),a1     ;fin du path
          lea name2,a0
          bsr transtext       ;recopie le nom
          subq.l #1,a1
          lea bas,a0
          bsr transtext       ;avec .BAS a la fin dans NAME1
          bsr save2           ;va sauver le programme dans le folder
; fabrique le .PRG loader
          move.l (sp)+,a1      
          lea prgrun,a0       ;loader
          bsr transtext
          lea name1,a0
          moveq #0,d0
          bsr sfirst
          bne diskerr
          lea name1,a0
          moveq #0,d0
          bsr open
          bmi diskerr
          move d0,handle
          move.l fsource,a0
          addq.l #8,a0
          move.l a0,a2
          move.l dta+26,d2    ;longueur du fichier
          move.l d2,d0
          bsr readisk         ;va lire le loader
          bmi diskerr
          bsr close
          move.l a2,a1
          add #$1c,a1
          addq.l #4,a1        ;saute le BRA
          lea name2,a0
          bsr transtext       ;recopie le nom
          subq.l #1,a1
          lea bas,a0
          bsr transtext       ;avec .BAS a la fin!
          move.l (sp)+,a1     ;ancien path
          lea name2,a0
          bsr transtext
          subq.l #1,a1
          lea prg,a0
          bsr transtext       ;NOM.PRG en name1
          lea name1,a0
          moveq #0,d0
          bsr create
          bmi diskerr
          move d0,handle
          move.l a2,a0        ;adresse de depart
          move.l d2,d0        ;longueur a ecrire
          bsr write
          bmi diskerr
          bsr close
          bra ok

;OUVREVAR
ouvrevar: lea cvr,a1      ;codage: LIONPOUVAR
          bra ouvre
;OUVREBNK
ouvrebank:lea cbk,a1     ;codage: LIONPOUBNK
          bra ouvre
;OUVREBAS: ouvre un fichier SOURCE BASIC en le verifiant
ouvrebas: lea cbs,a1            ;codage: LIONPOULOS
ouvre:  
          move.l a0,-(sp)
          clr.l d0
          bsr sfirst
          bne dk1
          move.l (sp)+,a0
ouvreacc: move.l dta+26,d6    ;entree pour ACCLOAD (pas de SFIRST)
          moveq #0,d0
          bsr open            ;va ouvrir le fichier
          bmi diskerr
          move d0,handle
          move.l #10,d0       ;lis le codage du fichier
          lea buffer,a0
          bsr readisk
          bmi diskerr
          lea buffer,a0
          move #9,d0
ouvre2:   move.b (a0)+,d1
          cmp.b (a1)+,d1
          bne noformat
          dbra d0,ouvre2
          sub.l #10,d6        ;ramene la longueur du fichier en D6
          clr d0
          rts
noformat: moveq #1,d0         ;ne branche au message d'erreur
          tst acldflg         ;que si pas accessoire!!!!
          beq erreur
          rts

; SAVE .ASC: sauve un fichier ASC
savasc:   tst runflg
          bne illegal
          lea name1,a0
          clr d0
          bsr create
          bmi diskerr
          move d0,handle
          move.l dsource,a6
sva:      tst (a6)
          beq.s sva2
          bsr detok
          lea buffer,a0
          bsr plusr
          moveq #0,d0
sva1:     addq #1,d0
          tst.b (a0)+
          bne.s sva1
          subq #1,d0
          lea buffer,a0
          bsr write
          bmi diskerr
          add.w (a6),a6
          bra.s sva
sva2:     bsr close
          bra ok

; FLOAD: GENIAL, CHARGE AVEC LE FILE SELECTOR!
fload:    lea fc,a0
          bsr traduit
          bsr ffsel           ;va chercher le fichier
          bsr setdta
          move.l d3,a2
          clr.l d2
          move.w (a2)+,d2
          beq notdone
          bsr namedbis
          bsr load0
          bra ok

;LOAD:
load:     bsr setdta
          bsr namedisk        ;cherche le nom
load0:    bne.s load1
          lea bas,a0          ;pas d'extension, fichier basic! ->.BAS
          bsr transtext
          bra.s load2
load1:    bsr disknom         ;une extension!
          tst d0
          beq load2           ;ne correspond a rien---> fichier BASIC
          cmp #4,d0
          bls picload         ;1<ext<5---> neo/pi1/pi2/pi3
          cmp #5,d0
          beq loadmbk         ;une banque de memoire
          cmp #6,d0
          beq loadmbs         ;toutes les banques
          cmp #7,d0
          beq loadprg         ;programme
          cmp #8,d0
          beq loadvar
          cmp #9,d0           ;fichier ASCII
          beq loadasc
          bra badname         ;IMPOSSIBLE!
; LOAD "XXXXX.BAS"
load2:    tst runflg
          bne illegal         ;interdit en mode programme!!!!
load3:    lea name1,a0
          bsr ouvrebas        ;ouvre un fichier SOURCE BASIC
          subq.l #4,d6
          sub.l #16*4,d6
          add.l dsource,d6    ;d6= taille du prg + banques
          cmp.l topmem,d6
          bcc outofmem
; OK: charge le programme BASIC
loadbis:  bsr new             ;va faire un new
          move.l adataprg,a0
          addq.l #4,a0        ;pointe la longueur du prg
          moveq #4,d0
          bsr readisk         ;lis dataprg
          bmi errload
          move.l adatabank,a0
          move.l #16*4,d0
          bsr readisk         ;lis databank
          bmi errload
          move.l adataprg,a0
          move.l 4(a0),d0     ;prend la longueur du source
          move.l dsource,a0
          bsr readisk         ;lis le source
          bmi errload
          bsr close
          bsr dechaine        ;va dechainer les banques memoire
          clr d0
          rts
errload:  bsr new             ;efface le peu qui a ete charge
          clr.l d0            ;affiche DISK ERROR ou revient si ACCESSOIRE!
          bra diskerr

; LOAD .ASC: charge un fichier ASCII
loadasc:  tst runflg
          bne illegal
          lea name1,a0
          moveq #0,d0
          bsr sfirst
          bne dk1
          moveq #0,d0
          lea name1,a0
          bsr open
          bmi dk
          move d0,handle
          move.l dta+26,d1      ;taille du fichier
; merge le fichier
lz1:      lea buffer,a0
          move #499,d0
lz2:      movem.l a0/d0-d1,-(sp)
          moveq #1,d0
          bsr readisk
          bmi diskerr
          movem.l (sp)+,a0/d0-d1
          subq.l #1,d1
          cmp.b #13,-1(a0)
          bne.s lz3
          cmp.b #10,(a0)
          beq.s lz5
lz3:      cmp.b #10,-1(a0)
          bne.s lz4
          cmp.b #13,(a0)
          beq.s lz5
lz4:      cmp.b #10,(a0)
          beq.s lz8
          cmp.b #13,(a0)
          beq.s lz8
          cmp.b #32,(a0)        ;si code ASCII<32
          bcc.s lz8
          move.b #32,(a0)       ;remplace par 32!
lz8:      addq.l #1,a0
          tst.l d1
          beq.s lz7
          dbra d0,lz2
          bra dk  
lz5:      move.l d1,-(sp)
          clr.b -1(a0)
          lea buffer,a0         ;va afficher la chaine
          moveq #1,d7
          trap #3
          bsr retour            ;retour chariot
          lea buffer,a0
lz6:      move.b (a0)+,d0
          cmp.b #32,d0
          beq.s lz6
          cmp.b #"1",d0         ;ignore les lignes sans chiffre!
          bcs.s lz9
          cmp.b #"9",d0
          bhi.s lz9
          move.l himem,d0       ;au moins 728 octets de rab!
          sub.l fsource,d0
          cmp.l #$300,d0
          bcs dk
          bsr tokenise
lz9:      move.l (sp)+,d1
          bne lz1
; fin du chargement
lz7:      bsr close
          bra ok

; ACCESSORY LOAD
accload:  bsr setdta
          bsr namedisk
          bne.s al0
          lea acb,a0          ;pas d'extension: ecris .ACB
          bsr transtext
          bra.s al
al0:      bsr disknom
          tst d0              ;bad file name!!!
          bne badname
al:       lea name1,a0
; entree systeme
accldbis: clr.l d0
          bsr sfirst
          bne al10
          move program,-(sp)
al1:      move posacc,d0      ;numero de l'accessoire a charger
          cmp #16,d0
          bcc al6

          move #1,acldflg
          bsr active          ;active le programme "accessoire"
          lea dta,a0
          add #30,a0          ;pointe le nom du fichier
          lea cbs,a1
          bsr ouvreacc        ;ouvre et verifie le fichier
          bne al5
; teste la memoire
          subq.l #4,d6
          sub.l #16*4,d6
          add.l dsource,d6    ;d6= taille du prg + banques
          add.l #8192,d6      ;plus 8k de securite!
          cmp.l topmem,d6
          bcs.s ala
          bsr close           ;plus de place: arrete de charger 
          bra.s al6           ;sans message d'erreur
ala:      bsr loadbis         ;charge le programme
          bne.s al5
; ecris le nom de l'accessoire dans la table
          move posacc,d0
          subq #4,d0
          mulu #8,d0
          lea accnames,a1
          add.w d0,a1         ;pointe le nom de l'accessoire
          lea dta,a0
          add #30,a0
          move #7,d0
al2:      move.b (a0)+,d1     ;ecris le nom, et fini par des 32
          beq.s al3
          cmp.b #".",d1
          beq.s al3
          move.b d1,(a1)+
          dbra d0,al2
          bra.s al4
al3:      move.b #32,(a1)+
          dbra d0,al3
al4:      add #1,posacc       ;un accessoire de plus!
al5:      bsr snext
          beq al1
; fin du chargement des accessoires
al6:      move (sp)+,d0
          bsr active          ;reactive le programme courant
          clr acldflg
al10:     rts

; DISKNOM: teste l'extension: ;1=IMG, 2=PI0, 3=PI1, 4=PI2
disknom:  lea nomdisk,a2      ;5=MBK, 6=MBS, 7=PRG, 8=VAR
          moveq #1,d0         ;ZERO= AUCUNE!!!
npic1:    moveq #2,d1
          move.l a0,a1
npic2:    move.b (a1)+,d2
          cmp.b #"A",d2
          bcs.s npic2a
          cmp.b #"Z",d2
          bhi.s npic2a
          add.b #$20,d2
npic2a:   cmp.b (a2)+,d2
          bne.s npic3
          dbra d1,npic2
          rts                 ;trouvee!
npic3:    tst.b (a2)+
          bne.s npic3
          addq #1,d0
          cmp #10,d0
          bne.s npic1
          clr.l d0            ;pas trouvee!
          rts

; LOAD "xx.NEO/.PI1/.PI2/.PI3"[,adecran[,0]]: SCREEN LOAD
picload:  move.l adback,a0    ;par defaut: dans le decor des sprites
          clr d1              ; "    "   : poke la palette
          bsr finie
          beq.s picop
          cmp.b #",",(a6)+
          bne syntax
          movem.l d0-d1,-(sp)
          bsr expentier
          bsr adecran
          movem.l (sp)+,d0-d1
          move.l d3,a0
          bsr finie
          beq.s picop
          cmp.b #",",(a6)+
          bne syntax
          movem.l d0/a0,-(sp)
          bsr expentier
          movem.l (sp)+,d0/a0
          move.l d3,d1
; ouvre le fichier
picop:    movem.l d0-d1/a0,-(sp)
          moveq #0,d0
          lea name1,a0
          bsr open
          bmi diskerr
          move d0,handle
          movem.l (sp)+,d4-d5/a3
          cmp #1,d4
          bne picdeg
; IMAGE AU FORMAT NEO!!!
          move.l a3,a0
          add.l #32000-4,a0
          move.l #128,d0      ;lis tout d'un coup: 4oct, palette, et caca
          bsr readisk
          bmi diskerr
          move.l a3,a0
          move.l #32000,d0    ;lis l'image
          bsr readisk
          bmi diskerr
          bra pokpal          ;va poker la palette
; IMAGE AU FORMAT DEGAS
picdeg:   lea buffer,a0
          moveq #2,d0         ;saute le mode
          bsr readisk
          bmi diskerr
          move.l a3,a0
          add.l #32000,a0
          moveq #32,d0        ;lis la palette
          bsr readisk
          bmi diskerr
          move.l a3,a0
          move.l #32000,d0    ;lis l'image
          bsr readisk
          bmi diskerr
; POKE LA PALETTE ET FAIT APPARAITRE L'ECRAN (OU NON)
pokpal:   bsr close
          cmp.l adback,a3     ;si background
          bne picldfin
          tst d5              ;ET 0 a la fin
          bne picldfin
          add.l #32000,a3     ;copie la palette du BACK ---> LOGIC
          moveq #15,d0
          move.l adlogic,a0
          add.l #32000,a0
pokpal1:  move.w (a3)+,(a0)+
          dbra d0,pokpal1
          bsr setpalet        ;envoie la palette au XBIOS
          bsr waitvbl         ;attend le balayage
          moveq #23,d0
          trap #5             ;DEC TO EC
          moveq #29,d0
          trap #5             ;SPREAFF
picldfin: rts

; SAVE "aa.NEO/.PI1/.PI2/.PI3"[,adecran]: SCREEN SAVE
picsave:  move.l adback,d3    ;par defaut: adresse du decor
          bsr finie
          beq pics1
          cmp.b #",",(a6)+    ;chercher l'adresse de l'ecran
          bne syntax
          movem.l d0/d3,-(sp)
          bsr expentier
          bsr adecran
          movem.l (sp)+,d0/d1
pics1:    move d0,d4          ;ouvre le fichier sur la disquette
          clr d0
          lea name1,a0
          bsr create
          bmi diskerr
          move d0,handle
          cmp #1,d4
          bne pics5
; Sauve une image au format NEO
          lea defloat,a0
          move #31,d0
pics2:    clr.l (a0)+
          dbra d0,pics2
          lea defloat,a0
          moveq #4,d0         ; quatre octets inutiles!
          bsr write
          bmi varserr
          move.l d3,a0        ; palette
          add.l #32000,a0
          moveq #32,d0
          bsr write
          bmi varserr
          lea defloat,a0      ; cacas
          moveq #92,d0
          bsr write
          bmi varserr
          move.l d3,a0        ; ecran
          move.l #32000,d0
          bsr write
          bmi varserr
          bra pics10
; Sauve une image au format DEGAS
pics5:    lea mode,a0
          moveq #2,d0
          bsr write
          bmi varserr
          move.l d3,a0
          add.l #32000,a0
          moveq #32,d0
          bsr write
          bmi varserr
          move.l d3,a0
          move.l #32000,d0
          bsr write
          bmi varserr
; Ferme le fichiers
pics10:   bsr close
          rts

; BLOAD "AAAAAAAA.BBB",$depart: charge un bloc d'octets
bload:    bsr setdta
          bsr namedisk
          cmp.b #",",(a6)+
          bne syntax
          bsr expentier
          bsr adoubank
          move.l d3,-(sp)
          clr.l d0
          lea name1,a0
          bsr sfirst          ;ramene la taille du fichier---> dta
          bne dk1
          clr.l d0
          lea name1,a0
          bsr open            ;ouvre le fichier
          bmi diskerr
          move d0,handle
          move.l (sp)+,a0
          move.l dta+26,d0    ;taille du fichier
          bsr readisk         ;charge
          bmi diskerr
          bsr close
          rts

; BSAVE "AAAAAAAA.BIN",$depart TO $fin
bsave:    bsr setdta
          bsr namedisk
          cmp.b #",",(a6)+
          bne syntax
          bsr expentier
          bsr adoubank
          move.l d3,-(sp)
          cmp.b #$80,(a6)+    ;token de TO
          bne syntax
          bsr expentier
          bsr adoubank
          move.l d3,-(sp)
          clr.l d0
          lea name1,a0
          bsr create
          bmi diskerr
          move d0,handle
          move.l (sp)+,d0
          move.l (sp)+,a0     ;debut a sauver
          sub.l a0,d0         ;taille a sauver
          bsr write
          bmi varserr
          bsr close
          rts

; LOAD "AAAAAAAA.PRG",# de banque: charge un PROGRAMME
loadprg:  cmp.b #",",(a6)+
          bne syntax
          bsr expentier
          tst.l d3
          beq foncall
          cmp.l #16,d3
          bcc foncall
          move.l d3,-(sp)
          clr.l d0
          lea name1,a0
          bsr sfirst               ;cherche la taille du fichier
          bne dk1
          clr.l d0
          lea name1,a0
          bsr open                 ;ouvre le fichier
          bmi diskerr
          move d0,handle
          move.l (sp),buffer
          move.l dta+26,d0         ;taille du fichier
          and.l #$ffffff,d0
          or.l #$81000000,d0       ;pour le moment: flag DATA
          move.l d0,buffer+4
          bsr prgbis               ;verifie/reserve/charge: GENIAL!
          move.l (sp)+,d3
          bsr adbank               ;adresse de la banque
          beq foncall              ;pas possible!
          and.l #$ffffff,d0
          or.l #$83000000,d0
          move.l d0,(a0)           ;change le flag maintenant
; loge pour la premiere fois le programme
          move.l a1,16(a1)         ;16 (start)---> ancienne adresse
          move.l 2(a1),d0          ;distance a la table
          add.l 6(a1),d0
          and.l #$ffffff,d0
          add #$1c,a1              ;pointe le debut du programme
          move.l a1,a2
          move.l a2,d2             ;d2= debut du programme
          add.l d0,a1
          tst.l (a1)               ;si nul: pas de relocation!
          beq.s lprg3  
          add.l (a1)+,a2           ;pointe la table de relocation!
          clr.l d0
          bra.s lprg1
lprg0:    move.b (a1)+,d0
          beq.s lprg3
          cmp.b #1,d0
          beq.s lprg2
          add d0,a2                ;pointe dans le programme
lprg1:    add.l d2,(a2)            ;change dans le programme
          bra.s lprg0
lprg2:    add #254,a2
          bra.s lprg0
lprg3:    rts

; LOAD "AAAAAAAA.MBK"[,xx]: charge une banque memoire
loadmbk:  lea name1,a0
          bsr ouvrebank                 ;ouvre le fichier, cherche le codage
          lea buffer,a0
          moveq #4,d0
          bsr readisk
          bmi diskerr
          tst.l buffer                  ;si ZERO, il s'agit de TOUTES
          beq badname                   ;les banques memoire!!!
; charge UNE banque memoire
          lea buffer+4,a0               ;taille de la banque
          moveq #4,d0
          bsr readisk                   ;va charger la longueur
          bmi diskerr
          jsr finie                     ;changer le numero de la banque?
          beq prgbis
          cmp.b #",",(a6)+
          bne syntax
          bsr expentier
          tst.l d3
          beq foncall
          cmp.l #15,d3
          bhi foncall
          move.l d3,buffer
; entree pour charger un .PRG
prgbis:   move.l buffer,d3
          bsr adbank
          cmp #15,d3
          bne lmbk0
          tst mnd+14
          bne menuill
lmbk0:    and.l #$ffffff,d0             ;taille ACTUELLE de la banque
          move.l buffer+4,d3
          and.l #$ffffff,d3             ;taille de la banque a charger
          add.l #64,d3                  ;plus 64 octets de secu
          cmp.l d0,d3
          bls.s lmbk1
          sub.l d0,d3
          bsr demande
lmbk1:    move.l buffer,d3
          bsr effbank                   ;va effacer la banque
          move.l buffer+4,d1
          move.l d1,d3
          and.l #$ffffff,d3             ;longueur a reserver
          move.l d3,-(sp)
          rol.l #8,d1
          and.l #$ff,d1                 ;flag
          move.l buffer,d2              ;numero de la banque
          move.l d2,-(sp)
          bsr reservin                  ;va reserver la memoire
          move.l (sp)+,d3
          bsr adbank                    ;adresse ou charger
          move.l a1,a0
          move.l (sp)+,d0               ;longueur a charger
          bsr readisk
          bmi diskerr
          bsr close
          bra resbis                    ;va tout changer dans le programme

; LOAD "AAAAAAAA.MBS": charge toutes les banques memoire!
loadmbs:  lea name1,a0
          bsr ouvrebank                 ;ouvre le fichier, cherche le codage
          lea buffer,a0
          moveq #4,d0
          bsr readisk
          bmi diskerr
          tst.l buffer                  ;si PAS ZERO, il s'agit de UNE
          bne badname                   ;SEULE banque memoire!!!
          tst mnd+14
          bne menuill                   ;si menus en route! RIEN!!!
          lea buffer,a0
          moveq #4,d0
          bsr readisk
          bmi diskerr
          move.l topmem,d0
          sub.l himem,d0
          move.l buffer,d3
          add.l #64,d3
          cmp.l d0,d3
          bls.s lmbk11
          sub.l d0,d3
          bsr demande
lmbk11:   bsr stopall
          lea unewbank,a1
          move.l adatabank,a0
          addq.l #4,a0
          move.l a0,a2
          moveq #14,d0
lmbk12:   move.l (a2)+,(a1)+  ;recopie les banques!!!
          dbra d0,lmbk12
          moveq #15*4,d0
          bsr readisk         ;copie les banques
          bmi errbank
          move.l topmem,a3
          sub.l buffer,a3
          move.l lowvar,a2    ;depart des variables
          move.l himem,d3
          sub.l a2,d3         ;taille des variables
          sub.l d3,a3         ;arrivee des variables
          move.l a3,lowvar    ;nouveau lowvar
          bsr transmem        ;bouge les variables
          move.l a3,himem     ;nouveau himem= arrivee des banques
          move.l a3,a0
          move.l buffer,d0
          bsr readisk
          bmi errbk2
          bsr close
          bra resbis

; ERREUR EN COURS DE CHARGEMENT DE BANQUES! kADASDROPHE!
errbank:  lea unewbank,a0
          move.l adatabank,a1
          addq.l #4,a0
          moveq #14,d1
errbk1:   move.l (a0)+,(a1)+            ;remet les banques comme avant!
          dbra d1,errbk1
errbk2:   move.l d0,-(sp)
          bsr resbis
          move.l (sp)+,d0
          bra diskerr

; SAVE "AAAAAAAA.MBK",xx: sauve UNE banque
savembk:  bsr finie
          beq syntax
; sauve une seule banque
          cmp.b #",",(a6)+
          bne syntax
          bsr expentier
          tst.l d3
          beq foncall
          cmp.l #16,d3
          bcc foncall
          bsr adbank
          beq bknotdef                  ;bank not reserved
          movem.l a0-a1,-(sp)
          lea name1,a0
          clr d0
          bsr create                    ;ouvre le fichier
          bmi diskerr
          move d0,handle
          lea cbk,a0               ;ecris le codage
          moveq #10,d0
          bsr write
          bmi varserr
          movem.l (sp)+,a0-a1
          move.l d3,buffer
          move.l (a0),buffer+4          ;NUMERO DE LA BANQUE 1-15
          lea buffer,a0                 ;PUIS DATAZONE!
          moveq #8,d0
          bsr write
          bmi varserr
          move.l a1,a0                  ;adresse de la banque
          move.l buffer+4,d0
          and.l #$ffffff,d0             ;taille de la banque
          bsr write
          bmi varserr
          bra close                     ;ferme et revient

; SAVE "AAAAAAAA.MBS": sauve TOUTES les banques
savembs:  move.l himem,d0
          cmp.l topmem,d0
          beq bknotdef                  ;pas de banque reservee!
          lea name1,a0                  ;va creer le fichier
          clr d0
          bsr create
          bmi diskerr
          move d0,handle
          lea cbk,a0               ;ecris le codage
          moveq #10,d0
          bsr write
          bmi varserr
          lea buffer,a0                 ;zero---> toutes les banques
          clr.l (a0)
          move.l topmem,d0              ;taille totale des banques
          sub.l himem,d0
          move.l d0,4(a0)
          moveq #8,d0
          bsr write
          bmi varserr
          move.l adatabank,a0
	addq.l #4,a0
          moveq #15*4,d0
          bsr write                     ;puis datazone-banque zero
          bmi varserr
          move.l himem,a0               ;debut des banques
          move.l topmem,d0              ;taille des banques
          sub.l a0,d0
          bsr write
          bmi varserr
          bra close                     ;ferme et revient

; SAVE "AAAAAAAA.VAR": sauve les variables
savevar:  lea name1,a0
          clr d0
          bsr create
          bmi diskerr
          move d0,handle
          lea cvr,a0
          moveq #10,d0
          bsr write
          bmi varserr
          move.l lowvar,d0              ;fait le menage
          bsr menage
          lea fsource,a0                ;adresse absolue des chaines
          moveq #4,d0
          bsr write
          bmi varserr
          move.l hichaine,d7            ;taille des chaines
          sub.l fsource,d7
          lea buffer,a0
          move.l d7,(a0)
          moveq #4,d0
          bsr write
          bmi varserr
          move.l d7,d0
          beq vars1
          move.l fsource,a0             ;sauve les chaines s'il y en a
          bsr write
          bmi.s varserr
vars1:    move.l himem,d7               ;puis taille des variables
          sub.l lowvar,d7
          lea buffer,a0
          move.l d7,(a0)
          moveq #4,d0
          bsr write
          bmi.s varserr
          move.l d7,d0
          beq.s vars2
          move.l lowvar,a0              ;sauve les variables s'il y en a
          bsr write
          bmi.s varserr
vars2:    bra close                     ;ferme et revient
; erreur de save: ferme le fichier, l'efface!!!!!!!
varserr:  move.l d0,-(sp)
          bsr close
          lea name1,a0
          bsr unlink
          move.l (sp)+,d0
          bra diskerr

; LOAD "AAAAAAAA.VAR": charge les variables
loadvar:  lea name1,a0
          bsr ouvrevar                  ;ouvre et verifie le fichier
          add.l #48,d6                  ;secu de 64 octets
          move.l himem,d0
          sub.l fsource,d0
          cmp.l d0,d6                   ;verifie la memoire!!!
          bcc outofmm
          bsr clear                     ;fait un CLEAR
          lea buffer,a0
          moveq #8,d0                   ;lis FSOURCE et LONG CHAINE
          bsr readisk
          bmi diskerr
          move.l buffer+4,d3
          beq.s lvar1
          move.l fsource,a0
          move.l d3,d0
          bsr readisk
          bmi diskerr
          move.l fsource,hichaine
          add.l d3,hichaine             ;remonte HICHAINE
lvar1:    lea buffer+8,a0
          moveq #4,d0
          bsr readisk                   ;lis la taille des variables normales
          bmi diskerr
          move.l buffer+8,d0
          beq lvr20                     ;pas de variable!!!!
          move.l himem,a2
          sub.l d0,a2                   ;debut des variables
          move.l a2,a0
          bsr readisk
          bmi diskerr
          move.l a2,lowvar              ;baisse les variables
; RELOGE LES VARIABLES ALPHANUMERIQUES
          move.l buffer,d5              ;base des variables chargees
          move.l fsource,d7             ;base a poker
          move.l lowvar,a2
          move.l himem,a3
lvr2:     cmp.l a3,a2
          bcc lvr20
          move.b (a2)+,d2     ;rend pair!
          bne.s lvr2a
          move.b (a2)+,d2
lvr2a:    move d2,d0
          and #$001f,d0
          add d0,a2
          tst.b d2
          bpl.s lvr15
; TROUVE UNE VARIABLE ALPHANUMERIQUE
          btst #5,d2
          beq.s lvr10
; C'EST UN TABLEAU!
          addq.l #4,a2        ;saute la taille du tableau
          move (a2)+,d2       ;nb de dimensions
          subq #1,d2
          moveq #1,d3
lvr3:     clr.l d6            ;calcule le nombre de variables
          move (a2)+,d6
          addq #1,d6
          bsr milt1           ;resultat en d3
          dbra d2,lvr3
lvr4:     sub.l d5,(a2)       ;soustrait la base
          add.l d7,(a2)       ;additionne le plancher
          addq.l #4,a2
          subq.l #1,d3        ;variable tableau suivante
          bne.s lvr4
          bra.s lvr2
; VARIABLE NORMALE
lvr10:    sub.l d5,(a2)
          add.l d7,(a2)
          addq.l #4,a2
          bra.s lvr2
; PAS UNE VARIABLE ALPHANUMERIQUE: passe a la variable suivante
lvr15:    btst #5,d2
          bne.s lvr16
          addq.l #4,a2
          btst #6,d2
          beq lvr2
          addq.l #4,a2
          bra lvr2
lvr16:    add.l (a2),a2       ;si tableau: le saute!!!
          bra lvr2
; SORTIE DU RELOGEAGE DES CHAINES
lvr20:    bra close           ;ferme le fichier, et revient!

; ACCNEW: EFFACE TOUS LES ACCESSOIRES
accnew:   move #4,posacc
; efface les banques des accessoires
          lea dataprg,a0
          add.l #2*4*4,a0
          lea databank,a1
          add.l #16*4*4,a1
          move.l fbufprg,a2
          sub.l #12*2,a2
          move #11,d0
acnw1:    move.l a2,(a0)+     ;efface le programme
          move.l #2,(a0)+
          clr.w (a2)+
          move.l #2,(a1)+
          move #14,d1         ;efface les banques
acnw2:    clr.l (a1)+
          dbra d1,acnw2
          dbra d0,acnw1
; bouge les programme au dessus du pgm edite
          move.l #4,d0
          lea dataprg,a0
          add #8*4,a0         ;pointe pgm #5
          move.l fbufprg,a3
          sub.l #12*2,a3
acnw3:    subq #1,d0
          cmp program,d0
          beq.s acnw4
          move.l -(a0),d3     ;longueur
          move.l -(a0),a2     ;depart
          sub.l d3,a3         ;destination
          move.l a3,(a0)      ;poke la nouvelle adresse
          move.l a3,-(sp)
          bsr transmem
          move.l (sp)+,a3
          bra.s acnw3
; bouge les banques du programme edite!
acnw4:    move.l a3,d4
          clr.b d4            ;adresse multiple de 256
          move.l topmem,d3
          move.l d4,topmem
          move.l himem,a2     ;adresse de depart
          sub.l a2,d3         ;taille des banques
          move.l d4,a3
          sub.l d3,a3         ;adresse de destination
          move.l a3,himem
          bsr transmem
          bsr clearvar
; efface les noms des accessoires
          lea accnames,a0
          move #8*12-1,d0
acnw5:    move.b #32,(a0)+
          dbra d0,acnw5
          rts

;MERGE
merge:    bsr setdta
          bsr namedisk        ;va chercher le nom
          bne.s mg0
          lea bas,a0          ;ecris .BAS
          bsr transtext
          bra.s mg3
mg0:      bsr disknom         ;verifie l'extension
          tst d0
          bne badname
mg3:      lea name1,a0
          bsr ouvrebas
          move.l #17*4,d0     ;saute les entetes
          lea buffer,a0
          bsr readisk
          bmi diskerr
mg1:      lea buftok,a0
          move.l #4,d0
          bsr readisk
          bmi diskerr
          lea buftok,a6
          tst.w (a6)
          beq.s mg2
          clr.l d0
          move (a6),d0
          sub.l #4,d0
          lea 4(a6),a0
          bsr readisk
          bmi diskerr
          lea buftok,a6
          bsr stockage
          bra.s mg1
mg2:      bsr close
          bra ok      

; sspgm GETFILE: va chercher le numero de fichier, le pointe en a2
getfile:  cmp.b #"#",(a6)
          bne.s getf1
          addq.l #1,a6
getf1:    bsr expentier
          cmp.b #",",(a6)+    ;toujours une virgule apres!
          bne syntax
getf2:    tst.l d3
          beq foncall
          cmp.l #10,d3
          bhi foncall
          subq #1,d3
          mulu #tfiche,d3
          lea fichiers,a2
          add d3,a2
          move.w (a2),d0
          rts

; FGETFILE: MEME CHOSE EN FONCTION!
fgetfile: cmp.b #"(",(a6)+
          bne syntax
          cmp.b #"#",(a6)
          bne.s fgetf1
          addq.l #1,a6
fgetf1:   move.w parenth,-(sp)
          move #1,parenth
          bsr entierbis
          move.w (sp)+,parenth
          bra getf2

; OPENIN
openin:   bsr setdta
          bsr getfile         ;va chercher le numero de fichier
          bne filopen         ;file already open!
          bsr ficlean         ;va nettoyer la table
          move.l a2,-(sp)
          bsr namedisk        ;va chercher le nom du fichier
          clr d0
          lea name1,a0
          bsr sfirst
          bne dk1          ;file not found
          move.l (sp)+,a2
          lea dta,a0
          move.l 26(a0),fhl(a2)   ;poke sa longueur
          lea name1,a0
          clr.l d0                ;accessible en lecture uniquement
          bsr open
          bmi diskerr
          move d0,fha(a2)     ;poke le file handle
          move #5,(a2)            ;fichier DISQUE en LECTURE!
          rts

; OPENOUT #xx,"aaaaa.eee"[,attribut]
openout:  bsr setdta
          bsr getfile         ;va chercher le numero de fichier
          bne filopen         ;file already open!
          bsr ficlean         ;va nettoyer la table
          move.l a2,-(sp)
          bsr namedisk        ;va chercher le nom du fichier
          clr.l d3
          bsr finie
          beq.s opout1
          cmp.b #",",(a6)+
          bne syntax
          bsr expentier       ;va chercher le parametre
          cmp.l #4,d3
          bcc foncall
opout1:   move d3,d0
          lea name1,a0
          bsr create          ;va le creer
          bmi diskerr
          move.l (sp)+,a2
          clr.l fhl(a2)      ;longueur nulle!
          move d0,fha(a2)     ;poke le file handle
          move #6,(a2)            ;fichier en ecriture!
          rts

; OPEN #xx,("R", "MID", "AUX", "PRT"),a$
hopen:    bsr setdta
          bsr getfile
          bne filopen
          bsr ficlean         ;va nettoyer la table
          move.l a2,-(sp)
          bsr expalpha        ;va chercher la chaine
          tst.w d2
          beq foncall
          move.b (a2)+,d0
          move.l (sp)+,a2
          cmp.b #"a",d0
          bcs.s hop1
          cmp.b #"z",d0
          bhi.s hop1
          sub.b #$20,d0
hop1:     cmp.b #"R",d0
          beq.s hop2
          cmp.b #"P",d0
          beq hop3
          cmp.b #"A",d0
          beq hop4
          cmp.b #"M",d0
          beq hop5
          bne foncall
; OUVRE UN FICHIER A ACCES DIRECT
hop2:     cmp.b #",",(a6)+
          bne syntax
          move.l a2,-(sp)
          bsr namedisk        ;va chercher le nom du fichier
          move.l (sp)+,a2
          clr d0
          lea name1,a0
          bsr sfirst
          beq.s hop1a
; il faut creer le fichier
          lea name1,a0        ;le fichier n'existe pas: va le creer!
          clr.l d0            ;lecture/ecriture
          bsr create
          bmi diskerr
          move.w d0,fha(a2)         ;handle
          move.w #-1,(a2)               ;fichier en acces direct
          rts
; le fichier existe deja
hop1a:    lea name1,a0
          moveq #2,d0             ;acces en lecture/ecriture
          bsr open
          bmi diskerr
          move d0,fha(a2)           ;poke le file handle
          lea dta,a0
          move.l 26(a0),fhl(a2)    ;poke la longueur
          move.w #-1,(a2)               ;fichier a access direct
          rts
; OUVRE UN PORT D'ENTREE/SORTIE
hop3:     moveq #1,d0         ;PRT
          bra.s hop6
hop4:     moveq #2,d0         ;AUX= RS 232
          bra.s hop6
hop5:     moveq #4,d0         ;MIDI
hop6:     move.w d0,(a2)      ;poke le type de fichier ET C'EST TOUT!!!!!!!
          rts

; NETTOIE LA TABLE DE DEFINITION DU FICHIER
ficlean:  movem.l d0/a0,-(sp)
          moveq #tfiche-1,d0
          move.l a2,a0
ficl1:    clr.b (a0)+
          dbra d0,ficl1
          movem.l (sp)+,a0/d0
          rts

; PORT (#xx): PREND AU VOL UN CARACTERE DU PORT D'ENTREE/SORTIE
port:     bsr fgetfile
          beq filnotop
          bmi filtmis
          cmp #1,d0
          beq.s po1
          cmp #2,d0
          beq.s po1
          cmp #4,d0
          beq.s po1
          bra filtmis
po1:      subq #1,d0
          move.w d0,-(sp)
          move.w #1,-(sp)
          trap #13
          addq.l #2,sp
          tst d0
          bne.s po2
; pas de caractere
          addq.l #2,sp
          clr.b d2
          moveq #-1,d3
          rts
; caractere
po2:      move.w #2,-(sp)
          trap #13
          addq.l #4,sp
          clr.b d2
          moveq #0,d3
          move.b d0,d3
          rts

; CLOSE [#xx]
klose:    bsr finie
          beq clause
          cmp.b #"#",(a6)
          bne.s klos1
          addq.l #1,a6
klos1:    bsr expentier
          bsr getf2
          beq fileclos        ;file already closed
          clr d2              ;un seul fichier a fermer!
          bra.s cs1             ;va fermer, puis revient
; CLAUSE: FERME TOUS LES FICHIERS
clause:   bsr close           ;va fermer le fichier systeme
          lea fichiers,a2
          moveq #9,d2
cs1:      move.w (a2),d0
          beq.s cs4
          bmi.s cs2
          cmp #5,d0           ;ne "ferme" que les fichiers disquette!
          beq.s cs2
          cmp #6,d0
          bne.s cs3
cs2:      move.w fha(a2),-(sp)
          move.w #$3e,-(sp)
          trap #1
          addq.l #4,sp
cs3:      bsr ficlean
cs4:      add.l #tfiche,a2
          dbra d2,cs1
          rts

; GETBYTE: PREND UN OCTET DANS LE FICHIER (D7 bouzille)
getbyte:  move.w (a2),d7
          beq filnotop
          cmp #5,d7
          beq getb4
          subq #1,d7
          cmp #1,d7           ;rs 232
          beq.s getb0
          cmp #3,d7           ;midi
          bne filtmis
; prend un byte dans le port RS-232 ou MIDI
getb0:    movem.l d1-d2/a0-a2,-(sp)
getb1:    move.w d7,-(sp)     ;bconstat
          move.w #1,-(sp)
          trap #13
          addq.l #4,sp
          tst d0
          bne.s getb2
          jsr avantint        ;va tester le break
          bra.s getb1
getb2:    move.w d7,-(sp)     ;conin
          move.w #2,-(sp)
          trap #13
          addq.l #4,sp
          movem.l (sp)+,d1-d2/a0-a2
          rts
; prend un byte d'un fichier sequentiel sur disque
getb4:    move.l a0,-(sp)
          bsr pfile           ;position du pointeur du fichier
          cmp.l fhl(a2),d0
          bcc eofmet          ;End Of File met
          pea defloat
          move.l #1,-(sp)
          move.w fha(a2),-(sp)
          move.w #$3f,-(sp)
          trap #1             ;READ
          add.l #12,sp
          tst.l d0
          bmi diskerr
          move.b defloat,d0
          move.l (sp)+,a0
          rts

; SSPGM: PFILE: ramene la position du pointeur du fichier en D0.L
pfile:    move.l a0,-(sp)
          move.w #1,-(sp)
          move.w fha(a2),-(sp)
          clr.l -(sp)         ;Pas de deplacement!
          move.w #$42,-(sp)
          trap #1
          add.l #10,sp
          move.l (sp)+,a0
          tst.l d0
          bmi diskerr
          rts

; FONCTION: LOF(#xx)
lof:      bsr fgetfile
          beq filnotop
          bmi.s lof1
          cmp #5,d0
          beq.s lof1
          cmp #6,d0
          bne filtmis         ;pas de sens pour les autres fichiers!
lof1:     move.l fhl(a2),d3
          clr.b d2
          rts

; FONCTION: EOF(#xx)
eof:      bsr fgetfile
          beq filnotop
          bmi.s eof1
          cmp #5,d0
          beq.s eof1
          cmp #6,d0
          bne filtmis
eof1:     clr.b d2
          clr.l d3
          bsr pfile           ;va chercher la position
          cmp.l fhl(a2),d0
          bcs.s eof2
          moveq #-1,d3
eof2:     rts


; FONCTION: POF(#xx): position dans un fichier
pofonc:   bsr fgetfile
          beq filnotop
          bmi.s pof1
          cmp #5,d0
          beq.s pof1
          cmp #6,d0
          bne filtmis
pof1:     clr.b d2
          bsr pfile
          move.l d0,d3
          rts

; INSTRUCTION POF(#xx)=xxxx: positionne dans un fichier
pofins:   lea bufcalc,a3
          bsr fgetfile
          beq filnotop
          bmi.s pofi1
          cmp #5,d0
          beq.s pofi1
          cmp #6,d0
          bne filtmis
pofi1:    cmp.b #$f1,(a6)+
          bne syntax
          move.l a2,-(sp)
          bsr expentier
          move.l (sp)+,a2
          tst.l d3
          bmi foncall
          cmp.l fhl(a2),d3
          bhi eofmet
          bra seekbis
          
; FIELD #XX,AA AS XX$,...
field:    bsr getfile
          beq filnotop
          bpl filtmis
          moveq #15,d1
field0:   move d1,d0          ;nettoie la definition de la fiche
          lsl #1,d0
          clr.w fhc(a2,d0.w)
          lsl #1,d0
          clr.l fhs(a2,d0.w)
          dbra d1,field0
          clr.w fht(a2)
          clr.l d7            ;d7: taille totale des champs
          clr.l d2            ;numero de la variable traitee
field1:   movem.l d2/d7/a2,-(sp)
          bsr expentier
          move.l d3,-(sp)
          cmp.b #$a0,(a6)+
          bne syntax
          cmp.b #$d3,(a6)+    ;token de AS
          bne syntax
          cmp.b #$fa,(a6)+    ;veut une variable
          bne syntax
          lea bufcalc,a3
          bsr findvar
          tst.b d2            ;alphanumerique!!! (a1= adresse)
          bpl typemis
          move.l (sp)+,d3
          beq foncall
          cmp.l #$fff0,d3
          bcc stoolong
          movem.l (sp)+,d2/d7/a2
          add.l d3,d7
          cmp.l #$fff0,d7
          bcc fldtoolg
          move d2,d0
          lsl #1,d0
          move.w d3,fhc(a2,d0.w)   ;taille de la variable
          lsl #1,d0
          move.l a1,fhs(a2,d0.w)   ;adresse de celle-ci
          bsr finie
          beq field2
          cmp.b #",",(a6)+
          bne syntax
          addq #1,d2
          cmp #16,d2
          bcs field1
          bra fldtoolg
field2:   move.w d7,fht(a2)        ;poke le taille totale du champ
          rts

; LSEEK: POSITIONNE LE POINTEUR DU FICHIER AU BON ENDROIT
lseek:    move.l a2,-(sp)
          bsr expentier
          move.l (sp)+,a2
          tst.l d3
          beq foncall
          cmp.l #$10000,d3
          bcc foncall
          subq #1,d3
          mulu fht(a2),d3  ;adresse absolue dans le fichier
          cmp.l fhl(a2),d3 ;plus loin que la fin du fichier!
          bhi eofmet
seekbis:  bsr pfile             ;position du pointeur ---> d0
          move.w #1,-(sp)       ;deplacement RELATIF
          move.w fha(a2),-(sp)
          move.l d3,-(sp)
          sub.l d0,(sp)         ;calcule le deplacement relatif
          move.w #$42,-(sp)
          trap #1               ;LSEEK
          add.l #10,sp
          tst.l d0              ;ramene en d0 la position dans le fichier
          bmi diskerr
          rts

; GET #xx,yy
get:      bsr getfile
          beq filnotop
          bpl filtmis
          bsr lseek           ;positionne ou il faut dans le fichier
          cmp.l fhl(a2),d3
          beq eofmet          ;ne permet pas le dernier octet!
          clr.l d7
get1:     move d7,d4
          lsl #1,d4
          clr.l d3
          move.w fhc(a2,d4.w),d3
          beq.s get3
          bsr demande
          lsl #1,d4
          move.l fhs(a2,d4.w),a0   ;prend l'adresse de la variable
          move.l a1,(a0)                ;change la variable
          move.w d3,(a1)+               ;poke la longueur
          move.l a1,-(sp)
          move.l d3,-(sp)
          move.w fha(a2),-(sp)
          move.w #$3f,-(sp)
          trap #1
          add.l #12,sp
          tst.l d0
          bmi diskerr
          add.l d3,a1
          move a1,d0
          btst #0,d0
          beq.s get2
          addq.l #1,a1
get2:     move.l a1,hichaine  ;remonte les chaines
          addq #1,d7
          cmp #16,d7
          bcs.s get1
get3:     rts

; PUT #xx,yy
put:      bsr getfile
          beq filnotop
          bpl filtmis
          bsr lseek           ;positionne ou il faut dans le fichier
          clr.l d7
put1:     move d7,d1
          lsl #1,d1
          clr.l d3
          move.w fhc(a2,d1.w),d3
          beq.s put5
          lsl #1,d1
          move.l fhs(a2,d1.w),a0
          move.l (a0),a0      ;pointe la variable
          clr.l d4
          move.w (a0)+,d4     ;taille de la variable
          cmp d3,d4
          beq.s put2
          bcs.s put2
          move d3,d4          ;variable PLUS GRANDE que le champ
put2:     move.l a0,-(sp)
          move.l d4,-(sp)
          move.w fha(a2),-(sp)
          move.w #$40,-(sp)
          trap #1
          add.l #12,sp
          tst.l d0
          bmi diskerr
          cmp d3,d4
          bcc.s put4
          sub.l d4,d3         ;calcule la difference
          bsr demande
          move.l d3,d0
put3:     move.b #32,(a1)+    ;remplis de blancs
          subq #1,d3
          bne.s put3
          move.l a0,-(sp)
          move.l d0,-(sp)
          move.w fha(a2),-(sp)
          move.w #$40,-(sp)
          trap #1
          add.l #12,sp
          tst.l d0
          bmi diskerr
put4:     addq #1,d7          ;autre variable
          cmp #16,d7
          bcs put1
put5:     bsr pfile
          cmp.l fhl(a2),d0    ;si le fichier a grandi
          bcs.s put6
          move.l d0,fhl(a2)   ;poke la nouvelle longueur
put6:     rts

; DFREE: place libre sur une disque
dfree:    move.w #0,-(sp)
          pea buffer
          move.w #$36,-(sp)
          trap #1             ;get free disk space
          addq.l #8,sp
          tst d0
          bne diskerr
          lea buffer,a0
          move.l 8(a0),d6
          move.l 12(a0),d0
          mulu d0,d6
          move.l (a0),d3
          mulu d6,d3
          clr.b d2
          rts
          
; MK DIR a$
mkdir:    bsr namedisk
          pea name1
          move #$39,-(sp)
          trap #1             ;MKDIR
          addq.l #6,sp
          tst.w d0
          bne diskerr
          rts

; RM DIR a$
rmdir:    bsr namedisk
          pea name1
          move #$3a,-(sp)
          trap #1             ;RMDIR
          addq.l #6,sp
          tst.w d0
          bne diskerr
          rts

; DIR$=a$  (instruction)
dirinst:  cmp.b #$f1,(a6)+
          bne syntax
          bsr namedisk
          pea name1
          move #$3b,-(sp)
          trap #1             ;CHDIR
          addq.l #6,sp
          tst d0
          bne diskerr
          rts

; DIR$ en fonction
fndir:    move.l #128,d3
          bsr demande         ;longueur de la chaine
          addq.l #2,a0
          clr.w -(sp)         ;drive courant
          move.l a0,-(sp)
          move.w #$47,-(sp)   ;GETDIR
          trap #1
          addq.l #8,sp
          tst.w d0
          bne diskerr
          lea 2(a1),a0
curdir1:  tst.b (a0)+
          bne.s curdir1
          subq.l #1,a0
          move.l a0,d0
          sub.l a1,d0
          subq.l #2,d0
          move.w d0,(a1)      ;longueur de la chaine
          bra mid7a

; PREVIOUS: PASSE AU DIRECTORY PRECCEDENT
previous: clr -(sp) 
          pea buffer
          move.w #$47,-(sp)
          trap #1             ;GETDIR
          addq.l #8,sp
          tst d0
          bne diskerr
          lea buffer,a0
          moveq #-1,d0
pr:       addq #1,d0
          tst.b (a0)+
          bne.s pr
          tst d0
          beq.s pr3
pr1:      cmp.b #"\",-(a0)
          beq.s pr2
          cmp.l #buffer,a0
          bne.s pr1
pr2:      clr.b 1(a0)
          pea buffer
          move.w #$3b,-(sp)
          trap #1             ;CHDIR
          addq.l #6,sp
pr3:      rts

; DRIVE$ EN FONCTION RAMENE la lettre DU DRIVE COURANT
fndrived: move.w #$19,-(sp)
          trap #1
          addq.l #2,sp
          clr.l d2
          move.b d0,d2
          add #65,d2
          jmp chhr1

; DRIVE EN FONCTION: RAMENE le numero DU DRIVE COURANT
fndrive:  move.w #$19,-(sp)
          trap #1             ;CURRENT DISK
          addq.l #2,sp
          clr.l d3
          move d0,d3
          clr.b d2
          rts

; DRIVE EN INSTRUCTION: CHANGE LE DRIVE COURANT
drive:    cmp.b #$f1,(a6)+
          bne syntax
          bsr expentier
          bra setdrv
; DRIVE$ EN INSTRUCTION
drived:   cmp.b #$f1,(a6)+
          bne syntax
          bsr expalpha
          clr.l d3
          move.b (a2),d3
drived0:  cmp.w #97,d3
          bcs.s drived1
          sub.w #$20,d3
drived1:  sub.w #65,d3          
setdrv:   move.w #10,-(sp)
          trap #13
          addq.l #2,sp
          cmp.l #26,d3
          bcc foncall
          btst d3,d0
          beq drvnotc
          move.w d3,-(sp)
          move.w #$e,-(sp)
          trap #1             ;SETDRV
          addq.l #4,sp
          tst d0
          bmi diskerr
          rts

; DRVMAP: FONCTION ---> CARTE DES DRIVES CONNECTES
drvmap:   move #10,-(sp)
          trap #13
          addq.l #2,sp
          clr d2
          move.l d0,d3
          rts

; DIR FIRST$(a$,xx): ramene les donnees directory d'un pgm
dirfirst: bsr setdta
          bsr comm2           ;ramene une chaine en d2/a2
          cmp #1,d0           ;et un entier en d5
          bne syntax
          move.l d5,-(sp)
          bsr namedbis        ;verifie le nom
          move.l (sp)+,d0
          cmp.l #$40,d0
          bcs.s dfrst1
          moveq #%11001,d0    ;par defaut!
dfrst1:   lea name1,a0
          bsr sfirst
          bra.s dnxt1
; DIR NEXT$
dirnext:  bsr snext
dnxt1:    tst d0              ;rien trouve: ramene une chaine vide!
          bne mid9
          moveq #44,d3
          bsr demande
          move.w #45,(a1)+    ;taille de la chaine
          move.l a1,a0
          moveq #44,d0
dnxt2:    move.b #32,(a0)+    ;nettoie la chaine
          dbra d0,dnxt2
          move.l a1,a0
          lea dta,a2
          add.l #30,a2
dnxt3:    move.b (a2)+,(a0)+  ;copie le nom du fichier: 0
          bne.s dnxt3
          move.b #32,-1(a0)   ;efface le zero!
          move.l a5,-(sp)
          lea dta,a2          ;taille du fichier: 13
          move.l 26(a2),d0
          move.l a1,a5
          add.l #13,a5
          bsr longdec
          lea dta,a2          ;date: 22
          move.w 24(a2),d7
          move.l a1,a0
          add.l #22,a0
          bsr datebis
          lea dta,a2          ;heure: 33
          move.w 22(a2),d7
          move.l a1,a0
          add.l #33,a0
          bsr timebis
          clr.l d0            ;type de fichier: 42--->45
          lea dta,a2
          move.b 21(a2),d0
          move.l a1,a5
          add.l #42,a5
          bsr longdec
          move.l (sp)+,a5
          move.l a1,a0        ;termine tout!
          add.l #45,a0
          subq.l #2,a1        ;remet au debut de la variable
          bra mid7a

; Sauve le DRIVE et le PATH dans BUFFER,
; Recopie le path dans un NAME1, change DRIVE et DIRECTORY...
; Recopie le filtre s'il existe dans NAME2 (sinon---> *.*)
ds:      
          movem.l a2/d2,-(sp)
; Sauve DRIVE COURANT et DIRECTORY
          bsr fndrive         ;va chercher le numero du drive
          move.w d3,buffer+128
          clr.w -(sp)         ;drive courant
          pea buffer+130      ;poke en BUFFER+130
          move.w #$47,-(sp)   ;GETDIR
          trap #1
          addq.l #8,sp
          tst.w d0
          bne diskerr
          tst.b buffer+130    ;rattrape les bugs du TOS!
          bne.s dsa
          move.w #$5C00,buffer+130
; analyse la chaine
dsa:      movem.l (sp)+,a2/d2
          move.l #$2A2E2A00,name2       ;*.*---> NAME2
          tst.w d2
          beq ds7
          subq.w #1,d2
          lea name1,a1
          move.l a1,d4
          move.l a2,a0
          move.w d2,d3
ds0:      move.b (a0)+,d0               ;prend la lettre
          cmp.b #":",d0
          beq.s ds1
          cmp.b #"\",d0
          bne.s ds2
ds1:      move.l a0,a2
          move.w d2,d3
          subq.w #1,d3
          move.l a1,d4
          addq.l #1,d4
ds2:      cmp.b #"*",d0         ;Essaie de reperer la fin du nom
          beq.s ds3
          cmp.b #"?",d0
          beq.s ds3
          move.b d0,(a1)+
          dbra d2,ds0
          clr.b (a1)
          bra.s ds5             ;Pas de nom de filtre---> *.*!
; copie le filtre---> NAME2
ds3:      move.l d4,a1
          clr.b (a1)            ;arrete le path!
          move.l a2,a0
          lea name2,a1
          tst.w d3
          bmi.s ds5
ds4:      move.b (a0)+,(a1)+
          dbra d3,ds4
          clr.b (a1)
; change le directory s'il faut
ds5:      tst.b name1           ;Ya til un path?
          beq.s ds7
          lea name1,a2
; change le drive?
          cmp.b #":",1(a2)
          bne.s ds6
          moveq #0,d3
          move.b (a2),d3
          addq.l #2,a2
          move.l a2,-(sp)
          bsr drived0
          move.l (sp)+,a2
; Change le directory?
ds6:      tst.b (a2)
          beq.s ds7
          move.l a2,-(sp)
          move #$3b,-(sp)
          trap #1             ;CHDIR
          addq.l #6,sp
          tst d0
          bne diskerr         ;DIR ERROR!
; FINI!
ds7:      rts

; Restore DRIVE et DIRECTORY

; Restore DRIVE
sd:       moveq #0,d3
          move.w buffer+128,d3
          bsr setdrv
; restore DIRECTORY
          pea buffer+130
          move #$3b,-(sp)
          trap #1             ;CHDIR
          addq.l #6,sp
          tst d0
          bne diskerr
          rts

; DIRECTORY REDUIT
dirw:     clr.w impflg
          move.b #1,buffer+255
          bra.s dd0
;DIRECTORY SUR IMPRIMANTE
ldir:     move #1,impflg
          clr.b buffer+255
          bra dd0
;DIRECTORY
dir:      clr impflg
          clr.b buffer+255
dd0:      bsr setdta
          move.l #$2A2E2A00,name2       ;*.* ---> NAME2
          moveq #0,d2
          bsr finie
          beq.s dd1
          bsr expalpha
dd1:      bsr ds
; affiche le message de debut de directory
          move.w brkinhib,-(sp)         ;Arrete le break!
          move.w #1,brkinhib
          movem.l a4-a6,-(sp)
          bsr impretour
          lea msd0,a0           ;Drive
          bsr traduit
          bsr impchaine
          bsr fndrive           ;numero du drive
          add.b #65,d0
          lea defloat,a0
          move.b d0,(a0)
          clr.b 1(a0)
          bsr impchaine

          lea msd1,a0           ;path
          bsr traduit
          bsr impchaine
          clr.w -(sp)
          pea defloat
          move.w #$47,-(sp)
          trap #1               ;GETDIR
          addq.l #8,sp
          tst.w d0
          bne dk3               ;disk not ready
          lea defloat,a0
          bsr plusr
          bsr impchaine

; Va remplir le buffer avec les fichiers
          bsr fillfile

; Affichage des noms des fichiers
          clr.l dirsize
          move.l hichaine,a2
dd3:      subq.w #1,fsd
          bmi dd10
          tst.b buffer+255
          beq.s dd4
; Affichage condense
          move.l 16(a2),d0
          add.l d0,dirsize
          move.l a2,a0
          bsr impchaine
          lea defloat,a0
          move.l #$20202020,(a0)
          move.l #$20200000,4(a0)
          bsr impchaine
          bra dd6
; Directory?
dd4:      cmp.b #"*",(a2)
          bne.s dd5
          lea ssdir1,a0
          bsr impchaine
          lea 1(a2),a0
          bsr impchaine
          bsr impretour
          bra.s dd6
; Fichier normal?
dd5:      lea 1(a2),a0        ;imprime le nom
          bsr impchaine
          move.l 16(a2),d0    ;prend la taille
          add.l d0,dirsize    ;additionne a la taille totale
          lea defloat,a5
          move.w #$2020,(a5)+
          move.l a2,-(sp)
          bsr longdec
          clr.b (a5)
          move.l (sp)+,a2
          lea defloat,a0      ;affiche la taille
          bsr impchaine
          bsr impretour
dd6:      lea 20(a2),a2
;appui sur les touches
dd7:      bsr ttlist
          beq dd3            ;pas d'appui
          bmi dd15           ;appui sur ESC
dd8:      bsr ttlist
          beq.s dd8
          bmi.s dd15
          bra dd3
    
; Taille prise et taille restante sur la disquette
dd10:     bsr impretour
          move.l dirsize,d0
          lea defloat,a5
          bsr longdec         ;ecris le nombre de BYTE USED
          clr.b (a5)
          lea defloat,a0
          bsr impchaine
          tst.l dirsize
          beq.s dd11
          cmp.l #1,dirsize
          bne.s dd12
dd11:     lea msd3,a0
          bra.s dd13
dd12:     lea msd2,a0 
dd13:     bsr traduit
          bsr impchaine
	  bsr impretour
dd15:     bsr sd                ;Restore drive!
          movem.l (sp)+,a4-a6
          move.w (sp)+,brkinhib ;Restore break!
          rts

;KILL
kill:     bsr setdta
          bsr namedisk        ;cherche le nom
          beq notdone
          lea name1,a0
          bsr sfirst
          bne dk1          ;file not found
kill1:    bsr unlink
          bmi diskerr
          bsr snext
          beq.s kill1
          rts

;RENAME
rename:   bsr setdta
          bsr namedisk
          beq notdone
          lea name1,a0
          lea name2,a1
          bsr transtext
          cmp.b #$80,(a6)+    ;token de TO
          bne syntax
          bsr namedisk
          beq notdone
          lea name2,a0
          bsr sfirst
          bne dk1          ;file not found
rename1:  lea name1,a1
          bsr renome
          bmi diskerr
          bsr snext
          beq.s rename1
          rts
 
;-----------------------------------------    --- ----- ---   ---    -------
;    ----------------------------------      |      |  |   | |
;   |           FILE SELECTOR          |      ---   |  |   |  ---
;    ----------------------------------          |  |  |   |     |
;-----------------------------------------    ---       ---   ---    -------

; FILL FILE: REMPLIS LE BUFFER AVEC LES FILES ALPHABETIQUEMENT!

fillfile: 
          move.l lowvar,d0      ;Au moins 2560 octets de libre?
          sub.l #2600,d0
          cmp.l hichaine,d0
          bhi.s F1
          bsr menage
F1:       move.l hichaine,a0    ;Adresse du buffer= hichaine!
          moveq #127,d0         ;128 noms
F2:       moveq #13,d1          ;RAZ du buffer
F3:       move.b #32,(a0)+
          dbra d1,F3
          clr.w (a0)+           ;Fin de la chaine
          clr.l (a0)+           ;Place pour la taille
          dbra d0,F2                    
          bsr setdta
          clr fsd
; Cherche les directories
          lea etoile,a0
          moveq #$10,d0
          bsr sfirst
          bne.s F6
F4:       lea dta,a2
          cmp.b #$10,21(a2)   ;Ne veut que des directory
          bne.s F5
          bsr putfile
F5:       bsr snext
          beq.s F4
; Cherche les fichiers
F6:       lea name2,a0
          clr.l d0
          bsr sfirst
          bne.s FF
F7:       bsr putfile
          bsr snext
          beq.s F7
FF:       rts

; PUT FILE: POKE DANS LE BUFFER
putfile:  cmp #128,fsd        ;Pas plus de 128!
          bcc.s FF
; Poke le nom au debut du buffer
          lea fsbuff,a0
          move.l a0,a1  
          moveq #13,d0
pf0:      move.b #32,(a1)+      ;Nettoie le buffer
          dbra d0,pf0
          clr.w (a1)+
          move.l a0,a1
          lea dta,a2
          move.l 26(a2),16(a0)  ;Taille du fichier
          btst #4,21(a2)        ;Si directory, met * avant!
          beq.s pf1
          move.b #"*",(a0)
pf1:      addq.l #1,a0
          lea 30(a2),a2
          clr d1
pf2:      move.b (a2)+,d0
          beq.s pf5
          cmp.b #".",d0
          beq.s pf3
          move.b d0,(a0)+
          addq #1,d1
          bra.s pf2
pf3:      tst d1              ;enleve les . et ..
          beq.s FF
          lea 9(a1),a0
          move.b d0,(a0)+
pf4:      move.b (a2)+,d0
          beq.s pf5
          move.b d0,(a0)+
          bra.s pf4
; Cherche la place dans le buffer
pf5:      move.l hichaine,a2
          move.w fsd,d2
          beq.s pfC
          subq.w #1,d2
pf6:      lea fsbuff,a0
          move.l a2,a1
pf7:      move.b (a0)+,d0
          beq.s pf9
          cmp.b #'*',d0
          bne.s pf8
          move.b #31,d0
pf8:      move.b (a1)+,d1
          beq.s pf9
          cmp.b #'*',d1
          bne.s pfZ
          move.b #31,d1
pfZ:      cmp.b d1,d0
          beq.s pf7
          bcs.s pfA
pf9:      lea 20(a2),a2
          dbra d2,pf6
          bra.s pfC
; Decale le reste du buffer---> fin
pfA:      move.w fsd,d0       ;Adresse du dernier nom!
          mulu #20,d0
          add.l hichaine,d0  
          move.l d0,a0
          sub.l a2,d0         ;distance choisi/dernier
          beq.s pfC           ;C'est le dernier
          bcs.s pfC           ;Improbable!
          lsr.w #2,d0         ;Divise par 4---> nb de long mots
          subq.w #1,d0
          lea 20(a0),a1
pfB:      move.l -(a0),-(a1)  ;Boucle de recopie
          dbra d0,pfB
; Recopie du nom
pfC:      moveq #20-1,d0
          lea fsbuff,a0
pfD:      move.b (a0)+,(a2)+
          dbra d0,pfD
; Un nom de plus!
          add.w #1,fsd
          rts 

; Pitit ss pgm---> adresse dans le buffer
adbufile: mulu #20,d0
          move.l hichaine,a0
          add d0,a0
          move.l a0,a1
          rts                       
         
; D1-> normal/inverse
norminv:  tst d1
          bne.s fsinv
fsnorm:   movem.l d0/d7/a0,-(sp)
          moveq #0,d7
          moveq #18,d0
          trap #3
          movem.l (sp)+,d0/d7/a0
          rts
fsinv:    movem.l d0/d7/a0,-(sp)
          moveq #0,d7
          moveq #21,d0
          trap #3
          movem.l (sp)+,d0/d7/a0
          rts

; memorise le curseur
memocurs: movem.l d0/d7/a0,-(sp)
          moveq #0,d7
          moveq #20,d0        
          trap #3
          moveq #17,d7
          trap #3
          move.l d0,fsd+10
          movem.l (sp)+,d0/d7/a0
          rts

; remet le curseur
remetcurs:movem.l d0/d7/a0,-(sp)
          move.l fsd+10,d0
          move d0,d1
          swap d0
          moveq #2,d7
          trap #3
          moveq #0,d7
          moveq #17,d0
          trap #3
          movem.l (sp)+,d0/d7/a0
          rts          
           
; WRITEPOS: ECRIS UN MOT (a0) EN D0/D1 ET STOCKE DANS LA TABLE SOURIS (D2)
writepos: movem.l d0-d7/a0-a2,-(sp)
          lsl #3,d2
          lea defloat+16,a2	;fsmouse
          add d2,a2
          move.l a0,a1
          move d0,d2
          moveq #2,d7
          trap #3             ;locate
          move d2,d0
          moveq #35,d7
          trap #3
          move d0,(a2)+       ;fixe DX
          move d1,d0      
          moveq #36,d7
          trap #3
          move d0,(a2)+       ;fixe DY
          move.l a1,a0
          moveq #1,d7
          trap #3             ;imprime le mot
          moveq #17,d7
          trap #3
          move d0,d1
          swap d0
          moveq #35,d7
          trap #3
          move d0,(a2)+       ;fixe FX
          move d1,d0
          moveq #36,d7
          trap #3
          cmp #2,mode
          bne.s wrtp1
          addq #8,d0
wrtp1:    addq #8,d0
          move d0,(a2)+
          movem.l (sp)+,d0-d7/a0-a2
          rts
          
; WRITEXT: ECRIS LA PHRASE #D0, D1-INVERSE/NORMAL
writext:  movem.l d0-d2/a0-a2,-(sp)
          bsr norminv
          move d0,d2
          lsl #3,d0
          lea fstext,a1
          add d0,a1
          move.l (a1)+,a0
          cmp #6,d2
          bcc.s wt3
          bsr traduit
wt3:      move.w (a1)+,d0
          move.w (a1)+,d1
          bsr writepos
          movem.l (sp)+,d0-d2/a0-a2
          rts

; TROUVE ET AFFICHE LE PATHNAME
pathaff:  bsr memocurs
          moveq #7,d0
          clr d1
          bsr writext
          lea 7*8+fstext,a0
          move.w 4(a0),d0     ;locate
          move.w 6(a0),d1
          moveq #2,d7
          trap #3
          bsr fndrive         ;cherche le disque courant
          lea name1,a0
          add.b #65,d3
          move.b d3,(a0)+
          move.b #":",(a0)+
          clr.w -(sp)         ;cherche le path courant
          move.l a0,-(sp)
          move.w #$47,-(sp)
          trap #1
          addq.l #8,sp
          lea name1,a0        ;affiche le path
          move.l a0,a1
ph1:      tst.b (a1)+
          bne.s ph1
          move.b #"\",-1(a1)
          clr.b (a1)
          moveq #1,d7
          trap #3
          lea name2,a0     ;affiche le filtre
          trap #3
          bsr remetcurs
          tst fsd+14        ;reloge le curseur si dans le path!    
          beq.s ph2
          bsr locpath
ph2:      rts

; AFFICHE LES DRIVES
drivaff:  bsr memocurs
          movem.l d0-d7/a0-a2,-(sp)
          move.w #10,-(sp)
          trap #13            ;DRVMAP
          addq.l #2,sp
          move.l d0,d6
          move #$19,-(sp)
          trap #1             ;CURRENT DISK
          addq.l #2,sp
          move d0,d5
          clr d4              ;compteur 0-7: # du carre          
da0:      clr d2
          clr d3
da1:      btst d3,d6
          beq.s da2
          cmp d2,d4
          beq.s da3
          addq #1,d2
da2:      addq #1,d3
          cmp #26,d3
          bcs.s da1
          bra da10
da3:      lea fsdriv,a2
          move d4,d0
          lsl #2,d0
          add d0,a2
          move 0(a2),d0
          move 2(a2),d1
          moveq #2,d7
          trap #3             ;locate
          bsr fsnorm
          move fsd+22,d0
          moveq #3,d1
          moveq #3,d2
          moveq #39,d7
          trap #3             ;cadre
          moveq #0,d1
          cmp d3,d5
          bne.s da4
          moveq #1,d1
da4:      bsr norminv         ;normal/inverse
          move 0(a2),d0
          move 2(a2),d1
          addq #1,d0
          addq #1,d1
          move d4,d2
          add #8,d2           ;drives: 8--->15
          add #65,d3
          lea defloat,a0
          move.b d3,(a0)
          clr.b 1(a0)
          bsr writepos        ;ecris et stocke
da10:     addq #1,d4
          cmp #8,d4
          bcs da0
          clr fsd+4
          movem.l (sp)+,d0-d7/a0-a2
          bsr remetcurs
          rts

; AFFICHE LE NOM FICHIER d0 EN INVERSE/NORMAL d1
fileaff:  movem.l d0-d2/a0-a1,-(sp)
          bsr norminv
          move d0,d1
          bsr adbufile
          sub fsd+2,d1
          move d1,d2    
          addq #3,d1          ;locate
          moveq #1,d0
          add #16,d2          ;table: 16--->29
          bsr writepos
          movem.l (sp)+,d0-d2/a0-a1
          rts

; AFFICHE TOUS LES NOMS DE FICHIER DANS LA FENETRE
filesaff: bsr memocurs
          move fsd+2,d0
          moveq #12,d2
          clr d1      
fa1:      bsr fileaff
          addq #1,d0
          dbra d2,fa1
          bsr remetcurs
          rts   

; locate dans le nom
locnom:   movem.l d0/d1/d7/a0,-(sp)
          lea 6*8+fstext,a0
          move.w 4(a0),d0
          add fsd+16,d0
          move.w 6(a0),d1
          moveq #2,d7
          trap #3
          clr fsd+14
          movem.l (sp)+,d0/d1/d7/a0
          rts

; locate dans le path
locpath:  movem.l d0/d1/d7/a0/a1,-(sp)
          lea name1,a0
lp1:      tst.b (a0)+
          bne.s lp1
          sub.l #name1+1,a0
          move a0,fsd+20
          lea 7*8+fstext,a1
          move.w 4(a1),d0
          add.w a0,d0
          add.w fsd+18,d0
          clr d1
          cmp.w #32,d0        ;sur la deuxieme ligne?
          bcs.s lp2
          moveq #1,d1
          sub #32,d0
lp2:      add.w 6(a1),d1
          moveq #2,d7
          trap #3
          move #1,fsd+14
          movem.l (sp)+,d0/d1/d7/a0/a1
          rts

; ENTREE POUR FLOAD/FSAVE
ffsel:    lea fsbuff,a1
ffs:      move.b (a0)+,(a1)+    ;recopie la chaine dans le buffer
          bne.s ffs 
          move #1,fsd+24
          move #1,fsd+22
          move #1,fsd+26
          bsr expalpha
          move parenth,-(sp)
          bra.s ffs0
; a$=FILE SELECT$ ("A:\*.*",[["title"],border])
fselector:tst runflg          ;pas en mode direct!
          beq illdir
          clr fsd+26
          clr fsd+24           ;pas de title
          move #1,fsd+22       ;border par defaut
          cmp.b #"(",(a6)+
          bne syntax
; prend et analyse le diskname
          move parenth,-(sp)
          clr parenth
          bsr evalbis         ;diskname
          bsr alphaq          ;verifie variable alphanumerique
ffs0:     bsr ds              ;ROUTINE GENIALE de directory!
          moveq #-1,d0
          lea name2,a0
fs1:      addq.l #1,d0        ;trouve la longueur du filtre!
          tst.b (a0)+
          bne.s fs1
          move.w d0,fsd+18       ;longueur du filtre
          tst fsd+26             ;si vient de FSAVE/FLOAD, arrete le
          bne fs0                ;desastre!
          cmp #-1,parenth
          beq fs0
          tst parenth
          bne syntax
; prend title
          cmp.b #",",(a6)+
          bne syntax
          bsr evalbis
          bsr alphaq
          cmp.w #64,d2
          bcc foncall
          lea fsbuff,a0
          bsr chverbuf2
          move #1,fsd+24
          cmp #-1,parenth
          beq fs0
          tst parenth
          bne syntax
;prend border
          cmp.b #",",(a6)+
          bne syntax
          move #1,parenth
          bsr entierbis
          tst.l d3
          beq foncall
          cmp.l #16,d3
          bcc foncall
          move d3,fsd+22
; fini!
fs0:      move (sp)+,parenth
; raz du buffer souris
          lea defloat+16,a0	;fsmouse
          moveq #63,d0
fs3c:     clr.l (a0)+
          dbra d0,fs3c
; dessin de la fenetre
          bsr fz1             ;freeze sprites!
          move mode,d0
          mulu #10,d0
          lea fswind,a0
          add d0,a0
          moveq #13,d0
          move.w fsd+22,d1     ;jeux de caractere
          swap d1
          move.w (a0)+,d1     ;bordure
          move.w (a0)+,d2     ;dx
          move.w (a0)+,d3     ;dy
          move.w (a0)+,d4     ;tx
          move.w (a0)+,d5     ;ty
          move.w valpen,d6    ;pen
          swap d6
          move.w valpaper,d6  ;paper
          moveq #6,d7         ;initwind
          trap #3
          tst d0
          beq.s fs4
          jmp winderr
fs4:      moveq #0,d7
          moveq #20,d0        ;arret curs
          trap #3
          moveq #25,d0        ;scroll off
          trap #3
          tst fsd+24           ;imprime le titre
          bne.s fs4a
          lea fst,a0
          bsr traduit
          moveq #18,d7
          trap #3
          bra.s fs4b
fs4a:     lea fsbuff,a0
          moveq #1,d7
          trap #3
fs4b:     lea fsc,a2      ;imprime les cadres
          moveq #5,d3
fs5:      move.w (a2)+,d0
          move.w (a2)+,d1
          moveq #2,d7
          trap #3
          move.w (a2)+,d1
          move.w (a2)+,d2
          move.w fsd+22,d0
          moveq #39,d7
          trap #3
          dbra d3,fs5           
          clr d0
fs6:      clr d1 
          bsr writext         ;affichage du texte
          addq #1,d0
          cmp #7,d0
          bcs.s fs6
; raz du nom
          clr fsd+16 
          lea fsname,a0
          moveq #12,d0
fs6a:     clr.b (a0)+
          dbra d0,fs6a
          bsr locnom
; affiche le pathname
          bsr pathaff   
; affichage des drives
          bsr drivaff
; remplissage du buffer
          bsr fillfile
; affiche tous les fichiers
          clr fsd+2
          move #-1,fsd+6
          bsr filesaff
; raz du buffer clavier
          bsr clearkey
; boucle d'attente
fswait:   tst.b interflg
          bpl.s fs9
          and.b #$7f,interflg
          beq.s fs9
          bclr #0,interflg    
          beq.s fs9
          moveq #13,d0
          moveq #9,d7
          trap #3             ;efface la fenetre
          bsr ufz1            ;remet tout en route!          
          jmp braik           ;et fait le break  
fs9:      moveq #20,d0        ;trouve la zone de la souris
          trap #5
          clr d2
          lea defloat+16,a0	;fsmouse
fs10:     cmp (a0),d0
          bcs.s fs11
          cmp 2(a0),d1
          bcs.s fs11
          cmp 4(a0),d0
          bcc.s fs11
          cmp 6(a0),d1
          bcs.s fs12
fs11:     addq.l #8,a0
          addq #1,d2
          cmp #32,d2
          bcs.s fs10
; dans aucune: eteint ce qui etait allume
          tst fsd+4
          bne.s fs12a
          move #-1,fsd+6
          bra.s fs19
; dans une zone 
fs12:     tst fsd+4
          beq.s fs13  
          cmp fsd+6,d2    ;on reste sur le meme!
          beq fs19
fs12a:    clr d1
          move fsd+6,d2
          move #-1,fsd+6   
          bra.s fs14
fs13:     move d2,fsd+6
          moveq #1,d1
fs14:     move d1,fsd+4
          cmp #6,d2           ;inverse une commande
          bcc.s fs15
          move d2,d0
          bsr memocurs
          bsr writext
          bsr remetcurs
          bra.s fs19
fs15:     cmp #16,d2          ;n'inverse pas les drives!
          bcs.s fs19
          move d2,d0
          sub #16,d0
          add fsd+2,d0
          cmp fsd,d0
          bcc.s fs19
          bsr memocurs
          bsr fileaff         ;inverse un nom de file
          bsr remetcurs

; TESTS DU CLAVIER
fs19:     bsr incle
          beq fs19z
          bsr fsnorm          ;affichage normal!
          tst.w d0
          bne.s fs19a
          swap d0
          cmp.b #72,d0        ;locate nom
          beq fs26a
          cmp.b #80,d0        ;locate path
          beq fs27a
          bra fswait
fs19a:    cmp.b #13,d0        ;RETURN
          bne.s fs19j
          tst fsd+14
          beq fs25c           ;si dans NOM----> OK
          bne fs22d           ;si dans PATH---> DIR  
fs19j:    tst fsd+14
          bne fs19p
; dans le nom
          lea fsname,a1
          move fsd+16,d1
          cmp.b #8,d0
          bne.s fs19c
fs19b:    tst d1              ;backspace
          beq fswait
          subq #1,d1
          move d1,fsd+16
          move.b 0(a1,d1.w),d2
          move.b #32,0(a1,d1.w)
          lea fsr,a0
          moveq #1,d7
          trap #3
          cmp.b #32,d2
          beq.s fs19b
          bra fswait
fs19c:    cmp.b #".",d0       ;point?
          bne fs19d
          cmp #9,d1
          bcc fswait
fs19g:    cmp #8,d1
          beq fs19h
          move.b #32,0(a1,d1.w)
          moveq #32,d0
          moveq #0,d7
          trap #3
          addq #1,d1
          bra fs19g
fs19h:    move d1,fsd+16
          move.b #".",d0
          bra fs19f 
fs19d:    cmp.b #97,d0
          bcs.s fs19e
          sub.b #$20,d0
fs19e:    cmp.b #"_",d0
	beq.s fs19i
	cmp.b #48,d0
          bcs fswait
          cmp.b #58,d0
          bcs.s fs19i
          cmp.b #65,d0
          bcs fswait
          cmp.b #91,d0
          bcc fswait
fs19i:    cmp #8,d1
          beq fswait
fs19f:    cmp #12,d1
          bcc fswait
          move.b d0,0(a1,d1.w)
          addq #1,d1
          move d1,fsd+16
          moveq #0,d7
          trap #3
          bra fswait
; dans le path
fs19p:    lea name2,a1
          move fsd+18,d1
          cmp.b #8,d0
          bne.s fs19q
          tst d1
          beq fswait
          subq #1,d1
          move d1,fsd+18
          clr.b 0(a1,d1.w)
          lea fsr,a0
          moveq #1,d7
          trap #3
          bra fswait
fs19q:    cmp.b #97,d0
          bcs.s fs19r
          sub.b #32,d0
fs19r:    cmp.b #"*",d0
          beq.s fs19s
          cmp.b #".",d0
          beq.s fs19s
          cmp.b #"?",d0
          beq.s fs19s
	cmp.b #"_",d0
	beq.s fs19s
          cmp.b #48,d0
          bcs fswait
          cmp.b #58,d0
          bcs.s fs19s
          cmp.b #65,d0
          bcs fswait
          cmp.b #91,d0
          bcc fswait
fs19s:    cmp #12,d1
          bcc fswait
          move d1,d2
          add fsd+20,d2
          cmp #60,d2
          bcc fswait
          move.b d0,0(a1,d1.w)
          addq #1,d1
 	clr.b 0(a1,d1.w)
          move d1,fsd+18
          moveq #0,d7
          trap #3
          bra fswait
            
; TESTS DE LA SOURIS
fs19z:    tst fsd+6         ;pas de choix si rien en inverse!  
          bmi fswait
          moveq #21,d0
          trap #5             ;mousekey
          tst d0
          bne.s fs20
          clr fsd+8
          bra fswait
fs20:     tst fsd+8
          bne fswait
          move #1,fsd+8
          move fsd+6,d1
          bne.s fs21
; HAUT
          cmp #1,d0
          bne.s fs20a
          moveq #1,d0
          clr fsd+8
          bra.s fs20b
fs20a:    moveq #13,d0
fs20b:    sub d0,fsd+2
          bcc.s fs20c
          clr fsd+2
fs20c:    bsr filesaff
          bra fswait

fs21:     cmp #1,d1
          bne fs22
; BAS
          cmp #1,d0
          bne.s fs21a
          moveq #1,d0
          clr fsd+8
          bra.s fs21b
fs21a:    moveq #13,d0
fs21b:    cmp #13,fsd
          bls fswait
          add fsd+2,d0
          move d0,d1
          add #13,d1
          cmp fsd,d1
          bls fs21c
          move fsd,d0
          sub #13,d0
fs21c:    move d0,fsd+2
          bsr filesaff
          bra fswait

fs22:     cmp #2,d1
          bne fs23
; PREVIOUS DIR
          lea name1,a0
fs22a:    tst.b (a0)+
          bne.s fs22a
          cmp.l #name1+2,a0
          beq fswait
fs22b:    cmp.b #"\",-(a0)
          bne fs22b
fs22c:    cmp.b #"\",-(a0)
          bne.s fs22c
          clr.b 1(a0)
fs22d:    pea name1
          move.w #$3b,-(sp)
          trap #1
          addq.l #6,sp
          bsr pathaff
          bsr fillfile
          clr fsd+2
          bsr filesaff
          bra fswait

fs23:     cmp #3,d1
          bne fs24
; DIR
          bra fs22d

fs24:     cmp #4,d1
          bne fs25
; QUIT
fs24a:    moveq #13,d0
          moveq #9,d7
          trap #3             ;efface la fenetre
          bsr ufz1            ;remet tout en route!
          jmp mid9            ;chaine vide, et revient!

fs25:     cmp #5,d1
          bne fs26
; RETURN
fs25c:    moveq #13,d0
          moveq #9,d7
          trap #3
          moveq #12,d3
          jsr demande
          addq.l #2,a0
          lea fsname,a2
          clr d1
fs25a:    move.b (a2)+,d0
          beq.s fs25b
          cmp.b #32,d0
          beq.s fs25a
          move.b d0,(a0)+
          addq #1,d1
          bra.s fs25a
fs25b:    move.w d1,(a1)
          movem.l a0-a1,-(sp) ;remet les sprites
          bsr ufz1
          movem.l (sp)+,a0-a1
          jmp mid7a           ;met la chaine et revient!

fs26:     cmp #6,d1
          bne fs27
; LOCATE DANS LE NOM
fs26a:    bsr locnom
          bra fswait

fs27:     cmp #7,d1
          bne fs28
; LOCATE DANS LE PATH
fs27a:    bsr locpath
          bra fswait

fs28:     cmp #16,d1
          bcc fs29
; CHANGEMENT DE DRIVE
          subq #8,d1
          move d1,-(sp)
          move #10,-(sp)
          trap #13            ;drvmap
          addq.l #2,sp
          move (sp)+,d1
          clr d2
          clr d3
fs28a:    btst d3,d0
          beq.s fs28b
          cmp d2,d1
          beq.s fs28c
          addq #1,d2
fs28b:    addq #1,d3
          bra.s fs28a
fs28c:    move.w d3,-(sp)
          move.w #$e,-(sp)
          trap #1             ;setdrive
          addq.l #4,sp
          bsr drivaff         ;reaffiche les drives
          lea name1,a0        ;raz du path
          move.b #"\",(a0)+
          clr.b (a0)
          bra fs22d
          
; DANS LES FICHIERS
fs29:     sub #16,d1
          add fsd+2,d1
          cmp fsd,d1
          bcc fswait
          move d1,d0
          bsr adbufile
          cmp.b #"*",(a0)+
          bne fs29d
; met un sous directory
          lea name1,a1
fs29a:    tst.b (a1)+
          bne.s fs29a
          subq.l #1,a1
fs29b:    move.b (a0)+,d0
          beq.s fs29c
          cmp.b #32,d0
          beq.s fs29b
          move.b d0,(a1)+
          cmp.l #name1+63,a1
          bcs.s fs29b
          bsr pathaff         ;si trop de ss directory: ignore!         
          bra fswait
fs29c:    clr.b (a1)
          bra fs22d         ;branche a PREVIOUS
; prend un nom de fichier normal
fs29d:    clr fsd+16
          bsr locnom
          bsr fsnorm
          lea fsname,a1
          clr d1
          clr d2
          clr d3
fs29e:    move.b (a0)+,d0     ;recopie et compte la taille du nom
          addq #1,d1
          cmp.b #32,d0
          beq.s fs29f
          move d1,d2 
fs29f:    cmp.b (a1),d0
          bne.s fs29g
          addq #1,d3      
fs29g:    move.b d0,(a1)+
          cmp #12,d1
          bne.s fs29e
          clr.b (a1)
          move.w d2,fsd+16
          lea fsname,a0       ;reaffiche
          moveq #1,d7
          trap #3
          bsr locnom          ;curseur a la fin du nom
          cmp #12,d3
          beq fs25c           ;si le meme nom: RETURN  
          bra fswait
    
;LA FENETRE D0 FAIT ELLE PARTIE DU MODE? BEQ=oui, BNE=non
fenmode:  move typecran,d5
fenec:    mulu #5,d5
          lea tt,a0
          add d5,a0
cr1:      cmp.b (a0)+,d0      ;la fenetre fait-elle partie du mode?
          beq.s cr2
          tst.b (a0)
          bpl.s cr1
cr2:      rts

;CONVERSION #FENETRE DE 1->4 EN #FENETRE DE 1->6
convfen:  move typecran,d1
convf2:   mulu #5,d1
          lea tc,a0
          add d1,a0
          and #$00ff,d0
          move.b 0(a0,d0.w),d0  ;d0 contient le numero ou -1
          rts

;CONVERSION #FENETRE DE 1->6 EN #FENETRE DE 1-4
fenconv:  lea tb,a0
          and #$00ff,d0
          move.b 0(a0,d0.w),d0
          rts

;CLICK AVEC LA SOURIS DANS UNE FENETRE
clickfen: sub #10,d1            ;d1: numero fenetre de 1->4
          move fenetre,d0
          beq.s clck1           ;full screen
          bsr fenconv
          cmp d0,d1
          beq.s clck1           ;va positionner le curseur
          move program,d2
          lsl #4,d2
          move d1,d0
          subq #1,d1
          lsl #2,d1
          add d1,d2
          lea reparti,a0      ;pointe le programme sur la fenetre choisie
          add d2,a0
          tst.l (a0)
          beq boucle          ;pas possible: le programme n'est pas edite la
          bsr convfen
          bmi boucle          ;pas possible ????!!!
          bsr chge4           ;activation rapide de la fenetre
          bra boucle
; Clique dans la fenetre courante
clck1:    moveq #20,d0
          trap #5
	move.l d1,d2
	moveq #37,d7
	trap #3
	tst.w d0
	bmi boucle
	exg d0,d2
	moveq #38,d7
	trap #3
	tst.w d0
	bmi boucle
 	move d0,d1
	moveq #17,d7        ;coordonnees actuelles du curseur
          trap #3
          cmp d0,d1           ;si l'on clique au meme endroit
          bne.s clck4
          swap d0
          cmp d0,d2
          beq return          ;alors RETURN
clck4:    move d2,d0
          move #2,d7
          trap #3             ;locate! super!
          bra boucle

;WINDNEXT: PASSE A LA FENETRE SUIVANTE DU PROGRAMME DANS CET ECRAN!
windnext: move program,d0
          lsl #4,d0
          lea reparti,a1
          add d0,a1
          move fenetre,d0
          beq windn10         ;fenetre zero: on change pas
          bsr fenconv         ;1-6 ---> 1-4
          move d0,d2
windn0:   move d2,d0
          addq #1,d0          ;cherche la suivante dans DATAPRG
          cmp #5,d0
          bne.s windn1
          move #1,d0
windn1:   move d0,d1
          move d1,d2
          subq #1,d1
          lsl #2,d1
          tst.l 0(a1,d1.w)
          beq.s windn0
          bsr convfen         ;1-4 ---> 1-6
          bmi.s windn0          ;ca marche pas
          bsr chge4           ;activation rapide
windn10:  bra boucle

;L'ECRAN D1 CONTIENT-IL UNE FENETRE POUR L'EDITION DU PRG?
prgmode:  move d1,-(sp)       ;si oui, la prend
          move program,d2
          lsl #4,d2
          lea reparti,a1
          add d2,a1
          move #1,d2
pgd2:     tst.l (a1)+
          bne.s pgd3
pgd2b:    addq #1,d2
          cmp #5,d2
          bne.s pgd2
          move (sp)+,d1       ;NON: beq
          clr d0
          rts
pgd3:     move d2,d0
          move (sp)+,d1
          move d1,-(sp)
          bsr convf2
          bmi.s pgd2b           ;essaie un autre!
          move (sp)+,d1       ;OUI: bne, d0=#fenetre
          move #1,d3
          rts

;FULLSCREEN: retour a l'edition sur un seul ecran
fullscreen:tst.b (a6)
          bne syntax
          tst typecran
          beq ok
          clr d0
          clr d1
          bsr chgecran
          bra ok

;MULTISCREEN: passe mode EDITION MULTIPLE
multi:    bsr expentier
          move.l d3,d0
ml1:      cmp.l #2,d0
          bcs foncall
          cmp.l #5,d0
          bcc foncall
          cmp typecran,d0     ;cet ecran est deja choisi!
          beq ok
;essaie de conserver la meme fenetre d'un ecran a l'autre
          move d0,d1
          move fenetre,d0
          move d1,d5
          bsr fenec           ;la fenetre peut elle etre conservee?
          beq.s ml1b          ;OUI
          bsr prgmode         ;NON: trouve une fenetre qui peut marcher
          beq.s ml1c          ;Y'en a pas!
ml1b:     bsr chgecran
          bra ok
; message d'erreur: program #x cannot be...
ml1c:     move program,d0
          add #49,d0
          move.b d0,errmult2
          lea errmult,a0
          bsr traduit
          move #1,d7
          trap #3
          lea errmult2,a0
          trap #3
          bra ok

; REAFFICHE PAR MAGOUILLE L'ANCIEN ECRAN
reaffiche:move typecran,d1
          bne.s reaff1
          move #2,typecran
          bra.s reaff2
reaff1:   clr typecran
reaff2:   move fenetre,d0

;CHANGEMENT D'ECRAN OPTIMISE AVEC ACTIVATION FENETRE CHOISIE!
chgecran: movem d0-d1,-(sp)
          move typecran,d2
          mulu #4*5,d2
          lsl #2,d1
          add d2,d1
          lea ps,a1
          add d1,a1
          move #3,d2
chge1:    clr d0              ;effectue le changement d'ecran
          move.b (a1)+,d0
          bmi.s chge3
          move d0,d1
          bsr defaut
          tst d0
          beq.s chge2
          move d1,d0
          move #8,d7
          trap #3
chge2:    dbra d2,chge1
chge3:    movem (sp)+,d0-d1    ;active la fenetre d0
          move d1,typecran
          move d0,-(sp)
          bsr zonecran
          move (sp)+,d0
;activation rapide fenetre d0
chge4:    move d0,fenetre
          moveq #16,d7
          trap #3
          eor #1,ins    ;provoque le REENVOI de la taille du curseur
          bsr insere
          jsr curseur
          rts

;ENVOIE LES ZONES DE TEST DE LA SOURIS CORRESPONDANT A L'ECRAN AFFICHE
zonecran: move typecran,d0
          beq.s ze1
          subq #1,d0
ze1:      mulu #18*2*3,d0
          move mode,d1
          mulu #18*2,d1
          add d1,d0
          lea modezone,a2
          add d0,a2
          bra envzone

;GRAB: CHERCHE DES LIGNES DANS UN AUTRE PROGRAMME
grab:     bsr expentier
          tst.l d3
          beq foncall
          cmp.l #5,d3
          bcc foncall
          move.b (a6),d1
          beq.s grab1
          cmp.b #",",d1
          bne syntax
          addq.l #1,a6
grab1:    subq #1,d3
          lsl #3,d3
          lea dataprg,a1
          add d3,a1
          move.l (a1),a1
          bsr parambis        ;cherche les parametres LIST

grab2:    tst.w (a6)
          beq.s grab5
          cmp 2(a6),d5
          bcs.s grab5
          bsr stockage
          add (a6),a6
          bra.s grab2
grab5:    bra ok

;SOUS PROGRAMME HELP: POSITIONNE LE CURSEUR SUR LA FENETRE HELP
poshelp:  lea tposhelp,a0
          move d4,d0
          move d5,d1
          mulu #10,d0
          lsl #1,d1
          add d1,d0
          add d0,a0
          move.b (a0)+,d0
          move.b (a0),d1
          move #2,d7
          trap #3
;positionnne a3 et a4 sur les pointeurs fenetre/programme!
pospoint: lea defloat,a3
          move d5,d0
          subq #1,d0
          mulu #6,d0
          add d0,a3           ;a3 pointe copie decimale
          lea reparti,a4
          move d4,d0
          lsl #4,d0
          move d5,d1
          subq #1,d1
          lsl #2,d1
          add d1,d0
          add d0,a4           ;a4 pointe le debut/fin
          rts

;SOUS PROGRAMME HELP: AFFICHE LES DONNEES DU PROGRAMME D4
;affiche la longueur du programme en premier
helprg:   movem.l d4/d5/a4,-(sp)
          clr d5
          bsr poshelp         ;curseur en dessous de SIZE
          lea effsize,a0
          move #1,d7
          trap #3
          bsr poshelp
          move d4,d1
          lsl #3,d1
          lea dataprg,a0
          move.l 4(a0,d1.w),d0
          subq.l #2,d0
          lea defloat,a5
          move d4,-(sp)
          bsr longdec
          move (sp)+,d4
          clr.b (a5)
          lea defloat,a0
          move #1,d7
          trap #3             ;affiche le chiffre
          bra.s hp3
;affiche et poke les numeros de ligne
helprg2:  movem.l d4/d5/a4,-(sp)
          clr d5
hp3:      addq #1,d5
          bsr poshelp
          lea effhelp,a0
          move.l a3,a1
          bsr transtext
          move 2(a4),d0       ;ligne de fin
          beq.s hp5
          cmp #$ffff,d0
          bne.s hp4
          lea helpend,a0      ;65535: jusque a la fin
          move.l a3,a1
          bsr transtext
          bra.s hp5
hp4:      move.l a3,a5
          move d4,-(sp)
          bsr longdec
          move (sp)+,d4
hp5:      move.l a3,a0
          move #1,d7
          trap #3
          cmp #4,d5
          bne.s hp3
          movem.l (sp)+,d4/d5/a4
          rts

;INITIALISATION DE LA TABLE DE REPARTITION FENETRE
repartini:lea reparti,a0
          move #15,d0
rep1:     clr.l (a0)+
          dbra d0,rep1
          move #3,d4
rep2:     move d4,d5
          addq #1,d5
          bsr pospoint
          move #$ffff,2(a4)
          dbra d4,rep2
          rts

;EFFACE LA LIGNE OU SE TROUVE LE CURSEUR
lignen:   movem d4-d5,-(sp)
          move #18,d0         ;retour a la normale
          clr d7
          trap #3
          bsr helprg2         ;reaffiche la ligne
          movem (sp)+,d4-d5
          rts

;FONCTION (TRES) SPECIALE: HELP --->c'est genial, mais c'est chiant!
help:     clr undoflg
          tst mnd+12         ;SURTOUT PAS DE HELP AVEC LA BARRE DE MENUS!
          bne boucle
          move.l adlogic,d0   ;SURTOUT PAS DE HELP NON PLUS SI ON VOIT PLUS
          cmp.l adphysic,d0   ;L'ECRAN!
          bne boucle
          bsr stopall
          bsr putchar         ;remet les caracteres !!!
          moveq #13,d7
          trap #3             ;get courante
          move d0,avanthelp   ;sauve pour retablir apres le help!
; fait apparaitre la fenetre
          moveq #7,d0
          bsr defaut          ;fenetre #7: HELP (#14)
          tst d0
          bne.s hc1
          lea helptext,a0
          bsr tcentre         ;affiche le fond
          bra.s hc5
hc1:      moveq #8,d7         ;Deja cree! l'active!
          moveq #14,d0
          trap #3             ;activation de la fenetre #14
; affiche le texte dans la bonne langue
hc5:      clr d0
          moveq #2,d1
          moveq #2,d7
          trap #3
          lea thelp2,a0
          bsr traduit
          moveq #18,d7
          trap #3             ;entete du tableau
          clr d0
          moveq #10,d1
          moveq #2,d7
          trap #3
          lea thelp3,a0
          bsr traduit
          moveq #18,d7
          trap #3             ;Basic accessorie loaded
          clr d0
          moveq #16,d1
          moveq #2,d7
          trap #3
          lea thelp4,a0
          bsr traduit
          moveq #18,d7
          trap #3             ;remaining memory
          clr d4
hlp1:     bsr helprg          ;affiche les donnees des 4 programmes
          addq #1,d4
          cmp #4,d4
          bne.s hlp1
;affiche les noms des accessoires
          lea accnames,a2
          moveq #4,d4
hd1:      clr.l d5
hd2:      bsr poshelp         ;va positionner le curseur
          clr d7
          move #7,d2
hd3:      move.b (a2)+,d0     ;affiche le nom
          trap #3
          dbra d2,hd3
          addq #1,d5
          cmp #4,d5
          bcs.s hd2
          addq #1,d4
          cmp #7,d4
          bcs.s hd1
;affiche la remaining memory!
          move #7,d4
          clr d5
          bsr poshelp         ;curseur sur remaining
          move.l himem,d0
          sub.l fsource,d0
          lea defloat,a5
          bsr longdec
          clr.b (a5)
          lea defloat,a0
          move #1,d7
          trap #3
;saisie des numeros de ligne
          move program,d4     ;pointe au debut sur le programme EDITE!
          move #1,d5

hlp3:     clr d0
          clr d1
          moveq #2,d7
          trap #3
          lea thelp1,a0
          bsr traduit
          moveq #18,d7
          trap #3
          move d4,d0
          add #49,d0
          clr d7
          trap #3             ;affiche prg edited #, centre.
          move #21,d0
          clr d7
          trap #3
          bsr helprg2         ;affiche la ligne en inverse

hlp4:     bsr poshelp         ;position activee
          clr d3              ;RAZ pointeur
hlp5:     bsr incle
          tst.l d0
          beq.s hlp5
          move.l d0,d1
          swap d1
          cmp.b #$62,d1       ;HELP pour ressortir
          beq finhelp
          cmp.b #$61,d1       ;UNDO
          beq unhelp
          cmp.b #13,d0        ;return
          beq hlp17
          cmp.b #$3b,d1
          bcs hlp6
          cmp.b #$45,d1
          bcs hlp5a           ;touches de fonction f1-f10
          cmp.b #$54,d1
          bcs hlp6
          cmp.b #$56,d1
          bcc hlp6            ;touches de fonction f11-f12
          sub.b #15,d1
; APPEL D'UN ACCESSOIRE
hlp5a:    sub.b #$3b-4,d1
          clr d0
          move.b d1,d0
          cmp posacc,d0       ;cet accessoire n'est pas charge!
          bcc hlp5
          bsr active
          move #1,accflg
          bra finhelp

hlp6:     cmp.b #$4b,d1       ;gauche?
          beq hlp10
          cmp.b #$4d,d1       ;droite?
          beq hlp11
          cmp.b #$48,d1       ;haut
          beq hlp12
          cmp.b #$50,d1       ;bas
          beq hlp13
          cmp.b #$0e,d1       ;backspace?
          beq hlp16
          cmp.b #32,d0        ;filtre les lettres
          blt hlp5
          cmp.b #127,d0
          bge hlp5
;ecris un chiffre ou lettre
          cmp #5,d3
          beq hlp5
          move.b d0,(a3)+     ;stocke et affiche le caractere
          addq #1,d3
          clr d7
          trap #3
          bra hlp5
;backspace
hlp16:    tst d3
          beq hlp5
          move #3,d0
          clr d7
          trap #3
          move #32,d0
          trap #3
          move #3,d0
          trap #3
          subq #1,d3
          move.b #32,-(a3)
          bra hlp5
;mouvements du curseur dans les chiffres
hlp10:    subq #1,d5          ;Gauche
          bne hlp4
          move #4,d5
          bra hlp4
hlp11:    addq #1,d5          ;Droite
          cmp #5,d5
          bne hlp4
          move #1,d5
          bra hlp4
hlp12:    bsr lignen          ;haut
          subq #1,d4
          bpl hlp3
          move #3,d4
          bra hlp3
hlp13:    bsr lignen          ;bas
          addq #1,d4
          cmp #4,d4
          bne hlp3
          clr d4
          bra hlp3
;undo
unhelp:   bsr lignen          ;retour a la normale
          bra hlp3
;return: prend tous les numeros rentres
hlp17:    move d5,-(sp)
          move #1,d5
hlp18:    bsr pospoint
          move.l a3,a6
          bsr dechexa
          beq.s hlp20
          bpl.s hlp19           ;out of range
          move.b (a6)+,d0
          beq.s hlp20
          cmp.b #"e",d0
          beq.s hlp19
          cmp.b #"E",d0
          beq.s hlp19
          clr d0
          bra.s hlp20
hlp19:    move #$ffff,d0
hlp20:    move d0,2(a4)       ;poke dans la table
          clr.w (a4)
          addq #1,d5
          cmp #5,d5
          bne.s hlp18
;analyse les numeros de ligne et fait que tout aille bien!
          move #1,d5
          bsr pospoint        ;met le pointeur au debut de la table
hlp22:    clr d2              ;verifie bien si le suivant
hlp23:    move 2(a4,d2.w),d0  ;est plus grand que le precedant!
          beq.s hlp24
          cmp #$ffff,d0
          beq.s hlp28           ;il y a un $ffff: on sort
          move d0,4(a4,d2.w)
          cmp 6(a4,d2.w),d0
          bcs.s hlp24
          addq #4,d2
          move #$ffff,2(a4,d2.w)
          bra.s hlp28           ;bourre la suite de zero
hlp24:    addq #4,d2
          cmp #12,d2
          bne.s hlp23
          move 2(a4,d2.w),d0
          cmp #$ffff,d0
          beq.s hlp28
;Il n'y a pas de $ffff
          move #12,d2
hlp25:    tst 2(a4,d2.w)
          bne.s hlp26
          subq #4,d2
          bpl.s hlp25
;Tout est a zero: fenetre par defaut!
          move d4,d2
          lsl #2,d2
          move #$ffff,2(a4,d2.w)
          bra.s hlp30         ;numero de programme--->#fenetre
;Met le $ffff apres le dernier numero!
hlp26:    cmp #12,d2
          beq.s hlp27
          addq #4,d2
hlp27:    move #$ffff,2(a4,d2.w)
          bra.s hlp30
;Il y a un $ffff: met la suite a zero!
hlp28:    cmp #12,d2
          beq.s hlp30
          addq #4,d2
          clr.l 0(a4,d2.w)
          bra hlp28
;sortie de cette MERDE INFAME!
hlp30:    move (sp)+,d5
          bra unhelp

; FIN DU HELP: REAFFICHE L'ECRAN ET EFFECTUE LES CHANGEMENTS
finhelp:  bsr lignen          ;effacement ligne courante
          lea effachelp,a0
          move.w typecran,d0
          subq #1,d0
          bmi.s finhh2
finhh1:   tst.w (a0)+         ;pointe la bonne table
          bpl.s finhh1
          dbra d0,finhh1
finhh2:   moveq #27,d7
          trap #3             ;affiche tout l'ecran
          move.w avanthelp,d0
          moveq #16,d7
          trap #3             ;active rapidement la fenetre d'avant HELP
; LANCE L'ACCESSOIRE
          tst accflg
          beq.s finh1
          move d4,reactive
          bsr propre
          move.l dsource,a5
          move #1,runflg
          lea pile,sp
          bra lignesvt
; RETOUR D'UN ACCESSOIRE
retacc:   move #9,d7          ;efface toutes les autres fenetres
          move #8,d6
retacc1:  move d6,d0
          trap #3
          addq #1,d6
          cmp #14,d6
          bcs.s retacc1
          move reactive,d4
; fin normale du help
finh1:    move d4,d0
          bsr active          ;active le programme
edit0:    move typecran,d1
          beq boucle          ;fenetre zero: on change rien
;edition multiple peut on garder la meme fenetre?
edit1:    move fenetre,d0
          bsr fenconv
          lea reparti,a0
          subq #1,d0
          lsl #2,d0
          add d0,a0
          move program,d0
          lsl #4,d0
          add d0,a0
          tst.l (a0)
          bne boucle          ;oui!
;on ne peut pas garder la meme fenetre: peut on garder le meme ecran?
edit2:    move d4,d0
          bsr prgmode
          beq.s edit4
;changement rapide de fenetre dans cet ecran!
          bsr chge4
          bra boucle
;retour au full screen
edit4:    clr d0              ;pas besoin de reafficher!
          clr d1
          bsr chgecran
          bra boucle

; WINDCOPY
windcopy: move #12,d7
          trap #3
          tst d0
          bne prtnotr
          rts

; HARDCOPY
hardcopy: move.w #20,-(sp)
          trap #14
          addq.l #2,sp
          rts

; TROUVE LA PHRASE DANS LA LANGUE CHOISIE (EN A0)
traduit:  tst langue
          beq.s trad2
trad1:    tst.b (a0)+
          bne.s trad1
trad2:    rts

; ENGLISH
english:  clr langue
          rts

; FRANCAIS
francais: move #1,langue
          rts

;-----------------------------------------    --- ----- ---   ---    -------
;    ----------------------------------      |      |  |   | |
;   |  PREPARATION DU PGM,  ET CHRGET  |      ---   |  |   |  ---
;    ----------------------------------          |  |  |   |     |
;-----------------------------------------    ---       ---   ---    -------
; EFFACEMENT DES VARIABLES ET DES BOUCLE ET DES GOSUBS ET DES ERREURS
clearvar: bsr cleanbank                 ;nettoyage des banques
          bsr calclong
; raz des 26 extensions
          move.l adext,a0
          moveq #25,d0
cv:       tst.l (a0)
          beq.s cv0
          move.l (a0),a1
          movem.l a0/d0,-(sp)
          jsr (a1)
          movem.l (sp)+,a0/d0
cv0:      addq.l #4,a0
          dbra d0,cv
; raz des flag/vecteurs...
          clr accflg                    ;pas un accessoire!
          move.l himem,lowvar           ;RAZ des variables
          move.l fsource,a0
          clr.w (a0)+                   ;cree la chaine vide!
          move.l a0,hichaine
          move #1,actualise
          move #1,autoback
          move #-1,fixflg
          clr expflg
; entree pour GOTO direct
cvbis:    clr.l unewhi                  ;empeche un UNNEW
          move.l #bufbcle,posbcle       ;RAZ des boucles
          move.l #bufbcle,tstbcle
          clr nboucle
          clr tstnbcle
          move.l #bufgsb,posgsb         ;RAZ des gosubs
          clr.l datastart               ;RAZ des datas
          clr.l dataline
          clr.l datad
          clr.l onerrline               ;RAZ des erreurs!
          clr.l errorline
          clr.w errornb
          clr.w erroron
          clr contflg                   ;RAZ du cont
          clr.l contchr
          clr.l contline
          clr.l printpos                ;PRINT normal
          clr printype
          clr.l printfile
          clr sortflg
          clr brkinhib                  ;autorise le break
          clr mnd+14
          clr mnd+98
          lea mnd+100,a0
          moveq #9,d0
cv1:      clr.l (a0)+                   ;plus de ON MNBAR GOTO
          dbra d0,cv1
          bsr menuoff
          clr undoflg
          rts

; CLEAR: EFFACEMENT DES VARIABLES, DES BOUCLES, DES GOSUBS...
clear:    bsr clearvar
          bsr propre
          rts

; MOVE VAR: CHANGEMENT D'ADRESSE DES VARIABLES
movevar:  move #1,d3          ;nettoyage des variables uniquement
          bra o0
; NETTOYAGE DU PROGRAMME, ET PREPARATION DES PARAMETRES
propre:   clr d3
o0:       move.l dsource,a0
o1:       move (a0),d1
          beq o9
          move #4,d0
o2:       move.b 0(a0,d0.w),d2
          bpl o8
          cmp.b #$a0,d2       ;instruction etendue?
          beq.s ob
          cmp.b #$b8,d2       ;fonction etendue?
          beq.w o7
          cmp.b #$a8,d2       ;.EXT instruction
          beq.w o6a
          cmp.b #$c0,d2       ;.EXT fonction
          beq.s o6a
          cmp.b #$fa,d2       ;vaoiable ou nomboe
          bcc.s o3
          cmp.b #$a0,d2       ;boanchement?
          bcc.s o8
          cmp.b #$98,d2
          bcs.s o8
o3:       btst #0,d0          ;oend paio
          bne.s o4
          addq #1,d0
o4:       cmp.b #$ff,d2       ;constantes FLOAT sur huit octets
          beq.s o5f
          cmp.b #$fc,d2       ;variables alphanumeriques
          bne.s o3a
          add.w 3(a0,d0.w),d0   ;saute la chaine
o3a:      cmp.b #$fa,d2
          bhi.s o6              ;autoes constantes
          bne.s o4a
; nettoyage d'une vaoiable: laisse la longueuo!
oa:       and.l #$ff000000,1(a0,d0.w)
          bra.s o6
; code d'extension: est-ce un DATA???
ob:       cmp.b #$a6,1(a0,d0.w)
          bne.s o7
          tst.l dataline
          bne.s o7
          cmp.b #4,d0                 ;DATA doit etoe le premier sur la ligne!
          bne.s o7
          move.l a0,datastart         ;adresse du premier DATA
          move.l a0,dataline          ;ligne du premier DATA
          move.l a0,a1
          add d0,a1
          addq.l #2,a1
          move.l a1,datad             ;pointeur sur le premier element
          bra.s o7
; nettoyage d'un branchement (si d3=0)
o4a:      tst d3
          bne.s o6
o5:       clr.l 1(a0,d0.w)
          bra.s o6
; token suivant
o5f:      addq #4,d0          ;pour les float (8 octets)
o6:       addq #2,d0
o6a:      addq #1,d0          ;.EXT
o7:       addq #1,d0
o8:       addq #1,d0
          cmp d1,d0           ;caractere suivant?
          bcs o2
          add (a0),a0         ;ligne suivante.
          bra o1
o9:       clr autoflg
          rts

; RUN / RUN xx / RUN "dklskdl.bas"
run:      bsr finie                     ;run tout seul
          beq.s run3
          move.l a6,-(sp)
          bsr evalue
          move.l (sp)+,a6               ;remet le chrget!
          tst.b d2                      ;run # de ligne
          beq.s run2
          bpl.s run1
; run NOM$
          bsr setdta                    ;E/S disque
          bsr namedisk                  ;va chercher le nom
          bne.s run0
          lea bas,a0                    ;met l'extension
          bsr transtext
run0:     bsr load3                     ;va faire NEW, va charger le pgm
          bra.s run3
; run numero
run1:     bsr fltoint                   ;run FLOAT!
run2:     bsr findrun
          bra.s run4
run3:     move.l dsource,a0
run4:     move.l a0,-(sp)
          bsr clause                    ;ferme tous les fichiers
          bsr clearvar                  ;nettoie les variables
          bsr ains                  ;Plus d'insertion
          bsr propre                    ;nettoie prg, raz variables
          move.l (sp)+,a5
          move #1,runflg
          lea pile,a7
          tst.w (a5)                    ;BUG !!!
          bne lignesvt

; END
end:      tst runflg
          beq illdir
          bra direct

; CHRGET: avec branchements aux routines concernees
finligne: tst runflg          ;mode direct ou programme?
          beq.s direct
          add (a5),a5
          tst (a5)
          beq.s direct
lignesvt: move.l a5,a6
          addq.l #4,a6
chrget:   move.b (a6)+,d0
          beq.s finligne
          bmi.s chr1
          cmp.b #":",d0
          beq.s chrget
chr0:     move.l a6,a4
          bra syntax
chr1:     and #$007f,d0
          lsl #2,d0
          lea jumps,a0
          move.l 0(a0,d0.w),a0
          tst.b interflg      ;le bit 7 d'interflg, est mis … chaque 
          bpl.s chr2          ;interruption d'‚cran!
          bsr entrint         ;test break/interruption...
chr2:     tst folflg
          bne folprg          ;branche au follow si en route
chr3:     move.l a6,a4        ;position avant l'appel de la fonction
          jsr (a0)
          move.b (a6)+,d0     ;refait le CHRGET, pour ‚conomiser
          beq.s finligne      ;un branchement!
          bmi.s chr1
          cmp.b #":",d0
          beq.s chrget
          bra.s chr0
direct:   clr runflg
	bsr zofonc	;Remet les zones pour clickage
          bra ok              ;fin du programme

; ENTREE DES INSTRUCTIONS ETENDUES (EN $A0)
etendu:   move.b (a6)+,d0
          cmp.b #32,d0
          bcs.s eten2
; routines simples
eten1:    sub #$70,d0
          lsl #2,d0
          lea extjumps,a0
          move.l 0(a0,d0.w),a0
          jmp (a0)
; routines directes
eten2:    and #$7f,d0
          clr autoflg
          cmp #$20,d0
          bcc syntax
          tst runflg
          bne illegal
          lsl #2,d0
          lea dirjumps,a0
          move.l 0(a0,d0.w),a0
          jmp (a0)
illegal:  move #15,d0
          bra erreur

; ENTREE DES FONCTIONS ETENDUES (EN $B8)
fetendu:  clr d0
          move.b (a6)+,d0
          sub.b #$80,d0
          bcs syntax
          lsl #2,d0
          lea extfonc,a0
          move.l 0(a0,d0.w),a0
          jmp (a0)

; ENTREE DES .EXT instructions
extinst:  move.l a6,extchr    ;sauve le chrget
          move.l sp,trahpile  ;sauve la pile
          addq.l #2,a6        ;saute les params
          clr d0              ;empile les parametres
          move.b (a6),d1
          beq ef4
          cmp.b #":",d1
          beq ef4
ei1:      move d0,-(sp)
          bsr evalue
          tst parenth
          bne syntax
          move (sp)+,d0
          movem.l d2-d4,-(sp)
          addq #1,d0
          move.b (a6),d1
          beq.s ef4
          cmp.b #":",d1
          beq.s ef4
          cmp.b #",",d1
          bne syntax
          addq.l #1,a6
          bra.s ei1

; ENTREE DES .EXT functions
extfunc:  move.l a6,extchr
          move.l sp,trahpile  ;sauve la pile
          addq.l #2,a6
          clr d0
          cmp.b #"(",(a6)
          bne.s ef4
          addq.l #1,a6
ef1:      move d0,-(sp)
          move parenth,-(sp)
          clr parenth
          bsr evalbis
          move parenth,d1
          move (sp)+,parenth
          move (sp)+,d0
          movem.l d2-d4,-(sp)
          addq #1,d0
          cmp #-1,d1
          beq.s ef4
          tst d1
          bne syntax
          cmp.b #",",(a6)
          bne syntax
          addq.l #1,a6
          bra.s ef1

; appel de la .EXT fonction/instruction
ef4:      move.l extchr,a0
          move.l adext,a1
          clr d1
          move.b (a0)+,d1
          lsl #2,d1
          tst.l 0(a1,d1.w)
          beq ef5             ;extension not present!
          lsl #1,d1
          lea datext,a1
          move.l 4(a1,d1.w),a1  ;adresse de la table des jumps
          move.b (a0)+,d1
          and.w #$7f,d1
          cmp.w (a1)+,d1      ;securite!
          bhi ef5
          lsl #2,d1
          move.l 0(a1,d1.w),a1  ;adresse de la routine
          jsr (a1)            ;appel, d0= nombre de parametres
          move.l trahpile,sp  ;restore la pile!
          rts
; erreur #84: extension non chargee!
ef5:      moveq #84,d0
          bra erreur

; FOLLOW A,B,D$;10-2000
follow:   bsr onoff
          bmi fol1
          bne syntax
; arret du follow: FOLLOW OFF
          clr folflg
          rts
; mise en route du follow
fol1:     lea fb,a0
fol2:     move.b (a6),d0
          beq fol5
          cmp.b #$fa,d0
          bne fol5
          addq.l #1,a6
          move.b d0,(a0)+
          move a6,d0                    ;rend pair dans le buftok
          btst #0,d0
          beq.s fol3
          addq.l #1,a6
fol3:     move a0,d0                    ;rend le folbuf pair
          btst #0,d0
          beq.s fol3a
          addq.l #1,a0
fol3a:    move.b (a6)+,d0
          btst #5,d0                    ;pas de tableaux!
          bne syntax
          move.b d0,(a0)+
          move.b (a6)+,(a0)+            ;poke le FLAG
          move.b (a6)+,(a0)+
          move.b (a6)+,(a0)+
          and #$1f,d0
          subq #1,d0
fol4:     move.b (a6)+,(a0)+            ;poke le nom
          cmp.l #maxfb,a0
          bcc foltolong
          dbra d0,fol4
          move.b #";",(a0)+             ;met le ";" entre chaque variable
          move.b (a6),d0
          beq.s fol5
          addq.l #1,a6
          cmp.b #",",d0
          beq.s fol2
          bra syntax
; prend la fin des parametres
fol5:     clr.b (a0)
          bsr params
          move.w d4,foldeb              ;premiere ligne a suivre
          move.w d5,folend              ;derniere ligne a suivre
          move #1,folflg                ;autorise le test du FOLLOW
          rts
foltolong:moveq #9,d0
          bra erreur

; AFFICHAGE DES VARIABLES AU COURS DU PROGRAMME
folprg:   tst runflg
          beq chr3
          tst accflg
          bne chr3
          move.w 2(a5),d7               ;numero de ligne
          cmp.w foldeb,d7
          bcs chr3
          cmp.w folend,d7               ;entre les limites!
          bhi chr3
; ok! affiche tout!
          movem.l d0-d6/a0-a6,-(sp)
          moveq #17,d7
          trap #3
          move.l d0,-(sp)               ;sauve les coordonnes du curseur!
          lea fl,a0
          bsr traduit
          moveq #1,d7
          trap #3                       ;affiche LINE
          clr.l d0
          move.w 2(a5),d0               ;numero de ligne
          lea buffer,a5
          bsr longdec
          clr.b (a5)
          lea buffer,a0
          moveq #1,d7
          trap #3
          lea fl1,a0                ;" : "
          trap #3
; explore les variables et les affiche
          lea fb,a6
          tst.b (a6)
          beq folp5
folp1:    move.l a6,a1                  ;pointe le flag de la variable
          addq.l #1,a1
          move a1,d0
          btst #0,d0
          beq.s folp2
          addq.l #1,a1
folp2:    move.b (a1),d0
          move.l a1,-(sp)
          addq.l #4,a1
          and #$1f,d0
          lea buffer,a0
          subq #1,d0
folp3:    move.b (a1)+,(a0)+
          dbra d0,folp3
          clr.b (a0)
          moveq #1,d7                   ;affiche le nom de la variable
          lea buffer,a0
          trap #3
          lea fl2,a0
          trap #3                       ;egal
          clr printflg
          bsr ssprint                   ;converti la variable---> buffer
          clr printflg
          bsr finprint                  ;print: retour normal!
          lea buffer,a0
          moveq #1,d7
          trap #3                       ;affiche le contenu
          move.l (sp)+,a0
          and.l #$ff000000,(a0)         ;efface le flag de la variable!!!
          tst.b (a6)                    ;le point virgule est pris par PRINT
          beq.s folp5
          lea fl3,a0                ;", "
          moveq #1,d7
          trap #3
          bra folp1
; SORTIE NORMALE: remet a6 et le curseur
folp5:    lea fl4,a0
          moveq #1,d7
          trap #3
          move.l (sp)+,d0
          move d0,d1                    ;Y en d1
          swap d0                       ;X en d0
          moveq #2,d7
          trap #3                       ;locate!
folp6:    bsr avantint
          bsr incle
          tst.l d0
          beq.s folp6
          movem.l (sp)+,d0-d6/a0-a6
          bra chr3

;-----------------------------------------    --- ----- ---   ---    -------
;    ----------------------------------      |      |  |   | |
;   |      VARIABLES ET EXPRESSION     |      ---   |  |   |  ---
;    ----------------------------------          |  |  |   |     |
;-----------------------------------------    ---       ---   ---    -------

; TROUVE UNE VARIABLE:        -la CREEE si elle n'existe pas
;                             -ramene son ADRESSE en A1
;                             -retour en d2/d3/d4
fdavant:  addq.l #1,a6
findvar:  move a6,d0          ;rend l'adresse paire
          btst #0,d0
          beq fv0
          addq.l #1,a6
fv0:      move.b (a6),d3      ;prend le FLAG de la variable
          move.l (a6)+,d0     ;prend l'adresse
          and.l #$ffffff,d0
          bne fv20         ;si l'adresse est nulle: pas encore passe!
; cherche la variable dans la table
          move.l lowvar,a1    ;debut des variables
          move.l a1,d2
          move.l himem,d4     ;fin des variables
          clr.l d0
          clr.l d1
fv1:      cmp.l d4,a1
          bcc fv10
          move.b (a1)+,d1     ;trouve le debut de la variable
          bne.s fv1a
          move.b (a1)+,d1     ;FLAG de la variable exploree
          addq.l #1,d2
fv1a:     cmp.b d3,d1         ;pas cette variable!
          bne.s fv5
          move.l a6,a0        ;debut du nom de la variable
          move d1,d0
          and #$001f,d0
          subq #1,d0          ;taille du nom explore
fv2:      cmpm.b (a0)+,(a1)+
          bne.s fv5
          dbra d0,fv2
          move.l a1,d0
          bra fv19
; essaie la variable suivante
fv5:      clr.l d0
          move d1,d0
          and #$1f,d0
          addq.l #1,d2        ;saute le flag
          add.l d0,d2         ;saute les lettres
          btst #5,d1          ;est-ce un tableau?
          beq.s fv6
          move.l d2,a1        ;pointe la taille du tableau
          move.l (a1)+,d0     ;taille du tableau
          bra.s fv8
fv6:      moveq #4,d0         ;pas un tableau
          btst #6,d1
          beq.s fv8
          addq.l #4,d0        ;float, sur 8 octets
fv8:      add.l d0,d2         ;trouve l'adresse de la variable suivante
          move.l d2,a1
          bra fv1
; LA VARIABLE N'EXISTAIT PAS: ON VA LA CREER!
fv10:     btst #5,d3          ;est-ce un tableau???
          bne entdim
          move.l lowvar,d0
          sub.l #64,d0        ;securite de 64 octets
          cmp.l hichaine,d0
          bcc.s fv11
          bsr menage          ;nettoyage des chaines--->place!
fv11:     move.l lowvar,a1
          move.b d3,d0
          and.b #$c0,d0
          beq.s fv14
          bpl.s fv13
          move.l fsource,-(a1) 	;si alphanumerique: chaine vide!
          bra.s fv15
fv13:  	movem.l d3/d4,-(sp)	 	;Va demander le ZERO
	movem.l a0/a1,-(sp)
	move.w #$ff05,d0
	trap #6
	movem.l (sp)+,a0/a1
	move.l d4,-(a1)
	move.l d3,-(a1)
	movem.l (sp)+,d3/d4
	bra.s fv15
fv14:     clr.l -(a1)
fv15:     move.l a1,d0        ;adresse de la variable a mettre dans le listing!
          move d3,d1
          and #$001f,d1
          move.l a6,a0
          add d1,a0           ;adresse de la fin du nom de la variable
          subq #1,d1
fv16:     move.b -(a0),-(a1)  ;pokage du nom de la variable
          dbra d1,fv16
          move.b d3,-(a1)     ;pokage du flag
          move a1,d1          ;LOWVAR doit etre toujours pair
          btst #0,d1
          beq.s fv17
          clr.b -(a1)         ;laisse un blanc! IMPERATIF!
fv17:     move.l a1,lowvar    ;baisse le bas des variables
; LA VARIABLE EST TROUVEE! REMPLIS LE LISTING
fv19:     or.l d0,-4(a6)
; LA VARIABLE EXISTE DANS LE LISTING et DANS LA MEMOIRE
fv20:     move.l d0,a1        ;recupere l'adresse
fv21:     move d3,gotovar     ;met le flag GOTO VARIABLE a un!
          move d3,d2
          and #$001f,d3
          add d3,a6           ;saute le nom de la variable! GENIAL!
          btst #5,d2          ;est-ce un tableau?
          bne.s tableau
; PREND LE CONTENU DE CES VARIABLES, au retour A1 contient l'adresse
prendvar: and.b #$c0,d2
          beq.s fv22         ;dans la table des variables
          bmi.s fv23
          move.l (a1),d3      ;FLOAT: d2=flag, d3/d4=variable
          move.l 4(a1),d4
          rts
fv22:     move.l (a1),d3      ;VARIABLE ENTIERE: d2=flag, d3=contenu
          rts
fv23:     move.l (a1),d3      ;CHAINE: d2=flag, d3=adresse de la chaine
          rts
; CHERCHE LA VALEUR D'UNE VARIABLE DANS UN TABLEAU
tableau:  tst sortflg         ;si SORT ou FIND: revient sans rien faire
          beq.s tabl0
          rts
tabl0:    move parenth,-(sp)
          move d2,-(sp)       ;sauve le flag
          clr.l -(sp)         ;calcul de la position
          addq.l #4,a1        ;saute la taille du tableau
          move (a1)+,-(sp)    ;nombre de dimensions a trouver
          clr -(sp)           ;nombre de dimensions trouvees
          move.l a1,-(sp)
          addq.l #1,a6        ;pointe l'interieur de la parenthese
; PREND TOUTES LES DIMENSIONS L'UNE APRES L'AUTRE
          clr parenth
tabl1:    bsr evalbis
          tst.b d2
          bmi typemis
          beq.s tabl2
          bsr fltoint         ;conversion FLOAT--->ENTIER
tabl2:    add #1,4(sp)        ;un dimension en plus
          move 4(sp),d2
          move 6(sp),d4
          cmp d4,d2
          bhi foncall         ;trop de dimensions!
          move.l (sp),a1
          cmp (a1)+,d3        ;trop grand!
          bhi subsout
; SITUE DANS LE TABLEAU
tabl3:    cmp d4,d2
          bcc.s tabl4
          clr.l d6
          move (a1)+,d6
          addq.l #1,d6        ;taille de la dimension a trouver
          mulu d6,d3
          addq #1,d2
          bra.s tabl3
tabl4:    add.l d3,8(sp)      ;additionne aux calcul
          add.l #2,(sp)       ;pointe la taille dimension suivante
          tst parenth
          bne.s tabl5
          move.b (a6),d0
          cmp.b #",",d0
          bne syntax
          addq.l #1,a6        ;encore une dimension!
          bra tabl1
tabl5:    cmp #-1,parenth
          bne syntax
; DEPILE TOUT ET POINTE LA VARIABLE!
          move.l (sp)+,a1     ;pointe la premiere variable
          move (sp)+,d2
          move (sp)+,d4
          cmp d2,d4           ;pas le meme nombre de dimensions!
          bne syntax
          move.l (sp)+,d3     ;nombre de variable a sauter
          move (sp)+,d2       ;flag de la variable
          lsl.l #2,d3	;*4
          btst #6,d2          ;trouve la taille de la variable
          beq.s tabl6
          lsl.l #1,d3	;si FLOAT: *8
tabl6:    add.l d3,a1         ;CA Y EST: a1 pointe la variable
          move (sp)+,parenth
          bra prendvar        ;va chercher la variable!

; DIM
dim:      move.b (a6),d0
          cmp.b #$fa,d0
          bne syntax
          bsr fdavant         ;va voir la variable apres! Si revient,
retdim:   move #28,d0         ;c'est qu'elle est deja dimensionnee!
          bra erreur

; NONDIM: VERITABLE ENTREE DE DIM!!!
entdim:   clr sortflg
          cmp.l #retdim,(sp)  ;vient de DIM???
          addq.l #4,sp
          bne nondim          ;NON: erreur!
; DIMENSIONAGE DE VARIABLE
dimin:    clr nbdim           ;nombre de dimensions
          move.l a6,-(sp)     ;sauve le chrget (premiere lettre du nom)
          move d3,-(sp)       ;sauve le flag pour plus tard
          move d3,d0
          and #$1f,d0
          add d0,a6
          addq.l #1,a6        ;pointe l'interieur de la parenthese
dim1:     bsr evalue
          tst.b d2
          bmi typemis
          beq.s dim2
          bsr fltoint         ;conversion float--->entier
dim2:     tst.l d3
          beq foncall         ;pas de dimension ZERO!
          cmp.l #$ffff,d3
          bcc foncall         ;pas de dimension > 65534!
          add #1,nbdim        ;une dimension de plus
          move.l d3,-(sp)     ;empile les dimensions
          tst parenth
          bne.s dim3
          move.b (a6),d0
          cmp.b #",",d0       ;une virgule entre chaque dimension
          bne syntax
          addq.l #1,a6        ;encore une dimension!
          bra.s dim1
dim3:     cmp #-1,parenth
          bne syntax
; TOUTES LES DIMENSIONS ONT ETE VUES ET STOCKEES
          tst nbdim
          beq syntax
; CALCUL DE LA TAILLE TOTALE DU TABLEAU
          move.l #1,d3
          lea defloat,a0
          move nbdim,d7
          subq #1,d7
dim4:     move.l (sp)+,d6
          move.l d6,(a0)+     ;stocke dans le buffer pour inverser apres
          addq.l #1,d6        ;element zero
	mulu d6,d3
          dbra d7,dim4
          move.l d3,d2        ;d2= nombre d'elements
          move (sp)+,d4       ;d4= flag de la variable
          lsl.l #2,d3
          btst #6,d4
          beq.s dim4a
          lsl.l #1,d3
dim4a:    move.l lowvar,d0
          sub.l d3,d0
          bcs outofmm
          sub.l #255,d0       ;de securite
          bcs outofmm
          cmp.l hichaine,d0
          bcc.s dim5
          bsr menage
; Y A LA PLACE: cree le tableau dans la memoire!
dim5:     lsr.l #2,d3         ;travaille par mot longs
          move.l lowvar,a1
          move.l a1,a2        ;fin du tableau
          moveq #0,d0
	move.b d4,d1
	and.b #$c0,d1
          beq.s dim6a          ;initialise les chaines sur chaine vide!
	bmi.s dim6
; Init tableau FLOAT ---> demande le vrai ZERO
	movem.l a0-a1/d3-d4,-(sp)
	move.w #$ff05,d0
	trap #6
	move.l d3,d0
	move.l d4,d1
	movem.l (sp)+,a0-a1/d3-d4
	lsr.l #1,d3
dim5a:	move.l d1,-(a1)
	move.l d0,-(a1)
	subq.l #1,d3
	bne.s dim5a
	bra.s dim6b
; RAZ tableau INT /CHAINE
dim6:     move.l fsource,d0
dim6a:    move.l d0,-(a1)     ;nettoie la memoire!
          subq.l #1,d3
          bne.s dim6a

dim6b:    move nbdim,d0
          subq #1,d0
          lea defloat,a0
dim7:     move.l (a0)+,d1     ;poke les dimensions a l'envers donc a l'endroit!
          move d1,-(a1)
          dbra d0,dim7
          move nbdim,-(a1)    ;poke le nombre de dimensions
          subq.l #4,a1
          sub.l a1,a2
          move.l a2,(a1)      ;poke la taille totale du tableau
          move.l (sp)+,a0     ;pointe la premiere lettre du nom
          move d4,d0
          and #$1f,d0
          add d0,a0           ;pointe la fin du nom de la variable
          subq #1,d0
dim8:     move.b -(a0),-(a1)  ;poke le nom de la variable
          dbra d0,dim8
          move.b d4,-(a1)     ;poke le flag
          move a1,d0          ;LOWVAR doit etre toujours pair
          btst #0,d0
          beq.s dim9
          clr.b -(a1)         ;laisse un blanc! IMPERATIF!
dim9:     move.l a1,lowvar    ;baisse le bas des variables
; REGARDE S'IL Y A UNE AUTRE VARIABLE DANS LE DIM
          move.b (a6),d0
          cmp.b #",",d0
          bne findim
          addq.l #1,a6
          move.b (a6),d0
          cmp.b #$fa,d0
          beq dim             ;effectue un nouveau DIM
          bra syntax
findim:   rts

; VARPTR (A)
varptr:   cmp.b #"(",(a6)+
          bne syntax
          cmp.b #$fa,(a6)+    ;veut une variable
          bne syntax
          bsr findvar         ;va chercher la variable
          cmp.b #")",(a6)+
          bne syntax
          tst.b d2
          bmi.s vptr
          move.l a1,d3
          clr.b d2
          rts
vptr:     addq.l #2,d3        ;variable chaine: pointe le debut!
          clr.b d2
          rts

; RAMENE UNE CONSTANTE ENTIERE DANS D2-D3-D4
entier:   move a6,d0
          btst #0,d0
          beq.s ent1
          addq.l #1,a6
ent1:     move.l (a6)+,d3
          clr.b d2
          rts

; RAMENE UNE CONSTANTE FLOAT DANS D2-D3-D4
float:    move a6,d0
          btst #0,d0
          beq.s flt1
          addq.l #1,a6
flt1:     move.l (a6)+,d3
          move.l (a6)+,d4
          move #$40,d2
          rts

; RAMENE UNE CONSTANTE ALPHANUMERIQUE EN D2-D3
alpha:    move a6,d0
          btst #0,d0
          beq.s alph1
          addq.l #1,a6
alph1:    addq.l #2,a6
          tst runflg
          bne.s alph5
; en mode direct, on ne peut pas pointer le source! idiot!
          move.l a6,a2
          clr.l d3
          move.w (a2)+,d3
          bsr demande
          move.w d3,(a0)+
          beq.s alph3
          addq #1,d3
          lsr #1,d3
          subq #1,d3
alph2:    move.w (a2)+,(a0)+
          dbra d3,alph2
alph3:    move.l a0,hichaine
          move.l a1,d3
          bra.s alph6
; mode programme: pointe dans le source: SUPER RAPIDE!
alph5:    move.l a6,d3
          tst (a6)
          bne.s alph6
          move.l fsource,d3   ;si chaine vide: prend la variable nulle!
alph6:    add (a6)+,a6        ;saute la chaine!
          move.b #$80,d2      ;code des chaines
          rts

; CHERCHE UN OPERANDE, ET LE RAMENE DANS D2-D3-D4
operande: clr -(sp)               ;par defaut: pas de signe devant
ope0:     move.b (a6)+,d0
          beq syntax
          bpl.s ope3
          cmp.b #$f5,d0           ;signe moins devant?
          beq.s ope2
          lea opejumps,a0
          and #$00ff,d0
          sub #debfonc,d0         ;branchement a la routine:
          bcs syntax              ;pas une fonction!
          lsl #2,d0               ;ramene le resultat en d2-d3-d4
          move.l 0(a0,d0.w),a0
          jsr (a0)
;changement de signe de l'operande?
ope1:     move (sp)+,d0           ;ressort le signe
          beq.s chs2              ;pas de changement
          tst.b d2
          beq.s chs1
          bmi syntax
	move.w #$ff00,d0	  ;Change le signe sur D3!
	trap #6
          rts
chs1:     neg.l d3                ;changement entier
chs2:     rts
;signe moins devant
ope2:     tst (sp)                ;pas DEUX signes moins!
          bne syntax
          move #1,(sp)
          bra ope0
;parenthese?
ope3:     cmp.b #"(",d0
          bne syntax
          add #1,parenth
          bsr evalbis         ;appel recursif de l'evaluation
          bra ope1

; EVALUATION D'UNE EXPRESSION: PREMIERE ENTREE
evalue:   lea bufcalc,a3      ;pour le moment, le buffer entree/sortie
          clr parenth
; EVALUATION D'UNE EXPRESSION: ENTREE RECURSIVE
evalbis:  move #debop,d0      ;operateur de poids faible et signal de fin
          bra.s eval1
eval0:    movem.l d2-d4,-(a3)
eval1:    move d0,-(a3)
          bsr operande        ;ramene operande en d2-d3-d4
eval2:    move.b (a6)+,d0     ;cherche operateur suivant
          and #$00ff,d0
          cmp (a3),d0         ;compare au precedent
          bhi.s eval0           ;poids plus fort: il a priorite: on boucle!

          subq.l #1,a6        ;reste sur le meme pointeur!
          move.w (a3)+,d1     ;depile l'operateur
          sub #debop,d1
          beq.s evalfin         ;c'est fini!
          lsl #2,d1
          lea evajumps,a0
          move.l 0(a0,d1.w),a0
          movem.l (a3)+,d5-d7 ;depile le premier operande
          jsr (a0)            ;effectue l'operateur
          bra.s eval2           ;operateur suivant!

evalfin:  cmp.b #")",d0       ;fermeture  d'une parenthese?
          bne.s eval3
          sub #1,parenth
          move.b (a6)+,d0
eval3:    rts

; TRANSFORME LES DEUX OPERANDES EN ENTIER
quentier: tst.b d2
          bmi typemis
          beq.s quent1
          bsr fltoint         ;converti d2/d3/d4 en entier
quent1:   tst.b d5
          bmi typemis
	beq.s quent2
	movem.l d2/d3/d4,-(sp)
	moveq #$d,d0	;FLTOINT
	move.l d6,d1
	move.l d7,d2
	trap #6
	move.l d0,d6
	clr.b d5
	movem.l (sp)+,d2/d3/d4
quent2:   rts

; TRANSFORME LES DEUX OPERANDES EN FLOAT
quefloat: tst.b d2
          bmi typemis
          bne.s compat
          tst.b d5
          bmi typemis
          bne.s compat
          bsr inttofl         ;transforme d2/d3/d4 en float
; COMPATIBILITE ENTRE DEUX VARIABLES:
compat:   cmp.b d2,d5         ;si UN des deux en float: les deux floats!
          bne.s cpt1
          tst.b d2
          rts
cpt1:     tst.b d5
          bmi typemis
          tst.b d2
          bmi typemis
          bne.s cpt2       
cpt0:     move.l d3,d1
          move #$e,d0
          trap #6             ;INTTOFL
          move.l d0,d3
          move.l d1,d4
          move.b #$40,d2
          rts
cpt2:     movem.l d2-d4,-(sp)
          move.l d6,d1
          move #$e,d0
          trap #6             ;INTTOFL
          move.l d0,d6
          move.l d1,d7
          movem.l (sp)+,d2-d4
          move.b #$40,d5
          rts

; OPENTIER: ramene un operande ENTIER en d2/d3/d4
opentier: clr parenth
          lea bufcalc,a3
          bsr operande
          bra opent1
; EXPENTIER: ramene le resultat d'une expression en entier en d2/d3/d4
expentier:bsr evalue
opent1:   tst parenth
          bne syntax
          tst.b d2
          bmi typemis         ;pas de chaine!
          beq.s opent2
          bra fltoint         ;conversion float--->entier
opent2:   rts
; ALPHENTIER: ramene le resultat d'une expression alphanumerique en d3/d2/a2
expalpha: bsr evalue
          bra alphater

; ENTREES RECURSIVE POUR UN TYPE DE VARIABLE
; ALPHABIS: ramene le resultat d'une expression alphanumerique
alphabis: bsr evalbis 
alphater: tst parenth
          bne syntax
alphaq:   tst.b d2
          bpl typemis
          move.l d3,a2        ;en a2: adresse de la chaine + 2
          clr.l d2
          move (a2)+,d2       ;en d2: longueur de la chaine
          rts

; ENTIERBIS
entierbis:bsr evalbis
          tst parenth
          bne syntax
          tst.b d2
          bmi typemis
          beq opent2
; CONVERSION FLOAT->ENTIER SUR D2/D3/D4
fltoint:  move.l a1,-(sp)
          move.l d3,d1
          move.l d4,d2
          move #$d,d0         ;FLTOINT
          trap #6
          move.l d0,d3
          move.l (sp)+,a1
          clr.b d2
          rts

; FLOATBIS
floatbis: bsr evalbis
          tst parenth
          bne syntax
          tst.b d2
          bmi typemis
          bne opent2
; CONVERSION ENTIER->FLOAT SUR D2/D3/D4
inttofl:  move.l a1,-(sp)
          move.l d3,d1
          move #$e,d0         ;INTTOFL
          trap #6
          move.l d0,d3
          move.l d1,d4
          move.l (sp)+,a1
          move.b #$40,d2
          rts

; DEF FN
def:      cmp.b #$c9,(a6)+    ;cherche un FN
          beq.s def1
          cmp.b #$a0,-1(a6)   ;Cherche un DefScroll
          bne syntax
          cmp.b #$f9,(a6)+
          beq defsc 
          bne syntax    
def1:     tst runflg
          beq illdir
          cmp.b #$fa,(a6)+    ;veut un nom de variable
          bne syntax
          bsr findvar         ;va chercher la variable
          tst.b d2
          bne syntax          ;verification inutile mais securisante!
          move.l a6,(a1)      ;adresse de la fonction dans le listing
          move.l a6,a0
          move.b #":",d0      ;fin de l'instruction
          move.b #$9b,d1      ;ou ELSE
          bsr ftoken          ;va chercher la fin de l'instruction
          move.l a0,a6
          rts

; FN xxxxxxx (yy,zz): ultra puissant!!!
fn:       cmp.b #$fa,(a6)+
          bne syntax
          bsr findvar         ;va chercher le variable FN
          tst.l d3
          beq usnotdef        ;user function not defined!!!
          move.l d3,a2        ;pointe la parenthese de la definition
          move parenth,-(sp)
          move.b (a2)+,d0
          cmp.b #"(",d0       ;ouvre une parenthese?
          bne.s fn0
          cmp.b #"(",(a6)+    ;de part et d'autre?
          beq.s fn1
          bne usfoncall
fn0:      cmp.b #$f1,d0       ;il faut un egal!
          bne syntax
          cmp.b #"(",(a6)
          beq usfoncall
          bra fn4
; egalisation de tous les parametres de l'appel
fn1:      exg a2,a6           ;pointe la fonction definie
fn2:      move.l a2,-(sp)
          cmp.b #$fa,(a6)+
          bne syntax          ;veut une variable!!!
          bsr findvar         ;va chercher cette variable
          move.l (sp)+,a2
          exg a2,a6           ;pointe maintenant l'expression
          move.l a2,-(sp)
          movem.l d2/a1,-(sp) ;stocke pour l'egalisation
          clr parenth
          bsr evalbis         ;va evaluer l'expression
          movem.l (sp)+,d5/a1
          bsr letbis          ;va egaliser la variable
          move.l (sp)+,a2
          tst parenth
          bne.s fn3
          cmp.b #",",(a6)+    ;une virgule apres chaque exp
          bne syntax
          exg a2,a6           ;la syntax err doit etre sur la bonne ligne!
          cmp.b #",",(a6)+    ;une virgule apres chaque var
          bne syntax
          bra.s fn2
fn3:      cmp #-1,parenth
          bne syntax
          exg a2,a6
          cmp.b #")",(a6)+    ;les deux parentheses doivent etre fermees
          bne usfoncall
          cmp.b #$f1,(a6)+    ;veut un egal dans la definition
          bne syntax
          exg a2,a6
; effectue les calculs
fn4:      move.l a6,-(sp)
          clr parenth
          move.l a2,a6        ;chrget sur la fonction
          bsr evalbis         ;va evaluer a fonction
          tst parenth
          bne syntax
          move.l (sp)+,a6      ;reprend le chrget
          move.w (sp)+,parenth ;remet les parentheses
          rts

;-----------------------------------------    --- ----- ---   ---    -------
;    ----------------------------------      |      |  |   | |
;   |            OPERATEURS            |      ---   |  |   |  ---
;    ----------------------------------          |  |  |   |     |
;-----------------------------------------    ---       ---   ---    -------

; LET: egalisation de deux variables
llet:     cmp.b #$fa,(a6)+    ;veut une variable
          bne syntax
; entree directe
let:      lea bufcalc,a3      ;buffer de calcul si variable tableau!!!
          bsr findvar         ;va chercher la variable
          movem.l d2/a1,-(sp) ;de cote pour apres
          move.b (a6)+,d0
          cmp.b #$f1,d0       ;operateur = SEUL AUTORISE!
          bne syntax
          bsr evalue
          tst parenth         ;niveau de parenthese doit etre a zero!
          bne syntax
          movem.l (sp)+,d5/a1 ;depile la variable a changer
letbis:   cmp.b d2,d5
          bne let3
          tst.b d5
          beq.s let1
          bmi.s let2
; egalisation entre float
let0:     move.l d3,(a1)
          move.l d4,4(a1)
          rts
; egalisation entre entiers
let1:     move.l d3,(a1)
          rts
; egalisation entre chaines
let2:     move.l d3,(a1)
          rts
; compatibilite entre variables
let3:     tst.b d5
          bmi typemis
          tst.b d2
          bmi typemis
          bne.s let4
          bsr inttofl         ;--->d2/d3/d4--->float
          bra.s let0
let4:     bsr fltoint         ;--->d2/d3/d4--->entier
          bra.s let1

; SWAP aa,bb: VARIABLES DE MEME TYPE UNIQUEMENT
swap:     cmp.b #$fa,(a6)+    ;veut une variable!
          bne syntax
          lea bufcalc,a3
          bsr findvar
          movem.l d2/a1,-(sp)
          cmp.b #",",(a6)+
          bne syntax
          cmp.b #$fa,(a6)+    ;veut une variable!
          bne syntax
          lea bufcalc,a3
          bsr findvar
          movem.l (sp)+,d5/a2
          cmp.b d2,d5
          bne typemis         ;veut le meme type de variable
          tst.b d2
          beq.s swp1
          bmi.s swp1
          move.l 4(a1),d0     ;float
          move.l 4(a2),4(a1)
          move.l d0,4(a2)
swp1:     move.l (a1),d0      ;entier et alphanumerique
          move.l (a2),(a1)
          move.l d0,(a2)
          rts

; SOUS PRG POUR SORT ET FIND: PREND LES CARACTERISTIQUES D'UN TABLEAU
getablo:  cmp.b #$fa,(a6)+
          bne syntax
          move #1,sortflg
          bsr findvar         ;va chercher le tableau
          clr sortflg
          btst #5,d2
          beq typemis         ;veut un tableau!
          move.l (a1)+,d6     ;taille totale du tableau
          clr.l d0
          move.w (a1)+,d0
          movem.l d0/d2/a1/d6,-(sp)
          addq.l #1,a6        ;pointe l'interieur du tableau
          move parenth,-(sp)
or1:      move d0,-(sp)       ;saute toutes les dimensions du tableau
          bsr evalbis
          move (sp)+,d0
          subq #1,d0
          tst parenth
          bne.s or2
          cmp.b #",",(a6)+
          beq.s or1
          bne syntax
or2:      cmp #-1,parenth
          bne syntax
          tst d0
          bne syntax
          move (sp)+,parenth
          movem.l (sp)+,d0/d2/a1/d6
          lsl.l #1,d0
          add.l d0,a1         ;saute les dimensions
          moveq #2,d7
          and.b #$c0,d2
          bmi.s or3
          beq.s or3
          moveq #3,d7         ;facteur de decalage en d7
or3:      subq.l #6,d6        ;saute ttableau en nbdim
          sub.l d0,d6         ;saute les dimensions
          lsr.l d7,d6         ;NM=d6: nombre d'elements du tableau
          rts

; SORT a$(0): CLASSE UN TABLEAU DE VARIABLE
sort:     lea bufcalc,a3      ;SORT est une instruction!!!!
          bsr getablo         ;va chercher les caracteristiques du tableau
          move.l d6,d3
or4:      lsr.l #1,d3         ;E=d3
          beq or10
          moveq #1,d5         ;NA=d5
or5:      move.l d5,d4        ;NR=d4 -> NR=NA
or6:      movem.l d3-d7/a1,-(sp)
          move.l a1,a0
          subq.l #1,d4
          lsl.l d7,d4
          add.l d4,a0
          move.l a0,a1
          lsl.l d7,d3
          add.l d3,a1
          move.l (a0),d6      ;n$(nr)
          move.l 4(a0),d7
          move.l (a1),d3      ;n$(nr+e)
          move.l 4(a1),d4
          movem.l d2/a0-a1,-(sp)
          move.b d2,d5
          bsr supbis          ;va comparer
          movem.l (sp)+,d2/a0-a1
          tst.l d3
          beq.s or8
; fait le swap
          tst.b d2
          beq.s or7
          bmi.s or7
          move.l 4(a0),d0
          move.l 4(a1),4(a0)
          move.l d0,4(a1)
or7:      move.l (a0),d0
          move.l (a1),(a0)
          move.l d0,(a1)
          movem.l (sp)+,d3-d7/a1
          sub.l d3,d4         ;NR=NR-E
          beq.s or9
          bcc.s or6
          bra.s or9
or8:      movem.l (sp)+,d3-d7/a1
or9:      addq.l #1,d5        ;NA=NA+1
          move.l d6,d0
          sub.l d3,d0
          cmp.l d0,d5
          bls or5
          bra or4
or10:     rts

; b=MATCH (a(0),b): TROUVE UNE VARIABLE PAR DICHOTOMIE, RAMENE SA PLACE
dichot:   cmp.b #"(",(a6)+
          bne syntax
          bsr getablo         ;va chercher le tableau
          movem.l a1/d2/d6/d7,-(sp)
          cmp.b #",",(a6)+
          bne syntax
          move parenth,-(sp)
          move #1,parenth
          bsr evalbis
          tst parenth
          bne syntax
          move (sp)+,parenth
          movem.l (sp)+,a1/d5/d6/d7
; etabli la compatibilite entre variables
          cmp.b d2,d5
          beq.s di3
          tst.b d2
          bmi typemis
          tst.b d5            ;variable recherchee--->comme le tableau
          bmi typemis
          beq.s di2
          bsr fltoint
          bra.s di3
di2:    bsr inttofl
; recherche!
di3:      clr.l d5            ;d5= base de recherche
          move.l d6,d1        ;d1= nombre total d'elements
          lsr.l #1,d6         ;d6= pivot de la recherche
di4:      movem.l a1/d1-d7,-(sp)
          add.l d6,d5
          lsl.l d7,d5
          add.l d5,a1         ;pointe la variable du tableau
          move.l (a1),d6
          move.l 4(a1),d7     ;prend les deux: ca fait pas de mal!
          movem.l d2-d7,-(sp)
          move.b d2,d5
          bsr egbis           ;egal ???
          tst.l d3
          bne di11          ;trouve!
          movem.l (sp)+,d2-d7
          move.b d2,d5
          bsr supbis          ;superieur strictement
          tst.l d3
          beq.s di5
; moitie inferieure de la liste
          movem.l (sp)+,a1/d1-d7
          bra.s di6
; moitie superieure de la liste
di5:      movem.l (sp)+,a1/d1-d7
          add.l d6,d5         ;change de cote!
di6:      tst.l d6
          beq.s di7
          lsr.l #1,d6
          bra.s di4
; pas trouve: cherche le premier element superieur
di7:      cmp.l d1,d5         ;arrive a la fin de la liste?
          bcc.s di10
          movem.l a1/d1-d7,-(sp)
          lsl.l d7,d5
          add.l d5,a1
          move.l (a1),d6
          move.l 4(a1),d7
          movem.l d2-d7,-(sp)
          move.b d2,d5
          bsr egbis
          tst.l d3            ;trouve dans la fin!
          bne.s di11
          movem.l (sp)+,d2-d7
          move.b d2,d5
          bsr supbis
          tst.l d3
          bne.s di9
          movem.l (sp)+,a1/d1-d7
          addq.l #1,d5
          bra.s di7
di9:      movem.l (sp)+,a1/d1-d7
di10:     move.l d5,d3        ;NEGATIF: pas trouve!
          addq.l #1,d3        ;plus 1=> -1<toute la liste
          neg.l d3            ;<taille liste=> >a toute la liste!!!!
          clr.b d2
          rts
; trouve!
di11:     movem.l (sp)+,d2-d7
          movem.l (sp)+,a1/d1-d7
          move.l d5,d3        ;calcule le pointeur dans le tableau
          add.l d6,d3
          clr.b d2
          rts

; INC a: addition rapide
inc:      cmp.b #$fa,(a6)+
          bne syntax
          lea bufcalc,a3
          bsr findvar
          tst.b d2            ;que des entiers
          bne typemis
          add.l #1,(a1)
          bvs overflow
          rts

; DEC a: soustraction rapide
dec:      cmp.b #$fa,(a6)+
          bne syntax
          lea bufcalc,a3
          bsr findvar
          tst.b d2            ;que des entiers
          bne typemis
          sub.l #1,(a1)
          bvs overflow
          rts

; OPERATEUR PLUS
plus:     bsr compat
          beq.s plus1
          bmi.s plus2
plusfl:   moveq #0,d0
opfloat:  move.l d6,d1        ;entree des operateurs en float
          move.l d7,d2
          trap #6
          move.l d0,d3
          move.l d1,d4
          move.b #$40,d2
          rts
plus1:    add.l d6,d3         ;addition entiere
          bvs overflow
          rts
; addition de chaines
plus2:    move.l d3,a2
          move.l d3,-(sp)
          clr.l d3
          move (a2),d3        ;taille de la deuxieme chaine
          beq.s plus11          ;deuxieme chaine nulle
          move.l d6,a2
          clr.l d0
          move (a2),d0
          beq.s plus10          ;premiere chaine nulle
          add.l d0,d3
          cmp.l #$fff0,d3
          bcc stoolong        ;string too long!
          bsr demande
          move d3,(a0)+       ;poke la taille resultante
          move (a2)+,d0
          beq.s plus4
          subq #1,d0
plus3:    move.b (a2)+,(a0)+  ;recopie de la premiere chaine
          dbra d0,plus3
plus4:    move.l (sp)+,a2
          move (a2)+,d0
          beq.s plus6
          subq #1,d0
plus5:    move.b (a2)+,(a0)+
          dbra d0,plus5
plus6:    move a0,d0          ;rend pair
          btst #0,d0
          beq.s plus7
          addq.l #1,a0
plus7:    move.l a0,hichaine
          move.l a1,d3
          move.b #$80,d2
          rts
plus10:   move.l (sp)+,d3     ;premiere chaine nulle: ramene la deuxieme
          move.b #$80,d2
          rts
plus11:   addq.l #4,sp        ;deuxieme chaine nulle: ramene la premiere
          move.l d6,d3
          move.b #$80,d2
          rts

; OPERATEUR MOINS
moins:    bsr compat
          beq.s ms1
          bmi.s ms2
          moveq #1,d0
          bra opfloat
ms1:      sub.l d3,d6          ;soustraction entiere
          bvs overflow
          move.l d6,d3
          rts
; Soustraction de chaines EXCLUSIF!!!
ms2:      move.l d3,d4        ;sauve pour plus tard
          move.l d6,a2
          clr.l d3
          move.w (a2)+,d3
          move.l d3,d1
          bsr demande         ;prend la place une fois pour toute!
          move.w d3,(a0)+
          beq.s ms4
          addq #1,d3
          lsr #1,d3
          subq #1,d3
ms3:      move.w (a2)+,(a0)+  ;recopie la chaine
          dbra d3,ms3
ms4:      move.l a0,hichaine
          addq.l #2,a1        ;chaine dont auquelle on soustrait en a1/d1
          move.l d4,a2
          clr.l d2
          move (a2)+,d2       ;chaine a soustraire en a2/d2

ms5:      clr.l d4
          movem.l d1-d2/a1-a2,-(sp)
          bsr instrfind       ;recherche la chaine!
          movem.l (sp)+,d1-d2/a1-a2
          tst.l d3
          beq.s ms9
          move.l a1,a0
          move.l a1,d4        ;pour plus tard!
          subq.l #1,d3
          move.l d3,d5        ;taille du debut a garder
          add.l d3,a1         ;pointe ou transferer la fin
          add.l d2,d3
          add.l d3,a0         ;pointe la fin a recopier
          sub.l d3,d1
          add.l d1,d5         ;taille finale en memoire
          subq.l #1,d1
          bmi.s ms7
ms6:      move.b (a0)+,(a1)+
          dbra d1,ms6
ms7:      move a0,d0          ;rend pair
          btst #0,d0
          beq.s ms8
          addq.l #1,a0
ms8:      move.l a0,hichaine  ;baisse la limite!
          move.l d4,a1
          move.w d5,-2(a1)
          move.l d5,d1
          bra.s ms5
ms9:      move.b #$80,d2
          move.l a1,d3
          subq.l #2,d3
          rts

; OPERATEUR ETOILE
multiplie:bsr compat
          beq milt1
          bmi syntax
          moveq #2,d0
          bra opfloat         ;multiplication float
milt1:    cmp.l #$00008000,d3
          bcc.s mlt0
          cmp.l #$00008000,d6
          bcc.s mlt0
          muls d6,d3          ;quand on le peut: multiplication directe!
          rts
mlt0:     clr d4              ;multiplication signee 32*32 bits
          tst.l d3            ;aabb*ccdd
          bpl.s mlt1
          neg.l d3
          not d4
mlt1:     tst.l d6            ;tests des signes
          bpl.s mlt2
          neg.l d6
          not d4
mlt2:     move d6,d1
          mulu d3,d1
          bmi overflow
          swap d6
          move d6,d0
          mulu d3,d0
          swap d0
          bmi overflow
          tst d0
          bne overflow
          add.l d0,d1
          bvs overflow
          swap d3
          move d6,d0
          mulu d3,d0
          bne overflow
          swap d6
          move d6,d0
          mulu d3,d0
          swap d0
          bmi overflow
          tst d0
          bne overflow
          add.l d0,d1
          bvs overflow
          tst d4              ;signe du resultat
          beq.s mlt3
          neg.l d1
mlt3:     move.l d1,d3
          rts

; OPERATEUR DIVISE
divise:   bsr compat
          bmi syntax
          beq.s div1
          moveq #3,d0
          bra opfloat         ;division en float
div1:     tst.l d3
          beq dbyzero         ;division par zero!
          clr d7
          tst.l d6
          bpl.s dva
          not d7
          neg.l d6
dva:      cmp.l #$10000,d3    ;Division rapide ou non?
          bcc.s dv0
          tst.l d3
          bpl.s dvb
          not d7
          neg.l d3
dvb:      move.l d6,d0
          divu d3,d0          ;division rapide: 32/16 bits
          bvs.s dv0
          moveq #0,d3
          move d0,d3
          bra.s dvc
dv0:      tst.l d3
          bpl.s dv3
          not d7
          neg.l d3
dv3:      moveq #31,d5         ;division lente: 32/32 bits
          moveq #-1,d4
          clr.l d1
dv2:      lsl.l #1,d6
          roxl.l #1,d1
          cmp.l d3,d1
          bcs.s dv1
          sub.l d3,d1
          lsr #1,d4           ;met X a un!
dv1:      roxl.l #1,d0
          dbra d5,dv2
          move.l d0,d3
dvc:      tst d7
          beq.s dvd
          neg.l d3
dvd:      rts

; OPERATEUR PUISSANCE
puissant: bsr quefloat        ;que des float
          moveq #28,d0
          bra opfloat

; OPERATEUR MODULO
modulo:   bsr quentier	;Que des entiers!
	bsr dv0             ;va effectuer la division
          move.l d1,d3        ;prend le reste!
          rts

; COMPARAISON DE DEUX CHAINES
compch:   move.l d6,a0
          move.l d3,a1
          clr.l d3
          clr.l d6
          clr.b d2
          move.w (a0)+,d0
          move.w (a1)+,d1
          beq.s cpch8
          tst d0
          beq.s cpch7
cpch1:    cmpm.b (a0)+,(a1)+
          bne.s cpch6
          subq #1,d0
          beq.s cpch3
          subq #1,d1
          bne.s cpch1
; on est arrive au bout d'une des chaines
cpch2:    moveq #1,d6         ;A$>B$
          rts
cpch3:    subq #1,d1          ;egalite!
          beq.s cpch5
cpch4:    moveq #1,d3         ;B$>A$
cpch5:    rts
; on est pas arrive au bout des chaines
cpch6:    bcc.s cpch4
          bcs.s cpch2
; a$ est nulle
cpch7:    tst d1
          beq.s cpch5           ;deux chaines nulles
          bne.s cpch4           ;B$>A$
; b$ est nulle
cpch8:    tst d0
          beq.s cpch5           ;deux chaines nulles
          bne.s cpch2           ;A$>B$

; OPERATEUR EGAL
egale:    bsr compat
egbis:    beq.s eg1             ;entree pour find
          bmi.s eg2
          move #$0f,d0
eg0:      bsr opfloat         ;entree des comparaisons de FLOAT
          move.l d0,d3
          clr.b d2
          rts
eg1:      cmp.l d3,d6
          beq.s vrai
faux:     clr.l d3
          clr.b d2
          rts
vrai:     move.l #-1,d3
          clr.b d2
          rts
eg2:      bsr compch
          bra.s eg1
 
; OPERATEUR INFERIEUR STRICTEMENT
inf:      bsr compat
          beq.s inf1
          bmi.s inf2
          move #$13,d0
          bra eg0
inf1:     cmp.l d3,d6
          blt vrai
          bra faux
inf2:     bsr compch
          bra.s inf1

; OPERATEUR INFERIEUR OU EGAL
infeg:    bsr compat
          beq.s infeg1
          bmi.s infeg2
          move #$14,d0
          bra eg0
infeg1:   cmp.l d3,d6
          ble vrai
          bra faux
infeg2:   bsr compch
          bra.s infeg1

; OPERATEUR DIFFERENT
diff:     bsr compat
          beq.s dif1
          bmi.s dif2
          move #$10,d0
          bra eg0
dif1:     cmp.l d3,d6
          bne vrai
          bra faux
dif2:     bsr compch
          bra.s dif1

; OPERATEUR SUPERIEUR STRICTEMENT
sup:      bsr compat
supbis:   beq.s sup1
          bmi.s sup2
          move #$11,d0
          bra eg0
sup1:     cmp.l d3,d6
          bgt vrai
          bra faux
sup2:     bsr compch
          bra.s sup1

; OPERATEUR SUPERIEUR OU EGAL
supeg:    bsr compat
          beq.s supeg1
          bmi.s supeg2
          move #$12,d0
          bra eg0
supeg1:   cmp.l d3,d6
          bge vrai
          bra faux
supeg2:   bsr compch
          bra.s supeg1

; OPERATEUR AND
opand:    bsr quentier
          and.l d6,d3
          rts

; OPERATEUR OR
opor:     bsr quentier
          or.l d6,d3
          rts

; OPERATEUR XOR
opxor:    bsr quentier
          eor.l d6,d3
          rts

;-----------------------------------------    --- ----- ---   ---    -------
;    ----------------------------------      |      |  |   | |
;   |     FONCTIONS MATHEMATIQUES      |      ---   |  |   |  ---
;    ----------------------------------          |  |  |   |     |
;-----------------------------------------    ---       ---   ---    -------
; NOT: FONCTION QUI SE FAIT PASSER POUR UN OPERATEUR! Mais ca ne prend pas!
naut:     bsr fentier
          not.l d3
          rts

; PI=constante
pi:     move.w #$ff02,d0
	trap #6
	move.b #$40,d2
	rts

; DEG(xx)---> conversion RADIANS->DEGRES
; / pi * 160
deg:    bsr ffloat            ;operande FLOAT -> D2/D3/D4
	move.w #$ff03,d0
	trap #6
	move.b #$40,d2
	rts
          
; RAD(xx)---> conversion DEGRES->RADIANS
; / 160 * pi
rad:    bsr ffloat            ;operande FLOAT -> D2/D3/D4
	move.w #$ff04,d0
	trap #6
	move.b #$40,d2
	rts
         
; SINus
sin:      bsr ffloat
          moveq #4,d0         ;sin
foncfl:   move.l d3,d1        ;entree des fonctions float
          move.l d4,d2
          trap #6
          move.l d0,d3
          move.l d1,d4
          move #$40,d2
          rts

; COSinus
cos:      bsr ffloat
          moveq #5,d0
          bra foncfl

; TANgente
tan:      bsr ffloat
          moveq #6,d0
          bra foncfl

; EXPonentielle
exp:      bsr ffloat
          moveq #7,d0
          bra foncfl

; LOGNarythme neperien (pour attendre)
log:      bsr ffloat
 	move.w #$ff01,d0
	trap #6
	tst.w d0
	bmi illneg
          moveq #8,d0
          bra foncfl

; LOGarythme decimal
log10:    bsr ffloat
 	move.w #$ff01,d0
	trap #6
	tst.w d0
	bmi illneg
          moveq #$9,d0
          bra foncfl

; SQR
sqr:      bsr ffloat
 	move.w #$ff01,d0
	trap #6
	tst.w d0
	bmi illneg
          moveq #$a,d0
          bra foncfl

; SINH
sinh:     bsr ffloat
          moveq #$18,d0
          bra foncfl

; COSH
cosh:     bsr ffloat
          moveq #$19,d0
          bra foncfl

; TANH
tanh:     bsr ffloat
          moveq #$1a,d0
          bra foncfl

; ASIN
asin:     bsr ffloat
          moveq #$15,d0
          bra foncfl

; ACOS
acos:     bsr ffloat
          moveq #$16,d0
          bra foncfl

; ATAN
atan:     bsr ffloat
          moveq #$17,d0
          bra foncfl

; ABS
abs:      bsr farg
          bne abs1
          tst.l d3
          bpl abs0
          neg.l d3
abs0:     rts
abs1:     moveq #$1d,d0
          bra foncfl

; INT
int:      bsr farg
          bne int1
          rts
int1:     moveq #$1b,d0
          bra foncfl

; SGN
sgn:      bsr farg
          bne.s sgn5
sgn0:     tst.l d3
          beq.s sgn4
sgn1:     bpl.s sgn3
	move.l #-1,d3
          clr.b d2
          rts
sgn3:     move.l #1,d3
          clr.b d2
          rts
sgn4:     clr.l d3
          clr.b d2
          rts
sgn5:     move.w #$ff01,d0		;Fonction GET SGN
	trap #6
	move.l d0,d3
	clr.b d2
	rts
 
; RND (xx)
rnd:      bsr fentier         ;va chercher l'argument
          tst.l d3
          bpl.s rnd1
	clr.b d2
          move.l ancrnd2,d3
          rts
rnd1:     beq.s rnd6
          move.l #$ffffff,d4
          move #23,d0
rnd2:     lsr.l #1,d4
          cmp.l d3,d4
          dbcs d0,rnd2
          roxl.l #1,d4
rnd4:     move.w #17,-(sp)
	trap #14
	addq.l #2,sp
          and.l d4,d0         ;masque le chiffre
          cmp.l d3,d0
          bhi.s rnd4
          move.l d0,d3
          clr.b d2	
	move.l d3,ancrnd2
          rts
rnd6:     bra foncall

; SSPGM de max et min
maxmin:   move parenth,-(sp)
          cmp.b #"(",(a6)+
          bne syntax
          clr parenth
          bsr evalbis
          tst parenth
          bne syntax
          movem.l d2-d4,-(sp)
          move #1,parenth
          cmp.b #",",(a6)+
          bne syntax
          bsr evalbis
          tst parenth
          bne syntax
          movem.l (sp)+,d5-d7
          move (sp)+,parenth
          rts

; MAX (aa,bb)
max:      bsr maxmin
          movem.l d2-d7,-(sp)
          bsr supeg
          bra.s min1
; MIN (aa,bb)
min:      bsr maxmin
          movem.l d2-d7,-(sp)
          bsr infeg
min1:     move.l d3,d0
          movem.l (sp)+,d2-d7
          tst.l d0
          beq.s min2
          exg d2,d5
          exg d3,d6
          exg d4,d7
min2:     rts

;-----------------------------------------    --- ----- ---   ---    -------
;    ----------------------------------      |      |  |   | |
;   |       GESTION DES ERREURS        |      ---   |  |   |  ---
;    ----------------------------------          |  |  |   |     |
;-----------------------------------------    ---       ---   ---    -------
; SYNTAX
syntax:   moveq #12,d0
          bra erreur
; OUT OF MEMORY
outofmm:  moveq #8,d0
          bra erreur
; PRINTER NOT READY
prtnotr:  moveq #10,d0
          bra erreur
; ILLEGAL FUNCTION CALL
foncall:  moveq #13,d0
          bra erreur
; ILLEGAL DIRECT
illdir:   moveq #14,d0
          bra erreur
; TYPE MISMATCH
typemis:  moveq #19,d0
          bra erreur
;NON DIMENSIONE
nondim:   moveq #18,d0
          bra erreur
; PAS IMPLEMENTE!
pasimp:   moveq #20,d0
          bra erreur
; OVERFLOW
overflow: moveq #21,d0
          bra erreur
; FOR WITHOUT NEXT
fornext:  moveq #22,d0
          bra erreur
; NEXT WITHOUT FOR
nextfor:  moveq #23,d0
          bra erreur
; WHILE WITHOUT WEND
whilewend:moveq #24,d0
          bra erreur
; WEND WITHOUT WHLIE
wendwhile:moveq #25,d0
          bra erreur
; REPEAT WITHOUT UNTIL
repuntil: moveq #26,d0
          bra erreur
; UNTIL WITHOUT REPEAT
unrepeat: moveq #27,d0
          bra erreur
; UNDEFINED LINE NUMBER
undef:    moveq #29,d0
          bra erreur
; STRING TOO LONG
stoolong: moveq #30,d0
          bra erreur
; ERREUR DE BUS
errbus:   moveq #31,d0
          bra erreur
; ERREUR D'ADRESSE
erradr:   moveq #32,d0
          bra erreur
; NO DATAS ON THIS LINE
nodata:   moveq #33,d0
          bra erreur
; OUT OF DATAS
outofdata:moveq #34,d0
          bra erreur
; TOO MANY GOSUB
toogsb:   moveq #35,d0
          bra erreur
; RETURN WITHOUT GOSUB
retgsb:   moveq #36,d0
          bra erreur
; POP WITHOUT GOSUB
popgsb:   moveq #37,d0
          bra erreur
; RESUME WITHOUT ERROR
noerror:  moveq #38,d0
          bra erreur
; USER FUNCTION NOT DEFINED
usnotdef: moveq #39,d0
          bra erreur
; ILLEGAL USER FUNCTION CALL
usfoncall:moveq #40,d0
          bra erreur
; BANK ALREADY RESERVED
dejares:  moveq #41,d0
          bra erreur
; NOT A SCREEN
notscreen:moveq #42,d0
          bra erreur
; PAS DE 256
pas256:   moveq #43,d0
          bra erreur
; BANK NOT DEFINED
bknotdef: moveq #44,d0
          bra erreur
; RESOLUTION NOT ALLOWED
cantres:  moveq #45,d0
          bra erreur
; DIVISION BY ZERO
dbyzero:  moveq #46,d0
          bra erreur
; ILLEGAL NEGATIVE
illneg:   moveq #47,d0
          bra erreur
; BAD TIME
badtime:  moveq #54,d0
          bra erreur
; BAD DATE
baddate:  moveq #55,d0
          bra erreur
; SPRITE ERROR
spriterr: moveq #56,d0
          bra erreur
; MOVE ERROR
mouverr:  moveq #57,d0
          bra erreur
; ANIM ERROR
animerr:  moveq #58,d0
          bra erreur
; FLASH ERROR
illflash: moveq #67,d0
          bra erreur
; SYSTEM WINDOW
syswind:  moveq #76,d0
          bra erreur
; JEU DE CARACTERES SYSTEME
charsys:  moveq #77,d0
          bra erreur
; JEU DE CARACTERE NON TROUVE
charnotf: moveq #78,d0
          bra erreur
; MENU NOT DEFINED
menunotd: moveq #79,d0
          bra erreur
; BANK 15 ALREADY RESERVED
menures:  moveq #80,d0
          bra erreur
; BANK IS RESERVED
menuill:  moveq #81,d0
          bra erreur
; ILLEGAL INSTRUCTION
illinst:  moveq #82,d0
          bra erreur
; SUBSCRIPT OUT OF RANGE
subsout:  moveq #85,d0
          bra erreur
       
; TRAITEMENT DES ERREURS: D0=NUMERO DE L'ERREUR
erreur:   move d0,d4
          lsl #1,d0           ;ecris dans 2 langues!!!
          lea merreur,a2      ;trouve le message, en a2
          subq #1,d0
          bmi.s err2
err1:     tst.b (a2)+
          bne.s err1
          dbra d0,err1
; entree secondaire pour les extensions
err2:     movem.l a0/d4,-(sp)
          jsr close           ;ferme le fichier systeme
          clr.l printpos      ;print normal
          clr sortflg         
          clr inputflg        ;hachement important
          move.l adlogic,$44e ;en cas de BUS/ADRESS error lors de graphiques
          movem.l (sp)+,a0/d4
          cmp #2,undoflg      ;si on vient d'appuyer sur UNDO---> message!
          beq err4
          tst runflg
          bne.s err3
; erreur en mode direct: JAMAIS DETOURNEE!!!
          tst runonly
          bne sysbis
          clr folflg          ;important! plus de follow
          clr autoflg         ;important aussi: plus d'auto!
          bsr retour
          move.l a2,a0
          bsr traduit         ;va traduire! genial
          move #1,d7
          trap #3
          move.b #".",d0
          clr d7
          trap #3
err2a:    jmp ok
; erreur en MODE PROGRAMME
err3:     clr contflg
          move.l a4,contchr   ;met tout pour le cont
          move.l a5,contline
          move.l a4,errorchr  ;chrget lors de l'erreur
          move.w d4,errornb
          tst erroron         ;si DEUX ERREURS ensembles: message!!!
          bne.s err5
          tst.l onerrline     ;on error goto???
          beq.s err5
; les erreurs sont detournees!!!
          cmp #17,d4          ;ne detourne pas le break!
          beq.s err5
          move #1,erroron     ;erreur en route!
          move.l a5,errorline ;ligne de l'erreur=ligne actuelle!
          move.l onerrline,a5
          lea pile,sp
          bra lignesvt        ;branche au chrget
; reaffiche un message (UNDO)
err4:     move.l errorline,a1
          clr errornb         ;ne remet plus la prochaine fois!
          clr undoflg
          bra err6a
; affiche un message ou revient si runonly
err5:     tst runonly         ;si RUN ONLY, revient au systeme!
          bne sysbis
          move.l dsource,a0   ;trouve la ligne reelle de l'erreur
          addq.l #4,a0
err6:     move.l a0,a1
          add -4(a0),a0
          cmp.l a0,a6
          bcc.s err6
          subq.l #4,a1        ;pointe la ligne de l'erreur
          move.l a1,errorline
err6a:    clr erroron
          clr runflg          ;retour en direct
          bsr retour
          move.l a2,a0
          bsr traduit         ;dans toutes les langues
          move #1,d7
          trap #3
          lea inline,a0
          bsr traduit
          trap #3
          clr.l d0
          move 2(a1),d0
          lea buffer,a5
          bsr longdec
          move.b #".",(a5)+
          clr.b (a5)+
          lea buffer,a0
          move #1,d7
          trap #3
          move #1,contflg     ;autorise un cont!!!
; liste la ligne de l'erreur, et revient a l'editeur
	bsr zofonc
          cmp #17,errornb     ;si break, ne liste pas
          beq ok
          clr folflg          ;pas break: inhibe follow!
          clr contflg         ;pas break: on ne pas faire de CONT!
          bsr retour
          move.l errorline,a6
          bsr detok
          lea buffer,a0
          move #1,d7
          trap #3
          jmp ok

; ON ERROR GOTO
onerror:  cmp.b #$98,(a6)+    ;veut un goto apres!
          bne syntax
          move a6,d0
          btst #0,d0
          beq.s oe1
          addq.l #1,a6
oe1:      move.l (a6)+,d3
          bne.s oe4
; pas encore passe dessus
          clr gotovar
          pea -4(a6)
          bsr expentier       ;va chercher l'expression
          tst.l d3
          beq.s oe2
          bsr findrun         ;va chercher la ligne
          move.l a0,d3
oe2:      or.l #$ff000000,d3
          move.l (sp)+,a0
          tst gotovar         ;ne poke pas si variable dans l'expression!
          bne.s oe5
          move.l d3,(a0)      ;poke dans le source
          bra.s oe5
; deja passe dessus
oe4:      move.l d3,-(sp)
          bsr expentier
          move.l (sp)+,d3  
oe5:      and.l #$00ffffff,d3
          move.l d3,onerrline ;adresse ou aller!
          rts

; ERROR xx: ERREUR SIMULEE
erraur:   bsr expentier
          cmp.l #86,d3
          bcc foncall
          move.l d3,d0
          bra erreur

; RESUME [xxxx]
resume:   tst.w erroron
          beq noerror         ;pas d'erreur en cours!
          bsr finie
          beq.s resum1
; resume numero de ligne
          bsr expentier
          bsr findrun
          move.l a0,d0
          clr.l errorline
          clr.w errornb
          clr.w erroron       ;plus d'erreur!
          bra gotobis         ;effectue le GOTO
; resume tout seul
resum1:   move.l errorchr,a4  ;positionne le chrget
          move.l a4,a6
          subq.l #1,a6        ;debut d'une instruction!!!
          move.l errorline,a5 ;ligne actuelle
          clr.l errorline
          clr.w errornb
          clr.w erroron       ;plus d'erreur
          bra sorbcle         ;nettoie les boucles et revient au chrget

; RESUME NEXT
resnext:  tst erroron
          beq noerror         ;pas d'erreur en cours!
rna:      move.l errorchr,a0
          move.l errorline,a5 ;numero de la ligne de l'erreur
          clr.l errorline
          clr.l errornb
          clr.l erroron
rn0:      move.b (a0)+,d2
          beq.s rn9         ;fin de la ligne
          cmp.b #":",d2       ;instruction suivante trouvee!
          beq.s rn10
          cmp.b #$9b,d2       ;instruction suivante= ELSE
          beq rn10
          cmp.b #$9a,d2       ;si THEN: resume ligne suivante!
          beq rn8
          tst.b d2            ;saute tous les caracteres > 0
          bpl.s rn0
          cmp.b #$a0,d2       ;instruction etendue
          beq.s rn1
          cmp.b #$b8,d2       ;fonction etendue
          beq.s rn1
          cmp.b #$a8,d2       ;.EXT instruction
          beq.s rn6
          cmp.b #$c0,d2       ;.EXT fonction
          bne.s rn2
rn6:      addq.l #2,a0
rn1:      addq.l #1,a0
          bra.s rn0
rn2:      cmp.b #$fa,d2       ;variable ou constante?
          bcc.s rn3
          cmp.b #$98,d2
          bcs.s rn0
          cmp.b #$a0,d2
          bcc.s rn0
rn3:      move a0,d3          ;rend pair
          btst #0,d3
          beq.s rn4
          addq.l #1,a0
rn4:      cmp.b #$ff,d2
          bne.s rn5
          addq.l #4,a0        ;constantes float sur huit octets!
rn5:      addq.l #4,a0        ;saute le flag
          bra rn0
; resume next---> THEN
rn8:      add.w (a5),a5       ;fait un GOTO ligne suivante!
          move.l a5,a6
          addq.l #4,a6
          bra sorbcle
; resume ->fin ligne, ->: ->else
rn9:      subq.l #1,a0
rn10:     move.l a0,a6        ;positionne le chrget
          bra sorbcle         ;nettoie les boucles et revient au chrget

; ERROR LINE: ramene le numero de la ligne ou s'est produite la derniere erreur
errline:  moveq #0,d3
	moveq #0,d2
	move.l errorline,d0
	beq.s errl1
	move.l d0,a0
          move.w 2(a0),d3
errl1:    rts

; ERROR NUMBER: ramene le numero de la derniere erreur
errnumber:clr.l d3
          move.w errornb,d3
          clr.b d2
          rts

; BREAK ON/OFF
breaque:  bsr onoff
          bmi syntax
          bne.s bron
          move #1,brkinhib
          rts
bron:     clr brkinhib
          rts

; ENTREE DU BREAK
braik:    bclr #0,interflg      ;arrete le CONTROL-C
          tst brkinhib
          bne.s brk5            ;break inhibe!
stop:     move #17,d0
          bra erreur
brk5:     bra it

; CONT
cont:     tst contflg
          bne.s cont1
          move #7,d0          ;can't continue!
          bra erreur
cont1:    clr contflg
          move #1,runflg      ;CONT n'est qu'un vulgaire RESUME NEXT! Peuh...
          bra rna

;-----------------------------------------    --- ----- ---   ---    -------
;    ----------------------------------      |      |  |   | |
;   | BRANCHEMENTS, BOUCLES, ET TESTS  |      ---   |  |   |  ---
;    ----------------------------------          |  |  |   |     |
;-----------------------------------------    ---       ---   ---    -------
; GOTO
goto:     move a6,d0          ;rend pair
          btst #0,d0
          beq.s gt1
          addq.l #1,a6
gt1:      move.l (a6),d0      ;prend le numero
          bne gotobis
          move.l a6,-(sp)
          addq.l #4,a6
          clr gotovar         ;flag VARIABLE a zero
          bsr expentier       ;recupere le numero dans d3
          bsr findrun         ;va chercher la ligne en a0
          move.l (sp)+,a1
          move.l a0,d0
          tst runflg
          bne.s goto2
; goto en mode direct
          move.l d0,-(sp)
          bsr cvbis           ;nettoie les variables systeme
          bsr propre          ;va nettoyer le programme
          move.l (sp)+,d0
          move #1,runflg      ;mode programme
          bra.s gotobis
goto2:    tst gotovar         ;si il y a une variable dans l'expression,
          bne.s gotobis         ;on ne stocke pas!
          move.l d0,(a1)      ;stocke dans le source
gotobis:  move.l d0,a5
          move.l a5,a6
          addq.l #4,a6

; TESTE SI SORT D'UNE BOUCLE: (A6=NOUVEAU CHRGET)
sorbcle:  move.w nboucle,d0   ;nombre total de boucles
          move.l tstbcle,a0   ;commencement des tests
          move.w tstnbcle,d1  ;numero du debut
          cmp d1,d0           ;pas de nouvelle boucle depuis le gosub?
          beq.s gt5
gt2:      tst.w -2(a0)        ;Type
          beq.s gt3
          move #14,d2         ;while/wend ou repeat/until
          bra.s gt4
gt3:      move #38,d2         ;for/next
gt4:      cmp.l -6(a0),a6     ;FIN
          bhi.s gt7
          cmp.l -10(a0),a6    ;DEBUT
          bcs.s gt7
          sub d2,a0           ;passe a la boucle suivante
          addq #1,d1
          cmp d1,d0           ;encore une boucle??
          bne.s gt2
gt5:      rts
;sorti d'une boucle
gt7:      move.l a0,posbcle   ;arrete TOUTES les boucles au
          move d1,nboucle     ;dessus de celle ci
          rts

; GOSUB
gosub:    tst runflg          ;pas de gosub en mode direct!!!
          beq illdir
          move a6,d0          ;rend pair
          btst #0,d0
          beq.s gsb1
          addq.l #1,a6
gsb1:     move.l (a6)+,d0     ;prend le numero
          bne.s gsb2
          move.l a6,-(sp)
          clr gotovar         ;flag VARIABLE a zero
          bsr expentier       ;recupere le numero dans d3
          bsr findrun         ;va chercher la ligne en a0
          move.l (sp)+,a1
          move.l a0,d0
          tst gotovar         ;si il y a une variable dans l'expression,
          bne.s gsb3            ;on ne stocke pas!
          move.l a6,d1
          sub.l a1,d1         ;longueur de l'expression
          and.l #$ff,d1
          ror.l #8,d1
          or.l d1,d0
          move.l d0,-4(a1)    ;stocke dans le source
; deja passe dessus
gsb2:     clr d1
          move.b -4(a6),d1
          add d1,a6           ;saute l'expression
gsb3:     move.l posgsb,a1
          cmp.l #maxgsb,a1
          bcs toogsb          ;too many gosub
          move.l tstbcle,-(a1)          ;position des boucles
          move.w tstnbcle,-(a1)         ;nombre de boucles
          move.l posbcle,tstbcle        ;monte les pointeurs!!!!!!
          move.w nboucle,tstnbcle
          move.l a5,-(a1)               ;ligne actuelle pour le return
          move.l a6,-(a1)               ;chrget pour le return
          move.l a1,posgsb    ;change le pointeur
          and.l #$00ffffff,d0 ;efface la longueur de l'expression
          move.l d0,a5
          lea 4(a5),a6        ;change le chrget et ligne act
          rts                 ;et se rebranche au chrget

; RETURN
retourne: move.l posgsb,a0
          cmp.l #bufgsb,a0
          beq retgsb          ;return without gosub error
          move.l (a0)+,a6     ;recupere le chrget
          move.l (a0)+,a5     ;ligne actuelle
pop2:     move.w (a0)+,tstnbcle
          move.l (a0)+,tstbcle ;remet les boucles comme avant
          move.l a0,posgsb    ;change le pointeur
          bra sorbcle         ;sort des boucles entamees et va au chrget

; POP
pop:      move.l posgsb,a0
          cmp.l #bufgsb,a0
          beq popgsb          ;pop without gosub error
          addq.l #8,a0        ;saute chrget/ligneact
          bra.s pop2

; ON xx GOTO / ON xx GOSUB
on:       cmp.b #$a0,(a6)     ;on MENU ?
          bne.s ona
          cmp.b #$81,1(a6)
          beq onmenu
ona:      bsr expentier       ;va chercher la variable
          move.b (a6)+,d1
          cmp.b #$98,d1
          beq.s on0
          cmp.b #$99,d1
          bne syntax
on0:      move.w d1,-(sp)     ;pour plus tard
          move a6,d0
          btst #0,d0          ;rend pair
          beq.s on1
          addq.l #1,a6
; trouve le bon numero a prendre
on1:      move.l (a6)+,d4
          bne on10
; pas encore passe dessus!!!
          move.l d3,-(sp)     ;pour plus tard!!!
          move.l a6,a0        ;cherche la fin de l'instruction
          move.b #":",d0
          move.b d0,d1
          bsr ftoken
          move.l a1,d4        ;adresse de la fin de l'instruction
          move.b #",",d0
          move.b d0,d1
          move.l a6,a0
          moveq #1,d5
on2:      bsr ftoken
          beq.s on3
          addq #1,d5          ;et un numero de plus!
          cmp.l d4,a0         ;a-t-on depasse la fin de l'instruction??
          bcs.s on2
on3:      ror.l #8,d5
          or.l d5,d4          ;le flag est fabrique!
          move.l d4,-4(a6)    ;le poke!
          move.l (sp)+,d3     ;recupere le chiffre
; deja passe dessus: trouve le bon chiffre ou passe a l'instruction suivante
on10:     clr.l d0
          move.b -4(a6),d0
          cmp.b d0,d3
          bhi.s on4
          tst.l d3
          bne.s on9
; instruction suivante!!!
on4:      addq.l #2,sp        ;pile a l'etat normal
          and.l #$00ffffff,d4 ;change le chrget
          move.l d4,a6        ;et instruction suivante!
          rts
; compte et trouve le branchement
on9:      move.l a6,a0
          and.l #$00ffffff,d4
          move.l d4,-(sp)     ;adresse apres l'instruction, pour plus tard
          move.b #",",d0
          move.b d0,d1
          move.l d3,d4
on5:      subq.l #1,d4
          beq.s on6
          bsr ftoken
          beq syntax          ;impossible, mais securite!
          bra.s on5
on6:      move.l a0,a6        ;change le chrget
          bsr expentier       ;va chercher l'expression
          bsr findrun         ;va chercher la ligne en question-->a0
          move.l a0,d0
          move.l (sp)+,a6     ;saute l'instruction
          move.w (sp)+,d1     ;recupere le token goto/gosub
          cmp.b #$98,d1
          beq gotobis         ;on xx goto...
          bra gsb3            ;on xx gosub...

; ON MENU ON / ON MENU OFF / ON MENU GOTO XX,YY...
onmenu:   addq.l #2,a6        ;saute MENU
          bsr onoff
          bmi.s onmn2
          bne.s onmn1
          bset #7,mnd+98     ;ON MENU OFF
          move.l (sp)+,a0
          lea pile,sp         ;restore la pile (BUGBUGBUG)
          jmp (a0)
onmn1:    bclr #7,mnd+98     ;ON MENU ON
          move.l (sp)+,a0
          lea pile,sp         ;restore la pile (BUGBUGBUG)
          jmp (a0)
onmn2:    cmp.b #$98,(a6)+    ;veut un GOTO
          bne syntax
          move a6,d0
          btst #0,d0          ;saute le flag!
          beq.s onmn2a
          addq.l #1,a6
onmn2a:   addq.l #4,a6
          moveq #9,d1
          lea mnd+100,a1
onmn3:    clr.l (a1)+
          dbra d1,onmn3
          moveq #9,d1
          lea mnd+100,a1
onmn4:    movem.l d1/a1,-(sp)
          bsr expentier
          bsr findrun
          movem.l (sp)+,d1/a1
          move.l a0,(a1)+
          cmp.b #",",(a6)
          bne.s onmn5
          addq.l #1,a6
          dbra d1,onmn4
onmn5:    move #1,mnd+98     ;ON MENU ON!
          rts

; IF/THEN/ELSE
if:       bsr expentier       ;ramene VRAI ou FAUX en entier
; cherche le THEN
          cmp.b #$9a,(a6)+
          bne syntax
          move a6,d0          ;rend pair
          btst #0,d0
          beq.s if1
          addq.l #1,a6
if1:      move.l (a6),d0
          tst.l d3
          beq.s if5
; CONDITION VRAIE
then:     and.l #$00ffffff,d0
          bne gotobis         ;effectue le GOTO
;pas encore passe dessus!
if2:      move.b 4(a6),d1
          beq syntax
          addq.l #4,a6
          cmp.b #$fd,d1       ;si pas un numero apres le THEN: 
          bcs gt5             ;on se rebranche au CHRGET (rts)
;numero de ligne pas encore calcule
          pea -4(a6)
          bsr opentier        ;va chercher le numero de ligne
          bsr findrun         ;trouve l'adresse dans le listing
          move.l (sp)+,a1     ;recupere l'adresse du flag
          move.l a0,d0
          or.l d0,(a1)
          bra gotobis         ;effectue le GOTO
; CONDITION FAUSSE
if5:      rol.l #8,d0
          tst.b d0
          beq.s if6
;on est deja passe dessus!
          cmp.b #1,d0         ;pas de ELSE--->ligne suivante!
          beq else
          and #$00ff,d0
          add d0,a6           ;pointe le flag du ELSE
          bsr sorbcle         ;sort-on d'une boucle?
          move.l (a6),d0
          bra then            ;traite le ELSE comme le THEN
;ON EST PAS ENCORE PASSE DESSUS: chercher le bon ELSE
if6:      move.l a6,a0
          addq.l #4,a0
          move #1,cptnext
if7:      move.b #$9a,d0      ;token de THEN
          move.b #$9b,d1      ;token de ELSE
          bsr ftoken          ;cherche le token dans la ligne
          beq.s if9
          bmi.s if8
; a trouve un THEN
          add #1,cptnext
          bra.s if7
; a trouve un ELSE
if8:      sub #1,cptnext
          bne.s if7
; a trouve le bon ELSE
          subq.l #4,a0        ;pointe le flag du ELSE
          move.l a0,d0
          sub.l a6,d0         ;calcule la difference THEN/ELSE
          cmp.w #$100,d0
          bcs.s ifb           ;si la taille de la ligne est > $100
          clr.b d0            ;ne poke rien!
ifb:      move.b d0,(a6)      ;poke le flag=distance THEN au ELSE: SUPER!
          move.l a0,a6
          bsr sorbcle         ;sort-on d'une boucle?
          move.l (a6),d0
          bra then            ;traite le ELSE comme le THEN
; y'a pas de ELSE
if9:      move.b #1,(a6)      ;flag: PAS DE ELSE, et ligne suivante!

; ELSE:
else:     tst runflg          ;en mode direct
          beq ok              ;pas de ligne suivante!!!!!!!!!!!!
          move.l a5,a6
          add (a6),a6         ;fait un GOTO a la ligne suivante
          addq.l #4,a6
          bsr sorbcle
          addq.l #4,sp
          bra finligne

; FINDLIGNE POUR LE RUNTIME! BRANCHE DIRECTEMENT A UNDEF SI PAS DE LIGNE.
findrun:  tst.l d3
          bmi foncall
          cmp.l #$10000,d3    ;pas de # > 65535
          bcc undef
          tst d3              ;pas de # zero
          beq undef
          move.l dsource,a0
          bra.s fdr2
fdr1:     add (a0),a0
fdr2:     tst.w (a0)
          beq undef
          cmp.w 2(a0),d3
          bne.s fdr1
          rts

; SUPER FIND: CHERCHE UN TOKEN DANS LA SUITE DU PROGRAMME a partir de a0!
supfind:  bsr ftoken
          bne.s sf5
          tst runflg          ;si en mode DIRECT, ne cherche pas plus loin!
          beq.s sf5
          move.l oldfind,a0
          add (a0),a0
          tst.w (a0)
          beq.s sf5
          move.l a0,oldfind
          addq.l #4,a0
          bra supfind
sf5:      rts

; FIND TOKEN: CHERCHE UN TOKEN DANS LA LIGNE ACTUELLE
ftoken:   move.l a0,a1        ;ramene l'adresse juste en a1
          move.b (a0)+,d2     ;ramene l'adresse juste apres en a0!
          beq.s ft8           ;fin de la ligne
          bpl.s ft5
          cmp.b #$a0,d2       ;instruction etendue
          beq.s ft1a
          cmp.b #$b8,d2       ;fonction etendue
          beq.s ft1a
          cmp.b #$a8,d2       ;.EXT instruction
          beq.s ft1
          cmp.b #$c0,d2       ;.EXT fonction
          bne.s ft2
ft1:      addq.l #1,a0          
ft1a:     addq.l #1,a0
          bra.s ft5
ft2:      cmp.b #$fa,d2       ;variable ou constante?
          bcc.s ft3
          cmp.b #$98,d2
          bcs.s ft5
          cmp.b #$a0,d2
          bcc.s ft5
ft3:      move a0,d3          ;rend pair
          btst #0,d3
          beq.s ft4
          addq.l #1,a0
ft4:      cmp.b #$ff,d2
          bne.s ft4a
          addq.l #4,a0        ;constantes float sur huit octets!
ft4a:     cmp.b #$fc,d2
          bne.s ft0
          add.w 2(a0),a0      ;chaines alphanumerique! saute la chaine
ft0:      addq.l #4,a0        ;saute le flag
ft5:      cmp.b d2,d1
          beq.s ft7
          cmp.b d2,d0
          bne.s ftoken
ft6:      move #1,d2          ;trouve le premier
          rts
ft7:      move #-1,d2         ;trouve le second
          rts
ft8:      subq.l #1,a0        ;reste sur le zero!!!
          rts                 ;pas trouve!

; FOR/TO/STEP---- quelle merde!
for:      move a6,d0
          btst #0,d0
          beq.s for1
          addq.l #1,a6
for1:     move.l (a6)+,d0     ;le NEXT est deja trouve: SUPER!
          bne for10
;trouve le NEXT correspondant a ce FOR!
          move.b (a6),d0
          cmp.b #$fa,d0       ;il faut une variable apres un next
          bne syntax
          move.l a6,-(sp)     ;sauve l'adresse du CHRGET
          lea bufcalc,a3
          bsr fdavant
          move.l a1,-(sp)
          move.l a6,a0
          move #1,cptnext
          move.l a5,oldfind
for2:     move.b #$9d,d0
          move.b #$82,d1
          bsr supfind
          beq fornext         ;for without next error
          bmi.s for4
; a trouve un FOR
          move.b (a0),d0
          cmp.b #$fa,d0       ;si SYNTAX ERR: n'en tient pas compte
          bne.s for2
          move.l a0,a6
          lea bufcalc,a3
          bsr fdavant
          move.l a6,a0
          cmp.l (sp),a1
          bne.s for2
          add #1,cptnext
          bra.s for2
; a trouve un NEXT
for4:     move.l a1,a2        ;a1 pointe le NEXT
          move.b (a0),d0      ;si NEXT seul
          cmp.b #$fa,d0       ;ou erreur, decremente le compteur
          bne.s for5
          move.l a0,a6
          move.l a2,-(sp)
          lea bufcalc,a3
          bsr fdavant         ;va chercher la variable
          move.l (sp)+,a2
          move.l a6,a0
          cmp.l (sp),a1       ;compare la variable
          bne for2
for5:     sub #1,cptnext
          bne for2
          move.l a2,d0        ;d0 pointe le NEXT
          addq.l #4,sp
          move.l (sp)+,a6     ;a6 repointe le flag du FOR
          move.l d0,-4(a6)    ;poke dans le listing
; LE NEXT EST TROUVE
for10:    move.l d0,-(sp)
          move.l posbcle,d0
          sub.l #38,d0
          cmp.l #maxbcle,d0
          bcs outofmm
          addq.l #1,a6
          bsr let             ;initialise la variable! SUPER
          tst.b d5
          bmi typemis
          movem.l d5/a1,-(sp)
          cmp.b #$80,(a6)+    ;cherche le TO
          bne syntax
          bsr evalue
          movem.l (sp)+,d5/a1
          cmp.b d2,d5         ;egalise les types entre VAR et To
          beq for10b
          tst.b d2
          bmi typemis
          beq.s for10a
          bsr fltoint
          bra.s for10b
for10a:   bsr inttofl
for10b:   move.l a1,-(sp)     ;stocke l'adresse de la variable
          movem.l d2-d4,-(sp)
          move.b (a6),d0
          cmp.b #$81,d0       ;cherche un STEP
          bne.s for11
          addq.l #1,a6
          bsr evalue          ;va chercher le STEP
          bra.s for12
for11:    clr d2              ;STEP par defaut: 1
          move.l #1,d3
for12:    movem.l (sp)+,d5-d7
          cmp.b d2,d5         ;egalise les types entre TO et STEP
          beq for12b
          tst.b d2
          bmi typemis
          beq.s for12a
          bsr fltoint
          bra.s for12b
for12a:   bsr inttofl
for12b:   move.l posbcle,a0
          clr.w -(a0)            ;poke le type: 0 for/next
          move.l 4(sp),-(a0)     ;poke la fin
          move.b (a6),d0         ;saute le : apres le FOR
          beq.s for13
          cmp.b #":",d0          ;plus RAPIDE!!!
          bne.s for13
          addq.l #1,a6
for13:    move.l a6,-(a0)        ;poke le debut
          move.l a5,-(a0)        ;ligne actuelle
          movem.l d6-d7,-(a0)    ;poke la limite
          movem.l d2-d4,-(a0)    ;poke la step
          move.l himem,d0        ;haut des variables
          sub.l (sp)+,d0         ;adresse RELATIVE de la variable
          move.l d0,-(a0)        ;poke la variable
          addq.l #4,sp           ;saute la fin
          move.l a0,posbcle      ;pointeur de boucle
          add #1,nboucle         ;une boucle de plus!
          rts

; NEXT
next:     move tstnbcle,d0    ;si pas de nouvelle boucle
          cmp.w nboucle,d0    ;depuis le precedent GOSUB
          beq nextfor         ;Next without for!!!
          move.l posbcle,a2   ;prend la derniere boucle!!!
          subq.l #1,a6
          cmp.l 32(a2),a6     ;verifie le next
          bne nextfor
          tst 36(a2)          ;verifie la boucle
          bne nextfor
; on est sur le bon next!
          move.l himem,a1
          sub.l (a2)+,a1      ;depile la variable RELATIVE
          movem.l (a2)+,d2-d4 ;depile la step
          tst.b d2
          beq next1
; TRAVAILLE SUR FLOAT
          move.l (a1),d1      ;FLOAT
          move.l 4(a1),d2
          move.l a1,-(sp)
          move.l d3,d5        ;stocke pour plus tard
          clr d0
          trap #6             ;addition en float
          move.l (sp)+,a1
          move.l d0,(a1)
          move.l d1,4(a1)       ;stocke dans la memoire
          move.l d1,d2
          move.l d0,d1
	movem.l d1/d2,-(sp)
	move.w #$ff01,d0
	trap #6
	movem.l (sp)+,d1/d2
          tst d0                ;signe de la step?
          bpl.s nexta
          moveq #$13,d0         ;step negative
          bra.s nextb
nexta:    moveq #$11,d0         ;step positive
nextb:    movem.l (a2)+,d3-d4   ;depile la limite float
          trap #6
          tst d0
          beq.s next5           ;faux: on reste
          bra.s next10          ;vrai: on sort
; TRAVAILLE SUR ENTIERS
next1:    add.l d3,(a1)         ;ENTIER
          bvs overflow
          movem.l (a2)+,d6-d7   ;depile la limite
          tst.l d3
          bpl next3
; step negative: inferieur
next2:    cmp.l (a1),d6
          ble.s next5
          bra.s next10
; step positive: superieur
next3:    cmp.l (a1),d6
          blt.s next10
; ON RESTE DANS LA BOUCLE!
next5:    move.l (a2)+,a5
          move.l (a2),a6
          rts
; ON SORT DE LA BOUCLE!
next10:   add.l #38,posbcle   ;une boucle de moins!
          sub #1,nboucle
          addq.l #1,a6
          move.b (a6),d0
          cmp.b #$fa,d0
          bne.s next11
          lea bufcalc,a3
          bsr fdavant         ;saute la variable!!!
next11:   rts

; WHILE
while:    tst.w runflg
          beq illdir
          move a6,d0
          btst #0,d0
          beq.s wh1
          addq.l #1,a6
wh1:      move.l (a6)+,d0
          bne.s wh10
; premier passage sur le WHILE
          move.l a6,a0
          move.l a5,oldfind
          move #1,cptnext
wh2:      move.b #$9e,d0                ;token de while
          move.b #$83,d1                ;token de wend
          bsr supfind
          beq whilewend       ;while without wend error
          bmi.s wh5
; a trouve un while
          add #1,cptnext
          bra.s wh2
; a trouve un wend
wh5:      sub #1,cptnext
          bne.s wh2
; a trouve le bon wend
          move.l a1,-4(a6)    ;poke l'adresse du wend dans le source
          move.l a1,d0
; initialisation du while
wh10:     move.l posbcle,d1
          move.l d1,a2
          sub.l #14,d1
          cmp.l #maxbcle,d1
          bcs outofmm
          move #1,-(a2)       ;poke le type: 1=while/wend
          move.l d0,-(a2)     ;poke la fin
          move.l a6,-(a2)     ;poke le debut
          move.l a5,-(a2)     ;poke la ligne actuelle
          move.l a2,posbcle
          add #1,nboucle      ;une boucle de plus!
; branchement au WEND! super!
          move.l a5,a0        ;trouve la bonne ligneact du WEND
wh11:     move.l a0,a1
          add (a0),a0
          cmp.l a0,d0
          bcc.s wh11
          move.l a1,a5        ;change la ligne actuelle
          move.l d0,a6        ;changement du chrget: pointe le WEND
          rts

; WEND
wend:     move.w tstnbcle,d0
          cmp.w nboucle,d0
          beq wendwhile       ;while without next error
          move.l posbcle,a2
          subq.l #1,a6
          cmp.l 8(a2),a6      ;verifie que c'est le bon wend
          bne wendwhile
          cmp #1,12(a2)       ;verifie qu'il s'agit bien d'une boucle while
          bne wendwhile
; on est bien dans la bonne boucle!
          addq.l #1,a6
          move.l a6,-(sp)     ;sauve le chrget
          move.l 4(a2),a6     ;pointe l'expression
          bsr expentier       ;ramene une expression entiere!
          tst.l d3
          beq.s we2
; expression vraie: on reste dans la boucle
          addq.l #4,sp        ;depile l'adresse apres le wend
          move.l posbcle,a2
          move.l (a2),a5
          rts
; expression fausse: on sort de la boucle
we2:      add.l #14,posbcle
          sub #1,nboucle      ;une boucle de moins!
          move.l (sp)+,a6     ;pointe apres le wend
          rts

; REPEAT
repeat:   move a6,d0
          btst #0,d0
          beq.s rp1
          addq.l #1,a6
rp1:      move.l (a6)+,d0
          bne.s rp10
; pas encore passe sur le repeat
          move.l a6,a0
          move.l a5,oldfind
          move #1,cptnext
rp2:      move.b #$9f,d0      ;token de repeat
          move.b #$84,d1      ;token de until
          bsr supfind
          beq repuntil        ;repeat without until error
          bmi.s rp5
; a trouve un repeat
          add #1,cptnext
          bra.s rp2
; a trouve un until
rp5:      sub #1,cptnext
          bne.s rp2
; a trouve le bon until
          move.l a1,-4(a6)    ;poke l'adresse du until dans le source
          move.l a1,d0
; initialisation du repeat
rp10:     move.l posbcle,d1
          move.l d1,a2
          sub.l #14,d1
          cmp.l #maxbcle,d1
          bcs outofmm
          move #2,-(a2)       ;poke le type: 2=repeat/until
          move.l d0,-(a2)     ;poke la fin
          move.b (a6),d0      ;saute un : apres le repeat! super!
          beq.s rp11
          cmp.b #":",d0
          bne.s rp11
          addq.l #1,a6
rp11:     move.l a6,-(a2)     ;poke le debut
          move.l a5,-(a2)     ;poke la ligne actuelle
          move.l a2,posbcle
          add #1,nboucle      ;une boucle de plus!
          rts

; UNTIL
until:    move.w tstnbcle,d0
          cmp.w nboucle,d0
          beq unrepeat        ;until without repeat error!
          subq.l #1,a6
          move.l posbcle,a2
          cmp.l 8(a2),a6      ;verifie le niveau du UNTIL
          bne unrepeat
          cmp #2,12(a2)       ;verification de securite!
          bne unrepeat
; on est dans le bon until!
          addq.l #1,a6
          bsr expentier       ;va evaluer l'expression
          tst.l d3
          bne.s unt1
; l'expression est fausse: on reste dans la boucle
          move.l posbcle,a2
          move.l (a2)+,a5
          move.l (a2),a6
          rts
; l'expression est vraie: on sort de la boucle
unt1:     add.l #14,posbcle
          sub #1,nboucle      ;une boucle de moins et c'est tout!
          rts

;-----------------------------------------    --- ----- ---   ---    -------
;   -----------------------------------      |      |  |   | |
;  |         ENTREE DE DONNEES         |      ---   |  |   |  ---
;   -----------------------------------          |  |  |   |     |
;-----------------------------------------    ---       ---   ---    -------
; CLIK ON / CLIK OFF: bruit des touches
clik:     bsr onoff
          bmi syntax
          bne.s clik1
          move.b #3,bip
          rts
clik1:    clr.b bip
          rts

; KEYFNC: ENTREE KEY OFF/KEY ON/KEY (XX)
keyfnc:   bsr onoff
          bmi keychg
          bne.s keyon
; KEY OFF: arret des touches de fonctions
          tst foncon
          beq.s kon1
          clr foncon
          bra.s kon0
; KEY ON: mise en route des touches de fonction
keyon:    tst foncon
          bne.s kon1
          move #1,foncon
kon0:     tst mnd+12         ;si barre de menu, pas besoin de reafficher!
          bne.s kon1
          bsr modebis
kon1:     rts
; KEY (XX)="dkjskjdksjkdjskjdkkj"
keychg:   lea bufcalc,a3
          bsr fentier
          tst.l d3
          beq foncall
          cmp.l #20,d3
          bhi foncall
          subq.l #1,d3
          mulu #40,d3
          add.l #buffonc,d3
          move.l d3,-(sp)
          cmp.b #$f1,(a6)+
          bne syntax
          bsr expalpha
          move.l (sp)+,a0
          tst d2
          beq.s kychg2
          cmp #38,d2
          bcs.s kychg1
          move #38,d2
kychg1:   move.b (a2)+,(a0)+
          subq #1,d2
          bne.s kychg1
kychg2:   clr.b (a0)
          bsr affonc          ;reaffiche les touches de fonction
          rts

; KEYfonc: RAMENE 1--->20 SI L'ON APPUIE SUR UNE TOUCHE DE FONCTION
fonkey:   jsr incle
          clr.b d2
          clr.l d3
          tst.l d0
          beq.s fonkey5
          swap d0
          move.b d0,d3
          cmp.b #59,d3
          bcs.s fonkey5
          cmp.b #69,d3
          bcc.s fonkey1
          sub.b #58,d3
          rts
fonkey1:  cmp.b #84,d3
          bcs.s fonkey5
          cmp.b #94,d3
          bcc.s fonkey5
          sub.b #73,d3
fonkey5:  rts

; KEY LIST: LISTE LES TOUCHES DE FONCTION
keylist:  lea foncnom,a1
          lea buffonc,a2
          move #19,d2
          move #1,d7
kylst1:   move.l a1,a0        ;numero de la touche
          trap #3
          move.l a2,a0        ;nom de la touche
          trap #3
          bsr retour
          bsr ttlist
          beq.s kylst3          ;pas d'appui
          bmi.s kylst4          ;appui sur ESC
kylst2:   bsr ttlist
          beq.s kylst2
          bmi.s kylst4
kylst3:   add #5,a1
          add #40,a2
          dbra d2,kylst1
kylst4:   rts

; RESTORE
restore:  move a6,d0
          btst #0,d0
          beq.s rest1
          addq.l #1,a6
rest1:    tst runflg          ;pas en mode direct
          beq illdir
          move.l (a6)+,d0
          bne.s rest10          ;deja passe dessus
; premier passage sur le restore
          bsr finie
          beq.s rest2
          clr gotovar
          move.l a6,-(sp)
          bsr expentier       ;va chercher le numero ensuite
          bsr findrun         ;ramene le numero de ligne
          move.l (sp)+,a1
          move.l a0,d0
          tst gotovar         ;si variable dans l'expression: recalcul
          bne.s rest11          ;chaque fois
          move.l a6,d1
          sub.l a1,d1         ;taille de l'expression
          and.l #$ff,d1
          ror.l #8,d1
          or.l d1,d0          ;flag pret!
          move.l a1,a6
          bra.s rest3
; pas de numero de ligne
rest2:    move.l datastart,d0
; poke dans le listing
rest3:    move.l d0,-4(a6)
; deja passe dessus!
rest10:   move.b -4(a6),d1
          and #$00ff,d1       ;saute l'expression
          add d1,a6
rest11:   and.l #$00ffffff,d0 ;efface la longueur de l'expression
          move.l d0,dataline  ;adresse de la ligne pointee
          move.l d0,a0
          cmp.w #$a0a6,4(a0)  ;cherche un DATA au debut de la ligne
          bne nodata
          addq.l #6,a0        ;pointe la premiere expression
          move.l a0,datad
          rts

; DATAS: passe a la ligne suivante!
data:     tst runflg
          beq illdir
          addq.l #4,sp
          bra finligne

; READ
read:     tst runflg
          beq illdir
read1:    cmp.b #$fa,(a6)+
          bne syntax
          lea bufcalc,a3
          bsr findvar         ;va chercher la variable
          movem.l d2/a1/a6,-(sp) ;stocke pour plus tard
          tst.l dataline
          beq outofdata
          move.l datad,a6
          move.b (a6),d0      ;autorise DATA 1,,25,,"dsk ",,
          cmp.b #",",d0
          bne.s read1b
          tst.b d2
          bmi.s read1a
          clr.l d3            ;variable nulle!
          clr.l d4
          bra.s read5
read1a:   move.l fsource,d3   ;chaine nulle!
          bra.s read5
read1b:   bsr evalue          ;va evaluer l'expression
          cmp.b #",",d0
          beq.s read5
          tst.b d0
          bne syntax
; cherche la ligne suivante de datas
          move.l dataline,a6  ;ligne des datas
read2:    add.w (a6),a6
          tst.w (a6)
          beq.s read3
          cmp.w #$a0a6,4(a6)  ;un data en debut de ligne
          bne.s read2
          beq.s read4
read3:    sub.l a6,a6         ;met un zero dans le pointeur
read4:    move.l a6,dataline
          addq.l #5,a6
read5:    addq.l #1,a6
          move.l a6,datad
; egalise le data
          movem.l (sp)+,d5/a1/a6
          bsr letbis          ;fait l'egalisation
; une autre variable a prendre?
          cmp.b #",",(a6)+
          beq read1
          subq.l #1,a6
          rts

; LINEINPUT [#xx,]a$ ou LINEINPUT "xxxxxxx";a$,b$
lineinput:clr inputype
          bra.s input0
; INPUT [#xx,]a$ ou INPUT #xx,a$
input:    move #",",inputype
input0:   clr orinput         ;origine de l'input
          move.b (a6)+,d0
          cmp.b #"#",d0
          beq inpdisk
          cmp.b #$fa,d0
          beq.s input2
          cmp.b #$fc,d0       ;chaine alphanumerique
          bne syntax
; input "xxxxxxxxxx";a$ ---> impression de la chaine
          bsr alpha           ;ramene la constante en d2/d3
          move.l d3,a2
          move (a2)+,d2
          beq.s input1b
          subq #1,d2
          clr d7
input1:   move.b (a2)+,d0
          trap #3
          dbra d2,input1
input1b:  cmp.b #";",(a6)+    ;un point virgule!!!
          bne syntax
          cmp.b #$fa,(a6)+    ;une variable!!!
          bne syntax
          bra.s i2b
; point d'interrogation
input2:   move.b #"?",d0
          clr d7
          trap #3
i2b:      move.b #255,d0
          clr d7
          trap #3

; INPUT AU CLAVIER, RAMENE UNE LIGNE (500 car) DANS LE BUFFER
input3:   clr d2              ;position du curseur
          lea buffer,a1
rtin0:    movem.l d2-d3/a1,-(sp)
          move #1,inputflg
          bsr key
          clr inputflg
          movem.l (sp)+,d2-d3/a1
          tst.b d1
          beq.s rtin15          ;code ascii direct
          bmi.s rtin20
; filtrage des mouvements du curseur
rtin1:    cmp.b #8,d0
          bne.s rtin0
          tst d2              ;backspace ?
          beq.s rtin0
          subq #1,d2
          clr.b 0(a1,d2.w)
          moveq #3,d0
          clr d7
          trap #3
          moveq #32,d0
          trap #3
          moveq #3,d0
          trap #3
          bra.s rtin0
; code ascii normal
rtin15:   cmp.w #255,d2       ;pas plus de 255 caracteres
          bcc.s rtin0
          move.b d0,0(a1,d2.w)
          addq #1,d2
          clr.b 0(a1,d2.w)
          clr d7
          trap #3             ;envoi a la trappe
          bra rtin0
; code special: seul accepte=return
rtin20:   cmp.b #$80,d1
          bne rtin0
          clr.b 0(a1,d2.w)    ;un espace a la fin!
          bra input4

; INPUT #xx[,yy],: VA CHERCHER SUR LA DISQUETTE 
inpdisk:  move #1,orinput     ;vient du disque!
          clr flginp
          bsr getfile         ;va chercher le numero de fichier
          beq filnotop        ;file not opened
          clr.l d3
          cmp.b #$fa,(a6)
          beq.s inpda
          move.l a2,-(sp)
          bsr expentier
          move.l (sp)+,a2
          cmp.b #",",(a6)+
          bne syntax
          move #1,flginp
          move d3,chrinp
inpda:    cmp.b #$fa,(a6)+    ;veut une variable
          bne syntax
          move.l a2,oradinp
; reentree: re-remplis le buffer
inpd0:    move.l oradinp,a2   ;recupere la position du fichier
          move #511,d1        ;ne prend que 512 octets
          move inputype,d2
          move flginp,d3
          move chrinp,d4
          lea buffer,a3
inpd1:    bsr getbyte
          tst.b d2
          beq.s inpd1a
          cmp.b d2,d0         ;input normal: stop aux virgules
          beq.s inpd3
inpd1a:   tst.b d3            ;pas de caractere special: 13/10
          bne.s inpd1c
          cmp.b #13,d0        ;stop toujours a return
          beq.s inpd2
inpd1b:   move.b d0,(a3)+
          dbra d1,inpd1
          bra inptoolg        ;input too long!
inpd1c:   cmp.b d4,d0
          bne.s inpd1b
          bra.s inpd3
inpd2:    bsr getbyte         ;saute le #10 apres
inpd3:    clr.b (a3)

; INPUT ET LINEINPUT: INTERPRETE LE BUFFER CHARGE
input4:   lea buffer,a2
          lea bufcalc,a3      ;important si variables tableau!!!
          clr parenth
input4a:  move.l a2,-(sp)
          bsr findvar         ;va chercher la variable!
          move.l (sp)+,a2
          movem.l d2/a1,-(sp)
          tst.b d2
          bpl input10
; variable alphanumerique
          move.l #500,d3
          bsr demande
          addq.l #2,a0        ;place pour la taille
          clr d1
          move inputype,d4
input5:   move.b (a2)+,d0
          beq.s input6
          cmp.b d0,d4
          beq.s input6
          addq #1,d1
          move.b d0,(a0)+
          bra.s input5
input6:   subq.l #1,a2        ;reste sur le dernier caractere
          move.w d1,(a1)      ;poke la longueur
          move a0,d0
          btst #0,d0
          beq.s input7
          addq.l #1,a0
input7:   move.l a0,hichaine
          movem.l (sp)+,d0/a0
          move.l a1,(a0)      ;egalisation de la variable!
          bra input15
; variable numerique
input10:  move.l a6,-(sp)
          move.l a2,a6
          bsr valprg
          move.l a6,a2
          move.l (sp)+,a6
          movem.l (sp)+,d5/a1
          clr d0
          move.b (a2),d0
          beq.s input11
          cmp inputype,d0
          bne.s input12
input11:  bsr letbis          ;fait l'egalisation
          bra.s input15
; redo from start
input12:  tst orinput         ;type mismatch
          bne typemis
          lea redofrom,a0
          bsr traduit         ;va traduire
          move #1,d7
          trap #3             ;affichage du message
          move.l a4,a6        ;chrget au debut de l'input
          addq.l #1,a6        ;c'est une routine etendue: double token!!!
          tst inputype
          beq lineinput
          bne input
; passage a la variable suivante
input15:  move.b (a6)+,d0
          cmp.b #",",d0       ;encore une variable a prendre?
          bne input20
          cmp.b #$fa,(a6)+
          bne syntax
          cmp.b #",",(a2)+    ;encore une variable disponible
          beq input4a
; ??
input16:  tst orinput         ;si vient du disque: n'ecris rien
          bne inpd0
          lea encore,a0       ;affiche deux points d'interrogation
          move #1,d7
          trap #3
          bra input3          ;va retester le clavier
; fini!
input20:  tst.b d0
          beq.s input21
          cmp.b #":",d0
          beq.s input22
          cmp.b #$9b,d0       ;ELSE?
          beq.s input22
          cmp.b #";",d0
          beq.s input23
          bne syntax
input21:  subq.l #1,a6
input22:  tst orinput         ;pas de RETURN si vient du disque
          bne.s input23
          bsr retour
input23:  rts

; INKEY$
inkey:    bsr incle           ;ramene le caractere en d0.l
          tst.l d0
          beq.s ik1
          move d0,d2
          swap d0
          move d0,scankey     ;poke le scan-code
          bra chhr1           ;va creer la chaine de retour!
ik1:      clr scankey         ;pas de touche disponible
          move.l fsource,d3
          move.b #$80,d2
          rts

; SCANCODE
scancode: clr.l d3
          move scankey,d3
          clr.b d2
          rts

; INPUT$ (xx): ou INPUT$ (#xx,yy): saisit xx caracteres au clavier/disque
inputn:   cmp.b #"(",(a6)+
          bne syntax
          cmp.b #"#",(a6)
          bne.s in0
          addq.l #1,a6
in0:      bsr getentier
          cmp #1,d0
          beq inz
          cmp #2,d0
          bne syntax
; INPUT$ (#xx,nn): prend dans un fichier
          move.l d2,-(sp)
          move.l d1,d3
          bsr getf2           ;ramene l'adresse du fichier
          beq filnotop
          cmp #5,d0
          beq.s ine
; rs232 ou midi: prend octet par octet
          move.l (sp)+,d3     ;entree rs232, ou midi
          bmi foncall
          beq mid9
          cmp.l #$fff0,d3
          bcc stoolong
          bsr demande
          move d3,(a0)+       ;poke la longueur
ind:      bsr getbyte
          move.b d0,(a0)+
          subq.l #1,d3
          bne.s ind
          bra mid7a
; disque: prend rapidement!
ine:      move.l fhl(a2),d2
          bsr pfile
          sub.l d0,d2
          bcs eofmet          ;le fichier est fini!
          beq eofmet
          move.l (sp)+,d3
          bmi foncall
          beq mid9
          cmp.l #$fff0,d3
          bcc stoolong
          cmp.l d2,d3
          bls.s inq
          move.l d2,d3        ;trop grand: ne prend que ce qu'il faut
inq:      bsr demande
          move.l a1,-(sp)
          move d3,(a0)+
          move.l a0,-(sp)
          move.l d3,-(sp)
          move.w fha(a2),-(sp)
          move.w #$3f,-(sp)
          trap #1
          add.l #12,sp
          tst.l d0
          bmi diskerr
          move.l (sp)+,a1
          move.l a1,a0
          addq.l #2,a0
          add.l d3,a0
          bra mid7a           ;va fermer la variable
; input$ (xx): prend au clavier
inz:      move.l d1,d3
          tst.l d3            ;ramene une chaine vide
          bmi foncall
          beq mid9
          cmp.l #$fff0,d3
          bcc stoolong
          bsr demande         ;demande xx caracteres
          move d3,(a0)+       ;poke la longueur
          subq #1,d3
in1:      movem.l a0/a1/d3,-(sp)
          move #1,inputflg
          bsr key
          clr inputflg
          movem.l (sp)+,a0/a1/d3
          tst.b d1            ;n'accepte que les caracteres ASCII
          bmi.s in2
          beq.s in2
          cmp #32,d1
          bcs.s in1
          move d1,d0
in2:      move.b d0,(a0)+
          dbra d3,in1
          bra mid7a

; CLEARKEY: vide le buffer du clavier
clearkey: bsr incle
          tst.l d0
          bne clearkey
          clr fonction        ;plus de touche de fonction!
          rts

; PUT KEY a$: met une chaine dans le buffer TOUCHES DE FONCTION !!!GENIAL!!!
putkey:   bsr expalpha
          cmp #63,d2          ;pas plus de 63 caracteres!!!
          bcc foncall
          subq #1,d2          ;chaine vide!
          bcs.s putk3
          lea 40*20+buffonc,a0
putk1:    move.b (a2)+,d0     ;filtre les codes de fonction
          cmp.b #32,d0
          bcc.s putk2
          move.b #32,d0
putk2:    move.b d0,(a0)+
          dbra d2,putk1
          clr.b (a0)
          move.w #40*20+1,fonction
putk3:    rts

;-----------------------------------------    --- ----- ---   ---    -------
;   -----------------------------------      |      |  |   | |
;  |      CHAINES ALPHANUMERIQUES      |      ---   |  |   |  ---
;   -----------------------------------          |  |  |   |     |
;-----------------------------------------    ---       ---   ---    -------
;-------------------------------> Fait le menage ! VITE ! 
menage:	movem.l d0-d7/a0-a6,-(sp)

        	move.l #BMenage,d5          	  ;Debut TI
        	move.l d5,d6	
	add.l #63*8,d6                  ;Fin TI
	move.l fsource,d7               ;Ad mini de recopie
	addq.l #2,d7		  ;Chaine vide
	move.l d7,a1		  ;Si ya pas de variable!
	move.l himem,a5

Men0:   	move.l lowvar,a6                ;Debut des variables
        	moveq #-1,d2                    ;Maxi dans le tableau
        	moveq #0,d4                     ;Cpt tableau---> 0
        	move.l d5,d3                    ;Rien dans la TI
        	move.l d3,a0
        	move.l #$ffffff,(a0)
; Rempli la table intermediaire
Men1:  	cmp.l a5,a6
	bcc Men20
	move.b (a6)+,d0
	bne.s Men1a
	move.b (a6)+,d0
Men1a:	move.b d0,d1
	and.w #$1f,d1
	add.w d1,a6
	tst.b d0
	bmi.s Men2
; Pas une variable alphanumerique
	btst #5,d0
	bne.s Men1b
	addq.l #4,a6
	btst #6,d0
	beq.s Men1
	addq.l #4,a6
	bra.s Men1
Men1b:	add.l (a6),a6
	bra.s Men1
; Variable alphanumerique
Men2:	btst #5,d0
	beq.s Men4
	addq.l #4,a6
	move.w (a6)+,d0
	subq.w #1,d0
	moveq #1,d4
Men2a:	move.w (a6)+,d1		;Calcule nombre de variable
	addq.l #1,d1
	mulu d1,d4
	dbra d0,Men2a
Men3:	subq.l #1,d4
Men4:	move.l a6,a3
	addq.l #4,a6
; Essai de poker dans la TI
Men5:     move.l (a3),d0
          cmp.l d7,d0                     ;< au minimum?
          bcs.s Men10
          cmp.l d2,d0                     ;>= au maximum?
          bcc.s Men10
          move.l d5,a0
Men6:     cmp.l (a0),d0
          lea 8(a0),a0
          bcc.s Men6
          cmp.l d6,a0
          bne.s Men7
          move.l d0,d2                    ;C'est le dernier element!
          move.l d6,d3
          bra.s Men9
Men7:     move.l d3,a1                    ;Decale les adresses au dessus
          cmp.l d6,d3
          bcs.s Men7a
          lea -8(a1),a1
          move.l -8(a1),d2                ;Remonte la limite haute
          bra.s Men8 
Men7a:    addq.l #8,d3
          move.l #$ffffff,8(a1)
Men8:     move.l -(a1),8(a1)
          move.l -(a1),8(a1)
          cmp.l a0,a1
          bcc.s Men8
Men9:     move.l a3,-(a0)                 ;Poke dans la table
          move.l d0,-(a0) 
Men10:    tst.l d4
          bne.s Men3
          beq Men1

; Recopie toutes les chaines du buffer
Men20:    move.l d5,a3                    ;Adresse TI
          move.l d7,a1                    ;Adresse de recopie
          moveq #0,d7
Men21:    cmp.l d3,a3                     ;Fini-ni?
          bcc.s Men26 
          move.l (a3),a0                  ;Adresse de la chaine
          lea 8(a3),a3
          cmp.l a0,d7                     ;Chaine deja bougee?
          beq.s Men25
          move.l a0,d7
          cmp.l a0,a1                     ;Au meme endroit?
          bne.s Men22
; Les 2 chaines sont au meme endroit!
          move.l a1,d1
	moveq #0,d0
          move.w (a1)+,d0
	add.l d0,a1
          move.w a1,d0
          btst #0,d0
          beq.s Men21
          addq.l #1,a1
          bra.s Men21
; Recopie la chaine
Men22:    move.l -4(a3),a2                ;Change la variable
          move.l a1,(a2)
          move.l a1,d1
          move.w (a0)+,d0                 ;Recopie la chaine
          beq.s Men24
          move.w d0,(a1)+
          subq.w #1,d0 
          lsr.w #1,d0
Men23:    move.w (a0)+,(a1)+
          dbra d0,Men23
          bra.s Men21
; Chaine vide au milieu: pointe la vraie
Men24:    move.l fsource,d1
          move.l d1,(a2)
          bra.s Men21
; La variable pointait la meme chaine que la precedente
Men25:    move.l -4(a3),a2
          move.l d1,(a2)
          bra.s Men21
; Est-ce completement fini?
Men26:    cmp.l d6,d3                     ;Buffer TI rempli?
          bcs.s FinMen                    ;NON---> c'est fini!

;-----> Reexplore les variables a la recherche de la DERNIERE CHAINE
          move.l lowvar,a6                ;Table des ad strings
          moveq #0,d4                     ;Cpt tableau---> 0
	move.l d1,d2		  ;Feneant!
; Rempli la table intermediaire
Men31:  	cmp.l a5,a6
	bcc.s Men40
	move.b (a6)+,d0
	bne.s Men31a
	move.b (a6)+,d0
Men31a:	move.b d0,d1
	and.w #$1f,d1
	add.w d1,a6
	tst.b d0
	bmi.s Men32
; Pas une variable alphanumerique
	btst #5,d0
	bne.s Men31b
	addq.l #4,a6
	btst #6,d0
	beq.s Men31
	addq.l #4,a6
	bra.s Men31
Men31b:	add.l (a6),a6
	bra.s Men31
; Variable alphanumerique
Men32:	btst #5,d0
	beq.s Men34
	addq.l #4,a6
	move.w (a6)+,d0
	subq.w #1,d0
	moveq #1,d4
Men32a:	move.w (a6)+,d1		;Calcule nombre de variable
	addq.l #1,d1
	mulu d1,d4
	dbra d0,Men32a
Men33:	subq.l #1,d4
Men34:	move.l a6,a3
	addq.l #4,a6
; La variable pointe elle la meme chaine?
Men35:    cmp.l (a3),d7
          beq.s Men36
          tst.l d4
          bne.s Men33
          beq.s Men31
Men36:    move.l d2,(a3)
          tst.l d4
          bne.s Men33
          beq.s Men31

;-----> Refait un tour!
Men40:    move.l a1,d7                    ;Monte la limite <
          bra Men0

;-----> Menage fini!
FinMen:   move.l a1,hichaine
          movem.l (sp)+,d0-d7/a0-a6
	cmp.l hichaine,d0
	bcs outofmm
          rts

; DEMANDE une certaine place pour le traitement des chaines, si revient, OK!
demande:  move.l lowvar,d0
          move.l hichaine,a1  ;au retour, a1 contient hichaine
          move.l a1,a0
          sub.l d3,d0
          subq.l #4,d0        ;4 octets de securite (pour la longueur)
          cmp.l a1,d0
          bcs.s dem1
          rts
dem1:     bsr menage          ;recommence l'evaluation depuis le debut!
          move.l a4,a6
          subq.l #1,a6
          lea pile-8,sp       ;niveau de la pile au CHRGET, a verifier!
          bra chrget

; ROUTINE COMMUNE LEFT$/RIGHT$/MID$ EN INSTRUCTIONS
comm1:    lea bufcalc,a3
          cmp.b #"(",(a6)+
          bne syntax
          cmp.b #$fa,(a6)+
          bne syntax
          bsr findvar         ;va chercher la chaine en question
          tst.b d2
          bpl typemis
          clr.l d2
          move.l d3,a2
          move.w (a2)+,d2
          cmp.l fsource,a2    ;la chaine fait-elle partie du source?
          bcc.s cm3
          move.l a1,-(sp)
          moveq #0,d3
          move d2,d3
          bsr demande
          move.l (sp)+,a1     ;adresse de l'adresse!
          move.l a0,(a1)      ;change l'adresse de la chaine
          move.w d2,(a0)+
          movem.l d2/a0,-(sp) ;empile l'adresse de la chaine
          subq #1,d2
cm1:      move.b (a2)+,(a0)+  ;recopie la chaine ailleurs
          dbra d2,cm1
          move a0,d0
          btst #0,d0
          beq.s cm2
          addq.l #1,a0
cm2:      move.l a0,hichaine       
          bra.s cm4
cm3:      movem.l d2/a2,-(sp)
cm4:      cmp.b #",",(a6)+
          bne syntax
          bsr getentier
          movem.l d0-d2,-(sp)
          cmp.b #$f1,(a6)+    ;egal
          bne syntax
          bsr expalpha
          movem.l (sp)+,d4-d6
          movem.l (sp)+,d3/a3
          rts

; RAMENE D0(1-3) OPERANDES ENTIERS, EXPRESSION FINIE PAR ")"
getentier:move.w parenth,-(sp)
          clr d0
          clr parenth
gtent1:   cmp #3,d0
          bhi syntax
          move d0,-(sp)
          bsr evalbis
          tst.b d2
          beq.s gtent0
          bmi typemis
          bsr fltoint         ;conversion float--->entier
gtent0:   move (sp)+,d0
gtent2:   move.l d3,-(sp)
          addq #1,d0
          tst parenth
          bne.s gtent3
          cmp.b #",",(a6)+
          beq.s gtent1
          bra syntax
gtent3:   cmp #-1,parenth
          bne syntax
          cmp #1,d0
          beq.s gtent5
          cmp #2,d0
          beq.s gtent4
          move.l (sp)+,d3
gtent4:   move.l (sp)+,d2
gtent5:   move.l (sp)+,d1
          move.w (sp)+,parenth
          rts

; DENTIER: RAMENE DEUX ENTIERS SEPARES PAR UNE VIRGULE D'UNE INSTRUCTION
dentier:  bsr expentier
          move.l d3,-(sp)
          cmp.b #",",(a6)+
          bne syntax
          bsr expentier
          move.l (sp)+,d4
          rts

; LEFT$ EN INSTRUCTION
leftinst: bsr comm1
          cmp #1,d4           ;un seul operande!
          bne syntax
          move.l d5,d6
          clr.l d5
          bra mdst1

; RIGHT$ EN INSTRUCTION
rightinst:bsr comm1
          cmp #1,d4
          bne syntax
          move.l d5,d6        ;nombre de caracteres
          bmi syntax
          clr.l d5
          cmp.l d3,d6
          bcc.s rghinst
          move.l d3,d5
rghinst:  sub.l d6,d5
          addq.l #1,d5
          bra mdst1

; MID$ EN INSTRUCTION
midinst:  bsr comm1
          cmp #2,d4
          beq.s mdst1
          cmp #1,d4
          bne syntax
          move.l #$ffff,d6    ;si pas de dernier operateur: prend -> fin
mdst1:    tst.l d5
          bmi foncall
          beq.s mdst2
          subq.l #1,d5
mdst2:    add.l d5,a3         ;situe dans la chaine a changer
          cmp.l d3,d5
          bcc.s mdst10          ;trop loin: ne change rien
          tst.l d6
          bmi foncall         ;on prend zero caracteres: rien!
          beq.s mdst10
          add.l d5,d6
          cmp.l d3,d6
          bls.s mdst3
          move.l d3,d6
mdst3:    sub.l d5,d6
          cmp.l d2,d6         ;limite par la taille de la chaine source
          bls.s mdst4
          move.l d2,d6
mdst4:    subq.l #1,d6        ;la chaine source est nulle!
          bmi.s mdst10
mdst5:    move.b (a2)+,(a3)+
          dbra d6,mdst5
mdst10:   rts

; TRANSFERT UNE CHAINE VERS LE BUFFER, AVEC UN ZERO A LA FIN
chverbuf: lea buffer,a0
chverbuf2:move.l a2,a1
          move d2,d0
          beq.s chv2
          subq #1,d0
          cmp #510,d0
          bcs.s chv1
          move #509,d0
chv1:     move.b (a1)+,(a0)+
          dbra d0,chv1
chv2:     clr.b (a0)+
          rts

; ROUTINE COMMUNE LEFT$/RIGHT$/MID$ EN FONCTIONS
comm2:    move.w parenth,-(sp)
          cmp.b #"(",(a6)+
          bne syntax
          clr parenth
          bsr alphabis        ;va chercher la chaine
          movem.l d2/a2,-(sp) ;empile la chaine
          cmp.b #",",(a6)+
          bne syntax
          bsr getentier
          move.l d1,d5
          move.l d2,d6
          movem.l (sp)+,d2/a2
          move.w (sp)+,parenth
          rts

; FENTIER: PREND L'ARGUMENT ENTIER DES FONCTIONS A UN SEUL PARAMETRE
fentier:  move.w parenth,-(sp)
          cmp.b #"(",(a6)+
          bne syntax
          move #1,parenth
          bsr entierbis
          move.w (sp)+,parenth
          rts

; FFLOAT: PREND L'ARGUMENT FLOAT DES FONCIONS A UN SEUL PARAMETRE
ffloat:   move.w parenth,-(sp)
          cmp.b #"(",(a6)+
          bne syntax
          move #1,parenth
          bsr floatbis
          move.w (sp)+,parenth
          rts

; FALPHA: PREND L'ARGUMENT ALPHA DES FONCTIONS A UN SEUL PARAMETRE
falpha:   move.w parenth,-(sp)
          cmp.b #"(",(a6)+
          bne syntax
          move #1,parenth
          bsr alphabis
          move.w (sp)+,parenth
          rts

; FARG: RAMENE L'ARGUMENT CHIFFRE DES FONCTIONS A UN SEUL PARAMETRE
farg:     move.w parenth,-(sp)
          cmp.b #"(",(a6)+
          bne syntax
          move #1,parenth
          bsr evalbis
          tst parenth
          bne syntax
          move.w (sp)+,parenth
          tst.b d2
          bmi typemis
          rts

; LEFT$
left:     bsr comm2
          cmp #1,d0
          bne syntax
          move.l d5,d6
          clr.l d5
          bra mid1

; RIGHT$
right:    bsr comm2
          cmp #1,d0           ;un seul parametre
          bne syntax
          move.l #$ffff,d6    ;jusqu'a la fin!
          tst.l d5
          bmi foncall
          cmp.l d2,d5
          bcs.s rght1
          move.l d2,d5
rght1:    neg.l d5
          add.l d2,d5
          addq.l #1,d5
          bra mid1

; MID$
mid:      bsr comm2
          cmp #2,d0
          beq.s mid1
          cmp #1,d0
          bne syntax
          move.l #$ffff,d6
mid1:     tst.l d5            ;pointe au milieu de la chaine
          bmi foncall
          beq.s mid2
          subq.l #1,d5
mid2:     add.l d5,a2
          cmp.l d2,d5         ;pas pointe trop loin??
          bcc.s mid9            ;si! chaine vide
mid3:     tst.l d6
          beq.s mid9
          bmi foncall
mid4:     add.l d5,d6
          cmp.l d2,d6
          bls.s mid5
          move.l d2,d6
mid5:     sub.l d5,d6
mid6:     move.l d6,d3
          bsr demande
          move d6,(a0)+       ;poke la longueur
          subq.l #1,d6
          bmi.s mid8
mid7:     move.b (a2)+,(a0)+
          dbra d6,mid7
mid7a:    move a0,d0          ;rend pair
          btst #0,d0
          beq.s mid8
          addq.l #1,a0
mid8:     move.l a0,hichaine
          move.l a1,d3
          move.b #$80,d2
          rts
mid9:     move.l fsource,d3   ;ramene la chaine vide
          move.b #$80,d2
          rts

; INSTR
instr:    move.w parenth,-(sp)
          cmp.b #"(",(a6)+
          bne syntax
          clr parenth
          bsr alphabis
          movem.l d2/a2,-(sp)
          cmp.b #",",(a6)+
          bne syntax
          bsr evalbis
          tst.b d2
          bpl typemis
          clr.l d2
          move.l d3,a2
          move (a2)+,d2
          tst parenth
          bne.s instr1
          cmp.b #",",(a6)+
          bne syntax
          movem.l d2/a2,-(sp)
          bsr getentier
          movem.l (sp)+,d2/a2
          cmp #1,d0
          bne syntax
          move.l d1,d4
          bra.s instr2
instr1:   cmp #-1,parenth
          bne syntax
          clr.l d4
instr2:   movem.l (sp)+,d1/a1
          tst.l d4
          bmi syntax
          move.w (sp)+,parenth

; INSTR FIND: trouve une sous chaine dans une chaine a partir de d4
instrfind:move.l a3,-(sp)
          tst.l d2
          beq.s instf11
          tst.l d4
          beq.s instf1
          subq.l #1,d4
instf1:   add.l d4,a1         ;situe dans la chaine
instf3:   clr d3
instf4:   move.l a2,a3
          addq #1,d4
          cmp d1,d4
          bhi.s instf11
          cmpm.b (a1)+,(a3)+
          bne.s instf4
          move.l a1,a0
          move d4,d0
instf5:   addq #1,d3
          cmp d2,d3
          bcc.s instf10
          addq #1,d0
          cmp d1,d0
          bhi.s instf11
          cmpm.b (a0)+,(a3)+
          beq.s instf5
          bra.s instf3
instf10:  move.l (sp)+,a3
          clr.b d2
          move.l d4,d3                  ;trouve!
          rts
instf11:  move.l (sp)+,a3               ;pas trouve!
          clr.b d2
          clr.l d3
          rts

; FLIP$: INVERSE LA CHAINE
flip:     move.w parenth,-(sp)
          addq.l #1,a6
          move #1,parenth
          bsr alphabis
          move.w (sp)+,parenth
          move.l d2,d3
          bsr demande
          move d2,(a0)+
          beq mid8
          add.l d2,a2
          subq #1,d2
flp1:     move.b -(a2),(a0)+
          dbra d2,flp1
          bra mid7a

; LEN: ramene la longueur d'une chaine
len:      bsr falpha
          move.l d2,d3
          clr.b d2
          rts

; SPACE$ (XX)
space:    bsr fentier         ;ramene UN entier pour fonction
          move.l d3,d5
          move.w #$2020,d1
          bra string2

; STRING$ ("a",10) ou STRING$(chr$(XX),10)
string:   bsr comm2           ;cherche une chaine et un entier
          cmp #1,d0
          bne syntax
          tst.l d2
          bne.s string1
          clr.l d3
          bra.s string2
string1:  move.b (a2),d1
          lsl #8,d1
          move.b (a2),d1
string2:  move.l d5,d3
          bmi foncall
          cmp.l #$fff0,d3
          bcc stoolong
          bsr demande
          move.w d3,(a0)+
          beq.s string4
          addq #1,d3
          lsr #1,d3
          subq #1,d3
string3:  move.w d1,(a0)+
          dbra d3,string3
string4:  move.l a0,hichaine
          move.l a1,d3
          move.b #$80,d2
          rts

; CHR$(XX)
chr:      bsr fentier
          cmp.l #$100,d3
          bcc foncall
          move d3,d2
chhr1:    lsl #8,d2
          move.l #1,d3
          bsr demande
          move.w #1,(a0)+
          move.w d2,(a0)+
          move.l a0,hichaine
          move.l a1,d3
          move.b #$80,d2
          rts

; ASC(A$)
asc:      bsr falpha
          clr.l d3
          tst.l d2
          beq.s asc1
          move.b (a2),d3
asc1:     clr.b d2
          rts

; BIN$
bin:      move.l #33,d3
          bra hexin
; HEX$
hex:      move.l #9,d3
hexin:    move.l d3,-(sp)
          cmp.b #"(",(a6)+
          bne syntax
          bsr getentier
          cmp #2,d0
          beq.s hx1
          cmp #1,d0
          bne syntax
          move.l #-1,d2
          bra.s hx2
hx1:      tst.l d2
          bmi foncall
hx2:      move.l (sp)+,d3
          bsr demande
          move.l a5,-(sp)
          move.l d1,d0
          exg d2,d3
          lea 2(a0),a5        ;laisse la place pour la longueur
          cmp #9,d2
          bne.s hx3
          bsr longascii
          bra.s hx4
hx3:      bsr longbin
hx4:      move.l a5,d0        ;rend pair
          btst #0,d0
          beq.s hx5
          addq.l #1,d0
hx5:      move.l d0,hichaine
          sub.l a1,a5
          subq.l #2,a5
          move a5,(a1)        ;poke la longueur
          move.l a1,d3
          move.b #$80,d2
          move.l (sp)+,a5
          rts

; STR$(XX)
str:      move.w parenth,-(sp)
          cmp.b #"(",(a6)+
          bne syntax
          move #1,parenth
          bsr evalbis
          tst parenth
          bne syntax
          move.w (sp)+,parenth
          tst.b d2
          bmi typemis
          beq.s str1
          move.l a5,-(sp)     ;conversion FLOAT--->ASCII
          movem.l d2-d4,-(sp)
          moveq #40,d3
          bsr demande         ;BUGBUGBUBUGBUGBUGBUGBUGBUGBUGBUGBUGBUG
          movem.l (sp)+,d2-d4
          lea 2(a0),a5
          move.l a1,-(sp)
          move fixflg,d0
          bsr strflasc
          move.l (sp)+,a1
          bra hx4
str1:     move.l d3,d2
          move.l #16,d3
          bsr demande
          move.l a5,-(sp)
          lea 2(a0),a5
          move.l d2,d0
          bsr longdec1        ;fait la conversion
          bra hx4

; VAL (A$): que c'est chiant!!!
val:      bsr falpha          ;va chercher la chaine
          tst d2
          beq.s val11
          bsr chverbuf        ;recopie la chaine dans le buffer
          move.l a6,-(sp)
          lea buffer,a6
          bsr valprg
          move.l (sp)+,a6
          rts
val11:    clr.b d2
          clr.l d3
          rts

; SOUS PROGRAMME UTILISE PAR VAL ET INPUT ET LA TOKENISATION
valprg:   move.l a6,-(sp)     ;sauve l'adresse du chiffre si erreur!
          movem.l d5/d6,-(sp) ;sauve pour la tokenisation
          clr d4              ;signe
; y-a-t'il un signe devant?
val1:     move.b (a6)+,d0     ;saute les espaces au debut
          beq val9
          cmp.b #32,d0
          beq.s val1
          move.l a6,a2        ;pointe le premier caractere non nul
          subq.l #1,a2
          cmp.b #"-",d0
          bne.s val1a
          not d4
          bra.s val1c
val1a:    cmp.b #"+",d0
          beq.s val1c
val1b:    subq.l #1,a6
; est-ce un HEXA ou un BINAIRE?
val1c:    move.b (a6),d0
          beq val10
          cmp.b #32,d0
          beq.s val1c
          cmp.b #"$",d0       ;chiffre HEXA
          beq val5
          cmp.b #"%",d0       ;chiffre BINAIRE
          beq val6
          cmp.b #".",d0
          beq.s val2
          cmp.b #"0",d0
          bcs val10
          cmp.b #"9",d0
          bhi val10
; c'est un chiffre DECIMAL: entier ou float?
val2:     move.l a6,a0        ;si float: trouve la fin du chiffre
          clr d3
val3:     move.b (a0)+,d0
          beq.s val4
          cmp.b #32,d0
          beq.s val3
          cmp.b #"0",d0
          bcs.s val3z
          cmp.b #"9",d0
          bls.s val3
val3z:    cmp.b #".",d0       ;cherche une "virgule"
          bne.s val3a
          bset #0,d3          ;si deux virgules: fin du chiffre
          beq.s val3
          bne.s val4
val3a:    cmp.b #"e",d0       ;cherche un exposant
          beq.s val3b
          cmp.b #"E",d0       ;autre caractere: fin du chiffre
          bne.s val4
val3ab:   move.b #"e",-1(a0)  ;met un E minuscule!!!
val3b:    move.b (a0)+,d0     ;apres un E, accepte -/+ et chiffres
          cmp.b #32,d0
          beq.s val3b
          cmp.b #"+",d0
          beq.s val3c
          cmp.b #"-",d0
          bne.s val3e
val3c:    bset #1,d3          ;+ ou -: c'est un float! 
val3d:    move.b (a0)+,d0     ;puis cherche la fin de l'exposant
          cmp.b #32,d0
          beq.s val3d
val3e:    cmp.b #"0",d0
          bcs.s val4
          cmp.b #"9",d0       ;chiffre! c'est un float
          bls.s val3c
val4:     tst d3              ;si d3=0: c'est un entier
          beq val7
; conversion ASCII--->FLOAT
          subq.l #1,a0        ;pointe la fin du chiffre
          move.b (a0),d0
          move d0,-(sp)
          move.l a0,-(sp)
          clr.b (a0)          ;arrete la conversion ICI!
          move.l a2,a0        ;pointe le debut du chiffre
          move #$b,d0
          trap #6             ;conversion ASCII--->float
          move.l d0,d3
          move.l d1,d4
          move.l (sp)+,a6
          move (sp)+,d0
          move.b d0,(a6)      ;repoke dans le "source"
          move.b #$40,d2
          move #$ff,d1        ;chiffre FLOAT
          movem.l (sp)+,d5/d6
          addq.l #4,sp
          clr d0              ;pas d'erreur
          rts
; chiffre hexa
val5:     addq.l #1,a6
          bsr hexalong
          move #$fd,d2
          bra.s val8
; chiffre binaire
val6:     addq.l #1,a6
          bsr binlong
          move #$fb,d2
          bra.s val8
; chiffre entier
val7:     bsr declong
          move #$fe,d2
val8:     exg d2,d1           ;type de conversion--->d1
          tst d2
          bne.s val10           ;si probleme: ramene zero!
          move.l d0,d3
; test du signe
          tst d4
          beq.s val8a
          neg.l d3
val8a:    movem.l (sp)+,d5/d6
          addq.l #4,sp        ;pas d'erreur, ne recupere pas l'adresse debut
          clr.b d2
          rts
; ramene zero
val9:     subq.l #1,a6
val10:    clr.b d2            ;ramene zero!
          clr.l d3
          movem.l (sp)+,d5/d6
          move.l (sp)+,a6     ;repointe au debut du chiffre
          move #1,d0          ;erreur!
          rts

; FONCTIONS UPPER$: converti en minuscule
fnupper:  bsr falpha          ;va chercher la chaine
          move.l d2,d3
          beq mid9            ;ramene la chaine vide!
          bsr demande         ;meme taille de chaine
          move.w d3,(a0)+
          subq #1,d3
fnup1:    move.b (a2)+,d0
          cmp.b #"A",d0
          bcs.s fnup2
          cmp.b #"Z",d0
          bhi.s fnup2
          add.b #$20,d0
fnup2:    move.b d0,(a0)+
          dbra d3,fnup1
          bra mid7a           ;termine et revient

; FONCTIONS LOWER$: converti en majuscule
fnlower:  bsr falpha          ;va chercher la chaine
          move.l d2,d3
          beq mid9            ;ramene la chaine vide!
          bsr demande         ;meme taille de chaine
          move.w d3,(a0)+
          subq #1,d3
fnlw1:    move.b (a2)+,d0
          cmp.b #"a",d0
          bcs.s fnlw2
          cmp.b #"z",d0
          bhi.s fnlw2
          sub.b #$20,d0
fnlw2:    move.b d0,(a0)+
          dbra d3,fnlw1
          bra mid7a           ;termine et revient

; TIME$ en fonction: ramene l'heure
time:     move.w #$2c,-(sp)
          trap #1             ;get time
          addq.l #2,sp
          move d0,-(sp)
          moveq #8,d3
          bsr demande
          move.w #8,(a0)+     ;taille de la chaine
          move (sp)+,d7
; entree pour DIR FIRST et DIR NEXT
timebis:  move.l a5,-(sp)
          move.l a0,a5        ;adresse de la chaine
          rol #5,d7
          move d7,d0
          and.l #%11111,d0
          bsr sstime          ;poke les heures
          move.b #":",(a5)+
          rol #6,d7
          move d7,d0
          and.l #%111111,d0
          bsr sstime
          move.b #":",(a5)+
          rol #5,d7
          move d7,d0
          lsl #1,d0
          and #%111111,d0
          bsr sstime
tim1:     move.l a5,a0
          move.l (sp)+,a5
          bra mid7a           ;fini le travail

; DATE$ en fonction: ramene la date
date:     move.w #$2a,-(sp)
          trap #1             ;get date
          addq.l #2,sp
          move d0,-(sp)
          move.l #10,d3
          bsr demande
          move.w #10,(a0)+    ;taille de la chaine
          move (sp)+,d7
; entree pour DIR FIRST et DIR NEXT
datebis:  move.l a5,-(sp)
          move.l a0,a5        ;adresse de la chaine
          move d7,d0
          and.l #%11111,d0
          bsr sstime          ;jour
          move.b #"/",(a5)+
          lsr #5,d7
          move.b d7,d0
          and.l #%1111,d0
          bsr sstime          ;mois
          move.b #"/",(a5)+
          lsr #4,d7
          move.b d7,d0
          and.l #%1111111,d0
          add.l #1980,d0
          moveq #4,d3
          clr.l d4
          bsr longent         ;annee
          bra tim1

; ssprg TIME: affiche deux chiffre
sstime:   moveq #2,d3
          clr.l d4
          bra longent

; SETTIME: fixe l'heure
settime:  cmp.b #$f1,(a6)+
          bne syntax
          bsr expalpha
          bsr chverbuf
          move.l a6,-(sp)
          lea buffer,a6       ;pointe la chaine
          bsr declong
          bne.s badt
          and #%11111,d0
          move d0,d7
          lsl #6,d7           ;heure
          bsr svtime
          beq.s badt
          bsr declong
          bne.s badt
          and #%111111,d0
          or d0,d7
          lsl #5,d7           ;minutes
          bsr svtime
          beq.s badt
          bsr declong
          bne.s badt
          lsr #1,d0
          and #%11111,d0
          or d0,d7            ;secondes
          move.w d7,-(sp)
          move.w #$2d,-(sp)
          trap #1             ;set time
          addq.l #4,sp
          tst d0
          bmi.s badt
          move.l (sp)+,a6
          rts
badt:     move.l (sp)+,a6
          bra badtime

; sspgm: cherche le chiffre suivant
svtime:   move.b (a6)+,d0
          beq.s svtt1
          cmp.b #32,d0
          beq.s svtime
svtt1:    rts

; SETDATE: fixe la date
setdate:  cmp.b #$f1,(a6)+
          bne syntax
          bsr expalpha
          bsr chverbuf
          move.l a6,-(sp)
          lea buffer,a6       ;pointe la chaine
          bsr declong
          bne.s badd
          and #%11111,d0      ;jour
          move d0,d7
          ror #5,d7
          bsr svtime
          beq.s badd
          bsr declong
          bne.s badd
          and #%1111,d0       ;mois
          or d0,d7
          ror #4,d7
          bsr svtime
          beq.s badd
          bsr declong
          bne.s badd
          sub #1980,d0
          and #%1111111,d0    ;annee
          or d0,d7
          ror #7,d7 
          move d7,-(sp)
          move #$2b,-(sp)
          trap #1             ;set date
          addq.l #4,sp
          tst d0
          bmi.s badd
          move.l (sp)+,a6
          rts
badd:     move.l (sp)+,a6
          bra baddate

; SETIMER
setimer:  cmp.b #$f1,(a6)+    ;veut un EGAL
          bne syntax
          bsr expentier
          tst.l d3
          bmi foncall
          move.l d3,timer
          rts

; GETIMER
getimer:  clr.b d2
          move.l timer,d3
          rts

;-----------------------------------------    --- ----- ---   ---    -------
;   -----------------------------------      |      |  |   | |
;  |       GESTION DE LA MEMOIRE       |      ---   |  |   |  ---
;   -----------------------------------          |  |  |   |     |
;-----------------------------------------    ---       ---   ---    -------
; STOPALL: arret de toute interruption
stopall:  cmp #1,runonly      ;si c'est le premier appel pour un RUN ONLY
          beq stpall2         ;on ne fait RIEN!
          movem.l d0-d7/a0-a6,-(sp)
          clr.l d2
          moveq #10,d0
          trap #5             ;move off
          moveq #13,d0
          trap #5             ;anim off
          moveq #7,d0
          trap #5             ;sprite off
          moveq #16,d0
          trap #5             ;actualise
          moveq #1,d1
          moveq #19,d0
          trap #5             ;mouse par default
          moveq #0,d0
          trap #7             ;music off
          move nbjeux,d6
stpall1:  lea merreur,a0      ;pointe un message <>06071963
          moveq #29,d7
          move d6,d0
          trap #3             ;arrete tous les jeux > 3
          addq #1,d6
          cmp #16,d6
          bne.s stpall1
          lea merreur,a0      ;pointe un message <>28091960
          moveq #26,d7
          trap #3             ;arrete les icones
          movem.l (sp)+,d0-d7/a0-a6
stpall2:  rts

; OFF tout seul: arrete les interruptions
auff:     bsr stopall         ;arrete les interruptions
          bsr putchar         ;REMET les caracteres et les icones!!!
          rts

; MOVE DATA: CHANGEMENT DES ADRESSES DES SPRITES, DE LA MUSIQUE
; RELOGE LES SPRITES
movedata: moveq #1,d3         ;Banque #1: SPRITES
          bsr adbank
          bne.s mvd1
          lea merreur,a1      ;pointe un message fixe, <> de 19861987
mvd1:     move.l a1,a0
          moveq #1,d0         ;chgbank
          trap #5
          moveq #0,d5
          bra.s mvd5
; RELOGE LES BANQUES PROGRAMME ET LES BANQUES CARACTERES
putchar:  moveq #1,d5
mvd5:     move.l adatabank,a3
          addq.l #4,a3
          moveq #1,d3
          move nbjeux,d6      ;numero du premier jeu de caractere
mvd2:     cmp.b #$83,(a3)     ;banque programme?
          bne.s mvd3
          tst d5              ;doit reloger les caracteres seulement?
          bne.s mvd4 
          bsr relprg
          bra.s mvd4
mvd3:     cmp.b #$84,(a3)     ;banque caractere?
          bne.s mvd4
          bsr adbank
          move.l d6,d0        ;reloge la banque de caracteres
          move.l a1,a0
          moveq #29,d7
          trap #3
          cmp #16,d6
          bcc.s mvd4
          addq #1,d6          ;une autre banque (si < 16)!
mvd4:     addq.l #4,a3
          addq #1,d3
          cmp #16,d3
          bne.s mvd2
; RELOGE LES ICONES
          moveq #2,d3         ;Banque #2: ICONES
          bsr adbank
          bne.s mvd1a
          lea merreur,a1      ;pointe un message fixe <> $28091960
mvd1a:    move.l a1,a0
          moveq #26,d7        ;new icones
          trap #3
          rts

; RELOGE UN PROGRAMME
relprg:   movem.l d0-d7,-(sp)
          bsr adbank               ;va chercher l'adresse de la banque
          move.l a1,a0
          move.l a1,d2
          move.l 2(a1),d0          ;distance a la table
          add.l 6(a1),d0
          and.l #$ffffff,d0
          add #$1c,a1              ;pointe le debut du programme
          move.l a1,a2
          add.l d0,a1
          sub.l 16(a0),d2          ;d2= difference a additionner au prg
          move.l a0,16(a0)         ;poke la nouvelle adresse
          tst.l (a1)
          beq.s relp3
          add.l (a1)+,a2           ;pointe la table de relocation
          clr.l d0
          bra.s relp1
relp0:    move.b (a1)+,d0
          beq.s relp3
          cmp.b #1,d0
          beq.s relp2
          add d0,a2                ;pointe dans le programme
relp1:    add.l d2,(a2)            ;change dans le programme
          bra.s relp0
relp2:    add.w #254,a2
          bra.s relp0
relp3:    movem.l (sp)+,d0-d7
          rts

; TRANSFERT DE MEMOIRE RAPIDE ET INTELLIGENT a2/pair->a3/pair, d3 octets
transmem: move.b d3,d4        ;retour: a2 et a3 pointent a la fin des zones
          and.b #3,d4
          cmp.l a2,a3
          bcs.s trsmm
; a3>a2: remonter le programme
          add.l d3,a2
          add.l d3,a3
          movem.l a2/a3,-(sp)
          lsr.l #2,d3         ;nombre de mots longs
          beq.s trsmm2
trsmm1:   move.l -(a2),-(a3)  ;transfert mots longs
          subq.l #1,d3
          bne.s trsmm1
trsmm2:   tst.b d4
          beq.s trsmm3b
trsmm3:   move.b -(a2),-(a3)  ;transfert octets
          subq.b #1,d4
          bne.s trsmm3
trsmm3b:  movem.l (sp)+,a2/a3 ;pointe la fin des zones
          rts
; a2<a3: descendre le programme
trsmm:    lsr.l #2,d3
          beq.s trsmm5
trsmm4:   move.l (a2)+,(a3)+
          subq.l #1,d3
          bne.s trsmm4
trsmm5:   tst.b d4
          beq.s trsmm7
trsmm6:   move.b (a2)+,(a3)+
          subq.b #1,d4
          bne.s trsmm6
trsmm7:   rts

; CALCLONG: calcule et poke la longueur totale du programme
calclong: movem.l a0/d0-d1,-(sp)
          move.l fsource,d3
          sub.l dsource,d3
          move.l adatabank,a0
          move.l d3,(a0)+     ;poke la longueur du source
          move #14,d1
clcl0:    move.l (a0)+,d0
          beq.s clcl1
          and.l #$00ffffff,d0
          add.l d0,d3
clcl1:    dbra d1,clcl0
          move.l adataprg,a0
          move.l d3,4(a0)     ;poke la longueur totale du pgm
          movem.l (sp)+,a0/d0-d1
          rts

; EFFACE LES BANQUES DE DONNEE PENDANT CLEARVAR
cleanbank:move.l topmem,a3
          move.l a3,a2
          move.l adatabank,a1
          add.l #16*4,a1
          move #14,d1
clbk1:    move.l -(a1),d3     ;data de la banque
          beq.s clbk3         ;Vide
          move.l d3,d0
          and.l #$00ffffff,d3
          sub.l d3,a2         ;debut de la banque
          tst.l d0
          bmi.s clbk2         ;non indispensable!
          clr.l (a1)          ;l'efface!
          bra.s clbk3
clbk2:    sub.l d3,a3
          cmp.l a2,a3         ;pas besoin de poker: tout est a la meme adresse!
          beq.s clbk3
          movem.l a2-a3,-(sp) ;transfere
          bsr transmem
          movem.l (sp)+,a2-a3
clbk3:    dbra d1,clbk1
; si on a change quelque chose: ON FAIT UN MOVEDATA !!!
          cmp.l himem,a3
          beq.s clbk4
          move.l a3,himem     ;fin des variables/debut des banques
          bsr stopall
          bsr movedata
clbk4:    rts

; CHAINE LES BANQUES DE DONNEES IMPORTANTES A LA SUITE DU PROGRAMME ACTUEL
chaine:   bsr stopall
          move.l adatabank,a0
          move.l fsource,a3
          move.l himem,a2     ;debut de la premiere banque
          move.l (a0)+,d5     ;longueur du source
          move #14,d6         ;plus que 15 banques a voir
activ1:   move.l (a0)+,d3
          beq.s activ2b
          bpl.s activ2
          and.l #$00ffffff,d3 ;longueur a tranferer
          add.l d3,d5         ;calcule la longueur totale du programme
          bsr transmem        ;va recopier
          bra.s activ2b
activ2:   clr.l -4(a0)        ;si zone NON INDISPENSABLE: l'efface
          and.l #$00ffffff,d3 ;BUG BUG BUG BUG BUG BUG BUG BUG
          add.l d3,a2
activ2b:  dbra d6,activ1
          move.l adataprg,a1
          move.l d5,4(a1)     ;change la longueur totale du prg
          rts

; DECHAINE LES BANQUES DE DONNEES DU PROGRAMME ACTUEL
dechaine: move.l adataprg,a0
          move.l adatabank,a1
          move.l (a0),a2      ;debut du source en absolu
          move.l a2,dsource
          add.l (a1),a2       ;longueur de la banque ZERO=LSOURCE
          move.l a2,fsource   ;fin source en absolu
          move.l 8(a0),d0     ;debut du programme suivant OU fin du buffer
          clr.b d0            ;multiple de 256!
          move.l d0,a3
          move.l a3,topmem    ;topmem: haut des donnees
          move.l 4(a0),d3     ;longueur totale
          sub.l (a1),d3       ;moins taille du source=longueur des donnees!
          sub.l d3,a3         ;topmem moins longueur des donnees
          move.l a3,himem     ;= himem du basic =debut des donnees
          bsr transmem        ;transfere
          bsr clearvar
          bsr movedata        ;initialise sprites/musiques/3d
          rts

; ACTIVATION DU PROGRAMME D0
active:   movem.l d1-d7/a0-a6,-(sp)
          cmp #16,d0
          bcc activ20
          move program,d1     ;ancien programme active
          cmp d1,d0
          beq activ20
          move d0,program     ;programme edite actuellement
; CHAINE LES BANQUES DE DONNEES IMPORTANTES A LA SUITE DU PROGRAMME: d0=#prg
          bsr chaine
; TOUT EST EN UN SEUL BLOC: change la table des programmes
          lea dataprg,a0
          move d0,d2
          lsl #3,d2
          add d2,a0           ;a0: dataprg nouveau (a1=ancien)
          move.l a0,adataprg  ;stocke!
          cmp d1,d0
          bcs activ5
;le nouveau programme est au dessus de l'ancien!
          move.l (a1),d3      ;debut ancien
          add.l 4(a1),d3      ;fin ancien
          move.l 8(a1),d2     ;juste superieur a l'ancien
          sub.l d3,d2         ;decalage vers le bas en d2
activ3:   lea 8(a1),a1
          addq #1,d1
          move.l (a1),a2      ;adresse d'origine
          move.l a2,a3
          sub.l d2,a3         ;adresse de destination
          move.l a3,(a1)      ;change le pointeur
          move.l 4(a1),d3     ;taille a transferer
          bsr transmem
          cmp d1,d0
          bne.s activ3
          bra.s activ10
;le nouveau programme est en dessous de l'ancien!
activ5:   move.l 8(a1),d2     ;si c'est le 15eme: pas de prb: prend fbufprg!
          move.l (a1),d3
          add.l 4(a1),d3
          sub.l d3,d2         ;decalage vers le haut!
activ8:   move.l (a1),a2
          move.l a2,a3
          add.l d2,a3         ;adresse de destination
          move.l a3,(a1)      ;change le pointeur
          move.l 4(a1),d3     ;taille a transferer
          bsr transmem
activ9:   subq #1,d1          ;tous au dessus, sauf d0
          lea -8(a1),a1
          cmp d1,d0
          bne.s activ8
; DECHAINE LES BANQUES DE DONNEES DU PROGRAMME D0
activ10:  move.l adataprg,a0
          lea databank,a1
          lsl #6,d0           ;multiplie par 64
          add d0,a1
          move.l a1,adatabank ;poke la nouvelle position dans databank
          bsr dechaine        ;va dechainer
activ20:  movem.l (sp)+,d1-d7/a0-a6
          rts

; CURRENT: numero du programme EDITE
current:  clr.l d3
          move program,d3
          tst accflg          ;si en accessoire
          beq.s curt1
          move reactive,d3    ;ramene le numero du programme AVANT l'appel
curt1:    addq.l #1,d3
          clr.b d2
          rts

; ACCNB: numero de l'accessoire, zero si pas un accessoire
accnb:    clr.l d3
          clr.b d2
          tst accflg
          beq.s accnb1
          move.w program,d3
          addq #1,d3
accnb1:   rts

; LANGAGE: ramene la langue selectionnee
langage:  clr.l d3
          move.w langue,d3
          clr.b d2
          rts

; POINTE LA BANQUE D3 DANS LA DATAZONE ACTUELLE (A0), RAMENE SON ADRESSE (A1)
adbank:   move.l adatabank,a0
          move.l himem,a1     ;depart des banques
adbis:    move.l d1,-(sp)     ;entree pour bgrab
          tst.l d3
          beq foncall
          cmp.l #16,d3
          bcc foncall
          addq.l #4,a0        ;saute le source
          move d3,d1
          subq #2,d1
          bmi.s adb3
adb1:     move.l (a0)+,d0
          and.l #$00ffffff,d0
          beq.s adb2
          add.l d0,a1
adb2:     dbra d1,adb1
adb3:     move.l (sp)+,d1
          move.l (a0),d0
          rts

; ADPRG: ramene ADATABANK(a0) et ADATAPRG(a1) d'un autre programme (1-16)
adprg:    subq.l #1,d3        ;(1-16)--->(0-15)
          cmp.l #16,d3
          bcc foncall
          lsl #3,d3
          lea dataprg,a1
          add d3,a1
          lsl #3,d3
          lea databank,a0
          add d3,a0
          rts

; ERASE X/ ERASE P,X: EFFACE UNE BANQUE DE MEMOIRE 
erase:    bsr mentiers        ;va chercher le numero de la banque
          cmp #2,d0
          beq.s er1
          cmp #1,d0
          bne syntax
          move.l d1,d3        ;un seul param: efface dans le programme 
erasbis:  bsr effbank
          bne.s er0
          bsr calclong
          bsr movevar         ;changement de place des variables
          bsr movedata        ;changement de place des sprite/music
er0:      rts
; efface dans un autre programme, commande directe!
er1:      tst runflg
          bne illegal
          cmp.l #16,d2        ;D2= numero de programme
          bhi foncall
          subq #1,d2
          bcs foncall
          cmp.l #16,d1        ;D1= numero de la banque
          bhi foncall
          tst d1
          beq foncall
          move program,d0
          move d0,-(sp)
          move.l d1,-(sp)
          move d2,d0
          bsr active          ;active le programme en question
          move.l (sp)+,d3
          bsr erasbis         ;va effacer la banque
          move (sp)+,d0
          bsr active          ;reactive le programme
          jmp ok              ;fini !!!

; ss pgm de erase
effbank:  move.l d3,-(sp)
          bsr adbank
          beq.s eras5
          cmp #15,d3
          bne.s effb1
          tst mnd+14        ;touche pas a ma banque 15!
          bne menuill
effb1:    clr.l (a0)          ;efface la banque dans la table
          bsr stopall

          and.l #$00ffffff,d0 ;taille de la banque
          add.l d0,himem      ;remonte HIMEM
          move.l lowvar,a2    ;depart
          move.l a2,a3
          add.l d0,a3         ;destination
          move.l a3,lowvar    ;remonte les variables
          move.l a1,d3
          sub.l a2,d3         ;nombre d'octets
          bsr transmem        ;va tout changer
          move.l (sp)+,d3
          clr d0              ;pas d'erreur
          rts
eras5:    move.l (sp)+,d3
          move #1,d0          ;rien fait!
          rts

; RESERVE
reserve:  cmp.b #$a0,(a6)+    ;as data/as work/as screen/as datascreen
          bne syntax
          move.b (a6)+,d0
          cmp.b #$aa,d0
          beq.s res2
          cmp.b #$ab,d0
          beq.s res3
          cmp.b #$ac,d0
          beq.s res1
          cmp.b #$7d,d0
          beq.s res2a
          move #$81,d1        ;data!
          bra.s res4
res1:     move #$2,d1         ;screen!
          bra.s res4
res2:     move #$82,d1        ;datascreen!
          bra.s res4
res2a:    move #$84,d1
          bra.s res4
res3:     move #$1,d1
res4:     move d1,-(sp)
          bsr expentier       ;va chercher le numero de la banque
          move (sp)+,d1
          move d1,d0
          and #$0f,d0
          cmp.l #15,d3
          bne.s res4a
          tst mnd+14
          bne menuill         ;MENUS en route!!!
res4a:    cmp.b #$2,d0
          bne.s res5
; ecran: 32768, commencant par un multiple de 256
          move.l d3,d2
          move.l #32768,d3
          bra.s res6
res5:     movem.l d1/d3,-(sp) ;va chercher la longueur de la banque
          cmp.b #",",(a6)+
          bne syntax
          bsr expentier
          movem.l (sp)+,d1/d2
res6:     bsr reservin
resbis:   bsr calclong
          bsr movevar         ;remet les variables
          bsr movedata        ;remet les banques
rester:   rts

; sous programme de RESERVE: d1=flag, d2=banque, d3=longueur
reservin: bsr stopall         ;arrete TOUT: on change les adresses...
          tst.b d3
          beq.s reserv1
          clr.b d3
          add.l #$100,d3      ;longueur multiple de 256!!!!
reserv1:  bsr demande         ;d3 octets de libre?
          exg d2,d3
          bsr adbank
          bne dejares         ;bank already reserved
          and.l #$ff,d1
          ror.l #8,d1
          or.l d2,d1          ;flag/longueur de la banque
          move.l d1,(a0)
          sub.l d2,himem      ;baisse HIMEM
          move.l lowvar,a2    ;adresse de depart
          move.l a2,a3
          sub.l d2,a3         ;adresse de destination
          move.l a3,lowvar
          move.l a1,d3
          sub.l a2,d3         ;nombre d'octets a bouger
          bsr transmem
          rts

; BCOPY X TO Y : COPIE UNE BANQUE MEMOIRE
bcopy:    bsr expentier
          bsr adbank
          beq rester
          movem.l d3/a0,-(sp)
          cmp.b #$80,(a6)+
          bne syntax
          bsr expentier
          bsr adbank
          bne dejares
          cmp #15,d3
          bne.s cb1
          tst mnd+14
          bne menuill
cb1:      move.l d3,d2        ;d2= numero de la banque
          movem.l (sp)+,d0/a2
          cmp d3,d0
          beq rester
          move.l (a2),d1
          move.l d1,d3
          and.l #$ffffff,d3   ;d3=longueur de la banque
          clr d1
          swap d1
          clr.b d1
          ror.w #8,d1         ;d1= flag
          movem.l d0/d2,-(sp)
          bsr reservin        ;va reserver
          movem.l (sp)+,d3/d4
          bsr adbank
          move.l a1,a2        ;adresse d'origine
          move.l d4,d3
          bsr adbank
          move.l a1,a3        ;adresse de destination
          move.l (a0),d3
          and.l #$ffffff,d3   ;longueur
          bsr transmem
          bra resbis          ;va tout terminer

; BGRAB prg[,bank]: GRABBE LES BANQUES DE MEMOIRE
bgrab:    bsr mentiers        ;va chercher les parametres
          cmp #1,d0
          beq bgrab5
          cmp #2,d0
          bne syntax
; GRABBE UNE SEULE BANQUE
          subq.l #1,d2
          cmp program,d2
          beq rester          ;c'est le meme!!!
          addq.l #1,d2
          move.l d2,d3        ;numero de programme en d3
          bsr adprg           ;va chercher (et teste) ad bank et ad prg
; verifie la taille memoire
          move.l (a1),a1
          add.l (a0),a1       ;adresse du HIMEM de l'autre prg
          movem.l a0-a1,-(sp)
          move.l d1,d3        ;numero de la banque
          bsr adbis
          cmp #15,d3          ;banque 15
          bne.s bgrab0
          tst mnd+14        ;et menus en route!!! ALLONS!!!
          bne menuill
bgrab0:   and.l #$ffffff,d0
          move.l d0,d3
          add.l #64,d3        ;taille de la banque a prendre + 64 secu
          move.l d3,-(sp)
          move.l d1,d3
          bsr adbank          ;taille ACTUELLE de la banque
          and.l #$ffffff,d0
          move.l (sp)+,d3
          cmp.l d0,d3         ;si plus grande:
          bls.s bgrab1
          sub.l d0,d3         ;va demander la difference!
          bsr demande
bgrab1:   move.l d1,d3        ;numero de banque en d3
          bsr effbank         ;va effacer la banque du pgm active
          movem.l (sp)+,a0-a1
          bsr adbis           ;ramene la banque de l'autre pgm
          beq resbis          ;VIDE: on arrete la!
          move.l a1,-(sp)
          move.l d3,d2        ;numero de banque
          move.l d0,d3
          and.l #$ffffff,d3   ;longueur
          move.l d3,-(sp)
          rol.l #8,d0
          move.b d0,d1        ;flag
          move.l d2,-(sp)
          bsr reservin        ;reserve la place memoire
          move.l (sp)+,d3
          bsr adbank          ;ramene l'adresse ou copier
          move.l a1,a3
          move.l (sp)+,d3     ;longueur a bouger
          move.l (sp)+,a2     ;depart
          bsr transmem
          bra resbis          ;va tout changer dans le programme
; GRABBE TOUTES LES BANQUES
bgrab5:   subq.l #1,d1
          cmp program,d1      ;c'est le meme
          beq rester
          tst mnd+14
          bne menuill         ;la banque 15 est pour les menus!!!
          addq.l #1,d1
          move.l d1,d3        ;numero de programme
          bsr adprg
          movem.l a0-a1,-(sp)
          move.l topmem,d0
          sub.l himem,d0      ;taille des banques actuelles
          move.l 4(a1),d3     ;taille de l'autre pgm
          sub.l (a0),d3       ;- taille du source = taille des autres banques
          add.l #64,d3        ;securite!
          cmp.l d0,d3
          bls.s bgrab6          ;inferieur! ca marche!
          sub.l d0,d3         ;prend la difference
          bsr demande
bgrab6:   bsr stopall
          movem.l (sp)+,a0-a1
          move.l 4(a1),d3
          sub.l (a0),d3       ;longueur des autres banques
          move.l (a1),a1
          add.l (a0)+,a1      ;debut des autres banques
          move.l adatabank,a2
          addq.l #4,a2
          move #14,d0
bgrab7:   move.l (a0)+,(a2)+  ;copie toutes les banques
          dbra d0,bgrab7
; bouge les variables
          movem.l d3/a1,-(sp)
          move.l topmem,a3
          sub.l d3,a3
          move.l lowvar,a2    ;depart des variables
          move.l himem,d3
          sub.l a2,d3         ;taille des variables
          sub.l d3,a3         ;arrivee des variables
          move.l a3,lowvar    ;nouveau lowvar
          bsr transmem        ;recopie les variables
          move.l a3,himem     ;nouveau himem= arrivee des banques
          movem.l (sp)+,d3/a2 ;recupere longueur et depart des banques
          bsr transmem        ;recopie!
          bra resbis

; START (xx)/START (xx,yy): debut d'une banque de donnee
start:    cmp.b #"(",(a6)+
          bne syntax
          bsr getentier
          cmp #2,d0
          beq.s start1
          cmp #1,d0
          bne syntax
; un seul argument: programme courant
start0:   move.l d1,d3
          bsr adbank
          bra.s start2
; deux arguments: un autre programme
start1:   subq.l #1,d1
          cmp.w program,d1    ;c'est le programme courant
          beq.s start3
          addq.l #1,d1
          move.l d1,d3
          bsr adprg           ;adbank et adprg
          move.l (a1),a1
          add.l (a0),a1       ;pointe "HIMEM"
          move.l d2,d3
          bsr adbis
start2:   move.l a1,d3
          clr.b d2
          rts
start3:	move.l d2,d3
	bsr adbank
	bra.s start2

; LENGTH (xx)/LENGTH (xx,yy): longueur d'une banque de donnee
length:   cmp.b #"(",(a6)+
          bne syntax
          bsr getentier
          cmp #2,d0
          beq.s leng1
          cmp #1,d0
          bne syntax
; un seul argument: programme courant
leng0:    move.l d1,d3
          bsr adbank
          bra.s leng2
; deux arguments: un autre programme
leng1:    subq.l #1,d1
          cmp.w program,d1    ;c'est le programme courant!
          beq.s leng3
          addq.l #1,d1
          move.l d1,d3
          bsr adprg
          move.l (a1),a1
          add.l (a0),a1
          move.l d2,d3
          bsr adbis
leng2:    and.l #$00ffffff,d0
          move.l d0,d3
          clr.b d2
          rts
leng3:	move.l d2,d3
	bsr adbank
	bra.s leng2

; ADOUBANK: ramene l'adresse absolue de la banque si <16
adoubank: cmp.l #16,d3
          bcc.s adou1
; numero de banque
          bsr adbank          ;adresse de la banque
          rol.l #8,d0
          and.l #$ff,d0
          beq bknotdef
          move.l a1,d3
adou1:    rts

; COPY depart(inclus),fin(exclue) TO arrivee: COPIE DE PLAGES MEMOIRE
copy:     bsr expentier       ;adresse de depart
          bsr adoubank
          move.l d3,-(sp)
          cmp.b #",",(a6)+
          bne syntax
          bsr expentier       ;adresse de fin
          bsr adoubank
          move.l d3,-(sp)
          cmp.b #$80,(a6)+    ;token de TO
          bne syntax
          bsr expentier       ;adresse d'arrivee
          bsr adoubank
          move.l d3,a3        ;en A3
          move.l (sp)+,d3
          move.l (sp)+,a2     ;adresse de depart en A2
          sub.l a2,d3         ;taille a bouger en D3
          bcs foncall
          bsr transmem
          rts

; FILL depart(inclus) TO fin(exclue), mot long: REMPLI DES PLAGES MEMOIRE
fill:     bsr expentier       ;adresse de depart
          bsr adoubank
          move.l d3,-(sp)
          cmp.b #$80,(a6)+    ;token de TO
          bne syntax
          bsr expentier       ;longueur
          bsr adoubank
          move.l d3,-(sp)
          cmp.b #",",(a6)+
          bne syntax
          bsr expentier       ;mot long a mettre
          move.l (sp)+,d2
          move.l (sp)+,a0
fillbis:  sub.l a0,d2
          bcs foncall
          move.b d2,d1
          lsr.l #2,d2         ;travaille par mot long
          beq.s fil2
fil1:     move.l d3,(a0)+
          subq.l #1,d2
          bne.s fil1
fil2:     and #$0003,d1
          beq.s fil4
fil3:     rol.l #8,d3
          move.b d3,(a0)+
          subq #1,d1
          bne.s fil3
fil4:     rts

; HUNT (depart TO fin,chaine$): RAMENE L'ADRESSE D'UNE CHAINE DANS LA MEMOIRE!
faind:    cmp.b #"(",(a6)+
          bne syntax
          move parenth,-(sp)
          clr parenth
          bsr entierbis
          bsr adoubank
          move.l d3,-(sp)
          cmp.b #$80,(a6)+    ;token de TO
          bne syntax
          bsr entierbis
          bsr adoubank
          move.l d3,-(sp)
          cmp.b #",",(a6)+
          bne syntax
          move #1,parenth
          bsr alphabis
          bsr chverbuf
          move.l (sp)+,d7     ;adresse de fin
          move.l (sp)+,a0     ;adresse de recherche
          move.w (sp)+,parenth
          subq #1,d2
          bcs.s ht3           ;si chaine nulle: ramene zero!
          move.l #buffer,d6
          subq.l #1,a0
ht1:      addq.l #1,a0        ;passe a l'octet suivant
          move.l a0,a1
          cmp.l d7,a0         ;pas trouve!
          bcc.s ht3
          move.l d6,a2        ;pointe la chaine recherchee
          move d2,d1
ht2:      cmpm.b (a2)+,(a1)+
          bne.s ht1
          dbra d1,ht2
          move.l a0,d3        ;TROUVE!
          clr.b d2
          rts
ht3:      clr.l d3
          clr.b d2
          rts

; LLISTBANK
llistbank:move #1,impflg
          bra.s lstbk1
; LISTBANK
listbank: clr impflg
lstbk1:   move.l adatabank,a0
          addq.l #4,a0
          move #14,d0
lstbk0:   tst.l (a0)+         ;cherche une banque pleine
          bne.s lstbkb
          dbra d0,lstbk0
          bra lstbk9
lstbkb:   move.l a5,-(sp)
          lea lbk0,a0         ;titre
          bsr traduit         ;va traduire, le titre seulement!
          bsr impchaine
          moveq #1,d5
lstbk2:   move.l d5,d3        ;regarde si la banque est pleine
          bsr adbank
          beq lstbk7          ;VIDE: passe a la suivante
          lea buffer,a5
          move.l d5,d0        ;numero de la banque
          bsr longdec
          cmp #10,d5
          bcc.s lstbka
          move.b #" ",(a5)+
lstbka:   move.l d5,d3
          bsr adbank
          move.l d0,-(sp)
          cmp #4,d5           ;banques < 5: sprites / icones / music / 3d
          bhi.s lstbkq
          move d5,d0
          addq #7,d0
          bra.s lstbk3
lstbkq:   rol.l #8,d0
          subq #1,d0
          tst.b d0
          bpl.s lstbk3
          and.b #3,d0
          or.b #4,d0
lstbk3:   and #$00ff,d0
          lsl #2,d0
          lea lbktext,a2
          add d0,a2
          move.l (a2),a2      ;adresse de la chaine
lstbk4:   move.b (a2)+,(a5)+
          bne.s lstbk4          ;copie la chaine
          subq.l #1,a5
          move.l (sp)+,d6
          lea lbk10,a0
          move.l a1,d0
          bsr lbkpgm          ;start
          lea lbk11,a0
          move.l a1,d0
          and.l #$00ffffff,d6
          add.l d6,d0
          bsr lbkpgm          ;end
          lea lbk12,a0
          move.l d6,d0
          bsr lbkpgm          ;length
lstbk5:   clr.b (a5)+
          lea buffer,a0
          bsr plusr
          bsr impchaine
; Teste les touches
          bsr ttlist
          beq.s lstbk7          ;pas d'appui
          bmi.s lstbk8          ;appui sur ESC
lstbk6:   bsr ttlist
          beq.s lstbk6
          bmi.s lstbk8
lstbk7:   addq #1,d5
          cmp #16,d5
          bcs lstbk2
lstbk8:   move.l (sp)+,a5
lstbk9:   rts
; sous pgm de listbank
lbkpgm:   movem.l a0/a1,-(sp)
lbkpgm0:  move.b (a0)+,(a5)+
          bne.s lbkpgm0
          subq.l #1,a5
          tst lbkflg
          bne.s lbkpgm1
          moveq #6,d3
          jsr longascii
          bra.s lbkpgm2
lbkpgm1:  jsr longdec
lbkpgm2:  movem.l (sp)+,a0/a1
          rts

; HEXA on/off: liste les banques en hexa ou en decimal
hexa:     bsr onoff
          bmi syntax
          bne.s hexxon
          move #1,lbkflg
          rts
hexxon:   clr lbkflg
          rts

; FREE: ramene la place memoire disponoble
free:     move.l lowvar,d0
          bsr menage
          move.l lowvar,d3
          sub.l hichaine,d3
          clr.b d2
          rts

; POKE xx,yy
poke:     bsr dentier
          move.l d4,a0
          move.b d3,(a0)
          rts

; DOKE xx,yy
doke:     bsr dentier
          move.l d4,a0
          move.w d3,(a0)
          rts

; LOKE xx,yy
loke:     bsr dentier
          move.l d4,a0
          move.l d3,(a0)
          rts

; PEEK (xx)
peek:     bsr fentier
          move.l d3,a0
          clr.l d3
          move.b (a0),d3
          rts

; DEEK (xx)
deek:     bsr fentier
          move.l d3,a0
          clr.l d3
          move.w (a0),d3
          rts

; LEEK (xx)
leek:     bsr fentier
          move.l d3,a0
          move.l (a0),d3
          rts

; BSET #bit,var
bsait:    bsr expentier
          cmp.l #32,d3
          bcc foncall
          cmp.b #",",(a6)+
          bne syntax
          cmp.b #$fa,(a6)+
          bne syntax
          move.l d3,-(sp)
          bsr findvar
          move.l (sp)+,d0
          tst.b d2
          bne typemis
          bset d0,d3
          move.l d3,(a1)
          rts

; BCLR #bit,var
bclair:   bsr expentier
          cmp.l #32,d3
          bcc foncall
          cmp.b #",",(a6)+
          bne syntax
          cmp.b #$fa,(a6)+
          bne syntax
          move.l d3,-(sp)
          bsr findvar
          move.l (sp)+,d0
          tst.b d2
          bne typemis
          bclr d0,d3
          move.l d3,(a1)
          rts

; BCHG #bit,var
bchge:    bsr expentier
          cmp.l #32,d3
          bcc foncall
          cmp.b #",",(a6)+
          bne syntax
          cmp.b #$fa,(a6)+
          bne syntax
          move.l d3,-(sp)
          bsr findvar
          move.l (sp)+,d0
          tst.b d2
          bne typemis
          bchg d0,d3
          move.l d3,(a1)
          rts

; fonction BTST (#bit,exp)
btest:    cmp.b #"(",(a6)+
          bne syntax
          bsr getentier
          cmp #2,d0
          bne syntax
          clr.l d3
          btst d1,d2
          beq.s btest1
          moveq #-1,d3
btest1:   clr.b d2
          rts

; ROL .b / .w / .l nbre,variable
raul:     clr d0
          bra raur1
; ROR .b / .w / .l nbre,variable
raur:     moveq #1,d0
raur1:    move d0,-(sp)
          clr d1              ;par defaut: mot
          move.b (a6),d0
          cmp.b #$ae,d0
          beq.s raur3
          cmp.b #$ad,d0
          beq.s raur2
          cmp.b #$af,d0
          bne.s raur4
          moveq #1,d1         ;mot long
          bra.s raur3
raur2:    moveq #-1,d1        ;octet
raur3:    addq.l #1,a6
raur4:    move d1,-(sp)
          bsr expentier
          cmp.l #32,d3
          bcc foncall
          move d3,-(sp)
          cmp.b #",",(a6)+
          bne syntax
          cmp.b #$fa,(a6)+
          bne syntax
          bsr findvar
          move (sp)+,d1
          move.w (sp)+,d0
          beq raur10
          bpl raur15
; rotation sur un octet
          move.w (sp)+,d0
          bne raur6
          rol.b d1,d3
          bra.s finrot
raur6:    ror.b d1,d3
          bra.s finrot
; rotation sur un mot
raur10:   move.w (sp)+,d0
          bne raur11
          rol.w d1,d3
          bra.s finrot
raur11:   ror.w d1,d3
          bra.s finrot
; rotation sur un mot long
raur15:   move.w (sp)+,d0
          bne raur16
          rol.l d1,d3
          bra.s finrot
raur16:   ror.l d1,d3
finrot:   move.l d3,(a1)
          rts

; DREG(0-7)=xx: INSTRUCTION DREG
instdreg: clr.l d0
          moveq #7,d1
          bra instreg
; AREG(0-6)=xx: INSTRUCTION DREG
instareg: move.l #8*4,d0
          moveq #6,d1
instreg:  movem.l d0-d1,-(sp)
          lea bufcalc,a3
          bsr fentier
          cmp.b #$f1,(a6)+
          bne syntax
          move.l d3,-(sp)
          bsr expentier
          move.l (sp)+,d2
          movem.l (sp)+,d0-d1
          cmp.l d1,d2
          bhi foncall
          lsl #2,d2
          add.l d0,d2                ;decalage des registres
          lea callreg,a0
          move.l d3,0(a0,d2.w)
          rts

; =DREG(xx): fonction DREG 0 ---> 7
dreg:     clr.l d0
          moveq #7,d1
          bra reg
; =AREG(xx): fonction AREG 0 ---> 6
areg:     moveq #8*4,d0
          moveq #6,d1
reg:      movem.l d0-d1,-(sp)
          bsr fentier
          movem.l (sp)+,d0-d1
          cmp.l d1,d3
          bhi foncall
          lsl #2,d3
          add.l d0,d3
          lea callreg,a0
          move.l 0(a0,d3.w),d3
          clr.b d2
          rts

; CALL adbank/ad: charge les registres d0-d7/a0-a7
call:     bsr expentier
          bsr adoubank
          move.l d3,buffer
          movem.l a4-a6,-(sp)           ;sauve les registres importants!
          lea callreg,a6
          movem.l (a6)+,d0-d7/a0-a5     ;ca doit marcher!
          move.l (a6),a6
          pea callret                   ;pousse l'adresse de retour!
          move.l buffer,-(sp)           ;appel!
          rts

; TRAP nn,param1,"param2",param3...
trahp:    bsr expentier
          cmp.l #15,d3
          bhi foncall
          move.w trahpapel,d0           ;prepare l'appel de la trappe
          and.w #%1111111111110000,d0
          or.w d3,d0
          move.w d0,trahpapel
; recupere tous les parametres! Quelle merde
          lea buffer,a2
          clr d0
trahp1:   clr d1              ;par defaut: WORD
          move.b (a6),d2
          beq trahp9
          cmp.b #":",d2
          beq trahp9
          cmp.b #$9b,d2
          beq trahp9
          cmp.b #",",d2
          bne syntax
          addq.l #1,a6
          move.b (a6),d2
          cmp.b #$ae,d2       ;word?
          beq.s trahp1a
          cmp.b #$af,d2       ;long?
          bne.s trahp2
          moveq #1,d1
trahp1a:  addq.l #1,a6
trahp2:   movem.l d0-d1/a2,-(sp)
          bsr evalue
          tst.b d2
          beq.s trahp7
          bpl.s trahp6
;chaine de caracteres: la recopie avec un ZERO a la fin!
          move.l d3,a2
          clr.l d3
          move.w (a2)+,d3
          bsr demande
          subq #1,d3
          bcs.s trahp4
trahp3:   move.b (a2)+,(a1)+
          dbra d3,trahp3
trahp4:   clr.b (a1)+
          move a1,d0
          btst #0,d0
          beq.s trahp5
          clr.b (a1)+
trahp5:   move.l a1,hichaine
          move.l a0,d3
          movem.l (sp)+,d0-d1/a2
          moveq #1,d1
          bra.s trahp8
; parametre float
trahp6:   movem.l d0-d1/a2,-(sp)
          bsr fltoint
; parametre entier
trahp7:   movem.l (sp)+,d0-d1/a2
trahp8:   move.l d3,(a2)+     ;d'abord la variable
          move.w d1,(a2)+     ;puis le type
          addq #1,d0
          bra trahp1
; reprend tous ces parametres---> dans la pile
trahp9:   movem.l a4-a6,-(sp) ;sauve les registres importants
          move.l a7,trahpile  ;position de la pile avant l'appel
trahp10:  tst d0
          beq.s trahp12
          subq #1,d0
          tst.w -(a2)
          bne.s trahp11
          move.l -(a2),d2
          move.w d2,-(sp)
          bra.s trahp10
trahp11:  move.l -(a2),d2
          move.l d2,-(sp)
          bra.s trahp10
; appel de la trappe
trahp12:  lea callreg,a6
          movem.l (a6)+,d0-d7/a0-a5     ;ca doit marcher!
          move.l (a6),a6
trahpapel:trap #3                       ;modifie par le programme!
          move.l trahpile,a7            ;reprend la pile! OUF!
; retour d'appel pour CALL
callret:  move.l a6,14*4+callreg        ;sauve le registre A6
          lea 14*4+callreg,a6
          movem.l d0-d7/a0-a5,-(a6)     ;sauve les autres registres
          movem.l (sp)+,a4-a6           ;recupere les registres importants
          rts

;-----------------------------------------    --- ----- ---   ---    -------
;   -----------------------------------      |      |  |   | |
;  |  ECRANS, GRAPHIQUES, ET  SPRITES  |      ---   |  |   |  ---
;   -----------------------------------          |  |  |   |     |
;-----------------------------------------    ---       ---   ---    -------
; RAMENE D0(1-6) OPERANDES ENTIERS, SEPARES PAR "," EN D1/D2/D3/D4/D5/D6
mentiers: clr.l d0
          move.b (a6),d7
          beq.s munt2
          cmp.b #":",d7
          beq.s munt2
          cmp.b #$9b,d7                 ;ELSE?
          beq.s munt2
munt1:    movem.l d0-d6,-(sp)
          cmp.b #",",(a6)               ;accepte: a,,b,,c...
          bne.s munt0
          addq.l #1,a6
          clr.l d3
          bra.s munt05
munt0:    bsr expentier
munt05:   move.l d3,d0
          movem.l (sp)+,d1-d7
          exg d0,d1
          addq #1,d0
          cmp.b #",",(a6)+
          beq.s munt1
          subq.l #1,a6
munt2:    rts

; ADECRAN: ramene et verifie une adresse d'ecran
adecran:  cmp.l #16,d3
          bcc.s adec1
          bsr adoubank
          and #$7f,d0
          cmp.b #2,d0         ;est-ce un ecran?
          bne notscreen
adec1:    tst.b d3            ;cette adresse DOIT etre un multiple de 256
          bne pas256
          cmp.l deflog,d3     ;et pas superieure a l'ecran par defaut!
          bhi foncall
          rts

; fonction: LOGICAL
logical:  move.l adlogic,d3
          clr.b d2
          rts

; fonction: PHYSICAL
physical: move.l adphysic,d3
          clr.b d2
          rts

; fonction: BACKGROUND
backgrnd: move.l adback,d3    ;adresse du decor
          clr.b d2
          rts

; fonction: DEFAULT
default:  cmp.b #$c8,(a6)     ;logic
          beq.s dflt1
          cmp.b #$e1,(a6)     ;physic
          beq.s dflt1
          cmp.b #$e2,(a6)     ;back
          bne syntax
          move.l defback,d3
          bra dflt2
dflt1:    move.l deflog,d3
dflt2:    addq.l #1,a6
          clr.b d2
          rts

; instruction DEFAULT
defolt:   jmp redessin        ;refait completement l'ecran!

; LOGICAL
loginst:  cmp.b #$f1,(a6)+    ;veut un egal
          bne syntax
          bsr expentier       ;va evaluer l'expression
          bsr adecran         ;va verifier les adresses ecran
logicbis: move.l d3,adlogic
          move.w #-1,-(sp)
          move.l #-1,-(sp)
          move.l d3,-(sp)     ;change LOGICAL seulement
          move.w #5,-(sp)     ;SETSCREEN
          trap #14
          add #12,sp
          rts

; PHYSICAL
physinst: cmp.b #$f1,(a6)+
          bne syntax
          bsr expentier
          bsr adecran
physicbis:move.l d3,adphysic
          move.w #-1,-(sp)
          move.l d3,-(sp)
          move.l #-1,-(sp)
          move.w #5,-(sp)     ;SETSCREEN
          trap #14
          add #12,sp
          rts

; SCREEN SWAP: echange LOGIC (et BACK) et PHYSIC: GENIAL!
scrswap:  move.l adphysic,-(sp)
          move.l adlogic,d3
          cmp.l adback,d3     ;si LOGIC = BACK
          bne.s scrsw1
          move.l (sp),d3      ;change aussi BACK ---> PHYSIC
          bsr backbis
          move.l adlogic,d3
scrsw1:   bsr physicbis       ;change l'ecran PHYSIQUE
          move.l (sp)+,d3
          bra logicbis        ;change l'ecran LOGIQUE

; BACKGROUND
backinst: cmp.b #$f1,(a6)+
          bne syntax
          bsr expentier
          bsr adecran
backbis:  move.l d3,adback
          move.l d3,a0
          moveq #27,d0        ;change screen sprites
          trap #5
          move.l d3,a0
          moveq #19,d7        ;change back fenetres
          trap #3
          rts

; MODE en fonction
fnmode:   clr.l d3
          move mode,d3
          clr.b d2
          rts

; MODE en instruction
setmode:  bsr expentier
          cmp.l #2,d3
          bcc foncall
          cmp #2,mode
          beq cantres         ;can't change resolution
          bsr maude
          bra modebis

; Entree pour default
maude:    moveq #28,d0
          trap #5             ;stop mouse!
          bsr waitvbl
          move.l adback,a0
          move #3999,d0
          clr.l d1
maude1:   move.l d1,(a0)+
          move.l d1,(a0)+
          dbra d0,maude1
          bsr waitvbl
          move.l adlogic,a0
          move #3999,d0
maude2:   move.l d1,(a0)+
          move.l d1,(a0)+
          dbra d0,maude2
          bsr waitvbl
          move d3,mode        ;change la resolution
          move.w d3,-(sp)
          move.l #-1,-(sp)
          move.l #-1,-(sp)
          move.w #5,-(sp)     ;SETSCREEN
          trap #14
          add #12,sp
          bsr waitvbl         ;empeche le BUG!
          rts
;INITIALISATION DES TRAPPES (entree pour REDESSIN)
modebis:  movem.l d0-d7/a0-a6,-(sp)
          clr d0
          trap #5             ;initmode sprites
          move #10,d7
          trap #3             ;initmode fenetres
          move d0,nbjeux      ;nombre de jeux de caracteres par defaut!
          bsr putchar         ;remet les jeux de caracteres !!!
          clr typecran 
          clr fenetre
          clr mousflg
          move #1,actualise
          move #1,autoback
          tst runflg
          bne.s md03
          jsr zonecran
          jsr pokeamb
md03:     jsr curseur         ;met (ou non) le curseur
          tst mnd+12
          beq.s md05
; la barre de menu est affichee!!!
          clr d0
          move #9,d7
          trap #3             ;arret du plein ecran
          tst mnd+10
          bne.s md04
          moveq #10,d0        ;menu UNE ligne
          bra.s md04a
md04:     moveq #12,d0        ;menu DEUX lignes
md04a:    jsr defaut
          move #20,d0
          clr d7
          trap #3             ;arret du curseur
          move #25,d0
          trap #3             ;scrolloff
          jsr affbarre        ;va afficher la barre
          tst mnd+10
          bne.s md04b
          moveq #9,d0
          bra md04c
md04b:    moveq #11,d0
md04c:    jsr defaut
          bra.s md10            ;saute toutes les touches de fonction!

md05:     tst foncon          ;pas de touche de fonction: on reste comme ca!
          beq.s md10
;les touches de fonction sont en route: affichage
          clr d0
          move #9,d7
          trap #3             ;arret du plein ecran
          move #8,d0
          jsr defaut          ;creation de la fenetre de fonction
          move #20,d0
          clr d7
          trap #3             ;arret du curseur
          move #25,d0
          trap #3             ;scrolloff
          move #0,d0
          jsr affonc
          jsr defaut          ;fenetre de texte
	bsr zofonc	;Envoie les zones

;initialisation LIGNE A
md10:     dc.w $a000                    ;init ligne A
          move.l a0,laad                ;adresse de la ligne A
          move.l 8(a0),laintin          ;adresse de intin
          move.l 12(a0),laptsin         ;adresse de ptsin
;init GRAPHIQUES
          move mode,d0
          lsl #3,d0
          lea maxmode,a0
          clr.l d3
          move.w 0(a0,d0.w),d3
          move.l d3,xmax                ;maximum en X pour la resolution
          move.w 2(a0,d0.w),d3
          move.l d3,ymax                ;maximum en Y pour la resolution
          move.w 4(a0,d0.w),d3
          move.l d3,colmax              ;couleur maximum "  "      "
          clr valpaper
          subq #1,d3
          move d3,valpen
          move #1,autoback
          clr.w xgraph                  ;origine graphique
          clr.w ygraph
;init tables du VDI
          move mode,d0
          mulu #$72,d0
          lea vdimode,a0
          add d0,a0                     ;pointe la table VDI du mode
          move.l ada,a2
          move.l 12(a2),a1              ;adresse table du VDI 1
          moveq #$5a/2-1,d0
md12:     move.w (a0)+,(a1)+            ;poke dans la table
          dbra d0,md12
          move.l 16(a2),a1              ;adresse table du VDI 2
          moveq #$18/2-1,d0
md13:     move.w (a0)+,(a1)+
          dbra d0,md13
; initialisation d'une workstation
          move.l $84,buffer
          move.l #trp1,$84    ;init fausse trappe #1
          move #100,contrl
          move #0,contrl+2
          move #11,contrl+6
          move #0,contrl+12
          move #1,intin
          move #1,intin+2
          move #1,intin+4
          move #1,intin+6
          move #1,intin+8
          move #1,intin+10
          move #1,intin+12
          move #1,intin+14
          move #1,intin+16
          move #1,intin+18
          move #2,intin+20
          bsr vdi   
          move.w contrl+12,d0
          move d0,grh         ;graphic handle
          move.l buffer,$84   ;remet la trappe1

;pas de CLIP
          bsr clipoff
;init du WRITING
          moveq #1,d3                   ;writing normal
          bsr writebis
;init de la COULEUR
          moveq #1,d3              	;encre graphique = 1
          bsr inkbis
          clr valpaper
          move #1,valpen
;init des POLYLINES
          moveq #0,d1                   ;debut carre
          moveq #0,d2                   ;fin carree
          moveq #1,d3                   ;largeur 1
          move #$ffff,d4                ;ligne parcourue
          bsr slinebis
;init des POLYMARKER
          moveq #3,d2                   ;etoile
          moveq #4,d1
          bsr smarkbis
;init du PAINT
          moveq #1,d3                   ;met la bordure
          moveq #1,d2
          moveq #1,d1                   ;rempli avec de la couleur
          bsr spaintbis
; Init du defscroll/scroll
          lea dfst,a0                   ;Table de def scroll
          moveq #8*8-1,d0
isc:      clr.w (a0)+
          dbra d0,isc
          movem.l (sp)+,d0-d7/a0-a6
          rts

; fausse trappe 1
trp1:     cmp #$48,6(sp)
          beq.s trp2
          cmp #$49,6(sp)
          beq.s trp3
          move.l buffer,-(sp)
          rts
trp2:     move.l #work,d0               ;"MALLOC" !
          rte
trp3:     clr.l d0                      ;"MFREE" !
          rte

; Initialisation des zones des touches de fonction
zofonc:	clr.w mousflg
	tst.w foncon
	beq.s md4
          tst mode
          beq.s md2             ;Zones a tester dans l'ecran
          cmp #1,mode
          beq.s md1
          lea z3,a2     ;hires
          bra.s md3
md1:      lea z2,a2     ;midres
          bra.s md3
md2:      lea z1,a2     ;lowres
md3:      jsr envzone
md4:	rts

; WAITVBL: ATTEND LE RETOUR DU BALAYAGE
waitvbl:  move.w #37,-(sp)
          trap #14
          addq.l #2,sp
          rts

; WAIT xx: ATTEND xx 50ieme de seconde
wait:     bsr expentier
waitbis:  tst.l d3
          beq foncall
          bmi foncall
          move.l d3,waitcpt
wait1:    bsr avantint        ;attend que le compteur arrive a zero
          tst.l waitcpt
          bne.s wait1
          rts

; WAIT KEY: attend qu'on appuie sur une touche
waitkey:  jsr avantint
          jsr incle
          tst.l d0
          beq waitkey
          rts

; PALETTE
palet:    move.l adlogic,a0   ;poke la palette dans l'image logique
          add.l #32000,a0
          bsr s               ;va lire la palette!
; envoie la palette au XBIOS, si physic=logic (et copie dans back)
setpalet: move.l adlogic,a0   ;image physique
          cmp.l adphysic,a0   ;image logique
          bne.s s7
s5:       add.l #32000,a0     ;palette logique
          move.l a0,a1
          move.l adback,a2
          add.l #32000,a2     ;palette back
          moveq #15,d0
s6:       move.w (a1)+,(a2)+  ;copie la palette
          dbra d0,s6
          move.l a0,-(sp)
          move.w #6,-(sp)
          trap #14            ;envoie!!!
          addq.l #6,sp
s7:       rts

; Sous programme: lis la palette/set flags D1---> couleurs precisee!
s:        moveq #0,d0
          moveq #0,d1
s0:       bsr finie
          beq.s s7
          cmp.b #",",(a6)
          beq.s s1
          movem.l d0-d1/a0,-(sp)
          bsr expentier
          movem.l (sp)+,d0-d1/a0
          move.l d3,d2
          and.l #$777,d2
          cmp.l d2,d3
          bne foncall
          move.w d0,d2
          lsl.w #1,d2
          move.w d3,0(a0,d2.w)
          bset d0,d1
s1:       addq #1,d0
          cmp #16,d0
          bcc.s s7
          bsr finie
          beq.s s7
          cmp.b #",",(a6)+    ;virgule apres?
          beq.s s0
          bne syntax

; GET PALETTE(adecran): ENVOIE AU XBIOS LA PALETTE DE L'IMAGE
getpalet: lea bufcalc,a3
          bsr fentier
          bsr adecran
          move.l d3,a0
          move.l a0,a1
          move.l adlogic,a2   
          lea 32000(a1),a1
          lea 32000(a2),a2
          moveq #15,d0
gtp:      move.w (a1)+,(a2)+  ;copie dans LOGIC
          dbra d0,gtp
          bra s5              ;copie dans le decor et revient5

; COLOR nn,CC: instruction COLOR
color:    bsr mentiers
          cmp #2,d0
          bne syntax
          cmp.l #16,d2
          bcc foncall
          cmp.l #$10000,d1
          bcc foncall
          lsl #1,d2
          move.l adlogic,a0
          add.l #32000,a0
          add d2,a0           ;pointe la couleur
          move.w d1,(a0)      ;poke la couleur
          bra setpalet        ;envoie la palette si logic=physic (genial)

; COLOR (nn): fonction COLOR
colorf:   bsr fentier
          cmp.l #16,d3
          bcc foncall
          lea $ff8240,a0
          lsl #1,d3
          add d3,a0
          move.w 0(a0),d3
          and.l #$777,d3
          clr.b d2
          rts

; =XMOUSE fonction
xmouse:   move #20,d0         ;MOUSE -> d0 et d1
          trap #5
          clr.l d3
          move.w d0,d3
          clr.b d2
          rts

; =YMOUSE fonction
ymouse:   move #20,d0
          trap #5
          clr.l d3
          move.w d1,d3
          clr.b d2
          rts

; XMOUSE en instruction: XMOUSE=xx
xminst:   cmp.b #$f1,(a6)+
          bne syntax
          bsr expentier
          move.l d3,d1
          bmi foncall
          moveq #-1,d2
          moveq #44,d0
          trap #5
          rts

; YMOUSE en instruction
yminst:   cmp.b #$f1,(a6)+
          bne syntax
          bsr expentier
          move.l d3,d2
          bmi foncall
          moveq #-1,d1
          moveq #44,d0
          trap #5
          rts

; MOUSE KEY= fonction
mousekey: move #21,d0
          trap #5
          clr.l d3
          move.b d0,d3
          clr.b d2
          rts

; = JOY : position du joystick
joy:      clr.b d2
          clr.l d3
          move.l ada,a0
          move.l 4(a0),a0
          move.b (a0),d3      ;#$e09...
          move.l adm,a0
          btst #1,7(a0)
          beq.s joy1
          bset #4,d3
joy1:     rts

; FIRE: vrai si appuie sur FEU
fire:     move.l adm,a0
          btst #1,7(a0)
          beq.s jfalse
          bne.s jtrue
; JRIGHT: vrai si va a droite
jright:   move.l ada,a0
          move.l 4(a0),a0
          btst #3,(a0)
          beq.s jfalse
          bne.s jtrue
; JLEFT: vrai si va a gauche
jleft:    move.l ada,a0
          move.l 4(a0),a0
          btst #2,(a0)
          beq.s jfalse
          bne.s jtrue
; JDOWN: vrai si descend
jdown:    move.l ada,a0
          move.l 4(a0),a0
          btst #1,(a0)
          beq.s jfalse
          bne.s jtrue
; JUP: vrai si monte! GENIAL
jup:      move.l ada,a0
          move.l 4(a0),a0
          btst #0,(a0)
          bne.s jtrue
jfalse:   clr.b d2
          clr.l d3
          rts
jtrue:    clr.b d2
          moveq #-1,d3
          rts
 
; SHOW / SHOW ON
show:     moveq #17,d2
          bra.s hid0
; HIDE / HIDE ON
hide:     moveq #18,d2
hid0:     moveq #-1,d1
          bsr finie
          beq.s hid1
          bsr onoff
          bmi syntax
          beq syntax
          clr.l d1
hid1:     move.l d2,d0
          trap #5
          rts

; CHANGE MOUSE
chgmouse: bsr expentier
          tst.l d3
          beq foncall
          bmi foncall
          move.l d3,d1
          move #19,d0
          trap #5
          rts

; LIMIT MOUSE X1,Y1 TO X2,Y2
limouse:  bsr finie
          beq.s limous1
          bsr mentiers
          cmp #2,d0
          bne syntax
          cmp.l xmax,d2
          bcc foncall
          cmp.l ymax,d1
          bcc foncall
          exg d1,d2
          movem d1-d2,-(sp)
          cmp.b #$80,(a6)+
          bne syntax
          bsr mentiers
          cmp #2,d0
          bne syntax
          cmp.l xmax,d2
          bcc foncall
          cmp.l ymax,d1
          bcc foncall
          move d2,d3
          move d1,d4
          movem (sp)+,d1-d2
          bra.s limous2
limous1:  clr.l d3
limous2:  move #32,d0         ;LIMOUSE
          trap #5
          rts

; a$=SCREEN$ ( adecran , x1,y1 to x2,y2 ): FONCTION SCREEN$
scrfonc:  move.w parenth,-(sp)
          cmp.b #"(",(a6)+
          bne syntax
          clr.w parenth
          bsr entierbis
          bsr adecran
          move.l d3,-(sp)       ;Pousse l'adresse ecran
          cmp.b #",",(a6)+
          bne syntax
          bsr entierbis         ;Prend X1
          move.l d3,-(sp)
          cmp.b #",",(a6)+
          bne syntax
          bsr entierbis         ;Prend Y1
          move.l d3,-(sp)
          cmp.b #$80,(a6)+
          bne syntax
          bsr getentier
          cmp.w #2,d0
          bne syntax
          move.l d1,d3
          move.l d2,d4
          move.l (sp)+,d2
          move.l (sp)+,d1       ;D1/D2= X1/Y1 - D2/D3= X2/Y2
          move.l (sp)+,a1       ;A0= adresse ecran
          move.w (sp)+,parenth
; Teste les limites
          and.w #$fff0,d1
          and.w #$fff0,d3
          cmp.l xmax,d1
          bcc foncall
          cmp.l ymax,d2
          bcc foncall
          cmp.l xmax,d3
          bhi foncall
          cmp.l ymax,d4
          bhi foncall
          sub.l d1,d3           ;Calcule TX et TY
          bcs foncall
          beq foncall
          sub.l d2,d4
          bcs foncall
          beq foncall
          move.w d3,d5
          lsr.w #4,d5
          mulu d4,d5            ;TX*TY
          moveq #3,d0
          sub.w mode,d0
          lsl.w d0,d5           ;fois NBPLANS*2
          addq.l #8,d5          ;plus flags---> taille de la chaine
          movem.l a1/d1/d2/d3/d4,-(sp)
          move.l d5,d3
          bsr demande
          move.l a0,a2          ;debut de la chaine
          move.w d3,(a2)+       ;poke la taille
          movem.l (sp)+,a1/d1/d2/d3/d4
; Appel de la trappe
          move.l a0,-(sp)
          moveq #51,d0
          trap #5
          move.l d0,a0          ;Ramene la fin de la chaine
          move.l (sp)+,a1       ;Debut de la chaine
          bra mid7a

; SCREEN$ ( adecran,x,y )=a$: INSTRUCTION SCREEN$
scrinst:  lea bufcalc,a3
          cmp.b #"(",(a6)+
          bne syntax
          bsr getentier
          cmp.w #3,d0
          bne syntax

          movem.l d2/d3,-(sp) ;Calcule l'adresse ecran
          move.l d1,d3
          bsr adecran
          move.l d3,-(sp)

          cmp.b #$f1,(a6)+    ;Cherche un egal
          bne syntax
          bsr expalpha        ;va chercher la chaine
          cmp.w #8,d2
          bcs.s st2
          move.l a2,a1        ;Adresse chaine
          move.l (sp)+,a2     ;recupere l'adresse de l'ecran
          movem.l (sp)+,d1-d2 ;recupere X/Y  
; Appel de la trappe
          moveq #52,d0
          trap #5
          tst d0
          beq.s st1
st2:      moveq #87,d0        ;String is not a screen bloc
          bra erreur
st1:      rts

; SCREEN COPY ec1[,x1,y1,x2,y2] to ec2[,x3,y3] ! PAS SUCCEPTIBLE !
; C'EST L'INSTRUCTION LA PLUS GENIALE QU'ON AI JAMAIS FAIT DANS UN BASIC
scrcopy:  bsr expentier
          bsr adecran
          move.l d3,-(sp)     ;adresse de l'ecran 1
          move.b (a6)+,d0
          cmp.b #$80,d0
          beq.s scc1
          cmp.b #",",d0
          bne syntax
          bsr mentiers
          cmp #4,d0
          bne syntax
          move d2,d5
          move d1,d6
          move d4,d1          ;remet dans l'ordre
          move d3,d2
          clr d0              ;flag: pas tout l'ecran!
          cmp.b #$80,(a6)+
          bne syntax
          beq.s scc2
scc1:     moveq #1,d0         ;flag: tout l'ecran!
scc2:     movem d0/d1/d2/d5/d6,-(sp)
          bsr expentier
          bsr adecran
          move.l d3,a1        ;adresse ecran 2
          cmp.b #",",(a6)
          beq.s scc3
          movem (sp)+,d0/d1/d2/d5/d6
          tst d0              ;tout l'ecran!
          beq syntax
          clr d5
          bra scc20
scc3:     addq.l #1,a6        ;dernier parametres
          move.l a1,-(sp)
          bsr mentiers
          move.l (sp)+,a1
          cmp #2,d0
          bne syntax
          move d1,d4
          move d2,d3
          movem (sp)+,d0/d1/d2/d5/d6

          bsr scalc           ;Va faire les calculs
          bne pascc1          ;Pas de screen copy

scc20:    move.l (sp)+,a0     ;recupere la premiere adresse
          move #33,d0         ;screen copy
          trap #5
          rts

; FAIT TOUS LES TESTS!
; TESTE L'ORIGINE
scalc:    moveq #0,d7
          move d1,d7          ;garde le decalage en D7
          and #$fff0,d1
          and #$fff0,d3
          and #$fff0,d5
          and #$f,d7 
          move d2,-(sp)
          move d1,-(sp)
          tst d1              ;X1
          bpl.s scc6
          clr d1
          bset #31,d7         ;met le flag: tronqu‚ a gauche!!!
scc6:     cmp.w xmax+2,d1
          bcc pascc1
          tst d2              ;Y1
          bpl.s scc7
          clr d2
scc7:     cmp.w ymax+2,d2
          bcc pascc1
          tst d5              ;X2
          bmi pascc1
          beq pascc1
          cmp.w xmax+2,d5
          bcs.s scc8
          move.w xmax+2,d5
scc8:     tst d6              ;Y2
          bmi pascc1
          beq pascc1
          cmp.w ymax+2,d6
          bcs.s scc9
          move.w ymax+2,d6
scc9:     sub d1,d5           ;calcule TX
          bcs pascc1
          beq pascc1
          sub d2,d6           ;calcule TY
          beq pascc1
          bcs pascc1
; TESTE L'ARRIVEE
          move d1,d0
          sub (sp)+,d0
          add d0,d3           ;decale l'arrivee vers la droite
          btst #31,d7
          beq.s scc9a
          and.w #$000f,d7
          beq.s scc9a           ;Si coupe a gauche ET decalage,
          sub.w #16,d3
          add.w #16,d5
scc9a:    move d2,d0
          sub (sp)+,d0
          add d0,d4           ;decale l'arrivee vers le bas
          cmp xmax+2,d3
          bge pascc2
          cmp ymax+2,d4
          bge pascc2
; limite l'arrivee a gauche
          tst d3
          bpl.s scc10
          move d3,d0
          clr d3
          neg d0              ;taille rajoutee!
          sub d0,d5           ;diminue TX
          bcs.s pascc2
          beq.s pascc2        ;si plus grand: sortie!!!
          add d0,d1           ;decale a droite X1
; limite l'arrivee en haut
scc10:    tst d4
          bpl.s scc11
          move d4,d0
          clr d4
          neg d0
          sub d0,d6
          bcs pascc2
          beq pascc2
          add d0,d2
; limite l'arrivee a droite
scc11:    move d3,d0
          add d5,d0
          sub xmax+2,d0
          bcs scc12
          sub d0,d5           ;limite la TX
          beq pascc2
; limite l'arrivee en bas
scc12:    move d4,d0
          add d6,d0
          sub ymax+2,d0
          bcs scc13
          sub d0,d6           ;limite la TY
          beq pascc2
; les tests sont finis! OUF!
scc13:    moveq #0,d0         ;Pas d'erreur!
          rts
pascc1:   addq.l #4,sp
pascc2:   moveq #1,d0         ;erreur!
          rts

; DEF SCROLL N,X1,Y2 TO X2,Y2,DX,DY
defsc:    bsr expentier         ;Prend le numero
          subq.l #1,d3
          cmp.l #16,d3          ;1-16 scrollings
          bcc foncall
          move.w d3,-(sp)
          cmp.b #",",(a6)+
          bne syntax
          bsr mentiers
          cmp.w #2,d0
          bne syntax
          exg d1,d2
          movem.l d1-d2,-(sp)
          cmp.b #$80,(a6)+      ;TO?
          bne syntax
          bsr mentiers          ;6 parametres, pas de facultatif!
          cmp.w #4,d0
          bne syntax
          exg d1,d2
          move.l d4,d5
          move.l d3,d6
          movem.l (sp)+,d3-d4
          and.w #$fff0,d3       ;Multiple de 16 en X
          neg.l d1
          neg.l d2
          add.l d3,d1
          add.l d4,d2
          bsr scalc             ;Calcule les parametres screen copy
          bne foncall           ;Erreur de fonction!
          move.w (sp)+,d0       ;Numero du scrolling
          mulu #16,d0    
          lea dfst,a0
          add.w d0,a0
          move.w d1,(a0)+       ;Stocke dans la table
          move.w d2,(a0)+
          move.w d3,(a0)+
          move.w d4,(a0)+
          move.w d5,(a0)+
          move.w d6,(a0)+
          move.l d7,(a0)
          rts

; SCROLL N
scr:      bsr expentier
          subq.l #1,d3
          cmp.l #16,d3
          bcc foncall
          mulu #16,d3           ;Pointe le scrolling dans la table
          lea dfst,a0
          add.w d3,a0
          move.w (a0)+,d1
          move.w (a0)+,d2
          move.w (a0)+,d3
          move.w (a0)+,d4
          move.w (a0)+,d5       ;Jamais de taille nulle!
          beq.s scr1 
          move.w (a0)+,d6
          beq.s scr1
          move.l (a0),d7
          move.l adlogic,a0     ;Travaille dans l'ecran logique
          move.l a0,a1  
          moveq #33,d0          ;SCREEN COPY
          trap #5
          rts
scr1:     moveq #86,d0          ;Scrolling non defini
          bra erreur    

; SSPGM ON/OFF: ramene 0 si OFF, 1 si ON, -1 si NI L'UN NI L'AUTRE!
onoff:    move.b (a6)+,d0
          cmp.b #$a6,d0         ;Off
          beq.s onof1
          cmp.b #$a7,d0         ;On
          beq.s onof2
          cmp.b #$a5,d0         ;Freeze
          beq.s onof3
          subq.l #1,a6
          moveq #-1,d0        ;autre: Bmi et Bcc
          rts
onof1:    clr d0              ;Off: Beq
          rts
onof2:    moveq #1,d0         ;On: Bne
          rts
onof3:    clr d0              ;Freeze: Bmi et Bcs
          subq #1,d0
          rts

; SSPGM FINIE: BEQ si l'instruction est finie, BNE sinon
finie:    tst.b (a6)
          beq.s fin1
          cmp.b #":",(a6)
          beq.s fin1
          cmp.b #$9b,(a6)
fin1:     rts

; SYNCHRO [ON/OFF]: chainage des interruptions
sync:     bsr onoff
          bmi.s sy2
          bne.s sy1
; Interruptions arretees
          moveq #0,d1
          moveq #48,d0
          trap #5
          rts
; Interruptions en route
sy1:      moveq #1,d1
          moveq #48,d0
          trap #5
          rts
; Un cran d'interruptions
sy2:      moveq #49,d0
          trap #5
          rts

; UPDATE
update:   bsr onoff
          bmi.s upd2
          bne.s upd1
          clr actualise       ;update off
          moveq #40,d7
          moveq #0,d0
          trap #3
          rts
upd1:     move #1,actualise   ;update on
          moveq #40,d7
          moveq #1,d0
          trap #3
          rts
upd2:     bcs syntax
          moveq #16,d0        ;actualise!
          trap #5
upd3:     rts

; REDRAW: redessine les sprites en l'etat!
redraw:   moveq #47,d0
          trap #5
          rts

; SPRITE
sprite:   bsr onoff
          bmi.s spr5
          bne.s spr0
          clr d2              ;off
          bra.s spr05
spr0:     moveq #1,d2         ;on
spr05:    move d2,-(sp)
          bsr finie
          beq.s spr1
          bsr expentier       ;sprite on/off xx
          move.l d3,d1
          moveq #8,d0
          bra.s spr2
spr1:     moveq #7,d0         ;sprite on/off
spr2:     move (sp)+,d2
          trap #5
          tst d0
          bne spriterr
          rts
; sprite NN,XX,YY,DD
spr5:     bcs syntax
          bsr mentiers
          cmp #4,d0
          beq.s spr6
          cmp #3,d0
          bne syntax
          exg d1,d3
          clr.l d4
          bra.s spr7
spr6:     exg d1,d4
          exg d2,d3
spr7:     moveq #9,d0         ;SPRNXYA
          trap #5
          tst d0
          bne spriterr
          rts

; MOVE on/off/freeze [xx]
mouve:    bsr onoff
          bcs.s mv1
          bmi syntax
          bne.s mv2
          clr d2              ;Off
          bra.s mv3
mv1:      moveq #1,d2         ;Freeze
          bra.s mv3
mv2:      moveq #2,d2         ;On
mv3:      move d2,-(sp)
          bsr finie
          beq.s mv4
          bsr expentier
          move.l d3,d1
          moveq #11,d0
          bra.s mv5
mv4:      moveq #10,d0
mv5:      move (sp)+,d2
          trap #5
          tst d0
          bne mouverr
          rts

; MOVE Y
mouvey:   move #1,-(sp)
          bra.s mx1
; MOVE X xx,a$ / MOVE Y yy,a$
mouvex:   clr -(sp)
mx1:      bsr expentier
          bne syntax
          move.l d3,-(sp)
          cmp.b #",",(a6)+
          bne syntax
          bsr expalpha
          tst d2
          beq foncall
          cmp #250,d2
          bcc stoolong
          bsr chverbuf
          lea buffer,a0
          move.l (sp)+,d1     ;numero du sprite
          move (sp)+,d2       ;en X ou en Y
          move #12,d0
          trap #5
          tst d0
          bne mouverr
          rts

; MOVON (xx): fonction: 0= arrete, 1= move x, 2= movey, 3= les deux
movon:    bsr fentier
          tst.l d3
          beq foncall
	bmi foncall
          move.l d3,d1
          moveq #45,d0
          trap #5
          move.l d0,d3
          clr.b d2
          rts

; ANIM on/off/freeze [xx]
anime:    bsr onoff
          bcs.s an1
          bmi.s an10
          bne.s an2
          clr d2              ;Off
          bra.s an3
an1:      moveq #1,d2         ;Freeze
          bra.s an3
an2:      moveq #2,d2         ;On
an3:      move d2,-(sp)
          bsr finie
          beq.s an4
          bsr expentier
          move.l d3,d1
          moveq #14,d0
          bra.s an5
an4:      moveq #13,d0
an5:      move (sp)+,d2
          trap #5
          tst d0
          bne animerr
          rts
; ANIM X xx,a$
an10:     clr -(sp)
          bsr expentier
          bne syntax
          move.l d3,-(sp)
          cmp.b #",",(a6)+
          bne syntax
          bsr expalpha
          tst d2
          beq foncall
          cmp #250,d2
          bcc stoolong
          bsr chverbuf
          lea buffer,a0
          move.l (sp)+,d1     ;numero du sprite
          move (sp)+,d2       ;en X ou en Y
          move #15,d0
          trap #5
          tst d0
          bne animerr
          rts

; COLLIDE (#sprite,tx,ty)
collide:  cmp.b #"(",(a6)+
          bne syntax
          bsr getentier
          cmp #3,d0
          bne syntax
	tst.l d1
	bmi foncall
          cmp.l xmax,d2       ;TX
          bcc foncall
          cmp.l ymax,d3       ;TY
          bcc foncall
          moveq #5,d0         ;trap #5, fonction #5: BOUM
          trap #5
          clr.b d2
          move.l d0,d3
          rts

; FREEZE: arrete tout!
freeze:   moveq #4,d0         
          trap #7             ;music freeze
fz1:      moveq #1,d2
          moveq #10,d0
          trap #5             ;move freeze
          moveq #13,d0
          trap #5             ;anim freeze
          rts

; UNFREEZE: remet tout en route
unfreeze: moveq #5,d0         ;unfreeze music
          trap #7
ufz1:     moveq #2,d2         ;ON!
          moveq #10,d0
          trap #5             ;move on
          moveq #13,d0
          trap #5             ;anim on
          rts

; =XSPRITE (xx)
xsprite:  bsr fentier
	tst.l d3
          bmi foncall
          move.l d3,d1
          moveq #6,d0
          trap #5
          move d0,d3
          ext.l d3
          clr.b d2
          rts

; =YSPRITE (xx)
ysprite:  bsr fentier
          tst.l d3
          bmi foncall
          move.l d3,d1
          moveq #6,d0
          trap #5
          move d1,d3
          ext.l d3
          clr.b d2
          rts

; DETECT (xx): ramene le pixel SOUS le point chaud, -1 si en dehors ecran
dtct:     bsr fentier
          tst.l d3
          bmi foncall
          move.l d3,d1        ;Demande a la trappe
          moveq #6,d0
          trap #5
          cmp.w xmax+2,d0     ;Si sort de l'ecran---> -1
          bcc.s dtc1
          cmp.w ymax+2,d1
          bcc.s dtc1
          move.l laptsin,a2
          move.w d0,(a2)      ;poke X
          move.w d1,2(a2)     ;poke Y
          moveq #28,d0        ;stopmouse
          trap #5
          move.l adback,$44e
          dc.w $a002          ;LIGNE A: GET PIXEL
          move.l adlogic,$44e
          moveq #0,d3
          move.w d0,d3
          clr.b d2
          move #41,d0         ;MOUSEBETE: remet la souris
          trap #5
          rts
dtc1:     moveq #-1,d3        ;Ramene -1 si sprite en dehors de l'ecran
          clr.b d2
          rts

; RESET ZONE [X]
reszone:  tst runflg
          beq illdir
          bsr finie
          beq.s inizone
; reset zone X
          bsr expentier
          tst.l d3
          bmi foncall
          move d3,d1
          moveq #0,d2
          moveq #1,d3
          moveq #0,d4
          moveq #1,d5
          moveq #25,d0
          trap #5
          rts
; reset toutes les zones
inizone:  moveq #36,d0           ;entree de l'editeur
          trap #5
          rts

; ZONE (XX)
zone:     tst runflg
          beq illdir
          bsr fentier
          tst.l d3
          bmi foncall
          move.l d3,d1
          moveq #26,d0
          trap #5
          clr.l d3
          move d1,d3
          clr.b d2
          rts

; SET ZONE aa,x1,y1 TO x2,y2
setzone:  tst runflg
          beq illdir
          bsr mentiers
          cmp #3,d0
          bne syntax
          movem.l d1-d3,-(sp)
          cmp.b #$80,(a6)+
          bne syntax
          bsr mentiers
          cmp #2,d0
          bne syntax
          move.l d1,d4
          move.l d2,d5
          movem.l (sp)+,d1-d3
          exg d1,d3           ;c'est les tours de hanoi!
          exg d3,d5
          exg d4,d5
          cmp.l xmax,d2
          bcc foncall
          cmp.l xmax,d3
          bcc foncall
          cmp.l ymax,d4
          bcc foncall
          cmp.l ymax,d5
          bcc foncall
          add.l #640,d2
          add.l #640,d3
          add.l #400,d4
          add.l #400,d5
          moveq #25,d0
          trap #5
          tst d0
          bne foncall
          rts

; PRIORITY ON/OFF
priority: bsr onoff
          bmi syntax
          bne.s pn
          clr d1
          bra.s pn1
pn:       moveq #1,d1
pn1:      moveq #4,d0
          trap #5
          rts

; LIMIT SPRITE x1,y1 TO x2,y2 / LIMIT SPRITE
limsprite:bsr finie
          bne.s ls1
          move #-1000,d1      ;enleve les limites!
          clr d2
          clr d3
          clr d4
          bra.s ls10
ls1:      bsr mentiers
          cmp #2,d0
          bne syntax
          move.l d1,-(sp)
          move.l d2,-(sp)
          cmp.b #$80,(a6)+
          bne syntax
          bsr mentiers
          cmp #2,d0
          bne syntax
          move.l d1,d4
          move.l (sp)+,d1
          move.l (sp)+,d3
ls10:     moveq #2,d0         ;la trappe veut: d1=X1/d2=X2/d3=Y1/d4=Y2
          trap #5
          rts

; PUT SPRITE xx
putspr:   bsr expentier
          move.l d3,d1
          moveq #35,d0
          trap #5
          rts

; GET SPRITE xx,yy,nn[,transparent]
getspr:   bsr mentiers
          cmp #4,d0
          beq.s gs1
          cmp #3,d0
          bne syntax
          clr d4
          exg d1,d3
          bra.s gs2
gs1:      exg d1,d4
          exg d2,d3
gs2:      moveq #37,d0
          trap #5
          tst d0
          bne foncall
          rts

; REDUCE [ecran] TO [ecran,]x1,y1,x2,y2
reduce:   cmp.b #$80,(a6)
          beq rdc0
; ecran d'origine fixe
          bsr expentier
          bsr adecran
          move.l d3,-(sp)
          cmp.b #$80,(a6)+
          beq.s rdc1
          bne syntax
; ecran d'origine par defaut: LOGIC
rdc0:     addq.l #1,a6
          move.l adlogic,-(sp)
; parametres de destination
rdc1:     bsr mentiers
          cmp #5,d0
          beq.s rdc2
          cmp #4,d0
          bne syntax
; pas d'adresse d'ecran: AUTOBACK ON---> back--> logic/ AUTOBACK OFF---> logic
          bra.s rdc3
; une adresse d'ecran
rdc2:     movem.l d0-d4,-(sp)
          move.l d5,d3
          bsr adecran         ;va chercher l'adresse d'ecran
          move.l d3,a1
          movem.l (sp)+,d0-d4
rdc3:     exg d1,d4
          exg d2,d3
          cmp.l xmax,d1
          bcc foncall
          cmp.l ymax,d2
          bcc foncall
          cmp.l xmax,d3
          bcc foncall
          cmp.l ymax,d4
          bcc foncall
          sub d1,d3
          beq foncall
          bcs foncall
          sub d2,d4
          beq foncall
          bcs foncall
          move.l (sp)+,a0     ;d1= x1 / d2= x2 / d3= tx / d4= ty
; DEUX ADRESSES D'ECRAN
          cmp #5,d0
          bne.s rdc4
          move #38,d0
          trap #5
          rts
; UNE SEULE ADRESSE D'ECRAN: decor automatique!
rdc4:     tst autoback
          beq.s rdc5
          move d1,-(sp)
          moveq #28,d0
          trap #5             ;stop mouse
          move (sp)+,d1
          move.l adback,a1
          bra.s rdc6
rdc5:     move.l adlogic,a1
rdc6:     moveq #38,d0
          trap #5
          bra abis        ;remet les ecrans et les sprites

; ZOOM [ecran,] X1,Y1,X2,Y2 TO [ecran,] X3,Y3,X4,Y4
zoom:     bsr mentiers
          cmp #5,d0
          beq.s zm0
          cmp #4,d0
          bne syntax
; ecran d'origine par defaut: logic
          move.l adlogic,a0
          bra.s zm05
; ecran d'origine fixe
zm0:      movem.l d1-d4,-(sp)
          move.l d5,d3
          bsr adecran
          move.l d3,a0
          movem.l (sp)+,d1-d4
zm05:     move.l a0,-(sp)
          exg d1,d4
          exg d2,d3
          cmp.l xmax,d1       ;teste X1
          bcc foncall
          cmp.l ymax,d2       ;teste Y1
          bcc foncall
          cmp.l xmax,d3       ;teste X2
          bcc foncall
          cmp.l ymax,d4       ;teste Y2
          bcc foncall
          sub.l d1,d3         ;TX1
          beq foncall
          bcs foncall
          sub.l d2,d4         ;TY1
          beq foncall
          bcs foncall
          movem.l d1-d4,-(sp)
          cmp.b #$80,(a6)+    ;token de TO
          bne syntax
          bsr mentiers
          cmp #5,d0
          beq zm1
          cmp #4,d0
          bne syntax
; ecran par defaut
          bra.s zm2
; ecran choisi
zm1:      movem.l d0-d4,-(sp)
          move.l d5,d3
          bsr adecran
          move.l d3,a1
          movem.l (sp)+,d0-d4
zm2:      exg d1,d4
          exg d2,d3
          cmp.l xmax,d1       ;teste X3
          bcc foncall
          cmp.l ymax,d2       ;teste Y3
          bcc foncall
          cmp.l xmax,d3
          bcc foncall
          cmp.l ymax,d4
          bcc foncall
          sub.l d1,d3         ;TX2
          beq foncall
          bcs foncall
          sub.l d2,d4         ;TY2
          beq foncall
          bcs foncall
          move d3,a2          ;TX2-> a2
          move d4,a3          ;TY2-> a3
          move d1,d5          ;X3--> d5
          move d2,d6          ;Y3--> d6
          movem.l (sp)+,d1-d4
          move.l (sp)+,a0     ;ecran origine
          cmp d3,a2
          bcs foncall         ;TX2 > TX1
          cmp d4,a3
          bcs foncall         ;TY2 > TY1
          cmp #5,d0
          bne.s zm3
; ecran de destination CHOISI!
          moveq #42,d0        ;fonction ZOOM de la trappe
          trap #5
          rts
; ecran de destination par defaut!
zm3:      tst autoback
          beq.s zm4
          move d1,-(sp)       ;arrete la souris
          moveq #28,d0
          trap #5
          move (sp)+,d1
          move.l adback,a1              ;travaille dans BACK
          bra.s zm5
zm4:      move.l adlogic,a1
zm5:      moveq #42,d0                  ;appel de ZOOM
          trap #5
          bra abis                  ;remet les ecrans, les sprites

; APPEAR ecran[,param] ---> ecran PHYSIQUE!!!
appear:   bsr mentiers
          cmp #2,d0
          beq.s app5
          cmp #1,d0
          bne syntax
; un seul param
          move.l d1,-(sp)
app1:     moveq #71,d3        ;APPEAR ecran: tire un chiffre au hasard!
          bsr rnd1            ;0 <= chiffre <= 71
          tst.l d3
          beq.s app1
          move.l d3,d1
          move.l (sp)+,d2
; deux params
app5:     move.l d1,-(sp)
          move.l d2,d3
          bsr adecran
          move.l d3,a0
          move.l adphysic,a1
          move.l (sp)+,d1
          beq foncall
          cmp.l #80,d1
          bhi foncall
          moveq #43,d0
          trap #5
          rts

; FADE <speed> TO image# / FADE <speed>,colour1,,colour3,,,
fde:      bsr expentier
          cmp.l #1000,d3
          bcc foncall
          cmp.w #0,d3
          beq foncall
          move.w d3,-(sp)
          bsr finie
          bne.w g1
; fade to ZERO!
          move.l adlogic,a0
          lea 32000(a0),a0
          moveq #15,d0
g0:       clr.w (a0)+
          dbra d0,g0
          move.w #$ffff,d1    ;toutes les couleurs
          bra.w g5
; fade
g1:       move.b (a6)+,d0
          cmp.b #$80,d0
          beq.w g2
          cmp.b #",",d0
          bne syntax
; FADE <speed>,fkdf,dd,f,,fd,f,d
          move.l adlogic,a0
          lea 32000(a0),a0
          bsr s               ;va chercher la palette---> logique
          bra.w g5
; FADE <speed> TO image#
g2:       bsr expentier
          bsr adecran         ;adresse de l'image
          move.l d3,a0
          move.l adlogic,a1
          lea 32000(a0),a0
          lea 32000(a1),a1
          moveq #15,d0
g3:       move.w (a0)+,(a1)+  ;copie la palette---> logic
          dbra d0,g3
          move.w #$ffff,d1    ;flag---> toutes les couleurs!
; fin du FADE: envoie a la trappe!
g5:       move.l adlogic,a0
          move.l adback,a1
          lea 32000(a0),a0
          lea 32000(a1),a1
          moveq #15,d0
g6:       move.w (a0)+,(a1)+  ;copie dans le back
          dbra d0,g6
; Envoie!
          move.w d1,d2        ;FLAG
          move.w (sp)+,d1     ;vitesse
          moveq #53,d0        ;Fonction FADE
          trap #5             ;debut
          rts

; FLASH xx,a$  /  FLASH OFF
flash:    bsr onoff
          bmi.s fh1
          bne syntax
          moveq #39,d0         ;flash off
          trap #5
          rts
fh1:      bcs syntax
          bsr expentier
          move.l d3,-(sp)
          cmp.b #",",(a6)+
          bne syntax
          bsr expalpha
          bsr chverbuf
          move.l (sp)+,d1
          lea buffer,a0
          moveq #40,d0
          trap #5
          tst d0
          bne illflash
          rts

; SHIFT OFF / SHIFT nn
colshift: bsr onoff
          bmi.s cft1
          bne syntax
; SHIFT OFF
          moveq #0,d1
          moveq #46,d0
          trap #5
          rts
; SHIFT vitesse [,couleur de debut]
cft1:     bcs syntax
          bsr mentiers
          cmp #2,d0
          beq.s cft2
          cmp #1,d0
          bne syntax    
          move.l d1,d2
          moveq #1,d1
cft2:     cmp.l #$10000,d2
          bcc foncall
          move.l colmax,d0
          subq #1,d0
          cmp.l d0,d1
          bcc foncall
          exg d1,d2
          moveq #46,d0
          trap #5
          rts

; APPEL DE FONCTION VDI, AVEC GESTION DE L'AUTOBACK
avdi:     tst autoback
          beq.s atb1
          moveq #28,d0        ;arrete la souris
          trap #5
          move.l adback,$44e  ;ecran logique = decor!
atb1:     bsr vdi             ;APPEL VDI
; GESTION DE L'AUTOBACK: DEUXIEME APPEL
abis:     tst autoback
          beq.s atb2
          move.l adlogic,a1
          move.l a1,$44e      ;remet LOGIC en LOGIC
          move.l adback,a0    ;adresse du decor= origine!
          clr.l d5            ;recopie totale
          moveq #33,d0
          trap #5             ;SCREEN COPY
          moveq #29,d0
          trap #5             ;SPREAFF
atb2:     rts
; GESTION DE L'AUTO BACK PREMIER APPEL (pour les extensions...)
abck:     tst autoback
          beq.s atb2
          moveq #28,d0
          trap #5
          move.l adback,$44e
          rts

; VDI, SAUVE TOUS LES REGISTRES
vdi:      movem.l d0-d1,-(sp)
          moveq #$73,d0
          move.l #vdipb,d1
          trap #2
          movem.l (sp)+,d0-d1
          rts

; VDINT: APPEL VDI AVEC UN PARAMETRE EN INTIN(0)
vdint:    clr contrl+2
          move #1,contrl+6
          move grh,contrl+12
          bra vdi

; AUTOBACK ON/OFF
sautoback:bsr onoff
          bmi syntax
          bne.s autob3
          clr autoback        ;OFF
          moveq #33,d7
          trap #3             ;autoback off TEXTE
          rts
autob3:   move #1,autoback    ;ON
          moveq #32,d7
          trap #3             ;autoback on  TEXTE
          rts

; INK xx: change la COULEUR GRAPHIQUE
setink:   bsr expentier
          cmp.l colmax,d3
          bcc foncall
; fabrique les PLANS COULEUR de la LIGNE A
inkbis:   move.w d3,ink       ;INK pour plot 
          move.w d3,d7        ;INK pour le VDI
          lea plan0,a0
          clr.l (a0)
          clr.l 4(a0)
          clr.l d1
          move mode,d0
          subq #1,d0
          beq.s si1
          bpl.s si2
          addq #2,d1
          lea vdink2,a1                 ;lowres
          bra.s si1a
si1:      lea vdink1,a1                 ;midres
si1a:     addq #1,d1
          move d7,d0
          lsl #1,d0
          move.w 0(a1,d0.w),d7          ;INK pour le VDI: QUELLE MERDE!!!
si2:      clr d0
si2a:     btst d0,d3
          beq.s si3
          move #1,(a0)
si3:      addq.l #2,a0
          addq #1,d0
          cmp d1,d0
          bls.s si2a
          move.w d7,inkvdi
; fill color index
          move #25,contrl
          move d7,intin
          bsr vdint
; polyline color index
          move #17,contrl
          move d7,intin
          bsr vdint
; polymarker color index
          move #20,contrl
          move d7,intin
          bsr vdint
          rts

; GRWRITING xx (WRITING GRAPHIQUE)
setwrite: bsr expentier
          tst.l d3
          beq foncall
          cmp.l #4,d3
          bhi foncall
writebis: move d3,grwrite               ;entree pour MODEBIS
          sub #1,grwrite
; set writing mode
          move #32,contrl
          move d3,intin
          bsr vdint
          rts

; PLOT xx,yy [,couleur]
plot:     bsr mentiers
          cmp #2,d0
          beq.s pl1
          cmp #3,d0
          bne syntax
; couleur precisee
          cmp.l colmax,d1
          bcc foncall
          move d1,d7
          move.l d2,d1
          move.l d3,d2
          bra.s pl1a
; couleur non precisee
pl1:      move ink,d7
pl1a:     move.l laintin,a0
          move.w d7,(a0)      ;plotte la couleur         
          cmp.l xmax,d2
          bcc foncall
          cmp.l ymax,d1
          bcc foncall
          move.l laptsin,a0
          move.w d2,(a0)
          move.w d2,xgraph
          move.w d1,2(a0)
          move.w d1,ygraph
          tst autoback        ;si AUTOBACK: plotte dans le decor d'abord
          beq.s pl2
          moveq #28,d0        ;stopmouse
          trap #5
          move.l adback,$44e
          dc.w $a001          ;LIGNE A: PUT PIXEL
          move.l adlogic,$44e
pl2:      dc.w $a001          ;LIGNE A: PUT PIXEL
pl3:      tst autoback
          beq.s pl4
          moveq #29,d0        ;spreaff
          trap #5
pl4:      rts

; POINT (xx,yy): RAMENE LA COULEUR D'UN POINT
point:    cmp.b #"(",(a6)+
          bne syntax
          bsr getentier       ;va chercher les parametres
pointbis: cmp #2,d0           ;entree pour paint
          bne syntax
          cmp.l xmax,d1
          bcc foncall
          cmp.l ymax,d2
          bcc foncall
          move.l laptsin,a0
          move.w d1,(a0)      ;poke X
          move.w d1,xgraph
          move.w d2,2(a0)     ;poke Y
          move.w d2,ygraph
          tst autoback        ;si autoback: prend dans le decor
          beq.s pt1
          moveq #28,d0        ;stopmouse
          trap #5
          move.l adback,$44e
pt1:      dc.w $a002          ;LIGNE A: GET PIXEL
          move.l adlogic,$44e
          clr.l d3
          move d0,d3
          clr.b d2
          tst autoback
          beq.s pt2
          move #41,d0         ;MOUSEBETE: remet la souris
          trap #5
pt2:      rts

; DRAW: [xx,yy] TO xx,yy: TRACE UNE LIGNE PAR LA LIGNE A
draw:     cmp.b #$80,(a6)
          beq.s dw2
          bsr mentiers
          cmp #2,d0
          bne syntax
          cmp.l xmax,d2
          bcc foncall
          cmp.l ymax,d1
          bcc foncall
          move.w d2,xgraph
          move.w d1,ygraph
          cmp.b #$80,(a6)
          bne syntax
dw2:      addq.l #1,a6
          bsr mentiers
          cmp #2,d0
          bne syntax
          cmp.l xmax,d2
          bcc foncall
          cmp.l ymax,d1
          bcc foncall
          move.l laad,a0
          move.w xgraph,38(a0)          ;X1
          move.w ygraph,40(a0)          ;Y1
          move.w d2,42(a0)              ;X2
          move.w d2,xgraph
          move.w d1,44(a0)              ;Y2
          move.w d1,ygraph
          move.l plan0,24(a0)           ;plans 0-1
          move.l plan0+4,28(a0)         ;plans 2-3
          move.w grwrite,36(a0)         ;writing Ligne A
          move.w #$ffff,34(a0)          ;ligne parcourue
          move #-1,32(a0)               ;LSTLIN= -1!
          tst autoback
          beq.s dw3
          moveq #28,d0
          trap #5
          move.l adback,$44e
          dc.w $a003
          move.l adlogic,$44e
dw3:      dc.w $a003
          bra pl3                     ;remet les sprites

; CLIP off/ x1,y1 to x2,y2
clip:     bsr onoff
          bmi.s cl1
          bne syntax
clipoff:  moveq #0,d4           
          moveq #0,d3
          move.l xmax,d2
          move.l ymax,d1
          bra.s cl2
cl1:      bcs syntax
          bsr mentiers
          cmp #2,d0
          bne syntax
          cmp.l xmax,d2                 ;X
          bcc foncall
          cmp.l ymax,d1                 ;Y
          bcc foncall
          movem.w d1-d2,-(sp)
          cmp.b #$80,(a6)+              ;TO
          bne syntax
          bsr   mentiers
          cmp.w #2,d0
          bne foncall
          cmp.l xmax,d2                 ;X2         
          bcc   foncall
          cmp.l ymax,d1                 ;Y2
          bcc   foncall
          movem.w (sp)+,d3-d4
          cmp.w d1,d3
          bcc foncall
          cmp.w d2,d4
          bcc foncall

cl2:      move d4,ptsin
          move d3,ptsin+2
          move d2,ptsin+4
          move d1,ptsin+6
          move #1,intin
          move #129,contrl
          move #12,contrl+2
          move #1,contrl+6
          move grh,contrl+12
          bsr vdi
          rts

; SET LINE style(%01010001 11100011),width,begin(0-2),end(0-2)
setline:  bsr mentiers
          cmp #4,d0                     ;veut 4 parametres
          bne syntax
; set polyline line type #7
slinebis: move #15,contrl
          move #7,intin
          bsr vdint
; set user defined line style pattern
          move #113,contrl
          move.w d4,intin               ;d4: dessin de la ligne
          bsr vdint
; set polyline line width
          move #16,contrl
          move #1,contrl+2
          clr contrl+6
          move grh,contrl+12
          move d3,ptsin                 ;d3: taille de la ligne
          bsr vdi
; set polyline end style
          move #108,contrl
          clr contrl+2
          move #2,contrl+6
          move grh,contrl+12
          and #3,d2
          move d2,intin                 ;d2: debut de la ligne
          and #3,d1
          move d1,intin+2               ;d1: fin de la ligne
          bsr vdi
          rts

; POLYPARAMS: RECUPERE LES POLY PARAMETRES---> PTSIN et CONTRL(1)
polypar:  clr d7                        ;nombre de parametres
          cmp.b (a6),d6                 ;#$80 ou ;
          bne.s pa1
          move xgraph,d2
          move ygraph,d1
          bra.s pa2
pa0:      addq.l #1,a6
pa1:      movem d6-d7,-(sp)
          bsr mentiers
          movem (sp)+,d6-d7
          cmp #2,d0
          bne syntax
          cmp.l xmax,d2
          bcc foncall
          cmp.l ymax,d1
          bcc foncall
pa2:      move d7,d0
          lsl #2,d0
          lea ptsin,a0
          move.w d2,0(a0,d0.w)
          move.w d2,xgraph
          move.w d1,2(a0,d0.w)
          move.w d1,ygraph
          addq #1,d7
          move.b (a6),d0
          beq.s pa3
          cmp.b #":",d0
          beq.s pa3
          cmp.b #$9b,d0
          beq.s pa3
          cmp.b d6,d0
          beq.s pa0
          bra syntax
pa3:      cmp #1,d7
          beq syntax
          move.w d7,contrl+2
          rts

; POLYLINE x1,y1 TO x2,y2 TO x3,y3 TO .....
polyline: move #$80,d6
          bsr polypar
          move #6,contrl
          clr contrl+6
          move grh,contrl+12
          bra avdi

; SET MARK type,height
setmark:  bsr mentiers
          cmp #2,d0
          bne syntax
smarkbis: tst.l d2
          beq foncall
          cmp.l #7,d2
          bcc foncall
; set polymarker type
          move #18,contrl
          move d2,intin
          bsr vdint
; set polymarker height
          tst.l d1
          bmi foncall
          move #19,contrl
          move #1,contrl+2
          clr contrl+6
          move grh,contrl+12
          clr ptsin
          move d1,ptsin+2
          bsr vdi
          rts

; POLYMARK x1,y1;x2,y2,...
polymark: clr d7
pm1:      move d7,-(sp)
          bsr mentiers
          move (sp)+,d7
          cmp #2,d0
          bne syntax
          cmp.l xmax,d2
          bcc foncall
          cmp.l ymax,d1
          bcc foncall
          move d7,d0
          lsl #2,d0
          lea ptsin,a0
          move d2,xgraph
          move d2,0(a0,d0.w)
          move d1,ygraph
          move d1,2(a0,d0.w)
          addq #1,d7
          bsr finie
          beq.s pm2
          cmp.b #";",(a6)+
          beq.s pm1
          bne syntax
pm2:      move #7,contrl
          move d7,contrl+2
          clr contrl+6
          move grh,contrl+12
          bra avdi

; SET PAINT type,style,perimetre
setpaint: bsr mentiers
          cmp #3,d0
          bne syntax
spaintbis:cmp.l #5,d3
          bcc foncall
; set fill interior style
          move #23,contrl
          move d3,intin
          bsr vdint
; set fill style index
          tst.l d2
          beq foncall
          cmp.l #37,d2
          bcc foncall
          move #24,contrl
          move d2,intin
          bsr vdint
; set fill perimeter visibility
          cmp.l #2,d1
          bcc foncall
          move #104,contrl
          move d1,intin
          bsr vdint
          rts

; SET PATTERN xx / a$: motif utilisateur
setpatt:  bsr evalue
          moveq #1,d1
          move mode,d0
          subq #1,d0
          beq.s dp1
          bpl.s dp2
          addq #2,d1                    ;mode 0: 4 plans
dp1:      addq #1,d1                    ;mode 1: 2 plans
dp2:      move.w d1,d0
          lsl.w #4,d0
          move.w d0,contrl+6
          tst.b d2
          bmi.s dp0
          bne typemis
; Set pattern (adresse)          
          move.w d0,-(sp)
          bsr adoubank
          move.w (sp)+,d1
          move.l d3,a1
          subq #1,d1
          lea intin,a0
dp3:      move.w (a1)+,(a0)+            ;copie les plans
          dbra d1,dp3
          bra dp9
; Set pattern (CHAINE$)
dp0:      move.l d3,a1
          move.w (a1)+,d2
          cmp.w #8,d2                   ;string is not a screen bloc
          bcs st2
          cmp.l #$44553528,(a1)+
          bne st2
          cmp.w #16,(a1)+
          bne foncall
          cmp.w #16,(a1)+
          bne foncall
          move.w d1,d0
          lsl.w #1,d0
          subq #1,d1
          lea intin,a0
dp4:      moveq #15,d2
          move.l a1,a2
dp5:      move.w (a2),(a0)+
          add.w d0,a2
          dbra d2,dp5
          addq.l #2,a1
          dbra d1,dp4
; set user defined fill pattern
dp9:      move #112,contrl
          clr contrl+2
          bsr vdi
          rts

; POLYGONE x1,y1 TO x2,y2 TO ....
polygone: move #$80,d6                  ;token de TO
          bsr polypar                   ;va chercher le parametres
          move #9,contrl
          clr contrl+6
          move grh,contrl+12
          bra avdi

; PAINT xx,yy
paint:    bsr mentiers
          cmp #2,d0
          bne syntax
          cmp.l xmax,d2
          bcc foncall
          cmp.l ymax,d1
          bcc foncall
          move #-1,intin
          move d2,xgraph
          move d2,ptsin
          move d1,ygraph
          move d1,ptsin+2
          move #103,contrl
          move #1,contrl+2
          move #1,contrl+6
          move grh,contrl+12
          bra avdi

; BAR x1,y1 TO x2,y2
bar:      move #$80,d6
          bsr polypar
          move #1,contrl+10
finbar:   cmp #2,d7                     ;DEUX POINTS!
          bne syntax
          move #11,contrl
          clr contrl+6
          move grh,contrl+12
          bra avdi

; RBOX x1,y1 TO x2,y2: ROUNDED BOX
rbox:     move #$80,d6
          bsr polypar
          move #8,contrl+10
          bra finbar

; RBAR x1,y1 TO x2,y2: ROUNDED BAR
rbar:     move #$80,d6
          bsr polypar
          move #9,contrl+10             ;au PIF!!!
          bra finbar

; BOX x1,y1 TO x2,y2
box:      bsr mentiers
          cmp #2,d0
          bne syntax
          cmp.l xmax,d2
          bcc foncall
          cmp.l ymax,d1
          bcc foncall
          movem.l d1-d2,-(sp)
          cmp.b #$80,(a6)+
          bne syntax
          bsr mentiers
          cmp #2,d0
          bne syntax
          cmp.l xmax,d2
          bcc foncall
          cmp.l ymax,d1
          bcc foncall
          movem.l (sp)+,d3-d4
          move d4,ptsin       ;x1-y1
          move d3,ptsin+2
          move d2,ptsin+4     ;x2-y1
          move d3,ptsin+6
          move d2,ptsin+8     ;x2-y2
          move d1,ptsin+10
          move d4,ptsin+12    ;x1-y2
          move d1,ptsin+14
          move d4,ptsin+16    ;x1-y1
          move d3,ptsin+18
          move #6,contrl
          move #5,contrl+2
          clr contrl+6
          move grh,contrl+12
          bra avdi

; ARC xx,yy,rayon,angle1,angle2
arc:      move #2,contrl+10
          bra piebis
; PIE xx,yy,rayon,angle1,angle2
pie:      move #3,contrl+10
piebis:   bsr mentiers
          cmp #5,d0
          bne syntax
          cmp.l xmax,d5
          bcc foncall
          cmp.l ymax,d4
          bcc foncall
          move d5,xgraph
          move d5,ptsin
          move d4,ygraph
          move d4,ptsin+2
          clr.l ptsin+4
          clr.l ptsin+8
          tst.l d3
          bmi foncall
          move d3,ptsin+12
          clr ptsin+14
          cmp.l #3600,d2
          bhi foncall
          cmp.l #3600,d1
          bhi foncall
          move d2,intin
          move d1,intin+2
          move #11,contrl
          move #4,contrl+2
          move #2,contrl+6
          move grh,contrl+12
          bra avdi

; CIRCLE xx,yy,rayon
circle:   bsr mentiers
          cmp #3,d0
          bne syntax
          cmp.l xmax,d3
          bcc foncall
          cmp.l ymax,d2
          bcc foncall
          tst.l d1
          bmi foncall
          move d3,xgraph
          move d3,ptsin
          move d2,ygraph
          move d2,ptsin+2
          clr.l ptsin+4
          move d1,ptsin+8
          clr ptsin+10
          move #11,contrl
          move #3,contrl+2
          clr contrl+6
          move #4,contrl+10
          move grh,contrl+12
          bra avdi

; EARC xx,yy,rx,ry,angle1,angle2
earc:     move #6,contrl+10
          bra epiebis
; EPIE xx,yy,rx,ry,angle1,angle2
epie:     move #7,contrl+10
epiebis:  bsr mentiers
          cmp #6,d0
          bne syntax
          cmp.l xmax,d6
          bcc foncall
          cmp.l ymax,d5
          bcc foncall
          tst.l d4
          bmi foncall
          tst.l d3
          bmi foncall
          cmp.l #3600,d2
          bhi foncall
          cmp.l #3600,d1
          bhi foncall
          move d6,xgraph
          move d6,ptsin
          move d5,ygraph
          move d5,ptsin+2
          move d4,ptsin+4
;          add.l ymax,d3                 ;fixe l'axe des Y !?!?!?!?!?!?!
          move d3,ptsin+6
          move d2,intin
          move d1,intin+2
          move #11,contrl
          move #2,contrl+2
          move #2,contrl+6
          move grh,contrl+12
          bra avdi

; ELLIPSE xx,yy,rx,ry
ellipse:  bsr mentiers
          cmp #4,d0
          bne syntax
          cmp.l xmax,d4
          bcc foncall
          cmp.l ymax,d3
          bcc foncall
          tst.l d2
          bmi foncall
          tst.l d1
          bmi foncall
          move d4,xgraph
          move d4,ptsin
          move d3,ygraph
          move d3,ptsin+2
          move d2,ptsin+4
          move d1,ptsin+6
          move #11,contrl
          move #2,contrl+2
          clr contrl+6
          move #5,contrl+10
          move grh,contrl+12
          bra avdi

;-----------------------------------------    --- ----- ---   ---    -------
;   -----------------------------------      |      |  |   | |
;  |          MUSIQUE ET SONS          |      ---   |  |   |  ---
;   -----------------------------------          |  |  |   |     |
;-----------------------------------------    ---       ---   ---    -------
; MUSIC nn / MUSIC on / MUSIC off / MUSIC freeze /
music:    bsr onoff
          bmi mus2
          bne mus1
; MUSIC OFF
          moveq #0,d0
          trap #7
          bclr #1,bip                   ;remet les bruits de touche
          rts
; MUSIC ON
mus1:     moveq #5,d0
          trap #7
          bset #1,bip                   ;plus de bruits de touche
          rts
mus2:     bcc.s mus3
; MUSIC FREEZE
          moveq #4,d0
          trap #7
          rts
; MUSIC NN
mus3:     bsr expentier
          tst.l d3
          beq foncall
          cmp.l #32,d3
          bhi foncall
          move.l d3,-(sp)
          moveq #3,d3
          bsr adbank                    ;musique= banque # 3!
          beq musnotdef
          cmp.l #$13490157,(a1)         ;code "BANQUE DE MUSIQUE"
          bne musnotdef
          move.l (sp)+,d3
          lsl #2,d3                     ;ca tombe bien! sauter le code!
          move.l 0(a1,d3.w),d0
          beq.s musnotdef                 ;musique non definie
          move.l d0,a0
          add.l a1,a0                   ;adresse absolue!
          moveq #1,d0
          trap #7
          bset #1,bip                   ;plus de bruit de touches
          rts
musnotdef:moveq #75,d0
          bra erreur

; PVOICE (#voice): ramene la position de la voix (0 si la voix est arretee)
pvoice:   bsr fentier
          tst.l d3
          beq foncall
          cmp.l #3,d3
          bhi foncall
          move.l d3,d1
          moveq #10,d0
          trap #7
          move.l d0,d3
          clr.b d2
          rts


; VOICE on/off nn,time
voice:    bsr onoff
          bmi syntax
          bne vo1
; VOICE OFF[ nn ][,time]
          bsr finie
          bne.s vo0
          moveq #0,d2           ;Pas de timing
vo:       moveq #2,d0           ;Arrete toutes les voix
          moveq #1,d1
          trap #7
          moveq #2,d0
          moveq #2,d1
          trap #7
          moveq #2,d0
          moveq #3,d1
          trap #7
          rts
vo0:      bsr mentiers          ;Arrete une seule voix
          cmp.w #1,d0
          bne.s vo9
          exg d1,d2
          moveq #0,d1
          moveq #2,d0
vo9:      cmp.w #2,d0
          bne syntax
          exg d1,d2
          tst.l d1
          beq foncall
          cmp.l #4,d1
          bcc foncall
          cmp.l #256,d2
          bcc foncall
          moveq #2,d0
          trap #7
          rts
; VOICE ON [ nn ]
vo1:      bsr finie
          bne.s vo2
          moveq #3,d0         ;remet toutes les voix
          moveq #1,d1
          trap #7
          moveq #3,d0
          moveq #2,d1
          trap #7
          moveq #3,d0
          moveq #3,d1
          trap #7
          rts
vo2:      bsr expentier       ;remet une seule voix
          tst.l d3
          beq foncall
          cmp.l #4,d3
          bcc foncall
          move.l d3,d1
          moveq #3,d0
          trap #7
          rts

; TEMPO xx: change le tempo d'une musique en marche
tempo:    bsr expentier
          cmp.l #100,d3
          bhi foncall
          move d3,d1
          moveq #6,d0
          trap #7
          rts

; TRANSPOSE: change la tonalite d'une musique
transpose:bsr expentier
          cmp.l #96,d3
          bgt foncall
          cmp.l #-96,d3
          ble foncall
          move.l d3,d1
          moveq #9,d0
          trap #7
          rts

; SHOOT
shoot:    moveq #40,d2
          bsr vo
          lea tshoot,a0
          bra stmus
; EXPLODE
explode:  moveq #60,d2
          bsr vo
          lea texplode,a0
          bra stmus
; PING
ping:     moveq #50,d2
          bsr vo
          lea tping,a0
          bra stmus

; ENVEL type,speed ---> CHANGE L'ENVELOPPE
envel:    bsr mentiers
          cmp #2,d0
          bne syntax
          cmp.l #16,d2
          bcc foncall
          cmp.l #$10000,d1
          bcc foncall
          move d1,-(sp)
          move d2,d0
          moveq #13,d1
          bsr putgia
          move (sp)+,d3
          move.b d3,d0
          moveq #11,d1
          bsr putgia
          lsr #8,d3
          move.b d3,d0
          moveq #12,d1
          bsr putgia
          rts

; VOLUME xx / VOLUME nn,xx
volume:   bsr mentiers
          cmp #2,d0
          beq.s vol5
          cmp #1,d0
          bne syntax
; volume sur les trois voix
          cmp.l #17,d1
          bcc foncall
          move d1,d3
          move.b d3,volumes
          move.b d3,volumes+1
          move.b d3,volumes+2
          moveq #8,d1
          move d3,d0
          bsr putgia
          move d3,d0
          moveq #9,d1
          bsr putgia
          move d3,d0
          moveq #10,d1
          bsr putgia
          rts
; volume sur une seule voix
vol5:     cmp.l #17,d1
          bcc foncall
          tst.l d2
          beq foncall
          cmp #4,d2
          bcc foncall
          move d1,d0
          move d2,d1
          lea volumes,a0
          move.b d0,-1(a0,d1.w)
          addq #7,d1
          bsr putgia
          rts

; NOISE [voix,] freq
noise:    bsr mentiers
          cmp #2,d0
          beq.s ns5
          cmp #1,d0
          bne syntax
; noise sur les TROIS VOIX
          cmp #32,d1
          bcc foncall
          lea tn,a0
          move.b d1,1(a0)
          bsr stmus           ;fait demarrer la musique
          bra stenv           ;fait demarrer l'enveloppe
; noise sur une SEULE VOIX
ns5:      tst.l d2
          beq foncall
          cmp.l #4,d2
          beq foncall
          cmp.l #32,d1
          bcc foncall
          move d2,d7
          subq #2,d2
          beq.s ns6
          bpl.s ns7
          lea tn1,a0
          move.w #%11110110,d3
          bra.s ns8
ns6:      lea tn2,a0
          move.w #%11101101,d3
          bra.s ns8
ns7:      lea tn3,a0
          move.w #%11011011,d3
ns8:      move.b d1,1(a0)
          bsr stmus           ;va lancer la table
          moveq #7,d1
          bsr getgia
          and d3,d0
          moveq #7,d1
          bsr putgia          ;change le mixer SUR UNE SEULE VOIX
          lea volumes,a0
          cmp.b #16,-1(a0,d7.w)
          beq stenv           ;si volume=16: fait demarrer une enveloppe
          rts

; NOTE [voix,] freq,duree (50ø de seconde)
note:     bsr mentiers
          move.l d1,-(sp)
          cmp #3,d0
          beq.s nt5
          cmp #2,d0
          bne syntax
; note sur les TROIS VOIX
          cmp.l #97,d2
          bcc foncall
          lea tfreq,a0
          lsl #1,d2
          move.w 0(a0,d2.w),d0
          lea te,a0
          move.b d0,1(a0)
          move.b d0,3(a0)
          move.b d0,5(a0)
          lsr #8,d0
          move.b d0,7(a0)
          move.b d0,9(a0)
          move.b d0,11(a0)
          bsr stmus           ;fait demarrer la musique
          bsr stenv           ;fait demarrer l'enveloppe
          bra nt10
; note sur une SEULE VOIX
nt5:      tst.l d3
          beq foncall
          cmp.l #4,d3
          bcc foncall
          move d3,d7
          subq #2,d3
          beq.s nt6
          bpl.s nt7
          lea te1,a0
          move.w #%11111110,d3
          bra.s nt8
nt6:      lea te2,a0
          move.w #%11111101,d3
          bra.s nt8
nt7:      lea te3,a0
          move.w #%11111011,d3
nt8:      lea tfreq,a1
          cmp.l #97,d2
          bcc foncall
          lsl #1,d2
          move.w 0(a1,d2.w),d0
          move.b d0,1(a0)
          lsr #8,d0
          move.b d0,3(a0)
          bsr stmus           ;va lancer la note
          moveq #7,d1
          bsr getgia
          and d3,d0
          moveq #7,d1
          bsr putgia          ;change le mixer SUR UNE SEULE VOIX
          lea volumes,a0
          cmp.b #16,-1(a0,d7.w)
          bne.s nt10          ;si volume=16: fait demarrer une enveloppe
          bsr stenv
; attend la fin de la note
nt10:     move.l (sp)+,d3
          bne waitbis         ;si zero, n'attend pas !!! mais c'est GENIAL !!!
          rts

; STMUS: lis une table DO SOUND, et la fait demarrer tout de suite?!?!?!
stmus:    move.l a0,a3
stmus1:   move.b (a3)+,d1
          cmp.b #16,d1
          bcc.s stmus2
          move.b (a3)+,d0
          bsr putgia
          bra.s stmus1
stmus2:   rts

; STENV: fait demarrer un cycle d'enveloppe
stenv:    moveq #13,d1
          bsr getgia
          moveq #13,d1
          bsr putgia
          rts

; GETGIA: prend le registre D1 du circuit son
getgia:   and #$f,d1
          bclr #7,d1
          move.w d1,-(sp)
          clr.w -(sp)
          move.w #28,-(sp)
          trap #14
          addq.l #6,sp
          rts

; PUTGIA: met D0 dans le registre D1 du circuit son
putgia:   and #$f,d1
          bset #7,d1
          move.w d1,-(sp)
          move.w d0,-(sp)
          move.w #28,-(sp)
          trap #14
          addq.l #6,sp
          rts

; PSG (xx)= xx: psg en instruction
psginst:  lea bufcalc,a3
          bsr fentier
          cmp.l #14,d3
          bcc foncall
          cmp.b #$f1,(a6)+    ;veut un EGAL
          bne syntax
          move.l d3,-(sp)
          bsr expentier
          and.l #$ff,d3
          move d3,d0
          move.l (sp)+,d1
          bra putgia

; = PSG (xx): PSG en fonction
psgfonc:  bsr fentier
          cmp.l #14,d3
          bcc foncall
          move d3,d1
          bsr getgia
          clr.l d3
          clr.b d2
          move.b d0,d3
          rts

;-----------------------------------------    --- ----- ---   ---    -------
;   -----------------------------------      |      |  |   | |
;  |         FENETRES ET TEXTE         |      ---   |  |   |  ---
;   -----------------------------------          |  |  |   |     |
;-----------------------------------------    ---       ---   ---    -------
; KEY SPEED repetition,retard
keyspeed: bsr mentiers
          cmp #2,d0
          bne syntax
          cmp.l #$8000,d1
          bcs.s ksp1
          move.w #-1,d0
ksp1:     cmp.l #$8000,d2
          bcs.s ksp2
          move.w #-1,d2
ksp2:     move.w d2,-(sp)
          move.w d1,-(sp)
          move.w #35,-(sp)
          trap #14            ;appel de KBRATE
          addq.l #6,sp
          rts

; FIX le nombre de decimales
fix:      bsr expentier
          tst.l d3
          bmi.s fx2            ;fix>0 : mode normal
          clr expflg
fx0:      cmp.l #16,d3        ;fix >15: force proportionnel
          bcs.s fx1
          move #-1,d3
fx1:      move d3,fixflg
          rts
fx2:      neg.l d3
          move #1,expflg
          bra.s fx0

; CHOICE: CHOIX DANS LA BARRE DE MENU
choice:   clr.l d3
          clr.b d2
          move.w mnd+18,d3
          clr.w mnd+18
          rts

; ITEM: CHOIX DANS UN SOUS MENU
item:     clr.l d3
          clr.b d2
          move.w mnd+20,d3
          clr.w mnd+20
          rts

;-----------------------------------------    --- ----- ---   ---    -------
;    ----------------------------------      |      |  |   | |
;   |      INTERRUPTIONS EN BASIC      |      ---   |  |   |  ---
;    ----------------------------------          |  |  |   |     |
;-----------------------------------------    ---       ---   ---    -------
; ENTREE DES INTERRUPTIONS 50 HERZ
inter50:  add.l #1,timer                ;timer!
          tst.l waitcpt
          beq.s i5
          subq.l #1,waitcpt             ;compteur WAIT
; A-T-ON APPUYE SUR UNE TOUCHE?
i5:       move.l adk,a1
          move 8(a1),d1
          cmp.w ancdb8,d1
          beq fi5
; BUFFER PLEIN ???
          addq #4,d1
          cmp 6(a1),d1                  ;buffer PLEIN!
          bne.s i5e
          subq #4,d1
          move.l (a1),a0                ;prend le dernier code
          move.l 0(a0,d1.w),d0
          move.w ancdb8,d1              ;et le met a l'avant dernier
          move.w d1,8(a1)
          move.l d0,0(a0,d1.w)          ;pointe l'avant dernier
          bra.s i5f
; test du CONTRL/C, BIP DES TOUCHES
i5e:      subq #4,d1
          move d1,ancdb8
          move.l (a1),a0                ;buffer clavier
          move.w 2(a0,d1.w),d0          ;code ASCII de la derniere touche
i5f:      cmp.w #3,d0                   ;CONTRL-C (i5ab)
          bne.s i5a
          bset #7,interflg              ;provoque un test immediat
          bset #0,interflg              ;OUI: met le flag
i5a:      tst.b bip                     ;flag: bruit des touches
          bne.s fi5
          cmp #3,d0
          bne.s i5b
          lea b1,a0
          bra.s i5z
i5b:      cmp #13,d0
          bne.s i5c
          lea b2,a0
          bra.s i5z
i5c:      cmp #32,d0
          bcc.s i5d
          lea b3,a0
          bra.s i5z
i5d:      lea b4,a0
i5z:   
	sub.l	#23*2,$4a2		; Safe BIOS interrupt call
	move.l	a0,-(sp)
	move.w	#32,-(sp)
	trap 	#14
	addq.l	#6,sp
	add.l	#23*2,$4a2

; fin des interruptions: se rebranche a la routine normale
fi5:      move.l anc400,a0
          jmp (a0)

; ENTREE DES "INTERRUPTIONS" BASIC
avantint: tst.b interflg
          bmi.s entrint
          rts
entrint:  and.b #$7f,interflg
          beq.s menutest
          btst #0,interflg
          bne braik                     ;CONTROL-C
it:       tst actualise                 ;dessin des sprites automatiques?
          beq.s menutest
          movem.l d0-d1/a0,-(sp)        ;sauve juste ce qu'il faut!
          move #16,d0
          trap #5
          movem.l (sp)+,d0-d1/a0
          bclr #1,interflg
; TEST DES MENUS
menutest: tst mnd         ;menu en route?
          bne.s mt1
          rts
mt1:      bmi.s mt4           ;menu automatique ???
; manuel
          move.l a0,-(sp)
          move.l adm,a0
          btst #0,7(a0)       ;touche appuyee?
          bne.s mt2
          clr mnd+6
          move.l (sp)+,a0
          rts
mt2:      move.l (sp)+,a0
          tst mnd+6         ;pas de rebond?
          beq.s mt3
          rts
mt3:      move #1,mnd+6     ;dans la barre?
; automatique
mt4:      movem.l d0-d7/a0-a6,-(sp)
          move.l adm,a6
          move mnd+8,d0
          cmp 2(a6),d0
          bcs finmenu         ;compare en Y
mt5:      lea mnd+66,a0     ;trouve le choix en X
          move (a6),d0
          clr d1
mt6:      tst (a0)
          beq finmenu
          cmp (a0),d0
          bcs.s mt7
          addq.l #2,a0
          addq #1,d1
          cmp #10,d1
          bne.s mt6
          bra finmenu
; d1 contient le choix
mt7:      move d1,mnd+16
          bsr fz1             ;va arreter les sprites
          moveq #15,d0
          bsr qactive         ;active la fenetre des menus
          moveq #15,d3
          bsr adbank          ;adresse de la banque!
          cmp.l #$03008000,d0
          beq mt7a
          bsr qreactive       ;reactive et revient
          bra finmenu
mt7a:     move.l a1,a3        ;a3= adresse de la banque de menus
; sauve le decor!
          add.l #4220,a1      ;saute les donnees menu
          move #6999,d0       ;ne copie pas tout l'ecran!
          move.l adback,a0
mt8:      move.l (a0)+,(a1)+  ;recopie le decor dans la banque!
          dbra d0,mt8
; affiche en inverse le choix de la barre
          move mnd+16,d3    ;d3= # du choix a afficher
          moveq #1,d2         ;en mode inverse!
          bsr affchoix        ;va l'afficher!

; PREPARE LES PARAMETRES
          move mnd+16,d0
          mulu #25*16+22,d0
          add #22,d0          ;saute le titre
          add d0,a3           ;pointe l'arbre dans la banque
          move.l a3,a2
          lea defloat+4,a1    ;ou mettre l'arbre de tests!
          clr d3              ;numero du choix
          moveq #8,d6         ;taille d'un caractere en hauteur!
          cmp #2,mode
          bne mt12
          lsl #1,d6
mt12:     move d6,d7
          mulu #2,d7          ;debut de la zone graphique
          clr.w d5            ;debut de la zone texte
          clr.w d4            ;taille maxi en X
mt13:     tst.b 5(a2)
          beq mt16
; situe le souschoix en Y
          move.b d5,0(a2)     ;debut en Y
          clr d0
          move.b 1(a2),d0
          addq #1,d0          ;taille = 0 ou 1!
          add d0,d5           ;debut de la zone suivante
          cmp #16,d5          ;pas plus de 16 lignes !!!
          bhi mt16
          move d7,(a1)+       ;debut graphique en Y
          mulu d6,d0
          add d0,d7
          move d7,(a1)+       ;fin a tester pour cette zone/debut suivant
          tst.b 2(a2)
          bne mt13a
          move #800,-4(a1)    ;zone inactive!
          move #900,-2(a1)
; trouve la largeur maxi
mt13a:    move.l a2,a0
          addq.l #5,a0
          moveq #19,d0
          clr d1
mt14:     tst.b (a0)+
          beq mt14a
          addq #1,d1
          dbra d0,mt14
mt14a:    cmp d1,d4
          bcc mt15
          move d1,d4
; passe au suivant
mt15:     add #25,a2
          addq #1,d3
          cmp #16,d3
          bcs mt13
mt16:     clr.l (a1)          ;fin des tests!
          move d4,mnd+22      ;taille maxi en X
          move d3,mnd+24
          beq mt41          ;pas de rubrique !!!

; FAIT APPARAITRE LA FENETRE DE SOUS MENU
          moveq #33,d7
          trap #3             ;autoback OFF: ca va plus vite!
          addq #2,d4          ;TX
          addq #2,d5          ;TY
          clr d2
          move mnd+16,d0
          lsl #1,d0           ;dx text= 0: a gauche, on ne change rien
          beq mt21
          lea mnd+34,a0
          move.w -2(a0,d0.w),d2
          move d4,d1
          add d2,d1
          move #40,d7
          tst mode
          beq mt20
          lsl #1,d7
mt20:     cmp d7,d1           ;ca sort?
          bls mt21
          move d7,d2          ;oui: on recentre!
          sub d4,d2
mt21:     moveq #1,d3         ;DY text
          move mnd+26,d1
          swap d1
          move mode,d1
          addq #1,d1          ;jeux de caractere MODE + 1
          move mnd+28,d6
          swap d6
          move mnd+30,d6
          lea defloat,a0
          move d2,d0
          addq #1,d0           ;saute la bordure
          lsl #3,d0
          move d0,(a0)         ;DX pour la souris
          move d0,2(a0)
          move d4,d0
          subq #1,d0           ;saute aussi la bordure!
          lsl #3,d0
          add d0,2(a0)         ;FX pour la souris
          moveq #14,d0
          moveq #6,d7
          trap #3
          clr.l d7
          moveq #25,d0
          trap #3              ;scroll off!
          moveq #20,d0
          trap #3              ;arret du curseur!
; affiche le texte
          clr d2
          clr d3
mt23:     bsr affsschx
          addq #1,d3
          cmp mnd+24,d3
          bne.s mt23
          moveq #34,d7        ;remet l'ancien autoback, (reaffiche les sprites)
          trap #3

; TESTS DE LA SOURIS!!!
          clr d2              ;flag: rien d'affiche en inverse!
          move #-1,d3         ;dernier choisi!
; teste quand meme les interruptions! C'EST GENIAL!
mt30:     move.l adm,a6
          tst.b interflg
          bpl.s mt30b
          and.b #$7f,interflg
          beq.s mt30b
          bclr #0,interflg              ;CONTROL-C ?
          beq.s mt30b
          bsr effmenus
          movem.l (sp)+,d0-d7/a0-a6
          jmp braik                     ;va tout effacer et revient a BRAIK!
; tests de la souris!
mt30b:    tst mnd
          bpl.s mt30e
; AUTOMATIQUE!
          move mnd+8,d0
          cmp 2(a6),d0
          bcs.s mt30e           ;compare en Y
          lea mnd+66,a0     ;dans la barre: trouve le choix en X
          move (a6),d0
          clr d1
mt30c:    tst (a0)
          beq.s mt30e
          cmp (a0),d0
          bcs.s mt30d
          addq.l #2,a0
          addq #1,d1
          cmp #10,d1
          bne.s mt30c
          bra mt30e
mt30d:    cmp mnd+16,d1     ;change de zone?
          beq.s mt30e
          bsr effmenus
          movem.l (sp)+,d0-d7/a0-a6
          jmp menutest        ;va tout effacer et revient a MENUTEST
; MANUEL! ou automatique pour arreter les menus...
mt30e:    btst #0,7(a6)
          beq mt31
          tst mnd+6
          bne.s mt31a
          bra mt40
; affiche en inverse le sous-choix
mt31:     clr mnd+6
mt31a:    lea defloat,a0
          move (a6),d0
          cmp (a0)+,d0        ;trop a gauche
          bcs mt36
          cmp (a0)+,d0        ;trop a droite
          bhi mt36
          move 2(a6),d0
          clr d1
mt32:     tst.l (a0)          ;pas a l'interieur!
          beq mt36
          cmp (a0),d0         ;a l'interieur des limites?
          bcs.s mt33
          cmp 2(a0),d0
          bcs.s mt34
mt33:     addq.l #4,a0
          addq #1,d1
          bra.s mt32
; affiche en inverse!
mt34:     cmp d1,d3
          beq.s mt35
          tst d3              ;si pas de choix avant: rien a faire!
          bmi.s mt35
          clr d2
          bsr affsschx        ;reaffiche en NORMAL!
mt35:     tst d2              ;si deja en inverse, pas la peine!
          bne mt30
          move d1,d3
          moveq #1,d2
          bsr affsschx        ;affiche en inverse!
          bra mt30
; pas a l'interieur: efface le choix inverse!
mt36:     tst d2
          beq.s mt37
          clr d2
          bsr affsschx
mt37:     moveq #-1,d3        ;plus de choix
          bra mt30

; FIN DES MENUS OUF!
mt40:     btst #0,7(a6)       ;attend qu'on relache!
          bne.s mt40
          tst d3
          bmi mt41
          move mnd+16,d0
          addq #1,d0
          move d0,mnd+18   ;SI UN CHOIX: change les variables!!!
          addq #1,d3
          move d3,mnd+20
; teste si ON MENU GOTO
          tst runflg          ;pas en mode direct
          beq.s mt41
          tst mnd+98         ;branchemt ?
          beq.s mt41
          bmi.s mt41
          cmp.l #pile-64,sp   ;vient du CHRGET ?
          bne.s mt41
          subq #1,d0
          lsl #2,d0
          lea mnd+100,a0
          tst.l 0(a0,d0.w)
          beq.s mt41
          move.l 0(a0,d0.w),-(sp)
          bsr effmenus
          bset #7,mnd+98     ;empeche les appels en boucle
          move.l (sp)+,a5     ;pointe la nouvelle ligne
          lea 4(a5),a6
          jsr sorbcle         ;sort des boucles?
          lea pile,sp         ;RAZ de la pile, sort de ENTRINT!
          jmp lignesvt
mt41:     bsr effmenus
finmenu:  movem.l (sp)+,d0-d7/a0-a6
          rts

; EFFACE LES MENUS
effmenus: moveq #14,d0        ;effacemt rapide de la fenetre
          moveq #25,d7
          trap #3
          moveq #16,d7        ;activation rapide de la barre
          moveq #15,d0
          trap #3
          moveq #15,d3        
          bsr adbank          ;adresse de la banque
          move.l a1,a3
          clr.l d2            ;efface le nom en inverse
          move mnd+16,d3
          bsr affchoix
; recopie l'ecran!
          add.l #4220,a1
          move.l a1,a2
          move.l adback,a0
          move #6999,d0
mt43:     move.l (a1)+,(a0)+  ;recopie dans le decor
          dbra d0,mt43
          move #6999,d0
          move.l adlogic,a0
mt44:     move.l (a2)+,(a0)+  ;recopie dans l'ecran logique
          dbra d0,mt44
          bsr qreactive       ;reactive la fenetre pleine page!  
          bsr ufz1            ;remet les sprites
          clr mnd+6
          rts

; AFFCHOIX: AFFICHE UN ARTICLE DE LA BARRE DE MENU (D3)
affchoix: movem.l d0-d3/a0-a3,-(sp)
          move d3,d0
          mulu #25*16+22,d0
          add d0,a3               ;pointe le menu!
          bsr mi2                 ;met pen/paper/inverse
          clr d0
          lea mnd+34,a0
          lsl #1,d3
          beq.s ac1
          move.w -2(a0,d3.w),d0
ac1:      move.w 0(a0,d3.w),d2    ;taille de la chaine!
          sub d0,d2
          beq ac10
          move d0,-(sp)
          tst mnd+10
          beq.s ac3
; deux lignes de titre!
          moveq #1,d1
          moveq #2,d7
          trap #3             ;locate!
          move d2,d0
          subq #1,d0
          lea buffer,a0
ac2:      move.b #32,(a0)+    ;que des 32
          dbra d0,ac2
          clr.b (a0)+
          moveq #31,d0
          clr d7              ;souligne
          trap #3
          lea buffer,a0
          moveq #1,d7
          trap #3             ;affiche la ligne du bas, soulignee
          moveq #29,d0
          clr d7              ;desouligne
          trap #3
          bra ac4
; une seule ligne dans la barre
ac3:      moveq #31,d0
          clr d7              ;souligne
          trap #3
ac4:      move (sp)+,d0
          moveq #0,d1
          moveq #2,d7
          trap #3             ;locate
          lea buffer,a0
          subq #1,d2
ac5:      move.b (a3)+,(a0)+
          dbra d2,ac5
          clr.b (a0)
          lea buffer,a0
          moveq #1,d7
          trap #3
ac10:     movem.l (sp)+,d0-d3/a0-a3
          rts

; AFFSSCHX: AFFICHE UN SOUS CHOIX (D3) DANS LA FENETRE!
affsschx: movem.l d0-d3/a0-a3,-(sp)
          mulu #25,d3
          add d3,a3
          clr d1
          clr d3
          move.b (a3)+,d1     ;depart en Y
          move.b (a3)+,d3     ;taille en Y
          movem d1/d3,-(sp)
          bsr menuinv         ;met SHADE/PEN/PAPER
          lea buffer,a0
          move mnd+22,d0
          subq #1,d0
as1:      move.b #32,(a0)+    ;nettoie le buffer d'affichage
          dbra d0,as1
          clr.b (a0)
          movem (sp)+,d1-d2
          clr d0
; affiche sur plusieurs lignes
as2:      movem d0-d2,-(sp)
          add d2,d1
          moveq #2,d7         ;locate
          trap #3
          tst d2              ;derniere ligne!
          beq.s as3
          lea buffer,a0
          moveq #1,d7
          trap #3
          movem (sp)+,d0-d2
          subq #1,d2          ;remonte d'une ligne
          bra.s as2
as3:      movem (sp)+,d0-d2
          lea buffer,a0
as4:      move.b (a3)+,d1     ;poke le nom
          beq.s as5
          tst.b (a0)
          beq.s as5
          move.b d1,(a0)+
          bra.s as4
as5:      moveq #1,d7
          lea buffer,a0
          trap #3
          movem.l (sp)+,d0-d3/a0-a3
          rts

; QACTIVE: ACTIVATION RAPIDE D'UNE FENETRE
qactive:  move d0,-(sp)
          moveq #13,d7
          trap #3
          move d0,mnd+32     ;ancienne fenetre activee
          move (sp)+,d0
          moveq #16,d7
          trap #3
          rts

; REACTIVATION DE L'ANCIENNE FENETRE
qreactive:move mnd+32,d0
          moveq #16,d7
          trap #3
          rts

; SSPGM: MET SHADE/PEN/PAPER/INVERSE, retour A3 pointe la chaine!!!
menuinv:  tst.b (a3)+
          bne.s mi0
          moveq #22,d0
          bra.s mi1
mi0:      moveq #19,d0
mi1:      clr d7
          trap #3             ;SHADE ON/OFF
mi2:      clr d0
          move.b (a3)+,d0
          moveq #3,d7         ;SET PAPER
          trap #3
          clr d0
          move.b (a3)+,d0
          moveq #4,d7         ;SET PEN
          trap #3
          tst d2
          beq.s mi3
          moveq #21,d0        ;inverse on
          bra.s mi4
mi3:      moveq #18,d0        ;inverse off
mi4:      clr d7
          trap #3
          rts

; MENU$ (XX[,YY]) = A$: ACQUISITION DU MENU
menu:     tst mnd+14                  ;place deja reservee?
          bne.s mn1
; reserve la banque 15 pour les menus
          moveq #15,d3
          bsr adbank                    ;deja reservee???
          bne menures
          move.l #$8000,d3              ;prend 32000 octets
          bsr demande
          move.l #$8000,d3              ;longueur a reservee
          moveq #$3,d1                  ;flag MENUS
          moveq #15,d2                  ;numero de la banque
          bsr res6                      ;va reserver la memoire
          moveq #15,d3
          bsr adbank
          move.l a1,a0                  ;nettoie la banque!
          move.l a0,d2
          add.l #8000,d2
          clr.l d3
          bsr fillbis
          move #1,mnd+14              ;met le flag a un!

mn1:      moveq #15,d3
          bsr adbank
          cmp.l #$03008000,d0
          bne menunotd                  ;on a chage la banque #15 !!!!
          move.l a1,-(sp)
          cmp.b #"(",(a6)+
          bne syntax
          lea bufcalc,a3                ;OUF!
          bsr getentier
          cmp #2,d0
          beq mn10
          cmp #1,d0
          bne syntax
; prend un article de la BARRE DE MENU
          clr mnd
          move #1,mnd+4               ;on a change la barre de menu!
          subq.l #1,d1
          bcs foncall
          cmp.l #10,d1                  ;pas plus de DIX!
          bcc foncall
          move.l (sp)+,a1
          mulu #422,d1
          add d1,a1                     ;pointe la chaine
          move.l a1,-(sp)
          bsr papen
          move.b d0,(a1)+               ;paper et pen par defaut!
          move.b d1,(a1)+
          moveq #19,d0
mn2:      clr.b (a1)+                   ;RAZ de la chaine
          dbra d0,mn2
          cmp.b #$f1,(a6)+
          bne syntax
          bsr expalpha                  ;va chercher la chaine
          move.l (sp),a1
          addq.l #2,a1
          tst d2
          beq.s mn4
          moveq #19,d0
mn3:      move.b (a2)+,(a1)+            ;copie la chaine, 20 car max!
          subq #1,d2
          beq.s mn4
          dbra d0,mn3
mn4:      move.l (sp)+,a1
          bsr finie
          beq.s mn5
          move.l a1,-(sp)
          cmp.b #",",(a6)+
          bne syntax
          bsr mentiers
          move.l (sp)+,a1
          cmp #2,d0
          bne syntax
          cmp.l colmax,d1
          bcc foncall
          cmp.l colmax,d2
          bcc foncall
          move.b d2,(a1)+               ;paper
          move.b d1,(a1)+               ;et pen!
mn5:      rts
; prend un article dans un SOUS MENU
mn10:     subq.l #1,d1
          bcs foncall
          cmp.l #10,d1                  ;pas plus de 10!
          bcc foncall
          move.l (sp)+,a1
          mulu #422,d1
          add #22,d1
          add d1,a1                     ;pointe le groupe de menu
          subq.l #1,d2
          bcs foncall
          cmp.l #16,d2                  ;pas plus de 16 choix!
          bcc foncall
          mulu #25,d2
          add d2,a1                     ;pointe le bon endroit!
          bsr onoff
          bpl mn20
; menu$(xx,yy) = "ioaozioai"[,paper,pen]
          move.l a1,-(sp)
          clr.b (a1)+         ;position enY
          clr.b (a1)+         ;taille en Y par defaut: UN
          move.b #1,(a1)+     ;active par defaut
          bsr papen
          move.b d0,(a1)+     ;paper
          move.b d1,(a1)+     ;pen
          moveq #19,d0
mn11:     clr.b (a1)+                   ;nettoie la chaine
          dbra d0,mn11
          cmp.b #$f1,(a6)+
          bne syntax
          bsr expalpha                  ;va chercher la chaine
          move.l (sp),a1
          lea 1(a1),a0                  ;pointe la taille ligne!
          addq.l #5,a1
          tst d2
          beq.s mn14
          moveq #19,d0
mn12:     move.b (a2)+,d1
          move.b d1,(a1)+
          cmp.b #27,d1                  ;si icones: taille ligne = 2!
          bne.s mn13
          cmp #2,mode                   ;et si mode <> 2!
          beq.s mn13
          move.b #1,(a0)
mn13:     subq #1,d2
          beq.s mn14
          dbra d0,mn12
mn14:     add.l #3,(sp)                 ;va terminer: paper et pen!
          bra mn4
; menu$(xx,yy) ON/OFF
mn20:     bne.s mn21
          clr.b 2(a1)                   ;arrete!
          rts
mn21:     move.b #1,2(a1)               ;met en route!
          rts

; PAPEN: RAMENE PAPER(D0) ET PEN(D1) ACTUELS
papen:    move valpaper,d0
          move valpen,d1    
          rts

; MENU ON [tour,auto] / MENU OFF / MENU FREEZE
menuonof: bsr onoff
          bcs mfreeze
          bmi syntax
          bne menuon
; arret du menu!
menuoff:  clr mnd
          clr mnd+2
          clr mnd+18
          clr mnd+20
          tst mnd+14
          beq.s mf1
          clr mnd+14
          moveq #15,d3
          bsr erasbis         ;va effacer, bouge toutes le variables
mf1:      tst mnd+12
          beq.s mf2
          clr mnd+12
          jsr modebis         ;reaffiche tout l'ecran!
mf2:      rts                 ;c'est fini!
; mise en route du menu!
menuon:   tst mnd+12         ;barre en route?
          beq.s mo0
          tst mnd         ;menus en marche  
          bne.s mo0
          tst mnd+4
          bne.s mo0
          bsr finie           ;MENU ON tour,auto
          bne.s mo0
          move mnd+2,d0
          beq.s mo0
          move d0,mnd
          rts
mo0:      tst mnd+14
          beq menunotd        ;menu not defined
          moveq #15,d3
          bsr adbank
          cmp.l #$03008000,d0
          bne menunotd
          move #2,mnd+26    ;tour par defaut
          bsr papen
          move d0,mnd+30
          move d1,mnd+28
          move #-1,-(sp)      ;par defaut: automatique!
; MENU ON TOUR,AUTO (-1 laisse les memes)
          bsr finie           ;tour
          beq.s mo2
          bsr expentier
          tst.l d3
          bmi.s mo1c
          beq foncall
          cmp.l #16,d3
          bhi foncall
          move.w d3,mnd+26
mo1c:     bsr finie           ;automatique?
          beq.s mo2
          cmp.b #",",(a6)+
          bne syntax
          bsr expentier
          tst.l d3
          bmi.s mo2
          beq foncall
          cmp.l #2,d3
          bhi foncall
          bne.s mo2
          move.w #1,(sp)
; calcul de la barre de menu, et des coordonnees
mo2:      bsr affbarre        ;va afficher la barre de menu!
          move (sp)+,mnd  ;menus actives!
          rts
; GEL des menus
mfreeze:  tst mnd+14
          beq menunotd
          move mnd,mnd+2
          clr mnd
          rts

; SSPRG: AFFICHE LA BARRE DE MENU --- que c'est chiant ---
affbarre: tst mnd+14
          beq ab13
          moveq #15,d3
          bsr adbank
          cmp.l #$03008000,d0
          bne ab13
          move.l a1,-(sp)
          clr mnd+4
          moveq #9,d0
          moveq #40,d1
          move #8,mnd+8    ;hauteur des tests de la souris
          move mode,d7
          cmp #2,d7
          bne.s ab0
          move #16,mnd+8
ab0:      tst d7
          beq.s ab1
          lsl #1,d1           ;d1= nombre de lettres en largeur
ab1:      lea mnd+66,a2     ;coordonnees reelle/souris
          lea mnd+34,a3     ;coordonnees texte dans la barre
          moveq #9,d0
ab2:      clr.w (a2)+         ;nettoie les tables
          clr.w (a3)+
          dbra d0,ab2
          lea mnd+66,a3
          lea mnd+34,a2
          clr d2
          clr d3
          clr d5              ;mnd+10 recherche!
          moveq #9,d0
ab3:      tst.b 2(a1)         ;fini!
          beq ab6a
          clr d4
ab4:      cmp.b #27,2(a1,d4.w)
          bne.s ab4a
          moveq #1,d5
ab4a:     addq #1,d2
          addq #8,d3
          cmp d1,d2           ;trop loin a droite?
          bcc.s ab6
          addq #1,d4
          cmp #20,d4          ;fin de la chaine?
          beq.s ab5
          tst.b 2(a1,d4.w)
          bne.s ab4
ab5:      move.w d2,(a2)+     ;poke les coordonnees
          move.w d3,(a3)+
          add #422,a1
          dbra d0,ab3
          bra.s ab6a
ab6:      move.w d2,(a2)+
          move.w d3,(a3)+
; mode 2
ab6a:     cmp #2,mode
          bne ab7             ;en mode 2: toujours UNE SEULE LIGNE!
          moveq #0,d5
          move #16,mnd+8
          tst mnd+12
          beq.s ab8
          bne.s ab9
; mode 0/1
ab7:      move #8,d0
          move d0,mnd+8
          mulu d5,d0
          add d0,mnd+8
          tst mnd+12
          beq.s ab8
          cmp mnd+10,d5
          beq.s ab9
; change l'ecran
ab8:      move #1,mnd+12     ;va effacer l'ecran, revient ici
          move d5,mnd+10    ;affiche le menu, et fini mode!
          addq.l #4,sp        ;raz pile
          jmp modebis         ;OUCH!
; ne change pas l'ecran
ab9:      moveq #15,d0
          bsr qactive         ;active la fenetre de menus
; prepare la fenetre
          move mnd+30,d0   ;set paper
          moveq #3,d7
          trap #3
          move mnd+28,d0     ;set pen
          moveq #4,d7
          trap #3
          moveq #18,d0
          clr.l d7            ;pas en inverse!
          trap #3
          moveq #12,d0        ;cls
          clr.l d7
          trap #3
; souligne la ligne du menu, sur toute la largeur
          lea buffer,a0
          moveq #39,d0
          tst mode
          beq.s ab9a
          lsl #1,d0
          addq #1,d0
ab9a:     move.b #32,(a0)+
          dbra d0,ab9a
          clr.b (a0)
          moveq #31,d0        ;SOULIGNE
          clr d7
          trap #3
          tst mnd+10
          beq.s ab9b
          moveq #0,d0
          moveq #1,d1
          moveq #2,d7
          trap #3             ;si DEUX LIGNES: souligne la ligne du bas!
ab9b:     lea buffer,a0
          moveq #1,d7
          trap #3
          moveq #29,d0        ;DESOULIGNE
          clr d7
          trap #3
; affiche tous les choix
          move.l (sp)+,a3     ;adresse de la banque
          clr d3
          lea mnd+34,a0
ab10:     tst.w (a0)+
          beq.s ab12
          clr d2              ;pas en inverse!
          bsr affchoix
ab11:     addq #1,d3
          cmp #10,d3
          bcs.s ab10
; reactive l'ancienne fenetre
ab12:     bsr qreactive
ab13:     rts

; ICON$ (xx): CHR$(27)+CHR$(XX)
icon:     bsr fentier
          tst.l d3
          beq foncall
          cmp.l #256,d3
          bcc foncall
          move d3,-(sp)
          moveq #3,d3
          bsr demande
          move (sp)+,d3
          move.w #2,(a0)+
          move.b #27,(a0)+
          move.b d3,(a0)+
          bra mid7a

; TAB (xx): FONCTION !!!
tab:      bsr fentier
          tst.l d3         ;tab (0)----> chaine vide
          beq mid9
          cmp.l #65500,d3
          bcc foncall
          bsr demande
          move.w d3,(a0)+
          subq #1,d3
tab1:     move.b #9,(a0)+
          dbra d3,tab1
          bra mid7a

; = CHARLEN(xx): RAMENE LA LONGUEUR D'UN JEU DE CARACTERES
charlen:  bsr fentier
charlbis: subq #1,d3
          bcs foncall
          cmp.l #16,d3
          bcc foncall
          move.l d3,d0
          moveq #28,d7        ;ramene l'adresse du jeu de caracteres
          trap #3
          move.l d0,d3
          tst.l d3
          beq.s charl1
          move.l d3,a1
          clr.l d3
          move 4(a1),d3       ;TX
          mulu 6(a1),d3       ;fois TY
          mulu #224,d3        ;fois 224 caracteres
          add #264,d3         ;plus 264
charl1:   clr.b d2
          rts

; CHAR COPY xx TO # de banque
charcopy: bsr expentier
          bsr charlbis        ;va chercher l'adresse des caracateres
          tst.l d3
          beq charnotf        ;character set not found!
          move.l a1,-(sp)
          move.l d3,-(sp)
          cmp.b #$80,(a6)+
          bne syntax
          bsr expentier
; efface la banque en question
          cmp.l #15,d3        ;si banque 15
          bne.s cp1
          tst mnd+14        ;et menus en route!!! ALLONS!!!
          bne menuill
cp1:      move.l d3,-(sp)
          bsr adbank
          beq.s cp2
          bsr effbank         ;va effacer!
          bsr resbis
cp2:      move.l 4(sp),d3     ;longueur
          bsr demande
          move #$84,d1        ;flag CARACTERE
          move.l (sp),d2      ;numero de la banque demandee
          bsr reservin        ;va reserver!
          move.l (sp)+,d3
          bsr adbank          ;va chercher l'adresse de la banque
          move.l a1,a3        ;destination
          move.l (sp)+,d3     ;longueur
          move.l (sp)+,a2     ;adresse du jeu a copier
          bsr transmem        ;recopie!
          bsr resbis          ;remet tout normalement!!!
          rts

; WINDOPEN N,X1,Y1,TX,TY [,bordure] [,jeux de car]
windopen: bsr mentiers
          cmp.w #7,d0
          beq.s wp5
          cmp.w #5,d0
          beq.s wp1
; windopen n,x1,y1,tx,ty,bordure
          movem.l d1-d6,-(sp)
          movem.l (sp)+,d2-d7
          bra.s wp2
; windopen x1,y1,tx,ty
wp1:      movem.l d1-d5,-(sp)
          movem.l (sp)+,d3-d7
          moveq #1,d2         ;bordure par defaut
wp2:      move mode,d1
          addq #1,d1          ;caractere par defaut: MODE+1!
; tous les parametres
wp5:      move.l d7,d0        ;D0.L numero de la fenetre
          beq syswind         ;pas la fenetre zero!!!
          cmp.l #16,d0
          bcc foncall
          cmp.l #14,d0
          bcc syswind
          swap d1
          cmp.l #16,d2        ;seize bordures differentes
          bhi foncall
          move.w d2,d1
          swap d1             ;D1.L bord/jeux de car
          exg d3,d6
          exg d4,d5
          movem.l d3-d6,-(sp)
          movem.l (sp)+,d2-d5
          move valpen,d6      ;pen actuel
          swap d6
          move valpaper,d6    ;paper actuel
	cmp.l #$10000,d4
	bhi foncall
	cmp.l #$10000,d5
	bhi foncall
wp7:      moveq #6,d7
          trap #3             ;init window
; erreurs fenetres
winderr:  tst d0
          beq.s fwinder
          cmp #7,d0
          bhi foncall
          add #67,d0
          bra erreur
fwinder:  rts

; WINDOW xx[,yy,zz...]: active des fenetres
window:   bsr mentiers
          lea buffer,a0
          subq #1,d0
          bra.s ww1
ww0:      movem.l d2-d7,-(sp)
          movem.l (sp)+,d1-d6
ww1:      cmp.l #16,d1
          bcc foncall
          cmp.l #14,d1
          bcc syswind
          move.w d1,(a0)+
          dbra d0,ww0
          move.w #-1,(a0)
          lea buffer,a0
          moveq #27,d7
          trap #3
          bra winderr

;QWINDOW: activation rapide de fenetres
qwindow:  bsr expentier
          cmp.l #16,d3
          bcc foncall
          cmp.l #14,d3
          bcc syswind
          move.l d3,d0
          moveq #16,d7
          trap #3
          bra winderr

; WINDON: RAMENE LA FENETRE ACTIVEE
fwindon:  moveq #13,d7
          trap #3
          clr.l d3
          move d0,d3
          clr.b d2
          rts

; WINDMOVE XX,YY: BOUGE LA FENETRE COURANTE
windmov:  bsr mentiers
          cmp #2,d0
          bne syntax
          tst.l d1
          bmi foncall
          tst.l d2
          bmi foncall
          move d2,d0
          moveq #24,d7        ;fonction #24: move window
          trap #3
          bra winderr

; WINDEL xx: detruit une fenetre
windel:   bsr expentier
          tst.l d3
          beq syswind
          cmp.l #16,d3
          bcc foncall
          cmp.l #14,d3
          bcc syswind
          moveq #9,d7
          move.l d3,d0
          trap #3
          bra winderr

; LOCATE x,y
locate:   bsr mentiers
          cmp #2,d0
          bne syntax
          moveq #2,d7
          move.l d2,d0
          bmi foncall
          tst.l d1
          bmi foncall
          trap #3
          tst d0
          bne foncall
          rts

; CURS X
cursx:    moveq #17,d7
          trap #3
          swap d0
          clr.l d3
          move.w d0,d3
          clr.b d2
          rts

; CURS Y
cursy:    moveq #17,d7
          trap #3
          clr.l d3
          move d0,d3
          clr.b d2
          rts

; XTEXT (xx): CONVERTION GRAPHIQUE ---> TEXTE X
xtext:    bsr fentier
          moveq #37,d7
xtext1:   move.l d3,d0
          trap #3
          move.l d0,d3
          clr.b d2
          rts

; YTEXT (yy): CONVERTION GRAPHIQUE ---> TEXTE Y
ytext:    bsr fentier
          moveq #38,d7
          bra xtext1

; XGRAPHIC (xx): CONVERTION TEXTE X ---> GRAPHIQUE
xgraphic: bsr fentier
          moveq #35,d7
          bra xtext1

; YGRAPHIC (yy): CONVERSION TEXTE Y ---> GRAPHIQUE
ygraphic: bsr fentier
          moveq #36,d7
          bra xtext1

; DIVX: diviseur en X selon le mode
divx:     clr.b d2
          tst mode
          beq.s divx1
          moveq #1,d3
          rts
divx1:    moveq #2,d3
          rts

; DIVY: diviseur en Y selon le mode
divy:     clr.b d2
          cmp #2,mode
          bne.s divy1
          moveq #1,d3
          rts
divy1:    moveq #2,d3
          rts

; SCREEN (xx,yy)
screen:   cmp.b #"(",(a6)+
          bne syntax
          bsr getentier
          cmp #2,d0
          bne syntax
          move.l d1,d0
          bmi foncall
          move.l d2,d1
          bmi foncall
          moveq #5,d7
          trap #3
          tst d0
          bmi foncall
          and #$ff,d0
          clr.l d3
          move.b d0,d3
          clr.b d2
          rts

; PAPER xx
paper:    bsr expentier
          cmp.l colmax,d3
          bcc foncall
          move d3,valpaper
          move.l d3,d0
          moveq #3,d7
          trap #3
          rts

; PEN xx
pen:      bsr expentier
          cmp.l colmax,d3
          bcc foncall
          move d3,valpen
          move.l d3,d0
          moveq #4,d7
          trap #3
          rts

; MET OU NON LE CURSEUR
curseur:  tst cursflg
          beq.s cursoff
          bne.s curson
; CURS ON/OFF
curs:     bsr onoff
          bmi syntax
          bne.s curson
; arret du curseur
cursoff:  clr cursflg
          cmp #2,mode
          beq curs0
          moveq #39,d0        ;arrete les flash
          trap #5
          bsr setpalet        ;remet les couleurs
curs0:    moveq #20,d0        ;code arret cur
          bra.s curs1
; marche du curseur
curson:   move #1,cursflg
          cmp #2,mode
          beq.s curs2
          lea fd,a0     ;fait flasher la couleur #2
          moveq #2,d1
          moveq #40,d0
          trap #5
curs2:    moveq #17,d0
curs1:    clr.l d7
          trap #3
          rts

; SET CURS dy,fy[,vitesse]
setcurs:  bsr mentiers
          cmp #3,d0
          beq pasimp
          cmp #2,d0
          bne syntax
          move.l d2,d0
          bmi foncall
          tst.l d1
          bmi foncall
          moveq #14,d7
          trap #3
          rts                 ;pasimp!!! tester les erreurs

; UP
curup:    moveq #11,d0
          bra curs1
; DOWN
curdown:  moveq #10,d0
          bra curs1
; LEFT
curleft:  moveq #3,d0
          bra curs1
; RIGHT
curight:  moveq #9,d0
          bra curs1

; SCROLL ON/OFF
scroll:   bsr onoff
          bmi scr               ;Branche a SCROLL N
          bne scrolon
; scroll OFF
          moveq #25,d0
          bra curs1
; scroll ON
scrolon:  moveq #23,d0
          bra curs1

; SCROLL DOWN
scrolldn: moveq #5,d0
          bra curs1

; SCROLL UP
scrollup: moveq #4,d0
          bra curs1

; HOME
home:     moveq #30,d0
          bra curs1

; CLW
clw:      moveq #12,d0
          bra curs1

; SQUARE tx,ty,border
textbox:  bsr mentiers
          cmp #3,d0
          bne syntax
          move.l d1,d0
          beq foncall
          cmp.l #16,d0
          bcc foncall
          move.l d3,d1
          cmp.l #3,d1
          bcs foncall
          cmp.l #80,d1
          bcc foncall
          cmp.l #3,d2
          bcs foncall
          cmp.l #80,d2
          bcc foncall
          moveq #39,d7
          trap #3
          rts

; CLS / CLS ecran / CLS ecran,couleur / CLS ecran,couleur,X1,Y1 TO X2,Y2
cls:      bsr finie           ;pas de parametre: MODEBIS!
          bne.s cls0
          tst runflg
          bne modebis         ;mode programme: efface juste!
          jmp Red             ;mode direct: redessin sans changer MODE!
; cls complexe!
cls0:     bsr expentier       ;Premier param ---> ECRAN
          bsr adecran
          move.l d3,-(sp)
          clr.l -(sp)         ;Couleur par defaut: 0
          moveq #0,d3         ;Par defaut, tout l'ecran
          cmp.b #",",(a6)
          bne cls1            ;Un seul parametre
          addq.l #1,a6
          bsr expentier
          cmp.l colmax,d3     ;Couleur de CLS
          bcc foncall
          move.l d3,(sp)
          moveq #0,d3         ;Tout l'ecran
          cmp.b #",",(a6)
          bne.s cls1
          addq.l #1,a6        ;CLS fenetre
          bsr mentiers
          cmp.w #2,d0
          bne syntax
          movem.l d1-d2,-(sp)
          cmp.b #$80,(a6)+
          bne syntax
          bsr mentiers
          cmp.w #2,d0
          bne syntax
          move.l d1,d4
          move.l d2,d3
          movem.l (sp)+,d1-d2
          exg d1,d2
          and.w #$fff0,d1     ;Masque les coordonnees en X
          and.w #$fff0,d3
          cmp.l xmax,d1       ;Teste les limites
          bcc foncall
          cmp.l ymax,d2
          bcc foncall
          cmp.l xmax,d3
          bhi foncall
          cmp.l ymax,d4
          bhi foncall
          sub.l d1,d3
          bcs foncall
          beq foncall
          sub.l d2,d4
          bcs foncall
          beq foncall
; Appel de la trappe
cls1:     move.l (sp)+,d5
          move.l (sp)+,a0
          moveq #50,d0
          trap #5
          rts

; INVERSE ON/OFF
inverse:  bsr onoff
          bmi syntax
          bne.s inveron
; inverse off
          moveq #18,d0
          bra curs1
; inverse on
inveron:  moveq #21,d0
          bra curs1

; SHADE ON/OFF
shade:    bsr onoff
          bmi syntax
          bne.s shadon
; shade off
          moveq #19,d0
          bra curs1
; shade on
shadon:   moveq #22,d0
          bra curs1

; UNDERLINE ON/OFF
underline:bsr onoff
          bmi syntax
          bne.s underon
; underline off
          moveq #29,d0
          bra curs1
; underline on
underon:  moveq #31,d0
          bra curs1

; WRITING 1-3
writing:  bsr expentier
          tst.l d3
          beq foncall
          cmp.l #4,d3
          bcc foncall
          add #13,d3
          move d3,d0
          clr.l d7
          trap #3
          rts

; CENTER a$: affiche une chaine CENTREE dans la fenetre courante
center:   bsr expalpha
          tst.l d2
          beq foncall
          cmp.l #80,d2
          bcc foncall
          bsr chverbuf
          moveq #18,d7
          lea buffer,a0
          trap #3
          rts

; TITLE a$: affiche une chaine CENTREE dans le HAUT DE LA FENETRE
title:    bsr expalpha
          tst.l d2
          beq foncall
          cmp.l #80,d2
          bcc foncall
          bsr chverbuf
          moveq #31,d7
          lea buffer,a0
          trap #3
          tst d0
          bne foncall
          rts

; BORDER xx: REDESSINE LE TOUR D'UNE FENETRE ENCADREE! GENIAL!!!
border:   bsr finie
          bne.s bd1
          clr.l d3
          bra.s bd2
bd1:      bsr expentier
          cmp.l #17,d3
          bcc foncall
bd2:      move.l d3,d0
          moveq #30,d7
          trap #3
          tst d0
          bne foncall
          rts

jfiltmis: jmp filtmis
jfilnotop:jmp filnotop

; LPRINT
lprint:   move #1,impflg
          bra.s lprint1
; PRINT
print:    clr impflg
lprint1:  tst.l printpos      ;position du CHRGET du print
          beq.s print0          ;si 0: OK, on est sorti NORMALEMENT du print!
          bclr #7,printflg    ;reprend AU DEBUT des chaines
          move.l printpos,a6
          move.l printfile,a2
          move.w printype,d0
          beq.s print1
          bne reprint
; entree normale dans un print
print0:   clr printflg
          cmp.b #"#",(a6)
          beq.s print2
; impression a l'ecran
          clr printype        ;impression normale
print1:   bsr ssprint
          beq finprint
          tst d7
          beq.s print1
          lea buffer,a0
          jsr impchaine       ;imprime--> ecran ou imprimante
          bra.s print1
; impression dans un fichier
print2:   tst impflg          ;pas LPRINT #xx!!!
          bne syntax
          jsr getfile
          beq jfilnotop
          bmi jfiltmis
lprint3:  move.w d0,printype
          move.l a2,printfile
          cmp #5,d0
          beq jfiltmis
reprint:  cmp #6,d0
          beq print5
; port imprimante/midi/rs-232: imprime TOUT, meme les zero!
print3:   bsr ssprint
          beq finprint
          subq #1,d7          ;compteur du nombre de caracteres
          bmi.s print3
          move.w printype,d6
          subq #1,d6
          pea buffer
print4:   move.w d6,-(sp)     ;bcostat
          move.w #8,-(sp)
          trap #13
          addq.l #4,sp
          bsr entrint         ;attend que le perif soit pres,
          tst d0              ;en gerant quand meme les interruptions! SUPER!
          beq.s print4
	move.l (sp),a2
	moveq #0,d0
          move.b (a2)+,d0     ;c'est pret! envoyez c'est pes‚!
	move.l a2,(sp)
          move.w d0,-(sp)
          move.w d6,-(sp)
          move.w #3,-(sp)
          trap #13
          addq.l #6,sp
          dbra d7,print4
	addq.l #4,sp
          bra.s print3
; dans un fichier sequentiel: imprime aussi tout!
print5:   bsr ssprint
          beq finprint
          tst d7              ;chaine vide!
          beq.s print5
          move.l printfile,a2 ;recupere l'adresse du fichier
          pea buffer
          and.l #$ffff,d7
          move.l d7,-(sp)
          move.w fha(a2),-(sp)
          move.w #$40,-(sp)
          trap #1             ;Write
          add.l #12,sp
          tst.l d0
          bmi disquerr
          add.l d7,fhl(a2) ;augmente la taille du fichier
          bra print5
disquerr: jmp diskerr
; Fin du print
finprint: clr.l printpos      ;On est sorti NORMALEMENT du print!
          clr.l printfile
          clr.w printype
          rts

; ROUTINE DE PRINT: REMPLI LE BUFFER, REVIENT D7=LONGUEUR A IMPRIMER!
ssprint:  btst #7,printflg    ;impression de chaine en route!
          bne sp2a
          btst #6,printflg    ;fini?
          bne sp17
          lea buffer,a0
          move.b (a6),d0
          beq sp11
          cmp.b #":",d0
          beq sp11
          cmp.b #$9b,d0
          beq sp11
          cmp.b #$a0,d0       ;code etendu de USING?
          bne.s spa
          cmp.b #$df,1(a6)
          bne.s spa
; USING "+ - #### . ^^^^ ~~~~": debut, STOCKE LA CHAINE
sp20:     addq.l #2,a6
          bsr expalpha
          cmp #120,d2         ;pas plus de 120 caracteres
          bcc foncall
          clr searchd
          clr searchf
          lea buffer+256,a0
          bsr chverbuf2       ;copie la chaine dans le buffer
          move #1,usingflg
          cmp.b #";",(a6)+    ;veut absolument un ; apres using!!!!
          beq.s spb             ;sinon: pas de print using NA!
spa:      clr usingflg
spb:      bsr evalue
          tst parenth
          bne syntax
          move.l a5,-(sp)
          lea buffer,a5
          tst.b d2
          beq.s sp1
          bmi.s sp2
; IMPRESSION D'UN CHIFFRE FLOAT
          move fixflg,d0
          jsr strflasc        ;va ecrire dans le buffer
          bra using1
; IMPRESSION D'UN CHIFFRE ENTIER
sp1:      move.l d3,d0
          move.l a4,-(sp)
          jsr longdec1
          move.l (sp)+,a4
          bra using1
; IMPRESSION D'UNE CHAINE -debut-
sp2:      move.l d3,a3
          move.w (a3)+,d3
          bne.s sp3
          bra using50 
; IMPRESSION D'UNE CHAINE -milieu-
sp2a:     move.l a5,-(sp)
          lea buffer,a5
sp3:      move #120,d0
sp4:      move.b (a3)+,(a5)+  ;imprime par salves de 120 caracteres,
          subq #1,d3
          beq.s sp5
          dbra d0,sp4
          bset #7,printflg    ;on a pas fini d'imprimer la chaine!
          move.l a5,a0
          move.l (sp)+,a5     ;depile, arrete le print using!!!
          bra.s sp11
sp5:      bclr #7,printflg    ;on a fini!
          bra using50
; fin du sspgm/retour du USING
sp11:     clr usingflg        ;une seule expression par USING
          btst #7,printflg    ;pas fini: ne fait rien!
          bne.s sp15
          move.b (a6),d0
          beq.s sp14
          cmp.b #":",d0
          beq.s sp14
          cmp.b #$9b,d0
          beq.s sp14
          cmp.b #",",d0
          beq.s sp12
          cmp.b #";",d0       ;point virgule: ne fait rien!
          beq.s sp13
          bne syntax
sp12:     move.b #32,(a0)+    ;virgule: met trois espaces! RIDICULE!
          move.b #32,(a0)+
          move.b #32,(a0)+
sp13:     addq.l #1,a6
          bsr finie
          beq.s sp14a
          bra.s sp15
sp14:     move.b #13,(a0)+    ;met le RETURN
          move.b #10,(a0)+
sp14a:    bset #6,printflg    ;flag: c'est fini apres!
sp15:     clr.b (a0)
          sub.l #buffer,a0
          move.l a0,d7        ;taille du buffer
          btst #7,printflg
          bne.s sp16
          move.l a6,printpos  ;position du CHRGET PRINT
sp16:     move #1,d0          ;retour: quelque chose a imprimer!
          rts
sp17:     clr d0
          rts

; USING pour les CHIFFRES
using1:   move.l a5,a0        ;depile
          move.l (sp)+,a5
          tst usingflg        ;si pas using: revient imprimer
          beq sp11
          clr.b (a0)          ;stoppe la chaine
          lea buffer,a1
          lea 128(a1),a2
          moveq #127,d0
us2:      move.b (a1),(a2)+   ;recopie la chaine, et fait le menage!!!
          move.b #32,(a1)+
          dbra d0,us2
          lea buffer,a0
          lea 128(a0),a1      ;a1 pointe la chaine
          move.l a1,d6        ;debut chaine a formatter
          lea buffer+256,a2   ;a2 pointe la chaine de definition
          move.l a2,d7        ;debut chaine de format
us3:      move.b (a2),d0
          beq.s us5
          cmp.b #".",d0       ;cherche la fin du format de chiffre
          beq.s us5
          cmp.b #";",d0
          beq.s us5
          cmp.b #"E",d0
          beq.s us5
          addq.l #1,a0
          addq.l #1,a2
          bra.s us3
us5:      move.b (a1),d0
          beq.s us6
          cmp.b #".",d0       ;trouve le point de la chaine a formatter
          beq.s us6             ;ou la fin
          cmp.b #"E",d0
          beq.s us6
          addq.l #1,a1
          bra.s us5
us6:      movem.l a0-a2,-(sp)
; ecris la gauche du chiffre
us7:      cmp.l d7,a2         ;fini a gauche???
          beq us15
          move.b -(a2),d0
          cmp.b #"#",d0
          beq.s us8
          cmp.b #"-",d0
          beq.s us11
          cmp.b #"+",d0
          beq.s us12
          move.b d0,-(a0)     ;aucun signe reserve: le met simplement!
          bra.s us7
us8:      cmp.l d6,a1         ;-----> "#"
          bne.s us10
us9:      move.b #" ",-(a0)   ;arrive au debut du chiffre!
          bra.s us7
us10:     move.b -(a1),d0
          cmp.b #"0",d0       ;pas un chiffre (signe)
          bcs.s us9
          cmp.b #"9",d0
          bhi.s us9
          move.b d0,-(a0)     ;OK, chiffre: poke!
          bra.s us7
us11:     move.l d6,a3        ;-----> "-"
          move.b (a3),-(a0)   ;met le "signe": 32 ou "-"
          bra.s us7
us12:     move.l d6,a3
          move.b (a3),d0
          cmp.b #"-",d0
          beq.s us13
          move.b #"+",d0
us13:     move.b d0,-(a0)     ;-----> "+"
          bra us7
; ecrit la droite du chiffre
us15:     movem.l (sp)+,a0-a2 ;recupere les adresses pivot
          clr.l d2            ;flag puissance
          cmp.b #".",(a1)     ;saute le point dans le chiffre a afficher
          bne.s us16
          addq.l #1,a1
us16:     move.b (a2)+,d0
          beq sp11        ;fini OUF!
          cmp.b #";",d0       ;";" marque la virgule sans l'ecrire!
          beq.s us18z
          cmp.b #"#",d0
          beq.s us17
          cmp.b #"^",d0
          beq.s us20
          move.b d0,(a0)+     ;ne correspond a rien: POKE!
          bra.s us16
us17:     move.b (a1),d0      ;-----> "#"
          bne.s us19
us18:     tst d2
          beq.s us18a
us18z:    move.b #" ",(a0)+   ;si puissance passee: met des espaces
          bra.s us16
us18a:    move.b #"0",(a0)+   ;fin du chiffre: met un zero apres la virgule
          bra.s us16
us19:     cmp.b #"0",d0
          bcs.s us18
          cmp.b #"9",d0
          bhi.s us18
          addq.l #1,a1
          move.b d0,(a0)+
          bra us16
us20:     tst d2              ;-----> "^"
          bmi.s us24
          bne.s us25
us21:     move.b (a1),d0
          beq.s us22
          cmp.b #"E",d0
          beq.s us23
          addq.l #1,a1
          bra.s us21
us22:     move #1,d2          ;pas de puissance: en fabrique une!
          bra.s us25
us23:     move #-1,d2
us24:     move.b (a1),d0      ;si fin du chiffre: met des espaces
          beq us18
          addq.l #1,a1
          cmp.b #32,d0        ;saute l'espace entre E et +/-
          beq.s us24
          move.b d0,(a0)+
          bra us16
us25:     lea uspuiss,a3
          move.b -1(a3,d2.w),(a0)+ ;met une fausse puissance!
          cmp.b #6,d2
          beq us16
          addq #1,d2
          bra us16

; PRINT USING POUR DES CHAINES +++facile
using50:  move.l a5,a0        ;depile
          move.l (sp)+,a5
          tst usingflg        ;si pas using, va imprimer
          beq sp11
          clr.b (a0)          ;stoppe la chaine
          lea buffer,a0
          lea 128(a0),a1
          moveq #127,d0
us51:     move.b (a0)+,(a1)+  ;recopie la chaine, et fait le menage!!!
          dbra d0,us51
          lea buffer,a0
          lea 128(a0),a1      ;a1 pointe la chaine
          lea buffer+256,a2   ;a2 pointe la chaine de definition
; ecris la chaine dans le buffer
us52:     move.b (a2)+,d0
          beq sp11        ;fini!
          cmp.b #"~",d0
          beq.s us53
          move.b d0,(a0)+
          bra.s us52
us53:     move.b (a1),d0      ;----> "~"
          bne.s us54
          move.b #32,(a0)+
          bra.s us52
us54:     addq.l #1,a1
          move.b d0,(a0)+
          bra.s us52

;-------------------------------------------------------------
; stockage des programmes apres le source
          even
bufprg:   equ *













