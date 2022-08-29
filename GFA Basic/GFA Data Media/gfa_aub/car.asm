; file       car.asm
;
             .INCLUDE 'ATARI.IS'

leftkey      equ "7"
rightkey     equ "9"
stopkey      equ "8"

carwidth     equ 14
carheight    equ 12

scroll:      movem.l   d1-d4/a0/a1/a6,-(sp) ;save the CPU registers used

label:       lea.l     label(pc),a6         ;all addresses in the program
             .BASE 6,label                  ;are relative to label. The
;                                            GFA ASSEMBLER will automatically
;                                            convert them.

             move.l    screen,d0            ;Is screen position
;                                            already defined (<> -1)?
             bpl       redraw               ;yes, then scroll etc...

firsttime:   Physbase  ;                     first call:
;                                            Where is screen?
             move.l    d0,screen            ;note for later use
             move.w    7*4+4(sp),d0         ;fetch parameters
             move.w    d0,pos               ;set start position
             bsr       drawcar              ;draw car
             bra       done                 ;and finished.

redraw:      Vsync     ;wait for frame flyback
             move.w    pos,d0               ;then erase the old car
             bsr       drawcar
             movea.l   screen,a1            ;screen start address to a1
             move.w    7*4+4(sp),d0         ;fetch parameter line number
             mulu.w    #80,d0               ;convert to bytes (Lines*80)
             lea.l     0(a1,d0.w),a0        ;load a1+d0 to a0
             neg.l     d0                   ;-d0+32000 is block length
             addi.l    #32000,d0
             bsr       qcopy                ;call subroutine qcopy here

             Crawio    #$000000ff           ;read keyboard, ASCII code to d0.b

             move.w    vx,d1                ;hold horizontal speed
             move.w    pos,d2               ;and position ready in registers

             cmpi.b    #leftkey,d0          ;acceleration to the left?
             bne       .tstright            ; no
             subq.w    #1,d1                ; yes, vx := vx-1
             bra       .finished            ;  and key read
.tstright:   cmpi.b    #rightkey,d0         ;not left, then
;perhaps right?
             bne       .tststop             ;  no, then perhaps
;  stop?
             addq.w    #1,d1                ;  yes, vx := vx+1
             bra       .finished            ;  and key read
.tststop:    cmpi.b    #stopkey,d0          ;Key for abrupt stop?
             bne       .finished            ;  no, then finished
             moveq.l   #0,d1                ;  yes, vx := 0
.finished:   add.w     d1,d2                ;Position = position + speed
             bpl       .tstleft             ; >= 0, not beyond left border
             moveq.l   #0,d1                ; <0: position to left border and
             moveq.l   #0,d2                ; set speed to 0
             bra       .savnpos             ; remember new position
.tstleft:    cmpi.w    #640-carwidth,d2     ; >=640-carwidth?
             bcs       .savnpos             ; no, position is okay
             move.w    #640-carwidth,d2     ; yes, then position to right
; border and
             moveq.l   #0,d1                ; speed to 0
.savnpos:    move.w    d1,vx                ;Note new position and speed
             move.w    d2,pos
             Vsync     ;Wait again for frame flyback
             move.w    d2,d0                ; and draw car at new position
             bsr       drawcar              ;any collision sets d0<>0

done:        movem.l   (sp)+,d1-d4/a1/a2/a6
;restore registers
             rts                            ;d0 holds result

;
; drawcar
;
; Input: d0 -- Line position of the car in pixels
; Output: d0 -- <> 0, if car leaves road
;
;  registers changed: 01234567
;                    D:-------
;                    A--------
;
;  Road is ScrnMem Bit = 1
; Ditch and obstacle ScrnMem Bit = 0
;
drawcar:     movem.l   d1-d4/a0/a1,-(sp)
             moveq.l   #15,d1               ;shift
             and.w     d0,d1
             lsr.w     #4,d0                ;word offset
             add.w     d0,d0
             movea.l   screen,a1            ;pointer to first word under car
             lea.l     30*80(a1),a1
             adda.w    d0,a1
             lea.l     car,a0               ;pointer car table
             moveq.l   #carheight-1,d2      ;line pointer
             moveq.l   #0,d3                ;erase collision flags
.carloop:    moveq.l   #0,d4                ;erase long word
             move.w    (a0)+,d4             ;and write carmask to low word

             ror.l     d1,d4                ;rotate carmask
             move.w    (a1),d0              ;left word under car
             not.w     d0                   ;test for collision
             and.w     d4,d0
             or.w      d0,d3                ;note any collisions
             eor.w     d4,(a1)+             ;put car onto road/erase

             swap.w    d4                   ;the same for the second word

             move.w    (a1),d0
             not.w     d0
             and.w     d4,d0
             or.w      d0,d3
             eor.w     d4,(a1)
             lea.l     78(a1),a1
             dbf       d2,.carloop
             move.l    d3,d0                ;copy collision status to d0

             movem.l   (sp)+,d1-d4/a0/a1    ;and return
             rts       

pos:         .DC.w 0   ;car start position
vx:          .DC.w 0   ;
screen:      .DC.l -1  ;


car:         .DC.w %1111000000111100        ;mask for car: maximum width 16
             .DC.w %1111111111111100        ;maximum height is freely selectable

             .DC.w %1111111111111100        ;   constants
             .DC.w %0001111111110000        ; car width and
             .DC.w %0001111111110000        ; car height have to be adapted.
             .DC.w %0000111111100000
             .DC.w %0000011111000000
             .DC.w %0000001110000000
             .DC.w %0000011111000000
             .DC.w %0000011111000000
             .DC.w %0000001110000000
             .DC.w %0000000100000000

;==========================================================================
;
;qcopy       Quick copy of a memory block
;
;
; Input:
;  a0: Address of source block
;  a1: Address of destination block
;  d0: Length of block in bytes (0<= Length <= 3,145,727)
;  d0 is not checked for correct length!
;
; Output:
; a0,a1: Point to byte behind relevant block
;
; registers changed:
;  D 1,2,3,4,5,6,7
;  A 2,3,4,5,6,7
qcopy:       movem.l   d1-d7/a2-a6,-(sp)    ;save registers
             move.w    a0,d1                ;check orientation of blocks
             move.w    a1,d2                ; different  ==>copy bytes
             andi.w    #1,d1                ; both odd ==>one byte, then ,as if odd
             andi.w    #1,d2                ; both even copy blocks
             eor.w     d1,d2
             bne       .copybytes
             tst.w     d1
             beq       .copyeven
.copyodd:    move.b    (a0)+,(a1)+          ;odd address: copy one byte
             subq.w    #1,d0                ;adapt counter
             beq       .done                ;and test for end
.copyeven:   divu.w    #12*4,d0             ;even address: copy blocks of 48 bytes
             bra       .vlcpy               ;downward loop
.vlloop:     movem.l   (a0)+,d1-d7/a2-a6    ;Loop transfers 48 bytes at a time
             movem.l   d1-d7/a2-a6,(a1)     ;Simulates writing with
             lea.l     12*4(a1),a1          ;postincrement
.vlcpy:      dbf       d0,.vlloop           ;
             swap.w    d0                   ;look at remainder of division
             ext.l     d0                   ;extend to whole register
             ror.l     #2,d0                ;division by 4, remainder in bit 30,31
             bra       .lcpy                ;downward loop
.lloop:      move.l    (a0)+,(a1)+          ;counter div 4 copy longs
.lcpy:       dbf       d0,.lloop
.word:       lsl.l     #1,d0                ; Is remainder a word?
             bcc       .byte                ; no, then perhaps byte
             move.w    (a0)+,(a1)+          ; yes, then copy word
.byte:       tst.l     d0                   ; Is remainder byte?
             bpl       .done                ; no, then finished
             move.b    (a0)+,(a1)+          ; yes, then copy it
             bra       .done
;
; Blocks are of different orientation, so byte access is used.
; Optimisation not worth the effort as case too rare.
;
.copybytes:  bra       .btst                ; move memory block in bytes, as otherwise
.bloop:      move.b    (a0)+,(a1)+          ; an address error occurs
.btst:       dbf       d0,.bloop            ; here loop lower word
             swap.w    d0                   ; look at higher part
             subq.w    #1,d0                ; also decrement
             bcs       .done                ; <0, then finished
             swap.w    d0                   ; else: restore order
             bra       .bloop               ; and repeat inner loop
.done:       movem.l   (sp)+,d1-d7/a2-a6    ; finished.
             rts                            ; then back.

