/* FILE:  XOPTIONS.C
 *==========================================================================
 * DATE:  March 2, 1990
 * DESCRIPTION: OPTION CALL handling, such as the about box, info and
 *		options.
 *
 * INCLUDE FILE: XOPTIONS.H
 * 07/07/92 cjg - save and restore mouse form only if AES 3.2 or greater.
 *		  Skip changing mouse form otherwise...
 */


/* INCLUDE FILES
 *==========================================================================
 */
#include <sys\gemskel.h>

#include <string.h>
#include <tos.h>
#include <stdlib.h>

#include "country.h"
#include "xcontrol.h"				/* Xcontrol.c defines   */

#include "cpxdata.h"				/* Keep these in order..*/
#include "xstructs.h"
#include "cpxhandl.h"				

#include "timedate.h"				/* Timedate.c prototypes*/
#include "xcontrl2.h"				/* Xcontrol.c prototypes*/
#include "windows.h"
#include "xerror.h"
#include "sliders.h"
#include "slots.h"
#include "stuffptr.h"
#include "xconfig.h"
#include "mover.h"
#include "text.h"


EXTERN int AES_Version;
EXTERN int gl_ncolors;

/* PROTOTYPES
 *==========================================================================
 */
void save_defaults( void );
void get_defaults( void );
void bputstr( char *str );
void bputcr( void );
void bgetstr( char *str );

void nodetxt_handle( void );
                     
void pop_xdata( void );
void push_xdata( void );

void wait_up( void );

WORD	ChkTouchButton( OBJECT *tree, WORD button );
void	xselect( OBJECT *tree, int base, int obj );
void	xdeselect( OBJECT *tree, int base, int obj );



/* DEFINES
 *==========================================================================
 */
#define OPT_ABOUT	0
#define OPT_XOPTION	1
#define OPT_OPEN	2
#define OPT_INFO	3
#define OPT_UNLOAD	4

#define DIR_MAX		24

#if 0
#define DIR_MAX		25			/* # of chars for dirpath
						 * displayed in text obj
						 */
#endif

#define DFT_MIN_NODES	5			/* Limits for the number */
#define DFT_MAX_NODES	99			/* of default nodes.	 */


/* GLOBALS
 *==========================================================================
 */
typedef struct _xcsave
{
  char dirpath[128];
  int  hour_state;
  int  num_default_nodes;
}XCSAVE;



/* DIRECTORY PATH/XINFO OPTIONS Variables */
char dirpath[ 128 ];		/* CPX directory path master		 */
int  dirsize;			/* text length of path			 */
int  dircount;			/* Used for scrolling..increment counter */
char template[ DIR_MAX + 1 ];	/* path for text object			 */

char tempbuf[128];		/* The SAVE DEFAULT PATH for configs */
char *buff;			/* Ptr to save default buffer        */
int  index;			/* index into the save buffer	     */

char blnkstring[] = "________________________";
/*char blnkstring[] = "_________________________";*/
char dft_name[]   = "CONTROL.INF";

int  num_xoptions;			/* number of xconfig options
					 * visible in the popup menu
				         */

int  buffer_size;			/* The default Buffer size for the
					 * loading of CPXs if none exist
					 */
					 					
int  num_default_nodes;			/* Number of default nodes
					 * Default is 10 if xcontrol.inf
					 * doesn't exist. 
					 * Limits: 5<=X<=99
					 */
					 
char savepath[128];			/* Text string for XCONTROL
					 * Save Defaults
					 */

char nodetext[3] = "XXX";		/* Text string for node num */			 
					 
XCSAVE Xcsave;				/* storage for backup vars
					 * used for a cancel... 
 					 */
 					 
int Dynamic = 0;			/* The flag that decides to
					 * use the loadbufsize ptr
					 * or not.
					 * 0 - Use CPX buffer if necessary
					 * 1 - Don't use buffer, ever
					 */


/* FUNCTIONS
 *==========================================================================
 */
 



/* ABOUT FUNCTIONS
 *==========================================================================
 */
 
/* xopt_about()
 *==========================================================================
 * Initializes ABOUT objects and tree when selected from popup
 */ 
void
xopt_about( void )
{
     OBJECT *tree;
     
     xconfig = OPT_ABOUT;
     xtree   = ( OBJECT *)rs_trindex[ XABOUT ];

     ActiveTree( xtree );
     SetNormal( ABOUTOK );
}


/* do_about_button()
 *==========================================================================
 * Button Handling for the ABOUT panel option
 */
BOOLEAN
do_about_button( int obj )
{
   OBJECT *tree = xtree;
#if 0   
   if( obj == ABOUTOK )
   {
   
      select( tree, ABOUTOK );
      wait_up();
   }   
   return( obj == ABOUTOK );
#endif
  
   if( obj == ABOUTOK ) 
      return( ChkTouchButton( tree,  ABOUTOK ));
   else
      return( FALSE );   
   
}





/* CPX INFORMATION FUNCTIONS
 *==========================================================================
 */
 
/* xopt_info()
 *==========================================================================
 * Initializes objects, trees, variables for INFORMATION panel option
 */ 
void
xopt_info( void )
{
      OBJECT  *tree;
      CPXNODE *curptr;
      
      xconfig = OPT_INFO;
      xtree   = ( OBJECT *)rs_trindex[ CPXSTAT ];
      
      ActiveTree( xtree );
      SetNormal( XEXIT );
      curptr = get_cpx_from_slot();
      
      ObString( CFNAME ) = curptr->fname;
      ObString( CRES )   = stat_string[ curptr->cpxhead.flags.resident ];
      tempbuf[0] =  ( ( curptr->cpxhead.cpx_version >> 12 ) & 0x0F ) + '0'; 
      tempbuf[1] =  ( ( curptr->cpxhead.cpx_version >> 8 ) & 0x0F ) + '0';
      tempbuf[2] = '.';
      tempbuf[3] =  ( ( curptr->cpxhead.cpx_version >> 4 ) & 0x0F ) + '0';
      tempbuf[4] =  ( curptr->cpxhead.cpx_version & 0x0F ) + '0';
        
      tempbuf[5] = '\0';
      ObString( CVERSION ) = tempbuf;
      			
      tempbuf[6] = ( curptr->cpxhead.cpx_id >> 24 ) & 0xFF;
      tempbuf[7] = ( curptr->cpxhead.cpx_id >> 16 ) & 0xFF;
      tempbuf[8] = ( curptr->cpxhead.cpx_id >> 8 )  & 0xFF;
      tempbuf[9] = curptr->cpxhead.cpx_id & 0xFF;
      tempbuf[10] = '\0';
      ObString( CID ) = &tempbuf[6];
}


/* do_info_button()
 *==========================================================================
 * Button Handling for information button panel option
 */
BOOLEAN
do_info_button( int obj )
{
   OBJECT *tree = xtree;

#if 0   
   if( obj == XEXIT )
   {
      select( tree, XEXIT );
      wait_up();
   }   
   return( obj == XEXIT );
#endif

   if( obj == XEXIT )   
      return( ChkTouchButton( tree,  XEXIT ) );
   else
      return( FALSE );   
   
}



/* XCONFIG CONFIGURATION FUNCTIONS
 *==========================================================================
 */
 
/* xopt_option()
 *==========================================================================
 * Initializes objects, trees and variables for the configuration option
 */
void
xopt_option( void )
{ 
     OBJECT *tree;
     
     xconfig = OPT_XOPTION;
     xtree   = ( OBJECT *)rs_trindex[ XINFO ];
     
     ActiveTree( xtree );
     Deselect( OKOPTION );
     Deselect( CANOPT );

     #if USA | UK | SPAIN | FRENCH | ITALY
         TedText( HOUR ) = hour_string[ hour_state ];
     #else
         hour_state = HOUR24;
         HideObj( TIMEBOX );   /* Hide if miltime..24 hours always*/
     #endif    

     my_itoa( nodetext, num_default_nodes, TRUE );
     nodetext[2] = '\0';
     TedText( NODETEXT ) = nodetext;

     dircount = 0;
     dirsize  = ( int )strlen( dirpath ); 
     strcpy( template, blnkstring );
     strncpy( template, dirpath, min( DIR_MAX, dirsize ));
     if( dirsize > DIR_MAX )
       	   template[ DIR_MAX - 1 ] = 0xAF;
     TedText( CPXPATH ) = template;

     /* store originals to safety...*/
     push_xdata();
}



/* xopt_keys()
 *=========================================================================
 * Called ONLY by Xkeys_config().
 * If we are using XINFO and the MOVER/STATUS is displayed, we return to
 * XINFO, otherwise, we return to XCONTROL.
 */
BOOLEAN
xopt_keys( void )
{
   if( mover_keys() )
         return( FALSE );      
   else
      return( TRUE );
}


/* do_option_button()
 *==========================================================================
 * Button Handling for the configuration option
 */
BOOLEAN
do_option_button( int obj )
{
   OBJECT *tree = xtree;
   BOOLEAN redraw_flag = FALSE;
   long  i;
   int   out;
   GRECT rect;

   if( mover_button( obj ) )
          return( redraw_flag );
   
   switch( obj )
   {
      case OKOPTION:if( ChkTouchButton( tree, OKOPTION ) )
      		    {

      		     redraw_flag = TRUE;
		     push_xdata();
/*		     
		     select( xtree, OKOPTION );
		     wait_up();
 */		     
		    }
		    break;
	     
      case CANOPT:		       
		    if( ChkTouchButton( tree, CANOPT ) )
		    {
      		     redraw_flag = TRUE;   /* restore previous settings */
		     pop_xdata();
		     redraw_hour( hour_state );
/*		     
		     select( xtree, CANOPT );
		     wait_up();
 */
 		    }		     
		    break;

      case HOUR:     obj = Pop_Handle( xtree, obj, hour_string, 2, &hour_state, IBM, 10 );
     		     if( obj != -1 )
			redraw_hour( obj );
     		     break;
		      
      case CPXPATH:  ActiveTree( xtree );
      		     wait_up();
      		     
      		     strcpy( newpath, dirpath );
      		     for ( i = strlen( newpath ); i && ( newpath[ i ] != '\\' ); newpath[i--] = '\0' );
      		     out = fsel_name( FALSE, newpath, "*.CPX", title );
      		     if( ( ( out == A_OK ) || ( out == A_CANCEL )) && ( newpath[0] != '\0' ) )
      		     {
      		      	for ( i = strlen( newpath ); i && ( newpath[ i ] != '\\' ); newpath[i--] = '\0' );
			strcpy( dirpath, newpath );
      		        strcat( dirpath, "*.CPX" );
      		        dirsize  =  ( int )strlen( &dirpath[0] );
			strcpy(  template, blnkstring );
			strncpy( template, dirpath, min( DIR_MAX, dirsize) );
      		        dircount = 0;
			if( dirsize > DIR_MAX )
			{
		  	   template[ DIR_MAX - 1 ] = 0xAF;	/* >> */
			   Enable( CPXRIGHT );
			}
      		        TedText( CPXPATH ) = template;
      		        rect = ObRect( CPXPATH );
      		        objc_offset( tree, CPXPATH, &rect.g_x, &rect.g_y );
			Send_Redraw( &rect );
      		     }
      		     break;

		      		     
     case CPXRIGHT:  if(( dirsize > DIR_MAX ) && (( dircount + DIR_MAX ) < dirsize ))
   		     {
     		        ActiveTree( xtree );
     		        dircount++;
			strncpy( template, &dirpath[ dircount ],min( DIR_MAX, dirsize - dircount) );
			template[0] = 0xAE;		/* << */
			if( (dirsize - dircount) > DIR_MAX )
					template[ DIR_MAX - 1 ] = 0xAF;    /* >> */
     		        TedText( CPXPATH ) = template;
     		        Objc_draw( xtree, CPXPATH, 0, NULL );
     		     }
     		     break;
		     		     
     case CPXLEFT:   if( dircount )
     		     {
     		        ActiveTree( xtree );
     		        dircount--;
			strncpy( template, &dirpath[ dircount ], min( DIR_MAX, dirsize - dircount ) );
			if( dircount )
				template[0] = 0xAE;		/* << */
			if(( dirsize - dircount ) > DIR_MAX )
				template[ DIR_MAX - 1 ] = 0xAF;	/* >> */
     		        TedText( CPXPATH ) = template;
     		        Objc_draw( xtree, CPXPATH, 0, NULL );
     		     }
     		     break;
		     		     
		     		     
     case XSAVE:     if( ChkTouchButton( tree, XSAVE ) )
		     {
                        save_defaults();
                     }   
     		     break;		   
     		    
     case RELOAD:    cpx_reload( FALSE );   /* FALSE - Called frm XCONFIG */
     		     break;
		     		     
     case LEFTNODE:		     
     case RTNODE:    sl_arrow( xtree, NBASE, NODETEXT, obj,
     			      (( obj == LEFTNODE ) ? ( -1 ) : ( 1 ) ),
     			      DFT_MIN_NODES, DFT_MAX_NODES,
     			      &num_default_nodes, HORIZONTAL, nodetxt_handle );
      		     break;
 	
     			    
     case STATS:     select( xtree, STATS );
     		     wait_up();
     		     Deselect( STATS );
     		     if( !do_mover() )
			Objc_draw( xtree, STATBASE, MAX_DEPTH, NULL );     		            
      		     break;
      		     
    }
   return( redraw_flag );
}




/* nodetxt_handle()
 *==========================================================================
 * Used for printing the text field in the number of default nodes 
 * setting in options.
 *
 * my_itoa() puts a blank in front of single digit numbers, therefore
 * we increment the index into the text string so that only 1 number is
 * printed.  Otherwise, the text will not be centered for single digits.
 */
void
nodetxt_handle( void )
{
    OBJECT *tree = ( OBJECT *)rs_trindex[ XINFO ];
    
    my_itoa( nodetext, num_default_nodes, TRUE );
    TedText( NODETEXT ) = &nodetext[ ( nodetext[0] == ' ' ) ];
    Objc_draw( tree, NODETEXT, 0, NULL );
    Evnt_timer( 150L );
}




/* push_xdata()
 *==========================================================================
 * Save the XCONFIG options to its saved storage structure
 */
void
push_xdata( void )
{
   strcpy( Xcsave.dirpath, dirpath );
   Xcsave.hour_state        = hour_state;
   Xcsave.num_default_nodes = num_default_nodes;
}




/* pop_xdata()
 *==========================================================================
 * Restore the XCONFIG options from its saved storage structure to
 * its global variables...
 */
void
pop_xdata( void )
{
   strcpy( dirpath, Xcsave.dirpath ); 
   hour_state        = Xcsave.hour_state;
   num_default_nodes = Xcsave.num_default_nodes;
}



/*==========================================================================
 * Save and Retrieve XCONTROL default functions
 *==========================================================================
 */

/* save_defaults()
 *==========================================================================
 * Create a text buffer of our defaults and then write out the buffer to
 * the file 'Xcontrol.inf'. Note: this is for the XCONFIG defaults only.
 *
 * IN:  void
 * OUT: void
 *
 * GLOBAL:   char *buff:      pointer to our 200 byte buffer...
 *           char dirpath[]   directory path for cpxs
 */
void
save_defaults( void )
{
    OBJECT *tree = ( OBJECT *)rs_trindex[ XINFO ];
    int  fd;
    char temp[3];
    
    xselect( tree, ROOT, XSAVE );
    wait_up();
        
    if( XGen_Alert( SAVE_DEFAULTS ) )
    {
       push_xdata();
       buff = (char *)Malloc( 200L );
       if( buff )
       { 
          
          index = 0;
          bputstr( &dirpath[0] );	/* write out directory path */
          bputcr();
          
          temp[0] = hour_state + '0';   /* write out 12/24 hour flag*/
          temp[1] = '\0';
          bputstr( temp );
          bputcr();      

	  temp[2] = '\0';
          my_itoa( temp, num_default_nodes, TRUE );
          bputstr( temp );
          bputcr();

	  temp[0] = Dynamic + '0';
	  temp[1] = '\0';
	  bputstr( temp );
	  bputcr();
	           
          if( ( fd = Fcreate( &savepath[0], 0 )) > 0 ) 
          {
             MFsave( MFSAVE, &mfOther );
	     if( AES_Version >= 0x0320 )	/* cjg 07/07/92 */
                graf_mouse( BUSYBEE, 0L );
	     Fwrite( fd, (long)strlen( buff ), buff  );
	     MFsave( MFRESTORE, &mfOther );
	     Fclose( fd );            
	  }
	  else
	     XGen_Alert( FILE_ERR );
	  Mfree( buff );
       }
       else
          XGen_Alert( MEM_ERR );
    }
    xdeselect( tree, ROOT, XSAVE );

}





/* get_defaults()
 *==========================================================================
 * Get the XCONFIG defaults at bootup time of XCONTROL. Source is either
 * at C:\ or A:\.
 *
 * IN:   void
 * OUT:  void
 *
 * GLOBAL:   char savepath[]:     Save defaults directory path
 *           char dirpath[]:      Directory path for cpxs
 *           char *buff:	  ptr to save defaults buffer
 */
void
get_defaults( void )
{
   int  drv, fd;
   DTA  thedta, *saved;
   char temp[2];
      
   drv = (( Drvmap() & 4L ) ? ( 2 ) : ( 0 ) );
   savepath[0] = drv + 'A';
   strcat( savepath, ":\\" );
   strcat( savepath, dft_name );
   
   saved = Fgetdta();
   Fsetdta( &thedta );
   if( Fsfirst( savepath, 0 ) <= -1 )
   {						/* Can't find file */	
     dirpath[0] = drv + 'A';
     strcat( dirpath, ":\\*.CPX" );
     num_default_nodes = MIN_NODES;
     hour_state        = HOUR24;


     /* If the AES version Number is >= to AES_VERSION ( 3.01 )
      * then we shall NOT use a CPX buffer as the default.
      * Otherwise, we shall allocate a CPX buffer.
      */
     if( AES_Check() )
     	Dynamic = 1;		/* Don't allocate Buffer */
     else
        Dynamic = 0;		/* Allocate Buffer       */
   }
   else
   {
   	/* When getting the defaults from the Control.INF file,
   	 * we shall use whatever the dynamic flag was set to.
   	 */
        buff = (char *)Malloc( thedta.d_length );
        if( buff )
        {
           fd = Fopen( savepath, 0 );
           Fread( fd, thedta.d_length, buff );
           Fclose( fd );
           
	   index = 0;           
 	   bgetstr( dirpath );               /* get directory path   */
          
           bgetstr( temp );		     /* get 12/24 hour toggle*/
     	   #if USA | UK | SPAIN | FRENCH
 	          hour_state = temp[0] - '0';
 	   #else
 	   	  hour_state = HOUR24;
 	   #endif       
           
           bgetstr( temp );		     /* get min num of nodes */
           num_default_nodes = my_atoi( temp );

	   bgetstr( temp );		/* Dynamic flag */
	   Dynamic = temp[0] - '0';
	   
   	   Mfree( buff );
        }
        else
          XGen_Alert( MEM_ERR );
   }
   Fsetdta( saved );
}





/* bputstr()
 *==========================================================================
 * Put a string INTO the XCONFIG default buffer
 */
void
bputstr( char *str )
{
   while( *str )
	buff[index++] = *str++;       
}


/* bputcr()
 *==========================================================================
 * Put a carriage return into the XCONFIG default buffer
 */
void
bputcr( void )
{
   buff[index++] = 0x0D;
   buff[index++] = 0x0A;
   buff[index] = '\0';
}



/* bgetstr()
 *==========================================================================
 * Get a string from the default buffer bypassing carriage returns
 */
void
bgetstr( char *str )
{
   while( buff[index] != 0x0D )
   	*str++ = buff[index++];
   index++;				/* bypass 0x0d */
   index++;				/* bypass 0x0a */
   *str++ = '\0';
}





/* EXECUTE CPX FUNCTIONS
 *==========================================================================
 */
 
/* xopt_open()
 *==========================================================================
 * Execute a cpx option from popup menu
 */
void
xopt_open( void )
{
    int item;
    
    item = get_active_slot_obj();
    handle_cpx( item, 2 );
    clear_xconfig();
}




/* UNLOAD CPX FUNCTIONS
 *==========================================================================
 */
 
/* xopt_unload()
 *==========================================================================
 * Unload from the nodes the chosen cpx
 */
void
xopt_unload( void )
{
    unload_cpx();
    clear_xconfig();
}



/* wait_up()
 *==========================================================================
 * Wait for Up Button
 */
void
wait_up( void )
{
   MRETS m;
   
   Evnt_button( 1, 1, 0, &m );
}



/* xopt_shutdown();
 *==========================================================================
 * Shutdown XCONTROL by releasing the slot memory.
 */
void
xopt_shutdown( void )
{
   int msg[4];
   
   if( XGen_Alert( SHUTDOWN ) )
   {
      Clear_All_Nodes(); /* This will also clear baseptr */
      clear_xconfig();
   
      /* We close our window and everything related to it.
       * We have already released the nodes.
       * XControl will be unable to be executed again until a rez change
       * or a reboot.
       */
      msg[3] = w.id;
      Wm_Closed( msg );
   }   
}




WORD
ChkTouchButton( OBJECT *tree, WORD button )
{
    MRETS mk;
    WORD  dummy; 
    WORD  obj;
    GRECT rect;
/*
    wind_update( BEG_MCTRL );
 */
    xselect( tree, ROOT, button );			

    graf_mkstate( &mk.x, &mk.y, &mk.buttons, &mk.kstate );
    while( mk.buttons )
    {
      obj = objc_find( tree, ROOT, MAX_DEPTH, mk.x, mk.y );
      if( obj != button )
      {
         if( tree[ button ].ob_state & SELECTED )
	     xdeselect( tree, ROOT, button );
      }
      else
      {
         if( !( tree[ button ].ob_state & SELECTED ) )
	     xselect( tree, ROOT, button );
      }
      graf_mkstate( &mk.x, &mk.y, &mk.buttons, &mk.kstate );
    }
    evnt_button( 1, 1, 0, &dummy, &dummy, &dummy, &dummy );
    obj = objc_find( tree, ROOT, MAX_DEPTH, mk.x, mk.y );
    if( obj != button )
       xdeselect( tree, ROOT, button );
/*
    wind_update( END_MCTRL );
 */
    return( obj == button );
}


void
xselect( OBJECT *tree, int base, int obj )
{
    GRECT rect;
    
    tree[ obj ].ob_state |= SELECTED;
    rect = ObRect( obj );
    objc_offset( tree, obj, &rect.g_x, &rect.g_y );
    rect.g_x -= 2;
    rect.g_y -= 2;
    rect.g_w += 4;
    rect.g_h += 4;
    Objc_draw( tree, base, MAX_DEPTH, &rect ); /* NOTE THIS! */
}

void
xdeselect( OBJECT *tree, int base, int obj )
{
    GRECT rect;
    
    tree[ obj ].ob_state &= ~SELECTED;
    rect = ObRect( obj );
    objc_offset( tree, obj, &rect.g_x, &rect.g_y );
    rect.g_x -= 2;
    rect.g_y -= 2;
    rect.g_w += 4;
    rect.g_h += 4;
    Objc_draw( tree, base, MAX_DEPTH, &rect ); /* NOTE THIS! */
}

