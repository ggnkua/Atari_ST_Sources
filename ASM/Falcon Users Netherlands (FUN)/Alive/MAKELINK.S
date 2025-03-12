******** ASM OPTIONS ********

	COMMENT	HEAD=%111
	OPT	P=68000
	OPT	D-

	OUTPUT	D:\CODING\DEMOS1\MAKELINK.TTP

	bra	START

******** LIBRARIES ********

createmode:	EQU	1
	INCLUDE	INCLOAD.I
	TEXT

******** GLOBAL EQUATES ********

* memory management
minfilebufsize:	=	100000			* Minimum size of append buffer.
maxincfilesize:	=	300000			* Maximum size of 1 incfile.

* Switches that can be specified in the commandline.
refreshflag:	=	0

* Return codes.
succescode:	=	0
generalerror:	=	-1
openfail:	=	-2
readfail:	=	-3
writefail:	=	-4
memfail:	=	-5

******** MAIN CODE ********

START:	move.l	4(sp),a5
	lea	$80(a5),a5
	moveq	#0,d0
	move.b	(a5)+,d0
	beq	.generalerror
	subq.w	#1,d0
	move.w	d0,arglenght
	move.l	a5,argstartadr

.parsearguments:
	movea.l	a5,a1
	lea	argoffset_tbl(pc),a6
	lea	2(a6),a0
	moveq	#0,d1
	moveq	#0,d2
.scanloop:
.scanspaceloop:
	cmpi.b	#" ",(a1)+
	bne.s	.end_scanspaceloop
	addq.w	#1,d1
	dbra	d0,.scanspaceloop
	bra.s	.end_scanloop
.end_scanspaceloop:
	subq	#1,a1
	move.w	d1,(a0)+
.scancharloop:
	cmpi.b	#" ",(a1)+
	beq.s	.end_scancharloop
	addq.w	#1,d1
	dbra	d0,.scancharloop
	bra.s	.end_scanloop
.end_scancharloop:
	addq.w	#1,d1
	subq.w	#1,d0
	addq.w	#1,d2
	bpl.s	.scanloop
.end_scanloop:	
	move.w	d1,(a0)
	move.w	d2,(a6)+

	movea.l	a5,a0
	adda.w	(a6),a0
	moveq	#0,d7
.parseloop:
	cmpi.b	#"-",(a0)
	bne.s	.endparse
	addq.w	#1,firstfilemask
	move.b	1(a0),d0
	andi.b	#%11011111,d0
	cmpi.b	#"R",d0
	addq	#3,a0
	bne.s	.parseloop
	bset	#refreshflag,d7
.endparse:
	move.l	a0,argadr
	move.l	d7,flags

.shrinkmem:
	move.l	4(sp),a5			* Mshrink
	move.l	$0c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	addi.l	#$1000,d0
	move.l	a5,d1
	add.l	d0,d1
	andi.b	#%11111110,d1			* even address
	move.l	d1,sp

	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	d0,-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp

	pea	fileinfo_buf(pc)		* Fsetdta
	move.w	#$1a,-(sp)
	trap	#1
	addq.w	#6,sp

	pea	title_txt(pc)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp

	pea	srcdirname_txt(pc)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp

	move.l	argadr(pc),-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp

	pea	return_txt(pc)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp

	move.w	#0,-(sp)			* Dgetpath
	pea	curpath_txt(pc)
	move.w	#$47,-(sp)
	trap	#1
	addq.w	#8,sp
	tst.l	d0
	bmi	.generalerror

	lea	dataname_txt(pc),a0
	lea	curpath_txt(pc),a1
.nmlop:	move.b	(a1)+,(a0)+
	bne.s	.nmlop
	subq	#1,a0
	move.b	#"\",(a0)+
	move.b	#"D",(a0)+
	move.b	#"A",(a0)+
	move.b	#"T",(a0)+
	move.b	#"A",(a0)+
	clr.b	(a0)

	pea	dstfilename_txt(pc)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp

	pea	dataname_txt(pc)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp

	pea	return_txt(pc)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp

	move.l	flags(pc),d0
	btst	#refreshflag,d0
	bne.s	.refresh

.update:
	bsr	UPDATE_LINKFILE
	bra	.handleerror

.refresh:
	pea	refreshmode_txt(pc)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp

	bsr	REFRESH_LINKFILE
	bra	.handleerror

.handleerror:
	tst.l	d0
	bpl.s	.end
	cmpi.w	#openfail,d0
	beq.s	.openfail
	cmpi.w	#readfail,d0
	beq.s	.readfail
	cmpi.w	#writefail,d0
	beq.s	.writefail
	cmpi.w	#memfail,d0
	beq.s	.memfail

.generalerror:
	pea	error_txt(pc)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp
	bra.s	.end
.openfail:
	pea	openfail_txt(pc)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp
	bra.s	.end
.readfail:
	pea	readfail_txt(pc)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp
	bra.s	.end
.writefail:
	pea	writefail_txt(pc)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp
	bra.s	.end
.memfail:
	pea	memfail_txt(pc)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp

.end:	pea	presskey_txt(pc)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp

	move.w	#7,-(sp)
	move.w	#1,-(sp)
	trap	#1
	addq	#4,sp

	clr.w	-(sp)
	trap	#1

******** SUBROUTINES ********

REFRESH_LINKFILE:
	lea	dataname_txt(pc),a1
	bsr	CREATE_LINKFILE
	tst.l	d0
	bmi	.error

* Reserve maximum of memory here for optimal filebuffering.
	moveq	#-1,d0
	bsr	malloc
	subi.l	#$8000,d0
	bmi	.memfail
	cmpi.l	#minfilebufsize,d0
	blt	.memfail
	move.l	d0,.filebufsize
	bsr	malloc
	move.l	d0,.filebufadr
	beq	.memfail

	move.w	#1,.currentfilemask

.filemaskloop:
	movea.l	argstartadr(pc),a1
	lea	argoffset_tbl,a0
	move.w	.currentfilemask(pc),d0
	cmp.w	(a0)+,d0
	bhi	.end_filemaskloop
	move.w	d0,d1
	addq.w	#1,d1
	move.w	d1,.currentfilemask
	add.w	d0,d0
	movem.w	(a0,d0.w),d0/d7
	adda.l	d7,a1
	sub.l	d0,d7
	subq.w	#1,d7

.spaceloop:
	cmpi.b	#" ",-(a1)
	dbne	d7,.spaceloop
	addq	#1,a1
	clr.b	(a1)
.floop:	cmpi.b	#"\",-(a1)
	dbeq	d7,.floop
	tst.w	d7
	bpl.s	.newpath
	move.l	a1,.searchmaskadr
	bra	.endsetpath

.newpath:
	lea	1(a1),a6
	lea	newpath_txt(pc),a0
	adda.w	d7,a0
	subq.w	#1,d7
.wloop:	move.b	-(a1),-(a0)
	dbra	d7,.wloop

	move.l	a6,.searchmaskadr

.setdrive:
	lea	newpath_txt(pc),a0
	cmpi.b	#":",1(a0)
	bne.s	.endsetdrive
	move.b	(a0),d0
	andi.w	#%11011111,d0
	subi.w	#"A",d0
	bmi	.openfail

	pea	2(a0)

	move.w	d0,-(sp)			* Dsetdrive
	move.w	#$e,-(sp)
	trap	#1
	addq.w	#4,sp
	
	move.l	(sp)+,a0
.endsetdrive:

.setpath:
	pea	(a0)				* Dsetpath
	move.w	#$3b,-(sp)
	trap	#1
	addq.w	#6,sp
	tst.l	d0
	bmi	.openfail
.endsetpath:

	move.w	#0,-(sp)			* Fsfirst
	move.l	.searchmaskadr(pc),-(sp)
	move.w	#$4e,-(sp)
	trap	#1
	addq	#8,sp
	tst.l	d0
	bmi	.openfail

.loop:	tst.l	d0
	bmi	.end

	move.l	.accusize(pc),d0
	add.l	fileinfo_buf+26(pc),d0
	cmp.l	.filebufsize(pc),d0
	blt.s	.nowrite
	bra.s	.write
.nowrite:
	move.l	d0,.accusize
	bra.s	.load
	
.write:	sub.l	.filebufsize(pc),d0
	movea.l	.filebufadr(pc),a0
	bsr	WRITE_LINKBUFFER
	move.l	fileinfo_buf+26(pc),.accusize
	clr.l	.oldaccusize

.load:	movea.l	.filebufadr(pc),a1
	adda.l	.oldaccusize(pc),a1
	move.l	fileinfo_buf+26(pc),d0
	lea	fileinfo_buf+30(pc),a0
	bsr	load

	pea	fileinfo_buf+30(pc)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp

	pea	return_txt(pc)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp

	lea	fileinfo_buf+30(pc),a0
	move.l	fileinfo_buf+26(pc),d0
	cmp.l	.filebufsize(pc),d0
	bge.s	.memfail
	bsr	STORE_INCFILENAME
	tst.l	d0
	bmi.s	.writefail

	move.l	.accusize(pc),.oldaccusize

	move.w	#$4f,-(sp)			* Fsnext
	trap	#1
	addq	#2,sp

	bra	.loop
.end:
	bra	.filemaskloop
.end_filemaskloop:
	
	tst.l	.oldaccusize
	beq.s	.written
	move.l	.accusize(pc),d0
	move.l	.filebufadr(pc),a0
	bsr	WRITE_LINKBUFFER
.written:
	bsr	CLOSE_LINKFILE
	moveq	#0,d0
	rts
.error:	moveq	#-1,d0
	rts
.openfail:
	moveq	#openfail,d0
	rts
.readfail:
	moveq	#readfail,d0
	rts
.writefail:
	moveq	#writefail,d0
	rts
.memfail:
	moveq	#memfail,d0
	rts

.searchmaskadr:
	DS.L	1
.filebufsize:
	DS.L	1
.filebufadr:
	DS.L	1
.currentfilemask:
	DS.W	1
.accusize:
	DC.L	0
.oldaccusize:
	DC.L	0

UPDATE_LINKFILE:
	lea	dataname_txt(pc),a1
	bsr	OPEN_LINKFILE
	tst.l	d0
	bmi	.openfail

	move.l	#maxincfilesize,d0
	bsr	malloc
	move.l	d0,.filebufadr
	beq	.memfail

.filemaskloop:
	movea.l	argstartadr(pc),a1
	lea	argoffset_tbl,a0
	move.w	.currentfilemask(pc),d0
	cmp.w	(a0)+,d0
	bhi	.end_filemaskloop
	move.w	d0,d1
	addq.w	#1,d1
	move.w	d1,.currentfilemask
	add.w	d0,d0
	movem.w	(a0,d0.w),d0/d7
	adda.l	d0,a1
	sub.l	d0,d7
	adda.l	d7,a1
	subq.w	#1,d7

.spaceloop:
	cmpi.b	#" ",-(a1)
	dbne	d7,.spaceloop
	addq	#1,a1
	clr.b	(a1)
.floop:	cmpi.b	#"\",-(a1)
	dbeq	d7,.floop
	tst.w	d7
	bmi.s	.pathset

	lea	1(a1),a6
	lea	newpath_txt(pc),a0
	adda.w	d7,a0
	subq.w	#1,d7
.wloop:	move.b	-(a1),-(a0)
	dbra	d7,.wloop

	pea	(a6)				* Save address of filename.

	cmpi.b	#":",1(a0)
	bne.s	.nodrive
	move.b	(a0),d0
	andi.w	#%11011111,d0
	subi.w	#"A",d0
	bpl.s	.on
	addq	#4,sp
	bra	.openfail

.on:	pea	2(a0)

	move.w	d0,-(sp)			* Dsetdrive
	move.w	#$e,-(sp)
	trap	#1
	addq.w	#4,sp
	
	move.l	(sp)+,a0
.nodrive:

	pea	(a0)				* Dsetpath
	move.w	#$3b,-(sp)
	trap	#1
	addq.w	#6,sp

	move.l	(sp)+,a1			* Restore filename.

	tst.l	d0
	bmi	.error
.pathset:

	move.w	#0,-(sp)			* Fsfirst
	pea	(a1)
	move.w	#$4e,-(sp)
	trap	#1
	addq.w	#8,sp
	tst.l	d0
	bmi	.openfail

.replaceloop:
	tst.l	d0
	bmi	.end_replaceloop

.loadfile:
	movea.l	.filebufadr(pc),a1
	lea	fileinfo_buf+30(pc),a0
	move.l	fileinfo_buf+26(pc),d0
	bsr	load

.printfilename:
	pea	fileinfo_buf+30(pc)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp

.replace:
	movea.l	.filebufadr(pc),a0
	lea	fileinfo_buf+30(pc),a1
	move.l	fileinfo_buf+26(pc),d0
	bsr	REPLACE_INCFILE

	tst.l	d0
	bmi.s	.writefail
	cmpi.w	#linkreplaced,d0
	bne.s	.newlink
	pea	.replaced_txt(pc)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp
	bra.s	.endreplace
.newlink:
	cmpi.w	#newlinksaved,d0
	bne.s	.error
	pea	.appended_txt(pc)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp
.endreplace:

	move.w	#$4f,-(sp)			* Fsnext
	trap	#1
	addq	#2,sp

	bra	.replaceloop
.end_replaceloop:

	bra	.filemaskloop
.end_filemaskloop:

.close:	bsr	CLOSE_LINKFILE

.end	moveq	#0,d0
	rts
.error:	moveq	#-1,d0	
	rts
.openfail:
	moveq	#openfail,d0
	rts
.readfail:
	moveq	#readfail,d0
	rts
.writefail:
	moveq	#writefail,d0
	rts
.memfail:
	moveq	#memfail,d0
	rts

.filebufadr:
	DS.L	1
.currentfilemask:
	DS.W	1
.replaced_txt:
	DC.B	" REPLACED",$a,$d,0
.appended_txt
	DC.B	" APPENDED",$a,$d,0
	EVEN

******** GLOBAL DATA ********

	DATA

title_txt:
	DC.B	" //-/\-/\-/\=/\=/\=/\=/\=/\=/\-/\-/\-\\ ",$a,$d
	DC.B	"<< LINKFILEMAKER BY EARX/FUN (C) 1999 >>",$a,$d
	DC.B	" \\-\/-\/-\/=\/=\/=\/=\/=\/=\/-\/-\/-// ",$a,$d
	DC.B	$a,$d
	DC.B	"Specify a filename. Wildcards accepted. ",$a,$d
	DC.B	"Use '-r' for fast refresh of linkfile.",$a,$d
	DC.B	$a,$d,0
srcdirname_txt:
	DC.B	"SOURCE FILE(MASK): ",0
dstfilename_txt:
	DC.B	"DESTINATION FILE : ",0
refreshmode_txt:
	DC.B	"REFRESHING LINKFILE!",$a,$d,0
error_txt:
	DC.B	"An error has occurred!",$a,$d,0
openfail_txt:
	DC.B	"File couldn't be opened!",$a,$d,0
readfail_txt:
	DC.B	"File couldn't be read from!",$a,$d,0
writefail_txt:
	DC.B	"File couldn't be written to!",$a,$d,0
memfail_txt:
	DC.B	"Not enough memory could be allocated!",$a,$d,0
presskey_txt:
	DC.B	"Press any key to exit",$a,$d,0
return_txt:
	DC.B	$a,$d,0
	EVEN

******** GLOBAL RESERVES ********

	BSS

argoffset_tbl:
	DS.W	128
firstfilemask:
	DS.W	1
argadr:	DS.L	1
argstartadr:
	DS.L	1
flags:	DS.L	1
arglenght:
	DS.W	1
curpath_txt
	DS.B	256
newpath_txt
	DS.B	256
fileinfo_buf:
	DS.L	12