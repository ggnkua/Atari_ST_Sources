;******************************************************************************
;*               'Single-Step'-Algorithmus zur String-Suche                   *
;*   Autor:      Andreas Hollmann, Paderborn                                  *
;*               (c) MAXON Computer GmbH                                      *
;*   Sprache:    Assembler                                                    *
;******************************************************************************
; Aufruf:         pos%=C:adr%(L:p_file,L:file_len%,L:p_search%,W:search_len&)
; Stack-Offset:                   4         8           12           16
;
; Parameter:
; p_file%       = Pointer auf den zu durchsuchenden Speicherbereich/Datei
; file_len%     = LÑnge des zu durchsuchenden Speicherbereichs/Datei
; p_search%     = Pointer auf den zu suchenden String
; search_len&   = LÑnge des zu suchenden Strings
; pos%          = Position des Strings relativ zum Dateianfang
;------------------------------------------------------------------------------
            movea.l   4(sp),a0        ;Pointer auf Datei laden
            move.l    8(sp),d6        ;DateilÑnge laden
            movea.l   12(sp),a2       ;Pointer auf String laden
            move.w    16(sp),d7       ;StringlÑnge laden...
            subq.w    #1,d7           ;...und dekrementieren

            move.b    (a2),d0         ;1.Zeichen des Strings laden
main_loop:  cmp.b     (a0)+,d0        ;mit Zeichen aus der Datei vergleichen
            beq.s     found1          ;1.Zeichen gefunden
            subq.l    #1,d6           ;ZÑhler fÅr DateilÑnge dekrementieren
            bpl.s     main_loop       ;bis zum Dateiende suchen

            moveq     #-1,d0          ;String nicht in der Datei enthalten !
            rts
;------------------------------------------------------------------------------
found1:     movea.l   a0,a3           ;aktuelle Datei-Adresse sichern
            lea       -1(a3),a3       ;wegen postinkrement
            movea.l   a2,a4           ;aktuelle String-Adresse sichern
            move.w    d7,d5           ;StringlÑnge kopieren
            subq.l    #1,d6           ;ZÑhler fÅr DateilÑnge dekrementieren

sub_loop:   cmpm.b    (a3)+,(a4)+     ;die beiden nÑchsten Zeichen vergleichen
            bne.s     main_loop       ;ungleich, -> zurÅck und weitersuchen
            dbra      d5,sub_loop

            lea       -1(a0),a0       ;-1 wegen predekrement in cmp_loop1
            move.l    a0,d0           ;absolute Position des Strings
            sub.l     4(sp),d0        ;-Dateianfang = relative Position
            rts
;------------------------------------------------------------------------------
            END
