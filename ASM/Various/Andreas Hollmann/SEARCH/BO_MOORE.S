;******************************************************************************
;*                'Boyer-Moore'-Algorithmus zur String-Suche                  *
;*   Autor:       Andreas Hollmann, Paderborn                                 *
;*                (c) MAXON Computer GmbH                                     *
;*   Sprache:     Assembler                                                   *
;******************************************************************************
; Aufruf:  pos%=C:adr%(L:p_file,L:file_len%,L:p_search%,W:search_len&,L:p_buf%)
; Stack-Offset:            4          8          12          16          18
;
; Parameter:
; p_file%     = Pointer auf den zu durchsuchenden Speicherbereich
; file_len%   = LÑnge des zu durchsuchenden Speicherbereichs
; p_search%   = Pointer auf den zu suchenden String
; search_len& = LÑnge des auszugebenden Strings
; p_buf%      = Pointer auf 256 Byte shift-buffer
; pos%        = Position des Strings relativ zum Dateianfang
;------------------------------------------------------------------------------
            move.w    16(sp),d7       ;StringlÑnge steht in d7

;shift-buffer mit StringlÑnge fÅllen:
            movea.l   18(sp),a0       ;Pointer auf 256 Byte shift-buffer laden
            move.w    #255,d0         ;256 Byte mit StringlÑnge fÅllen
fill_buf:   move.b    d7,(a0)+        ;StringlÑnge eintragen
            dbra      d0,fill_buf     ;bis zum Ende des shift-buffers

;String von rechts nach links scannen und Verschiebe-Werte eintragen:
            movea.l   12(sp),a0       ;Pointer auf String laden
            adda.w    d7,a0           ;auf Stringende 'ASCII 0' setzen
            movea.l   18(sp),a1       ;Pointer auf 256 Byte shift-buffer laden
            moveq     #0,d6           ;RÅckwÑrts-ZÑhler auf Position 0 setzen
shift_loop: move.b    -(a0),d0        ;Zeichen laden
            ext.w     d0              ;auf Wortbreite erweitern
            cmp.b     0(a1,d0.w),d7   ;shift-buffer-Position schon belegt ?
            bne.s     inc_count       ;ja: keinen Verschiebe-Wert eintragen
            move.b    d6,0(a1,d0.w)   ;nein: Verschiebe-Wert eintragen
inc_count:  addq.w    #1,d6           ;RÅckwÑrts-ZÑhler inkrementieren
            cmp.w     d6,d7           ;Stringende erreicht ?
            bhi.s     shift_loop      ;immanonich ?, -> weitershiften
;der shift-buffer ist jetzt mit den Verschiebe-Werten gefÅllt.

;jetzt geht es mit der eigentlichen String-Suche los:
            movea.l   4(sp),a0        ;Pointer auf Datei-Anfang laden
            move.l    8(sp),d6        ;Datei-LÑnge laden
            lea       -1(a0,d7.w),a0  ;Pointer auf letztes Zeichen setzen
            movea.l   12(sp),a2       ;Pointer auf String-Anfang laden
            lea       -1(a2,d7.w),a2  ;Pointer auf letztes Zeichen setzen
            movea.l   18(sp),a3       ;Pointer auf shift-buffer laden

cmp_loop:   move.b    (a0),d0         ;Zeichen aus Datei laden
            move.b    (a2),d1         ;Zeichen aus String laden
            cmp.b     d0,d1           ;beide Zeichen vergleichen
            beq.s     cmp_back        ;Zeichen stimmen Åberein -> ...hops...
            ext.w     d1              ;Zeichen stimmen nicht Åberein (schade)
            move.b    0(a3,d0.w),d1   ;entsprechenden shift-Wert laden
            ext.w     d1
            adda.w    d1,a0           ;Datei-Pointer um shift-Wert erhîhen
            sub.l     d1,d6           ;DateilÑngen-ZÑhler vermindern
            bpl.s     cmp_loop        ;bis Dateiende weitersuchen !

            moveq     #-1,d0          ;String nicht in der Datei enthalten !
            rts                       ;back to life...
;------------------------------------------------------------------------------
;String im RÅckwÑrtsgang untersuchen:
cmp_back:   move.w    d7,d5           ;LÑnge des Strings laden
            subq.w    #2,d5           ;wegen 'dbra' und predekrement
            movea.l   a0,a4           ;aktuelle Adressen sichern
            movea.l   a2,a5           ;           "
cmp_b_loop: move.b    -(a4),d0        ;nÑchstes Zeichen aus Datei laden
            move.b    -(a5),d1        ;nÑchstes Zeichen aus String laden
            cmp.b     d0,d1           ;sind beide Zeichen gleich ?
            beq.s     continue        ;Jawoll Herr Kaleu ! -> weitermachen
            lea       1(a0),a0        ;sonst: Datei-Pointer inkrementieren...
            bra.s     cmp_loop        ;...und zurÅckspringen

continue:   dbra      d5,cmp_b_loop   ;aktuelle String-Position dekrementieren
            cmpi.w    #-1,d5          ;komplette öbereinstimmung der Strings ?
            bne.s     cmp_loop        ;zurÅck und weitersuchen

;Der String ist gefunden worden !
            move.l    a4,d0           ;absolute Position des Strings
            sub.l     4(sp),d0        ;- Dateianfang = relative Position
            rts                       ;relative Position zurÅckgeben
;------------------------------------------------------------------------------
            END
