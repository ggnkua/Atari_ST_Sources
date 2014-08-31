;-----------------------------------------------------------------------------
;File name:		MT_X.S			Revision date:	1993.08.24
;Revision author:	Ulf Ronald Andersson	Disassembled:	1993.04.24
;Original author:	Olof Edstr”m		Release date:	1993.xx.xx
;Revision code:		MTx4			Version:	4.1
;-----------------------------------------------------------------------------
; Notes:
;
;	Original "ResOpen" code was created with Sozobon C.
;	This naturally caused a lack of optimization throughout the code.
;
;	I (Ronald Andersson) have endeavoured to rectify this,
;	without affecting the user interface at all.
;	While working on this I also found a few bugs (commented below),
;	which I have of course corrected.
;
;	To differentiate this version from the original, I use the XBRA
;	abbreviation "MTx4", which stands for "MichTron eXtension version 4".
;
;-----------------------------------------------------------------------------
; Version 4.1 changes:
;
;	MTx4 now patches the code of Michtron 3.0 such that whatever system
;	font is active on entry is also adopted by Michtron for the BBS.
;
;	Further patches ensure that all european character sets are legal,
;	as well as possible graphics, when ANSI-fonts are used.
;
;	These also provide the ability to translate input and output bytes
;	through 2 separate user-defined translation tables.
;
;	Translation of either kind can be individually disabled, without
;	reloading the translation tables.
;
;	To be able to use translation filters you _must_ read MT_X.DOC !!!
;
;	All these new extensions are options, that must be enabled by user
;	calls, so that all old MCL software will be unaffected by update.
;
;-----------------------------------------------------------------------------
; Original bugs & features:
;
;	One bug in particular needs to be mentioned here, since the original
;	author is obviously aware of its existence but has failed to find it.
;	This is the lack of NUL termination for the name of the log file, as
;	copied into its reserved data area from the user's argument.
;
;	Unterminated, this string would cause errors in the "Fopen" calls,
;	which the author has finally circumvented by replacing the given name
;	with a string constant instead.
;
;	I have corrected this bug and made the name user defined according
;	to the original intention of the author.
;	I have also added the code needed to accumulate log info, rather
;	than deleting any previous log file.
;	Finally I have made the use of a log file optional, so that none
;	will be used if the "Fopen" argument begins with '#'.
;
;-----------------------------------------------------------------------------
;
	output	.PRG	;so Michtron externals can use GEM
;
	include	URAn_DOS.S
	include	URAn_LA.S
	include	URAn_XB.S
;
main_stk_need	= 1000
save_stk_need	= 800
;
;-----------------------------------------------------------------------------
;
	text
;
prog_entry:
	move.l	4(sp),a4		;a4->basepage
	move.l	#$100,d4		;d4= basepage size
	add.l	bp_textlen(a4),d4	;d4+= code size
	add.l	bp_datalen(a4),d4	;d4+= data size
	add.l	bp_bss_len(a4),d4	;d4+= bss  size
	addq.l	#1,d4			;\ Force d4 even
	and.l	#-2,d4			;/ by rounding up
	move.l	#main_stack,d5
	add.l	main_stk_size,d5
	move.l	d5,sp			;sp= main_stack+LONG@(main_stk_size)
	gemdos	Mshrink,!,(a4),d4
	tst.l	d0
	bmi.s	.refuse
	move.l	a4,basepage_p
	bsr.s	decode_font		;decode system font
	move.l	basepage_p,-(sp)
	jsr	_Start
	addq.l	#4,sp
.refuse:
	clr.l	d0		;remove this line to get return codes.
	gemdos	Pterm,d0		;exit to desktop at exit from BBS
;
;
;-----------------------------------------------------------------------------
; 	Here follows the font decoder:
;
decode_font:
	_a_init				;a0 -> line_a structure
	move.l	la_def_font(a0),a6	;a6 -> system font header
	lea	font_array(pc),a5	;a5 -> local font array
	move.l	76(a6),a4		;a4 -> system font data
	move.l	72(a6),a3		;a3 -> char offset table
	move	82(a6),d7		;d7 = system font height
	move	36(a6),d5		;d5 = lowest ascii of font
	subq	#1,d5			;d5 = lowest ascii - 1
	move	80(a6),d6		;d6 = system font width (bytes)
font_move_loop_1:
	addq	#1,d5			;d5 += 1  (stepped to next ascii)
	move	d5,d0
	mulu	d7,d0			;d0 = font_height * ascii
	lea	0(a5,d0.l),a1		;a1 -> array area for ascii's line 0,..,7
	move	d5,d0
	sub	36(a6),d0		;d0 = ascii - lowest_ascii
	lsl.w	#1,d0			;d0 = word index
	move	0(a3,d0.w),d3		;d3 = char offset
	moveq	#0,d4			;d4 = 0  (clear line#)
font_move_loop_2:
	move	d4,d0
	mulu	d6,d0			;d0 = line# * font_width = line_offs
	lea	0(a4,d0.l),a2		;a2 -> system font data of line
	move	d3,d1
	lsr.w	#3,d1			;d1 = char_offset / 8  (byte_index)
	move.b	0(a2,d1.w),d2		;\
	lsl.w	#8,d2			; > d2 = unaligned font data word
	move.b	1(a2,d1.w),d2		;/
	move	d3,d0			;d0 = char_offs
	and	#7,d0			;d0 = mod(char_offs,8)
	moveq	#8,d1
	sub.b	d0,d1			;d1 = 8-mod(char_offs,8)  (8,7,..,2,1)
	lsr.w	d1,d2
	and.b	#255,d2
	move.b	d2,(a1)+		;(a1)+ = line data for char
	addq	#1,d4			;d4 += 1  (step line#)
	cmp	d7,d4			;line# = font_height ???
	bne	font_move_loop_2	;loop back for each font line
	cmp	38(a6),d5		;ascii = highest_ascii ???
	bne	font_move_loop_1	;loop back for each font character
	rts
;
;
;-----------------------------------------------------------------------------
;	Here follows the XBRA-linked gemdos extension
;
;NB: Original did not test '_longframe' to be compatible with newer CPU's.
;    It also wasted time for critical functions ('Super' etc.) .
;    Finally, when it had executed an external program, it would exit through
;    the original gemdos handler, which can cause various errors (BUG).
;
;    The new routine is optimized to minimize time loss for all functions
;    except 'Fopen', since that is the one implementing the new commands.
;    This code allows for any 680xx CPU, and exits after commands without
;    erroneously calling the old 'Fopen' function.
;
	XB_define	nu_gemdos_XB,'MTx4'
	tas	nu_gemdos_lock
	bmi.s	.force_old_gemdos
	move	USP,a0
	btst	#5,(sp)
	beq.s	.keep_arg_p
	move.l	sp,a0
	add	st_frame_size(pc),a0
.keep_arg_p:
	cmp	#Fopen&$FF,(a0)
	beq.s	.we_have_Fopen
.use_old_gemdos:
	clr.b	nu_gemdos_lock
.force_old_gemdos:
	XB_gonext_d	nu_gemdos_XB
;
;
.we_have_Fopen:
	movem.l	d1-d2/a1-a2,-(sp)
	jsr	new_Fopen
	movem.l	(sp)+,d1-d2/a1-a2
	tst.l	d0
	bpl.s	.use_old_gemdos		;NEW: only use old DOS after non_command
	clr.b	nu_gemdos_lock
	rte				;NEW: exit with d0= err<0 after command
;
new_Fopen:
	link	a6,#0
	pea	prog_arg_c(pc)
	pea	progname_s(pc)
	pea	log_name_s(pc)
	move.l	2(a0),-(sp)		;-(sp)->file_pathname
	bsr	split_command
	adda	#$10,sp
	tst.l	d0
	beq	.exit_new_Fopen		;exit positive zero for non_command
	tst.b	progname_s
	bne.s	.call_external
.call_internal:
	move	SR,sr_save		;save status
	or	#$0700,sr		;disable interrupts
	bsr	new_command		;special command if no program name
	move	sr_save,SR		;restore status & interrupt mask
	bra	.exit_new_command
;
.call_external:
	move	SR,sr_save		;save status
	or	#$0700,sr		;disable interrupts
	move.l	#bbs_vector_tb,-(sp)
	bsr	read_vectors
	addq	#4,sp
	move.l	#bbs_mfp_tb,-(sp)
	bsr	read_mfp
	addq	#4,sp
	move.l	#norm_vector_tb,-(sp)
	bsr	write_vectors
	addq	#4,sp
	move.l	#norm_mfp_tb,-(sp)
	bsr	write_mfp
	addq	#4,sp
	move.l	#save_stk_need,-(sp)
	move.l	#LD9A,-(sp)
	move.l	initial_SSP,-(sp)
	bsr	_SaveStk
	adda	#12,sp
	move.l	d0,stk_save_size
	move	sr_save,SR		;restore status & interrupt mask
	gemdos	Pexec,!,progname_s(pc),prog_arg_c(pc),!	;Load and run
	move.l	d0,prog_result
	move	SR,sr_save		;save status
	or	#$0700,sr		;disable interrupts
	tst.l	stk_save_size
	ble.s	.skip_setstk
	move.l	stk_save_size,-(sp)
	move.l	#LD9A,-(sp)
	bsr	_SetStk
	addq	#8,sp
.skip_setstk:
	move.l	#bbs_vector_tb,-(sp)
	bsr	write_vectors
	addq	#4,sp
	move.l	#bbs_mfp_tb,-(sp)
	bsr	write_mfp
	addq	#4,sp
	move	sr_save,SR		;restore status & interrupt mask
	tst.b	log_name_s		;externals called without log_name
	beq	.not_log		;will then skip logging
	gemdos	Fopen,log_name_s(pc),#1
	tst.l	d0
	bmi.s	.try_create
	move	d0,log_handle
	gemdos	Fseek,!,log_handle(pc),#2
	bra.s	.got_log
;
.try_create:
	gemdos	Fcreate,log_name_s(pc),!
	tst.l	d0
	bmi.s	.not_log
	move	d0,log_handle
.got_log:
	pea	MT_X_name_s(pc)
	move	log_handle,-(sp)
	bsr	log_text
	addq	#6,sp
	pea	version_s(pc)
	move	log_handle,-(sp)
	bsr	log_text
	addq	#6,sp
	pea	Underline_s(pc)
	move	log_handle,-(sp)
	bsr	log_text
	addq	#6,sp
	pea	progname_s(pc)
	move	log_handle,-(sp)
	bsr	log_text
	addq	#6,sp
	pea	prog_arg_s(pc)
	move	log_handle,-(sp)
	bsr	log_text
	addq	#6,sp
	move.l	prog_result,-(sp)
	bsr	_ToHex
	addq	#4,sp
	move.l	d0,-(sp)
	move	log_handle,-(sp)
	bsr	log_text
	addq	#6,sp
	pea	Underline_s(pc)
	move	log_handle,-(sp)
	bsr	log_text
	addq	#6,sp
	gemdos	Fclose,log_handle
.not_log:				;Here logging is complete, or skipped
.exit_new_command:
	moveq	#-1,d0			;exit with err -1 after command
.exit_new_Fopen:
	unlk	a6
	rts
;
;
new_command:
	lea	log_name_s(pc),a0
	lea	prog_arg_c(pc),a1
	move.b	(a0)+,d0
	beq.s	.exit
	move.b	(a0)+,d1
	beq.s	.exit
	tst.b	(a0)
	bne.s	.exit
	cmp.b	#1,(a1)+
	bne.s	.exit
	move.b	(a1)+,d2
	tst.b	(a1)
	bne.s	.exit
	and	#$FF,d0
	and	#$FF,d1
	and	#$FF,d2
	cmp	#$40,d0
	blo.s	.exit
	cmp	#$7A,d0
	bhi.s	.exit
	and	#$1F,d0
	lsl	#2,d0
	pea	.exit
	move.l	new_cmd_tab(pc,d0),-(sp)
	bne.s	.exit
	addq	#8,sp
.exit:
	move.l	#-1,d0
	rts
;
new_cmd_tab:
	dc.l	0,0,0,clear_cmd,0,0,flag_cmd,0		;0x40..0x47
	dc.l	0,ifilt_cmd,0,0,0,0,0,ofilt_cmd		;0x48..0x4F
	dc.l	patch_cmd,0,0,0,0,0,0,0			;0x50..0x57
	dc.l	0,0,0,0,0,0,0,0				;0x58..0x5F
;
;
clear_cmd:
	cmp	#'i',d1
	beq.s	.clr_ifilt
	cmp	#'I',d1
	bne.s	.not_clr_ifilt
.clr_ifilt:
	bsr	clear_ifilt
	rts
;
.not_clr_ifilt:
	cmp	#'o',d1
	beq.s	.clr_ofilt
	cmp	#'O',d1
	bne.s	.not_clr_ofilt
.clr_ofilt:
	bsr	clear_ofilt
.not_clr_ofilt:
	rts
;
;
flag_cmd:
	lea	flag_array(pc),a0
	move	d1,d0
	and	#7,d0
	lsr	#3,d1
	cmp.b	#'0',d2
	beq.s	.clr_flag
	cmp.b	#'1',d2
	bne.s	.exit
.set_flag:
	bset	d0,(a0,d1)
	rts
;
.clr_flag:
	bclr	d0,(a0,d1)
.exit:
	rts
;
;
ifilt_cmd:
	lea	ifilt_tab(pc),a0
	bra.s	a_filt_cmd
;
;
ofilt_cmd:
	lea	ofilt_tab(pc),a0
a_filt_cmd:
	move.b	d2,(a0,d1)
	rts
;
;
patch_cmd:
	cmp	#'8',d1
	bne.s	.patch_not_p8
	cmp	#'0',d2
	beq.s	.patch_8_0
	cmp	#'1',d2
	bne.s	.exit
.patch_8_1:
	bsr	patch_8bit_on
	rts
;
.patch_8_0:
	bsr	patch_8bit_off
	rts
;
.patch_not_p8:
	cmp	#'f',d1
	beq.s	.patch_font
	cmp	#'F',d1
	bne.s	.patch_not_pf
.patch_font:
	cmp	#'0',d2
	beq.s	.patch_font_0
	cmp	#'1',d2
	bne.s	.exit
.patch_font_1:
	bsr	patch_font_on
	rts
;
.patch_font_0:
	bsr	patch_font_off
	rts
;
.patch_not_pf:
	cmp	#'i',d1
	beq.s	.patch_i
	cmp	#'I',d1
	bne.s	.patch_not_pi
.patch_i:
	cmp	#'0',d2
	beq.s	.patch_i_0
	cmp	#'1',d2
	bne.s	.exit
.patch_i_1:
	bsr	patch_ifilt_on
	rts
;
.patch_i_0:
	bsr	patch_ifilt_off
	rts
;
.patch_not_pi:
	cmp	#'o',d1
	beq.s	.patch_o
	cmp	#'O',d1
	bne.s	.patch_not_po
.patch_o:
	cmp	#'0',d2
	beq.s	.patch_o_0
	cmp	#'1',d2
	bne.s	.exit
.patch_o_1:
	bsr	patch_ofilt_on
	rts
;
.patch_o_0:
	bsr	patch_ofilt_off
.patch_not_po:
.exit:
	rts
;
;-----------------------------------------------------------------------------
;	Here are the filter routines for Michtron user I/O
;
serin_filt_1:
	jsr	(serin_filt_sub).l
;
serin_filt_sub:
	move.l	4(sp),-(sp)
serin_filt_0:
	jsr	(0).l			;patched at startup
	addq	#4,sp
	movem.l	d0/a0,-(sp)
	and	#$FF,d0
	lea	ifilt_tab,a0
	move.b	(a0,d0),3(sp)
	movem.l	(sp)+,d0/a0
	rts
;
;
conin_filt_1:
	jsr	(conin_filt_sub).l
;
conin_filt_sub:
	move.l	4(sp),-(sp)
conin_filt_0:
	jsr	(0).l			;patched at startup
	addq	#4,sp
	movem.l	d0/a0,-(sp)
	and	#$FF,d0
	lea	ifilt_tab,a0
	move.b	(a0,d0),3(sp)
	movem.l	(sp)+,d0/a0
	rts
;
;
conout_filt_1:
	jsr	(conout_filt_sub).l
;
conout_filt_sub:
	movem.l	d0/a0,-(sp)
	move	d6,d0
	and	#$FF,d0
	lea	ofilt_tab,a0
	move.b	(a0,d0),d6
	movem.l	(sp)+,d0/a0
	cmp	#$20,d6
	blt.s	.jump_74h
	rts
;
.jump_74h:
	add.l	#$74,(sp)
	cmp	#$20,d6
	rts
;
conout_filt_0:
	cmp	#$20,d6
	blt.s	.l1+$74
.l1:
;
;-----------------------------------------------------------------------------
;
; This routine "split_command" checks for legal command (must contain '#')
; and splits it up into log_name, prog_name and argument.
; The original however contained some bugs, that made log_name useless,
; and made arguments obligatory instead of optional.
; Both these errors are corrected in this version.
;
split_command:
	link	a6,#0
.log_name_loop:
	move.l	8(a6),a0
	cmpi.b	#'#',(a0)
	beq.s	.scan_prog_name
	tst.b	(a0)
	bne.s	.pass_log_name
	clr.l	d0		;flag positive zero for non_command
	bra	.non_command
;
.pass_log_name:				;store byte of logfile name
	move.l	12(a6),a1
	move.b	(a0),(a1)
	addq.l	#1,8(a6)
	addq.l	#1,12(a6)
	bra.s	.log_name_loop
;
.scan_prog_name:
	addq.l	#1,8(a6)
	move.l	12(a6),a1	;\ NB: original neglected NUL termination
	clr.b	(a1)		;/     which could cause SERIOUS BUGS
.prog_name_loop:
	move.l	8(a6),a0
	cmpi.b	#'#',(a0)
	beq.s	.scan_argument
	tst.b	(a0)
	beq.s	.prog_name_end	;NB: original branched to .scan_argument again (BUG)
.pass_prog_name:		;store byte of external program's name
	move.l	16(a6),a1
	move.b	(a0),(a1)
	addq.l	#1,8(a6)
	addq.l	#1,16(a6)
	bra.s	.prog_name_loop
;
.scan_argument:
	addq.l	#1,8(a6)
.prog_name_end:			;NB: This avoids taking garbage argument
	move.l	16(a6),a0	;NB: Here original NUL terminates OK!,
	clr.b	(a0)		;    so why not elsewhere as well ???
	move.l	20(a6),d0
	addq.l	#1,20(a6)	;reserve a byte as argument length count
	move.l	d0,cmd_arg_p	;store argument pointer
	clr.b	cmd_arglen	;arglen=0
.argument_loop:
	move.l	8(a6),a0
	cmpi.b	#'#',(a0)
	beq.s	.argument_end
	tst.b	(a0)
	beq.s	.argument_end
.pass_argument:			;store byte of external program's argument
	move.l	20(a6),a1
	move.b	(a0),(a1)
	addq.l	#1,8(a6)
	addq.l	#1,20(a6)
	addq.b	#1,cmd_arglen
	bra.s	.argument_loop
;
.argument_end:
	move.l	20(a6),a0
	clr.b	(a0)		;NUL terminate argument string
	move.l	cmd_arg_p,a0
	move.b	cmd_arglen,(a0)	;store argument length byte
	moveq	#-1,d0		;flag negative d0 for command
.non_command:
	unlk	a6
	rts
;
;
;-----------------------------------------------------------------------------
;
_Hej:
	gemdos	Cconws,crlf_s(pc)
	gemdos	Cconws,MT_X_name_s(pc)
	gemdos	Cconws,version_s(pc)
	gemdos	Cconws,crlf_s(pc)
;NB: original had a speed_dependent delay here.
;    This had no real purpose, so I have removed it.
	rts
;
;
read_vectors:		;argument is a ptr to a 164 byte structure
	link	a6,#-10
	bios	Setexc,#$2D,?		;d0= bios_vector
	move.l	8(a6),a0		;a0= save_p
	move.l	d0,(a0)			;save_p[0]= bios_vector
	bios	Setexc,#$2E,?		;d0= xbios_vector
	move.l	8(a6),a0		;a0= save_p
	move.l	d0,4(a0)		;save_p[1]= xbios_vector
	clr	-2(a6)			;count= 0
.L178:					;loop start to save 16 vectors
	cmpi	#$10,-2(a6)			;16 vectors saved ?
	bge.s	.L1B4				;exit after 16 vectors
	move	-2(a6),d0			;d0= count
	add	#$40,d0				;d0= ($100)/4 + count
	bios	Setexc,d0,?			;d0= old vector at (d0*4)
	move	-2(a6),d1			;d1= count
	asl.w	#2,d1				;d1= count*4
	ext.l	d1				;d1= (long)(count*4)
	move.l	8(a6),a0			;a0= save_p
	addq	#8,a0				;a0= &(save_p[2])
	adda.l	d1,a0				;a0= &(save_p[2+count])
	move.l	d0,(a0)				;save_p[2+count]=vector
	addq	#1,-2(a6)			;count+= 1
	bra.s	.L178			;loop back to save 16 vectors
;
.L1B4:
	xbios	Kbdvbase		;d0= Kbdvbase()
	move.l	d0,-6(a6)		;vect_p= Kbdvbase()
	clr	-2(a6)			;count= 0
.L1C8:					;loop start to save 9 kbd vectors
	cmpi	#$9,-2(a6)			;9 vectors saved ?
	bge.s	.L1F4				;exit after 9 vectors
	move.l	-6(a6),d0			;d0= vect_p ;(&current_vector)
	addq.l	#4,-6(a6)			;vect_p+= sizeof(vector)
	move.l	d0,a0				;a0= d0= &current_vector
	move	-2(a6),d0			;\
	asl.w	#2,d0				; > d0= (long)(count * sizeof(vector))
	ext.l	d0				;/
	move.l	8(a6),a1			;a1= save_p
	adda	#$48,a1				;a1= &(save_p[18])
	adda.l	d0,a1				;a1= &(save_p[18+count])
	move.l	(a0),(a1)			;save_p[18+count]= current_vector
	addq	#1,-2(a6)			;count+= 1
	bra.s	.L1C8			;loop back to save 9 kbd vectors
;
.L1F4:
	move.l	#_vbl_list,-10(a6)
	clr	-2(a6)
.L200:					;loop start to save 8 vbl vectors
	cmpi	#$8,-2(a6)
	bge.s	.L22C
	move.l	-10(a6),d0
	addq.l	#4,-10(a6)
	move.l	d0,a0
	move	-2(a6),d0
	asl.w	#2,d0
	ext.l	d0
	move.l	8(a6),a1
	adda	#$7C,a1
	adda.l	d0,a1
	move.l	(a0),(a1)
	addq	#1,-2(a6)
	bra.s	.L200			;loop back to save 8 vbl vectors
;
.L22C:
	move.l	8(a6),a0
	move	(nvbls).w,156(a0)
	move.l	8(a6),a0
	move.l	(_vblqueue).w,158(a0)
	move.l	8(a6),a0
	move	(vblsem).w,162(a0)
	bios	Setexc,#$1C,?		;d0= vbi vector
	move.l	8(a6),a0
	move.l	d0,112(a0)
	bios	Setexc,#$1A,?		;d0= hbi vector
	move.l	8(a6),a0
	move.l	d0,108(a0)
	bios	Setexc,#$1E,?		;d0= vector at $78
	move.l	8(a6),a0
	move.l	d0,116(a0)
	move.l	8(a6),a0
	move.l	(etv_timer).w,120(a0)	;save etv_timer vector
	unlk	a6
	rts
;
;
write_vectors:	;argument is a ptr to a 164 byte structure
	link	a6,#-10
	move.l	8(a6),a0
	bios	Setexc|_ind,#$2D,(a0)	;set bios vector
	move.l	8(a6),a0
	bios	Setexc|_ind,#$2E,4(a0)	;set xbios vector
	clr	-2(a6)
.L2F8:
	cmpi	#$10,-2(a6)
	bge.s	.L32E
	move	-2(a6),d0
	asl.w	#2,d0
	ext.l	d0
	move.l	8(a6),a0
	addq	#8,a0
	adda.l	d0,a0
	move	-2(a6),d0
	add	#$40,d0
	bios	Setexc|_ind,d0,(a0)	;set vector at (d0*4)
	addq	#1,-2(a6)
	bra.s	.L2F8
;
.L32E:
	xbios	Kbdvbase
	move.l	d0,-6(a6)
	clr	-2(a6)
.L342:
	cmpi	#$9,-2(a6)
	bge.s	.L36E
	move	-2(a6),d0
	asl.w	#2,d0
	ext.l	d0
	move.l	8(a6),a0
	adda	#$48,a0
	adda.l	d0,a0
	move.l	-6(a6),d0
	addq.l	#4,-6(a6)
	move.l	d0,a1
	move.l	(a0),(a1)
	addq	#1,-2(a6)
	bra.s	.L342
;
.L36E:
	move.l	#_vbl_list,-10(a6)
	clr	-2(a6)
.L37A:
	cmpi	#$8,-2(a6)
	bge.s	.L3A6
	move	-2(a6),d0
	asl.w	#2,d0
	ext.l	d0
	move.l	8(a6),a0
	adda	#$7C,a0
	adda.l	d0,a0
	move.l	-10(a6),d0
	addq.l	#4,-10(a6)
	move.l	d0,a1
	move.l	(a0),(a1)
	addq	#1,-2(a6)
	bra.s	.L37A
;
.L3A6:
	clr	(vblsem).w
	move.l	8(a6),a0
	move	156(a0),(nvbls).w
	move.l	8(a6),a0
	move.l	158(a0),(_vblqueue).w
	move.l	8(a6),a0
	move	162(a0),(vblsem).w
	move.l	8(a6),a0
	bios	Setexc|_ind,#$1C,112(a0)	;set vbi vector
	move.l	8(a6),a0
	bios	Setexc|_ind,#$1A,108(a0)	;set hbi vector
	move.l	8(a6),a0
	bios	Setexc|_ind,#$1E,116(a0)	;set vector at ($78)
	move.l	8(a6),a0
	move.l	120(a0),(etv_timer).w		;set etv_timer vector
	unlk	a6
	rts
;
;
read_mfp:
	link	a6,#0
	movem.l	a3-a4,-(sp)
	move.l	8(a6),a3
	move.l	#$FFFA00,a4
	move.b	7(a4),7(a3)
	move.b	9(a4),9(a3)
	move.b	19(a4),19(a3)
	move.b	21(a4),21(a3)
	move.b	23(a4),23(a3)
	movem.l	(sp)+,a3-a4
	unlk	a6
	rts
;
;
write_mfp:
	link	a6,#0
	movem.l	a3-a4,-(sp)
	move.l	8(a6),a3
	move.l	#$FFFA00,a4
	move.b	23(a3),23(a4)
	move.b	7(a3),7(a4)
	move.b	9(a3),9(a4)
	move.b	19(a3),19(a4)
	move.b	21(a3),21(a4)
	movem.l	(sp)+,a3-a4
	unlk	a6
	rts
;
;
log_text:	;void log_text(word handle, char *text)
	link	a6,#-8		;long s_len; char *s
	clr.l	-4(a6)		;s_len= 0
	move.l	10(a6),-8(a6)	;s= text
.L4B4:				;loop start to count length of text
	move.l	-8(a6),a0		;a0= s
	tst.b	(a0)
	beq.s	.L4C6			;exit if (*s == NUL)
	addq.l	#1,-8(a6)		;s+= 1
	addq.l	#1,-4(a6)		;s_len+= 1
	bra.s	.L4B4		;loop back to count length of text
;
.L4C6:
	gemdos	Fwrite|_ind,8(a6),-4(a6),10(a6)	;write text to file
	gemdos	Fwrite,8(a6),#2,crlf_s(pc)	;write crlf to file
	unlk	a6
	rts
;
;
_ToHex:
	link	a6,#0
	move	#$7,hex_pos
L516:
	tst	hex_pos
	blt.s	L554
	move.l	8(a6),d0
	and.l	#$F,d0
	lea	hex_table_s,a0
	adda	d0,a0
	lea	hex_buff_s,a1
	adda	hex_pos,a1
	move.b	(a0),(a1)
	move.l	8(a6),d0
	asr.l	#4,d0
	move.l	d0,8(a6)
	subq	#1,hex_pos
	bra.s	L516
;
L554:
	clr.b	hex_buff_term
	move.l	#hex_buff_s,d0
	unlk	a6
	rts
;
;
_SaveStk:
	link	a6,#0
	lea	16(a6),a0
	addq.l	#4,a0
	move.l	a0,LC0E		;LC0E= precall_SSP
	move.l	8(a6),d0	;d0= initial_SSP
	sub.l	LC0E,d0		;d0= initial_SSP-precall_SSP
	move.l	d0,SSP_diff	;SSP_diff= initial_SSP-precall_SSP
	cmp.l	16(a6),d0	;SSP_diff > save_stk_need ?
	ble.s	L678		;continue if SSP_diff <= save_stk_need
	moveq	#-1,d0
	bra.s	L6C6
;
L678:
	tst.l	SSP_diff
	bge.s	L684
	clr.l	d0
	bra.s	L6C6
;
L684:
	move.l	SSP_diff,d0
	asr.l	#1,d0
	move.l	d0,LC0A
L692:
	tst.l	LC0A
	ble.s	L6BC
	move.l	LC0E,a0
	move.l	12(a6),a1
	move	(a0),(a1)
	addq.l	#2,LC0E
	addq.l	#2,12(a6)
	subq.l	#1,LC0A
	bra.s	L692
;
L6BC:
	move.l	SSP_diff,d0
L6C6:
	unlk	a6
	rts
;
;
_SetStk:
	link	a6,#0
	lea	12(a6),a0
	addq.l	#4,a0
	move.l	a0,LC12
	move.l	12(a6),d0
	asr.l	#1,d0
	move.l	d0,12(a6)
L6EA:
	tst.l	12(a6)
	ble.s	L710
	move.l	8(a6),a0
	move.l	LC12,a1
	move	(a0),(a1)
	addq.l	#2,8(a6)
	addq.l	#2,LC12
	subq.l	#1,12(a6)
	bra.s	L6EA
;
L710:
	unlk	a6
	rts
;
;
start_BBS:
	link	a6,#-14
	gemdos	Malloc,?	;d0= largest RAM available
	move.l	d0,-8(a6)
	gemdos	Malloc,-8(a6)		;d0->Allocated maximum RAM
	move.l	d0,-12(a6)
	tst.l	d0
	bmi	.exit
	move.l	-8(a6),d0
	sub.l	20(a6),d0
	gemdos	Mshrink|_ind,!,-12(a6),d0 ;release bbs required RAM
	tst.l	d0
	bmi.s	.refuse
	gemdos	Pexec|_ind,#3,8(a6),12(a6),16(a6)	;Load BBS
	move.l	d0,-4(a6)
	bmi.s	.refuse
	gemdos	Mfree|_ind,-12(a6)		;release RAM
	move.l	-4(a6),d0
	bsr.s	patch_MT			;patch BBS
	tst.l	d0
	bmi.s	.wrong_MT_err
	gemdos	Pexec|_ind,#4,!,-4(a6),!	;Start BBS
	bra.s	.exit
;
.wrong_MT_err:
	gemdos	Cconws,wrong_MT_s(pc)
	moveq	#-1,d0
	bra.s	.exit
;
.refuse:	;error exit point
	move.l	d0,d7
	gemdos	Mfree|_ind,-12(a6)		;release RAM
	move.l	d7,d0
.exit:		;normal exit point
	unlk	a6
	rts
;
;
patch_MT:
	move.l	d0,a5			;a5 -> basepage of loaded MT
	cmpi.l	#$1817C,bp_textlen(a5)	;Program code is ok ???
	beq.s	.install_patcher	;patch only if program size ok !!!
	moveq	#-1,d0
	rts
;
.install_patcher:
	gemdos	Cconws,patching_s(pc)
	move.l	bp_textbeg_p(a5),a3	;a3 -> start of MT program code
	lea	$480(a3),a0		;font2_ptr	=   $480+a3
	move.l	a0,font2_ptr_p
	move.l	(a0),font2_ptr_0
	lea	font_array(pc),a1
	move.l	a1,font2_ptr_1
	lea	$486(a3),a0		;font2_limit	=   $486+a3
	move.l	a0,font2_limit_p
	move	(a0),font2_limit_0
	move	#$FF,font2_limit_1
	lea	$4BC(a3),a0		;font1_ptr	=   $4BC+a3
	move.l	a0,font1_ptr_p
	move.l	(a0),font1_ptr_0
	lea	font_array(pc),a1
	move.l	a1,font1_ptr_1
	lea	$4C2(a3),a0		;font1_limit	=   $4C2+a3
	move.l	a0,font1_limit_p
	move	(a0),font1_limit_0
	move	#$FF,font1_limit_1
	lea	$4C64(a3),a0		;editld_limit	=  $4C64+a3
	move.l	a0,editld_limit_p
	move	(a0),editld_limit_0
	move	#$FF,editld_limit_1
	lea	$5A1C(a3),a0		;serin_filt	=  $5A34+a3
	move.l	a0,serin_filt_p
	movem.w	(a0),d0-d2
	movem.w	d0-d2,serin_filt_0
	lea	$5A42(a3),a0		;serin_bxx	=  $5A42+a3
	move.l	a0,serin_bxx_p
	move	(a0),serin_bxx_0
	move	#$677C,serin_bxx_1
	move	#$6726,conin_bxx_1
	lea	$748E(a3),a0		;conout_filt	=  $748E+a3
	move.l	a0,conout_filt_p
	lea	$7496(a3),a0		;conout_limit	=  $7496+a3
	move.l	a0,conout_limit_p
	move	(a0),conout_limit_0
	move	#$FF,conout_limit_1
	move.l	a3,a0
	add.l	#$102A2,a0		;ext1ld_limit	= $102A2+a3
	move.l	a0,ext1ld_limit_p
	move	(a0),ext1ld_limit_0
	move	#$FF,ext1ld_limit_1
	move.l	a3,a0
	add.l	#$150A4,a0		;conin_filt	= $150BC+a3
	move.l	a0,conin_filt_p
	movem.w	(a0),d0-d2
	movem.w	d0-d2,conin_filt_0
	move.l	a3,a0
	add.l	#$150CA,a0		;conin_bxx	= $150CA+a3
	move.l	a0,conin_bxx_p
	move	(a0),conin_bxx_0
;
	bsr.s	patch_font_on		;adopt system font
;
	bsr.s	clear_ifilt		;\/ Force both filters
	bsr.s	clear_ofilt		;/\ to transparency
;
	clr.l	d0
	rts
;
;
clear_ifilt:
	lea	ifilt_tab,a0
	bra.s	clear_a_filt
;
clear_ofilt:
	lea	ofilt_tab,a0
clear_a_filt:
	move	#256-1,d0
.iz_filt_loop:
	move.b	d0,(a0,d0)
	dbra	d0,.iz_filt_loop
	rts
;
;
patch_font_off:
;
	move.l	conout_limit_p,a0	;Force 8bit display off
	move	conout_limit_0,(a0)
;
	move.l	ext1ld_limit_p,a0	;Prevent type_1 8bit loading
	move	ext1ld_limit_0,(a0)
;
	move.l	editld_limit_p,a0	;Prevent editor 8bit loading
	move	editld_limit_0,(a0)
;
	bsr.s	patch_8bit_off		;Can't have 8bit without font
;
	move.l	font1_ptr_p,a0		;\
	move	font1_ptr_0,(a0)	; \/ Use Michtrons
	move.l	font2_ptr_p,a0		; /\ Internal fonts
	move	font2_ptr_0,(a0)	;/
;
	move.l	font1_limit_p,a0	;\
	move	font1_limit_0,(a0)	; \/ Mask 8bit codes
	move.l	font2_limit_p,a0	; /\ if present
	move	font2_limit_0,(a0)	;/
	rts
;
;
patch_font_on:
	move.l	font1_ptr_p,a0		;\
	move.l	font1_ptr_1,(a0)	; \/ Adopt system font
	move.l	font2_ptr_p,a0		; /\ in either resolution
	move.l	font2_ptr_1,(a0)	;/
;
	move.l	font1_limit_p,a0	;\
	move	font1_limit_1,(a0)	; \/ Show 8bit codes
	move.l	font2_limit_p,a0	; /\ if present
	move	font2_limit_1,(a0)	;/
;
	move.l	editld_limit_p,a0	;Allow editor 8bit loading
	move	editld_limit_1,(a0)
;
	move.l	ext1ld_limit_p,a0	;Allow type_1 8bit loading
	move	ext1ld_limit_1,(a0)
;
	move.l	conout_limit_p,a0	;Force 8bit display on
	move	conout_limit_1,(a0)
	rts
;
;
patch_8bit_off:				;Mask 8 bit codes
	move.l	serin_bxx_p,a0
	move	serin_bxx_0,(a0)
	move.l	conin_bxx_p,a0
	move	conin_bxx_0,(a0)
	rts
;
;
patch_8bit_on:				;Allow 8 bit codes
	bsr.s	patch_font_on		;We require 8bit font
	move.l	serin_bxx_p,a0
	move	serin_bxx_1,(a0)
	move.l	conin_bxx_p,a0
	move	conin_bxx_1,(a0)
	rts
;
;
patch_ifilt_off:
	move.l	serin_filt_p,a0
	movem.w	serin_filt_0,d0-d2
	movem.w	d0-d2,(a0)
	move.l	conin_filt_p,a0
	movem.w	conin_filt_0,d0-d2
	movem.w	d0-d2,(a0)
	rts
;
;
patch_ifilt_on:
	move.l	serin_filt_p,a0
	movem.w	serin_filt_1,d0-d2
	movem.w	d0-d2,(a0)
	move.l	conin_filt_p,a0
	movem.w	conin_filt_1,d0-d2
	movem.w	d0-d2,(a0)
	rts
;
;
patch_ofilt_off:
	move.l	conout_filt_p,a0
	movem.w	conout_filt_0,d0-d2
	movem.w	d0-d2,(a0)
	rts
;
;
patch_ofilt_on:
	move.l	conout_filt_p,a0
	movem.w	conout_filt_1,d0-d2
	movem.w	d0-d2,(a0)
	rts
;
;
_Start:
	link	a6,#-2
	bsr	_Hej
	gemdos	Super,!
	move.l	d0,initial_SSP
	moveq	#8,d0
	tst	(_longframe).w
	bne.s	.keep_frame
	moveq	#6,d0
.keep_frame:
	move	d0,st_frame_size
	move.l	#norm_mfp_tb,-(sp)
	bsr	read_mfp
	addq	#4,sp
	move.l	#norm_vector_tb,-(sp)
	bsr	read_vectors
	addq	#4,sp
	gemdos	Super|_ind,initial_SSP
	bios	Setexc,#$21,?			;get old gemdos vector
	move.l	d0,nu_gemdos_XB+8
	bios	Setexc,#$21,nu_gemdos_XB+12	;set new gemdos vector
	move.l	#$62250,-(sp)	;bbs program RAM requirement
	clr.l	-(sp)		;bbs program env. (NULL)
	pea	null_s(pc)	;bbs program args (NUL,NUL)
	pea	bbs_tos_s(pc)	;bbs program name ("BBS.TOS")
	bsr	start_BBS
	move.l	d0,d7
	adda	#$10,sp
	bios	Setexc|_ind,#$21,nu_gemdos_XB+8	;reset old gemdos vector
	move.l	d7,d0
	unlk	a6
	rts
;
;
;-----------------------------------------------------------------------------
;
	data
;
;-----------------------------------------------------------------------------
;
st_frame_size
	dc.w	0
nu_gemdos_lock:
	dc.w	0
;
MT_X_name_s:
	dc.b	' MichTron eXtension ',NUL
version_s:
	dc.b	' version 4.0 (Beta) ',NUL
crlf_s:
	dc.b	CR,LF,NUL
patching_s:
	dc.b	' Patching Michtron font.'
	dc.b	CR,LF,NUL
wrong_MT_s:
	dc.b	' Error! Program size is wrong!',CR,LF,BEL
	dc.b	' You can not use packed BBS.TOS,',CR,LF
	dc.b	' unless you have xAFX or similar.',CR,LF
	dc.b	CR,LF,NUL
hex_table_s:
	dc.b	'0123456789ABCDEF',NUL
	even
;
main_stk_size:
	dc.l	main_stk_need
null_s:
	dc.w	0
bbs_tos_s:
	dc.b	'BBS.TOS',NUL
SysSSP_s:
	dc.b	'SysSSP  ',NUL
MaxMinne_s:
	dc.b	'MaxMinne',NUL
StkSize_s:
	dc.b	'StkSize ',NUL
Usp_s:
	dc.b	'Usp     ',NUL
Ssp_s:
	dc.b	'SSP     ',NUL
Debuginfo_s:
	dc.b	'----Debuginfo-----',NUL
Underline_s:
	dc.b	'------------------',NUL
	even
;
;-----------------------------------------------------------------------------
;
	bss
;
;-----------------------------------------------------------------------------
;
basepage_p:	ds.l	1
hex_pos:	ds.w	1
hex_buff_s:	ds.b	8
hex_buff_term:	ds.w	1
cmd_arg_p:	ds.l	1
cmd_arglen:	ds.w	1
SSP_diff:	ds.l	1
LC0A:		ds.b	4
LC0E:		ds.b	4
LC12:		ds.b	4
progname_s:	ds.b	128
prog_arg_c:	ds.b	1
prog_arg_s:	ds.b	127
log_name_s:	ds.b	128
LD9A:		ds.b	save_stk_need
stk_save_size:	ds.b	14
L10C8:		ds.b	2		;this variable now disused
log_handle:	ds.b	2
prog_result:	ds.b	4
bbs_vector_tb:	ds.b	164
bbs_mfp_tb:	ds.b	48
main_stack:	ds.b	main_stk_need
initial_SSP:	ds.b	4
norm_vector_tb:	ds.b	164
norm_mfp_tb:	ds.b	48
sr_save:	ds.w	1		;saves status during interrupt disables
font_array:	ds.b	4096
flag_array:	ds.b	256/8
ifilt_tab:	ds.b	256
ofilt_tab:	ds.b	256
;
;
font2_limit_p:		ds.l	1
font2_ptr_p:		ds.l	1
font1_limit_p:		ds.l	1
font1_ptr_p:		ds.l	1
editld_limit_p:		ds.l	1
serin_filt_p:		ds.l	1
serin_bxx_p:		ds.l	1
conout_filt_p:		ds.l	1
conout_limit_p:		ds.l	1
ext1ld_limit_p:		ds.l	1
conin_filt_p:		ds.l	1
conin_bxx_p:		ds.l	1
;
editld_limit_0:		ds.w	1
editld_limit_1:		ds.w	1
serin_bxx_0:		ds.w	1
serin_bxx_1:		ds.w	1
conout_limit_0:		ds.w	1
conout_limit_1:		ds.w	1
ext1ld_limit_0:		ds.w	1
ext1ld_limit_1:		ds.w	1
conin_bxx_0:		ds.w	1
conin_bxx_1:		ds.w	1
font1_limit_0:		ds.w	1
font1_limit_1:		ds.w	1
font1_ptr_0:		ds.l	1
font1_ptr_1:		ds.l	1
font2_limit_0:		ds.w	1
font2_limit_1:		ds.w	1
font2_ptr_0:		ds.l	1
font2_ptr_1:		ds.l	1
;
;
;-----------------------------------------------------------------------------
	end	;of file:	MT_X.S
;-----------------------------------------------------------------------------
