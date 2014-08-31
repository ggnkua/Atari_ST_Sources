;----------------------------------------------------------------------------
; File name:	MAXIDISK.S	Revised:	1993.09.18
; Disassembler:	U.R.Andersson	Disassembled:	1992.01.31
; Version:	2.2
; Purpose:	Packing reset-proof ramdisk.
;----------------------------------------------------------------------------
; Version 2.0:	Added XBRA protocol for all vectors.
;  ...		Added memory checking to avoid current conflicts.
;  ...		Added memory protection for OverScan and other big screens.
;  ...		Total rewrite of BPB handling, for efficient packing.
;  ...		Total rewrite of block allocation, for speedup.
;  ...		Total rewrite of block store/recall for speedup.
;  ...		Total rewrite of Pack/Unpack routines for speed and packing.
;  ...		Elimination of remaining C compiler inefficiencies.
;  ...		Boot sector initialization
;  ...		Mediach update flags
;  ...		Byte-oriented fast_move
;----------------------------------------------------------------------------
; Version 2.1:	Corrected value for bs_disk_sects in simulated boot area
;  ...		Altered find_MPB for better KAOS 1.4.2 compatibility
;----------------------------------------------------------------------------
; Version 2.2:	Altered find_MPB for further compatibility & removed a bug
;  ...		Improved speed for unpacked sectors
;----------------------------------------------------------------------------
; Version 2.3:	Improved for compatibility with MultiTOS 1.08
;----------------------------------------------------------------------------
;
MAXIDATE	equ	$19560221	;identification code
;NB: Identification is made by checking this code in high RAM during boot
;NB: But XBRA chains are also tested to avoid dual installation
;
;----------------------------------------------------------------------------
;
	nolist
	include	TOS\URAn_SYS.S
	include	TOS\URAn_DOS.S
	include	TOS\URAn_XB.S	; This defines 9 macros handling XBRA protocol
;
	text
	opt	a+
	opt	p+
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
static		;static data now uses only positive indexing
;
OS_calljump_s:	dc.w	$4EF9		;32bit abs jump instruction
OS_calllink_s:	dc.l	0		;address for jump above
OS_callsave_s:	dc.l	0,0		;place for saved a1 & a2
;
not_got_mem_s:
	dc.b	'Not enough free memory available.     ',CR,LF,NUL
max_inf_s:
	dc.b	'MAXIDISK.INF',NUL
	dcb.b	20,NUL
maxbort_s:
	dc.b	CR,LF
	dc.b	'Maxidisk installation aborted.'
crlf_s:
	dc.b	CR,LF,NUL
BS_SP_BS_s:
	dc.b	BS,' ',BS,NUL
free_mem_s:
	dc.b	'Free Memory  ==>  ',NUL
bytes_s:
	dc.b	'  Bytes',CR,LF,CR,LF,NUL
copyright_s:
	dc.b	ESC,'E',ESC,'e',ESC,'v',ESC,'p'
	dc.b	' *** Public domain software ***         '
	dc.b	'             (C) Max B”hm    08.08.1987 ',ESC,'q',CR,LF
	dc.b	'This is a resetproof ramdisk that stores'
	dc.b	' more than you would imagine...        ',CR,LF
	dc.b	CR,LF
	dc.b	'R e v i s e d   V e r s i o n   2 . 2 : '
	dc.b	'XBRA protocols & improved compatibility',CR,LF
	dc.b	ESC,'p'
	dc.b	' *** Public domain software ***         '
	dc.b	' (C) Ulf Ronald Andersson    21.05.1992 ',ESC,'q'
	dc.b	CR,LF,NUL
installed_s:
	dc.b	'Installed as partition   ',NUL
instslash_s:
	dc.b	'  /  ',NUL
kb_used_s:
	dc.b	' kB used',CR,LF,CR,LF,NUL
howmany_kb_s:
	dc.b	ESC,'A','Use how many kB ?     ',BS,BS,BS,BS,NUL
whichpart_s:
	dc.b	ESC,'A','Which partition ?  ',BS,NUL
error_on_s:
	dc.b	'Error on   : ',NUL
chain_react_s:
	dc.b	'MAXIDISK cannot be installed now.',CR,LF
	dc.b	'XBRA-id "MAXI" is already in use.',CR,LF
	dc.b	CR,LF,NUL
mpb_err_s:
	dc.b	CR,LF
	dc.b	"MAXIDISK can't find sensible MPB's.",CR,LF
	dc.b	'Please reorder the AUTO folder.',CR,LF,NUL
	even
;
dummy_bs:	;MAXIDISK boot sector !!! did not exist in original (needed by some PRG's)
	DC.L	$E9004E4E,$4E4E4E4E,$56022100,$02020100
	DC.L	$02333333,$33F93333,$0C000200,$00004E4E
	DC.L	$4E4E4E4E,$4E4E4E4E,$4E4E4E4E,$4E4E4E4E
	DC.L	$4E4E4E4E,$4E4E4E4E,$4E4E4E4E,$00000000
	DCB.B	$C0,0
;
;
data_end:
;
;----------------------------------------------------------------------------
;
	RSSET	(data_end-static)	;some statics are in BSS too
basepage_p	rs.l	1	;->basepage of maxidisk program
maxibase_p	rs.l	1	;->maxidisk high RAM == phystop after installation
maxi_MAP_p	rs.l	1	;->maxidisk sector to data_block link map in high RAM
maxi_sectbase_p	rs.l	1	;->maxidisk non_data sectors  (unpacked) in high RAM
maxi_bpb_p	rs.l	1	;->internal BPB in high RAM
URAn_mpb	rs.l	1	;->MPB'variables in OS RAM  (TOS independent search)
URAn_movesize	rs.l	1	;long for size of protected RAM during init (screen etc.)
URAn_movedist	rs.l	1	;long for distance to move protected data during init
URAn_ramloss	rs.l	1	;long for Kbytes taken for non_data use (FAT, root, etc.)
entry_d3_a4	rs.l	2	;holds entry D3 & A4 during hdv_rw calls
entry_retadr	rs.l	1	;holds entry return address during hdv_rw calls
pack_magic	rs.l	2*512	;Packing table, link & bufpos for each sector byte
Keytab		rs.l	256	;256 long pointers into table pack_magic, 1 per byte value
INF_buff_1	rs.l	8/4	; 5 bytes minimum for MAXIDISK.INF strings
convbuff	rs.l	12/4	;10 bytes minimum for hex to dec conversion
dummy_bpb	rs.w	9	;external BPB, see TOS\URAn_DOS.S for details
URAn_smudge	rs.l	1	;long flag to keep track of packing changes
pack_buff	rs.l	$280/4	;packing buffer for packed sector data
static_end	= __RS
;
data_static	= (data_end-static)
bss_static	= (static_end-data_static)
;
;----------------------------------------------------------------------------
;
	text
;
;
	include	TOS\FIND_MPB.S
;
;----------------------------------------------------------------------------
;
;NB:
;NB: Original maxidisk seems to have been created with a C compiler.
;NB: The startup code extended the BSS area with $2000 bytes stack,
;NB: then moved the contents of the DATA area to the end of the
;NB: original BSS area and zeroed the remainder of both areas.
;NB: A4 was set pointing to the moved data, which were strings,
;NB: so strings were indexed positively, other STATIC's negatively.
;NB: Several Kbyte there were devoted to C IO functions not used !
;NB: A6 was used for allocation of AUTO data.
;NB: All this has been abolished, except for the use of A4 and A6.
;NB: The use of A4 is altered, so all indexes are positive.
;NB: DATA and BSS sections now follow standard.
;NB:
;
;----------------------------------------------------------------------------
;
; MAXIDISK high memory variable offsets, relative to (maxibase_p(a4))
;
	RSRESET
_maxi_date		rs.l	1	;long BCD identification date == MAXIDATE
_maxi_drive		rs.w	1	;word maxidisk drive number (0..$1A)
_maxi_size		rs.w	1	;word maxidisk Kbytes data capacity
_maxi_CHAIN_p		rs.l	1	;-> First free block in data block area
_maxi_dspace		rs.l	1	;long == free space in data blocks
_maxi_pspace		rs.l	1	;long == space held by free block pointers
_maxi_reserve_1		rs.l	1
_maxi_reserve_2		rs.w	3
_maxi_bpb		rs.w	9	;9 words BPB data
_maxi_MAP		rs.l	9999	;map of data block pointers for logical sectors
_maxi_headend	= _maxi_MAP
;
;NB: twice as many logical sectors may be used, than would be for unpacked data
;NB: so the number available is dependent on how data can be packed.
;
;
;NB: The BPB is non_standard, in that twice the number of physical clusters
;NB: is used for "bpb_data_clusts". Those not available have FATs = $FFF7 .
;NB: As clusters are stored in packed format, these "BAD" clusters can then
;NB: be released, by changing their FATs to $0000 (free).
;NB: Unfortunately, the original allowed packing only on small RAM disks,
;NB: since no extra FATs and map pointers were added to large ones.
;NB: This seems to have caused some confusion amongst the subroutines, as to
;NB: whether "bpb_data_clusts" means sectors or clusters available.
;NB:
;NB: I have fixed it so all sizes use "bpb_data_clusts" at twice the size
;NB: of the physical data area requested, with the same number of map pointers.
;NB: This means all sizes have an extra overhead cost, but this is compensated
;NB: for by the area gained through packing.
;NB: EG:	Size requested	= 1200 Kbyte	= 1 228 800 bytes
;NB:		Total RAM cost	= 1269 Kbyte	= 1 299 456 bytes
;NB:		Stored data	= 1565 Kbyte	= 1 602 606 bytes
;NB: This was tested with the files on my program testing diskette, which is quite
;NB: dominated by program files. Text files should pack even tighter.
;
;----------------------------------------------------------------------------
;
install_vectors:
	move.l	maxi_bpb_p(a4),a0
	lea	dummy_bpb(a4),a1
	moveq	#9*2-1,d0
.bpb_fixloop:
	move.b	(a0,d0),(a1,d0)	;copy _maxi_bpb to static "dummy_bpb"
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
	move.l	maxi_sectbase_p(a4),a1
	move	#256,d0
	bsr	fast_move
	XB_install	new_hdv_bpb(pc),(hdv_bpb).w
	XB_install	new_hdv_mediach(pc),(hdv_mediach).w
	XB_install	new_hdv_rw(pc),(hdv_rw).w
	moveq	#1,d1
	move.l	maxibase_p(a4),a0
	move	_maxi_drive(a0),d3
	asl.l	d3,d1
	lea	(_drvbits).w,a0
	move.l	(a0),d0
	or.l	d1,d0
	move.l	d0,(a0)
	lea	drive_link(pc),a0
	move	d3,(a0)			;init drive-id link
	rts
;
;
drive_link:
	dc.w	0	;will be initialized to MAXIDISK drive number
;
;----------------------------------------------------------------------------
;
	XB_define	new_hdv_bpb,'MAXI'
	move	drive_link(pc),d0
	cmp	4(sp),d0
	beq.s	maxi_hdv_bpb
	XB_gonext_d	new_hdv_bpb(pc)
;
maxi_hdv_bpb:
	lea	dummy_bpb+static(pc),a0
	move.l	a0,d0
	rts
;
;----------------------------------------------------------------------------
;
	XB_define	new_hdv_mediach,'MAXI'
	move	drive_link(pc),d0
	cmp	4(sp),d0
	beq.s	maxi_hdv_mediach
	XB_gonext_d	new_hdv_mediach(pc)
;
maxi_hdv_mediach:
	lea	static(pc),a0
	tst.b	1+URAn_smudge(a0)
	beq.s	.media_ok
	sf	1+URAn_smudge(a0)
	moveq	#1,d0
	rts
;
.media_ok:
	clr.l	d0
	rts
;
;----------------------------------------------------------------------------
;
	XB_define	new_hdv_rw,'MAXI'
	move	drive_link(pc),d0
	cmp	14(sp),d0
	beq.s	maxi_hdv_rw
	XB_gonext_d	new_hdv_rw(pc)
;
maxi_hdv_rw:
	lea	static(pc),a0
	movem.l	d3/a4,entry_d3_a4(a0)
	move.l	a0,a4
	move.l	(sp)+,entry_retadr(a4)
	bsr.s	maxi_hdv_rw_func
	move.l	entry_retadr(a4),-(sp)
	movem.l	entry_d3_a4(a4),d3/a4
	rts
;
;----------------------------------------------------------------------------
;
; Beyond this point all code (almost) assumes a4 -> runtime "static"
;
;
;long	maxi_hdv_rw_func(rw,int *buf_p,size,startsect,drive)
maxi_hdv_rw_func:
	link	a6,#-12
	movem.l	d4-d7/a2-a3,-(sp)
	move.l	10(a6),a3		;a3->buffer area
	clr.l	d7
	move	16(a6),d7		;d7.L= startsect (logical not physical)
	bra	.hdv_rw_start
;
;
.hdv_rw_loop:
	move.l	d7,d0			;d0= d7= next secnum
	move.l	maxi_bpb_p(a4),a0
	cmp	bpb_data_start(a0),d0	;secnum >= data_start ?
	bhs	.hdv_rw_datasect
;Here we only deal with sectors below data_start
	move.l	d7,d1
	asl.l	#8,d1
	asl.l	#1,d1			;d1= secnum * $200 = byte offset
	move.l	maxi_sectbase_p(a4),a2
	adda.l	d1,a2			;a2->sector area
	move	8(a6),d0		;d0= rw
	and	#1,d0			;even==read  odd==write
	beq	.hdv_rw_simple_read
.hdv_rw_write_undata:	;Here to read non_data sector
	move.l	maxi_bpb_p(a4),a0
	cmp	bpb_FAT2_start(a0),d7
	blo	.hdv_rw_simple_write	;go move it if writing below FAT2
	move	bpb_FAT2_start(a0),d0
	add	bpb_FAT_sects(a0),d0	;d0= secnum beyond FAT2
	cmp	d0,d7
	bhs	.hdv_rw_simple_write	;go move it if writing beyond FAT2
	moveq	#2,d6
	cmp	bpb_FAT2_start(a0),d7
	beq.s	.hdv_rw_write_FAT2	;use d6=2 if d7 is first sector of FAT2 (reserved)
	clr.l	d6			;use d6=0 for d7 sector not first in FAT2
.hdv_rw_write_FAT2:		;Here we are writing a FAT2 sector
.hdv_rw_release_FATs_1:			;loop 1 start to release blocks for deleted clusters
;Here d6.L= cluster_index for release checking
	move.l	d6,d0
	asl.l	#1,d0
	tst	(a3,d0.l)			;zero FAT(d6) in sector d7 ?
	bne.s	.hdv_rw_release_next	;go .hdv_rw_release_next if FAT(d6) non_zero
	tst	(a2,d0.l)
	beq.s	.hdv_rw_release_next	;go .hdv_rw_release_next if FAT already zeroed
;Here we must free space & FAT previously used for cluster_index  d6 in sector d7
	move.l	d7,d5
	move.l	maxi_bpb_p(a4),a0
	sub	bpb_FAT2_start(a0),d5	;d5= secnum - FAT2_start
	asl.l	#8,d5			;d5 *= $100
	add.l	d6,d5			;d5 += d6  (==data cluster number)
	subq.l	#2,d5			;d5 -= 2
	asl.l	#3,d5			;d5 *= 8
	moveq	#2-1,d4			;prep to loop twice for 2 sectors of cluster
;Here d5= ((secnum-FAT2_start)*$100+cluster_index-2)*8  == map_index(byte)
.hdv_rw_release_FATs_2:				;loop 2 start
	move.l	maxi_MAP_p(a4),a0
	move.l	(a0,d5.l),-(sp)			;->1'st block of old sector, or is NULL
	clr.l	(a0,d5.l)			;map freed sector as free
	jsr	allocate_block(pc)		;allocate_block(old_block_p)
	addq	#4,sp
.hdv_rw_relhalf:
;Here the block chain used by half cluster has been released
	addq.l	#4,d5				;d5= next map_index(long)
	dbra	d4,.hdv_rw_release_FATs_2	;loop 2 back to release 2 sectors of cluster
.hdv_rw_release_next:	;Here a FAT in FAT2 sector is OK, but there are 256 per sector
	addq.b	#1,d6
	bcc.s	.hdv_rw_release_FATs_1	;loop 1 back to release blocks of more FATs in sector d7
;Here all clusters deleted, by writing sector d7, have had their blocks released
	tst.b	URAn_smudge(a4)		;any size change?
	beq	.hdv_rw_simple_write	;skip size checking if no change
	st	1+URAn_smudge(a4)	;flag size adjustment to change (for hdv_mediach !)
	sf	URAn_smudge(a4)		;adjust for each change once only
	move.l	maxibase_p(a4),a0
	move.l	_maxi_dspace(a0),-4(a6)	;-4(a6) = free data space
	move.l	_maxi_pspace(a0),-8(a6)	;-8(a6) = free pointer space
	move.l	maxi_bpb_p(a4),a0
	clr.l	d4
	move	bpb_FAT2_start(a0),d4	;d4.L= first FAT2 sector
.hdv_rw_check_FATs_1:			;loop 1 start to check all sectors of FAT2
;Here d4.L= FAT sector to check FATs in, and will pass through all of FAT2
	move.l	a3,d0
	cmp	d7,d4
	beq.s	.L2FC			;go .L2FC with d0=a3 if d4==d7 (->future FAT data)
	move.l	maxi_sectbase_p(a4),d0
	move.l	d4,d1
	asl.l	#8,d1
	asl.l	#1,d1			;d1= d4 * $200
	add.l	d1,d0			;d0= sectbase + d4 * $200 (->present FAT data)
.L2FC:
	move.l	d0,-12(a6)		;-12(a6) -> buffer for sector d4 (future/present!)
	clr.l	d6
	move.l	maxi_bpb_p(a4),a0
	cmp	bpb_FAT2_start(a0),d4
	bne.s	.hdv_rw_check_FATs_2	;use d6= 0 unless d4 is first in FAT2
	moveq	#2,d6			;use d6= 2 if d4 first in FAT2 (reserved)
.hdv_rw_check_FATs_2:			;loop 2 start to check all FAT's in sector d4
;Here d6.L= cluster_index for FAT checking
	move.l	-12(a6),a0		;a0->sector d4 buffer
	move.l	d6,d0
	asl.l	#1,d0
	tst	(a0,d0.l)		;test d6'th FAT in sector d4
	beq.s	.alter_FAT		;go .alter_FAT for free cluster
	cmpi	#$F7FF,(a0,d0.l)
	bne.s	.hdv_rw_check_next	;go check next if cluster OK
;Here we found a FAT to alter from FREE or BAD to whatever we have room for
.alter_FAT:
	subi.l	#$400,-4(a6)		;reduce check dspace by 1 cluster
	bge.s	.show_FAT
.hide_FAT:
	move	#$F7FF,(a0,d0.l)	;no room => mark it as BAD
	bra.s	.hdv_rw_check_next
;
;Here we found a free or BAD FAT that must be free
.show_FAT:
	clr	(a0,d0.l)		;mark cluster FAT free
	subq.l	#8,-8(a6)		;reduce check pspace by 1 block head
	bge.s	.show_FAT_2
.show_FAT_1:
	sub.l	#16,-4(a6)		;reduce check dspace by 2 block heads
	bge.s	.hdv_rw_check_next
	bra.s	.hide_FAT
;
.show_FAT_2:
	subq.l	#8,-8(a6)		;reduce check pspace by 1 block head
	bge.s	.hdv_rw_check_next
	subq.l	#8,-4(a6)		;reduce check dspace by 1 block head
.hdv_rw_check_next:
	addq.b	#1,d6
	bcc.s	.hdv_rw_check_FATs_2	;loop 2 back to check more FAT's in sector d4
	addq	#1,d4			;d4= next sector to check
	move.l	maxi_bpb_p(a4),a0
	move	bpb_FAT2_start(a0),d0
	add	bpb_FAT_sects(a0),d0
	cmp	d0,d4
	blo	.hdv_rw_check_FATs_1	;loop 1 back if d4 is a secnum within FAT2
;Here all is checked and we can finally accept the new FAT2 sector data
.hdv_rw_simple_write:		;Here we write any non_data sector data (boot & FATs)
	move.l	a3,a0
	move.l	a2,a1
	bsr	move_512
	bra	.hdv_rw_next_step_a3
;
;
.hdv_rw_simple_read:		;Here to read non_packed sectors
	move.l	a2,a0
	move.l	a3,a1
	bsr	move_512
	bra	.hdv_rw_next_step_a3
;
;
;Here packed data sector d7 must be accessed
.hdv_rw_datasect:
	move.l	d7,d4
	move.l	maxi_bpb_p(a4),a0
	sub	bpb_data_start(a0),d4
	asl.l	#2,d4			;d4.L= 4*(secnum-data_start)  (==map offset)
	move	8(a6),d0
	and	#1,d0			;even==read  odd==write
	beq	.hdv_rw_read_data
.hdv_rw_write_data:
;Here packed data sector d7 must be written
	move.l	maxi_MAP_p(a4),a0
	move.l	(a0,d4.l),-(sp)		;->1'st block of old sector, or is NULL
	jsr	allocate_block(pc)	;allocate_block(old_block_p)
	addq.l	#4,sp
;Here old blocks of sector d7 are free, and a new available via _maxi_CHAIN_p
	pea	-4(a6)			;&size  of packed data (future)
	pea	pack_buff(a4)		;&pack_buff
	pea	$200(a3)		;&sector_dta + 512
	pea	(a3)			;&sector_dta
	jsr	pack_sector(pc)		;pack_sector(bufbeg_p,bufend_p,pack_p,size_p)
	adda	#16,sp
	move.l	-4(a6),-(sp)		;size  of packed data
	pea	pack_buff(a4)		;&pack_buff
	move.l	maxi_MAP_p(a4),a0
	pea	(a0,d4.l)		;&_maxi_map[d4.L]  linked by store_blocks!
	jsr	store_blocks(pc)	;store_blocks(map_p,pack_p,size)
	adda	#$C,sp
	tst	14(a6)			;more to write ?
	beq	.hdv_rw_success		;exit successfully, if no more to write
	move.l	maxibase_p(a4),a0
	cmpi.l	#$208,_maxi_dspace(a0)
	bge.s	.hdv_rw_next_step_a3
	cmpi.l	#$200,_maxi_dspace(a0)
	blt.s	.hdv_rw_write_err
	tst.l	_maxi_pspace(a0)
	bgt.s	.hdv_rw_next_step_a3
.hdv_rw_write_err:
	moveq	#-1,d0
	bra.s	.fnend_maxi_hdv_rw
;
.hdv_rw_simple_readnull:	;Here to clear a buffer page (unused sector)
	move	#$200-1,d0
.L4AE:
	clr.b	(a3)+
	dbra	d0,.L4AE
	bra.s	.hdv_rw_next
;
;
.hdv_rw_read_antipack:
	bclr	#31,d0			;get rid of pack_status
	pea	(a3)			;dest_p  -> sector_dta
	move.l	d0,-(sp)		;block_p -> 1'st sector block
	move.l	#$200,-(sp)		;maxsize =  $200
	jsr	fetch_blocks(pc)	;fetch_blocks(maxsize,block_p,dest_p)
	adda	#$A,sp
	bra.s	.hdv_rw_next_step_a3
;
;
.hdv_rw_read_data:
	move.l	maxi_MAP_p(a4),a0
	move.l	(a0,d4.l),d0		;d0->sector
	beq.s	.hdv_rw_simple_readnull	;go if reading empty sector
	bmi.s	.hdv_rw_read_antipack	;go if reading unpackable data
	pea	pack_buff(a4)		;dest_p -> pack_buff(a4)
	move.l	d0,-(sp)		;block_p -> 1'st sector block
	move.l	#$200,-(sp)		;maxsize =  $200
	jsr	fetch_blocks(pc)	;fetch_blocks(maxsize,block_p,dest_p)
	adda	#$A,sp
	pea	pack_buff(a4)		;pack_p   -> pack_buff(a4)
	pea	(a3)			;bufbeg_p -> sector_dta
	pea	$200(a3)		;bufend_p -> sector_dta + 512
	jsr	unpack_sector(pc)	;unpack_sector(bufend_p,bufbeg_p,pack_p)
	adda	#12,sp
.hdv_rw_next_step_a3:
	adda	#$200,a3	;a3->buffer for next sector
.hdv_rw_next:
	addq	#1,d7		;d7= next sector to access
.hdv_rw_start:
	move	14(a6),d0	;d0= sectors remaining to read/write
	subq	#1,14(a6)
	tst	d0
	bne	.hdv_rw_loop	;loop back to read/write more data
.hdv_rw_success:
	clr.l	d0		;d0= 0 to flag success
.fnend_maxi_hdv_rw:
	movem.l	(sp)+,d4-d7/a2-a3
	unlk	a6
	rts
;
;----------------------------------------------------------------------------
;
startup:
	move.l	4(sp),a5	;a5->bp
	move.l	bp_textlen(a5),d0
	add.l	bp_datalen(a5),d0
	add.l	bp_bss_len(a5),d0
	add.l	#$2100,d0		;d0+=basepage size + $2000 stack margin
	move.l	d0,d1
	add.l	a5,d1			;d1= a5 + d0
	and.l	#-2,d1			;masked even
	move.l	d1,sp			;then made new USP !!!
	gemdos	Mshrink!_IND,!,a5,d0	;returns memory to system
	lea	static(pc),a4
	move.l	a5,basepage_p(a4)
	bsr	init_static		;initialize some "static" data
main:
	link	a6,#-26			;NB: originally	#-76 !!!
; word -22 INF_handle long -20 entry_SSP  word -8 drivenum
	sub_xbios	Cursconf,!,!
	bsr	show_copyright
	sub_gemdos	Super,!
	move.l	d0,-20(a6)	;entry SSP
	XB_check	new_hdv_bpb(pc),(hdv_bpb).w
	bpl	.chain_reaction
	XB_check	new_hdv_mediach(pc),(hdv_mediach).w
	bpl.s	.chain_reaction
	XB_check	new_hdv_rw(pc),(hdv_rw).w
	bpl.s	.chain_reaction
	move.l	#(phystop),a0
	move.l	(a0),d0
	move.l	d0,maxibase_p(a4)
	add.l	#_maxi_MAP,d0
	cmpi.l	#$400000,d0	; > 4 MEGA ???
	bgt.s	.install_maxi
	move.l	maxibase_p(a4),a0
	cmpi.l	#MAXIDATE,_maxi_date(a0)	; This maxidisk's date at top ?
	bne.s	.install_maxi
.warmup_maxi:
	bsr	show_warmup
	move.l	maxibase_p(a4),a0
	lea	_maxi_bpb(a0),a1
	move.l	a1,maxi_bpb_p(a4)
	lea	_maxi_MAP(a0),a2
	move.l	a2,maxi_MAP_p(a4)
	move	bpb_data_clusts(a1),d0
	ext.l	d0
	asl.l	#3,d0		;d0= 8*data_clusts  (==4*data_sects)
	add.l	d0,a2
	move.l	a2,maxi_sectbase_p(a4)
	bsr	install_vectors
	bra	join_warmcold
;
.chain_reaction:
	sub_gemdos	Super!_IND,-20(a6)
	sub_gemdos	Cconws,chain_react_s(pc)
	bra	fnend_main
;
.install_maxi:
	sub_gemdos	Malloc,?
	cmpi.l	#$11170,d0	;demand 70000 bytes free to init MAXIDISK
	bhs.s	.izmax_1
	sub_gemdos	Cconws,not_got_mem_s-static(a4)
	bra	fnend_main
;
.izmax_1:
	sub_gemdos	Dgetdrv
	move	d0,-8(a6)
	sub_gemdos	Fopen,max_inf_s-static(a4),!
	move	d0,-22(a6)
	tst	-22(a6)	;Found MAXIDISK.INF ?
	bpl.s	.accept_INF	;go accept file if found
	cmpi	#2,-8(a6)	;C: boot ?
	bpl.s	.accept_INF	;must go accept absence on C:
	move.l	#(_nflops),a0
	cmpi	#1,(a0)	;more floppies ?
	bls.s	.accept_INF	;must go accept absence if all tried
	move	#1,d0
	sub	-8(a6),d0
	sub_gemdos	Dsetdrv,d0
	sub_gemdos	Fopen,max_inf_s-static(a4),!
	move	d0,-22(a6)
.accept_INF:
	move	-22(a6),-24(a6)	;copy INF_handle
	sub_gemdos	Malloc,?
	lsr.l	#8,d0
	lsr.l	#2,d0		;d0= Malloc(-1) / 1024
	sub.l	#30,d0		;d0 -= 30
	move	d0,-26(a6)
	move	-26(a6),-(sp)	;RAM_free
	pea	-22(a6)		;&INF_handle
	pea	-6(a6)		;&drive_INF
	pea	-4(a6)		;&sectors_INF
	pea	-2(a6)		;&size_INF
	jsr	getINFdata(pc)
	adda	#18,sp
	move	-2(a6),d0	;size_INF
	beq	maxbort_main	;skip installation if size_INF == 0
	clr.l	d0
	move	-2(a6),d0		;d0= size_INF
	add.l	URAn_ramloss(a4),d0	;d0= total RAM need in Kbytes
	move.l	d0,-(sp)
	jsr	take_MAXI_RAM(pc)	;d0= take_MAXI_RAM(size_INF+8)
	addq.l	#4,sp
	move.l	d0,maxibase_p(a4)
	beq	mpb_err_main		;exit with error if pointer is NULL
	move.l	d0,a0
	move.l	#MAXIDATE,_maxi_date(a0)	;store MAXIDATE to Mark high RAM taken
	move	-6(a6),_maxi_drive(a0)		;store drive_INF
	move	-2(a6),_maxi_size(a0)		;store size_INF
	lea	_maxi_bpb(a0),a0
	lea	dummy_bpb(a4),a1
	moveq	#9-1,d0
.LA0x:				;loop start to copy initial BPB from static to high RAM
	move	(a1)+,(a0)+
	dbra	d0,.LA0x	;loop back for all of BPB
	move.l	maxibase_p(a4),a0
	add.l	#_maxi_bpb,a0
	move.l	a0,maxi_bpb_p(a4)	;init static maxi_bpb_p
	move.l	maxibase_p(a4),d0
	add.l	#_maxi_MAP,d0
	move.l	d0,maxi_MAP_p(a4)	;init static maxi_MAP_p
	move.l	maxibase_p(a4),a0
	clr.l	d0
	move	_maxi_bpb+bpb_data_clusts(a0),d0
	asl.l	#3,d0			;d0=8*data_clusts  (==4*data_sects)
	add.l	maxi_MAP_p(a4),d0	;d0=_maxi_MAP + 4*data_sects
	move.l	d0,maxi_sectbase_p(a4)	;init static maxi_sectbase
	move	_maxi_bpb+bpb_data_clusts(a0),d0
	asl	#1,d0			;d0= 2*data_clusts (==data_sects)
	subq	#1,d0			;d0 adj for dbra
	move.l	maxi_MAP_p(a4),a0
.L718:					;loop start to clear all of _maxi_MAP
	clr.l	(a0)+
	dbra	d0,.L718		;loop back to clear all of _maxi_MAP
	move.l	maxi_bpb_p(a4),a0
	move	bpb_data_start(a0),d0
	asl	#7,d0			;d0= bpb_data_start*$200/4  (==longs to data_start)
	subq	#1,d0			;d0 adj for dbra
	move.l	maxi_sectbase_p(a4),a0
.L75C:					;loop start to clear boot,FATs,root_dir
	clr.l	(a0)+
	dbra	d0,.L75C		;loop back to clear boot,FATs,root_dir
	move.l	a0,d0			;d0=  a0-> data_start in high RAM
	sub.l	maxibase_p(a4),d0	;d0= actual RAM loss in bytes
	move.l	URAn_movedist(a4),d1	;d1= actual total space (the phystop decrement)
	sub.l	d0,d1			;d1= actual space for data	
	move.l	maxibase_p(a4),a1
	move.l	a0,_maxi_CHAIN_p(a1)	;init CHAIN_p
	clr.l	(a0)			;init first block link = 0
	subq.l	#8,d1			;reduce space by overhead for first block
	move.l	d1,_maxi_dspace(a1)	;init _maxi_dspace
	move.l	#8,_maxi_pspace(a1)	;init _maxi_pspace
	move.l	d1,4(a0)		;init first block size = dspace
	move.l	maxi_bpb_p(a4),a0
	move	bpb_FAT2_start(a0),d0
	ext.l	d0
	asl.l	#8,d0
	asl.l	#1,d0			;d0= bpb_FAT2_start * $200
	addq.l	#4,d0			;d0+= 4  (==offset from sectbase to 2'nd FAT in FAT2)
	move.l	maxibase_p(a4),a0
	move.l	_maxi_dspace(a0),d1
	addq.l	#8,d1
	move.l	d1,-(sp)
	move.l	#$410,-(sp)
	jsr	long_div(pc)		;long_div(#$410,space)
	move.l	(sp)+,d1		;d1 = approximate free clusters
	addq.l	#4,sp
	asl.l	#1,d1			;d1 *= 2  (==approximate free cluster FAT bytes)
	add.l	d1,d0			;d0= FAT2_start*$200+4+appx_freeFAT_bytes
	add.l	maxi_sectbase_p(a4),d0
	move.l	d0,a1			;a1->1'st FAT2 FAT needing BAD mark
	move.l	maxi_bpb_p(a4),a0
	move	bpb_FAT2_start(a0),d0
	add	bpb_FAT_sects(a0),d0
	ext.l	d0
	asl.l	#8,d0
	asl.l	#1,d0			;d0= (bpb_FAT2_start+bpb_FAT_sects)*$200
	add.l	maxi_sectbase_p(a4),d0	;d0-> end of FAT2
	sub.l	a1,d0			;d0= FAT bytes needing BAD marks
	lsr.l	#1,d0			;d0= FAT words needing BAD marks
	subq	#1,d0			;d0 adj for dbra
.L850:
	move	#$F7FF,(a1)+
	dbra	d0,.L850
	jsr	install_vectors(pc)
	tst	-22(a6)			;INF_handle <= 0 ?
	ble.s	L8C6			;skip batch if no INF file
	move	-22(a6),-(sp)		;INF_handle
	jsr	batch_INF_commands(pc)
	addq	#2,sp
L8C6:
	move	-24(a6),-(sp)
	bsr.s	close_safe
	addq	#2,sp
L8DE:
	sub_gemdos	Dsetdrv,-8(a6)
	bsr	show_freemem
join_warmcold:
	sub_gemdos	Super!_IND,-20(a6)
	move.l	sp,d0		;take current SP
	add.l	#$64,d0			;add 100 bytes for safety
	move.l	basepage_p(a4),d1	;subtract BP and use result for size
	sub.l	d1,d0
	sub_gemdos	Ptermres,d0,!
;
;
mpb_err_main:
	sub_gemdos	Cconws,mpb_err_s-static(a4)
maxbort_main:
	sub_gemdos	Cconws,maxbort_s-static(a4)
	move	-24(a6),-(sp)
	bsr.s	close_safe
	addq	#2,sp
fnend_main:
	gemdos	Pterm,#-1
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
; void	*take_MAXI_RAM(long size_INF)	/* actually size_INF+URAn_ramloss */
take_MAXI_RAM:
	link	a6,#-18
	move.l	8(a6),d0
	asl.l	#8,d0
	asl.l	#2,d0			;d0= (size_INF + URAn_ramloss) * 1024
	add.l	#$1FE,d0		;to allow screen basing
	move.l	d0,-10(a6)		;RAM_need= d0
	and.l	#-$200,d0		;ensures screen at 512_byte multiple
	move.l	d0,URAn_movedist(a4)
	addq.l	#8,-10(a6)		;bump RAM_need a bit to ensure release_ability
	sub_gemdos	Malloc,?	;d0= Malloc(-1)
	move.l	d0,-6(a6)		;Free_RAM= d0
	sub.l	-10(a6),d0		;d0= Free_RAM - RAM_need
	sub_gemdos	Malloc,d0	;d0= Malloc(d0)
	move.l	d0,-14(a6)		;store void *UNwantedp
	beq.s	.take_failed
	sub_gemdos	Malloc,-10(a6)	;d0= Malloc(RAM_need)
	move.l	d0,-18(a6)		;store void *WANTED_RAM_p
	beq.s	.take_failed
	sub_gemdos	Mfree!_IND,-14(a6)	;Mfree(UNwantedp)
	move.l	-10(a6),-(sp)
	move.l	-18(a6),-(sp)
	bsr	find_mpb		;find_mpb(WANTED_RAM_p, RAM_need)
	addq	#8,sp
	subq.l	#1,d0
	beq.s	.mpb_found
.take_failed:
	clr.l	d0			;NULL return pointer flags failure
	bra	.exit_take_MAXI
;
.mpb_found:
	move.l	a0,URAn_mpb(a4)
	move.l	(phystop).w,d0
	sub.l	(_memtop).w,d0
	and.l	#-2,d0
	move.l	d0,URAn_movesize(a4)
	move.l	URAn_mpb(a4),a2		;a2-> MPB root vector group
	move.l	4(a2),a2		;a2-> MPB of *WANTED_RAM_p
	move.l	(_memtop).w,a0		;a0->old _memtop  NB: orig assumed == _v_bas_ad
	move.l	a0,a1
	move.l	URAn_movedist(a4),d0
	sub.l	d0,a1			;a1->new _memtop for data move
	sub.l	d0,8(a2)		;shrink MPB, so we can lock up properly!!! 
	sub.l	d0,(_memtop).w		;NB: orig did not move _memtop, or shrink MPB
	sub.l	d0,(phystop).w		;Here new areas are protected
	move.l	URAn_movesize(a4),d0	;NB: orig used constant size 32000
	beq.s	.screen_lpx		;phystop may equal _memtop if screen Malloc'd
	lsr.l	#4,d0			;move as quad longwords (overlap doesn't matter)
	subq.l	#1,d0
	swap	d0
.screen_lp1:				;Loop 1 start
	swap	d0
.screen_lp2:				;Loop 2 start
	move.l	(a0)+,(a1)+		;move screen data to new area
	move.l	(a0)+,(a1)+		;move screen data to new area
	move.l	(a0)+,(a1)+		;move screen data to new area
	move.l	(a0)+,(a1)+		;move screen data to new area
	dbra	d0,.screen_lp2		;Loop for whole screen
	swap	d0
	dbra	d0,.screen_lp1
.screen_lpx:
	move.l	(_v_bas_ad).w,d0
	sub.l	URAn_movedist(a4),d0
	move.l	d0,(screenpt).w
	sub_xbios	Vsync
	clr.l	(screenpt).w
	sub_gemdos	Mfree!_IND,-18(a6)	;release unused part of MPB
	move.l	(phystop).w,d0
.exit_take_MAXI:
	unlk	a6
	rts			;return d0= new phystop  URAn_movedist= maxidisk area size
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
	sub.b	#$20,d0
	move.b	d0,-1(a6)
.LB04:
	cmp.b	#' ',d0
	beq.s	.LB4A
	cmp.b	#HT,d0
	beq.s	.LB4A
	cmp.b	#CR,d0
	beq.s	.LB4A
	cmp.b	#LF,d0
	beq.s	.LB4A
	cmp.b	#FF,d0
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
	cmp.b	#' ',d0
	beq.s	.LC54
	cmp.b	#HT,d0
	beq.s	.LC54
	cmp.b	#CR,d0
	beq.s	.LC54
	cmp.b	#LF,d0
	beq.s	.LC54
	cmp.b	#FF,d0
	bne.s	.LC40		;go .LC40 if non-whitespace
	bra.s	.LC54		;go .LC54 if whitespace
;
.LC40:
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
	jsr	long_div(pc)	;long_div(limit,10)
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
	jsr	long_div(pc)	;long_div(value,limit)
	move.l	(sp)+,d0	;d0= quotient
	move.l	(sp)+,8(a6)	;value= remainder
	add.l	#'0',d0
	move.b	d0,(a0)+	;store new digit
	move.l	-4(a6),-(sp)
	move.l	#10,-(sp)
	jsr	long_div(pc)	;long_div(limit,10)
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
show_copyright:
	sub_gemdos	Cconws,copyright_s-static(a4)
	rts
;
;
show_warmup:
	sub_gemdos	Cconws,installed_s-static(a4)
	move	#'A',d0
	move.l	maxibase_p(a4),a0
	add	_maxi_drive(a0),d0
	sub_gemdos	Cconout,d0
	sub_gemdos	Cconws,instslash_s-static(a4)
	move.l	maxibase_p(a4),a0
	move	_maxi_size(a0),d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	ultoa(pc)
	addq.l	#4,sp
	sub_gemdos	Cconws!_IND,d0
	sub_gemdos	Cconws,kb_used_s-static(a4)
show_freemem:
	sub_gemdos	Cconws,free_mem_s-static(a4)
	sub_gemdos	Malloc,?
	move.l	d0,-(sp)
	jsr	ultoa(pc)
	addq.l	#4,sp
	sub_gemdos	Cconws!_IND,d0
	sub_gemdos	Cconws,bytes_s-static(a4)
	rts
;
;----------------------------------------------------------------------------
;
; void	getINFdata(*size_INF, *sectors_INF, *drive_INF, *INF_handle_p, RAM_free)
;NB: sectors_INF is no longer used, nor initialized, just a dummy arg
getINFdata:
	link	a6,#-2
	jsr	show_freemem(pc)
	sub_gemdos	Cconws,crlf_s-static(a4)
.LE7C:				;Loop start
	sub_gemdos	Cconws,howmany_kb_s-static(a4)
	move.l	20(a6),-(sp)	;INF_handle_p
	move	#'9',-(sp)	;'9'
	move	#'0',-(sp)	;'0'
	move	#4,-(sp)	;4
	pea	INF_buff_1(a4)	;&
	jsr	fgets_masked(pc)
	adda	#14,sp
	pea	INF_buff_1(a4)
	jsr	strtoul(pc)
	addq.l	#4,sp
	move.l	8(a6),a0
	move	d0,(a0)		;store size_INF
	beq	.fnend_getINFdata	;go if d0 == 0
	cmpi	#30,d0
	blo.s	.LE7C		;Loop back if < 30 K requested
	ext.l	d0
	asl	#1,d0
	move	d0,dummy_bpb+bpb_data_clusts(a4)
	move.l	d0,d1
	add.l	#$FF,d0
	lsr.l	#8,d0
	move	d0,dummy_bpb+bpb_FAT_sects(a4)
	move	d0,dummy_bpb+bpb_data_start(a4)
	addq	#1,d0
	move	d0,dummy_bpb+bpb_FAT2_start(a4)
	add	d0,dummy_bpb+bpb_data_start(a4)
	move.l	d1,d0
	lsr.l	#8,d0		;add 16 root_dirs per 256 data clusters
	addq	#5,d0
	move	d0,dummy_bpb+bpb_root_sects(a4)
	add	d0,dummy_bpb+bpb_data_start(a4)
	clr.l	d0
	move	dummy_bpb+bpb_data_start(a4),d0
	asl.l	#8,d0
	asl.l	#1,d0		;d0= data_start*512  ==RAM need for non_data sectors
	asl.l	#3,d1		;d1= size_INF*16     ==RAM need for data sector block maps
	add.l	d1,d0
	clr.l	d1
	move	dummy_bpb+bpb_data_clusts(a4),d1
	asl.l	#3,d1		;d1= log_clusts*8  == phys_sects*8  for data blockheads
	add.l	d1,d0
	add.l	#_maxi_headend,d0		;d0= Total RAM loss in bytes
	add.l	#$3FF,d0	;prep to round up to Kbytes
	lsr.l	#8,d0
	lsr.l	#2,d0
	move.l	d0,URAn_ramloss(a4)	;store RAM overhead cost in Kbytes
	add	(a0),d0		;d0= total RAM need
	cmp	24(a6),d0
	bhi	.LE7C		;Loop back if d0 > RAM_free
	sub_gemdos	Cconws,crlf_s-static(a4)
	sub_bios	Kbshift,#$10
.LF20:				;Loop start
	sub_gemdos	Cconws,whichpart_s-static(a4)
	move.l	20(a6),-(sp)	;INF_handle_p
	move	#'P',-(sp)	;'P'
	move	#'C',-(sp)	;'C'
	move	#1,-(sp)	;1
	pea	INF_buff_1(a4)
	jsr	fgets_masked(pc)
	adda	#$E,sp
	lea	INF_buff_1(a4),a0
	move.b	(a0),d0
	ext.w	d0
	sub	#'A',d0
	move.l	16(a6),a0
	move	d0,(a0)		;store drive_INF
	lea	INF_buff_1(a4),a0
	move.b	(a0),d0
	tst.b	d0
	beq.s	.LF20		;Loop back if illegal drivespec
	moveq	#1,d0		;d0= 1L
	move.l	16(a6),a0
	move	(a0),d3		;d3= drive
	asl.l	d3,d0		;d0= drive bit
	and.l	(_drvbits).w,d0
	bne.s	.LF20		;also loop back if drive already logged
	sub_bios	Kbshift,!
.fnend_getINFdata:
	unlk	a6
	rts
;
;----------------------------------------------------------------------------
;
;batch_INF_commands(handle)
batch_INF_commands:
	link	a6,#-20
	sub_gemdos	Malloc,#$3E8
	move.l	d0,-4(a6)
	beq	L122C
	sub_gemdos	Fread!_IND,8(a6),#$3E6,-4(a6)
	move	d0,-20(a6)
	clr.b	d0
	move.l	-4(a6),a0
	adda	-20(a6),a0
	move.b	d0,1(a0)
	move.b	d0,(a0)
	move.l	-4(a6),-8(a6)
L1002:
	bra.s	L100A
;
;
L1006:
	addq.l	#1,-8(a6)
L100A:
	move.l	-8(a6),a0
	move.b	(a0),d0
	cmp.b	#' ',d0
	beq.s	L1006
	cmp.b	#HT,d0
	beq.s	L1006
	cmp.b	#CR,d0
	beq.s	L1006
	cmp.b	#LF,d0
	beq.s	L1006
	cmp.b	#FF,d0
	beq.s	L1006
	move.l	-8(a6),-12(a6)
	bra.s	L1068
;
L1064:
	addq.l	#1,-8(a6)
L1068:
	move.l	-8(a6),a0
	move.b	(a0),d0
	beq.s	L10C2
	cmp.b	#' ',d0
	beq.s	L10C2
	cmp.b	#HT,d0
	beq.s	L10C2
	cmp.b	#CR,d0
	beq.s	L10C2
	cmp.b	#LF,d0
	beq.s	L10C2
	cmp.b	#FF,d0
	bne.s	L1064
L10C2:
	cmp.b	#' ',d0
	beq.s	L10E2
	cmp.b	#HT,d0
	bne.s	L1178
L10E2:
	move.l	-8(a6),a0
	addq.l	#1,-8(a6)
	clr.b	(a0)
	bra.s	L10F4
;
L10F0:
	addq.l	#1,-8(a6)
L10F4:
	move.l	-8(a6),a0
	move.b	(a0),d0
	cmp.b	#' ',d0
	beq.s	L10F0
	cmp.b	#HT,d0
	beq.s	L10F0
	move.l	-8(a6),-16(a6)
	move.l	-8(a6),a0
	addq.l	#1,-8(a6)
	move.b	(a0),-17(a6)
	move.l	-16(a6),a0
	clr.b	(a0)
	bra.s	L1150
;
L1130:
	move.b	-17(a6),-18(a6)
	move.l	-8(a6),a0
	move.b	(a0),-17(a6)
	addq.l	#1,-8(a6)
	move.b	-18(a6),(a0)
	move.l	-16(a6),a0
	addq.b	#1,(a0)
L1150:
	move.b	-17(a6),d0
	beq.s	L1174
	cmp.b	#CR,d0
	beq.s	L1174
	cmp.b	#LF,d0
	bne.s	L1130
L1174:
	bra.s	L1188
;
L1178:
	move.l	-8(a6),-16(a6)
	move.l	-8(a6),a0
	addq.l	#1,-8(a6)
	clr.b	(a0)
L1188:
	move.l	-12(a6),a0
	move.b	(a0),d0
	beq	L1222
	sub_gemdos	Pexec!_IND,!,-12(a6),-16(a6),!
	tst.l	d0
	bge.s	L1222
	sub_gemdos	Cconws,error_on_s-static(a4)
	sub_gemdos	Cconws!_IND,-12(a6)
	sub_gemdos	Cconout,#$20
	move.l	-16(a6),a0
	addq.l	#1,-16(a6)
	move.b	(a0),-18(a6)
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
L1222:
	move.l	-8(a6),a0
	move.b	(a0),d0
	bne	L1002
L122C:
	sub_gemdos	Mfree!_IND,-4(a6)
	unlk	a6
	rts
;
;----------------------------------------------------------------------------
;
move_bytes	macro	src_p,dst_p,size
	lea	\1,a0	;src_p
	lea	\2,a1	;dst_p
	move.l	\3,d0	;size
	bsr	fast_move
	endm	;move_bytes
;
;
;void	store_blocks(sect_p_p,packbf_p,size)
store_blocks:
	link	a6,#0
	movem.l	d4-d7/a2-a3,-(sp)
	move.l	12(a6),a3		;a3->pack buffer
	clr.l	d7
	move	18(a6),d7		;d7= size  NB: as word to avoid flag bit
	clr.l	d5			;zero future dspace decrement
	clr.l	d4			;zero future pspace decrement
	addq.l	#1,d7
	and.w	#-2,d7			;round d7 for words
	move.l	maxibase_p(a4),a0
	move.l	_maxi_CHAIN_p(a0),a2	;a2->top free block
	move.l	a2,d0			;No block ?
	beq.s	.diskfull_store_block
.loop_store_blocks:			;loop start to write into 1 or more blocks
	move.l	4(a2),d6		;d6= blocksize
	cmp.l	d7,d6
	bhs.s	.single_store_block	;go if blocksize >= writesize
; Here we need to write several blocks (1 per loop)
	move_bytes	(a3),8(a2),d6	;src_p,dst_p,size
	sub.l	d6,d7			;writesize -= blocksize
	adda.l	d6,a3			;pack_p += blocksize
	add.l	d6,d5			;dcount += blocksize
	addq.l	#8,d4			;pcount +=8
	move.l	(a2),a2			;a2->next block
	move.l	a2,d0			;No block ?
	bne.s	.loop_store_blocks	;loop to complete unless out of blocks
.diskfull_store_block:
	move.l	8(a6),a0		;a0->sector block ptr
	clr.l	(a0)			;clear sector's block ptr (no room!)
	bra.s	.fnend_store_blocks
;
;
.single_store_block:			;Here a single block will hold final data
	move.l	maxibase_p(a4),a0
	move.l	_maxi_CHAIN_p(a0),d0
	tst.b	16(a6)			;check pack_flag
	beq.s	.fixed_store_block
	bset	#31,d0			;mark sector block ptr as unpacked
.fixed_store_block:
	move.l	8(a6),a0		;a0->sector block ptr
	move.l	d0,(a0)			;store sector block ptr in map
	move_bytes	(a3),8(a2),d7	;src_p,dst_p,size
	move.l	d7,d1
	addq.l	#8,d1
	cmp.l	d1,d6
	bhi.s	.cut_store_block	;go cut block if it is large enough
;NB: original did not avoid zero-length blocks, which might then cause errors,
;NB: so never alter above "bhi" to the original "bge" !!!
	move.l	maxibase_p(a4),a0
	move.l	(a2),_maxi_CHAIN_p(a0)	;move next block in chain to top
	add.l	d6,d5			;dcount += blocksize
	addq.l	#8,d4			;pcount += 8
	bra.s	.finish_store_blocks
;
;
.cut_store_block:
	move.l	d7,4(a2)		;blocksize= writesize
	move.l	a2,d0
	addq.l	#8,d0
	add.l	d7,d0			;d0= blockbase+8+blocksize
	move.l	maxibase_p(a4),a0
	move.l	d0,_maxi_CHAIN_p(a0)	;new top block is blockbase+8+blocksize
	move.l	d0,a0
	move.l	(a2),(a0)		;new top block inherits old chain
	move.l	d6,d0
	sub.l	d7,d0
	subq.l	#8,d0			;d0= old_blocksize-writesize-8
	move.l	d0,4(a0)		;new_blocksize= d0
	move.l	d7,d0
	addq.l	#8,d0
	add.l	d0,d5			;count += writesize+8
.finish_store_blocks:
	clr.l	(a2)			;this breaks chain of sectors blocks
	move.l	maxibase_p(a4),a0
	sub.l	d5,_maxi_dspace(a0)	;dspace -= dcount
	sub.l	d4,_maxi_pspace(a0)	;pspace -= pcount
	st	URAn_smudge(a4)		;flag size change
.fnend_store_blocks:
	movem.l	(sp)+,d4-d7/a2-a3
	unlk	a6
	rts
;
;
move_512:
	exg	a0,d0
	btst	#0,d0
	exg	a0,d0
	bne	slow_512
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
slow_512:
	rept	512
	move.b	(a0)+,(a1)+
	endr
move_null:
	rts
;
fast_move:
	asl	#1,d0
	neg	d0
	jmp	move_null(pc,d0)
;
;
;fetch_blocks(size,block_p,pack_p)
fetch_blocks:
	movem.l	d6-d7/a2-a3,-(sp)
	movem.l	20(sp),d7/a2/a3		;d7=size  a2=block_p  a3=pack_p
	bra.s	.fetch_start
;
.fetch_loop:				;loop start
	move.l	4(a2),d6
	cmp.l	d7,d6
	bls.s	.min_d7_d6
	move.l	d7,d6
.min_d7_d6:				;d6= min(size_need,block_size)
	move_bytes	8(a2),(a3),d6	;move bytes
	sub.l	d6,d7			;decrease size_need
	adda.l	d6,a3			;increase pack_p
	move.l	(a2),a2			;a2->next sector block
.fetch_start:
	move.l	a2,d0			;a2==end_of_chain ?
	beq.s	.fnend_fetch_blocks	;if at end, exit function
	tst.l	d7			;need more blocks ?
	bgt.s	.fetch_loop		;loop back for more blocks
.fnend_fetch_blocks:
	movem.l	(sp)+,d6-d7/a2-a3
sneak_out_1:	;Here for fast exits, when no regs need restoration
	rts
;
;
;NB: This is a total rewrite, since the original was inefficient (hopelessly)
;void allocate_block(oldblock_p)
allocate_block:
	move.l	4(sp),d0		;d0->possible old block, or is NULL
	beq.s	sneak_out_1		;superfast exit if no old block
	st	URAn_smudge(a4)		;flag size change
	move.l	a2,-(sp)	;save a2
	bclr	#31,d0			;clear pack_status
	move.l	d0,a1			;a1 -> valid old chain
	clr.l	d1			;d1 =  0
	suba.l	a0,a0			;a0 =  0
clean_old_loop:				;loop start to return data parts of old chain
	move.l	d0,a2				;a2 -> oldblock
	add.l	4(a2),d1			;d1 += oldsize
	addq.l	#8,a0				;a0 += 8
	move.l	(a2),d0				;d0 =  oldlink
	bne.s	clean_old_loop		;loop back to return data parts of old chain
	move.l	a0,d0
	move.l	maxibase_p(a4),a0
	add.l	d1,_maxi_dspace(a0)	;This releases ALL data parts in old chain
	add.l	d0,_maxi_pspace(a0)	;This releases ALL pointers in old chain
;NB:
;NB: Here a1-> valid old chain, all parts of which have been registered as free
;NB:
	move.l	_maxi_CHAIN_p(a0),d0	;d0-> valid top chain, or is NULL
	movem.l	a1,_maxi_CHAIN_p(a0)	;a1 applies as new top, WITH flags intact
	beq.s	.fnend_allocate_block	;so if top was empty, we're DONE
	move.l	d0,a2			;a2-> valid top chain
;NB:
;NB: Here a1 and a2 are both valid free block chains, needing to be combined
;NB: The lower should set _maxi_CHAIN_p, currently == a1
;NB:
	cmp.l	a2,a1
	blo.s	.keep_CHAIN_p
	exg	a1,a2;			;ooops!, need to swap chains
	move.l	a1,_maxi_CHAIN_p(a0)
.keep_CHAIN_p:				;Here _maxi_CHAIN_p has final correct value
;NB:
;NB: Here a1 < a2, both -> valid free chains to be combined
;NB:
.combine_loop_1:			;loop 1 target after combining 2 blocks
	move.l	a1,d0
.combine_loop_2:			;loop 2 target for search and normal linking
	move.l	d0,a1
	move.l	(a1),d0
	beq.s	.fix_link		;if a1_link is chain_end, go link to a2
	cmp.l	a2,d0
	blo.s	.combine_loop_2		;loop back continue search if a1_link < a2
.fix_link:				;Here a1_link > a2 or a1_link is NULL
	move.l	a1,d1
	addq.l	#8,d1
	add.l	4(a1),d1		;d1= a1_base + 8 + a1_size
	cmp.l	a2,d1
	beq.s	.combine_blocks		;go combine if a2_block adjacent after a1_block
	move.l	a2,(a1)			;a1_link = a2
	tst.l	d0			;if old_a1_link is NULL we're DONE
	beq.s	.fnend_allocate_block
	exg	d0,a2			;new a2_block=old_a1_link  d0=a2 ==future a1_block
	bra.s	.combine_loop_2		;loop back to combine rest of chains
;
.combine_blocks:
	move.l	4(a2),d1
	addq.l	#8,d1
	add.l	d1,4(a1)		;a1_size += a2_size + 8
	subq.l	#8,_maxi_pspace(a0)
	addq.l	#8,_maxi_dspace(a0)	;2 longs moved from pspace to dspace
	move.l	(a2),d1			;d1= a2_link, and if NULL we try combining a1_link
	beq.s	.finish_allocate_block	
	move.l	d1,(a1)			;new a1_link  = a2_link
	tst.l	d0			;if old_a1_link is NULL we're DONE
	beq.s	.fnend_allocate_block	
	move.l	d0,a2			;new a2_block = old_a1_link
	bra.s	.combine_loop_1		;loop back to combine rest of chains
;
.finish_allocate_block:			;Here d0 == a1_link may be combinable with a1_block
	tst.l	d0			;if a1_link is NULL we're DONE
	beq.s	.fnend_allocate_block	
	move.l	a1,d1
	addq.l	#8,d1
	add.l	4(a1),d1		;d1= a1_base + 8 + a1_size
	cmp.l	d0,d1			;if not combinable we're DONE
	bne.s	.fnend_allocate_block
	move.l	d0,a2			;new a2_block = a1_link
	move.l	4(a2),d1
	addq.l	#8,d1
	add.l	d1,4(a1)		;a1_size += a2_size + 8
	subq.l	#8,_maxi_pspace(a0)
	addq.l	#8,_maxi_dspace(a0)	;2 longs moved from pspace to dspace
	move.l	(a2),(a1)		;a1_link= a2_link, and now we're definitely DONE
.fnend_allocate_block:
	movea.l	(sp)+,a2	;restore a2
	rts
;
;
;pack_sector(bufbeg_p,bufend_p,pack_p,size_p)
pack_sector:
	link	a6,#-8
	movem.l	d4-d7/a2-a5,-(sp)
	lea	pack_magic(a4),a1	;a1-> magic
	move.l	a1,-8(a6)		;magic_save = a1
	lea	1024+Keytab(a4),a5
;NB: The sequence below clears 1 Kbyte, that is 512 words,
;NB: while wasting time only on 53 non_data word accesses !!!
;NB: standard "clr.l & dbra" would cost 768 accesses, "REPT clr.l" 256 accesses
	clr.l	d0			;clear first of 13 long registers
	clr.l	d1
	clr.l	d2
	clr.l	d3
	clr.l	d4
	clr.l	d5
	clr.l	d6
	clr.l	d7
	move.l	d0,a0
	move.l	d0,a1
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4			;clear last of 13 long registers
	REPT	19			;clear 988 bytes (== 19 * 52)
	movem.l	d0-d7/a0-a4,-(a5)	;clear 52 (== 13 * 4) bytes per instruction
	ENDR
	movem.l	d0-d7/a0,-(a5)		;clear 36 (== 9 * 4) bytes to complete 1Kbyte clear234567890
;NB: The sequence above clears 1 Kbyte, that is 512 words,
;NB: while wasting time only on 53 non_data word accesses !!!
;NB: standard "clr.l & dbra" would cost 768 accesses, "REPT clr.l" 256 accesses
;NB: After the clearing, a5 -> base of cleared table
	move.l	a5,-4(a6)		;Keytab_p = a5 -> Keytab
	move.l	-8(a6),a1	;restores magic_p from before clearing
	move.l	16(a6),a4	;a4= pack_p
	move.l	20(a6),a0	;a0= size_p
	move.l	a4,(a0)		;*size_p= pack_p start position
	move.l	a4,a5		;seqlen_p= first sequence start
	addq	#1,a4		;pack_p++
	clr	d3		;seqlen = 1
	move.l	8(a6),a2	;a2= bufbeg_p  here: bufpos_p
	clr.l	d1
	move.b	(a2),d1		;char d1= *buf_pos
	lsl	#2,d1		;d1 *= 4
	move.l	-4(a6),a0	;a0= Keytab_p
	move.l	a1,(a0,d1)	;long Keytab[d1]= magic_pos_p
	clr.l	(a1)+		;long *magic_pos_p++ = NULL  reference link
	move.l	a2,(a1)+	;long *magic_pos_p++ = bufpos_p
	bra	.pack_copybyte
;
.pack_loop_1:
	clr.l	d1
	move.b	(a2),d1		;char d1= *buf_pos
	lsl	#2,d1		;d1 *= 4
	move.l	-4(a6),a0	;a0= Keytab_p
	move.l	(a0,d1),d0	;d0= Keytab[d1]  (== old magic_pos_p)
	bne.s	.pack_repeated_char
; Here d1/4 is a character not seen previously in this sector
	move.l	a1,(a0,d1)	;long Keytab[d1]= magic_pos_p
	clr.l	(a1)+		;long *magic_pos_p++ = NULL  (reference link ?)
	move.l	a2,(a1)+	;long *magic_pos_p++ = bufpos_p
	bra	.pack_unpacked
;
;
.pack_repeated_char:
	move.l	12(a6),d6
	sub.l	a2,d6
	subq	#3,d6		;d6= bufend_p - bufpos_p - 3  ==area for cmpm test
	bmi	.pack_unpacked	;last 2 char's can't be legal packed block
	move.b	1(a2),d1	;d1= char 1
	move.b	2(a2),d2	;d2= char 2
	clr.l	d7		;clear length measure
	move.l	a1,d4		;d4= a1  to save magic_pos_p during .pack_reploop
.pack_reploop:
	move.l	d0,a3		;a3= Keytab[repeated_char]  == old magic_pos_p
	move.l	4(a3),a0	;a0= old magic_pos_p[4]  == old bufpos_p
	addq.l	#1,a0
	cmp.b	(a0)+,d1
	bne.s	.pack_trynext	;go .pack_trynext if old char 1 doesn't match new char 1
	cmp.b	(a0)+,d2
	bne.s	.pack_trynext	;go .pack_trynext if old char 2 doesn't match new char 2
	lea	3(a2),a1	;a1= bufpos_p + 3
	move.l	a2,d0
	sub.l	a0,d0		;d0= bufpos_p - (old bufpos_p + 3)
	bmi.s	.pack_trynext	;go .pack_trynext if no size for cmpm test
	beq.s	.keep_length	;tentatively accept it if 3 characters match
	cmp	d6,d0
	ble.s	.mini_d0	;keep d0 if d0 <= d6
	move	d6,d0
	beq.s	.keep_length	;tentatively accept it if 3 characters match
.mini_d0:			;d0= min(d0,d6)
	subq	#1,d0		;adj cmpm area size for dbra
	cmp	#(64-3)-1,d0
	bls.s	.cmpm_loop
	moveq	#(64-3)-1,d0	;truncate testing to possible sequence length
.cmpm_loop:			;loop start
	cmpm.b	(a1)+,(a0)+		;test an old char to match a new char
	dbne	d0,.cmpm_loop	;loop back unless all done, or match broken
;NB: Original ERROR !!!  The cmpm_loop has TWO possible exit states.
;NB: On bad match, it will leave a1 one step beyond match breaker == 1 + a2 + size,
;NB: but full matchup will leave a1 one step beyond last byte     == a2 + size.
;NB: The original code below did not cater to a full matchup !!!
;NB: The effect of the error was to make some packed sequences less efficient.
	beq.s	.keep_length	;keep length if perfect match  NB: new correction
	subq	#1,a1		;NB: adjustment moved here, to make it conditional
.keep_length:			;NB: here a1 == a2 + size regardless of loop exit state
	suba.l	a2,a1		;a1 -= bufpos_p  = matching length
	cmp	a1,d7		;match_length <= latest_length ?  (first time: match <= 0)
	bhs.s	.pack_trynext	;keep d5,d7 if match too bad
	move	a1,d7		;d7= matching length
	move.l	4(a3),d5	;d5= old bufpos_p
.pack_trynext:
	move.l	(a3),d0		;d0= old magic_pos[0]  ->next reference magic_pos
	bne.s	.pack_reploop	;loop until all ref's tried
	move.l	d4,a1		;restore magic_pos_p from before .pack_reploop
	move.l	a1,(a3)		;link last ref magic_pos[0]= new magic_pos_p
	clr.l	(a1)+		;*magic_pos_p++ = NULL  zero new reference link
	move.l	a2,(a1)+	;*magic_pos_p++ = bufpos_p
	tst	d7
	beq.s	.pack_unpacked	;go .pack_unpacked if no match
;NB:
;NB: Here original program adjusted d7 to proper length,
;NB: but erroneously assumed the adjustment to be constant -1  (it usually is)
;NB: This adjustment has been moved up a bit, to condition it to loop exit state.
;NB:
;NB: Here original program also truncated d7 to maximum packed length,
;NB: but this is now redundant, since only possible lengths are tested.
;NB:
	sub.l	8(a6),d5	;d5= sequence start offset from bufbeg_p
	adda	d7,a2		;bufpos_p += length
	subq	#1,d7		;dbra_adj length
	lsr	#1,d5		;shift offset, with bit 0 to carry
	roxl	#1,d7		;shifts length, with carry to bit 0
	bset	#7,d7		;set formflag to "packed" status
	move.b	d3,(a5)		;save latest length byte at previous start
	move.l	a4,a5		;seqlen_p->start of packed sequence
	addq	#1,a4		;pack_p++
	move.b	d7,d3		;seqlen = combined formflag, length and offset bit 0
	move.b	d5,(a4)+	;*pack_p++ = low byte of sequence offset
	bra.s	.pack_next
;
.pack_restore:
	subq.b	#1,d3		;ooops, a new block was needed
	move.b	d3,(a5)		;save latest length byte at previous start
	move.l	a4,a5		;seqlen_p= pack_p ->start of next sequence
	addq	#1,a4		;pack_p++
	clr	d3		;seqlen = 1  init length for next sequence
	bra.s	.pack_copybyte
;
.pack_unpacked:
	addq.b	#1,d3		;seqlen_p++
	bmi.s	.pack_restore
	bcs.s	.pack_restore
.pack_copybyte:
	move.b	(a2)+,(a4)+	;*pack_p++ = *bufpos_p++
.pack_next:
	cmp.l	12(a6),a2
	blo	.pack_loop_1	;loop until bufpos_p >= bufend_p
	move.b	d3,(a5)		;save latest length byte at previous start
	move.l	20(a6),a0	;a0= size_p
	suba.l	(a0),a4		;a4 -= *size_p  == pack_p data size
	move.l	a4,(a0)		;*size_p = packed size
	move.l	12(a6),d0
	sub.l	8(a6),d0	;d0= original size
	cmp.l	d0,a4		;test packed - original
	blo.s	.keep_pack	;keep packed only if efficient
	bset	#31,d0		;set top bit of d0, to flag pack failure
	move.l	d0,(a0)		;*size_p = unpacked size with flag
	move.l	8(a6),a0	;a0= bufbeg_p
	move.l	16(a6),a1	;a1= pack_p starting position
	bsr	fast_move
.keep_pack:
	movem.l	(sp)+,d4-d7/a2-a5
	unlk	a6
	rts
;
;
;void	unpack_sector(char *bufend_p,char *bufbeg_p,char *pack_p)
unpack_sector:
	movem.l	d7/a2-a3,-(sp)
	movem.l	16(sp),d7/a2/a3
;d7= bufend_p (destination limit) here: bufend_p
;a2= bufbeg_p (destination)       here: bufpos_p
;a3= pack_p   (source)            here: pack_p
	move.l	a2,a1		;a1= bufbeg_p (destination)       here: bufbeg_p
.unpack_loop:			;loop start for each byte sequence
	clr	d0
	move.b	(a3)+,d0	;d0= *pack_p++  first byte==format and size
	bclr	#7,d0		;bit 7 flags packing
	bne.s	.unpack_packed
.L1680:				;loop to unpack "unpacked" byte sequence of 1..128 bytes
	move.b	(a3)+,(a2)+		;*bufpos_p++ = *pak_p++
	dbra	d0,.L1680	;loop for entire sequence
	bra.s	.unpack_next
;
.unpack_packed:
	clr	d1
	move.b	(a3)+,d1	;d1= *pack_p++  sequence offset/2 from sector start
	lsr	#1,d0		;d0 /= 2 : lost bit is bit 0 of corrected offset
	roxl	#1,d1		;d1= sequence offset from sector start  0..509
	lea	(a1,d1),a0	;a0= bufbeg_p + offset  here: unpacked_p
.L169C:				;loop to expand "packed" byte sequence reference
	move.b	(a0)+,(a2)+	;*bufpos_p++ = *unpacked_p++
	dbra	d0,.L169C	;loop for entire sequence
.unpack_next:
	cmp.l	d7,a2
	blo.s	.unpack_loop	;loop back until bufpos_p >= bufend_p
	movem.l	(sp)+,d7/a2-a3
	rts
;
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
;
bios_sub:
	movem.l	a1-a2,OS_callsave_s-static(a4)
	move.l	(sp)+,OS_calllink_s-static(a4)
	trap	#13
	movem.l	OS_callsave_s-static(a4),a1-a2
	jmp	OS_calljump_s-static(a4)
;
;
xbios_sub:
	movem.l	a1-a2,OS_callsave_s-static(a4)
	move.l	(sp)+,OS_calllink_s-static(a4)
	trap	#14
	movem.l	OS_callsave_s-static(a4),a1-a2
	jmp	OS_calljump_s-static(a4)
;
;
gemdos_sub:
	movem.l	a1-a2,OS_callsave_s-static(a4)
	move.l	(sp)+,OS_calllink_s-static(a4)
	trap	#1
	movem.l	OS_callsave_s-static(a4),a1-a2
	jmp	OS_calljump_s-static(a4)
;
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
;
	bss
;
	ds.l	(bss_static+3)/4
;
bss_limit:
;
;
;----------------------------------------------------------------------------
	end	;of file:	MAXIDISK.S
