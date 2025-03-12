
; Dekomprimierung von CRACK ART Bildern (CA?)
; Copyright ½ Detlef R”ttger 04.03.1990

; GFA-Aufruf: ~C:CA_DECOMPRESS%( l:Quelle, l:Ziel )

                TEXT

                movem.l   d1-a6,-(sp)

                movem.l   60(sp),a0-a1  ; Quelle/Ziel
                movea.l   a1,a2
                lea       32000(a1),a3

                clr.w     d7
                clr.w     d6
                move.b    (a0)+,d7      ; ESC
                move.b    (a0)+,d6      ; DELTA

                move.w    (a0)+,d0      ; Offset
                and.l     #$7fff,d0
                movea.l   d0,a5

                move.b    d6,d1         ; DELTA in Langwoerter bringen
                lsl.w     #8,d1
                move.b    d6,d1
                move.w    d1,d2
                swap      d1
                move.w    d2,d1
                move.l    d1,d2
                move.l    d1,d3
                move.l    d1,d4
                move.l    d1,d5

                movea.l   a3,a6         ; Ziel mit DELTA fuellen
                move.w    #1599,d0
delta:          movem.l   d1-d5,-(a6)
                dbra      d0,delta

                move.l    a5,d0         ; Offset
                subq.w    #1,d0         ; Durchlaeufe
                bmi.s     endmain
main:           clr.w     d1
                move.b    (a0)+,d1      ; Erstes Byte holen
                cmp.b     d7,d1
                beq.s     esccode

writeone:       move.b    d1,(a2)       ; Wenn kein ESC, dann gleich schreiben
                adda.l    a5,a2
                cmpa.l    a3,a2
                blt.s     main
                addq.l    #1,a1
                movea.l   a1,a2
                dbra      d0,main

endmain:        movem.l   (sp)+,d1-a6
                rts

; Hier wurde ein ESC gefunden

esccode:        move.b    (a0)+,d1      ; zweites Byte
                cmp.b     d7,d1
                beq.s     writeone      ; ESC schreiben

                tst.b     d1            ; COMP0
                bne.s     code1
                clr.w     d2            ; ESC 00 ANZAHL-1 BYTE
                move.b    (a0)+,d2      ; Anzahl 3-255 ist bedeutet 4-256
                move.b    (a0)+,d1      ; gleiche Bytes
loop0:          move.b    d1,(a2)
                adda.l    a5,a2
                cmpa.l    a3,a2
                blt.s     drin0
                addq.l    #1,a1
                movea.l   a1,a2
                subq.w    #1,d0         ; Ueberschlag gemacht
                bmi.s     endmain
drin0:          dbra      d2,loop0
                bra.s     main

code1:          cmpi.b    #1,d1         ; COMP1
                bne.s     code2
                clr.w     d2            ; ESC 01 MULT REST-1 BYTE
                clr.w     d3
                move.b    (a0)+,d3      ; Multiplikator
                lsl.w     #8,d3
                move.b    (a0)+,d2      ; Anzahl 1-256
                add.w     d3,d2
                move.b    (a0)+,d1      ; komprimiertes Byte
loop1:          move.b    d1,(a2)
                adda.l    a5,a2
                cmpa.l    a3,a2
                blt.s     drin1
                addq.l    #1,a1
                movea.l   a1,a2
                subq.w    #1,d0         ; Ueberschlag gemacht
                bmi.s     endmain
drin1:          dbra      d2,loop1
                bra.s     main

code2:          cmpi.b    #2,d1         ; SAME
                bne.s     multiple      ; Komprimiert 3<n<=256
                clr.w     d3
                move.b    (a0)+,d3      ; Multiplikator
                beq.s     endmain       ; Abbruchcode ESC 02 00
                lsl.w     #8,d3
                clr.w     d2            ; ESC 02 MULT REST-1
                move.b    (a0)+,d2      ; Anzahl 1-256
                add.w     d3,d2
loop2:          adda.l    a5,a2         ; DELTAs 'schreiben'
                cmpa.l    a3,a2
                blt.s     drin2
                addq.l    #1,a1
                movea.l   a1,a2
                subq.w    #1,d0         ; Ueberschlag gemacht
                bmi.s     endmain
drin2:          dbra      d2,loop2
                bra       main

multiple:       clr.w     d2            ; ESC ANZAHL-1 BYTE
                move.b    (a0)+,d2      ; Byte
loop3:          move.b    d2,(a2)
                adda.l    a5,a2
                cmpa.l    a3,a2
                blt.s     drin3
                addq.l    #1,a1
                movea.l   a1,a2
                subq.w    #1,d0         ; Ueberschlag gemacht
                bmi       endmain
drin3:          dbra      d1,loop3
                bra       main

                END
