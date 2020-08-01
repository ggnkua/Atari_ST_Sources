; GEM.S: VDI and AES interface words
; Copyright <C> John Redmond 1989,1990
; Public domain for non-commercial use.
;
	section	text
	even

_aes:	lea	_aespb,a0
	move.l	a0,d1
	move.w	#$c8,d0
	movem.l d2/a2/a6,-(a7)
	trap	#2
	movem.l (a7)+,d2/a2/a6
	rts
;
_vdi:	lea	_vdipb,a0
	move.l	a0,d1
	move.w	#$73,d0
	move.l	d2,-(a7)
	movem.l d2/a2/a6,-(a7)
	trap	#2
	movem.l (a7)+,d2/a2/a6
	rts
;
_control: dc.w	1
sintin: dc.w	1
sintout: dc.w	1
saddrin: dc.w	1
saddrout: dc.w	1
	ds.w	5
;
_global:
version: dc.w	1
apcount: dc.w	1
apid:	dc.w	1
apprivate: dc.l 1
apptree: dc.l	1
reserve: dc.l	4
;
_intin:	ds.w	256
_ptsin:	ds.w	128
_intout: ds.w	45
_ptsout: ds.w	12
_addrin: ds.w	128
_addrout: ds.w	128
;
; Initialization of the following (with _iarrays) will be necessary.
_aespb: ds.l	6 ;control,global,intin,intout,addrin,addrout
_vdipb: ds.l	5 ;control,intin,ptsin,intout,ptsout
;
_iarrays:
	move.l	a7,a1
	lea	_vdipb+20,a7
	pea	_ptsout
	pea	_intout
	pea	_ptsin
	pea	_intin
	pea	_control
	pea	_addrout
	pea	_addrin
	pea	_intout
	pea	_intin
	pea	_global
	pea	_control
	move.l	a1,a7
	rts
;
	section	data
	even
;
	dc.b	$83,'VD','I'!$80
	ptrs	_vdi,16
;
	dc.b	$83,'AE','S'!$80
	ptrs	_aes,16
;
	dc.b	$c7,'CONTRO','L'!$80
	vptrs	_control,20
;
	dc.b	$c6,'GLOBAL',$a0
	vptrs	_global,20
;
	dc.b	$c5,'INTI','N'!$80
	vptrs	_intin,18
;
	dc.b	$c6,'INTOUT',$a0
	vptrs	_intout,20
;
	dc.b	$c5,'PTSI','N'!$80
	vptrs	_ptsin,18
;
	dc.b	$c6,'PTSOUT',$a0
	vptrs	_ptsout,20
;
	dc.b	$c6,'ADDRIN',$a0
	vptrs	_addrin,20
;
	dc.b	$c7,'ADDROU','T'!$80
	vptrs	_addrout,20
;
	dc.b	$c5,'AESP','B'!$80
	vptrs	_aespb,18
;
	dc.b	$c5,'VDIP','B'!$80
	vptrs	_vdipb,18
;
	dc.b	$87,'IARRAY','S'!$80
	ptrs	_iarrays,20
;
