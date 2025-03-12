;	MACROs pour la communication avec le DSP
;	ecris par G.Audoly
;	je ne prends aucunement la responsabilite de degats pouvant etre
;	causes par ces MACROs

Readyr:	MACRO
	btst.b	#0,$ffffa202.w
	ENDM

Readyr2:	MACRO
	btst.b	#0,$ffffa202.w
	beq.s	*-6
	ENDM

Readys:	MACRO
	btst.b	#1,$ffffa202.w
	ENDM

Readys2:	MACRO
	btst.b	#1,$ffffa202.w
	beq.s	*-6
	ENDM


Rel:	MACRO		;dest.L
	move.l	$ffffa204.w,\1
	rol.l	#8,\1
	slt.b	\1
	ror.l	#8,\1
	ENDM

Recl:	MACRO		;dest.L
	btst.b	#0,$ffffa202.w
	beq.s	*-6
	Rel	\1
	ENDM

Rel2:	MACRO		;dest.L
	move.l	$ffffa204.w,\1
	tst.b	\1+1
	slt.b	\1
	ENDM
	
Recl2:	MACRO		;dest.L
	btst.b	#0,$ffffa202.w
	beq.s	*-6
	Rel2	\1
	ENDM
	
Rel3:	MACRO		;dest.L
	move.l	$ffffa204.w,\1+
	tst.b	-3\1
	slt.b	-4\1
	ENDM
	
Recl3:	MACRO		;dest.L
	btst.b	#0,$ffffa202.w
	beq.s	*-6
	Rel3	\1
	ENDM
	
Rec:	MACRO		;dest.L
	btst.b	#0,$ffffa202.w
	beq.s	*-6
	move.l	$ffffa204.w,\1
	ENDM

Re:	MACRO		;dest.L
	move.l	$ffffa204.w,\1
	ENDM

Recw:	MACRO		;dest.L
	btst.b	#0,$ffffa202.w
	beq.s	*-6
	move.w	$ffffa206.w,\1
	ENDM

Rew:	MACRO		;dest.L
	move.w	$ffffa206.w,\1
	ENDM

Senw:	MACRO		;#val.L
	clr.w	$ffffa204.w
	move.w	\1,$ffffa206.w
	ENDM

Sendw:	MACRO		;#val.L
	btst.b	#1,$ffffa202.w
	beq.s	*-6
	Senw	\1
	ENDM

Senw0:	MACRO		;#val.L
	move.w	\1,$ffffa206.w
	ENDM

Sendw0:	MACRO		;#val.L
	btst.b	#1,$ffffa202.w
	beq.s	*-6
	Senw0	\1
	ENDM

Sen:	MACRO		;#val.L
	move.l	\1,$ffffa204.w
	ENDM

Send:	MACRO		;#val.L
	btst.b	#1,$ffffa202.w
	beq.s	*-6
	Sen	\1
	ENDM

senw:	MACRO		;#val.L,reg
	move.w	\1,\2
	ext.l	\2
	Sen	\2
	ENDM

sendw:	MACRO		;#val.L,reg
	btst.b	#1,$ffffa202.w
	beq.s	*-6
	senw	\1,\2
	ENDM

Dsp_DoBlock: MACRO		;#*data_in.L, #size_in, #*data_out, #size_out
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#$60,-(sp)
	trap	#14
	lea.l	18(sp),sp
	ENDM
	
Dsp_BlkHandShake: MACRO		;#*data_in.L, #size_in, #*data_out, #size_out
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#$61,-(sp)
	trap	#14
	lea.l	18(sp),sp
	ENDM
	
Dsp_BlkUnpacked: MACRO		;#*data_in.L, #size_in, #*data_out, #size_out
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#$62,-(sp)
	trap	#14
	lea.l	18(sp),sp
	ENDM
	
Dsp_BlkWords: MACRO		;#*data_in.L, #size_in, #*data_out, #size_out
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#$7b,-(sp)
	trap	#14
	lea.l	18(sp),sp
	ENDM
	
Dsp_BlkBytes: MACRO		;#*data_in.L, #size_in, #*data_out, #size_out
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#$7c,-(sp)
	trap	#14
	lea.l	18(sp),sp
	ENDM

Dsp_InStream: MACRO		;#*data_in.L, #bloc_size.L, #num_blocks, #*blocks_done
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#$63,-(sp)
	trap	#14
	lea.l	18(sp),sp
	ENDM

Dsp_OutStream: MACRO		;#*data_out.L, #bloc_size.L, #num_blocks, #*blocks_done
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#$64,-(sp)
	trap	#14
	lea.l	18(sp),sp
	ENDM

Dsp_RemoveInterrupts: MACRO	;#mask.W
	move.w	\1,-(sp)
	move.w	#$66,-(sp)
	trap	#14
	addq.l	#4,sp
	ENDM
	
Dsp_GetWordSize: MACRO
	move.w	#$67,-(sp)
	trap	#14
	addq.w	#2,sp
	ENDM		;size.W
	
Dsp_Lock:	MACRO
	move.w	#$68,-(sp)
	trap	#14
	addq.w	#2,sp
	ENDM		;state.W
	
Dsp_Unlock: MACRO
	move.w	#$69,-(sp)
	trap	#14
	addq.w	#2,sp
	ENDM		;state.W
	
Dsp_LoadProg: MACRO		;#*file.L,#ability.W,#*buffer.L
	move.l	\3,-(sp)
	move.w	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#$6c,-(sp)
	trap	#14
	lea.l	12(sp),sp
	ENDM		;status.W

Dsp_ExecProg: MACRO		;#*codeptr.L,#codesize.L,#ability.W
	move.w	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#$6d,-(sp)
	trap	#14
	lea.l	12(sp),sp
	ENDM		;(RIEN)

Dsp_ExecBoot: MACRO		;#*codeptr.L,#codesize.L,#ability.W
	move.w	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#$6e,-(sp)
	trap	#14
	lea.l	12(sp),sp
	ENDM		;(RIEN)

Dsp_LodToBinary: MACRO	;#file.L,#*codeptr.L
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#$6f,-(sp)
	trap	#14
	lea.l	10(sp),sp
	ENDM		;size.L


Dsp_RequestUniqueAbility: MACRO
	move.w	#$71,-(sp)
	trap	#14
	addq.w	#2,sp
	ENDM		;Ability.W

Dsp_GetProgAbility: MACRO
	move.w	#$72,-(sp)
	trap	#14
	addq.w	#2,sp
	ENDM		;Ability.W

Dsp_FlushSubroutines: MACRO
	move.w	#$73,-(sp)
	trap	#14
	addq.w	#2,sp
	ENDM

Dsp_LoadSubroutine: MACRO	;#*ptr.L, #size.L, #ability.W
	move.w	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#$74,-(sp)
	trap	#14
	lea.l	10(sp),sp
	ENDM		;handle.W

Dsp_InqSubrAbility: MACRO	;#ability.W
	move.w	\1,-(sp)
	move.w	#$75,-(sp)
	trap	#14
	addq.w	#4,sp
	ENDM		;handle.W

Dsp_RunSubroutine: MACRO	;#handle.W
	move.w	\1,-(sp)
	move.w	#$76,-(sp)
	trap	#14
	addq.w	#4,sp
	ENDM		;status.W
	
Dsp_Hf0:	MACRO		;#flag.W
	move.w	\1,-(sp)
	move.w	#$77,-(sp)
	trap	#14
	addq.w	#4,sp
	ENDM		;hf0_ret.W
	
Dsp_Hf1:	MACRO		;#flag.W
	move.w	\1,-(sp)
	move.w	#$78,-(sp)
	trap	#14
	addq.w	#4,sp
	ENDM		;hf1_ret.W
	
Dsp_Hf2:	MACRO		;#flag.W
	move.w	\1,-(sp)
	move.w	#$79,-(sp)
	trap	#14
	addq.w	#4,sp
	ENDM		;hf2_ret.W
	
Dsp_Hf3:	MACRO		;#flag.W
	move.w	\1,-(sp)
	move.w	#$7a,-(sp)
	trap	#14
	addq.w	#4,sp
	ENDM		;hf3_ret.W
	
Dsp_HStat:	MACRO
	move.w	#$7d,-(sp)
	trap	#14
	addq.w	#2,sp
	ENDM		;status.B
	
	