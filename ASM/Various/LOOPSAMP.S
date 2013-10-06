		 MOVE.L A7,A5
		 MOVE.L 4(A5),A5
		 MOVE.L $C(A5),D0
 		 ADD.L $14(A5),D0
		 ADD.L $1C(A5),D0
		 ADD.L #$1100,D0
		 MOVE.L A5,D1
		 ADD.L D0,D1
		 AND.L #-2,D1
		 MOVE.L D1,A7
		 MOVE.L D0,-(SP)
		 MOVE.L A5,-(SP)
		 MOVE.W D0,-(SP)
                 MOVE.W #$4A,-(SP) 
                 TRAP #1
                 ADD.L #12,SP

 		 CLR.W -(SP)      
		 MOVE.L #-1,-(SP) 
		 MOVE.L #-1,-(SP) 
 		 MOVE.W #5,-(SP)  
 		 TRAP #14
 		 ADD.L #12,SP

                 MOVE.L #59122,LENGTH
                 MOVE.L #SOUNDBUFF,D6
                 ADD.L LENGTH,D6
                 MOVE.L D6,SBUFF
                 MOVE.L #SOUNDBUFF,PLAYPOS
                 
                 MOVE.L #0,-(SP)
                 MOVE.W #$20,-(SP)
                 TRAP #1
                 ADD.L #6,SP
                 MOVE.L D0,SPSAVE

 		 MOVE.L #$31415926,$426
		 MOVE.L #RESVEC,$42A
LOOP:		 BRA LOOP

RESVEC:
 		 MOVE.B #2,$FF820A
		 LEA $D50,A7

                 MOVE.L #10,D0
SETREGS:         MOVE.B D0,$FFF8800
                 CLR.B $FFF8802
                 DBF D0,SETREGS
                 CLR.B $FFF8800
                 CLR.B $FFF8802
                 MOVE.B #7,$FFF8800
                 MOVE.B #$F8,$FFF8802
 		 MOVE.B $FFFA07,INT1
		 MOVE.B $FFFA09,INT2
		 MOVE.B #0,$FFFA07
		 MOVE.B #0,$FFFA09
                 LEA CHANEL_A(PC),A6
                 MOVE.L PLAYPOS,A3
	         MOVE.L #$FFFF8800,A5

ISR:             
                 MOVE.B (A3)+,D0
                 MOVE.L SBUFF,D6
                 CMPA.L D6,A3           
                 BLT.S OUTPUT
                 MOVE.L #SOUNDBUFF,A3

OUTPUT:          MOVE.W #45,D7
DELAY:		 DBRA D7,DELAY
		 AND.W #$FF,D0
                 MOVE.B #8,(A5)
                 MOVE.B 0(A6,D0.W),2(A5)
                 MOVE.B #9,(A5)
	         ADD.L #256,A6
                 MOVE.B 0(A6,D0.W),2(A5)
                 MOVE.B #10,(A5)
	         ADD.L #256,A6
                 MOVE.B 0(A6,D0.W),2(A5)
	         SUB.L #512,A6
                 MOVE.L A3,PLAYPOS
		 BRA ISR
                 
SLUT:		 MOVE.L SPSAVE,-(SP)
                 MOVE.W #$20,-(SP)
                 TRAP #1
                 ADD.L #6,SP
                 
	         CLR.W -(SP)
	         TRAP #1



CHANEL_A:      DC.L    $00000000,$00000000,$00000000,$00000000
               DC.L    $00010000,$00000001,$00000000,$00000001
               DC.L    $02000000,$00010000,$01020001,$00010203
               DC.L    $00010000,$00000100,$01020000,$00010203
               DC.L    $00010204,$00000001,$02000100,$00010001
               DC.L    $02030001,$00010200,$01020403,$03000102
               DC.L    $06050300,$00010001,$02000000,$01020001
               DC.L    $02000100,$01020000,$01020203,$00010204
               DC.L    $05030001,$02060503,$00010200,$01020207
               DC.L    $03030504,$04050000,$00010200,$01020001
               DC.L    $00010203,$00010202,$04000102,$04000100
               DC.L    $01020305,$03040404,$00010206,$07030304
               DC.L    $04040505,$05060600,$00010207,$0B030309
               DC.L    $04080001,$02020603,$03000001,$02020303
               DC.L    $06080404,$05070706,$06060908,$07070707
               DC.L    $0B0B0000,$00000102,$00010200,$01000100

CHANEL_B:      DC.L    $00000001,$02000102,$00010001,$02030001
               DC.L    $02020400,$01020404,$03000102,$06050303
               DC.L    $03040001,$02020703,$03030404,$05050504
               DC.L    $06060001,$02070703,$03030408,$05050504
               DC.L    $06060608,$00010202,$02030308,$04040505
               DC.L    $05040606,$09090907,$07070607,$07080808
               DC.L    $0607080A,$0A0A0909,$09000102,$02020303
               DC.L    $03040405,$05050A06,$0606060A,$07070706
               DC.L    $0A070808,$08060708,$0B0B0B09,$09090907
               DC.L    $09090B09,$09090001,$02020203,$03030404
               DC.L    $05050504,$06060606,$05070707,$060B0B08
               DC.L    $08080B07,$080B0808,$0909090B,$07090909
               DC.L    $09090909,$0909090A,$0A0A0A09,$0B0A0A0B
               DC.L    $0A090C0C,$0C0C0A0C,$0C0B0B0B,$0B0B0B0B
               DC.L    $0C0A0B0B,$0B0C0C0B,$0B0B0A0C,$0B0B0B0B
               DC.L    $0B0B0000,$01020202,$03030304,$0405050C

CHANEL_C:      DC.L    $00010202,$02030303,$04040505,$05040606
               DC.L    $06060507,$07070606,$07080808,$06070808
               DC.L    $08080909,$09090709,$09090909,$09090909
               DC.L    $09090A0A,$0A09090A,$0A0A0A09,$0A0A0A0A
               DC.L    $0A0A0A09,$0B0B0B0B,$0B0B0B0A,$0B0B0B0B
               DC.L    $0B0B0B0B,$0A0A0A0B,$0B0B0B0B,$0B0B0B0B
               DC.L    $0B0B0B0A,$0A0A0B0B,$0B0C0C0C,$0C0C0C0C
               DC.L    $0C0C0C0C,$0C0C0B0C,$0C0C0C0B,$0C0C0C0C
               DC.L    $0B0C0C0C,$0C0C0C0C,$0B0B0B0C,$0C0C0C0C
               DC.L    $0C0C0B0C,$0C0C0D0D,$0D0D0D0D,$0D0D0D0D
               DC.L    $0D0D0D0D,$0D0D0D0D,$0D0D0D0D,$0D0C0C0D
               DC.L    $0D0D0C0D,$0D0C0D0D,$0D0D0D0C,$0D0D0D0D
               DC.L    $0D0D0D0D,$0D0D0D0D,$0D0D0D0D,$0B0D0D0C
               DC.L    $0D0D0C0C,$0C0C0D0C,$0C0D0D0D,$0D0D0D0D
               DC.L    $0C0D0D0D,$0D0C0C0D,$0D0D0D0C,$0D0D0D0D
               DC.L    $0C0C0E0E,$0E0E0E0E,$0E0E0E0E,$0E0E0E0D


SPSAVE           DS.L 1
STATUS           DS.W 1
STACKST          DS.W 1
SAVESP           DS.L 1
LENGTH           DS.L 1
SBUFF            DS.L 1
PLAYPOS          DS.L 1
VSAVE	 	 DS.L 1
INT1		 DC.B 0
INT2		 DC.B 0
ISRA             EQU $FFFA00+$F
 EVEN
SOUNDBUFF	 INCBIN A:\MEGA10.SPL
                 END

 