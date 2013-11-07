                >PART 'StartUp'
                pea     super(pc)
                move.w  #38,-(a7)
                trap    #14
                addq.l  #6,a7
                clr.w   -(a7)
                trap    #1
                ENDPART

Super:



                PATH 'D:\'
fdc:            IBYTES 'FDCINTER.BN'
