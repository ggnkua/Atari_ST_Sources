; QED-ASMPAR 4 0006  $DSDR:Z:415,M:5
;Desert Drain V1.52   680x0er Disassembler  01.01.1998 16:52:36
;DATEI: DMASOUND.PRG   2118 Bytes
;TEXT:    942   $003AE
;DATA:    962   $003C2
;BSS:    3104  $000C20
	opt P=68000

			TEXT
			movea.l     4(SP),A5
			move.l      A5,B_B76
			move.l      $18(A5),D0
			add.l       $1C(A5),D0
			addi.l      #$100,D0
			lea         B_138E,SP
			sub.l       A5,D0
			move.l      D0,-(SP)
			move.l      A5,-(SP)
			clr.w       -(SP)
			move.w      #$4A,-(SP)
			trap        #1          ;Mshrink
			adda.w      #12,SP
			move.l      #D_3AE,D1
			move.l      #$C8,D0
			trap        #2          ;aes
			move.w      #2,D_428
			cmpi.w      #$140,B_788
			bpl.b       T_5A
			move.l      #D_690,D_66E
T_5A:      move.l      #D_406,D1
			move.l      #$C8,D0
			trap        #2          ;aes
			move.l      #D_42E,D1
			move.l      #$C8,D0
			trap        #2          ;aes
			move.w      B_918,B_772
			move.w      #4,-(SP)
			trap        #14         ;Getrez
			addq.l      #2,SP
			addq.w      #2,D0
			move.w      D0,D_5DE
			move.w      B_772,B_770
			movea.l     #D_5B2,A0
			move.l      A0,D1
			movea.l     (A0),A0
			move.w      B_770,12(A0)
			moveq       #$73,D0
			trap        #2          ;vdi
			move.w      D_5D2,B_770
			move.w      #3,B_9E0
			move.l      #D_450,D1
			move.l      #$C8,D0
			trap        #2          ;aes
			movea.l     #D_494,A0
			move.l      A0,D1
			movea.l     (A0),A0
			move.w      B_770,12(A0)
			moveq       #$73,D0
			trap        #2          ;vdi
			move.l      #D_472,D1
			move.l      #$C8,D0
			trap        #2          ;aes
			move.l      #D_4C2,D1
			move.l      #$C8,D0
			trap        #2          ;aes
			tst.w       B_918
			beq.w       T_356
			move.l      #0,B_B90
			move.l      #D_4E8,D1
			move.l      #$C8,D0
			trap        #2          ;aes
			movea.l     B_B7A(PC),A0
T_128:     moveq       #0,D7
			moveq       #0,D6
			bsr.w       T_27A
			cmp.w       #15,D6
			beq.w       T_356
			cmp.w       #14,D6
			bne.s .lb0
			bsr.w       T_154
			bra.b       T_128
.lb0:
			cmp.w       #8,D6
			bmi.b       T_128
			cmp.w       #11,D6
			bpl.b       T_128
			move d6,-(sp)
			moveq #1,d6
			moveq #1,d7
			bsr T_27A
			move (sp)+,d6
			bsr.w       T_156
			move d6,-(sp)
			moveq #1,d6
			moveq #-1,d7
			bsr T_27A
			move (sp)+,d6
			bra.b       T_128
T_154:     rts         
T_156:     clr.w       -(SP)
			move.l      #-1,-(SP)
			move.w      #$44,-(SP)
			trap        #1          ;Mxalloc
			addq.l      #8,SP
			cmp.l #-32,d0				; invalid funct
			bne.s .suite
			move.l #-1,-(sp)
			move #72,-(sp)
			trap #1
			addq.l #6,sp
.suite:			
			move.l #1501980,d1		; 2 minutes a 12KHz
			move d6,d2
			subq #8,d2
			lsl.l d2,d1					; *1, *2 ou *4
			cmp.l       d1,D0
			bmi.b       T_174
			move.l      d1,D0
T_174:     move.l      D0,B_BAA
			move.l      D0,B_BA6
			clr.w       -(SP)
			move.l      D0,-(SP)
			move.w      #$44,-(SP)
			trap        #1          ;Mxalloc
			addq.l      #8,SP
			cmp.l #-32,d0
			bne.s .suite
			move.l B_BAA,-(sp)
			move #72,-(sp)
			trap #1
			addq.l #6,sp
.suite:						
			move.l      D0,B_BA2
			subq.l      #1,D0
			add.l       D0,B_BA6
			clr.l       -(SP)
			move.w      #$20,-(SP)
			trap        #1          ;Super
			addq.l      #6,SP
			move.l      D0,B_BBA
			lea         B_BA3,A0
			move.b      (A0)+,$FFFF8903.w
			move.b      (A0)+,$FFFF8905.w
			move.b      (A0),$FFFF8907.w
			lea         B_BA7,A0
			move.b      (A0)+,$FFFF890F.w
			move.b      (A0)+,$FFFF8911.w
			move.b      (A0),$FFFF8913.w
			move.b      D6,D0
			subq.b      #7,D0
			addi.b      #-$80,D0
			move.b      D0,$FFFF8921.w
			move.b      #1,$FFFF8901.w
			move.l      $4BA.w,D0   ;_hz_200
			move.l      D0,B_BB2
T_1EA:     btst        #0,$FFFF8901.w
			bne.b       T_1EA
			move.l      $4BA.w,D0   ;_hz_200
			move.l      D0,B_BB6
			sub.l       B_BB2,D0
			move.l      D0,B_BAE
			move.l      B_BA2,-(SP)
			move.w      #$49,-(SP)
			trap        #1          ;Mfree
			addq.l      #6,SP
			move.l      B_BBA,-(SP)
			move.w      #$20,-(SP)
			trap        #1          ;Super
			addq.l      #6,SP
			clr.l       B_B90
			move.l      #D_4E8,D1
			move.l      #$C8,D0
			trap        #2          ;aes
			move.l      B_BAA,D0
			lsl.l #3,d0
			move.l d0,d1
			lsl.l #3,d1
			add.l d1,d0
			add.l d1,d1
			add.l d1,d0		; * 200
			move.l B_BAE,d1			; temps 1/200
			divu d1,d0					; freq
			lsr #1,d1					; moitie
			swap d0
			cmp d1,d0
			bmi.s .lb0					; arrondi en dessous
			clr d0
			swap d0
			addq #1,d0					; arrondi au dessus
			bra.s .lb1
.lb0:
			clr d0
			swap d0
.lb1:			
			movea.l     B_B7A,A0
			move.w      D6,D1
			subq.w      #4,D1
			muls        #$18,D1
			movea.l     12(A0,D1.l),A0
			addq.l      #5,A0
			moveq       #4,D1
T_264:     divu        #10,D0
			swap        D0
			addi.b      #$30,D0
			move.b      D0,-(A0)
			clr.w       D0
			swap        D0
			dbra        D1,T_264
			rts         
T_27A:     tst.w       D7
			bmi.w       T_33E
			move.l      D6,B_B90
			move.l      #D_4E8,D1
			move.l      #$C8,D0
			trap        #2          ;aes
			move.l      #D_50A,D1
			move.l      #$C8,D0
			trap        #2          ;aes
			clr.w       B_B7E
			move.l      #D_52C,D1
			move.l      #$C8,D0
			trap        #2          ;aes
			move.l      #7,B_B84
			move.l      #D_590,D1
			move.l      #$C8,D0
			trap        #2          ;aes
			tst.w       D7
			bne.w       T_354
			clr.w       D_428
			move.l      #D_406,D1
			move.l      #$C8,D0
			trap        #2          ;aes
			movea.l     #D_494,A0
			move.l      A0,D1
			movea.l     (A0),A0
			move.w      B_770,12(A0)
			moveq       #$73,D0
			trap        #2          ;vdi
			move.l      #D_56C,D1
			move.l      #$C8,D0
			trap        #2          ;aes
			move.w      B_918,D6
			andi.w      #$7FFF,D6
			movea.l     B_B7A,A0
			move.w      D6,D0
			muls        #$18,D0
			bclr        #0,11(A0,D0.w)
			movea.l     #D_642,A0
			move.l      A0,D1
			movea.l     (A0),A0
			move.w      B_770,12(A0)
			moveq       #$73,D0
			trap        #2          ;vdi
T_33E:     move.w      #3,B_B7E
			move.l      #D_52C,D1
			move.l      #$C8,D0
			trap        #2          ;aes
T_354:     rts         
T_356:     movea.l     #D_494,A0
			move.l      A0,D1
			movea.l     (A0),A0
			move.w      B_770,12(A0)
			moveq       #$73,D0
			trap        #2          ;vdi
			movea.l     #D_616,A0
			move.l      A0,D1
			movea.l     (A0),A0
			move.w      B_770,12(A0)
			moveq       #$73,D0
			trap        #2          ;vdi
			move.w      #2,B_9E0
			move.l      #D_450,D1
			move.l      #$C8,D0
			trap        #2          ;aes
			move.l      #D_5F4,D1
			move.l      #$C8,D0
			trap        #2          ;aes
			move.w      #0,-(SP)
			trap        #1          ;Pterm0
			addq.l      #2,SP
			DATA
D_3AE:     dc.l        D_3C6
			dc.l        B_788
			dc.l        B_774
			dc.l        D_3D0
			dc.l        B_774
			dc.l        B_774
D_3C6:     dc.b        $0,$A,$0,$0,$0,$1,$0,$0,$0,$0
D_3D0:     dc.b        $0,$0
			dc.l        D_3EA
			dc.l        B_788
			dc.l        D_3F4
			dc.l        B_774
			dc.l        B_774
			dc.l        B_774
D_3EA:     dc.b        $0,$33,$0,$9,$0,$0,$0,$1,$0,$0
D_3F4:     dc.b        $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$2
			dc.b        $80,$1,$E0
D_406:     dc.l        D_41E
			dc.l        B_788
			dc.l        D_428
			dc.l        B_918
			dc.l        D_42A
			dc.l        B_774
D_41E:     dc.b        $0,$4E,$0,$1,$0,$1,$0,$1,$0,$0
D_428:     dc.b        $0,$0
D_42A:     dc.b        $0,$0,$0,$0
D_42E:     dc.l        D_446
			dc.l        B_788
			dc.l        B_774
			dc.l        B_918
			dc.l        B_774
			dc.l        B_774
D_446:     dc.b        $0,$4D,$0,$0,$0,$5,$0,$0,$0,$0
D_450:     dc.l        D_468
			dc.l        B_788
			dc.l        B_9E0
			dc.l        B_774
			dc.l        B_774
			dc.l        B_774
D_468:     dc.b        $0,$6B,$0,$1,$0,$1,$0,$0,$0,$0
D_472:     dc.l        D_48A
			dc.l        B_788
			dc.l        B_774
			dc.l        B_774
			dc.l        D_4E4
			dc.l        B_774
D_48A:     dc.b        $0,$7C,$0,$0,$0,$1,$0,$1,$0,$0
D_494:     dc.l        D_4A8
			dc.l        D_4C0
			dc.l        B_774
			dc.l        B_774
			dc.l        B_774
D_4A8:     dc.b        $0,$7A,$0,$0,$0,$0,$0,$1,$0,$0,$0,$0,$0,$0,$0
			dc.b        $0,$0,$0,$0,$0,$0,$0,$0,$0
D_4C0:     dc.b        $0,$0
D_4C2:     dc.l        D_4DA
			dc.l        B_788
			dc.l        B_774
			dc.l        B_918
			dc.l        D_4E4
			dc.l        B_774
D_4DA:     dc.b        $0,$6E,$0,$0,$0,$1,$0,$1,$0,$0
D_4E4:     dc.l        D_69A
D_4E8:     dc.l        D_500
			dc.l        B_788
			dc.l        B_B90
			dc.l        B_774
			dc.l        B_774
			dc.l        B_B7A
D_500:     dc.b        $0,$70,$0,$2,$0,$1,$0,$0,$0,$1
D_50A:     dc.l        D_522
			dc.l        B_788
			dc.l        B_774
			dc.l        B_B86
			dc.l        B_B7A
			dc.l        B_774
D_522:     dc.b        $0,$36,$0,$0,$0,$5,$0,$1,$0,$0
D_52C:     dc.l        D_3EA
			dc.l        B_788
			dc.l        B_B7E
			dc.l        B_774
			dc.l        B_774
			dc.l        B_774
			dc.l        D_55C
			dc.l        B_788
			dc.l        D_566
			dc.l        B_918
			dc.l        B_774
			dc.l        B_774
D_55C:     dc.b        $0,$15,$0,$3,$0,$5,$0,$0,$0,$0
D_566:     dc.b        $0,$1,$0,$1,$0,$0
D_56C:     dc.l        D_584
			dc.l        B_788
			dc.l        D_58E
			dc.l        B_918
			dc.l        B_B7A
			dc.l        B_774
D_584:     dc.b        $0,$32,$0,$1,$0,$1,$0,$1,$0,$0
D_58E:     dc.b        $0,$0
D_590:     dc.l        D_5A8
			dc.l        B_788
			dc.l        B_B84
			dc.l        B_774
			dc.l        B_B7A
			dc.l        B_774
D_5A8:     dc.b        $0,$2A,$0,$6,$0,$1,$0,$1,$0,$0
D_5B2:     dc.l        D_5C6
			dc.l        D_5DE
			dc.l        B_774
			dc.l        B_9E6
			dc.l        B_AAE
D_5C6:     dc.b        $0,$64,$0,$0,$0,$0,$0,$B,$0,$0,$0,$0
D_5D2:     dc.b        $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
D_5DE:     dc.b        $0,$2,$0,$1,$0,$1,$0,$1,$0,$1,$0,$1,$0,$1,$0
			dc.b        $0,$0,$1,$0,$0,$0,$2
D_5F4:     dc.l        D_60C
			dc.l        B_788
			dc.l        B_774
			dc.l        B_918
			dc.l        B_774
			dc.l        B_774
D_60C:     dc.b        $0,$13,$0,$0,$0,$1,$0,$0,$0,$0
D_616:     dc.l        D_62A
			dc.l        B_774
			dc.l        B_774
			dc.l        B_774
			dc.l        B_774
D_62A:     dc.b        $0,$65,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
			dc.b        $0,$0,$0,$0,$0,$0,$0,$0,$0
D_642:     dc.l        D_656
			dc.l        B_774
			dc.l        B_774
			dc.l        B_774
			dc.l        B_774
D_656:     dc.b        $0,$7B,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
			dc.b        $0,$0,$0,$0,$0,$0,$0,$0,$0
D_66E:     dc.l        D_686
			dc.l        B_788
			dc.l        B_774
			dc.l        B_918
			dc.l        B_B96
			dc.l        B_774
D_686:     dc.b        $0,$5B,$0,$0,$0,$2,$0,$3,$0,$0
D_690:     dc.b        $0,$5A,$0,$0,$0,$2,$0,$2,$0,$0
D_69A:     dc.b        $44,$4D,$41,$53,$4F,$55,$4E,$44,$2E,$52,$53
			dc.b        $43,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
			dc.b        $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
			dc.b        $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
			dc.b        $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
			dc.b        $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
			dc.b        $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
			dc.b        $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
			dc.b        $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
			dc.b        $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
			dc.b        $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
			dc.b        $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
			dc.b        $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
			dc.b        $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
			dc.b        $0,$0,$0,$0,$0,$0,$0,$0
			BSS
B_770:     ds.w        1           ;=2
B_772:     ds.w        1           ;=2
B_774:     ds.l        5           ;=20
B_788:     ds.l        100         ;=400
B_918:     ds.l        50          ;=200
B_9E0:     ds.w        3           ;=6
B_9E6:     ds.l        50          ;=200
B_AAE:     ds.l        50          ;=200
B_B76:     ds.l        1           ;=4
B_B7A:     ds.l        1           ;=4
B_B7E:     ds.w        3           ;=6
B_B84:     ds.w        1           ;=2
B_B86:     ds.w        5           ;=10
B_B90:     ds.w        3           ;=6
B_B96:     ds.l        3           ;=12
B_BA2:     ds.b        1           ;=1
B_BA3:     ds.b        3           ;=3
B_BA6:     ds.b        1           ;=1
B_BA7:     ds.b        3           ;=3
B_BAA:     ds.l        1           ;=4
B_BAE:     ds.l        1           ;=4
B_BB2:     ds.l        1           ;=4
B_BB6:     ds.l        1           ;=4
B_BBA:     ds.l        501         ;=2004
B_138E:    ds.w        1           ;=2
			END
