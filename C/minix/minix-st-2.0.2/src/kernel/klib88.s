#
#include <minix/config.h>
#include <minix/const.h>
#include "const.h"
#include "sconst.h"
#include "protect.h"

! This file contains a number of assembly code utility routines needed by the
! kernel.  They are:

.define	_monitor	! exit Minix and return to the monitor
.define	_int86		! make an 8086 interrupt call
.define real2prot	! switch from real to protected mode
.define prot2real	! switch from protected to real mode
.define	_cp_mess	! copies messages from source to destination
.define	_exit		! dummy for library routines
.define	__exit		! dummy for library routines
.define	___exit		! dummy for library routines
.define	.fat, .trp	! dummies for library routines
.define	_in_byte	! read a byte from a port and return it
.define	_in_word	! read a word from a port and return it
.define	_out_byte	! write a byte to a port
.define	_out_word	! write a word to a port
.define	_port_read	! transfer data from (disk controller) port to memory
.define	_port_read_byte	! likewise byte by byte
.define	_port_write	! transfer data from memory to (disk controller) port
.define	_port_write_byte ! likewise byte by byte
.define	_lock		! disable interrupts
.define	_unlock		! enable interrupts
.define	_enable_irq	! enable an irq at the 8259 controller
.define	_disable_irq	! disable an irq
.define	_phys_copy	! copy data from anywhere to anywhere in memory
.define	_mem_rdw	! copy one word from [segment:offset]
.define	_reset		! reset the system
.define	_mem_vid_copy	! copy data to video ram
.define	_vid_vid_copy	! move data in video ram
.define	_level0		! call a function at level 0
.define	klib_init_prot	! initialize klib functions for protected mode

! The routines only guarantee to preserve the registers the C compiler
! expects to be preserved (si, di, bp, sp, segment registers, and direction
! bit in the flags), though some of the older ones preserve bx, cx and dx.

#define DS_286_OFFSET	DS_286_INDEX*DESC_SIZE
#define ES_286_OFFSET	ES_286_INDEX*DESC_SIZE
#	define EM_XFER_FUNC	0x87
#define JMP_OPCODE	0xE9	/* opcode used for patching */
#define OFF_MASK	0x000F	/* offset mask for phys_b -> hclick:offset */
#define HCHIGH_MASK	0x0F	/* h/w click mask for low byte of hi word */
#define HCLOW_MASK	0xF0	/* h/w click mask for low byte of low word */

! Imported functions

.extern	p_restart
.extern	p_save
.extern	_restart
.extern	save

! Exported variables

.extern kernel_cs

! Imported variables

.extern kernel_ds
.extern _irq_use
.extern	_blank_color
.extern	_gdt
.extern	_protected_mode
.extern	_vid_seg
.extern	_vid_size
.extern	_vid_mask
.extern	_level0_func
.extern	_ps_mca

	.text
!*===========================================================================*
!*				monitor					     *
!*===========================================================================*
! PUBLIC void monitor();
! Return to the monitor.

_monitor:
	call	prot2real		! switch to real mode
	mov	ax, _reboot_code+0	! address of new parameters
	mov	dx, _reboot_code+2
	mov	sp, _mon_sp		! restore monitor stack pointer
	mov	bx, _mon_ss		! monitor data segment
	mov	ds, bx
	mov	es, bx
	mov	ss, bx
	pop	di
	pop	si
	pop	bp
	retf				! return to the monitor


!*===========================================================================*
!*				int86					     *
!*===========================================================================*
! PUBLIC void int86();
_int86:				! make an 8086 interrupt call.
	push	bp
	push	si
	push	di		! save C variable registers
	pushf			! save flags

	call	int86		! make the actual call

	popf			! restore flags
	pop	di		! restore C registers
	pop	si
	pop	bp
	ret

! Do an 8086 interrupt from protected mode
p_int86:
	push	bp
	push	si
	push	di			! save C variable registers
	pushf				! save flags

	cli				! no interruptions
	inb	INT2_CTLMASK
	movb	ah, al
	inb	INT_CTLMASK
	push	ax			! save interrupt masks
	mov	ax, _irq_use		! map of in-use IRQs
	and	ax, #~[1<<CLOCK_IRQ]	! keep the clock ticking
	outb	INT_CTLMASK		! enable all unused IRQs and vv.
	movb	al, ah
	outb	INT2_CTLMASK

	call	prot2real		! switch to real mode

	xor	ax, ax
	mov	es, ax			! vector & BIOS data segments
   eseg	mov	0x046C, ax		! clear BIOS clock counter
   eseg	mov	0x046E, ax

	sti				! enable interrupts
	call	int86			! make the actual call
	cli				! disable interrupts

	xor	ax, ax
	mov	es, ax
   eseg	mov	ax, 0x046C
	add	_lost_ticks, ax		! record lost clock ticks

	call	real2prot		! back to protected mode

	pop	ax			! restore interrupt masks
	outb	INT_CTLMASK
	movb	al, ah
	outb	INT2_CTLMASK

	popf				! restore flags
	pop	di			! restore C registers
	pop	si
	pop	bp
	ret

int86:
	mov	bp, #_reg86	! address of parameter block
	movb	al, #0xCD	! INT instruction
	movb	ah, (bp)	! Interrupt number?
	testb	ah, ah
	jnz	0f		! nonzero if INT, otherwise far call
	push	cs
	push	#intret+2	! far return address
	push	6(bp)
	push	4(bp)		! far driver address
	mov	ax, #0x90CB	! RETF; NOP
0: cseg	mov	intret, ax	! patch `INT n` or `RETF; NOP` into code
	jmp	.+2		! clear instruction queue

	mov	ds, 8(bp)	! Load parameters
	mov	es, 10(bp)
	mov	ax, 12(bp)	! (sorry, only ax set, not eax)
	mov	bx, 16(bp)
	mov	cx, 20(bp)
	mov	dx, 24(bp)
	mov	si, 28(bp)
	mov	di, 32(bp)
	mov	bp, 36(bp)

intret:	int	0xFF		! do the interrupt or far call

	push	bp
	pushf
	mov	bp, #_reg86	! address of parameter block
	pop	(bp)		! eflags
	mov	8(bp), ds
	mov	10(bp), es
	mov	12(bp), ax
	mov	16(bp), bx
	mov	20(bp), cx
	mov	24(bp), dx
	mov	28(bp), si
	mov	32(bp), di
	pop	36(bp)		! bp

	mov	ax, ss
	mov	ds, ax		! restore ds and es
	mov	es, ax
	ret


!*===========================================================================*
!*				real2prot				     *
!*===========================================================================*
! Switch from real to protected mode.
real2prot:
	lgdt	_gdt+GDT_SELECTOR	! set global descriptor table
	smsw	ax
	mov	msw, ax			! save real mode msw
	orb	al, #0x01		! set PE (protection enable) bit
	lmsw	ax			! set msw, enabling protected mode

	jmpf	csinit, CS_SELECTOR	! set code segment selector
csinit:
	mov	ax, #DS_SELECTOR	! set data selectors
	mov	ds, ax
	mov	es, ax
	mov	ss, ax
	lidt    _gdt+IDT_SELECTOR	! set interrupt vectors
	andb	_gdt+TSS_SELECTOR+DESC_ACCESS, #~0x02  ! clear TSS busy bit
	mov	ax, #TSS_SELECTOR
	ltr	ax			! set TSS register

	movb	ah, #0x02
	jmp	gate_A20		! enable the A20 address line


!*===========================================================================*
!*				prot2real				     *
!*===========================================================================*
! Switch from protected to real mode.
prot2real:
	mov	save_sp, sp		! save stack pointer
	cmp	_processor, #386	! is this a 386?
	jae	p2r386
p2r286:
	mov	_gdt+ES_286_OFFSET+DESC_BASE, #0x0000
	movb	_gdt+ES_286_OFFSET+DESC_BASE_MIDDLE, #0x00
	mov	ax, #ES_286_SELECTOR
	mov	es, ax			! BIOS data segment
  eseg	mov	0x0467, #real		! set return from shutdown address
  cseg	mov	ax, kernel_cs
  eseg	mov	0x0469, ax
	movb	al, #0x8F
	outb	0x70			! select CMOS byte 0x0F (disable NMI)
	jmp	.+2
	movb	al, #0x0A
	outb	0x71			! set shutdown code to 0x0A "jump far"
	jmp	p_reset			! cause a processor shutdown
p2r386:
	lidt	idt_vectors		! real mode interrupt vectors
	push	_gdt+CS_SELECTOR+0
	push	_gdt+DS_SELECTOR+0	! save CS and DS limits
	mov	_gdt+CS_SELECTOR+0, #0xFFFF
	mov	_gdt+DS_SELECTOR+0, #0xFFFF ! set 64k limits
	jmpf	cs64k, CS_SELECTOR	! reload selectors
cs64k:	mov	ax, #DS_SELECTOR
	mov	ds, ax
	mov	es, ax
	mov	ss, ax
	pop	_gdt+DS_SELECTOR+0
	pop	_gdt+CS_SELECTOR+0	! restore CS and DS limits
	.data1	0x0F,0x20,0xC0		! mov	eax, cr0
	mov	ax, msw			! restore real mode (16 bits) msw
	.data1	0x0F,0x22,0xC0		! mov	cr0, eax
	.data1	0xEA			! jmpf real, "kernel_cs"
	.data2	real
kernel_cs:
	.data2	0
real:
  cseg	mov	ax, kernel_ds		! reload data segment registers
	mov	ds, ax
	mov	es, ax
	mov	ss, ax
	mov	sp, save_sp		! restore stack

	xorb	ah, ah
	!jmp	gate_A20		! disable the A20 address line

! Enable (ah = 0x02) or disable (ah = 0x00) the A20 address line.
gate_A20:
	cmp	_ps_mca, #0	! PS/2 bus?
	jnz	gate_PS_A20
	call	kb_wait
	movb	al, #0xD1	! Tell keyboard that a command is coming
	outb	0x64
	call	kb_wait
	movb	al, #0xDD	! 0xDD = A20 disable code if ah = 0x00
	orb	al, ah		! 0xDF = A20 enable code if ah = 0x02
	outb	0x60
	call	kb_wait
	movb	al, #0xFF	! Pulse output port
	outb	0x64
	call	kb_wait		! Wait for the A20 line to settle down
	ret
kb_wait:
	inb	0x64
	testb	al, #0x02	! Keyboard input buffer full?
	jnz	kb_wait		! If so, wait
	ret

gate_PS_A20:		! The PS/2 can twiddle A20 using port A
	inb	0x92		! Read port A
	andb	al, #0xFD
	orb	al, ah		! Set A20 bit to the required state
	outb	0x92		! Write port A
	jmp	.+2		! Small delay
A20ok:	inb	0x92		! Check port A
	andb	al, #0x02
	cmpb	al, ah		! A20 line settled down to the new state?
	jne	A20ok		! If not then wait
	ret


!*===========================================================================*
!*				cp_mess					     *
!*===========================================================================*
! PUBLIC void cp_mess(int src, phys_clicks src_clicks, vir_bytes src_offset,
!		      phys_clicks dst_clicks, vir_bytes dst_offset);
! This routine makes a fast copy of a message from anywhere in the address
! space to anywhere else.  It also copies the source address provided as a
! parameter to the call into the first word of the destination message.
!
! Note that the message size, "Msize" is in WORDS (not bytes) and must be set
! correctly.  Changing the definition of message in the type file and not
! changing it here will lead to total disaster.

_cp_mess:
	cld
	push es			! save es
	push ds			! save ds
	mov bx,sp		! index off bx because machine cannot use sp
	push si			! save si
	push di			! save di

	mov	ax,12(bx)	! destination click
#if HCLICK_SHIFT > CLICK_SHIFT
#error /* Small click sizes are not supported (right shift will lose bits). */
#endif
#if HCLICK_SHIFT < CLICK_SHIFT
	movb	cl,#CLICK_SHIFT-HCLICK_SHIFT
	shl	ax,cl		! destination segment
#endif
	mov	es,ax
	mov	di,14(bx)	! offset of destination message

! Be careful not to destroy ds before we are finished with the bx pointer.
! We are using bx and not the more natural bp to save pushing bp.

	mov	ax,6(bx)	! process number of sender
	mov	si,10(bx)	! offset of source message
	mov	bx,8(bx)	! source click (finished with bx as a pointer)
#if HCLICK_SHIFT < CLICK_SHIFT
	shl	bx,cl		! source segment
#endif
	mov	ds,bx

	stos			! copy process number of sender to dest message
	add si,*2		! do not copy first word
	mov cx,*Msize-1		! remember, first word does not count
	rep			! iterate cx times to copy 11 words
	movs			! copy the message
	pop di			! restore di
	pop si			! restore si
	pop ds			! restore ds
	pop es			! restore es
	ret			! that is all folks!


!*===========================================================================*
!*				exit					     *
!*===========================================================================*
! PUBLIC void exit();
! Some library routines use exit, so provide a dummy version.
! Actual calls to exit cannot occur in the kernel.
! Same for .fat & .trp.

_exit:
__exit:
___exit:
.fat:
.trp:
	sti
	jmp __exit


!*===========================================================================*
!*				in_byte					     *
!*===========================================================================*
! PUBLIC unsigned in_byte(port_t port);
! Read an (unsigned) byte from the i/o port  port  and return it.

_in_byte:
	pop	bx
	pop	dx		! port
	dec	sp
	dec	sp
	inb			! input 1 byte
	subb	ah,ah		! unsign extend
	jmp	(bx)


!*===========================================================================*
!*				in_word					     *
!*===========================================================================*
! PUBLIC unsigned short in_word(port_t port);
! Read an (unsigned) word from the i/o port and return it.

_in_word:
	pop	bx
	pop	dx		! port
	dec	sp
	dec	sp		! added to new klib.s 3/21/91 d.e.c.
	inw			! input 1 word no sign extend needed
	jmp	(bx)


!*===========================================================================*
!*				out_byte				     *
!*===========================================================================*
! PUBLIC void out_byte(port_t port, int value);
! Write  value  (cast to a byte)  to the I/O port  port.

_out_byte:
	pop	bx
	pop	dx		! port
	pop	ax		! value
	sub	sp,#2+2
	outb			! output 1 byte
	jmp	(bx)


!*===========================================================================*
!*				out_word				     *
!*===========================================================================*
! PUBLIC void out_word(port_t port, int value);
! Write  value  (cast to a word)  to the I/O port  port.

_out_word:
	pop	bx
	pop	dx		! port
	pop	ax		! value
	sub	sp,#2+2
	outw			! output 1 word
	jmp	(bx)


!*===========================================================================*
!*				port_read				     *
!*===========================================================================*
! PUBLIC void port_read(port_t port, phys_bytes destination,unsigned bytcount);
! Transfer data from (hard disk controller) port to memory.

_port_read:
	push	bp
	mov	bp,sp
	push	di
	push	es

	call	portio_setup
	shr	cx,#1		! count in words
	mov	di,bx		! di = destination offset
	mov	es,ax		! es = destination segment
	rep
	ins

	pop	es
	pop	di
	pop	bp
	ret

portio_setup:
	mov	ax,4+2(bp)	! source/destination address in dx:ax
	mov	dx,4+2+2(bp)
	mov	bx,ax
	and	bx,#OFF_MASK	! bx = offset = address % 16
	andb	dl,#HCHIGH_MASK	! ax = segment = address / 16 % 0x10000
	andb	al,#HCLOW_MASK
	orb	al,dl
	movb	cl,#HCLICK_SHIFT
	ror	ax,cl
	mov	cx,4+2+4(bp)	! count in bytes
	mov	dx,4(bp)	! port to read from
	cld			! direction is UP
	ret


!*===========================================================================*
!*				port_read_byte				     *
!*===========================================================================*
! PUBLIC void port_read_byte(port_t port, phys_bytes destination,
!							unsigned bytcount);
! Transfer data port to memory.

_port_read_byte:
	push	bp
	mov	bp,sp
	push	di
	push	es

	call	portio_setup
	mov	di,bx		! di = destination offset
	mov	es,ax		! es = destination segment
	rep
	insb

	pop	es
	pop	di
	pop	bp
	ret


!*===========================================================================*
!*				port_write				     *
!*===========================================================================*
! PUBLIC void port_write(port_t port, phys_bytes source, unsigned bytcount);
! Transfer data from memory to (hard disk controller) port.

_port_write:
	push	bp
	mov	bp,sp
	push	si
	push	ds

	call	portio_setup
	shr	cx,#1		! count in words
	mov	si,bx		! si = source offset
	mov	ds,ax		! ds = source segment
	rep
	outs

	pop	ds
	pop	si
	pop	bp
	ret


!*===========================================================================*
!*				port_write_byte				     *
!*===========================================================================*
! PUBLIC void port_write_byte(port_t port, phys_bytes source,
!							unsigned bytcount);
! Transfer data from memory to port.

_port_write_byte:
	push	bp
	mov	bp,sp
	push	si
	push	ds

	call	portio_setup
	mov	si,bx		! si = source offset
	mov	ds,ax		! ds = source segment
	rep
	outsb

	pop	ds
	pop	si
	pop	bp
	ret


!*===========================================================================*
!*				lock					     *
!*===========================================================================*
! PUBLIC void lock();
! Disable CPU interrupts.

_lock:
	cli				! disable interrupts
	ret


!*===========================================================================*
!*				unlock					     *
!*===========================================================================*
! PUBLIC void unlock();
! Enable CPU interrupts.

_unlock:
	sti
	ret


!*==========================================================================*
!*				enable_irq				    *
!*==========================================================================*/
! PUBLIC void enable_irq(unsigned irq)
! Enable an interrupt request line by clearing an 8259 bit.
! Equivalent code for irq < 8:
!	out_byte(INT_CTLMASK, in_byte(INT_CTLMASK) & ~(1 << irq));

_enable_irq:
	mov	bx, sp
	mov	cx, 2(bx)		! irq
	pushf
	cli
	movb	ah, #~1
	rolb	ah, cl			! ah = ~(1 << (irq % 8))
	cmpb	cl, #8
	jae	enable_8		! enable irq >= 8 at the slave 8259
enable_0:
	inb	INT_CTLMASK
	andb	al, ah
	outb	INT_CTLMASK		! clear bit at master 8259
	popf
	ret
enable_8:
	inb	INT2_CTLMASK
	andb	al, ah
	outb	INT2_CTLMASK		! clear bit at slave 8259
	popf
	ret


!*==========================================================================*
!*				disable_irq				    *
!*==========================================================================*/
! PUBLIC int disable_irq(unsigned irq)
! Disable an interrupt request line by setting an 8259 bit.
! Equivalent code for irq < 8:
!	out_byte(INT_CTLMASK, in_byte(INT_CTLMASK) | (1 << irq));
! Returns true iff the interrupt was not already disabled.

_disable_irq:
	mov	bx, sp
	mov	cx, 2(bx)		! irq
	pushf
	cli
	movb	ah, #1
	rolb	ah, cl			! ah = (1 << (irq % 8))
	cmpb	cl, #8
	jae	disable_8		! disable irq >= 8 at the slave 8259
disable_0:
	inb	INT_CTLMASK
	testb	al, ah
	jnz	dis_already		! already disabled?
	orb	al, ah
	outb	INT_CTLMASK		! set bit at master 8259
	popf
	mov	ax, #1			! disabled by this function
	ret
disable_8:
	inb	INT2_CTLMASK
	testb	al, ah
	jnz	dis_already		! already disabled?
	orb	al, ah
	outb	INT2_CTLMASK		! set bit at slave 8259
	popf
	mov	ax, #1			! disabled by this function
	ret
dis_already:
	popf
	xor	ax, ax			! already disabled
	ret


!*===========================================================================*
!*				phys_copy				     *
!*===========================================================================*
! PUBLIC void phys_copy(phys_bytes source, phys_bytes destination,
!			phys_bytes bytecount);
! Copy a block of physical memory.

SRCLO	=	4
SRCHI	=	6
DESTLO	=	8
DESTHI	=	10
COUNTLO	=	12
COUNTHI	=	14

_phys_copy:
	push	bp		! save only registers required by C
	mov	bp,sp		! set bp to point to source arg less 4

	push	si		! save si
	push	di		! save di
	push	ds		! save ds
	push	es		! save es

	mov	ax,SRCLO(bp)	! dx:ax = source address (dx is NOT segment)
	mov	dx,SRCHI(bp)
	mov	si,ax		! si = source offset = address % 16
	and	si,#OFF_MASK
	andb	dl,#HCHIGH_MASK	! ds = source segment = address / 16 % 0x10000
	andb	al,#HCLOW_MASK
	orb	al,dl		! now bottom 4 bits of dx are in ax
	movb	cl,#HCLICK_SHIFT ! rotate them to the top 4
	ror	ax,cl
	mov	ds,ax

	mov	ax,DESTLO(bp)	! dx:ax = destination addr (dx is NOT segment)
	mov	dx,DESTHI(bp)
	mov	di,ax		! di = dest offset = address % 16
	and	di,#OFF_MASK
	andb	dl,#HCHIGH_MASK	! es = dest segment = address / 16 % 0x10000
	andb	al,#HCLOW_MASK
	orb	al,dl
	ror	ax,cl
	mov	es,ax

	mov	ax,COUNTLO(bp)	! dx:ax = remaining count
	mov	dx,COUNTHI(bp)

! copy upwards (cannot handle overlapped copy)

pc_loop:
	mov	cx,ax		! provisional count for this iteration
	test	ax,ax		! if count >= 0x8000, only do 0x8000 per iter
	js	pc_bigcount	! low byte already >= 0x8000
	test	dx,dx
	jz	pc_upcount	! less than 0x8000
pc_bigcount:
	mov	cx,#0x8000	! use maximum count per iteration
pc_upcount:
	sub	ax,cx		! update count
	sbb	dx,#0		! cannot underflow, so carry clear now for rcr
	rcr	cx,#1		! count in words, carry remembers if byte
	jnb	pc_even		! no odd byte
	movb			! copy odd byte
pc_even:
	rep			! copy 1 word at a time
	movs			! word copy

	mov	cx,ax		! test if remaining count is 0
	or	cx,dx
	jnz	pc_more		! more to do

	pop	es		! restore es
	pop	ds		! restore ds
	pop	di		! restore di
	pop	si		! restore si
	pop	bp		! restore bp
	ret			! return to caller

pc_more:
	sub	si,#0x8000	! adjust pointers so the offset does not
	mov	cx,ds		! overflow in the next 0x8000 bytes
	add	cx,#0x800	! pointers end up same physical location
	mov	ds,cx		! the current offsets are known >= 0x8000
	sub	di,#0x8000	! since we just copied that many
	mov	cx,es
	add	cx,#0x800
	mov	es,cx
	jmp	pc_loop		! start next iteration


!*===========================================================================*
!*				mem_rdw					     *
!*===========================================================================*
! PUBLIC u16_t mem_rdw(u16_t segment, u16_t *offset);
! Load and return the word at the far pointer  segment:offset.

_mem_rdw:
	mov	cx,ds		! save ds
	pop	dx		! return adr
	pop	ds		! segment
	pop	bx		! offset
	sub	sp,#2+2		! adjust for parameters popped
	mov	ax,(bx)		! load the word to return
	mov	ds,cx		! restore ds
	jmp	(dx)		! return


!*===========================================================================*
!*				reset					     *
!*===========================================================================*
! PUBLIC void reset();
! Reset the system.
! In real mode we simply jump to the reset address at F000:FFF0.

_reset:
	jmpf	0xFFF0,0xF000


!*===========================================================================*
!*				mem_vid_copy				     *
!*===========================================================================*
! PUBLIC void mem_vid_copy(u16 *src, unsigned dst, unsigned count);
!
! Copy count characters from kernel memory to video memory.  Src, dst and
! count are character (word) based video offsets and counts.  If src is null
! then screen memory is blanked by filling it with blank_color.

MVC_ARGS	=	2 + 2 + 2 + 2	! 2 + 2 + 2
!			es  di  si  ip	 src dst ct

_mem_vid_copy:
	push	si
	push	di
	push	es
	mov	bx, sp
	mov	si, MVC_ARGS(bx)	! source
	mov	di, MVC_ARGS+2(bx)	! destination
	mov	dx, MVC_ARGS+2+2(bx)	! count
	mov	es, _vid_seg		! destination is video segment
	cld				! make sure direction is up
mvc_loop:
	and	di, _vid_mask		! wrap address
	mov	cx, dx			! one chunk to copy
	mov	ax, _vid_size
	sub	ax, di
	cmp	cx, ax
	jbe	0f
	mov	cx, ax			! cx = min(cx, vid_size - di)
0:	sub	dx, cx			! count -= cx
	shl	di, #1			! byte address
	test	si, si			! source == 0 means blank the screen
	jz	mvc_blank
mvc_copy:
	rep				! copy words to video memory
	movs
	jmp	mvc_test
mvc_blank:
	mov	ax, _blank_color	! ax = blanking character
	rep
	stos				! copy blanks to video memory
	!jmp	mvc_test
mvc_test:
	shr	di, #1			! word addresses
	test	dx, dx
	jnz	mvc_loop
mvc_done:
	pop	es
	pop	di
	pop	si
	ret


!*===========================================================================*
!*				vid_vid_copy				     *
!*===========================================================================*
! PUBLIC void vid_vid_copy(unsigned src, unsigned dst, unsigned count);
!
! Copy count characters from video memory to video memory.  Handle overlap.
! Used for scrolling, line or character insertion and deletion.  Src, dst
! and count are character (word) based video offsets and counts.

VVC_ARGS	=	2 + 2 + 2 + 2	! 2 + 2 + 2
!			es  di  si  ip 	 src dst ct

_vid_vid_copy:
	push	si
	push	di
	push	es
	mov	bx, sp
	mov	si, VVC_ARGS(bx)	! source
	mov	di, VVC_ARGS+2(bx)	! destination
	mov	dx, VVC_ARGS+2+2(bx)	! count
	mov	es, _vid_seg		! use video segment
	cmp	si, di			! copy up or down?
	jb	vvc_down
vvc_up:
	cld				! direction is up
vvc_uploop:
	and	si, _vid_mask		! wrap addresses
	and	di, _vid_mask
	mov	cx, dx			! one chunk to copy
	mov	ax, _vid_size
	sub	ax, si
	cmp	cx, ax
	jbe	0f
	mov	cx, ax			! cx = min(cx, vid_size - si)
0:	mov	ax, _vid_size
	sub	ax, di
	cmp	cx, ax
	jbe	0f
	mov	cx, ax			! cx = min(cx, vid_size - di)
0:	sub	dx, cx			! count -= cx
	shl	si, #1
	shl	di, #1			! byte addresses
	rep
   eseg movs				! copy video words
	shr	si, #1
	shr	di, #1			! word addresses
	test	dx, dx
	jnz	vvc_uploop		! again?
	jmp	vvc_done
vvc_down:
	std				! direction is down
	add	si, dx			! start copying at the top
	dec	si
	add	di, dx
	dec	di
vvc_downloop:
	and	si, _vid_mask		! wrap addresses
	and	di, _vid_mask
	mov	cx, dx			! one chunk to copy
	lea	ax, 1(si)
	cmp	cx, ax
	jbe	0f
	mov	cx, ax			! cx = min(cx, si + 1)
0:	lea	ax, 1(di)
	cmp	cx, ax
	jbe	0f
	mov	cx, ax			! cx = min(cx, di + 1)
0:	sub	dx, cx			! count -= cx
	shl	si, #1
	shl	di, #1			! byte addresses
	rep
   eseg	movs				! copy video words
	shr	si, #1
	shr	di, #1			! word addresses
	test	dx, dx
	jnz	vvc_downloop		! again?
	cld				! C compiler expect up
	!jmp	vvc_done
vvc_done:
	pop	es
	pop	di
	pop	si
	ret


!*===========================================================================*
!*			      level0					     *
!*===========================================================================*
! PUBLIC void level0(void (*func)(void))
! Not very interesting in real mode, see p_level0.
!
_level0:
	mov	bx, sp
	jmp	@2(bx)


!*===========================================================================*
!*				klib_init_prot				     *
!*===========================================================================*
! PUBLIC void klib_init_prot();
! Initialize klib for protected mode by patching some real mode functions
! at their starts to jump to their protected mode equivalents, according to
! the patch table.  Saves a lot of tests on the "protected_mode" variable.
! Note that this function must be run in real mode, for it writes the code
! segment.  (One otherwise has to set up a descriptor, etc, etc.)

klib_init_prot:
	mov	si,#patch_table
kip_next:
	lods			! original function
	mov	bx,ax
  cseg	movb	(bx),#JMP_OPCODE ! overwrite start of function by a long jump
	lods			! new function - target of jump
	sub	ax,bx		! relative jump
	sub	ax,#3		! adjust by length of jump instruction
  cseg	mov	1(bx),ax	! set address
	cmp	si,#end_patch_table ! end of table?
	jb	kip_next
kip_done:
	ret


!*===========================================================================*
!*			variants for protected mode			     *
!*===========================================================================*
! Some routines are different in protected mode.
! The only essential difference is the handling of segment registers.
! One complication is that the method of building segment descriptors is not
! reentrant, so the protected mode versions must not be called by interrupt
! handlers.


!*===========================================================================*
!*				p_cp_mess				     *
!*===========================================================================*
! The real mode version attempts to be efficient by passing raw segments but
! that just gets in the way here.

p_cp_mess:
	cld
	pop	dx
	pop	bx		! proc
	pop	cx		! source clicks
	pop	ax		! source offset
#if CLICK_SHIFT != HCLICK_SHIFT + 4
#error /* the only click size supported is 256, to avoid slow shifts here */
#endif
	addb	ah,cl		! calculate source offset
	adcb	ch,#0		! and put in base of source descriptor
	mov	_gdt+DS_286_OFFSET+DESC_BASE,ax
	movb	_gdt+DS_286_OFFSET+DESC_BASE_MIDDLE,ch
	pop	cx		! destination clicks
	pop	ax		! destination offset
	addb	ah,cl		! calculate destination offset
	adcb	ch,#0		! and put in base of destination descriptor
	mov	_gdt+ES_286_OFFSET+DESC_BASE,ax
	movb	_gdt+ES_286_OFFSET+DESC_BASE_MIDDLE,ch
	sub	sp,#2+2+2+2+2

	push	ds
	push	es
	mov	ax,#DS_286_SELECTOR
	mov	ds,ax
	mov	ax,#ES_286_SELECTOR
	mov	es,ax

  eseg	mov	0,bx		! proc no. of sender from arg, not msg
	mov	ax,si
	mov	bx,di
	mov	si,#2		! src offset is now 2 relative to start of seg
	mov	di,si		! and destination offset
	mov	cx,#Msize-1	! word count
	rep
	movs
	mov	di,bx
	mov	si,ax
	pop	es
	pop	ds
	jmp	(dx)


!*===========================================================================*
!*				p_portio_setup				     *
!*===========================================================================*
! The port_read, port_write, etc. functions need a setup routine that uses
! a segment descriptor.
p_portio_setup:
	mov	ax,4+2(bp)	! source/destination address in dx:ax
	mov	dx,4+2+2(bp)
	mov	_gdt+DS_286_OFFSET+DESC_BASE,ax
	movb	_gdt+DS_286_OFFSET+DESC_BASE_MIDDLE,dl
	xor	bx,bx		! bx = 0 = start of segment
	mov	ax,#DS_286_SELECTOR ! ax = segment selector
	mov	cx,4+2+4(bp)	! count in bytes
	mov	dx,4(bp)	! port to read from
	cld			! direction is UP
	ret


!*===========================================================================*
!*				p_phys_copy				     *
!*===========================================================================*
p_phys_copy:
	cld
	pop	dx
	pop	_gdt+DS_286_OFFSET+DESC_BASE
	pop	ax		! pop source into base of source descriptor
	movb	_gdt+DS_286_OFFSET+DESC_BASE_MIDDLE,al
	pop	_gdt+ES_286_OFFSET+DESC_BASE
	pop	ax		! pop destination into base of dst descriptor
	movb	_gdt+ES_286_OFFSET+DESC_BASE_MIDDLE,al
	pop	cx		! byte count in bx:cx
	pop	bx
	sub	sp,#4+4+4

	push	di
	push	si
	push	es
	push	ds
	sub	si,si		! src offset is now 0 relative to start of seg
	mov	di,si		! and destination offset
	jmp	ppc_next

! It is too much trouble to align the segment bases, so word alignment is hard.
! Avoiding the book-keeping for alignment may be good anyway.

ppc_large:
	push	cx
	mov	cx,#0x8000	! copy a large chunk of this many words
	rep
	movs
	pop	cx
	dec	bx
	pop	ds		! update the descriptors
	incb	_gdt+DS_286_OFFSET+DESC_BASE_MIDDLE
	incb	_gdt+ES_286_OFFSET+DESC_BASE_MIDDLE
	push	ds
ppc_next:
	mov	ax,#DS_286_SELECTOR	! (re)load the selectors
	mov	ds,ax
	mov	ax,#ES_286_SELECTOR
	mov	es,ax
	test	bx,bx
	jnz	ppc_large

	shr	cx,#1		! word count
	rep
	movs			! move any leftover words
	rcl	cx,#1		! restore old bit 0
	rep
	movb			! move any leftover byte
	pop	ds
	pop	es
	pop	si
	pop	di
	jmp	(dx)

!*===========================================================================*
!*				p_reset					     *
!*===========================================================================*
! Reset the system by loading IDT with offset 0 and interrupting.

p_reset:
	lidt	idt_zero
	int	3		! anything goes, the 286 will not like it


!*===========================================================================*
!*				p_level0				     *
!*===========================================================================*
! PUBLIC void level0(void (*func)(void))
! Call a function at permission level 0.  This allows kernel tasks to do
! things that are only possible at the most privileged CPU level.
!
p_level0:
	mov	bx, sp
	mov	ax, 2(bx)
	mov	_level0_func, ax
	int	LEVEL0_VECTOR
	ret


!*===========================================================================*
!*				data					     *
!*===========================================================================*
	.data
patch_table:			! pairs (old function, new function)
	.data2	_int86, p_int86
	.data2	_cp_mess, p_cp_mess
	.data2	_phys_copy, p_phys_copy
	.data2	portio_setup, p_portio_setup
	.data2	_reset, p_reset
	.data2	_level0, p_level0
	.data2	_restart, p_restart	! in mpx file
	.data2	save, p_save	! in mpx file
end_patch_table:		! end of table

idt_vectors:			! limit and base of real mode interrupt vectors
	.data2	0x3FF
idt_zero:			! zero limit IDT to cause a processor shutdown
	.data2	0, 0, 0

	.bss
save_sp:			! place to put sp when switching to real mode
	.space	2
msw:				! saved real mode machine status word
	.space	2
