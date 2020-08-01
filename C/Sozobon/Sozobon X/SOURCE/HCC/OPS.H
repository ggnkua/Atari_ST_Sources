/* Copyright (c) 1988,1991 by Sozobon, Limited.  Author: Johann Ruegg
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 *
 *	ops.h
 *
 *	defines of allowed operands
 *	'E' means Dreg or OREG or ONAME or (if on left) ICON
 *	'Q' means ICON which is 1 to 8
 *	ONE means ICON which is 1
 */

#define DOPD	1
#define AOPD	2
#define MOPD	4
#define IOPD	8

#define DOPA	0x10
#define AOPA	0x20
#define MOPA	0x40
#define IOPA	0x80

#define DOPM	0x100
#define AOPM	0x200
#define MOPM	0x400
#define IOPM	0x800

#define QOPD	0x1000
#define ONEOPM	0x2000
#define ASSOC	0x4000

#define EOPD	(DOPD|MOPD|IOPD)
#define DOPE	(DOPD|DOPM)
#define IOPE	(IOPD|IOPM)
#define EOPA	(DOPA|MOPA|IOPA)
