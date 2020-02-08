                                                                                                                                                                                                                                                                
                TEXT



start:          move.w  #3,-(SP)
                trap    #14
                addq.l  #2,SP
                movea.l D0,A0
                move.l  #3999,D0
                movea.l A0,A1
loop:           move.w  (A1)+,D1
                or.w    (A1)+,D1
                or.w    (A1)+,D1
                or.w    (A1)+,D1
                not.w   D1
                move.w  D1,(A0)+
                move.w  D1,(A0)+
                move.w  D1,(A0)+
                move.w  D1,(A0)+
                dbra    D0,loop
                rts
                END
