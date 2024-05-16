	opt	x+
x:              bra     main
**********************************************
*  Mini-program to determine the number of   *
*        clockcycles a routine uses          *
*             by Niclas Thisell              *
**********************************************

testrout:
;*****************************************************
; The routine you want to test here!
		lsl	#8,d1
;		nop				; DARREN PUT YOU COE HERE
;		nop
;		nop
                rts

testinit:
;****************************************************
; Stuff the right values into registers
                movea.l #spr2,a0
                movea.l #spr2,a1
                rts

main:
                pea     introtext
                move.w  #9,-(sp)
                trap    #1
                addq.l  #6,sp

                pea     0
                move.w  #$0020,-(sp)
                trap    #1
                addq.l  #6,sp
                move.l  $00000010,saveillegal
                move.w  #$0765,$ffff8240.w
                move.b  #2,$ffff820a.w
loop:
                move.w  #37,-(sp)
                trap    #14
                addq.l  #2,sp
                move    #$2700,sr
                jsr     testinit
                move.l  a0,-(sp)
                move.w  d0,-(sp)
                lea     $ffff8209.w,a0
                moveq   #0,d0
.wait:          move.b  (a0),d0
                beq.s   .wait
                not.w   d0
                lsr.w   d0,d0
                move.w  #128,d0
                sub.w   nopno(pc),d0
                add.w   d0,d0
                jmp     .jmpbase(pc,d0.w)
.jmpbase:
                dcb.w	128,$00004e71

                move.w  (sp)+,d0
                movea.l (sp)+,a0
;************************************
;sprite-routine or whatever here!
                jsr     testrout
continue:
;***********************************
                move.b  $ffff8209.w,d0
                move.b  $ffff8207.w,d1
                move.b  $ffff8205.w,d2
                move.b  $ffff8209.w,d3
                sub.b   d0,d3
                cmp.b   #18,d3
                beq.s   .found_values
                addq.w  #5,nopno
                andi.w  #127,nopno
                beq     something_wrong_here
                move.w  #$0765,$ffff8240.w
                move    #$2300,sr
                bra     loop
.found_values:
                move.w  #$0770,$ffff8240.w
                move    #$2300,sr

                and.l   #$000000ff,d0
                and.l   #$000000ff,d1
                and.l   #$000000ff,d2
                lsl.w   #8,d2
                add.w   d1,d2
                lsl.l   #8,d2
                add.w   d0,d2
                sub.l   $0000044e,d2
                divu    #160,d2
                move.l  d2,d0
                mulu    #256,d0
                swap    d2
                add.w   d2,d0
                sub.w   nopno(pc),d0
                sub.w   nopno(pc),d0
                add.w   d0,d0
                sub.w   #252,d0
                bra     getouttahere
something_wrong_here:
                move.w  #10000,d0
.p:             addi.w  #$0123,$ffff8240.w
                dbra    d0,.p
                moveq   #0,d0
                bra     getouttahere
nopno:          dc.w 0

getouttahere:
                move    #$2300,sr
                move.b  #2,$ffff820a.w
                move.w  #$0777,$ffff8240.w

                move.w  d0,-(sp)
                lea     numbertext+5(pc),a0
                moveq   #4,d7
.decoutloop:
                divu    #10,d0
                swap    d0
                add.w   #"0",d0
                move.b  d0,-(a0)
                clr.w   d0
                swap    d0
                dbra    d7,.decoutloop

                pea     numbertext
                move.w  #9,-(sp)
                trap    #1
                addq.l  #6,sp

                cmpi.w  #0,(sp)+
                beq.s   .notlasttext
                pea     lasttext
                move.w  #9,-(sp)
                trap    #1
                addq.l  #6,sp
.notlasttext:
                move.w  #7,-(sp)
                trap    #1
                addq.l  #2,sp
                move.l  saveillegal,$00000010

                clr.w   -(sp)
                trap    #1

saveillegal:    dc.l 0

introtext:      dc.b 27,"EYour routine takes ",0
numbertext:     dc.b "      clockcycles.",10,13,10,13,0
lasttext:       dc.b "I think you need to speed it up!",10,13,0
                even
spr2:           ds.b 4096
                end
