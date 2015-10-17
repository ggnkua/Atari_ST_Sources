/*
	VDI mouse interrupt

	Copyright (C) 2002	Patrice Mandin

	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
*/

	.text

	.globl	_VdiMotionVector
	.globl	_VdiButtonVector

	.globl	_Vdi_mouseb
	.globl	_Vdi_mousex
	.globl	_Vdi_mousey

	.globl	_Vdi_oldmotionvector
	.globl	_Vdi_oldbuttonvector

/*--- Our mouse motion vector ---*/

	.text
	.even
	.ascii "XBRA"
	.ascii "LSDL"
	.comm	_Vdi_oldmotionvector,4*1
_VdiMotionVector:
	/* X position */
	movew	d0,_Vdi_mousex

	/* Y position */
	movew	d1,_Vdi_mousey

	rts

/*--- Our mouse button vector ---*/

	.text
	.even
	.ascii "XBRA"
	.ascii "LSDL"
	.comm	_Vdi_oldbuttonvector,4*1
_VdiButtonVector:
	/* Buttons */
	movew	d0,_Vdi_mouseb

	rts

	.data
	.even
	.comm	_Vdi_mousex,2*1
	.even
	.comm	_Vdi_mousey,2*1
	.even
	.comm	_Vdi_mouseb,2*1

