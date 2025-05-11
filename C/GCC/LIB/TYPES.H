#ifndef _TYPES_H
/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 * $Header: types.h,v 1.1 88/01/29 17:22:35 m68k Exp $
 *
 * $Log:	types.h,v $
 * Revision 1.1  88/01/29  17:22:35  m68k
 * Initial revision
 * 
 */
typedef unsigned char	u_char;
typedef unsigned short	u_short;
typedef unsigned long	u_long;

typedef u_long		ino_t;
typedef short		dev_t;
typedef long		off_t;
typedef long		size_t;
typedef long		time_t;
typedef u_short		uid_t;
typedef u_short		gid_t;
typedef char *		caddr_t;

#define _TYPES_H
#endif	/* types.h */
