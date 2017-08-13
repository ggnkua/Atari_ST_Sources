;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
decompress_exp: >PART
*  DC.L $4AFC4E71

                lea     exp_comp(PC),A0

                lea     exp_decomp,A1

                moveq   #0,D5           ; current value
                move.w  #EXPS/8-1,D6
dc_exp:
delta_2bit_decode_blks:
                move.w  (A0)+,D0        ; get 16 bit
                REPT 8
                rol.w   #2,D0           ; get 2 bit
                moveq   #3,D1           ; 2 bit mask
                and.w   D0,D1           ; get & mask
                add.w   D1,D5           ; value+=delta
                move.w  D5,(A1)+        ; output value
                ENDR
                dbra    D6,dc_exp
                rts
                ENDPART
decompress_log: >PART

*  DC.L $4AFC4E71

                lea     log_comp(PC),A0

                lea     log_decomp,A1

                move.w  (A0)+,D5        ; normal 16bit run
                move.w  (A0)+,D6        ; 2bit 8blocks run
dl16:
                move.w  (A0)+,(A1)+
                dbra    D5,dl16

                move.w  -2(A0),D5       ; current value

                bra.s   delta_2bit_decode_blks

*dl_2bd:
*      move.w  (A0)+,D0        ; get 16 bit
*      REPT 8
*      rol.w   #2,D0           ; get 2 bit
*      moveq   #3,D1           ; 2 bit mask
*      and.w   D0,D1           ; get & mask
*      add.w   D1,D5           ; value+=delta
*      move.w  D5,(A1)+        ; output value
*      ENDR
*      dbra    D6,dl_2bd
*      rts
                ENDPART
                PATH 'C:\0NEW\TDOME\MORPHDOT\'
                PATH 'EXPLOG\'
exp_comp:       IBYTES 'EXP.PAK'
log_comp:       IBYTES 'LOG.PAK'
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------


