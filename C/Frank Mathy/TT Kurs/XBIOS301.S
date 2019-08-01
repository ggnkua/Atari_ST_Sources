.EXPORT		Bconmap,DMAread,DMAwrite,NVMaccess

.TEXT

; long Bconmap(int devno);
Bconmap:
	pea		(a2)
	move.w	d0,-(sp)
	move.w	#$2c,-(sp)
	trap	#14
	addq.w	#4,sp
	move.l	(sp)+,a2
	rts


; long DMAread(long sector,int count,void *buffer,int devno);
;					D0		D1			A0			D2
DMAread:
	pea		(a2)
	move.w	d2,-(sp)
	pea		(a0)
	move.w	d1,-(sp)
	move.l	d0,-(sp)
	move.w	#$2a,-(sp)
	trap	#14
	lea		14(sp),sp
	move.l	(sp)+,a2
	rts

; long DMAwrite(long sector,int count,void *buffer,int devno);
;					D0		D1			A0			D2
DMAwrite:
	pea		(a2)
	move.w	d2,-(sp)
	pea		(a0)
	move.w	d1,-(sp)
	move.l	d0,-(sp)
	move.w	#$2b,-(sp)
	trap	#14
	lea		14(sp),sp
	move.l	(sp)+,a2
	rts

; int NVMaccess(int op,int start,int count, char *buffer)
;				D0		D1			D2		A0
NVMaccess:
	pea		(a2)
	pea		(a0)
	move.w	d2,-(sp)
	move.w	d1,-(sp)
	move.w	d0,-(sp)
	move.w	#$2e,-(sp)
	trap	#14
	lea		12(sp),sp
	move.l	(sp)+,a2
	rts
