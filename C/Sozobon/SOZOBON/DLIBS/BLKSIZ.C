/*
 *	Default _BLKSIZ variable declaration
 *
 *	NOTE:  (16 * _BLKSIZ) is the maximum amount of memory that can
 *	by managed by the dynamic memory management routines.
 */

long _BLKSIZ = 65536;		/* Malloc() in 64K chunks */
