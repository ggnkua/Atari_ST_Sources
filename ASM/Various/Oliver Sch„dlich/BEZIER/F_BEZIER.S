; ******************************************************************
; * Fast-Bezier-Routine                                            *
; * von Oliver Sch„dlich   (c) 1992 MAXON Computer                 *
; *                                                                *
; * deklaration in TC:                                             *
; * extern int f_bezier( int *xvals, int *yvals, int rec_count );  *
; *                                                                *
; ******************************************************************

    .GLOBL  f_bezier
f_bezier:
    movem.l d3-d7/a2,-(sp)              ; Register retten

    move.w  d0,d7                       ; Rekursionsz„hler -> d7

    movea.w #$8000,a2                   ; n.5, um auf'm Pixel-Mittel-
                                        ; punkt zu rechnen

    bsr     init_rec                    ; =>x-Kurvenpunkte errechnen

    movea.l a1,a0                       ; =>y-Kurvenpunkte errechnen
    bsr     init_rec                    ; "

    moveq   #2,d0                       ; Anzahl der Punkte -> d0
    lsl.w   d7,d0                       ; "
    addq.w  #1,d0                       ; "

    movem.l (sp)+,d3-d7/a2              ; Register restaurieren
    rts                                 ; zurck

init_rec:
    move.w  (a0)+,d0                    ; n0 -> d0
    movem.w (a0),d1/d5/d6               ; n1...n3 -> d1/d5/d6

    add.w   a2,d0                       ; n0...n3 ins
    add.w   a2,d1                       ; unsigned-Format
    add.w   a2,d5                       ; wandlen
    add.w   a2,d6                       ; "
    
    swap    d0                          ; Werte ins high-word
    swap    d1                          ; und Nachkommastelle
    swap    d5                          ; (n.5) anh„ngen
    swap    d6                          ; "
    move.w  a2,d0                       ; "
    move.w  a2,d1                       ; "
    move.w  a2,d5                       ; "
    move.w  a2,d6                       ; "

fb_rec:                                 ; >>> Bezier-Rekursion <<<
    move.l  d5,d2                       ; (n1 + n2) / 2 -> d2
    add.l   d1,d2                       ; "
    roxr.l  #1,d2                       ; "
    add.l   d0,d1                       ; n1.0 -> d1
    roxr.l  #1,d1                       ; "
    add.l   d6,d5                       ; n2.1 -> d5
    roxr.l  #1,d5                       ; "
    move.l  d5,d4                       ; n1.1 -> d4
    add.l   d2,d4                       ; "
    roxr.l  #1,d4                       ; "
    add.l   d1,d2                       ; n2.1 -> d2
    roxr.l  #1,d2                       ; "
    move.l  d4,d3                       ; n0.1 -> d3
    add.l   d2,d3                       ; "
    roxr.l  #1,d3                       ; "

    subq.w  #1,d7                       ; Rek.-z„hler dekrementieren
    bcc     rcall_x                     ; >=0: =>n„chste Rek.-Ebene

set_n:
    swap    d3                          ; n3.0
    sub.w   a2,d3                       ; zurck ins signed-Format
    move.w  d3,(a0)+                    ; und setzen
    swap    d6                          ; n3.1
    sub.w   a2,d6                       ; zurck ins signed-Format
    move.w  d6,(a0)+                    ; und setzen

    addq.w  #1,d7                       ; Rek.-Z„hler inkrementieren
    rts                                 ; <=zurck

rcall_x:
    movem.l d3-d6,-(sp)                 ; l. Bezierh„lfte auf'n Stack

rcall_left:
    move.l  d2,d5                       ; richrige Reg.-konstellation
    move.l  d3,d6                       ; fr n„chste Rek.-Ebene
    bsr     fb_rec                      ; =>n„chst tiefere Rek.-Ebene

rcall_right:
    movem.l (sp)+,d0/d1/d5/d6           ; r. Bezierh„lfte zurck
                                        ; und automatisch richtige
                                        ; Reg.-Konstellation fr
                                        ; n„chste Rek.-Ebene
    bsr     fb_rec                      ; =>n„chst tiefere Rek.-Ebene

    addq.w  #1,d7                       ; Rek.-Z„hler inkrementieren
    rts                                 ; <=zurck
