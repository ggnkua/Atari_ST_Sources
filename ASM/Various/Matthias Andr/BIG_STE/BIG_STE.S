; -----------------------------------------------------------------------------
;
;                      BigSTE fÅr Atari-STE
;
; Beschreibung: Simulation erhîhter Auflîsungen auf dem Atari STE
;               (STE-Hardware erforderlich)
;
;        Autor: Matthias AndrÑ
;      Sprache: Assembler
;  Progammname: 'BIG_STE.PRG' (unbedingt so benennen !!!)
;
;      Version: 1.2    (c) 1991 MAXON Computer
;
; -----------------------------------------------------------------------------

GEMDOS     equ 1
GEM        equ 2
XBIOS      equ 14

LINE_A     equ $A000                   ; Line-A-Initialisierung

v_lin_wr   equ $02                     ; Line-A-Variable (Zeilenbreite)

BYTES_LIN  equ -$02                    ; negative Line-A-Variablen
V_REZ_VT   equ -$04
V_REZ_HZ   equ -$0C
V_REZ_WR   equ -$28
V_CEL_MY   equ -$2A
V_CEL_MX   equ -$2C
V_CEL_HT   equ -$2E
MOUSE_Y    equ -$0258
MOUSE_X    equ -$025A
DEV_TAB    equ -$02B4

VBLVEKTOR  equ $70                     ; benutzte Vektoren
GEMVEKTOR  equ $88
TIMERBVEK  equ $0120

dump_vec   equ $0502                   ; Zeiger auf Hardcopy-Routine
_p_cookies equ $05A0                   ; Zeiger auf Cookie-Jar

VBASEHI    equ $FF8201                 ; diverse (STE-)Video-Register
VBASEMID   equ $FF8203
VBASELO    equ $FF820D
LINEWID    equ $FF820E                 ; Offset zur nÑchsten Zeile
HSCROLL    equ $FF8264                 ; Register fÅr pixelweises Scrollen

IERA       equ $FFFA07                 ; Interrupt Enable Register
ISRA       equ $FFFA0F                 ; Interrupt In-Service Register
IMRA       equ $FFFA13                 ; Interrupt Mask Register
TBCR       equ $FFFA1B                 ; Timer B Control Register
TBDR       equ $FFFA21                 ; Timer B Data Register

; -----------------------------------------------------------------------------
           text

           bra.s   start               ; zu Programmstart springen
           dc.b 'BSTE'                 ; Programmkennung

; Nachfolgende Variablen werden von 'K_BIGSTE.PRG' gepatcht und dienen zur
; Konfiguration von 'BigSTE'

aufloesung:dc.w 1                      ; Farbauflîsung (Mid/Low)
; BigSTE wird nicht installiert, wenn 'aufloesung' > 1  !!!
rez_plus:  dc.w 320,200,0,200,640,560  ; Tabelle: zusÑtzliche Auflîsungen
;                                        wird zu Standardauflîsung addiert
rand:      dc.w 16,16,32,16,32,32      ; Tabelle: hor./vert. SchieberÑnder

start:     movea.l 4(SP),A6            ; Basepageadresse
           movea.w #$0500,A5           ; Grîûe der Basepage + Stackgrîûe
           adda.l  12(A6),A5           ; + Grîûe TEXT-Segments
           adda.l  20(A6),A5           ; + Grîûe DATA-Segments
           adda.l  28(A6),A5           ; + Grîûe BSS-Segments
           move.l  A5,D1               ; = GesamtlÑnge
           and.b   #$FE,D1             ; LÑnge gerade
           add.l   A6,D1               ; + Basepageadresse
           movea.l D1,SP               ; Stackende
           move.l  A5,-(SP)            ; ProgrammlÑnge
           move.l  A6,-(SP)            ; Basepageadresse
           move.l  #$4A0000,-(SP)
           trap    #GEMDOS             ; Mshrink
           lea     12(SP),SP

           lea     test_ste(PC),A0     ; auf STE testen
           bsr     supexec             ; im Supervisormodus ausfÅhren
           tst.b   ste                 ; STE-Hardware vorhanden ?
           beq     no_ste              ; nein, Abbruch

           bsr     appl_init           ; 'appl_init' durchfÅhren
           tst.w   global              ; geglÅckt ?
           bne     auto                ; dann Abbruch, da BigSTE nicht
;                                        aus Auto-Ordner gestartet wurde
           cmpi.w  #2,aufloesung       ; 'aufloesung' > 1 ?
           bge     not_installed       ; dann BigSTE nicht installieren

           dc.w LINE_A                 ; Line-A-Init
           move.l  A0,linea_var        ; Variablen-Startadresse merken

           move.w  #3,-(SP)            ; Logbase
           trap    #XBIOS              ; logische Bildschirmadresse
           addq.l  #2,SP
           move.l  D0,videobase        ; merken

           move.w  #4,-(SP)            ; Getrez
           trap    #XBIOS              ; Auflîsungsstufe holen
           addq.l  #2,SP               ; Stack korrigieren
           cmp.w   #2,D0               ; hohe Auflîsung ?
           beq.s   res_ok              ; dann weiter
           cmp.w   aufloesung(PC),D0   ; tats. Farbauflîsung = gewÅnschter ?
           beq.s   res_ok              ; ja, dann weiter

           move.w  aufloesung(PC),-(SP) ; Auflîsung setzen (Voreinstellung)
           move.l  #-1,-(SP)
           move.l  #-1,-(SP)
           move.w  #5,-(SP)
           trap    #XBIOS
           lea     12(SP),SP
           move.w  aufloesung(PC),D0

res_ok:    move.w  D0,resolution       ; merken
           add.w   D0,D0               ; *2
           lea     planes(PC),A0
           move.w  0(A0,D0.w),planeanz
           add.w   D0,D0               ; *2 *2 = *4
           lea     rand(PC),A0         ; Zeiger auf Randtabellen
           move.w  0(A0,D0.w),h_rand   ; horizontaler Rand
           move.w  2(A0,D0.w),v_rand   ; vertikaler Rand

           lea     rez(PC),A0          ; Zeiger auf Auflîsungstabelle
           move.w  0(A0,D0.w),D6       ; Standardauflîsung holen
           move.w  2(A0,D0.w),D7
           move.w  D6,h_mon
           move.w  D7,v_mon
           addi.w  #1,h_mon            ; +1 = Breite
           addi.w  #1,v_mon            ; +1 = Hîhe

           move.w  v_mon(PC),D3
           lsr.w   #1,D3
           move.b  D3,count            ; halbe vertikale Auflîsung

           lea     rez_plus(PC),A0     ; Tabelle Auflîsungserhîhung
           move.w  0(A0,D0.w),D4
           add.w   2(A0,D0.w),D4       ; keine Auflîsungserhîhung ?
           beq     not_installed       ; dann Ende
           add.w   0(A0,D0.w),D6       ; X-Wert addieren
           add.w   2(A0,D0.w),D7       ; Y-Wert addieren
           move.w  D6,h_rez            ; und merken
           move.w  D7,v_rez

           addq.w  #1,D6               ; Breite
           addq.w  #1,D7               ; Hîhe
           lsr.w   #3,D6               ; Breite / 8
           mulu    planeanz(PC),D6     ; * Anzahl Planes
           mulu    D6,D7               ; * Hîhe = Bildschirmbedarf
           add.l   #255,D7             ; +255
           and.l   #$FFFF00,D7         ; auf 256 Byte Grenze bringen
           move.l  D7,D6
           sub.l   #$8000,D6           ; -32k vorhandenen Bildschirmspeicher

           move.l  #-1,D0              ; Grîûten freien Speicherblock
           bsr     malloc              ; erfragen
           move.l  D0,D5               ; LÑnge in D5
           bsr     malloc              ; Speicher reservieren
           movea.l D0,A0               ; Startadresse in A0
           move.l  D0,D4               ; und D4 merken
           bsr     mfree               ; und gleich wieder freigeben

           add.l   D5,D4               ; LÑnge Speicherblock dazuaddieren
           cmp.l   videobase(PC),D4    ; Block direkt am Video-Ram ?
           bne.s   new_v_ram           ; nein, weiter

           cmp.l   D6,D5               ; genug Speicher frei ?
           blt     memfull             ; nein, Meldung ausgeben

           sub.l   D6,D5               ; Freier Speicher minus benîtigter
           move.l  D5,D0               ; nach D0
           bsr     malloc              ; 1. Block reservieren
           movea.l D0,A6               ; Startadresse in A6 merken
           move.l  D6,D0               ; benîtigter Speicherplatz
           bsr     malloc              ; Block unter Video-Ram reservieren
           tst.l   D0                  ; geklappt ?
           bmi     memfull             ; nein, Meldung ausgeben
           move.l  D0,videobase        ; Startadresse merken
           movea.l A6,A0               ; Startadresse 1. Block
           bsr     mfree               ; Block wieder freigeben
           bra.s   install1

new_v_ram: cmp.l   D7,D5               ; genug Speicher frei ?
           blt     memfull             ; nein, Meldung ausgeben

           move.l  D7,D0               ; Speicher fÅr Bildschirm
           bsr     malloc              ; reservieren
           tst.l   D0                  ; geklappt ?
           bmi     memfull             ; nein, Meldung ausgeben
           move.l  D0,videobase        ; Startadresse merken

; Das alte Videoram (32k) liegt jetzt brach, da kein Speicherblock
; direkt darunter reserviert werden konnte !

install1:  andi.l  #$FFFF00,videobase  ; auf 256-Byte-Grenze bringen

           lea     install2(PC),A0     ; 'install2' im
           bsr     supexec             ; Supervisormodus
           tst.b   installiert         ; BigSTE bereits installiert ?
           bne     installed           ; dann Meldung und Abbruch

           lea     TEXT8(PC),A0        ; Bildschirm lîschen
           bsr     printline

           move.w  #-1,-(SP)
           move.l  videobase(PC),-(SP) ; Physikalische
           move.l  videobase(PC),-(SP) ; und logische
           move.w  #5,-(SP)
           trap    #XBIOS              ; Bildschirmadresse setzen
           lea     12(SP),SP

           lea     TEXT0(PC),A0        ; Headertext
           bsr     printline
           lea     TEXT3(PC),A0        ; "BigSTE installiert"
           bsr     printline
           clr.w   -(SP)
           move.l  A5,-(SP)
           move.w  #$31,-(SP)          ; Ptermres
           trap    #GEMDOS             ; Programm resident halten und Ende

install2:  lea     GEMVEKTOR,A0
           bsr.s   inst_test           ; BigSTE schon im GEM-Vektor
           bne.s   install2end         ; ja, Abbruch
           move.l  (A0),oldgemvec      ; alten GEM-Vektor sichern und
           move.l  #new_gem,(A0)       ; eigene Routine eintragen

           lea     VBLVEKTOR,A0
           bsr.s   inst_test           ; BigSTE schon im VBL-Vektor
           bne.s   install2end         ; ja, Abbruch
           move.l  (A0),oldvblvec      ; alten VBL-Vektor sichern und
           move.l  #new_vbl,(A0)       ; eigene Routine eintragen

           move.l  dump_vec,olddumpvec ; alten Hardcopy-Vektor sichern
           move.l  #hardcopy,dump_vec  ; Dummy-Routine eintragen

           move.l  TIMERBVEK,oldtimerb ; alten Timer-B-Vektor sichern
           move.l  #timer_b,TIMERBVEK  ; Timer-B-Routine eintragen
           ori.b   #1,IERA             ; Timer-B erlauben
           ori.b   #1,IMRA
install2end:rts

; -- Testen ob 'BSTE'-Kennung bereits in Vektorkette vorhanden ist ------------

inst_test: sf      installiert
           movea.l (A0),A1
testloop:  cmpa.l  #$08,A1
           blt.s   testend
           cmpi.l  #'XBRA',-12(A1)     ; XBRA-Kennung gefunden ?
           bne.s   testend             ; nein, Ende
           cmpi.l  #'BSTE',-8(A1)      ; Eigene Programmkennung gefunden ?
           seq     installiert         ; Ja, BigSTE bereits installiert
           beq.s   testend             ; und Ende
           movea.l -4(A1),A1           ; Nein, XBRA-Kette weiterverfolgen
           beq.s   testend
           bra.s   testloop
testend:   tst.b   installiert
           rts

; -- Verschiedene (Fehler)-Meldungen ausgeben ---------------------------------

installed: movea.l videobase(PC),A0
           bsr     mfree
           lea     TEXT1,A0            ; Headertext
           bsr     printline
           lea     TEXT7(PC),A0        ; "BigSTE bereits installiert"
           bsr     printline
           bra.s   waitkey

no_ste:    lea     TEXT1(PC),A0        ; Headertext
           bsr     printline
           lea     TEXT6(PC),A0        ; "Benîtigte Hardware fehlt"
           bsr     printline
           bra.s   waitkey

memfull:   lea     TEXT1(PC),A0        ; Headertext
           bsr     printline
           lea     TEXT2(PC),A0        ; "Nicht genug Speicher"
           bsr     printline
waitkey:   move.w  #7,-(SP)
           trap    #GEMDOS             ; auf Tastendruck warten
           addq.l  #2,SP
           bra.s   ende                ; und Ende

not_installed:
           lea     TEXT1(PC),A0        ; Headertext
           bsr     printline
           lea     TEXT4(PC),A0        ; "BigSTE nicht installiert"
           bsr     printline
           bra.s   ende

auto:      move.w  #1,intin
           move.l  #TEXT5,addrin       ; BigSTE aus Auto-Ordner starten !
           bsr     form_alert          ; Meldung ausgeben ...
           bsr     appl_exit           ; Applikation abmelden
ende:      clr.w   -(SP)
           trap    #GEMDOS             ; Ende

; -- Rechner auf Vorhandensein der STE-Hardware testen ------------------------

test_ste:  movea.l _p_cookies,A0       ; Cookie-Jar vorhanden ?
           beq.s   tst_end             ; Nein, dann kein STE ...
cookie_tst:cmpi.l  #'_VDO',(A0)+       ; gesuchter Cookie-ID gefunden ?
           beq.s   cookie_val          ; ja, dann Wert abtesten
           lea     4(A0),A0            ; nÑchster Cookie
           tst.l   (A0)                ; Ende der Liste ?
           bne.s   cookie_tst          ; Nein, weiter
tst_end:   rts
cookie_val:cmpi.l  #$010000,(A0)       ; Cookie-Wert mind. STE-Videohardware ?
           sge     ste                 ; Flag entsprechend setzen
           rts                         ; und zurÅck

; -- Hardcopy-Dummyroutine ----------------------------------------------------

           dc.b 'XBRA'
           dc.b 'BSTE'
olddumpvec:ds.l 1
hardcopy:  rts                         ; Bloû schnell wieder raus ...

; -----------------------------------------------------------------------------
;          Timer-B-Interrupt starten und Mausaktionen Åberwachen ...
; -- VBL-Interrupt ------------------------------------------------------------

           dc.b 'XBRA'
           dc.b 'BSTE'
oldvblvec: ds.l 1

new_vbl:   sf      half                ; 1. HÑlfte Bildschirm zÑhlen
           clr.b   TBCR                ; Timer anhalten
           move.l  #timer_b,TIMERBVEK  ; Eigene Timer-B-Routine auf jeden
           ori.b   #1,IERA             ; Fall einsetzen und
           ori.b   #1,IMRA             ; Timer-B erlauben
           move.b  count(PC),TBDR      ; 1/2 Bildschirm zÑhlen
           move.b  #8,TBCR             ; Event-Count-Mode starten

mouse:     movem.l D0-A0,-(SP)         ; benutzte Register retten
           movea.l linea_var(PC),A0    ; Adresse Line-A-Variablen
           move.w  MOUSE_X(A0),D0      ; Maus X-Position
           move.w  MOUSE_Y(A0),D1      ; Maus Y-Position
           cmp.w   mousex(PC),D0       ; Mausposition geÑndert ?
           bne.s   setnew              ; ja, weiter
           cmp.w   mousey(PC),D1
           beq     mouseend            ; nein, Abbruch

setnew:    move.w  D0,mousex           ; geÑnderte Mausposition verarbeiten
           move.w  D1,mousey
           move.w  x_pos(PC),D2        ; linke Ecke Bildschirmanzeige
           move.w  y_pos(PC),D3        ; obere Ecke
           move.w  D2,D4
           move.w  D3,D5
           add.w   h_mon(PC),D4        ; rechte Ecke
           add.w   v_mon(PC),D5        ; untere Ecke

           add.w   h_rand(PC),D2       ; VerschieberÑnder zu
           sub.w   h_rand(PC),D4       ; Bildschirmgrenzen
           add.w   v_rand(PC),D3       ; addieren (links und oben) und
           sub.w   v_rand(PC),D5       ; subtrahieren (rechts und unten)

           cmp.w   D2,D0               ; linker Rand erreicht ?
           bgt.s   pos1
           move.w  D2,D6
           sub.w   D0,D6               ; Verschiebewert (positiv)
           sub.w   D6,x_pos            ; von Anzeigeposition subtrahieren
           bge.s   pos2
           clr.w   x_pos               ; auf Null setzen
           bra.s   pos2

pos1:      cmp.w   D4,D0               ; rechter Rand erreicht ?
           blt.s   pos2
           move.w  D4,D6
           sub.w   D0,D6               ; Verschiebewert (negativ)
           sub.w   D6,x_pos
           move.w  x_pos(PC),D6
           add.w   h_mon(PC),D6
           cmp.w   h_rez(PC),D6        ; schon ganz rechts ?
           blt.s   pos2
           move.w  h_rez(PC),D6
           sub.w   h_mon(PC),D6
           addq.w  #1,D6
           move.w  D6,x_pos            ; neue X-Position

pos2:      cmp.w   D3,D1               ; oberer Rand erreicht ?
           bgt.s   pos3                ; nein, weiter
           move.w  D3,D7
           sub.w   D1,D7               ; Verschiebewert
           sub.w   D7,y_pos
           bge.s   adresse
           clr.w   y_pos
           bra.s   adresse

pos3:      cmp.w   D5,D1               ; unterer Rand erreicht ?
           blt.s   adresse             ; nein, weiter
           move.w  D5,D7
           sub.w   D1,D7               ; Verschiebewert
           sub.w   D7,y_pos
           move.w  y_pos(PC),D7
           add.w   v_mon(PC),D7
           cmp.w   v_rez(PC),D7        ; schon ganz unten ?
           blt.s   adresse             ; nein, weiter
           move.w  v_rez(PC),D7
           sub.w   v_mon(PC),D7
           addq.w  #1,D7
           move.w  D7,y_pos            ; max. untere Position

adresse:   moveq   #0,D0
           move.l  D0,D1
           move.w  x_pos(PC),D0
           move.w  y_pos(PC),D1
           movea.l videobase(PC),A0    ; Bildschirmbasisadresse holen
           move.w  D0,D2
           and.w   #$0F,D2
           move.w  D2,shift
           lsr.w   #4,D0               ; X-Position auf Wortgrenze
           mulu    planeanz(PC),D0     ; * Anzahl Planes
           add.w   D0,D0               ; in Bytes
           adda.l  D0,A0               ; zu Bildschirmbasis addieren

           move.w  h_rez(PC),D0        ; hor. Auflîsung
           addq.w  #1,D0               ; +1
           lsr.w   #3,D0               ; /8
           mulu    planeanz(PC),D0     ; * Anzahl Planes = Bytes pro Zeile
           mulu    D1,D0               ; * Hîhe
           adda.l  D0,A0               ; zu Bildschirmbasis addieren

           move.l  A0,videoadr         ; neue Videoadresse merken
mouseend:  movem.l (SP)+,D0-A0         ; benutzte Register restaurieren
           move.l  oldvblvec(PC),-(SP) ; alte VBL-Routine
           rts                         ; anspringen

; -----------------------------------------------------------------------------
;          Am Ende des Bildaufbaues Videoadressen setzen ...
; -- Timer-B-Interrupt --------------------------------------------------------

           dc.b 'XBRA'
           dc.b 'BSTE'
oldtimerb: ds.l 1

timer_b:   move.l  D0,-(SP)

           clr.b   TBCR                ; Timer Stop
           move.b  count(PC),TBDR      ; Bildschirmzeilen zÑhlen
           move.b  #8,TBCR             ; Event-Count-Mode starten

           not.b   half
           bne.s   hbl2end             ; erst halber Bildschirm gezÑhlt ?

setvideo:  tst.l   videoadr            ; aktuelle Videoadresse
           beq.s   hbl2end             ; schon gesetzt ?

           move.b  videoadr+1(PC),VBASEHI ; Videoadresse Highbyte
           move.b  videoadr+2(PC),VBASEMID ; Videoadresse Midbyte
           move.b  videoadr+3(PC),VBASELO ; Videoadresse Lowbyte
           clr.l   videoadr            ; gesetzt

           move.w  line_wid(PC),D0     ; Video-Offset
           tst.w   resolution          ; Auflîsung > Low-Resolution
           bne.s   hbl1end             ; dann Ende
           tst.w   shift               ; Wortgrenze (Pixelverschiebung=0)
           beq.s   set_shift           ; ja, weiter
           sub.w   planeanz(PC),D0     ; nein, Offset - (1*Anzahl Planes)
set_shift: move.w  shift(PC),HSCROLL   ; Verschiebung in Pixeln
hbl1end:   move.w  D0,LINEWID          ; Video-Offset zur nÑchsten Zeile
;                                        in WortlÑnge
hbl2end:   move.l  (SP)+,D0
           bclr    #0,ISRA             ; In-Service-Bit lîschen
           rte

; -----------------------------------------------------------------------------
;          Auf v_opnwk-Aufruf warten und Variablen patchen ...
; -- Trap #2 ------------------------------------------------------------------

           dc.b 'XBRA'
           dc.b 'BSTE'
oldgemvec: ds.l 1

new_gem:   cmp.l   #$73,D0             ; VDI-Aufruf ?
           bne.s   oldgem              ; nein, zum normalen Aufruf
           movea.l D1,A0
           move.l  $0C(A0),intoutadr   ; intout-Adresse merken
           movea.l (A0),A0             ; contrl-Adresse
           cmpi.w  #1,(A0)             ; v_opnwk-Aufruf ?
           bne.s   oldgem              ; nein, zum normalen Aufruf

           move.l  2(SP),oldgemret     ; Return-Adresse merken
           move.l  #set_vdi,2(SP)      ; und neue setzen.
oldgem:    move.l  oldgemvec(PC),-(SP) ; Normalen VDI-Aufruf
           rts                         ; ausfÅhren

set_vdi:   movea.l intoutadr(PC),A0    ; intout-Adresse
           move.w  h_rez(PC),(A0)      ; horizontale Auflîsung setzen
           move.w  v_rez(PC),2(A0)     ; vertikale Auflîsung setzen

set_linea: movea.l linea_var(PC),A0

           move.w  h_rez(PC),V_REZ_HZ(A0) ; horizontale Auflîsung setzen
           addq.w  #1,V_REZ_HZ(A0)
           move.w  h_rez(PC),DEV_TAB(A0)

           move.w  v_rez(PC),V_REZ_VT(A0) ; vertikale Auflîsung setzen
           addq.w  #1,V_REZ_VT(A0)
           move.w  v_rez(PC),DEV_TAB+2(A0)

           move.w  V_REZ_HZ(A0),D0     ; horizontale Auflîsung
           lsr.w   #3,D0               ; /8 = Bytes pro Zeile
           move.w  D0,V_CEL_MX(A0)
           subq.w  #1,V_CEL_MX(A0)     ; maximale Cursorspalte

           mulu    planeanz(PC),D0     ; * Anzahl Planes
           move.w  D0,v_lin_wr(A0)     ; Bytes pro Zeile
           move.w  D0,BYTES_LIN(A0)

           mulu    V_CEL_HT(A0),D0     ; * Zeichensatzhîhe
           move.w  D0,V_REZ_WR(A0)     ; = Bytes pro Charakterzeile

           moveq   #0,D0
           move.w  V_REZ_VT(A0),D0     ; vertikale Auflîsung
           divu    V_CEL_HT(A0),D0     ; / Zeichensatzhîhe
           subq.w  #1,D0               ; - 1
           move.w  D0,V_CEL_MY(A0)     ; = maximale Cursorzeile

           lea     set_video(PC),A0    ; 'set_video' im
           bsr.s   supexec             ; Supervisormodus ausfÅhren

           movea.l oldgemret(PC),A0
           jmp     (A0)                ; in aufrufendes Programm zurÅck

set_video: movea.l linea_var(PC),A0    ; Zeiger auf Line-A-Variablen
           lea     line_w(PC),A2       ; Zeiger auf Tabelle (Bytes/Zeile)
           move.w  resolution(PC),D1   ; Auflîsungsstufe holen
           add.b   D1,D1               ; *2
           move.w  V_REZ_HZ(A0),D0     ; horizontale Auflîsung
           lsr.w   #4,D0               ; /16
           mulu    planeanz(PC),D0     ; * Planesanzahl = Worte pro Zeile
           sub.w   0(A2,D1.w),D0       ; - Worte pro Zeile (Standard)
           move.w  D0,LINEWID          ; = Video-Offset zur nÑchsten Zeile
           move.w  D0,line_wid         ; Offset merken
           move.l  oldgemvec(PC),GEMVEKTOR ; alten GEM-Vektor restaurieren
           rts

; -- Betriebssystemaufrufe ----------------------------------------------------

printline: pea     (A0)                ; Startadresse in A0
           move.w  #$09,-(SP)          ; Text auf Bildschirm ausgeben
           bra.s   trapgemdos

malloc:    move.l  D0,-(SP)            ; LÑnge in D0
           move.w  #$48,-(SP)          ; Speicher reservieren
           bra.s   trapgemdos

mfree:     pea     (A0)                ; Adresse in A0
           move.w  #$49,-(SP)          ; Speicher freigeben
trapgemdos:trap    #GEMDOS
           bra.s   stackkor

supexec:   pea     (A0)                ; Startadresse der Routine in a0
           move.w  #38,-(SP)           ; im Supervisormodus
           trap    #XBIOS              ; ausfÅhren
stackkor:  addq.l  #6,SP
           rts

; -- GEM-Aufrufe --------------------------------------------------------------

form_alert:move.l  #$340001,control
           move.l  #$010001,control+4
           bra.s   call2gem

appl_init: move.l  #$0A0000,control
           bra.s   call1gem

appl_exit: move.l  #$130000,control
call1gem:  move.l  #$010000,control+4
call2gem:  clr.w   control+8
           move.l  #aespb,D1
           move.w  #$C8,D0
           trap    #GEM
           rts

; -----------------------------------------------------------------------------
           data

rez:       dc.w 319,199,639,199,639,399 ; Tabellen:Standardauflîsungen
line_w:    dc.w 80,80,40
planes:    dc.w 4,2,1

mousex:    dc.w 0                      ; alte Maus-X-Position
mousey:    dc.w 0                      ; alte Maus-Y-Position
half:      dc.b 0
count:     dc.b 0
ste:       dc.b 0
installiert:dc.b 0

TEXT0:     dc.b 27,'E'
TEXT1:     dc.b 13,10,27,'p',' BigSTE ',27,'q Version 1.2',13,10
           dc.b '5/91,  Matthias AndrÑ',13,10,0
TEXT2:     dc.b 'Nicht genug freier Speicher !!!',13,10,0
TEXT3:     dc.b 'Installation durchgefÅhrt ...',13,10,0
TEXT4:     dc.b 'Nicht installiert ...',13,10,0
TEXT5:     dc.b '[1][ |BigSTE muû unbedingt bei|Systemstart aus dem Auto-Ordner|heraus gestartet werden !!!][  Ok  ]',0
TEXT6:     dc.b 'Hardwarevoraussetzungen nicht gegeben !!!',13,10,0
TEXT7:     dc.b 'BigSTE bereits installiert !!!',13,10,0
TEXT8:     dc.b 27,'E',0

aespb:     dc.l control,global,intin,intout,addrin,addrout

           bss

linea_var: ds.l 1
intoutadr: ds.l 1
videobase: ds.l 1
videoadr:  ds.l 1
oldgemret: ds.l 1

x_pos:     ds.w 1                      ; Darstellung ab X-Position
y_pos:     ds.w 1                      ; Darstellung ab Y-Position
h_mon:     ds.w 1                      ; hor. Monitorauflîsung
v_mon:     ds.w 1                      ; vert. Monitorauflîsung
h_rez:     ds.w 1                      ; eingestellte hor. Auflîsung
v_rez:     ds.w 1                      ; eingestellte vert. Auflîsung
h_rand:    ds.w 1                      ; eingestellter hor. Schieberand
v_rand:    ds.w 1                      ; eingestellter vert. Schieberand

line_wid:  ds.w 1
resolution:ds.w 1
planeanz:  ds.w 1
shift:     ds.w 1

control:   ds.w 5
global:    ds.w 15
intin:     ds.w 16
intout:    ds.w 7
addrin:    ds.l 3
addrout:   ds.l 1
           end
