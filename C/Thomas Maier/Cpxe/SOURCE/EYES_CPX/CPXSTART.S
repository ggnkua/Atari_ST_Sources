
| startup.s     start up code for cpx

	.globl _cpxstart
	.globl _save_vars
	.globl _cpx_init

	.text
	.even
_cpxstart:
	jmp	_cpx_init

	.data
	.even
_save_vars:
	
	.space	2,0
	


