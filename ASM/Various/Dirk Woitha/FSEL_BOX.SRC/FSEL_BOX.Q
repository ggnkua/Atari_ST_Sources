;=========================================================
;
;                       FSEL_BOX.ACC
;
;                                      1988 by Dirk Woitha
;=========================================================


         include   acc.q
         include   fsel_box.a
         include   hex_dez.q
         include   vbl_list.q

acc_rtm: move.l    #rsc_nam,(a6)       ;Resource laden
         move.w    #rsrc_load,d0
         move.l    #$00010100,d1
         bsr       aescall


         move.w    #r_tree,(a5)        ;Adresse des Formulars
         move.w    #fsel,2(a5)
         move.w    #rsrc_gaddr,d0
         move.l    #$02010001,d1
         bsr       aescall

         move.l    addrout(pc),fsel_adr

         pea       bau_ein(pc)
         move.w    #supexec,-(sp)
         trap      #xbios
         addq.l    #6,sp

         lea       gem_set(pc),a0
         bsr       vbl_ein             ;neue Gem-Routine im VBL
                                       ;Åberwachen
         moveq     #1,d0
                   rts


acc_pgm  rts

         data
acc_name:                              ;ACC wird nicht angemeldet
acc_msgs:
         dc.l      0
rsc_nam: dc.b      'FSEL_BOX.RSC',0
         align

         text

;==========================================================
; gem_set:
;
; Eintrag im TRAP 2 Åberwachen
;==========================================================

gem_set:
         move.l    trap_2,d0           ;Adresse im ROM ?
         and.l     #$FFFFFF,d0
         cmp.l     #$FC0000,d0
         blt       trap_ok             ;nein, dann ok
         move.l    #gem_neu,trap_2     ;ja, dann eigene Routine
trap_ok:
         rts




;==========================================================
;  bau_ein:
;
;  neue Fileselectorbox ins Betriebssystem einbinden
;==========================================================

bau_ein:
         move.l    trap_2,gem_alt     ;Adr. alte Gem-Routine merken
         move.l    #gem_neu,trap_2     ;und neue Adresse einschreiben
         rts

         bss
gem_alt:
         ds.l      1                   ;Adresse der alten Gem-Routine

         text

gem_neu:                               ;neue Routine
         movem.l   a1-a2,\rette_reg    ;Register retten

         cmp.w     #aes,d0             ;Åberhaubt AES Aufruf
         bne       \mach_alt            ;nein, wohl VDI

         move.l    d1,a1
         move.l    (a1),a2             ;a2 zeigt auf CONTROL(0)
         cmp.w     #90,(a2)            ;Fileselect-Aufruf ?
         bne       \mach_alt            ;nein, dann ins AES

         move.l    12(a1),a2           ;Adresse INTOUT(0) merken
         move.l    a2,\error
         lea       2(a2),a2            ;Adresse INTOUT(1) merken
         move.l    a2,\taste

         move.l    16(a1),a2           ;Adresse ADDRIN(0)
         move.l    (a2),\path_name     ;Adresse Pathname merken
         move.l    4(a2),\file_name    ;Adresse Filename merken

         move.l    2(sp),\ret_adr      ;Return-Adresse merken
         move.l    #\makebox,2(sp)     ;und Filebox-Routine als
                                       ;neuen Aussprung eintragen
         movem.l   \rette_reg(pc),a1-a2
         rte                           ;und in Fileselektorbox springen
                                       ;wird im USER-Modus ausgefÅhrt!

\mach_alt:
         movem.l   \rette_reg(pc),a1-a2
         move.l    gem_alt,-(sp)
         rts                           ;alte Routine anspringen

         bss
\error:
         ds.l      1                   ;Adresse von INTOUT(0) / Error-Flag
\taste:
         ds.l      1                   ;Adresse von INTOUT(1) / Abbruch-
                                       ;Taste
\path_name:
         ds.l      1                   ;Adresse des Pathname
\file_name:
         ds.l      1                   ;Adresse des Filename
\ret_adr:
         ds.l      1                   ;Return-Adresse / RÅcksprungadresse
                                       ;ins Hauptprogramm

\rette_reg:
         ds.l      2                   ;Zwischenspeicher fÅr a0,a2

         text

;===========================================================
;      Fileselektorbox anzeigen und Dialog abwickeln
;
;      Eingabe:  \path_name zeigt auf String mit Pfad-Namen
;                \file_name zeigt auf String mit Datei_Namen
;                \error     zeigt auf intout(0)
;                \taste     zeigt auf intout(1)
;
;      Ausgabe:  Pfad und Dateiname werden neu gesetzt
;                \error = 0 Fehler, >0 = Alles OK
;                \taste = 0 Abbruch    =1 OK
;===========================================================

\makebox:
         move.l    sp,\rette_sp
         move.l    #\stack_neu,sp      ;eigenen Stack setzen


         movem.l   a0-a6/d0-d7,-(sp)

         move.w    #1,\err_aus         ;erst mal keinen Fehler annehmen

         lea       intin(pc),a5        ;intin und addrin nach a5,a6
         lea       addrin(pc),a6


;*** Pfadnamen, Dateinamen und Extension zerlegen und in Objekte eintragen


         move.l    \path_name(pc),a0
         bsr       \upper              ;Text in Groûschrift
         bsr       \hack_pfad          ;Pfadnamen zerlegen und ÅberprÅfen
         move.w    #PATHNAME,d0        ;Pfadnamen eintragen
         move.w    #38,d1
         bsr       \txtcpy             ;a0 zeigt noch auf Pathname

         move.l    \file_name(pc),a0   ;Dateinamen eintragen
         lea       \hilfstext(pc),a1
\lpx1    move.b    (a0)+,(a1)+         ;Kopie anfertigen
         bne       \lpx1

         lea       \hilfstext(pc),a0
         bsr       \upper
         bsr       \konv_name
         move.w    #11,d1
         move.w    #FILENAME,d0
         bsr       \txtcpy

         lea       \e_blank(pc),a0     ;Suchextension eintragen
         move.w    #MOVER,d0
         move.w    #14,d1
         bsr       \txtcpy

         lea       \e_teil(pc),a0
         cmp.b     #'*',(a0)           ;wenn Extension mit '*.' anfÑngt
         bne       \nimm_st            ;dann auch ins Feld unten links
         cmp.b     #'.',1(a0)
         bne       \nimm_st
\trans   move.w    #DEFEXT,d0
         move.w    #5,d1
         bsr       \strcpy
         bra       \go_on
\nimm_st:
         lea       \stern(pc),a0
         bra       \trans
\go_on:

;*** Vorhandene Drives darstellen und andere Knîpfe deaktivieren

                                       ;Vorhandene Drives eintragen
         move.w    #drvmap,-(sp)       ;Drives abfragen
         trap      #bios
         addq.l    #2,sp
         move.w    d0,d7               ;Drive Table in d7

         lea       \knopf_tab(pc),a3   ;Zeiger auf Tabelle mit Knopf-Index
         move.w    (a3)+,d3            ;d3 zeigt INDEX nÑch. Laufw. Knopf
         move.w    #-1,d4              ;d4 zÑhlt Bits durch
         move.w    #'A'-1,d5           ;d5 zÑhlt Buchstabe durch
         clr.w     d6                  ;Zaehler gefundene Laufwerke
\lp20    addq.w    #1,d4
         addq.w    #1,d5
         cmp.w     #16,d4              ;Bis Laufwerk P testen
         beq       \dr_end
         btst      d4,d7               ;gibt es das Laufwerk?
         beq       \lp20
                                       ;ja Laufwerk gibt es
         move.w    d3,d0
         bsr       \objc_adr           ;Adr. Knopf-Object berechnen

         bclr      #7,9(a0)            ;not hidden
         move.w    #%100000,10(a0)     ;shadowed
         move.b    d5,12(a0)           ;Buchstabe eintragen
         move.w    (a3)+,d3            ;naechster Knopf
         addq.w    #1,d6
         cmp.w     #12,d6              ;nach 12. Laufwerk schluss
         beq       \dg_end
         bra       \lp20
\dr_end:                               ;restliche Knîpfe verstecken
         cmp.w     #-1,d3
         beq       \dg_end
         move.w    d3,d0
         bsr       \objc_adr
         bset      #7,9(a0)            ;hidden
         move.w    (a3)+,d3
         bra       \dr_end
\dg_end:

;*** Allgemein DTA-Buffer Adresse erfragen

         move.w    #fgetdta,-(sp)      ;DTA-Buffer Adresse erfragen
         trap      #gemdos
         addq.l    #2,sp
         move.l    d0,\dta_old


         pea       \dtabuf             ;und neue setzen
         move.w    #$1A,-(sp)
         trap      #gemdos
         addq.l    #6,sp

         move.l    #\dtabuf,\dta_adr


;*** Direktorie lesen und Slider-LÑnge berechnen

         bsr       \read_dir
         tst.w     d0
         beq       \read_ok
         clr.w     \err_aus
         bra       \end_box2           ;bei Malloc-Error abbrechen
\read_ok:
         bsr       \count_slider

;*** Filenamen eintragen

         move.w    #1,\abnumr          ;beim erstenmal ab Nummer 1
         clr.w     \anz_art

         bsr       \zeig_an            ;Filenamen eintragen



;*** File-Seletor-Box zeichnen

         move.l    fsel_adr(pc),(a6)   ;form_center
         move.w    #form_center,d0
         move.l    #$00050100,d1
         bsr       aescall
         lea       intout(pc),a0
         move.l    2(a0),\ob_x
         move.l    6(a0),\ob_br


         move.w    #form_dial,d0
         move.l    #$09010100,d1
         clr.w     (a5)                ;Bildschirm-Speicher reservieren
         move.l    \ob_x(pc),2(a5)
         move.l    \ob_br(pc),6(a5)
         move.l    2(a5),10(a5)
         move.l    6(a5),14(a5)
         bsr       aescall

         move.w    #root,d0            ;BOX zeichnen
         bsr       \objc_draw

         clr.w     (a5)                ;Mauszeiger ist Pfeil
         move.w    #graf_mouse,d0
         move.l    #$01010100,d1
         bsr       aescall

         move.w    #wind_update,d0     ;Mauskontrolle Åbernehmen
         move.l    #$01010000,d1
         move.w    #beg_mctrl,(a5)
         bsr       aescall

\do_form:
         move.w    #form_do,d0
         move.l    #$01010100,d1
         move.w    #FILENAME,(a5)
         move.l    fsel_adr(pc),(a6)
         bsr       aescall
         move.w    intout(pc),d6       ;d6,d7 = Index des Abbruch-Objects
         move.w    d6,d7
         bclr      #15,d7              ;Doppelklick Bit in d7 lîschen

         cmp.w     #UP,d7
         bne       \not_up
                                       ; ### Pfeil 'Hoch' angeklickt ###
         cmp.w     #1,\abnumr          ;wenn schon oben fertig
         beq       \do_form
         subq.w    #1,\abnumr          ;sonst eins rauf
\draw_names:
         move.w    \slid_max(pc),d1    ;Slider Position berechnen
         sub.w     \slid_is(pc),d1     ;Grîûe des Hintergrundes
         move.w    \abnumr(pc),d0
         subq.w    #1,d0
         mulu      d0,d1               ; * (abnumr -1)
         move.w    \anzahl,d0          ;Anzahl ist hier immer > 9
         sub.w     #9,d0
         divu      d0,d1               ; / (anzahl -9)
         move.w    #SLIDER,d0
         bsr       \objc_adr
         move.w    d1,18(a0)
         move.w    #GROUND,d0
         bsr       \objc_draw

         bsr       \zeig_an
         move.w    #NAMES,d0           ;und neu zeichnen
         bsr       \objc_draw
         bra       \do_form
\not_up:
         cmp.w     #DOWN,d7
         bne       \not_down
                                       ; ### Pfeil 'Runter' angeklickt
         move.w    #9,d0               ;wenn unten nichts mehr -> fertig
         add.w     \abnumr(pc),d0
         cmp.w     \anzahl,d0
         bgt       \do_form
         addq.w    #1,\abnumr          ;sonst eins runter
         bra       \draw_names
\not_down:
         cmp.w     #SLIDER,d7          ; ### Slider Bewegung ###
         bne       \not_slider
         cmp.w     #9,\anzahl
         ble       \do_form            ;Anzahl <= 9, nichts verschieben

         move.w    #graf_slidebox,d0   ;Slider verschieben
         move.l    #$03010100,d1
         move.w    #GROUND,(a5)
         move.w    #SLIDER,2(a5)
         move.w    #1,4(a5)            ;vertikal
         move.l    fsel_adr(pc),(a6)
         bsr       aescall

         move.w    intout(pc),d0       ;abnumr berechnen
         move.w    \anzahl(pc),d1      ;Formel:
         sub.w     #9,d1               ;((rel.Pos * (anzahl-9)+500)
         mulu      d0,d1               ;/1000+1
         add.l     #500,d1
         divu      #1000,d1
         addq.w    #1,d1
         move.w    d1,\abnumr
         bra       \draw_names
\not_slider:
         cmp.w     #GROUND,d7
         bne       \not_ground
                                       ;### Klick auf Sliderhintergrund ###
         lea       contrl(pc),a0       ;Mausposition abfragen
         move.w    #vq_mouse,(a0)
         clr.w     2(a0)
         clr.w     6(a0)
         move.w    grf_hand(pc),12(a0)
         bsr       vdicall             ;ptsout+2 enthÑlt y-Position

         move.w    #objc_offset,d0     ;y-Position Slider bestimmen
         move.l    #$01030100,d1
         move.w    #SLIDER,(a5)
         move.l    fsel_adr(pc),(a6)
         bsr       aescall
         move.w    (intout+4)(pc),d0

         cmp.w     (ptsout+2)(pc),d0   ;und mit Maus vergleichen
         bgt       \geh_rauf
                                       ;Klick unter Slider
                                       ;also um 9 runter
         add.w     #9,\abnumr
         move.w    \anzahl,d1          ;aber nicht grîûer als Anzahl-8
         sub.w     #8,d1
         cmp.w     \abnumr(pc),d1
         bge       \draw_names
         move.w    d1,\abnumr
         bra       \draw_names
\geh_rauf:                             ;Klick Åber Slider
                                       ;also 9 rauf
         sub.w     #9,\abnumr
         cmp.w     #1,\abnumr          ;aber nicht kleiner 1
         bge       \draw_names
         move.w    #1,\abnumr
         bra       \draw_names

\not_ground:
         cmp.w     #LEFT,d7            ;### Klick auf Pfeil 'Links' ###
         bne       \not_left

         subq.w    #1,\anz_art         ;Anzeige wechseln
         bpl       \art_gut
         move.w    #2,\anz_art
\art_gut:
         bsr       \zeig_an
         move.w    #NAMES,d0
         bsr       \objc_draw
         move.w    #ANZTYP,d0
         bsr       \objc_draw
         bra       \do_form
\not_left:
         cmp.w     #RIGHT,d7           ;### Klick auf Pfeil 'Rechts' ###
         bne       \not_right

         addq.w    #1,\anz_art         ;Anzeige wechseln
         cmp.w     #3,\anz_art
         bne       \art_gut
         clr.w     \anz_art
         bra       \art_gut
\not_right:

         cmp.w     #MOVER,d7           ;### Klick auf Mover-Feld ###
         bne       \not_mover

         move.w    #PATHNAME,d0        ;eimgegebenen Pathnamen auswerten
         bsr       \objc_adr
         move.l    12(a0),a0
         move.l    (a0),a0             ;a0 zeigt auf Text
         move.l    \path_name(pc),a1   ;a1 auf Speicher fÅr Pathname
\lz1     move.b    (a0)+,(a1)+         ;Pathname Åbertragen
         bne       \lz1
\neuer_path:
         move.l    \path_name(pc),a0
         bsr       \hack_pfad          ;Pathname korrigieren
         move.w    #PATHNAME,d0        ;und zurÅckschreiben
         move.w    #38,d1
         bsr       \txtcpy

         lea       \e_blank(pc),a0     ;Suchextension eintragen
         move.w    #MOVER,d0
         move.w    #14,d1
         bsr       \txtcpy

         move.w    #PATHNAME,d0        ;und alles anzeigen
         bsr       \objc_draw
         move.w    #MOVER,d0
         bsr       \objc_draw

         bclr      #0,\mal_flag        ; war ueberhaupt ein malloc ?
         beq       \no_mem             ; nî

         move.l    \dir_tab,-(sp)      ;alten Speicher freigeben
         move.w    #mfree,-(sp)
         trap      #gemdos
         addq.l    #6,sp

\no_mem: bsr       \read_dir           ;neues Direktorie einlesen
         tst.w     d0
         beq       \read_ok2
         clr.w     \err_aus
         bra       \das_wars           ;bei Malloc-Error abbrechen
\read_ok2:

         bsr       \count_slider

         move.w    #1,\abnumr
         clr.w     \anz_art

         bsr       \zeig_an            ;Filnamen eintragen

         move.w    #GROUND,d0          ;und anzeigen
         bsr       \objc_draw
         move.w    #NAMES,d0
         bsr       \objc_draw
         move.w    #ANZTYP,d0
         bsr       \objc_draw

         bra       \do_form
\not_mover:
         cmp.w     #CLOSER,d7          ;### Klick auf CLOSER ###
         bne       \not_closer
                                       ;einen Ordner zurÅck

         bsr       \such_slash         ;letzen '\' suchen
         cmp.l     #0,a0
         beq       \do_form            ;kein '\' gefunden
         lea       -1(a0),a3
                                       ;1. '\' gefunden
                                       ;2. '\'suchen
                                       ;Adresse in a3 merken
         move.l    a3,a1
         move.l    \path_name(pc),a2
         subq.l    #1,a2               ;Endaddresse fÅr '\' Suche
\l2      subq.l    #1,a1
         cmp.l     a1,a2
         beq       \do_form            ;kein 2. '\' -> fertig

         cmp.b     #'\',(a1)
         bne       \l2
                                       ;Ordner zwischen '\' entfernen
\l3      move.b    (a3)+,(a1)+
         bne       \l3

         bra       \neuer_path         ;und neu anzeigen

\not_closer:
                                       ;### Laufwerksknîpfe abfragen ###
         lea       \knopf_tab(pc),a1
\l4      cmp.w     (a1),d7
         beq       \knopf_found
         cmp.w     #-1,(a1)+
         bne       \l4
         bra       \not_knopf
\knopf_found:                          ;Knopf gefunden
         move.w    (a1),d0
         bsr       \objc_adr
         clr.w     10(a0)              ;wieder normal
         bsr       \objc_draw
         move.b    12(a0),d5           ;Laufwerk nach d5

         btst      #15,d6              ;Doppelklick, dann Routdir
         bne       \root_dir
                                       ;aktuellen path holen
         move.b    d5,d4
         ext.w     d4                  ;auf Wort erweitern
         sub.w     #'A'-1,d4           ;1 = A u.s.w.
         move.l    \path_name(pc),a1
         move.b    d5,(a1)+            ;X: eintragen
         move.b    #':',(a1)+
         move.w    d4,-(sp)            ; GetPath
         pea       (a1)
         move.w    #dgetpath,-(sp)
         trap      #gemdos
         lea       8(sp),sp
         tst.w     d0
         bne       \root_dir           ;bei Fehler ins Root-Direktorie

\l00     tst.b     (a1)+               ;nun noch '\' anhÑngen
         bne       \l00
         subq.l    #2,a1
         cmp.b     #'\',(a1)+
         beq       \schon_da           ;war schon
         move.b    #'\',(a1)+
\schon_da:                             ;und Extension anhÑngen
         lea       \e_teil(pc),a0
\l01     move.b    (a0)+,(a1)+
         bne       \l01
         bra       \neuer_path

\root_dir:
         move.l    \path_name(pc),a1
         move.b    d5,(a1)+            ;X: eintragen
         move.b    #':',(a1)+
         bra       \schon_da           ;und Extension anhÑngen

\not_knopf:
                                       ;### Filenamen abfragen ###
         lea       \file_tab(pc),a1
\lq4     cmp.w     (a1),d7
         beq       \file_found
         cmp.w     #-1,(a1)+
         bne       \lq4
         bra       \not_file
\file_found:
         move.w    d7,d0               ;Filenamen auswerten
         bsr       \objc_adr
         move.l    12(a0),a1
         move.l    (a1),a1

         cmp.b     #'',(a1)           ;Ordner ?
         bne       \is_file

         clr.w     10(a0)              ;Name wieder normal
         lea       2(a1),a2            ;a0 zeigt auf Ordnernamen
         lea       \hilfstext(pc),a3   ;nach Hilfstext Åbertragen
         move.l    a3,a0
\lq5     move.b    (a2)+,(a3)+
         bne       \lq5

         bsr       \blank_raus         ;und Blanks entfernen
         move.w    #-1,d0              ;Laenge Ordnername bestimmen
\l8      addq.w    #1,d0
         tst.b     (a0)+
         bne       \l8
         move.b    #'\',-1(a0)         ;und '\' anhÑngen
         clr.b     (a0)
                                       ;LÑnge -1 in d0

        
         bsr       \such_slash         ;letzes '\' suchen
         cmp.l     #0,a0
         beq       \no_bslash          ;a0 = 0; kein '\' gefunden
                                       ;Pathende ist in a1
                                       ;A0 zeigt hinter '\'

                                       ;Laenge - 1 in d0, fÅr dbra
         lea       1(a1,d0.w),a3       ;a3 neue Endadresse
\l9      move.b    -(a1),-(a3)         ;LÅcke freimachen
         cmp.l     a1,a0
         bne       \l9
\nur_ord:
         lea       \hilfstext(pc),a1   ;und Ordner einfÅgen
\l10     move.b    (a1)+,(a0)+
         tst.b     (a1)
         bne       \l10

         bra       \neuer_path

\no_bslash:                            ;Kein '\' vorhanden
                                       ;dann einfach Ordnername als Path
         move.l    \path_name(pc),a0
         bra       \nur_ord

\is_file:
         move.w    d7,\select_file     ;Merker: File selectiert
         addq.l    #2,a1               ;a1 zeigt auf Filename
         lea       \hilfstext(pc),a0   ;nach Hilfstext Åbertragen
         move.l    a0,a2
\lp1     move.b    (a1)+,(a2)+
         bne       \lp1
         bsr       \blank_raus         ;und konvertieren
         bsr       \konv_name

         move.w    #FILENAME,d0
         move.w    #11,d1
         bsr       \txtcpy             ;und ins Dateifeld Åbertragen
         bsr       \objc_draw          ;und anzeigen


         btst      #15,d6              ;bei Doppelklick noch wie OK
         beq       \do_form
         bra       \its_ok

\not_file:
         cmp.w     #STERN2,d7          ;### Klick auf *.* ###
         bne       \not_stern

         lea       \stern(pc),a2       ;*.* nach letzem '\' anhÑngen
\haeng_dran:
         bsr       \such_slash         ;letzen slash suchen
         cmp.l     #0,a0
         beq       \nein_slash

\ll1     move.b    (a2)+,(a0)+
         bne       \ll1
         move.w    d7,d0               ;und Objekt wieder normal
         bsr       \objc_adr
         clr.w     10(a0)
         bsr       \objc_draw

         bra       \neuer_path
\nein_slash:
         move.l    \path_name(pc),a0   ;kein \, dann \*.*
         move.b    #'\',(a0)+
         bra       \ll1

\not_stern:
         cmp.w     #DEFEXT,d7
         bne       \not_defext
                                       ;### Klick auf *.DEF ###
         move.w    d7,d0
         bsr       \objc_adr
         move.l    12(a0),a2

         bra       \haeng_dran

\not_defext:
         cmp.w     #ABBRUCH,d7         ;### Klick auf Abbruch ###
         bne       \not_abbruch

;         move.l    \path_name(pc),a0   ; Pathname und Filename lîschen
;         clr.b     (a0)
;         move.l    \file_name(pc),a0
;         clr.b     (a0)
         move.l    \taste(pc),a0
         clr.w     (a0)                ; Merker Abbruch
         bra       \das_wars
\not_abbruch:

         cmp.w     #OK,d7              ;### OK angeklickt ? ###
         bne       \not_ok
\its_ok:
         move.w    #FILENAME,d0        ;Dateinamen Åbergeben
         bsr       \objc_adr
         move.l    12(a0),a0
         move.l    (a0),a0
         move.l    \file_name(pc),a1
\lf1     move.b    (a0)+,(a1)+
         bne       \lf1
         move.l    \file_name(pc),a0   ;und korrigieren
         bsr       \punkt_rein
         bsr       \blank_raus
         move.l    \taste(pc),a0
         move.w    #1,(a0)             ;Merker OK
         bra       \das_wars

\not_ok:
         cmp.w     #ERASE,d7           ;### Klick auf File lîschen ###
         bne       \not_erase

         move.w    #13,d0              ;alten Namen in Alert Box lîschen
         lea       \f_name,a0
\lk7     move.b    #' ',(a0)+
         dbra      d0,\lk7

         move.w    #FILENAME,d0        ;Filename nach Hilfstext kopieren
         bsr       \objc_adr
         move.l    12(a0),a0
         move.l    (a0),a0
         lea       \hilfstext(pc),a1
         lea       \f_name(pc),a2
\lk1     move.b    (a0),(a1)+
         move.b    (a0)+,(a2)+         ;und in Alert-Box eintragen
         bne       \lk1

         lea       \f_name(pc),a0
         bsr       \punkt_rein
\s_0     tst.b     (a0)+               ;und Endkennung entfernen
         bne       \s_0
         move.b    #' ',-1(a0)
         move.b    #'.',\f_name+8

         lea       \hilfstext(pc),a0   ;und auf normales Format bringen
         bsr       \punkt_rein
         bsr       \blank_raus

         tst.b     (a0)                ;Testen ob Leername
         bne       \name_lang
         lea       \txt_leer(pc),a0    ;ja, dann Meldung ausgeben
         bsr       \do_allert
         bra       \kill_end
\name_lang:
         lea       \bestaet(pc),a0     ;BestÑtigung erfragen
         bsr       \do_allert
         cmp.w     #1,d0
         beq       \kill_end           ;Datei nicht lîschen

         bsr       \bastel_path
         pea       \search_path(pc)      ;nun lîschen
         move.w    #fdelete,-(sp)
         trap      #gemdos
         addq.l    #6,sp
         tst.l     d0
         bne       \d_error

         move.w    #ERASE,d0
\name_weg:
         bsr       \objc_adr           ;'Datei lîschen' wieder normal
         move.w    #32,10(a0)
         bsr       \objc_draw

         move.w    #FILENAME,d0        ;Filenamen entfernen
         bsr       \objc_adr
         move.l    12(a0),a0
         move.l    (a0),a0
         clr.b     (a0)
         bsr       \objc_draw

         bra       \neuer_path
\d_error:                              ;Fehler
         lea       \f_error(pc),a0
         bsr       \do_allert

\kill_end:
         move.w    #ERASE,d0
\make_normal:
         bsr       \objc_adr           ;'Datei lîschen' wieder normal
         move.w    #32,10(a0)
         bsr       \objc_draw
         bra       \do_form

\not_erase:
         cmp.w     #OPENORD,d7          ;### Klick auf neuer Ordner ###
         bne       \not_openord

         move.w    #13,d0              ;alten Namen in Alert Box lîschen
         lea       \o_name,a0
\lk8     move.b    #' ',(a0)+
         dbra      d0,\lk8

         move.w    #FILENAME,d0        ;Filename nach Hilfstext kopieren
         bsr       \objc_adr
         move.l    12(a0),a0
         move.l    (a0),a0
         lea       \hilfstext(pc),a1
         lea       \o_name(pc),a2
\lk9     move.b    (a0),(a1)+
         move.b    (a0)+,(a2)+         ;und in Alert-Box eintragen
         bne       \lk9

         lea       \o_name(pc),a0
         bsr       \punkt_rein
\s_1     tst.b     (a0)+               ;und Endkennung entfernen
         bne       \s_1
         move.b    #' ',-1(a0)
         move.b    #'.',\o_name+8

         lea       \hilfstext(pc),a0   ;und auf normales Format bringen
         bsr       \punkt_rein
         bsr       \blank_raus

         tst.b     (a0)                ;Testen ob Leername
         bne       \ord_lang
         lea       \ord_leer(pc),a0    ;ja, dann Meldung ausgeben
         bsr       \do_allert
         bra       \ord_end
\ord_lang:
         lea       \anleg(pc),a0       ;BestÑtigung erfragen
         bsr       \do_allert
         cmp.w     #1,d0
         beq       \ord_end            ;Ordner nicht erstellen

                                       ;Abfragen ob Name schon vorhanden
         move.w    #$3F,-(sp)          ;alles suchen
         bsr       \bastel_path
         pea       \search_path(pc)
         move.w    #fsfirst,-(sp)
         trap      #gemdos
         lea       8(sp),sp
         tst.l     d0
         beq       \o_err              ;Fehler, wenn gefunden

         pea       \search_path(pc)    ;nun erstellen
         move.w    #dcreate,-(sp)
         trap      #gemdos
         addq.l    #6,sp
         tst.l     d0
         bne       \o_err

         move.w    #OPENORD,d0
         bra       \name_weg
\o_err:                                 ;Fehler
         lea       \o_error(pc),a0
         bsr       \do_allert

\ord_end:
         move.w    #OPENORD,d0
         bra       \make_normal        ;' neuer Ordner ' wieder normal

\not_openord:


\das_wars:
         move.w    \select_file,d0     ;evt. angeklickten Filenamen
         beq       \no_select          ;noch normalisieren
         bsr       \objc_adr
         clr.w     10(a0)
\no_select:
         move.w    #OK,d0
         bsr       \objc_adr           ;OK und Abbruch normalisieren
         clr.w     10(a0)
         move.w    #ABBRUCH,d0
         bsr       \objc_adr
         clr.w     10(a0)


         move.w    #wind_update,d0     ;Mauskontrolle abgeben
         move.l    #$01010000,d1
         move.w    #end_mctrl,(a5)
         bsr       aescall

         move.w    #form_dial,d0
         move.l    #$09010100,d1
         move.w    #3,(a5)             ;Bildschirm-Speicher freigeben
         move.l    \ob_x(pc),2(a5)
         move.l    \ob_br(pc),6(a5)
         move.l    2(a5),10(a5)
         move.l    6(a5),14(a5)
         bsr       aescall
         bclr      #0,\mal_flag        ; war ueberhaupt ein malloc ?
         beq       \end_box2           ; nî
         move.l    \dir_tab,-(sp)      ;Speicher freigeben
         move.w    #mfree,-(sp)
         trap      #gemdos
         addq.l    #6,sp
\end_box2:
         move.l    \dta_old(pc),-(sp)  ;alten DTA-Buffer wieder setzen
         move.w    #$1A,-(sp)
         trap      #gemdos
         addq.l    #6,sp

         move.l    \error,a0
         move.w    \err_aus,(a0)       ;INTOUT(0) setzen (0=Fehler)

         movem.l   (sp)+,a0-a6/d0-d7

         move.l    \rette_sp(pc),sp    ;wieder alten Stack

         move.l    \ret_adr,-(sp)      ;und ab ins Hauptprogramm
         rts

;=====================================================
;             allgemeine Unterprogramme
;=====================================================

;-----------------------------------------
; do_allert: Allert Box zeichnen
;    a0 zeigt auf text
;    d0 enthÑlt Abbruchnummer
;-----------------------------------------
\do_allert:
         move.l    a0,-(sp)

         move.w    #1,(a5)             ;Default Knopf ist 1
         move.l    a0,(a6)             ;String nach ADDRIN(0)
         move.w    #form_alert,d0
         move.l    #$01010100,d1
         bsr       aescall

         move.w    intout(pc),d0

         move.l    (sp)+,a0
         rts

;-----------------------------------------
;  Slider-Grîûe berechnen
;-----------------------------------------

\count_slider:
         movem.l   d0/d3-d5/a0,-(sp)

         move.w    \anzahl,d5
                                       ;Slider-Grîûe berechnen
         move.w    #GROUND,d0
         bsr       \objc_adr           ;a0 = Adresse Hintergrund

         move.w    22(a0),d3           ;d3 = maximale Hîhe
         move.w    d3,\slid_max
         move.w    20(a0),d4           ;d4 = minimale Hîhe = Breite

         move.w    #SLIDER,d0
         bsr       \objc_adr           ;Adr. Slider berechnen

         clr.w     18(a0)              ;ob_y = 0
         move.w    d3,22(a0)           ;max. Grîûe

         cmp.w     #10,d5
         bcs       \hight_ok           ;bei weniger 10 Files -> Slider max.

         mulu      #9,d3               ;Grîûe = 9 * max / Anzahl Files
         divu      d5,d3
         cmp.w     d4,d3               ;Slider aber nicht zu klein machen
         bcc       \not_min
         move.w    d4,d3
\not_min:
         move.w    d3,22(a0)           ;berechnete Grîûe eintragen
         move.w    d3,\slid_is
\hight_ok:
         movem.l   (sp)+,d0/d3-d5/a0
         rts

;---------------------------------------------------------------
;  zeig_an:  öbertrÑgt Filenamen ab \abnumr in die Anzeige
;---------------------------------------------------------------

\zeig_an:
         movem.l   d0-d5/a0-a5,-(sp)

         move.w    #ANZTYP,d0          ;Anzeigetyp Åbertragen
         move.w    #14,d1
         lea       \name_anz(pc),a0
         tst.w     \anz_art            ;\anz_art = 0 -> Dateiname
         beq       \zeig_text
         lea       \lang_anz(pc),a0
         cmp.w     #1,\anz_art         ;\anz_art = 1 -> DateilÑnge
         beq       \zeig_text
         lea       \dat_anz(pc),a0     ;sonst Datum / Zeit
\zeig_text:
         bsr       \txtcpy

         move.w    #9,d4               ;Anzahl Anzeige-PlÑtze
         lea       \file_tab(pc),a5    ;Zeiger auf Tabelle mit Index
                                       ;Werten der 9 Filnamen
         move.w    \anzahl,d3          ;Anzahl der zu Åbertragenden
         beq       \hide_rest          ;Files berechnen
         sub.w     \abnumr,d3
         cmp.w     #9,d3               ;jedoch nicht mehr als 9 anzeigen
         bcs       \num_ok
         move.w    #8,d3
\num_ok:
         move.l    \dir_tab(pc),a3     ;Zeiger vor ersten Filenamen
         lea       -14(a3),a3

         move.w    \abnumr,d2          ;Namen vor \abnumr Åberspringen
         subq.w    #1,d2
\lx4     lea       24(a3),a3
         dbra      d2,\lx4             ;a3 zeigt nun auf ersten Filenamen

\next_anz:
         lea       \hilfstext(pc),a2   ;nach Hilfstext Åbertragen

         tst.w     \anz_art            ;Dateinamen anzeigen ?
         bne       \tst_lang

;  Dateinamen anzeigen

         move.w    #'  ',(a2)          ;File annehmen
         cmp.b     #$10,-9(a3)         ;Atribut testen
         bne       \no_sub             ;kein Ordner OK!
         move.w    #' ',(a2)          ;sonst Ordner Symbol eintragen
\no_sub:
         addq.l    #2,a2
         move.l    a3,a4
\lx5     move.b    (a4)+,(a2)+         ;Filenamen in Hilfsspeicher
         bne       \lx5
         move.b    #' ',-1(a2)         ;und noch ein Blank anhÑngen
         clr.b     (a2)
         bra       \rueber

; DateilÑnge anzeigen

\tst_lang:
         cmp.w     #1,\anz_art         ;DateilÑnge ?
         bne       \nimm_datum

         move.w    #14,d0              ;\hilfstext voll Blanks
\lt4     move.b    #' ',(a2)+
         dbra      d0,\lt4
         clr.b     (a2)                ;a2 zeigt hinter Hilfstext
         subq.l    #4,a2               ;sieht besser aus

         move.l    -4(a3),d0           ;Anzahl Bytes
         bsr       hex_dez             ;Dezimal wandeln
         move.l    a0,a1               ;rechtsbÅndig nach \hilfstext

\lt3     tst.b     (a1)+               ;Ende suchen
         bne       \lt3
         subq.l    #1,a1               ;a1 zeigt hinter Zahl

\lt5     move.b    -(a1),-(a2)         ;Zahl Åbertragen
         cmp.l     a1,a0
         bne       \lt5

         bra       \rueber


; Datum / Zeit anzeigen

\nimm_datum:

         move.w    -6(a3),d0           ;Datum lesen
         and.l     #$1F,d0             ;Tag isolieren
         bsr       \hex_dez_0          ;dezimal wandeln
         move.b    (a0)+,(a2)+         ;und eintragen
         move.b    (a0)+,(a2)+
         move.b    #'/',(a2)+

         move.w    -6(a3),d0           ;dito mit Monat
         and.l     #$1E0,d0
         lsr.l     #5,d0
         bsr       \hex_dez_0
         move.b    (a0)+,(a2)+
         move.b    (a0)+,(a2)+
         move.b    #'/',(a2)+

         move.w    -6(a3),d0           ;dito mit Jahr
         and.l     #$FE00,d0
         lsr.l     #5,d0
         lsr.l     #4,d0
         add.w     #80,d0              ;Jahr + 80
         cmp.w     #100,d0
         bcs       \jahr_ok
         sub.w     #100,d0
\jahr_ok bsr       \hex_dez_0
         move.b    (a0)+,(a2)+
         move.b    (a0)+,(a2)+
         move.b    #' ',(a2)+
         move.b    #' ',(a2)+

 
         move.w    -8(a3),d0           ;Stunden
         and.l     #$F800,d0
         lsr.l     #5,d0
         lsr.l     #6,d0
         bsr       \hex_dez_0
         move.b    (a0)+,(a2)+
         move.b    (a0)+,(a2)+
         move.b    #':',(a2)+

         move.w    -8(a3),d0           ;und noch Minuten
         and.l     #$7E0,d0
         lsr.l     #5,d0
         bsr       \hex_dez_0
         move.b    (a0)+,(a2)+
         move.b    (a0)+,(a2)+
         move.b    #':',(a2)+
         clr.b     (a2)

\rueber:
         move.w    (a5)+,d0
         bsr       \objc_adr           ;bei Datum und LÑnge
         and.w     #%0111110,8(a0)     ;not selectable, not touchexit
         tst.w     \anz_art
         bne       \disab              ;bei Namen:
         or.w      #%1010001,8(a0)     ;selectable, radio, touchexit
\disab:  clr.w     10(a0)              ;normal
         lea       \hilfstext(pc),a0   ;und in Anzeigetext
         move.w    #15,d1
         bsr       \txtcpy

         lea       24(a3),a3
         subq.w    #1,d4               ;wieder einen Namen eingetragen
         dbra      d3,\next_anz
\hide_rest:
         tst.w     d4                  ;alles ausgefÅllt, dann fertig
         beq       \anz_fertig
         subq.w    #1,d4
\lx6:
         move.w    (a5)+,d0            ;sonst Rest leeren
         bsr       \objc_adr
         and.w     #%0111110,8(a0)     ;not selectable, not touchexit
         clr.w     10(a0)              ;normal
         lea       \empty(pc),a0
         move.w    #15,d1
         bsr       \txtcpy             ;und Leerstring eintragen
         dbra      d4,\lx6
\anz_fertig:
         clr.w     \select_file        ;Merker: Kein File angekickt
         movem.l   (sp)+,d0-d5/a0-a5
         rts

;----------------------------------------------------
;  hex_dez_0:
;
;  ruft Hex_dez auf, wandelt dann aber einstellige
;  Zahl in zweistellige Zahl, also z.B. 3 in 03
;----------------------------------------------------

\hex_dez_0:
         move.w    d0,-(sp)
         bsr       hex_dez
         tst.b     1(a0)
         bne       \dez_ok
         move.b    (a0),d0
         move.b    #'0',(a0)
         move.b    d0,1(a0)
         clr.b     2(a0)
\dez_ok: move.w    (sp)+,d0
         rts

;------------------------------------------------------------------
;  read_dir: liest Direktorie des akt. Pfades ein
;
;  Ausgabe:  \dir_tab: Zeiger auf Adresse mit geordnetem Direkt.
;            (\dir_tab wurde mit malloc angefordert)
;          
;            Aufbau der Tabelle:
;                                 0:  dummy
;                                 1:  File-Attribut (10H = Subdir.)
;                               2+3:  Uhrzeit
;                               4+5:  Datum
;                               6-9:  LÑnge
;                             10-23:  Name
;
;
;            \anzahl:  Anzahl der Files im akt. Pfad
;
;            d0.w = 0 alles OK!   sonst Fehler bei Malloc!
;
;   Um auch alle Ordner zu suchen, wird erst mit *.* nach Ordnern
;   und dann mit dem richtigen Suchbegriff nach normalen Files
;   gesucht!
;
;-------------------------------------------------------------------

\read_dir: 
         movem.l   d2/d6-d7/a0-a4,-(sp)
         clr.b     \mal_flag           ; kein malloc
         clr.w     \anzahl

         clr.w     d7                  ;FilezÑhler lîschen

         move.w    #$11,d6             ;$10 = Attribut fÅr Ordner
         lea       \stern(pc),a4       ;Suchbegriff *.*
\suche_wieder:
         move.w    d6,-(sp)            ;Files und Subdirs suchen
         bsr       \bau_path
         pea       \search_path(pc)
         move.w    #fsfirst,-(sp)
         trap      #gemdos
         lea       8(sp),sp
         tst.w     d0
         bne       \last_file

         cmp.w     #1,d6               ;wenn nach Files suchen OK
         beq       \add1
         move.l    \dta_adr(pc),a0     ;Test ob auch wirklich Ordner
         btst      #4,21(a0)
         beq       \next_file          ;Bit 4 = 0 -> kein Ordner
         cmp.b     #'.',30(a0)         ;beginnt mit . -> Dummy Ordner
         beq       \next_file
\add1:
         addq.w    #1,d7               ;ein File gefunden, also Anzahl+1
\next_file:
         move.w    #fsnext,-(sp)       ;weiter suchen
         trap      #gemdos
         addq.l    #2,sp
         tst.w     d0
         bne       \last_file

         cmp.w     #1,d6               ;wenn nach Files suchen OK
         beq       \add1
         move.l    \dta_adr(pc),a0     ;Test ob auch wirklich Ordner
         btst      #4,21(a0)
         beq       \next_file          ;Bit 4 = 0 -> kein Ordner
         cmp.b     #'.',30(a0)         ;beginnt mit . -> Dummy Ordner
         beq       \next_file
         bra       \add1
\last_file:
         cmp.w     #$11,d6             ;wenn $10, dann noch nach Files
         bne       \s_ready            ;suchen
         moveq     #1,d6
         lea       \e_teil(pc),a4
         bra       \suche_wieder
\s_ready:
         move.w    d7,\anzahl          ;Anzahl merken
         beq       \count_ready        ;bei 0 Files fertig

         mulu      #24,d7              ;Anzahl der benîtigten Bytes
         move.l    d7,-(sp)            ;reservieren
         move.w    #malloc,-(sp)
         trap      #gemdos
         addq.l    #6,sp
         tst.l     d0
         beq       \m_error
         move.b    #1,\mal_flag        ; malloc ok
         move.l    d0,\dir_tab         ;und Tabellenanfang merken
         move.l    d0,a3

         move.w    #$11,d6             ;wieder erst Ordner
         lea       \stern(pc),a4
\lese_weiter:
         move.w    d6,-(sp)            ;Files und Subdirs suchen
         bsr       \bau_path
         pea       \search_path
         move.w    #fsfirst,-(sp)
         trap      #gemdos
         lea       8(sp),sp

         move.l    \dta_adr(pc),a0     ;Dta-Buffer Åbertragen
         cmp.w     #1,d6
         beq       \trag_ein           ;bei Files eintragen
         btst      #4,21(a0)           ;ORDNER erst nachsehen
         beq       \next_read
         cmp.b     #'.',30(a0)         ;Name mit . -> Dummy Ordner
         beq       \next_read
\trag_ein:
         lea       20(a0),a0           ;undef. Teil interessiert nicht
         move.w    #23,d0
\lp40    move.b    (a0)+,(a3)+
         dbra      d0,\lp40

\next_read:
         move.w    #fsnext,-(sp)       ;weiter suchen
         trap      #gemdos
         addq.l    #2,sp
         tst.w     d0
         bne       \last_read

         move.l    \dta_adr(pc),a0     ;Dta-Buffer Åbertragen
         cmp.w     #1,d6
         beq       \trag_ein1          ;bei Files eintragen
         btst      #4,21(a0)           ;ORDNER erst nachsehen
         beq       \next_read
         cmp.b     #'.',30(a0)         ;Name mit . -> Dummy Ordner
         beq       \next_read
\trag_ein1:
         lea       20(a0),a0           ;undef. Teil intr. nicht
         move.w    #23,d0
\lp41    move.b    (a0)+,(a3)+
         dbra      d0,\lp41
         bra       \next_read
\last_read: 
         cmp.w     #$11,d6             ;wenn $10 noch Files einlesen
         bne       \les_ok
         moveq     #1,d6
         lea       \e_teil(pc),a4
         bra       \lese_weiter
\les_ok:
                                       ;Direktorie ist nun eingelesen

         move.w    \anzahl,d2          ;nun Namen korrigieren
         subq.w    #1,d2

         move.l    \dir_tab(pc),a2
         lea       10(a2),a2           ;a2 zeigt auf ersten Filnamen
\lx3     move.l    a2,a0
         bsr       \konv_name
         bsr       \punkt_rein

         move.l    a2,a0               ;Namen mit Blanks auf 12 Stellen
         move.w    #11,d0              ;fÅllen
\such_0:
         tst.b     (a0)+               ;Zeichen = 0?
         beq       \is_0
         dbra      d0,\such_0
         bra       \nam_ok
\is_0:   subq.l    #1,a0               ;0 und Rest mit Blanks Åberschreiben
\bl_rein move.b    #' ',(a0)+
         dbra      d0,\bl_rein
         clr.b     (a0)                ;und Endekennung
\nam_ok:
         lea       24(a2),a2           ;a2 zeigt auf nÑchsten Filenamen

         dbra      d2,\lx3

                                       ;nun noch Namen alphabetisch
                                       ;sortieren
         cmp.w     #1,\anzahl          ;bei einem File nicht sort.
         beq       \count_ready

         move.l    \dir_tab(pc),a3
         lea       10(a3),a3           ;a3 zeigt auf ersten Filenamen
         lea       24(a3),a4           ;a4 zeigt auf 2. Filenamen
         move.l    a3,a2
         move.w    \anzahl,d0
         subq.w    #1,d0
         mulu      #24,d0
         add.l     d0,a2               ;a2 zeigt auf letzen Filenamen

\next_comp:
         bsr       \f_tausch           ;Vergleichen und evt. Tauschen

         cmp.l     a4,a2               ;2. Zeiger am Ende ?
         beq       \end_2
         lea       24(a4),a4           ;nein, dann 2.Zeiger erhîhen
         bra       \next_comp
\end_2:
         lea       24(a3),a3           ;ja, dann 1.Zeiger erhîhen
         cmp.l     a3,a2               ;auch am Ende, dann fertig
         beq       \count_ready
         lea       24(a3),a4           ;nein -> neuer Durchgang
         bra       \next_comp

\count_ready:
         clr.w     d0
\dir_end movem.l   (sp)+,d2/d6-d7/a0-a4
         rts

\m_error:
         moveq     #1,d0
         bra       \dir_end

;-------------------------------------------------------
;  f_tausch: Vergleicht und tauscht evt. Filenamen
;            die bei (a3) und (a4) stehen
;-------------------------------------------------------

\f_tausch:
         movem.l   d0-d1/a1-a2,-(sp)
                                       ;Strings bei (a3) und (a4) vergl.
         move.l    a3,a1
         move.l    a4,a2               ;Zeiger retten
         btst      #4,-9(a3)           ;testen ob 1. Name Ordner
         bne       \ord_1
         btst      #4,-9(a4)
         beq       \sort               ;beides Files, also vergleichen
         bra       \tausch             ;1. File ; 2. Ordner -> tauschen
\ord_1:  btst      #4,-9(a4)
         beq       \sort_ok            ;1. Ordner; 2. File -> Ok
\sort:                                 ;beides Ordner, also vergleichen
         move.w    #11,d0              ;max. 12 Zeichen vergleichen
         cmpm.b    (a1)+,(a2)+
         bcs       \tausch
         dbne      d0,\sort
         bra       \sort_ok            ;Files stehen richtig
\tausch: lea       -10(a3),a1          ;dta-Block austauschen
         lea       -10(a4),a2
         move.w    #23,d1
\lt1:    move.b    (a1),d0
         move.b    (a2),(a1)+
         move.b    d0,(a2)+
         dbra      d1,\lt1
\sort_ok:
         movem.l   (sp)+,d0-d1/a1-a2
         rts
;-----------------------------------------------------
;  blank_raus: entfernt Blanks aus Filenamen
;              a0 zeigt auf Filenamen
;-----------------------------------------------------

\blank_raus:
         movem.l   a0-a1,-(sp)

\such_blank:
         cmp.b     #' ',(a0)           ;Blank suchen
         beq       \is_blank
         tst.b     (a0)+
         bne       \such_blank

         movem.l   (sp)+,a0-a1
         rts

\is_blank:
         move.l    a0,a1               ;gefundenes Blank entfernen
\lb1     move.b    1(a0),(a0)+
         bne       \lb1
         lea       (a1),a0
         bra       \such_blank


;-----------------------------------------------------
;  Dateinamen konvertieren
;
;  z.B.:    HUGO.BAK    ->  HUGO    BAK
;
;  Eingabe:  a0 zeigt auf Filenamen
;  Ausgabe:  a0 zeigt auf konvertierten Filenamen
;-----------------------------------------------------

\konv_name:
         movem.l   d0/a0-a2,-(sp)
         move.l    a0,a2
         lea       \helptxt(pc),a1     ;a1 Zeiger auf neuen Text

         move.w    #7,d0               ;Bis Punkt Åbertragen
\lp3     cmp.b     #'.',(a0)
         beq       \is_punkt
         move.b    (a0)+,(a1)+
         dbra      d0,\lp3
                                       ;8 Zeichen Åbertragen
         cmp.b     #'.',(a0)+          ;doch noch Punkt ?
         bne       \nam_end
\extens                                ;also nÑchstes Zeichen Åberspringen
         move.w    #2,d0               ;und noch 3 Zeichen Åbertagen
\lp4     move.b    (a0)+,(a1)+
         dbra      d0,\lp4
\nam_end clr.b     (a1)                ;und 0 als Endkennung

         lea       \helptxt(pc),a1     ;und Text zurÅckÅbertragen
\lpx2    move.b    (a1)+,(a2)+
         bne       \lpx2

         movem.l   (sp)+,d0/a0-a2
         rts

\is_punkt:                             ;Punkt gefunden, also mit Blanks
\lp5     move.b    #' ',(a1)+          ;auffÅllen
         dbra      d0,\lp5
         addq.l    #1,a0               ;Punkt natÅrlich Åberspr.
         bra       \extens             ;und noch Extension anhÑngen
 
         bss

\helptxt ds.b      14

         text

;-----------------------------------------------------------
; punkt_rein: wandelt datei hugo    bak -> in hugo    .bak
; Stringzeiger in a0
;-----------------------------------------------------------

\punkt_rein:
         movem.l   d0-d2/a0,-(sp)

         lea       8(a0),a0            ;a0 zeigt auf punkt
         move.b    (a0),d0
         beq       \pu_end             ;wenn Name genau 8 Zei. kein Punkt
         move.b    #'.',(a0)+          ;verschieben und Punkt einfÅgen
         moveq     #4,d2               ;max. 3 Zeichen & 0
\n_ch    move.b    (a0),d1
         move.b    d0,(a0)+
         beq       \pu_end
         move.b    d1,d0
         subq      #1,d2
         bne.s     \n_ch
\pu_end:
         movem.l   (sp)+,d0-d2/a0

         rts

;-----------------------------------------------------
;  such_slash
;
;  a0 zeigt auf hinter '\' oder 0 wenn nicht gefunden
;  a1 zeigt auf Stringende (hinter 0)
;------------------------------------------------------

\such_slash:
         move.l    a2,-(sp)
         move.l    \path_name(pc),a1   ;letzes '\' suchen
         lea      -1(a1),a0            ;a0 ist Adr. Suchende

\l6      tst.b     (a1)+
         bne       \l6                 ;Ende suchen
         move.l    a1,a2               ;und in a1 merken

\l7      subq.l    #1,a2               ;'\' suchen
         cmp.l     a2,a0
         beq       \no_bs              ;kein '\'gefunden
         cmp.b     #'\',(a2)
         bne       \l7
         lea       1(a2),a0            ;a0 zeigt hinter '\'
\bs_ret:
         move.l    (sp)+,a2
         rts
\no_bs:
         sub.l     a0,a0
         bra       \bs_ret

;------------------------------------------------------
;         Pfadnamen zerlegen und korrigieren
;
;  Eingabe: a0 zeigt auf Pfadnahmen mit Suchextension
;  Ausgabe: p_teil, e_teil und e_blank enthalten Strings
;------------------------------------------------------

\hack_pfad:
         movem.l   d0-d1/a0-a4,-(sp)

         move.l    a0,a3               ;Zeiger retten

         tst.b     (a0)                ;Pfad leer, dann A:\*.* eintragen
         bne       \not_leer
\a_trans lea       \a_pfad(pc),a1
\lp6     move.b    (a1)+,(a0)+
         bne       \lp6
\not_leer:
         move.l    a3,a0
         cmp.b     #':',1(a0)          ;2.Zeichen = ':', dann muû
         bne       \next1              ;3.Zeichen '\' sein!
         cmp.b     #'\',2(a0)          ;sonst einfÅgen
         beq       \next1
         addq.l    #2,a0               ;a0 zeigt hinter ':'
         move.b    (a0),d0             ;Zeichen merken
         move.b    #'\',(a0)+          ;'\' einfÅgen
\lp7     move.b    (a0),d1             ;nÑchstes Zeichen lesen
         move.b    d0,(a0)+            ;und mit letztem Zeichen Åberschr.
         beq       \next1              ;u.s.w. bis 0 erreicht
         move.b    d1,d0
         bra       \lp7
\next1:
         move.l    a3,a0               ;nun nach letztem '\' im Text suchen
         sub.l     a1,a1               ;Merker: noch kein '\' gefunden
\lp8     cmp.b     #'\',(a0)
         bne       \no_bsl
         move.l    a0,a1               ;'\' Adresse nach a1
\no_bsl  tst.b     (a0)+
         bne       \lp8
                                       ;in a1 steht nun Adresse des letzen
                                       ;'\' oder 0
         move.l    a3,a0
         cmp.l     #0,a1               ;kein '\' vorhanden, dann A:\*.*
         beq       \a_trans            ;einsetzen

         tst.b     1(a1)               ;wenn '\' letzes Zeichen, dann
         bne       \gibt_ext           ;*.* anhÑngen
         move.l    a1,a0
         addq.l    #1,a0
         lea       \stern(pc),a2
\lp9     move.b    (a2)+,(a0)+
         bne       \lp9
\gibt_ext:
         cmp.b     #'*',1(a1)          ;aus * oder *. wird *.* gemacht
         bne       \ext_gut
         tst.b     2(a1)
         bne       \not_st
         move.b    #'.',2(a1)
         move.b    #'*',3(a1)
         clr.b     4(a1)
         bra       \ext_gut
\not_st  cmp.b     #'.',2(a1)
         bne       \ext_gut
         tst.b     3(a1)
         bne       \ext_gut
         move.b    #'*',3(a1)
         clr.b     4(a1)

\ext_gut:                              ;Pfad ist nun einigermaûen
         lea       \e_teil(pc),a0      ;brauchbar
         lea       \e_blank(pc),a4
         move.b    #' ',(a4)+
         addq.l    #1,a1               ;also Extension abtrennen
         move.l    a1,a2
\lp10    move.b    (a1),(a0)+
         move.b    (a1)+,(a4)+
         bne       \lp10
         move.b    #' ',-1(a4)
         clr.b     (a4)
         move.b    (a2),d0             ;und Pfad abtrennen
         clr.b     (a2)                ;Ende Pfad markieren
         lea       \p_teil(pc),a0
\lp11    move.b    (a3)+,(a0)+
         bne       \lp11
         move.b    d0,(a2)             ;Endekennung wieder weg

         movem.l   (sp)+,d0-d1/a0-a4
         rts

;---------------------------------------------------------------
;  upper: wandelt String auf den a0 zeigt in Grossbuchstaben um
;---------------------------------------------------------------

\upper:  move.l    a0,-(sp)
         subq.l    #1,a0

\lp12    addq.l    #1,a0
         tst.b     (a0)                ;Stringende testen
         beq       \u_end

         cmp.b     #"a",(a0)           ;wenn kleiner 'a' fertig
         bcs       \lp12
         bclr      #5,(a0)             ;sonst Bit lîschen
         bra       \lp12
\u_end:  move.l    (sp)+,a0
         rts

;------------------------------------------------------
;  txtcpy
;
;  kopiert string auf den a0 zeigt in den Text
;  des TEXT-Object mit der Indexnummer in d0.w
;  Es werden max. d1.w Zeichen kopiert
;------------------------------------------------------

\txtcpy: movem.l   d0-d1/a0-a1,-(sp)
         move.l    a0,a1
         bsr       \objc_adr           ; Adresse Object nach a0
         move.l    12(a0),a0           ; a0 zeigt nun auf TEDINFO
         move.l    (a0),a0             ; a0 zeigt nun auf Text

         subq.w    #1,d1
\li1:    move.b    (a1)+,(a0)+         ; Text Åbertragen (ENDE = 0)
         dbeq       d1,\li1
         clr.b     (a0)
         movem.l   (sp)+,d0-d1/a0-a1
         rts

;------------------------------------------------------
;  strcpy
;
;  kopiert string auf den a0 zeigt in den Text
;  des String-Object mit der Indexnummer in d0.w
;  Es werden max. d1.w Zeichen kopiert
;------------------------------------------------------

\strcpy: movem.l   d0-d1/a0-a1,-(sp)
         move.l    a0,a1
         bsr       \objc_adr           ; Oject_Adresse nach a0
         move.l    12(a0),a0           ; a0 zeigt nun auf String

         subq.w    #1,d1
\lp2:    move.b    (a1)+,(a0)+         ; Text Åbertragen (ENDE = 0)
         dbeq      d1,\lp2
         clr.b     (a0)
         movem.l   (sp)+,d0-d1/a0-a1
         rts

;------------------------------------------------------
;  Objc_Draw: zeichnet Objekt mit Index in d0.w
;------------------------------------------------------

\objc_draw:
         movem.l   d0-d1/a0,-(sp)
         move.w    d0,(a5)             ;Index
         move.w    #max_depth,2(a5)
         move.l    \ob_x(pc),4(a5)
         move.l    \ob_br(pc),8(a5)
         move.l    fsel_adr(pc),(a6)
         move.w    #objc_draw,d0
         move.l    #$06010100,d1
         bsr       aescall
         movem.l   (sp)+,d0-d1/a0
         rts

;------------------------------------------------------------------
;  Objc_Adresse: Berechnet Adresse des Obj. mit Index d0.w nach a0
;------------------------------------------------------------------

\objc_adr:
         move.l    d0,-(sp)
         move.l    fsel_adr(pc),a0
         mulu      #24,d0
         add.l     d0,a0
         move.l    (sp)+,d0
         rts

;------------------------------------------------
; path fÅr neuen Ordner und File loeschen basteln
;------------------------------------------------
\bastel_path:
         movem.l   a0/a1,-(sp)
         lea       \p_teil(pc),a0
         lea       \search_path(pc),a1
\copy3:  move.b    (a0)+,(a1)+
         bne       \copy3
         subq.l    #1,a1
         lea       \hilfstext(pc),a0
\copy4:  move.b    (a0)+,(a1)+
         bne       \copy4
         movem.l   (sp)+,a0/a1
         rts
;-----------------------------------------------
; path fÅr fsfirst aufbauen
;-----------------------------------------------
\bau_path:
         movem.l   a0/a1/a4,-(sp)
         lea       \p_teil(pc),a0       ;kompletten Path aufbauen
         lea       \search_path(pc),a1
\copy_1: move.b    (a0)+,(a1)+
         bne       \copy_1
         subq.l    #1,a1
\copy_2: move.b    (a4)+,(a1)+
         bne       \copy_2
         movem.l   (sp)+,a0/a1/a4
         rts



         data
\knopf_tab:
         dc.w      drive0,drive1,drive2,drive3,drive4,drive5
         dc.w      drive6,drive7,drive8,drive9,drive10,drive11,-1

\file_tab:
         dc.w      file1,file2,file3,file4,file5,file6,file7,file8,file9,-1

\name_anz:
         dc.b      ' Dateiname ',0
         align
\lang_anz:
         dc.b      ' DateilÑnge ',0
         align
\dat_anz:
         dc.b      ' Datum / Zeit ',0
         align

\empty:  dc.b      '               ',0  ;15 Blanks zum Dateinamen Åberschr.

\a_pfad: dc.b      'A:\'
\stern:  dc.b      '*.*',0
         align

\txt_leer:
         dc.b      '[1][Ein File ohne Dateinamen|kann ich leider nicht|'
         dc.b      'lîschen!][ Tja ]',0
         align
\bestaet:
         dc.b      '[2][Wollen Sie die Datei|    '
\f_name  dc.b      '                  | wirklich  lîschen?]'
         dc.b      '[Nein| Ja ]',0
         align
\f_error:
         dc.b      '[1][Fehler beim Lîschen!|'
         dc.b      'Evt. Datei nicht gefunden,|'
         dc.b      'oder Datei hat den|'
         dc.b      'NUR LESEN  Status.]'
         dc.b      '[ #@! ]',0
         align
\ord_leer:
         dc.b      '[2][Meinen Sie nicht, daû Sie|'
         dc.b      'einen Ordner mit Namen spÑter|'
         dc.b      'leichter wiederfinden!]'
         dc.b      '[ Tja ]',0
         align
\anleg:  dc.b      '[2][Wollen Sie den Ordner|    '
\o_name  dc.b      '                  |   neu  erstellen?]'
         dc.b      '[Nein| Ja ]',0
         align
\o_error:
         dc.b      '[1][Der neue Ordner kann nicht|'
         dc.b      'erstellt werden! Evt. ist der|'
         dc.b      'Name schon belegt, oder die|'
         dc.b      'Diskette voll.]'
         dc.b      '[ #@! ]',0
         align

         bss

\dta_adr:
         ds.l      1                   ;Adresse des DTA-Buffers
\mal_flag:
         ds.b      1                   ;1 nach malloc 0 sonst
         align
\dir_tab:
         ds.l      1                   ;Adresse der Direktorie-Tabelle

\anzahl:
         ds.w      1                   ;Anzahl der Files
\abnumr:
         ds.w      1                   ;Nummer des ersten Files in der
                                       ;Anzeige
\anz_art:
         ds.w      1                   ;Art der Anzeige:
                                       ;0=Name; 2=Laenge; 3=Datum/Zeit

\ob_x:   ds.w      1                   ;Koordinaten der File-Box
\ob_y:   ds.w      1                   ;mÅssen so hintereinander stehen
\ob_br:  ds.w      1
\ob_ho:  ds.w      1

\slid_max:
         ds.w      1                   ;Grîûe des ganzen Sliders
\slid_is:
         ds.w      1                   ;akt. Slider Grîûe

\select_file:
         ds.w      1                   ;Index des selektierten Filenamen

\p_teil  ds.b      150                 ;Pfadname
\e_teil  ds.b      20                  ;Extension
\e_blank ds.b      22                  ;Extension mit Blanks umrandet
\search_path ds.b  160
\err_aus:
         ds.w      1                   ;RÅckgabewert fÅr INTOUT(0)

\hilfstext:
         ds.b      20

\dta_old:
         ds.l      1                   ;alte DTA-Adresse
\dtabuf:
         ds.b      44

\rette_sp:
         ds.l      1                   ;Speicher fÅr Stackpointer

         ds.b      500
\stack_neu:                            ;Platz fÅr neuen Stack

fsel_adr:
         ds.l      1                   ;Adresse des Hauptbaumes

         align


         end
 