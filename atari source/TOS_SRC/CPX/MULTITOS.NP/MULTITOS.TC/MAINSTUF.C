/* MULTITOS.C
 *==========================================================================
 * DATE: February 5, 1993
 *
 * DESCRIPTION: MULTITOS ON/OFF RENAME SWITCH
 */

 
/* INCLUDE FILES 
 *==========================================================================
 */
#include <sys\gemskel.h>
#include <stdio.h>
#include <tos.h>
#include <string.h >

#include "country.h"

#include "mtos.h"
#include "mtos.rsh"

#include "..\cpxdata.h"




/* DEFINES
 *==========================================================================
 */	
#define E_OK 		0



/* PROTOTYPES
 *==========================================================================
 */
BOOLEAN  cdecl cpx_call( GRECT *rect );
CPXINFO	*cdecl cpx_init( XCPB *Xcpb );
void	open_vwork( void );
void	close_vwork( void );
void	MakeActivator( int xtree, int obj );
void	MakeIndicator( int xtree, int obj );

char	GetBaseDrive( void );
long	GetBootDrive( void );

int	initialize( void );
void	do_rename( int curb, int curc );





/* EXTERNALS
 *==========================================================================
 */



/* GLOBALS
 *==========================================================================
 */			
XCPB *xcpb;
CPXINFO cpxinfo;

int AES_Version;
int gl_ncolors;

/* VDI arrays */
int	contrl[12], intin[128], intout[128], ptsin[128], ptsout[128],
	work_in[12], work_out[57];
int	vhandle=-1;		/* virtual workstation handle */
int	hcnt=0;			/* handle count */

OBJECT *tree;


char OnPath[25] = "C:\\AUTO\\MINT.PRG";
char OffPath[25]= "C:\\AUTO\\MINT.PRX";

char NPOnPath[25] = "C:\\AUTO\\MINTNP.PRG";
char NPOffPath[25]= "C:\\AUTO\\MINTNP.PRX";

char Source[50];
char Destination[50];

char Drive;		/* Current Boot Drive */
int  BootDrive;		/* Boot Device - 0x446; */
DTA  *olddma, newdma;		/* DTA buffers for _our_ searches */

int  bstate;
int  cstate;
int  cur_bstate;
int  cur_cstate;
char temp[30];
int  errno;

#if USA | UK
char nomint[] = "[1][ | MultiTOS is NOT | Available. ][ OK ]";
char NoOn[] = "[1][ | Unable to enable MultiTOS. | Please check your files. ][ OK ]";
char NoWrite[] = "[1][ The disk is write | protected. Unable to enable | MultiTOS ][ OK ]";
char NoWrite2[] = "[1][ The disk is write | protected. Unable to disable | MultiTOS ][ OK ]";
char NoOff[] = "[1][ | Unable to disable MultiTOS. | Please check your files. ][ OK ]";
char RebootText[] = "[1][ Please reboot the system | for this change to take | effect. ][ OK ]";
#endif



#if GERMAN
/*char nomint[] = "[1][ | MultiTOS is NOT | Available. ][ OK ]";*/
char nomint[] = "[1][ | MultiTOS ist NICHT | vorhanden. ][ OK ]";

/*char NoOn[] = "[1][ | Unable to enable MultiTOS. | Please check your files. ][ OK ]";*/
char NoOn[] = "[1][ | MultiTOS l„žt sich nicht | aktivieren. Bitte berprfen | Sie Ihre Dateien. ][ OK ]";

/*char NoWrite[] = "[1][ The disk is write | protected. Unable to enable | MultiTOS ][ OK ]";*/
char NoWrite[] = "[1][ Die Diskette ist schreib- | geschtzt. MultiTOS konnte | nicht aktiviert werden.][ OK ]";

/*char NoWrite2[] = "[1][ The disk is write | protected. Unable to disable | MultiTOS ][ OK ]";*/
char NoWrite2[] = "[1][ Die Diskette ist schreib-| geschtzt. MultiTOS konnte | nicht deaktiviert werden. ][ OK ]";

/*char NoOff[] = "[1][ | Unable to disable MultiTOS. | Please check your files. ][ OK ]";*/
char NoOff[] = "[1][ MultiTOS l„žt sich nicht | deaktivieren. Bitte ber-| prfen Sie Ihre Dateien. ][ OK ]";

/*char RebootText[] = "[1][ Please reboot the system | for this change to take | effect. ][ OK ]";*/
char RebootText[] = "[1][ Damit diese Žnderung in | Kraft tritt mssen Sie Ihr | System neu booten. ][ OK ]";
#endif


#if FRENCH
/*; char nomint[] = "[1][ | MultiTOS is NOT | Available. ][ OK ]"; */
char nomint[] = "[1][ | MultiTOS n'est pas | disponible... ][CONFIRMER]";


/*; char NoOn[] = "[1][ | Unable to enable MultiTOS. | Please check your files. ][ OK ]";*/
char NoOn[] = "[1][ |Impossible d'activer MultiTOS. |V‚rifiez vos fichiers. ][CONFIRMER]";


/*; char NoWrite[] = "[1][ The disk is write | protected. Unable to enable | MultiTOS ][ OK ]";*/
char NoWrite[] = "[1][ Le disque est prot‚g‚| en ‚criture. Impossible| d'activer MultiTOS. ][CONFIRMER]";


/*; char NoWrite2[] = "[1][ The disk is write | protected. Unable to disable | MultiTOS ][ OK ]";*/
char NoWrite2[] = "[1][ Le disque est prot‚g‚| en ‚criture. Impossible| de d‚sactiver MultiTOS. ][CONFIRMER]";


/*; char NoOff[] = "[1][ | Unable to disable MultiTOS. | Please check your files. ][ OK ]";*/
char NoOff[] = "[1][ | Impossible de d‚sactiver | MultiTOS. V‚rifiez vos | fichiers.][CONFIRMER]";


/*; char RebootText[] = "[1][ Please reboot the system | for this change to take | effect. ][ OK ]";*/
char RebootText[] = "[1][ Veuillez relancer le systŠme | pour que les changements | deviennent effectifs. ][CONFIRMER]";

#endif



/* FUNCTIONS
 *==========================================================================
 */
 

/* cpx_init() 
 *==========================================================================
 * Initialize the cpx
 */		
CPXINFO
*cdecl cpx_init( XCPB *Xcpb )
{
    xcpb = Xcpb;
    if( xcpb->booting )
    {
      return( ( CPXINFO *)TRUE );  
    }
    else
    {
      appl_init();
      AES_Version = _GemParBlk.global[0];
    
      if( !xcpb->SkipRshFix )  
             (*xcpb->rsh_fix)( NUM_OBS, NUM_FRSTR, NUM_FRIMG, NUM_TREE,
                              rs_object, rs_tedinfo, rs_strings,
                              rs_iconblk, rs_bitblk, rs_frstr, rs_frimg,
                              rs_trindex, rs_imdope );

      open_vwork();
      close_vwork();
      gl_ncolors = work_out[13];

      if( !xcpb->SkipRshFix )  
      {
        if(( AES_Version >= 0x0330 )
           && ( gl_ncolors > LWHITE ))
        {
           tree  = (OBJECT *)rs_trindex[MAINTREE];
           MakeActivator( MAINTREE, MOK );
           MakeActivator( MAINTREE, MCANCEL );
           MakeIndicator( MAINTREE, SETON );
           MakeIndicator( MAINTREE, SETOFF );
           MakeIndicator( MAINTREE, NPON );
           MakeIndicator( MAINTREE, NPOFF );
        }
      }       

      tree  = (OBJECT *)rs_trindex[MAINTREE];
      if( !initialize() )
          return( ( CPXINFO *)FALSE );
                  
      cpxinfo.cpx_call   = cpx_call;
      cpxinfo.cpx_draw   = NULL;
      cpxinfo.cpx_wmove  = NULL;
      cpxinfo.cpx_timer  = NULL;
      cpxinfo.cpx_key    = NULL;
      cpxinfo.cpx_button = NULL;
      cpxinfo.cpx_m1 	  = NULL;
      cpxinfo.cpx_m2	  = NULL;
      cpxinfo.cpx_hook   = NULL;
      cpxinfo.cpx_close  = NULL;
      return( &cpxinfo );
    }
}




/* cpx_call()
 *==========================================================================
 * Execute the cpx using Xform_do
 */
BOOLEAN
cdecl cpx_call( GRECT *rect )
{
     int button;
     int quit = 0;
     WORD   msg[8];

#if 0
form_alert( 1, nomint );
form_alert( 1, NoOn );
form_alert( 1, NoWrite );
form_alert( 1, NoWrite2 );
form_alert( 1, NoOff );
form_alert( 1, RebootText );
#endif


     tree = ( OBJECT *)rs_trindex[ MAINTREE ];
          
     ObX( ROOT ) = rect->g_x;
     ObY( ROOT ) = rect->g_y;


     Objc_draw( tree, ROOT, MAX_DEPTH, NULL );
     do
     {
	button = (*xcpb->Xform_do)( tree, 0, msg );
     	switch( button )
     	{
     		case MOK:	quit = MOK;
     				Deselect( MOK );
     				cur_bstate = (( IsSelected( SETON ) ) ? ( TRUE ) : ( FALSE ) );
     				cur_cstate = (( IsSelected( NPON ) ) ? ( TRUE ) : ( FALSE ) );
     				if((  bstate != cur_bstate ) || ( cstate != cur_cstate ) )
     				   do_rename( cur_bstate, cur_cstate );
     				break;
     						
     		case MCANCEL:	quit = MCANCEL;
     				Deselect( MCANCEL );
     				break;

     		default:	if( button == -1 )
     				{
     				   switch( msg[0] )
     				   {
     				     case WM_REDRAW:
     				     		     break;
     				     		     
     				     case AC_CLOSE:  quit = MCANCEL;
     				     		     break;
     				     		     
     				     case WM_CLOSED: quit = MCANCEL;
						     break;
     				     default:
     				     		break;
     				   }
     				}
				break;
     		
     	}
     }while( !quit);
     
     return( FALSE );
}






/*
 * Open virtual workstation
 */
void
open_vwork( void )
{
  int i;
  
  if (hcnt == 0) {
  	for (i = 1; i < 10;)
    	work_in[i++] = 1;
  	work_in[0] = Getrez() + 2;
  	work_in[10] = 2;
  	vhandle = xcpb->handle;
  	v_opnvwk(work_in, &vhandle, work_out);
  }
  hcnt++;
}


/*
 * Close virtual workstation
 */
void
close_vwork(void)
{
    hcnt--;
    if( !hcnt )
    {
 	v_clsvwk(vhandle);
	vhandle = -1;
    }
}



void
MakeActivator( int xtree, int obj )
{
   OBJECT *tree;
   
   tree = ( OBJECT *)rs_trindex[ xtree ];
   
   ObFlags( obj ) |= IS3DOBJ;
   ObFlags( obj ) |= IS3DACT;
}



void
MakeIndicator( int xtree, int obj )
{
   OBJECT *tree;
   
   tree = ( OBJECT *)rs_trindex[ xtree ];
   
   ObFlags( obj ) |= IS3DOBJ;
   ObFlags( obj ) &= ~IS3DACT;
}



/* GetBaseDrive()
 * ====================================================================
 * Get the A drive or C drive for the ASSIGN.SYS based upon
 * the boot drive.
 */
char
GetBaseDrive( void )
{
    char Drive;

    Supexec( GetBootDrive );
    Drive = BootDrive + 'A';    
    return( Drive );
}



/* GetBootDrive()
 * ====================================================================
 */
long
GetBootDrive( void )
{
   int *ptr;
   
   ptr = ( int *)0x446L;
   BootDrive = *ptr;
   return( 0L );
}





/* initialize()
 * ====================================================================
 */
int
initialize( void )
{
      int berror;
      int flag;
      
      flag = TRUE;
            
      /* Get the Boot Drive and Muck the paths */
      Drive = GetBaseDrive();
      OnPath[0] = OffPath[0] = Drive;
      NPOnPath[0] = NPOffPath[0] = Drive;
          

      olddma = Fgetdta();	
      Fsetdta( &newdma );		/* Point to OUR buffer */

     berror = Fsfirst( OnPath, 0 );
     if( berror == E_OK )		/* Found it! */
     {
	/* MINT IS ON! with Memory Protection */
	Select( SETON );
	Deselect( SETOFF );
	Select( NPON );
	Deselect( NPOFF );
	bstate = TRUE;
	cstate = TRUE;
     }
     else
     {
        /* Check for No Memory Protection */
        berror = Fsfirst( NPOnPath, 0 );
        if( berror == E_OK )
        {
           /* Found it! It is ON with No Memory Protection */
	   Select( NPOFF );
	   Deselect( NPON );
	   Select( SETON );
	   Deselect( SETOFF );
	   bstate = TRUE;
           cstate = FALSE;
        }
        else
        {
     	   /* Check for Off items */
     
           /* Mint is OFF, with memory protection */
           berror = Fsfirst( OffPath, 0 );
           if( berror == E_OK )		/* Found it! */
           {
             /* MInT.PRX is found! */
             Select( SETOFF );
             Deselect( SETON );
             Select( NPON );
             Deselect( NPOFF );
             bstate = FALSE;
             cstate = TRUE;
           }
           else
           {
              /* Mint is off with no memory protection */
              berror = Fsfirst( NPOffPath, 0 );
              if( berror == E_OK )
              {
                /* MintNP.prx is found */
                Select( SETOFF );
                Deselect( SETON );
                Select( NPOFF );
                Deselect( NPON );
                bstate = FALSE;
                cstate = FALSE;
              }
              else
              {
       	        /* Mint is not on the hard disk...*/
	        form_alert( 1, nomint );
	        flag = FALSE;
	      }  
           }
       }   
     }
     Fsetdta( olddma );		/* Point to OLD buffer */
     return( flag );
}





/* do_rename()
 * ====================================================================
 */
void
do_rename( int curb, int curc )
{
    int berror;
    
    olddma = Fgetdta();	
    Fsetdta( &newdma );		/* Point to OUR buffer */


    /* Get SOURCE */
    if( cstate )	/* Protection On or Off */
    {
        /* Memory Protection */
        if( bstate )
        {
           /* Source is MINT.PRG - Memory Protection */
           strcpy( Source, OnPath );
        }
        else
        {    
           /* Source is MINT.PRX  - Memory Protection */
           strcpy( Source, OffPath );
        }  
    }
    else
    {
        /* No Memory Protection */
        if( bstate )
        {
           /* Source is MINTNP.PRG - No Memory Protection */
           strcpy( Source, NPOnPath );
        }
        else
        {
           /* Source is MINTNP.PRX - No Memory Protection */
           strcpy( Source, NPOffPath );
        }         
  
    }
    


    /* Get Destination - Turn ON or OFF */
    if( curb )
    {
        /* Turn ON MultiTOS */
        /* Get Destination */
        if( curc )
        {
            /* Memory Protection */
            /* Destination is MINT.PRG - Memory Protection */
            strcpy( Destination, OnPath );
        }
        else
        {
            /* No Memory Protection */
            
            /* Destination is MINTNP.PRG - No Memory Protection */
            strcpy( Destination, NPOnPath );
        }
        

	/* Do the Renaming - TURN ON MULTITOS */ 
        berror = Frename( 0, Source, Destination );
        if( berror )
        {
            if( berror == -13 )
               /* write protected */
               form_alert( 1, NoWrite );
            else
            {
               /* Unable to Turn On MultiTOS */
               form_alert( 1, NoOn );
            }
        }
        else
	   form_alert( 1, RebootText );         
    }
    else
    {
        /* Turn Off MultiTOS */
        /* Get Destination */
        if( curc )
        {
            /* Destination is MINT.PRX - Memory Protection */
            strcpy( Destination, OffPath );
        }
        else
        {
            /* Destination is MINTNP.PRX - No Memory Protection */
            strcpy( Destination, NPOffPath );
        }





    	/* Turn Off MultiTOS  - */
        berror = Frename( 0, Source, Destination );
	if( berror )
	{
	     if( berror == -13 )	        /* write protected */
	     	form_alert( 1, NoWrite2 );
	     else
	     {
	        /* Unable to Turn off MultiTOS */
	        form_alert( 1, NoOff );
	     }
	}
	else
	   form_alert( 1, RebootText );         
        
    }
    Fsetdta( olddma );		/* Point to OLD buffer */
}
