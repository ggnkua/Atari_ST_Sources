                pea     super
                move.w  #$26,-(SP)
                trap    #14

super:          pea     message
                move.w  #9,-(SP)
                trap    #1              ;print message

                move    #$2700,SR       ;disable interrupts
                move.w  #$0FF0,D0       ;set initial colour

loop:           move.w  D0,$FFFF8240.w  ;plot colour
                ror.w   #1,D0           ;change colour
                bra.s   loop            ;branch forever (which is Cathy's lifespan!)

message:        DC.B 27,'E'
                DC.B 'Na ziseis Katerina!',0
                END
