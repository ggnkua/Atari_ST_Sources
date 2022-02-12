#ifdef __ACK__
.sect .text
.sect .rom
.sect .data
.sect .bss
.define endtext,enddata,endbss,__end
.sect .text
	.align 2
.sect .rom
	.align 2
.sect .data
	.align 2
.sect .bss
	.align 2
.sect .end ! only for declaration of _end, __end and endbss.

	.sect .text
endtext:
	.sect .data
enddata:
	.sect .end
__end:
endbss:
#endif
