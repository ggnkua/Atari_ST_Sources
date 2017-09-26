/*
	MFP 68901 interrupts

	Copyright (C) 2002	Patrice Mandin

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#ifndef _MFP_H
#define _MFP_H

enum {
	MFP_PARALLEL=0,
	MFP_DCD,
	MFP_CTS,
	MFP_BITBLT,
	MFP_TIMERD,
	MFP_BAUDRATE=MFP_TIMERD,
	MFP_TIMERC,
	MFP_200HZ=MFP_TIMERC,
	MFP_ACIA,
	MFP_DISK,
	MFP_TIMERB,
	MFP_HBLANK=MFP_TIMERB,
	MFP_TERR,
	MFP_TBE,
	MFP_RERR,
	MFP_RBF,
	MFP_TIMERA,
	MFP_DMASOUND=MFP_TIMERA,
	MFP_RING,
	MFP_MONODETECT
};

/* Xbtimer() timers */
enum {
	XB_TIMERA=0,
	XB_TIMERB,
	XB_TIMERC,
	XB_TIMERD
};

#endif /* _MFP_H */
