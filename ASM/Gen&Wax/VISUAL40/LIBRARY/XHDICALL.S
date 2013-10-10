;	Librairie accŠs XHDI
;	Pour le Visual Asssembler 4.0

*--------------------------------------------------------------------------*

XH_LOCATE_DRIVER:
	move.l #'XHDI',GWVA_APP_OBJ_SEARCH_IN_OUT
	SUPEXEC GWVA_APP_OBJ_SEARCH_ONE_COOKIE

	move.l GWVA_APP_OBJ_SEARCH_IN_OUT,a0
	cmp.l #0,a0
	beq.s .no_xhdi
	cmp.l #$27011992,([a0],-4)
	beq.s .ok

.no_xhdi:	clr.l XH_DRIVER_ROUTINE
	moveq #GWVA_ERROR_GENERIC,d7
	rts

.ok:	move.l (a0),XH_DRIVER_ROUTINE
	clr d7
	rts

*--------------------------------------------------------------------------*

	ifd LIB_XHDI_INFOPARTITION
XH_GET_INFO_ON_THIS_PARTITION:
	; Entr‚e : d0.w=partition (0=all disk,1=first ...) d1.w=major device
	; Sortie : d0.l=start sector d1.l=nb sector d2.l=type 'XXX'0 + d7=0 si OK

	move d1,XH_DEVICE_MAJOR
	clr XH_DEVICE_MINOR
	clr.l XH_PRODUCTNAME
	save.w d0
	SUPEXEC XH_INQ_TARGET		; pour la taille des blocks & device flags
	load.w d0
	tst XH_RETURN_CODE
	bne .erreur_read_debut

	clr.l d1			; num‚ro du secteur … lire

	save.l d0/d1
	MXALLOC #RAM_ST,XH_1BLOCK_SIZE
	move.l d0,XH_READWRITE_BUFFER
	load.l d0/d1
	tst.l XH_READWRITE_BUFFER
	ble .erreur_malloc

.continue_search:
	move.w #2,XH_READWRITE_RWFLAG	; read no change test
	move.l d1,XH_READWRITE_RECNO
	move.w #1,XH_READWRITE_COUNT
	save.l d0/d1
	SUPEXEC XH_READ_WRITE
	load.l d0/d1
	tst XH_RETURN_CODE
	bmi .erreur_lecture_mfree

	tst d0
	beq .info_on_all_disk

	move.l #$1C6,d2

.scan_all_of_4:
	btst #0,([XH_READWRITE_BUFFER],d2.l)
	beq .derniere_pas_trouve

	cmp.b #'X',([XH_READWRITE_BUFFER],d2.l,1)	; description courante
	bne .pas_une_xgm
	cmp.w #'GM',([XH_READWRITE_BUFFER],d2.l,1+1)
	bne .pas_une_xgm

	add.l ([XH_READWRITE_BUFFER],d2.l,1+3-(1+3+4+4)),d1
	add.l ([XH_READWRITE_BUFFER],d2.l,1+3+4-(1+3+4+4)),d1
	bra .continue_search

.pas_une_xgm:
	cmp #1,d0
	beq.s .trouve

	subq #1,d0
	add.l #1+3+4+4,d2
	cmp.l #$1C6+4*(1+3+4+4),d2
	bne.s .scan_all_of_4
	bra .derniere_pas_trouve	; pas d'XGM et toutes pass‚es

.trouve:	move.l ([XH_READWRITE_BUFFER],d2.l,1+3),d0	; start sec
	add.l d1,d0
	move.l ([XH_READWRITE_BUFFER],d2.l,1+3+4),d1	; nbr sec
	move.l ([XH_READWRITE_BUFFER],d2.l,1),d2	; id
	clr.b d2

.sortie_reussie:
	save.l d0-d2
	MFREE XH_READWRITE_BUFFER
	load.l d0-d2

	clr d7
	rts

.info_on_all_disk:
	clr.l d0
	move.l ([XH_READWRITE_BUFFER.l],$1c2),d1
	clr.l d2
	bra.s .sortie_reussie

.derniere_pas_trouve:
.erreur_lecture_mfree:
	MFREE XH_READWRITE_BUFFER

.erreur_read_debut:
.erreur_malloc:
	moveq #GWVA_ERROR_GENERIC,d7
	rts
	endc

*--------------------------------------------------------------------------*

	ifd LIB_XHDI_GETVERSION
XH_GET_VERSION:			; no parameter
	move.w #0,-(sp)		; XH_GetVersion
	jsr ([XH_DRIVER_ROUTINE])
	lea 2(sp),sp
	move d0,XH_RETURN_CODE
	rts
	endc

	ifd LIB_XHDI_INQTARGET
XH_INQ_TARGET:			; XH_DEVICE_MAJOR,XH_DEVICE_MINOR,XH_PRODUCTNAME
	move.l XH_PRODUCTNAME,-(sp)	; char *productname
	pea XH_DEVICE_FLAGS		; *device flags
	pea XH_1BLOCK_SIZE		; *block size
	move XH_DEVICE_MINOR,-(sp)	; minor
	move XH_DEVICE_MAJOR,-(sp)	; major
	move.w #1,-(sp)		; XInqTarget
	jsr ([XH_DRIVER_ROUTINE])
	lea 18(sp),sp
	move d0,XH_RETURN_CODE
	rts
	endc

	ifd LIB_XHDI_STOP
XH_STOP:				; XH_DEVICE_MAJOR,XH_DEVICE_MINOR,XH_DO_STOP,XH_DEVICE_KEY
	move XH_DEVICE_KEY,-(sp)	; key
	move XH_DO_STOP,-(sp)		; do stop
	move XH_DEVICE_MINOR,-(sp)	; minior
	move XH_DEVICE_MAJOR,-(sp)	; major
	move.w #4,-(sp)		; XHStop
	jsr ([XH_DRIVER_ROUTINE])
	lea 10(sp),sp
	move d0,XH_RETURN_CODE
	rts
	endc

	ifd LIB_XHDI_EJECT
XH_EJECT:				; XH_DEVICE_MAJOR,XH_DEVICE_MINOR,XH_DO_EJECT,XH_DEVICE_KEY
	move XH_DEVICE_KEY,-(sp)	; key
	move XH_DO_EJECT,-(sp)		; do stop
	move XH_DEVICE_MINOR,-(sp)	; minior
	move XH_DEVICE_MAJOR,-(sp)	; major
	move.w #5,-(sp)		; XHEject
	jsr ([XH_DRIVER_ROUTINE])
	lea 10(sp),sp
	move d0,XH_RETURN_CODE
	rts
	endc

	ifd LIB_XHDI_READWRITE
XH_READ_WRITE:			; XH_DEVICE_MAJOR,XH_DEVICE_MINOR,XH_READWRITE_RWFLAG,XH_READWRITE_RECNO,XH_READWRITE_COUNT,XH_READWRITE_BUFFER
	move.l XH_READWRITE_BUFFER,-(sp)	; *buff
	move.w XH_READWRITE_COUNT,-(sp)	; count
	move.l XH_READWRITE_RECNO,-(sp)	; recno
	move.w XH_READWRITE_RWFLAG,-(sp)	; rw_flag
	move XH_DEVICE_MINOR,-(sp)	; minor
	move XH_DEVICE_MAJOR,-(sp)	; major
	move.w #10,-(sp)		; XHreadWrite
	jsr ([XH_DRIVER_ROUTINE])
	lea 18(sp),sp
	move d0,XH_RETURN_CODE
	rts
	endc

	ifd LIB_XHDI_INQDEV2
XH_INQ_DEV_2:			; XH_BIOS_DEVICE,XH_BPB,XH_PARTID
	move.l XH_PARTID,-(sp)		; char *partid
	pea XH_DEVICE_NB_BLOCKS		; *blocks
	move.l XH_BPB,-(sp)		; BPB *bpb
	pea XH_DEVICE_START_SECTOR	; *device start sector
	pea XH_DEVICE_MINOR		; *minor
	pea XH_DEVICE_MAJOR		; *major
	move.w XH_BIOS_DEVICE,-(sp)	; bios device
	move.w #12,-(sp)		; XInqDev2
	jsr ([XH_DRIVER_ROUTINE])
	lea 28(sp),sp
	move.w #GWVA_ERROR_GENERIC,XH_RETURN_CODE
	cmp.l #-1,XH_DEVICE_START_SECTOR
	beq.s .temp_unavailable
	move d0,XH_RETURN_CODE
.temp_unavailable:
	rts
	endc

	ifd LIB_XHDI_GETCAPACITY
XH_GET_CAPACITY:			; XH_DEVICE_MAJOR,XH_DEVICE_MINOR
	pea XH_1BLOCK_SIZE		; *blocksize
	pea XH_DEVICE_NB_BLOCKS		; *blocks
	move XH_DEVICE_MINOR,-(sp)	; minor
	move XH_DEVICE_MAJOR,-(sp)	; major
	move.w #14,-(sp)		; XHGetCapacity
	jsr ([XH_DRIVER_ROUTINE])
	lea 14(sp),sp
	move d0,XH_RETURN_CODE
	rts
	endc

	ifd LIB_XHDI_LASTACCESS
XH_LAST_ACCESS:			; XH_DEVICE_MAJOR,XH_DEVICE_MINOR
	pea XH_NB_MS		; *ms
	move XH_DEVICE_MINOR,-(sp)	; minor
	move XH_DEVICE_MAJOR,-(sp)	; major
	move.w #18,-(sp)		; XHLastAccess
	jsr ([XH_DRIVER_ROUTINE])
	lea 10(sp),sp
	move d0,XH_RETURN_CODE
	rts
	endc

*--------------------------------------------------------------------------*

	BSS

XH_DRIVER_ROUTINE:	ds.l 1
XH_RETURN_CODE:	ds.w 1

XH_DEVICE_FLAGS:	ds.l 1
XH_1BLOCK_SIZE:	ds.l 1
XH_DEVICE_NB_BLOCKS:	ds.l 1
XH_DEVICE_START_SECTOR:	ds.l 1
XH_DEVICE_KEY:	ds.w 1
XH_BIOS_DEVICE:	ds.w 1
XH_DEVICE_MINOR:	ds.w 1
XH_DEVICE_MAJOR:	ds.w 1
XH_READWRITE_RWFLAG:	ds.w 1
XH_READWRITE_RECNO:	ds.l 1
XH_READWRITE_COUNT:	ds.w 1
XH_READWRITE_BUFFER:	ds.l 1
XH_PRODUCTNAME:	ds.l 1	; fill with 0.l if not used
XH_PARTID:		ds.l 1	; fill with 0.l if not used
XH_BPB:		ds.l 1	; fill with 0.l if not used
XH_NB_MS:		ds.l 1

	ifd LIB_XHDI_STOP
XH_DO_STOP:	ds.w 1
	endc

	ifd LIB_XHDI_EJECT
XH_DO_EJECT:ds.w 1
	endc

	TEXT

*--------------------------------------------------------------------------*
