/* FILE:  CACHEOPT.C
 * ======================================================================
 * DATE:  October 25, 1990
 *	  July    12, 1991
 *
 * DESCRIPTION: Handle LOAD\APPEND\SAVE\CLEAR Cache Buffer
 *
 * The Character Cache is wot is calculated.
 * The Miscellaneous Cache is the main number.
 *
 * INCLUDE FILE: CACHEOPT.H
 */


/* INCLUDE FILES
 * ======================================================================
 */
#include "fsmhead.h"
#include "country.h"
#include "fsm.h"
#include "text.h"

#include "mainstuf.h"

#include "fsmio.h"
#include "fsmacc.h"
#include "outline.h"
#include "ptbind.h"

#include "extend.h"
#include "lex.h"
#include "fileio.h"


/* PROTOTYPES
 * ======================================================================
 */
void Do_Cache_Options( void );
int  CacheButton( int button, WORD *msg );
void Get_Default_Cache( void );
void Calc_Cache( BOOLEAN draw );

/* from gdostst.s */
long	 gdos_tst( void );


/* DEFINES
 * ======================================================================
 */


/* EXTERN
 * ======================================================================
 */
extern Token lookahead;


/* GLOBALS
 * ======================================================================
 */
char cache_path[ 128 ];
char *cache_text[] = { "Load Cache Buffer",
		       "Merge Cache Buffer",
		       "Save Cache Buffer",
		       "Clear Cache Buffer"
		    };  

/* The initial device will be set to the Boot device */
char	def_path[] = "c:\\extend.sys";
char    dex_path[128];

char    data_cache_text[ 6 ];
char    bitmap_cache_text[6];

long    dcache_size;	/* actual usage of the data and bitmap cache */
long    bcache_size;	/* in KBYTES....			     */

/* FUNCTIONS
 * ======================================================================
 */


/* Do_Cache_Options()
 * ======================================================================
 */
void
Do_Cache_Options( void )
{
   PrevTree = Maintree;
   Reset_Tree( CacheTree );
   
   Calc_Cache( FALSE );
   Objc_draw( tree, ROOT, MAX_DEPTH, NULL );   		  
}



/* CacheButton()
 * ======================================================================
 */
int
CacheButton( int button, WORD *msg )
{
  int quit = FALSE;
  int out;
     
  if( ( button != -1 ) && ( button & 0x8000 ) )
     button &= 0x7FFF;      

  switch( button )
  {
     case CACHEOK:  Deselect( CACHEOK );
		    Reset_Tree( PrevTree );     
		    Objc_draw( tree, ROOT, MAX_DEPTH, NULL );   		  
     		    break;

     case LCACHE:
     case MCACHE:
     case SCACHE:   Deselect( button );
     		    sprintf( cache_path, "%s\\", Current.FontPath );
     		    out = fsel_name( FALSE, cache_path, "*.FSM", cache_text[ button - LCACHE ] );
		    
     		    if( ( ( out == A_OK ) || ( out == A_CANCEL )) && ( cache_path[0] != '\0' ) )
     		    {
     		        if( out == A_OK )
     		        {
     		           if( open_vwork() )
     		           {
     		             switch( button )
     		             {
     		                case LCACHE: out = v_loadcache( vhandle, cache_path, TRUE );
     		              		     break;
     		              		   
     		                case MCACHE: out = v_loadcache( vhandle, cache_path, FALSE ); /* append, merge */
     		               		     break;
     		               		   
     		                case SCACHE: out = v_savecache( vhandle, cache_path );
     		              		     break;
     		                default:
     		                         break;
     		              }
     		              if( out == -1 )
     		              	   form_alert( 1, alert19 );
     		              close_vwork();

     		            }
     		            else
	     		         form_alert( 1, alert18 );
     		        }
		    }
   		    Objc_draw( tree, button, MAX_DEPTH, NULL );
		    Calc_Cache( TRUE );
     		    break;
     		    
     case CCACHE:   if( form_alert( 1, alert17 ) == 1 )
     		    {
     		      if( open_vwork())
     		      {
     		         if( v_flushcache( vhandle ) == -1 )
     		              form_alert( 1, alert19 );	
     		         close_vwork();
     		      }
     		      else
     		         form_alert( 1, alert18 );
 		      Calc_Cache( TRUE );
     		    }  
     		    deselect( tree, button );
     		    break;

     		  
     default:	if( button == -1 )
     		{
     		   switch( msg[0] )
     		   {
     		     case WM_REDRAW: 
     		     		     break;
     			     	
     		     /* Don't care about canceling or oking the values
     		      * here, because, the cpx is gone gone gone otherwise
     		      */		     		     
     		     case AC_CLOSE:  quit = TRUE;
     		     		     break;
     				     		     
     		     case WM_CLOSED: quit = TRUE;
				     do_write_extend( FALSE );
				     break;

		     case CT_KEY:
		     		     break;
       		     default:
     		     		break;
     		   }
     		}
     		break;
  }
  
  return( quit );
}



/* Get_Default_Cache()
 * ======================================================================
 */
void
Get_Default_Cache( void )
{
    int  out;
    int  error;
    long tst = '_FSM';
    int  gdos_flag;
    char Drive;
    long len;
    DTA  *olddma, newdma;	/* DTA buffers for _our_ searches */
            
    gdos_flag = (( gdos_tst() != tst ) ? ( FALSE ) : ( TRUE ) );
    if( gdos_flag )
    {
       /* Get the Bootup Device */
       Supexec( GetBootDevice );
       Drive = BootDevice + 'A';
       def_path[0] = Drive;   

       olddma = Fgetdta();	
       Fsetdta(&newdma);		/* Point to OUR buffer  */

       xopen( def_path );	/* Find the extend.sys file and open it*/
       if( !errno )		/* WE have an EXTEND.SYS and need to */
       {			/* look for the font path	     */
       
         lookahead = NO_TOKEN;
         if( !match(PATH) )
         {
	    /* Error: No Path line at the top of the extend.sys file
	     * Therefore, we don't load any default.fsm file.
	     */
	    xclose();
            Fsetdta(olddma);		/* Point to OLD buffer */
	    return;	 
         }
         skipequal();

         if( match(PATHSPEC) )
         {
	    strncpy( dex_path, yytext, yyleng );
	    len = yyleng-1;
	    if( dex_path[len] != '\\' ) ++len;
	      dex_path[len] = '\0';
	    if( len > 2 )	/* below code fails for items like 'f:'*/
	    {
	       if( !stat(dex_path, &statbuf) )
	          errno = (isdir(&statbuf)) ? 0 : ENOTDIR;
	       if( errno )
	       {
	          /* Error Parsing the path */    
	          xclose();
                  Fsetdta(olddma);		/* Point to OLD buffer */
	          return;
	       }
	    }  
         }
         
         xclose();
         Fsetdta(olddma);		/* Point to OLD buffer */

         strcat( dex_path, "\\DEFAULT.FSM" );
         error = Fopen( dex_path, 0 );
	 if ( error < 0 )		/* No such files! */
   	    return;			

	 Fclose( error );	/* Close the file immediately */       
	 
         if( open_vwork() )
         {
            out = v_loadcache( vhandle, dex_path, TRUE );
            if( out == -1 )	/* Cache I/O Error! */
	         form_alert( 1, alert19 );      
	         
            close_vwork();
         }  /* error opening a workstation, no cache loaded..*/   
       }/* NO EXTEND.SYS, NO default cache */
   }
}


/* Calc_Cache()
 * ======================================================================
 * Calculates and inquires the current size available of the 
 * FSM Data cache and the FSM bitmap cache.
 */
void
Calc_Cache( BOOLEAN draw )
{
   if( open_vwork() )
   {
     vqt_cachesize( vhandle, 1, &dcache_size );
     vqt_cachesize( vhandle, 0, &bcache_size );
     dcache_size /= 1024L;
     bcache_size /= 1024L;     
     close_vwork();
   }
   else
   {
     form_alert( 1, alert18 );
     dcache_size = bcache_size = 0L;
   }  
   sprintf( data_cache_text, "%ldK", dcache_size );
   TedText( DCACHE ) = data_cache_text;
   
   sprintf( bitmap_cache_text, "%ldK", bcache_size );
   TedText( BMAP ) = bitmap_cache_text;
   
   if( draw )
   {
      Objc_draw( tree, DCACHE, MAX_DEPTH, NULL );
      Objc_draw( tree, BMAP, MAX_DEPTH, NULL );
   }
}
