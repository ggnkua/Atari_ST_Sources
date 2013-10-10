;=========================================================================;
;                            Real Stereo Machine !                        ;
;                    (C)oderight Nullos / DNT-Crew 1994                   ;
;======================================================= Version 1.0 =====;
;
;Transformation St‚r‚o DMA -> Enhanced Stereo
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
	Xbios	Dsp_ExecProg	;Pof, c'est fait

	lea	PCM_base.w,a0	;
	move.w	#$0191,mpx_src(a0)	;Connexions de la matrice.
	move.w	#$2393,mpx_dst(a0)	;

	move.b	#$93,hcvr+HST_base.w	;DSP en Enhanced St‚r‚o
	moveq	#2,d0		;
	move.l	d0,htx+HST_base.w	;pour du 25Khz.

	Gemdos	Super
	pea	message(pc)
	Gemdos	Cconws
	Gemdos	Pterm0

	section	data
stereo	incbin	stereo.p56
stereosize	equ	*-stereo

message	dc.b	$d,$a,"Enhanced Stereo 1.0 : activated !",$d,$a,0
