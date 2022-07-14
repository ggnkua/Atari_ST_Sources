/*
 * Copyright 2014 David Galvez.
 *
 * This file belongs to FreeMiNT. It's not in the original MiNT 1.12
 * distribution. See the file CHANGES for a detailed log of changes.
 *
 *
 * This file is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *
 */

.global _ehci_interrupt_handle
.global _ehci_int_handle_asm

/* PCI_BIOS specification: only a0 and d0 are allowed 
 * to be changed in interrupt handler, so we need to 
 * preserve a1 and d1 since GCC use them too as scratch
 * registers.
 */

_ehci_int_handle_asm:
	subq.l #8,sp
	movem.l d1/a1,(sp)
	move.l d0,-(sp)		// PCI_BIOS specification: INT not for us leave d0 untouched
	move.l a0,-(sp)		// PCI_BIOS specification: parameter is in a0
	jsr _ehci_interrupt_handle
	addq.l #8,sp
	movem.l (sp),d1/a1
	addq.l #8,sp
	rts
