;-----------------------------------------------------------------------;
;									;
;			   TTP .MOD Player				;
;	           16 Bit Falcon030 Pro-Tracker 2.1A Driver  		;
;                         (C) 1993-1994 Griff 				;
;									;
; - 50 khz 16bit stereo sound.						;
; - The ONLY player in the whole wide world to emulate TEMPO properly.	;
;-----------------------------------------------------------------------;
; Quick notes about this source.					;
; - Assemble using DEVPAC 2 or 3.					;
; - This replay is NOT fast and nor should it be. 			;
;-----------------------------------------------------------------------;
; v1.0   Falcon Version!
; v1.1p   Power Packer decrunch works as does modplayer
; v1.2p   No self modifying code now.
; v1.3p   Fixed tempo change set routine.
; v1.4p   DSP play routine instead.
; v1.5    Interpolation/tempo toggle and detects 6/8channel mods.
;         also works with multitos! 
; v1.6    Bug fixes, more autodetects.
; v1.7    S3M Module support.
; v1.8 	  

mtS3M = 1
mtMOD = 2
mtMTM = 3
mtXM  = 4

iword	macro
	ror	#8,\1
	endm

ilword	macro
	ror	#8,\1
	swap	\1
	ror	#8,\1
	endm

tlword	macro
	move.b	\1,\2
	ror.l	#8,\2
	move.b	\1,\2
	ror.l	#8,\2
	move.b	\1,\2
	ror.l	#8,\2
	move.b	\1,\2
	ror.l	#8,\2
	endm

tword	macro
	move.b	\1,\2
	ror	#8,\2
	move.b	\1,\2
	ror	#8,\2
	endm
		
	
		output c:\falcpl17.tos

		opt c-

test		EQU 1			; if test=1 then run from assember
					; (with a pre-included module)
		IFNE test
		OPT D+
		LEA testfile(pc),A6			;  if in testmode
		JMP 	letsgo(pc)
testfile	DC.B (endtestfilename-testfilename)
testfilename	;DC.B "e:\mods\gyros.MOD",0
		dC.B "e:\mods\8MODS\CD2PART1.MOD",0
		;dC.B "e:\mods\s3m\2nd_skav.s3m",0
		;dC.B "e:\bud.mod",0
		;dC.B "e:\mods\s3m\LAVE2.s3m",0
		;dC.B "e:\hors-doe.xm",0
endtestfilename
		EVEN
		ENDC


		OPT O+,OW-

dummy
letsgo		
		MOVE.L 4(SP),A5
		IFEQ test
		LEA $80(A5),A6			; -> length,filename
		ENDC				; then -> testfilename

		MOVE.L $C(A5),A4
		ADD.L $14(A5),A4
		ADD.L $1C(A5),A4
		LEA $100(A4),A4			; proggy size+basepage
		lea my_stack,a7
		PEA (A4)
		PEA (A5)
		CLR -(SP)
		MOVE #$4A,-(SP)
		TRAP #1				; reserve some memory
		LEA 12(SP),SP

		MOVE.B (A6)+,D0 		; get filename length.
		BEQ mustinstall			; no filename given?
		LEA filename(PC),A4
.lp		MOVE.B (A6)+,(A4)+		
		SUBQ.B #1,D0
		BNE.S .lp
		CLR.B (A4)			; terminate filename

		BSR load_mod			; load the module
		
		TST.B errorflag
		BNE load_error			; exit if load error

.notpp		MOVE.L	mt_data_ptr(pc),a0
		BSR	determine_modtype
		BSR print_mainscr		; print main screen
		;MOVE.W	#104,-(SP)
		;TRAP	#14			; DSP LOCK
		;ADDQ.L	#2,SP
		PEA go(PC)
		MOVE.W #$26,-(SP)
		TRAP #14
		ADDQ.L #6,SP
		;MOVE.W	#105,-(SP)
		;TRAP	#14			; DSP UNLOCK
		;ADDQ.L	#2,SP


exitloaderr	move.l	saved_alloc_addr(pc),-(sp)
                move.w  #$49,-(sp)      
		TRAP #1
		ADDQ.L #6,SP
redir		CLR -(SP)
		TRAP #1


;-------------------------------------------------------------------------
; A few error handlers.

load_error	cmp.l #-1024,error_no
		bne.s	.notoutofmem
		PEA outofmem_txt(PC)
		BRA.S .cont
.notoutofmem	CMP.L #-33,error_no
		BNE.S .not_fnf
		PEA filenf_errortxt(PC)
		BRA.S .cont
.not_fnf	PEA load_errortxt(PC)
.cont		MOVE.W #9,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		BSR get_key
		BRA exitloaderr

; No FILENAME was passed error - so tell 'em how to install !!

mustinstall	PEA installtxt(PC)
		MOVE.W #9,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		BSR get_key
		BRA.S redir

	
;-------------------------------------------------------------------------
; Subroutines for interrupts and replay.


; Load that Module

load_mod	LEA filename(PC),A4
		BSR getflength
		move.l	d7,modlength
		add.l	#32,d7
.allocmodmem    move.l  D7,-(sp)
                move.w  #$48,-(sp)      
                trap    #1              	; allocate memory
                addq.l  #6,sp           
		tst.l	d0
		bgt 	okgoforload
		ST.B	errorflag
		move.l	#-1024,error_no
		RTS
okgoforload	move.l	d0,saved_alloc_addr
                add.l  #16,d0           
                and.b   #$f0,d0         	;
		move.l	d0,mt_data_ptr
		LEA loading(PC),A0		; file xxxxxx 
		BSR print			
.loadit		LEA filename(PC),A4
		move.l	mt_data_ptr(pc),a5
		move.l	modlength(pc),d7

.Load_file	SF.B errorflag			; assume no error!
		MOVE #2,-(SP)
		PEA (A4)
		MOVE #$3D,-(SP)
		TRAP #1				; open da file
		ADDQ.L #8,SP
		MOVE D0,D4
		TST.L D0
		BMI.S .error
.read		PEA (A5)
		MOVE.L D7,-(SP)			; length
		MOVE D4,-(SP)			' handle
		MOVE #$3F,-(SP)
		TRAP #1				; read da file
		LEA 12(SP),SP
		TST.L D0
		BMI.S .error
.close		MOVE D4,-(SP)
		MOVE #$3E,-(SP)
		TRAP #1				; close da file!
		ADDQ.L #4,SP
		RTS
 
.error		MOVE.L D0,error_no
		ST.B errorflag			; shit a load error!
		RTS

; Return filelength in d7...

getflength	MOVE.W #$2F,-(SP)		;
		TRAP #1				; get_dta
		ADDQ.L #2,SP
		MOVE.L D0,A6
		CLR -(SP)
		PEA (A4)
		MOVE.W #$4E,-(SP)		; f_sfirst
		TRAP #1
		ADDQ.L #8,SP
		TST.L D0
		BMI.S .flenerr
		MOVE.L 26(A6),D7		; store filelength		
.flenerr	RTS


; Print Main Screen

print_mainscr	LEA thetext(PC),A0		; main text
		BSR print			; draw text
.printplaying	MOVE.L mt_data_ptr,A0
		LEA realmodname(PC),A1
		TST.B (A0)
		BNE.S .okhasname 
		LEA unnamed_mod(PC),A0
.okhasname	CLR D0
.lp1		TST.B (A0)
		BEQ.S .out1 
		MOVE.B (A0)+,(A1)+
		ADDQ #1,D0
		CMP.W #20,D0
		BLE.S .lp1
.out1		MOVE.B #0,(A1)+
		LEA playingtxt(PC),A0
		BSR print			
		LEA module_type_txt(PC),A0
		BSR print
		MOVE.W	mtype(PC),D0
		lea	modtype_str_ptrs-4(pc),a0
		move.l (a0,D0*4),A0			
		BSR print
		BSR print_newline			
print_togstatus	BSR print_interpol_txt

print_tempocon_txt
		LEA 	tempocontrl_txt(PC),A0
		BSR 	print
		MOVE.W 	tempo_flag(pc),d0
		BRA	print_on_off
print_interpol_txt
		LEA 	interpolate_txt(PC),A0
		BSR 	print
		
		MOVE.L interpolate_flag(pc),d0

print_on_off	LEA onoff_txt(PC),A0
		LEA (A0,D0*4),A0
		BRA print
		

print_newline	LEA	newline(pc),a0

; Print Rout -> Text address in A0...  Uses TXPOS and TYPOS (.B)
; (not fast or anything but works nicely thank you!)

print:		pea (a0)
		move.w #9,-(sp)
		trap #1
		addq.l #6,sp
		rts


get_key		MOVE.W	#2,-(SP)
		MOVE.W	#2,-(SP)
		TRAP	#13
		ADDQ.L	#4,SP
		RTS

go		BSR M_SaveSound	
		MOVE.L mt_data_ptr(pc),a0
		BSR M_On 
; Music playing, key selection loop follows(microwire control)
.k_lp		
		BSR	get_key
		CMP.B	#'I',D0
		BEQ.S	.toggleint
		CMP.B	#'i',D0
		BEQ.S	.toggleint
		CMP.B	#'T',D0
		BEQ.S	.toggletmp
		CMP.B	#'t',D0
		BEQ.S	.toggletmp
		BRA.S	.out

.toggleint	EOR.L	#1,interpolate_flag
		BSR 	print_togstatus
		BRA.S	.k_lp
.toggletmp	EOR.W	#1,tempo_flag
		BSR 	print_togstatus
		BRA.S	.k_lp

.out 		BSR M_Off 
		BRA M_RestSound	

; The Player.


wait_flag	EQU 1			; wait for dsp to finish flag.
pre_div		EQU 1			; pre divider(frequency)
freq		EQU ((25175000)/(pre_div+1))/256

M_SaveSound	BRA.W Save_Sound
M_Setup		BRA.W mt_init 
M_On		BRA.W Start_music 
M_Off		BRA.W Stop_music 
M_RestSound	BRA.W Restore_Sound

Save_Sound	LEA old_stuff(PC),A0
		MOVE.W SR,-(SP)
		MOVE.W #$2700,SR
		MOVE.L $134.W,(a0)+
		MOVE.W $ffff8900.W,(A0)+
		MOVE.W $ffff8920.W,(A0)+
		MOVE.L $ffff8930.W,(A0)+
		MOVE.W $ffff8934.W,(A0)+
		MOVE.W $ffff8936.W,(A0)+
		MOVE.W $ffff8938.W,(A0)+
		MOVE.W $ffff893A.W,(A0)+
		MOVE.B $fffffa19.W,(A0)+
		MOVE.B $fffffa1f.W,(A0)+
		MOVE.W (SP)+,SR
		RTS

Restore_Sound	LEA old_stuff(PC),A0
		MOVE.W SR,-(SP)
		MOVE.W #$2700,SR
		MOVE.L (a0)+,$134.W
		MOVE.W (a0)+,$ffff8900.W
		MOVE.W (a0)+,$ffff8920.W
		MOVE.L (a0)+,$ffff8930.W
		MOVE.W (a0)+,$ffff8934.W
		MOVE.W (a0)+,$ffff8936.W
		MOVE.W (a0)+,$ffff8938.W
		MOVE.W (a0)+,$ffff893A.W
		MOVE.B (a0)+,$fffffa19.W
		MOVE.B (a0)+,$fffffa1f.W
		MOVE.W (SP)+,SR
		RTS

Start_music	BSR dsp_boot
		MOVE #%1000000110011001,$FFFF8930.w	; dma output 25mhz clock,no handshake
                MOVE #%1011100100011101,$FFFF8932.w	; dsp out -> dac
                MOVE #0,$FFFF8920.w 		; 16 bit stereo,50khz,play 1 track,dac to track 1
		move.b  #pre_div,$FFFF8935.w  	;49.2khz
                move.b  #2,$FFFF8937.w		;CODEC <- Multiplexor
                move.b  #3,$FFFF8938.w		;L+R <- Soundchip(NOT ADC!)
.wait1		BTST.B #1,$FFFFA202.W
		BEQ.S .wait1
		MOVE.L #freq,$FFFFA204.W	; send dsp frequency to play at.
.wait2		BTST.B #1,$FFFFA202.W
		BEQ.S .wait2
		MOVE.L #3546895,$FFFFA204.W	; send base clock to play at.
		MOVE.W SR,d7
		ori.w #$700,SR
		BSET.B #5,$FFFFFA07.W		;iera
		BSET.B #5,$FFFFFA13.W		;imra
		MOVE.L #music_int,$134.W
		MOVE.B #0,$FFFFFA19.W
		MOVE.B #1,$FFFFFA1F.W
		MOVE.W d7,SR
		MOVE.B #19,$FFFFA201.W		; host command 2
		BCLR #7,$FFFF8901.w  		; select playback register
		BSR Set_DMA
.sync1		BTST.B #0,$FFFFA202.W
		BEQ.S .sync1
		MOVE.L $FFFFA204.W,d0		
.sync2		BTST.B #0,$FFFFA202.W
		BEQ.S .sync2
		MOVE.L $FFFFA204.W,d1	
		MOVE.B #8,$FFFFFA19.W		; timer a event mode.
		NOP
		MOVE #1024+3,$FFFF8900.W	; DMA ON,timer a int
		RTS

Stop_music	MOVE.W SR,-(SP)
		MOVE.W #$2700,SR
		MOVE.B #0,$FFFFFA19.W		; STOP INT
		MOVE.W #0,$FFFF8900.W		; STOP DMA
		BCLR.B #5,$FFFFFA07.W		; iera
		BCLR.B #5,$FFFFFA13.W		; iera
		MOVE.W (SP)+,SR
		RTS

; Music Interrupt

		RSRESET
sam_start	rs.l	1
sam_length	rs.l	1
sam_lpstart	rs.l	1
sam_lplength	rs.l	1
mFPos		rs.l	1
sam_period	rs.w	1
sam_vol		rs.w	1
mLoop		rs.b	1
mOnOff		rs.b	1
cur_start	RS.L 	1
cur_end		RS.L 	1	
cur_lpstart	RS.L 	1
cur_lpend	RS.L 	1
cur_pos		RS.L 	1
cur_lpflag	RS.B 	1
cur_haslpflag	RS.B 	1
mChanBlock_SIZE	rs.b 	0

music_int	
		not.l	$ffff9800.w
		BCLR #5,$fffffa0f.w		
		TAS.B player_sem
		BNE .out
		BSET.B	#7,$ffffa201.w
		BSR Set_DMA
.waitdspexcp	BTST #7,$FFFFA201.w
		BNE.S .waitdspexcp		
		MOVE.W #$2500,SR
		MOVEM.L	D0-D7/A0-A6,-(A7)
		LEA $ffffa207.w,a6
.waitsem1	MOVE.B	-5(a6),d0
		AND.B	#$18,d0
		CMP.B	#$18,d0		; wait for host flag bits to be set.
		BNE.S	.waitsem1
.wait7		BTST.B #1,-5(A6)
		BEQ.S .wait7
		MOVE.L interpolate_flag(pc),$FFFFA204.W	; signal dsp to go!
.wait8		BTST.B #1,-5(A6)
		BEQ.S .wait8
		clr.b	$ffffa205.w
		MOVE.w numchans(pc),$FFFFA206.W

.SEND		LEA 	cha0(PC),A1
		MOVE.W	numchans(PC),D7
.lp2		BSR 	setup_paula
		BSR 	send_voice
		LEA	mChanBlock_SIZE(A1),A1
		SUBQ	#1,D7
		BNE.S	.lp2

;		IFNE wait_flag
;.waitsem2	MOVE.B	-5(a6),d0
;		AND.B	#$18,d0
;		BNE.S	.waitsem2
;		ENDC

		cmp	#mtS3M,mtype
		bne.b	.xm
		bsr	s3m_music
		bra.b	.kool

.xm		cmp	#mtXM,mtype
		bne.b	.mod

		bsr	xm_music
		bra.b	.kool

.mod		
		bsr	mt_music			; Also with MTMs

.kool		;st	paivita

		MOVEM.L	(A7)+,D0-D7/A0-A6
		SF player_sem
.out		
		not.l	$ffff9800.w
		RTE

setup_paula	TST.L	mFPos(a1)
		bmi.s	.nah
		MOVE.L sam_start(A1),D2
		MOVE.L D2,cur_start(A1)
		MOVE.L D2,cur_lpstart(A1)
		MOVE.L D2,cur_pos(A1)
		SF cur_lpflag(A1)
		MOVE.L sam_length(A1),D0
		MOVE.L cur_start(A1),D2
		ADD.L D0,D2
		MOVE.L D2,cur_end(A1)
		MOVE.L D2,cur_lpend(A1)
		MOVE.L sam_lpstart(A1),cur_lpstart(A1)
		MOVE.L sam_lplength(A1),D0
		MOVE.L cur_lpstart(A1),D2
		ADD.L D0,D2
		MOVE.L D2,cur_lpend(A1)
		move.l	#-1,mFPos(a1)
.nah		RTS


; Send 1 voice to the dsp.

send_voice	MOVEQ #0,D0
		MOVE.W sam_vol(A1),d0
		CMP.W #$40,D0
		BLS.S .volok
		MOVEQ #$40,D0
.volok		SWAP D0
.sync		BTST #1,-5(A6)			;;;
		BEQ.S .sync			; send volume 
		MOVE.L D0,-3(A6)		;;; 
		moveq	#0,d0
		MOVE.W sam_period(A1),d0
		lsr.w	#2,d0
.wait1		BTST #1,-5(A6)			;;;
		BEQ.S .wait1			; send 
		move.l	d0,-3(a6)	;;;
		moveq	#0,d1
		cmp.w	#2,fformat
		bne	.send_sign
		move.b	#$80,d1
.send_sign	BTST #1,-5(A6)			; 
		BEQ.S .send_sign		; 
		MOVE.l d1,-3(A6)		; get no. of samples
.wait2		BTST #0,-5(A6)			; 
		BEQ.S .wait2			; 
		MOVE.w -1(A6),D5		; get no. of samples
.s1		BTST #1,-5(A6)			; 
		BEQ.S .s1			; 

		tst.b	mOnOff(a1)
		Bne dmaisoff			; no, then send zeros...
		tst.w	sam_period(a1)
		beq dmaisoff		
		MOVE.L cur_end(A1),A2
		MOVE.L cur_lpend(A1),A3
		MOVE.L cur_pos(A1),A0		; current voice address
		MOVE.L cur_start(A1),A4
		MOVE.L cur_lpstart(A1),A5
		MOVE.B cur_lpflag(A1),D3

do_vce		TST.B D3			; sample looping?
		BNE.S in_loop
in_main		CMP.L A4,A2			; sample start = sample end?
		BLE.S vce_isoffcont
		BRA.S vc_main_cont
in_loop		CMP.L A5,A3
		BLE.S vce_isoffcont
		BRA.S vclp_cont
vc_main_lp	
		MOVE.B (A0)+,(A6)
vc_main_cont	CMP.L A2,A0
		DBGE D5,vc_main_lp
		BLT.S vce_done
hit_looppoint	ST D3
		MOVE.L A5,A0
		CMP.L A5,A3
		BEQ.S vce_isoffcont
		BRA.S vclp_cont
vc_loop_lp	
		MOVE.B (A0)+,(A6)
vclp_cont	CMP.L A3,A0
		DBGE D5,vc_loop_lp
		BLT.S vce_done
vclp_resetlp	MOVE.L A5,A0
		DBF D5,vc_loop_lp
vce_done	MOVE.B D3,cur_lpflag(A1)
		MOVE.L A0,cur_pos(A1)	; store new address
		MOVE.B (A0),(A6)
		RTS

dmaisoff	BRA.S vce_isoffcont
vce_isoff	
.wait		BTST.B #1,-5(A6)
		BEQ.S .wait
		move.b d1,(A6)
vce_isoffcont	DBF D5,vce_isoff
		MOVE.B D3,cur_lpflag(A1)
		MOVE.L A0,cur_pos(A1)	; store new address
.wait		BTST.B #1,-5(A6)
		BEQ.S .wait
		move.b d1,(A6)
		RTS

; Set DMA to buffer(buffer len based on TEMPO)

Set_DMA		MOVEM.L D0/D1,-(SP)
		MOVE.L #dummy,d0
		MOVEQ #0,D1
		MOVE.W RealTempo(PC),D1
		MOVE.W ciaem_tab(PC,D1.W*2),D1
		LSL.L #1,D1
		ADD.L D0,D1
setptrs		MOVE.B d0,$FFFF8907.W
		LSR.L #8,D0
		MOVE.B d0,$FFFF8905.W
		LSR.L #8,D0
		MOVE.B d0,$FFFF8903.W	
		MOVE.B d1,$FFFF8913.W
		LSR.L #8,D1
		MOVE.B d1,$FFFF8911.W
		LSR.L #8,D1
		MOVE.B d1,$FFFF890f.W
		MOVEM.L (SP)+,D0/D1
		RTS
ciaem_tab	INCBIN CIA_EMU.TAB


; Macro to move parameter '\1' into the shadow dma register...
; (Remember - bit 15 of 'dmacon' determines clearing or setting of bits!)

move_dmacon	MACRO
.setdma\@	MOVE.W D4,-(Sp)			; save D4
		MOVE.W \1,D4
		BTST #15,D4			; set or clear?
		BNE.S .setbits\@		
.clearbits\@	NOT.W D4			; zero so clear
		AND.W D4,shadow_dmacon		; mask bits in dmacon
		BRA.S .dmacon_set\@		; and exit...
.setbits\@	OR.W D4,shadow_dmacon		; not zero so set 'em
.dmacon_set\@	MOVE.W (sp)+,D4			; restore D4
		ENDM

determine_modtype:
init	clr	mtype

	move.l	mt_data_ptr,a0
	cmp.l	#'SCRM',44(a0)
	beq	.s3m

	move.l	(a0),d0
	lsr.l	#8,d0
	cmp.l	#'MTM',d0
	beq	.mtm

	move.l	a0,a1
	lea	xmsign,a2
	moveq	#3,d0
.lp	cmpm.l	(a1)+,(a2)+
	bne.b	.j
	dbf	d0,.lp
	bra	.xm

.j	move.l	1080(a0),d0
	cmp.l	#'OCTA',d0
	beq	.fast8
	cmp.l	#'M.K.',d0
	beq	.pro4
	cmp.l	#'M!K!',d0
	beq	.pro4
	cmp.l	#'M&K&',d0
	beq	.pro4
	cmp.l	#'FLT6',d0
	beq	.fast6
	cmp.l	#'FLT8',d0
	beq	.fast8

	move.l	d0,d1
	and.l	#$ffffff,d1
	cmp.l	#'CHN',d1
	beq.b	.chn
	move.l	d0,d1
	cmp.w	#'CH',d1
	beq.b	.ch
	move.l	d0,d1
	swap	d1
	cmp.w	#'FA',d1
	beq.b	.fa

	move.l	d0,d1
	and.l	#$ffffff00,d1
	cmp.l	#"TDZ"<<8,d1
	beq.b	.tdz
	
	moveq	#1,d0
	rts

.chn	move.l	d0,d1
	swap	d1
	lsr	#8,d1
	sub	#'0',d1
	move	#mtMOD,mtype
	move	d1,numchans
	addq	#1,d1
	lsr	d1
	move	d1,maxchan
	bra	.init

.ch	move.l	d0,d1
.fa	
	swap	d1
	sub	#'00',d1
	move	d1,d0
	lsr	#8,d0
	mulu	#10,d0
	and	#$f,d1
	add	d0,d1

	move	#mtMOD,mtype
	move	d1,numchans
	addq	#1,d1
	lsr	d1
	move	d1,maxchan
	bra	.init

.tdz	and.l	#$ff,d0
	sub	#'0',d0
	move	#mtMOD,mtype
	move	d0,numchans
	addq	#1,d0
	lsr	d0
	move	d0,maxchan
	bra.b	.init

.fast8	move	#mtMOD,mtype
	move	#8,numchans
	move	#4,maxchan
	bra.b	.init
.fast6	move	#mtMOD,mtype
	move	#6,numchans
	move	#3,maxchan
	bra.b	.init

.pro4	move	#mtMOD,mtype
	move	#4,numchans
	move	#2,maxchan
	bra.b	.init

.mtm	move	#mtMTM,mtype
	bra.b	.init

.xm	cmp	#$401,xmVersion(a0)		; Kool turbo-optimizin'...
	bne	.j
	move	#mtXM,mtype
	bra.b	.init

.s3m	move	#mtS3M,mtype


.init

; TEMPORARY BUGFIX...

	cmp	#2,maxchan
	bhs.b	.opk

	move	#2,maxchan

.opk	tst	mtype
	beq.b	.error

	cmp	#mtS3M,mtype
	beq	s3m_init

	cmp	#mtMOD,mtype
	beq	mt_init

	cmp	#mtMTM,mtype
	beq	mtm_init

	cmp	#mtXM,mtype
	beq	xm_init

.error	moveq	#1,d0
	rts

; Decrunch routine from FImp v2.34 by A.J. Brouwer
; A0 must be pointing at the start of the decrunched data

FImp_decrunch
	movem.l	d2-d5/a2-a4,-(a7)
	move.l	a0,a3
	move.l	a0,a4
	tst.l	(a0)+
	adda.l	(a0)+,a4
	adda.l	(a0)+,a3
	move.l	a3,a2
	move.l	(a2)+,-(a0)
	move.l	(a2)+,-(a0)
	move.l	(a2)+,-(a0)
	move.l	(a2)+,d2
	move	(a2)+,d3
	bmi.b	lb_180e
	subq.l	#1,a3
lb_180e	lea	-$1c(a7),a7
	move.l	a7,a1
	moveq	#6,d0
lb_1816	move.l	(a2)+,(a1)+
	dbf	d0,lb_1816
	move.l	a7,a1
	bra.b	lb_1e90
lb_1822	moveq	#0,d0
	rts
lb_1e90	tst.l	d2
	beq.b	lb_1e9a
lb_1e94	move.b	-(a3),-(a4)
	subq.l	#1,d2
	bne.b	lb_1e94
lb_1e9a	cmpa.l	a4,a0
	bcs.b	lb_1eb2
	lea	$1c(a7),a7
	moveq	#-1,d0
	cmpa.l	a3,a0
	beq.b	lb_1eaa
	moveq	#0,d0
lb_1eaa	movem.l	(a7)+,d2-d5/a2-a4
	tst.l	d0
	rts
lb_1eb2	add.b	d3,d3
	bne.b	lb_1eba
	move.b	-(a3),d3
	addx.b	d3,d3
lb_1eba	bcc.b	lb_1f24
	add.b	d3,d3
	bne.b	lb_1ec4
	move.b	-(a3),d3
	addx.b	d3,d3
lb_1ec4	bcc.b	lb_1f1e
	add.b	d3,d3
	bne.b	lb_1ece
	move.b	-(a3),d3
	addx.b	d3,d3
lb_1ece	bcc.b	lb_1f18
	add.b	d3,d3
	bne.b	lb_1ed8
	move.b	-(a3),d3
	addx.b	d3,d3
lb_1ed8	bcc.b	lb_1f12
	moveq	#0,d4
	add.b	d3,d3
	bne.b	lb_1ee4
	move.b	-(a3),d3
	addx.b	d3,d3
lb_1ee4	bcc.b	lb_1eee
	move.b	-(a3),d4
	moveq	#3,d0
	subq.b	#1,d4
	bra.b	lb_1f28
lb_1eee	add.b	d3,d3
	bne.b	lb_1ef6
	move.b	-(a3),d3
	addx.b	d3,d3
lb_1ef6	addx.b	d4,d4
	add.b	d3,d3
	bne.b	lb_1f00
	move.b	-(a3),d3
	addx.b	d3,d3
lb_1f00	addx.b	d4,d4
	add.b	d3,d3
	bne.b	lb_1f0a
	move.b	-(a3),d3
	addx.b	d3,d3
lb_1f0a	addx.b	d4,d4
	addq.b	#5,d4
	moveq	#3,d0
	bra.b	lb_1f28
lb_1f12	moveq	#4,d4
	moveq	#3,d0
	bra.b	lb_1f28
lb_1f18	moveq	#3,d4
	moveq	#2,d0
	bra.b	lb_1f28
lb_1f1e	moveq	#2,d4
	moveq	#1,d0
	bra.b	lb_1f28
lb_1f24	moveq	#1,d4
	moveq	#0,d0
lb_1f28	moveq	#0,d5
	move	d0,d1
	add.b	d3,d3
	bne.b	lb_1f34
	move.b	-(a3),d3
	addx.b	d3,d3
lb_1f34	bcc.b	lb_1f4c
	add.b	d3,d3
	bne.b	lb_1f3e
	move.b	-(a3),d3
	addx.b	d3,d3
lb_1f3e	bcc.b	lb_1f48
	move.b	lb_1fac(pc,d0),d5
	addq.b	#8,d0
	bra.b	lb_1f4c
lb_1f48	moveq	#2,d5
	addq.b	#4,d0
lb_1f4c	move.b	lb_1fb0(pc,d0),d0
lb_1f50	add.b	d3,d3
	bne.b	lb_1f58
	move.b	-(a3),d3
	addx.b	d3,d3
lb_1f58	addx	d2,d2
	subq.b	#1,d0
	bne.b	lb_1f50
	add	d5,d2
	moveq	#0,d5
	move.l	d5,a2
	move	d1,d0
	add.b	d3,d3
	bne.b	lb_1f6e
	move.b	-(a3),d3
	addx.b	d3,d3
lb_1f6e	bcc.b	lb_1f8a
	add	d1,d1
	add.b	d3,d3
	bne.b	lb_1f7a
	move.b	-(a3),d3
	addx.b	d3,d3
lb_1f7a	bcc.b	lb_1f84
	move	8(a1,d1),a2
	addq.b	#8,d0
	bra.b	lb_1f8a
lb_1f84	move	(a1,d1),a2
	addq.b	#4,d0
lb_1f8a	move.b	16(a1,d0),d0
lb_1f8e	add.b	d3,d3
	bne.b	lb_1f96
	move.b	-(a3),d3
	addx.b	d3,d3
lb_1f96	addx.l	d5,d5
	subq.b	#1,d0
	bne.b	lb_1f8e
	addq	#1,a2
	adda.l	d5,a2
	adda.l	a4,a2
lb_1fa2	move.b	-(a2),-(a4)
	dbf	d4,lb_1fa2
	bra	lb_1e90

lb_1fac	dc.b	6,10,10,18
lb_1fb0	dc.b	1,1,1,1,2,3,3,4
	dc.b	4,5,7,14


;;******** Init routines ***********


detectchannels
	lea	ch(pc),a0
	moveq	#7,d0
.l2	clr.l	(a0)+
	dbf	d0,.l2

	move.l	patts,a1
	lea	ch(pc),a2
	MOVE.L	mt_data_ptr(pc),a0
	move	pats,d7
	subq	#1,d7
.pattloop
	moveq	#0,d0
	move	(a1)+,d0
	iword	d0
	lsl.l	#4,d0
	lea	(a0,d0.l),a3
	addq.l	#2,a3
	moveq	#63,d6
.rowloop
	move.b	(a3)+,d0
	beq.b	.newrow

	moveq	#31,d1
	and	d0,d1

	moveq	#32,d2
	and	d0,d2
	beq.b	.nnot

	tst.b	(a3)
	bmi.b	.skip

	tst.b	1(a3)
	bmi.b	.skip

	st	(a2,d1)

.skip	addq.l	#2,a3

.nnot	moveq	#64,d2
	and	d0,d2
	beq.b	.nvol

	addq.l	#1,a3

.nvol	and	#128,d0
	beq.b	.rowloop

	move.b	(a3),d0
	cmp.b	#1,d0
	blo.b	.skip2

	cmp.b	#'Z'-64,d0
	bhi.b	.skip2

	st	(a2,d1)

.skip2	addq.l	#2,a3
	bra.b	.rowloop

.newrow
	dbf	d6,.rowloop
	dbf	d7,.pattloop	

	moveq	#1,d0
	moveq	#1,d1
	moveq	#31,d7
	moveq	#0,d5
	moveq	#0,d6
	lea	$40(a0),a1
	lea	pantab,a0
.lp	clr.b	(a0)
	tst.b	(a2)+
	beq.b	.d

	move.b	(a1),d2
	bmi.b	.d
	cmp.b	#8,d2
	blo.b	.vas
	move.b	#-1,(a0)
	move	d1,d0
	addq	#1,d5
	bra.b	.d
.vas	move.b	#1,(a0)
	move	d1,d0
	addq	#1,d6
.d	addq.l	#1,a1
	addq.l	#1,a0
	addq	#1,d1
	dbf	d7,.lp

	cmp	d5,d6
	bls.b	.k	
	move	d6,d5
.k	move	d5,maxchan
	move.w	#8,numchans
	;move	d0,numchans
ret	rts

ch	ds.b	32

;********** S3M Play Routine **********


;/***************************************************************************\
;*       struct s3mChanBlock
;*       -------------------
;* Description:  S3M and XM player channel block
;\***************************************************************************/

		rsreset
nt		rs.b	1
inst		rs.b	1
vol		rs.b	1
cmd		rs.b	1
info		rs.b	1
flgs		rs.b	1
sample		rs.l	1
linst		rs.w	1
period		rs.w	1
volume		rs.w	1
note		rs.b	1
lastcmd		rs.b	1
toperiod 	rs.w	1
notepspd 	rs.b	1
panning		rs.b	1
rVolume		rs.w	1
rPeriod		rs.w	1
fadeOut		rs.w	1
fading		rs.b	1
keyoff		rs.b	1
age		rs.b	1
filler		rs.b	1
retrigcn	rs.b	1
vibcmd		rs.b	1
vibpos		rs.b	1
lastOffset	rs.b	1
volEnvOn	rs.b	1
volCurPnt	rs.b	1
volEnvX		rs.w	1
volEnvY		rs.w	1
volEnvDelta	rs.w	1
volRecalc	rs.b	1
volSustained	rs.b	1
panEnvOn	rs.b	1
panCurPnt	rs.b	1
panEnvX		rs.w	1
panEnvY		rs.w	1
panEnvDelta	rs.w	1
panRecalc	rs.b	1
panSustained	rs.b	1
s3mChanBlock_SIZE	rs.b	0


;/***************************************************************************\
;*       struct s3mInstHdr
;*       -----------------
;* Description:  S3M instrument header
;\***************************************************************************/

		rsreset
instype		rs.b	1
insdosname	rs.b	12
inssig1		rs.b	1
insmemseg	rs.w	1
inslength	rs.l	1
insloopbeg	rs.l	1
insloopend	rs.l	1
insvol		rs.b	1
insdsk		rs.b	1
inspack		rs.b	1
insflags	rs.b	1
insloc2spd	rs.w	1
inshic2spd	rs.w	1
inssig2		rs.b	4
insgvspos	rs.w	1
insint512	rs.w	1
insintlastused	rs.l	1
insname		rs.b	28
inssig		rs.b	4
s3mInstHdr_SIZE	rs.b	0

;/***************************************************************************\
;*       struct s3mHeader
;*       ----------------
;* Description:  S3M main header
;\***************************************************************************/

		rsreset
name		rs.b	28
sig1		rs.b	1
type		rs.b	1
sig2		rs.b	2
ordernum	rs.w	1
insnum		rs.w	1
patnum		rs.w	1
flags		rs.w	1
cwtv		rs.w	1
ffv		rs.w	1
s3msig		rs.b	4
mastervol	rs.b	1
initialspeed	rs.b	1
initialtempo	rs.b	1
mastermul	rs.b	1
sig3		rs.b	12
chanset		rs.b	32
orders		rs.b	1
s3mHeader_SIZE	rs.b	0


s3m_init
	move	ordernum(a0),d0
	iword	d0
	move	d0,slen
	move	d0,positioneita

	move	patnum(a0),d0
	iword	d0
	move	d0,pats

	move	insnum(a0),d0
	iword	d0
	move	d0,inss

	move	ffv(a0),d0
	iword	d0
	move	d0,fformat

	move	flags(a0),d0
	iword	d0
	move	d0,sflags

	lea	$60(a0),a1
	moveq	#0,d0
	move	slen,d0
	moveq	#1,d1
	and	d0,d1
	add	d1,d0
	lea	(a1,d0.l),a2
	move.l	a2,samples

	move	inss,d0
	add	d0,d0
	lea	(a2,d0.l),a3
	move.l	a3,patts

	moveq	#0,d0
	move.b	(a1),d0
	add	d0,d0
	move	(a3,d0),d0
	iword	d0
	asl.l	#4,d0
	lea	2(a0,d0.l),a1
	move.l	a1,ppos

	moveq	#0,d0
	move.b	initialspeed(a0),d0
	move	d0,spd

	move.b	initialtempo(a0),d0
	bne.b	.qw
	moveq	#125,d0
.qw	move	d0,RealTempo

	clr	pos
	move	#63,rows
	clr	cn

	bsr	detectchannels
	moveq	#0,d0
	rts

s3m_music
	move.l	mt_data_ptr,a0
	addq	#1,cn
	move	cn,d0
	cmp	spd,d0
	beq.b	uusrow

ccmds	lea	c0,a2
	lea	cha0,a4
	move	numchans,d7
	subq	#1,d7
.loo	btst	#7,5(a2)
	beq.b	.edi

	lea	cct(pc),a1
	moveq	#0,d0
	move.b	cmd(a2),d0
	cmp	#'Z'-'@',d0
	bgt.b	.edi
	add	d0,d0
	move	(a1,d0),d0
	jsr	(a1,d0)

.edi	lea	s3mChanBlock_SIZE(a2),a2
	lea	mChanBlock_SIZE(a4),a4
	dbf	d7,.loo
	rts

uusrow	clr	cn

	lea	c0,a2
	move	numchans,d7
	subq	#1,d7
.cl	clr.b	flgs(a2)
	lea	s3mChanBlock_SIZE(a2),a2
	dbf	d7,.cl

	move.l	ppos,a1
	lea	c0,a4		;chanblocks
.loo	move.b	(a1)+,d0
	beq.b	.end

	moveq	#$1f,d5
	and	d0,d5			;chan
	mulu	#s3mChanBlock_SIZE,d5
	lea	(a4,d5),a2

	and	#~31,d0
	move.b	d0,flgs(a2)
	
	moveq	#32,d2
	and	d0,d2
	beq.b	.nnot

	move.b	(a1)+,(a2)
	move.b	(a1)+,inst(a2)

.nnot	moveq	#64,d2
	and	d0,d2
	beq.b	.nvol

	move.b	(a1)+,vol(a2)

.nvol	and	#128,d0
	beq.b	.loo

	move.b	(a1)+,d0
	bmi.b	.d
	move.b	d0,cmd(a2)
.d	move.b	(a1)+,info(a2)
	bra.b	.loo

.end	move.l	a1,ppos

process	lea	c0,a2
	lea	cha0,a4
	move	numchans,d7
	move.l	samples,a5
	subq	#1,d7
.lloo	tst.b	5(a2)
	beq	.evol

	moveq	#32,d0
	and.b	flgs(a2),d0
	beq	.f

	move.b	inst(a2),d0
	beq	.esmp
	bmi	.esmp

	cmp	inss,d0
	bgt	.mute

	btst	#7,flgs(a2)
	beq.b	.eii
	cmp.b	#'S'-'@',cmd(a2)
	bne.b	.eii
	move.b	info(a2),d1
	and	#$f0,d1
	cmp	#$d0,d1
	beq	.evol

.eii	add	d0,d0
	move	-2(a5,d0),d0
	iword	d0
	lsl	#4,d0
	lea	(a0,d0),a1

	moveq	#0,d0
	move	insmemseg(a1),d0
	iword	d0
	lsl.l	#4,d0
	move.l	a0,d4
	add.l	d0,d4

	move.l	insloopbeg(a1),d1
	ilword	d1
	move.l	insloopend(a1),d2
	ilword	d2
	sub.l	d1,d2
	add.l	d4,d1

	move.l	d1,sam_lpstart(a4)
	move.l	d2,sam_lplength(a4)
	move.b	insvol(a1),volume+1(a2)
	cmp	#64,volume(a2)
	blo.b	.e
	move	#63,volume(a2)
.e	move	volume(a2),sam_vol(a4)

	move.l	a1,sample(a2)

	btst	#0,insflags(a1)
	beq.b	.eloo
	cmp.l	#2,d2
	bls.b	.eloo
	st	mLoop(a4)
	bra.b	.esmp

.mute	st	mOnOff(a4)
	bra	.f

.eloo	clr.b	mLoop(a4)

.esmp	moveq	#0,d0
	move.b	(a2),d0
	beq	.f
	cmp.b	#254,d0
	beq.b	.mute
	cmp.b	#255,d0
	beq	.f

	move.b	d0,note(a2)
	move	d0,d1
	lsr	#4,d1

	and	#$f,d0
	add	d0,d0

	move.l	sample(a2),a1
	move.l	$20(a1),d2
	ilword	d2

	lea	Periods(pc),a1
	move	(a1,d0),d0
	mulu	#8363,d0
	lsl.l	#4,d0
	lsr.l	d1,d0	

	divu	d2,d0


	btst	#7,flgs(a2)
	beq.b	.ei

	cmp.b	#'Q'-'@',cmd(a2)	;retrig
	beq.b	.eiik

.ei	clr.b	retrigcn(a2)

.eiik	clr.b	vibpos(a2)


	btst	#7,flgs(a2)
	beq.b	.eitopo

	cmp.b	#'G'-'@',cmd(a2)	;TOPO
	beq.b	.eddo

	cmp.b	#'L'-'@',cmd(a2)	;TOPO+VSLD
	bne.b	.eitopo

.eddo	move	d0,toperiod(a2)
	bra.b	.f

.eitopo	move	d0,sam_period(a4)
	move	d0,period(a2)
	clr.l	mFPos(a4)

	move.l	sample(a2),d0
	beq.b	.f
	move.l	d0,a1

	moveq	#0,d0
	move	insmemseg(a1),d0
	iword	d0
	lsl.l	#4,d0
	move.l	a0,d4
	add.l	d0,d4

	move.l	inslength(a1),d0
	ilword	d0

	move.l	d4,(a4)
	move.l	d0,sam_length(a4)
	clr.b	mOnOff(a4)

.f	moveq	#64,d0
	and.b	flgs(a2),d0
	beq.b	.evol
	move.b	vol(a2),volume+1(a2)
	cmp	#64,volume(a2)
	blo.b	.evol
	move	#63,volume(a2)

.evol	btst	#7,flgs(a2)
	beq.b	.eivib

	cmp.b	#'H'-'@',cmd(a2)
	beq.b	.vib

.eivib	bsr	checklimits
.vib

	btst	#7,flgs(a2)
	beq.b	.eitre

	cmp.b	#'R'-'@',cmd(a2)
	beq.b	.tre
	cmp.b	#'I'-'@',cmd(a2)
	beq.b	.tre

.eitre	move	volume(a2),sam_vol(a4)

.tre	btst	#7,flgs(a2)
	beq.b	.edd

	move.b	info(a2),d0
	beq.b	.dd
	move.b	d0,lastcmd(a2)
.dd	lea	ct(pc),a1
	moveq	#0,d0
	move.b	cmd(a2),d0
	cmp	#'Z'-'@',d0
	bgt.b	.edd

	add	d0,d0
	move	(a1,d0),d0
	jsr	(a1,d0)

.edd	lea	s3mChanBlock_SIZE(a2),a2
	lea	mChanBlock_SIZE(a4),a4
	dbf	d7,.lloo

	subq	#1,rows
	bpl.b	dee

burk	addq	#1,pos
	move	slen,d0
	cmp	pos,d0
	bgt.b	.ee

.alkd	clr	pos
	st	PS3M_break
	move.b	initialspeed(a0),spd+1

.ee	move	pos,d0

	move.l	patts,a3
	moveq	#0,d1
	move.b	$60(a0,d0),d1
	cmp.b	#$fe,d1
	beq.b	burk
	cmp.b	#$ff,d1
	beq.b	burk

	add	d1,d1

	moveq	#0,d0
	move	(a3,d1),d0
	iword	d0
	asl.l	#4,d0
	lea	2(a0,d0.l),a1
	move.l	a1,ppos

	move	#63,rows

	move	pos,d0
	move	d0,PS3M_position
	st	PS3M_poschan

dee	bra	xm_dee


ct	dc	rt-ct
	dc	changespeed-ct
	dc	posjmp-ct
	dc	patbrk-ct
	dc	vslide-ct
	dc	portadwn-ct
	dc	portaup-ct
	dc	rt-ct
	dc	rt-ct
	dc	tremor-ct
	dc	arpeggio-ct
	dc	rt-ct
	dc	rt-ct
	dc	rt-ct
	dc	rt-ct
	dc	soffset-ct
	dc	rt-ct
	dc	retrig-ct
	dc	rt-ct
	dc	rt-ct
	dc	stempo-ct
	dc	rt-ct
	dc	setmaster-ct
	dc	rt-ct
	dc	rt-ct
	dc	rt-ct
	dc	rt-ct



cct	dc	rt-cct
	dc	rt-cct
	dc	rt-cct
	dc	rt-cct
	dc	vslide-cct
	dc	portadwn-cct
	dc	portaup-cct
	dc	noteporta-cct
	dc	vibrato-cct
	dc	tremor-cct
	dc	arpeggio-cct
	dc	vvslide-cct
	dc	pvslide-cct
	dc	rt-cct
	dc	rt-cct
	dc	rt-cct
	dc	rt-cct
	dc	retrig-cct
	dc	tremolo-cct
	dc	specials-cct
	dc	rt-cct
	dc	rt-cct
	dc	rt-cct
	dc	rt-cct
	dc	rt-cct
	dc	rt-cct
	dc	rt-cct

tremor
tremolo
rt	rts


changespeed
	move.b	info(a2),d0
	bne.b	.e
	st	PS3M_break
.e	move.b	info(a2),spd+1
	rts

posjmp	clr	rows
	move.b	info(a2),pos+1
	subq	#1,pos
	st	PS3M_poschan
	rts

patbrk	clr	rows
	st	PS3M_poschan
	rts

vslide	moveq	#0,d0
	move.b	lastcmd(a2),d0
	moveq	#$f,d1
	and	d0,d1
	move	d0,d2
	lsr	#4,d2

	cmp.b	#$f,d1
	beq.b	.addfine

	cmp.b	#$f,d2
	beq.b	.subfine
	
	tst	d1
	beq.b	.add
	and	#$f,d0
	bra.b	.sub

.subfine
	tst	cn
	bne.b	.dd
	and	#$f,d0
.sub	sub	d0,volume(a2)
	bpl.b	.dd
	clr	volume(a2)
.dd	move	volume(a2),sam_vol(a4)
	rts

.addfine
	tst	d2
	beq.b	.sub
	tst	cn
	bne.b	.dd
.add	lsr	#4,d0

.add2	add	d0,volume(a2)
	cmp	#64,volume(a2)
	blo.b	.dd
	move	#63,volume(a2)
	bra.b	.dd


portadwn
	moveq	#0,d0
	move.b	lastcmd(a2),d0

	tst	cn
	beq.b	.fined
	cmp.b	#$e0,d0
	bhs.b	.dd
	lsl	#2,d0

.ddd	add	d0,period(a2)
	bra.b	checklimits
.dd	rts

.fined	cmp.b	#$e0,d0
	bls.b	.dd
	cmp.b	#$f0,d0
	bls.b	.extr
	and	#$f,d0
	lsl	#2,d0
	bra.b	.ddd

.extr	and	#$f,d0
	bra.b	.ddd

portaup
	moveq	#0,d0
	move.b	lastcmd(a2),d0

	tst	cn
	beq.b	.fined
	cmp.b	#$e0,d0
	bhs.b	.dd
	lsl	#2,d0

.ddd	sub	d0,period(a2)
	bra.b	checklimits

.dd	rts

.fined	cmp.b	#$e0,d0
	bls.b	.dd
	cmp.b	#$f0,d0
	bls.b	.extr
	and	#$f,d0
	lsl	#2,d0
	bra.b	.ddd

.extr	and	#$f,d0
	bra.b	.ddd


checklimits
	move	period(a2),d0
	btst	#4,sflags+1
	beq.b	.sii
	
	cmp	#856*4,d0
	bls.b	.dd
	move	#856*4,d0
.dd	cmp	#113*4,d0
	bhs.b	.dd2
	move	#113*4,d0
.dd2	move	d0,period(a2)
	move	d0,sam_period(a4)
	rts

.sii	cmp	#$7fff,d0
	bls.b	.dd3
	move	#$7fff,d0
.dd3	cmp	#64,d0
	bhs.b	.dd4
	move	#64,d0
.dd4	move	d0,sam_period(a4)
	rts


noteporta
	move.b	info(a2),d0
	beq.b	notchange
	move.b	d0,notepspd(a2)
notchange
	move	toperiod(a2),d0
	beq.b	.1
	moveq	#0,d1
	move.b	notepspd(a2),d1
	lsl	#2,d1

	cmp	period(a2),d0
	blt.b	.topoup

	add	d1,period(a2)
	cmp	period(a2),d0
	bgt.b	.1
	move	d0,period(a2)
	clr	toperiod(a2)
.1	move	period(a2),sam_period(a4)
	rts

.topoup	sub	d1,period(a2)
	cmp	period(a2),d0
	blt.b	.dd
	move	d0,period(a2)
	clr	toperiod(a2)
.dd	move	period(a2),sam_period(a4)
	rts


vibrato	move.b	cmd(a2),d0
	bne.b	.e
	move.b	vibcmd(a2),d0
	bra.b	vibskip2

.e	move	d0,d1
	and	#$f0,d1
	bne.b	vibskip2

	move.b	vibcmd(a2),d1
	and	#$f0,d1
	or	d1,d0

vibskip2
	move.b	d0,vibcmd(a2)

vibrato2
	moveq	#$1f,d0
	and.b	vibpos(a2),d0
	moveq	#0,d2
	lea	mt_vibratotable(pc),a3
	move.b	(a3,d0),d2
	moveq	#$f,d0
	and.b	vibcmd(a2),d0
	mulu	d0,d2

	moveq	#4,d0
	btst	#0,sflags+1
	bne.b	.sii
	moveq	#5,d0
.sii	lsr	d0,d2
	move	period(a2),d0
	btst	#5,vibpos(a2)
	bne.b	.neg
	add	d2,d0
	bra.b	.vib3
.neg
	sub	d2,d0
.vib3
	move	d0,sam_period(a4)
	move.b	vibcmd(a2),d0
	lsr.b	#4,d0
	add.b	d0,vibpos(a2)
	rts


arpeggio
	moveq	#0,d0
	move.b	note(a2),d0
	beq.b	.qq

	moveq	#$70,d1
	and	d0,d1
	and	#$f,d0

	moveq	#0,d2
	move	cn,d2
	divu	#3,d2
	swap	d2
	tst	d2
	beq.b	.norm
	subq	#1,d2
	beq.b	.1

	moveq	#$f,d2
	and.b	lastcmd(a2),d2
	add	d2,d0
.f	cmp	#12,d0
	blt.b	.norm
	sub	#12,d0
	add	#$10,d1
	bra.b	.f

.1	move.b	lastcmd(a2),d2
	lsr.b	#4,d2
	add.b	d2,d0
.f2	cmp	#12,d0
	blt.b	.norm
	sub	#12,d0
	add	#$10,d1
	bra.b	.f2

.norm	add	d0,d0
	lsr	#4,d1

	move.l	sample(a2),a1

	move.l	$20(a1),d2
	ilword	d2

	lea	Periods(pc),a1
	move	(a1,d0),d0
	mulu	#8363,d0
	lsl.l	#4,d0
	lsr.l	d1,d0
	divu	d2,d0
	move	d0,sam_period(a4)
.qq	rts


pvslide	bsr	notchange
	bra	vslide

vvslide	bsr	vibrato2
	bra	vslide

soffset	move.l	(a4),d0
	move.l	sam_length(a4),d1
	moveq	#0,d2
	move.b	lastcmd(a2),d2
	lsl.l	#8,d2
	add.l	d2,d0
	sub.l	d2,d1
	bpl.b	.ok
	move.l	sam_lpstart(a4),d0
	move.l	sam_lplength(a4),d1
.ok	move.l	d0,(a4)
	move.l	d1,sam_length(a4)
	rts


retrig	move.b	retrigcn(a2),d0
	subq.b	#1,d0
	cmp.b	#0,d0
	ble.b	.retrig

	move.b	d0,retrigcn(a2)
	rts

.retrig
	move.l	sample(a2),a1
	moveq	#0,d1
	move	insmemseg(a1),d1
	iword	d1
	lsl.l	#4,d1
	move.l	a0,d4
	add.l	d1,d4

	move.l	inslength(a1),d1
	ilword	d1

	move.l	d4,(a4)
	move.l	d1,sam_length(a4)
	clr.b	mOnOff(a4)
	clr.l	mFPos(a4)

	move.b	lastcmd(a2),d0
	moveq	#$f,d1
	and.b	d0,d1
	and	#$f0,d0
	move.b	d1,retrigcn(a2)

	lsr	#4,d0
	moveq	#0,d2
	lea	ftab2(pc),a3
	move.b	(a3,d0),d2
	beq.b	.ddq

	mulu	volume(a2),d2
	lsr	#4,d2
	move	d2,volume+1(a2)
	bra.b	.ddw

.ddq	lea	ftab1(pc),a3
	move.b	(a3,d0),d2
	ext	d2
	add	d2,volume(a2)

.ddw	tst	volume(a2)
	bpl.b	.ei0
	clr	volume(a2)
.ei0	cmp	#64,volume+1(a2)
	blo.b	.ei64
	move	#63,volume(a2)
.ei64	move	volume(a2),sam_vol(a4)
	rts

specials
ncut_delay
	move.b	info(a2),d0
	and	#$f0,d0
	cmp	#$d0,d0
	beq.b	.delay
	cmp	#$c0,d0
	bne.b	.dd

	move.b	info(a2),d0
	and	#$f,d0
	cmp	cn,d0
	bne.b	.dd
	clr	volume(a2)
	clr	sam_vol(a4)
.dd	rts

.delay	move.b	info(a2),d0
	and	#$f,d0
	cmp	cn,d0
	bne.b	.dd
	
	moveq	#32,d0
	and.b	flgs(a2),d0
	beq	.f

	move.b	inst(a2),d0
	beq	.esmp
	bmi	.esmp

	cmp	inss,d0
	bgt.b	.dd

	move.l	samples,a5
	add	d0,d0
	move	-2(a5,d0),d0
	iword	d0
	asl	#4,d0
	lea	(a0,d0),a1

	moveq	#0,d0
	move	insmemseg(a1),d0
	iword	d0
	asl.l	#4,d0
	move.l	a0,d4
	add.l	d0,d4

	move.l	insloopbeg(a1),d1
	ilword	d1
	move.l	insloopend(a1),d2
	ilword	d2
	sub.l	d1,d2
	add.l	d4,d1

	move.l	inslength(a1),d0
	ilword	d0

	move.l	d4,(a4)
	move.l	d0,sam_length(a4)
	move.l	d1,sam_lpstart(a4)
	move.l	d2,sam_lplength(a4)
	move.b	insvol(a1),volume+1(a2)
	cmp	#64,volume(a2)
	blo.b	.e
	move	#63,volume(a2)
.e	move	volume(a2),sam_vol(a4)
	clr.b	mOnOff(a4)

	move.l	a1,sample(a2)

	btst	#0,insflags(a1)
	beq.b	.eloo
	cmp.l	#2,d2
	bls.b	.eloo
	st	mLoop(a4)
	bra.b	.esmp
.eloo	clr.b	mLoop(a4)

.esmp	moveq	#0,d0
	move.b	(a2),d0
	beq.b	.f
	bmi.b	.f

	moveq	#$70,d1
	and	d0,d1
	lsr	#4,d1

	and	#$f,d0
	add	d0,d0

	move.l	sample(a2),a1

	move.l	$20(a1),d2
	ilword	d2

	lea	Periods(pc),a1
	move	(a1,d0),d0
	mulu	#8363,d0
	lsl.l	#4,d0
	lsr.l	d1,d0
	divu	d2,d0

	move	d0,sam_period(a4)
	move	d0,period(a2)
	clr.l	mFPos(a4)
	clr.b	vibpos(a2)

.f	moveq	#64,d0
	and.b	flgs(a2),d0
	beq.b	.evol
	move.b	vol(a2),volume+1(a2)
	cmp	#64,volume(a2)
	blo.b	.evol
	move	#63,volume(a2)
.evol
	move	volume(a2),sam_vol(a4)
	rts


stempo	moveq	#0,d0
	move.b	info(a2),d0
	beq.b	.e
	move.w	d0,RealTempo
	;move.l	mrate,d1
	;move.l	d1,d2
	;lsl.l	#2,d1
	;add.l	d2,d1
	;add	d0,d0
	;divu	d0,d1

	;addq	#1,d1
	;and	#~1,d1
	;move	d1,bytesperframe
.e	rts

setmaster
	moveq	#0,d0
	move.b	info(a2),d0
	cmp	#64,d0
	bls.b	.d
	moveq	#64,d0
.d	move	d0,PS3M_master

	mulu	#-1,d0
	divu	#64,d0
	move	d0,d1

	moveq	#-1,d0
	clr	d0
	swap	d0
	divu	#65,d0
	move	d0,d3

	rts

Periods
	dc.w	1712,1616,1524,1440,1356,1280,1208,1140,1076,1016,960,907

ftab1	dc.b	0,-1,-2,-4,-8,-16,0,0
	dc.b	0,1,2,4,8,16,0,0

ftab2	dc.b	0,0,0,0,0,0,10,8
	dc.b	0,0,0,0,0,0,24,32


********** Fasttracker ][ XM player **************

;/***************************************************************************\
;*       struct xmHeader
;*       ---------------
;* Description:  Extended Module file header
;\***************************************************************************/

		rsreset
xmExtended	rs.b	17		; "Extended Module: "
xmName		rs.b	20		; module name
xmNum1A		rs.b	1		; 0x1A
xmTrackerName	rs.b	20		; tracker name
xmVersion	rs.w	1		; version number, major-minor
xmHdrSize	rs.l	1		; header size
xmSongLength	rs.w	1		; song length
xmRestart	rs.w	1		; restart position
xmNumChans	rs.w	1		; number of channels
xmNumPatts	rs.w	1		; number of patterns
xmNumInsts	rs.w	1		; number of instruments
xmFlags		rs.w	1		; flags
xmSpeed		rs.w	1		; initial speed
xmTempo		rs.w	1		; initial tempo
xmOrders	rs.b	256		; pattern order table
xmHeader_SIZE	rs.b	0

; Flag bits:

xmLinearFreq = 0			; linear frequency table

;/***************************************************************************\
;*       struct xmPattHdr
;*       ----------------
;* Description:  Fasttracker 2 Extended Module pattern header
;\***************************************************************************/

		rsreset
xmPattHdrLength	rs.l	1		; pattern header length
xmPackType	rs.b	1		; packing type (now 0)
xmNumRows	rs.w	1		; number of rows
xmPattDataSize	rs.w	1		; pattern data size
xmPattData				; packed pattern data
xmPattHdr_SIZE	rs.b	0



;/***************************************************************************\
;*       struct xmInstHdr
;*       ----------------
;* Description:  Fasttracker 2 Extended Module instrument header
;\***************************************************************************/

		rsreset
xmInstSize	rs.l	1		; instrument size
xmInstName	rs.b	22		; instrument filename
xmInstType	rs.b	1	; instrument type (now 0)
xmNumSamples	rs.w	1		; number of samples in instrument
xmInstHdr_SIZE	rs.b	0	; If numSamples > 0, this will follow
xmSmpHdrSize	rs.l	1	; sample header size
xmSmpNoteNums	rs.b	96	; sample numbers for notes
xmVolEnv	rs.b	48		; volume envelope points
xmPanEnv	rs.b	48		; panning envelope points
xmNumVolPnts	rs.b	1		; number of volume points
xmNumPanPnts	rs.b	1		; number of panning points
xmVolSustain	rs.b	1		; volume sustain point
xmVolLoopStart	rs.b	1		; volume loop start point
xmVolLoopEnd	rs.b	1		; volume loop end point
xmPanSustain	rs.b	1	; panning sustain point
xmPanLoopStart	rs.b	1	; panning loop start point
xmPanLoopEnd	rs.b	1	; panning loop end point
xmVolType	rs.b	1		; volume envelope flags
xmPanType	rs.b	1	; panning envelope flags
xmVibType	rs.b	1		; vibrato type
xmVibSweep	rs.b	1	; vibrato sweep
xmVibDepth	rs.b	1	; vibrato depth
xmVibRate	rs.b	1	; vibrato rate
xmVolFadeout	rs.w	1		; volume fadeout
xmReserved	rs.w	1
xmInstHdr2_SIZE	rs.b	0

; Envelope flags:

xmEnvOn = 0				; envelope on
xmEnvSustain = 1			; envelope sustain on
xmEnvLoop = 2				; envelope loop on

;/***************************************************************************\
;*       struct xmSmpHdr
;*       ---------------
;* Description:  Fasttracker 2 Extended Module sample header
;\***************************************************************************/

		rsreset
xmSmpLength	rs.l	1		; sample length
xmLoopStart	rs.l	1	; loop start
xmLoopLength	rs.l	1		; loop length
xsam_vol	rs.b	1	; volume
xmFinetune	rs.b	1	; finetune
xmSmpFlags	rs.b	1	; sample flags
xmPanning	rs.b	1	; sample panning
xmRelNote	rs.b	1	; relative note number
xmReserved2	rs.b	1
xmSmpName	rs.b	22		; sample name
xmSmpHdr_SIZE	rs.b 	0

; sample flags

xmLoopType = 3
xm16bit = $10
xm16bitf = 4


xm_init	move.l	mt_data_ptr,a0
	;lea	xmName(a0),a1
	;move.l	a1,mname(a5)

	lea	xmNum1A(a0),a2
	moveq	#18,d0
.t	cmp.b	#' ',-(a2)
	bne.b	.x
	dbf	d0,.t
.x	clr.b	1(a2)

	move	xmSpeed(a0),d0
	iword	d0
	move	d0,spd

	move	xmTempo(a0),d0
	iword	d0
	move	d0,RealTempo

	move	xmFlags(a0),d0
	iword	d0
;	clr	sflags			; force to use Amiga-freq.
	move	d0,sflags

	tst	PS3M_reinit
	bne	xm_skipinit

	move	xmSongLength(a0),d0
	iword	d0
	move	d0,slen
	move	d0,positioneita

	moveq	#0,d0
	move.b	xmNumChans(a0),d0
	move	d0,numchans
	addq	#1,d0
	lsr	#1,d0
	move	d0,maxchan			;!!!

	lea	xmHdrSize(a0),a1
	move.l	(a1),d0
	ilword	d0
	add.l	d0,a1
	lea	xm_patts,a2
	move	xmNumPatts(a0),d7
	iword	d7
	subq	#1,d7
.pattloop
	move.l	a1,(a2)+
	move.l	a1,a3				; xmPattHdrSize
	moveq	#0,d0
	tlword	(a3)+,d0
	lea	xmPattDataSize(a1),a3
	add.l	d0,a1
	moveq	#0,d0
	tword	(a3)+,d0
	add.l	d0,a1
	dbf	d7,.pattloop

	lea	xm_insts,a2
	move	xmNumInsts(a0),d7
	iword	d7
	subq	#1,d7
.instloop
	moveq	#0,d5				; instlength
	move.l	a1,(a2)+
	move.l	a1,a3				; xmInstSize
	tlword	(a3)+,d0
	lea	xmNumSamples(a1),a3
	tword	(a3)+,d1
	lea	xmSmpHdrSize(a1),a3
	add.l	d0,a1
	tst	d1
	beq	.q
	tlword	(a3)+,d2			; xmSmpHdrSize
	move	d2,d6
	mulu	d1,d6
	lea	(a1,d6.l),a4			; sample start
	subq	#1,d1
.lp	move.l	a1,a3				; xmSmpLength
	tlword	(a3)+,d0
	tst.l	d0
	beq.b	.e
	add.l	d0,d5

	btst	#xm16bitf,xmSmpFlags(a1)
	beq.b	.bit8

; Dedelta the samples

.bit16	moveq	#0,d4
	move.l	a4,a6
.l3	move.b	(a4)+,d3
	move.b	(a4)+,d6
	lsl	#8,d6
	move.b	d3,d6
	add	d4,d6
	move	d6,d4
	lsr	#8,d6
	move.b	d6,(a6)+
	subq.l	#2,d0
	bne.b	.l3
	bra.b	.e

.bit8	moveq	#0,d4
.l2	add.b	(a4),d4
	move.b	d4,(a4)+
	subq.l	#1,d0
	bne.b	.l2

.e	add.l	d2,a1
	dbf	d1,.lp

	add.l	d5,a1

.q	dbf	d7,.instloop


xm_skipinit
	clr	pos
	clr	rows
	clr	cn
	move	#64,globalVol

	lea	pantab,a1
	move.l	a1,a2
	moveq	#7,d0
.l9	clr.l	(a2)+
	dbf	d0,.l9

	move	numchans,d0
	subq	#1,d0
	moveq	#0,d1
.lop	tst	d1
	beq.b	.vas
	cmp	#3,d1
	beq.b	.vas
.oik	move.b	#-1,(a1)+
	bra.b	.je
.vas	move.b	#1,(a1)+
.je	addq	#1,d1
	and	#3,d1
	dbf	d0,.lop

	move.l	#8363*1712/4,clock		; Clock constant
	move	#1,fformat			; signed samples

	moveq	#0,d1
	move.b	xmOrders(a0),d1
	lsl.l	#2,d1
	lea	xm_patts,a1
	move.l	(a1,d1),a1

	lea	xmNumRows(a1),a3
	tword	(a3)+,d0
	move	d0,plen
	move.l	a1,a3
	tlword	(a3)+,d0
	add.l	d0,a1
	move.l	a1,ppos

	st	PS3M_reinit
	moveq	#0,d0
	rts


xm_music
	move.l	mt_data_ptr,a0
	pea	xm_runEnvelopes(pc)

	addq	#1,cn
	move	cn,d0
	cmp	spd,d0
	beq	xm_newrow

xm_ccmds
	lea	c0,a2
	lea	cha0,a4
	move	numchans,d7
	subq	#1,d7

.loo	moveq	#0,d0
	move.b	vol(a2),d0
	cmp.b	#$60,d0
	blo.b	.eivol

	lea	xm_cvct(pc),a1
	moveq	#$f,d1
	and	d0,d1
	move	d1,d2
	lsr	#4,d0
	subq	#6,d0
	add	d0,d0
	move	(a1,d0),d0
	jsr	(a1,d0)

.eivol	lea	xm_cct(pc),a1
	moveq	#0,d0
	move.b	cmd(a2),d0
	cmp.b	#$20,d0
	bhi.b	.edi
	moveq	#0,d1
	move.b	info(a2),d1
	beq.b	.zero
	move.b	d1,lastcmd(a2)
.zero	moveq	#0,d2
	move.b	lastcmd(a2),d2
	add	d0,d0
	move	(a1,d0),d0
	jsr	(a1,d0)

.edi	lea	s3mChanBlock_SIZE(a2),a2
	lea	mChanBlock_SIZE(a4),a4
	dbf	d7,.loo
	rts


xm_runEnvelopes
	lea	c0,a2
	lea	cha0,a4
	move	numchans,d7
	subq	#1,d7
.envloop
	move.l	sample(a2),d1
	beq	.skip

	move.l	d1,a1	

	move	rVolume(a2),d0

	tst.b	fading(a2)
	beq.b	.sk

	mulu	fadeOut(a2),d0
	swap	d0

	tst	fadeOut(a2)
	beq.b	.sk

	lea	xmVolFadeout(a1),a3
	moveq	#0,d1
	tword	(a3)+,d1
	moveq	#0,d2
	move	fadeOut(a2),d2
	sub.l	d1,d2
	bpl.b	.ok
	moveq	#0,d2
.ok	move	d2,fadeOut(a2)
.sk	cmp	#64,globalVol
	beq.b	.skipglobal

	mulu	globalVol,d0
	lsr	#6,d0

.skipglobal
	tst.b	volEnvOn(a2)
	beq	.skipenv

	tst.b	volSustained(a2)
	bne	.sust

	tst.b	volRecalc(a2)
	beq.b	.cont

	btst	#xmEnvSustain,xmVolType(a1)
	beq.b	.nsus
	move.b	xmVolSustain(a1),d3
	cmp.b	volCurPnt(a2),d3
	bne.b	.nsus
	tst.b	keyoff(a2)
	bne.b	.nsus
	st	volSustained(a2)

.nsus	moveq	#0,d1
	move.b	volCurPnt(a2),d1
	lsl	#2,d1
	lea	xmVolEnv(a1),a3
	add.l	d1,a3
	moveq	#0,d2
	tword	(a3)+,d1			; Envelope X
	tword	(a3)+,d2			; Envelope Y

	moveq	#0,d3
	tword	(a3)+,d4			; To X
	tword	(a3)+,d3			; To Y

	sub.l	d2,d3
	asl.l	#8,d3
	sub	d1,d4
	beq.b	.hups
	divs	d4,d3
.hups	move	d3,volEnvDelta(a2)

	move	d1,volEnvX(a2)
	lsl	#8,d2
	move	d2,volEnvY(a2)

	addq.b	#1,volCurPnt(a2)
	clr.b	volRecalc(a2)
	bra.b	.juuh


.cont	addq	#1,volEnvX(a2)
	move	volEnvY(a2),d2
	add	volEnvDelta(a2),d2
	move	d2,volEnvY(a2)
.juuh	asr	#8,d2
	bpl.b	.jupo
	moveq	#0,d2
.jupo	cmp	#64,d2
	bls.b	.oko
	moveq	#64,d2
.oko	mulu	d2,d0
	lsr	#6,d0

	move	volEnvX(a2),d2
	moveq	#0,d1
	move.b	volCurPnt(a2),d1
	lsl	#2,d1
	lea	xmVolEnv(a1),a3
	add.l	d1,a3
	tword	(a3)+,d1			; Envelope X
	cmp	d1,d2
	blo.b	.skipenv

.kaa	st	volRecalc(a2)

	btst	#xmEnvSustain,xmVolType(a1)
	beq.b	.nosust

	move.b	xmVolSustain(a1),d3
	cmp.b	volCurPnt(a2),d3
	bne.b	.nosust
	tst.b	keyoff(a2)
	bne.b	.nosust
	st	volSustained(a2)
	bra.b	.skipenv

.nosust	btst	#xmEnvLoop,xmVolType(a1)
	beq.b	.noloop

	move.b	xmVolLoopEnd(a1),d3
	cmp.b	volCurPnt(a2),d3
	bne.b	.noloop

	move.b	xmVolLoopStart(a1),volCurPnt(a2)
	bra.b	.skipenv

.noloop	move.b	xmNumVolPnts(a1),d3
	subq.b	#1,d3
	cmp.b	volCurPnt(a2),d3
	bne.b	.skipenv
	st.b	volSustained(a2)
	bra.b	.skipenv

.sust	move	volEnvY(a2),d2
	asr	#8,d2
	bpl.b	.jupi
	moveq	#0,d2
.jupi	cmp	#64,d2
	bls.b	.okk
	moveq	#64,d2
.okk	mulu	d2,d0
	lsr	#6,d0
.skipenv
	move	d0,sam_vol(a4)

.skip	btst	#0,sflags+1
	beq.b	.amigaperiods

	moveq	#0,d0
	move	rPeriod(a2),d0
	divu	#768,d0
	move	d0,d1
	swap	d0
	lsl	#2,d0
	lea	xm_linFreq(pc),a0
	move.l	(a0,d0),d0
	lsr.l	d1,d0
	move.l	d0,d1
	move.l	#8363*1712,d0
	bsr	divu_32

	move	d0,sam_period(a4)
	bra.b	.k


.amigaperiods
	move	rPeriod(a2),sam_period(a4)

.k	lea	s3mChanBlock_SIZE(a2),a2
	lea	mChanBlock_SIZE(a4),a4
	dbf	d7,.envloop
	rts


xm_newrow
	clr	cn

	tst.b	pdelaycnt
	bne.b	.process

	move.l	ppos,a1
	lea	c0,a2		;chanblocks
	move	numchans,d7
	subq	#1,d7
.loo	move.b	(a1)+,d0
	bpl.b	.all

	clr.l	(a2)
	clr.b	info(a2)

	btst	#0,d0
	beq.b	.nonote
	move.b	(a1)+,(a2)
.nonote	btst	#1,d0
	beq.b	.noinst
	move.b	(a1)+,inst(a2)
.noinst	btst	#2,d0
	beq.b	.novol
	move.b	(a1)+,vol(a2)
.novol	btst	#3,d0
	beq.b	.nocmd
	move.b	(a1)+,cmd(a2)
.nocmd	btst	#4,d0
	beq.b	.next
	move.b	(a1)+,info(a2)
	bra.b	.next
	
.all	move.b	d0,(a2)
	move.b	(a1)+,inst(a2)
	move.b	(a1)+,vol(a2)
	move.b	(a1)+,cmd(a2)
	move.b	(a1)+,info(a2)

.next	lea	s3mChanBlock_SIZE(a2),a2
	dbf	d7,.loo
	move.l	a1,ppos

.process
	lea	c0,a2
	lea	cha0,a4
	move	numchans,d7
	subq	#1,d7
.channelloop
	tst.b	pdelaycnt
	bne	.skip

	tst	(a2)
	beq	.skip

	moveq	#0,d0
	move.b	(a2),d0
	bne.b	.note
	move.b	note(a2),d0
.note	move.b	d0,note(a2)

	moveq	#0,d1
	move.b	inst(a2),d1
	beq.b	.esmp

	lsl	#2,d1
	lea	xm_insts,a1
	move.l	-4(a1,d1),a1

	move.l	a1,sample(a2)
	bra.b	.ju
.esmp	move.l	sample(a2),d2
	beq	.skip
	move.l	d2,a1

.ju	moveq	#$f,d1
	and.b	cmd(a2),d1
	cmp	#$e,d1
	bne.b	.s
	move.b	info(a2),d1
	and	#$f0,d1
	cmp	#$d0,d1
	beq	.skip

.s	bsr	xm_getInst

	tst.b	inst(a2)
	beq.b	.smpok
	tst.b	(a2)
	beq.b	.smpok

	lea	xmLoopStart(a1),a3
	tlword	(a3)+,d1
	lea	xmLoopLength(a1),a3
	tlword	(a3)+,d2

	btst	#xm16bitf,xmSmpFlags(a1)
	beq.b	.bit8
	lsr.l	#1,d1
	lsr.l	#1,d2
.bit8	add.l	a6,d1

	move.l	d1,sam_lpstart(a4)
	move.l	d2,sam_lplength(a4)
	move.b	xsam_vol(a1),volume+1(a2)
	cmp	#64,volume(a2)
	bls.b	.e
	move	#64,volume(a2)
.e	move	volume(a2),rVolume(a2)

	moveq	#xmLoopType,d1
	and.b	xmSmpFlags(a1),d1
	beq.b	.eloo
	st	mLoop(a4)
	bra.b	.smpok

.eloo	clr.b	mLoop(a4)

.smpok	tst.b	(a2)
	beq	.skip

	cmp.b	#97,(a2)			; Key off -note
	beq	.keyoff

	bsr	xm_getPeriod

; Handle envelopes
	move	#$ffff,fadeOut(a2)
	clr.b	fading(a2)
	clr.b	keyoff(a2)

	move.l	sample(a2),d2
	beq	.skip
	move.l	d2,a3

	btst	#xmEnvOn,xmVolType(a3)
	beq.b	.voloff

	st	volEnvOn(a2)
	clr.b	volCurPnt(a2)
	st	volRecalc(a2)
	clr.b	volSustained(a2)
	bra.b	.jep

.voloff	clr.b	volEnvOn(a2)


.jep	btst	#xmEnvOn,xmPanType(a3)
	beq.b	.panoff

	st	panEnvOn(a2)
	clr.b	panCurPnt(a2)
	st	panRecalc(a2)
	clr.b	panSustained(a2)
	bra.b	.jep2

.panoff	clr.b	panEnvOn(a2)

.jep2	cmp.b	#3,cmd(a2)
	beq	.tonep
	cmp.b	#5,cmd(a2)
	beq	.tonep

	move	d0,rPeriod(a2)
	move	d0,period(a2)
	clr.l	mFPos(a4)

	move.l	a1,a3
	tlword	(a3)+,d0			; sample length

	cmp.b	#9,cmd(a2)
	bne.b	.nooffset

	moveq	#0,d1
	move.b	info(a2),d1
	bne.b	.ok3
	move.b	lastOffset(a2),d1
.ok3	move.b	d1,lastOffset(a2)
	lsl	#8,d1
	add.l	d1,a6
	sub.l	d1,d0
	bpl.b	.nooffset
	st	mOnOff(a4)
	bra.b	.skip

.nooffset
	move.l	a6,(a4)				; sample start
	btst	#xm16bitf,xmSmpFlags(a1)
	beq.b	.bit8_2
	lsr.l	#1,d0
.bit8_2	move.l	d0,sam_length(a4)
	clr.b	mOnOff(a4)
	bra.b	.skip

.keyoff	
	tst.b	volEnvOn(a2)
	beq.b	.vol0

	clr.b	volSustained(a2)
	st	fading(a2)
	st	keyoff(a2)
	bra.b	.skip

.vol0	tst.b	inst(a2)
	bne.b	.skip
	clr	volume(a2)
	bra.b	.skip

.tonep	move	d0,toperiod(a2)

.skip	moveq	#0,d0
	move.b	vol(a2),d0
	cmp.b	#$10,d0
	blo.b	.eivol

	cmp.b	#$50,d0
	bhi.b	.volcmd

	sub	#$10,d0
	move	d0,volume(a2)
	bra.b	.eivol

.volcmd	cmp.b	#$60,d0
	blo.b	.eivol

	lea	xm_vct(pc),a1
	moveq	#$f,d1
	and	d0,d1
	move	d1,d2
	lsr	#4,d0
	subq	#6,d0
	add	d0,d0
	move	(a1,d0),d0
	jsr	(a1,d0)

.eivol	lea	xm_ct(pc),a1
	moveq	#0,d0
	move.b	cmd(a2),d0
	cmp.b	#$20,d0
	bhs.b	.skipa
	moveq	#0,d1
	move.b	info(a2),d1
	beq.b	.zero
	move.b	d1,lastcmd(a2)

.zero	moveq	#0,d2
	move.b	lastcmd(a2),d2

	;ifne	debug
	;move.l	kalas,a3
	;st	(a3,d0)
	;endc

	add	d0,d0
	move	(a1,d0),d0
	jsr	(a1,d0)

.skipa	move	volume(a2),rVolume(a2)
	move	period(a2),rPeriod(a2)

	lea	s3mChanBlock_SIZE(a2),a2
	lea	mChanBlock_SIZE(a4),a4
	dbf	d7,.channelloop

	tst.b	pdelaycnt
	beq.b	.oke

	subq.b	#1,pdelaycnt
	bra	xm_exit

.oke	tst	pbflag
	bne.b	.break

	addq	#1,rows
	move	plen,d0
	cmp	rows,d0
	bhi	xm_dee

	addq	#1,pos
	clr	rows

.break	move	slen,d0
	cmp	pos,d0
	bhi.b	.ee

	move	xmRestart(a0),d0
	iword	d0
	move	d0,pos
	st	PS3M_break

.ee	move	pos,d0
	move	d0,PS3M_position
	st	PS3M_poschan

	moveq	#0,d1
	move.b	xmOrders(a0,d0),d1	

	lsl	#2,d1

	lea	xm_patts,a1
	move.l	(a1,d1),a1
	lea	xmNumRows(a1),a3
	tword	(a3)+,d0
	move	d0,plen
	move.l	a1,a3
	tlword	(a3)+,d0
	add.l	d0,a1
	move.l	a1,ppos
	clr	pbflag

xm_dee	lea	c0,a2
	lea	cha0,a4
	move	numchans,d7
	subq	#1,d7

.luu	tst	volume(a2)
	bne.b	.noaging

	cmp.b	#8,age(a2)
	bhs.b	.stop
	addq.b	#1,age(a2)
	bra.b	.nextt
.stop	st	mOnOff(a4)
	bra.b	.nextt
.noaging
	clr.b	age(a2)

.nextt	lea	s3mChanBlock_SIZE(a2),a2
	lea	mChanBlock_SIZE(a4),a4
	dbf	d7,.luu
xm_exit	rts

xm_ret	rts


; COMMANDS!


xm_getInst
	moveq	#0,d6
	move.b	xmSmpNoteNums-1(a1,d0),d6	; sample number
	lea	xmNumSamples(a1),a3
	tword	(a3)+,d2
	lea	xmSmpHdrSize(a1),a3
	tlword	(a3)+,d3
	move.l	a1,a3				; InstHdrSize
	tlword	(a3)+,d1
	add.l	d1,a1				; Now at the first sample!

	move.l	d3,d4
	mulu	d2,d4
	lea	(a1,d4),a6

	tst	d6
	beq.b	.rightsample

.skiploop
	lea	xmSmpLength(a1),a3
	tlword	(a3)+,d4
	add.l	d4,a6
	add.l	d3,a1
	subq	#1,d6
	bne.b	.skiploop

.rightsample
	rts



xm_getPeriod
	move.b	xmRelNote(a1),d1
	ext	d1
	add	d1,d0
	bpl.b	.ok
	moveq	#0,d0
.ok	cmp	#118,d0
	bls.b	.ok2
	moveq	#118,d0
.ok2	move.b	xmFinetune(a1),d1
	ext.l	d0
	ext	d1

	btst	#0,sflags+1
	beq.b	.amigafreq

	move	#121*64,d2
	lsl	#6,d0
	sub	d0,d2
	asr	d1
	sub	d1,d2
	move	d2,d0
	rts

.amigafreq
	divu	#12,d0
	swap	d0
	move	d0,d2				; note
	clr	d0
	swap	d0				; octave
	lsl	#3,d2

	move	d1,d3
	asr	#4,d3
	move	d2,d4
	add	d3,d4

	add	d4,d4
	lea	xm_periods(pc),a3
	moveq	#0,d5
	move	(a3,d4),d5

	tst	d1
	bpl.b	.k
	subq	#1,d3
	neg	d1
	bra.b	.k2
.k	addq	#1,d3
.k2	move	d2,d4
	add	d3,d4
	add	d4,d4
	moveq	#0,d6
	move	(a3,d4),d6

	and	#$f,d1
	mulu	d1,d6
	move	#16,d3
	sub	d1,d3
	mulu	d3,d5
	add.l	d6,d5

	subq	#1,d0
	bmi.b	.f2
	lsr.l	d0,d5
	bra.b	.d

.f2	add.l	d5,d5
.d	move	d5,d0
	rts


; Command 0 - Arpeggio

xm_arpeggio
	tst.b	info(a2)
	beq.b	.skip

	moveq	#0,d0
	move.b	note(a2),d0
	beq.b	.skip

	move.l	sample(a2),d2
	beq.b	.skip
	move.l	d2,a1

	bsr	xm_getInst

	moveq	#0,d2
	move	cn,d2
	divu	#3,d2
	swap	d2
	tst	d2
	beq.b	.f
	subq	#1,d2
	beq.b	.1

.2	moveq	#$f,d2
	and.b	lastcmd(a2),d2
	add	d2,d0
	bra.b	.f

.1	move.b	lastcmd(a2),d2
	lsr.b	#4,d2
	add.b	d2,d0

.f	bsr	xm_getPeriod
	move	d0,sam_period(a4)
.skip	rts



; Command 1 - Portamento up
; Also command E1 - fine portamento up
; and command X1 - extra fine portamento up

xm_slideup
	lsl	#2,d2
xm_xslideup
	sub	d2,period(a2)
	bra.b	xm_checklimits


; Command 2 - Portamento down
; Also command E2 - fine portamento down
; and command X2 - extra fine portamento down

xm_slidedwn
	lsl	#2,d2
xm_xslidedwn
	add	d2,period(a2)

xm_checklimits
	move	period(a2),d0
	btst	#0,sflags+1
	beq.b	.amiga

	cmp	#2*64,d0
	bhs.b	.ok
	move	#2*64,d0
.ok	cmp	#121*64,d0
	bls.b	.dd2
	move	#121*64,d0
	bra.b	.dd2

.amiga	cmp	#$7fff,d0
	bls.b	.dd
	move	#$7fff,d0
.dd	cmp	#64,d0
	bhs.b	.dd2
	move	#64,d0
.dd2	move	d0,period(a2)
	move	d0,rPeriod(a2)
	rts


; Command 3 - Tone portamento

xm_tonep
	tst	d1
	beq.b	xm_tonepnoch
	move.b	d1,notepspd(a2)
xm_tonepnoch
	move	toperiod(a2),d0
	beq.b	.1
	moveq	#0,d1
	move.b	notepspd(a2),d1
	lsl	#2,d1

	cmp	period(a2),d0
	blt.b	.topoup

	add	d1,period(a2)
	cmp	period(a2),d0
	bhi.b	.1
	move	d0,period(a2)
	clr	toperiod(a2)
.1	move	period(a2),rPeriod(a2)
	rts

.topoup	sub	d1,period(a2)
	cmp	period(a2),d0
	blt.b	.dd
	move	d0,period(a2)
	clr	toperiod(a2)
.dd	move	period(a2),rPeriod(a2)
	rts


; Command 4 - Vibrato

xm_svibspd
	move.b	vibcmd(a2),d2
	moveq	#$f,d0
	and	d1,d0
	beq.b	.skip
	and	#$f0,d2
	or	d0,d2
.skip	move.b	d2,vibcmd(a2)
	rts

xm_vibrato
	move.b	vibcmd(a2),d2
	move	d1,d0
	and	#$f0,d0
	beq.b	.vib2

	and	#$f,d2
	or	d0,d2

.vib2	moveq	#$f,d0
	and	d1,d0
	beq.b	.vibskip2

	and	#$f0,d2
	or	d0,d2
.vibskip2
	move.b	d2,vibcmd(a2)

xm_vibrato2
	moveq	#$1f,d0
	and.b	vibpos(a2),d0
	moveq	#0,d2
	lea	mt_vibratotable(pc),a3
	move.b	(a3,d0),d2
	moveq	#$f,d0
	and.b	vibcmd(a2),d0
	mulu	d0,d2
	lsr	#5,d2

	move	period(a2),d0
	btst	#5,vibpos(a2)
	bne.b	.neg
	add	d2,d0
	bra.b	.vib3
.neg
	sub	d2,d0
.vib3
	move	d0,sam_period(a4)
	move.b	vibcmd(a2),d0
	lsr.b	#4,d0
	add.b	d0,vibpos(a2)
	rts

; Command 5 - Tone portamento and volume slide

xm_tpvsl
	bsr	xm_tonepnoch
	bra.b	xm_vslide

; Command 6 - Vibrato and volume slide

xm_vibvsl
	move	d2,-(sp)
	bsr.b	xm_vibrato2
	move	(sp)+,d2
	bra.b	xm_vslide


; Command 7 - Tremolo

xm_tremolo
	move.b	vibcmd(a2),d2
	move	d1,d0
	and	#$f0,d0
	beq.b	.vib2

	and	#$f,d2
	or	d0,d2

.vib2	moveq	#$f,d0
	and	d1,d0
	beq.b	.vibskip2

	and	#$f0,d2
	or	d0,d2
.vibskip2
	move.b	d2,vibcmd(a2)

	moveq	#$1f,d0
	and.b	vibpos(a2),d0
	moveq	#0,d2
	lea	mt_vibratotable(pc),a3
	move.b	(a3,d0),d2
	moveq	#$f,d0
	and.b	vibcmd(a2),d0
	mulu	d0,d2
	lsr	#6,d2

	move	volume(a2),d0
	btst	#5,vibpos(a2)
	bne.b	.neg
	add	d2,d0
	bra.b	.vib3
.neg
	sub	d2,d0
.vib3	move	d0,sam_vol(a4)
	move.b	vibcmd(a2),d0
	lsr.b	#4,d0
	add.b	d0,vibpos(a2)
	rts


; Command A - Volume slide
; Also commands EA and EB, fine volume slides

xm_vslide
	lsr	#4,d2
	beq.b	xm_vslidedown
xm_vslideup
	add	d2,volume(a2)
	cmp	#64,volume(a2)
	bls.b	xm_vsskip
	move	#64,volume(a2)
xm_vsskip
	move	volume(a2),rVolume(a2)
	rts

xm_vslidedown
	moveq	#$f,d2
	and.b	lastcmd(a2),d2
xm_vslidedown2
	sub	d2,volume(a2)
	bpl.b	xm_vsskip
	clr	volume(a2)
	clr	rVolume(a2)
	rts


; Command B - Pattern jump

xm_pjmp	move	d1,pos
	st	pbflag
	clr	rows
	rts


; Command C - Set volume

xm_setvol
	cmp	#64,d1
	bls.b	.ok
	moveq	#64,d1
.ok	move	d1,volume(a2)
	rts


; Command D - Pattern break

xm_pbrk	addq	#1,pos
	st	pbflag
	moveq	#$f,d2
	and.l	d1,d2
	lsr.l	#4,d1
	mulu	#10,d1
	add	d2,d1
	move	d1,rows
	rts


; Command E - Extended commands

xm_ecmds
	lea	xm_ect(pc),a1
xm_ee	move	d1,d0
	moveq	#$f,d1
	and	d0,d1
	move	d1,d2
	lsr	#4,d0

	;ifne	debug
	;move.l	kalas,a3
	;st	$40(a3,d0)
	;endc

	add	d0,d0
	move	(a1,d0),d0
	jmp	(a1,d0)

xm_cecmds
	lea	xm_cect(pc),a1
	bra.b	xm_ee


; Command E9 - Retrig note

xm_retrig
	subq.b	#1,retrigcn(a2)
	bne	xm_eret

	move.l	sample(a2),d2
	beq	xm_eret
	move.l	d2,a1

	move	d1,-(sp)

	bsr	xm_getInst

	clr.l	mFPos(a4)
; Handle envelopes
	move	#$ffff,fadeOut(a2)
	clr.b	fading(a2)
	clr.b	keyoff(a2)

	move.l	sample(a2),a3
	btst	#xmEnvOn,xmVolType(a3)
	beq.b	.voloff

	st	volEnvOn(a2)
	clr.b	volCurPnt(a2)
	st	volRecalc(a2)
	clr.b	volSustained(a2)
	bra.b	.jep

.voloff	clr.b	volEnvOn(a2)


.jep	btst	#xmEnvOn,xmPanType(a3)
	beq.b	.panoff

	st	panEnvOn(a2)
	clr.b	panCurPnt(a2)
	st	panRecalc(a2)
	clr.b	panSustained(a2)
	bra.b	.jep2

.panoff	clr.b	panEnvOn(a2)

.jep2	move.l	a1,a3
	tlword	(a3)+,d0			; sample length

	move.l	a6,(a4)				; sample start
	btst	#xm16bitf,xmSmpFlags(a1)
	beq.b	.bit8_2
	lsr.l	#1,d0
.bit8_2	move.l	d0,sam_length(a4)
	clr.b	mOnOff(a4)
	move	(sp)+,d1
xm_sretrig
	move.b	d1,retrigcn(a2)
	rts


; Command EC - Note cut

xm_ncut	cmp	cn,d1
	bne.b	xm_eret
	clr	volume(a2)
	clr	rVolume(a2)
xm_eret	rts


; Command ED - Delay note

xm_ndelay
	cmp	cn,d1
	bne.b	xm_eret

	tst	(a2)
	beq	.skip

	moveq	#0,d0
	move.b	(a2),d0
	beq	.skip

	cmp.b	#97,d0				; Key off -note
	beq	.keyoff

	move.b	d0,note(a2)

	moveq	#0,d1
	move.b	inst(a2),d1
	beq.b	.esmp

	lsl	#2,d1
	lea	xm_insts,a1
	move.l	-4(a1,d1),a1

	move.l	a1,sample(a2)
	bra.b	.ju
.esmp	move.l	sample(a2),d2
	beq	.skip
	move.l	d2,a1

.ju	bsr	xm_getInst

	tst.b	inst(a2)
	beq.b	.smpok

	lea	xmLoopStart(a1),a3
	tlword	(a3)+,d1
	lea	xmLoopLength(a1),a3
	tlword	(a3)+,d2

	btst	#xm16bitf,xmSmpFlags(a1)
	beq.b	.bit8
	lsr.l	#1,d1
	lsr.l	#1,d2
.bit8	add.l	a6,d1

	move.l	d1,sam_lpstart(a4)
	move.l	d2,sam_lplength(a4)
	move.b	xsam_vol(a1),volume+1(a2)
	cmp	#64,volume(a2)
	bls.b	.e
	move	#64,volume(a2)
.e	move	volume(a2),rVolume(a2)

	moveq	#xmLoopType,d1
	and.b	xmSmpFlags(a1),d1
	beq.b	.eloo
	st	mLoop(a4)
	bra.b	.smpok

.eloo	clr.b	mLoop(a4)

.smpok
	bsr	xm_getPeriod

	move	d0,rPeriod(a2)
	move	d0,period(a2)
	clr.l	mFPos(a4)

; Handle envelopes
	move	#$ffff,fadeOut(a2)
	clr.b	fading(a2)
	clr.b	keyoff(a2)

	move.l	sample(a2),a3

	btst	#xmEnvOn,xmVolType(a3)
	beq.b	.voloff

	st	volEnvOn(a2)
	clr.b	volCurPnt(a2)
	st	volRecalc(a2)
	clr.b	volSustained(a2)
	bra.b	.jep

.voloff	clr.b	volEnvOn(a2)


.jep	btst	#xmEnvOn,xmPanType(a3)
	beq.b	.panoff

	st	panEnvOn(a2)
	clr.b	panCurPnt(a2)
	st	panRecalc(a2)
	clr.b	panSustained(a2)
	bra.b	.jep2

.panoff	clr.b	panEnvOn(a2)

.jep2	move.l	a1,a3
	tlword	(a3)+,d0			; sample length
	move.l	a6,(a4)				; sample start
	btst	#xm16bitf,xmSmpFlags(a1)
	beq.b	.bit8_2
	lsr.l	#1,d0
.bit8_2	move.l	d0,sam_length(a4)
	clr.b	mOnOff(a4)
	bra.b	.skip

.keyoff
	tst.b	volEnvOn(a2)
	beq.b	.vol0

	clr.b	volSustained(a2)
	st	fading(a2)
	st	keyoff(a2)
	bra.b	.skip

.vol0	tst.b	inst(a2)
	bne.b	.skip
	clr	volume(a2)
.skip
.ret	rts




; Command EE - Pattern delay

xm_pdelay
	tst.b	pdelaycnt
	bne.b	.skip

	move	d1,pdelaycnt

.skip	rts

; Command F - Set speed

xm_spd	cmp	#$20,d1
	bhs.b	.bpm

	tst	d1
	beq.b	.g
	move	d1,spd
.g	rts

.bpm	move	d1,RealTempo
	;move.l	mrate,d0
	;move.l	d0,d2
	;lsl.l	#2,d0
	;add.l	d2,d0
	;add	d1,d1
	;divu	d1,d0

	;addq	#1,d0
	;and	#~1,d0
	;move	d0,bytesperframe
	rts


; Command G - Set global volume

xm_sgvol
	cmp	#64,d1
	bls.b	.ok
	moveq	#64,d1
.ok	move	d1,globalVol
	rts


; Command H - Global volume slide

xm_gvslide
	lsr	#4,d2
	beq.b	.down
	add	d2,globalVol
	cmp	#64,globalVol
	bls.b	.x
	move	#64,globalVol
.x	rts

.down	moveq	#$f,d2
	and.b	lastcmd(a2),d2
	sub	d2,globalVol
	bpl.b	.x
	clr	globalVol
	rts


; Command K - Key off

xm_keyoff
	clr.b	volSustained(a2)
	st	fading(a2)
	st	keyoff(a2)
	rts


; Command L - Set envelope position

xm_setenvpos
	tst.b	volEnvOn(a2)
	beq	.skip

	move	d1,volEnvX(a2)

	move.l	sample(a2),d2
	beq	.skip

	move.l	d2,a1

	clr.b	volSustained(a2)

	moveq	#0,d2
	lea	xmVolEnv(a1),a3
	moveq	#11,d3
.loop	tword	(a3)+,d0
	cmp	d0,d1
	beq.b	.exact
	blo.b	.found
	addq	#2,a3
	addq	#1,d2
	dbf	d3,.loop
	subq	#2,a3
	bra.b	.found
.exact	move.b	d2,volCurPnt(a2)
	subq	#2,a3
	bra.b	.con
.found	move.b	d2,volCurPnt(a2)
	subq	#6,a3
.con
	moveq	#0,d2
	tword	(a3)+,d1			; Envelope X
	tword	(a3)+,d2			; Envelope Y

	moveq	#0,d3
	tword	(a3)+,d4			; To X
	tword	(a3)+,d3			; To Y

	sub.l	d2,d3
	asl.l	#8,d3
	sub	d1,d4
	beq.b	.hups
	divs	d4,d3
.hups	move	d3,volEnvDelta(a2)

	lsl	#8,d2

	move	volEnvX(a2),d0
	sub	d1,d0
	mulu	d3,d0
	add	d0,d2
	move	d2,volEnvY(a2)

	addq.b	#1,volCurPnt(a2)
	clr.b	volRecalc(a2)
.skip	rts



; Command R - Multi retrig note

xm_rretrig
	subq.b	#1,retrigcn(a2)
	bne	xm_eret

	move.l	sample(a2),d2
	beq	xm_eret
	move.l	d2,a1

	move	d1,-(sp)

	bsr	xm_getInst

	clr.l	mFPos(a4)
; Handle envelopes
	move	#$ffff,fadeOut(a2)
	clr.b	fading(a2)
	clr.b	keyoff(a2)

	move.l	sample(a2),a3
	btst	#xmEnvOn,xmVolType(a3)
	beq.b	.voloff

	st	volEnvOn(a2)
	clr.b	volCurPnt(a2)
	st	volRecalc(a2)
	clr.b	volSustained(a2)
	bra.b	.jep

.voloff	clr.b	volEnvOn(a2)


.jep	btst	#xmEnvOn,xmPanType(a3)
	beq.b	.panoff

	st	panEnvOn(a2)
	clr.b	panCurPnt(a2)
	st	panRecalc(a2)
	clr.b	panSustained(a2)
	bra.b	.jep2

.panoff	clr.b	panEnvOn(a2)

.jep2	move.l	a1,a3
	tlword	(a3)+,d0			; sample length

	move.l	a6,(a4)				; sample start
	btst	#xm16bitf,xmSmpFlags(a1)
	beq.b	.bit8_2
	lsr.l	#1,d0
.bit8_2	move.l	d0,sam_length(a4)
	clr.b	mOnOff(a4)

	moveq	#0,d0
	move.b	lastcmd(a2),d0
	lsr	#4,d0
	moveq	#0,d2
	lea	ftab2(pc),a3
	move.b	(a3,d0),d2
	beq.b	.ddq

	mulu	volume(a2),d2
	lsr	#4,d2
	move	d2,volume(a2)
	bra.b	.ddw

.ddq	lea	ftab1(pc),a3
	move.b	(a3,d0),d2
	ext	d2
	add	d2,volume(a2)

.ddw	tst	volume(a2)
	bpl.b	.ei0
	clr	volume(a2)
.ei0	cmp	#64,volume(a2)
	bls.b	.ei64
	move	#64,volume(a2)
.ei64	move	volume(a2),sam_vol(a4)
	move	(sp)+,d1
xm_srretrig
	and	#$f,d1
	move.b	d1,retrigcn(a2)
	rts


; Command T - Tremor

xm_tremor
	rts


; Command X - Extra fine slides

xm_xfinesld
	move.b	d2,d1
	and	#$f,d2
	cmp.b	#$10,d1
	blo.b	.q
	cmp.b	#$20,d1
	blo	xm_xslideup
	cmp.b	#$30,d1
	blo	xm_xslidedwn
.q	rts

	dc.w	960,954,948,940,934,926,920,914
xm_periods
	dc.w	907,900,894,887,881,875,868,862,856,850,844,838,832,826,820,814
	dc.w	808,802,796,791,785,779,774,768,762,757,752,746,741,736,730,725
	dc.w	720,715,709,704,699,694,689,684,678,675,670,665,660,655,651,646
	dc.w	640,636,632,628,623,619,614,610,604,601,597,592,588,584,580,575
	dc.w	570,567,563,559,555,551,547,543,538,535,532,528,524,520,516,513
	dc.w	508,505,502,498,494,491,487,484,480,477,474,470,467,463,460,457

xm_linFreq
	dc.l	535232,534749,534266,533784,533303,532822,532341,531861
	dc.l	531381,530902,530423,529944,529466,528988,528511,528034
	dc.l	527558,527082,526607,526131,525657,525183,524709,524236
	dc.l	523763,523290,522818,522346,521875,521404,520934,520464
	dc.l	519994,519525,519057,518588,518121,517653,517186,516720
	dc.l	516253,515788,515322,514858,514393,513929,513465,513002
	dc.l	512539,512077,511615,511154,510692,510232,509771,509312
	dc.l	508852,508393,507934,507476,507018,506561,506104,505647
	dc.l	505191,504735,504280,503825,503371,502917,502463,502010
	dc.l	501557,501104,500652,500201,499749,499298,498848,498398
	dc.l	497948,497499,497050,496602,496154,495706,495259,494812
	dc.l	494366,493920,493474,493029,492585,492140,491696,491253
	dc.l	490809,490367,489924,489482,489041,488600,488159,487718
	dc.l	487278,486839,486400,485961,485522,485084,484647,484210
	dc.l	483773,483336,482900,482465,482029,481595,481160,480726
	dc.l	480292,479859,479426,478994,478562,478130,477699,477268
	dc.l	476837,476407,475977,475548,475119,474690,474262,473834
	dc.l	473407,472979,472553,472126,471701,471275,470850,470425
	dc.l	470001,469577,469153,468730,468307,467884,467462,467041
	dc.l	466619,466198,465778,465358,464938,464518,464099,463681
	dc.l	463262,462844,462427,462010,461593,461177,460760,460345
	dc.l	459930,459515,459100,458686,458272,457859,457446,457033
	dc.l	456621,456209,455797,455386,454975,454565,454155,453745
	dc.l	453336,452927,452518,452110,451702,451294,450887,450481
	dc.l	450074,449668,449262,448857,448452,448048,447644,447240
	dc.l	446836,446433,446030,445628,445226,444824,444423,444022
	dc.l	443622,443221,442821,442422,442023,441624,441226,440828
	dc.l	440430,440033,439636,439239,438843,438447,438051,437656
	dc.l	437261,436867,436473,436079,435686,435293,434900,434508
	dc.l	434116,433724,433333,432942,432551,432161,431771,431382
	dc.l	430992,430604,430215,429827,429439,429052,428665,428278
	dc.l	427892,427506,427120,426735,426350,425965,425581,425197
	dc.l	424813,424430,424047,423665,423283,422901,422519,422138
	dc.l	421757,421377,420997,420617,420237,419858,419479,419101
	dc.l	418723,418345,417968,417591,417214,416838,416462,416086
	dc.l	415711,415336,414961,414586,414212,413839,413465,413092
	dc.l	412720,412347,411975,411604,411232,410862,410491,410121
	dc.l	409751,409381,409012,408643,408274,407906,407538,407170
	dc.l	406803,406436,406069,405703,405337,404971,404606,404241
	dc.l	403876,403512,403148,402784,402421,402058,401695,401333
	dc.l	400970,400609,400247,399886,399525,399165,398805,398445
	dc.l	398086,397727,397368,397009,396651,396293,395936,395579
	dc.l	395222,394865,394509,394153,393798,393442,393087,392733
	dc.l	392378,392024,391671,391317,390964,390612,390259,389907
	dc.l	389556,389204,388853,388502,388152,387802,387452,387102
	dc.l	386753,386404,386056,385707,385359,385012,384664,384317
	dc.l	383971,383624,383278,382932,382587,382242,381897,381552
	dc.l	381208,380864,380521,380177,379834,379492,379149,378807
	dc.l	378466,378124,377783,377442,377102,376762,376422,376082
	dc.l	375743,375404,375065,374727,374389,374051,373714,373377
	dc.l	373040,372703,372367,372031,371695,371360,371025,370690
	dc.l	370356,370022,369688,369355,369021,368688,368356,368023
	dc.l	367691,367360,367028,366697,366366,366036,365706,365376
	dc.l	365046,364717,364388,364059,363731,363403,363075,362747
	dc.l	362420,362093,361766,361440,361114,360788,360463,360137
	dc.l	359813,359488,359164,358840,358516,358193,357869,357547
	dc.l	357224,356902,356580,356258,355937,355616,355295,354974
	dc.l	354654,354334,354014,353695,353376,353057,352739,352420
	dc.l	352103,351785,351468,351150,350834,350517,350201,349885
	dc.l	349569,349254,348939,348624,348310,347995,347682,347368
	dc.l	347055,346741,346429,346116,345804,345492,345180,344869
	dc.l	344558,344247,343936,343626,343316,343006,342697,342388
	dc.l	342079,341770,341462,341154,340846,340539,340231,339924
	dc.l	339618,339311,339005,338700,338394,338089,337784,337479
	dc.l	337175,336870,336566,336263,335959,335656,335354,335051
	dc.l	334749,334447,334145,333844,333542,333242,332941,332641
	dc.l	332341,332041,331741,331442,331143,330844,330546,330247
	dc.l	329950,329652,329355,329057,328761,328464,328168,327872
	dc.l	327576,327280,326985,326690,326395,326101,325807,325513
	dc.l	325219,324926,324633,324340,324047,323755,323463,323171
	dc.l	322879,322588,322297,322006,321716,321426,321136,320846
	dc.l	320557,320267,319978,319690,319401,319113,318825,318538
	dc.l	318250,317963,317676,317390,317103,316817,316532,316246
	dc.l	315961,315676,315391,315106,314822,314538,314254,313971
	dc.l	313688,313405,313122,312839,312557,312275,311994,311712
	dc.l	311431,311150,310869,310589,310309,310029,309749,309470
	dc.l	309190,308911,308633,308354,308076,307798,307521,307243
	dc.l	306966,306689,306412,306136,305860,305584,305308,305033
	dc.l	304758,304483,304208,303934,303659,303385,303112,302838
	dc.l	302565,302292,302019,301747,301475,301203,300931,300660
	dc.l	300388,300117,299847,299576,299306,299036,298766,298497
	dc.l	298227,297958,297689,297421,297153,296884,296617,296349
	dc.l	296082,295815,295548,295281,295015,294749,294483,294217
	dc.l	293952,293686,293421,293157,292892,292628,292364,292100
	dc.l	291837,291574,291311,291048,290785,290523,290261,289999
	dc.l	289737,289476,289215,288954,288693,288433,288173,287913
	dc.l	287653,287393,287134,286875,286616,286358,286099,285841
	dc.l	285583,285326,285068,284811,284554,284298,284041,283785
	dc.l	283529,283273,283017,282762,282507,282252,281998,281743
	dc.l	281489,281235,280981,280728,280475,280222,279969,279716
	dc.l	279464,279212,278960,278708,278457,278206,277955,277704
	dc.l	277453,277203,276953,276703,276453,276204,275955,275706
	dc.l	275457,275209,274960,274712,274465,274217,273970,273722
	dc.l	273476,273229,272982,272736,272490,272244,271999,271753
	dc.l	271508,271263,271018,270774,270530,270286,270042,269798
	dc.l	269555,269312,269069,268826,268583,268341,268099,267857

xm_ct	dc.w	xm_arpeggio-xm_ct	;0
	dc.w	xm_ret-xm_ct		;1
	dc.w	xm_ret-xm_ct		;2
	dc.w	xm_ret-xm_ct		;3
	dc.w	xm_ret-xm_ct		;4
 	dc.w	xm_ret-xm_ct		;5
	dc.w	xm_ret-xm_ct		;6
	dc.w	xm_ret-xm_ct		;7
	dc.w	xm_ret-xm_ct		;8
	dc.w	xm_ret-xm_ct		;9
	dc.w	xm_ret-xm_ct		;A
 	dc.w	xm_pjmp-xm_ct		;B
 	dc.w	xm_setvol-xm_ct		;C
 	dc.w	xm_pbrk-xm_ct		;D
 	dc.w	xm_ecmds-xm_ct		;E
 	dc.w	xm_spd-xm_ct		;F
	dc.w	xm_sgvol-xm_ct		;G
 	dc.w	xm_ret-xm_ct		;H
 	dc.w	xm_ret-xm_ct		;I
 	dc.w	xm_ret-xm_ct		;J
 	dc.w	xm_keyoff-xm_ct		;K
 	dc.w	xm_setenvpos-xm_ct	;L
 	dc.w	xm_ret-xm_ct		;M
 	dc.w	xm_ret-xm_ct		;N
 	dc.w	xm_ret-xm_ct		;O
 	dc.w	xm_ret-xm_ct		;P
 	dc.w	xm_ret-xm_ct		;Q
 	dc.w	xm_srretrig-xm_ct	;R
 	dc.w	xm_ret-xm_ct		;S
 	dc.w	xm_tremor-xm_ct		;T
 	dc.w	xm_ret-xm_ct		;U
 	dc.w	xm_ret-xm_ct		;V
 	dc.w	xm_ret-xm_ct		;W
 	dc.w	xm_xfinesld-xm_ct	;X
 	dc.w	xm_ret-xm_ct		;Y
 	dc.w	xm_ret-xm_ct		;Z

xm_cct	dc.w	xm_arpeggio-xm_cct	;0
	dc.w	xm_slideup-xm_cct	;1
	dc.w	xm_slidedwn-xm_cct	;2
	dc.w	xm_tonep-xm_cct		;3
	dc.w	xm_vibrato-xm_cct	;4
	dc.w	xm_tpvsl-xm_cct		;5
	dc.w	xm_vibvsl-xm_cct	;6
	dc.w	xm_tremolo-xm_cct	;7
	dc.w	xm_ret-xm_cct		;8
	dc.w	xm_ret-xm_cct		;9
	dc.w	xm_vslide-xm_cct	;A
 	dc.w	xm_ret-xm_cct		;B
 	dc.w	xm_ret-xm_cct		;C
 	dc.w	xm_ret-xm_cct		;D
 	dc.w	xm_cecmds-xm_cct	;E
 	dc.w	xm_ret-xm_cct		;F
 	dc.w	xm_ret-xm_cct		;G
	dc.w	xm_gvslide-xm_cct	;H
 	dc.w	xm_ret-xm_cct		;I
 	dc.w	xm_ret-xm_cct		;J
 	dc.w	xm_ret-xm_cct		;K
 	dc.w	xm_ret-xm_cct		;L
 	dc.w	xm_ret-xm_cct		;M
 	dc.w	xm_ret-xm_cct		;N
 	dc.w	xm_ret-xm_cct		;O
 	dc.w	xm_ret-xm_cct		;P
 	dc.w	xm_ret-xm_cct		;Q
 	dc.w	xm_rretrig-xm_cct	;R
 	dc.w	xm_ret-xm_cct		;S
 	dc.w	xm_tremor-xm_cct	;T
 	dc.w	xm_ret-xm_cct		;U
 	dc.w	xm_ret-xm_cct		;V
 	dc.w	xm_ret-xm_cct		;W
 	dc.w	xm_ret-xm_cct		;X
 	dc.w	xm_ret-xm_cct		;Y
 	dc.w	xm_ret-xm_cct		;Z

xm_ect	dc.w	xm_ret-xm_ect		;0
	dc.w	xm_slideup-xm_ect	;1
	dc.w	xm_slidedwn-xm_ect	;2
	dc.w	xm_ret-xm_ect		;3
	dc.w	xm_ret-xm_ect		;4
	dc.w	xm_ret-xm_ect		;5
	dc.w	xm_ret-xm_ect		;6
	dc.w	xm_ret-xm_ect		;7
	dc.w	xm_ret-xm_ect		;8
	dc.w	xm_sretrig-xm_ect	;9
	dc.w	xm_vslideup-xm_ect	;A
 	dc.w	xm_vslidedown2-xm_ect	;B
 	dc.w	xm_ncut-xm_ect		;C
 	dc.w	xm_ret-xm_ect		;D
 	dc.w	xm_pdelay-xm_ect	;E
 	dc.w	xm_ret-xm_ect		;F

xm_cect	dc.w	xm_ret-xm_cect		;0
	dc.w	xm_ret-xm_cect		;1
	dc.w	xm_ret-xm_cect		;2
	dc.w	xm_ret-xm_cect		;3
	dc.w	xm_ret-xm_cect		;4
	dc.w	xm_ret-xm_cect		;5
	dc.w	xm_ret-xm_cect		;6
	dc.w	xm_ret-xm_cect		;7
	dc.w	xm_ret-xm_cect		;8
	dc.w	xm_retrig-xm_cect	;9
	dc.w	xm_ret-xm_cect		;A
 	dc.w	xm_ret-xm_cect		;B
 	dc.w	xm_ncut-xm_cect		;C
 	dc.w	xm_ndelay-xm_cect	;D
 	dc.w	xm_ret-xm_cect		;E
 	dc.w	xm_ret-xm_cect		;F

xm_vct	dc.w	xm_ret-xm_vct		;6
	dc.w	xm_ret-xm_vct		;7
	dc.w	xm_vslidedown2-xm_vct	;8
	dc.w	xm_vslideup-xm_vct	;9
	dc.w	xm_svibspd-xm_vct	;A
 	dc.w	xm_ret-xm_vct		;B
 	dc.w	xm_ret-xm_vct		;C
 	dc.w	xm_ret-xm_vct		;D
 	dc.w	xm_ret-xm_vct		;E
 	dc.w	xm_ret-xm_vct		;F

xm_cvct	dc.w	xm_vslidedown2-xm_cvct	;6
	dc.w	xm_vslideup-xm_cvct	;7
	dc.w	xm_ret-xm_cvct		;8
	dc.w	xm_ret-xm_cvct		;9
	dc.w	xm_ret-xm_cvct		;A
 	dc.w	xm_vibrato-xm_cvct	;B
 	dc.w	xm_ret-xm_cvct		;C
 	dc.w	xm_ret-xm_cvct		;D
 	dc.w	xm_ret-xm_cvct		;E
 	dc.w	xm_tonep-xm_cvct	;F


   *************************
   *   Standard effects:   *
   *************************

;!      0      Arpeggio
;!      1  (*) Porta up
;!      2  (*) Porta down
;!      3  (*) Tone porta
;-      4  (*) Vibrato
;!      5  (*) Tone porta+Volume slide
;-      6  (*) Vibrato+Volume slide
;-      7  (*) Tremolo
;*      8      Set panning
;!      9      Sample offset
;!      A  (*) Volume slide
;!      B      Position jump
;!      C      Set volume
;!      D      Pattern break
;!      E1 (*) Fine porta up
;!      E2 (*) Fine porta down
;-      E3     Set gliss control
;-      E4     Set vibrato control
;-      E5     Set finetune
;-      E6     Set loop begin/loop
;-      E7     Set tremolo control
;!      E9     Retrig note
;!      EA (*) Fine volume slide up
;!      EB (*) Fine volume slide down
;!      EC     Note cut
;!      ED     Note delay
;-      EE     Pattern delay
;!      F      Set tempo/BPM
;!      G      Set global volume
;!      H  (*) Global volume slide
;!     	K      Key off
;!      L      Set envelope position
;*      P  (*) Panning slide
;!      R  (*) Multi retrig note
;-      T      Tremor
;-      X1 (*) Extra fine porta up
;-      X2 (*) Extra fine porta down
;
;      (*) = If the command byte is zero, the last nonzero byte for the
;            command should be used.
;
;   *********************************
;   *   Effects in volume column:   *
;   *********************************
;
;   All effects in the volume column should work as the standard effects.
;   The volume column is interpreted before the standard effects, so
;   some standard effects may override volume column effects.
;
;   Value      Meaning
;
;      0       Do nothing
;    $10-$50   Set volume Value-$10
;      :          :        :
;      :          :        :
;!    $60-$6f   Volume slide down
;!    $70-$7f   Volume slide up
;!    $80-$8f   Fine volume slide down
;!    $90-$9f   Fine volume slide up
;-    $a0-$af   Set vibrato speed
;-    $b0-$bf   Vibrato
;*    $c0-$cf   Set panning
;*    $d0-$df   Panning slide left
;*    $e0-$ef   Panning slide right
;!    $f0-$ff   Tone porta


slen		dc.w	0
pats		dc.w	0
inss		dc.w	0

samples		dc.l	0
patts		dc.l	0

fformat		dc.w	0
sflags		dc.w	0

rows		dc.w	63
spd		dc.w	6

cn		dc.w	0
pbflag		dc.w	0
pdelaycnt	dc.b	0
ploopcnt	dc.b	0

numchans	dc.w	0
maxchan		dc.w	0
mtype		dc.w	0			
clock		dc.l	0			; 14317056/4 for S3Ms
globalVol	dc.w	0

pos		dc.w	0
plen		dc.w	0
ppos		dc.l	0


divtabs		ds.l	16

pantab		ds.b	32			;channel panning infos
positioneita	dc.w	1
PS3M_play	dc.w	0
PS3M_break	dc.w	0
PS3M_poschan	dc.w	0
PS3M_position	dc.w	0
PS3M_master	dc.w	64
PS3M_eject	dc.w	0
PS3M_wait	dc.w	0
PS3M_cont	dc.w	0
PS3M_paused	dc.w	0
PS3M_initialized dc.w	0
PS3M_reinit	dc.w	0


; Reset DSP, and load boot.

dsp_boot	move.w	#$71,-(Sp)	; Dsp_RequestUniqueAbility
		trap	#14
		addq.l	#2,sp
		move.w	d0,-(sp)
		move.l	#(DspProgEnd-DspProg)/3,-(sp)
		pea 	DspProg(PC)
		move.w	#$6d,-(sp)
		trap	#14
		lea	12(sp),sp
		rts

; Dsp Code

DspProg		incbin dspaula.bin
DspProgEnd	
		even

* divu_32 --- d0 = d0/d1, d1=jakojäännös
divu_32	move.l	d3,-(a7)
	swap	d1
	tst	d1
	bne.b	lb_5f8c
	swap	d1
	move.l	d1,d3
	swap	d0
	move	d0,d3
	beq.b	lb_5f7c
	divu	d1,d3
	move	d3,d0
lb_5f7c	swap	d0
	move	d0,d3
	divu	d1,d3
	move	d3,d0
	swap	d3
	move	d3,d1
	move.l	(a7)+,d3
	rts	

lb_5f8c	swap	d1
	move	d2,-(a7)
	moveq	#16-1,d3
	move	d3,d2
	move.l	d1,d3
	move.l	d0,d1
	clr	d1
	swap	d1
	swap	d0
	clr	d0
lb_5fa0	add.l	d0,d0
	addx.l	d1,d1
	cmp.l	d1,d3
	bhi.b	lb_5fac
	sub.l	d3,d1
	addq	#1,d0
lb_5fac	dbf	d2,lb_5fa0
	move	(a7)+,d2
	move.l	(a7)+,d3
	rts	

********** Protracker (Fasttracker player) **************

n_note		equ	0
n_cmd		equ	2
n_cmdlo		equ	3
n_start		equ	4
n_length	equ	8
n_loopstart	equ	10
n_replen	equ	14
n_period	equ	16
n_finetune	equ	18
n_volume	equ	19
n_dmabit	equ	20
n_toneportdirec	equ	22
n_toneportspeed	equ	23
n_wantedperiod	equ	24
n_vibratocmd	equ	26
n_vibratopos	equ	27
n_tremolocmd	equ	28
n_tremolopos	equ	29
n_wavecontrol	equ	30
n_glissfunk	equ	31
n_sampleoffset	equ	32
n_pattpos	equ	33
n_loopcount	equ	34
n_funkoffset	equ	35
n_wavestart	equ	36
n_reallength	equ	40

mtm_init
	move.l	mt_data_ptr,a0
	move.l	a0,mt_songdataptr
	lea	4(a0),a1
	;move.l	a1,mname

	move.l	#mtm_periodtable,peris
	move	#1616,lowlim
	move	#45,upplim
	move	#126,octs

	moveq	#0,d0
	move.b	27(a0),d0
	addq.b	#1,d0
	move.b	d0,slene
	move	d0,positioneita

	moveq	#0,d1
	move.b	33(a0),d1
	move	d1,numchans

	moveq	#0,d0
	move.b	32(a0),d0
	lsl	#2,d0
	mulu	d1,d0
	move	d0,patlen

	move.l	a0,d0
	add.l	#66,d0

	moveq	#0,d1
	move.b	30(a0),d1			; NOS
	mulu	#37,d1
	add.l	d1,d0

	move.l	d0,orderz
	add.l	#128,d0
	move.l	d0,tracks

	move	24(a0),d1			; number of tracks
	iword	d1
	mulu	#192,d1
	add.l	d1,d0

	move.l	d0,sequ

	moveq	#0,d1
	move.b	26(a0),d1			; last pattern saved
	addq	#1,d1
	lsl	#6,d1
	add.l	d1,d0

	moveq	#0,d1
	move	28(a0),d1			; length of comment field
	iword	d1
	add.l	d1,d0

	lea	66(a0),a2			; sample infos

	moveq	#0,d7
	move.b	30(a0),d7			; NOS
	subq	#1,d7

	lea	mt_sampleinfos(pc),a1
.loop	move.l	d0,(a1)+
	lea	22(a2),a3
	tlword	(a3)+,d1
	add.l	d1,d0
	lsr.l	#1,d1
	move	d1,(a1)+

	lea	26(a2),a3
	tlword	(a3)+,d1
	lsr.l	#1,d1
	move	d1,(a1)+			; rep offset

	lea	30(a2),a3
	tlword	(a3)+,d2
	lsr.l	#1,d2
	sub.l	d1,d2	
	move	d2,(a1)+			; rep length

	clr.b	(a1)+				; no finetune
	move.b	35(a2),(a1)+			; volume

	lea	37(a2),a2
	dbf	d7,.loop

	;or.b	#2,$bfe001
	move.b	#6,mt_speed
	clr.b	mt_counter
	clr.b	mt_songpos
	clr	mt_patternpos

	move	#2,fformat			; unsigned data
	move	#125,RealTempo
	move.l	#14317056/4,clock		; Clock constant

	lea	34(a0),a2
	lea	pantab,a0
	move.l	a0,a1
	moveq	#7,d0
.lp	clr.l	(a1)+
	dbf	d0,.lp

	move	numchans,d0
	subq	#1,d0
	moveq	#0,d5
	moveq	#0,d6
.lop	move.b	(a2)+,d1
	cmp.b	#8,d1
	blo.b	.vas
	move.b	#-1,(a0)+
	addq	#1,d5
	bra.b	.je
.vas	move.b	#1,(a0)+
	addq	#1,d6
.je	dbf	d0,.lop

	cmp	d5,d6
	bls.b	.k
	move	d6,d5
.k	move	d5,maxchan

	lea	mt_chan1temp(pc),a0
	move	#44*8-1,d0
.cl	clr.l	(a0)+
	dbf	d0,.cl

	moveq	#0,d0
	rts

orderz	dc.l	0
tracks	dc.l	0
sequ	dc.l	0
slene	dc	0
patlen	dc	0
upplim	dc	0
lowlim	dc	0
peris	dc.l	0
octs	dc	0

mt_init	move.l	mt_data_ptr,a0
	;move.l	a0,mname
	move.l	a0,mt_songdataptr
	move.l	a0,a1
	moveq	#0,d0
	move.b	950(a1),d0
	move.b	d0,slene
	move	d0,positioneita

	move	#256,d0
	mulu	numchans,d0
	move	d0,patlen

	move	#113,upplim
	move	#856,lowlim
	move.l	#mt_periodtable,peris
	move	#36*2,octs

	lea	952(a1),a1
	moveq	#127,d0
	moveq	#0,d1
mtloop	move.l	d1,d2
	subq	#1,d0
mtloop2	move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.b	mtloop
	dbra	d0,mtloop2
	addq.b	#1,d2
			
	lea	mt_sampleinfos(pc),a1
	asl	#8,d2
	mulu	numchans,d2

	add.l	#1084,d2
	add.l	a0,d2
	move.l	d2,a2
	moveq	#30,d0
mtloop3	move.l	a2,(a1)+
	moveq	#0,d1
	move	42(a0),d1
	move	d1,(a1)+
	asl.l	#1,d1
	add.l	d1,a2

	move	46(a0),(a1)+
	move	48(a0),(a1)+
	move	44(a0),(a1)+			; finetune and volume

	add.l	#30,a0
	dbra	d0,mtloop3

	;or.b	#2,$bfe001
	move.b	#6,mt_speed
	clr.b	mt_counter
	clr.b	mt_songpos
	clr	mt_patternpos

	move	#1,fformat
	move	#125,RealTempo
	move.l	#14187580/4,clock		; Clock constant

	lea	pantab,a0
	move.l	a0,a1
	moveq	#7,d0
.lp	clr.l	(a1)+
	dbf	d0,.lp

	move	numchans,d0
	subq	#1,d0
	moveq	#0,d1
.lop	tst	d1
	beq.b	.vas
	cmp	#3,d1
	beq.b	.vas
.oik	move.b	#-1,(a0)+
	bra.b	.je
.vas	move.b	#1,(a0)+
.je	addq	#1,d1
	and	#3,d1
	dbf	d0,.lop

	lea	mt_chan1temp(pc),a0
	move	#44*8-1,d0
.cl	clr.l	(a0)+
	dbf	d0,.cl

	moveq	#0,d0
	rts

mt_music
	movem.l	d0-d4/a0-a6,-(sp)
	addq.b	#1,mt_counter
	move.b	mt_counter(pc),d0
	cmp.b	mt_speed(pc),d0
	blo.b	mt_nonewnote
	clr.b	mt_counter
	tst.b	mt_pattdeltime2
	beq.b	mt_getnewnote
	bsr.b	mt_nonewallchannels
	bra	mt_dskip

mt_nonewnote
	bsr.b	mt_nonewallchannels
	bra	mt_nonewposyet

mt_nonewallchannels
	move	numchans,d7
	subq	#1,d7
	lea	cha0,a5
	lea	mt_chan1temp(pc),a6
.loo	move	d7,-(sp)
	bsr	mt_checkefx
	move	(sp)+,d7
	lea	mChanBlock_SIZE(a5),a5
	lea	44(a6),a6			; Size of MT_chanxtemp
	dbf	d7,.loo
	rts

mt_getnewnote
	move.l	mt_songdataptr(pc),a0
	lea	12(a0),a3
	lea	952(a0),a2	;pattpo
	lea	1084(a0),a0	;patterndata
	moveq	#0,d0
	moveq	#0,d1
	move.b	mt_songpos(pc),d0
	move.b	(a2,d0),d1
	asl.l	#8,d1
	mulu	numchans,d1
	add	mt_patternpos(pc),d1
	clr	mt_dmacontemp

	cmp	#mtMTM,mtype
	bne.b	.ei
	moveq	#0,d1
.ei
	move	numchans,d7
	subq	#1,d7
	lea	cha0,a5
	lea	mt_chan1temp(pc),a6
.loo	move	d7,-(sp)

	tst.l	(a6)
	bne.b	.mt_plvskip
	bsr	mt_pernop
.mt_plvskip
	bsr.b	getnew

	bsr	mt_playvoice
	move	(sp)+,d7
	lea	mChanBlock_SIZE(a5),a5
	lea	44(a6),a6			; Size of MT_chanxtemp
	dbf	d7,.loo

	bra	mt_setdma

getnew	cmp	#mtMOD,mtype
	bne.b	.mtm
	move.l	(a0,d1.l),(a6)
	addq.l	#4,d1
	rts

.mtm	move.l	mt_songdataptr(pc),a0
	move.l	orderz(pc),a2
	moveq	#0,d0
	move.b	mt_songpos(pc),d0
	move.b	(a2,d0),d0

	lsl	#6,d0				; 32 channels * word
	move.l	sequ(pc),a2
	add	d1,d0
	move.b	(a2,d0),d2
	lsl	#8,d2
	move.b	1(a2,d0),d2
	move	d2,d0
	beq.b	.zero
	iword	d0
	move.l	tracks(pc),a2
	subq	#1,d0
	mulu	#192,d0

	moveq	#0,d2
	move	mt_patternpos(pc),d2
	divu	numchans,d2
	lsr	#2,d2
	mulu	#3,d2
	add.l	d2,d0

	moveq	#0,d2
	move.b	(a2,d0.l),d2
	lsr	#2,d2
	beq.b	.huu
	move.l	peris(pc),a1
	subq	#1,d2
	add	d2,d2
	move	(a1,d2),d2

.huu	clr.l	(a6)
	or	d2,(a6)

	moveq	#0,d2
	move.b	(a2,d0.l),d2
	lsl	#8,d2
	move.b	1(a2,d0.l),d2
	and	#$3f0,d2
	lsr	#4,d2
	move.b	d2,d3
	and	#$10,d3
	or.b	d3,(a6)
	lsl.b	#4,d2
	or.b	d2,2(a6)

	moveq	#0,d2
	move.b	1(a2,d0.l),d2
	lsl	#8,d2
	move.b	2(a2,d0.l),d2
	and	#$fff,d2
	or	d2,2(a6)

	addq.l	#2,d1
	rts

.zero	clr.l	(a6)
	addq.l	#2,d1
	rts

mt_playvoice
	moveq	#0,d2
	move.b	n_cmd(a6),d2
	and.b	#$f0,d2
	lsr.b	#4,d2
	move.b	(a6),d0
	and.b	#$f0,d0
	or.b	d0,d2
	tst.b	d2
	beq.b	mt_setregs
	moveq	#0,d3
	lea	mt_sampleinfos(pc),a1
	move	d2,d4
	subq	#1,d4
	mulu	#12,d4
	move.l	(a1,d4.l),n_start(a6)
	move	4(a1,d4.l),n_length(a6)
	move	4(a1,d4.l),n_reallength(a6)
	move.b	10(a1,d4.l),n_finetune(a6)
	move.b	11(a1,d4.l),n_volume(a6)
	move	6(a1,d4.l),d3 ; get repeat
	tst	d3
	beq.b	mt_noloop
	move.l	n_start(a6),d2	; get start
	asl	#1,d3
	add.l	d3,d2		; add repeat
	move.l	d2,n_loopstart(a6)
	move.l	d2,n_wavestart(a6)
	move	6(a1,d4.l),d0	; get repeat
	add	8(a1,d4.l),d0	; add replen
	move	d0,n_length(a6)
	move	8(a1,d4.l),n_replen(a6)	; save replen
	moveq	#0,d0
	move.b	n_volume(a6),d0
	move	d0,sam_vol(a5)	; set volume
	bra.b	mt_setregs

mt_noloop
	move.l	n_start(a6),d2
	move.l	d2,n_loopstart(a6)
	move.l	d2,n_wavestart(a6)
	move	8(a1,d4.l),n_replen(a6)	; save replen
	moveq	#0,d0
	move.b	n_volume(a6),d0
	move	d0,sam_vol(a5)	; set volume
mt_setregs
	move	(a6),d0
	and	#$fff,d0
	beq	mt_checkmoreefx	; if no note
	move	2(a6),d0
	and	#$ff0,d0
	cmp	#$e50,d0
	beq.b	mt_dosetfinetune
	move.b	2(a6),d0
	and.b	#$f,d0
	cmp.b	#3,d0	; toneportamento
	beq.b	mt_chktoneporta
	cmp.b	#5,d0
	beq.b	mt_chktoneporta
	cmp.b	#9,d0	; sample offset
	bne.b	mt_setperiod
	bsr	mt_checkmoreefx
	bra.b	mt_setperiod

mt_dosetfinetune
	bsr	mt_setfinetune
	bra.b	mt_setperiod

mt_chktoneporta
	bsr	mt_settoneporta
	bra	mt_checkmoreefx

mt_setperiod
	movem.l	d0-d1/a0-a1,-(sp)
	move	(a6),d1
	and	#$fff,d1
	move.l	peris(pc),a1
	moveq	#0,d0
	move	octs(pc),d7
	lsr	#1,d7
mt_ftuloop
	cmp	(a1,d0),d1
	bhs.b	mt_ftufound
	addq.l	#2,d0
	dbra	d7,mt_ftuloop
mt_ftufound
	moveq	#0,d1
	move.b	n_finetune(a6),d1
	mulu	octs(pc),d1
	add.l	d1,a1
	move	(a1,d0),n_period(a6)
	movem.l	(sp)+,d0-d1/a0-a1

	move	2(a6),d0
	and	#$ff0,d0
	cmp	#$ed0,d0 ; notedelay
	beq	mt_checkmoreefx

	btst	#2,n_wavecontrol(a6)
	bne.b	mt_vibnoc
	clr.b	n_vibratopos(a6)
mt_vibnoc
	btst	#6,n_wavecontrol(a6)
	bne.b	mt_trenoc
	clr.b	n_tremolopos(a6)
mt_trenoc
	move.l	n_start(a6),(a5)	; set start
	moveq	#0,d0
	move	n_length(a6),d0
	add.l	d0,d0
	move.l	d0,sam_length(a5)		; set length
	move	n_period(a6),d0
	lsl	#2,d0
	move	d0,sam_period(a5)		; set period

	clr.b	mOnOff(a5)		; turn on
	clr.l	mFPos(a5)		; retrig
	bra	mt_checkmoreefx

 
mt_setdma
	move	numchans,d7
	subq	#1,d7
	lea	cha0,a5
	lea	mt_chan1temp(pc),a6
.loo	move	d7,-(sp)
	bsr	setreg
	move	(sp)+,d7
	lea	mChanBlock_SIZE(a5),a5
	lea	44(a6),a6			; Size of MT_chanxtemp
	dbf	d7,.loo

mt_dskip
	moveq	#4,d0
	mulu	numchans,d0
	add	d0,mt_patternpos
	move.b	mt_pattdeltime,d0
	beq.b	mt_dskc
	move.b	d0,mt_pattdeltime2
	clr.b	mt_pattdeltime
mt_dskc	tst.b	mt_pattdeltime2
	beq.b	mt_dska
	subq.b	#1,mt_pattdeltime2
	beq.b	mt_dska

	moveq	#4,d0
	mulu	numchans,d0
	sub	d0,mt_patternpos

mt_dska	tst.b	mt_pbreakflag
	beq.b	mt_nnpysk
	sf	mt_pbreakflag
	moveq	#0,d0
	move.b	mt_pbreakpos(pc),d0
	clr.b	mt_pbreakpos
	lsl	#2,d0
	mulu	numchans,d0	
	move	d0,mt_patternpos
mt_nnpysk
	move	patlen(pc),d0
	cmp	mt_patternpos(pc),d0
	bhi.b	mt_nonewposyet
mt_nextposition	
	moveq	#0,d0
	move.b	mt_pbreakpos(pc),d0
	lsl	#2,d0
	mulu	numchans,d0
	move	d0,mt_patternpos
	clr.b	mt_pbreakpos
	clr.b	mt_posjumpflag
	addq.b	#1,mt_songpos
	and.b	#$7f,mt_songpos

	moveq	#0,d1
	move.b	mt_songpos(pc),d1
	st	PS3M_poschan
	move	d1,PS3M_position

	cmp.b	slene(pc),d1
	blo.b	mt_nonewposyet
	clr.b	mt_songpos
	st	PS3M_break
mt_nonewposyet	
	tst.b	mt_posjumpflag
	bne.b	mt_nextposition
	movem.l	(sp)+,d0-d4/a0-a6
	rts


setreg	move.l	n_loopstart(a6),sam_lpstart(a5)
	moveq	#0,d0
	move	n_replen(a6),d0
	add.l	d0,d0
	move.l	d0,sam_lplength(a5)
	cmp.l	#2,sam_lplength(a5)
	bls.b	.eloo
	st	mLoop(a5)
	tst.b	mOnOff(a5)
	beq.b	.ok
	clr.b	mOnOff(a5)
	clr.l	mFPos(a5)
.ok	rts
.eloo	clr.b	mLoop(a5)
	rts


mt_checkefx
	bsr	mt_updatefunk
	move	n_cmd(a6),d0
	and	#$fff,d0
	beq.b	mt_pernop
	move.b	n_cmd(a6),d0
	and.b	#$f,d0
	beq.b	mt_arpeggio
	cmp.b	#1,d0
	beq	mt_portaup
	cmp.b	#2,d0
	beq	mt_portadown
	cmp.b	#3,d0
	beq	mt_toneportamento
	cmp.b	#4,d0
	beq	mt_vibrato
	cmp.b	#5,d0
	beq	mt_toneplusvolslide
	cmp.b	#6,d0
	beq	mt_vibratoplusvolslide
	cmp.b	#$e,d0
	beq	mt_e_commands
setback	move	n_period(a6),d2
	lsl	#2,d2
	move	d2,sam_period(a5)
	cmp.b	#7,d0
	beq	mt_tremolo
	cmp.b	#$a,d0
	beq	mt_volumeslide
mt_return2
	rts

mt_pernop
	move	n_period(a6),d2
	lsl	#2,d2
	move	d2,sam_period(a5)
	rts

mt_arpeggio
	moveq	#0,d0
	move.b	mt_counter(pc),d0
	divs	#3,d0
	swap	d0
	cmp	#0,d0
	beq.b	mt_arpeggio2
	cmp	#2,d0
	beq.b	mt_arpeggio1
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	lsr.b	#4,d0
	bra.b	mt_arpeggio3

mt_arpeggio1
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#15,d0
	bra.b	mt_arpeggio3

mt_arpeggio2
	move	n_period(a6),d2
	bra.b	mt_arpeggio4

mt_arpeggio3
	asl	#1,d0
	moveq	#0,d1
	move.b	n_finetune(a6),d1
	mulu	octs(pc),d1
	move.l	peris(pc),a0
	add.l	d1,a0
	moveq	#0,d1
	move	n_period(a6),d1
	move	octs(pc),d7
	lsr	#1,d7
	subq	#1,d7
mt_arploop
	move	(a0,d0),d2
	cmp	(a0),d1
	bhs.b	mt_arpeggio4
	addq.l	#2,a0
	dbra	d7,mt_arploop
	rts

mt_arpeggio4
	lsl	#2,d2
	move	d2,sam_period(a5)
	rts

mt_fineportaup
	tst.b	mt_counter
	bne	mt_return2
	move.b	#$f,mt_lowmask
mt_portaup
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	mt_lowmask(pc),d0
	move.b	#$ff,mt_lowmask
	sub	d0,n_period(a6)
	move	n_period(a6),d0
	and	#$fff,d0
	cmp	upplim(pc),d0
	bpl.b	mt_portauskip
	and	#$f000,n_period(a6)
	move	upplim(pc),d0
	or	d0,n_period(a6)
mt_portauskip
	move	n_period(a6),d0
	and	#$fff,d0
	lsl	#2,d0
	move	d0,sam_period(a5)
	rts	
 
mt_fineportadown
	tst.b	mt_counter
	bne	mt_return2
	move.b	#$f,mt_lowmask
mt_portadown
	clr	d0
	move.b	n_cmdlo(a6),d0
	and.b	mt_lowmask(pc),d0
	move.b	#$ff,mt_lowmask
	add	d0,n_period(a6)
	move	n_period(a6),d0
	and	#$fff,d0
	cmp	lowlim(pc),d0
	bmi.b	mt_portadskip
	and	#$f000,n_period(a6)
	move	lowlim(pc),d0
	or	d0,n_period(a6)
mt_portadskip
	move	n_period(a6),d0
	and	#$fff,d0
	lsl	#2,d0
	move	d0,sam_period(a5)
	rts

mt_settoneporta
	move.l	a0,-(sp)
	move	(a6),d2
	and	#$fff,d2
	moveq	#0,d0
	move.b	n_finetune(a6),d0
	mulu	octs(pc),d0
	move.l	peris(pc),a0
	add.l	d0,a0
	moveq	#0,d0
mt_stploop
	cmp	(a0,d0),d2
	bhs.b	mt_stpfound
	addq	#2,d0
	cmp	octs(pc),d0
	blo.b	mt_stploop
	move	octs(pc),d0
	subq	#2,d0
mt_stpfound
	move.b	n_finetune(a6),d2
	and.b	#8,d2
	beq.b	mt_stpgoss
	tst	d0
	beq.b	mt_stpgoss
	subq	#2,d0
mt_stpgoss
	move	(a0,d0),d2
	move.l	(sp)+,a0
	move	d2,n_wantedperiod(a6)
	move	n_period(a6),d0
	clr.b	n_toneportdirec(a6)
	cmp	d0,d2
	beq.b	mt_cleartoneporta
	bge	mt_return2
	move.b	#1,n_toneportdirec(a6)
	rts

mt_cleartoneporta
	clr	n_wantedperiod(a6)
	rts

mt_toneportamento
	move.b	n_cmdlo(a6),d0
	beq.b	mt_toneportnochange
	move.b	d0,n_toneportspeed(a6)
	clr.b	n_cmdlo(a6)
mt_toneportnochange
	tst	n_wantedperiod(a6)
	beq	mt_return2
	moveq	#0,d0
	move.b	n_toneportspeed(a6),d0
	tst.b	n_toneportdirec(a6)
	bne.b	mt_toneportaup
mt_toneportadown
	add	d0,n_period(a6)
	move	n_wantedperiod(a6),d0
	cmp	n_period(a6),d0
	bgt.b	mt_toneportasetper
	move	n_wantedperiod(a6),n_period(a6)
	clr	n_wantedperiod(a6)
	bra.b	mt_toneportasetper

mt_toneportaup
	sub	d0,n_period(a6)
	move	n_wantedperiod(a6),d0
	cmp	n_period(a6),d0
	blt.b	mt_toneportasetper
	move	n_wantedperiod(a6),n_period(a6)
	clr	n_wantedperiod(a6)

mt_toneportasetper
	move	n_period(a6),d2
	move.b	n_glissfunk(a6),d0
	and.b	#$f,d0
	beq.b	mt_glissskip
	moveq	#0,d0
	move.b	n_finetune(a6),d0
	mulu	octs(pc),d0
	move.l	peris(pc),a0
	add.l	d0,a0
	moveq	#0,d0
mt_glissloop
	cmp	(a0,d0),d2
	bhs.b	mt_glissfound
	addq	#2,d0
	cmp	octs(pc),d0
	blo.b	mt_glissloop
	move	octs(pc),d0
	subq	#2,d0
mt_glissfound
	move	(a0,d0),d2
mt_glissskip
	lsl	#2,d2
	move	d2,sam_period(a5) ; set period
	rts

mt_vibrato
	move.b	n_cmdlo(a6),d0
	beq.b	mt_vibrato2
	move.b	n_vibratocmd(a6),d2
	and.b	#$f,d0
	beq.b	mt_vibskip
	and.b	#$f0,d2
	or.b	d0,d2
mt_vibskip
	move.b	n_cmdlo(a6),d0
	and.b	#$f0,d0
	beq.b	mt_vibskip2
	and.b	#$f,d2
	or.b	d0,d2
mt_vibskip2
	move.b	d2,n_vibratocmd(a6)
mt_vibrato2
	move.b	n_vibratopos(a6),d0
	lea	mt_vibratotable(pc),a4
	lsr	#2,d0
	and	#$1f,d0
	moveq	#0,d2
	move.b	n_wavecontrol(a6),d2
	and.b	#3,d2
	beq.b	mt_vib_sine
	lsl.b	#3,d0
	cmp.b	#1,d2
	beq.b	mt_vib_rampdown
	move.b	#255,d2
	bra.b	mt_vib_set
mt_vib_rampdown
	tst.b	n_vibratopos(a6)
	bpl.b	mt_vib_rampdown2
	move.b	#255,d2
	sub.b	d0,d2
	bra.b	mt_vib_set
mt_vib_rampdown2
	move.b	d0,d2
	bra.b	mt_vib_set
mt_vib_sine
	move.b	0(a4,d0),d2
mt_vib_set
	move.b	n_vibratocmd(a6),d0
	and	#15,d0
	mulu	d0,d2
	lsr	#7,d2
	move	n_period(a6),d0
	tst.b	n_vibratopos(a6)
	bmi.b	mt_vibratoneg
	add	d2,d0
	bra.b	mt_vibrato3
mt_vibratoneg
	sub	d2,d0
mt_vibrato3
	lsl	#2,d0
	move	d0,sam_period(a5)
	move.b	n_vibratocmd(a6),d0
	lsr	#2,d0
	and	#$3c,d0
	add.b	d0,n_vibratopos(a6)
	rts

mt_toneplusvolslide
	bsr	mt_toneportnochange
	bra	mt_volumeslide

mt_vibratoplusvolslide
	bsr.b	mt_vibrato2
	bra	mt_volumeslide

mt_tremolo
	move.b	n_cmdlo(a6),d0
	beq.b	mt_tremolo2
	move.b	n_tremolocmd(a6),d2
	and.b	#$f,d0
	beq.b	mt_treskip
	and.b	#$f0,d2
	or.b	d0,d2
mt_treskip
	move.b	n_cmdlo(a6),d0
	and.b	#$f0,d0
	beq.b	mt_treskip2
	and.b	#$f,d2
	or.b	d0,d2
mt_treskip2
	move.b	d2,n_tremolocmd(a6)
mt_tremolo2
	move.b	n_tremolopos(a6),d0
	lea	mt_vibratotable(pc),a4
	lsr	#2,d0
	and	#$1f,d0
	moveq	#0,d2
	move.b	n_wavecontrol(a6),d2
	lsr.b	#4,d2
	and.b	#3,d2
	beq.b	mt_tre_sine
	lsl.b	#3,d0
	cmp.b	#1,d2
	beq.b	mt_tre_rampdown
	move.b	#255,d2
	bra.b	mt_tre_set
mt_tre_rampdown
	tst.b	n_vibratopos(a6)
	bpl.b	mt_tre_rampdown2
	move.b	#255,d2
	sub.b	d0,d2
	bra.b	mt_tre_set
mt_tre_rampdown2
	move.b	d0,d2
	bra.b	mt_tre_set
mt_tre_sine
	move.b	0(a4,d0),d2
mt_tre_set
	move.b	n_tremolocmd(a6),d0
	and	#15,d0
	mulu	d0,d2
	lsr	#6,d2
	moveq	#0,d0
	move.b	n_volume(a6),d0
	tst.b	n_tremolopos(a6)
	bmi.b	mt_tremoloneg
	add	d2,d0
	bra.b	mt_tremolo3
mt_tremoloneg
	sub	d2,d0
mt_tremolo3
	bpl.b	mt_tremoloskip
	clr	d0
mt_tremoloskip
	cmp	#$40,d0
	bls.b	mt_tremolook
	move	#$40,d0
mt_tremolook
	move	d0,sam_vol(a5)
	move.b	n_tremolocmd(a6),d0
	lsr	#2,d0
	and	#$3c,d0
	add.b	d0,n_tremolopos(a6)
	rts

mt_sampleoffset
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	beq.b	mt_sononew
	move.b	d0,n_sampleoffset(a6)
mt_sononew
	move.b	n_sampleoffset(a6),d0
	lsl	#7,d0
	cmp	n_length(a6),d0
	bge.b	mt_sofskip
	sub	d0,n_length(a6)
	lsl	#1,d0
	add.l	d0,n_start(a6)
	rts
mt_sofskip
	move	#1,n_length(a6)
	rts

mt_volumeslide
	move.b	n_cmdlo(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.b	mt_volslidedown
mt_volslideup
	add.b	d0,n_volume(a6)
	cmp.b	#$40,n_volume(a6)
	bmi.b	mt_vsuskip
	move.b	#$40,n_volume(a6)
mt_vsuskip
	move.b	n_volume(a6),d0
	move.b	d0,sam_vol+1(a5)
	rts

mt_volslidedown
	moveq	#$f,d0
	and.b	n_cmdlo(a6),d0
mt_volslidedown2
	sub.b	d0,n_volume(a6)
	bpl.b	mt_vsdskip
	clr.b	n_volume(a6)
mt_vsdskip
	move.b	n_volume(a6),d0
	move	d0,sam_vol(a5)
	rts

mt_positionjump
	move.b	n_cmdlo(a6),d0
	cmp.b	mt_songpos(pc),d0
	bhi.b	.e
	st	PS3M_break

.e	subq.b	#1,d0
	move.b	d0,mt_songpos
mt_pj2	clr.b	mt_pbreakpos
	st 	mt_posjumpflag
	rts

mt_volumechange
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	cmp.b	#$40,d0
	bls.b	mt_volumeok
	moveq	#$40,d0
mt_volumeok
	move.b	d0,n_volume(a6)
	move	d0,sam_vol(a5)
	rts

mt_patternbreak
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	move.l	d0,d2
	lsr.b	#4,d0
	mulu	#10,d0
	and.b	#$f,d2
	add.b	d2,d0
	cmp.b	#63,d0
	bhi.b	mt_pj2
	move.b	d0,mt_pbreakpos
	st	mt_posjumpflag
	st	PS3M_poschan
	rts

mt_setspeed
	moveq	#0,d0
	move.b	3(a6),d0
	bne.b	.e
	st	PS3M_break
	bra.b	.q
.e	clr.b	mt_counter
	TST.W tempo_flag		; tempo control on?
	BEQ.S .miss
	cmp	#32,d0
	bhs.b	mt_settempo
.miss	move.b	d0,mt_speed
.q	rts

mt_settempo
	move.l	d1,-(sp)
	move.w	d0,RealTempo
	;move.l	mrate,d1
	;move.l	d1,d2
	;lsl.l	#2,d1
	;add.l	d2,d1
	;add	d0,d0
	;divu	d0,d1

	;addq	#1,d1
	;and	#~1,d1
	;move	d1,bytesperframe
	move.l	(sp)+,d1
	rts

mt_checkmoreefx
	bsr	mt_updatefunk
	move.b	2(a6),d0
	and.b	#$f,d0
	cmp.b	#$9,d0
	beq	mt_sampleoffset
	cmp.b	#$b,d0
	beq	mt_positionjump
	cmp.b	#$d,d0
	beq	mt_patternbreak
	cmp.b	#$e,d0
	beq.b	mt_e_commands
	cmp.b	#$f,d0
	beq.b	mt_setspeed
	cmp.b	#$c,d0
	beq	mt_volumechange

	cmp	#mtMOD,mtype
	beq	mt_pernop

; MTM runs these also in set frames

	cmp.b	#1,d0
	beq	mt_portaup
	cmp.b	#2,d0
	beq	mt_portadown
	cmp.b	#3,d0
	beq	mt_toneportamento
	cmp.b	#4,d0
	beq	mt_vibrato
	cmp.b	#5,d0
	beq	mt_toneplusvolslide
	cmp.b	#6,d0
	beq	mt_vibratoplusvolslide
	bra	mt_pernop


mt_e_commands
	move.b	n_cmdlo(a6),d0
	and.b	#$f0,d0
	lsr.b	#4,d0
;	beq.b	mt_filteronoff
	cmp.b	#1,d0
	beq	mt_fineportaup
	cmp.b	#2,d0
	beq	mt_fineportadown
	cmp.b	#3,d0
	beq.b	mt_setglisscontrol
	cmp.b	#4,d0
	beq	mt_setvibratocontrol
	cmp.b	#5,d0
	beq	mt_setfinetune
	cmp.b	#6,d0
	beq	mt_jumploop
	cmp.b	#7,d0
	beq	mt_settremolocontrol
	cmp.b	#9,d0
	beq	mt_retrignote
	cmp.b	#$a,d0
	beq	mt_volumefineup
	cmp.b	#$b,d0
	beq	mt_volumefinedown
	cmp.b	#$c,d0
	beq	mt_notecut
	cmp.b	#$d,d0
	beq	mt_notedelay
	cmp.b	#$e,d0
	beq	mt_patterndelay
	cmp.b	#$f,d0
	beq	mt_funkit
	rts

mt_filteronoff
	move.b	n_cmdlo(a6),d0
	and.b	#1,d0
	asl.b	#1,d0
	;and.b	#$fd,$bfe001
	;or.b	d0,$bfe001
	rts	

mt_setglisscontrol
	move.b	n_cmdlo(a6),d0
	and.b	#$f,d0
	and.b	#$f0,n_glissfunk(a6)
	or.b	d0,n_glissfunk(a6)
	rts

mt_setvibratocontrol
	move.b	n_cmdlo(a6),d0
	and.b	#$f,d0
	and.b	#$f0,n_wavecontrol(a6)
	or.b	d0,n_wavecontrol(a6)
	rts

mt_setfinetune
	move.b	n_cmdlo(a6),d0
	and.b	#$f,d0
	move.b	d0,n_finetune(a6)
	rts

mt_jumploop
	tst.b	mt_counter
	bne	mt_return2
	move.b	n_cmdlo(a6),d0
	and.b	#$f,d0
	beq.b	mt_setloop
	tst.b	n_loopcount(a6)
	beq.b	mt_jumpcnt
	subq.b	#1,n_loopcount(a6)
	beq	mt_return2
mt_jmploop
	move.b	n_pattpos(a6),mt_pbreakpos
	st	mt_pbreakflag
	rts

mt_jumpcnt
	move.b	d0,n_loopcount(a6)
	bra.b	mt_jmploop

mt_setloop
	move	mt_patternpos(pc),d0
	lsr	#4,d0
	move.b	d0,n_pattpos(a6)
	rts

mt_settremolocontrol
	move.b	n_cmdlo(a6),d0
	and.b	#$f,d0
	lsl.b	#4,d0
	and.b	#$f,n_wavecontrol(a6)
	or.b	d0,n_wavecontrol(a6)
	rts

mt_retrignote
	move.l	d1,-(sp)
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$f,d0
	beq.b	mt_rtnend
	moveq	#0,d1
	move.b	mt_counter(pc),d1
	bne.b	mt_rtnskp
	move	(a6),d1
	and	#$fff,d1
	bne.b	mt_rtnend
	moveq	#0,d1
	move.b	mt_counter(pc),d1
mt_rtnskp
	divu	d0,d1
	swap	d1
	tst	d1
	bne.b	mt_rtnend
mt_doretrig
	move.l	n_start(a6),(a5)	; set start
	moveq	#0,d1
	move	n_length(a6),d1
	add.l	d1,d1
	move.l	d1,sam_length(a5)		; set length
	clr.b	mOnOff(a5)		; turn on
	clr.l	mFPos(a5)		; retrig

	move.l	n_loopstart(a6),sam_lpstart(a5)
	moveq	#0,d1
	move	n_replen(a6),d1
	add.l	d1,d1
	move.l	d1,sam_lplength(a5)
	cmp.l	#2,sam_lplength(a5)
	bls.b	.eloo
	st	mLoop(a5)
	move.l	(sp)+,d1
	rts
.eloo	clr.b	mLoop(a5)

mt_rtnend
	move.l	(sp)+,d1
	rts

mt_volumefineup
	tst.b	mt_counter
	bne	mt_return2
	moveq	#$f,d0
	and.b	n_cmdlo(a6),d0
	bra	mt_volslideup

mt_volumefinedown
	tst.b	mt_counter
	bne	mt_return2
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$f,d0
	bra	mt_volslidedown2

mt_notecut
	moveq	#$f,d0
	and.b	n_cmdlo(a6),d0
	cmp.b	mt_counter(pc),d0
	bne	mt_return2
	clr.b	n_volume(a6)
	clr	sam_vol(a5)
	rts

mt_notedelay
	moveq	#$f,d0
	and.b	n_cmdlo(a6),d0
	cmp.b	mt_counter(pc),d0
	bne	mt_return2
	move	(a6),d0
	beq	mt_return2

	move	n_period(a6),d0
	lsl	#2,d0
	move	d0,sam_period(a5)		; set period
	move.l	d1,-(sp)
	bra	mt_doretrig

mt_patterndelay
	tst.b	mt_counter
	bne	mt_return2
	moveq	#$f,d0
	and.b	n_cmdlo(a6),d0
	tst.b	mt_pattdeltime2
	bne	mt_return2
	addq.b	#1,d0
	move.b	d0,mt_pattdeltime
	rts

mt_funkit
	tst.b	mt_counter
	bne	mt_return2
	move.b	n_cmdlo(a6),d0
	lsl.b	#4,d0
	and.b	#$f,n_glissfunk(a6)
	or.b	d0,n_glissfunk(a6)
	tst.b	d0
	beq	mt_return2
mt_updatefunk
	movem.l	a0/d1,-(sp)
	moveq	#0,d0
	move.b	n_glissfunk(a6),d0
	lsr.b	#4,d0
	beq.b	mt_funkend
	lea	mt_funktable(pc),a0
	move.b	(a0,d0),d0
	add.b	d0,n_funkoffset(a6)
	btst	#7,n_funkoffset(a6)
	beq.b	mt_funkend
	clr.b	n_funkoffset(a6)

	move.l	n_loopstart(a6),d0
	moveq	#0,d1
	move	n_replen(a6),d1
	add.l	d1,d0
	add.l	d1,d0
	move.l	n_wavestart(a6),a0
	addq.l	#1,a0
	cmp.l	d0,a0
	blo.b	mt_funkok
	move.l	n_loopstart(a6),a0
mt_funkok
	move.l	a0,n_wavestart(a6)
	moveq	#-1,d0
	sub.b	(a0),d0
	move.b	d0,(a0)
mt_funkend
	movem.l	(sp)+,a0/d1
	rts


mt_funktable dc.b 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128

mt_vibratotable	
	dc.b   0, 24, 49, 74, 97,120,141,161
	dc.b 180,197,212,224,235,244,250,253
	dc.b 255,253,250,244,235,224,212,197
	dc.b 180,161,141,120, 97, 74, 49, 24

mt_periodtable
; tuning 0, normal
	dc.w	856,808,762,720,678,640,604,570,538,508,480,453
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113
; tuning 1
	dc.w	850,802,757,715,674,637,601,567,535,505,477,450
	dc.w	425,401,379,357,337,318,300,284,268,253,239,225
	dc.w	213,201,189,179,169,159,150,142,134,126,119,113
; tuning 2
	dc.w	844,796,752,709,670,632,597,563,532,502,474,447
	dc.w	422,398,376,355,335,316,298,282,266,251,237,224
	dc.w	211,199,188,177,167,158,149,141,133,125,118,112
; tuning 3
	dc.w	838,791,746,704,665,628,592,559,528,498,470,444
	dc.w	419,395,373,352,332,314,296,280,264,249,235,222
	dc.w	209,198,187,176,166,157,148,140,132,125,118,111
; tuning 4
	dc.w	832,785,741,699,660,623,588,555,524,495,467,441
	dc.w	416,392,370,350,330,312,294,278,262,247,233,220
	dc.w	208,196,185,175,165,156,147,139,131,124,117,110
; tuning 5
	dc.w	826,779,736,694,655,619,584,551,520,491,463,437
	dc.w	413,390,368,347,328,309,292,276,260,245,232,219
	dc.w	206,195,184,174,164,155,146,138,130,123,116,109
; tuning 6
	dc.w	820,774,730,689,651,614,580,547,516,487,460,434
	dc.w	410,387,365,345,325,307,290,274,258,244,230,217
	dc.w	205,193,183,172,163,154,145,137,129,122,115,109
; tuning 7
	dc.w	814,768,725,684,646,610,575,543,513,484,457,431
	dc.w	407,384,363,342,323,305,288,272,256,242,228,216
	dc.w	204,192,181,171,161,152,144,136,128,121,114,108
; tuning -8
	dc.w	907,856,808,762,720,678,640,604,570,538,508,480
	dc.w	453,428,404,381,360,339,320,302,285,269,254,240
	dc.w	226,214,202,190,180,170,160,151,143,135,127,120
; tuning -7
	dc.w	900,850,802,757,715,675,636,601,567,535,505,477
	dc.w	450,425,401,379,357,337,318,300,284,268,253,238
	dc.w	225,212,200,189,179,169,159,150,142,134,126,119
; tuning -6
	dc.w	894,844,796,752,709,670,632,597,563,532,502,474
	dc.w	447,422,398,376,355,335,316,298,282,266,251,237
	dc.w	223,211,199,188,177,167,158,149,141,133,125,118
; tuning -5
	dc.w	887,838,791,746,704,665,628,592,559,528,498,470
	dc.w	444,419,395,373,352,332,314,296,280,264,249,235
	dc.w	222,209,198,187,176,166,157,148,140,132,125,118
; tuning -4
	dc.w	881,832,785,741,699,660,623,588,555,524,494,467
	dc.w	441,416,392,370,350,330,312,294,278,262,247,233
	dc.w	220,208,196,185,175,165,156,147,139,131,123,117
; tuning -3
	dc.w	875,826,779,736,694,655,619,584,551,520,491,463
	dc.w	437,413,390,368,347,328,309,292,276,260,245,232
	dc.w	219,206,195,184,174,164,155,146,138,130,123,116
; tuning -2
	dc.w	868,820,774,730,689,651,614,580,547,516,487,460
	dc.w	434,410,387,365,345,325,307,290,274,258,244,230
	dc.w	217,205,193,183,172,163,154,145,137,129,122,115
; tuning -1
	dc.w	862,814,768,725,684,646,610,575,543,513,484,457
	dc.w	431,407,384,363,342,323,305,288,272,256,242,228
	dc.w	216,203,192,181,171,161,152,144,136,128,121,114


mtm_periodtable
; Tuning 0, Normal
	dc.w	1616,1524,1440,1356,1280,1208,1140,1076,1016,960,907
	dc.w	856,808,762,720,678,640,604,570,538,508,480,453
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113
	dc.w	107,101,95,90,85,80,75,71,67,63,60,56
	dc.w	53,50,48,45

; Tuning 1
	dc.w	1604,1514,1430,1348,1274,1202,1134,1070,1010,954,900
	dc.w	850,802,757,715,674,637,601,567,535,505,477,450
	dc.w	425,401,379,357,337,318,300,284,268,253,239,225
	dc.w	213,201,189,179,169,159,150,142,134,126,119,113
	dc.w	106,100,94,89,84,80,75,71,67,63,59,56
	dc.w	53,50,47,45

; Tuning 2
	dc.w	1592,1504,1418,1340,1264,1194,1126,1064,1004,948,894
	dc.w	844,796,752,709,670,632,597,563,532,502,474,447
	dc.w	422,398,376,355,335,316,298,282,266,251,237,224
	dc.w	211,199,188,177,167,158,149,141,133,125,118,112
	dc.w	105,99,94,88,83,79,74,70,66,62,59,56
	dc.w	53,50,47,44

; Tuning 3
	dc.w	1582,1492,1408,1330,1256,1184,1118,1056,996,940,888
	dc.w	838,791,746,704,665,628,592,559,528,498,470,444
	dc.w	419,395,373,352,332,314,296,280,264,249,235,222
	dc.w	209,198,187,176,166,157,148,140,132,125,118,111
	dc.w	104,99,93,88,83,78,74,70,66,62,59,55
	dc.w	52,49,47,44

; Tuning 4
	dc.w	1570,1482,1398,1320,1246,1176,1110,1048,990,934,882
	dc.w	832,785,741,699,660,623,588,555,524,495,467,441
	dc.w	416,392,370,350,330,312,294,278,262,247,233,220
	dc.w	208,196,185,175,165,156,147,139,131,124,117,110
	dc.w	104,98,92,87,82,78,73,69,65,62,58,55
	dc.w	52,49,46,44

; Tuning 5
	dc.w	1558,1472,1388,1310,1238,1168,1102,1040,982,926,874
	dc.w	826,779,736,694,655,619,584,551,520,491,463,437
	dc.w	413,390,368,347,328,309,292,276,260,245,232,219
	dc.w	206,195,184,174,164,155,146,138,130,123,116,109
	dc.w	103,97,92,87,82,77,73,69,65,61,58,54
	dc.w	52,49,46,43

; Tuning 6
	dc.w	1548,1460,1378,1302,1228,1160,1094,1032,974,920,868
	dc.w	820,774,730,689,651,614,580,547,516,487,460,434
	dc.w	410,387,365,345,325,307,290,274,258,244,230,217
	dc.w	205,193,183,172,163,154,145,137,129,122,115,109
	dc.w	102,97,91,86,81,77,72,68,64,61,57,54
	dc.w	51,48,46,43

; Tuning 7
	dc.w	1536,1450,1368,1292,1220,1150,1086,1026,968,914,862
	dc.w	814,768,725,684,646,610,575,543,513,484,457,431
	dc.w	407,384,363,342,323,305,288,272,256,242,228,216
	dc.w	204,192,181,171,161,152,144,136,128,121,114,108
	dc.w	102,96,91,85,81,76,72,68,64,60,57,54
	dc.w	51,48,45,43

; Tuning -8
	dc.w	1712,1616,1524,1440,1356,1280,1208,1140,1076,1016,960
	dc.w	907,856,808,762,720,678,640,604,570,538,508,480
	dc.w	453,428,404,381,360,339,320,302,285,269,254,240
	dc.w	226,214,202,190,180,170,160,151,143,135,127,120
	dc.w	113,107,101,95,90,85,80,75,71,67,63,60
	dc.w	56,53,50,48

; Tuning -7
	dc.w	1700,1604,1514,1430,1350,1272,1202,1134,1070,1010,954
	dc.w	900,850,802,757,715,675,636,601,567,535,505,477
	dc.w	450,425,401,379,357,337,318,300,284,268,253,238
	dc.w	225,212,200,189,179,169,159,150,142,134,126,119
	dc.w	112,106,100,94,89,84,79,75,71,67,63,60
	dc.w	56,53,50,47

; Tuning -6
	dc.w	1688,1592,1504,1418,1340,1264,1194,1126,1064,1004,948
	dc.w	894,844,796,752,709,670,632,597,563,532,502,474
	dc.w	447,422,398,376,355,335,316,298,282,266,251,237
	dc.w	223,211,199,188,177,167,158,149,141,133,125,118
	dc.w	112,105,99,94,89,84,79,75,70,66,63,59
	dc.w	56,53,50,47

; Tuning -5
	dc.w	1676,1582,1492,1408,1330,1256,1184,1118,1056,996,940
	dc.w	887,838,791,746,704,665,628,592,559,528,498,470
	dc.w	444,419,395,373,352,332,314,296,280,264,249,235
	dc.w	222,209,198,187,176,166,157,148,140,132,125,118
	dc.w	111,105,99,93,88,83,78,74,70,66,62,59
	dc.w	55,52,49,47

; Tuning -4
	dc.w	1664,1570,1482,1398,1320,1246,1176,1110,1048,988,934
	dc.w	881,832,785,741,699,660,623,588,555,524,494,467
	dc.w	441,416,392,370,350,330,312,294,278,262,247,233
	dc.w	220,208,196,185,175,165,156,147,139,131,123,117
	dc.w	110,104,98,93,87,82,78,73,69,65,62,58
	dc.w	55,52,49,46

; Tuning -3
	dc.w	1652,1558,1472,1388,1310,1238,1168,1102,1040,982,926
	dc.w	875,826,779,736,694,655,619,584,551,520,491,463
	dc.w	437,413,390,368,347,328,309,292,276,260,245,232
	dc.w	219,206,195,184,174,164,155,146,138,130,123,116
	dc.w	109,103,97,92,87,82,77,73,69,65,61,58
	dc.w	55,52,49,46

; Tuning -2
	dc.w	1640,1548,1460,1378,1302,1228,1160,1094,1032,974,920
	dc.w	868,820,774,730,689,651,614,580,547,516,487,460
	dc.w	434,410,387,365,345,325,307,290,274,258,244,230
	dc.w	217,205,193,183,172,163,154,145,137,129,122,115
	dc.w	108,102,97,91,86,81,77,72,68,64,61,57
	dc.w	54,51,48,46

; Tuning -1
	dc.w	1628,1536,1450,1368,1292,1220,1150,1086,1026,968,914
	dc.w	862,814,768,725,684,646,610,575,543,513,484,457
	dc.w	431,407,384,363,342,323,305,288,272,256,242,228
	dc.w	216,203,192,181,171,161,152,144,136,128,121,114
	dc.w	108,102,96,91,85,81,76,72,68,64,60,57
	dc.w	54,51,48,45

mt_chan1temp	ds.b	44*32

mt_sampleinfos
	ds	31*12

mt_songdataptr	dc.l 0

mt_speed	dc.b 6
mt_tempo	dc.b 0
mt_counter	dc.b 0
mt_songpos	dc.b 0
mt_pbreakpos	dc.b 0
mt_posjumpflag	dc.b 0
mt_pbreakflag	dc.b 0
mt_lowmask	dc.b 0
mt_pattdeltime	dc.b 0
mt_pattdeltime2	dc.b 0

mt_patternpos	dc.w 0
mt_dmacontemp	dc.w 0


; Paula emulation storage structure.

old_stuff	DS.L 8
interpolate_flag dc.l 1
tempo_flag 	DC.W 1
RealTempo	dc.w 125
mt_1Pat_Size	DC.W 0	
mt_1Pos_size	DC.W 0
shadow_dmacon	DS.W 1
shadow_filter	DS.W 1
player_sem	DC.W 0
mt_data_ptr	DC.L 0
modlength	DC.L 0

saved_alloc_addr ds.l 1
error_no	DC.L 0
errorflag	DC.W 0
modtype_str_ptrs
		DC.L module_type1
		DC.L module_type2
		DC.L module_type3
		DC.L module_type4

onoff_txt	DC.B 'Off',0
		DC.B 'On ',0

playingtxt	DC.B "Now Playing : "
realmodname	DS.B 24
unnamed_mod	DC.B "Unnamed Module!",0
loading		DC.B 27,"E","Loading : "
filename	DS.B 128
module_type_txt	DC.B $A,$D," (Mod Type) : ",0
module_type1	DC.B "Scream Tracker",$a,$d,0
module_type2	DC.B "Protracker/FastTracker",$a,$d,0
module_type3	DC.B "MTM",$a,$d,0
module_type4	DC.B "FastTracker ][",$a,$d,0

interpolate_txt	DC.B $d,"Interpolation:",0
tempocontrl_txt	DC.B "  Tempo Control:",0
newline		dc.b $a,$d,0

thetext		dc.b 27,"E"	
		dc.b "       MultiTracker Replay      ",$a,$d
 		dc.b "    - Falcon030 Version v1.0 - ",$a,$d
 		dc.b "          Programmed by        ",$a,$d
 		dc.b "    Griff of Electronic Images ",$a,$d
 		dc.b " <I> toggles interpolation On/Off ",$a,$d
 		dc.b " <T> toggles tempo control On/Off ",$a,$d,$a,$d
 		dc.b 0

installtxt	DC.B 27,"E"
		DC.B "You must install this program as an",10,13
		DC.B "application on the Gem desktop,",10,13
		DC.B "OR Type the Module Name if you are",10,13
		DC.B "running this from a command line!",10,13
		DC.B "Press any key.",10,13,0

load_errortxt	DC.B 27,"E"
		DC.B "Load Error(disk error?)",10,13
		DC.B "Press any key.",10,13,0
outofmem_txt	DC.B 27,"E"
		DC.B "Not enough memory to load module",10,13
		DC.B "Press any key.",10,13,0

filenf_errortxt	DC.B 27,"E"
		DC.B "File Not Found",10,13
		DC.B "Press any key.",10,13,0
		EVEN
xmsign		dc.b	'Extended Module:',0
		EVEN

		section	bss

c0		ds.b	s3mChanBlock_SIZE*32
cha0		ds.b	mChanBlock_SIZE*32

xm_patts	ds.l	256
xm_insts	ds.l	128

		ds.l 	1024
my_stack	ds.l	8
