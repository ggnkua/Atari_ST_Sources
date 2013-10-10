	output d:\assemble\sources.v40\hardsafe\safeauto.prg

DEBUT_TSR:	lea objet_application,a1

	include safeauto.def
	include visual40.s
	include safeauto.obj

	comment HEAD=7
	section TEXT

;---------------------------------------------------------------------------
	; Hard Disk Saver (auto module)
	; (c) Pierre LALOE 21 January 1996
;---------------------------------------------------------------------------

my_inits:	CCONWS message

	move.l #HDV_RW,GWVA_APP_OBJ_SEARCH_IN_OUT
	move.l #'HDSv',GWVA_APP_OBJ_SEARCH_IN_OUT+4
	SUPEXEC GWVA_APP_OBJ_SEARCH_ONE_XBRA

	tst.l GWVA_APP_OBJ_SEARCH_IN_OUT
	bne already_installed

	move.l #'XHDI',GWVA_APP_OBJ_SEARCH_IN_OUT
	SUPEXEC GWVA_APP_OBJ_SEARCH_ONE_COOKIE

	move.l GWVA_APP_OBJ_SEARCH_IN_OUT,a0
	cmp.l #0,a0
	beq no_xhdi
	cmp.l #$27011992,([a0],-4)
	bne no_xhdi
	move.l (a0),pointeur_driver_xhdi

	SUPEXEC scan_disks

	move.l #HDV_RW,GWVA_APP_OBJ_SEARCH_IN_OUT
	move.l #new_rout,GWVA_APP_OBJ_SEARCH_IN_OUT+4
	SUPEXEC GWVA_APP_OBJ_INSTALL_ONE_XBRA

	CCONWS message_success

	move.l #FIN_TSR-DEBUT_TSR+4096,objet_application+GWVA_APP_OBJ_TSR_SIZE

	rts

no_xhdi:	CCONWS message_no_xhdi
	bra.s finished

already_installed:
	CCONWS message_twice

finished:	CRAWCIN
	rts

*--------------------------------------------------------------------------*
scan_disks:
	move.w #6,-(sp)		; XHD drv map
	jsr ([pointeur_driver_xhdi])
	lea 2(sp),sp
	and.l #$ffffffff-1-2,d0		; - A et B

	lea tableau_correspondance,a0
	clr d1

.scan:	lsr.l #1,d0
	bcc.s .next

	save.l d0-d1/a0
	clr.l -(sp)			; *bpb
	clr.l -(sp)			; *startsec
	clr.l -(sp)			; *minor
	pea major_nr		; major
	move.w d1,-(sp)		; bios dev
	move.w #7,-(sp)		; XHD inq dev
	jsr ([pointeur_driver_xhdi])
	lea 20(sp),sp
	tst d0
	bmi.s .erreur

	load.l d0-d1/a0

	move major_nr,d2
	lea tableau_acces_lecteurs,a1
	mulu #4,d2
	add d2,a1
	move.l a1,(a0)
	move.l cpt_200,(a1)
	bra.s .next

.erreur:	load.l d0-d1/a0

.next:	addq #1,d1
	lea 4(a0),a0
	cmp.w #31,d1
	bne.s .scan
	rts
*--------------------------------------------------------------------------*

	dc.l 'XBRA'
	dc.l 'HDSv'
old_rout:	dc.l 0

new_rout:	bra.s .zap

	dc.l tableau_acces_lecteurs

.zap:	move.w 4+2+4+2+2(sp),d0		; d0-d2 / a0-a2
	lsl.w #2,d0
	lea tableau_correspondance,a0
	tst.l (a0,d0.w)
	beq.s .not_you		; A, B
	move.l cpt_200,([a0,d0.w])
.not_you:
	opt o-
	jmp ([old_rout])
	opt o+

*--------------------------------------------------------------------------*

	section DATA

message:	dc.b rc,lf
	dc.b esc,$70
	dc.b 'HardDisk Saver, resident part   21 January 1996'
	dc.b esc,$71
	dc.b rc,lf
	dc.b '(c) Pierre LALOE 1996',rc,lf
	dc.b 0

message_twice:
	dc.b esc,$70
	dc.b 'Cannot be installed twice !'
	dc.b esc,$71
	dc.b rc,lf
	dc.b rc,lf,0

message_no_xhdi:
	dc.b esc,$70
	dc.b 'No XHDI Driver, cannot run !'
	dc.b esc,$71
	dc.b rc,lf
	dc.b rc,lf,0

message_success:
	dc.b esc,$70
	dc.b 'Successfully installed as HDV_RW : "HDSv"'
	dc.b esc,$71
	dc.b rc,lf
	dc.b rc,lf,0

*--------------------------------------------------------------------------*

	section BSS

major_nr:		ds.w 1
pointeur_driver_xhdi:	ds.l 1
tableau_correspondance:	ds.l 32	; pointeurs : A = 0 ... C = 2Šme entr‚e

tableau_acces_lecteurs:	ds.l 8+8+2

*--------------------------------------------------------------------------*

FIN_TSR:
 END
