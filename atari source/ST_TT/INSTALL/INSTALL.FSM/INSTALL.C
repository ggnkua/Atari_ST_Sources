/* INSTALL.C
 * ================================================================
 * DATE: November 27, 1990
 * 
 * 01/15/92 cjg - yes 1992
 *		- Modified to install pageomat...
 * 01/29/92 cjg - modify again - the folders have changed names again
 *
 * DESCRIPTION: 
 */
#include <sys\gemskel.h>
#include <string.h>
#include <tos.h>
#include <vdikeys.h>

#include <stdio.h>
#include <stdlib.h>

#include "country.h"
#include "finstall.h"
#include "mainstuf.h"
#include "file.h"
#include "text.h"


/*
 * TURN OFF Turbo C "parameter X is never used" warnings
 */
#pragma warn -par


/* DEFINES
 * ================================================================
 */
#define DRIVER_MAX 	100


/* PROTOTYPES
 * ================================================================
 */
void	Do_Install( void );
void 	make_dir( void );
void	DoPageMessage( void );

BOOLEAN	Do_Transfer( void ); 
BOOLEAN	Insert_Disk( int num );
int	Action( char *Source, int dest_id );

void	Clear_Driver_List( void );
BOOLEAN	Add_Driver_To_List( char *fname );
long    GetRam( void );
 

/* GLOBALS
 * ================================================================
 */ 
char temp[ 128 ];		/* Temp string to build alerts with numbers etc..*/
char Source_Fname[ 128 ];	/* Source Filename read from A   */
char Dest_Fname[ 128 ];		/* Destination Filename		 */
char Driver_Path[ 128 ];	/* Driver Source Path - Probably A:\DRIVERS */
char xdirpath[ 128 ];

int  Num_Drivers;			/* Number of Drivers currently loaded*/
int  Cur_Driver;			/* Current Driver Selected */
BOOLEAN RamFlag;	/* TRUE - memory >= 4meg */


/* FUNCTIONS
 * ================================================================
 */


/* Do_Install()
 * ================================================================
 * Perform Installation of FSMGDOS
 *  1) create folders where necessary.
 *  2) Rename GDOS\G+Plus if flag says to do it.
 *  3) EXTEND.SYS? exists? yes\no...
 *  4) start copying files over.
 */
void
Do_Install( void )
{  
   Graf_Mouse( BUSYBEE );

   Supexec( GetRam );
        
   Check_Gdos();
   make_dir();     

   if( Do_Transfer())
      form_alert( 1, alert7 );
   else
      form_alert( 1, alert8 );
   Graf_Mouse( ARROW );
}




/* make_dir()
 * ================================================================
 * make the AUTO and FONT FOLDERs for FSM GDOS and Assign.sys
 * The ASSIGN.SYS folder is necessary ONLY if we need to
 * have it made.
 */
void
make_dir( void )
{
    BOOLEAN flag;

    /* Create the AUTO folder if necessary */
    strcpy( xdirpath, "C:\\AUTO" );
    flag = md( xdirpath );   
    if( flag )
    {
       ActiveTree( ad_dir );
       TedText( FOLDERS ) = xdirpath;
       Scan_Message( ad_dir, TRUE );
       Evnt_timer( 2000L );
       Scan_Message( ad_dir, FALSE );
    }
    
    /* Create the FSM GDOS font folder if necessary */
      flag = md( dirpath );
      if( flag )
      {    
        ActiveTree( ad_dir );
        TedText( FOLDERS ) = dirpath;
        Scan_Message( ad_dir, TRUE );
        Evnt_timer( 2000L );
        Scan_Message( ad_dir, FALSE );
      } /* Folder is not created IF we have a folder name of '.123' */
      
      
      /* Create the Assign.sys font folder if necessary */
      if( adirpath[0] )
      {
        flag = md( adirpath );
        if( flag )
        {
           ActiveTree( ad_dir );
           TedText( FOLDERS ) = adirpath;
           Scan_Message( ad_dir, TRUE );
           Evnt_timer( 2000L );
           Scan_Message( ad_dir, FALSE );
        }
      }  
      
      /* Create paths for Pageomat....*/
      if( PageOneFlag )
      {
        sprintf( PagePath, "%c:\\%s", CurPageTwo + 'C', "PAGEOMAT");
        flag = md( PagePath );
        if( flag )
        {
	  DoPageMessage();
	            
          sprintf( PagePath, "%c:\\PAGEOMAT\\%s", CurPageTwo + 'C', "SAMPLES" );
          flag = md( PagePath );
          if( flag )
              DoPageMessage();


          sprintf( PagePath, "%c:\\PAGEOMAT\\%s", CurPageTwo + 'C', "GEM" );
          flag = md( PagePath );
          if( flag )
          {
             DoPageMessage();

             sprintf( PagePath, "%c:\\PAGEOMAT\\GEM\\%s", CurPageTwo + 'C', "BANNERS" );
             flag = md( PagePath );
             if( flag )
                DoPageMessage();

	     sprintf( PagePath, "%c:\\PAGEOMAT\\GEM\\%s", CurPageTwo + 'C', "BORDERS" );
             flag = md( PagePath );
             if( flag )
               DoPageMessage();                                         
          }   
        }
      }
}
 

void
DoPageMessage( void )
{
   ActiveTree( ad_dir );
   TedText( FOLDERS ) = PagePath;
   Scan_Message( ad_dir, TRUE );
   Evnt_timer( 2000L );
   Scan_Message( ad_dir, FALSE );
}




/* Insert_Disk()
 * ================================================================
 * Checks the Disk Drive for the proper disk.
 * It allows the user to cancel installation if necessary.
 * RETURNS: TRUE - INSTALL
 *          FALSE- Cancel Installation.
 */
BOOLEAN
Insert_Disk( int num )
{
   while( !Get_CurDisk_Num( num ) )
   {
     sprintf( temp, alert9, num );
     if( form_alert( 1, temp ) == 2 )
        return( FALSE );
   }
   return( TRUE );  
}




/* Do_Transfer()
 * ================================================================
 */
BOOLEAN
Do_Transfer( void )
{
   int i;

   int ndisks;		/* Number of Total Disks to Install    */
   int Cur_Disk;	/* Current Disk that we are installing */
   int dest;		/* Number to identify wot action to take*/
   
   int status;
   
   ndisks = Get_Number_Of_Disks(); /* Get the number of Disks to Install*/

   for( i = 1; i <= ndisks; i++ )
   {
	Cur_Disk = i;
   	Graf_Mouse( ARROW );

	/* Check the disk drive for the right disk. Prompt
	 * the user if it is not the right disk.
	 */
	if( !Insert_Disk( i ) )
	{
	   oldptr = dataptr = data_buffer;  /* reset the buffer...     */
	   return( FALSE );
	}
	
	
	Graf_Mouse( BUSYBEE );
	/* Get the Disk ID, if it returns a Zero, then
	 * we have either reached the EOF, or we have
	 * went on to another disk.
	 */
	while( Get_ID( Cur_Disk ) )
	{
	    Get_Source_Fname( Source_Fname );
	    strupr( Source_Fname );
	    dest = Get_Destination();   /* Get destination   */
	    
	    /* Perform the Action */
	    status = Action( Source_Fname, dest );
	    if( status )
	    {
	       switch( status )
	       {
	    	 case 2: /* file not found */
	    	 	 sprintf( temp, alert10, Source_Fname );
	    	 	 form_alert( 1, temp );
	    		 break;
	    		
	    	 case 3: /*not enough memory */
	    		form_alert(1, alert2 );
	    		break;
	    	
	    	 case 4: /* Not enough disk space */
	    	 	 form_alert( 1, diskalert );
	    	 	 break;
	    	 	 
	    	 default:
	    		break;
	       }
	       
	       if( ( status == 3 ) || ( status == 4 ))
	           return( FALSE );			
	    	
	    }
	}
        dataptr = oldptr;		/* reset to before get_id */
   }
   return( TRUE );
}




/* Action()
 * ================================================================
 * Given the dest_id number, we take the Source filename and
 * do horrendous things to it...
 * Mainly, we see wot action is required with this file, based
 * upon the dest_id number.
 * RETURN: 0 - if everything went AOK
 *         # - error message.
 */
int
Action( char *Source, int dest_id )
{
   int    error;
   
   error = 0;
   switch( dest_id )
   {
/*   
;		    1 - ROOT DIRECTORY OF C:\ Partition
;		    2 - AUTO FOLDER OF C:\Partition
;		    3 - FSM GDOS FONTS DIRECTORY
;		    4 - CPX DIRECTORY
;		    5 - ASSIGN.SYS DIRECTORY - DEFAULTS to FSM GDOS DIR
;		    6 - Extend.sys file
;		    7 - Assign.sys file
;		    8 - ASSIGN.SYS Directory - PRINTER FONTS
;		    9 - DISK IDENTIFICATION
;		   10 - ASSIGN.SYS drivers.
;		   11 - FSM GDOS WID DIRECTORY
;		   12 - META.SYS and MEMORY.SYS
;		   13 - ROOT DIRECTORY OF C:\ ( PAGEOMAT )
;		   14 - PAGEOMAT DIRECTORY
;		   15 - PAGEOMAT\SAMPLES DIRECTORY
;		   16 - PAGEOMAT\GEM DIRECTORY
;		   17 - PAGEOMAT\GEM\BANNERS DIRECTORY
;		   18 - PAGEOMAT\GEM\BORDERS DIRECTORY
*/
   
      case 1:  /* ROOT DIRECTORY of C:\ Partition - ACC probably only. */
      	       if(( CurCPX == 2 ) || ( CurCPX == 3 ) )
      	       {
	         Build_Destination_Path( Source_Fname, "C:", Dest_Fname );
	         error = Copy_File( Source_Fname, Dest_Fname );
	       }  
      	       break;
      	       
      case 2:  /* AUTO FOLDER of C:\ partition */
      	       if( ( InstallFlag && !strstr( Source_Fname, "FONT" ) ) ||
      	           ( !InstallFlag && !strstr( Source_Fname, "FSM" ) )
      	         )  
      	       {    
	         Build_Destination_Path( Source_Fname, "C:\\AUTO", Dest_Fname );
	         error = Copy_File( Source_Fname, Dest_Fname );
	       }  
     	       break;
      	       
      case 3:  /* FSM GDOS Fonts Directory - AND other stuff that
      		* needs to go into the FSM GDOS directory when 
      		* we're installing FSM GDOS only.
      		*/
	       if( InstallFlag )
	       {	       	           
	         Build_Destination_Path( Source_Fname, dirpath, Dest_Fname );
	         error = Copy_File( Source_Fname, Dest_Fname );
	       }  
      	       break;
      	       
      case 4:  /* CPX Directory */
      	       /* Copy over the CPXs IF they are wanted. */
	       if( ( CurCPX == 1 ) || ( CurCPX == 3 ) )
      	       {   
	         Build_Destination_Path( Source_Fname, CPX_Path, Dest_Fname );
	         error = Copy_File( Source_Fname, Dest_Fname );
	       }  
      	       break;
      	       
      case 5:  /* Assign.Sys directory - Screen Fonts */
	       if( CurScreen )      	       
	       {
	         Build_Destination_Path( Source_Fname, adirpath, Dest_Fname );
	         error = Copy_File( Source_Fname, Dest_Fname );
	       }  
     	       break;
      	       
      case 6:  /* EXTEND.SYS
      	        * If EXTEND.SYS - Always copy over our new extend.sys and
      	        *		  use the FSM GDOS directory path.
      	        *
      	        * Need a sign to say now copying extend.sys 
      	        * Test to see which EXTEND.SYS ( big or small ) to copy.
      	        */
      	        if( ( InstallFlag && RamFlag && strstr( Source_Fname,  "LARGE" ) ) ||
      	            ( InstallFlag && !RamFlag && strstr( Source_Fname, "SMALL" ) ) ||
      	            ( !InstallFlag && strstr( Source_Fname, "FONTGDOS" ) )
      	          )
      	        {    
	            Build_Destination_Path( Source_Fname, "C:", Dest_Fname );
	            Modify_Extend_And_Copy( Source_Fname, Dest_Fname );
	        }  
     	        break;

      case 7:  /* ASSIGN.SYS */
      	       Graf_Mouse( ARROW );
	       Build_Destination_Path( Source_Fname, "C:", Dest_Fname );
	       Graf_Mouse( BUSYBEE );
	       if( ( CurScreen && strstr( Source_Fname, "SFONTS" ) ) ||
                   ( !CurScreen && strstr( Source_Fname, "NOFONTS" ) ) )
               {
                    Modify_Assign_And_Copy( Source_Fname, Dest_Fname, adirpath, DriverName );
	       } 
	       break;

      case 8:  /* Assign.Sys directory - Printer Fonts */
      	       
      	       if( CurDriver && CurBFont )
      	       {
      	           switch( CurBFont )
      	           {
      	              case 1: strcpy( temp, "SLM804" ); /* SLM804 fonts */
      	              	      break;
      	              	      
      	              case 2: strcpy( temp, "FX80" ); /* FX80 fonts */
      	              	      break;
      	              	      
      	              case 3: strcpy( temp, "NB15" ); /* NB15 fonts */
      	              	      break;
      	           }
      	           if( strstr( Source_Fname, temp ) )
      	           {
	             Build_Destination_Path( Source_Fname, adirpath, Dest_Fname );
	             error = Copy_File( Source_Fname, Dest_Fname );
	           }
	       }    
     	       break;
     	             	       
      case 9:  /* Disk Identification File.
                * We don't do anything since the Disk ID was checked
                * when we asked them to switch disks.
                */
      	       break;

      case 10: /* Assign.Sys directory - Drivers
      	        * Only copy over driver that is requested.
      	        */
      	       if( CurDriver && strstr( Source_Fname, DriverName ))
      	       {
	         Build_Destination_Path( Source_Fname, adirpath, Dest_Fname );
	         error = Copy_File( Source_Fname, Dest_Fname );
	       }  
     	       break;

      case 11: /* FSM GDOS WID Fonts Directory */
      	       if( ( InstallFlag && RamFlag && strstr( Source_Fname,  "LARGE" ) ) ||
      	           ( InstallFlag && !RamFlag && strstr( Source_Fname, "SMALL" ) ) 
		 )
	       {	       	           
	         Build_Destination_Path( Source_Fname, dirpath, Dest_Fname );
	         error = Copy_File( Source_Fname, Dest_Fname );
	       }  
      	       break;


      case 12: /* META.SYS and MEMORY.SYS */
      	       if( CurMeta )
      	       {
      	         if( ( CurMeta == 3 ) ||
      	             ( ( CurMeta == 1 ) && strstr( Source_Fname , "META" )) ||
      	             ( ( CurMeta == 2 ) && strstr( Source_Fname, "MEMORY" ))
      	           )
      	         {
	           Build_Destination_Path( Source_Fname, adirpath, Dest_Fname );
	           error = Copy_File( Source_Fname, Dest_Fname );
	         }  
      	       }
      	       break;
      	       
      case 13: /* ROOT OF C: - PAGEOMAT FILE */
      	       if( PageOneFlag )
      	       {
 	         Build_Destination_Path( Source_Fname, "C:", Dest_Fname );
	         error = Copy_File( Source_Fname, Dest_Fname );
      	       }
               break;       
               
      case 14: /* PAGEOMAT DIRECTORY */
               if( PageOneFlag )
               {
                 sprintf( PagePath, "%c:\\PAGEOMAT", CurPageTwo + 'C' );
 	         Build_Destination_Path( Source_Fname, PagePath, Dest_Fname );
	         error = Copy_File( Source_Fname, Dest_Fname );
               }
      	       break;
 
      case 15: /* PAGEOMAT\SAMPLES DIRECTORY */
               if( PageOneFlag )
               {
                 sprintf( PagePath, "%c:\\PAGEOMAT\\SAMPLES", CurPageTwo + 'C' );
 	         Build_Destination_Path( Source_Fname, PagePath, Dest_Fname );
	         error = Copy_File( Source_Fname, Dest_Fname );
               }
      	       break;

      case 16: /* PAGEOMAT\GEM DIRECTORY */
               if( PageOneFlag )
               {
                 sprintf( PagePath, "%c:\\PAGEOMAT\\GEM", CurPageTwo + 'C' );
 	         Build_Destination_Path( Source_Fname, PagePath, Dest_Fname );
	         error = Copy_File( Source_Fname, Dest_Fname );
               }
      	       break;

      case 17: /* PAGEOMAT\GEM\BANNERS DIRECTORY */
               if( PageOneFlag )
               {
                 sprintf( PagePath, "%c:\\PAGEOMAT\\GEM\\BANNERS", CurPageTwo + 'C' );
 	         Build_Destination_Path( Source_Fname, PagePath, Dest_Fname );
	         error = Copy_File( Source_Fname, Dest_Fname );
               }
      	       break;

      case 18: /* PAGEOMAT\GEM\BORDERS DIRECTORY */
               if( PageOneFlag )
               {
                 sprintf( PagePath, "%c:\\PAGEOMAT\\GEM\\BORDERS", CurPageTwo + 'C' );
 	         Build_Destination_Path( Source_Fname, PagePath, Dest_Fname );
	         error = Copy_File( Source_Fname, Dest_Fname );
               }
      	       break;
      	                
      default:
               break;
   }
   return( error );  
}


long
GetRam( void )
{
    long RamValue;
    
    RamValue = *(long *)0x42eL;
    RamFlag  = ( RamValue >= 4000000L );
    return( RamValue );
}
