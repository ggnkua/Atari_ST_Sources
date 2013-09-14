/* ======================================================================
 * FILE: FILEIO.C
 * ======================================================================
 * DATE: November 23, 1992
 *       January 20, 1993
 *
 * This file handles the I/O for the options dialog box which 
 * allows the user to change the parameters of a driver.
 */
 

/* INCLUDE FILES
 * ======================================================================
 */
#include <sys\gemskel.h>
#include <string.h>
#include <tos.h>
#include <stdio.h>
#include <stdlib.h>

#include "country.h"
#include "drvhead.h"
#include "mainstuf.h"
#include "text.h"
#include "fsmio.h"
#include "options.h"
#include "drivers.h"



/* PROTOTYPES
 * ======================================================================
 */
BOOLEAN	 Read_Data( void );
int	 *FindString( int *ptr, int *endptr );
BOOLEAN  Save_Data( void );
int	 CountDPI( HEADER *hdptr );
int	 SearchDPI( int xvalue, int yvalue );


/* DEFINES
 * ======================================================================
 */
#define E_OK 		0


/* EXTERNALS
 * ======================================================================
 */


/* GLOBALS
 * ======================================================================
 */
char    FPath[ 128 ];		/* Directory path */
int	xdpi[4];
int	ydpi[4];
int     icount;
long    mbuffer;
int  *DataPtr;
long EndIndex;


/* FUNCTIONS
 * ======================================================================
 */


/* Read_Data()
 * ================================================================
 * Read in the data and keep the buffer till later.
 */
BOOLEAN
Read_Data( void )
{
   DTA  thedta, *saved;
   int  fd;
   BOOLEAN flag;
   
            
   flag = FALSE;      
   saved = Fgetdta();
   Fsetdta( &thedta );
   if( Fsfirst( FPath, 0 ) <= -1 ) /* Can't find the file... */
   {				   
     form_alert( 1, alert52 );
   }
   else
   {
     DataBuf = calloc( 1, thedta.d_length * 2L );

     if( DataBuf )
     {
       fd = Fopen( FPath, 0 );	
       if( fd <= 0 )
       {
         form_alert( 1, alert51 );
       }
       else
       {
         Buffer = ( long )DataBuf;
         Buffer = ( Buffer + 15L ) & 0xFFFFFFF0L;
         DataHdr = ( int *)Buffer;
         
         Fread( fd, thedta.d_length, DataHdr );
         Fclose( fd );
     
         EndIndex = thedta.d_length;
         DataPtr  = FindString( DataHdr, DataHdr + EndIndex - 8 );
         if( DataPtr )
         {
           hdr = ( HEADER *)DataPtr;
           hdr_buffer = ( HEADER )*hdr;

           strcpy( title, hdr->fname );
	   icount = CountDPI( hdr );

	   mbuffer = ( long )&hdr->TopMargin;

	   if( icount >= 3 )	/* Get's us past a third page table */
	      mbuffer += 16L;
	   
	   if( icount >= 4 )	/* Get's us past a fourth page table */
	      mbuffer += 16L;
	      
	   mhdr = ( MARGIN *)mbuffer;
           flag = TRUE;
         }
         else
         {
           form_alert( 1, alert53 );  
         }
       }  
     }
     else
       form_alert( 1, alert54 );  
   }
   Fsetdta( saved );    
   return( flag );
}




/* FindString()
 * ======================================================================
 */
int
*FindString( int *ptr, int *endptr )
{
    long *xptr;
    
    while( ptr < endptr )
    {
       /* Look for _FSM_HDR */
       xptr = (long *)ptr;
       if( ((long)*xptr == 0x5f46534dL ) &&
           ((long)*(xptr+1) == 0x5f484452L ) )
       return( ptr );
       ptr++;
    }   
    return( ( int *)NULL );
}


/* Save_Data()
 * ======================================================================
 * Save out the Data - Note- The buffer is still there from the read_data.
 */
BOOLEAN
Save_Data( void )
{
   DTA  thedta, *saved;
   int  fd;
   BOOLEAN flag;
   int  index;
               
   flag = FALSE;      
   saved = Fgetdta();
   Fsetdta( &thedta );
   if( Fsfirst( FPath, 0 ) <= -1 ) /* Can't find the file... */
   {				   
     form_alert( 1, alert52 );
   }
   else
   {
     if( DataBuf )
     {
         if( DataPtr )
         {
    	   hdr_buffer.quality    = Menu[ MQUALITY ].curvalue;
           hdr_buffer.nplanes    = Menu[ MCOLOR ].curvalue + 1;
    	   hdr_buffer.PageSize   = Menu[ MPAGESIZE ].curvalue;
           hdr_buffer.xres       = xres_value;
           hdr_buffer.yres       = yres_value;
           hdr_buffer.port       = Menu[ MPORT ].curvalue;
           hdr_buffer.paper_feed = Menu[ MTRAY ].curvalue;


           *hdr = hdr_buffer;
	   /* NEED TO FIGURE OUT WHERE TOPMARGIN GOES...*/
	   index = SearchDPI( hdr->X_PIXEL[ Menu[ MHSIZE ].curvalue ], 
	   		      hdr->Y_PIXEL[ Menu[ MVSIZE ].curvalue ] );
	   
	   /* We're NOW at TopMargin!!!*/	   

	   /* check if Page Area Offset is ON or OFF */
	   if( IsSelected( AREAON ) )
	   {
	   	/* It's ON! - look at page table margins */
		/* Take the number from the appropriate page margin
		 * and shove it into the TopMargin etc...
		 */
	   	mhdr->TopMargin    = mhdr->Margin[ ( index * 4 ) + 0 ];
	   	mhdr->BottomMargin = mhdr->Margin[ ( index * 4 ) + 1 ];
	   	mhdr->LeftMargin   = mhdr->Margin[ ( index * 4 ) + 2 ];
	   	mhdr->RightMargin  = mhdr->Margin[ ( index * 4 ) + 3 ];
	   }
	   else
	   {
	   	/* It's OFF! - Shove zeros into it.*/
	   	mhdr->TopMargin    = 0;
	   	mhdr->BottomMargin = 0;
	   	mhdr->LeftMargin   = 0;
	   	mhdr->RightMargin  = 0;
	   }           
           flag = TRUE;

           fd = Fcreate( FPath, 0 );
           if( fd >= 0 )
           {
             Fwrite( fd, EndIndex, DataHdr );
             Fclose( fd );
           }
           else
             form_alert( 1, alert51 );  
         }
         else
         {
           form_alert( 1, alert53 );  
         }  
     }
     else
       form_alert( 1, alert54 );  
   }
   Fsetdta( saved );    
   return( flag );
}



/* CountDPI()
 * ======================================================================
 */
int
CountDPI( HEADER *hdptr )
{
    int  count;
    int  i,j;
    int  curx, cury;
    
    for( i = 0; i < 4; i++ )
    {
       xdpi[i] = ydpi[i] = 0;
    }

    count = 0;    
    if( hdptr )
    {
	curx = cury = 0;       
        for( i = 0; i < hdr->total_planes; i++ )
        {
           curx = hdr->X_PIXEL[i];
           cury = hdr->Y_PIXEL[i];
           
           if( curx && cury )
           {
               for( j = 0; j < 4; j++ )
               {
                 /* The slot is open! shove one in...*/
                 if( !xdpi[j] && !ydpi[j] )
                 {
                    count++;
                    xdpi[j] = curx;
                    ydpi[j] = cury;
                    break;
                 }
                 
                 /* This one already exists...*/
                 if( ( curx == xdpi[j] ) && ( cury == ydpi[j] ) )
                    break;
               }
               /* if we reach here without finding an empty slot...
                * or matching...
                * we're in trouble, cause I don't know how to handle
                * more than 4 different dpi's.
                */
           }
        }    	
    }
    if( !count || ( count > 4 ))
       count = 1;
    return( count );
}



/* Find the matching xdpi and ydpi in our array */
int
SearchDPI( int xvalue, int yvalue )
{
     int index;
     
     for( index = 0; index < 4; index++ )
     {
	 if( !xdpi[index ] && !ydpi[index ] )
	    return( 0 );
	    
         if( ( xdpi[index] == xvalue ) && ( ydpi[index] == yvalue ) )
         {
            return( index );
         }
         
     }
     return( 0 );
}
