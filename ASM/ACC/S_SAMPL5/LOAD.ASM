* load the ss5 mega-file

        clr.w   -(sp)
        move.l  #file,-(sp)
        move.w  #$3d,-(sp)
        trap    #1
        addq.l  #8,sp
        
        move.l  #$30000,-(sp)
        move.l  #245760,-(sp)
        move.w  d0,-(sp)
        move.w  #$3f,-(sp)
        trap    #1
        add.l   #12,sp

        clr.w   -(sp)
        move.l  #$76000,-(sp)
        move.l  #$76000,-(sp)
        move.w  #5,-(sp)
        trap    #14
        add.l   #12,sp

        jsr     $30000

        move.w  #1,-(sp)
        move.l  #$76000,-(sp)
        move.l  #$76000,-(sp)
        move.w  #5,-(sp)
        trap    #14
        add.l   #12,sp

        clr.w   -(sp)
        trap    #1

file:   dc.b    'ss5.cod',0
