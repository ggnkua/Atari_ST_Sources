;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;

		OPT O+,OW-

no_strs		EQU 190
timing		EQU 0
max_screensize	EQU 192000	; maximum size of 1 screen

; SetVideo() equates.

VERTFLAG	EQU $0100	; double-line on VGA, interlace on ST/TV ;
STMODES		EQU $0080	; ST compatible ;
OVERSCAN	EQU $0040	; Multiply X&Y rez by 1.2, ignored on VGA ;
PAL		EQU $0020	; PAL if set, else NTSC ;
VGA		EQU $0010	; VGA if set, else TV mode ;
COL80		EQU $0008	; 80 column if set, else 40 column ;
BPS16		EQU $0004
BPS8		EQU $0003
BPS4		EQU $0002
BPS2		EQU $0001
BPS1		EQU $0000

; Cache Control Register Equates (CACR)

ENABLE_CACHE		EQU 1   ; Enable instruction cache
FREEZE_CACHE		EQU 2   ; Freeze instruction cache
CLEAR_INST_CACHE_ENTRY	EQU 4   ; Clear instruction cache entry
CLEAR_INST_CACHE	EQU 8   ; Clear instruction cache
INST_BURST_ENABLE	EQU 16  ; Instruction burst enable
ENABLE_DATA_CACHE	EQU 256 ; Enable data cache
FREEZE_DATA_CACHE	EQU 512 ; Freeze data cache
CLEAR_DATA_CACHE_ENTRY	EQU 1024 ; Clear data cache entry
CLEAR_DATA_CACHE	EQU 2048 ; Clear data cache
DATA_BURST_ENABLE	EQU 4096 ; Instruction burst enable
WRITE_ALLOCATE		EQU 8192 ; Write allocate 

letsgo		MOVE.L 4(SP),A5
		MOVE.L $C(A5),A4
		ADD.L $14(A5),A4
		ADD.L $1C(A5),A4
		LEA $100(A4),A4			; proggy size+basepage
		PEA (A4)
		PEA (A5)
		CLR -(SP)
		MOVE #$4A,-(SP)
		TRAP #1				; reserve some memory
		LEA 12(SP),SP
		MOVE.W #-1,-(SP)
		MOVE.W #$58,-(SP)
		TRAP #14
		ADDQ.L #4,SP
		MOVE.W D0,oldvideo
		MOVE.W #2,-(SP)
		TRAP #14		
		ADDQ.L #2,SP	
		MOVE.L D0,oldbase
		CLR.L -(SP)
		MOVE.W #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		MOVE.L D0,oldsp
		LEA my_stack,SP
		BSR wait_vbl
		BSR save_pal
		BSR ClearScreens	

;		BSR load_dspprog	
;		MOVE.L D0,$FFFFA204.W	;stobe to continue
		BSR init_ints

.sperm		BSR makeperstab
		BSR Random_gen
		BSR make160tab
		BSR crplotmasks

		MOVE.L #64000,D1
		BSR Initscreenptrs
		BSR wait_vbl
		MOVE.L log_base(PC),D0
		BSR SetScreen
		MOVE.W #OVERSCAN+PAL+BPS4,-(SP)
		MOVE.W #$58,-(SP)
		TRAP #14
		ADDQ.L #4,SP
		BSR wait_vbl
		CLR.L $466.W
		CLR.W tc_count
		BSR readrate

		REPT 4
		BSR SwapScreens
		BSR Clear_stars
		LEA angles(PC),A5
		BSR Sperm_seq
		BSR Matrix_make
		BSR trans_sperms
		ENDR
		BSR wait_vbl

.waitspace	
		IFNE timing
		MOVE.l #$20,$FFFF9800.W
		ENDC
		BSR wait_vbl
		IFNE timing
		MOVE.l #$00,$FFFF9800.W
		ENDC
		BSR SwapScreens
		MOVE.L phy_base(PC),D0
		BSR SetScreen
		BSR Clear_stars
		LEA angles(PC),A5
		BSR Sperm_seq
		BSR Matrix_make
		BSR trans_sperms
		BSR Drawsperms	

		BSR setcols

		CMP.B #$39,key
		BNE.S .waitspace

.out		BSR wait_vbl
		BSR restore_ints
		MOVE.W oldvideo(PC),-(SP)
		MOVE.W #$58,-(SP)
		TRAP #14
		ADDQ.L #4,SP
		MOVE.W #-1,-(SP)
		MOVE.L oldbase(PC),-(SP)
		MOVE.L oldbase(PC),-(SP)
		MOVE.W #5,-(SP)
		TRAP #14
		LEA 12(SP),SP
		BSR wait_vbl
		BSR rest_pal
		MOVE.L oldsp(PC),-(SP)
		MOVE.W #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		CLR -(SP)
		TRAP #1

oldvideo	DC.W 0
oldbase		DC.L 0
oldsp		DS.L 1

;-------------------------------------------------------------------------
; Interrupt setup routines

; Save mfp vectors and ints and install our own.(very 'clean' setup rout)

init_ints	MOVEQ #$13,D0			; pause keyboard
		BSR Writeikbd			; (stop from sending)
		MOVE #$2700,SR
		LEA old_stuff,A0
		MOVE.L USP,A1
		MOVE.L A1,(A0)+
		MOVE.L $68.W,(A0)+
		MOVE.L $70.W,(A0)+
		MOVE.L $B0.W,(A0)+
		MOVE.L $110.W,(A0)+
		MOVE.L $114.W,(A0)+
		MOVE.L $118.W,(A0)+
		MOVE.L $120.W,(A0)+
		MOVE.L $134.W,(A0)+
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA0B.W,(A0)+
		MOVE.B $FFFFFA0D.W,(A0)+
		MOVE.B $FFFFFA0F.W,(A0)+
		MOVE.B $FFFFFA11.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+	; restore mfp
		MOVE.B $FFFFFA17.W,(A0)+
		MOVE.B $FFFFFA19.W,(A0)+
		MOVE.B $FFFFFA1B.W,(A0)+
		MOVE.B $FFFFFA1D.W,(A0)+
		MOVE.B $FFFFFA1F.W,(A0)+
		MOVE.B $FFFFFA21.W,(A0)+
		MOVE.B $FFFFFA23.W,(A0)+
		LEA anrte(PC),A0
		MOVE.L A0,$14.W
		LEA vbl(PC),A0
		MOVE.L A0,$70.W
		LEA tc_ratecounter(PC),A0
		MOVE.L A0,$114.W 
		LEA key_rout(PC),A0
		MOVE.L A0,$118.W		; and our keyrout.
		MOVE.B #$00,$FFFFFA07.W
		MOVE.B #$60,$fffffa09.W
		MOVE.B #$00,$FFFFFA13.W
		MOVE.B #$60,$fffffa15.W
		MOVE.B #$70,$FFFFFA1D.W
		BCLR.B #3,$fffffa17.W		; software end of int.
		CLR key			
		MOVE #$2300,SR
		MOVEQ #$11,D0			; resume sending
		BSR Writeikbd
		MOVEQ #$12,D0			; kill mouse
		BSR Writeikbd
		BRA flush

; Restore mfp vectors and ints.

restore_ints	MOVEQ #$13,D0			; pause keyboard
		BSR Writeikbd			; (stop from sending)
		MOVE #$2700,SR
		LEA old_stuff,A0
		MOVE.L (A0)+,A1
		MOVE.L A1,USP
		MOVE.L (A0)+,$68.W
		MOVE.L (A0)+,$70.W
		MOVE.L (A0)+,$B0.W
		MOVE.L (A0)+,$110.W
		MOVE.L (A0)+,$114.W
		MOVE.L (A0)+,$118.W
		MOVE.L (A0)+,$120.W
		MOVE.L (A0)+,$134.W
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA0B.W
		MOVE.B (A0)+,$FFFFFA0D.W
		MOVE.B (A0)+,$FFFFFA0F.W
		MOVE.B (A0)+,$FFFFFA11.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W	; restore mfp
		MOVE.B (A0)+,$FFFFFA17.W
		MOVE.B (A0)+,$FFFFFA19.W
		MOVE.B (A0)+,$FFFFFA1B.W
		MOVE.B (A0)+,$FFFFFA1D.W
		MOVE.B (A0)+,$FFFFFA1F.W
		MOVE.B (A0)+,$FFFFFA21.W
		MOVE.B (A0)+,$FFFFFA23.W
		MOVE.B #$C0,$FFFFFA23.W
		MOVE #$2300,SR
		MOVEQ #$11,D0			; resume
		BSR Writeikbd		
		MOVEQ #$8,D0			; restore mouse.
		BSR Writeikbd
		BRA flush

; Write d0 to IKBD

Writeikbd	BTST.B #1,$FFFFFC00.W
		BEQ.S Writeikbd			; wait for ready
		MOVE.B D0,$FFFFFC02.W		; and send...
		RTS

; Flush keyboard

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S flush
flok		RTS

; Keyboard handler interrupt routine...

key_rout	MOVE #$2500,SR			; ipl 5 for 'cleanness' 
		MOVE D0,-(SP)
		MOVE.B $FFFFFC00.W,D0
		BTST #7,D0			; int req?
		BEQ.S .end			
		BTST #0,D0			; 
		BEQ.S .end
		MOVE.B $FFFFFC02.W,key		; store keypress
.end		MOVE (SP)+,D0
		RTE

key		DC.W 0

; Save palette

save_pal	MOVEM.L $FFFF8240.W,D0-D7
		MOVEM.L D0-D7,old_pal
		LEA $FFFF9800.W,A0
		LEA old_falcpal,A1
		MOVE #256-1,D0
.save_pallp	MOVE.L (A0)+,(A1)+
		DBF D0,.save_pallp		
		RTS

; Restore palette

rest_pal	MOVEM.L old_pal,D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		LEA old_falcpal,A0
		LEA $FFFF9800.W,A1
		MOVE #256-1,D0
.rest_pallp	MOVE.L (A0)+,(A1)+
		DBF D0,.rest_pallp		
		RTS

; Initialise 3 screens.
; D1 has size of screen.

Initscreenptrs	LEA log_base(PC),A1
	  	MOVE.L #screens+256,D0
		CLR.B D0
		MOVE.L D0,(A1)+
		ADD.L D1,D0
		MOVE.L D0,(A1)+
		ADD.L D1,D0
		MOVE.L D0,(A1)+
		RTS

; Set Screen. d0->screen.

SetScreen	MOVE.B D0,$FFFF820D.W
		LSR.L #8,D0
		MOVE.B D0,$FFFF8203.W
		LSR.L #8,D0
		MOVE.B D0,$FFFF8201.W
		RTS

; Clear the screen area 

ClearScreens	LEA screens,A0
		MOVE.W #(256+(3*max_screensize))/16-1,D2 
		MOVEQ #0,D1
.lp		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		DBF D2,.lp
		RTS


; Wait for the vbl.

wait_vbl	MOVE.L $466.W,D0
.waitvb		CMP.L $466.W,D0	
		BEQ.S .waitvb
		RTS

; Little old vbl..

vbl		MOVEM.L A0-A1,-(SP)
		LEA colours(PC),A0
		LEA $FFFF9800.W,A1
		REPT 16
		MOVE.L (A0)+,(A1)+
		ENDR
		MOVEM.L (SP)+,A0-A1
		ADDQ.L #1,$466.W
		RTE 

; Timer C frame rate counter (used for frame compensation)

tc_ratecounter	SUBQ.B #1,tc_count 
anrte		RTE 

readrate  	MOVE.W tc_count(PC),D0 
		MOVE.B $FFFFFA23.W,D0
		MOVE.W oldtc_count(PC),D1 
		MOVE.W D0,oldtc_count 
		SUB.W D0,D1 
		BPL.S .ok
		MOVEQ #0,D1 
.ok	   	RTS 

tc_count	DC.W 0
oldtc_count	DC.W 0
log_base	DC.L 0
phy_base	DC.L 0
aux_base	DC.L 0
frame_switch	DC.W 0
plane_cnt	DC.W 0

; Swap Screen ptrs and set hardware reg for next frame.

SwapScreens	LEA log_base(PC),A0
		MOVEM.L (A0)+,D0-D1
		NOT.W 4(A0)
		MOVE.L D0,-(A0)
		MOVE.L D1,-(A0)
		RTS

; Set/Cycle colours

setcols		LEA cols(PC),A0
		MOVE.W plane_cnt(PC),D0
		NEG D0
		ADDQ #6,D0
		MOVEM.L (A0,D0*2),D0-D3
		LEA colours+4(PC),A1
		MOVE.L D0,(A1)+
		REPT 2
		MOVE.L D1,(A1)+
		ENDR
		REPT 4
		MOVE.L D2,(A1)+
		ENDR
		REPT 8
		MOVE.L D3,(A1)+
		ENDR
		RTS
rgb24		MACRO
		DC.l (\1<<24)+(\2<<16)+\3
		ENDM

cols		rgb24 100,100,100
		rgb24 150,150,150
		rgb24 200,200,200
		rgb24 250,250,250
		rgb24 100,100,100
		rgb24 150,150,150
		rgb24 200,200,200
		rgb24 250,250,250

colours		DS.L 16

; Clear those stars!

Clear_stars	LEA plane_cnt(PC),A0
		MOVE.W (A0),D0
		TST frame_switch
		BEQ.S .ok
		ADDQ #2,D0
.ok		AND.W #7,D0
		MOVE.W D0,(A0)

		MOVE.L log_base(PC),A0
		ADDA.W plane_cnt(PC),A0
		MOVEQ #0,D1
		MOVE #240-1,D2
.lp		MOVE.W D1,(A0)
		MOVE.W D1,8(A0)
		MOVE.W D1,16(A0)
		MOVE.W D1,24(A0)
		MOVE.W D1,32(A0)
		MOVE.W D1,40(A0)
		MOVE.W D1,48(A0)
		MOVE.W D1,56(A0)
		MOVE.W D1,64(A0)
		MOVE.W D1,72(A0)
		MOVE.W D1,80(A0)
		MOVE.W D1,88(A0)
		MOVE.W D1,96(A0)
		MOVE.W D1,104(A0)
		MOVE.W D1,112(A0)
		MOVE.W D1,120(A0)
		MOVE.W D1,128(A0)
		MOVE.W D1,136(A0)
		MOVE.W D1,144(A0)
		MOVE.W D1,152(A0)
		MOVE.W D1,160(A0)
		MOVE.W D1,168(A0)
		MOVE.W D1,176(A0)
		MOVE.W D1,184(A0)
		LEA 192(A0),A0
		DBF D2,.lp
		RTS
		
Sperm_seq	LEA ballseqdata(PC),A3
		SUBQ.L #1,seq_timer(A3)
		BNE.S .nonew
		MOVE.L seq_ptr(A3),A1
		TST.L (A1)
		BPL.S .notendseq
		MOVE.L restart_ptr(A3),A1 
.notendseq	MOVE.L (A1)+,seq_timer(A3)
		MOVE.L (A1)+,addangx(A3)
		MOVE.L (A1)+,addangy(A3)
		MOVE.L (A1)+,addangz(A3)	; store new incs..
		MOVE.L (A1)+,zspeed
		MOVE.L A1,seq_ptr(A3)
.nonew		MOVEM.W (A5),D5-D7    		; get current x,y,z ang	
		SWAP D5
		SWAP D6
		SWAP D7
		MOVE.W anglesfrac(PC),D5 
		MOVE.W anglesfrac+2(PC),D6 
		MOVE.W anglesfrac+4(PC),D7 
		ADD.L addangx(A3),D5
		ADD.L addangy(A3),D6
		ADD.L addangz(A3),D7
		MOVE.W D5,anglesfrac
		MOVE.W D6,anglesfrac+2
		MOVE.W D7,anglesfrac+4
		SWAP D5
		SWAP D6
		SWAP D7
		MOVEM.W D5-D7,(A5)   	
		RTS

; Sequence data for ball starfield
		
		RSRESET

seq_timer	RS.l 1
seq_ptr		RS.L 1
addangx		RS.W 1
addangxfr	RS.W 1
addangy		RS.W 1
addangyfr	RS.W 1
addangz		RS.W 1
addangzfr	RS.W 1
restart_ptr	RS.L 1
angles		DC.W $400,0,0
anglesfrac	DC.W 0,0,0

zspeed		DC.L 0

ballseqdata	DC.L 1
		DC.L ballsequence 
		DC.L 0,0,0
		DC.L restart

ballsequence	DC.L 250,$00000,$00000,$00000,$80000
restart
		DC.L 64,$30000,$08000,$08000,$80000
		DC.L 64,$60000,$08000,$08000,$80000
		DC.L 64,$60000,$10000,$10000,$80000
		DC.L 64,$60000,$20000,$10000,$80000
		DC.L 64,$80000,$30000,$20000,$80000
		DC.L 64,$40000,$30000,$20000,$80000
		DC.L -1

; Calculate a translation matrix (and do rotation sequence!)
; D0-D7/A0-A6 smashed. (which basically means all of them!)

Matrix_make	LEA matrix(PC),A0
		MOVEM.W (A5),D0/d2/d4    		; get current x,y,z ang	
		MOVE.W #$7FE,D6
		LEA trig_tab,A1			; sine table
		LEA 512(A1),A2			; cosine table
                and.w   D6,D0
                move.w  0(A1,D0.w),D1   ; Sin X into D1
                move.w  0(A2,D0.w),D0   ; Cos X into D0.
                and.w   D6,D2
                move.w  0(A1,D2.w),D3   ; Sin Y into D3
                move.w  0(A2,D2.w),D2   ; Cos Y into D2.
                and.w   D6,D4
                move.w  0(A1,D4.w),D5   ; Sin Z into D5
                move.w  0(A2,D4.w),D4   ; Cos Z into D4.
gen_mat_x:      move.w  D4,D6           ; Store CosZ.
                muls    D2,D4           ; CosY * CosZ.
                add.l   D4,D4
                swap    D4
                move.w  D4,(A0)+        ; > M1,1
                move.w  D6,D4           ; Restore Cos Z.
                move.w  D5,D6           ; Store SinZ.
                muls    D2,D5           ; CosY * SinZ.
                add.l   D5,D5
                swap    D5
                move.w  D5,(A0)+        ; > M2,1
                move.w  D6,D5
                move.w  D3,(A0)+        ; > M3,1 = SinY. Also stores d3!
                move.w  D3,D7           ; Store for later use.
gen_mat_y:      muls    D1,D3           ; SinX * SinY
                add.l   D3,D3
                swap    D3
                movea.w D3,A4           ; Store for later.
                muls    D4,D3           ; * CosZ.
                move.w  D5,D6           ; Store SinZ.
                neg.w   D5              ; SinZ = -SinZ.
                muls    D0,D5           ; CosX * -SinZ.
                add.l   D5,D3
                add.l   D3,D3
                swap    D3
                move.w  D3,(A0)+        ; > M1,2.
                move.w  A4,D3           ; Fetch SinX * SinY.
                move.w  D6,D5           ; Restore SinZ.
                muls    D5,D3           ; * SinZ.
                move.w  D4,D6           ; Store CosZ.
                muls    D0,D4           ; CosX * CosZ.
                add.l   D4,D3
                add.l   D3,D3
                swap    D3
                move.w  D6,D4           ; Restore CosZ.
                move.w  D3,(A0)+        ; > M2,2
                move.w  D7,D3           ; Restore SinY.
                move.w  D1,D6           ; Store SinX.
                neg.w   D1              ; SinX = -SinX.
                muls    D2,D1           ; -SinX * CosY.
                add.l   D1,D1
                swap    D1
                move.w  D1,(A0)+        ; > M3,2.
                move.w  D6,D1           ; Restore SinX.
gen_mat_z:      neg.w   D3              ; SinY = -SinY.
                muls    D0,D3           ; CosX * -SinY.
                add.l   D3,D3
                swap    D3
                movea.w D3,A4           ; Store for later.
                muls    D4,D3           ; * CosZ.
                move.w  D5,D6           ; Store SinZ.
                neg.w   D5              ; SinZ = -SinZ.
                muls    D1,D5           ; SinX * -SinZ.
                add.l   D5,D3
                add.l   D3,D3
                swap    D3
                move.w  D3,(A0)+        ; > M1,3
                move.w  A4,D3           ; Get CosX * -SinY.
                muls    D6,D3           ; * SinZ.
                muls    D1,D4           ; SinX * CosZ.
                add.l   D4,D3
                add.l   D3,D3
                swap    D3
                move.w  D3,(A0)+        ; > M2,3
                muls    D0,D2           ; CosX * CosY.
                add.l   D2,D2
                swap    D2
                move.w  D2,(A0)+        ; > M3,3
                rts

matrix		DS.W 9

; Translate those sperms

trans_sperms	LEA stars(PC),A0		; star co-ords
		MOVE zspeed(PC),A2
		MOVE plane_cnt(PC),D0
		LEA trans_flags(PC),A6
		LEA trans_stars1(PC),A5
		TST.W frame_switch
		BNE.S .cse2
		LEA trans_stars2(PC),A5
		ADDQ.L #2,A6
.cse2		AND.W #3,D0
		BEQ.S .ok
		ADDQ.L #1,A6	
		LEA (no_strs*6)(A5),A5
.ok		MOVE #no_strs-1,D7		; no of stars
.star_lp	LEA matrix(PC),A1
		MOVEM.W (A0)+,D0-d2
		SUB A2,D2			; z-zspeed
		CMP #-256,D2
		SLE (A6)
		BGT.S .starok
		ADD.W #512,D2
.starok		MOVE D2,-2(A0)
		MOVE D0,D3	
		MOVE D1,D4			; dup
		MOVE D2,D5
; Calculate x co-ordinate		
		MULS (A1)+,D0			
		MULS (A1)+,D4			; mat mult
		MULS (A1)+,D5 
		ADD.L D4,D0
		ADD.L D5,D0
		MOVE D3,D6
		MOVE D1,D4
		MOVE D2,D5
; Calculate y co-ordinate		
		MULS (A1)+,D3
		MULS (A1)+,D1			; mat mult
		MULS (A1)+,D5
		ADD.L D3,D1
		ADD.L D5,D1
; Calculate z co-ordinate
		MULS (A1)+,D6
		MULS (A1)+,D4			; mat mult
		MULS (A1)+,D2
		ADD.L D6,D2
		ADD.L D4,D2
		ADD.L D2,D2
		ASR.L #7,D0
		SWAP D2
		ASR.L #7,D1
		ADD #256+192,D2
		DIVS D2,D0
		DIVS D2,D1
		ADD #192,D0
		ADD #120,D1
		ADDQ.L #4,A6
		MOVE.W D0,(A5)+
		MOVE.W D1,(A5)+
.conts		DBF D7,.star_lp			; do all points
		RTS

; Draw those sperms!

Drawsperms	MOVE.L log_base(PC),A1
		LEA masks,a2
		MOVE.W plane_cnt(PC),D0
		ADDA.W D0,A1
		LEA mul_scrtab(PC),A3
		LEA trans_flags(PC),A4
		LEA trans_stars1(PC),A5
		LEA trans_stars1+(no_strs*6)(PC),A6
		TST.W frame_switch
		BNE.S .cse2
		LEA trans_stars2(PC),A5
		LEA trans_stars2+(no_strs*6)(PC),A6
.cse2			
		MOVE #no_strs-1,D7
.lp		MOVEM.W (A5)+,D0-D1
		MOVEM.W (A6)+,D2-D3
		MOVE.L (A4)+,D4
		BNE.S .miss
		CMP.W #383,D0
		BCC.S .miss
		CMP.W #383,D2
		BCC.S .miss
		CMP.W #239,D1
		BCC.S .miss
		CMP.W #239,D3
		BCC.S .miss
		BSR.S Drawline
.miss		DBF D7,.lp
		RTS

;-----------------------------------------------------------------------;
; Routine to draw a 1 plane line,the line is clipped if necessary.	;
; D0-D3 holds x1,y1/x2,y2 A1 -> screen base. A2 -> x bit+chunk lookup	;
; D0-D6/A0 smashed.       A3 -> * 160 table					;
;-----------------------------------------------------------------------;

nodraw		RTS

Drawline	MOVE.L A1,A0
		CMP.W D0,D2			; CLIP ON X				
		BGE.S x2big
		EXG D0,D2			; reorder
		EXG D1,D3
x2big		MOVE.W D2,D4
		SUB.W D0,D4			; dx
		MOVE.W D3,D5
		SUB.W D1,D5			; dy
		MOVE.L (A2,D2*4),D6		; mask/chunk offset
		ADD.L (A3,D3*4),A0		; add scr line
		ADDA.W D6,A0			; a0 -> first chunk of line
		SWAP D6				; get mask
		MOVE.W #-192,D3
		TST.W D5			; draw from top to bottom?
		BGE.S bottotop
		NEG.W D5			; no so negate vals
		NEG.W D3
bottotop	CMP.W D4,D5			; dy>dx?
		BLT.S dxbiggerdy

; DY>DX Line drawing case

dybiggerdx	MOVE.W D5,D1			; yes!
		BEQ.S .drawn			; dy=0 nothing to draw(!)
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

; Create plot masks

crplotmasks	LEA masks(PC),A0
		MOVEQ #0,D0
		MOVEQ #24-1,D6
.bloop		MOVE #$8000,D1
		MOVEQ #15,D7
.aloop		MOVE.W D1,(A0)+
		MOVE.W D0,(A0)+
		LSR #1,D1
		DBF D7,.aloop
		ADDQ #8,D0
		DBF D6,.bloop
		RTS

; Make X*DIST/Z table (32000 Z values!!)

makeperstab	LEA perstab(PC),A0
		MOVEQ #0,D0
		MOVE.L #32767*350,D7
.lp		MOVE.W D0,D1
		MOVE.L D7,D6
		ADD #350,D1
		DIVS D1,D6
		MOVE.W D6,(A0)+
		ADDQ #1,D0
		CMP #$400,D0
		BNE.S .lp
		RTS

; Rout to generate *160 table for screen lookup

make160tab	LEA mul_scrtab(PC),A0
		SUB.L A1,A1
		MOVE #256-1,D0
.makelp		MOVE.L A1,(A0)+
		LEA 192(A1),A1
		DBF D0,.makelp
		RTS

; Rout to generate initial Random star positions.

Random_gen	LEA stars(PC),A3
		MOVE #no_strs-1,D7
f_rand_x	BSR Rand
		AND #$1FF,D0
		SUB #$100,D0
		MOVE D0,(A3)+
f_rand_y	BSR Rand
		AND #$1FF,D0
		SUB #$100,D0
		MOVE D0,(A3)+
		BSR Rand
		AND #$1FF,D0
		SUB #$100,D0
		MOVE D0,(A3)+
		DBF D7,f_rand_x
		RTS

; Random number generator. Returns with number in D0.
; This is a tad slooow... it takes about 650 cycles.

Rand		move.l	rndseed(pc),d0
		addi.l	#715136305,d0
		eor.l #$92795c69,d0
		ror.l #3,d0
		muls.l d7,d0
		not.l d0
		ror.l #7,d0
		move.l	d0,rndseed
		rts

rndseed 	dc.l $749457451

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
old_stuff	DS.L 32
old_falcpal	DS.L 256
old_pal		DS.W 16
perstab		DS.W $401
mul_scrtab	DS.l 256
masks		DS.W 32*24
stars 		DS.W no_strs*3
trans_stars1	DS.W no_strs*3*2
trans_stars2	DS.W no_strs*3*2
trans_flags	DS.L no_strs

		DS.L 498
my_stack	DS.L 2
screens		DS.B 256
		DS.B max_screensize*3

