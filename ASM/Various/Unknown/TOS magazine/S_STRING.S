; Routine zum Suchen eines Strings
; Startadresse des Suchstrings in A1
; Startadresse des Speicherbereichs in A0
;

                movem.l d1/a2,-(sp)     ; Register retten
                movea.l a1,a2           ;
                cmpi.b  #':',(a1)       ; Enth„lt String ein Zeichen ?
                beq.s   gotcha          ; nein, dann raus.

                move.b  (a1),d1         ; Erstes Zeichen nach d1
                bra.s   erster

wied:
                movea.l a2,a1           ; Startadresse Suchstring
                addq.l  #1,a3           ; Ein Zeichen weiter
                movea.l a3,a0           ; kopieren
erster:
                cmp.b   (a0)+,d1        ; 1. Buchstabe stimmt ?
                beq.s   weiter
                cmpi.b  #'*',(a0)       ; Ende des Speicherbereichs
                bne.s   erster
                bra.s   nichts_da       ; nein, dann wieder Suchen

weiter:
                addq.l  #1,a1           ; auf zweiten Buchstaben zeigen
                movea.l a0,a3           ; Adresse kopieren

                subq.l  #1,a3

testen:
                cmpi.b  #':',(a1)       ; Ende des Suchstrings ?
                beq.s   gotcha          ; Suche erfolgreich !
                cmpi.b  #'*',(a0)       ; Ende des Speicherbereichs ?
                beq.s   nichts_da       ; ja, dann nichts gefunden
                cmpm.b  (a0)+,(a1)+     ; Vergleichen
                beq.s   testen          ; falls gleich -> weiter machen
                bra.s   wied            ; sonst wieder von vorne

nichts_da:
                movea.l #0,a3

gotcha:
                movem.l (sp)+,d1/a2     ; Register herstellen

                rts
                end
