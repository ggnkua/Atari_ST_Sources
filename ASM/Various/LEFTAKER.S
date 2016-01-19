* This was originally written in Devpack but I think it works in
* any assembler for the Atari Ste.
* It only works for the Ste because the St doesn't have the
* adresses which is used to remove the left border.
* The routine is called "Left taker" because it takes a bit
* of the left border (Sixteen pixels).


* Written by Martin Petterson from Stockholm    

		text

                pea     rout
                move.w  #38,-(SP)
                trap    #14
                addq.l  #6,SP

                move.w  #0,-(SP)
                trap    #1

rout:
                move.b  $00FF8260,resolution
                move.b  #0,$00FF8260

                move.l  #screen,tiny

                move.b  tiny+2,$00FF8203
                move.b  tiny+1,$00FF8201
                move.b  tiny+3,$00FF820D

                lea     screen,A0
                move.w  #$20CF,D0
fine_screen:    move.l  #$55555555,(A0)+
                dbra    D0,fine_screen

                move.w  #1,$00FF8264		this two lines are
                move.b  #0,$00FF8264		the only thing you need 

                move.w  #8,-(SP)
                trap    #1
                addq.l  #2,SP

                move.b  resolution,$00FF8260

                move.w  #0,$00FF8264             back to normal

                rts

                BSS

                EVEN
screen:         DS.B 168*200
resolution:     DS.W 1
tiny:           DS.L 1
                END
