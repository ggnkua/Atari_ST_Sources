                OUTPUT 'C:\COML_TST.TTP'
                movea.l 4(A7),A5
                lea     _Stack(PC),A7
                lea     128(A5),A5
                moveq   #0,D0
                move.b  (A5)+,D0
                clr.b   0(A5,D0.w)
                                                                                                                                                                                                                                                                
                pea     _text(PC)
                move.w  #9,-(A7)
                trap    #1
                addq.l  #6,A7

                move.l  A5,-(A7)
                move.w  #9,-(A7)
                trap    #1
                addq.l  #6,A7
                move.w  #7,-(A7)
                trap    #1
                addq.l  #2,A7
                clr.w   -(A7)
                trap    #1
_text:          DC.B 13,10,10
                DC.B "Command Line text, line below is the commandline."
                DC.B 13,10,0
                EVEN
                BSS
                DS.B 200
_Stack:
                END
