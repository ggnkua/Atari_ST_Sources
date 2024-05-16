; IO-Routinen fr Disk/HD/WP

	TEXT
	
; Fopen fname  (ret: D0.w handle)
Fopen	MACRO
	clr	-(sp)
	pea	\1
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
;	error_w
	ENDM

; Fcreate fname  (ret: d0.w handle)
Fcreate	MACRO
	clr	-(sp)
	pea	\1
	move.w	#$3c,-(sp)
	trap	#1
	addq.l	#8,sp
;	error_w
	ENDM
	
; Fread handle,dest,len  (ret: D0.l Tats„chliche L„nge)
Fread	MACRO
	pea	\2
	move.l	\3,-(sp)
	move.w	\1,-(sp)
	move	#$3f,-(sp)
	trap	#1
	lea	$c(sp),sp
;	error_l
	ENDM

; Fwrite handle,source,len  (ret: d0.l Tats„chliche Anzahl geschriebener Bytes)
Fwrite	MACRO
	pea	\2
	move.l	\3,-(sp)
	move.w	\1,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	lea	$c(sp),sp
;	error_l
	ENDM
	
; Fclose handle
Fclose	MACRO
	move.w	\1,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
;	error_w
	ENDM
	
; Fseek handle,pos
Fseek	MACRO
	clr	-(sp)
	move	\1,-(sp)
	move.l	\2,-(sp)
	move	#$42,-(sp)
	trap	#1
	lea	$a(sp),sp
;	error_l
	ENDM
	
; Frelseek handle,relpos
Frelseek MACRO
	move.w	#1,-(sp)
	move	\1,-(sp)
	move.l	\2,-(sp)
	move	#$42,-(sp)
	trap	#1
	lea	$a(sp),sp
;	error_l
	ENDM

; Fdelete fname^
Fdelete	MACRO
	pea	\1
	move.w	#$41,-(sp)
	trap	#1
	addq.l	#6,sp
;	error_w
	ENDM

; Frename oldfname^,newfname^
Frename	MACRO
	pea	\2
	pea	\1
	clr	-(sp)
	move	#$56,-(sp)
	trap	#1
	lea	$c(sp),sp
;	error_w
	ENDM

; Fsfirst fspec^,attribs
Fsfirst	MACRO
	move.w	\2,-(sp)
	pea	\1
	move.w	#$4e,-(sp)
	trap	#1
	addq.l	#8,sp
	ENDM

; Fsnext
Fsnext	MACRO
	move.w	#$4f,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM

; Fgetdta  (ret: d0.l  Zeiger auf aktuelle DTA)
Fgetdta	MACRO
	move.w	#$2f,-(sp)
	trap	#1
	addq.l	#2,sp
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
;	error_w
	ENDM

; _LOAD fname^,dest,len  (ret: d0.l Tats„chliche L„nge, neg.l:Fehler)
_LOAD	MACRO
.l0\@:	tst.b	disk_in_use
	bne.s	.l0\@
	st	disk_in_use
	movem.l	d0-a6,-(sp)
	lea	\1,a0
	lea	\2,a1
	move.l	\3,d0
	bsr	load
;	move.l	a1,a0
;	bsr	decrunch_ice
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
	
; -> d0.l  L„nge
;    a0.l  Fname^
;    a1.l  Dest
; <- d0.l  Tats„chliche L„nge oder Fehler (negativ LONG!)
load:	move.l	d0,d6
	Fopen	(a0)
	move.w	d0,d7
	ext.l	d7
	bmi.s	.e
	Fread	d7,(a1),d6
	move.l	d0,d6
	bmi.s	.e
	Fclose	d7
	ext.l	d0
	bmi.s	.e
	move.l	d6,d0	
.e:	rts

; -> d0.l  L„nge
;    a0.l  Fname^
;    a1.l  Dest
; <- d0.l  Tats„chliche L„nge oder Fehler (negativ LONG!)
save:	move.l	d0,d6
	Fcreate	(a0)
	move.w	d0,d7
	ext.l	d7
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
	
disk_in_use:	dc.b	0
		even