playmod:
                jsr     dspmod+28

                lea     mod,A0
                lea     vtab,A1
                jsr     dspmod+36

                move.w  dspmod+60,D0
                bset    #1,D0
                move.w  D0,dspmod+60


                move.l  $70.w,oldvbi
                move.l  #vbi,$70.w
                rts



stopmod:
                move.l  oldvbi,$70.w
                jsr     dspmod+40


                jsr     dspmod+32
                rts




                PATH 'D:\TNB-SHIT\SYMPOSI\COMPIL\'
mod:            IBYTES 'CRICKEY.MOD'
                PATH 'D:\CODING\'
dspmod:         IBYTES 'DSPMOD.TCE'

vtab:           DC.W $2FFF,$2FFF,$2FFF,$2FFF
                DC.W 0,0,0,0

                END
