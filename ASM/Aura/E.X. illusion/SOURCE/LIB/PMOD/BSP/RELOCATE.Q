ph_branch       EQU $00           ; Startbranch im Header    [Headerinfos]
ph_tlen         EQU $04-2         ; L„nge Textsegment
ph_dlen         EQU $08-2         ; L„nge Datasegment
ph_blen         EQU $0C-2         ; L„nge BSS-Segment
ph_slen         EQU $10-2         ; L„nge Symboltabelle
ph_res1         EQU $14-2         ; reserviert
ph_res2         EQU $18-2         ;     "
ph_flag         EQU $1C-2         ; res. bzw. Relozierflag
ph_len          EQU ph_flag+2

binaerfile      EQU 0

        IFEQ    binaerfile                      ; PC-relatives Bin„rfile im
                OPT     D-,O+                   ; PMOD-Format erzeugen ?
                MC68000
                ORG     0
                MODUL   "F:\LIB\RELOCATE.INC"
                
                bra.s   relozier

                DC.B    'PMOD'
                DC.B    'Relozierroutine',0
                DC.B    'BDCannibal/AURA',0
                DC.B    '01920192'
                DC.B    '010000--'          ; Geht auch auf 68000
                DC.B    '--------'
        ENDIF

; a0.l  - Pointer auf Programmheader.
relozier:       movem.l D0-D2/A0-A2,-(SP)   ; (c) 1992 Jochen Knaus (BDC).

                move.l  ph_tlen(A0),D0      ; L„nge TEXT-Segment
                add.l   ph_dlen(A0),D0      ; + L„nge DATA-Segment
                add.l   ph_slen(A0),D0      ; + L„nge Symboltabelle
                lea     ph_len(A0,D0.l),A1  ; Startadresse Reloziertabelle
                lea     ph_len(A0),A0       ; Startadresse Textsegment
                move.l  A0,D0               ; Basisadresse Relozierung
                move.l  (A1)+,D1            ; Erster Relozierwert (32Bit-Offs.)
                beq.s   end_rel             ; =0 => keine Relozierung
                adda.l  D1,A0               ; richtige Adresse.
                add.l   D0,(A0)             ; Offset draufknallen

                moveq   #0,D1               ; als Wortoffset gebraucht
                moveq   #1,D2               ; Vgl. auf 1 optimieren
rel_loop:       move.b  (A1)+,D1            ; Byteoffset holen
                beq.s   end_rel             ; Nulloffset=Ende der šbertragung
                cmp.b   D2,D1               ; d1=1
                beq.s   add_254             ; 254 Bytes addieren

                adda.l  D1,A0               ; auf n„chsten zu relozierenden Wert
                add.l   D0,(A0)             ; Offset draufhauen
                bra.s   rel_loop            ; n„chsten Byteoffset

add_254:        lea     254(A0),A0          ; 254 Bytes drauf.
                bra.s   rel_loop            ; Vielleicht hat's der n„chste.

end_rel:        movem.l (SP)+,D0-D2/A0-A2
                rts
