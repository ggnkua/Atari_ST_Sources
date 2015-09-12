	output d:\assemble\sources.v45\blit_off\blit_off.prg

OPT_GWVA_DEBUG_ERROR			; [option][root] generates an illegal when something goes wrong (for debugging purposes)
OPT_GWVA_DEBUG_PRINT_COMMENTS		; [option][root] print comments/warnings when assembling source


	; Un TOS ne peut d‚bugger ni dans une Alert-box ni dans le Logger !

*OPT_DEBUG

	lea objet_application,a1

	include blit_off.def
	include visual45.s
	include blit_off.obj

	comment HEAD=7
	section TEXT

;---------------------------------------------------------------------------
	; Exemple de programme Visual Assembleur 4.5
	; Propri‚t‚ : fonctionne en TOS sans le GEM !
;---------------------------------------------------------------------------

my_inits_created:	; a1.l : ligne de commande, d0.w : taille
	CCONWS text_presentation

	MXALLOC #MX_TTRAM,#-1
	tst.l d0
	beq.s .pas_de_ttram

	clr.w -(sp)
	appel xbios,blitmode,4

	SUPEXEC SearchMySelf

	tst.l GWVA_ROOT_SEARCH_IN_OUT
	beq.s .pas_installee

	CCONWS text_already_installed

	bra.s .wait

.pas_de_ttram:
	CCONWS text_no_ttram

.wait:	appel dos,t_gettime,2
	and.w #%11111,d0
.wait_2s:
	save.w d0
	appel dos,t_gettime,2
	move.w d0,d1
	load.w d0
	and.w #%11111,d1
	cmp.w d0,d1
	beq.s .wait_2s

	moveq #GWVA_PRGRET_CONSUMED,d6
	rts

.pas_installee:
	SUPEXEC InstallMySelf
	cmp.l #GWVA_NO_ERROR_GENERIC,d0
	bne.s .pas_pu_installer

	move.l #GWVA_TSR_SIZE_CTE_TEXT_DATA_BSS,GWVA_WAPP_OBJ_TSR_SIZE+objet_application
.pas_pu_installer:
	moveq #GWVA_PRGRET_CONSUMED,d6
	rts

SearchMySelf:
	move.l #_vec_trap14,GWVA_ROOT_SEARCH_IN_OUT
	move.l #'BOFF',GWVA_ROOT_SEARCH_IN_OUT+4
	bsr GWVA_XBRA_SEARCH_ONE_XBRA
	rts

InstallMySelf:
	move.l #_vec_trap14,GWVA_ROOT_SEARCH_IN_OUT
	move.l #blit_off,GWVA_ROOT_SEARCH_IN_OUT+4
	bsr GWVA_XBRA_INSTALL_ONE_XBRA
	move.l GWVA_ROOT_SEARCH_IN_OUT,d0
	rts

	dc.l 'XBRA','BOFF',0
blit_off:	lea 6(sp),a0
	tst.w (_longframe).w
	beq.s .short_stack_frame
	lea 8(sp),a0
.short_stack_frame:
	btst #5,(sp)		; test du bit S sur SR
	bne.s .appel_en_superviseur
	move.l usp,a0
.appel_en_superviseur:
	cmp.w #blitmode,(a0)		; BlitMode
	bne.s .pas_blitmode
	moveq #0,d0			; pas de blitter hard et blit soft
	rte
.pas_blitmode:
	move.l blit_off+xbra_next,a0
	jmp (a0)

;------------------------------------------------------------------------------

	section DATA

text_presentation:	dc.b esc,$70
		dc.b 'BLITTER OFF V 1.0'
		dc.b esc,$71
		dc.b rc,lf
		dc.b '(c) Benoit PERRIN 08/11/1998',rc,lf
		dc.b rc,lf,0

text_already_installed:	dc.b esc,$70
		dc.b 'The BLITTER OFF is already installed !'
		dc.b esc,$71
		dc.b rc,lf,0

text_no_ttram:	dc.b 'There is no TT-RAM. BLITTER OFF is not installed.'
		dc.b rc,lf,0

 even

 END
