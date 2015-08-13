*********************************************************************************
* Data structure for packet buffers in MagicNet/MintNet				*
*										*
*	Copyright 2001-2002 Dr. Thomas Redelberger				*
*	Use it under the terms of the GNU General Public License		*
*	(See file COPYING.TXT)							*
*										*
* Credits:									*
* Although written in 68000 assembler this source code is based on the source	*
* module buff.h of MintNet originally due to Kay Roemer				*
*										*
* Tabsize 8, developed with DEVPAC assembler 2.0.				*
*********************************************************************************
* $Id: buf.i 1.1 2002/03/24 14:06:12 Thomas Exp Thomas $
*


* we just have a subset here relevant for a driver

BUF_NORMAL	EQU	0
BUF_ATOMIC	EQU	1


* struct buf
		OFFSET	0

bf_buflen	DS.L	1			; ulong	buflen, including header
bf_dstart	DS.L	1			; char	*dstart, start of data
bf_dend		DS.L	1			; char	*dend, end of data
bf_next		DS.L	1			; BUF	*next, next message
bf_prev		DS.L	1			; BUF	*prev, previous message
bf_link3	DS.L	1			; BUF	*link3, another next pointer
bf_links	DS.W	1			; short	links, usage counter
bf_info		DS.L	1			; long	info, aux info
* ...more follow we do not need

