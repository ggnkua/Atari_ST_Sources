/* FILE.C
 * ================================================================
 * DATE: April 15, 1992
 */
#include <alt\gemskel.h>
#include <string.h>
#include <stdio.h>
#include <dos.h>
#include <ctype.h>
#include <osbind.h>
#include <stdlib.h>

#include "country.h"
#include "text.h"
#include "setup.h"
#include "gemskel.h"
#include "handlers.h"
#include "drivers.h"
#include "mainstuf.h"
#include "tables.h"

/* DEFINES
 * ================================================================
 */
#define MAX_DISKS 10
#define READ_ERROR   0
#define WRITE_ERROR  1
#define MEM_ERROR    2
#define OPEN_ERROR   3
#define NOT_FOUND_ERROR 4


/* PROTOTYPES
 * ================================================================
 */
BOOLEAN	  Read_DAT_File( void );
BOOLEAN	  init_drive( void );
void	  CheckOS( void );
long	  GetOS( void );

void	  GetInitialPath( void );
int	  do_mkdir( char *name, int rflag );

void	  bgetstr( char *buffer, char *str );
void	  GetNumberOfDisks( void );
char	  *GetStringData( char *text );

void	  GetPrinterNames( void );
int	  Check_CPX( void );
BOOLEAN	  Get_CurDisk_Num( char DriveNum, char *DiskNum );
void	  GetFiles( char *path );
int	  bgetstring( char *buffer, int index, char *str );
int	  bputstr( char *buffer, int index, char *str );
int	  bputcr( char *buffer, int index );

int	  check_sysfile( char *filename, char *Path );
void 	  Copy_File( char *Source, char *Destination );

long	  GetRam( void );
int	  CheckError( int alert );
void	  CheckDir( char *path );

void	  Rename( char *old, char *new );
void	  ModifyExtend( char *Source, char *Destination );
void	  ModifyAssign( char *Source, char *Destination );

/* GLOBALS
 * ================================================================
 */
struct FILEINFO  *olddma, newdma;	/* DTA buffers for _our_ searches  */
char *data_buffer = NULL;		/* INSTALL.DAT buffer pointer      */
long datasize;				/* INSTALL.DAT buffer size         */

char *dataptr;				/* INSTALL.DAT pointer             */
char *oldptr;				/* INSTALL.DAT old pointer         */


/* Partition Drive Submenu info */
int  CurDrive    = 0;			/* Current Partition          */
int  DriveCount  = 0;			/* Number of Partitions	      */
int  DriveArray[ 14 ];			/* Array for active Partitions*/
char DriveNum;				/* Source disks A or B        */

unsigned int  Tos_Version;		/* TOS Version */

char TempString[ 128 ];		/* Temp String for all to use    */
char ScratchString[128];

char InitPath[ 128 ];

char DataString[ 128 ];		/* Parsing a line of data 	 */
char DataPath[ 128 ];		/* Source Path while copying     */

char CPX_Path[128];		/* Path for CPXs 		 */
char DPath[128];		/* Destination Path while copying*/
char AssignPath[128];		/* Path for the Assign.sys files */
char ExtendPath[128];		/* Path for the Extend.sys files */

int  RamFlag;			/* TRUE - 4megs or more memory   */
 				/* FALSE - < 4megs in system     */

/* FUNCTIONS
 * ================================================================
 */

/* Read_DAT_File()
 * ================================================================
 * Load the INSTALL.DAT file from the disk. Without it, we can't
 * do the install.
 * RETURN TRUE - for success
 *        FALSE - for failure.
 */
BOOLEAN
Read_DAT_File( void )
{
   int fhandle;
   
   olddma = Fgetdta();	
   Fsetdta( &newdma );	            /* Point to OUR buffer */
 
   /* locate the INSTALL.DAT file first...*/
   if( Fsfirst( "INSTALL.DAT", 0 ) < 0 )
   {
	/* Failed, can't find INSTALL.DAT */
        form_alert( 1, alert1 );
        Fsetdta(olddma);	       /* Point to OLD buffer */
	return( FALSE );
   }

   if( ( data_buffer = Malloc( newdma.size * 2L )) != NULL )
   {
	dataptr  = data_buffer;
	fhandle  = (int)Fopen( "INSTALL.DAT", 0 );
	datasize = Fread( fhandle, newdma.size, data_buffer );
	Fclose( fhandle );
   }
   else
   {    /* Failed Malloc */
	form_alert( 1, alert2 );
        Fsetdta( olddma );		       /* Point to OLD buffer */
        return( FALSE );
   }
   Fsetdta( olddma );		       /* Point to OLD buffer */
   return( TRUE );
}



/* init_drive()
 * ================================================================
 * If there is no hard disk, the Install program will abort.
 */
BOOLEAN
init_drive( void )
{
     int     drv;
     long    drivemap;
     long    drvmsk  = 1;
     BOOLEAN flag = FALSE;
     int     xobject;

     CurDrive   = 0;     
     DriveCount = 0;
     
     drivemap = Drvmap();
     for(drv = 0; drv < 16; drv++)	/* Initialize dialog box partitions */
     {
	if( drv > 1 )			/* skip drive A and B...	    */
        {
          xobject = drv - 2;
          DriveArray[ xobject ] = 0;
          if(drvmsk & drivemap)
          {
            DriveCount++;
            DriveArray[ xobject ] = 1;
	    if(!flag)
	    {
		flag = TRUE;
		CurDrive = xobject;
	    }	 
          }
        }
        drvmsk <<= 1;
    }
    return( flag );
}



/* CheckOS()    
 * ================================================================
 * Checks the OS for version 3.01 of TOS which will have problems
 * with Bezier functions.
 */
void
CheckOS( void )
{
    Supexec( GetOS );
    if( Tos_Version == 0x301 )
      form_alert( 1, tosalert );
}



/* GetOS()
 * ================================================================
 * A Supexec routine to get the current version of the OS.
 */
long
GetOS( void )
{
   OSHEADER *osheader;
   
   osheader = *((OSHEADER **)0x4f2L );
   
   osheader = osheader->os_beg;
   Tos_Version  = osheader->os_version;
   return( 0L );
}




/* GetInitialPath()
 * ================================================================
 * Gets the Initial path from where install.prg was run from.
 */
void
GetInitialPath( void )
{
   Dgetpath( TempString, Dgetdrv() + 1 );
   strcpy( InitPath, "X:" );
   DriveNum = InitPath[0] = Dgetdrv() + 'A';

   if( TempString[0] == '\0' )
     strcat( InitPath, "\\" );
   else
     strcat( InitPath, TempString );

   if( ( DriveNum != 'A' ) && ( DriveNum != 'B' ) )
      DriveNum = 'A';

}


/* do_mkdir()
 * ================================================================
 * Recursively makes a directory
 * RETURN: negative number upon failure.
 */
int
do_mkdir( char *name, int rflag )
{
    long err;
    char hold;
    char *p1, *p2;

    err = Dcreate(name);
    if( err < 0L )
    {
	/* error, but rflag: try recursively to create parent(s) */
	p1 = strrchr(name,'\\');
	p2 = strrchr(name,'/');
	if (p2 > p1) p1 = p2;   /* p1 = max(p1,p2) */
	if(!p1 )
        {
	    /* no parent(s) to create */
	    return( 1 );
	}
	else
	{
	    /* create parent(s), then try again */
	    hold = *p1;
	    *p1 = '\0';
	    if (do_mkdir(name,1)) return 1;
	    *p1 = hold;
	    err = Dcreate(name);
	}
    }
    return( (int)err );
}



/* bgetstr()
 * ================================================================
 * Get a string from the buffer bypassing carriage returns
 *
 */
void
bgetstr( char *buffer, char *str )
{
   char *ptr;
   char *cptr;

   ptr = strstr( buffer, "\r\n" );	/* CRLF           */

   /* copy the string */
   cptr = buffer;
   while( cptr != ptr )
      *str++ = *cptr++;
   *str = '\0';
}



/* GetNumberOfDisks()
 * ================================================================
 */
void
GetNumberOfDisks( void )
{
     char *bufptr;
     char *cptr;
     int  count;

     count = 0;
     bufptr = strstr( data_buffer, "[DISKS]" );

     /* Gets us to the next line */
     bgetstr( bufptr, TempString );
     bufptr += ( (char)strlen( TempString) + 2 );

     /* Get the first disk */
     bgetstr( bufptr, TempString ); 
     while( TempString[0] != '[' )
     {
	/* Skip comments */
        if( TempString[0] != ';' )
	{
	   if( (cptr = GetStringData( TempString )) != NULL )
	   {
	      strcpy( gl_disk_string[ count ], cptr );
	      count++;
	   } 
	}
     	bufptr += ( strlen( TempString ) + 2 );
        bgetstr( bufptr, TempString ); 
     }
     gl_numdisks = count;
}



/* GetString()
 * ================================================================
 */
char
*GetStringData( char *text )
{
   char *ptr;
   char *eptr;
   char *xptr;

   /* Initialize the pointer */
   ptr = text;

   /* Get to the first digit or alphanumeric character */
   while( *ptr && !isdigit( *ptr ) && !isalpha( *ptr ) && ( *ptr != '*' ) )
	ptr++;
          
   /* Get to the end */
   eptr = ptr;     
   while( *eptr && ( *eptr != '@' ) )
	eptr++;

   /* If a blank line, return NULL */
   if( ptr == eptr )
     return( NULL );

   /* Copy to our temp buffer the text */
   xptr = DataString;
   while( ptr != eptr )
	*xptr++ = *ptr++;
   *xptr = '\0';

   /* Return the temp buffer */
   return( DataString );
}



/* GetPrinterNames()
 * ================================================================
 */
void
GetPrinterNames( void )
{
     char *bufptr;
     char *cptr;
     int  count;

     count = 0;
     bufptr = strstr( data_buffer, "[PRINTERS]" );

     /* Gets us to the next line */
     bgetstr( bufptr, TempString );
     bufptr += ( (char)strlen( TempString) + 2 );

     /* Get the first printer line */
     bgetstr( bufptr, TempString ); 
     while( TempString[0] != '[' )
     {
	/* Skip comments */
        if( TempString[0] != ';' )
	{
	   if( (cptr = GetStringData( TempString )) != NULL )
	   {
	      FillPNode( cptr, count );
	      count++;
	   } 
	}
     	bufptr += ( strlen( TempString ) + 2 );
        bgetstr( bufptr, TempString ); 
     }
     gl_num_printers = count;

}


/* Check_CPX()
 * ================================================================
 * Check for the presence of 'CONTROL.INF' which signifies that
 * XCONTROL is installed. Get the path from CONTROL.INF and use
 * this for the CPX.
 * XControl_Present =   0 - AOK
 *			1 - Not Present
 *			2 - Invalid Path
 */
int
Check_CPX( void )
{
   int  fd;
   long i;
   char *buff;
   char *str;
   int  XControl_Present;
   int  index;
         
   olddma = Fgetdta();
   Fsetdta( &newdma );
   
   XControl_Present = 0;
      
   if( Fsfirst( "C:\\CONTROL.INF", 0 ) <= -1 )
   {				/* Can't find file    */	
      strcpy( CPX_Path, "C:" );
      XControl_Present = 1;	/* Not Present 	      */
   }
   else
   {
        buff = Malloc( newdma.size * 2L );
        if( buff )
        {
           fd = (int)Fopen( "C:\\CONTROL.INF", 0 );
           Fread( fd, newdma.size, buff );
           Fclose( fd );
           
	   index = 0;
	   str = &TempString[0];
	   while( buff[ index ] != 0x0D )
		*str++ = buff[ index++ ];
	   *str = '\0';

   	   Mfree( buff );
           XControl_Present = 0;  
        }
        else
        {
	   form_alert( 1, alert2 );
           Fsetdta( olddma );		       /* Point to OLD buffer */
	   Gem_Exit( 0 );      
        }
        
        /* Get rid of Wild Card...*/
        for( i = strlen( TempString ); i && TempString[i] != '\\'; TempString[i--] = '\0');
        TempString[i] = '\0';		/* Get rid of '\\' also...*/
        strcpy( CPX_Path, TempString );
        
        Dsetdrv( CPX_Path[0] - 'A' );
        if( Dsetpath( CPX_Path ) )
        {
             strcpy( CPX_Path, "C:" );
             XControl_Present = 2;	/* if path is invalid, set to NO CPX */
        }     
   }
   Fsetdta( olddma );
   return( XControl_Present );
}



/* Get_CurDisk_Num()
 * ================================================================
 * Get the Current Disk Number. Which is FSM.001, FSM.002 etc.
 * RETURN: TRUE - if disk is in Drive.
 *         FALSE - if disk is NOT in Drive.
 */
BOOLEAN
Get_CurDisk_Num( char DriveNum, char *DiskNum )
{
   char    filename[ 15 ];
   BOOLEAN flag = FALSE;
   
   olddma = Fgetdta();	
   Fsetdta( &newdma );	            /* Point to OUR buffer */
 
   _mediach( DriveNum - 'A');	/* Hit drive 'A or B' for media change */
   sprintf( filename, "%c:\\%s", DriveNum, DiskNum );
   if( Fsfirst( filename, 0 ) == E_OK )
      flag = TRUE;
   else
      flag = FALSE;

   Fsetdta( olddma );
   return( flag );
}


/* GetFiles()
 * ================================================================
 */
void
GetFiles( char *path )
{
   struct FILEINFO *oldinfo;
   struct FILEINFO info;
   char   *cptr;
   int    i;
   
   oldinfo = Fgetdta();	
   Fsetdta( &info );	            /* Point to OUR buffer */
   
   strcat( path, "\\*.*" );
       
   if( !Fsfirst( path, FA_SUBDIR ))
   {
     if( ( cptr = strstr( path, "*.*" )) != NULL )
	*cptr = '\0';

     do
     {
	if( info.attr == FA_SUBDIR )
	{
	   if( strcmp( info.name, "." ) && strcmp( info.name,".." ) )
           {
	     strcat( path, info.name );
	     GetFiles( path );
	   }
	}
	else
	{
	   strcpy( TempString, path );
	   strcat( TempString, info.name );
	   ProcessFile( TempString );
	}

        if( Bconstat(2) )
	    {
			Bconin(2);
			CheckExit();
		}
     }while( !Fsnext() );

     /* Clean up after ourselves, avoiding the ROOT! */
     i = (int)strlen( path );
     path[i-1] = '\0';
     if( i > 3 )
     {
       for( i = (int)strlen( path ); path[i] != '\\'; i-- )
	path[i] = '\0';
     }
   }
   Fsetdta( oldinfo );
}



/* check_sysfile()
 * ================================================================
 * Checks for the C:\ASSIGN.SYS or C:\EXTEND.SYS
 *        Flag -   0 - No error
 *		   1 - No file
 *		   2 - no path in file.sys
 *		   3 - invalid drive in path in file.sys
 *		   4 - invalid path in file.sys
 */
int
check_sysfile( char *filename, char *Path )
{
   int     fd;
   char    *ptr, *endptr;
   int     drv;
   BOOLEAN done;
   int     flag;
   char    *buff;
   int     index;

   olddma = Fgetdta();
   Fsetdta( &newdma );

   Path[0] = '\0';	/* NULL the path initially */
   flag =  0;
   if( Fsfirst( filename, 0 ) <= -1 )
      flag = 1;				/* Return - Can't find filename*/
   else
   {
        if( ( buff = (char *)Malloc( newdma.size * 2L )) != NULL )
        {
           fd = (int)Fopen( filename, 0 );
           Fread( fd, newdma.size, buff );
           Fclose( fd );
           buff[ newdma.size ] = '\0';


	   /* Parse to get the directory path */
	   index = 0;
	   done = FALSE;
	   do
	   { 
 	     index = bgetstring( buff, index, TempString );

 	     if( !TempString[0] )	/* no more to parse */
 	         done = TRUE;
	     else
	     {
 	       if(   ( TempString[0] != ';' ) &&
		     ( strstr( TempString, "PATH =" ) ||
		       strstr( TempString, "path =" ))
	         )
	         done = TRUE;
	     }
 	   }while( !done );
 	   
	   ptr = (( TempString[0] ) ? ( strchr( TempString,'=')):(&TempString[0]));
 	   if( *ptr )
 	   {
	     /* Find the beginning of the path */
 	     while( isspace( *ptr ) || ( *ptr == '=' ))	/* Get rid of spaces and equal*/
 	          ptr++;
 	     
	     /* Find the end of the path and NULL IT */     
 	     endptr = ptr;
	     while( !isspace( *endptr++ ) );
	     *endptr = '\0';
	   
	     if( *( endptr-1 ) == '\\' )
	   	*(endptr-1) = '\0';
	   
	     strcpy( Path, ptr );
             flag = 0;  
	   }
	   else
	   {
	     /* NO '=', therefore, NO directory path. 
	      * We shall treat it as NO file.SYS
	      */
	     Path[0] = '\0';
	     flag = 2;
	   }
   	   Mfree( buff );
        }
        else
        {
	   form_alert( 1, alert2 );
           Fsetdta( olddma );		       /* Point to OLD buffer */
	   Gem_Exit( 0 );      
        }

	if( !flag )
	{
	  drv = Path[0] - 'A';
	  if( drv == 0 || drv == 1 || !DriveArray[ drv - 2 ] )
	  {
	      /* If the Drive is set to the A Drive or B Drive OR
	       * if the Drive is set to a non-existent partition...
	       * set to NO file.sys
	       */
              Path[0] = '\0';
              flag = 3;	/* if drive is invalid, set to NO file.SYS */
	  }
	  else
	  {
            Dsetdrv( drv );
            if( Dsetpath( Path ) )
            {
              Path[0] = '\0';
              flag = 4;	/* if path is invalid, set to NO file.SYS */
            }
          }  
        }       

   }
   Fsetdta( olddma );
   return( flag );
}



/* bputstr()
 * ================================================================
 * Put a string INTO the buffer
 */
int
bputstr( char *buffer, int index, char *str )
{
   while( *str )
	buffer[ index++ ] = *str++;       
   return( index );
}


/* bputcr()
 * ================================================================
 * Put a carriage return into the buffer
 */
int
bputcr( char *buffer, int index )
{
   buffer[ index++ ] = 0x0D;
   buffer[ index++ ] = 0x0A;
   buffer[ index ] = '\0';
   return( index );
}


/* bgetstring()
 * ================================================================
 * Get a string from the default buffer bypassing carriage returns
 *
 */
int
bgetstring( char *buffer, int index, char *str )
{
   /* SHOULD NULL the STRING IF WE REACH THE END OF THE BUFFER */
   while(( buffer[ index ] != 0x0D ) && buffer[index] )
   	*str++ = buffer[ index++ ];
   	
   if( buffer[ index ] )	
      index++;				/* bypass 0x0d */
      
   if( buffer[ index ] )   
      index++;				/* bypass 0x0a */
      
   *str++ = '\0';
   return( index );
}



/* Copy_File( Source, Destination )
 * ================================================================
 * Copy the source file to the Destination.
 * The source and destination strings contain complete paths.
 */
void 
Copy_File( char *Source, char *Destination )
{
      char *fbuffer;
      int  fhandle;
      long fsize;
      long out;
      struct FILEINFO *oldinfo;
      struct FILEINFO info;
      int    value;
	            
      oldinfo = Fgetdta();	
      Fsetdta( &info );            /* Point to OUR buffer */

redo_find:
      if( Fsfirst( Source, 0 ) != E_OK )
      {
         /* FILE NOT FOUND */  
	 value = CheckError( NOT_FOUND_ERROR );
	 if( value == 1 )
	   goto redo_find;

         Fsetdta( oldinfo );	/* Skip */

	 if( value == 3 )	/* Quit */
	    Gem_Exit( -1 );

         return;	
      }      
      fsize = info.size;

redo_mem:            
      /* Get a buffer to read in the file with */
      fbuffer = Malloc( fsize * 2L );
            
      /* If not enough memory, error...*/
      if( !fbuffer )
      {
	  value = CheckError( MEM_ERROR );
	  if( value == 1 )	/* RETRY */
	    goto redo_mem;

          Fsetdta( oldinfo );	/* SKIP */

	  if( value == 3 )	/* QUIT */
	    Gem_Exit( -1 );
	  return;
      }	  

      /* Read in the source file...*/
redo_read:
      fhandle = (int)Fopen( Source, 0 );

      if( fhandle < 0 ) 
      {
	value = CheckError( OPEN_ERROR );
	if( value == 1 )	/* RETRY */
	   goto redo_read;

        if( fbuffer )
            Mfree( fbuffer );
        Fsetdta( oldinfo );
	if( value == 3 )		/* QUIT */
	     Gem_Exit(-1);		

	/* Skip! */
	return;
      }

      out = Fread( fhandle, fsize, fbuffer );
      if( out < 0 )
      {
	value = CheckError( READ_ERROR );
	if( value == 1 )
	{
	    Fclose( fhandle );
	    goto redo_read;	/* RETRY */
	}

	if( fbuffer )		/* SKIP */
	   Mfree( fbuffer );
        Fsetdta( oldinfo );
	if( value == 3 )
	    Gem_Exit( -1 );
	return;
      }	
      Fclose(fhandle);


      /* Write out file to destination */
redo_create:

      fhandle = (int)Fcreate( Destination, 0 );
      if( fhandle > 0 )
      {
      	 out = Fwrite( fhandle, fsize, fbuffer );
      	 Fclose( fhandle );
      	 
      	 if( out != fsize )	/* Write Error, delete file */
	 {
	    value = CheckError( WRITE_ERROR );
	    if( value == 1 )	/* Retry */
	      goto redo_create;	

	    if( value == 3 )	/* QUIT */
	    {
	       if( fbuffer )
		 Mfree( fbuffer );
	       Fsetdta( oldinfo );
	       Gem_Exit(-1);		
	    }

	    /* SKIP */
      	 }
      }
      else
      {
	  value = CheckError( WRITE_ERROR );
	  if( value == 1 )	/* Retry */
	    goto redo_create;
	
	  if( value == 3 )		/* QUIT */
	  {
	     if( fbuffer )
	       Mfree( fbuffer );
	     Fsetdta( oldinfo );
	     Gem_Exit(-1);		
	  }

          /* skip! */	  

      }
      if( fbuffer )
   	   Mfree(fbuffer);
		
      Fsetdta( oldinfo );
      return;		/* everything went smoothly...*/
}




/* GetRam()
 * ================================================================
 */
long
GetRam( void )
{
    long RamValue;
    
    RamValue = *(long *)0x42eL;
    RamFlag  = ( RamValue >= 4000000L );
    return( RamValue );
}



/* CheckError()
 * ================================================================
 */
int
CheckError( int alert )
{
    int value;

    switch( alert )
    {
	case 0: /* Read Error */
		value = form_alert( 1, read_error );
		
		break;

	case 1: /* Write Error */
		value = form_alert( 1, write_error );
		break;

	case 2: /* memory malloc Error */
		value = form_alert( 1, mem_error );
		break;

	case 3: /* open file error */
		value = form_alert( 1, open_error );
		break;

	case 4: /* File NOt found error */
		value = form_alert( 1, no_file_error );
		break;
    }

    /* return values 1 and 2 where 
     * 1 - RETRY
     * 2 - SKIP!
     * 3 - QUIT 
     */
    return( value );
}



/* CheckDir()
 * ================================================================
 * Check if the path is valid, and then make the directories if it isn't
 */
void
CheckDir( char *path )
{
  Dsetdrv( path[0] - 'A' );
  if( Dsetpath( path ) )
  {
    do_mkdir( path, 0 );   	/* needs error checking?*/
  }
}



/* Rename()
 * ================================================================
 * Rename old file to new file with name conflict checking...
 * This is used ONLY for EXTEND.SYS and ASSIGN.SYS to be
 * renamed to ASSIGN.OLD and EXTEND.OLD
 */
void
Rename( char *old, char *new )
{
   struct FILEINFO *oldinfo;
   struct FILEINFO newinfo;
         
   oldinfo = Fgetdta();
   Fsetdta( &newinfo );

   /* Look for the new filename first.
    * If found, delete it. Then rename the old to the new.
    */
   if( !Fsfirst( new, 0 ) )
      Fdelete( new );

   Frename( 0, old, new );

   Fsetdta( oldinfo );
}



/* ModifyExtend()
 * ================================================================
 */
void
ModifyExtend( char *Source, char *Destination )
{
   int    fd;
   long   fsize;
   long   time;
   long   out;
   struct FILEINFO *oldinfo;
   struct FILEINFO newinfo;
   int    value;
   char   *buff;
   int    index;
   char   *obuff;
   int    oindex;
           
   oldinfo = Fgetdta();
   Fsetdta( &newinfo );

   /* We shall be saving to EXTEND.SYS, so check if it already
    * exists. Then rename it, if necessary to EXTEND.OLD.
    */
   if( !gl_extend )
   {
     if( !Fsfirst( "C:\\EXTEND.SYS", 0 ))
         Rename( "C:\\EXTEND.SYS", "C:\\EXTEND.OLD" );
   }


   /* Look for the Source FileName */
redo_find:
   if( Fsfirst( Source, 0 ))
   {
      value = CheckError( NOT_FOUND_ERROR );
      if( value == 1 )
	goto redo_find;
      	
      Fsetdta( oldinfo );	/* skip */

      if( value == 3 )		/* QuiT */
	Gem_Exit( -1 );
      return;
   }
   else
   {
redo_mem:
	/* Get our new buffers */
        buff = obuff = 0L;     

        buff = (char *)calloc( 1L, newinfo.size * 2L );  /* Source */
	obuff = (char *)calloc( 1L, newinfo.size * 2L );  /* destination*/
        if( buff && obuff )	
        {
	   /* Read in the source file...*/
redo_read:
           fd = (int)Fopen( Source, 0 );
	   if( fd < 0 )
	   {
		value = CheckError( OPEN_ERROR );
	        if( value == 1 )	/* RETRY */
	   	    goto redo_read;

                free( buff );
                free( obuff );
	        buff = obuff = 0L;     
	        Fsetdta( oldinfo );	/* skip */
	        if( value == 3 )		/* QUIT */
	          Gem_Exit(-1);		
	        return;				/* SKIP */
           }

           out = Fread( fd, newinfo.size, buff );
	   if( out < 0 )
	   {
		value = CheckError( READ_ERROR );
		if( value == 1 )
		{
		   Fclose( fd );
		   goto redo_read;	/* RETRY */
		}
		
                free( buff );
                free( obuff );
	        buff = obuff = 0L;     
	        Fsetdta( oldinfo );	/* skip */
		if( value == 3 )	/* QUIT */
		  Gem_Exit( -1 );		
		return;			/* SKIP */	
	   }
           Fclose( fd );

	   index  = 0;		/* Clear index into source      */
	   oindex = 0;		/* Clear index into destination */
	   do
	   { 
             index = bgetstring( buff, index, ScratchString );

	     /* Write out the last modified date and time.*/
             if( strstr( ScratchString, "; TIME" ) )
             {	     
		time = Gettime();
		sprintf( ScratchString,
		"; Last modified on %d/%d/%d %02d:%02d", 
		(int )((time  >> 21) & 0x0F),
		(int )((time  >> 16) & 0x1F),
		(int )(((time >> 25) & 0x7F) + 1980),
		(int )((time  >> 11) & 0x1F),
		(int )((time  >> 5)  & 0x3F) );
 	     }
 	     
 	     /* Add in our NEW path for the FSM GDOS fonts.
	      * If we are installing FONTGDOS, then we use
	      * the Assign.sys path inside the EXTEND.SYS file.
              */
	     if( strstr( ScratchString, "PATHX" ) )
	     {
		sprintf( ScratchString, "PATH = %s", ExtendPath );
		strupr( ScratchString );
	     }	

	     oindex = bputstr( obuff, oindex, ScratchString );
	     oindex = bputcr( obuff, oindex );
 	   }while( ScratchString[0] != '\0' );


	   /* Now, write out the destination file */
	   fsize = strlen( obuff );
redo_create:
      	   fd = (int)Fcreate( Destination, 0 );
      	   if( fd > 0 )
      	   {
      	      out = Fwrite( fd, fsize, obuff );
      	      Fclose( fd );
	      if( out != fsize )
	      {
		 value = CheckError( WRITE_ERROR );
		 if( value == 1 )	/* Retry */
		    goto redo_create;

                 free( buff );
                 free( obuff );
	         buff = obuff = 0L;     
	         Fsetdta( oldinfo );	/* skip */	 
		 if( value == 3 )	/* QUIT */
	           Gem_Exit( -1 );
		 return;		/* Skip */		
	      }
           }
           else
	   {	/* Create Error */
		value = CheckError( WRITE_ERROR );
		if( value == 1 )	/* Retry */
		   goto redo_create;

                free( buff );
                free( obuff );
	        buff = obuff = 0L;     
	        Fsetdta( oldinfo );	/* skip */	 
		if( value == 3 )	/* QUIT */
	           Gem_Exit( -1 );
		return;			/* Skip */		
           }
           free( buff );
           free( obuff );
	   buff = obuff = 0L;     
	}
	else
	{
	   /* Not Enough Memory */
	   if( buff )
	        free( buff );
	   if( obuff )
	        free( obuff );
	   buff = obuff = 0L;     

	   value = CheckError( MEM_ERROR );
	   if( value == 1 )   /* RETRY */
	     goto  redo_mem;

           Fsetdta( oldinfo );    /* skip */

	   if( value == 3 )	/* QUIT */
	       Gem_Exit( -1 );

	   return;      
	}   
   }
   Fsetdta( oldinfo );
}



 
/* ModifyAssign()
 * ================================================================
 */
void
ModifyAssign( char *Source, char *Destination )
{
   int    fd;
   long   fsize;
   int    i;
   long   time;
   long   out;
   struct FILEINFO *oldinfo;
   struct FILEINFO newinfo;
   char   *buff;
   int    index;
   char   *obuff;
   int    oindex;
   int    value;
   
   oldinfo = Fgetdta();
   Fsetdta( &newinfo );

   /* if not to be saved as Assign.new, look for 
    * assign.sys and rename it to assign.old
    */
   if( !gl_assign )
   {
     if( !Fsfirst( "C:\\ASSIGN.SYS", 0 ) )
         Rename( "C:\\ASSIGN.SYS", "C:\\ASSIGN.OLD" );
   }

redo_find:
   if( Fsfirst( Source, 0 ) )
   {					/* Can't find file    */	
      value = CheckError( NOT_FOUND_ERROR );
      if( value == 1 )
	goto redo_find;
      	
      Fsetdta( oldinfo );	/* skip */

      if( value == 3 )		/* QuiT */
	Gem_Exit( -1 );
      return;
   }
   else
   {
redo_mem:
        buff = obuff = 0L;     
        buff  = (char *)calloc( 1L, newinfo.size * 2L ); /* Source     */
	obuff = (char *)calloc( 1L, newinfo.size * 2L ); /* Destination*/

        if( buff && obuff )
        {
	   /* Read in the source file...*/
redo_read:
           fd = (int)Fopen( Source, 0 );
	   if( fd < 0 )
	   {
		value = CheckError( OPEN_ERROR );
	        if( value == 1 )	/* RETRY */
	   	    goto redo_read;

                free( buff );
                free( obuff );
	        buff = obuff = 0L;     
	        Fsetdta( oldinfo );	/* skip */
	        if( value == 3 )		/* QUIT */
	          Gem_Exit(-1);		
	        return;				/* SKIP */
           }
		
           out = Fread( fd, newinfo.size, buff );
	   if( out < 0 )
	   {
		value = CheckError( READ_ERROR );
		if( value == 1 )
		{
		   Fclose( fd );
		   goto redo_read;	/* RETRY */
		}
		
                free( buff );
                free( obuff );
	        buff = obuff = 0L;     
                Fsetdta( oldinfo );	/* skip */
		if( value == 3 )	/* QUIT */
		  Gem_Exit( -1 );		
		return;			/* SKIP */	
	   }

           Fclose( fd );
           
	   index  = 0;		/* Clear index into source      */
	   oindex = 0;		/* Clear index into destination */

	   time = Gettime();
	   sprintf( ScratchString,
	   "; Last modified on %d/%d/%d %02d:%02d", 
	   (int )((time  >> 21) & 0x0F),
	   (int )((time  >> 16) & 0x1F),
	   (int )(((time >> 25) & 0x7F) + 1980),
	   (int )((time  >> 11) & 0x1F),
	   (int )((time  >> 5)  & 0x3F) );
	   oindex = bputstr( obuff, oindex, ScratchString );
	   oindex = bputcr( obuff, oindex );

	   do
	   { 
 	     index = bgetstring( buff, index, ScratchString );	/* Get a line at a time.*/

	     if( strstr( ScratchString, "PATHX" ) )
		 sprintf( ScratchString, "PATH = %s", AssignPath );
	     strupr( ScratchString );
	   
	     if( ScratchString[0] != '\0' )
	     {
	       oindex = bputstr( obuff, oindex, ScratchString );
	       oindex = bputcr( obuff, oindex );
	     }  
 	   }while( ScratchString[0] != '\0' );

	   if( gl_printer )
	   {
	     /* Print out the 21 driver name */
             sprintf( ScratchString, "21 %s", MenuNode[ gl_printer ].fname );
	     oindex = bputstr( obuff, oindex, ScratchString );
	     oindex = bputcr( obuff, oindex );

	     /* Print out the 21 printer fonts names */
	     if( gl_slm )
	     {
		  for( i = 0; i < Titles[ 10 ].count; i++ )
		  {
	             sprintf( ScratchString, "%s", Titles[ 10 ].fnode[i].fname );
                     oindex = bputstr( obuff, oindex, ScratchString );
	             oindex = bputcr( obuff, oindex );
		  }		
             }
	  
             if( gl_nb15 )
	     {
		  for( i = 0; i < Titles[ 9 ].count; i++ )
		  {
	             sprintf( ScratchString, "%s", Titles[ 9 ].fnode[i].fname );
                     oindex = bputstr( obuff, oindex, ScratchString );
	             oindex = bputcr( obuff, oindex );
		  }		
	     }

	     if( gl_fx80 )
	     {
		  for( i = 0; i < Titles[ 11 ].count; i++ )
		  {
	             sprintf( ScratchString, "%s", Titles[ 11 ].fnode[i].fname );
                     oindex = bputstr( obuff, oindex, ScratchString );
	             oindex = bputcr( obuff, oindex );
		  }		
	     }
	   }

	   /* print out 31 META Driver */
	   if( gl_meta )
	   {
             sprintf( ScratchString, "31 META.SYS" );
	     oindex = bputstr( obuff, oindex, ScratchString );
	     oindex = bputcr( obuff, oindex );
	   }  

	   /* print out memory driver */
	   if( gl_mem )
	   {
             sprintf( ScratchString, "61 MEMORY.SYS" );
	     oindex = bputstr( obuff, oindex, ScratchString );
	     oindex = bputcr( obuff, oindex );
	   }  


	   /* Write out the ASSIGN.SYS or ASSIGN.NEW file */	   
	   fsize = strlen( obuff );

redo_create:
      	   fd = (int)Fcreate( Destination, 0 );
      	   if( fd > 0 )
      	   {
      	      out = Fwrite( fd, fsize, obuff );
      	      Fclose( fd );

	      /* If out != file size written, write error */
	      if( out != fsize )
	      {
		 value = CheckError( WRITE_ERROR );
		 if( value == 1 )	/* Retry */
		    goto redo_create;

                 free( buff );
                 free( obuff );
	         buff = obuff = 0L;     
	         Fsetdta( oldinfo );	/* skip */	 
		 if( value == 3 )	/* QUIT */
	           Gem_Exit( -1 );
		 return;		/* Skip */		
	      }
           }
           else
	   {
		/* Create Error */
		value = CheckError( WRITE_ERROR );
		if( value == 1 )	/* Retry */
		   goto redo_create;

                free( buff );
                free( obuff );
	        buff = obuff = 0L;     
		Fsetdta( oldinfo );	/* skip */	 
		if( value == 3 )	/* QUIT */
	           Gem_Exit( -1 );
		return;			/* Skip */		
	   }
           free( buff );
           free( obuff );
	   buff = obuff = 0L;     
	}
	else
	{
	   /* Not Enough Memory */
	   if( buff )
	        free( buff );
	   if( obuff )
	        free( obuff );
	   buff = obuff = 0L;     

	   value = CheckError( MEM_ERROR );
	   if( value == 1 )   /* RETRY */
	     goto  redo_mem;

           Fsetdta( oldinfo );    /* skip */

	   if( value == 3 )	/* QUIT */
	       Gem_Exit( -1 );

	   return;      
	}
   }
   Fsetdta( oldinfo );
}

