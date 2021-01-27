; wdial_create:
; entr‚e = A0 = adresse de l'arbre
; sortie = A0 = pointeur vers structure
; utilise A3,D7

; wdial_open:
; entr‚e : A0 = adresse structure
;			  A1 = adresse chaine
;			  D0 = index champ FTEXT
; sortie	: D7 = handle fenetre

; wdial_close:
; entree: A0 : adresse structure
; utilise A3,D3

; wdial_change:
; entree: A3 : structure
;			 D6 : index objet a modifier
; 			 D0 : 1 pour enlever l'‚tat SELECTED
;			      0 juste pour le redessiner si il a chang‚

; wdial_evnt:
; entree D0: si > 0, temps … attendre
;		   D0 = 0 si pas d'evenement TIMER
; en sortie D0 = 0 si pas d'evenement TIMER, -1 si TIMER

; wdial_formdo:
; renvoit D0 :	0: rien … faire
;		ou  D0 : 1: AC_OPEN, r‚veiller une fenetre.
;		ou	 D0 : $FF
;		    A3 : structure
;			 D7 ; bouton Exit si>0 ou -1 pour fermer la fenetre

__GEM_AES MACRO
   move.l #\1,d1
   move.l #$c8,d0
   trap #2
   ENDM

	text

; entree: D7 = handle
;			 A0 = pointe sur x,y,l,h

set_redraw:
	lea redrawdat,a1
	ext.l d7			; 0.w pour first rectangle + handle.w
	move.l d7,(a1)+
	move.l (a0)+,(a1)+	; x,y
	move.l (a0),(a1)	; l,h
	rts

winup_on:
	move #1,wu_int
	__GEM_AES wind_update
	move #3,wu_int
	__GEM_AES wind_update
	addq #1,winup
	rts

winup_off:
	move #2,wu_int
	__GEM_AES wind_update
	move #0,wu_int
	__GEM_AES wind_update  ; libŠre l'‚cran
	subq #1,winup
	bpl.s .fin
	clr winup		; erreur normalement! mais bon...
.fin:
	rts

winup_clear:
	tst winup
	beq.s .fin
	bsr.s winup_off
	bra.s winup_clear
.fin:
	rts

_redraw:
   moveq #12,d7      ; next par d‚faut
	lea redrawdat,a3
	tst (a3)+
	beq.s .premier      ; premier appel
	bpl .suivant      ; appel normal
	moveq #0,d4			; si c'est n‚gatif, il n'y a d‚j… plus de rectangles!
	rts
.premier:
	bsr winup_on
	move #256,wc_in
	__GEM_AES .graf_mouse
	move #1,-2(a3)    ; ce n'est plus le premier appel
	addq.l #2,a3
	move.l (a3)+,d0   ; x et y
	sub.l #$10001,d0  ; pour faire joli
	add.l d0,(a3)     ; remplace l et h par x' et y' (fastoche)
	subq.l #6,a3     ; revient sur handle
	lea .wg_int,a0
	move (a3)+,(a0)+
	move #4,(a0)
	__GEM_AES .wind_get0 ; work_area pour limiter les valeurs de set_redraw
	lea .wg_out+2,a0
	movem.w (a0)+,d0-d3
	cmp (a3)+,d0
	bmi.s .g0
	move d0,-2(a3)
.g0:
	cmp (a3)+,d1
	bmi.s .g1
	move d1,-2(a3)
.g1:
	subq #1,d0
	add d0,d2
	cmp (a3)+,d2
	bpl.s .g2
	move d2,-2(a3)
.g2:
	subq #1,d1
	add d1,d3
	cmp (a3),d3
	bpl.s .g3
	move d3,(a3)
.g3:
	subq.l #8,a3     ; retour sur le handle
	moveq #11,d7      ; premier rectangle
.suivant:
	lea .wg_int,a0
	move (a3)+,(a0)+  ; le handle
	move d7,(a0)      ; first ou next
	__GEM_AES .wind_get0 ; le rectangle
	moveq #12,d7      ; si il y en a un autre, plus le premier
   lea .wg_out,a0
   tst (a0)+
   beq.s .dernier      ; si 0, une erreur, on arrˆte l…!
   tst.l 4(a0)       ; l et h
   beq.s .dernier      ; si nuls, il n'y a plus de rectangles
   moveq #0,d3
   move (a0)+,d3     ; x
   add d3,2(a0)      ; l+x
   cmp (a3)+,d3
   bpl.s .lb0
   move -2(a3),d3
.lb0:
	moveq #0,d2
	move (a0)+,d2     ; y
	add d2,2(a0)      ; h+y
	cmp (a3)+,d2
	bpl.s .lb1
	move -2(a3),d2
.lb1
	sub.l #$10001,(a0)
	moveq #0,d1
	move (a0)+,d1     ; x'
	cmp (a3)+,d1
	bmi.s .lb2
	move -2(a3),d1
.lb2:
	moveq #0,d0
	move (a0)+,d0 		; y'
	cmp (a3)+,d0
	bmi.s .lb3
	move -2(a3),d0
.lb3:
	lea -10(a3),a3    ; revient sur la handle
	cmp d3,d1
	bmi.s .suivant      ; pas d'intersection car x'<x
	cmp d2,d0
	bmi.s .suivant      ; meme chose, y'<y
							; sinon donne x y x' y' dans d3-d2-d1-d0
	moveq #1,d4			; et le flag 1, rectangle correct
   bra.s .fin
.dernier:
	bsr winup_off
	move #257,wc_in
	__GEM_AES .graf_mouse
	move #-1,redrawdat   ; c'est fini
	moveq #0,d4
.fin:
	moveq #4,d7
	move.l d7,.wg_int     ; wind_get normal pour fastopen
	rts
.graf_mouse: dc.l .gm_cont,global,wc_in,dum,dum,dum
.gm_cont: dc.w 78,1,1,1,0
.wind_get0: dc.l wg_cont,global,.wg_int,.wg_out,dum,dum
.wg_int: dc.w 0,4
.wg_out: dc.w 0,0,0,0,0
.maxi_xylh: dc.w 0,0,0,0

wind_update: dc.l wu_cont,global,wu_int,dum,dum,dum
wu_cont: dc.w 107,1,1,0,0
wu_int: dc.w 0

; entr‚e = A0 = adresse de l'arbre
; sortie = A0 = pointeur vers structure
; structure: +0 LONG adresse arbre
;				+ 4 word x,y,l,h coordonn‚es internes				
;				+12 word x,y,l,h coordonn‚es externes
;				+20 word handle fenetre ou z‚ro si pas ouverte
;				+22 pointeurs champ d'‚dition
;				+26 zone pour wdial_open
;				+32 ...fin...

wdial_create:
	move.l wd_ptr,a3		; nouvelle structure
	moveq #0,d7				; pas d'offset
	move.l a0,(a3)+		; range l'adresse
;	btst #4,11(a0)			; bit OUTLINED
;	beq.s .lb2
;	move.l #$30003,d7		; taille de la bordure
.lb2:
	move.l a0,fc_addrin
	__GEM_AES .wd_form_center
	lea fc_out+2,a0
	move.l (a0)+,(a3)+
	move.l (a0),(a3)+		; les coordonn‚es internes
	lea wc_in,a0
	clr (a0)+				; calculer l'ext‚rieur
	move #11,(a0)+			; TITLE, MOVER, CLOSER
	sub.l d7,(a0)+			; oter la bordure … X et Y
	add.l d7,d7				; la doubler en largeur et hauteur
	add.l d7,(a0)
	__GEM_AES .wd_wind_calc
	lea fc_out2+2,a0
	move.l (a0)+,(a3)+
	move.l (a0),(a3)+		; taille totale de la fenˆtre
	clr (a3)+				; handle … 0
	clr.l (a3)+				; les pointeur du champ d'‚dition … 0
	addq.l #6,a3			; zone pour wdial_open
	move.l a3,wd_ptr		; met a jour
	lea -32(a3),a0			; renvoit l'adresse
	rts
.wd_wind_calc: dc.l .wca_cont,global,wc_in,fc_out2,dum,dum
.wca_cont: dc.w 108,6,5,0,0
.wd_form_center: dc.l .fc_cont,global,dum,fc_out,fc_addrin,dum
.fc_cont: dc.w 54,0,5,1,0

; entr‚e : A0 = adresse structure
;			  A1 = adresse chaine titre
;			  D0 = index champ FTEXT
; sortie	: D7 = handle fenetre

wdial_open:
	sf acc_close
	move.l a0,a3
	move.l a1,26(a3)
	move d0,30(a3)		; pour tout … l'heure
	move 20(a3),d7
	beq.s .premier
	lea wc_in,a0
	move d7,(a0)+
	move #10,(a0)+
	move d7,(a0)
	__GEM_AES wd_wind_set
	ext.l d7
	bra .fin
.premier:
	lea fc_out,a0
	move #11,(a0)+		; mover, closer, title
	move.l 12(a3),(a0)+
	move.l 16(a3),(a0)	; x,y,l,h
	__GEM_AES .wd_wind_create
	move wc_in,d7
	ext.l d7
	bmi .fin
.table:
	lea wd_table,a0
.lb1:
	tst.l (a0)+			; cherche une place libre
	bne.s .lb1
	move.l a3,-(a0)	; ajoute cette structure dans la table
	move d7,20(a3)		; sauve le handle
	moveq #0,d1
	move.l 26(a3),d0	; chaine de titre
	move 30(a3),d1		; index edit
	move d1,22(a3)
	move.l (a3),a0		; arbre
	muls #24,d1
	add.l d1,a0
	btst #3,9(a0)		; objet ‚ditable?
	bne.s .oui
	clr.l 22(a3)
	bra.s .suite
.oui:
	move.l 12(a0),a0	; tedinfo
	move.l (a0),a0			; chaine saisie
	move.l a0,a1
.lb0:
	tst.b (a0)+
	bne.s .lb0
	sub.l a1,a0
	subq.l #1,a0
;	move a0,24(a3)			; position pour l'‚dition
	clr 24(a3)
.suite:
	lea wc_in,a0
	move d7,(a0)+			; handle
	move #2,(a0)+			; set TITLE
	move.l d0,(a0)			; adresse
	__GEM_AES wd_wind_set
	lea fc_out,a0
	move d7,(a0)+
	move.l 12(a3),(a0)+
	move.l 16(a3),(a0)	; x,y,l,h
	__GEM_AES .wd_wind_open
.fin:
	rts
.wd_wind_open: dc.l .wo_cont,global,fc_out,wc_in,dum,dum
.wo_cont: dc.w 101,5,1,0,0
.wd_wind_create: dc.l .wc_cont,global,fc_out,wc_in,dum,dum
.wc_cont: dc.w 100,5,1,0,0

; entree: A0 : adresse structure

wdial_close:
	move.l a0,a3
	move 20(a3),d3			; le handle
	beq.s .fin				; si nul, pas ouvert
	clr 20(a3)				; si on referme, handle nul
	tst.b acc_close
	bne.s .lb0				; si fermeture accessoire, alors pas de wind_close
	
;	btst #0,([kbshift])	; touche shift enfonc‚e?
;	beq.s .notdump
;	bsr dump_screen
;.notdump:	
	move d3,wc_in
	__GEM_AES .wd_wind_close
	move d3,wc_in
	__GEM_AES .wd_wind_delete
.lb0:
	lea wd_table,a0
.lb1:
	cmp.l (a0)+,a3			; recherche dans la table
	bne.s .lb1
	clr.l -(a0)				; et ensuite efface cette adresse
.fin:
   rts
.wd_wind_close: dc.l .wl_cont,global,wc_in,wc_in,dum,dum
.wl_cont: dc.w 102,1,1,0,0
.wd_wind_delete: dc.l .wd_cont,global,wc_in,wc_in,dum,dum
.wd_cont: dc.w 103,1,1,0,0


; renvoit D0 :	0: rien … faire
;		ou	 D0 : $FF
;		    A3 : structure
;			 D7 ; bouton Exit si>0 ou -1 pour fermer la fenetre
;   acc_close:

wdial_formdo:
	lea wd_intout,a5		; intout
	lea wd_buf,a4	   	; le buffer de event-mesag
	movem.l a4-a5,.sauve	; pour un deuxiŠme appel cons‚cutif
.encore:
	sf .flag					; renvoit 0 par d‚faut
	moveq #0,d6
	and #$13,(a5)			; ne garde que MESAG/BUTTON/KEYB
	move (a5)+,d6			; l'‚vŠnement
	bclr #4,d6				; teste si MESAG
	beq .k0
	move d6,-2(a5)			; range l'‚vŠnement avec MESAG en moins
	cmp #41,(a4)			; AC_CLOSE?
	bne.s .lb00
;	move global+4,d7		; appl_id
;	cmp 6(a4),d7			; mon application?
;	bne.s .lb00
	st acc_close			; flag pour fermeture accessoire
	bra .ferme				; oui tout est ok, on ferme.
	dc.b "ICIC"
.lb00:
	cmp #40,(a4)			; AC_OPEN?
	bne.s .lb01
;	move global+4,d7		; appl_id
;	cmp 6(a4),d7			; mon application?
;	bne.s .lb01
	moveq #1,d0
	bra .sortie
.lb01:
	lea wd_table,a0
	move 6(a4),d7			; handle de la fenˆtre concern‚e
	moveq #19,d1			; pour boucler
.lb0:
	tst.l (a0)				; emplacement vide
	beq.s .lb1
	move.l (a0),a3
	cmp 20(a3),d7			; le bon handle?
	beq.s .lb2
.lb1:
	addq.l #4,a0
	dbf d1,.lb0
	bra .k0				; aucun handle ne convient, autre ‚vŠnement
.lb2:
	cmp #20,(a4)			; REDRAW?
	bne .z0
	clr .init_field		; pour le curseur
	tst 22(a3)				; champ ‚ditable?
	beq.s .r0
; a virer????
	lea wc_in,a0
	move d7,(a0)+
	move #10,(a0)
	__GEM_AES wd_wind_get	; fenˆtre au top
	cmp fc_out+2,d7
	bne.s .r0
; ???
	lea 4(a3),a0			; si editable et fenetre au top, tout redessiner
	move #3,.init_field	; ED_END
	bra.s .r1
.r0:
	lea 8(a4),a0			; sinon, prendre les coordonn‚es de event-mesag
.r1:
	bsr set_redraw			; initialise
	move.l (a3),fc_addrin	; arbre pour object_draw
	move.l a3,-(sp)		; utilis‚ dans _redraw!
.r2:
	bsr _redraw
	tst.l d4					; flag renvoy‚
	beq.s .r3					; si 0, c'est la fin
	lea fc_out,a0
	move.l #8,(a0)+
	sub.l d2,d0
	addq #1,d0
	sub.l d3,d1
	addq #1,d1
	move.w d3,(a0)+
	move.w d2,(a0)+
	move d1,(a0)+
	move d0,(a0)
	__GEM_AES .wd_object_draw
	bra.s .r2
.init_field: dc.w 0
.r3:
	move.l (sp)+,a3		; _redraw l'a ‚cras‚!
	tst 22(a3)				; champ ‚ditable?
	beq.s .non
	tst .init_field		; s'occuper du curseur?
	beq.s .non
	move.l (a3),fc_addrin	; l'arbre
	lea fc_out,a0
	move 22(a3),(a0)+			; index ‚ditable
	clr (a0)+					; touche inutile
	move 24(a3),(a0)+			; position
	move .init_field,(a0)	; ED_END
	__GEM_AES .wd_objc_edit
	move fc_out+2,24(a3)		; nouvelle position
.non:
					; renvoit 0, rien … faire!
	bra .fin
.z0:
	cmp #21,(a4)			; WM TOPPED?
	bne.s .z1
	lea wc_in,a0
	move d7,(a0)+
	move #10,(a0)+
	move d7,(a0)
	__GEM_AES wd_wind_set	; top la fenetre D7
	tst 22(a3)				; un champ ‚ditable?
	beq .fin					; renvoit 0
; a virer ????
;	cmp #-1,global+2		; et multitos?
;	bne .fin
; ???
	lea fc_out,a0
	move #3,(a0)+			; FDM_FINISH
	clr.l (a0)+
	clr.l (a0)+
	move.l 4(a3),(a0)+
	move.l 8(a3),(a0)		; coordonn‚es int‚rieures
	__GEM_AES .wd_form_dial
	bra .fin					; renvoit 0
.z1:
	cmp #22,(a4)			; WM CLOSED?
	bne.s .z2
.ferme:
	st .flag
	moveq #-1,d7			; fermer
	bra .fin
.z2:
	cmp #28,(a4)			; WM MOVED?
	bne.s .k0
	lea wc_in,a0
	move d7,(a0)+			; le handle
	move #5,(a0)+			; deplace WF_CURRXYWH
	move.l 8(a4),(a0)+
	move.l 12(a4),(a0)	; x,y,w,h
	__GEM_AES wd_wind_set
	move.l 4(a3),d0		; x,y internes
	sub.l 12(a3),d0		; offset interne/externe
	move.l 8(a4),d1		; nouvelles externes
	move.l d1,12(a3)		; dans la structure
	add.l d0,d1				; nouvelles internes
	move.l d1,4(a3)		; dans la structure...
	move.l (a3),a0			; (l'arbre)
	move.l d1,16(a0)		; ...et comme coordonn‚es du rectangle de l'arbre
	bra .fin					; renvoit 0
.k0:
	bclr #0,d6				; teste si KEYBD
	beq .k1
	move d6,-2(a5)
	tst 8(a5)
	beq .k1					; si touche=0, erreur!
	lea wc_in,a0
	move.l #10,(a0)
	__GEM_AES wd_wind_get	; fenˆtre au top
	move fc_out+2,d7		; son handle
	lea wd_table,a0
	moveq #19,d1			; pour boucler
.lb8:
	tst.l (a0)				; emplacement vide
	beq.s .lb9
	move.l (a0),a3
	cmp 20(a3),d7			; le bon handle?
	beq.s .lb10
.lb9:
	addq.l #4,a0
	dbf d1,.lb8
					; fenetre pas … nous
	bra .fin
.lb10:
	move.l (a3),fc_addrin	; l'arbre
	lea fc_out,a0
	move 22(a3),(a0)+		; l'index (ou 0 si pas de FTEXT mais un DEFAULT)
	move 8(a5),(a0)+		; touche press‚e (dans intout de event multi)
	move 22(a3),(a0)+		; pour XaAES
	__GEM_AES .wd_form_keybd
	lea fc_out2,a0
	tst (a0)+				; 0 si bouton DEFAULT ou 1 autrement
	bne.s .lb11
	move (a0),d7			; index du bouton default
	bra .lb12				; sortie comme pour FORM BUTTON avec un EXIT
.lb11:
	move (a0)+,d6			; new_obj
	move (a0),d7			; key_out
	cmp 22(a3),d6
	beq.s .lb13
.new_obj:
	moveq #24,d0
	muls d6,d0
	move.l (a3),a0
	move.l 12(a0,d0.l),a0	; adresse tedinfo
	move.l (a0),a0			; texte
	move.l a0,d0
.lb14:
	tst.b (a0)+
	bne.s .lb14
	sub.l d0,a0
	subq.l #1,a0
	move a0,d5				; d6 contient new_objc et d5 contient new_pos
	move.l (a3),fc_addrin	; l'arbre
	lea fc_out,a0
	move 22(a3),(a0)+		; objet actuel
	clr (a0)+
	move 24(a3),(a0)+		; position
	move #3,(a0)			; ED_END
	__GEM_AES .wd_objc_edit
	move d6,22(a3)			; nouvel objet
	lea fc_out,a0
	move d6,(a0)+			; nouveau
	clr (a0)+
	move d5,(a0)+			; nouvelle position
	move #1,(a0)			; ED_INIT
	__GEM_AES .wd_objc_edit
	move fc_out2+2,24(a3)	; nouvelle position
.lb13:
	tst d7					; keyout=0??
	beq .fin
	lea fc_out,a0			; passer par objc_edit
	move 22(a3),d6			; new_obj
	move d6,(a0)+			; objet
	move d7,(a0)+			; touche
	move 24(a3),(a0)+		; position
	move #2,(a0)			; mode ED_CHAR
	__GEM_AES .wd_objc_edit
	swap d6
	move fc_out2+2,d6		; new_pos
	move d6,24(a3)			; mise … jour
					; rien … faire
	bra .fin
.k1:
	bclr #1,d6				; teste si BUTTON
	beq .fin
	move d6,-2(a5)
	lea wc_in,a0
	move.l #10,(a0)
	__GEM_AES wd_wind_get	; fenˆtre au top
	move fc_out+2,d7		; son handle
	lea wd_table,a0
	moveq #19,d1			; pour boucler
.lb3:
	tst.l (a0)				; emplacement vide
	beq.s .lb4
	move.l (a0),a3
	cmp 20(a3),d7			; le bon handle?
	beq.s .lb5
.lb4:
	addq.l #4,a0
	dbf d1,.lb3
.lb7:
					; la fenetre au top n'est pas … nous
	bra.s .fin
.lb5:
	lea fc_out,a0
	move.l #8,(a0)+		; de l'objet 0 … 8 de profondeur
	move.l (a5),(a0)		; mousex et mousey (de evnt_multi)
	move.l (a3),fc_addrin	; l'arbre
	__GEM_AES .wd_objc_find
	moveq #0,d7
	move fc_out,d7
	bmi.s .lb7				; si <0, rien trouv‚
	move 12(a5),fc_out+2	; nombre de clicks
	__GEM_AES .wd_form_button
	tst fc_out
	beq.s .lb12
	moveq #0,d7		; pas de Keyout si newobj
	move fc_out+2,d6		; new_obj?
	bgt .new_obj			; oui, on s'occupe de d‚placer le curseur
	lsl d6
	lsr d6
	move d6,d7		; sinon objet EXIT (sans bit 15)
	; renvoit 0
	beq.s .fin		; peut pas etre nul! sinon on evite
.lb12:
	st .flag			; bouton exit (deja dans d7!)
.fin:
	movem.l .sauve,a4-a5
	move.b .flag,d0		; renvoit 0?
	bne.s .sortie			; non, traitement compl‚mentaire par utilisateur
	tst (a5)					; un ‚vŠnement reste encore?
	bne .encore				; oui, traiter!
.sortie:
   rts
.sauve: dc.l 0,0
.flag: dc.w 0
.wd_form_button: dc.l .fb_cont,global,fc_out,fc_out,fc_addrin,dum
.fb_cont: dc.w 56,2,2,1,0
.wd_form_keybd: dc.l .fk_cont,global,fc_out,fc_out2,fc_addrin,dum
.fk_cont: dc.w 55,3,3,1,0
.wd_form_dial: dc.l .fd_cont,global,fc_out,wc_in,dum,dum
.fd_cont: dc.w 51,9,1,0,0
.wd_object_draw: dc.l .od_cont,global,fc_out,wc_in,fc_addrin,dum
.od_cont: dc.w 42,6,1,1,0
.wd_objc_find: dc.l .of_cont,global,fc_out,fc_out,fc_addrin,dum
.of_cont: dc.w 43,4,1,1,0
.wd_objc_edit: dc.l .oe_cont,global,fc_out,fc_out2,fc_addrin,dum
.oe_cont: dc.w 46,4,2,1,0


; entree: A3 : structure
;			 D6 : index objet a modifier
; 			 D0 : 1 pour enlever l'‚tat SELECTED
;			      0 juste pour le redessiner si il a chang‚

wdial_change:
	move.l (a3),a2
	move.l a2,fc_addrin 	; l'arbre
	move d6,wc_in			; l'objet
	moveq #24,d1
	muls d6,d1
	lea 0(a2,d1.l),a2	   ; adresse objet
	tst d0
	beq.s .pas_deselect
	bclr #0,11(a2)			; enleve SELECTED
.pas_deselect:
	lea fc_out2,a3
	move #3,(a3)+
	clr.l (a3)+
	clr.l (a3)+
	move.l #$20002,d0
	add.l 20(a2),d0
	move.l d0,4(a3)	; l+2 et h+2
	__GEM_AES .wd_objc_offset	; coordonn‚es x,y de l'objet chang‚
	move.l fc_out+2,d0		; x et y
	sub.l #$10001,d0
	move.l d0,(a3)
	__GEM_AES .wd_form_dial	; message redraw sur l'objet
	rts
;.wd_objc_change: dc.l .oc_cont,global,fc_out,fc_out2,fc_addrin,dum
;.oc_cont: dc.w 47,8,1,1,0
.wd_form_dial: dc.l .fd_cont,global,fc_out2,wc_in,dum,dum
.fd_cont: dc.w 51,9,1,0,0
.wd_objc_offset: dc.l .oo_cont,global,wc_in,fc_out,fc_addrin,dum
.oo_cont: dc.w 44,1,3,1,0

; entree D0: si > 0, temps … attendre
;			D0: si < 0, temps … attendre et pas de keyboard
;		   D0 = 0 si pas d'evenement TIMER
; en sortie D0 = 0 si pas d'evenement TIMER, -1 si TIMER

wdial_evnt:
	moveq #19,d1	; keyb + butt + mesag (default for draw+formdo+clear)
	tst.l d0
	beq.s .lb0
	moveq #18+32,d1	; butt + mesag + timer (for just draw)
.lb0:
	lea .event_in,a0
	move d1,(a0)
	move d0,28(a0)		; lowcount
	swap d0
	move d0,30(a0)		; highcount
	move.l #wd_intout,.wd_evnt_multi+12		; intout
	move.l #wd_buf,fc_addrin				; buffer pour mesag
	__GEM_AES .wd_evnt_multi
	bclr #5,wd_intout+1	; evenement TIMER? (effac‚)
	sne d0				; si oui, D0 = -1
	ext.w d0
	ext.l d0
	rts										; valeurs retourn‚es dans les tableaux
.wd_evnt_multi: dc.l .wem_cont,global,.event_in,0,fc_addrin,dum
.wem_cont: dc.w 25,16,7,1,0
.event_in: dc.w 19,2,1,1,0,0,0,0,0,0,0,0,0,0,0,0

fc_addrin: dc.l 0
wc_in: dc.w 0
fc_out: dc.w 0,0,0,0,0,0,0,0,0
fc_out2: dc.w 0,0,0,0,0,0,0,0,0

wd_wind_set: dc.l ws_cont,global,wc_in,fc_out2,dum,dum
; ws_cont: dc.w 105,6,1,0,0

wd_wind_get: dc.l wg_cont,global,wc_in,fc_out,dum,dum
; wg_cont: dc.w 104,2,5,0,0

wd_ptr: dc.l wd_data

	if 1=0
dump_screen:
	movem.l d0-d7/a0-a6,-(sp)
	dc.w $a000
	move -4(a0),d5		; H
	move -12(a0),d4	; W
	move d5,d0
	muls d4,d0			; total pixels
	add.l d0,d0			; en words
	lea _tga_size(pc),a0
	ror #8,d4
	move d4,(a0)+
	ror #8,d5
	move d5,(a0)+
	move.l d0,2(a0)	; dans _data_size
	
	move #3,-(sp)
	move.l d0,-(sp)
	GEMDOS 68,8
	move.l d0,__buffer

	clr -(sp)
	pea file_name(pc)
	GEMDOS 60,8
	move d0,d3
	bmi.s .fin
	pea tga_head(pc)
	moveq #18,d0
	move.l d0,-(sp)
	move d3,-(sp)
	GEMDOS 64,12		; ecrit le header
	move.l physbase,a0
	move.l __buffer(pc),a1
	move.l a1,-(sp)
	move.l _data_size(pc),d0
	move.l d0,-(sp)
	lsr.l #4,d0
.copy:
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	subq.l #1,d0
	bne.s .copy
	move d3,-(sp)
	GEMDOS 64,12
	move d3,-(sp)
	GEMDOS 62,4
	move.l __buffer,-(sp)
	GEMDOS 73,6
	lea _file_count(pc),a0
.encore:
	move.b -(a0),d0
	addq.b #1,d0
	cmp.b #'9'+1,d0
	bne.s .ok
	move.b #'0',(a0)
	bra.s .encore	
.ok:
	move.b d0,(a0)	
.fin:
	movem.l (sp)+,d0-d7/a0-a6
	rts

__buffer: dc.l 0
tga_head:
	dc.b 0,0,2,0,0,0,0,0,0,0,0,0
_tga_size:
	dc.w 0,0,$1020
_data_size: dc.l 0
file_name: dc.b "D:\DUMP_000"
_file_count: dc.b ".TGA",0
	even
	
	endif


	
	bss

; global: ds.w 15
; dum: ds.l 15
wd_table: ds.l 20
redrawdat: ds.w 6 ; flag, handle, x,y,x',y'
wd_data: ds.b 32*(LAST_TREE+1)
wd_intout: ds.w 8
wd_buf: ds.w 8
winup: ds.w 1	; compte wind_update: +1 avec controle, -1 si libere
acc_close: ds.w 1	; FF si acc_close

	text