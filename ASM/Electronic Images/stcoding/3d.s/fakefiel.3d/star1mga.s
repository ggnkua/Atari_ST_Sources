;-----------------------------------------------------------------------;
; 'Wraparound' Starfield. (a sort of fake 3d starfield using modulos..)	;
; Programmed by Griff of Electronic Images September 1991.		;
; Very Fast Table Version (no multiplies so could be used in fullscreen);
;-----------------------------------------------------------------------;

demo		EQU 0			; gem/disk
timing		EQU 1			; timing bar flag

no_strs		EQU 1024

letsgo
		IFEQ demo
		CLR -(SP)
		PEA -1.W
		PEA -1.W
		MOVE #5,-(SP)
		TRAP #14		; lowres
		LEA 12(SP),SP
		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1			; supervisor
		ADDQ.L #6,SP	
		ENDC

		MOVE #$2700,SR
		LEA stack,SP	
		BSR Initscreens
		BSR Random_gen
		BSR makeperstab
		BSR gen_masks
		BSR Init_StarSeq
		BSR set_ints
		MOVEM.L $FFFF8240.W,D0-D7
		MOVEM.L D0-D7,old_cols
		MOVEM.L colours(pc),D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		MOVE #$2300,SR
		BSR wait_vbl

* This is the main program loop

Star_frame	BSR Swap_Screens
		IFNE timing
		MOVE.W #$300,$FFFF8240.W
		ENDC
		BSR wait_vbl
		IFNE timing
		MOVE.W #$000,$FFFF8240.W
		ENDC
		BSR clear_stars	
		BSR Plot_stars	

starsd		CMP.B #$39,$FFFFFC02.W
		BNE Star_frame		

Exit		MOVEM.L old_cols(pc),D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		BSR rest_ints
		CLR -(SP)
		TRAP #1			

; Initialisation interrupts (mfp etc) and various vectors.

set_ints	MOVE.W SR,-(SP)
		MOVE.W #$2700,SR
		LEA old_stuff(pc),A0
		MOVE.L $70.W,(A0)+
		MOVE.L $120.W,(A0)+
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+
		MOVE.B $FFFFFA17.W,(A0)+
		MOVE.B $FFFFFA1B.W,(A0)+
		MOVE.B $FFFFFA21.W,(A0)+
		LEA my_vbl(pc),a1
		MOVE.L a1,$70.w
		MOVE.B #0,$FFFFFA07.W
		MOVE.B #0,$FFFFFA09.W
		MOVE.B #0,$FFFFFA13.W
		MOVE.B #0,$FFFFFA15.W
		BCLR.B #3,$FFFFFA17.W
		BSR flush
		MOVE.B #$12,$FFFFFC02.W
		MOVE.W (SP)+,SR
		RTS

; Restore previous(gem) interrupts (mfp etc) and various vectors.

rest_ints	MOVE.W SR,-(SP)
		MOVE.W #$2700,SR
		LEA old_stuff(pc),A0
		MOVE.L (A0)+,$70.W
		MOVE.L (A0)+,$120.W
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W
		MOVE.B (A0)+,$FFFFFA17.W
		MOVE.B (A0)+,$FFFFFA1B.W
		MOVE.B (A0)+,$FFFFFA21.W
		BSR flush
		MOVE.B #$8,$FFFFFC02.W
		MOVE.W (SP)+,SR
		RTS

; Flush keyboard Buffer

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S .flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S flush
.flok		RTS

old_stuff	DS.L 16
old_cols	DS.W 16

; Little old vbl.

my_vbl		ADDQ #1,vbl_timer
		RTE

; Swap screens and set h/ware reg.

Swap_Screens	LEA log_base(PC),A0
		MOVE.L (A0)+,D0
		MOVE.L (A0)+,D1
		NOT.W (A0)			; switch screens
		MOVE.L D0,-(A0)
		MOVE.L D1,-(A0)
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W		; set hardware...
		RTS

; Wait for one vbl..

wait_vbl	MOVE vbl_timer(PC),D0
.wait_vbl	CMP vbl_timer(PC),D0		
		BEQ.S .wait_vbl
		RTS


; Allocate space for screens and clear them + make standard *160 table.

Initscreens	lea log_base(pc),a1
		move.l #screens+256,d0
		clr.b d0
		move.l d0,(a1)+
		add.l #42240,d0
		move.l d0,(a1)+
		move.l log_base(pc),a0
		bsr clear_screen
		move.l phy_base(pc),a0
		bsr clear_screen
		move.l log_base(pc),d0
		lsr #8,d0
		move.l d0,$ffff8200.w
		rts

; Clear screen ->A0

clear_screen	moveq #0,d0
		move #1999,d1
.cls		move.l d0,(a0)+
		move.l d0,(a0)+
		move.l d0,(a0)+
		move.l d0,(a0)+
		dbf d1,.cls
		rts

; Routines for Initialision of Starfield.

makeperstab	LEA humungus_table,A1
		LEA mul_160+(384),A3
		MOVE.L #(350*32767/512)*384,D7
		MOVE #350+$200,D1
		MOVE.W #$100-1,D2
.lp		MOVE.L D7,D6
		DIVS D1,D6
		MOVE.W #-256,D4
		MOVE.W #512-1,D3
.lp2		MOVE.W D4,D5
		MULS D6,D5
		ADD.L D5,D5
		SWAP D5
		ADD.W D5,D5
		MOVE.W (A3,D5),(A1)+
		ADD.W D5,D5
		MOVE.W D5,(A1)+
		ADDQ #1,D4
		DBF D3,.lp2
		SUBQ #2,D1
		DBF D2,.lp
		RTS

Random_gen	LEA stars,A3
		LEA (no_strs*4)(A3),A4
		MOVE #no_strs-1,D4
		MOVE.W #$2354,D0		;seed
.f_rand_x	BSR Rand
		MOVE.W D0,D1
		AND #$7FC,D1
		MOVE D1,(A3)+
.f_rand_y	BSR Rand
		MOVE.W D0,D1
		AND #$7FC,D1
		MOVE D1,(A3)+
		MOVE.L -4(A3),(A4)+
		DBF D4,.f_rand_x
Mul_160_crt	LEA mul_160,A0			;create *160 table
		MOVEQ #32-1,D0
.lp1		MOVE.W #-160,(A0)+
		DBF D0,.lp1
		MOVE.L #$A000,D2
		MOVEQ #0,D0
		MOVE #320-1,D1
.mul_lp		ADD.L D2,D0
		MOVE.L D0,D3
		SWAP D3
		MULU #160,D3
		MOVE.W D3,(A0)+
		DBF D1,.mul_lp
		MOVEQ #32-1,D0
.lp2		MOVE.W #32160,(A0)+
		DBF D0,.lp2
		RTS

gen_masks 	LEA plot_masks,A0
		MOVEQ #16-1,D0
.lp1		CLR.L (A0)+
		DBF D0,.lp1
		MOVEQ #0,D0
		MOVE.L #$E8BA,D2
		MOVE #352-1,D7
.masklp		
		ADD.L D2,D0
		MOVE.L D0,D3
		SWAP D3
		MOVE.W D3,D4
		CLR D5
		NOT D3
		AND #15,D3
		BSET D3,D5
		MOVE.W D5,(A0)+
		LSR #1,D4
		AND.W #$FFF8,D4
		MOVE.W D4,(A0)+
		DBF D7,.masklp
		
		MOVEQ #16-1,D0
.lp2		CLR.L (A0)+
		DBF D0,.lp2
		RTS

Rand		ADD D4,D0
		ADD.W #$573,D0
		MULU #$45F7,D0
		ROR.W #6,D0
		RTS

log_base 	DC.L 0
phy_base 	DC.L 0
switch		DS.W 1
vbl_timer	DS.W 1
colours		DC.W $000,$222,$444,$444,$666,$666,$666,$666
		DC.W $000,$000,$000,$000,$000,$000,$000,$000


clear_stars	MOVE.L log_base(pc),A0		; screen base
		MOVEQ #0,D0
		TST switch
		BNE old_pos1
old_pos2	
		REPT 84*4
		MOVE.W D0,2(A0)
		ENDR
		ADDQ.W #2,A0
		REPT 86*4
		MOVE.W D0,2(A0)
		ENDR
		ADDQ.W #2,A0
		REPT 86*4
		MOVE.W D0,2(A0)
		ENDR
		RTS
old_pos1	
		REPT 84*4
		MOVE.W D0,2(A0)
		ENDR
		ADDQ.W #2,A0
		REPT 86*4
		MOVE.W D0,2(A0)
		ENDR
		ADDQ.W #2,A0
		REPT 86*4
		MOVE.W D0,2(A0)
		ENDR
		RTS


Init_StarSeq	LEA starfield_struc(PC),A0
		MOVE.L #star_seq,starseq_ptr(A0)
		MOVE.L #star_seq,starresseq_ptr(A0)
		MOVE.W #1,star_seqtimer(A0)
		RTS

star_seq	DC.W 128,0,0,56,0,80
		DC.W 256,4,4,56,0,96
		DC.W 256,4,4,0,56,96
		DC.W 256,4,4,56,56,96
		DC.W -1
		
; Do Starfield sequence and plot them.

		RSRESET
star_seqtimer	RS.W 1
starseq_ptr	RS.L 1
starresseq_ptr	RS.L 1
xyz		RS.B 0
x		RS.W 1
y		RS.W 1
z		RS.W 1
xyzang		RS.B 0
xang		RS.W 1
zang		RS.W 1
xspeed		RS.W 1
yspeed		RS.W 1
zspeed		RS.W 1
xang_inc	RS.W 1
zang_inc	RS.W 1
star_strucsize	RS.B 1

starfield_struc	DS.B star_strucsize

Plot_stars	LEA starfield_struc(PC),A6
		SUBQ #1,star_seqtimer(A6)	; next sequence?
		BNE.S .nonew
		MOVE.L starseq_ptr(A6),A0	; ok...
		MOVE.W (A0)+,star_seqtimer(A6)
		MOVE.W (A0)+,xang_inc(A6)
		MOVE.W (A0)+,zang_inc(A6)
		MOVE.W (A0)+,xspeed(A6)		; read next seq
		MOVE.W (A0)+,yspeed(A6)		; vals
		MOVE.W (A0)+,zspeed(A6)
		CMP.W #-1,(A0)			; end of seq?
		BNE.S .notendseq
		MOVE.L starresseq_ptr(A6),A0	; yes then restart
.notendseq	MOVE.L A0,starseq_ptr(A6)	; store seq ptr
.nonew		MOVEM.W xyzang(A6),D0-D1
		ADD xang_inc(A6),D0
		ADD zang_inc(A6),D1
		AND.W #$7FE,D0
		AND.W #$7FE,D1
		MOVEM.W D0-D1,xyzang(A6)
		LEA trig_tab,A1
		LEA $200(A1),A2
		MOVE.W (A2,D1),D2
		MOVE.W (A1,D0),D1
		MOVE.W (A1,D0),D0
		MULS xspeed(A6),D0
		MULS yspeed(A6),D1
		MULS zspeed(A6),D2
		ADD.L D0,D0
		SWAP D0
		ADD.L D1,D1		
		SWAP D1
		ADD.L D2,D2
		SWAP D2
		MOVEM.W xyz(A6),D3-D5
		ADD D0,D3
		ADD D1,D4
		ADD D2,D5
		AND.W #$FFC,D5
		MOVEM.W D3-D5,xyz(A6)

		MOVE.L log_base(pc),A0		; screen base
		LEA stars,A1			; star co-ords
		ADD D5,A1
		LEA old_pos1(PC),A3		
		LEA old_pos2(PC),A4
		MOVE.W switch(PC),D0
		BNE .cse2
.cse1		MOVE.L A4,A3
.cse2		LEA plot_masks+(384*2),A5	; point masks
		LEA humungus_table,A2
		MOVE.W #$7FC,D7
		MOVE.L (A3),D2

plot1		MACRO
		MOVE.W (A1)+,D0
		MOVE.W (A1)+,D1
		ADD D3,D0
		ADD D4,D1
		AND.W D7,D0
		AND.W D7,D1
		MOVE.W 2(A2,D0),D0
		MOVE.W (A2,D1),D2
		MOVE.L (A5,D0),D0
		ADD D0,D2
		MOVE.L D2,(A3)+			; store pos
		SWAP D0
		OR D0,(A0,D2)

		MOVE.W (A1)+,D0
		MOVE.W (A1)+,D1
		ADD D3,D0
		ADD D4,D1
		AND.W D7,D0
		AND.W D7,D1
		MOVE.W 2(A2,D0),D0
		MOVE.W (A2,D1),D2
		MOVE.L (A5,D0),D0
		ADD D0,D2
		MOVE.L D2,(A3)+			; store pos
		SWAP D0
		OR D0,(A0,D2)

		MOVE.W (A1)+,D0
		MOVE.W (A1)+,D1
		ADD D3,D0
		ADD D4,D1
		AND.W D7,D0
		AND.W D7,D1
		MOVE.W 2(A2,D0),D0
		MOVE.W (A2,D1),D2
		MOVE.L (A5,D0),D0
		ADD D0,D2
		MOVE.L D2,(A3)+			; store pos
		SWAP D0
		OR D0,(A0,D2)

		MOVE.W (A1)+,D0
		MOVE.W (A1)+,D1
		ADD D3,D0
		ADD D4,D1
		AND.W D7,D0
		AND.W D7,D1
		MOVE.W 2(A2,D0),D0
		MOVE.W (A2,D1),D2
		MOVE.L (A5,D0),D0
		ADD D0,D2
		MOVE.L D2,(A3)+			; store pos
		SWAP D0
		OR D0,(A0,D2)

		LEA 2048(A2),A2
		ENDM

		REPT 84
		plot1 0
		ENDR
		ADDQ.L #2,A0
		ADDQ.L #2,A3
		REPT 86
		plot1
		ENDR
		ADDQ.L #2,A0
		ADDQ.L #2,A3
		REPT 86
		plot1
		ENDR
		RTS

trig_tab	dc.w	$0000,$00C9,$0192,$025B,$0324,$03ED,$04B6,$057E 
		dc.w	$0647,$0710,$07D9,$08A1,$096A,$0A32,$0AFB,$0BC3 
		dc.w	$0C8B,$0D53,$0E1B,$0EE3,$0FAB,$1072,$1139,$1200 
		dc.w	$12C7,$138E,$1455,$151B,$15E1,$16A7,$176D,$1833 
		dc.w	$18F8,$19BD,$1A82,$1B46,$1C0B,$1CCF,$1D93,$1E56 
		dc.w	$1F19,$1FDC,$209F,$2161,$2223,$22E4,$23A6,$2467 
		dc.w	$2527,$25E7,$26A7,$2767,$2826,$28E5,$29A3,$2A61 
		dc.w	$2B1E,$2BDB,$2C98,$2D54,$2E10,$2ECC,$2F86,$3041 
		dc.w	$30FB,$31B4,$326D,$3326,$33DE,$3496,$354D,$3603 
		dc.w	$36B9,$376F,$3824,$38D8,$398C,$3A3F,$3AF2,$3BA4 
		dc.w	$3C56,$3D07,$3DB7,$3E67,$3F16,$3FC5,$4073,$4120 
		dc.w	$41CD,$4279,$4325,$43D0,$447A,$4523,$45CC,$4674 
		dc.w	$471C,$47C3,$4869,$490E,$49B3,$4A57,$4AFA,$4B9D 
		dc.w	$4C3F,$4CE0,$4D80,$4E20,$4EBF,$4F5D,$4FFA,$5097 
		dc.w	$5133,$51CE,$5268,$5301,$539A,$5432,$54C9,$555F 
		dc.w	$55F4,$5689,$571D,$57B0,$5842,$58D3,$5963,$59F3 
		dc.w	$5A81,$5B0F,$5B9C,$5C28,$5CB3,$5D3D,$5DC6,$5E4F 
		dc.w	$5ED6,$5F5D,$5FE2,$6067,$60EB,$616E,$61F0,$6271 
		dc.w	$62F1,$6370,$63EE,$646B,$64E7,$6562,$65DD,$6656 
		dc.w	$66CE,$6745,$67BC,$6831,$68A5,$6919,$698B,$69FC 
		dc.w	$6A6C,$6ADB,$6B4A,$6BB7,$6C23,$6C8E,$6CF8,$6D61 
		dc.w	$6DC9,$6E30,$6E95,$6EFA,$6F5E,$6FC0,$7022,$7082 
		dc.w	$70E1,$7140,$719D,$71F9,$7254,$72AE,$7306,$735E 
		dc.w	$73B5,$740A,$745E,$74B1,$7503,$7554,$75A4,$75F3 
		dc.w	$7640,$768D,$76D8,$7722,$776B,$77B3,$77F9,$783F 
		dc.w	$7883,$78C6,$7908,$7949,$7989,$79C7,$7A04,$7A41 
		dc.w	$7A7C,$7AB5,$7AEE,$7B25,$7B5C,$7B91,$7BC4,$7BF7 
		dc.w	$7C29,$7C59,$7C88,$7CB6,$7CE2,$7D0E,$7D38,$7D61 
		dc.w	$7D89,$7DB0,$7DD5,$7DF9,$7E1C,$7E3E,$7E5E,$7E7E 
		dc.w	$7E9C,$7EB9,$7ED4,$7EEF,$7F08,$7F20,$7F37,$7F4C 
		dc.w	$7F61,$7F74,$7F86,$7F96,$7FA6,$7FB4,$7FC1,$7FCD 
		dc.w	$7FD7,$7FE0,$7FE8,$7FEF,$7FF5,$7FF9,$7FFC,$7FFE 
		dc.w	$7FFF,$7FFE,$7FFC,$7FF9,$7FF5,$7FEF,$7FE8,$7FE0 
		dc.w	$7FD7,$7FCD,$7FC1,$7FB4,$7FA6,$7F96,$7F86,$7F74 
		dc.w	$7F61,$7F4C,$7F37,$7F20,$7F08,$7EEF,$7ED4,$7EB9 
		dc.w	$7E9C,$7E7E,$7E5E,$7E3E,$7E1C,$7DF9,$7DD5,$7DB0 
		dc.w	$7D89,$7D61,$7D38,$7D0E,$7CE2,$7CB6,$7C88,$7C59 
		dc.w	$7C29,$7BF7,$7BC4,$7B91,$7B5C,$7B25,$7AEE,$7AB5 
		dc.w	$7A7C,$7A41,$7A04,$79C7,$7989,$7949,$7908,$78C6 
		dc.w	$7883,$783F,$77F9,$77B3,$776B,$7722,$76D8,$768D 
		dc.w	$7640,$75F3,$75A4,$7554,$7503,$74B1,$745E,$740A 
		dc.w	$73B5,$735E,$7306,$72AE,$7254,$71F9,$719D,$7140 
		dc.w	$70E1,$7082,$7022,$6FC0,$6F5E,$6EFA,$6E95,$6E30 
		dc.w	$6DC9,$6D61,$6CF8,$6C8E,$6C23,$6BB7,$6B4A,$6ADB 
		dc.w	$6A6C,$69FC,$698B,$6919,$68A5,$6831,$67BC,$6745 
		dc.w	$66CE,$6656,$65DD,$6562,$64E7,$646B,$63EE,$6370 
		dc.w	$62F1,$6271,$61F0,$616E,$60EB,$6067,$5FE2,$5F5D 
		dc.w	$5ED6,$5E4F,$5DC6,$5D3D,$5CB3,$5C28,$5B9C,$5B0F 
		dc.w	$5A81,$59F3,$5963,$58D3,$5842,$57B0,$571D,$5689 
		dc.w	$55F4,$555F,$54C9,$5432,$539A,$5301,$5268,$51CE 
		dc.w	$5133,$5097,$4FFA,$4F5D,$4EBF,$4E20,$4D80,$4CE0 
		dc.w	$4C3F,$4B9D,$4AFA,$4A57,$49B3,$490E,$4869,$47C3 
		dc.w	$471C,$4674,$45CC,$4523,$447A,$43D0,$4325,$4279 
		dc.w	$41CD,$4120,$4073,$3FC5,$3F16,$3E67,$3DB7,$3D07 
		dc.w	$3C56,$3BA4,$3AF2,$3A3F,$398C,$38D8,$3824,$376F 
		dc.w	$36B9,$3603,$354D,$3496,$33DE,$3326,$326D,$31B4 
		dc.w	$30FB,$3041,$2F86,$2ECC,$2E10,$2D54,$2C98,$2BDB 
		dc.w	$2B1E,$2A61,$29A3,$28E5,$2826,$2767,$26A7,$25E7 
		dc.w	$2527,$2467,$23A6,$22E4,$2223,$2161,$209F,$1FDC 
		dc.w	$1F19,$1E56,$1D93,$1CCF,$1C0B,$1B46,$1A82,$19BD 
		dc.w	$18F8,$1833,$176D,$16A7,$15E1,$151B,$1455,$138E 
		dc.w	$12C7,$1200,$1139,$1072,$0FAB,$0EE3,$0E1B,$0D53 
		dc.w	$0C8B,$0BC3,$0AFB,$0A32,$096A,$08A1,$07D9,$0710 
		dc.w	$0647,$057E,$04B6,$03ED,$0324,$025B,$0192,$00C9 
		dc.w	$0000,$FF37,$FE6E,$FDA5,$FCDC,$FC13,$FB4A,$FA82 
		dc.w	$F9B9,$F8F0,$F827,$F75F,$F696,$F5CE,$F505,$F43D 
		dc.w	$F375,$F2AD,$F1E5,$F11D,$F055,$EF8E,$EEC7,$EE00 
		dc.w	$ED39,$EC72,$EBAB,$EAE5,$EA1F,$E959,$E893,$E7CD 
		dc.w	$E708,$E643,$E57E,$E4BA,$E3F5,$E331,$E26D,$E1AA 
		dc.w	$E0E7,$E024,$DF61,$DE9F,$DDDD,$DD1C,$DC5A,$DB99 
		dc.w	$DAD9,$DA19,$D959,$D899,$D7DA,$D71B,$D65D,$D59F 
		dc.w	$D4E2,$D425,$D368,$D2AC,$D1F0,$D134,$D07A,$CFBF 
		dc.w	$CF05,$CE4C,$CD93,$CCDA,$CC22,$CB6A,$CAB3,$C9FD 
		dc.w	$C947,$C891,$C7DC,$C728,$C674,$C5C1,$C50E,$C45C 
		dc.w	$C3AA,$C2F9,$C249,$C199,$C0EA,$C03B,$BF8D,$BEE0 
		dc.w	$BE33,$BD87,$BCDB,$BC30,$BB86,$BADD,$BA34,$B98C 
		dc.w	$B8E4,$B83D,$B797,$B6F2,$B64D,$B5A9,$B506,$B463 
		dc.w	$B3C1,$B320,$B280,$B1E0,$B141,$B0A3,$B006,$AF69 
		dc.w	$AECD,$AE32,$AD98,$ACFF,$AC66,$ABCE,$AB37,$AAA1 
		dc.w	$AA0C,$A977,$A8E3,$A850,$A7BE,$A72D,$A69D,$A60D 
		dc.w	$A57F,$A4F1,$A464,$A3D8,$A34D,$A2C3,$A23A,$A1B1 
		dc.w	$A12A,$A0A3,$A01E,$9F99,$9F15,$9E92,$9E10,$9D8F 
		dc.w	$9D0F,$9C90,$9C12,$9B95,$9B19,$9A9E,$9A23,$99AA 
		dc.w	$9932,$98BB,$9844,$97CF,$975B,$96E7,$9675,$9604 
		dc.w	$9594,$9525,$94B6,$9449,$93DD,$9372,$9308,$929F 
		dc.w	$9237,$91D0,$916B,$9106,$90A2,$9040,$8FDE,$8F7E 
		dc.w	$8F1F,$8EC0,$8E63,$8E07,$8DAC,$8D52,$8CFA,$8CA2 
		dc.w	$8C4B,$8BF6,$8BA2,$8B4F,$8AFD,$8AAC,$8A5C,$8A0D 
		dc.w	$89C0,$8973,$8928,$88DE,$8895,$884D,$8807,$87C1 
		dc.w	$877D,$873A,$86F8,$86B7,$8677,$8639,$85FC,$85BF 
		dc.w	$8584,$854B,$8512,$84DB,$84A4,$846F,$843C,$8409 
		dc.w	$83D7,$83A7,$8378,$834A,$831E,$82F2,$82C8,$829F 
		dc.w	$8277,$8250,$822B,$8207,$81E4,$81C2,$81A2,$8182 
		dc.w	$8164,$8147,$812C,$8111,$80F8,$80E0,$80C9,$80B4 
		dc.w	$809F,$808C,$807A,$806A,$805A,$804C,$803F,$8033 
		dc.w	$8029,$8020,$8018,$8011,$800B,$8007,$8004,$8002 
		dc.w	$8001,$8002,$8004,$8007,$800B,$8011,$8018,$8020 
		dc.w	$8029,$8033,$803F,$804C,$805A,$806A,$807A,$808C 
		dc.w	$809F,$80B4,$80C9,$80E0,$80F8,$8111,$812C,$8147 
		dc.w	$8164,$8182,$81A2,$81C2,$81E4,$8207,$822B,$8250 
		dc.w	$8277,$829F,$82C8,$82F2,$831E,$834A,$8378,$83A7 
		dc.w	$83D7,$8409,$843C,$846F,$84A4,$84DB,$8512,$854B 
		dc.w	$8584,$85BF,$85FC,$8639,$8677,$86B7,$86F8,$873A 
		dc.w	$877D,$87C1,$8807,$884D,$8895,$88DE,$8928,$8973 
		dc.w	$89C0,$8A0D,$8A5C,$8AAC,$8AFD,$8B4F,$8BA2,$8BF6 
		dc.w	$8C4B,$8CA2,$8CFA,$8D52,$8DAC,$8E07,$8E63,$8EC0 
		dc.w	$8F1F,$8F7E,$8FDE,$9040,$90A2,$9106,$916B,$91D0 
		dc.w	$9237,$929F,$9308,$9372,$93DD,$9449,$94B6,$9525 
		dc.w	$9594,$9604,$9675,$96E7,$975B,$97CF,$9844,$98BB 
		dc.w	$9932,$99AA,$9A23,$9A9E,$9B19,$9B95,$9C12,$9C90 
		dc.w	$9D0F,$9D8F,$9E10,$9E92,$9F15,$9F99,$A01E,$A0A3 
		dc.w	$A12A,$A1B1,$A23A,$A2C3,$A34D,$A3D8,$A464,$A4F1 
		dc.w	$A57F,$A60D,$A69D,$A72D,$A7BE,$A850,$A8E3,$A977 
		dc.w	$AA0C,$AAA1,$AB37,$ABCE,$AC66,$ACFF,$AD98,$AE32 
		dc.w	$AECD,$AF69,$B006,$B0A3,$B141,$B1E0,$B280,$B320 
		dc.w	$B3C1,$B463,$B506,$B5A9,$B64D,$B6F2,$B797,$B83D 
		dc.w	$B8E4,$B98C,$BA34,$BADD,$BB86,$BC30,$BCDB,$BD87 
		dc.w	$BE33,$BEE0,$BF8D,$C03B,$C0EA,$C199,$C249,$C2F9 
		dc.w	$C3AA,$C45C,$C50E,$C5C1,$C674,$C728,$C7DC,$C891 
		dc.w	$C947,$C9FD,$CAB3,$CB6A,$CC22,$CCDA,$CD93,$CE4C 
		dc.w	$CF05,$CFBF,$D07A,$D134,$D1F0,$D2AC,$D368,$D425 
		dc.w	$D4E2,$D59F,$D65D,$D71B,$D7DA,$D899,$D959,$DA19 
		dc.w	$DAD9,$DB99,$DC5A,$DD1C,$DDDD,$DE9F,$DF61,$E024 
		dc.w	$E0E7,$E1AA,$E26D,$E331,$E3F5,$E4BA,$E57E,$E643 
		dc.w	$E708,$E7CD,$E893,$E959,$EA1F,$EAE5,$EBAB,$EC72 
		dc.w	$ED39,$EE00,$EEC7,$EF8E,$F055,$F11D,$F1E5,$F2AD 
		dc.w	$F375,$F43D,$F505,$F5CE,$F696,$F75F,$F827,$F8F0 
		dc.w	$F9B9,$FA82,$FB4A,$FC13,$FCDC,$FDA5,$FE6E,$FF37 
		dc.w	$0000,$00C9,$0192,$025B,$0324,$03ED,$04B6,$057E 
		dc.w	$0647,$0710,$07D9,$08A1,$096A,$0A32,$0AFB,$0BC3 
		dc.w	$0C8B,$0D53,$0E1B,$0EE3,$0FAB,$1072,$1139,$1200 
		dc.w	$12C7,$138E,$1455,$151B,$15E1,$16A7,$176D,$1833 
		dc.w	$18F8,$19BD,$1A82,$1B46,$1C0B,$1CCF,$1D93,$1E56 
		dc.w	$1F19,$1FDC,$209F,$2161,$2223,$22E4,$23A6,$2467 
		dc.w	$2527,$25E7,$26A7,$2767,$2826,$28E5,$29A3,$2A61 
		dc.w	$2B1E,$2BDB,$2C98,$2D54,$2E10,$2ECC,$2F86,$3041 
		dc.w	$30FB,$31B4,$326D,$3326,$33DE,$3496,$354D,$3603 
		dc.w	$36B9,$376F,$3824,$38D8,$398C,$3A3F,$3AF2,$3BA4 
		dc.w	$3C56,$3D07,$3DB7,$3E67,$3F16,$3FC5,$4073,$4120 
		dc.w	$41CD,$4279,$4325,$43D0,$447A,$4523,$45CC,$4674 
		dc.w	$471C,$47C3,$4869,$490E,$49B3,$4A57,$4AFA,$4B9D 
		dc.w	$4C3F,$4CE0,$4D80,$4E20,$4EBF,$4F5D,$4FFA,$5097 
		dc.w	$5133,$51CE,$5268,$5301,$539A,$5432,$54C9,$555F 
		dc.w	$55F4,$5689,$571D,$57B0,$5842,$58D3,$5963,$59F3 
		dc.w	$5A81,$5B0F,$5B9C,$5C28,$5CB3,$5D3D,$5DC6,$5E4F 
		dc.w	$5ED6,$5F5D,$5FE2,$6067,$60EB,$616E,$61F0,$6271 
		dc.w	$62F1,$6370,$63EE,$646B,$64E7,$6562,$65DD,$6656 
		dc.w	$66CE,$6745,$67BC,$6831,$68A5,$6919,$698B,$69FC 
		dc.w	$6A6C,$6ADB,$6B4A,$6BB7,$6C23,$6C8E,$6CF8,$6D61 
		dc.w	$6DC9,$6E30,$6E95,$6EFA,$6F5E,$6FC0,$7022,$7082 
		dc.w	$70E1,$7140,$719D,$71F9,$7254,$72AE,$7306,$735E 
		dc.w	$73B5,$740A,$745E,$74B1,$7503,$7554,$75A4,$75F3 
		dc.w	$7640,$768D,$76D8,$7722,$776B,$77B3,$77F9,$783F 
		dc.w	$7883,$78C6,$7908,$7949,$7989,$79C7,$7A04,$7A41 
		dc.w	$7A7C,$7AB5,$7AEE,$7B25,$7B5C,$7B91,$7BC4,$7BF7 
		dc.w	$7C29,$7C59,$7C88,$7CB6,$7CE2,$7D0E,$7D38,$7D61 
		dc.w	$7D89,$7DB0,$7DD5,$7DF9,$7E1C,$7E3E,$7E5E,$7E7E 
		dc.w	$7E9C,$7EB9,$7ED4,$7EEF,$7F08,$7F20,$7F37,$7F4C 
		dc.w	$7F61,$7F74,$7F86,$7F96,$7FA6,$7FB4,$7FC1,$7FCD 
		dc.w	$7FD7,$7FE0,$7FE8,$7FEF,$7FF5,$7FF9,$7FFC,$7FFE 

		SECTION BSS
mul_160		DS.L 384
plot_masks	DS.L 384

stars 		DS.l no_strs*2

		DS.L 399
stack		DS.L 3	
		DS.B 320
screens		DS.B 256
		DS.B 42240
		DS.B 42240

humungus_table	DS.W 512*256*2
