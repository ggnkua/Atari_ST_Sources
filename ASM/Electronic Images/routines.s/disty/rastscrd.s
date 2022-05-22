; The Resistance\Inner Circle screen for the European Demo
; Coding  :Martin Griffiths(Griff of the Resistance)
; Graphix :Lawrence McDonald(Master of the Resistance)
;         :Chris Nordberg(Resistance logo)
; Music   :Nic Alderton(Count Zero of Electronic Images)


		OPT O+,OW-

demoflag	EQU 0			run from gem/demo(0/1)

; Note to Mr Bee:
; If you set demoflag to 1 then the demo is ready to be assembled
; all mfp,stack etc is restored all you need to do is put an 'org'
; to whatever address it is to be assembled at.
 
		IFEQ demoflag
		CLR -(SP)
		PEA -1.W
		PEA -1.W
		MOVE #5,-(SP)
		TRAP #14
		LEA 12(SP),SP
		MOVE #37,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		ENDC

raslinewid	EQU 300

Start		MOVE #$2700,SR
		MOVE.L SP,old_sp		;Save stack
		LEA stack,SP
		MOVE.L #screen1+256,D0
		CLR.B D0
		MOVE.L D0,log_base
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W
		LEA old_mfp,A0
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+
		MOVE.B $FFFFFA1B.W,(A0)+
		MOVE.B $FFFFFA21.W,(A0)+
		MOVE.L $70.W,(A0)+
		MOVE.L $120.W,(A0)+
		BCLR.B #3,$FFFFFA17.W
		move.b #1,$FFFFFA07.W
		CLR.B $FFFFFA09.W
		MOVE.B #1,$FFFFFA13.W
		CLR.B $FFFFFA15.W
		MOVE.L #my_vbl,$70.W
		MOVE #$2300,SR
wait		BTST.B #0,$FFFFFC00.W
		BEQ wait
		CMP.B #$39,$FFFFFC02.W
		BNE wait
		MOVE #$2700,SR
		LEA old_mfp,A0
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W
		MOVE.B (A0)+,$FFFFFA1B.W
		MOVE.B (A0)+,$FFFFFA21.W
		MOVE.L (A0)+,$70.W
		MOVE.L (A0)+,$120.W
		BSET.B #3,$FFFFFA17.W
		MOVE #$2300,SR

		IFEQ demoflag
		MOVE.L #$07770000,$FFFF8240.W
		MOVE.L #$00000000,$FFFF8244.W
		CLR -(SP)
		TRAP #1
		ENDC

		MOVE.L old_sp(PC),SP
		RTS
old_sp		DC.L 0
my_vbl		movem.l d0-d7/a0-a6,-(sp)

; Rasterscroll stuff

		move.w rast_vertmove(pc),d0
		add #10,d0
		and #$3fe,d0
		move.w d0,rast_vertmove
		lea trig_tab(pc),a0
		move.w (a0,d0),d0
		muls #80,d0
		add.l d0,d0
		swap d0
		add #81,d0
		clr.b $fffffA1b.w
		move.l #rasterdisplay,$120.w
		move.b d0,$fffffa21.w
		move.b #8,$fffffa1b.w
		add d0,d0
		lea rast_ytable(pc),a0
		move (a0,d0),scrcountoffy+2

rast_calc_dist	lea rast_dist_tab+4(pc),a0
		rept 4
		movem.l (a0)+,d0-d7/a1-a6
		movem.l d0-d7/a1-a6,-60(a0)
		endr
		movem.l (a0)+,d0-d6
		movem.l d0-d6,-32(a0)
		move rast_dist_ang(pc),d0
		add rast_dist_step(pc),d0
		and #$7fe,d0
		move d0,rast_dist_ang
		move rast_dister(pc),d1
		add rast_dist_step(pc),d1
		cmp rast_maxi_dist(pc),d1
		ble.s rnotwang
 		sub rast_maxi_dist(pc),d1
rsel_wave	move.l rast_wave_ptr(pc),a1
		tst (a1)
		bpl.s rnrapwave 
		lea rast_wave_tab(pc),a1
rnrapwave	lea rast_dist_step(pc),a2
		move.w (a1)+,(a2)+
		move.l (a1)+,(a2)
		move.l a1,rast_wave_ptr
rnotwang	move d1,rast_dister
		lea trig_tab(pc),a1		ptr to sin table
		move (a1,d0),d0			sin(xd)
		muls rast_size(pc),d0		*size (magnitude of wave)
		add.l d0,d0				
		swap d0				normalise
		add #32*16,d0
		lsr.w #4,d0
		ext.l d0
		divu #3,d0
		swap d0
		neg d0
		addq #3,d0
		add.l d0,d0
		move.l d0,rast_dist_tab+252

		subq #2,rast_scx
		bne notnewchunk
		move.l rast_scrpoint(pc),a0	curr text ptr
		addq #2,rast_scrlpos		onto next chunk 
		cmp #148,rast_scrlpos		in pix buffer.
		bne.s nowrapscr			reached end of buffer?		
		clr rast_scrlpos		if yes reset buffer position
nowrapscr	move #6,rast_scx		+ pix position
		subq #2,rast_inchunk
		bne.s notwrap 
		move #12,rast_inchunk
		addq #1,a0			
pos_ok		move.b (a0),d0	
		bne.s notwrap			end of text?
		lea rast_text(PC),a0		yes restart text
notwrap		move.l a0,rast_scrpoint			
		moveq #0,d0
		move.b (a0)+,d0
		sub.b #64,d0			normalise asci char
		mulu #12*32,d0         		
		lea rast_font+28+12(pc),a5     	
		sub rast_inchunk(pc),d0 
		add d0,a5
		lea scbuffer(pc),a6
		add rast_scrlpos(pc),a6
i		set 0
j		set 0
		rept 32
		move i(a5),d0
		move d0,j+146(a6)
		move d0,j-2(a6)
i		set i+12
j		set j+raslinewid
		endr
		
notnewchunk	movem.l (sp)+,d0-d7/a0-a6
		addq #1,vbl_timer
		rte

rasterdisplay	move #$2700,sr
		clr.b $fffffa1b.w
		movem.l d0-d7/a0-a6,-(sp)
		move #$8209,a0
waits		move.b (a0),d0
scrcountoffy	sub #0,d0
		and #$3F,d0
		moveq #$3F,d1
		sub d0,d1
		lsl d1,d0
		dcb.w 50,$4e71
		lea scbuffer(pc),a0
		add rast_scrlpos(pc),a0
		lea $ffff8240.w,a1
		lea rast_dist_tab(pc),a2 
		move.w rast_scx(pc),d0
lp		rept 32
		move.l a0,a3
		add.w (a2)+,a3
		move.w (a2)+,d2
		add d0,d2
		moveq #12,d1
		sub d2,d1
		lsl d2,d3
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		dcb.w 2,$4e71
		lsl d1,d3
		move.l a0,a3
		add.w (a2)+,a3
		move.w (a2)+,d2
		add d0,d2
		moveq #12,d1
		sub d2,d1
		lsl d2,d3
		dcb.w 2,$4e71
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		move.w (a3)+,(a1)
		dcb.w 2,$4e71
		lsl d1,d3
		lea raslinewid(a0),a0
		endr
		clr.w (a1)
		movem.l (sp)+,d0-d7/a0-a6
		rte

; Disting Raster scroll variables and stuff...

rast_ytable	rept 25
		dc.w 0
		dc.w 160
		dc.w 320-256
		dc.w 480-256
		dc.w 640-512
		dc.w 800-768
		dc.w 960-768
		dc.w 1120-1024
		endr
rast_vertmove	dc.w 0
rast_scrpoint	DC.L rast_text
rast_scx	DC.W 6
rast_scrlpos	DC.W 0
rast_inchunk	DC.W 12
rast_text	dc.b "[RASTERSCROLLER[[BETTERER[THAN[NICKS[SO[THERE[STICK[THAT[UP[YOUR[NOSE[[["
		dc.b 0
		EVEN
rast_dist_ang	DC.W 0
rast_dist_step	DC.W 4
rast_maxi_dist	DC.W 1024
rast_size	DC.W 0
rast_dister	DC.W 0
rast_wave_ptr	DC.L rast_wave_tab
rast_wave_tab	DC.W 16,1024,8*16
		DC.W 16,1024,4*16
		DC.W 16,1024,16*16
		DC.W 16,1024,32*16
		DC.W -1
rast_dist_tab	ds.l 65
rast_font	incbin colchar.dat

log_base	DS.L 1
		DS.L 1
vbl_timer	DS.W 1

trig_tab	dc.w	$0000,$FF37,$FE6E,$FDA5,$FCDC,$FC13,$FB4A,$FA82 
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

		SECTION BSS
		DS.W 2
scbuffer	DS.B 32*raslinewid
		DS.W 2

old_mfp		DS.L 6

		DS.L 149
stack		DS.L 1
screen1		DS.B 256
		DS.B 32000

