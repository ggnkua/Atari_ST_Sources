;-----------------------------------------------------------------------;
;									;
;			   TTP .MOD Player				;
;	           16 Bit Falcon030 Pro-Tracker 2.1A Driver  		;
;                (C) January 1992 Griff of Electronic Images		;
;									;
; - 50 khz 16bit stereo sound, (15bits per channel)			;
; - The ONLY player in the whole wide world to emulate TEMPO properly.	;
;-----------------------------------------------------------------------;
; Quick notes about this source.					;
; - Assemble using DEVPAC 2 or 3.					;
; - This replay is NOT fast and nor should it be. 			;
;-----------------------------------------------------------------------;
; v1.0p   Falcon Version!
; v1.1p   Power Packer decrunch works as does modplayer
; v1.2p   No self modifying code now.
; v1.3p   Fixed tempo change set routine.
; v1.4p   DSP play routine instead.
; v1.5p   Interpolation toggle.

		output c:\usr\installd\falcpl13.app

		opt c-

test		EQU 1			; if test=1 then run from assember
					; (with a pre-included module)
bufsize 	EQU 5500		; maximum size of buffer
					; (when tempo =32)

		OPT O+,OW-

letsgo		
		IFEQ test
		MOVEA.L 4(A7),A5
		LEA $80(A5),A5			; -> length,filename
		ELSEIF
		LEA testfile,A5			;  if in testmode
		ENDC				; then -> testfilename

		MOVE.B (A5)+,D0 		; get filename length.
		BEQ mustinstall			; no filename given?
		LEA filename(PC),A4
.lp		MOVE.B (A5)+,(A4)+		
		SUBQ.B #1,D0
		BNE.S .lp
		CLR.B (A4)			; terminate filename

		MOVE.L 4(SP),A5
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
		CLR.L -(SP)
		MOVE #$20,-(SP)	
		TRAP #1				; supervisor mode
		ADDQ.L #6,SP
		MOVE.L D0,oldsp
		LEA my_stack,SP			; our own stack.
		;DC.W $A00A			; hide mouse
		BSR M_SaveSound	
		BSR load_mod			; load the module
		LEA mt_data,A0
		MOVE.L A0,mt_data_ptr
.test_pp	CMP.L #'PP20',mt_data
		BNE.S .notpp
.is_pp		LEA mt_data,A0
		LEA 4(A0),A5
		LEA 256(A0),A3
		MOVE.L A3,mt_data_ptr
		ADD.L modlength(PC),A0
		BSR PP_Decrunch
.notpp
		TST.B errorflag
		BNE load_error			; exit if load error
		BSR print_mainscr		; print main screen
		BSR Wait_Vbl
.goformusic	BSR Wait_Vbl
		BSR M_Setup		
		BSR M_On 

; Music playing, key selection loop follows(microwire control)

.k_lp		MOVE.W #7,-(SP)
		TRAP #1
		ADDQ.L #2,SP
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

.out 		
		BSR M_Off 

exit		
exitloaderr	
		BSR M_RestSound	
		;DC.W $A009
		MOVE.L oldsp(PC),-(SP)
		MOVE #$20,-(SP)	
		TRAP #1				; user mode
		ADDQ.L #6,SP
redir		CLR -(SP)
		TRAP #1

;-------------------------------------------------------------------------
; A few error handlers.

load_error	CMP.L #-33,error_no
		BNE.S .not_fnf
		PEA filenf_errortxt(PC)
		BRA.S .cont
.not_fnf	PEA load_errortxt(PC)
.cont		MOVE.W #9,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		MOVE.W #7,-(SP)
		TRAP #1
		ADDQ.L #2,SP
		BRA exitloaderr

; No FILENAME was passed error - so tell 'em how to install !!

mustinstall	DC.W $A00A
		PEA installtxt(PC)
		MOVE.W #9,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		MOVE.W #7,-(SP)
		TRAP #1
		ADDQ.L #2,SP
		DC.W $A009
		BRA.S redir

installtxt	DC.B 27,"E"
		DC.B "You must install this program as an",10,13
		DC.B "application on the Gem desktop,",10,13
		DC.B "OR Type the Module Name if you are",10,13
		DC.B "running this from a command line!",10,13
		DC.B "Press any key.",10,13,0

load_errortxt	DC.B 27,"E"
		DC.B "Load Error(disk error?)",10,13
		DC.B "Press any key.",10,13,0

filenf_errortxt	DC.B 27,"E"
		DC.B "File Not Found",10,13
		DC.B "Press any key.",10,13,0
	
;-------------------------------------------------------------------------
; Subroutines for interrupts and replay.

; Wait for a vbl..

Wait_Vbl	MOVE #37,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		RTS

oldsp		DS.L 1

; Load that Module

load_mod	BSR Wait_Vbl
		LEA loading(PC),A0		; file xxxxxx 
		BSR print			
.loadit		LEA filename(PC),A4
		LEA mt_data,A5
		MOVE.L #4000000,D7
		BSR Load_file			; load the file
		RTS

; Load a file of D7 bytes, Filename at A4 into address A5.

Load_file	SF.B errorflag			; assume no error!
		MOVE #2,-(SP)
		MOVE.L A4,-(SP)
		MOVE #$3D,-(SP)
		TRAP #1				; open da file
		ADDQ.L #8,SP
		TST.L D0
		BMI.S .error
		MOVE D0,D4
.read		MOVE.L A5,-(SP)
		MOVE.L D7,-(SP)
		MOVE D4,-(SP)
		MOVE #$3F,-(SP)
		TRAP #1				; read da file
		LEA 12(SP),SP
		TST.L D0
		BMI.S .error
		MOVE.L D0,modlength
.close		MOVE D4,-(SP)
		MOVE #$3E,-(SP)
		TRAP #1				; close da file!
		ADDQ.L #4,SP
		RTS
 
.error		MOVE.L D0,error_no
		ST.B errorflag			; shit a load error!
		RTS

;-------------------------------------------------------------------------
;-------------------------------------------------------------------------
; Various Decrunch routines.

; Power packer Decrunch
;-- a0 = Pointer to longword AFTER crunched file
;-- a3 = Pointer to destination
;-- a5 = Pointer to 'efficiency' longword, which is the second
;        longword in the crunched data file.

PP_Decrunch:	
ppdec		moveq #3,d6
		moveq #7,d7
		moveq #1,d5
		move.l a3,a2			; remember start of file
		move.l -(a0),d1			; get file length and empty bits
		tst.b d1
		beq.s NoEmptyBits
		bsr.s ReadBit			; this will always get the next long (D5 = 1)
		subq.b #1,d1
		lsr.l d1,d5			; get rid of empty bits
NoEmptyBits:	lsr.l #8,d1
		add.l d1,a3			; a3 = endfile
LoopCheckCrunch: 
		bsr.s ReadBit			; check if crunch or normal
		bcs.s CrunchedBytes
NormalBytes:	moveq #0,d2
Read2BitsRow:	moveq #1,d0
		bsr.s ReadD1
		add.w d1,d2
		cmp.w d6,d1
		beq.s Read2BitsRow
ReadNormalByte:	moveq #7,d0
		bsr.s ReadD1
		move.b d1,-(a3)
		dbf d2,ReadNormalByte
		cmp.l a3,a2
		bcs.s CrunchedBytes
		rts
ReadBit:	lsr.l #1,d5			; this will also set X if d5 becomes zero
		beq.s GetNextLong
		rts
GetNextLong:	move.l -(a0),d5
		roxr.l #1,d5			; X-bit set by lsr above
		rts
ReadD1sub:	subq.w #1,d0
ReadD1:		moveq #0,d1
ReadBits:	lsr.l #1,d5			; this will also set X if d5 becomes zero
		beq.s GetNext
RotX:		roxl.l #1,d1
		dbf d0,ReadBits
		rts
GetNext:	move.l -(a0),d5
		roxr.l #1,d5			; X-bit set by lsr above
		bra.s RotX
CrunchedBytes:	moveq #1,d0
		bsr.s ReadD1			; read code
		moveq #0,d0
		move.b 0(a5,d1.w),d0		; get number of bits of offset
		move.w d1,d2			; d2 = code = length-2
		cmp.w d6,d2			; if d2 = 3 check offset bit and read length
		bne.s ReadOffset
		bsr.s ReadBit			; read offset bit (long/short)
		bcs.s LongBlockOffset
		moveq #7,d0
LongBlockOffset: bsr.s ReadD1sub
		move.w d1,d3			; d3 = offset
Read3BitsRow:	moveq #2,d0
		bsr.s ReadD1
		add.w d1,d2			; d2 = length-1
		cmp.w d7,d1			; cmp with #7
		beq.s Read3BitsRow
		bra.s DecrunchBlock
ReadOffset:	bsr.s ReadD1sub			; read offset
		move.w d1,d3			; d3 = offset
DecrunchBlock:	addq.w #1,d2
DecrunchBlockLoop:
		move.b 0(a3,d3.w),-(a3)
		dbf d2,DecrunchBlockLoop
EndOfLoop:	cmp.l a3,a2
		bcs.s LoopCheckCrunch
		rts

;-------------------------------------------------------------------------

; Print Main Screen

print_mainscr	BSR Wait_Vbl
		LEA thetext(PC),A0		; main text
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
		MOVE.W	module_type(PC),D0
		MOVE.L	modtype_str_ptrs(PC,D0*4),A0			
		BSR print			
print_togstatus	BSR print_interpol_txt
		BSR print_tempocon_txt
		MOVE.W #'A',-(SP)
		MOVE.W #3,-(SP)
		TRAP #1
		ADDQ.L #2,SP
		RTS

print_tempocon_txt
		LEA 	tempocontrl_txt(PC),A0
		BSR 	print
		MOVE.W 	tempo_flag(pc),d0
		BRA	print_on_off
print_interpol_txt
		LEA 	interpolate_txt(PC),A0
		BSR 	print
		
		MOVE.L interpolate_flag(pc),d0

print_on_off	LEA onoff_txt(PC,D0*4),A0
		BRA print
		
onoff_txt	DC.B 'Off',0
		DC.B 'On ',0

module_type	dc.w 0
modtype_str_ptrs
		DC.L module_type1
		DC.L module_type2
		DC.L module_type3
		DC.L module_type4

; Various variables.

OldTempo	dc.w 125
modlength	DC.L 0
mt_data_ptr	DC.L 0
error_no	DC.L 0
errorflag	DC.B 0
playingtxt	DC.B "Now Playing : "
realmodname	DS.B 24
unnamed_mod	DC.B "Unnamed Module!",0
loading		DC.B 27,"E","Loading : "
filename	DS.B 128
module_type_txt	DC.B $A,$D,"Module Type : ",0
module_type1	DC.B "Protracker 4 channel.",$a,$d,0
module_type2	DC.B "Protracker 6 channel.",$a,$d,0
module_type3	DC.B "Protracker 8 channel.",$a,$d,0
module_type4	DC.B "Scream Tracker X channel.",$a,$d,0
interpolate_txt	DC.B "Interpolation : ",0
tempocontrl_txt	DC.B "  Tempo Control : ",0
newline		dc.b $a,$d,0
		EVEN

		

thetext
 dc.b 27,"E"	
 dc.b "        ProTracker Replay      ",$a,$d
 dc.b "   - Falcon030 Version v1.5p - ",$a,$d
 dc.b "          Programmed by        ",$a,$d
 dc.b "    Griff of Electronic Images ",$a,$d
 dc.b " <I> toggles interpolation On/Off ",$a,$d
 dc.b " <T> toggles tempo control On/Off ",$a,$d,$a,$d
 dc.b 0
		EVEN

print_newline	LEA	newline(pc),a0

; Print Rout -> Text address in A0...  Uses TXPOS and TYPOS (.B)
; (not fast or anything but works nicely thank you!)

print:		pea (a0)
		move.w #9,-(sp)
		trap #1
		addq.l #6,sp
		rts


; The Player.

vces_8_flag	EQU 0
wait_flag	EQU 0			; wait for dsp to finish flag.
pre_div		EQU 1			; pre divider(frequency)
freq		EQU ((25175000)/(pre_div+1))/256
interpolate_flag	dc.l	1
tempo_flag		dc.w	1

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
		MOVE.B $fffffa17.W,(A0)+
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
		MOVE.B (a0)+,$fffffa17.W
		MOVE.B (a0)+,$fffffa19.W
		MOVE.B (a0)+,$fffffa1f.W
		MOVE.W (SP)+,SR
		RTS

Start_music	BSR dsp_boot
		move.b  #pre_div,$FFFF8935.w  ;49.2khz
                move.b  #2,$FFFF8937.w	;CODEC <- Multiplexor
                move.b  #3,$FFFF8938.w	;L+R <- Soundchip(NOT ADC!)
		MOVE.W SR,-(SP)
		MOVE.W #$2700,SR
.wait1		BTST.B #0,$FFFFA202.W
		BEQ.S .wait1
		MOVE.W $FFFFA206.W,D0		; get dummy
.wait2		BTST.B #1,$FFFFA202.W
		BEQ.S .wait2
		MOVE.L #freq,$FFFFA204.W	; send dsp frequency to play at.
                MOVE #%1000000110011001,$FFFF8930.w	; dma output 25mhz clock,no handshake
                MOVE #%1011100100011101,$FFFF8932.w	; dsp out -> dac
                MOVE #0,$FFFF8920.w 		; 16 bit stereo,50khz,play 1 track,dac to track 1
		BCLR #7,$FFFF8901.w  		; select playback register
		BSR Set_DMA
		BCLR #3,$fffffa17.W		; soft end of interrupt
		MOVE.B #0,$FFFFFA19.W
		MOVE.L #music_int,$134.W
		BSET.B #5,$FFFFFA07.W		;iera
		BSET.B #5,$FFFFFA13.W		;imra
		MOVE.B #1,$FFFFFA1F.W
		MOVE.B #8,$FFFFFA19.W
		MOVE.W (SP)+,SR
		MOVE.B #8,$FFFFFA19.W		;timer a event mode.
		MOVE #1024+3,$FFFF8900.W	; DMA ON,timer a int
		RTS

Stop_music	MOVE.W SR,-(SP)
		MOVE.W #$2700,SR
		MOVE.B #0,$FFFFFA19.W		; STOP INT
		MOVE.W #0,$FFFF8900.W		; STOP DMA
		BCLR.B #5,$FFFFFA07.W		; iera
		BCLR.B #5,$FFFFFA07.W		; iera
		MOVE.W (SP)+,SR
		RTS

; Music Interrupt

		RSRESET
sam_start	RS.L 1			; sample start
sam_length	RS.W 1			; sample length
sam_period	RS.W 1			; sample period(freq)
sam_vol		RS.W 1			; sample volume
sam_lpstart	RS.L 1			; sample loop start
sam_lplength	RS.W 1	 		; sample loop length
cur_start	RS.L 1
cur_end		RS.L 1
cur_lpstart	RS.L 1
cur_lpend	RS.L 1
cur_pos		RS.L 1
cur_lpflag	RS.B 1
cur_haslpflag	RS.B 1
sam_vcsize	RS.B 1			; structure size.

music_int	TAS.B player_sem
		BNE .out
		MOVE.W #$2500,SR
		BSR Set_DMA
		MOVE.B #$80+19,$FFFFA201.W		; host command 2
		MOVEM.L	A0-A6/D0-D7,-(A7)
.waitdspexcp	BTST #7,$FFFFA201.w
		BNE.S .waitdspexcp		
		;MOVE.L $FFFF9800.W,-(SP)
		;MOVE.L #$F7000000,$FFFF9800.W
		;NOT.W $FFFF8240.W
;.wait		move.b	$FFFFA202.w,d0
;		and.b	#$18,d0
;		cmp.b	#$18,d0
;		bne.s	.wait
		LEA $FFFFA207.W,A6		; point to lsbyte
.wait		BTST.B #1,-5(A6)
		BEQ.S .wait
		MOVE.L interpolate_flag(pc),$FFFFA204.W	; signal dsp to go!
.wait8		BTST.B #1,-5(A6)
		BEQ.S .wait8
		MOVE.L #vces_8_flag,$FFFFA204.W

		LEA ch1s(PC),A1
		BSR setup_paula
		LEA ch2s(PC),A1
		BSR setup_paula
		LEA ch3s(PC),A1
		BSR setup_paula
		LEA ch4s(PC),A1
		BSR setup_paula

		IFNE vces_8_flag
		LEA ch5s(PC),A1
		BSR setup_paula
		LEA ch6s(PC),A1
		BSR setup_paula
		LEA ch7s(PC),A1
		BSR setup_paula
		LEA ch8s(PC),A1
		BSR setup_paula
		ENDC

		MOVEQ #0,D7
		LEA ch1s(PC),A1
		MOVEQ #0,D6
		BSR send_voice
		LEA ch2s(PC),A1
		MOVEQ #1,D6
		BSR send_voice
		LEA ch3s(PC),A1
		MOVEQ #2,D6
		BSR send_voice
		LEA ch4s(PC),A1
		MOVEQ #3,D6
		BSR send_voice

		IFNE vces_8_flag
		LEA ch5s(PC),A1
		MOVEQ #4,D6
		BSR send_voice
		LEA ch6s(PC),A1
		MOVEQ #5,D6
		BSR send_voice
		LEA ch7s(PC),A1
		MOVEQ #6,D6
		BSR send_voice
		LEA ch8s(PC),A1
		MOVEQ #7,D6
		BSR send_voice
		ENDC


.wait1		BTST #1,$FFFFA202.W		 
		BEQ.S .wait1
		MOVE.L #wait_flag,$FFFFA204.W
		IFNE wait_flag
.wait2		BTST #0,$FFFFA202.W		 
		BEQ.S .wait2
		TST.W $FFFFA206.W		
		ENDC
		BSR mt_music
		;NOT.W $FFFF8240.W
		;MOVE.L (SP)+,$FFFF9800.W
		MOVEM.L	(A7)+,A0-A6/D0-D7
		;BCLR.B #5,$FFFFFA0F.W
		SF player_sem
.out		RTE

setup_paula	MOVE.L sam_start(A1),D2
		BEQ.S .nosetnewmains
		MOVE.L D2,cur_start(A1)
		MOVE.L D2,cur_lpstart(A1)
		MOVE.L D2,cur_pos(A1)
		MOVE.L #0,sam_start(A1)
		SF cur_lpflag(A1)
.nosetnewmains	MOVEQ #0,D0
		MOVE.W sam_length(A1),D0
		BMI.S .nosetnewmainl
		MOVE.L cur_start(A1),D2
		ADD.L D0,D0
		ADD.L D0,D2
		MOVE.L D2,cur_end(A1)
		MOVE.L D2,cur_lpend(A1)
		MOVE.W #-1,sam_length(A1)
.nosetnewmainl	MOVE.L sam_lpstart(A1),D2
		BEQ.S .nosetnewloops
		MOVE.L D2,cur_lpstart(A1)
		MOVE.L #0,sam_lpstart(A1)
.nosetnewloops	MOVEQ #0,D0
		MOVE.W sam_lplength(A1),D0
		BMI.S .nosetnewloopl
		MOVE.L cur_lpstart(A1),D2
		ADD.L D0,D0
		ADD.L D0,D2
		MOVE.L D2,cur_lpend(A1)
		MOVE.W #-1,sam_lplength(A1)
.nosetnewloopl	RTS


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
.wait1		BTST #1,-5(A6)			;;;
		BEQ.S .wait1			; send 
		CLR.B -2(A6)			;   period
		MOVE.W sam_period(A1),-1(a6)	;;;
.wait2		BTST #0,-5(A6)			; 
		BEQ.S .wait2			; 
		MOVE.W -1(A6),D5		; get no. of samples
		BTST D6,shadow_dmacon+1		; voice dma on?
		BEQ dmaisoff			; no, then send zeros...
		MOVE.L cur_end(A1),A2
		MOVE.L cur_lpend(A1),A3
		MOVE.L cur_pos(A1),A0		; current voice address
		MOVE.L cur_start(A1),A4
		MOVE.L cur_lpstart(A1),A5
		MOVE.B cur_lpflag(A1),D3
		CLR.W -2(a6)			; clear top 16 msbits
do_vce		TST.B D3		; sample looping?
		BNE.S in_loop
in_main		CMP.L A4,A2		; sample start = sample end?
		BLE.S vce_isoffcont
		BRA.S vc_main_cont
in_loop		CMP.L A5,A3
		BLE.S vce_isoffcont
		BRA.S vclp_cont
vc_main_lp	MOVE.B (A0)+,(A6)
vc_main_cont	CMP.L A2,A0
		DBGE D5,vc_main_lp
		BLT.S vce_done
hit_looppoint	ST D3
		MOVE.L A5,A0
		CMP.L A5,A3
		BEQ.S vce_isoffcont
		BRA.S vclp_cont
vc_loop_lp	MOVE.B (A0)+,(A6)
vclp_cont	CMP.L A3,A0
		DBGE D5,vc_loop_lp
		BLT.S vce_done
vclp_resetlp	MOVE.L A5,A0
		DBF D5,vc_loop_lp
vce_done	MOVE.B (A0),(A6)
vce_done1	MOVE.B D3,cur_lpflag(A1)
		MOVE.L A0,cur_pos(A1)	; store new address
		RTS

dmaisoff	BRA.S vce_isoffcont
vce_isoff	
.wait		BTST.B #1,-5(A6)
		BEQ.S .wait
		MOVE.B D7,(A6)
vce_isoffcont	DBF D5,vce_isoff
.wait		BTST.B #1,-5(A6)
		BEQ.S .wait
		MOVE.B D7,(A6)
		BRA.S vce_done1

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

; Paula emulation storage structure.

ch1s		DS.B sam_vcsize
ch2s		DS.B sam_vcsize			; shadow channel regs
ch3s		DS.B sam_vcsize
ch4s		DS.B sam_vcsize
		IFNE vces_8_flag
ch5s		DS.B sam_vcsize
ch6s		DS.B sam_vcsize			; shadow channel regs
ch7s		DS.B sam_vcsize
ch8s		DS.B sam_vcsize
		ENDC

shadow_dmacon	DS.W 1
shadow_filter	DS.W 1
player_sem	DC.W 0

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

; ----- Protracker V2.1A Playroutine ----- 

; Changes from V1.0C playroutine:
; - Vibrato depth changed to be compatible with Noisetracker 2.0.
;   You'll have to double all vib. depths on old PT modules.
; - Funk Repeat changed to Invert Loop.
; - Period set back earlier when stopping an effect.

n_note		EQU	0  ; W
n_cmd		EQU	2  ; W
n_cmdlo		EQU	3  ; B
n_start		EQU	4  ; L
n_length	EQU	8  ; W
n_loopstart	EQU	10 ; L
n_replen	EQU	14 ; W
n_period	EQU	16 ; W
n_finetune	EQU	18 ; B
n_volume	EQU	19 ; B
n_dmabit	EQU	20 ; W
n_toneportdirec	EQU	22 ; B
n_toneportspeed	EQU	23 ; B
n_wantedperiod	EQU	24 ; W
n_vibratocmd	EQU	26 ; B
n_vibratopos	EQU	27 ; B
n_tremolocmd	EQU	28 ; B
n_tremolopos	EQU	29 ; B
n_wavecontrol	EQU	30 ; B
n_glissfunk	EQU	31 ; B
n_sampleoffset	EQU	32 ; B
n_pattpos	EQU	33 ; B
n_loopcount	EQU	34 ; B
n_funkoffset	EQU	35 ; B
n_wavestart	EQU	36 ; L
n_reallength	EQU	40 ; W

mt_init	
	move.l 	mt_data_ptr,a0
	MOVE.L	a0,mt_SongDataPtr
	MOVE.L	A0,A1
	LEA	952(A1),A1
	MOVEQ	#127,D0
	MOVEQ	#0,D1
mtloop	MOVE.L	D1,D2
	SUBQ.W	#1,D0
mtloop2	MOVE.B	(A1)+,D1
	CMP.B	D2,D1
	BGT.S	mtloop
	DBRA	D0,mtloop2
	ADDQ.B	#1,D2
	LEA	mt_SampleStarts(PC),A1
	ASL.L	#8,D2
	ASL.L	#2+vces_8_flag,D2
	ADD.L	#1084,D2
	ADD.L	A0,D2
	MOVE.L	D2,A2
	MOVEQ	#30,D0
mtloop3	CLR.L	(A2)
	MOVE.L	A2,(A1)+
	MOVEQ	#0,D1
	MOVE.W	42(A0),D1
	ASL.L	#1,D1
	ADD.L	D1,A2
	ADD.L	#30,A0
	DBRA	D0,mtloop3
	MOVE.B	#6,mt_speed
	CLR.B	mt_counter
	CLR.B	mt_SongPos
	CLR.W	mt_PatternPos
	ST	mt_Enable
	CLR.W 	shadow_dmacon
	RTS

mt_end	SF	mt_Enable
	CLR.W 	shadow_dmacon
	RTS

mt_music
	TST.B	mt_Enable
	BEQ	mt_exit
	ADDQ.B	#1,mt_counter
	MOVE.B	mt_counter(PC),D0
	CMP.B	mt_speed(PC),D0
	BLO.S	mt_NoNewNote
	CLR.B	mt_counter
	TST.B	mt_PattDelTime2
	BEQ.S	mt_GetNewNote
	BSR.S	mt_NoNewAllChannels
	BRA	mt_dskip

mt_NoNewNote
	BSR.S	mt_NoNewAllChannels
	BRA	mt_NoNewPosYet

mt_NoNewAllChannels
	LEA	ch1s(PC),A5
	LEA	mt_chan1temp(PC),A6
	BSR	mt_CheckEfx
	LEA	ch2s(PC),A5
	LEA	mt_chan2temp(PC),A6
	BSR	mt_CheckEfx
	LEA	ch3s(PC),A5
	LEA	mt_chan3temp(PC),A6
	BSR	mt_CheckEfx
	LEA	ch4s(PC),A5
	LEA	mt_chan4temp(PC),A6
	BSR	mt_CheckEfx

	IFNE vces_8_flag
	LEA	ch5s(PC),A5
	LEA	mt_chan5temp(PC),A6
	BSR	mt_CheckEfx
	LEA	ch6s(PC),A5
	LEA	mt_chan6temp(PC),A6
	BSR	mt_CheckEfx
	LEA	ch7s(PC),A5
	LEA	mt_chan7temp(PC),A6
	BSR	mt_CheckEfx
	LEA	ch8s(PC),A5
	LEA	mt_chan8temp(PC),A6
	BSR	mt_CheckEfx
	ENDC

	RTS

mt_GetNewNote
	MOVE.L	mt_SongDataPtr(PC),A0
	LEA	12(A0),A3
	LEA	952(A0),A2	;pattpo
	LEA	1084(A0),A0	;patterndata
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.B	mt_SongPos(PC),D0
	MOVE.B	(A2,D0.W),D1
	ASL.L	#8,D1
	ASL.L	#2+vces_8_flag,D1
	SUB.L 	A5,A5
	MOVE.W	mt_PatternPos(PC),A5
	ADD.L	A5,D1
	CLR.W	mt_DMACONtemp

	LEA	ch1s(PC),A5
	LEA	mt_chan1temp(PC),A6
	BSR.S	mt_PlayVoice
	LEA	ch2s(PC),A5
	LEA	mt_chan2temp(PC),A6
	BSR.S	mt_PlayVoice
	LEA	ch3s(PC),A5
	LEA	mt_chan3temp(PC),A6
	BSR.S	mt_PlayVoice
	LEA	ch4s(PC),A5
	LEA	mt_chan4temp(PC),A6
	BSR.S	mt_PlayVoice

	IFNE vces_8_flag
	LEA	ch5s(PC),A5
	LEA	mt_chan5temp(PC),A6
	BSR.S	mt_PlayVoice
	LEA	ch6s(PC),A5
	LEA	mt_chan6temp(PC),A6
	BSR.S	mt_PlayVoice
	LEA	ch7s(PC),A5
	LEA	mt_chan7temp(PC),A6
	BSR.S	mt_PlayVoice
	LEA	ch8s(PC),A5
	LEA	mt_chan8temp(PC),A6
	BSR.S	mt_PlayVoice
	endc

	BRA	mt_SetDMA

mt_PlayVoice
	TST.L	(A6)
	BNE.S	mt_plvskip
	BSR	mt_PerNop
mt_plvskip
	MOVE.L	(A0,D1.L),(A6)
	ADDQ.L	#4,D1
	MOVEQ	#0,D2
	MOVE.B	n_cmd(A6),D2
	AND.B	#$F0,D2
	LSR.B	#4,D2
	MOVE.B	(A6),D0
	AND.B	#$F0,D0
	OR.B	D0,D2
	TST.B	D2
	BEQ	mt_SetRegs
	MOVEQ	#0,D3
	LEA	mt_SampleStarts(PC),A1
	MOVE	D2,D4
	SUBQ.L	#1,D2
	ASL.L	#2,D2
	MULU	#30,D4
	MOVE.L	(A1,D2.L),n_start(A6)
	MOVE.W	(A3,D4.L),n_length(A6)
	MOVE.W	(A3,D4.L),n_reallength(A6)
	MOVE.B	2(A3,D4.L),n_finetune(A6)
	MOVE.B	3(A3,D4.L),n_volume(A6)
	MOVE.W	4(A3,D4.L),D3 ; Get repeat
	TST.W	D3
	BEQ.S	mt_NoLoop
	MOVE.L	n_start(A6),D2	; Get start
	ASL.W	#1,D3
	ADD.L	D3,D2		; Add repeat
	MOVE.L	D2,n_loopstart(A6)
	MOVE.L	D2,n_wavestart(A6)
	MOVE.W	4(A3,D4.L),D0	; Get repeat
	ADD.W	6(A3,D4.L),D0	; Add replen
	MOVE.W	D0,n_length(A6)
	MOVE.W	6(A3,D4.L),n_replen(A6)	; Save replen
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,sam_vol(A5)	; Set volume
	BRA.S	mt_SetRegs

mt_NoLoop
	MOVE.L	n_start(A6),D2
	ADD.L	D3,D2
	MOVE.L	D2,n_loopstart(A6)
	MOVE.L	D2,n_wavestart(A6)
	MOVE.W	6(A3,D4.L),n_replen(A6)	; Save replen
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,sam_vol(A5)	; Set volume
mt_SetRegs
	MOVE.W	(A6),D0
	AND.W	#$0FFF,D0
	BEQ	mt_CheckMoreEfx	; If no note
	MOVE.W	2(A6),D0
	AND.W	#$0FF0,D0
	CMP.W	#$0E50,D0
	BEQ.S	mt_DoSetFineTune
	MOVE.B	2(A6),D0
	AND.B	#$0F,D0
	CMP.B	#3,D0	; TonePortamento
	BEQ.S	mt_ChkTonePorta
	CMP.B	#5,D0
	BEQ.S	mt_ChkTonePorta
	CMP.B	#9,D0	; Sample Offset
	BNE.S	mt_SetPeriod
	BSR	mt_CheckMoreEfx
	BRA.S	mt_SetPeriod

mt_DoSetFineTune
	BSR	mt_SetFineTune
	BRA.S	mt_SetPeriod

mt_ChkTonePorta
	BSR	mt_SetTonePorta
	BRA	mt_CheckMoreEfx

mt_SetPeriod
	MOVEM.L	D0-D1/A0-A1,-(SP)
	MOVE.W	(A6),D1
	AND.W	#$0FFF,D1
	LEA	mt_PeriodTable(PC),A1
	MOVEQ	#0,D0
	MOVEQ	#36,D2
mt_ftuloop
	CMP.W	(A1,D0.W),D1
	BHS.S	mt_ftufound
	ADDQ.L	#2,D0
	DBRA	D2,mt_ftuloop
mt_ftufound
	MOVEQ	#0,D1
	MOVE.B	n_finetune(A6),D1
	MULU	#36*2,D1
	ADD.L	D1,A1
	MOVE.W	(A1,D0.W),n_period(A6)
	MOVEM.L	(SP)+,D0-D1/A0-A1

	MOVE.W	2(A6),D0
	AND.W	#$0FF0,D0
	CMP.W	#$0ED0,D0 ; Notedelay
	BEQ	mt_CheckMoreEfx

	move_dmacon n_dmabit(A6)
	BTST	#2,n_wavecontrol(A6)
	BNE.S	mt_vibnoc
	CLR.B	n_vibratopos(A6)
mt_vibnoc
	BTST	#6,n_wavecontrol(A6)
	BNE.S	mt_trenoc
	CLR.B	n_tremolopos(A6)
mt_trenoc
	MOVE.L	n_start(A6),sam_start(A5)	; Set start
	MOVE.W	n_length(A6),sam_length(A5)	; Set length

	MOVE.W	n_period(A6),D0
	MOVE.W	D0,sam_period(A5)		; Set period
	MOVE.W	n_dmabit(A6),D0
	OR.W	D0,mt_DMACONtemp
	BRA	mt_CheckMoreEfx
 
mt_SetDMA
	MOVE.W	mt_DMACONtemp(PC),D0
	OR.W	#$8000,D0
	move_dmacon d0

	IFNE vces_8_flag
	LEA ch8s(PC),A5
	LEA mt_chan8temp(PC),A6
	MOVE.L n_loopstart(A6),sam_lpstart(A5)
	MOVE.W	n_replen(A6),sam_lplength(A5)

	LEA ch7s(PC),A5
	LEA mt_chan7temp(PC),A6
	MOVE.L n_loopstart(A6),sam_lpstart(A5)
	MOVE.W	n_replen(A6),sam_lplength(A5)

	LEA ch6s(PC),A5
	LEA mt_chan6temp(PC),A6
	MOVE.L n_loopstart(A6),sam_lpstart(A5)
	MOVE.W	n_replen(A6),sam_lplength(A5)

	LEA ch5s(PC),A5
	LEA mt_chan5temp(PC),A6
	MOVE.L n_loopstart(A6),sam_lpstart(A5)
	MOVE.W	n_replen(A6),sam_lplength(A5)
	ENDC

	LEA ch4s(PC),A5
	LEA mt_chan4temp(PC),A6
	MOVE.L n_loopstart(A6),sam_lpstart(A5)
	MOVE.W	n_replen(A6),sam_lplength(A5)

	LEA ch3s(PC),A5
	LEA mt_chan3temp(PC),A6
	MOVE.L n_loopstart(A6),sam_lpstart(A5)
	MOVE.W	n_replen(A6),sam_lplength(A5)

	LEA ch2s(PC),A5
	LEA mt_chan2temp(PC),A6
	MOVE.L n_loopstart(A6),sam_lpstart(A5)
	MOVE.W	n_replen(A6),sam_lplength(A5)

	LEA ch1s(PC),A5
	LEA mt_chan1temp(PC),A6
	MOVE.L n_loopstart(A6),sam_lpstart(A5)
	MOVE.W	n_replen(A6),sam_lplength(A5)

mt_dskip
	ADD.W	#16*(vces_8_flag+1),mt_PatternPos
	MOVE.B	mt_PattDelTime,D0
	BEQ.S	mt_dskc
	MOVE.B	D0,mt_PattDelTime2
	CLR.B	mt_PattDelTime
mt_dskc	TST.B	mt_PattDelTime2
	BEQ.S	mt_dska
	SUBQ.B	#1,mt_PattDelTime2
	BEQ.S	mt_dska
	SUB.W	#16*(vces_8_flag+1),mt_PatternPos
mt_dska	TST.B	mt_PBreakFlag
	BEQ.S	mt_nnpysk
	SF	mt_PBreakFlag
	MOVEQ	#0,D0
	MOVE.B	mt_PBreakPos(PC),D0
	CLR.B	mt_PBreakPos
	LSL.W	#4+vces_8_flag,D0
	MOVE.W	D0,mt_PatternPos
mt_nnpysk
	CMP.W	#1024*(vces_8_flag+1),mt_PatternPos
	BLO.S	mt_NoNewPosYet
mt_NextPosition	
	MOVEQ	#0,D0
	MOVE.B	mt_PBreakPos(PC),D0
	LSL.W	#4,D0
	MOVE.W	D0,mt_PatternPos
	CLR.B	mt_PBreakPos
	CLR.B	mt_PosJumpFlag
	ADDQ.B	#1,mt_SongPos
	AND.B	#$7F,mt_SongPos
	MOVE.B	mt_SongPos(PC),D1
	MOVE.L	mt_SongDataPtr(PC),A0
	CMP.B	950(A0),D1
	BLO.S	mt_NoNewPosYet
	CLR.B	mt_SongPos
mt_NoNewPosYet	
	TST.B	mt_PosJumpFlag
	BNE.S	mt_NextPosition
mt_exit	
	RTS

mt_CheckEfx
	BSR	mt_UpdateFunk
	MOVE.W	n_cmd(A6),D0
	AND.W	#$0FFF,D0
	BEQ.S	mt_PerNop
	MOVE.B	n_cmd(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_Arpeggio
	CMP.B	#1,D0
	BEQ	mt_PortaUp
	CMP.B	#2,D0
	BEQ	mt_PortaDown
	CMP.B	#3,D0
	BEQ	mt_TonePortamento
	CMP.B	#4,D0
	BEQ	mt_Vibrato
	CMP.B	#5,D0
	BEQ	mt_TonePlusVolSlide
	CMP.B	#6,D0
	BEQ	mt_VibratoPlusVolSlide
	CMP.B	#$E,D0
	BEQ	mt_E_Commands
SetBack	MOVE.W	n_period(A6),sam_period(A5)
	CMP.B	#7,D0
	BEQ	mt_Tremolo
	CMP.B	#$A,D0
	BEQ	mt_VolumeSlide
mt_Return
	RTS

mt_PerNop
	MOVE.W	n_period(A6),sam_period(A5)
	RTS

mt_Arpeggio
	MOVEQ	#0,D0
	MOVE.B	mt_counter(PC),D0
	DIVS	#3,D0
	SWAP	D0
	CMP.W	#0,D0
	BEQ.S	mt_Arpeggio2
	CMP.W	#2,D0
	BEQ.S	mt_Arpeggio1
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	LSR.B	#4,D0
	BRA.S	mt_Arpeggio3

mt_Arpeggio1
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#15,D0
	BRA.S	mt_Arpeggio3

mt_Arpeggio2
	MOVE.W	n_period(A6),D2
	BRA.S	mt_Arpeggio4

mt_Arpeggio3
	ASL.W	#1,D0
	MOVEQ	#0,D1
	MOVE.B	n_finetune(A6),D1
	MULU	#36*2,D1
	LEA	mt_PeriodTable(PC),A0
	ADD.L	D1,A0
	MOVEQ	#0,D1
	MOVE.W	n_period(A6),D1
	MOVEQ	#36,D3
mt_arploop
	MOVE.W	(A0,D0.W),D2
	CMP.W	(A0),D1
	BHS.S	mt_Arpeggio4
	ADDQ.L	#2,A0
	DBRA	D3,mt_arploop
	RTS

mt_Arpeggio4
	MOVE.W	D2,sam_period(A5)
	RTS

mt_FinePortaUp
	TST.B	mt_counter
	BNE.S	mt_Return
	MOVE.B	#$0F,mt_LowMask
mt_PortaUp
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	mt_LowMask(PC),D0
	MOVE.B	#$FF,mt_LowMask
	SUB.W	D0,n_period(A6)
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	CMP.W	#113,D0
	BPL.S	mt_PortaUskip
	AND.W	#$F000,n_period(A6)
	OR.W	#113,n_period(A6)
mt_PortaUskip
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	MOVE.W	D0,sam_period(A5)
	RTS	
 
mt_FinePortaDown
	TST.B	mt_counter
	BNE	mt_Return
	MOVE.B	#$0F,mt_LowMask
mt_PortaDown
	CLR.W	D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	mt_LowMask(PC),D0
	MOVE.B	#$FF,mt_LowMask
	ADD.W	D0,n_period(A6)
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	CMP.W	#856,D0
	BMI.S	mt_PortaDskip
	AND.W	#$F000,n_period(A6)
	OR.W	#856,n_period(A6)
mt_PortaDskip
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	MOVE.W	D0,sam_period(A5)
	RTS

mt_SetTonePorta
	MOVE.L	A0,-(SP)
	MOVE.W	(A6),D2
	AND.W	#$0FFF,D2
	MOVEQ	#0,D0
	MOVE.B	n_finetune(A6),D0
	MULU	#37*2,D0
	LEA	mt_PeriodTable(PC),A0
	ADD.L	D0,A0
	MOVEQ	#0,D0
mt_StpLoop
	CMP.W	(A0,D0.W),D2
	BHS.S	mt_StpFound
	ADDQ.W	#2,D0
	CMP.W	#37*2,D0
	BLO.S	mt_StpLoop
	MOVEQ	#35*2,D0
mt_StpFound
	MOVE.B	n_finetune(A6),D2
	AND.B	#8,D2
	BEQ.S	mt_StpGoss
	TST.W	D0
	BEQ.S	mt_StpGoss
	SUBQ.W	#2,D0
mt_StpGoss
	MOVE.W	(A0,D0.W),D2
	MOVE.L	(SP)+,A0
	MOVE.W	D2,n_wantedperiod(A6)
	MOVE.W	n_period(A6),D0
	CLR.B	n_toneportdirec(A6)
	CMP.W	D0,D2
	BEQ.S	mt_ClearTonePorta
	BGE	mt_Return
	MOVE.B	#1,n_toneportdirec(A6)
	RTS

mt_ClearTonePorta
	CLR.W	n_wantedperiod(A6)
	RTS

mt_TonePortamento
	MOVE.B	n_cmdlo(A6),D0
	BEQ.S	mt_TonePortNoChange
	MOVE.B	D0,n_toneportspeed(A6)
	CLR.B	n_cmdlo(A6)
mt_TonePortNoChange
	TST.W	n_wantedperiod(A6)
	BEQ	mt_Return
	MOVEQ	#0,D0
	MOVE.B	n_toneportspeed(A6),D0
	TST.B	n_toneportdirec(A6)
	BNE.S	mt_TonePortaUp
mt_TonePortaDown
	ADD.W	D0,n_period(A6)
	MOVE.W	n_wantedperiod(A6),D0
	CMP.W	n_period(A6),D0
	BGT.S	mt_TonePortaSetPer
	MOVE.W	n_wantedperiod(A6),n_period(A6)
	CLR.W	n_wantedperiod(A6)
	BRA.S	mt_TonePortaSetPer

mt_TonePortaUp
	SUB.W	D0,n_period(A6)
	MOVE.W	n_wantedperiod(A6),D0
	CMP.W	n_period(A6),D0
	BLT.S	mt_TonePortaSetPer
	MOVE.W	n_wantedperiod(A6),n_period(A6)
	CLR.W	n_wantedperiod(A6)

mt_TonePortaSetPer
	MOVE.W	n_period(A6),D2
	MOVE.B	n_glissfunk(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_GlissSkip
	MOVEQ	#0,D0
	MOVE.B	n_finetune(A6),D0
	MULU	#36*2,D0
	LEA	mt_PeriodTable(PC),A0
	ADD.L	D0,A0
	MOVEQ	#0,D0
mt_GlissLoop
	CMP.W	(A0,D0.W),D2
	BHS.S	mt_GlissFound
	ADDQ.W	#2,D0
	CMP.W	#36*2,D0
	BLO.S	mt_GlissLoop
	MOVEQ	#35*2,D0
mt_GlissFound
	MOVE.W	(A0,D0.W),D2
mt_GlissSkip
	MOVE.W	D2,sam_period(A5) ; Set period
	RTS

mt_Vibrato
	MOVE.B	n_cmdlo(A6),D0
	BEQ.S	mt_Vibrato2
	MOVE.B	n_vibratocmd(A6),D2
	AND.B	#$0F,D0
	BEQ.S	mt_vibskip
	AND.B	#$F0,D2
	OR.B	D0,D2
mt_vibskip
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F0,D0
	BEQ.S	mt_vibskip2
	AND.B	#$0F,D2
	OR.B	D0,D2
mt_vibskip2
	MOVE.B	D2,n_vibratocmd(A6)
mt_Vibrato2
	MOVE.B	n_vibratopos(A6),D0
	LEA	mt_VibratoTable(PC),A4
	LSR.W	#2,D0
	AND.W	#$001F,D0
	MOVEQ	#0,D2
	MOVE.B	n_wavecontrol(A6),D2
	AND.B	#$03,D2
	BEQ.S	mt_vib_sine
	LSL.B	#3,D0
	CMP.B	#1,D2
	BEQ.S	mt_vib_rampdown
	MOVE.B	#255,D2
	BRA.S	mt_vib_set
mt_vib_rampdown
	TST.B	n_vibratopos(A6)
	BPL.S	mt_vib_rampdown2
	MOVE.B	#255,D2
	SUB.B	D0,D2
	BRA.S	mt_vib_set
mt_vib_rampdown2
	MOVE.B	D0,D2
	BRA.S	mt_vib_set
mt_vib_sine
	MOVE.B	(A4,D0.W),D2
mt_vib_set
	MOVE.B	n_vibratocmd(A6),D0
	AND.W	#15,D0
	MULU	D0,D2
	LSR.W	#7,D2
	MOVE.W	n_period(A6),D0
	TST.B	n_vibratopos(A6)
	BMI.S	mt_VibratoNeg
	ADD.W	D2,D0
	BRA.S	mt_Vibrato3
mt_VibratoNeg
	SUB.W	D2,D0
mt_Vibrato3
	MOVE.W	D0,sam_period(A5)
	MOVE.B	n_vibratocmd(A6),D0
	LSR.W	#2,D0
	AND.W	#$003C,D0
	ADD.B	D0,n_vibratopos(A6)
	RTS

mt_TonePlusVolSlide
	BSR	mt_TonePortNoChange
	BRA	mt_VolumeSlide

mt_VibratoPlusVolSlide
	BSR.S	mt_Vibrato2
	BRA	mt_VolumeSlide

mt_Tremolo
	MOVE.B	n_cmdlo(A6),D0
	BEQ.S	mt_Tremolo2
	MOVE.B	n_tremolocmd(A6),D2
	AND.B	#$0F,D0
	BEQ.S	mt_treskip
	AND.B	#$F0,D2
	OR.B	D0,D2
mt_treskip
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F0,D0
	BEQ.S	mt_treskip2
	AND.B	#$0F,D2
	OR.B	D0,D2
mt_treskip2
	MOVE.B	D2,n_tremolocmd(A6)
mt_Tremolo2
	MOVE.B	n_tremolopos(A6),D0
	LEA	mt_VibratoTable(PC),A4
	LSR.W	#2,D0
	AND.W	#$001F,D0
	MOVEQ	#0,D2
	MOVE.B	n_wavecontrol(A6),D2
	LSR.B	#4,D2
	AND.B	#$03,D2
	BEQ.S	mt_tre_sine
	LSL.B	#3,D0
	CMP.B	#1,D2
	BEQ.S	mt_tre_rampdown
	MOVE.B	#255,D2
	BRA.S	mt_tre_set
mt_tre_rampdown
	TST.B	n_vibratopos(A6)
	BPL.S	mt_tre_rampdown2
	MOVE.B	#255,D2
	SUB.B	D0,D2
	BRA.S	mt_tre_set
mt_tre_rampdown2
	MOVE.B	D0,D2
	BRA.S	mt_tre_set
mt_tre_sine
	MOVE.B	(A4,D0.W),D2
mt_tre_set
	MOVE.B	n_tremolocmd(A6),D0
	AND.W	#15,D0
	MULU	D0,D2
	LSR.W	#6,D2
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	TST.B	n_tremolopos(A6)
	BMI.S	mt_TremoloNeg
	ADD.W	D2,D0
	BRA.S	mt_Tremolo3
mt_TremoloNeg
	SUB.W	D2,D0
mt_Tremolo3
	BPL.S	mt_TremoloSkip
	CLR.W	D0
mt_TremoloSkip
	CMP.W	#$40,D0
	BLS.S	mt_TremoloOk
	MOVE.W	#$40,D0
mt_TremoloOk
	MOVE.W	D0,sam_vol(A5)
	MOVE.B	n_tremolocmd(A6),D0
	LSR.W	#2,D0
	AND.W	#$003C,D0
	ADD.B	D0,n_tremolopos(A6)
	RTS

mt_SampleOffset
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	BEQ.S	mt_sononew
	MOVE.B	D0,n_sampleoffset(A6)
mt_sononew
	MOVE.B	n_sampleoffset(A6),D0
	LSL.W	#7,D0
	CMP.W	n_length(A6),D0
	BGE.S	mt_sofskip
	SUB.W	D0,n_length(A6)
	LSL.W	#1,D0
	ADD.L	D0,n_start(A6)
	RTS
mt_sofskip
	MOVE.W	#$0001,n_length(A6)
	RTS

mt_VolumeSlide
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	LSR.B	#4,D0
	TST.B	D0
	BEQ.S	mt_VolSlideDown
mt_VolSlideUp
	ADD.B	D0,n_volume(A6)
	CMP.B	#$40,n_volume(A6)
	BMI.S	mt_vsuskip
	MOVE.B	#$40,n_volume(A6)
mt_vsuskip
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,sam_vol(A5)
	RTS

mt_VolSlideDown
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
mt_VolSlideDown2
	SUB.B	D0,n_volume(A6)
	BPL.S	mt_vsdskip
	CLR.B	n_volume(A6)
mt_vsdskip
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,sam_vol(A5)
	RTS

mt_PositionJump
	MOVE.B	n_cmdlo(A6),D0
	SUBQ.B	#1,D0
	MOVE.B	D0,mt_SongPos
mt_pj2	CLR.B	mt_PBreakPos
	ST 	mt_PosJumpFlag
	RTS

mt_VolumeChange
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	CMP.B	#$40,D0
	BLS.S	mt_VolumeOk
	MOVEQ	#$40,D0
mt_VolumeOk
	MOVE.B	D0,n_volume(A6)
	MOVE.W	D0,sam_vol(A5)
	RTS

mt_PatternBreak
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	MOVE.L	D0,D2
	LSR.B	#4,D0
	MULU	#10,D0
	AND.B	#$0F,D2
	ADD.B	D2,D0
	CMP.B	#63,D0
	BHI.S	mt_pj2
	MOVE.B	D0,mt_PBreakPos
	ST	mt_PosJumpFlag
	RTS

mt_SetSpeed
	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	BEQ	mt_end

	TST.W	tempo_flag
	BEQ.S	.miss
	CMP.B	#32,D0			; yes then d0>=32
	BHS	SetTempo		; then Set Tempo
.miss
	CLR.B	mt_counter
	MOVE.B	D0,mt_speed
	RTS

SetTempo
	CMP.W	#32,D0
	BHS.S	setemsk
	MOVEQ	#32,D0
setemsk	MOVE.W	D0,RealTempo		; set tempo speed
	RTS
RealTempo	
	DC.W 125

mt_CheckMoreEfx
	BSR	mt_UpdateFunk
	MOVE.B	2(A6),D0
	AND.B	#$0F,D0
	CMP.B	#$9,D0
	BEQ	mt_SampleOffset
	CMP.B	#$B,D0
	BEQ	mt_PositionJump
	CMP.B	#$D,D0
	BEQ	mt_PatternBreak
	CMP.B	#$E,D0
	BEQ.S	mt_E_Commands
	CMP.B	#$F,D0
	BEQ	mt_SetSpeed
	CMP.B	#$C,D0
	BEQ	mt_VolumeChange
	BRA	mt_PerNop

mt_E_Commands
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F0,D0
	LSR.B	#4,D0
	BEQ.S	mt_FilterOnOff
	CMP.B	#1,D0
	BEQ	mt_FinePortaUp
	CMP.B	#2,D0
	BEQ	mt_FinePortaDown
	CMP.B	#3,D0
	BEQ.S	mt_SetGlissControl
	CMP.B	#4,D0
	BEQ	mt_SetVibratoControl
	CMP.B	#5,D0
	BEQ	mt_SetFineTune
	CMP.B	#6,D0
	BEQ	mt_JumpLoop
	CMP.B	#7,D0
	BEQ	mt_SetTremoloControl
	CMP.B	#9,D0
	BEQ	mt_RetrigNote
	CMP.B	#$A,D0
	BEQ	mt_VolumeFineUp
	CMP.B	#$B,D0
	BEQ	mt_VolumeFineDown
	CMP.B	#$C,D0
	BEQ	mt_NoteCut
	CMP.B	#$D,D0
	BEQ	mt_NoteDelay
	CMP.B	#$E,D0
	BEQ	mt_PatternDelay
	CMP.B	#$F,D0
	BEQ	mt_FunkIt
	RTS

mt_FilterOnOff
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#1,D0
	ASL.B	#1,D0
;	AND.B	#$FD,$BFE001		; filter!
;	OR.B	D0,$BFE001		; hehe
	RTS	

mt_SetGlissControl
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	AND.B	#$F0,n_glissfunk(A6)
	OR.B	D0,n_glissfunk(A6)
	RTS

mt_SetVibratoControl
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	AND.B	#$F0,n_wavecontrol(A6)
	OR.B	D0,n_wavecontrol(A6)
	RTS

mt_SetFineTune
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	MOVE.B	D0,n_finetune(A6)
	RTS

mt_JumpLoop
	TST.B	mt_counter
	BNE	mt_Return
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_SetLoop
	TST.B	n_loopcount(A6)
	BEQ.S	mt_jumpcnt
	SUBQ.B	#1,n_loopcount(A6)
	BEQ	mt_Return
mt_jmploop	MOVE.B	n_pattpos(A6),mt_PBreakPos
	ST	mt_PBreakFlag
	RTS

mt_jumpcnt
	MOVE.B	D0,n_loopcount(A6)
	BRA.S	mt_jmploop

mt_SetLoop
	MOVE.W	mt_PatternPos(PC),D0
	LSR.W	#4,D0
	MOVE.B	D0,n_pattpos(A6)
	RTS

mt_SetTremoloControl
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	LSL.B	#4,D0
	AND.B	#$0F,n_wavecontrol(A6)
	OR.B	D0,n_wavecontrol(A6)
	RTS

mt_RetrigNote
	MOVE.L	D1,-(SP)
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BEQ	mt_rtnend
	MOVEQ	#0,D1
	MOVE.B	mt_counter(PC),D1
	BNE.S	mt_rtnskp
	MOVE.W	(A6),D1
	AND.W	#$0FFF,D1
	BNE	mt_rtnend
	MOVEQ	#0,D1
	MOVE.B	mt_counter(PC),D1
mt_rtnskp
	DIVU	D0,D1
	SWAP	D1
	TST.W	D1
	BNE.S	mt_rtnend
mt_DoRetrig
	;move_dmacon n_dmabit(A6)	; Channel DMA off
	MOVE.L	n_start(A6),sam_start(A5) ; Set sampledata pointer
	MOVE.W	n_length(A6),sam_length(A5)	; Set length
	MOVE.W	n_dmabit(A6),D0
	BSET	#15,D0
	move_dmacon d0
	MOVE.L	n_loopstart(A6),sam_lpstart(A5)
	MOVE.W	n_replen(A6),sam_lplength(A5)
	MOVE.W	n_replen+2(A6),sam_period(A5)
mt_rtnend:
	MOVE.L	(SP)+,D1
	RTS

mt_VolumeFineUp
	TST.B	mt_counter
	BNE	mt_Return
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F,D0
	BRA	mt_VolSlideUp

mt_VolumeFineDown
	TST.B	mt_counter
	BNE	mt_Return
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BRA	mt_VolSlideDown2

mt_NoteCut
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	CMP.B	mt_counter(PC),D0
	BNE	mt_Return
	CLR.B	n_volume(A6)
	MOVE.W	#0,sam_vol(A5)
	RTS

mt_NoteDelay
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	CMP.B	mt_Counter,D0
	BNE	mt_Return
	MOVE.W	(A6),D0
	BEQ	mt_Return
	MOVE.L	D1,-(SP)
	BRA	mt_DoRetrig

mt_PatternDelay
	TST.B	mt_counter
	BNE	mt_Return
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	TST.B	mt_PattDelTime2
	BNE	mt_Return
	ADDQ.B	#1,D0
	MOVE.B	D0,mt_PattDelTime
	RTS

mt_FunkIt
	TST.B	mt_counter
	BNE	mt_Return
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	LSL.B	#4,D0
	AND.B	#$0F,n_glissfunk(A6)
	OR.B	D0,n_glissfunk(A6)
	TST.B	D0
	BEQ	mt_Return
mt_UpdateFunk
	MOVEM.L	A0/D1,-(SP)
	MOVEQ	#0,D0
	MOVE.B	n_glissfunk(A6),D0
	LSR.B	#4,D0
	BEQ.S	mt_funkend
	LEA	mt_FunkTable(PC),A0
	MOVE.B	(A0,D0.W),D0
	ADD.B	D0,n_funkoffset(A6)
	BTST	#7,n_funkoffset(A6)
	BEQ.S	mt_funkend
	CLR.B	n_funkoffset(A6)

	MOVE.L	n_loopstart(A6),D0
	MOVEQ	#0,D1
	MOVE.W	n_replen(A6),D1
	ADD.L	D1,D0
	ADD.L	D1,D0
	MOVE.L	n_wavestart(A6),A0
	ADDQ.L	#1,A0
	CMP.L	D0,A0
	BLO.S	mt_funkok
	MOVE.L	n_loopstart(A6),A0
mt_funkok
	MOVE.L	A0,n_wavestart(A6)
	MOVEQ	#-1,D0
	SUB.B	(A0),D0
	MOVE.B	D0,(A0)
mt_funkend
	MOVEM.L	(SP)+,A0/D1
	RTS


mt_FunkTable dc.b 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128

mt_VibratoTable	
	dc.b   0, 24, 49, 74, 97,120,141,161
	dc.b 180,197,212,224,235,244,250,253
	dc.b 255,253,250,244,235,224,212,197
	dc.b 180,161,141,120, 97, 74, 49, 24

mt_PeriodTable
; Tuning 0, Normal
	dc.w	856,808,762,720,678,640,604,570,538,508,480,453
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113
; Tuning 1
	dc.w	850,802,757,715,674,637,601,567,535,505,477,450
	dc.w	425,401,379,357,337,318,300,284,268,253,239,225
	dc.w	213,201,189,179,169,159,150,142,134,126,119,113
; Tuning 2
	dc.w	844,796,752,709,670,632,597,563,532,502,474,447
	dc.w	422,398,376,355,335,316,298,282,266,251,237,224
	dc.w	211,199,188,177,167,158,149,141,133,125,118,112
; Tuning 3
	dc.w	838,791,746,704,665,628,592,559,528,498,470,444
	dc.w	419,395,373,352,332,314,296,280,264,249,235,222
	dc.w	209,198,187,176,166,157,148,140,132,125,118,111
; Tuning 4
	dc.w	832,785,741,699,660,623,588,555,524,495,467,441
	dc.w	416,392,370,350,330,312,294,278,262,247,233,220
	dc.w	208,196,185,175,165,156,147,139,131,124,117,110
; Tuning 5
	dc.w	826,779,736,694,655,619,584,551,520,491,463,437
	dc.w	413,390,368,347,328,309,292,276,260,245,232,219
	dc.w	206,195,184,174,164,155,146,138,130,123,116,109
; Tuning 6
	dc.w	820,774,730,689,651,614,580,547,516,487,460,434
	dc.w	410,387,365,345,325,307,290,274,258,244,230,217
	dc.w	205,193,183,172,163,154,145,137,129,122,115,109
; Tuning 7
	dc.w	814,768,725,684,646,610,575,543,513,484,457,431
	dc.w	407,384,363,342,323,305,288,272,256,242,228,216
	dc.w	204,192,181,171,161,152,144,136,128,121,114,108
; Tuning -8
	dc.w	907,856,808,762,720,678,640,604,570,538,508,480
	dc.w	453,428,404,381,360,339,320,302,285,269,254,240
	dc.w	226,214,202,190,180,170,160,151,143,135,127,120
; Tuning -7
	dc.w	900,850,802,757,715,675,636,601,567,535,505,477
	dc.w	450,425,401,379,357,337,318,300,284,268,253,238
	dc.w	225,212,200,189,179,169,159,150,142,134,126,119
; Tuning -6
	dc.w	894,844,796,752,709,670,632,597,563,532,502,474
	dc.w	447,422,398,376,355,335,316,298,282,266,251,237
	dc.w	223,211,199,188,177,167,158,149,141,133,125,118
; Tuning -5
	dc.w	887,838,791,746,704,665,628,592,559,528,498,470
	dc.w	444,419,395,373,352,332,314,296,280,264,249,235
	dc.w	222,209,198,187,176,166,157,148,140,132,125,118
; Tuning -4
	dc.w	881,832,785,741,699,660,623,588,555,524,494,467
	dc.w	441,416,392,370,350,330,312,294,278,262,247,233
	dc.w	220,208,196,185,175,165,156,147,139,131,123,117
; Tuning -3
	dc.w	875,826,779,736,694,655,619,584,551,520,491,463
	dc.w	437,413,390,368,347,328,309,292,276,260,245,232
	dc.w	219,206,195,184,174,164,155,146,138,130,123,116
; Tuning -2
	dc.w	868,820,774,730,689,651,614,580,547,516,487,460
	dc.w	434,410,387,365,345,325,307,290,274,258,244,230
	dc.w	217,205,193,183,172,163,154,145,137,129,122,115
; Tuning -1
	dc.w	862,814,768,725,684,646,610,575,543,513,484,457
	dc.w	431,407,384,363,342,323,305,288,272,256,242,228
	dc.w	216,203,192,181,171,161,152,144,136,128,121,114

mt_chan1temp	dc.l	0,0,0,0,0,$00010000,0,  0,0,0,0
mt_chan2temp	dc.l	0,0,0,0,0,$00020000,0,  0,0,0,0
mt_chan3temp	dc.l	0,0,0,0,0,$00040000,0,  0,0,0,0
mt_chan4temp	dc.l	0,0,0,0,0,$00080000,0,  0,0,0,0
		IFNE vces_8_flag
mt_chan5temp	dc.l	0,0,0,0,0,$00100000,0,  0,0,0,0
mt_chan6temp	dc.l	0,0,0,0,0,$00200000,0,  0,0,0,0
mt_chan7temp	dc.l	0,0,0,0,0,$00400000,0,  0,0,0,0
mt_chan8temp	dc.l	0,0,0,0,0,$00800000,0,  0,0,0,0
		ENDC
mt_SampleStarts	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

mt_SongDataPtr	dc.l 0
mt_speed	dc.b 6
mt_counter	dc.b 0
mt_SongPos	dc.b 0
mt_PBreakPos	dc.b 0
mt_PosJumpFlag	dc.b 0
mt_PBreakFlag	dc.b 0
mt_LowMask	dc.b 0
mt_PattDelTime	dc.b 0
mt_PattDelTime2	dc.b 0
mt_Enable	dc.b 0
mt_PatternPos	dc.w 0
mt_DMACONtemp	dc.w 0

; Reset DSP, and load boot.

dsp_boot	move	sr,-(a7)
		move.w	#$2700,sr
		move.b	#$E,$FFFF8800.w
		move.b	$FFFF8800.w,d0
		or.b	#$10,d0
		move.b	d0,$FFFF8802.w
		rept 8
		nop
		endr
		and.b	#$EF,d0
		move.b	d0,$FFFF8802.w
		move.w	(a7)+,sr
		LEA DspProg(PC),A0
		move.w #512-1,d0
.lp		move.b (a0)+,$FFFFA205.w
		move.w (a0)+,$FFFFA206.w
		dbf d0,.lp
		move.b	#0,$FFFFA200.w
		rts

; Dsp Code

DspProg		incbin d:\coding.s\dsppaula\dspaula.bin
DspProgEnd	DS.B (3*512)-(*-DspProg)
		EVEN

old_stuff	DS.L 10
dummy		


		IFNE test
testfile	DC.B (endtestfilename-testfilename)
testfilename	DC.B "d:\mods\axelf.MOD"
endtestfilename
		ENDC
		even

		SECTION BSS

		DS.L 399
my_stack	DS.L 3
mt_data		DS.B 180000		; module is loaded here.
		EVEN
