#
! sections

.sect .text; .sect .rom; .sect .data; .sect .bss

#include <minix/config.h>
#include <minix/const.h>
#include "const.h"
#include "sconst.h"
#include "protect.h"

! This file contains a number of assembly code utility routines needed by the
! kernel.  They are:

.define	_monitor	! exit Minix and return to the monitor
.define	_int86		! let the monitor make an 8086 interrupt call
.define	_cp_mess	! copies messages from source to destination
.define	_exit		! dummy for library routines
.define	__exit		! dummy for library routines
.define	___exit		! dummy for library routines
.define	___main		! dummy for GCC
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

! The routines only guarantee to preserve the registers the C compiler
! expects to be preserved (ebx, esi, edi, ebp, esp, segment registers, and
! direction bit in the flags).

! imported variables

.sect .bss
.extern	_mon_return, _mon_sp
.extern _irq_use
.extern	_blank_color
.extern	_gdt
.extern	_vid_seg
.extern	_vid_size
.extern	_vid_mask
.extern	_level0_func

.sect .text
!*===========================================================================*
!*				monitor					     *
!*===========================================================================*
! PUBLIC void monitor();
! Return to the monitor.

_monitor:
	mov	eax, (_reboot_code)	! address of new parameters
	mov	esp, (_mon_sp)		! restore monitor stack pointer
    o16 mov	dx, SS_SELECTOR		! monitor data segment
	mov	ds, dx
	mov	es, dx
	mov	fs, dx
	mov	gs, dx
	mov	ss, dx
	pop	edi
	pop	esi
	pop	ebp
    o16 retf				! return to the monitor


!*===========================================================================*
!*				int86					     *
!*===========================================================================*
! PUBLIC void int86();
_int86:
	cmpb	(_mon_return), 0	! is the monitor there?
	jnz	0f
	movb	ah, 0x01		! an int 13 error seems appropriate
	movb	(_reg86+ 0), ah		! reg86.w.f = 1 (set carry flag)
	movb	(_reg86+13), ah		! reg86.b.ah = 0x01 = "invalid command"
	ret
0:	push	ebp			! save C registers
	push	esi
	push	edi
	push	ebx
	pushf				! save flags
	cli				! no interruptions

	inb	INT2_CTLMASK
	movb	ah, al
	inb	INT_CTLMASK
	push	eax			! save interrupt masks
	mov	eax, (_irq_use)		! map of in-use IRQ`s
	and	eax, ~[1<<CLOCK_IRQ]	! keep the clock ticking
	outb	INT_CTLMASK		! enable all unused IRQ`s and vv.
	movb	al, ah
	outb	INT2_CTLMASK

	mov	eax, SS_SELECTOR	! monitor data segment
	mov	ss, ax
	xchg	esp, (_mon_sp)		! switch stacks
	push	(_reg86+36)		! parameters used in INT call
	push	(_reg86+32)
	push	(_reg86+28)
	push	(_reg86+24)
	push	(_reg86+20)
	push	(_reg86+16)
	push	(_reg86+12)
	push	(_reg86+ 8)
	push	(_reg86+ 4)
	push	(_reg86+ 0)
	mov	ds, ax			! remaining data selectors
	mov	es, ax
	mov	fs, ax
	mov	gs, ax
	push	cs
	push	return			! kernel return address and selector
    o16	jmpf	20+2*4+10*4+2*4(esp)	! make the call
return:
	pop	(_reg86+ 0)
	pop	(_reg86+ 4)
	pop	(_reg86+ 8)
	pop	(_reg86+12)
	pop	(_reg86+16)
	pop	(_reg86+20)
	pop	(_reg86+24)
	pop	(_reg86+28)
	pop	(_reg86+32)
	pop	(_reg86+36)
	lgdt	(_gdt+GDT_SELECTOR)	! reload global descriptor table
	jmpf	CS_SELECTOR:csinit	! restore everything
csinit:	mov	eax, DS_SELECTOR
	mov	ds, ax
	mov	es, ax
	mov	fs, ax
	mov	gs, ax
	mov	ss, ax
	xchg	esp, (_mon_sp)		! unswitch stacks
	lidt	(_gdt+IDT_SELECTOR)	! reload interrupt descriptor table
	andb	(_gdt+TSS_SELECTOR+DESC_ACCESS), ~0x02  ! clear TSS busy bit
	mov	eax, TSS_SELECTOR
	ltr	ax			! set TSS register

	pop	eax
	outb	INT_CTLMASK		! restore interrupt masks
	movb	al, ah
	outb	INT2_CTLMASK

	add	(_lost_ticks), ecx	! record lost clock ticks

	popf				! restore flags
	pop	ebx			! restore C registers
	pop	edi
	pop	esi
	pop	ebp
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
! Note that the message size, "Msize" is in DWORDS (not bytes) and must be set
! correctly.  Changing the definition of message in the type file and not
! changing it here will lead to total disaster.

CM_ARGS	=	4 + 4 + 4 + 4 + 4	! 4 + 4 + 4 + 4 + 4
!		es  ds edi esi eip	proc scl sof dcl dof

	.align	16
_cp_mess:
	cld
	push	esi
	push	edi
	push	ds
	push	es

	mov	eax, FLAT_DS_SELECTOR
	mov	ds, ax
	mov	es, ax

	mov	esi, CM_ARGS+4(esp)		! src clicks
	shl	esi, CLICK_SHIFT
	add	esi, CM_ARGS+4+4(esp)		! src offset
	mov	edi, CM_ARGS+4+4+4(esp)		! dst clicks
	shl	edi, CLICK_SHIFT
	add	edi, CM_ARGS+4+4+4+4(esp)	! dst offset

	mov	eax, CM_ARGS(esp)	! process number of sender
	stos				! copy number of sender to dest message
	add	esi, 4			! do not copy first word
	mov	ecx, Msize - 1		! remember, first word does not count
	rep
	movs				! copy the message

	pop	es
	pop	ds
	pop	edi
	pop	esi
	ret				! that is all folks!


!*===========================================================================*
!*				exit					     *
!*===========================================================================*
! PUBLIC void exit();
! Some library routines use exit, so provide a dummy version.
! Actual calls to exit cannot occur in the kernel.
! GNU CC likes to call ___main from main() for nonobvious reasons.

_exit:
__exit:
___exit:
	sti
	jmp	___exit

___main:
	ret


!*===========================================================================*
!*				in_byte					     *
!*===========================================================================*
! PUBLIC unsigned in_byte(port_t port);
! Read an (unsigned) byte from the i/o port  port  and return it.

	.align	16
_in_byte:
	mov	edx, 4(esp)		! port
	sub	eax, eax
	inb	dx			! read 1 byte
	ret


!*===========================================================================*
!*				in_word					     *
!*===========================================================================*
! PUBLIC unsigned in_word(port_t port);
! Read an (unsigned) word from the i/o port  port  and return it.

	.align	16
_in_word:
	mov	edx, 4(esp)		! port
	sub	eax, eax
    o16	in	dx			! read 1 word
	ret


!*===========================================================================*
!*				out_byte				     *
!*===========================================================================*
! PUBLIC void out_byte(port_t port, u8_t value);
! Write  value  (cast to a byte)  to the I/O port  port.

	.align	16
_out_byte:
	mov	edx, 4(esp)		! port
	movb	al, 4+4(esp)		! value
	outb	dx			! output 1 byte
	ret


!*===========================================================================*
!*				out_word				     *
!*===========================================================================*
! PUBLIC void out_word(Port_t port, U16_t value);
! Write  value  (cast to a word)  to the I/O port  port.

	.align	16
_out_word:
	mov	edx, 4(esp)		! port
	mov	eax, 4+4(esp)		! value
    o16	out	dx			! output 1 word
	ret


!*===========================================================================*
!*				port_read				     *
!*===========================================================================*
! PUBLIC void port_read(port_t port, phys_bytes destination, unsigned bytcount);
! Transfer data from (hard disk controller) port to memory.

PR_ARGS	=	4 + 4 + 4		! 4 + 4 + 4
!		es edi eip		port dst len

	.align	16
_port_read:
	cld
	push	edi
	push	es
	mov	ecx, FLAT_DS_SELECTOR
	mov	es, cx
	mov	edx, PR_ARGS(esp)	! port to read from
	mov	edi, PR_ARGS+4(esp)	! destination addr
	mov	ecx, PR_ARGS+4+4(esp)	! byte count
	shr	ecx, 1			! word count
	rep				! (hardware cannot handle dwords)
    o16	ins				! read everything
	pop	es
	pop	edi
	ret


!*===========================================================================*
!*				port_read_byte				     *
!*===========================================================================*
! PUBLIC void port_read_byte(port_t port, phys_bytes destination,
!						unsigned bytcount);
! Transfer data from port to memory.

PR_ARGS_B =	4 + 4 + 4		! 4 + 4 + 4
!		es edi eip		port dst len

_port_read_byte:
	cld
	push	edi
	push	es
	mov	ecx, FLAT_DS_SELECTOR
	mov	es, cx
	mov	edx, PR_ARGS_B(esp)
	mov	edi, PR_ARGS_B+4(esp)
	mov	ecx, PR_ARGS_B+4+4(esp)
	rep
	insb
	pop	es
	pop	edi
	ret


!*===========================================================================*
!*				port_write				     *
!*===========================================================================*
! PUBLIC void port_write(port_t port, phys_bytes source, unsigned bytcount);
! Transfer data from memory to (hard disk controller) port.

PW_ARGS	=	4 + 4 + 4		! 4 + 4 + 4
!		es edi eip		port src len

	.align	16
_port_write:
	cld
	push	esi
	push	ds
	mov	ecx, FLAT_DS_SELECTOR
	mov	ds, cx
	mov	edx, PW_ARGS(esp)	! port to write to
	mov	esi, PW_ARGS+4(esp)	! source addr
	mov	ecx, PW_ARGS+4+4(esp)	! byte count
	shr	ecx, 1			! word count
	rep				! (hardware cannot handle dwords)
    o16	outs				! write everything
	pop	ds
	pop	esi
	ret


!*===========================================================================*
!*				port_write_byte				     *
!*===========================================================================*
! PUBLIC void port_write_byte(port_t port, phys_bytes source,
!						unsigned bytcount);
! Transfer data from memory to port.

PW_ARGS_B =	4 + 4 + 4		! 4 + 4 + 4
!		es edi eip		port src len

_port_write_byte:
	cld
	push	esi
	push	ds
	mov	ecx, FLAT_DS_SELECTOR
	mov	ds, cx
	mov	edx, PW_ARGS_B(esp)
	mov	esi, PW_ARGS_B+4(esp)
	mov	ecx, PW_ARGS_B+4+4(esp)
	rep
	outsb
	pop	ds
	pop	esi
	ret


!*===========================================================================*
!*				lock					     *
!*===========================================================================*
! PUBLIC void lock();
! Disable CPU interrupts.

	.align	16
_lock:
	cli				! disable interrupts
	ret


!*===========================================================================*
!*				unlock					     *
!*===========================================================================*
! PUBLIC void unlock();
! Enable CPU interrupts.

	.align	16
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

	.align	16
_enable_irq:
	mov	ecx, 4(esp)		! irq
	pushf
	cli
	movb	ah, ~1
	rolb	ah, cl			! ah = ~(1 << (irq % 8))
	cmpb	cl, 8
	jae	enable_8		! enable irq >= 8 at the slave 8259
enable_0:
	inb	INT_CTLMASK
	andb	al, ah
	outb	INT_CTLMASK		! clear bit at master 8259
	popf
	ret
	.align	4
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

	.align	16
_disable_irq:
	mov	ecx, 4(esp)		! irq
	pushf
	cli
	movb	ah, 1
	rolb	ah, cl			! ah = (1 << (irq % 8))
	cmpb	cl, 8
	jae	disable_8		! disable irq >= 8 at the slave 8259
disable_0:
	inb	INT_CTLMASK
	testb	al, ah
	jnz	dis_already		! already disabled?
	orb	al, ah
	outb	INT_CTLMASK		! set bit at master 8259
	popf
	mov	eax, 1			! disabled by this function
	ret
disable_8:
	inb	INT2_CTLMASK
	testb	al, ah
	jnz	dis_already		! already disabled?
	orb	al, ah
	outb	INT2_CTLMASK		! set bit at slave 8259
	popf
	mov	eax, 1			! disabled by this function
	ret
dis_already:
	popf
	xor	eax, eax		! already disabled
	ret


!*===========================================================================*
!*				phys_copy				     *
!*===========================================================================*
! PUBLIC void phys_copy(phys_bytes source, phys_bytes destination,
!			phys_bytes bytecount);
! Copy a block of physical memory.

PC_ARGS	=	4 + 4 + 4 + 4	! 4 + 4 + 4
!		es edi esi eip	 src dst len

	.align	16
_phys_copy:
	cld
	push	esi
	push	edi
	push	es

	mov	eax, FLAT_DS_SELECTOR
	mov	es, ax

	mov	esi, PC_ARGS(esp)
	mov	edi, PC_ARGS+4(esp)
	mov	eax, PC_ARGS+4+4(esp)

	cmp	eax, 10			! avoid align overhead for small counts
	jb	pc_small
	mov	ecx, esi		! align source, hope target is too
	neg	ecx
	and	ecx, 3			! count for alignment
	sub	eax, ecx
	rep
   eseg	movsb
	mov	ecx, eax
	shr	ecx, 2			! count of dwords
	rep
   eseg	movs
	and	eax, 3
pc_small:
	xchg	ecx, eax		! remainder
	rep
   eseg	movsb

	pop	es
	pop	edi
	pop	esi
	ret


!*===========================================================================*
!*				mem_rdw					     *
!*===========================================================================*
! PUBLIC u16_t mem_rdw(U16_t segment, u16_t *offset);
! Load and return word at far pointer segment:offset.

	.align	16
_mem_rdw:
	mov	cx, ds
	mov	ds, 4(esp)		! segment
	mov	eax, 4+4(esp)		! offset
	movzx	eax, (eax)		! word to return
	mov	ds, cx
	ret


!*===========================================================================*
!*				reset					     *
!*===========================================================================*
! PUBLIC void reset();
! Reset the system by loading IDT with offset 0 and interrupting.

_reset:
	lidt	(idt_zero)
	int	3		! anything goes, the 386 will not like it
.sect .data
idt_zero:	.data4	0, 0
.sect .text


!*===========================================================================*
!*				mem_vid_copy				     *
!*===========================================================================*
! PUBLIC void mem_vid_copy(u16 *src, unsigned dst, unsigned count);
!
! Copy count characters from kernel memory to video memory.  Src, dst and
! count are character (word) based video offsets and counts.  If src is null
! then screen memory is blanked by filling it with blank_color.

MVC_ARGS	=	4 + 4 + 4 + 4	! 4 + 4 + 4
!			es edi esi eip	 src dst ct

_mem_vid_copy:
	push	esi
	push	edi
	push	es
	mov	esi, MVC_ARGS(esp)	! source
	mov	edi, MVC_ARGS+4(esp)	! destination
	mov	edx, MVC_ARGS+4+4(esp)	! count
	mov	es, (_vid_seg)		! destination is video segment
	cld				! make sure direction is up
mvc_loop:
	and	edi, (_vid_mask)	! wrap address
	mov	ecx, edx		! one chunk to copy
	mov	eax, (_vid_size)
	sub	eax, edi
	cmp	ecx, eax
	jbe	0f
	mov	ecx, eax		! ecx = min(ecx, vid_size - edi)
0:	sub	edx, ecx		! count -= ecx
	shl	edi, 1			! byte address
	test	esi, esi		! source == 0 means blank the screen
	jz	mvc_blank
mvc_copy:
	rep				! copy words to video memory
    o16	movs
	jmp	mvc_test
mvc_blank:
	mov	eax, (_blank_color)	! ax = blanking character
	rep
    o16	stos				! copy blanks to video memory
	!jmp	mvc_test
mvc_test:
	shr	edi, 1			! word addresses
	test	edx, edx
	jnz	mvc_loop
mvc_done:
	pop	es
	pop	edi
	pop	esi
	ret


!*===========================================================================*
!*				vid_vid_copy				     *
!*===========================================================================*
! PUBLIC void vid_vid_copy(unsigned src, unsigned dst, unsigned count);
!
! Copy count characters from video memory to video memory.  Handle overlap.
! Used for scrolling, line or character insertion and deletion.  Src, dst
! and count are character (word) based video offsets and counts.

VVC_ARGS	=	4 + 4 + 4 + 4	! 4 + 4 + 4
!			es edi esi eip	 src dst ct

_vid_vid_copy:
	push	esi
	push	edi
	push	es
	mov	esi, VVC_ARGS(esp)	! source
	mov	edi, VVC_ARGS+4(esp)	! destination
	mov	edx, VVC_ARGS+4+4(esp)	! count
	mov	es, (_vid_seg)		! use video segment
	cmp	esi, edi		! copy up or down?
	jb	vvc_down
vvc_up:
	cld				! direction is up
vvc_uploop:
	and	esi, (_vid_mask)	! wrap addresses
	and	edi, (_vid_mask)
	mov	ecx, edx		! one chunk to copy
	mov	eax, (_vid_size)
	sub	eax, esi
	cmp	ecx, eax
	jbe	0f
	mov	ecx, eax		! ecx = min(ecx, vid_size - esi)
0:	mov	eax, (_vid_size)
	sub	eax, edi
	cmp	ecx, eax
	jbe	0f
	mov	ecx, eax		! ecx = min(ecx, vid_size - edi)
0:	sub	edx, ecx		! count -= ecx
	shl	esi, 1
	shl	edi, 1			! byte addresses
	rep
eseg o16 movs				! copy video words
	shr	esi, 1
	shr	edi, 1			! word addresses
	test	edx, edx
	jnz	vvc_uploop		! again?
	jmp	vvc_done
vvc_down:
	std				! direction is down
	lea	esi, -1(esi)(edx*1)	! start copying at the top
	lea	edi, -1(edi)(edx*1)
vvc_downloop:
	and	esi, (_vid_mask)	! wrap addresses
	and	edi, (_vid_mask)
	mov	ecx, edx		! one chunk to copy
	lea	eax, 1(esi)
	cmp	ecx, eax
	jbe	0f
	mov	ecx, eax		! ecx = min(ecx, esi + 1)
0:	lea	eax, 1(edi)
	cmp	ecx, eax
	jbe	0f
	mov	ecx, eax		! ecx = min(ecx, edi + 1)
0:	sub	edx, ecx		! count -= ecx
	shl	esi, 1
	shl	edi, 1			! byte addresses
	rep
eseg o16 movs				! copy video words
	shr	esi, 1
	shr	edi, 1			! word addresses
	test	edx, edx
	jnz	vvc_downloop		! again?
	cld				! C compiler expect up
	!jmp	vvc_done
vvc_done:
	pop	es
	pop	edi
	pop	esi
	ret


!*===========================================================================*
!*			      level0					     *
!*===========================================================================*
! PUBLIC void level0(void (*func)(void))
! Call a function at permission level 0.  This allows kernel tasks to do
! things that are only possible at the most privileged CPU level.
!
_level0:
	mov	eax, 4(esp)
	mov	(_level0_func), eax
	int	LEVEL0_VECTOR
	ret
