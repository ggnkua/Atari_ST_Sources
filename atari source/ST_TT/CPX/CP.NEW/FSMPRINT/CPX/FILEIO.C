/* ======================================================================
 * FILE: FILEIO.C
 * ======================================================================
 * DATE: June 10, 1991
 * DESCRIPTION: FILE IO
 * COMPILER: TURBO C Version 2.0
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
#include "mainstuf.h"
#include "text.h"


/* PROTOTYPES
 * ======================================================================
 */
char	 GetBaseDrive( void );
int 	 kisspace( char thing );
char	 *extract_path( int *offset, int max );
void 	 get_bitpath( void );
BOOLEAN	 Read_Data( void );
int	 *FindString( int *ptr, int *endptr );
BOOLEAN  Save_Data( void );

void	 GetCDrivers( void );
void	 SortCDriverNames( void );


/* DEFINES
 * ======================================================================
 */
typedef struct _header
{
    long header[2];
    
    int	 quality;
    int  config_map;

    int  nplanes;
    int  total_planes;
    int  Plane[4];
    int  X_PIXEL[4];
    int  Y_PIXEL[4];
    
    int	 PageSize;
    int  xres;
    int  yres;
    int  port;
    int  paper_feed;
    char fname[ 26 ];
}HEADER;

/* FRONT END DEFINES */
#define MAX_DRIVERS	50	/* Maximum # of Drivers we can use */
#define E_OK 		0


/* EXTERNALS
 * ======================================================================
 */


/* GLOBALS
 * ======================================================================
 */

char	epath[ 128 ];		/* Path used to look for ASSIGN.SYS */
char 	path[128];		/* path plus filename 	      */
char    FPath[ 128 ];		/* Directory path */
char    blnkstring[] = "                ";
DTA     *olddma, newdma;	/* DTA buffers for _our_ searches */
char    *bufptr;		/* ptr to malloc'ed memory...     */
long    BufferSize;		/* Size of ASSIGN.SYS 		  */
BOOLEAN path_found;

int     *DataBuf;		/* Malloced buffer */
long    Buffer;
int	*DataHdr;		/* Word boundary Buffer */
long  	bindex;
HEADER  *hdr, hdr_buffer;

char    line_buf[ 128 ];


/* FUNCTIONS
 * ======================================================================
 */


/* GetBaseDrive()
 * ====================================================================
 * Get the A drive or C drive depending upon if there is a hard disk.
 */
char
GetBaseDrive( void )
{
    int  drv;
    char Drive;
    
    drv = (( Drvmap() & 4L ) ? ( 2 ) : ( 0 ) );
    Drive = drv + 'A';
    return( Drive );
}


/* kisspace()
 * ====================================================================
 */
int 
kisspace( char thing )
{
	if ((thing == ' ') || (thing == '\t')) return TRUE;
	else return FALSE;
}


/* extract_path()
 * ====================================================================
 *  Given an index into bufptr, immediately following the keyword that
 *  indicates a path follows, will extract a pointer to the path and
 *  return it.
 */
char
*extract_path( int *offset, int max )
{
	int j;

	/* Goes looking for the start of the path */
	while ( ( bufptr[ *offset ] != '=' ) && ( *offset < max ) )
	{
	  *offset += 1;
	}
	
	*offset += 1;
	while ( ( kisspace(bufptr[*offset])) && ( *offset < max) )
	{
	  *offset += 1;
	}

	/* Properly null terminates the path */
	j = *offset;
	while ((bufptr[j] != '\n') && (j < (max - 1)) && (bufptr[j] != '\r')) {++j;}
	bufptr[j] = '\0';

	return ( &bufptr[*offset] );
}


/* get_bitpath()
 * ====================================================================
 * Get the font path from the ASSIGN.SYS
 * If there is NO ASSIGN.SYS, we substitute C: or A: instead.
 *
 */
void 
get_bitpath( void )
{
	int  i, sys_file;
	long j;
	int  error;
	char *fname;
	int  alen;
		
	olddma = Fgetdta();	
	Fsetdta( &newdma );		/* Point to OUR buffer */

	strcpy( epath, "C:\\ASSIGN.SYS" );
	epath[0] = GetBaseDrive();

	bufptr     = 0L;
	BufferSize = 0L;
	
        error = Fsfirst( epath, 0 );	/* Normal file search for 1st file */
        if( error == 0 )  		   
        {   /* found it! */
            bufptr = calloc( 1, newdma.d_length * 2L );
	    if( bufptr )
	    {
	        BufferSize = newdma.d_length;
		
		if( (sys_file = Fopen( epath, 0 )) < 0)
		{
	   	   Fsetdta( olddma );		/* Point to OLD buffer */
	   	   if( bufptr )
	   	   {
	   	       free( bufptr );
	   	       bufptr = 0L;
	   	   }
                   form_alert( 1, alert1 );
	           return;
	        }

		path_found = FALSE;
		do
		{
	  	   i = 0;
	  	   alen = (int)Fread( sys_file, BufferSize, bufptr );
	  	   do
	  	   {
	    		if( !strncmp( &bufptr[i], "path", 4) ||
		            !strncmp( &bufptr[i], "PATH", 4) )
	    		{
			    strcpy( epath, extract_path( &i, alen ) );
			    path_found = TRUE;
			    goto done;
	   		}
  	    		else
  	    		{
			    while(( bufptr[i] != '\n' ) && ( i < alen )) { ++i; }	/* Skip to newline */
			    ++i;
	    		}
	  	   }while( i < alen );
		}while( alen == BufferSize );
done:	
		Fclose( sys_file );
		
		if( bufptr )
		{
		   free( bufptr );
		   bufptr = 0L;
		}
		j = strlen( epath );
		if( epath[ j - 1 ] == '\\' )
		    epath[ j - 1 ] = '\0';
	    }
	    else
             form_alert( 1, alert1 );
	}
	Fsetdta( olddma );		/* Point to OLD buffer */
	
	fname = &epath[0];
	fname = strupr( fname );
}


/* Read_Data()
 * ================================================================
 */
BOOLEAN
Read_Data( void )
{
   DTA  thedta, *saved;
   int  fd;
   int  *DataPtr;
   long EndIndex;
   BOOLEAN flag;
         
   flag = FALSE;      
   saved = Fgetdta();
   Fsetdta( &thedta );
   if( Fsfirst( FPath, 0 ) <= -1 ) /* Can't find the file... */
   {				   
     Objc_draw( tree, ROOT, MAX_DEPTH, NULL );
     form_alert( 1, alert2 );
   }
   else
   {
     DataBuf = calloc( 1, thedta.d_length * 2L );

     if( DataBuf )
     {
       fd = Fopen( FPath, 0 );	
       if( fd <= 0 )
       {
         form_alert( 1, alert1 );
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
           hdr = &hdr_buffer;
           strcpy( title, hdr->fname );
           flag = TRUE;
         }
         else
         {
           Objc_draw( tree, ROOT, MAX_DEPTH, NULL );
           form_alert( 1, alert3 );  
         }  
         free( DataBuf );
       }  
     }
     else
       form_alert( 1, alert4 );  
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
 */
BOOLEAN
Save_Data( void )
{
   DTA  thedta, *saved;
   int  fd;
   int  *DataPtr;
   long EndIndex;
   BOOLEAN flag;
         
   flag = FALSE;      
   saved = Fgetdta();
   Fsetdta( &thedta );
   if( Fsfirst( FPath, 0 ) <= -1 ) /* Can't find the file... */
   {				   
     Objc_draw( tree, ROOT, MAX_DEPTH, NULL );
     form_alert( 1, alert2 );
   }
   else
   {
     DataBuf = calloc( 1, thedta.d_length * 2L );

     if( DataBuf )
     {
       fd = Fopen( FPath, 0 );	
       if( fd <= 0 )
       {
         form_alert( 1, alert1 );
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

    	   hdr_buffer.quality    = Menu[ MQUALITY ].curvalue;
           hdr_buffer.nplanes    = Menu[ MCOLOR ].curvalue + 1;
    	   hdr_buffer.PageSize   = Menu[ MPAGESIZE ].curvalue;
           hdr_buffer.xres       = xres_value;
           hdr_buffer.yres       = yres_value;
           hdr_buffer.port       = Menu[ MPORT ].curvalue;
           hdr_buffer.paper_feed = Menu[ MTRAY ].curvalue;
           
           *hdr = hdr_buffer;

           flag = TRUE;
           fd = Fcreate( FPath, 0 );
           Fwrite( fd, thedta.d_length, DataHdr );
           Fclose( fd );
         }
         else
         {
           Objc_draw( tree, ROOT, MAX_DEPTH, NULL );
           form_alert( 1, alert3 );  
         }  
         free( DataBuf );
       }  
     }
     else
       form_alert( 1, alert4 );  
   }
   Fsetdta( saved );    
   return( flag );
}



/* GetCDrivers()
 * ====================================================================
 * Go thru the list of .sys files and try to load them.
 * Those that we can load, get the header and see if they are of the
 * new driver type. Get the filenames of those that are printer drivers
 * and store them in cdriver. Store their index into the driver array
 * into our cdriver array position.
 */
void
GetCDrivers( void )
{
   DTA  thedta, *saved;
   int  fd;
   int  *DataPtr;
   long EndIndex;
   int  error;
               
   saved = Fgetdta();
   Fsetdta( &thedta );
   
   cdriver_count =  0;
   
   get_bitpath();       
   strcpy( FPath, epath );
   strcat( FPath, "\\*.SYS");

   error = Fsfirst( FPath, 0 );	/* Normal file search for 1st file */
   if( error != E_OK )  	/* No such files! */
   {
     return;
   }

   do
   {
       sprintf( line_buf, "%s\\%s", epath, thedta.d_fname );
       DataBuf = calloc( 1, thedta.d_length * 2L );
       
       if( DataBuf )
       {
           fd = Fopen( line_buf, 0 );	
           if( fd > 0 )
           {
              Buffer = ( long )DataBuf;
              Buffer = ( Buffer + 15L ) & 0xFFFFFFF0L;
              DataHdr = ( int *)Buffer;
         
              Fread( fd, thedta.d_length, DataHdr );
              Fclose( fd );
              EndIndex = thedta.d_length;
              DataPtr  = FindString( DataHdr, DataHdr + EndIndex - 8 );
              if( DataPtr )	/* Look only for new drivers with headers*/
              {
                hdr = ( HEADER *)DataPtr;
                hdr_buffer = ( HEADER )*hdr;
                hdr = &hdr_buffer;

	        /* want only those drivers with real page sizes */
	        if( hdr->config_map & 0x3E )
	        {
	          /* then get the name...*/
	          strcpy( cdrivers[ cdriver_count ], hdr->fname );
	          strcpy( drivers[ cdriver_count ], thedta.d_fname );
	          cdriver_count++;
                }
              }
           }  
           free( DataBuf );
       }
       else
       {
           /* memory error - break out of loop and exit routine */
           form_alert( 1, alert4 );  
           break;
       }  
   } while ( ( Fsnext() == E_OK ) && ( cdriver_count < MAX_DRIVERS ) );
   SortCDriverNames();
   Fsetdta( saved );    
}




/* SortCDriverNames()
 * ====================================================================
 * Sort the Front End Driver Names - CDrivers[] into alphabetical order.
 */
void
SortCDriverNames( void )
{
    char  temp[30];	
    char* item1;
    char* item2;
    int   index;
            
    index = 0;
  
    /* only sort if there is more than one item */
    if( cdriver_count > 1 )
    {
	do
	{
	   if( ( index + 1) < cdriver_count )
	   {
               item1 = &cdrivers[ index ][0];
 	       item2 = &cdrivers[ index + 1 ][0];
	       if( strcmp( item1, item2 ) > 0 )
	       {
	          /* printer name */
		  strcpy( &temp[0], item2 );
		  strcpy( item2, item1 );
		  strcpy( item1, &temp[0] );

                  /* printer filename */
		  strcpy( &temp[0], &drivers[ index + 1 ][0] );
		  strcpy( &drivers[ index + 1 ][0], &drivers[ index ][0] );
		  strcpy( &drivers[ index ][0], &temp[0] );
		  		  
		  index = 0;
	       }
	       else
	         index++;
	   }
	   else
	     index++;	   
	}while( ( ( index + 1 ) < cdriver_count ) && ( index < MAX_DRIVERS ) );
    }
}
