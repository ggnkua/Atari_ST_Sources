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

phen_twirl	INCBIN D:\HALLUCIN.DEM\PHN_CUBE\PH_twirl.dat
