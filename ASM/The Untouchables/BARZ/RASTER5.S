 format 0-,1-,2-
 list +

* ADVANCED RASTER PROGRAMMING BY TONY B OF THE UNTOUCHABLES
* Patched up by Mat of the Untouchables
* USES: D0/A0-A1	TABS = 10		DEVPAC V2.23
 list -


	pea	x(pc)		; exec. in supervisor mode
	move	#38,-(sp)
	trap	#14
	addq.l	#6,sp
	
	clr	-(sp)		; the end!
	trap	#1


*------------------
x	clr.b	$ffff8203.w	; clear screen!!!
	
	move.b	#$12,$fffffc02.w	; disable mouse

	bsr.s	set_ints		; set ints.


scan:	cmp.b	#57,$fffffc02.w	; space?
	bne.s	scan


	bsr.s	rem_ints		; old vectors

	move	#$777,$ffff8240.w	; white border
	move.b	#$8,$fffffc02.w	; enable mouse

	rts			; return/user mode


*------------------
set_ints:	move	#$2700,sr		; set the interrupts
	move.l	$70.w,oldvbl
	move.l	$118.w,oldkey
	move.l	$120.w,oldhbl
	move.b	$fffffa07.w,mfp
	move.b	$fffffa09.w,mfp+1	; save some MFP vecs.
	move.b	$fffffa13.w,mfp+2
	and.b	#$fe,$fffffa07.w	; disable timer b
	and.b	#$df,$fffffa09.w	; disable timer c
	move.l	#newvbl,$70.w
	move.l	#newhbl,$120.w	; install new ints.
	move.l	#newkey,$118.w
	or.b	#1,$fffffa07.w	; enable timer b
	or.b	#1,$fffffa13.w	; set timer b mask
	move	#$2300,sr
	rts

*------------------
rem_ints:	move	#$2700,sr		; return old vectors
	move.b	mfp(pc),$fffffa07.w	; old MFP
	move.b	mfp+1(pc),$fffffa09.w
	move.b	mfp+2(pc),$fffffa13.w
	move.l	oldkey,$118.w
	move.l	oldvbl,$70.w		; old ints.
	move.l	oldhbl,$120.w
	move	#$2300,sr
	rts


oldvbl	dc.l	0
oldhbl	dc.l	0
oldkey	dc.l	0

*------------------
* new key handler
newkey	move	#$2500,sr		; stop interference from ikbd
	move.b	$fffffc02.w,rubbish	; empty keyboard
	bclr	#6,$fffffa11.w
	rte


*----------------------------
* the usual timer b stuff
newhbl:	move.l	a0,-(sp)
	movea.l	pointer(pc),a0	; you should understand how this
	move	(a0)+,$ffff8240.w	; working, by now ....
	move.l	a0,pointer
	movea.l	(sp)+,a0
	bclr	#0,$fffffa0f.w
	rte


*----------------------------
* the good bits...
newvbl:	clr.b	$fffffa1b.w
	move.b	#1,$fffffa21.w	; set timer
	move.b	#8,$fffffa1b.w

	move.l	#buffer,pointer	; get next color
	
	not.b	slower		; execute only every other VBL
	tst.b	slower		; ...to slow it down a bit!
	beq.s	exit70		; exit my VBL

	addq	#2,offset		; increment pointer in palette
	cmp	#560,offset	; time to wrap?
	bne.s	carryon
	clr	offset		; clear counter 'coz we have
				; reached the end of the palettes!

carryon:	movem.l	d0/a0-a1,-(sp)
	lea	buffer(pc),a1
	lea	cols(pc),a0
	adda	offset(pc),a0
	moveq	#12-1,d0
copy:	move.l	(a0),(a1)+	; shift in increments of 2 !
	move.l	2(a0),(a1)+	; try it with increments of 4 ..
	move.l	4(a0),(a1)+
	move.l	6(a0),(a1)+
	move.l	8(a0),(a1)+
	move.l	10(a0),(a1)+
	move.l	12(a0),(a1)+
	move.l	14(a0),(a1)+
	addq.l	#2,a0
	dbf	d0,copy
	movem.l	(sp)+,d0/a0-a1

exit70:	rte			; end of VBL



*------------------
	section data
rubbish	dc.b	0
offset:	dc.w	0		; counter
slower:	dc.b	0		; will either be 0 or 1
pointer:	dc.l	0		; pointer to next color
mfp:	dc.b	0,0,0		; space for MFP vecs.

*------------------
cols:	dc.l	0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	$111,$222,$333,$444,$555,$666,$777,$777
	dc.w	$666,$555,$444,$333,$222,$111,$000,$000
	
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	$011,$022,$033,$044,$055,$066,$077,$077
	dc.w	$066,$055,$044,$033,$022,$011,$000,$000
	
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	$101,$202,$303,$404,$505,$606,$707,$707
	dc.w	$606,$505,$404,$303,$202,$101,$000,$000
	
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	$110,$220,$330,$440,$550,$660,$770,$770
	dc.w	$660,$550,$440,$330,$220,$110,$000,$000
	
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	$010,$020,$030,$040,$050,$060,$070,$070
	dc.w	$060,$050,$040,$030,$020,$010,$000,$000
	
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	$100,$200,$300,$400,$500,$600,$700,$700
	dc.w	$600,$500,$400,$300,$200,$100,$000,$000
	
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	$001,$002,$003,$004,$005,$006,$007,$007
	dc.w	$006,$005,$004,$003,$002,$001,$000,$000
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0


;	section bss
buffer:	ds.w	buffer-cols	; store for shifted colors

