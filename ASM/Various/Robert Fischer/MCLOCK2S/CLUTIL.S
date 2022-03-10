
; +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
; Emulate the VT-52 "glass terminal" emulator, without using Line A calls
; to try to make it faster.
; This is a stripped down version of the "real" vt52.s, and it is used
; so that one doesn't have to call Line A from a VBLANK interrupt
; +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-

.include "atari.s"
.include "linea.s"

ESC = 27
TRUE = 1
FALSE = 0

linewidth = 80  ; Width of one line (in bytes)
linelast = linewidth - 1    ; Width of line - 1
scr_size = 32000    ; Size of screen

bios_vec = $B4
; +++++++++++++++++++++
.macro Conout c
    move.w  \c, -(sp)
    bsr     conout
    addq.l  #2, sp
.endm


    .bss

_curpos::       ds.w 1  ; Curent offset (from Logbase) of cursor
linea:      ds.l 1  ; Line A master variable pointer
    .text

; ****************************************************
_init_vt::
init_vt::
    A_init
    move.l  a0, linea
    move.l  #0, _curpos         ; Init cursor position
    move.w  #FALSE, WMODE(a0)   ; Init wrap mode

    rts

; ****************************************************
putc:   ; Puts a character.  Arguments:
; A0: Line A variable pointer
; A3: Screen pointer
; d1.w: offset into screen of where to put character
; d0.w: character to put
; Destroys d6, d7, a2, a4

    lea     0(a3, d1), a4       ; Address to blit char to
    sub.w   V_FONT_ST(a0), d0   ; character offset in font data
    move.l  V_FONT_AD(a0), a2   ; Address of font form
    ext.l   d0
    add.l   d0, a2              ; Address of character in font

    move.w  V_CEL_HT(a0), d7    ; # times to go around loop
    subq.w  #1, d7
    move.w  V_FONT_WD(a0), d6   ; amount to add each time around
    ext.l   d6

.l1:                            ; Blit the character
    move.b  (a2), (a4)
    lea     linewidth(a4), a4
    add.l   d6, a2
    dbra    d7, .l1

    rts
; ****************************************
_conout::
conout:: .cargs .c.w    ; Interprets and Outputs a character
; Register usage:
; a0: Line A structure
; a3: Screen base
; a1, a2: temporary
    move.w  .c(sp), d0
_hoihoi::
    movem.l d1/d6/d7/a0/a1/a2/a3/a4, -(sp)
    move.l  _v_bas_ad, a3

    move.l  linea, a0

    move.w  _curpos, d1     ; Output the character
    bsr     putc

    addq.w  #1, d1          ; Move cursor
    move.w  d1, _curpos

    movem.l (sp)+, d1/d6/d7/a0/a1/a2/a3/a4
    rts
; **************

