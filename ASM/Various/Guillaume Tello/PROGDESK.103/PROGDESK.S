; PROGDESK: bureau (ou shell) programmable

	opt P=68000,w+
	
	; langues: FR = 0, EN = 1, IT = 3, CZ = 4
	;	   PL = 4, SW = 5, ES = 6

MAXLANG = 7

VERSION MACRO
	dc.b "1.05"
	ENDM
	
	output "PROGDESK.PRG"

MEM = 11			; 0-9 and : for language

XBIOS MACRO   ; fn,pile
   move #\1,-(sp)
   trap #14
   if \2<=8
      addq.l #\2,sp
   else
      add.w #\2,sp
   endif
   ENDM

BIOS MACRO   ; fn,pile
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
   
GEM_AES MACRO	; adresse
	lea \1(pc),a0
	move.l a0,d1
	move #$c8,d0
	trap #2
	ENDM
	
	text
	
	
	bra.s debut
builtin_lang: dc.w 0
	dc.b "ProgDESK V"
	VERSION
	dc.b 0,"(c) 98-18, guillaume.tello@orange.fr"
	even
debut:
	move.l 4(sp),a0
	move.l a0,basepage
	move.l $18(a0),a1
	add.l $1c(a0),a1
	add.l #$200,a1
	move.l a1,sp
	sub.l a0,a1
	move.l a1,-(sp)
	move.l a0,-(sp)
	clr.w -(sp)
	GEMDOS $4a,12
	
	moveq.l #0,d0
	move.w builtin_lang(pc),d0
	bsr setlanguage		; default is french
	st exec_auto			; AUTO will be executed
	GEM_AES appl_init		; hello AES
	cmp #$140,global
	bpl.s xselect
	lea fi_cont(pc),a0
	subq #1,(a0)			; fonction precedente
	subq #1,6(a0)			; addrin revenu a deux
xselect:	
	GEM_AES graf_handle	; size of one char
	bsr adapt_input_box
	GEM_AES wind_get		; size of screen
	move.l a7,savestack
	move.l basepage(pc),a6
	add.w #$80,a6
	moveq #0,d0
	move.b (a6)+,d0
	beq.s defaut
	clr.b 0(a6,d0.w)		; end of string	
	bra.s autre_menu
defaut:	
	st is_default
	lea default_file(pc),a6
	
autre_menu:
	bsr load_inf_file		; remplit TREE avec adresse des chaines
	lea is_default(pc),a0
	beq.s .ok
	tst.b (a0)				; a t on deja tente le menu par defaut?
	beq.s defaut			; non, allons y
	lea pas_de_dsk(pc),a0
	bsr lang_adr_a0
	bsr alert
	bra termine
.ok:
	sf (a0)
	bsr menu					; remplit TREE avec l'adresse de l'arbre
	
	move.l auto_adr(pc),d0
	beq.s grosse_boucle
	tst.b exec_auto
	beq.s .skip_auto
	move.l d0,a5
	lea labels(pc),a0
	move.l a0,120(a0)		; =	move.l #labels,lab_ptr	; reset labels
	bsr interprete
.skip_auto:
	st exec_auto

grosse_boucle:
	lea gm_int(pc),a0
	move #256,(a0)
	GEM_AES graf_mouse

	bsr setmenu
	lea mb_int(pc),a0
	move #1,(a0)
	GEM_AES menu_bar
	
	lea gm_int(pc),a3
	clr (a3)
	GEM_AES graf_mouse
	move #257,(a3)
	GEM_AES graf_mouse
.wait_event:
	GEM_AES evnt_mesag
	lea aes_buffer(pc),a3
	cmp #10,(a3)
	bne.s .wait_event
	lea mt_int(pc),a0
	move.w 6(a3),(a0)	; index du titre
	GEM_AES menu_tnormal
	move 8(a3),d0
	bsr strindex			; index chaine de l'entree dans D0
	lsl.l #2,d0
	move.l table_adr(pc),a0
	move.l 0(a0,d0),a5	; adresse de la partie ex‚cutable
	lea labels(pc),a0
	move.l a0,120(a0)		; =	move.l #labels,lab_ptr	; reset labels
	bsr interprete
	;
	bra grosse_boucle	
	
termine:
	GEM_AES appl_exit
	clr -(sp)
	trap #1

malloc:
	move.l d6,-(sp)
	GEMDOS 72,6
	rts

appl_init: dc.l ai_cont,global,dum,appl_id,dum,dum
ai_cont: dc.w 10,0,1,0,0
appl_id: dc.w 0


default_file: dc.b "DEFAULT.DSK",0
	even

graf_handle: dc.l gh_cont,global,dum,gh_out,dum,dum
gh_cont: dc.w 77,0,5,0,0
gh_out: dc.w 0
charw: dc.w 0
charh: dc.w 0
		dc.w 0,0


; A6=path+file.inf

; output d0=-1 -> not found
;			d0=0	-> ok

	
load_inf_file:
	pea dta(pc)
	GEMDOS 26,6			; ma dta
	clr -(sp)
	move.l a6,-(sp)
	GEMDOS 78,8		; find first
	tst d0
	beq.s .ok
.beurk:
	moveq #-1,d0
	rts
.ok:
	sf vu_menu		; pour decider si @ est une entree ou un lien EXT
	move.l table_adr(pc),a2
	bsr mfree
	move.l inf_adr(pc),a2
	bsr mfree
	clr.l auto_adr
	move.l dta+26,d6	; size of file
	addq.l #6,d6
	bsr malloc
	subq.l #6,d6
	move.l d0,inf_adr
	move.l d0,a5
	clr -(sp)
	move.l a6,-(sp)
	GEMDOS 61,8			; open INF
	move d0,d3
	bmi.s .beurk
	pea 2(a5)
	move.l d6,-(sp)
	move d3,-(sp)
	GEMDOS 63,12		; fread entier
	cmp.l d0,d6
	bne.s .beurk
	move d3,-(sp)
	GEMDOS 62,4			; fclose
	moveq #0,d3			; nombre de menus
	moveq #0,d4			; taille maxi d'une chaine
	moveq #0,d5			; nombre total de chaines (menus + drop down)
	moveq #0,d7			; nombre de @ avant le premier MENU (donc des extensions)
	move.l a5,a0		; d‚but de fichier
	move.b #13,2(a5,d6.l)
	move.b #"œ",3(a5,d6.l)	; fin de fichier
	move.b #13,4(a5,d6.l)
	move #$0d0a,(a5)	; simule une premiŠre ligne
.next_line:
	bsr next_line
	move.b (a0)+,d0		; premier caractŠre
	cmp.b #";",d0
	beq.s .next_line	; un commentaire
	cmp.b #"*",d0		; un menu?
	bne.s .p0
	addq #1,d3			; un menu de plus
	bsr text_size		; updates D4
	bra.s .next_line
.p0:
	cmp.b #"@",d0
	bne.s .p1
	tst d3
	bne.s .p2			; d‚j… un menu, donc @ est une entree
	bsr count_ext		; sinon, compte les extensions list‚es (dans D7)
	bra.s .next_line
.p2:
	addq #1,d5			; une chaine de plus
	bsr text_size
	bra.s .next_line
.p1:
	cmp.b #"œ",d0
	bne.s .next_line
	moveq #8,d6
	muls d7,d6		; taille pour extensions ('EXT0' + adresse)
	addq.l #4,d6	; plus DUMMY (0=fin de table)
	bsr malloc
	move.l d0,ext_adr
	move.l d0,ext_ptr
	move.l d0,a0
	clr.l (a0)		; resets table
	moveq #11,d6
	add d5,d6
	add d3,d6
	add d3,d6
	muls #24,d6		; taille de l'arbre de menu
	moveq #40,d7	; header size
	add.l d7,d6
	move.l d6,menu_size
	addq #3,d4		; 2 blancs avant, un blanc apres
	moveq #1,d6
	add d3,d6
	add d3,d6
	add d6,d5		; nombre total de chaines plus les s‚parateurs
	move d4,d7
	addq #4,d7		; +0 + size
	bclr #0,d7		; offset from one string to another
	move d7,d6
	addq #4,d6		; + table d'access au BAT
	muls d5,d6		; taille totale du tableau
	move.l d6,menu_adr
	add.l menu_size(pc),d6	; + arbre de menu
	bsr malloc
	move.l d0,table_adr
	add.l d0,menu_adr
	move.l d0,a3	; pointe sur la table (facile!)
	lsl.l #2,d5
	lea 0(a3,d5.l),a4	; pointe sur les chaines MENU
	move.l a4,tree
	move.l a4,fin_tab
	move.l a3,a0	; debut de la table
.vide_tab:
	clr.l (a0)+
	cmp.l a4,a0
	bmi.s .vide_tab
	move d3,d0
	lsl #2,d0
	add d0,a3		; skip MENU strings (no entry in table)
	muls d7,d3		; size of MENU strings
	move.l a5,a0	; debut di fichier
	lea 0(a4,d3.l),a5	; pointe sur drop down strings
.add_string:
	bsr next_line
.same_line:
	move.b (a0)+,d0
	cmp.b #";",d0	
	beq.s .add_string
	cmp.b #"*",d0
	bne.s .c0
	addq.l #4,a3	; une entree DUMMY
	move d4,(a5)+	; size of string DUMMY
	clr (a5)			; Null string
	lea -2(a5,d7.w),a5	; next dummy string
	move.l a4,a1
	bsr add_entree
	add d7,a4		; next string
	st vu_menu
	bra.s .add_string
.c0:
	cmp.b #'@',d0
	bne.s .c1
	tst.b vu_menu
	bne.s .c99			; un menu deja vu, plus d'extensions
	bsr treat_new_ext	; sinon, c'est une nouvelle extension!
	bra.s .add_string
.c99:
	move.l a5,a1
	cmp.b #"@",(a0)	; double @@?
	bne.s .c00
	bset #7,(a3)		; bit mis dans tableau
	addq.l #1,a0		; saute le caractere
.c00:
	bsr add_entree
	bsr next_line
	move.l a0,d0
	add.l d0,(a3)+		; nouvelle entree (avec bit 31 eventuel)
	add d7,a5
.c01:
	bsr test_if_empty_cmd
	beq.s .add_string
	bra.s .same_line
.c1:
	cmp.b #">",d0		; >AUTO???
	bne.s .c2
	bsr next_line
	move.l a0,auto_adr
	bra.s .c01
.c2:
	cmp.b #'œ',d0
	bne.s .add_string
	move d4,(a5)+
	clr (a5)				; last dummy string
	rts					; returns EQ
	
wind_get: dc.l wg_cont,global,wg_int,wg_out,dum,dum
wg_cont: dc.w 104,2,5,0,0
wg_int: dc.w 0,5
wg_out: dc.w 0,0,0
screenw dc.w 0
screenh: dc.w 0
	
test_if_empty_cmd:
	move.l a0,a1
.lb0:
	move.b (a1)+,d0
	cmp.b #13,d0
	beq.s .normal
	cmp.b #10,d0
	beq.s .normal
	cmp.b #33,d0
	bmi.s .lb0
	cmp.b #"*",d0
	beq.s .artif
	cmp.b #"@",d0
	beq.s .artif
	cmp.b #"œ",d0
	bne.s .normal
.artif:
	lea -1(a1),a0
	moveq #1,d0
	rts	
.normal:
	moveq #0,d0
	rts	
	
add_entree:
	move d4,(a1)+		; size
	move #$2020,(a1)+	; deux blancs
.lb0:
	cmp.b #33,(a0)+
	bmi.s .lb0
	subq.l #1,a0
	move.l a0,a2		; save pos
.lb1:
	move.b (a0)+,d1
	cmp.b #13,d1
	beq.s .found
	cmp.b #10,d1
	bne.s .lb1
.found:
	subq.l #1,a0
.lb2:
	cmp.b #32,-(a0)	
	beq.s .lb2
	addq.l #1,a0
.lb3:
	move.b (a2)+,(a1)+
	cmp.l a0,a2
	bmi.s .lb3
	move.b #32,(a1)+
	clr.b (a1)
	rts

appl_exit: dc.l ae_cont,global,dum,dum,dum,dum
ae_cont: dc.w 19,0,1,0,0
	
next_line:
	move.b (a0)+,d0
	cmp.b #13,d0
	beq.s .found
	cmp.b #10,d0
	bne.s next_line
.found:
	cmp.b #33,(a0)+
	bmi.s .found
	subq.l #1,a0
	rts

text_size:
	cmp.b #33,(a0)+
	bmi.s text_size	; look for 1st >32
	subq.l #1,a0
	move.l a0,d1
.lb0:
	move.b (a0)+,d0
	cmp.b #13,d0
	beq.s .found
	cmp.b #10,d0
	bne.s .lb0
.found:
	subq.l #1,a0
.lb1:
	cmp.b #32,-(a0)
	beq.s .lb1
	addq.l #1,a0
	sub.l a0,d1			; size of text
	neg.l d1
	cmp.l d1,d4
	bpl.s .fin
	move.l d1,d4		; new max size
.fin:
	rts

separe: dc.b "--------------------"
nulle: dc.b 0

 even
menudat:
 dc.w 0,40,40,40,40,0,40,40,0,36
 dc.w 0,1,0,0,0,0,0,0                   ; nombre d'objets , ... , taille totale

 dc.w -1,1,3,25,0,0,0,0,0,0,0,0         ; ROOT
 dc.w 3,2,2,20,0,0,0,$1100,0,0,0,0      ; BAR
 dc.w 1,3,3,25,0,0,0,0,0,0,0,0          ; ACTIVE

 dc.w 0,0,0,25,0,0,0,0,0,0,0,0          ; SCREEN

isfirst: dc.w 0

; adresse du tableau de chaines dans A4

menu: move.l #indextab,indexadr   ; pour la table de conversion
  move.w charw(pc),d0       ; largeur cellule
  move.w charh(pc),d1       ; hauteur cellule
  move.w screenw(pc),d2     ; resolution horizontale
  move.w screenh(pc),d3     ; resolution verticale
  lea menudat(pc),a0
  move.l menu_adr(pc),a1
  move.l a1,global+14   ; adresse du header
  rept 5
  move.l (a0)+,(a1)+
  endr
  move.l a1,a5          ; garde l'adresse du nombre d'objets
  rept 4
  move.l (a0)+,(a1)+
  endr
  move.l a1,global+10   ; adresse de la table
  addq.l #4,a1
  move.l a1,-4(a1)      ; table des arbres, un seul qui pointe sur la suite
  move.l tree(pc),a4
  addq.l #2,a4				; saute le SIZE de la chaine
  move.l a1,tree        ; adresse de l'arbre
  move.w d2,20(a0)      ; L de ROOT
  move.w d3,22(a0)      ; H
  move.w d2,44(a0)      ; L de BAR
  move.w d2,92(a0)      ; L de SCREEN
  sub.w d1,d3
  sub.w d1,d3
  move.w d3,94(a0)      ; H de SCREEN ( ymax-2lignes )
  moveq #2,d2
  add d1,d2             ; hauteur de BAR
  move d2,46(a0)
  addq #1,d2            ; hauteur des titres
  move d2,70(a0)        ; hauteur de ACTIVE
  move d2,90(a0)        ; y de SCREEN
  move d0,d3
  add d0,d3
  move d3,64(a0)        ; x de ACTIVE
  move.l a1,a6          ; garde le debut de l'arbre
  moveq #17,d4
.lb0: move.l (a0)+,(a1)+
  dbf d4,.lb0           ; transvase ROOT, BAR, ACTIVE
  move -2(a4),d4      	; mlen
  addq #4,d4
  bclr #0,d4            ; d4=offset pour chaine suivante
  moveq #3,d5           ; num‚ro de l'objet libre
  moveq #0,d6           ; largeur de ACTIVE, et x du titre en cours
.titreloop:
  move.l indexadr(pc),a2
  move.b d5,(a2)+       ; table de conversion
  move.l a2,indexadr
  tst.b (a4)
  beq.s .dropdown       ; chaine vide = fin des titres
  move.l a4,a2
.lb1: tst.b (a2)+
  bne.s .lb1
  sub.l a4,a2
  subq.l #1,a2          ; longueur du titre
  move a2,d7            ; L en caractŠres
  muls d0,d7            ; L en points
					         ; objet titre
  addq #1,d5            ; un objet de plus
  move d5,(a1)+         ; pointe sur le suivant
  move.l #-1,(a1)+      ; pas d'enfants
  move #32,(a1)+        ; G_TITLE
  clr.l (a1)+           ; flag et state
  move.l a4,(a1)+       ; adr chaine
  move d6,(a1)+         ; X
  clr (a1)+             ; Y
  move d7,(a1)+         ; L
  move d2,(a1)+         ; H
  add d7,d6             ; ACTIVE s'‚largit
  add.w d4,a4           ; chaine suivante
  bra.s .titreloop
.dropdown: move #1,isfirst  ; c'est le premier drop down
  move d6,68(a6)        ; L de ACTIVE
  move d5,24(a6)        ; BAR pointe sur SCREEN
  move d5,4(a6)         ; ROOT pointe sur SCREEN
  subq #1,d5
  move d5,52(a6)        ; ACTIVE pointe sur le dernier titre
  addq #1,d5
  move #2,-24(a1)       ; le dernier titre pointe sur ACTIVE
  lea 72(a6),a3         ; a3 pointe sur la suite des titres
        ; objet SCREEN
  addq #1,d5
  move d5,2(a0)         ; SCREEN pointe sur son premier enfant
  moveq #5,d6
.lb2: move.l (a0)+,(a1)+
  dbf d6,.lb2
  moveq #20,d7          ; premier BOX, large de 20 au minimum
        ; objet drop-down
  move.l a1,a6          ; conserve l'adresse du drop-down
.loopbox: addq #1,d5
  clr (a1)+             ; suivant inconnu
  move d5,(a1)+         ; 1ø enfant
  clr (a1)+             ; dernier inconnu
  move #20,(a1)+        ; G_BOX
  clr.l (a1)+           ; flag et state
  move.l #$FF1100,(a1)+ ; obspec
  move 16(a3),d6        ; x du titre
  add d0,d6
  add d0,d6             ; plus deux colonnes de d‚calage
  move d6,(a1)+         ; x du BOX
  clr (a1)+             ; y
  clr.l (a1)+           ; l et h inconnus
  moveq #0,d3           ; hauteur du BOX
.loopstr:
  move.l indexadr(pc),a2
  move.b d5,(a2)+       ; table de conversion
  move.l a2,indexadr
  add.w d4,a4   ; chaine suivante
  tst.b (a4)
  beq.s .finboite       ; chaine nulle pour la fin d'un DROP-DOWN
  move.l a4,a2
.lb3: tst.b (a2)+
  bne.s .lb3
  sub.l a4,a2
  subq.l #1,a2
  cmp a2,d7             ; compare avec taille maxi
  bpl.s .lb4
  move a2,d7            ; ‚change si plus
.lb4:					      ; objet STRING
  addq #1,d5
  move d5,(a1)+         ; pointe sur suivant
  move.l #-1,(a1)+      ; pas d'enfants
  move #28,(a1)+        ; G_STRING
  clr.l (a1)+           ; flag et state
  move.l a4,(a1)+       ; chaine
  clr (a1)+             ; x
  move d3,(a1)+         ; y
  clr (a1)+             ; l inconnu
  move d1,(a1)+         ; h=1 caractŠre
  add d1,d3             ; BOX augmente de taille
  bra.s .loopstr        ; entr‚e suivante
.finboite: muls d0,d7   ; largeur BOX
  tst isfirst  ; est-ce le premier menu?
  beq.s .autre ; 0 si c'est un autre
		        ; objet separateur
  addq #1,d5
  move d5,(a1)+
  move.l #-1,(a1)+
  move #28,(a1)+
  move.l #8,(a1)+
  move.l #separe,(a1)+
  clr (a1)+
  move d3,(a1)+
  add d1,d3
  clr (a1)+
  move d1,(a1)+
       ; les accessoires
  moveq #5,d6
.loopacc: addq #1,d5
  move d5,(a1)+
  move.l #-1,(a1)+
  move #28,(a1)+
  clr.l (a1)+
  move.l #nulle,(a1)+
  clr (a1)+
  move d3,(a1)+
  add d1,d3
  clr (a1)+
  move d1,(a1)+
  dbf d6,.loopacc
  clr isfirst
.autre: move d5,(a6)   ; lie les drop downs
  subq #1,d5
  move d5,4(a6)        ; BOX pointe sur le dernier enfant
  addq #1,d5
  move 24(a6),d6       ; sur qui pointe le premier enfant...
  subq #2,d6           ; ... donc -2 = index du BOX
  move d6,-24(a1)      ; le dernier enfant pointe sur BOX
  move d3,22(a6)       ; H du BOX
.lb5: move d7,20(a6)   ; L du BOX et des STRINGs
  add.w #24,a6         ; objet suivant
  cmp.l a6,a1          ; fini?
  bne.s .lb5           ; ben non
  cmp #2,(a3)
  beq.s .fin           ; c'‚tait le dernier titre ( il pointe sur ACTIVE )
  add.w #24,a3         ; titre suivant
  clr d7               ; largeur du BOX
  bra .loopbox
.fin: move d5,(a5)     ; nombre d'objets dans header
  move d5,d3
  muls #24,d3
  add.w #40,d3         ; taille totale
  move d3,14(a5)       ; dans header
  move d3,global+18
  add.w #24,a3         ; aprŠs les titres on pointe sur SCREEN !
  move d5,d3
.lb6: sub.w #24,a1     ; objet pr‚c‚dent
  subq #1,d3
  cmp (a1),d5
  bne.s .lb6           ; lorqu'il pointera sur d5, ce sera le dernier dropdown
  move d3,4(a3)        ; SCREEN pointe sur son dernier enfant
  move 2(a3),d3        ; sur qui pointe SCREEN...
  subq #1,d3           ; ...donc - 1 c'est son index
  move d3,(a1)         ; le dernier BOX pointe sur SCREEN.
  move.l table_adr(pc),a0
  move.l fin_tab(pc),a4
  lea indextab(pc),a1
  move.l tree(pc),a2
.set_disabled:
   bclr #7,(a0)
   beq.s .skip
  	moveq #0,d0
  	move.b (a1),d0
  	muls #24,d0
  	bset #3,11(a2,d0.l)
.skip:
	addq.l #4,a0
	addq.l #1,a1
	cmp.l a4,a0
	bmi.s .set_disabled
   rts

input:
	dc.w -1,1,4,20,0,16,2,$1100,0,0,$BBBB,5	; boite (bbb= largeur)
	dc.w 2,-1,-1,28,0,0,$CCCC,$CCCC,1,1,$BBBB,1	; string
	dc.w 3,-1,-1,29,8,0
	dc.l tedinfo
	dc.w 1,3,$bbbb,1									; ligne editable
	dc.w 4,-1,-1,26,5,0
input_cancel:
	dc.l annule
	dc.w $bbbb,1,9,1									; bouton annule
	dc.w 0,-1,-1,26,$27,0
input_ok:
	dc.l confirme
	dc.w $bbbb,3,9,1									; bouton confirmer
	
cancel_list: dc.l annule,.en,.it,.cz,.pl,.sw,.es
.en: dc.b "Cancel",0
.it: dc.b "Annulla",0
.cz: dc.b "Zrusit",0
.pl: dc.b "Odrzuc",0
.sw: dc.b "Avbryt",0
.es: dc.b "Cancelar",0
annule: dc.b "Annule",0


	even
ok_list: dc.l confirme,.en,.it,.cz,.pl,.sw,.es
.en: dc.b "Confirm",0
.it: dc.b "Conferma",0
.cz: dc.b "Potvrdit",0
.pl: dc.b "Potwierdz",0
.sw: dc.b "Bekr„fta",0
.es: dc.b "Confirmar",0
confirme: dc.b "Confirme",0


	even
	
adapt_input_box:
	lea input+16(pc),a0
	moveq #4,d0			; 5 objets
	move charw(pc),d1
	move charh(pc),d2	
.lb0:
	rept 2
		move (a0),d3
		muls d1,d3
		move d3,(a0)+
		move (a0),d3
		muls d2,d3
		move d3,(a0)+
	endr
	add.w #16,a0
	dbf d0,.lb0
	rts
		
tedinfo:
	dc.l $bbbbbbbb,pad2,pad2+128
	dc.w 3,6,2,$1180,0,-1,$bbbb,$bbbb

setmenu: lea global+6(pc),a0
  move.l tree(pc),a1
  lea -4(a1),a2        ; adresse de la table des arbres
  sub.w #40,a1         ; adresse du header
  move.l #indextab,(a0)+
  move.l a2,(a0)+
  move.l a1,(a0)+
  rts
  
pas_de_dsk: 
	dc.l .fr,.en,.it,.cz,.pl,.sw,.es
	
.fr: dc.b "[3][ Fichier DSK introuvable! | | DEFAULT.DSK introuvable! ][Quitter]",0
.en: dc.b "[3][ Can't find the DSK file | no DEFAULT.DSK found ! ][ Quit ]",0
.it: dc.b "[3][ Non trovo il file DSK, | DEFAULT.DSK non trovato! ][ Quit ]",0
.cz: dc.b "[3][ Nelze nel‚zt soubor DSK, | DEFAULT.DSK nenalezen ! ][ Odej¡t ]",0
.pl: dc.b "[3][ Nie moge znalezc pliku DSK, | Brak DEFAULT.DSK! ][ Wyjdz ]",0
.sw: dc.b "[3][ DSK-filen finns inte, | DEFAULT.DSK saknas! ][ Avsluta ]",0
.es: dc.b "[3][ No se encuentra el | archivo DSK, | ­no se encuentra DEFAULT.DSK! ][ Salir ]",0

	even
  
gemindex: move.l (a6),d0
  lea indextab(pc),a0
  move.b 0(a0,d0),3(a6)
  rts

menu_bar: dc.l mb_cont,global,mb_int,dum,tree,dum
mb_cont: dc.w 30,1,1,1,0
mb_int: dc.w 1

; A5 adresse du texte

interprete:
	bsr find_cmd			; a0 le mot, d0 sa taille
	bpl.s .ok
.sortie:
	rts
.ok:
	lea premier(pc),a1
	cmp.b #4,d0			; 4 lettres?
	bne.s .cmd
	cmp.l #'stop',(a0)
	beq.s .sortie		; commande 'stop'
.cmd:
	moveq #0,d1
	move.b 4(a1),d1		; taille du mot
	cmp.b d0,d1
	bne.s .next
	lea 5(a1),a2
	move.l a0,a3
	subq #1,d1
.truc:
	cmp.b (a2)+,(a3)+
	dbne d1,.truc
	bne.s .next				; pas le bon mot
	addq #2,d0			; sinon, saute le mot
	bclr #0,d0
	lea 4(a1,d0),a1		; routine
	jsr (a1)					; et ex‚cute!
	bra.s interprete
.next:
	move.l (a1),d1
	beq.s .error			; si 0, pas d'autre commande
	move.l d1,a1
	bra.s .cmd
.error:
		cmp #5,d0
		bne.s .vraie_erreur
		lea mot(pc),a1
		move.l (a1),d1
		and.l #$FF00FFFF,d1
		cmp.l #$25003d25,d1	; '% =%'
		bne.s .vraie_erreur
		move.b 1(a1),d0
		sub.b #'0',d0
		bmi.s .vraie_erreur
		ext.w d0
		cmp #MEM,d0
		bpl.s .vraie_erreur
		lsl #8,d0
		move.b 4(a1),d1
		lea mem(pc),a0
		lea 0(a0,d0),a1
		cmp.b #"%",d1
		bne.s .vraie_copie
		clr.b (a1)				; %x=%% pour vider une chaine
		bra interprete
	.vraie_copie:
		sub.b #'0',d1
		bmi.s .vraie_erreur
		ext.w d1
		cmp #MEM,d1
		bpl.s .vraie_erreur
		lsl #8,d1
		add d1,a0
	.copymem:
		move.b (a0)+,(a1)+
		bne.s .copymem		
		bra interprete
	.vraie_erreur:
	lea bad_cmd(pc),a0
	bsr lang_adr_a0
	bsr alert
	rts
	
	
bad_cmd: dc.l .fr,.en,.it,.cz,.pl,.sw,.es

.fr: dc.b "[3][ Commande inconnue! ][Oups !]",0
.en: dc.b "[3][ Unknown command ! ][Oops !]",0
.it: dc.b "[3][ Comando sconosciuto! ][Oops !]",0
.cz: dc.b "[3][ Nezn my pr¡kaz ! ][Jejda !]",0
.pl: dc.b "[3][ Nieznany rozkaz ! ][Ops !]",0
.sw: dc.b "[3][ Ok„nt kommando! ][Hoppla!]",0
.es: dc.b "[3][ ­Comando desconocido! ][­Huy!]",0

	even	

; D0=int
; A0 string space

int_to_str:
	tst.l d0
	bpl.s .lb1
	move.b #'-',(a0)+
	neg.l d0
.lb1:
	lea pad2+20(pc),a1
	clr.b (a1)
.lb0:
	divs #10,d0
	swap d0
	add.b #'0',d0
	move.b d0,-(a1)
	clr d0
	swap d0
	bne.s .lb0
.copy:
	move.b (a1)+,(a0)+
	bne.s .copy
	rts	
	
	
menu_tnormal: dc.l mt_cont,global,mt_int,dum,tree,dum
mt_cont: dc.w 33,2,1,1,0
mt_int: dc.w 0,1

find_cmd:
	cmp.b #33,(a5)+
	bmi.s find_cmd
	move.b -1(a5),d0	; first char
	cmp.b #";",d0
	bne.s .lb1
.lb0:
	move.b (a5)+,d0	; un commentaire
	cmp.b #13,d0
	beq.s find_cmd
	cmp.b #10,d0
	beq.s find_cmd
	bra.s .lb0
.lb1:
	cmp.b #"*",d0
	bne.s .lb2
.fin_cmd:
	moveq #-1,d0		; plus de commandes
	rts
.lb2:
	cmp.b #"@",d0
	beq.s .fin_cmd
	cmp.b #"œ",d0
	beq.s .fin_cmd
	cmp.b #".",d0
	bne.s .lb0			; pas un point? ignorer commande, ligne suivante
	lea mot(pc),a0
.copy_mot:
	move.b (a5)+,d0
	cmp.b #33,d0
	bmi.s .fin_mot
	move.b d0,(a0)+
	bra.s .copy_mot
.fin_mot:
	clr.b (a0)
	move.l a0,d0
	lea mot(pc),a0
	sub.l a0,d0			; taille du mot
	rts

mot: dcb.b 20,0

mfree:
	cmp.l #0,a2
	beq.s .fin
	move.l a2,-(sp)
	GEMDOS 73,6
.fin:
	rts
	
graf_mouse: dc.l gm_cont,global,gm_int,dum,dum,dum
gm_cont: dc.w 78,1,1,1,0
gm_int: dc.w 0

alert:
	lea fa_addrin(pc),a1
	move.l a0,(a1)
	GEM_AES form_alert
	move dum(pc),d0
	ext.l d0
	rts

form_alert: dc.l fa_cont,global,fa_int,dum,fa_addrin,dum
fa_cont: dc.w 52,1,1,1,0
fa_int: dc.w 1

; A5 line pointer (ends with 13,10)
; PAD line expanded

expand_line:
	lea pad(pc),a0
.lb0:
	move.b (a5)+,d0
	cmp.b #13,d0
	beq.s .end
	cmp.b #10,d0
	beq.s .end
	cmp.b #33,d0
	bmi.s .lb0
	bra.s .lb4
.lb1:
	move.b (a5)+,d0
	cmp.b #13,d0
	beq.s .cut_end
	cmp.b #10,d0
	beq.s .cut_end
.lb4:
	cmp.b #"%",d0
	bne.s .lb2
	move.b (a5)+,d0
	cmp.b #"%",d0		; double %, pour un %
	beq.s .lb2
	sub.b #'0',d0
	bmi.s .lb2			; aie!!!
	ext.w d0
	cmp #MEM,d0
	bpl.s .lb2			; ouille...
	ext.l d0
	lsl.l #8,d0			; *256
	lea mem(pc),a1
	add.l d0,a1
.lb3:
	move.b (a1)+,(a0)+
	bne.s .lb3
	subq.l #1,a0
	bra.s .lb1
.lb2:
	move.b d0,(a0)+
	bra.s .lb1
.cut_end:
	cmp.b #32,-(a0)
	beq.s .cut_end
	addq.l #1,a0
.end:
	clr.b (a0)
	rts
	
evnt_mesag: dc.l em_cont,global,dum,dum,em_addrin,dum
em_cont: dc.w 23,0,1,1,0
em_addrin: dc.l aes_buffer

premier:
	dc.l ordre2
	dc.b 3,"end"
	bra termine
	
ordre2:
	dc.l ordre3
	dc.b 5,"alert"
	bsr expand_line
	moveq #1,d0			; button number
	lea pad(pc),a0
	cmp.b #'[',(a0)
	beq.s .ok
	move.b (a0)+,d0
	sub.b #'0',d0
	addq.l #1,a0
.ok:
	move d0,fa_int
	bsr alert
	lea mem(pc),a0
	bsr int_to_str
	moveq #1,d0
	move d0,fa_int
	rts
	
ordre3:
	dc.l ordre4
	dc.b 4,"exec",0
_exec:
	bsr expand_line	; copie vers PAD
	lea pad(pc),a0
	lea pad3(pc),a1
	clr (a1)				; path vide
	lea pad2(pc),a1
.lb1:
	move.b (a0)+,d0	; copies the name
	cmp.b #33,d0
	bmi.s .lb2
	cmp.b #'(',d0
	bne.s .lb11
	bsr .yaunpath
	bra.s .lb1
.lb11:
	move.b d0,(a1)+
	bra.s .lb1
.lb2:
	clr.b (a1)			; a1 pointe sur un zero (ligne de commande par defaut)
	subq.l #1,a0		; back
.lb3:
	move.b (a0)+,d0
	beq.s .exec
	cmp.b #33,d0
	bmi.s .lb3
	lea -2(a0),a1		; else, new start of CMD line
	clr.b (a1)
.lb4:
	tst.b (a0)+
	bne.s .lb4			; til the end
	sub.l a1,a0
	move.l a0,d0
	subq #2,d0
	move.b d0,(a1)
.exec:
	bsr test_extension	; pour les liens!!!
	bne.s .fin			; ex‚cute par un autre lien
	pea pad3(pc)
	move.l a1,-(sp)	; cmd line
	pea pad2(pc)		; name
	clr -(sp)
	GEMDOS 75,16
	ext.l d0
	lea mem(pc),a0		; first MEM
	bsr int_to_str
.fin:
	rts	
.yaunpath:
	move.l a1,-(sp)
	lea pad3(pc),a1
	move.l #'PATH',(a1)+
	move #$3d00,(a1)+		; "PATH=",0
.cpypath:
	move.b (a0)+,d0
	cmp.b #')',d0
	beq.s .okk
	move.b d0,(a1)+
	bra.s .cpypath
.okk:
	clr (a1)+
	st (a1)+
	move.l (sp)+,a1
	rts

ordre4:
	dc.l ordre5
	dc.b 7,"setpath"
	bsr expand_line
	lea pad(pc),a0
	move.l a0,a3
	cmp.b #":",1(a0)	; un lecteur sp‚cifi‚?
	bne.s .path
	move.b (a0),d0	; le lecteur
	and.w #$DF,d0		; en majuscules
	sub.b #'A',d0
	lea 2(a0),a3		; d‚but chaine chemin
	move d0,-(sp)
	GEMDOS 14,4
.path:
	move.l a3,-(sp)
	GEMDOS 59,6
	rts

ordre5:
	dc.l ordre6
	dc.b 4,"menu",0
	bsr expand_line
	move.l savestack(pc),a7
	lea pad(pc),a0
	move.l a0,a6		; start of filename
	cmp.b #'*',(a6)
	bne autre_menu		; normal
	addq.l #1,a6		; else skip '*'
	sf exec_auto		; and don't execute AUTO section
	bra autre_menu
	
fileselect: dc.l fi_cont,global,dum,dum,fi_addrin,dum
fi_cont: dc.w 91,0,2,3,0
fi_addrin: dc.l mem,mem+256,mem+512

ordre6:
	dc.l ordre7
	dc.b 6,"select",0
	bsr expand_line
	lea pad(pc),a0
	lea mem(pc),a1
.lb1:
	move.b (a0)+,d0
	cmp.b #",",d0
	beq.s .lb2
	move.b d0,(a1)+
	bra.s .lb1
.lb2:
	clr.b (a1)
	lea mem+256(pc),a1
.lb3:
	move.b (a0)+,d0
	cmp.b #",",d0
	beq.s .lb4
	move.b d0,(a1)+
	bra.s .lb3
.lb4:
	clr.b (a1)
	lea fi_addrin+8(pc),a1
	move.l a0,(a1)
	GEM_AES fileselect
	lea dum(pc),a0
	tst (a0)+		; erreur?
	beq .quit
	tst (a0)			; annule?
	beq .quit
	lea fi_addrin(pc),a1
	move.l (a1)+,a0					; chemin
	move.l (a1),a3						; name
	lea mem+512(pc),a1				; full
	move.l a1,a2						; will keep the last '\' position
.lb5:
	move.b (a0)+,d0					; a byte from path...
	beq.s .copy_name					; it's the end of the path
	move.b d0,(a1)+					; ...to full
	cmp.b #'\',d0
	bne.s .lb5
	move.l a1,a2						; if '\', updates A2
	bra.s .lb5
.copy_name:
	sub.l a2,a1
	sub.l a1,a0							; last '\' in path
	clr.b -1(a0)
.lb6:
	move.b (a3)+,(a2)+				; copies after the last '\'
	bne.s .lb6							; til the end of the string
	rts	
.quit:
	lea .fin(pc),a5
	rts
.fin: dc.b "*",13	

ordre7:
	dc.l ordre8
	dc.b 9,"copyright"
	lea .copy(pc),a0
	bsr lang_adr_a0
	bsr alert
	rts
.copy: dc.l .fr,.en,.it,.cz,.pl,.sw,.es

.fr: dc.b "[1][ PROGDESK: Shell programmable | Version "
	VERSION
	dc.b " | | (c) 1998-18 | guillaume.tello@orange.fr"
	dc.b " ][Confirmer]",0
.en: dc.b "[1][ PROGDESK: Programmable Shell | Version "
	VERSION
	dc.b " | | (c) 1998-18 | guillaume.tello@orange.fr"
	dc.b " ][ Ok ]",0
.it: dc.b "[1][ PROGDESK: Shell Programmabile| Versione "
	VERSION
	dc.b " | | (c) 1998-18 | guillaume.tello@orange.fr"
	dc.b " ][ Ok ]",0
.cz: dc.b "[1][ PROGDESK Programovatelny Shell | Verze "
	VERSION
	dc.b " | | (c) 1998-18 | guillaume.tello@orange.fr"
	dc.b " ][ Ok ]",0
.pl: dc.b "[1][ PROGDESK: Programowalny Shell | Wersja "
	VERSION
	dc.b " | | (c) 1998-18 | guillaume.tello@orange.fr"
	dc.b " ][ Ok ]",0
.sw: dc.b "[1][ PROGDESK: Programmerbart Skal | Version "
	VERSION
	dc.b " | | (c) 1998-18 | guillaume.tello@orange.fr"
	dc.b " ][ Ok ]",0
.es: dc.b "[1][ PROGDESK: Interfaz programable | Versi¢n "
	VERSION
	dc.b " | | (c) 1998-18 | guillaume.tello@orange.fr"
	dc.b " ][ Ok ]",0

	even

ordre8:
	dc.l ordre9
	dc.b 5,"input"
.lb0:
	lea cancel_list(pc),a0
	bsr lang_adr_a0
	move.l a0,input_cancel
	lea ok_list(pc),a0
	bsr lang_adr_a0
	move.l a0,input_ok
	cmp.b #"%",(a5)+
	bne.s .lb0
	moveq #0,d0
	move.b (a5)+,d0
	sub.b #"0",d0
	lsl.w #8,d0
	lea mem(pc),a0
	add.w d0,a0			; bonne variable
	move.l a0,tedinfo
	addq.l #1,a5		; saute la virgule
	bsr expand_line
	lea pad(pc),a0
	moveq #0,d0
	moveq #0,d1
.lb1:
	move.b (a0)+,d1
	cmp.b #",",d1
	beq.s .lb2
	sub.b #"0",d1
	muls #10,d0
	add d1,d0
	bra.s .lb1
.lb2:
	lea tedinfo(pc),a1
	move.l (a1),a2
	clr.b 0(a2,d0.w)	; force la fin de chaine pour ne pas d‚passer
	move d0,d1
	addq #1,d1
	move d1,24(a1)
	move d1,26(a1)
	lea pad2(pc),a1
	lea 128(a1),a2
	subq #2,d1
.lb3:
	move.b #"_",(a1)+
	move.b #"X",(a2)+
	dbf d1,.lb3
	clr.b (a1)
	clr.b (a2)
	lea input(pc),a1
	move.l a0,24+12(a1)		; string adr
	move d0,d1
	move charw(pc),d2
	muls d2,d1
	move d1,48+20(a1)			; largeur ftext
	move.l a0,d1
.lb4:
	tst.b (a0)+
	bne.s .lb4
	sub.l d1,a0
	subq.l #1,a0				; taille STRING
	move a0,d1
	muls d2,d1
	move d1,24+20(a1)			; largeur STRING
	cmp a0,d0
	bpl.s .lb5
	move a0,d0					; sup(ftext,string)
.lb5:
	addq #3,d0
	move d0,d1
	muls d2,d1
	move d1,72+16(a1)			; X bouton annule
	move d1,96+16(a1)			; X bouton Confirmer
	addq #8,d0
	addq #2,d0
	muls d2,d0
	move d0,20(a1)				; largeur BOX	
	move screenw(pc),d1
	sub d0,d1
	lsr d1						; X BOX
	move d1,16(a1)
	move screenh(pc),d1
	sub 22(a1),d1
	lsr d1						; Y box
	move d1,18(a1)	
	lea fdial_int+10(pc),a0
	clr -10(a0)					; reserve
	move.l 16(a1),(a0)+
	move.l 20(a1),(a0)
	GEM_AES form_dial
	GEM_AES objc_draw
	GEM_AES form_do
	move dum,d3
	moveq #24,d0
	muls d3,d0
	lea input(pc),a0
	bclr #0,11(a0,d0)			; bouton redevenu blanc
	move #3,fdial_int
	GEM_AES form_dial
	cmp #3,d3
	beq.s .annule
	rts
.annule:
	lea .truc(pc),a5
	rts
.truc: dc.b "*",13

ordre9:
	dc.l ordre10
	dc.b 4,"save",0
	move.l #$0040003C,d7	; fwrite et fcreate
_load_save:
	cmp.b #"%",(a5)+
	bne.s _load_save
	moveq #0,d5			; masque
.lb1:
	move.b (a5)+,d0
	cmp.b #",",d0
	beq.s .lb2
	sub.b #"0",d0
	bset d0,d5
	bra.s .lb1
.lb2:
	bsr expand_line
	clr -(sp)
	pea pad(pc)
	move d7,-(sp)
	trap #1				; fcreate ou fopen
	addq.l #8,sp
	move d0,d3			; handle
	bmi.s .fin
	lea mem(pc),a3
	moveq #MEM-1,d4
	swap d7
	moveq #1,d6
	lsl.l #8,d6			; 256.L
.lb3:
	ror d5
	bpl.s .lb4			; pas a sauver
	pea (a3)
	move.l d6,-(sp)
	move d3,-(sp)
	move d7,-(sp)
	trap #1				; fread ou fwrite
	add #12,sp
.lb4:
	add d6,a3
	dbf d4,.lb3
	move d3,-(sp)
	GEMDOS 62,4
.fin:
	rts
	
ordre10:
	dc.l ordre11
	dc.b 4,"load",0
	move.l #$003f003d,d7	; fread et fopen
	bra _load_save
	rts

ordre11:
	dc.l ordre12
	dc.b 6,"cutext",0
.lb0:
	cmp.b #"%",(a5)+
	bne.s .lb0
	moveq #0,d0
	move.b (a5)+,d0
	sub #'0',d0
	lsl #8,d0
	lea mem(pc),a0
	add d0,a0
	move.l a0,a1
.lb1:
	tst.b (a0)+
	bne.s .lb1
	subq.l #1,a0
	moveq #3,d0
.lb2:
	cmp.l a0,a1
	bpl.s .fin
	move.b -(a0),d1
	cmp.b #"\",d1
	beq.s .fin
	cmp.b #":",d1
	beq.s .fin
	cmp.b #".",d1
	bne.s .boucle
	clr.b (a0)
.fin:
	rts
.boucle:
	dbf d0,.lb2
	rts

ordre12:
	dc.l ordre13
	dc.b 5,"label"
_label:
	bsr expand_line
	lea pad(pc),a0
	bsr.s long_a0
	lea labels(pc),a0
	move.l lab_ptr(pc),a1
.lb1:
	cmp.l a0,a1
	beq.s .non_present
	cmp -(a1),d0
	beq.s .trouve
	subq.l #4,a1
	bra.s .lb1
.trouve:				; ce label existe deja, on le modifie!!!
	move.l a5,-(a1)
	rts
.non_present:
	move.l lab_ptr(pc),a1
	move.l a5,(a1)+		; nouvelle adresse
	move d0,(a1)+			; nouvelle valeur
	move.l a1,lab_ptr
	rts		

long_a0:
	moveq #0,d0
	moveq #0,d1
	move.b (a0)+,d1
	moveq #0,d2
	cmp.b #'+',d1
	beq.s .lb0
	cmp.b #'-',d1
	seq d2
	bne.s .first
.lb0:
	move.b (a0)+,d1
.first:
	sub.b #'0',d1
	bmi.s .fin
	cmp.b #10,d1
	bpl.s .fin
	add.l d0,d0		; * 2
	move.l d0,d3
 	add.l d0,d0		; *4
 	add.l d0,d0		; *8
 	add.l d3,d0		; *10 !
	add.l d1,d0
	bra.s .lb0
.fin:
	tst.b d2
	beq.s .positif
	neg.l d0
.positif:
	rts
	
ordre13:
	dc.l ordre14
	dc.b 4,"goto",0
	bsr expand_line
	lea pad(pc),a0
_goto:
	bsr.s long_a0
	move d0,.temp
	lea labels(pc),a0
	move.l lab_ptr(pc),a1
.cherche:
	cmp.l a0,a1
	beq.s .non
	cmp -(a1),d0
	beq.s .trouve
	subq.l #4,a1
	bra.s .cherche
.trouve:
	move.l -(a1),a5
	rts
.temp: dc.w 0
.zut:
	subq.l #1,a5		; revient sur "*" ou autre fin
	rts
.non:
	bsr find_cmd		; nouvelle commande
	bmi.s .zut
	cmp.b #5,d0			; 5 caractŠres?
	bne.s .non			; passer, ce n'est pas un label
	cmp.l #'labe',(a0)
	bne.s .non			; non plus!
	cmp.b #'l',4(a0)
	bne.s .non
	bsr _label			; ajoute !
	move.l lab_ptr(pc),a0
	move .temp(pc),d0	; la valeur voulue
	cmp -(a0),d0		; est-ce le bon?
	bne.s .non			; non!!!
	move.l -(a0),a5	; sinon, on a l'adresse!
	rts
	
ordre14:
	dc.l ordre15
	dc.b 2,"if",0
	bsr expand_line
	lea pad(pc),a0
	move.b (a0)+,d1
	cmp.b #"(",d1
	beq.s .valeurs
	move.l a0,a1		; premiŠre chaine
.fin_ch1:
	cmp.b #'"',(a0)+
	bne.s .fin_ch1
	clr.b -1(a0)		; fin chaine 1
	move.b (a0)+,d6	; op‚rateur
	addq.l #1,a0		; saute "
	move.l a0,a2		; d‚but chaine 2
.fin_ch2:
	cmp.b #'"',(a0)+	
	bne.s .fin_ch2
	clr.b -1(a0)
	moveq #0,d7
	moveq #0,d0
.cmp_chaines:
	move.b (a1)+,d7
	move.b (a2)+,d0
	beq.s .fin_comp
	tst.b d7
	beq.s .fin_comp
	cmp.b d7,d0
	beq.s .cmp_chaines
.valeurs:
	bsr long_a0
	move.l d0,d7
	move.b (a0)+,d6	; op‚rateur
	addq.l #1,a0		; saute la parenthese
	bsr long_a0
.fin_comp:
	cmp.b #"=",d6
	bne.s .v1
	cmp.l d7,d0
	beq.s .saut
	rts
.v1:
	cmp.b #"<",d6
	bne.s .v2
	cmp.l d0,d7
	bmi.s .saut
	rts
.v2:
	cmp.b #">",d6
	bne.s .v3
	cmp.l d0,d7
	bgt.s .saut
	rts
.v3:
	cmp.b #'#',d6
	bne.s .v4
	cmp.l d7,d0
	bne.s .saut
	rts
.v4:
	rts
.saut:
	cmp.b #33,(a0)+
	bmi.s .saut
	subq.l #1,a0
	bra _goto
	
ordre15:
	dc.l ordre16
	dc.b 6,"redraw",0
	lea wg_out+2(pc),a0
	lea fd_int+2(pc),a1
	move #3,-10(a1)		; free space
	move.l (a0)+,(a1)+	; whole screen
	move.l (a0),(a1)
	GEM_AES form_dial
	rts
	
ordre16:
	dc.l ordre17
	dc.b 3,"tos"
	lea gm_int(pc),a0
	move #256,(a0)
	GEM_AES graf_mouse
	pea .efface(pc)
	GEMDOS 9,6
	bsr _exec
	pea .fin(pc)
	GEMDOS 9,6
	lea gm_int(pc),a0
	move #257,(a0)
	GEM_AES graf_mouse
	rts
.efface: dc.b 27,"E",27,"e",0
.fin: dc.b 27,"f",0
	even


ordre17:
	dc.l ordre18
	dc.b 5,"mouse"
	bsr expand_line
	lea pad(pc),a0
	bsr long_a0
	lea gm_int(pc),a0
	move d0,(a0)
	GEM_AES graf_mouse
	rts

ordre18:
	dc.l ordre19
	dc.b 5,"pause"
	move.l #$20002,-(sp)
	trap #13
	addq.l #4,sp
	rts
	
ordre19:
	dc.l ordre20
	dc.b 8,"language",0
	bsr expand_line
	lea pad(pc),a0
	bsr long_a0
	tst.l d0
	bpl.s .lb0
	moveq #0,d0
.lb0:
	cmp.l #MAXLANG,d0
	bmi.s setlanguage
	moveq #0,d0
setlanguage:
	move.l d0,lang
	lea mem+256*10(pc),a0		; into special memory %:
	bsr int_to_str
	rts
	
ordre20:
	dc.l ordre21
	dc.b 10,"starttimer",0
	pea get_time(pc)
	XBIOS 38,6
	move.l current_time,start_time
	rts
	
get_time:
	move.l $4ba.w,current_time
	rts
	
ordre21:
	dc.l ordre22
	dc.b 8,"gettimer",0
	pea get_time(pc)
	XBIOS 38,6
.lb0:
	cmp.b #"%",(a5)+
	bne.s .lb0
	moveq #0,d0
	move.b (a5)+,d0
	sub #'0',d0
	lsl #8,d0
	lea mem(pc),a0
	add d0,a0
	move.l current_time,d0
	sub.l start_time,d0
	lsr.l #1,d0				; 1/100 sec
	cmp.l #360000,d0		; >= 1h ?
	bmi.s .lb1
	moveq #-1,d1
.lb2:
	addq.l #1,d1
	sub.l #3600000,d0		; 10 h
	bpl.s .lb2
	add.l #3600000,d0
	tst.l d1
	beq.s .lb3
	add.b #'0',d1
	move.b d1,(a0)+
.lb3:
	moveq #-1,d1
.lb4:
	addq.l #1,d1
	sub.l #360000,d0		; 1 h
	bpl.s .lb4
	add.l #360000,d0
	add.b #'0',d1
	move.b d1,(a0)+
	move.b #'h',(a0)+		; hours stored!
.lb1:
	moveq #-1,d1
	cmp.l #6000,d0			; > 1 min
	bmi.s .lb5				; no, skip minutes
.lb6:
	addq.l #1,d1
	sub.l #60000,d0		; 10 min
	bpl.s .lb6
	add.l #60000,d0
	tst.l d1
	beq.s .lb7
	add.b #'0',d1
	move.b d1,(a0)+
.lb7:
	moveq #-1,d1
.lb8:
	addq.l #1,d1
	sub.l #6000,d0		; 1 min
	bpl.s .lb8
	add.l #6000,d0
	add.b #'0',d1
	move.b d1,(a0)+
	move.b #"'",(a0)+		; minutes stored!
.lb5:
	divs #10,d0
	move.l d0,d1
	ext.l d0
	divs #10,d0
	swap d0
	move d0,d1			; d1 = centiŠmes.w dixiŠmes.w
	swap d0
	ext.l d0
	divs #10,d0			; d1 = unit‚s.w dizaines.w
	beq.s .lb9			; pas de dizaines
	add.b #'0',d0
	move.b d0,(a0)+	; dizaines
.lb9:
	swap d0
	add.b #'0',d0
	move.b d0,(a0)+	; unit‚s
	tst.l d1
	beq.s .lb10			; pas de centiŠmes
	move.b #',',(a0)+	; comma
	add.b #'0',d1
	move.b d1,(a0)+
	swap d1
	tst.w d1
	beq.s .lb10
	add.b #'0',d1
	move.b d1,(a0)+	
.lb10:
	move.b #'"',(a0)+
	clr.b (a0)
	rts
	
ordre22:
	dc.l 0
	dc.b 8,"setflags",0
	bsr expand_line
	lea pad(pc),a0			; start of file path-name
	move.l a0,a1
.lb0:
	move.b (a0)+,d0
	cmp.b #33,d0
	bpl.s .lb0
	clr.b -1(a0)	
	bsr long_a0
	move.l d0,.buf
	
	move #2,-(sp)
	pea (a1)
	GEMDOS 61,8			; fopen
	move.l d0,d3
	bmi.s .erreur
	
	clr -(sp)
	move d3,-(sp)
	move.l #$16,-(sp)	;fseek to flags
	GEMDOS 66,10
	
	cmp.l #$16,d0
	bne.s .erreur
	
	pea .buf(pc)
	move.l #4,-(sp)
	move d3,-(sp)
	GEMDOS 64,12		; fwrite 4 bytes
	
	move d3,-(sp)
	GEMDOS 62,4			; fclose
	rts
.buf: dc.l 0
.erreur:
	lea .file_error(pc),a0
	bsr lang_adr_a0
	bsr alert
	rts
.file_error: dc.l .fr,.en,.it,.cz,.pl,.sw,.es
.fr: dc.b "[3][ Erreur fichier ! ][Annuler]",0
.en: dc.b "[3][ File error ! ][Cancel]",0
.it: dc.b "[3][ File error ! ][Annulla]",0
.cz: dc.b "[3][ Chyba souboru ! ][Zrusit]",0
.pl: dc.b "[3][ Blad pliku ! ][Odrzuc]",0
.sw: dc.b "[3][ Filen „r felaktig | eller skadad! ][Avbryt]",0
.es: dc.b "[3][ ­Error de archivo! ][Cancelar]",0
	even
	
lang_adr_a0:
	add.l lang(pc),a0
	add.l lang(pc),a0
	add.l lang(pc),a0
	add.l lang(pc),a0
	move.l (a0),a0
	rts	
		
form_dial: dc.l fdial_cont,global,fdial_int,dum,dum,dum
fdial_cont: dc.w 51,9,1,0,0
fdial_int: dc.w 0,0,0
ob_int: dc.w 0
fd_int: dc.w 2,1,1,1,1


count_ext:
	move.b (a0)+,d0
	cmp.b #13,d0
	beq.s .fin
	cmp.b #10,d0
	beq.s .fin
	cmp.b #",",d0
	bne.s count_ext
	addq #1,d7
	bra.s count_ext
.fin:
	addq #1,d7
	rts

objc_draw: dc.l od_cont,global,ob_int,dum,ob_addrin,dum
od_cont: dc.w 42,6,1,1,0
ob_addrin: dc.l input

treat_new_ext:
	move.l a0,a1
.lb0:
	move.b (a1)+,d0
	cmp.b #13,d0
	beq.s .found
	cmp.b #10,d0
	bne.s .lb0
.found:
	cmp.b #33,(a1)+
	bmi.s .found
	subq.l #1,a1		; start of command line
	move.l a1,d1		; saved
	move.l ext_ptr(pc),a1	; new extension
.lb1:
	cmp.b #33,(a0)+
	bmi.s .lb1
	subq.l #1,a0
.autre:
	moveq #0,d0
.lb2:
	move.b (a0)+,d0
	cmp.b #',',d0
	beq.s .ok
	cmp.b #13,d0
	beq.s .last
	cmp.b #10,d0
	beq.s .last
	lsl.l #8,d0
	bra.s .lb2
.ok:
	lsr.l #8,d0
	or.l #$00202020,d0	; en minuscules
	move.l d0,(a1)+
	move.l d1,(a1)+
	bra.s .autre
.last:
	lsr.l #8,d0
	or.l #$00202020,d0	; en minuscules
	move.l d0,(a1)+
	move.l d1,(a1)+
	clr.l (a1)
	move.l a1,ext_ptr
	rts

form_do: dc.l fd_cont,global,fd_int,dum,ob_addrin,dum
fd_cont: dc.w 50,1,1,1,0

test_extension:
	lea pad2(pc),a0
.lb0:
	move.b (a0)+,d0
	beq.s .rien
	cmp.b #".",d0
	bne.s .lb0
	moveq #0,d0
.lb1:
	move.b (a0)+,d0
	beq.s .ok
	cmp.b #"\",d0
	beq.s .lb0
	lsl.l #8,d0
	bra.s .lb1
.ok:
	lsr.l #8,d0
	beq.s .rien
	or.l #$00202020,d0	; en minuscules
	move.l ext_adr(pc),a0	; table d'equivalences
.lb2:
	move.l (a0),d1			; extension connue
	beq.s .rien				; fin de table!!!
	addq.l #8,a0
	bsr.s compare_ext
	bne.s .lb2
	move.l a5,-(sp)		; sauve le pointeur d'interpr‚tation
	move.l -(a0),a5		; nouveau pointeur
	lea mem(pc),a0			; variable 0
	lea pad2(pc),a2		; le nom
.copy_nom:
	move.b (a2)+,(a0)+
	bne.s .copy_nom
	moveq #0,d0
	move.b (a1)+,d0		; taille ancienne ligne de commande
	lea mem+256(pc),a0	; memoire 1
	bra.s .loop
.copy_cmd:
	move.b (a1)+,(a0)+
.loop:
	dbf d0,.copy_cmd
	clr.b (a0)
	bsr interprete			; et relance le tout!
	move.l (sp)+,a5		; recupere A5
	moveq #1,d0				; ne pas ex‚cuter
	rts
.rien:
	moveq #0,d0				; ex‚cuter
	rts	
compare_ext:
	moveq #2,d2				; trois fois!
	move.l d0,d3
.c1:
	cmp.b #"$",d1
	beq.s .voir_lettre
	cmp.b #"#",d1
	beq.s .voir_chiffre
	cmp.b #"?",d1
	beq.s .c2
	cmp.b d3,d1
	bne.s .rate
	bra.s .c2
.voir_chiffre:
	cmp.b #"0",d3
	bmi.s .rate
	cmp.b #"9"+1,d3
	bpl.s .rate
	bra.s .c2
.voir_lettre:
	cmp.b #"a",d3
	bmi.s .rate
	cmp.b #"z"+1,d3
	bpl.s .rate
.c2:
	lsr.l #8,d3
	lsr.l #8,d1		; caractere suivant
	dbf d2,.c1
	moveq #0,d2		; renvoit EQ
	rts
.rate:
	rts


; D0=index GEM
; retour D0=index chaine

strindex:
  lea indextab(pc),a0
  lea 1(a0),a1
.lb0: cmp.b (a0)+,d0
  beq.s .fin
  bpl.s .lb0
.fin: sub.l a1,a0
  move.l a0,d0
  rts
  
  data

obdata: dc.l 0
obptr:  dc.l 0
tedata: dc.l 0
imagedat: dc.l 0
obindex: dc.w 0
pereindex: dc.w 0
pereadr: dc.l 0
large: dc.w 1
haut: dc.w 1

	bss

lang: ds.l 1		; default is french
current_time: ds.l 1
start_time: ds.l 1
aes_buffer: ds.w 8
ext_adr: ds.l 1
ext_ptr: ds.l 1

vu_menu: ds.b 1	; byte!!
is_default: ds.b 1
exec_auto: ds.b 1

	even
	
fa_addrin: ds.l 1
tree: ds.l 1
fin_tab: ds.l 1
menu_adr: ds.l 1
menu_size: ds.l 1
dum: ds.l 4
global: ds.w 15
dta: ds.b 44
savestack: ds.l 1
basepage: ds.l 1
auto_adr: ds.l 1
inf_adr: ds.l 1
table_adr: ds.l 1
indexadr: ds.l 1
indextab: ds.b 128
pad3: ds.b 256		; pour le PATH=
pad: ds.b 256
pad2: ds.b 256
mem: ds.b 256*MEM	; variables %0 … %9 et %:, 255 caractŠres chacune

	; ne pas separer
labels: ds.b 6*20	; adresse.l + valeur.w
lab_ptr: ds.l 1

	end