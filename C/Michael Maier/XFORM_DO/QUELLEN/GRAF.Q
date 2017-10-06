* -------------------------------------------------- *
*
*               XFORMDO.LIB Version 1.2
*
*          geschrieben von Michael Maier 1991
*
* -------------------------------------------------- *

* -------------------------------------------------- *
* Modul: GRAF.Q
* Version: 1.0
* Datum: 14.9.1991
* -------------------------------------------------- *

	PATH	include 	kann geÑndert werden!

**************************************************************************
*
* Include-Anweisungen
*
**************************************************************************
	  include types.i
	  include gem.i
	  include xform.i
	  include xobjects.i
	  
**************************************************************************
*
* Clip setzen
* -----------
* IN	A5.l	Zeiger auf Baum
*	A6.l	Basis
*
**************************************************************************
	LOCAL
set_clip:
	move.l	p_clip(A5),D0		; Clipbereich
	move.l	p_clip+4(A5),D1 	; setzen

	move.w	#$0001,gl_intin(A6)	; Clippen ein

	move.l	D0,gl_ptsin(A6) 	; Koordinatenfeld berechnen
	add.l	D1,D0			;
	sub.l	#$00010001,D0		;
	move.l	 D0,gl_ptsin+4(A6)	; + Breite

	move.l	#$00810002,gl_contrl(A6)	; Contrl-Werte...
	move.l	#$00000001,gl_contrl+4(A6)	;
	clr.w	gl_contrl+8(A6) 		;
	bsr	vdi				; vs_clip

	rts				; und zurÅck

**************************************************************************
*
* ankreuzbare KÑstchen zeichnen
* 4(SP):	Zeiger auf PARMBL-Struktur
* ret:		neuer Status
*
**************************************************************************
	LOCAL
	GLOBL	draw_box
draw_box:
	move.l	4(SP),A0		; Zeiger auf PARMBL holen
	movem.l #CREGS,-(SP)		; Register retten

	move.l	A0,A5			;
	lea	basis,A6		;

	move.w	gl_vhandle(A6),gl_contrl+12(A6)        ; VDI-Handle

	move.l	p_parm(A5),D7		; 
	move.w	D7,D6			; Farben...
	swap	D7			;
	and.w	#$00FF,D7		; Rahmendicke...


	bsr	set_clip		;

	move.w	#$0001,gl_intin(A6)	;
	bsr	vsl_type		;
	bsr	vswr_mode		;

	clr.l	gl_intin(A6)		; Ende setzen
	bsr	vsl_ends		;

	ext.l	D7			; Rahmendicke
	swap	D7			;
	move.l	D7,gl_ptsin(A6) 	;
	bsr	vsl_width		;

	move.w	D6,D0			; Farben
	ror.w	#6,D0			;
	ror.w	#6,D0			;
	and.w	#$000F,D0		;
	move.w	D0,gl_intin(A6) 	; Rahmenfarbe
	bsr	vsl_color		;

	move.w	p_cstate(A5),D0 	;
	move.w	p_pstate(A5),D1 	;
	xor.w	D1,D0			;
	and.w	#$0001,D0		; objc_draw-Aufruf?
	bne	.changed		; nein, Objektstatus gewechselt

;
; Rahmen der Box Zeichnen
;

	move.l	p_xy(A5),D0		; Startpunkt
	move.l	D0,gl_ptsin+16(A6)	; Endpunkt sind gleich
	move.l	D0,gl_ptsin(A6) 	; 1. Punkt
	move.w	p_xy(A5),D0		; X
	move.w	p_xy+2(A5),D1		; Y
	move.w	p_xy+4(A5),D2		; Breite
	move.w	p_xy+6(A5),D3		; Hîhe
	subq.w	#1,D2			;
	subq.w	#1,D3			;

	move.w	D0,D4			; X
	add.w	D2,D4			; + Breite - 1
	move.w	D4,gl_ptsin+4(A6)	;
	move.w	D1,gl_ptsin+6(A6)	; 2. Punkt

	move.w	D4,gl_ptsin+8(A6)	; 3. Punkt
	move.w	D1,D5			;
	add.w	D3,D5			;
	move.w	D5,gl_ptsin+10(A6)	;

	move.w	D0,gl_ptsin+12(A6)	; 4. Punkt
	move.w	D5,gl_ptsin+14(A6)	;

	move.w	#5,gl_contrl+2(A6)	; 5 Punkte insgesamt
	bsr	v_pline 		;

.changed:
	moveq	#0,D1			; Farbe
	move.w	p_cstate(A5),D0 	;
	btst	#0,D0			; SELECTED?
	beq.s	.notsel 		; nein
	ror.w	#8,D6			; Farbe
	and.w	#$000F,D6		;
	move.w	D6,D1			;

.notsel:
	move.w	D1,gl_intin(A6) 	; Eintragen
	bsr	vsl_color		; Farbe setzen

	move.w	p_xy(A5),D0		; X
	move.w	p_xy+2(A5),D1		; Y
	move.w	p_xy+4(A5),D2		; Breite
	move.w	p_xy+6(A5),D3		; Hîhe

	addq.w	#1,D0			;
	addq.w	#1,D1			;
	subq.w	#3,D2			;
	subq.w	#3,D3			;

	move.w	D0,gl_ptsin(A6) 	; 1. Punkt
	move.w	D1,gl_ptsin+2(A6)	;

	move.w	D0,D4			; 2. Punkt
	add.w	D2,D4			;
	move.w	D4,gl_ptsin+4(A6)	;
	move.w	D1,D5			;
	add.w	D3,D5			;
	move.w	D5,gl_ptsin+6(A6)	;
	move.w	#2,gl_contrl+2(A6)	; 2 Punkte = 1 Strich
	bsr	v_pline 		;

	move.w	D4,gl_ptsin(A6) 	   ; 2. Strich...
	move.w	D0,gl_ptsin+4(A6)	   ;
	bsr	v_pline 		;

	move.w	p_cstate(A5),D0 	;
	bclr	#0,D0			; nicht invertieren
	movem.l (SP)+,#CREGS		; Register vom Stack
	rts				; und zurÅck

**************************************************************************
*
* Unterstreichen
* 4(SP):	Zeiger auf PARMBL-Struktur
* ret:		neuer Status
*
**************************************************************************
	LOCAL
	GLOBL	draw_unln
draw_unln:
	move.l	4(SP),A0		; Zeiger auf PARMBL holen
	movem.l #CREGS,-(SP)		; Register retten

	lea	basis,A6		; Basis
	move.l	A0,A5			; Baum

	move.w	gl_vhandle(A6),gl_contrl+12(A6)        ; VDI-Handle

	move.l	p_tree(A5),A0		; Zeiger auf
	move.w	p_obj(A5),D0		; Objekt
	mulu	#ob_size,D0		; ermitteln
	add.l	D0,A0
	move.w	ob_type(A0),D0		; Typ untersuchen
	cmp.w	#G_USERDEF,D0		; nur G_USERDEG?
	bne	.ishotkey		; nein -> es ist HOTKEY
	move.w	p_xy+6(A5),D7		; ja -> Werte aus p_h lesen
	move.w	D7,D6			; Farbe in D6
	and.w	#$000F,D6		; Dicke ausmarkieren
	lsr.w	#8,D7			; Dicke nach vorne
	bra	.isunderline

.ishotkey:

	move.l	p_parm(A5),D7		; 
	move.w	D7,D6			; Farbe nicht vergessen!
	lsr.w	#6,D6
	lsr.w	#6,D6
	and.w	#$000F,D6		; Farbe
	swap	D7			;
	and.w	#$00FF,D7		; Rahmendicke...

.isunderline:

	bsr	set_clip		; Clip setzen

	move.w	#$0001,gl_intin(A6)	; Typ setzen
	bsr	vsl_type		;

**********

	move.l	pb_tree(A5),A0		; Zeiger auf Objekt ermitteln
	move.w	pb_obj(A5),D0		; Objekt
	mulu	#ob_size,D0		; Offset
	add.l	D0,A0			; addieren
	move.w	ob_type(A0),D0		; HOTKEY?
	cmp.w	#G_HOTKEY,D0		;
	bne	.nohot			; nein -> Schreibmodus bleibt!

	move.w	ob_next(A0),D0		;
	move.l	pb_tree(A5),A0		;
	mulu	#ob_size,D0		;
	add.l	D0,A0			; Zeiger auf's Mutterobjekt
	move.w	ob_state(A0),D0 	;
	btst	#0,D0			; SELECTED?
	beq	.nohot			; nein -> Schreibmodus bleibt!
	move.w	#3,gl_intin(A6) 	; ja -> XOR-Modus

.nohot:

	bsr	vswr_mode		; Schreibmodus setzen

	clr.l	gl_intin(A6)		;
	bsr	vsl_ends		; Enden setzen

	ext.l	D7			; Rahmendicke
	swap	D7			;
	move.l	D7,gl_ptsin(A6) 	;
	bsr	vsl_width		; setzen
	
	move.w	D6,gl_intin(A6) 	; Rahmenfarbe
	bsr	vsl_color		;

	move.l	pb_xy(A5),gl_ptsin(A6)	; 1. Punkt
	move.l	pb_xy(A5),gl_ptsin+4(A6) ; 2. Punkt
	move.w	pb_xy+4(A5),D0		;
	add.w	D0,gl_ptsin+4(A6)	;
	move.w	#2,gl_contrl+2(A6)	; Zwei Punkte
	bsr	v_pline 		; zeichnen

	move.w	p_cstate(A5),D0 	;
	bclr	#0,D0			; nicht invertieren
	movem.l (SP)+,#CREGS		; Register vom Stack
	rts				; und zurÅck

**************************************************************************
*
* Runde Schalter zeichnen
* 4(SP):	Zeiger auf PARMBL-Struktur
* ret:		neuer Status
*
**************************************************************************
	LOCAL
	GLOBL	draw_rbut
draw_rbut:
	move.l	4(SP),A0		; Zeiger auf PARMBL holen
	movem.l #CREGS,-(SP)		; Register retten

	link	A4,#-2*fd_size		; lokale Strukturen
	lea	fd_size(SP),A3		; Quelle
	move.l	SP,A2			; Ziel

	lea	basis,A6		; Basis
	move.l	A0,A5			; Zeiger auf Baum

	move.w	gl_vhandle(A6),gl_contrl+12(A6)      ; VDI-Handle

	bsr	set_clip		;

	move.l	gl_bitoff(A6),A0	; Adresse der Grafik

	move.w	pr_cstate(A5),D0	; neuer Status
	btst	#0,D0			;
	beq.s	.notselected		;

	move.l	gl_biton(A6),A0 	; Adresse der Grafik

.notselected:

;
; Initialisierung
;
	clr.l	fd_addr(A2)		; Zielspeicher

	move.l	bi_pdata(A0),fd_addr(A3) ; Quellspeicher
	move.w	bi_wb(A0),D0		; Breite
	lsl.w	#3,D0			; * 8
	move.w	D0,fd_w(A3)		;
	move.w	bi_wb(A0),D0		;
	lsr.w	#1,D0			; durch 2
	move.w	D0,fd_wdwidth(A3)	;
	move.w	bi_hl(A0),fd_h(A3)	; Hîhe
	clr.w	fd_stand(A3)		; GerÑteabhÑngig
	move.w	#1,fd_nplanes(A3)	; 1 Plane

	move.w	#1,gl_intin(A6) 		; E=Q
	move.w	bi_color(A0),gl_intin+2(A6)	; Bits gesetzt
	clr.w	gl_intin+4(A6)			; Bits nicht gesetzt

	clr.l	gl_ptsin(A6)			; Quelle
	move.l	fd_w(A3),gl_ptsin+4(A6)    ; Breite und Hîhe
	sub.l	#$00010001,gl_ptsin+4(A6)  ;

	move.l	pb_xy(A5),gl_ptsin+8(A6)	; X,Y
	move.l	pb_xy(A5),D0			;
	add.l	fd_w(A3),D0			;
	move.l	D0,gl_ptsin+12(A6)		;

	move.l	#$00790004,gl_contrl(A6)	; Contrl-Werte...
	move.l	#$00000003,gl_contrl+4(A6)	;
	clr.w	gl_contrl+8(A6) 		;
	move.l	A3,gl_contrl+14(A6)		; Quelle
	move.l	A2,gl_contrl+18(A6)		; Ziel
	bsr	vdi				; vrt_cpyfm...

	unlk	A4			; lokaler Speicher
	move.w	p_cstate(A5),D0 	;
	bclr	#0,D0			;
	movem.l (SP)+,#CREGS		; Register vom Stack
	rts				; und zurÅck

**************************************************************************
*
* Fly-Objekt zeichnen
* 4(SP):	Zeiger auf PARMBL-Struktur
* ret:		neuer Status
*
**************************************************************************
	LOCAL
	GLOBL	draw_fly
draw_fly:
	move.l	4(SP),A0		; Zeiger auf PARMBL holen
	movem.l #CREGS,-(SP)		; Register retten

	lea	basis,A6		; Basis
	move.l	A0,A5			; Baum

	move.w	gl_vhandle(A6),gl_contrl+12(A6)      ; VDI-Handle

	bsr	set_clip		;

	move.w	#$0001,gl_intin(A6)	; Typ setzen
	bsr	vsl_type		;
	bsr	vswr_mode		; Schreibmodus setzen

	clr.l	gl_intin(A6)		;
	bsr	vsl_ends		; Enden setzen

	move.l	#$00010000,gl_ptsin(A6) ;
	bsr	vsl_width		; setzen

	move.l	pb_parm(A5),D0		; Farbe ermitteln
	lsr.w	#6,D0			;
	lsr.w	#6,D0			;
	and.w	#$000F,D0		;
	move.w	D0,gl_intin(A6) 	; Rahmenfarbe
	bsr	vsl_color		;

	clr.w	gl_intin(A6)			; FÅllfarbe setzen
	move.l	#$00170000,gl_contrl(A6)	;
	move.l	#$00000001,gl_contrl+4(A6)	;
	move.w	#$0001,gl_contrl+8(A6)		;
	bsr	vdi				; vsf_interior

	move.l	pb_xy(A5),gl_ptsin(A6)		;
	move.l	pb_xy(A5),gl_ptsin+4(A6)	;
	move.l	gl_gr_bw(A6),D0 		;
	add.l	D0,gl_ptsin+4(A6)		; Hîhe und Breite
	move.l	#$00720002,gl_contrl(A6)	;
	clr.l	gl_contrl+4(A6) 		;
	clr.w	gl_contrl+8(A6) 		;
	bsr	vdi				; vr_recfl
	move.l	D0,gl_ptsin+4(A6)		;

	move.l	pb_xy(A5),gl_ptsin(A6)		; Anfangspunkte
	move.l	pb_xy(A5),gl_ptsin+4(A6)	; 2. Punkt
	move.l	pb_xy(A5),gl_ptsin+8(A6)	; 3. Punkt
	move.l	pb_xy(A5),gl_ptsin+12(A6)	; 4. Punkt
	move.l	pb_xy(A5),gl_ptsin+16(A6)	; 5. Punkt
	move.w	pb_xy+4(A5),D0			;
	add.w	D0,gl_ptsin+4(A6)		; 2. Punkt
	add.w	D0,gl_ptsin+8(A6)		; 3. Punkt
	move.w	pb_xy+6(A5),D0			;
	add.w	D0,gl_ptsin+10(A6)		; 3. Punkt
	add.w	D0,gl_ptsin+14(A6)		; 4. Punkt
	move.w	#5,gl_contrl+2(A6)		; 5 Punkte
	bsr	v_pline 			; und Ausgabe

	add.l	#$00030003,gl_ptsin(A6) 	; 1. Punkt nach innen
	sub.w	#$0003,gl_ptsin+4(A6)		;
	add.w	#$0003,gl_ptsin+6(A6)		; 2. Punkt nach innen
	sub.l	#$00030003,gl_ptsin+8(A6)	; 3. Punkt nach innen
	add.w	#$0003,gl_ptsin+12(A6)		;
	sub.w	#$0003,gl_ptsin+14(A6)		; 4. Punkt nach innen
	add.l	#$00030003,gl_ptsin+16(A6)	; 5. Punkt nach innen
	move.w	#5,gl_contrl+2(A6)		; 5 Punkte
	bsr	v_pline 			; und Ausgabe

	move.l	gl_ptsin(A6),D0 		; 1. Punkt 1 Zeile tiefer
	addq.l	#1,D0				;
	move.l	D0,gl_ptsin(A6) 		;
	move.l	gl_ptsin+4(A6),D0		; 2. Punkt 1 Zeile tiefer und nÑher
	addq.l	#1,D0				;
	sub.l	#$00010000,D0			;
	move.l	D0,gl_ptsin+4(A6)		;
	move.l	gl_ptsin+8(A6),D0		; 2. Punkt 1 Zeile nÑher
	sub.l	#$00010000,D0			;
	move.l	D0,gl_ptsin+8(A6)		;
	move.w	#3,gl_contrl+2(A6)		; 
	bsr	v_pline 			; und Ausgabe

	move.l	pb_xy(A5),gl_ptsin(A6)		;
	move.l	pb_xy(A5),gl_ptsin+4(A6)	;
	move.l	gl_gr_bw(A6),D0 		;
	add.l	D0,gl_ptsin+4(A6)		; Hîhe und Breite
	move.w	#2,gl_contrl+2(A6)		; 2 Punkte = 1 Linie
	bsr	v_pline 			;

	move.w	p_cstate(A5),D0 		;
	bclr	#0,D0				;
	movem.l (SP)+,#CREGS			; Register vom Stack
	rts					; und zurÅck

**************************************************************************
*
* VDI-Funktionsaufrufe...
* immer: A5 Zeiger auf contrl-Array!
*
**************************************************************************
vsl_type:
	move.l	#$000F0000,gl_contrl(A6)	;
	move.l	#$00000001,gl_contrl+4(A6)	;
	move.w	#$0001,gl_contrl+8(A6)		;
	bra	vdi				; vsl_type

vsl_ends:
	move.l	#$006C0000,gl_contrl(A6)	; Contrl-Werte...
	move.l	#$00000002,gl_contrl+4(A6)	;
	clr.w	gl_contrl+8(A6) 		;
	bra	vdi				; vsl_ends

vsl_width:
	move.l	#$00100001,gl_contrl(A6)	; Contrl-Werte...
	move.l	#$00010000,gl_contrl+4(A6)	;
	clr.w	gl_contrl+8(A6) 		;
	bra	vdi				; vsl_width

vswr_mode:
	move.l	#$00200000,gl_contrl(A6)	; Contrl-Werte...
	move.l	#$00000001,gl_contrl+4(A6)	;
	move.w	#$0001,gl_contrl+8(A6)		;
	bra	vdi				; vswr_mode	   

vsl_color:
	move.l	#$00110000,gl_contrl(A6)	; Contrl-Werte.
	move.l	#$00000001,gl_contrl+4(A6)	;
	move.w	#$0001,gl_contrl+8(A6)		;
	bra	vdi				; vsl_color

v_pline:
	move.w	#$0006,gl_contrl(A6)		;
	clr.l	gl_contrl+4(A6) 		;
	clr.w	gl_contrl+8(A6) 		;
	bra	vdi				; v_pline	 

***************************************************************************

;
; Struktur: PARMBLK
;
	ABS
	ABSSET	0

p_tree: 	ds.l	1
p_obj:		ds.w	1
p_pstate:	ds.w	1
p_cstate:	ds.w	1
p_xy:		ds.w	4
p_clip: 	ds.w	4
p_parm: 	ds.l	1

;
; Ende
;
	END
