/*
 * Michael S. Walker <mwalk762@mtroyal.ca>
 *	    _    _
 *       | |  | |	OUTLAW. 
 *      -| |  | |- 
 *  _    | |- | |
 *-| |   | |  | |- 	
 * |.|  -| ||/  |
 * | |-  |  ___/ 
 *-|.|   | | |
 * |  \_|| |
 *  \____  |
 *   |   | |- 
 *       | |
 *      -| |
 *       |_| Copyleft !(c) 2020 All Rights Unreserved in all Federations, including Alpha Centauris.
 */

#ifndef ISR_H
#define ISR_H

#define VBL_ISR 28
#define IKBD_ISR 70

typedef void (*Vector)(void); /* a Vector is a function start addr. */
Vector InstallVector(int num, Vector vector);
extern void Vbl(void);
extern void Ikbd(void);

#endif /* ISR_H */
