|
|	Assembly language stuff for MiNT-Net, mostly for setting
|	interrupt level.
|
|	10/26/93, kay roemer
|

		.globl	_spl7
		.globl	_spl

_spl7:		movew	sr, d0
		oriw	#0x700, sr
		rts

_spl:		movew	sp@(4), sr
		rts
