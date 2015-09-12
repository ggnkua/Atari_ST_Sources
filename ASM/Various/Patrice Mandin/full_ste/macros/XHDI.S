; -------------	XHDI fonctions

XHGetVersion	MACRO
	SUPER	#0
	move.l	d0,xhdi_pile
	clr	-(sp)
	jsr	([xhdi_base.l])
	addq.l	#2,sp
	move.l	d0,xhdi_retour
	SUPER	xhdi_pile
	move.l	xhdi_retour,d0
	ENDM

XHInqTarget	MACRO	major,minor,blocksize,device_flags,product_name
	SUPER	#0
	move.l	d0,xhdi_pile
	move.l	\5,-(sp)
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move	\2,-(sp)
	move	\1,-(sp)
	move	#1,-(sp)
	jsr	([xhdi_base.l])
	lea	18(sp),sp
	move.l	d0,xhdi_retour
	SUPER	xhdi_pile
	move.l	xhdi_retour,d0
	ENDM

XHReserve	MACRO	major,minor,do_reserve,key
	SUPER	#0
	move.l	d0,xhdi_pile
	move	\4,-(sp)
	move	\3,-(sp)
	move	\2,-(sp)
	move	\1,-(sp)
	move	#2,-(sp)
	jsr	([xhdi_base.l])
	lea	10(sp),sp
	move.l	d0,xhdi_retour
	SUPER	xhdi_pile
	move.l	xhdi_retour,d0
	ENDM

XHLock	MACRO	major,minor,do_lock,key
	SUPER	#0
	move.l	d0,xhdi_pile
	move	\4,-(sp)
	move	\3,-(sp)
	move	\2,-(sp)
	move	\1,-(sp)
	move	#3,-(sp)
	jsr	([xhdi_base.l])
	lea	10(sp),sp
	move.l	d0,xhdi_retour
	SUPER	xhdi_pile
	move.l	xhdi_retour,d0
	ENDM

XHStop	MACRO	major,minor,do_stop,key
	SUPER	#0
	move.l	d0,xhdi_pile
	move	\4,-(sp)
	move	\3,-(sp)
	move	\2,-(sp)
	move	\1,-(sp)
	move	#4,-(sp)
	jsr	([xhdi_base.l])
	lea	10(sp),sp
	move.l	d0,xhdi_retour
	SUPER	xhdi_pile
	move.l	xhdi_retour,d0
	ENDM

XHEject	MACRO	major,minor,do_eject,key
	SUPER	#0
	move.l	d0,xhdi_pile
	move	\4,-(sp)
	move	\3,-(sp)
	move	\2,-(sp)
	move	\1,-(sp)
	move	#5,-(sp)
	jsr	([xhdi_base.l])
	lea	10(sp),sp
	move.l	d0,xhdi_retour
	SUPER	xhdi_pile
	move.l	xhdi_retour,d0
	ENDM

XHDrvMap	MACRO
	SUPER	#0
	move.l	d0,xhdi_pile
	clr	-(sp)
	move	#6,-(sp)
	jsr	([xhdi_base.l])
	addq.l	#4,sp
	move.l	d0,xhdi_retour
	SUPER	xhdi_pile
	move.l	xhdi_retour,d0
	ENDM

XHInqDev	MACRO	bios_device,major,minor,start_sector,bpb
	SUPER	#0
	move.l	d0,xhdi_pile
	move.l	\5,-(sp)
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#7,-(sp)
	jsr	([xhdi_base.l])
	lea	18(sp),sp
	move.l	d0,xhdi_retour
	SUPER	xhdi_pile
	move.l	xhdi_retour,d0
	ENDM

XHInqDriver	MACRO	bios_device,name,version,company,ahdi_version,maxIPL
	SUPER	#0
	move.l	d0,xhdi_pile
	move.l	\6,-(sp)
	move.l	\5,-(sp)
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#8,-(sp)
	jsr	([xhdi_base.l])
	lea	24(sp),sp
	move.l	d0,xhdi_retour
	SUPER	xhdi_pile
	move.l	xhdi_retour,d0
	ENDM

XHNewCookie	MACRO	newcookie
	SUPER	#0
	move.l	d0,xhdi_pile
	move.l	\1,-(sp)
	move	#9,-(sp)
	jsr	([xhdi_base.l])
	lea	6(sp),sp
	move.l	d0,xhdi_retour
	SUPER	xhdi_pile
	move.l	xhdi_retour,d0
	ENDM	

XHReadWrite	MACRO	major,minor,rwflag,recno,count,buf
	SUPER	#0
	move.l	d0,xhdi_pile
	move.l	\6,-(sp)
	move	\5,-(sp)
	move.l	\4,-(sp)
	move	\3,-(sp)
	move	\2,-(sp)
	move	\1,-(sp)
	move	#10,-(sp)
	jsr	([xhdi_base.l])
	lea	18(sp),sp
	move.l	d0,xhdi_retour
	SUPER	xhdi_pile
	move.l	xhdi_retour,d0
	ENDM

XHInqTarget2	MACRO	major,minor,blocksize,device_flags,product_name,stringlen
	SUPER	#0
	move.l	d0,xhdi_pile
	move	\6,-(sp)
	move.l	\5,-(sp)
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move	\2,-(sp)
	move	\1,-(sp)
	move	#11,-(sp)
	jsr	([xhdi_base.l])
	lea	20(sp),sp
	move.l	d0,xhdi_retour
	SUPER	xhdi_pile
	move.l	xhdi_retour,d0
	ENDM

XHInqDev2	MACRO	bios_device,major,*minor,start_sector,bpb,blocks,partid
	SUPER	#0
	move.l	d0,xhdi_pile
	move.l	\7,-(sp)
	move.l	\6,-(sp)
	move.l	\5,-(sp)
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#12,-(sp)
	jsr	([xhdi_base.l])
	lea	28(sp),sp
	move.l	d0,xhdi_retour
	SUPER	xhdi_pile
	move.l	xhdi_retour,d0
	ENDM

XHDriverSpecial	MACRO	key1,key2,subopcode,data
	SUPER	#0
	move.l	d0,xhdi_pile
	move.l	\4,-(sp)
	move	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move	#13,-(sp)
	jsr	([xhdi_base.l])
	lea	16(sp),sp
	move.l	d0,xhdi_retour
	SUPER	xhdi_pile
	move.l	xhdi_retour,d0
	ENDM

XHGetCapacity	MACRO	major,minor,blocks,blocksize
	SUPER	#0
	move.l	d0,xhdi_pile
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move	\2,-(sp)
	move	\1,-(sp)
	move	#14,-(sp)
	jsr	([xhdi_base.l])
	lea	14(sp),sp
	move.l	d0,xhdi_retour
	SUPER	xhdi_pile
	move.l	xhdi_retour,d0
	ENDM

XHMediumChanged	MACRO	major,minor
	SUPER	#0
	move.l	d0,xhdi_pile
	move	\2,-(sp)
	move	\1,-(sp)
	move	#15,-(sp)
	jsr	([xhdi_base.l])
	addq.l	#6,-(sp)
	move.l	d0,xhdi_retour
	SUPER	xhdi_pile
	move.l	xhdi_retour,d0
	ENDM

XHMiNTInfo	MACRO	opcode,data
	SUPER	#0
	move.l	d0,xhdi_pile
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#16,-(sp)
	jsr	([xhdi_base.l])
	addq.l	#8,sp
	move.l	d0,xhdi_retour
	SUPER	xhdi_pile
	move.l	xhdi_retour,d0
	ENDM

XHDOSLimits	MACRO	which,limit
	SUPER	#0
	move.l	d0,xhdi_pile
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#17,-(sp)
	jsr	([xhdi_base.l])
	addq.l	8,sp
	move.l	d0,xhdi_retour
	SUPER	xhdi_pile
	move.l	xhdi_retour,d0
	ENDM

XHLastAccess	MACRO	major,minor,ms
	SUPER	#0
	move.l	d0,xhdi_pile
	move.l	\3,-(sp)
	move	\2,-(sp)
	move	\1,-(sp)
	move	#18,-(sp)
	jsr	([xhdi_base.l])
	lea	10(sp),sp
	move.l	d0,xhdi_retour
	SUPER	xhdi_pile
	move.l	xhdi_retour,d0
	ENDM

XHReaccess	MACRO	major,minor
	SUPER	#0
	move.l	d0,xhdi_pile
	move	\2,-(sp)
	move	\1,-(sp)
	move	#19,-(sp)
	jsr	([xhdi_base.l])
	addq.l	#6,sp
	move.l	d0,xhdi_retour
	SUPER	xhdi_pile
	move.l	xhdi_retour,d0
	ENDM

	BSS

xhdi_base	ds.l	1
xhdi_retour	ds.l	1
xhdi_pile	ds.l	1