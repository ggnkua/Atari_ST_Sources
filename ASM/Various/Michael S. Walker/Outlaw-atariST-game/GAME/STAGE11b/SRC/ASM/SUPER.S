*  Michael S. Walker <mwalk762@mtroyal.ca>
* 	    _    _
*        | |  | |	OUTLAW. 
*       -| |  | |- 
*   _    | |- | |
* -| |   | |  | |- 	
*  |.|  -| ||/  |
*  | |-  |  ___/ 
* -|.|   | | |
*  |  \_|| |
*   \____  |
*    |   | |- 
*        | |
*       -| |
*        |_| Copyleft !(c) 2020 All Rights Unreserved in all Federations, including Alpha Centauris.

  xdef       _MySuper

*	--------------- long MySuper(long ssp) ------
*	Usage: 
*	
*	long MySuper(long ssp);
*	long old_ssp = super(0);        // for super
*	MySuper(old_ssp);               // for user. 
*	------------------------------------------------

_MySuper:
SSP equ 8

  clr.l      d0
  link       a6,#0
  movem.l    d1/a0-a2,-(sp)

  move.l     SSP(a6),-(sp)
  move.w     #$20,-(sp)
  trap       #1
  addq.l     #6,sp

  movem.l    (sp)+,d1/a0-a2
  unlk       a6

  rts
  nop
