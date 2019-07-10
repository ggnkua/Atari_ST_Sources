/*
 * fixpt.h - fix point arithmetic routines
 *
 * Copyright 1990 by Bruce D. Szablak
 *
 * This software is distributed "as is" with no warrantee of fitness
 * for any use. Unrestricted use of this software is hereby granted.
 */

#ifndef _FIXPT_H
#define _FIXPT_H

typedef long Fixpt;

#ifndef _S
#define _S	10
#endif

#define IntToFix(i)	((long)(i) << _S)
#define	FixToInt(f)	(((f)+(1L<<(_S-1))) >> _S)
#define FixAbs(f)	((f) < 0) ? -(f) : (f))
#define FFAdd(f1,f2)	((f1)+(f2))
#define FFSub(f1,f2)	((f1)-(f2))
#define FFMlt(f1,f2)	(((f1)*(f2))>>_S)
#define FFDiv(f1,f2)	(IntToFix(f1)/(f2))
#define FIAdd(f,i)	FFAdd(f,IntToFix(i))
#define FISub(f,i)	FFSub(f,IntToFix(i))
#define FIMlt(f,i)	((f)*(i))
#define FIDiv(f,i)	((f)/(i))
#define IFSub(i,f)	FFSub(IntToFix(i),f)
#define IFDiv(i,f)	(IntToFix(IntToFix(i))/(f))

#endif
