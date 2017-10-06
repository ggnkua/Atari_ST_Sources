	.globl _slb_init
	.globl _slb_sprintf

	.text

	.long	0x70004afc	| magic value (clr.l d0, illegal)
	.long	name		| pointer to library's (file)name
	.long	1		| version number
	.long	0		| flags, currently 0L
	.long	_slb_init	| called when the library's been loaded
	.long	_slb_init	| called before the library is removed
	.long	_slb_init	| called when a process opens the library
	.long	_slb_init	| called when a process closes the library
	.long	0		| pointer to function names, optional
	.long	0,0,0,0,0,0,0,0	| unused, always 0L
	.long	1		| number of functions
	.long	_slb_sprintf	

	.data
name:
	.asciz	"sprintf.slb"

	.bss			| 1k stack for SMALLTPA libs
	.ds	512		| (otherwise MagiC refuses to run it)

| EOF
