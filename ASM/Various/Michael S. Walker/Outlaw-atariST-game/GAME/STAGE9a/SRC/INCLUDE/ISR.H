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

typedef void (*Vector)(void); /* a Vector is a function start addr. */
Vector InstallVector(int num, Vector vector);
void ResetTicks(void);
void ResetSeconds(void);
int GetSeconds(void);
long MyVblank(void);
void do_VBL_ISR(void);
void Vbl(void);
void MyVsync(void);
void ResetVblankFlag(void);

#endif /* ISR_H */
