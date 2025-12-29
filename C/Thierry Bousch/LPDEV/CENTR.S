|
| centr.s: Centronics interrupt routine. It is raised every time
| the printer is ready to write one more character
|
| Also a few low-level functions

.globl _new_centr_vector, _print_byte

_new_centr_vector:
	moveml	d0-d1/a0-a1, sp@-
	jsr	_print_head		| prints the pending byte(s)
	jsr	_wake_up		| has someone selected the printer?
	moveml	sp@+, d0-d1/a0-a1
	bclr	#0, 0xFFFFFA11
	rte
	
_print_byte:
	movew	sp@(4), d0		| character to print
	movew	sr, sp@-
	oriw	#0x700, sr		| disable all interrupts
	movel	#0xFFFF8800, a0
	moveb	#15, a0@		| select port B
	moveb	d0, a0@(2)		| and write the character
	moveb	#14, a0@		| select port A
	moveb	a0@, d0			| read it
	bclr	#5, d0
	moveb	d0, a0@(2)		| strobe low
	nop
	nop
	bset	#5, d0
	moveb	d0, a0@(2)		| strobe high
	movew	sp@+, sr
	rts

| Utility functions to modify the interrupt mask. They'll be used
| only if the NO_INLINE macro is defined.

.globl _spl7, _spl

_spl7:
	movew	sr, d0
	oriw	#0x700, sr
	rts

_spl:
	movew	sp@(4), sr
	rts

