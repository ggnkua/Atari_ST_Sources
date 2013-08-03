        .if !(^^defined MACROS_I)
MACROS_I = 1
*********** SWIPED FROM INIT.TT : 31JAN92 : RWS
     .macro    fnop      ;FPU nop
     dc.l      $f2800000
     .endm

     .macro  vbrr        ;read vbr into d0
     dc.l    $4e7a0801
     .endm

     .macro  vbrw        ;write d0 into vbr
     dc.l    $4e7b0801
     .endm
********** ENDSWIPE

* From Submenu.s
.macro  popretaddr      ; remove old return address (original menu bsr) from stack. : RWS 21JAN92
        addq.l  #4,sp   ; otherwise stack will overflow eventually (not likely, but still...)
.endm   

* FROM FPU.S : RWS : 03FEB92

        .macro  w4cir value
.\~:    cmp.w   \value,FPCIR
        bne.s   .\~
        .endm

        .macro  w4idle
        w4cir   #$0802
        .endm

        .macro  wrop value
        w4cir   #$9504
        move.l  \value,FPOP
        .endm

        .macro  rdop
        w4cir   #$B104
        move.l  FPOP,d0
        endm

****        .include "68030 macro's"

 .macro movecd0vbr
        dc.w    $4E7B
        dc.w    $0801
 .endm

 .macro movecvbrd0
        dc.w    $4E7A
        dc.w    $0801
 .endm

 .macro movecacrd0
        dc.w    $4E7A
        dc.w    $0002
 .endm

 .macro moved0cacr
        dc.w    $4E7B
        dc.w    $0002
 .endm

; unsigned long multiply immediate producing a word in specified register
 .macro mululwi val,dstreg
        dc.w    $4C3C
        dc.w    \dstreg << 12
        dc.l    \val
 .endm

; unsigned long divide 32/32 -> 32r:32q
 .macro divulr  eareg,regr,regq
        dc.w    $4C40+\eareg    ; divu.l d?,
        dc.w    (\regq << 12)+\regr
 .endm
***** end 68030 macro's

*       Cache control macros
*       movec   cacr,d0
.macro  rdcacr
        dc.w    $4e7a
        dc.w    $0002
.endm

*       movec   d0,cacr
.macro  wrcacr
        dc.w    $4e7b
        dc.w    $0002
.endm

.macro nocache
        clr.l   d0
        wrcacr
.endm

.macro cache
        ori     #$1111,d0
        wrcacr                  ;enable instr&data cache
.endm


** sermacs mods **

.macro  DSPMSG  msg
        lea.l   \msg,a5
        bsr     dspmsg
.endm

.macro  CRLF
        bsr     crlf
.endm
 
        .endif

    
