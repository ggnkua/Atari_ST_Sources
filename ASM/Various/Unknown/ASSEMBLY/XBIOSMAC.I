Initmous        MACRO
        move.l  \1,-(sp)
        move.l  \2,-(sp)
        move.w  \3,-(sp)
        move.w  #0,-(sp)
        trap    #14
        lea     12(sp),sp
        ENDM

physbase        MACRO
        move.w  #2,-(sp)
        trap    #14
        addq.l  #2,sp
        ENDM

Logbase MACRO
        move.w  #3,-(sp)
        trap    #14
        addq.l  #2,sp
        ENDM

Getrez  MACRO
        move.w  #4,-(sp)
        trap    #14
        addq.l  #2,sp
        ENDM

Setscreen       MACRO
        move.w  \1,-(sp)
        move.l  \2,-(sp)
        move.l  \3,-(sp)
        move.w  #5,-(sp)
        trap    #14
        lea     12(sp),sp
        ENDM

Setpalette      MACRO
        move.l  \1,-(sp)
        move.w  #6,-(sp)
        trap    #14
        addq.l  #4,sp
        ENDM

Setcolor        MACRO
        move.w  \1,-(sp)
        move.w  \2,-(sp)
        move.w  #7,-(sp)
        trap    #14
        addq.l  #6,sp
        ENDM

Floprd  MACRO
        move.w  \1,-(sp)
        move.w  \2,-(sp)
        move.w  \3,-(sp)
        move.w  \4,-(sp)
        move.w  \5,-(sp)
        move.l  \6,-(sp)
        move.l  \7,-(sp)
        move.w  #8,-(sp)
        trap    #14
        lea     20(sp),sp
        ENDM

Flopwr  MACRO
        move.w  \1,-(sp)
        move.w  \2,-(sp)
        move.w  \3,-(sp)
        move.w  \4,-(sp)
        move.w  \5,-(sp)
        move.l  \6,-(sp)
        move.l  \7,-(sp)
        move.w  #9,-(sp)
        trap    #14
        lea     20(sp),sp
        ENDM

Flopfmt MACRO
        move.w  \1,-(sp)
        move.l  \2,-(sp)
        move.w  \3,-(sp)
        move.w  \4,-(sp)
        move.w  \5,-(sp)
        move.w  \6,-(sp)
        move.w  \7,-(sp)
        move.l  \8,-(sp)
        move.l  \9,-(sp)
        move.w  #10,-(sp)
        trap    #14
        lea     26(sp),sp
        ENDM

Midiws  MACRO
        move.l  \1,-(sp)
        move.w  \2,-(sp)
        move.w  #12,-(sp)
        trap    #14
        addq.l  #8,sp
        ENDM

Mfpint  MACRO
        move.l  \1,-(sp)
        move.w  \2,-(sp)
        move.w  #13,-(sp)
        trap    #14
        addq.l  #8,sp
        ENDM

Iorec   MACRO
        move.w  \1,-(sp)
        move.w  #14,-(sp)
        trap    #14
        addq.l  #4,sp
        ENDM

Rsconf  MACRO
        move.w  \1,-(sp)
        move.w  \2,-(sp)
        move.w  \3,-(sp)
        move.w  \4,-(sp)
        move.w  \5,-(sp)
        move.w  \6,-(sp)
        move.w  #15,-(sp)
        trap    #14
        lea     14(sp),sp
        ENDM

Keytbl  MACRO
        move.l  \1,-(sp)
        move.l  \2,-(sp)
        move.l  \3,-(sp)
        move.w  #16,-(sp)
        trap    #14
        lea     14(sp),sp
        ENDM

Random  MACRO
        move.w  #17,-(sp)
        trap    #14
        addq.l  #2,sp
        ENDM

Protobt MACRO
        move.w  \1,-(sp)
        move.w  \2,-(sp)
        move.l  \3,-(sp)
        move.l  \4,-(sp)
        move.w  #18,-(sp)
        trap    #14
        lea     14(sp),sp
        ENDM

Flopver MACRO
        move.w  \1,-(sp)
        move.w  \2,-(sp)
        move.w  \3,-(sp)
        move.w  \4,-(sp)
        move.w  \5,-(sp)
        move.l  \6,-(sp)
        move.l  \7,-(sp)
        move.w  #19,-(sp)
        trap    #14
        lea     20(sp),sp
        ENDM

Scrdmp  MACRO
        move.w  #20,-(sp)
        trap    #14
        addq.l  #2,sp
        ENDM

Cursconf        MACRO
        move.w  \1,-(sp)
        move.w  \2,-(sp)
        move.w  #21,-(sp)
        trap    #14
        addq.l  #6,sp
        ENDM

Settime MACRO
        move.l  \1,-(sp)
        move.w  #22,-(sp)
        trap    #14
        addq.l  #6,sp
        ENDM

Gettime MACRO
        move.w  #23,-(sp)
        trap    #14
        addq.l  #2,sp
        ENDM

Bioskeys        MACRO
        move.w  #24,-(sp)
        trap    #14
        addq.l  #2,sp
        ENDM

Ikbdws  MACRO
        move.l  \1,-(sp)
        move.w  \2,-(sp)
        move.w  #25,-(sp)
        trap    #14
        addq.l  #8,sp
        ENDM

Jdisint MACRO
        move.w  \1,-(sp)
        move.w  #26,-(sp)
        trap    #14
        addq.l  #4,sp
        ENDM

Jenabint        MACRO
        move.w  \1,-(sp)
        move.w  #27,-(sp)
        trap    #14
        addq.l  #4,sp
        ENDM

Giaccess        MACRO
        move.w  \1,-(sp)
        move.w  \2,-(sp)
        move.w  #28,-(sp)
        trap    #14
        addq.l  #6,sp
        ENDM

Offgibit        MACRO
        move.w  \1,-(sp)
        move.w  #29,-(sp)
        trap    #14
        addq.l  #4,sp
        ENDM

Ongibit MACRO
        move.w  \1,-(sp)
        move.w  #30,-(sp)
        trap    #14
        addq.l  #4,sp
        ENDM

Xbtimer MACRO
        move.l  \1,-(sp)
        move.w  \2,-(sp)
        move.w  \3,-(sp)
        move.w  \4,-(sp)
        move.w  #31,-(sp)
        trap    #14
        lea     12(sp),sp
        ENDM

Dosound MACRO
        move.l  \1,-(sp)
        move.w  #32,-(sp)
        trap    #14
        addq.l  #6,sp
        ENDM

Setprt  MACRO
        move.w  \1,-(sp)
        move.w  #33,-(sp)
        trap    #14
        addq.l  #4,sp
        ENDM

Kbdvbase        MACRO
        move.w  #34,-(sp)
        trap    #14
        addq.l  #2,sp
        ENDM

Kbrate  MACRO
        move.w  \1,-(sp)
        move.w  \2,-(sp)
        move.w  #35,-(sp)
        trap    #14
        addq.l  #6,sp
        ENDM

Prtblk  MACRO
        move.l  \1,-(sp)
        move.w  #36,-(sp)
        trap    #14
        addq.l  #6,sp
        ENDM

Vsync   MACRO
        move.w  #37,-(sp)
        trap    #14
        addq.l  #2,sp
        ENDM

Supexec MACRO
        move.l  \1,-(sp)
        move.w  #38,-(sp)
        trap    #14
        addq.l  #6,sp
        ENDM

Puntaes MACRO   *RAM loaded TOS only
        move.w  #39,-(sp)
        trap    #14
        addq.l  #2,sp
        ENDM

Floprate        MACRO   *TOS 1.04 and above
        move.w  \1,-(sp)
        move.w  \2,-(sp)
        move.w  #41,-(sp)
        trap    #14
        addq.l  #6,sp
        ENDM

Dmaread MACRO   *TT TOS
        move.w  \1,-(sp)
        move.l  \2,-(sp)
        move.w  \3,-(sp)
        move.l  \4,-(sp)
        move.w  #42,-(sp)
        trap    #14
        lea     14(sp),sp
        ENDM

Dmawrite        MACRO   *TT TOS
        move.w  \1,-(sp)
        move.l  \2,-(sp)
        move.w  \3,-(sp)
        move.l  \4,-(sp)
        move.w  #43,-(sp)
        trap    #14
        lea     14(sp),sp
        ENDM

Bconmap MACRO
        move.w  \1,-(sp)
        move.w  #44,-(sp)
        trap    #14
        addq.l  #4,sp
        ENDM

Nvmaccess       MACRO   *TT TOS
        move.l  \1,-(sp)
        move.w  \2,-(sp)
        move.w  \3,-(sp)
        move.w  \4,-(sp)
        move.w  #46,-(sp)
        trap    #14
        lea     12(sp),sp
        ENDM


Blitmode        MACRO
        move.w  \1,-(sp)
        move.w  #64,-(sp)
        trap    #14
        addq.l  #4,sp
        ENDM

Esetshift       MACRO   *TT TOS
        move.w  \1,-(sp)
        move.w  #80,-(sp)
        trap    #14
        addq.l  #4,sp
        ENDM

Egetshift       MACRO   *TT TOS
        move.w  #81,-(sp)
        trap    #14
        addq.l  #2,sp
        ENDM

Esetbank        MACRO   *TT TOS
        move.w  \1,-(sp)
        move.w  #82,-(sp)
        trap    #14
        addq.l  #4,sp
        ENDM

Esetcolor       MACRO   *TT TOS
        move.w  \1,-(sp)
        move.w  \2,-(sp)
        move.w  #83,-(sp)
        trap    #14
        addq.l  #6,sp
        ENDM

Esetpalette     MACRO   *TT TOS
        move.l  \1,-(sp)
        move.w  \2,-(sp)
        move.w  \3,-(sp)
        move.w  #84,-(sp)
        trap    #14
        lea     10(sp),sp
        ENDM

Egetpalette     MACRO   *TT TOS
        move.l  \1,-(sp)
        move.w  \2,-(sp)
        move.w  \3,-(sp)
        move.w  #85,-(sp)
        trap    #14
        lea     10(sp),sp
        ENDM

Esetgray        MACRO   *TT TOS
        move.w  \1,-(sp)
        move.w  #86,-(sp)
        trap    #14
        addq.l  #4,sp
        ENDM

Esetsmear       MACRO   *TT TOS
        move.w  \1,-(sp)
        move.w  #87,-(sp)
        trap    #14
        addq.l  #4,sp
        ENDM

