;----------------------------------------------------------------------------
; File name:	FaRD.S				Revision date:	1997.02.03
; Disassembler:	U.R.Andersson			Creation date:	1992.04.28
; Purpose:	Reset-proof fast ramdisk	Version:	1.2
;----------------------------------------------------------------------------
;
stack_size	=	$1000
FaRDDATE	=	$19970203	;identification code (not version date)
;NB: Identification is made by checking this code in high RAM during boot
;NB: But XBRA chains are also tested to avoid dual installation
;
	include	URAn_SYS.S
	include	URAn_DOS.S
	include	URAn_XB.S	; This defines 9 macros handling XBRA protocol
;
;----------------------------------------------------------------------------
;
	text
;
;----------------------------------------------------------------------------
;
	opt	a+
	opt	o+
;
;----------------------------------------------------------------------------
;
text_base:
tb:
	bra	startup
;
;----------------------------------------------------------------------------
;
	data
;
;----------------------------------------------------------------------------
;
static		;static data uses only positive indexing
;
OS_calljump_s:	dc.w	$4EF9		;32bit abs jump instruction
OS_calllink_s:	dc.l	0		;address for jump above
OS_callsave_s:	dc.l	0,0		;place for saved a1 & a2
;
not_got_mem_s:
	dc.b	'Not enough free memory available.     ',CR,LF,NUL
max_inf_s:
	dc.b	'A:\FARD.INF',NUL
	dcb.b	20,NUL
maxbort_s:
	dc.b	CR,LF
	dc.b	'FaRD installation aborted.'
crlf_s:
	dc.b	CR,LF,NUL
BS_SP_BS_s:
	dc.b	BS,' ',BS,NUL
free_mem_s:
	dc.b	'Free Memory  ==>  ',NUL
bytes_s:
	dc.b	'  Bytes'
crlf_twice_s:
	dc.b	CR,LF,CR,LF,NUL
copyright_s:
	dc.b	ESC,'E',ESC,'e',ESC,'v',ESC,'p'
	dc.b	' *** --- Public access freeware --- ***'
	dc.b	' (C) Ulf Ronald Andersson    1997.02.03',ESC,'q'
	dc.b	CR,LF
	dc.b	'F a R D = _Fast_ Ram Disk. Version: 1.2'
	dc.b	CR,LF,NUL
installed_s:
	dc.b	'FaRD re_installed as partition ',NUL
ask_size_s:
	dc.b	'Fast RamDisk size (KByte) =      ',BS,BS,BS,BS,BS,NUL
whichpart_s:
	dc.b	ESC,'A'
	dc.b	'FaRD partition (A=Abort) choice =   ',BS,BS,NUL
error_on_s:
	dc.b	'Error on   : ',NUL
;
chain_react_s:
	dc.b	'FaRD cannot be installed now.',CR,LF
	dc.b	'XBRA-id "FaRD" is already in use.',CR,LF
	dc.b	CR,LF,NUL
;
bad_drive_s:
	dc.b	"FaRD can't accept the specified drive.",CR,LF
	dc.b	CR,LF,NUL
;
bad_size_s:
	dc.b	"FaRD can't accept the specified size.",CR,LF
	dc.b	CR,LF,NUL
;
mpb_err_s:
	dc.b	CR,LF
	dc.b	"FaRD can't find sensible MPB's.",CR,LF
	dc.b	'Please reorder the AUTO folder.',CR,LF,NUL
	even
;
dummy_bs:	;FaRD boot sector
	DC.L	$E9004E4E,$4E4E4E4E,$56022100,$02020100
	DC.L	$02333333,$33F93333,$0C000200,$00004E4E
	DC.L	$4E4E4E4E,$4E4E4E4E,$4E4E4E4E,$4E4E4E4E
	DC.L	$4E4E4E4E,$4E4E4E4E,$4E4E4E4E,$00000000
limit_bs:
;
;
data_end:
;
;----------------------------------------------------------------------------
;
	RSSET	(data_end-static)	;some statics are in BSS too
basepage_p	rs.l	1	;->basepage of fard program
fardbase_p	rs.l	1	;->fard high RAM header
fard_bpb_p	rs.l	1	;->internal BPB in high RAM
data_block_p	rs.l	1	;->fard sectors in high RAM
fard_sectors	rs.w	1	;= total sector count in lo_block + mixblock + hiblock
dummy_bpb	rs.w	9	;external BPB, see URAn_DOS.S for details
INF_buff_1	rs.l	8/4	; 5 bytes minimum for FaRD.INF strings
convbuff	rs.l	12/4	;10 bytes minimum for hex to dec conversion
local_dta	rs.b	512	;sector buffer
static_end	= __RS
;
data_static	= (data_end-static)
bss_static	= (static_end-data_static)
;
;----------------------------------------------------------------------------
;
	text
;
;----------------------------------------------------------------------------
;
	include	FIND_MPB.S
;
;----------------------------------------------------------------------------
;
; FaRD high memory variable offsets, relative to (fardbase_p(a4))
;
	RSRESET
_fard_date		rs.l	1	;long BCD identification date == FaRDDATE
_fard_drive		rs.w	1	;word fard drive number (0..$1A)
_fard_size		rs.w	1	;word fard Kbytes data capacity
_fard_reserve_1		rs.l	4
_fard_reserve_2		rs.w	3
_fard_bpb		rs.w	9	;9 words BPB data
_fard_MAP		rs.l	9999	;map of data sectors
_fard_headend	= _fard_MAP
;
;----------------------------------------------------------------------------
;
install_vectors:
	move.l	fard_bpb_p(a4),a0
	lea	dummy_bpb(a4),a1
	moveq	#9*2-1,d0
.bpb_fixloop:
	move.b	(a0,d0),(a1,d0)		;copy _fard_bpb to static "dummy_bpb"
	dbra	d0,.bpb_fixloop
	lea	dummy_bs-static(a4),a0
	move	bpb_root_sects(a1),d0
	lsl	#4,d0
	move.b	d0,bs_root_files(a0)
	lsr	#8,d0
	move.b	d0,1+bs_root_files(a0)
	move	bpb_data_clusts(a1),d0
	lsl	#1,d0
	add	bpb_data_start(a1),d0
	move.b	d0,bs_disk_sects(a0)
	lsr	#8,d0
	move.b	d0,1+bs_disk_sects(a0)
	move	bpb_FAT_sects(a1),d0
	rol	#8,d0
	move	d0,bs_FAT_sects(a0)
	move.l	data_block_p(a4),a1
	lea	dummy_bs-static(a4),a0
	move	#limit_bs-dummy_bs,d0
	bsr	move_d0
	moveq	#1,d1
	move.l	fardbase_p(a4),a0
	move	_fard_drive(a0),d3
	asl.l	d3,d1
	lea	(_drvbits).w,a0
	move.l	(a0),d0
	or.l	d1,d0
	move.l	d0,(a0)
	lea	drive_link(pc),a0
	move	d3,(a0)			;init drive-id link
	XB_install	new_hdv_bpb(pc),(hdv_bpb).w
	XB_install	new_hdv_mediach(pc),(hdv_mediach).w
	XB_install	new_hdv_rw(pc),(hdv_rw).w
	move.l	(_v_bas_ad).w,(screenpt).w
	sub_xbios	Vsync
	clr.l	(screenpt).w
	rts
;
;
drive_link:
	dc.w	0	;will be initialized to FaRD drive number
;
;----------------------------------------------------------------------------
;
	XB_define	new_hdv_bpb,'FaRD'
	move	drive_link(pc),d0
	cmp	4(sp),d0
	beq.s	fard_hdv_bpb
	XB_gonext_d	new_hdv_bpb(pc)
;
fard_hdv_bpb:
	lea	dummy_bpb+static(pc),a0
	move.l	a0,d0
	rts
;
;----------------------------------------------------------------------------
;
	XB_define	new_hdv_mediach,'FaRD'
	move	drive_link(pc),d0
	cmp	4(sp),d0
	beq.s	fard_hdv_mediach
	XB_gonext_d	new_hdv_mediach(pc)
;
fard_hdv_mediach:
	clr.l	d0
	rts
;
;----------------------------------------------------------------------------
;
	XB_define	new_hdv_rw,'FaRD'
	move	drive_link(pc),d0
	cmp	14(sp),d0
	beq.s	fard_hdv_rw
	XB_gonext_d	new_hdv_rw(pc)
;
fard_hdv_rw:
	move.l	a4,-(sp)
	lea	static(pc),a4
	move.l	10(sp),a2		;a2->dta
	move.w	14(sp),d2		;d2=sector count
	move.w	16(sp),d1		;d1=start sector
	move.w	8(sp),d0		;d0= rw  even==read  odd==write
	lsr	#1,d0
	bcc.s	.fard_hdv_rw_read
.fard_hdv_rw_write:
	tst	d2
	beq.s	.fard_hdv_rw_OK
	cmp	fard_sectors(a4),d1
	bhs.s	.fard_hdv_rw_error
	lea	(a2),a0			;user dta source
	move.l	data_block_p(a4),a1	;high RAM dest
	move	d1,d0
	swap	d0
	clr	d0
	lsr.l	#7,d0
	adda.l	d0,a1
	bsr.s	move_512
	addq	#1,d1
	adda	#$200,a2
	dbra	d2,.fard_hdv_rw_write	;NB: Pretested, always branches
;
.fard_hdv_rw_read:
	tst	d2
	beq.s	.fard_hdv_rw_OK
	cmp	fard_sectors(a4),d1
	bhs.s	.fard_hdv_rw_error
	move.l	data_block_p(a4),a0	;high RAM source
	move	d1,d0
	swap	d0
	clr	d0
	lsr.l	#7,d0
	adda.l	d0,a0
	lea	(a2),a1			;user dta dest
	bsr.s	move_512
	addq	#1,d1
	adda	#$200,a2
	dbra	d2,.fard_hdv_rw_read	;NB: Pretested, always branches
;
.fard_hdv_rw_OK:
	clr.l	d0
.fard_hdv_rw_exit:
	move.l	(sp)+,a4
	rts
;
.fard_hdv_rw_error:
	moveq	#-1,d0
	bra.s	.fard_hdv_rw_exit
;
;----------------------------------------------------------------------------
;
move_512:
	exg	a0,d0
	btst	#0,d0
	exg	a0,d0
	bne	odd_512
	exg	a1,d0
	btst	#0,d0
	exg	a1,d0
	bne	slow_512
fast_512:
	rept	128
	move.l	(a0)+,(a1)+
	endr
	rts
;
odd_512:
	exg	a1,d0
	btst	#0,d0
	exg	a1,d0
	beq	slow_512
soso_512:
	move.b	(a0)+,(a1)+
	rept	127
	move.l	(a0)+,(a1)+
	endr
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	rts
;
slow_512:
	rept	128
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	endr
move_null:
	rts
move_d0:
	lsl	#1,d0
	neg	d0
	jmp	move_null(pc,d0)
;
;----------------------------------------------------------------------------
;
startup:
	move.l	4(sp),a5	;a5->bp
	move.l	bp_bss_beg_p(a5),d0
	add.l	bp_bss_len(a5),d0
	add.l	#stack_size,d0		;d0 -> stack end
	bclr	#0,d0			;masked even
	move.l	d0,sp			;sp -> new stack end
	sub.l	a5,d0			;d0 -> total RAM needed
	gemdos	Mshrink!_IND,!,a5,d0	;return unused memory to system
	lea	static(pc),a4
	move.l	a5,basepage_p(a4)
	bsr	init_static		;initialize some "static" data
main:
	link	a6,#-12
; word -2 drivenum,  word -4 boot_drivenum,  word -6 & -8 INF_handle,  long -12 entry_SSP
	sub_xbios	Cursconf,!,!
	bsr	show_copyright
	sub_gemdos	Super,!
	move.l	d0,-12(a6)	;entry SSP
	XB_check	new_hdv_bpb(pc),(hdv_bpb).w
	bpl	chain_reaction
	XB_check	new_hdv_mediach(pc),(hdv_mediach).w
	bpl	chain_reaction
	XB_check	new_hdv_rw(pc),(hdv_rw).w
	bpl	chain_reaction
	move.l	(phystop).w,a0
	move.l	a0,fardbase_p(a4)		;iz fardbase_p
	lea	_fard_bpb(a0),a1
	move.l	a1,fard_bpb_p(a4)		;iz fard_bpb_p
	lea	$200(a0),a1
	move.l	a1,data_block_p(a4)		;iz data_block_p
;
	move.l	sp,d7				;d7 -> pre_test stack
	move.l	(ev_buserr).w,d6		;d6 =  original bus error vector
	move.l	#.install_fard,(ev_buserr).w	;prep to iz FaRD on RAM limit bus error
;
	move	_fard_size(a0),d0		;get old size (bus error at limit)
	asl	#1,d0
	move	d0,fard_sectors(a4)
	cmpi.l	#FaRDDATE,_fard_date(a0)	; This maxidisk's date at top ?
	bne.s	.install_fard
;FaRD was already resident, so we just have to warm it up again
	move.l	d6,(ev_buserr).w		;restore original bus error vector
	move.l	d7,sp				;restore pre_test stack pointer
	bsr	install_vectors			;iz all remaining
	bsr	show_warmup
	bra	join_warmcold
;
.install_fard:
	move.l	d6,(ev_buserr).w		;restore original bus error vector
	move.l	d7,sp				;restore pre_test stack pointer
	sub_gemdos	Malloc,?
	cmpi.l	#$11170,d0	;demand 70000 bytes free to init MAXIDISK
	bhs.s	.izmax_1
.bad_memsize:
	sub_gemdos	Cconws,not_got_mem_s-static(a4)
	bra	fnend_main
;
.izmax_1:
	move	(_bootdev).w,d0		;d0 = boot_drive
	add.b	d0,max_inf_s-static(a4)
	sub_gemdos	Fopen,max_inf_s-static(a4),!
	move	d0,-6(a6)		;INF_handle = Fopen(max_inf_s,0)
;
	move	-6(a6),-8(a6)		;copy INF_handle
	clr	-2(a6)
	pea	-2(a6)			;&drive_INF
	pea	-6(a6)			;&INF_handle
	bsr	getINFdata		;size_INF= getINFdata(&INF_handle,&drive_INF)
	addq	#8,sp
	tst	-2(a6)			;drive_INF
	ble	bad_drive_exit		;skip installation if no drive_INF
	tst	d0			;size_INF
	ble	bad_size_exit
	move	d0,-(sp)
	asl	#1,d0
	move	d0,fard_sectors(a4)
	bsr	protallo		;d0= protallo(size_INF)
	addq	#2,sp
	tst.l	d0
	beq	mpb_err_main		;exit with error if pointer is NULL
	move.l	d0,a0
	move.l	a0,fardbase_p(a4)			;iz fardbase_p
	lea	_fard_bpb(a0),a1
	move.l	a1,fard_bpb_p(a4)			;iz fard_bpb_p
	lea	$200(a0),a1
	move.l	a1,data_block_p(a4)			;iz data_block_p
	move	fard_sectors(a4),d0
	lsr	#1,d0
	move	d0,_fard_size(a0)
	move.l	data_block_p(a4),a0
	clr.l	d0
	move	fard_sectors(a4),d0
	lsl.l	#7,d0			;d0= longwords in sector areas
	subq.l	#1,d0
	swap	d0
.clr_data_1:
	swap	d0
.clr_data_2:
	clr.l	(a0)+
	dbra	d0,.clr_data_2
	swap	d0
	dbra	d0,.clr_data_1
	move.l	fardbase_p(a4),a0
	move.l	#FaRDDATE,_fard_date(a0)			;iz _fard_date
	move	-2(a6),_fard_drive(a0)				;iz _fard_drive
	lea	dummy_bpb(a4),a0
	move.l	fard_bpb_p(a4),a1
	moveq	#9-1,d0
.iz_fard_bpb_lp:			;loop start to copy initial BPB from static to high RAM
	move	(a0)+,(a1)+					;iz _fard_bpb
	dbra	d0,.iz_fard_bpb_lp	;loop back for all of BPB
	bsr	install_vectors				;iz all remaining
	move	-6(a6),-(sp)		;INF_handle
	ble.s	L8C6			;skip batch if no INF file
	bsr	batch_INF_commands
L8C6:
	addq	#2,sp
	move	-8(a6),-(sp)
	bsr	close_safe
	addq	#2,sp
L8DE:
	sub_gemdos	Dsetdrv,-4(a6)
	bsr	show_freemem
join_warmcold:
	sub_gemdos	Super!_IND,-12(a6)
	move.l	sp,d0			;take current SP
	sub.l	basepage_p(a4),d0	;subtract BP and use result for size
	sub_gemdos	Ptermres,d0,!
;
;----------------------------------------------------------------------------
;
chain_reaction:
	sub_gemdos	Cconws,chain_react_s(pc)
	bra.s	fnend_main
;
bad_drive_exit:
	sub_gemdos	Cconws,bad_drive_s-static(a4)
	bra.s	maxbort_main
;
bad_size_exit:
	sub_gemdos	Cconws,bad_size_s-static(a4)
	bra.s	maxbort_main
;
mpb_err_main:
	sub_gemdos	Cconws,mpb_err_s-static(a4)
maxbort_main:
	sub_gemdos	Cconws,maxbort_s-static(a4)
	move	-8(a6),-(sp)
	bsr.s	close_safe
	addq	#2,sp
fnend_main:
	sub_gemdos	Super!_IND,-12(a6)
	gemdos	Pterm,?
;
;----------------------------------------------------------------------------
;
close_safe:
	tst	4(sp)
	ble.s	.no_close
	gemdos	Fclose,4(sp)
.no_close:
	rts
;
;----------------------------------------------------------------------------
;
show_copyright:
	sub_gemdos	Cconws,copyright_s-static(a4)
	rts
;
;----------------------------------------------------------------------------
;
show_warmup:
	sub_gemdos	Cconws,installed_s-static(a4)
	move	#'A',d0
	add	drive_link(pc),d0
	sub_gemdos	Cconout,d0
	sub_gemdos	Cconws,crlf_twice_s-static(a4)
show_freemem:
	sub_gemdos	Cconws,free_mem_s-static(a4)
	sub_gemdos	Malloc,?
	move.l	d0,-(sp)
	bsr	ultoa
	addq.l	#4,sp
	sub_gemdos	Cconws!_IND,d0
	sub_gemdos	Cconws,bytes_s-static(a4)
	rts
;
;----------------------------------------------------------------------------
;
; long	getINFdata(*handle_p, *drive_INF_p);	/* returns size in KB */
getINFdata:
	link	a6,#-4			;local short mem_FREE, size_INF; /* KB */
	bsr.s	show_freemem
	clr	-2(a6)
	sub_gemdos	Malloc,?
	lsr.l	#8,d0
	lsr.l	#2,d0
	sub	#30,d0
	ble	.fnend_getINFdata
	cmp	#34,d0
	blt	.fnend_getINFdata
	move	d0,-4(a6)
.reask_size:
	sub_gemdos	Cconws,ask_size_s-static(a4)
	move.l	8(a6),-(sp)	;INF_handle_p
	move	#'9',-(sp)	;'9'
	move	#'0',-(sp)	;'0'
	move	#4,-(sp)	;4
	pea	INF_buff_1(a4)	;&
	bsr	fgets_masked
	adda	#14,sp
	pea	INF_buff_1(a4)
	bsr	strtoul
	addq.l	#4,sp
	move	d0,-2(a6)
	beq	.fnend_getINFdata
	cmpi	#30,d0
	blo.s	.reask_size
	move	d0,dummy_bpb+bpb_data_clusts(a4)
	move	d0,d1
	add	#$FF,d0
	lsr	#8,d0
	move	d0,dummy_bpb+bpb_FAT_sects(a4)
	move	d0,dummy_bpb+bpb_data_start(a4)
	addq	#1,d0
	move	d0,dummy_bpb+bpb_FAT2_start(a4)
	add	d0,dummy_bpb+bpb_data_start(a4)
	move	d1,d0
	lsr	#8,d0		;add 16 root_dirs per 256 data clusters
	addq	#5,d0
	move	d0,dummy_bpb+bpb_root_sects(a4)
	add	d0,dummy_bpb+bpb_data_start(a4)
	clr.l	d0
	move	dummy_bpb+bpb_data_start(a4),d0
	addq	#2,d0		;1 for header + 1 for rounding up
	lsr.l	#1,d0
	move.l	d0,prot_struct+prot_ramloss-static(a4)
	add	dummy_bpb+bpb_data_clusts(a4),d0
	cmp	-4(a6),d0
	bhi	.reask_size
	sub_gemdos	Cconws,crlf_s-static(a4)
	sub_bios	Kbshift,#$10
.reask_drive:				;Loop start
	sub_gemdos	Cconws,whichpart_s-static(a4)
	move.l	8(a6),-(sp)	;INF_handle_p
	move	#'Z',-(sp)	;'Z'
	move	#'C',-(sp)	;'C'
	move	#1,-(sp)	;1
	pea	INF_buff_1(a4)
	bsr	fgets_masked
	adda	#$E,sp
	lea	INF_buff_1(a4),a0
	move.b	(a0),d0
	ext.w	d0
	sub	#'A',d0
	ble.s	.fnend_getINFdata
	move.l	12(a6),a0
	move	d0,(a0)		;store drive_INF
	lea	INF_buff_1(a4),a0
	move.b	(a0),d0
	tst.b	d0
	beq.s	.reask_drive		;Loop back if illegal drivespec
	moveq	#1,d0		;d0= 1L
	move.l	12(a6),a0
	move	(a0),d3		;d3= drive
	asl.l	d3,d0		;d0= drive bit
	and.l	(_drvbits).w,d0
	bne.s	.reask_drive		;also loop back if drive already logged
	sub_bios	Kbshift,!
.fnend_getINFdata:
	clr.l	d0
	move	-2(a6),d0
	unlk	a6
	rts
;
;----------------------------------------------------------------------------
;
;batch_INF_commands(INF_handle)
batch_INF_commands:
;word  +8(a6) =  INF handle			int	INF_handle;
	link	a6,#-20
;long  -4(a6) -> INF buffer start		char	*INF_beg_p;
;long  -8(a6) -> INF buffer position		char	*INF_pos_p;
;long -12(a6) -> command string			char	*cmd_beg_p;
;long -16(a6) -> argument string		char	*arg_beg_p;
;byte -17(a6) =  argument end character		char	arg_end_ch;
;byte -18(a6) =  extra work character		char	arg_ext_ch;
;word -20(a6) =  INF buffer data length		int	INF_len;
	sub_gemdos	Malloc,#1000
	move.l	d0,-4(a6)			;INF_beg_p = Malloc(1000);
	beq	fnend_batch_INF			;if (INF_beg_p==NULL) goto fnend_batch_INF
	sub_gemdos	Fread!_IND,8(a6),#998,-4(a6)
	move	d0,-20(a6)			;INF_len = Fread(INF_handle,998,INF_beg_p);
	clr.b	d0
	move.l	-4(a6),a0
	adda	-20(a6),a0
	move.b	d0,1(a0)			;INF_beg_p[INF_len+1] = '\0';
	move.b	d0,(a0)				;INF_beg_p[INF_len+0] = '\0';
	move.l	-4(a6),-8(a6)			;INF_pos_p = INF_beg_p;
L1002:					;do {	/* until (*INF_pos_p == '\0') */
	bra.s	L100A
;
L1006:					;\
	addq.l	#1,-8(a6)		; |
L100A:					; |
	move.l	-8(a6),a0		; |
	move.b	(a0),d0			; |
	cmp.b	#' ',d0			; |
	beq.s	L1006			; |
	cmp.b	#HT,d0			;  >	;while strpos(" \t\r\n\f",*INF_pos_p)
	beq.s	L1006			; |	;	INF_pos_p++;
	cmp.b	#CR,d0			; |
	beq.s	L1006			; |
	cmp.b	#LF,d0			; |
	beq.s	L1006			; |
	cmp.b	#FF,d0			; |
	beq.s	L1006			;/
	move.l	-8(a6),-12(a6)			;cmd_beg_p = INF_pos_p;
	bra.s	L1068
;
L1064:					;\
	addq.l	#1,-8(a6)		; |
L1068:					; |
	move.l	-8(a6),a0		; |
	move.b	(a0),d0			; |
	beq.s	L10C2			; |
	cmp.b	#' ',d0			; |
	beq.s	L10C2			;  >	;while !strpos(" \t\r\n\f",*INF_pos_p)
	cmp.b	#HT,d0			; |	;	INF_pos_p++;
	beq.s	L10C2			; |
	cmp.b	#CR,d0			; |
	beq.s	L10C2			; |
	cmp.b	#LF,d0			; |
	beq.s	L10C2			; |
	cmp.b	#FF,d0			; |
	bne.s	L1064			; |
L10C2:					;/
	cmp.b	#' ',d0		;\
	beq.s	L10E2		; |
	cmp.b	#HT,d0		;  >		;if strpos(" \t",*INF_pos_p)
	bne.s	L1178		; |		;{
L10E2:				;/
	move.l	-8(a6),a0		;\
	addq.l	#1,-8(a6)		; >	;	*INF_pos_p++ = '\0';
	clr.b	(a0)			;/
	bra.s	L10F4		;\
;				; |
L10F0:				; |
	addq.l	#1,-8(a6)	; |
L10F4:				; |
	move.l	-8(a6),a0	;  >		;	while strpos(" \t",*INF_pos_p)
	move.b	(a0),d0		; |		;		INF_pos_p++
	cmp.b	#' ',d0		; |
	beq.s	L10F0		; |
	cmp.b	#HT,d0		; |
	beq.s	L10F0		;/
	move.l	-8(a6),-16(a6)			;	arg_beg_p = INF_pos_p;
	move.l	-8(a6),a0
	addq.l	#1,-8(a6)
	move.b	(a0),-17(a6)			;	arg_end_ch = *INF_pos_p++;
	move.l	-16(a6),a0
	clr.b	(a0)				;	*arg_beg_p = '\0';
	bra.s	L1150
;
L1130:				;\
	move.b	-17(a6),-18(a6)	; |
	move.l	-8(a6),a0	; |
	move.b	(a0),-17(a6)	; |
	addq.l	#1,-8(a6)	; |
	move.b	-18(a6),(a0)	; |
	move.l	-16(a6),a0	; |
	addq.b	#1,(a0)		;  >		;	while !strpos("\0\r\n",arg_end_ch)
L1150:				; |		;	{	arg_ext_ch = arg_end_ch;
	move.b	-17(a6),d0	; |		;		arg_end_ch = *INF_pos_p;
	beq.s	L1174		; |		;		*INF_pos_p++ = arg_ext_ch;
	cmp.b	#CR,d0		; |		;		*arg_beg_p += 1;
	beq.s	L1174		; |		:	}
	cmp.b	#LF,d0		; |
	bne.s	L1130		; |
L1174:				;/
	bra.s	L1188				;}
;						;else	/* no argument to command */
L1178:						;{
	move.l	-8(a6),-16(a6)			;	arg_beg_p = INF_pos_p;
	move.l	-8(a6),a0	;\
	addq.l	#1,-8(a6)	; >			*INF_pos_p++ = '\0'
	clr.b	(a0)		;/
L1188:						;} /* endif */
	move.l	-12(a6),a0
	move.b	(a0),d0
	beq	L1222				;if (*cmd_beg_p != 0
	sub_gemdos	Pexec!_IND,!,-12(a6),-16(a6),!
	tst.l	d0
	bge.s	L1222				;    && Pexec(cmd_beg_p,arg_beg_p,0) < 0)
;						;{
	sub_gemdos	Cconws,error_on_s-static(a4)
	sub_gemdos	Cconws!_IND,-12(a6)
	sub_gemdos	Cconout,#$20
	move.l	-16(a6),a0	;\
	addq.l	#1,-16(a6)	; >		;	arg_ext_ch = *arg_beg_p++;
	move.b	(a0),-18(a6)	;/
	bra.s	L1206
L11EE:
	move.l	-16(a6),a0
	addq.l	#1,-16(a6)
	move.b	(a0),d0
	ext.w	d0
	sub_gemdos	Cconout,d0
L1206:
	move.b	-18(a6),d0
	subq.b	#1,-18(a6)
	tst.b	d0
	bne.s	L11EE
	sub_gemdos	Cconws,crlf_s-static(a4)
L1222:						;} /* endif */
	move.l	-8(a6),a0	;\
	move.b	(a0),d0		; >	} until (*INF_pos_p == '\0')
	bne	L1002		;/
fnend_batch_INF:
	sub_gemdos	Mfree!_IND,-4(a6)
	unlk	a6
	rts
;
;----------------------------------------------------------------------------
;
; short	 fgets_masked(*chbufp,maxcnt,minchar,maxchar,*handlep)
fgets_masked:
	link	a6,#-4
	sub_xbios	Cursconf,#1,!
	clr	-4(a6)		;curpos= 0
.LAAE:
	move.l	18(a6),a0
	tst	(a0)
	ble.s	.LB58		;go .LB58 if handle is for a non-file device
.LABA:	;here we read from some file
	clr.b	-1(a6)		;ch= 0
	move.l	18(a6),a0	;a0->handle
	sub_gemdos	Fread,(a0),#1,-1(a6)
	move.b	-1(a6),d0
	cmp.b	#'a',d0
	blt.s	.LB04
	cmp.b	#'z',d0
	bgt.s	.LB04
	sub.b	#' ',d0
	move.b	d0,-1(a6)
.LB04:
	bsr	is_white
	bne.s	.LB66		;go admit non-whitespace
.LB4A:
	tst	-4(a6)
	beq.s	.LABA		;Loop if curpos==0
	bra.s	.LB66
;
.LB58:	;here we read from some device (like CON:)
	sub_gemdos	Crawcin
	move.b	d0,-1(a6)
.LB66:
	move.b	-1(a6),d0
	cmp.b	#BS,d0
	bne.s	.LB8E
	move	-4(a6),d0
	beq.s	.LB8E		;don't backspace if curpos==0
	sub_gemdos	Cconws,BS_SP_BS_s-static(a4)
	subq	#1,-4(a6)	;curpos -= 1
.LB8E:
	move	-4(a6),d0
	cmp	12(a6),d0
	bge.s	.LBE6		;go .LBE6 if curpos >= maxcnt
	move.b	-1(a6),d0
	move.b	15(a6),d1
	cmp.b	d1,d0
	blt.s	.LBE6		;go .LBE6 if ch < minchar
	move.b	17(a6),d1
	cmp.b	d1,d0
	bgt.s	.LBE6		;go .LBE6 if ch > maxchar
	sub_gemdos	Cconout,d0	;echo accepted ch
	move	-4(a6),d0
	addq	#1,-4(a6)	;curpos += 1
	move.l	8(a6),a0
	move.b	-1(a6),(a0,d0)		;store accepted ch
	bra.s	.LC46
;
.LBE6:	;here ch is unacceptable
	move.l	18(a6),a0
	tst	(a0)
	ble.s	.LC46		;go .LC46 if reading non-file device
	move.b	-1(a6),d0
	bsr.s	is_white
	beq.s	.LC54		;go .LC54 if whitespace
	move.l	18(a6),a0
	clr	(a0)		;Force reading from console on unacceptable ch
.LC46:
	move.b	-1(a6),d0
	cmp.b	#CR,d0		;Loop until CR
	bne	.LAAE
.LC54:
	sub_gemdos	Cconws,crlf_s-static(a4)
	move.l	8(a6),a0
	adda	-4(a6),a0
	clr.b	(a0)		;terminate string
	sub_xbios	Cursconf,!,!
	move	-4(a6),d0	;return d0= curpos
	unlk	a6
	rts
;
;
is_white:
	cmp.b	#' ',d0
	beq.s	exit_white
	cmp.b	#HT,d0
	beq.s	exit_white
is_endln:
	cmp.b	#CR,d0
	beq.s	exit_white
	cmp.b	#LF,d0
	beq.s	exit_white
	cmp.b	#FF,d0
exit_white:
	rts
;
is_term:
	tst.b	d0
	bne.s	is_endln
	rts
;
is_space:
	cmp.b	#' ',d0
	beq.s	exit_white
	cmp.b	#HT,d0
	rts
;
;----------------------------------------------------------------------------
;
; strtoul(char *digitp)
strtoul:
	link	a6,#-4
	clr.l	-4(a6)	;value= 0
	bra.s	.LCB2
;
.LC84:				;Loop start
	move.l	-4(a6),d0
	asl.l	#2,d0		;d0= value * 4
	add.l	-4(a6),d0	;d0= value * 5
	asl.l	#1,d0		;d0= value * 10
	move.l	8(a6),a0	;a0= digitp
	addq.l	#1,8(a6)	;digitp += 1
	move.b	(a0),d3
	sub.b	#'0',d3		;d3= new bcd digit
	ext.w	d3
	ext.l	d3
	add.l	d3,d0
	move.l	d0,-4(a6)	;value= value*10 + digit
.LCB2:
	move	#'0',d0
	move.l	8(a6),a0
	move.b	(a0),d1		;d1= next ascii digit
	ext.w	d1
	cmp	d1,d0
	bgt.s	.LCD4		;exit loop if '0' > digit
	cmp	#$39,d1
	ble.s	.LC84		;loop back if digit <= '9'
.LCD4:
	move.l	-4(a6),d0
	unlk	a6
	rts
;
;----------------------------------------------------------------------------
;
;char *ultoa(long value)
ultoa:
	link	a6,#-4
	lea	convbuff(a4),a0
	move.l	#$3B9ACA00,-4(a6)	;limit= 1000,000,000
	bra.s	.LD12
;
.LCF8:
	move.l	-4(a6),-(sp)
	move.l	#10,-(sp)
	bsr.s	long_div	;long_div(limit,10)
	move.l	(sp)+,-4(a6)	;limit /= 10
	addq.l	#4,sp
.LD12:
	move.l	8(a6),d0	;d0= value
	cmp.l	-4(a6),d0
	bge.s	.LD2A		;go .LD2A if value >= limit
	cmpi.l	#$1,-4(a6)
	bgt.s	.LCF8		;go .LCF8 if limit >1
;here value>=limit, or limit==1
.LD2A:				;Loop start
	move.l	8(a6),-(sp)
	move.l	-4(a6),-(sp)
	bsr.s	long_div	;long_div(value,limit)
	move.l	(sp)+,d0	;d0= quotient
	move.l	(sp)+,8(a6)	;value= remainder
	add.l	#'0',d0
	move.b	d0,(a0)+	;store new digit
	move.l	-4(a6),-(sp)
	move.l	#10,-(sp)
	bsr.s	long_div	;long_div(limit,10)
	move.l	(sp)+,-4(a6)	;limit /= 10
	addq.l	#4,sp
	bne.s	.LD2A		;loop back for each digit
	clr.b	(a0)		;terminate string
	lea	convbuff(a4),a0
	move.l	a0,d0
	unlk	a6
	rts			;return with d0= a0->convbuff
;
;----------------------------------------------------------------------------
;
; long_div(Divs,Divd)
long_div:
	link	a6,#-2
	movem.l	d0-d3,-(sp)
	move.l	8(a6),d2	;d2= Divs
	bne.b	L1872		;go L1872 unless Divs==0
	divu	#$0,d0		;div by ZERO !!!
	clr.l	d0
	clr.l	d1
	bra.b	L18BC
;
L1872:
	move.l	12(a6),d1	;d1= Divd
	clr	-2(a6)		;x1= 0
	tst.l	d1		;Divd >= 0 ?
	bge.b	L1884
	addq	#3,-2(a6)	;x1+=3
	neg.l	d1		;Divd= abs(Divd)
L1884:
	tst.l	d2		;Divs >= 0
	bge.b	L188E
	addq	#1,-2(a6)	;x1 += 1
	neg.l	d2		;Divs= abs(Divs)
L188E:
	moveq	#1,d3		;d3= 1
L1890:				;loop start
	cmp.l	d1,d2		;Divs - Divd ?
	bhs.b	L189A		;exit loop if Divs >= Divd
	asl.l	#1,d2		;Divs *= 2
	asl.l	#1,d3		;d3 *= 2
	bra.b	L1890		;loop back
;
L189A:
;here d3 is the factor Divs needed to match or exceed Divd
	clr.l	d0		;d0= 0
L189C:				;loop start
	cmp.l	d1,d2		;Divs - Divd ?
	bhi.b	L18A4		;keep Divd & d0 if Divs > Divd
	or.l	d3,d0		;d0 |= d3
	sub.l	d2,d1		;Divd -= Divs
L18A4:
	lsr.l	#1,d2		;Divs /= 2
	lsr.l	#1,d3		;d3 /= 2
	bcc.b	L189C		;loop until d3 lost a bit
;here d0 is the quotient abs(Divd)/abs(Divs)
	cmpi	#3,-2(a6)	;x1 - 3 ?
	blt.b	L18B4		;keep Divd if originally positive
	neg.l	d1		;else negate Divd
L18B4:
	lsr	-2(a6)		;CF = x1 & 1
	bcc.b	L18BC		;keep d0 if orig Divs had sign of Divd
	neg.l	d0		;else negate d0
L18BC:
	move.l	d0,8(a6)	;return quotient in Divs, but NOT in d0
	move.l	d1,12(a6)	;return remainder in Divd
	movem.l	(sp)+,d0-d3
	unlk	a6
	rts			;return from function
;
;----------------------------------------------------------------------------
;
bios_sub:
	movem.l	a1-a2,OS_callsave_s-static(a4)
	move.l	(sp)+,OS_calllink_s-static(a4)
	trap	#13
	movem.l	OS_callsave_s-static(a4),a1-a2
	jmp	OS_calljump_s-static(a4)
;
;------------------------------------
;
xbios_sub:
	movem.l	a1-a2,OS_callsave_s-static(a4)
	move.l	(sp)+,OS_calllink_s-static(a4)
	trap	#14
	movem.l	OS_callsave_s-static(a4),a1-a2
	jmp	OS_calljump_s-static(a4)
;
;------------------------------------
;
gemdos_sub:
	movem.l	a1-a2,OS_callsave_s-static(a4)
	move.l	(sp)+,OS_calllink_s-static(a4)
	trap	#1
	movem.l	OS_callsave_s-static(a4),a1-a2
	jmp	OS_calljump_s-static(a4)
;
;----------------------------------------------------------------------------
;
init_static:
	lea	dummy_bpb(a4),a1
	move	#$200,(a1)+	; 512 sect_bytes
	move	#$2,(a1)+	;   2 clust_sects
	move	#$400,(a1)+	;1024 clust_bytes
	move	#$5,(a1)+	;   5 root_sects => 80 root_files (increased)
	move	#$4,(a1)+	;   4 FAT_sects  => 1024 clusters (ignored)
	move	#$5,(a1)+	;   5 FAT2_start (ignored)
	move	#$E,(a1)+	;  14 data_start (ignored)
	clr	(a1)+	;  data_clusts initialized later
	move	#$1,(a1)+	;  flag 16_bit FAT's  (avoids shifting)
	rts
;
;----------------------------------------------------------------------------
;
	include	protallo.s
;
;----------------------------------------------------------------------------
;
	bss
;
;----------------------------------------------------------------------------
;
	ds.l	(bss_static+3)/4
;
bss_limit:
;
;----------------------------------------------------------------------------
;
	end
;
;----------------------------------------------------------------------------
;End of file:	FaRD.S
;----------------------------------------------------------------------------
