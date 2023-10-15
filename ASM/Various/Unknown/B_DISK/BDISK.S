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

hdv_bpb equ     $472
hdv_rw  equ     $476
hdv_mediach     equ     $47e
drvbits equ     $4c2
gemdos  equ     1
keep    equ     $31
xbios   equ     14
super   equ     38
default equ     100

        move.l  #init1,-(sp)
        move    #super,-(sp)
        trap    #xbios
        addq.l  #6,sp

        clr     -(sp)
        move.l  #ende,-(sp)
        move    #keep,-(sp)
        trap    #gemdos

init1   move.l  hdv_bpb,bpbsave
        move.l  #bpb,hdv_bpb
        move.l  hdv_rw,rwsave
        move.l  #rw,hdv_rw
        move.l  hdv_mediach,mediasave
        move.l  #media,hdv_mediach

        or.l    #%10000,drvbits
        rts

bpb     cmp     #4,4(sp)
        beq     bpb1

        move.l  bpbsave,a0
        jmp     (a0)

bpb1    move.l  #bpbtab,d0
        rts

rw      cmp     #4,14(sp)
        beq     rw1

        move.l  rwsave,a0
        jmp     (a0)

rw1     move    12(sp),d0
        ext.l   d0
        move.l  6(sp),a0
        move    10(sp),d2
        move    4(sp),d1
        btst    #0,d1
        beq     read
        movem   d3-d6/a0,-(a7)
        move    d0,d3
        move    d2,d4
wrtlop  move    d3,d0
        ext.l   d0
        divu    #9,d0
        move.l  d0,d1
        swap    d1
        addq    #1,d1
        move.l  a0,sav
        move    #10,d5
        sub     d1,d5
        cmp     d4,d5
        ble     doit
        move    d4,d5
doit    flopwr  a0,#0,d1,d0,#1,d5
        bne     fehler
        sub     d5,d4
        add     d5,d3
        move.l  sav,a0
        mulu    #512,d5
        add     d5,a0
        tst     d4
        bne     wrtlop
        movem   (a7)+,d3-d6/a0
        rts

read    movem.l d3-d6,-(a7)
        move    d0,d3
        move    d2,d4
rdlop   move    d3,d0
        ext.l   d0
        divu    #9,d0
        move.l  d0,d1
        swap    d1
        addq    #1,d1
        move.l  a0,sav
        move    #10,d5
        sub     d1,d5
        cmp     d4,d5
        ble     doit1
        move    d4,d5
doit1   floprd  a0,#0,d1,d0,#1,d5
        bne     fehler
        move.l  sav,a0
        sub     d5,d4
        add     d5,d3
        mulu    #512,d5
        add     d5,a0
        tst     d4
        bne     rdlop
        movem.l (a7)+,d3-d6
        rts

fehler  move    1,d0

media   cmp     #4,4(sp)
        beq     media2
        cmp     #0,4(sp)
        beq     media2
        move.l  mediasave,a0
        jmp     (a0)

media2  move.l  (a7)+,save
        move    (a7)+,saved
        move    #0,-(a7)
        move.l  mediasave,a0
        jsr     (a0)
        cmp     #0,d0
        beq     back
        move    d0,last0
        move    d0,last4
back    addq    #2,a7
        move    saved,-(a7)
        move.l  save,-(a7)
        tst.w   saved
        beq     back2
        move    last4,d0
        move    #0,last4
        rts

back2   move    last0,d0
        move    #0,last0
        rts

last0   dc.w    0
last4   dc.w    0
save    ds.l    1
saved   ds.w    1

sav     ds.l    1

bpbtab:
recsiz  dc.w    $200
clsiz   dc.w    2
clsizb  dc.w    $400
rdlen   dc.w    7
fsiz    dc.w    5
fatrec  dc.w    6
datrec  dc.w    18
numc1   dc.w    $15f
        dc.w    0
        dc.w    $50
        dc.w    1
        dc.w    9
        dc.w    9
        dc.w    0
        dc.w    $5035
        dc.w    $3000
        dc.w    0
        dc.w    0

boottab dc.b    0,2
        dc.b    2
        dc.b    1,0
        dc.b    2
        dc.b    112,0
        dc.b    $d0,2
        dc.b    $f8
        dc.b    5,0
        dc.b    9,0
        dc.b    1,0
        dc.b    0

tabend  equ     *

bpbsave ds.l    1
rwsave  ds.l    1
mediasave       ds.l    1

ende    equ     *

        end

