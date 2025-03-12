*------------------------------------------------------------------------------*
* The Highlander Of The Pixel Twins presents his SYNC scroll routines.
*------------------------------------------------------------------------------*
* This routine is not the best.. But it works, and it is quite quick
* being a 10 line Sync Scroll. ( As an example the one in the Mindbomb
* main menu takes 20 lines ) and the one that Powerman uses ( and boasts
* about its speed.. ) also takes 10.
*------------------------------------------------------------------------------*
* Works on all machines!!!!! (Thanks to Tony B. for his Universal Left and
* right overscan code, without which this code would probably only run on
* my STE - just a bit of a pointless exercise saying as STE owners don't
* need all this shit to make it hardscroll!! )
*
* So far this code has been tested and run on....
*
*                                       One 4 meg Mega..
*                                       My 2 meg STE ( TOS 1.62 )
*                                       Douglas's 2 meg STE (an early 1040)
*                                       A 1 meg STFM ( TOS 1.4 )
*                                       A really early STFM (red power light)
*                                       A 1 meg STFM ( TOS 1.2 )
*
* This is not by any means an exhaustive test, but I have not had a chance
* to try it on any other type of machine.. But I think we can presume that
* it will work on any machine you try it on except probably the TT.
*------------------------------------------------------------------------------*
* This test program, merely scrolls up a screen to show it works. Hold ESC
* to watch it scroll up...
*------------------------------------------------------------------------------*
* If you use this code please credit me!!! Or I will be greatly upset......
*------------------------------------------------------------------------------*
* I am looking for more contacts at the moment, so if you are in a famous
* ( or not so famous ) demo crew, contact me.
*
*                                              Andrew Younger,
*                                              23/14 Balfour street,
*                                              Leith walk,
*                                              Edinburgh,
*                                              EH6 5DJ,
*                                              Scotland.
*
*                                              TEL. ( 031 ) 553 7799.
*------------------------------------------------------------------------------*

                clr.l   -(SP)
                move.w  #$20,-(SP)
                trap    #1
                addq.l  #6,SP
                move.l  D0,-(SP)

                move.l  $FFFF8200.w,-(SP)
                movem.l $FFFF8240.w,D0-D7
                movem.l D0-D7,-(SP)

                move.l  #SCR1+256,D0
                clr.b   D0
                move.l  D0,SCREEN_ADDR
                move.l  $70.w,-(SP)
                move.l  $68.w,-(SP)

                lea     $FFFFFA00.w,A1
                move.b  9(A1),-(SP)
                move.b  $1D(A1),-(SP)


********* END OF START UP CODE

                clr.b   9(A1)           ;shut off dangerous timers
                clr.b   $1D(A1)

                movea.l SCREEN_ADDR,A5
                lea     (-8*11)+2(A5),A5
                move.w  #266-1,D5
                move.l  #$FFF0,D3
                move.l  #$00,D4
fill1:          lea     230(A5),A6
                movea.l A6,A5
                move.w  #(28/2)-1,D6    ; fill screen row.
fill2:          move.l  D3,(A6)+
                move.l  D3,(A6)+
                move.l  D4,(A6)+
                move.l  D4,(A6)+
                dbra    D6,fill2
                dbra    D5,fill1

                movea.l SCREEN_ADDR,A0
                lea     (190*160)+(22*8)(A0),A0
                lea     (38*160)(A0),A0
                move.l  #$FFFFFFFF,(A0)+
                move.l  #$FFFFFFFF,(A0)+
                move.l  #SYNCSCROLL_VBI,$70.w

WAIT_VBI:       stop    #$2300

                move.l  SCREEN_ADDR,D0
                bsr     SETSCREEN
                cmpi.b  #$01,$FFFFFC02.w
                bne.s   _NOT_ESC
                addi.l  #160,SCREEN_ADDR

_NOT_ESC:       cmpi.b  #$39,$FFFFFC02.w
                bne.s   WAIT_VBI


******** START OF CLOSE DOWN CODE.

                lea     $FFFFFA00.w,A1
                move.b  (SP)+,$1D(A1)
                move.b  (SP)+,9(A1)

                move.l  (SP)+,$68.w
                move.l  (SP)+,$70.w
                movem.l (SP)+,D0-D7
                movem.l D0-D7,$FFFF8240.w
                move.l  (SP)+,$FFFF8200.w

                move.w  #$20,-(SP)
                trap    #1
                addq.l  #6,SP
                clr.w   -(SP)
                trap    #1

SCREEN_ADDR:    DS.L 1


*------------------------------------------------------------------------------*
* The Sync scroll new  VBI routine.
*------------------------------------------------------------------------------*
SYNCSCROLL_VBI: movem.l D0-A6,-(SP)
                move.l  #END_HBL,$68.w
                move    #$2100,SR
                move.w  #33,LINE_COUNT
                move.l  #NEW_HBL,$68.w
                movem.l __CLEARPAL(PC),D0-D7
                movem.l D0-D7,$FFFF8240.w

; You should insert normal VBI code here
; I.E. music drivers etc.
; be careful not to fuck up the timer.. ( MULS are not a good idea! )

_WT:            tst.w   LINE_COUNT
                bpl.s   _WT

                move    #$2700,SR
                movem.l (SP)+,D0-A6
END_HBL:        rte
__CLEARPAL:     DC.L 0,0,0,0,0,0,0,0
__SCREENPAL:    DC.L $0111,$222222,$333333,$444444,$555555,$666666,$777777,$777777
LINE_COUNT:     DC.W 0

*------------------------------------------------------------------------------*
* The HBLANK ($68) routine used for calling the SYNC scrolling routine at
* correct time.
*------------------------------------------------------------------------------*

NEW_HBL:        subq.w  #1,LINE_COUNT
                bne.s   END_HBL
SYNC_SCROLL:    movem.l D0-A6,-(SP)
                REPT 51
                nop
                ENDR
                lea     $FFFF820A.w,A0
                lea     $FFFF8260.w,A1
                moveq   #16,D1
                clr.b   $FFFF820A.w     ;top border
                REPT 13
                nop
                ENDR
                move.b  #2,$FFFF820A.w
                REPT 6
                nop
                ENDR
__WT_LN_SYNC:   move.b  $FFFF8209.w,D0
                beq.s   __WT_LN_SYNC
                sub.b   D0,D1
                lsl.b   D1,D0
                REPT 76
                nop
                ENDR
                moveq   #2,D0
                moveq   #0,D1

*------------------------------------------------------------------------------*
* Start of SYNC SCROLL CODE proper..
*------------------------------------------------------------------------------*

SYNC_SET1:      move.w  #6,D2
SYNC_SET2:      move.w  #6,D3
SYNC_SET3:      move.w  #6,D4
                tst.w   D2
                blt     SYNC_SCROLL2A
;
; LEFT AND RIGHT BORDER OVERSCAN
; 70 byte offset!
;
SYNC_SCROLL1A:  REPT 8
                nop
                ENDR
                move.b  D0,(A1)
                nop
                nop
                move.b  D1,(A1)
                REPT 89
                nop
                ENDR
                move.b  D1,(A0)
                move.b  D0,(A0)
                REPT 13
                nop
                ENDR
                move.b  D0,(A1)
                nop
                move.b  D1,(A1)
                dbra    D2,SYNC_SCROLL1A
                bra     SYNC_SCROLL2B
;
; RIGHT BORDER OVERSCAN.
; 44 byte offset.
;
SYNC_SCROLL2A:  nop
                nop
                nop
                nop
SYNC_SCROLL2B:  tst.w   D3
                beq     SYNC_SCROLL3A
                nop
                nop
                nop
                REPT 92
                nop
                ENDR
                move.b  D1,(A0)
                move.b  D0,(A0)
                REPT 13
                nop
                ENDR
                move.b  D0,(A1)
                nop
                move.b  D1,(A1)
                REPT 4
                nop
                ENDR
                dbra    D3,SYNC_SCROLL2B
                bra     SYNC_SCROLL3B
SYNC_SCROLL3A:  REPT 121
                nop
                ENDR
SYNC_SCROLL3B:  tst.w   D3
                blt     SYNC_SET4
                REPT 3
                nop
                ENDR
;
; LEFT AND RIGHT BORDER OVERSCAN
; RIGHT BORDER called 4 cycles early means 24 byte offset!
;
SYNC_SCROLL3:   move.b  D0,(A1)
                nop
                nop
                move.b  D1,(A1)
                tst.w   D4
                blt     SYNC_SET4
                REPT 89-1-4
                nop
                ENDR
                move.b  D1,(A0)
                move.b  D0,(A0)
                REPT 13+1
                nop
                ENDR
                move.b  D0,(A1)
                nop
                move.b  D1,(A1)
                REPT 8
                nop
                ENDR
                dbra    D4,SYNC_SCROLL3
SYNC_SET4:      move.w  #0,D2           ; make time uniform.
                bmi     END_SYNC
_WASTE:         REPT 125
                nop
                ENDR
                dbra    D2,_WASTE
END_SYNC:       movem.l __SCREENPAL(PC),D0-D7
                movem.l D0-D7,$FFFF8240.w
                movem.l (SP)+,D0-A6
                rte

*------------------------------------------------------------------------------*
* CALL THIS ROUTINE TO SET YOUR SCREEN ADDRESSES!!!!!!!!!!!!!!!!!!!!!!!!!!
*------------------------------------------------------------------------------*
* Address must be on an 8 byte boundary.
*------------------------------------------------------------------------------*
* Enter with d0 pointing to the screen address wanted.
*------------------------------------------------------------------------------*

SETSCREEN:      move.l  D0,D6
                and.w   #$FF,D0
                lea     SYNCTABLE(PC),A0
                adda.w  D0,A0

                move.w  (A0)+,D0
                move.w  (A0)+,D1
                move.w  (A0)+,D2
                subq.w  #1,D0
                move.w  D0,SYNC_SET1+2
                move.w  D1,SYNC_SET2+2
                move.w  D2,SYNC_SET3+2

                moveq   #9,D3
                add.w   D0,D1
                add.w   D1,D2
                sub.w   D2,D3
                move.w  D3,SYNC_SET4+2
                moveq   #0,D0
                move.w  (A0),D0
                sub.l   D0,D6
                lsr.w   #8,D6
                move.l  D6,$FFFF8200.w  ; set new screen address.
                rts

*------------------------------------------------------------------------------*

SYNCTABLE:
; Sync table for max 10 scanlines
                DC.W 6,1,2,$0200
                DC.W 0,6,0,$0100
                DC.W 2,3,0,$0100
                DC.W 4,0,0,$0100
                DC.W 4,6,0,$0200
                DC.W 6,3,0,$0200
                DC.W 8,0,0,$0200
                DC.W 0,6,2,$0100
                DC.W 6,3,1,$0200
                DC.W 8,0,1,$0200
                DC.W 0,6,3,$0100
                DC.W 0,2,0,$00
                DC.W 0,8,0,$0100
                DC.W 2,5,0,$0100
                DC.W 4,2,0,$0100
                DC.W 0,8,1,$0100
                DC.W 2,5,1,$0100
                DC.W 8,2,0,$0200
                DC.W 0,8,2,$0100
                DC.W 2,5,2,$0100
                DC.W 4,2,2,$0100
                DC.W 4,0,6,$0100
                DC.W 0,4,0,$00
                DC.W 2,1,0,$00
                DC.W 2,7,0,$0100
                DC.W 4,4,0,$0100
                DC.W 6,1,0,$0100
                DC.W 2,7,1,$0100
                DC.W 4,4,1,$0100
                DC.W 6,1,1,$0100
                DC.W 0,0,10,$00
                DC.W 4,4,2,$0100
SYNCOFF:        DC.L SYNCTABLE

*-------------------- END OF SYNC SCROLL ROUTINES -----------------------------*

                BSS
SCR1:           DS.B 40000+256
                DS.B 40000

*------------------------------------------------------------------------------*
                END
