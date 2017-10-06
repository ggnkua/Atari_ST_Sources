
* Fill_string: Notepad function to read some number of characters from 
document storage.
*  by Tim Victor
* Copyright 1987, COMPUTE! Publications/ABC

.text
.globl _fill_string
.globl _first_block
*
* register usage:
*    d6:  index
*    d5:  position counter
*    d4:  block size counter
*    a5:  storage block
*    a4:  fill source address
*    a3:  last index in block + 1
*    a2:  fill dest address
*
_fill_string:
     link      a6, #0
     movem.l   d4-d6/a2-a5,-(SP)
*
* find the block containing the index
*
     movea.l   _first_block, a5
     movea.w   #0, a3
     move.l    8(a6), d6           ;index parm
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
* point to the fill source
*
     lea       $a(a5), a4
     adda.l    d6, a4
     adda.w    (a5), a4
     suba.l    a3, a4
*
* init counters
*
     move.l    $c(a6), d5          ;copy length
     movea.l   $10(a6), a2         ;string to fill
     move.l    a3, d4
     sub.l     d6, d4              ;copy count for 1st block
*
* copy a char
*
copyloop:
     move.b    (a4)+, (a2)+
     subq.l    #1, d5
     beq       copydone
*
* at end of block?
*
     subq.l    #1, d4
     bne       copyloop
*
* go to next block
*
nextblok:
     movea.l   $2(a5), a5
     cmpa.w    #-1, a5
     beq       errexit
*
* skip empty blocks
*
     move.w    (a5), d4
     beq       nextblok

     lea       $a(a5), a4
     bra       copyloop
*
* copy is finised
*
copydone:
     movem.l   (SP)+,d4-d6/a2-a5
     unlk      a6 
     rts
*
* error condition
*
errexit:
     movea.l   $10(a6), a2
     move.b    #0, (a2)
     bra       copydone
.end
