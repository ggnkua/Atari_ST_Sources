; Sous-routines de reconnaissance et adaptation … l'environnement

search_cookie:
	move.l	($5a0.w),a0
.loop_search_cookie:
	clr.w	d1
	move.l	(a0),d2
	beq.s	.end_loop_cookie
	move.w	#1,d1
	cmp.l	d0,d2
	beq.s	.end_loop_cookie
	addq.l	#8,a0
	bra.s	.loop_search_cookie
.end_loop_cookie:
	rts

init_mint:
	move.l	#'MiNT',d0
	bsr.s	search_cookie
	tst.w	d1
	beq.s	.no_mint
	move.w	#1,play_once
.no_mint:
	rts

init_cacr:
	move.l	#'_CPU',d0
	bsr.s	search_cookie
	tst.w	d1
	beq.s	.error_cacr
	move.l	4(a0),d1
	cmp.w	#20,d1
	blt.s	.error_cacr
	movec	cacr,d0
	move.l	d0,sauve_cache
	move.l	#SET_CACHE_020,d0	; On active les caches
	cmp.w	#40,d1
	blt.s	.no_040
	move.l	#SET_CACHE_040,d0
.no_040:
	moveq	#-1,d1
	movec	d0,cacr
	rts
.error_cacr:
	moveq	#0,d1
	rts

init_nvdi:
	move.l	#data_nvdi,adr_bios_nvdi
	Setexc	#$2d,-1.l	; le bios : 45Šme vecteur
	move.l	d0,a0		; l'adresse que pointe ce vecteur
.search_nvdi:
	move.l	-12(a0),d0
	cmp.l	#'XBRA',d0
	bne.s	.fin_nvdi
	move.l	-8(a0),d0
	cmp.l	#'NVDI',d0
	beq.s	.trouve_nvdi
	move.l	-4(a0),a0
	bra.s	.search_nvdi	
.trouve_nvdi:
	move.l	a0,adr_bios_nvdi
	move.l	(a0),data_nvdi
	move.l	#$2f3afffa,(a0)+
	move.w	(a0),data_nvdi+4
	move.w	#$4e75,(a0)
.fin_nvdi:
	rts

restore_nvdi:
; Si NVDI n'est pas pr‚sent, adr_bios_nvdi vaut en fait #data_nvdi !!!
	move.l	adr_bios_nvdi(pc),a0
	move.l	data_nvdi(pc),(a0)+
	move.w	data_nvdi+4(pc),(a0)
	rts

	BSS
adr_bios_nvdi:
	ds.l	1
data_nvdi:
	ds.l	1
	ds.w	1
	TEXT

init_tveil:
	move.l	#'VeiL',d0
	bsr	search_cookie
	tst.w	d1
	beq.s	.no_tveil
	move.l	4(a0),a0
	move.b	$37(a0),tveil_mode
	st	$37(a0)
.no_tveil:
	rts

restore_tveil:
	move.l	#'VeiL',d0
	bsr	search_cookie
	tst.w	d1
	beq.s	.no_tveil
	move.l	4(a0),a0
	move.b	tveil_mode(pc),$37(a0)
.no_tveil:
	rts

	BSS
tveil_mode:
	ds.w	1
	TEXT
