; VBL-Scroller
; Scrollt pro VBL eine Bildschirmzeile nach unten (nur fÅr niedrige Auflîsung !)
; Entwickelt mit TurboAss von Markus Fritze
; (C) 1991 Armin Hierstetter
; fÅr TOS-Magazin 3'91

                text

                bsr     _init_vbl       ; VBL-Scroller einschalten

                move.w  #1,-(sp)
                trap    #1
                addq.l  #2,-(sp)

;  ---------------------
; Hier steht Ihr Programm
;  ---------------------

                bsr.s   exit

                clr.w   -(sp)
                trap    #1

_init_vbl:      move.w  #2,-(sp)        ; Physbase
                trap    #14             ; Xbios
                addq.l  #2,sp           ; Stack

                movea.l d0,a6           ; Bildschirmadresse nach A0

                adda.l  #31680,a6       ; Ende der Bildschirmzeile

                move.l  a6,base_adr     ; Basisadresse merken

;  --------------------------------
; Installieren der neuen VBL-Routine
;  --------------------------------

                pea     vbl_scroll(pc)  ; Adresse der Routine auf Stack
                move.w  #28,-(sp)       ; Exceptionnummer 28
                move.w  #5,-(sp)        ; Setexc()
                trap    #13             ; Bios
                addq.l  #8,sp           ; Stack
                move.l  d0,old_vbl      ; Adresse der alten Routine merken

                rts                     ; weiter im Hauptprogramm
;  -------------------------------
; Alte VBL-Routine wieder eintragen
;  -------------------------------


exit:           move.l  old_vbl,-(sp)   ; alte Routine
                move.w  #28,-(sp)       ; Exceptionnummer 28
                move.w  #5,-(sp)        ; Setexc()
                trap    #13             ; Bios
                addq.l  #8,sp           ; Stack aufrÑumen

                rts

;  ---------------------------
; Die eigentliche Scrollroutine
;  ---------------------------

vbl_scroll:     movem.l d0-d1/a0-a1,-(sp) ; Register retten

                movea.l base_adr,a0     ; vorletzte Zeile

                move.w  #150,d0         ; 200 Zeilen scrollen
loop:
                move.l  (a0),160(a0)    ; 20 Langworte kopieren
                move.l  8(a0),168(a0)
                move.l  16(a0),176(a0)
                move.l  24(a0),184(a0)
                move.l  32(a0),192(a0)
                move.l  40(a0),200(a0)
                move.l  48(a0),208(a0)
                move.l  56(a0),216(a0)
                move.l  64(a0),224(a0)
                move.l  72(a0),232(a0)
                move.l  80(a0),240(a0)
                move.l  88(a0),248(a0)
                move.l  96(a0),256(a0)
                move.l  104(a0),264(a0)
                move.l  112(a0),272(a0)
                move.l  120(a0),280(a0)
                move.l  128(a0),288(a0)
                move.l  136(a0),296(a0)
                move.l  144(a0),304(a0)
                move.l  152(a0),312(a0)

                lea     -160(a0),a0     ; zwei Zeile zurÅck
                dbra    d0,loop         ; Bildschirm fertig

                movem.l (sp)+,d0-d1/a0-a1 ; Register wieder herstellen
                move.l  old_vbl,-(sp)
                rts                     ; zur Hauptschleife

                data

                bss


save_ssp:       ds.l 1
base_adr:       ds.l 1
old_vbl:        ds.l 1

                end
