*************************
*			*
DRIVE	equ	1	*
TRACK	equ	79	*
*			*
*************************
	
	opt	o+,x+,w-,a+
start
	move.l	#main,-(a7)
	move	#$26,-(a7)
	trap	#14
	addq	#6,a7
	clr	-(a7)
	trap	#1
main
	move	#$2700,sr
	move.l	#$eff05ff,$ffff8800.w
Retry:
	moveq	#TRACK,d7		; beware to track #70 !!
	moveq	#-1,d3
	bsr.s	Hard
	bsr	Mot_off
Nop:
	nop
	rts
Hard:	
Special:
	bsr	Spe_trk
	move.l	#$eff05ff,$ffff8800.w
	moveq	#0,d0
	bsr	Seek_d0
	bsr	Seek_d0
	move	d7,d0
	bsr	Seek_d0
	lea	Buffer,a6
.Format:
	bsr	Initdma
	move.w	#$190,$ffff8606.w
	move.w	#$90,$ffff8606.w
	move.w	#$190,$ffff8606.w
	divs	d3,d3
	move.w	#$1f,$ffff8604.w	; seek
	divs	d3,d3
	move.w	#$180,$ffff8606.w
	divs	d3,d3
	move.w	#$f0,$ffff8604.w	; Write track
	bsr	Mfpwait
	move.w	$ffff8604.w,d2
	btst	#4,d2			; 1=wrt prot.
	bne.s	.Format
	rts
Spe_trk:
	moveq	#$A,d5			; 11 sectors
	lea	Buffer,a0
Protect:
	moveq	#$f,d3			; 25*$4e
	moveq	#$4e,d2
	bsr	Built
	movem.l	Secret(pc),d0-d1
	movem.l	d0-d1,(a0)
	addq	#8,a0
	moveq	#1,d0
	moveq	#2,d1
Nxtsect:
	moveq	#7,d3			; 8*$00	gap2
	moveq	#0,d2
	bsr	Built
	moveq	#2,d3			; 3*$f5	sync
	moveq	#$f5,d2
	bsr	Built
	moveq	#$fe,d2
	move.b	d2,(a0)+		; $fe	id-am
	move.b	d7,(a0)+		; d7	track
	clr.b	(a0)+			; $00	side
	move.b	d0,(a0)+		; d0	sector
	move.b	d1,(a0)+		; d1	lenght
	moveq	#$f7,d2
	move.b	d2,(a0)+		; $f7	id-crc
	moveq	#$f,d3			; 22*$4e	gap3
	moveq	#$4e,d2
	bsr	Built
	moveq	#$b,d3			; 12*$00
	moveq	#0,d2
	bsr	Built
	moveq	#2,d3			; 3*$f5	sync
	move.b	#$f5,d2
	bsr	Built
	moveq	#$fb,d2
	move.b	d2,(a0)+		; $fb	dam
	move.w	#$1ff,d3		; 512*$e5
	moveq	#$e5,d2
	bsr	Built
	moveq	#$f7,d2
	move.b	d2,(a0)+		; $f7	data-crc
	moveq	#1,d3			; 37*$4e	gap4
.Short:
	moveq	#$4e,d2
	bsr	Built
	addq.w	#1,d0
	dbf	d5,Nxtsect
	moveq	#1,d3			; 57*$4e	gap5
	moveq	#$4e,d2
Built:
	move.b	d2,(a0)+
	dbf	d3,Built
	rts
Restdrv:
	bsr	Initdma
	move.w	#$90,$ffff8606.w
	move.w	#$190,$ffff8606.w
	move.w	#$90,$ffff8606.w
	divs	d3,d3
	move.w	#1,$ffff8604.w
	divs	d3,d3
	move.w	#$80,$ffff8606.w
	divs	d3,d3
	move.w	#$e0,$ffff8604.w
	bra	Mfpwait
Initdma:
	move.l	a6,d6
	move.b	d6,$ffff860d.w
	ror.w	#8,d6
	move.b	d6,$ffff860b.w
	swap	d6
	move.b	d6,$ffff8609.w
	rts
Resdrv2:
	move.w	#$80,$ffff8606.w
	divs	d3,d3
	move.w	#3,$ffff8604.w
	divs	d3,d3
	bra.s	Mfpwait
Seek_d0:
	tst.w	d0
	beq.s	Resdrv2
	move.w	#$86,$ffff8606.w
	divs	d3,d3
	move.w	d0,$ffff8604.w
	divs	d3,d3
	move.w	#$80,$ffff8606.w
	divs	d3,d3
	move.w	#$13,$ffff8604.w
	divs	d3,d3
Mfpwait:
	move.l	#$40000,d2
.Loop7:
	subq.l	#1,d2
	beq.s	.Endmfp
	btst	#5,$fffffa01.w
	bne.s	.Loop7
.Endmfp:
	rts
Mot_off:
	move.w	#$80,$ffff8606.w
.Motor:
	move.w	$ffff8604.w,d2
	btst	#7,d2
	bne.s	.Motor
	move.l	#$e0e0707,$ffff8800.w
	rts
Fdc:
	lea	$ffff8606.w,a6
	move	#$90,(a6)
	move	#$190,(a6)
	move	#$90,(a6)
	moveq	#$16,d7
	bsr	Wrt1772
	lea	Buffer(pc),a6
	bsr	Initdma
	lea	$1870(a6),a6
	move	#$80,$ffff8606.w
	move	#$e8,d7
	bsr	Wrt1772
	move	#$180,d5
.Pause:
	dbf	d5,.Pause
	moveq	#4,d5
	swap	d5
.Readmfp:
	btst	#5,$fffffa01.w
	beq	Force
	subq.l	#1,d5
	beq.s	Force
	lea	Dmaadr(pc),a5
	clr.b	(a5)+
	move.b	$ffff8609.w,(a5)+
	move.b	$ffff860b.w,(a5)+
	move.b	$ffff860d.w,(a5)
	cmp.l	-3(a5),a6
	bgt.s	.Readmfp
Force:
	move	#$80,$ffff8606.w
	move	#$d0,d7
Wrt1772:
	divs	d3,d3
	move	d7,$ffff8604.w
	divs	d3,d3
Rt:
	rts
Secret:
;	dc.b	$28,$29,0,"RAP"
;	dc.b	$28,$29,0,"LGT"
;	dc.b	$28,$29,0,"LIGHTMAN"
	dc.b	$28,$29,0,"SUCK MY DICK"
	dc.b	$4e,$4e
	bss	****************
Dmaadr:
	ds.l	1
Buffer:
	ds.l	2000
	End	****************