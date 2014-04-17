/*  	NEWFSLIB.C	10/27/87 - 01/06/88	Derek Mui		*/
/*	Totally rewritten by Derek Mui					*/
/*	Change fs_input	1/21/88	- 1/22/88	D.Mui			*/
/*	Change at r_dir		1/28/88		D.Mui			*/
/*	Allocate all the memory first	2/10/88		D.Mui		*/
/*	Save the extension always and append to the new dir  2/12/88	*/
/*	Change at r_files		2/23/88	D.Mui			*/
/*	Save the default drive's directory	2/24/88	D.Mui		*/
/*	Save all the drive's default directory	2/29/88	D.Mui		*/
/*	Update 		3/1/88 - 3/2/88			D.Mui		*/
/*	Save and set new clipping rect	3/15/88		D.Mui		*/
/*	Change at fix_path		3/22/88		D.Mui		*/
/*	Optimize at fs_input		3/24/88		D.Mui		*/
/*	Fix at fs_input variable, fs_topptr 4/25/88	D.Mui		*/
/*	Change the unsigned to signed at r_sort 4/27/88 D.Mui		*/
/*	Change fs_input so that CATALOGGER will work	D.Mui		*/
/*	Change to make the underscore disappear	5/17/88	D.Mui		*/
/*	Fix the fs_input for doing cancel	9/5/90	D.Mui		*/
/*	Fix at r_file for checking the extension size 9/5/90	D.Mui	*/
/*	Change gsx_mfset to gr_mrestore			5/8/91	D.Mui	*/
/*	Fix the Ftitle 11 characters problem		6/11/91	D.Mui	*/
/*	Mininum height of slide bar is 1		1/6/92	D.Mui	*/
/*	Use Mxalloc instead of Malloc			3/30/92		*/
/*	Add ini_fsel to adjust drive boxes	7/15/92		D.Mui	*/
/* 	02/17/93	cjg	Converted to Lattice C 5.51		*/
/*	02/24/93	cjg	Force the use of prototypes		*/
/*	07/01/93	cjg	Massive rewrite...			*/

/*	-----------------------------------------------------------
*	AES Version 4.0	MultiTOS version is written by Derek M. Mui
*	Copyright (C) 1992 
*	Atari (U.S.) Corp
*	All Rights Reserved
*	-----------------------------------------------------------
*/	

/*
*	-------------------------------------------------------------
*	GEM Application Environment Services		  Version 1.1
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1985			Digital Research Inc.
*	-------------------------------------------------------------
*/


/* ----------------------------------------------------------------------------
 * INCLUDES
 * ----------------------------------------------------------------------------
 */
#include "pgem.h"
#include "pmisc.h"

#include "machine.h"
#include "objaddr.h"
#include "gemdos.h"
#include "rslib.h"
#include "gemusa.h"
#include "windlib.h"
#include "osbind.h"
#include "mintbind.h"



/* ----------------------------------------------------------------------------
 * DEFINES
 * ----------------------------------------------------------------------------
 */
#define LEN_FSNAME 		16	/* Length of a filename	( 8.3 )	      */
#define NM_NAMES 		9	/* # of filenames displayable	      */
#define DEVICES			26	/* A-Z devices 			      */
#define LPATH			128	/* Length of Directory Path	      */
#define MAX_FSWIDTH		33	/* Width of Abbreviated Path Menu     */
#define MAX_USEDWIDTH		36	/* Width of Used Paths Menu           */
#define MAX_PDELETE_WIDTH	30	/* Width of Remove Path TextBox       */
#define MAX_MULTI_LIMIT   	6	/* Number of Multiple Masks possible  */
#define MAX_USED_PATHS		8	/* Number of Previous Paths to store  */
#define DTA_SIZE		46	/* Size of FSTRUCT		      */
#define D_ATTRIB		21
#define D_TIME			22
#define D_DATE			24
#define D_LENGTH		26
#define D_NAME			30

/* ------------------------------------------------------------
 * DTA structure for files - modified 06/30/93 cjg
 * ------------------------------------------------------------
 */
typedef	struct	fstruct
{
	BYTE	d_reserved[21];		
	BYTE	d_attrib;
	UWORD	d_time;
	UWORD	d_date;
	LONG	d_length;
	BYTE	snames[LEN_FSNAME];
} FSTRUCT;




/* ------------------------------------------------------------
 * PROTOTYPE additions -- 06/30/93 cjg
 * ------------------------------------------------------------
 */
VOID	do_rsort( REG FSTRUCT *buffer, WORD count, WORD mode );
/*VOID	do_rswap( FSTRUCT *buffer, WORD first, WORD second );*/

WORD	FindFSMask( BYTE *textptr );
WORD	CountFolders( BYTE *path );
OBJECT  *MakeFSMenu( WORD NumLevels, WORD width );

VOID	CheckFSPath( VOID );
VOID	StorePath( BYTE *path, BYTE *fname );
VOID	AbbrevPath( BYTE *source, BYTE *dest, WORD width );
VOID	AbbrevMask( BYTE *source, BYTE *dest, WORD width );

WORD	fs_formdo( OBJECT *tree, WORD start_fld );
VOID	CleanFSDirt( OBJECT *dialog_tree, WORD obj, OBJECT *fs_tree );

MLOCAL WORD	DoFullMaskDialog( VOID );
MLOCAL VOID	MaskTailEnd( WORD mn_item );
MLOCAL WORD	BuildFullMask( VOID );
MLOCAL VOID	FullMaskHandler( WORD ClearFnameFlag, UWORD *count );
MLOCAL WORD	ParseFullMask( VOID );
MLOCAL VOID	SetupSelFile( BYTE *fname );
MLOCAL WORD	IsFullMaskEmpty( VOID );

WORD	FindFSFile( BYTE *str, BYTE attrib, WORD count );

WORD	DoSingleMaskDialog( WORD *item );
VOID	SingleMaskDialogHandler( VOID );
VOID	EditMaskViaShiftClick( WORD mn_item );

VOID	fs_infpath( BYTE *buffer );
BYTE	*push_string( REG BYTE *pcurr, REG BYTE *pstring );
WORD	SaveFSelect( BYTE *path );
WORD	ReadFSelect( BYTE *path );
VOID	fs_infscan( BYTE *buffer );
BYTE	*fs_scan_string( REG BYTE *pcurr, REG BYTE *ppstr );

VOID	ForceReadDirectory( VOID );
VOID	RDirCheckPath( VOID );
WORD	RDirReadDirectory( VOID );
VOID	RDirSuccess( VOID );
WORD	RDirFailure( VOID );
VOID	RDirTailEnd( VOID );
VOID	ResetDriveAndMask( VOID );
VOID	SetDriveMenu( VOID );
VOID	SetMaskMenu( VOID );



/* ------------------------------------------------------------
 * GLOBAL additions -- 06/30/93 cjg
 * ------------------------------------------------------------
 */

/* Initial defaults for a ROOT and G_STRING object used for a dynamic popup */
OBJECT  FS_DATA[] = { -1, -1, -1, G_BOX, NONE, SHADOWED, 0xFF1100L, 0, 0, MAX_FSWIDTH, 1,
		      -1, -1, -1, G_STRING, NONE, NORMAL, 0x0L, 0, 0, MAX_FSWIDTH, 1
		    };

/* Defaults for the 20 or so *.3 editable masks */
GLOBAL  BYTE   *DefaultSMasks[] = { "STW",
				    "ACX",
				    "CPZ",
				    "IMG",
				    "GEM",
				    "ICN",
				    "DAT",
				    "RSC",
				    "RSH",
				    "C",
				    "S",
				    "H",
				    "1",
				    "2",
				    "3",
				    "4",
				    "5",
				    "6",
				    "7",
				    "8"
				  };

GLOBAL	OBJECT  *ad_drives;		/* Drives Popup Menu            */
GLOBAL  OBJECT  *ad_sort;		/* Sort Files Popup Menu        */
GLOBAL	OBJECT  *ad_mask;		/* File Extensions Menu         */
GLOBAL  OBJECT  *ad_dpath;		/* Remove Path Dialog Box	*/
GLOBAL  OBJECT  *ad_medit;		/* Edit 3 char Mask dialog	*/
GLOBAL	OBJECT  *ad_fmask;		/* 8.3 Mask Dialog Box		*/
GLOBAL  OBJECT  *ad_edit;		/* edit masks dialog box	*/
GLOBAL	WORD	CurSort;		/* Current Sort Object          */
GLOBAL  WORD	CurMask;		/* Current Mask -fname extension*/
GLOBAL  BYTE    TempPath[ LPATH ];	/* Temporary Path - Can't be malloced */

GLOBAL  BYTE	*BackUpPath;		/* Used to store paths that are 
					 * too long.
					 */
GLOBAL  BYTE	*MaskTemplate;		/* Stores Multiple Mask Template*/
GLOBAL  BYTE	*TitleCopy;		/* Copy fo File Extension	*/


GLOBAL	BYTE 	*ad_back;		/* backup Ptr to FDIRECTO text  */
GLOBAL	OBJECT  *fs_menu;		/* OBJECT tree for dynamic menu */
MLOCAL	MENU    Menu, MData;		/* Popup Menu Data Structures   */
					/* must be MLOCAL, same names are used
					   in the desktop */

GLOBAL  BYTE    UsedPaths[ MAX_USED_PATHS ][ LPATH ];		/* Store the last 8 paths used */
GLOBAL  BYTE	FullMaskText[ MAX_MULTI_LIMIT ][ LEN_FSNAME ];  /* Store 6 8.3 masks.	       */
GLOBAL  BYTE    fsinfpath[] = "C:\\FSELECT.INF";		/* FSELECT filename	       */

EXTERN  WORD	gl_wchar;
EXTERN  WORD	gl_hchar;


MLOCAL  UWORD	botptr, count;
MLOCAL	WORD	curdrv, firstry;
MLOCAL	BYTE	scopy[ LEN_FSNAME ];



/* ------------------------------------------------------------
 * EXISTING GLOBALS and EXTERNS
 * ------------------------------------------------------------
 */
EXTERN  WORD	DOS_AX;
EXTERN	WS	gl_ws;
EXTERN	WORD	q_change;
EXTERN  GRECT	gl_rcenter;
EXTERN  LONG	ad_sysglo;
EXTERN	PD	*currpd;
EXTERN	WORD	gl_button;
EXTERN	WORD	gl_multi;
EXTERN	WORD	wtcolor[];
GLOBAL  GRECT	gl_rfs;

GLOBAL LONG	ad_fstree;
GLOBAL BYTE	*ad_fpath;
GLOBAL LONG	ad_title;
GLOBAL LONG	ad_select;

GLOBAL FSTRUCT	*ad_fsnames;

GLOBAL WORD	fs_first;		/* first enter the file selector */
GLOBAL UWORD	fs_topptr;
GLOBAL UWORD	fs_count;
GLOBAL LONG	fs_fnum;		/* max file allowed	*/

GLOBAL	FSTRUCT *ad_fsdta;		/* cjg 06/24/93 */

GLOBAL BYTE     wildstr[] = "*.*";
GLOBAL BYTE	wslstr[] = "\\*.*";

MLOCAL BYTE	fsname[40];
MLOCAL BYTE	fcopy[40];
MLOCAL BYTE	*pathcopy;		/* path copy	*/
MLOCAL WORD	defdrv;

typedef struct pathstruct
{
	BYTE	pxname[ LPATH ];
} PATHSTRUCT;

GLOBAL PATHSTRUCT *pxpath;	









/* fs_back()
 * ====================================================================
 *	Routine to back off the end of a file string.
 */
	BYTE
*fs_back( pstr )
REG 	BYTE	*pstr;
{
REG	BYTE	*pend;
REG	WORD	i;

	i = strlen( pstr );		/* find the end of string	*/
	pend = pstr + i;
	
	while ( (*pend != '\\') &&
		(pend != pstr) )
	{
	  pend--;
	  if( (*pend == ':') && (pend == pstr+1) )
	    break;
	}
					/* if a : then insert	*/
					/*   a backslash for fsel dir line */
	if ( *pend == ':' )
	{
	  pend++;
	  LBCOPY( pend + 1, pend, i + 1 );
	  *pend = '\\'; 
	}
		
	return(pend);
}






/* fs_input()
 * ====================================================================
 *	File Selector input routine that takes control of the mouse
 *	and keyboard, searchs and sort the directory, draws the file 
 *	selector, interacts with the user to determine a selection
 *	or change of path, and returns to the application with
 *	the selected path, filename, and exit button.
 *	Add the label parameter
 */
	WORD
fs_input( pipath, pisel, pbutton, lstring )
	BYTE		*pipath;
	LONG		pisel;
	WORD		*pbutton;
	BYTE		*lstring;
{
REG	LONG	i,j;
REG	LONG	tree;
	OBJECT	*obj;
	LONG	addr,mul,savedta,savepath;
	UWORD	value;
	WORD	label,last,ret;
	WORD	xoff,yoff,mx,my,bret;
	WORD	savedrv;
	BYTE	dirbuffer[122];
	BYTE	chr;
	LONG	**lgptr;
	GRECT	clip;
	OBJECT	*xtree;
	WORD    newend, oldend;
	LONG	drives;

	WORD	xpos, ypos;		/* x and y pos for popup menus */
	BYTE	*sptr, *dptr;		/* BYTE *ptrs for string funcs */
	WORD	flag;	
	WORD	LevelCount;		/* # of levels in a path       */
	WORD	dummy;
	LONG	size_wanted;		/* LPATH Malloc requirements   */
	WORD	dclick;			/* Double Click flag	       */
	WORD	start_obj;		/* Starting object for edit    */

#if UNLINKED
	state = currpd->p_state;
	if ( state == PS_NEW )			/* if start up sequence	*/
	  currpd->p_state = PS_CRITICAL;	/* then change state	*/
#endif
	wm_update( 3 );
	
	/* -----------------------------------------------------------
	 * Start up the file selector by initializing the fs_tree
	 * -----------------------------------------------------------
	 */
	rs_gaddr(ad_sysglo, R_TREE, SELECTOR, &ad_fstree);
	rs_gaddr(ad_sysglo, R_TREE, DRVTREE, ( LONG *)&ad_drives );
	rs_gaddr(ad_sysglo, R_TREE, SORT, ( LONG *)&ad_sort );
	rs_gaddr(ad_sysglo, R_TREE, MASKTREE, ( LONG *)&ad_mask );
	rs_gaddr(ad_sysglo, R_TREE, PATHDEL, ( LONG *)&ad_dpath );
	rs_gaddr(ad_sysglo, R_TREE, MASKEDIT, ( LONG *)&ad_medit );
	rs_gaddr(ad_sysglo, R_TREE, FULLMASK, ( LONG *)&ad_fmask );
        rs_gaddr(ad_sysglo, R_TREE, EDITTREE, ( LONG *)&ad_edit );
	ob_center(ad_fstree, &gl_rfs);

	gsx_mxmy( &mx, &my );		/* cjg 02/17/93 */

	firstry = TRUE;
	fs_first = TRUE;		/* first enter		*/	
	last = F1NAME;			/* last selected file	*/

	defdrv = (WORD)dos_gdrv();	/* get the default drive*/
	savedrv = defdrv;

	curdrv = defdrv + DRIVEA;


	/* -----------------------------------------------------------
         * Calculate the amount of memory required by the system
	 * for its temporary paths.
	 *    LPATH * ( DEVICES + 2 )   Paths for each device and a backup
         *    LPATH * 2			Double Long Path for BackUp Path
         *				which is used to store the un-
         *				abbreviated path which can include
         *				multiple masks.
         *    LPATH			Path for the MaskTemplate
 	 *    LPATH			File Extension text with buffer.
	 * -----------------------------------------------------------
	 */
	size_wanted = ( LONG )( LPATH * ( DEVICES + 2 ));	/* Save for default drive paths + buffer      */
	size_wanted += ( LONG )( LPATH * 4 );			/* For BackUpPath, MaskTemplate and Titlecopy */


	/* -----------------------------------------------------------
	 * We need to malloc a 2nd buffer which will hold all of the
	 * files.  We default to 256K.  We shouldn't need more than
	 * that.
	 * ERGO, let's just dos_xalloc ONE big happy buffer.
	 * -----------------------------------------------------------
	 */
	mul = ( LONG )dos_xalloc( -1L, 3 );

	if( mul < ( 262144L + size_wanted ) )
	   mul = 0;			/* Not enuf memory...so exit */

	if (mul > 262144L)
	  mul = 262144L;		/* ++ERS 1/19/93 */

					/*	LEN_FSNAMES;	*/
	fs_fnum = mul / (LONG)LEN_FSNAME;	

	if ( ( !mul ) || ( fs_fnum < (LONG)NM_NAMES ) )
	{
	  fm_show( NOMEMORY, 0x0L, 1 );
	  wm_update( 2 );
	  return( FALSE );
	}
	else
	  pxpath = ( PATHSTRUCT *)dos_xalloc( mul + size_wanted, 3 ); 

	/* -----------------------------------------------------------
	 * Since we have only 1 big buffer for the paths, we need
	 * to set the path pointers to their respective areas within
	 * this one buffer.
	 * -----------------------------------------------------------
	 */
	savepath = ( LONG )pxpath;				/* save the address to the buffer*/
	pathcopy = ( BYTE *)savepath;				/* Path copy 			 */
	pxpath = ( PATHSTRUCT *)( savepath + (WORD)LPATH );	/* Device Paths - A-Z		 */

	BackUpPath   = pathcopy + ( LPATH * ( DEVICES + 2 ) );	/* Setup Up BackUp Path 	 */
	MaskTemplate = BackUpPath + ( LPATH * 2 );	 	/* Mask Template buffer 	 */
	TitleCopy    = MaskTemplate + LPATH;			/* Titlecopy buffer     	 */
	ad_fsnames   = ( FSTRUCT *)TitleCopy + LPATH;		/* Get file buffer area		 */


	fm_dial( FMD_START, &gl_rcenter, &gl_rfs );		/* start the File Selector dialog*/

	xtree = obj = ( OBJECT *)ad_fstree;
	tree = ( LONG )ad_fstree;
	
	lgptr = ( LONG **)OB_SPEC( FDIRECTO );			/* change the buffer pointer     */
	**lgptr = ( LONG )dirbuffer;


	fs_sset( tree, FLABEL, ( LONG )lstring, &addr, ( WORD *)&addr );
	fs_sset( tree, FDIRECTO, ( LONG)"", ( LONG *)&ad_fpath, ( WORD *)&addr ); 
	fs_sset( tree, FTITLE, ( LONG )"", &ad_title, ( WORD*)&addr );
	fs_sset( tree, FSELECTI, ( LONG )"", &ad_select, ( WORD *)&addr );

						/* get the current drive */
	drives = isdrive();
	j = 1;
						/* start from A drive	*/
						/* set the button	*/



	/* -------------------------------------------------------------
	 * Set up the Drive Menu and Button 
	 * -------------------------------------------------------------
	 */
	 for( i = DRIVEA; i <= DRIVEZ; i++ ) {	/* CJG use A-Z		*/
	    if ( drives & j )			/* drive present	*/
	      ad_drives[i].ob_state &= ~DISABLED;
	    else
	      ad_drives[i].ob_state |= DISABLED;

	    j = j << 1;
	 }


	/* -------------------------------------------------------------
	 * Setup a DEFAULT for the Current Mask Variable.
	 * We set it to *.* because the first pass will do a rdir()
	 * and it needs to be set to something other than multiple
	 * mask wildcards.
	 * The WILDCARD during a read is actually within the ad_title
  	 * variable already.  CurMask is set by SetMaskMenu() 
	 * which is called AFTER we force a read.
	 * -------------------------------------------------------------
	 */
        CurMask = MASK_BEG;			/* Set to '*.*'  */


	/* -------------------------------------------------------------
	 * Set up the File Sort Menu and Button
	 * -------------------------------------------------------------
	 */
	 for( i = SORTNAME; i <= SORTNONE; i++ )
             ad_sort[i].ob_state &= ~CHECKED;
	 ad_sort[ CurSort ].ob_state |= CHECKED;

	 sptr = ( BYTE *)ad_sort[ CurSort ].ob_spec;
	 obj[ SBUTTON ].ob_spec = ( LONG )( sptr + 2 );	
	 ob_draw( ( LONG )obj, SBUTTON, MAX_DEPTH );




	/* -------------------------------------------------------------
	 * Clean up the Files and Names displayed
	 * -------------------------------------------------------------
	 */
	label = F1NAME;				/* clean up the files 	*/

	for ( i = 0; i < NM_NAMES; i++ )	/* clean up fields	*/
	{
	  fs_sset( tree, label, ( LONG )" ", &addr, ( WORD *)&addr );
	  LWSET( OB_STATE( label++ ), NORMAL );
	}

						
	savedta = Fgetdta( );			/* save the current dta	*/

	gsx_gclip( &clip );			/* get the clipping rect*/
						/* set the new one	*/
	gsx_sclip( &gl_rfs );
						/* reset the height	*/
	LWSET( OB_Y( FSVELEV ), 0 );	
	LWSET( OB_HEIGHT( FSVELEV ), LWGET( OB_HEIGHT( FSVSLID ) ) );


	/* -------------------------------------------------------------
	 * Set element colors to the appropriate window part colors
	 * -------------------------------------------------------------
	 */
	((TEDINFO *)obj[FTITLE].ob_spec)->te_color = (UWORD)wtcolor[W_NAME];
	obj[FCLSBOX].ob_spec &= 0xFFFF0000L;
	obj[FCLSBOX].ob_spec |= (UWORD)wtcolor[W_CLOSER];
	obj[FDNAROW].ob_spec &= 0xFFFF0000L;
	obj[FDNAROW].ob_spec |= (UWORD)wtcolor[W_DNARROW];
	obj[FUPAROW].ob_spec &= 0xFFFF0000L;
	obj[FUPAROW].ob_spec |= (UWORD)wtcolor[W_UPARROW];
	obj[FSVSLID].ob_spec &= 0xFFFF0000L;
	obj[FSVSLID].ob_spec |= (UWORD)wtcolor[W_VSLIDE];
	obj[FSVELEV].ob_spec &= 0xFFFF0000L;
	obj[FSVELEV].ob_spec |= (UWORD)wtcolor[W_VELEV];

	((TEDINFO *)ad_edit[PTITLE1].ob_spec)->te_color = (UWORD)wtcolor[W_NAME];
	((TEDINFO *)ad_edit[PTITLE2].ob_spec)->te_color = (UWORD)wtcolor[W_NAME];

	gr_mouse( 258, 0x0L );
	gr_mouse( 0, 0x0L );


	ob_draw( tree, 0, MAX_DEPTH );		/* draw the file selector*/

	fmt_str( ( BYTE *)pisel, scopy );	/* format FILENAME	 */		

	strcpy( pipath, ad_fpath );		/* setup main path 	 */

	pathcopy[0] = defdrv + 'A';		/* Backup path		 */
	pathcopy[1] = ':';
	strcpy( wslstr, &pathcopy[2] );


	count     = 0;			/* set # of files to display 	       */
	fs_topptr = 0;			/* Set index of top file to display    */
	botptr    = 0;			/* Set index of bottom file to display */

	ret       = 0;			/* initial action  	       */
	bret      = 0;			
	start_obj = FSELECTI;		/* Initial editable text field */
	dclick    = FALSE;		/* Clear double click flag     */


	/* -------------------------------------------------------------
	 * Check if we have an 8.3 mask. If so, we really need to
	 * force it into the Multiple mask area.
	 * if we have a standard *.3 mask, then just do a ForceReadDirectory
	 * -------------------------------------------------------------
	 */
	 RDirCheckPath();				   /* Validate the path 	      */

         strcpy( fs_back( ad_fpath ) + 1, TempPath );	   /* Copy off the file extension     */

         if( TempPath[0] && ( TempPath[0] != '*') && ( TempPath[1] != '.' ) ) {
            /* We have a 8.3 mask for a pattern. and need to add it to FullMaskText */
	    CurMask = MSPECIAL;

   	    for( i = 0; i < MAX_MULTI_LIMIT; i++ ) {  /* Go Through the 8.3 text strings*/

		if( strcmp( FullMaskText[i], TempPath )) /* If its already there..break out */
		   break;

               if( !FullMaskText[i][0] ) {
 	          strcpy( TempPath, FullMaskText[i] );
		  break;
	       }

	       if( strcmp( "*.*", FullMaskText[i] ) ) {  /* If we find *.*, replace it there...*/
 	          strcpy( TempPath, FullMaskText[i] );
		  break;
	       }
            }

	    if( i >= MAX_MULTI_LIMIT )			/* We couldn't find an empty slot     */
 	       strcpy( TempPath, FullMaskText[i] );	/* So shove it into the first position*/     

            BuildFullMask();	     			/* Build the mask string 	      */
	    strcpy( "[?]", ( BYTE *)ad_title );
	    FullMaskHandler( FALSE, &count );	    
	 }
	 else
	    ForceReadDirectory();


	/* -------------------------------------------------------------
	 * MAIN LOOP for File Selector FormDO routines
	 * -------------------------------------------------------------
	 */
	do  
        {
	  value = 1;				/* scroll factor	*/

	  switch ( ret )
	  {


	    /* --------------------------------------------------------------
	     * Vertical Slider
	     * --------------------------------------------------------------
	     */
	    case FSVSLID:
	      ob_offset( tree, FSVELEV, &xoff, &yoff );
	      value = NM_NAMES;
	      if ( my < yoff )
		goto up;
	      else if (my >= yoff + xtree[FSVELEV].ob_height)
	        goto down;
	      /* else fall through */



	    /* --------------------------------------------------------------
	     * Vertical Elevator
	     * --------------------------------------------------------------
	     */
	    case FSVELEV:
	      if( !( xtree[ FSVELEV ].ob_state & SELECTED ))
		FXSelect( xtree, FSVELEV );
              gsx_sclip( &gl_rfs );

	      wm_update( 3 );
	      value = gr_slidebox( tree, FSVSLID, FSVELEV, TRUE );
	      wm_update( 2 );

	      if ( count > NM_NAMES )
	      {	
	        mul = ((LONG)( count - NM_NAMES )) * (LONG)(value);
	        if ( fs_topptr != ( mul / 1000 ) )
	        {
		  fs_topptr = ( UWORD )( mul / 1000 );
	          r_sfiles( fs_topptr, value );
	        }
	      }
	      
	      goto out;



	    /* --------------------------------------------------------------
	     * Down Arrow Handling
	     * --------------------------------------------------------------
	     */
down:	    case FDNAROW:			/* scroll down	*/
	      if ( fs_topptr >= botptr )
	      {
out:		FXWait();
		if( ret != FSVSLID) {
	          FXDeselect( xtree, ret );
                  gsx_sclip( &gl_rfs );
		}
		break;
	      }

	      if ( (fs_topptr + value) <= botptr )
	        fs_topptr += value;
	      else
		fs_topptr = botptr;

	      goto sfiles;


	    /* --------------------------------------------------------------
	     * Up Arrow Handling
	     * --------------------------------------------------------------
	     */
up:	    case FUPAROW:			/* scroll up	*/
	      if ( !fs_topptr )
	      {
		goto out;
	      }
	      if ( (WORD)(fs_topptr - value) >= 0 )
	        fs_topptr -= value;
	      else
		fs_topptr = 0;

sfiles:	      
	      if( !( xtree[ ret ].ob_state & SELECTED ) && ret != FSVSLID )
		FXSelect( xtree, ret );

              gsx_sclip( &gl_rfs );

	      r_sfiles( fs_topptr, value );

	      if( gl_button )
		  continue;
	      
	      FXWait();
	      if (ret != FSVSLID) {
	        FXDeselect( xtree, ret );
	        gsx_sclip( &gl_rfs );
	      }
	      break;


	    /* ------------------------------------------------------------------
	     * CLOSE BOX Button Handling
	     * ------------------------------------------------------------------
	     */
	    case FCLSBOX:	
	         oldend = strlen( ad_fpath );	/* find # char in string*/

	         if( !( xtree[ FCLSBOX ].ob_state & SELECTED ))
		      FXSelect( xtree, FCLSBOX );
	         gsx_sclip( &gl_rfs );

	         *( fs_back( ad_fpath ) ) = 0;		   /* back to last path	*/
	         strcpy( "*.", fs_back( ad_fpath ) + 1 );  /* CJG 06/30/93 -- pts to editable field now */
	         strcat( ( BYTE *)ad_title, ad_fpath );		

	         if( CurMask == MSPECIAL ) {
		     FullMaskHandler( TRUE, &count );
	         }
	         else
		     ForceReadDirectory();


	         newend = strlen( ad_fpath );	/* find # char in string*/

	         if( newend != oldend ) {	        /*  is dir changed ?	*/

	            if( !( xtree[ FCLSBOX ].ob_state & SELECTED )) 
		           FXSelect( xtree, FCLSBOX );
	            gsx_sclip( &gl_rfs );
	         }
	         else {
		    FXWait();	/* Hasn't changed, wait arnd*/
		    FXDeselect( xtree, FCLSBOX );
	            gsx_sclip( &gl_rfs );
		    break;
	         }

		 if( !gl_button ) {
		    FXWait();
		    FXDeselect( xtree, FCLSBOX );
		    gsx_sclip( &gl_rfs );
		 }
	         else
		    continue;
	      break;
	

	    /* ------------------------------------------------------------------
	     * Force the Reading of the Directory
	     * Note that it is called when the FS first opens up.
	     * ------------------------------------------------------------------
	     */
	    case FLABEL:
	       ForceReadDirectory();
	       break;


	    /* --------------------------------------------------------------
	     * Disk Drive PopUp Handler
	     * --------------------------------------------------------------
	     */
	    case DBUTTON:
		 FXSelect( obj, DBUTTON );
		 gsx_sclip( &gl_rfs );

		 ad_drives[ DRIVE00 ].ob_state |= ( SELECTED | DISABLED );
	 	 ob_offset( ( LONG )obj, DBUTTON, &xpos, &ypos );

     		 Menu.mn_tree   = ad_drives;
		 Menu.mn_menu   = ROOT;
		 Menu.mn_item   = DRIVE00;
		 Menu.mn_scroll = 0;
     		 flag = mn_popup( currpd->p_pid, &Menu, xpos, ypos, &MData );
		 if( flag ) {
	            if( ( ad_drives == MData.mn_tree ) &&
            		( MData.mn_menu == DRVBOX ) && ( curdrv != MData.mn_item ) ) {
			curdrv  = MData.mn_item;

			strcpy( ad_fpath, pathcopy );	/* copy current dir    */

		        i = ( curdrv - DRIVEA );	/* get the drive       */
	      	        *ad_fpath = (BYTE)( i + 'A' );	/* stuff into the path */
	      		*( ad_fpath + 1 ) = ':';
			*( ad_fpath + 2 ) = '\0';

			sptr = ( BYTE *)ad_drives[ DRIVE00 ].ob_spec;		/* ?: */
	 		*( sptr + 2 ) = *ad_fpath;

			sptr = ( BYTE *)obj[ DBUTTON ].ob_spec;		/* Set Drive ?: */
			*( sptr + strlen( sptr ) - 2 ) = *ad_fpath;

	      		if ( !dos_gdir( i + 1, ( LONG )(ad_fpath + 2) ) ) {
			   /* SUCCESS - FORCE A NEW READ WITH THE NEW DRIVE AND PATH */
			   if( CurMask != MSPECIAL ) {
								 /* SUCCESS		  */
			       strcat( &fsname[0], ad_fpath );   /* Append the Mask       */
			       ForceReadDirectory();
			   }
			   else {
								 /* SUCCESS		  */
			       strcat( "\\", ad_fpath );	 /* Add in the '\\'	  */
		    	       strcat( MaskTemplate, ad_fpath ); /* Restore the masks	  */
		    	       FullMaskHandler( TRUE, &count );  /* Handle Multiple Masks */
			   }
			}
	      		else {
			
			   /* SINCE the Get Directory failed for whatever reason, we
			    * need to stay where we were and restore the path.
			    */
			   if( CurMask != MSPECIAL ) {
			       firstry = TRUE;			/* FAILURE - handle single masks */
			       RDirFailure();
			       ForceReadDirectory();
			   } 
			   else {
			      strcpy( pathcopy, ad_fpath );     /* FAILURE - handle multiple masks */
			      FullMaskHandler( TRUE, &count );
			   }
			}

		    }
		 }
		 FXDeselect( obj, DBUTTON );
		 gsx_sclip( &gl_rfs );
		 break;


	    /* --------------------------------------------------------------
	     * File Extension Editable Text Field
	     * --------------------------------------------------------------
	     */
	    case FTITLE:
		 if( dclick )			/* Double Click! 	   */
		   SingleMaskDialogHandler();	/* display Mask Dialog Box */
		 else
		   start_obj = FTITLE;
		 break;



	    /* --------------------------------------------------------------
	     * File Extensions PopUp Handler
	     * --------------------------------------------------------------
	     */
	    case EBUTTON2:
	    case EBUTTON:

		 FXSelect( obj, EBUTTON );
		 gsx_sclip( &gl_rfs );

	 	 ob_offset( ( LONG )obj, EBUTTON, &xpos, &ypos );
		 ypos += obj[ EBUTTON ].ob_height + 2;

     		 Menu.mn_tree   = ad_mask;
		 Menu.mn_menu   = ROOT;
		 Menu.mn_item   = CurMask;
		 Menu.mn_scroll = -1;
     		 flag = mn_popup( currpd->p_pid, &Menu, xpos, ypos, &MData );

		 FXDeselect( obj, EBUTTON );
		 gsx_sclip( &gl_rfs );

		 if( flag ) {
	            if( ( ad_mask == MData.mn_tree ) &&
            		( MData.mn_menu == MASKBOX ) ) {


			/* ------------------------------------------------
			 * Do Edit Masks Dialog Box. This dialog box also
			 * allows the user to edit multiple masks also.
			 * ------------------------------------------------
			 */
		        if( MData.mn_item == MSKEDIT ) {
			   SingleMaskDialogHandler();
			   break;			
			}


			
			/* ------------------------------------------------
			 * Edit single *.3 mask via Shift-Click
			 * ------------------------------------------------
			 */
			if( MData.mn_keystate & ( K_LSHIFT | K_RSHIFT  ) ) {
			    EditMaskViaShiftClick( MData.mn_item );
			    break;
			}


			/* ------------------------------------------------
			 * The user clicked on a menu item, so Mask Tailend
			 * will handle it by clearing the old check mark
			 * and setting the new one.
			 * The Multiple Mask Dialog box will come up
			 * also on certain occasions.
			 * They are: 1 ) Shift_Click - Always appear
			 *           2) If empty, display it.
			 * ------------------------------------------------
			 */				
			if( ( CurMask != MData.mn_item ) || ( MData.mn_item == MSPECIAL ) ) {

			   if( MData.mn_item == MSPECIAL ) {

			       if( ( CurMask == MData.mn_item ) ||
				   (( CurMask != MData.mn_item ) && 
				    ( IsFullMaskEmpty() ))
				 ) {
			           if( !DoFullMaskDialog())		/* Display Multiple Mask Dialog box */
				       break;				/* If cancel, just exit             */
	   			   SaveFSelect( TempPath );		/* Save Out to DISK FSELECT.INF	    */
			       }
			       else
			         BuildFullMask();			/* Build the mask string instead.   */
			   }

			   MaskTailEnd( MData.mn_item );
			}
	 	    }
		 }
		 break;


	    /* --------------------------------------------------------------
	     * Sort Files PopUp Handler
	     * --------------------------------------------------------------
	     */
	    case SBUTTON:
		 FXSelect( obj, SBUTTON );
		 gsx_sclip( &gl_rfs );

	 	 ob_offset( ( LONG )obj, SBUTTON, &xpos, &ypos );

     		 Menu.mn_tree   = ad_sort;
		 Menu.mn_menu   = ROOT;
		 Menu.mn_item   = CurSort;
		 Menu.mn_scroll = 0;

     		 flag = mn_popup( currpd->p_pid, &Menu, xpos, ypos, &MData );

	         if( flag && ( ad_sort == MData.mn_tree ) &&
            	     ( MData.mn_menu == SORTBOX ) &&
		     ( CurSort != MData.mn_item ) ) {
			
			ad_sort[ CurSort ].ob_state &= ~CHECKED;
			ad_sort[ MData.mn_item ].ob_state |= CHECKED;
			CurSort  = MData.mn_item;

			sptr = ( BYTE *)ad_sort[ CurSort ].ob_spec;
			obj[ SBUTTON ].ob_spec = ( LONG )( sptr + 2 );	

			if( CurMask != MSPECIAL ) 		/* If Not Special Mask, process it normally */
			    ForceReadDirectory();			    
			else
			    FullMaskHandler( TRUE, &count );	/* Multi Mask Handler */
		 }
		 FXDeselect( obj, SBUTTON );
		 gsx_sclip( &gl_rfs );
		 break;




	    /* --------------------------------------------------------------
	     * Previous Path Selection Popup Menu Handler
	     * --------------------------------------------------------------
	     */
	    case PBUTTON:
		     FXSelect( obj, PBUTTON );
		     gsx_sclip( &gl_rfs );

		     fs_menu = MakeFSMenu( MAX_USED_PATHS, MAX_USEDWIDTH );
		     if( !fs_menu ) {		
		        FXDeselect( obj, PBUTTON );
		        gsx_sclip( &gl_rfs );

			fm_show( NOMENU, 0x0L, 1 );
			break;
		     }

		     /* ---------------------------------------------------
		      * Copy the Paths over from storage to display.
		      * shortening them if necessary.
		      * Disable the menu items not being used. 
		      * ---------------------------------------------------
		      */
		     for( i = 1; i <= MAX_USED_PATHS; i++ ) {
			if( UsedPaths[i-1][0] == '\0' )	 {  				/* If empty */
		            fs_menu[ i ].ob_state |= DISABLED;
			    *( BYTE *)fs_menu[i].ob_spec = '\0';
			}
			else {
		          strcpy( "  ", ( BYTE *)fs_menu[i].ob_spec );		/* 2 blanks preceding   */
			  AbbrevPath( UsedPaths[ i - 1 ], ( BYTE *)fs_menu[i].ob_spec + 2, MAX_USEDWIDTH - 2 );	
			}
		     }

	 	     ob_offset( ( LONG )obj, FDIRECTO, &xpos, &dummy );
	 	     ob_offset( ( LONG )obj, PBUTTON, &dummy, &ypos );
		     ypos += obj[ PBUTTON ].ob_height + 1;
		     xpos = (( xpos + 7 )/ 8 ) * 8;
		
	
     		     Menu.mn_tree   = fs_menu;
		     Menu.mn_menu   = ROOT;
		     Menu.mn_item   = 1;
		     Menu.mn_scroll = 0;

     		     flag = mn_popup( currpd->p_pid, &Menu, xpos, ypos, &MData );

	             if( flag && ( fs_menu == MData.mn_tree ) &&
            		 ( MData.mn_menu == ROOT ) ) {

			    /* Remove Entry? or set Paths? */
			    if( MData.mn_keystate & K_CTRL ) {
			
				/* Prompt if they want to remove this entry...*/
				sptr = ( BYTE *)( ( TEDINFO *)ad_dpath[ PDELITEM ].ob_spec )->te_ptext;
			        AbbrevPath( UsedPaths[ MData.mn_item - 1 ], sptr, MAX_PDELETE_WIDTH );	
				
				flag = fs_formdo( ad_dpath, 0 );

				CleanFSDirt( ad_dpath, ROOT, ( OBJECT *)tree );

				if( flag == PDELOK ) {		/* Remove this entry! */
				   for( i = ( MData.mn_item - 1 ); i < ( MAX_USED_PATHS - 1 ); i++ ) {
				      strcpy( UsedPaths[ i + 1 ], UsedPaths[ i ] );
				   }
				   UsedPaths[ MAX_USED_PATHS - 1 ][0] = '\0';
				   SaveFSelect( TempPath );		/* Save Out to DISK FSELECT.INF	*/
			        }
				flag = FALSE;
			    }
			    else {

			        strcpy( ad_fpath, pathcopy );	/* copy current dir	*/

			        /* Need to break up the path string returned into
			         * filename and path with mask.
			         */
			        strcpy( ( BYTE *)UsedPaths[ MData.mn_item - 1 ], TempPath );

			        sptr = dptr = fs_back( TempPath );     /* Get pointer to path	        */
			        sptr = scasb( sptr, '.' );	       /* Need to get the file mask '.' */
		                fmt_str( dptr + 1, scopy );	       /* Get filename w/o the '.'      */
			        fs_first = TRUE;		       /* Global FLAG so filename is not
								        * erased during rdir
								        */
			
			    	*( fs_back( TempPath ) + 1 ) = '\0';   /* NULL path w/o filename     */
			    	strcat( "*.", TempPath );	       /* Add in wild card beginning */
    
			    	if( *sptr )
			      	   strcat( sptr + 1, TempPath );       /* Extract the mask	     */
			        else
			           strcat( "*", TempPath );	       /* No wildcard, so *.* 	     */			
			    	strcpy( TempPath, ( BYTE *)ad_fpath ); /* Get path 		     */
			   }
		     }

		     if( fs_menu )
		        dos_free( ( LONG )fs_menu );

		     FXDeselect( obj, PBUTTON );
		     gsx_sclip( &gl_rfs );

		     if( flag ) {		  	        /* if the user clicked on something valid, let's go there...*/
			if( CurMask != MSPECIAL ) {		/* If Not Special Mask, process it normally */

			    firstry = TRUE;
			    gr_mouse( 0, 0x0L );		/* Force ARROW */
			    ForceReadDirectory();			    
			}
			else {		
			     strcpy( scopy, ( BYTE *)ad_select );  /* Copy over to ad_select -the function uses it */
			     FullMaskHandler( FALSE, &count );
			}
		     }
		 break;


	    /* --------------------------------------------------------------
	     * Directory PopUp Handler
	     * --------------------------------------------------------------
	     */
	    case FDIRECT2:
	    case FDIRECTO:

		 strcpy( ad_fpath, TempPath );
		 LevelCount = CountFolders( TempPath );

		 if( LevelCount > 1 ) {
		     
		     
		     fs_menu = MakeFSMenu( (( LevelCount < INIT_LIST_HEIGHT ) ?
					   ( INIT_LIST_HEIGHT ) : ( LevelCount ) ),
					   MAX_FSWIDTH );

		     if( !fs_menu ) {			/* Not enuf memory */
			fm_show( NOMENU, 0x0L, 1 );
			break;
		     }


		     /* ---------------------------------------------------
		      * Disable the menu items not being used. Especially
		      * if the height of the menu is < 8.
		      * ---------------------------------------------------
		      */
		      if( LevelCount < INIT_LIST_HEIGHT ) {
			 for( i = ( LevelCount + 1 ); i <= INIT_LIST_HEIGHT; i++ )
			    fs_menu[ i ].ob_state |= DISABLED;
		      }

		     /* ---------------------------------------------------
		      * BUILD the menu strings by breaking up the path
		      * into its respective components.
		      * ---------------------------------------------------
		      */

		     strcpy( ad_fpath, TempPath );
		     sptr = fs_back( TempPath );	/* Remove the wildcard */
		     *sptr  = '\0';

		     i = 1;
		     do {
			sptr = fs_back( TempPath );
			if( sptr ) {
			  dptr = ( BYTE *)fs_menu[ i ].ob_spec;
		          strcpy( ( sptr + 1 ), ( dptr + 2 ) );
			  strcat( "\\", dptr );
			  *( sptr ) = '\0';
			  i++;
			}
		     }while( *( sptr - 1 ) != ':' );

		     /* don't forget the ROOT -------------*/
  		     dptr = ( BYTE *)fs_menu[ i++ ].ob_spec;
		     strcpy( "  \\", dptr );

		     fs_menu[ 1 ].ob_state |= CHECKED;



		    /* ---------------------------------------------------
		     * Setup the Drop-Down List menu and prepare to show it.
		     * ---------------------------------------------------
		     */
		     FXSelect( obj, FDIRECTO );
		     gsx_sclip( &gl_rfs );

	 	     ob_offset( ( LONG )obj, FDIRECTO, &xpos, &ypos );
		     ypos += obj[ FDIRECTO ].ob_height + 1;
		     xpos = (( xpos + 7 )/ 8 ) * 8;
			
     		     Menu.mn_tree   = fs_menu;
		     Menu.mn_menu   = ROOT;
		     Menu.mn_item   = 1;
		     Menu.mn_scroll = -1;

     		     flag = mn_popup( currpd->p_pid, &Menu, xpos, ypos, &MData );
		
		     if( flag ) {

	                if( ( fs_menu == MData.mn_tree ) &&
            		    ( MData.mn_menu == ROOT ) && ( MData.mn_item != 1 ) ) {

			    /* Need to build a new path */
			    *( ad_fpath + 2 ) = '\0';

			    for( i = LevelCount; i >= MData.mn_item; i-- ) {
				sptr = ( BYTE *)fs_menu[ i ].ob_spec;
			        strcat( sptr + 2, ad_fpath );
			    }
	
			    /* Now, tack on the file extension */
			    strcat( "*.", ad_fpath );			/* Tack on *. first...*/
			    strcat( ( BYTE *)ad_title , ad_fpath );
			}
			else
			  flag = FALSE;	  /* If we clicked on '1', meaning same path, don't force read */
		     }

		     if( fs_menu )
		       dos_free( ( LONG )fs_menu );
		
		     FXDeselect( obj, FDIRECTO );
		     gsx_sclip( &gl_rfs );

		     if( flag ) {	    /* if the user clicked on something valid, let's go there...*/
		
			if( CurMask != MSPECIAL )
			   ForceReadDirectory();
			else
			   FullMaskHandler( TRUE, &count );
		     }	
		 }
		 break;


	    /* --------------------------------------------------------------
	     * Directory and FileName String Object Handling
	     * --------------------------------------------------------------
	     */
	    case F1NAME:
	    case F2NAME:
	    case F3NAME:
	    case F4NAME:
	    case F5NAME:
            case F6NAME:
	    case F7NAME:
	    case F8NAME:
	    case F9NAME:
	      i = ret - F1NAME;
	      addr = ( LONG )&ad_fsnames[i + fs_topptr].snames[1];
	      chr = ad_fsnames[i + fs_topptr].snames[0];

						
	      if ( chr == 7 )  		/* is it a directory ?  */
	      {
		 if( CurMask != MSPECIAL ) {	/* Check if we're multiple masks */
						/* NO, so treat normally	 */

		    unfmt_str( ( BYTE *)addr, fs_back( ad_fpath ) + 1 );
		    strcat( &fsname[0], ad_fpath );
		    ForceReadDirectory();
		 }
		 else {

		    /* We've got potentially multiple masks. so...*/
		    unfmt_str( ( BYTE *)addr, fs_back( ad_fpath ) + 1 ); /* Add in the new directory     */
		    strcat( "\\", ad_fpath );				/* Add in the '\\'		*/
		    strcat( MaskTemplate, ad_fpath );			/* Restore the masks		*/
		    FullMaskHandler( TRUE, &count );
		}

	      }
	      else  				/* must be a file	*/
	        if ( chr )
	        {				/* clean up the last selected */
		  ob_change( tree, last, NORMAL, TRUE );
		  strcpy( ( BYTE *)addr, ( BYTE *)LLGET( LLGET(OB_SPEC(FSELECTI)) ));
		  ob_change( tree, ret, SELECTED, TRUE );		  
		  ob_draw( tree, FSELECTI, MAX_DEPTH );
		  last = ret;
		  if ( bret & 0x8000 )		/* double click		*/ 
		  {
		    ob_change( tree, OK, SELECTED, TRUE );
		    ret = OK;			/* cjg 07/01/93         */
		    goto fdone;			/* force to exit	*/

		  }
	        }

	      break;

	      default:
	        break;  
	  }					/* end of switch	*/

	  bret = fm_do( tree, start_obj );

	  gsx_mxmy( &mx, &my );

	  dclick = bret & 0x8000;		/* Check for double clicks */
	  ret = bret & 0x7FFF;
	  start_obj = FSELECTI;

	  if ( ret == CANCEL )
	    break;


	  if( !strcmp( ( BYTE *)ad_title, TitleCopy ) ) {  /* Has the file extension changed? */

	    if( *( BYTE *)ad_title == '\0' )		   /* If the extension is blank, then */
		strcpy( TitleCopy, ( BYTE *)ad_title );    /* restore the extension copy      */

	    ob_change( tree, ret, NORMAL, TRUE );

	    if( strcmp( ( BYTE *)ad_title, "[?]" )) {	   /* If multiple Mask mode...        */
		BuildFullMask();
		ret = 0;
		MaskTailEnd( MSPECIAL );
		continue;
	    }
	    else {

		/* -------------------------------------------------------------
		 * Setup a DEFAULT for the Current Mask Variable.
		 * We set it to *.* because the first pass will do a rdir()
		 * and it needs to be set to something other than multiple
		 * mask wildcards.
		 * The WILDCARD during a read is actually within the ad_title
	  	 * variable already.  CurMask is set by SetMaskMenu() 
		 * which is called AFTER we force a read.
	         * -------------------------------------------------------------
	         */
	       CurMask = MASK_BEG;			/* Set to '*.*'  */

	       strcpy( "*.", fs_back( ad_fpath ) + 1 );	/* Need to copy *. and then XXX */
	       strcat( ( BYTE *)ad_title, ad_fpath );	/* Build the new path with ext. */
	       ForceReadDirectory();			/* force a read again  		*/
	    }
	  }
	  else {  
	    if( ret == OK )
	       break;
	  }
	     	
	}while ( ret != CANCEL );

fdone:

	dos_sdrv( savedrv );				/* Restore the DTA */

	dos_free( savepath );
	strcpy( ad_fpath, pipath );


	unfmt_str( ( BYTE *)ad_select, ( BYTE *)pisel );

	if(( ret == OK ) && ( *( BYTE *)ad_select != '\0' ) ) {	/* Store the path away if the user clicked OK AND */
	   StorePath( ad_fpath, ( BYTE *)pisel );	        /* if there is a filename			  */
								/* We use pisel since it it now is fixed up again */

	   SaveFSelect( TempPath );				/* Save Out to DISK FSELECT.INF			  */
	}


	if ( ( *pbutton = inf_what( tree, OK, CANCEL ) ) == -1 )
	  *pbutton = NULL;

        ob_change( tree, ret, NORMAL, FALSE );
	fm_dial( FMD_FINISH, &gl_rcenter, &gl_rfs );
	dos_dta( savedta );
	gsx_sclip( &clip );
	
	wm_update( 2 );
 	gr_mouse( 0, 0x0L );	/* Force to a mouse - because if an error occurs, we'll restore a busy bee otherwise */
	return( TRUE );
}





/* r_dir()
 * ====================================================================
 *	read in a directory
 */
	WORD	
r_dir( path, select, count, mask_flag )
	BYTE	*path;
	BYTE	*select;
REG	UWORD	*count;
	WORD	mask_flag;
{
	LONG	tree,addr;
REG	WORD	status;
	LONG	h,h1;
	BYTE	filename[ LEN_FSNAME ];
	BYTE    *sptr;
	
	gr_mouse( 2, 0x0L ); 


	if( !mask_flag ) {	/* if we're not parsing multiple masks, set count to 0 */
	  fs_count = 0;
	  *count   = 0;
	}

	if ( ! r_files( path, select, count, filename, mask_flag ) )
	{				/* if failed	*/
	  fm_error( 2 );
	  status = FALSE;
	  goto r_exit;
	}

	/* Check if the path is too long and shorten it if necessary */
	CheckFSPath();			/* cjg 06/29/93 */

	fs_count = *count;

	if( !mask_flag ) {
	  ob_draw( ad_fstree, FDIRECTO, MAX_DEPTH );
	  sptr = scasb( filename, '.' );
	  fs_draw( FTITLE, ( LONG )( sptr + 1 ), ( LONG )&addr, ( LONG )&addr );
	  fs_draw( FSELECTI, ( LONG )select, ( LONG )&ad_select, ( LONG )&addr ); 
	}

	tree = ad_fstree;
	fs_topptr = 0;				/* reset top pointer	*/

	h = LWGET( OB_HEIGHT( FSVSLID ) );
	h += ADJ3DPIX << 1;
	if ( *count > NM_NAMES )
	{
	  h1 = *count;
	  h = ( h * (LONG)NM_NAMES ) / h1;
	}

	if ( !h )				/* min size */
	  h = 1;
	else
	{
	  if ( h > ( ADJ3DPIX << 1 ) )
	    h -= (LONG) (ADJ3DPIX << 1);	
	}
	LWSET( OB_Y(FSVELEV), 0 );		/* move it to the top	  */
	LWSET( OB_HEIGHT(FSVELEV), (UWORD)h );	/* height of the elevator */

	if( !mask_flag )			/* Skip if we're parsing multiple masks */
           SetupSelFile( select );		/* Try to display the file within the scroll area */

	status = TRUE;
r_exit:
	gr_mouse( 260, 0x0L );
	return ( status );
}





/* r_files()
 * ====================================================================	
 *	 Read files into the buffer		          
 *	The buffer size will always be NM_NAMES or more   
 *	for easy coding and redraw the count will return  
 *	the actual number of files		          
 */ 
	WORD
r_files( path, select, count, filename, mask_flag )
REG	BYTE	*path;/*5*/
	BYTE	*select;
	WORD	*count;
REG	BYTE	*filename;/*4*/
	WORD	mask_flag;
{
	REG	WORD	i;/*8*/
		LONG	j;/*2*/
	REG	LONG	k;/*4*/
		WORD	ret/*3*//*,len*/;
	REG	FSTRUCT	*fsnames;
	REG	WORD	drvid;/*4*/
		BYTE	*chrptr;
		WORD	out;
		FSTRUCT *old_dta, new_dta;

	
	fsnames = ad_fsnames;

	*filename = 0;		/* no file name		*/

	if ( !fs_first )	/* Check Global Flag to preserve filename */
	  *select = 0;		/* clean up selection filed */
	else
	  fs_first = FALSE;	/* don't clean up at this   */
				/* time			    */

				/* uppercase the drive path	*/
	if ( *( path + 1 ) == ':' )
	{
	  *path = toupper( *path );
	  drvid = (WORD)(*path - 'A');	
	}
	else
	  drvid = defdrv;

 				/* the drive present ? 	*/
	k = 1L;
	k = k << drvid; 
	j = Drvmap( );		/* get the drive map	*/

	if ( !( k & j ) )	/* drive not there	*/
	  return( FALSE );


	dos_sdrv( drvid );	/* set the default drive	*/
				/* take out the wild string stuff	*/

	chrptr = fs_back( path );	/* get the directory	*/
	if ( *chrptr == '\\' )		/* path exists, point at filename */
	  chrptr++;	  

	if ( strlen( chrptr ) > 12 )	/* 9/5/90		*/
	  chrptr[12] = 0;

	strcpy( chrptr, filename );	/* save the file name	*/
	strcpy( wildstr, chrptr );	/* this is the dir	*/

	old_dta  = ( FSTRUCT *)dos_gdta();

	ad_fsdta = &new_dta;
	dos_dta( ( LONG )ad_fsdta );					
					/* look for all sub dir	*/
	if ( ! ( ret = dos_sfirst( ( LONG )path, 0x37 ) ) )	
	{				/* error		*/
	  if ( DOS_AX != E_NOFILES )	/* it is not no files	*/
	  {				
	    strcpy( filename, chrptr );	/* then return		*/
	    return( FALSE );
	  }
	}

	if( mask_flag )			/* If parsing multiple masks */
	  i = *count;			/* multiple masks	     */
	else
	  i = 0;			/* single mask		     */

	if( !i ) {	     		/* Clear these ONLY if first time */
	  for ( i = 0; i < NM_NAMES; i++ )
	    strcpy( " ",  &fsnames[i].snames[0] );
	  i = 0;
	}


	  				/* look for directory	*/
	while ( ( ret ) && ( (UWORD)(i) < fs_fnum ) )	
	{
	  if( ad_fsdta->d_attrib & (F_HIDDEN|F_SYSTEM) ) {
	    goto rfile2;
	  }

	  if( ad_fsdta->d_attrib & F_SUBDIR ) /* if subdirectory	*/
	  {
	    if ( ad_fsdta->snames[0] != '.' )
	      fsnames[i].snames[0] = 7;
	    else {
	      goto rfile2; 
	    }
	  }
	  else
	  {
	    if ( wildcmp( filename, ad_fsdta->snames ) )
	      fsnames[i].snames[0] = 0x20;
	    else {
	      goto rfile2;
	    }
	  }

	  /* See if the file already is installed. Skip it if found
	   * Also, skip if not the Special Mask
	   */
	  out = -1;
	  if( CurMask == MSPECIAL )
	      out = FindFSFile( ad_fsdta->snames, ad_fsdta->d_attrib, i );
	
	  if( out == -1 ) {
	    fsnames[i].d_attrib = ad_fsdta->d_attrib;
	    fsnames[i].d_time   = ad_fsdta->d_time;
	    fsnames[i].d_date   = ad_fsdta->d_date;
	    fsnames[i].d_length = ad_fsdta->d_length;
	    fmt_str( ad_fsdta->snames, &fsnames[i++].snames[1] );
	  }
	  else
	    strcpy( " ",  &fsnames[i].snames[0] );	/* If not to be used, clear it out */
rfile2:
	  ret = dos_snext();
	}

	dos_dta( ( LONG )old_dta );

	if ( i && ( CurMask != MSPECIAL ) )
	  do_rsort( fsnames, i, CurSort ); 

	strcpy( filename, chrptr );	/* restore file name	*/

	*count = (UWORD)i;

	return( TRUE );
}






/* r_sfiles()
 * ====================================================================
 * show files and update the scroll bar
 */
	VOID
r_sfiles( index, ratio )
	UWORD	index,ratio;
{	
REG	WORD	label,i;
REG	LONG	tree;
	LONG	addr,h,h1,h3;

	label = F1NAME;
	tree = ad_fstree;

	for ( i = index; i < ( index + NM_NAMES ); i++ )
	{
	  LWSET( OB_STATE(label),NORMAL );
	  fs_sset( ad_fstree, label, ( LONG )" ", &addr, ( WORD *)&addr ); 
	  fs_draw( label++, ( LONG )&ad_fsnames[i].snames[0], ( LONG )&addr, ( LONG )&addr ); 
	}

	h = LWGET( OB_HEIGHT( FSVSLID ) );
	h += ADJ3DPIX << 1;

	h1 = LWGET( OB_HEIGHT( FSVELEV ) );
	h1 += ADJ3DPIX << 1;

	h3 = (LONG) index;

	if ( ratio == 1 || ratio == NM_NAMES )
	{
	  if ( fs_count > NM_NAMES )
	    h = ( (h - h1) * h3 ) / (LONG)(( fs_count - NM_NAMES ));
	  else
	    h = 0L;
	}
	else
	  h = ( (h - h1) * (LONG)ratio ) / 1000L;	  

	LWSET( OB_Y(FSVELEV), ( WORD )h );
	ob_draw( tree, FSVSLID, MAX_DEPTH );	/* erase the old slide bar */
}




/* fs_draw()
 * ====================================================================
 * do the fs_sset and ob_draw
 */
	VOID
fs_draw( index, path, addr1, addr2 )
	WORD	index;
	LONG	path,addr1,addr2;
{
	fs_sset( ad_fstree, index, path, ( LONG *)addr1, ( WORD *)addr2 ); 
	ob_draw( ad_fstree, index, MAX_DEPTH );
}





/* ini_fsel()
 * ====================================================================
 * Adjust all the drive boxes for 3D effects
 * Initialize the Global Variables before reading in the INF file.
 */
	VOID
ini_fsel( VOID )
{
	WORD		x,y,w;
	REG OBJECT	*obj;
	OBJECT		*tree;
	REG WORD	i;
	REG BYTE	*sptr;


	rs_gaddr(ad_sysglo, R_TREE, SELECTOR, ( LONG *)&tree );
	rs_gaddr(ad_sysglo, R_TREE, MASKTREE, ( LONG *)&ad_mask );
	rs_gaddr(ad_sysglo, R_TREE, EDITTREE, ( LONG *)&ad_edit );
	
	obj = tree;

	y = x = 0;

	/* fix up the remaining of the file selector */

	ob_offset( ( LONG )tree, DIRTITLE, &x, &y );
	obj[ FDIRECTO ].ob_y = y + obj[ DIRTITLE ].ob_height + 2;
	obj[ FDIRECT2 ].ob_y = obj[ FDIRECTO ].ob_y;

	obj[FUPAROW].ob_height -= 1;
	obj[FDNAROW].ob_height -= 1;

	ob_offset( ( LONG )tree, FCLSBOX, &x, &y );

 	obj[FILEBOX].ob_x = x - ADJ3DPIX - 1; 
	obj[FTITLE].ob_x = x + obj[FCLSBOX].ob_width + (ADJ3DPIX << 1);
					 /* adjust FTITLE */	
	obj[FTITLE].ob_y = y;
	obj[FTITLE].ob_height = obj[FCLSBOX].ob_height;
	obj[FTITLE].ob_width -= (ADJ3DPIX << 1);

	y = y + obj[FCLSBOX].ob_height + ADJ3DPIX;
	obj[FILEBOX].ob_y = obj[SCRLBAR].ob_y = y;
	obj[FUPAROW].ob_y = ADJ3DPIX;
	y = obj[FUPAROW].ob_height + (ADJ3DPIX << 1);
	obj[FSVELEV].ob_height = obj[FSVSLID].ob_height;
	y += ADJ3DPIX;	
	obj[FSVSLID].ob_y = obj[FSVELEV].ob_y = y; 
	y += obj[FSVSLID].ob_height + (ADJ3DPIX << 1);
	obj[FDNAROW].ob_y = y;
	y += obj[FDNAROW].ob_height + ADJ3DPIX;
	obj[FILEBOX].ob_height = obj[SCRLBAR].ob_height = y;
	w = obj[FCLSBOX].ob_width + obj[FTITLE].ob_width + ( ADJ3DPIX << 2 );
	w -= obj[FUPAROW].ob_width;
	obj[FILEBOX].ob_width = w;
	obj[SCRLBAR].ob_x = obj[FILEBOX].ob_x + w;
	obj[SCRLBAR].ob_spec = 0;
	obj[FSVSLID].ob_flags |= (IS3DOBJ|IS3DACT);
	obj[FSVSLID].ob_state |= SELECTED;

	ob_offset( ( LONG )tree, FILEBOX, &x, &y );
	y = obj[FILEBOX].ob_height + y + 6 + ADJ3DPIX;
	obj[OK].ob_y = obj[CANCEL].ob_y = y;
	y += obj[OK].ob_height + ADJ3DPIX + 6;
	obj[0].ob_height = y;

	/* colors will be set up at run time based on window colors */

	/* Fixup the Edit Mask Dialog Box */
	ad_edit[ PTITLE1 ].ob_x += ADJ3DPIX;
	ad_edit[ PTITLE1 ].ob_width -= ( ADJ3DPIX << 1 ) - 1;

	ad_edit[ PTITLE2 ].ob_x += ADJ3DPIX;
	ad_edit[ PTITLE2 ].ob_width -= ( ADJ3DPIX << 1 ) - 1;
	
	ob_offset( ( LONG )ad_edit, PTITLE0, &x, &y );
	
	ad_edit[ PTITLE1 ].ob_y = y + ad_edit[ PTITLE0 ].ob_height + gl_hchar;
	ad_edit[ PBOX1 ].ob_y = ad_edit[ PTITLE1 ].ob_y +
				ad_edit[ PTITLE1 ].ob_height + ADJ3DPIX;
	ad_edit[ PTITLE2 ].ob_y = ad_edit[ PBOX1 ].ob_y +
				  ad_edit[ PBOX1 ].ob_height + gl_hchar;
	ad_edit[ PBOX2 ].ob_y = ad_edit[ PTITLE2 ].ob_y +
				ad_edit[ PTITLE2 ].ob_height + ADJ3DPIX;

	y = ad_edit[ PBOX2 ].ob_y + ad_edit[ PBOX2 ].ob_height + gl_hchar;
	ad_edit[ ETOK ].ob_y	 = y;
	ad_edit[ ETCANCEL ].ob_y = y;
	ad_edit[ ETEDIT].ob_y	 = y;
	y += ad_edit[ ETOK ].ob_height + ADJ3DPIX + 8;
	ad_edit[ ROOT ].ob_height = y;


	/* -------------------------------------------------------
         * Initialize the Global Variables - Before READING INF file.
	 * -------------------------------------------------------
	 */
        for( i = 0; i < MAX_USED_PATHS; i++ )	/* Clear the Used Paths Array */
            UsedPaths[i][0] = '\0';

   	for( i = 0; i < MAX_MULTI_LIMIT; i++ )  /* Clear the 8.3 Mask Area    */
            FullMaskText[i][0] = '\0';
        strcpy( "*.*", FullMaskText[0] );       /* Default to [*.*]           */

        for( i = 0; i < ( MASKUEND - MASKUB + 1 ); i++ ) { /* Default Single Editable Masks*/
	   sptr = scasb( ( BYTE *)ad_mask[ i + MASKUB ].ob_spec, '.' );
	   strcpy( DefaultSMasks[i], sptr + 1 );
        }

        CurSort = SORTNAME;		        /* Default for sorting.       */

        /* Read and LOAD the FSELECT.INF file - initialize the variables */
	ReadFSelect( TempPath );
}




/* FXWait()
 * ====================================================================
 * Wait for the UP button
 */
VOID
FXWait( VOID )
{
    do
    {
        if (gl_multi)
                Syield();
    }while( gl_button );
}



/* FXSelect()
 * ====================================================================
 * Select and redraw an object taking into account the special effects
 */
VOID
FXSelect( tree, obj )
OBJECT *tree;
WORD   obj;
{
    GRECT 	rect;
    WORD	dummy;
	
    tree[ obj ].ob_state |= SELECTED;
    rect = *(GRECT *)&tree[(obj)].ob_x;
    ob_gclip( ( LONG )tree, obj, &dummy, &dummy, &rect.g_x, &rect.g_y,
	      &rect.g_w, &rect.g_h );
    gsx_sclip( &rect );
    ob_draw( ( LONG )tree, obj, MAX_DEPTH );		/* draw the box		*/
}



/* FXDeselect()
 * ====================================================================
 * Deselect and redraw an object taking into account the 
 * special effects.
 */
VOID
FXDeselect( tree, obj )
OBJECT *tree;
WORD   obj;
{
    GRECT 	rect;
    WORD	dummy;
 	
    tree[ obj ].ob_state &= ~SELECTED;
    rect = *(GRECT *)&tree[(obj)].ob_x;
    ob_gclip( ( LONG )tree, obj, &dummy, &dummy, &rect.g_x, &rect.g_y,
	      &rect.g_w, &rect.g_h );
    gsx_sclip( &rect );
    ob_draw( ( LONG )tree, obj, MAX_DEPTH );		/* draw the box		*/
}




#if 0
/* do_rsort()
 * ====================================================================
 * Sorts the filenames based on mode - NAME, DATE, TYPE, NO SORT
 */
VOID
do_rsort( buffer, count, mode )
REG	FSTRUCT	*buffer;
	WORD	count;
	WORD	mode;
{ 
REG	WORD	i,j;
REG	WORD	gap;
REG	BYTE	*first, *second;

REG	FSTRUCT *d1,*d2;
	BYTE    t1[ LEN_FSNAME ];
	BYTE	t2[ LEN_FSNAME ];
	WORD	ret;

	for( gap = count/2; gap > 0; gap = gap >> 1 )
	{
	  for( i = gap; i < count; i++ )
	  {
	    for ( j = i - gap; j >= 0; j -= gap )
	    {
		if( mode == SORTNONE )
		   goto ss_1;
#ifdef OUR_OPTIMIZER_WORKS
/* this is the way the code should be */
		if( ( buffer[ j+gap].d_attrib & F_SUBDIR ) && 
		    ( buffer[j].d_attrib & F_SUBDIR ) )
		    goto ss_1;

		if( buffer[ j+gap].d_attrib & F_SUBDIR )
		    goto ss_2;

		if( buffer[ j].d_attrib & F_SUBDIR )
		    break;

ss_1:
	        d1 = &buffer[j];
		d2 = &buffer[j+gap];

	        first  = buffer[j].snames;
	        second = buffer[j+gap].snames;
#else
/* this is the way the Lattice optimizer needs it to be */
		if( ( *( BYTE *)( ( ( BYTE *)buffer ) + ( ( j + gap ) * DTA_SIZE ) + D_ATTRIB ) & F_SUBDIR ) && 
		    ( *( BYTE *)( ( ( BYTE *)buffer ) + ( j * DTA_SIZE ) + D_ATTRIB ) & F_SUBDIR ) )
		    goto ss_1;

		if( *( BYTE *)( ( ( BYTE *)buffer ) + ( (j + gap ) * DTA_SIZE ) + D_ATTRIB ) & F_SUBDIR )
		    goto ss_2;


		if( *( BYTE *)( ( ( BYTE *)buffer ) + ( j * DTA_SIZE ) + D_ATTRIB ) & F_SUBDIR )
		    break;
ss_1:
		d1 = ( FSTRUCT *)( ( ( BYTE *)buffer )  + ( j * DTA_SIZE ) );
		d2 = ( FSTRUCT *)( ( ( BYTE *)buffer )  + ( ( j + gap ) * DTA_SIZE ) );

	        first  = ((BYTE *)buffer ) + ( j * DTA_SIZE ) + D_NAME;
	        second = ((BYTE *)buffer ) + ( ( j + gap ) * DTA_SIZE ) + D_NAME;
#endif
	      unfmt_str( first + 1, t1 );
	      unfmt_str( second + 1, t2 );
	      
	      switch( mode ) {

		case SORTNONE:	/* NO SORT */
		     ret = -1;
		     break;

		case SORTSIZE:   /* Sort based on file size   */
#if 1
//#ifdef OUR_OPTIMIZER_WORKS
/* This is the way the code should be */
		     if( d2->d_length > d1->d_length )
			ret = 1;
		     else
		        if( d2->d_length < d1->d_length )
			   ret = -1;
			else
			   ret = strchk( first, second );
#else
/* This is the way the Lattice optimizer needs it to be */
		     if( *( LONG *)(( BYTE *)d2 + D_LENGTH ) > *( LONG *)(( BYTE *)d1 + D_LENGTH ) )
			ret = 1;
		     else
			if( *( LONG *)(( BYTE *)d2 + D_LENGTH ) < *( LONG *)(( BYTE *)d1 + D_LENGTH ) )
			   ret = -1;
			else
			   ret = strchk( first, second );
#endif
		     break;

		case SORTTYPE:   /* Sort based upon file type */
		     if( ret = strchk( scasb( t1, '.' ), scasb( t2, '.' ) ) )
 		        break;
		     else
			ret = strchk( t1, t2 );
		     break;


		case SORTNAME:   /* Sort based on file name   */
		     ret = strchk( first, second );
		     break;

		case SORTDATE:   /* Sort based on DATE        */
#if 1
//#ifdef OUR_OPTIMIZER_WORKS
/* This is the way the code should be */
		     ret = 0;
		     if( d2->d_date > d1->d_date )
			ret = 1;
		     
		     if( d2->d_date < d1->d_date )
			ret = -1;

		     if( !ret ) {	/* IF the dates are equal, */
					/* sort based on time...   */
				        /* then sort based on name */
			if( ( d2->d_time >> 5 ) > 
			    ( d1->d_time >> 5 ) )
			    ret = 1;

			if( ( d2->d_time >> 5 ) < 
			    ( d1->d_time >> 5 ) )
			    ret = -1;
		
			if( !ret ) {
			   ret = strchk( first, second );
			}
		     }
#else
/* This is the way the Lattice optimizer needs it to be */
		     ret = 0;
		     if( *( UWORD *)(( BYTE *)d2 + D_DATE ) > *( UWORD *)(( BYTE *)d1 + D_DATE ) )
			ret = 1;

		     if( *( UWORD *)(( BYTE *)d2 + D_DATE ) < *( UWORD *)(( BYTE *)d1 + D_DATE ) )		     
			ret = -1;

		     if( !ret ) {	/* IF the dates are equal, */
					/* sort based on time...   */
				        /* then sort based on name */
		        if( ((*( UWORD *)(( BYTE *)d2 + D_TIME ))>>5) > ((*( UWORD *)(( BYTE *)d1 + D_TIME ))>>5) )
			    ret = 1;

		        if( ((*( UWORD *)(( BYTE *)d2 + D_TIME ))>>5) < ((*( UWORD *)(( BYTE *)d1 + D_TIME ))>>5) )
			    ret = -1;
		
			if( !ret ) {
			   ret = strchk( first, second );
			}
		     }
#endif
		     break;
			
	      }
		
	      if( ret <= 0 )
		 break;

ss_2:
	      do_rswap( buffer, j, j + gap );

	    }
	  }
	}
}

/* do_rswap()
 * ====================================================================
 * Swap the FSTRUCT structure from do_rsort()
 */
VOID
do_rswap( REG FSTRUCT *buffer, WORD first, WORD second )
{
    REG FSTRUCT buff;

    buff             = buffer[ first ];
    buffer[ first ]  = buffer[ second ];
    buffer[ second ] = buff;
}
#endif



/* do_rsort()
 * ====================================================================
 * Sorts the filenames based on mode - NAME, DATE, TYPE, NO SORT
 */
VOID
do_rsort( buffer, count, mode )
REG	FSTRUCT	*buffer;
	WORD	count;
	WORD	mode;
{ 
REG	WORD	i,j;
REG	WORD	gap;
REG	BYTE	*first, *second;

REG	FSTRUCT *d1,*d2;
	BYTE    t1[ LEN_FSNAME ];
	BYTE	t2[ LEN_FSNAME ];
	WORD	ret;
	FSTRUCT buff;

	for( gap = count/2; gap > 0; gap = gap >> 1 )
	{
	  for( i = gap; i < count; i++ )
	  {
	    for ( j = i - gap; j >= 0; j -= gap )
	    {
#ifdef OUR_OPTIMIZER_WORKS
/* this is the way the code should be */
	        d1 = &buffer[j];
		d2 = &buffer[j+gap];

	        first  = buffer[j].snames;
	        second = buffer[j+gap].snames;
#else
/* this is the way the Lattice optimizer needs it to be */
		d1 = ( FSTRUCT *)( ( ( BYTE *)buffer )  + ( j * DTA_SIZE ) );
		d2 = ( FSTRUCT *)( ( ( BYTE *)buffer )  + ( ( j + gap ) * DTA_SIZE ) );

	        first  = ((BYTE *)buffer ) + ( j * DTA_SIZE ) + D_NAME;
	        second = ((BYTE *)buffer ) + ( ( j + gap ) * DTA_SIZE ) + D_NAME;
#endif

		if( mode == SORTNONE )
		   goto ss_1;

		if( ( d2->d_attrib & F_SUBDIR ) &&
		    ( d1->d_attrib & F_SUBDIR ) )
		    goto ss_1;

		if( d2->d_attrib & F_SUBDIR )
		    goto ss_2;

		if( d1->d_attrib & F_SUBDIR )
		    break;

ss_1:
	      unfmt_str( first + 1, t1 );
	      unfmt_str( second + 1, t2 );
	      
	      switch( mode ) {

		case SORTNONE:	/* NO SORT */
		     ret = -1;
		     break;

		case SORTSIZE:   /* Sort based on file size   */
		     if( d2->d_length > d1->d_length )
			ret = 1;
		     else
		        if( d2->d_length < d1->d_length )
			   ret = -1;
			else
			   ret = strchk( first, second );
		     break;

		case SORTTYPE:   /* Sort based upon file type */
		     if( ret = strchk( scasb( t1, '.' ), scasb( t2, '.' ) ) )
 		        break;
		     else
			ret = strchk( t1, t2 );
		     break;


		case SORTNAME:   /* Sort based on file name   */
		     ret = strchk( first, second );
		     break;

		case SORTDATE:   /* Sort based on DATE        */
		     ret = 0;
		     if( d2->d_date > d1->d_date )
			ret = 1;
		     
		     if( d2->d_date < d1->d_date )
			ret = -1;

		     if( !ret ) {	/* IF the dates are equal, */
					/* sort based on time...   */
				        /* then sort based on name */
			if( ( d2->d_time >> 5 ) > 
			    ( d1->d_time >> 5 ) )
			    ret = 1;

			if( ( d2->d_time >> 5 ) < 
			    ( d1->d_time >> 5 ) )
			    ret = -1;
		
			if( !ret )
			   ret = strchk( first, second );
		     }
		     break;
			
	      }
		
	      if( ret <= 0 )
		 break;

ss_2:
#ifdef OUR_OPTIMIZER_WORKS
/* This is the way the code should be */
	     buff  = buffer[j];
	     buffer[ j ] = buffer[ j + gap ];
	     buffer[ j + gap ] = buff;
#else
/* This is the way the Lattice optimizer needs it to be */
	     buff  = *d1;
	     *d1   = *d2;
	     *d2   = buff;
#endif
	    }
	  }
	}
}



/* FindMask()
 * ====================================================================
 * Given a wildcard extension, find it in our tree...
 */
WORD
FindFSMask( BYTE *textptr )
{
	OBJECT *ad_tree;
REG	WORD   i;
REG	BYTE   *sptr;

	rs_gaddr(ad_sysglo, R_TREE, MASKTREE, ( LONG *)&ad_tree );
	
	for( i = MASK_BEG; i <= MASK_END; i++ ) {
	    sptr = scasb( ( BYTE *)ad_tree[ i ].ob_spec, '.' );
	    if( *sptr && strcmp( textptr, sptr + 1 ) )
	       return( i );
	}

	return( FALSE );
}






/* CountFolders()
 * ====================================================================
 * Count the number of folders in a PATH
 */
WORD
CountFolders( BYTE *path )
{
     REG BYTE *dptr;
     WORD     count;

     count = 0;
     dptr = path;

     do {
	dptr = fs_back( path );
	if( *dptr ) {
	  *( dptr ) = '\0';
	  count++;
	}
     }while( *( dptr - 1 ) != ':' );

     return( count );
}




/* MakeFSMenu()
 * ====================================================================
 * Builds an object tree for the abbreviated path menu.
 * Also, Allocates enough memory for the string text and points
 * the G_STRINGS to those locations.
 * IN: NumLevels - Number of Menu items to buildd
 * RETURN: NULL- FAILURE
 * 	   NON-ZERO - Address of buffer.
 */
OBJECT
*MakeFSMenu( WORD NumLevels, WORD width )
{
     OBJECT     *ptr;
     LONG       size;
     WORD       NumItems;
     REG WORD   i,j;
     BYTE       *txt_ptr;

     NumItems = NumLevels + 1;

     size = ( ( NumItems ) * sizeof( OBJECT ) ) +
	    ( ( NumItems + 2 ) * width );		/* Safety boundary + 2 */

     ptr = ( OBJECT *)dos_xalloc( size, 3 );

     if( ptr ) {	/* We have a chunk of memory */
	 
	  /* Need to Set up the ROOT FIRST */
	  ptr[0] = FS_DATA[0];
	  ptr->ob_width  = width * gl_wchar;
	  ptr->ob_height = NumLevels * gl_hchar;


	  /* Calculate the initial text area */
	  txt_ptr = ( BYTE *)ptr;
	  txt_ptr += ( sizeof( OBJECT ) * ( NumItems + 1 )) + 1;	/* Safety boundary + 1 */


	  /* Add in the other G_STRINGS and update the
 	   * ob_spec pointers.
	   */
	  for( i = 1; i < NumItems; i++ ) {
	     ptr[i] = FS_DATA[1];
	     for( j = 0; j < width; j++ )
		txt_ptr[j] = ' ';
	     txt_ptr[ width ] = '\0';	

	     ptr[i].ob_spec   = ( LONG )txt_ptr;	     
	     ptr[i].ob_y      = ( i - 1 ) * gl_hchar;
	     ptr[i].ob_width  = width * gl_wchar;
	     ptr[i].ob_height = gl_hchar; 

	     ob_add( ( LONG )ptr, ROOT, i );

	     txt_ptr += ( width + 1 );				/* Safety boundary + 1 */
	  }
     }
     return( ptr );
}




/* CheckFSPath()
 * ====================================================================
 * Check if the path ---> ad_fspath[] is longer than MAX_FSWIDTH.
 * If so, substitute in our copy of the path. Otherwise, reset
 * the string pointers back to ad_fspath.
 * 
 * When we substitute our new path, it contains an abbreviated version
 * ie: C:\A\B\C\*.*  ---->   C:\...\B\C\*.*
 */
VOID
CheckFSPath( VOID )
{
	LONG addr;
	WORD len;	/* Length of the string */

	len = strlen( ad_fpath );

	/* If the length of the path is too long, we need to 
	 * shorten it to make it fit.
	 */
	if( len > MAX_FSWIDTH ) {	/* Need to shorten it...*/

	    /* -----------------------------------------------------
	     * We want to set ad_fpath to the Backup string area ONLY
	     * if it hasn't already been done so.		
	     * -----------------------------------------------------
	     */
	    if( ad_fpath != BackUpPath ) {
		ad_back = ad_fpath;		/* Backup ptr to TEDINFO */
	        strcpy( ad_fpath, BackUpPath );
		ad_fpath = BackUpPath;		/* point to original */
	    }

	    AbbrevPath( ad_fpath, ad_back, MAX_FSWIDTH );
	    return;	
	}


	/* RESTORE ORIGINAL ---> IF we need to restore the original path */
	if( ad_fpath == BackUpPath ) {
	   fs_sset( ad_fstree, FDIRECTO, ( LONG)"", ( LONG *)&ad_fpath, ( WORD *)&addr ); 
	   strcpy( BackUpPath, ad_fpath );
	}
}





/* StorePath()
 * ====================================================================
 * Store the Path, when the user pressed OK, into the array
 * of used paths.  If there is no more room, we must make some...
 * Later on, we write this out to a file.
 */
VOID
StorePath( BYTE *path, BYTE *fname )
{
   REG WORD i,j;


   /* Build the Path and filename into one string */
   strcpy( path, TempPath );
   strcpy( fname, fs_back( TempPath ) + 1 );


   /* Search the Array to see if the path and filename already exist */
   for( i = 0; i < MAX_USED_PATHS; i++ ) {
       if( strcmp( TempPath, UsedPaths[i] ) ) {
	   return;				/* Path exists, exit */
       }
   }

   /* if we reach this point, the path does not exist yet
    * and we are going to have to add it in.
    */
   
   
   /* Find the empty slot */
   for( i = 0; i < MAX_USED_PATHS; i++ ) {
      if( UsedPaths[i][0] == '\0' ) {			  /* Found an empty slot!	       */
	   break;
      }
   }

   if( i >= MAX_USED_PATHS ) {			  /* If there is no room, we must add  */
							  /* it at the top and shove everyting */
	for( j = ( MAX_USED_PATHS - 1 ); j >= 1; j-- )  /* else down below		       */
            strcpy( UsedPaths[j-1], UsedPaths[j] );
	strcpy( TempPath, UsedPaths[0] );
   }
   else {						  /* There is room, ad it in!!!!       */
								
	strcpy( TempPath, UsedPaths[i] );
   }
   
}




/* AbbrevPath()
 * ====================================================================
 * Abbreviate the Given Path based upon the width given.
 */
VOID
AbbrevPath( BYTE *source, BYTE *dest, WORD width )
{
     WORD mlen;				/* minimum width we're dealing width */
     REG  BYTE *sptr;			/* Temporary string pointer	     */
     WORD len;				/* length of source.		     */

     len  = strlen( source );		/* get the length of the source      */

     if( len > width ) {

      strcpy( "C:\\...", dest );	/* Setup up first section            */
      *dest = *source;			/* copy over Drive - first char      */
      mlen = ( width - 1 ) - strlen( dest );  /* Subtract the C:\... string  */


      /* Search for slashes and then check length from there.
       * If the path is still too long, go up to the next directory.
       */
      sptr = source;			/* Might as well start in front      */

      while( *sptr && ( len > mlen ) ) {
	  sptr++;			/* SKip past current slash  	     */
	  while( *sptr && ( *sptr != '\\') ) {
	     sptr++;
          };


	  len = strlen( sptr );		
      };

      if( *sptr )
         strcat( sptr, dest );		/* concatenate  in the Directories   */
      else {				/* If we reached this point, then    */
					/* the multiple masks must be        */
					/* shortened also.		     */
	   *dest = '\0';
	   AbbrevMask( source, dest, width );
	 
      }
    }
    else
      strcpy( source, dest );		/* otherwise, copy them over	     */
}




/* AbbrevMask()
 * ====================================================================
 * Abbreviate Multiple Masks - Called ONLY by AbbrevPath
 */
VOID
AbbrevMask( BYTE *source, BYTE *dest, WORD width )
{
     WORD mlen;				/* minimum width we're dealing width */
     REG  BYTE *sptr;			/* Temporary string pointer	     */
     WORD len;				/* length of source.		     */
     REG  WORD level;

     strcpy( source, TempPath );	      /* See if there are any folders*/
     level = CountFolders( TempPath );

     if( level > 1 )			      /* Inside a directory...       */
        strcpy( "C:\\...\\[...]", dest );     /* Setup destination           */
     else
	strcpy( "C:\\[...]", dest );	      /* At the ROOT		     */

     *dest = *source;			      /* Copy over the Drive         */
     sptr = source;			      /* Setup Initial source ptr    */

     len  = strlen( source );		      /* Get length of source        */
     mlen = ( width - 1 ) - strlen( dest );   /* Set lenght we're shooting 4 */


     while( *sptr && ( len > mlen ) ) {       /* Do the Main LOOP	     */

        level = 0;
        do {				   /* Another Loop to count brackets */
	     	     
	    /* Search for open and close brackets until the string runs out  */
            while( *sptr && ( *sptr != '[' ) && ( *sptr != ']' ) ) {
	             sptr++;
            };

	    if( *sptr ) {

               if( *sptr == '[' )	   /* Open a Bracket  */
	           level++;

	       if( *sptr == ']' )	   /* Close a Bracket */
	           level--;

	       sptr++;			   /* SKip past current [ or ]    */



	       if( !level )		   /* Completed a segment of mask */
	          break;
	    }

	}while( *sptr );		   /* End of do { 		  */

        if( *sptr )
           len = strlen( sptr );	   /* Update the length		  */	
    };

    if( *sptr )
        strcat( sptr, dest );	           /* concatenate the multiple paths */
    else
        strcat( "[*.*]", dest );           /* Do this if NULL...   	     */
}




/* fs_formdo()
 * ====================================================================
 * Form Do for the File Selector stuff. Merely sets the centering
 * and returns the button selected.
 */
WORD
fs_formdo( OBJECT *tree, WORD start_fld )
{

      GRECT rect;
      WORD  ret;

      ob_center( ( LONG )tree, &rect );
      tree[ ROOT ].ob_x = rect.g_x;
      tree[ ROOT ].ob_y = rect.g_y;

      ob_draw( ( LONG )tree, ROOT, MAX_DEPTH );
      ret = fm_do( ( LONG )tree, start_fld );
      tree[ ret ].ob_state &= ~SELECTED;
      return( ret );
}



/* CleanFSDirt()
 * ====================================================================
 * Clean up after a dialog box has been displayed over the 
 * file selector.
 */
VOID
CleanFSDirt( OBJECT *dialog_tree, WORD obj, OBJECT *fs_tree )
{
    GRECT rect;
    WORD  dummy;

   ob_gclip( ( LONG )dialog_tree, obj, &dummy, &dummy,
  	     &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h );

   rect.g_w += ( SHADOW + ADJ3DPIX );
   rect.g_h += ( SHADOW + ADJ3DPIX );

   gsx_sclip( &rect );				
   ob_draw( ( LONG )fs_tree, ROOT, MAX_DEPTH );
   gsx_sclip( &gl_rfs );				
}





/* DoFullMaskDialog()
 * ====================================================================
 * Display the 8.3 Mask Editing Dialog Box.
 * Build a mask based upon the multiple masks.
 */
MLOCAL WORD
DoFullMaskDialog( VOID )
{
    WORD flag;
    REG  WORD i,j;
    REG  BYTE *sptext, *dptext;

    /* Copy the 8.3 masks from the GLOBAL location to the dialog box tree text fields
     * These are stored in the editable text fields as FORMATTED text - meaning
     * that they do not have '.' in their filenames.
     */
    for( i = 0; i < MAX_MULTI_LIMIT; i++ ) {
	sptext = ( BYTE *)( ( TEDINFO *)ad_fmask[ F1EDIT + i ].ob_spec )->te_ptext;
	fmt_str( FullMaskText[i], sptext );
    }

    flag = fs_formdo( ad_fmask, F1EDIT );

    CleanFSDirt( ad_fmask, ROOT, ( OBJECT *)ad_fstree );

    /* The user clicked on OK, need to go through and build a 
     * path containing all masks
     */
    if( flag == FOK ) {

	/* Copy the strings found in the editable text fields back to the global storage
 	 * These are stored as UNFORMATTED text - meaning they include the '.' in the
	 * filename.
	 * We shift the text around to clear out blank fields.
	 */
	j = 0;
	for( i = 0; i < MAX_MULTI_LIMIT; i++ ) {	
	   sptext = ( BYTE *)( ( TEDINFO *)ad_fmask[ F1EDIT + i ].ob_spec )->te_ptext;
	   dptext = ( BYTE *)( ( TEDINFO *)ad_fmask[ F1EDIT + j ].ob_spec )->te_ptext;

	   FullMaskText[i][0] = '\0';		    /* Clear EACH Destination */

	   if( *sptext ) {			    /* Is the editable field empty? */
	      unfmt_str( sptext, FullMaskText[j] ); /* NO- Copy it over		    */
	      if( i != j ) {			    /* Did we skip any blank fields?
						     * YES - copy sptext to dptext  
					             * and clear sptext		    
						     */
		strcpy( sptext, dptext );	   
		*sptext = '\0';
	      }
	      j++;				    /* increment destination counter*/  
	   }
	}

	if( IsFullMaskEmpty() )		/* If the masks are empty, default to [*.*] */
	  strcpy( wildstr, FullMaskText[0] );
	
	return( BuildFullMask() );	/* Build the multiple mask string */
	
    }
    return( FALSE );      
}




/* MaskTailEnd()
 * ====================================================================
 * The EBUTTON Switch tail end code - created to avoid GOTOs
 */
MLOCAL VOID
MaskTailEnd( WORD mn_item )
{
     REG BYTE *sptr;

     ad_mask[ CurMask ].ob_state &= ~CHECKED;
     ad_mask[ mn_item ].ob_state |= CHECKED;
     CurMask  = mn_item;

     sptr = scasb( ( BYTE *)ad_mask[ CurMask ].ob_spec, '.' );
     strcpy( sptr + 1, ( BYTE *)ad_title );		/* Copy over just the extension */

     /* Look for a blank at the end, zero it if found */
     sptr = scasb( ( BYTE *)ad_title, ' ' );
     if( *sptr )
       *sptr = '\0';

     strcpy( "*.", fs_back( ad_fpath ) + 1 );	/* Need to copy *. and then XXX      */
     strcat( ( BYTE *)ad_title, ad_fpath );	/* Build the new path with the mask  */

     if( mn_item != MSPECIAL )
        ForceReadDirectory();			/* Reread directory - single mask */
     else
        FullMaskHandler( TRUE, &count );	/* Multiple Mask Read		  */
}




/* BuildFullMask()
 * ====================================================================
 * Build the Global Multiple mask string based on the entries
 * into the Multiple Mask Dialog Box. The 8.3 masks are already 
 * unformatted and in the global FullMaskText arrays.
 *
 * The field array flags are set one by one as each
 * 8.3 mask is processed so that another 8.3 mask will not
 * process it.
 *
 * IN:	VOID
 *
 * GLOBALS:
 *	FullMaskText - string arrays holding the 8.3 masks
 *	MaskTemplate - String array holding the global multiple mask string
 *	ad_fmask     - OBJECT *ptr to the multiple mask dialog tree
 */
MLOCAL WORD
BuildFullMask( VOID )
{
    REG  WORD i,j;
    REG  BYTE *sptr, *dptr, *sptext, *dptext;
    BYTE sname[ LEN_FSNAME ];
    BYTE smask[ 4 ];
    BYTE dname[ LEN_FSNAME ];
    BYTE dmask[ 4 ];
    WORD field[ MAX_MULTI_LIMIT ];		/* 1 processed, 0 - not processed */

    for( i = 0; i < MAX_MULTI_LIMIT; i++ )
      field[i] = FALSE;

    MaskTemplate[0] = '\0';			/* Clear out our final string   */

    for( i = 0; i < MAX_MULTI_LIMIT; i++ ) {	/* Go through each mask	        */

	sptext = FullMaskText[i];		/* Get ptr to text, see if empty*/

	strcpy( FullMaskText[i], sname );	/* Copy 8.3 to source string    */
	sptr = scasb( sname, '.' );		/* Mark '.' of source           */

	if( *sptr )				/* If '.' is found...		*/
	   strcpy( sptr + 1, smask );		/* Get source file extension    */
	else
	   *smask = '\0';			/* Otherwise, no file extension */

	*sptr = '\0';				/* Clear the '.' to get the 8
						 * character filename.
						 */

		   
	if( !field[i] && *sptext ) {		/* Handle ONLY non-blank strings
						 * based on the editable text field.
					         * OR, if its NOT already processed.
						 */
	      
	   strcat( "[", MaskTemplate );         /* Start a fresh mask            */
	   strcat( sname, MaskTemplate );	/* Copy first 8 chars of source  */
	   strcat( ".", MaskTemplate );		/* Tack on the '.' delimiter     */

	
           /* --------------------------------------------------------------------
	    * For every mask found to be active in the editable text fields,
	    * we go through each and every mask to see if it already exists or
	    * if the 8 character filename is the same.
            * --------------------------------------------------------------------
    	    */
	   for( j = 0; j < MAX_MULTI_LIMIT; j++ ) {

	     if( i != j ) {			/* No need to check ourselves       */

		dptext = FullMaskText[j];	/* Get pointer to text to check     */

		if( !field[j] && *dptext ) {	/* If its blank or already processed, skip, otherwise    */

		   if( !strcmp( FullMaskText[i], FullMaskText[j] ) ) {	/* Skip if the strings are the same */

		       /* ------------------------------------------------------
			* The strings are not the same, so, let's compare 
			* the first 8 characters and the last 3 characters.
			* First, let's build the fname and mask strings
			* ------------------------------------------------------
			*/
		        strcpy( FullMaskText[j], dname );  	/* Copy over full mask */
			dptr = scasb( dname, '.' );		/* Get ptr to '.'      */
			if( *dptr )				/* If found...	       */
			   strcpy( dptr + 1, dmask );		/* Get file extension  */
			else
			   *dmask = '\0';			/* No file extension   */
		        *dptr = '\0';				/* Clear to get fname  */
				
		         if( strcmp( sname, dname ) ) {		/* Check the first 8 characters
								 * to see if they are the same
								 */
			    
			     /* --------------------------------------------------
			      * Since the first 8 characters are the same,
			      * We'll tack on the extensions
			      * masks with different first 8 characters, but 
			      * the same extensions will be different for our purposes.
			      * 
			      * Since we are in a loop, when we add the source file
			      * extension to the mask string, we want to do it only
			      * once, so we change it to a blank space. We can't
			      * use a NULL because a NULL signifies that the
			      * file extension never existed.
			      * --------------------------------------------------
			      */
			     if( *smask != 0x20 ) {	 /* We want to tack on the source only once */

			        strcat( "[", MaskTemplate );	/* Add start of multiple extensions */
				strcat( smask, MaskTemplate );	/* Copy over source mask	    */
				*smask = 0x20;			/* Now, blank it so we do it once   */
			     }

			     if( *dmask ) {			/* Same fname, different extension  */
			        strcat( ",", MaskTemplate );	/* Add in comma delimiter	    */
			        strcat( dmask, MaskTemplate );	/* Copy over the next mask          */
			     }
			     field[j] = TRUE;	     /* Now clear this one, since its processed now */
		         }
			

		   }     /* End of 'if( !strcmp( FullMaskText[i], FullMaskText[j] ) ) {' */
		   else
		   {
		         /* The strings we're gonna compare are the same, so clear it out */
		         FullMaskText[j][0] = *dptext = '\0';
			 field[j] = TRUE;			/* Processed! */
		   }
		}        /* End of 'if( *dptext ) { ' */
		else
		  field[j] = TRUE;	/* It's blank! so set the flag to PROCESSED */

 	   
	      }	         /* End of if( i != j )      */

	   }		 /* End of for( j = 0 loop ) */

	   if( *smask ) {			      /* if source has an extension */
	      if( *smask == 0x20 )		      /* Close multiple extensiosn  */
	         strcat( "]", MaskTemplate );
	      else
	         strcat( smask, MaskTemplate );       /* No multiple extensions     */
	   }
		
	   strcat( "]", MaskTemplate );	      	      /* Close up this mask         */
	   
	}				    	      /* End of ' if( *sptext ) { ' */
	field[i] = TRUE;
    }			    /* End of ' for( i = 0; i < MAX_MULTI_LIMIT; i++ ) { '  */

    if( MaskTemplate[0] == '\0' )		      /* All strings were blank */
       return( FALSE );


    return( TRUE );
}




/* FullMaskHandler()
 * ====================================================================
 * Handles the directory path for multiple masks ( MSPECIAL ) and
 * forces the read via ParseFullMask(). Restores the original path
 * if the destination path to change to is invalid.
 * Forces an arrow, since if there is an error, the BUSYBEE will
 * come up forever.
 *
 * IN:	     ClearFnameFlag - Clears on TRUE the filename field.
 *	     *count	    - Returns the # of files to display
 *
 * GLOBALS:  ad_select - pointer to filename field
 *	     pathcopy  - string array of the old directory path
 *	     ad_fpath  - pointer to directory path 
 *	     ad_fstree - file selector tree
 *	     fs_count  - global counter for # of files to display.
 */
MLOCAL VOID
FullMaskHandler( WORD ClearFnameFlag, UWORD *count )
{
    WORD out;

    if( ClearFnameFlag )
       *( BYTE *)ad_select = '\0';			/* Clear Fname if requested */

    out = ParseFullMask();				/* Parse multiple masks     */

    if( !out )	{					/* failure?      	    */
	*( BYTE *)ad_select = '\0';
	strcpy( pathcopy, ad_fpath );			/* Restore original path    */
        ParseFullMask();				/* Parse multiple masks again*/
    }

			     
    ob_draw( ad_fstree, FDIRECTO, MAX_DEPTH );		/* Redraw Path     	    */
    ob_draw( ad_fstree, FTITLE, MAX_DEPTH );		/* Redraw Mask              */
    ob_draw( ad_fstree, FSELECTI, MAX_DEPTH );		/* Redraw Filename          */

    gr_mouse( 0, 0x0L );				/* Force ARROW 		    */
    *count = fs_count;				        /* Update the files counted */

    RDirSuccess();					/* Perform cleanup duties   */
    RDirTailEnd();					/* after reading files from */
							/* multiple mask extensions */
}





/* ParseFullMask()
 * ====================================================================
 * Force the read of the directory based upon the multiple masks.
 * NOTE: MaskTemplate contains the multiple mask template already.
 *  
 * GLOBAL USED: fs_count - # of files to display
 *		FullMaskText - Text Array containing 8.3 masks
 *		fs_first     - Flag to clear/not clear filename field
 *		ad_fpath     - Ptr to Directory Path
 *		ad_select    - PTr to filename field
 *		CurSort      - Current Sorting Value
 *		MaskTemplate - String Array holding Multiple Mask String
 */
MLOCAL WORD
ParseFullMask( VOID )
{
      REG   WORD  i;
      UWORD count;

      fs_count = count = 0;

      for( i = 0; i < MAX_MULTI_LIMIT; i++ ) {

	 if( FullMaskText[i][0] != '\0' ) {	/* Make sure its not empty */

 	     fs_first = TRUE;			/* Global FLAG so filename is not
						 * erased during rdir
						 */
	     /* Build each path */
	     strcpy( FullMaskText[i], fs_back( ad_fpath ) + 1 );
	     if( !r_dir( ad_fpath, ( BYTE *)ad_select, &count, TRUE ) )
		return( FALSE );
	 }
      }

      if ( count )
	  do_rsort( ad_fsnames, count, CurSort ); 

      strcpy( MaskTemplate, fs_back( ad_fpath ) + 1 );     /* Build Master image with multiple masks */

      CheckFSPath();

      SetupSelFile( ( BYTE *)ad_select );		/* Try to display the file within the scroll area */

      return( TRUE );
}



/* SetupSelFile
 * ====================================================================
 * Setup the file selector to display the filename.  We adjust the
 * index to display the filename within the scroll area if it exists.
 */
MLOCAL VOID
SetupSelFile( BYTE *fname )
{
      WORD out;

      if( *fname ) {		
         unfmt_str( fname, TempPath );	      
         out   = FindFSFile( TempPath, 0, fs_count );
         if( out != -1 ) {
	    if( fs_count > NM_NAMES ) {
   	        fs_topptr = min( out, fs_count - NM_NAMES );
	        r_sfiles( fs_topptr, 1 );
	    }
	    else
		r_sfiles( 0, 0 );

	    ob_change( ad_fstree, ( out - fs_topptr ) + F1NAME, SELECTED, TRUE );		  
         }
	 else
	   r_sfiles( 0, 0 );		/* show form the top	  */		
      }
      else 
         r_sfiles( 0, 0 );		/* Setup slider sizes etc...*/
}



/* IsFullMaskEmpty()
 * ====================================================================
 * Check to see if the Full 8.3 Masks are empty. If so, return TRUE.
 */
MLOCAL WORD
IsFullMaskEmpty( VOID ) 
{
   REG WORD i;

   for( i = 0; i < MAX_MULTI_LIMIT; i++ ) {
      
      if( FullMaskText[i][0] )
	 return( FALSE );
   }
   return( TRUE );
}




/* FindFSFile()
 * ====================================================================
 * Searches the ad_fsnames structure to see if a file is already there.
 * Returns the index if found.
 * -1 if not found.
 * 
 * IN:	str     - pointer to filename string to look for
 *	attrib  - attributes of the file to look for
 *	count   - # of files to search through ( UPPER LIMIT )
 *
 *  GLOBALS:
 *	ad_fsnames - pointer to head of internal database containing
 *		     all of the files
 *	 
 */
WORD
FindFSFile( BYTE *str, BYTE attrib, WORD count )
{
    BYTE      fname[ LEN_FSNAME ];
    REG WORD  index;
    FSTRUCT   *fsnames;

    index = 0;
    fsnames = ( FSTRUCT *)ad_fsnames;

    if( attrib & F_SUBDIR ) /* if subdirectory	*/ 
       fname[0] = 7;	    /* subdirectory     */
    else
       fname[0] = 0x20;	    /* filename         */

    fmt_str( str, &fname[1] );

    for( index = 0; index < count; index++ ) {
	if( strcmp( fname, ( BYTE *)fsnames[ index ].snames ) ) {
	   return( index );
	}

    }
    return( -1 );
}






/* SingleMaskDialogHandler()
 * ====================================================================
 * Handles the Dialog Box that displays *.3 masks.  Allows
 * the user to edit and also select 8.3 masks.
 */
VOID
SingleMaskDialogHandler( VOID )
{
     WORD flag, mn_item;

     flag = DoSingleMaskDialog( &mn_item );

     switch( flag ) {
	case ETCANCEL:			   /* Do Cancel! */
	     break;

	case ETEDIT:			   /* Do Multiple Mask Dialog Box      */
   	     if( !DoFullMaskDialog())	   /* Display Multiple Mask Dialog box */
                 break;		   	   /* If cancel, just exit             */
      	     SaveFSelect( TempPath );	   /* Save Out to DISK FSELECT.INF     */
      	     MaskTailEnd( mn_item ); 	   /* And perform tailend stuff	       */
      	     break;

        case ETOK:			     /* Hit the OK!			     */
					     /* Check if we're MSPECIAL or not empty */
	     if( mn_item == MSPECIAL ) {
   	        if( IsFullMaskEmpty() ) {
                    if( !DoFullMaskDialog())  /* Display Multiple Mask Dialog box */
	               break;		      /* If cancel, just exit             */
         	    SaveFSelect( TempPath );  /* Save Out to DISK FSELECT.INF	  */
	        }
	        else
	           BuildFullMask();	     /* Build the mask string instead.   */
	    }
	    if(( CurMask != mn_item ) || ( mn_item == MSPECIAL ) )
		MaskTailEnd( mn_item );
	    break;

	default:
	    break;

    }		/* End of switch( flag ) */
}






/* DoSingleMaskDialog()
 * ====================================================================
 * Single Mask Dialog Box - displays the permanent and editable
 * masks in dialog box format.
 */
WORD
DoSingleMaskDialog( WORD *item )
{
     WORD  flag;
     REG   WORD  i;
     REG   BYTE  *sptr, *dptr;
     REG   WORD  obj;
     WORD  start_obj;
     GRECT rect;
     WORD  out;
     WORD  len;

     start_obj = ETEBEG;			/* Sets a starting editable text field */

     for( i = ETPBEG; i <= ETPTMP; i++ )	/* Deselects the Permanent Masks       */
       ad_edit[ i ].ob_state &= ~SELECTED;

     for( i = ETEBEG; i <= ETEEND; i++ )	/* Deselects the Editable Masks	       */
       ad_edit[ i ].ob_state &= ~SELECTED;

					    /* Copies the Editable Masks to our dialog */
     for( i = 0; i < ( MASKUEND - MASKUB + 1 ); i++ ) {
         sptr = scasb( ( BYTE *)ad_mask[ i + MASKUB ].ob_spec, '.' );
	 dptr = ( BYTE *)( ( TEDINFO *)ad_edit[ i + ETEBEG ].ob_spec )->te_ptext;
	 strcpy( sptr + 1, dptr );
     }

     /* --------------------------------------------------------------------------
      * Copy over the current text for *.TMP and make sure its wide enuf.
      * The format is '<space><space>*.TMP<space>'
      * --------------------------------------------------------------------------
      */
     dptr = ( BYTE *)( ( TEDINFO *)ad_edit[ ETPTMP ].ob_spec )->te_ptext;
     strcpy( ( BYTE *)ad_mask[ MASK_END ].ob_spec, dptr );

     while( ( len = strlen( dptr ) ) < 8 )
       strcat( " ", dptr );
     

     /* --------------------------------------------------------------------------
      * Select an object ( mask ) in our dialog box which matches the same
      * one in our mask drop down menu.
      * --------------------------------------------------------------------------
      */
     obj = ETPBEG;				/* Sets a default selected item	 */
         					
     if( CurMask < ( MSPECIAL - 1 )) {		/* Select a Permanent Mask	 */
	obj = ( CurMask - MASK_BEG ) + ETPBEG;
     }

     if( CurMask == MSPECIAL )			/* Select the Multiple Mask      */
	obj = ETPMULTI;

     if( CurMask == MASK_END )			/* Select the Default TMP mask   */
	obj = ETPTMP;

     if( ( CurMask >= MASKUB ) && ( CurMask <= MASKUEND )) {   /* Editable Mask  */
	obj = ( CurMask - MASKUB ) + ETEBEG;
     }

     ad_edit[ obj ].ob_state |= SELECTED;


     ob_center( ( LONG )ad_edit, &rect );	/* Center and draw the dialog box*/
     ad_edit[ ROOT ].ob_x = rect.g_x;
     ad_edit[ ROOT ].ob_y = rect.g_y;

     ob_draw( ( LONG )ad_edit, ROOT, MAX_DEPTH );


     /* --------------------------------------------------------------------------
      * Since the dialog box uses TouchExits, we stay in a form_do until 
      * OK, Cancel or until they want to display the multiple mask dialog box.
      * --------------------------------------------------------------------------
      */
     do {

       flag = fm_do( ( LONG )ad_edit, start_obj );
       flag &= 0x7FFF;

       if((  flag != ETOK ) && ( flag != ETCANCEL ) && ( flag != ETEDIT ) ) {

	  if(( flag >= ETEBEG ) && ( flag <= ETEEND ) )
	     start_obj = flag;					/* Reset the edit obj*/

          if( flag != obj ) {
	    ad_edit[ obj ].ob_state &= ~SELECTED;		/* clear the old one */
	    ob_draw( (LONG)ad_edit, obj, MAX_DEPTH );

	    ad_edit[ flag ].ob_state |= SELECTED;		/* draw the new one  */
	    ob_draw( (LONG)ad_edit, flag, MAX_DEPTH );

	    obj = flag;
	  }
       }
     }while( ( flag != ETOK ) && ( flag != ETCANCEL ) && ( flag != ETEDIT ) ) ;


     /* ------------------------------------------------------
      * Copy the editable fields that are not blank back to 
      * the mask menu. Check if any masks are already in use
      * also.
      * ------------------------------------------------------
      */
     if( flag == ETOK ) {
        for( i = 0; i < ( MASKUEND - MASKUB + 1 ); i++ ) { /* Default Single Editable Masks*/
            sptr = scasb( ( BYTE *)ad_mask[ i + MASKUB ].ob_spec, '.' );
	    dptr = ( BYTE *)( ( TEDINFO *)ad_edit[ i + ETEBEG ].ob_spec )->te_ptext;

	    if( *dptr ) {
	       out = FindFSMask( dptr );
	       if( !out )				/* copy only if not found. */
	           strcpy( dptr, sptr + 1 );
	    }
        }

        /* ---------------------------------------------------------------
	 * Return the object selected - the obj num will be in the format
	 * of the mask menu.
         * ---------------------------------------------------------------
	 */
        if( ( obj >= ETPBEG ) && ( obj <= ETPEND )) {
	   *item = ( obj - ETPBEG ) + MASK_BEG;
        }

        if( obj == ETPMULTI )
	   *item = MSPECIAL;

        if( obj == ETPTMP )
	   *item = MASK_END;

        if( ( obj >= ETEBEG ) && ( obj <= ETEEND )) {
	   *item = ( obj - ETEBEG ) + MASKUB;
        }

        SaveFSelect( TempPath );  	  /* Save Out to DISK FSELECT.INF */
     }


     if( flag == ETEDIT )		  /* Want Multiple Masks, so treat as such */
	*item = MSPECIAL;

     ad_edit[ flag ].ob_state &= ~SELECTED;
     CleanFSDirt( ad_edit, ROOT, ( OBJECT *)ad_fstree );

     return( flag );
}



/* EditMaskViaShiftClick()
 * ====================================================================
 * Edits a mask in the mask menu via a shift-click
 */
VOID
EditMaskViaShiftClick( WORD mn_item )
{
    REG BYTE *sptr, *dptr;
    WORD flag, out;
    LONG tree;
   
    tree = ( LONG )ad_fstree;

    if( ( mn_item >= MASKUB ) && ( mn_item <= MASKUEND )) { 	 /* The selected Mask is editable */

	sptr = ( BYTE *)( ( TEDINFO *)ad_medit[ MASKNAME ].ob_spec )->te_ptext;
	dptr = scasb( ( BYTE *)ad_mask[ mn_item ].ob_spec, '.' ) + 1;  /* get pointer past '.' */
	strcpy( dptr, sptr );

	/* -----------------------------------------------------------
	 * Kick up a dialog to allow the user to change the single
	 * masks.  If the user enters a blank string, treat it as a cancel
	 * -----------------------------------------------------------
	 */
	do {

    	       flag = fs_formdo( ad_medit, 0 );

	       CleanFSDirt( ad_medit, ROOT, ( OBJECT *)tree );

	       if( flag == MASKOK ) {		/* The user hit OK! */

		   if( *sptr ) {		/* Make sure its not blank first, then copy it... */
		      out = FindFSMask( sptr );       /* Check to see if it already exists		  */

		      if( !out || ( out == mn_item ) ) {  /* if we're the same item, its ok also */
		            strcpy( sptr, dptr );
		  	    SaveFSelect( TempPath );  	  /* Save Out to DISK FSELECT.INF */
		            MaskTailEnd( mn_item );       /* Its OK, process as normal    */
			    break;			  /* Breaks out of while loop     */
		      }
		      else
		        fm_show( MSKEXIST, 0x0L, 1 );  /* The mask already exists   */
			    			       /* AND REPROCESS...LOOP      */
		   }
		   else
		    break;			       /* the user entered blank text */
						       /* Breaks out of while loop    */
	       }

	}while( flag == MASKOK );		  /* LOOP UNTIL DONE         */
								

    }
    else {	/* The user click on a non-editable menu item */

       if( mn_item == MSPECIAL ) {	/* Shift Click always enters this   */
	   if( !DoFullMaskDialog())	/* Display Multiple Mask Dialog box */
	       return;			/* If cancel, just exit             */
	   SaveFSelect( TempPath );	/* Save Out to DISK FSELECT.INF	    */
	   MaskTailEnd( MSPECIAL );	/* And perform tailend stuff	    */
       }
       else
          fm_show( MSKNOGO, 0x0L, 1 );  /* The Masks selected were not editable */
    }
}





/* ====================================================================
 * FILE I/O SECTION
 * ====================================================================
 */



/* fs_infpath()
 * ====================================================================
 * Make the INF path that we will read/write to.
 * CURRENTLY, it will ALWAYS be C:\FSELECT.INF
 */
VOID
fs_infpath( BYTE *buffer )
{
      strcpy( fsinfpath, buffer );	/* C:\FSELECT.INF */
      buffer[0] = ( isdrive() & 0x04 ) ? 'C' : 'A';
}





/* push_string()
 * ====================================================================
 * Save the string to the buffer.
 */
BYTE
*push_string( REG BYTE *pcurr, REG BYTE *pstring )
{

     while( ( *pstring ) && ( pstring ) )
	*pcurr++ = *pstring++;
     *pcurr++ = '@';
     return( pcurr );
}




/* SaveFSelect()
 * ====================================================================
 * Write the FSELECT.INF file out to the drive.
 */
WORD
SaveFSelect( BYTE *path )
{
    LONG  	size;
    BYTE  	*buf;
    REG BYTE	*pcurr;
    REG WORD	i;
    REG BYTE	*sptr;
    UWORD	len;
    WORD	handle;


    if( size = ( LONG )dos_xalloc( 0x800L, 3 ) ) {	/* 2048 bytes */
	
	buf = pcurr = ( BYTE *)size;
    }
    else {
      return( FALSE );	/* not enough memory */
    }

   /* ----------------------------------------------
    * Write out Non-Blank Used Paths
    * ----------------------------------------------
    */
    for( i = 0; i < MAX_USED_PATHS; i++ ) {
	if( UsedPaths[i][0] ) {	

	   *pcurr++ = '#';
	   *pcurr++ = 'u';
	   *pcurr++ = ' ';

	   pcurr = push_string( pcurr, UsedPaths[i] );

	   *pcurr++ = 0x0d;
	   *pcurr++ = 0x0a;
	}
    }



   /* ----------------------------------------------
    * Write out Multiple Masks 8.3, if any
    * ----------------------------------------------
    */
   for( i = 0; i < MAX_MULTI_LIMIT; i++ ) {
       if( FullMaskText[i][0] ) {

	   *pcurr++ = '#';
	   *pcurr++ = 'm';
	   *pcurr++ = ' ';

	   pcurr = push_string( pcurr, FullMaskText[i] );

	   *pcurr++ = 0x0d;
	   *pcurr++ = 0x0a;
	
       }
   }



   /* ----------------------------------------------
    * Write out Single Editable Masks
    * ----------------------------------------------
    */
   for( i = MASKUB; i <= MASKUEND; i++ ) {

       sptr = ( BYTE *)ad_mask[ i ].ob_spec;

       *pcurr++ = '#';
       *pcurr++ = 's';
       *pcurr++ = ' ';

       pcurr = push_string( pcurr, sptr + 2 );

       *pcurr++ = 0x0d;
       *pcurr++ = 0x0a;
   }

   *pcurr = '\0';	/* Set the end of the string */

   len = strlen( buf );


   /* ----------------------------------------------
    * Write out the buffer
    * ----------------------------------------------
    */
   fs_infpath( path );			/* Build Path */

   handle = dos_create( path, 0x0 );

   if( handle > 0 ) {

       size = dos_write( handle, len, buf );

       dos_close( handle );

       if( size < ( LONG )len )
         dos_delete( path );
   }

   dos_free( ( LONG )buf );
   gr_mouse( 0, 0x0L );		/* Force Arrow */

   return( TRUE );
}







/* ReadFSelect()
 * ====================================================================
 * Read in the FSELECT.INF file and initialize the file selector
 * global variables.
 */
WORD
ReadFSelect( BYTE *path )
{
    REG BYTE    *pcurr, *buf;
    LONG    size;
    FSTRUCT *old_dta, newdta;
    WORD    error;
    WORD    handle;

    old_dta = ( FSTRUCT *)dos_gdta();
    dos_dta( ( LONG )&newdta );

    fs_infpath( path );

    error = dos_sfirst( ( LONG )path, 0 );	/* Look for 'C:\FSELECT.INF' */

    if( !error ) {	/* File not found! */
	dos_dta( ( LONG )old_dta );
	return( FALSE );
    }

    if( size = ( LONG )dos_xalloc( newdta.d_length + 1L, 3 ) ) {
	
	buf = pcurr = ( BYTE *)size;
    }
    else {
      dos_dta( ( LONG )old_dta );
      return( FALSE );	/* not enough memory */
    }


    /* Read in the file and start processing */
    handle = dos_open( path, 0x0 );

    if( handle > 0 ) {
       dos_read( handle, ( UWORD )newdta.d_length, ( LONG )buf );
       dos_close( handle );
       fs_infscan( buf );
    }

    dos_free( ( LONG )buf );    
    dos_dta( ( LONG )old_dta );
    return( TRUE );
}




/* fs_infscan()
 * ====================================================================
 * Scan the FSELECT.INF file for the data to shove into the global
 * variables.
 */
VOID
fs_infscan( BYTE *buffer )
{
      REG BYTE *pcurr;
      BYTE	temp;
      WORD	ucount;			/* Previous Paths Count */
      WORD	scount;			/* Single Mask Count    */
      WORD	mcount;			/* Multiple Mask count  */
      REG BYTE      *sptr;


      ucount = scount = mcount = 0;
      pcurr = buffer;

      while( *pcurr ) {

	 if( *pcurr++ == '#' ) {
	    temp = *pcurr;
	    pcurr += 2;

	    switch( temp ) {
	      case 'u':			/* Previous Paths */
			if( ucount < MAX_USED_PATHS ) {
			   pcurr = fs_scan_string( pcurr, UsedPaths[ ucount++ ] );
			}
			break;

	      case 's': 		/* Single Masks   */
			if( scount < ( MASKUEND - MASKUB + 1 ) ) {
			   sptr = ( BYTE *)ad_mask[ MASKUB + scount ].ob_spec;
			   pcurr = fs_scan_string( pcurr, sptr + 2 );
			   scount++;
			}
			break;

	      case 'm': 		/* Multiple Masks */
			if( mcount < MAX_MULTI_LIMIT ) {
			   pcurr = fs_scan_string( pcurr, FullMaskText[ mcount++ ] );
			}
			break;

	      default:
			break;
	    }				/* End of ' switch( temp ) '	    */
	 }				/* End of ' if( *pcurr++ == '#' ) ' */
      } 				/* end of 'while( *pcurr )' 	    */
}




/* fs_scan_string()
 * ====================================================================
 * Scan a string from the FSELECT.INF file
 */
BYTE
*fs_scan_string( REG BYTE *pcurr, REG BYTE *ppstr )
{
     while( *pcurr == ' ' )
	pcurr++;

     while( ( *pcurr != '@' ) && ( *pcurr ) )
	*ppstr++ = *pcurr++;

     *ppstr = '\0';
     pcurr++;	
     return( pcurr );
}



/* ====================================================================
 * END OF FILE I/O SECTION
 * ====================================================================
 */



 
/* ====================================================================
 * START OF FORCE READ DIRECTORY AND ERROR HANDLING
 * ====================================================================
 */


/* ForceReadDirectory()
 * ====================================================================
 * Perform a new FLABEL call ---Force a read of the directory
 * with Path Checking, Read Directory, Read Success, Read Failure,
 * Reset Drive and Mask, Set Drive Menu, Set Mask Menu.
 */
VOID
ForceReadDirectory( VOID )
{
      WORD flag;

      for( ;; ) {
         RDirCheckPath();	     /* Check the path for blanks and extensions */
         flag = RDirReadDirectory(); /* Force a Single Mask Read Directory.      */

	 if( !flag )		     /* SUCCESS!!!!!! --Exit LOOP! 		 */
	   break;

	 if( flag == 1 ) {	     /* Perform RDirSuccess() then break;	 */
	    RDirSuccess();	     /* Was a Failure to read, but also we are   */
	    break;		     /* Displaying Multiple mask settings	 */
	 }

	 /* if flag == 2, then failure, force a new entire READ of the path.
	  * This is when we failed to read the directory and we are using
	  * a single mask.
	  */
      };

      RDirTailEnd();		  /* Reset Drive, MAsk, Drive Menu, Mask Menu */
}




/* RDirCheckPath()
 * ====================================================================
 * This routine checks:
 * 1) Is the path blank.
 * 2) Is the extension AOK
 * 3) Any Backslash?
 * 4) If no extension, copy one over
 */
VOID
RDirCheckPath( VOID )
{
      REG BYTE *sptr;

      if ( !*ad_fpath )				   /* If the path is blank, restore the copy */
	strcpy( pathcopy, ad_fpath );

      /* This is in case the string starts with '\\' */
      if( ad_fpath[0] == '\\' ) {		   /* Any <drive><:>?   */
	strcpy( "C:", TempPath );		   /* No-add one in	*/
	TempPath[0] = defdrv + 'A';
	strcat( ad_fpath, TempPath );
	strcpy( TempPath, ad_fpath );
      }

      /* This is in case the string doesn't have a drive colon designation */			
      if( ad_fpath[1] != ':' ) {		   /* Any <drive><:>?   */
	strcpy( "C:\\", TempPath );		   /* No-add one in     */
	TempPath[0] = defdrv + 'A';
	strcat( ad_fpath, TempPath );
	strcpy( TempPath, ad_fpath );
      }
 
      strcpy( fs_back( ad_fpath ), &fcopy[0] );	   /* Copy off the file extension     */

      if ( ( fcopy[0] == '\\' ) && ( fcopy[1] ) )  /* Check if the extension is AOK...*/
	strcpy( fcopy, fsname );		   /* yes - 			      */	

      if ( fcopy[0] != '\\' )			   /* any slash ?  		      */
      {
	fsname[0] = '\\';			   /* Add a slash in if no slash      */
	strcpy( fcopy, fsname + 1 );
      }

      if ( !fcopy[1] ) 				   /* if no extension	     */
      {
	strcpy( wslstr, &fsname[0] ); 		   /* Add a wildcard one in. */
	strcat( wildstr, ad_fpath );
      }


      sptr = scasb( &fcopy[1], '.' );
      if( !*sptr ) {				   /* No mask, add one in    */
	 strcpy( ".*", &fsname[0] );
	 strcat( ".*", ad_fpath );
      }


}




/* RDirReadDirectory()
 * ====================================================================
 * Perform a Read Directory and include Success and Failure Routines
 * GLOBALS:
 *	1)	ad_fpath
 *	2)	scopy
 *	3)	count
 *	4)	flag - FALSE - Sets fs_count and count to ZERO.
 * RETURN: 0 - SUCCESS - no problems
 *	   1 - ERROR - Hit the failure, but just perform update botptr
 *		       and save off path. aka RDirSuccess().
 *		       This is for Multiple Masks
 *	   2 - ERROR - FAILURE - Perform Full Read Directory again.
 *		       This is for single masks
 *	   0 - ERROR - RDirFailure() but since its not a firstry, no
 *		       need to force a new read.
 */
WORD
RDirReadDirectory( VOID )
{
      if ( r_dir( ad_fpath, scopy, &count, FALSE ) ) {
	 RDirSuccess();
	 return( FALSE );
      }
      else
	 return( RDirFailure() );
}



/* RDirSuccess()
 * ====================================================================
 * After calling r_dir ( force a read of the directory ), call THIS
 * routine if a SUCCESS
 */
VOID
RDirSuccess( VOID )
{
    strcpy( ad_fpath, pathcopy );	/* copy current dir	*/

    if ( count > NM_NAMES )		/* more than 9 items	*/
	  botptr = count - NM_NAMES;
    else
          botptr = 0;
}




/* RDirFailure()
 * ====================================================================
 * After calling r_dir ( force a read of the directory ), call THIS
 * routine if a FAILURE
 *
 * RETURN: 0 - If not firstry, return 0
 *	   1 - If firstry, Restore for Multiple Masks Path
 *	   2 - If firstry, Restore for single Mask ( force a new read ).
 */
WORD
RDirFailure( VOID )
{
    LONG tree;

    tree = ( LONG )ad_fstree;

    gr_mouse( 0, 0x0L );
    strcpy( pathcopy, ad_fpath );

    /* Check path and shorten it if necessary to fit.*/
    CheckFSPath();

    ob_draw( tree, FDIRECTO, MAX_DEPTH );

    if( firstry ) {			/* First Try through? */
	 firstry = FALSE;

      if( CurMask != MSPECIAL )		
	 return( 2 );
      else 
	 return( 1 );
    }
    return( FALSE );			/* No need to force a read */
}



/* RDirTailEnd()
 * ====================================================================
 * Reset the Drive and Mask
 * Set the Drive Popup Menu
 * Set the Mask Popup Menu
 */
VOID
RDirTailEnd( VOID )
{
    ResetDriveAndMask();
    SetDriveMenu();
    SetMaskMenu();
}



/* ResetDriveAndMask()
 * ====================================================================
 * Reset the Drive and Mask
 * CALLED ONLY BY RDIRTailEnd()
 */
VOID
ResetDriveAndMask( VOID )
{

      firstry = FALSE;

      /* reset the last one	*/
      if ( *( ad_fpath + 1 ) == ':' )	/* if there a drive */
         defdrv = (WORD)( *ad_fpath - 'A' );

      curdrv = defdrv + DRIVEA;


      /* Copy the File Extension from the FTITLE object so that when a return
       * is hit, we can check if its different and force a new read.
       */
      strcpy( ( BYTE *)ad_title, TitleCopy );
}




/* SetDriveMenu()
 * ====================================================================
 * Setup the Disk Drive Popup Menu.	CJG 06/29/93
 * CALLED ONLY BY RDIRTailEnd()
 */
VOID
SetDriveMenu( VOID )
{
    BYTE   *sptr;
    OBJECT *obj;
    LONG   tree;

    obj  = ( OBJECT *)ad_fstree;
    tree = ( LONG )ad_fstree;

    sptr = ( BYTE *)ad_drives[ DRIVE00 ].ob_spec;
    *( sptr + 2 ) = *ad_fpath;

    sptr = ( BYTE *)obj[ DBUTTON ].ob_spec;
    *( sptr + strlen( sptr ) - 2 ) = *ad_fpath;
    ob_draw( tree, DBUTTON, MAX_DEPTH );
}





/* SetMaskMenu()
 * ====================================================================
 * Setup the File Mask Menu and Button
 * CALLED ONLY BY RDIRTailEnd()
 */
VOID
SetMaskMenu( VOID )
{
     WORD   	i;
     BYTE   	*dptr;
     OBJECT 	*obj;
     LONG	tree;

     obj  = ( OBJECT *)ad_fstree;
     tree = ( LONG )ad_fstree;


     for( i = MASK_BEG; i <= MASK_END; i++ )
        ad_mask[ i ].ob_state &= ~CHECKED;

     CurMask = FindFSMask( ( BYTE *)ad_title );
     if( !CurMask ) {			/* Can't find it in the menu? then put it at the end */	

	 if( *( BYTE *)ad_title != ' ' ) {	/* If not blank....then put it at the end */
             CurMask = MASK_END;
	     dptr = scasb( ( BYTE *)ad_mask[ CurMask ].ob_spec, '.' ); /* Copy the File Extension     */
	     strcpy( ( BYTE *)ad_title, dptr + 1 );	 	       /* into the last menu item     */
	 }
	 else
	     CurMask = MASK_BEG;			/* Otherwise, set it to the *.* */
      }

      dptr = ( BYTE *)ad_mask[ CurMask ].ob_spec;	/* Set the type title button    */
      obj[ EBUTTON ].ob_spec = ( LONG )( dptr + 2 );
      ob_draw( tree, EBUTTON, MAX_DEPTH );

      ad_mask[ CurMask ].ob_state |= CHECKED;
}




/* ====================================================================
 * END OF FORCE READ DIRECTORY AND ERROR HANDLING
 * ====================================================================
 */
