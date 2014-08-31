;------------------------------------------------------------------
;
;		Basic-Input/Output	(BIOS)
;
;------------------------------------------------------------------

;------------------------------------------------------------------
; wenn EXTRAFONT auf einen Wert!=0 gesetzt wird, wird nicht der
; Systemfont verwendet, sondern ein eigener
; d.h. kein LINE-A, dafÅr lÑnger
;------------------------------------------------------------------

			.text
			.mc68000

			.import font8x8
			.import memcpy
			.import ctrl
			.import WaitBASIC
			.import do_draw
			.import DirtyScreen

;------------------------------------------------------------------

			NULL_KENN	=	$87916543	; 4-Byte-Kennung

;------------------------------------------------------------------
; Stellt fest, ob ein vorangegangenes Null-Byte den String terminiert
; int is0byte(char *);
;------------------------------------------------------------------

			.xref is0byte

is0byte:	moveq	#0,D0
			bsr.s	is0byte__
			bne.s	is0_end
			moveq	#4,D0
is0_end:	rts

is0byte__:	cmp.b	#(NULL_KENN>>24)&$FF,(A0)
			bne.s	.fa
			cmp.b	#(NULL_KENN>>16)&$FF,1(A0)
			bne.s	.fa
			cmp.b	#(NULL_KENN>>8)&$FF,2(A0)
			bne.s	.fa
			cmp.b	#NULL_KENN&$FF,3(A0)
.fa:		rts

;------------------------------------------------------------------
; legt hinter einem Null-Byte eine Kennung ab
; void make0byte(char *);
;------------------------------------------------------------------

			.xref make0byte

make0byte:	move.b	#(NULL_KENN>>24)&$FF,(A0)
			move.b	#(NULL_KENN>>16)&$FF,1(A0)
			move.b	#(NULL_KENN>>8)&$FF,2(A0)
			move.b	#NULL_KENN&$FF,3(A0)
			clr.b	4(A0)
			rts

;------------------------------------------------------------------
; meine eigenen Versionen der C-Standards: fangen NULL-Pointer ab und
; kopieren maximal 255 Zeichen, beachten NULL_KENNUNG
;------------------------------------------------------------------

			.xref strcpy
			.xref strncpy
			.xref strcat
			.xref strncat
			.xref strlen

strcpy:		move.w	#254,D0
strncpy:	move.l	A0,D2
			beq.s	bye_strcpy
entry:		move.l	A1,D1
			beq.s	bye_strcpy
			bra.s	.bloop
.loop:		move.b	(A1)+,(A0)+
.bloop:		dbeq	D0,.loop
			exg		A0,A1
			bsr.s	is0byte__
			exg		A0,A1
			dbne	D0,.loop
			clr.b	(A0)
			move.l	D2,A0
bye_strcpy:	rts

strcat:		move.w	#254,D0
strncat:	move.l	A0,D2
			beq.s	bye_strcpy
.loop:		tst.b	(A0)+
			bne.s	.loop
			bsr.s	is0byte__
			beq.s	.loop
			subq.l	#1,A0
			bra.s	entry

strlen:		move.l	A0,D0
			beq.s	.bye_strlen
			moveq	#-1,D0
.loop:		tst.b	(A0)+
.bloop:		dbeq	D0,.loop
			bsr.s	is0byte__
			dbne	D0,.loop
.end:		eor.l	#-1,D0
.bye_strlen:rts
;------------------------------------------------------------------
;  Zieht eine Linie mit Hilfe des Bresenham-Verfahrens
;  entnommen aus:
;  David Kastrup, ''Einfache Kurven auf Rastergrafiken ''
;  und die Behandlung verschiedener Anstiege implementiert
;  void line(int x1,int y1,int x2,int y2);
;------------------------------------------------------------------

			.xref line
;D0.w: x0
;D1.w: y0
;D2.w: x1
;4(sp): y1

;D3: y1
;D4: a
;D5: b
;D6: step
;D7: inc
; (sp): x
; 2(sp): y

			regs reg D3-D7/A2	;6 register
line:		movem.l #regs,-(sp)
			move.w	4+6*4(SP),D3 ; y1
			lea		-4(sp),A1	; x
			lea		-2(sp),A2	; y
			move.w	D3,D4
			sub.w	D1,D4	;a=y1-y0
			move.w	D4,D6
			bpl.s	.get_b
			neg.w	D6		; abs(a)
.get_b:		move.w	D2,D5
			sub.w	D0,D5	;b=x1-x0
			move.w	D5,D7
			bpl.s	.chk_a_b
			neg.w	D7		;abs(b)
.chk_a_b:	cmp.w	D6,D7	;abs(a)<abs(b)
			bhs.s	.do_compute
			exg		A1,A2	;xp<->yp
			exg		D0,D1	;x0<->y0
			exg		D2,D3	;x1<->y1
			exg		D4,D5	;a <->b
.do_compute:
			movem.w D0-D1,-(sp) ; x=x0,y=y0
			tst.w	D5		;b<0
			bpl.s	.init_loop
			neg.w	D5
			neg.w	D4
			move.w	D2,(sp) ;x=x1
			move.w	D3,2(sp);y=y1
			move.w	D0,D2	;x1=x0
.init_loop: move.w	D5,D6
			lsr.w	#1,D6	; step=b/2
			sub.w	(SP),D2 ; Anzahl der auszugebenden Punkte
			move.w	D2,D3	;spart Sichern bei plotpoint-Aufruf
			moveq	#-1,D7	;inc=-1
			tst.w	D4		;a>0
			ble.s	.loop
			neg.w	D4		; a: immer negativ oder 0!
			moveq	#1,D7
.loop:		move.w	(A1),D0
			move.w	(A2),D1
			bsr.s	plotpoint
			addq.w	#1,(SP) ;x++
			add.w	D4,D6	;step-=a
			bgt.s	.chk_x	;step<=0
			add.w	D7,2(sp);y+=inc
			add.w	D5,D6	;step+=b
.chk_x:		dbra	D3,.loop ;x>x1
			addq.l	#4,SP
			movem.l (sp)+,#regs
			rts

;------------------------------------------------------------------
; Plottet einen Punkt an der angegebenen Koordinate
; void plotpoint(int x,int y)
;------------------------------------------------------------------

			.xref plotpoint
;D0.w x
;D1.w y

plotpoint:	cmp.w	#256,D0		; öber- und Unterlauf abfangen
			bhs.s	.endplot
			cmp.w	#176,D1
			bhs.s	.endplot
			neg.w	D1			; linke untere Ecke ist 0
			add.w	#175,D1
			lsl.w	#5,D1		; y in Bytes umrechnen
			move.w	D0,D2		; x-Wert sichern
			lsr.w	#3,D0		; Byteoffset in x-Richtung
			add.w	D0,D1		; gesamter Offset
			and.w	#7,D2		; PixelOffset im Byte
			eor.w	#7,D2		; Bitnummer
			lea		screen,A0
			bset	D2,0(A0,D1) ; Punkt setzen
			st		DirtyScreen
.endplot:	rts


;------------------------------------------------------------------
; bewegt die angegebene Anzahl von Bytes von source nach dest
; void peekpoke(char* source,char* dest);
;------------------------------------------------------------------

			.xref	peekpoke
; D0.w Anzahl der Bytes
; A0.l source
; A0.l destination

peekpoke:	move	SR,D1
			or		#%111<<8,SR
			subq.w	#1,D0
.loop:		move.b	(A0)+,(A1)+
			dbra	D0,.loop
			move	D1,SR
			rts

GetScreen:	lsl.w	#8,D0
			lea		screen,a0
			lea		(A0,D0.w),A0
			lea		256(a0),a1
			neg.w	D0
			add.w	#21*32*8,D0
			rts

GetCharScreen:
			lsl.w	#5,D0
			lea		line00,a0
			lea		(A0,D0.w),A0
			lea		32(a0),a1
			neg.w	D0
			add.w	#32*21,d0
			rts

			.xref ScrollUp,ScrollUpR
ScrollUp:	moveq	#0,D0
ScrollUpR:	move.w	D0,-(SP)
			bsr.s	GetScreen
			bsr.s	scr_cpy_up

			move.w	(SP)+,D0
			bsr.s	GetCharScreen
			bsr.s	scr_cpy_up

			moveq	#21,D0
			bsr		clline

			jmp		do_draw(PC)

scr_cpy_up:	lsr.w	#2,D0
			bra.s	scr_cpy_ups
scr_cpy_l:	move.l	(A1)+,(A0)+
scr_cpy_ups:dbra	D0,scr_cpy_l
			rts


			.xref ScrollDown,ScrollDownR
ScrollDown:	moveq	#0,D0
ScrollDownR:move.w	D0,-(SP)
			bsr.s	GetScreen
			bsr.s	scr_cpy_d

			move.w	(SP),d0
			bsr.s	GetCharScreen
			bsr.s	scr_cpy_d

			move.w	(SP)+,D0
			bsr.s	clline

			jmp		do_draw(PC)

scr_cpy_d:	lea		(A0,D0.w),A0
			lea		(A1,D0.w),A1
			lsr.w	#2,D0
			bra.s	scr_cpy_ds
scr_cpy_dl:	move.l	-(A0),-(A1)
scr_cpy_ds:	dbra	D0,scr_cpy_dl
			rts

;------------------------------------------------------------------
;	VOID DrawCursor(WORD x, WORD y)
;	d0.w -> x
;	d1.w -> y
;------------------------------------------------------------------
			.xref DrawCursor
DrawCursor: lea		screen,a0
			lsl.w	#8,d1
			add.w	d1,d0
			lea		(a0,d0.w),a0	; Adresse des Cursors auf dem Screen

			not.b	(a0)
			not.b	32(a0)
			not.b	64(a0)
			not.b	96(a0)			; Cursor zeichnen/lîschen
			not.b	128(a0)
			not.b	160(a0)
			not.b	192(a0)
			not.b	224(a0)
			st		DirtyScreen

			rts

;--------------------------------------------------------------------
;	void cls(void)			: lîsche den gesamten screen
;	void clline(int line)	: lîsche eine Zeile
;	void cllines(int von, int bis) :lîschen mehrerer Zeilen
;	void delxy( int line,int von_x, int bis_x) : lîschen in einer Zeile
;--------------------------------------------------------------------
			.xref cls,clline,cllines,delxy
			clregs reg D3-D5

cls:		moveq	#0,D0
			moveq	#21,D1

; D0: Startzeile
; D1: endzeile
cllines:	movem.l	D3/D4,-(SP)
			move.w	D0,D3
			move.w	D1,D4
			bra.s	.sloop
.loop:		move.w	D3,D0
			bsr.s	clline
			addq.w	#1,D3
.sloop:		cmp.w	D4,D3
			ble.s	.loop
			movem.l	(SP)+,D3/D4
			rts			


; d0: Zeile
clline:		moveq	#0,D1
			moveq	#31,D2

; d0: Zeile
; d1: Start-x
; d2: End-x
delxy:		movem.l #clregs,-(sp)
			move.w	rev_mode,-(SP)
			clr.b	rev_mode
			move.w	D0,D3
			move.w	D1,D4
			move.w	D2,D5
			bra.s	.sloop
.loop1:		move.w	D4,D0
			move.w	D3,D1
			moveq	#' ',D2
			bsr.s	PutChar
			addq.w	#1,D4
.sloop:		cmp.w	D5,D4
			ble.s	.loop1
			move.w	(SP)+,rev_mode
			movem.l (sp)+,#clregs
			rts


;------------------------------------------------------------------
;	VOID PutChar(WORD x, WORD y, WORD ch);
;	d0.w -> x
;	d1.w -> y
;	d2.w -> Zeichen
;------------------------------------------------------------------
			.xref PutChar
PutChar:	tst.w	ctrl			; gleichzeitig check auf
			bne.s	.no_wait			; ctrl-c und ctrl-q
			movem.w D0-D2,-(SP)
			jsr		WaitBASIC(PC)
			movem.w (SP)+,D0-D2
			bra.s	PutChar

.no_wait:	cmp.w	#31,D0
			bhi		.rts
			cmp.w	#21,D1
			bhi.s	.rts
			cmp.w	#255,D2
			bhi.s	.rts
			lea		charscreen,a0	; Buchstaben merken
			lsl.w	#5,d1			; 32 Byte pro Zeile
			add.w	d0,d1			; plus x
			move.b	d2,0(a0,d1.w)	; und Buchstaben merken
			sub.w	d0,d1			; x wieder abziehen

			lsl.w	#3,d1			; 32-Byte pro Zeile * 8 Zeilen
			add.w	D1,D0			; Gesamt-Offset im Screen

if EXTRAFONT
			lea		font8x8,a1
			lsl.w	#3,d2
			add.w	D2,A1			; Adresse des Zeichens im Font
			moveq	#7,D1			; 8 Pixel hoch
else
			lea		font_d,A0
			tst.l	(A0)
			bne.s	.cont			;schon initialisiert?

			movem.l D0-D2/A0/A2,-(SP) ; initialisieren
			dc.w	$A000			; LineA-Init
			movem.l (SP)+,D0-D2/A0/A2
			move.l	4(A1),A1
			move.w	$52(A1),D1
			subq.w	#1,D1			; Hîhe des Zeichensatzes
			move.w	D1,font_h-font_d(A0)
			move.w	$50(A1),font_w-font_d(A0) ; Breite des Zeichensatzes
			move.l	$4C(A1),(A0) ; der Zeichensatz selbst

.cont:		move.l	(A0),A1
			add.w	D2,A1			; Adresse des Zeichens im Font
			move.w	font_h-font_d(A0),D1
			move.w	font_w-font_d(A0),D2
endif

			lea		screen,a0
			add.w	D0,A0		; Adresse des Zeichens im Screen

			move.b	rev_mode,D0

.loop:
if EXTRAFONT
			move.b	(a1)+,(a0)
else
			move.b	(a1),(a0)
			add.w	D2,A1
endif
			eor.b	D0,(a0)			; Fontdaten kopieren
			lea		32(a0),a0
			dbra	D1,.loop
			st		DirtyScreen
.rts:		rts

;------------------------------------------------------------------
			.data
			.xref cpx_mfdb
cpx_mfdb:	.dc.l	screen
			.dc.w	256
			.dc.w	176
			.dc.w	16
			.dc.w	1
			.dc.w	1
			.dc.w	0,0,0		; reserviert

			.bss
			.xref	charscreen
			.xref	rev_mode
			.xref screen
if !EXTRAFONT
font_h:		ds.w	1
font_w:		ds.w	1
font_d:		ds.l	1
endif

rev_mode:	.ds.b	1
.dummy:		.ds.b	1

screen:		.ds.b	(256/8)*176 ; Bildschirmspeicher

charscreen:
line00:		.ds.b	32			; Speicher fÅr alle char's
line01:		.ds.b	32
line02:		.ds.b	32
line03:		.ds.b	32
line04:		.ds.b	32
line05:		.ds.b	32
line06:		.ds.b	32
line07:		.ds.b	32
line08:		.ds.b	32
line09:		.ds.b	32
line10:		.ds.b	32
line11:		.ds.b	32
line12:		.ds.b	32
line13:		.ds.b	32
line14:		.ds.b	32
line15:		.ds.b	32
line16:		.ds.b	32
line17:		.ds.b	32
line18:		.ds.b	32
line19:		.ds.b	32
line20:		.ds.b	32
line21:		.ds.b	32


			.end
