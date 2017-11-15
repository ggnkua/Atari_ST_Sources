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
 *	flags.h
 *
 *	token or e_flags flags
 */

#define CAN_U	2	/* can be unary op */
#define CAN_AS	4	/* can be op-assign */
#define SPECIAL 8	/* special token beginner ("'/*) */
#define SEE_U	0x10	/* for ICON */
#define SEE_L	0x20	/* for ICON */
#define C_NOT_A 0x40	/* commutative but not associative */
#define C_AND_A 0x80	/* commutative and associative */
#define IMMEDID	0x100	/* Ptr to XXX ID which is really
				Array of XXX or Fun ret XXX */
#define CHILDNM	0x200	/* my name is my (left) child's name */
#define SIDE_CC 0x400	/* cc set as side effect of op. */
#define RCHILDNM 0x800	/* my name is my (right) child's name */
