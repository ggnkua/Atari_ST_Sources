********************************************
* Atari ST hi-speed plotting subroutine    *
* by Tom Hudson for START Magazine     *
********************************************
* For Low-resolution mode only             *
********************************************

.globl _pinit
.globl _myplot

.text

**************************************
* INITIALIZE THE PLOTTING ROUTINE:   *
* BUILDS PLOT ADDRESS TABLE (YTABLE) *
* FOR FAST PLOTTING.                 *
*                                    *
* CALL WITH:                         *
* PINIT(SCREENADDRESS)               *
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
* MYPLOT(X,Y,COLOR)                  *
**************************************

_myplot:
movem.l d3-d5,regsave
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
movem.l regsave,d3-d5
rts                  ;bye!

.data

***********************************
* This table stores the addresses *
* of each of the 200 Y positions  *
***********************************

ytable: .ds.l 200
regsave: .ds.l 3
