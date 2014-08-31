;-----------------------------------------------------------------------------
;File name:	TRACKER.ASM			Revision date:	1998.02.05
;Revised by:	Ulf Ronald Andersson		Revision start:	1997.02.19
;-----------------------------------------------------------------------------
	NOLIST
	PAGE	132,72,2,2,2
;-----------------------------------------------------------------------------
;	Verification codes for various DSP/APP interactions
;
Tk_Init_delay	equ	$1000	;Maximum loop count waiting for Init
Tk_Track_delay	equ	$1000	;Maximum loop count waiting for Tracking
Tk_Zap_delay	equ	$1000	;Maximum loop count waiting for Zap
;
;	codes used without host command prefix
;
Tk_Init_s_c	equ	'TkI'	;Initialization code from app to dsp
Tk_Error_s_c	equ	'TkE'	;Error code from dsp at wrong commands
Tk_Busy_s_c	equ	'TkB'	;from dsp when interrupted before ready
Tk_Ready_s_c	equ	'TkR'	;from dsp when ready after sending Busy
;
;
;	codes used with host_0 command prefix (Soundtracker refill)
;
Tk_Track_s_c	equ	'TkT'	;Track code	;APP->DSP at track work start
;
;
;	codes used with host_1 command prefix (General commands)
;
Tk_Zap_s_c	equ	'TkZ'	;deactivation (Zap) code
;
;-----------------------------------------------------------------------------
;
SamBuf_SIZE	equ	4096	;NB: 1 per X/Y space
SamBuf_MASK	equ	4096
;
VoiceBuf_SIZE	equ	1500	;4 per X/Y space
TempHead_SIZE	equ	3	;3 words header used before 3byte smaple packets
;
;-----------------------------------------------------------------------------
;
all_8		equ	$ff
all_16		equ	$ffff
all_24		equ	$ffffff
;
mr_imask	equ	all_8-3
;
f_Zap_cmd	equ	0
f_tracking	equ	1
f_Track_cmd	equ	2
;
;-----------------------------------------------------------------------------
;
PBC		equ	$ffe0	; Port B Control Register
PCC		equ	$ffe1	; Port C Control register
HCR		equ	$ffe8	; Host Control Register
HSR		equ	$ffe9	; Host Status Register
HRX		equ	$ffeb	; Host Receive Register
HTX		equ	$ffeb	; Host Transmit Register
CRA		equ	$ffec	; SSI Control Register A
CRB		equ	$ffed	; SSI Control Register B
SSISR		equ	$ffee	; SSI Status Register
TX		equ	$ffef	; SSI Serial Transmit data/shift register
BCR		equ	$fffe	; Port A Bus Control Register
IPR		equ	$ffff	; Interrupt Priority Register
;
;	Host Control Register Bit Flags
;
HCIE		equ	2				; Host Command Interrupt Enable
;
;	Host Status Register Bit Flags
;
HRDF		equ	0				; Host Receive Data Full
HTDE		equ	1				; Host Transmit Data Empty
;
;-----------------------------------------------------------------------------
;
tx_APP	MACRO	data
_tx_APP
	jclr	#<HTDE,X:<<HSR,_tx_APP 	;await Tx permission
	movep	data,X:<<HTX			;Tx(APP) = data
	ENDM	;tx_APP
;
rx_APP	MACRO	dest
_rx_APP
	jclr	#<HRDF,X:<<HSR,_rx_APP		;await Rx completion
	movep	X:<<HRX,dest			;dest  = Rx(APP)
	ENDM	;rx_APP
;
rx_CODE	MACRO	timeout,expected
	move	timeout,a1
	move	expected,x1
	jsr	receive_code
	ENDM	;rx_CODE
;
protect	MACRO
	move	a0,X:<saved_a0
	move	a1,X:<saved_a1
	move	a2,X:<saved_a2
	move	x1,X:<saved_x1
	ENDM	;protect
;
restore	MACRO
	move	X:<saved_x1,x1
	move	X:<saved_a2,a2
	move	X:<saved_a1,a1
	move	X:<saved_a0,a0
	ENDM	;restore
;
;-----------------------------------------------------------------------------
;	System vectors used:
;
	org	p:$0
	jmp	>Start
;
	org	p:$10
Tx_vector:
	jsr	>Sample_Out
;
	org	p:$26
host_0_vector:
	jsr	>Soundtrack_Rout
;
	org	p:$28
host_1_vector:
	jsr	>Command_Rout
;
;-----------------------------------------------------------------------------
; Interrupt Routine that plays the sound with the SSI
;
	org	p:$40
;
Sample_Out:
	jset	#<2,X:<<SSISR,Right_Out	;detect the odd/even transfers
Left_Out:
	movep	X:(r7),X:<<TX
	rti
;
Right_Out:
	movep	Y:(r7)+,X:<<TX
Simple_rti:
	rti
;
;-----------------------------------------------------------------------------
; It Begins here :
;
Start:
	movec	#0,sp			;reset stack pointer
	movec	sr,X:entry_sr		;save sr
	ori	#<3,mr			;disable interrupts
	movep	X:<<IPR,X:entry_IPR	;save IPR
	movep	X:<<HCR,X:entry_HCR	;save HCR
;
	movec	#SamBuf_SIZE-1,m7	;r7 modulo = SamBuf_SIZE
	movec	#-1,m0			;r0 modulo = OFF
	move	#SampleBuffer,r7
;
	clr	b
	rep	m0
	move	b,L:(r7)+
;
	move	b,L:(r7)+
;
	movep	#1,X:<<PBC		; Port B in Host
	movep	#$1f8,X:<<PCC		; Port C in SSI
	movep	#$4100,X:<<CRA		; 1 voice 16 bits Stereo
	movep	#$5800,X:<<CRB		; enable X-mit IT
	movep	#$3800,X:<<IPR		; SSI at IPL 3 and Host at IPL 2
;
	bset	#<HCIE,X:<<HCR		; enable Host Command ITs
;
	move	#<1,n0			;r0 increment = 1
	movec	m0,m1			;r1 modulo = OFF
	move	#<1,n1			;r1 increment = 1
	movec	m0,m2			;r2 modulo = OFF
	movec	m0,m3			;r3 modulo = OFF
	movec	m0,m4			;r4 modulo = OFF
	move	#>VoiceBuf_SIZE,n4	;r4 increment = VoiceBuf_SIZE
	movec	m0,m5			;r5 modulo = OFF
	move	#>VoiceBuf_SIZE,n5	;r5 increment = VoiceBuf_SIZE
	movec	m7,m6			;r6 modulo = SamBuf_SIZE
;
	andi	#<mr_imask,mr		; Enable interrupts (IPL0)
;
; Verify the connection with the 030
;
init_verify_loop:
	rx_CODE	#>Tk_Init_delay,#>Tk_Init_s_c	;await Init code
	cmp	x1,a				;did it come in ?
	jne	<init_verify_loop		;if not, wait some more ;-)
;
ready_loop:
	bclr	#<f_Track_cmd,X:<main_flags
main_loop:
	jset	#<f_Zap_cmd,X:<main_flags,Zap_action
	jset	#<f_Track_cmd,X:<main_flags,Track_action
	jmp	<main_loop
;
Zap_action:
	ori	#<3,mr			;disable interrupts
	movep	X:entry_HCR,X:<<HCR	;restore HCR
	movep	X:entry_IPR,X:<<IPR	;restore IPR
	movec	X:entry_sr,sr		;restore sr
zapped_loop:
	jmp	<zapped_loop
;
Track_action:
	jsr	<sound_track_sub
	tx_APP	#Tk_Ready_s_c
	jmp	<ready_loop
;
;-----------------------------------------------------------------------------
; Turn-off Routine in Host 1 Command
;
Command_Rout:
	protect
	rx_CODE	#>Tk_Zap_delay,#>Tk_Zap_s_c	;await Zap confirmation
	cmp	x1,a				;was Zap confirmed ?
	jne	<done_commands			;if not, forget it  ;-)
	bset	#<f_Zap_cmd,X:<main_flags	;else set Zap flag
done_commands:
	restore
	rti					;return from interrupt
;
;-----------------------------------------------------------------------------
; Sound-Tracker Routine in Host 0 Command
;
Soundtrack_Rout:
	protect
	jset	#<f_Track_cmd,X:<main_flags,tracking_busy
	rx_CODE	#>Tk_Track_delay,#>Tk_Track_s_c	;Get command verification from APP
	cmp	x1,a				;Was this a tracker command ?
	jne	<done_commands			;ignore unknown commands since Tk_Error already sent
	bset	#<f_Track_cmd,X:<main_flags	;set Track command flag
	jmp	<done_commands
;
tracking_busy:
	rx_CODE	#>Tk_Track_delay,#<0		;Get command verification from APP
	move	#>Tk_Track_s_c,x1
	cmp	x1,a				;Was this a tracker command ?
	jne	<done_error			;send Tk_Error for unknown commands here
	tx_APP	#Tk_Busy_s_c			;tell APP to "lay off, we're busy!"
	jmp	<done_commands
;
done_error:
	tx_APP	#Tk_Error_s_c			;tell APP we got an erroneous command
	jmp	<done_commands
;
;-----------------------------------------------------------------------------
; Sound-Tracker subroutine
;
sound_track_sub:
	clr	a	X:<frame_end,x0		;a  = 0,  x0 = frame_end
	move	r7,a1				;a  = new_pos
	sub	x0,a	x0,X:<frame_base	;a  = new_pos-frame_end,  frame_base = frame_end
	jge	<positive			;go keep diff unless negative
	move	#>SamBuf_SIZE,x0		;x0 = SamBuf_SIZE
	add	x0,a				;correct diff modulo SamBuf_SIZE
positive:
	bset	#f_tracking,X:<main_flags
	jne	not_first_track_call
	clr	a
not_first_track_call:			;Place any stuff unique to first call above this line
	tx_APP	a1			;Tx(APP) = frame room
	rx_APP	a			;a  = Rx(APP), frame size
	move	a1,X:<frame_size
	tst	a
	jne	Trackit_now
	rts
;
Trackit_now:
	move	X:<frame_base,r6
	move	a1,n6
	nop
	lua	(r6)+n6,r6
	nop
	move	r6,X:<frame_end
	rx_APP	a			;a  = Rx(APP), (voices-2)/2
	move	a1,X:voicepairs_added	;voicepairs_added = a1
	move	#>1,x0			;x0 = $000001
	add	x0,a			;a  = voices/2
	move	a1,X:voicepairs_total	;voicepairs_total = a1
;
	move	#TempBuffers,r5
	DO	X:<voicepairs_total,Receive_Voices_end	;Loop start to receive all voice pairs
;-----     -----     -----     -----     -----     -----     -----     -----
;Routine to receive voice data from APP for an L-R voice pair
;This will be stored in non-final (triple-byte) form in TempBuffers
;It is done to minimize host CPU time costs (at expense of DSP work)
;
;NB: The TempBuffer areas use no separate storage !!!
;    They overlap the end of each VoiceBuffer...
;
;
Receive_Voice_Pair:
	move	r5,r0				;restart r0 pointer
Receive_Voice_Left:
	rx_APP	X:(r0)+				;X:(r0)+ = Rx(APP),  voice volume
	rx_APP	x0				;x0 = Rx(APP),  freq_ratio
	move	X:<frame_size,y0		;y0 = frame_size
	mpy	x0,y0,a		x0,X:(r0)+	;a = freq_ratio * frame_size, X:(r0)+ = freq_ratio
	tx_APP	a1				;Tx(APP) = freq_ratio * frame_size
	rx_APP	b				;b = 6-byte pkt count
	lsl	b				;b = 3-byte pkt count
	move	b1,X:(r0)+			;store pkt count
;
	DO	b1,Receive_Left_Loop		;Loop start for b1 packets
	rx_APP	X:(r0)+				;X:(r0)+ = Rx(APP),  3-byte packet
Receive_Left_Loop:				;Loop back for more packets
;
	move	r5,r0				;restart r0 pointer
Receive_Voice_Right:
	rx_APP	Y:(r0)+				;Y:(r0)+ = Rx(APP),  voice volume
	rx_APP	x0				;x0 = Rx(APP),  freq_ratio
	move	X:<frame_size,y0		;y0 = frame_size
	mpy	x0,y0,a		x0,Y:(r0)+	;a = freq_ratio * frame_size, Y:(r0)+ = freq_ratio
	tx_APP	a1				;Tx(APP) = period * frame_size
	rx_APP	b				;b = number of 6-byte packets
	lsl	b				;b = number of 3-byte packets
	move	b1,Y:(r0)+			;store pkt count
;
	DO	b1,Receive_Right_Loop		;Loop start for b1 packets
	rx_APP	Y:(r0)+				;Y:(r0)+ = Rx(APP),  3-byte packet
Receive_Right_Loop:				;Loop back for b1 packets
;-----     -----     -----     -----     -----     -----     -----     -----
	lua	(r5)+n5,r5
Receive_Voices_end:			;Loop back to receive all voice pairs
;
	move	#VoiceBuffers,r4
	move	#TempBuffers,r5
	DO	X:<voicepairs_total,patch_voices_end
;-----     -----     -----     -----     -----     -----     -----     -----
;Routine to patch voice data from TempBuffers to VoiceBuffers
;
Patch_Voice_Pair:
	move	#$FF,x1				;x1 = const $FF0000 for truncation
	move	#>$008000,y1			;y1 = const 1/2^8 for mpy shifting
	move	r5,r1				;restart TempBuffer pointer
	move	r4,r0				;restart Voice pointer
Patch_Voice_Left:
	move	X:(r1)+,y0			;y0 = voice volume
	move	X:(r1)+,x0			;x0 = voice frequency
	move	x0,X:(r0)+			;store voice frequency
	lua	(r0)+,r0			;pass voice time fraction
	move	X:(r1)+,x0			;x0 = count for 3-byte packets
;
	DO	x0,Patch_Left_Loop	;Loop start for 3-byte packets
	move	X:(r1)+,x0			;x0 = 3-byte packet
	mpy	x0,y1,a		x0,b		;a1 = pkt>>8,  a0 = byte_3<<16,  b = pkt
	and	x1,b		a1,x0		;b1 = byte_1<<16,  x0 = pkt>>8
	mpy	x0,y1,b		b1,x0		;b0 = byte_2<<16,  x0 = byte_1<<16
	mpy	y0,x0,b		b0,x0		;b  = sample_1,  x0 = byte_2<<16
	mpy	y0,x0,a		a0,x0		;a  = sample_2,  x0 = byte_3<<16
	mpy	y0,x0,b		b,X:(r0)+	;b  = sample_3,  X:(r0)+ = sample_1
	move	a,X:(r0)+			;X:(r0)+ = sample_2
	move	b,X:(r0)+			;X:(r0)+ = sample_3
Patch_Left_Loop:				;Loop back for more packets
;
	move	r5,r1				;restart TempBuffer pointer
	move	r4,r0				;restart Voice pointer
Patch_Voice_Right:
	move	Y:(r1)+,y0			;y0 = voice volume
	move	Y:(r1)+,x0			;x0 = voice frequency
	move	x0,Y:(r0)+			;store voice frequency
	lua	(r0)+,r0			;pass voice time fraction
	move	Y:(r1)+,x0			;x0 = count for 3-byte packets
;
	DO	x0,Patch_Right_Loop	;Loop start for 3-byte packets
	move	Y:(r1)+,x0			;x0 = 3-byte packet
	mpy	x0,y1,a		x0,b		;a1 = pkt>>8,  a0 = byte_3<<16,  b = pkt
	and	x1,b		a1,x0		;b1 = byte_1<<16,  x0 = pkt>>8
	mpy	x0,y1,b		b1,x0		;b0 = byte_2<<16,  x0 = byte_1<<16
	mpy	y0,x0,b		b0,x0		;b  = sample_1,  x0 = byte_2<<16
	mpy	y0,x0,a		a0,x0		;a  = sample_2,  x0 = byte_3<<16
	mpy	y0,x0,b		b,Y:(r0)+	;b  = sample_3,  Y:(r0)+ = sample_1
	move	a,Y:(r0)+			;Y:(r0)+ = sample_2
	move	b,Y:(r0)+			;Y:(r0)+ = sample_3
Patch_Right_Loop:			;Loop back for b1 packets
;-----     -----     -----     -----     -----     -----     -----     -----
	lua	(r5)+n5,r5
	lua	(r4)+n4,r4
patch_voices_end:
;
	move	#VoiceBuffers,r4
	nop
;-----     -----     -----     -----     -----     -----     -----     -----
;Routine to calculate output sample data for the first L-R voice pair
;
CalcPair:
	move	r4,r0				;r0 -> Left voice data
CalcLeft:
	move	X:<frame_base,r6		;r6 -> mixed data destination
	lua	(r0)+,r1			;r1 -> frac,  r0 -> freq
	move	X:(r0)+,y1			;y1 =  freq,  r0 -> frac
	move	X:(r1)+,b			;b  =  fraction,  r1 -> old raw sample
;
	move	X:(r1)+,x0			;x0 = old raw voice sample
	move	X:(r1),a			;a = current raw voice sample
	sub	x0,a		b,x1		;a = sample diff,  x1 = frac
	move	a,y0				;y0 = sample diff
	mpy	y1,y0,a				;a  = diff * freq
	mpy	x1,y0,a		a,y0		;a  = diff * frac,  y0 = diff * freq
	add	x0,a				;a  = interpolated sample
;
	DO	X:<frame_size,Calc_L_end	;loop start
	add	y1,b				;L frac += L frequency
	jec	<Calc_L_pos			;keep voice pos unless b overflowed
	bclr	#23,b1				;remove overflow
	move	X:(r1)+,x0			;x0 = current raw voice sample
	move	X:(r1),a			;a = next raw voice sample
	sub	x0,a		b1,x1		;a = sample diff,  x1 = frac
	move	a,y0				;y0 = sample diff
	mpy	y1,y0,a				;a  = diff * freq
	mpy	x1,y0,a		a,y0		;a  = diff * frac,  y0 = diff * freq
	add	x0,a				;a  = interpolated sample
Calc_L_pos:
	move	a,X:(r6)+			;store mixed interpolated sample
	add	y0,a				;a = next sample interpolation
Calc_L_end:					;loop back
	move	b,X:(r0)+			;store remaining L frac
;
	move	r4,r0				;r0 -> Right voice data
CalcRight:
	move	X:<frame_base,r6		;r6 -> mixed data destination
	lua	(r0)+,r1			;r1 -> frac,  r0 -> freq
	move	Y:(r0)+,y1			;y1 =  freq,  r0 -> frac
	move	Y:(r1)+,b			;b  =  fraction,  r1 -> old raw sample
;
	move	Y:(r1)+,x0			;x0 = old raw voice sample
	move	Y:(r1),a			;a = current raw voice sample
	sub	x0,a		b,x1		;a = sample diff,  x1 = frac
	move	a,y0				;y0 = sample diff
	mpy	y1,y0,a				;a  = diff * freq
	mpy	x1,y0,a		a,y0		;a  = diff * frac,  y0 = diff * freq
	add	x0,a				;a  = interpolated sample
;
	DO	X:<frame_size,Calc_R_end	;loop start
	add	y1,b				;R frac += R frequency
	jec	<Calc_R_pos			;keep voice pos unless b overflowed
	bclr	#23,b1				;remove overflow
	move	Y:(r1)+,x0			;x0 = current raw voice sample
	move	Y:(r1),a			;a = next raw voice sample
	sub	x0,a		b1,x1		;a = sample diff,  x1 = frac
	move	a,y0				;y0 = sample diff
	mpy	y1,y0,a				;a  = diff * freq
	mpy	x1,y0,a		a,y0		;a  = diff * frac,  y0 = diff * freq
	add	x0,a				;a  = interpolated sample
Calc_R_pos:
	move	a,Y:(r6)+			;store mixed interpolated sample
	add	y0,a				;a = next sample interpolation
Calc_R_end:					;loop back
	move	b,Y:(r0)+			;store remaining R frac
;-----     -----     -----     -----     -----     -----     -----     -----
	lua	(r4)+n4,r4
;
	DO	X:<voicepairs_added,Mix_Voices_Sup
;-----     -----     -----     -----     -----     -----     -----     -----
;Routine to mix output sample data for any additional L-R voice pair
;
MixPair:
	move	r4,r0				;r0 -> Left voice data
MixLeft:
	move	X:<frame_base,r6		;r6 -> mixed data destination
	lua	(r0)+,r1			;r1 -> frac,  r0 -> freq
	move	X:(r0)+,y1			;y1 =  freq,  r0 -> frac
	move	X:(r1)+,b			;b  =  fraction,  r1 -> old raw sample
;
	move	X:(r1)+,x0			;x0 = old raw voice sample
	move	X:(r1),a			;a = current raw voice sample
	sub	x0,a		b,x1		;a = sample diff,  x1 = frac
	move	a,y0				;y0 = sample diff
	mpy	y1,y0,a				;a  = diff * freq
	mpy	x1,y0,a		a,y0		;a  = diff * frac,  y0 = diff * freq
	add	x0,a				;a  = interpolated sample
;
	DO	X:<frame_size,Mix_L_end	;loop start
	add	y1,b				;b += frequency
	jec	<keep_L_pos			;keep voice pos unless b overflowed
	bclr	#23,b1				;remove overflow
	move	X:(r1)+,x0			;x0 = current raw voice sample
	move	X:(r1),a			;a0 = next raw voice sample
	sub	x0,a		b1,x1		;a0 = sample diff,  x1 = frac
	move	a,y0				;y0 = sample diff
	mpy	y1,y0,a				;a  = diff * freq
	mpy	x1,y0,a		a,y0		;a  = diff * frac,  y0 = diff * freq
	add	x0,a				;a  = interpolated sample
keep_L_pos:
	move	X:(r6),x0			;x0 = old mix
	add	x0,a		a,x0		;a  = new mix,  x0 = interpolated sample
	move	a,X:(r6)+			;store new mix
	move	x0,a				;a = interpolated sample
	add	y0,a				;a = next sample interpolation
Mix_L_end:					;loop back
	move	b,X:(r0)+			;store remaining L frac
;
	move	r4,r0				;r0 -> Right voice data
MixRight:
	move	X:<frame_base,r6		;r6 -> mixed data destination
	lua	(r0)+,r1			;r1 -> frac,  r0 -> freq
	move	Y:(r0)+,y1			;y1 =  freq,  r0 -> frac
	move	Y:(r1)+,b			;b  =  fraction,  r1 -> old raw sample
;
	move	Y:(r1)+,x0			;x0 = old raw voice sample
	move	Y:(r1),a			;a0 = current raw voice sample
	sub	x0,a		b,x1		;a0 = sample diff,  x1 = frac
	move	a,y0				;y0 = sample diff
	mpy	y1,y0,a				;a  = diff * freq
	mpy	x1,y0,a		a,y0		;a  = diff * frac,  y0 = diff * freq
	add	x0,a				;a  = interpolated sample
;
	DO	X:<frame_size,Mix_R_end	;loop start
	add	y1,b				;b += frequency
	jec	<keep_R_pos			;keep voice pos unless b overflowed
	bclr	#23,b1				;remove overflow
	move	Y:(r1)+,x0			;x0 = current raw voice sample
	move	Y:(r1),a			;a0 = next raw voice sample
	sub	x0,a		b1,x1		;a0 = sample diff,  x1 = frac
	move	a,y0				;y0 = sample diff
	mpy	y1,y0,a				;a  = diff * freq
	mpy	x1,y0,a		a,y0		;a  = diff * frac,  y0 = diff * freq
	add	x0,a				;a  = interpolated sample
keep_R_pos:
	move	Y:(r6),x0			;x0 = old mix
	add	x0,a		a,x0		;a  = new mix,  x0 = interpolated sample
	move	a,Y:(r6)+			;store new mix
	move	x0,a				;a = interpolated sample
	add	y0,a				;a = next sample interpolation
Mix_R_end:					;loop back
	move	b,Y:(r0)+			;store remaining R frac
;-----     -----     -----     -----     -----     -----     -----     -----
	lua	(r4)+n4,r4
Mix_Voices_Sup:
;
;additional filters can be inserted here
;
	rts
;
;ends:	sound_track_sub
;-----------------------------------------------------------------------------
;entry:		x1 == expected command, or zero for general reception
;alters:	a
;result:	a1 = received command or $FFFFFF if none
;		If the command received matches non_zero x1, then the
;		command is echoed back to sender as receipt of transaction.
;		If it fails to match non_zero x1 it is an error, echoing
;		Tk_Error_s_c back to sender and returning $FFFFFF in a.
;
receive_code:
	DO	a1,receive_code_loop_end
	jclr	#<HRDF,X:<<HSR,wait_receive_rx
	clr	a
	cmp	x1,a
	jne	receive_code_test
	movep	X:<<HRX,a1
	jmp	done_receive_code
;
receive_code_test:
	movep	X:<<HRX,a1
	cmp	x1,a
	jne	reject_receive_code
	jclr	#<HTDE,X:<<HSR,reject_receive_code
	movep	a1,X:<<HTX
done_receive_code:
	enddo
	nop
	jmp	receive_code_loop_end
;
reject_receive_code:
	movep	#Tk_Error_s_c,X:<<HTX		;Send 'TkE' as Error code
	move	#>all_24,a			;flag failure
	jmp	done_receive_code
;
wait_receive_rx:
	move	#>all_24,a			;flag failure
	nop
receive_code_loop_end:
	nop
	nop
	rts
;
;ends:	receive_code
;-----------------------------------------------------------------------------
; Data Zone
;-----------------------------------------------------------------------------
		org	X:0
;
voicepairs_total:	DC	1
voicepairs_added:	DC	1
;
frame_size:		DS	1		;<= current r7 - frame_base
frame_base:		DC	SampleBuffer	;frame_end from older calculation
frame_end:		DC	SampleBuffer	;&frame_base[frame_size]
;
main_flags:		DC	0
;
entry_sr:		DC	1
entry_IPR:		DC	1
entry_HCR:		DC	1
;
saved_a2:		dc	1
saved_a1:		dc	1
saved_a0:		dc	1
saved_x1:		dc	1
;
;-----------------------------------------------------------------------------
		org	X:1*1500
;
VoiceBuffers:
VoiceBuf_L:	ds	4*VoiceBuf_SIZE	;
;
TempBuffers	equ	VoiceBuffers+VoiceBuf_SIZE-VoiceBuf_SIZE/3-TempHead_SIZE
;-----------------------------------------------------------------------------
		org	Y:1*1500
;
VoiceBuf_R:	ds	4*VoiceBuf_SIZE	;
;-----------------------------------------------------------------------------
		org	X:$2000	;must be multiple of SamBuf_MASK
;
SampleBuffer:
SamBuf_L:	ds	SamBuf_SIZE
;-----------------------------------------------------------------------------
		org	Y:$2000	;must be multiple of SamBuf_MASK
;
SamBuf_R:	ds	SamBuf_SIZE
;-----------------------------------------------------------------------------
;
			END
;
;-----------------------------------------------------------------------------
;End of file:	TRACKER.ASM
;-----------------------------------------------------------------------------
