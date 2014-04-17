/*	OBJADDR.H			9/22/92		D.Mui	*/

/*	-----------------------------------------------------------
*	AES Version 4.0	MultiTOS version is written by Derek M. Mui
*	Copyright (C) 1992 
*	Atari (U.S.) Corp
*	All Rights Reserved
*	-----------------------------------------------------------
*/	

#ifndef _OBJADDR_H_
#define _OBJADDR_H_

#define OB_NEXT(x) (tree + (x) * sizeof(OBJECT) + 0)
#define OB_HEAD(x) (tree + (x) * sizeof(OBJECT) + 2)
#define OB_TAIL(x) (tree + (x) * sizeof(OBJECT) + 4)
#define OB_TYPE(x) (tree + (x) * sizeof(OBJECT) + 6)
#define OB_FLAGS(x) (tree + (x) * sizeof(OBJECT) + 8)
#define OB_STATE(x) (tree + (x) * sizeof(OBJECT) + 10)
#define OB_SPEC(x) (tree + (x) * sizeof(OBJECT) + 12)
#define OB_X(x) (tree + (x) * sizeof(OBJECT) + 16)
#define OB_Y(x) (tree + (x) * sizeof(OBJECT) + 18)
#define OB_WIDTH(x) (tree + (x) * sizeof(OBJECT) + 20)
#define OB_HEIGHT(x) (tree + (x) * sizeof(OBJECT) + 22)

#endif

