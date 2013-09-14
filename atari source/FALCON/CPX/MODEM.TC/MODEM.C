/* MODEM.C
 *==========================================================================
 * DATE: March 9, 1990
 *	 January 14, 1993   Handle new 3D format
 * DESCRIPTION: MODEM CPX
 */

/* There are now 4 ports on the TT versus 1 port on an ST/STe/Mega
 * There are also 3 ports on the Mega STE
 *
 * Rsconf( -2, -1, -1, -1, -1 ) with TOS 1.4 or greater will return
 * 				the current Baud rate 0-15 in the low word
 *
 * Rsconf( -1, -1, -1, -1, -1 ) will return a long containing the
 * 				UCR, RSR, TSR and SCR in that order.
 *
 * UCR defines are:
 *	7	6	5	4	3	2	1	0      bits
 *     ---     ---     ---     ---     ---     ---     ---     ---     ----
 *     Don't  |           |   |		  |    |	  |    unused
 *     Touch  |           |   |           |    |          |
 *            |___________|   |___________|    |__________|
 *                  |               |                |
 *                  |               |              PARITY
 *		    |               |            2  1
 *		    |               |           ------
 *                  |               |            0  0      No   Parity
 *                  |               |            0  1      No   Parity
 *                  |               |            1  0      Odd  Parity  
 *		    |               |            1  1      Even Parity
 *                  |            Stop Bits
 *		    |	        4  3
 *		    |          ------
 *		    |           0  0    0   Stop Bits
 *		    |           0  1    1   Stop Bits
 *		    |	        1  0    1.5 Stop Bits
 *		    |           1  1    2   Stop Bits
 *		    | 
 *              Word Length
 *	       6  5
 *	      ------
 *             0  0   8 bits
 *             0  1   7 bits
 *             1  0   6 bits
 *             1  1   5 bits
 *
 * On a TT ONLY, done by checking the cookie for _MCH == 0x2xxxxL
 * we can call:
 *               xbios( (int)0x2c, PORT# );
 *
 * to switch the serial port mask.
 * MEGA STE is 0x10010L
 * The port numbers are:						On Box
 *                              6	ST Serial Port ( 68901 )	Modem 1
 *			        7 	Channel B      ( SCC chip )	Modem 2
 *				8	TT Serial Port ( 68901 )	Serial 1
 *				9	Channel A      ( SCC chip )	Serial 2
 *			       -1       Return current setting
 * When calling this routine, it returns the previous setting.
 *
 * MODEM.CP Settings:
 *
 *
 *      BAUD RATE:    	0    -   19200 baud
 *                     ...
 *		        15   -   50 baud
 *
 *      FLOW CONTROL:   0   -	None
 *		        1   -   Xon/Xoff
 *			2   -   Rts/Cts
 *
 *   See the corresonding UCR values. MODEM.CP will adjust these to match
 *   whenever it reads/writes to the ports.
 *
 *      Parity:	        0   -	None
 *			1   -   Odd
 *			2   -   Even
 *
 *      Stop Bits:	0   -   0   Stop Bits
 *			1   -   1   Stop Bits
 *			2   -   1.5 Stop Bits
 *			3   -   2   Stop Bits
 * 
 *      Word Length:    0   -   8 Bits/Char
 *                      1   -   7
 *                      2   -   6
 *                      3   -   5
 *
 * LAN PORT - If on a TT or MEGA STE, Channel A can either be
 *	      a serial port or the LAN port.
 *
 *	    - Bit 7 of the PSG determines this
 *	      Bit 7 == 1 ==>   Use as Serial Port
 *	      Bit 7 == 0 ==>   LAN IN USE
 *
 *	    - When the LAN is in use, do not read or write to
 *	      Channel A
 */
 
 
/* INCLUDE FILES 
 *==========================================================================
 */
#include <sys\gemskel.h>
#include <tos.h>
#include <string.h >

#include "country.h"

#include "struct.h"

#include "modem.h"
#include "modem.rsh"

#include "..\cpxdata.h"
#include "ports.h"


/* PROTOTYPES
 *==========================================================================
 */
CPXINFO	*cdecl cpx_init( XCPB *Xcpb );
BOOLEAN  cdecl cpx_call( GRECT *rect );

void     set_objects( int port );

int      Pop_Handle( int button, char *items[], int num_items,
                     int *default_item, int font_size, int width );

void	 push_data( void );
void 	 pop_data( void );


BOOLEAN  IsTT( void );
BOOLEAN  IsSTE( void );
void	 Select_Ok( void );

void	 Set_Machine_Code( void );

long	 Get_OS( void );
BOOLEAN  Check_OS( void );

void	 Redraw_Objects( void );
void	 do_redraw( OBJECT *tree, int obj );

BOOLEAN  IsLanActive( void );
void	 Set_Number_Of_Ports( void );

int	 Get_Active_Port( void );
int	 Set_Active_Port( int cur_port );

void	 Check_Port_Change( void );

void	 close_vwork(void);
void 	 open_vwork( void );
void	 MakeActivator( int xtree, int obj );


/* DEFINES
 *==========================================================================
 */
#define PORT_A		0
#define PORT_B		1
#define PORT_C		2
#define PORT_D		3

/* Machine Code Values */
#define ST		0L
#define TT		2L
#define MEGA_STE	0x10010L

/* Maximum Number of Serial Ports currently possible */
#define MAX_PORTS	4
#define MACHINE_COOKIE  0x5f4d4348L


/* Bconmap Devices
 *-----------------------------------------------------------------
 * MASK_A  -->		ST Serial: All Machines
 * MASK_B  -->		Channel B: TT and Mega STE
 * MASK_C  -->		(TT): TT Serial
 * MASK_D  -->		(TT): Channel A
 */
#define INQUIRE_MAP	-1
 
#define MASK_A		6
#define MASK_B		7
#define MASK_C		8
#define MASK_D		9

/* TOS 1.4 Cookie Check */
#define TOS14		0x0104



/* Number of Ports Possible 
 * When Channel A is Set for LAN, it cannot be used as a serial port
 */
#define NORMAL_ST	1

#define TT_LAN		3
#define TT_NO_LAN	4

#define MEGA_STE_LAN	2
#define MEGA_STE_NO_LAN 3

#define MEGA_STE_PORTS	2

#define Bconmap( xport )	( int )xbios( 0x2c, ( xport ) )
     


/* EXTERNALS
 *==========================================================================
 */
extern MDEFAULT  save_vars;


/* GLOBALS
 *==========================================================================
 */
MDEFAULT Modem;			/* Structure of 4 modem ports plus cur_port */
MDEFAULT Old_Modem;		/* Backup storage for CANCEL		    */

#if 0
MDATA   *modemptr;


MDATA	modem[ MAX_PORTS ];	/* Storage for current data...     */
MDATA   old_modem[ MAX_PORTS ];	/* BACKUP storage for CANCEL       */
#endif

int     old_port;
int     cur_port;		/* Current Serial Port  - NUM_PORTS
				 * 0, 1, 2, 3
				 * There is only ONE port on regular STs.
				 * The other ports are for the TT.
				 */
				 
BUFFER  *store;			/* Need to store baud rate and flow cntrl
				 * in the 64 byte buffer. There is no other
				 * way to get these 2 numbers since they
				 * are write only items. The UCR data 
				 * can be had from RSCONF
				 */

int top_baud;			/* Top baud rate is the item at the top
				 * ( BAUD1 ) for the popup box
				 */

char *baud_array[] = { "19200",
		       "9600",
      		       "4800",
         	       "3600",
		       "2400",
		       "2000",
		       "1800",
		       "1200",
		       "600",
		       "300",
		       "200",
		       "150",
		       "134",
		       "110",
		       "75",
		       "50"
		     };


			  
char *bits_array[] = { "8",	        /* Array for bits/char    */
		       "7",	        /* Indexed thru cur_bits  */
		       "6",
		       "5"
		     };

			
char *stop_array[] = { "0",	       /* Array for stop bits     */
		       "1",	       /* Indexed thru cur_stop   */
		       "1.5",	       
		       "2"	       
		     };



char *port_array[] = { "Modem 1",
		       "Modem 2",
		       "Serial 1",
		       "Serial 2"
		     };
		     
/* VDI arrays */
int	contrl[12], intin[128], intout[128], ptsin[128], ptsout[128],
	work_in[12], work_out[57];
int	vhandle=-1;		/* virtual workstation handle */
int	hcnt=0;			/* handle count */



/*==========================================================================
 * STRINGS
 *==========================================================================
 */

/* COUNTRY: USA | UK
 *==========================================================================
 */ 
#if USA | UK
	char *flow_array[] = { "None",   	/* Array for flow control */
		      	       "Xon/Xoff",   	/* Index thru cur_flow    */
		               "Rts/Cts"
		             };

	char *parity_array[] = { "None",	/* Parity... */
		 		 "Odd",
		 	 	 "Even"
	               	       };
#endif



/* COUNTRY: ITALY
 *==========================================================================
 */ 
#if ITALY
	char *flow_array[] = { "Nessuno",   	/* Array for flow control */
		      	       "Xon/Xoff",   	/* Index thru cur_flow    */
		               "Rts/Cts"
		             };

	char *parity_array[] = { "Nessuna",	/* Parity... */
		 		 "Dispari",
		 	 	 "Pari"
	               	       };
#endif




/* COUNTRY: GERMAN
 *==========================================================================
 */ 
#if GERMAN
	char *flow_array[] = { "Keine",   	/* Array for flow control */
		      	       "Xon/Xoff",   	/* Index thru cur_flow    */
		               "Rts/Cts"
		             };

	char *parity_array[] = { "Keine",	/* Parity... */
		 		 "Ungerade",
		 	 	 "Gerade"
	               	       };
#endif




/* COUNTRY: FRENCH
 *==========================================================================
 */ 
#if FRENCH
	char *flow_array[] = { "Sans",   	/* Array for flow control */
		      	       "Xon/Xoff",   	/* Index thru cur_flow    */
		               "Rts/Cts"
		             };

	char *parity_array[] = { "Sans",	/* Parity... */
		 		 "Impaire",
		 	 	 "Paire"
	               	       };
#endif




/* COUNTRY: SPAIN
 *==========================================================================
 */ 
#if SPAIN
	char *flow_array[] = { "No",   		/* Array for flow control */
		      	       "Xon/Xoff",   	/* Index thru cur_flow    */
		               "Rts/Cts"
		             };

	char *parity_array[] = { "No",		/* Parity... */
		 		 "Impar",
		 	 	 "Par"
	               	       };
#endif





/* COUNTRY: SWEDEN
 *==========================================================================
 */ 
#if SWEDEN
	char *flow_array[] = { "Ingen",   	/* Array for flow control */
		      	       "Xon/Xoff",   	/* Index thru cur_flow    */
		               "Rts/Cts"
		             };

	char *parity_array[] = { "Ingen",	/* Parity... */
		 		 "Udda",
		 	 	 "J„mn"
	               	       };
#endif





/* GLOBALS
 *==========================================================================
 */ 
char blanks[20][20];	/* Used for Pop_Up String Manipulation  */
char *blank[20];	/* and is subject to change after review*/

XCPB    *xcpb;		/* Structure of function pointers FROM XCONTROL */
CPXINFO cpxinfo;	/* Structure of function pointers TO XCONTROL   */

long    machine_code;	/* Machine Code from Cookie Check */

unsigned int version;	/* TOS rom version */		 

int	Num_Ports;	/* Number of ACTUAL ports that the CPX can use
			 * This can be as high as 4 on a TT,
			 * 3 on a MEGA STE, and 1 on all other STs
			 * If LAN is active for TT or MEGA STE,
			 * Active number of ports is 1 less.
			 * See IsLanActive() for LAN Detection
			 */
/*			 
int	stack_port;	* the port that is shoved during a push_data()
			 * and is used for a pop_data. (mainly for OK and
			 * cancel functions )
			 *
*/

int AES_Version;
int gl_ncolors;


/* FUNCTIONS
 *==========================================================================
 */
 
 
/* cpx_init() 
 *==========================================================================
 * Initialize cpx data structures etc...
 */
CPXINFO
*cdecl cpx_init( XCPB *Xcpb )
{
    OBJECT *tree;
    int    port;
    int    temp_port;
    
    xcpb = Xcpb;
    if( xcpb->booting )
    {
        /* Read in defaults and set the options */

        store = ( BUFFER *)(*xcpb->Get_Buffer)();
        Modem = save_vars;
        
        Set_Machine_Code();
	Set_Number_Of_Ports();        
	
        for( port = 0; port < Num_Ports; port++ )
        {
	   Write_Port( port, store );
	   store++;
        }
        Modem.cur_port = Set_Active_Port( Modem.cur_port );
        return( ( CPXINFO *)TRUE );  
    }
    else
    {
      appl_init();
      AES_Version = _GemParBlk.global[0];
      
      if( !xcpb->SkipRshFix )
           (*xcpb->rsh_fix)( NUM_OBS, NUM_FRSTR, NUM_FRIMG, NUM_TREE,
           		    rs_object, rs_tedinfo, rs_strings, rs_iconblk,
           		    rs_bitblk, rs_frstr, rs_frimg, rs_trindex,
           		    rs_imdope );


      Supexec( Get_OS );
      tree = ( OBJECT *)rs_trindex[ RS232 ];
      Disable( PORT );
      Set_Machine_Code();
      (( IsTT() || IsSTE() ) ? ( Enable( PORT ) ) : ( Disable( PORT ) ) );
      Set_Number_Of_Ports();
      store = ( BUFFER *)(*xcpb->Get_Buffer)();
      
      Modem = save_vars;	/* Get the Defaults and fill up all 4 ports with info */
      
      /* Get the ACTUAL system values for as many ports as possible.*/
      temp_port = Get_Active_Port();
      for( port = 0; port < Num_Ports; port++ )
      {
	Read_Port( port, store );
	store++;      
      }
      Modem.cur_port = Set_Active_Port( temp_port );
      push_data();
 
      open_vwork();
      close_vwork();
      gl_ncolors = work_out[13];

      if( !xcpb->SkipRshFix )
      {
        if(( AES_Version >= 0x0330 )
         && ( gl_ncolors > LWHITE ))
        {
          tree  = (OBJECT *)rs_trindex[RS232];
	  MakeActivator( RS232, SAVE );
	  MakeActivator( RS232, RS232OK );
	  MakeActivator( RS232, RS232CAN );
        }
      }   
      
      
      
      cpxinfo.cpx_call   = cpx_call;
      cpxinfo.cpx_draw   = NULL;
      cpxinfo.cpx_wmove  = NULL;
      cpxinfo.cpx_timer  = NULL;
      cpxinfo.cpx_key    = NULL;
      cpxinfo.cpx_button = NULL;
      cpxinfo.cpx_m1 	 = NULL;
      cpxinfo.cpx_m2	 = NULL;
      cpxinfo.cpx_hook   = NULL;
      cpxinfo.cpx_close  = NULL;             
      return( &cpxinfo );
    }
}


/* set_objects()
 *==========================================================================
 * Set Button Text
 */
void
set_objects( int port  )
{
     OBJECT *tree  = (OBJECT *)rs_trindex[RS232];
    
     
     /* Setup Flow Control */
     TedText( FLOW ) = flow_array[ Modem.modem[ port ].cur_flow ];
          
     /* Setup Baud Rate	*/
     TedText( BAUD ) = baud_array[ Modem.modem[ port ].cur_baud ];

     /* Setup Parity	*/
     TedText( PARITY ) = parity_array[ Modem.modem[ port ].cur_parity ];
     
     /* Setup Bits/CHAR */
     TedText( BITSCHAR ) = bits_array[ Modem.modem[ port ].cur_bits ]; 
     
     /* Setup Stopbits */
     TedText( STOPX ) = stop_array[ Modem.modem[ port ].cur_stop ];
     
     /* Setup Port */
     TedText( PORT ) = port_array[ port ];
}



/* cpx_call()
 *==========================================================================
 * Execute the cpx using Xform_do()
 */
BOOLEAN
cdecl cpx_call( GRECT *rect )
{
     int button;
     int quit = 0;
     OBJECT *tree  = (OBJECT *)rs_trindex[RS232];
     WORD msg[8];
     int  temp;
     int  temp_port;
     long filesize;
     char *a,*b;
     GRECT xrect;
                    
     set_objects( cur_port );

     if( IsSTE() )
     {
        a = port_array[ PORT_C ];
        b = port_array[ PORT_D ];
        strcpy( a, b );
     }
     
     ObX( ROOT ) = rect->g_x;
     ObY( ROOT ) = rect->g_y;
     Objc_draw( tree, ROOT, MAX_DEPTH, NULL );
     do
     {
	button = (*xcpb->Xform_do)( tree, 0, msg );
     	switch( button )
     	{
     				/* if on a TT, we write out structure for 4 ports
     				 * but on an ST/STE/Mega, we write out just ONE!
     				 * And on a MEGA STE, we write out 3
     				 */
     		case SAVE:	if( (*xcpb->XGen_Alert)( SAVE_DEFAULTS ) )
     				{
				    filesize = sizeof( MDEFAULT );
				    (*xcpb->CPX_Save)( &Modem, filesize );			            
			            Select_Ok();
			        }
			        Deselect( SAVE );
			        xrect = ObRect( SAVE );
			        objc_offset( tree, SAVE, &xrect.g_x, &xrect.g_y );
			        xrect.g_x -= 2;
			        xrect.g_y -= 2;
			        xrect.g_w += 4;
			        xrect.g_h += 4;
			        Objc_draw( tree, SAVE, MAX_DEPTH, &xrect );
#if 0			            
     				deselect( tree, SAVE );
#endif     				
     				break;
     				
     		case RS232OK:	quit = RS232OK;
     				Select_Ok();
     				Deselect( RS232OK );
     				break;
     						
     		case RS232CAN:	quit = RS232CAN;
     				pop_data();
     				Deselect( RS232CAN );
     				break;
     						
     		case BAUD:	Pop_Handle( BAUD, baud_array, 16, &Modem.modem[ cur_port ].cur_baud, IBM, 8 );
     				break;
     						
		case FLOW:	Pop_Handle( FLOW, flow_array, 3, &Modem.modem[ cur_port ].cur_flow, IBM, 11 );
				break;

#if FRENCH | ITALY
		case PARITY:    Pop_Handle( PARITY, parity_array, 3, &Modem.modem[ cur_port ].cur_parity, IBM, 10 );
				break;
#endif

#if GERMAN				
		case PARITY:    Pop_Handle( PARITY, parity_array, 3, &Modem.modem[ cur_port ].cur_parity, IBM, 11 );
				break;
#endif
				
#if USA | UK | SPAIN | SWEDEN
		case PARITY:    Pop_Handle( PARITY, parity_array, 3, &Modem.modem[ cur_port ].cur_parity, IBM, 8 );
				break;
#endif
				
		case BITSCHAR:	Pop_Handle( BITSCHAR, bits_array, 4, &Modem.modem[ cur_port ].cur_bits, IBM, 8 );
				break;
				
		case STOPX:	if( !Modem.modem[ cur_port ].cur_stop )
				   Pop_Handle( STOPX, stop_array, 4, &Modem.modem[ cur_port ].cur_stop, IBM, 8 );
				else
				{ 
				   temp = Modem.modem[ cur_port ].cur_stop;
				   temp -= 1;
				   Pop_Handle( STOPX, &stop_array[1], 3, &temp, IBM, 8 );
				   Modem.modem[ cur_port ].cur_stop = temp + 1;
				}   
				break;
				
		case PORT:	if( !IsDisabled( PORT ) )
				{
				   /* Select number of ports based on 
				    * LAN TT and MEGA STE
				    * If on TT the LAN
				    * is ACTIVE AND we are using CHANNEL A,
				    * then set port to ST SERIAL using
				    * Bconmap call.
				    *
				    * For the Popup, we set the number of ports and also
				    * the default 'old_port' which is set by Set_Active_Port()
				    
				    */
				   temp_port = Get_Active_Port();
				   Modem.cur_port = Set_Active_Port( temp_port );
				   
				   Pop_Handle( PORT, port_array, Num_Ports, &old_port, IBM, 11 );
				   if( old_port != cur_port )
				   {
				     cur_port = old_port;
				     Modem.cur_port = Set_Active_Port( cur_port );
				     set_objects( cur_port );
				     Objc_draw( tree, BAUD, 0, NULL );
				     Objc_draw( tree, FLOW, 0, NULL );
				     Objc_draw( tree, PARITY, 0, NULL );
				     Objc_draw( tree, BITSCHAR, 0, NULL );	   
				     Objc_draw( tree, STOPX, 0, NULL );
				   }
				}
				break;
								
     		default:	if( button == -1 )
     				{
     				   switch( msg[0] )
     				   {
     				     case WM_REDRAW: Redraw_Objects();
     				     		     break;

     				     case AC_CLOSE:  quit = RS232CAN;
     				     		     pop_data();
						     break;
						     
     				     case WM_CLOSED: quit = RS232OK;
     				     		     Select_Ok();
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
 * Setup strings for popup menu and execute...
 */
int
Pop_Handle( int button, char *items[], int num_items, int *default_item, int font_size, int width )
{
   GRECT butn, world;
   
   int  i;
   int  obj;
   long max = 0L;
   OBJECT *tree = (OBJECT *)rs_trindex[ RS232 ];
   int small = FALSE;

   Check_Port_Change();
     
   butn = ObRect( button );
   objc_offset( tree, button, &butn.g_x, &butn.g_y );

   world = ObRect( ROOT );
   objc_offset( tree, ROOT, &world.g_x, &world.g_y ); 
   
   
   for( i = 0; i < num_items; i++ )
   {
       if( strlen( items[i] ) > max )
       	 	max = strlen( items[i] );
   }

   if( max <= 3L )
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
      	
   /* Other than the serial port mask selector...
    * we will slam the new setting into the hardware at the
    * current mask for the tt and into PORT_A for the ST
    */
   if( button != PORT )
       Set_Rsconf( cur_port );
   return( obj );
}





/* push_data()
 *==========================================================================
 * Save current data to cancel buffer
 */
void
push_data( void )
{
   Old_Modem = Modem;   
}




/* pop_data()
 *==========================================================================
 * Restore cancel buffer to current data
 */
void
pop_data( void )
{

   int port;
   
   store = ( BUFFER *)(*xcpb->Get_Buffer)();
   
   for ( port = 0; port < Num_Ports; port++ )
   {
         Modem.modem[ port ] = Old_Modem.modem[ port ];
         Write_Port( port, store );
         store++;
   }
   Modem.cur_port = Set_Active_Port( Old_Modem.cur_port );
}







/* Select_Ok
 *==========================================================================
 * Called when OK button is pressed or close_window occurs
 */
void
Select_Ok( void )
{
    int port;
    int temp_port;
    
    store = ( BUFFER *)(*xcpb->Get_Buffer)();
    temp_port = Get_Active_Port();
    for( port = 0; port < Num_Ports; port++ )
    {
       Write_Port( port, store );
       store++;
    }
    Modem.cur_port = Set_Active_Port( temp_port );
    push_data();
}




/* Set_Machine_Code()
 *==========================================================================
 * Check for _MCH cookie
 * If TRUE, machine_code contains the following numbers in the HIGH WORD
 *	  0 - ST
 *	  1 - STE
 *	  2 - TT		0x20000L == TT
 *	  0x10010L - Mega STE
 *
 * GLOBAL: long machine_code:   Will contain the machine code value
 */
void
Set_Machine_Code( void )
{
   if( (*xcpb->getcookie)( MACHINE_COOKIE, &machine_code ) )
   {
         return;
   }         

   machine_code = ST;     
}




/* Get_OS()
 *==========================================================================
 * Supexec this routine to get the version # in the variable..'VERSION'
 */
long
Get_OS( void )
{
    SYSHDR *osheader;
    
    osheader = *((SYSHDR **)0x4f2L );
    osheader = osheader->os_base;
    version  = osheader->os_version;
    return( 0L );
}



/* Check_OS()
 *==========================================================================
 * Return TRUE or FALSE if the version of the OS is >= than TOS 1.4
 */
BOOLEAN
Check_OS( void )
{
    return( version >= TOS14 );
}






/* Redraw_Objects()
 *==========================================================================
 * Redraws the modem objects.
 * This is especially important if the values are changed, therefore
 * they must reflect actual reality
 */
void
Redraw_Objects( void )
{
   OBJECT *tree = ( OBJECT *)rs_trindex[ RS232 ];
   MDATA temp;
   int   xport;
   int   i;
   int   temp_port;
   
   store = ( BUFFER *)(*xcpb->Get_Buffer)();
   
   xport = temp_port = Get_Active_Port();
   Set_Number_Of_Ports();
   temp  = Modem.modem[ temp_port ];

   for( i =0;i < Num_Ports;i++ )
   {
       Read_Port( i, store );
       store++;   
   }
   Set_Active_Port( temp_port );
   set_objects( cur_port );
      
   if( xport != cur_port )
       do_redraw( tree, PORT );
          
   if( temp.cur_baud != Modem.modem[ cur_port ].cur_baud )
         do_redraw( tree, BAUD );
         
   if( temp.cur_parity != Modem.modem[ cur_port ].cur_parity )
   	do_redraw( tree, PARITY );
   	
   if( temp.cur_bits != Modem.modem[ cur_port ].cur_bits )
       do_redraw( tree, BITSCHAR );
       
   if( temp.cur_flow != Modem.modem[ cur_port ].cur_flow )
   	do_redraw( tree, FLOW );
   	
   if( temp.cur_stop != Modem.modem[ cur_port ].cur_stop )
   	do_redraw( tree, STOPX );
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





/* Set_Number_Of_Ports()
 *==========================================================================
 * 1) Checks for the presence of an ACTIVE LAN if on a MEGA STE or TT
 * 2) Sets the Number of Ports available accordingly
 * 3) 		Regular ST		1 ( ALWAYS )
 *					 LAN OFF	LAN ACTIVE
 *		MEGA STE		   2		    2   ( always 2 ports )
 *		TT			   4		    3
 *    This number is shoved into:   int Num_Ports
 */
void
Set_Number_Of_Ports( void )
{
     Num_Ports = NORMAL_ST;
     if( IsTT() )
         Num_Ports = (( IsLanActive() ) ? ( TT_LAN ) : ( TT_NO_LAN ) );

     if( IsSTE() )
     {
#if 0     
	    Num_Ports = MEGA_STE_PORTS;
#else	    
	    Num_Ports = (( IsLanActive() ) ? ( MEGA_STE_LAN ) : ( MEGA_STE_NO_LAN ) );      
#endif	    
     }	 
}





/* Get_Active_Port()
 *==========================================================================
 * Return the active port ( PORT_A, PORT_B, PORT_C or PORT_D )
 * On a standard ST, we always return PORT_A ( ST SERIAL )
 */
int
Get_Active_Port( void )
{
    int port_mask;
    
    if( IsTT() || IsSTE() )
    {
         port_mask = Bconmap( INQUIRE_MAP );
         return( port_mask - MASK_A );    
    }
    return( PORT_A );
}



/* Set_Active_Port()
 *==========================================================================
 * Set the port variables to the NEW port
 * 1) On a regular ST, the port is ALWAYS the ST SERIAL ( PORT_A )
 * 2) (TT): If the port is Channel A and the LAN is active, we reset
 *	    the port to ST SERIAL instead.
 * 3) ( MEGA STE ): if the port is Channel A and the LAN is active, we
 *		    reset the port to ST SERIAL instead
 * Return: cur_port - 0, 1, 2, 3 with the actual port set to.
 */
int
Set_Active_Port( int port )
{
  Set_Number_Of_Ports();

  if( IsTT() )
  { 

     if(( port == PORT_D ) && IsLanActive() )
         old_port = cur_port = PORT_A; 
     else
         old_port = cur_port = port;

     xbios( 0x2c, ( cur_port + MASK_A ) );  
     return( cur_port );;  
  }
  
  if( IsSTE() )
  {
     if( ( port == PORT_C ) && IsLanActive() )
	old_port = cur_port = PORT_A;
     else       
        old_port = cur_port = port;

     xbios( 0x2c, ( cur_port + MASK_A ) );  
     return( cur_port );  
  }     
  
  old_port = cur_port = PORT_A;
  return( cur_port );
}




/* Check_Port_Change()
 *==========================================================================
 * When Selecting one of the popup items, the PORT_D status might have
 * been changed.
 * On a Standard ST, this can never occur.
 * On a TT or Mega STE, the port might have the LAN now set to ON.
 * Therefore, we are going to have to adjust to this.
 */
void
Check_Port_Change( void )
{
    int temp_port;
    
    temp_port = Get_Active_Port();
    if( IsTT() && IsLanActive() && ( temp_port == PORT_D ))
    {
        Set_Active_Port( temp_port );
        Redraw_Objects();
    }
    
    if( IsSTE() && IsLanActive() && ( temp_port == PORT_C ) )
    {
        Set_Active_Port( temp_port );
        Redraw_Objects();
    }       		
}





/* IsLanActive()
 *=========================================================================
 * On a Mega STE and on a TT, Channel A can also be the LAN
 * When the LAN is active, the modem cpx should not read or write to 
 * Channel A.
 * Bit 7 on the Sound Chip is the LAN On/Off setting
 *
 * Bit 7 == TRUE      ====>     LAN not in use, SO, OK to use
 * Bit 7 == FALSE     ====>	LAN IN USE, Don't Touch
 *
 * Return:   TRUE  - LAN in USE
 *	     FALSE - LAN not in USE
 */
BOOLEAN
IsLanActive( void )
{
    char status;

    if( IsTT() || IsSTE() ) 
    {    
       status = Giaccess( 0, 14 );
       return( !(status & 0x80 ) );
    }
    else
       return( FALSE );   
}



/* IsTT()
 *==========================================================================
 * Check if value returned from cookie is a TT
 * TT is 0x2xxxxL
 */
BOOLEAN
IsTT( void )
{
    return( ( machine_code >> 16 ) == TT );
}




/* IsSTE()
 *==========================================================================
 * Returns TRUE or FALSE if this machine is an STE
 */
BOOLEAN
IsSTE( void )
{
  return( machine_code == 0x10010L );	/* MEGA STE */
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
