/* MAINSTUF.C
 * ================================================================
 * DATE: October 3, 1990
 *
 * 01/15/92 cjg - Yes, 1992
 *		- Modified to prompt for the installation of Pageomat.
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

#pragma warn -apt		   /* 1 Non-portable pointer assignment */
#pragma warn -rpt		   /* 1 Non-portable pointer conversion */
#include "finstall.rsh"
#pragma warn .apt
#pragma warn .rpt

#include "fixrsh.h"
#include "file.h"
#include "install.h"
#include "text.h"
#include "popmenu.h"

/*
 * TURN OFF Turbo C "parameter X is never used" warnings
 */
#pragma warn -par

/* DEFINES
 * ================================================================
 */


/* PROTOTYPES
 * ================================================================
 */
void 	do_init( void );
BOOLEAN Do_Entry( void );

void	Do_Quiz( void );
BOOLEAN Do_EDrive( void );
BOOLEAN	Do_EPath( void );
BOOLEAN Do_EDriver( void );
BOOLEAN Do_EScreen( void );
BOOLEAN Do_EPFonts( void );
BOOLEAN	Do_CPXACC( void );
BOOLEAN Do_Meta( void );
BOOLEAN Do_EAssign( void );
BOOLEAN Do_ENoAssign( int action );
BOOLEAN Do_EAPath( void );
BOOLEAN Do_ECPX( void );
BOOLEAN Do_EFile( void );
BOOLEAN Do_EGdos( void );
BOOLEAN Do_EGplus( void );
BOOLEAN Do_EFGdos( void );
BOOLEAN Do_EAFile( void );
BOOLEAN Do_PageOne( void );
BOOLEAN Do_PageTwo( void );

int	execform( OBJECT *tree, int start_obj );
void 	Graf_Mouse( int item );
void    Scan_Message( OBJECT *Tree, BOOLEAN flag );
void	WaitUpButton( void );


/* EXTERN
 * ================================================================
 */
void Gem_Exit( int item );
long gdos_tst( void ); 


/* GLOBALS 
 * ================================================================
 */
OBJECT *tree;
OBJECT *ad_entry;

OBJECT *ad_dir;
OBJECT *ad_driver;
OBJECT *ad_copy;
OBJECT *ad_assign;
OBJECT *ad_extend;
OBJECT *ad_massign;
OBJECT *ad_rename;
OBJECT *ad_conflict;

OBJECT *ad_edrive;
OBJECT *ad_epath;
OBJECT *ad_edriver;
OBJECT *ad_escreen;
OBJECT *ad_epfonts;
OBJECT *ad_ecpxacc;
OBJECT *ad_emeta;
OBJECT *ad_eassign;
OBJECT *ad_enoassign;
OBJECT *ad_eapath;
OBJECT *ad_ecpx;
OBJECT *ad_efile;
OBJECT *ad_egdos;
OBJECT *ad_egplus;
OBJECT *ad_efgdos;
OBJECT *ad_eafile;
OBJECT *ad_pageone;
OBJECT *ad_pagetwo;

BOOLEAN InstallFlag;	/* 1 = INSTALL FSM, 0 INSTALL FONT GDOS */
char head_text[ 128 ];

char dirpath[ 128 ];	/* directory path for FSM GDOS folder  */
char adirpath[ 128 ];	/* directory path for FONTGDOS folder  */
char folder_name[ 16 ]; /* Folder to install FSM GDOS fonts in */
char temp[ 128 ];


/* Partition Drive Submenu info */
int  CurDrive    = 0;
int  DriveMenuID = -1;
char DriveText[15];
int  DriveCount;
int  DriveArray[ 14 ];
BOOLEAN CurScreen;	/* Use Screen fonts, TRUE-FALSE */

/* Printer Driver Submenu info */
int  CurDriver    = 0;
int  DriverMenuID = -1;
char DriverText[20];
int  DriverCount  = 12; /* Including None */
char DriverName[ 20 ];


/* Printer Fonts Submenu info */
int  CurBFont    = 0;
int  BFontMenuID = -1;
char BFontText[ 20 ];
int  BFontCount  = 4;   /* Including None */
char CurBName[ 20 ];

/* CPXACC Submenu info */
int  CurCPX    = 0;
int  CPXMenuID = -1;
char CPXText[ 20 ];
int  CPXCount  = 4;

/* META Submenu info */
int  CurMeta    = 0;
int  MetaMenuID = -1;
char MetaText[ 20 ];
int  MetaCount  = 4;

/* Assign.sys submenu info */
int  CurAss    = 0;
int  AssMenuID = -1;
char AssText[ 20 ];
int  AssCount  = 3;

/* No Assign.sys submenu info */
int  CurNoAss    = 0;
int  NoAssMenuID = -1;
char NoAssText[ 20 ];
int  NoAssCount  = 2;

/* New Assign.sys Path      */
/*   APathCount == DriveCount */
int  CurAPath    = 0;
int  APathMenuID = -1;
char APathText[ 20 ];	
char AFolder[ 16 ];
	

/* PAGEOMAT menu info */
BOOLEAN PageOneFlag;
int  PageTwoID  = -1;
int  CurPageTwo = 0;
char PagePath[ 128 ];

/* GEMSKEL functions
 * ================================================================
 */

/* do_main()
 * ================================================================
 */
void
do_main( void )
{
  if( Do_Entry() )
  {
    do_init();
    Do_Quiz();
  }  
}


/* Do_Entry()
 * ================================================================
 * Prompt to install FSM GDOS or Font Gdos 
 */
BOOLEAN
Do_Entry( void )
{
    int   button;
    
    ActiveTree( ad_entry );
    button      = execform( ad_entry, 0 );
    InstallFlag = IsSelected( IFSM );
    strcpy( head_text, iheader[ InstallFlag ] );
    Deselect( button );
    return( button == IOK );
}



/* do_init()
 * ================================================================
 */
void
do_init( void )
{
   int     i;

   /* Read in the INSTALL.DAT file...if there is none, or if there
    * is not enough memory to load the Installation file, the
    * Installation is cancelled.
    */
   if( !Read_DAT_File() )
   {
      Gem_Exit( 0 );      
   }

   /* Check for hard disk partitions. If there is none, we shall
    * abort the installation.
    */
   if( !init_drive() )
   {
      form_alert( 1, alert11 );
      Gem_Exit( 0 );
   }
   
   if( InstallFlag )	/* FSM GDOS INSTALLATION */
   {
     /* Check if FSMGDOS.PRG is already installed 
      * Cancel Installation if so requested.
      */
      if( CheckFSMGdos() )
      {
        if( form_alert( 1, alert12 ) == 2 )
           Gem_Exit( 0 );
      }
   }
   else			/* FONT GDOS INSTALLATION */
   {
     /* Check if FONTGDOS.PRG is already installed.
      * Cancel Installation if so requested.
      */
      if( CheckEFGdos() )
      {
        if( form_alert( 1, alert14 ) == 2 )
           Gem_Exit( 0 );
      }
   }   

   CheckOS();
   
   /* Initialize SubMenus */
   InitPopUpMenus();
   SetSubMenuDelay( 300L );
   SetSubDragDelay( 3000L );
   SetArrowClickDelay( 150L );

   /* Setup Disk Drive Partition and Printer Driver SubMenus */
   DriveMenuID  = InsertPopUpMenu( DriveNames[0], DriveCount, DriveCount );
   DriverMenuID = InsertPopUpMenu( DriverNames[0], DriverCount, DriverCount );
   BFontMenuID  = InsertPopUpMenu( BFontNames[0], BFontCount, BFontCount );
   CPXMenuID    = InsertPopUpMenu( CPXNames[0], CPXCount, CPXCount );
   MetaMenuID   = InsertPopUpMenu( MetaNames[0], MetaCount, MetaCount );
   AssMenuID    = InsertPopUpMenu( AssNames[0], AssCount, AssCount );
   NoAssMenuID  = InsertPopUpMenu( NoAssNames[0], NoAssCount, NoAssCount );
   APathMenuID  = InsertPopUpMenu( APathNames[0], DriveCount, DriveCount );
   PageTwoID    = InsertPopUpMenu( DriveNames[0], DriveCount, DriveCount );
   
   
   /* Setup Drive SubMenu */
   for( i = 0; i < 14; i++ )
   {
      DisableItem( DriveMenuID, i );
      DisableItem( APathMenuID, i );
      if( DriveArray[ i ] )
      {
         EnableItem( DriveMenuID, i );
         EnableItem( APathMenuID, i );
      }   
   }
   SetStartItem( DriveMenuID, CurDrive );
   CheckItem( DriveMenuID, CurDrive, TRUE );

   SetStartItem( APathMenuID, CurAPath );
   CheckItem( APathMenuID, CurAPath, TRUE );

   /* Setup Driver SubMenu */
   CurDriver    = 0;		/* Set to None Selected */
   CheckItem( DriverMenuID, 0, TRUE );   
   
   /* Setup Printer Bitmap Fonts Submenu
    * Setup CPXACC Submenu
    * Setup CPXACC Submenu
    */ 
   CurBFont = CurCPX = CurMeta = CurAss = CurNoAss = 0;
   CheckItem( BFontMenuID, 0, TRUE );   
   CheckItem( CPXMenuID, 0, TRUE );
   CheckItem( MetaMenuID, 0, TRUE );

   CheckItem( AssMenuID, 0, TRUE );
   CheckItem( NoAssMenuID, 0, TRUE );   
}



/* Do_Quiz()
 * ================================================================
 */
void
Do_Quiz( void )
{
   int action;
   int done;

 
   if( !InstallFlag )	/* FONT GDOS INSTALLATION */
   { 
      while( Do_EAPath() )
      {
        if( form_alert( 1, acancel ) == 1 )
         return;
      }
      /* For FONTGDOS, make the extend.sys path be the same as the
       * assign.sys path.
       */
      strcpy( dirpath, adirpath );
      Assign_Flag = 1;	/* Make it assign.sys doesn't exist */
   }   
   else			/* FSM GDOS INSTALLATION */
   {  
      while( Do_EDrive() )
      {
        if( form_alert( 1, acancel ) == 1 )
          return;
      }  
   
      while( Do_EPath() )
      {
        if( form_alert( 1, acancel ) == 1 )
            return;
      }  
   }
   
     
   while( Do_EDriver() )
   {
     if( form_alert( 1, acancel ) == 1 )
       return;  
   }  
     
   while( Do_EScreen() )
   {
     if( form_alert( 1, acancel ) == 1 )
       return;  
   }
     
   while( Do_EPFonts() )
   {
     if( form_alert( 1, acancel ) == 1 )
       return;   
   }    
     
   while( Do_CPXACC() )
   {
     if( form_alert( 1, acancel ) == 1 )
       return;  
   }    

   if( ( CurCPX == 1 ) || ( CurCPX == 3 ) )
   {
     while( Do_ECPX() )
     {
       if( form_alert( 1, acancel ) == 1 )
         return;  
     }
   }  
      
   while( Do_Meta() )
   {
     if( form_alert( 1, acancel ) == 1 )
       return;  
   }    


   /* FSM GDOS will check only for all of the ASSIGN.SYS junk */
   if( InstallFlag )
   {
      action = Check_Assign();  
      if( !action )
      {
     	/* Normal ASSIGN.SYS Found */
     	while( Do_EAssign() )
     	{
       	   if( form_alert( 1, acancel ) == 1 )
           return;
        }      

        if( CurAss == 1 ) /* Set a new path */
        {
           while( Do_EAPath() )
           {
              if( form_alert( 1, acancel ) == 1 )
              return;
           }    
           /* adirpath is the path */
        }
        
        if( !CurAss ) /* Use existing ASSIGN.SYS path */
            strcpy( adirpath, Assign_Path );
        if( CurAss == 2 ) /* Use existing FSM GDOS path */
	    strcpy( adirpath, dirpath );     
      }
      else
      {
        while( Do_ENoAssign( action ) )
             return;
          
        if( CurNoAss == 1 )/* Set a new path */
        {
          while( Do_EAPath() )
               return;
        }
        else
          strcpy( adirpath, dirpath );	/* USE the FSM GDOS path */
        /* adirpath is the ASSIGN.SYS path */
      }  
   }

   
   while( Do_EAFile() )		/* CHeck for ASSIGN.sYS */
   {
     if( form_alert( 1, acancel ) == 1 )
        return;
   }


   while( Do_EFile() )		/* Check for EXTEND.SYS */
   {
     if( form_alert( 1, acancel ) == 1 )
       return;  
   }    

   while( Do_EGdos() )		/* Check for Gdos */
   {
     if( form_alert( 1, acancel ) == 1 )
       return;  
   }    

   while( Do_EGplus() )		/* Check for Gplus */
   {
     if( form_alert( 1, acancel ) == 1 )
       return;  
   }    

   while( Do_EFGdos() )		/* Check for FontGdos */
   {
     if( form_alert( 1, acancel ) == 1 )
       return;  
   }    


   while( Do_PageOne() )		/* Check for Page Installation */
   {
     if( form_alert( 1, acancel ) == 1 )
       return;
   }

   if( PageOneFlag )
   {
      while( Do_PageTwo() )
      {
         if( form_alert( 1, acancel ) == 1 )
            return;
      }
   }
   
   
   /* Commence Installation? */
   done = FALSE;
   do
   {
     if( form_alert( 1, commence ) == 2 )
     {
       /* Cancel installation? */
       if( form_alert( 1, acancel ) == 1 )
         return;
     }
     else
     {
       done = TRUE;         
       Do_Install();
     }  
   }while( !done );         
}



/* Do_EDrive()
 * ================================================================
 */
BOOLEAN
Do_EDrive( void )
{
   GRECT   rect;
   GRECT   xrect;
   int     button;
   BOOLEAN done = FALSE;
   MRETS   mk;   
   long    value;
   int     item;
   int     id;
   int     obj;
   
   ActiveTree( ad_edrive );

   strcpy( DriveText, DriveNames[ CurDrive ] );
   ObString( I1BUTTON ) = DriveText;

   if( DriveCount == 1 )
   {
     NoShadow( I1BUTTON );   
     NoTouchExit( I1BUTTON );
   }     
   
   Form_center( tree, &rect );
   Form_dial( FMD_START, &rect, &rect );
   Objc_draw( tree, ROOT, MAX_DEPTH, &rect );
   do
   {
      button = form_do( tree, 0 );
      
      if( button & 0x8000 )
          button &= 0x7FFF;      
   
      switch( button )
      {
	 case I1OK:
	 case I1CANCEL: done = TRUE;
	 		break;

	 case I1BUTTON:  /* If there is only 1 Drive, we skip */
	 		 if( DriveCount == 1 )
	  		       break;
	  		       
	  		 select( tree, I1BUTTON );
	  	 	 WaitUpButton();
	 		 Graf_mkstate( &mk );
	 		 obj = objc_find( tree, ROOT, MAX_DEPTH, mk.x, mk.y );
			 if( obj == I1BUTTON )
			 {
	  		   select( tree, I1TITLE );
		           xrect = ObRect( button );
		     	   objc_offset( tree, button, &xrect.g_x, &xrect.g_y );
                           value = PopUpMenuSelect( DriveMenuID, xrect.g_x, xrect.g_y, CurDrive );        
                           if( value != -1L )
                           {
		             item  = (int)value;
               		     id = (int)( value >> 16L );
                         
              	             if( ( item != -1 ) && ( id == DriveMenuID ) )
              	             {
		                CheckItem( id, CurDrive, FALSE );
                  		CheckItem( id, item, TRUE );
                  		CurDrive = item;
                  		SetStartItem( id, item );
 
				strcpy( DriveText, DriveNames[ CurDrive ] );
				ObString( I1BUTTON ) = DriveText;
                		Objc_draw( tree, I1BUTTON, MAX_DEPTH, NULL );
              	              }
                            }
                            deselect( tree, I1TITLE );
                         }
                         deselect( tree, I1BUTTON );  
	 		break;
	 			 		
	 default:
	 	        break;		      
      }
             
   }while( !done );

   Form_dial( FMD_FINISH, &rect, &rect );
   Deselect( button );
   return( button == I1CANCEL );
}



/* Do_EPath()
 * ================================================================
 */
BOOLEAN
Do_EPath( void )
{
   int    button;
   char   name[16];
   int    i = 0, j = 0;
   long   length;
   char   dummy[3];
   
   ActiveTree( ad_epath );

   strcpy( folder_name, "FSMGDOS" );
   TedText( I2TEXT ) = folder_name;   
   sprintf( dummy, "%c.", CurDrive + 'C' );
   ObString( I2DRIVE ) = dummy;
   
   button = execform( tree, 0 );
   if( button == I2OK )
   {
    strcpy( folder_name, TedText( I2TEXT ) );

    if( folder_name[0] )  	/* Check for no folder name */
    {
      length = strlen( folder_name );
      /* Copy the 8 character filename, stopping if we reach 8 characters,
       * or hit the end of the text string, or hit a ' '.
       */
      for( i = 0; (i < length) && ( i < 8 ) && ( folder_name[i] != ' '); name[j++] = folder_name[i++] );

      /* if we have less than 8 characters, there are blank spaces
       * up to the . mark, so we advance up to there.
       * BTW, there is NO '.', at the most, the folder is 11 characters.
       */
      for( i = i; ( i < length ) && ( i < 8 ) && ( folder_name[i] == ' ' ); i++ );
      
      /* now, put in the '.' */
      if(( i < length ) && folder_name[i] )
          name[j++] = '.';
          
      /* now, copy the extender if there is one...*/    
      for( i = i; i<length; name[j++] = folder_name[i++] );
      name[ j ] = '\0';
    }
    else
    {
      strcpy( folder_name, "FSMGDOS" );
      strcpy( name, "FSMGDOS" );
    }  
    sprintf( dirpath, "%c:\\%s", CurDrive + 'C', name );
   }
   Deselect( button );
   return( button == I2CANCEL );
}



/* Do_EDriver()
 * ================================================================
 */
BOOLEAN
Do_EDriver( void )
{
   GRECT   rect;
   GRECT   xrect;
   int     button;
   BOOLEAN done = FALSE;
   MRETS   mk;   
   long    value;
   int     item;
   int     id;
   int     obj;

   ActiveTree( ad_edriver );

   TedText( I3HEAD ) = head_text;
   
   strcpy( DriverText, DriverNames[ CurDriver ] );
   ObString( I3BUTTON ) = DriverText;
   
   Form_center( tree, &rect );
   Form_dial( FMD_START, &rect, &rect );
   Objc_draw( tree, ROOT, MAX_DEPTH, &rect );
   do
   {
      button = form_do( tree, 0 );
      
      if( button & 0x8000 )
          button &= 0x7FFF;      
   
      switch( button )
      {
	 case I3OK:
	 case I3CANCEL: done = TRUE;
	 		break;

	 case I3BUTTON:
	  		select( tree, I3BUTTON );
	  	 	WaitUpButton();
	 		Graf_mkstate( &mk );
	 		obj = objc_find( tree, ROOT, MAX_DEPTH, mk.x, mk.y );
			if( obj == I3BUTTON )
			{
	  		   select( tree, I3TITLE );
		           xrect = ObRect( button );
		     	   objc_offset( tree, button, &xrect.g_x, &xrect.g_y );
                           value = PopUpMenuSelect( DriverMenuID, xrect.g_x, xrect.g_y, CurDriver );        
                           if( value != -1L )
                           {
		             item  = (int)value;
               		     id = (int)( value >> 16L );
                         
              	             if( ( item != -1 ) && ( id == DriverMenuID ) )
              	             {
		                CheckItem( id, CurDriver, FALSE );
                  		CheckItem( id, item, TRUE );
                  		CurDriver = item;
                  		SetStartItem( id, item );
 
				strcpy( DriverText, DriverNames[ CurDriver ] );
				ObString( I3BUTTON ) = DriverText;
                		Objc_draw( tree, I3BUTTON, MAX_DEPTH, NULL );
              	              }
                            }
                            deselect( tree, I3TITLE );
                        }
                        deselect( tree, I3BUTTON );  	  		 
	  		break;
	 			 		
	 default:
	 	        break;		      
      }
             
   }while( !done );

   Form_dial( FMD_FINISH, &rect, &rect );
   
   /* Get the Name of the driver...*/
   if( button == I3OK )
   {
      if( !CurDriver )
        DriverName[0] = '\0';
      else
        strcpy( DriverName, DriverIndex[ CurDriver ] );
   }
   Deselect( button );
   return( button == I3CANCEL );
}




/* Do_EScreen()
 * ================================================================
 */
BOOLEAN
Do_EScreen( void )
{
    int   button;
    
    
    ActiveTree( ad_escreen );
    TedText( I4HEAD ) = head_text;
    button = execform( ad_escreen, 0 );
    CurScreen = IsSelected( I4YES );
    Deselect( button );
    return( button == I4CANCEL );
}


/* Do_EPFONTS()
 * ================================================================
 */
BOOLEAN
Do_EPFonts( void )
{
   GRECT   rect;
   GRECT   xrect;
   int     button;
   BOOLEAN done = FALSE;
   MRETS   mk;   
   long    value;
   int     item;
   int     id;
   int     obj;
   
   ActiveTree( ad_epfonts );

   TedText( I5HEAD ) = head_text;
   
   strcpy( BFontText, BFontNames[ CurBFont ] );
   ObString( I5BUTTON ) = BFontText;
   
   Form_center( tree, &rect );
   Form_dial( FMD_START, &rect, &rect );
   Objc_draw( tree, ROOT, MAX_DEPTH, &rect );
   do
   {
      button = form_do( tree, 0 );
      
      if( button & 0x8000 )
          button &= 0x7FFF;      
   
      switch( button )
      {
	 case I5OK:
	 case I5CANCEL: done = TRUE;
	 		break;

	 case I5BUTTON:
	  		 select( tree, I5BUTTON );
	  	 	 WaitUpButton();
	 		 Graf_mkstate( &mk );
	 		 obj = objc_find( tree, ROOT, MAX_DEPTH, mk.x, mk.y );
			 if( obj == I5BUTTON )
			 {
	  		   select( tree, I5TITLE );
		           xrect = ObRect( button );
		     	   objc_offset( tree, button, &xrect.g_x, &xrect.g_y );
                           value = PopUpMenuSelect( BFontMenuID, xrect.g_x, xrect.g_y, CurBFont );        
                           if( value != -1L )
                           {
		             item  = (int)value;
               		     id = (int)( value >> 16L );
                         
              	             if( ( item != -1 ) && ( id == BFontMenuID ) )
              	             {
		                CheckItem( id, CurBFont, FALSE );
                  		CheckItem( id, item, TRUE );
                  		CurBFont = item;
                  		SetStartItem( id, item );
 
				strcpy( BFontText, BFontNames[ CurBFont ] );
				ObString( I5BUTTON ) = BFontText;
                		Objc_draw( tree, I5BUTTON, MAX_DEPTH, NULL );
              	              }
                            }
                            deselect( tree, I5TITLE );
                         }
                         deselect( tree, I5BUTTON );  
	 		break;
	 			 		
	 default:
	 	        break;		      
      }
             
   }while( !done );
   Form_dial( FMD_FINISH, &rect, &rect );

   if( !CurBFont )
     CurBName[0] = '\0';
   else
     strcpy( CurBName, CurBStyle[ CurBFont ] );   
   Deselect( button );
   return( button == I5CANCEL );
}



/* Do_CPXACC()
 * ================================================================
 */
BOOLEAN
Do_CPXACC( void )
{
   GRECT   rect;
   GRECT   xrect;
   int     button;
   BOOLEAN done = FALSE;
   MRETS   mk;   
   long    value;
   int     item;
   int     id;
   int     obj;
   
   ActiveTree( ad_ecpxacc );

   TedText( I6HEAD ) = head_text;
      
   strcpy( CPXText, CPXNames[ CurCPX ] );
   ObString( I6BUTTON ) = CPXText;
   
   Form_center( tree, &rect );
   Form_dial( FMD_START, &rect, &rect );
   Objc_draw( tree, ROOT, MAX_DEPTH, &rect );
   do
   {
      button = form_do( tree, 0 );
      
      if( button & 0x8000 )
          button &= 0x7FFF;      
   
      switch( button )
      {
	 case I6OK:
	 case I6CANCEL: done = TRUE;
	 		break;

	 case I6BUTTON:
	  		 select( tree, I6BUTTON );
	  	 	 WaitUpButton();
	 		 Graf_mkstate( &mk );
	 		 obj = objc_find( tree, ROOT, MAX_DEPTH, mk.x, mk.y );
			 if( obj == I6BUTTON )
			 {
	  		   select( tree, I6TITLE );
		           xrect = ObRect( button );
		     	   objc_offset( tree, button, &xrect.g_x, &xrect.g_y );
                           value = PopUpMenuSelect( CPXMenuID, xrect.g_x, xrect.g_y, CurCPX );        
                           if( value != -1L )
                           {
		             item  = (int)value;
               		     id = (int)( value >> 16L );
                         
              	             if( ( item != -1 ) && ( id == CPXMenuID ) )
              	             {
		                CheckItem( id, CurCPX, FALSE );
                  		CheckItem( id, item, TRUE );
                  		CurCPX = item;
                  		SetStartItem( id, item );
 
				strcpy( CPXText, CPXNames[ CurCPX ] );
				ObString( I6BUTTON ) = CPXText;
                		Objc_draw( tree, I6BUTTON, MAX_DEPTH, NULL );
              	              }
                            }
                            deselect( tree, I6TITLE );
                         }
                         deselect( tree, I6BUTTON );  
	 		break;
	 			 		
	 default:
	 	        break;		      
      }
             
   }while( !done );

   Form_dial( FMD_FINISH, &rect, &rect );

   Deselect( button );
   return( button == I6CANCEL );
}




/* Do_Meta()
 * ================================================================
 */
BOOLEAN
Do_Meta( void )
{
   GRECT   rect;
   GRECT   xrect;
   int     button;
   BOOLEAN done = FALSE;
   MRETS   mk;   
   long    value;
   int     item;
   int     id;
   int     obj;
   
   ActiveTree( ad_emeta );
   
   TedText( I7HEAD ) = head_text;
   
   strcpy( MetaText, MetaNames[ CurMeta ] );
   ObString( I7BUTTON ) = MetaText;
   
   Form_center( tree, &rect );
   Form_dial( FMD_START, &rect, &rect );
   Objc_draw( tree, ROOT, MAX_DEPTH, &rect );
   do
   {
      button = form_do( tree, 0 );
      
      if( button & 0x8000 )
          button &= 0x7FFF;      
   
      switch( button )
      {
	 case I7OK:
	 case I7CANCEL: done = TRUE;
	 		break;

	 case I7BUTTON:
	  		 select( tree, I7BUTTON );
	  	 	 WaitUpButton();
	 		 Graf_mkstate( &mk );
	 		 obj = objc_find( tree, ROOT, MAX_DEPTH, mk.x, mk.y );
			 if( obj == I7BUTTON )
			 {
	  		   select( tree, I7TITLE );
		           xrect = ObRect( button );
		     	   objc_offset( tree, button, &xrect.g_x, &xrect.g_y );
                           value = PopUpMenuSelect( MetaMenuID, xrect.g_x, xrect.g_y, CurMeta );        
                           if( value != -1L )
                           {
		             item  = (int)value;
               		     id = (int)( value >> 16L );
                         
              	             if( ( item != -1 ) && ( id == MetaMenuID ) )
              	             {
		                CheckItem( id, CurMeta, FALSE );
                  		CheckItem( id, item, TRUE );
                  		CurMeta = item;
                  		SetStartItem( id, item );
 
				strcpy( MetaText, MetaNames[ CurMeta ] );
				ObString( I7BUTTON ) = MetaText;
                		Objc_draw( tree, I7BUTTON, MAX_DEPTH, NULL );
              	              }
                            }
                            deselect( tree, I7TITLE );
                         }
                         deselect( tree, I7BUTTON );  
	 		break;
	 			 		
	 default:
	 	        break;		      
      }
             
   }while( !done );

   Form_dial( FMD_FINISH, &rect, &rect );

   Deselect( button );
   return( button == I7CANCEL );
}




/* Do_EAssign()
 * ================================================================
 */
BOOLEAN
Do_EAssign( void )
{
   GRECT   rect;
   GRECT   xrect;
   int     button;
   BOOLEAN done = FALSE;
   MRETS   mk;   
   long    value;
   int     item;
   int     id;
   int     obj;
   
   ActiveTree( ad_eassign );
   
   strcpy( AssText, AssNames[ CurAss ] );
   ObString( I8BUTTON ) = AssText;

   strncpy( temp, Assign_Path, 26 );
   ObString( I8APATH ) = temp;
   ObString( I8EPATH ) = dirpath;
         
   Form_center( tree, &rect );
   Form_dial( FMD_START, &rect, &rect );
   Objc_draw( tree, ROOT, MAX_DEPTH, &rect );
   do
   {
      button = form_do( tree, 0 );
      
      if( button & 0x8000 )
          button &= 0x7FFF;      
   
      switch( button )
      {
	 case I8OK:
	 case I8CANCEL: done = TRUE;
	 		break;

	 case I8BUTTON:
	  		 select( tree, I8BUTTON );
	  	 	 WaitUpButton();
	 		 Graf_mkstate( &mk );
	 		 obj = objc_find( tree, ROOT, MAX_DEPTH, mk.x, mk.y );
			 if( obj == I8BUTTON )
			 {
	  		   select( tree, I8TITLE );
		           xrect = ObRect( button );
		     	   objc_offset( tree, button, &xrect.g_x, &xrect.g_y );
                           value = PopUpMenuSelect( AssMenuID, xrect.g_x, xrect.g_y, CurAss );        
                           if( value != -1L )
                           {
		             item  = (int)value;
               		     id = (int)( value >> 16L );
                         
              	             if( ( item != -1 ) && ( id == AssMenuID ) )
              	             {
		                CheckItem( id, CurAss, FALSE );
                  		CheckItem( id, item, TRUE );
                  		CurAss = item;
                  		SetStartItem( id, item );
 
				strcpy( AssText, AssNames[ CurAss ] );
				ObString( I8BUTTON ) = AssText;
                		Objc_draw( tree, I8BUTTON, MAX_DEPTH, NULL );
              	              }
                            }
                            deselect( tree, I8TITLE );
                         }
                         deselect( tree, I8BUTTON );  
	 		break;
	 			 		
	 default:
	 	        break;		      
      }
             
   }while( !done );

   Form_dial( FMD_FINISH, &rect, &rect );

   Deselect( button );
   return( button == I8CANCEL );
}





/* Do_ENoAssign()
 * ================================================================
 */
BOOLEAN
Do_ENoAssign( int action )
{
   GRECT   rect;
   GRECT   xrect;
   int     button;
   BOOLEAN done = FALSE;
   MRETS   mk;   
   long    value;
   int     item;
   int     id;
   int     obj;
   
   ActiveTree( ad_enoassign );
   
   strcpy( NoAssText, NoAssNames[ CurNoAss ] );
   ObString( I9BUTTON ) = NoAssText;
   
   ObString( I9EPATH ) = dirpath;
   strcpy( temp, NoAssOther[ action ] );
   ObString( I9HEADER ) = temp;
         
   Form_center( tree, &rect );
   Form_dial( FMD_START, &rect, &rect );
   Objc_draw( tree, ROOT, MAX_DEPTH, &rect );
   do
   {
      button = form_do( tree, 0 );
      
      if( button & 0x8000 )
          button &= 0x7FFF;      
   
      switch( button )
      {
	 case I9OK:
	 case I9CANCEL: done = TRUE;
	 		break;

	 case I9BUTTON:
	  		 select( tree, I9BUTTON );
	  	 	 WaitUpButton();
	 		 Graf_mkstate( &mk );
	 		 obj = objc_find( tree, ROOT, MAX_DEPTH, mk.x, mk.y );
			 if( obj == I9BUTTON )
			 {
	  		   select( tree, I9TITLE );
		           xrect = ObRect( button );
		     	   objc_offset( tree, button, &xrect.g_x, &xrect.g_y );
                           value = PopUpMenuSelect( NoAssMenuID, xrect.g_x, xrect.g_y, CurNoAss );        
                           if( value != -1L )
                           {
		             item  = (int)value;
               		     id = (int)( value >> 16L );
                         
              	             if( ( item != -1 ) && ( id == NoAssMenuID ) )
              	             {
		                CheckItem( id, CurNoAss, FALSE );
                  		CheckItem( id, item, TRUE );
                  		CurNoAss = item;
                  		SetStartItem( id, item );
 
				strcpy( NoAssText, NoAssNames[ CurNoAss ] );
				ObString( I9BUTTON ) = NoAssText;
                		Objc_draw( tree, I9BUTTON, MAX_DEPTH, NULL );
              	              }
                            }
                            deselect( tree, I9TITLE );
                         }
                         deselect( tree, I9BUTTON );  
	 		break;
	 			 		
	 default:
	 	        break;		      
      }
             
   }while( !done );

   Form_dial( FMD_FINISH, &rect, &rect );

   Deselect( button );
   return( button == I9CANCEL );
}




/* Do_EAPath()
 * ================================================================
 */
BOOLEAN
Do_EAPath( void )
{
   GRECT   rect;
   GRECT   xrect;
   int     button;
   BOOLEAN done = FALSE;
   MRETS   mk;   
   long    value;
   int     item;
   int     id;
   int     obj;
   char    name[16];
   int     i = 0, j = 0;
   long    length;
   
   ActiveTree( ad_eapath );
   
   strcpy( APathText, APathNames[ CurAPath ] );
   ObString( I10BUT ) = APathText;
   
   if( DriveCount == 1 )
   {
     NoShadow( I10BUT );   
     NoTouchExit( I10BUT );
   }     

   strcpy( AFolder, "FONTGDOS" );
   TedText( I10PATH ) = AFolder;   
   
   Form_center( tree, &rect );
   Form_dial( FMD_START, &rect, &rect );
   Objc_draw( tree, ROOT, MAX_DEPTH, &rect );
   do
   {
      button = form_do( tree, 0 );
      
      if( button & 0x8000 )
          button &= 0x7FFF;      
   
      switch( button )
      {
	 case I10OK:
	 case I10CAN: done = TRUE;
	 		break;

	 case I10BUT:
			 /* If there is only 1 Drive, we skip */
	 		 if( DriveCount == 1 )
	  		       break;
	  		       
	  		 select( tree, I10BUT );
	  	 	 WaitUpButton();
	 		 Graf_mkstate( &mk );
	 		 obj = objc_find( tree, ROOT, MAX_DEPTH, mk.x, mk.y );
			 if( obj == I10BUT )
			 {
	  		   select( tree, I10TITLE );
		           xrect = ObRect( button );
		     	   objc_offset( tree, button, &xrect.g_x, &xrect.g_y );
                           value = PopUpMenuSelect( APathMenuID, xrect.g_x, xrect.g_y, CurAPath );        
                           if( value != -1L )
                           {
		             item  = (int)value;
               		     id = (int)( value >> 16L );
                         
              	             if( ( item != -1 ) && ( id == APathMenuID ) )
              	             {
		                CheckItem( id, CurAPath, FALSE );
                  		CheckItem( id, item, TRUE );
                  		CurAPath = item;
                  		SetStartItem( id, item );
 
				strcpy( APathText, APathNames[ CurAPath ] );
				ObString( I10BUT ) = APathText;
                		Objc_draw( tree, I10BUT, MAX_DEPTH, NULL );
              	              }
                            }
                            deselect( tree, I10TITLE );
                         }
                         deselect( tree, I10BUT );  
	 		break;
	 			 		
	 default:
	 	        break;		      
      }
             
   }while( !done );

   Form_dial( FMD_FINISH, &rect, &rect );

   if( button == I10OK )
   {
     strcpy( AFolder, TedText( I10PATH ) );

     if( AFolder[0] )  	/* Check for no folder name */
     {
      length = strlen( AFolder );
      /* Copy the 8 character filename, stopping if we reach 8 characters,
       * or hit the end of the text string, or hit a ' '.
       */
      for( i = 0; (i < length) && ( i < 8 ) && ( AFolder[i] != ' '); name[j++] = AFolder[i++] );

      /* if we have less than 8 characters, there are blank spaces
       * up to the . mark, so we advance up to there.
       * BTW, there is NO '.', at the most, the folder is 11 characters.
       */
      for( i = i; ( i < length ) && ( i < 8 ) && ( AFolder[i] == ' ' ); i++ );
      
      /* now, put in the '.' */
      if(( i < length ) && AFolder[i] )
          name[j++] = '.';
          
      /* now, copy the extender if there is one...*/    
      for( i = i; i<length; name[j++] = AFolder[i++] );
      name[ j ] = '\0';
     }
     else
     {
      strcpy( AFolder, "FONTGDOS" );
      strcpy( name, "FONTGDOS" );
     }  
     sprintf( adirpath, "%c:\\%s", CurAPath + 'C', name );
   }

   Deselect( button );
   return( button == I10CAN );
}


/* Do_ECPX()
 * ================================================================
 */
BOOLEAN
Do_ECPX( void )
{
    int button;
    int action;
    
    action = Check_CPX();
    if( action )
    {
       ActiveTree( ad_ecpx );
       ObString( I11TITLE ) = ECPXNames[ action ];
       button = execform( tree, 0 );
       Deselect( button );
       return( button == I11CAN );
    }   
    return( FALSE );   
}

/* Do_EFile()
 * ================================================================
 * Checks if the extend.sys file already exists.
 * later on, we'll rename it to extend.old.
 */
BOOLEAN
Do_EFile( void )
{
    int button;
    int flag;
    
    flag = Check_Extend();
    if( flag )
    {
       ActiveTree( ad_efile );
       button = execform( tree, 0 );
       Deselect( button );
       return( button == I12CAN );
    }   
    return( FALSE );   
}


/* Do_EGdos()
 * ================================================================
 * Checks if the GDOS.PRG file already exists.
 * later on, we'll rename it to extend.old.
 */
BOOLEAN
Do_EGdos( void )
{
    int button;
    int flag;
    
    flag = CheckEGdos();
    if( flag )
    {
       ActiveTree( ad_egdos );
       button = execform( tree, 0 );
       Deselect( button );
       return( button == I14CAN );
    }   
    return( FALSE );   
}


/* Do_EGplus()
 * ================================================================
 * Checks if the GPLUS.PRG file already exists.
 * later on, we'll rename it to extend.old.
 */
BOOLEAN
Do_EGplus( void )
{
    int button;
    int flag;
    
    flag = CheckEGplus();
    if( flag )
    {
       ActiveTree( ad_egplus );
       button = execform( tree, 0 );
       Deselect( button );
       return( button == I15CAN );
    }   
    return( FALSE );   
}



/* Do_FGdos()
 * ================================================================
 * Checks if the FONTGDOS.PRG file already exists.
 * later on, we'll rename it to extend.old.
 */
BOOLEAN
Do_EFGdos( void )
{
    int button;
    int flag;
    
    flag = CheckEFGdos();
    if( flag )
    {
       ActiveTree( ad_efgdos );
       button = execform( tree, 0 );
       Deselect( button );
       return( button == I16CAN );
    }   
    return( FALSE );   
}



/* Do_EAFile()
 * ================================================================
 * Checks if the assign.sys file already exists.
 * later on, we'll rename it to assign.old.
 */
BOOLEAN
Do_EAFile( void )
{
    int button;
    int flag;
    
    flag = Check_FAssign();
    if( !flag )
    {
       ActiveTree( ad_eafile );
       button = execform( tree, 0 );
       Deselect( button );
       return( button == I17CAN );
    }   
    return( FALSE );   
}



/* Do_PageOne()
 * ================================================================
 * Prompts if the user wants to install Pageomat
 */
BOOLEAN
Do_PageOne( void )
{
    int button;
    
    PageOneFlag = FALSE;
    
    ActiveTree( ad_pageone );
    button = execform( tree, 0 );
    Deselect( button );
    
    if( button == I18OK )
    {
      if( IsSelected( I18YES ) )
      {
         PageOneFlag = TRUE;
      }
    }    
    return( button == I18CAN );   
}



/* Do_PageTwo()
 * ================================================================
 * Prompts the user to select a drive to install pageomat on.
 */
BOOLEAN
Do_PageTwo( void )
{
   GRECT   rect;
   GRECT   xrect;
   int     button;
   BOOLEAN done = FALSE;
   MRETS   mk;   
   long    value;
   int     item;
   int     id;
   int     obj;
   
   ActiveTree( ad_pagetwo );

   CurPageTwo = CurDrive;
   strcpy( DriveText, DriveNames[ CurPageTwo ] );
   ObString( I19BUTT ) = DriveText;

   if( DriveCount == 1 )
   {
     NoShadow( I19BUTT );   
     NoTouchExit( I19BUTT );
   }     
   
   Form_center( tree, &rect );
   Form_dial( FMD_START, &rect, &rect );
   Objc_draw( tree, ROOT, MAX_DEPTH, &rect );
   do
   {
      button = form_do( tree, 0 );
      
      if( button & 0x8000 )
          button &= 0x7FFF;      
   
      switch( button )
      {
	 case I19OK:
	 case I19CAN: done = TRUE;
	 	      break;

	 case I19BUTT:  /* If there is only 1 Drive, we skip */
	 		 if( DriveCount == 1 )
	  		       break;
	  		       
	  		 select( tree, I19BUTT );
	  	 	 WaitUpButton();
	 		 Graf_mkstate( &mk );
	 		 obj = objc_find( tree, ROOT, MAX_DEPTH, mk.x, mk.y );
			 if( obj == I19BUTT )
			 {
	  		   select( tree, I19TITLE );
		           xrect = ObRect( button );
		     	   objc_offset( tree, button, &xrect.g_x, &xrect.g_y );
                           value = PopUpMenuSelect( DriveMenuID, xrect.g_x, xrect.g_y, CurPageTwo );        
                           if( value != -1L )
                           {
		             item  = (int)value;
               		     id = (int)( value >> 16L );
                         
              	             if( ( item != -1 ) && ( id == DriveMenuID ) )
              	             {
		                CheckItem( id, CurPageTwo, FALSE );
                  		CheckItem( id, item, TRUE );
                  		CurPageTwo = item;
                  		SetStartItem( id, item );
 
				strcpy( DriveText, DriveNames[ CurPageTwo ] );
				ObString( I19BUTT ) = DriveText;
                		Objc_draw( tree, I19BUTT, MAX_DEPTH, NULL );
              	              }
                            }
                            deselect( tree, I19TITLE );
                         }
                         deselect( tree, I19BUTT );  
	 		break;
	 			 		
	 default:
	 	        break;		      
      }
             
   }while( !done );

   Form_dial( FMD_FINISH, &rect, &rect );
   Deselect( button );
   return( button == I19CAN );
}



/* rsrc_init()
 * ================================================================
 */
BOOLEAN
rsrc_init( void )
{
   fix_rsh( NUM_OBS, NUM_FRSTR, NUM_FRIMG, NUM_TREE, rs_object,
            rs_tedinfo, rs_strings, rs_iconblk, rs_bitblk, rs_frstr,
            rs_frimg, rs_trindex, rs_imdope );

   ad_dir     = ( OBJECT *)rs_trindex[ DIRS  ];
   ad_driver  = ( OBJECT *)rs_trindex[ DRIVERS ];
   ad_copy    = ( OBJECT *)rs_trindex[ COPY ];
   ad_assign  = ( OBJECT *)rs_trindex[ CASSIGN ];
   ad_extend  = ( OBJECT *)rs_trindex[ CEXTEND ];
   ad_massign = ( OBJECT *)rs_trindex[ MASSIGN ];

   ad_rename  = ( OBJECT *)rs_trindex[ RENAME ];
   ad_conflict= (OBJECT *)rs_trindex[ CONFLICT];

   ad_edrive  = ( OBJECT *)rs_trindex[ EDRIVE ];
   ad_epath   = ( OBJECT *)rs_trindex[ EPATH ];
   ad_edriver = ( OBJECT *)rs_trindex[ EDRIVER ];
   ad_escreen = ( OBJECT *)rs_trindex[ ESCREEN ];
   ad_epfonts = ( OBJECT *)rs_trindex[ EPFONTS ];
   ad_ecpxacc = ( OBJECT *)rs_trindex[ ECPXACC ];
   ad_emeta   = ( OBJECT *)rs_trindex[ EMETA ];
   ad_eassign = ( OBJECT *)rs_trindex[ EASS ];
   ad_enoassign = ( OBJECT *)rs_trindex[ ENOASS ];
   ad_eapath  = ( OBJECT *)rs_trindex[ EAPATH ];
   ad_ecpx    = ( OBJECT *)rs_trindex[ ECPX ];
   ad_efile   = ( OBJECT *)rs_trindex[ EFILE ];
   ad_egdos   = ( OBJECT *)rs_trindex[ EGDOS ];
   ad_egplus  = ( OBJECT *)rs_trindex[ EGPLUS ];
   ad_efgdos  = ( OBJECT *)rs_trindex[ EFGDOS ];

   ad_entry   = ( OBJECT *)rs_trindex[ ENTRY ];                                                         
   ad_eafile  = ( OBJECT *)rs_trindex[ EAFILE ];
      
   ad_pageone = ( OBJECT *)rs_trindex[ PAGEONE ];
   ad_pagetwo = ( OBJECT *)rs_trindex[ PAGETWO ];
      
   Graf_Mouse( ARROW );
   
   return( TRUE );      
}



/* execform()
 * ================================================================
 * Custom routine to put up a standard dialog box and wait for a key.
 */
int
execform( OBJECT *tree, int start_obj )
{
   GRECT rect;
   int button;
   
   Form_center( tree, &rect );
   Form_dial( FMD_START, &rect, &rect );
   Objc_draw( tree, ROOT, MAX_DEPTH, &rect );
   button = form_do( tree, start_obj );
   Form_dial( FMD_FINISH, &rect, &rect );
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


/* rsrc_exit();
 * ================================================================
 */
void
rsrc_exit( void )
{
  if( data_buffer )
     Mfree( data_buffer );
  data_buffer = 0L;   

  if( DriveMenuID != -1 )
      DeletePopUpMenu( DriveMenuID );
      
  if( DriverMenuID != -1 )   
      DeletePopUpMenu( DriverMenuID );
  
  if( BFontMenuID != -1 )    
      DeletePopUpMenu( BFontMenuID );
  
  if( CPXMenuID != -1 )    
      DeletePopUpMenu( CPXMenuID );
  
  if( MetaMenuID != -1 )
      DeletePopUpMenu( MetaMenuID );
  
  if( AssMenuID != -1 )    
      DeletePopUpMenu( AssMenuID );  

  if( NoAssMenuID != -1 )    
      DeletePopUpMenu( NoAssMenuID );  

  if( APathMenuID != -1 )    
      DeletePopUpMenu( APathMenuID );  

  if( PageTwoID != -1 )
      DeletePopUpMenu( PageTwoID );
}



/* Open_Scanning()
 * ================================================================
 * Displays the dialog box using 'Tree';
 * IN: flag = TRUE  - Display the dialog box.
 *          = FALSE - Generate the Redraw Message
 */
void
Scan_Message( OBJECT *Tree, BOOLEAN flag )
{  
     static GRECT rect;
     static GRECT xrect;
     
     if( flag )
     {
       xrect.g_x = xrect.g_y = 10;
       xrect.g_w = xrect.g_h = 36;
   
       Form_center( Tree, &rect );
       Form_dial( FMD_START, &xrect, &rect );
       Objc_draw( Tree, ROOT, MAX_DEPTH, &rect );
     }
     else
       Form_dial( FMD_FINISH, &xrect, &rect );
}




/* WaitUpButton()
 * ======================================================================
 */
void
WaitUpButton( void )
{
   MRETS mk;

   do
   {
      Graf_mkstate( &mk );
   }while( mk.buttons );
}
