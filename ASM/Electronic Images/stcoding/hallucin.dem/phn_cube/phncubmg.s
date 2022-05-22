;-----------------------------------------------------------------------
; 			Phenomena ENIGMA demo
;		
; The 3D Cube with various vector styles on it spinning/rotating etc.. 		
;		
; Original Idea/Amiga coding - Azatoth of Phenomena.
; ST/STE coding/objects by Griff of The Inner Circle (c) June/July 1991		
; YO! Thanx Bealer for helping me type in those fucking coordinates!!!  
;-----------------------------------------------------------------------		
; Updates:-
; 27/06/91 - (now with my fastest line drawer .(about 10k of code!!!!)
; 05/06/91 - overscan scroller added.(runs over occasionally)
; 24/08/91 - tweeked/fades added/optimised a little. 

demo		EQU 0				; 0=gem 1=from DMA disk
dist		EQU 256		; viewpoint distance

		OPT O+,OW-
	
letsgo		
		IFEQ demo
		MOVE.W #4,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		MOVE.W D0,oldres
		MOVE.W #2,-(SP)
		TRAP #14		
		ADDQ.L #2,SP	
		MOVE.L D0,oldbase
		CLR -(SP)
		PEA -1.W
		PEA -1.W
		MOVE.W #5,-(SP)
		TRAP #14
		LEA 12(SP),SP
		CLR.L -(SP)
		MOVE.W #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		MOVE.L D0,oldsp

		ELSEIF

		ORG $10000
		MOVE.L SP,oldsp

		ENDC

		LEA stack,SP
		BSR Initcube
		IFNE demo
		JSR $508
		ENDC
		BSR Initscreens
		BSR Init_ints

		MOVE.L #pal,fadein_pal_ptr
		MOVE.L #currpal,fadein_cur_ptr
		MOVE.W #16,fadein_nocols
		ST fadeinflag
		BSR Enigma_cube

		BSR flush
		BSR RestoreInts

		IFEQ demo
		MOVE.L #$07770000,$FFFF8240.W
		MOVE.L #$00000000,$FFFF8244.W
		MOVE.L oldsp(PC),-(SP)
		MOVE.W #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		MOVE.W oldres(PC),-(SP)
		MOVE.L oldbase(PC),-(SP)
		MOVE.L oldbase(PC),-(SP)
		MOVE.W #5,-(SP)
		TRAP #14
		LEA 12(SP),SP
		CLR -(SP)
		TRAP #1
oldbase		DS.L 1
oldres		DS.W 1

		ELSEIF

		MOVE.L oldsp(PC),SP
		RTS
		ENDC

oldsp		DC.L 0

; Initialise mfp and ints.

Init_ints	MOVE.W #$2700,SR	
		LEA old_mfp(PC),A0
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+
		MOVE.B $FFFFFA1B.W,(A0)+
		MOVE.B $FFFFFA21.W,(A0)+
		MOVE.L $70.W,(A0)+
		MOVE.L $120.W,(A0)+
		MOVE.B #1,$FFFFFA07.W
		CLR.B $FFFFFA09.W
		MOVE.B #1,$FFFFFA13.W
		CLR.B $FFFFFA15.W
		CLR.B $FFFFFA1B.W
		CLR.B $FFFFFA21.W
		BCLR.B #3,$FFFFFA17.W
		MOVE.L #first_vbl,$70.W
		MOVE.W #$2300,SR
		RTS

; Restore ints.

RestoreInts	MOVE.W #$2700,SR
		LEA old_mfp(PC),A0
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W
		MOVE.B (A0)+,$FFFFFA1B.W
		MOVE.B (A0)+,$FFFFFA21.W
		MOVE.L (A0)+,$70.W
		MOVE.L (A0)+,$120.W
		MOVE.W #$2300,SR
		RTS
old_mfp		DS.L 5

; Flush keyboard.

flush		BTST.B #0,$fffffc00.w
		BEQ.S fldone
		MOVE.B $fffffc02.w,d0
		BRA.S flush
fldone		RTS

;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;
;									;
;									;
;									;
;  The 'Enigma' Cube code follows (about 2000 lines of the bastard!!)	;
;	 (you better like it cus it took over 14 hours of coding)	;
;									;
;									;
;									;
;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;

; Initialise the routines / make the tables for the "Enigma" cube .

Initcube	LEA PHCube_Sequence,A0
		LEA (A0),A1
		BSR Init_Seq
		BSR Setupline
		BSR makebigperstab	; big table for main perspective
		BSR makelefttab		;
		BSR makerghttab		; left/right hline masks
		BSR makebit_offs	; plot table(mask.w/offset.w)
		BSR makeperstab		; smaller perspective table
		BSR Initcubestars	; init cube starfields
		RTS

; The Enigma cube main vbl loop (this runs at 25 FPS and not 50!!!)

Enigma_cube	
		move.w #$100,$ffff8240.w
		BSR Swapscreens
		LEA vbl_timer(PC),A6
		move.w (a6),d0
.wait		cmp.w (a6),d0
		beq.s .wait
		move.w #$000,$ffff8240.w
		
;.wait2		CMP #2,(A6)			; make sure 2 vbls
;		BNE.S .wait2			; have occured
		CLR (A6)


		BSR ClearIt			; Clear Screen
		BSR Do_Sequence			; Sequence 3D
		LEA cube(PC),A5	
		BSR Show_object			; draw it!
		TST.B demo_finished
		BNE.S .done
		BTST.B #0,$FFFFFC00.W
		BEQ.S Enigma_cube
		MOVE.B $FFFFFC02.W,D0
		CMP.B #$39,D0
		BNE Enigma_cube			; space?
.done		RTS
demo_finished	DC.W 0

; Initialize line plotting rout.

Setupline	
		rts

Initcubestars
gside1star	LEA side1starcoordsxy(PC),A3
		MOVEQ #33-1,D4
.sde1rndgen	BSR BRand
		AND #$7FF,D0
		MOVE D0,(A3)+
		BSR BRand
		AND #$7FE,D0
		SUB #1023,D0
		MOVE D0,(A3)+
		BSR BRand
		DBF D4,.sde1rndgen
gside2star	LEA side2starcoordsxy(PC),A3
		MOVEQ #33-1,D4
.sde2rndgen	BSR BRand
		AND #$7FF,D0
		MOVE D0,(A3)+
		BSR BRand
		AND #$7FE,D0
		SUB #1023,D0
		MOVE D0,(A3)+
		BSR BRand
		DBF D4,.sde2rndgen
		RTS

BRand		ADD D4,D0
		ADD.W #$573,D0
		MULU #$45F7,D0
		ROR.W #6,D0
		SWAP D0
		CLR.W D0
		SWAP D0
		RTS

makelefttab:	LEA ch_vectl,A0
		MOVEQ #0,D0
		MOVEQ #19,D1
.ml_lp1		MOVEQ #15,D2	
		MOVEQ #-1,D3
.ml_lp2		MOVE.W D3,(A0)+
		MOVE.W D0,(A0)+
		LSR #1,D3
		DBF D2,.ml_lp2
		ADDQ #8,D0
		DBF D1,.ml_lp1
		RTS

makerghttab:	LEA ch_vectr,A0
		MOVEQ #0,D0
		MOVEQ #19,D1
.mr_lp1		MOVEQ #15,D2	
		MOVEQ #0,D3
.mr_lp2		ADD #$8000,D3
		MOVE.W D3,(A0)+
		MOVE.W D0,(A0)+
		LSR #1,D3
		DBF D2,.mr_lp2
		ADDQ #8,D0
		DBF D1,.mr_lp1
		RTS

makebit_offs	LEA bit_offs,A0
		MOVEQ #0,D1
		MOVEQ #19,D3
.mbolp1		MOVE.W #$8000,D0
		MOVEQ #15,D2
.mbolp2		MOVE.W D0,(A0)+
		MOVE.W D1,(A0)+
		LSR #1,D0
		DBF D2,.mbolp2
		ADDQ #8,D1
		DBF D3,.mbolp1
		RTS

makebigperstab:	LEA multable,A0
		MOVE #dist+1,D0
		MOVE #32768-dist-2,D1
.mbblp1		MOVE.L #32768*dist,D2
		DIVS D0,D2
		MOVE.W D2,(A0)+
		ADDQ #1,D0
		DBF D1,.mbblp1
		RTS

makeperstab	LEA perstab,A0
		MOVEQ #0,D0
		MOVE.L #4200*32767,D7
.smptlp		MOVE.W D0,D1
		MOVE.L D7,D6
		ADD #4200,D1
		DIVS D1,D6
		MOVE.W D6,(A0)+
		ADDQ #1,D0
		CMP #$A00,D0
		BNE.S .smptlp
		RTS

; Initialise 2 screens.(Allocate Workspace and clear etc)

Initscreens	LEA log_base(PC),A0
		MOVE.L #screens+256,D0
		CLR.B D0
		MOVE.L D0,(A0)+
		ADD.L #42240,D0
		MOVE.L D0,(A0)+
		MOVE.L log_base(PC),A0
		MOVE #(42240*2)/16,D0
		MOVEQ #0,D1
cls_lp		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		DBF D0,cls_lp
		RTS

; Swap log + phy screen ptrs and set screen hardware reg.

Swapscreens	LEA log_base(PC),A0
		MOVEM.L (A0)+,D5-D6
		MOVE.L D5,-(A0)
		MOVE.L D6,-(A0)
		LSR #8,D5
		MOVE.L D5,$FFFF8200.W
		RTS

; Wait vbl

WaitVbl		LEA vbl_timer,A0
		MOVE (A0),D0
.waitvb		CMP (A0),D0
		BEQ.S .waitvb
		RTS

; Clear area where cube rotates.

ClearIt		MOVE.L log_base(PC),A0
		LEA 32000(A0),A0
		MOVEQ #0,D0
		MOVE.L D0,D1
		MOVE.L D0,D2
		MOVE.L D0,D3
		MOVE.L D0,D4
		MOVE.L D0,D5
		MOVE.L D0,D6
		MOVE.L D0,A1
		MOVE.L D0,A2
		MOVE.L D0,A3
		MOVE.L D0,A4
		MOVE.L D0,A5
		MOVE.L D0,A6
		moveq #(200/4)-1,d7
.lp
		MOVEM.L D0-D6/A1-A6,-(A0)      ;13
		MOVEM.L D0-D6/A1-A6,-(A0)      ;13
		MOVEM.L D0-D6/A1-A6,-(A0)      ;13
		MOVEM.L D0-D6/A1-A6,-(A0)      ;13
		MOVEM.L D0-D6/A1-A6,-(A0)      ;13
		MOVEM.L D0-D6/A1-A6,-(A0)      ;13
		MOVEM.L D0-D6/A1-A6,-(A0)      ;13
		MOVEM.L D0-D6/A1-A6,-(A0)      ;13
		MOVEM.L D0-D6/A1-A6,-(A0)      ;13
		MOVEM.L D0-D6/A1-A6,-(A0)      ;13
		MOVEM.L D0-D6/A1-A6,-(A0)      ;13
		MOVEM.L D0-D6/A1-A6,-(A0)      ;13
		MOVEM.L D0-D6/A1-A6,-(A0)      ;13
		MOVEM.L D0-D6/A1-A6,-(A0)      ;13
		MOVEM.L D0-D6/A1-A6,-(A0)      ;13
		MOVEM.L D0-D6/A1-A6,-(A0)      ;13
		MOVEM.L D0-D6/A1-A6,-(A0)      ;13
		MOVEM.L D0-D6/A1-A6,-(A0)      ;13
		MOVEM.L D0-D6/A1-A6,-(A0)      ;13
		MOVEM.L D0-D6/A1-A6,-(A0)      ;13
		MOVEM.L D0-D6/A1-A6,-(A0)      ;13
		MOVEM.L D0-D6/A1-A6,-(A0)      ;13
		MOVEM.L D0-D6/A1-A6,-(A0)      ;13
		MOVEM.L D0-D6/A1-A6,-(A0)      ;13
		MOVEM.L D0-D6/A1,-(A0)         ;8
		DBF D7,.lp
		RTS

fadein:		tst.b fadeinflag
		beq.s .endfade
		move.l fadein_pal_ptr(pc),a0
		move.l fadein_cur_ptr(pc),a1
		move.w fadein_tim(pc),d0
		move.w fadein_nocols(pc),d7
		subq #1,d7
.lp		bsr calc1
		move.w d3,(a1)+
		dbf d7,.lp
		addq #1,d0
		cmp #$11,d0
		bne.s .notendfade
		clr d0
		sf fadeinflag
.notendfade	move.w d0,fadein_tim
.endfade	rts

fadeout:	tst.b fadeoutflag
		beq.s .endfade
		move.l fadeout_pal_ptr(pc),a0
		move.l fadeout_cur_ptr(pc),a1
		moveq #$10,d0
		sub.w fadeout_tim(pc),d0
		move.w fadeout_nocols(pc),d7
		subq #1,d7
.lp		bsr calc1
		move.w d3,(a1)+
		dbf d7,.lp
		move.w fadeout_tim(pc),d0
		addq #1,d0
		cmp #$11,d0
		bne.s .notendfade
		clr d0
		sf fadeoutflag
.notendfade	move.w d0,fadeout_tim
.endfade	rts

calc1		move.w (a0)+,d1
		move.w d1,d2
		and #$007,d1
		mulu d0,d1
		lsr #4,d1
		move.w d1,d3
		move.w d2,d1
		and #$070,d1
		mulu d0,d1
		lsr #4,d1
		and #$070,d1
		or.w d1,d3
		and #$700,d2
		mulu d0,d2
		lsr #4,d2
		and #$700,d2
		or.w d2,d3
		rts

fadein_pal_ptr	dc.l 0
fadein_cur_ptr	dc.l 0
fadein_nocols	dc.w 0
fadein_tim	dc.w 0
fadeinflag:	dc.b 0
	
fadeout_pal_ptr:dc.l 0
fadeout_cur_ptr:dc.l 0
fadeout_nocols	dc.w 0
fadeout_tim	dc.w 0
fadeoutflag:	dc.b 0	


first_vbl	MOVE.L #my_vbl,$70.W
		MOVEM.L D0-D7/A0-A6,-(SP)
		IFNE demo
		JSR $504
		ENDC
		MOVEM.L (SP)+,D0-D7/A0-A6
		ADDQ #1,vbl_timer
		RTE

; My little VBL!

my_vbl		MOVEM.L D0-D7/A0-A6,-(SP)
		CLR.B $FFFFFA1B.W
		MOVE.B #199,$FFFFFA21.W
		MOVE.L #botbord,$120.W
		MOVE.B #8,$FFFFFA1B.W
		MOVE.B #12,$FFFFFA21.W
		MOVEM.L currpal(pc),D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		IFNE demo
		JSR $504
		ENDC
		BSR Do_bufscroll
		BSR fadein
		BSR fadeout
		MOVEM.L (SP)+,D0-D7/A0-A6
		ADDQ #1,vbl_timer
		RTE
currpal		DS.W 16
pal		DC.L $00000333
		DC.L $05550555
		DC.L $07770777
		DC.L $07770777
		DC.L $00050005
		DC.L $00050005
		DC.L $00050005
		DC.L $00050005


botbord		MOVEM.L A0/D7,-(SP)
		MOVE #$8209,A0
		MOVEQ #96,D7
.synca		CMP.B (A0),D7
		BEQ.S .synca
		MOVE.B (A0),D7
		JMP noplist1-96(PC,D7) 
noplist1	
		REPT 99
		NOP
		ENDR
		MOVE.B #0,$ffff820a.w
		REPT 8
		NOP
		ENDR
		MOVE.B #2,$ffff820a.w
		MOVE.L #scrollrast1,$120.W
		MOVEM.L (SP)+,A0/D7
		RTE

scrollrast1	MOVE.W #$223,$FFFF8250.W
		MOVE.W #$223,$FFFF8242.W
		CLR.B $FFFFFA1B.W
		MOVE.B #1,$FFFFFA21.W
		MOVE.B #8,$FFFFFA1B.W
		MOVE.L #scrollrast2,$120.W
		RTE
scrollrast2	MOVE.W #$224,$FFFF8250.W
		MOVE.W #$224,$FFFF8242.W
		MOVE.L #scrollrast3,$120.W
		RTE
scrollrast3	MOVE.W #$335,$FFFF8250.W
		MOVE.W #$335,$FFFF8242.W
		MOVE.L #scrollrast4,$120.W
		RTE
scrollrast4	MOVE.W #$336,$FFFF8250.W
		MOVE.W #$336,$FFFF8242.W
		MOVE.L #scrollrast5,$120.W
		RTE
scrollrast5	MOVE.W #$447,$FFFF8250.W
		MOVE.W #$447,$FFFF8242.W
		MOVE.L #scrollrast6,$120.W
		RTE
scrollrast6	MOVE.W #$557,$FFFF8250.W
		MOVE.W #$557,$FFFF8242.W
		MOVE.L #scrollrast7,$120.W
		RTE
scrollrast7	MOVE.W #$667,$FFFF8250.W
		MOVE.W #$667,$FFFF8242.W
		MOVE.L #scrollrast8,$120.W
		RTE
scrollrast8	MOVE.W #$777,$FFFF8250.W
		MOVE.W #$777,$FFFF8242.W
		MOVE.L #scrollrast9,$120.W
		RTE
scrollrast9	MOVE.W #$111,$FFFF8250.W
		MOVE.W #$111,$FFFF8242.W
		MOVE.L #scrollrast10,$120.W
		RTE
scrollrast10	MOVE.W #$222,$FFFF8250.W
		MOVE.W #$222,$FFFF8242.W
		MOVE.L #scrollrast11,$120.W
		RTE
scrollrast11	MOVE.W #$333,$FFFF8250.W
		MOVE.W #$333,$FFFF8242.W
		MOVE.L #scrollrast12,$120.W
		RTE
scrollrast12	MOVE.W #$444,$FFFF8250.W
		MOVE.W #$444,$FFFF8242.W
		MOVE.L #scrollrast13,$120.W
		RTE
scrollrast13	MOVE.W #$555,$FFFF8242.W 
		MOVE.W #$555,$FFFF8250.W 
		MOVE.L #scrollrast14,$120.W
		RTE
scrollrast14	MOVE.W #$666,$FFFF8242.W 
		MOVE.W #$666,$FFFF8250.W 
		MOVE.L #scrollrast15,$120.W
		RTE
scrollrast15	MOVE.W #$667,$FFFF8242.W 
		MOVE.W #$667,$FFFF8250.W 
		MOVE.L #scrollrast16,$120.W
		RTE
scrollrast16	MOVE.W #$777,$FFFF8242.W
		MOVE.W #$777,$FFFF8250.W
		CLR.B $FFFFFA1B.W
		RTE

vbl_timer	DS.W 1
log_base	DC.L 0
phy_base	DC.L 0

		DC.W -800,-640,-480,-320,-160 
i		SET 0
tmul_160	
		REPT 51
		DC.W i,i+160,i+320,i+480
i		SET i+640
		ENDR

;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;

; Routine to translate,perspect and draw the cube with vector types.
; (This rout is specifically done for a cube for extra speed...)

Show_object	BSR Matrix_make			;rotmat
		MOVEQ #8,D7			;no of verts
		MOVE (A5)+,addoffx+2
		MOVE (A5)+,addoffy+2
		MOVE (A5)+,offz
		LEA new_coords,A1		;new x,y co-ords
		BSR Trans_verts			;translate
.Draw_hidden_line_faces				; A0 -> no. of faces in shape data.
		LEA (A0),A5
		LEA tmul_160(PC),A3
		LEA new_coords(PC),A6		; ptr to translated coords
		MOVEQ #6-1,D7			; no of faces-1
.hidfacelp	MOVEM 4(A5),D4-D6		; 1st three vertice ptrs
		MOVEM (A6,D4),D1-D2		; x1,y1
		MOVEM (A6,D5),D3-D4		; x2,y2
		SUB D3,D1			; (x1-x2)
		SUB D4,D2			; (y1-y2)
		SUB (A6,D6),D3   		; (x2-x3)
		SUB 2(A6,D6),D4 		; (y2-y3)
		MULS D4,D1			; (x1-x2)*(y2-y3)
		MULS D2,D3			; (y1-y2)*(x2-x3)
		SUB.L D3,D1			; can face be seen?
		BMI .notseen		
		MOVE.L A5,A4		
		MOVE.L (A4)+,A0			; side rout addr
		MOVEM.L A3-A5/D7,-(SP)
		JSR (A0)			; call side rout addr
		MOVEM.L (SP)+,A3-A5/D7
		LEA new_coords(PC),A6		; ptr to translated coords
		MOVE.L log_base(PC),A1		; screen base
		ADDQ.L #6,A1			; lines are blue!!

		REPT 3				; Draw 3 lines of 4 sided poly.
		MOVE.W (A4)+,D2
		MOVE.W (A4),D3
		MOVEM.W (A6,D2),D0-D1		; x1,y1
		MOVEM.W (A6,D3),D2-D3		; x2,y2
		BSR Drawline			; draw line(x1,y1,x2,y2)
		ENDR
		MOVE.W (A4)+,D2		
		MOVE.W -8(A4),D3		; draw last line.
		MOVEM.W (A6,D2),D0-D1
		MOVEM.W (A6,D3),D2-D3
		BSR Drawline
.notseen	LEA 12(A5),A5			; onto next face.
		DBF D7,.hidfacelp
		RTS

;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;
; 	   The routines for each side of the cube... (6 sides!!) 	;
;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;

;-----------------------------------------------------------------------;
;  				Side 1  				;
;-----------------------------------------------------------------------;
; Left side of cube - Spinning Hidden line cube.

cubeside1:	LEA hcube(PC),A5
		ADD #12,(A5)
		ADD #14,2(A5)
		ADD #12,4(A5)
		BSR CMatrix_make		;rotmat
		MOVEQ #8,D7			;no of verts
		LEA hcubenewc1(PC),A1		;new x,y,z co-ords
		MOVE #-1024,A4
		BSR CTrans_verts		;translate
		LEA hcubenewc1(PC),A5		;source x,y,z	
		LEA hcubenewc2(PC),A1		;dest(translated)
		MOVEQ #8,D7
		BSR Trans_verts		
		LEA hcubeflist(PC),A5		; face list.(draw unhidden faces)
		LEA tmul_160(PC),A3
		LEA hcubenewc2(PC),A6		; translated coords!
		MOVEQ #6-1,D7			; no of faces-1
.hidfacelp	MOVEM (A5),D4-D6		; 1st three vertice ptrs
		MOVEM (A6,D4),D1-D2		; x1,y1
		MOVEM (A6,D5),D3-D4		; x2,y2
		SUB D3,D1			; (x1-x2)
		SUB D4,D2			; (y1-y2)
		SUB (A6,D6),D3   		; (x2-x3)
		SUB 2(A6,D6),D4 		; (y2-y3)
		MULS D4,D1			; (x1-x2)*(y2-y3)
		MULS D2,D3			; (y1-y2)*(x2-x3)
		SUB.L D3,D1			; can face be seen?
		BMI .notseen		
		MOVE.L A5,A4
		MOVE.L log_base(PC),A1		; screen base
		ADDQ.L #2,A1			; greyish lines!
		REPT 3				; Draw 3 lines of 4 sided poly.
		MOVE.W (A4)+,D2
		MOVE.W (A4),D3
		MOVEM.W (A6,D2),D0-D1		; x1,y1
		MOVEM.W (A6,D3),D2-D3		; x2,y2
		BSR Drawline			; draw line(x1,y1,x2,y2)
		ENDR
		MOVE.W (A4)+,D2		
		MOVE.W -8(A4),D3		; draw last line.
		MOVEM.W (A6,D2),D0-D1
		MOVEM.W (A6,D3),D2-D3
		BSR Drawline
.notseen	LEA 8(A5),A5			; onto next face.
		DBF D7,.hidfacelp
		RTS
hcube		DC.W 0,0,0
		DC.W -610,-610,-610
		DC.W 610,-610,-610
		DC.W 610,-610,610
		DC.W -610,-610,610
		DC.W -610,610,-610
		DC.W 610,610,-610
		DC.W 610,610,610
		DC.W -610,610,610
hcubeflist	DC.W 00*4,01*4,02*4,03*4
		DC.W 01*4,05*4,06*4,02*4
		DC.W 02*4,06*4,07*4,03*4
		DC.W 05*4,04*4,07*4,06*4
		DC.W 00*4,04*4,05*4,01*4
		DC.W 00*4,03*4,07*4,04*4
hcubenewc1	DS.W 3*8
hcubenewc2	DS.W 2*8

;-----------------------------------------------------------------------;
;				Side 4  				;
;-----------------------------------------------------------------------;
; Right Side of the Cube - Spinning Hidden line pyramid.

cubeside4:	LEA hpyramid(PC),A5
		ADD #12,(A5)
		ADD #18,2(A5)			;spin it!
		ADD #16,4(A5)
		BSR CMatrix_make		;rotmat
		MOVEQ #5,D7			;no of verts
		LEA hpyrnewc1(PC),A1		;new x,y,z co-ords
		MOVE #1024,A4
		BSR CTrans_verts		;translate
		LEA hpyrnewc1(PC),A5		;source x,y,z	
		LEA hpyrnewc2(PC),A1		;dest(translated)
		MOVEQ #5,D7
		BSR Trans_verts		
		LEA hpyrflist(PC),A5		; face list. (now draw unhidden faces)
		LEA bit_offs,A2			;
		LEA tmul_160(PC),A3		; scr line lookup
		LEA hpyrnewc2(PC),A6		; translated coords!
		MOVEQ #5-1,D7			; no of faces-1
.hidfacelp	MOVE.W (A5)+,D0			; no. of verts in this 'poly'
		MOVEM (A5),D4-D6		; 1st three vertice ptrs
		MOVEM (A6,D4),D1-D2		; x1,y1
		MOVEM (A6,D5),D3-D4		; x2,y2
		SUB D3,D1			; (x1-x2)
		SUB D4,D2			; (y1-y2)
		SUB (A6,D6),D3   		; (x2-x3)
		SUB 2(A6,D6),D4 		; (y2-y3)
		MULS D4,D1			; (x1-x2)*(y2-y3)
		MULS D2,D3			; (y1-y2)*(x2-x3)
		SUB.L D3,D1			; can face be seen?
		BMI .notseen		
		MOVE.L A5,A4
		MOVE.L log_base(PC),A1		; screen base
		ADDQ.L #2,A1			; greyish lines!
		CMP #4,D0
		BEQ.S .case4sides  
.case3sides	
		REPT 2				; Draw 2 lines of 3 sided poly.
		MOVE.W (A4)+,D2
		MOVE.W (A4),D3
		MOVEM.W (A6,D2),D0-D1		; x1,y1
		MOVEM.W (A6,D3),D2-D3		; x2,y2
		BSR Drawline			; draw line(x1,y1,x2,y2)
		ENDR
		MOVE.W (A4)+,D2		
		MOVE.W -6(A4),D3		; draw last line.
		MOVEM.W (A6,D2),D0-D1
		MOVEM.W (A6,D3),D2-D3
		BSR Drawline
		LEA 6(A5),A5
		DBF D7,.hidfacelp
		RTS
.case4sides	
		REPT 3				; Draw 3 lines of 4 sided poly.
		MOVE.W (A4)+,D2
		MOVE.W (A4),D3
		MOVEM.W (A6,D2),D0-D1		; x1,y1
		MOVEM.W (A6,D3),D2-D3		; x2,y2
		BSR Drawline			; draw line(x1,y1,x2,y2)
		ENDR
		MOVE.W (A4)+,D2		
		MOVE.W -8(A4),D3		; draw last line.
		MOVEM.W (A6,D2),D0-D1
		MOVEM.W (A6,D3),D2-D3
		BSR Drawline
		LEA 8(A5),A5
		DBF D7,.hidfacelp
		RTS
.notseen	ADD D0,D0			; skip list.
		ADD D0,A5			; -> next face
		DBF D7,.hidfacelp
		RTS
hpyramid	DC.W 0,0,0			;5
		DC.W -650,-650,-650
		DC.W 650,-650,-650
		DC.W 650,-650,650
		DC.W -650,-650,650
		DC.W 0,650,0
hpyrflist	DC.W 4,03*4,02*4,01*4,00*4
		DC.W 3,00*4,01*4,04*4
		DC.W 3,01*4,02*4,04*4
		DC.W 3,02*4,03*4,04*4
		DC.W 3,03*4,00*4,04*4
hpyrnewc1	DS.W 3*5
hpyrnewc2	DS.W 2*5


;-----------------------------------------------------------------------;
;  				Side 2  				;
;-----------------------------------------------------------------------;
; Bottom of cube - 91 logo spinning on it

NOverts		EQU 19

cubeside2:	LEA NOxycoords(PC),A0		; 2d xy coords
		LEA trig_tab,A1			; sine
		LEA 512(A1),A2			; cosine
		LEA NOxyzcoords(PC),A3		; new xyz coords
		MOVE.W NOang(PC),D0
		SUB #24,D0
		AND #$7FE,D0
		MOVE.W D0,NOang
		MOVE.W (A1,D0),D2		; sine
		MOVE.W (A2,D0),D3		; cosine
		MOVE.W #1024,D6
		MOVEQ #NOverts-1,D7
.rotatexlp	MOVEM.W (A0)+,D0/D1		; x/y coord
		MOVE.W D6,(A3)+			; x=-1024
		MOVE.W D0,D4
		MOVE.W D1,D5
		MULS D3,D4			; cos*xold
		MULS D2,D5			; sin*yold
		SUB.L D5,D4
 		ADD.L D4,D4
		SWAP D4				; XNEW
		MOVE.W D4,(A3)+			; store X as Y in 3d
		MULS D2,D0			; sin*xold
		MULS D3,D1			; cos*yold
		ADD.L D0,D1
		ADD.L D1,D1
		SWAP D1
		MOVE.W D1,(A3)+			; store Y as Z in 3d
		DBF D7,.rotatexlp
		LEA NOcoordstrn(pc),A1		; translated co-ords
		LEA NOxyzcoords(PC),A5		; new xyz coords
		MOVEQ #NOverts,D7
		BSR Trans_verts			; translated 'em
		MOVE.W (A0)+,-(SP)
		MOVE.W #3*2,col
.plp		LEA NOcoordstrn(pc),A1		;
		MOVE.W (A0)+,D7
		BSR Draw_poly			; draw obj
		MOVE.L USP,A0
		SUBQ #1,(SP)
		BNE.S .plp		
 		ADDQ.L #2,SP
		RTS
NOang		DC.W 0
NOcoordstrn	DS.L NOverts
NOxycoords	DC.W -540,540 ;00
		DC.W -180,540 ;01
		DC.W 0,360    ;02
		DC.W 0,0      ;03
		DC.W -540,0   ;04      ;9
		DC.W -720,180 ;05
		DC.W -720,360 ;06
		DC.W -342,0   ;07
		DC.W -198,-306;08
		DC.W -450,-360;09
		DC.W -540,-540;10
		DC.W 180,180  ;11
		DC.W 540,540  ;12
		DC.W 540,180  ;13	
		DC.W 360,180  ;14      ;1
		DC.W 540,-360 ;15
		DC.W 360,-360 ;16
		DC.W 720,-540 ;17
		DC.W 180,-540 ;18	
NOxyzcoords	DS.W 3*NOverts
		DC.W 6
		DC.W 7,00*4,01*4,02*4,03*4,04*4,05*4,06*4
		DC.W 4,07*4,03*4,08*4,09*4
		DC.W 3,09*4,08*4,10*4
		DC.W 3,11*4,12*4,13*4
		DC.W 4,14*4,13*4,15*4,16*4
		DC.W 4,16*4,15*4,17*4,18*4

;-----------------------------------------------------------------------;
;  				Side 6  				;
;-----------------------------------------------------------------------;
; Top of cube - IC logo spinning on it...

cubeside6:	LEA ICxycoords(PC),A0		; 2d xy coords
		LEA trig_tab,A1			; sine
		LEA 512(A1),A2			; cosine
		LEA ICxyzcoords(PC),A3		; new xyz coords
		MOVE.W ICang(PC),D0
		ADD #24,D0
		AND #$7FE,D0
		MOVE.W D0,ICang
		MOVE.W (A1,D0),D2		; sine
		MOVE.W (A2,D0),D3		; cosine
		MOVE.W #-1024,D6
		MOVEQ #22-1,D7
.rotatexlp	MOVEM.W (A0)+,D0/D1		; x/y coord
		MOVE.W D6,(A3)+			; x=-1024
		MOVE.W D0,D4
		MOVE.W D1,D5
		MULS D3,D4			; cos*xold
		MULS D2,D5			; sin*yold
		SUB.L D5,D4
 		ADD.L D4,D4
		SWAP D4				; XNEW
		MOVE.W D4,(A3)+			; store X as Y in 3d
		MULS D2,D0			; sin*xold
		MULS D3,D1			; cos*yold
		ADD.L D0,D1
		ADD.L D1,D1
		SWAP D1
		MOVE.W D1,(A3)+			; store Y as Z in 3d
		DBF D7,.rotatexlp
		LEA ICcoordstrn(pc),A1		; translated co-ords
		LEA ICxyzcoords(PC),A5		; new xyz coords
		MOVEQ #22,D7
		BSR Trans_verts			; translated 'em
		MOVE.W (A0)+,-(SP)
		MOVE.W #3*2,col
.plp		LEA ICcoordstrn(pc),A1		;
		MOVEQ #4,D7
		BSR Draw_poly			; draw obj
		MOVE.L USP,A0	
		SUBQ #1,(SP)
		BNE.S .plp		
 		ADDQ.L #2,SP
		RTS
ICang		DC.W 0
ICcoordstrn	DS.L 22
ICxycoords	DC.W -735,600			;00
		DC.W 0,600			;01	
		DC.W -221,450			;02
		DC.W -515,450			;03
		DC.W -515,-450			;04     I
		DC.W -221,-450			;05
		DC.W 0,-600			;06
		DC.W -735,-600			;07
		DC.W 147,600			;08
		DC.W 735,600			;09
		DC.W 441,450			;10
		DC.W 0,450			;11
		DC.W 294,450			;12
		DC.W 0,300			;13
		DC.W 221,300			;14	 C
		DC.W 0,-300			;15
		DC.W 221,-300			;16
		DC.W 0,-450			;17
		DC.W 294,-450			;18
		DC.W 441,-450			;19
		DC.W 147,-600			;20
		DC.W 735,-600 			;21
ICxyzcoords	DS.W 3*22
		DC.W 8
		DC.W 03*4,02*4,01*4,00*4
		DC.W 07*4,06*4,05*4,04*4 	;I
		DC.W 02*4,03*4,04*4,05*4
		DC.W 11*4,10*4,09*4,08*4
		DC.W 13*4,14*4,12*4,11*4
		DC.W 17*4,18*4,16*4,15*4 	;C
		DC.W 15*4,16*4,14*4,13*4
		DC.W 20*4,21*4,19*4,17*4

;-----------------------------------------------------------------------;
;  				Side 5 					;
;-----------------------------------------------------------------------;
; Front of cube - This is a sideways starfield.(with 3, 12 star layers...)

cubeside5:	LEA side1starcoordsxy(PC),A0
		LEA side1starcoordsxyz(PC),A1
		MOVE.W #$7FF,D1
		MOVE #-1024,D2
		MOVEQ #24,D0
		BSR do1starf
		MOVEQ #48,D0
		BSR do1starf
		MOVEQ #96,D0
		BSR do1starf
		LEA side1starcoordstrs(PC),A1	; translated star coords
		LEA side1starcoordsxyz(PC),A5	; x,y,z star co-ords
		MOVEQ #33,D7
		BSR Trans_verts
		LEA side1starcoordstrs(PC),A0	; translated star coords
		BRA.W phdraw_stars		; and draw 'em

do1starf	
		REPT 11
		MOVE.W (A0),D4
		ADD.W D0,D4
		AND.W D1,D4
		MOVE.W D4,(A0)+
		ADD D2,D4			; range -1024 to 1024
		MOVE.W D4,(A1)+
		MOVE.W (A0)+,(A1)+
		MOVE.W D2,(A1)+			; Z=-1024
		ENDR
		RTS
side1starcoordsxy:  DS.W 33*2
side1starcoordsxyz: DS.W 33*3
side1starcoordstrs: DS.W 33*2

;-----------------------------------------------------------------------;
;				Side 3  				;
;-----------------------------------------------------------------------;
; Back of cube - This is a sideways starfield.(with 3, 12 star layers...)
 
cubeside3:	LEA side2starcoordsxy(PC),A0
		LEA side2starcoordsxyz(PC),A1
		MOVE.W #$7FF,D1
		MOVE #1024,D2
		MOVEQ #24,D0
		BSR do2starf
		MOVEQ #48,D0
		BSR do2starf
		MOVEQ #96,D0
		BSR do2starf
		LEA side2starcoordstrs(PC),A1	; translated star coords
		LEA side2starcoordsxyz(PC),A5	; x,y,z star co-ords
		MOVEQ #33,D7
		BSR Trans_verts
		LEA side2starcoordstrs(PC),A0	; translated star coords
phdraw_stars	MOVE.L log_base(PC),A1
		LEA tmul_160(PC),A2
		LEA bit_offs,A3
		MOVEQ #3-1,D4			; draw 3 planes of stars
.draw_lp2s2	
		REPT 11
		MOVEM.W (A0)+,D0-D1
		ADD D0,D0
		ADD D0,D0
		MOVE.L (A3,D0),D0
		MOVE.L D0,D2
		ADD.W D1,D1			; plot 1 plane of stars
		ADD.W (A2,D1),D0		
		SWAP D2
		OR.W D2,(A1,D0)
		ENDR
		ADDQ.L #2,A1			; onto next plane
		DBF D4,.draw_lp2s2
		RTS
do2starf	
		REPT 11
		MOVE.W (A0),D4
		ADD.W D0,D4
		AND.W D1,D4
		MOVE.W D4,(A0)+
		SUB D2,D4			; range -1024 to 1024
		MOVE.W D4,(A1)+
		MOVE.W (A0)+,(A1)+
		MOVE.W D2,(A1)+			; Z=-1024
		ENDR	
		RTS
side2starcoordsxy:  DS.W 33*2
side2starcoordsxyz: DS.W 33*3
side2starcoordstrs: DS.W 33*2

; Translation routine for objects on sides of cube...

; Create translation matrix, from the angle data pointed by A5.

CMatrix_make
		LEA trig_tab,A0			;sine table
		LEA 512(A0),A2			;cosine table
		MOVEM.W (A5)+,D5-D7    	
		AND #$7FE,D5
		AND #$7FE,D6
		AND #$7FE,D7
		MOVE (A0,D5),D0			;sin(xd)
		MOVE (A2,D5),D1			;cos(xd)
		MOVE (A0,D6),D2			;sin(yd)
		MOVE (A2,D6),D3			;cos(yd)
		MOVE (A0,D7),D4			;sin(zd)
		MOVE (A2,D7),D5			;cos(zd)
		LEA CM11+2(PC),A1
		MOVE D0,D6			;sinx
		MULS D4,D6			;sinz*sinx
		ADD.L D6,D6
		SWAP D6
		MOVE D6,A3
		MOVE D1,D6			;cosx
		MULS D4,D6			;sinz*cosx
		ADD.L D6,D6
		SWAP D6
		MOVE D6,A4
		MOVE D3,D6			;cosy
		MULS D1,D6			;cosy*cosx
		MOVE A3,D7			;sinz*sinx
		MULS D2,D7			;siny*sinz*sinx					
		SUB.L D7,D6
		ADD.L D6,D6
		SWAP D6			
		MOVE D6,(A1)
		MOVE D2,D6
		MULS D1,D6			;siny*cosx
		MOVE A3,D7			;sinz*sinx
		MULS D3,D7			;cosy*sinz*sinx			
		ADD.L D7,D6
		ADD.L D6,D6
		SWAP D6			
		MOVE D6,CM21-CM11(A1)
		MOVE D5,D6			;cosz
		MULS D0,D6			;cosz*sinx
		ADD.L D6,D6
		SWAP D6
		NEG D6				;-cosz*sinx
		MOVE D6,CM31-CM11(A1)
		MOVE D2,D6			;siny
		MULS D5,D6			;siny*cosz
		ADD.L D6,D6
		SWAP D6
		NEG D6				;-siny*cosz
		MOVE D6,CM12-CM11(A1)
		MOVE D3,D6			;cosy
		MULS D5,D6			;cosy*cosz
		ADD.L D6,D6
		SWAP D6
		MOVE D6,CM22-CM11(A1)
		MOVE D4,CM32-CM11(A1)
		MOVE D3,D6			;cosy
		MULS D0,D6			;cosy*sinx
		MOVE A4,D7			;sinz*cosx
		MULS D2,D7
		ADD.L D7,D6
		ADD.L D6,D6
		SWAP D6				;siny*(sinz*cosx)
		MOVE D6,CM13-CM11(A1)
		MULS D0,D2			;siny*sinx
		MOVE A4,D7
		MULS D3,D7
		SUB.L D7,D2 
		ADD.L D2,D2
		SWAP D2
		MOVE D2,CM23-CM11(A1)
		MULS D1,D5 
		ADD.L D5,D5
		SWAP D5				;cosz*cosx
		MOVE D5,CM33-CM11(A1)
		RTS				

; Translate and perspect co-ords. A5 -> D7.W x,y,z.w co-ords to translate.

CTrans_verts	LEA perstab+$A00,A6
		SUBQ #1,D7			;verts-1
Ctrans_lp	MOVEM.W (A5)+,D0-D2		;x,y,z
		MOVE D0,D3	
		MOVE D1,D4			;dup
		MOVE D2,D5
* Calculate x co-ordinate		
CM11		MULS #0,D0			
CM21		MULS #0,D4			;mat mult
CM31		MULS #0,D5
		ADD.L D4,D0
		ADD.L D5,D0
		MOVE D3,D6
		MOVE D1,D4
		MOVE D2,D5
* Calculate y co-ordinate		
CM12		MULS #0,D3
CM22		MULS #0,D1			;mat mult
CM32		MULS #0,D5
		ADD.L D3,D1
		ADD.L D5,D1
* Calculate z co-ordinate
CM13		MULS #0,D6
CM23		MULS #0,D4			;mat mult
CM33		MULS #0,D2
		ADD.L D6,D2
		ADD.L D4,D2
* Combine and Perspect. 
		ADD.L D0,D0
		ADD.L D1,D1
		ADD.L D2,D2
		SWAP D0
		SWAP D1
		SWAP D2
		ADD D2,D2
		MOVE (A6,D2),D2
		MULS D2,D0
		MULS D2,D1
		ADD.L D0,D0
		ADD.L D1,D1
		SWAP D0
		SWAP D1
		MOVE D0,(A1)+			;new x co-ord
		MOVE A4,(A1)+			;force to y plane
		MOVE D1,(A1)+			;new Z co-ord
		DBF D7,Ctrans_lp
		RTS

;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;

; General translation / line drawers / poly fillers etc...

new_coords	DS.W 50*2	
p_space		DS.W 100      

; Heres The 3D Sequencer!
; commands 0 - Set new object, initial offset X,Y,Z .Ws 
;	       View angles ptr.L Offsets ptr.L(in object to sequence!)
;          1 - Set X,Y and Z Rotation speeds and X,Y,Z offset adds.
; 	       TIMER (.W) X,Y,Z rot vals (.W) X,Y,Z offset (.W)
;          2 = Sets a Waveform to be added to X,Y,Z centres each update.
;	       Waveform size .W (in bytes),Initial offset .W
;              Waveform ptr.L
;          3 = Stop Waveform - no parameters
;          4 - Restart Sequence

SetNewObj	EQU 0*4
SetXYZstuff	EQU 1*4
SetWaveformON	EQU 2*4
SetWaveformOFF	EQU 3*4
SetRestart	EQU 4*4
SetFadeDown	EQU 5*4

		RSRESET
Seq_ptr		RS.L 1			; Ptr to Sequence!
Restart_ptr	RS.L 1			; Ptr to Place to Restart Seq.
Seq_Timer	RS.W 1			; Sequence Timer
Object_ptrA	RS.L 1			; Ptr to Object (angles)
Object_ptrO	RS.L 1			; Ptr to Object (offsets)
OffsetXYZ	RS.W 0
OffsetX		RS.W 1			; Offset X
OffsetY		RS.W 1			;    "   Y
OffsetZ		RS.W 1			;    "   Z
XYZang		RS.W 0
Xang		RS.W 1			;
Yang		RS.W 1			; Current View Angles (X,Y,Z)
Zang		RS.W 1			;
XYZadd		RS.W 0
Xadd		RS.W 1			; X rotation addition 
Yadd		RS.W 1			; Y rotation    "
Zadd		RS.W 1                  ; Z rotation    "
XYZaddOffset	RS.W 0
XaddOffset	RS.W 1			; X offset addition
YaddOffset	RS.W 1			; Y offset addition
ZaddOffset	RS.W 1			; Z offset addition
Waveform_flag	RS.W 1			; Waveform Flag(0=no wave <>0 wave)
Waveform_ptr	RS.L 1			; Waveform base PTR
Waveform_offptr	RS.W 1			; offset in Waveform
Waveform_Size	RS.W 1                  ; Size(in bytes) of waveform

SeqStrucSize	RS.B 1			; size of struc

; Initialise Sequence... A0-> Sequence Data A1-> Restart Data.

Init_Seq	LEA SeqStructure(PC),A5
		MOVE.L A0,Seq_ptr(A5)
		MOVE.L A1,Restart_ptr(A5)
		RTS

; This is the sequencer - Call once every object update.

Do_Sequence	LEA SeqStructure(PC),A5
		SUBQ #1,Seq_Timer(A5)
		BGT.S seqdone
		MOVE.L Seq_ptr(A5),A0	; get seq ptr
morethisframe	MOVE.W (A0)+,D0		; get next command in sequence
		JMP .SeqCommandList(PC,D0.W)
.SeqCommandList	BRA.W SetNewObject	; init new object.
		BRA.W SetXYZ_addStuff	; set movement vals(rot+offset)
		BRA.W SetWaveform_ON
		BRA.W SetWaveform_OFF
		BRA.W Restart_Seq	; restart sequence
		BRA.W Set_FadeDown

endthisframe:	MOVE.L A0,Seq_ptr(A5)	; store seq ptr.
seqdone		MOVEM XYZaddOffset(A5),D0-D2
		ADD.W D0,OffsetX(A5)
		ADD.W D1,OffsetY(A5)	; update offsets!
		ADD.W D2,OffsetZ(A5)
		MOVEM XYZadd(A5),D0-D2
		ADD.W D0,Xang(A5)
		ADD.W D1,Yang(A5)	; update view angles!
		ADD.W D2,Zang(A5)
		MOVE.L Object_ptrA(A5),A1  
		MOVEM XYZang(A5),D0-D2
		MOVEM D0-D2,(A1)	; store view angs in object
		MOVEM OffsetXYZ(A5),D0-D2
		TST.B Waveform_flag(A5)
		BEQ.S .noaddwaveform
		MOVE.L Waveform_ptr(A5),A1
		MOVE.W Waveform_offptr(A5),D3
		MOVEM.W (A1,D3),D4-D6
		ADD.W D4,D0
		ADD.W D5,D1		; update offsets!
		ADD.W D6,D2
		ADDQ #6,D3
		CMP.W Waveform_Size(A5),D3
		BNE.S .nowrapwaveform
		CLR D3
.nowrapwaveform	MOVE.W D3,Waveform_offptr(A5)
.noaddwaveform	MOVE.L Object_ptrO(A5),A1  
		MOVEM D0-D2,(A1)	; store view offsets in object 
		RTS

; Set New Object initial X,Y,Z offsets, X,Y,Z angles,Obj Angle/offset ptrs.

SetNewObject	MOVE.W (A0)+,OffsetX(A5)
		MOVE.W (A0)+,OffsetY(A5)
		MOVE.W (A0)+,OffsetZ(A5)
		MOVE.W (A0)+,Xang(A5)
		MOVE.W (A0)+,Yang(A5)
		MOVE.W (A0)+,Zang(A5)
		MOVE.L (A0)+,Object_ptrA(A5)
		MOVE.L (A0)+,Object_ptrO(A5)
		BRA.W morethisframe	

; Set X,Y,Z rotation speed and offset movement speeds.

SetXYZ_addStuff	MOVE.W (A0)+,Seq_Timer(A5)
		MOVE.W (A0)+,Xadd(A5)
		MOVE.W (A0)+,Yadd(A5)
		MOVE.W (A0)+,Zadd(A5)
		MOVE.W (A0)+,XaddOffset(A5)
		MOVE.W (A0)+,YaddOffset(A5)
		MOVE.W (A0)+,ZaddOffset(A5)
		BRA.W endthisframe		

; Set a waveform on e.g values to be added each update to X,Y,Z.

SetWaveform_ON	MOVE.W (A0)+,Waveform_Size(A5)
		MOVE.W (A0)+,Waveform_offptr(A5)
		MOVE.L (A0)+,Waveform_ptr(A5)
		ST Waveform_flag(A5)
		BRA.W morethisframe	

; Set a waveform off...

SetWaveform_OFF	SF Waveform_flag(A5)
		BRA.W morethisframe	

; Restart the Sequence

Restart_Seq	MOVE.L Restart_ptr(A5),A0
		ST.B demo_finished
		BRA.W endthisframe		

Set_FadeDown	MOVE.L #pal,fadeout_pal_ptr
		MOVE.L #currpal,fadeout_cur_ptr
		MOVE.W #16,fadeout_nocols
		ST fadeoutflag
		BRA.W morethisframe	

SeqStructure	DS.B SeqStrucSize


;-----------------------------------------------------------------------;
;   Calculate a translation matrix, from the angle data pointed by A5.	;
;-----------------------------------------------------------------------;

Matrix_make	LEA trig_tab,A0			;sine table
		LEA 512(A0),A2			;cosine table
		MOVEM.W (A5)+,D5-D7    	
		AND #$7FE,D5
		AND #$7FE,D6
		AND #$7FE,D7
		MOVE (A0,D5),D0			;sin(xd)
		MOVE (A2,D5),D1			;cos(xd)	
		MOVE (A0,D6),D2			;sin(yd)
		MOVE (A2,D6),D3			;cos(yd)
		MOVE (A0,D7),D4			;sin(zd)
		MOVE (A2,D7),D5			;cos(zd)
		LEA M11+2(PC),A1
* sinz*sinx(used twice) - A3
		MOVE D0,D6			;sinx
		MULS D4,D6			;sinz*sinx
		ADD.L D6,D6
		SWAP D6
		MOVE D6,A3
* sinz*cosx(used twice) - A4
		MOVE D1,D6			;cosx
		MULS D4,D6			;sinz*cosx
		ADD.L D6,D6
		SWAP D6
		MOVE D6,A4
* Matrix(1,1) cosy*cosx-siny*sinz*sinx
		MOVE D3,D6			;cosy
		MULS D1,D6			;cosy*cosx
		MOVE A3,D7			;sinz*sinx
		MULS D2,D7			;siny*sinz*sinx					
		SUB.L D7,D6
		ADD.L D6,D6
		SWAP D6			
		MOVE D6,(A1)
* Matrix(2,1) siny*cosx+cosy*sinz*sinx 
		MOVE D2,D6
		MULS D1,D6			;siny*cosx
		MOVE A3,D7			;sinz*sinx
		MULS D3,D7			;cosy*sinz*sinx			
		ADD.L D7,D6
		ADD.L D6,D6
		SWAP D6			
		MOVE D6,M21-M11(A1)
* Matrix(3,1) -cosz*sinx
		MOVE D5,D6			;cosz
		MULS D0,D6			;cosz*sinx
		ADD.L D6,D6
		SWAP D6
		NEG D6				;-cosz*sinx
		MOVE D6,M31-M11(A1)
* Matrix(1,2) -siny*cosz
		MOVE D2,D6			;siny
		MULS D5,D6			;siny*cosz
		ADD.L D6,D6
		SWAP D6
		NEG D6				;-siny*cosz
		MOVE D6,M12-M11(A1)
* Matrix(2,2) cosy*cosz		
		MOVE D3,D6			;cosy
		MULS D5,D6			;cosy*cosz
		ADD.L D6,D6
		SWAP D6
		MOVE D6,M22-M11(A1)
* Matrix(3,2) sinz 
		MOVE D4,M32-M11(A1)
* Matrix(1,3) cosy*sinx+siny*sinz*cosx
		MOVE D3,D6			;cosy
		MULS D0,D6			;cosy*sinx
		MOVE A4,D7			;sinz*cosx
		MULS D2,D7
		ADD.L D7,D6
		ADD.L D6,D6
		SWAP D6				;siny*(sinz*cosx)
		MOVE D6,M13-M11(A1)
* Matrix(2,3) siny*sinx-cosy*sinz*cosx
		MULS D0,D2			;siny*sinx
		MOVE A4,D7
		MULS D3,D7
		SUB.L D7,D2 
		ADD.L D2,D2
		SWAP D2
		MOVE D2,M23-M11(A1)
* Matrix(3,3) cosz*cosx
		MULS D1,D5 
		ADD.L D5,D5
		SWAP D5				;cosz*cosx
		MOVE D5,M33-M11(A1)
		RTS				
offz		DC.W 0

; Translate and perspect co-ords. A5 -> D7.W x,y,z.w co-ords to translate.
; Returns A0 pointing to 'no of faces' in object data.

Trans_verts	LEA multable-((dist+1)*2),A6
		MOVE.W offz(PC),D0
		ADD D0,D0
		ADD D0,A6			;offset
		MOVE #160,A3			;centre x
		MOVE #100,A4			;centre y
		SUBQ #1,D7			;verts-1
		LEA (A5),A0
trans_lp	MOVEM.W (A0)+,D0-D2		;x,y,z
		MOVE D0,D3	
		MOVE D1,D4			;dup
		MOVE D2,D5
* Calculate x co-ordinate		
M11		MULS #0,D0			
M21		MULS #0,D4			;mat mult
M31		MULS #0,D5
		ADD.L D4,D0
		ADD.L D5,D0
		MOVE D3,D6
		MOVE D1,D4
		MOVE D2,D5
* Calculate y co-ordinate		
M12		MULS #0,D3
M22		MULS #0,D1			; mat mult
M32		MULS #0,D5
		ADD.L D3,D1
		ADD.L D5,D1
* Calculate z co-ordinate
M13		MULS #0,D6
M23		MULS #0,D4			; mat mult
M33		MULS #0,D2
		ADD.L D6,D2
		ADD.L D4,D2
		ADD.L D0,D0
		ADD.L D1,D1
		ADD.L D2,D2
		SWAP D0
		SWAP D1
		SWAP D2
addoffx		ADD.W #0,D0
addoffy		ADD.W #0,D1
		ADD D2,D2			; now perspect
		MOVE (A6,D2),D2
		MULS D2,D0
		MULS D2,D1
		ADD.L D0,D0
		ADD.L D1,D1
		SWAP D0
		SWAP D1
		ADD A3,D0			; x scr centre
		ADD A4,D1			; y scr centre
		MOVE D0,(A1)+			; new x co-ord
		MOVE D1,(A1)+			; new y co-ord
		DBF D7,trans_lp
		RTS

cube		DC.W 0,0,0
		DC.W 0,0,$1330
		DC.W -1024,-1024,-1024
		DC.W 1024,-1024,-1024
		DC.W 1024,-1024,1024
		DC.W -1024,-1024,1024
		DC.W -1024,1024,-1024
		DC.W 1024,1024,-1024
		DC.W 1024,1024,1024
		DC.W -1024,1024,1024
		DC.L cubeside1
		DC.W 03*4,02*4,01*4,00*4
		DC.L cubeside2
		DC.W 02*4,06*4,05*4,01*4
		DC.L cubeside3
		DC.W 03*4,07*4,06*4,02*4
		DC.L cubeside4
		DC.W 06*4,07*4,04*4,05*4
		DC.L cubeside5
		DC.W 01*4,05*4,04*4,00*4
		DC.L cubeside6
		DC.W 04*4,07*4,03*4,00*4

;-----------------------------------------------------------------------;
; Routine to draw a 1 plane line,the line is clipped if necessary.	;
; D0-D3 holds x1,y1/x2,y2 A1 -> screen base. A2 -> x bit+chunk lookup	;
; D0-D6/A0 smashed.       A3 -> * 160 table					;
;-----------------------------------------------------------------------;

nodraw		RTS

Drawline	MOVE.L A1,A0
cliponx		CMP.W D0,D2			; CLIP ON X				
		BGE.S x2big
		EXG D0,D2			; reorder
		EXG D1,D3
x2big		MOVE.W D2,D4
		SUB.W D0,D4			; dx
		MOVE.W D3,D5
		SUB.W D1,D5			; dy
		ADD D2,D2
		ADD D2,D2
		LEA bit_offs,a2
		MOVE.L (A2,D2),D6		; mask/chunk offset
		ADD D3,D3
		ADD (A3,D3),D6			; add scr line
		ADDA.W D6,A0			; a0 -> first chunk of line
		SWAP D6				; get mask
		MOVE.W #-160,D3
		TST.W D5			; draw from top to bottom?
		BGE.S bottotop
		NEG.W D5			; no so negate vals
		NEG.W D3
bottotop	CMP.W D4,D5			; dy>dx?
		BLT.S dxbiggerdy

; DY>DX Line drawing case

dybiggerdx	MOVE.W D5,D1			; yes!
		BEQ nodraw			; dy=0 nothing to draw(!)
		ASR.W #1,D1			; e=2/dy
		MOVE.W D5,D2
		SUBQ.W #1,D2			; lines to draw-1(dbf)
.lp		OR.W D6,(A0)
		ADDA.W D3,A0
		SUB.W D4,D1
		BGT.S .nostep
		ADD.W D5,D1
		ADD.W D6,D6
		DBCS D2,.lp
		BCC.S .drawn
		SUBQ.W #8,A0
		MOVEQ #1,D6
.nostep		DBF D2,.lp
.drawn		OR.W D6,(A0)
		RTS

; DX>DY Line drawing case

dxbiggerdy	CLR.W D2
		MOVE.W D4,D1
		ASR.W #1,D1				; e=2/dx
		MOVE.W D4,D0
		SUBQ.W #1,D0
.lp		OR.W D6,D2
		SUB.W D5,D1
		BGE.S .nostep
		OR.W D2,(A0)
		ADDA.W D3,A0
		ADD.W D4,D1
		CLR.W D2
.nostep		ADD.W D6,D6
		DBCS D0,.lp
		BCC.S .drawn
.wrchnk		OR.W D2,(A0)
		SUBQ.W #8,A0
		CLR.W D2
		MOVEQ #1,D6
		DBF D0,.lp
.drawn		OR.W D2,(A0)
		RTS


;----------------------------- Polyfill --------------------------------;
; A0 points to D7 coords,taken from the translated co-ords -> a1	;
; Polygon drawn in colour "col".(This is a 1 plane polygon fastfiller!) ;
;-----------------------------------------------------------------------;

Draw_poly	LEA p_space(PC),A2
		MOVE.L A2,A5
		MOVE D7,D0
		SUBQ #1,D7
dup_lp1		MOVE (A0)+,D2
		MOVE.L (A1,D2),(A2)+
		DBF D7,dup_lp1
		MOVE.L A0,USP
Polyfill	MOVE D0,D4
		ADD D4,D4
		ADD D4,D4
		MOVE.L A5,A1
		ADDA.W D4,A1
		MOVE.L A1,A2
		ADDA.W D4,A2
Init_coords	SUBQ #2,D0
		MOVE.L (A5)+,D7
		MOVE D7,D2
		MOVE.L A1,A4
		MOVE.L D7,(A1)+
		MOVE.L D7,(A2)+
coord_lp	MOVE.L (A5)+,D3
		CMP D2,D3
		BGE.S not_top
		MOVE D3,D2
		MOVE.L A1,A4
not_top		CMP D3,D7
		BGE.S not_bot
		MOVE D3,D7	
not_bot		MOVE.L D3,(A1)+
		MOVE.L D3,(A2)+
		DBF D0,coord_lp
		MOVE.L A4,A5
		CMP #200,D7
		BLE.S .normjobby
		MOVE.W #200,D7
.normjobby	SUB D2,D7			; d2 - lowest y  d7 - greatest y
		BEQ poly_done
		MOVE D2,D0			; save minimum y
CALCS		MOVE D7,D5
		LEA grad_table+400(PC),A0
; Calc x's down left side of poly
Do_left		LEA LEFTJMP(PC),A2
		LEA x1s(PC),A3
Left_lp 	SUBQ #4,A4
		MOVEM.W (A4),D1-D4
		SUB D4,D2			;dy
		SUB D3,D1			;dx
		SUB D2,D7			;remaining lines-dy
		ADD D2,D2
		MULS (A0,D2),D1
		ASL.L #3,D1
		SWAP D1
		ADD D2,D2
		ADD D3,D3
		ADD D3,D3
		NEG D2
		JMP (A2,D2)
		REPT 200
		MOVE.W D3,(A3)+
		ADDX.L D1,D3
		ENDR
LEFTJMP		TST D7
		BGT Left_lp
; Calc x's down right side of poly
Do_right	MOVE.W D5,D7
		LEA RIGHTJMP(PC),A2
		LEA x2s(PC),A3
Right_lp	MOVEM (A5),D1-D4
		ADDQ #4,A5
		SUB D2,D4			;dy
		SUB D1,D3			;dx
		SUB D4,D5			;remaining lines-dy
		ADD D4,D4
		MULS (A0,D4),D3
		ASL.L #3,D3
		SWAP D3
		ADD D4,D4
		ADD D1,D1
		ADD D1,D1
		NEG D4
		JMP (A2,D4)
		REPT 200
		MOVE.W D1,(A3)+
		ADDX.L D3,D1
		ENDR
RIGHTJMP	TST D5
		BGT Right_lp
; Now we actually get round to filling the polygon!
		LEA x1s(PC),a1			; ptr to left edge list
		LEA x2s(PC),a2			;   "    right   "
		MOVE col(PC),D1
normalfill	MOVE.L log_base(PC),A6
		ADD D0,D0			; min y*2
		LEA tmul_160(PC),A4
		ADD (A4,D0),D1
		ADD D1,A6
		LEA ch_vectl,A3			; left mask table
		LEA 320*4(a3),A4		; right mask table
		MOVEQ #-1,D2
		SUBQ #1,D7
		BMI poly_done 
drawonehline:	MOVEQ #-4,D0
		MOVEQ #-4,D1
		AND (A1)+,D0
		AND (A2)+,D1
		MOVE.L (A3,D0),D0		; left mask\offset
		MOVE.L (A4,D1),D1		; right mask\offset
		SUB D1,D0			; -ve difference!
		BLT.S bigcase			; same chunk?
; Hline over one chunk case
		BNE.S next_line			; negative case
		AND.L D1,D0
		SWAP D0
		OR.W D0,(A6,D1)			; write 1 chunk
		LEA 160(A6),A6			; next screen line
		DBF D7,drawonehline
		RTS
bigcase		MOVE.L A6,A0			; hline over several chunks
		ADDA.W D1,A0 
		SWAP D1
		OR D1,(A0)			; write left edge
		ADD D0,A0
		ASR #1,D0			; asr because dx is -ve 
		JMP miss_main+4(PC,D0)		; jump back thru list
		MOVE.W D2,152(A0)
		MOVE.W D2,144(A0)
		MOVE.W D2,136(A0)
		MOVE.W D2,128(A0)
		MOVE.W D2,120(A0)
		MOVE.W D2,112(A0)
		MOVE.W D2,104(A0)
		MOVE.W D2,96(A0)
		MOVE.W D2,88(A0)
		MOVE.W D2,80(A0)		; solid colour
		MOVE.W D2,72(A0)
		MOVE.W D2,64(A0)
		MOVE.W D2,56(A0)
		MOVE.W D2,48(A0)
		MOVE.W D2,40(A0)
		MOVE.W D2,32(A0)
		MOVE.W D2,24(A0)
		MOVE.W D2,16(A0)
		MOVE.W D2,8(A0)
miss_main	SWAP D0				; right mask
		OR D0,(A0)			; and write right mask!!
next_line	LEA 160(A6),A6			; next screen line
		DBF D7,drawonehline
poly_done	RTS

; Multplication gradient table for poly edges
grad_table	dc.w	$FF5D,$FF5C,$FF5B,$FF5A,$FF59,$FF58,$FF58,$FF57 
		dc.w	$FF56,$FF55,$FF54,$FF53,$FF52,$FF51,$FF50,$FF4F 
		dc.w	$FF4E,$FF4D,$FF4C,$FF4B,$FF4A,$FF49,$FF48,$FF47 
		dc.w	$FF46,$FF45,$FF44,$FF43,$FF42,$FF41,$FF40,$FF3F 
		dc.w	$FF3D,$FF3C,$FF3B,$FF3A,$FF39,$FF37,$FF36,$FF35 
		dc.w	$FF34,$FF32,$FF31,$FF30,$FF2E,$FF2D,$FF2C,$FF2A 
		dc.w	$FF29,$FF28,$FF26,$FF25,$FF23,$FF22,$FF20,$FF1F 
		dc.w	$FF1D,$FF1B,$FF1A,$FF18,$FF16,$FF15,$FF13,$FF11 
		dc.w	$FF10,$FF0E,$FF0C,$FF0A,$FF08,$FF06,$FF04,$FF02 
		dc.w	$FF01,$FEFE,$FEFC,$FEFA,$FEF8,$FEF6,$FEF4,$FEF2 
		dc.w	$FEEF,$FEED,$FEEB,$FEE8,$FEE6,$FEE4,$FEE1,$FEDF 
		dc.w	$FEDC,$FED9,$FED7,$FED4,$FED1,$FECE,$FECB,$FEC8 
		dc.w	$FEC5,$FEC2,$FEBF,$FEBC,$FEB9,$FEB6,$FEB2,$FEAF 
		dc.w	$FEAB,$FEA8,$FEA4,$FEA0,$FE9C,$FE98,$FE94,$FE90 
		dc.w	$FE8C,$FE88,$FE83,$FE7F,$FE7A,$FE76,$FE71,$FE6C 
		dc.w	$FE67,$FE62,$FE5C,$FE57,$FE51,$FE4C,$FE46,$FE40 
		dc.w	$FE39,$FE33,$FE2C,$FE26,$FE1F,$FE17,$FE10,$FE08 
		dc.w	$FE01,$FDF8,$FDF0,$FDE7,$FDDE,$FDD5,$FDCC,$FDC2 
		dc.w	$FDB7,$FDAD,$FDA2,$FD96,$FD8A,$FD7E,$FD71,$FD64 
		dc.w	$FD56,$FD47,$FD38,$FD28,$FD18,$FD06,$FCF4,$FCE1 
		dc.w	$FCCD,$FCB8,$FCA2,$FC8B,$FC72,$FC58,$FC3D,$FC20 
		dc.w	$FC01,$FBE0,$FBBC,$FB97,$FB6E,$FB43,$FB14,$FAE2 
		dc.w	$FAAB,$FA70,$FA2F,$F9E8,$F99A,$F944,$F8E4,$F879 
		dc.w	$F801,$F778,$F6DC,$F628,$F556,$F45E,$F334,$F1C8 
		dc.w	$F001,$EDB7,$EAAB,$E667,$E001,$D556,$C001,$8001 
		dc.w	$0000,$7FFF,$3FFF,$2AAA,$1FFF,$1999,$1555,$1249 
		dc.w	$0FFF,$0E38,$0CCC,$0BA2,$0AAA,$09D8,$0924,$0888 
		dc.w	$07FF,$0787,$071C,$06BC,$0666,$0618,$05D1,$0590 
		dc.w	$0555,$051E,$04EC,$04BD,$0492,$0469,$0444,$0420 
		dc.w	$03FF,$03E0,$03C3,$03A8,$038E,$0375,$035E,$0348 
		dc.w	$0333,$031F,$030C,$02FA,$02E8,$02D8,$02C8,$02B9 
		dc.w	$02AA,$029C,$028F,$0282,$0276,$026A,$025E,$0253 
		dc.w	$0249,$023E,$0234,$022B,$0222,$0219,$0210,$0208 
		dc.w	$01FF,$01F8,$01F0,$01E9,$01E1,$01DA,$01D4,$01CD 
		dc.w	$01C7,$01C0,$01BA,$01B4,$01AF,$01A9,$01A4,$019E 
		dc.w	$0199,$0194,$018F,$018A,$0186,$0181,$017D,$0178 
		dc.w	$0174,$0170,$016C,$0168,$0164,$0160,$015C,$0158 
		dc.w	$0155,$0151,$014E,$014A,$0147,$0144,$0141,$013E 
		dc.w	$013B,$0138,$0135,$0132,$012F,$012C,$0129,$0127 
		dc.w	$0124,$0121,$011F,$011C,$011A,$0118,$0115,$0113 
		dc.w	$0111,$010E,$010C,$010A,$0108,$0106,$0104,$0102 
		dc.w	$00FF,$00FE,$00FC,$00FA,$00F8,$00F6,$00F4,$00F2 
		dc.w	$00F0,$00EF,$00ED,$00EB,$00EA,$00E8,$00E6,$00E5 
		dc.w	$00E3,$00E1,$00E0,$00DE,$00DD,$00DB,$00DA,$00D8 
		dc.w	$00D7,$00D6,$00D4,$00D3,$00D2,$00D0,$00CF,$00CE 
		dc.w	$00CC,$00CB,$00CA,$00C9,$00C7,$00C6,$00C5,$00C4 
		dc.w	$00C3,$00C1,$00C0,$00BF,$00BE,$00BD,$00BC,$00BB 
		dc.w	$00BA,$00B9,$00B8,$00B7,$00B6,$00B5,$00B4,$00B3 
		dc.w	$00B2,$00B1,$00B0,$00AF,$00AE,$00AD,$00AC,$00AB 
		dc.w	$00AA,$00A9,$00A8,$00A8,$00A7,$00A6,$00A5,$00A4 
		dc.w	$00A3 

col		DS.W 1
x1s		DS.W 210
x2s		DS.W 210

;-----------------------------------------------------------------------;
; 16*16 1 plane Buffer Scroller (This one has variable speeds 1,2,4etc) ;
; By Martin Griffiths May 1991. (alias Griff of the Inner Circle)....	;
;-----------------------------------------------------------------------;

nolines		EQU 16
linewid		EQU 104
phbufsize	EQU nolines*linewid

Do_bufscroll	LEA ovscr_point(PC),A1		; ->some variables
		MOVE.L (A1)+,A0			; curr text ptr
		MOVE (A1)+,D6			; pixel offset
		ADD ovscrlspeed(PC),D6		; pix offset+speed
		AND #15,D6			; next 16 pix?
		BNE.S .notnchar			; no then skip
		ADDQ.W #2,(A1)			; onto next chunk 
		CMP #linewid/2,(A1)		; in pix buffer.
		BNE.S .noreset			; reached end of buffer?		
		CLR (A1)			; if yes reset buffer position
.noreset	ADDQ.L #1,A0			; next letter...
		MOVE.W ovthischar+2(PC),ovthischar ; cycle characters.
		MOVEQ #0,D0
.fetchchar	MOVE.B (A0),D0	
		BNE.S .notwrap			; end of text?
		LEA ovtext(PC),A0		; yes restart text
		MOVE.B (A0),D0
.notwrap	CMP.B #1,D0
		BNE.S .notsetspeed
		MOVE.B 1(A0),ovscrlspeed+1
		ADDQ.L #2,A0
		BRA.S .fetchchar
.notsetspeed	ADD.W D0,D0
		MOVE.W D0,ovthischar+2
.notnchar	MOVE D6,-(A1)			; otherwise restore
		MOVE.L A0,-(A1)
		LEA phfontbuf(PC),A5     	; character addr    
		LEA (A5),A6
		ADDA.W ovthischar(PC),A5
		ADDA.W ovthischar+2(PC),A6
		MOVE.W ovscx(PC),D0
		MULU #phbufsize,d0
		LEA (phscbuffer)-2,A3
		ADD.L D0,A3
		ADD ovscrlpos(PC),A3
		LEA 2(A3),A1
		MOVE.W ovscrlspeed(PC),D4	; scroll speed
		SUBQ #1,D4
		MULU #12,D4			; *14(for jmp thru)
		LEA .jmpthru(PC),A4
		SUB.W D4,A4			; jmp address
		MOVEQ #nolines-1,D1
.updatebuflp	MOVE.W (A6),D3
		SWAP D3
		MOVE.W (A5),D3 
		LEA 120(A5),A5
		LEA 120(A6),A6
		ROL.L D6,D3
		MOVE.W D3,(linewid/2)(A3)	; update the buffers		
		MOVE.W D3,(A3)
		MOVE.L A3,A2
		JMP (A4)
		REPT 15				; e.g number of buffers
		LEA phbufsize(A2),A2		; to update = speed!
		ROL.L #1,D3
		MOVE.W D3,(linewid/2)(A2)
		MOVE.W D3,(A2)
		ENDR
.jmpthru	LEA linewid(A3),A3
		DBF D1,.updatebuflp
set_bufcopyptrs	MOVE.L A1,bufsource_ptr
		MOVE.L phy_base(PC),A4
		ADD.L #(212*160)+6,A4
		MOVEQ #16-1,D0
.LP		MOVE.L (A1)+,(A4)
		MOVE.L (A1)+,16(A4)
		MOVE.L (A1)+,32(A4)
		MOVE.L (A1)+,48(A4)
		MOVE.L (A1)+,64(A4)
		MOVE.L (A1)+,80(A4)
		MOVE.L (A1)+,96(A4)
		MOVE.L (A1)+,112(A4) 
		MOVE.L (A1)+,128(A4)
		MOVE.L (A1)+,144(A4)
		LEA linewid-40(A1),A1		; next buf line
		LEA 160(A4),A4
		DBRA D0,.LP
		RTS

bufsource_ptr	DC.L 0
bufdest_ptr	DC.L 0

ovscr_point	DC.L ovtext
ovscx		DC.W 0
ovscrlpos	DC.W 0
ovscrlspeed	DC.W 4
ovthischar	DC.W 64,64
ovtext		DC.B "                        WELL HOW ABOUT THAT!!!!!! (HE HE) IT'S ANOTHER UNDERSCAN SCREEN!!"
		DC.B " (SORRY DELTAFORCE!)  OK OK, SO ITS JUST A LOUSY BLUE BORDER WITH A SLOW STARFIELD.....         "
		DC.B 1,8,"                  "
		DC.B 1,4,"  BUT LET US APPROACH THIS FROM SOME NEW ANGLES.....          ",1,8,"                   "
		DC.B 1,4,"                               YEAH! A HIDDEN LINE VECTOR PYRAMID.....          ",1,8,"                    "      
		DC.B 1,4,"                               AND A ROTATING INNER CIRCLE LOGO......         ",1,8,"                    "
		DC.B 1,4,"         BUT NOW LET US....      SPIN IT!     ",1,1," ",1,2," ",1,8,"                  "
		DC.B 1,4,"     WELL THIS CUBE IS MOSTLY A CONVERSION OF A PART OF MY FAVOURITE AMIGA DEMO, 'ENIGMA' AND IS BY PHENOMENA...    "
		DC.B " OKAY SO THE AMIGA VERSION WAS A BIT FASTER BUT THE ST HAS NO BLITTER TO DRAW LINES AND FILL AREAS, SO WHAT DO YOU EXPECT?!"
		DC.B " ANYWAY THIS VERSION IS MUCH SMOOTHER THAN THE AMIGA ONE COS THEY USED WOBBLY 3D ROUTS TO GAIN EXTRA SPEED.....        "
		DC.B 1,8,"                    "
		DC.B 1,4," OK... LETS MOVE THAT CUBE......       ",1,8,"                 "
		DC.B 1,4,"  WELL I HOPE YOU LIKED THIS PART! IT TOOK ME TWO DAYS TO CODE SO YA BETTER LIKE IT...        "
		DC.B "LETS LEAVE THIS PART AND GO ONTO SOME MORE INTERESTING(?) ROUTINES......          "
		DC.B 1,8,"                           "
		DC.B 1,4,"                                     " 
		DC.B 0
		EVEN

phfontbuf	INCBIN ENIG161P.FNT

; Sequence for the cube

PHCube_Sequence	DC.W SetNewObj,0,0,$3B30,0,0,0
		DC.L cube,cube+6
		DC.W SetXYZstuff,40,0,0,0,0,0,-254
		DC.W SetXYZstuff,1,0,0,0,0,0,-238
		DC.W SetXYZstuff,480,0,0,0,0,0,0
		DC.W SetXYZstuff,64,0,0,8,0,0,0
		DC.W SetXYZstuff,126,0,0,0,0,0,0
		DC.W SetXYZstuff,64,0,8,0,0,0,0
		DC.W SetXYZstuff,218,0,0,0,0,0,0
		DC.W SetXYZstuff,200,-20,-16,18,0,0,0
		DC.W SetXYZstuff,200,-18,-16,20,0,0,0
		DC.W SetXYZstuff,200,-16,-18,18,0,0,0
		DC.W SetXYZstuff,228,-14,-22,20,0,0,0
		DC.W SetWaveformON,360,0
		DC.L phen_twirl
		DC.W SetXYZstuff,180,-18,-20,22,0,0,0
		DC.W SetXYZstuff,180,-22,-22,24,0,0,0
		DC.W SetXYZstuff,80,-22,-22,24,0,0,0
		DC.W SetFadeDown
		DC.W SetXYZstuff,35,-22,-22,24,0,0,0
		DC.W SetWaveformOFF
		DC.W SetRestart

phen_twirl	INCBIN PH_twirl.dat

; Standard Tables etc...

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

bit_offs	DS.L 320      ; standard table for plot mask.w/offset.w
		DS.L 512-320  ; + clip tab for starfield etc...

; Phenomena Cube BSS 

		SECTION BSS
		DS.L 199
stack		DS.L 1

screens		DS.B 256
		DS.B 42240
		DS.B 42240
		DS.W 8
phscbuffer	
		REPT 16
		DS.B phbufsize
		ENDR
		DS.W 8
ch_vectl	DS.L 320
ch_vectr	DS.L 320
perstab		DS.W $A00
multable	DS.W (32768-dist)
