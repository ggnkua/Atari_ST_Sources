


depack_sample:
; a0=Gepacktes Sample (Gleichzeitig Ziel)
; d0=ungepackte L„nge

		move.l	A0,-(A7)
		move.l	D0,-(A7)
		bsr	init_depack
		move.l	(A7)+,D0
		move.l	(A7)+,A0		

                lea     depack_hi(PC),A2
                lea     depack_lo(PC),A3

                addq.l  #1,D0
                and.b   #-2,D0               ; l„nge aufrunden
                move.l  D0,D7
                lsr.l   #1,D7                ; Samplel„nge in Worten

                lea     0(A0,D0.l),A1        ; ende des Ziels
                adda.l  D7,A0                ; ende des Quellbereichs

                move.w  #128,D0              ; letztes Byte
                moveq   #0,D1                

depack_loop:    move.b  -(A0),D1             ; 2 Distanzen holen
                add.b   0(A2,D1.w),D0
                move.b  D0,-(A1)
                add.b   0(A3,D1.w),D0
                move.b  D0,-(A1)

                subq.l  #1,D7
                bne.s   depack_loop

                rts

init_depack:

                lea     depack_lo(PC),A1
                move.w  #15,D7
init1:          lea     power_bytes(PC),A0
                move.w  #15,D6
init2:          move.b  (A0)+,(A1)+
                dbra    D6,init2
                dbra    D7,init1

                lea     power_bytes(PC),A0
                lea     depack_hi(PC),A1
                move.w  #15,D7
init3:          move.w  #15,D6
                move.b  (A0)+,D0
init4:          move.b  D0,(A1)+
                dbra    D6,init4
                dbra    D7,init3

                rts


power_bytes:    DC.B -128,-64,-32,-16,-8,-4,-2,-1,0,1,2,4,8,16,32,64

sample_start:   DC.L 0
sample_end:     DC.L 0

depack_lo:      DS.B 256
depack_hi:      DS.B 256

; DEPACK END
                END
