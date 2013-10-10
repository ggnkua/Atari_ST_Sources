;=========================================================================;
;                            Real Stereo Machine !                        ;
;                    (C)oderight Nullos / DNT-Crew 1994                   ;
;======================================================= Version 1.0 =====;
;
;Transformation Mono Yamaha -> Enhanced Mono
;
	include	tos_030.s
	include	hard_sys.s

ReadHost	MACRO	dst
.\@	btst	#0,$ffffa202.w
	beq.s	.\@
	move.l	$ffffa204.w,\1
	ENDM
WritHost	MACRO	src
.\@	btst	#1,$ffffa202.w
	beq.s	.\@
	move.l	\1,$ffffa204.w
	ENDM

	StartUp	512
	clr.l	-(sp)
	Gemdos	Super
	move.l	d0,-(sp)

yo	move.w	#"RS",-(sp)	;Installe le programme DSP
	pea	stereosize/3.w	;
	pea	stereo(pc)		;
	Xbios	Dsp_ExecProg	;

	lea	PCM_base.w,a0	;
	move.b	#2,cdc_add(a0)	;ADDRin sur la matrice
	move.b	#$3,cdc_inp(a0)	;
	move.w	#$0000,pcm_ptrk(a0)	;piste 0 en 8 bits st‚r‚o
	move.w	#$0191,mpx_src(a0)	;Connexions de la matrice.
	move.w	#$23f3,mpx_dst(a0)	;
	move.w	#$0000,mpx_clk(a0)	;Diviseur STE
	ori.b	#$03,pcm_ctrl(a0)	;50Khz

	move.b	#$94,$ffffa201.w	;DSP en Enhanced Mono

	Gemdos	Super
	pea	message(pc)
	Gemdos	Cconws
	Gemdos	Pterm0

	section	data
stereo	incbin	stereo.p56
stereosize	equ	*-stereo

message	dc.b	$d,$a,"Enhanced Mono 1.0 : activated !",$d,$a,0
