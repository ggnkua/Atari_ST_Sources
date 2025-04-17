| This short module is used as a 'start up module' for minixfs ,
| it *must* be linked in first , this means that the -fwriteable-strings
| is no longer necessary to get minix_init in the right place as this
| is automatically jumped to. By linking this module in first this is
| guaranteed to be the first instruction.

	.globl _init_addr
_init_addr:
	jmp _minix_init
