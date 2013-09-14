/* FILE: BUILDWD.C
 * ====================================================================
 * MODIFIED: July  9, 1991 cjg
 *	     July 12, 1991 cjg
 *
 * ====================================================================
 * 
 */

/* INCLUDE FILES
 * ====================================================================
 */
#include "fsmhead.h"
#include "country.h"
#include "fsm.h"
#include "text.h"
#include "mainstuf.h"
#include "fsmacc.h"

#include "fsmio.h"
#include "outline.h"
#include "ptbind.h"


/* DEFINES
 * ====================================================================
 */


/* PROTOTYPES
 * ====================================================================
 */
void	Make_Width_Table( void );
void	parse_fsmsys( void );
int	font_setup( FON_PTR curptr );
void	make_width( int ptsize);
void	font_close( void );
void	get_emsquare( int *em, int ptsize );
void	calc_dpi( int pixw, int pixh );
BOOLEAN	Check_Keyboard( void );


/* EXTERNS
 * ====================================================================
 */



/* GLOBALS
 * ====================================================================
 */
int i,j;
int charw, charh, boxw, boxh;
int numfnt;

int dummy;

long fsm_bufsize;
long fsm_buf;
long fsm_bufend;

int  fsm_handle;
char *fsmptr;

char fsm_path[128];
int  fsm_path_length;
char error_text[ 50 ];

int font_id;
int wdhandle;
int width_table[226];

float xdpi;
float ydpi;

char width_name[ 15 ];	/* Holds the filename.wid name */
OBJECT *Temp;


/* Make_Width_Table()
 * ====================================================================
 * ALWAYS will save the extend.sys with width tables off.
 * Make the tables.
 * Then resave the extend.sys with the current system setting.
 */
void
Make_Width_Table( void )
{
   BOOLEAN done = FALSE;
   int     width_flag;
         
   if( form_alert(1, alert2 ) == 2 )
   	return;

   width_flag    = Current.Width;
   Current.Width = 0;   
   fast_write_extend();

   if( !open_vwork())
   {
       form_alert( 1, alert18 );
       return;
   }

   MF_Save();
       
   calc_dpi( work_out[3], work_out[4] );

   Scan_Message( ad_load, TRUE );
   v_flushcache( vhandle );	/* flush the cache */
   numfnt=vst_load_fonts( vhandle, 0 );
   Scan_Message( ad_load, FALSE );
   
   done = Check_Keyboard();
   if( numfnt && !done && active_fsm_count )
   {
     Scan_Message( ad_width, TRUE );
     Temp = tree;
     ActiveTree( ad_width );
     parse_fsmsys();
     tree = Temp;
     Scan_Message( ad_width, FALSE );
     
     vst_unload_fonts( vhandle, 0 ); 
   }
   else
   {
     if( !done )
     	form_alert( 1, alert3 );
   }  
     
   MF_Restore();

   close_vwork();

   Current.Width = width_flag;
   fast_write_extend();   
   Make_Width_Flag = FALSE;	/* Reset the Make Width Table flag */
}





/* parse_fsmsys
 * ====================================================================
 * Parse the fsm.sys file and create the headers		
 * Need to ignore the symbol fonts				
 */
void
parse_fsmsys( void )
{
   int fsm_errors;
   BOOLEAN done;
      
   FON_PTR curptr;
   int count;
   int k;
   long i;
         
   curptr = active_fsm_list;
   
   done = FALSE;
   while( curptr && !done )
   {
   
      
      /* Check for existing point sizes */
      count = 0;
      for( k = 0; k < MAX_DEV; k++ )
      {
         if( POINTS( curptr )[k] )
           count++;
      }		
      
   
      /* if none, check and use the default point sizes */
      if( !count )
      {
         count = 0;
         for( k = 0; k < MAX_DEV; k++ )
         {
            POINTS( curptr )[k] = Current.point_size[k];
            if( Current.point_size[k] )
                  count++;
         }
      }
      
      
      /* create the wid file if a point size exists */
      if( count )
      {
        fsm_errors = font_setup( curptr );	/* create a wid file */
        if( fsm_errors > 0 )
        {
          strcpy( width_name, FFNAME( curptr ) );
          for( i = strlen( width_name ); i && ( width_name[i] != '.'); width_name[ i-- ] = '\0' );
          strcat( width_name,"WID" );
          TedText( WIDNAME ) = width_name;
          Objc_draw( ad_width, WIDNAME, MAX_DEPTH, NULL );
          
          for( k = 0; k < MAX_DEV; k++ )	/* make width table for each point size */
          {
            if( POINTS( curptr )[k] )
                make_width( POINTS( curptr )[k] );
          }   
          font_close();
        }
        else
        {
           if( !fsm_errors )
               form_alert( 1, alert4 );/* later use filename.WID */
        }
      }  
      curptr = FNEXT( curptr );		/* get next file */
      done = Check_Keyboard();   
   }
}


/* font_setup()
 * ====================================================================
 */
int
font_setup( FON_PTR curptr )
{
    int i;
    int fnt;
    
    fnt = vst_font( vhandle, FONTID( curptr ) );
    
    if( fnt == FONTID( curptr ) )
    {
      sprintf( fsm_path, "%s\\%s", Current.FontPath, FFNAME( curptr ) );
      for( i = (int)strlen( fsm_path ); i && fsm_path[i] != '.'; fsm_path[i--] = '\0' );
      strcat( fsm_path, "WID" );
      wdhandle = Fcreate( fsm_path, 0 );
    }
    else
    {
       wdhandle = 0;
       sprintf( error_text, alert5, FFNAME( curptr ) );/* later use filename.wid */
       form_alert( 1, error_text );
    }	
    return( wdhandle );
}



/* make_width()
 * ====================================================================
 */
void
make_width( int ptsize )
{
   int i;
   int minade,maxade,maxwidth;
   int dist[5];
   int effects[3];
   int tot;
   int width;
   int em;

   vst_point( vhandle, ptsize, &dummy, &dummy, &dummy, &dummy );
   get_emsquare( &em, ptsize );
   width_table[0] = em;      
   vqt_fontinfo( vhandle, &minade, &maxade, dist, &maxwidth, effects );
   minade = 32;
   maxade = 254;
   tot = 0;
   for (i=minade; i <= maxade; i++) {
	width_table[i - minade + 1] = tot;
	vqt_width( vhandle, i , &width, &dummy, &dummy );
	tot += width;
    }
    width_table[i - minade + 1] = tot;		/* last entry */
    Fwrite( wdhandle, 452L, width_table );
}




/* font_close()
 * ====================================================================
 */
void
font_close( void )
{
    if( wdhandle > 0 )
         Fclose( wdhandle );
}



/* get_emsquare()
 * ====================================================================
 */
void
get_emsquare( int *em, int ptsize )
{
	int dpix, roundoff;
	register long temp;

	dpix = xdpi;

	temp = (long) dpix * (long) ptsize;
	roundoff = ((temp % 72L) > 36L);
	temp /= 72;	
	*em = (int) temp + roundoff;
}


/* calc_dpi()
 * ====================================================================
 * Calculates the dpi for a workstation.  Should only be called
 * once per init_owt_entry().
 */
void
calc_dpi( int pixw, int pixh )
{
	float aspect;

        aspect = (float)pixw/(float)pixh;
        if( work_in[0] <= 10 )
        {
          if( work_out[0] > 640 )
          {
              xdpi = 91.0;
              ydpi = 91.0 * aspect;
          }
          else
          {
              xdpi = 91.0 * (float)work_out[0]/640.0;
              ydpi = xdpi * aspect;
          }
        }
        else
        {
            xdpi = (float)( 25400 / pixw );
            ydpi = (float)( 25400 / pixh );
        }	
}


/* Check_Keyboard()
 * ====================================================================
 * Checks to see if a keypress occurred so that we can exit the
 * makewidth routines.
 */   
BOOLEAN
Check_Keyboard( void )
{
   int		event, msg[8], key, nclicks;
   MRETS	mrets;
   static	int	ev_clicks=0, ev_bmask=0, ev_bstate=0;
   static	MOBLK	ev_m1   = { 0, 0, 0, 0, 0 };
   static	MOBLK	ev_m2   = { 0, 0, 0, 0, 0 };
   static	long	ev_time = 0L;
   BOOLEAN  	done = FALSE;

   event = Evnt_multi( MU_KEYBD | MU_TIMER, ev_clicks, ev_bmask, ev_bstate,
		       &ev_m1, &ev_m2, ( WORD *)msg, ev_time,
		       &mrets, ( WORD *)&key, ( WORD *)&nclicks );

   if( event != MU_TIMER )
   {
         if( form_alert( 1, alert16 ) == 1 )
	      	 done = TRUE;
   }	     
   return( done );
}
