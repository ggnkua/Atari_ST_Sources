base_blit	equ	$ffff8a00
adr_s	equ	$24	;adresse_source
adr_d	equ	$32	;adrese_destination
inc_hs	equ	$20	;inc horizontal source
inc_hd	equ	$2e	;increment horizontal destination
t_h	equ	$36	;taille horizontal
t_v	equ	$38	;taille vertical
inc_vs	equ	$22	;inc vertical source
inc_vd	equ	$30	;increment vertical destination

mask	equ	$28	; les 3 masks
h_dt	equ	$3a	;op demi teinte 1 (source=2)
op_l	equ	$3b	;mode 3
contrl	equ	$3c	;bit 7
