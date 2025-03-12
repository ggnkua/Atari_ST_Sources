	OPT	D-
	COMMENT	HEAD=%111

	pea	hello_txt(pc)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp

	move.w	#7,-(sp)
	trap	#1
	addq	#2,sp

	clr.w	-(sp)
	trap	#1

hello_txt:
	DC.B	"Hello world",0