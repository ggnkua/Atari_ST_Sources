********************************************************************************
* BLT(SPRITE,XPIX,YPIX,ADDR) takes the address of a sprite in memory = SPRITE, *
* the X,Y coordinates in pixels, and the logical screen address = ADDR and puts*
* your sprite on the screen at that location.                                  *
********************************************************************************

.globl _blt
.text
_blt:  link R14,#-4          *Allocate stack frame.
       clr.l R0
       clr.l R1 
       move.l 8(R14),R8      *R8 holds the long int address of bitmap in mem
       move.w 12(R14),R0     *R0 holds the x-coordinate in screen row pixels
       move.w 14(R14),R1     *R1 holds the y-coordinate in screen column pixels 
       move.l 16(R14),R9     *Load off screen base address
       mulu #160,R1         *R1 now holds the number of screen bytes for rows
       divu #16,R0          *R0 bot now holds number of two-word groups 
       clr.l R2             *Ready R2 for use
       move.w R0,R2         *Get bottom word which is # of 2-word groups
       mulu #8,R2           *R2 now holds number of bytes in screen row
       swap R0              *R0 now holds the right shift number of sprite
       clr.l R3
       move.w #16,R3
       sub.w R0,R3
       move.l R3,R0
       add.l R2,R1          *R1 now holds starting screen byte address
       add.l R1,R9          *Starting byte for sprite in screen memory in R9
       clr.l R5              *Zero the row counter 
top2:  clr.l R1
       clr.l R2
       clr.l R3
       clr.l R4
       clr.l R6
       move.w (R8),R1        *move bitmap value of plane zero into R2
       asl.l R0,R1           *move it the number of bits to the left
       move.w 2(R8),R2       *move bitmap value of plane one into R3
       asl.l R0,R2
       move.w 4(R8),R3
       asl.l R0,R3
       move.w 6(R8),R4
       asl.l R0,R4
       move.l R1,R6          *Put a copy of R3 into R4
       or.l R2,R6            *find the plane overlap for nontrivial info
       or.l R3,R6
       or.l R4,R6
       not.l R6            *find the inverse of the nontrivial (1's comp)
       and.w R6,8(R9)        *blanks out screen where the bitmap will appear
       and.w R6,10(R9)
       and.w R6,12(R9)
       and.w R6,14(R9)
       swap R6
       and.w R6,(R9)
       and.w R6,2(R9)
       and.w R6,4(R9)
       and.w R6,6(R9)
       or.w R1,8(R9)
       or.w R2,10(R9)
       or.w R3,12(R9)
       or.w R4,14(R9)
       swap R1
       swap R2
       swap R3
       swap R4
       or.w R1,(R9)
       or.w R2,2(R9)
       or.w R3,4(R9)
       or.w R4,6(R9)
       add #8,R8             *done with 8 bytes of memory = 4 16-bit integers
       add.l #160,R9         *move to next screen line
       addq #1,R5            *increment screen line counter
       cmp.w #16,R5           *have we done 16 lines yet?
       blt top2              *if not then do another line
       unlk R14
       rts
                            


