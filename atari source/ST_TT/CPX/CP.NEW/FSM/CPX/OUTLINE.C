/* FILE:  OUTLINE.C
 * ====================================================================
 * CREATED:  August 16, 1990  cjg
 * MODIFIED: June   26, 1991  cjg
 *           July   11, 1991  cjg
 *
 * DESCRIPTION: 
 *
 * INCLUDE FILE: OUTLINE.H
 */


/* INCLUDE FILES
 * ====================================================================
 */
#include "fsmhead.h"
#include "country.h"

#include "fsmio.h"

#include "fsm.h"
#include "fsm2.h"

#include "..\cpxdata.h"
#include "mover.h"
#include "points.h"
#include "text.h"
#include "fsmcache.h"

#include "status.h"

extern XCPB *xcpb;		/* XControl Parameter Block   */

struct foobar {
	WORD	dummy;
	WORD	*image;
	};

/* TYPE DEFINITIONS
 * ====================================================================
 */

/* Structure to store the global variables required for EXTEND.SYS */
typedef struct fsm
{
   char FontPath[ 128 ];	/* Font Directory Path             */
   char SymbolFont[ 15 ];	/* Symbol Font filename - w/o .QFM */
   char HebrewFont[ 15 ];	/* Hebrew Font filename - w/o .QFM */
   BOOLEAN SymbolFlag;		/* Symbol Flag to display filename */
   BOOLEAN HebrewFlag;		/* Hebrew Flag to display filename */
   long FSMCacheSize;		/* FSM Cache Size		   */
   long BITCacheSize;		/* BITmap Cache Size		   */
   int  fsm_percent;		/* Percentage (1-9) for fsm cache  */
   int  Width;			/* Width Tables?		   */
   int  point_size[ MAX_DEV + 2 ]; /* Point Sizes of Current font  */
}XFSM;





/* PROTOTYPES
 * ====================================================================
 */
void	Do_Font_Setup( void );
int	Outline_Buttons( int button, WORD *msg );
void	Up_Down_Arrow( int obj, int UpButton, char *text, long *num, int NBase );
void	wait_up( void );
void	push_outline( void );
void 	pop_outline( void );
void	Check_Symbols( void );
BOOLEAN SetSymbols( BOOLEAN *flag, int Text, int Title, char *filename, char *title_field, BOOLEAN draw_flag );
BOOLEAN SymButton( char *filename, int Title, int Text, char *title_field, BOOLEAN *flag );
void	CopyXFSM( XFSM *src, XFSM *dst );

void	SymHebFontChange( void );


/* DEFINES
 * ====================================================================
 */
#define MAX_CACHE_SIZE	99999L
#define MIN_CACHE_SIZE	10L
#define DEFAULT_POINTS  1						 

#define DIR_MAX		21

#define NUM_SYMBOL_FONTS 	7


/* GLOBALS
 * ====================================================================
 */
char dirpath[ 128 ];
char newpath[ 128 ];
char view_path[ DIR_MAX + 1 ];
int  dircount;
int  dirsize;

char underbar[] = "_____________________";

char Bit_Cache_Text[ 7 ];
char FSM_Cache_Text[ 7 ];

/* These are the current Symbol and Hebrew Fonts that I know of...*/
char *syms[] = { "Crescendo",
		 "Hebrew",
		 "LucidaHebrew",
		 "LucidaHebrew-Typewriter",
		 "LucidaSymbol",
		 "Symbol",
		 "ZapfDingbats"
	       };
	       
XFSM Current;			/* Current EXTEND.SYS variables */
XFSM Backup;			/* Backup EXTEND.SYS variables  */

BOOLEAN Symbol_Change;		/* Flag to display symbol change alert
				 * Will show only once. Initialized in
				 * initialize() in FSM.C	      
				 */

BOOLEAN Old_Make_Width_Flag;				 
BOOLEAN Make_Width_Flag;	/* Flag ( if TRUE ) to make prompt the
				 * user to make width tables after the
				 * extend.sys is written out. Init to
				 * FALSE at initialize() time. Once set
				 * to TRUE, will always be TRUE unless
				 * a person makes width tables.
				 */				

	       
/* FUNCTIONS
 * ====================================================================
 */


/* Check_Symbols()
 * ====================================================================
 * Check if the Symbol and Hebrew Fonts are found in the linked list.
 * Next, remove all Symbol and Hebrew fonts that we know of from the
 * linked list....
 */
void
Check_Symbols( void )
{
     int i;
     FON_PTR curptr;

     if( Current.SymbolFont[0] && !FindFontOnDisk( &Current.SymbolFont[0] ) )
     {
        Current.SymbolFont[0] = '\0';
        Current.SymbolFlag = FALSE;   
     }
     
     if( Current.HebrewFont[0] && !FindFontOnDisk( &Current.HebrewFont[0] ) )
     {
        Current.HebrewFont[0] = '\0';
        Current.HebrewFlag = FALSE;
     }
     
     /* remove from the lists the symbol fonts */
     for( i = 0; i < NUM_SYMBOL_FONTS; i++ )
     {
        do	/* this will remove symbol fonts that are duplicated*/
        {
           curptr = find_font( syms[i] );
           if( curptr )
               Remove_Font( curptr );
        }while( curptr );       
     }
}



/* Do_Font_Setup()
 * ====================================================================
 * Setup the variables for outline tree dialog.
 */
void
Do_Font_Setup( void )
{
     Undo_Fnodes( hdptr, ( FON_PTR )NULL );

     Reset_Tree( Oxtree );  
     
     /* Setup the variables appropriately for the OUTLINE Font Setup */
     /* Width Table */
     ObString( WIDTHFLG ) = width_text[ Current.Width ];

     /* Font Directory Path */
     strcpy( dirpath, Current.FontPath );
     strcat( dirpath, "\\*.QFM");

     dircount = 0;
     dirsize = ( int )strlen( dirpath );
     
     strcpy( view_path, underbar );
     strncpy( view_path, dirpath, ( DIR_MAX, dirsize ) );
     if( dirsize > DIR_MAX )
     	  view_path[ DIR_MAX - 1 ] = 0xAF;
     TedText( FSMPATH ) = view_path;


     /* Hebrew and Symbol Font Setup */
     SetSymbols( &Current.SymbolFlag, SYMTEXT, SYMTITLE, Current.SymbolFont, title_symbol, FALSE );
     SetSymbols( &Current.HebrewFlag, HEBTEXT, HEBTITLE, Current.HebrewFont, title_hebrew, FALSE );

     Objc_draw( tree, ROOT, MAX_DEPTH, NULL );
                             
     push_outline();   		  
}



/* SetSymbols()
 * ====================================================================
 * Sets the flags and buttons for the outline dialog box Symbol and
 * Hebrew font setups. See above when they are used.
 * Also used when the user selects the button to enable/disable the
 * symbol/hebrew font.
 */
BOOLEAN
SetSymbols( BOOLEAN *flag, int Text, int Title, char *filename, char *title_field, BOOLEAN draw_flag )
{
   BOOLEAN out_flag;
   
   ObString( Text ) = &none_text[0];
   Disable( Title );
   Disable( Text );
   out_flag = TRUE;
   
   if( *flag )
   {
      Enable( Title );
      Enable( Text );
   
      if( *filename )
        ObString( Text ) = filename;
      else
        out_flag = SymButton( filename, Title, Text, title_field, flag );
   }
   
   if( draw_flag )
   {
      Objc_draw( tree, Title, MAX_DEPTH, NULL );
      Objc_draw( tree, Text, MAX_DEPTH, NULL );
      return( out_flag );
   }
   return( FALSE );  
}



/* SymButton()
 * ====================================================================
 * Handles the routine when the Symbol Text button or Hebrew Text button
 * is pressed. A file selector is brought up to allow the user to select
 * a new Symbol font or Hebrew font.
 */
BOOLEAN
SymButton( char *filename, int Title, int Text, char *title_field, BOOLEAN *flag )
{
  int  out;
  long i;
    
  if( !IsDisabled( Text ) )
  {
     Deselect( Text );
     strcpy( newpath, dirpath );
     for( i = strlen( newpath ); i && ( newpath[i] != '\\'); newpath[ i-- ] = '\0' );
     if( strlen( filename ) )
     {
        strcat( newpath, filename );
        strcat( newpath, ".QFM" );
     }  
     out = fsel_name( FALSE, newpath, "*.QFM", title_field );
     if( ( ( out == A_OK ) || ( out == A_CANCEL )) && ( newpath[0] != '\0' ) )
     {
        if( out == A_OK )
        {
  	  for( i = strlen( newpath ); i && ( newpath[i] != '.'); newpath[ i-- ] = '\0' );
          newpath[i--] = '\0';
 	  for( i = strlen( newpath ); i && ( newpath[i] != '\\'); i-- );
	  strcpy( filename, &newpath[ i + 1 ] );     		          
	  ObString( Text ) = filename;
     	}
     	else
     	{ /* Clicked on OK with no filename, so we'll put none there */
     	  filename[0] = '\0';
     	  ObString( Text ) = &none_text[0];
          out = A_OK;
     	}  
  	Objc_draw( tree, Text, MAX_DEPTH, NULL );
        Change_Flag = TRUE;
    }
  }
  if( !(*filename) )
  {
    Disable( Title );
    Disable( Text );
    *flag = FALSE;
    Objc_draw( tree, Title, MAX_DEPTH, NULL );
    Objc_draw( tree, Text, MAX_DEPTH, NULL );
    Change_Flag = TRUE;
  }
  return( out == A_OK );
}



/* Outline_Buttons()
 * ====================================================================
 * Handle the button events for the outline font dialog.
 */
int
Outline_Buttons( int button, WORD *msg )
{
  int quit = FALSE;
  int out;
  long i;
  MRETS mk;

  if( ( button != -1 ) && ( button & 0x8000 ) )
      button &= 0x7FFF;      
  
  switch( button )
  {
     case OCANCEL:pop_outline();	/* restore */
     		   
     case OEXIT:  Deselect( button );
		  if( OEXIT == button )
		  {
		     /* Read in ONLY if new directory path */
		     if( strcmp( Current.FontPath, Backup.FontPath ) )
		     {
		       MF_Save();
		       push_outline();
		       Scan_Message( ad_scan, TRUE );
		       read_fonts( 1 );
		       Scan_Message( ad_scan, FALSE );
		       pop_outline();
		       MF_Restore();
		     }  
		  }
		  Return_To_Maintree( Maintree );
     		  break;

     case SETCACHE: deselect( tree, SETCACHE );
     		    Do_Cache_Size();
     		    break;

     case DEFPOINT: Deselect( button );
     		    Do_Point_Sizes( 0, DEFAULT_POINTS );
		    break;
     
     case FSMLEFT:  select( tree, FSMLEFT );
     		    do
     		    {
     		       Graf_mkstate( &mk );
     		       if( dircount )
     		       {
     		         dircount--;
     		         strncpy( view_path, &dirpath[ dircount ], min( DIR_MAX, dirsize - dircount ) );
     		         if( dircount )
     		       	   view_path[0] = 0xAE;
     		         if((dirsize - dircount ) > DIR_MAX )
     		       	   view_path[ DIR_MAX - 1 ] = 0xAF;
     		         TedText( FSMPATH ) = view_path;
     		         Objc_draw( tree, FSMPATH, MAX_DEPTH, NULL );
     		       }  
     		    }while( mk.buttons );
     		    deselect( tree, FSMLEFT );
     		    break;
     		    
     case FSMRIGHT: select( tree, FSMRIGHT );
     		    do
     		    {
     		       Graf_mkstate( &mk );
  		       if( ( dirsize > DIR_MAX ) && ((dircount + DIR_MAX ) < dirsize ))
  		       {
  		          dircount++;
  		          strncpy( view_path, &dirpath[ dircount], min( DIR_MAX, dirsize - dircount) );
  		          view_path[0] = 0xAE;
  		          if( (dirsize - dircount) > DIR_MAX )
  		          	view_path[ DIR_MAX - 1 ] = 0xAF;
  		          TedText( FSMPATH ) = view_path;
  		          Objc_draw( tree, FSMPATH, MAX_DEPTH, NULL );
  		       }	   		    
     		    }while( mk.buttons );
     		    deselect( tree, FSMRIGHT );
     		    break;
     		    
     case FSMPATH:  wait_up();
    		    strcpy( newpath, dirpath );
    		    for( i = strlen( newpath ); i && ( newpath[i] != '\\'); newpath[ i-- ] = '\0' );
     		    out = fsel_name( FALSE, newpath, "*.QFM", title_fsmpath );
     		    if( ( ( out == A_OK ) || ( out == A_CANCEL )) && ( newpath[0] != '\0' ) )
     		    {
	     	         for( i = strlen( newpath ); i && ( newpath[i] != '\\'); newpath[ i-- ] = '\0' );
	     	         
  		         strcpy( dirpath, newpath );
  		         
  		         newpath[i] = '\0';	/* Get rid of the '\\' */
  		         strcpy( Current.FontPath, newpath );
  		         
  		         strcat( dirpath, "*.QFM" );
  		         dirsize = (int)strlen( &dirpath[0] );
  		         strcpy( view_path, underbar );
  		         strncpy( view_path, dirpath, min( DIR_MAX, dirsize) );
  		         dircount = 0;
  		         if( dirsize > DIR_MAX )
  		            view_path[ DIR_MAX - 1 ] = 0xAF;
		         TedText( FSMPATH ) = view_path;
		         Objc_draw( tree, FSMPATH, MAX_DEPTH, NULL );
                         Change_Flag = TRUE;
		    }
		    break;
		    
     case WIDTHFLG: Current.Width ^= TRUE;
    		    deselect( tree, button ); 
		    ObString( WIDTHFLG ) = width_text[ Current.Width ];
    		    Objc_draw( tree, WIDTHFLG, MAX_DEPTH, NULL );
                    Change_Flag = TRUE;
                    CacheCheck( 0 );
     		    break;
  
     		    
     case SYMFLAG:  Current.SymbolFlag ^= TRUE;
                    if( SetSymbols( &Current.SymbolFlag, SYMTEXT, SYMTITLE, Current.SymbolFont, title_symbol, TRUE ) )
			SymHebFontChange();
   		    deselect( tree, SYMFLAG );
                    Change_Flag = TRUE;
		    break;
		         
     case HEBFLAG:  Current.HebrewFlag ^= TRUE;
		    if( SetSymbols( &Current.HebrewFlag, HEBTEXT, HEBTITLE, Current.HebrewFont, title_hebrew, TRUE ))
			SymHebFontChange();
    		    deselect( tree, HEBFLAG );
                    Change_Flag = TRUE;
     		    break;     	 	              

     case SYMTEXT:  if( SymButton( Current.SymbolFont, SYMTITLE, SYMTEXT, title_symbol, &Current.SymbolFlag ) )
			SymHebFontChange();
     		    break;

     case HEBTEXT:  if( SymButton( Current.HebrewFont, HEBTITLE, HEBTEXT, title_hebrew, &Current.HebrewFlag ) )
			SymHebFontChange();
     		    break;

     default:	if( button == -1 )
     		{
     		   switch( msg[0] )
     		   {
     		     case WM_REDRAW: 
     		     		     break;
     			     		     
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



/* SymHebFontChange()
 * ====================================================================
 * Called whenever the Symbol or Hebrew Font is changed, turned on
 * or turned off.
 */
void
SymHebFontChange( void )
{
#if 0
     Current.Width = FALSE;
     ObString( WIDTHFLG ) = width_text[ Current.Width ];
/*   Objc_draw( tree, WIDTHFLG, MAX_DEPTH, NULL );*/

     CacheCheck( 0 ); /* Do I need to check if the cache is large enuf? NO!*/
#endif
     
     /* This is to prevent the warning from popping up all the time.
      * It will show ONCE and that is that. It is initialized when
      * the CPX or desk accessory is first opened.
      */
     if( !Symbol_Change )
     {
         Objc_draw( tree, ROOT, MAX_DEPTH, NULL );
         form_alert( 1, sym_alert );
     }    
     Symbol_Change   = TRUE;	
     Make_Width_Flag = TRUE;    /* Make sure we prompt for a make
     				 * width tables after an extend.sys
     				 */
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
   
   select( tree, obj );

   *num = atol( text );
   min_cache = (( UpButton == BUP ) ? ( 0L ) : ( MIN_CACHE_SIZE ) );   
   
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
   
   deselect( tree, obj );
}



/* wait_up()
 * ====================================================================
 * Wait for an up button.
 */
void
wait_up( void )
{
   MRETS m;
   
   Evnt_button( 1, 1, 0, &m );
}



/* push_outline()
 * ====================================================================
 * Save the variables!
 */
void
push_outline( void )
{
    CopyXFSM( &Current, &Backup );        
}




/* pop_outline()
 * ====================================================================
 * Restore the variables
 */
void
pop_outline( void )
{
    CopyXFSM( &Backup, &Current );        
}




/* CopyXFSM()
 * ====================================================================
 * Copies the XFSM structure from one to the other.
 * Used for saving the original and restoring from backup.
 */
void
CopyXFSM( XFSM *src, XFSM *dst )
{
   int i;
   
   strcpy( dst->FontPath, src->FontPath );
   strcpy( dst->SymbolFont, src->SymbolFont );
   strcpy( dst->HebrewFont, src->HebrewFont );
   dst->SymbolFlag   = src->SymbolFlag;
   dst->HebrewFlag   = src->HebrewFlag;
   dst->FSMCacheSize = src->FSMCacheSize;
   dst->BITCacheSize = src->BITCacheSize;
   dst->fsm_percent  = src->fsm_percent;
   dst->Width        = src->Width;
   
   for( i = 0; i < MAX_DEV; i++ )
       dst->point_size[ i ] = src->point_size[ i ];    
}
