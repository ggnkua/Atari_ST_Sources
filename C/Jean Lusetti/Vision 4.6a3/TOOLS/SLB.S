	EXPORT	Slbopen
	EXPORT	Slbclose

/*****************************************************************
*
* Funktion 0x16 (22)
*
* LONG Slbopen(
*			a0 = char *name,
*			a1 = char *path,
*			d0 = LONG min_ver,
*			SLB_HANDLE *sl,
*			SLB_EXEC *fn,
*			d1 = LONG param
*			);
*
*****************************************************************/

	MODULE Slbopen
 pea		(a2)
 move.l	8+4(sp),-(sp)		; fn
 move.l	4+8(sp),-(sp)		; sl
 move.l	d0,-(sp)			; min_ver
 move.l	a1,-(sp)			; path
 move.l	a0,-(sp)			; name
 move.w	#$16,-(sp)
 trap	#1				; gemdos Slbopen
 lea		22(sp),sp
 move.l	(a7)+,a2
 rts
	ENDMOD


/*****************************************************************
*
* Funktion 0x17 (23)
*
* LONG Slbclose( a0 = SLB_HANDLE *sl );
*
*****************************************************************/

	MODULE Slbclose
 pea		(a2)
 move.l	a0,-(sp)			; sl
 move.w	#$17,-(sp)
 trap	#1				; gemdos Slbclose
 addq.l	#6,sp
 move.l	(a7)+,a2
 rts
	ENDMOD

