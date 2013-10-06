	output d:\assemble\sources.v45\enter\enter.ttp

OPT_GWVA_DEBUG_ERROR			; [option][root] generates an illegal when something goes wrong (for debugging purposes)
OPT_GWVA_DEBUG_PRINT_COMMENTS		; [option][root] print comments/warnings when assembling source

*OPT_DEBUG

	lea objet_application,a1

	include enter.def
	include visual45.s
	include enter.obj

	comment HEAD=7
	section TEXT

;---------------------------------------------------------------------------
	; Exemple de programme Visual Assembleur 4.5
	; Propri‚t‚ : fonctionne en TOS sans le GEM !
;---------------------------------------------------------------------------

my_inits_created:
	ifd OPT_DEBUG
	illegal
	endc

	save.l a1/d0
	CCONWS msg
	movem.l (sp),a1/d0
	CCONWS (a1)
	CCONWS rc_lf
	load.l a1/d0

	tst d0
	beq.s .no_cmd_line

	lea prg_name,a2
.copy:	move.b (a1)+,(a2)+
	tst.b -1(a2)
	beq.s .no_params
	cmp.b #' ',-1(a2)
	bne.s .copy

	clr.b -1(a2)

	lea prg_cmd_line+1,a2
	COPY_STRING_0 a1,a2
	sub.l #prg_cmd_line+1+1,a2
	move.l a2,d0
	move.b d0,prg_cmd_line

.no_params:
	PEXEC envs,prg_cmd_line,prg_name,#0
	CRAWCIN

.no_cmd_line:

	moveq #GWVA_PRGRET_CONSUMED,d6
	rts

	section DATA

envs:	dc.b 0
msg:	dc.b 'Command line was : ',0
rc_lf:	dc.b rc,lf,0
 even

	section BSS
prg_name:		ds.b GWVA_ROOT_MAX_PATH_LENGTH
prg_cmd_line:	ds.b GWVA_ROOT_MAX_PATH_LENGTH
 END