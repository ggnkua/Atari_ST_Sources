/* ===================================================================
 * FILE: CACHE.C
 * ===================================================================
 * DATE: December 9, 1992
 * 
 * DESCRIPTION: Fonts ACC
 *
 * This file handles the Cache settings dialog box.
 *
 * COMPILER: TURBO C Version 2.0
 */
 

/* INCLUDE FILES
 * ===================================================================
 */
#include <sys\gemskel.h>
#include <tos.h>
#include <linea.h>
#include <string.h>
#include <stdio.h>

#include "country.h"
#include "fonthead.h"
#include "fonts.h"
#include "mainstuf.h"
#include "text.h"
#include "fsmio.h"
#include "mover.h"
#include "front.h"
#include "ptbind.h"
#include "extend.h"
#include "lex.h"
#include "fileio.h"
#include "status.h"




/* STRUCTURES
 * ===================================================================
 */


/* EXTERN
 * ===================================================================
 */
extern int AES_Version;
extern Token lookahead;



/* PROTOTYPES
 * ===================================================================
 */
void	DoCache( void );
int	HandleCache( int button, WORD *msg );

void	Get_Default_Cache( void );
void	Calc_Cache( BOOLEAN draw );
long	limits( long num, long min_num, long max_num );
void	Up_Down_Arrow( int obj, int UpButton, char *text, long *num, int NBase );
void	DoValuesCheck( void );



/* DEFINES
 * ===================================================================
 */
#define SPEEDO_PERCENT_MIN	1	/* 10% Speedo CACHE/BITMAP */
#define SPEEDD_PERCENT_MAX	9	/* 90% Speedo CACHE/BITMAP */
#define MAX_CACHE_SIZE	99999L
#define MIN_CACHE_SIZE	10L
#define MIN_CHAR_CACHE_SIZE 1L


/* GLOBALS
 * ===================================================================
 */
char    cache_path[ 128 ];
char    data_cache_text[ 6 ];	/* Unused Miscellaneous Cache Text */
char    bitmap_cache_text[6];	/* Unused Character Cache Text     */

long    dcache_size;	/* actual usage of the data and bitmap cache */
long    bcache_size;	/* in KBYTES....			     */

char	CharSizeText[6];	/* Character Cache Text */
char	MiscSizeText[6];	/* Miscellaneous Cache Text */
char    BitSizeText[6];		/* Bitmap Size Text */
long	OldBitMapSize;

int	OldPercent;		/* Speedo Percent...*/
int	CurPercent;
long	OldSpeedoCache;		/* Old Speedo Cache Size */
long    ccache;			/* Character Cache Size */
long    mcache;			/* Miscellaneous Cache Size */
long    old_ccache;
long    old_mcache;

long	CurUsage;
char    CurSizeText[6];

/* FUNCTIONS
 * ===================================================================
 */


/* DoCache()
 * ===================================================================
 */
void
DoCache( void )
{
   long extra;
   long interim;
   
    Reset_Tree( ad_cache );

   /* ------------------------------------------------------
    * Handle the Cache I/O Boxes and the Unused Cache...
    * ------------------------------------------------------
    */
    Enable( LCACHE );
    Enable( MCACHE );
    Enable( SCACHE );
    Enable( CCACHE );
    MakeExit( LCACHE );
    MakeExit( MCACHE );
    MakeExit( SCACHE );
    MakeExit( CCACHE );
   
    Enable( CUTITLE );
    Enable( CUNUSED );
    Enable( MUTITLE );
    Enable( MUNUSED );
    
    dcache_size = bcache_size = 0L;
    sprintf( data_cache_text, "%5ldK", dcache_size );
    TedText( MUNUSED ) = data_cache_text;

    /* Character Cache */   
    sprintf( bitmap_cache_text, "%5ldK", bcache_size );
    TedText( CUNUSED ) = bitmap_cache_text;
    
    if( !SpeedoFlag )
    {
       Disable( LCACHE );
       Disable( MCACHE );
       Disable( SCACHE );
       Disable( CCACHE );
       NoExit( LCACHE );
       NoExit( MCACHE );
       NoExit( SCACHE );
       NoExit( CCACHE );
       
       Disable( CUTITLE );
       Disable( CUNUSED );
       Disable( MUTITLE );
       Disable( MUNUSED );
    }    
    else
      Calc_Cache( FALSE );


   /* ------------------------------------------------------
    * Handle the Cache Sizes...
    * ------------------------------------------------------
    */
   OldPercent  = CurPercent = Current.speedo_percent;
   OldSpeedoCache = Current.SpeedoCacheSize;
   
   /* Set the Speedo Character Cache */   
   interim = Current.speedo_percent * Current.SpeedoCacheSize;
   extra   = ( interim % 10L ) > 5L;
   ccache  = ( interim / 10L ) + extra;
   
   ccache = limits( ccache, MIN_CHAR_CACHE_SIZE, MAX_CACHE_SIZE );	   
   old_ccache = ccache;
   sprintf( CharSizeText,"%5ld", ccache );
   TedText( CSIZE ) = CharSizeText;

   /* Display a size based on a percentage of the Misc CACHE Size */
   interim  =  (10L - (long)Current.speedo_percent ) * Current.SpeedoCacheSize;
   extra    = ( interim % 10L ) > 5L;
   mcache   = ( interim / 10L ) + extra;
   mcache    = limits( mcache, MIN_CACHE_SIZE, MAX_CACHE_SIZE );	   
   old_mcache = mcache;
   sprintf( MiscSizeText, "%5ld", mcache );
   TedText( MSIZE ) = MiscSizeText;


   /* Set the Bitmap Font Cache */
   Current.BitMapCacheSize = limits( Current.BitMapCacheSize, 0L, MAX_CACHE_SIZE );	   
   OldBitMapSize = Current.BitMapCacheSize;
   sprintf( BitSizeText,"%5ld", Current.BitMapCacheSize );
   TedText( BSIZE ) = BitSizeText;


   /* Handle Getting the Current Minimum Amount of Miscellanous Required */
   CurUsage = GetCurUsage();
   sprintf( CurSizeText, "%5ldK", CurUsage );
   TedText( CACHEMIN ) = CurSizeText;
   
   Objc_draw( tree, ROOT, MAX_DEPTH, NULL ); 
}



/* HandleCache()
 * ===================================================================
 */
int
HandleCache( int button, WORD *msg )
{
   int   quit;
   int	 out;   
   int   error;
        
   quit   = FALSE;

   
   /* Handle Double-clicking of the objects */   
   if( ( button != -1 ) && ( button & 0x8000 ) )
      button &= 0x7FFF;
   
   switch( button )
   {
     case CCANCEL: Current.SpeedoCacheSize = OldSpeedoCache;
		   Current.speedo_percent  = OldPercent;
		   Current.BitMapCacheSize = OldBitMapSize;
   
     case COK:    Deselect( button );
     		  if( button == COK )
     		  {
     		     DoValuesCheck();
		     CacheCheck();
     		  }
     		  
	  	  Reset_Tree( ad_options );     
		  Objc_draw( tree, ROOT, MAX_DEPTH, NULL ); 
     		  break;

     case LCACHE:
     case MCACHE:
     case SCACHE:  if( SpeedoFlag )
     		   {
     		     sprintf( cache_path, "%s\\", OutlinePath );
     		          		     
     		     out = fsel_name( FALSE, cache_path, "*.SPC", cache_text[ button - LCACHE ] );
		    
     		     if( ( ( out == A_OK ) || ( out == A_CANCEL )) && ( cache_path[0] != '\0' ) )
     		     { 
     		        if( out == A_OK )
     		        {
     		           /* Check if the file exists first */
	     		   if(( button == LCACHE ) || ( button == MCACHE ))
     		           {
			      olddma = Fgetdta();	
			      Fsetdta( &newdma );		/* Point to OUR buffer */

			      error = Fsfirst( cache_path, 0 );/* Normal file search for 1st file */
			      if( error != E_OK )	/* No such files! */
		 	      { 
			        Fsetdta( olddma );	/* Point to OLD buffer */
			        form_alert( 1, nofile );	   
			        XDeselect( tree, button );
			        return( quit );		
			      }
     		           }
     		        
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
		     Calc_Cache( TRUE );
		    } 
	            XDeselect( tree, button );
     		    break;
     		    
     case CCACHE:   if( SpeedoFlag )
     		    {
     		       if( form_alert( 1, alert17 ) == 1 )
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
     		    }  
     		    XDeselect( tree, button );
     		    break;


     case MUP:
     case MDOWN:    Up_Down_Arrow( button, MUP, &MiscSizeText[0], &mcache, MSIZE );
     		    break;

     case BUP:
     case BDOWN:    Up_Down_Arrow( button, BUP, &BitSizeText[0], &Current.BitMapCacheSize, BSIZE );
		    break;

     case CUP:
     case CDOWN:    Up_Down_Arrow( button, CUP, &CharSizeText[0], &ccache, CSIZE );
		    break;

     default:	 if( button == -1 )
     		 {
     		   switch( msg[0] )
     		   {
     		     case WM_REDRAW: 
     		     		     break;
     			     		     
     		     case AC_CLOSE:  quit = TRUE;
     		     		     break;
     				     		     
     		     case WM_CLOSED: quit = TRUE;
				     DoValuesCheck();
     		     		     CloseWindow();
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
    char Drive;
    long len;
            
    if( SpeedoFlag )
    {
       /* Get the Bootup Device */
       strcpy( ExtendPath, "C:\\EXTEND.SYS" );
       Drive = GetBaseDrive();
       ExtendPath[0] = Drive;   

       olddma = Fgetdta();	
       Fsetdta(&newdma);		/* Point to OUR buffer  */

       xopen( ExtendPath );	/* Find the extend.sys file and open it*/
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
	    strncpy( OutlinePath, yytext, yyleng );
	    len = yyleng-1;
	    if( OutlinePath[len] != '\\' ) ++len;
	      OutlinePath[len] = '\0';
	    if( len > 2 )	/* below code fails for items like 'f:'*/
	    {
	       if( !stat( OutlinePath, &statbuf) )
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

         strcat( OutlinePath, "\\DEFAULT.SPC" );
         error = Fopen( OutlinePath, 0 );
	 if ( error < 0 )		/* No such files! */
   	    return;			

	 Fclose( error );	/* Close the file immediately */       
	 
         if( open_vwork() )
         {
            out = v_loadcache( vhandle, OutlinePath, TRUE );
            if( out == -1 )	/* Cache I/O Error! */
	         form_alert( 1, alert19 );      

            close_vwork();
         }  /* error opening a workstation, no cache loaded..*/   
         else
            form_alert( 1, alert18 );
            
       }/* NO EXTEND.SYS, NO default cache */
   }
}


/* Calc_Cache()
 * ======================================================================
 * Calculates and inquires the current size available of the 
 * Speedo Data cache and the Speedo bitmap cache.
 */
void
Calc_Cache( BOOLEAN draw )
{
   if( SpeedoFlag )
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
     /* Miscellaneous Cache */  
     sprintf( data_cache_text, "%5ldK", dcache_size );
     TedText( MUNUSED ) = data_cache_text;

     /* Character Cache */   
     sprintf( bitmap_cache_text, "%5ldK", bcache_size );
     TedText( CUNUSED ) = bitmap_cache_text;
   
     if( draw )
     {
       Objc_draw( tree, CUNUSED, MAX_DEPTH, NULL );
       Objc_draw( tree, MUNUSED, MAX_DEPTH, NULL );
     }
   }
}


/* limits()
 * ====================================================================
 */
long
limits( long num, long min_num, long max_num )
{
    if( num > max_num )
    	    num = max_num;
    	
    if( num < min_num )
            num = min_num;
    return( num );    
}



/* Up_Down_Arrow()
 * ====================================================================
 * Handle the up and down arrow presses in the outline font dialog
 * for the cache settings.
 */
void
Up_Down_Arrow( int obj, int UpButton, char *text, long *num, int NBase )
{
   MRETS mk;
   long  min_cache;
   
   XSelect( tree, obj );

   *num = atol( text );
   min_cache = (( UpButton == BUP ) ? ( 0L ) : ( MIN_CACHE_SIZE ) );   
   
   if( UpButton == CUP )
      min_cache = MIN_CHAR_CACHE_SIZE;   
   
   *num = limits( *num, min_cache, MAX_CACHE_SIZE );
   do
   {
      Evnt_timer( 50L );
   
      
      if( obj == UpButton )
         *num = (((*num + 1) > MAX_CACHE_SIZE ) ? ( MAX_CACHE_SIZE ) : ( *num + 1 ) );
      else
         *num = (((*num - 1) < min_cache ) ? ( min_cache ) : ( *num - 1 ) );

      sprintf( text, "%5ld", *num );
      Objc_draw( tree, NBase, MAX_DEPTH, NULL );
      Graf_mkstate( &mk );
      
   }while( mk.buttons );
   
   XDeselect( tree, obj );
}



/* DoValuesCheck()
 * ====================================================================
 */
void
DoValuesCheck( void )
{
   long  half;
   int   extra;

   /* Speedo Character Stuff */		       
   ccache = atol( CharSizeText );
   if( !ccache )
      ccache = old_ccache;
   ccache = limits( ccache, MIN_CHAR_CACHE_SIZE, MAX_CACHE_SIZE );	   

   /* Speedo Miscellaneous Stuff */
   mcache = atol( MiscSizeText );
   if( !mcache )
       mcache = old_mcache;
   mcache = limits( mcache, MIN_CACHE_SIZE, MAX_CACHE_SIZE );	   

   /* Get Speedo Cache Size */
   Current.SpeedoCacheSize = ccache + mcache;
	       
   /* Get Percent Value */
   Current.speedo_percent = 0;
   half     =  Current.SpeedoCacheSize / 2L;
   extra    =  ((( ccache * 10L ) % Current.SpeedoCacheSize) > half );
   CurPercent =  (int)(( ccache * 10L ) / Current.SpeedoCacheSize);
   Current.speedo_percent = CurPercent + extra;
   Current.speedo_percent = (int)limits( (int)Current.speedo_percent, 1L, 9L );	   
		        
   /* Get BitMap Cache Size */
   Current.BitMapCacheSize = atol( BitSizeText );
   Current.BitMapCacheSize = limits( Current.BitMapCacheSize, 0L, MAX_CACHE_SIZE );	   

   /* A Real Change has occurred, so set change flag */
   if( ( Current.SpeedoCacheSize != OldSpeedoCache ) ||
       ( Current.speedo_percent  != OldPercent ) ||
       ( Current.BitMapCacheSize != OldBitMapSize ) )
       SetChangeFlag();
}
