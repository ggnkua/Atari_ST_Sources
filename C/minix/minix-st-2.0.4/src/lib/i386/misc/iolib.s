! Some I/O related routines like:
!	unsigned char inb(int port);
!	unsigned short inw(int port);
!	void outb(int port, int value);
!	void outw(int port, int value);
!	void rep_inb(int port, unsigned char *buf, size_t count);
!	void rep_inw(int port, unsigned short *buf, size_t count);
!	void rep_outb(int port, unsigned char *buf, size_t count);
!	void rep_outw(int port, unsigned short *buf, size_t count);
!	void intr_enable(void);
!	void intr_disable(void);

.sect .text; .sect .rom; .sect .data; .sect .bss

.sect .text
.define _inb
_inb:
	push	ebp
	mov	ebp, esp
	mov	edx, 8(ebp)		! port
	xor	eax, eax
	inb	dx			! read 1 byte
	pop	ebp
	ret

.define _inw
_inw:
	push	ebp
	mov	ebp, esp
	mov	edx, 8(ebp)		! port
	xor	eax, eax
    o16	in	dx			! read 1 word
	pop	ebp
	ret

.define _outb
_outb:
	push	ebp
	mov	ebp, esp
	mov	edx, 8(ebp)		! port
	mov	eax, 8+4(ebp)		! value
	outb	dx			! output 1 byte
	pop	ebp
	ret

.define _outw
_outw:
	push	ebp
	mov	ebp, esp
	mov	edx, 8(ebp)		! port
	mov	eax, 8+4(ebp)		! value
    o16	out	dx			! output 1 word
	pop	ebp
	ret

.define _rep_inb
_rep_inb:
	push	ebp
	mov	ebp, esp
	push	edi
	mov	edx, 8(ebp)		! port
	mov	edi, 12(ebp)		! buf
	mov	ecx, 16(ebp)		! byte count
	rep
	inb	dx			! input many bytes
	pop	edi
	pop	ebp
	ret

.define _rep_inw
_rep_inw:
	push	ebp
	mov	ebp, esp
	push	edi
	mov	edx, 8(ebp)		! port
	mov	edi, 12(ebp)		! buf
	mov	ecx, 16(ebp)		! byte count
	shr	ecx, 1			! word count
	rep
    o16	in	dx			! input many words
	pop	edi
	pop	ebp
	ret

.define _rep_outb
_rep_outb:
	push	ebp
	mov	ebp, esp
	push	esi
	mov	edx, 8(ebp)		! port
	mov	esi, 12(ebp)		! buf
	mov	ecx, 16(ebp)		! byte count
	rep
	outb	dx			! output many bytes
	pop	esi
	pop	ebp
	ret

.define _rep_outw
_rep_outw:
	push	ebp
	mov	ebp, esp
	push	esi
	mov	edx, 8(ebp)		! port
	mov	esi, 12(ebp)		! buf
	mov	ecx, 16(ebp)		! byte count
	shr	ecx, 1			! word count
	rep
    o16	out	dx			! output many words
	pop	esi
	pop	ebp
	ret

.define _intr_disable
_intr_disable:
	push	ebp
	mov	ebp, esp
	cli
	pop	ebp
	ret

.define _intr_enable
_intr_enable:
	push	ebp
	mov	ebp, esp
	sti
	pop	ebp
	ret
