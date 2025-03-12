* load the ss5 mega-file

        move.l  #pal1,-(sp)
        move.w  #$06,-(sp)
        trap    #14
        addq.l  #6,sp

        clr.w   -(sp)
        move.l  #file,-(sp)
        move.w  #$3d,-(sp)
        trap    #1
        addq.l  #8,sp
        move.l  d0,d6

        move.w  #2,-(sp)
        trap    #14
        addq.l  #2,sp
        move.l  d0,a6

        clr.w   -(sp)
        move.l  a6,-(sp)
        move.l  a6,-(sp)
        move.w  #5,-(sp)
        trap    #14
        add.l   #12,sp

        move.l  a6,-(sp)
        move.l  #32000,-(sp)
        move.w  d6,-(sp)
        move.w  #$3f,-(sp)
        trap    #1
        add.l   #12,sp
        
        move.l  #7999,d1
        move.l  a6,a0
cod1:   eor.l   #$10091988,(a0)+
        dbra    d1,cod1

        move.l  #pal2,-(sp)
        move.w  #6,-(sp)
        trap    #14
        addq.l  #6,sp

        move.l  #$2fd00,-(sp)
        move.l  #245760,-(sp)
        move.w  d6,-(sp)
        move.w  #$3f,-(sp)
        trap    #1
        add.l   #12,sp

        move.l  #61440,d0
        move.l  #$30000,a0
cod2:   eor.l   #$10091988,(a0)+
        dbra    d0,cod2

        jmp     $30000

file:   dc.b    'sample_v.img',0
	even
pal1:   dc.w    000,000,000,000,000,000,000,000
        dc.w    000,000,000,000,000,000,000,000
pal2:   dc.w    $000,$003,$004,$005,$006,$007,$555,$444
        dc.w    $333,$500,$773,$707,$444,$222,$111,$666
