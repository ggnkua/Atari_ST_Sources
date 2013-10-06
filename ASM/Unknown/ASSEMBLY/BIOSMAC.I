Getmpb  MACRO
        move.l  \1,-(sp)
        move.w  #0,-(sp)
        trap    #13
        addq.l  #6,sp
        ENDM

Bconstat        MACRO
        move.w  \1,-(sp)
        move.w  #1,-(sp)
        trap    #13
        addq.l  #4,sp
        ENDM

Bconin  MACRO
        move.w  \1,-(sp)
        move.w  #2,-(sp)
        trap    #13
        addq.l  #4,sp
        ENDM

Bconout MACRO
        move.w  \1,-(sp)
        move.w  \2,-(sp)
        move.w  #3,-(sp)
        trap    #13
        addq.l  #6,sp
        ENDM

Rwabs   MACRO
        move.w  \1,-(sp)
        move.w  \2,-(sp)
        move.w  \3,-(sp)
        move.l  \4,-(sp)
        move.w  \5,-(sp)
        move.w  #4,-(sp)
        trap    #13
        lea     14(sp),sp
        ENDM

Setexec MACRO
        move.l  \1,-(sp)
        move.w  \2,-(sp)
        move.w  #5,-(sp)
        trap    #13
        addq.l  #8,sp
        ENDM

Tickcal MACRO
        move.w  #6,-(sp)
        trap    #13
        addq.l  #2,sp
        ENDM
Getbpb  MACRO
        move.w  \1,-(sp)
        move.w  #7,-(sp)
        trap    #13
        addq.l  #4,sp
        ENDM

Bcostat MACRO
        move.w  \1,-(sp)
        move.w  #8,-(sp)
        trap    #13
        addq.l  #4,sp
        ENDM

Mediach MACRO
        move.w  \1,-(sp)
        move.w  #9,-(sp)
        trap    #13
        addq.l  #4,sp
        ENDM

Drvmap  MACRO
        move.w  #10,-(sp)
        trap    #13
        addq.l  #2,sp
        ENDM

Kbshift MACRO
        move.w  \1,-(sp)
        move.w  #11,-(sp)
        trap    #13
        addq.l  #4,sp
        ENDM


