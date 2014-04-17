********************************  vdiincld.s  *********************************
*
* $Revision: 3.0 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/vdiincld.s,v $
* =============================================================================
* $Author: lozben $	$Date: 91/01/03 15:22:56 $     $Locker:  $
* =============================================================================
*
* $Log:	vdiincld.s,v $
* Revision 3.0  91/01/03  15:22:56  lozben
* New generation VDI
* 
* Revision 2.2  90/03/01  13:32:58  lozben
* *** Initial Revision ***
* 
*******************************************************************************

*+
* This is an include file for other .s files.
*-
P68030		equ	0	; @check@ set to 0 if we are on a 68030 (else 1)
PAL4096		equ	0	; @check@ set to 0 if st mode has a pal of 4096
