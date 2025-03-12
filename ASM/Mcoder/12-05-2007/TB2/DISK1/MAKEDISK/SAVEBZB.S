boot=$80000
;
disk=0
;
; ‚crit boot-secteur
;
;
;	- calcul checksum :
;
	LEA	BOOT,A0
	MOVE	#-$1234,D1
	MOVE	#255,D0
BC:	ADD	(A0)+,D1
	DBRA	D0,BC
	SUB	D1,BOOT+$1FE

	ILLEGAL

	pea	1.w
;	move	#1,-(sp)	;count
;	clr	-(sp)		;face 0
	pea	$10000
;	clr	-(sp)		;piste 0
;	move	#1,-(sp)	;secteur
	move	#disk,-(sp)
	clr.l	-(sp)
	pea	boot
	move	#9,-(sp)
	trap	#14
	lea	20(sp),sp
	tst.l	d0
	bmi	erreur

ok:	moveq	#0,d7
	illegal
erreur:
	moveq	#-1,d7
	illegal
