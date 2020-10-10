;
; TT-Noise
; By GGN of KšA software productions 14/11/2010
; Jumping on the TV noise bangwagon currently on pouet
; Apologies to 505/Checkpoint - he requested a STE version ;)
;

                OPT D-
                OPT X-
                OPT F+          ;Fastload bit

                clr.l   -(SP)
                move.w  #$20,-(SP)
                trap    #1              ;Supervisor mode on

                IFNE 1          ;generic version
                OUTPUT 'TTNOISE.PRG'
;                move.w  #$FF,D7
                subq.b  #1,D7           ;I will burn in hell for this :(
                lea     $FFFF8400.w,A0
palset:         move.w  D6,(A0)+
                add.w   #$0111,D6
                dbra    D7,palset

                ELSE            ;TT-mono version
                OUTPUT 'TTNOISEM.PRG'
                clr.w   $FFFF8400.w

                ENDC

                lea     $FFFF8205.w,A0  ;Video address pointer high
loop:
                movep.w D5,0(A0)        ;Zap value to high and med bytes
                addq.b  #1,D5
                bra.s   loop

                END
