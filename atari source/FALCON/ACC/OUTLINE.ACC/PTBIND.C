/*==========================================================================
 * FILE: PTBIND.C
 *==========================================================================
 * DATE: October 22, 1990
 * Description: Bindings for new FSM GDOS calls
 */


/* INCLUDE FILES
 *==========================================================================
 */
#include <sys\gemskel.h>


/* PROTOTYPES
 *==========================================================================
 */
void  stuffptr( int *srce, long *dest );


/* DEFINES
 *==========================================================================
 */

/* EXTERNALS
 *==========================================================================
 */
void vdi( void );


/* GLOBALS
 *==========================================================================
 */



/* FUNCTIONS
 *==========================================================================
 */
 

/* vst_arbpt()
 *==========================================================================
 */
int 
vst_arbpt( int handle, int point, int *chwd, int *chht, int *cellwd, int *cellht )
{
   contrl[0] = 252;
   contrl[1] = 0;
   contrl[3] = 1;
   contrl[6] = handle;
   intin[0] = point;
   vdi();
   *chwd    = ptsout[0];
   *chht    = ptsout[1];
   *cellwd  = ptsout[2];
   *cellht  = ptsout[3];
   return(intout[0]);
}



/* v_savecache()
 *==========================================================================
 */
int 
v_savecache( int handle, char *filename )
{
   int i = 0;

   while (*filename)
	intin[i++] = *filename++;

   contrl[0] = 249;
   contrl[1] = 0;
   contrl[3] = i;
   contrl[6] = handle;

   vdi();

   return( intout[0] );
}


/* v_loadcache()
 *==========================================================================
 */
int
v_loadcache( int handle, char *filename, int mode )
{
   int i = 0;

   intin[i++] = mode;

   while (*filename)
	intin[i++] = *filename++;

   contrl[0] = 250;
   contrl[1] = 0;
   contrl[3] = i;
   contrl[6] = handle;

   vdi();

   return( intout[0] );
}





/* v_flushcache()
 *==========================================================================
 */
int  
v_flushcache( int handle )
{
   contrl[0] = 251;
   contrl[1] = 0;
   contrl[3] = 1;
   contrl[6] = handle;

   vdi();
   return( intout[0] );
}




/* vqt_cachesize()
 *==========================================================================
 * Returns the largest block size availalbe in each of the two fsm caches.
 */
void
vqt_cachesize( int handle, int which_cache, long *size )
{
  contrl[0] = 255;
  contrl[1] = 0;
  contrl[3] = 1;
  contrl[6] = handle;
  
  intin[0]  = which_cache;
  
  vdi();
  
  stuffptr( &intout[0], size );
}

