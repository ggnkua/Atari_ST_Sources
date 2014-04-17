/* COOKIE.C
 *==========================================================================
 * DATE: March 12, 1990
 * Get Cookie Routine for XCONTROL
 * INCLUDE FILE: COOKIE.H
 */

/* INCLUDE FILES
 *==========================================================================
 */
#include <sys\gemskel.h>
#include <tos.h>


/* PROTOTYPES
 *==========================================================================
 */
int  cdecl Get_Cookie( long cookie, long *p_value );
long getcookie( void );

/* GLOBALS
 *==========================================================================
 */
/* We use globals because we can't pass variables using Supexec()   */
long cookie;		/* The Cookie that we are looking for	    */
long *p_value;		/* The value returned if the cookie is found*/
int  result;		/* Result - TRUE or FALSE		    */



/* Get_Cookie()
 *==========================================================================
 * The Entry point for inquiring a cookie.
 * IN: long Cookie:		The Cookie that we are looking for 
 *     long *P_Value:		Contains the value upon exit	      
 *
 * OUT: int:			Returns TRUE or FALSE	      
 */
int
cdecl
Get_Cookie( long Cookie, long *P_Value )
{
     cookie  = Cookie;
     p_value = P_Value;
     
     Supexec( getcookie );   
     return( result );
}



/* getcookie()
 *==========================================================================
 * The actual get_cookie() routine. Note that it is Supexec()'d.
 */
long
getcookie( void )
{
    long *cookiejar;
    
    cookiejar = *(long **)0x05a0L;
    
    /* no jar found at all */
    if (cookiejar == NULL )
    {
      result = FALSE;
      return 0L;
    }
    
    /* Use do/while here so you can match the zero entry itself */
    do {
    	if ( *cookiejar == cookie )
    	{
    	   /* found it! */
    	   if (p_value != NULL ) *p_value = *(cookiejar + 1);
    	   
    	   /* return nonzero for success */
    	   result = TRUE;
    	   return 1L;
    	}
    	else cookiejar += 2;
    	
    } while( *cookiejar != 0 );
    
    /* return 0 (failed ) */
    result = FALSE;
    return 0L;
}


