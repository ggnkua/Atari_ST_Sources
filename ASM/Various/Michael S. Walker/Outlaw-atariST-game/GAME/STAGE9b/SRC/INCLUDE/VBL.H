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

#ifndef VBL_H
#define VBL_H

void do_VBL_ISR(void);
void MyVsync(void);
long MyVblank(void);
int GetSeconds(void);
void ResetSeconds(void);
void ResetTicks(void);
void ResetVblankFlag(void);
#endif /* VBL_H */