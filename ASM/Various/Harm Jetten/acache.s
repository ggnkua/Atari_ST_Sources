* acache v 1.1
* by Harm Jetten, 870412
* caches disk sectors for drive A:
* assemble with HiSoft DevpacST
* put acache.prg in your AUTO folder

nsects	equ	16		number of disk sectors cached
ageing	equ	2*nsects	offset from sector number in map
magic	equ	'CACH'		identification of this program
 
	include gemdos.s

start:	pea	rpvec(pc)	go replace r/w vector
	call_ebios supexec
	addq.l	#6,sp

	tst.b	d2		this was first time cache is called ?
	bne.s	putmsg
	call_bdos p_term_old	if not, return, exit code is 0

putmsg:	pea	strins(pc)	announce disk cache installed
	call_bdos c_conws
	addq.l	#6,sp

	bsr	clrmap		clear cache map
	lea	end(pc),a0	calculate amount of
	sub.l	4(sp),a0	memory to keep resident
	clr	-(sp)		exit code is 0
	move.l	a0,-(sp)
	call_bdos p_termres


* replace old r/w vector with cache vector

rpvec:	lea	hdv_rw,a1	get vector
	move.l	(a1),a0
	cmp.l	#magic,-8(a0)	are we installed already ?
	sne.b	d2		set if not installed yet
	beq.s	rpret
	lea	acache(pc),a0
	move.l	(a1),-4(a0)	save old r/w vector
	move.l	a0,(a1)		install acache in vector
rpret:	rts


* copy a sector from a0 to a1

cpysec:	move.l	a0,d0		see if a0 or a1 are odd
	btst.l	#0,d0
	bne.s	cpyslo
	move.l	a1,d0
	btst.l	#0,d0
	bne.s	cpyslo

	moveq	#31,d0		fast copy, 32 * 16 bytes
cpyflp:	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,cpyflp
	rts

cpyslo:	moveq	#127,d0		slow copy, 128 * 4 bytes
cpyslp:	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	dbra	d0,cpyslp
	rts


* clear all entries in cache map

clrmap:	lea	map(pc),a0
	moveq	#nsects-1,d2
clrmab:	clr.l	(a0)+
	dbra	d2,clrmab
	rts


* cache r/w handler 

id:	dc.l	magic		our identification
oldvec:	dc.l	0		save old r/w vector here

acache:	tst	14(sp)		drive must be A:
	beq.s	drva
toold:	move.l	oldvec(pc),a0	jump to old r/w driver
	jmp	(a0)

drva:	tst	12(sp)		check if accessing boot sector
	bne.s	noboot
	bsr	clrmap		wipe out map
	bra.s	toold

noboot:	move.l	hdv_mediach,a3	check if media changed
	clr	-(sp)		on drive A:
	jsr	(a3)
	addq.l	#2,sp
	tst.l	d0
	beq.s	nochg
	bsr	clrmap		wipe out map, continue

nochg:	tst	4(sp)		check request type (rd/wr)
	bne.s	nocach

	cmp	#1,10(sp)	check only one sector to read
	bne.s	nocach

	move	12(sp),d6	get logical sector number

	lea	map+ageing(pc),a3  sector present in cache ?
	moveq	#nsects-1,d2
srchlp: cmp	-(a3),d6
	beq.s	found
	subq	#1,ageing(a3)	leak ageing field
	bgt.s	srchnx
	addq	#1,ageing(a3)	oops, if it was 0 or 1 leave it
srchnx:	dbra	d2,srchlp

	lea	map+2*ageing(pc),a3  search for oldest sector
	move	#32767,d1
	moveq	#nsects-1,d2
repllp: cmp	-(a3),d1
	blt.s	replnx
	move.l	a3,a0		new lowest ageing ptr
	move	(a3),d1		new lowest ageing value
replnx:	dbra	d2,repllp

	move	d6,-ageing(a0)	replace oldest sector number
	clr	(a0)		0 ageing means not valid yet
	bra.s	nocach

found:	add	#ageing,a3
	tst	(a3)		ageing of 0 is invalid
	beq.s	nocach

	move	#32767,(a3)	update sector ageing field 
	move	d2,d1		save this index 
	beq.s	calcad
	subq	#1,d2
restlp:	subq	#1,-(a3)	leak remaining fields
	bgt.s	restnx
	addq	#1,(a3)		oops, if it was 0 or 1 leave it
restnx:	dbra	d2,restlp

calcad:	move.l	6(sp),a1	user buffer address
	lea	cachbuf(pc),a0
	mulu	#512,d1
	add.l	d1,a0		address of cached sector

	bsr	cpysec		copy cached sector to user buffer

	clr.l	d0		return success
	rts
	
nocach:	lea	rsave(pc),a0
	move.l	(sp)+,(a0)	save original return address
	pea	ownret(pc)	replace with our own return address
	bra	toold		execute the request
ownret:	move.l	rsave(pc),-(sp)	put back original
	tst.l	d0
	bne.s	return		return if request failed
	
	lea	map+ageing(pc),a3  check if cached sectors need updating
	move	12(sp),d6	get first logical sector number
	move	10(sp),d5
	add	d6,d5		get last+1 logical sector number
	moveq	#nsects-1,d2
updtlp: cmp	-(a3),d6	cached sector number in range ?
	bgt.s	updtnx
	cmp	(a3),d5
	ble.s	updtnx

	move	#32767,ageing(a3)  update sector ageing field 
	
	move.l	6(sp),a0	start of user buf
	move	(a3),d1
	sub	d6,d1		number of sectors from start of user buf
	mulu	#512,d1
	add.l	d1,a0		address of the sector in user buf

	lea	cachbuf(pc),a1
	move	d2,d1
	mulu	#512,d1
	add.l	d1,a1		address of cached sector

	bsr	cpysec		copy user sector to cache

updtnx:	dbra	d2,updtlp

	clr.l	d0		return success
return:	rts

strins:	dc.b	13,10," acache v 1.1 installed",13,10,0
	even

rsave:	dsbss.l	1		for return address
map:	dsbss.l nsects		the cache map (sector nr, ageing)
cachbuf:dsbss.b 512*nsects	the cached sector buffer
end:	dsbss.b 0		used for resident memory calculation
