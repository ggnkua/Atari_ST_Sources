test            EQU 0
                IF test=1
                PART 'Test'
                move.w  #2,-(A7)
                trap    #14
                addq.l  #2,A7
                movea.l D0,A0
                moveq   #0,D0
                moveq   #1,D1
                moveq   #8,D2
                moveq   #4,D3
                bsr.s   Plot
                move.w  #7,-(A7)
                trap    #1
                addq.l  #2,A7
                clr.w   -(A7)
                trap    #1
                ENDPART
                ENDC

Plot:           PART 'Plot routine'
* A0=Screen Adr
* d0=x
* d1=y
* d2=color
* d3=resolution
s:              movem.l D0-A6,-(A7)
                lea     s(PC),A6
                lea     PloterTab(PC),A5
                add.w   D3,D3
                move.w  0(A5,D3.w),D3
                jsr     0(A6,D3.w)
                movem.l (A7)+,D0-A6
                rts
PloterTab:      DC.W 0,0,0,TTLow-s,TTMedium-s,0
                ENDPART
TTLow:          >PART 'TT Medium pixel driver'
                mulu    #320,D1
                move.w  D0,D3
                and.w   #$FFF0,D3
                add.w   D3,D1
                sub.w   D3,D0
                adda.w  D1,A0
                eori.w  #$0F,D0
                moveq   #0,D1
                bset    D0,D1
                move.w  D1,D0
                not.w   D1

                moveq   #7,D3
.ColSprut:      rol.b   #1,D2
                bcc.s   .NotSet
                or.w    D0,(A0)+
                bra.s   .Joina
.NotSet:        and.w   D1,(A0)+
.Joina:         dbra    D3,.ColSprut
                rts
                ENDPART
TTMedium:       >PART 'TT Medium Pixel Driver'
                mulu    #320,D1
                move.w  D0,D3
                and.w   #$FFF0,D3
                sub.w   D3,D0
                lsr.w   #1,D3
                add.w   D3,D1
                adda.w  D1,A0
                eori.w  #$0F,D0
                moveq   #0,D1
                bset    D0,D1
                move.w  D1,D0
                not.w   D1

.ColSprut2:     rol.b   #1,D2
                bcc.s   .NotSet2
                or.w    D0,(A0)+
                bra.s   .Joina2
.NotSet2:       and.w   D1,(A0)+
.Joina2:
                dbra    D3,.ColSprut2
                rts
                ENDPART

                END
