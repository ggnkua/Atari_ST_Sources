;----------------------------------------------------------------------------
;File name:	COLORTOS.S			Revision date:	1998.10.18
;Revised by:	Ronald Andersson		Revision start:	1998.08.31
;Version:	1.01				Release date:	not yet
;----------------------------------------------------------------------------
VERSION_S	MACRO
	dc.b	'1.01'
	ENDM
RELDATE_S	MACRO
	dc.b	'beta 1998.10.14'
	ENDM
;----------------------------------------------------------------------------
XB_cpu_mode	=	1	;RA_XB shall assume supervisor mode active
;
	include	RA_TOS.I
	include	RA_JAR.I
	include	RA_XGEM.I
	include	RA_LA.I
;
;NB:	The libs included above also include other libs automagically...
;----------------------------------------------------------------------------
MAX_ICONS	=	200
NOVA_GREY	=	$EF3D	;NOVA TC code for 3D grey
;----------------------------------------------------------------------------
;Remarks:
;
;The original version of this program was written by Guillaume Tello,
;as indicated by his original file header which follows further below.
;I, Ronald Andersson have implemented the following changes to his code:
;
;1:	Converted source into DevPac_3 format
;2:	Added XBRA headers to all 'bent' vector code.  (XBRA id = 'CoIc')
;3:	Added XBRA protocol to all vector 'bending' code.
;4:	Added new TOS version adaption, leading to a single program for all
;	supported TOS versions.
;5:	Added TOS version adaption data for TOS 2.06.
;6:	Replaced 68030-dependent code for ST/STE compatibility
;7:	Added recognition of two more cookies (_CPU, Gnva)
;8:	Renamed the program from COLOR_TT to COLORTOS, since it now does
;	support ST/STE machines as well (when using TOS 2.06 that is).
;9:	Added multiple XBRA vector installation to circumvent the 'delinking'
;	operations of NVDI, which otherwise prevent proper function.
;10:	Corrected a bug in declaration of 'adr_actu' (must be ds.l not ds.w).
;	This bug was 'mostly harmless' but lowered drawing speed a bit.
;11:	Modified storage methods to allow for selected icon definitions.
;12:	Modified vrt_cpyfm function to support selected icon definitions.
;13:	Added code to generate selected icons for icon definitions lacking it.
;-------
;NB:	Lack of XBRA protocol is the main reason why the original version
;	did not cooperate well with other utilities bending AES/VDI vectors.
;	NVDI additionally demands extra precautions against 'delinking',
;       and it is those that are mentioned as change number 9 above.
;-------
;After the above changes I contacted Guillaume and together we agreed that I
;should merge my changes with some that he had developed since his release,
;and we also agreed on some modifications of both sets of enhancements.
;The resulting changes are summarized below:
;-------
;14:	Merged (incomplete) TOS adaption data for TOS 2.05, from COL_MSTE.
;15:	Merged TOS 3.06 3D window support from Guillaume's COLOR_TT version.
;16:	I've added TOS adaption data for TOS 2.06 3D window support.
;17:	I've restructured the XGEM dispatcher completely, for better speed.
;18:	I've added ability to relocate some AES pointers for compatibility
;       with TOS patchers (eg: GEMRAM + WINX + SHBUF) and RAM TOS versions.
;       This support is complete for TOS 2.06 and 3.06, but I lack info on
;	the AES start adress of the others... (plus lots other stuff on 2.05)
;	Since I also lack any atari RAM TOS some stuff remains untested
;-------
;After further discussions with Guillaume we agreed that TOS 1.x are not to
;be targeted for COLORTOS adaptions.  Their TOS and desktops differ too much
;from TOS 2.x for it to be meaningful to combine their support into COLORTOS.
;Instead Guillaume produces some separate programs specifically for those
;TOS, giving them some new icons etc.
;-------
;We also agreed that I should try to use the methods of Guillaume's newer
;program COL_MSTE for COLORTOS, so that fewer TOS dependent vectors will
;be used.  (This has not yet been implemented.)
;-------
;A bug was discovered in trying to use 'Pure Debugger' with COLORTOS, which
;was due to XBRA smashing by the debugger.  A patch for that debugger was
;quickly produced, but I also decided to develop a better mechanism for
;protecting the XBRA chains.  This involves compatibility to lots of very
;important software, such as debuggers, NVDI, other AES enhancers etc,
;of which nearly all mishandle the XBRA chains in some way.
;-------
;19:	I've implemented XBRA chain protection for the XGEM vector, such
;	that debugging under COLORTOS does not require patched debuggers.
;20:	I've eliminated the (erroneous) 3D drawing of d-clicked icon labels.
;21:	I've added 3D-support for atari mode with 2 bitplanes (ST_M) and
;	also for single-plane mode (ST_H, TT_H), which latter also should
;	work with the Nova graphics board (I don't have any, so can't test).
;22:	I added version number info (1.00) to the startup message.
;23:	I sent this version 1.00 to Guillaume, and posted it on my homepage
;	(http://www.oden.se/~dlanor/)
;-------
;This marks the first public release of COLORTOS, Ver:1.00 of 1998.10.12
;-------
;24:	I added clipping of 3D rectangles, to avoid crossing screen borders.
;25:	I added limit checks for window ids to avoid bombs under WinX.
;	This means that windows with id >7 under WinX or similar will get
;       proper 3D, except that title/info lines of desktop under WinX are not
;       recognized (so just 2D).  Windows of normal APPs do not have that
;	that problem, which is due to internal methods of WinX.
;26:	I improved the 3D rutines for 1 or 2 bitplanes to use a grey hatch
;	pattern rather than black for the 3D shadows.
;
;NB:	3D gadgets are now supported for all native Atari ST and TT rez modes
;	and also for 3 rez modes of the Nova board (1 or 8 planes, 16bit TC).
;
;NB:	TOS versions now supported are: 2.06, 3.05, 3.06 . (2.05 is coming)
;	As yet only TOS 2.06 and 3.06 have 3D window support.
;----------------------------------------------------------------------------
;Start of:	Original file header, by original author (Tello Guillaume)
;----------------------------------------------------------------------------
; COLOR_TT.PRG
; programme r‚sident (dossier AUTO )
; permet d'obtenir:
; 	- des icones couleurs sur le bureau
;  - des icones color‚es dans les boites d'alerte
; Tourne sur TT (TOS 3.6) uniquement (avec ou sans carte NOVA 32000 couleurs).
; Auteur: Tello Guillaume (Ao–t/Novembre 1995)
;			 240 rue Estienvrin
;			 49260 Montreuil Bellay
;		tel: 41 38 71 48
;		email: gtello@planete.net
; assembl‚ avec ASSEMBLE de Brainstorm.
;
; changements par rapport … la version pr‚c‚dente:
;
; les changements de r‚solution sont support‚s (seule la r‚solution de boot
; du bureau l'‚tait avant), l'adaptation des icones se fait 'en temps r‚el':
; - quelque soit la r‚solution, la place m‚moire est la mˆme
; - si la mˆme icone est redessin‚e deux fois de suite, elle n'est pas
;   recalcul‚e, on dispose d'un buffer d'une icone.
;----------------------------------------------------------------------------
;End of:	Original file header, by original author (Tello Guillaume)
;----------------------------------------------------------------------------
;Start of:	internal macro definitions
;----------------------------------------------------------------------------
;The macros 'patch' and 'patch_t' are used to generate relocation tables for
;all pointers that need to be calculated at runtime (during installation).
;The assemblytime variable 'ptc__p' also plays a big role in this process, as
;does also the submacro 'sub_patch_t' (not to be explicitly called).
;----------------------------------------------------------------------------
ptc__ct	set	0	;init the patch counter to zero
;------------------------------------
patch	MACRO	location
ptc__\<ptc__ct>	=	\1
ptc__ct	set	ptc__ct+1
	ENDM	;patch
;------------------------------------
patch_t	MACRO
ptc__max	=	ptc__ct
	repeat	ptc__max,sub_patch_t
	dc.l	0
	ENDM	;patch_t
;------------------------------------
sub_patch_t	MACRO
ptc__ct	set	ptc__ct-1
	dc.l	ptc__\<ptc__ct>
	ENDM	;sub_patch_t
;----------------------------------------------------------------------------
;NVDI always attempts to 'delink' other 'benders' of the XGEM vector, and to
;prevent this it is necessary to link in multiple vectors, in a very careful
;manner. This means a lot of code must be duplicated for speed optimization,
;and that makes it difficult to update the code properly.  For this reason
;the code to be used by the XGEM dispatchers is defined in a single macro,
;whose argument determines which of the dispatchers will be generated.
;------------------------------------
;NB: Normal TOS also uses some 'delinking' of XGEM vectors, but not exactly
;    the same way as NVDI does.  The methods I use are adapted to both.
;----------------------------------------------------------------------------
XGEM_code	MACRO	XGEM_id
	XGEM_define	nu_\1,'CoIc'	;XBRA header is defined here
	cmp	#$73,d0			;VDI call ?
	beq.s	nu_VDI_\1
	cmp	#$C8,d0			;AES call ?
	beq.s	nu_AES_\1
	XB_gonext_a0	nu_\1(pc)	;go to older XGEM
;------------------------------------
nu_AES_\1:
	move.l	d1,a0			;a0 =  d1 -> AES_param_blk
	move.l	(a0),a0			;a0 -> contrl
	cmp	#$67,(a0)		;AES opcode $67 ? (wind_delete)
	bhs.s	.AES_67_xx		;go continue test for opcodes >= $67 (not very many)
	XB_gonext_a0	nu_\1(pc)	;go to older XGEM for opcodes < $67 (most opcodes)
;-------
.AES_67_xx:
	cmp	#$69,(a0)		;AES opcode $69 ? (wind_set)
	bls.s	.AES_67_69		;go continue test for opcodes in range $67..$69
	XB_gonext_a0	nu_\1(pc)	;go to older XGEM for opcodes > $69 (several opcodes)
;-------
.AES_67_69:
	beq.s	nu_wind_set_\1		;if wind_set call, go deal with it further below
	cmp	#$67,(a0)		;AES opcode $67 ? (wind_delete)
	beq	nu_wind_delete_\1	;if wind_delete call, go deal with it further below
	XB_gonext_a0	nu_\1(pc)	;go to older XGEM for opcodes $65,$66,$68
;------------------------------------
nu_wind_set_\1:
	move.l	d1,a0			;a0 =  d1 -> AES_param_blk
	move.l	8(a0),a0		;a0 -> intin
	cmp	#3,2(a0)		;WF_ type > _INFO ?  (we want _NAME, _INFO)
	bhi.s	direct_to_old_\1	;go use older XGEM if WF_ type > 3
	cmp	#2,2(a0)		;WF_ type > _NAME ?  (we want _NAME, _INFO)
	blo.s	direct_to_old_\1	;go use older XGEM if WF_ type < 2
	bra	nu_wind_set_work_\1	;go do rest of work below (keeps some branches short)
;------------------------------------
nu_VDI_\1:
	move.l	d1,a0			;a0 =  d1 -> vdi_param_blk
	move.l	(a0),a0			;a0 -> control
	cmp	#$79,(a0)		;VDI opcode == vrt_cpyfm ?
	beq	nu_vrt_cpyfm_\1
	cmp	#$72,(a0)		;VDI opcode == vr_recfl ? (for frame rectangles)
	beq.s	nu_3D_fix_\1
	cmp	#8,(a0)			;VDI opcode == v_gtext ?  (for gadget characters)
	beq.s	nu_3D_fix_\1
direct_to_old_\1:
	XB_gonext_a0	nu_\1(pc)	;go use older XGEM
;------------------------------------
;NB: The tests have been reordered so as to minimize delays for calls
;    that do not use the enhanced functions.  This is VITAL for speed.
;    Although the speed of enhanced functions does become slower by
;    this method, the speed of all unenhanced function calls is raised.
;    Since the latter will normally dominate, the result is a significant
;    speed improvement.
;------------------------------------
nu_3D_fix_\1:
	btst	#5,(sp)			;CPU in supervisor mode ?
	beq.s	direct_to_old_\1	;skip 3D stuff for user mode (non-TOS call)
	dc.l	move_preframe_retadr_a0	;a0 = return address before the trap call
	patch	(*-4)		;NB: this patch adapts to stack frame size of CPU
	cmp.l	#AES_3Drecfl_ret_p,a0	;was call in supported TOS location for vr_recfl ?
	patch	(*-4)
	beq.s	.valid_3D_call		;if so, then we treat it as valid for 3D fix
	cmp.l	#AES_3Dgtext_ret_p,a0	;was call in supported TOS location for v_gtext ?
	patch	(*-4)
	bne.s	direct_to_old_\1	;if not, then it is not valid for 3D fix
.valid_3D_call:
	tst	AES_3D_support_f	;is this a TOS we know how to support ?
	beq.s	direct_to_old_\1	;else we can NOT support 3D
	cmp	#16,LA_planes_p.l	;16 planes ?
	patch	(*-4)
	bhi.s	direct_to_old_\1	;more than 16 planes is NOT supported
	tst.b	nova			;nova graphics board
	bne.s	.nova_support		;if so, then we use nova support methods
.atari_support:		;for atari hardware we support all standard modes
	bra.s	supported_3D_fix_\1	;so we just continue, without further tests
;
.nova_support:
	cmp	#8,LA_planes_p.l	;8 planes ?
	patch	(*-4)
	bhs.s	supported_3D_fix_\1	;if higher or equal, we have support (8p & TC)
	cmp	#2,LA_planes_p.l	;2 planes ?
	patch	(*-4)
	bhs.s	direct_to_old_\1	;2-4 nova planes is NOT supported
supported_3D_fix_\1:
	move.l	d1,a0			;a0 =  d1 -> vdi_param_blk
	move.l	(a0),a0			;a0 -> control
	cmp	#8,(a0)			;VDI opcode == v_gtext ?
	dc.l	move_preframe_retadr_a0	;a0 = return address before the trap call
	patch	(*-4)		;NB: this patch adapts to stack frame size of CPU
	beq.s	nu_v_gtext_\1		;if v_gtext call, try to fix gadget character
;-------				;else note vr_recfl rectangle size for future
nu_vr_recfl_\1:
	cmp.l	#AES_3Drecfl_ret_p,a0	;was call in supported TOS location for vr_recfl
	patch	(*-4)
	bne.s	direct_to_old_\1	;if not, then it is not valid for 3D fix
	movem.l	d0-d1/a1-a2,-(sp)	;push some entry registers
	bsr	save_rect		;fix it
	bra	exit_to_old_\1		;let older XGEM do normal work
;-------
nu_v_gtext_\1:
	cmp.l	#AES_3Dgtext_ret_p,a0	;was call in supported TOS location for v_gtext
	patch	(*-4)
	bne.s	direct_to_old_\1	;if not, then it is not valid for 3D fix
	movem.l	d0-d1/a1-a2,-(sp)	;push some entry registers
	bsr	draw_3D_lines		;fix it
	bra	exit_to_old_\1		;let older XGEM do normal work
;------------------------------------
nu_vrt_cpyfm_\1:
	cmp	#4,LA_planes_p.l	;4 planes ?
	patch	(*-4)
	blt	direct_to_old_\1	;skip colour icons for less than 4 planes
	movem.l	d0-d1/a1-a2,-(sp)	;push some entry registers
	cmp.l	#AES_MFDB_src_p,14(a0)	;is this the AES MFDB source ?
	patch	(*-6)
	bne	exit_to_old_\1		; non, pas une icone alors!
	move.l	AES_al_BITBLK_p_p.l,a0	; le BITBLK (pointeur donn‚es) des alertes
	patch	(*-4)
	cmp.l	AES_MFDB_src_p.l,a0	; meme adresse?
	patch	(*-4)
	bne.s	.non_alert		; non, pas une icone d'alerte
	exg.l	d1,a0			; si oui, on va v‚rifier l'adresse
	sub.l	AES_weird_RSC_p_p.l,d1
	patch	(*-4)
;-------
	sub.l	#2156,d1		; offset de l'icone
	bmi	exit_to_old_\1		; en dessous!
	cmp.l	#384,d1			; 3*128 pour 3 icones
	bpl	exit_to_old_\1		; au dessus
	move.l	4(a0),a0		; intin
	move	#4,2(a0)		; couleur icone (du bleu au lieu du noir)
	bra	exit_to_old_\1
;------------------------------------
.non_alert:
;-------
	move.l	AES_ICON_data_p_p.l,a0	;a0 -> ICONBLK des disques (pointeur datas)
	patch	(*-4)
	move.l	AES_MFDB_src_p.l,a1	;a1 -> src data of MFDB
	patch	(*-4)
	cmp.l	a1,a0			;same address ?
	bne.s	.pas_data		; non, on dessine autre chose
	move.l	AES_DESKICON_p_p.l,a2	;a2 -> DESKICON RSC base
	patch	(*-4)
;-------
	add.w	14(a2),a2		;a2 -> DESKICON RSC data
	add.w	#128,a2			; passe le masque
	sub.l	a2,a1			;offset of icon relative to 1st icon
	cmp.l	#0,a1			;negative offset ?
	bmi	exit_to_old_\1		;if so, then this is not a desktop icon !
;here a1 is a multiple of 256, the space for an icon + mask in DESKICON.RSC
	add.l	a1,a1			; paquets de 256 en 512 (pour 4 plans)
;here a1 is a multiple of 512, the space of a pure 4-plane icon in icon array
	add.l	a1,a1
;I now double this yet again, so as to allow for selected icon definitions
	move.l	d1,a0			;a0 =  d1 -> vdi_param_blk
	move.l	4(a0),a0		;a0 -> intin
	tst	2(a0)			;normal colour ?
	bne.s	.have_icon_offs
	add	#512,a1			;a1 = offset for selected icon
.have_icon_offs:
	add.l	data_ptr,a1		;a1 -> icon in main icon array
	cmp.l	data_end,a1		;is it beyond upper limit
	bpl	exit_to_old_\1		;if so, then this is not a desktop icon !
	bsr	adapt_icone		; selon les plans et NOVA ou ATARI
	move.l	d1,a0			;a0 =  d1 -> vdi_param_blk
	move.l	4(a0),a0		;a0 -> intin
	move	#7,(a0)			; mode or
	cmp	#16,plans
	bne.s	.k1
	addq	#2,(a0)			; mode 9 plus joli!
.k1:
	move.l	#une_icone,mfdb		; adresse donn‚es
	move.l	d1,a0
	move.l	(a0),a1			; control
	move	#109,(a1)		; vro_cpyfm (au lieu de vrt_cpyfm)
	move	#1,6(a1)		; 1 seul intin
	move.l	#mfdb,14(a1)		; nouvel mfdb
	bra.s	exit_to_old_\1
;------------------------------------
.pas_data:
;-------
	move.l	AES_ICON_mask_p_p.l,a0	;a0 -> ICONBLK des disques (masques)
	patch	(*-4)
	cmp.l	a1,a0			; bonne adresse?
	bne.s	exit_to_old_\1		;else leave it to older VDI code
	exg.l	d1,a0			;d1 -> ICONBLK,  a0 -> vdi_param_blk
	move.l	AES_DESKICON_p_p.l,a2	;a2 -> DESKICON RSC base
	patch	(*-4)
;-------
	add.w	14(a2),a2		;a2 += offset to data in DESKICON RSC
	sub.l	a2,d1			;d1 = offset of icon from data start
	bmi.s	exit_to_old_\1		;negative offset == it is no desktop icon !
;here d1 is a multiple of 256, the space for an icon + mask in DESKICON.RSC
;;;	asr.l	#1,d1			; 256 en paquets de 128
;here d1 used to be a multiple of 128, to index the icon mask array
;but I changed this to allow for selected icon definitions
	move.l	4(a0),a0		;a0 -> intin
	tst	2(a0)
	beq.s	.have_mask_offs
	add.l	#128,d1			;d1 = offset to selected icon mask
.have_mask_offs
	add.l	#zone,d1		;d1 -> icon mask
	cmp.l	data_ptr,d1		;beyond limit for the icon mask array ?
	bpl.s	exit_to_old_\1		;if so, then it is not a desktop icon !
;-------
	move.l	d1,AES_MFDB_src_p	; masque choisi comme donn‚es du MFDB
	patch	(*-4)
;-------
	move.l	#1,2(a0)		;Colours = white on black, avoids inversion
exit_to_old_\1:
	movem.l	(sp)+,d0-d1/a1-a2		;pull some entry registers
	XB_gonext_a0	nu_\1(pc)	;go use older XGEM
;------------------------------------
nu_wind_set_work_\1:
	cmp	#256,(a0)		;is window id >= 256 ?  (we can't handle such)
	bhs	direct_to_old_\1	;go use older XGEM if window id is too high ?
	move.l	4(a0),-(sp)		;push the long value ((intin[2]<<16)|intin[3])
	move	(a0),d0			;d0 = window id
	lsl	#1,d0			;d0 = window_id*2  (for 2 longs per struct)
	add	2(a0),d0		;d0 = window_id*2+WF_type
	subq	#2,d0			;d0 = window_id*2+(WF_type-2)
	lsl	#2,d0			;d0 = byte offset for storage of value in array
	lea	window_data_t(pc),a0	;a0 -> base of array of structs
	move.l	(sp)+,(a0,d0)		;pull the long value from stack into struct in array
	move	#$C8,d0			;d0 = XGEM opcode for AES
	XB_gonext_a0	nu_\1(pc)	;go to older XGEM after intern wind_set work
;------------------------------------
nu_wind_delete_\1:
	move.l	d1,a0			;a0 =  d1 -> AES_param_blk
	move.l	8(a0),a0		;a0 -> intin
	move	(a0),d0			;d0 =  window id
	cmp	#256,d0			;is window id >= 256 ?  (we can't handle such)
	bhs.s	.exit			;exit if window id too high
	lsl	#3,d0			;scale index for 8 bytes per struct
	lea	window_data_t(pc),a0	;a0 -> base of array of structs
	add	d0,a0			;a0 -> struct for created window
	clr.l	(a0)+			;\/ Clear this struct entirely
	clr.l	(a0)+			;/\ to mark that it is invalid
.exit:
	move	#$C8,d0			;d0 = XGEM opcode for AES
	XB_gonext_a0	nu_\1(pc)	;go use older XGEM
	ENDM	XGEM_code
;----------------------------------------------------------------------------
;End of:	internal macro definitions
;----------------------------------------------------------------------------
	SECTION	TEXT
;----------------------------------------------------------------------------
debut:
	jmp	init			; saute la partie r‚sidente
;----------------------------------------------------------------------------
;Start of:	3D window subroutines
;----------------------------------------------------------------------------
;'save_rect' below has been modified, to make non-TOS vr_recfl calls faster.
;The return address test has therefore been moved to the dispatcher, and so
;has the register push/pull operations.
;
save_rect:
	sf	rect_flag		;mark rectangle as invalid (for failed tests)
	move	AES_actwnd_id_p.l,d0	;d0 = active window id  (from AES variable)
	patch	(*-4)
	ble.s	.exit			;exit if no window (or desk backgnd) active
	cmp	#256,d0			;is window id >= 256 ?  (we can't handle such)
	bhs.s	.exit			;exit if window id too high
	move.b	d0,rect_flag+1		;save window id (handle) for later use (by v_gtext)
	clr.l	actwnd_str_VAR_p
	cmp	#8,d0			;is window id >= 8 (Enhanced by WinX or similar)
	bhs.s	.done_str_VAR_p		;if so, then wind parm structs are not in standard VDI places
	muls	#132,d0
	lea	AES_wind_parm_t_p.l,a0	;a0 -> AES array of window parameter structs
	patch	(*-4)
	add	d0,a0			;a0 -> struct of active window
	addq	#8,a0			;a0 -> ptrs to title and info strings in struct
	move.l	a0,actwnd_str_VAR_p	;store -> strings according to AES variable area
.done_str_VAR_p:
	lea	window_data_t(pc),a0	;a0 -> base of array of window data structs
	move	rect_flag(pc),d0	;d0 = window id
	lsl	#3,d0			;d0 = window_id * 8  (for 8 bytes per struct)
	add	d0,a0			;a0 -> local struct for active window
	move.l	a0,actwnd_str_SET_p	;store -> to strings according to wind_set calls
;-------
	move.l	d1,a0			;a0 -> vdi_param_blk
	move.l	8(a0),a0		;a0 -> ptsin
	move.l	(a0)+,rect_size		;store x0.y0 in rect_size array
	move.l	(a0),rect_size+4	;store x1.y1 in rect_size array
	st	rect_flag		;mark rectangle as valid (for use by draw_3D_lines)
.exit:
	rts				;return to caller (vr_recfl part of XGEM)
;----------------------------------------------------------------------------
;'draw_3D_lines' below will draw the border lines of a rectangle to give it
; a 3D appearance => Top and left borders entirely white, but the bottom and
; right borders grey, except for leftmost and topmost bits which are white.
;----------------------------------------------------------------------------
;NB: For simplicity, modes with 1 or 2 planes use black instead of grey.
;----------------------------------------------------------------------------
draw_3D_lines:
	lea	rect_flag,a0		;a0 -> rect_flag
	tst.b	(a0)			;is high byte set ? (valid for present use)
	bne.s	.ok			;if so, low byte is window id, go check on
.ciao:					;here we just return, having done nothing
	rts				;return to caller (v_gtext part of XGEM)
;-------
.ok:
	sf	(a0)			;clear high byte of rect_flag (invalidates future use)
	move	(a0),d0			;d0 = window id
	cmp	AES_actwnd_id_p.l,d0	;is this the topped window ?
	patch	(*-4)
	bne.s	.ciao			;if not, it should not have 3D fix
	lea	rect_size,a0		;a0 -> rect_size
	move	6(a0),d0		;d0 = y1
	sub	2(a0),d0		;d0 = y1-y0
	cmp	#8,d0			;are more than 8 lines affected ?
	blt	.ciao			;if not, exit since 3D gadgets should have more
	movem.l	d2/d3,-(sp)
	move.l	d1,a0			;a0 -> vdi_param_blk
	move.l	4(a0),a1		;a1 -> intin
	move.l	(a0),a0			;a0 -> control
	move	6(a0),d0		;d0 = character count
	beq	.exit			;exit if no chars...
	cmp	#1,d0			;one single char ?
	bne.s	.autres
	move	(a1),d1			;d1 = ascii of the single char
	cmp	#1,d1			;ascii < 1 ?
	bmi.s	.autres			;if so, test on at 'autres'
	cmp	#8,d1			;ascii < 8 ?
	bmi.s	.bon			;if ascii is 1..7 it is valid for gadgets
.autres:			;Here string is not a valid single-char gadget
;-------			;So we must check if it is legal as title or info bar
	clr	actwnd_str_VAR_f	;clear two byte flags
	move.l	actwnd_str_VAR_p,d2	;d2 = test -> strings according to AES variables
	ble.s	.done_str_VAR_p
	move.l	d2,a0
	move.l	(a0),d2			;d2 = test -> title string
	ble.s	.not_title_VAR
	st	actwnd_str_VAR_f
	move.l	d2,a0			;a0 -> title string
	bsr	cmp_v_gtext_str		;compare string to v_gtext argument
	beq.s	.bon			;accept 3D gadget if strings match
.not_title_VAR:
	move.l	actwnd_str_VAR_p,a0	;a0 -> strings according to AES variables
	move.l	4(a0),d2		;d2 = test -> info string
	ble.s	.not_info_VAR
	st	actwnd_str_VAR_f+1
	move.l	d2,a0			;a0 -> info string
	bsr	cmp_v_gtext_str		;compare string to v_gtext argument
	beq.s	.bon			;accept 3D gadget if strings match
.not_info_VAR:
.done_str_VAR_p:
	tst.b	actwnd_str_VAR_f
	bne.s	.not_title_SET
	move.l	actwnd_str_SET_p,a0	;a0 -> strings according to wind_set calls
	move.l	(a0),d2			;d2 = test -> title string
	ble.s	.not_title_SET
	move.l	d2,a0			;a0 -> title string
	bsr	cmp_v_gtext_str		;compare string to v_gtext argument
	beq.s	.bon			;accept 3D gadget if strings match
.not_title_SET:
	tst.b	actwnd_str_VAR_f+1
	bne	.exit			;refuse 3D gadget if strings unmatched
	move.l	actwnd_str_SET_p,a0	;a0 -> strings according to wind_set calls
	move.l	4(a0),d2		;d2 = test -> info string
	ble	.exit			;refuse 3D gadget if strings unmatched
	move.l	d2,a0			;a0 -> info string
	bsr	cmp_v_gtext_str		;compare string to v_gtext argument
	bne	.exit			;refuse 3D gadget if strings unmatched
.bon:					;here string is a valid gadget, title, or status line
	lea	rect_size,a0		;a0 -> rect_size
.clip_vertically:
	clr.l	d2			;preclear high bits of d2, (clipping flags)
	move	2(a0),d0		;d0 = y0
	bpl.s	.done_clip_top
	clr	d0			;d0 = clipped y0
	move	d0,2(a0)		;clip y0 in array too
	bset	#31,d2			;flag clipping of top edge
.done_clip_top:
	move	6(a0),d2		;d2 = y1
	bmi	.exit			;exit if rectangle completely off screen (above top)
	cmp	LA_v_rez_vt_p.l,d2	;is y1 too high ?
	patch	(*-4)
	blo.s	.done_clip_bot
	move	LA_v_rez_vt_p.l,d2
	patch	(*-4)
	subq	#1,d2			;d2 = clipped y1
	move	d2,6(a0)		;clip y1 in array too
	bset	#30,d2			;flag clipping of bottom edge
.done_clip_bot:
	sub	d0,d2			;d2 = affected lines -1, with clipping flags in high word
	blt	.exit			;if none, exit
;
.clip_horizontally:
	clr.l	d3			;preclear high bits of d3, (clipping flags)
	move	(a0),d1			;d1 = x0
	bpl.s	.done_clip_left
	clr	d1			;d1 = clipped x0
	move	d1,(a0)			;clip x0 in array too
	bset	#31,d3			;flag clipping of left edge
.done_clip_left:
	move	4(a0),d3		;d3 = x1
	bmi	.exit			;exit if rectangle completely off screen (to the left)
	cmp	LA_v_rez_hz_p.l,d3	;is x1 too high ?
	patch	(*-4)
	blo.s	.done_clip_right
	move	LA_v_rez_hz_p.l,d3
	patch	(*-4)
	subq	#1,d3			;d3 = clipped x1
	move	d3,4(a0)		;clip x1 in array too
	bset	#30,d3			;flag clipping of right edge
.done_clip_right:
	sub	d1,d3			;d3 = affected columns -1, with clipping flags in high word
	bmi	.exit			;if no affected columns, just exit
;
	move	LA_bytes_lin_p.l,d1	;d1 = screen width (bytes, incl 'dead' space if any)
	patch	(*-4)
	muls	d1,d0			;d0 = offset to first affected line
	move.l	(_v_bas_ad).w,a1	;a1 -> screen base
	add.l	d0,a1			;a1 -> base of first affected line
	move.l	d1,a2			;a2 = screen width (bytes, incl 'dead' space if any)
;
	tst.b	nova
	bne	.nova_3D
.atari_3D:				;atari bitplane modes go here
	cmp	#8,LA_planes_p.l	;la_planes > 8 ?
	patch	(*-4)
	bhi	.exit			;machines with atari TC modes don't need COLORTOS !
.nova_1_plane:				;for single plane mode, nova branches here too
.bitplane_fix:
.left_mask_fix:
	move	(a0),d0			;d0 = x0
	and	#$F,d0			;d0 = bit offset to 1st column in 1st word
	move	#$8000,d1		;d1 = a word with only bit 15 set
	ror	d0,d1			;d1 = word value for 1st pixel bit
	move	d1,left_bit		;store word value for 1st pixel bit
	add	d1,d1			;d1 = doubled word value
	subq	#1,d1			;d1 = mask for affected bits at right end of word
	move	d1,left_mask		;store left_mask word
	btst	#31,d3			;left edge clipped ?
	beq.s	.left_mask_done
	clr	left_bit		;disable separate bit mask for left edge
.left_mask_done:
.right_mask_fix:
	move	4(a0),d0		;d0 = x1
	and	#$F,d0			;d0 =  bit offset to last column in last word
	move	#$8000,d1		;d1 = a word with only bit 15 set
	ror	d0,d1			;d1 = word value for last pixel bit
	move	d1,right_bit		;store word value for last pixel bit
	subq	#1,d1			;d1 = mask for unaffected bits at right end
	not	d1			;d1 = mask for affected bits at left end
	move	d1,right_mask		;store right_mask word
	btst	#30,d3			;right edge clipped ?
	beq.s	.right_mask_done
	clr	right_bit		;disable separate bit mask for right edge
.right_mask_done:
	move	(a0),d0			;d0 = x0
	asr	#4,d0			;d0 = 16pix group offset to 1st column
	move	4(a0),d3		;d3 = x1
	asr	#4,d3			;d3 = 16pix group offset to last column
	sub	d0,d3			;d3 = 16pix groups needed after the 1st one
	bgt.s	.one_group_fixed	;if plural, skip fix for single group masks
	and	d1,left_mask		;combine right mask with left
.one_group_fixed:
	cmp	#8,LA_planes_p.l	;8 planes ?
	patch	(*-4)
	beq	.atari_8_planes		;if 8 planes, go fix them now
	cmp	#2,LA_planes_p.l	;2 planes ?
	patch	(*-4)
	bhi	.atari_4_planes		;if 4 planes, go fix them now
	beq	.atari_2_planes		;if 2 planes, go fix them now
;------------------------------------	;fix single plane immediately below
.atari_1_plane:
	movem.l	d4-d7,-(sp)		;push some registers
	lsl	#1,d0			;d0 = byte offset to plane 0 word of 1st affected pixel
	add	d0,a1			;a1 -> plane 0 word of 1st affected pixel
;-------
	move	#$5555,d6		;d6 = $5555
	btst	#0,4+1(a0)		;final pixel in odd column ?
	bne.s	.a1_grey_mask_ok_1	;if odd, then the grey mask is ok
	not	d6			;d6 = $AAAA
.a1_grey_mask_ok_1:
	tst.l	d2
	bmi.s	.a1_skip_1st_line	;if top edge clipped, go treat 1st line as mid_line
	move	left_mask(pc),d4
	not	d4			;d4 = mask for anding zeroes into 1st 16pix group
	move.l	a1,a0			;a0 -> 1st affected byte on 1st affected line
	and	d4,(a0)+		;Store white for left pix group on 1st line
	move	d3,d0			;d0 = middle group count +1 (== total count -1)
	ble.s	.a1_done_1st_line	;if only one group on line, the line is complete
	subq	#2,d0			;d0 = dbra count for middle groups
	blt.s	.a1_done_mid_1st_line	;if only two groups on line, skip 'middle' groups
.a1_mid_1st_line_lp:
	clr	(a0)+			;\/ Store white codes for all pixels in
;-------				;/\ 'middle' 16pix groups of 1st affected line
	dbra	d0,.a1_mid_1st_line_lp	;loop back for all 'middle' groups of 1st line
.a1_done_mid_1st_line:
	move	right_mask(pc),d4
	not	d4			;d4 = mask for anding zeroes into last 16pix group
	and	d4,(a0)+		;Store white for right pix group on 1st line
.a1_done_1st_line:
	move	d3,d1			;d1 = 16pix groups per line -1
	lsl	#1,d1			;d1 = byte offset to plane 0 word of last affected pixel
	dbra	d2,.a1_try_mid_lines	;decrement d2 to lines -2, but don't branch on d2 = -1
	bra.s	.a1_done_last_line	;the block only had one line, we'd better just exit
;-------
.a1_try_mid_lines:
	add	a2,a1			;a1 -> 1st affected word of next line
.a1_skip_1st_line:
	move	left_bit,d4
	not	d4			;d4 = word value for clearing left bit by AND
	btst	#30,d2			;bottom edge clipped ?
	bne.s	.a1_use_mid_lines	;then treat all remaining lines as 'middle' lines
	dbra	d2,.a1_use_mid_lines	;decrement d2 to remaining lines -2, but don't branch on d2 = -1
	bra.s	.a1_done_mid_lines	;only one line remains, so skip 'middle'
;-------
.a1_use_mid_lines:
	btst	#0,d2			;is (middle_lines - 1) odd ?  (same as middle_lines being even)
	bne.s	.a1_grey_mask_ok_2		;then the grey mask is ok
	not	d6			;invert grey mask (so bottom line fits with middle lines)
.a1_grey_mask_ok_2:
	clr.l	d5			;preclear high bits of d5
	move	right_bit,d5		;d5 = mask for setting right bit by OR on even lines
	move.l	d5,d0
	not.l	d0
	swap	d0			;d0 = mask for clearing right bit by AND on odd lines
.a1_mid_lines_lp:
	and	d4,(a1)			;Store white for 1st affected pixel on 'middle' lines
	or	d5,(a1,d1)		;Store black for last affected pixel on even 'middle' lines
	swap	d5			;alternate OR mask
	and	d0,(a1,d1)		;Store white for last affected pixel on odd 'middle' lines
	swap	d0			;alternate AND mask
	add	a2,a1			;a1 -> 1st affected word of next line
	dbra	d2,.a1_mid_lines_lp	;loop back for all 'middle' lines
	btst	#30,d2			;bottom edge clipped ?
	bne.s	.a1_done_last_line	;then the last line is already complete
.a1_done_mid_lines:
	move	d4,d0			;d0 = word value for clearing 1st affected pixel
	move	left_mask(pc),d5	;d5 = mask for all affected bits of 1st group
	move	d5,d4			;d4 = mask for all affected bits of 1st group
	and	d6,d5			;d5 = mask to set alternate bits in 1st group by OR
	not	d4			;d4 = mask for unaffected bits of 1st group
	or	d6,d4			;d4 = mask to clear alternate bits of 1st group by AND
	and	d0,d4			;d4 adjusted to always clear 1st valid bit in group too
	move.l	a1,a0			;a0 -> 1st affected byte on last affected line
	or	d5,(a0)			;\/ Store white code for 1st affected pixel
	and	d4,(a0)+		;/\ and grey hatch for the rest of that group
	move	d3,d0			;d0 = middle group count +1 (== total count -1)
	ble.s	.a1_done_last_line	;if only one group on line, the line is complete
	subq	#2,d0			;d0 = dbra count for middle groups
	blt.s	.a1_done_mid_last_line	;if only two groups on line, skip 'middle' groups
.a1_mid_last_line_lp:
	move	d6,(a0)+		;Store grey hatch for all pixels in 'middle' groups
	dbra	d0,.a1_mid_last_line_lp	;loop back for all 'middle' groups of last line
.a1_done_mid_last_line:
	move	right_mask(pc),d5	;mask for affected bits of last 16pix group
	move	d5,d4			;d4 = mask for all affected bits of last group
	and	d6,d5			;d5 = mask to set bits in last group by OR
	not	d4			;d4 = mask for unaffected bits of last group
	or	d6,d4			;d4 = mask to clear bits of last group by AND
	or	d5,(a0)			;\/ Store grey hatch for last group of
	and	d4,(a0)+		;/\ the last affected line
.a1_done_last_line:
	movem.l	(sp)+,d4-d7		;pull some registers
	bra	.exit
;------------------------------------
.atari_2_planes:
	movem.l	d4-d7,-(sp)		;push some registers
	lsl	#2,d0			;d0 = byte offset to plane 0 word of 1st affected pixel
	add	d0,a1			;a1 -> plane 0 word of 1st affected pixel
;-------
	move	#$5555,d6		;d6 = $5555
	btst	#0,4+1(a0)		;final pixel in odd column ?
	bne.s	.a2_grey_mask_ok_1	;if odd, then the grey mask is ok
	not	d6			;d6 = $AAAA
.a2_grey_mask_ok_1:
	tst.l	d2
	bmi.s	.a2_skip_1st_line	;if top edge clipped, go treat 1st line as mid_line
	move	left_mask(pc),d4
	not	d4			;d4 = mask for anding zeroes into 1st 16pix group
	move.l	a1,a0			;a0 -> 1st affected byte on 1st affected line
	and	d4,(a0)+		;\/ Store white codes for affected pixels
	and	d4,(a0)+		;/\ of 1st 16pix group on 1st affected line
	move	d3,d0			;d0 = middle group count +1 (== total count -1)
	ble.s	.a2_done_1st_line	;if only one group on line, the line is complete
	subq	#2,d0			;d0 = dbra count for middle groups
	blt.s	.a2_done_mid_1st_line	;if only two groups on line, skip 'middle' groups
.a2_mid_1st_line_lp:
	clr.l	(a0)+			;\/ Store white codes for all pixels in
;-------				;/\ 'middle' 16pix groups of 1st affected line
	dbra	d0,.a2_mid_1st_line_lp	;loop back for all 'middle' groups of 1st line
.a2_done_mid_1st_line:
	move	right_mask(pc),d4
	not	d4			;d4 = mask for anding zeroes into last 16pix group
	and	d4,(a0)+		;\/ Store white codes for affected pixels
	and	d4,(a0)+		;/\ of last 16pix group on 1st affected line
.a2_done_1st_line:
	move	d3,d1			;d1 = 16pix groups per line -1
	lsl	#2,d1			;d1 = byte offset to plane 0 word of last affected pixel
	dbra	d2,.a2_try_mid_lines	;decrement d2 to lines -2, but don't branch on d2 = -1
	bra	.a2_done_last_line	;the block only had one line, we'd better just exit
;-------
.a2_try_mid_lines:
	add	a2,a1			;a1 -> 1st affected word of next line
.a2_skip_1st_line:
	move	left_bit,d4
	not	d4			;d4 = word value for clearing left bit by AND
	btst	#30,d2			;bottom edge clipped ?
	bne.s	.a2_use_mid_lines	;then treat all remaining lines as 'middle' lines
	dbra	d2,.a2_use_mid_lines	;decrement d2 to remaining lines -3, but don't branch on d2 = -1
	bra.s	.a2_done_mid_lines	;only one line remains, so skip 'middle'
;-------
.a2_use_mid_lines:
	btst	#0,d2			;is (middle_lines - 1) odd ?  (same as middle_lines being even)
	bne.s	.a2_grey_mask_ok_2		;then the grey mask is ok
	not	d6			;invert grey mask (so bottom line fits with middle lines)
.a2_grey_mask_ok_2:
	clr.l	d5			;preclear high bits of d5
	move	right_bit,d5		;d5 = mask for setting right bit by OR on even lines
	move.l	d5,d0
	not.l	d0
	swap	d0			;d0 = mask for clearing right bit by AND on odd lines
.a2_mid_lines_lp:
	lea	(a1),a0			;a0 -> 1st affected word of current line
	and	d4,(a0)+		;\/ Store white code for the 1st
	and	d4,(a0)+		;/\ affected pixel on 'middle' lines
	lea	(a1,d1),a0		;a0 -> 1st word of last affected group on current line
	or	d5,(a0)			; \/ Store black codes for last
	or	d5,2(a0)		; /\ affected pixel on even middle lines
	swap	d5			;alternate OR mask
	and	d0,(a0)+		; \/ Store white codes for last
	and	d0,(a0)			; /\ affected pixel on odd middle lines
	swap	d0			;alternate AND mask
	add	a2,a1			;a1 -> 1st affected word of next line
	dbra	d2,.a2_mid_lines_lp	;loop back for all 'middle' lines
	btst	#30,d2			;bottom edge clipped ?
	bne.s	.a2_done_last_line	;then the last line is already complete
.a2_done_mid_lines:
	move	d4,d0			;d0 = word value for clearing 1st affected pixel
	move	left_mask(pc),d5	;d5 = mask for all affected bits of 1st group
	move	d5,d4			;d4 = mask for all affected bits of 1st group
	and	d6,d5			;d5 = mask to set alternate bits in 1st group by OR
	not	d4			;d4 = mask for unaffected bits of 1st group
	or	d6,d4			;d4 = mask to clear alternate bits of 1st group by AND
	and	d0,d4			;d4 adjusted to always clear 1st valid bit in group too
	move.l	a1,a0			;a0 -> 1st affected byte on last affected line
	or	d5,(a0)			;\
	and	d4,(a0)+		; \/ Store white code for 1st affected pixel
	or	d5,(a0)			; /\ and grey hatch for the rest of that group
	and	d4,(a0)+		;/
	move	d3,d0			;d0 = middle group count +1 (== total count -1)
	ble.s	.a2_done_last_line	;if only one group on line, the line is complete
	subq	#2,d0			;d0 = dbra count for middle groups
	blt.s	.a2_done_mid_last_line	;if only two groups on line, skip 'middle' groups
	move	d6,d1
	swap	d1
	move	d6,d1			;d1 = long holding two identical masks for alternate bits
.a2_mid_last_line_lp:
	move.l	d1,(a0)+		;Store grey hatch for all pixels in 'middle' groups of last line
	dbra	d0,.a2_mid_last_line_lp	;loop back for all 'middle' groups of last line
.a2_done_mid_last_line:
	move	right_mask(pc),d5	;mask for affected bits of last 16pix group
	move	d5,d4			;d4 = mask for all affected bits of last group
	and	d6,d5			;d5 = mask to set bits in last group by OR
	not	d4			;d4 = mask for unaffected bits of last group
	or	d6,d4			;d4 = mask to clear bits of last group by AND
	or	d5,(a0)			;\
	and	d4,(a0)+		; \/ Store grey hatch codes for affected pixels
	or	d5,(a0)			; /\ of last 16pix group on last affected line
	and	d4,(a0)+		;/
.a2_done_last_line:
	movem.l	(sp)+,d4-d7		;pull some registers
	bra	.exit
;------------------------------------
.atari_4_planes:
	movem.l	d4-d7,-(sp)		;push some registers
	lsl	#3,d0			;d0 = byte offset to plane 0 word of 1st affected pixel
	add	d0,a1			;a1 -> plane 0 word of 1st affected pixel
	tst.l	d2
	bmi.s	.a4_skip_1st_line	;if top edge clipped, go treat 1st line as mid_line
	move	left_mask(pc),d5	;d5 = mask for affected bits of 1st 16pix group
	move	d5,d4
	not	d4			;d4 = mask for anding zeroes into 1st 16pix group
	move.l	a1,a0			;a0 -> 1st affected byte on 1st affected line
	and	d4,(a0)+		;\
	and	d4,(a0)+		; \/ Store white codes for affected pixels
	and	d4,(a0)+		; /\ of 1st 16pix group on 1st affected line
	and	d4,(a0)+		;/
	move	d3,d0			;d0 = middle group count +1 (== total count -1)
	ble.s	.a4_done_1st_line	;if only one group on line, the line is complete
	subq	#2,d0			;d0 = dbra count for middle groups
	blt.s	.a4_done_mid_1st_line	;if only two groups on line, skip 'middle' groups
.a4_mid_1st_line_lp:
	clr.l	(a0)+			;\/ Store white codes for all pixels in
	clr.l	(a0)+			;/\ 'middle' 16pix groups of 1st affected line
	dbra	d0,.a4_mid_1st_line_lp	;loop back for all 'middle' groups of 1st line
.a4_done_mid_1st_line:
	move	right_mask(pc),d7	;mask for affected bits of last 16pix group
	move	d7,d6
	not	d6			;d6 = mask for anding zeroes into last 16pix group
	and	d6,(a0)+		;\
	and	d6,(a0)+		; \/ Store white codes for affected pixels
	and	d6,(a0)+		; /\ of last 16pix group on 1st affected line
	and	d6,(a0)+		;/
.a4_done_1st_line:
	move	d3,d1			;d1 = 16pix groups per line -1
	lsl	#3,d1			;d1 = byte offset to plane 0 word of last affected pixel
	dbra	d2,.a4_try_mid_lines	;decrement d2 to lines -2, but don't branch on d2 = -1
	bra.s	.a4_done_last_line	;the block only had one line, we'd better just exit
;-------
.a4_try_mid_lines:
	add	a2,a1			;a1 -> 1st affected word of next line
.a4_skip_1st_line:
	move	left_bit,d5		;d5 = word value of 1st bit in 1st group
	move	d5,d4
	not	d4			;d4 = word value for clearing the same bit by AND
	btst	#30,d2			;bottom edge clipped ?
	bne.s	.a4_use_mid_lines	;then treat all remaining lines as 'middle' lines
	dbra	d2,.a4_use_mid_lines	;decrement d2 to remaining lines -3, but don't branch on d2 = -1
	bra.s	.a4_done_mid_lines	;only one line remains, so skip 'middle'
;-------
.a4_use_mid_lines:
	move	right_bit,d7		;d7 = word value of last bit in last group
	move	d7,d6
	not	d6			;d6 = word value for clearing the same bit by AND
.a4_mid_lines_lp:
	lea	(a1),a0			;a0 -> 1st affected word of current line
	and	d4,(a0)+		;\
	and	d4,(a0)+		; \/ Store white code for the 1st
	and	d4,(a0)+		; /\ affected pixel on 'middle' lines
	and	d4,(a0)			;/
	lea	(a1,d1),a0		;a0 -> 1st word of last affected group on current line
	and	d6,(a0)+		;\
	and	d6,(a0)+		; \/ Store grey code for the last
	and	d6,(a0)+		; /\ affected pixel on 'middle' lines
	or	d7,(a0)			;/
	add	a2,a1			;a1 -> 1st affected word of next line
	dbra	d2,.a4_mid_lines_lp	;loop back for all 'middle' lines
	btst	#30,d2			;bottom edge clipped ?
	bne.s	.a4_done_last_line	;then the last line is already complete
.a4_done_mid_lines:
	move	d4,d0			;d0 = word value for clearing 1st affected pixel
	move	left_mask(pc),d5	;d5 = mask for affected bits of 1st group
	move	d5,d4
	not	d4			;d4 = mask for anding zeroes into 1st 16pix group
	move.l	a1,a0			;a0 -> 1st affected byte on last affected line
	and	d4,(a0)+		;\
	and	d4,(a0)+		; \/ Store grey codes for affected pixels
	and	d4,(a0)+		; /\ of 1st 16pix group on last affected line
	or	d5,(a0)			;/
	and	d0,(a0)+		;change code for 1st pixel to white
	move	d3,d0			;d0 = middle group count +1 (== total count -1)
	ble.s	.a4_done_last_line	;if only one group on line, the line is complete
	subq	#2,d0			;d0 = dbra count for middle groups
	blt.s	.a4_done_mid_last_line	;if only two groups on line, skip 'middle' groups
	moveq	#-1,d1			;d1 = $FFFF
.a4_mid_last_line_lp:
	clr.l	(a0)+			;\ / Store grey codes for all pixels
	clr	(a0)+			; X  in the 'middle' 16pix groups of
	move	d1,(a0)+		;/ \ the last affected line
	dbra	d0,.a4_mid_last_line_lp	;loop back for all 'middle' groups of last line
.a4_done_mid_last_line:
	move	right_mask(pc),d7	;mask for affected bits of last 16pix group
	move	d7,d6
	not	d6			;d6 = mask for anding zeroes into last 16pix group
	and	d6,(a0)+		;\
	and	d6,(a0)+		; \/ Store grey codes for affected pixels
	and	d6,(a0)+		; /\ of last 16pix group on last affected line
	or	d7,(a0)+		;/
.a4_done_last_line:
	movem.l	(sp)+,d4-d7		;pull some registers
	bra	.exit
;------------------------------------
.atari_8_planes:
	movem.l	d4-d7,-(sp)		;push some registers
	lsl	#4,d0			;d0 = byte offset to plane 0 word of 1st affected pixel
	add	d0,a1			;a1 -> plane 0 word of 1st affected pixel
;-------
	tst.l	d2
	bmi.s	.a8_skip_1st_line	;if top edge clipped, go treat 1st line as mid_line
	move	left_mask(pc),d5	;d5 = mask for affected bits of 1st 16pix group
	move	d5,d4
	not	d4			;d4 = mask for anding zeroes into 1st 16pix group
;-------
	move.l	a1,a0			;a0 -> 1st affected byte on 1st affected line
	and	d4,(a0)+		;\
	and	d4,(a0)+		; \
	and	d4,(a0)+		;  \
	and	d4,(a0)+		;   \/ Store white codes for affected pixels
	and	d4,(a0)+		;   /\ of 1st 16pix group on 1st affected line
	and	d4,(a0)+		;  /
	and	d4,(a0)+		; /
	and	d4,(a0)+		;/
;-------
	move	d3,d0			;d0 = middle group count +1 (== total count -1)
	ble.s	.a8_done_1st_line	;if only one group on line, the line is complete
	subq	#2,d0			;d0 = dbra count for middle groups
	blt.s	.a8_done_mid_1st_line	;if only two groups on line, skip 'middle' groups
.a8_mid_1st_line_lp:
	clr.l	(a0)+			;\
	clr.l	(a0)+			; \/ Store white codes for all pixels in
	clr.l	(a0)+			; /\ 'middle' 16pix groups of 1st affected line
	clr.l	(a0)+			;/
	dbra	d0,.a8_mid_1st_line_lp	;loop back for all 'middle' groups of 1st line
.a8_done_mid_1st_line:
	move	right_mask(pc),d7	;mask for affected bits of last 16pix group
	move	d7,d6
	not	d6			;d6 = mask for anding zeroes into last 16pix group
	and	d6,(a0)+		;\
	and	d6,(a0)+		; \
	and	d6,(a0)+		;  \
	and	d6,(a0)+		;   \/ Store white codes for affected pixels
	and	d6,(a0)+		;   /\ of last 16pix group on 1st affected line
	and	d6,(a0)+		;  /
	and	d6,(a0)+		; /
	and	d6,(a0)+		;/
.a8_done_1st_line:
	move	d3,d1			;d1 = 16pix groups per line -1
	lsl	#4,d1			;d1 = byte offset to plane 0 word of last affected pixel
	dbra	d2,.a8_try_mid_lines	;decrement d2 to lines -2, but don't branch on d2 = -1
	bra	.a8_done_last_line	;the block only had one line, we'd better just exit
;-------
.a8_try_mid_lines:
	add	a2,a1			;a1 -> 1st affected word of next line
.a8_skip_1st_line:
	move	left_bit,d5		;d5 = word value of 1st bit in 1st group
	move	d5,d4
	not	d4			;d4 = word value for clearing the same bit by AND
	btst	#30,d2			;bottom edge clipped ?
	bne.s	.a8_use_mid_lines	;then treat all remaining lines as 'middle' lines
	dbra	d2,.a8_use_mid_lines	;decrement d2 to remaining lines -3, but don't branch on d2 = -1
	bra.s	.a8_done_mid_lines	;only one line remains, so skip 'middle'
;-------
.a8_use_mid_lines:
	move	right_bit,d7		;d7 = word value of last bit in last group
	move	d7,d6
	not	d6			;d6 = word value for clearing the same bit by AND
.a8_mid_lines_lp:
	lea	(a1),a0			;a0 -> 1st affected word of current line
	and	d4,(a0)+		;\
	and	d4,(a0)+		; \
	and	d4,(a0)+		;  \
	and	d4,(a0)+		;   \/ Store white code for the 1st
	and	d4,(a0)+		;   /\ affected pixel on 'middle' lines
	and	d4,(a0)+		;  /
	and	d4,(a0)+		; /
	and	d4,(a0)			;/
	lea	(a1,d1),a0		;a0 -> 1st word of last affected group on current line
	and	d6,(a0)+		;\
	and	d6,(a0)+		; \
	and	d6,(a0)+		;  \
	or	d7,(a0)+		;   \/ Store grey code for the last
	and	d6,(a0)+		;   /\ affected pixel on 'middle' lines
	and	d6,(a0)+		;  /
	and	d6,(a0)+		; /
	and	d6,(a0)			;/
	add	a2,a1			;a1 -> 1st affected word of next line
	dbra	d2,.a8_mid_lines_lp	;loop back for all 'middle' lines
	btst	#30,d2			;bottom edge clipped ?
	bne.s	.a8_done_last_line	;then the last line is already complete
.a8_done_mid_lines:
	move	d4,d0			;d0 = word value for clearing 1st affected pixel
	move	left_mask(pc),d5	;d5 = mask for affected bits of 1st group
	move	d5,d4
	not	d4			;d4 = mask for anding zeroes into 1st 16pix group
	move.l	a1,a0			;a0 -> 1st affected byte on last affected line
	and	d4,(a0)+		;\
	and	d4,(a0)+		; \
	and	d4,(a0)+		;  \
	or	d5,(a0)+		;   \/ Store grey codes for affected pixels
	and	d4,(a0)+		;   /\ of 1st 16pix group on 1st affected line
	and	d4,(a0)+		;  /
	and	d4,(a0)+		; /
	and	d4,(a0)+		;/
	and	d0,-10(a0)		;change code for 1st pixel to white
	move	d3,d0			;d0 = middle group count +1 (== total count -1)
	ble.s	.a8_done_last_line	;if only one group on line, the line is complete
	subq	#2,d0			;d0 = dbra count for middle groups
	blt.s	.a8_done_mid_last_line	;if only two groups on line, skip 'middle' groups
	moveq	#-1,d1			;d1 = $FFFF
.a8_mid_last_line_lp:
	clr.l	(a0)+			;\
	clr	(a0)+			; \ / Store grey codes for all pixels
	move	d1,(a0)+		;  X  in the 'middle' 16pix groups of
	clr.l	(a0)+			; / \ the last affected line
	clr.l	(a0)+			;/
	dbra	d0,.a8_mid_last_line_lp	;loop back for all 'middle' groups of last line
.a8_done_mid_last_line:
	move	right_mask(pc),d7	;mask for affected bits of last 16pix group
	move	d7,d6
	not	d6			;d6 = mask for anding zeroes into last 16pix group
	and	d6,(a0)+		;\
	and	d6,(a0)+		; \
	and	d6,(a0)+		;  \
	or	d7,(a0)+		;   \/ Store grey codes for affected pixels
	and	d6,(a0)+		;   /\ of last 16pix group on last affected line
	and	d6,(a0)+		;  /
	and	d6,(a0)+		; /
	and	d6,(a0)+		;/
.a8_done_last_line:
	movem.l	(sp)+,d4-d7		;pull some registers
	bra	.exit
;------------------------------------
.nova_3D:
	move	(a0),d0			;d0 = x0
	cmp	#8,LA_planes_p.l	;8 planes ?
	patch	(*-4)
	bhi.s	.nova_16_planes		;if larger, go assume 16 bit truecolour
	beq.s	.nova_8_planes		;if 8 planes go render them below
	cmp	#2,LA_planes_p.l	;2 planes ?
	patch	(*-4)
	blo	.nova_1_plane		;if less, go render single plane further above
	bra	.exit			;2-4 nova planes are not yet supported, so exit
;------------------------------------
.nova_8_planes:
	movem.l	d4-d5,-(sp)		;push some registers
	add	d0,a1			;a1 -> first affected byte on 1st affected line
;-------
	tst.l	d2
	bmi.s	.n8_skip_1st_line	;if top edge clipped, go treat 1st line as mid_line
	move.l	a1,a0			;a0 -> first affected byte on 1st affected line
	move	d3,d0			;d0 = affected columns -1
.n8_mid_1st_line_lp:
	sf	(a0)+			;store white code in bytes on 1st line
	dbra	d0,.n8_mid_1st_line_lp	;loop back for all affected pixels on 1st line
.n8_done_1st_line:
	dbra	d2,.n8_try_mid_lines	;decrement d2 to lines -2, but don't branch on d2 = -1
	bra.s	.n8_done_last_line	;the block only had one line, we'd better just exit
;-------
.n8_try_mid_lines:
	add	a2,a1			;a1 -> first affected byte on next line
.n8_skip_1st_line:
	btst	#30,d2			;bottom edge clipped ?
	bne.s	.n8_use_mid_lines	;then treat all remaining lines as 'middle' lines
	dbra	d2,.n8_use_mid_lines	;decrement d2 to remaining lines -2, but don't branch on d2 = -1
	bra.s	.n8_done_mid_lines	;only one line remains, so skip 'middle'
;-------
.n8_use_mid_lines:
	clr	d4			;d4 = mask for ANDing zero to 1st pixel (for white)
	tst.l	d3			;left edge clipped ?
	bpl.s	.n8_left_mask_ok	;if not clipped, the left mask is ok
	moveq	#-1,d4			;d4 = mask to not affect 1st pixel by ANDing
.n8_left_mask_ok:
	moveq	#8,d0			;d0 = mask for ANDing zeroes of grey code to last pixel
	move	d0,d5			;d5 = mask for ORing ones of of grey code to last pixel
	btst	#30,d3			;right edge clipped ?
	beq.s	.n8_right_masks_ok	;if not clipped, the right masks are ok
	moveq	#-1,d0			;d0 = mask to not affect last pixel by ANDing
	clr	d5			;d5 = mask to not affect last pixel by ORing
.n8_right_masks_ok:
.n8_mid_lines_lp:
	and.b	d4,(a1)			;store white code for 1st affected pixel on line unless clipped
	and.b	d0,(a1,d3)		;copy bits==0 of grey code to last pixel \/ Unless
	or.b	d5,(a1,d3)		;copy bits==1 of grey code to last pixel /\ clipped
	add	a2,a1			;a1 -> first affected byte on next line
	dbra	d2,.n8_mid_lines_lp	;loop back for all 'middle' lines
	btst	#30,d2			;bottom edge clipped ?
	bne.s	.n8_done_last_line	;then the last line is already complete
.n8_done_mid_lines:
	move	d3,d0			;d0 = affected columns -1
	tst.l	d3			;left edge clipped ?
	bmi.s	.n8_mid_last_line_lp	;if clipped, go treat leftmost pixel as 'middle' pixels
	sf	(a1)+			;store white code for leftmost pixel if left edge unclipped
	bra.s	.n8_next_on_last_line	;go handle remaining pixels
;
.n8_mid_last_line_lp:
	move.b	#8,(a1)+		;store grey code for remaining pixels on last line
.n8_next_on_last_line:
	dbra	d0,.n8_mid_last_line_lp	;loop back for all affected pixels on last line
.n8_done_last_line
	movem.l	(sp)+,d4-d5		;pull some registers
	bra.s	.exit
;------------------------------------
.nova_16_planes:
	movem.l	d4-d5,-(sp)		;push some registers
	add	d0,a1
	add	d0,a1			; premier pixel!
;-------
	tst.l	d2
	bmi.s	.n16_skip_1st_line	;if top edge clipped, go treat 1st line as mid_line
	move.l	a1,a0			; premiere ligne
	move	d3,d0
	moveq	#-1,d1			;d1 = $FFFF, white NOVA TC word
.n16_mid_1st_line_lp:
	move	d1,(a0)+		;store white NOVA TC word
	dbra	d0,.n16_mid_1st_line_lp	;loop back for all affected pixels on 1st line
.n16_done_1st_line:
	dbra	d2,.n16_try_mid_lines	;decrement d2 to lines -2, but don't branch on d2 = -1
	bra.s	.n16_done_last_line	;the block only had one line, we'd better just exit
;-------
.n16_try_mid_lines:
	add	a2,a1			;a1 -> first affected byte on next line
.n16_skip_1st_line:
	btst	#30,d2			;bottom edge clipped ?
	bne.s	.n16_use_mid_lines	;then treat all remaining lines as 'middle' lines
	dbra	d2,.n16_use_mid_lines	;decrement d2 to remaining lines -2, but don't branch on d2 = -1
	bra.s	.n16_done_mid_lines	;only one line remains, so skip 'middle'
;-------
.n16_use_mid_lines:
	moveq	#-1,d4			;d4 = mask for ORing ones to 1st pixel (for white)
	tst.l	d3			;left edge clipped ?
	bpl.s	.n16_left_mask_ok	;if not clipped, the left mask is ok
	moveq	#0,d4			;d4 = mask to not affect 1st pixel by ORing
.n16_left_mask_ok:
	move	#NOVA_GREY,d0		;d0 = mask for ANDing zeroes of grey code to last pixel
	move	d0,d5			;d5 = mask for ORing ones of of grey code to last pixel
	btst	#30,d3			;right edge clipped ?
	beq.s	.n16_right_masks_ok	;if not clipped, the right masks are ok
	moveq	#-1,d0			;d0 = mask to not affect last pixel by ANDing
	clr	d5			;d5 = mask to not affect last pixel by ORing
.n16_right_masks_ok:
	move	d3,d1
	add	d1,d1			;d0 = byte offset to last affected pixel on lines
.n16_mid_lines_lp:
	or	d4,(a1)			;store white code for 1st affected pixel on line unless clipped
	and	d0,(a1,d1)		;copy bits==0 of grey code to last pixel \/ Unless
	or	d5,(a1,d3)		;copy bits==1 of grey code to last pixel /\ clipped
	add	a2,a1			;a1 -> first affected byte on next line
	dbra	d2,.n16_mid_lines_lp	;loop back for all 'middle' lines
	btst	#30,d2			;bottom edge clipped ?
	bne.s	.n16_done_last_line	;then the last line is already complete
.n16_done_mid_lines:
	move	#NOVA_GREY,d1
	move	d3,d0			;d0 = affected columns -1
	tst.l	d3			;left edge clipped ?
	bmi.s	.n16_mid_last_line_lp	;if clipped, go treat leftmost pixel as 'middle' pixels
	move	#-1,(a1)+		;store white code for leftmost pixel if left edge unclipped
	bra.s	.n16_next_on_last_line	;go handle remaining pixels
;
.n16_mid_last_line_lp:
	move	d1,(a1)+		;store white NOVA TC word
.n16_next_on_last_line:
	dbra	d0,.n16_mid_last_line_lp	;loop back for all affected pixels on last line
.n16_done_last_line
	movem.l	(sp)+,d4-d5		;pull some registers
.exit:
	movem.l	(sp)+,d2/d3
	rts
;----------------------------------------------------------------------------
;'cmp_v_gtext_str' arguments:
;------------------------------------
;a0 -> normal C-style string of character bytes
;a1 -> v_gtext-style string of character words
;d0 -> character count for the v_gtext-style string
;------------------------------------
cmp_v_gtext_str:
	move.l	a1,d2		;save a1 in d2
	move	d0,d3		;d3 = character count
	subq	#1,d3		;d3 = adapted for 'dbne' looping
.loop:
	move	(a1)+,d1	;d1 = v_gtext-style string character word
	cmp.b	(a0)+,d1	;does it differ from corresponding byte in C-style string ?
	dbne	d3,.loop	;loop back to test whole v_gtext string, but break on diffs
	bne.s	.diff		;if strings differ, go return NE to caller
	move.l	d2,a1		;restore entry a1 from d2
	moveq	#0,d1		;EQ flags string equality
	rts			;return to caller
;-------
.diff:
	move.l	d2,a1		;restore entry a1 from d2
	moveq	#-1,d1		;NE flags string difference
	rts			;return to caller
;----------------------------------------------------------------------------
;End of:	3D subs from G.Tello 1998.10.07 revised for my patch methods
;----------------------------------------------------------------------------
;Start of:	XBRA linked BIOS dispatcher
;----------------------------------------------------------------------------
	XGEM_BIOS_define	nu_BIOS,'CoIc'
	move.l	nu_BIOS+xb_next(pc),a0	;\/ use older bios dispatcher
	jmp	(a0)			;/\
;----------------------------------------------------------------------------
patch_XGEM_sub:			;uses d0/a0/a1
	tst	XGEM_2_use_f		;is XGEM_2 to be used yet
	bmi.s	patch_XGEM		;if so, skip XGEM_1 tests
	lea	(ev_xgem).w,a0		;a0 -> XGEM root
	lea	nu_XGEM_1(pc),a1	;a1 -> XGEM_1
	XB_seek_code
	bpl.s	patch_XGEM
	lea	nu_XGEM_2(pc),a1	;a1 -> XGEM_2
	move.l	a1,XGEM_wanted_p	;XGEM_2 is what we now want to use
	st	XGEM_2_use_f		;And we make sure to remember this
patch_XGEM:
	XGEM_patch	XGEM_linked_p,XGEM_wanted_p
	rts
;----------------------------------------------------------------------------
;End of:	XBRA linked BIOS dispatcher
;----------------------------------------------------------------------------
;Start of:	XBRA linked XGEM dispatcher
;----------------------------------------------------------------------------
	XGEM_code	XGEM_1		;code for primary XGEM link
;----------------------------------------------------------------------------
	XGEM_code	XGEM_2		;code for secondary XGEM link
;----------------------------------------------------------------------------
;End of:	XBRA linked XGEM dispatcher
;----------------------------------------------------------------------------
mfdb:	dc.l	0			; mon mfdb couleur
	dc.w	32,32,2,0
plans:	dc.w	4,0,0,0	; 32x32 en 4 plans
;----------------------------------------------------------------------------
;I changed 'adapt_icone' below to not preserve d0, because it is cheaper
;(time & space) to do it as part of 'movem' needed in dispatcher anyway.
;
adapt_icone:
	move	LA_planes_p.l,d0	;d0 = planes
	patch	(*-4)
	move	d0,plans		; pour le mfdb
	cmp	p_actu,d0		; mˆme plans
	bne.s	.adapt			; non, donn‚es non valides
	cmp.l	adr_actu,a1		; mˆme adresse?
	bne.s	.adapt			; non, donn‚es non valides
	rts				; sinon, tout est bon!
;------------------------------------
.adapt:
	move.l	a1,adr_actu
	move	d0,p_actu		; la nouvelle icone
	lea	une_icone,a0		; l… ou vont les donn‚es
	cmp	#4,d0
	beq.s	prendre4
	cmp	#8,d0
	beq.s	prendre8
	cmp	#16,d0
	beq	prendre16
;------------------------------------
prendre4:
	tst.b	nova
	bne.s	.nova
	moveq	#63,d0			; 64 * 4 mots = 512 octets
.lb1:
	move	(a1),(a0)+
	move	128(a1),(a0)+
	move	256(a1),(a0)+
	move	384(a1),(a0)+		; TT sans carte, mˆler les 4 plans!
	addq	#2,a1
	dbra	d0,.lb1
	rts
;------------------------------------
.nova:					; TT avec carte, meme codage!
	moveq	#127,d0			; 128 mots longs = 512 octets
.lb0:
	move.l	(a1)+,(a0)+		; copie les donn‚es
	dbra	d0,.lb0
	rts
;------------------------------------
prendre8:
	tst.b	nova
	bne.s	.nova
	moveq	#63,d0			; 64 * 4 mots = 512 octets
.lb7:
	move	(a1),(a0)+
	move	128(a1),(a0)+
	move	256(a1),(a0)+
	move	384(a1),(a0)+		; TT sans carte, mˆler les 4 plans!
	clr.l	(a0)+
	clr.l	(a0)+			; plus 4 plans vides! (les plus signifiants)
	addq	#2,a1
	dbra	d0,.lb7
	rts
;------------------------------------
.nova:
	movem.l	d1-d5,-(sp)
	moveq	#31,d4			; pour les 32 lignes
.lb0:
	swap	d4			; TT avec carte, plus de plans, 1 point=1 octet!
	move.l	(a1),d0
	move.l	128(a1),d1
	move.l	256(a1),d2
	move.l	384(a1),d3
	moveq	#31,d5			; pour les 32 points par ligne
.lb1:
	clr	d4
	roxl.l	d3
	roxl.b	d4
	roxl.l	d2
	roxl.b	d4
	roxl.l	d1
	roxl.b	d4
	roxl.l	d0
	roxl.b	d4
	cmp.b	#15,d4
	bne.s	.lb6
	st d4				; le 1 devient 255
.lb6:
	move.b	d4,(a0)+
	dbra	d5,.lb1			; autre point sur la mˆme ligne
	swap	d4
	addq	#4,a1			; ligne suivante
	dbra	d4,.lb0
	movem.l	(sp)+,d1-d5
	rts
;------------------------------------
prendre16:
	movem.l	d1-d5,-(sp)
	lea	.table,a2		; conversions en 16 bits
	moveq	#31,d4			; pour les 32 lignes de l'icone
.lb0:
	swap	d4			; l'autre mot de d4 est utilis‚ ici
	move.l	(a1),d0			; d0-d3 contienent les 4 bits de 32 points
	move.l	128(a1),d1
	move.l	256(a1),d2
	move.l	384(a1),d3
	moveq	#31,d5			; pour les 32 points par ligne
.lb1:
	clr	d4
	roxl.l	d3
	roxl.b	d4
	roxl.l	d2
	roxl.b	d4
	roxl.l	d1
	roxl.b	d4
	roxl.l	d0
	roxl.b	d4
	add	d4,d4
	move.w	0(a2,d4),(a0)+
	dbra	d5,.lb1			; autre point sur la mˆme ligne
	swap	d4
	addq.l	#4,a1			; ligne suivante
	dbra	d4,.lb0
	movem.l	(sp)+,d1-d5
	rts
;------------------------------------
.table:		dc.w $ff7f,$007c,$e003,$e07f,$1f00,$1f7c,$ff03,$f75e
		dc.w $1042,$107e,$f043,$f07f,$1f42,$1f7e,$ff43,$0000
;----------------------------------------------------------------------------
; L'AES dessine toutes ses icones … travers la fonction VDI vrt_cpyfm(121).
; Pour ˆtre certain que c'est l'AES qui appelle (et non un programme
; utilisateur), il suffit de v‚rifier que le MFDB source se situe en $E5CC.
; maintenant il faut distinguer l'icone alerte, l'icone bureau et le masque
; d'icone bureau.
; icone ALERTE:
;	l'AES a auparavant pr‚par‚ une structure BITBLK en $8E16 dont l'adresse
;	des donn‚es doit correspondre … celle du mfdb. On v‚rifie en plus que
;	les donn‚es sont bien celles des alertes (en $949A se trouve un pointeur
;	sur une zone contenant les icones d'alertes … l'offset 2156: 3 paquets
;	de 128 octets.) On peut imaginer ajouter des icones alertes car form_alert
;	ne plante pas avec un index sup‚rieur … trois, cette fonction se contente
;	d'afficher ce qui suit en m‚moire, c'est … dire une icone souris!.
;	Si tout concorde, on change alors la couleur (1 NOIR devient 4 BLEU).
; icone BUREAU:
;	l'AES a auparavant pr‚par‚ une structure ICONBLK en $8DF4 dont l'adresse
;	des donn‚es (en $8DF4+4) doit correspondre au mfdb. On v‚rifie en plus
;	que ce sont bien des donn‚es d'icones du bureau (en $9400 se trouve un pointeur sur
;	le DESKICON.RSC en m‚moire. Ceci nous donne ‚galement l'index de l'icone
;	dans ressource pour l'aiguillage correct vers nos donn‚es). Si tout concorde,
;	on change alors vrt_cpyfm en vro_cpyfm (copie couleur), mode NOT (S XOR D).
; masque BUREAU:
;	mˆme systŠme que pour les donn‚es (pour la d‚tection on se sert de
;	l'adresse du masque en $8DF4), pour l'aiguillage c'est la mˆme proc‚dure
;	et on v‚rifie que le masque n'est pas utilis‚ pour l'inversion (lors
;	de la s‚lection). Pour le dessin normal intin vaut 2(mode) 0(coul) 1(fond)
;	et pour l'inversion intin vaut 2 1(coul) 0(fond), dans ce cas on
;	n'ex‚cute pas la copie (c'est moche). Seul le nom sous l'icone devrait
;	ˆtre invers‚.
;----------------------------------------------------------------------------
mt:	dc.b	0		; pas de multitos (… priori), FF si pr‚sent
nova:	dc.b	0		; ni de carte NOVA, FF si pr‚sente
	even
;----------------------------------------------------------------------------
init:
	move.l	4(a7),a5		;a5 -> basepage
	lea	stack_top,sp		;sp -> local stack top
	move.l	bp_bss_beg_p(a5),d0	;d0 -> BSS start
	add.l	bp_bss_len(a5),d0	;d0 -> BSS end
	sub.l	a5,d0			;d0 =  program RAM size excl basepage
	add.l	#$100,d0		;d0 =  program RAM size incl basepage
	gemdos	Mshrink,!,(a5),d0	;return unneeded RAM to system
;-------
	xbios	Supexec,check_cookies(pc)	;test for various cookies
	tst.b	mt
	bne	quitter			; multitos!, pas de couleur … mettre!
;-------
	gemdos	Cconws,titre(pc)	; affiche COLOR TT et mon nom
;-------
	xbios	Supexec,install_vector(pc)	; va d‚tourner l'AES/VDI
	tst.l	d0
	bne	quitter
;-------
	gemdos	Fopen,nom(pc),!		;open file C:\DESKCICN.RSC
	move	d0,d7
	gemdos	  Fread,d7,#max_file,filebase	;Read RSC file into RAM (most is reused later)
	gemdos	Fclose,d7		;close file
;-------
	lea	zone,a0			;a0 -> space for icon mask array
	lea	filebase,a2		;a2 -> DESKCICN.RSC
	move	20(a2),d7		;d7 =  number of objects
	subq	#1,d7			;d7 =  number of icons (inside the BOX)
	move	d7,ni			;store icon count
	move	d7,d6
	muls	#256,d6			;d6 = space needed for icon masks
;The factor above used to be 128, before I added support for animated icons
	lea	0(a0,d6.l),a1		;a1 -> space for main icon array
	move.l	a1,data_ptr		;store ptr to main icon array
	add.w	34(a2),a2				; vers l'extension
;There used to be some non-68000 code here, but I changed it (as below)
	lea	filebase+4,a3
	add	d7,a3
	add	d7,a3
	add	d7,a3
	add	d7,a3
	add.l	4(a2),a3
	move.l	a3,a2			;a2 -> structure start
.have_struct:
	subq	#1,d7			;d7 = dbra-adapted icon count
;-------
icon_loop:
	lea	306(a2),a2		; saute l'icone monochrome
.loop:
	move	(a2),d6
	cmp	#4,d6			;d6 = 4 planes for the icon ?
	bne.s	.skip_copy		;if not, skip this one
	bsr	copy_icon		;copy the main icon data
	addq	#1,d6			;d6 += one plane for the mask
	cmp.l	#1,10(a2)		;flag for selected icon ?
	bne.s	.sim_selected		;if not, go simulate one
.get_selected:
	bsr	copy_selected		;copy selected icon
	add	d6,d6			;double offset of next icon in file
	bra.s	.done_selected
;
.sim_selected:
	bsr	copy_inv_icon		;create selected icon (inverted)
	bra.s	.done_selected
;
.skip_copy:
	addq	#1,d6			;d6 += one plane for the mask
	cmp.l	#1,10(a2)		;flag for selected icon ?
	bne.s	.done_selected		;if not, all is well
	add	d6,d6			;double offset of next icon in file
.done_selected:
	move	18(a2),d0		;d0 = flag for 'other resolution'
	muls	#128,d6			;d6 = scale offset of next icon to bytes
	lea	22(a2,d6.l),a2		;a2 -> next icon in file
	tst	d0			;is that 'other resolution' for same icon
	bne.s	.loop			;if so, then loop back
	dbra	d7,icon_loop		;loop back to copy more icons
;-------
	move.l	a1,data_end		;store ptr to end limit of icon array
	sub.l	#debut,a1		;a1 = size from program start to that limit
	add.w	#$100,a1		;a1 +=  basepage size  (== total size needed)
;-------
	gemdos	Ptermres,a1,!		; PTERMRES (r‚sident!), taille … conserver
;------------------------------------
quitter:
	gemdos	Pterm0
;----------------------------------------------------------------------------
install_vector:
	move.l	(_sysbase).w,a0		;a0 -> TOS header (possibly a copy)
	move.l	os_selfbeg_p(a0),a0	;a0 -> TOS header (the original)
	move	os_version(a0),d0	;d0 =  TOS version code from header
	lea	TOS_var_ID_t(pc),a1	;a1 -> ID table of supported TOS
	move.l	a1,a2			;a2 -> ID table of supported TOS
.ID_TOS_loop:
	movem	(a1)+,d1/d2		;d1/d2 = version_code/table_offset
	tst	d1			;end of ID_table
	beq	.unknown_TOS		;give up at end, such TOS are unknown
	cmp	d1,d0			;found supported TOS ?
	bne.s	.ID_TOS_loop		;if not, loop back for more tests
	lea	(a2,d2),a1		;a1 -> TOS variable table of found TOS
	lea	TOS_var_act_t(pc),a2	;a2 -> TOS variable table for activation
	moveq	#(TOS_var_act_end-TOS_var_act_t)/4-1,d1	;d1 = dbra counter for longs
.init_TOS_var_loop:
	move.l	(a1)+,(a2)+		;copy each TOS dependent variable ptr
	dbra	d1,.init_TOS_var_loop
;-------
;Here we check for RAM-relocated AES, so as to allow 3D support to function with
;some TOS patchers (GEMRAM, WINX, SHBUF) as well as RAM-based TOS versions.
;-------
	move.l	(_sysbase).w,a0		;a0 -> TOS header (possibly in RAM)
	move.l	os_selfbeg_p(a0),a1	;a1 -> TOS header (normally in ROM)
	move.l	os_gem_mpb_p(a0),a0	;a0 -> gem_mpb according to RAM
	move.l	os_gem_mpb_p(a1),a1	;a0 -> gem_mpb according to ROM
	move.l	a0,d0			;test RAM derived pointer
	ble.s	.done_AES_reloc		;if negative or NULL, skip it
	btst	#0,d0			;test bit 0 of RAM derived pointer
	bne.s	.done_AES_reloc		;if pointer odd, skip it
	cmp.l	#$87654321,(a0)		;is RAM derived gem_mpb valid ?
	bne.s	.done_AES_reloc		;if not, skip it
	move.l	8(a1),d1		;d1 = ROM derived AES start adr
	move.l	8(a0),d0		;d0 = RAM derived AES start adr
	ble.s	.done_AES_reloc		;if that is negative or NULL, skip it
	btst	#0,d0			;test bit 0 of RAM derived address
	bne.s	.done_AES_reloc		;if that address is odd, skip it
	move.l	AES_start_adr_p(pc),d2	;d2 = known standard vector or NULL
	bne.s	.relocate_AES_ptrs	;if not NULL, we use it to relocate safely
	move.l	d1,d2			;else try using ROM derived address
;NB: The last is an emergency solution...  Works for GEMRAM, but not for Atari RAM TOS
	sub.l	#$E00000,d1		;check if it is below ROM base (unusable)
	blo.s	.abort_AES_reloc	;if so, abort relocation AND 3D support
	cmp.l	#$080000,d1		;check if it is above max ROM address (unusable)
	blo.s	.relocate_AES_ptrs	;if not, we can use it to relocate safely
.abort_AES_reloc:
	clr.l	AES_3Drecfl_ret_p	;\/ NULL both pointers that need relocation
	clr.l	AES_3Dgtext_ret_p	;/\ we can't accomplish at this time.
	bra.s	.done_AES_reloc		;then skip it
;
.relocate_AES_ptrs:
	move.l	d0,AES_start_adr_p	;Accept RAM derived AES start adr as real one
	sub.l	d2,d0			;d0 = RAM derived adr - reference adr
	add.l	d0,AES_3Drecfl_ret_p	;\/ Relocate both of the pointers
	add.l	d0,AES_3Dgtext_ret_p	;/\ that need it
.done_AES_reloc:
;-------
;Here TOS_var_act_t is complete, so patching of TOS references can follow,
;but first we add some non-TOS patch vectors, since they are needed for some
;other reference patches performed by the same loop (further below).
;-------
	dc.w	$A000			; line-A init function
	move.l	d0,a2			;a2 -> line_a variable base
	move.l	a2,line_a_base_p	;store -> line_a base (same as LA_planes_p)
	lea	la_bytes_lin(a2),a0
	move.l	a0,LA_bytes_lin_p	;store -> la_bytes_lin
	lea	la_v_rez_vt(a2),a0
	move.l	a0,LA_v_rez_vt_p	;store -> la_v_rez_vt
	lea	la_v_rez_hz(a2),a0
	move.l	a0,LA_v_rez_hz_p	;store -> la_v_rez_hz
;-------
	clr	AES_3D_support_f	;assume that 3D support vectors are missing
	tst.l	AES_actwnd_id_p		;valid -> AES active window id variable ?
	beq.s	.done_AES_3D_support_f	;if not, assumed lack of support is correct
	tst.l	AES_wind_parm_t_p	;valid -> table of AES window parameter structs ?
	beq.s	.done_AES_3D_support_f	;if not, assumed lack of support is correct
	tst.l	AES_3Drecfl_ret_p	;valid -> AES code ret adr for frame rectangles ?
	beq.s	.done_AES_3D_support_f	;if not, assumed lack of support is correct
	tst.l	AES_3Dgtext_ret_p	;valid -> AES code ret adr for frame gadgets ?
	beq.s	.done_AES_3D_support_f	;if not, assumed lack of support is correct
	st	AES_3D_support_f	;Hooray! All 4 3D support vectors are valid
.done_AES_3D_support_f:
;-------
	move.l	.move_pre_6_frame_retadr_a0(pc),move_preframe_retadr_a0	;fix for 6 bytes
	tst	(_longframe).w		;8byte stack frames ?  (else 6)
	beq.s	.done_frame_fix		;else go use 6 byte fix
	move.l	.move_pre_8_frame_retadr_a0(pc),move_preframe_retadr_a0	;fix for 8 bytes
	bra.s	.done_frame_fix		;go use 8 byte fix
;-------
;The two opcodes below are only used as data for the fixing above
;-------
.move_pre_6_frame_retadr_a0:		;opcode => a0 = long above 6 byte frame at (sp)
	move.l	6(sp),a0
.move_pre_8_frame_retadr_a0:		;opcode => a0 = long above 8 byte frame at (sp)
	move.l	8(sp),a0
;-------
.done_frame_fix:
;-------
;Here the entire list of patch vectors is complete, starting with the TOS
;dependent ones at TOS_var_act_t, followed by non-TOS vectors at TOS_var_act_end.
;References to all these vectors are patched in the loop below, so as to cause
;no further runtime delays thereafter.
;-------
	lea	ptr_patch_t(pc),a3	;a3 -> pointer reference patch table
.ptr_patch_loop:
	move.l	(a3)+,d0		;d0 -> location for patch, or is NULL
	beq.s	.done_ptr_patch		;if d0 is NULL patching is complete
	move.l	d0,a2			;a2 -> location for patch
	move.l	(a2),a1			;a1 -> variable pointer of patch
	move.l	(a1),(a2)		;code is patched to use active pointer
	bra.s	.ptr_patch_loop		;loop back to fix all patches
;
.unknown_TOS:
	moveq	#-1,d0
	rts
;
.done_ptr_patch:
	st	XGEM_linked_p		;as yet none is linked
	lea	nu_XGEM_1(pc),a1	;for starters we want XGEM_1
	move.l	a1,XGEM_wanted_p	;and we need to remember it
	XB_install	nu_XGEM_1(pc),(ev_xgem).w	;activate new XGEM
	XB_install	nu_BIOS(pc),(ev_bios).w	;activate new BIOS
	clr.l	d0
	rts
;----------------------------------------------------------------------------
copy_selected:
	lea	22+640(a2),a3
	bra.s	copy_common
;------------------------------------
copy_icon:
	lea	22(a2),a3		; donn‚es de l'icone
copy_common:
	moveq	#127,d0			; 128 mots longs = 512 octets
.lb0:
	move.l	(a3)+,(a1)+		; copie les donn‚es
	dbra	d0,.lb0
	moveq	#31,d0			; pour le masque
.lb1:
	move.l	(a3)+,(a0)+		; copie le masque
	dbra	d0,.lb1
	rts	
;----------------------------------------------------------------------------
copy_inv_icon:
	lea	-512(a1),a3		;a3 -> data of normal icon
	moveq	#4-1,d0			;4 loop passes, 1 per data plane
.loop_1:				;loop start for each plane
	lea	-128(a0),a4		;a4 -> mask of normal icon
	moveq	#32-1,d1		;32 loop passes, 1 per pixel line
.loop_2:				;loop start for each line
	move.l	(a3)+,d2		;d2 = icon data
	not.l	d2			;but inverted
	and.l	(a4)+,d2		;and then masked
	move.l	d2,(a1)+		;and finally stored in icon array
	dbra	d1,.loop_2		;loop back for each line
	dbra	d0,.loop_1		;loop back for each plane
	lea	-128(a0),a4		;a4 -> mask of normal icon
	moveq	#32-1,d0		;32 loop passes, 1 per mask longword
.loop_3:				;loop start for each mask longword
	move.l	(a3)+,(a0)+		;copy a mask longword
	dbra	d0,.loop_3		;loop back for each longword
	rts	
;----------------------------------------------------------------------------
check_cookies:
	eval_cookie	#'MiNT'
	bmi.s		.done_MiNT
	st		mt		;set multitasking flag
.done_MiNT:
	eval_cookie	#'MagX'
	bmi.s		.done_MagX
	st		mt		;set multitasking flag
.done_MagX:
	eval_cookie	#'Gnva'
	bmi.s		.done_Gnva
	st		mt		;set multitasking flag
.done_Gnva:
	eval_cookie	#'NOVA'
	bmi.s		.done_NOVA
	st	nova			; si oui, nova=FF
.done_NOVA:
	eval_cookie	#'_CPU'
	move.l		d0,_CPU_cookie
	seq		old_68000_f
	rts
;----------------------------------------------------------------------------
	make	JAR_links
;----------------------------------------------------------------------------
	SECTION	DATA
;----------------------------------------------------------------------------
nom:		dc.b	"C:\DESKCICN.RSC",0
titre:		dc.b	CR,LF,LF
		dc.b	ESC,'b3'
		dc.b	"  ",ESC,'c8',"                     ",ESC,'c0',CR,LF
		dc.b	"  ",ESC,'c8',"  COLORTOS  V: "
		VERSION_S
		dc.b					 "  ",ESC,'c0',CR,LF
		dc.b	ESC,'b1'
		dc.b	"  ",ESC,'c8',"     (c)1998 by:     ",ESC,'c0',CR,LF
		dc.b	ESC,'b2'
		dc.b	"  ",ESC,'c8',"   Guillaume Tello   ",ESC,'c0',CR,LF
		dc.b	"  ",ESC,'c8',"         and         ",ESC,'c0',CR,LF
		dc.b	"  ",ESC,'c8',"  Ronald  Andersson  ",ESC,'c0',CR,LF
		dc.b	"  ",ESC,'c8',"                     ",ESC,'c0',CR,LF
		dc.b	ESC,'b?'
		dc.b	CR,LF,NUL
		even
;----------------------------------------------------------------------------
;The 'TOS_var_..._t' tables below provide TOS dependent vector values used
;to initialize the 'TOS_var_act_t' table further below at runtime init.
;That table is then used to patch various references as described further on.
;----------------------------------------------------------------------------
TOS_var_ID_t:
;;;incomplete	dc.w	$0205,TOS_var_205_t-TOS_var_ID_t	;data by G.Tello (only 2 vectors)
		dc.w	$0206,TOS_var_206_t-TOS_var_ID_t	;data by R.Andersson
		dc.w	$0305,TOS_var_305_t-TOS_var_ID_t	;data by G.Tello (no 3D vectors)
		dc.w	$0306,TOS_var_306_t-TOS_var_ID_t	;data by G.Tello
		dc.w	0
;
TOS_var_306_t:	dc.l	$8DF4		;AES ICONBLK +0 == -> AES ICON mask
		dc.l	$8DF8		;AES ICONBLK +4 == -> AES ICON data
		dc.l	$8E16		;-> AES alert BITBLK
		dc.l	$9400		;-> AES DESKICON RSC
		dc.l	$949A		;-> AES weird RSC area
		dc.l	$E5CC		;AES MFBD source
		dc.l	$95D6		;AES active window id variable
		dc.l	$E120		;table of AES window parameter structs
		dc.l	$E197AE		;AES start address (for relocation)
		dc.l	$E254CC		;AES code ret adr for frame rectangles
		dc.l	$E24A12		;AES code ret adr for frame gadgets
;
;
TOS_var_305_t:	dc.l	$8B08		;AES ICONBLK +0 == -> AES ICON mask
		dc.l	$8B0C		;AES ICONBLK +4 == -> AES ICON data
		dc.l	$8B2A		;-> AES alert BITBLK
		dc.l	$9082		;-> AES DESKICON RSC
		dc.l	$911C		;-> AES weird RSC area
		dc.l	$E132		;AES MFBD source
		dc.l	0;;;		;AES active window id variable
		dc.l	0;;;		;table of AES window parameter structs
		dc.l	0;;;		;AES start address (for relocation)
		dc.l	0;;;		;AES code ret adr for frame rectangles
		dc.l	0;;;		;AES code ret adr for frame gadgets
;
TOS_var_206_t:	dc.l	$73AA		;AES ICONBLK +0 == -> AES ICON mask
		dc.l	$73AE		;AES ICONBLK +4 == -> AES ICON data
		dc.l	$73CC		;-> AES alert BITBLK
		dc.l	$79B6		;-> AES DESKICON RSC
		dc.l	$7A50		;-> AES weird RSC area
		dc.l	$CB82		;AES MFBD source
		dc.l	$7B8C		;AES active window id variable
		dc.l	$C6D6		;table of AES window parameter structs
		dc.l	$E15D48		;AES start address (for relocation)
		dc.l	$E21A66		;AES code ret adr for frame rectangles
		dc.l	$E20FAC		;AES code ret adr for frame gadgets
;
TOS_var_205_t:	dc.l	0;;;		;AES ICONBLK +0 == -> AES ICON mask
		dc.l	0;;;		;AES ICONBLK +4 == -> AES ICON data
		dc.l	0;;;		;-> AES alert BITBLK
		dc.l	$76CE		;-> AES DESKICON RSC
		dc.l	$7768		;-> AES weird RSC area
		dc.l	0;;;		;AES MFBD source
		dc.l	0;;;		;AES active window id variable
		dc.l	0;;;		;table of AES window parameter structs
		dc.l	0;;;		;AES start address (for relocation)
		dc.l	0;;;		;AES code ret adr for frame rectangles
		dc.l	0;;;		;AES code ret adr for frame gadgets
;----------------------------------------------------------------------------
;The table below is a list of pointers to all the locations addressed by the
;'patch' macro call earlier in the code.  The list is terminated by a NULL.
;Initialization code in the 'install_vector' subroutine uses the table to
;patch all those locations with new values, fetched from the location that
;the old value pointed to.  This should always be one of the pointers in
;the list starting at 'TOS_var_act_t' further below.  The effect of this
;is that at ultimate runtime all new XGEM functions are as efficient as if
;they had been assembled as part of the original TOS, with the ability to
;address all TOS-dependent variables directly, without having to duplicate
;the entire routines for each supported TOS.
;----------------------------------------------------------------------------
;NB: The patch procedure is not affected by the cache phenomena which do
;    make other forms of selfmodifying code unsuitable, because the code
;    areas are guaranteed not to be in the code cache at the time that
;    the patches are performed.  Thus no caching conflict is possible.
;----------------------------------------------------------------------------
ptr_patch_t:		;Relocation table for runtime-determined pointers
		patch_t	;This macro call generates the actual table !
;----------------------------------------------------------------------------
	SECTION	BSS
;----------------------------------------------------------------------------
;The table below is filled in with TOS dependent data at runtime init, and
;this is then used to adapt references to them as described further above.
;----------------------------------------------------------------------------
;NB: AES_wind_parm_t_p can be purged if AES patches work out as intended...
;----------------------------------------------------------------------------
TOS_var_act_t:		;list of vectors to TOS variables/constants
AES_ICON_mask_p_p:	ds.l	1	;-> AES ICONBLK +0 == -> ->  AES ICON mask
AES_ICON_data_p_p:	ds.l	1	;-> AES ICONBLK +4 == -> -> AES ICON data
AES_al_BITBLK_p_p:	ds.l	1	;-> -> AES alert BITBLK
AES_DESKICON_p_p:	ds.l	1	;-> -> AES DESKICON RSC
AES_weird_RSC_p_p:	ds.l	1	;-> -> AES weird RSC area
AES_MFDB_src_p:		ds.l	1	;-> AES MFBD source
AES_actwnd_id_p:	ds.l	1	;-> AES active window id variable
AES_wind_parm_t_p:	ds.l	1	;-> table of AES window parameter structs
;----------------------- ptrs above are variables, below are TOS code addresses
AES_start_adr_p:	ds.l	1	;-> AES start address (for relocation)
AES_3Drecfl_ret_p:	ds.l	1	;-> AES code ret adr for frame rectangles
AES_3Dgtext_ret_p:	ds.l	1	;-> AES code ret adr for frame gadgets
TOS_var_act_end:	;End of list of TOS variables/constants
;----------------------- The list continues with other runtime determined stuff
line_a_base_p:		;-> base of line_a variables
LA_planes_p:		ds.l	1	;-> la_planes word (at line_a base)
LA_bytes_lin_p:		ds.l	1	;-> la_bytes_lin (at line_a -2)
LA_v_rez_vt_p:		ds.l	1	;-> la_v_rez_vt
LA_v_rez_hz_p:		ds.l	1	;-> la_v_rez_hz
move_preframe_retadr_a0: ds.l	1	;opcode => a0 = long above stack frame at (sp)
;------------------------------------
;Here ends the list of patch vectors. Normal variables follow below.
;------------------------------------
_CPU_cookie:		ds.l	1	;30 for 68030 CPU, 0 for 68000, etc
old_68000_f:		ds.w	1	;$FF00 for 68000, $0000 for newer CPU
XGEM_2_use_f:		ds.w	1	;flags use of secondary XGEM link
AES_3D_support_f:	ds.w	1	;flags validity of 3D support vectors
XGEM_linked_p:		ds.l	1	;-> XBRA struct of dispatcher we have linked
XGEM_wanted_p:		ds.l	1	;-> XBRA struct of dispatcher we want linked
;
rect_flag:		ds.w	1	;high byte $FF if rect valid, low byte == window id
rect_size:		ds.w	4	;x0, y0, x1, y1, as saved by 'save_rect'
;
left_mask:		ds.w	1	;mask for affected bits in 1st 16pix group
right_mask:		ds.w	1	;mask for affected bits in last 16pix group
left_bit:		ds.w	1	;mask for 1st affected bit in left_mask
right_bit:		ds.w	1	;mask for last affected bit in right_mask
;
actwnd_str_VAR_f:	ds.w	1	;2 flags for validity of title/info ptrs at (actwnd_str_VAR_p)
actwnd_str_VAR_p:	ds.l	1	;-> window title/info strings according to AES vars
actwnd_str_SET_p:	ds.l	1	;-> window title/info strings according to wind_set
;
window_data_t:		ds.l	256*2	;4KB table of 2 string ptrs per window (set by wind_set etc)
;
adr_actu:		ds.l	1	; adresse de l'icone actuelle
p_actu:			ds.w	1	; nombre de plans actuels
une_icone:		ds.b	32*32*2	; taille en 16 bits
ni:			ds.w	1	; nombre d'icones
data_ptr:		ds.l	1	; adresse pour les donn‚es
data_end:		ds.l	1	; fin des donn‚es
zone:			ds.b	MAX_ICONS*256	;max RAM for icon masks
filebase:		ds.b	MAX_ICONS*Kb	;max RAM for icon data
			ds.b	MAX_ICONS*Kb	;extra temp RAM for file
filebuff_end:
max_file		=	filebuff_end-filebase
stack_base:		ds.l	256	;minimal initialization stack
stack_top:		ds.w	1	;init stack overlaps resource !!!
;----------------------------------------------------------------------------
	END
;----------------------------------------------------------------------------
;End of:	COLORTOS.S
;----------------------------------------------------------------------------
