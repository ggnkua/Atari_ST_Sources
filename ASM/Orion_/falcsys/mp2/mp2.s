;-------------------------------------
; DSP MPEG Audio Layer 2 player
; by Tomas Berndtsson, NoBrain/NoCrew
;-------------------------------------

	machine	68000

	public	_asm_mp2_player
	public	_asm_mp2_start
	public	_asm_mp2_stop

_asm_mp2_start:
	jmp	_asm_mp2_player+48

_asm_mp2_stop:
	jmp	_asm_mp2_player+52

	even
_asm_mp2_player:
	incbin	'mp2inc.bin'
	even
