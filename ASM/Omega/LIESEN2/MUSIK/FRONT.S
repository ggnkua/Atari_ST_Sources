                pea     text(pc)
                move.w  #9,-(a7)
                trap    #1
                pea     super(pc)
                move.w  #38,-(a7)
                trap    #14
                lea     12(a7),a7
                clr.w   -(a7)
                trap    #1
                                                                                                                                                                                                                                                                
super:          move.b  #6,$00000484.w
vbl:            move.w  #37,-(a7)
                trap    #14
                addq.l  #2,a7
wait:           tst.b   $FFFF8209.w
                beq.s   wait
play:           eori.w  #$0070,$FFFF8240.w
                bsr     music+34
                eori.w  #$0070,$FFFF8240.w
                cmpi.b  #$39,$FFFFFC02.w
                beq.s   hejoh†
                cmpi.b  #$1C,$FFFFFC02.w
                bne.s   vbl
                move.w  #800,d0
hej:            dbra    d0,hej
                bra.s   play
hejoh†:         rts

text:           DC.B 27,"E"
                DC.B "NiggerBrains........ Front cool l†t",13,10
                DC.B "by LAP of NEXT...this World Must be",13,10
                DC.B "destroyed........",13,10
                DC.B "FASTLY Ripped By Liesen Of Omega....",13,10
                DC.B "Return <FF>     Space <HejOh†>",0
                EVEN
                PATH '\'
music:          IBYTES 'FRONT2.IMG'
                END
