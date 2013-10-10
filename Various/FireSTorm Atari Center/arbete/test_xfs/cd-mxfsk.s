/*
**
** Dies ist der Assembler-Teil des CD-XFS fuer MagiX,
** der den Zugriff auf die Kernel-Funktionen durchfÅhrt.
** Entwickelt mit PASM.
**
** (C) Andreas Kromke 1997
**
**
*/

     INCLUDE "MGX_XFS.INC"


/*
*
* Wir importieren den Zeiger auf den MagiX-Kernel,
* der bei der Installation des XFS ermittelt wurde.
*
* Weiterhin brauchen wir den Zeiger auf den DFS-Kernel
* fÅr die Funktionen conv_8_3() und match_8_3().
*
*/

     XREF kernel			; MagiX-Kernel
     XREF	dfskernel
 

/*
*
* Dies sind die Kernelfunktionen, die hier als
* cdecl ausgefÅhrt sind, um einen beliebigen
* Compiler benutzen zu kînnen.
*
*/

	XDEF	kernel__sprintf
     XDEF	kernel_int_malloc
     XDEF	kernel_int_mfree
     XDEF	kernel_diskchange
     XDEF	kernel_proc_info

	XDEF	kernel_conv_8_3
	XDEF	kernel_match_8_3


**********************************************************************
*
* void cdecl kernel__sprintf( char *dst, char *src, LONG *data )
*

kernel__sprintf:
 move.l   a2,-(sp)
 move.l	16(sp),-(sp)			; data
 move.l	16(sp),-(sp)			; src
 move.l	16(sp),-(sp)			; dst
 move.l	kernel,a2
 move.l	mxk__sprintf(a2),a2
 jsr      (a2)
 adda.w	#12,sp
 move.l	(sp)+,a2
 rts


**********************************************************************
*
* void cdecl *kernel_int_malloc( void )
*

kernel_int_malloc:
 move.l   a2,-(sp)			; PureC braucht das Register!
 move.l	kernel,a2
 move.l	mxk_int_malloc(a2),a2
 jsr      (a2)
 move.l	(sp)+,a2
;move.l	d0,a0			; nicht cdecl: Zeiger in a0 zurÅckgeben!
 rts


**********************************************************************
*
* void cdecl kernel_int_mfree( void *block )
*

kernel_int_mfree:
 move.l   a2,-(sp)
 move.l	8(sp),a0
 move.l	kernel,a2
 move.l	mxk_int_mfree(a2),a2
 jsr      (a2)
 move.l	(sp)+,a2
 rts


**********************************************************************
*
* LONG cdecl kernel_diskchange( WORD drv )
*

kernel_diskchange:
 move.l   a2,-(sp)
 move.w	8(sp),d0
 move.l	kernel,a2
 move.l	mxk_diskchange(a2),a2
 jsr      (a2)
 move.l	(sp)+,a2
 rts


**********************************************************************
*
* LONG cdecl kernel_proc_info( WORD code, PD *pd )
*

kernel_proc_info:
 move.l   a2,-(sp)
 move.l	10(sp),a0
 move.w	8(sp),d0
 move.l	kernel,a2
 move.l	mxk_ker_proc_info(a2),a2
 jsr      (a2)
 move.l	(sp)+,a2
 rts


**********************************************************************
*
* void kernel_conv_8_3( char *from, char to[11] )
*

kernel_conv_8_3:
 move.l   a2,-(sp)
 move.l	8(sp),a0
 move.l	12(sp),a1
 move.l	dfskernel,a2
 move.l	dfsk_conv_8_3(a2),a2
 jsr      (a2)
 move.l	(sp)+,a2
 rts


**********************************************************************
*
* WORD kernel_match_8_3( char *patt, char *fname );
*

kernel_match_8_3:
 move.l   a2,-(sp)
 move.l	8(sp),a0
 move.l	12(sp),a1
 move.l	dfskernel,a2
 move.l	dfsk_match_8_3(a2),a2
 jsr      (a2)
 move.l	(sp)+,a2
 rts

     END
