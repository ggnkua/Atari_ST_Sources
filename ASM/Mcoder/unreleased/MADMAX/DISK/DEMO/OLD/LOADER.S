	OUTPUT	LOADER.PRG
;
; chargement du fichier de musiques
;
loadfile:
	DC.W	$A009
	pea	.loading(pc)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp

	clr	-(sp)
	pea	.file(pc)
	move	#$3d,-(sp)
	trap	#1
	addq	#8,sp

	move.l	d0,d7
	bpl.s	.noerr
.errload:illegal
.loading:dc.b	27,"ELoading madmax.prg",13,10,0
.file:	dc.b	"madmax.prg",0
	EVEN
.noerr
	PEA	CODE(PC)
	pea	200000
	move	d7,-(sp)
	move	#$3f,-(sp)
	trap	#1
	lea	12(sp),sp
	tst.l	d0
	bmi.s	.errload

	move	d7,-(sp)
	move	#$3e,-(sp)
	trap	#1
	addq	#4,sp
CODE:
