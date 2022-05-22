Polyfill	LEA $dff000,A6
		MOVE.W D0,D7			; no of edges
		ADD D0,D0 
		ADD D0,D0 			; *4
		MOVE.L (A5),(A5,D0) 		; last vert=first(line draw)
		SUBQ #1,D7			; edges-1
		LEA tmul_160(PC),A2
		LEA .max_x+2(PC),A3 
		MOVE.L log_base(PC),A4
		ADD.W col(PC),A4		; fetched colour
		CLR.W .max_x-.max_x(a3)
		CLR.W .max_y-.max_x(a3)
		MOVE #32767,.min_x-.max_x(a3)
		MOVE #32767,.min_y-.max_x(a3)
		MOVEQ #-1,d5
		waitblit			; wait for bloody blitter!
		MOVE.L d5,BLTAFWM(A6)
		MOVE.W #linewidth,BLTCMOD(A6)
		MOVE.W #linewidth,BLTDMOD(A6)
		CLR.L BLTAPT(A6)
		MOVE.W #$8000,BLTADAT(A6)
		MOVE.W D5,BLTBDAT(A6)
.drawline_lp	MOVEM.W (A5),D0-D3		; get x1,y1,x2,y2
.max_x		CMP #0,D0 
		BLE.S .min_x 
		MOVE.W D0,(A3)
.min_x		CMP #32767,D0 
		BGE.S .max_y 
		MOVE.W D0,.min_x-.max_x(A3) 
.max_y		CMP #0,D1 
		BLE.S .min_y 
		MOVE.W D1,.max_y-.max_x(A3) 
.min_y		CMP #32767,D1 
		BGE.S .donetst 
		MOVE.W D1,.min_y-.max_x(A3) 
.donetst	ADDQ.L #4,A5
.Drawline	CMP.W D1,D3
		BHI .quadok
		EXG D0,D2
		EXG D1,D3
.quadok		SUB.W D1,D3			; dy
		SUB.W D0,D2			; dx
		BPL.S .toptwo
		NEG.W D2
		MOVE.L #$0B5A0000+$B,D4
		CMP.W D3,D2
		BCS.S .letsdraw
		MOVE.L #$0B5A0000+$17,D4
		EXG D2,D3
		BRA.S .letsdraw
.toptwo		MOVE.L #$0B5A0000+3,D4
		CMP.W D3,D2
		BCS.S .letsdraw
		MOVE.L #$0B5A0000+$13,D4
		EXG D2,D3
.letsdraw	ADD.W D2,D2
		MOVE.W D2,D5
		SUB.W D3,D5
		CMP.W D2,D3
		BCS .signok
		OR.W #$40,D4
.signok		MOVE.W D0,D6
		ROR.L #4,D0
		ADD D0,D0
		MOVE.L A4,A0
		ADD D1,D1
		ADD.W (A2,D1),D0
		ADD D0,A0
		ADD D6,D6
		MOVE.W .xmasks(PC,D6),D1
		CLR.W D0
		OR.L D0,D4
		waitblit
		EOR.W D1,(A0)
		MOVE.L A0,BLTCPT(A6)
		MOVE.L A0,BLTDPT(A6)
		MOVE.W D5,BLTAPT+2(A6)
		SUB.W D3,D5
		MOVE.W D5,BLTAMOD(A6)
		MOVE.W D2,BLTBMOD(A6)
		MOVE.L D4,BLTCON0(A6)
		ADDQ.W #1,D3
		LSL.W #6,D3
		ADDQ.W #2,D3
		MOVE.W D3,BLTSIZE(A6)
		DBF D7,.drawline_lp
		BRA .fillit

.xmasks		REPT 20
		DC.W $8000,$4000,$2000,$1000,$800,$400,$200,$100,$80,$40,$20,$10,$8,$4,$2,$1
		ENDR
