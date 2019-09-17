; =====================================================================
; XRSCFIX() is a routine to calculate addresses and coordinates in a
; resource which is NOT loaded with RSRC_LOAD(), but with f.i. BLOAD
; or which are merged to the GfA Basic program, using INLINE.
; It handles all versions on resources, even on machines with no
; RSC=>3 capabillities. (extended size/ color icons)
; It fills and uses a secundary resource header array, made up of
; 20 LONG values (even if the resource file has the 'old' WORD-
; based header) The calling program must provide these 80 bytes
; working space and send its address too this routine in the
; second parameter. The first parameter is ofcourse the address
; of the 'raw' resource file itself.
;
; As a bonus, XRSCFIX() will eliminate LASTOB-errors (these errors
; will otherwise hang your machine) and also fixes up the OB_H's
; of color icons to their proper values (sometimes these are
; incorrectly set by Interface)

; Upon return, this Xheader-array is filled with:
;
;   xrsh%(0)  copy of rsc_startaddress% 
;   xrsh%(1)  copy of rsh_object (=offset to object structures)
;   xrsh%(2)  copy of rsh_tedinfo (=offset to tedinfo structures)
;   xrsh%(3)  copy of rsh_iconblk (=offset to iconblk structures)
;   xrsh%(4)  copy of rsh_bitblk (=offset to bitblk structures)
;   xrsh%(5)  copy of rsh_frstr (=offset to freestring pointer table)
;   xrsh%(6)  copy of rsh_string (=offset to string data)
;   xrsh%(7)  copy of rsh_imdata (=offset to image data)
;   xrsh%(8)  copy of rsh_frimg (=offset to image pointer table)
;   xrsh%(9)  copy of rsh_trindex (=offset to tree pointer table)
;   xrsh%(10) copy of rsh_nobs (=number of objects in the file)
;   xrsh%(11) copy of rsh_ntree (=number of trees in the file)
;   xrsh%(12) copy of rsh_nted (=number of tedinfos in the file)
;   xrsh%(13) copy of rsh_nib (=number of iconblk's in the file)
;   xrsh%(14) copy of rsh_nbb (=number of bitblk's in the file)
;   xrsh%(15) copy of rsh_nstring (=number of free strings in the file)
;   xrsh%(16) copy of rsh_nimages (=number of free images in the file)
;   xrsh%(17) copy of rsh_rssize (=old style resource file size)
;   xrsh%(18) number of color icons found in the resource 
;   xrsh%(19) address of ciconpointer-table or 0 if no color-icons found
;
; To call the function in GfA, use:
;
; ~C:xrscfix%(L:rsc_start%,L:xheaderarray%,charw&,charh&,hide_progdefs!)
;	' returnvalue is address of treepointer (xrsh%(0)+xrsh%(9))
;
; see the XRSC.TXT file for further details of the parameters, and the
; XRSC.GFA listing for a demo of its use.
;
; XRSCFIX() is written in DEVPAC 3 assembler to produce an
; Atari Executable file (XRSC.PRG) of 714 bytes
; (strip off the first 28 bytes to obtain the XRSCFIX.INL of 686 bytes)
;
; (c) Theo Ros for Ictari	21/04/97
;
;=======================================================================

	INCLUDE	XRSCVARS.EQU
	INCLUDE	OB_VARS.EQU
	
n_res		equ	34
monoblklen	equ	34+4

;=======================================================================
; first fill the Xheader array
;=======================================================================

	movem.l	4(sp),a0/a1	; rsc% en xrsh%
	movem.l	d2-d7/a2-a4,-(sp)	; save registers
	movea.l	a0,a2
	movea.l	a1,a3
	move.l	a0,(a3)+	; xrsh%(0)=address of resource-file
	moveq	#16,d0
	move.w	(a2)+,d1	; rsh_vrsn
	andi.w	#3,d1	; bits 0 en 1 set --> header 18 LONGS
	cmpi.w	#3,d1	
	bne.s	rscshort	; otherwise header 18 WORDS
	addq.l	#2,a2	; LONG header, so skip 2 bytes
rsclong:	move.l	(a2)+,(a3)+
	dbra	d0,rsclong
	bra.s	test_cicon
rscshort:	clr.w	(a3)+
	move.w	(a2)+,(a3)+
	dbra	d0,rscshort

test_cicon:  
	move.l	#0,(a3)+	; assume: no coloricons
	move.l	#0,(a3)+	; xrsh%(18)=0, xrsh%(19)=0
	move.w	(a0),d1
	subq.w	#3,d1
	bmi	cicon_exit	; version < 3: no color-icons

;=======================================================================
; if color icons present, treat them first
;=======================================================================

	movea.l	a0,a2		; a2=rsc%
	adda.l	xrsh_rssize(a1),a2	; a2=rsc%+xrsh%(17)
	move.l	4(a2),d7		; LONG{ "+4 }
	add.l	a0,d7		; +rsc% --> ciconptr%

	move.l	d7,xrsh_ciconptr(a1)	; xrsh%(19)=cicontabelpointer
	movea.l	d7,a0
	movea.l	d7,a2		; ciconptr%
	moveq.l	#0,d0		; counter
	moveq.l	#0,d4		; nplanes&
cicon_count:	
	move.l	(a0)+,d1		; a0=ciconblk%
	bmi.s	count_end
	addq.l	#1,d0
	bra.s	cicon_count

count_end:	
	move.l	d0,xrsh_ncicons(a1)	; xrsh%(18)=nr of color-icons
	movea.l	a1,a4		; save xrsh%-pointer
for_cicon:	tst.l	d0	; while cicons
	beq	cicon_exit
	move.l	a0,(a2)+		; ciconblk%
	moveq.l	#0,d1
	move.w	ib_wicon(a0),d1	; icnw
	addi.w	#15,d1
	lsr.w	#4,d1		; +15 div 16--> wordwidth
	mulu.w	ib_hicon(a0),d1	; *icnheight
	move.l	d1,d6		; save WORDlength
	add.w	d1,d1		; *2 --> monolen%
	move.l	n_res(a0),d3	; n_res%
	move.l	a0,d2		; d2=ciconblk%
	addi.l	#monoblklen,d2	; skip monoblk
	move.l	d2,ib_pdata(a0)	; ib_pdata in monoblok%
	add.l	d1,d2		; + monolen%
	move.l	d2,ib_pmask(a0)	; ib_pmask in monoblok
	add.l	d1,d2		; in d2 address of icon_text buffer

	movea.l	d2,a3
	tst.b	(a3)		; empty?
	bne.s	set_ib_ptext	; no, max 12 chars.
	move.l	ib_ptext(a0),d5	; relocated text? (usually >12 chars)
	beq.s	set_ib_ptext	; no, really empty
	add.l	xrsh_resource(a4),d5	; text_offset + rsc%
	
				; XRSCFIX() sets special code in buffer
	clr.l	(a3)+		; MKL$(0)+"XTXT"+MKL$(adr%)
	move.l	#'XTXT',(a3)+	; to make sure the reader knows what's there
	move.l	d5,(a3)		
	
set_ib_ptext:
	move.l	d2,ib_ptext(a0)	; ib_ptext in monoblok%

	addi.l	#12,d2		; textbuffer is 12 bytes
	movea.l	d2,a0		; a0=ciconblk% (points to 1st ciconblk)

while_res:	tst.l	d3	; while n_res%
	beq.s	next_cicon
	movea.l	a0,a1		; copy ciconblk%
	adda.l	#22,a1		; a1=colordata
	move.w	(a0)+,d4		; d4=nplanes&
	moveq	#0,d5
	moveq	#0,d7		; calc colorlen%
	move.w	d4,d5
	subq.w	#1,d5
colorlen:	add.l	d1,d7
	dbra	d5,colorlen	; d7=colorlen%

	bsr.s	do_bitmap		; set address data en mask and vr_trnfm()
	tst.l	(a0)		; select_data exists?
	beq.s	wend
	bsr.s	do_bitmap		; transform these too

wend:	movea.l	a1,a0		; a0 again ciconblk%
	subq.l	#1,d3
	bra.s	while_res

next_cicon:
	subq.l	#1,d0
	bra	for_cicon

cicon_exit:
	movem.l	(sp)+,d2-d7/a2-a4
	bra.s	xrsc_fix	
	
;=======================================================================
; subroutine do_bitmap transforms the colordata in place from
; machine independent to VDI format. Here, TOS function vr_trnfm()
; is NOT used, but for maximum speed an adapted version of NVDI's
; vr_trnfm(), which also does not require any mfdb's to save bytes.
; right after transforming imagedata, the addresses of data and mask
; are calculated and written in the resource
;=======================================================================

do_bitmap:			; a1=data, d4=nplanes, d6=WORDlen
	movem.l	d0-d6/a0-a2,-(sp)	; save registers
	subq.l	#1,d6		
	ble.s	trans_exit	; not even 1 word?
	move.l	d4,d1		; nplanes --> planecount
	subq	#2,d1		; at least 2 bitplanes?
	bmi.s	trans_exit
	movea.l	a1,a0		; address of bitmap, transform IN PLACE

trans_loop:	
	moveq	#0,d2
	move.l	d1,d4		; planecount --> nplanes

trans_plane:	
	adda.l	d6,a0		; add wordwidth
	lea	2(a0,d6.l),a0
	move.w	(a0),d5
	movea.l	a0,a1	
	movea.l	a0,a2
	add.l	d6,d2
	move.l	d2,d0
	bra.s	trans_next

trans_words:	
	movea.l	a1,a2
	move.w	-(a1),(a2)

trans_next:	
	subq.l	#1,d0		; done 1 word
	bpl.s	trans_words
	move.w	d5,(a1)

	subq.l	#1,d4		; done 1 plane
	bpl.s	trans_plane
	movea.l	a2,a0
	subq.l	#1,d6
	bpl.s	trans_loop

trans_exit:	
	movem.l	(sp)+,d0-d6/a0-a2

	move.l	a1,(a0)+		; write address of color DATA
	adda.l	d7,a1		; + colorlen% --> address MASK
	move.l	a1,(a0)+		; write  color MASK
	adda.l	d1,a1		; + monolen% --> next cicon
	rts
	
;=======================================================================
; this is where the rest of the resource is 'fixed'
;=======================================================================

xrsc_fix:	movem.l	4(sp),a0/a1	; address .RSC-file and address Xheaderarray
	movem.w	12(sp),d5-d7	; flag: <>0 --> hide progdefs
	move.l	a3,-(sp)		; d6=charw, d7=charh
	
	move.l	a0,d2		; copy address
	move.l	xrsh_trindex(a1),d0 ; offset of treepointer
	add.l	d2,d0		; in d0 address 1e objecttree
	move.l	xrsh_ntree(a1),d1	; xrsh_ntree
	ble.s	fix_obj
	movea.l	d0,a2		; xrsh_trindex
fix_tree:	add.l	d2,(a2)		; LONG{adr%}=LONG{adr%}+rsc%
	move.l	(a2),a3		; some progs forget LASTOB !! (ICO2RSC.PRG)
	tst.w	ob_next(a3) 	; test end of tree
	bmi.s	nexttree		; no children?
	move.w	ob_tail(a3),d4	; number of last child
	bmi.s	nexttree
	mulu.w	#24,d4
	ori.w	#$20,ob_flags(a3,d4.w)	; set LASTOB
nexttree:	addq.l	#4,a2	
	subq.l	#1,d1
	bne.s	fix_tree
	
fix_obj:	move.l	xrsh_nobs(a1),d1	; xrsh_nobs
	ble.s	fix_ted
	movea.l	a0,a2
	adda.l	xrsh_object(a1),a2 	; offset of xrsh_object
obj_lus:	bsr	xrsc_obfix	; faster than RSRC_OBFIX()
	cmpi.b	#G_TEXT,ob_type(a2)	; test OB_TYPE
	bcs.s	obj_next		; 20,25 and 27 point to BOXINFO
	cmpi.b	#G_CICON,ob_type(a2)
	bhi.s	obj_next		; >33? --> unknown object type..
	cmpi.b	#G_IBOX,ob_type(a2)	
	beq.s	obj_next
	cmpi.b	#G_BOXCHAR,ob_type(a2)
	beq.s	obj_next
	cmpi.b	#G_CICON,ob_type(a2)
	bne.s	chk_pdef
	move.l	ob_spec(a2),d4	; color icon:
	lsl.l	#2,d4		; OB_SPEC(tree%,obj)=LONG{xrsh%(19)+OB_SPEC(tree%,obj)*4}
	movea.l	xrsh_ciconptr(a1),a3
	movea.l	0(a3,d4.l),a3
	move.l	a3,ob_spec(a2)
	move.w	ib_hicon(a3),d4	; correct OB_H ...
	add.w	ib_htext(a3),d4
	move.w	d4,ob_h(a2)
	bra.s	obj_next
chk_pdef:	cmpi.b	#G_PROGDEF,ob_type(a2)
	bne.s	obj_adr		; object types 28 to 32
	tst.w	d7		; flag: <>0 --> hide progdef
	beq.s	obj_adr
	ori.w	#$80,ob_flags(a2)	; --> OB_FLAGS=HIDETREE
obj_adr:	add.l	d2,ob_spec(a2)
obj_next:	lea	24(a2),a2
	subq.l	#1,d1
	bne.s	obj_lus
	

;=======================================================================
; now calculate all substructures
;=======================================================================

fix_ted:	move.l	xrsh_nted(a1),d1	; xrsh_nted
	ble.s	fix_icn
	movea.l	a0,a2
	adda.l	xrsh_tedinfo(a1),a2 ; offset to xrsh_tedinfo
ted_lus:	add.l	d2,(a2)+		; +4 --> xrsh_tedinfo
	add.l	d2,(a2)+		; +4
	add.l	d2,(a2)+		; +4
	lea	16(a2),a2		; +16=28 bytes TEDINFO
	subq.l	#1,d1
	bne.s	ted_lus

fix_icn:	move.l	xrsh_nib(a1),d1	; xrsh_nib (iconblk)
	ble.s	fix_bit
	movea.l	a0,a2
	adda.l	xrsh_iconblk(a1),a2 ; xrsh_iconblk
icn_lus:	add.l	d2,(a2)+		; +4
	add.l	d2,(a2)+		; +4
	add.l	d2,(a2)+		; +4
	lea	22(a2),a2		; +22=34 bytes ICONBLK
	subq.l	#1,d1
	bne.s	icn_lus

fix_bit:	move.l	xrsh_nbb(a1),d1	; xrsh_nbb (bitblk)
	ble.s	fix_str
	movea.l	a0,a2
	adda.l	xrsh_bitblk(a1),a2 	; offset to xrsh_bitblk
bit_lus:	add.l	d2,(a2)+		; +4
	lea	10(a2),a2		; +10=14 bytes BITBLK
	subq.l	#1,d1
	bne.s	bit_lus

fix_str:	move.l	xrsh_nstring(a1),d1 ; xrsh_nstring
	ble.s	fix_img
	movea.l	a0,a2
	adda.l	xrsh_frstr(a1),a2	; offset to xrsh_frstr
str_lus:	add.l	d2,(a2)+
	subq.l	#1,d1
	bne.s	str_lus

fix_img:	move.l	xrsh_nimages(a1),d1 ; xrsh_nimages
	ble.s	fix_end
	movea.l	a0,a2
	adda.l	xrsh_frimg(a1),a2	; offset to xrsh_frimg
img_lus:	add.l	d2,(a2)+
	subq.l	#1,d1
	bne.s	img_lus

fix_end:	move.l	(sp)+,a3
	rts

;=======================================================================
; subroutine xrsc_obfix replaces TOS-function RSRC_OBFIX() for
; faster results 
;=======================================================================

xrsc_obfix:
	movem.l	d0-d3,-(sp)	; d0=obj, d6=charw,d7=charh
	move.w	ob_x(a2),d0	; a2=OB_ADR
	bsr.s	.obfix
	move.w	d0,ob_x(a2)
	move.w	ob_w(a2),d0
	bsr.s	.obfix
	move.w	d0,ob_w(a2)
	exg	d5,d6		; swap charw,charh
	move.w	ob_y(a2),d0
	bsr.s	.obfix
	move.w	d0,ob_y(a2)
	move.w	ob_h(a2),d0
	bsr.s	.obfix
	move.w	d0,ob_h(a2)	
	exg	d5,d6		; swap back again
	movem.l	(sp)+,d0-d3
	rts
	
.obfix:	move.w	d0,d3
	lsr.w	#8,d3	; extra pixels
	andi.w	#$ff,d0	; offset
	mulu	d5,d0	; * charw or charh
	add.w	d3,d0	; + extra pixels
	rts