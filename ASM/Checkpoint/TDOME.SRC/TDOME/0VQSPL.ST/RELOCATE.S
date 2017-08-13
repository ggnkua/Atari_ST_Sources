;-------------------------------------------------------------------------------
relocate_VQ:    >PART

                lea     program_start(PC),A0
                cmpa.l  #program_start,A0
                beq.s   relocated
                move.l  A0,D0

                adda.l  #relocation_table-program_start,A0

                move.l  (A0)+,D1        ;relocation info ??
                beq.s   end_relocation  ;nope...
                movea.l D0,A1           ; text start
                adda.l  D1,A1           ;1st adress - long offset
                moveq   #0,D1
relo_do:
                add.l   D0,(A1)         ;relocate!
RELO2:
                move.b  (A0)+,D1
                beq.s   end_relocation
                cmp.b   #1,D1
                bne.s   normal_distance
                lea     254(A1),A1
                bra.s   RELO2
normal_distance:
                adda.l  D1,A1
                bra.s   relo_do
end_relocation:
relocated:
                rts
                ENDPART
;-------------------------------------------------------------------------------
init_soundchip: >PART
                lea     $FFFF8800.w,A0
                move.w  #$0D00,D0
clr_ym:
                movep.w D0,0(A0)
                sub.w   #$0100,D0
                bpl.s   clr_ym
                move.w  #$07FF,D0
                movep.w D0,0(A0)
                rts
                ENDPART
;-------------------------------------------------------------------------------

