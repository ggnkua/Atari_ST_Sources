/* PRINTER.C
 *==========================================================================
 * DATE: March 16, 1990
 *	 January 14, 1993	Handle new 3D format
 *
 * DESCRIPTION: PRINTER CPX
 */

/* The printer CPX will inquire and set the printer port attributes
 *
 *      Item		      0			1
 *     -------------------------------------------------------
 *     Printer Type:	   Dot Matrix	      Daisy Wheel
 *     Printer Color:	   Monochrome	      Color
 *     Lines Per Inch:	   Atari - 1280       Epson - 960
 *     Output Quality:	   Final	      Draft
 *     Paper Type:	   Feed		      Single Sheets
 *     Printer Port:	   Parallel	      Serial Port
 *
 * Call Setprt() to set and inquire the configuration of the printer port
 *
 *     To Inquire:    int Setprt( -1 );
 *     To Set:	      Setptr( int value );
 *
 *     Bit	      Description
 *    -----	      --------------------------
 *      0	      Printer type
 *	1	      Printer Color
 *	2	      Lines Per Inch
 *	3	      Output Quality
 *	4	      Paper Type
 *	5	      Printer Port
 *      6-14          Reserved
 *	15	      Reserved
 */

 
 
/* INCLUDE FILES 
 *==========================================================================
 */
#include <sys\gemskel.h>
#include <tos.h>
#include <string.h >

#include "country.h"

#include "printer.h"
#include "printer.rsh"

#include "..\cpxdata.h"




/* DEFINES
 *==========================================================================
 */	
 
typedef struct _prt	/*             Setting               */
{			/*       0                    1      */
  int cur_type;		/*  Dot Matrix    	  Daisy	     */
  int cur_color;	/*  Black and White	  Color	     */
  int cur_pixel;	/*  ATARI - 1280          Epson - 960*/
  int cur_quality;	/*  Final 		  Draft	     */
  int cur_port;		/*  Parallel		  Serial     */
  int cur_paper;	/*  Feed		  Single     */
}PRT;



/* PROTOTYPES
 *==========================================================================
 */
void     set_objects( void );
int      Pop_Handle( int button, char *items[], int num_items, int *default_item, int font_size, int width );
BOOLEAN  cdecl cpx_call( GRECT *rect );
CPXINFO	*cdecl cpx_init( XCPB *Xcpb );

void	 Set_Printer( PRT *value );
void	 Get_Printer( PRT *value );

void	 push_data( void );
void	 pop_data( void );

void	 Redraw_Objects( void );
void	 do_redraw( OBJECT *tree, int obj );


void	 open_vwork( void );
void	 close_vwork( void );

void	 MakeActivator( int xtree, int obj );

/* EXTERNALS
 *==========================================================================
 */
extern PRT save_vars;


/* GLOBALS
 *==========================================================================
 */
char *pix_array[]     = { "1280",
   		          "960"
		        };


/* COUNTRY:
 *==========================================================================
 */
#if USA | UK
   char *type_array[]    = { "Dot",
			     "Daisy"
			   };
			   
   char *color_array[]   = { "B/W",
			     "Color"
		           };

   char *quality_array[] = { "Draft",
			     "Final"
			   };

   char *paper_array[]   = { "Feed",
			     "Single"
		           };

   char *port_array[]    = {"Printer",
		            "Modem"
	                   };

#endif



/* COUNTRY: ITALY
 *==========================================================================
 */
#if ITALY
   char *type_array[]    = { "Matrice",
			     "Margh."
			   };
			   
   char *color_array[]   = { "B/N",
			     "Colore"
		           };

   char *quality_array[] = { "Bozza",
			     "Lettera"
			   };

   char *paper_array[]   = { "Modulo",
			     "Singolo"
		           };

   char *port_array[]    = {"Stamp.",
		            "Modem"
	                   };

#endif



/* COUNTRY: GERMAN
 *==========================================================================
 */
#if GERMAN
   char *type_array[]    = { "Matrix",
			     "Typenrad"
			   };
			   
   char *color_array[]   = { "S/W",
			     "Farbe"
		           };

   char *quality_array[] = { "Test",
			     "Maximum"
			   };

   char *paper_array[]   = { "Endlos",
			     "Einzel"
		           };

   char *port_array[]    = {"Drucker",
		            "Seriell"
	                   };

#endif



/* COUNTRY: FRENCH
 *==========================================================================
 */
#if FRENCH
   char *type_array[]    = { "Matric.",
			     "Margu."
			   };
			   
   char *color_array[]   = { "N/B",
			     "Couleur"
		           };

   char *quality_array[] = { "Epreuve",
			     "D‚fini"
			   };

   char *paper_array[]   = { "Continu",
			     "Feuille"
		           };

   char *port_array[]    = {"Imprim.",
		            "Modem"
	                   };

#endif



/* COUNTRY: SPAIN
 *==========================================================================
 */
#if SPAIN
   char *type_array[]    = { "Matric.",
			     "Daisy"
			   };
			   
   char *color_array[]   = { "B/N",
			     "Color"
		           };

   char *quality_array[] = { "Draft",
			     "Final"
			   };

   char *paper_array[]   = { "Cont.",
			     "Suelto"
		           };

   char *port_array[]    = {"Impres.",
		            "Modem"
	                   };

#endif






/* COUNTRY: SWEDEN
 *==========================================================================
 */
#if SWEDEN
   char *type_array[]    = { "Matris",
			     "Typhjul"
			   };
			   
   char *color_array[]   = { "S/V",
			     "F„rg"
		           };

   char *quality_array[] = { "Enkel",
			     "H”gsta"
			   };

   char *paper_array[]   = { "Bana",
			     "Ark"
		           };

   char *port_array[]    = {"Printer",
		            "Modem"
	                   };

#endif




/* GLOBALS
 *==========================================================================
 */			
char blanks[20][20];	       /* For use with Popup handling   */
char *blank[20];

XCPB *xcpb;
CPXINFO cpxinfo;

PRT old_value, cur_value;


int AES_Version;
int gl_ncolors;

/* VDI arrays */
int	contrl[12], intin[128], intout[128], ptsin[128], ptsout[128],
	work_in[12], work_out[57];
int	vhandle=-1;		/* virtual workstation handle */
int	hcnt=0;			/* handle count */



/* FUNCTIONS
 *==========================================================================
 */
 

/* cpx_init() 
 *==========================================================================
 * Initialize the cpx
 */		
CPXINFO
*cdecl cpx_init( XCPB *Xcpb )
{
    OBJECT *tree;
    
    xcpb = Xcpb;
    if( xcpb->booting )
    {
      old_value = cur_value = save_vars;
      
      Set_Printer( &cur_value );
      return( ( CPXINFO *)TRUE );  
    }
    else
    {
      appl_init();
      AES_Version = _GemParBlk.global[0];
    
      if( !xcpb->SkipRshFix )  
             (*xcpb->rsh_fix)( NUM_OBS, NUM_FRSTR, NUM_FRIMG, NUM_TREE,
                              rs_object, rs_tedinfo, rs_strings,
                              rs_iconblk, rs_bitblk, rs_frstr, rs_frimg,
                              rs_trindex, rs_imdope );

       /* Get the current printer configuration port settings
        * Currently, we use these values, 
        * Should we instead slam the hardware with OUR settings instead?
        */
       Get_Printer( &cur_value );
       old_value = cur_value;
       push_data();


      open_vwork();
      close_vwork();
      gl_ncolors = work_out[13];

      if( !xcpb->SkipRshFix )  
      {
        if(( AES_Version >= 0x0330 )
           && ( gl_ncolors > LWHITE ))
        {
           tree  = (OBJECT *)rs_trindex[PRINTER];
           MakeActivator( PRINTER, PSAVE );
           MakeActivator( PRINTER, POK );
           MakeActivator( PRINTER, PCANCEL );
        }
      }       
       cpxinfo.cpx_call   = cpx_call;
       cpxinfo.cpx_draw   = NULL;
       cpxinfo.cpx_wmove  = NULL;
       cpxinfo.cpx_timer  = NULL;
       cpxinfo.cpx_key    = NULL;
       cpxinfo.cpx_button = NULL;
       cpxinfo.cpx_m1 	  = NULL;
       cpxinfo.cpx_m2	  = NULL;
       cpxinfo.cpx_hook   = NULL;
       cpxinfo.cpx_close  = NULL;
       return( &cpxinfo );
    }
}



/* set_objects()
 *==========================================================================
 * Set the text buttons
 */
void
set_objects( void )
{
     OBJECT *tree  = (OBJECT *)rs_trindex[PRINTER];

     TedText( PTYPE )   = type_array[ cur_value.cur_type ];
      
     TedText( COLOR )   = color_array[ cur_value.cur_color ];

     TedText( PIXLINE ) = pix_array[ cur_value.cur_pixel ];    
          
     TedText( QUALITY ) = quality_array[ cur_value.cur_quality ];

     TedText( PORT )    =  port_array[ cur_value.cur_port ];

     TedText( PAPER )   = paper_array[ cur_value.cur_paper ];
     
}



/* cpx_call()
 *==========================================================================
 * Execute the cpx using Xform_do
 */
BOOLEAN
cdecl cpx_call( GRECT *rect )
{
     int button;
     int quit = 0;
     OBJECT *tree  = (OBJECT *)rs_trindex[PRINTER];
     WORD   msg[8];
     GRECT  xrect;
     
     ObX( ROOT ) = rect->g_x;
     ObY( ROOT ) = rect->g_y;
     set_objects();
     Objc_draw( tree, ROOT, MAX_DEPTH, NULL );
     do
     {
	button = (*xcpb->Xform_do)( tree, 0, msg );
     	switch( button )
     	{
     		case PSAVE:	if( (*xcpb->XGen_Alert)( SAVE_DEFAULTS ) )
     				{
     		 		   (*xcpb->CPX_Save)( &cur_value, sizeof( PRT ) );
     		 		   push_data();
     		 		   Set_Printer( &cur_value );
     		 		}
     		 		Deselect( PSAVE );
     		 		xrect = ObRect( PSAVE );
     		 		objc_offset( tree, PSAVE, &xrect.g_x, &xrect.g_y );
     		 		xrect.g_x -= 2;
     		 		xrect.g_y -= 2;
     		 		xrect.g_w += 4;
     		 		xrect.g_h += 4;
     		 		Objc_draw( tree, PSAVE, MAX_DEPTH, &xrect );
#if 0     		 		   
     				deselect( tree, PSAVE );
#endif     				
     				break;
     				
     		case POK:	quit = POK;
     				Set_Printer( &cur_value );
     				Deselect( POK );
     				break;
     						
     		case PCANCEL:	quit = PCANCEL;
     				pop_data();
     				Deselect( PCANCEL );
     				break;




#if GERMAN
		case PTYPE:	Pop_Handle( PTYPE, type_array, 2, &cur_value.cur_type, IBM, 11 );
				break;
#endif

#if FRENCH | SPAIN | SWEDEN | ITALY
		case PTYPE:	Pop_Handle( PTYPE, type_array, 2, &cur_value.cur_type, IBM, 10 );
				break;
#endif				


#if USA | UK
		case PTYPE:	Pop_Handle( PTYPE, type_array, 2, &cur_value.cur_type, IBM, 8 );
				break;
#endif     






#if FRENCH     				
     		case COLOR:	Pop_Handle( COLOR, color_array, 2, &cur_value.cur_color, IBM, 10 );
     				break;
#endif

#if ITALY
     		case COLOR:	Pop_Handle( COLOR, color_array, 2, &cur_value.cur_color, IBM, 9 );
				break;
#endif				

#if USA | UK | SPAIN | GERMAN | SWEDEN
     		case COLOR:	Pop_Handle( COLOR, color_array, 2, &cur_value.cur_color, IBM, 8 );
     				break;
#endif



		case PIXLINE:	Pop_Handle( PIXLINE, pix_array, 2, &cur_value.cur_pixel, IBM, 8 );
     				break;






#if GERMAN | FRENCH | ITALY
		case QUALITY:	Pop_Handle( QUALITY, quality_array, 2, &cur_value.cur_quality, IBM, 10 );
     				break;
#endif

#if SWEDEN
		case QUALITY:	Pop_Handle( QUALITY, quality_array, 2, &cur_value.cur_quality, IBM, 9 );
				break;
#endif

#if USA | UK | SPAIN
		case QUALITY:	Pop_Handle( QUALITY, quality_array, 2, &cur_value.cur_quality, IBM, 8 );
     				break;
#endif     						


#if ITALY
		case PAPER:	Pop_Handle( PAPER, paper_array, 2, &cur_value.cur_paper, IBM, 10 );
				break;
#endif
				
#if USA | UK | SPAIN | GERMAN | FRENCH
		case PAPER:	Pop_Handle( PAPER, paper_array, 2, &cur_value.cur_paper, IBM, 9 );
     				break;
#endif

#if SWEDEN
		case PAPER:	Pop_Handle( PAPER, paper_array, 2, &cur_value.cur_paper, IBM, 8 );
				break;
#endif




#if ITALY
     		case PORT:	Pop_Handle( PORT, port_array, 2, &cur_value.cur_port, IBM, 9 );
     				break;
#else
     		case PORT:	Pop_Handle( PORT, port_array, 2, &cur_value.cur_port, IBM, 10 );
     				break;
#endif
     		default:	if( button == -1 )
     				{
     				   switch( msg[0] )
     				   {
     				     case WM_REDRAW: Redraw_Objects();
     				     		     break;
     				     		     
     				     case AC_CLOSE:  quit = PCANCEL;
     				     		     pop_data();
     				     		     break;
     				     		     
     				     case WM_CLOSED: quit = POK;
     				     		     Set_Printer( &cur_value );
						     break;
     				     default:
     				     		break;
     				   }
     				}
				break;
     		
     	}
     }while( !quit);
     
     return( FALSE );
}



/* Pop_Handle()
 *==========================================================================
 * Set up the text strings for pop_handle, and then show popup menu
 */
int
Pop_Handle( int button, char *items[], int num_items, int *default_item, int font_size, int width )
{
   GRECT butn, world;
   
   int  i;
   int  obj;
   long max = 0L;
   OBJECT *tree = (OBJECT *)rs_trindex[ PRINTER ];
   int small = FALSE;
     
   butn = ObRect( button );
   objc_offset( tree, button, &butn.g_x, &butn.g_y );
   world = ObRect( ROOT );
   objc_offset( tree, ROOT, &world.g_x, &world.g_y ); 
   
   
   for( i = 0; i < num_items; i++ )
   {
       if( strlen( items[i] ) > max )
       	 	max = strlen( items[i] );
   }
   if( max <= 3 )
   	small = TRUE;
   		   
   for( i = 0; i < num_items; i++ )
   {
      if( small )
        strcpy( &blanks[i][0], "   " );
      else
        strcpy( &blanks[i][0], "  ");		/* get 2 blank spaces */
      strcat( &blanks[i][0], items[ i ]);	/* copy the string    */
      do
      {
         strcat( &blanks[i][0], " ");
      }while( strlen( &blanks[i][0] ) < width );
      blank[i] = &blanks[i][0];
   }
   obj = (*xcpb->Popup)( blank, num_items, *default_item, font_size, &butn, &world );

   if( obj != -1 )
      	*default_item = obj;
   TedText( button ) = items[ *default_item ];
   Objc_draw( tree, button, 0, NULL );
   
   
    /* When an item is set ( that isn't the save function )
     * Immediately slam the hardware.
     * Don't worry tho, Cancel and ACC_CLOSE will restore if necessary
     */   	
   if( button != PSAVE )
    	   Set_Printer( &cur_value );
   return( obj );
}






/* Set_Printer()
 *==========================================================================
 * Set the Printer configuration port
 */
void
Set_Printer( PRT *value )
{
   int current;
   current = Setprt( -1 );

   /* Clear out bits 0 - 5 but keep 6 - 15 */
   current &= 0xffc0;

   /* OR in the values to preserve bits 6 - 15 */            
   current |= (
                 value->cur_type |
               ( value->cur_color   << 1 ) |
	       ( value->cur_pixel   << 2 ) |
	       ( value->cur_quality << 3 ) |
	       ( value->cur_port    << 4 ) |
	       ( value->cur_paper   << 5 )
	      );
   Setprt( current );	      
}





/* Get_Printer()
 *==========================================================================
 * Get the current configuration port settings.
 */
void
Get_Printer( PRT *value )
{
    int current;

    current = Setprt( -1 );
    value->cur_type    =  ( current & 0x01 );
    value->cur_color   = (( current >> 1 ) & 0x01 );
    value->cur_pixel   = (( current >> 2 ) & 0x01 );
    value->cur_quality = (( current >> 3 ) & 0x01 );
    value->cur_port    = (( current >> 4 ) & 0x01 );
    value->cur_paper   = (( current >> 5 ) & 0x01 );
}



/* push_data()
 *==========================================================================
 * Save the current config structure to its backup
 */
void
push_data( void )
{
    old_value = cur_value;
}



/* pop_data()
 *==========================================================================
 * restore the backup config structure to the current structure
 * Reset the Printer configuration Port
 */
void
pop_data( void )
{
    cur_value = old_value;
    Set_Printer( &cur_value );
}


void
Redraw_Objects( void )
{
   OBJECT *tree = ( OBJECT *)rs_trindex[ PRINTER ];
   PRT oldnums;
   
   oldnums = cur_value;
   
   Get_Printer( &cur_value );
   set_objects();
   
   if( oldnums.cur_type != cur_value.cur_type )
   	do_redraw( tree, PTYPE );
   	
   if( oldnums.cur_color != cur_value.cur_color )
   	do_redraw( tree, COLOR );
   	
   if( oldnums.cur_pixel != cur_value.cur_pixel )
        do_redraw( tree, PIXLINE );
        
   if( oldnums.cur_quality != cur_value.cur_quality )
        do_redraw( tree, QUALITY );
        
   if( oldnums.cur_port != cur_value.cur_port )
   	do_redraw( tree, PORT );

   if( oldnums.cur_paper != cur_value.cur_paper )
   	do_redraw( tree, PAPER );
}




void
do_redraw( OBJECT *tree, int obj )
{
   GRECT *xrect;
   GRECT rect;
   GRECT t;
   
   t = ObRect( obj );
   objc_offset( tree, obj, &t.g_x, &t.g_y );   
   
   xrect = (*xcpb->GetFirstRect)( &t );
   while( xrect )
   {
    	rect = *xrect;
        Objc_draw( tree, obj, MAX_DEPTH, &rect );
        xrect = (*xcpb->GetNextRect)();
   };   
}



/*
 * Open virtual workstation
 */
void
open_vwork( void )
{
  int i;
  
  if (hcnt == 0) {
  	for (i = 1; i < 10;)
    	work_in[i++] = 1;
  	work_in[0] = Getrez() + 2;
  	work_in[10] = 2;
  	vhandle = xcpb->handle;
  	v_opnvwk(work_in, &vhandle, work_out);
  }
  hcnt++;
}


/*
 * Close virtual workstation
 */
void
close_vwork(void)
{
    hcnt--;
    if( !hcnt )
    {
 	v_clsvwk(vhandle);
	vhandle = -1;
    }
}



void
MakeActivator( int xtree, int obj )
{
   OBJECT *tree;
   
   tree = ( OBJECT *)rs_trindex[ xtree ];
   
   ObFlags( obj ) |= IS3DOBJ;
   ObFlags( obj ) |= IS3DACT;
}
