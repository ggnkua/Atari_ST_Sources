;
;       SM124-Emulator fr STGA                 (c) 1992-97 Till Harbaum
;
;       jetzt auch fuer VOFA (ungetestet)
;

shift_md   equ       $FF8260
sync_md    equ       $FF820A

Getrez     equ       $04
Setscren   equ       $05

sshiftmd   equ       $44C
_v_basad   equ       $44E
_hz_200    equ       $4BA
_p_cookies equ       $5A0

VIDBASE    equ       $C00000
STGA_IO    equ       $CF03B0
VOFA_IO    equ       $D003B0

; hier kommen die VGA-Register
HERC_COMP  equ       $0F
ATC_INDX   equ       $10
MISC_OUT   equ       $12
VID_ENBL   equ       $13
TS_INDEX   equ       $14
TS_DATA    equ       $15
PEL_MASK   equ       $16
PEL_RDADR  equ       $17
PEL_WRADR  equ       $18
PEL_DATA   equ       $19
GDC_INDX   equ       $1E
CRT_INDX   equ       $24
DISP_MDE   equ       $28
FEAT_CTL   equ       $2A

.globl start_emu

no_stga:   move.l    a1,sp              ; Stackpointer restaurieren
           move.l    a0,8               ; Busfehlervektor restaurieren
           clr       d0
           rts

check_vga:
           move.l    8,a0               ; Busfehlervektor sichern
           move.l    #no_stga,8         ; und neuen eintragen
           move.l    sp,a1              ; Stackpointer sichern
           move.b    #1,VID_ENBL(a6)    ; Busfehler provozieren
           move.l    a0,8               ; Busfehlervektor restaurieren
           st        d0
           rts

wait_vsync:
wv1:       btst.b    #3,FEAT_CTL(a6)    ; Vsync high abwarten
           bne.s     wv1
wv2:       btst.b    #3,FEAT_CTL(a6)    ; Vsync low abwarten
           beq.s     wv2
           dbf       d0,wv1             ; d0 mal warten
           rts

           ; erstmal antesten, ob ueberhaupt eine VOFA/STGA da ist
start_emu:
           lea       VOFA_IO,a6         ; Basisregister fuer VOFA-VGA-IO-Zugriffe
           bsr.s     check_vga          ; ist eine VGA da?
           tst       d0
           bne.s     vga_ok

           lea       STGA_IO,a6         ; Basisregister fuer STGA-VGA-IO-Zugriffe
           bsr.s     check_vga          ; ist eine VGA da?
           tst       d0
           bne.s     vga_ok

           rts                          ; Noe, weder noch -> Tschuess
vga_ok:
           move.l    8,a0               ; Busfehlervektor sichern
           move.l    #no_stga,8         ; und neuen eintragen
           move.l    sp,a1              ; Stackpointer sichern
           move.b    #1,VID_ENBL(a6)    ; Busfehler provozieren
           move.l    a0,8               ; Busfehlervektor restaurieren

           bsr       init_vga           ; VGA aktivieren

           ; jetzt testen, ob Takt stimmt
           clr       d0
           bsr.s     wait_vsync         ; einen Vsync warten
           move.l    _hz_200,d1         ; 200Hz-Zaehler lesen
           move      #9,d0
           bsr.s     wait_vsync         ; zehn Vsync's warten
           move.l    _hz_200,d2
           sub.l     d1,d2              ; Zeitdifferenz bilden
           cmp.l     #21,d2             ; mit 21 vergleichen
           bhi.s     tst_ok             ; gross genug?
           move.b    #7,TS_INDEX(a6)    ; Timing-Sequencer
           move.b    #$f4,TS_DATA(a6)   ; korrigieren
tst_ok:

           ; cookie reinhaengen (kommt nicht mit existierendem
           ; aber vollem Jar klar (macht nix, weil ROM -> frueh
           tst.l     _p_cookies         ; existiert ein Jar?
           bne.s     has_jar
           cmp.l     #STGA_IO,a6        ; war's eine STGA?
           bne.s     rom_vofa
           move.l    #stga_cookie,_p_cookies
           bra.s     end_cookie
rom_vofa:  move.l    #vofa_cookie,_p_cookies
           bra.s     end_cookie
has_jar:   move.l    _p_cookies,a0
jar_loop:  tst.l     (a0)
           beq.s     jar_end
           addq.l    #8,a0
           bra.s     jar_loop           ; weitersuchen
jar_end:   clr.l     8(a0)              ; letzten Eintrag verschieben
           move.l    4(a0),12(a0)
           move.l    stga_cookie,(a0)   ; STRM eintragen
           clr.l     4(a0)              ; VOFA-Flag
           cmp.l     #STGA_IO,a6        ; war's eine STGA?
           bne.s     end_cookie
           move.l    #1,4(a0)           ; STGA-Flag
end_cookie:

           ; Videospeicher fuellen
           move.b    #2,TS_INDEX(a6)
           move.b    #7,TS_DATA(a6)     ; alle Planes loeschen
           lea       VIDBASE,a0
           move.w    #7999,d0           ; Bildschirm l”schen
clr_scrn:  clr.l     (a0)+
           dbf       d0,clr_scrn

           move.w    #Getrez,-(sp)
           trap      #14
           addq.l    #2,sp
           cmp.w     #2,d0              ; Haben wir hohe Aufl”sung ?
           beq.s     is_hirez           ; Ja, nix machen!

           move.b    shift_md,d7        ; shift_mode merken
           move.w    #2,-(sp)           ; hohe Aufl”sung
           pea       -1                 ; einschalten
           pea       -1
           move.w    #Setscren,-(sp)
           trap      #14
           lea       12(sp),sp
           move.b    d7,shift_md        ; und wieder herstellen

is_hirez:  move.l    #VIDBASE,_v_basad  ; Bildschirmbasis setzen
           move.b    #2,sshiftmd        ; ST-High-Rez

;        lea    VIDBASE,a0

;        move.b #2,TS_INDEX(a6)
;        move.b #2,TS_DATA(a6)   ; zweite Plane malen
;        move  #1999,d0
;t1:     move.l #-1,(a0)+
;        dbf       d0,t1

;        move.b #2,TS_INDEX(a6)
;        move.b #4,TS_DATA(a6)   ; dritte Plane malen
;        move  #1999,d0
;t2:     move.l #-1,(a0)+
;        dbf       d0,t2

;        move.b #2,TS_INDEX(a6)
;        move.b #6,TS_DATA(a6)   ; zweite und dritte Plane malen
;        move  #1999,d0
;t3:     move.l #-1,(a0)+
;        dbf       d0,t3

        move.b #2,TS_INDEX(a6)
        move.b #1,TS_DATA(a6)

           rts

init_vga:  movem.l   d3-d7/a2-a5,-(sp)
           move.w    d0,-(sp)
           move.b    #1,VID_ENBL(a6)    ; Enable VGA
           move.b    #$E3,MISC_OUT(a6)  ; Miscellaneous
           bsr       set_herc
           bsr       init_gdc           ; vga starten
           move.w    (sp)+,d0           ; werden
           bsr.s     init_res
           movem.l   (sp)+,d3-d7/a2-a5
           rts

; Startet den eigentlichen Videomodus und setzt Farben
init_res:  movem.l   d3-d7/a2-a6,-(sp)
           lea       reg_tab(pc),a1
           bsr       set_modus          ; Aufl”sung setzen
           bsr.s     set_colors         ; Farben setzen
           movem.l   (sp)+,d3-d7/a2-a6  ; Und Tschuess
           rts

set_colors:movem.l   d0-d5/d7/a0-a4,-(sp)
           move.b    #255,PEL_MASK(a6)
           move      sr,-(sp)
           ori       #$0700,sr          ; Interrupts aus
           move.b    #0,PEL_WRADR(a6)   ; Mit erster Farbe beginnen
           lea       PEL_DATA(a6),a0

           move.w    #7,d7              ; Schwarz - Weiž !
set_bw:    lea       bw_tab(pc),a1      ; Tabelle mit Schwarz & Weiž
s_col_lp:  move.b    (a1)+,(a0)         ; Farbteile in Register packen
           move.b    (a1)+,(a0)
           move.b    (a1)+,(a0)
           dbf       d7,s_col_lp

col_back:  move      (sp)+,sr           ; Alles wieder herstellen
           movem.l   (sp)+,d0-d5/d7/a0-a4
           rts

; Hier noch ein paar n”tige Inits
set_herc:  move.b    #3,HERC_COMP(a6)    ; Hercules komp.-Register setzen
           move.b    #$A0,DISP_MDE(a6)
           rts

; So, nu setzen wir die Register des Graphic-Display-Controllers
; und ein paar andere
init_gdc:  lea       GDC_INDX(a6),a0
           move.b    #2,-10(a0)         ; TS-Index:  Write Plane Mask
           move.b    #15,-9(a0)         ; TS-Daten:  Alle an
           move.b    #4,-10(a0)         ; TS-Index:  Memory Mode
           move.b    #12,-9(a0)         ; TS-Daten:  Ext. Mem. & Chain 4 an
           move.b    #1,(a0)            ; Enable Set / Reset
           move.b    #0,1(a0)           ; Alle aus
           move.b    #3,(a0)            ; Data Rotate and Function Select
           move.b    #0,1(a0)           ; Alles aus
           move.b    #6,(a0)            ; Miscellaneous
           move.b    #5,1(a0)           ; Graphic-Mode & 64k-Segmente
           move.b    #8,(a0)            ; Bit Mask
           move.b    #-1,1(a0)          ; Alle an
           move.b    #0,-1(a0)          ; Segment Select Register < 0
           addq.w    #6,a0              ; CRTC-Index ausw„hlen
           move.b    #$32,(a0)          ; RAS/CAS Configuration
                   move.b    #$70,1(a0)         ; 100 ns RAS/CAS
;           move.b    #8,1(a0)          ; Naja, halt RAS/CAS einstellen
           move.b    #$36,(a0)          ; Video System Config. 1
           move.b    #$F3,1(a0)         ; alles auf 16 Bit schalten

           move.b    #$37,(a0)          ; Video System Config. 2
           moveq     #3,d7              ; 32-Bit Video-RAM
           move.b    d7,1(a0)
           bsr.s     test_ram           ; Alles Klar?
           beq.s     ram_ok

           move.b    #$37,(a0)          ; dito
           moveq     #2,d7              ; 16-Bit Video-RAM
           move.b    d7,1(a0)
           bsr.s     test_ram           ; Nu alles klar?
           beq.s     ram_ok

           move.b    #$37,(a0)          ; dito dito
           moveq     #1,d7              ; 8-Bit Video-RAM
           move.b    d7,1(a0)
           bsr.s     test_ram           ; Nu aber?
           beq.s     ram_ok

           moveq     #-1,d0             ; War nix!
           rts

ram_ok:    or.b      #$0C,d7            ; Latch enablen und 256k*4
           move.b    #$37,(a0)          ; Tiefe einstellen
           move.b    d7,1(a0)
           moveq     #0,d0
           rts

; Testet, ob das RAM der VGA sinvoll geschaltet ist (so wie es der ST beim
; Booten mit seinem RAM ja auch macht)
test_ram:  move.l    a0,-(sp)
           lea       VIDBASE,a0
           moveq     #40,d0             ; 40 Byte testen
fil_ram:   move.b    #$55,(a0)+         ; Testmuster schreiben
           dbf       d0,fil_ram
           lea       VIDBASE,a0
           cmp.b     #$55,(a0)          ; Noch da?
           bne.s     ram_err            ; Nee, falsche Einstellung
           moveq     #40,d0             ; Nochmal 40 Byte
fil_ram2:  move.b    #$AA,(a0)+         ; Testmuster schreiben
           dbf       d0,fil_ram2
           cmp.b     #$AA,VIDBASE       ; Diesmal auch alles klar?
ram_err:   move.l    (sp)+,a0           ; Flags, ob alles klar bleiben!
           moveq     #0,d0
           rts

set_atc:   move.b    FEAT_CTL(a6),d0    ; Index-Z„hler aktivieren
           lea       ATC_INDX(a6),a0    ; ATC Basis
           lea       (a1),a2            ; ATC-Register-Satz
           moveq     #0,d1              ; ab Register 0
           moveq     #22,d2             ; 22 Register setzen
atc_loop:  move.b    d1,(a0)
           move.b    (a2)+,(a0)
           addq.b    #1,d1              ; n„chstes Register
           dbf       d2,atc_loop
           move.b    #$20,(a0)          ; ATC-Pallette freigeben
           rts

set_modus: move      sr,-(sp)
           ori       #$0700,sr          ; Interrupts aus
           bsr       start_ts           ; Timing-Sequencer starten
           bsr       set_herc

           moveq     #3,d1              ; 4 Register setzen
           moveq     #1,d0              ; ab Register 1
           lea       24(a1),a2          ; TS-Register setzen
           bsr.s     set_list

           moveq     #2,d1              ; 3 Register setzen
           moveq     #6,d0              ; ab Register 6
           bsr.s     set_list           ; TS-Register setzen

           move.b    23(a1),MISC_OUT(a6) ; Miscellaneous setzen

           lea       CRT_INDX(a6),a0
           move.b    #$11,(a0)          ; Vertical Sync End (u.s.w.)
           move.b    #0,1(a0)           ; CRTC 0-7 schreiben erlauben

           move.w    #24,d1             ; 25 Register setzen
           moveq     #0,d0              ; bei 0 anfangen
           lea       40(a1),a2          ; CRTC-Register-Liste
           bsr.s     set_list           ; CRTC-Register setzen

           move.b    #$33,(a0)          ; Extended Start Address
           move.b    (a2)+,1(a0)
           move.b    #$34,(a0)          ; 6845-komp. Ctrl.-Reg.
           move.b    (a2)+,1(a0)
           move.b    #$35,(a0)          ; Overflow high
           move.b    (a2)+,1(a0)
           move.b    #$11,(a0)          ; Vertical Sync End s.o.
           move.b    1(a0),d0
           or.b      #$80,d0            ; Register-schreiben verbieten
           move.b    d0,1(a0)

           bsr       set_atc            ; Nun noch den ATC setzen
                                        ; (ist nicht so einfach)
           lea       GDC_INDX(a6),a0
           move.w    #8,d1              ; 9 Register setzen
           moveq     #0,d0              ; ab Register 0
           lea       31(a1),a2          ; GDC-Register-Liste
           bsr.s     set_list

           move      (sp)+,sr           ; Interrupts wieder an
           rts

; Fllt VGA-Registersatz ab Register D0 , D1 Register lang aus Tabelle A2
; in Registersatz an Adresse A0
set_list:  move.b    d0,(a0)
           move.b    (a2)+,1(a0)
           addq.b    #1,d0
           dbf       d1,set_list
           rts

start_ts:  lea       TS_INDEX(a6),a0    ; Timing Sequencer starten
           move.b    #0,(a0)
           move.b    #1,1(a0)           ; TS-stop
           nop
           nop
           move.b    #0,(a0)            ; TS-start
           move.b    #3,1(a0)           ; l„žt TS mit neuen Werten starten
           rts

vofa_cookie:
           dc.b      "STRM",0,0,0,1     ; STgaRomModul = 1 (VOFA)
           dc.l      0,1                ; keine weiteren Eintraege (weil ROM)

stga_cookie:
           dc.b      "STRM",0,0,0,0     ; STgaRomModul = 0 (STGA)
           dc.l      0,1                ; keine weiteren Eintraege (weil ROM)

bw_tab:    dc.b      $3F,$3F,$3F        ; Weiž
           dc.b      $00,$00,$00        ; Schwarz
           dc.b      $3f,$00,$00        ; Rot
           dc.b      $00,$00,$00        ;
           dc.b      $00,$3f,$00        ; G
           dc.b      $00,$00,$00        ;
           dc.b      $00,$00,$3f        ; B
           dc.b      $00,$00,$00        ;

; Hier folgt der Videomodus
reg_tab:
           ; ATC-Tabelle
           dc.b      $00,$01,$02,$03,$04,$05,$06,$07
           dc.b      $08,$09,$0A,$0B,$0C,$0D,$0E,$0F
           dc.b      $01,$FF,$07,$10,$00,$05,$00


           ; Misc-Register
           dc.b      $63

           ; TS-Tabelle
           dc.b      $01,$01,$00,$06    ; Reg 1-4
           dc.b      $00
           dc.b      $B4,$03            ; Reg 6-8

           ; GDC-Tabelle
           dc.b      $00,$00,$00,$00,$00,$00,$05,$01
           dc.b      $FF

           ; CRTC-Tabelle
           dc.b      $5F,$4F,$4f,$83,$54,$80,$BF,$0F
           dc.b      $00,$40,$00,$00,$00,$00,$00,$00
           dc.b      $9C,$0E,$8F,$28,$00,$8f,$c0,$C3
           dc.b      $FF,$00,$00,$00