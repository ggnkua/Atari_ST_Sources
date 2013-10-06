
; d‚finition des EQUs de la ligne A

MAX_X equ -$c
MAX_Y equ -4

_X1 equ 38
_Y1 equ 40
_X2 equ 42
_Y2 equ 44
_FG_BP_1 equ 24
_FG_BP_2 equ 26
_FG_BP_3 equ 28
_FG_BP_4 equ 30
_LN_MASK equ 34
_WRT_MOD equ 36
_LSTLIN equ 32

ligne:
 cmp.w #4,d0
 bne.s .syntax_error
 movem.l (a1)+,d4-d7
 dc.w $a000
 move.l d0,a2
 tst.w d4
 bmi.s .syntax_error
 tst.w d5
 bmi.s .syntax_error
 tst.w d6
 bmi.s .syntax_error
 tst.w d7
 bmi.s .syntax_error
 move.w MAX_X(a2),d0
 move.w MAX_Y(a2),d1
 cmp.w d0,d4
 bge.s .syntax_error
 cmp.w d0,d6
 bge.s .syntax_error
 cmp.w d1,d5
 bge.s .syntax_error
 cmp.w d1,d7
 bge.s .syntax_error
 moveq #-1,d0
 move.w d0,_FG_BP_1(a2)
 move.w d0,_FG_BP_2(a2)
 move.w d0,_FG_BP_3(a2)
 move.w d0,_FG_BP_4(a2)
 move.w d0,_LN_MASK(a2)
 move.w d0,_LSTLIN(a2)
 clr.w _WRT_MOD(A2)
 move.w d4,_X1(a2)
 move.w d5,_Y1(a2)
 move.w d6,_X2(a2)
 move.w d7,_Y2(a2)
 dc.w $a003
.end:
 moveq #-1,d0
 rts 
.syntax_error:
 moveq #0,d0
 rts
