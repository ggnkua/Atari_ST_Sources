********************************************
*                                          *
*  Map scrolling routine for YOMO , to     *
*  handle exploding buildings              *
*  Aaron Fothergill , Shadow Software 89   *
*                                          *
********************************************

* A0 = map address
* D0 = X co-ord
* D1 = Y co-ord
* D2 = Xsize

loop    tst.w   d1
        beq     endit
        subq.w  #1,d1
        move.w  d1,d3
        mulu    d2,d3
        add.w   d0,d3
        move.b  4(a0,d3),d4
        addq.w  #1,d1
        move.w  d1,d3   
        mulu    d2,d3
        add.w   d0,d3
        move.b  d4,4(a0,d3)
        subq.w  #1,d1
        bra     loop
endit   move.b  #19,4(a0,d0)
        rts

        END
