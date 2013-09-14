; cpxstart.asm


	.globl	    cpxstart
	.globl	    save_vars
	.globl	    cpx_init

	.text

cpxstart:
   	  jmp cpx_init
	  rts

	.data

save_vars:
		.dc.w	1	; temp
	.end
