gemdos  macro
        push    \1
        trap    #1
        endm

xbio    macro
        push    \1
        trap    #14
        endm

push    macro
        move.w  \1,-(sp)
        endm

floprd  macro
        push    \6
        push    \5
        push    \4
        push    \3
        push    \2
        clr.l   -(sp)
        move.l  \1,-(a7)
        xbio    #8
        add.w   #20,sp
        tst.w   d0
        endm

flopwr  macro
        push    \6
        push    \5
        push    \4
        push    \3
        push    \2
        clr.l   -(sp)
        move.l  \1,-(a7)
        xbio    #9
        add.w   #20,sp
        tst.w   d0
        endm

        move.l  #infmes,-(a7)
        move.w  #9,-(a7)
        trap    #1
        addq.l  #6,a7
        move.w  #7,-(a7)
        trap    #1
        addq.l  #2,a7

copy    move    #0,d5
trlop   move    #1,d6
        floprd  #puffer,#0,#1,d5,#0,#9
        bne     fehler
        flopwr  #puffer,#0,#1,d5,#1,#9
        bne     fehler2
        addq    #1,d5
        cmp     #80,d5
        bne     trlop
        move.l  #okmes,-(a7)
        move.w  #9,-(a7)
        trap    #1
        addq.l  #6,a7
rueck   move.w  #7,-(a7)
        trap    #1
        add.l   #2,a7
        gemdos  #$4c


fehler  move    1,d0
fehler2 move.l  #badmes,-(a7)
        move.w  #9,-(a7)
        trap    #1
        addq.l  #6,a7
        bra     rueck
infmes  dc.b    "Achtung! RÅckseite wird gelîscht.",13,10,0
okmes   dc.b    "Kopieren durchgefÅhrt.",13,10,0
badmes  dc.b    "Fehler.  Kopieren abgebrochen.",13,10,0

info    addq.w  #1,d0
puffer  end
