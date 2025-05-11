/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 *   Addresses of system variables (these are the ones "cast in stone") -
 * add them as you need them.
 *
 * $Header: sysvars.h,v 1.2 88/02/03 22:30:14 m68k Exp $
 *
 * $Log:	sysvars.h,v $
 * Revision 1.2  88/02/03  22:30:14  m68k
 * Set the high bit in address <64k - this avoids a problem (in 68k chip?)
 * that causes things not to work (movl 1212:w, d0 does not work as expected).
 * 
 * Revision 1.1  88/02/03  20:04:48  m68k
 * Initial revision
 * 
 */
#define	nvblq		((short *) 0x80000454)
/* This should be pointer to ponter to function returning int but C doesn't
 * like dealing with such things
 */
#define _vblqueue	((char ***) 0x80000456)
#define	_hz_200		((long *) 0x800004bc)
