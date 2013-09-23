**************************************************************************
** CopperKaahBaahNaah by New Mode of Delta Force			**
**************************************************************************

; !!! THIS SOURCECODE IS COPYRIGHTED SOFTWARE !!!

disk_version    EQU 0
; 0 = Entwicklerversion/Festplatte
; 1 = Diskettenversion

		IFEQ disk_version
		OPT X+		; Erweiterte Symboltable anschalten
		ELSEif
		OPT X-		; Symboltabelle aus
		ORG $1000	; hier Relozieradresse angeben
		ENDC

		TEXT

start:
		lea	bss_start,A0
		lea	bss_ende,A1
		moveq   #0,D0
clear_bss:	move.l  D0,(A0)+
		cmpa.l  A0,A1
		bgt.s   clear_bss

		IFNE disk_version
		move    SR,old_sr
		ori     #$0700,SR
		ENDC

		move.l  A7,oldstack
		lea	stack,A7		; eigenen Stack setzen

		bsr     install_all

		lea	logo(PC),A0
		move.l  #4864,D0
		bsr     backform
		lea	charset,A0
		move.l  #35328,D0
		bsr     backform
		lea	font,A0
		move.l  #24576,D0
		bsr     backform

		bsr     init_sync_scrolling

		bsr     make_coltab

		bsr     make_logo_cols

		bsr     preshift_logo

		bsr     make_roehre

		bsr     convert_text

		movea.l screen_1(PC),A0
		lea	14*160(A0),A0
		move.l  roehren_grafik(PC),D0
		move.w  #(176*20)-1,D1
copy_first:     move.l  D0,(A0)		; R”hre auf Screen kopieren
		lea	8(A0),A0
		dbra    D1,copy_first

		move.l  #vbl,$70.w

wait_space:     cmpi.b  #$39,$fffffc02.w     ; Warten bis SPACE da ist
		bne.s   wait_space

		bsr     quit_screen

		bsr     restore_all		; alles zurcksetzen

;---------------- System -----------------------


		movea.l oldstack,A7		; alten Stack setzen

		IFEQ disk_version
		clr.w   -(A7)		; und Programm verlassen
		trap    #1
		ELSEif
		move    old_sr,SR
		moveq   #0,D0
		jmp     $0500.w
		ENDC


install_all:
; Initialisiert alle Hardware-Register

		IFEQ disk_version
		pea     0
		move.w  #32,-(A7)	; Supervisor an
		trap    #1
		addq.l  #6,A7
		move.l  D0,ssp
		ENDC


		move.b  $ffff820a.w,oldsync
		move.b  $ffff8260.w,oldres

		movem.l $ffff8240.w,D0-D7
		movem.l D0-D7,oldpalette

		lea	$ffff8240.w,A0
		moveq   #7,D0
clrpal:	clr.l   (A0)+
		dbra    D0,clrpal

		lea	$ffff8201.w,A0	; Screenadresse holen
		movep.w 0(A0),D0
		move.w  D0,oldscreen

		move.l  #screen_base,D0
		and.l   #-256,D0		; untere 8 Bits weg
		move.l  D0,screen_1
		move.l  D0,screen_buffer
		movea.l D0,A0

		move.w  #(261+200)*40-1,D0   ; Screens l”schen
clr_screens:    clr.l   (A0)+
		dbra    D0,clr_screens

		move.l  screen_1(PC),D0
		bsr     set_screen

		bsr     init_mfp

		moveq   #$12,D0		; Maus aus
		bsr     send_ikbd
		moveq   #$1a,D0		; Joystick aus
		bsr     send_ikbd

		move    #$2300,SR	; Interrupts anschalten

		bsr     vsync
		move.b  #2,$ffff820a.w	; 50 Hz

		bsr     vsync
		clr.b   $ffff8260.w		; Lowres

		moveq   #1,D0		; Musik anwerfen
		bsr     music

		rts


restore_all:
; alle Hardware-Register werden wieder so gesetzt wie am Anfang

		moveq   #0,D0
		jsr     music

		move.l  #start_vbl,$70.w
		bsr     vsync

		movem.l oldpalette,D0-D7
		movem.l D0-D7,$ffff8240.w

		bsr     vsync
		move.b  #2,$ffff820a.w	; auf 50 Hz gehen

		bsr     vsync
		move.b  #0,$ffff820a.w	; kurz auf 60 Hz gehen

		bsr     vsync
		move.b  oldsync,$ffff820a.w
		move.b  oldres,$ffff8260.w

		bsr     restore_mfp

		IFEQ disk_version
		moveq   #$08,D0		; Maus wieder ein
		bsr     send_ikbd
		ELSEif
		moveq   #$12,D0		; Maus aus
		bsr     send_ikbd
		moveq   #$1a,D0		; Joystick aus
		bsr     send_ikbd
		ENDC

		moveq   #0,D0		; Musik abwrgen
		bsr     music+8

		move.w  oldscreen,D0
		lea	$ffff8201.w,A0
		movep.w D0,0(A0)		; alte Screenadresse setzen

		IFEQ disk_version
		move.l  ssp,-(A7)
		move.w  #32,-(A7)	; Supervisor aus
		trap    #1
		addq.l  #6,A7
		ENDC
		rts

send_ikbd:
; sendet Byte aus d0 an IKBD
		lea	$fffffc00.w,A0
waitkeyready:   btst    #1,(A0)
		beq.s   waitkeyready
		move.b  D0,2(A0)
		rts


vsync:		lea	vsync_count,A0
		move.l  (A0),D0
wait_strahl:    cmp.l   (A0),D0
		beq.s   wait_strahl
		rts

init_mfp:
; rettet und setzt alle IRQ's

		move    SR,-(A7)
		ori     #$0700,SR
		move.l  $0118.w,oldkey
		move.l  $0120.w,oldtimerb
		move.l  $70.w,oldvbl
		move.l  $68.w,oldhbl
		lea	$fffffa00.w,A0	; MFP
		move.b  $07(A0),oldmfp07
		move.b  $09(A0),oldmfp09
		move.b  $11(A0),oldmfp11
		move.b  $13(A0),oldmfp13
		move.b  $15(A0),oldmfp15
		move.b  $17(A0),oldmfp17
		move.b  $1b(A0),oldmfp1b
		move.b  $21(A0),oldmfp21
		clr.b   $07(A0)		; alle IRQ's aus
		clr.b   $09(A0)
		clr.b   $13(A0)
		clr.b   $15(A0)
		bset    #0,$07(A0)	; Timer B erlauben
		bset    #0,$13(A0)
		bclr    #3,$17(A0)	; Automatic EOI

		move.l  #newkey,$0118.w
		move.l  #start_vbl,$70.w     ; am Anfang (zum Initialisieren)
		move.l  #timer_b,$0120.w
		move    (A7)+,SR

		move.b  #$03,$fffffc00.w     ; ACIA-Init
		move.b  #$96,$fffffc00.w

		rts

restore_mfp:
; setzt alle MFP-Register wieder zurck

		move    SR,-(A7)
		ori     #$0700,SR
		move.l  oldkey,$0118.w
		move.l  oldtimerb,$0120.w
		move.l  oldvbl,$70.w
		move.l  oldhbl,$68.w
		lea	$fffffa00.w,A0	; MFP
		move.b  oldmfp07,$07(A0)
		move.b  oldmfp09,$09(A0)
		move.b  oldmfp11,$11(A0)
		move.b  oldmfp13,$13(A0)
		move.b  oldmfp15,$15(A0)
		move.b  oldmfp17,$17(A0)
		move.b  oldmfp1b,$1b(A0)
		move.b  oldmfp21,$21(A0)

		move.b  #$03,$fffffc00.w     ; ACIA-Init
		move.b  #$96,$fffffc00.w


		move    (A7)+,SR
		rts

start_vbl:	clr.b   $fffffa1b.w		; Timer B aus
		addq.l  #1,vsync_count
		rte


;----------- System - Ende --------------------------

quit_screen:
; Hier wird noch kurz alles sauber ausgeblendet

		move.w  #-1,logo_schwing_stop ; Schwingende Farben anhalten

		bsr     vsync

		lea	color_buff,A6
		move.w  #anz_delta_cols/2-1,D7 ; soviele Spalten
clear_cols:     move.w  #199,D0		; soviele Zeilen
		movea.l A6,A5
		moveq   #0,D1
clear_col_loop: move.l  D1,(A5)
		lea	anz_delta_cols*2(A5),A5
		dbra    D0,clear_col_loop
		bsr     vsync
		lea	4(A6),A6		; n„chste Spalte
		dbra    D7,clear_cols

		moveq   #0,D6

fade_loop:	cmp.w   #24,D6		; Sicherheitsz„hler (8+8+8)
		beq.s   end_fade		; damit auf jeden Fall zu Ende
		addq.w  #1,D6		; Z„hler erh”hen

		bsr     fade_down
		bsr     fade_down2
		bsr     vsync
		bsr     vsync
		lea	palette(PC),A0
		moveq   #31,D0		; 32 Farben
fade_check:     move.w  (A0)+,D1
		and.w   #$0777,D1
		bne.s   fade_loop	; noch nicht schwarz?
		dbra    D0,fade_check

		movea.l logo_col_point1(PC),A0
		move.w  #(8*16)-1,D0	; 128 Farben
fade_check2:    move.w  (A0)+,D1
		and.w   #$0777,D1
		bne.s   fade_loop	; noch nicht schwarz?
		dbra    D0,fade_check2

end_fade:
		bsr     vsync		; noch kurz warten
		bsr     vsync
		bsr     vsync
		bsr     vsync

		rts

backform:
; formt Bild aus Spezialformat zurck
; a0=Adresse
; d0=L„nge
		lsr.l   #3,D0		; Length/Bitblocks
		subq.l  #1,D0
		movea.l A0,A1		; Dest. (Atari)
backformloop0:  moveq   #0,D1		; clear Plane 0-3
		moveq   #0,D2
		moveq   #0,D3
		moveq   #0,D4
		moveq   #3,D5		; 4 words
backformloop1:  move.w  (A0)+,D7		; get word (Special)
		add.w   D7,D7		; shift left by 1
		addx.w  D1,D1		; Plane 0 set
		add.w   D7,D7		;
		addx.w  D2,D2		;
		add.w   D7,D7		;
		addx.w  D3,D3		;
		add.w   D7,D7		;
		addx.w  D4,D4		;
		add.w   D7,D7		;
		addx.w  D1,D1		;
		add.w   D7,D7		;
		addx.w  D2,D2		;
		add.w   D7,D7		;
		addx.w  D3,D3		;
		add.w   D7,D7		;
		addx.w  D4,D4		;
		add.w   D7,D7		;
		addx.w  D1,D1		;
		add.w   D7,D7		;
		addx.w  D2,D2		;
		add.w   D7,D7		;
		addx.w  D3,D3		;
		add.w   D7,D7		;
		addx.w  D4,D4		;
		add.w   D7,D7		;
		addx.w  D1,D1		;
		add.w   D7,D7		;
		addx.w  D2,D2		;
		add.w   D7,D7		;
		addx.w  D3,D3		;
		add.w   D7,D7		;
		addx.w  D4,D4		;
		dbra    D5,backformloop1
		move.w  D4,(A1)+		;
		move.w  D3,(A1)+
		move.w  D2,(A1)+
		move.w  D1,(A1)+
		dbra    D0,backformloop0
		rts


fade_down:
; faded Paletten runter

		lea	palette(PC),A0
		moveq   #31,D2		; 32 Werte
fdl0		move.w  (A0),D0
		and.w   #%111,D0
		beq.s   col2
		subq.w  #1,D0
		move.w  (A0),D1
		and.w   #%1111111111111000,D1
		or.w    D0,D1
		move.w  D1,(A0)
		bra.s   colok
col2		move.w  (A0),D0
		and.w   #%1110000,D0
		beq.s   col3
		sub.w   #$10,D0
		move.w  (A0),D1
		and.w   #%1111111110001111,D1
		or.w    D0,D1
		move.w  D1,(A0)
		bra.s   colok
col3		move.w  (A0),D0
		and.w   #%11100000000,D0
		beq.s   colok
		sub.w   #$0100,D0
		move.w  (A0),D1
		and.w   #%1111100011111111,D1
		or.w    D0,D1
		move.w  D1,(A0)
colok:		lea	2(A0),A0
		dbra    D2,fdl0
		rts

fade_down2:
; faded Palette im Logo runter
		movea.l logo_col_point1(PC),A0
		move.w  #(16*8)-1,D2
		bra     fdl0




nachschubpuffer:
; h„ngt den Rest an den Scroller an (und an Screen)

; Routine fr normalen Buffer
		tst.w   scroll_flag		; welche Routine?
		bne     nachschubpuffer2

		movea.l char_pointer1(PC),A0
		movea.l screen_1(PC),A1
		lea	179*160+152(A1),A1
		lea	scroll_buffer+152,A2
s_off		SET 0
c_off		SET 0
		REPT 32
		move.l  c_off(A0),s_off(A1)
		move.l  c_off(A0),s_off(A2)
		move.l  c_off+4(A0),s_off+4(A1)
		move.l  c_off+4(A0),s_off+4(A2)
s_off		SET s_off+160
c_off		SET c_off+24
		ENDR
		rts


nachschubpuffer2:
; h„ngt den Rest an den Scroller an (und an Screen)

; Routine fr 8er Buffer

		movea.l char_pointer1(PC),A0
		lea	1(A0),A0
		movea.l char_pointer2(PC),A3
		movea.l screen_1(PC),A1
		lea	179*160+152(A1),A1
		lea	scroll_buffer+32*160+152,A2
s_off		SET 0
c_off		SET 0
		REPT 32
		movep.l c_off(A0),D0
		movep.l D0,s_off(A1)
		movep.l D0,s_off(A2)
		movep.l c_off(A3),D0
		movep.l D0,s_off+1(A1)
		movep.l D0,s_off+1(A2)
s_off		SET s_off+160
c_off		SET c_off+24
		ENDR

		move.l  A3,char_pointer1     ; Charpointer2 in Charpointer1 kopieren
		addq.l  #8,A3		; auf n„chsten Bitblock
		addq.w  #1,scroll_counter    ; muž Zeichen angeh„ngt werden?
		cmpi.w  #3,scroll_counter
		bne.s   not_last_bb
		clr.w   scroll_counter

		addq.l  #1,text_pos		; Textpointer weiter
		movea.l text_pos(PC),A0
		cmpi.b  #-1,(A0)
		bne.s   nix_end_text
		lea	scroll_text(PC),A0
nix_end_text:   move.l  A0,text_pos
		moveq   #0,D0
		move.b  (A0)+,D0		; Zeichen holen
		mulu    #768,D0		; mal Gr”že eines Zeichens
		lea	charset,A3
		adda.l  D0,A3		; dort ist neues Zeichen
not_last_bb:    move.l  A3,char_pointer2
		rts


wabbel_logo:
; Kopiert wabbelndes Logo auf den Screen

		movea.l dpos_logo(PC),A4     ; dort ist Wabbeltabelle
		movea.l screen_1(PC),A5
		adda.l  #231*160,A5
		lea	logo_preshift_buff,A6
		moveq   #31,D0		; 32 Zeilen hoch
logo_loop:	movea.l A6,A3
		adda.w  (A4)+,A3		; Wabbelwert addieren
		movem.l (A3)+,D1-A2		; 10 Longs holen
		movem.l D1-A2,(A5)
		movem.l (A3)+,D1-A2		; 10 Longs holen
		movem.l D1-A2,40(A5)
		movem.l (A3)+,D1-A2		; 10 Longs holen
		movem.l D1-A2,80(A5)
		movem.l (A3)+,D1-A2		; 10 Longs holen
		movem.l D1-A2,120(A5)
		lea	160(A5),A5	; n„chste Zeile
		lea	16*160(A6),A6
		dbra    D0,logo_loop
		rts

scroll_up:
; Scroller hoch.
; Buchstaben werden zentriert
		move.w  scroll_noth_count(PC),D0
		beq.s   scroll_normal	; gerade aussetzen?
		subq.w  #1,D0
		move.w  D0,scroll_noth_count
		rts

scroll_normal:  subq.w  #1,scroll_up_count   ; schon 32 Zeilen gescrollt?
		bpl.s   not_end_scrollup
		move.w  #32,scroll_up_count  ; 32 Scanlines hoch
		move.w  #8,scroll_noth_count ; 8 Zeilen nichts scrollen

		lea	scroll_up_point(PC),A1
		movea.l text_pos2(PC),A2     ; dort ist Text
		cmpi.b  #-1,(A2)
		bne.s   not_end_text2
		lea	text(PC),A2
not_end_text2:  moveq   #9,D0		; max 10 Pointer berechnen
		moveq   #0,D7		; Anzahl Zeichen auf 0 setzen
calc_pointers:  moveq   #0,D1
		move.b  (A2)+,D1		; Zeichen holen
		cmp.b   #-2,D1		; Endekennung
		beq.s   end_of_line

		addq.w  #1,D7		; Anzahl Zeichen +1
		lsl.l   #8,D1
		add.l   D1,D1
		lea	font(PC),A0
		adda.l  D1,A0
		move.l  A0,(A1)+		; Pointer ablegen
		dbra    D0,calc_pointers
end_of_line:
		move.l  A2,text_pos2

		moveq   #0,D4		; Offset auf 0 init
		moveq   #10,D6
		sub.w   D7,D6		; jetzt Werte von 0-9 in d6
		btst    #0,D6		; ungerade?
		beq.s   ist_gerade
		moveq   #8,D4		; Offset um 16 Pixel bei ungerade
ist_gerade:
		subq.w  #1,D7		; Anzahl-1 wegen DBRA
		move.w  D7,anzahl_chars	; soviele Buchstaben pro Zeile
		lsr.w   #1,D6		; durch zwei teilen
		lsl.w   #4,D6		; *32 Pixel
		add.w   D6,D4
		move.w  D4,centre_offset

		rts

not_end_scrollup:
		movea.l screen_1(PC),A1
		lea	176*160(A1),A1
		lea	scroll_up_point(PC),A2
		move.w  anzahl_chars(PC),D0  ; soviele Buchstaben
		adda.w  centre_offset(PC),A1 ; um soviel einrcken
knuepf_font:    movea.l (A2),A0		; Pointer holen
		move.w  (A0)+,D1
		move.w  (A0)+,D2
		move.w  (A0)+,D3
		move.w  (A0)+,D4
		move.w  D1,D5		; Maske bilden
		or.w    D2,D5
		or.w    D3,D5
		or.w    D4,D5
		not.w   D5
		and.w   D5,(A1)
		or.w    D1,(A1)+
		and.w   D5,(A1)
		or.w    D2,(A1)+
		and.w   D5,(A1)
		or.w    D3,(A1)+
		and.w   D5,(A1)
		or.w    D4,(A1)+
		move.w  (A0)+,D1
		move.w  (A0)+,D2
		move.w  (A0)+,D3
		move.w  (A0)+,D4
		move.w  D1,D5		; Maske bilden
		or.w    D2,D5
		or.w    D3,D5
		or.w    D4,D5
		not.w   D5
		and.w   D5,(A1)
		or.w    D1,(A1)+
		and.w   D5,(A1)
		or.w    D2,(A1)+
		and.w   D5,(A1)
		or.w    D3,(A1)+
		and.w   D5,(A1)
		or.w    D4,(A1)+
		move.l  A0,(A2)+		; Pointer ablegen
		dbra    D0,knuepf_font

		rts

centre_offset:  DC.W 0		; um soviele Bitblocks springen
anzahl_chars:   DC.W 0		; soviele Zeichen pro Zeile darstellen




klopf_roehre:
; kopiert neue R”hrengrafik in letzte Zeile

		addq.l  #2,dpos_roehre	; Delta-Zeiger weiter
		movea.l dpos_roehre(PC),A0
		cmpi.w  #-99,(A0)	; Tabele zu Ende?
		bne.s   nix_end_dp_r
		lea	delta_roehre(PC),A0
nix_end_dp_r:   move.l  A0,dpos_roehre

		move.w  (A0),D0		; Wert holen
		and.w   #15,D0		; nur Werte von 0-15
		add.w   D0,D0
		add.w   D0,D0		; *4
		lea	roehren_buffer,A0
		move.l  0(A0,D0.w),D0	; Grafik holen
		movea.l screen_1(PC),A0
		lea	176*160(A0),A0
		moveq   #0,D1
		REPT 20	; 20 Bitblocks
		move.l  D0,(A0)+
		move.l  D1,(A0)+
		ENDR
		rts


make_coltab:
; erstellt schwingende Farben

		bsr     make_ste_colors	; rechnet zuerst Palette um

		lea	coltab(PC),A0
		lea	newcoltab,A1	; Spezielles Format erstellen
		move.w  (A0),D1		; Farbe 1, Farbe 0, Farbe 1, Farbe 2,..
create_special_tab:
		move.w  (A0),(A1)+
		cmpi.w  #-1,(A0)
		beq.s   end_cr_sp_tab
		move.w  D1,(A1)+
		move.w  (A0),(A1)+
		move.w  (A0),(A1)+
		move.w  (A0)+,D1
		bra.s   create_special_tab

end_cr_sp_tab:




		lea	delta_cols(PC),A0    ; dort sind Positionen (0-49)
		lea	color_buff,A1
		move.l  A1,col_pointer

		move.w  #anz_delta_cols-1,D0 ; soviele Spalten
make_colsloop0: lea	newcoltab,A2	; da sind Farben
		moveq   #0,D1
		move.b  (A0)+,D1		; Deltawert holen
		add.w   D1,D1		; *2
		adda.w  D1,A2		; auf Farbpointer kopieren
		movea.l A1,A3
		move.w  #199,D1		; 200 Farben reinkopieren
make_colsloop1: move.w  (A2)+,D2
		bpl.s   nix_end_coltab
		lea	newcoltab,A2
		move.w  (A2)+,D2
nix_end_coltab: move.w  D2,(A3)
		lea	anz_delta_cols*2(A3),A3 ; eine Zeile tiefer
		dbra    D1,make_colsloop1
		lea	2(A1),A1		; eine Spalte nach rechts
		dbra    D0,make_colsloop0
		rts


make_ste_colors:
		lea	coltab(PC),A0
ste_umrechen:   move.w  (A0),D0		; Wert holen
		cmp.w   #-1,D0
		beq.s   endumrechen
		move.w  D0,D1
		and.w   #%1111,D1	; nur Bits 0-3
		lsr.w   #1,D1
		bcc.s   nixbluebit
		bset    #3,D1		; rausgechobenes
nixbluebit:     and.w   #-16,D0
		or.w    D1,D0
		move.w  D0,D1
		and.w   #%11110000,D1
		lsr.w   #1,D1
		bclr    #3,D1
		beq.s   nixgreenbit
		bset    #7,D1
nixgreenbit:    and.w   #%1111111100001111,D0
		or.w    D1,D0
		move.w  D0,D1
		and.w   #%111100000000,D1
		lsr.w   #1,D1
		bclr    #7,D1
		beq.s   nixredbit
		bset    #11,D1
nixredbit:	and.w   #%1111000011111111,D0
		or.w    D1,D0
		move.w  D0,(A0)+
		bra.s   ste_umrechen
endumrechen:    rts


make_logo_cols:
; Errechnet Farbtabelle fr das Logo

		lea	logo_paletten(PC),A0
		lea	logo_paletten+32(PC),A1
		lea	logo_col_buffer,A2
		moveq   #uebergaenge-1,D0
make_logo_col_loop:
		bsr     calc_uebergang
		movea.l A1,A0
		lea	32(A1),A1
		lea	24*32(A2),A2
		dbra    D0,make_logo_col_loop

		rts


calc_uebergang:
; berechnet Farbbergang von Palette 1 auf Palette 2
; šbergabewerte:
; a0 = Palette 1 (wird ver„ndert)
; a1 = Palette 2
; a2 = Farbbuffer (dort kommt Palette rein)
; macht 24 Paletten
		movem.l D0-A6,-(A7)


		moveq   #23,D7		; 24 šbergange berechnen

calc_col_loop0: movea.l A0,A5
		movea.l A1,A6

		moveq   #15,D0		; 16 Farben
calc_col_loop1:
		move.w  (A5),D1		; Farbwert Palette 1
		move.w  D1,D3
		move.w  (A6),D2		; Farbwert Palette 2
		and.w   #$0700,D1
		and.w   #$0700,D2	; nur Rotwerte
		cmp.w   D1,D2		; Farben gleich?
		beq.s   rot_is_ok
		blt.s   rot_zu_gross	; alter Rotwert groesser?
		add.w   #$0100,D3	; sonst Rotwert vergroessern
		bra.s   end_col
rot_zu_gross:   sub.w   #$0100,D3	; Rotwert verkleinern
		bra.s   end_col
rot_is_ok:	move.w  D3,D1
		move.w  (A6),D2		; Farbwert Palette 2
		and.w   #$70,D1
		and.w   #$70,D2		; nur Grnwerte
		cmp.w   D1,D2		; Farben gleich?
		beq.s   gruen_is_ok
		blt.s   gruen_zu_gross	; alter Grnwert groesser?
		add.w   #$10,D3		; sonst Grnwert vergroessern
		bra.s   end_col
gruen_zu_gross: sub.w   #$10,D3		; Grnwert verkleinern
		bra.s   end_col
gruen_is_ok:    move.w  D3,D1
		move.w  (A6),D2		; Farbwert Palette 2
		and.w   #$07,D1
		and.w   #$07,D2		; nur Blauwerte
		cmp.w   D1,D2		; Farben gleich?
		beq.s   blau_is_ok
		blt.s   blau_zu_gross	; alter Blauwert groesser?
		addq.w  #$01,D3		; sonst Blauwert vergroessern
		bra.s   end_col
blau_zu_gross:  subq.w  #$01,D3		; Blauwert verkleinern
blau_is_ok:

end_col:	move.w  D3,(A5)+		; Farbe ablegen in Palette 1
		move.w  D3,(A2)+		; in Farbbuffer
		addq.l  #2,A6
		dbra    D0,calc_col_loop1
		dbra    D7,calc_col_loop0

		movem.l (A7)+,D0-A6
		rts




make_roehre:
; preshiftet R”hre
		lea	roehren_buffer,A0
		move.w  roehren_grafik(PC),D1 ; 2 Worte holen
		move.w  roehren_grafik+2(PC),D2
		moveq   #15,D0		; 16 mal shiften
shift_roehre:   move.w  D1,(A0)+
		move.w  D2,(A0)+
		ror.w   #1,D1		; um jeweils 1 nach rechts
		ror.w   #1,D2
		dbra    D0,shift_roehre
		rts

preshift_logo:
; Shiftet Logo 16 Mal. Speicherbedarf: 16*32*160=81920 bytes
; jeweils jede Zeile 16 mal hintereinander

		lea	logo(PC),A6
		lea	logo_preshift_buff,A1
		moveq   #31,D0		; 32 hoch
psl0:		moveq   #0,D1		; 0-16 Shiften
psl1:		movea.l A6,A0
		moveq   #18,D2		; 19 Bitblocks
		moveq   #0,D4
		moveq   #0,D5		; Oderwert auf 0
		moveq   #0,D6
		moveq   #0,D7
psl2:		moveq   #0,D3
		move.w  (A0)+,D3
		ror.l   D1,D3
		or.w    D4,D3
		move.w  D3,(A1)+
		swap    D3
		move.w  D3,D4		; Restwert
		moveq   #0,D3
		move.w  (A0)+,D3
		ror.l   D1,D3
		or.w    D5,D3
		move.w  D3,(A1)+
		swap    D3
		move.w  D3,D5		; Restwert
		moveq   #0,D3
		move.w  (A0)+,D3
		ror.l   D1,D3
		or.w    D6,D3
		move.w  D3,(A1)+
		swap    D3
		move.w  D3,D6		; Restwert
		moveq   #0,D3
		move.w  (A0)+,D3
		ror.l   D1,D3
		or.w    D7,D3
		move.w  D3,(A1)+
		swap    D3
		move.w  D3,D7		; Restwert
		dbra    D2,psl2
		move.w  D4,(A1)+
		move.w  D5,(A1)+
		move.w  D6,(A1)+
		move.w  D7,(A1)+
		addq.w  #1,D1
		cmp.w   #16,D1
		bne.s   psl1
		lea	152(A6),A6	; auf n„chste Scanline
		dbra    D0,psl0
		rts

convert_text:
; Konvertiert Text fr vertikalen Scroller
		lea	text(PC),A0
		lea	contab,A1
convert:	moveq   #0,D0
		move.b  (A0),D0
		cmp.b   #-2,D0		; -2 einfach bernehmen
		bne.s   not_centre_flag
		addq.l  #1,A0
		bra.s   convert
not_centre_flag:cmp.b   #-1,D0
		beq.s   end_convert
		move.b  0(A1,D0.w),(A0)+
		bra.s   convert
end_convert:    rts

vbl		move.l  D0,-(A7)
		move.l  A0,-(A7)

		lea	$ffff8240.w,A0
		moveq   #0,D0		; Palette l”schen
		REPT 8
		move.l  D0,(A0)+
		ENDR

		move.l  #open_top,$68.w	; HBL fr oberen Rand installieren
		move.w  #32,hbl_count	; in dieser Zeile oberen Rand auf
		move    #$2100,SR	; HBL zulassen

		clr.b   $fffffa1b.w
		move.b  #178,$fffffa21.w
		move.b  #8,$fffffa1b.w
		move.l  #timer_b,$0120.w

		addq.l  #1,vsync_count
		movea.l (A7)+,A0
		move.l  (A7)+,D0
		andi.w  #$f1ff,(A7)		; SR auf $2100 setzen
		rte

newkey:	rte
		move.w  D0,-(A7)		; TastaturIRQ
		move.b  $fffffc00.w,D0
		btst    #7,D0
		beq.s   endkey
		move.b  $fffffc02.w,key
endkey:	move.w  (A7)+,D0
		rte

timer_b:
; schaltet Palette fr Font ein
		move.l  A0,-(A7)
		move.l  A1,-(A7)
		move.w  D0,-(A7)
		lea	$fffffa21.w,A0
		clr.b   -6(A0)
		move.b  #32,(A0)
		move.b  #8,-6(A0)
		move.l  #timer_b2,$0120.w
		move.b  (A0),D0
wait_rand:	cmp.b   (A0),D0
		beq.s   wait_rand
		lea	$ffff8240.w,A1
		lea	palette3(PC),A0
		REPT 8
		move.l  (A0)+,(A1)+
		ENDR
		move.w  (A7)+,D0
		movea.l (A7)+,A1
		movea.l (A7)+,A0
		rte


timer_b2:
; schaltet Palette auf Dunkel
		move.l  A0,-(A7)
		move.l  D0,-(A7)
		lea	$fffffa21.w,A0
		clr.b   -6(A0)
timer_b_pos1:   move.b  #17,(A0)		; Hier wird modifiziert
		move.b  #8,-6(A0)
		move.l  #timer_b3,$0120.w
		move.b  (A0),D0
wait_rand2:     cmp.b   (A0),D0
		beq.s   wait_rand2
		lea	$ffff8240.w,A0
		moveq   #0,D0
		REPT 8
		move.l  D0,(A0)+
		ENDR
		move.l  (A7)+,D0
		movea.l (A7)+,A0
		rte


timer_b3:
; klappt unteren Rand auf.
		move.l  A0,-(A7)
		move.w  D0,-(A7)
		lea	$fffffa21.w,A0
		clr.b   -6(A0)
timer_b_pos2:   move.b  #2,(A0)
		move.b  #8,-6(A0)
		move.l  #timer_b4,$0120.w
		move.b  (A0),D0
wait_rand3:     cmp.b   (A0),D0
		beq.s   wait_rand3

		move.b  #0,$ffff820a.w
		DCB.W 16,$4e71
		move.b  #2,$ffff820a.w

		tst.w   logo_schwing_stop
		bne.s   stop_schwing

		eori.w  #1,delay		; nur jeden zweiten VBL
		bne.s   not_now_honey

col_direction:  addi.l  #32,logo_col_point1  ; hier wird Direction eingetragen
not_now_honey:  cmpi.l  #logo_col_buffer+32*24*uebergaenge-8*32,logo_col_point1
		bne.s   not_end_tab
		move.l  #-32,col_direction+2
		bra.s   stop_schwing
not_end_tab:    cmpi.l  #logo_col_buffer-32,logo_col_point1
		bne.s   stop_schwing
		move.l  #32,col_direction+2
		move.l  #logo_col_buffer,logo_col_point1

stop_schwing:
		move.l  logo_col_point1(PC),logo_col_pointer

		move.w  (A7)+,D0
		movea.l (A7)+,A0
		rte

logo_schwing_stop:DC.W 0	; auf -1 wenn anhalten

testpointer:    DC.L logo_col_buffer
delay:		DC.W 0


timer_b4:
; setzt Paletten fr Logo
		move.l  A0,-(A7)
		move.l  A1,-(A7)
		move.w  D0,-(A7)
		lea	$fffffa21.w,A0
		clr.b   -6(A0)
		move.b  #4,(A0)
		move.b  #8,-6(A0)
		move.l  #timer_b5,$0120.w
		move.b  (A0),D0
wait_rand4:     cmp.b   (A0),D0
		beq.s   wait_rand4
		lea	$ffff8240.w,A1
		movea.l logo_col_pointer(PC),A0
		REPT 8
		move.l  (A0)+,(A1)+
		ENDR

		move.w  #8,tb_count		; Z„hler setzen
		move.l  A0,logo_col_pointer

		move.w  (A7)+,D0
		movea.l (A7)+,A1
		movea.l (A7)+,A0
		rte


timer_b5:
; setzt Paletten fr Logos
		move.l  A0,-(A7)
		move.l  A1,-(A7)
		move.l  D0,-(A7)

		lea	$ffff8240.w,A1

		move.b  $fffffa21.w,D0
wait_rand5:     cmp.b   $fffffa21.w,D0
		beq.s   wait_rand5

		subq.w  #1,tb_count		; letzte Zeile
		bne.s   nix_end_tb5

		moveq   #0,D0
		REPT 8
		move.l  D0,(A1)+		; Palette l”schen
		ENDR
		clr.b   $fffffa1b.w		;Timer B aus
		bra.s   end_timer_b5

nix_end_tb5:
		movea.l logo_col_pointer(PC),A0
		REPT 8
		move.l  (A0)+,(A1)+
		ENDR

		move.l  A0,logo_col_pointer

end_timer_b5:   move.l  (A7)+,D0
		movea.l (A7)+,A1
		movea.l (A7)+,A0
		rte

tb_count:	DC.W 31
logo_col_pointer:DC.L logo_col_buffer
logo_col_point1:DC.L logo_col_buffer

;------------------------ Syncscrolling ----------------------------

set_screen:
; in d0 = Screenadresse
; setzt Lowbyte mit Syncscrolling (beim STE normal)

		move.l  sync_pointer1(PC),D1 ; Pointer tauschen
		move.l  sync_pointer2(PC),sync_pointer1
		move.l  D1,sync_pointer2

		move.w  D0,D1
		and.w   #255,D1		; nur Lowbyte
		lea	sync_tabelle(PC),A0
		adda.w  D1,A0
		move.l  (A0)+,sync_pointer2  ; Pointer auf Sync-Routine
		add.l   (A0)+,D0		; dieser Offset wird abgezogen

		lsr.l   #8,D0
		lea	$ffff8201.w,A0
		movep.w D0,0(A0)
		rts


init_sync_scrolling:
		bsr     get_anzahl_zeilen    ; ermitteln, wieviel Scanlines dargestellt werden
		move.w  anzahl_zeilen(PC),D0
		sub.w   #211,D0		; dort wird unterer Rand aufgemacht
		move.w  D0,timer_b_pos1+2    ; in selbstmodifizierenden Code
		moveq   #20,D1
		sub.w   D0,D1
		move.w  D1,timer_b_pos2+2
		rts



get_anzahl_zeilen:
; Routine ermittelt die MMU des ST's, d.h. wieviele Zeilen dargestellt werden
; (wenn oberer Rand auf ist)

		move    #$2700,SR
		move.l  $70.w,-(A7)		; VBL und HBL retten
		move.l  $68.w,-(A7)

		move.l  #test_vbl,$70.w
		move.l  #test_hbl1,$68.w
		move.w  #340,hbl_count	; Wert sehr hoch setzen

		move    #$2300,SR
		bsr     vsync

		clr.b   $fffffa1b.w
		move.b  #255,$fffffa21.w
		move.b  #8,$fffffa1b.w	; Timer B start

		move.b  $ffff8209.w,D0
wait_lowbyte:   cmp.b   $ffff8209.w,D0
		beq.s   wait_lowbyte

		moveq   #0,D1
wait_loop:	addq.w  #1,D1
		cmp.w   #5,D1
		bgt.s   wait_ready
		move.b  $ffff8209.w,D0
		cmp.b   $ffff8209.w,D0
		beq.s   wait_loop
		moveq   #0,D1
		bra.s   wait_loop
wait_ready:     move.w  #255,D0
		sub.b   $fffffa21.w,D0	; aktuelle Z„hler abziehen
		move.w  D0,anzahl_zeilen
		bsr     vsync

		move    #$2700,SR

		move.l  (A7)+,$68.w
		move.l  (A7)+,$70.w
		move    #$2300,SR
		rts

test_vbl:	move.w  #32,hbl_count	; dort oberen Rand aufmachen
		move.l  #test_hbl1,$68.w     ; HBL Routine
		addq.l  #1,vsync_count
		andi.w  #$f1ff,(A7)		; HBL erlauben (SR auf $2100)
		rte

test_hbl1:	subq.w  #1,hbl_count
		bmi.s   test_hbl2
		rte
test_hbl2:	move.l  #test_hbl3,$68.w     ; neuen HBL setzen
wait_for_hbl:   stop    #$2100		; warten bis HBL da!
		bra.s   wait_for_hbl

test_hbl3:	move    #$2700,SR	; alle IRQ's aus
		addq.l  #6,A7		; Stack korrigieren
		DCB.W 89,$4e71
		move.b  #0,$ffff820a.w	; 60 Hz
		DCB.W 17,$4e71
		move.b  #2,$ffff820a.w	; 50 Hz
		ori.w   #$0300,(A7)		; SR auf $2300
		rte

anzahl_zeilen:  DC.W 0




hbl_count:	DC.W 32

open_top:	subq.w  #1,hbl_count	; solange, bis Zeile erreicht
		bmi.s   hbl_is_da
		rte

hbl_is_da:	move.l  #open_top_2,$68.w
waithere:	stop    #$2100
		bra.s   waithere

open_top_2:
; klappt den oberen Rand auf

		move    #$2700,SR

		addq.l  #6,A7		; Stack korrigieren

		movem.l D0-A6,-(A7)

		DCB.W 56,$4e71

		move.b  #0,$ffff820a.w	; 60 Hz

		DCB.W 17,$4e71

		move.b  #2,$ffff820a.w	; 50 Hz

		movea.l sync_pointer2(PC),A0 ; Pointer auf Routinen
		lea	$ffff8209.w,A2

		lea	$ffff820a.w,A3
		lea	$ffff8260.w,A4
		moveq   #0,D0
		moveq   #2,D1

		moveq   #0,D2
wait_sync2:     move.b  (A2),D2
		cmp.w   #64,D2
		blt.s   wait_sync2
		sub.w   #64,D2
		not.w   D2
		lsr.w   D2,D2

		DCB.W 38-5,$4e71

		movea.l (A0)+,A1		; Routine aus Tabelle holen
		jmp     (A1)		 ; und diese anspringen


end_sync:

		DCB.W 80,$4e71

		lea	$ffff8242.w,A1
		lea	2(A1),A2

		movea.l col_pointer,A0	; Pointer auf Colorbuffer
		moveq   #31,D0		; soviele Zeilen (*5) wegen Logo
		movea.l screen_1(PC),A5
		lea	179*160(A5),A5
		movea.l scrollpointer1(PC),A6
		lea	8(A6),A6		; auf ersten Bitblock

		lea	palette+8(PC),A3
		lea	$ffff8240+8.w,A4
		REPT 6
		move.l  (A3)+,(A4)+
		ENDR


color_loop:
; schiebt Scroller im Syncloop um 16 Pixel nach vorne

		REPT 8
		move.w  (A0)+,(A1)	;(32)
		move.l  (A0)+,(A2)
		ENDR
		movem.l (A6)+,D1-D7/A3	;(76)
		movem.l D1-D7/A3,-40(A6)     ;(76)
		movem.l D1-D7/A3,(A5)	;(72)
		lea	32(A5),A5	;(8)
		DCB.W 3,$4e71
		lea	anz_delta_cols*2-8*6-4(A0),A0 ; (6*8=48)
;--------
		REPT 8
		move.w  (A0)+,(A1)	;(32)
		move.l  (A0)+,(A2)
		ENDR
		movem.l (A6)+,D1-D7/A3	;(76)
		movem.l D1-D7/A3,-40(A6)     ;(76)
		movem.l D1-D7/A3,(A5)	;(72)
		lea	32(A5),A5	;(8)
		DCB.W 3,$4e71
		lea	anz_delta_cols*2-8*6(A0),A0 ; (6*8=48)
;--------
		REPT 8
		move.w  (A0)+,(A1)		;(32)
		move.l  (A0)+,(A2)
		ENDR
		movem.l (A6)+,D1-D7/A3	;(76)
		movem.l D1-D7/A3,-40(A6)     ;(76)
		movem.l D1-D7/A3,(A5)	;(72)
		lea	32(A5),A5	;(8)
		DCB.W 4,$4e71
		lea	anz_delta_cols*2-8*6-4(A0),A0 ; (6*8=48)
;--------
		REPT 8
		move.w  (A0)+,(A1)		;(32)
		move.l  (A0)+,(A2)
		ENDR
		movem.l (A6)+,D1-D7/A3	;(76)
		movem.l D1-D7/A3,-40(A6)     ;(76)
		movem.l D1-D7/A3,(A5)	;(72)
		lea	32(A5),A5	;(8)
		DCB.W 4,$4e71
		lea	anz_delta_cols*2-8*6-2(A0),A0 ; (6*8=48)
;--------
		REPT 8
		move.w  (A0)+,(A1)		;(32)
		move.l  (A0)+,(A2)
		ENDR
		movem.l (A6)+,D1-D6		;(60)
		movem.l D1-D6,-32(A6)	;(60)
		movem.l D1-D6,(A5)		;(56)
		lea	32(A5),A5	;(8)
		lea	8(A6),A6		;(8)
		DCB.W 8,$4e71
		lea	anz_delta_cols*2-8*6(A0),A0 ; (6*8=48)
;--------
		dbra    D0,color_loop	; (12)

		lea	$ffff8240.w,A0
		moveq   #0,D0		; Palette l”schen
		REPT 8
		move.l  D0,(A0)+
		ENDR

		move    #$2500,SR

		addq.l  #2,col_pointer	; Pointer in Tabelle weiter
		movea.l col_pointer,A0
		cmpa.l  #color_buff+2*anz_delta_cols,A0
		bne.s   nix_end_colp
		lea	color_buff,A0
nix_end_colp:   move.l  A0,col_pointer

		addq.l  #2,dpos_logo	; Logo-wabbler um 1 weiter
		movea.l dpos_logo(PC),A0
		cmpa.l  #delta_logo_ende,A0
		bne.s   nix_end_dp_l
		lea	delta_logo(PC),A0
nix_end_dp_l:   move.l  A0,dpos_logo

		bsr     nachschubpuffer

		bsr     wabbel_logo

		bsr     music+8

		bsr     klopf_roehre
		bsr     scroll_up

		movea.l screen_1(PC),A0
		movea.l A0,A1
		lea	14*160(A1),A1
		lea	176*160(A0),A0
		moveq   #39,D0
copy_last_line: move.l  (A0)+,(A1)+
		dbra    D0,copy_last_line

		addi.l  #160,screen_1
		move.l  screen_buffer(PC),D1 ; dort f„ngt Screen an
		move.l  D1,D2
		add.l   #162*160,D2
		move.l  screen_1(PC),D0
		cmp.l   D2,D0
		blt.s   not_end_screen
		move.l  D1,D0
not_end_screen: move.l  D0,screen_1

		bsr     set_screen

		move.l  scrollpointer1(PC),D0 ; Pointer auf Buffer tauschen
		move.l  scrollpointer2(PC),scrollpointer1
		move.l  D0,scrollpointer2
		eori.w  #-1,scroll_flag	; Scrollflag umdrehen

		movem.l (A7)+,D0-A6
		ori.w   #$0300,(A7)		; SR auf $2300 setzen
		rte



sync_pointer1:  DC.L s_offset_0
sync_pointer2:  DC.L s_offset_0

sync_tabelle:
; zu jedem Offset (in 8er Schritten) Pointer auf Routinen und Offset auf Screen

		DC.L s_offset_0
		DC.L 0
		DC.L s_offset_0
		DC.L 0
		DC.L s_offset_0
		DC.L 0
		DC.L s_offset_0
		DC.L 0
		DC.L s_offset_32
		DC.L -512
		DC.L s_offset_0
		DC.L 0
		DC.L s_offset_0
		DC.L 0
		DC.L s_offset_0
		DC.L 0
		DC.L s_offset_64
		DC.L -768
		DC.L s_offset_0
		DC.L 0
		DC.L s_offset_0
		DC.L 0
		DC.L s_offset_0
		DC.L 0
		DC.L s_offset_96
		DC.L -256
		DC.L s_offset_0
		DC.L 0
		DC.L s_offset_0
		DC.L 0
		DC.L s_offset_0
		DC.L 0
		DC.L s_offset_128
		DC.L -512
		DC.L s_offset_0
		DC.L 0
		DC.L s_offset_0
		DC.L 0
		DC.L s_offset_0
		DC.L 0
		DC.L s_offset_160
		DC.L -768
		DC.L s_offset_0
		DC.L 0
		DC.L s_offset_0
		DC.L 0
		DC.L s_offset_0
		DC.L 0
		DC.L s_offset_192
		DC.L -256
		DC.L s_offset_0
		DC.L 0
		DC.L s_offset_0
		DC.L 0
		DC.L s_offset_0
		DC.L 0
		DC.L s_offset_224
		DC.L -512
		DC.L s_offset_0
		DC.L 0
		DC.L s_offset_0
		DC.L 0
		DC.L s_offset_0
		DC.L 0



; Hier sind die Pointertabellen fr die jeweiligen gewnschten Offsets
; auf jeweils immer 14 Scanlines erweitert (nur fr vertikales Scrolling)

s_offset_0:     REPT 14
		DC.L sync_routine0
		ENDR
		DC.L end_sync


s_offset_32:    REPT 4
		DC.L sync_routine1
		ENDR
		REPT 6
		DC.L sync_routine5
		ENDR
		REPT 4
		DC.L sync_routine0
		ENDR
		DC.L end_sync

s_offset_64:    REPT 10
		DC.L sync_routine1
		ENDR
		REPT 3
		DC.L sync_routine5
		ENDR
		REPT 1
		DC.L sync_routine0
		ENDR
		DC.L end_sync

s_offset_96:    REPT 8
		DC.L sync_routine5
		ENDR
		REPT 6
		DC.L sync_routine0
		ENDR
		DC.L end_sync

s_offset_128:   REPT 6
		DC.L sync_routine1
		ENDR
		REPT 5
		DC.L sync_routine5
		ENDR
		REPT 3
		DC.L sync_routine0
		ENDR
		DC.L end_sync

s_offset_160:   REPT 12
		DC.L sync_routine1
		ENDR
		REPT 2
		DC.L sync_routine5
		ENDR
		DC.L end_sync

s_offset_192:   REPT 2
		DC.L sync_routine1
		ENDR
		REPT 7
		DC.L sync_routine5
		ENDR
		REPT 5
		DC.L sync_routine0
		ENDR
		DC.L end_sync

s_offset_224:   REPT 8
		DC.L sync_routine1
		ENDR
		REPT 4
		DC.L sync_routine5
		ENDR
		REPT 2
		DC.L sync_routine0
		ENDR
		DC.L end_sync




; Hier sind die Routinen, die die R„nder aufmachen

sync_routine1:
; klappt beide R„nder auf.
; braucht 70 Bytes
		move.b  D1,(A4)		; Highres
		nop
		move.b  D0,(A4)		; Lowres (Links auf)

		DCB.W 89,$4e71

		move.b  D0,(A3)		; 60Hz
		move.b  D1,(A3)		; 50Hz (Rechts auf)

		DCB.W 13,$4e71

		move.b  D1,(A4)		; Highres
		nop
		move.b  D0,(A4)		; Lowres (Rechts zu)

		DCB.W 12-5,$4e71
		movea.l (A0)+,A1		; n„chste Routine holen (12)
		jmp     (A1)		 ; und die anspringen    (8)


sync_routine5:
; stellt 44 Bytes dar
		move.b  D0,(A4)		; Lowres
		nop
		move.b  D0,(A4)		; Lowres (Links auf)

		DCB.W 89,$4e71

		move.b  D0,(A3)		; 60Hz
		move.b  D1,(A3)		; 50Hz (Rechts auf)

		DCB.W 13,$4e71

		move.b  D0,(A4)		; Lowres
		nop
		move.b  D0,(A4)		; Lowres (Rechts zu)

		DCB.W 12-5,$4e71

		movea.l (A0)+,A1	; n„chste Routine holen (12)
		jmp     (A1)		 ; und die anspringen    (8)

sync_routine0:
; macht 512 TZ lang nichts
		DCB.W 128-5,$4e71
		movea.l (A0)+,A1	; n„chste Routine holen (12)
		jmp     (A1)		 ; und die anspringen    (8)



;-------------------- Syncscrolling Ende --------------------------------


		DATA
screen_1:	DC.L 0		; so weit oben damit PC-Relativer Zugriff
screen_buffer:  DC.L 0
key		DC.W 0
scroll_up_count:DC.W 0
scroll_up_point:DS.L 10	; dort kommen die 10 Pointer auf die Scroller hin
scroll_flag:    DC.W 0
scroll_counter: DC.W 0
scroll_noth_count:DC.W 0
scrollpointer1: DC.L scroll_buffer
scrollpointer2: DC.L scroll_buffer+32*160
char_pointer1:  DC.L charset+45*32*24
char_pointer2:  DC.L charset+45*32*24
text_pos:	DC.L scroll_text
text_pos2:	DC.L text

scroll_text:
		DCB.B 20,45
		INCBIN 'BILBO.IMG'
		EVEN

; # Front 1
; * Front 2
; $%& Front Breit
text:
; Vertikaler Text
; Maximal 10 breit, bei kleineren -2 anh„ngen zum Zentrieren (aber nur dort!!!)
; -1 ist Endekennung
;		   >>**********<<

		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2

		DC.B "HI GUYS!",-2
		DC.B " ",-2
		DC.B "DELTA     "
		DC.B "     FORCE"
		DC.B " ",-2
		DC.B "OF",-2
		DC.B " ",-2
		DC.B "THE UNION",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B "IS BACK",-2
		DC.B "WITH A NEW"
		DC.B "SCREEN",-2
		DC.B "CALLED",-2
		DC.B " ",-2
		DC.B "**********"
		DC.B "COPPER-   "
		DC.B " KAAAAAH- "
		DC.B "  BAAAAAH-"
		DC.B "   NAAAAAH"
		DC.B "**********"
		DC.B " ",-2
		DC.B " ",-2
		DC.B "##########"
		DC.B " ",-2
		DC.B "CREDITS:",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B "CODING",-2
		DC.B " ",-2
		DC.B "NEW MODE",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B "GRAPHICS",-2
		DC.B " ",-2
		DC.B "TANIS  TCB"
		DC.B " ",-2
		DC.B "HORIZONTAL"
		DC.B "FONT AND",-2
		DC.B "LOGO",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B "SLIME",-2
		DC.B " ",-2
		DC.B "THIS FONT",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B "MUSIC",-2
		DC.B " ",-2
		DC.B "BIG ALEC",-2
		DC.B " ",-2
		DC.B "##########"
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B "MEMBERS OF"
		DC.B " ",-2
		DC.B "DELTA     "
		DC.B "     FORCE"
		DC.B " ",-2
		DC.B "ARE:",-2
		DC.B " ",-2
		DC.B "**********"
		DC.B "BIG ALEC  "
		DC.B "     MUSIC"
		DC.B " ",-2
		DC.B "CHAOS INC."
		DC.B "     CODER"
		DC.B " ",-2
		DC.B "DANIEL    "
		DC.B "     CODER"
		DC.B " ",-2
		DC.B "EARTHLIGHT"
		DC.B "   PAINTER"
		DC.B " ",-2
		DC.B "FLIX      "
		DC.B "     CODER"
		DC.B " ",-2
		DC.B "MASCOT    "
		DC.B "    GIRLIE"
		DC.B " ",-2
		DC.B "NEW MODE  "
		DC.B "     CODER"
		DC.B " ",-2
		DC.B "QUESTLORD "
		DC.B "  GRAPHICS"
		DC.B " ",-2
		DC.B "RAY       "
		DC.B "     CODER"
		DC.B " ",-2
		DC.B "SAMMY JOE "
		DC.B "    MAGGIE"
		DC.B " ",-2
		DC.B "SLIME     "
		DC.B "  GRAPHICS"
		DC.B " ",-2
		DC.B "THOR      "
		DC.B "  GRAPHICS"
		DC.B "**********"
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B "IF YOU",-2
		DC.B "WANT TO",-2
		DC.B "BUY A",-2
		DC.B "SOURCECODE"
		DC.B "FROM OUR",-2
		DC.B "SYNTAX    "
		DC.B "    TERROR"
		DC.B "DEMO",-2
		DC.B "OR",-2
		DC.B "SOURCES",-2
		DC.B "OF THIS",-2
		DC.B "DEMO",-2
		DC.B "THEN SEND",-2
		DC.B "15 GERMAN",-2
		DC.B "MARKS (DM)"
		DC.B "FOR EACH",-2
		DC.B "SOURCECODE"
		DC.B " ",-2
		DC.B " ",-2
		DC.B "EACH",-2
		DC.B "SOURCECODE"
		DC.B "IS FOR",-2
		DC.B "DEVPAC 2",-2
		DC.B "AND",-2
		DC.B "CONTAINS",-2
		DC.B "ALL FILES",-2
		DC.B "TO RUN IT."
		DC.B " ",-2
		DC.B " ",-2
		DC.B "EACH",-2
		DC.B "SOURCECODE"
		DC.B "IS FULLY",-2
		DC.B "DOCUMENTED"
		DC.B " ",-2
		DC.B " ",-2
		DC.B "B U T",-2
		DC.B "YOU CAN'T",-2
		DC.B "BUY ANY",-2
		DC.B "GUEST-",-2
		DC.B "SCREENS!",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B "ACCEPT NO",-2
		DC.B " ",-2
		DC.B "IMITATIONS"
		DC.B " ",-2
		DC.B " ",-2
		DC.B "-ONLY-",-2
		DC.B " ",-2
		DC.B "THE UNION",-2
		DC.B " ",-2
		DC.B "RULES!",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B "SINCE THIS"
		DC.B "TEXT IS A",-2
		DC.B "BASTARD TO"
		DC.B "TYPE IN,",-2
		DC.B "WE WRAP..."
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B "COPYRIGHT",-2
		DC.B "MCMXCI BY",-2
		DC.B "NEW MODE",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B " ",-2
		DC.B -1
		EVEN

palette:				     ; vertikaler Font
		DC.W $00,$37,$0700,$0770,$00,$60,$50,$40
		DC.W $30,$20,$0222,$0333,$0444,$0555,$0666,$0506

palette3:				    ; Palette fr Scroller
		DC.W $00,$0300,$0400,$0510,$0520,$0630,$0740,$0750
		DC.W $0760,$0770,$0774,$0776,$0777,$0620,$0200,$0730


logo_paletten:
		DS.W 16

		DC.W $0777
		DS.W 15

		DC.W $00
		DCB.W 15,$0777

		DC.W $00,$02,$03,$14,$25,$36,$47,$57
		DC.W $67,$0322,$0577,$0777,$0433,$0544,$0655,$0766

		DC.W $00,$0200,$0300,$0410,$0520,$0630,$0740,$0750
		DC.W $0760,$0223,$0775,$0777,$0334,$0445,$0556,$0667

		DC.W $00,$0200,$0300,$0401,$0502,$0603,$0704,$0705
		DC.W $0706,$0223,$0757,$0777,$0334,$0445,$0556,$0667

		DCB.W 16,$0777

		DC.W $00,$0111,$0222,$0333,$0444,$0555,$0666,$0777
		DC.W $0777,$0223,$0777,$0777,$0334,$0445,$0556,$0667

		DC.W $00,$0100,$0210,$0321,$0432,$0543,$0654,$0765
		DC.W $0776,$0223,$0777,$0777,$0334,$0445,$0556,$0667

		DC.W $00,$01,$0112,$0223,$0334,$0445,$0556,$0667
		DC.W $0777,$0223,$0777,$0777,$0334,$0445,$0556,$0667

		DC.W $00,$0101,$0212,$0323,$0434,$0545,$0656,$0767
		DC.W $0777,$0223,$0777,$0777,$0334,$0445,$0556,$0667

		DS.W 16

		DC.W $00,$0202,$0404,$0414,$0525,$0636,$0747,$0757
		DC.W $0767,$0223,$0777,$0777,$0334,$0445,$0556,$0667

		DC.W $0777,$0202,$0404,$0414,$0525,$0636,$0747,$0757
		DC.W $0767,$0223,$0777,$0777,$0334,$0445,$0556,$0667

		DS.W 16

		DC.W $00,$0111,$0222,$0333,$0444,$0555,$0666,$0777
		DC.W $0777,$0223,$0777,$0777,$0334,$0445,$0556,$0667


logo_paletten_ende:
uebergaenge     EQU (logo_paletten_ende-logo_paletten)/32-1


coltab:
; ste-Colors (mssen noch umgerechnet werden)

		DC.W $0101,$0202,$0303,$0404,$0505,$0606,$0707,$0808,$0909,$0a0a
		DC.W $0b0b,$0c0c,$0d0d,$0e0e,$0f0f
		DC.W $0f0e,$0f0d,$0f0c,$0f0b,$0f0a,$0f09,$0f08,$0f07,$0f06,$0f05
		DC.W $0f04,$0f03,$0f02,$0f01,$0f00
		DC.W $0f10,$0f20,$0f30,$0f40,$0f50,$0f60,$0f70,$0f80,$0f90
		DC.W $0fa0,$0fb0,$0fc0,$0fd0,$0fe0,$0ff0
		DC.W $0ff1,$0ff2,$0ff3,$0ff4,$0ff5,$0ff6,$0ff7,$0ff8,$0ff9,$0ffa
		DC.W $0ffb,$0ffc,$0ffd,$0ffe,$0fff
		DC.W $0eff,$0dff,$0cff,$0bff,$0aff,$09ff,$08ff,$07ff,$06ff
		DC.W $05ff,$04ff,$03ff,$02ff,$01ff,$ff
		DC.W $ef,$df,$cf,$bf,$af,$9f,$8f,$7f,$6f,$5f,$4f,$3f,$2f,$1f,$0f
		DC.W $011f,$022f,$033f,$044f,$055f,$066f,$077f,$088f,$099f,$0aaf
		DC.W $0bbf,$0ccf,$0ddf,$0eef,$0fff
		DC.W $0efe,$0dfd,$0cfc,$0bfb,$0afa,$09f9,$08f8,$07f7,$06f6
		DC.W $05f5,$04f4,$03f3,$02f2,$01f1,$f0
		DC.W $01f0,$02f0,$03f0,$04f0,$05f0,$06f0,$07f0,$08f0
		DC.W $09f0,$0af0,$0bf0,$0cf0,$0df0,$0ef0,$0ff0
		DC.W $0ff1,$0ff2,$0ff3,$0ff4,$0ff5,$0ff6,$0ff7,$0ff8,$0ff9
		DC.W $0ffa,$0ffb,$0ffc,$0ffd,$0ffe,$0fff
		DC.W $0ffe,$0ffd,$0ffc,$0ffb,$0ffa,$0fe9,$0fd8,$0fc7,$0fb6
		DC.W $0fa5,$0e94,$0d83,$0c72,$0b61,$0a50,$0940,$0830,$0720,$0610
		DC.W $0500,$0400,$0300,$0200,$0100
		DC.W $01,$02,$03,$14,$25,$36,$0147,$0258
		DC.W $0369,$047a,$058b,$069c,$07ad,$08be,$09cf,$0adf,$0bef,$0cff
		DC.W $0dff,$0eff,$0fff
		DC.W $0eee,$0ddd,$0ccc,$0bbb,$0aaa,$0999,$0888,$0777,$0666,$0555
		DC.W $0444,$0333,$0222,$0111
coltabende:
anzcols	EQU coltabende-coltab

		DC.W -1


delta_cols:
; Schwingdaten fr gesamten Farbhintergrund

		DC.B 100,101,103,105,106,108,110,112
		DC.B 113,115,117,119,120,122,124,125
		DC.B 127,129,130,132,134,135,137,139
		DC.B 140,142,143,145,146,148,150,151
		DC.B 152,154,155,157,158,160,161,162
		DC.B 164,165,166,168,169,170,171,173
		DC.B 174,175,176,177,178,179,180,181
		DC.B 182,183,184,185,186,187,188,189
		DC.B 189,190,191,192,192,193,193,194
		DC.B 195,195,196,196,197,197,197,198
		DC.B 198,198,199,199,199,199,199,199
		DC.B 199,199,200,199,199,199,199,199
		DC.B 199,199,199,198,198,198,197,197
		DC.B 197,196,196,195,195,194,193,193
		DC.B 192,192,191,190,189,189,188,187
		DC.B 186,185,184,183,182,181,180,179
		DC.B 178,177,176,175,174,173,171,170
		DC.B 169,168,166,165,164,162,161,160
		DC.B 158,157,155,154,152,151,150,148
		DC.B 146,145,143,142,140,139,137,135
		DC.B 134,132,130,129,127,125,124,122
		DC.B 120,119,117,115,113,112,110,108
		DC.B 106,105,103,101,100,98,96,94
		DC.B 93,91,89,87,86,84,82,80
		DC.B 79,77,75,74,72,70,69,67
		DC.B 65,64,62,60,59,57,56,54
		DC.B 53,51,49,48,47,45,44,42
		DC.B 41,39,38,37,35,34,33,31
		DC.B 30,29,28,26,25,24,23,22
		DC.B 21,20,19,18,17,16,15,14
		DC.B 13,12,11,10,10,9,8,7
		DC.B 7,6,6,5,4,4,3,3
		DC.B 2,2,2,1,1,1,0,0
		DC.B 0,0,0,0,0,0,0
		DC.B 0,0,0,0,0,0,0,1
		DC.B 1,1,2,2,2,3,3,4
		DC.B 4,5,6,6,7,7,8,9
		DC.B 10,10,11,12,13,14,15,16
		DC.B 17,18,19,20,21,22,23,24
		DC.B 25,26,28,29,30,31,33,34
		DC.B 35,37,38,39,41,42,44,45
		DC.B 47,48,49,51,53,54,56,57
		DC.B 59,60,62,64,65,67,69,70
		DC.B 72,74,75,77,79,80,82,84
		DC.B 86,87,89,91,93,94,96,98
		DC.B 99

end_delta_cols:
anz_delta_cols  EQU end_delta_cols-delta_cols
		EVEN


dpos_roehre:    DC.L delta_roehre

delta_roehre:
; beliebige Werte (werden mit AND #15 gekrzt)

		DC.W 160,162,165,168,171,173,176,179
		DC.W 182,185,187,190,193,195,198,201
		DC.W 204,206,209,212,214,217,219,222
		DC.W 225,227,230,232,235,237,240,242
		DC.W 244,247,249,251,254,256,258,260
		DC.W 262,264,267,269,271,273,275,277
		DC.W 278,280,282,284,286,287,289,291
		DC.W 292,294,295,297,298,299,301,302
		DC.W 303,305,306,307,308,309,310,311
		DC.W 312,313,313,314,315,315,316,317
		DC.W 317,318,318,318,319,319,319,319
		DC.W 319,319,319,319,319,319,319
		DC.W 319,318,318,318,317,317,316,315
		DC.W 315,314,313,313,312,311,310,309
		DC.W 308,307,306,305,303,302,301,299
		DC.W 298,297,295,294,292,291,289,287
		DC.W 286,284,282,280,278,277,275,273
		DC.W 271,269,267,264,262,260,258,256
		DC.W 254,251,249,247,244,242,240,237
		DC.W 235,232,230,227,225,222,219,217
		DC.W 214,212,209,206,204,201,198,195
		DC.W 193,190,187,185,182,179,176,173
		DC.W 171,168,165,162,160,157,154,151
		DC.W 148,146,143,140,137,134,132,129
		DC.W 126,124,121,118,115,113,110,107
		DC.W 105,102,100,97,94,92,89,87
		DC.W 84,82,79,77,75,72,70,68
		DC.W 65,63,61,59,57,55,52,50
		DC.W 48,46,44,42,41,39,37,35
		DC.W 33,32,30,28,27,25,24,22
		DC.W 21,20,18,17,16,14,13,12
		DC.W 11,10,9,8,7,6,6,5
		DC.W 4,4,3,2,2,1,1,1
		DC.W 0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,1,1,1
		DC.W 2,2,3,4,4,5,6,6
		DC.W 7,8,9,10,11,12,13,14
		DC.W 16,17,18,20,21,22,24,25
		DC.W 27,28,30,32,33,35,37,39
		DC.W 41,42,44,46,48,50,52,55
		DC.W 57,59,61,63,65,68,70,72
		DC.W 75,77,79,82,84,87,89,92
		DC.W 94,97,100,102,105,107,110,113
		DC.W 115,118,121,124,126,129,132,134
		DC.W 137,140,143,146,148,151,154,157
		DC.W 159

		DC.W 160,173,187,201,214,227,240,251
		DC.W 262,273,282,291,298,305,310,314
		DC.W 317,319,319,317,314,310,305
		DC.W 298,291,282,273,262,251,240,227
		DC.W 214,201,187,173,160,146,132,118
		DC.W 105,92,79,68,57,46,37,28
		DC.W 21,14,9,5,2,0,0,0
		DC.W 2,5,9,14,21,28,37,46
		DC.W 57,68,79,92,105,118,132,146
		DC.W 159

		DC.W 160,162,165,168,171,173,176,179
		DC.W 182,185,187,190,193,195,198,201
		DC.W 204,206,209,212,214,217,219,222
		DC.W 225,227,230,232,235,237,240,242
		DC.W 244,247,249,251,254,256,258,260
		DC.W 262,264,267,269,271,273,275,277
		DC.W 278,280,282,284,286,287,289,291
		DC.W 292,294,295,297,298,299,301,302
		DC.W 303,305,306,307,308,309,310,311
		DC.W 312,313,313,314,315,315,316,317
		DC.W 317,318,318,318,319,319,319,319
		DC.W 319,319,319,319,319,319,319
		DC.W 319,318,318,318,317,317,316,315
		DC.W 315,314,313,313,312,311,310,309
		DC.W 308,307,306,305,303,302,301,299
		DC.W 298,297,295,294,292,291,289,287
		DC.W 286,284,282,280,278,277,275,273
		DC.W 271,269,267,264,262,260,258,256
		DC.W 254,251,249,247,244,242,240,237
		DC.W 235,232,230,227,225,222,219,217
		DC.W 214,212,209,206,204,201,198,195
		DC.W 193,190,187,185,182,179,176,173
		DC.W 171,168,165,162,160,157,154,151
		DC.W 148,146,143,140,137,134,132,129
		DC.W 126,124,121,118,115,113,110,107
		DC.W 105,102,100,97,94,92,89,87
		DC.W 84,82,79,77,75,72,70,68
		DC.W 65,63,61,59,57,55,52,50
		DC.W 48,46,44,42,41,39,37,35
		DC.W 33,32,30,28,27,25,24,22
		DC.W 21,20,18,17,16,14,13,12
		DC.W 11,10,9,8,7,6,6,5
		DC.W 4,4,3,2,2,1,1,1
		DC.W 0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,1,1,1
		DC.W 2,2,3,4,4,5,6,6
		DC.W 7,8,9,10,11,12,13,14
		DC.W 16,17,18,20,21,22,24,25
		DC.W 27,28,30,32,33,35,37,39
		DC.W 41,42,44,46,48,50,52,55
		DC.W 57,59,61,63,65,68,70,72
		DC.W 75,77,79,82,84,87,89,92
		DC.W 94,97,100,102,105,107,110,113
		DC.W 115,118,121,124,126,129,132,134
		DC.W 137,140,143,146,148,151,154,157
		DC.W 159

		DC.W 160,171,182,193,204,214,225,235
		DC.W 244,254,262,271,278,286,292,298
		DC.W 303,308,312,315,317,319,319,319
		DC.W 319,317,315,312,308,303,298,292
		DC.W 286,278,271,262,254,244,235,225
		DC.W 214,204,193,182,171,160,148,137
		DC.W 126,115,105,94,84,75,65,57
		DC.W 48,41,33,27,21,16,11,7
		DC.W 4,2,0,0,0,0,2,4
		DC.W 7,11,16,21,27,33,41,48
		DC.W 57,65,75,84,94,105,115,126
		DC.W 137,148,159

zaehler	SET 158
		REPT 157
		DC.W zaehler
zaehler	SET zaehler-1
		ENDR

		REPT 20
		DC.W 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
		DC.W 14,13,12,11,10,9,8,7,6,5,4,3,2,1
		ENDR

		REPT 20
		DC.W 0,1,2,3,2,1
		ENDR

zaehler	SET 0
		REPT 157
		DC.W zaehler
zaehler	SET zaehler+1
		ENDR

		DCB.W 50,159

		DC.W -99


dpos_logo:	DC.L delta_logo
delta_logo:

		DC.W 1280,1280,1440,1600,1600,1760,1920,1920
		DC.W 2080,2080,2240,2240,2240,2400,2400,2400
		DC.W 2400,2400,2400,2400,2400,2400,2400
		DC.W 2240,2240,2240,2080,2080,1920,1920,1760
		DC.W 1600,1600,1440,1280,1280,1120,960,800
		DC.W 800,640,480,480,320,320,160,160
		DC.W 160,0,0,0,0,0,0,0
		DC.W 0,0,0,0,160,160,160,320
		DC.W 320,480,480,640,800,800,960,1120
		DC.W 1120


delta_logo_ende:

		DC.W 1280,1280,1440,1600,1600,1760,1920,1920
		DC.W 2080,2080,2240,2240,2240,2400,2400,2400
		DC.W 2400,2400,2400,2400,2400,2400,2400
		DC.W 2240,2240,2240,2080,2080,1920,1920,1760


roehren_grafik:
; 16 breit, 2 Planes

		DC.W $d2cb,$2ff4


music:		INCBIN 'PARTY2.MUS'
		EVEN

logo		INCBIN 'DFLOGO.IM2'

font		INCBIN 'FONT.IM2'

charset:	INCBIN 'CHARSET.IM2'

;-----------------------------
contab:
; fr vertikalen Scroller
		DC.B $ff	;$00
		DCB.B 32,42	;bis $20
		DC.B 26,29	;!,"
		DC.B 43,45,46,47 ; #-&
		DC.B 29,42,42,44,42,30,31,27,42 ;$27-$2f
		DC.B 32,33,34,35,36,37,38,39,40,41,28,30 ;$30-$3b
		DCB.B 3,42	;$3c-$3e
		DC.B 42,42	;$3f,$40
		DC.B 0,1,2,3,4,5,6,7 ;$41-$48
		DC.B 8,9,10,11,12,13,14,15 ;$49-$50
		DC.B 16,17,18,19,20,21,22,23,24,25 ;$51-$5a
		DCB.B 6,42	;$5b-$60
		EVEN

		BSS
bss_start:
old_sr:	DS.W 1
oldmfp07:	DS.B 1
oldmfp09:	DS.B 1
oldmfp11:	DS.B 1
oldmfp13:	DS.B 1
oldmfp15:	DS.B 1
oldmfp17:	DS.B 1
oldmfp1b:	DS.B 1
oldmfp21:	DS.B 1
oldres:	DS.B 1
oldsync:	DS.B 1
oldvbl:	DS.L 1
oldkey:	DS.L 1
oldtimerb:	DS.L 1
oldhbl:	DS.L 1
oldstack:	DS.L 1
oldpalette:     DS.L 8
oldscreen:	DS.W 1
vsync_count:    DS.L 1
		IFEQ disk_version
ssp		DS.L 1
		ENDC

		DS.B 512	; 512 Bytes Stack
stack:

newcoltab:	DS.W anzcols*3+1



roehren_buffer: DS.L 16	; dort kommt geshiftete R”hre hin

logo_preshift_buff:
		DS.B 16*32*160  ; dort kommt geshiftetes Logo in

scroll_buffer:  DS.B 2*32*160

logo_col_buffer:DS.B 32*24*uebergaenge ; dort kommen die Paletten frs Logo rein

leer_palette:   DS.B 32	; nur 0-bytes

col_pointer:    DS.L 1
color_buff:     DS.W 200*anz_delta_cols

		DS.B 256	; wegen unteren 8 Bits des Screens
screen_base:    DS.B 261*160    ; Platz fr 2 Screens
		DS.B 200*160

bss_ende:
		END
