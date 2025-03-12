* - Generic LINKLOADER system made for UnderCoverMagazine -
*           - (C)oderight 1998 by EarX of FUN -
*
* LOAD_INCFILE loads a file, checks it for known packtypes
* and depacks it.
* In archivemode it loads from a big archive. When this mode
* is off it simply loads from the normal filesystem.
*
* So it is a completely transparent system. It might seem you're
* loading from a local directory, while you're actually reading
* from an archive with ICE or ATOMIK packed data.
*
* This includefile also contains subroutines:
* OPEN_LINKFILE     Opens an existing archive, otherwise a new one is created.
* CREATE_LINKFILE   Creates a new archive or overwrites an old one.
* SAVE_INCFILE      Appends an incfile to the archive.
* REPLACE_INCFILE   Replaces or Appends an incfile to the archive.
* STORE_INCFILENAME Stores a filename and size in the index of the acrhive.
* WRITE_LINKBUFFER  Appends a databuffer to the archive.
*
* System works on TOS 1.0 and standard 68000.

		IFND	archivemode
archivemode:	EQU	0
		ENDC

maxlinkfiles:	EQU	256
linkentrysize:	EQU	20

newlinksaved:	EQU	0
linkreplaced:	EQU	1

******** MACROS ********

; Fopen fname  (ret: D0.w handle)
Fopen	MACRO
	clr.w	-(sp)
	pea	\1
	move.w	#$3d,-(sp)
	trap	#1
	addq	#8,sp
	ENDM

; Fcreate fname  (ret: d0.w handle)
Fcreate	MACRO
	clr.w	-(sp)
	pea	\1
	move.w	#$3c,-(sp)
	trap	#1
	addq	#8,sp
	ENDM
	
; Fread handle,dest,len  (ret: D0.l TatsÑchliche LÑnge)
Fread	MACRO
	pea	\2
	move.l	\3,-(sp)
	move.w	\1,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	lea	$c(sp),sp
	ENDM

; Fwrite handle,source,len  (ret: d0.l TatsÑchliche Anzahl geschriebener Bytes)
Fwrite	MACRO
	pea	\2
	move.l	\3,-(sp)
	move.w	\1,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	lea	$c(sp),sp
	ENDM
	
; Fclose handle
Fclose	MACRO
	move.w	\1,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq	#4,sp
	ENDM
	
; Fseek handle,pos
Fseek	MACRO
	clr.w	-(sp)
	move.w	\1,-(sp)
	move.l	\2,-(sp)
	move.w	#$42,-(sp)
	trap	#1
	lea	$a(sp),sp
	ENDM
	
; Frelseek handle,relpos
Frelseek MACRO
	move.w	#1,-(sp)
	move.w	\1,-(sp)
	move.l	\2,-(sp)
	move.w	#$42,-(sp)
	trap	#1
	lea	$a(sp),sp
	ENDM

; Fdelete fname^
Fdelete	MACRO
	pea	\1
	move.w	#$41,-(sp)
	trap	#1
	addq	#6,sp
	ENDM

; Frename oldfname^,newfname^
Frename	MACRO
	pea	\2
	pea	\1
	clr.w	-(sp)
	move.w	#$56,-(sp)
	trap	#1
	lea	$c(sp),sp
	ENDM

; Fsfirst fspec^,attribs
Fsfirst	MACRO
	move.w	\2,-(sp)
	pea	\1
	move.w	#$4e,-(sp)
	trap	#1
	addq	#8,sp
	ENDM

; Fsnext
Fsnext	MACRO
	move.w	#$4f,-(sp)
	trap	#1
	addq	#2,sp
	ENDM

; Fgetdta  (ret: d0.l  Zeiger auf aktuelle DTA)
Fgetdta	MACRO
	move.w	#$2f,-(sp)
	trap	#1
	addq	#2,sp
	ENDM

; Fsetdta ptr
Fsetdta	MACRO
	pea	\1
	move.w	#$1a,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM
	
; Pexec mode,fname,cmdline,envptr  (ret: d0.w Mode 3/5:Ptr. auf Basepage, 0/4:Returnwert d. Prgs.)
Pexec	MACRO
	pea	\4
	pea	\3
	pea	\2
	move.w	\1,-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	lea	$10(sp),sp
	ENDM

; _LOAD fname^,dest,len  (ret: d0.l TatsÑchliche LÑnge, neg.l:Fehler)
_LOAD	MACRO
.l0\@:	tst.b	disk_in_use
	bne.s	.l0\@
	st	disk_in_use
	movem.l	d0-a6,-(sp)
	lea	\1,a0
	lea	\2,a1
	move.l	\3,d0
	bsr	load
	movem.l	(sp)+,d0-a6
	sf	disk_in_use
	ENDM

; _SAVE fname^,dest,len  (ret: d0.l)
_SAVE	MACRO
.l0\@:	tst.b	disk_in_use
	bne.s	.l0\@
	st	disk_in_use
	movem.l	a0/a1,-(sp)
	lea	\1,a0
	lea	\2,a1
	move.l	\3,d0
	bsr	save
	movem.l	(sp)+,a0/a1
	sf	disk_in_use
	ENDM
	
******** SUBROUTINES ********

; d0 (s. amount, Profibuch)
malloc:	move.l	d0,-(sp)
	move.w	#$48,-(sp)
	trap	#1
	addq	#6,sp
	rts

mfree:	move.l	d0,-(sp)
	move.w	#73,-(sp)
	trap	#1
	addq	#6,sp
	rts

; -> d0.l  LÑnge
;    a0.l  Fname^
;    a1.l  Dest
; <- d0.l  TatsÑchliche LÑnge oder Fehler (negativ LONG!)
load:	move.l	d0,d6
	Fopen	(a0)
	move.w	d0,d7
	bmi.s	.e
	Fread	d7,(a1),d6
	move.l	d0,d6
	bmi.s	.e
	Fclose	d7
	ext.l	d0
	bmi.s	.e
	move.l	d6,d0	
.e:	rts

; -> d0.l  LÑnge
;    a0.l  Fname^
;    a1.l  Dest
; <- d0.l  TatsÑchliche LÑnge oder Fehler (negativ LONG!)
save:	move.l	d0,d6
	Fcreate	(a0)
	move.w	d0,d7
	bmi.s	.e
	Fwrite	d7,(a1),d6
	move.l	d0,d6
	bmi.s	.e
	Fclose	d7
	ext.l	d0
	bmi.s	.e
	move.l	d6,d0	
.e:	rts

	DATA
	
disk_in_use:
	DC.B	0
	EVEN

	TEXT

* Routine that copies a given amount of data from one address to the other.
* INPUT: a0: startaddress of destination buffer
*        a1: startaddress of source buffer
*        d0.l: number of bytes to copy
COPY_BUFFER
	divu.w	#192,d0
	subq.w	#1,d0
	bmi.s	.small
.biglp	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,48(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,96(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,144(a0)
	lea	192(a0),a0
	dbra	d0,.biglp
.small	swap	d0
	move.w	d0,d1
	andi.w	#$fff8,d0
	sub.w	d0,d1
	lsr.w	#3,d0
	subq.w	#1,d0
	bmi.s	.mini
.smallp	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbra	d0,.smallp
.mini	subq.w	#1,d1
	bmi.s	.rts
.minilp	move.b	(a1)+,(a0)+
	dbra	d1,.minilp
.rts	rts

* Loading routine that can load from an archive or directly from a filesys.
* Can also depack the shit.
* All is allocated on a long-edge!
* INPUT: a1: address of filename
* OUTPUT: a0: address of loaded file
*         d0.l: 0= all clear
*               -1= error
LOAD_INCFILE:
	IFEQ	archivemode

	tst.w	.dataset
	bne.s	.skipdatasetting
	move.l	a1,-(sp)
	Fsetdta	.data_tbl(pc)
	move.l	(sp)+,a1
.skipdatasetting:
	move.l	a1,-(sp)			* Store filename.
	Fsfirst	(a1),#0
	tst.l	d0
	bpl.s	.malloc
	addq	#4,sp
	bra.s	.error
.malloc:
	move.l	.data_tbl+26(pc),d0		* d0.l: filesize
	addq.l	#4,d0
	bsr	malloc
	move.l	d0,.mallocadr
	bne.s	.load
	addq	#4,sp
	bra.s	.error
.load:	addq.l	#4,d0				* / Put on
	andi.b	#%11111100,d0			* \ Long edge!
	move.l	(sp)+,a0			* Restore filename.
	move.l	d0,-(sp)			* Store bufferaddress.
	movea.l	d0,a1
	move.l	.data_tbl+26(pc),d0
	bsr	load
	tst.l	d0
	bpl.s	.depack
	addq	#4,sp
	bra.s	.error

.depack:
	lea	(a1),a0
	bsr	DEPACK_BUFFER

	tst.l	d0
	bgt.s	.newaddress
	beq.s	.oldaddress
	addq	#4,sp
	bra.s	.error

.oldaddress:
	movea.l	(sp)+,a0
	moveq	#0,d0
	rts

.newaddress:
	move.l	a0,-(sp)
	move.l	.mallocadr(pc),d0		* / Deallocate old
	bsr	mfree				* \ buffer.
	movea.l	(sp)+,a0
	addq	#4,sp
	moveq	#0,d0
	rts

.error:	moveq	#-1,d0
	rts

.dataset:
	DC.W	0
.mallocadr:
	DS.L	1
.data_tbl:
	DS.L	12

	ELSE

	tst.w	.opened
	bne.s	.skipdirload
	movem.l	a0-a1,-(sp)
	Fopen	.dataname_txt(pc)
	movem.l	(sp)+,a0-a1
	move.w	d0,linkfilehandle
	bmi	.error
	movem.l	a0-a1,-(sp)
	Fread	d0,dir_tbl,#maxlinkfiles*linkentrysize
	movem.l	(sp)+,a0-a1
	not.w	.opened
.skipdirload:
	lea	dir_tbl,a2
	lea	(a1),a6
	move.w	#maxlinkfiles-2,d7
.fndlop:
	lea	(a6),a1
	lea	(a2),a0
.charlop:
	move.b	(a1)+,d0
	beq.s	.found
	cmp.b	(a0)+,d0
	beq.s	.charlop
	lea	linkentrysize(a2),a2
	lea	(a2),a0
	dbra	d7,.fndlop
	bra	.error
.found:	cmpi.w	#maxlinkfiles-2,d7
	bne.s	.notfirst
	moveq	#0,d0
	bra.s	.load
.notfirst:
	move.l	-4(a2),d0

.load:	addi.l	#maxlinkfiles*linkentrysize,d0
	Fseek	linkfilehandle,d0

	lea	(a2),a0
	bsr	GET_INCFILESIZE

	move.l	d0,-(sp)
	addq.l	#4,d0
	bsr	malloc
	move.l	d0,.mallocadr
	bne.s	.on
	addq	#4,sp
	bra.s	.error
.on:	addq.l	#4,d0				* / Put on
	andi.b	#%11111100,d0			* \ long edge!
	movea.l	d0,a0
	move.l	(sp)+,d0
	move.l	a0,-(sp)
	Fread	linkfilehandle,(a0),d0
	movea.l	(sp)+,a0

	move.l	a0,-(sp)
	bsr	DEPACK_BUFFER

	tst.l	d0
	bgt.s	.newaddress
	beq.s	.oldaddress
	addq	#4,sp
	bra.s	.error

.oldaddress:
	movea.l	(sp)+,a0
	moveq	#0,d0
	rts

.newaddress:
	move.l	a0,-(sp)
	move.l	.mallocadr(pc),d0		* / Deallocate old
	bsr	mfree				* \ buffer.
	movea.l	(sp)+,a0
	addq	#4,sp
	moveq	#0,d0
	rts

.error:	moveq	#-1,d0
	rts

.dataname_txt:
	DC.B	"DATA",0
	EVEN
.opened:
	DC.W	0
.filehandle:
	DC.W	0
.mallocadr:
	DC.L	0

	ENDC

* Loading routine that can load from an archive or directly from a filesys.
* Can also depack the shit.
* The final (depacked) data is put into the specified buffer.
* INPUT: a0: address of buffer to write to
*        a1: address of filename
* OUTPUT: d0.l: 0= all clear
*               -1= error
LOAD_INCFILETOBUF:
	IFEQ	archivemode

	tst.w	.dataset
	bne.s	.skipdatasetting
	movem.l	a0-a1,-(sp)
	Fsetdta	.data_tbl(pc)
	movem.l	(sp)+,a0-a1
	not.w	.dataset
.skipdatasetting:
	movem.l	a0-a1,-(sp)			* Store filename.
	Fsfirst	(a1),#0
	tst.l	d0
	bpl.s	.load
	addq	#8,sp
	bra.s	.error
.load:	movea.l	4(sp),a0			* Restore filename.
	movea.l	(sp),a1
	addq	#8,sp
	move.l	.data_tbl+26(pc),d0
	bsr	load
	tst.l	d0
	bmi.s	.error
	
	move.l	d0,-(sp)
	movea.l	a1,a0
	bsr	DEPACK_BUFTOBUF
	tst.l	d0
	bgt.s	.waspacked
	beq.s	.wasunpacked
	addq	#4,sp
	bra.s	.error
.wasunpacked:
	move.l	(sp)+,d0
	rts
.waspacked:
	addq	#4,sp
	rts

.error:	moveq	#-1,d0
	rts

.dataset:
	DC.W	0
.mallocadr:
	DS.L	1
.data_tbl:
	DS.L	12

	ELSE

	tst.w	.opened
	bne.s	.skipdirload
	movem.l	a0-a1,-(sp)
	Fopen	.dataname_txt(pc)
	movem.l	(sp)+,a0-a1
	move.w	d0,linkfilehandle
	bmi	.error
	movem.l	a0-a1,-(sp)
	Fread	d0,dir_tbl,#maxlinkfiles*linkentrysize
	movem.l	(sp)+,a0-a1
	not.w	.opened
.skipdirload:
	move.l	a0,-(sp)
	lea	dir_tbl,a2
	movea.l	a1,a6
	move.w	#maxlinkfiles-2,d7
.fndlop:
	movea.l	a6,a1
	movea.l	a2,a0
.charlop:
	move.b	(a1)+,d0
	beq.s	.found
	cmp.b	(a0)+,d0
	beq.s	.charlop
	lea	linkentrysize(a2),a2
	movea.l	a2,a0
	dbra	d7,.fndlop
	addq	#4,sp
	bra	.error
.found:	cmpi.w	#maxlinkfiles-2,d7
	bne.s	.notfirst
	moveq	#0,d0
	bra.s	.load
.notfirst:
	move.l	-4(a2),d0

.load:	addi.l	#maxlinkfiles*linkentrysize,d0
	Fseek	linkfilehandle,d0

	movea.l	a2,a0
	bsr	GET_INCFILESIZE

	movea.l	(sp),a0
	Fread	linkfilehandle,(a0),d0
	movea.l	(sp)+,a0
	move.l	d0,-(sp)
	bsr	DEPACK_BUFTOBUF
	tst.l	d0
	bgt.s	.waspacked
	beq.s	.wasunpacked
	addq	#4,sp
	bra.s	.error
.wasunpacked:
	move.l	(sp)+,d0
	rts
.waspacked:
	addq	#4,sp
	rts

.error:	moveq	#-1,d0
	rts

.dataname_txt:
	DC.B	"DATA",0
	EVEN
.opened:
	DC.W	0
.filehandle:
	DC.W	0
.mallocadr:
	DC.L	0

	ENDC

* INPUT: a0: address of (packed) buffer
* OUTPUT: d0.l: 0= not packed
*               1= packed
*               -1= error
*         a0: address of (depacked) buffer if the input was packed
DEPACK_BUFFER:
	cmpi.l	#"ICE!",(a0)
	bne.s	.nextpacktype
	move.l	8(a0),d0
	addq.l	#4,d0
	move.l	a0,-(sp)
	bsr	malloc
	move.l	(sp)+,a1
	tst.l	d0
	beq.s	.error
	addq.l	#4,d0				* / Put on
	andi.b	#%11111100,d0			* \ Long edge!
	movea.l	d0,a0
	move.l	a0,-(sp)
	move.l	8(a1),d0
	bsr	COPY_BUFFER
	move.l	(sp)+,a0
	move.l	a0,-(sp)
	bsr	DEPACK_ICE
	move.l	(sp)+,a0			* a0: address of depacked file.
	moveq	#1,d0				* Indicate that file was packed.
	rts

.nextpacktype:
* More types in here..
	nop

.notpacked:
	moveq	#0,d0				* Indicate that file was unpacked.
	rts

.error:	moveq	#-1,d0
	rts

* INPUT: a0: address of (packed) buffer
* OUTPUT: d0.l: >0 size of (unpacked) file
*               -1= error
DEPACK_BUFTOBUF:
	cmpi.l	#"ICE!",(a0)
	bne.s	.nextpacktype
	move.l	8(a0),-(sp)
	bsr	DEPACK_ICE
	move.l	(sp)+,d0
	rts

.nextpacktype:
* More types in here..
	nop

.notpacked:
	moveq	#0,d0				* Indicate that file was unpacked.
	rts

.error:	moveq	#-1,d0
	rts

* Unpacking routine of PACK-ICE
* INPUT a0: address of packed data
DEPACK_ICE:
	link	a3,#-120
	movem.L	d0-a6,-(sp)
	lea	120(a0),a4
	move.L	a4,a6
	bsr.s	.getinfo
	cmpi.L	#'ICE!',d0
	bne.S	.not_packed
	bsr.s	.getinfo
	lea.L	-8(a0,d0.L),a5
	bsr.s	.getinfo
	move.L	d0,(sp)
	adda.L	d0,a6
	move.L	a6,a1
	moveq	#119,d0
.save:	move.B	-(a1),-(a3)
	dbf	d0,.save
	move.L	a6,a3
	move.B	-(a5),d7
	bsr.s	.normal_bytes
	move.L	a3,a5
	bsr	.get_1_bit
	bcc.s	.no_picture
	move.W	#$0f9f,d7
	bsr	.get_1_bit
	bcc.s	.ice_00
	moveq	#15,d0
	bsr	.get_d0_bits
	move.W	d1,d7
.ice_00:
	moveq	#3,d6
.ice_01:
	move.W	-(a3),d4
	moveq	#3,d5
.ice_02:
	add.W	d4,d4
	addx.W	d0,d0
	add.W	d4,d4
	addx.W	d1,d1
	add.W	d4,d4
	addx.W	d2,d2
	add.W	d4,d4
	addx.W	d3,d3
	dbra	d5,.ice_02
	dbra	d6,.ice_01
	movem.W	d0-d3,(a3)
	dbra	d7,.ice_00
.no_picture:
	movem.L	(sp),d0-a3

.move:	move.B	(a4)+,(a0)+
	subq.L	#1,d0
	bne.s	.move
	moveq	#119,d0
.TRESt:	move.B	-(a3),-(a5)
	dbf	d0,.TRESt
.not_packed:
	movem.L	(sp)+,d0-a6
	unlk	a3
	rts
.getinfo:
	moveq	#3,d1
.getbytes:
	lsl.L	#8,d0
	move.B	(a0)+,d0
	dbf	d1,.getbytes
	rts
.normal_bytes:
	bsr.s	.get_1_bit
	bcc.s	.test_if_end
	moveq.L	#0,d1
	bsr.s	.get_1_bit
	bcc.s	.copy_direkt
	lea.L	.direkt_tab+20(pc),a1
	moveq.L	#4,d3
.nextgb:
	move.L	-(a1),d0
	bsr.s	.get_d0_bits
	swap.W	d0
	cmp.W	d0,d1
	dbne	d3,.nextgb
.no_more:
	add.L	20(a1),d1
.copy_direkt:
	move.B	-(a5),-(a6)
	dbf	d1,.copy_direkt
.test_if_end:
	cmpa.L	a4,a6
	bgt.s	.strings
	rts	
.get_1_bit:
	add.B	d7,d7
	bne.s	.Bitfound
	move.B	-(a5),d7
	addx.B	d7,d7
.Bitfound:
	rts	
.get_d0_bits:
	moveq.L	#0,d1
.hole_bit_loop:
	add.B	d7,d7
	bne.s	.on_d0
	move.B	-(a5),d7
	addx.B	d7,d7
.on_d0:	addx.W	d1,d1
	dbf	d0,.hole_bit_loop
	rts	
.strings:
	lea.L	.Length_tab(pc),a1
	moveq.L	#3,d2
.get_length_bit:	
	bsr.s	.get_1_bit
	dbcc	d2,.get_length_bit
.no_length_bit:
	moveq.L	#0,d4
	moveq.L	#0,d1
	move.B	1(a1,d2.W),d0
	ext.W	d0
	bmi.s	.no_Åber
.get_Åber:
	bsr.s	.get_d0_bits
.no_Åber:
	move.B	6(a1,d2.W),d4
	add.W	d1,d4
	beq.s	.get_offset_2
	lea.L	.more_offset(pc),a1
	moveq.L	#1,d2
.getoffs:
	bsr.s	.get_1_bit
	dbcc	d2,.getoffs
	moveq.L	#0,d1
	move.B	1(a1,d2.W),d0
	ext.W	d0
	bsr.s	.get_d0_bits
	add.W	d2,d2
	add.W	6(a1,d2.W),d1
	bpl.s	.depack_bytes
	sub.W	d4,d1
	bra.s	.depack_bytes
.get_offset_2:
	moveq.L	#0,d1
	moveq.L	#5,d0
	moveq.L	#-1,d2
	bsr.s	.get_1_bit
	bcc.s	.Less_40
	moveq.L	#8,d0
	moveq.L	#$3f,d2
.Less_40:
	bsr.s	.get_d0_bits
	add.W	d2,d1
.depack_bytes:
	lea.L	2(a6,d4.W),a1
	adda.W	d1,a1
	move.B	-(a1),-(a6)
.dep_b:	move.B	-(a1),-(a6)
	dbf	d4,.dep_b
	bra	.normal_bytes

.direkt_tab:
	dc.L	$7fff000e,$00ff0007,$00070002,$00030001,$00030001
	dc.L     270-1,	15-1,	 8-1,	 5-1,	 2-1
.Length_tab:
	dc.B	9,1,0,-1,-1
	dc.B	8,4,2,1,0
.more_offset:
	dc.B	  11,   4,   7,  0		* Bits lesen
	dc.W	$11f,  -1, $1f			* Standard Offset
	EVEN

* INPUT: a1: address of datafilename
* OUTPUT: d0.l: 0= all clear
*               -1= error
* POST: if successful the filepointer is set to end of archive
CREATE_LINKFILE:
	tst.w	linkfileopen
	bne.s	.skipdirload
	Fcreate	(a1)
	move.w	d0,linkfilehandle
	bmi.s	.error
.readdir:
	Fread	d0,dir_tbl,#maxlinkfiles*linkentrysize
	Fwrite	linkfilehandle,dir_tbl,#maxlinkfiles*linkentrysize
	clr.l	lastlinkfileindex
	not.w	linkfileopen
.skipdirload:
	moveq	#0,d0
	rts
.error:	moveq	#-1,d0
	rts

* INPUT: a1: address of datafilename
* OUTPUT: d0.l: 0= all clear
*               -1= error
* POST: if successful the filepointer is set to end of archive
OPEN_LINKFILE:
	tst.w	linkfileopen
	bne	.skipdirload
	Fopen	(a1)
	move.w	d0,linkfilehandle
	bpl.s	.readdir
* The given archive doesn't exist!
* A new archive is created!
	Fcreate	(a1)
	move.w	d0,linkfilehandle
	bmi.s	.error
	Fwrite	linkfilehandle,dir_tbl,#maxlinkfiles*linkentrysize
	bra.s	.end
* The given archive exists.
.readdir:
	Fread	d0,dir_tbl,#maxlinkfiles*linkentrysize
	lea	dir_tbl+linkentrysize-4,a0
	move.w	#maxlinkfiles-2,d7
.floop:	move.l	(a0),d0
	beq.s	.found
	lea	linkentrysize(a0),a0
	dbra	d7,.floop
	bra.s	.error
.found:	move.l	-linkentrysize(a0),d0
	addi.l	#maxlinkfiles*linkentrysize,d0
	Fseek	linkfilehandle,d0

.end:	clr.l	lastlinkfileindex
	not.w	linkfileopen
.skipdirload:
	moveq	#0,d0
	rts	
.error:	moveq	#-1,d0
	rts

* INPUT: d0.l: lenght of buffer
*        a0: address of buffer
*        a1: address of filename
* OUTPUT: d0.l: 0= all clear
*               -1= error
SAVE_INCFILE:
	tst.w	linkfileopen
	beq	.error
	lea	dir_tbl,a2
	adda.l	lastlinkfileindex,a2
	lea	(a2),a3
	move.l	d0,d1
	cmpa.l	#dir_tbl,a2
	beq.s	.savename
	add.l	-4(a2),d0
.savename:
.nmlop:	move.b	(a1)+,(a3)+
	bne.s	.nmlop
	move.l	d0,linkentrysize-4(a2)

	Fwrite	linkfilehandle,(a0),d1

	addi.l	#linkentrysize,lastlinkfileindex
	moveq	#0,d0
	rts

.error:	moveq	#-1,d0
	rts

* INPUT: d0.l: filesize
*        a0: address of filename
* OUTPUT: d0.l: 0= all clear
*               -1= error
STORE_INCFILENAME:
	lea	dir_tbl,a1
	move.l	lastlinkfileindex,d1
	cmpi.l	#(maxlinkfiles-1)*linkentrysize,d1
	bhs.s	.error
	adda.l	lastlinkfileindex,a1
	cmpa.l	#dir_tbl,a1
	beq.s	.first
	add.l	-4(a1),d0
.first:	move.l	d0,linkentrysize-4(a1)

.loop:	move.b	(a0)+,(a1)+
	bne.s	.loop

	moveq	#linkentrysize,d0
	add.l	d0,lastlinkfileindex
	
	moveq	#0,d0
	rts

.error:	moveq	#-1,d0
	rts

* INPUT: d0.l: number of bytes to write
*        a0: address of data to put in archive
WRITE_LINKBUFFER:
	Fwrite	linkfilehandle,(a0),d0
	rts

* INPUT: d0.l: lenght of buffer
*        a0: address of buffer
*        a1: address of filename
* OUTPUT: d0.l: 0= all clear
*               -1= error
REPLACE_INCFILE:
	tst.w	linkfileopen
	beq	.error

	lea	dir_tbl,a2
	move.w	#maxlinkfiles-2,d7
	lea	(a1),a6

* Look for occurence of filename or take the first vacant position.
.floop:	lea	(a2),a3
.chlop:	tst.b	(a3)
	beq.s	.new_found
.cmplp:	move.b	(a1)+,d1
	beq.s	.old_found
	cmp.b	(a3)+,d1
	beq.s	.cmplp
	lea	linkentrysize(a2),a2
	lea	(a6),a1
	dbra	d7,.floop
	bra	.error

* Filename did not occur in the archive.
* File will be appended.
.new_found:
	addi.l	#linkentrysize,lastlinkfileindex
	lea	(a2),a3
	move.l	d0,d1
	cmpi.w	#maxlinkfiles-2,d7
	beq.s	.new_first
	add.l	-4(a2),d0
.new_first:
.new_nmlop:
	move.b	(a6)+,(a3)+
	bne.s	.new_nmlop
	move.l	d0,linkentrysize-4(a2)
* Append file to archive.
	Fwrite	linkfilehandle,(a0),d1

	moveq	#newlinksaved,d0
	rts

* Filename already occurs in archive.
* File will be replaced.
.old_found:
	lea	(a2),a3
	move.l	d0,d1
	move.l	#maxlinkfiles*linkentrysize,d2
	cmpi.w	#maxlinkfiles-2,d7
	beq.s	.old_first
	add.l	-4(a2),d2
	add.l	d2,d0

.old_first:
	movem.l	d1/d2/d7/a0/a2,-(sp)
	move.l	d0,-(sp)
	lea	(a2),a0
	bsr	GET_INCFILESIZE
	move.l	(sp)+,d3
	movem.l	(sp)+,d1/d2/d7/a0/a2
	
	move.l	d1,d4
	sub.l	d0,d4

* Modify the following indexes.
	move.l	linkentrysize-4(a2),d0
	move.l	d0,d5
	addi.l	#maxlinkfiles*linkentrysize,d0
	lea	linkentrysize-4(a2),a2
	move.w	d7,d6
.addloop:
	tst.l	(a2)
	beq.s	.end_addloop
	add.l	d4,(a2)
	lea	linkentrysize(a2),a2
	dbra	d7,.addloop
.end_addloop:
	cmp.w	d6,d7
	beq	.no_move
* Move the following filedata.
	move.l	-linkentrysize(a2),d3
	sub.l	d5,d3
	sub.l	d4,d3
	movem.l	d1-d3/a0,-(sp)
	Fseek	linkfilehandle,d0
	movem.l	(sp)+,d1-d3/a0

	movem.l	d1-d3/a0,-(sp)
	move.l	d3,d0
	bsr	malloc
	movem.l	(sp)+,d1-d3/a0
	move.l	d0,.mallocadr
	bmi	.error

	movem.l	d1-d3/a0,-(sp)
	move.l	.mallocadr(pc),a0
	Fread	linkfilehandle,(a0),d3
	movem.l	(sp)+,d1-d3/a0
	tst.l	d0
	bmi	.error

* Save the file.	
	movem.l	d1/d3/a0,-(sp)
	Fseek	linkfilehandle,d2
	movem.l	(sp),d1/d3/a0
	Fwrite	linkfilehandle,(a0),d1
	movem.l	(sp)+,d1/d3/a0
* Write back the following filedata.
	move.l	.mallocadr(pc),a0
	Fwrite	linkfilehandle,(a0),d3

	move.l	.mallocadr(pc),d0
	bsr	mfree

	moveq	#linkreplaced,d0
	rts

* The replaced was the last in the archive, so the data needn't be moved.
.no_move:
* Save the file.	
	movem.l	d1/d3/a0,-(sp)
	Fseek	linkfilehandle,d2
	movem.l	(sp),d1/d3/a0
	Fwrite	linkfilehandle,(a0),d1
	movem.l	(sp)+,d1/d3/a0

	moveq	#linkreplaced,d0
	rts

.error:	moveq	#-1,d0
	rts

.mallocadr:
	DS.L	1

CLOSE_LINKFILE:
	Fseek	linkfilehandle,#0
	Fwrite	linkfilehandle,dir_tbl,#maxlinkfiles*linkentrysize
	Fclose	linkfilehandle
	clr.l	lastlinkfileindex
	rts

* INPUT: a0: address of link-index
* OUTPUT: d0.l: filesize
GET_INCFILESIZE:
	cmpa.l	#dir_tbl,a0
	bne.s	.not_first
	move.l	linkentrysize-4(a0),d0
	rts
.not_first:
	move.l	linkentrysize-4(a0),d0
	sub.l	-4(a0),d0
	rts

******** GLOBAL DATA ********

	DATA

linkfileopen:
	DC.W	0
lastlinkfileindex:
	DC.L	0

******** GLOBAL RESERVES ********

	BSS

	EVEN
dir_tbl:
	DS.B	maxlinkfiles*linkentrysize
dataname_txt:
	DS.B	128
linkfilehandle:
	DS.W	1
