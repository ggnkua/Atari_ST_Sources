********************************************
* Atari ST hi-speed plotting subroutine    *
* by Tom Hudson                            *
* Copyright 1987 by Antic Publishing       *
* START, The ST Quarterly #4               *
* Markt & Technik AG Happy-Computer        *
********************************************
* For Low-resolution mode only             *
********************************************

.globl _pinit
.globl _myplot
.globl _get0
.globl _clr_RAM
.globl _or_sc
.globl _movedat

.text

**************************************
* INITIALIZE THE PLOTTING ROUTINE:   *
* BUILDS PLOT ADDRESS TABLE (YTABLE) *
* FOR FAST PLOTTING.                 *
*                                    *
* CALL WITH:                         *
* pinit(SCREENADDRESS)               *
**************************************

_pinit:
move.l 4(a7),a0    ;screen addr in A0
move.b #200,d1     ;200 Y positions
movea.l #ytable,a1 ;y table address in A1

iloop:
move.l a0,(a1)+    ;move address to table
adda.w #160,a0     ;increment address
subq.b #1,d1       ;1 less y position
bne iloop          ;loop if there's more!
rts

**************************************
* PLOT A PIXEL WITH MY ROUTINE       *
*                                    *
* CALL WITH:                         *
* myplot(X,Y,COLOR)                  *
**************************************

_myplot:
movem.l d0-a7,regsave
move.w 4(a7),d0      ;x coordinate in D0
cmp.w #319,d0
bcc pltxit
move.w d0,d3         ;duplicate in D3
andi.w #15,d3        ;mask off lower 4 bits
move.w 6(a7),d1      ;get y coordinate,
cmp.w #199,d1
bcc pltxit
lsl.w #2,d1          ;mult by 4 for index
move.w 8(a7),d2      ;get color number

lsr.w d0             ;x coord / 2
and.w #$00f8,d0      ;strip lower 3 bits
movea.w d0,a0        ;move x offset to A0
movea.l #ytable,a1   ;get y table addr
adda.l 0(a1,d1.w),a0 ;got final pixel addr!
move.w #$8000,d4     ;set ON pixel mask
lsr.w d3,d4          ;shift right D3 times
move.l #$80008000,d5 ;set OFF pixel mask
lsr.l d3,d5          ;shift right D3 times
eor.l #$ffffffff,d5  ;toggle all bits in D5

******************************
*    Turn off old pixel!     *
******************************

and.l d5,(a0)        ;turn off old pixel
and.l d5,4(a0)       ;(both longwords)

******************************
* Now turn on the new pixel! *
******************************

* BIT 1 *

btst #0,d2           ;set the bit?
beq bit2             ;no!
or.w d4,(a0)         ;turn it on!

* BIT 2 *

bit2:
btst #1,d2           ;set it?
beq bit4             ;no!
or.w d4,2(a0)        ;turn it on!

* BIT 4 *

bit4:
btst #2,d2           ;set bit?
beq bit8             ;no!
or.w d4,4(a0)        ;turn it on!

* BIT 8 *

bit8:
btst #3,d2           ;set bit?
beq pltxit           ;no, exit.
or.w d4,6(a0)        ;turn it on!

pltxit:
movem.l regsave,d0-a7
rts                  ;bye!

**********************
* get low-rez pixel  *
* get0(scrnbase,x,y) *
**********************

_get0:
move.l d3,datasave
move.l 4(a7),a1
clr.w d0                ;zero result register
move.w 10(a7),d3        ;get Y coordinate
and.l #$0000ffff,d3     ;mask off for multiply
mulu #160,d3            ;multiply by 160 (# of bytes per scan line)
adda.l d3,a1            ;add to screen base address
move.w 8(a7),d1         ;get X coordinate
move.w d1,d2            ;duplicate it in D2
lsr.w #1,d1             ;divide it by 2
and.w #$00f8,d1         ;turn off lower 3 bits
adda.w d1,a1            ;add to screen address register

move.w (a1),d3          ;grab screen word
and.l #15,d2            ;mask X to 0-15
move.w #$8000,d1        ;set up bit mask
lsr.w d2,d1             ;shift bit mask 0-15 bits
and.w d1,d3             ;mask off bit 0
beq bit0b               ;bit's off, go get next color bit
move.w #1,d0            ;turn on bit 0 in result

bit0b:
move.w 2(a1),d3         ;get screen word for bit 1 of color
and.w d1,d3             ;get bit 1
beq bit0c               ;it's off, try bit 2
or.w #2,d0              ;turn on bit 1 in result

bit0c:
move.w 4(a1),d3         ;get screen word for bit 2
and.w d1,d3             ;get bit 2
beq bit0d               ;it's off, try bit 3
or.w #4,d0              ;turn on bit 2 in result

bit0d:
move.w 6(a1),d3         ;get word for bit 3
and.w d1,d3             ;get bit 3
beq getx0               ;it's off!
or.w #8,d0              ;turn on bit 3 in result

getx0:
move.l datasave,d3
rts

************************************
* Clear a section of RAM to zeroes *
*                                  *
* clr_RAM(START,SIZE)              *
*                                  *
* START & SIZE are LONGs           *
************************************

_clr_RAM:
move.l 4(a7),a0         ;point to RAM
move.l 8(a7),d1         ;get count
lsr.l #2,d1             ;divide by 4

csc_loop:
clr.l (a0)+             ;clear 4 bytes
subq.w #1,d1            ;decrement counter
bne csc_loop            ;and loop for more
rts

************************************
* OR 2 sections of RAM             *
*                                  *
* or_sc(AREA1,AREA2,SIZE)          *
*                                  *
* AREA1, AREA2 & SIZE are LONGs    *
* op: AREA1 or AREA2 --> AREA2     *
************************************

_or_sc:
move.l 4(a7),a0         ;get area 1
move.l 8(a7),a1         ;get area 2
move.l 12(a7),d1        ;get length to OR
lsr.l #2,d1             ;divide by 4

or_loop:
move.l (a0)+,d0         ;get LONG from area 1
or.l d0,(a1)+           ;OR with area 2
subq.w #1,d1            ;decrement counter
bne or_loop             ;loop for more
rts

************************************
* Move a  section of RAM           *
*                                  *
* movedat(AREA1,AREA2,SIZE)        *
*                                  *
* AREA1, AREA2 & SIZE are LONGs    *
* op: AREA1 --> AREA2              *
************************************

_movedat:
move.l 4(a7),a0         ;get area 1
move.l 8(a7),a1         ;get area 2
move.l 12(a7),d1        ;get size of block to move
lsr.l #2,d1             ;divide by 4

mdloop:
move.l (a0)+,(a1)+      ;move area 1 LONG to area 2
subq.w #1,d1            ;decrement counter
bne mdloop              ;loop if more
rts

.data

***********************************
* This table stores the addresses *
* of each of the 200 Y positions  *
***********************************

ytable: .ds.l 200
regsave: .ds.l 16
datasave: .ds.l 1
