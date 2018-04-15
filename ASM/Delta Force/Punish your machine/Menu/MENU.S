**** PUNISH YOUR MACHINE MAIN MENU BY NEW MODE OF DELTA FORCE


;!!!! THIS SOURCECODE IS COPYRIGHTED SOFTWARE !!!!


first_screen    EQU 4           ; erste Filenummer -1

max_pic         EQU 15          ; soviele Screens selektierbar

balken_pos      EQU $040c       ; hier steht die Position

hidden_number   EQU 21


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
                pea     start(PC)
                move.w  #38,-(A7)            ; Supexec
                trap    #14
                addq.l  #6,A7

                clr.w   -(A7)
                trap    #1
                ENDC

start:

                ;>PART 'BSS lîschen'
                lea     bss_start,A0
                lea     bss_ende,A1
                moveq   #0,D0
clear_bss:      move.l  D0,(A0)+
                cmpa.l  A0,A1
                bge.s   clear_bss
                ;ENDPART

                move.l  A7,oldstack
                move    SR,old_sr
                ori     #$0700,SR            ; alle IRQ's sperren

                lea     stack,A7             ; eigenen Stack setzen

                bsr     install_all          ; alles initialisieren

                bsr     preshift_roehre

                bsr     create_font          ; Font umrechnen

                bsr     conv_text

                bsr     conv_ste             ; Farben vom STE umrechnen

                bsr     init_sync_scrolling

		moveq	#1,d0
		jsr	music

                IFNE disk_version
                moveq   #0,D0
                move.w  balken_pos.w,D0      ; muss es zerhauen haben!
                bmi.s   wert_mist
                cmp.w   #max_pic,D0
                bgt.s   wert_mist
                lea     mono_pictures,A0
                mulu    #8000,D0
                adda.l  D0,A0
                move.l  A0,bild_pointer      ; auf richtigen Screen gehen
wert_mist:      ENDC

                bsr     prepare_screen       ; Screen aufbauen

                move.l  #vbl,$70.w
                clr.b   key

wait:           bsr     vsync
                move.b  key(PC),D0
wait2:          cmpi.b  #$48,key
                bne.s   not_up
                cmpi.l  #mono_pictures,bild_pointer
                beq.s   not_up
                bsr     screen_up
                bra.s   wait2
not_up:
                cmpi.b  #$50,key
                bne.s   not_down
                cmpi.l  #mono_pictures+max_pic*8000,bild_pointer
                beq.s   wait
                bsr     screen_down
                bra.s   wait2
not_down:
                cmpi.b  #$62,key             ; HELP?
                beq     second_menu
                cmpi.b  #$1c,key             ; RETURN gedrÅckt?
                beq.s   selected
                cmpi.b  #$72,key
                beq.s   selected
                cmpi.b  #$39,key             ; Space gedrÅckt?
                beq.s   selected

; hier ist Hiddenscreenabfrage!

                cmpi.l  #mono_pictures,bild_pointer
                bne.s   wait                 ; geht nur im ersten Bild!

                movea.l hidden_point(PC),A0
                cmp.b   (A0)+,D0             ; nicht gleich Scancode
                bne.s   wait
                move.l  A0,hidden_point
                tst.b   (A0)
                bpl     wait                 ; noch nicht am Ende!

                IFNE disk_version
                clr.w   balken_pos
                ENDC
                move.w  #hidden_number,screen
                bra.s   ende


selected:       cmpi.l  #mono_pictures,bild_pointer ; im ersten Bild geht es nicht!
                beq     wait

                IFNE disk_version
                move.l  bild_pointer,D0
                sub.l   #mono_pictures,D0
                divu    #8000,D0
                move.w  D0,balken_pos
                addq.w  #first_screen,D0
                move.w  D0,screen
                ENDC

ende:
                bsr     leave_screen

exit_help:
                ;>PART 'Quit-Programm' ; hier wird verlassen

		moveq	#0,d0
		jsr	music

                bsr     restore_all          ; alles zurÅcksetzen

                movea.l oldstack,A7          ; alten Stack setzen
                move    old_sr,SR
                IFEQ disk_version
                rts
                ELSEif

                move.w  screen(PC),D1
                moveq   #0,D0
                lea     screen_numbers,A0
                move.b  0(A0,D1.w),D0
                jmp     $0500.w
                ENDC
                ;ENDPART

                ;>PART 'Zweites MenÅ'

second_menu:
; zweites MenÅ nur Text und warten auf Taste

                move.l  #vbl2,$70.w          ; VBL auf nichts
                bsr     vsync

                bsr     vsync

                lea     $ffff8240.w,A0
                moveq   #7,D0                ; Palette lîschen
cl_pal:         clr.l   (A0)+
                dbra    D0,cl_pal

                move.l  screen_mem(PC),D0
                move.l  D0,screen_1
                bsr     set_screen

                movea.l screen_1(PC),A0
                move.w  #7999,D0
cl_s:           clr.l   (A0)+
                dbra    D0,cl_s

                bsr     vsync
                move.b  #2,$ffff820a.w
                bsr     vsync
                move.b  #0,$ffff820a.w       ; Syncerrors beheben
                bsr     vsync
                move.b  #2,$ffff820a.w
                clr.b   $ffff8260.w


                lea     menu2_text(PC),A0
                movea.l screen_1(PC),A1
                moveq   #24,D0               ; 25 Zeilen
line_loop:      moveq   #39,D1               ; 40 Spalten
                moveq   #1,D4                ; Addierwert
row_loop:       lea     chars8(PC),A2
                moveq   #0,D2
                move.b  (A0)+,D2             ; Zeichen holen
                sub.b   #" ",D2              ; erstes Zeichen abziehen
                divu    #40,D2
                move.w  D2,D3
                mulu    #8*40,D3
                adda.w  D3,A2
                swap    D2
                adda.w  D2,A2
                movea.l A1,A3
                moveq   #7,D5                ; 8 Zeilen hoch
copy_char:      move.b  (A2),(A3)
                lea     40(A2),A2
                lea     160(A3),A3
                dbra    D5,copy_char

                adda.w  D4,A1                ; Auf Screen weiter
                eori.w  #6,D4                ; 1 oder 7 in d4
                dbra    D1,row_loop

                lea     7*160(A1),A1
                dbra    D0,line_loop

                moveq   #0,D7
fade_text_up:   move.w  D7,$ffff8242.w       ; Farbe hochfaden
                bsr     vsync
                bsr     vsync
                bsr     vsync
                add.w   #$0111,D7
                cmp.w   #$0888,D7
                bne.s   fade_text_up

check_keys:     moveq   #0,D0
                lea     key_tab(PC),A0
                move.b  key(PC),D0
                moveq   #first_screen,D1     ; Startscreen -1
check_key_loop: tst.b   (A0)
                bmi.s   check_keys           ; An Endekennung angekommen!
                addq.w  #1,D1                ; Screennummer +1
                cmp.b   (A0)+,D0             ; ist Scancode gleich?
                bne.s   check_key_loop

                move.w  D1,screen

                move.w  #$0777,D7
fade_text_down: move.w  D7,$ffff8242.w       ; Farbe runterfaden
                bsr     vsync
                bsr     vsync
                bsr     vsync
                sub.w   #$0111,D7
                bpl.s   fade_text_down

                IFNE disk_version
                move.w  screen(PC),D0
                subq.w  #first_screen,D0
                move.w  D0,balken_pos
                ENDC

                bra     exit_help

                ;ENDPART


screen:         DC.W 0

                ;>PART 'Scrolling fÅr Bilder'

screen_up:
; Scrollt Text um einen Screen nach oben
                moveq   #49,D7               ; ZÑhler
up_loop:        bsr     vsync
                subi.l  #160,bild_pointer    ; 4 Zeilen hîher
                dbra    D7,up_loop
                rts

screen_down:
; Scrollt Text um einen Screen nach unten
                moveq   #49,D7               ; ZÑhler
down_loop:      bsr     vsync
                addi.l  #160,bild_pointer    ; 4 Zeilen tiefer
                dbra    D7,down_loop
                rts

                ;ENDPART

                ;>PART 'Screen sauber verlassen'
leave_screen:
; Screen sauber verlassen. (Farben ausblenden, etc. etc.)


                move.w  #-1,color_stop       ; Farbscrolling anhalten
                bsr     vsync

                movea.l col_pointer(PC),A5
                movea.l A5,A0
                move.w  #205,D0
make_stcols:    andi.w  #$0777,(A0)+
                dbra    D0,make_stcols

                lea     col_tab2,A0
                move.w  #399,D0
make_stcols2:   andi.w  #$0777,(A0)+
                dbra    D0,make_stcols2

                moveq   #24,D7               ; zur Sicherheit
fade_loop:      movea.l A5,A0
                move.w  #204,D2              ; 205 Farben
                bsr     fade_down

                lea     text_color1+2(PC),A0 ; Vertikalen Scrolltext abblenden
                moveq   #0,D2                ; eine Farbe
                bsr     fade_down
                lea     text_color2+2(PC),A0 ; Vertikalen Scrolltext abblenden
                moveq   #0,D2                ; eine Farbe
                bsr     fade_down
                lea     text_color3+2(PC),A0 ; Vertikalen Scrolltext abblenden
                moveq   #0,D2                ; eine Farbe
                bsr     fade_down

                bsr     vsync

                dbra    D7,fade_loop


                moveq   #24,D7
fade_loop3:
                lea     col_tab2,A0          ; Vordergrundfarbe abblenden
                move.w  #399,D2              ; 400 Farben
                bsr     fade_down2

                bsr     vsync

                dbra    D7,fade_loop3

                rts

                ;ENDPART

                ;>PART 'Fade-Routinen'

fade_down:
; faded Farben runter
; a0=Pointer
; d2=Anzahl-1

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

fade_down2:
; faded Farben runter (auf Blau zuletzt)
; a0=Pointer
; d2=Anzahl-1

fdl02:
                move.w  (A0),D0
                and.w   #%11100000000,D0
                beq.s   col22
                sub.w   #$0100,D0
                move.w  (A0),D1
                and.w   #%1111100011111111,D1
                or.w    D0,D1
                move.w  D1,(A0)
                bra.s   colok2
col22:          move.w  (A0),D0
                and.w   #%1110000,D0
                beq.s   col32
                sub.w   #$10,D0
                move.w  (A0),D1
                and.w   #%1111111110001111,D1
                or.w    D0,D1
                move.w  D1,(A0)
                bra.s   colok2

col32:          move.w  (A0),D0
                and.w   #%111,D0
                beq.s   colok2
                subq.w  #1,D0
                move.w  (A0),D1
                and.w   #%1111111111111000,D1
                or.w    D0,D1
                move.w  D1,(A0)

colok2:         lea     2(A0),A0
                dbra    D2,fdl02
                rts

                ;ENDPART

;-----------------------------------------------------------------------------
                ;>PART 'Install' ; alles installieren (MFP,...)

install_all:
; Initialisiert alle Hardware-Register

                move.b  $ffff820a.w,oldsync
                move.b  $ffff8260.w,oldres

                movem.l $ffff8240.w,D0-D7
                movem.l D0-D7,oldpalette

                lea     $ffff8240.w,A0
                moveq   #7,D0
clrpal:         clr.l   (A0)+
                dbra    D0,clrpal

                lea     $ffff8201.w,A0       ; Screenadresse holen
                movep.w 0(A0),D0
                move.w  D0,oldscreen

                move.l  #screen_base,D0
                and.l   #-256,D0             ; untere 8 Bits weg
                move.l  D0,screen_1
                move.l  D0,screen_mem
                movea.l D0,A0
                add.l   #36864,D0
                move.l  D0,screen_2
                movea.l D0,A1

                move.w  #(229*40)-1,D0       ; beide Screens lîschen
clr_screens:    clr.l   (A0)+
                clr.l   (A1)+
                dbra    D0,clr_screens

                move.l  screen_1(PC),D0
                bsr     set_screen

                bsr     init_mfp

                move    #$2300,SR            ; IRQ's an

                moveq   #$12,D0              ; Maus aus
                bsr     send_ikbd

                bsr     vsync
                move.b  #2,$ffff820a.w       ; 50 Hz
                bsr     vsync
                move.b  #0,$ffff820a.w       ; 60 Hz
                bsr     vsync
                move.b  #2,$ffff820a.w       ; 50 Hz ; damit Syncerrors weg

                bsr     vsync
                clr.b   $ffff8260.w          ; Lowres

                rts

                ;ENDPART

                ;>PART 'Restore' ; alles zurÅcksetzen

restore_all:
; alle Hardware-Register werden wieder so gesetzt wie am Anfang

                move.l  #start_vbl,$70.w
                bsr     vsync

                ori     #$0300,SR

                movem.l oldpalette,D0-D7
                movem.l D0-D7,$ffff8240.w

                bsr     vsync
                move.b  #2,$ffff820a.w       ; 50Hz

                bsr     vsync
                move.b  #0,$ffff820a.w       ; 60Hz (damit Syncerrors beheben)

                bsr     vsync
                move.b  oldsync,$ffff820a.w  ; alte Sync. und Res. zurÅck
                move.b  oldres,$ffff8260.w

                bsr     restore_mfp

                moveq   #$08,D0              ; Maus wieder ein
                bsr     send_ikbd

                move.w  oldscreen,D0
                lea     $ffff8201.w,A0
                movep.w D0,0(A0)             ; alte Screenadresse setzen

                rts
                ;ENDPART

                ;>PART 'SendIKBD'
send_ikbd:
; sendet Byte aus d0 an IKBD
                lea     $fffffc00.w,A0
waitkeyready:   btst    #1,(A0)
                beq.s   waitkeyready
                move.b  D0,2(A0)
                rts

                ;ENDPART

                ;>PART 'Vsync'
vsync:          lea     vsync_count,A0
                move.l  (A0),D0
wait_strahl:    cmp.l   (A0),D0
                beq.s   wait_strahl
                rts
                ;ENDPART

                ;>PART 'MFP-Install+DeInstall'
init_mfp:
; rettet und setzt alle IRQ's

                move    SR,-(A7)
                ori     #$0700,SR
                move.l  $0118.w,oldkey
                move.l  $0120.w,oldtimerb
                move.l  $70.w,oldvbl
                move.l  $68.w,oldhbl
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
                bset    #6,$09(A0)           ; Tastatur IRQ erlauben
                bset    #6,$15(A0)
                bclr    #3,$17(A0)           ; Automatic EOI

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
                move.l  oldhbl,$68.w
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
;------------------------------------------------------------------------------

                ;>PART 'Text konvertieren'
conv_text:
                lea     text(PC),A0
                lea     contab(PC),A1
conv_loop:      moveq   #0,D0
                move.b  (A0),D0
                cmp.b   #-1,D0
                beq.s   end_conv
                cmp.b   #-2,D0               ; -2 nicht konvertieren
                bne.s   not_cen
                move.b  #-2,(A0)+
                bra.s   conv_loop
not_cen:        move.b  0(A1,D0.w),(A0)+
                bra.s   conv_loop
end_conv:       rts

                ;ENDPART

                ;>PART 'Farben vom STE umrechnen'

conv_ste:
; STE-Farben umrechnen
                lea     old_col_tab(PC),A0
ste_umrechen:   cmpa.l  #end_ste_colors,A0
                beq.s   endumrechen
                move.w  (A0),D0              ; Wert holen
                move.w  D0,D1
                and.w   #%1111,D1            ; nur Bits 0-3
                lsr.w   #1,D1
                bcc.s   nixbluebit
                bset    #3,D1                ; rausgechobenes
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
nixredbit:      and.w   #%1111000011111111,D0
                or.w    D1,D0
                move.w  D0,(A0)+
                bra.s   ste_umrechen

endumrechen:

; Schreibt jede Farbe im folgenden Format:
; Farbe 1, Farbe 0, Farbe 2, Farbe 1

                lea     old_col_tab(PC),A0
                lea     col_tab,A1
                lea     col_tab_ende,A2
                move.w  #anzcolors-1,D0
                move.w  (A0),D1
make_tab:       move.w  (A0),(A1)+
                move.w  D1,(A1)+
                move.w  (A0),(A2)+
                move.w  D1,(A2)+
                move.w  (A0),(A1)+
                move.w  (A0),(A2)+
                move.w  (A0)+,D1
                dbra    D0,make_tab

                lea     col_tab+720,A0
                lea     col_tab2,A1
                move.w  #199,D0
make_coltab2:   move.w  (A0),(A1)+           ; Langworte erzeugen
                move.w  (A0)+,(A1)+
                dbra    D0,make_coltab2

                rts

                ;ENDPART

                ;>PART 'Screen-Verwaltung'
prepare_screen:
; baut den ersten Screen auf.

                move.w  #199,D7              ; 200 Zeile aufbauen
prepare_loop:   bsr     handle_screen
                bsr     set_screen
                bsr     draw_roehre
                dbra    D7,prepare_loop
                rts


handle_screen:
; erledigt das Handling des Screenpointers unter BerÅcksichtigung der
; Syncscrolltechnik.

                addi.l  #160,screen_1
                move.l  screen_1(PC),D0

                move.l  screen_mem(PC),D1
                move.l  D1,D2
                add.l   #201*160,D1
                cmp.l   D1,D0
                blt.s   not_reset_screen

                move.l  D2,D0
not_reset_screen:
                move.l  D0,screen_1
                rts

                ;ENDPART

                ;>PART 'Vertikaler Scroller'

scroll_up:
; Scroller hoch.
; Buchstaben werden zentriert
                move.w  scroll_noth_count(PC),D0
                beq.s   scroll_normal        ; gerade aussetzen?
                subq.w  #1,D0
                move.w  D0,scroll_noth_count
                rts

scroll_normal:  subq.w  #1,scroll_up_count   ; schon 14 Zeilen gescrollt?
                bpl.s   not_end_scrollup
                move.w  #16,scroll_up_count  ; 16 Scanlines hoch
                move.w  #16,scroll_noth_count ; 16 Zeilen nichts scrollen

                lea     scroll_up_point,A1
                movea.l text_pos(PC),A2      ; dort ist Text
                cmpi.b  #-1,(A2)
                bne.s   not_end_text2
                lea     text(PC),A2
not_end_text2:  moveq   #19,D0               ; max 20 Pointer berechnen
                moveq   #0,D7                ; Anzahl Zeichen auf 0 setzen
calc_pointers:  moveq   #0,D1
                move.b  (A2)+,D1             ; Zeichen holen
                cmp.b   #-2,D1               ; Endekennung
                beq.s   end_of_line

                addq.w  #1,D7                ; Anzahl Zeichen +1
                lea     font_buffer,A0

                lsl.w   #7,D1                ; *128 = Zeichenhîhe
                adda.w  D1,A0

; Hier Fontberechnung einsetzen

                move.l  A0,(A1)+             ; Pointer ablegen
                dbra    D0,calc_pointers
end_of_line:
                move.l  A2,text_pos

                moveq   #0,D4                ; Offset auf 0 init
                moveq   #20,D6
                sub.w   D7,D6                ; jetzt Werte von 0-19 in d6
                subq.w  #1,D7                ; Anzahl-1 wegen DBRA
                move.w  D7,anzahl_chars      ; soviele Buchstaben pro Zeile
                lsr.w   #1,D6                ; durch zwei teilen
                lsl.w   #3,D6                ; *16 Pixel
                add.w   D6,D4
                move.w  D4,centre_offset

                rts

not_end_scrollup:
                movea.l screen_1(PC),A0
                adda.l  screen_offset(PC),A0
                movea.l A0,A1
                lea     32000-160(A0),A0
                lea     -160-160(A1),A1

                lea     scroll_up_point,A2
                move.w  anzahl_chars(PC),D0  ; soviele Buchstaben
                adda.w  centre_offset(PC),A1 ; um soviel einrÅcken
                adda.w  centre_offset(PC),A0
knuepf_font:    movea.l (A2),A3              ; Pointer holen
                addq.l  #8,(A2)+             ; Pointer um eine Zeile tiefer
                movem.w (A3),D1-D4           ; 4 Worte holen
                and.w   D1,(A0)
                and.w   D1,(A1)
                or.w    D2,(A0)+
                or.w    D2,(A1)+
                and.w   D1,(A0)
                and.w   D1,(A1)
                or.w    D3,(A0)+
                or.w    D3,(A1)+
                and.w   D1,(A0)
                and.w   D1,(A1)
                or.w    D4,(A0)+
                or.w    D4,(A1)+
                addq.l  #2,A0
                addq.l  #2,A1                ; Eine Plane Åberspringen
                dbra    D0,knuepf_font
                rts

centre_offset:  DC.W 0          ; um soviele Bitblocks springen
anzahl_chars:   DC.W 0          ; soviele Zeichen pro Zeile darstellen
scroll_noth_count:DC.W 0
scroll_up_count:DC.W 0

                ;ENDPART

                ;>PART 'Rîhre reinkopieren'
draw_roehre:
                addq.l  #2,sinus_pointer
                movea.l sinus_pointer(PC),A0
                cmpi.w  #-99,(A0)
                bne.s   not_end_sinus
                lea     sinus_tab(PC),A0
not_end_sinus:  move.l  A0,sinus_pointer

                move.w  (A0),D0
                and.w   #31,D0               ; nur Werte von 0-31
                lsl.w   #4,D0                ; *16
                lea     roehre_preshifted,A0
                adda.w  D0,A0
                movem.l (A0)+,D0-D3          ; 4 Longs holen
                movea.l screen_1(PC),A0
                adda.l  screen_offset(PC),A0
                movea.l A0,A1
                lea     32000(A0),A0
                lea     -160(A1),A1
                REPT 10
                movem.l D0-D3,-(A0)          ; Rîhre auf Screen hauen
                movem.l D0-D3,-(A1)          ; Rîhre auf Screen hauen
                ENDR
                rts

                ;ENDPART

                ;>PART 'Rîhre shiften'

preshift_roehre:

; shiftet die Rîhre 32 mal vor in Buffer. Das was rechts rausgeschoben wird,
; kommt links wieder rein. Nimmt jeweils die vorige Shiftphase und schiebt diese
; ein mal nach rechts.

                lea     roehre_preshifted,A0 ; dort kommt Rîhre rein
                lea     16(A0),A1            ; eine Shiftphase weiter

                movem.l roehre(PC),D0-D3     ; erste Shiftphase (=0) holen
                movem.l D0-D3,(A0)           ; in Buffer ablegen

                moveq   #31,D0               ; 32 mal shiften
shift_roehre_loop:
                moveq   #3,D4                ; 4 Planes
shift_roehre_loop2:
                moveq   #0,D1
                move.w  (A0),D1
                ror.l   #1,D1                ; um eins nach rechts
                moveq   #0,D2
                move.w  8(A0),D2
                ror.l   #1,D2
                swap    D1
                or.w    D1,D2                ; Rest vom ersten Wort einodern
                move.w  D2,8(A1)
                swap    D1
                swap    D2
                or.w    D2,D1
                move.w  D1,(A1)
                lea     2(A0),A0             ; eine Plane weiter
                lea     2(A1),A1
                dbra    D4,shift_roehre_loop2
                lea     8(A0),A0             ; zweite 16 Pixel Åberspringen
                lea     8(A1),A1
                dbra    D0,shift_roehre_loop
                rts

                ;ENDPART

                ;>PART 'Font erstellen'
create_font:
; wandelt Font von Screenformat in folgendes Format um:
; 1 Wort Maske, 3 Worte Grafik
; Maske ist um eine Reihe nach rechts und nach unten verschoben >> Schatten

                lea     font_buffer,A2
                moveq   #0,D0
change_font_loop:
                lea     font(PC),A0
                lea     fontmask,A1
                moveq   #0,D1
                move.w  D0,D1
                divu    #20,D1               ; Zeichenposition errechnen
                move.w  D1,D3
                move.l  D1,D4
                move.w  D1,D2
                mulu    #16*160,D2
                adda.w  D2,A0
                swap    D1
                lsl.w   #3,D1                ; *8
                adda.w  D1,A0
                mulu    #16*40,D3
                adda.w  D3,A1
                swap    D4
                add.w   D4,D4
                adda.w  D4,A1

                moveq   #15,D1
                movea.l A2,A3
copy_font_loop:
                move.w  (A1),D3
                not.w   D3
                move.w  D3,(A3)+
                move.w  (A0),(A3)+
                move.w  2(A0),(A3)+          ; 3 Planes
                move.w  4(A0),(A3)+
                lea     160(A0),A0           ; eine Zeile tiefer
                lea     40(A1),A1
                dbra    D1,copy_font_loop
                lea     128(A2),A2           ; ein Zeichen weiter im Buffer
                addq.w  #1,D0
                cmp.w   #60,D0
                bne.s   change_font_loop
                rts

                ;ENDPART

vbl:
                tst.b   $fffffc02.w

                move.l  #open_top,$68.w
                move.w  #32,hbl_count


                andi.w  #$f9ff,(A7)
                rte

vbl2:           addq.l  #1,vsync_count       ; wÑhrend zweitem MenÅ
                rte


; --------- **** 7UP-SYNC SCROLLING **** -----------------------------------
;
;       BY NEW MODE OF DELTA FORCE/THE UNION
;


hbl_count:      DC.W 32

open_top:       subq.w  #1,hbl_count         ; solange, bis Zeile erreicht
                bmi.s   hbl_is_da
                rte


hbl_is_da:      move.l  #open_top_2,$68.w
waithere:       stop    #$2100
                bra.s   waithere

open_top_2:
; klappt den oberen Rand auf
; hier kommt er mit a2=Zeiger auf Digidaten an

                move    #$2700,SR

                addq.l  #6,A7                ; Stack korrigieren

                movem.l D0-A6,-(A7)          ; alle Register retten

                DCB.W 56,$4e71

                move.b  #0,$ffff820a.w       ; 60 Hz

                DCB.W 17,$4e71

                move.b  #2,$ffff820a.w       ; 50 Hz

                movea.l sync_pointer1(PC),A0

                movea.l bild_pointer,A5
                movea.l screen_1(PC),A6
                adda.l  screen_offset(PC),A6
                lea     6(A6),A6             ; auf Plane 3 gehen

; erste 7 Zeilen werden im Syncloop kopiert
                lea     $ffff8209.w,A3
                moveq   #0,D0
                moveq   #2,D1
                moveq   #0,D3
wait_sync2:     move.b  (A3),D3
                cmp.w   #64,D3
                blt.s   wait_sync2
                sub.w   #64,D3
                not.w   D3
                lsr.w   D3,D3

                lea     $ffff820a.w,A3
                lea     $ffff8260.w,A4


                DCB.W 29,$4e71

                movea.l (A0)+,A1             ; Routine aus Tabelle holen
                jmp     (A1)                 ; und diese anspringen


end_sync:
; in a2 ist Pointer auf Digibuffer

                movea.l col_pointer(PC),A3

                lea     $ffff8242.w,A0
                lea     $ffff8802.w,A1

                move.w  #192,D7              ; 193 Scanlines aufmachen!
                lea     col_tab2,A4

                DCB.W 80,$4e71

text_color1:    move.w  #$0770,6*2(A0)       ; Textfarben setzen
text_color2:    move.w  #$0650,5*2(A0)
text_color3:    move.w  #$0530,4*2(A0)

; a5=Bild
; a6=Screen
; a3=Farbtabelle
; a4=Farbtabelle fÅr Logos (als Longs abgelegt)
; a0=$ffff8242
; d7=Counter
; a2=$ffff8802.w
; a1=Sounddatas

sync_loop:
                move.l  (A3)+,(A0)+          ; [20]    Farben reinkopieren
                move.l  (A3)+,(A0)+          ; [20]
                subq.l  #8,A0                ; [8]
                subq.l  #6,A3                ; [8]   / [76]

                move.l  (A4)+,D0             ; [12]
                move.l  D0,D1                ; [4]
                move.l  D0,D2                ; [4]
                move.l  D0,D3                ; [4]

		DCB.W	4,$4E71
                movem.l D0-D3,14(A0)         ; [44] Farben ablegen

                move.w  (A5)+,(A6)           ; [12]
off_1           SET 8
                REPT 19         ; Eine Zeile des Bilds reinkopieren
                move.w  (A5)+,off_1(A6)      ; 19*[16]=304
off_1           SET off_1+8
                ENDR
                lea     160(A6),A6           ; [8]

                DCB.W 9,$4e71

                dbra    D7,sync_loop         ; [12]


; kein Logo mehr kopieren!

                moveq   #6,D7                ; 7 Scanlines weitermachen
sync_loop2:     move.l  (A3)+,(A0)+          ; [20]    Farben reinkopieren
                move.l  (A3)+,(A0)+          ; [20]
                subq.l  #8,A0                ; [8]
                subq.l  #6,A3                ; [8]   / [76]

                move.l  (A4)+,D0             ; [12]
                move.l  D0,D1                ; [4]
                move.l  D0,D2                ; [4]
                move.l  D0,D3                ; [4]

		DCB.W	4,$4E71
                movem.l D0-D3,14(A0)         ; [44] Farben ablegen

                DCB.W 88,$4e71

                dbra    D7,sync_loop2        ; [12]


                moveq   #0,D0                ; Palette lîschen
                REPT 7
                move.l  D0,(A0)+
                ENDR
                move.w  D0,(A0)


                tst.w   color_stop           ; angehalten ?
                bne.s   dont_scroll_cols
                addq.l  #4,col_pointer
dont_scroll_cols:
                cmpi.l  #col_tab_ende,col_pointer
                ble.s   not_end_of_tab
                move.l  #col_tab,col_pointer
not_end_of_tab:

                bsr     handle_screen

                bsr     draw_roehre

                bsr     scroll_up

		jsr	music+8

                move.l  screen_1(PC),D0
                bsr     set_screen

                addq.l  #1,vsync_count

                movem.l (A7)+,D0-A6
                ori.w   #$0300,(A7)          ; SR auf $2300 setzen
                rte

                ;ENDPART

                ;>PART 'Set-Screen (Syncscrolling)'
set_screen:
; in d0 = Screenadresse
; stellt Lowbyte durch Syncscrolling dar
                move.l  sync_pointer1(PC),D1 ; Pointer tauschen
                move.l  sync_pointer2(PC),sync_pointer1
                move.l  D1,sync_pointer2

                move.l  D0,D1
                and.w   #255,D1              ; nur untere 8 Bits
                lea     sync_pointer_tab(PC),A0 ; dort sind Routinen
                lsr.w   #1,D1                ; durch 2 -> 0-127
                move.w  D1,D2
                lsl.w   #5,D1                ; *32 (8 Longs)
                adda.w  D1,A0
                move.l  A0,sync_pointer1
                lea     sync_offset_tab(PC),A0
                lsl.w   #2,D2                ; *4 (wegen Longs)
                add.l   0(A0,D2.w),D0        ; Offset auf Screen addieren
                lsr.l   #8,D0
                lea     $ffff8201.w,A0       ; Screen setzen (Mid- und Highbyte)
                movep.w D0,0(A0)
                rts

                ;ENDPART

                ;>PART 'Sync-Routinen'


; Hier sind die Routinen, die die RÑnder aufmachen
; Kopiert die ersten 7 Scanlines des Logos
; Spielen auch Digidrums ab
; in a2=Digisounddaten, a5=Logo, a6=Screen

sync_routine1:
; klappt beide RÑnder auf.
; braucht 70 Bytes
                move.b  D1,(A4)              ; Highres
                nop
                move.b  D0,(A4)              ; Lowres (Links auf)

                move.w  (A5)+,(A6)           ; [12]
off_1           SET 8
                REPT 19         ; Eine Zeile des Bilds reinkopieren
                move.w  (A5)+,off_1(A6)      ; 19*[16]=304
off_1           SET off_1+8
                ENDR
                lea     160(A6),A6           ; [8]

                DCB.W 8,$4e71

                move.b  D0,(A3)              ; 60Hz
                move.b  D1,(A3)              ; 50Hz (Rechts auf)

                DCB.W 13,$4e71

                move.b  D1,(A4)              ; Highres
                nop
                move.b  D0,(A4)              ; Lowres (Rechts zu)

                DCB.W 12-5,$4e71

                movea.l (A0)+,A1             ; nÑchste Routine holen (12)
                jmp     (A1)                 ; und die anspringen    (8)


sync_routine2:
; klappt nur linken Rand auf
; braucht 26 Bytes


                move.b  D1,(A4)              ; Highres
                nop
                move.b  D0,(A4)              ; Lowres (Links auf)

                move.w  (A5)+,(A6)           ; [12]
off_1           SET 8
                REPT 19         ; Eine Zeile des Bilds reinkopieren
                move.w  (A5)+,off_1(A6)      ; 19*[16]=304
off_1           SET off_1+8
                ENDR
                lea     160(A6),A6           ; [8]


                DCB.W 8,$4e71

                move.b  D1,(A3)              ; 50Hz
                move.b  D1,(A3)              ; 50Hz (nur Dummy)

                DCB.W 13,$4e71

                move.b  D1,(A4)              ; Highres
                nop
                move.b  D0,(A4)              ; Lowres (Rechts "zu")

                DCB.W 12-5,$4e71
                movea.l (A0)+,A1             ; nÑchste Routine holen (12)
                jmp     (A1)                 ; und die anspringen    (8)


sync_routine3:
; klappt linken Rand auf und schneidet 2 Bytes ab.
; braucht 24 Bytes

                move.b  D1,(A4)              ; Highres
                nop
                move.b  D0,(A4)              ; Lowres (Links auf)


                move.w  (A5)+,(A6)           ; [12]
off_1           SET 8
                REPT 19         ; Eine Zeile des Bilds reinkopieren
                move.w  (A5)+,off_1(A6)      ; 19*[16]=304
off_1           SET off_1+8
                ENDR
                lea     160(A6),A6           ; [8]


                DCB.W 7,$4e71    ; ein NOP weniger!!

                move.b  D0,(A3)              ; 60Hz
                move.b  D1,(A3)              ; 50Hz (Rechts auf)

                DCB.W 14,$4e71

                move.b  D1,(A4)              ; Highres
                nop
                move.b  D0,(A4)              ; Lowres (Rechts zu)
                DCB.W 12-5,$4e71
                movea.l (A0)+,A1             ; nÑchste Routine holen (12)
                jmp     (A1)                 ; und die anspringen    (8)



sync_routine4:
; klappt rechten Rand auf und schneidet 2 Bytes ab.
; braucht -2 Bytes

                move.b  D0,(A4)              ; Lowres (Dummy)
                nop
                move.b  D0,(A4)              ; Lowres ("Links auf")



                move.w  (A5)+,(A6)           ; [12]
off_1           SET 8
                REPT 19         ; Eine Zeile des Bilds reinkopieren
                move.w  (A5)+,off_1(A6)      ; 19*[16]=304
off_1           SET off_1+8
                ENDR
                lea     160(A6),A6           ; [8]


                DCB.W 7,$4e71    ; ein NOP zu frÅh

                move.b  D0,(A3)              ; 60Hz
                move.b  D1,(A3)              ; 50Hz (Rechts auf)

                DCB.W 14,$4e71

                move.b  D1,(A4)              ; Highres
                nop
                move.b  D0,(A4)              ; Lowres (Rechts zu)

                DCB.W 12-5,$4e71
                movea.l (A0)+,A1             ; nÑchste Routine holen (12)
                jmp     (A1)                 ; und die anspringen    (8)



sync_routine5:
; Nur rechten Rand aufmachen
; stellt 44 Bytes dar

                move.b  D0,(A4)              ; Lowres (Dummy)
                nop
                move.b  D0,(A4)              ; Lowres ("Links auf")


                move.w  (A5)+,(A6)           ; [12]
off_1           SET 8
                REPT 19         ; Eine Zeile des Bilds reinkopieren
                move.w  (A5)+,off_1(A6)      ; 19*[16]=304
off_1           SET off_1+8
                ENDR
                lea     160(A6),A6           ; [8]

                DCB.W 8,$4e71

                move.b  D0,(A3)              ; 60Hz
                move.b  D1,(A3)              ; 50Hz (Rechts auf)

                DCB.W 13,$4e71

                move.b  D1,(A4)              ; Highres
                nop
                move.b  D0,(A4)              ; Lowres (Rechts zu)

                DCB.W 12-5,$4e71

                movea.l (A0)+,A1             ; nÑchste Routine holen (12)
                jmp     (A1)                 ; und die anspringen    (8)

sync_routine0:
; macht 512 TZ lang nichts

                DCB.W 30,$4e71

                move.w  (A5)+,(A6)           ; [12]
off_1           SET 8
                REPT 19         ; Eine Zeile des Bilds reinkopieren
                move.w  (A5)+,off_1(A6)      ; 19*[16]=304
off_1           SET off_1+8
                ENDR
                lea     160(A6),A6           ; [8]


                DCB.W 12,$4e71
                movea.l (A0)+,A1             ; nÑchste Routine holen (12)
                jmp     (A1)                 ; und die anspringen    (8)

                ;ENDPART

                ;>PART 'Init-Syncscrolling'
init_sync_scrolling:
; generelle Initialisierungsroutine

                bsr.s   get_anzahl_zeilen    ; ermitteln, wieviel Scanlines dargestellt werden
                bsr     create_tabellen      ; Tabellen aufbauen
                move.l  #9*160,screen_offset
                rts

                ;ENDPART

                ;>PART 'Create-Tables'
create_tabellen:
; erstellt Pointertabellen fÅr Syncscrolling (im BSS)
                lea     sync_tabelle(PC),A0
                lea     sync_pointer_tab(PC),A1
                lea     sync_offset_tab(PC),A2
                lea     sync_routine_tab(PC),A3
                move.w  #(256/2)-1,D0        ; 128 Werte (2er Syncscrolling)
createtabloop0: moveq   #6,D1                ; 7 Routinen
createtabloop1: moveq   #0,D2
                move.b  (A0)+,D2             ; Wert von 0-5 holen
                lsl.w   #2,D2                ; *4 wegen Longs
                move.l  0(A3,D2.w),(A1)+     ; Routine in Pointertab ablegen
                dbra    D1,createtabloop1
                move.l  #end_sync,(A1)+      ; Letzte Routine immer dazu
                move.b  (A0)+,D2             ; Offsetwert holen
                beq.s   is_off0
                bpl.s   is_off1
                move.l  #-256,(A2)+          ; jeweiligen Offset setzen
                bra.s   off_ok
is_off0:        clr.l   (A2)+
                bra.s   off_ok
is_off1:        move.l  #256,(A2)+
off_ok:         dbra    D0,createtabloop0
                rts




sync_routine_tab:
; Hier stehen die mîglichen Routinen drin.
; Wird zum Berechnen benîtigt

                DC.L sync_routine0
                DC.L sync_routine1
                DC.L sync_routine2
                DC.L sync_routine3
                DC.L sync_routine4
                DC.L sync_routine5

                ;ENDPART

                ;>PART 'MMU-Test'


get_anzahl_zeilen:
; Routine ermittelt die MMU des ST's, d.h. wieviele Zeilen dargestellt werden
; (wenn oberer Rand auf ist)

                move    #$2700,SR
                move.l  $70.w,-(A7)          ; VBL und HBL retten
                move.l  $68.w,-(A7)

                move.l  #test_vbl,$70.w
                move.l  #test_hbl1,$68.w
                move.w  #340,hbl_count       ; Wert sehr hoch setzen

                move    #$2300,SR
                bsr     vsync

                clr.b   $fffffa1b.w
                move.b  #255,$fffffa21.w
                move.b  #8,$fffffa1b.w       ; Timer B start

                move.b  $ffff8209.w,D0
wait_lowbyte:   cmp.b   $ffff8209.w,D0
                beq.s   wait_lowbyte

                moveq   #0,D1
wait_loop:      addq.w  #1,D1
                cmp.w   #5,D1
                bgt.s   wait_ready
                move.b  $ffff8209.w,D0
                cmp.b   $ffff8209.w,D0
                beq.s   wait_loop
                moveq   #0,D1
                bra.s   wait_loop
wait_ready:     move.w  #255,D0
                sub.b   $fffffa21.w,D0       ; aktuelle ZÑhler abziehen
                move.w  D0,anzahl_zeilen
                bsr     vsync

                move    #$2700,SR

                move.l  (A7)+,$68.w
                move.l  (A7)+,$70.w
                move    #$2300,SR
                rts

test_vbl:       move.w  #32,hbl_count        ; dort oberen Rand aufmachen
                move.l  #test_hbl1,$68.w     ; HBL Routine
                addq.l  #1,vsync_count
                andi.w  #$f1ff,(A7)          ; HBL erlauben (SR auf $2100)
                rte

test_hbl1:      subq.w  #1,hbl_count
                bmi.s   test_hbl2
                rte
test_hbl2:      move.l  #test_hbl3,$68.w     ; neuen HBL setzen
wait_for_hbl:   stop    #$2100               ; warten bis HBL da!
                bra.s   wait_for_hbl

test_hbl3:      move    #$2700,SR            ; alle IRQ's aus
                addq.l  #6,A7                ; Stack korrigieren
                DCB.W 89,$4e71
                move.b  #0,$ffff820a.w       ; 60 Hz
                DCB.W 17,$4e71
                move.b  #2,$ffff820a.w       ; 50 Hz
                ori.w   #$0300,(A7)          ; SR auf $2300
                rte

anzahl_zeilen:  DC.W 0


                ;ENDPART

                ;>PART 'Sync-Tabellen'

sync_pointer1:  DC.L sync_pointer_tab ; auf Routine "0" zeigen
sync_pointer2:  DC.L sync_pointer_tab

sync_offset_tab:
; Hier kommen die jeweiligen Offsets fÅr die Syncoffsets rein
; (256, -256 oder 0)
; kann ins BSS kommen
; Hier fÅr 2er Lowbytes

                DS.L 256/2

sync_pointer_tab:
                DS.L 256/2*8
; kann ins BSS kommen. Hier sind jeweils 8 Pointer auf die Routinen pro
; Offset (hier 2er Lowbytes mîglich)


sync_tabelle:

; eigentliche Tabelle mit jeweils 8 Bytes.
; davon 7 Bytes Randwerte (welche Routine 0-5).
; Achtes Byte: 0=Screenoffset 0, 1=Screenoffset 256, -1=Screenoffset -256
                DC.B 0,0,0,0,0,0,0,0 ; 0
                DC.B 1,1,1,3,3,0,0,-1 ; 2
                DC.B 1,1,3,3,3,3,3,-1 ; 4
                DC.B 4,5,5,5,5,5,5,-1 ; 6
                DC.B 5,5,5,5,5,5,0,-1 ; 8
                DC.B 2,2,2,1,1,3,3,-1 ; 10
                DC.B 3,3,5,5,5,5,5,-1 ; 12
                DC.B 1,3,5,5,5,5,0,-1 ; 14
                DC.B 1,1,5,5,5,0,0,-1 ; 16
                DC.B 1,3,3,3,5,5,5,-1 ; 18
                DC.B 1,1,3,3,5,5,0,-1 ; 20
                DC.B 1,1,1,3,5,0,0,-1 ; 22
                DC.B 1,1,1,1,0,0,0,-1 ; 24
                DC.B 1,1,1,3,3,3,0,-1 ; 26
                DC.B 2,1,1,1,3,3,0,-1 ; 28
                DC.B 2,2,1,1,1,3,0,-1 ; 30
                DC.B 3,5,5,5,5,5,5,-1 ; 32
                DC.B 1,5,5,5,5,5,0,-1 ; 34
                DC.B 4,4,4,4,5,0,0,0 ; 36
                DC.B 1,3,3,5,5,5,5,-1 ; 38
                DC.B 1,1,3,5,5,5,0,-1 ; 40
                DC.B 1,1,1,5,5,0,0,-1 ; 42
                DC.B 1,1,3,3,3,5,5,-1 ; 44
                DC.B 1,1,1,3,3,5,0,-1 ; 46
                DC.B 3,3,0,0,0,0,0,0 ; 48
                DC.B 1,1,1,3,3,3,3,-1 ; 50
                DC.B 5,5,5,5,5,5,5,-1 ; 52
                DC.B 2,2,1,1,1,3,3,-1 ; 54
                DC.B 2,2,2,1,1,1,3,-1 ; 56
                DC.B 1,3,5,5,5,5,5,-1 ; 58
                DC.B 1,1,5,5,5,5,0,-1 ; 60
                DC.B 3,4,4,4,5,0,0,0 ; 62
                DC.B 1,1,3,3,5,5,5,-1 ; 64
                DC.B 1,1,1,3,5,5,0,-1 ; 66
                DC.B 1,1,1,1,5,0,0,-1 ; 68
                DC.B 1,0,0,0,0,0,0,0 ; 70
                DC.B 1,1,1,1,3,3,0,-1 ; 72
                DC.B 2,2,4,1,1,1,1,-1 ; 74
                DC.B 2,2,1,1,1,1,0,-1 ; 76
                DC.B 1,5,5,5,5,5,5,-1 ; 78
                DC.B 4,4,4,4,5,5,0,0 ; 80
                DC.B 4,4,4,5,5,0,0,0 ; 82
                DC.B 1,1,3,5,5,5,5,-1 ; 84
                DC.B 1,1,1,5,5,5,0,-1 ; 86
                DC.B 5,5,0,0,0,0,0,0 ; 88
                DC.B 1,1,1,3,3,5,5,-1 ; 90
                DC.B 3,3,5,0,0,0,0,0 ; 92
                DC.B 1,1,1,1,1,0,0,-1 ; 94
                DC.B 1,1,1,1,3,3,3,-1 ; 96
                DC.B 2,3,3,3,0,0,0,0 ; 98
                DC.B 2,2,1,1,1,1,3,-1 ; 100
                DC.B 2,2,2,1,1,1,1,-1 ; 102
                DC.B 1,1,5,5,5,5,5,-1 ; 104
                DC.B 3,4,4,4,5,5,0,0 ; 106
                DC.B 1,4,4,4,5,0,0,0 ; 108
                DC.B 1,1,1,3,5,5,5,-1 ; 110
                DC.B 1,1,1,1,5,5,0,-1 ; 112
                DC.B 1,5,0,0,0,0,0,0 ; 114
                DC.B 3,3,3,5,0,0,0,0 ; 116
                DC.B 1,3,3,0,0,0,0,0 ; 118
                DC.B 3,3,3,3,3,0,0,0 ; 120
                DC.B 2,2,2,5,0,0,0,0 ; 122
                DC.B 4,4,4,4,5,5,5,0 ; 124
                DC.B 4,4,4,5,5,5,0,0 ; 126
                DC.B 4,4,5,5,5,0,0,0 ; 128
                DC.B 1,1,1,5,5,5,5,-1 ; 130
                DC.B 5,5,5,0,0,0,0,0 ; 132
                DC.B 4,3,3,5,5,0,0,0 ; 134
                DC.B 3,3,5,5,0,0,0,0 ; 136
                DC.B 1,3,5,0,0,0,0,0 ; 138
                DC.B 1,1,0,0,0,0,0,0 ; 140
                DC.B 1,3,3,3,0,0,0,0 ; 142
                DC.B 3,3,3,3,3,3,0,0 ; 144
                DC.B 1,1,1,1,1,2,2,-1 ; 146
                DC.B 5,2,2,2,2,0,0,0 ; 148
                DC.B 1,4,4,4,4,5,5,0 ; 150
                DC.B 3,4,4,5,5,5,0,0 ; 152
                DC.B 1,4,4,5,5,0,0,0 ; 154
                DC.B 3,5,5,5,0,0,0,0 ; 156
                DC.B 1,5,5,0,0,0,0,0 ; 158
                DC.B 3,3,3,5,5,0,0,0 ; 160
                DC.B 1,3,3,5,0,0,0,0 ; 162
                DC.B 1,1,3,0,0,0,0,0 ; 164
                DC.B 1,3,3,3,3,0,0,0 ; 166
                DC.B 3,3,3,3,3,3,3,0 ; 168
                DC.B 2,3,3,3,3,3,3,0 ; 170
                DC.B 5,5,5,5,4,4,0,0 ; 172
                DC.B 4,5,5,5,5,0,0,0 ; 174
                DC.B 5,5,5,5,0,0,0,0 ; 176
                DC.B 3,3,4,5,5,5,0,0 ; 178
                DC.B 3,3,5,5,5,0,0,0 ; 180
                DC.B 1,3,5,5,0,0,0,0 ; 182
                DC.B 1,1,5,0,0,0,0,0 ; 184
                DC.B 1,3,3,3,5,0,0,0 ; 186
                DC.B 1,1,3,3,0,0,0,0 ; 188
                DC.B 1,3,3,3,3,3,0,0 ; 190
                DC.B 2,2,3,3,3,3,5,0 ; 192
                DC.B 2,2,2,3,3,3,5,0 ; 194
                DC.B 1,4,4,4,5,5,5,0 ; 196
                DC.B 3,4,5,5,5,5,0,0 ; 198
                DC.B 3,5,5,5,5,0,0,0 ; 200
                DC.B 1,5,5,5,0,0,0,0 ; 202
                DC.B 3,3,3,5,5,5,0,0 ; 204
                DC.B 1,3,3,5,5,0,0,0 ; 206
                DC.B 1,1,3,5,0,0,0,0 ; 208
                DC.B 1,1,1,0,0,0,0,0 ; 210
                DC.B 1,1,3,3,3,0,0,0 ; 212
                DC.B 1,3,3,3,3,3,3,0 ; 214
                DC.B 4,4,5,5,5,5,5,0 ; 216
                DC.B 4,5,5,5,5,5,0,0 ; 218
                DC.B 5,5,5,5,5,0,0,0 ; 220
                DC.B 3,3,4,5,5,5,5,0 ; 222
                DC.B 3,3,5,5,5,5,0,0 ; 224
                DC.B 1,3,5,5,5,0,0,0 ; 226
                DC.B 1,1,5,5,0,0,0,0 ; 228
                DC.B 1,3,3,3,5,5,0,0 ; 230
                DC.B 1,1,3,3,5,0,0,0 ; 232
                DC.B 1,1,1,3,0,0,0,0 ; 234
                DC.B 1,1,3,3,3,3,0,0 ; 236
                DC.B 1,2,2,3,3,3,5,0 ; 238
                DC.B 2,2,1,1,3,3,0,0 ; 240
                DC.B 1,4,4,5,5,5,5,0 ; 242
                DC.B 0,4,4,4,4,4,4,1 ; 244
                DC.B 1,5,5,5,5,0,0,0 ; 246
                DC.B 3,3,3,5,5,5,5,0 ; 248
                DC.B 1,1,3,4,5,5,0,0 ; 250
                DC.B 1,1,3,5,5,0,0,0 ; 252
                DC.B 1,1,1,5,0,0,0,0 ; 254



                ;ENDPART

; ---------- **** SYNCSCROLLING ENDE **** ------------------------------------



                ;>PART 'Tastatur-IRQ'
newkey:         move.w  D0,-(A7)             ; TastaturIRQ
                move.b  $fffffc00.w,D0
                btst    #7,D0
                beq.s   endkey
                move.b  $fffffc02.w,key
endkey:         move.w  (A7)+,D0
                rte
                ;ENDPART

                ;>PART 'Timer B'

timer_b:        rte

                ;ENDPART

;------------------------------------------------------------------------------
                DATA

screen_1:       DC.L 0          ; so weit oben damit PC-Relativer Zugriff
screen_2:       DC.L 0
screen_offset:  DC.L 0
screen_mem:     DC.L 0
color_stop:     DC.W 0          ; falls <>0 wird Farbscrolling angehalten
key:            DC.W 0

                ;>PART 'Text'


text_pos:       DC.L text

; maximal 20 Zeichen pro Zeile.
; -2 zentriert den Text (aber nur bei LÑngen <20 sonst Absturz!!!)
; -1 ist Endekennung
; INKL. SPALTE 41 IST MAXIMUM


                REPT 15         ; WEGEN WRAP
                DC.B " ",-2
                ENDR
text:
                DC.B " ",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "HI!",-2
                DC.B "THIS IS",-2
                DC.B "PUNISH YOUR MACHINE!"
                DC.B " ",-2
                DC.B "USE YOUR CURSORKEYS",-2
                DC.B "TO SELECT THE",-2
                DC.B "SCREENS AND PRESS",-2
                DC.B "SPACE TO LOAD THEM.",-2
                DC.B "PRESS HELP FOR AN",-2
                DC.B "ALTERNATIVE MENU!",-2
                DC.B " ",-2
                DC.B "NOW IT'S UP TO YOU",-2
                DC.B "TO DECIDE!",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "THIS IS THE",-2
                DC.B "MAINMENU OF THIS",-2
                DC.B "GODDAMNED PARTYDEMO",-2
                DC.B "FROM A CERTAIN",-2
                DC.B "PARTY CALLED",-2
                DC.B "I.C.C. 2",-2
                DC.B "IT WAS HELD FROM",-2
                DC.B "THE 1ST TO THE 4TH",-2
                DC.B "OF AUGUST 1991 NEAR",-2
                DC.B "STUTTGART  (GERMANY)"
                DC.B " ",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "GREETINGS GO TO:",-2
                DC.B "(IN A STRANGE ORDER)"
                DC.B " ",-2
                DC.B " ",-2
                DC.B "--------------------"
                DC.B "---- THE  UNION ----"
                DC.B "--------------------"
                DC.B " ",-2
                DC.B "-THE CAREBEARS-",-2
                DC.B "(ESPECIALLY TANIS",-2
                DC.B "FOR ALL THE GFX!)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-THE EXCEPTIONS-",-2
                DC.B "(ESPECIALLY DARYL",-2
                DC.B "AND -ME-)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-OVERLANDERS-",-2
                DC.B "(WELCOME TO OUR",-2
                DC.B "PLEASUREDOME!)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-LEVEL 16-",-2
                DC.B "(MANY THANKS FOR",-2
                DC.B "THE CARD!)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-TNT-CREW-",-2
                DC.B "(HI ALL)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-ELECTRA-",-2
                DC.B "(HI JESPER AND",-2
                DC.B "STEFAN, WE'RE",-2
                DC.B "REALLY HAPPY THAT",-2
                DC.B "IT NOW IS RELEASED)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-THE REPLICANTS-",-2
                DC.B "(ESPECIALLY SNAKE!)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-THE LOST BOYS-",-2
                DC.B "(CRIKEY WAS A REAL",-2
                DC.B "SCORCHER, ESPECIALLY"
                DC.B "THE FUNNY DICKFLEAS)"
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-UNLIMITED MATRICKS-"
                DC.B "(GREAT TUNE, CHRIS!)"
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-RIPPED OFF-",-2
                DC.B "(PREPARE TO DIE,",-2
                DC.B "WE'LL COME!!!)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-PHALANX-",-2
                DC.B "(HI BLACK)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-LEGACY-",-2
                DC.B "(YO FURY! ALL THE",-2
                DC.B "BEST FOR UNIVERSITY)"
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-SUPERIOR-",-2
                DC.B "(ESPECIALLY AXE AND",-2
                DC.B "JABBA, OUR GRANDPA)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-ST-CONNEXION-",-2
                DC.B "(YOU NUTTY FRENCHIES"
                DC.B "WE HAD TO REMOVE THE"
                DC.B "LOADER BECAUSE OF",-2
                DC.B "YOUR SCREEN (494KB!)"
                DC.B "BUT ANYWAY, NICE",-2
                DC.B "SCREEN AND NICE",-2
                DC.B "GUYS!)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-BBC-",-2
                DC.B "(HI THERE ANDY,",-2
                DC.B "HOPE TO SEE YOU",-2
                DC.B "IN ENGLAND)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-INNER CIRCLE-",-2
                DC.B "(ESPECIALLY E.I.,",-2
                DC.B "GIVE US MORE OF",-2
                DC.B "THESE HORNY HOT-",-2
                DC.B "BABES! BRILL TNTD!)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-LORD HACKBEAR-",-2
                DC.B "(HI TJORBORN, THANKS"
                DC.B "FOR ALL MAILS)"
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-GIGABYTE-CREW-",-2
                DC.B "(IT WAS NICE THAT",-2
                DC.B "YOU CAME ALTHOUGH",-2
                DC.B "IT WAS QUITE LATE!)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-THE RESPECTABLES-",-2
                DC.B "(DIE LAGE BESSERT",-2
                DC.B "SICH TAEGLICH, AUCH",-2
                DC.B "WENN'S NOCH RECHT",-2
                DC.B "NASS IST!)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-NEXT-",-2
                DC.B "(ESPECIALLY DBUG II,"
                DC.B "STWARS AND ZAE,",-2
                DC.B "SPREAD THIS DEMO!)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-OMEGA-",-2
                DC.B "(SOMETHING WENT",-2
                DC.B "WRONG WITH THE ICC2,"
                DC.B "WE'RE REALLY SORRY!)"
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-FLEXIBLE FRONT-",-2
                DC.B "(WE KNOW, STALIN IS",-2
                DC.B "DEAD, BUT WHAT ABOUT"
                DC.B "YOU, VILLE?)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-ALLIANCE-",-2
                DC.B "(BMT, TVI, NEWLINE,",-2
                DC.B "ACF, A SPECIAL HI!",-2
                DC.B "TO FORD PERFECT AND",-2
                DC.B "THE LAST SCHAMANE!)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-AENIGMATICA-",-2
                DC.B "(A BIG HI! TO",-2
                DC.B "THE NUTTY SNAKE!)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-GALTAN 6-",-2
                DC.B "(WE REALLY HOPE THAT"
                DC.B "THE THINGS ARE CLEAR"
                DC.B "NOW, ENS, DON'T USE "
                DC.B "OUR MUSICS WITHOUT",-2
                DC.B "CREDITING BIG ALEC!)"
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-ST-NEWS-",-2
                DC.B "(HI THERE RICHARD,",-2
                DC.B "HOPE YOU LIKE THIS",-2
                DC.B "DEMO AND OF COURSE",-2
                DC.B "THE -TWO- BOOTSEXS)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-SYNC-",-2
                DC.B "(WE HAD NO ADDRESS",-2
                DC.B "FROM YOU SO WE",-2
                DC.B "COULDN'T INVITE YOU",-2
                DC.B "TO THE ICC2, SORRY!)"
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-ANIMI DUX-",-2
                DC.B "(HI DIRE! IT WAS A",-2
                DC.B "PLEASURE HAVING YOU",-2
                DC.B "AT THE PARTY!)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-SCUM OF THE EARTH-",-2
                DC.B "(HI THERE IE!)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-FUTURE MINDS-",-2
                DC.B "(NICE SCREEN!)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-WHIZZCAT-",-2
                DC.B "(HI KARL-ANDERS,",-2
                DC.B "ALWAYS NICE MAILS!)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-HEMOROIDS-",-2
                DC.B "(HI SINK)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-2 LIVE CREW-",-2
                DC.B "(THANKS FOR THE",-2
                DC.B "INVITATION)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-SEWER SOFTWARE-",-2
                DC.B "(HI OZZIES)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-AVENGERS-",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-NAOS-",-2
                DC.B "(ESPECIALLY RIC)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-AWESOME-",-2
                DC.B "(NICE INTROS)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-TSUNOO-",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-ARMIN HIERSTETTER-",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-MYSTIK-",-2
                DC.B "(NICE SCREEN!",-2
                DC.B "HI THERE LTK)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-PAULO SIMOES-",-2
                DC.B "(ALWAYS NICE DEMOS",-2
                DC.B "FROM YOU)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-CY-",-2
                DC.B "(YOU'RE A NICE GUY,",-2
                DC.B "THANKS FOR ALL)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-THE BLACK CATS-",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-VEGETABLES-",-2
                DC.B "(HI THERE BANANA,",-2
                DC.B "YOU'RE A COOL MATE)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-POLTERGEISTS-",-2
                DC.B "(STRANGE SCREENS)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-KRUZ-",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-DBA-",-2
                DC.B "(GOOD NEWS SUPPLY!)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-TSB-",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-MCODER-",-2
                DC.B "(YOU'RE SURELY ONE",-2
                DC.B "OF THE BEST CODERS)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-NPG-",-2
                DC.B "(GOOD DCD'S!)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-ATG-",-2
                DC.B "(ARE YOU DEAD?)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-ETERNAL-",-2
                DC.B "(GOOD MUZAKS)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-MCS-",-2
                DC.B "(GREAT PACKER!)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-DYNAMIC DUO-",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-THE WATCHMEN-",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-FIREHAWKS-",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-FUNVISION-",-2
                DC.B "(NICE DEMO)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-EQUINOX-",-2
                DC.B "(BRILLIANT 3D-",-2
                DC.B "SCREEN!!!)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-CHAOS-",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "-POMPEY PIRATES-",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "SUB HUMANS IN TURKEY"
                DC.B " ",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "PERHAPS WE'VE FORGOT"
                DC.B "YOU, BUT WE DON'T",-2
                DC.B "MIND AT ALL....",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "IF YOU WANT TO GET",-2
                DC.B "IN TOUCH WITH US,",-2
                DC.B "WRITE TO THE",-2
                DC.B "FOLLOWING ADDRESSES:"
                DC.B " ",-2
                DC.B " ",-2
                DC.B "SLIME, NEW MODE,",-2
                DC.B "CHAOS INC, QUESTLORD"
                DC.B " ",-2
                DC.B "--------------------"
                DC.B "PLK 136681E",-2
                DC.B "7050 WAIBLINGEN",-2
                DC.B "WEST-GERMANY",-2
                DC.B "--------------------"
                DC.B " ",-2
                DC.B " ",-2
                DC.B "SAMMY JOE",-2
                DC.B "(PD-LIBRARY)",-2
                DC.B "--------------------"
                DC.B "MICHAEL SCHUESSLER",-2
                DC.B "SEESTRASSE 34 II",-2
                DC.B "7254 HEMMINGEN",-2
                DC.B "WEST-GERMANY",-2
                DC.B "--------------------"
                DC.B " ",-2
                DC.B " ",-2
                DC.B "BIG ALEC",-2
                DC.B "--------------------"
                DC.B "DELTA FORCE",-2
                DC.B "POSTLAGERND",-2
                DC.B "8034 GERMERING",-2
                DC.B "WEST-GERMANY",-2
                DC.B "--------------------"
                DC.B " ",-2
                DC.B " ",-2
                DC.B "FLIX AND RAY",-2
                DC.B "--------------------"
                DC.B "FLIX",-2
                DC.B "JAHNSTRASSE 51",-2
                DC.B "8130 STARNBERG",-2
                DC.B "WEST-GERMANY",-2
                DC.B "--------------------"
                DC.B " ",-2
                DC.B " ",-2
                DC.B "YOU CAN ALSO TRY TO",-2
                DC.B "CONTACT US ON I.R.C."
                DC.B " ",-2
                DC.B "JUST HAVE A LOOK IN",-2
                DC.B "SUITABLE CHANNELS",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "OR CALL OUR BBS:",-2
                DC.B "--------------------"
                DC.B "+49 (0)8151 78880",-2
                DC.B "--------------------"
                DC.B " ",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "BUT ONLY FOR LEGAL",-2
                DC.B "REASONS! WE WON'T",-2
                DC.B "ANSWER ANY LETTERS",-2
                DC.B "CONCERNING ANY",-2
                DC.B "ILLEGAL ACTIVITIES!!"
                DC.B " ",-2
                DC.B "AND DON'T FORGET TO",-2
                DC.B "ENCLOSE ENOUGH",-2
                DC.B "INTERNATIONAL REPLY",-2
                DC.B "COUPONS, OTHERWISE",-2
                DC.B "WE WON'T ANSWER, TOO"
                DC.B " ",-2
                DC.B "LETTERS WITH",-2
                DC.B "DONATIONS WILL GET",-2
                DC.B "VERY SPECIAL",-2
                DC.B "TREATMENT, OF COURSE"
                DC.B " ",-2
                DC.B " ",-2
                DC.B "SOURCECODES OF OUR",-2
                DC.B "SYNTAX TERROR DEMO",-2
                DC.B "AND THIS DEMO",-2
                DC.B "CAN BE OBTAINED AT",-2
                DC.B "A PRICE OF 15 MARKS "
                DC.B "PER SCREEN.",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "WE STILL HAVE AROUND"
                DC.B "25 PER CENT CPU-TIME"
                DC.B "LEFT IN THIS MENU,",-2
                DC.B "BUT WE HAVE:",-2
                DC.B "(A) NO MOTIVATION..."
                DC.B "(B) NO TIME........."
                DC.B "(C) NO IDEAS........"
                DC.B " ",-2
                DC.B "SO GO AHEAD AND MAKE"
                DC.B "MY DAY YOU BLOODY",-2
                DC.B "IUSEALLCLOCKCYCLES-",-2
                DC.B "OTHERWISEIHAVENO-",-2
                DC.B "ORGASM - CODER",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "LET'S WRAP DU DEPP",-2
                REPT 20
                DC.B " ",-2
                ENDR
                DC.B -1

                ;ENDPART

                ;>PART 'Text Konvertiertab'
;----------------------------- Tabelle zum Umkovertieren der Zeichen
; Sonderzeichen:
;
; $   Smiley
; []  Farben
; #   (C) 1990
; ~   Fuck you!
; >   Pfeil nach rechts
; <   Pfeil nach links
; {}  Syntax-Terror

contab:         DCB.B 33,26      ; 0-32
                DC.B 40,42,54,51,26,46,43,44,45,26,46,48,47,37,49 ; Sonder
                DC.B 27,28,29,30,31,32,33,34,35,36 ; 0-9
                DC.B 38,39,57,50,56,41,26 ; Sonder
                DC.B 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17
                DC.B 18,19,20,21,22,23,24,25 ; A-Z
                DC.B 52,49,53,26,26,43
                DC.B 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17
                DC.B 18,19,20,21,22,23,24,25 ; a-z
                DC.B 58,26,59,55 ; Sonder
                EVEN

                ;ENDPART


                ;>PART 'Roehrengrafik'
roehre:
                DC.W $f0f0,$0ff0,$0f,$00,$0f0f,$0ff0,$f000,$00

                ;ENDPART

                ;>PART 'Hidden-Keys'

; Hier stehen Scancodes des Passwortes fÅr Hiddenscreen.

hidden_point:   DC.L hidden_keys

hidden_keys:
; Passwort ist: HIDDENSCREENMAESSIG

                DC.B 35
                DC.B 23
                DC.B 32
                DC.B 32
                DC.B 18
                DC.B 49
                DC.B 31
                DC.B 46
                DC.B 19
                DC.B 18
                DC.B 18
                DC.B 49
                DC.B 50
                DC.B 30
                DC.B 18
                DC.B 31
                DC.B 31
                DC.B 23
                DC.B 34
                DC.B -1
                EVEN

                ;ENDPART

                ;>PART 'Sinustabelle'

sinus_pointer:  DC.L sinus_tab

sinus_tab:
                DC.W 64,65,66,67,68,69,70,71
                DC.W 72,74,75,76,77,78,79,80
                DC.W 81,82,83,84,85,86,87,89
                DC.W 90,91,92,93,94,95,96,96
                DC.W 97,98,99,100,101,102,103,104
                DC.W 105,105,106,107,108,109,110,110
                DC.W 111,112,113,113,114,115,115,116
                DC.W 117,117,118,118,119,119,120,121
                DC.W 121,122,122,122,123,123,124,124
                DC.W 124,125,125,125,126,126,126,126
                DC.W 127,127,127,127,127,127,127,127
                DC.W 127,127,127,127,127,127,127,127
                DC.W 127,127,127,127,127,126,126,126
                DC.W 126,125,125,125,124,124,124,123
                DC.W 123,122,122,122,121,121,120,119
                DC.W 119,118,118,117,117,116,115,115
                DC.W 114,113,113,112,111,110,110,109
                DC.W 108,107,106,105,105,104,103,102
                DC.W 101,100,99,98,97,96,96,95
                DC.W 94,93,92,91,90,89,87,86
                DC.W 85,84,83,82,81,80,79,78
                DC.W 77,76,75,74,72,71,70,69
                DC.W 68,67,66,65,64,62,61,60
                DC.W 59,58,57,56,55,53,52,51
                DC.W 50,49,48,47,46,45,44,43
                DC.W 42,41,40,38,37,36,35,34
                DC.W 33,32,31,31,30,29,28,27
                DC.W 26,25,24,23,22,22,21,20
                DC.W 19,18,17,17,16,15,14,14
                DC.W 13,12,12,11,10,10,9,9
                DC.W 8,8,7,6,6,5,5,5
                DC.W 4,4,3,3,3,2,2,2
                DC.W 1,1,1,1,0,0,0,0
                DC.W 0,0,0,0,0,0,0,0
                DC.W 0,0,0,0,0,0,0,0
                DC.W 0,1,1,1,1,2,2,2
                DC.W 3,3,3,4,4,5,5,5
                DC.W 6,6,7,8,8,9,9,10
                DC.W 10,11,12,12,13,14,14,15
                DC.W 16,17,17,18,19,20,21,22
                DC.W 22,23,24,25,26,27,28,29
                DC.W 30,31,31,32,33,34,35,36
                DC.W 37,38,40,41,42,43,44,45
                DC.W 46,47,48,49,50,51,52,53
                DC.W 55,56,57,58,59,60,61,62
                DC.W 63

                DC.W 64,66,68,70,72,75,77,79
                DC.W 81,83,85,87,90,92,94,96
                DC.W 97,99,101,103,105,106,108,110
                DC.W 111,113,114,115,117,118,119,120
                DC.W 121,122,123,124,124,125,126,126
                DC.W 127,127,127,127,127,127,127,127
                DC.W 127,127,127,126,126,125,124,124
                DC.W 123,122,121,120,119,118,117,115
                DC.W 114,113,111,110,108,106,105,103
                DC.W 101,99,97,96,94,92,90,87
                DC.W 85,83,81,79,77,75,72,70
                DC.W 68,66,64,61,59,57,55,52
                DC.W 50,48,46,44,42,40,37,35
                DC.W 33,31,30,28,26,24,22,21
                DC.W 19,17,16,14,13,12,10,9
                DC.W 8,7,6,5,4,3,3,2
                DC.W 1,1,0,0,0,0,0,0
                DC.W 0,0,0,0,0,1,1,2
                DC.W 3,3,4,5,6,7,8,9
                DC.W 10,12,13,14,16,17,19,21
                DC.W 22,24,26,28,30,31,33,35
                DC.W 37,40,42,44,46,48,50,52
                DC.W 55,57,59,61,63

                DC.W 64,67,70,74,77,80,83,86
                DC.W 90,93,96,98,101,104,106,109
                DC.W 111,113,115,117,119,121,122,123
                DC.W 124,125,126,127,127,127,127,127
                DC.W 127,127,126,125,124,123,122,121
                DC.W 119,117,115,113,111,109,106,104
                DC.W 101,98,96,93,90,86,83,80
                DC.W 77,74,70,67,64,60,57,53
                DC.W 50,47,44,41,37,34,31,29
                DC.W 26,23,21,18,16,14,12,10
                DC.W 8,6,5,4,3,2,1,0
                DC.W 0,0,0,0,0,0,1,2
                DC.W 3,4,5,6,8,10,12,14
                DC.W 16,18,21,23,26,29,31,34
                DC.W 37,41,44,47,50,53,57,60
                DC.W 63

                DC.W 64,68,72,77,81,85,90,94
                DC.W 97,101,105,108,111,114,117,119
                DC.W 121,123,124,126,127,127,127,127
                DC.W 127,127,126,124,123,121,119,117
                DC.W 114,111,108,105,101,97,94,90
                DC.W 85,81,77,72,68,64,59,55
                DC.W 50,46,42,37,33,30,26,22
                DC.W 19,16,13,10,8,6,4,3
                DC.W 1,0,0,0,0,0,0,1
                DC.W 3,4,6,8,10,13,16,19
                DC.W 22,26,30,33,37,42,46,50
                DC.W 55,59,63

                DC.W 64,70,77,83,90,96,101,106
                DC.W 111,115,119,122,124,126,127,127
                DC.W 127,126,124,122,119,115,111,106
                DC.W 101,96,90,83,77,70,64,57
                DC.W 50,44,37,31,26,21,16,12
                DC.W 8,5,3,1,0,0,0,1
                DC.W 3,5,8,12,16,21,26,31
                DC.W 37,44,50,57,63

                DC.W 64,72,81,90,97,105,111,117
                DC.W 121,124,127,127,127,126,123,119
                DC.W 114,108,101,94,85,77,68,59
                DC.W 50,42,33,26,19,13,8,4
                DC.W 1,0,0,0,3,6,10,16
                DC.W 22,30,37,46,55,63

                DC.W 64,74,83,93,101,109,115,121
                DC.W 124,127,127,127,124,121,115,109
                DC.W 101,93,83,74,64,53,44,34
                DC.W 26,18,12,6,3,0,0,0
                DC.W 3,6,12,18,26,34,44,53
                DC.W 63

                DC.W 64,75,85,96,105,113,119,124
                DC.W 127,127,127,124,119,113,105,96
                DC.W 85,75,64,52,42,31,22,14
                DC.W 8,3,0,0,0,3,8,14
                DC.W 22,31,42,52,63


                DC.W -99
                ;ENDPART

                ;>PART '8*8 Font'
chars8:
; 8*8 Font, Screenformat, Space erstes Zeichen, 2 Zeilen

                DC.W $30,$3800,$aec6,$ae60,$1c70,$1000,$00,$06
                DC.W $fe38,$fefe,$eefe,$fefe,$fefe,$00,$1000,$10fe
                DC.W $fefe,$fefe,$fcfe,$fefe,$30,$5400,$aa8c,$a440
                DC.W $1830,$1818,$00,$0e,$ee78,$eeee,$eeee,$eeee
                DC.W $eeee,$6000,$3000,$18c6,$feee,$eeee,$eeee,$eeee
                DC.W $30,$d606,$aa18,$a400,$1830,$1c18,$00,$1c
                DC.W $ee38,$0e1c,$eee0,$e00e,$eeee,$6060,$7e7c,$fc06
                DC.W $feee,$eee0,$eee0,$e0e0,$30,$fe0c,$ea30,$e400
                DC.W $1830,$1e7e,$7c,$38,$ee38,$7e38,$fefc,$fc0e
                DC.W $7cfe,$60,$fe00,$fe1e,$feee,$fce0,$eef8,$f8ee
                DC.W $30,$bad8,$2a60,$a400,$1830,$1818,$00,$70
                DC.W $ee38,$e01c,$0e0e,$ee0e,$ee0e,$6000,$7e7c,$fc18
                DC.W $fefe,$eee0,$eee0,$e0ee,$00,$4470,$aac2,$a400
                DC.W $1830,$1018,$6000,$60e0,$ee38,$eeee,$0eee,$ee0e
                DC.W $eeee,$6060,$3000,$1800,$feee,$eeee,$eeee,$e0ee
                DC.W $30,$3820,$ee86,$ae00,$1c70,$fe00,$4000,$60c0
                DC.W $fe7c,$fefe,$0efe,$fe0e,$fefe,$40,$1000,$1018
                DC.W $feee,$fefe,$fefe,$e0fe,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $ee7c,$1eee,$e0c6,$fefe,$fefe,$fefe,$feee,$eeee
                DC.W $eeee,$fe00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$ee38,$0eee,$e0ee,$eeee
                DC.W $eeee,$eeee,$38ee,$eeee,$eeee,$ee00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $ee38,$0eee,$e0fe,$eeee,$eeee,$eee0,$38ee,$eeee
                DC.W $eeee,$1c00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$fe38,$0efc,$e0fe,$eeee
                DC.W $feee,$fcfe,$38ee,$eefe,$7cfe,$3800,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $ee38,$0eee,$e0ee,$eeee,$e0ee,$ee0e,$38ee,$fcfe
                DC.W $ee0e,$7000,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$ee38,$eeee,$eeee,$eeee
                DC.W $e0fe,$eeee,$38ee,$f8ee,$eeee,$ee00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $ee7c,$feee,$feee,$eefe,$e0fe,$eefe,$38fe,$f0c6
                DC.W $eefe,$fe00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                ;ENDPART

                ;>PART '2nd Menutext'

menu2_text:
; komplett auffÅllen 40*25
; 61 ist maximale Spalte!

;               DC.B "****************************************"

                DC.B " THE SECOND MAINMENU FOR FASTER ACCESS: "
                DC.B "PRESS THE FOLLOWING KEYS FOR THE SCREENS"
                DC.B "                                        "
                DC.B "----------------------------------------"
                DC.B "F1 - SICKEST SO FAR                 (DF)"
                DC.B "F2 - COAST                         (BMT)"
                DC.B "F3 - COPPERKAAAHBAAAHNAAAH          (DF)"
                DC.B "F4 - ISHIDO, WAY OF THE STONES      (CY)"
                DC.B "F5 - WHEN COLOURS ARE GOING BANG... (DF)"
                DC.B "F6 - LEIF RULLAR               (ELECTRA)"
                DC.B "F7 - THERE ARE MANY SHEEP(S)....   (OVR)"
                DC.B "F8 - LET'S DO THE TWIST AGAIN   (ST-CNX)"
                DC.B "F9 - THE CUBE                   (LEGACY)"
                DC.B "F10- THE BEST PART OF THE CREATION  (DF)"
                DC.B "1  - FROM SPACE TO LEUTENBACH     (NAOS)"
                DC.B "2  - I.C.C. 2 SCREEN                (FM)"
                DC.B "3  - THE MAGIC RASTERS          (MYSTIC)"
                DC.B "4  - TWENTYFOURMINUTE SCREEN      (SOTE)"
                DC.B "5  - RETURN OF MEDUSA DEMO          (DF)"
                DC.B "----------------------------------------"
                DC.B "                                        "
                DC.B "      COPYRIGHT NOVEMBER 1991 BY        "
                DC.B "             DELTA FORCE                "
                DC.B "                 OF                     "
                DC.B "              THE UNION                 "
                DC.B 0,0

                EVEN

                ;ENDPART

                ;>PART 'Screen-Liste'
screen_numbers:
; Liste mit Nummern, die den eigentlichen Screenzahlen entsprechen
                DC.B 0          ; 0-4 = Dummy
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 5          ; Big Alec
                DC.B 6          ; BMT
                DC.B 7          ; Copper
                DC.B 8          ; Ishido
                DC.B 10         ; Megarast
                DC.B 11         ; Electra
                DC.B 12         ; OVR
                DC.B 13         ; ST-Cnx
                DC.B 15         ; Legacy
                DC.B 18         ; Flix
                DC.B 16         ; Naos
                DC.B 19         ; FM
                DC.B 14         ; Mystic
                DC.B 17         ; SOTE
                DC.B 20         ; ROM
                DC.B 21
                DC.B 22         ; Hiddenscreen
                EVEN

                ;ENDPART

                ;>PART 'Tastaturtabelle'
key_tab:
; mîgliche Tasten im zweiten MenÅ. Muû ergÑnzt werden
                DC.B $3b,$3c,$3d,$3e,$3f,$40,$41,$42,$43,$44
                DC.B $02,$03,$04,$05,$06
                DC.B -1
                EVEN

                ;ENDPART

                ;>PART 'Colortab'

col_pointer:    DC.L col_tab


old_col_tab:
; ste-Colors (mÅssen noch umgerechnet werden)
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

                DS.W 80

col             SET $0111

                REPT 15
                DC.W col
col             SET col+$0111
                ENDR

                REPT 15
col             SET col-$0111
                DC.W col
                ENDR

                DS.W 40

col             SET $0100

                REPT 15
                DC.W col
col             SET col+$0100
                ENDR

                REPT 15
col             SET col-$0100
                DC.W col
                ENDR

                DS.W 40

col             SET $0110

                REPT 15
                DC.W col
col             SET col+$0110
                ENDR

                REPT 15
col             SET col-$0110
                DC.W col
                ENDR


                DS.W 40


col             SET $01

                REPT 15
                DC.W col
col             SET col+$01
                ENDR

                REPT 15
col             SET col-$01
                DC.W col
                ENDR

                DS.W 40

col             SET $10

                REPT 15
                DC.W col
col             SET col+$10
                ENDR

                REPT 15
col             SET col-$10
                DC.W col
                ENDR

                DS.W 40

col             SET $11

                REPT 15
                DC.W col
col             SET col+$11
                ENDR

                REPT 15
col             SET col-$11
                DC.W col
                ENDR

                DS.W 40

end_ste_colors:

                DC.W $0101,$0202,$0303,$0404,$0505,$0606,$0707

                INCBIN 'HBL.PAL',388


end_colors:


anzcolors       EQU (end_colors-old_col_tab)/2

                ;ENDPART

                ;>PART 'Font'

font:
; im Screenformat abgelegt 16*16 (3 Planes)
                INCBIN 'FONT16.IMG'

fontmask:
                DC.W $0fe0,$ffe0,$0ffe,$ffe0,$fffe,$fffe,$0ffe,$fc7e
                DC.W $7ffe,$7e,$fc7e,$fc00,$f01e,$f07e,$0fe0,$ffe0
                DC.W $0fe0,$ffe0,$0ffe,$7ffe,$3ff8,$fff8,$3ffe,$fff8
                DC.W $fffe,$fffe,$3ffe,$fc7e,$7ffe,$7e,$fcfe,$fc00
                DC.W $f83e,$f87e,$3ff8,$fff8,$3ff8,$fff8,$3ffe,$7ffe
                DC.W $7ffc,$fffc,$7ffe,$fffc,$fffe,$fffe,$7ffe,$fc7e
                DC.W $7ffe,$7e,$fdfe,$fc00,$fc7e,$fc7e,$7ffc,$fffc
                DC.W $7ffc,$fffc,$7ffe,$7ffe,$7ffc,$fffc,$7ffe,$fffc
                DC.W $fffe,$fffe,$7ffe,$fc7e,$7ffe,$7e,$fffc,$fc00
                DC.W $fefe,$fe7e,$7ffc,$fffc,$7ffc,$fffc,$7ffe,$7ffe
                DC.W $fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fc7e
                DC.W $7ffe,$7e,$fff8,$fc00,$fffe,$ff7e,$fffe,$fffe
                DC.W $fffe,$fffe,$fffe,$7ffe,$fffe,$fffe,$fffe,$fffe
                DC.W $fffe,$fffe,$fffc,$fffe,$7ffe,$7e,$fff0,$fc00
                DC.W $fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$ffe0,$7ffe
                DC.W $fc7e,$fffe,$fc00,$fc7e,$ffe0,$ffe0,$fffe,$fffe
                DC.W $07e0,$7e,$ffe0,$fc00,$fffe,$fffe,$fc7e,$fffe
                DC.W $fc7e,$fffe,$fff8,$07e0,$fffe,$fffc,$fc00,$fc7e
                DC.W $ffe0,$ffe0,$fffe,$fffe,$07e0,$fc7e,$ffc0,$fc00
                DC.W $fffe,$fffe,$fc7e,$fffc,$fc7e,$fffc,$7ffc,$07e0
                DC.W $fffe,$fffc,$fc00,$fc7e,$ffe0,$ffe0,$fffe,$fffe
                DC.W $07e0,$fc7e,$ffc0,$fc00,$fffe,$fffe,$fc7e,$fffc
                DC.W $fc7e,$fffc,$7ffc,$07e0,$fffe,$fffe,$fc00,$fc7e
                DC.W $ffe0,$ffe0,$fffe,$fffe,$07e0,$fc7e,$ffe0,$fc00
                DC.W $fffe,$fffe,$fc7e,$fff8,$fc7e,$fff8,$3ffe,$07e0
                DC.W $fffe,$fffe,$fffe,$fffe,$fffe,$ffe0,$fffe,$fffe
                DC.W $7ffe,$fffe,$fff0,$fffe,$fd7e,$fdfe,$fffe,$ffe0
                DC.W $fffe,$fff0,$0ffe,$07e0,$fffe,$fffe,$fffe,$fffe
                DC.W $fffe,$fc00,$fffe,$fc7e,$7ffe,$fffe,$fff8,$fffe
                DC.W $fc7e,$fcfe,$fffe,$fc00,$fffe,$fff8,$fffe,$07e0
                DC.W $fffe,$fffc,$7ffe,$fffc,$fffe,$fc00,$7ffe,$fc7e
                DC.W $7ffe,$7ffc,$fffc,$fffe,$fc7e,$fc7e,$7ffc,$fc00
                DC.W $7ffe,$fdfc,$fffc,$07e0,$fc7e,$fffc,$7ffe,$fffc
                DC.W $fffe,$fc00,$7ffe,$fc7e,$7ffe,$7ffc,$fdfe,$fffe
                DC.W $fc7e,$fc7e,$7ffc,$fc00,$7ffe,$fcfe,$fffc,$07e0
                DC.W $fc7e,$fff8,$3ffe,$fff8,$fffe,$fc00,$3ffe,$fc7e
                DC.W $7ffe,$3ff8,$fcfe,$fffe,$fc7e,$fc7e,$3ff8,$fc00
                DC.W $3ffe,$fc7e,$fff8,$07e0,$fc7e,$ffe0,$0ffe,$ffe0
                DC.W $fffe,$fc00,$0ffe,$fc7e,$7ffe,$0fe0,$fc7e,$fffe
                DC.W $fc7e,$fc7e,$0fe0,$fc00,$0ffe,$fc3e,$ffe0,$07e0
                DC.W $fc7e,$fc7e,$fc7e,$f01e,$7e7e,$fffe,$00,$0fe0
                DC.W $3f00,$ffe0,$ffe0,$fc7e,$fffe,$0ffc,$ffe0,$0fe0
                DC.W $0fe0,$00,$00,$00,$fc7e,$fc7e,$fc7e,$f83e
                DC.W $7e7e,$fffe,$00,$3ff8,$3fc0,$fff8,$fff8,$fc7e
                DC.W $fffe,$3ffc,$fff8,$3ff8,$3ff8,$00,$00,$00
                DC.W $fc7e,$fc7e,$fc7e,$fc7e,$7e7e,$fffe,$00,$7ffc
                DC.W $3fe0,$fffc,$fffc,$fc7e,$fffe,$7ffc,$fffc,$7ffc
                DC.W $7ffc,$00,$3c00,$00,$fc7e,$fc7e,$fc7e,$fefe
                DC.W $7e7e,$fffe,$00,$7ffc,$3fe0,$fffc,$fffc,$fc7e
                DC.W $fffe,$7ffc,$fffc,$7ffc,$7ffc,$00,$7e00,$00
                DC.W $fc7e,$fc7e,$fc7e,$7ffc,$7e7e,$fffe,$00,$fffe
                DC.W $3ff0,$fffe,$fffe,$fc7e,$fffe,$fffc,$fffe,$fffe
                DC.W $fffe,$00,$7e00,$0f00,$fc7e,$fc7e,$fd7e,$3ff8
                DC.W $7ffe,$fffc,$00,$fffe,$3ff0,$0ffe,$fffe,$fffe
                DC.W $ffe0,$ffe0,$fffe,$fffe,$fffe,$00,$7e00,$1f80
                DC.W $fc7e,$fc7e,$fffe,$1ff0,$7ffe,$03f8,$00,$fcfe
                DC.W $03f0,$3ffe,$0ffe,$fffe,$fff8,$fff8,$7e,$fffe
                DC.W $fffe,$00,$7e00,$1f80,$fc7e,$fc7e,$fffe,$0fe0
                DC.W $3ffc,$07f0,$00,$fdfe,$03f0,$7ffc,$0ffc,$7ffe
                DC.W $fffc,$fffc,$7e,$7ffc,$7ffe,$00,$3c00,$1f80
                DC.W $fc7e,$fc7e,$fffe,$0fe0,$3ffc,$0fe0,$00,$ff7e
                DC.W $03f0,$7ffc,$0ffc,$7ffe,$fffc,$fffc,$7e,$7ffc
                DC.W $7ffe,$00,$00,$1f80,$fc7e,$fc7e,$fffe,$1ff0
                DC.W $1ff8,$1fc0,$00,$fe7e,$03f0,$fff8,$0ffe,$3ffe
                DC.W $fffe,$fffe,$7e,$fffe,$3ffe,$3e00,$3c00,$1f80
                DC.W $fffe,$fffe,$fffe,$3ff8,$07e0,$3ffe,$00,$fffe
                DC.W $03f0,$ffe0,$fffe,$0ffe,$7ffe,$fffe,$7e,$fffe
                DC.W $0ffe,$7f00,$7e00,$1f80,$fffe,$7ffc,$fffe,$7ffc
                DC.W $07e0,$7ffe,$00,$fffe,$03f0,$fffe,$fffe,$7e
                DC.W $fffe,$fffe,$7e,$fffe,$7ffe,$7f00,$7e00,$1f80
                DC.W $7ffc,$3ff8,$fefe,$fefe,$07e0,$fffe,$00,$7ffc
                DC.W $03f0,$fffe,$fffc,$7e,$fffc,$7ffc,$7e,$7ffc
                DC.W $7ffc,$7f00,$7e00,$3f80,$7ffc,$1ff0,$fc7e,$fc7e
                DC.W $07e0,$fffe,$00,$7ffc,$03f0,$fffe,$fffc,$7e
                DC.W $fffc,$7ffc,$7e,$7ffc,$7ffc,$7f00,$7e00,$7f00
                DC.W $3ff8,$0fe0,$f83e,$f83e,$07e0,$fffe,$00,$3ff8
                DC.W $03f0,$fffe,$fff8,$7e,$fff8,$3ff8,$7e,$3ff8
                DC.W $7ff8,$7f00,$3c00,$7e00,$0fe0,$07c0,$f01e,$f01e
                DC.W $07e0,$fffe,$00,$0fe0,$03f0,$fffe,$ffe0,$7e
                DC.W $ffe0,$0fe0,$7e,$0fe0,$7fe0,$3e00,$00,$7c00
                DC.W $0f80,$7fe0,$3ffc,$3fc0,$fc,$3f00,$0100,$00
                DC.W $00,$fc,$07c0,$00,$00,$00,$03e0,$00
                DC.W $00,$00,$00,$00,$1fc0,$7ff8,$3ffc,$3fc0
                DC.W $03fc,$3fc0,$0380,$00,$00,$01fc,$07c0,$0fe0
                DC.W $7bde,$f7bc,$0410,$eaea,$00,$00,$0eaa,$eea0
                DC.W $1fc0,$7ffc,$3ffc,$3fc0,$07fc,$3fe0,$07c0,$00
                DC.W $00,$01fc,$07c0,$3ff8,$7bde,$f7bc,$05d0,$8a8a
                DC.W $00,$00,$08ae,$eea0,$1fc0,$7ffc,$3ffc,$3fc0
                DC.W $07fc,$3fe0,$0fe0,$00,$00,$03f8,$07c0,$7ffc
                DC.W $7bde,$f7bc,$0510,$8a8c,$40,$0400,$0eee,$4a40
                DC.W $1fc0,$7ffe,$3ffc,$3fc0,$0ffc,$3ff0,$1ff0,$00
                DC.W $00,$03f8,$07c0,$7ffc,$7bde,$f7bc,$05d0,$ca8e
                DC.W $60,$0c00,$022e,$4ee0,$1fc0,$7ffe,$7ffc,$1fc0
                DC.W $0ffc,$3ff0,$3ff8,$3ffc,$00,$07f0,$07c0,$fbbe
                DC.W $00,$00,$0410,$8eea,$70,$1c00,$0eea,$4aa0
                DC.W $1fc0,$03fe,$7ff8,$1f80,$0fc0,$03f0,$7ffc,$3ffc
                DC.W $00,$07f0,$07c0,$fffe,$7bde,$f7bc,$03e0,$8eea
                DC.W $fff8,$3ffe,$0eea,$4aa0,$1fc0,$07fc,$7df0,$3f00
                DC.W $0fc0,$03f0,$07c0,$3ffc,$00,$0fe0,$07c0,$fffe
                DC.W $7bde,$f7bc,$00,$00,$fffc,$7ffe,$00,$00
                DC.W $1fc0,$07fc,$00,$3e00,$0fc0,$03f0,$07c0,$3ffc
                DC.W $0fc0,$0fe0,$07c0,$fffe,$7bde,$f7bc,$2eee,$5752
                DC.W $fffe,$fffe,$0eee,$eee0,$0f80,$07f8,$00,$3c00
                DC.W $0fc0,$03f0,$07c0,$3ffc,$1fc0,$1fc0,$7ffc,$fffe
                DC.W $7bde,$f7bc,$6aaa,$5552,$fffc,$7ffe,$0e8a,$aaa0
                DC.W $1fc0,$03e0,$00,$00,$0ffc,$3ff0,$07c0,$3ffc
                DC.W $1fc0,$1fc0,$3ff8,$fffe,$00,$00,$2eea,$5552
                DC.W $fff8,$3ffe,$04ce,$eae0,$1fc0,$07e0,$00,$00
                DC.W $0ffc,$3ff0,$07c0,$00,$1fc0,$3f80,$1ff0,$7ffc
                DC.W $7bde,$f7bc,$222a,$7552,$70,$1c00,$048c,$cac0
                DC.W $1fc0,$07e0,$00,$00,$07fc,$3fe0,$07c0,$00
                DC.W $3f80,$3f80,$0fe0,$7ffc,$7bde,$f7bc,$2eee,$2770
                DC.W $60,$0c00,$04ea,$aea0,$1fc0,$07e0,$00,$00
                DC.W $07fc,$3fe0,$07c0,$00,$7f00,$7f00,$07c0,$3ff8
                DC.W $7bde,$f7bc,$2eee,$2772,$40,$0400,$04ea,$aea0
                DC.W $1fc0,$07e0,$00,$00,$03fc,$3fc0,$07c0,$00
                DC.W $7e00,$7f00,$0380,$0fe0,$7bde,$f7bc,$00,$00
                DC.W $00,$00,$00,$00,$0f80,$03c0,$00,$00
                DC.W $fc,$3f00,$07c0,$00,$7c00,$7e00,$0100,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00


                ;ENDPART

                ;>PART 'Bilder'
; Einplanebilder (320*200) fÅr MainmenÅ

bild_pointer:   DC.L mono_pictures

mono_pictures:
                INCBIN 'TITLE.IMG'

                INCBIN 'ALEC.IMG'

                INCBIN 'BMT.IMG'

                INCBIN 'COPPER.IMG'

                INCBIN 'ISHIDO.IMG'

                INCBIN 'MEGARAST.IMG'

                INCBIN 'ELECTRA.IMG'

                INCBIN 'OVR.IMG'

                INCBIN 'STCNX.IMG'

                INCBIN 'LEGACY.IMG'

                INCBIN 'FLIX.IMG'

                INCBIN 'NAOS.IMG'

                INCBIN 'FUTURE.IMG'

                INCBIN 'MYSTIC.IMG'

                INCBIN 'SOTE.IMG'

                INCBIN 'ROM.IMG'

                ;ENDPART

music:		INCBIN 'PARTY2.MUS'
		EVEN

;------------------------------------------------------------------------------
		SECTION BSS
bss_start:      

                ;>PART 'Saveregs' ; dort wird alles hingerettet (MFP, etc.)
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
oldhbl:         DS.L 1
oldtimerb:      DS.L 1
oldstack:       DS.L 1
oldpalette:     DS.L 8
oldscreen:      DS.W 1
vsync_count:    DS.L 1
old_sr:         DS.W 1
                ;ENDPART

scroll_up_point:DS.L 20         ; Pointer fÅr vertikalen Scroller

                ;>PART 'Farbtabellen'

col_tab:        DS.W anzcolors*3 ; hier kommen Farben rein
col_tab_ende:   DS.W anzcolors*3
col_tab2:       DS.L 200        ; Hier kommen die Farben fÅr die Bilder rein
                ;ENDPART

font_buffer:
                DS.B 16*4*2*20*3 ; Hier kommt Font und Maske rein


roehre_preshifted:
                DS.B 32*16      ; 32 mal geshiftet

                ;>PART 'Stack'
                DS.B 512        ; 512 Bytes Stack
stack:
                ;ENDPART

                ;>PART 'Screens'
                DS.B 256        ; wegen unteren 8 Bits des Screens

screen_base:    DS.B 36864*2    ; Platz fÅr 2 Screens (mit oberem Rand auf)
                ;ENDPART

bss_ende:       END
