*** WEHN COLOURS ARE GOING BANG BANG BY NEW MODE OF DELTA FORCE
***************************************************************
*** THIS SOURCECODE IS COPYRIGHTED SOFTWARE!!!!!!!!!!!!!!


disk_version    EQU 0
; 0 = Entwicklerversion/Festplatte
; 1 = Diskettenversion

		IFEQ disk_version
		OPT X+          ; Erweiterte Symboltable anschalten
		ELSEif
		OPT X-          ; Symboltabelle aus
		ORG $1000       ; hier Relozieradresse angeben
		ENDC

		TEXT

		IFEQ disk_version
		pea     start(PC)            ; Supexec
		move.w  #38,-(A7)
		trap    #14
		addq.l  #6,A7

		clr.w   -(A7)
		trap    #1
		ENDC

start:
		;PART 'BSS lîschen'
		lea     bss_start,A0
		lea     bss_ende,A1
		moveq   #0,D0
clear_bss:      move.l  D0,(A0)+
		cmpa.l  A0,A1
		bgt.s   clear_bss
		;ENDPART

		move.l  A7,oldstack
		move    SR,old_sr
		lea     stack,A7             ; eigenen Stack setzen



		bsr     install_all

		lea     hidden_pic,A0
		move.l  #32000,D0
		bsr     backform

		lea     font,A0
		move.l  #22528,D0
		bsr     backform

		lea     raster_graphics,A0
		move.l  #18560,D0
		bsr     backform

		lea     df_logo,A0
		move.l  #15680,D0
		bsr     backform


		bsr     make_charset

		;PART 'Logo kopieren'
		lea     df_logo,A0
		movea.l screen_1(PC),A1
		movea.l screen_2(PC),A2
		lea     160(A1),A1
		lea     160(A2),A2
		move.w  #(98*40)-1,D0
copy_logo:      move.l  (A0),(A1)+
		move.l  (A0)+,(A2)+
		dbra    D0,copy_logo
		;ENDPART

		bsr     make_stars

		move.l  #vbl,$70.w           ; richtigen VBL einhÑngen


		bsr     fade_in_logo

wait:           cmpi.b  #$66,$fffffc02.w     ; * auf Ziffernblock gedrÅckt?
		beq.s   hidden_part

		cmpi.b  #$39,$fffffc02.w     ; Auf SPACE warten
		bne.s   wait

ende:           bsr     quit_program

quit_all:       bsr     restore_all          ; alles zurÅcksetzen

		movea.l oldstack,A7          ; alten Stack setzen
		move    old_sr,SR

		IFEQ disk_version
		rts		          ; und raus
		ELSEif
		moveq   #0,D0
		jmp     $0500
		ENDC



hidden_part:
; Zeigt Bild von Bilbo an.

		bsr     quit_program2        ; Farben ausblenden

		move.l  #hidden_vbl,$70.w

		bsr     vsync

		lea     hidden_pic,A0
		movea.l screen_1(PC),A1
		movea.l screen_2(PC),A2
		move.w  #(199*40)-1,D0
copy_pic:       move.l  (A0),(A1)+
		move.l  (A0)+,(A2)+
		dbra    D0,copy_pic

		bsr     vsync

		bsr     fade_in_piccy

wait_hidden:    cmpi.b  #$39,$fffffc02.w     ; auf SPACE warten
		bne.s   wait_hidden

		bsr     quit_program         ; jetzt alles ausblenden

		bra.s   quit_all



quit_program:

		move.w  #-1,scroll_stop      ; Farbscroller anhalten
		bsr     vsync

		moveq   #39,D7               ; soviele zur Sicherheit

wait_ende:      lea     logopalette,A0       ; Palette Logo
		moveq   #15,D2
		bsr     fade_down
		lea     palette2(PC),A0      ; Palette Font
		moveq   #15,D2
		bsr     fade_down
		bsr     vsync
		bsr     vsync
		dbra    D7,wait_ende

		rts


quit_program2:
; fÅr Hiddenscreen. Blendet unteren Scroller nicht aus

		move.w  #-1,scroll_stop      ; Farbscroller anhalten
		bsr     vsync

		moveq   #39,D7               ; soviele zur Sicherheit

wait_ende2:     lea     logopalette,A0       ; Palette Logo
		moveq   #15,D2
		bsr     fade_down
		bsr     vsync
		bsr     vsync
		dbra    D7,wait_ende2

		rts

		;PART 'Logo und Bild einblenden'
fade_in_logo:
		lea     palette,A5           ; Logopalette
		lea     logopalette,A6       ; dort kommt Palette rein
fade_up_logo:   bsr     fade_up
		bsr     vsync
		bsr     vsync
		bsr     vsync
		lea     palette,A0
		lea     logopalette,A1
		moveq   #15,D0
compare:        move.w  (A0)+,D1
		move.w  (A1)+,D2
		and.w   #$0777,D1
		and.w   #$0777,D2
		cmp.w   D1,D2
		bne.s   fade_up_logo
		dbra    D0,compare

		rts

fade_in_piccy:
; Blendet Hiddenbild ein
		lea     hidden_pal,A5        ; Bildpalette
		lea     logopalette,A6       ; dort kommt Palette rein
fade_up_pic:    bsr     fade_up
		bsr     vsync
		bsr     vsync
		bsr     vsync
		lea     hidden_pal,A0
		lea     logopalette,A1
		moveq   #15,D0
compare2:       move.w  (A0)+,D1
		move.w  (A1)+,D2
		and.w   #$0777,D1
		and.w   #$0777,D2
		cmp.w   D1,D2
		bne.s   fade_up_pic
		dbra    D0,compare2
		rts
		;ENDPART

		;PART 'Fade-Routine (Farben)'
fade_down:
; faded Paletten runter
; a0=Zeiger auf Farben
; d2=Anzahl Farben

fdl0:           move.w  (A0),D0
		and.w   #%111,D0
		beq.s   col2
		subq.w  #1,D0
		move.w  (A0),D1
		and.w   #%1111111111111000,D1
		or.w    D0,D1
		move.w  D1,(A0)
		bra.s   colok
col2:           move.w  (A0),D0
		and.w   #%1110000,D0
		beq.s   col3
		sub.w   #$10,D0
		move.w  (A0),D1
		and.w   #%1111111110001111,D1
		or.w    D0,D1
		move.w  D1,(A0)
		bra.s   colok
col3:           move.w  (A0),D0
		and.w   #%11100000000,D0
		beq.s   colok
		sub.w   #$0100,D0
		move.w  (A0),D1
		and.w   #%1111100011111111,D1
		or.w    D0,D1
		move.w  D1,(A0)
colok:          lea     2(A0),A0
		dbra    D2,fdl0
		rts

fade_up:
; Blendet Farben hoch
; in a5=Sourcepalette, a6=Destination
		movem.l D0-A6,-(A7)
		moveq   #15,D7
ful01:          move.w  (A6),D0
		and.w   #%111,D0
		move.w  (A5),D1
		and.w   #%111,D1
		cmp.w   D0,D1
		beq.s   fcol21
		addq.w  #1,D0
		move.w  (A6),D1
		and.w   #%1111111111111000,D1
		or.w    D0,D1
		move.w  D1,(A6)
;               bra.s   fcolok1
fcol21:         move.w  (A6),D0
		and.w   #%1110000,D0
		move.w  (A5),D1
		and.w   #%1110000,D1
		cmp.w   D0,D1
		beq.s   fcol31
		add.w   #$10,D0
		move.w  (A6),D1
		and.w   #%1111111110001111,D1
		or.w    D0,D1
		move.w  D1,(A6)
;		bra.s   fcolok1
fcol31:         move.w  (A6),D0
		and.w   #%11100000000,D0
		move.w  (A5),D1
		and.w   #%11100000000,D1
		cmp.w   D0,D1
		beq.s   fcolok1
		add.w   #$0100,D0
		move.w  (A6),D1
		and.w   #%1111100011111111,D1
		or.w    D0,D1
		move.w  D1,(A6)
fcolok1:        lea     2(A6),A6
		lea     2(A5),A5
		dbra    D7,ful01
		movem.l (A7)+,D0-A6
		rts



		;ENDPART

		;PART 'Konverter Spezialformat'
backform:
; formt Bild aus Spezialformat zurÅck
; a0=Adresse
; d0=LÑnge
		lsr.l   #3,D0		; Length/Bitblocks
		subq.l  #1,D0
		movea.l A0,A1		; Dest. (Atari)
backformloop0:  moveq   #0,D1		; clear Plane 0-3
		moveq   #0,D2
		moveq   #0,D3
		moveq   #0,D4
		moveq   #3,D5		; 4 words
backformloop1:  move.w  (A0)+,D7             ; get word (Special)
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
		move.w  D4,(A1)+             ;
		move.w  D3,(A1)+
		move.w  D2,(A1)+
		move.w  D1,(A1)+
		dbra    D0,backformloop0
		rts
		;ENDPART

; ------------- Rasterscroller -------------

		;PART 'Zeichensatz erzeugen'
make_charset:
; dreht Buchstaben um 90 Grad nach rechts. Ein Bit entspricht dann einem Byte.
; ein Buchstabe ist dann 14 Bytes breit und 15 Zeilen hoch
; -1 bedeutet Pixel gesetzt, 0 Pixel nicht gesetzt

		lea     charset,A0           ; dort ist normaler Zeichensatz
		lea     char_buffer,A1       ; Hier kommen Bytes rein
		moveq   #64,D0               ; 65 Zeichen
make_chars_l0:  moveq   #14,D1               ; 15 Pixel breit
make_chars_l1:  movea.l A0,A2
		moveq   #13,D2               ; 14 Scanlines hoch
make_chars_l2:  move.w  (A2),D3              ; Zeichen holen (16 Pixel)
		lsl.w   #1,D3		; um eins nach links schieben
		scs     (A1)+		; Setzt je Carry das Byte auf 0 oder -1
		move.w  D3,(A2)+             ; und geshiftetes wieder ablegen
		dbra    D2,make_chars_l2
		dbra    D1,make_chars_l1
		lea     14*2(A0),A0          ; ein Zeichen tiefer
		dbra    D0,make_chars_l0
		rts
		;ENDPART

		;PART 'Rasterhintergrund kopieren'


copy_raster_back1:
; Scroller groû
		lea     scroller_gross_tab(PC),A0
		bra     copy_rout

copy_raster_back2:
; Scroller klein
		lea     scroller_klein_tab(PC),A0
		bra     copy_rout

copy_raster_back3:
; Scroller nach hinten gekippt
		lea     kipp_tab_hinten(PC),A0
		bra     copy_rout


copy_raster_back4:
; Scroller nach vorne gekippt
		lea     kipp_tab_vorne(PC),A0
		bra     copy_rout


copy_raster_back5:
; Kopiert den Hintergrund fÅr die Raster (wabbelnd)

		addq.l  #2,dpos              ; Tabelle um eins weiter
		movea.l dpos(PC),A0
		cmpa.l  #delta_raster_ende,A0 ; Ende der Tabelle?
		bne.s   nix_end_delta
		lea     delta_raster(PC),A0
nix_end_delta:  move.l  A0,dpos

copy_rout:
; hier ist eigentliche Kopierroutine. In a0 ist Tabelle

		movea.l screen_1(PC),A1
		lea     116*160(A1),A1       ; 2 Zeilen tiefer
		moveq   #69,D0               ; 70 Scanlines kopieren
copy_loop:      lea     raster_graphics(PC),A2
		adda.w  (A0)+,A2
		movem.l (A2)+,D1-D7/A3-A5
		movem.l D1-D7/A3-A5,(A1)
		movem.l (A2)+,D1-D7/A3-A5
		movem.l D1-D7/A3-A5,40(A1)
		movem.l (A2)+,D1-D7/A3-A5
		movem.l D1-D7/A3-A5,80(A1)
		movem.l (A2)+,D1-D7/A3-A5
		movem.l D1-D7/A3-A5,120(A1)
		lea     160(A1),A1
		dbra    D0,copy_loop
		rts


copy_raster_back6:
; verschiebend nach beiden Seiten. Jede Zeile gleich. Links und rechts gleich

		addq.l  #2,dpos              ; Tabelle um eins weiter
		movea.l dpos(PC),A0
		cmpa.l  #delta_raster_ende,A0 ; Ende der Tabelle?
		bne.s   nix_end_delta2
		lea     delta_raster(PC),A0
nix_end_delta2: move.l  A0,dpos

		movea.l screen_1(PC),A1
		lea     116*160(A1),A1       ; 2 Zeilen tiefer
		moveq   #69,D0               ; 70 Scanlines kopieren
		lea     raster_graphics(PC),A6
		adda.w  (A0),A6
copy_loop2:     movea.l A6,A2
		movem.l (A2)+,D1-D7/A3-A5
		movem.l D1-D7/A3-A5,(A1)
		movem.l (A2)+,D1-D7/A3-A5
		movem.l D1-D7/A3-A5,40(A1)
		movem.l (A2)+,D1-D7/A3-A5
		movem.l D1-D7/A3-A5,80(A1)
		movem.l (A2)+,D1-D7/A3-A5
		movem.l D1-D7/A3-A5,120(A1)
		lea     160(A1),A1
		dbra    D0,copy_loop2
		rts

copy_raster_back7:
; Wabbelt in beide Richtungen verschieden

		addq.l  #2,dpos              ; Tabelle um eins weiter
		movea.l dpos(PC),A0
		cmpa.l  #delta_raster_ende,A0 ; Ende der Tabelle?
		bne.s   nix_end_delta3
		lea     delta_raster(PC),A0
nix_end_delta3: move.l  A0,dpos

		addq.l  #2,dpos2             ; Tabelle um eins weiter
		movea.l dpos2(PC),A6
		cmpa.l  #delta_raster_ende,A6 ; Ende der Tabelle?
		bne.s   nix_end_delta4
		lea     delta_raster(PC),A6
nix_end_delta4: move.l  A6,dpos2

		movea.l screen_1(PC),A1
		lea     116*160(A1),A1       ; 2 Zeilen tiefer
		moveq   #69,D0               ; 70 Scanlines kopieren
copy_loop3:     lea     raster_graphics(PC),A2
		adda.w  (A0)+,A2
		movem.l (A2)+,D1-D7/A3-A5
		movem.l D1-D7/A3-A5,(A1)
		movem.l (A2)+,D1-D7/A3-A5
		movem.l D1-D7/A3-A5,40(A1)

		lea     raster_graphics+80(PC),A2
		adda.w  (A6)+,A2

		movem.l (A2)+,D1-D7/A3-A5
		movem.l D1-D7/A3-A5,80(A1)
		movem.l (A2)+,D1-D7/A3-A5
		movem.l D1-D7/A3-A5,120(A1)
		lea     160(A1),A1
		dbra    D0,copy_loop3
		rts

copy_raster_back8:
; verschiebt in beide Richtungen verschieden

		addq.l  #2,dpos              ; Tabelle um eins weiter
		movea.l dpos(PC),A0
		cmpa.l  #delta_raster_ende,A0 ; Ende der Tabelle?
		bne.s   nix_end_delta5
		lea     delta_raster(PC),A0
nix_end_delta5: move.l  A0,dpos

		lea     raster_graphics(PC),A6
		adda.w  (A0)+,A6


		addq.l  #2,dpos2             ; Tabelle um eins weiter
		movea.l dpos2(PC),A1
		cmpa.l  #delta_raster_ende,A1 ; Ende der Tabelle?
		bne.s   nix_end_delta6
		lea     delta_raster(PC),A1
nix_end_delta6: move.l  A1,dpos2
		lea     raster_graphics+80(PC),A0
		adda.w  (A1)+,A0

		movea.l screen_1(PC),A1
		lea     116*160(A1),A1       ; 2 Zeilen tiefer
		moveq   #69,D0               ; 70 Scanlines kopieren
copy_loop4:     movea.l A6,A2
		movem.l (A2)+,D1-D7/A3-A5
		movem.l D1-D7/A3-A5,(A1)
		movem.l (A2)+,D1-D7/A3-A5
		movem.l D1-D7/A3-A5,40(A1)
		movea.l A0,A2
		movem.l (A2)+,D1-D7/A3-A5
		movem.l D1-D7/A3-A5,80(A1)
		movem.l (A2)+,D1-D7/A3-A5
		movem.l D1-D7/A3-A5,120(A1)
		lea     160(A1),A1
		dbra    D0,copy_loop4
		rts


copy_raster_back9:
; 2 Scanlines untereinander wabbeln verschieden

		addq.l  #2,dpos              ; Tabelle um eins weiter
		movea.l dpos(PC),A0
		cmpa.l  #delta_raster_ende,A0 ; Ende der Tabelle?
		bne.s   nix_end_delta7
		lea     delta_raster(PC),A0
nix_end_delta7: move.l  A0,dpos

		addq.l  #2,dpos2             ; Tabelle um eins weiter
		movea.l dpos2(PC),A6
		cmpa.l  #delta_raster_ende,A6 ; Ende der Tabelle?
		bne.s   nix_end_delta8
		lea     delta_raster(PC),A6
nix_end_delta8: move.l  A6,dpos2

		movea.l screen_1(PC),A1
		lea     116*160(A1),A1       ; 2 Zeilen tiefer
		moveq   #34,D0               ; 2*35=70 Scanlines kopieren
copy_loop5:     lea     raster_graphics(PC),A2
		adda.w  (A0)+,A2
		movem.l (A2)+,D1-D7/A3-A5
		movem.l D1-D7/A3-A5,(A1)
		movem.l (A2)+,D1-D7/A3-A5
		movem.l D1-D7/A3-A5,40(A1)
		movem.l (A2)+,D1-D7/A3-A5
		movem.l D1-D7/A3-A5,80(A1)
		movem.l (A2)+,D1-D7/A3-A5
		movem.l D1-D7/A3-A5,120(A1)
		lea     160(A1),A1
		lea     raster_graphics(PC),A2
		adda.w  (A6)+,A2
		movem.l (A2)+,D1-D7/A3-A5
		movem.l D1-D7/A3-A5,(A1)
		movem.l (A2)+,D1-D7/A3-A5
		movem.l D1-D7/A3-A5,40(A1)
		movem.l (A2)+,D1-D7/A3-A5
		movem.l D1-D7/A3-A5,80(A1)
		movem.l (A2)+,D1-D7/A3-A5
		movem.l D1-D7/A3-A5,120(A1)
		lea     160(A1),A1
		dbra    D0,copy_loop5
		rts


copy_raster_back10:
; zur Mitte wabbelnd und wieder zurÅck
		movea.l screen_1(PC),A1
		lea     116*160(A1),A1       ; 2 Zeilen tiefer
		moveq   #69,D0               ; 70 Scanlines kopieren
		lea     raster_graphics+116*160(PC),A6
copy_loop10:    movea.l A6,A2
		movem.l (A2)+,D1-D7/A3-A5
		movem.l D1-D7/A3-A5,(A1)
		movem.l (A2)+,D1-D7/A3-A5
		movem.l D1-D7/A3-A5,40(A1)
		movem.l (A2)+,D1-D7/A3-A5
		movem.l D1-D7/A3-A5,80(A1)
		movem.l (A2)+,D1-D7/A3-A5
		movem.l D1-D7/A3-A5,120(A1)
		lea     160(A1),A1
		dbra    D0,copy_loop10
		rts


		;ENDPART

		;PART 'Scrollroutine'
scroll_col_buff:
; Schiebt den ganzen Rasterbuffer um 1 Wort nach vorne

		lea     color_buffer+2,A6    ; auf zweites Wort gehen
		REPT 75
		movem.l (A6)+,D0-A5          ; 14 Longs holen
		movem.l D0-A5,-58(A6)
		ENDR
		rts

haeng_rest_an:
; HÑngt letzte Farben an Rasterscroller an

		movea.l char_pointer,A0      ; Pointer auf Zeichengrafik

		subq.w  #1,scroll_counter    ; am Ende des Buchstabens angekommen?
		bpl     not_last_line
		move.w  #14,scroll_counter

		movea.l text_pointer,A0
		tst.b   (A0)		 ; am letzten Zeichen angekommen?
		bne.s   not_last_char
		lea     text,A0
not_last_char:  moveq   #0,D0
		move.b  (A0)+,D0             ; Zeichen holen (ASCII)

		cmp.b   #1,D0
		bne.s   not_scroller_gross
		move.l  #copy_raster_back1,what_back+2
		move.b  (A0)+,D0             ; neues Zeichen holen
not_scroller_gross:
		cmp.b   #2,D0
		bne.s   not_scroller_klein
		move.l  #copy_raster_back2,what_back+2
		move.b  (A0)+,D0             ; neues Zeichen holen
not_scroller_klein:
		cmp.b   #3,D0
		bne.s   not_scroller_hinten
		move.l  #copy_raster_back3,what_back+2
		move.b  (A0)+,D0             ; neues Zeichen holen
not_scroller_hinten:
		cmp.b   #4,D0
		bne.s   not_scroller_vorne
		move.l  #copy_raster_back4,what_back+2
		move.b  (A0)+,D0             ; neues Zeichen holen
not_scroller_vorne:
		cmp.b   #5,D0
		bne.s   not_scroller_wabbel
		move.l  #copy_raster_back5,what_back+2
		move.b  (A0)+,D0             ; neues Zeichen holen
not_scroller_wabbel:
		cmp.b   #6,D0
		bne.s   not_scroller_move
		move.l  #copy_raster_back6,what_back+2
		move.b  (A0)+,D0             ; neues Zeichen holen
not_scroller_move:
		cmp.b   #7,D0
		bne.s   not_scroller_wabbel2
		move.l  #copy_raster_back7,what_back+2
		move.l  #delta_raster,dpos
		move.l  #delta_raster+300,dpos2
		move.b  (A0)+,D0             ; neues Zeichen holen
not_scroller_wabbel2:
		cmp.b   #8,D0
		bne.s   not_scroller_move2
		move.l  #copy_raster_back8,what_back+2
		move.l  #delta_raster,dpos
		move.l  #delta_raster+300,dpos2
		move.b  (A0)+,D0             ; neues Zeichen holen
not_scroller_move2:
		cmp.b   #9,D0
		bne.s   not_scroller_wabbel3
		move.l  #copy_raster_back9,what_back+2
		move.l  #delta_raster,dpos
		move.l  #delta_raster+500,dpos2
		move.b  (A0)+,D0             ; neues Zeichen holen
not_scroller_wabbel3:
		cmp.b   #13,D0
		bne.s   not_scroller_kante
		move.l  #copy_raster_back10,what_back+2
		move.b  (A0)+,D0             ; neues Zeichen holen
not_scroller_kante:
		cmp.b   #10,D0
		bne.s   not_scroller_mono
		move.l  #col_rout1,what_cols+2
		move.b  (A0)+,D0             ; neues Zeichen holen
not_scroller_mono:
		cmp.b   #11,D0
		bne.s   not_scroller_cols2
		move.l  #col_rout2,what_cols+2
		move.b  (A0)+,D0             ; neues Zeichen holen
not_scroller_cols2:
		cmp.b   #12,D0
		bne.s   not_scroller_bunt
		move.l  #col_rout3,what_cols+2
		move.b  (A0)+,D0             ; neues Zeichen holen
not_scroller_bunt:
		tst.w   scroll_stop
		beq.s   not_scroll_stop
		move.l  #scroll_fade,what_cols+2
not_scroll_stop:

		move.l  A0,text_pointer
		sub.w   #' ',D0              ; erstes Zeichen abziehen
		mulu    #14*15,D0            ; mal Grîûe eines Zeichens
		lea     char_buffer,A0
		adda.w  D0,A0		; neuer Charpointer
not_last_line:
		lea     color_buffer+58,A1   ; dort kommen Farben rein

what_cols:      jmp     col_rout1


scroll_fade:
		addq.l  #4,scroll_fade_pointer
		movea.l scroll_fade_pointer,A2
		bra.s   all_colors



		movea.l scroll_fade_pointer(PC),A6
		move.w  (A6)+,D1
		move.l  A6,scroll_fade_pointer
		bra.s   one_color

col_rout1:
; einfarbig
		move.w  #$0765,D1

one_color:      moveq   #0,D0

		moveq   #13,D2               ; 14 Scanlines
haeng_an_loop1: tst.b   (A0)+
		beq.s   not_pix_set1
		move.w  D1,(A1)
		move.w  D1,60(A1)
		move.w  D1,120(A1)
		move.w  D1,180(A1)
		move.w  D1,240(A1)
		bra.s   pix_set_1
not_pix_set1:   move.w  D0,(A1)
		move.w  D0,60(A1)
		move.w  D0,120(A1)
		move.w  D0,180(A1)
		move.w  D0,240(A1)
pix_set_1:      lea     300(A1),A1           ; 5 zeilen tiefer
		dbra    D2,haeng_an_loop1
		move.l  A0,char_pointer
		rts



col_rout2:
; jede Scanline andere Farbe

		lea     col_tab(PC),A2

all_colors:     moveq   #0,D0
		moveq   #13,D2               ; 14 Scanlines hoch

haeng_an_loop2:
		tst.b   (A0)+		; ist Pixel gesetzt?
		beq.s   pixel_not_set1
		move.w  (A2)+,(A1)
		move.w  (A2)+,60(A1)
		move.w  (A2)+,120(A1)
		move.w  (A2)+,180(A1)
		move.w  (A2)+,240(A1)
		bra.s   pixel_was_set1
pixel_not_set1: move.w  D0,(A1)
		move.w  D0,60(A1)
		move.w  D0,120(A1)
		move.w  D0,180(A1)
		move.w  D0,240(A1)
		lea     10(A2),A2
pixel_was_set1: lea     300(A1),A1           ; 5 Zeilen tiefer im Colorbuffer
		dbra    D2,haeng_an_loop2

		move.l  A0,char_pointer
		rts

col_rout3:
; voll bunt

		addq.l  #2,col_pointer
		movea.l col_pointer(PC),A2
		cmpa.l  #end_col_tab,A2
		bne.s   nix_end_coltab
		lea     col_tab(PC),A2
nix_end_coltab: move.l  A2,col_pointer


		moveq   #0,D0
		moveq   #13,D2               ; 14 Scanlines hoch

haeng_an_loop3: tst.b   (A0)+		; ist Pixel gesetzt?
		beq.s   pixel_not_set
		move.w  (A2)+,(A1)
		move.w  (A2)+,60(A1)
		move.w  (A2)+,120(A1)
		move.w  (A2)+,180(A1)
		move.w  (A2)+,240(A1)
		lea     -8(A2),A2
		bra.s   pixel_was_set
pixel_not_set:  move.w  D0,(A1)
		move.w  D0,60(A1)
		move.w  D0,120(A1)
		move.w  D0,180(A1)
		move.w  D0,240(A1)
		lea     2(A2),A2
pixel_was_set:  lea     300(A1),A1           ; 5 Zeilen tiefer im Colorbuffer
		dbra    D2,haeng_an_loop3

		move.l  A0,char_pointer
		rts

		;ENDPART

; ------------- Rasterscroller Ende -------------

		;PART 'Grafikscroller um 8 nach vorne'
scroller:
; normaler Grafikscroller
; Buffer (auf Screen) um 8 Byte vorschieben

		movea.l screen_1(PC),A6
		lea     200*160+8(A6),A6
		moveq   #31,D0
scroll_loop:    movem.l (A6)+,D1-A5          ; 13 Longs holen
		movem.l D1-A5,-60(A6)
		movem.l (A6)+,D1-A5          ; 13 Longs holen
		movem.l D1-A5,-60(A6)
		movem.l (A6)+,D1-A4          ; 12 Longs holen
		movem.l D1-A4,-56(A6)
		lea     8(A6),A6
		dbra    D0,scroll_loop
		rts

		;ENDPART

		;PART 'GrafikScroller Rest anhÑngen'

nachschubpuffer:
; hÑngt den Rest an den Scroller an (und an Screen)

; Routine fÅr normalen Buffer
		eori.w  #1,scroll_flag       ; jeden VBL drehen
		bne     nachschubpuffer2     ; je nach Routine verzweigen

		movea.l char_pointer1(PC),A0
		movea.l screen_1(PC),A1
		lea     200*160+152(A1),A1
s_off           SET 0
c_off           SET 0
		REPT 32
		move.l  c_off(A0),s_off(A1)
		move.l  c_off+4(A0),s_off+4(A1)
s_off           SET s_off+160
c_off           SET c_off+16
		ENDR
		rts


nachschubpuffer2:
; hÑngt den Rest an den Scroller an (und an Screen)

; Routine fÅr 8er Buffer

		movea.l char_pointer1(PC),A0
		lea     1(A0),A0
		movea.l char_pointer2(PC),A3
		movea.l screen_1(PC),A1
		lea     200*160+152(A1),A1
s_off           SET 0
c_off           SET 0
		REPT 32
		movep.l c_off(A0),D0
		movep.l D0,s_off(A1)
		movep.l c_off(A3),D0
		movep.l D0,s_off+1(A1)
s_off           SET s_off+160
c_off           SET c_off+16
		ENDR

		move.l  A3,char_pointer1     ; Charpointer2 in Charpointer1 kopieren
		addq.l  #8,A3		; auf nÑchsten Bitblock
		addq.w  #1,scroll_counter2   ; muû Zeichen angehÑngt werden?
		cmpi.w  #2,scroll_counter2
		bne.s   not_last_bb
		clr.w   scroll_counter2

		addq.l  #1,text_pos          ; Textpointer weiter
		movea.l text_pos(PC),A0
		cmpi.b  #-1,(A0)
		bne.s   nix_end_text
		lea     scroll_text,A0
nix_end_text:   move.l  A0,text_pos
		moveq   #0,D0
		move.b  (A0)+,D0             ; Zeichen holen
		lsl.l   #8,D0
		add.l   D0,D0
		lea     font,A3
		adda.l  D0,A3		; dort ist neues Zeichen
not_last_bb:    move.l  A3,char_pointer2
		rts

		;ENDPART

		;PART 'Sterne erstellen'
make_stars:
; erstellt 320 Tabellen fÅr die Sternroutine
; Format: Pointer wo Stern gezeichnet wird und Pointer auf Grafik des Sterns

		lea     stars_grafik,A0      ; dort wird Sterngrafik erstellt
		moveq   #1,D0		; Wort fÅr Plane 0
		moveq   #0,D1		; Wort fÅr Plane 1
		bsr     create_star_graf
		lea     stars_grafik+16*8,A0 ; dort wird Sterngrafik erstellt
		moveq   #0,D0		; Wort fÅr Plane 0
		moveq   #1,D1		; Wort fÅr Plane 1
		bsr     create_star_graf
		lea     stars_grafik+2*16*8,A0 ; dort wird Sterngrafik erstellt
		moveq   #1,D0		; Wort fÅr Plane 0
		moveq   #1,D1		; Wort fÅr Plane 1
		bsr     create_star_graf


		lea     star_buffer,A1       ; dort kommen die Daten rein
		move.w  #319,D0              ; 320 mal Tabelle erstellen
		movea.l screen_1(PC),A4
make_starloop0: move.w  D0,-(A7)
		lea     star_tab(PC),A0
		moveq   #99,D1               ; 100 Sterne
		moveq   #0,D0		; Y-Zeile
make_starloop1:
		move.w  2(A0),D2             ; X-Pos holen
		move.w  D2,D3
		and.w   #-16,D3
		lsr.w   #1,D3		; Bitblock bestimmen
		movea.l A4,A3
		add.w   D0,D3		; aktuelle Zeile aufaddieren
		adda.w  D3,A3		; hier ist Screenpos
		and.w   #15,D2               ; nur Werte von 0-15
		eori.w  #15,D2               ; umdrehen
		movem.w (A3),D4-D7           ; 4 Planes vom Screen holen
		btst    D2,D4		; schauen ob da Pixel gesetzt ist
		bne.s   pixel_ist_da
		btst    D2,D5
		bne.s   pixel_ist_da
		btst    D2,D6
		bne.s   pixel_ist_da
		btst    D2,D7
		bne.s   pixel_ist_da         ; falls kein Pixel gesetzt ist
		move.w  D3,(A1)+

		bra.s   pixel_nix_da
pixel_ist_da:   move.w  #-8,(A1)+            ; Pointer auf Dummybuffer ablegen
pixel_nix_da:   move.w  (A0)+,D3             ; Farbe holen
		move.w  (A0),D7              ; Xpos holen
		cmp.w   #1,D3		; Farbe = 1?
		bne.s   not_color1
		subq.w  #1,D7		; X-Pos -1
		lea     stars_grafik,A3
		bra.s   ok_color
not_color1:     cmp.w   #2,D3		; Farbe=2?
		bne.s   not_color2
		subq.w  #2,D7		; X-Pos -2
		lea     stars_grafik+16*8,A3
		bra.s   ok_color
not_color2:     subq.w  #4,D7		; X-Pos -4
		lea     stars_grafik+2*16*8,A3
ok_color:       tst.w   D7		   ; X-pos negativ?
		bpl.s   x_pos_ok
		add.w   #320,D7              ; neue Position
x_pos_ok:       move.w  D7,(A0)+             ; X-Pos ablegen
		lsl.w   #3,D2		; mal Breite eines Sterns
		adda.w  D2,A3
		move.l  A3,(A1)+             ; Grafikpointer ablegen
		add.w   #160,D0              ; eine Zeile tiefer
		dbra    D1,make_starloop1
		move.w  (A7)+,D0
		dbra    D0,make_starloop0

		lea     star_restbuff1,A0
		lea     star_restbuff2,A1
		moveq   #99,D0               ; 100 Sterne
init_rest_buff: move.l  #stars_dummy,(A0)    ; Restorebuffer vorinitialisieren
		move.l  #stars_dummy,(A1)
		lea     12(A0),A0
		lea     12(A1),A1
		dbra    D0,init_rest_buff

		rts

create_star_graf:
; shiftet die Grafik des Sterns 16 mal und erstellt dann Maske und KnÅpfwert.
; Format: 1 Longs Maske und 1 Long Grafik
; in a0=Buffer
; d0,d1 = Plane 0, Plane 1

		moveq   #15,D2               ; 16 mal shiften
create_s_loop:  move.w  D0,D3
		or.w    D1,D3
		not.w   D3		   ; Maske
		move.w  D3,(A0)+
		move.w  D3,(A0)+             ; 2 mal ablegen (damit Longzugriff)
		move.w  D0,(A0)+
		move.w  D1,(A0)+             ; jetzt Grafik ablegen
		lsl.w   #1,D0
		lsl.w   #1,D1		; um jeweils eins nach rechts
		dbra    D2,create_s_loop


		rts

		;ENDPART

; -------------------------------------------------


		;PART 'Install'  ; alles installieren (MFP,...)

install_all:
; Initialisiert alle Hardware-Register

		move.b  $ffff820a.w,oldsync
		move.b  $ffff8260.w,oldres

		movem.l $ffff8240.w,D0-D7
		movem.l D0-D7,oldpalette

		lea     $ffff8240.w,A0
		moveq   #7,D0
clr_pal:        clr.l   (A0)+
		dbra    D0,clr_pal

		lea     $ffff8201.w,A0       ; Screenadresse holen
		movep.w 0(A0),D0
		move.w  D0,oldscreen

		move.l  #screen_base,D0
		and.l   #-256,D0             ; untere 8 Bits weg
		move.l  D0,screen_1
		movea.l D0,A0
		add.l   #264*160,D0
		move.l  D0,screen_2
		movea.l D0,A1

		move.w  #(264*40)-1,D0       ; beide Screens lîschen
clr_screens:    clr.l   (A0)+
		clr.l   (A1)+
		dbra    D0,clr_screens

		move.l  screen_1(PC),D0
		bsr     set_screen

		bsr     init_mfp

		bsr     vsync
		bsr     vsync
		bsr     vsync

		moveq   #$12,D0              ; Maus aus
		bsr     send_ikbd

		moveq   #$1a,D0              ; Joystick aus
		bsr     send_ikbd

		bsr     vsync
		move.b  #2,$ffff820a.w       ; 50 Hz

		bsr     vsync
		clr.b   $ffff8260.w          ; Lowres

		moveq   #1,D0
		bsr     music		; Musik init.

		rts

		;ENDPART

		;PART 'Restore'  ; alles zurÅcksetzen

restore_all:
; alle Hardware-Register werden wieder so gesetzt wie am Anfang

		move.l  #start_vbl,$70.w
		bsr     vsync

		movem.l oldpalette,D0-D7
		movem.l D0-D7,$ffff8240.w

		bsr     vsync
		move.b  oldsync,$ffff820a.w

		bsr     vsync
		move.b  oldres,$ffff8260.w

		bsr     restore_mfp

		moveq   #0,D0		; Musik abdrehen
		bsr     music

		IFNE disk_version
		moveq   #$12,D0              ; Maus aus
		bsr     send_ikbd

		moveq   #$1a,D0              ; Joystick aus
		bsr     send_ikbd
		ELSE

		moveq   #$08,D0              ; Maus wieder ein
		bsr     send_ikbd
		ENDC


		move.w  oldscreen,D0
		lea     $ffff8201.w,A0
		movep.w D0,0(A0)             ; alte Screenadresse setzen

		rts
		;ENDPART

		;PART 'SendIKBD'
send_ikbd:
; sendet Byte aus d0 an IKBD
		lea     $fffffc00.w,A0
waitkeyready:   btst    #1,(A0)
		beq.s   waitkeyready
		move.b  D0,2(A0)
		rts

		;ENDPART

		;PART 'Set-Screen'
set_screen:
; in d0 = Screenadresse
		lsr.l   #8,D0
		lea     $ffff8201.w,A0
		movep.w D0,0(A0)
		rts
		;ENDPART

		;PART 'Vsync'
vsync:          move.l  A0,-(A7)
		move.l  D0,-(A7)
		lea     vsync_count,A0
		move.l  (A0),D0
wait_strahl:    cmp.l   (A0),D0
		beq.s   wait_strahl
		move.l  (A7)+,D0
		movea.l (A7)+,A0
		rts
		;ENDPART

		;PART 'MFP-Install+DeInstall'
init_mfp:
; rettet und setzt alle IRQ's

		move    SR,-(A7)
		ori     #$0700,SR
		move.l  $0118.w,oldkey
		move.l  $0120.w,oldtimerb
		move.l  $70.w,oldvbl
		lea     $fffffa00.w,A0       ; MFP
		move.b  $07(A0),oldmfp07
		move.b  $09(A0),oldmfp09
		move.b  $11(A0),oldmfp11
		move.b  $13(A0),oldmfp13
		move.b  $15(A0),oldmfp15
		move.b  $17(A0),oldmfp17
		move.b  $1b(A0),oldmfp1b
		move.b  $21(A0),oldmfp21
		clr.b   $07(A0)              ; alle IRQ's aus
		clr.b   $09(A0)
		clr.b   $13(A0)
		clr.b   $15(A0)
		bset    #0,$07(A0)           ; Timer B erlauben
		bset    #0,$13(A0)
		bclr    #3,$17(A0)           ; Automatic EOI

		bclr    #6,$09(A0)           ; Tastatur IRQ ausschalten
		bclr    #6,$15(A0)

		move.l  #newkey,$0118.w
		move.l  #start_vbl,$70.w     ; am Anfang (zum Initialisieren)
		move.l  #timer_b,$0120.w
		move    (A7)+,SR


		rts

restore_mfp:
; setzt alle MFP-Register wieder zurÅck

		move    SR,-(A7)
		ori     #$0700,SR
		move.l  oldkey,$0118.w
		move.l  oldtimerb,$0120.w
		move.l  oldvbl,$70.w
		lea     $fffffa00.w,A0       ; MFP
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

start_vbl:      clr.b   $fffffa1b.w          ; Timer B aus
		addq.l  #1,vsync_count
		rte

		;ENDPART


vbl:            movem.l D0-A6,-(A7)

		clr.b   $fffffa1b.w
		move.b  #115,$fffffa21.w     ; Timer B in Zeile 118
		move.b  #8,$fffffa1b.w
		move.l  #timer_b,$0120.w

		movem.l logopalette,D0-D7    ; Palette fÅr Logo setzen
		movem.l D0-D7,$ffff8240.w

		movea.l star_restpoint1(PC),A0
		REPT 100        ; 100 Sterne lîschen
		movea.l (A0)+,A1             ; Pointer holen
		move.l  (A0)+,(A1)+          ; und restaurieren
		move.l  (A0)+,(A1)
		ENDR


		bsr     scroller

		bsr     nachschubpuffer

		bsr     music+8

what_back:      jsr     copy_raster_back1    ; hier wird verÑndert

		addq.l  #1,vsync_count

		movem.l (A7)+,D0-A6
		rte


hidden_vbl:
		movem.l D0-A6,-(A7)

		movem.l logopalette,D0-D7
		movem.l D0-D7,$ffff8240.w

		clr.b   $fffffa1b.w
		move.b  #199,$fffffa21.w     ; Unteren Rand aufklappen
		move.b  #8,$fffffa1b.w
		move.l  #timer_b_hidden,$0120.w

		bsr     scroller

		bsr     nachschubpuffer

		bsr     music+8

		addq.l  #1,vsync_count

		movem.l (A7)+,D0-A6
		rte


newkey:         rte

timer_b:        movem.l D0-A7,regs_save

		clr.b   $fffffa1b.w          ; Timer stoppen
		move.b  #84,$fffffa21.w
		move.b  #8,$fffffa1b.w
		move.l  #timer_b2,$0120.w

		lea     $ffff8209.w,A0
		moveq   #0,D0
sync_dich:      move.b  (A0),D0
		cmp.w   #64,D0
		blt.s   sync_dich
		sub.w   #64,D0
		not.w   D0
		lsr.w   D0,D0


		lea     color_buffer,A0      ; dort sind die Farben

		lea     $ffff8242.w,A1
		lea     $ffff825e.w,A3
		movea.l star_pointer(PC),A4
		movea.l star_restpoint1(PC),A5
		movea.l screen_1(PC),A7
		moveq   #69,D0               ; soviele Zeilen
color_loop:     movem.l (A0)+,D1-D6/A2       ; (68)
		move.w  (A0)+,D7             ; (8)
		movem.l D1-D6/A2,(A1)        ; (64)
		move.w  D7,(A3)              ; (8)

		movem.l (A0)+,D1-D6/A2       ; (68)
		move.w  (A0)+,D7             ; (8)
		movem.l D1-D6/A2,(A1)        ; (64)
		move.w  D7,(A3)              ; (8)

		movea.l A7,A6		; Screenpointer (4)
		adda.w  (A4)+,A6             ; Screenpos addieren (12)
		movea.l (A4)+,A2             ; Pointer auf Grafik (12)
		move.l  A6,(A5)+             ; Screenpos in Restorbuff (12)
		move.l  (A6)+,D1             ; zwei Longs vom Screen holen (12)
		move.l  (A6)+,D2             ; (12)
		move.l  D1,(A5)+             ; und in Restorbuffer (12)
		move.l  D2,(A5)+             ; (12)
		move.l  (A2)+,D3             ; Andwert holen (12)
		and.l   D3,D1		; maskieren (6)
		and.l   D3,D2		; (6)
		or.l    (A2),D1              ; in Plane 0+1 einknÅpfen (16)
		move.l  D2,-(A6)             ; auf Screen zurÅck (16)
		move.l  D1,-(A6)             ; (16)

		DCB.W 12,$4e71

		dbra    D0,color_loop

		movem.l palette2(PC),D0-D7   ; Palette fÅr Font setzen
		movem.l D0-D7,$ffff8240.w

		moveq   #29,D0               ; noch 30 Sterne zeichnen
last_stars:     movea.l A7,A6
		adda.w  (A4)+,A6             ; Screenpos holen (12)
		movea.l (A4)+,A2             ; Pointer auf Grafik (12)
		move.l  A6,(A5)+             ; Screenpos in Restorbuff (12)
		move.l  (A6)+,D1             ; zwei Longs vom Screen holen (12)
		move.l  (A6)+,D2             ; (12)
		move.l  D1,(A5)+             ; und in Restorbuffer (12)
		move.l  D2,(A5)+             ; (12)
		move.l  (A2)+,D3             ; Andwert holen (12)
		and.l   D3,D1		; maskieren (6)
		and.l   D3,D2		; (6)
		or.l    (A2),D1              ; in Plane 0+1 einknÅpfen (16)
		move.l  D2,-(A6)             ; auf Screen zurÅck (16)
		move.l  D1,-(A6)             ; (16)
		dbra    D0,last_stars

		movem.l regs_save(PC),D0-A7
		rte

regs_save:      DS.L 16


timer_b2:
; klappt unteren Rand auf

		movem.l D0-A6,-(A7)


		lea     $fffffa21.w,A0
		clr.b   -6(A0)
		move.b  #20,(A0)
		move.b  #8,-6(A0)
		move.b  (A0),D0
wait_rand:      cmp.b   (A0),D0
		beq.s   wait_rand
		clr.b   $ffff820a.w
		DCB.W 16,$4e71
		move.b  #2,$ffff820a.w
		clr.b   -6(A0)               ; Timer B anhalten

		bsr     scroll_col_buff      ; Buffer scrollen

		bsr     haeng_rest_an        ; letzte Spalte anhÑngen

		addi.l  #100*6,star_pointer  ; nÑchster Buffer?
		cmpi.l  #star_buffer+320*100*6,star_pointer ; Ende des Buffers?
		bne.s   not_end_stars
		move.l  #star_buffer,star_pointer
not_end_stars:
		move.l  star_restpoint1(PC),D0
		move.l  star_restpoint2(PC),star_restpoint1
		move.l  D0,star_restpoint2   ; Pointer tauschen

		move.l  screen_1(PC),D0      ; Screens tauschen
		move.l  screen_2(PC),screen_1
		move.l  D0,screen_2
		bsr     set_screen

		movem.l (A7)+,D0-A6
		rte



timer_b_hidden:
; klappt unteren Rand auf

		movem.l D0-A6,-(A7)

		movem.l palette2(PC),D0-D7   ; Palette fÅr Font setzen
		movem.l D0-D7,$ffff8240.w

		lea     $fffffa21.w,A0
		clr.b   -6(A0)
		move.b  #20,(A0)
		move.b  #8,-6(A0)
		move.b  (A0),D0
wait_rand3:     cmp.b   (A0),D0
		beq.s   wait_rand3
		clr.b   $ffff820a.w
		DCB.W 16,$4e71
		move.b  #2,$ffff820a.w
		clr.b   -6(A0)               ; Timer B anhalten

		move.l  screen_1(PC),D0      ; Screens tauschen
		move.l  screen_2(PC),screen_1
		move.l  D0,screen_2
		bsr     set_screen

		movem.l (A7)+,D0-A6
		rte




		DATA
screen_1:       dc.l	0          ; so weit oben damit PC-Relativer Zugriff
screen_2:       dc.l	0
key:            dc.w	0
hbl_count:      dc.w	30
scroll_flag:    dc.w	0
scroll_counter2:dc.w	0
char_pointer1:  dc.l	font+26*32*16
char_pointer2:  dc.l	font+26*32*16
text_pos:       dc.l	scroll_text ; fÅr mittleren Scroller
star_pointer:   dc.l	star_buffer
star_restpoint1:dc.l	star_restbuff1
star_restpoint2:dc.l	star_restbuff2
scroll_stop:    dc.w	0
scroll_fade_pointer:dc.l	scroll_fade_tab

scroll_fade_tab:
; Mit dieser Tabelle wird Scroller am Ende runtergeblendet
		DCB.W 6,$0777
		DCB.W 6,$0776
		DCB.W 6,$0775
		DCB.W 6,$0774
		DCB.W 6,$0763
		DCB.W 6,$0752
		DCB.W 6,$0741
		DCB.W 6,$0630
		DCB.W 6,$0520
		DCB.W 6,$0410
		DCB.W 6,$0300
		DCB.W 6,$0200
		DCB.W 6,$0100
		DS.W 400


palette:				     ; fÅr DF-Logo
;Palette of DF_TANI2.IFF: Saved by NEOchrome V2.22 by Chaos, Inc.
		dc.w	$00,$0222,$0444,$0777,$00,$0200,$0310,$0420
		dc.w	$0530,$0640,$0750,$0760,$0770,$0773,$0775,$0777

palette2:				    ; Palette fÅr Scroller
;Palette of FONTREMA.IFF: Saved by NEOchrome V2.25 by Chaos, Inc.
		dc.w	$00,$01,$0112,$0223,$0334,$0445,$0556,$0667
		dc.w	$0770,$0550,$0330,$0110,$0707,$70,$0700,$70


		;PART 'Delta-Raster'

dpos:           dc.l	delta_raster
dpos2:          dc.l	delta_raster

delta_raster:
; mit 160 multipliziert. Maximalwert: 116

		dc.w	9280,9440,9600,9760,9920,10080,10240,10400
		dc.w	10560,10720,10880,11040,11200,11360,11520,11680
		dc.w	11680,11840,12000,12160,12320,12480,12640,12800
		dc.w	12960,13120,13280,13440,13600,13760,13920,13920
		dc.w	14080,14240,14400,14560,14720,14720,14880,15040
		dc.w	15200,15360,15360,15520,15680,15840,15840,16000
		dc.w	16160,16160,16320,16480,16480,16640,16640,16800
		dc.w	16960,16960,17120,17120,17280,17280,17440,17440
		dc.w	17600,17600,17600,17760,17760,17920,17920,17920
		dc.w	18080,18080,18080,18240,18240,18240,18240,18240
		dc.w	18400,18400,18400,18400,18400,18400,18400,18400
		dc.w	18400,18400,18400,18400,18400,18400,18400
		dc.w	18400,18400,18400,18400,18400,18240,18240,18240
		dc.w	18240,18240,18080,18080,18080,17920,17920,17920
		dc.w	17760,17760,17600,17600,17600,17440,17440,17280
		dc.w	17280,17120,17120,16960,16960,16800,16640,16640
		dc.w	16480,16480,16320,16160,16160,16000,15840,15840
		dc.w	15680,15520,15360,15360,15200,15040,14880,14720
		dc.w	14720,14560,14400,14240,14080,13920,13920,13760
		dc.w	13600,13440,13280,13120,12960,12800,12640,12480
		dc.w	12320,12160,12000,11840,11680,11680,11520,11360
		dc.w	11200,11040,10880,10720,10560,10400,10240,10080
		dc.w	9920,9760,9600,9440,9280,8960,8800,8640
		dc.w	8480,8320,8160,8000,7840,7680,7520,7360
		dc.w	7200,7040,6880,6720,6720,6560,6400,6240
		dc.w	6080,5920,5760,5600,5440,5280,5120,4960
		dc.w	4800,4640,4480,4480,4320,4160,4000,3840
		dc.w	3680,3680,3520,3360,3200,3040,3040,2880
		dc.w	2720,2560,2560,2400,2240,2240,2080,1920
		dc.w	1920,1760,1760,1600,1440,1440,1280,1280
		dc.w	1120,1120,960,960,800,800,800,640
		dc.w	640,480,480,480,320,320,320,160
		dc.w	160,160,160,160,0,0,0,0
		dc.w	0,0,0,0,0,0,0,0
		dc.w	0,0,0,0,0,0,0,0
		dc.w	0,160,160,160,160,160,320,320
		dc.w	320,480,480,480,640,640,800,800
		dc.w	800,960,960,1120,1120,1280,1280,1440
		dc.w	1440,1600,1760,1760,1920,1920,2080,2240
		dc.w	2240,2400,2560,2560,2720,2880,3040,3040
		dc.w	3200,3360,3520,3680,3680,3840,4000,4160
		dc.w	4320,4480,4480,4640,4800,4960,5120,5280
		dc.w	5440,5600,5760,5920,6080,6240,6400,6560
		dc.w	6720,6720,6880,7040,7200,7360,7520,7680
		dc.w	7840,8000,8160,8320,8480,8640,8800,8960
		dc.w	9120



		dc.w	9280,9600,9920,10240,10560,10880,11200,11520
		dc.w	11680,12000,12320,12640,12960,13280,13600,13920
		dc.w	14080,14400,14720,14880,15200,15360,15680,15840
		dc.w	16160,16320,16480,16640,16960,17120,17280,17440
		dc.w	17600,17600,17760,17920,18080,18080,18240,18240
		dc.w	18400,18400,18400,18400,18400,18400,18400
		dc.w	18400,18400,18400,18240,18240,18080,18080,17920
		dc.w	17760,17600,17600,17440,17280,17120,16960,16640
		dc.w	16480,16320,16160,15840,15680,15360,15200,14880
		dc.w	14720,14400,14080,13920,13600,13280,12960,12640
		dc.w	12320,12000,11680,11520,11200,10880,10560,10240
		dc.w	9920,9600,9280,8800,8480,8160,7840,7520
		dc.w	7200,6880,6720,6400,6080,5760,5440,5120
		dc.w	4800,4480,4320,4000,3680,3520,3200,3040
		dc.w	2720,2560,2240,2080,1920,1760,1440,1280
		dc.w	1120,960,800,800,640,480,320,320
		dc.w	160,160,0,0,0,0,0,0
		dc.w	0,0,0,0,0,160,160,320
		dc.w	320,480,640,800,800,960,1120,1280
		dc.w	1440,1760,1920,2080,2240,2560,2720,3040
		dc.w	3200,3520,3680,4000,4320,4480,4800,5120
		dc.w	5440,5760,6080,6400,6720,6880,7200,7520
		dc.w	7840,8160,8480,8800,9120

delta_raster_ende:
		dc.w	9280,9440,9600,9760,9920,10080,10240,10400
		dc.w	10560,10720,10880,11040,11200,11360,11520,11680
		dc.w	11680,11840,12000,12160,12320,12480,12640,12800
		dc.w	12960,13120,13280,13440,13600,13760,13920,13920
		dc.w	14080,14240,14400,14560,14720,14720,14880,15040
		dc.w	15200,15360,15360,15520,15680,15840,15840,16000
		dc.w	16160,16160,16320,16480,16480,16640,16640,16800
		dc.w	16960,16960,17120,17120,17280,17280,17440,17440
		dc.w	17600,17600,17600,17760,17760,17920,17920,17920
		dc.w	18080,18080,18080,18240,18240,18240,18240,18240
		dc.w	18400,18400,18400,18400,18400,18400,18400,18400
		dc.w	18400,18400,18400,18400,18400,18400,18400
		dc.w	18400,18400,18400,18400,18400,18240,18240,18240



		;ENDPART

		;PART 'Tabellen fÅr Scroller'

kipp_tab_vorne:
count           SET 115
		REPT 70
		dc.w	count*160
count           SET count-1
		ENDR

kipp_tab_hinten:
count           SET 45
		REPT 70
		dc.w	count*160
count           SET count+1
		ENDR

scroller_gross_tab:DCB.W 70,16800

scroller_klein_tab:DS.W 70

		;ENDPART

		;PART 'Farbtabelle'
col_pointer:    dc.l	col_tab
col_tab:        
		INCBIN 'HBL.PAL',388
end_col_tab:    INCBIN 'HBL.PAL',140

		;ENDPART

		;PART 'StarTab'
star_tab:
; jeweils Farbe und dann X-Position
; 100 Sterne
		dc.w	1,68
		dc.w	3,164
		dc.w	3,60
		dc.w	2,2
		dc.w	2,154
		dc.w	3,120
		dc.w	1,272
		dc.w	3,184
		dc.w	3,204
		dc.w	2,166
		dc.w	3,300
		dc.w	2,204
		dc.w	3,80
		dc.w	3,156
		dc.w	3,308
		dc.w	2,240
		dc.w	2,272
		dc.w	3,168
		dc.w	1,177
		dc.w	1,305
		dc.w	3,208
		dc.w	3,136
		dc.w	1,261
		dc.w	1,317
		dc.w	3,28
		dc.w	1,212
		dc.w	3,140
		dc.w	3,244
		dc.w	2,304
		dc.w	3,196
		dc.w	2,138
		dc.w	3,296
		dc.w	3,76
		dc.w	1,19
		dc.w	3,180
		dc.w	3,224
		dc.w	1,218
		dc.w	2,262
		dc.w	1,169
		dc.w	1,277
		dc.w	1,1
		dc.w	2,184
		dc.w	1,222
		dc.w	3,292
		dc.w	3,256
		dc.w	3,284
		dc.w	2,216
		dc.w	2,142
		dc.w	1,46
		dc.w	3,144
		dc.w	1,159
		dc.w	3,224
		dc.w	1,283
		dc.w	1,130
		dc.w	2,154
		dc.w	2,110
		dc.w	2,196
		dc.w	2,4
		dc.w	3,256
		dc.w	2,94
		dc.w	2,104
		dc.w	2,114
		dc.w	3,248
		dc.w	2,306
		dc.w	2,250
		dc.w	3,112
		dc.w	3,244
		dc.w	1,143
		dc.w	3,164
		dc.w	3,272
		dc.w	2,264
		dc.w	1,32
		dc.w	2,188
		dc.w	2,6
		dc.w	1,13
		dc.w	1,56
		dc.w	3,0
		dc.w	2,258
		dc.w	3,156
		dc.w	1,216
		dc.w	3,248
		dc.w	2,228
		dc.w	1,314
		dc.w	2,142
		dc.w	3,236
		dc.w	2,198
		dc.w	1,131
		dc.w	3,116
		dc.w	1,7
		dc.w	3,300
		dc.w	1,266
		dc.w	2,270
		dc.w	2,66
		dc.w	2,276
		dc.w	2,70
		dc.w	3,112
		dc.w	1,56
		dc.w	3,244
		dc.w	2,292
		dc.w	1,91
		;ENDPART

		;PART 'Raster Hintergrund'
raster_graphics:
		INCBIN 'RASTER.IMX'

		dc.w	$00,$00,$00,$00,$00,$00,$00,$00
		dc.w	$ff,$00,$00,$00,$fe00,$01ff,$00,$00
		dc.w	$07ff,$ffff,$00,$00,$c003,$c000,$3fff,$00
		dc.w	$ff80,$7f,$ffff,$00,$1ff0,$fff0,$fff0,$0f
		dc.w	$0fe0,$1f,$00,$ffff,$7c39,$fc07,$03ff,$ffff
		dc.w	$9c3e,$7c01,$03ff,$00,$07f0,$fff0,$fff0,$0f
		dc.w	$0ff8,$07,$00,$ffff,$01ff,$ffff,$00,$ffff
		dc.w	$c003,$c000,$3fff,$ffff,$ffe0,$1f,$ffff,$ffff
		dc.w	$7f,$ffff,$ffff,$ffff,$ff00,$ff00,$ff00,$ff00
		dc.w	$00,$00,$00,$00,$00,$00,$00,$00

		;ENDPART

		;PART 'Music'
music:          INCBIN 'PARTY1.MUS'
		EVEN
		;ENDPART

		;PART 'Raster Zeichensatz'
charset:        INCBIN 'FONT2.IMG' ; 65 Zeichen
		;ENDPART

		;PART 'Scrolltext fÅr RasterScroller'
; Effekte:
; --------
; 1 = Scroller groû und nicht bewegen
; 2 = Scroller klein und nicht bewegen
; 3 = Scroller nach hinten gekippt
; 4 = Scroller nach vorne gekippt
; 5 = Scroller wabbelnd
; 6 = Scroller sich verschiebend nach links und rechts
; 7 = Scroller nach links und rechts verschieden wabbelnd
; 8 = Scroller sich nach links und rechts anders verschiebend
; 9 = jeweils zwei Zeilen wabbeln anders
; 10 = Scroller einfarbig
; 11 = Scroller eine Farbe pro Zeile
; 12 = Scroller voll bunt
; 13 = Scroller zur Mitte hin wabbelnd
;----
; # = Smiley
; $ = YO!
; & = HI!
; <,> = Pfeile
; @ = Block
; New Mode = *[\]^_`
; 0 = Endekennzeichen

text_pointer:   dc.l	text
scroll_counter: dc.w	0
char_pointer:   dc.l	char_buffer

text:
		dc.b	5,11," @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
		dc.b	"    "
		dc.b	1,10," &  THIS IS AN ORDINARY SCROLLER YOU COULD EVEN"
		dc.b	" DO WITH STOS OR GFA-BASIC..."
		dc.b	"    "
		dc.b	11,"  SOME BETTER LAMERS COULD DO THIS ONE WITH GFA-BASIC, TOO..."
		dc.b	"    "
		dc.b	2,"  BUT I (*[\]^_`) REALLY DOUBT THAT THEY COULD DO THIS"
		dc.b	" ONE TOO! YOU DON'T THINK SO? SO LET ME CHANGE COLOURS NOW!"
		dc.b	"    "
		dc.b	12,"   LOOKS QUITE COLOURFUL NOW, BUT A LITTLE SMALL?"
		dc.b	" SO LET'S HAVE IT BIGGER..."
		dc.b	"    "
		dc.b	4," THAT ONE'S MUCH BETTER, ISN'T IT?"
		dc.b	"    "
		dc.b	3," AND HOW DO YOU LIKE THIS ONE?"
		dc.b	"    "
		dc.b	5," WE CAN EVEN DISTORT THIS CUTE RASTERSCROLLER, SO"
		dc.b	" BELIEVE US:"
		dc.b	"    "
		dc.b	13," THE UNION - LIGHTYEARS AHEAD!"
		dc.b	"    "
		dc.b	6," WELCOME TO THE OVERLANDERS! HOPE WE REALLY"
		dc.b	" MANAGE TO DO THE UNION DEMO 2!"
		dc.b	"    "
		dc.b	8," @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
		dc.b	"    "
		dc.b	7," BEFORE I START WITH A REAL SCROLLTEXT, I SHOW"
		dc.b	" YOU THE LAST WAVEFORM NOW..."
		dc.b	"    "
		dc.b	9," THIS ONE IS REALLY UGLY AND UNREADABLE, BUT"
		dc.b	" WHO CARES?    "
		dc.b	3," SO LET'S START WITH THE USUAL BULLSHIT NOW..."
		dc.b	"  WRITTEN BY SAMMY JOE...      "

		dc.b	" HELLO AND WELCOME TO WHEN COLORS ARE GOING BANG BANG. THIS SCROLLER"
		dc.b	" IS BEING CREATED BY ONE OF THE NEW MEMBERS OF DELTA FORCE, THE GERMAN."
		dc.b	"    ",8
		dc.b	" WELL, THE ONLY REASON WHY I HAVE JOINED DELTA FORCE IS THAT I WANTED TO LIFT THE"
		dc.b	" STANDARD IN THIS RUN DOWN BUNCH OF ALCOHOLICS AND DISCOHOLICS. TALKING"
		dc.b	" ABOUT -OHOLICS, HAVE YOU HEARD ABOUT WANKOHOLICS ? WELL, IT IS A NEW"
		dc.b	" KINDA SPORT PRACTISED BY LAMERS. LAMERS, HAS ANYBODY WRITTEN TO THE LAMER"
		dc.b	" CLUB FOUNDED BY NIKO SCHOLZ (SPAGETOLAKISMALAGARIKIS TZATZKILAKIS)"
		dc.b	" KOLPINGSTRASSE 75  7300 ESSLINGEN  TEL.: (SEE PHONE BOOK)."
		dc.b	"    ",7
		dc.b	"@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
		dc.b	"    ",13
		dc.b	" WHERE WERE WE ? IN MY ROOM ?!?  WELL, ANYWAY, I AM ALSO A MEMBER OF DELTA FORCE NOW."
		dc.b	" DELTA FORCE IS PROBABLY THE BEST AND LARGEST CREW AROUND, APART FROM SOME"
		dc.b	" OTHER CREWS. SUCK UP...    SUCK MY DICK BITCH !!!!!"
		dc.b	"    ",2
		dc.b	" BY THE WAY MY"
		dc.b	" NEW ADDRESS HERE IN GERMANY IS MICHAEL SCHUESSLER   SEESTRASSE 34/2  7254"
		dc.b	" HEMMINGEN. MY PD LIBRARY IS STILL GOING AND WILL PROBABLY BE AROUND FOR"
		dc.b	" THE NEXT FEW CENTURIES. I WILL PASS IT ON TO MY GRAND CHILDREN."
		dc.b	"    ",3
		dc.b	" MAGGIE WILL NOW BE PUBLISHED BY DELTA FORCE FROM ISSUE 10 ONWARDS"
		dc.b	" (SO WE ARE NOT RESPONSIBLE FOR ANY ISSUES BEFORE NO 10, ED)."
		dc.b	" THERE WILL BE"
		dc.b	" AN ENTIRE NEW MAIN MENU, IT GONNA BE FUCKIN' AWSOME MATE.  PLEASE START"
		dc.b	" SENDING US YOUR BEST PICTURES(REFERING TO GRAPHIC ARTISTS) AS THERE HAVE"
		dc.b	" NOT BEEN ANY AROUND LATELY. IF YOU WANT THE SOURCES TO THIS DEMO (SCREENS"
		dc.b	"  FROM DELTA FORCE ONLY) YOU CAN GET THEM FROM MY PD LIBRARY OR FROM ANY"
		dc.b	" BUDGIE UK DISTRIBUTOR.  AS WE ARE RUNNING OUT OF FAGS, THE WINDOW IS OPEN,"
		dc.b	" AND I WANNA GO TO THE VOLKSFEST I WILL CONTINUE TO TYPE HERE.   TONIGHT WE"
		dc.b	" ARE ALL GONNA GET FUCKING PISSED OUT OF OUR HEADS (WE IS: NEW MODE, "
		dc.b	" QUESTLORD, SPAGETTI (I CAN'T BE BOTHERED TO TYPE THE REST) KERMIT AND OF"
		dc.b	" COURSE MYSELF). AT THIS POINT I WOULD LIKE TO SAY A BIG HI(GH) TO THE"
		dc.b	" BIGGEST SLIMER IN THE UNIVERSE. GO AND FUCK A SNAIL (IT WOULD FIT WOULD"
		dc.b	" NOT IT ?) ANYWAY DOLPH, WE ARE GOING TO HAVE A FUCKING GOOD TIME GETTING"
		dc.b	" DRUNK WHILE YOU ARE SWEATTING YOUR ARSE OFF TRYING TO DO SOMETHING"
		dc.b	" IMPOSSIBLE (I.E. GAINING MUSCLES (QUOTE STEFFEN))."
		dc.b	"     ",6
		dc.b	" I WOULD ALSO LIKE"
		dc.b	" TO SAY HI TO KERMIT WHO IS NOW A NEW GUY IN THE MAGGIE TEAM DOING GAME"
		dc.b	" REVIEWS.  ALL GAMES REVIEWED IN FUTURE MAGGIES ARE COURTESY OF FUNNY"
		dc.b	" SOFTWARE         THIS IS A SHOP IN STUTTGART SELLING GAMES FOR THE"
		dc.b	" IBM, AMIGA  AND OF COURSE ATARI AND OTHERS (FOR EVERYTHING REALLY).  "
		dc.b	" WE WOULD LIKE TO THANK HIM FOR BEING SO KIND. SO, IF YOU WANT ANY CHEAP"
		dc.b	" GAMES, WRITE FOR THE CATALOGUE TO:"
		dc.b	"     ",4
		dc.b	" FUNNY SOFTWARE"
		dc.b	"     ",3
		dc.b	" HOHEWARTSTRASSE 1"
		dc.b	"     ",4
		dc.b	" 7000 STUTTGART-FEUERBACH"
		dc.b	"     ",3
		dc.b	" WWWWEEEESSSSTTTT-GERMANY"
		dc.b	"     ",7
		dc.b	" NOW HERE'S KERMIT ON THE KEYBOARD...         HELLO SNEJ  "
		dc.b	" SHEEPSHAGGER AND WANKER. SORRY THAT I CAN'T TEACH YOU CAD. I AIN' GOT NO"
		dc.b	" TIME. SPECIAL GREETINGS FROM   NEW MODE   FOR BEING A DELTA FORCE FAN!!!!"
		dc.b	" IF YOU GIVE SOME MONEY (10,- DM) YOU WILL GET SOME GREETING FROM NEW MODE"
		dc.b	" (DELTA FORCE) IN THE NEXT DELTA FORCE DEMO OR IN MAGGIE DISC MAGAZINE."
		dc.b	"     ",13
		dc.b	" THIS SPECIAL-OFFER IS ONLY FOR YOU. OTHER LAMERS PAY ONE POUND FOR ONE"
		dc.b	" LETTER. GOOD BYE ALL STEEING LAMERS...................................."

		dc.b	12," "
		dc.b	"     ",5
		dc.b	" @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
		dc.b	"     ",6
		dc.b	" @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
		dc.b	"     ",7
		dc.b	" @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
		dc.b	"     ",8
		dc.b	" @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
		dc.b	"     ",9
		dc.b	" @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
		dc.b	"     ",13
		dc.b	" @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
		dc.b	"                 "
		dc.b	0

		EVEN
		;ENDPART

		;PART 'DF-Logo'
df_logo:  
; 98 hoch
		INCBIN 'DFLOGO2.IMX'
		;ENDPART

		;PART 'Scrollzeichensatz 32*32'
font:           INCBIN 'FONT.IMX'
end_font:
char_anzahl     EQU (end_font-font)/512
		;ENDPART

		;PART 'Scrolltext fÅr Grafikscroller'
scroll_text:
; mit -1 beenden
		INCBIN 'TEXT.IMG'
		EVEN
		;ENDPART

		;PART 'Hidden Picture (Bilbo)'
; Kommt, wenn man * drÅckt
; nur 199 Zeilen hoch wegen Scroller hunten
hidden_pal:     INCBIN 'BILBO.NEO',32,4
hidden_pic:     INCBIN 'BILBO.DOX',32000
		;ENDPART

		BSS

bss_start:
		;PART 'Saveregs' ; dort wird alles hingerettet (MFP, etc.)
oldmfp07:       DS.B 1
oldmfp09:       DS.B 1
oldmfp11:       DS.B 1
oldmfp13:       DS.B 1
oldmfp15:       DS.B 1
oldmfp17:       DS.B 1
oldmfp1b:       DS.B 1
oldmfp21:       DS.B 1
oldres:         DS.B 1
oldsync:        DS.B 1
oldvbl:         DS.L 1
oldkey:         DS.L 1
oldtimerb:      DS.L 1
oldstack:       DS.L 1
old_sr:         DS.W 1
oldpalette:     DS.L 8
oldscreen:      DS.W 1
vsync_count:    DS.L 1
		;ENDPART

		;PART 'Stack'
		DS.B 512        ; 512 Bytes Stack
stack:
		;ENDPART

logopalette:    DS.L 8

		;PART 'Farbbuffer'
color_buffer:   DS.W 30*70      ; 30 Farben*70 Scanlines
		;ENDPART

		;PART 'Starbuffer'
stars_grafik:   DS.B 8*16*3     ; dort werden die Sterne erstellt
star_buffer:    DS.B 320*100*6  ; dort sind die Daten der Sterne
stars_dummy:    DS.L 2          ; dort kommen Daten rein wenn Stern nicht gesetzt
star_restbuff1: DS.B 100*12     ; dort werden Sterne restauriert
star_restbuff2: DS.B 100*12
		;ENDPART

char_buffer:    DS.B 14*15*65   ; Buchstaben um 90 Grad gedreht. 1 Pixel=1 Byte

		;PART 'Screens'
		DS.B 512        ; wegen unteren 8 Bits des Screens
screen_base:    DS.B 264*160*2  ; Platz fÅr 2 Screens
		;ENDPART

bss_ende:
		END
