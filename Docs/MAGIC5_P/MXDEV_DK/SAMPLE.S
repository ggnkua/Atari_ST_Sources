;
;
; MagiC Device Driver Development Kit
; ===================================
;
; Assembler-Modul
;
; (C) Andreas Kromke, 1994
;
;

     SUPER

     XDEF _drvr
     XREF	drvr
     XREF kernel

	INCLUDE "mgx_dfs.inc"
	INCLUDE "errno.inc"

     TEXT


**********************************************************************
*
* Dies ist der GerÑtetreiber, der vom Kernel aufgerufen wird. Die
* Funktionen schreiben ihre Argumente auf den Stack und rufen
* die entsprechenden Funktionen von "drvr" auf, die als "cdecl"
* definiert sind.
*

_drvr:
 DC.L	_sample_open
 DC.L	_sample_close
 DC.L	_sample_read
 DC.L	_sample_write
 DC.L	_sample_stat
 DC.L	_sample_seek
 DC.L	_sample_datime
 DC.L	_sample_ioctl
 DC.L	_sample_delete
 DC.L	_sample_getc
 DC.L	_sample_getline
 DC.L	_sample_putc


**********************************************************************
*
* long _sample_open( a0 = MX_DOSFD *f )
*

_sample_open:
 move.l	a0,-(sp)
 move.l	drvr+ddev_open,a0
 jsr		(a0)
 addq.l	#4,sp
 rts


**********************************************************************
*
* long _sample_close( a0 = MX_DOSFD *f )
*

_sample_close:
 move.l	a0,-(sp)
 move.l	drvr+ddev_close,a0
 jsr		(a0)
 addq.l	#4,sp
 rts


**********************************************************************
*
* long _sample_read( a0 = MX_DOSFD *f, a1 = char *buf,
*					d0 = LONG count )
*

_sample_read:
 move.l	d0,-(sp)
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.l	drvr+ddev_read,a0
 jsr		(a0)
 lea		12(sp),sp
 rts


**********************************************************************
*
* long _sample_write( a0 = MX_DOSFD *f, a1 = char *buf,
*					d0 = LONG count )
*

_sample_write:
 move.l	d0,-(sp)
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.l	drvr+ddev_write,a0
 jsr		(a0)
 lea		12(sp),sp
 rts


**********************************************************************
*
* long _sample_stat( a0 = MX_DOSFD *f, a1 = LONG *unselect,
*				 d0 = WORD rwflag, d1 = LONG apcode );
*

_sample_stat:
 move.l	d1,-(sp)
 move.w	d0,-(sp)
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.l	drvr+ddev_stat,a0
 jsr		(a0)
 lea		14(sp),sp
 rts


**********************************************************************
*
* long _sample_seek( a0 = MX_DOSFD *f, d0 = LONG where,
*					d1 = WORD mode )
*

_sample_seek:
 move.w	d1,-(sp)
 move.l	d0,-(sp)
 move.l	a0,-(sp)
 move.l	drvr+ddev_seek,a0
 jsr		(a0)
 lea		10(sp),sp
 rts


**********************************************************************
*
* LONG _sample_datime( a0 = MX_DOSFD *f, a1 = WORD d[2],
*					d0 = WORD setflag )
*

_sample_datime:
 move.w	d0,-(sp)
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.l	drvr+ddev_datime,a0
 jsr		(a0)
 lea		10(sp),sp
 rts


**********************************************************************
*
* LONG _sample_ioctl(a0 = MX_DOSFD *f, d0 = WORD cmd,
*					a1 = void *buf)
*

_sample_ioctl:
 move.l   a1,-(sp)                 ; buf
 move.w   d0,-(sp)                 ; cmd
 move.l   a0,-(sp)                 ; MX_DOSFD
 move.l	drvr+ddev_ioctl,a0
 jsr      (a0)
 lea      10(sp),sp
 rts


**********************************************************************
*
* LONG _sample_delete( a1 = DIR *dir )
*

_sample_delete:
 move.l	a1,-(sp)
 move.l	drvr+ddev_delete,a0
 jsr		(a0)
 addq.l	#4,sp
 rts


**********************************************************************
*
* LONG _sample_getc( a0 = MX_DOSFD *f, d0 = WORD mode )
*
* mode & 0x0001:    cooked
* mode & 0x0002:    echo mode
*
* RÅckgabe: ist i.a. ein Langwort bei CON, sonst ein Byte
*           0x0000FF1A bei EOF
*

_sample_getc:
 move.w   d0,-(sp)                 ; mode
 move.l   a0,-(sp)                 ; MX_DOSFD
 move.l	drvr+ddev_getc,a0
 jsr      (a0)
 addq.l   #6,sp
 rts


**********************************************************************
*
* LONG _sample_getline( a0 = MX_DOSFD *f, a1 = char *buf,
*					d1 = LONG size, d0 = WORD mode )
*
* mode & 0x0001:    cooked
* mode & 0x0002:    echo mode
*
* RÅckgabe: Anzahl gelesener Bytes oder Fehlercode
*

_sample_getline:
 move.w   d0,-(sp)                 ; mode
 move.l   d1,-(sp)                 ; size
 move.l   a1,-(sp)                 ; buf
 move.l   a0,-(sp)                 ; MX_DOSFD
 move.l	drvr+ddev_getline,a0
 jsr      (a0)
 lea      14(sp),sp
 rts


**********************************************************************
*
* LONG _sample_putc( a0 = MX_DOSFD *f, d0 = WORD mode,
*					d1 = LONG value )
*
* mode & 0x0001:    cooked
*
* RÅckgabe: Anzahl geschriebener Bytes, 4 bei einem Terminal
*

_sample_putc:
 move.l   d1,-(sp)                 ; val
 move.w   d0,-(sp)                 ; mode
 move.l   a0,-(sp)                 ; MX_DOSFD
 move.l	drvr+ddev_putc,a0
 jsr      (a0)
 lea      10(sp),sp
 rts


	END
