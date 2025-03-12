; Cubase Audio Falcon (CAF) 2.06 Dongle emulator crack

		opt s-
		move.l sp,a0
		move.l 4(a0),a0
		move.l $c(a0),d0
		add.l $14(a0),d0
		add.l $1c(a0),d0
		add.l #$200,d0
		move.l d0,-(sp)
		pea (a0)
		move.w #0,-(sp)
		move.w #$4a,-(sp)
		trap #1
		add.l #12,sp
		move.l #(end+$f0),sp
		lea text(pc),a0
		bsr print
		pea env(pc)
		pea com(pc)
		pea filename(pc)
		move.w #3,-(sp)
		move.w #$4b,-(sp)
		trap #1
		add.l #16,sp
		tst.l d0
		bpl.s ok
		lea err(pc),a0
		bsr print
		lea filename(pc),a0
		bsr print
		lea nofile(pc),a0
		bsr print
		move.w #7,-(sp)
		trap #1
		addq.l #2,sp
		bra.s exit

ok		move.l d0,a0
		add.l #$5a236,a0
		cmp.l #$48e77ffe,(a0)		;check for unpacked main file
		bne.s packed
		move.w #$4ef9,(a0)+		;unpacked version so apply crack and run
		move.l #dongle,(a0)+
		
go		move.l d0,-(sp)
		move.l d0,-(sp)
		move.l d0,-(sp)
		move.w #4,-(sp)
		move.w #$4b,-(sp)
		trap #1
		add.l #16,sp

exit		clr.w -(sp)
		trap #1

packed		sub.l #$59fce,a0		;packed version so patch depack code
		move.w #$4eb9,(a0)+		;to apply crack after depack
		move.l #patch,(a0)+
		bra.s go

patch		add.l #$5a236,a5		;now depacked so apply crack
		move.w #$4ef9,(a5)		;then return to run
		move.l #dongle,2(a5)
		sub.l #$5a236,a5
		add.l #$8000,d0
		rts

dongle		movem.l d1-d7/a0,-(sp)
		tst.w d0
		beq.s .zero
		moveq #1,d0
.zero		lea pin14(pc),a0		;input 0 or 1 in d0
		move.b d0,(a0)			;and store to pin 14 input
		not.b d0
		move.b d0,1(a0)

		bsr do_gates			;calculate all gates

		move.b fflop_10_out(pc),d0	;get output 0 or 1 in d0 (1 tick behind like EP600)
		bsr do_fflops			;update flip flops 1-16
		and.w #1,d0
		movem.l (sp)+,d1-d7/a0
		rts

do_fflops	

		lea fflop_1_out(pc),a0		;table of 16 fflops
do_fflop_1
		move.b ic2a(pc),d6		;d6 = K (input #1)
		move.b icu1(pc),d5		;d5 = J (input #2)
		bsr calc_fflop
do_fflop_2
		move.b ic77b(pc),d6		;d6 = K (input #1)
		move.b ic12c(pc),d5		;d5 = J (input #2)
		bsr calc_fflop
do_fflop_3	
		move.b ic38c(pc),d6		;d6 = K (input #1)
		move.b ic12b(pc),d5		;d5 = J (input #2)
		bsr calc_fflop
do_fflop_4	
		move.b ic1d(pc),d6		;d6 = K (input #1)
		move.b ic1c(pc),d5		;d5 = J (input #2)
		bsr calc_fflop
do_fflop_5	
		move.b ic38b(pc),d6		;d6 = K (input #1)
		move.b ic12a(pc),d5		;d5 = J (input #2)
		bsr calc_fflop
do_fflop_6	
		move.b ic11d(pc),d6		;d6 = K (input #1)
		move.b ic2b(pc),d5		;d5 = J (input #2)
		bsr calc_fflop
do_fflop_7	
		move.b pin14(pc),d6		;d6 = K (input #1)
		move.b pin14+1(pc),d5		;d5 = J (input #2)
		bsr calc_fflop
do_fflop_8	
		move.b ic1b(pc),d6		;d6 = K (input #1)
		move.b ic94b(pc),d5		;d5 = J (input #2)
		bsr calc_fflop
do_fflop_9
		move.b ic11b(pc),d6		;d6 = K (input #1)
		move.b ic94d(pc),d5		;d5 = J (input #2)
		bsr calc_fflop
do_fflop_10	
		move.b icu2(pc),d6		;d6 = K (input #1)
		move.b ic3b(pc),d5		;d5 = J (input #2)
		bsr calc_fflop
do_fflop_11	
		move.b ic7b(pc),d6		;d6 = K (input #1)
		move.b ic7c(pc),d5		;d5 = J (input #2)
		bsr calc_fflop
do_fflop_12	
		move.b ic11c(pc),d6		;d6 = K (input #1)
		move.b ic12d(pc),d5		;d5 = J (input #2)
		bsr calc_fflop
do_fflop_13	
		move.b ic5a(pc),d6		;d6 = K (input #1)
		move.b ic3a(pc),d5		;d5 = J (input #2)
		bsr calc_fflop
do_fflop_14	
		move.b ic7d(pc),d6		;d6 = K (input #1)
		move.b ic94c(pc),d5		;d5 = J (input #2)
		bsr calc_fflop
do_fflop_15	
		move.b ic77c(pc),d6		;d6 = K (input #1)
		move.b ic2c(pc),d5		;d5 = J (input #2)
		bsr calc_fflop
do_fflop_16	
		move.b ic13c(pc),d6		;d6 = K (input #1)
		move.b ic2d(pc),d5		;d5 = J (input #2)
		bsr calc_fflop
		rts

calc_fflop					;emulate JK flip flop
		move.b (a0),d7			;d7 = Q (current state)
		and.b d7,d6			;d5 = J (input #2), d6 = K (input #1), d7 = Q (current state)
		not.b d7
		and.b d7,d5
		or.b d6,d5
		eor.b d5,(a0)
		eor.b d5,1(a0)
		addq.l #2,a0			;update address for next fflop in table
		rts

do_gates					;some redundant code that saved every gate state
						;has been commented out for optimisation in final version
						;(more could be done here but for clarity it's been left
						; in same order as the schematic)
do_ic73a
		move.b pin19(pc),d0
		and.b fflop_2_out(pc),d0
		not.b d0
		move.b d0,ic73a

do_ic71a
		move.b fflop_12_out+1(pc),d0
		and.b pin19+1(pc),d0
		not.b d0
;		move.b d0,ic71a

do_ic72a
;		move.b ic71a(pc),d0
		and.b ic73a(pc),d0
		not.b d0
;		move.b d0,ic72a

do_ic60a
;		move.b ic72a(pc),d0
		and.b pin14+1(pc),d0
		and.b fflop_5_out(pc),d0
		and.b fflop_6_out+1(pc),d0
		move.b d0,ic60a

do_ic50a
		move.b pin14(pc),d0
		and.b fflop_4_out+1(pc),d0
		not.b d0
		move.b d0,ic50a

do_ic58a
		move.b pin20+1(pc),d0
		and.b fflop_5_out(pc),d0
		not.b d0
		move.b d0,ic58a

do_ic57a
		move.b fflop_3_out(pc),d0
		and.b pin20(pc),d0
		not.b d0
;		move.b d0,ic57a

do_ic59a
;		move.b ic57a(pc),d0
		and.b ic58a(pc),d0
		not.b d0
		move.b d0,ic59a

do_ic90b
		move.b pin21(pc),d0
		and.b fflop_12_out(pc),d0
		not.b d0
		move.b d0,ic90b

do_ic90a
		move.b fflop_1_out(pc),d0
		and.b pin21+1(pc),d0
		not.b d0
;		move.b d0,ic90a

do_ic90c
;		move.b ic90a(pc),d0
		and.b ic90b(pc),d0
		not.b d0
		move.b d0,ic90c

do_ic62a
		move.b fflop_13_out+1(pc),d0
		and.b ic90c(pc),d0
		and.b ic59a(pc),d0
		not.b d0
;		move.b d0,ic62a

do_ic51a
;		move.b ic62a(pc),d0
		or.b ic50a(pc),d0
		not.b d0
		move.b d0,ic51a

do_icu2						;fflop 10 in 1
		move.b fflop_8_out+1(pc),d0
		or.b ic51a(pc),d0
		or.b ic60a(pc),d0
		move.b d0,icu2

do_ic68a
		move.b fflop_11_out(pc),d0
		and.b pin14(pc),d0
		move.b d0,ic68a

do_ic49a
		move.b fflop_11_out(pc),d0
		and.b fflop_4_out(pc),d0
		and.b pin14+1(pc),d0
		not.b d0
		move.b d0,ic49a

do_ic45a
		move.b fflop_8_out(pc),d0
		and.b fflop_7_out(pc),d0
		not.b d0
;		move.b d0,ic45a

do_ic48a
;		move.b ic45a(pc),d0
		or.b ic49a(pc),d0
		not.b d0
		move.b d0,ic48a

do_ic85a
;		move.b ic48a(pc),d0
		and.b fflop_14_out(pc),d0
		move.b d0,ic85a

do_ic74a
;		move.b ic85a(pc),d0
		and.b fflop_9_out(pc),d0
		move.b d0,ic74a

do_ic29b
;		move.b ic74a(pc),d0
		and.b fflop_5_out(pc),d0
		move.b d0,ic29b

do_ic13a
;		move.b ic29b(pc),d0
		and.b fflop_3_out(pc),d0
		move.b d0,ic13a

do_ic13b
;		move.b ic13a(pc),d0
		and.b fflop_2_out(pc),d0
		move.b d0,ic13b

do_ic18b
;		move.b ic13b(pc),d0
		and.b fflop_12_out(pc),d0
		move.b d0,ic18b

do_ic1a
;		move.b ic18b(pc),d0
		and.b fflop_1_out(pc),d0
		move.b d0,ic1a

do_ic18a
;		move.b ic1a(pc),d0
		and.b fflop_6_out(pc),d0
		move.b d0,ic18a

do_ic79a
;		move.b ic18a(pc),d0
		and.b fflop_15_out(pc),d0
		move.b d0,ic79a

do_ic85b
;		move.b ic79a(pc),d0
		and.b fflop_16_out(pc),d0
		move.b d0,ic85b

do_ic82a
;		move.b ic85b(pc),d0
		and.b fflop_13_out(pc),d0
;		move.b d0,ic82a

do_ic3b							;fflop 10 in 2
;		move.b ic82a(pc),d0
		or.b ic68a(pc),d0
		move.b d0,ic3b

do_ic9a
		move.b pin16(pc),d0
		or.b fflop_9_out(pc),d0
		not.b d0
		move.b d0,ic9a

do_ic11a
		move.b fflop_14_out+1(pc),d0
		and.b pin16(pc),d0
;		move.b d0,ic11a

do_ic2a							;fflop 1 in 1
;		move.b ic11a(pc),d0
		or.b ic9a(pc),d0
		move.b d0,ic2a

do_ic4b
		move.b fflop_12_out(pc),d0
		or.b pin15+1(pc),d0
		or.b fflop_9_out(pc),d0
		not.b d0
		move.b d0,ic4b

do_ic4a
		move.b fflop_3_out(pc),d0
		or.b pin15(pc),d0
		or.b fflop_12_out(pc),d0
		not.b d0
		move.b d0,ic4a

do_icu1							;fflop 1 in 2
		move.b ic18b(pc),d0
		or.b ic4a(pc),d0
		or.b ic4b(pc),d0
		move.b d0,icu1

do_ic77b						;fflop 2 in 1
		move.b fflop_3_out+1(pc),d0
		and.b fflop_5_out(pc),d0
		and.b fflop_4_out+1(pc),d0
		move.b d0,ic77b

do_ic7a
		move.b fflop_14_out+1(pc),d0
		and.b fflop_9_out(pc),d0
		move.b d0,ic7a

do_ic12c						;fflop 2 in 2
		move.b ic13a(pc),d0
		or.b ic7a(pc),d0
		move.b d0,ic12c

do_ic38c						;fflop 3 in 1
		move.b fflop_11_out(pc),d0
		and.b fflop_4_out(pc),d0
		and.b fflop_5_out+1(pc),d0
		move.b d0,ic38c

do_ic76c
		move.b pin18+1(pc),d0
		and.b fflop_14_out(pc),d0
		not.b d0
		move.b d0,ic76c

do_ic76a
		move.b pin18(pc),d0
		and.b fflop_4_out(pc),d0
		not.b d0
;		move.b d0,ic76a

do_ic76b
;		move.b ic76a(pc),d0
		and.b ic76c(pc),d0
		not.b d0
		move.b d0,ic76b

do_ic38a
		move.b fflop_8_out+1(pc),d0
		and.b fflop_9_out+1(pc),d0
		and.b ic76b(pc),d0
		move.b d0,ic38a

do_ic12b						;fflop 3 in 2
		move.b ic29b(pc),d0
		or.b ic38a(pc),d0
		move.b d0,ic12b

do_ic1d							;fflop 4 in 1
		move.b fflop_11_out+1(pc),d0
		and.b fflop_8_out(pc),d0
		move.b d0,ic1d

do_ic1c							;fflop 4 in 2
		move.b fflop_7_out(pc),d0
		and.b pin14+1(pc),d0
		move.b d0,ic1c

do_ic38b						;fflop 5 in 1
		move.b fflop_4_out+1(pc),d0
		and.b fflop_11_out+1(pc),d0
		and.b fflop_8_out(pc),d0
		move.b d0,ic38b

do_ic29a
		move.b fflop_9_out(pc),d0
		and.b fflop_14_out+1(pc),d0
		move.b d0,ic29a

do_ic12a						;fflop 5 in 2
		move.b ic74a(pc),d0
		or.b ic29a(pc),d0
		move.b d0,ic12a

do_ic11d						;fflop 6 in 1
		move.b fflop_12_out(pc),d0
		and.b fflop_2_out+1(pc),d0
		move.b d0,ic11d

do_ic23a
		move.b fflop_9_out(pc),d0
		and.b fflop_3_out+1(pc),d0
		and.b fflop_1_out(pc),d0
		move.b d0,ic23a

do_ic2b							;fflop 6 in 2
		move.b ic1a(pc),d0
		or.b ic23a(pc),d0
		move.b d0,ic2b

do_ic1b							;fflop 8 in 1
		move.b fflop_7_out(pc),d0
		and.b pin14(pc),d0
		move.b d0,ic1b

do_ic94b						;fflop 8 in 2
		move.b pin14(pc),d0
		or.b fflop_7_out(pc),d0
		move.b d0,ic94b

do_ic35a
		move.b fflop_8_out+1(pc),d0
		and.b pin14(pc),d0
		move.b d0,ic35a

do_ic11b						;fflop 9 in 1
;		move.b ic35a(pc),d0
		and.b fflop_4_out(pc),d0
		move.b d0,ic11b

do_ic40c
		move.b pin17+1(pc),d0
		and.b fflop_11_out+1(pc),d0
		not.b d0
		move.b d0,ic40c

do_ic40a
		move.b fflop_8_out(pc),d0
		and.b pin17(pc),d0
		not.b d0
;		move.b d0,ic40a

do_ic40b
;		move.b ic40a(pc),d0
		and.b ic40c(pc),d0
		not.b d0
		move.b d0,ic40b

do_ic77a
		move.b fflop_14_out(pc),d0
		and.b fflop_7_out+1(pc),d0
		and.b ic40b(pc),d0
		move.b d0,ic77a

do_ic94d						;fflop 9 in 2
		move.b ic85a(pc),d0
		or.b ic77a(pc),d0
		move.b d0,ic94d

do_ic7b							;fflop 11 in 1
		move.b pin14(pc),d0
		and.b fflop_8_out(pc),d0
		move.b d0,ic7b

do_ic43a
		move.b pin14(pc),d0
		or.b fflop_8_out(pc),d0
;		move.b d0,ic43a

do_ic7c							;fflop 11 in 2
;		move.b ic43a(pc),d0
		and.b fflop_7_out(pc),d0
		move.b d0,ic7c

do_ic11c						;fflop 12 in 1
		move.b fflop_5_out+1(pc),d0
		and.b fflop_2_out+1(pc),d0
		move.b d0,ic11c

do_ic27b
		move.b fflop_3_out(pc),d0
		and.b fflop_9_out+1(pc),d0
		move.b d0,ic27b

do_ic12d						;fflop 12 in 2
		move.b ic13b(pc),d0
		or.b ic27b(pc),d0
		move.b d0,ic12d

do_ic5a							;fflop 13 in 1
		move.b fflop_12_out+1(pc),d0
		and.b fflop_15_out(pc),d0
		and.b fflop_16_out+1(pc),d0
		move.b d0,ic5a

do_ic25b
		move.b fflop_1_out+1(pc),d0
		and.b fflop_6_out(pc),d0
		move.b d0,ic25b

do_ic3a							;fflop 13 in 2
		move.b ic85b(pc),d0
		or.b ic25b(pc),d0
		move.b d0,ic3a

do_ic7d							;fflop 14 in 1
		move.b ic35a(pc),d0
		and.b fflop_4_out+1(pc),d0
		move.b d0,ic7d

do_ic86a
		move.b fflop_7_out+1(pc),d0
		and.b fflop_11_out(pc),d0
;		move.b d0,ic86a

do_ic94c						;fflop 14 in 2
;		move.b ic86a(pc),d0
		or.b ic48a(pc),d0
		move.b d0,ic94c

do_ic77c						;fflop 15 in 1
		move.b fflop_6_out(pc),d0
		and.b fflop_1_out+1(pc),d0
		and.b fflop_12_out(pc),d0
		move.b d0,ic77c
				
do_ic55a
		move.b fflop_2_out+1(pc),d0
		and.b fflop_3_out(pc),d0
		move.b d0,ic55a

do_ic2c							;fflop 15 in 2
		move.b ic18a(pc),d0
		or.b ic55a(pc),d0
		move.b d0,ic2c

do_ic13c						;fflop 16 in 1
		move.b fflop_1_out(pc),d0
		and.b fflop_6_out+1(pc),d0
		move.b d0,ic13c

do_ic88a		
		move.b fflop_15_out+1(pc),d0
		and.b fflop_12_out+1(pc),d0
		move.b d0,ic88a

do_ic2d							;fflop 16 in 2
		move.b ic79a(pc),d0
		or.b ic88a(pc),d0
		move.b d0,ic2d
		rts

print		pea (a0)
		move.w #9,-(sp)
		trap #1
		addq.l #6,sp
		rts

		dc.l 0

pin15		dc.w $0100	;high pin
pin16		dc.w $0001	;ground pin
pin17		dc.w $0001	;ground pin
pin18		dc.w $0001	;ground pin
pin19		dc.w $0001	;ground pin
pin20		dc.w $0001	;ground pin
pin21		dc.w $0001	;ground pin

pin14		dc.w 1		;input pin
fflop_1_out	dc.w 1
fflop_2_out	dc.w 1
fflop_3_out	dc.w 1
fflop_4_out	dc.w 1
fflop_5_out	dc.w 1
fflop_6_out	dc.w 1
fflop_7_out	dc.w 1
fflop_8_out	dc.w 1
fflop_9_out	dc.w 1
fflop_10_out	dc.w 1
fflop_11_out	dc.w 1
fflop_12_out	dc.w 1
fflop_13_out	dc.w 1
fflop_14_out	dc.w 1
fflop_15_out	dc.w 1
fflop_16_out	dc.w 1

ic73a		dc.b 0
ic71a		dc.b 0
ic72a		dc.b 0
ic60a		dc.b 0
ic50a		dc.b 0
ic58a		dc.b 0
ic57a		dc.b 0
ic59a		dc.b 0
ic90b		dc.b 0
ic90a		dc.b 0
ic90c		dc.b 0
ic62a		dc.b 0
ic51a		dc.b 0
icu2		dc.b 0			;fflop 10 in 1
ic68a		dc.b 0
ic49a		dc.b 0
ic45a		dc.b 0
ic48a		dc.b 0
ic85a		dc.b 0
ic74a		dc.b 0
ic29b		dc.b 0
ic13a		dc.b 0
ic13b		dc.b 0
ic18b		dc.b 0
ic1a		dc.b 0
ic18a		dc.b 0
ic79a		dc.b 0
ic85b		dc.b 0
ic82a		dc.b 0
ic3b		dc.b 0			;fflop 10 in 2
ic9a		dc.b 0
ic11a		dc.b 0
ic2a		dc.b 0			;fflop 1 in 1
ic4b		dc.b 0
ic4a		dc.b 0
icu1		dc.b 0			;fflop 1 in 2
ic77b		dc.b 0			;fflop 2 in 1
ic7a		dc.b 0
ic12c		dc.b 0			;fflop 2 in 2
ic38c		dc.b 0			;fflop 3 in 1
ic76c		dc.b 0
ic76a		dc.b 0
ic76b		dc.b 0
ic38a		dc.b 0
ic12b		dc.b 0			;fflop 3 in 2
ic1d		dc.b 0			;fflop 4 in 1
ic1c		dc.b 0			;fflop 4 in 2
ic38b		dc.b 0			;fflop 5 in 1
ic29a		dc.b 0
ic12a		dc.b 0			;fflop 5 in 2
ic11d		dc.b 0			;fflop 6 in 1
ic23a		dc.b 0
ic2b		dc.b 0			;fflop 6 in 2
ic1b		dc.b 0			;fflop 8 in 1
ic94b		dc.b 0			;fflop 8 in 2
ic35a		dc.b 0
ic11b		dc.b 0			;fflop 9 in 1
ic40c		dc.b 0
ic40a		dc.b 0
ic40b		dc.b 0
ic77a		dc.b 0
ic94d		dc.b 0			;fflop 9 in 2
ic7b		dc.b 0			;fflop 11 in 1
ic43a		dc.b 0
ic7c		dc.b 0			;fflop 11 in 2
ic11c		dc.b 0			;fflop 12 in 1
ic27b		dc.b 0
ic12d		dc.b 0			;fflop 12 in 2
ic5a		dc.b 0			;fflop 13 in 1
ic25b		dc.b 0
ic3a		dc.b 0			;fflop 13 in 2
ic7d		dc.b 0			;fflop 14 in 1
ic86a		dc.b 0
ic94c		dc.b 0			;fflop 14 in 2
ic77c		dc.b 0			;fflop 15 in 1
ic55a		dc.b 0
ic2c		dc.b 0			;fflop 15 in 2
ic13c		dc.b 0			;fflop 16 in 1
ic88a		dc.b 0
ic2d		dc.b 0			;fflop 16 in 2

	even
		dc.l 0
text
		dc.b 27,'f',27,'E'
		dc.b "Cubase Audio Falcon (CAF 2.06) - Brought to you by -=TPH=- and the Medway Boys",10,13
		dc.b "Dongle hardware reversing by Unnamed Villain, emulation crack by Zippy",10,13
		dc.b "Thanks to Evil/DHS for supplying the 2 dongles used for analysis",10,10,13
		dc.b "It took a long time, more than 6 months, but at last it's complete!",10,13,0
	even
		dc.l 0
env		dc.w 0
com		dc.w 0
filename	dc.b 'CAF_206.PRG',0
err		dc.b 10,13,'Error: ',0
nofile		dc.b ' not found!',0
	even
end		dc.l 0
