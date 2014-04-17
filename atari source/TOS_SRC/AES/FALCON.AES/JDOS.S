*************************************************************************
*			Revision Control System
* =======================================================================
*  $Revision: 2.2 $	$Source: /u2/MRS/osrevisions/aes/jdos.s,v $
* =======================================================================
*  $Author: mui $	$Date: 89/04/26 18:28:39 $	$Locker: kbad $
* =======================================================================
*  $Log:	jdos.s,v $
* Revision 2.2  89/04/26  18:28:39  mui
* TT
* 
* Revision 2.1  89/02/22  05:30:41  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.3  88/07/01  16:22:43  mui
* move dos_space C code to deskinf.c
* 
* Revision 1.2  88/07/01 15:50:13  mui
* comment out dos_space
*
* Revision 1.1  88/06/02  12:35:45  lozben
* Initial revision
* 
*************************************************************************
*	.title	'GEMDOS Bindings for AES/Desktop'
*	Bug fixed 2/5/87
*	Added global definition	11/30/87	D.Mui
*	Add do_cdir		1/28/88		D.Mui
*	Use MAC to assemble	6/29/90		D.Mui
* assemble with MAS 900801 kbad

*----------------
*
*  Edit History
*
*  2-Feb-1987 lmd	Converted from stupid C code.  Original size
*			was $57E text, $2 data.
*


*----------------
*
*  Exports
*

*	.globl	_trap		; replace old trap() call
	.globl	_isdrive
	.globl	_pgmld
*	.globl	_bellout
	.globl	_dos_sfirst
	.globl	_dos_snext
	.globl	_dos_open
	.globl	_dos_read
	.globl	_dos_write
	.globl	_dos_lseek
	.globl	_dos_gdir
	.globl	_dos_mkdir
	.globl	_dos_set
	.globl	_dos_label
*	.globl	_dos_space
	.globl	_dos_rename
	.globl	_dos_alloc
	.globl	_dos_avail
	.globl	_chrout
	.globl	_rawcon
	.globl	_prt_chr
	.globl	_dos_gdrv
	.globl	_dos_sdta
	.globl	_dos_close
	.globl	_dos_chdir
	.globl	_dos_sdrv
	.globl	_dos_chmod
	.globl	_dos_delete
	.globl	_dos_rmdir
	.globl	_dos_create
	.globl	_dos_free
	.globl	_DOS_AX
	.globl	_DOS_ERR
	.globl	_do_cdir

*----------------
*
*  Imports
*
	.comm _DOS_AX,2
	.comm _DOS_ERR,2


*	.NLIST
*----------------
*
*  Error Codes
*
E_OK	= 0
ERROR	= -1
EDRVNR	= -2
EUNCMD	= -3
E_CRC	= -4
EBADRQ	= -5
E_SEEK	= -6
EMEDIA	= -7
ESECNF	= -8
EPAPER	= -9
EWRITF	= -10
EREADF	= -11
EGENRL	= -12
EWRPRO	= -13
E_CHNG	= -14
EUNDEV	= -15
EBADSF	= -16
EOTHER	= -17
EINVFN	= -32
EFILNF	= -33
EPTHNF	= -34
ENHNDL	= -35
EACCDN	= -36
EIHNDL	= -37
EIMBA	= -40
EDRIVE	= -46
ENMFIL	= -49
ERANGE	= -64
EINTRN	= -65
EPLFMT	= -66
EGSBF	= -67

E_BADFUNC	= 1
E_FILENOTFND	= 2
E_PATHNOTFND	= 3
E_NOHANDLES	= 4
E_NOACCESS	= 5
E_BADHANDLE	= 6
E_MEMBLKERR	= 7
E_NOMEMORY	= 8
E_BADMEMBLK	= 9
E_BADENVIR	= 10
E_BADFORMAT	= 11
E_BADACCESS	= 12
E_BADDATA	= 13
E_BADDRIVE	= 15
E_NODELDIR	= 16
E_NOTDEVICE	= 17
E_NOFILES	= 18


*----------------
*
*  Dos function numbers
*
X_TABOUT	= $02
X_PRTOUT	= $05
X_RAWCON	= $06
X_SETDRV	= $0E
X_GETDRV	= $19
X_SETDTA	= $1A
X_GETFREE	= $36
X_MKDIR		= $39
X_RMDIR		= $3A
X_CHDIR		= $3B
X_CREAT		= $3C
X_OPEN		= $3D
X_CLOSE		= $3E
X_READ		= $3F
X_WRITE		= $40
X_UNLINK	= $41
X_LSEEK		= $42
X_CHMOD		= $43
X_GETDIR	= $47
X_MALLOC	= $48
X_MFREE		= $49
X_SETBLOCK	= $4A
X_EXEC		= $4B
X_SFIRST	= $4E
X_SNEXT		= $4F
X_RENAME	= $56
X_GSDTOF	= $57
*	.LIST


*----------------
*
*  I know what this does, but I don't
*  know why it's supposed to do it.
*
_isdrive:
	bsr	_dos_gdrv		; get current drive number
	move.w	d0,-(sp)		; and make it the current
	bsr	_dos_sdrv		;    drive again...
	addq	#2,sp
	rts


nullstr: dc.b	0,0			; an empty string, for _pgmld()

*----------------
*
*  Local jump-to-trap-handler
*
jtrap:	jmp	_trap			; jump to _trap


*
*  WORD
*  pgmld(handle, pname, ldaddr)
*  	WORD	handle;
*  	BYTE	*pname;
*  	LONG	**ldaddr;
*  {
*  	LONG	length;
*  	LONG	*temp;
*  
*  	*ldaddr = trap(X_EXEC,3,pname,"",NULLPTR);
*  	if (!DOS_ERR)
*  	{			 /* code+data+bss lengths */
*  	  temp = *ldaddr;
*  	  length = temp[3] + temp[5] + temp[7] + 0x100;
*  	  trap(X_SETBLOCK,0, *ldaddr, length);
*  	  if (!DOS_ERR)
*  	    return(TRUE);
*  	  else
*  	    return(-1);
*  	}
*  	else
*  	  return(-1);
*  }
*
*		4       6       $a
*	.cargs .handle .pname.l .ldaddr.l
*
_pgmld:
	clr.l	-(sp)			; null env string (inherit parent's)
	pea	nullstr(pc)		; empty command tail
	move.l	6+8(sp),-(sp)		; &filename
	move.l	#$004b0003,-(sp)	; Pexec(3, ...): load, no-go
	bsr	jtrap
	add.w	#16,sp
	bne.b	pg_fal			; punt on load failure

	move.l	$a(sp),a0		; *ldaddr = &basepage
	move.l	d0,(a0)
	move.l	d0,a0			; a0 -> basepage

	move.l	#$100,d0		; compute size of program we loaded
	add.l	3*4(a0),d0
	add.l	5*4(a0),d0
	add.l	7*4(a0),d0

	move.l	d0,-(sp)		; = size to keep
	move.l	a0,-(sp)		; = address of block
	move.l	#$004a0000,-(sp)	; Mshrink(0, ...)
	bsr	jtrap
	add.w	#12,sp
	beq.b	TRUE			; return OK on shrink success

pg_fal:	moveq	#-1,d0			; return -1L
	rts


*----------------
*
*  Return 0 (FALSE)
*
FALSE:	moveq	#0,d0
	rts


*----------------
*
*  Return 1 (TRUE)
*
TRUE:	moveq	#1,d0
	rts


*----------------
*
*  Print a bell on the console (hard BIOS console)
*
*_bellout:
*	move.w	#7,-(sp)			; Bconout(CON, 7)
*	move.l	#$00030002,-(sp)
*	trap	#13
*	addq	#6,sp
*	rts


*
*  WORD
*  dos_sfirst(pspec, attr)
*  	LONG		pspec;
*  	WORD		attr;
*  {
*  	REG LONG		ret;
*  	ret = trap(X_SFIRST,pspec,attr);
*  	if (!ret)
*  	  return(TRUE);
*  	if ( ret == ENMFIL || ret == EFILNF )
*  	{
*  	  DOS_AX = E_NOFILES;
*  	  return(FALSE);
*  	}
*  	else
*  	  return(FALSE);
*  }
*
*		4	 8
*	 .cargs .pspec.l .attr.w	; ->name, =searchAttributes
*
_dos_sfirst:
	move.w	8(sp),-(sp)		; push attributes
	move.l	4+2(sp),-(sp)		; push &name
	move.w	#$4e,-(sp)		; push function#
	bsr	jtrap			; Fsfirst(...)
	addq	#8,sp

sfsn:	tst.w	d0			; if (d0 == 0) return TRUE;
	beq	TRUE

	cmp.w	#ENMFIL,d0		; if (d0 == ENMFIL ||
	beq.b	sf_1
	cmp.w	#EFILNF,d0		;     d0 == EFILNF)
	bne.b	sf_2
sf_1:	move.w	#E_NOFILES,_DOS_AX	;    DOS_AX = E_NOFILES;
sf_2:	bra	FALSE			; return FALSE


*
*  WORD
*  dos_snext()
*  {
*  	REG LONG		ret;
*  	ret = trap(X_SNEXT);
*  	if (!ret)
*  	  return(TRUE);
*  	if ( ret == ENMFIL || ret == EFILNF )
*  	{
*  	  DOS_AX = E_NOFILES;
*  	  return(FALSE);
*  	}
*  	else
*  	  return(FALSE);
*  }
*  
_dos_snext:
	move.w	#X_SNEXT,-(sp)		; Fsnext()
	bsr	jtrap
	addq	#2,sp
	bra	sfsn			; [common sfirst/snext return handler]


*  WORD
*  dos_open(pname, access)
*  	BYTE		*pname;
*  	WORD		access;
*  {
*  	LONG		ret;
*  
*  	ret = trap(X_OPEN,pname,access);
*  	if (ret == EFILNF)
*  	  DOS_AX = E_FILENOTFND;
*  	if (DOS_ERR)
*  	  return(FALSE);
*  	else
*  	  return((UWORD)ret);
*  }
*
*		4	 8
*	 .cargs .pname.l .access.w
*
_dos_open:
	move.w	8(sp),-(sp)
	move.l	4+2(sp),-(sp)
	move.w	#X_OPEN,-(sp)
	bsr	jtrap
	addq	#8,sp

	cmp.w	#EFILNF,d0
	bne.b	open_1
	move.w	#E_FILENOTFND,_DOS_AX

open_1:	tst.w	d1
	bne	FALSE
	rts


*
*  WORD
*  dos_read(handle, cnt, pbuffer)
*  	WORD		handle;
*  	UWORD		cnt;
*  	LONG		pbuffer;
*  {
*  	LONG		ret;
*  	ret = trap(X_READ,handle,(ULONG)cnt,pbuffer);
*  	return((UWORD)ret);
*  }
*  
*  WORD
*  dos_write(handle, cnt, pbuffer)
*  	WORD		handle;
*  	UWORD		cnt;
*  	LONG		pbuffer;
*  {
*  	LONG		ret;
*  	ret = trap(X_WRITE,handle,(ULONG)cnt,pbuffer);
*  	return( (UWORD)ret);
*  }
*
_dos_read:	moveq	#X_READ,d1
		bra.b	rw

_dos_write:	moveq	#X_WRITE,d1

*
*		4         6        8
*	.cargs	.handle.w .count.w .pbuffer.l
*
rw:
	move.l	8(sp),-(sp)		; pbuffer
	moveq	#0,d0
	move.w	6+4(sp),d0		; count
	move.l	d0,-(sp)
	move.w	4+8(sp),-(sp)		; handle
	move.w	d1,-(sp)		; X_READ or X_WRITE
	bsr	jtrap			; do trap
	add.w	#12,sp
	rts


*  
*  LONG
*  dos_lseek(handle, smode, sofst)
*  	WORD		handle;
*  	WORD		smode;
*  	LONG		sofst;
*  {
*  	return( trap(X_LSEEK,sofst, handle, smode) );
*  }
*
*		4       6       8
*	 .cargs .handle .smode .sofst.l
*
_dos_lseek:
	move.l	4(sp),-(sp)		; handle & smode
	move.l	4+8(sp),-(sp)		; softst
	move.w	#X_LSEEK,-(sp)
	bsr	jtrap
	add.w	#10,sp
	rts


*
*  WORD
*  dos_gdir(drive, pdrvpath)
*  	WORD		drive;
*  	LONG		pdrvpath;
*  {
*  	return(trap(X_GETDIR,pdrvpath,drive));
*  }
*
*		4        6
*	 .cargs .drive.w .pdrvpath.l
*
_dos_gdir:
	move.w	4(sp),-(sp)		; drive
	move.l	6+2(sp),-(sp)		; pdrvpath
	move.w	#X_GETDIR,-(sp)
	bsr	jtrap
	addq	#8,sp
	rts


*
*  WORD
*  dos_mkdir(path,attr)
*  	BYTE	*path;
*  	WORD	attr;
*  {
*  	LONG	ret;
*  
*  	ret = trap(X_MKDIR,path);
*  	if (ret == EACCDN)
*  	  DOS_AX = E_NOACCESS;
*  	return( !DOS_ERR );
*  }
*
*		4       8
*	 .cargs .path.l .attr
*
_dos_mkdir:
	move.l	4(sp),-(sp)		; path
	move.w	#X_MKDIR,-(sp)
	bsr	jtrap
	addq	#6,sp

	cmp.w	#EACCDN,d0
	bne.b	mkd_1
	move.w	#E_NOACCESS,_DOS_AX
mkd_1:	move.w	d1,d0			; return (!DOS_ERR)
	eor.w	#1,d0
	rts


*
*  WORD
*  dos_set(h,time,date)
*  	UWORD	h,time,date;
*  {
*  	UWORD	buf[2];
*  
*  	buf[0] = time;
*  	buf[1] = date;
*  	return( trap(X_GSDTOF,&buf[0],h,TRUE) );
*  }
*
*		4   6    8
*	 .cargs .h .time .date
*
_dos_set:
	move.w	#$0001,-(sp)		; TRUE
	move.w	4+2(sp),-(sp)		; h
	pea	6+4(sp)			; &time+date
	move.w	#X_GSDTOF,-(sp)
	bsr	jtrap
	add.w	#10,sp
	rts


*  
*  WORD
*  dos_label(drive,plabel)
*  	BYTE	drive;
*  	BYTE	*plabel;
*  {
*  	BYTE	buf[50];		/* 44 bytes used	*/
*  	BYTE	path[8];
*  	WORD	ret;
*  
*  	bfill(50,NULL,&buf[0]);
*  	trap(X_SETDTA,&buf[0]);
*  	path[0] = (drive + 'A') - 1;
*  	path[1] = ':';
*  	path[2] = '\\';
*  	path[3] = '*';
*  	path[4] = '.';
*  	path[5] = '*';
*  	path[6] = 0;
*  	ret = trap(X_SFIRST,path,0x08);
*  	if (!ret)
*  	{
*  	  strcpy(&buf[30],plabel);
*  	  return(TRUE);
*  	}
*  	else
*  	{
*  	  DOS_ERR = DOS_AX = TRUE;
*  	  return(FALSE);
*  	}
*  }
*
*		    8	    10
*	 .cargs #8, .drive .plabel
*
la_buf	=	-(44)
la_path	=	-(44+8)
_dos_label:
	link	a6,#la_path		; make room for args

	pea	la_buf(a6)		; Setdta #la_buf
	move.w	#X_SETDTA,-(sp)
	trap	#1
	addq	#6,sp

	lea	la_path(a6),a0
	move.b	8+1(a6),d0		; drive
	add.b	#$40,d0			; 'A' - 1
	move.b	d0,(a0)+
	lea	la_string(pc),a1
la_1:	move.b	(a1)+,(a0)+
	bne.b	la_1

	move.w	#$08,-(sp)
	pea	la_path(a6)
	move.w	#X_SFIRST,-(sp)
	bsr	jtrap
	addq	#8,sp

	tst.w	d0
	bne.b	la_err
	lea	la_buf+30(a6),a1
	move.l	10(a6),a0		; plabel
la_2:	move.b	(a1)+,(a0)+
	bne.b	la_2
	unlk	a6
	bra	TRUE

la_err:	moveq	#1,d0
	move.w	d0,_DOS_ERR
	move.w	d0,_DOS_AX
	unlk	a6
	bra	FALSE

la_string:	dc.b	':\*.*',0
		.EVEN



*
*   This conversion assumes no more than 65535 sectors on a media
*   (which is "good enough" given our current state of affairs)
*
*  
*  WORD
*  dos_space(drv,ptotal, pavail)
*  	WORD	drv;
*  	LONG	*ptotal, *pavail;
*  {
*  	LONG	buf[4];
*  	LONG	mult;
*  
*  	trap(X_GETFREE,buf,drv);	/* changed  0=A for gemdos	*/
*  	mult = buf[3] * buf[2];
*  	*ptotal = mult * buf[1];
*  	*pavail = mult * buf[0];
*  	return(TRUE);
*  }
*
*		   8      10        14
*	.cargs #8, .drv.w .ptotal.l .pavail.l
*
*sp_buf	=	-16
*_dos_space:
*	link	a6,#sp_buf
*	move.w	8(a6),-(sp)		; drv
*	pea	sp_buf(a6)
*	move.w	#X_GETFREE,-(sp)
*	trap	#1
*	addq	#8,sp
*
*	move.w	sp_buf+14(a6),d0	; d0 = buf[3] * buf[2]
*	mulu	sp_buf+10(a6),d0
*	move.w	d0,d1
*
*	movem.l	10(a6),a0-a1		; a0 = ptotal, a1 = pavail
*	mulu	4+sp_buf+2(a6),d0	; *ptotal = d0 * buf[1]
*	move.l	d0,(a0)
*	mulu	sp_buf+2(a6),d1		; *pavail = d0 * buf[0]
*	move.l	d1,(a1)
*
*	moveq	#1,d0			; return TRUE
*	unlk	a6
*	rts


*
*  WORD
*  dos_rename(p1,p2)
*  	BYTE	*p1;
*  	BYTE	*p2;
*  {
*  	return(trap(X_RENAME,0x0,p1,p2) );
*  }
*  
_dos_rename:
	move.l	(sp)+,retaddr
	move.l	#$00560000,-(sp)	; X_RENAME + $0000
	bsr	jtrap
	addq	#4,sp
	move.l	retaddr,a0
	jmp	(a0)


*  
*  LONG
*  dos_alloc(nbytes)
*  	LONG		nbytes;
*  {
*  	LONG		ret;
*  
*  	if (nbytes & 1)
*  	  nbytes += 1;			/* get on boundary	*/
*  	ret = trap(X_MALLOC,nbytes);
*  	if (ret == 0 )
*  	{
*  	  DOS_ERR = TRUE;
*  	  return(0);
*  	}
*  	if (ret & 0x1L )
*  	  ret += 1;
*  	return(ret);
*  }
*  
_dos_alloc:
	move.l	4(sp),d0		; nbytes
	btst	#0,d0
	beq.b	al_1
	addq.l	#1,d0

al_1:	move.l	d0,-(sp)
	move.w	#X_MALLOC,-(sp)
	trap	#1
	addq	#6,sp

	tst.l	d0
	bne.b	al_2
	move.w	#1,_DOS_ERR
	rts

al_2:	btst	#0,d0
	beq.b	al_3
	addq.l	#1,d0
al_3:	rts


*
*  LONG
*  dos_avail()
*  {
*  	return( trap( X_MALLOC, -1L) );
*  }
*
_dos_avail:
	moveq	#-1,d0
	move.l	d0,-(sp)
	move.w	#X_MALLOC,-(sp)
	trap	#1
	addq	#6,sp
	rts


*----------------
*
*  "Generic" calls
*  where we make a GEMDOS trap with the
*  arguments on the stack unchanged.
*
_chrout:	moveq	#X_TABOUT,d1
		bra.b	generic

_rawcon:	moveq	#X_RAWCON,d1
		bra.b	generic

_prt_chr:	moveq	#X_PRTOUT,d1
		bra.b	generic

_dos_gdrv:	moveq	#X_GETDRV,d1
		bra.b	generic

_dos_sdta:	moveq	#X_SETDTA,d1
		bra.b	generic

_dos_close:	moveq	#X_CLOSE,d1
		bra.b	generic

_dos_chdir:	moveq	#X_CHDIR,d1
		bra.b	generic

_dos_sdrv:	moveq	#X_SETDRV,d1
		bra.b	generic

_dos_chmod:	moveq	#X_CHMOD,d1
		bra.b	generic

_dos_delete:	moveq	#X_UNLINK,d1
		bra.b	generic

_dos_rmdir:	moveq	#X_RMDIR,d1
		bra.b	generic

_dos_create:	moveq	#X_CREAT,d1
		bra.b	generic

_dos_free:	moveq	#X_MFREE,d1

generic:
	move.l	(sp)+,retaddr		; save return address
	move.w	d1,-(sp)		; push trap
	bsr	jtrap			; trap to GEMDOS
	addq	#2,sp			; cleanup function#
	move.l	retaddr,a0		; load return address
	jmp	(a0)			; ... anvd return

	.BSS
retaddr:	ds.l	1		; saved return address
	.TEXT



*----------------
*
*  GEMDOS Trap binding
*
*    Returns:	EQ+D1=0, no "dos error"
*		NE+D1=1, "dos error" condition
*
_trap:
	move.l	(sp)+,tr_retsave	; save return address
	trap	#1			; do GEMDOS trap
	moveq	#0,d1			; assume no error
	move.w	d0,_DOS_AX		; save WORD return value
	tst.l	d0			; 2/5/87
	bge.b	tr_1			; >=0 means no error
	moveq	#1,d1			; we guessed wrong, set error flag
tr_1:	move.w	d1,_DOS_ERR		; copy error condition to global var.
	move.l	tr_retsave,a0		; return to caller
	jmp	(a0)


*	do_cdir( drive, path )
*	WORD	drive;
*	BYTE	*path;

_do_cdir:				
	move.w	4(sp),-(sp)		; change the drive first
	move.w	#X_SETDRV,-(sp)
	jsr 	jtrap
	move.l	10(sp),-(sp)		; change the directory
	move.w	#X_CHDIR,-(sp)
	jsr	jtrap
	add	#10,sp
	rts



    .BSS
tr_retsave: ds.l	1
