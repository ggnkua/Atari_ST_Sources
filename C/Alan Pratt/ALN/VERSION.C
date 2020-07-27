/*
******************* Revision Control System *****************************
*
* $Author: apratt $
* =======================================================================
*
* $Date: 90/01/24 15:46:10 $
* =======================================================================
*
* $Locker:  $
* =======================================================================
*
* $Log:	version.c,v $
* Revision 1.3  90/01/24  15:46:10  apratt
* Changed so dollar-V isn't printed as part of version string.
* 
* Revision 1.2  89/03/30  14:21:07  apratt
* Wider space, new copyright, more comments.
* 
* Revision 1.1  88/08/23  14:20:36  apratt
* Initial revision
* 
* =======================================================================
*
* $Revision: 1.3 $
* =======================================================================
*
* $Source: /u/apratt/work/aln/RCS/version.c,v $
* =======================================================================
*
*************************************************************************
*/
/*
 * version number for ALN
 *
 * This version number is meant to be changed by mkvers, which looks
 * for the dollar-V combination and clobbers the following 11 bytes.
 */

#ifdef JAGUAR
static char *vers = "93/08/25";
#else
static char vstring[] = "$V 00/00/00xx";
static char *vers = &vstring[3];
#endif

version()
{
      puts("***********************************");
    printf("*    ATARI LINKER  %s     *\n",vers);
      puts("* Copyright 1987-1990 Atari Corp. *");
      puts("***********************************");
}
