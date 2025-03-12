************************************************************
* Exemple d'utilisation de la routine de reproduction      *
* d'un module.                                             *
* Fabien Masson                                            *
*                                copyright E.S.A.T.   1991 *
************************************************************
	section	text
	move.l	4(sp),a6
	lea	mystack,sp
	move.l	$c(a6),d0
	add.l	$14(a6),d0
	add.l	$1c(a6),d0
	add.l	#$100,d0
	move.l	d0,-(sp)
	move.l	a6,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp
	tst.l	d0
	bne	end

	pea	cnx_volume_table
	move.w	#cnx_output,-(sp)
	pea	cnx_module
	jsr	replay
	lea	10(sp),sp

end	clr.w	-(sp)
	trap	#1

replay	include	player.s

	section	data
module		incbin	\modules\*.mod
cnx_module		equ	module
; adresse du module

cnx_output		equ	$00
;	Yamaha		Dma12khz	Dma25khz	Dma50khz
;Stf	  *
;Ste	  *		*(8bits)	*(7bits)
;MegaSte  *		*(8bits)	*(8bits)	*(7bits)
;TT	  *		*(8bits)	*(8bits)	*(8bits)
;
; Les cartouches sont disponibles sur toutes les machines.
;
; Yamaha	$00: sortie normale
;		$01: sortie avec un volume plus fort
; Dma		$10: 12khz (8bits)
;		$11: 25khz (7bits)
;		$12: 50khz (8bits)
;		$13: 50khz (7bits)
;		$14: 25khz (8bits)
;
; ST Replay	$20
; ST Replay-Pro	$21
; MV 16		$21
; Playback	$22
;
; Pro Sound Designer	$24
;

volume_table	ds.l	65*256/4
cnx_volume_table	equ	volume_table
; Cette table ne doit etre que si on utilise une sortie Dma en 7 bits.

	section	bss
	ds.l	$400
mystack
