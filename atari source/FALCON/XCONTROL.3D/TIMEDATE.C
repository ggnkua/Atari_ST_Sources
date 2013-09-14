/* FILE:  TIMEDATE.C
 *==========================================================================
 * DATE:  January 21, 1990
 * DESCRIPTION:
 *
 * INCLUDE FILE: TIMEDATE.H
 */
 

/* INCLUDE FILES
 *==========================================================================
 */
#include <sys\gemskel.h>
#include <string.h>
#include <tos.h>

#include "country.h"
#include "xcontrol.h"				/* Xcontrol.c Defines   */
#include "xcontrl2.h"				/* Xcontrol.c prototype */

#include "windows.h"
#include "text.h"

/* PROTOTYPES
 *==========================================================================
 */
void get_time( int *date_flag );
void showtime( int date_flag );
void my_itoa( char *ptr, int val, int suppress );
int  my_atoi( char *ptr );
void set_time( void );
int  keybutt_wait( int *mx, int *my, int *key );
void time_handle( void );
void update_time( void );
void init_time( void );
void time_date_stamp( int obj );
void redraw_hour( int new );

/* This is found in xoptions.c */
void wait_up( void );


/* DEFINES
 *==========================================================================
 */
#define DATE_SAME	0
#define DATE_DIFF	1
#define HOUR12		0
#define HOUR24		1

/* GLOBALS
 *==========================================================================
 */
int  hour, minute;				/* Current Date Values  */

int  hour_state;				/* 12 or 24 hour object */

char date[] = "       ";			/* The time and date    */
char time[] = "      ";				/* Strings...		*/

int  date_flag = DATE_DIFF;			/* 0 - same, 1 - diff   */

int  year  = 0,  year_bak  = 0;
int  month = 0,  month_bak = 0;
int  day   = 0,  day_bak   = 0;


int TIME;			/* The current TIME object
				 * TIME12 - 12 hour time
				 * TIME24 - 24 hour time ( no AM/PM )
				 */


/* FUNCTIONS
 *==========================================================================
 */



/* init_time()
 *==========================================================================
 * Initialize the time by getting what we think the time is and updating
 * the tedinfo structures.
 */
void
init_time( void )
{
   update_time();
}




/* update_time()
 *==========================================================================
 * Gets the current time and updates the tedinfo structures.
 */
void
update_time( void )
{
   OBJECT *tree = ( OBJECT *)rs_trindex[ XCONTROL ];
   
   if( hour_state == HOUR24 )
   {
        TIME = TIME24;
        HideObj( TIME12 );
        ShowObj( TIME24 );
   }
   else
   {
   	TIME = TIME12;
    	HideObj( TIME24 );
    	ShowObj( TIME12 );
   }

   get_time( &date_flag );
   showtime( date_flag );
}





/* time_handle()
 *==========================================================================
 * During every timer event, update the time, and redraw
 *
 * IN:  void
 * OUT: void
 *
 * GLOBAL:	WINFO w:		window structure
 */ 
void
time_handle( void )
{
   OBJECT *tree = ( OBJECT *)rs_trindex[ XCONTROL ];
   GRECT rect_time;
   GRECT rect_date;

   if( w.id == NO_WINDOW )
   		return;
   update_time();
 
   rect_time = ObRect( TIME );
   objc_offset( tree, TIME, &rect_time.g_x, &rect_time.g_y );

   rect_date = ObRect( DATE );
   objc_offset( tree, DATE, &rect_date.g_x, &rect_date.g_y );
  
   if( date_flag )
      	  do_redraw( tree, DATE, &rect_date );
   do_redraw( tree, TIME, &rect_time );
}





/* get_time()
 *==========================================================================
 * Get what the system thinks the time currently is
 * 
 * IN:    int *date_flag:	Set to True if date still the same
 * OUT:   void
 *
 * GLOBAL:   All of the time variables...
 */
void
get_time( int *date_flag )
{
    unsigned int temp;
    
    temp = Tgettime();				/* Get GEMDOS time */
    minute = 0x03f & (temp >> 5);
    hour   = 0x01f & (temp >> 11);
       						/* Get GEMDOS Date */
    temp  = Tgetdate();  
    day   = 0x1f & temp;
    month = 0x0f & (temp >> 5);
    year  = ((0x07f & (temp >> 9)) + 80)%100;
    
    if(( day_bak   == day   ) &&
       ( month_bak == month ) &&
       ( year_bak  == year  ))
       *date_flag = DATE_SAME;
    else
    {
       *date_flag = DATE_DIFF;
       day_bak    = day;
       month_bak  = month;
       year_bak   = year;
    }
}





/* showtime()
 *==========================================================================
 * Update the time tedinfo structures
 * 
 * IN:   int date_flag:		Skip date redraw if true
 * OUT:  void
 *
 * GLOBAL:   All of the date variables
 */
void
showtime( int date_flag )
{
   OBJECT *tree  = (OBJECT *)rs_trindex[ XCONTROL ];

   if( date_flag )
   {
      #if USA
         my_itoa( &date[0], month, TRUE );
         my_itoa( &date[2], day, FALSE ); 
         my_itoa( &date[4], year, FALSE );
      #endif
      
      #if SWEDEN
         my_itoa( &date[0], year, FALSE );
         my_itoa( &date[2], month, FALSE );
         my_itoa( &date[4], day, FALSE );
      #endif
      
      #if UK|GERMAN|FRENCH|ITALY|SPAIN
         my_itoa( &date[0], day, TRUE );
         my_itoa( &date[2], month, FALSE ); 
         my_itoa( &date[4], year, FALSE );
      #endif      
      date[6] = '\0';
      TedText( DATE )  = date;      
   }



   #if USA | UK | SPAIN | FRENCH | ITALY
     if( hour_state == HOUR24 )
   	my_itoa( &time[0], hour, TRUE );
     else
     {
       if(hour)
   	  my_itoa( &time[0], (( hour > 12 ) ? hour-12 : hour ) , TRUE );
       else
          my_itoa( &time[0], 12, TRUE );
     }
     my_itoa( &time[2], minute, FALSE );
     
     if( hour_state == HOUR24 )
     	time[4] = '\0';
     else
        time[4] = (hour < 12) ? 'A' : 'P';

   #else
      my_itoa( &time[2], minute, FALSE );
      my_itoa( &time[0], hour, TRUE );
      time[4] = '\0';
   #endif
   time[5] = '\0';
   TedText( TIME ) = time;
}




/* set_times()
 *==========================================================================
 * Given time and date, set the system time and date
 *
 * IN:  void
 * OUT: void
 *
 * GLOBAL:   char date[]:	date string
 *	     char time[]:       time string
 */
void
set_time( void )
{
  int miltime;
  int ibmyr;

  #if SWEDEN
      ibmyr = my_atoi( &date[0] );
  #else
      ibmyr  = my_atoi( &date[4] );
  #endif
  
  ibmyr = (( ibmyr < 80 ) ? ( ibmyr + 20 ) : ( ibmyr - 80 ));
  ibmyr = ibmyr << 9;
  
  #if USA
     ibmyr |= ( my_atoi( &date[0] ) & 15 ) << 5;   /* month */
     ibmyr |= ( my_atoi( &date[2] ) & 31 );	   /* day   */
  #endif   
 
  #if UK | GERMAN | FRENCH | ITALY | SPAIN 
     ibmyr |= (my_atoi(&date[2]) & 15) << 5;	/* month */
     ibmyr |= (my_atoi(&date[0]) & 31);		/* day   */
  #endif
  
  #if SWEDEN 
	ibmyr |= (my_atoi(&date[2]) & 15) << 5;	/* month */
	ibmyr |= (my_atoi(&date[4]) & 31);	/* day */
  #endif
  
  Tsetdate(ibmyr);
  miltime = my_atoi( &time[0] ) & 31;

  #if USA | UK | SPAIN | FRENCH
     if(( miltime < 12 )  && ( time[4] == 'P' )) miltime += 12;
     if(( miltime == 12 ) && ( time[4] == 'A' )) miltime = 0;
  #endif

  miltime = ( miltime << 11 ) | (( my_atoi( &time[2] ) & 63 ) << 5 );
  Tsettime(miltime);
  Settime(((long)Tgetdate() << 16) | ((long)Tgettime()));  
}




/* time_date_stamp()
 *==========================================================================
 * EDIT either the time or the date object and set the new time and date
 *
 * IN:  int obj:	time or date object was selected
 * OUT: void
 *
 * GLOBAL:   date_flag:  TRUE if skip date redraw
 */
void
time_date_stamp( int obj )
{
   OBJECT *tree = ( OBJECT *)rs_trindex[ XCONTROL ];

   Select( obj );
   MakeExit( obj );
   MakeDefault( obj );
   MakeEditable( obj );
   Objc_draw( tree, obj, 0, NULL );
   wait_up();
   form_do( tree, obj );
   NoExit( obj );
   NoDefault( obj );
   NoEdit( obj );
   set_time();
   get_time( &date_flag );
   if( obj == DATE )
   	date_flag = DATE_DIFF;
   showtime( date_flag );
   Deselect( obj );
   wait_up();
   Objc_draw( tree, obj, 0, NULL );   
}


 
 
/* my_itoa()
 *==========================================================================
 * Custom itoa that supresses the zero when requested.
 * NOTE: These are 2 digit conversions ONLY.
 */
void
my_itoa( char *ptr, int val, int suppress )
{
    *ptr++ = (suppress && ((val/10) == 0)) ? ' ': ((val/10) + '0');
    *ptr = (val%10) + '0';
}



/* my_atoi()
 *==========================================================================
 * Custom atoi that understands suppressed zeros
 * Note: These are 2 digit conversions ONLY.
 */
int
my_atoi( char *ptr )
{
   int temp;
   
   temp = (*ptr == ' ') ? 0 : 10*(*ptr - '0');
   return( temp + (*++ptr - '0'));
}



/* redraw_hour()
 *==========================================================================
 * Switch between 12 hours and 24 hour time clocks and redraw the object
 *
 * IN:  int new:	The new hour format: - either 12 or 24 hour
 *			Its  0 - 12 Hours, 1 = 24 Hours
 * OUT  void
 */
void
redraw_hour( int new )
{
    OBJECT *tree = ( OBJECT *)rs_trindex[ XCONTROL ];
       
    hour_state = new;

    update_time();
    Vsync();
    Objc_draw( tree, TIME, 0, NULL );
}



