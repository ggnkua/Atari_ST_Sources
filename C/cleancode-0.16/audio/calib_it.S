/*
	Calibration for Falcon external clock

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

	.globl	_CalibDone;
	.globl	_CalibSystemTic

	.globl	_CalibInterrupt

/*--- DMA 8 bits interrupt vector ---*/

	.text
_CalibInterrupt:
	movel	0x4ba:w,_CalibSystemTic
	movel	0xffffffff,_CalibDone

	/* Clear service bit, so other MFP interrupts can work */
	bclr	#5,0xfffffa0f:w
	rte

/*--- Variables ---*/

	.data
	.even
	.comm	_CalibDone,4
	.even
	.comm	_CalibSystemTic,4
