
; >> version 0.0.0 du 14 mai 2011
; >> version 0.0.1 du 30 janvier 2022
;    - suppression de la table des symboles de FORTH(STE).LIB
;    si il y en a une...
;	  - >prgflags ajout‚
;	  - signale une erreur si red‚finition d'un mot 
; >> version 0.2.0 du 06 f‚vrier 2022
;	  - optimisation de l'assemblage des instructions +,-,<,>,=,<>,and,or,xor
;		 of,<>of,>of,<of, et les tableaux (array, array$, table, warray)
;		 si une constante pr‚cŠde l'instruction
;	  - erreur suppression table des symboles: la taille n'‚tait pas remise … z‚ro
;    - correction taille chemins/fichiers pour s‚lecteur fichier
;	  - correction fond fenˆtre noir/blanc sur CT60+Radeon
; 	  - optimisations d'assemblage dans le chaŒnage des instructions pour ‚viter
;		 l'utilisation de la pile
;	  - >ifflag pour compilation conditionnelle
; >> version 0.2.1 du 14 f‚vrier 2022
;	  - >endf au lieu de >comp en liaison avec >ifflag
; >> version 0.2.3 du 21 f‚vrier 2022
;	  - inclusion r‚cursive d'un fichier FOR avec 9 >include
;    - avertissement Fastopen manquant
;    - "%" remplac‚ par chemin fichier FOR pour >include/>export/>exec (ligne de commande)

version MACRO
	dc.b "0.2.3"
	ENDM

LANG equ 0		; 0 fran‡ais, 1 anglais
DBG equ 1		; 1 pour garder la souris mode debug, 0 sinon
STE equ 0

;*************************************
;*                                   *
;*   Compilateur FORTH 1992          *
;*                                   *
;*************************************

	if STE=0
	   opt w+,P=68030,P=68882
	   if LANG=0
	   	OUTPUT "COMP.PRG"
	   else
	   	OUTPUT "ENGLISH\COMP.PRG"
	   endif
	else
		opt w+,P=68000
		if LANG=0
			OUTPUT "COMPSTE.PRG"
		else
			OUTPUT "ENGLISH\COMPSTE.PRG"
		endif
	endif

GGHH MACRO
  move #65,-(sp)
  move #2,-(sp)
  move #3,-(sp)
  trap #13
  addq.l #6,a7
  ENDM

XBIOS MACRO   ; fn,pile
   move #\1,-(sp)
   trap #14
   if \2<=8
      addq.l #\2,sp
   else
      add.w #\2,sp
   endif
   ENDM

BIOS MACRO    ; fn,pile
   move #\1,-(sp)
   trap #13
   if \2<=8
      addq.l #\2,sp
   else
      add.w #\2,sp
   endif
   ENDM

GEMDOS MACRO    ; fn,pile
   move #\1,-(sp)
   trap #1
   if \2<=8
      addq.l #\2,sp
   else
      add.w #\2,sp
   endif
   ENDM

GEM_AES MACRO
   move.l #\1,d1
   move.l #$c8,d0
   trap #2
   ENDM

GEM_VDI MACRO
   move.l #\1,a0
   move.l a0,d1
   move.l (a0),a0
   move i_handle,12(a0)
   moveq #$73,d0
   trap #2
   ENDM

   data
   even

	if LANG=0
gloups1:  dc.b "Erreur … la lecture du source !",0
	if STE=0
gloups2:  dc.b "Erreur … la lecture de FORTH.LIB !",0
	else
gloups2:  dc.b "Erreur … la lecture de FORTHSTE.LIB !",0
	endif	
gloups3:  dc.b "Erreur de compilation !",0
gloups4:  dc.b "Erreur … l'‚criture du programme !",0
mess1:  dc.b "Chargement du fichier source ...",0
mess2:  dc.b "Chargement de la librairie ...",0
mess2b: dc.b "Suppression infos DEBUG ...",0
mess3:  dc.b "Compilation du source ...",0
mess4:  dc.b "Edition des liens ...",0
mess5:  dc.b "Programme ex‚cutable",0
mess6:  dc.b "Ecriture du programme ...",0
	else
gloups1:  dc.b "Can't read source file !",0
	if STE=0
gloups2:  dc.b "Can't read FORTH.LIB !",0
	else
gloups2:  dc.b "Can't read FORTHSTE.LIB !",0
	endif
gloups3:  dc.b "Compilation error !",0
gloups4:  dc.b "Can't write output program !",0
mess1:  dc.b "Loading source file ...",0
mess2:  dc.b "Loading library ...",0
mess2b: dc.b "Removing DEBUG infos ...",0
mess3:  dc.b "Compiling source code ...",0
mess4:  dc.b "Editing links ...",0
mess5:  dc.b "Executable program",0
mess6:  dc.b "Writing program ...",0	
	endif
	
   even
fichier: dcb.b 100,0
source: dcb.b 200,0
fich2:  dcb.b 100,0

   even

	if LANG=0
pasbon: dc.b " Ce n'est pas un mot utilisateur",0
	else
pasbon:  dc.b " This is not a user word",0
	endif

   even

struc:  dc.w 0
pilptr:  dc.l pile
base:  dc.l 10
opt_count: dc.l 0
global: dc.l 0,0,0,0,0,0,0,0

   bss
   even

fastopen_flag: ds.b 2	; FF si fastopen trouv‚ puis FF si instruction ‚criture trouv‚e
inc_ptr: ds.l 1				; pointeur sur la chaine des boc d'>include FOR ou z‚ro
						;chaque bloc, 256 octets:
						; LONG pointeur bloc suivant
						; WORD handler fichier ouvert
						; WORD nbr de lignes restantes
						; LONG taille fichier puis sauvegarde compilptr
						; le reste correspond … une ligne du fichier + WORD taille ligne suivant

pile:      ds.l 1025
zone:      ds.l 16
topsave:   ds.l 1
bfsize:    ds.l 1
i_handle:    ds.w 1
intin:     ds.w 128
intout:    ds.w 128
addrin:    ds.l 64
addrout:   ds.l 64
ptsin:     ds.w 128
ptsout:    ds.w 128
forth:     ds.w 1
dicco:     ds.w 1
sommet:    ds.l 1
mot:       ds.b 42
erreur:    ds.w 1
linea:     ds.l 1
fhdl:      ds.w 1
ldbuf:     ds.b 6
fincomp:   ds.w 1
uspile:    ds.l 1
basesav:   ds.l 1
courant:   ds.w 1
ass:       ds.w 1
find:      ds.w 1
start:     ds.w 1
inter:     ds.l 1
interfin:  ds.l 1
offset:    ds.l 1
prog:      ds.l 1
relfin:    ds.l 1
relog:     ds.l 1
relptr:    ds.l 1
terminus:  ds.l 1
dlcomp:    ds.l 1
indptr:    ds.l 1
lstptr:    ds.l 1
copy_pts: ds.w 8
mf1:      ds.w 18
mf2:      ds.w 18
dum:      ds.l 2
vt_int:   ds.w 514
in_def:   ds.w 1
commande_buf: ds.b 512	; pour >exec et >export
chemin: 	ds.b 200
file:		ds.b 200
chemin2:	ds.b 200
off_relog: ds.l 1
ass_const: ds.b 1		; si constante empil‚e pour optimiser instruction suivante
	even

   text

   jmp initial

	if STE=0
info: dc.b "COMP.INF",0
	else
info: dc.b "COMPSTE.INF",0
	endif
	even

adresse:  dc.l 0
ordres:   dc.l 0


debut: bsr loadb                ; charge le source
       bsr cr
       lea mess2(pc),a0
       bsr write_str
       bsr charge               ; charge FORTH.LIB ou FORTHSTE.LIB
       bsr cr
       lea mess3(pc),a0
       bsr write_str
       clr erreur
       bsr compil               ; compile le source
       tst erreur
       bne fin3
       bsr cr
       lea mess4(pc),a0
       bsr write_str
       bsr ajuste               ; reloge les accŠs BSS
       bsr recolle              ; remet la table de relogement
       bsr cr
       move.l opt_count(pc),d0
       beq.s .lb0
		 lea o_titre(pc),a0				; change le titre de la fenˆtre
		 move.l a0,wst_in+4
		 lea 26(a0),a0
		 move.l d0,d1
		 bsr nombre						; optimisations de chaŒne
		 swap d0
		 subq.l #5,a0
		 move.l d0,d1
		 bsr nombre						; optimisation de constantes
		 GEM_AES wind_set_title
.lb0:
       lea mess5(pc),a0
       bsr write_str
       bsr saveb              ; sauve le *.prg
       move fastopen_flag,d0	; fastopen est il pr‚sent?
       bmi.s fin					; oui !
       tst.b d0					; si il est absent, testons si on ‚crit
       beq.s fin					; non, donc pas d'avertissement
       bsr cr
       lea cbug15(pc),a0
       bsr write_str				; warning
       move #2,-(sp)				; attend une touche
       BIOS 2,4

fin:
   bsr vider_inclusions		; en cas d'erreur, vider chaine >include
   bsr fastclose
   GEM_VDI close_work
   GEM_AES appl_exit
   move.l uspile,a7
   GEMDOS 0,2

fin1: lea gloups1(pc),a0
      bra.s term
fin2: lea gloups2(pc),a0
      bra.s term
fin3: lea gloups3(pc),a0
      bra.s term
fin4: lea gloups4(pc),a0
term:
      bsr cr
		bsr write_str
		GEM_AES event_key
      bra.s fin

	; d1.l … transformer en -(a0) sur 5 chiffres
nombre:
	ext.l d1
	moveq #4,d2
.lb0:
	divs #10,d1
	swap d1
	add.b d1,-(a0)
	clr d1
	swap d1
	dbf d2,.lb0
	rts
	

	if LANG=0
   even
bugass:  dc.b "  --->  Mot non assemblable",0
cbug1:  dc.b " Mot manquant aprŠs un mot de d‚finition",0
cbug2:  dc.b " Chaine absente ou incomplŠte aprŠs .",34," ou ",34,0
cbug3:  dc.b " Mot inconnu ou nombre exprim‚ dans une mauvaise base : ",0
cbug4:  dc.b " Buffer d'ex‚cution plein ( utiliser >comp ) -> ",0
cbug5: dc.b " Fichier … inclure dans une d‚finition!",0
cbug6: dc.b " D‚finitions … inclure hors d'une d‚finition!",0
cbug7: dc.b " Erreur >include: format PRG/FOR non reconnu!",0
cbug8: dc.b " Erreur >include: chargement impossible!",0
cbug9: dc.b " Erreur >include: masque d'options absent sur la pile!",0
cbug10: dc.b " Erreur >include: chaine fichier mal ferm‚e!",0
cbug12: dc.b " Erreur >true/>false: nø de flag incorrect!",0
cbug13: dc.b " Erreur >prgflags: constante attendue sur la pile!",0
cbug14: dc.b " Red‚finition d'un mot existant : ",0
troplong:  dc.b " Mot trop long ( 40 caractŠres maximum )",0
cbug15: dc.b " ATTENTION: fastopen manquant et ‚critures pr‚sentes!",0
   even

	; offset + 58 (zone remplac‚e selon la langue … la compilation)
	;				( par comp.prg)
	; les labels ici ne veulent rien dire (… part avert pour le calcul de taille)
avert: dc.b  "[2][ Inserer la diquette     | … formater | dans le lecteur "
avertd: dc.b "A ][Ca y est|Annuler]",0
avert1: dc.b "[1][ L'imprimante n'est pas | | prete … recevoir. ]"
        dc.b "[Annuler|Imprimer]",0
w_titre2: dc.b "Mon Bon FORTH "
	version
	dc.b 0,0        
   even
finavert:

	else
	
   even
bugass:  dc.b "  --->  Can't assemble this word",0
cbug1:  dc.b " Missing word after a definition",0
cbug2:  dc.b " Uncomplete or missing string after .",34," or ",34,0
cbug3:  dc.b " Unknown word or bad number in current base : ",0
cbug4:  dc.b " Execution buffer is full ( use >comp ) -> ",0
cbug5: dc.b " Include file within a definition!",0
cbug6: dc.b " D‚finitions … inclure hors d'une d‚finition!",0
cbug7: dc.b " Error >include: unknown PRG/FOR format!",0
cbug8: dc.b " Error >include: can't load file!",0
cbug9: dc.b " Error >include: missing option mask on the stack!",0
cbug10: dc.b " Error >include: unended string for filename!",0
cbug12: dc.b " Error >true/>false: bad flag number!",0
cbug13: dc.b " Error >prgflags: a constant is expected on the stack!",0
cbug14: dc.b " Attempt to redefine an existing word : ",0
troplong:  dc.b " Word too long ( 40 characters maximum )",0
cbug15: dc.b " WARNING: missing fastopen with write instructions !",0
   even

	; offset + 58 (zone remplac‚e selon la langue … la compilation)
	;				( par comp.prg)
avert: dc.b  "[2][ Insert the disk         | to be formatted | into drive "
avertd: dc.b "A: ][ Done | Cancel ]",0
avert1: dc.b "[1][ The printer is not     | | ready to receive. ]"
        dc.b "[ Cancel | Print ]",0
w_titre2: dc.b "My Good FORTH "
	version
	dc.b 0,0        
   even
finavert:

	endif

; recherche du mot suivant dans la phrase

motsuiv: move.l #mot,a1
         moveq #0,d1
         moveq #32,d2
.loop:   tst.b (a0)
         bne.s .lb0
         tst.l inc_ptr		; nous incluons un autre fichier depuis le disque?
         beq.s .ram
			bsr _load_line		; oui, on charge la ligne suivante!         
			bra.s .loop
.ram:
         tst (a0)
         beq.s .fin
         addq.l #3,a0
         bra.s .loop
.lb0:    cmp.b (a0)+,d2
         beq.s .loop
         subq.l #1,a0
.lab1:   move.b (a0)+,d2
         bne.s .lab2
         subq.l #1,a0
         bra.s .sortie
.lab2:   cmp.b #32,d2
         beq.s .sortie
         move.b d2,(a1)+
         addq #1,d1
         cmp #41,d1
         bne.s .lab1
         bra.s .bug
.fin:    move #-1,fincomp
.sortie: clr.b (a1)
         move.b d1,d7
         cmp.b #1,d1
         bne.s .out
         cmp.b #'\',-(a1)
         bne.s .out
.lab3:   tst.b (a0)+
         bne.s .lab3
         subq.l #1,a0
         bra.s motsuiv
.out:    rts
.bug:    bsr cr
         lea troplong(pc),a0
         bsr write_str
         addq.l #4,a7
         move #1,erreur
         rts

	; charge une nouvelle ligne
	; (a0) pointe sur le mot "taille" $00ss
	; en retour a0 pointe sur la nouvelle ligne
	;           EQ si dans le mˆme fichier
	;				NE si on a d– fermer.
	
_load_line:
			movem.l d0-d4/a1-a3,-(sp)
			move.l inc_ptr,a3
			addq.l #4,a3		; skip chain address
			move (a3)+,d4		; file handle
			subq #1,(a3)+		; one line less
			bmi.s .ll1			; no more, close file !
			addq.l #4,a3		; skip saved compilptr
			move.l a3,-(sp)	; pour charger
			move (a0),d0		; size of next line
			ext.l d0
			move.l d0,-(sp)
			move d4,-(sp)
			GEMDOS 63,12		; fread
			lea 1(a3),a0		; skip "tab" byte in source code
			moveq #0,d0
			bra.s .ll2
.ll1:
			bsr depile_inc		; remove block and close file
			move.l (a3),a0		; back on original compilptr
			moveq #1,d0
.ll2:
			movem.l (sp)+,d0-d4/a1-a3
			rts

; compilation du source

compil:  move.l beuf,a0
			clr in_def
         clr.l ass
         clr start
         clr struc
			sf ass_const        
         move.l inter,a2
         move.l pilptr,a6
         addq.l #4,a6
.suite:  bsr motsuiv
         moveq #0,d4
         tst.b d1
         bne.s .lab1
.sortie: tst start
         bne.s .sort
         move #1,(a2)+
.sort:   move #122,(a2)+
         move.l a2,interfin
         rts
.lab1:   
			bsr find_word
			beq .findic			; if EQ, word does not exist
         tst find
         beq.s .lb66
         clr find
         move.l base,basesav
         move d4,d5
         ext.l d5
         bra .lab5
.lb66:   bsr fastopen_test	; v‚rifie si fastopen utilis‚ si instructions graphiques
			cmp #171,d4    ; >comp
         bne.s .lb600
         tst start
         beq .suite
         move #146,(a2)+
         clr start
         bra .suite
.lb600:  cmp #113,d4    ; find
         bne.s .lb60
         move #-1,find
         bra .suite
.lb60:   cmp #862,d4		; inclure
			bne.s .lb6o
			bsr inclure
			beq .bug
			bra .suite
.lb6o:
			cmp #863,d4		; >true
			bne.s .lb6a
.lb6b:
			bsr flag_cond
			beq .bug
			bra .suite
.lb6a:
			cmp #864,d4		; >false
			beq.s .lb6b
			cmp #865,d4		; >export
			bne.s .lb6c
			bsr export_source
			beq .bug
			bra .suite
.lb6c:
			cmp #866,d4
			bne.s .lb6d		; >exec
			bsr exec_prog
			beq .bug
			bra .suite
.lb6d:
			cmp #867,d4		; >prgflags
			bne.s .lb6e
			bsr prg_flags
			bne .bug13
			bra .suite
.lb6e:
			cmp #868,d4		; >ifflag
			bne.s .lb6f
			bsr ifflag		; saute jusqu'au >comp si if flag est faux, sinon compile en s‚quence
			beq .bug
			bra .suite
.lb6f:
			cmp #869,d4		; >endf
			beq .suite		; rien … faire !
			cmp #78,d4     ; :
         beq.s .lb61
         cmp #571,d4    ; ::
         bne .lab2
         move #1,ass
.lb61:   move forth,courant
			move #1,in_def
         tst start
         beq.s .lb62
         move #146,(a2)+
.lb62:   move #-1,(a2)+
         move courant,(a2)+
         move #-1,start
         move.l a2,offset
         addq.l #4,a2
.nouvo:  bsr motsuiv			; le nouveau mot
         tst.b d1
         beq .bug1			; vide! erreur
         movem.l d4,-(sp)
         bsr find_word
         movem.l (sp)+,d4
         bne .bug14			; if NE, mot existant, erreur!
         cmp #78,d4
         beq.s .bon
         cmp #571,d4
         beq.s .bon
         move forth,(a2)+
.bon:    move.l sommet,a3
         move.b d1,(a3)+
         subq #1,d1
         move.l #mot,a4
.lab7:   move.b (a4)+,(a3)+
         dbf d1,.lab7
         move.l a3,sommet
         clr.b (a3)
.lb1:    move.l relog,a3
         sub.w forth,a3
         add.w dicco,a3
         cmp #587,d4      ; &name
         bne.s .ll0
         clr struc
.ll0:    tst struc
         bne.s .ass
         cmp #78,d4
         bne.s .ll1
         moveq #0,d0
         bra.s .llf
.ll1:    cmp #7,d4
         bpl.s .ll2
         move d4,d0
         bra.s .llf
.ll2:    cmp #719,d4
         bne.s .ll21
         moveq #2,d0
         bra.s .llf
.ll21:   cmp #611,d4
         bne.s .ll3
.ll25:   moveq #8,d0
         bra.s .llf
.ll3:    cmp #612,d4
         beq.s .ll25
         cmp #705,d4
         bne.s .ll4
         moveq #9,d0
         bra.s .llf
.ass:    moveq #7,d0
         bra.s .llf
.ll4:    cmp #571,d4
         beq.s .ass
         cmp #436,d4
         beq.s .ass
         cmp dicco,d4
         bpl.s .ass
         moveq #1,d0
.llf:    move.b d0,-(a3)
         addq #1,forth
         cmp #571,d4
         bne .suite
         move #437,(a2)+
         bra .suite
.lab2:   tst ass
         beq.s .lb21
         bsr assemblons
         tst erreur
         beq .suite
         bra .bugend
.lb21:   tst start
         bne.s .lb211
         not start
         move #1,(a2)+
.lb211:  move d4,(a2)+
         cmp #7,d4
         bmi .nouvo
         move.b mot,d2
         cmp.b #"&",d2
         beq .nouvo
; ici cas particuliers de compilation
         cmp #79,d4
         bne.s .lb0
         clr start
         move.l a2,d0
         move.l offset,a4
         sub.l a4,d0
         subq.l #4,d0
         move.l d0,(a4)+	; pointe donc sur la 1Šre instruction du mot
			move (a4),d2		; son code
			bsr son_type		; en cas d'utilisation de [var] ou autre
									; r‚vise le type du mot (de code 'courant')
         clr in_def
         bra .suite
.lb0:    cmp #66,d4
         beq.s .lb8
         cmp #700,d4
         beq.s .lb8
         cmp #701,d4
         beq.s .lb8
         cmp #702,d4
         beq.s .lb8
         cmp #712,d4
         beq.s .lb8
         cmp #714,d4
         beq.s .lb8
         cmp #69,d4
         beq.s .lb8
         cmp #62,d4
         bne.s .lb9
.lb8:    move.l a2,(a6)+ ; if, while, of et ses d‚riv‚s, and->, or->
         addq.l #2,a2
         bra .suite
.lb9:    cmp #71,d4
         beq.s .lb10
         cmp #63,d4
         bne.s .lb11
.lb10:   tst.l -(a6)       ; then ou repeat
         beq .suite        ; then suit un godo
         move.l a2,d4
         subq.l #2,d4
         sub.l (a6),d4
         move.l (a6),a3
         move d4,(a3)
         bra .suite
.lb11:   cmp #70,d4
         beq.s .lb12
         cmp #67,d4
         bne.s .lb13
.lb12:   move.l a2,d4      ; else ou endof
         sub.l -(a6),d4
         move.l (a6),a3
         move d4,(a3)
         move.l a2,(a6)+
         addq.l #2,a2
         bra .suite
.lb13:   cmp #138,d4
         beq.s .lb14
         cmp #139,d4
         bne.s .lb16
.lb14:   addq.l #2,a2
			move.l a2,(a6)+
			tst.b (a0)  ; (") ou (.")
         beq .bug2
.lb15:   move.b (a0)+,d4
         beq .bug2
         move.b d4,(a2)+
         cmp.b #34,d4
         bne.s .lb15
         clr.b -1(a2)
         move.l a2,d4
         and #1,d4
         add.w d4,a2
         move.l a2,d4
         move.l -(a6),a3
         sub.l a3,d4
         move d4,-(a3)
         bra .suite
.lb16:   cmp #65,d4
         bne.s .lb17
.lab16:  clr.l (a6)+    ; case ou ->
         bra .suite
.lb17:   cmp #711,d4
         beq.s .lab16
         cmp #68,d4
         beq.s .lb18
         cmp #713,d4
         bne.s .lb20
.lb18:   tst.l -(a6)  ; ->. , endcase
         beq .suite
         move.l a2,d4
         subq.l #2,d4
         sub.l (a6),d4
         move.l (a6),a3
         move d4,(a3)
         bra.s .lb18
.lb20:   cmp #368,d4      ; exe+
         bne.s .lb22
         move courant,d1
         ext.l d1
         clr -2(a2)
         move.l d1,(a2)+
         move d4,(a2)+
         bra .suite
.lb22:   cmp #585,d4      ; struct
         bne .suite
         move #1,struc
         bra .suite

; ici on cherche si un mot est un nombre
.findic: moveq #0,d5
         move.l base,basesav
         clr d6
         move d1,d4
         subq #1,d4
         move.l #mot,a4
         move.b (a4),d0
         cmp.b #"%",d0
         bne .f5
         addq.l #1,a4
         subq #2,d4
         move.b (a4)+,d0
         cmp.b #"f",d0
         bne.s .f0
         movem.l d2-d7/a0-a3,zone
         move.l a4,a0
         bsr subval
         movem.l zone,d2-d7/a0-a3
         move #637,d4
         tst ass
         beq.s .f00
         bsr assemblons
         bra .suite
.f00:    tst start
         bne.s .f01
         not start
         move #1,(a2)+
.f01:    move d4,(a2)+
         move.l d1,(a2)+
         move.l d0,(a2)+
         bra .suite
.f0:     cmp.b #"b",d0
         bne.s .f2
         moveq #2,d0
         bra.s .f1
.f2:     cmp.b #"d",d0
         bne.s .f3
         moveq #10,d0
         bra.s .f1
.f3:     cmp.b #"o",d0
         bne.s .f4
         moveq #8,d0
         bra.s .f1
.f4:     cmp.b #"h",d0
         bne .bug3
         moveq #16,d0
.f1:     move.l d0,base
.f5:     move.b (a4),d0
         cmp.b #"-",d0
         bne.s .lab3
         addq.l #1,a4
         subq #1,d4
         move #1,d6
.lab3:   move.l base,(a6)+
         move.l d5,(a6)
         bsr mul
         move.l (a6),d5
         moveq #0,d3
         move.b (a4)+,d3
         sub.l #"0",d3
         bmi .bug3
         cmp.l #10,d3
         bmi.s .lab4
         subq.l #7,d3
         cmp #36,d3
         bmi.s .lab4
         sub.l #32,d3
.lab4:   cmp.l base,d3
         bpl.s .bug3
         add.l d3,d5
         dbf d4,.lab3
         tst d6
         beq.s .lab5
         neg.l d5
.lab5:   tst ass
         beq.s .lab23
         clr d4
         bsr assemblons
         bra.s .lab24
.lab23:  tst start
         bne.s .ll23
         not start
         move #1,(a2)+
.ll23:   clr (a2)+
         move.l d5,(a2)+
.lab24:  move.l basesav,base
         bra .suite
.bug14:	lea cbug14(pc),a0
			bra.s .bug31
.bug13:	lea cbug13(pc),a0
			bsr cr
			bra.s .bug
.bug1:   lea cbug1(pc),a0
         bsr cr
         bra.s .bug
.bug2:   lea cbug2(pc),a0
         bsr cr
         bra.s .bug
.bug3:   lea cbug3(pc),a0
.bug31:  bsr cr
			bsr write_str
         lea mot(pc),a0
.bug:    bsr write_str
         move #1,erreur
.bugend: move.l basesav(pc),base
         rts

flags: dcb.b 13,-1			; true de 0 … 12
	dc.b 0						; flag 13 faux sous le compilateur
	if STE=0
		dc.b -1					; flag 14 vrai si 68030
	else
		dc.b 0					; faux si 68000
	endif
	if LANG=0
		dc.b -1					; flag 15 vrai si fran‡ais
	else
		dc.b 0					; faux si anglais
	endif

	; return EQ if word doesn't exist
	; return NE if it exists
	
find_word:
			move.l ordres(pc),a3
         moveq #0,d2
.autre:  move.b (a3)+,d2
         beq.s .findic
         cmp.b d1,d2
         beq.s .voyons
.bennon: add.l d2,a3
         addq.l #1,d4
         bra.s .autre
.voyons: move.l #mot,a4
         move d2,d7
         subq #1,d7
         move.l a3,a5
.lab6:   cmp.b (a4)+,(a5)+
         dbne d7,.lab6
         bne.s .bennon
.findic:
			tst.b d2
			rts

ifflag:
	move.l -(a2),d7
	swap d7						; +/- n dans le mot haut
	clr d7						; annule le bas
	move.l d7,(a2)+
	bsr mot_commande
	bne .bug1
	tst.l d7
	bmi.s .ok					; si le flag est VRAI, on ne fait rien, la compilation continue
.lb0:
	move.l #'endf',d0
	bsr une_ligne				; avancer jusqu'… >endf
	bne.s .lb0
	cmp #0,a1					; >comp trouv‚, ok
	beq.s .ok
	lea .ibug2(pc),a0
	cmp #1,a1					; pas de >comp
	beq.s .erreur
	lea .ibug3(pc),a0			; si a1=2, fin de bloc
	bra.s .erreur
.ok:
	moveq #1,d0					; NE ok
	rts
.bug1:
	lea .ibug1(pc),a0
.erreur:
	moveq #0,d0					; EQ erreur
	rts
	if STE=0
.ibug1: dc.b " Erreur >ifflag: mauvais mot de commande.",0
.ibug2: dc.b " Erreur >ifflag: >endf manquant!",0
.ibug3: dc.b " Erreur >ifflag: fin de bloc avant >endf !",0
	else
.ibug1: dc.b " Error >ifflag: bad command word!",0
.ibug2: dc.b " Error >ifflag: missing >endf !",0
.ibug3: dc.b " Error >ifflag: block end before >endf !",0	
	endif
	even

fastopen_test:
	lea fastopen_flag(pc),a1
	tst.b (a1)					; d‚j… trouv‚ ?
	bne.s .exit					; oui  rien … faire
	cmp #731,d4					; c'est fastopen?
	seq (a1)+
	beq.s .exit					; on vient de le trouver
	tst.b (a1)					; d‚j… des instructions d'‚criture trouv‚es?
	bne.s .exit					; oui, donc pas de soucis
	lea .fonctions(pc),a1
.lb0:
	move (a1)+,d2
	beq.s .exit					; fin de liste
	cmp d2,d4					; instruction trouv‚e?
	bne.s .lb0					; pas encore
	st fastopen_flag+1		; sinon mettre flag !	
.exit:
	rts
.fonctions:
	dc.w 124,127,134,138,136,596,135,128,131,132,108,635,640,581,582,583,584,151,129,609,610,0

; traite le mot de commande de la forme
; %h 000n dddd
; n=num‚ro de flag (0-15)
; dddd une donn‚e selon la commande
; si le mot est n‚gatif c'est pour valider si le flag est faux
; renvoie:
; NE si mauvais mot de commande
; EQ si ok et D7 = xxxx dddd
; xxxx = 0 si FAUX et FFFF si vrai
; dddd = valeur conserv‚e

mot_commande:
			move.l -(a2),d7	; mot de commande
			bpl.s .lb1
			neg.l d7
.lb1:
			swap d7				; le num‚ro du flag
			and #$F,d7			; de 0 … 15
			move.l a2,-(sp)
			lea flags(pc),a2
			move.b 0(a2,d7.w),d7	; true ou flase
			ext.w d7				; FFFF ou 0000
			move.l (sp)+,a2
			tst.b (a2)
			bpl.s .lb2
			not d7
.lb2:
			swap d7
_is_constant:
			move.w -(a2),d0	; 0 en interpr‚t‚ et move.l #...,-(a6) en compil‚
			tst ass
			beq.s .lb0
			cmp.w #$2D3C,d0	; move.l #
			bra.s .ok
.lb0:		tst d0
.ok:		rts					; renvoit NE en cas de prob ou EQ si Ok

	; v‚rifie qu'il y a bien une constant juste avant
	; et modifie le LONG prg flags de l'en-tˆte
	
prg_flags:
			move.l -(a2),d0		; valeur
			move.l a2,-(sp)		; sauve a2
			move.l prog,a2			; en tete
			move.l d0,22(a2)		; nouveaux flags en +22
			move.l (sp)+,a2		; r‚cupŠre
			bra.s _is_constant	; v‚rifie...

inclure:
			bsr mot_commande
			bne .bug1			; pas de mot de commande
.ok:
			tst in_def
			bne.s .okk			; si 1, d‚j… dans une d‚finition

			move d7,d0
			and #$9,d0
			cmp #9,d0
			beq.s .okk			; pas de changement si c'est l'inclusion d'un FOR
			
			move #146,(a2)+	; termine l'autre zone (peut-ˆtre vide!!)
			move.l a2,offset	; c'est l… qu'on est!
			move forth,2(a2)	; mot de d‚but
			addq.l #8,a2		; saute l'en-tˆte
.okk:
			tst.b (a0)
			beq .bug2			; chaine mal form‚e
			cmp.b #34,(a0)+		; cherche le " de d‚part
			bne.s .okk
			move.l a0,a1		; d‚but du nom
.lb1:
			tst.b (a0)
			beq .bug2
			cmp.b #34,(a0)+		; cherche le " final
			bne.s .lb1

			tst.l d7
			bpl .ignorer		; le flag est … 0, pas d'inclusion!

			move.l a0,a4		; conserve la fin
			clr.b -(a4)			; vire le " momentan‚ment
			move.l a2,a3		; au cas o— GEMDOS le d‚truise!

			move.l a2,a0		; zone libre pour le chemin+nom
			sf (a0)
			jsr expand_path		; ‚tend les % de (a1)  avec le chemin actuel

			clr -(sp)
			move.l a0,-(sp)
			GEMDOS 61,8			; fopen
			move.b #34,(a4)+
			move d0,d4			; le handle!
			bmi .bug3

			btst #0,d7			; =0 programme PRG, =1 autre
			beq .prg
			
.autre:			

			move #2,-(sp)
			move d4,-(sp)
			clr.l -(sp)
			GEMDOS 66,10
			move.l d0,d5		; taille totale du fichier
			bmi .bug3			; erreur de lecture

			clr -(sp)
			move d4,-(sp)
			clr.l -(sp)
			GEMDOS 66,10		; revient au d‚but du fichier
			tst.l d0
			bmi .bug3

			btst #3,d7			; fichier FOR ?
			beq.s .autre2
			
			move.l #256,-(sp)	; reserve un nouveau bloc
		   GEMDOS 72,6
		   move.l d0,a0		; nouvelle adresse
		   lea inc_ptr(pc),a1
		   move.l (a1),(a0)+	; chaine
		   move.l d0,(a1)		; nouveau pointeur courant
		   move d4,(a0)+		; garde le handle
		   						
			pea (a0)
			moveq #8,d0
			move.l d0,-(sp)	; 8 octets du header
			move d4,-(sp)
			GEMDOS 63,12		; fread
			cmp #8,d0
			bne .bug3			
			
			move.l inc_ptr,a0
			addq.l #8,a0		; saute chainage + handle + nbr ligne
			move.l (a0),d0		; normalement taille fichier - 6
			addq.l #6,d0
			cmp.l d0,d5
			bne .bug4			; format non reconnu
			move.l a4,(a0)+	; sauvegarde compilptr
			tst.b (a0)			; normalement nul, c'est le d‚but d'une ligne !
			bne .bug4			; format non reconnu
			bra .ignorer		; sortie avec Ok !

.autre2:
			lea 0(a3,d5.l),a2
			move.l a2,-(sp)
			move.l a2,-(sp)
			move.l a2,-(sp)	; pour rester compatible avec les autres cas
			bra.s .lire

.prg:
			move.l a3,-(sp)	; pour charger
			moveq #28,d0
			move.l d0,-(sp)	; 28 octets du header
			move d4,-(sp)
			GEMDOS 63,12		; fread
			cmp #28,d0
			bne .bug3

			cmp #$601a,(a3)	; header?
			bne .bug4
			move.l 2(a3),d5	; taille TEXT
			move.l a3,-(sp)	; sauve d‚but text
			pea 0(a3,d5.l)		; sauve d‚but data
			add.l 6(a3),d5		; taille text+data
			pea 0(a3,d5.l)		; sauve fin DATA
			add.l d5,d0
			add.l 14(a3),d0	; text+data+symb+head=offset relogement
			move.l d0,off_relog

.lire:
			move.l a3,-(sp)
			move.l d5,-(sp)
			move d4,-(sp)
			GEMDOS 63,12		; fread

			cmp.l d5,d0
			beq .lb2
			lea 12(sp),sp		; vire les trois .L sauv‚s
			bra .bug3

.lb2:
			move.l a4,a0		; restaure le pointeur de texte

			move.l (sp)+,d0	; fin data
			move.l (sp)+,a3	; d‚but data
			move.l (sp)+,a2	; d‚but TEXT

			btst #0,d7
			bne .raw				; chargement brut
			cmp.l #"ADD_",(a3)+
			bne .raw
			cmp.l #"DEFS",(a3)+
			bne .raw

			lea -8(a3),a0		; ne reloge que le TEXT (arret au debut data)
			bsr reloge_ferme
			move.l a4,a0		; restaure le pointeur de texte

			tst in_def
			bne .bug6			; def dans def!
.ok2:
			move.l a3,d0
			subq.l #8,d0		; d0 pointe sur d‚but DATA
			move.l d0,a4
			moveq #0,d1			; aucun mot par d‚faut
			move forth,courant	; pour son_type
.lb3:
			move.l (a3)+,d2	; adresse
			bmi.s .lb44			; si <0, c'est la fin
			addq #1,d1			; un mot de plus
			move.l d2,(a4)+	; garde l'offset … la suite de TEXT
			move.w 0(a2,d2.l),d2	; premier code du mot
			bsr son_type		; range son type (pour l'assembler ‚ventuellement)
			addq #1,courant	; nouveau mot
			bra.s .lb3
.lb44:
			add.w d1,forth
			move.l offset,a2	; d‚but en-tete
			move #-1,(a2)
			sub d1,(a2)			; code -2=1 mot, -3=2mots ...
			sub.l offset,d0	; vrai offset+8
			subq.l #8,d0
			move.l d0,4(a2)	; offset rang‚!
			move.l a4,d0		; nouvelle fin
			clr start			; la suite sera un nouveau bloc
			bra.s .lb4
.lb5:		move.l sommet,a2
			lea 1(a2),a1
.lb6:
			move.b (a3)+,(a1)+
			bne.s .lb6
			subq.l #1,a1
			move.l a1,sommet
			sub.l a2,a1
			subq #1,a1
			move a1,d2
			move.b d2,(a2)			; sa taille
.lb4:
			dbf d1,.lb5
			move.l d0,a2		; pointeur au d‚but des DATAS (ignor‚s donc!)
			bra.s .fin_ok
.raw:
			move.l d0,a0		; reloge jusqu'… la fin des datas
			bsr reloge_ferme
			move.l a4,a0
			tst in_def
			beq .bug5
			move.l d0,a2		; pointeur en fin de DATAS
.fin_ok:
			btst #1,d7			; =1 ignorer parit‚ dicco, =0 assurer parit‚
			bne.s .pas_pair
			move.l a2,d0
			addq.l #1,d0
			bclr #0,d0
			move.l d0,a2		; rend a2 pair (avec ‚ventuellement +1)

.pas_pair:
.ignorer:
			moveq #1,d0			; renvoit NE
			rts

.bug1:   lea cbug9(pc),a0
			bra.s .fin_bug
.bug2:   lea cbug10(pc),a0
			bra.s .fin_bug
.bug3:	lea cbug8(pc),a0
			bra.s .fin_bug
.bug4:   lea cbug7(pc),a0
			bra.s .fin_bug
.bug5:   lea cbug5(pc),a0
			bra.s .fin_bug
.bug6:	lea cbug6(pc),a0
			bra.s .fin_bug

			nop
.fin_bug:
			sub d0,d0			; pour avoir EQ au retour
			rts

; attend a0:finde la zone … reloger
;			a2:d‚but de la zone et debut de text aussi
;			d0:fin zone data (donc l… ou on peut charger la table)

reloge_ferme:
	movem.l d0/a2-a3,-(sp)
	btst #0,d7
	bne.s .fin			; pas un programme, juste fermer
	move.l d0,a3		; adresse ou charger
	btst #2,d7
	bne.s .fin			; bit mis, pas de relogement
	move.l a0,-(sp)	; sauve critŠre de fin
	clr -(sp)			; … partir du d‚but du fichier
	move d4,-(sp)		; handle
	move.l off_relog,-(sp)
	GEMDOS 66,10
	move.l a3,-(sp)	; adresse ou charger
	move.l #$7fffffff,-(sp) ; jusqu'au bout
	move d4,-(sp)
	GEMDOS 63,12
	move.l (sp)+,a0	; le critŠre de fin
	move.l a2,a1
	move.l a2,d1
	sub.l prog,d1		; moins debut programme
	sub.l #28,d1		; moins header, offset … ajouter aux r‚f‚rences
	tst.l (a3)			; pr‚sence d'une table ou non?
	beq.s .fin			; non...
	add.l (a3)+,a2		; premiŠre location
	moveq #0,d0
.loop:
	cmp.l a0,a2			; critŠre de fin
	bpl.s .fin			; on d‚passe de la zone … reloger
	add.l d1,(a2)		; reloge
	bsr refer1			; ajoute la r‚f‚rence (en interne)
.lb1:
	move.b (a3)+,d0
	beq.s .fin			; un z‚ro? c'est fini
	cmp #1,d0
	beq.s .lb0			; 1? il faut avancer de 254...
	add.w d0,a2			; sinon, c'est un offset
	bra.s .loop
.lb0:
	add.w #254,a2
	bra.s .lb1
.fin:
	move d4,-(sp)		; ferme le fichier
	GEMDOS 62,4
	movem.l (sp)+,d0/a2-a3
	rts

; d2=code 1Šre instruction, modifie D2 seulement
; forth.w=code du mot

son_type:
	move.l a0,-(sp)
	move.l relog,a0
	sub.w courant,a0
	add.w dicco,a0				; adresse de l'octet … coder
	cmp #140,d2
	bmi.s .autre
	cmp #146,d2
	bpl.s .encore
	sub #139,d2					; 140 … 145 -> 1 … 6
.range:
	move.b d2,-(a0)
	move.l (sp)+,a0
	rts
.encore:
	cmp #437,d2
	bne.s .lb0
	moveq #7,d2					; mot assembl‚
	bra.s .range
.lb0:
	cmp #628,d2
	bne.s .lb1
	moveq #8,d2					; ‚l‚ment d'ensemble
	bra.s .range
.lb1:
	cmp #706,d2
	bne.s .autre
	moveq #9,d2					; tableau de mots &warray
	bra.s .range
.autre:
	moveq #0,d2					; non assemblable
	bra.s .range


flag_cond:
	bsr mot_commande
	bne .bug1					; mot de commande absent
	and #$f,d7
	beq .bug1
	move.l a2,-(sp)
	lea flags(pc),a2
	cmp #863,d4					; si=863, true sinon false
	seq 0(a2,d7.w)
	move.l (sp)+,a2
	moveq #1,d0
	rts
.bug1: lea cbug12(pc),a0
	moveq #0,d0
	rts

export_source:
	bsr mot_commande
	bne .bug1					; mot de commande absent
	swap d7						; 0 ou -1
.ok:
	tst.b (a0)
	beq .bug2			; chaine mal form‚e
	cmp.b #34,(a0)+		; cherche le " de d‚part
	bne.s .ok
	move.l a0,a1		; d‚but du nom
.lb1:
	tst.b (a0)
	beq .bug2
	cmp.b #34,(a0)+		; cherche le " final
	bne.s .lb1

	tst d7
	beq.s .lb0			; pas d'export, on simule!

	move.l a0,a4		; conserve la fin
	clr.b -(a4)			; vire le " momentan‚ment

	movem.l a0/a2,-(sp)
	move.l a2,a0		; zone libre pour path complet
	sf (a0)
	jsr expand_path

	clr -(sp)
	move.l a0,-(sp)
	GEMDOS 60,8			; fcreate
	move.b #34,(a4)	; remet "
	movem.l (sp)+,a0/a2
	move d0,d6			; handle
	bmi .bug3			; cr‚ation impossible

.lb0:
	move.l #'comp',d0	; critŠre de fin
	bsr une_ligne
	beq .fin
	tst d7 				; simuler ou sauver?
	beq .lb0

	movem.l a0/a2,-(sp)
	move.l a1,-(sp)	; adresse d‚but ligne
	move.l d1,-(sp)	; taille ligne
	move d6,-(sp)
	GEMDOS 64,12		; fwrite
	movem.l (sp)+,a0/a2
	tst d0
	bmi .bug4			; erreur d'‚criture
	bra.s .lb0

.fin:
	cmp #1,a1			; a1=1 si >comp manque!
	beq .bug5			; >comp manquant
	tst d7
	beq.s .lb2			; on simule

	movem.l a0/a2,-(sp)
	move d6,-(sp)
	GEMDOS 62,4
	movem.l (sp)+,a0/a2
.lb2:
	moveq #1,d0			; pas d'erreur!
	rts
.bug1: lea .ex_bug1(pc),a0
	bra.s .fin_bug
.bug2: lea .ex_bug2(pc),a0
	bra.s .fin_bug
.bug3: lea .ex_bug3(pc),a0
	bra.s .fin_bug
.bug4: lea .ex_bug4(pc),a0
	bra.s .fin_bug
.bug5: lea .ex_bug5(pc),a0
.fin_bug:
	sub d0,d0
	rts

	if LANG=0
.ex_bug1: dc.b " Erreur >export: mauvais mot de commande!",0
.ex_bug2: dc.b " Erreur >export: chaine incomplŠte!",0
.ex_bug3: dc.b " Erreur >export: cr‚ation du fichier impossible!",0
.ex_bug4: dc.b " Erreur >export: ‚criture sur fichier impossible!",0
.ex_bug5: dc.b " Erreur >export: >comp manquant!",0
	even
	
	else
.ex_bug1: dc.b " Error >export: bad command word!",0
.ex_bug2: dc.b " Error >export: uncomplete string!",0
.ex_bug3: dc.b " Error >export: can't create file!",0
.ex_bug4: dc.b " Error >export: can't write to file!",0
.ex_bug5: dc.b " Error >export: missing >comp !",0
	even
	endif

	; a1 = chaine … ‚tendre
	; a0 = zone o— ‚tendre
	; entr‚e si (a0) = 0 chaine normale
	; si (a0)=FF chaine avec taille devant
	
expand_path:
	movem.l d1/a0/a2-a4,-(sp)
	move.l a1,a3
	move.l a0,a1
	move.l a0,a4
	move.b (a0),d1
	beq.s .lb0			; chaine normale
	addq.l #1,a1		; saute l'octet taille
.lb0:
	move.b (a3)+,d0	; un caractŠre source
	cmp.b #'%',d0
	bne.s .lb1			; ce n'est pas un %
	cmp.b #'%',(a3)
	bne.s .lb2
	move.b d0,(a1)+	; un double %% = %
	addq.l #1,a3
	bra.s .lb0	
.lb2:
	lea chemin,a0
	bsr.s _copy_path
	move.l a2,a1		; reprendre au dernier "\"
	bra.s .lb0
.lb1:
	move.b d0,(a1)+
	bne.s .lb0			; pas z‚ro final, on continue
	tst.b d1
	beq.s .exit
	move.l a1,d1
	sub.l a4,d1			; taille + z‚ro final + octet taille
	subq.l #2,d1
	move.b d1,(a4)		; stocke la taille
.exit:
	movem.l (sp)+,d1/a0/a2-a4
	rts
	

	; a0 pointe sur le chemin
	; a1 sur la zone destination
	; en sortie a2 pointe juste aprŠs le dernier "\"
_copy_path:
   move.l a1,a2              ; pointe sur le dernier \, ou le d‚but
.lb1: move.b (a0)+,d0        ; caractŠre suivant
   beq.s .lb3                ; fin de chaine, on saute
   cmp.b #"\",d0             ; est ce un \ ?
   bne.s .lb2
   lea 1(a1),a2              ; si oui, on d‚place a2
.lb2: move.b d0,(a1)+        ; remplit dest
   bra.s .lb1
.lb3:
	rts

vider_inclusions:
	tst.l inc_ptr
	beq.s .exit				; chaine vide
	bsr.s depile_inc
	bra.s vider_inclusions
.exit:
   rts
   
depile_inc:
	move.l inc_ptr,d0
	beq.s .fin
	move.l d0,a0
	pea (a0)				; pour mfree
	move.l (a0)+,inc_ptr	; nouveau pointeur
	move (a0),-(sp)		; handle
	GEMDOS 62,4				; fclose
	GEMDOS 73,6				; mfree
.fin:
	rts

	
une_ligne:
	move.l d0,.end_criter	; critŠre de fin de bloc >comp ou >endf
.lb00
	tst.b (a0)+
	bne.s .lb00				; avancer jusqu'… la ligne suivante
	subq.l #1,a0
	tst.l inc_ptr			; sommes nous en inclusion?
	beq.s .no_inc
	move (a0),d1			; taille ligne
	bsr _load_line
	bne.s .erreur			; fichier ferm‚ sans avoir trouv‚ le critŠre de fin
	subq.l #1,a0			; retour sur la tabulation	
	bra.s .commun
.no_inc:
	move.w (a0)+,d1		; taille ligne
	beq .erreur				; fin de source sans >comp/>endf!
.commun:
	moveq #0,d0
	move.b (a0)+,d0		; tabulation+1
	lea commande_buf(pc),a1			; pour construire la ligne
	subq #1,d0
	bra.s .lb1
.lb0:
	move.b #' ',(a1)+
.lb1:
	dbf d0,.lb0				; les espaces au d‚but
	cmp.b #'>',(a0)
	bne.s .normal
	move.l .end_criter(pc),d0
	cmp.l 1(a0),d0
	beq.s .fin
.normal:
	subq #4,d1				; moins taille et tab
.copie:
	move.b (a0)+,(a1)+
	dbf d1,.copie
	cmp.b #32,-1(a1)
	bne.s .lb2
	subq.l #1,a1
.lb2:
	move.b #13,(a1)+
	move.b #10,(a1)+
	move.l a1,d1
	lea commande_buf(pc),a1			; d‚but ligne
	sub.l a1,d1				; taille ligne
	moveq #1,d0				; renvoit NE, ok!
	rts
.fin:
	move #0,a1				; pas d'erreur, mais un >comp ou >endf!, a0 reste dessus.
	bra.s .sortie
.erreur:
	move #1,a1				; grosse erreur
.sortie:
	moveq #0,d0				; renvoit EQ
	rts
.end_criter:
	dc.l 0					; comp ou endf
	
exec_prog:
	bsr mot_commande
	bne .bug1				; pas de mot de commande
	lea commande_buf(pc),a1			; les chaines
.ok:
	tst.b (a0)
	beq .bug2			; chaine mal form‚e
	cmp.b #34,(a0)+		; cherche le " de d‚part
	bne.s .ok
.lb1:
	move.b (a0)+,d0
	beq .bug2				; mal ternim‚e!
	cmp.b #34,d0		; cherche le " final
	beq.s .lb3
	move.b d0,(a1)+
	bra.s .lb1
.lb3:
	clr.b (a1)+
	move.l a1,a4		; conserve la position de la longueur
	addq.l #1,a1		; et se place sur le premier octet!

.lb4:
	tst.b (a0)+
	bne.s .lb4			; fin de cette ligne
	
	tst.l inc_ptr		; en inclusion?
	beq.s .no_inc
	
	subq.l #1,a0		; retour sur le mot de taille
	bsr _load_line
	bne .bug3			; chaine paramŠtres absente dans ce fichier
	bra.s .ok2			; a0 est d‚j… positionnn‚ aprŠs tabulations
	
.no_inc:
	tst.b (a0)+			; taille ligne
	beq .bug3			; chaine absente
	addq.l #1,a0		; saute les tabulations

.ok2:
	tst.b (a0)
	beq .bug2			; chaine mal form‚e
	cmp.b #34,(a0)+		; cherche le " de d‚part
	bne.s .ok2
	move.l a0,d1		; emplacement initial
.lb12:
	move.b (a0)+,d0
	beq .bug2				; mal ternim‚e!
	cmp.b #34,d0		; cherche le " final
	bne.s .lb12
	lea -1(a0),a4		; garde le "
	clr.b (a4)
	
	move.l a1,a0		; l… ou ‚tendre la chaine
	st (a0)				; chaine avec taille initiale
	move.l d1,a1		; chaine … ‚tendre
	jsr expand_path
	move.b #34,(a4)+	; remet la chaine
	exg.l a0,a4			; a0 redevient le pointeur de compilation
							; a4 adresse de la chaine ‚tendue
	
	tst.l d7
	bpl .lb5				; si non n‚gatif, flag invalid‚ on saute!

	movem.l a0/a2,-(sp)

	btst #3,d7
	bne.s .lb9			; ignorer fenˆtre

	tst w_hand
	bmi.s .lb9			; d‚j… ferm‚e

	move.l a1,-(sp)
	lea wg_int(pc),a0
	move.l (a0),d4
	move w_hand(pc),(a0)+
	move #5,(a0)		; espace total
	GEM_AES wind_get0	; taille dans wg_out
	GEM_AES wind_close
	move.l (sp)+,a1
.lb9:
	pea -2(a1)			; environnement nul
	pea (a4)				; commande
	pea commande_buf(pc)	; programme
	clr -(sp)			; mode load and go
	GEMDOS 75,16
	movem.l (sp)+,a0/a2
	move.l d0,d6		; valeur renvoy‚e
	bpl.s .pas_bell
	move.l #$20007,-(sp)
	move #3,-(sp)
	trap #13
	addq.l #6,sp		; son de cloche, erreur PEXEC!
.pas_bell:
	moveq #0,d5			; pas d'arrˆt
	btst #0,d7
	bne.s .lb6			; pas de touche
	movem.l a0/a2,-(sp)
	move.l #$20002,-(sp)
	trap #13
	addq.l #4,sp
	cmp.b #27,d0
	seq d5				; d5=FF si touche escape
	movem.l (sp)+,a0/a2
.lb6:

	btst #3,d7
	bne.s .lb7			; ignorer fenˆtre

	tst w_hand
	bmi.s .lb7			; n'‚tait pas ouverte avant...

	movem.l a0/a2,-(sp)
	move w_hand,wg_out
	move.l d4,wg_int
	GEM_AES wind_open
	jsr cls
	movem.l (sp)+,a0/a2

.lb7:
	tst.l d6
	bmi .bug4			; erreur GEMDOS au chargement

	btst #1,d7
	bne.s .lb8			; pas v‚rifier si renvoi < 0
	tst d6
	bmi .bug5			; valeur renvoy‚e n‚gative!
.lb8:
	btst #2,d7
	bne.s .lb5
	tst d6
	beq.s .lb15
	bpl.s .bug5
.lb15:
	tst.b d5
	bne .bug6			; arrˆt utilisateur!

.lb5:
	moveq #1,d0
	rts					; tout est ok!
.bug1: lea .ex_bug1(pc),a0
	bra.s .fin_bug
.bug2: lea .ex_bug2(pc),a0
	bra.s .fin_bug
.bug3: lea .ex_bug3(pc),a0
	bra.s .fin_bug
.bug4: lea .ex_bug4(pc),a0
	bra.s .fin_bug
.bug5:
	lea .ex_bug5(pc),a0
	bra.s .fin_bug
.bug6:
	lea .ex_bug6(pc),a0
.fin_bug:
	moveq #0,d0
	rts
	if LANG=0
.ex_bug1: dc.b " Erreur >exec: mauvais mot de commande!",0
.ex_bug2: dc.b " Erreur >exec: chaine incomplŠte!",0
.ex_bug3: dc.b " Erreur >exec: chaine commande absente!",0
.ex_bug4: dc.b " Erreur >exec: impossible de lancer le programme!",0
.ex_bug5: dc.b " Erreur >exec: le programme lanc‚ signale une erreur!",0
.ex_bug6: dc.b " Message >exec: compilation interrompue.",0
	even
	else
.ex_bug1: dc.b " Error >exec: bad command word!",0
.ex_bug2: dc.b " Error >exec: uncomplete string!",0
.ex_bug3: dc.b " Error >exec: missing command string!",0
.ex_bug4: dc.b " Error >exec: can't run program!",0
.ex_bug5: dc.b " Error >exec: the child process returns an error!",0
.ex_bug6: dc.b " Message >exec: aborted compilation.",0
	even
	endif
; organisation de la m‚moire dans 'beuf'
;
; |  source.FOR  |  FORTH.LIB (sans relogment) | ... free....| RELOG | free |
;
; la place libre aprŠs RELOG est calcul‚e avec la taille de source.FOR
; divis‚e par 4. On suppose donc que 4 octets de source ne donnent pas lieu
; … plus d'une r‚f‚rence. Tout … fait raisonnable.

charge:
   clr -(sp)
   pea file
   GEMDOS $3d,8
   tst d0
   bmi fin2
   move d0,d6
   move.l prog,-(sp)
   move.l #100000,-(sp)
   move d6,-(sp)
   GEMDOS $3f,12
   move.l d0,d7
   bmi fin2
   move d6,-(sp)
   GEMDOS $3e,4
   tst d0
   bmi fin2
   move.l prog,a5
   tst.l 14(a5)				; symbol table present?
   beq.s .normal
   bsr remove_symbol			; update d7=size
.normal:
   bsr set_language			; remplace quelques chaines selon la langue
   move.l 34(a5),adresse
   move.l 38(a5),ordres
   move.l 42(a5),dlcomp
   move.l 46(a5),indptr
   move.l 50(a5),lstptr
   move.l a5,d0
   add.l #28,d0
   add.l d0,adresse
   add.l d0,ordres
   move.l 2(a5),d6
   add.l 6(a5),d6
   add.l d6,a5
   add.w #28,a5
   move.l a5,inter
   move.l a5,relptr
   subq.l #4,relptr
   move.l d7,d0
   add.l prog,d0
   sub.l a5,d0
   move.l d0,d7
   addq.l #1,d0
   bclr #0,d0
   move.l beuf,a0
   move.l prog,d1
   sub.l a0,d1
   lsr.l #2,d1
   bclr #0,d1
   add.l bfsize,a0
   sub.l d0,a0
   sub.l d1,a0
   move.l a0,relog
   lsr.l #1,d0
   subq.l #1,d0
.lb0: move (a5)+,(a0)+
   dbf d0,.lb0
.pasencore:
   tst.b -(a0)
   beq.s .pasencore
   addq.l #1,a0
   move.l a0,relfin
   move.l ordres(pc),a3
   moveq #0,d0
   moveq #0,d1
.lb1: move.b (a3)+,d1
   beq.s .fin
   add.w d1,a3
   addq #1,d0
   bra.s .lb1
.fin: move d0,forth
   move d0,dicco
   subq.l #1,a3
   move.l a3,sommet
   rts

ajuste: move.l relfin,a0
   clr.b (a0)
   move.l prog,a0
   move.l 2(a0),d0
   add.l 6(a0),d0      ; taille text+data
   move.l interfin,d1
   sub.l inter,d1      ; data en plus
   add.l d1,6(a0)
   add.w #28,a0        ; d‚but zone text
   move.l relog,a1     ; table de relogement
   add.l (a1)+,a0      ; premiŠre adresse
.lb0: cmp.l (a0),d0
   bpl.s .lb1          ; pas dans BSS
   add.l d1,(a0)       ; sinon on d‚cale la r‚f‚rence
.lb1: move.b (a1)+,d2
   beq.s .fin          ; 0 si fin de table
   cmp.b #1,d2         ; 1 si saut de 254
   beq.s .lb2
   bclr #0,d2          ; efface le bit 0
   beq.s .lb3          ; si nul, cas normal
   add.w d2,a0         ; sinon r‚f‚rence interne, pas de d‚calage
   move.b d2,-1(a1)    ; on corrige
   bra.s .lb1
.lb3: add.w d2,a0      ; sinon saut normal < 254
   bra.s .lb0
.lb2: add.w #254,a0    ; saut de 254 sans nouvelle r‚f‚rence
   bra.s .lb1
.fin: rts

recolle: move.l interfin,a0
   move.l relog,a1
   move.l relfin,d0
   sub.l a1,d0
   addq.l #2,d0
   lsr.l d0
   subq.l #1,d0
.lb0: move (a1)+,(a0)+
   dbf d0,.lb0
   move.l a0,terminus
   rts

mul: clr d2
   tst.l (a6)
   bge.s .lb1
   neg.l (a6)
   moveq #1,d2
.lb1: tst.l -(a6)
   bge.s .lb2
   neg.l (a6)
   addq #1,d2
.lb2: move 2(a6),d0
   mulu 6(a6),d0
   move (a6),d1
   mulu 6(a6),d1
   move 4(a6),d3
   mulu 2(a6),d3
   add d3,d1
   move.l d0,(a6)
   add d1,(a6)
   btst #0,d2
   beq.s .lb3
   neg.l (a6)
.lb3: rts

mulw: move.l (a6),d1
   move.l -(a6),d2
   muls d2,d1
   move.l d1,(a6)
   rts

wdiv: move.l (a6),d1
   move.l -(a6),d2
   divs d1,d2
   ext.l d2
   move.l d2,(a6)
   rts

loadb:
   GEM_VDI show_mouse
   GEM_AES file_select_l
   move intout+2(pc),-(sp)
   if DBG=0
	   GEM_VDI hide_mouse
	endif
   bsr cls
   lea mess1(pc),a0
   bsr write_str
   tst (sp)+
   bne.s .lll7
   jmp fin
.lll7: lea source(pc),a0
   clr -(sp)
   move.l a0,-(sp)
   lea chemin(pc),a1
.lb0: move.b (a1)+,(a0)+
   bne.s .lb0
   moveq #'\',d0
.lb1: cmp.b -(a0),d0
   bne.s .lb1
   addq.l #1,a0
   move.l #fichier,a1
.lb11: move.b (a1)+,(a0)+
   bne.s .lb11
   GEMDOS $3d,8
   tst d0
   bmi fin1
.lb2: move d0,d6
   move.l beuf,a5
.boucle: move.l #ldbuf,-(sp)
   move.l #6,-(sp)
   move d6,-(sp)
   GEMDOS 63,12
   cmp #6,d0
   bne .fin
   move.l ldbuf+2,d7
   move.l a5,-(sp)
   move.l d7,-(sp)
   move d6,-(sp)
   GEMDOS 63,12
   cmp.l d0,d7
   bne fin1
   add.l d7,a5
   bra.s .boucle
.fin: clr (a5)+
   move.l a5,prog
   move d6,-(sp)
   GEMDOS 62,4
   tst d0
   bmi fin1
finl: rts

beuf:  dc.l 0

saveb: move.l #fichier,a0
   move.l #fich2,a1
.suite: move.b (a0)+,d0
   beq.s .prg
   cmp.b #'.',d0
   beq.s .prg
   move.b d0,(a1)+
   bra.s .suite
.prg: move.b #'.',(a1)+
   move.b #'P',(a1)+
   move.b #'R',(a1)+
   move.b #'G',(a1)+
   clr.b (a1)
   GEM_VDI show_mouse
   GEM_AES file_select_s
   move intout+2,-(sp)
   if DBG=0
	   GEM_VDI hide_mouse
	endif
   bsr cls
   lea mess6(pc),a0
   bsr write_str
   tst (sp)+
   beq fin
   lea source(pc),a0
   clr -(sp)
   move.l a0,-(sp)
   lea chemin2(pc),a1
.lb0: move.b (a1)+,(a0)+
   bne.s .lb0
   moveq #'\',d0
.lb1: cmp.b -(a0),d0
   bne.s .lb1
   addq.l #1,a0
   move.l #fich2,a1
.lb2: move.b (a1)+,(a0)+
   bne.s .lb2
   GEMDOS $3c,8
   move d0,fhdl
   bmi fin4
   move.l terminus,d7
   move.l prog,d1
   sub.l d1,d7
   move.l d1,-(sp)
   move.l d7,-(sp)
   move fhdl,-(sp)
   GEMDOS $40,12
   move.l d0,d6
   move fhdl,-(sp)
   GEMDOS $3e,4
   tst d0
   bmi fin4
   cmp.l d6,d7
   bne fin4
   rts

	; certaines instructions peuvent ˆtre optimis‚es si une constante les pr‚cŠde
	; (code $4002) par exemple  26 and
	; au lieu move.l #26,-(a6) // move.l (a6)+,d1 // and.l d1,(a6)
	; on fera andi.l #26,(a6)
	; (code $5002) pour + et - si l'argument est de+/-1 … 8 on utilisera en plus:
	; addq/subq.l #n,(a6)
	; (code $6002) pour =,<,>,<> remplace le passage par la pile par D1 directement
	; et utilisation de moveq si -128/+127
	
optimise:
	cmp #$4002,d2			; simple remplacement?
	bne.s .lb0
.normal:
   move -6(a1),-6(a2)	; remplace move.l par le code de l'instruction optimis‚e
.optimisation:
	addq #1,opt_count
   rts
.lb0:
	cmp #$5002,d2			; add/sub ?
	bne.s .lb1
	move.l -4(a2),d2		; la constante
	bsr.s .un_huit			; renvoit EQ si de -1/-8 ou de 1/8
	bne.s .normal			; utlise addi et subi
	cmp #32,d4				; instruction "-"?
	bne.s .lb2
	neg.l d2					; donc ajouter l'oppos‚
.lb2:
	tst.l d2
	bmi.s .sous
	ror.w #7,d2
	or #$5096,d2			; addq
.ascomm:
	subq.l #6,a2
	move d2,(a2)+
	bra.s .optimisation
.sous:
	neg.l d2
	ror.w #7,d2
	or #$5196,d2			; subq
	bra.s .ascomm
.lb1:
	cmp #$6002,d2			; <,>,=,<> ?
	bne.s .lb3
	bsr.s optimise_move
   move -4(a1),d2      ; taille … copier en mots -1
   addq.l #2,a1			; saute le premier mot
   bra.s .cc2				; et donc en copie encore un de moins
.cc1: move (a1)+,(a2)+
.cc2:
   dbf d2,.cc1
	bra.s .optimisation
.lb3:
	rts	
	
.un_huit:
	beq.s .non				; z‚ro est refus‚
	cmp.l #-8,d2
	bmi.s .non				; en dessous de -8?
	cmp.l #9,d2				; au dessus de 8?
	bpl.s .non
	cmp d2,d2				; renvoie EQ si ok
	rts
.non:
	moveq #-1,d2			; renvoie NE si refus‚
	rts

	; optimise les of,<of,>of,<>of si il y a une constante
	
optimise_of:
	tst.b ass_const
	bne.s .opt
	move (a4)+,(a2)+		; pas d'optimisation, instruction move normale
	rts
.opt:
	addq #1,opt_count
	addq.l #2,a4			; saute le move
	; continue sur optimise move
	
	; remplace un move.l #nnn,-(a6)
	; par move.l #nnn,d1
	; ou bien par moveq.l #nnn,d1	si -128/+127
	
optimise_move:
	move.l -4(a2),d2		; valeur
	bpl.s .cc3
	neg.l d2
	cmp.l #128,d2
	beq.s .cc2				; cas particulier
.cc3:
	and.l #$FFFFFF80,d2
	bne.s .cc4				; c'est en dehors de -128/+127
.cc2:
	subq.l #6,a2
	move.b #$72,(a2)+
	move.b 4(a2),(a2)+	; fabrique moveq.l #nn,d1
	bra.s .cc5
.cc4:
	move #$223c,-6(a2)	; remplace move.l #xxx,-(a6) en move.l #xxx,d1
.cc5:
	rts

	; tente d'‚viter ces cas, par exemple:
	; routine qui finit par move.l d1,-(a6)
	; suivie d'une qui commence par move.l (a6)+,d1
optimise_chaine:
	cmp #$2d00,-2(a2)		; d0,-(a6) … la derniŠre?
	bne.s .lb1
	cmp #$221e,(a1)		; et (a6)+,d1 … la suivante?
	bne.s .no_opt
	move #$2200,-2(a2)	; remplace par d0,d1
	bra.s .comm
.lb1:
	cmp #$2d01,-2(a2)		; d1,-(a6) … la derniŠre instruction?
	bne.s .no_opt
	cmp #$221e,(a1)		; (a6)+,d1 sur la suivante?
	bne.s .lb0
	subq.l #2,a2			; vire move.l d1,-(a6)
.comm:
	addq.l #2,a1			; vire move.l (a6)+,d1 ou (a6)+,a2
	subq #1,d2				; un mot de moins … copier
	addq #1,opt_count+2	; statistiques!
	rts
.lb0:
	cmp #$245e,(a1)		; (a6)+,a2 sur la suivante?
	bne.s .no_opt
	move #$2441,-2(a2)	; remplace par move.l d1,a2
	bra.s .comm
.no_opt:
	rts
	
assemblons:
	if STE=0
	   move.l ([adresse],d4.w*4),a4     ;  adresse du mot, en relatif
	else
		move.l adresse(pc),a4
		add d4,a4
		add d4,a4
		add d4,a4
		move.l 0(a4,d4.w),a4
	endif
   lea 28(a4),a1
   add.l prog(pc),a1                   ; adresse du mot, absolue
   tst d4
   bne.s .lb00
   move .emp(pc),(a2)+     ; constante entiŠre
   move.l d5,(a2)+
   st ass_const				; flag pour constante empil‚e
   rts
.lb00: cmp #637,d4       ; constante r‚elle
   bne.s .lb0
   move #$2d3c,(a2)+
   move.l d1,(a2)+
   move #$2d3c,(a2)+
   move.l d0,(a2)+
.sortie: 
   sf ass_const
	rts
.lb0: cmp dicco,d4
   bpl .us             ; si c'est un mot "user"
   move -2(a1),d2      ; code d'assemblage
   cmp.b #2,d2           ; recopie du code
   bne.s .lb2
   cmp #2,d2				; sans optimisation? (code 0002)
   beq.s .no_opt			; c'est ‡a, copier normalement
   tst.b ass_const		; d‚j… une constante
   beq.s .no_opt			; ben non, copier normalement
	bsr optimise			; va optimiser !
   bra.s .sortie
.no_opt:
   move -4(a1),d2      ; taille … copier
   bsr optimise_chaine	; tente d'optimiser l'enchainement (pour ‚viter la pile)
.lb1: move (a1)+,(a2)+
   dbf d2,.lb1
   bra.s .sortie
.lb2: 
	tst d2
   beq .bug1           ; non assemblable
   bmi .fin            ; -1 pour ";"
  	cmp.b #3,d2        ; cr‚ation de "jsr adresse"
   bne.s .lb3
.saut: move .type3(pc),(a2)+
   bsr refere
   move.l a4,(a2)+
   bra .sortie
.lb3: cmp.b #12,d2       ; exit
   bne.s .lb4
   move #$4e75,(a2)+
   bra .sortie
.lb4: cmp.b #17,d2       ; vdi ou aes
   bne.s .lb5
   sub 2(a1),d4           ; soustrait l'offset
   move .type17(pc),(a2)+
   move d4,(a2)+
   addq.l #4,a4          ; saute l'instruction subi
   bra.s .saut
.lb5: cmp.b #6,d2        ; do
   bne.s .lb7
   lea .type6(pc),a4
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move (a4),(a2)+
   bsr refere
   move.l indptr(pc),(a2)+
   addq.l #6,a4
   move.l (a4)+,(a2)+
   move (a4),(a2)+
   move.l a2,(a6)+
   bra .sortie
.lb7: cmp.b #4,d2        ; loop
   bne.s .lb9
   lea .type4(pc),a4
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move (a4),(a2)+
   move.l -(a6),d2
   sub.l a2,d2
   move d2,(a2)+
   addq.l #4,a4
   move.l (a4),(a2)+
   bsr refere
   move.l indptr,(a2)+
   bra .sortie
.lb9: cmp.b #13,d2      ; if
   beq.s .lb9b
   cmp.b #10,d2         ; while
   bne.s .lb10
.lb9b: lea .type13(pc),a4
   move.l (a4)+,(a2)+
   move (a4)+,(a2)+
   move.l a2,(a6)+
   bsr refer1
   addq.l #4,a2
   bra .sortie
.lb10: cmp.b #14,d2     ; else ou endof
   bne.s .lb11
   move .type14(pc),(a2)+
   move.l -(a6),a4
   move.l a2,(a6)+
   bsr refer1
   addq.l #4,a2
.lb10a: move.l a2,d2
   sub.l prog,d2
   sub.l #28,d2
   move.l d2,(a4)
   bra .sortie
.lb11: cmp.b #15,d2     ; then
   bne.s .lb12
   move.l -(a6),a4
   bra.s .lb10a
.lb12: cmp.b #5,d2      ; +loop
   bne.s .lb14
   lea .type5(pc),a4
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move (a4),(a2)+
   move.l -(a6),d2
   sub.l a2,d2
   move d2,(a2)+
   addq.l #4,a4
   move.l (a4),(a2)+
   bsr refere
   move.l indptr(pc),(a2)+
   addq.l #8,a4
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move.l (a6),d2
   sub.l a2,d2
   move d2,(a2)+
   move 2(a4),(a2)+
   bra .sortie
.lb14: cmp.b #16,d2     ; ifloop
   bne.s .lb16
   lea .type16(pc),a4
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move (a4),(a2)+
   move.l -(a6),d2
   sub.l a2,d2
   move d2,(a2)+
   addq.l #4,a4
   move.l (a4)+,(a2)+
   move (a4),(a2)+
   bsr refere
   move.l indptr(pc),(a2)+
   bra .sortie
.lb16: cmp.b #7,d2      ; begin
   bne.s .lb17
   move.l a2,(a6)+
   bra .sortie
.lb17: cmp.b #8,d2      ; again
   bne.s .lb18
   move .type14(pc),(a2)+
.lb17a: bsr refer1
   move.l -(a6),d2
   sub.l prog,d2
   sub.l #28,d2
   move.l d2,(a2)+
   bra .sortie
.lb18: cmp.b #9,d2      ; until
   bne.s .lb19
   lea .type13(pc),a4
   move.l (a4)+,(a2)+
   move (a4)+,(a2)+
   bra.s .lb17a
.lb19: cmp.b #11,d2     ; repeat
   bne.s .lb21
   move .type14(pc),(a2)+
   move.l -(a6),a4
   bsr.s .lb17a
   bra .lb10a
.lb21: cmp.b #1,d2       ; un gemdos
   bne.s .lb23
   lea gblk-1476(pc),a4
   move #$4e41,d2
.lb22:
	if STE=0
		lea (a4,d4.w*4),a4
	else
		add d4,a4
		add d4,a4
		add d4,a4
		add d4,a4
	endif
   lea .tos(pc),a5
   move (a5)+,(a2)+
   move.b (a4)+,d0
   move.b (a4)+,d1
   bmi.s .tos1
   ext.w d1
.tos0: btst d1,d0
   bne.s .tos2
   move.l 2(a5),(a2)+
   bra.s .tos3
.tos2: move (a5),(a2)+
.tos3: dbf d1,.tos0
.tos1: addq.l #6,a5
   move (a5)+,(a2)+
   move.b (a4)+,d0
   ext.w d0
   move d0,(a2)+
   move d2,(a2)+
   addq.l #2,a5
   move (a5)+,(a2)+
   tst.b (a4)
   beq.s .tos4
   move (a5),(a2)+
.tos4: bra .sortie
.lb23: cmp.b #21,d2      ; un bios
   bne.s .lb24
   lea bblk-1588(pc),a4
   move #$4e4d,d2
   bra .lb22
.lb24: cmp.b #22,d2      ; un xbios
   bne.s .lb25
   lea xblk-1632(pc),a4
   move #$4e4e,d2
   bra .lb22
.lb25: cmp.b #19,d2      ; ."
   bne.s .lb26
;	lea .type19(pc),a5
;   move.l (a5)+,(a2)+
;   move.l (a5)+,(a2)+
;	move.l (a5)+,(a2)+
;	move (a5),(a2)+
;   addq.l #2,a2         ; saute l'offset
;   bsr .ch
;   addq #2,d2
;   move d2,-(a5)
;	bra .sortie
	lea .type19(pc),a5
	move.l (a5)+,(a2)+
	move.l (a5)+,(a2)+
	bsr .ch
	addq #2,d2
	move d2,-(a5)
	move.l -6(a1),a4
	bra .saut
.lb26: cmp.b #20,d2      ; "
   bne.s .lb27
	lea .type20(pc),a5
	move.l (a5)+,(a2)+
	move.l (a5),(a2)+
   addq.l #4,a2
   bsr .ch
   move d2,-(a5)
   addq #4,d2
   move d2,-(a5)
	bra .sortie
.lb27: cmp.b #23,d2      ; case
   bne.s .lb28
   clr.l (a6)+
   bra .sortie
.lb28: cmp.b #25,d2      ; of
   bne.s .lb281
   lea .type25(pc),a4
.lb280: bsr optimise_of 
	move (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move.l a2,(a6)+
   bsr refer1
   move.l (a4)+,(a2)+
   move (a4),(a2)+
   bra .sortie
.lb281: cmp.b #33,d2      ; <>of
   bne.s .lb282
   lea .type33(pc),a4
   bra.s .lb280
.lb282: cmp.b #34,d2      ; >of
   bne.s .lb283
   lea .type34(pc),a4
   bra.s .lb280
.lb283: cmp.b #35,d2      ; <of
   bne.s .lb29
   lea .type35(pc),a4
   bra.s .lb280
.lb29: cmp.b #24,d2      ; endcase
   bne.s .lb31
   move.l a2,d4
   sub.l prog(pc),d4
   sub.l #28,d4
.lb30: move.l -(a6),d2
   beq .sortie
   move.l d2,a4
   move.l d4,(a4)
   bra.s .lb30
.lb31: cmp.b #26,d2      ; ndo
   bne.s .lb32
   lea .type26(pc),a4
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move (a4),(a2)+
   move.l a2,(a6)+
   bra .sortie
.lb32: cmp.b #27,d2      ; nloop
   bne.s .lb33
   lea .type27(pc),a4
   move.l (a4),(a2)+
   move.l -(a6),d2
   sub.l a2,d2
   move d2,(a2)+
   addq.l #6,a4
   move.l (a4)+,(a2)+
   move (a4)+,(a2)+
   subq #8,d2
   move d2,(a2)+
   move 2(a4),(a2)+
   bra .sortie
.lb33: cmp.b #28,d2      ; fast ou slow
   beq .sortie
   cmp.b #29,d2      ; exe+
   bne.s .lb34
   move #$0696,(a2)+
   clr (a2)+
   move courant(pc),(a2)+
   bra.s .exec
.lb34: cmp.b #30,d2      ; exec
   bne.s .lb35
.exec: lea .type30(pc),a4
   move.l (a4)+,(a2)+
   move (a4),(a2)+
   move dicco(pc),(a2)+
   addq.l #4,a4
   move.l (a4)+,(a2)+
   move.l (a4),(a2)+
   bsr refere
   move.l adresse(pc),d2
   sub.l prog(pc),d2
   sub.l #28,d2
   move.l d2,(a2)+
   addq.l #8,a4
   move.l (a4)+,(a2)+
   move.l (a4),(a2)+
   bra .sortie
.lb35: cmp.b #32,d2      ; dolist
   bne.s .lb36
   move #$4eb9,(a2)+
   bsr refere
   move.l dlcomp(pc),(a2)+
   move.l a2,(a6)+
   bra .sortie
.lb36: cmp.b #31,d2      ; lloop
   bne .bug
   lea .type31(pc),a4
   move (a4),(a2)+
   bsr refere
   move.l indptr(pc),(a2)+
   addq.l #6,a4
   move.l (a4)+,(a2)+
   move (a4)+,(a2)+
   move.l -(a6),d2
   sub.l a2,d2
   move d2,(a2)+
   addq.l #2,a4
   move.l (a4),(a2)+
   bsr refere
   move.l lstptr,(a2)+
   move 8(a4),(a2)+
   bsr refere
   move.l indptr,(a2)+
   bra .sortie
.fin: move #$4e75,(a2)+
   clr start
   move.l a2,d0
   move.l offset,a4
   sub.l a4,d0
   subq.l #4,d0
   move.l d0,(a4)
   clr ass
   clr in_def
   bra .sortie
.us:
	move.l adresse(pc),a3
	move.l relog(pc),a4 ; c'est un mot user
   sub.w d4,a4
   add.w dicco(pc),a4
   asl #2,d4
   add.l d4,a3        ; adresse de la future adresse...
   move.b -(a4),d2     ; type de mot
	cmp #3,d2        ; array
   bne.s .u3
   lea .t142(pc),a4
   bsr optimise_of
   move (a4)+,(a2)+
   move.l (a4)+,(a2)+
   bsr .adradr
   move (a4),(a2)+
   rts
.u3: 
	cmp #5,d2        ; array$
   bne.s .u6
   lea .t144(pc),a4
   bsr optimise_of
   move (a4)+,(a2)+
   bsr .adradr
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move (a4),(a2)+
   rts
.u6: cmp #6,d2        ; table
   bne.s .u7
   lea .t145(pc),a4
   bsr optimise_of
   move (a4)+,(a2)+
   move.l (a4)+,(a2)+
   bsr .adradr
   move.l (a4),(a2)+
   rts
.u7:
	cmp #9,d2        ; [war]
   bne.s .u8
   lea .t706(pc),a4
   bsr optimise_of
   move.l (a4)+,(a2)+
   bsr .adradr
   move (a4),(a2)+
   rts
.u8: 
	sf ass_const	    ; a partir d'ici, le flag est devenu inutile
   cmp #7,d2          ; "&assembler" ou ":: ;" ou " ::does> ;end "
   bne.s .u1
   lea .t437(pc),a4
   move (a4)+,(a2)+
   bsr .adradr
   move.l (a4),(a2)+
   rts
.u1: cmp #1,d2        ; variable
   bne.s .u2
   lea .t140(pc),a4
   move (a4)+,(a2)+
   bsr .adradr
   move (a4),(a2)+
   rts
.u2: cmp #2,d2        ; constant
   bne.s .u4
   lea .t141(pc),a4
   move (a4)+,(a2)+
   bsr .adradr
   move.l (a4),(a2)+
   rts
.u4: cmp #4,d2        ; string
   bne.s .u5
   lea .t143(pc),a4
   move (a4)+,(a2)+
   bsr .adradr
   move.l (a4),(a2)+
   rts
.u5: 
	cmp #8,d2        ; [&]
   bne.s .bug2
   asr #2,d4
   ext.l d4
   move .emp(pc),(a2)+
   move.l d4,(a2)+
   rts
.bug2: asr #2,d4
.bug1: move.l ordres(pc),a0
   move.l #mot,a1
   move.b #' ',(a1)+
.blb1: subq #1,d4
   bmi.s .blb2
   move.b (a0)+,d2
   ext.w d2
   add.w d2,a0
   bra.s .blb1
.blb2: move.b (a0)+,d1
   ext.w d1
   subq #1,d1
.blb3: move.b (a0)+,(a1)+
   dbf d1,.blb3
   clr.b (a1)
   bsr cr
   lea mot(pc),a0
   bsr write_str
.bug: lea bugass(pc),a0
   bsr write_str
   move #1,erreur
   rts
.ch: move.l a2,a5
.ch3: move.b (a0)+,d2
   beq.s .ch2
   cmp.b #34,d2
   beq.s .ch1
   move.b d2,(a2)+
   bra.s .ch3
.ch1: clr.b (a2)+
   move.l a2,d2
   addq.l #1,d2
   bclr #0,d2
   move.l d2,a2    ; sur une adresse paire
   sub.l a5,d2     ; taille de la chaine
   rts
.ch2: move #1,erreur
   bsr cr
   lea cbug2(pc),a0
   bsr write_str
   rts
.emp: move.l #2,-(a6)
.type3:  dc.w $4eb9
.type17: move #100,d1
.type6: subq.l #8,a4
   move.l (a6)+,(a4)
   move.l (a6)+,4(a4)
   move.l #indptr,a1
   addq.l #4,(a1)
   move.l (a1),a2
   move.l a4,(a2)
.type4: addq.l #1,(a4)
   move.l (a4),d1
   cmp.l 4(a4),d1
   bmi .type13
   addq.l #8,a4
   subq.l #4,indptr
.type13: tst.l (a6)+
   bne.s .type5
.type14:  dc.w $4ef9,0,0
.type5: move.l (a6)+,d1
   ble.s .ttt5
   add.l d1,(a4)
   move.l (a4),d1
   cmp.l 4(a4),d1
   bmi .type16
.tt5: addq.l #8,a4
   subq.l #4,indptr
   bra.s .type16
.ttt5: add.l d1,(a4)
   move.l (a4),d1
   cmp.l 4(a4),d1
   bpl .type16
   bra.s .tt5
.type16: tst.l (a6)+
   beq.s .t16
   addq.l #1,(a4)
   move.l (a4),d1
   cmp.l 4(a4),d1
   bmi .tos
.t16: move.l (a4),-(a6)
   addq.l #8,a4
   subq.l #4,indptr.l
.tos: move.l a7,d7
   move.l (a6)+,-(a7)
   move.l (a6)+,d0
   move d0,-(a7)
   move #1212,-(a7)
   move.l d7,a7
   move.l d0,-(a6)
;.type19: pea .type20(pc)
;   move #9,-(a7)
;   trap #1
;   addq.l #6,a7
;   bra .type19
.type19: lea .type20(pc),a0
	bra .type25
.type20: lea .type25+2(pc),a0
   move.l a0,-(a6)
   bra .type20
.type25: move.l (a6)+,d1
   cmp.l (a6),d1
   beq.s .t25
    dc.w $4ef9,0,0
.t25: addq.l #4,a6
.type33: move.l (a6)+,d1
   cmp.l (a6),d1
   bne.s .t33
    dc.w $4ef9,0,0
.t33: addq.l #4,a6
.type34: move.l (a6)+,d1
   cmp.l (a6),d1
   bmi.s .t34
    dc.w $4ef9,0,0
.t34: addq.l #4,a6
.type35: move.l (a6)+,d1
   cmp.l (a6),d1
   bgt.s .t35
    dc.w $4ef9,0,0
.t35: addq.l #4,a6
.type26: clr.l -(a4)
   move.l (a6)+,d0
   subq.l #1,d0
   swap d0
   move.l d0,-(a4)
.type27: subq #1,(a4)
   bcc .type30
   subq #1,2(a4)
   bcc .type30
   addq.l #8,a4
.type30: moveq #2,d0
   move.l (a6)+,d1
   cmp #733,d1
   bpl.s .t30
   moveq #0,d0
.t30: asl #2,d1
   move.l #adresse,a1
   move.l  0(a1,d1.w),a1
   add.w d0,a1
   jsr (a1)
.t140: move.l 1212.l,-(a6)
   addq.l #2,(a6)
.t141: move.l 1212.l,a0
   move.l 2(a0),-(a6)
.t142: move.l (a6)+,d1
   asl.l #2,d1
   addq.l #2,d1
   add.l 1212.l,d1
   move.l d1,-(a6)
.t143: move.l 1212.l,a0
   addq.l #4,a0
   move.l a0,-(a6)
.t144: move.l (a6)+,d1
   move.l 1212.l,a0
   move 2(a0),d0
   addq.l #4,d0
   bclr #0,d0
   muls d1,d0
   addq #4,d0
   add.w d0,a0
   move.l a0,-(a6)
.t145: move.l (a6)+,d1
   asl.l #2,d1
   addq.l #2,d1
   add.l 1212.l,d1
   move.l d1,a0
   move.l (a0),-(a6)
.t437: move.l 1212.l,a0
   addq.l #2,a0
   jsr (a0)
.t706: move.l (a6)+,d1
   add.l d1,d1
   add.l 1212.l,d1
   move.l d1,-(a6)
.type31: move.l indptr,a1
   addq.l #4,(a1)
   subq.l #1,(a4)
   bne .typee1
   addq.l #8,a4
   subq.l #4,lstptr
   subq.l #4,indptr
.typee1: rts
.adradr: bsr refere
   addq.l #4,a4
   sub.l prog,a3
   sub.w #28,a3
   move.l a3,(a2)+
   rts

; ajoute une r‚f‚rence … la table de relogement
; entr‚e: a2 l'adresse de la r‚f‚rence
; aucun r‚gistre modifi‚

refere: move.l d0,-(sp)
   move.l a0,-(sp)
   move.l a2,d0
   sub.l relptr,d0
   move.l a2,relptr
   move.l relfin,a0
.lb0: cmp.l #255,d0
   bmi.s .lb1
   sub.l #254,d0
   move.b #1,(a0)+
   bra.s .lb0
.lb1: move.b d0,(a0)+
   move.l a0,relfin
   move.l (sp)+,a0
   move.l (sp)+,d0
   rts

refer1: move.l d0,-(sp)
   move.l a0,-(sp)
   move.l a2,d0
   sub.l relptr,d0
   move.l a2,relptr
   move.l relfin,a0
.lb0: cmp.l #255,d0
   bmi.s .lb1
   sub.l #254,d0
   move.b #1,(a0)+
   bra.s .lb0
.lb1: addq.b #1,d0
   move.b d0,(a0)+
   move.l a0,relfin
   move.l (sp)+,a0
   move.l (sp)+,d0
   rts

subval: sub a1,a1
   move #1,a3
   cmp.b #'-',(a0)
   bne.s .lb0
   move #1,a1
   addq.l #1,a0
   bra.s .lb1
.lb0: cmp.b #'+',(a0)
   bne.s .lb1
   addq.l #1,a0
.lb1: moveq #0,d0
   moveq #0,d1
.lb2: move.b (a0),d7
   beq .fin
   cmp.b #".",d7
   beq.s .virg
   cmp.b #',',d7
   bne.s .lb20
.virg: sub a3,a3
   addq.l #1,a0
   bra.s .lb2
.lb20: cmp.b #"e",d7
   beq.s .exp
   cmp.b #'E',d7
   beq.s .exp
   cmp.w #1,a3
   beq.s .lb21
   subq #1,a3
.lb21: tst.l d0
   beq.s .lb3
   add.l #$100000,d0
   move.l d0,d2
   move.l d1,d3
   add.l #$200000,d2
   bsr subplus
.lb3: moveq #0,d7
   move.b (a0)+,d7
   sub.b #'0',d7
   beq.s .lb2
   cmp.b #10,d7
   bmi.s .lb31
   move #1,erreur
   rts
.lb31: lea chdata(pc),a2
   add d7,d7
   move -2(a2,d7.w),d2
   swap d2
   clr d2
   moveq #0,d3
   bsr subplus
   bra.s .lb2
.exp: addq.l #1,a0
   cmp #1,a1
   bne.s .lb4
   moveq #31,d7
   bset d7,d0
.lb4: sub a1,a1
   moveq #0,d4
   cmp.b #'-',(a0)
   bne.s .lb5
   move #1,a1
   addq.l #1,a0
   bra.s .lb6
.lb5: cmp.b #'+',(a0)
   bne.s .lb6
   addq.l #1,a0
.lb6: move.b (a0)+,d7
   beq.s .lb7
   ext.w d7
   sub.w #'0',d7
   muls #10,d4
   add d7,d4
   bra.s .lb6
.fin: moveq #0,d4
   cmp #1,a1
   bne.s .lb71
   moveq #31,d7
   bset d7,d0
.lb7: cmp #1,a1
   bne.s .lb71
   neg d4
.lb71: cmp #1,a3
   beq.s .lb8
   add a3,d4
.lb8: lea posdata(pc),a2
   tst d4
   bpl.s .lb81
   neg d4
   lea negdata(pc),a2
.lb81: move d4,a3
.lb9: move a3,d4
   beq.s .sortie
   lsr d4
   bcc.s .lb10
   move d4,a3
   move.l (a2)+,d2
   move.l (a2)+,d3
   bsr submul
   bra.s .lb9
.lb10: addq.l #8,a2
   move d4,a3
   bra.s .lb9
.sortie: rts

subplus: moveq #31,d7         ; pour acc‚der au bit de signe
   moveq #20,d6               ; pour acc‚der au bit implicite
   bclr d7,d0
   bne .n1                    ; si le premier est n‚gatif
   bclr #31,d2
   bne .p1n2                  ; 2 n‚gatif et 1 positif
.p1p2:  move.l d0,d4          ; ici les deux sont positifs
   lsr.l d6,d4                ; exposant de 1
   move.l d2,d5
   lsr.l d6,d5                ; exposant de 2
   sub.w d5,d4                ; nbr de d‚calages
   bpl.s .lb0                 ; 1 > 2
   exg.l d0,d2                ; sinon on ‚change
   exg.l d1,d3
   neg d4
.lb0: move.l d0,d5            ; conserve l'exposant du plus grand
   cmp #53,d4
   bpl .endpos                ; trop de d‚calages
   and.l #$fffff,d0           ; on ote les exposants
   and.l #$fffff,d2
   bset d6,d0                 ; on ajoute le bit implicite
   bset d6,d2
   cmp #32,d4
   bpl.s .lb1
   move.l d2,d6               ; moins de 32 d‚calages
   lsr.l d4,d2
   lsr.l d4,d3
   sub #32,d4
   neg d4
   lsl.l d4,d6
   or.l d6,d3
   bra.s .lb2
.lb1: move.l d2,d3            ; plus de 32 d‚calages, d3 inutile
   moveq #0,d2
   sub #32,d4
   lsr.l d4,d3
.lb2: add.l d3,d1             ; addition
   addx.l d2,d0
   moveq #21,d6
   btst d6,d0                 ; une retenue?
   beq.s .lb4
   add.l #$100000,d5          ; si oui on augmente l'exposant
   lsr.l d0                   ; et on d‚cale … droite
   roxr.l d1
.lb4: moveq #20,d6            ; sinon on enlŠve le bit implicite
   bclr d6,d0
   and.l #$fff00000,d5        ; on garde l'exposant seul
   or.l d5,d0                 ; qu'on ajoute … la mantisse
.endpos: rts
.n1: bclr d7,d2
   beq.s .n1p2
   bsr .p1p2                  ; meme chose si deux n‚gatifs
   bset d7,d0                 ; mais signe -
   rts
.n1p2: bset d7,d7
.p1n2: move.l d0,d4           ; l'un positif l'autre n‚gatif
   lsr.l d6,d4                ; exposant de 1
   move.l d2,d5
   lsr.l d6,d5                ; exposant de 2
   sub.w d5,d4                ; nbr de d‚calages
   bpl.s .lb5                 ; 1 > 2
   exg.l d0,d2                ; sinon on ‚change
   exg.l d1,d3
   neg d4
   bchg d7,d7
.lb5: move.l d0,d5            ; conserve l'exposant du plus grand
   cmp #53,d4
   bpl .lb12                  ; trop de d‚calages
   and.l #$fffff,d0
   and.l #$fffff,d2
   bset d6,d0
   bset d6,d2
   cmp #32,d4
   bpl.s .lb6
   move.l d2,d6
   lsr.l d4,d2
   lsr.l d4,d3
   sub #32,d4
   neg d4
   lsl.l d4,d6
   or.l d6,d3
   bra.s .lb7
.lb6: move.l d2,d3
   moveq #0,d2
   sub #32,d4
   lsr.l d4,d3
.lb7: sub.l d3,d1
   subx.l d2,d0
   bne.s .lb8
   tst.l d1
   bne.s .lb8
   rts                               ; c'est z‚ro !
.lb8: bpl.s .lb9
   neg.l d1                          ; si c'est n‚gatif, le plus grand n'‚tait
   negx.l d0                         ; pas d0/d1, on oppose
   bchg d7,d7                        ; modifie le signe du r‚sultat
.lb9: moveq #20,d6
   lsr.l d6,d5                       ; ramŠne l'exposant au bit0
   bra.s .lb11
.lb10: lsl.l d1                      ; d‚calage … gauche
   roxl.l d0
   subq.w #1,d5                      ; ajuste l'exposant
.lb11: btst d6,d0                    ; tant que le bit20 n'est pas mis
   beq.s .lb10                       ; on remonte d‚caler … gauche
   bclr d6,d0                        ; sinon on ote le bit implicite
   lsl.l d6,d5                       ; on recale l'exposant au bit20
   or.l d5,d0                        ; qu'on ajoute … d0
.lb12: tst.l d7
   bpl.s .lb13
   bset d7,d0                        ; r‚sultat n‚gatif si bit31 de d7 = 1
.lb13: rts

submul: move.l d0,d4
   swap d4
   move d4,d7
   and.l #$7ff0,d4
   beq .zero
   move.l d2,d5
   swap d5
   move d5,d6
   and #$7ff0,d5
   beq .zero
   add d5,d4
   sub #$3ff0,d4
   swap d4
   eor d6,d7
   bpl.s .lb0
   moveq #31,d6
   bset d6,d4
.lb0: and.l #$fffff,d0
   and.l #$fffff,d2
   moveq #20,d6
   bset d6,d0
   bset d6,d2
.lb1: moveq #0,d6
   move d3,d7
   mulu d1,d7
   clr d7
   swap d7
   swap d3
   move d3,d5
   mulu d1,d5
   add.l d5,d7
   bcc.s .x1
   moveq #1,d6
.x1: swap d1
   swap d3
   move d3,d5
   mulu d1,d5
   add.l d5,d7
   bcc.s .x2
   addq #1,d6
.x2: move d6,d7
   swap d7
   moveq #0,d6
   move d0,d5
   mulu d3,d5
   add.l d5,d7
   bcc.s .x3
   moveq #1,d6
.x3: swap d3
   move d1,d5
   mulu d3,d5
   add.l d5,d7
   bcc.s .x4
   addq #1,d6
.x4: swap d1
   move d1,d5
   mulu d2,d5
   add.l d5,d7
   bcc.s .x5
   addq #1,d6
.x5: move d6,d7
   swap d7
   moveq #0,d6
   move d3,d5
   mulu d0,d5
   add.l d5,d7
   bcc.s .x6
   moveq #1,d6
.x6: swap d2
   move d1,d5
   mulu d2,d5
   add.l d5,d7
   bcc.s .x7
   addq #1,d6
.x7: swap d1
   swap d2
   move d1,d5
   mulu d2,d5
   add.l d5,d7
   bcc.s .x8
   addq #1,d6
.x8: swap d3
   swap d0
   move d0,d5
   mulu d3,d5
   add.l d5,d7
   bcc.s .x9
   addq #1,d6
.x9: swap d6
   swap d3
   mulu d0,d3
   move d2,d5
   swap d0
   mulu d0,d5
   add.l d5,d3
   bcc.s .x10
   addq #1,d6
.x10: swap d2
   mulu d2,d1
   add.l d1,d3
   bcc.s .x11
   addq #1,d6
.x11: swap d6
   swap d3
   moveq #0,d1
   move d3,d1
   clr d3
   add.l d3,d7
   addx.l d1,d6
   move d0,d5
   mulu d2,d5
   add.l d5,d6
   swap d0
   move d0,d5
   mulu d2,d5
   swap d5
   clr d5
   add.l d5,d6
   swap d2
   mulu d2,d0
   add.l d0,d6
   moveq #25,d1
   btst d1,d6
   bne.s .cinq
   moveq #24,d1
   bne.s .katr
.zero: moveq #0,d0
   moveq #0,d1
   rts
.cinq: moveq #5,d2
   moveq #27,d3
   add.l #$00100000,d4
   bra.s .suite
.katr: moveq #4,d2
   moveq #28,d3
.suite: move d6,d1
   lsl.l d3,d1
   lsr.l d2,d7
   lsr.l d2,d6
   or.l d7,d1
   moveq #20,d2
   bclr d2,d6
   move.l d6,d0
   or.l d4,d0
   rts

cls:
	movem.l a0-a1/d0-d1,-(sp)
   lea copy_pts(pc),a0
  	move.l fenetre(pc),a1
  	clr.l 8(a1)				; curseur en haut … droite
   move.l (a1)+,d0
   move.l d0,(a0)+     ; x et y
   add.l (a1),d0
   sub.l #$10001,d0     ; x' et y' ( ‚gaux … x,y + l,h -1,1 )
   move.l d0,(a0)
   GEM_VDI fill_rect
   movem.l (sp)+,a0-a1/d0-d1
   rts


;cls: movem.l a0-a1/d0-d1,-(sp)
;	if STE=0
;	   clr.l ([fenetre],8) ; curseur en haut … droite
;	else
;		move.l fenetre(pc),a0
;		clr.l 8(a0)
;	endif
;   clr copy_int        ; mode, vider la zone
;   lea copy_pts,a0
;   move.l fenetre(pc),a1  ; coordonn‚es de travail de la fenˆtre
;   move.l (a1)+,d0
;   move.l d0,(a0)+     ; x et y
;   move.l d0,d1
;   add.l (a1),d1
;   sub.l #$10001,d1     ; x' et y' ( ‚gaux … x,y + l,h -1,1 )
;   move.l d1,(a0)+
;   move.l d0,(a0)+
;   move.l d1,(a0)
;   clr.l mf1           ; source et dest = ‚cran.
;   clr.l mf2
;   GEM_VDI copy_tab
;   movem.l (sp)+,a0-a1/d0-d1
;   rts

cr:
   movem.l d0-d1/d5-d7/a0-a1,-(sp)
   move.l fenetre(pc),a1
   lea 8(a1),a0
   clr (a0)+          ; x=0, 1ø colonne
   move (a0),d0      ; y
   add 4(a0),d0      ; plus une colonne
   move 6(a1),d1     ; H
   sub 4(a0),d1      ; moins la hauteur de la ligne
   cmp d0,d1
   bmi.s .lb0        ; il faut scroller
   move d0,(a0)      ; sinon, colonne valable
   bra .fin
.lb0:
	move 4(a0),d7     ; hauteur d'un caractŠre
	ext.l d7
	move (a0),d6      ; y du curseur
	ext.l d6
	lea copy_pts(pc),a0
	move.l (a1)+,d5
	move.l d5,(a0)
	add.l d7,(a0)+
	sub.l #$10001,d5  ; pour l'angle oppos‚
	move.l (a1),(a0)
	add.l d5,(a0)+
	move.l -(a1),(a0)+
	move.l -8(a0),(a0)
	sub.l d7,(a0)
	move #3,copy_int
	clr.l mf1
	clr.l mf2
	GEM_VDI copy_tab
	lea copy_pts(pc),a0
	move.l fenetre(pc),a1
	add.l (a1)+,d6
	move.l d6,(a0)+
	add.l (a1),d5
	move.l d5,(a0)+
	move.l d6,(a0)+
	move.l d5,(a0)
	clr copy_int
	clr.l mf1
	clr.l mf2
	GEM_VDI copy_tab
.fin:
	movem.l (sp)+,d0-d1/d5-d7/a0-a1
   rts

fill_rect: dc.l fr_cont,dum,copy_pts,dum,dum
fr_cont: dc.w 114,2,0,0,0,0,0,0,0,0,0,0

appl_init: dc.l ai_cont,global,dum,appl_id,dum,dum
ai_cont: dc.w 10,0,1,0,0
appl_id: dc.w 0

file_select_l: dc.l fs_cont,global,dum,intout,fsl_addr,dum
fs_cont: dc.w 90,0,2,2,0
fsl_addr: dc.l chemin,fichier

file_select_s: dc.l fs_cont,global,dum,intout,fss_addr,dum
fss_addr: dc.l chemin2,fich2

appl_exit: dc.l ae_cont,global,dum,intout,dum,dum
ae_cont: dc.w 19,0,1,0,0

graf_hand: dc.l gh_cont,global,dum,intout,dum,dum
gh_cont: dc.w 77,0,5,0,0

mouse_form: dc.l mf_cont,global,mf_int,intout,dum,dum
mf_cont: dc.w 78,1,1,1,0
mf_int: dc.w 0

hide_mouse: dc.l hm_cont,dum,dum,dum,dum
hm_cont: dc.w 123,0,0,0,0,0,0,0,0,0,0,0

show_mouse: dc.l sm_cont,sm_int,dum,dum,dum
sm_cont: dc.w 122,0,0,1,0,0,0,0,0,0,0,0
sm_int: dc.w 1

open_work: dc.l ow_cont,ow_int,dum,intout,ptsout
ow_cont: dc.w 100,0,0,11,0,0,0,0,0,0,0,0
ow_int: dc.w 2,1,1,1,1,1,1,0,1,0,2

close_work: dc.l cw_cont,dum,dum,dum,dum
cw_cont: dc.w 101,0,0,0,0,0,0,0,0,0,0,0

menu_reg: dc.l mr_cont,global,appl_id,dum,menu_nom,dum
mr_cont: dc.w 35,1,1,1,0
menu_nom: dc.l _menu_nom

wind_get0: dc.l wg_cont,global,wg_int,wg_out,dum,dum
wg_cont: dc.w 104,2,5,0,0
wg_int: dc.w 0,4
wg_out: dc.w 0,0,0,0,0

wind_get1: dc.l wg_cont,global,wg_int,w_travail,dum,dum
w_travail: dc.w 0,0,0,0,0

wind_create: dc.l wc_cont,global,wg_out,w_hand,dum,dum
wc_cont: dc.w 100,5,1,0,0
w_hand: dc.w -1            ; n‚gatif tant qu'aucune n'est ouverte...

wind_open: dc.l wo_cont,global,wg_out,dum,dum,dum
wo_cont: dc.w 101,5,1,0,0

wind_close: dc.l wl_cont,global,w_hand,dum,dum,dum
wl_cont: dc.w 102,1,1,0,0

wind_del: dc.l wd_cont,global,w_hand,dum,dum,dum
wd_cont: dc.w 103,1,1,0,0

wind_set_title: dc.l wst_cont,global,wst_in,dum,dum,dum
wst_cont: dc.w 105,6,1,0,0
wst_in: dc.l 2,w_titre,0

copy_tab: dc.l copy_cont,copy_int,copy_pts,dum,dum
copy_cont: dc.w 109,4,0,1,0,0,0
           dc.l mf1,mf2
copy_int: dc.w 3

event_key: dc.l ek_cont,global,dum,intout,dum,dum
ek_cont: dc.w 20,0,1,0,0

text_align: dc.l ta_cont,ta_int,dum,intout,dum
ta_cont: dc.w 39,0,0,2,0,0,0,0,0,0,0,0
ta_int: dc.w 0,5

vdi_text: dc.l vt_cont,vt_int,vt_pts,dum,dum
vt_cont: dc.w 8,1,0,256,0,0,0,0,0,0,0,0
vt_pts: dc.w 0,0

fenetre: dc.l fenetre0

; X,Y,L,H puis x,y ( curseur ) l,h ( caractŠre )

fenetre0: dc.w 0,0,0,0,0,0,0,0

_menu_nom: dc.b "  FORTH COMP 4.00",0,0
o_titre: dc.b "Optim #imm:00000 1>2:00000",0,0
	if LANG=0
w_titre: dc.b "Mon Bon Compilateur V"
	else
w_titre: dc.b "My Good Compiler V"
	endif
	version
	dc.b 0,0
   even

	; enlŠve la table des symboles de FORTH.LIB
	
remove_symbol:
	bsr cr
   lea mess2b(pc),a0
   bsr write_str
	move.l a5,a0
	add.l 2(a5),a0
	add.l 6(a5),a0				; a0 = symbol ptr
	move.l 14(a5),d1			; d1 = symb size
	lea 0(a0,d1.l),a1			; a1 = reloc ptr
	lea 0(a5,d7.l),a2			; a2 = end of lib
	sub.l a1,a2					; size to copy
	sub.l d1,d7					; new size
	move.l a2,d0
.lb0:
	move.b (a1)+,(a0)+
	subq.l #1,d0
	bne.s .lb0
	clr.l 14(a5)				; no more symbol table
	rts

	; remplace quelques chaines dans FORTH.LIB selon la langue
set_language:
	lea 58(a5),a0			; zone … remplacer
	lea avert(pc),a1		; chaines selon la langue
	moveq.l #(finavert-avert)/2-1,d0	; nombre de mots
.lb0:
	move (a1)+,(a0)+
	dbf d0,.lb0
	rts


fastopen:
	GEM_AES wind_get0
   moveq #12,d0           ; une douzaine de lignes
   muls fenetre0+14(pc),d0    ; hauteur en points
   lea wg_out(pc),a0
	move #1,(a0)+          ; seulement le nom
	cmp.w 6(a0),d0         ; hauteur maxi d‚pass‚e?
	bpl.s .lb0
	move d0,6(a0)          ; non, on prend donc nos 12 lignes
.lb0:
   move fenetre0+12(pc),d0
   add d0,d0              ; deux colonnes
   add d0,(a0)            ; X d‚cal‚ du bord de la fenetre
   add d0,d0
   sub d0,4(a0)           ; 4 colonnes en moins en tout
	GEM_AES wind_create
	move w_hand(pc),d7
   move d7,wst_in
   GEM_AES wind_set_title
	move d7,wg_out
	GEM_AES wind_open
   move d7,wg_int
	GEM_AES wind_get1
   move.l fenetre,a0
   lea w_travail+2(pc),a1
   move.l (a1)+,(a0)+
   move.l (a1)+,(a0)+
	bsr cls
	GEM_VDI text_align         ; point en haut … gauche
	rts

fastclose:
   GEM_AES wind_close
   GEM_AES wind_del
   rts

; a0 pointe sur la chaine se terminant par 0
; les coordonn‚es du curseur sont dans la structure fenetre
; utilise d0,d1,d2,d3,d4, a0,a1,a2

write_str:
   movem.l d0-d4/a0-a2,-(sp)
.lb0:
   moveq #0,d1                ; nombre de caractŠres
	lea vt_int(pc),a1
	moveq #0,d0
	if STE=0
		lea ([fenetre,pc],8),a2
	else
		move.l fenetre(pc),a2
		addq.l #8,a2
	endif
	move.l (a2)+,d2              ; x et y
	move.l d2,vt_pts
	swap d2                      ; reprend x
	move (a2),d3                 ; l
	move.l fenetre(pc),a2
   move.l (a2)+,d4
	add.l d4,vt_pts
	move (a2),d4                 ; L
.autre:
   add d3,d2
   cmp d2,d4
   bpl.s .place
   tst.b (a0)                   ; mais, sommes nous … la fin?
   beq.s .fin
   move d1,vt_cont+6            ; nombre de caractŠres
   move.l a0,-(sp)
   GEM_VDI vdi_text
   bsr cr
   move.l (sp)+,a0
   bra.s .lb0
.place:
   move.b (a0)+,d0              ; caractŠre suivant
   beq.s .fin
   addq #1,d1
   move d0,(a1)+
   bra.s .autre
.fin:
	move d1,vt_cont+6
   sub d3,d2
   if STE=0
		move d2,([fenetre],8)     ; actualise x
	else
		move.l fenetre,a0
		move d2,8(a0)
	endif
	GEM_VDI vdi_text
	movem.l (sp)+,d0-d4/a0-a2
	rts


initial:
   move.l  4(a7),a5
   move.l  $18(a5),d0
   add.l $1c(a5),d0
   add.l #$1100,d0
   move.l d0,sp
   sub.l a5,d0
   move.l  d0,-(sp)
   move.l  a5,-(sp)
   clr -(sp)
   GEMDOS $4a,12
   GEM_AES appl_init
   clr -(sp)
   pea info
   GEMDOS 61,8						; fopen 'COMP.INF'
   move d0,d7						; handle
   bmi.s .pas_inf
   lea pile(pc),a6
   move.l a6,-(sp)
   move.l #1024,-(sp)			; 1024 octets maxi!
   move d7,-(sp)
   GEMDOS 63,12					; fread
   tst.l d0
   bmi.s .pas_inf
   clr.b 0(a6,d0.l)				; ajoute un z‚ro
   move d7,-(sp)
   GEMDOS 62,4						; fclose
   bra.s .lb1
.pas_inf:
	moveq #-1,d7
.lb1:
	bsr alloc_buffer				; renvoit dans D6 le pourcentage
										; dans d5 le + ou - kilo octets
.encore:
   move.l  #-1,-(sp)          ; taille maxi
   GEMDOS $48,6
   moveq #10,d1
   lsr.l d1,d0
	divs #100,d0					; d6% du total
	muls d6,d0
	add.l d5,d0						; + d5 kilo
   lsl.l d1,d0                ; retour en octets
   move.l  d0,bfsize          ; taille buffer
   move.l  d0,-(sp)
   GEMDOS $48,6               ; allocation
   move.l  d0,beuf
   bpl.s .ok1
   moveq #100,d6
   moveq #-64,d5						; sinon, retour … 100% moins 64Ko
   bra.s .encore
.ok1:
	bsr copie_chemins
   move.l  a7,uspile
   GEM_AES graf_hand
   move.l intout+2,fenetre0+12
   move intout,i_handle
   XBIOS 4,2
   add d0,ow_int
   GEM_VDI open_work
   move ow_cont+12,i_handle
   if DBG=0
	   GEM_VDI hide_mouse
	endif

   jsr fastopen

   jmp debut

alloc_buffer:
	tst d7
	bmi.s .defaut
	move.b (a6)+,d0
	cmp.b #'%',d0
	bne.s .defaut
	moveq #0,d6
.lb1:
	move.b (a6)+,d0
	beq.s .defaut
	cmp.b #"+",d0
	beq.s .suite
	cmp.b #"-",d0
	beq.s .suite
	cmp.b #13,d0
	beq.s .defaut
	cmp.b #10,d0
	beq.s .defaut
	muls #10,d6
	sub.b #'0',d0
	add.b d0,d6
	bra.s .lb1
.suite:
	moveq #0,d5
.lb2:
	move.b (a6)+,d1
	beq.s .defaut
	cmp.b #13,d1
	beq.s .fin
	cmp.b #10,d1
	beq.s .fin
	muls #10,d5
	sub.b #'0',d1
	ext.w d1
	ext.l d1
	add.l d1,d5
	bra.s .lb2
.fin:
	cmp.b #'+',d0
	beq.s .fin2
	neg.l d5
.fin2:
	rts
.defaut:
	moveq #-1,d7
	moveq #100,d6
	moveq #-64,d5
	rts

copie_chemins:
	lea chemin(pc),a0
.lb0:
	move.b (a6)+,d0
	beq.s .defaut
	cmp.b #32,d0
	bmi.s .lb0
	subq.l #1,a6
.lb1:
	move.b (a6)+,d0
	beq.s .defaut
	cmp.b #13,d0
	beq.s .suite
	cmp.b #10,d0
	beq.s .suite
	move.b d0,(a0)+
	bra.s .lb1
.suite:
	clr.b (a0)
	lea file(pc),a0
.lb4:
	move.b (a6)+,d0
	beq.s .defaut
	cmp.b #32,d0
	bmi.s .lb4
	subq.l #1,a6
.lb5:
	move.b (a6)+,d0
	beq.s .defaut
	cmp.b #13,d0
	beq.s .suite2
	cmp.b #10,d0
	beq.s .suite2
	move.b d0,(a0)+
	bra.s .lb5
.suite2:
	clr.b (a0)
	lea chemin2(pc),a1
.lb2:
	move.b (a6)+,d0
	beq.s .defaut
	cmp.b #32,d0
	bmi.s .lb2
	subq.l #1,a6
.lb3:
	move.b (a6)+,d0
	beq.s .fin
	cmp.b #13,d0
	beq.s .fin
	cmp.b #10,d0
	beq.s .fin
	move.b d0,(a1)+
	bra.s .lb3
.fin:
	clr.b (a1)
	rts
.defaut:
	lea chemin(pc),a0
	move.l #'*.FO',(a0)+
	move #$5200,(a0)+
	lea file(pc),a0
	move.l #'FORT',(a0)+
	if STE=0
	   move.l #'H.LI',(a0)+
	   move #$4200,(a0)
	else
		move.l #'HSTE',(a0)+
		move.l #'.LIB',(a0)+
		clr.b (a0)
	endif
	lea chemin2(pc),a1
	move.l #'*.PR',(a1)+
	move #$4700,(a1)
	rts
   even

gblk:  dc.b 0,-1,0,0,1,1,49,0,0,0,76,0,%1110,3,75,1,0,0,14,1,0,-1,25,1,1,0,59,1
       dc.b 1,1,71,1,1,1,54,0,1,0,57,1,1,0,58,1,%110,2,86,1,1,2,67,1,0,0,69,1
       dc.b 0,1,70,1,1,0,72,1,1,0,73,1,%110,2,74,1,0,-1,3,1,0,0,4,0,0,0,5,1
       dc.b 0,0,6,1,1,0,9,0,1,0,10,1,0,-1,11,1,0,-1,17,1,0,-1,18,1,0,-1,19,1

bblk:  dc.b 0,0,1,1,0,0,8,1,0,0,2,1,0,1,3,0,%10,4,4,1,0,0,9,1,0,-1,10,1
       dc.b 1,0,0,0,0,0,7,1,0,0,11,1,%10,1,5,0

xblk:  dc.b 0,-1,2,1,0,-1,3,1,0,-1,4,1,%11,2,5,0,1,0,6,0,0,1,7,0,%11,6,8,1
       dc.b %11,6,9,1,%11,6,19,1,%10,1,13,0,0,0,26,0,0,0,27,0,%1000,3,31,0
       dc.b 0,-1,34,1,%10,1,12,0,0,1,28,1,1,0,32,0,0,0,29,0,0,0,30,0,0,0,33,1
       dc.b 0,5,15,0,0,0,14,1,%110,2,0,0,%111,2,16,0,0,-1,24,0,0,1,35,1
       dc.b 0,-1,17,1,1,0,38,0

; puissances de 10 de 10^-8192 … 10^-1

; puissances de 10 de 10^-1 … 10^-256

negdata:   dc.l $3fb99999,$9999999a
           dc.l $3f847ae1,$47ae147a
           dc.l $3f1a36e2,$eb1c432c
           dc.l $3e45798e,$e2308c38
           dc.l $3c9cd2b2,$97d889b7
           dc.l $3949f623,$d5a8a729
           dc.l $32a50ffd,$44f4a72d
           dc.l $255bba08,$cf8c9771
           dc.l $0ac80628,$64ac6ef7

; puissances de 10 de 10^1 … 10^256

posdata:  dc.l $40240000,0
          dc.l $40590000,0
          dc.l $40c38800,0
          dc.l $4197d784,0
          dc.l $4341c379,$37e08000
          dc.l $4693b8b5,$b5056e16
          dc.l $4d384f03,$e93ff9f3
          dc.l $5a827748,$f9301d2e
          dc.l $75154fdd,$7f73bf33

; nombres r‚els de 1 … 9

chdata:   dc.w $3ff0,$4000,$4008,$4010,$4014,$4018,$401c,$4020,$4022


  end

