/* MAINSTUF.C
 * ================================================================
 * DATE: October 3, 1990
 * DESCRIPTION: 
 */
#include <sys\gemskel.h>
#include <string.h>
#include <tos.h>
#include <vdikeys.h>

#include <stdio.h>
#include <stdlib.h>

#include "viewer.h"
#include "DaveStuf.h"
#include "windows.h"
#include "text.h"


/*
 * TURN OFF Turbo C "parameter X is never used" warnings
 */
#pragma warn -par

/* DEFINES
 * ================================================================
 */
#define DIRMAX 16
#define DUMMY	    4	/* just a random number for window offsets(pixels) */

typedef struct _itile
{
   int  x;
   int  y;
   int  xrow;
   int  yrow;
   int  xcol;
   int  ycol;
   char TileText[12];
}ITILE;



/* PROTOTYPES
 * ================================================================
 */
int  execform( OBJECT *tree, int start_obj );
void do_redraw( int handle, GRECT *clip );
void Do_Wfile( int type );
void Graf_Mouse( int item );
void Send_Redraw( WINFO *x );

void Size_World( void );
void Do_Tile_Irr( void );
void Do_Grid_Size( void );
void Set_Brush_Path( void );

void Init_Defaults( void );
void Get_Path( char *bufptr );

void Func_Key( int num );
void Shift_Func_Key( int num );

void bputstr( char *str );
void bputcr( void );
void bgetstr( char *str );

void Write_Inf( void );
void Read_Inf( void );

void Get_Extension( char *Path, char *text );
void Do_Cfile( int type );
int  TooBigRam( void );
void Get_Grect( GRECT *rect, char *str );
void mod_window_specs( WINFO *x );
void World_Check( void );

void do_quit( int *event );
void Clear_World( void );
void Clear_Floor( void );
void do_help( void );
void Assign_Help_Strings( void );
void Check_Keyboard( int key );
void EatEvnt( void );

void EatKeyboard( void );

/* EXTERN
 * ================================================================
 */

 
/* GLOBALS 
 * ================================================================
 */
long  dummy;				/* Used by vex_butv() */

OBJECT *ad_menu;
OBJECT *ad_about;
OBJECT *ad_size;
OBJECT *ad_grid;
OBJECT *ad_tile;
OBJECT *ad_help;

char path[128];				/* path plus filename 	      */
char title[20];				/* file selector TITLE string */

char wexten[15];			/* world file extension string*/
char lexten[15];			/* Library file extension     */
char cexten[15];			/* Cluster file extension     */

					/* Globals for DAVESTUF.S     */
int  form_width;			/* xres of screen ( pixels )  */
int  form_height;			/* yres of screen ( pixels )  */

MRETS	Mrets;				/* For DaveEvnt */
int	Key;

ITILE	Itile;				/* Irregular Tile Structure ( DAVE )*/
char    Brush_Path[ 128 ];		/* Brush Path Directory path */
char    World_Path[ 128 ];		/* World Path Directory Path */
char	Cluster_Path[ 128 ];

char	Brush_Text[ DIRMAX + 1 ];

char    blnkstring[] = "                ";


/*   DEFAULT VIEWER.INF variables */
char Inf_Path[ 128 ];		/* path to look at to load viewer.inf */
char Inf_Buf[ 1024 ];		/* contents of viewer.inf */
char temp[128];
int  bindex;			/* index into the buffer  */

int  GridLock = FALSE;		/* Grid Lock Flag - TRUE/FALSE */

/*  Function Key Array that holds indexes to the brush data structures */
/*  -1 means not in use. */
int Func_Array[] = {
		    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
		   };
		   
/* GEMSKEL functions
 * ================================================================
 */
 

/* rsrc_init()
 * ================================================================
 */
BOOLEAN
rsrc_init( void )
{
   if( rsrc_load( "VIEWER.RSC" ) )
   {
      rsrc_gaddr( 0, MENU, &ad_menu );
      rsrc_gaddr( 0, ABOUT1, &ad_about );
      rsrc_gaddr( 0, TILES, &ad_tile );
      rsrc_gaddr( 0, WORLDSIZ, &ad_size );
      rsrc_gaddr( 0, GRIDS, &ad_grid );
      rsrc_gaddr( 0, XHELP, &ad_help );
                       
      menu_bar( ad_menu, TRUE );
      Graf_Mouse( ARROW );

      form_width  = xres;
      form_height = yres;
      
      fsel_init();      
      Read_Inf();
      
      return( TRUE );  
   }
   else
      return( FALSE );
}


/* evnt_init()
 * ================================================================
 */
void
evnt_init( void )
{
    evnt_set( MU_MESAG | MU_BUTTON | MU_KEYBD, 1, 1, 1, NULL, NULL, 0L );
}




/* do_menu()
 * ================================================================
 */
void
do_menu( const int *msg, int *event )
{
   switch( msg[4] )
   {
      case ABOUT: execform( ad_about, 0 );
      		  break;

      case LOADPAL: LoadPal();
      		    break;

      case SETBPATH: Set_Brush_Path();
      		     break;
      		          		          		  
      case QUIT:  do_quit( event );
      		  break;
	
      case CLRWRLD:  Clear_World();
      		     break;

      case CLRFLOOR: Clear_Floor();
      		     break;
      			
      case SIZEWRLD: Size_World();
        	     break;
      		     
      case TILENORM: DaveTile();
 	             do_redraw( WORLD, &wstruct[ WORLD ].w );
      		     break;
      		
      case TILEIRR:  Do_Tile_Irr();
      		     break;

      case SET2LYNX: Set_Window_To_Size( 160, 102 );
      		     break;
      		     
      case SET2WRLD: Set_Window_To_Size( wstruct[ WORLD ].w_wid, wstruct[ WORLD ].w_hite );
      		     break;
      		     	
      case GRIDSET: Do_Grid_Size();
      		    break;

      case LOADW: strcpy( title, "Load World List" );
      		  Do_Wfile( LOADW );
                  break;
                  
      case SAVEW: strcpy( title, "Save World List" );
      		  Do_Wfile( SAVEW );
      		  break;      		  

      case LOADC: strcpy( title, "Load Cluster List" );
      		  Do_Cfile( LOADC );
      		  break;
      		  
      case SAVEC: strcpy( title, "Save Cluster List" );
      		  Do_Cfile( SAVEC );
      		  break;
      
      default:
      		  break;
   }
   menu_tnormal( ad_menu, msg[3], TRUE );
}



/* Do_Wfile()
 * ================================================================
 */
void
Do_Wfile( int type )
{
    int out;
    char WPath[ 128 ];
    long i;

    strcpy( WPath, World_Path );

    /* Check if path includes a filename or just a wildcard. */
    /* if wildcard, remove up to the \\, otherwise, ignore it*/

    for( i = strlen( WPath ); i && ( WPath[i] != '\\') && ( WPath[i] != '*' ) && ( WPath[i] != '?'); i-- );
    if( WPath[i] != '\\' )
    {
       for( i = strlen( WPath ); i && ( WPath[i] != '\\' ); WPath[i--] = '\0' );
    }
        
    out = fsel_name( TRUE, WPath, wexten, title );
    if( (out == A_CANCEL) && ( WPath[0] != '\0' ))
    {
       Get_Extension( World_Path, wexten );
       for( i = strlen( WPath ); i && ( WPath[i] != '\\' ); WPath[i--] = '\0' );
       strcpy( World_Path, WPath );
       strcat( World_Path, wexten );
    }
    
    if( ( out == A_OK ) && ( WPath[0] != '\0' ) )
    {
       /* Take wot's in WPath, including the filename, and use that
        * as our NEW World Path, including the filename.
        */
       strcpy( World_Path, WPath );
       Get_Extension( World_Path, wexten );
       switch( type )
       {
           case LOADW: if( !load_world( WPath ) )
           	       {
		         SetDave_Stuff( WORLD );
		         slider_chk();
		       }
		       else
		         form_alert( 1, "[1][ | World Read Error,| Load Cancelled!][ Sorry ]" );
           	       break;
           	       
           case SAVEW: if( save_world( WPath ))
		         form_alert( 1, "[1][ | World Write Error,| Save Cancelled!][ Sorry ]" );
           	       break;
    
           default:
           	       break;
       }
    }
    do_redraw( WORLD, &w.work );
    do_redraw( LIBRARY, &l.work );
}





/* Do_Cfile()
 * ================================================================
 */
void
Do_Cfile( int type )
{
    int out;
    char CPath[ 128 ];
    long i;

    strcpy( CPath, Cluster_Path );

    /* Check if path includes a filename or just a wildcard. */
    /* if wildcard, remove up to the \\, otherwise, ignore it*/

    for( i = strlen( CPath ); i && ( CPath[i] != '\\') && ( CPath[i] != '*' ) && ( CPath[i] != '?'); i-- );
    if( CPath[i] != '\\' )
    {
       for( i = strlen( CPath ); i && ( CPath[i] != '\\' ); CPath[i--] = '\0' );
    }
        
    out = fsel_name( TRUE, CPath, cexten, title );
    if( (out == A_CANCEL) && ( CPath[0] != '\0' ))
    {
       Get_Extension( Cluster_Path, cexten );
       for( i = strlen( CPath ); i && ( CPath[i] != '\\' ); CPath[i--] = '\0' );
       strcpy( Cluster_Path, CPath );
       strcat( Cluster_Path, cexten );
    }
    
    if( ( out == A_OK ) && ( CPath[0] != '\0' ) )
    {
       /* Take wot's in CPath, including the filename, and use that
        * as our NEW Cluster Path, including the filename.
        */
       strcpy( Cluster_Path, CPath );
       Get_Extension( Cluster_Path, cexten );
       switch( type )
       {
           case LOADC: if( load_cluster( CPath ) )
		         form_alert( 1, "[1][ | Cluster Read Error,| Load Cancelled!][ Sorry ]" );
           	       break;
           	       
           case SAVEC: if( save_cluster( CPath ))
		         form_alert( 1, "[1][ | Cluster Write Error,| Save Cancelled!][ Sorry ]" );
           	       break;
    
           default:
           	       break;
       }
    }
    do_redraw( WORLD, &w.work );
    do_redraw( LIBRARY, &l.work );
}





/* do_key()
 * ================================================================
 */
void
do_key( int kstate, int key, int *event )
{
   OBJECT *tree;
   
       switch( key )
       {
	 case K_F1:  /* Function Key Pressed */
	 case K_F2:
	 case K_F3:
	 case K_F4:
	 case K_F5:
	 case K_F6:
	 case K_F7:
	 case K_F8:
	 case K_F9:
	 case K_F10: Func_Key( key - K_F1 );
	 	     break;

	 case KS_F1: /* Shift Function Key Pressed */
	 case KS_F2:
	 case KS_F3:
	 case KS_F4:
	 case KS_F5:
	 case KS_F6:
	 case KS_F7:
	 case KS_F8:
	 case KS_F9:
	 case KS_F10:Shift_Func_Key( key - KS_F1 );
		     break;	 

	 case K_DOWN:
	 case K_LEFT:
	 case K_RIGHT:
	 case K_UP:    do_arrow_buttons( key );
	 	       break;
	 			    

	 case KC_A:	Set_Brush_Path();
	 		break;
	 		
	 case KC_Q:     do_quit( event );
	 		break;
	 		
	 case KC_W:	Clear_World();
	 		break;
	 		
	 case KC_F:	Clear_Floor();
	 		break;
	 		
	 case KC_S:	Size_World();
	 		break;
	 		
	 case KC_N:     DaveTile();
 	                do_redraw( WORLD, &wstruct[ WORLD ].w );
	 		break;
	 		
	 case KC_I:     Do_Tile_Irr();
	 		break;
	 		
	 case KC_Z:     Set_Window_To_Size( 160, 102 );
	 		break;
	 		
	 case KC_X:     Set_Window_To_Size( wstruct[ WORLD ].w_wid, wstruct[ WORLD ].w_hite );
	 		break;
	 		
	 case KC_G:     Do_Grid_Size();
	 		break;
	 
	 case KC_T:     strcpy( title, "Load World List" );
      		        Do_Wfile( LOADW );
	 		break;
	 		
	 case KC_Y:     strcpy( title, "Save World List" );
	      		Do_Wfile( SAVEW );
	 		break;
	 
	 case KC_P:     LoadPal();
	 		break;
	 		
	 case KC_J:     strcpy( title, "Load Cluster List" );
      		        Do_Cfile( LOADC );
	 		break;
	 		
	 case KC_K:	ActiveTree( ad_menu );
	 		if( !IsDisabled( SAVEC ) )
	 		{
	                   strcpy( title, "Save Cluster List" );
      		           Do_Cfile( SAVEC );
      		        }   
	 		break;

	 case K_HELP:	do_help();
	 		break;
	 		
	 default:
	          DaveKey( kstate, key, GetTopWindow() );
	 	  break;	             
       }
}



/* do_button()
 * ================================================================
 */
void
do_button( MRETS *mrets, int nclicks, int *event )
{
    MRETS m;
    
    Graf_mkstate( &m );
    if( w.id == wind_find( m.x, m.y ) )
    {
       if( xy_inrect( m.x, m.y, &w.work ) )
       {
           DaveButton( m.x, m.y );
/*           EatEvnt();*/
        }   
    }
    
    if( l.id == wind_find( m.x, m.y ) )
    {
       if( xy_inrect( m.x, m.y, &l.work ) )
           LibButton( m.x, m.y );
    }
}



/* do_m1()
 * ================================================================
 */
void
do_m1( MRETS *mrets, int *event )
{
}


/* do_m2()
 * ================================================================
 */
void
do_m2( MRETS *mrets, int *event )
{
}



/* do_redraw()
 * ================================================================
 * IN: int handle;	WORLD or LIBRARY
 *     GRECT *clip;	Clipping rectangle
 */
void
do_redraw( int handle, GRECT *clip )
{
   GRECT rect;
   
   Graf_Mouse( M_OFF );
   Wind_get( window[ handle ]->id, WF_FIRSTXYWH, ( WARGS *)&rect );
   while( !rc_empty( &rect ) )
   {
       if( rc_intersect( clip, &rect ) )
       {
          if( handle == WORLD )
              DaveDraw( &rect );
              
          if( handle == LIBRARY )
              LibraryDraw( &rect );
       }   
       Wind_get( window[ handle ]->id, WF_NEXTXYWH, ( WARGS *)&rect );
   }
   Graf_Mouse( M_ON );    
}




/* rsrc_exit();
 * ================================================================
 */
void
rsrc_exit( void )
{
   menu_bar( ad_menu, FALSE );
   rsrc_free();
}



/* execform()
 * ================================================================
 * Custom routine to put up a standard dialog box and wait for a key.
 */
int
execform( OBJECT *tree, int start_obj )
{
   GRECT rect;
   GRECT xrect;
   int button;
   
   xrect.g_x = xrect.g_y = 10;
   xrect.g_w = xrect.g_h = 36;
   
   Form_center( tree, &rect );
   Form_dial( FMD_START, &xrect, &rect );
   Form_dial( FMD_GROW, &xrect, &rect );
   Objc_draw( tree, ROOT, MAX_DEPTH, &rect );
   button = form_do( tree, start_obj );
   Form_dial( FMD_SHRINK, &xrect, &rect );
   Form_dial( FMD_FINISH, &xrect, &rect );
   Deselect( button );
   return( button );
}





/* Graf_Mouse()
 * ================================================================
 * Let's Dave change the mouse image. ( See the AES for mouse forms )
 */
void
Graf_Mouse( int item )
{
   graf_mouse( item, 0L );
}



/* Send_Redraw()
 * ================================================================
 */
void
Send_Redraw( WINFO *x )
{
    int msg[8];
    
    msg[0] = WM_REDRAW;
    msg[1] = gl_apid;
    msg[2] = 0;
    msg[3] = x->id;
    msg[4] = x->work.g_x;
    msg[5] = x->work.g_y;
    msg[6] = x->work.g_w;
    msg[7] = x->work.g_h;
    appl_write(gl_apid, 16, msg );
}



/* DaveEvnt()
 * ================================================================
 */
void
DaveEvnt( void )
{
   static	int	ev_clicks=0, ev_bmask=0, ev_bstate=0;
   static	MOBLK	ev_m1 = { 0, 0, 0, 0, 0 };
   static	MOBLK	ev_m2 = { 0, 0, 0, 0, 0 };
   static	long	ev_time=0L;
   
   int		msg[8], nclicks;
   int	 	event;
      
   event = Evnt_multi( MU_TIMER | MU_KEYBD, ev_clicks, ev_bmask, ev_bstate,
  	   	       &ev_m1, &ev_m2, ( WORD *)msg, ev_time,
	       	       &Mrets, ( WORD *)&Key, ( WORD *)&nclicks );

   if( event == MU_TIMER )
   	Key = 0;
}



/* Size_World()
 * ================================================================
 */
void
Size_World( void )
{
    OBJECT *tree;
    char Width_Text[6];
    char Height_Text[6];
    unsigned int  old_wid;
    unsigned int  old_hite;
    WDATA *x;
    
    x = &wstruct[ WORLD ];
    
    old_wid  = x->w_wid;
    old_hite = x->w_hite;
    
    sprintf( Width_Text,  "%5d", x->w_wid );
    sprintf( Height_Text, "%5d", x->w_hite );
      		     
    ActiveTree( ad_size );
    TedText( SIZEW ) = Width_Text;
    TedText( SIZEH ) = Height_Text;

    if( execform( ad_size, 0 ) == WORLDOK )
    {
        do_redraw( WORLD, &wstruct[ WORLD ].w );
        
        x->w_wid  = atoi( Width_Text );
        x->w_hite = atoi( Height_Text );
        
        if( !x->w_wid )
         	x->w_wid = old_wid;
        if( !x->w_hite )
        	x->w_hite = old_hite;

	x->xoffset = x->yoffset = 0;
	
	DaveSize();
        do_redraw( WORLD, &wstruct[ WORLD ].w );
	
        SetDave_Stuff( WORLD );
        slider_chk();
   
        SetDave_Stuff( LIBRARY );
        slider_chk();
        DisplayXY();
    }
}



/* Do_Tile_Irr()
 * ================================================================
 */
void
Do_Tile_Irr( void )
{
  OBJECT *tree;
  char ixtext[6];
  char iytext[6];
  char rowxtext[6];
  char rowytext[6];
  char colxtext[6];
  char colytext[6];

  ITileSetup();
    
  ActiveTree( ad_tile );

  TedText( IRRTEXT ) = Itile.TileText;
  
  sprintf( ixtext, "%4d", Itile.x );
  sprintf( iytext, "%4d", Itile.y );
  TedText( IX ) = ixtext;
  TedText( IY ) = iytext;
  
  sprintf( rowxtext, "%4d", Itile.xrow );
  sprintf( rowytext, "%4d", Itile.yrow );
  TedText( ROWX ) = rowxtext;
  TedText( ROWY ) = rowytext;
  
  sprintf( colxtext, "%4d", Itile.xcol );
  sprintf( colytext, "%4d", Itile.ycol );
  TedText( COLX ) = colxtext;
  TedText( COLY ) = colytext;
  
  if( execform( ad_tile, 0 ) == TILEOK )
  {
     Itile.x = atoi( ixtext );
     Itile.y = atoi( iytext );
     
     Itile.xrow = atoi( rowxtext );
     Itile.yrow = atoi( rowytext );
     
     Itile.xcol = atoi( colxtext );
     Itile.ycol = atoi( colytext );
     
     DaveITile();
     do_redraw( WORLD, &wstruct[ WORLD ].w );
  }   
}




/* Do_Grid_Size()
 * ================================================================
 */
void
Do_Grid_Size( void )
{
   char xtext[4];
   char ytext[4];
   char wtext[4];
   char htext[4];
   OBJECT *tree;
   GRECT  drect;
   GRECT  rect;
   GRECT  xrect;
   int    button;
   char   GText[ 12 ];
   
   GText[0] = '\0';
   drect.g_w = drect.g_h = 0;
   GetCurObj( &GText[0], &drect );

      
   sprintf( xtext, "%3d", Grid.g_x );
   sprintf( ytext, "%3d", Grid.g_y );
   sprintf( wtext, "%3d", Grid.g_w );
   sprintf( htext, "%3d", Grid.g_h );
   
   ActiveTree( ad_grid );
   TedText( GRIDX ) = xtext;
   TedText( GRIDY ) = ytext;
   TedText( GRIDW ) = wtext;
   TedText( GRIDH ) = htext;
   TedText( GRIDTEXT ) = GText;

   Deselect( GRIDON );
   Deselect( GRIDOFF );
   
   if( GridLock )
        Select( GRIDON );
   else
        Select( GRIDOFF );
      
   xrect.g_x = xrect.g_y = 10;
   xrect.g_w = xrect.g_h = 36;
   
   Form_center( ad_grid, &rect );
   Form_dial( FMD_START, &xrect, &rect );
   Form_dial( FMD_GROW, &xrect, &rect );
   Objc_draw( ad_grid, ROOT, MAX_DEPTH, &rect );
   do
   {
      button = form_do( ad_grid, 0 );
      if( button == CUROBJ )
      {
         sprintf( wtext, "%3d", drect.g_w );
         sprintf( htext, "%3d", drect.g_h );
         TedText( GRIDW ) = wtext;
         TedText( GRIDH ) = htext;
         deselect( ad_grid, button );
	 Objc_draw( ad_grid, GRIDW, 0, &rect );
	 Objc_draw( ad_grid, GRIDH, 0, &rect );
      }   

   }while(( button != GRIDCAN ) && ( button != GRIDOK ) );
   
   Form_dial( FMD_SHRINK, &xrect, &rect );
   Form_dial( FMD_FINISH, &xrect, &rect );
   Deselect( button );

   if( button == GRIDOK )
   {
     Grid.g_x = atoi( xtext );
     Grid.g_y = atoi( ytext );
     Grid.g_w = atoi( wtext );
     Grid.g_h = atoi( htext );
     
     GridLock = IsSelected( GRIDON ); 	   
     
     DaveGrid();
   }  
}




/* Set_Brush_Path()
 * ================================================================
 */
void
Set_Brush_Path( void )
{
   char  BPath[ 128 ];
   int   out;
   long  i;
        
   strcpy( BPath, Brush_Path );
   for( i = strlen( BPath ); i && ( BPath[i] != '\\' ); BPath[i--] = '\0' );
   out = fsel_name( TRUE, BPath, lexten, "Set Brush Path" );
   if( (( out == A_OK ) || ( out == A_CANCEL ) ) && ( BPath[0] != '\0' ) )
   {
      Get_Extension( BPath, lexten );
      for( i = strlen( BPath ); i && ( BPath[i] != '\\' ); BPath[i--] = '\0' );
      strcpy( Brush_Path, BPath );
      strcat( Brush_Path, lexten );
      
      for( i = strlen( World_Path ); i && ( World_Path[i] != '\\' );World_Path[i--] = '\0' );
      strcat( World_Path, wexten );
      
      form_alert( 1,"[1][ | The Brush Path has been changed.| Exit and reenter program| to activate the new Brushes.][ OK ]");
   }
}




/* Init_Defaults()
 * ================================================================
 * 1) Get Brush path, World Path and Cluster Path.
 *    If they do not exist, use the current directory.
 * 2) Set the Function Key Array indexes to -1
 */
void
Init_Defaults( void )
{
   char  *bufptr;
   int   i;
   
   /* For now, assume NO 'viewer.inf' file */
   bufptr = Brush_Path;
   Get_Path( bufptr );
   strcat( bufptr, "\\*.BSH" );
   strcpy( lexten, "*.BSH" );

   bufptr = World_Path;
   Get_Path( bufptr );
   strcat( bufptr, "\\*.WLD" );
   strcpy( wexten, "*.WLD" );
   
   bufptr = Cluster_Path;
   Get_Path( bufptr );
   strcat( bufptr, "\\*.CLU" );
   strcpy( cexten, "*.CLU" );
   
   for( i = 0; i < 10; i++ )
      Func_Array[ i ] = -1;
      
   
   w.r = desk;
   w.r.g_w = ( ( desk.g_w / 4 ) * 3 ) - DUMMY;

   l.r	= desk;
   l.r.g_w = ( desk.g_w / 4 );
   l.r.g_x = ( l.r.g_w * 3 );
   
   Grid.g_x = Grid.g_y = Grid.g_w = Grid.g_h = 0;
   GridLock = FALSE;      
}




/* Get_Path()
 * ================================================================
 */
void
Get_Path( char *bufptr )
{
    int   drv;
 
    *bufptr++ = ( drv = Dgetdrv() ) + 'A';
    *bufptr++ = ':';
    Dgetpath( bufptr, drv+1 );
}




/* ================================================================
 * READ/WRITE VIEWER.INF
 * ================================================================
 * FORMAT:
 * 1) PATH of WORLDs ( Null terminated )
 * 2) PATH of BRUSHES( Null terminated )
 * 3) PATH of Cluster( Null terminated )
 * 4) Function array ( 10 lines of WORDS )
 * 5) WORLD window x y w h
 * 6) LIBRARY window x y w h
 * 7) GRID coordinates x y w h
 */
 
/* Write_Inf()
 * ================================================================
 */
void
Write_Inf( void )
{
   int  fd;
   int  i;
   
   /* Write out the World Path */
   bindex = 0;
   bputstr( &World_Path[0] );
   bputcr();
   
   /* Write out the Brush Path */
   bputstr( &Brush_Path[0] );
   bputcr();


   /* Write out the Cluster Path */
   bputstr( &Cluster_Path[0] );
   bputcr();

   /* Write out the Function Key assignments */   
   for( i = 0; i<10; i++ )
   {
      sprintf( temp, "%d", Func_Array[i] );
      bputstr( temp );
      bputcr();
   }
   
   /* Write out the World Window Coordinates */
   sprintf( temp, "%d,%d,%d,%d", w.r.g_x, w.r.g_y, w.r.g_w, w.r.g_h );
   bputstr( temp );
   bputcr();
   
   /* Write out the Library Window Coordinates */
   sprintf( temp, "%d,%d,%d,%d", l.r.g_x, l.r.g_y, l.r.g_w, l.r.g_h );
   bputstr( temp );
   bputcr();   				 
        
   /* Write out the Grid Coordinates */
   sprintf( temp, "%d,%d,%d,%d", Grid.g_x, Grid.g_y, Grid.g_w, Grid.g_h );
   bputstr( temp );
   bputcr();
        
   Get_Path( Inf_Path );
   strcat( Inf_Path, "\\VIEWER.INF" );
      
   if( ( fd = Fcreate( &Inf_Path[0], 0 )) > 0 )
   {
       Fwrite( fd, (long)strlen( Inf_Buf ), Inf_Buf );
       Fclose( fd );
   }
}




/* Read_Inf()
 * ================================================================
 */
void
Read_Inf( void )
{
   DTA  thedta, *saved;
   int  fd;
   int  i;
        
   Get_Path( Inf_Path );
   strcat( Inf_Path, "\\VIEWER.INF" );

   saved = Fgetdta();
   Fsetdta( &thedta );
   if( Fsfirst( Inf_Path, 0 ) <= -1 ) /* Can't find the file... */
   {				      /* So Use Defaults	*/
     Init_Defaults();   
   }
   else
   {
     fd = Fopen( Inf_Path, 0 );
     Fread( fd, thedta.d_length, Inf_Buf );
     Fclose( fd );

     bindex = 0;
     
     /* Get World Path */
     bgetstr( World_Path );
     
     /* Get Brush Path */
     bgetstr( Brush_Path );
     
     /* Get Cluster Path */
     bgetstr( Cluster_Path );
     
     /* Get Function Array keyboard assignments */
     for( i = 0; i < 10; i++ )
     {
        bgetstr( temp );
        Func_Array[i] = atoi( temp );
     }

     /* Get WORLD window coordinates */
     bgetstr( temp );
     Get_Grect( &w.r, temp );
     mod_window_specs( &w );
     
     /* Get LIBRARY window coordinates */
     bgetstr( temp );
     Get_Grect( &l.r, temp );
     mod_window_specs( &l );

     /* Get Grid Coordinates */
     bgetstr( temp );
     Get_Grect( &Grid, temp );


     Get_Extension( World_Path, wexten );
     Get_Extension( Brush_Path, lexten );
     Get_Extension( Cluster_Path, cexten );
   }
   Fsetdta( saved );    
}


void
mod_window_specs( WINFO *x )
{
     x->r.g_x = (( x->r.g_x < desk.g_x ) ? ( desk.g_x ) : ( x->r.g_x ) );
     x->r.g_y = (( x->r.g_y < desk.g_y ) ? ( desk.g_y ) : ( x->r.g_y ) );

     x->r.g_x = (( x->r.g_x > ( desk.g_w - 20 ) ) ? ( desk.g_x ) : ( x->r.g_x ) );
     x->r.g_y = (( x->r.g_y > ( desk.g_h - 20 ) ) ? ( desk.g_y ) : ( x->r.g_y ) );
     x->r.g_w = (( x->r.g_w > desk.g_w ) ? ( desk.g_w ) : ( x->r.g_w ));
     x->r.g_h = (( x->r.g_h > desk.g_h ) ? ( desk.g_h ) : ( x->r.g_h ));
}


/* bputstr()
 * ================================================================
 */
void
bputstr( char *str )
{
  while( *str )
      Inf_Buf[ bindex++ ] = *str++;
}



/* bputcr()
 * ================================================================
 */
void 
bputcr( void )
{
  Inf_Buf[ bindex++ ] = 0x0D;
  Inf_Buf[ bindex++ ] = 0x0A;
  Inf_Buf[ bindex ] = '\0';
}



/* bgetstr()
 * ================================================================
 */
void
bgetstr( char *str )
{
   while( Inf_Buf[ bindex ] != 0x0D )
   	*str++ = Inf_Buf[ bindex++ ];
   bindex++;
   bindex++;
   *str++ = '\0';
}




void
Get_Extension( char *Path, char *text )
{
   long i;
   
   for( i = strlen( Path ); i && (( Path[i] != '\\') && ( Path[i] != '*' ) && ( Path[i] != '?' )); i-- );
   
   /* Heck, if there is no (i), then we hit the front, so they lose */
   /* If we hit the '\\' and no * or ?, we have a filename..*/
   if( Path[i] == '\\' ) 
   { /* Therefore, get *.ext */
     text[0] = '*';
     for( i = i; (i < strlen( Path )) && Path[i] != '.'; i++ );
     strcpy( &text[1], &Path[i] ); 
   }
   else
   {
      /* we hit a * or ? so we have an extension */
      /* Therefore, get the whole thing from \\ onwards.*/
      for( i = strlen( Path ); i && ( Path[i] != '\\'); i-- );
      strcpy( text, &Path[i + 1 ] );
   }
}



void
SetCluster( int flag )
{
   menu_ienable( ad_menu, SAVEC, flag );
}




int
TooBigRam( void )
{
    if( form_alert( 1, "[1][ | There is not enough| memory for this world.| Size World to fit?][YES|Cancel]") == 1 )
    {
       return( TRUE );
    }   
    return( FALSE );
}



/* Get the GRECT from the VIEWER.INF file.
 * Here we have 0,0,0,0 - 4 numbers with commas in between and a \d
 * at the end.
 */
void
Get_Grect( GRECT *rect, char *str )
{
   char temp[10];
   char *ptr;
   int  i;
   int  *rptr;
   
   rptr = (int *)rect;
   for( i = 0; i<4;i++ )
   {
     ptr = temp;
     while( (*str != ',') && (*str != '\0') && (*str != 0x0D ))
   	  *ptr++ = *str++;
     str++;	  
     *ptr = '\0';	  
     *rptr++  = atoi( temp );   	
   }  
   
}




/* Load a world at boot-up time. */
void
World_Check( void )
{
   long i;
   
   for( i = strlen( World_Path ); i && (( World_Path[i] != '\\') && ( World_Path[i] != '*' ) && ( World_Path[i] != '?' )); i-- );
   /* if i == 0, we hit the front, so no filename, they lose.
    * if we hit a \\, then we have a filename.
    * if we hit a * or ?, we hit a wildcard, so skip and don't load the
    * world.
    */
   if( i )
   {
      if( World_Path[i] == '\\' )
      {
	load_world( World_Path );      
      }
   }      
}




/* Handles quitting */
void
do_quit( int *event )
{
   if( form_alert( 1,"[1][ | Leave ViewMaster? ][OK|Cancel]" ) == 1 )
   {
       *event = FALSE;
       vex_butv( vhandle, ( int (*)() )BUT_ADDR, ( int (**)() )&dummy );
       Write_Inf();
       DaveExit();
   }    
}



/*   Clear World Handling...  */
void
Clear_World( void )
{
   if( form_alert( 1, "[1][ | Clear the World? ][OK|Cancel]") == 1 )
   {
       DaveClrWorld();
       do_redraw( WORLD, &wstruct[ WORLD ].w );
   }    
}



/* Clear Floor Handling...  */
void
Clear_Floor( void )
{
  if( form_alert( 1, "[1][ | Clear the Floor? ][OK|Cancel]") == 1 )
  {
     ClrFloor();
     do_redraw( WORLD, &wstruct[ WORLD ].w );
  }    
}



/* Help key */
void
do_help( void )
{
   GRECT  rect;
   GRECT  xrect;
   int    button;
   OBJECT *tree;   
   
   ActiveTree( ad_help );
   xrect.g_x = xrect.g_y = 10;
   xrect.g_w = xrect.g_h = 36;
   
   Form_center( ad_help, &rect );
   Form_dial( FMD_START, &xrect, &rect );
   Form_dial( FMD_GROW, &xrect, &rect );


   Help_Page = 0;
   Disable( HPREV );
   Enable( HNEXT );
   Assign_Help_Strings();
   Objc_draw( ad_help, ROOT, MAX_DEPTH, &rect );
   do
   {
      button = form_do( ad_help, 0 );
      if(( button == HNEXT ) || ( button == HPREV ))
      {
         if( ( button == HNEXT ) && !IsDisabled( HNEXT ) && ( Help_Page <= MAX_HELP_PAGE ) )
           Help_Page++;
         
         if( ( button == HPREV ) && !IsDisabled( HPREV ) && ( Help_Page > 0 ) )
           Help_Page--;
           
         if( Help_Page <= 0 )
            Disable( HPREV );
         else
            Enable( HPREV );   
         
         if( Help_Page >= MAX_HELP_PAGE )
            Disable( HNEXT );
         else
            Enable( HNEXT );
              
         Assign_Help_Strings();
         Objc_draw( ad_help, HBASE, MAX_DEPTH, NULL );
         deselect( ad_help, button );
         
         Objc_draw( ad_help, HPREV, MAX_DEPTH, NULL );
         Objc_draw( ad_help, HNEXT, MAX_DEPTH, NULL );

      }
   }while( button != HEXIT );

   Deselect( button );
   Form_dial( FMD_SHRINK, &xrect, &rect );
   Form_dial( FMD_FINISH, &xrect, &rect );
}



void
Assign_Help_Strings( void )
{
   OBJECT *tree;
   int i;
      
   ActiveTree( ad_help );
   for( i = H0; i <= H8; i++ )
   {
     TedText( i ) = help_text[ Help_Page ][ i - H0 ]; 
   }  
}


/* Dave calls this routine when he needs to check for a keystroke.*/
void
Check_Keyboard( int key )
{
   OBJECT *tree;
   int event = TRUE;

   ActiveTree( ad_menu );
   switch( key )
   {   
	 case K_DOWN:
	 case K_LEFT:
	 case K_RIGHT:
	 case K_UP:    do_arrow_buttons( key );
	 	       break;



	 case KC_A:	Set_Brush_Path();
	 		break;
	 		
	 case KC_Q:     do_quit( &event );
	 		if( !event )
			   gem_exit(0);	 		
	 		break;
	 		
	 case KC_W:	Clear_World();
	 		break;
	 		
	 case KC_F:	Clear_Floor();
	 		break;
	 		
	 case KC_S:	Size_World();
	 		break;
	 		
	 case KC_N:     DaveTile();
 	                do_redraw( WORLD, &wstruct[ WORLD ].w );
	 		break;
	 		
	 case KC_I:     Do_Tile_Irr();
	 		break;
	 		
	 case KC_Z:     Set_Window_To_Size( 160, 102 );
	 		break;
	 		
	 case KC_X:     Set_Window_To_Size( wstruct[ WORLD ].w_wid, wstruct[ WORLD ].w_hite );
	 		break;
	 		
	 case KC_G:     Do_Grid_Size();
	 		break;
	 
	 case KC_T:     strcpy( title, "Load World List" );
      		        Do_Wfile( LOADW );
	 		break;
	 		
	 case KC_Y:     strcpy( title, "Save World List" );
	      		Do_Wfile( SAVEW );
	 		break;
	 
	 case KC_P:     LoadPal();
	 		break;
	 		
	 case KC_J:     strcpy( title, "Load Cluster List" );
      		        Do_Cfile( LOADC );
	 		break;
	 		
	 case KC_K:	ActiveTree( ad_menu );
	 		if( !IsDisabled( SAVEC ) )
	 		{
	                   strcpy( title, "Save Cluster List" );
      		           Do_Cfile( SAVEC );
      		        }   
	 		break;

	 case K_HELP:	do_help();
	 		break;
	 		
	 default:
			break;
    }						
}




/* EatEvnt()
 * ================================================================
 */
void
EatEvnt( void )
{
   static	int	ev_clicks=0, ev_bmask=0, ev_bstate=0;
   static	MOBLK	ev_m1 = { 0, 0, 0, 0, 0 };
   static	MOBLK	ev_m2 = { 0, 0, 0, 0, 0 };
   static	long	ev_time=0L;
   
   int		msg[8], nclicks;
   int	 	event;

   for( ;; )
   { 
     event = Evnt_multi(  MU_TIMER | MU_MESAG | MU_KEYBD, ev_clicks, ev_bmask, ev_bstate,
  	   	       &ev_m1, &ev_m2, ( WORD *)msg, ev_time,
   	       	       &Mrets, ( WORD *)&Key, ( WORD *)&nclicks );
     if( event == MU_TIMER )
     	break;
   }
}




/* EatKeyboard()
 * ================================================================
 */
void
EatKeyboard( void )
{
   static	int	ev_clicks=0, ev_bmask=0, ev_bstate=0;
   static	MOBLK	ev_m1 = { 0, 0, 0, 0, 0 };
   static	MOBLK	ev_m2 = { 0, 0, 0, 0, 0 };
   static	long	ev_time=0L;
   
   int		msg[8], nclicks;
   int	 	event;

   for( ;; )
   { 
     event = Evnt_multi(  MU_TIMER | MU_KEYBD, ev_clicks, ev_bmask, ev_bstate,
  	   	       &ev_m1, &ev_m2, ( WORD *)msg, ev_time,
   	       	       &Mrets, ( WORD *)&Key, ( WORD *)&nclicks );
     if( event == MU_TIMER )
     	break;
   }
}
