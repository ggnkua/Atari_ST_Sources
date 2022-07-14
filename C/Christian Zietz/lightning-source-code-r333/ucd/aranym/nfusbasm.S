|  Interrupt routine for the Native Features USB driver
| 
|  This file belongs to FreeMiNT. It's not in the original MiNT 1.12
|  distribution. See the file CHANGES for a detailed log of changes.
| 
|  Copyright (c) 2002-2006 Standa and Petr of ARAnyM dev team.
|                     2011 Modified for USB by David Galvez.
| 
|  This file is free software; you can redistribute it and/or modify
|  it under the terms of the GNU General Public License as published by
|  the Free Software Foundation; either version 2, or (at your option)
|  any later version.
| 
|  This file is distributed in the hope that it will be useful,
|  but WITHOUT ANY WARRANTY; without even the implied warranty of
|  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
|  GNU General Public License for more details.
| 
|  You should have received a copy of the GNU General Public License
|  along with this program; if not, write to the Free Software
|  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
|

	.globl _old_interrupt
	.globl _my_interrupt
	.globl _nfusb_interrupt

	.text

	dc.l	0x58425241		| XBRA
	dc.l	0x41524175		| ARAu
_old_interrupt:
	ds.l	1
_my_interrupt:
	movem.l	a0-a2/d0-d2,-(sp)
	bsr	_nfusb_interrupt
	movem.l	(sp)+,a0-a2/d0-d2
	move.l	_old_interrupt(PC),-(sp)
	rts
