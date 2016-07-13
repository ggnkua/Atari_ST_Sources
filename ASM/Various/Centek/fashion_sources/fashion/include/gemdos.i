********************************************************************
***** Toutes les fonctions gemdos resume de facon plus lisible *****
********************************************************************
*** Definition de la DTA et des flags du GEMDOS ***
GDF_READONLY	equ	0
GDF_HIDDEN	equ	1
GDF_SYSTEM	equ	2
GDF_VOLUME	equ	3
GDF_DIR		equ	4
GDF_ARCHIVE	equ	5
	rsreset
dta_reserved	rs.b	21
dta_attrb	rs.b	1
dta_time	rs.w	1
dta_date	rs.w	1
dta_lenght	rs.l	1
dta_name	rs.b	14
sizeof_dta	rs.w	1
	text
tst_rts		macro
	tst.l	d0
	bge.s	*+4
	rts
	endm

	XREF	tst_gemdos_error
tst_gemdos	macro
	tst.l	d0
	bge.s	*+8
	jsr	tst_gemdos_error
	endm
cauxis	macro
	move.w	#$12,-(sp)
	trap	#1
	addq.l	#2,sp
	tst_gemdos
	endm

cauxos	macro
	move.w	#$13,-(sp)
	trap	#1
	addq.l	#2,sp
	tst_gemdos
	endm

cauxout	macro	; ch
	move.w	\1,-(sp)
	move.w	#$4,-(sp)
	trap	#1
	addq.l	#4,sp
	tst_gemdos
	endm

cconin	macro
	move.w	#$1,-(sp)
	trap	#1
	addq.l	#2,sp
	tst_gemdos
	endm

cconis	macro
	move.w	#$b,-(sp)
	trap	#1
	addq.l	#2,sp
	tst_gemdos
	endm

cconos	macro
	move.w	#$10,-(sp)
	trap	#1
	addq.l	#2,sp
	tst_gemdos
	endm

conout	macro	; ch
	move.w	\1,-(sp)
	move.w	#2,-(sp)
	trap	#1
	addq.l	#4,sp
	tst_gemdos
	endm

cconrs	macro	; str
	move.l	\1,-(sp)
	move.w	#$a,-(sp)
	trap	#1
	addq.l	#6,sp
	tst_gemdos
	endm

cconws	macro	; str
	move.l	\1,-(sp)
	move.w	#$9,-(sp)
	trap	#1
	addq.l	#6,sp
	tst_gemdos
	endm

cnecin	macro
	move.w	#8,-(sp)
	trap	#1
	addq.l	#2,sp
	tst_gemdos
	endm

cprnos	macro
	move.w	#$11,-(sp)
	trap	#1
	addq.l	#2,sp
	tst_gemdos
	endm

cprnout	macro	; ch
	move.w	\1,-(sp)
	move.w	#$5,-(sp)
	trap	#1
	addq.l	#4,sp
	tst_gemdos
	endm

crawcin	macro
	move.w	#$07,-(sp)
	trap	#1
	addq.l	#2,sp
	tst_gemdos
	endm

crawio	macro	; ch
	move.w	\1,-(sp)
	move.w	#$6,-(sp)
	trap	#1
	addq.l	#4,sp
	tst_gemdos
	endm

dclosedir	macro	; dirhandle
	move.l	\1,-(sp)
	move.w	#$12b,-(sp)
	trap	#1
	addq.l	#6,sp
	tst_gemdos
	endm

dcntl	macro	; arg,name,cmd
	move.l	\1,-(sp)
	pea		\2
	move.w	cmd,-(sp)
	move.w	#$130,-(sp)
	trap	#1
	lea		12(sp),sp
	tst_gemdos
	endm

dcreat	macro	; path
	pea		\1
	move.w	#$39,-(sp)
	trap	#1
	addq.l	#6,sp
	tst_gemdos
	endm

ddelete		macro	; path
	pea		\1
	move.w	#$3a,-(sp)
	trap	#1
	addq.l	#4,sp
	tst_gemdos
	endm

dfree		macro	; drive,info
	move.w	\1,-(sp)
	pea		\2
	move.w	#$36,-(sp)
	trap	#1
	addq.l	#8,sp
	tst_gemdos
	endm

Dgetcwd		macro	; path,size,drv
	pea		\1
	move.w	\2,-(sp)
	move.w	\3,-(sp)
	move.w	#$13b,-(sp)
	trap	#1
	add.l	#10,sp
	tst_gemdos
	endm

Dgetdrv	macro
	move.w	#$19,-(sp)
	trap	#1
	addq.l	#2,sp
	tst_gemdos
	endm

Dgetpath	macro	; drive,buf
	move.w	\1,-(sp)
	pea		\2
	move.w	#$47,-(sp)
	trap	#1
	addq.l	#8,sp
	tst_gemdos
	endm

dlock		macro	; drv,move
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.w	#$135,-(sp)
	trap	#1
	addq.l	#6,sp
	tst_gemdos
	endm

dopendir	macro	; flag,name
	move.w	\1,-(sp)
	pea		\2
	move.w	#$128,-(sp)
	trap	#1
	addq.l	#8,sp
	tst_gemdos
	endm

dpathconf	macro	; mode,name
	move.w	\1,-(sp)
	pea		\2
	move.w	#$124,-(sp)
	trap	#1
	addq.l	#8,sp
	tst_gemdos
	endm

dreaddir	macro	; buf,dirhandle,lenght
	pea		\1
	move.l	\2,-(sp)
	move.w	\3,-(sp)
	move.w	#$129,-(sp)
	trap	#1
	lea	12(sp),sp
	tst_gemdos
	endm

drewinddir	macro	; handle
	move.l	\1,-(sp)
	move.w	#$12a,-(sp)
	trap	#1
	addq.l	#6,sp
	tst_gemdos
	endm

Dsetdrv		macro	; drive
	move.w	\1,-(sp)
	move.w	#$0e,-(sp)
	trap	#1
	addq.l	#4,sp
	tst_gemdos
	endm

Dsetpath	macro	; path
	move.l	\1,-(sp)
	move.w	#$3b,-(sp)
	trap	#1
	addq.l	#6,sp
	tst_gemdos
	endm

Fattrib		macro	; attr,flag,fname
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	pea	\3
	move.w	#$43,-(sp)
	trap	#1
	lea	10(sp),sp
	tst_gemdos
	endm

Fchmod		macro	; mode,name
	move.w	\1,-(sp)
	pea	\2
	move.w	#$123,-(sp)
	trap	#1
	addq.l	#8,sp
	tst_gemdos
	endm

Fchown		macro	; gid,uid,name
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	pea	\3
	move.w	#$131,-(sp)
	trap	#1
	lea	10(sp),sp
	tst_gemdos
	endm

Fclose		macro	; handle
	move.w	\1,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	tst_gemdos
	endm

Fcntl		macro	; cmd,arg,handle
	move.w	\1,-(sp)
	move.l	\2,-(sp)
	move.w	\3,-(sp)
	move.w	#$260,-(sp)
	trap	#1
	lea	10(sp),sp
	tst_gemdos
	endm

Fcreate		macro	; attr,fname
	move.w	\1,-(sp)
	move.l	\2,-(sp)
	move.w	#$3c,-(sp)
	trap	#1
	addq.l	#8,sp
	tst_gemdos
	endm

Fdatime	macro	; flag,handle,timeptr
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	pea		\3
	move.w	#$57,-(sp)
	trap	#1
	lea		10(sp),sp
	tst_gemdos
	endm

Fdelete	macro	; fname
	pea	\1
	move.w	#$41,-(sp)
	trap	#1
	addq.l	#6,sp
	tst_gemdos
	endm

Fdup	macro	; shandle
	move.w	\1,-(sp)
	move.w	#$45,-(sp)
	trap	#1
	addq.l	#4,sp
	tst_gemdos
	endm

Fforce	macro	; nhandle,shandle
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.w	#$46,-(sp)
	trap	#1
	addq.l	#6,sp
	tst_gemdos
	endm

Fgetchar	macro	; mode,handle
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.w	#$107,-(sp)
	trap	#1
	addq.l	#6,sp
	tst_gemdos
	endm

Fgetdta	macro
	move.w	#$2f,-(sp)
	trap	#1
	addq.l	#2,sp
	tst_gemdos
	endm

Finstat	macro	;  handle
		move.w	\1,-(sp)
		move.w	#$105,-(sp)
		trap	#1
		addq.l	#4,sp
		tst_gemdos
		endm

Flink	macro	; newname,oldname
		pea		\1
		pea		\2
		move.w	#$12d,-(sp)
		trap	#1
		lea		10(sp),sp
		tst_gemdos
		endm

Flock	macro	; lentght,start,mode,handle
		move.l	\1,-(sp)
		move.l	\2,-(sp)
		move.w	\3,-(sp)
		move.w	\4,-(sp)
		move.w	#$5c,-(sp)
		trap	#1
		lea		14(sp),sp
		tst_gemdos
		endm

Fmidipipe	macro	; out,in,pid
		move.w	\1,-(sp)
		move.w	\2,-(sp)
		move.w	\3,-(sp)
		move.w	#$126,-(sp)
		trap	#1
		addq.l	#8,sp
		tst_gemdos
		endm

Fopen	macro	; mode,fname
		move.w	\1,-(sp)
		move.l	\2,-(sp)
		move.w	#$3d,-(sp)
		trap	#1
		addq.l	#8,sp
		tst_gemdos
		endm

Foutstat	macro	; handle
		move.w	\1,-(sp)
		move.w	#$106,-(sp)
		trap	#1
		addq.l	#4,sp
		tst_gemdos
		endm

Fpipe	macro	; fhandle
		pea		\1
		move.w	#$100,-(sp)
		trap	#1
		addq.l	#6,sp
		tst_gemdos
		endm

Fputchar	macro	; mode,lchar,handle
		move.w	\1,-(sp)
		move.l	\2,-(sp)
		move.w	\3,-(sp)
		move.w	#$108,-(sp)
		trap	#1
		lea		10(sp),sp
		tst_gemdos
		endm

Fread		macro	; buf,lenght,handle
		move.l	\1,-(sp)
		move.l	\2,-(sp)
		move.w	\3,-(sp)
		move.w	#$3f,-(sp)
		trap	#1
		lea		12(sp),sp
		tst_gemdos
		endm

Freadlink	macro	; name,buf,bufsiz
		pea	\1
		pea	\2
		move.w	\3,-(sp)
		move.w	#$,-(sp)
		trap	#1
		lea	12(sp),sp
		tst_gemdos
		endm

Frename		macro	; newname,oldname
		pea	\1
		pea	\2
		move.w	#0,-(sp)
		move.w	#$86,-(sp)
		trap	#1
		lea		12(sp),sp
		tst_gemdos
		endm

SEEK_SET	equ	0
SEEK_CUR	equ	1
SEEK_END	equ	2
Fseek		macro	; mode,handle,offset
		move.w	\1,-(sp)
		move.w	\2,-(sp)
		move.l	\3,-(sp)
		move.w	#$42,-(sp)
		trap	#1
		lea	10(sp),sp
		tst_gemdos
		endm

Fselct		macro	; reserved,wfds,rfds,timeout
		move.l	\1,-(sp)
		pea		\2
		pea		\3
		move.w	\4,-(sp)
		move.w	#$11d,-(sp)
		trap	#1
		lea		16(sp),sp
		tst_gemdos
		endm

Fsetdta		macro	; ndta
		move.l	\1,-(sp)
		move.w	#$1a,-(sp)
		trap	#1
		addq.l	#6,sp
		tst_gemdos
		endm

Fsfirst		macro	; attribs,fspec
		move.w	\1,-(sp)
		move.l	\2,-(sp)
		move.w	#$4e,-(sp)
		trap	#1
		addq.l	#8,sp
		endm

Fsnext		macro
		move.w	#$4f,-(sp)
		trap	#1
		addq.l	#2,sp
		endm

Fsymlink	macro	; newname,oldname
		pea	\1
		pea	\2
		move.w	#$12e,-(sp)
		trap	#1
		lea		10(sp),sp
		tst_gemdos
		endm

Fwrite		macro	; buf,count,handle
		move.l	\1,-(sp)
		move.l	\2,-(sp)
		move.w	\3,-(sp)
		move.w	#$40,-(sp)
		trap	#1
		lea		12(sp),sp
		tst_gemdos
		endm

Fxattr		macro	; xattr,name,flag
		pea	\1
		pea	\2
		move.w	\3,-(sp)
		move.w	#$12c,-(sp)
		trap	#1
		lea	12(sp),sp
		tst_gemdos
		endm

maddalt		macro	; size,start
		move.l	\1,-(sp)
		pea	\2
		move.w	#$14,-(sp)
		trap	#1
		lea	10(sp),sp
		tst_gemdos
		endm

* La seule fonction GEMDOS a retourner 0 comme erreur
Malloc		macro	; amount
		move.l	\1,-(sp)
		move.w	#$48,-(sp)
		trap	#1
		addq.l	#6,sp
		tst.l	d0
		bne.s	.\@ok
		move.l	#-67,d0
		tst_gemdos
.\@ok
		endm

rtsMalloc	macro	; amount
		move.l	\1,-(sp)
		move.w	#$48,-(sp)
		trap	#1
		addq.l	#6,sp
		tst_gemdos
		tst.l	d0
		bge.s	*+4
		rts
		endm

Mfree		macro	; startadr
		move.l	\1,-(sp)
		move.w	#$49,-(sp)
		trap	#1
		addq.l	#6,sp
		tst_gemdos
		endm

mshrink		macro	; newsize,startadr
		move.l	\1,-(sp)
		move.l	\2,-(sp)
		clr.w	-(sp)
		move.w	#$4a,-(sp)
		trap	#1
		lea		12(sp),sp
		tst_gemdos
		endm

mxalloc		macro	; mode,maount
		move.w	\1,-(sp)
		move.l	\2,-(sp)
		move.w	#$44,-(sp)
		trap	#1
		addq.l	#8,sp
		tst_gemdos
		endm

;pause		macro
;		move.w	#$121,-(sp)
;		trap	#1
;		addq.l	#2,sp
;		tst_gemdos
;		endm

pdomain		macro	; domain
		move.w	#$119,-(sp)
		trap	#1
		addq.l	#4,sp
		tst_gemdos
		endm

pexec		macro	; envstr,cmdline,fname,word
		move.l	\1,-(sp)
		move.l	\2,-(sp)
		move.l	\3,-(sp)
		move.w	\4,-(sp)
		move.w	#$4b,-(sp)
		trap	#1
		lea		16(sp),sp
		tst_gemdos
		endm

pfork	macro
		move.w	#$11b,-(sp)
		trap	#1
		addq.l	#2,sp
		tst_gemdos
		endm

pgetegit	macro
		move.w	#$139,-(sp)
		trap	#1
		addq.l	#2,sp
		tst_gemdos
		endm

pgeteuid	macro
		move.w	#$138,-(sp)
		trap	#1
		addq.l	#2,sp
		tst_gemdos
		endm

pgetgit	macro
		move.w	#$10f,-(sp)
		trap	#1
		addq.l	#2,sp
		tst_gemdos
		endm

pgetpgrp	macro
		move.w	#$10d,-(sp)
		trap	#1
		addq.l	#2,sp
		tst_gemdos
		endm

pgetpid	macro
		move.w	#$10b,-(sp)
		trap	#1
		addq.l	#2,sp
		tst_gemdos
		endm

pgetppid	macro
		move.w	#$10c,-(sp)
		trap	#1
		addq.l	#2,sp
		tst_gemdos
		endm

pgetuid		macro
		move.w	#$10f,-(sp)
		trap	#1
		addq.l	#2,sp
		tst_gemdos
		endm

pkill		macro	; sig,pid
		move.w	\1,-(sp)
		move.w	\2,-(sp)
		move.w	#$111,-(sp)
		trap	#1
		addq.l	#6,sp
		tst_gemdos
		endm

pmsg		macro	; msgptr,mboxid,mode
		pea		\1
		move.l	\2,-(sp)
		move.w	\3,-(sp)
		move.w	#$125,-(sp)
		trap	#1
		lea		12(sp),sp
		tst_gemdos
		endm

pnice		macro	; delta
		move.w	\1,-(sp)
		move.w	#$10a,-(sp)
		trap	#1
		addq.l	#4,sp
		tst_gemdos
		endm

prenice		macro	; delta,pid
		move.w	\1,-(sp)
		move.w	\2,-(sp)
		move.w	#$127,-(sp)
		trap	#1
		addq.l	#6,sp
		tst_gemdos
		endm

prusage		macro	; rusg
		pea		\1
		move.w	#$11e,-(sp)
		trap	#1
		addq.l	#6,sp
		tst_gemdos
		endm

psemaphore	macro	; timeout,id,mode
		move.l	\1,-(sp)
		move.l	\2,-(sp)
		move.w	\3,-(sp)
		move.w	#$134,-(sp)
		trap	#1
		lea		12(sp),sp
		tst_gemdos
		endm

psetgit		macro	; git
		move.w	\1,-(sp)
		move.w	#$115,-(sp)
		trap	#1
		addq.l	#4,sp
		tst_gemdos
		endm

psetlimit	macro	; value,limit
		move.w	#$11f,-(sp)
		trap	#1
		addq.l	#8,sp
		tst_gemdos
		endm

psetpgrp	macro	; newgrp,pid
		move.w	\1,-(sp)
		move.w	\2,-(sp)
		move.w	#$10e,-(sp)
		trap	#1
		addq.l	#6,sp
		tst_gemdos
		endm

psetuid		macro	; uid
		move.w	\1,-(sp)
		move.w	#$110,-(sp)
		trap	#1
		addq.l	#4,sp
		tst_gemdos
		endm

psigaction	macro	; sig,act,oact
		move.w	\1,-(sp)
		pea	\2
		pea	\3
		move.w	#$,-(sp)
		trap	#1
		lea	12(sp),sp
		tst_gemdos
		endm

psigblock	macro	; mask
		move.l	\1,-(sp)
		move.w	#$116,-(sp)
		trap	#1
		addq.l	#6,sp
		tst_gemdos
		endm

psignal		macro	; handler,sig
		pea		\1
		move.w	\2,-(sp)
		move.w	#$112,-(sp)
		trap	#1
		addq.l	#8,sp
		tst_gemdos
		endm

psigpause	macro	; mask
		move.l	\1,-(sp)
		move.w	#$136,-(sp)
		trap	#1
		addq.l	#6,sp
		tst_gemdos
		endm

psigpending	macro
		move.w	#$123,-(sp)
		trap	#1
		addq.l	#2,sp
		tst_gemdos
		endm

psigreturn	macro
		move.w	#$11a,-(sp)
		trap	#1
		addq.l	#2,sp
		tst_gemdos
		endm

psigsetmask	macro	; mask
		move.l	\1,-(sp)
		move.w	#$117,-(sp)
		trap	#1
		addq.l	#6,sp
		tst_gemdos
		endm

pterm	macro	; retcode
		move.w	\1,-(sp)
		move.w	#$4c,-(sp)
		trap	#1
		addq.l	#4,sp
		tst_gemdos
		endm

ptermO		macro
		clr.w	-(sp)
		trap	#1
		endm

ptermres	macro	; retcode,keep
		move.w	\1,-(sp)
		move.l	\2,-(sp)
		move.w	#$31,-(sp)
		trap	#1
		addq.l	#,sp
		tst_gemdos
		endm

pumask		macro	; mode
		move.w	\1,-(sp)
		move.w	#$133,-(sp)
		trap	#1
		addq.l	#4,sp
		tst_gemdos
		endm

pusrval		macro
		move.w	#$118,-(sp)
		trap	#1
		addq.l	#2,sp
		tst_gemdos
		endm

pvfork		macro
		move.w	#$113,-(sp)
		trap	#1
		addq.l	#2,sp
		tst_gemdos
		endm

pwait		macro
		move.w	#$109,-(sp)
		trap	#1
		addq.l	#2,sp
		tst_gemdos
		endm

pwait3	macro	; rusage,flag
		pea	\1
		move.w	\2,-(sp)
		move.w	#$11c,-(sp)
		trap	#1
		addq.l	#8,sp
		tst_gemdos
		endm

pwaitpid	macro	; rusage,flag
		pea	\1
		move.w	\2,-(sp)
		move.w	#$13a,-(sp)
		trap	#1
		addq.l	#8,sp
		tst_gemdos
		endm

salert		macro	; str
		pea	\1
		move.w	#$13c,-(sp)
		trap	#1
		addq.l	#6,sp
		tst_gemdos
		endm

Superv		macro	; stack_address
		pea	\1
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		tst_gemdos
		endm

sversion	macro
		move.w	#$30,-(sp)
		trap	#1
		addq.l	#2,sp
		tst_gemdos
		endm

syield		macro
		move.w	#$ff,-(sp)
		trap	#1
		addq.l	#2,sp
		tst_gemdos
		endm

sysconf		macro	; inq
		move.w	#$122,-(sp)
		trap	#1
		addq.l	#4,sp
		tst_gemdos
		endm

talarm		macro	; time
		move.w	#$120,-(sp)
		trap	#1
		addq.l	#6,sp
		tst_gemdos
		endm

tgetdate	macro
		move.w	#$2a,-(sp)
		trap	#1
		addq.l	#2,sp
		tst_gemdos
		endm

tgettime	macro
		move.w	#$2c,-(sp)
		trap	#1
		addq.l	#2,sp
		tst_gemdos
		endm

tsetdate	macro	; date
		move.w	\1,-(sp)
		move.w	#$2b,-(sp)
		trap	#1
		addq.l	#4,sp
		tst_gemdos
		endm

tsettime	macro	; time
		move.w	\1,-(sp)
		move.w	#$2d,-(sp)
		trap	#1
		addq.l	#4,sp
		tst_gemdos
		endm
