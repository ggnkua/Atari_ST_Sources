*********************************  devequ.s  **********************************
*
* $Revision: 3.1 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/sbescape.s,v $
* =============================================================================
* $Author: lozben $	$Date: 91/01/31 12:04:31 $     $Locker:  $
* =============================================================================
*
* $Log:	$
*******************************************************************************

*+
* Offsets into SCREENDEF structure
*-
DEVNAME		=	0		; device description string
DEVID		=	4		; device id number
DEVPLANES	=	6		; # of planes (bits per pixel)
DEVLINEWRAP	=	8		; # of bytes from 1 scan to next
DEVXREZ		=	10		; current horizontal resolution
DEVYREZ		=	12		; current vertical resolution
DEVXSIZE	=	14		; width of one pixel in microns
DEVYSIZE	=	16		; height of one pixel in microns
DEVFORMID	=	18		; scrn form 0 ST, 1 stndrd, 2 pix
DEVFNTPTR	=	20		; points to the default font
DEVMAXPEN	=	24		; # of pens available
DEVCOLFLAG	=	26		; color cpability flag
DEVPALSIZE	=	28		; palette size (0 = contiguous)
DEVLOOKUPTABLE	=	30		; lookup table supported flag
DEVSOFTROUTINES =	32		; drawing primitives done in sofwr
DEVHARDROUTINES	=	36		; hardware assisted drawing primitives
DEVCURROUTINES	=	40		; current routines being used
DEVVIDADR	=	44		; video base adr for dev (can be NULL)

V_CELL		=	0		; VT52 cell output routines
V_SCRUP		=	4		; VT52 screen up routine
V_SCRDN		=	8		; VT52 screen down routine
V_BLANK		=	12		; VT52 screen blank routine
V_BLAST		=	16		; blit routines
V_MONO		=	20		; monospace font blit routines
V_RECT		=	24		; rectangle draw routines
V_VLINE		=	28		; vertical line draw routines
V_HLINE		=	32		; horizontal line draw routines
V_TEXT		=	36		; text blit routines
V_VQCOLOR	=	40		; color inquire routines
V_VSCOLOR	=	44		; color set routines
V_INIT		=	48		; init routine called upon openwk
V_SHOWCUR	=	52		; display cursor
V_HIDECUR	=	56		; replace cursor with old background
V_NEGCELL	=	60		; negate alpha cursor
V_MOVEACUR	=	64		; move alpha cur to new X,Y (D0, D1)
V_ABLINE	=	68		; arbitrary line draw routine
V_HABLINE	=	72		; horizontal line setup routine
V_RECTFILL	=	76		; rctangle fill routine
V_PUTPIX	=	80		; output pixel value to the screen
V_GETPIX	=	84		; get pixel value at (X,Y) of screen


DEVICEDEP	=	0		; means we're in device dep mode
STANDARD	=	1		; flag for standard format
INTERLEAVED	=	2		; flag for interlieved planes
PIXPACKED	=	3		; flag for pixel packed

