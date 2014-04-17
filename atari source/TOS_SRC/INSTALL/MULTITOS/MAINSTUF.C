/* MAINSTUF.C
 * ================================================================
 * DATE April 15, 1992
 */
#include <alt\gemskel.h>
#include <alt\vdikeys.h>
#include <gemlib.h>
#include <string.h>
#include <dos.h>
#include <cookie.h>
#include "country.h"
#include "text.h"
#include "setup.h"
#include "handlers.h"
#include "gemskel.h"
#include "menubind.h"
#include "file.h"
#include "tables.h"

/* DEFINES
 * ================================================================
 */


/* PROTOTYPES
 * ================================================================
 */
void initialize( void );
void DoInstall( void );
void Insert_Disk( int num );
void DoInsert( char *ptr, char DriveNum );

void ProcessFile( char *full_path );
void DoAction( int index, char *filename );


/* EXTERNS
 * ================================================================
 */


/* GLOBALS 
 * ================================================================
 */
char LineOne[40];
char LineTwo[40];
char CopyName[20];
char temp[256];
/* FUNCTIONS
 * ================================================================
 */


/* initialize
 * ================================================================
 */
void
initialize( void )
{

   /* Tell the AES we can accept an AP_TERM call for termination
    * iff the AES version is >= 4.0
    */
   if( AES_Version >= 0x0400 )
       shel_write( 9, 1, 0, NULL, NULL );

   /* Read in the INSTALL.DAT file...if there is none, or if there is not
    * enough memory to load the Installation file, the Setup is cancelled.
    */
   if( !Read_DAT_File() )
   {
      Gem_Exit( -1 );      /* Error - No DAT File */
   }


   /* Check for hard disk partitions. If there is none, we shall
    * abort the installation.
    */
   if( !init_drive() )
   {
      form_alert( 1, alert11 );
      Gem_Exit( -1 );
   }

   /* Check the OS for TOS 3.01 - Bezier's don't work properly 
    * with this version.
    */
   CheckOS();	

   /* See how much RAM the user has on this machine
    * If its less than four megs, we do a small extend.sys
    * otherwise, we do the full blown extend.sys
    */
   Supexec( GetRam );

   /* Get the Disk Names */
   GetNumberOfDisks();

   /* Get the printer text and filenames */
/*   GetPrinterNames(); */

   /* Initialize the Submenus and Popup Menu Structures */
   InitMenus();

   /* Get the path from where Setup.prg was run from */
   GetInitialPath();

   /* Build the Data Tables from the DAT File */
   BuildTables();

   gl_control = Check_CPX();
}



/* DoInstall()
 * ================================================================
 */
void
DoInstall( void )
{
  int i;
  int CurDisk;

  for( i = 0; i < gl_numdisks; i++ )
  {
       CurDisk = i;
       Insert_Disk( CurDisk );
       strcpy( DataPath, "A:" );
       DataPath[0] = DriveNum;
       GetFiles( &DataPath[0] );
  }
}



/* Insert_Disk()
 * ================================================================
 * Checks the Disk Drive for the proper disk.
 * It allows the user to cancel installation if necessary.
 */
void
Insert_Disk( int num )
{
   char *ptr;

   ptr = &gl_disk_string[num][0];
   while( !Get_CurDisk_Num( DriveNum, ptr ) )
   {
       DoInsert( ptr, DriveNum );
   }
}


/* DoInsert()
 * ================================================================
 */
void
DoInsert( char *ptr, char DriveNum )
{
    int msg[8];
    int button;
    int done;

    sprintf( LineOne, inserta, ptr );
    sprintf( LineTwo, insertb, DriveNum );

    ActiveTree( ad_insert );
    ObString( ITITLE1 ) = LineOne;
    ObString( ITITLE2 ) = LineTwo;
    Deselect( IINSERT );
  
    SetNewDialog( ad_insert );

    done = FALSE;
    do
    {
      button = xform_do( ad_tree, 0, msg );

      switch( button )
      {
	 case IINSERT:   done = TRUE;
		         Deselect( IINSERT );
		         break;

	 case IEXIT: CheckExit();
		     deselect( ad_tree, IEXIT );
		     break;

	 default: if( button == NIL )
		  {
		     switch( msg[0] )
		     {
		        case  WM_CLOSED: CheckExit();
					 break;

			case  CT_KEY:    if( msg[3] == K_F10 )
					   CheckExit();
					 break;
			default:
				 break;
		     }
		  }
		  break;
      }
    }while( !done );
    
}




/* ProcessFile()
 * ================================================================
 */
void
ProcessFile( char *full_path )
{
    char drive[ 3 ];
    char path[ FMSIZE ];
    char node[ FNSIZE ];
    char ext[ FESIZE ];
    char *cptr;
    int  index;

    strsfn( full_path, &drive[0], &path[0], &node[0], &ext[0] );

    /* ROOT FILE - PRobably DISK Labels or something */    
    if( !strcmp( path, "\\" ) )
       return;

    for( index = 0; index < NUM_PATTERNS; index++ )
    {
       if( ( cptr = strstr( path, Titles[index].path )) != NULL )
       {
           DoAction( index, full_path );
	   break;
       }
    }
}


/* DoAction()
 * ================================================================
 * NOTE: 1) Most have a global flag - which specifies whether or not
 *	    to copy the file from the floppy to the hard disk.
 * 	 2) Many, if installed, must also go into the assign.sys or
 *	    extend.sys.
 *	 3) if the assign.sys or extend.sys is not to be changed,
 *	    AND the files are set to be copied over, then
 *	    they'll just be copied over and the ASSIGN.SYS or EXTEND.SYS
 *	    will not be touched.
 */
void
DoAction( int index, char *filename )
{
    char drive[ 3 ];
    char path[ FMSIZE ];
    char node[ FNSIZE ];
    char ext[ FESIZE ];
	long pvalue = 0L;
	char temp[245];
	int	num;

    strsfn( filename, &drive[0], &path[0], &node[0], &ext[0] );
    strmfe( &CopyName[0], &node[0], &ext[0] );

    switch( index )
    {
#if 0
       case 0:   /* GDOS FILE */
		 /* Copy over either FSMGDOS or FNTGDOS to C:\AUTO */
		 /* Create the Auto Folder if necessary */

		 if( gl_gdos == XFSM )	/* WANT FSMGDOS */
		 {
		     if( !strstr( filename, "FONTS" ) )
			 return;		
		 }	
		 else			/* WANT FONTGDOS */
		 {
		     if( !strstr( filename, "BITMAP" ) )
			 return;
		 }

		 sprintf( DPath, "C:\\AUTO\\%s", CopyName );
		 DoCopy( CopyName );
		 strcpy( ScratchString, "C:\\AUTO" );
		 CheckDir( ScratchString );
 	         Copy_File( filename, DPath );
	         break;
#endif

       case 0:   /* AUTO FILE */
/*		 getcookie( _CPU, &pvalue );
		 if( pvalue == 0x0000001e )
		 {
			if( !strstr( filename, "MINT.PRG" ) )
				return;
		 } else {
			if( !strstr( filename, "MINT68K.PRG" ) )
				return;
		 }
*/
		 /* Copy files always */
		 if( !strstr( filename, "MINT.PRG" ) )
			return;

		 sprintf( DPath, "C:\\AUTO\\%s", "mint.prg" );
		 DoCopy( CopyName );
		 strcpy( ScratchString, "C:\\AUTO" );
		 CheckDir( ScratchString );

		 move_auto();

	     Copy_File( filename, DPath );
		 /* copy file here - creat auto folder if necessary*/
	         break;



       case 5:   /* CPX FILE */
		 /* Copy files if gl_cpx is non-zero */
		 if( gl_cpx )
		 {

		   if( gl_control == 1 || gl_control == 2 )
			   strcpy( CPX_Path, "C:\\CPX" ); 

		   if( Dsetpath( CPX_Path ) )
				if( do_mkdir( CPX_Path, 0 ) < 0 )
					form_alert( 1, bad_path );

		   sprintf( DPath, "%s\\%s", CPX_Path, CopyName );
		   DoCopy( CopyName );
           Copy_File( filename, DPath );

		   /* copy file here */
		 }
	         break;

       case 1:   /* ACC FILE */
		 /* Copy files if gl_acc is non-zero */

			/* Check for old deskicon file.. if there, rename it to .old */
		   if( strstr( filename, "DESKCICN.RSC" ) )
				if( !Fsfirst( "C:\\DESKCICN.RSC", 0 ) )
					Rename( "C:\\DESKCICN.RSC", "C:\\DESKCICN.OLD" );
		
		   sprintf( DPath, "C:\\%s", CopyName );
		   DoCopy( CopyName );
 	       Copy_File( filename, DPath );
	         break;
	
	   case 2:   /* APP files */
		   DoCopy( CopyName );
		   strcpy( ScratchString, AssignPath );
		   CheckDir( ScratchString );
		   sprintf( DPath, "%s\\%s", AssignPath, CopyName );
 	           Copy_File( filename, DPath );
		   break;	

		case 3: /* GEM Files */
		   DoCopy( CopyName );
		   strcpy( ScratchString, AssignPath );
		   CheckDir( ScratchString );
		   sprintf( DPath, "%s\\%s", AssignPath, CopyName );
 	           Copy_File( filename, DPath );
		   break;	

		case 4: /* MULTITOS configuration files */
			if( strcmp( AssignPath, "C:\\MULTITOS" ) != 0 )
				sprintf( DPath, "C:\\%s", CopyName );
			else sprintf( DPath, "C:\\MULTITOS\\%s", CopyName );
			DoCopy( CopyName );
			if( strstr( filename, "GEM.CNF" ) )
				Modify_gmcnf( filename, DPath );
				
			if( strstr( filename, "MINT.CNF" ) )
				Modify_mtcnf( filename, DPath );
			break;

#if 0
       case 4:   /* ASSIGN.SYS FILE */
		 if( gl_assign == 2 )	/* No Changes to ASSIGN.SYS */
		     return;
		
		 /* Include the screen fonts? or not     */
		 /* Skip them if its not the one we want */
		 if( gl_fonts )		/* Include screen fonts */
		 {			/* Look for 'SFONTS' */
		    if( !strstr( filename, "SFONTS" ) )
		      return;
		 }
		 else			/* Don't - so look for NOFONTS */
		 {
		    if( !strstr( filename, "NOFONTS" ) )
		      return;
		 }

		 /* Write to Assign.new or Assign.sys */
		 if( gl_assign == 1 )
		   strcpy( CopyName, "ASSIGN.NEW" );
		 else
		   strcpy( CopyName, "ASSIGN.SYS" );
		 
		 sprintf( DPath, "C:\\%s", CopyName );
		 DoCopy( CopyName );
		 ModifyAssign( filename, DPath );
	         break;


       case 5:   /* EXTEND.SYS File */
		 if( gl_extend == 2 )	/* No Changes to EXTEND.SYS */
		     return;

		 /* Want no fonts for FONTGDOS use  OR
		  * We've requested not to load scalable fonts
		  */
		 if( ( gl_gdos == XFONT ) || ( !gl_scalable ))
		 {
		   /* Want no fonts for FONTGDOS use */
		   if( !strstr( filename, "NOFONTS" ))
		      return;
		 }

		 if( gl_scalable )
		 {
		   /* Check if we want the LARGE or SMALL one   */
		   if( RamFlag )	/* 4 megs or more - use LARGE */
		   {
		     if( !strstr( filename, "LARGE" ) )
		       return;	/* not large, so skip */
		   }	
		   else		/* less than 4 megs - use SMALL */
		   {
		     if( !strstr( filename, "SMALL" ) )
		     return;	/* Not small - so skip */
		   }		 
		 }

		 /* Check if we want it as EXTEND.NEW or EXTEND.SYS */
		 if( gl_extend == 1 )
		   strcpy( CopyName, "EXTEND.NEW" );
		 else
		   strcpy( CopyName, "EXTEND.SYS" );
			
		 sprintf( DPath, "C:\\%s", CopyName );
		 DoCopy( CopyName );
		 ModifyExtend( filename, DPath );
		 break;

       case 6:   /* DRIVER FILE */
		 /* path is where the assign.sys is */
		 /* all drivers will be copied over always*/
		 DoCopy( CopyName );
		 strcpy( ScratchString, AssignPath );
		 CheckDir( ScratchString );
		 sprintf( DPath, "%s\\%s", AssignPath, CopyName );
 	         Copy_File( filename, DPath );
	         break;

       case 7:   /* OUTLINE FONT FILE */
		 if( gl_scalable )
		 {
		   DoCopy( CopyName );
		   strcpy( ScratchString, ExtendPath );
		   CheckDir( ScratchString );
		   sprintf( DPath, "%s\\%s", ExtendPath, CopyName );
 	           Copy_File( filename, DPath );
		 }
	         break;

       case 8:   /* SCREEN FONT FILE */
		 /* Copy over if gl_fonts is non-zero */
		 if( gl_fonts )
		 {
		   /* path is the assign.sys */
		   DoCopy( CopyName );
		   strcpy( ScratchString, AssignPath );
		   CheckDir( ScratchString );
		   sprintf( DPath, "%s\\%s", AssignPath, CopyName );
 	           Copy_File( filename, DPath );
		 }
	         break;

       case 9:   /* NB15 FONT FILE */
		 /* Copy over if gl_fonts is non-zero */
		 if( gl_nb15 )
		 {
		   /* path is the assign.sys */
		   DoCopy( CopyName );
		   strcpy( ScratchString, AssignPath );
		   CheckDir( ScratchString );
		   sprintf( DPath, "%s\\%s", AssignPath, CopyName );
 	           Copy_File( filename, DPath );
		 }
	         break;

       case 10:   /* SLM FONT FILE */
		 /* Copy over if gl_fonts is non-zero */
		 if( gl_slm )
		 {
		   /* path is the assign.sys */
		   DoCopy( CopyName );
		   strcpy( ScratchString, AssignPath );
		   CheckDir( ScratchString );
		   sprintf( DPath, "%s\\%s", AssignPath, CopyName );
 	           Copy_File( filename, DPath );
		 }
	         break;

       case 11:  /* FX80 FONT FILE */
		 /* copy over if gl_fx80 is non-zero */
		 if( gl_fx80 )
		 {
		   /* path is the assign.sys */
		   DoCopy( CopyName );
		   strcpy( ScratchString, AssignPath );
		   CheckDir( ScratchString );
		   sprintf( DPath, "%s\\%s", AssignPath, CopyName );
 	           Copy_File( filename, DPath );
		 }
	         break;

       case 12:  /* PAGEOMAT FILE */
		 /* Copy over if gl_pageomat is non-zero */
		 if( gl_pageomat )
		 {
		   DoCopy( CopyName );

		   /* Check if its the ROOT file. */
		   if( strstr( Titles[12].fnode[0].fname, CopyName ) )
		   {
		      /* This is the ROOT file, so put it at C:\\ */
		      sprintf( DPath, "C:\\%s", CopyName );
		   }
		   else
		   {
		      /* Path is in addition to the EXTEND.SYS PATH */
		      sprintf( DPath, "%s%s\\%s", ExtendPath, path, CopyName);
		      sprintf( ScratchString, "%s%s", ExtendPath, path );
		      CheckDir( ScratchString );
		   }
		   Copy_File( filename, DPath );
		 }
	         break;
#endif
       default: 
		break;
   }
}

