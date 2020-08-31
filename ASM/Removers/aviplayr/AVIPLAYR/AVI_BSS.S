********************************************************************************
	BSS
********************************************************************************
	; ces buffers sont ‚normes : il faut les mettre … la fin 

	; Il y a deux type de palette (0 pour les blocs C4, 1 pour les C1)
	; un type de palette contient 16 palettes de 256 entr‚es
	; une entree contient 4 couleurs.
	; il faut donc 1 entr‚e pour un bloc C1 et 4 pour un bloc C4
;	CNOP	0,1024
;	ds.w	1
__pal
palettes0
	ds.w	4*256*16
palettes1
	ds.w	4*256*16
	; la curieuse forme de ces precalculs vient du fait que lors d'un accŠs
	; "move.l (a1,d1.w*8),d1", il y a extension du signe de d1 sur 32 bits
	IFND	NO_OPT
NO_OPT	equ	1
	ENDC
	IF	NO_OPT
	ds.w	(1<<16)/2
buff_prec_uv
	ds.w	(1<<16)/2
	ELSE
	even.l
buff_prec_uv
	ds.w	(1<<18)
	ENDC
**********************
	ds.w	1<<15
bits_entrelaces_cram
	ds.w	1<<15
