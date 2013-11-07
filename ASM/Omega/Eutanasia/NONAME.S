s:
                pea     Installa(PC)
                move.w  #$38,-(A7)
                trap    #14
                addq.l  #6,A7

                pea     UnInstalla(PC)
                move.w  #38,-(A7)
                trap    #14
                addq.l  #6,A7

                clr.w   -(A7)
                trap    #1

NewTrap:        >PART 'Trap #1 patchen'
                jmp     $070000
_JmpOldTrap1Addr EQU *-4

                ENDPART
                >PART 'Super Install/UnInstall'
Installa:       lea     _JumpOldTrap1Addr(PC),A0
                move.l  $84.w,(A0)
                lea     NewTrap(PC),A0
                move.l  A0,$84.w
                rts

UnInstalla:     lea     _JumpOldTrap1Addr(PC),A0
                move.l  (A0),$84.w
                rts
                ENDPART
