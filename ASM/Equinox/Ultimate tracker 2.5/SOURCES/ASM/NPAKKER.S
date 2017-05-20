*
* Routines used to unpack NOISEPAKKER files
*

	.EXPORT	Unpack_ndpk,Lenght_ndpk

		text

; -----------------------------------------------------------------
; Returns size of unpacked file
; -----------------------------------------------------------------

Lenght_ndpk:
		MOVEM.L	D1-D7/A0-A6,-(A7)
		ADDQ.L	#8,A0
		BSR.b	analyse_module
		BSR		init_depack
		MOVE.L	sample_start,A0
		MOVE.L	sample_end,D0
		SUB.L	A0,D0
		MOVEM.L	(A7)+,D1-D7/A0-A6
		RTS

; ----------------------------------------------------------------
; Unpack the file
; ----------------------------------------------------------------

Unpack_ndpk:	
		MOVEM.L	D0-D7/A0-A6,-(A7)
		ADDQ.L	#8,A0
		bsr.b   analyse_module       ; find sample start/end
        bsr	   	init_depack
        movea.l sample_start,A0  	 ; packed sample
        move.l  sample_end,D0
        sub.l   A0,D0                ; unpacked length
        bsr.b   depack_sample        ; depack over source
        MOVEM.L	(A7)+,D0-D7/A0-A6
        rts

analyse_module: 
		move.l  A0,-(A7)
        lea     $03b8(A0),A1
        moveq   #$7f,D0
        moveq   #0,D4
mt_loop:
		move.l  D4,D2
        subq.w  #1,D0
mt_lop2:
		move.b  (A1)+,D4
        cmp.b   D2,D4
        bgt.s   mt_loop
        dbra    D0,mt_lop2
        addq.b  #1,D2

        asl.l   #8,D2
        asl.l   #2,D2
        add.l   #$043c,D2
        move.l  D2,D1
        add.l   A0,D2
        movea.l D2,A2
        move.l  A2,sample_start

        moveq   #$1e,D0
mt_lop3:
        moveq   #0,D4
        move.w  42(A0),D4
        add.l   D4,D4
        adda.l  D4,A2
        adda.l  #$1e,A0
        dbra    D0,mt_lop3

        move.l  A2,sample_end
        movea.l (A7)+,A0
        rts

; a0=packed sample (also destination)
; d0=unpacked length

depack_sample:
        lea		depack_hi,a2
        lea		depack_lo,a3
        addq.l  #1,D0
        and.b   #-2,D0               ; round length up
        move.l  D0,D7
        lsr.l   #1,D7                ; sample length in words

        lea     0(A0,D0.l),A1        ; destination end
        adda.l  D7,A0                ; source end

        move.w  #128,D0              ; last byte
        moveq   #0,D1                ; clear temp

depack_loop:    
		move.b  -(A0),D1             ; get 2 distances
        add.b   0(A2,D1.w),D0
        move.b  D0,-(A1)
        add.b   0(A3,D1.w),D0
        move.b  D0,-(A1)
        subq.l  #1,D7
        bne.s   depack_loop
        rts

init_depack:
        lea     depack_lo,A1
        move.w  #15,D7
init1:	lea		power_bytes,a0
        move.w  #15,D6
init2:  move.b  (A0)+,(A1)+
        dbra    D6,init2
        dbra    D7,init1

        lea     power_bytes,A0
        lea     depack_hi,A1
        move.w  #15,D7
init3:	move.w	#15,d6
        move.b  (A0)+,D0
init4:  move.b  D0,(A1)+
        dbra    D6,init4
        dbra    D7,init3
		RTS

		data

power_bytes:    DC.B -128,-64,-32,-16,-8,-4,-2,-1,0,1,2,4,8,16,32,64
sample_start:   DC.L 0
sample_end:     DC.L 0

		bss

depack_hi:		ds.b 256
depack_lo:		ds.b 256

	