	.globl _main
	.text
_main:	link	a6, #-24
	move.w  #26, -(a7)
	pea.l	buff
	move.w  #$36, -(a7)
	trap	#1
	addq.l  #8, a7
	unlk	a6
	rts
	.bss
	.even
buff:	.ds.l 4
	.end
