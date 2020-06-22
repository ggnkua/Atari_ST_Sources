.globl	_is_auto

| Bootup Standard AES Detection
| - code courtesy of Atari World magazine.

_is_auto:
	moveml	d1-d2/a0-a2,SP@-
	movew	#0xc9,d0
	trap	#2
	cmpw	#0xc9,d0		|if d0==$c9, we already have an AES loaded so return false
	beq	label1
	moveq	#0,d0
	bra	label2

label1:
	moveq	#1,d0		|no AES, must be in the auto folder of MiNT.CNF
label2:
	moveml	SP@+,d1-d2/a0-a2
	rts
