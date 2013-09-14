/* STATUS.C
 *==========================================================================
 * DATE:	February 2, 1990
 * DATE:	March 22, 1990
 *
 * DESCRIPTION: Displays TOS version and date
 *		Displays ST RAM and TT RAM ( Free and Total )
 * 09/08/92 cjg - Use the softloaded value, not the ROM value
 */




/* INCLUDE FILES
 *==========================================================================
 */
#include <sys\gemskel.h>
#include <tos.h>
#include <string.h>
#include <stdlib.h>

#include "country.h"

#include "general.h"
#include "gen2.h"

#include "super.h"



/* PROTOTYPES
 *==========================================================================
 */
void do_os( void );
void do_status( void );
void clear_status( void );
#if 0
void do_memory( int Total_object, char *xtotal,
                int Free_object , char *xfree,
                int device );
#endif
void do_memory( int Free_object, char *xfree, int device );
                
void wait_button( int flag );
long *Fmalloc( long num, int item );

#if 0
long Get_Total_Ram( int device );
long get_total_ram( void );
#endif

int  stat_button( int button, WORD *msg );

void Set_Date( char *osdate );


/* DEFINES
 *==========================================================================
 */
#define STRAM	0
#define _MAGIC		0x1357bd13L

#define STRAM   0
#define TTRAM   1


/* EXTERNALS
 *==========================================================================
 */

/* GLOBALS
 *==========================================================================
 */
int  errno;				/* errno declaration		*/

int  max_stat;				/* max and min y value of status*/
int  min_stat;				/* Note, these are y offsets... */
char tosdate[10];			/* TOS VERSON DATE		*/
char tosvers[10];			/* TOS VERSION NUMBER		*/

char total[10];				/* ST RAM total available       */
char tfree[10];				/* ST RAM free...		*/
char ttotal[10];
char ttfree[10];
char ttblank[] = "         ";
char tt_temp[ 10 ];

int blit_inc;				/* incrementer for scrolling of */
					/* the status box...		*/
					/* see sl_y for implementation. */
int stat_value;				/* y variable of status slider  */
					/* Note: it is an offset	*/
					/* off of the current y value   */
long Total_Ram;
/*
int  Ram_Device;
*/

int  OSDATE;				/* Object for cpx date (text)   */


/* FUNCTIONS
 *==========================================================================
 */


/* do_os()
 *==========================================================================
 */
void
do_os( void )
{
  OBJECT *ad_partz    = (OBJECT *)rs_trindex[PARTZ];
  OBJECT *tree;
  char *version;
  char *osdate;
  int j;
  SYSHDR *osheader;
  char  num;
  
  Enter_Super();
  osheader = *((SYSHDR **)0x4f2L);
  Exit_Super();
  
  /* Don't use the ROM version 09/08/92 cjg */
/*  osheader = osheader->os_base;*/
  version  = (char *)&osheader->os_version;
  osdate   = (char *)&osheader->os_gendat;
  
  for(j = 0;j<=3;j += 2)
  {
    num = *version++;
    tosvers[j] = ((num & 0xf0) >> 4) + '0';
    tosvers[j+1] = (num & 0x0f) + '0';
  }
  ActiveTree( ad_partz );
  Set_Date( osdate );
  TedText( OSDATE ) = &tosdate[0];
  TedText( VERSION ) = &tosvers[0];
}




/* do_status()
 *==========================================================================
 */
void
do_status( void )
{
  OBJECT *ad_tree  = (OBJECT *)rs_trindex[GENERAL];
  OBJECT *ad_partz = (OBJECT *)rs_trindex[PARTZ];
  OBJECT *tree;
  int x,y;
  long p_value;
  
  ActiveTree( ad_tree );
  x = ObX( ROOT );
  y = ObY( ROOT );
  Deselect( STATUS );
    
  ActiveTree( ad_partz );
  ObX( ROOT ) = x;
  ObY( ROOT ) = y;

  HideObj( TOTALTXT );  
  HideObj( FREETXT );
  HideObj( TTTOTAL );
  HideObj( TTFREE );
  
  do_os();
  
  Total_Ram = 0L;
  
  do_memory( STFREE, tfree, STRAM );

  /* Hide the TT data unless _FRB exists */  
  if( (*xcpb->getcookie)( 0x5f465242L, &p_value ))
  {
     do_memory( TTFREE, ttfree, TTRAM );
     
     ShowObj( TOTALTXT );
     ShowObj( FREETXT );
     ShowObj( TTTOTAL );
     ShowObj( TTFREE );

     ltoa( Total_Ram, tt_temp, 10 );
     tt_temp[9] = '\0';
     
     strcpy( ttotal, ttblank );
     ttotal[ 9 - ( int )strlen( tt_temp ) ] = '\0';
     strcat( ttotal, tt_temp );

     ActiveTree( ad_partz );
     ObString( TTTOTAL ) = ttotal;  
    
  }
  xtree = tree;
  Objc_draw( tree, ROOT, MAX_DEPTH, NULL );
}



/* clear_status()
 *==========================================================================
 */
void
clear_status( void )
{
  OBJECT *ad_tree  = (OBJECT *)rs_trindex[GENERAL];
  OBJECT *ad_partz = (OBJECT *)rs_trindex[PARTZ];
  OBJECT *tree;
  
  ActiveTree( ad_partz );
  Deselect( STATOK );
  
  ActiveTree( ad_tree );
  Deselect( STATUS );
  Objc_draw( ad_tree, GENERAL, MAX_DEPTH, NULL );
  wait_button( UP );
}



/* do_memory()
 *==========================================================================
 */
#if 0 
void
do_memory( int Total_object, char *xtotal,
           int Free_object,  char *xfree,
           int ram_item  )
#endif
void
do_memory( int Free_object, char *xfree, int ram_item )           
{
  OBJECT *ad_partz = (OBJECT *)rs_trindex[PARTZ];
  OBJECT *tree;

  long freenum  = 0L;
  long tempnum  = 0L;
  
  long *mptr;
  long *head;
  long *tptr;
  long *xptr;

  head = mptr = tptr = 0L;
  tempnum = ( long )Fmalloc( -1L, ram_item );
  while( tempnum > 4L )
  {
     if( !head )
     {
        head  = mptr = Fmalloc( tempnum, ram_item );
        *head = 0L;
     }
     else
     {
        tptr  = Fmalloc( tempnum, ram_item );
        *tptr = 0L;
        *mptr = ( long )tptr;
        mptr  = tptr;
     }
     freenum += tempnum;
     tempnum = ( long )Fmalloc( -1L, ram_item );       
  }
  

  if( head )
  {  
    tptr = 0L;
    while( *head )
    {
       mptr = (long *)*head;
       xptr = head;
       while( mptr )
       {
       	 tptr = mptr;
       	 mptr = ( long *)*mptr;
       	 if( mptr )
       	     xptr = tptr;
       }
       if( tptr )
       {
          Mfree( tptr );
          tptr  = ( long *)0L;
          *xptr = 0L;
       }
    }
    Mfree( head );
  }

  ltoa( freenum, tt_temp, 10 );
  tt_temp[9] = '\0';

  Total_Ram += freenum;
  
  strcpy( xfree, ttblank );
  xfree[ 9 - ( int )strlen( tt_temp ) ] = '\0';
  strcat( xfree, tt_temp );

  ActiveTree( ad_partz );
  ObString( Free_object )  = xfree;
}



long
*Fmalloc( long num, int item )
{
     long p_value;
     long _ramtop;
     long _ramvalid;
     long value = 0L;
     
     if( (*xcpb->getcookie)( 0x5f465242L, &p_value ))
     {
         if( item == TTRAM )
         {
            Enter_Super();
            _ramvalid = *( long *)0x5a8;
            _ramtop   = *( long *)0x5a4;
            Exit_Super();   
         
            if( ( _ramvalid == _MAGIC ) &&
                ( _ramtop > 0x1000000L ) )
            {
               value= ( long )gemdos( (int)0x44, (long)num, (int)item );          
            }
         }
         else
            value = (long)gemdos((int)0x44,(long)num,(int)item);
     }
     else
     {
       if( item == STRAM )
               value = ( long )Malloc( num );
     }
     return( (long *)value );
}


#if 0
long
Get_Total_Ram( int item )
{
    Ram_Device = item;
    Supexec( get_total_ram );
    return( Total_Ram );
}


long
get_total_ram( void )
{
     long p_value;
     long _ramtop;
     long _ramvalid;
     
     Total_Ram = 0L;
     if( ((*xcpb->getcookie)( 0x5f465242L, &p_value )) &&
         Ram_Device == TTRAM )
     {
         _ramvalid = *( long *)0x5a8;
         _ramtop   = *( long *)0x5a4;
         
         if( ( _ramvalid == _MAGIC ) &&
             ( _ramtop > 0x1000000L ) )
             Total_Ram = _ramtop - 0x1000000L;
     }
     
     if( Ram_Device == STRAM )
        Total_Ram = *(long *)0x42EL;
     return( 0L );
}
#endif





int
stat_button( int button, WORD *msg )
{
   OBJECT *tree = ( OBJECT *)rs_trindex[ PARTZ ];
   int done = FALSE;
   int x,y;
   
   switch( button )
   {
      case STATOK:  wait_button( UP );
      		    Deselect( button );
   		    x = ObX( ROOT );
   		    y = ObY( ROOT );
   		    xtree = ( OBJECT *)rs_trindex[ GENERAL ];
   		    ActiveTree( xtree );
   		    ObX( ROOT ) = x;
   		    ObY( ROOT ) = y;
		    Objc_draw( tree, ROOT, MAX_DEPTH, NULL );
		    break;
      
      default:	if( button == -1 )
  		{
     		   switch( msg[0] )
     		   {
     		     case AC_CLOSE:  done = TRUE;
		     		     pop_data();	
		     		     break;
     			     		     
		     case WM_CLOSED: done = TRUE;
		     		     Set_Data();
				     break;
     		     default:
     		     		break;
     		   }
     		}
     		break;
   }
   return( done );   
}



void
Set_Date( char *osdate )
{
  
  OBJECT *tree = ( OBJECT *)rs_trindex[ PARTZ ];
  
  HideObj( DATE1 );
  HideObj( DATE2 );
  
  #if USA	/* mm/dd/yyyy */
      ShowObj( DATE1 );
      OSDATE = DATE1;
      tosdate[0] = (( *osdate & 0xf0 ) >> 4 ) + '0';
      tosdate[1] = ( *( osdate++ ) & 0x0f ) + '0';
      
      tosdate[2] = (( *osdate & 0xf0 ) >> 4 ) + '0';
      tosdate[3] = ( *( osdate++ ) & 0x0f ) + '0';
      
      tosdate[4] = (( *osdate & 0xf0 ) >> 4 ) + '0';
      tosdate[5] = ( *( osdate++ ) & 0x0f ) + '0';
      
      tosdate[6] = (( *osdate & 0xf0 ) >> 4 ) + '0';
      tosdate[7] = ( *( osdate++ ) & 0x0f ) + '0';
  #endif

  #if SWEDEN
      /* yyyy-mm-dd */
      
      ShowObj( DATE2 );
      OSDATE = DATE2;
      tosdate[0] = (( *( osdate + 2 ) & 0xf0 ) >> 4 ) + '0';
      tosdate[1] = (  *( osdate + 2 ) & 0x0f ) + '0';
      
      tosdate[2] = (( *( osdate + 3 ) & 0xf0 ) >> 4 ) + '0';
      tosdate[3] = (  *( osdate + 3 ) & 0x0f ) + '0';
      
      
      tosdate[4] = (( *osdate & 0xf0 ) >> 4 ) + '0';
      tosdate[5] = (  *( osdate ) & 0x0f ) + '0';
      
      tosdate[6] = (( *( osdate + 1 )  & 0xf0 ) >> 4 ) + '0';
      tosdate[7] = (  *( osdate + 1 ) & 0x0f ) + '0';
 #endif
  
  
  #if UK | GERMAN | FRENCH | ITALY | SPAIN 
      /* dd/mm/yyyy */
      ShowObj( DATE1 );
      OSDATE = DATE1;
      tosdate[0] = (( *( osdate + 1 ) & 0xf0 ) >> 4 ) + '0';
      tosdate[1] = (  *( osdate + 1 ) & 0x0f ) + '0';
      
      tosdate[2] = (( *osdate & 0xf0 ) >> 4 ) + '0';
      tosdate[3] = (  *osdate & 0x0f ) + '0';
      

      tosdate[4] = (( *( osdate + 2 ) & 0xf0 ) >> 4 ) + '0';
      tosdate[5] = (  *( osdate + 2) & 0x0f ) + '0';
      
      tosdate[6] = (( *( osdate + 3 ) & 0xf0 ) >> 4 ) + '0';
      tosdate[7] = (  *( osdate + 3 ) & 0x0f ) + '0';
  #endif

  tosdate[8] = '\0';  
}
