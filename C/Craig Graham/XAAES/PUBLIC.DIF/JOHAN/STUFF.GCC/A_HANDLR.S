.globl	_handler
.globl	_patch_handler

|-------------------------------------------------------------------------------------
| AES/VDI (Trap 2)  Handler
|-------------------------------------------------------------------------------------
| This mini handler just calls the main handler (written in C) or fields VDI
| commands out to the old vector (which was saved when we hooked trap 2 in the first
| place).
| Perhaps the whole trap handler should be in assembler, but really, it's fast enough
| for me just written in C with this small kludge routine to handle the actual
| exception itself. If anyone wants to recode it totally in assembler, the main Trap
| to pipe interface in in HANDLER.C - I'll happily put the mods into a new release.
| WARNING: There is a small amount of self-modifiying code in here......
|-------------------------------------------------------------------------------------

|Exception vector goes to here....

_handler:

	btst	#7,d0			| Is this a VDI call? AES calls all have bit 7 of d0 set.
	beq		_is_vdi_call	| - if so, we should call the old vector as we haven't replaced
					|   the VDI and have to rely on the existing one.
	movel	d2,a7@-
	movel	a2,a7@-

	movel	d1,a7@-
	movew	d0,a7@-

	jsr	_XA_handler

	addql	#6,a7

	movel	a7@+,a2
	movel	a7@+,d2

	rte


| This is a jump to the old VDI/AES vector. The hook_into_vector() routine in HANDLER.C
| patches this jump instruction to point to the old vector (I know, self modifiying code
| shouldn't be used, but it's here to try and reduce the overhead in the trap handler
| for VDI calls.
| $4EF9 is the 68000 code for JMP
_is_vdi_call:
	.word	0x4EF9			| Call the old trap 2 vector with the VDI command
_old_trap2_vector:
	.long	0x12345678		| $123456578 is a dummy jump address that is replaced at run time.

| Do the patch
_patch_handler:
	movel	a7@(4),_old_trap2_vector
	rts
