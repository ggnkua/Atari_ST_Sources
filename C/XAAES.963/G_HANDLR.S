|-------------------------------------------------------------------------------
| AES/VDI (Trap 2)  Handler
|-------------------------------------------------------------------------------
| This mini handler just calls the main handler (written in C) or fields VDI
| commands out to the old vector (which was saved when we hooked trap 2 in the
| first place). Perhaps the whole trap handler should be in assembler, but
| really, it's fast enough for me just written in C with this small kludge
| routine to handle the actual exception itself. If anyone wants to recode it
| totally in assembler, the main Trap to pipe interface is in HANDLER.C - I'll
| happily put the mods into a new release.
| - Self modifying code removed [13/2/96] by Martin Koeling.
| - Made XBRA compliant [13/2/96] by Martin Koeling.
| - AES trap code streamlined [980629] by Johan Klockars.
|   Note that absolute addressing is used in two places since the version
|   of GAS I have couldn't deal with PC relative there...
|-------------------------------------------------------------------------------

	.text
	.globl	_asm_hook_into_vector
	.globl	_accstart


| The hook is now done in assembler....
_asm_hook_into_vector:
	moveml	d0-d2/a0-a1,sp@-
	pea	handler			| pc@(handler) produced bad code
	movew	#0x22,sp@-
	movew	#5,sp@-
	trap	#13
	lea	sp@(8),sp
	movel	d0,_old_trap2_vector
	moveml	sp@+,d0-d2/a0-a1
	rts


| XBRA structure immediately before the new vector address:
	.ascii	"XBRA"
	.ascii	"XaAE"		| XBRA id (just a proposal)
_old_trap2_vector:
	.long	0
	
| Exception vector goes to here...
handler:
	cmpw	#0xc9,d0	| Special case: implement the test for installed AES
	beqs	_end_handler

	cmpw	#0xc8,d0	| Both $fffe (vq_gdos) and $73 (vdi calls) are less than $c8
	blts	_not_aes	
	
	movel	a1,sp@-		| GCC code destroys d0-d1/a0-a1, but AES should keep a1

	movel	d1,sp@-		| Push args for GCC stack call
	movew	d0,sp@-

	jsr	_XA_handler	| Call the real handler written in C

	addql	#6,sp

	movel	sp@+,a1

	clrw	d0		| Ordinary GEM does this - so we do it as well...

_end_handler:
	rte


| New version of the call to the original VDI/AES vector
| [13/2/96] - Martin Koehling
| This is a jump to the old VDI/AES vector. No self-modifying code
| here - _old_trap_vector is data, not code... :-)

_not_aes:
	movel	_old_trap2_vector,sp@-	| pc@(...) produced bad code
	rts


| Accessory startup code poached from oAESis
_accstart:
	movel sp@(4),a0
	clrl  a0@(36)			; HR:   clear pointer to parent basepage
	movel a0@(16),a1
	movel a1,a0@(8)
	addl  a0@(12),a1
	movel a1,a0@(16)
	movel a0@(8),a1	
	jmp a1@
