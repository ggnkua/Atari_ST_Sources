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

.text
.define _inb
_inb:
	push	bp
	mov	bp, sp
	mov	dx, 4(bp)		! port
	inb	dx			! read 1 byte
	xorb	ah, ah
	pop	bp
	ret

.define _inw
_inw:
	push	bp
	mov	bp, sp
	mov	dx, 4(bp)		! port
	in	dx			! read 1 word
	pop	bp
	ret

.define _outb
_outb:
	push	bp
	mov	bp, sp
	mov	dx, 4(bp)		! port
	mov	ax, 4+2(bp)		! value
	outb	dx			! output 1 byte
	pop	bp
	ret

.define _outw
_outw:
	push	bp
	mov	bp, sp
	mov	dx, 4(bp)		! port
	mov	ax, 4+2(bp)		! value
	out	dx			! output 1 word
	pop	bp
	ret

.define _rep_inb
_rep_inb:
	push	bp
	mov	bp, sp
	push	di
	mov	dx, 4(bp)		! port
	mov	di, 6(bp)		! buf
	mov	cx, 8(bp)		! byte count
    rep	inb	dx			! input many bytes
	pop	di
	pop	bp
	ret

.define _rep_inw
_rep_inw:
	push	bp
	mov	bp, sp
	push	di
	mov	dx, 4(bp)		! port
	mov	di, 6(bp)		! buf
	mov	cx, 8(bp)		! byte count
	shr	cx, #1			! word count
    rep	in	dx			! input many words
	pop	di
	pop	bp
	ret

.define _rep_outb
_rep_outb:
	push	bp
	mov	bp, sp
	push	si
	mov	dx, 4(bp)		! port
	mov	si, 6(bp)		! buf
	mov	cx, 8(bp)		! byte count
    rep	outb	dx			! output many bytes
	pop	si
	pop	bp
	ret

.define _rep_outw
_rep_outw:
	push	bp
	mov	bp, sp
	push	si
	mov	dx, 4(bp)		! port
	mov	si, 6(bp)		! buf
	mov	cx, 8(bp)		! byte count
	shr	cx, #1			! word count
    rep	out	dx			! output many words
	pop	si
	pop	bp
	ret

.define _intr_disable
_intr_disable:
	push	bp
	mov	bp, sp
	cli
	pop	bp
	ret

.define _intr_enable
_intr_enable:
	push	bp
	mov	bp, sp
	sti
	pop	bp
	ret
