
**** PYM-INTRO BY NEW MODE OF DELTA FORCE

;!!!! THIS SOURCECODE IS COPYRIGHTED SOFTWARE !!!!


disk_version    EQU 0
; 0 = Entwicklerversion/Festplatte
; 1 = Diskettenversion

                IFEQ disk_version
                OPT X+          ; Erweiterte Symboltable anschalten
                ELSE
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
                ;PART 'BSS lîschen'
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

                bsr     preshift_logo

                bsr     conv_sinus_tab

                bsr     convert_text

                bsr     init_sync_scrolling

                moveq   #1,D0
                jsr     music

                movem.l palette(PC),D0-D7
                movem.l D0-D7,$ffff8240.w

                move.l  #vbl,$70.w


main_loop:
; Haupt-Schleife, erledigt alles

                ;PART 'Haupt-Schleife'

                bsr     do_colors

                bsr     vsync

                bsr     build_text_screen    ; Text auf Screen aufbauen


                clr.w   sinus_finished       ; Reindobbsen-Flag
                move.l  #rein_huepf_rout,what_routine+2
wait_for_dobbs:
                tst.w   end_flag             ; Space gedrÅckt?
                bne     ende

                bsr     vsync

                tst.w   sinus_finished
                beq.s   wait_for_dobbs


                clr.w   counter
wait_4_seconds:
                bsr     vsync
                tst.w   end_flag
                bne     ende
                addq.w  #1,counter
                cmpi.w  #100,counter
                bne.s   wait_4_seconds

                clr.w   sinus_finished       ; Reindobbsen-Flag
                move.l  #raus_schieb_rout,what_routine+2
wait_for_dobbs2:
                tst.w   end_flag             ; Space gedrÅckt?
                bne     ende

                bsr     vsync

                tst.w   sinus_finished
                beq.s   wait_for_dobbs2

                clr.w   counter
wait_4_seconds2:
                bsr     vsync
                tst.w   end_flag
                bne     ende
                addq.w  #1,counter
                cmpi.w  #50,counter
                bne.s   wait_4_seconds2

                move.l  #nothing,what_routine+2 ; auf unteren Teil gehen
                bsr     vsync

                bsr     do_colors

                bsr     clear_text_buffer
                tst.w   end_flag
                bne     ende

                bsr     build_text_buffer
                tst.w   end_flag
                bne     ende

                bsr     create_scroll_help_buff

                bsr     preshift8            ; Buffer vorshiften
                tst.w   end_flag
                bne     ende

                bsr     copy_buffer_on_screen ; Buffer auf oberen Teil kopieren
                tst.w   end_flag
                bne     ende

                move.l  #scroll_buffer,scroll_pointer1
                move.l  #scroll_buffer+16000,scroll_pointer2

                clr.w   scroll_delay
                clr.w   scroll_counter
                move.l  #scroll_text_rein,what_routine+2

wait_for_scroller:
                tst.w   end_flag
                bne     ende
                bsr     vsync
                addq.w  #1,scroll_counter
                cmpi.w  #40,scroll_counter
                bne.s   wait_for_scroller

                move.l  #nothing2,what_routine+2 ; auf oberen Teil gehen

                clr.w   counter
wait_4_seconds3:
                bsr     vsync
                tst.w   end_flag
                bne     ende
                addq.w  #1,counter
                cmpi.w  #100,counter
                bne.s   wait_4_seconds3


                bsr     vsync

                movea.l real_screen_1,A0
                movea.l real_screen_2,A1
                adda.l  screen_offset(PC),A0
                adda.l  screen_offset(PC),A1
                movea.l A0,A2
                lea     32000(A0),A0
                lea     32000(A1),A1
                move.w  #7999,D0
clr_scr:        move.l  (A2),(A0)+           ; Screens umkopieren
                move.l  (A2)+,(A1)+
                dbra    D0,clr_scr

                movea.l real_screen_2,A0
                adda.l  screen_offset(PC),A0
                lea     32000(A0),A0
                bsr     preshift8_2

                tst.w   end_flag
                bne     ende

                movea.l real_screen_2,A0     ; letzte Spalte lîschen
                adda.l  screen_offset(PC),A0
                lea     32000+153(A0),A0
                move.w  #199,D0
clr_last_line:  clr.b   (A0)
                clr.b   2(A0)
                clr.b   4(A0)
                clr.b   6(A0)
                lea     160(A0),A0
                dbra    D0,clr_last_line

                bsr     vsync

                move.l  real_screen_1,D0
wait_for_s2:    cmp.l   screen_1(PC),D0      ; auf Screen 2 warten
                bne.s   wait_for_s2

                move.l  #nothing,what_routine+2
                bsr     vsync

                clr.w   scroll_delay
                clr.w   scroll_counter
                move.l  #scroll_screen_out,what_routine+2
wait_for_scroller2:
                tst.w   end_flag
                bne     ende
                bsr     vsync
                addq.w  #1,scroll_counter
                cmpi.w  #40,scroll_counter
                bne.s   wait_for_scroller2

                movea.l real_screen_1,A0
                movea.l real_screen_2,A1
                adda.l  screen_offset(PC),A0
                adda.l  screen_offset(PC),A1
                move.w  #(200*40)-1,D0
cl:             clr.l   (A0)+
                clr.l   (A1)+
                dbra    D0,cl

                bsr     vsync
                move.l  #nothing2,what_routine+2 ; auf obere HÑlfte
                bsr     vsync

                movea.l real_screen_1,A0
                movea.l real_screen_2,A1
                adda.l  screen_offset(PC),A0
                adda.l  screen_offset(PC),A1
                lea     32000(A0),A0
                lea     32000(A1),A1
                move.w  #(229*40)-1,D0
cl2:            clr.l   (A0)+
                clr.l   (A1)+
                dbra    D0,cl2

                bsr     vsync
                move.l  #nothing,what_routine+2 ; auf untere HÑlfte gehen

                clr.w   counter
wait_4_seconds4:
                bsr     vsync
                tst.w   end_flag
                bne     ende
                addq.w  #1,counter
                cmpi.w  #50,counter
                bne.s   wait_4_seconds4

                bra     main_loop

                ;ENDPART

ende:
                ;PART 'Quit-Programm' ; hier wird verlassen

                moveq   #0,D0
                jsr     music+8

                bsr     restore_all          ; alles zurÅcksetzen

                movea.l oldstack,A7          ; alten Stack setzen
                move    old_sr,SR
                IFEQ disk_version
                rts
                ELSE
                moveq   #0,D0                ; bei Diskettenversion so verlassen
                jmp     $0500.w
                ENDC
                ;ENDPART

;-----------------------------------------------------------------------------
                ;PART 'Install'  ; alles installieren (MFP,...)

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
                movea.l D0,A0
                move.l  D0,real_screen_1
                add.l   #29*160+2*201*160,D0
                move.l  D0,screen_2
                move.l  D0,real_screen_2
                movea.l D0,A1

                move.w  #(200*40)-1,D0       ; beide Screens lîschen
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
                clr.b   $ffff8260.w          ; Lowres


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

                ;PART 'SendIKBD'
send_ikbd:
; sendet Byte aus d0 an IKBD
                lea     $fffffc00.w,A0
waitkeyready:   btst    #1,(A0)
                beq.s   waitkeyready
                move.b  D0,2(A0)
                rts

                ;ENDPART

                ;PART 'Vsync'
vsync:          lea     vsync_count,A0
                move.l  (A0),D0
wait_strahl:    cmp.l   (A0),D0
                beq.s   wait_strahl
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
;                bset    #6,$09(A0)           ; Tastatur IRQ erlauben
;                bset    #6,$15(A0)
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

                ;PART 'Farben erledigen'
do_colors:
; kopiert neue Farben fÅr den Text rein
                bsr     vsync
                addq.l  #6,color_pointer
                movea.l color_pointer(PC),A0
                tst.w   (A0)
                bpl.s   alles_chlor
                lea     color_tab(PC),A0
alles_chlor:    move.l  A0,color_pointer

                lea     palette+8(PC),A1
                move.w  (A0)+,D0
                move.w  D0,(A1)+
                move.w  D0,(A1)+
                move.w  D0,(A1)+
                move.w  D0,(A1)+
                move.w  (A0)+,D0
                move.w  D0,(A1)+
                move.w  D0,(A1)+
                move.w  D0,(A1)+
                move.w  D0,(A1)+
                move.w  (A0)+,D0
                move.w  D0,(A1)+
                move.w  D0,(A1)+
                move.w  D0,(A1)+
                move.w  D0,(A1)+
                rts

                ;ENDPART

                ;PART 'Helpbuffer erstellen'
create_scroll_help_buff:
; Kopiert erste Byte-Reihe in Buffer

                lea     scroll_buffer,A0
                lea     scroll_help_buff,A1
                move.w  #199,D0
cshbloop:       clr.b   (A1)+
                move.b  (A0),(A1)+
                clr.b   (A1)+
                move.b  2(A0),(A1)+
                lea     80(A0),A0
                dbra    D0,cshbloop
                rts
                ;ENDPART

                ;PART 'Buffer auf Screen kopieren'
copy_buffer_on_screen:
                lea     scroll_buffer,A0
                movea.l screen_1(PC),A1
                adda.l  screen_offset(PC),A1
                movea.l screen_2(PC),A2
                adda.l  screen_offset(PC),A2
                addq.l  #4,A1
                addq.l  #4,A2
                move.w  #(20*200)-1,D0
copy_buffer_lp: move.l  (A0),(A1)
                move.l  (A0)+,(A2)
                lea     8(A1),A1
                lea     8(A2),A2
                dbra    D0,copy_buffer_lp
                rts
                ;ENDPART

                ;PART 'Textbuffer lîschen'
clear_text_buffer:
                lea     scroll_buffer,A0
                move.w  #7999,D0             ; 8000*4 = 32000 Bytes
                moveq   #0,D1
clr_loop:       move.l  D1,(A0)+
                dbra    D0,clr_loop
                rts

                ;ENDPART

                ;PART 'Buffer shiften'

preshift8:
; shiftet Buffer um 8 Pixel nach links

                lea     scroll_buffer+16000,A0 ; Zweiter Buffer

                lea     1(A0),A0             ; Pointer um 1 Byte weiter
                move.w  #199,D0              ; 200 Zeilen
sh8screen1:     moveq   #19,D1               ; 20 Bitblocks
sh8screen2:     move.b  (A0),-1(A0)          ; erzeugt preshiftetes
                move.b  2(A0),1(A0)          ; Bild auf Newscreen
                move.b  3(A0),(A0)
                move.b  5(A0),2(A0)
                lea     4(A0),A0
                dbra    D1,sh8screen2
                dbra    D0,sh8screen1
                rts

                ;ENDPART

                ;PART 'Screen shiften'
preshift8_2:
; shiftet Bild um 8 Pixel nach links
; in a0=Pointer auf Bild

                lea     1(A0),A0             ; Pointer um 1 Byte weiter
                move.w  #199,D0              ; 200 Zeilen
sh8screen1a:    moveq   #19,D1               ; 20 Bitblocks
sh8screen2a:    move.b  (A0),-1(A0)          ; erzeugt preshiftetes
                move.b  2(A0),1(A0)          ; Bild auf Newscreen
                move.b  4(A0),3(A0)
                move.b  6(A0),5(A0)
                move.b  7(A0),(A0)
                move.b  9(A0),2(A0)
                move.b  11(A0),4(A0)
                move.b  13(A0),6(A0)
                lea     8(A0),A0
                dbra    D1,sh8screen2a
                dbra    D0,sh8screen1a
                rts

                ;ENDPART

                ;PART 'Text konvertieren'
convert_text:
; wandelt den Ascii-Text in Zeichennummern um

                lea     text(PC),A0
                lea     text_con_tab,A1
convert_loop:   moveq   #0,D0
                move.b  (A0),D0
                cmp.b   #-2,D0               ; Zentrierflag?
                bne.s   not_centre_flag
                move.b  D0,(A0)+             ; Åbernehmen!
                bra.s   convert_loop
not_centre_flag:cmp.b   #-1,D0
                beq.s   end_conv_text
                move.b  0(A1,D0.w),(A0)+     ; Zeichen aus Tabelle holen
                bra.s   convert_loop
end_conv_text:  rts

                ;ENDPART

                ;PART 'Logo preshiften'
preshift_logo:
; preshifted das Megalogo (640*400) 8 mal (2-er Schritte) in Buffer
; jeweils eine Zeile 8 mal hintereinander

                lea     big_logo(PC),A0
                lea     logo_preshift_buffer,A1
                move.w  #399,D1              ; 400 Scanlines
presh_logo_0:   moveq   #0,D0                ; Shiftcounter
presh_logo_1:   moveq   #39,D2               ; 40 Bitblocks pro Zeile
                movea.l A0,A2
                moveq   #0,D4
presh_logo_2:   moveq   #0,D3
                move.w  (A2)+,D3
                ror.l   D0,D3                ; um d3 nach rechts
                or.w    D4,D3                ; alten Rest einodern
                move.w  D3,(A1)+
                swap    D3
                move.w  D3,D4                ; neuer Rest
                dbra    D2,presh_logo_2
                addq.w  #2,D0                ; Shiftcounter+2
                cmp.w   #16,D0
                bne.s   presh_logo_1
                lea     80(A0),A0            ; eine Zeile tiefer
                dbra    D1,presh_logo_0
                rts
                ;ENDPART

                ;PART 'Sinustabelle umrechnen'

conv_sinus_tab:
; Wandelt x Koordinaten in Offsets um.

                lea     sinus_x(PC),A0
convert_sinus:  move.w  (A0),D0
                cmp.w   #-99,D0
                beq.s   end_convert
                move.w  D0,D1
                eori.w  #15,D0
                and.w   #15,D0
                lsr.w   #1,D0
                mulu    #80,D0

                lsr.w   #4,D1
                add.w   D1,D1
                add.w   D1,D0

                move.w  D0,(A0)+
                bra.s   convert_sinus
end_convert:    rts

                ;ENDPART

                ;PART 'Punish Logo kopieren'

wucht_punish:
; Kopiert Punish-Logo auf Screen
                addq.l  #2,sinus_point
                movea.l sinus_point(PC),A0
                cmpi.w  #-99,(A0)
                bne.s   nix
                lea     sinus_y(PC),A0
nix:            move.l  A0,sinus_point
                moveq   #0,D0
                move.w  (A0)+,D0
                lsl.l   #3,D0
                lea     logo_preshift_buffer,A0
                adda.l  D0,A0
                movea.l screen_1(PC),A1
                adda.l  screen_offset(PC),A1
                adda.l  sinus_screen(PC),A1
                addq.l  #2,A1                ; Plane 2
                addq.l  #2,sinus_point2
                movea.l sinus_point2(PC),A2
                cmpa.l  #end_sinus_x,A2
                bne.s   not_end_sinx
                lea     sinus_x(PC),A2
not_end_sinx:   move.l  A2,sinus_point2


                move.w  #199,D0
copy_logo_loop: movea.l A0,A3
                adda.w  (A2)+,A3

off             SET 0
                REPT 20
                move.w  (A3)+,off(A1)
off             SET off+8
                ENDR

                lea     8*80(A0),A0          ; auf nÑchste Scanline
                lea     160(A1),A1

                dbra    D0,copy_logo_loop
                rts

                ;ENDPART

                ;PART 'Front-Box kopieren'
wucht_front_box:
; Box ist an der x-Achse gespiegelt.
; Box ist 224*200 groû (1 Plane)

                lea     front_box,A4
                movea.l screen_1(PC),A5
                adda.l  screen_offset(PC),A5
                adda.l  sinus_screen(PC),A5
                lea     16(A5),A5
                lea     199*160(A5),A6       ; auf letzte Zeile gehen
                moveq   #99,D0               ; 2*100 Scanlines
                moveq   #0,D7                ; zum Lîschen
copy_front_box:
                movem.w (A4)+,D1-D6/A0       ; 7 Worte holen
                move.w  D7,(A5)
                move.w  D7,(A6)
                move.w  D1,8(A5)
                move.w  D1,8(A6)
                move.w  D2,16(A5)
                move.w  D2,16(A6)
                move.w  D3,24(A5)
                move.w  D3,24(A6)
                move.w  D4,32(A5)
                move.w  D4,32(A6)
                move.w  D5,40(A5)
                move.w  D5,40(A6)
                move.w  D6,48(A5)
                move.w  D6,48(A6)
                move.w  A0,56(A5)
                move.w  A0,56(A6)
                movem.w (A4)+,D1-D6/A0       ; 7 Worte holen
                move.w  D1,64(A5)
                move.w  D1,64(A6)
                move.w  D2,72(A5)
                move.w  D2,72(A6)
                move.w  D3,80(A5)
                move.w  D3,80(A6)
                move.w  D4,88(A5)
                move.w  D4,88(A6)
                move.w  D5,96(A5)
                move.w  D5,96(A6)
                move.w  D6,104(A5)
                move.w  D6,104(A6)
                move.w  A0,112(A5)
                move.w  A0,112(A6)
                move.w  D7,120(A5)
                move.w  D7,120(A6)
                lea     160(A5),A5           ; eine Zeile tiefer
                lea     -160(A6),A6
                dbra    D0,copy_front_box
                rts


                ;ENDPART

                ;PART 'Text aufbauen'


build_text_screen:
; baut Text auf Screen auf
                moveq   #8,D0
                move.w  #160,D1

                movea.l screen_1(PC),A0
                movea.l screen_2(PC),A1
                addq.l  #4,A0
                addq.l  #4,A1
                adda.l  screen_offset(PC),A0
                adda.l  screen_offset(PC),A1

                bra.s   build_text


build_text_buffer:
; baut Text in Buffer auf
                moveq   #4,D0
                moveq   #80,D1

                lea     scroll_buffer,A0
                lea     16000(A0),A1



build_text:
; baut den Text jeweils in den angegebenen zwei Buffern auf.
; a0=Buffer 1 (oder Screen 1)
; a1=Buffer 2 (oder Screen 2)
; d0.w=Abstand zweier Bitblocks (Screen=8, Buffer=4)
; d1.w=Bytes pro Scanline   (Screen=160, Buffer=80)
;
; nicht auf Geschwindigkeit optimiert, ist auch unnîtig.


                movea.l A0,A2                ; Komplett Screen oder Buffer lîschen
                movea.l A1,A3
                moveq   #0,D3
                move.w  #(20*200)-1,D2
clr_fuck_away:  move.l  D3,(A2)
                move.l  D3,(A3)
                adda.w  D0,A2                ; einen Bitblock weiter
                adda.w  D0,A3
                dbra    D2,clr_fuck_away


                adda.w  D1,A0                ; eine Zeile tiefer
                adda.w  D1,A1


                movea.l text_pointer(PC),A2  ; Hier steht Text
                cmpi.b  #-1,(A2)
                bne.s   not_end_of_text
                lea     text(PC),A2
not_end_of_text:

                moveq   #5,D2                ; 6 Zeilen
zeilen_loop:
                move.l  A0,-(A7)
                move.l  A1,-(A7)             ; Pointer retten


                moveq   #0,D3                ; ZeichenzÑhler Anzahl auf 0

                lea     char_pointers,A6
count_chars:
                moveq   #0,D4
                move.b  (A2)+,D4             ; Zeichen holen
                cmp.b   #-2,D4               ; Endekennung fÅr Zeile
                beq.s   end_count_chars
                lea     font,A3
                lsl.w   #8,D4                ; *256 (Zeichengrîûe)
                adda.w  D4,A3
                move.l  A3,(A6)+             ; in Pointertabelle
                addq.w  #1,D3                ; Anzahl +1
                cmp.w   #10,D3               ; entweder 10 Buchstaben oder zent.
                bne.s   count_chars


end_count_chars:
; in d3 steht jetzt Anzahl der Zeichen pro Zeile

                moveq   #0,D4                ; Offset auf 0 init
                moveq   #10,D6
                sub.w   D3,D6                ; jetzt Werte von 0-9 in d6
                btst    #0,D6                ; ungerade?
                beq.s   ist_gerade
                move.w  D0,D4                ; Offset um 16 Pixel bei ungerade
ist_gerade:
                subq.w  #1,D3                ; Anzahl-1 wegen DBRA

                lsr.w   #1,D6                ; durch zwei teilen
                mulu    D0,D6                ; * Bitblockbreite
                add.w   D6,D6                ; *2
                add.w   D6,D4

                adda.w  D4,A0                ; Auf Screenpointer addieren
                adda.w  D4,A1

                lea     char_pointers,A6

spalten_loop:   movea.l (A6)+,A3
                movea.l A0,A4
                movea.l A1,A5

                moveq   #31,D4               ; 32 hoch
copy_char:      move.l  (A3),(A4)
                move.l  (A3)+,(A5)
                adda.w  D0,A4                ; nÑchster Bitblock
                adda.w  D0,A5
                move.l  (A3),(A4)
                move.l  (A3)+,(A5)
                suba.w  D0,A4                ; wieder zurÅck
                suba.w  D0,A5
                adda.w  D1,A4                ; + Bytes pro Scanline
                adda.w  D1,A5
                dbra    D4,copy_char

                adda.w  D0,A0                ; + Abstand einer Plane zur anderen
                adda.w  D0,A0
                adda.w  D0,A1                ; (8 oder 4)
                adda.w  D0,A1

                dbra    D3,spalten_loop

                movea.l (A7)+,A1
                movea.l (A7)+,A0

                move.w  D1,D4
                mulu    #33,D4               ; *33 (soviele Zeilen tiefer)
                adda.w  D4,A0                ; 1 Reihe tiefer
                adda.w  D4,A1
                dbra    D2,zeilen_loop

                move.l  A2,text_pointer

                rts


                ;ENDPART

                ;PART 'VBL'
vbl:
                movem.l D0-A6,-(A7)

                lea     $ffff8240.w,A0       ; Palette schwarz
                moveq   #0,D0
                REPT 8
                move.l  D0,(A0)+
                ENDR

                move.l  #open_top,$68.w      ; HBL fÅr oberen Rand installieren
                move.w  #32,hbl_count        ; in dieser Zeile oberen Rand auf
                move    #$2100,SR            ; HBL zulassen

                jsr     music+4


                cmpi.b  #$39,$fffffc02.w     ; Space gedrÅckt?
                bne.s   not_space_pressed
                move.w  #-1,end_flag         ; Flag fÅr beenden
not_space_pressed:

                movem.l (A7)+,D0-A6

                andi.w  #$f8ff,(A7)
                rte

                ;ENDPART

                ;PART 'Tastatur-IRQ'
newkey:         rte
                ;ENDPART

                ;PART 'Timer-B'
timer_b:        movem.l D0/A0-A3,-(A7)


                eori.w  #1,delay             ; blinkende Farben setzen
                bne.s   delay_me

                addq.l  #4,blink_point1

delay_me:       movea.l blink_point1(PC),A3
                tst.w   (A3)
                bpl.s   not_end_tab1
                lea     blink_tab(PC),A3
not_end_tab1:   move.l  A3,blink_point1


                lea     palette+6(PC),A1
                lea     $ffff8242.w,A2
                lea     $fffffa21.w,A0
                clr.b   -6(A0)
                move.b  #190,(A0)            ; in Zeile 200 starten (Rand auf)
                move.b  #8,-6(A0)

                move.b  (A0),D0
wait_rand:      cmp.b   (A0),D0
                beq.s   wait_rand
                move.l  (A3),(A2)+           ; Blink-Farben kopieren
                REPT 6
                move.l  (A1)+,(A2)+
                ENDR
                move.w  (A1)+,(A2)+

                tst.w   old_st               ; nur beim alten ST aufmachen
                bne.s   not_stop_tb
                clr.b   -6(A0)
                bra.s   stop_tb
not_stop_tb:    move.l  #timer_b2,$0120.w
stop_tb:

                movem.l (A7)+,D0/A0-A3
                rte


timer_b2:
; Klappt unteren Rand auf (nur bei alten MMU)
                move.l  A0,-(A7)
                move.l  D0,-(A7)


                lea     $fffffa21.w,A0
                clr.b   -6(A0)
                move.b  #10,(A0)
                move.b  #8,-6(A0)
                move.l  #timer_b3,$0120.w

                move.b  (A0),D0
wait_rand2:     cmp.b   (A0),D0
                beq.s   wait_rand2

                clr.b   $ffff820a.w          ; 60 Hz
                DCB.W 16,$4e71
                move.b  #2,$ffff820a.w       ; 50 Hz


                move.l  (A7)+,D0
                movea.l (A7)+,A0
                rte


timer_b3:
; Lîscht Palette um Dreck wegzumachen
                move.l  A0,-(A7)
                move.l  D0,-(A7)


                lea     $fffffa21.w,A0
                clr.b   -6(A0)
                move.b  #2,(A0)
                move.b  #8,-6(A0)
                move.l  #timer_b,$0120.w

                move.b  (A0),D0
wait_rand3:     cmp.b   (A0),D0
                beq.s   wait_rand3

                lea     $ffff8240.w,A0
                moveq   #0,D0
                REPT 8
                move.l  D0,(A0)+             ; Palette auf Schwarz
                ENDR


                clr.b   $fffffa1b.w          ; Timer B anhalten


                move.l  (A7)+,D0
                movea.l (A7)+,A0
                rte



                ;ENDPART

hbl_count:      DC.W 32

open_top:       subq.w  #1,hbl_count         ; solange, bis Zeile erreicht
                bmi.s   hbl_is_da
                rte

hbl_is_da:      move.l  #open_top_2,$68.w
waithere:       stop    #$2100
                bra.s   waithere

open_top_2:
; klappt den oberen Rand auf

                move    #$2700,SR

                addq.l  #6,A7                ; Stack korrigieren

                movem.l D0-A6,-(A7)

                DCB.W 79-22,$4e71

                move.b  #0,$ffff820a.w       ; 60 Hz

                DCB.W 17,$4e71

                move.b  #2,$ffff820a.w       ; 50 Hz

                movea.l sync_pointer2(PC),A0 ; Pointer auf Routinen

                lea     $ffff8209.w,A2

                lea     $ffff820a.w,A3
                lea     $ffff8260.w,A4
                moveq   #0,D0
                moveq   #2,D1
                moveq   #3,D3

                moveq   #0,D2
wait_sync2:     move.b  (A2),D2
                cmp.w   #64,D2
                blt.s   wait_sync2
                sub.w   #64,D2
                not.w   D2
                lsr.w   D2,D2

                DCB.W 38-5,$4e71

                movea.l (A0)+,A1             ; Routine aus Tabelle holen
                jmp     (A1)                 ; und diese anspringen



end_sync:

                clr.b   $fffffa1b.w
where_timer:    move.b  #2,$fffffa21.w       ; Zeile in der Palette ist
                move.b  #8,$fffffa1b.w
                move.l  #timer_b,$0120.w
                move    #$2300,SR

what_routine:   jsr     nothing              ; hier werden Routinen eingehÑngt

                bsr     wucht_punish

                bsr     wucht_front_box

                move.l  screen_1(PC),D0
                move.l  screen_2(PC),screen_1
                move.l  D0,screen_2
                add.l   sinus_screen(PC),D0  ; HÅpfer dazuaddieren
                bsr     set_screen

                addq.l  #1,vsync_count

                movem.l (A7)+,D0-A6
                ori.w   #$0300,(A7)
                rte

                ;PART 'Sinus-Routinen'

nothing:
; setzt Offset auf "zweiten" Screen (nicht richtiger Zweiter Screen"
                move.l  #32000,sinus_screen
                rts

nothing2:
; setzt Offset auf "ersten" Screen (nicht richtiger Erster Screen"
                move.l  #0,sinus_screen
                rts


scroll_text_rein:
; Scrollt Text von links nach rechts rein.


                eori.w  #1,scroll_delay
                bne.s   first_routine
                addq.l  #8,sinus_screen      ; jeden zweiten VBL

first_routine:

copy_right_half:

                movea.l screen_1(PC),A1
                adda.l  screen_offset(PC),A1
                adda.l  sinus_screen(PC),A1
                lea     156(A1),A1

                tst.w   scroll_counter
                beq     first_time

                movea.l scroll_pointer1,A0

off_1           SET 0
off_2           SET 0
                REPT 200
                move.l  off_1(A0),off_2(A1)
off_1           SET off_1+80
off_2           SET off_2+160
                ENDR

                move.l  scroll_pointer1,D0
                addq.l  #4,D0
                move.l  scroll_pointer2,scroll_pointer1
                move.l  D0,scroll_pointer2
                rts

first_time:
                lea     scroll_help_buff,A0

off_1           SET 0
                REPT 200
                move.l  (A0)+,off_1(A1)
off_1           SET off_1+160
                ENDR
                clr.w   scroll_delay
                rts


scroll_screen_out:
; Scheibt Screen nach links raus
                eori.w  #1,scroll_delay      ; nur jeden zweiten VBL
                bne.s   not_this_vbl
                addi.l  #8,sinus_screen
not_this_vbl:

                tst.w   scroll_counter       ; beim ersten mal nichts tun
                beq     do_nothing

                movea.l screen_1(PC),A0
                adda.l  screen_offset(PC),A0
                adda.l  sinus_screen(PC),A0
                lea     156(A0),A0
                moveq   #0,D1
off_1           SET 0
                REPT 200
                move.l  D1,off_1(A0)
off_1           SET off_1+160
                ENDR

off_1           SET off_1-164
                move.l  D1,off_1(A0)         ; MÅll weglîschen

do_nothing:     rts






rein_huepf_rout:
                addq.l  #4,dobbs_point
                movea.l dobbs_point(PC),A0
                tst.l   (A0)
                bpl.s   not_end_sin_tab2
                move.w  #-1,sinus_finished   ; Fertig!
                move.l  #raus_schieb_tabelle,dobbs_point
                move.l  #nothing2,what_routine+2
                rts
not_end_sin_tab2:
                move.l  A0,dobbs_point
                move.l  (A0),sinus_screen
                rts

raus_schieb_rout:
                addq.l  #4,dobbs_point
                movea.l dobbs_point(PC),A0
                tst.l   (A0)
                bpl.s   not_end_sin_tab3
                move.w  #-1,sinus_finished
                move.l  #dobbs_tabelle,dobbs_point
                move.l  #nothing,what_routine+2
                rts
not_end_sin_tab3:
                move.l  A0,dobbs_point
                move.l  (A0),sinus_screen
                rts

                ;ENDPART

                ;PART 'Set-Screen'
set_screen:
; in d0 = Screenadresse
; setzt Lowbyte mit Syncscrolling (beim STE normal)

                move.l  sync_pointer1(PC),D1 ; Pointer tauschen
                move.l  sync_pointer2(PC),sync_pointer1
                move.l  D1,sync_pointer2

                move.w  D0,D1
                and.w   #255,D1              ; nur Lowbyte
                lea     sync_tabelle(PC),A0
                adda.w  D1,A0
                move.l  (A0)+,sync_pointer2  ; Pointer auf Sync-Routine
                add.l   (A0)+,D0             ; dieser Offset wird abgezogen

                lsr.l   #8,D0
                lea     $ffff8201.w,A0
                movep.w D0,0(A0)
                rts

                ;ENDPART

                ;PART 'Init-Syncscrolling'
init_sync_scrolling:
                bsr     get_anzahl_zeilen    ; ermitteln, wieviel Scanlines dargestellt werden
                bsr     find_top_border      ; ermittelt wo oberer Rand aufgeht
                move.w  anzahl_zeilen(PC),D0
                sub.w   #200,D0              ; jetzt Zeilen des oberen Randes

                moveq   #7,D1

                cmp.w   #13,D0
                bgt.s   not_add
                add.w   #10,D0               ; + 10 Zeilen
                move.w  #-1,old_st
                moveq   #1,D1                ; nach einer Zeile aufmachen
                bra.s   not_add2
not_add:        moveq   #29,D0               ; 29 Zeilen Default
not_add2:
                mulu    #160,D0

                move.b  D1,where_timer+3     ; dort werden Farben geschaltet
                move.l  D0,screen_offset
                rts

old_st:         DC.W 0

                ;ENDPART

                ;PART 'MMU-Test' ; stellt fest, welche MMU (und ob STE da ist)

get_anzahl_zeilen:
; Routine ermittelt die MMU des ST's, d.h. wieviele Zeilen dargestellt werden
; (wenn oberer Rand auf ist)

                move.l  $70.w,-(A7)          ; alten VBL merken

                move.l  #test_vbl1,$70.w
wait_test:      tst.w   test_flag            ; solange warten bis fertig
                beq.s   wait_test

                move.l  (A7)+,$70.w
                rts


test_vbl1:      clr.b   $fffffa1b.w          ; Timer B starten
                move.b  #1,$fffffa21.w       ; in erster Zeile Timer B auslîsen
                move.b  #8,$fffffa1b.w
                move.l  #test_timer_b1,$0120.w

                move.l  #test_vbl2,$70.w

                clr.b   $ffff820a.w          ; auf 60 Hz gehen
                rte

test_vbl2:      clr.b   $fffffa1b.w          ; Timer B stop
                move.w  #-1,test_flag        ; Test beendet!
                rte

test_timer_b1:  addq.w  #1,anzahl_zeilen     ; Zeilen+1
                move.b  #2,$ffff820a.w       ; auf 50 Hz gehen
                move.l  #test_timer_b2,$0120.w
                rte

test_timer_b2:  addq.w  #1,anzahl_zeilen     ; solange zÑhlen bis neuer VBL da
                rte


anzahl_zeilen:  DC.W 0
test_flag:      DC.W 0


find_top_border:
; ermittelt, in welcher Zeile der obere Rand aufgeklappt werden muû

                move.l  $70.w,-(A7)          ; alten VBL retten

                move.l  #test_vbl_3,$70.w

                bsr     vsync
                bsr     vsync

                subq.w  #2,hbl_count2

                move.l  (A7)+,$70.w          ; alten VBL wieder setzen

                rts


test_vbl_3:     movem.l D0-A6,-(A7)

                bsr     get_top_border

                addq.l  #1,vsync_count

                movem.l (A7)+,D0-A6
                rte


get_top_border:
;findet die Stelle, an der der obere Rand aufgeht. Wert steht dann in HBL_COUNT2

                move.l  $68.w,-(A7)          ; merke alten HBL-Vektor
                move.l  #hbl,$68.w           ; und setze eigenen Vektor

                bsr.s   finde_sync           ; bestimme Moment der Randoeffnung

                move.l  (A7)+,$68.w          ; hole alten HBL-Vektor wieder
                rts

finde_sync:
                movem.l D0/A1-A2,-(A7)       ; rette arbeitsregister

                movea.w #$820a,A1            ; Bildfrequenz
                movea.w #$8209,A2            ; Videoram-Lowbyte

                move    #$2000,SR            ; erlaube HBL
                clr.b   (A1)                 ; 60Hz

                move.b  (A2),D0              ; noch sind wir im VBL
finde_sync1:    cmp.b   (A2),D0              ; warte auf Bildanfang
                beq.s   finde_sync1          ;

                move.b  #2,(A1)              ; 50Hz

                move    #$2500,SR            ; kein HBL mehr
                move.w  hbl_count2(PC),D0    ; bereits ein Wert bekannt?
                bpl.s   finde_sync2          ; ja, bereits syncron

                sub.w   hbl_count1(PC),D0    ; bilde erst einmal den Wert
                subq.w  #1,D0
                move.w  D0,hbl_count2        ; und merke ihn

finde_sync2:    movem.l (A7)+,D0/A1-A2
                rts

hbl:            subq.w  #1,hbl_count1        ; Zeile -1
                rte

hbl_count1:     DC.W -1         ; aktueller HBL-Zaehler
hbl_count2:     DC.W -1         ; hier kommt Anzahl der Zeilen rein

                ;ENDPART

                ;PART 'Sync-Tabelle'

sync_pointer1:  DC.L s_offset_0
sync_pointer2:  DC.L s_offset_0

sync_tabelle:
; zu jedem Offset (in 8er Schritten) Pointer auf Routinen und Offset auf Screen
                DC.L s_offset_0
                DC.L 0
                DC.L s_offset_8
                DC.L -256
                DC.L s_offset_16
                DC.L -256
                DC.L s_offset_24
                DC.L -256
                DC.L s_offset_32
                DC.L -512
                DC.L s_offset_40
                DC.L -512
                DC.L s_offset_48
                DC.L -512
                DC.L s_offset_56
                DC.L -768
                DC.L s_offset_64
                DC.L -768
                DC.L s_offset_72
                DC.L -768
                DC.L s_offset_80
                DC.L -1024
                DC.L s_offset_88
                DC.L 0
                DC.L s_offset_96
                DC.L -256
                DC.L s_offset_104
                DC.L -256
                DC.L s_offset_112
                DC.L -256
                DC.L s_offset_120
                DC.L -512
                DC.L s_offset_128
                DC.L -512
                DC.L s_offset_136
                DC.L -512
                DC.L s_offset_144
                DC.L -768
                DC.L s_offset_152
                DC.L -768
                DC.L s_offset_160
                DC.L -768
                DC.L s_offset_168
                DC.L -1024
                DC.L s_offset_176
                DC.L 0
                DC.L s_offset_184
                DC.L 0
                DC.L s_offset_192
                DC.L -256
                DC.L s_offset_200
                DC.L -256
                DC.L s_offset_208
                DC.L -256
                DC.L s_offset_216
                DC.L -512
                DC.L s_offset_224
                DC.L -512
                DC.L s_offset_232
                DC.L -512
                DC.L s_offset_240
                DC.L -768
                DC.L s_offset_248
                DC.L -768

                ;ENDPART

                ;PART 'Sync-Pointer-Tab'

; Tabelle mit den Routinen, auf jeweils 14 Scanlines erweitert
s_offset_0:
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L end_sync
s_offset_8:
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L end_sync
s_offset_16:
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L end_sync
s_offset_24:
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L end_sync
s_offset_32:
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L end_sync
s_offset_40:
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L end_sync
s_offset_48:
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L end_sync
s_offset_56:
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L end_sync
s_offset_64:
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L end_sync
s_offset_72:
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L end_sync
s_offset_80:
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L end_sync
s_offset_88:
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L end_sync
s_offset_96:
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L end_sync
s_offset_104:
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L end_sync
s_offset_112:
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine0

                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L end_sync
s_offset_120:
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L end_sync
s_offset_128:
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L end_sync
s_offset_136:
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L end_sync
s_offset_144:
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L end_sync
s_offset_152:
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L end_sync
s_offset_160:
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L end_sync
s_offset_168:
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L end_sync
s_offset_176:
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L end_sync
s_offset_184:
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine2
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L end_sync
s_offset_192:
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L end_sync
s_offset_200:
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L end_sync
s_offset_208:
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine2
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L end_sync
s_offset_216:
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L end_sync
s_offset_224:
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L end_sync
s_offset_232:
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine2
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L end_sync
s_offset_240:
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L end_sync
s_offset_248:
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine1
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine2
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L sync_routine0
                DC.L end_sync


                ;ENDPART

                ;PART 'Sync-Routinen'

; Hier sind die Routinen, die die RÑnder aufmachen

sync_routine1:
; klappt beide RÑnder auf.
; braucht 70 Bytes
                move.b  D1,(A4)              ; Highres
                nop
                move.b  D0,(A4)              ; Lowres (Links auf)

                DCB.W 89,$4e71

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
; stellt 44 Bytes dar (klappt rechts auf)
                move.b  D0,(A4)              ; Lowres
                nop
                move.b  D0,(A4)              ; Lowres

                DCB.W 89,$4e71

                move.b  D0,(A3)              ; 60Hz
                move.b  D1,(A3)              ; 50Hz (Rechts auf)

                DCB.W 13,$4e71

                move.b  D0,(A4)              ; Lowres
                nop
                move.b  D0,(A4)              ; Lowres

                DCB.W 12-5,$4e71

                movea.l (A0)+,A1             ; nÑchste Routine holen (12)
                jmp     (A1)                 ; und die anspringen    (8)



sync_routine0:
; macht 512 TZ lang nichts
                DCB.W 128-5,$4e71
                movea.l (A0)+,A1             ; nÑchste Routine holen (12)
                jmp     (A1)                 ; und die anspringen    (8)

                ;ENDPART

screen_offset:  DC.L 0          ; dort kommt Offset an der erste Zeile beginnt hin

;-------------------- Syncscrolling Ende --------------------------------


;------------------------------------------------------------------------------
                DATA

screen_1:       DC.L 0          ; so weit oben damit PC-Relativer Zugriff
screen_2:       DC.L 0
sinus_screen:   DC.L 0          ; Offset fÅr reindobbsen, etc.
sinus_finished: DC.W 0



palette:        DC.W $00,$0123,$0740,$0777
                DCB.W 4,$0543
                DCB.W 4,$0765
                DCB.W 4,$0321


                ;PART 'Color-Tab'
color_pointer:  DC.L color_tab

color_tab:
                DC.W $0555,$0777,$0333
                DC.W $0554,$0776,$0332
                DC.W $0445,$0667,$0223
                DC.W $0455,$0677,$0233
                DC.W $0545,$0767,$0323
                DC.W $0544,$0766,$0322
                DC.W $0543,$0765,$0321
                DC.W $0454,$0676,$0232
                DC.W -1
                ;ENDPART

                ;PART 'Dobbs und Reinschiebtabelle'

dobbs_point:    DC.L dobbs_tabelle

dobbs_tabelle:

                DC.L 32000,31840,31680,31520,31200,30880,30400,29760
                DC.L 29120,28480,27680,26720,25760,24800,23680,22560
                DC.L 21280,20000,18720,17280,16000,14400,12960,11360
                DC.L 9760,8160,6560,4960,3200,1600,0
                DC.L 1600,3200,4960,6560,8160
                DC.L 9760,11360,12960,14400,16000,17280,18720,20000
                DC.L 21280,22560,23680,24800,25760,26720,27680,28480
                DC.L 29120,29760,30400,30880,31200,31520,31680,31840


                DC.L 32000,31840
                DC.L 31680,31520,31200,30880,30400,29760,29120,28480
                DC.L 27680,26720,25760,24800,23680,22560,21280,20000
                DC.L 18720,17280,16000,14400,12960,11360,9760,8160
                DC.L 6560,4960,3200,1600,0

                DC.L 0,1120,2400,3680,4960,6080,7360,8480
                DC.L 9760,10880,12000,12960,14080,15040,16000,16960
                DC.L 17760,18560,19360,20000,20640,21280,21920,22400
                DC.L 22720,23040,23360,23680,23840,23840,24000,23840
                DC.L 23840,23680,23360,23040,22720,22400,21920,21280
                DC.L 20640,20000,19360,18560,17760,16960,16000,15040
                DC.L 14080,12960,12000,10880,9760,8480,7360,6080
                DC.L 4960,3680,2400,1120,0

                DC.L 0,800,1600,2400,3200,4000,4800,5600
                DC.L 6400,7200,8000,8640,9280,9920,10560,11200
                DC.L 11840,12320,12800,13280,13760,14240,14560,14880
                DC.L 15200,15360,15520,15680,15840,15840,16000,15840
                DC.L 15840,15680,15520,15360,15200,14880,14560,14240
                DC.L 13760,13280,12800,12320,11840,11200,10560,9920
                DC.L 9280,8640,8000,7200,6400,5600,4800,4000
                DC.L 3200,2400,1600,800,0

                DC.L 0,480,960,1600,2080,2720,3200,3680
                DC.L 4160,4640,5120,5440,5920,6240,6560,6880
                DC.L 7040,7360,7520,7680,7840,7840,7840,7840
                DC.L 7840,7840,7680,7520,7360,7040,6880,6560
                DC.L 6240,5920,5440,5120,4640,4160,3680,3200
                DC.L 2720,2080,1600,960,480,0


                DC.L 0,320,640,960,1280,1600,1920,2240
                DC.L 2560,2720,3040,3200,3360,3520,3680,3840
                DC.L 3840,3840,4000,3840,3840,3840,3680,3520
                DC.L 3360,3200,3040,2720,2560,2240,1920,1600
                DC.L 1280,960,640,320,0

                DC.L 0,160,480,640,960,1120,1280,1440
                DC.L 1600,1760,1760,1760,1760,1760,1760,1600
                DC.L 1440,1280,1120,800,640,320,0,0
                DC.L -99

raus_schieb_tabelle:
                DC.L 0,0,0,160,160,480,640,800,1120,1440
                DC.L 1920,2240,2720,3200,3680,4160,4800,5440,6080,6720
                DC.L 7360,8160,8960,9760,10560,11360,12160,13120,14080,15040
                DC.L 16000,16960,17920,18880,20000,20960,22080,23040,24160,25280
                DC.L 26400,27520,28640,29760,30880,32000
                DC.L 32000
                DC.L -99

                ;ENDPART

                ;PART 'Text'
; Textblîcke: 10 breit und jeweils 6 hoch.
;

text_pointer:   DC.L text

text:
; Maximal 10 Zeichen, falls -2 am Ende wird der Text zentriert (16er statt 32er)
; Endekennung ist -1
; VORSICHT!!!!! BEI 10ZEICHEN PRO ZEILE KEIN -2 ---> SONST ABSTURZ!!!!!

;                    "vvvvvvvvvv"

                DC.B "----------"
                DC.B "WELCOME TO"
                DC.B "PUNISH",-2
                DC.B "YOUR",-2
                DC.B "MACHINE!",-2
                DC.B "----------"

                DC.B "OFFICIAL",-2
                DC.B "I.C.C. 2",-2
                DC.B "PARTY-DEMO"
                DC.B "RELEASE",-2
                DC.B "DATE:",-2
                DC.B "12-11-91",-2

                DC.B "A TWO-DISK"
                DC.B "DEMO BY",-2
                DC.B "DELTA",-2
                DC.B "FORCE",-2
                DC.B "OF THE",-2
                DC.B "THE UNION",-2

                DC.B "----------"
                DC.B "CREDITS",-2
                DC.B "FOR",-2
                DC.B "THIS",-2
                DC.B "SCREEN:",-2
                DC.B "----------"

                DC.B "CODING:",-2
                DC.B "NEW MODE",-2
                DC.B "GRAPHICS:",-2
                DC.B "SLIME",-2
                DC.B "MUSIC:",-2
                DC.B "BIG ALEC",-2

                DC.B "DELTA",-2
                DC.B "FORCE",-2
                DC.B "CONSISTS",-2
                DC.B "OF THE",-2
                DC.B "FOLLOWING",-2
                DC.B "PEOPLE:",-2

                DC.B "BIG ALEC  "
                DC.B "(MUSICIAN)"
                DC.B " ",-2
                DC.B " ",-2
                DC.B "CHAOS INC."
                DC.B "   (CODER)"

                DC.B "DANIEL    "
                DC.B "   (CODER)"
                DC.B " ",-2
                DC.B " ",-2
                DC.B "EARTHLIGHT"
                DC.B " (PAINTER)"

                DC.B "FLIX      "
                DC.B "   (CODER)"
                DC.B " ",-2
                DC.B " ",-2
                DC.B "MASCOT    "
                DC.B "  (GIRLIE)"


                DC.B "NEW MODE  "
                DC.B "   (CODER)"
                DC.B " ",-2
                DC.B " ",-2
                DC.B "QUESTLORD "
                DC.B " (PAINTER)"

                DC.B "RAY       "
                DC.B "   (CODER)"
                DC.B " ",-2
                DC.B " ",-2
                DC.B "SAMMY JOE "
                DC.B "  (MAGGIE)"

                DC.B "SLIME     "
                DC.B " (PAINTER)"
                DC.B " ",-2
                DC.B " ",-2
                DC.B "THOR      "
                DC.B " (PAINTER)"

                DC.B "COPY",-2
                DC.B "BOTH",-2
                DC.B "DISKS",-2
                DC.B "82 TRACKS",-2
                DC.B "10 SECTORS"
                DC.B "2 SIDES",-2

                DC.B "AND COPY",-2
                DC.B "WITH:",-2
                DC.B "SECTORS",-2
                DC.B "-ALL-",-2
                DC.B "FASTFORMAT"
                DC.B "-OFF-",-2

                DC.B "WE HOPE",-2
                DC.B "YOU LIKE",-2
                DC.B "THIS DEMO."
                DC.B "IF NOT, WE"
                DC.B "CARE A",-2
                DC.B "SHIT!",-2

                DC.B "IF YOU",-2
                DC.B "WANT TO",-2
                DC.B "CONTACT US"
                DC.B "FOR LEGAL",-2
                DC.B "REASONS",-2
                DC.B "THEN",-2

                DC.B "WRITE TO:",-2
                DC.B "PLK -",-2
                DC.B "136681E",-2
                DC.B "7050 -",-2
                DC.B "WAIBLINGEN"
                DC.B "W-GERMANY",-2

                DC.B "WE WON'T",-2
                DC.B "ANSWER",-2
                DC.B "WITHOUT",-2
                DC.B "ENOUGH",-2
                DC.B "INT.REPLY-"
                DC.B "COUPONS!",-2

                DC.B "CALL OUR",-2
                DC.B "BBS:",-2
                DC.B "+49",-2
                DC.B "(0)8151",-2
                DC.B "78880",-2
                DC.B "----------"

                DC.B "----------"
                DC.B "CREDITS",-2
                DC.B "FOR",-2
                DC.B "LOADING",-2
                DC.B "SCREEN:",-2
                DC.B "----------"

                DC.B "CODING:",-2
                DC.B "NEW MODE",-2
                DC.B "GRAPHICS:",-2
                DC.B "NEW MODE",-2
                DC.B "MUSIC:",-2
                DC.B "BIG ALEC",-2

                DC.B "----------"
                DC.B "CREDITS",-2
                DC.B "FOR",-2
                DC.B "DISKCHANGE"
                DC.B "SCREEN:",-2
                DC.B "----------"

                DC.B "CODING:",-2
                DC.B "NEW MODE",-2
                DC.B "GRAPHICS:",-2
                DC.B "QUESTLORD",-2
                DC.B "AND SLIME",-2
                DC.B "MUSIC: BA",-2

                DC.B "THAT'S THE"
                DC.B "EE NN  DD "
                DC.B "E  N N D D"
                DC.B "EE N N D D"
                DC.B "E  N N D D"
                DC.B "EE N N DD "

                DC.B -1
                EVEN

                ;ENDPART

                ;PART 'Blink-Tab'
blink_tab:
                DC.W $0777,$00  ; alte ST-Palette
                DC.W $0776,$0100
                DC.W $0775,$0200
                DC.W $0774,$0300
                DC.W $0773,$0400
                DC.W $0762,$0510
                DC.W $0751,$0620
                DC.W $0740,$0730
                DC.W $0730,$0740
                DC.W $0620,$0751
                DC.W $0510,$0762
                DC.W $0400,$0773
                DC.W $0300,$0774
                DC.W $0200,$0775
                DC.W $0100,$0776
                DC.W $00,$0777
                DC.W $00,$0777
                DC.W $00,$0777
                DC.W $00,$0777
                DC.W $00,$0777
                DC.W $00,$0777
                DC.W $00,$0777
                DC.W $00,$0777
                DC.W $00,$0777
                DC.W $00,$0777
                DC.W $01,$0776
                DC.W $02,$0775
                DC.W $03,$0774
                DC.W $04,$0773
                DC.W $15,$0772
                DC.W $26,$0771
                DC.W $37,$0770
                DC.W $47,$0760
                DC.W $0157,$0660
                DC.W $0267,$0650
                DC.W $0377,$0550
                DC.W $0477,$0540
                DC.W $0577,$0440
                DC.W $0677,$0430
                DC.W $0777,$0330
                DC.W $0777,$0320
                DC.W $0777,$0220
                DC.W $0777,$0210
                DC.W $0777,$0110
                DC.W $0777,$0100
                DC.W $0777,$00
                DC.W $0777,$00
                DC.W $0777,$00
                DC.W $0777,$00
                DC.W $0777,$00
                DC.W $0777,$00
                DC.W $0777,$00
                DC.W $0777,$00
                DC.W $0777,$00
                DC.W $0777,$00
                DC.W $0776,$0101
                DC.W $0766,$0202
                DC.W $0666,$0303

                DC.W $0665,$0404
                DC.W $0655,$0505
                DC.W $0555,$0606
                DC.W $0554,$0707
                DC.W $0544,$0717
                DC.W $0444,$0727
                DC.W $0443,$0737
                DC.W $0433,$0747
                DC.W $0333,$0757
                DC.W $0332,$0767
                DC.W $0322,$0777
                DC.W $0222,$0777
                DC.W $0221,$0777
                DC.W $0211,$0777
                DC.W $0111,$0777
                DC.W $0110,$0777
                DC.W $0100,$0777
                DC.W $00,$0777
                DC.W $00,$0777
                DC.W $00,$0777
                DC.W $00,$0777
                DC.W $00,$0777
                DC.W $00,$0777
                DC.W $00,$0777
                DC.W $00,$0777
                DC.W $00,$0777
                DC.W $00,$0777
                DC.W $0100,$0777
                DC.W $0200,$0777
                DC.W $0300,$0777
                DC.W $0400,$0777
                DC.W $0500,$0777
                DC.W $0600,$0777
                DC.W $0700,$0777
                DC.W $0710,$0777
                DC.W $0720,$0777
                DC.W $0730,$0777
                DC.W $0740,$0777
                DC.W $0750,$0777
                DC.W $0760,$0777
                DC.W $0770,$0777
                DC.W $0771,$0666
                DC.W $0772,$0555
                DC.W $0773,$0444
                DC.W $0774,$0333
                DC.W $0775,$0222
                DC.W $0776,$0111
                DC.W $0777,$00
                DC.W $0777,$00
                DC.W $0777,$00
                DC.W $0777,$00
                DC.W $0777,$00
                DC.W $0777,$00
                DC.W $0777,$00
                DC.W $0777,$00
                DC.W $0777,$00
                DC.W $0777,$00

                DC.W -1


blink_point1:   DC.L blink_tab
delay:          DC.W 0
                ;ENDPART

                ;PART 'Sinus-Tabellen'
sinus_point:    DC.L sinus_y
sinus_point2:   DC.L sinus_x

sinus_y:
; mit 80 multipliziert (0-199)

                DC.W 8000,8480,9040,9600,10160,10720,11200,11680
                DC.W 12160,12640,13120,13520,13920,14240,14560,14880
                DC.W 15120,15360,15600,15760,15840,15920,15920,15920
                DC.W 15920,15840,15760,15600,15360,15120,14880,14560
                DC.W 14240,13920,13520,13120,12640,12160,11680,11200
                DC.W 10720,10160,9600,9040,8480,8000,7440,6880
                DC.W 6320,5760,5200,4720,4240,3760,3280,2800
                DC.W 2400,2000,1680,1360,1040,800,560,320
                DC.W 160,80,0,0,0,0,80,160
                DC.W 320,560,800,1040,1360,1680,2000,2400
                DC.W 2800,3280,3760,4240,4720,5200,5760,6320
                DC.W 6880,7440

                DC.W 8000,8640,9360,10000,10720,11360,12000,12560
                DC.W 13120,13600,14080,14480,14880,15200,15440,15680
                DC.W 15840,15920,15920,15920,15840,15680,15440,15200
                DC.W 14880,14480,14080,13600,13120,12560,12000,11360
                DC.W 10720,10000,9360,8640,8000,7280,6560,5920
                DC.W 5200,4560,3920,3360,2800,2320,1840,1440
                DC.W 1040,720,480,240,80,0,0,0
                DC.W 80,240,480,720,1040,1440,1840,2320
                DC.W 2800,3360,3920,4560,5200,5920,6560,7280
                DC.W -99




sinus_x:
                DC.W 160,161,162,164,165,166,168,169,171,172
                DC.W 173,175,176,178,179,180,182,183,185,186
                DC.W 187,189,190,191,193,194,195,197,198,200
                DC.W 201,202,204,205,206,208,209,210,212,213
                DC.W 214,216,217,218,219,221,222,223,225,226
                DC.W 227,228,230,231,232,233,235,236,237,238
                DC.W 240,241,242,243,244,245,247,248,249,250
                DC.W 251,252,254,255,256,257,258,259,260,261
                DC.W 262,263,264,266,267,268,269,270,271,272
                DC.W 273,274,275,276,277,277,278,279,280,281
                DC.W 282,283,284,285,286,286,287,288,289,290
                DC.W 291,291,292,293,294,294,295,296,297,297
                DC.W 298,299,299,300,301,301,302,303,303,304
                DC.W 305,305,306,306,307,307,308,308,309,309
                DC.W 310,310,311,311,312,312,313,313,313,314
                DC.W 314,314,315,315,315,316,316,316,317,317
                DC.W 317,317,318,318,318,318,318,318,319,319
                DC.W 319,319,319,319,319,319,319,319,319,319
                DC.W 319,319,319,319,319,319,319,319,319,319
                DC.W 319,319,319,318,318,318,318,318,318,317
                DC.W 317,317,317,316,316,316,315,315,315,314
                DC.W 314,314,313,313,313,312,312,311,311,310
                DC.W 310,309,309,308,308,307,307,306,306,305
                DC.W 305,304,303,303,302,301,301,300,299,299
                DC.W 298,297,297,296,295,294,294,293,292,291
                DC.W 291,290,289,288,287,286,286,285,284,283
                DC.W 282,281,280,279,278,277,277,276,275,274
                DC.W 273,272,271,270,269,268,267,266,264,263
                DC.W 262,261,260,259,258,257,256,255,254,252
                DC.W 251,250,249,248,247,245,244,243,242,241
                DC.W 240,238,237,236,235,233,232,231,230,228
                DC.W 227,226,225,223,222,221,219,218,217,216
                DC.W 214,213,212,210,209,208,206,205,204,202
                DC.W 201,200,198,197,195,194,193,191,190,189
                DC.W 187,186,185,183,182,180,179,178,176,175
                DC.W 173,172,171,169,168,166,165,164,162,161
                DC.W 160,158,157,155,154,153,151,150,148,147
                DC.W 146,144,143,141,140,139,137,136,134,133
                DC.W 132,130,129,128,126,125,124,122,121,119
                DC.W 118,117,115,114,113,111,110,109,107,106
                DC.W 105,103,102,101,100,98,97,96,94,93
                DC.W 92,91,89,88,87,86,84,83,82,81
                DC.W 80,78,77,76,75,74,72,71,70,69
                DC.W 68,67,65,64,63,62,61,60,59,58
                DC.W 57,56,55,53,52,51,50,49,48,47
                DC.W 46,45,44,43,42,42,41,40,39,38
                DC.W 37,36,35,34,33,33,32,31,30,29
                DC.W 28,28,27,26,25,25,24,23,22,22
                DC.W 21,20,20,19,18,18,17,16,16,15
                DC.W 14,14,13,13,12,12,11,11,10,10
                DC.W 9,9,8,8,7,7,6,6,6,5
                DC.W 5,5,4,4,4,3,3,3,2,2
                DC.W 2,2,1,1,1,1,1,1,0,0
                DC.W 0,0,0,0,0,0,0,0,0,0
                DC.W 0,0,0,0,0,0,0,0,0,0
                DC.W 0,0,0,1,1,1,1,1,1,2
                DC.W 2,2,2,3,3,3,4,4,4,5
                DC.W 5,5,6,6,6,7,7,8,8,9
                DC.W 9,10,10,11,11,12,12,13,13,14
                DC.W 14,15,16,16,17,18,18,19,20,20
                DC.W 21,22,22,23,24,25,25,26,27,28
                DC.W 28,29,30,31,32,33,33,34,35,36
                DC.W 37,38,39,40,41,42,42,43,44,45
                DC.W 46,47,48,49,50,51,52,53,55,56
                DC.W 57,58,59,60,61,62,63,64,65,67
                DC.W 68,69,70,71,72,74,75,76,77,78
                DC.W 80,81,82,83,84,86,87,88,89,91
                DC.W 92,93,94,96,97,98,100,101,102,103
                DC.W 105,106,107,109,110,111,113,114,115,117
                DC.W 118,119,121,122,124,125,126,128,129,130
                DC.W 132,133,134,136,137,139,140,141,143,144
                DC.W 146,147,148,150,151,153,154,155,157,158
                DC.W 160

                DC.W 162,165,168,171,173,176,179
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

end_sinus_x:
                DC.W 160,161,162,164,165,166,168,169,171,172
                DC.W 173,175,176,178,179,180,182,183,185,186
                DC.W 187,189,190,191,193,194,195,197,198,200
                DC.W 201,202,204,205,206,208,209,210,212,213
                DC.W 214,216,217,218,219,221,222,223,225,226
                DC.W 227,228,230,231,232,233,235,236,237,238
                DC.W 240,241,242,243,244,245,247,248,249,250
                DC.W 251,252,254,255,256,257,258,259,260,261
                DC.W 262,263,264,266,267,268,269,270,271,272
                DC.W 273,274,275,276,277,277,278,279,280,281
                DC.W 282,283,284,285,286,286,287,288,289,290
                DC.W 291,291,292,293,294,294,295,296,297,297
                DC.W 298,299,299,300,301,301,302,303,303,304
                DC.W 305,305,306,306,307,307,308,308,309,309
                DC.W 310,310,311,311,312,312,313,313,313,314
                DC.W 314,314,315,315,315,316,316,316,317,317
                DC.W 317,317,318,318,318,318,318,318,319,319
                DC.W 319,319,319,319,319,319,319,319,319,319
                DC.W 319,319,319,319,319,319,319,319,319,319
                DC.W 319,319,319,318,318,318,318,318,318,317
                DC.W -99
                ;ENDPART

                ;PART 'Big-Logo'
big_logo:
; 640*400 eine Plane (im Monochrom-Format)
                INCBIN 'PUNISH.PI3',32000,34
                ;ENDPART

                ;PART 'Front-Box'
front_box:
; 224*100 (1 Plane) und an x-Achse gespiegelt.
                INCBIN 'FRONTBOX.IMG'
                ;ENDPART

                ;PART 'Musik'
music:          INCBIN 'OMEGAC64.MUS'
                EVEN
                ;ENDPART

                ;PART 'Zeichensatz'
font:
; 49 Zeichen, 2 Planes, 32*32
                INCBIN 'FONT.IMG'
                ;ENDPART

                ;PART 'Text-Konvertier-Tabelle'
;-----------------------------
text_con_tab:
; fÅr vertikalen Scroller
                DCB.B 33,26      ;bis $20
                DC.B 41,46      ;!,"
                DC.B 26,26,26,38 ; #-&
                DC.B 45,39,40,26,38,47,37,43,37 ; '- /
                DC.B 36,27,28,29,30,31,32,33,34,35,44,48 ; 0-;
                DCB.B 3,26       ;<=>
                DC.B 42,26      ;?,@
                DC.B 0,1,2,3,4,5,6,7 ; A-Z
                DC.B 8,9,10,11,12,13,14,15 ;$49-$50
                DC.B 16,17,18,19,20,21,22,23,24,25 ;$51-$5a
                DCB.B 6,26       ;$5b-$60
                EVEN


                ;ENDPART


;------------------------------------------------------------------------------
		SECTION BSS
bss_start:      

                ;PART 'Variablen'
end_flag:       DS.W 1
counter:        DS.W 1
scroll_delay:   DS.W 1
scroll_pointer1:DS.L 1
scroll_pointer2:DS.L 1
scroll_counter: DS.W 1
real_screen_1:  DS.L 1
real_screen_2:  DS.L 1
char_pointers:  DS.L 10         ; Dort kommen Pointer auf Buchstaben rein
                ;ENDPART

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
oldhbl:         DS.L 1
oldkey:         DS.L 1
oldtimerb:      DS.L 1
oldstack:       DS.L 1
oldpalette:     DS.L 8
oldscreen:      DS.W 1
vsync_count:    DS.L 1
old_sr:         DS.W 1
                ;ENDPART

                ;PART 'Stack'
                DS.B 512        ; 512 Bytes Stack
stack:
                ;ENDPART

scroll_buffer:  DS.B 16000*2    ; Platz fÅr zwei 2plane Scrollbuffer
scroll_help_buff:DS.L 200       ; dort kommt erste Zeile hin

                ;PART 'Screens'
                DS.B 512        ; wegen unteren 8 Bits des Screens
screen_base:    DS.B 29*160*2
                DS.B 201*160*4  ; Platz fÅr 4 groûe Screens

                ;ENDPART

logo_preshift_buffer:
                DS.B 32000*8    ; hier kommt preshiftes Logo rein

bss_ende:       END
