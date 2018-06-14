; ----------------------------------------------------------------------------
; - 06.11.1995 20:30 RxT Bernd HÅbenett                                      -
; -                                                                          -
; - Ich habe eben die Werbung fÅr Dosen aus Nixdorf gesehen. Das einzigste   -
; - was daran gut war, war die grafische Wiedergabe eines Audio-Signals.     -
; - 1ter Gedanke war auch haben wollen.                                      -
; - 2ter Gedanke machs dir selber.                                           -
; - et voila.                                                                -
; -                                                                          -
; - Version 4 von SOUND WATCH arbeitet in 320x200 Pixel in 16 Farben.        -
; - ACHTUNG: Seit dem 05.05.1996 arbeitet dieses Programm in 256 Farben.     -
; -                                                                          -
; - 07.04.1996 13:25 Ich werde wohl Teile des EDITION-Systems verwenden.     -
; -            15:36 Die Routine lÑuft.                                      -
; -            16:22 Das Ñndern von 256 auf 16 Farben war eine Sache von ein -
; -                  paar Minuten. Damit steht jetzt fÅr jede Farbtiefe eine -
; -                  Sound Watch Routine zu verfÅgung.                       -
; -            20:26 Kleine optimierung was das Bit-shifting betrifft.       -
; - 08.04.1996 12:53 Die Punktansteuerung (Bit-Shifting) so verÑndert das    -
; -                  die ansteuerung von 2 Planes vereinfacht wird.          -
; -                  Plane 0+1 werden von den Kurven verwendet.              -
; -            14:10 Plane 2+3 fÅr die Kugeln. Eventuell unten noch eine     -
; -                  Scroll-Line in 16 Farben.                               -
; - 09.04.1996 20:45 Die Kugeln sind da, nur nicht in der richtigen Farbe.   -
; - 10.04.1996 18:06 Die manipulation des SHIFT-REGISTERS $FFFF8265 im HBI   -
; -                  kînnte auch zu einem Copper-Effekt fÅhren.              -
; - 17.04.1996 19:48 Genau das klappt. Ich hatte am Anfang einige Probleme   -
; -                  mit der Syncronisation weil ich im VBI vergessen hatte  -
; -                  Timer B zu stoppen.                                     -
; - 23.04.1996 21:41 Paletten Konverter aus der 4Ktro integriert.            -
; -                  Klappt irgendwie noch nicht.                            -
; - 03.05.1996 19:54 Back again. Mal sehen wie es heute klappt.              -
; -            22:25 Endlich klappt die Farbgebung.                          -
; - 04.05.1996 08:15 An der Scroll-Line weitermachen.                        -
; - 05.05.1996 18:58 Die Zeichen darstellung klappt. Wenn des Shift-Register -
; -                  einen Wert ungleich 0 hat Ñndert sich auch die Zeilen-  -
; -                  lÑnge.                                                  -
; -            19:53 Bild-Stîrungen durch die manipulation der Farb-Register -
; -                  im HBI. Hier kînnte es helfen ST-Low als Video Betriebs--
; -                  art zu verwenden und damit auch die alten Farbregister. -
; -            22:02 Jetzt ist Schluû mit Lustig. Das Programm ist komplett  -
; -                  auf 256 Farben umgeschrieben.                           -
; - 06.05.1996 20:58 Das Darstellungsproblem der Text-Routine ist behoben.   -
; - 07.05.1996 22:48 Das Scroll-System ist im VBI + HBI.                     -
; - 08.05.1996 20:19 Die Zeichenasugabe funktioniert. Mit dem Sequenzer fÅr  -
; -                  die Scroll-Line angefangen.                             -
; -            21:37 Die Scroll-Line ist fertig. Jetzt nur noch die Farbe    -
; -                  Ñndern und viel Text schreiben.                         -
; -            21:44 Die Farben stimmen nun auch.                            -
; - 12.05.1996 22:45 Um das Programm zu verlassen muû jetzt die Leertaste    -
; -                  gedrÅckt werden. Sinn des ganzen soll es einmal werden  -
; -                  Åber andere Tasten das Programm zu steuern.             -
; - 13.05.1996 22:22 Die ALTERNATE-Taste startet den Stroboskop-Effekt.      -
; ----------------------------------------------------------------------------

cnecin          EQU 8
logbase         EQU 3
super           EQU 32
vsync           EQU 37

zeilen          EQU 1
hbivec          EQU $0120       ; Horizontal-Blanking-Interrupt-Vector
vbivec          EQU $70         ; Vertical-Blanking-Interrupt-Vector
mkbvec          EQU $0118       ; Mouse/Keyboard-Interrupt-Vector
iera            EQU $FFFA07     ; Interrupt-Enable-Register A
ierb            EQU $FFFA09     ; interrupt-Enable-Register B
isra            EQU $FFFA0F     ; Interrupt-Service-Register A
imra            EQU $FFFA13     ; Interrupt-Mask-Register A
tbcr            EQU $FFFA1B     ; Timer B Control-Register
tbdr            EQU $FFFA21     ; Timer B Data-Register


start:          DC.W $A00A

                pea     0
                move.w  #super,-(SP)
                trap    #1
                addq.l  #6,SP
                move.l  D0,ssp

                move.w  #2,-(SP)        ; Bildschirmadressen holen
                trap    #14
                addq.l  #2,SP
                move.l  D0,oldphys      ; Bildschirmadresse in oldphys speichern
                move.w  #3,-(SP)
                trap    #14
                addq.l  #2,SP
                move.l  D0,oldlog

                move.l  #bild+256,D0    ; Neue Video Adresse
                and.l   #$FFFFFF00,D0
                move.l  D0,buffscr

                move.b  D0,$FFFF820D
                lsr.l   #8,D0
                move.b  D0,$FFFF8203
                lsr.l   #8,D0
                move.b  D0,$FFFF8201

                bsr     Save_System

                lea     Videl_320_200_256,A0
                bsr     Set_Res

                lea     $FFFF9800,A0
                move.w  #3,D0
line_color:     clr.l   (A0)+
                move.l  #$90600050,(A0)+
                move.l  #$90700050,(A0)+
                move.l  #$90800050,(A0)+
                dbra    D0,line_color

; Konvertieren der Farb-Palette fÅr die Kugeln
; und laden der Paletten Register
                lea     kugel_farbe,A0  ; Konvertiert die ST-Kompatible
                lea     $FFFF9800,A1    ; 512 Farbpalette in die
                move.l  #3,D1           ; Falcon030/TT-Kompatible mit
pal_conv:       clr.l   D0              ; 262144 Farben
                move.w  (A0)+,D0
                ror.l   #7,D0
                lsl.w   #4,D0
                rol.l   #4,D0
                lsl.w   #4,D0
                swap    D0
                lsr.w   #8,D0
                move.l  D0,(A1)
                lea     16(A1),A1
                dbra    D1,pal_conv

; Konvertieren der Farb-Palette fÅr den Zeichensatz
; und laden der Paletten Register
                lea     newfont+2,A0
                lea     $FFFF9800,A1    ; 512 Farbpalette in die
                move.l  #15,D1          ; Falcon030/TT-Kompatible mit
pal_conv_2:     clr.l   D0              ; 262144 Farben
                move.w  (A0)+,D0
                ror.l   #7,D0
                lsl.w   #4,D0
                rol.l   #4,D0
                lsl.w   #4,D0
                swap    D0
                lsr.w   #8,D0
                move.l  D0,(A1)
                lea     64(A1),A1
                dbra    D1,pal_conv_2

                move.w  #0,$FFFF820E    ; Offset bis zur nÑchsten Zeile

                movea.l buffscr,A1
                move.w  #10,D2
balls_loop_1:   lea     kugel_daten,A0
                move.w  #7,D0           ; 8 Zeilen
balls_loop_2:   move.w  (A0)+,D1
                movep.w D1,4(A1)
                movep.w D1,20(A1)
                movep.w D1,36(A1)
                movep.w D1,52(A1)
                movep.w D1,68(A1)
                movep.w D1,84(A1)
                movep.w D1,100(A1)
                movep.w D1,116(A1)
                movep.w D1,132(A1)
                movep.w D1,148(A1)
                movep.w D1,164(A1)
                movep.w D1,180(A1)
                movep.w D1,196(A1)
                movep.w D1,212(A1)
                movep.w D1,228(A1)
                movep.w D1,244(A1)
                movep.w D1,260(A1)
                movep.w D1,276(A1)
                movep.w D1,292(A1)
                movep.w D1,308(A1)
                lea     320(A1),A1      ; nÑchste Zeile
                dbra    D0,balls_loop_2
                lea     2560(A1),A1
                dbra    D2,balls_loop_1

; LookUp-Tabelle fÅr das VBI-Oszi
                lea     s_lookup(PC),A0
                clr.l   D0
gen_lookup:     move.l  D0,D1
                add.b   #128,D1
                lsr.w   #1,D1
                mulu    #320,D1         ; Bytes pro Zeile = 320
                move.l  D1,(A0)+
                addq.l  #1,D0
                cmp.l   #256,D0
                bne.s   gen_lookup


; ----------------------------------------------------
; -   Konverter von ASCII->Interner EDITION-Code     -
; - Der Konverter arbeitet nur mit Groû-Buchstaben.  -
; ----------------------------------------------------

ascii_konv:     lea     text_out,A2     ; Platz fÅr den Edition-Code
                lea     text_in,A0      ; Platz fÅr den ASCII-Code
asc_loop:       cmpi.l  #0,(A0)         ; Auf End-Kennung testen
                beq.s   konv_exit       ; Ja, dann abbrechen
                move.b  (A0)+,D3        ;
                move.w  #49,D1
                lea     asc_tab,A1
asc_go_on:      move.l  (A1)+,D2
                cmp.b   D2,D3
                beq.s   asc_hit
                dbra    D1,asc_go_on
                bra     no_hit
asc_hit:        swap    D2
                move.b  D2,(A2)+
no_hit:         jmp     asc_loop
konv_exit:      move.b  #255,(A2)+      ; Endkennung an ASCII anhÑngen


; Lîschen des Sound-Puffers
                lea     live_puffer,A0
                move.l  #live_ende,D0
sou_puff_clear: move.l  #0,(A0)+
                cmp.l   A0,D0
                bne.s   sou_puff_clear

; Ab hier wird das Sound-Sub-System des Falcon030 initialisiert

                move.w  #1,-(SP)        ; 1 = Reset
                move.w  #140,-(SP)      ; XBIOS(140) = SndStatus
                trap    #14
                addq.l  #4,SP

                move.w  #$40,D0         ; 00000000xx000000
                or.w    D0,$FFFF8920    ; Betriebsart (Stero/Mono/8Bit/16Bit)

                move.w  #$02,D0         ; 00000000000000xx
                or.w    D0,$FFFF8936    ; Quelle fÅr den Addierer (2=Multiplexer)

                move.w  #$00,D0         ; 000000xx00000000
                or.w    D0,$FFFF8938    ; Quelle fÅr den DA-Wandler (0=Mikrofon)

; -------------------------------------------------------------------------
; - 03.03.1994 14:30 - Bernd HÅbenett                                     -
; - Das Verfahren mit dem   MOVEP.L D0,1(A1)  ist eine heikle wenn auch   -
; - schnelle Angelegenheit. Der Befehl transportiert (Long) immer 4 Bytes -
; - aber es werden nur 3 Bytes benîtigt. Beim setzen der Anfangsadresse   -
; - landet das 4. Byte auf der Adresse $FFFF8908. Diese Adresse enthÑlt   -
; - das High-Byte des DMA-Sound Wiedergabe/Aufnahme ZÑhlers. Probleme gibt-
; - das nur deshalb nicht weil diese Adresse nur von der DMA verÑndert    -
; - wird. Beim setzen der Endadresse muû man bei der Adresse $FFFF890C    -
; - anfangen da die Adresse $FFFF8914 nicht existiert und so ein Zugriff  -
; - auf diese Adresse fÅr bombige Stimmung sorgt (Busfehler).             -
; -------------------------------------------------------------------------

                bset    #7,$FFFF8901    ; Aufnahmepuffer
                move.l  #live_puffer,D0 ; Anfangsadr. des Sound-Puffers
                lea     $FF8902,A1
                lsl.l   #8,D0
                movep.l D0,1(A1)
                move.l  #live_ende,D0   ; Endadr. des Sound-Puffers
                lea     $0A(A1),A1      ; $FF890E
                movep.l D0,1(A1)

                bclr    #7,$FFFF8901    ; Wiedergabe
                move.l  #live_puffer,D0 ; Anfangsadr. des Sound-Puffers
                lea     $FF8902,A1
                lsl.l   #8,D0
                movep.l D0,1(A1)
                move.l  #live_ende,D0   ; Endadr. des Sound-Puffers
                lea     $0A(A1),A1      ; $FF890E
                movep.l D0,1(A1)

                move.w  #$00,D0         ; 000000xx00000000
                or.w    D0,$FFFF8920    ; AufnahmekanÑle (0=1 Kanal)

                move.w  #$00,D0         ; 000000xx00000000
                or.w    D0,$FFFF8936    ; WiedergabekanÑle (0=1 Kanal)

                move.w  #$00,D0         ; 00xx000000000000
                or.w    D0,$FFFF8920    ; Welcher Kanal Åber DA-Wandler (0=1)

; Multiplexer Verbindung zwischen ADC und DMA-Aufnahme schalten
; Noch keine Lust gehabt nach den Hardware-Adressen zu suchen. :-(

                move.w  #1,-(SP)        ; 1 = Protokoll (kein Handshake)
                move.w  #2,-(SP)        ; 2 = Sample-Frequenz (33880 Hz)
                move.w  #0,-(SP)        ; 0 = Takt (intern 25.175 MHz)
                move.w  #1,-(SP)        ; 1 = EmpfÑnger (DMA-Aufnahme)
                move.w  #3,-(SP)        ; 3 = Sender (ADC)
                move.w  #139,-(SP)      ; XBIOS(139) = DevConnect
                trap    #14
                adda.l  #12,SP

; Multiplexer Verbindung zwischen DMA-Wiedergabe und DAC schalten

                move.w  #1,-(SP)        ; 1 = Protokoll (kein Handshake)
                move.w  #2,-(SP)        ; 1 = Sample-Frequenz (33880 Hz)
                move.w  #0,-(SP)        ; 0 = Takt (intern 25.175 MHz)
                move.w  #8,-(SP)        ; 8 = EmpfÑnger (DAC)
                move.w  #0,-(SP)        ; 0 = Sender (DMA-Wiedergabe)
                move.w  #139,-(SP)      ; XBIOS(139) = DevConnect
                trap    #14
                adda.l  #12,SP

; Aufnahme/Wiedergabe starten
                move.w  $FFFF8900,D0
                and.w   #$FF00,D0
                or.w    #%0,D0
                move.w  D0,$FFFF8900
                or.w    #%110011,D0     ; Normal = %110011
                move.w  D0,$FFFF8900
; %110011 = Aufnahme und Wiedergabe im Loop-Modus
; %010011 = Einmal Aufnehmen und Wiedergabe im Loop-Modus
; %010000 = Einmal Aufnehmen
; %000001 = Einmal Wiedergeben
; %000011 = Wiedergabe im Loop-Modus

; Volume Control beginnt hier
                andi.w  #$F00F,$FFFF893A ; Einstellungen lîschen
                andi.w  #$FF00,$FFFF8938 ; Einstellungen lîschen
                move.w  #$00,D0         ; 0000xxxx00000000
                or.w    D0,$FFFF893A    ; AbschwÑchung linker Ausgang = 0
                move.w  #$00,D0         ; 00000000xxxx0000
                or.w    D0,$FFFF893A    ; AbschwÑchung rechter Ausgang = 0
                move.w  #$40,D0         ; 00000000xxxx0000
                or.w    D0,$FFFF8938    ; VerstÑrkung linker Eingang = 10
                move.w  #$04,D0         ; 000000000000xxxx
                or.w    D0,$FFFF8938    ; VerstÑrkung rechter Eingang = 10

                move.w  #$FFFF,redraw_off
                move.l  #hbi,hbivec
                move.l  vbivec,oldvbi+2
                move.l  #vbi,vbivec
                andi.b  #$DF,ierb
                ori.b   #1,iera
                ori.b   #1,imra

; ....warten....

wait_for_space: cmpi.b  #$39,$FFFFFC02
                bne.s   wait_for_space

; ...und tschÅû.
                move.l  oldvbi+2,vbivec
                andi.b  #$FE,iera
                ori.b   #$20,ierb
                move.w  $FFFF8900,D0    ; Soundsystem stoppen
                and.w   #$FF00,D0
                or.w    #%0,D0          ; Wiedergabe/Aufnahme stoppen
                move.w  D0,$FFFF8900

raus:           bsr     restore_system
                bsr     wait_vsync
                move.l  oldlog,D0
                move.b  D0,$FFFF820D
                lsr.l   #8,D0
                move.b  D0,$FFFF8203
                lsr.l   #8,D0
                move.b  D0,$FFFF8201

                move.l  ssp,-(SP)
                move.w  #super,-(SP)
                trap    #1
                addq.l  #6,SP

                clr.w   -(SP)
                trap    #1

; ------------------------------------------
; ------- V B I  -  R O U T I N E ----------
; ------------------------------------------

vbi:            movem.l D0-A4,save_regs
                cmpi.b  #56,$FFFFFC02   ; Scan-Code fÅr die ALTERNATE-Taste
                bne.s   no_strobo
                move.l  strobo,D0
                swap    D0
                move.l  D0,strobo
                ext.l   D0
                move.l  D0,$FFFF9800
                jmp     no_strobo_2
no_strobo:      clr.l   $FFFF9800
no_strobo_2:

;                move.l  #$FFFFFFFF,$FFFF9800

                move.b  #0,$FFFF8265.w  ; Shift-Register auf 0
                move.w  #0,$FFFF820E
                move.b  #0,tbcr         ; Timer B stoppen
                move.b  #175,tbdr       ; in Zeile ... HBI auslîsen
                move.b  #8,tbcr         ; Timer B in Event-Count-Mode

                move.w  #0,$FFFF82C2.w

                cmpi.w  #$FFFF,redraw_off
                beq.s   display

                movea.l buffscr(PC),A1
                lea     8000(A1),A1
                lea     8000(A1),A2
                lea     redraw_buffer,A0
                move.w  #19,D1
clear_loop_1:   move.w  #15,D2
clear_loop_2:   move.l  (A0)+,D0
                clr.w   2(A1,D0.l)
                DC.W $42B1,$0920,$0140 ; CLR.L (160,A1,D0.l)
                DC.W $4271,$0920,$0280 ; CLR.W (320,A1,D0.L)
                move.l  (A0)+,D0
                clr.w   0(A2,D0.l)
                DC.W $42B2,$0920,$0140 ; CLR.L (160,A2,D0.l)
                DC.W $4272,$0920,$0280 ; CLR.W (320,A2,D0.L)
                dbra    D2,clear_loop_2
                adda.l  #16,A1
                adda.l  #16,A2
                dbra    D1,clear_loop_1

display:        movea.l buffscr(PC),A1
                lea     live_puffer,A0
                lea     redraw_buffer(PC),A2
                lea     s_lookup(PC),A4
                lea     8000(A1),A1
                move.w  #19,D3          ; 320 Pixel / 16 = 20
                move.l  #$80008000,D2   ; Bit 15+31 setzen
disp_loop_1:    clr.w   D0              ; Kanal 1
                move.b  (A0),D0
                DC.W $2034,$0400 ; MOVE.L (A4,D0.W*4),D0
                move.l  D0,(A2)+        ; im Redraw Buffer speichern
                or.w    D2,2(A1,D0.l)   ; Punkt setzen
                DC.W $85B1,$0920,$0140 ; OR.L D2,(160,A1,D0.L)
                DC.W $8571,$0920,$0280 ; OR.W D2,(320,A1,D0.L)

                clr.w   D0              ; Kanal 2
                move.b  2(A0),D0
                DC.W $2034,$0400 ; MOVE.L (A4,D0.W*4),D0
                move.l  D0,(A2)+        ; im Redraw Buffer speichern
                DC.W $8571,$0920,$1F40 ; OR.W D2,(8000,A1,D0.L)
                DC.W $85B1,$0920,$2080 ; OR.L D2,(8320,A1,D0.L)
                DC.W $8571,$0920,$21C0 ; OR.W D2,(8640,A1,D0.L)

                addq.l  #4,A0
                ror.l   #1,D2           ; nÑchstes Bit = Punkt
                bcc.s   disp_loop_1     ; wiederholen solange wie C=0
                adda.l  #16,A1
                dbra    D3,disp_loop_1

; Scroll_line
                clr.l   D0
                move.b  line_shift,D0
                and.b   #%1111,D0       ; nur 4 Bit gÅltig
                cmp.b   #0,D0
                beq.s   next_char
                move.w  #8,line_offset
                jmp     same_char

next_char:      move.w  #16,line_offset
                movea.l buffscr,A0
                adda.l  #56008,A0       ;175*320+8 = Ziel-Adresse
                move.w  #22*25-1,D0     ; 25 Zeilen scrollen
scroll_16:      move.l  16(A0),0(A0)
                move.l  20(A0),4(A0)
                lea     16(A0),A0       ; nÑchster 16er Block
                dbra    D0,scroll_16

; Zeichenausgabe
                lea     newfont+34,A2
                lea     text_out,A0
                clr.l   D0
                move.w  char_index,D1
                move.b  0(A0,D1.w),D0
                cmp.b   #255,D0
                bne.s   char_go_on
                clr.w   D1
                move.w  D1,char_index
                move.b  0(A0,D1.w),D0
char_go_on:     mulu    #400,D0
                adda.l  D0,A2

                movea.l buffscr,A4
                adda.l  #56328,A4
                move.l  toggle,D0
                cmp.w   #$FFFF,D0
                beq.s   char_2

                move.w  #24,D5
char_copy_1:    move.l  (A2),(A4)
                move.l  4(A2),4(A4)
                adda.l  #16,A2
                lea     352(A4),A4
                dbra    D5,char_copy_1
                jmp     char_ready

char_2:         move.w  #24,D5
                adda.l  #8,A2
char_copy_2:    move.l  (A2),(A4)
                move.l  4(A2),4(A4)
                adda.l  #16,A2
                lea     352(A4),A4
                dbra    D5,char_copy_2
                addi.w  #1,char_index   ; jetzt erst nÑchster Buchstabe
char_ready:     swap    D0              ; toggle toggeln
                move.l  D0,toggle       ; und speichern
same_char:      clr.w   redraw_off
                movem.l save_regs(PC),D0-A4

                clr.l   $FFFF9800

oldvbi:         jmp     $FFFFFFFF

; ------------------------------------------
; -------- H B I  -  R O U T I N E ---------
; ------------------------------------------

hbi:            move.b  line_shift,$FFFF8265.w ; Shift-Register verÑndern
                move.w  line_offset,$FFFF820E ; Zeilen-Offset verÑndern
;                move.w  #1,$FFFF82C2.w  ; 100 Zeilen = Double Scan
                addi.b  #2,line_shift
                andi.b  #$FE,isra
                rte

; ------------------------------------------
; ----- A U F   V S Y N C   W A R T E N ----
; ------------------------------------------

wait_vsync:     move.l  D0,-(SP)
                move.l  $0462,D0
wait_wait_x:    cmp.l   $0462,D0
                beq.s   wait_wait_x
                move.l  (SP)+,D0
                rts

; ---------------------------------------------
; -------- S E T  V I D E O  M O D E ----------
; ---------------------------------------------
; Parameter:
;             A0.L : Adresse der Betriebsart
;                      (aus der Tabelle)
; ---------------------------------------------

Set_Res:        move.b  #2,$FFFF820A.w  ; Horloge Interne
                clr.b   $FFFF8265.w     ; DÇcalage Pixel Nul
                addq.l  #4,A0
                move.w  (A0)+,$FFFF820E.w ; Offset bis zur nÑchsten Zeile (Words)
                move.w  (A0)+,$FFFF8210.w ; LÑnge der sichtbaren Zeile (Words)
                move.w  (A0)+,D0        ; RÇsolution ST
                move.w  (A0)+,D1        ; RÇsolution FALCON

                move.w  D1,$FFFF8266.w  ; RÇsolution FALCON
                tst.w   (A0)+
                beq.s   FalconRez
                move.b  D0,$FFFF8260.w  ; RÇsolution ST
                move.w  -8(A0),$FFFF8210.w ; Largeur d'une ligne en mots
FalconRez:
;                btst    #7,$FFFF8006.w  ; Ecran VGA ?
;                beq.s   R_Ok            ; Si non,saut...
;                adda.w  #16*2,A0
R_Ok:           move.w  (A0)+,$FFFF8282.w ; HHT-Synchro
                move.w  (A0)+,$FFFF8284.w ; Fin du dÇcodage de la ligne
                move.w  (A0)+,$FFFF8286.w ; DÇbut du dÇcodage de la ligne
                move.w  (A0)+,$FFFF8288.w ; Overscan links
                move.w  (A0)+,$FFFF828A.w ; Overscan rechts
                move.w  (A0)+,$FFFF828C.w ; HSS-Synchro
                move.w  (A0)+,$FFFF828E.w ; HFS
                move.w  (A0)+,$FFFF8290.w ; HEE
                move.w  (A0)+,$FFFF82A2.w ; VFT-Synchro
                move.w  (A0)+,$FFFF82A4.w ; Fin du dÇcodage de l'image
                move.w  (A0)+,$FFFF82A6.w ; DÇbut du dÇcodage de l'image
                move.w  (A0)+,$FFFF82A8.w ; Overscan oben
                move.w  (A0)+,$FFFF82AA.w ; Overscan unten
                move.w  (A0)+,$FFFF82AC.w ; VSS-Synchro
                move.w  (A0)+,$FFFF82C0.w ; Indique rÇsolution FALCON
                move.w  (A0),$FFFF82C2.w ; Informations rÇsolution
                rts

; ---------------------------------------------
; ----------  V I D E O  S A V E --------------
; ---------------------------------------------

Save_System:    lea     Old_System,A0
                move.b  $FFFF8007.w,(A0)+ ; Configuration 68030
                move.b  $FFFF820A.w,(A0)+ ; Synchronisation vidÇo
                move.w  $FFFF820E.w,(A0)+ ; Offset pour prochaine ligne
                move.w  $FFFF8210.w,(A0)+ ; Largeur d'une ligne en mots
                move.b  $FFFF8260.w,(A0)+ ; RÇsolution ST
                move.b  $FFFF8265.w,(A0)+ ; DÇcalage Pixel
                move.w  $FFFF8266.w,(A0)+ ; RÇsolution FALCON
                move.w  $FFFF8282.w,(A0)+ ; HHT-Synchro
                move.w  $FFFF8284.w,(A0)+ ; Fin du dÇcodage de la ligne
                move.w  $FFFF8286.w,(A0)+ ; DÇbut du dÇcodage de la ligne
                move.w  $FFFF8288.w,(A0)+ ; Overscan gauche
                move.w  $FFFF828A.w,(A0)+ ; Overscan droit
                move.w  $FFFF828C.w,(A0)+ ; HSS-Synchro
                move.w  $FFFF828E.w,(A0)+ ; HFS
                move.w  $FFFF8290.w,(A0)+ ; HEE
                move.w  $FFFF82A2.w,(A0)+ ; VFT-Synchro
                move.w  $FFFF82A4.w,(A0)+ ; Fin du dÇcodage de l'image
                move.w  $FFFF82A6.w,(A0)+ ; DÇbut du dÇcodage de l'image
                move.w  $FFFF82A8.w,(A0)+ ; Overscan haut
                move.w  $FFFF82AA.w,(A0)+ ; Overscan bas
                move.w  $FFFF82AC.w,(A0)+ ; VSS-Synchro
                move.w  $FFFF82C0.w,(A0)+ ; Reconnaissance ST/FALCON
                move.w  $FFFF82C2.w,(A0)+ ; Informations rÇsolution

                lea     $FFFF8240.w,A1  ; Palette ST
                moveq   #8-1,D0         ; 8 longs...
Save_ST_Palette:
                move.l  (A1)+,(A0)+     ; Sauve 2 couleurs
                dbra    D0,Save_ST_Palette ; Boucle les 16 mots !

                lea     $FFFF9800.w,A1  ; Palette FALCON
                move.w  #256-1,D0       ; 256 longs...
Save_FALCON_Palette:
                move.l  (A1)+,(A0)+     ; Sauve 1 couleur
                dbra    D0,Save_FALCON_Palette ; Boucle les 256 longs !
                rts

; --------------------------------------------
; ------  V I D E O   R E S T O R E ----------
; --------------------------------------------

restore_system: move    #$2700,SR       ; Interrupts sperren
                lea     Old_System,A0   ; Espace de sauvegarde
                move.b  (A0)+,$FFFF8007.w ; Configuration 68030
                move.b  (A0)+,$FFFF820A.w ; Video-Syncronisation
                move.w  (A0)+,$FFFF820E.w ; Offset pour prochaine ligne
                move.w  (A0)+,$FFFF8210.w ; Largeur d'une ligne en mots
                move.b  (A0)+,D0        ; RÇsolution ST
                move.b  (A0)+,$FFFF8265.w ; DÇcalage Pixel
                move.w  (A0)+,D1        ; RÇsolution FALCON
                move.w  (A0)+,$FFFF8282.w ; HHT-Synchro
                move.w  (A0)+,$FFFF8284.w ; Fin du dÇcodage de la ligne
                move.w  (A0)+,$FFFF8286.w ; DÇbut du dÇcodage de la ligne
                move.w  (A0)+,$FFFF8288.w ; Overscan gauche
                move.w  (A0)+,$FFFF828A.w ; Overscan droit
                move.w  (A0)+,$FFFF828C.w ; HSS-Synchro
                move.w  (A0)+,$FFFF828E.w ; HFS
                move.w  (A0)+,$FFFF8290.w ; HEE
                move.w  (A0)+,$FFFF82A2.w ; VFT-Synchro
                move.w  (A0)+,$FFFF82A4.w ; Fin du dÇcodage de l'image
                move.w  (A0)+,$FFFF82A6.w ; DÇbut du dÇcodage de l'image
                move.w  (A0)+,$FFFF82A8.w ; Overscan haut
                move.w  (A0)+,$FFFF82AA.w ; Overscan bas
                move.w  (A0)+,$FFFF82AC.w ; VSS-Synchro
                move.w  (A0)+,$FFFF82C0.w ; Reconnaissance ST/FALCON
                move.w  (A0)+,$FFFF82C2.w ; Informations rÇsolution
                move.w  D1,$FFFF8266.w  ; Fixe rÇsolution FALCON...
                btst    #0,$FFFF82C0.w  ; RÇsolution FALCON ?
                bne.s   Falcon_Rez      ; Si oui,saut !
                move.b  D0,$FFFF8260.w  ; Fixe rÇsolution ST...
Falcon_Rez:     lea     $FFFF8240.w,A1  ; ST-Farbpalette restaurieren
                moveq   #7,D0           ; 8 Langwîrter...
Rest_ST_Palette:
                move.l  (A0)+,(A1)+     ; immer 2 Farben auf einmal
                dbra    D0,Rest_ST_Palette

                lea     $FFFF9800.w,A1  ; FALCON-Farbpalette restaurieren
                move.w  #255,D0         ; 256 Langwîrter
Rest_FALCON_Palette:
                move.l  (A0)+,(A1)+     ; eine Farbe nach der anderen
                dbra    D0,Rest_FALCON_Palette
                move    #$2000,SR       ; Interrupts freigeben
                rts

                DATA
Videl_320_200_256:
                DC.L 320*200+256 ; GÇnÇral
                DC.W 0,160,0,$10
                DC.W 0          ; Flag Ordre
                DC.W 254,203,39,28,125,216,0,0 ; RVB
                DC.W 625,613,47,127,527,619
                DC.W $0181,%0
                EVEN
kugel_farbe:    DC.W $00,$13,$23,$34 ; $00,$310,$420,$540
kugel_daten:    DC.B $24,$18,$0C,$7E
                DC.B $B7,$4E,$58,$E7
                DC.B $4C,$F3,$E1,$7E
                DC.B $32,$7C,$24,$18
                EVEN
; Konvertierungstabelle von ASCII zum internen Code von EDITION
; S_WATCH4 benutzt nicht ganz zufÑllig den selben Zeichensatz wie EDITION
asc_tab:        DC.W 0,65,1,66,2,67,3,68,4,69,5,70,6,71,7,72,8,73,9,74
                DC.W 10,75,11,76,12,77,13,78,14,79,15,80,16,81,17,82,18,83
                DC.W 19,84,20,85,21,86,22,87,23,88,24,89,25,90,26,33,27,63
                DC.W 28,58,29,59,30,48,31,49,32,50,33,51,34,52,35,53,36,54
                DC.W 37,55,38,56,39,57,40,34,41,40,42,41,43,44,44,45,45,46
                DC.W 46,39,49,32,49,13
                EVEN
strobo:         DC.L $FFFF0000
strobo_count:   DC.W 2
toggle:         DC.L $FFFF0000
line_offset:    DC.W 16
char_index:     DC.W 0
line_shift:     DC.B 0
                EVEN
text_in:        IBYTES 'PARTY.TXT'
                DC.L 0          ; Endkennung
                EVEN
newfont:        IBYTES 'NEWFONT.DAT' ; Zeichensatz
                BSS
                DS.B 256
ssp:            DS.L 1
oldlog:         DS.L 1
oldphys:        DS.L 1
oldmode:        DS.L 1
Old_System:     DS.L 500        ; Buffer fÅr altes System
buffscr:        DS.L 1
redraw_off:     DS.W 1
save_regs:      DS.L 64         ; Register sichern
s_lookup:       DS.L 256        ; LookUp-Tabelle
redraw_buffer:  DS.L 1280       ; Alter Offset 320+320 und 2 KanÑle
                DS.W 1280       ; Alter Farbwert 320+320 und 2 KanÑle
live_puffer:    DS.W 640        ; 320 16-Bit Stereosamples * x
live_ende:
                EVEN
text_out:       DS.W 50000      ; 100 KB fÅr den Text sollten reichen
                EVEN
                DS.B 256
bild:           DS.L 38400
                DS.L 38400
                DS.L 38400
picture:        DS.L 38400
                DS.L 38400
                DS.L 38400
                END
