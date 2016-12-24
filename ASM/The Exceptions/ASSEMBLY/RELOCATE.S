   movem.l d0-d1/a0-a1,-(sp)
        move.w  #$fa21,a1
        move.b  #200,(a1)       ;dummy value
        move.b  #8,$fffffa1b.w
        move.l  #newtb,$120.w
        move.l  old4(pc),$70.w  ;level 4 not needed anymore

        move.b  (a1),d0
wait2:                          ;wait for end of line
        cmp.b   (a1),d0
        beq     wait2

        moveq   #35,d0
scandelay:
        blk.w   125,$4e71
        dbf     d0,scandelay

        moveq   #29,d0
wait3:
        nop
        dbf     d0,wait3
                                ;upper border, 1st try
        clr.b   $ffff820a.w     ;60 Hz
        moveq   #3,d0
nopi3:                          ;wait a while
        nop
        dbf     d0,nopi3
                                ;now we are in the left border
        move.b  #2,$ffff820a.w  ;50 Hz
        move.w  #$700,$ff8240   ;Mark
        moveq   #14,d0
scandelay2:
        blk.w   125,$4e71
        dbf     d0,scandelay2

        moveq   #23,d0
wait4:
        nop
        dbf     d0,wait4
                                ;Upper border, 2nd try
        clr.b   $ffff820a.w     ;60 Hz
        moveq   #3,d0
nopi4:                          ;wait a while
        nop
        dbf     d0,nopi4
                                ;Left border reached
        move.b  #2,$ffff820a.w  ;50 Hz
        move.w  #$070,$ff8240   ;Mark

        clr.b   $fffffa1b.w     ;timer stop
        move.b  #199+13,$fffffa21.w
        move.b  #8,$fffffa1b.w

        movem.l (sp)+,d0-d1/a0