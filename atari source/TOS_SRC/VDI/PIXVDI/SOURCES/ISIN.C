/*
*******************************   isin.c   ************************************
*
* $Revision: 3.0 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/isin.c,v $
* =============================================================================
* $Author: lozben $	$Date: 91/01/03 15:11:51 $     $Locker:  $
* =============================================================================
*
* $Log:	isin.c,v $
* Revision 3.0  91/01/03  15:11:51  lozben
* New generation VDI
* 
* Revision 2.2  89/08/18  18:34:52  lozben
* Optimized the code.
* 
* Revision 2.1  89/02/21  17:23:06  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
*******************************************************************************
*/

#include "portab.h"
#include "proto.h"

#define    HALFPI    900 
#define    PI	     1800
#define    TWOPI     3600

/*---------------------------------------------------------------------------*/
/* Sines of angles 1 - 90 degrees normalized between 0-32767.		     */

MLOCAL WORD sin_tbl[92] = {    
		    0 , 572  , 1144 , 1716 , 2286 , 2856 , 3425 , 3993 , 
		 4560 , 5126 , 5690 , 6252 , 6813 , 7371 , 7927 , 8481 , 
		 9032 , 9580 ,10126 ,10668 ,11207 ,11743 ,12275 ,12803 ,
		13328 ,13848 ,14364 ,14876 ,15383 ,15886 ,16383 ,16876 ,
		17364 ,17846 ,18323 ,18794 ,19260 ,19720 ,20173 ,20621 ,
		21062 ,21497 ,21925 ,22347 ,22762 ,23170 ,23571 ,23964 ,
		24351 ,24730 ,25101 ,25465 ,25821 ,26169 ,26509 ,26841 ,
		27165 ,27481 ,27788 ,28087 ,28377 ,28659 ,28932 ,29196 ,
		29451 ,29697 ,29934 ,30162 ,30381 ,30591 ,30791 ,30982 ,
		31163 ,31335 ,31498 ,31650 ,31794 ,31927 ,32051 ,32165 ,
		32269 ,32364 ,32448 ,32523 ,32587 ,32642 ,32687 ,32722 ,
		32747 ,32762 ,32767 ,32767 
};
/*---------------------------------------------------------------------------*/
/* 
 * Returns integer sin between -32767 - 32767. Uses integer
 * lookup table sintable^[]. Expects angle in tenths of degree 0 - 3600.
 * Assumes positive angles only.
 */
WORD Isin(ang)
REG WORD ang;
{
  	REG WORD 	index, remainder, tmpsin, *ptr;
  	REG WORD  	quadrant;		/* 0-3 = 1st, 2nd, 3rd, 4th. */


	ptr = sin_tbl;

	while (ang > 3600)
    		ang -= 3600;

  	quadrant = ang / HALFPI;
 
 	switch (quadrant) {
		case 0:
        	  	break;

      		case 1:
		  	ang = PI - ang;
		  	break;
      
      		case 2:
		  	ang -= PI;
		  	break;

		case 3:
        	  	ang = TWOPI - ang;
		  	break;

      		case 4:
        	  	ang -= TWOPI;
		  	break;
    	};

    	index = ang / 10;
    	remainder = ang % 10;
    	tmpsin = ptr[index];

   	/* add interpolation. */
    	if (remainder != 0)
	  	tmpsin += ((ptr[index + 1] - tmpsin) * remainder) / 10;

    	if (quadrant > 1)
		tmpsin = -tmpsin;

    	return (tmpsin);
}

/*---------------------------------------------------------------------------*/
/*
 * return integer cos between -32767 and 32767.
 */
WORD Icos(ang) 
WORD ang;
{
  	ang += HALFPI ;

  	if (ang > TWOPI)
    	  	ang -= TWOPI ;

  	return (Isin(ang)) ;
}
/*---------------------------------------------------------------------------*/
