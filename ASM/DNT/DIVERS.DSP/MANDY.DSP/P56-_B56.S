;Minuscule routine pour transformer un fichier *.P56 simple en
;un fichier *.B56 … utiliser avec Dsp_ExecBoot.
;Il faut que le programme DSP … traiter soit d'un seul bloc en
;m‚moire P, sinon ‡a ne marche pas!...
;
;(C)oderight Nullos/DNT-Crew 1994
;
	include	tos_030.s

	section	text
	clr.w	-(sp)
	pea	name_b56(pc)
	Gemdos	Fcreate
	move.w	d0,d7
	pea	bloc_p56+9(pc)
	pea	bloc_siz-9.w
	move.w	d7,-(sp)
	Gemdos	Fwrite
	move.w	d7,-(sp)
	Gemdos	Fclose
	Gemdos	Pterm0

	section	data
bloc_p56	incbin	mandy.p56
bloc_siz	equ	*-bloc_p56
name_b56	dc.b	"mandy.b56",0
