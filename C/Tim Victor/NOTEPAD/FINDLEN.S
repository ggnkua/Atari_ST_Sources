
* Find_len: line length routine for Notepad desk accessory
*  by Tim Victor
* Copyright 1987, COMPUTE! Publications/ABC

.text
.globl _find_len
.globl _first_block
.globl _ch_cols
*
* register usage:
*    d6:  index
*    d5:  position counter
*    d4:  length register
*    d3:  width of line
*    a5:  storage block
*    a4:  scan pointer
*    a3:  last index in block + 1
*
_find_len:
     link      a6, #0
     movem.l   d3-d6/a3-a5,-(SP)
*
* find the block containing the index
*
     movea.l   _first_block, a5
     movea.w   #0, a3
     move.l    8(a6), d6
     bra       findblock

fbloop:
     movea.l   2(a5), a5           ;advance to next block
     cmpa.w    #-1, a5
     beq       errexit

findblock:
     adda.w    (a5), a3
     cmp.l     a3, d6
     bge       fbloop
*
* point to the line
*
     lea       $a(a5), a4
     adda.l    d6, a4
     adda.w    (a5), a4
     suba.l    a3, a4
*
* init counter
*
     moveq.l   #0, d5
     moveq.l   #0, d4
     moveq.l   #0, d3
     move.w    _ch_cols, d3
*
* scan the line
*
scan:
     addq.l    #1, d5
     cmpi.b    #$d, (a4)
     beq       rtncount
     cmpi.b    #$20, (a4)+
     bne       notspace
     move.l    d5, d4
*
* at end of line?
*
notspace:
     cmp.l     d3, d5
     beq       endline
*
* at end of block?
*
     addq.l    #1, d6
     cmp.l     a3, d6
     bne       scan
*
* go to next block
*
nextblok:
     movea.l   $2(a5), a5
     cmpa.w    #-1, a5
     beq       rtncount

     tst.w     (a5)                ;empty block?
     beq       nextblok

     lea       $a(a5), a4
     adda.w    (a5), a3
     bra       scan
*
* send back a result
*
endline:
     move.l    d4, d0
     bne       exit
rtncount:
     move.l    d5, d0
*
* return
*
exit:
     movem.l   (SP)+,d3-d6/a3-a5
     unlk      a6 
     rts
*
* error condition
*
errexit:
     move.l    a5, d0
     bra       exit
.end
