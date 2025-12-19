********************************************************************************
*                                                                              *
*                                UNEMEFDA V 1.0                                *
*                                --------------                                *
*                Und Noch Ein Monochrom-Emulator FÅr Den Atari                 *
*                                                                              *
*                          (c) 1992 by Harald Fîrster                          *
*                                                                              *
*                                                                              *
*        konvertiert die hohe ST-Auflîsung in die mittlere ST-Auflîsung        *
*                                                                              *
*                     geschrieben mit dem TurboAss V 1.7.2                     *
*                                                                              *
********************************************************************************


BIOS            EQU 13
XBIOS           EQU 14
GEMDOS          EQU 1
ESC             EQU 27


*******************************************************************************
*                              System-Variablen                               *
*******************************************************************************

TRAP_14         EQU $000000B8   ;Zeiger auf Xbios
_200_Hz_SYS     EQU $00000114   ;MFP-Interrupt 5 fÅr Systemtimer-Interrupt
FLOCK           EQU $0000043E   ;wenn nicht null, ist die DMA aktiv
_V_BAS_AD       EQU $0000044E   ;Zeiger auf Anfang des log. Bildschirms
VBLSEM          EQU $00000452   ;Eins: VB-Handler aktiviert
NVBLS           EQU $00000454   ;Maximalanzahl installierbarer VBlank-Prozesse
_VBLQUEUE       EQU $00000456   ;Zeiger auf Zeigertabelle der VBlank-Prozesse
SWV_VEC         EQU $0000046E   ;Routine bei énderung der Auflîsung
SAVPTR          EQU $000004A2   ;Zeiger auf Bios-Zwischenspeicher
PRT_CNT         EQU $000004EE   ;ZÑhler fÅr ALT-HELP-TastendrÅcke
SCR_DUMP        EQU $00000502   ;Zeiger auf Hardcopy-Routine
_P_COOKIES      EQU $000005A0   ;Zeiger auf Cookie Jar


*******************************************************************************
*                              Hardware-Register                              *
*******************************************************************************

VID_BAS_HIGH    EQU $FFFF8201   ;Video Base Register High-Byte
VID_BAS_MID     EQU $FFFF8203   ;Video Base Register Mid-Byte
SYNC_MODE       EQU $FFFF820A   ;Sync Mode Register
COL_REG_0       EQU $FFFF8240   ;Farbregister 0
SHIFT_MODE      EQU $FFFF8260   ;Shift Mode Register
SRC_X_INC       EQU $FFFF8A20   ;Source X Increment Register des Blitters
LINE_NUM        EQU $FFFF8A3C   ;Line Number Register


********************************************************************************

                TEXT

start:          bra     init            ;UNEMEFDA initialisieren


********************************************************************************
*                                                                              *
*                           VERTICAL-BLANK-INTERRUPT                           *
*                                                                              *
********************************************************************************

vbl_interrupt:  lea     mid_byte(PC),A5 ;
                move.b  (A5)+,VID_BAS_MID.w ;Mid-Byte ins Video-Base-Register
                move.b  (A5)+,VID_BAS_HIGH.w ;High-Byte dito
                subq.w  #1,(A5)+        ;ZÑhler dekrementieren
                bpl.s   int_ende        ;wenn >= 0, dann int_ende

                move.w  (A5)+,-4(A5)    ;Verzîgerungswert in den ZÑhler
                tst.w   (A5)+           ;Blitter-Modus aktiv?
                bne.s   cpu             ;wenn nein, dann CPU-Modus


********************************************************************************
*                                BLITTER-MODUS                                 *
********************************************************************************

blitter:        btst    #7,LINE_NUM.w   ;Blitter aktiv?
                bne.s   cpu             ;wenn ja, dann CPU-Modus nehmen
                lea     src_xinc(PC),A5 ;Zeiger auf Blitter-Daten
                lea     SRC_X_INC.w,A6  ;und die Hardware-Register
                move.l  (A5)+,(A6)+     ;alle
                move.l  (A5)+,(A6)+     ;Daten
                move.l  (A5)+,(A6)+     ;in
                move.l  (A5)+,(A6)+     ;die
                move.l  (A5)+,(A6)+     ;Register
                move.l  (A5)+,(A6)+     ;kopieren
                move.l  (A5)+,(A6)+     ;und den
                move.w  (A5),(A6)       ;Blitter starten

int_ende:       rts                     ;und zurÅck


********************************************************************************
*                                  CPU-MODUS                                   *
********************************************************************************

cpu:            move.w  (A5)+,D2        ;Zeilen-Offset nach D2
                movea.l (A5)+,A6        ;Adresse des Farb-Bildschirm
                movea.l (A5),A5         ;Adresse des s/w-Bildschirms

                moveq   #24,D1          ;25*8 Zeilen konvertieren

DIS             SET 0           ;Adressdistanz auf 0 setzen

zeile:          REPT 8          ;Block bis ENDR achtmal assemblieren

                adda.w  D2,A5           ;nÑchste Zeile Åberspringen

                movem.w (A5)+,D3-A4     ;10 Worte aus dem s/w-Bildschirm holen
                IF DIS=0        ;wenn DIS noch null ist
                movem.l D3-A4,(A6)      ;wird diese Zeile assembliert
                ELSE
                movem.l D3-A4,DIS(A6)   ;sonst diese mit Adressdistanz
                ENDC            ;Ende mit IF und ELSE

                movem.w (A5)+,D3-A4     ;10 Worte aus dem s/w-Bildschirm holen
                movem.l D3-A4,DIS+40(A6) ;und in den Farb-Bildschirm schreiben

                movem.w (A5)+,D3-A4     ;10 Worte aus dem s/w-Bildschirm holen
                movem.l D3-A4,DIS+80(A6) ;und in den Farb-Bildschirm schreiben

                movem.w (A5)+,D3-A4     ;10 Worte aus dem s/w-Bildschirm holen
                movem.l D3-A4,DIS+120(A6) ;und in den Farb-Bildschirm schreiben

DIS             SET DIS+160     ;Adressdistanz um 160 erhîhen

                ENDR            ;Blockende

                lea     1280(A6),A6     ;Adresse vom Farb-Bildschirm erhîhen
                dbra    D1,zeile        ;wenn nicht fertig, dann noch 'ne Runde
                rts                     ;sonst fertig konvertiert


********************************************************************************
*                                                                              *
*                          200_Hz-SYSTEM-INTERRUPT                             *
*                                                                              *
********************************************************************************

sys_int:        move.w  D0,-(SP)        ;Datenregister retten
                move.w  COL_REG_0.w,D0  ;Hintergrundfarbe nach D0
                cmp.w   paper(PC),D0    ;mit paper vergleichen
                beq.s   sys_end         ;wenn gleich, weiter bei sys_end

                movem.l A0-A1,-(SP)     ;Adressregister retten
                lea     COL_REG_0.w,A0
                lea     paper(PC),A1
                btst    #0,D0           ;Invers-Flag testen
                sne     D0              ;zum Byte erweitern
                ext.w   D0              ;zum Wort erweitern
                move.w  D0,(A0)         ;Hintergrundfarbe ins Farbregister 0
                move.w  (A0)+,(A1)      ;in paper merken
                move.w  D0,(A0)+        ;Hintergrundfarbe ins Farbregister 1
                not.w   D0              ;zur Schreibfarbe machen
                move.w  D0,(A0)+        ;ins Farbregister 2
                move.w  D0,(A0)         ;und ins Farbregister 3
                movem.l (SP)+,A0-A1     ;Adressregister restaurieren

sys_end:        move.w  (SP)+,D0        ;Datenregister restaurieren
                move.l  sys_timer(PC),-(SP) ;Einsprungadresse 200_hz_timer

swv_vec:        move.b  #1,SHIFT_MODE.w ;mittlere Auflîsung
                move.b  syncmode(PC),SYNC_MODE.w ;interne Synchronisation
                rts                     ;und zurÅck


********************************************************************************
*                                                                              *
*                                 ALT-HELP-TASTEN                              *
*                                                                              *
********************************************************************************

alt_help:       lea     screen(PC),A0
                lea     32300(A0),A0
                move.l  SAVPTR.w,2(A0)  ;Zeiger retten
                move.l  A0,SAVPTR.w     ;neuer Bios-Zwischenspeicher

                move.l  #$000BFFFF,-(SP) ;Tastatur-Status
                trap    #BIOS           ;abfragen
                addq.w  #4,SP           ;Stack korrigieren

                cmpi.b  #8,D0           ;ALT+HELP?
                beq     split_screen    ;wenn ja, weiter bei split_screen
                cmpi.b  #10,D0          ;LSHIFT+ALT+HELP?
                beq.s   flock           ;wenn ja, weiter bei flock


********************************************************************************
*                                  HARDCOPY                                    *
********************************************************************************

hardcopy:       movea.l scr_dump(PC),A0 ;sonst Hardcopy-Adresse holen
                jsr     (A0)            ;dort weitermachen
                bra     alt_end         ;und weiter bei alt_end


********************************************************************************
*                       EMULATIONSGESCHWINDIGKEIT éNDERN                       *
********************************************************************************

flock:          tst.w   FLOCK.w         ;DMA aktiv?
                bne     alt_end         ;wenn ja, weiter bei alt_end

change:         clr.w   VBLSEM.w        ;VB-Handler ausschalten
                move.w  blit_enable(PC),D0 ;Blittermode?
                bne.s   go_on           ;wenn nein, weiter bei go_on

blit_test:      btst    #7,LINE_NUM.w   ;Blitter aktiv?
                bne.s   blit_test       ;wenn ja, weiter bei blit_test

go_on:          move.l  color(PC),_V_BAS_AD.w ;Adresse des Farb-Bildschirms
                lea     new_cursor(PC),A0 ;den Cursor nach links oben
                bsr.s   print           ;und die Zeile lîschen

again:          move.l  #$00020002,-(SP) ;Bconin von Konsole (VT-52)
                trap    #BIOS           ;Zeichen einlesen
                addq.w  #4,SP           ;Stack korrigieren
                cmpi.b  #"0",D0         ;Taste kleiner 0?
                bcs.s   again
                cmpi.b  #"9",D0         ;Taste grîûer 9?
                bgt.s   again
                lea     count_amount(PC),A0
                sub.w   #48,D0          ;ASCII minus 48
                move.w  D0,(A0)         ;und in den Speicher
                move.l  mono_org(PC),_V_BAS_AD.w ;Adresse des s/w-Bildschirms
                addq.w  #1,VBLSEM.w     ;VB-Handler einschalten
                lea     old_cursor(PC),A0 ;alte Cursor-Position
                bsr.s   print           ;wieder herstellen
                bra.s   alt_end         ;und weiter bei alt_end

print:          move.b  (A0)+,D0        ;Zeichen nach D0
                beq.s   end_print       ;wenn Stringende, weiter bei end_print
                pea     (A0)            ;Zeiger auf String retten
                move.w  D0,-(SP)        ;auszugebendes Zeichen
                move.l  #$00030002,-(SP) ;Bconout auf Konsole (VT-52)
                trap    #BIOS           ;Zeichen zum Bildschirm
                addq.w  #6,SP           ;Stack korrigieren
                movea.l (SP)+,A0        ;Zeiger auf String restaurieren
                bra.s   print           ;nÑchstes Zeichen holen

end_print:      rts                     ;und zurÅck zum Hauptprogramm


********************************************************************************
*                               SPLITTING-SCREEN                               *
********************************************************************************

split_screen:   lea     mono_org(PC),A0 ;Adresse der Variablen nach A0
                clr.w   D1              ;keine Zeile Åberspringen
                movea.l (A0)+,A1        ;s/w-Bildschirm nach A1
                move.w  (A0),D0         ;Bildausschnitt nach D0
                cmpi.w  #16000,D0       ;schon untere HÑlfte?
                bls.s   next_screen     ;wenn nein, nÑchsten Ausschnitt
                clr.w   D0              ;sonst obere HÑlfte
                moveq   #80,D1          ;eine Zeile Åberspringen
                bra.s   save_cpu        ;und wieder ganzes Bild zeigen

next_screen:    adda.w  D0,A1           ;neuen Ausschnitt einstellen
                add.w   #8000,D0        ;nÑchsten Ausschnitt merken

save_cpu:       move.l  A1,-8(A0)       ;alle neuen Daten
                move.w  D0,(A0)         ;fÅr den
                move.w  D1,-14(A0)      ;CPU-Modus merken

save_blit:      adda.w  D1,A1           ;Zeilen-Offset zum Bildschirm addieren
                addq.w  #2,D1           ;erstes Wort Åberspringen
                addq.w  #4,A0           ;A0 zeigt nun auf src_yinc
                move.w  D1,(A0)+        ;alle neuen Daten fÅr den
                move.l  A1,(A0)         ;Blitter-Modus merken

alt_end:        move.l  32302+screen(PC),SAVPTR.w ;Zeiger restaurieren
                move.w  #-1,PRT_CNT.w   ;normalen Status fÅr ALT-HELP
                rts                     ;und zurÅck


********************************************************************************
*                                                                              *
*                                 XBIOS-PATCH                                  *
*                                                                              *
********************************************************************************

new_xbios:      movea.l SP,A0           ;Stackpointer nach A0
                adda.w  stackframe(PC),A0 ;Pointer korrigieren
                btst    #5,(SP)         ;Aufruf im Supervisor-Modus?
                bne.s   physbase        ;wenn ja, weiter bei physbase
                move    USP,A0          ;sonst User-Stackpointer nach A0


********************************************************************************
*                              PHYSBASE (XBIOS 2)                              *
********************************************************************************

physbase:       move.w  (A0)+,D0        ;Xbios-Funktion nach D0
                cmpi.w  #2,D0           ;ist es Physbase?
                bne.s   getrez          ;wenn nein, auf Getrez testen
                move.l  mono_org(PC),D0 ;sonst s/w-Bildschirm nach D0
                rte                     ;und zurÅck


********************************************************************************
*                               GETREZ (XBIOS 4)                               *
********************************************************************************

getrez:         cmpi.w  #4,D0           ;ist es Getrez?
                bne.s   setscreen       ;wenn nein, auf Setscreen testen
                moveq   #2,D0           ;sonst hohe Auflîsung nach D0
                rte                     ;und zurÅck


********************************************************************************
*                              SETSCREEN (XBIOS 5)                             *
********************************************************************************

setscreen:      cmpi.w  #5,D0           ;ist es Setscreen?
                bne.s   scrdmp          ;wenn nein, auf Scrdmp testen
                move.l  (A0)+,D0        ;logloc Ñndern?
                bmi.s   physloc         ;wenn nein, dann weiter bei set_end
                move.l  D0,_V_BAS_AD.w  ;sonst neue Adresse speichern

physloc:        move.l  (A0),D0         ;physloc Ñndern?
                bmi.s   set_end         ;wenn nein, weiter bei set_end
                lea     mono(PC),A1
                move.w  split(PC),D1    ;Beginn des Bildausschnittes
                ext.l   D1              ;auf 32-bit erweitern
                beq.s   new_screen      ;wenn ganzes Bild, weiter bei new_screen
                sub.w   #8000,D1        ;sonst tatsÑchlichen Beginn nehmen

new_screen:     add.l   D0,D1           ;neue Bildschirmadresse plus split
                move.l  D1,(A1)+        ;diese Adresse in mono
                move.l  D0,(A1)         ;und Bildschirm in mono_org speichern
                move.w  offset(PC),D0   ;Zeilen-Offset nach D0
                ext.l   D0              ;auf 32-bit erweitern
                add.l   D0,D1           ;zur Bildschirmadresse addieren
                move.l  D1,10(A1)       ;und in src_addr merken

set_end:        rte                     ;und zurÅck


********************************************************************************
*                              SCRDMP (XBIOS 20)                               *
********************************************************************************

scrdmp:         cmpi.w  #20,D0          ;ist es Scrdmp?
                bne.s   blitmode        ;wenn nein, weiter bei blitmode
                jsr     alt_help(PC)    ;wegen OMIKRON.BASIC!
                rte                     ;und zurÅck


********************************************************************************
*                              BLITMODE (XBIOS 64)                             *
********************************************************************************

blitmode:       cmpi.w  #64,D0          ;ist es Blitmode?
                bne.s   norm_xbios      ;wenn nein, weiter mit normalem Xbios
                lea     blit_enable(PC),A1
                tst.b   (A1)+           ;Blitter vorhanden?
                beq.s   read            ;wenn ja, weiter bei read
                moveq   #0,D0           ;kein Blitter da
                rte                     ;also zurÅck

read:           move.w  (A0),D1         ;Blitter-Status lesen?
                bmi.s   norm_xbios      ;wenn ja, weiter bei norm_xbios

                sne     D2              ;$00=aus bzw. $FF=ein
                lea     modus(PC),A2

                cmp.w   2(SP),D0        ;Aufruf vom ROM-TOS?
                bcc.s   user            ;wenn ja, weiter bei user
                move.w  D1,(A2)         ;im Desktop eingestellen Modus merken
                bra.s   blit_busy       ;und weiter bei blit_busy

user:           not.b   D2              ;Blitter-Modus umkehren
                bne.s   blit_busy       ;wenn ausschalten, weiter bei blit_busy
                move.w  (A2),(A0)       ;sonst Desktop-Modus auf den Stack
                sne     D2              ;$00=aus bzw. $FF=ein

blit_busy:      btst    #7,LINE_NUM.w   ;ist das busy-bit gesetzt?
                bne.s   blit_busy       ;wenn ja, weiter bei blit_busy

set_blit:       move.b  D2,(A1)         ;Status vom Blitter-Modus eintragen

norm_xbios:     movea.l old_xbios(PC),A0 ;alte Xbios-Adresse laden
                jmp     (A0)            ;und dort weitermachen


********************************************************************************
*                                                                              *
*                                 DATA-BEREICH                                 *
*                                                                              *
********************************************************************************

                DATA

stackframe:     DC.W 6          ;6 = 68000  bzw.  8 >= 68010

paper:          DC.W -1         ;Hintergrundfarbe
syncmode:       DC.W 0          ;Shadow vom Shifter-Register

mid_byte:       DC.B 0          ;mittleres Byte der Bildschirmadresse
high_byte:      DC.B 0          ;hohes Byte der Bildschirmadresse
counter:        DC.W 150        ;ZÑhler fÅr die Bildverzîgerung
count_amount:   DC.W 0          ;Wert der gewÑhlten Verzîgerung
blit_enable:    DC.W -1         ;Blitter-Modus sperren
offset:         DC.W 80         ;0 -> keine bzw. 80 -> eine Zeile Åberspringen
color:          DC.L 0          ;Adresse des Farb-Bildschirms
mono:           DC.L 0          ;des s/w-Bildschirms mit Bildausschnitt
mono_org:       DC.L 0          ;Basisadresse des s/w-Bildschirms
split:          DC.W 0          ;Offset zum nÑchsten Bildausschnitt


********************************************************************************
*                        DATEN FöR DIE BLITTER-REGISTER                        *
********************************************************************************

src_xinc:       DC.W 2          ;s/w-Bildschirm hat eine Bitplane
src_yinc:       DC.W 82         ;2 -> keine bzw. 82 -> eine Zeile Åberspringen
src_addr:       DC.L 0          ;Adresse des s/w-Bildschirms mit Bildausschnitt
endmask1:       DC.W -1         ;es gibt
endmask2:       DC.W -1         ;hier keine
endmask3:       DC.W -1         ;Maskierung
dst_xinc:       DC.W 4          ;Farb-Bildschirm hat zwei Bitplanes
dst_yinc:       DC.W 4          ;keine Zeile Åberspringen
dst_addr:       DC.L 0          ;Adresse des Farb-Bildschirms
x_count:        DC.W 40         ;80 Bytes pro Zeile werden kopiert
y_count:        DC.W 200        ;insgesamt sind es 200 Zeilen
hop:            DC.B 2          ;s/w-Daten werden nicht verknÅpft
op:             DC.B 3          ;dito
line_num:       DC.B $80        ;Busy-Bit setzen und Blitter starten
skew:           DC.B 0          ;wird alles nicht benîtigt


********************************************************************************
*                               SONSTIGE DATEN                                 *
********************************************************************************

sys_timer:      DC.L 0          ;Adresse der 200_Hz_System_Timer-Routine
old_xbios:      DC.L 0          ;Adresse der Xbios-Routine
scr_dump:       DC.L 0          ;Adresse der Hardcopy-Routine

modus:          DC.W 0          ;im Desktop eingestellte Blitter-Betriebsart

new_cursor:     DC.B ESC,"j",ESC,"H",ESC,"K","..WH..AT.. E..MU.."
                DC.B "LA..TI..ON.. S..PE..ED..??",0
old_cursor:     DC.B ESC,"k",0

                EVEN
screen:                                 ;hier kommt der Farb-Bildschirm hin


********************************************************************************
*                                                                              *
*                           UNEMEFDA INITIALISIEREN                            *
*                                                                              *
********************************************************************************

init:           lea     titel(PC),A0    ;Startadresse des Titels nach A0
                bsr     print           ;Titel auf dem Bildschirm ausgeben

                move.w  #4,-(SP)        ;Getrez
                trap    #XBIOS          ;aktuelle Auflîsung ermitteln
                addq.w  #2,SP           ;Stack korrigieren
                tst.w   D0              ;niedrige Auflîsung?
                beq.s   search_slot     ;wenn ja, weiter bei search_slot

                lea     wrong_rez(PC),A0 ;Adresse der Fehlermeldung

error:          bsr     print           ;Fehler anzeigen
                bsr     input           ;auf Tastendruck warten

abbruch:        clr.w   -(SP)           ;Pterm0
                trap    #GEMDOS         ;Programm beenden

search_slot:    pea     get_slot(PC)    ;freien VBI-Slot suchen
                move.w  #38,-(SP)       ;Supexec
                trap    #XBIOS          ;Routine starten
                addq.w  #6,SP           ;Stack korrigieren

                move.l  vbi_vektor(PC),D0 ;Slot gefunden?
                bne.s   get_screen      ;wenn ja, weiter bei get_screen
                lea     no_slot(PC),A0  ;Adresse der Fehlermeldung
                bra.s   error           ;und Abbruch

get_screen:     move.w  #2,-(SP)        ;Physbase
                trap    #XBIOS          ;Startadresse des Bildschirms holen
                addq.w  #2,SP           ;Stack korrigieren

                lea     mid_byte(PC),A6
                move.l  D0,14(A6)       ;s/w-Bildschirmadresse nach mono
                move.l  D0,18(A6)       ;und nach mono_org

                moveq   #80,D1          ;eine Zeile hat 80 Bytes
                add.l   D1,D0           ;zur s/w-Adresse addieren
                move.l  D0,28(A6)       ;und in src_addr merken

                lea     256+screen(PC),A5 ;Farb-Bildschirmadresse nach A5
                move.l  A5,D5
                clr.b   D5              ;ist nun durch 256 teilbar
                move.l  D5,D4
                lsr.w   #8,D5           ;mittleres Byte nach unten holen
                move.b  D5,(A6)+        ;als Video-Base Mid-Byte speichern
                swap    D5              ;hîheres Byte nach unten holen
                move.b  D5,(A6)+        ;als Video-Base High-Byte speichern

                lea     delay(PC),A0    ;Frage nach Verzîgerung
                bsr     print           ;ausgeben

get_key:        bsr     input

                cmpi.w  #ESC,D0         ;Escape gedrÅckt?
                beq.s   abbruch         ;wenn ja, weiter bei abbruch
                cmpi.w  #"0",D0         ;Taste kleiner 0?
                bcs.s   get_key
                cmpi.w  #"9",D0         ;Taste grîûer 9?
                bgt.s   get_key
                addq.w  #2,A6           ;ZÑhler Åberspringen
                sub.w   #48,D0          ;ASCII minus 48
                move.w  D0,(A6)+        ;und in count_amount merken

                move.l  D4,4(A6)        ;Farb-Bildschirmadresse nach color
                addq.l  #2,D4           ;um ein Wort erhîhen
                move.l  D4,36(A6)       ;und in dst_addr merken

                move.w  #-1,-(SP)       ;nach Blitterstatus fragen
                move.w  #64,-(SP)       ;Blitmode
                trap    #XBIOS
                addq.w  #4,SP           ;Stack korrigieren

                btst    #1,D0           ;Blitter vorhanden?
                seq     (A6)            ;$00=ja bzw. $FF=nein

                pea     privileg(PC)    ;Startadresse, falls >68000
                move.w  #8,-(SP)        ;Privilegverletzung
                move.w  #5,-(SP)        ;Setexc
                trap    #BIOS           ;neuen Vektor eintragen
                addq.w  #8,SP           ;Stack korrigieren

                move    SR,D1           ;ab 68010 priviligierter Befehl!

                move.l  D0,-(SP)        ;alter Vektor
                move.w  #8,-(SP)        ;Privilegverletzung
                move.w  #5,-(SP)        ;Setexc
                trap    #BIOS           ;alten Vektor eintragen
                addq.w  #8,SP           ;Stack korrigieren

                move.w  #2,-(SP)        ;hohe Auflîsung
                move.l  #-1,-(SP)       ;Adressen
                move.l  #-1,-(SP)       ;nicht Ñndern
                move.w  #5,-(SP)        ;Setscreen
                trap    #XBIOS          ;neue Auflîsung
                lea     12(SP),SP       ;Stack korrigieren

                pea     super(PC)       ;einige Vektoren verbiegen
                move.w  #38,-(SP)       ;Supexec
                trap    #XBIOS          ;Routine starten
                addq.w  #6,SP           ;Stack korrigieren

exit:           clr.w   -(SP)           ;OK fÅrs Desktop
                move.l  #(init-start)+(32256+50+256),-(SP)
                move.w  #49,-(SP)       ;Ptermres
                trap    #GEMDOS         ;Programm beenden


input:          move.w  #7,-(SP)        ;Crawcin
                trap    #GEMDOS         ;auf Tastendruck warten
                addq.w  #2,SP           ;Stack korrigieren
                rts                     ;und zurÅck


get_slot:       move.w  NVBLS.w,D7      ;Maximalanzahl der VBlank-Prozesse
                subq.w  #1,D7           ;minus 1
                movea.l _VBLQUEUE.w,A0  ;erster Eintrag der Tabelle
                lea     vbi_vektor(PC),A1

test_slot:      addq.w  #4,A0           ;nÑchster Eintrag
                tst.l   (A0)            ;Eintrag frei?
                beq.s   found           ;wenn ja, weiter bei found
                subq.w  #1,D7           ;sonst Maximalanzahl dekrementieren
                bne.s   test_slot       ;wenn >0,weiter bei test_slot
                clr.l   (A1)            ;kein freier VBI-Slot
                rts                     ;daher abbrechen

found:          move.l  A0,(A1)         ;Slot merken

                lea     swv_vec(PC),A0  ;eigene swv_vec-Routine
                move.l  A0,SWV_VEC.w    ;eintragen
                lea     syncmode(PC),A0
                move.b  SYNC_MODE.w,(A0) ;Frequenz und int. Synchro. merken
                rts                     ;und zurÅck


super:          lea     sys_timer(PC),A4 ;Adresse von sys_timer nach A4
                move.l  _200_Hz_SYS.w,(A4)+ ;alte Adresse dort merken
                lea     sys_int(PC),A5  ;und die neue Routine
                move.l  A5,_200_Hz_SYS.w ;eintragen

                move.l  TRAP_14.w,(A4)+ ;alte Xbios-Adresse nach old_xbios
                lea     new_xbios(PC),A5 ;und die neue Routine
                move.l  A5,TRAP_14.w    ;eintragen

                move.l  SCR_DUMP.w,(A4) ;Hardcopy-Adresse nach old_scr_dump
                lea     alt_help(PC),A4 ;neue ALT+HELP-Routine
                move.l  A4,SCR_DUMP.w   ;eintragen

                lea     vbl_interrupt(PC),A4 ;Start der VBI-Routine
                movea.l vbi_vektor(PC),A5 ;Adresse vom Slot
                move.l  A4,(A5)         ;Routine eintragen
                rts                     ;Super-Visor Routine beenden


privileg:       addq.w  #2,-12(A6)      ;Stackframe auf 8, da kein 68000'er
                addq.l  #2,2(SP)        ;PC auf nÑchsten Befehl stellen
                movea.l _P_COOKIES.w,A0 ;Zeiger auf Cookie Jar nach A0
                beq.s   no_blitter      ;wenn nicht da, weiter bei no_blitter

next:           move.l  (A0)+,D1        ;Kennung nach D1
                beq.s   no_blitter      ;wenn Ende, weiter bei no_blitter
                move.l  (A0)+,D2        ;Eintrag nach D2
                cmpi.l  #"_CPU",D1      ;Prozessortyp?
                bne.s   next            ;wenn nein, weiter bei next
                cmpi.w  #$0011,D2       ;Prozessor ein 32-Bitter?
                bcs.s   privileg_end    ;wenn nein, weiter bei privileg_end

no_blitter:     move.w  #-1,(A6)        ;sonst Blitter nicht vorhanden

privileg_end:   rte                     ;und zurÅck


titel:          DC.B ESC,"E",ESC,"f",ESC,"Y",32,44,ESC,"p","UNEMEFDA V 1.0"
                DC.B ESC,"Y",34,34,ESC,"q","a PUBLIC DOMAIN monochrome emulator"
                DC.B ESC,"Y",37,34,"Please send  a picture postcard to:"
                DC.B ESC,"Y",39,45,"Harald Fîrster"
                DC.B ESC,"Y",40,45,"TÅnkenhagen 1"
                DC.B ESC,"Y",41,45,"2400 LÅbeck 1"
                DC.B ESC,"Y",42,48,"Germany"
                DC.B ESC,"Y",45,32,"Put this program in an auto folder. With"
                DC.B ESC,"Y",46,32,"a  built-in  blitter you may  select the"
                DC.B ESC,"Y",47,32,"faster  blitter  mode by  switching  the"
                DC.B ESC,"Y",48,32,"blitter off (desktop only). Use ALT-HELP"
                DC.B ESC,"Y",49,32,"to split the screen, LSHIFT-ALT-HELP  to"
                DC.B ESC,"Y",50,32,"change    the   emulation   speed,   and"
                DC.B ESC,"Y",51,32,"CNTRL-ALT-HELP   to   get   a  hardcopy!",0

wrong_rez:      DC.B ESC,"Y",53,39,"Try with low resolution!",0

no_slot:        DC.B ESC,"Y",53,40,"No free VBI-Slot found!",0

delay:          DC.B ESC,"Y",53,42,"Press ESCAPE to exit"
                DC.B ESC,"Y",55,32,"What emulation speed? "
                DC.B "[0(most)-9(least)]",0

                BSS

vbi_vektor:     DS.L 1          ;Adresse vom VBI-Slot

                END
