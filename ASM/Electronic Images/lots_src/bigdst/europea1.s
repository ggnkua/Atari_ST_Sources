; The Resistance\Inner Circle screen for the European Demo
; Coding  :Martin Griffiths(Griff of the Resistance)
; Graphix :Lawrence McDonald(Master of the Resistance)
;         :Chris Nordberg(Resistance logo)
; Music   :Nic Alderton(Count Zero of Electronic Images)


		OPT O+,OW-

demoflag	EQU 0			run from gem/demo(0/1)

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
no_lines	EQU 46
linewid		EQU 104*4
bufsize		EQU no_lines*linewid 

Start		MOVE #$2700,SR
		MOVE.L SP,old_sp		;Save stack
		LEA stack,SP
		MOVE #$8240,A0
		REPT 8
		CLR.L (A0)+
		ENDR
		LEA stack,SP
		MOVE.L log_base(PC),D0
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W
		MOVEQ #1,D0
		JSR mus+28
		BSR Calcwave
		BSR cls
		BSR copylogo
		LEA old_mfp,A0
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+
		MOVE.B $FFFFFA1B.W,(A0)+
		MOVE.B $FFFFFA21.W,(A0)+
		MOVE.L $68.W,(A0)+
		MOVE.L $70.W,(A0)+
		MOVE.L $120.W,(A0)+
		MOVE.L $134.W,(A0)+
		BCLR.B #3,$FFFFFA17.W
		MOVE.B #$21,$FFFFFA07.W
		CLR.B $FFFFFA09.W
		MOVE.B #$21,$FFFFFA13.W
		CLR.B $FFFFFA15.W
		MOVE.L #first_vbl,$70.W
		MOVE.L #topbord,$134.W
		MOVE #$2300,SR

; Main vbl loop...

wait		move vbl_timer(pc),d0
wait_vbl	cmp vbl_timer(pc),d0
		beq.s wait_vbl

; Rasterscroll stuff

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
		bne.s rast_nowrapscr		reached end of buffer?		
		clr rast_scrlpos		if yes reset buffer position
rast_nowrapscr	move #6,rast_scx		+ pix position
		subq #2,rast_inchunk
		bne.s rast_notwrap 
		move #12,rast_inchunk
		addq #1,a0			
		move.b (a0),d0	
		bne.s rast_notwrap		end of text?
		lea rast_text(PC),a0		yes restart text
rast_notwrap	move.l a0,rast_scrpoint			
		moveq #0,d0
		move.b (a0)+,d0
		sub.b #64,d0			normalise asci char
		mulu #12*32,d0
		lea rast_font+28+12(pc),a5     	
		sub rast_inchunk(pc),d0 
		add d0,a5
		lea rast_scbuffer,a6
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
notnewchunk	

;----------------------------------------------;
; Dist scroller Rout using 16 offseted buffers ;
;----------------------------------------------;

		MOVE.L log_base(PC),A0	screen base
		LEA -320+(32*160)(A0),A0
		MOVEQ #0,D2
		MOVEQ #1,D1
clearoldlp	MOVEQ #3,D0
clearold	REPT 40
		MOVEP.L D2,(A0)
		ENDR
		LEA 160(A0),A0
		DBF D0,clearold
		LEA (no_lines-4)*160(A0),A0
		DBF D1,clearoldlp

; Vertical dist setup

vdist		MOVE.W vwaveptr(PC),D0
		ADDQ #2,D0
		AND #$3FF,D0
		LEA testvwave(PC),A0
		ADD.W D0,A0
		MOVE.W D0,vwaveptr
		LEA plot8(PC),A1
		LEA clearold(PC),A2
i		SET 2
j		SET 0
		REPT 5
		MOVEM.W (A0)+,D0-D7
		ADD #j,D0
		MOVE.W D0,i(A1)
		MOVE.W D0,j+2(A2)
		ADD #j+1,D1
		MOVE.W D1,i+4(A1)
		MOVE.W D1,j+6(A2)
		ADD #j+8,D2
		MOVE.W D2,i+8(A1)
		MOVE.W D2,j+10(A2)
		ADD #j+9,D3
		MOVE.W D3,i+12(A1)
		MOVE.W D3,j+14(A2)
		ADD #j+16,D4
		MOVE.W D4,i+16(A1)
		MOVE.W D4,j+18(A2)
		ADD #j+17,D5
		MOVE.W D5,i+20(A1)
		MOVE.W D5,j+22(A2)
		ADD #j+24,D6
		MOVE.W D6,i+24(A1)
		MOVE.W D6,j+26(A2)
		ADD #j+25,D7
		MOVE.W D7,i+28(A1)
		MOVE.W D7,j+30(A2)
i		SET i+36
j		SET j+32
		ENDR

; Horizontal dist setup

calc_dist	LEA dist_tab+2(PC),A0
		MOVEM.L (A0)+,D0-D7/A1-A6
		MOVEM.L D0-D7/A1-A6,-58(A0)
		MOVEM.L (A0)+,D0-D7/A1
		MOVEM.L D0-D7/A1,-38(A0)
		MOVE dist_ang(PC),D0
		ADD dist_step(PC),D0
		AND #$7FF,D0
yep		MOVE D0,dist_ang
		MOVE dister(PC),D1
		ADD dist_step(PC),D1
		CMP maxi_dist(PC),D1
		BLE.S notwang
 		SUB maxi_dist(PC),D1
sel_wave	MOVE.L wave_ptr(PC),A1
		LEA dist_step(PC),A2
		MOVE (A1)+,(A2)+
		BPL.S nrapwave 
		LEA wave_tab(PC),A1
		MOVE (A1)+,-2(A2)
nrapwave	MOVE.L (A1)+,(A2)+
		MOVE.L A1,wave_ptr
notwang		MOVE D1,dister
		LEA trig_tab(PC),A1		ptr to sin table
		MOVE (A1,D0),D0			sin(xd)
		MULS size(PC),D0		*size (magnitude of wave)
		ADD.L D0,D0
		SWAP D0				normalise
		ADD #48,D0
		ADD D0,D0
		ADD D0,D0			x4
		MOVE.W D0,dist_tab+90		place in table
		LEA scr_point(PC),A1
		MOVEM.L (A1)+,A0/A3		curr text ptr+curr pix buffer ptr
		MOVE (A1),D6			pixel offset
		ADD.L #bufsize*4,A3		skip 4 buffers(4 pix step)	
		ADDQ #4,D6			add 4(4 pixel step)
		CMP #8,D6
		BNE t2
		LEA scbuffer,A3			reset pixel chunk offset
		MOVE #4,littleadd
t2		CMP #16,D6			end of chunk?
		BNE.S pos_ok			no then skip
		ADDQ.W #8,scrlpos		onto next chunk 
		CMP #208,scrlpos		in pix buffer.
		BNE.S nowrapscr			reached end of buffer?		
		CLR scrlpos			if yes reset buffer position
nowrapscr	LEA scbuffer,A3			reset pixel chunk offset
		CLR littleadd
		MOVEQ #0,D6			+ pix position
		ADD #384,inletswitch		font is 64 wide
		CMP #3*384,inletswitch
		BNE.S pos_ok 			so there are two chunks
		CLR inletswitch
		ADDQ.L #1,A0			after 32 pixs,next letter...
pos_ok		TST.B 1(A0)	
		BNE.S notwrap			end of text?
		LEA text(PC),A0			yes restart text
notwrap		MOVE D6,(A1)			otherwise restore
		MOVE.L A3,-(A1)			
		MOVE.L A0,-(A1)			
		MOVEQ #0,D0
		MOVE.B (A0)+,D0
		LEA char_tab(PC),A5
		ADD D0,D0
		ADD D0,D0
		MOVE.L (A5,D0),A5
		MOVE inletswitch(PC),d0
		ADD D0,A5
		LEA 384(A5),A6			point to 2nd chunk
		CMP #384*2,d0			are we in last chunk
		Bne.S norm 			already?
		MOVEQ #0,D0			1st chunk of next char
		MOVE.B (A0),D0			must be plotted
		LEA char_tab(PC),A6
		ADD D0,D0
		ADD D0,D0
		MOVE.L (A6,D0),A6
norm		ADD scrlpos(PC),A3
		ADD littleadd(PC),A3
		LEA 200(A3),A3
		MOVEQ #no_lines-1,D7
		CMP #8,D6
		BGE morethan8

; There are two shift cases this way we only ever have to shift a max
; of 8 times. ROL instructions take 2 cycles extra per shift so we
; save 8*2*4=64 cycles on every line we plot.

; Shift in chunk of character - this does less all shifts<8
i		SET 0
a1		MOVEM.W (A6)+,D2-d5
		SWAP D2
		SWAP D3
		SWAP D4
		SWAP D5
		MOVE.W (A5)+,D2 
		MOVE.W (A5)+,D3 
		MOVE.W (A5)+,D4 
		MOVE.W (A5)+,D5 
		ROL.L D6,D2
		ROL.L D6,D3
		ROL.L D6,D4
		ROL.L D6,D5
		MOVE.B D2,(A3)+
		MOVE.B D3,(A3)+
		MOVE.B D4,(A3)+
		MOVE.B D5,(A3)+
		MOVE.L -4(A3),-204-8(A3)
		ROL.L #1,D2
		ROL.L #1,D3
		ROL.L #1,D4
		ROL.L #1,D5
		LEA bufsize-4(A3),A3
		MOVE.B D2,(A3)+
		MOVE.B D3,(A3)+
		MOVE.B D4,(A3)+
		MOVE.B D5,(A3)+
		MOVE.L -4(A3),-204-8(A3)
		ROL.L #1,D2
		ROL.L #1,D3
		ROL.L #1,D4
		ROL.L #1,D5
		LEA bufsize-4(A3),A3
		MOVE.B D2,(A3)+
		MOVE.B D3,(A3)+
		MOVE.B D4,(A3)+
		MOVE.B D5,(A3)+
		MOVE.L -4(A3),-204-8(A3)
		ROL.L #1,D2
		ROL.L #1,D3
		ROL.L #1,D4
		ROL.L #1,D5
		LEA bufsize-4(A3),A3
		MOVE.B D2,(A3)+
		MOVE.B D3,(A3)+
		MOVE.B D4,(A3)+
		MOVE.B D5,(A3)+
		MOVE.L -4(A3),-204-8(A3)
		ADD.L #linewid-(bufsize*3)-4,A3
		DBF D7,a1
		BRA copy_buf
; Shift in chunk of character - this does less all shifts>=8
morethan8	NEG D6
		ADD #16,D6
a2		MOVEM.W (A5)+,D2-d5
		SWAP D2
		SWAP D3
		SWAP D4
		SWAP D5
		MOVE.W (A6)+,D2 
		MOVE.W (A6)+,D3 
		MOVE.W (A6)+,D4 
		MOVE.W (A6)+,D5 
		ROR.L D6,D2
		ROR.L D6,D3
		ROR.L D6,D4
		ROR.L D6,D5
		MOVE.B D2,(A3)+
		MOVE.B D3,(A3)+
		MOVE.B D4,(A3)+
		MOVE.B D5,(A3)+
		MOVE.L -4(A3),-204-8(A3)
		ROL.L #1,D2
		ROL.L #1,D3
		ROL.L #1,D4
		ROL.L #1,D5
		LEA bufsize-4(A3),A3
		MOVE.B D2,(A3)+
		MOVE.B D3,(A3)+
		MOVE.B D4,(A3)+
		MOVE.B D5,(A3)+
		MOVE.L -4(A3),-204-8(A3)
		ROL.L #1,D2
		ROL.L #1,D3
		ROL.L #1,D4
		ROL.L #1,D5
		LEA bufsize-4(A3),A3
		MOVE.B D2,(A3)+
		MOVE.B D3,(A3)+
		MOVE.B D4,(A3)+
		MOVE.B D5,(A3)+
		MOVE.L -4(A3),-204-8(A3)
		ROL.L #1,D2
		ROL.L #1,D3
		ROL.L #1,D4
		ROL.L #1,D5
		LEA bufsize-4(A3),A3
		MOVE.B D2,(A3)+
		MOVE.B D3,(A3)+
		MOVE.B D4,(A3)+
		MOVE.B D5,(A3)+
		MOVE.L -4(A3),-204-8(A3)
		ADD.L #linewid-(bufsize*3)-4,A3
		DBF D7,a2

copy_buf	JSR mus+28+2
		MOVE.L log_base(PC),A2		screen base
		LEA 32*160(A2),A2		+ a bit!
		LEA scbuffer,A0
		ADD scrlpos(PC),A0
		LEA dist_tab(PC),A3
		LEA xtab(PC),A4
		MOVE.W scx(PC),D0
		ADD D0,D0
		ADD D0,D0
		ADD.W D0,A4
		MOVEQ #no_lines-1,D7
mainplotlp	MOVE.W D7,A5
		MOVE.W (A3)+,D0
		LEA (A0),A1
		ADD.L (A4,D0),A1
		MOVEM.L (A1)+,D0-D7
plot8		MOVEP.L D0,(a2)
		MOVEP.L D1,(a2)
		MOVEP.L D2,(a2)
		MOVEP.L D3,(a2)
		MOVEP.L D4,(a2)
		MOVEP.L D5,(a2)
		MOVEP.L D6,(a2)
		MOVEP.L D7,(a2)
		MOVEM.L (A1)+,D0-D7
		MOVEP.L D0,(a2)
		MOVEP.L D1,(a2)
		MOVEP.L D2,(a2)
		MOVEP.L D3,(a2)
		MOVEP.L D4,(a2)
		MOVEP.L D5,(a2)
		MOVEP.L D6,(a2)
		MOVEP.L D7,(a2)
		MOVEM.L (A1)+,D0-D7
		MOVEP.L D0,(a2)
		MOVEP.L D1,(a2)
		MOVEP.L D2,(a2)
		MOVEP.L D3,(a2)
		MOVEP.L D4,(a2)
		MOVEP.L D5,(a2)
		MOVEP.L D6,(a2)
		MOVEP.L D7,(a2)
		MOVEM.L (A1)+,D0-D7
		MOVEP.L D0,(a2)
		MOVEP.L D1,(a2)
		MOVEP.L D2,(a2)
		MOVEP.L D3,(a2)
		MOVEP.L D4,(a2)
		MOVEP.L D5,(a2)
		MOVEP.L D6,(a2)
		MOVEP.L D7,(a2)
		MOVEM.L (A1)+,D0-D7
		MOVEP.L D0,(a2)
		MOVEP.L D1,(a2)
		MOVEP.L D2,(a2)
		MOVEP.L D3,(a2)
		MOVEP.L D4,(a2)
		MOVEP.L D5,(a2)
		MOVEP.L D6,(a2)
		MOVEP.L D7,(a2)
		LEA 160(A2),A2
		LEA linewid(A0),A0
		MOVE.W A5,D7
		DBF D7,mainplotlp

		BTST.B #0,$FFFFFC00.W
		BEQ wait
		CMP.B #$39,$FFFFFC02.W
		BNE wait

end		MOVE #$2700,SR
		LEA old_mfp,A0
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W
		MOVE.B (A0)+,$FFFFFA1B.W
		MOVE.B (A0)+,$FFFFFA21.W
		MOVE.L (A0)+,$68.W
		MOVE.L (A0)+,$70.W
		MOVE.L (A0)+,$120.W
		MOVE.L (A0)+,$134.W
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

first_vbl	CLR.L $FFFF8240.W
		CLR.L $FFFF8240+4.W
		CLR.L $FFFF8240+8.W
		CLR.L $FFFF8240+12.W
		CLR.L $FFFF8240+16.W
		CLR.L $FFFF8240+20.W
		CLR.L $FFFF8240+24.W
		CLR.L $FFFF8240+28.W
		ADDQ #1,vbl_timer
		MOVE.L #my_vbl,$70.W
		RTE

my_vbl		CLR.B $FFFFFA19.W
		MOVE.B #100,$FFFFFA1F.W
		MOVE.B #4,$FFFFFA19.W
		MOVE.L #phbl,$68.W
		MOVEM.L D0-D7/A0-A6,-(SP)
		move.w rast_vertmove(pc),d0
		add #10,d0
		and #$3fe,d0
		move.w d0,rast_vertmove
		lea trig_tab(pc),a0
		move.w (a0,d0),d0
		muls #60,d0
		add.l d0,d0
		swap d0
		add #61,d0
		move #63+64,d1
		sub d0,d1
		clr.b $fffffa1b.w
		move.l #rasterdisplay,$120.w
		move.b d0,$fffffa21.w
		move.b #8,$fffffa1b.w
		move.b d1,$fffffa21.w
		add d0,d0
		lea rast_ytable(pc),a0
		move (a0,d0),scrcountoffy+2
fadestuff	TST fadecnt
		BEQ fade_done
		SUBQ #1,infadecnt
		BNE.S fade_done
		MOVE #4,infadecnt
		LEA toppal(PC),A1	dest palette
		LEA destpal(PC),A0	hardware regs
		MOVEQ #7,D4
col_lp		MOVE (A0),D0		curr value
		MOVE (A1)+,D1		dest value
		MOVE D0,D2
		MOVE D1,D3
		AND #$700,D2
		AND #$700,D3
		CMP D2,D3		
		BLE.S R_done
		ADD #$100,D0
R_done		MOVE D0,D2
		MOVE D1,D3
		AND #$070,D2
		AND #$070,D3
		CMP D2,D3
		BLE.S G_done
		ADD #$010,D0
G_done 		MOVE D0,D2
		MOVE D1,D3
		AND #$007,D2
		AND #$007,D3
		CMP D2,D3
		BLE.S B_done
		ADDQ #$001,D0
B_done		MOVE D0,(A0)+
		DBF D4,col_lp
		SUBQ #1,fadecnt
fade_done	MOVEM.L destpal(PC),D0-D3
		MOVEM.L D0-D3,$FFFF8240.W
		LEA log_base(PC),A0
		MOVEM.L (A0)+,D0-D1
		MOVE.L D0,-(A0)
		MOVE.L D1,-(A0)
		LSR #8,D1
		MOVE.L D1,$FFFF8200.W
		movem.l (sp)+,d0-d7/a0-a6
		addq #1,vbl_timer
		rte

topbord		move #$2100,sr
		stop #$2100
		move #$2700,sr
		clr.b $FFFFFA19.w
		dcb.w 76,$4e71
		clr.b $FFFF820A.w
		dcb.w 18,$4e71
		move.b #2,$FFFF820A.w
		rte
phbl		rte

rasterdisplay	move #$2700,sr
		movem.l d0-d4/a0-a4,-(sp)
		move.l #hbl1,$120.w
waits		move.b $ffff8209.w,d0
scrcountoffy	sub #0,d0
		and #$3F,d0
		moveq #$3F,d1
		sub d0,d1
		lsl d1,d0
		dcb.w 50,$4e71
		lea rast_scbuffer,a0
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
		movem.l (sp)+,d0-d4/a0-a4
		rte

hbl1		CLR.B $FFFFFA1B.W
		MOVE.B #101,$FFFFFA21.W
		MOVE.L #hbl2,$120.W
		MOVE.B #8,$FFFFFA1B.W
		MOVE.L #$00000045,$FFFF8240.W
		MOVE.L #$01010212,$FFFF8240+4.W
		MOVE.L #$03230434,$FFFF8240+8.W
		MOVE.L #$05450034,$FFFF8240+12.W
		MOVE.L #$00010012,$FFFF8240+16.W
		MOVE.L #$00230000,$FFFF8240+20.W
		MOVE.L #$00000000,$FFFF8240+24.W
		MOVE.L #$00000000,$FFFF8240+28.W
		RTE

hbl2		MOVE.W D0,-(SP)
		dcb.w 33,$4e71
.syncb		MOVE.B $ffff8209.w,D0
		NEG.B D0
		ADD.B #64+128,D0		
		LSL.B D0,D0
		MOVE #18,D0
.wait		DBF D0,.wait		;101 nops!
		MOVE.B #0,$FF820A
		DCB.W 12,$4E71
		MOVE.B #2,$FF820A
		MOVE.W (SP)+,D0
		RTE

toppal		DC.L $00000010
		DC.L $01210131
		DC.L $02420353
		DC.L $05750777
destpal		DS.L 4
infadecnt	DC.W 4
fadecnt		DC.W 7

; Create vertical wave

Calcwave	LEA testvwave(PC),A0
		LEA trig_tab(PC),A1
		MOVE #512+80,D7
calcvwave 	MOVE (A1,D2),D0
		MULS #40,D0
		ADD.L D0,D0
		SWAP D0
		MOVE.W D0,D1
		ADD #136,D1
		MULU #160,D1
		MOVE.W D1,(A0)+
		ADD #16,D2
		AND #$7FF,D2
		DBF D7,calcvwave		
		RTS

; Clear screen.

cls		MOVE.L log_base(PC),A0
		MOVE #3999,D0
		MOVEQ #0,D1
clsloop		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		DBF D0,clsloop
		RTS

; Copy logo to screen
		
copylogo	LEA reslogo,A0
		MOVE.L log_base(PC),A1
		MOVE.L log_base+4(PC),A2
		LEA 12*160(A1),A1
		LEA 12*160(A2),A2
		MOVE.W #14080/4-1,D0
COPYLOGOLP	MOVE.L (A0),(A1)+
		MOVE.L (A0)+,(A2)+
		DBF D0,COPYLOGOLP
		RTS

i		SET 0
xtab		REPT 20
		DC.L i
		DC.L i+(bufsize*1)
		DC.L i+(bufsize*2)
		DC.L i+(bufsize*3)
		DC.L i+(bufsize*4)
		DC.L i+(bufsize*5)
		DC.L i+(bufsize*6)
		DC.L i+(bufsize*7)
i		SET i+4
		ENDR

char_tab	rept 33
		dc.l bigfontspce
		endr
		dc.l bigfont+(30*1152)		; !
		dc.l bigfontspce 		; "
		dc.l bigfontspce 		; #
		dc.l bigfontspce 		; $
		dc.l bigfontspce 		; %
		dc.l bigfontspce 		; &
		dc.l bigfont+(29*1152)		; '
		dc.l bigfont+(32*1152)		; (
		dc.l bigfont+(33*1152)		; )
		dc.l bigfontspce 		; *
		dc.l bigfontspce 		; +
		dc.l bigfont+(28*1152)		; ,
		dc.l bigfont+(26*1152)		; -
		dc.l bigfont+(27*1152)		; .
		dc.l bigfontspce 		; /
		dc.l bigfontspce 		; 0
		dc.l bigfontspce 		; 1
		dc.l bigfontspce 		; 2
		dc.l bigfontspce 		; 3 
		dc.l bigfontspce 		; 4
		dc.l bigfontspce 		; 5
		dc.l bigfontspce 		; 6
		dc.l bigfontspce 		; 7
		dc.l bigfontspce 		; 8
		dc.l bigfontspce 		; 9
		dc.l bigfontspce 		; :
		dc.l bigfontspce 		; ;
		dc.l bigfontspce 		; <
		dc.l bigfontspce 		; =
		dc.l bigfontspce 		; >
		dc.l bigfont+(31*1152)		; ?
		dc.l bigfontspce 		; @
i		set 0
		rept 26
		dc.l bigfont+i
i		set i+1152
		endr

littleadd	DC.W 0
scr_point	DC.L text
which_buf	DC.L scbuffer
scx		DC.W 0
scrlpos		DC.W 0
inletswitch	DC.W 0
text		dc.b "  WOW!!  COOOO... THIS DON'T HALF LOOK GOOD... BET YOU CAN'T READ IT THOUGH!        "
		dc.b 0
		EVEN
log_base	DC.L $DA000
		DC.L $E4000
vbl_timer	DS.W 1
dist_ang	DC.W 0
dist_step	DC.W 8
maxi_dist	DC.W 1024
size		DC.W 0
dister		DC.W 0
wave_ptr	DC.L wave_tab
wave_tab	DC.W 8,1024,40
		DC.W 32,1024*8,40
		DC.W 128,4096,1
		DC.W 64,4096,4
		DC.W 8,1024,16
		DC.W 8,1024,32
		DC.W -1

dist_tab	DCB.W no_lines+1,48
vwaveptr	DC.W 0
testvwave	DS.W 1024

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

*vbl_timer	DS.W 1

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
bigfontspce	DS.W 768
bigfont		INCBIN bigfont1.DAT
reslogo		INCBIN reslogo.DAT
mus		INCBIN DOCDOTS.czi

		SECTION BSS
		DS.W 2
rast_scbuffer	DS.B 32*raslinewid
		DS.W 2

		DS.W 8
scbuffer	REPT 8
		DS.B bufsize
		ENDR
		DS.W 8


old_mfp		DS.L 6

		DS.L 149
stack		DS.L 1
screen1		DS.B 256
		DS.B 32000

