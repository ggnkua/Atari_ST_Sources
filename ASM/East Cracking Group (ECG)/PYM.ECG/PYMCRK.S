;
; the east cracking group
; punish your machine demo
; v00, full crack source soon, mazbe.
;
s               SET $00100000

                OPT D+


                pea     0.w
                move.w  #$0020,-(SP)
                trap    #1
                lea     stack,SP
                move    #$2700,SR
                clr.b   $FFFFFA07.w
                clr.b   $FFFFFA09.w
                move.l  #vbl,$00000070.w
                move    #$2300,SR
                bsr     wait_vbl
                clr.b   $FFFF8260.w
                bsr     wait_vbl
                clr.b   $FFFF820A.w
                bsr     wait_vbl
                move.b  #2,$FFFF820A.w
                bsr     wait_vbl

                move.l  #scr_ram,D0
                clr.b   D0
                move.l  D0,screen0


                move    #$2700,SR

                bsr     save_memory




                lea     _478,A0
                lea     s+$0478,A1
                move.w  #e478-_478,D0
                bsr     copy_bytes

;      illegal
                nop

                lea     _478,A0
                lea     $00000478,A1
                move.w  #e478-_478,D0
                bsr     copy_bytes


                move.w  #$4EF9,s+$04F6
                move.l  #e,s+$04F6+2


;  illegal
                nop
                jmp     s+$047C




copy_bytes:
                move.b  (A0)+,(A1)+
                dbra    D0,copy_bytes
                rts



vbl:            PART
                addq.l  #1,$00000466.w
rte:
                rte
wait_vbl:
                clr.l   $00000466.w
wv:
                tst.l   $00000466.w
                beq.s   wv
                rts
                ENDPART

save_memory:
                lea     $00000008.w,A0
                lea     memsave,A1
                move.l  #$00020000/16-4,D0
sm0:
                move.l  (A0)+,(A1)+
                move.l  (A0)+,(A1)+
                move.l  (A0)+,(A1)+
                move.l  (A0)+,(A1)+
                dbra    D0,sm0
                rts

e:
restore_memory:
                move    SR,_sr
                move    #$2700,SR
                movem.l D0-A7,regs
                lea     stack,SP

                lea     $00000008.w,A0
                lea     s+8,A1

                lea     memsave,A2


                move.l  #$00020000/4-4,D0
rm0:
                move.l  (A0),(A1)+
                move.l  (A2)+,(A0)+

                dbra    D0,rm0

                move.l  #rte,$00000070.w
                move.l  #rte,$00000068.w
                move.l  #rte,$00000118.w
                illegal
                nop
                rts

_sr:            DC.L 0
regs:           DS.L 16






                DATA
screen0:        DC.L 0

_478:           IBYTES '478.BIN'
e478:
                BSS
                DS.B 256
scr_ram:        DS.B 32000

memsave:        DS.L $00020000/4






                DS.B 1024
stack:          DS.B 1024
                END
