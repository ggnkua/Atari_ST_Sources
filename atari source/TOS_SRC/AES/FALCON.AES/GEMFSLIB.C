/*
*************************************************************************
*			Revision Control System
* =======================================================================
*  $Revision: 2.2 $	$Source: /u2/MRS/osrevisions/aes/gemfslib.c,v $
* =======================================================================
*  $Author: mui $	$Date: 89/04/26 18:23:06 $	$Locker: kbad $
* =======================================================================
*  $Log:	gemfslib.c,v $
* Revision 2.2  89/04/26  18:23:06  mui
* TT
* 
* Revision 2.1  89/02/22  05:26:30  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.14  88/11/02  12:00:29  mui
* Change fs_fnum from word to long
* 
* Revision 1.13  88/11/01  16:07:28  kbad
* fix hidden/system/readonly files (now they don't show)
* 
* Revision 1.12  88/11/01  11:21:04  kbad
* Reg opt @ r_dir, r_files
* 
* Revision 1.11  88/10/24  10:31:33  mui
* click anywhere to reload the directory
* 
* Revision 1.10  88/10/17  13:37:39  kbad
* yanked fs_start to fix fs_input growing clip rect problem
* 
* Revision 1.9  88/09/09  17:11:25  kbad
* Fixed the colon cancer - fixed fs_back colon handling
* 
* Revision 1.8  88/08/17  20:35:35  mui
* change to handle more than 16 devices
* 
* Revision 1.7  88/07/29  01:30:12  kbad
* change r_files to fix filename copy
* 
* Revision 1.6  88/07/28  21:25:19  mui
* use GEMDOS to handle all path functions
* 
* Revision 1.5  88/07/08  11:51:38  mui
* don't read them in until it is needed
* 
* Revision 1.4  88/07/07 17:55:48  mui
* Get default directory from GEMDOS
*
* Revision 1.3  88/07/01 16:21:52  mui
* Change r_files to read in everything once
*
* Revision 1.2  88/07/01 15:49:12  mui
* Fix fs_input to handle drive: with no extension
*
* Revision 1.1  88/06/02  12:33:50  lozben
* Initial revision
* 
*************************************************************************
*/
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
/*	Mininum height of evelator is 1		1/6/92		D.Mui	*/
/*	Add ini_fsel to adjust drive boxes	7/15/92		D.Mui	*/
/*	Arrows, Sliders and Close Box get SELECTED 08/10/92     c.gee   */

/*
*	-------------------------------------------------------------
*	GEM Application Environment Services		  Version 1.1
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1985			Digital Research Inc.
*	-------------------------------------------------------------
*/

#include <portab.h>
#include <machine.h>
#include <struct88.h>
#include <obdefs.h>
#include <taddr.h>
#include <dos.h>
#include <gemlib.h>
#include <vdidefs.h>
#include <gemusa.h>


#define LEN_FSNAME 16
#define NM_NAMES 9
#define DEVICES	16	/* sixteen devices	*/
#define LPATH	128

typedef	struct	fstruct
{
	BYTE	snames[LEN_FSNAME];
} FSTRUCT;

EXTERN	BYTE	toupper();			
EXTERN	BYTE	*dos_alloc();
EXTERN	LONG	rs_str();
EXTERN	BYTE	*dos_avail();	
EXTERN  WORD	DOS_AX;
EXTERN  LONG	trap();
EXTERN	LONG	trap13();

EXTERN	WS	gl_ws;
EXTERN  GRECT	gl_rcenter;
EXTERN  LONG	ad_sysglo;
EXTERN  LONG	ad_armice;
EXTERN  LONG	ad_hgmice;
EXTERN  WORD	gl_hbox;
EXTERN  THEGLO	D;
EXTERN  WORD	gl_button;	/* cjg */


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

GLOBAL BYTE	*ad_fsdta;
GLOBAL BYTE     wildstr[] = "*.*";
GLOBAL BYTE	wslstr[] = "\\*.*";

MLOCAL BYTE	fsname[40];
MLOCAL BYTE	fcopy[40];
MLOCAL BYTE	*pathcopy;		/* path copy	*/
MLOCAL WORD	defdrv;

typedef struct pathstruct
{
	BYTE	pxname[128];
} PATHSTRUCT;

GLOBAL PATHSTRUCT *pxpath;	


/*
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



/*
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
REG	UWORD	i,j;
	WORD	label,last,ret;
REG	LONG	tree;
	LONG	addr,mul,savedta,savepath;
	UWORD	botptr,count,value;
	WORD	xoff,yoff,mx,my,bret;
	BYTE	dirbuffer[122];
	BYTE	*chrptr;	
	BYTE	scopy[16];
	BYTE	chr;
	WORD	curdrv,savedrv;
	LONG	**lgptr;
	GRECT	clip;
	WORD	firstry;
	OBJECT  *xtree;			/* cjg */
	WORD    newend, oldend;

/*
*	Start up the file selector by initializing the fs_tree
*/
	rs_gaddr(ad_sysglo, R_TREE, SELECTOR, &ad_fstree);
	ob_center(ad_fstree, &gl_rfs);

	firstry = TRUE;
	fs_first = TRUE;		/* first enter		*/	
	last = F1NAME;			/* last selected file	*/

	defdrv = (WORD)dos_gdrv();	/* get the default drive*/
	savedrv = defdrv;

	curdrv = defdrv + DRIVEA;
					/* save for default dr	*/ 
	pxpath = dos_alloc( (LONG)( ( WORD )LPATH * ( WORD )( DEVICES + 1 ) ) );

	if ( !pxpath )
	  goto bye2;
					/* allocate dta buffer	*/
	ad_fsdta = dos_alloc( 0x00000100L );	

	if ( !ad_fsdta )		/* no buffer, bail out	*/
	  goto bye;

					/* get all the memory	*/
	mul = dos_avail();
					/*	LEN_FSNAMES;	*/
	fs_fnum = mul / (LONG)LEN_FSNAME;	

	if ( ( !mul ) || ( fs_fnum < (LONG)NM_NAMES ) )
	{
	  dos_free( ad_fsdta );
bye:	  dos_free( pxpath );
bye2:	  fm_show( NOMEMORY, 0x0L, 1 );
	  return( FALSE );
	}
	else
	  ad_fsnames = dos_alloc( mul );  


	savepath = pxpath;		/* save the address	*/
	pathcopy = savepath;
	pxpath = savepath + (WORD)LPATH;	

	fm_dial( FMD_START, &gl_rcenter, &gl_rfs );

	tree = ad_fstree;
	xtree = ( OBJECT * )tree;

	lgptr = OB_SPEC( FDIRECTORY );	/* change the buffer pointer */
	**lgptr = dirbuffer;

	fs_sset( tree, FLABEL, lstring, &addr, &addr );
	fs_sset( tree, FDIRECTORY, "", &ad_fpath, &addr ); 
	fs_sset( tree, FTITLE, "", &ad_title, &addr );
	fs_sset( tree, FSELECTION, "", &ad_select, &addr );
						/* get the current drive */
	count = isdrive();
	j = 1;
				/* start from A drive set the button	*/
	for ( i = DRIVEA; i <= DRIVEP; i++ )	
	{
	  LWSET( OB_STATE( i ), ( count & j ) ? NORMAL : DISABLED );
	  j = j << 1;
	}


	label = F1NAME;				/* clean up the files 	*/

	for ( i = 0; i < NM_NAMES; i++ )	/* clean up fields	*/
	{
	  fs_sset( tree, label, " ", &addr, &addr ); 
	  LWSET( OB_STATE( label++ ), NORMAL );
	}
						/* save the current dta	  */
	savedta = trap( 0x2F );

	gsx_gclip( &clip );			/* get the clipping rect  */
						/* set the new one	  */
	gsx_sclip( &gl_rfs );
						/* reset the height	*/
	LWSET( OB_Y( FSVELEV ), 0 );	
	LWSET( OB_HEIGHT( FSVELEV ), LWGET( OB_HEIGHT( FSVSLID ) ) );

	gr_mouse( 258, 0x0L );
	gsx_mfset( ad_armice );			/* arrow pointer	*/

	ob_draw( tree, 0, MAX_DEPTH );		/* draw the box		*/

	fmt_str( pisel, scopy );		

	strcpy( pipath, ad_fpath );		/* make a copy		*/

	pathcopy[0] = defdrv + 'A';		/* Backup path		*/
	pathcopy[1] = ':';
	strcpy( wslstr, &pathcopy[2] );

	count = 0;
	fs_topptr = 0;
	botptr = 0;

	ret = FDIRECTORY;			/* initial action	*/

	do
	{
cg_1:
	  value = 1;				/* scroll factor	*/

	  switch ( ret )
	  {
	    case FSVSLID:
	      ob_offset( tree, FSVELEV, &xoff, &yoff );
	      value = NM_NAMES;
	      if ( my < yoff )
		goto up;
	      else if (my >= yoff + xtree[FSVELEV].ob_height)
	        goto down;
	    /* else fall through */

	    case FSVELEV:
	      if( !( xtree[ FSVELEV ].ob_state & SELECTED ))
		FXSelect( xtree, FSVELEV );
              gsx_sclip( &gl_rfs );
	      
	      take_ownership( TRUE );
	      value = gr_slidebox( tree, FSVSLID, FSVELEV, TRUE );
	      take_ownership( FALSE );
	      if ( count > NM_NAMES )
	      {	
	        mul = ((LONG)( count - NM_NAMES )) * (LONG)(value);
	        if ( fs_topptr != ( mul / 1000 ) )
	        {
		  fs_topptr = mul / 1000;
	          r_sfiles( fs_topptr, value );
	        }
	      }
	      
	      goto out;
	 	
down:	    case FDNAROW:			/* scroll down	*/
	      if ( fs_topptr >= botptr )
	      {
out:		FXWait();
	        FXDeselect( xtree, ret );
                gsx_sclip( &gl_rfs );
		break;
	      }

	      if ( (fs_topptr + value) <= botptr )
	        fs_topptr += value;
	      else
		fs_topptr = botptr;

	      goto sfiles;

up:	    case FUPAROW:			/* scroll up	*/
	      if ( !fs_topptr )
	      {
		FXWait();
	        FXDeselect( xtree, ret );
                gsx_sclip( &gl_rfs );
		break;
	      }

	      if ( (WORD)(fs_topptr - value) >= 0 )
	        fs_topptr -= value;
	      else
		fs_topptr = 0;

sfiles:
	      if( !( xtree[ ret ].ob_state & SELECTED ))
		FXSelect( xtree, ret );

              gsx_sclip( &gl_rfs );

	      r_sfiles( fs_topptr, value );

	      dsptch();		
	      if( gl_button )
		  goto cg_1;

	      FXWait();
	      FXDeselect( xtree, ret );
	      gsx_sclip( &gl_rfs );
	      break;

	    case FCLSBOX:			/* close box		*/

	      oldend = strlen( ad_fpath );	/* find # char in string*/
	      if( !( xtree[ FCLSBOX ].ob_state & SELECTED ))
		   FXSelect( xtree, FCLSBOX );
	      gsx_sclip( &gl_rfs );

	      *( fs_back( ad_fpath ) ) = 0;	/* back to last path	*/
	      strcpy( ad_title, fs_back( ad_fpath ) + 1 );
	      
						/* fall through		*/
	    case FDIRECTORY:
rdir:
	      if ( !*ad_fpath )
		strcpy( pathcopy, ad_fpath );
 
	      strcpy( fs_back( ad_fpath ), &fcopy[0] );
						/* extension OK ?	*/
	      if ( ( fcopy[0] == '\\' ) && ( fcopy[1] ) )
		strcpy( fcopy, fsname );	/* yes			*/	

	      if ( fcopy[0] != '\\' )		/* any slash ?		*/
	      {
		fsname[0] = '\\';
		strcpy( fcopy, fsname + 1 );
	      }

	      if ( !fcopy[1] ) 			/* if no extension	*/
	      {
		strcpy( wslstr, &fsname[0] ); 
		strcat( wildstr, ad_fpath );
	      }

	      if ( r_dir( ad_fpath, scopy, &count ) )
	      {
		strcpy( ad_fpath, pathcopy );	/* copy current dir	*/
	        if ( count > NM_NAMES )		/* more than 9 items	*/
		  botptr = count - NM_NAMES;
	        else
	          botptr = 0;
	      }
	      else
	      {
rdir5:		strcpy( pathcopy, ad_fpath );
	        ob_draw( tree, FDIRECTORY, MAX_DEPTH );
		if ( firstry )
		{
		  firstry = FALSE;
		  goto rdir;
		}
	      }
		
	      firstry = FALSE;

				/* reset the last one	*/
	      if ( curdrv <= DRIVEP ) 
	        ob_change( tree, curdrv, NORMAL, TRUE );

	      if ( *( ad_fpath + 1 ) == ':' )	/* if there a drive */
	        defdrv = (WORD)( *ad_fpath - 'A' );

	      curdrv = defdrv + DRIVEA;

	      if ( curdrv <= DRIVEP ) 
	        ob_change( tree, curdrv, SELECTED, TRUE );


	      /* CJG 08/11/92 */
	      if( ret == FCLSBOX )
	      {
	        newend = strlen( ad_fpath );	/* find # char in string*/

	        if( newend != oldend )	        /*  is dir changed ?	*/
	        {
	          if( !( xtree[ FCLSBOX ].ob_state & SELECTED ))
		     FXSelect( xtree, FCLSBOX );
	          gsx_sclip( &gl_rfs );
	        }
	        else
	        {				/* Hasn't changed, wait arnd*/
		  FXWait();
		  XDeselect( xtree, FCLSBOX );
	          gsx_sclip( &gl_rfs );
		  break;
	        }

		dsptch();
		if( !gl_button )
		{
		    FXWait();
		    XDeselect( xtree, FCLSBOX );
		    gsx_sclip( &gl_rfs );
		}
	        else
		  goto cg_1;
	      }
	      break;

	    case DRIVEA:
	    case DRIVEB:
	    case DRIVEC:
	    case DRIVED:
	    case DRIVEE:
	    case DRIVEF:
	    case DRIVEG:
	    case DRIVEH:
	    case DRIVEI:
	    case DRIVEJ:
	    case DRIVEK:
	    case DRIVEL:
	    case DRIVEM:
	    case DRIVEN:
	    case DRIVEO:
	    case DRIVEP:
	      curdrv = ret;
	      i = ( ret - DRIVEA );		/* get the drive */
	      *ad_fpath = (BYTE)( i + 'A' );	/* stuff into the path */
	      *( ad_fpath + 1 ) = ':';
	      if ( !dos_gdir( i + 1, ad_fpath + 2 ) )
	        goto fs1;
	      else
		goto rdir5;
		
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
	      addr = &ad_fsnames[i + fs_topptr].snames[1];
	      chr = ad_fsnames[i + fs_topptr].snames[0];

						
	      if ( chr == 7 )  		/* is it a directory ?  */
	      {
		unfmt_str( addr, fs_back( ad_fpath ) + 1 );
fs1:
		strcat( &fsname[0], ad_fpath );
		goto rdir;
	      }
	      else  				/* must be a file	*/
	        if ( chr )
	        {				/* clean up the last selected */
		  ob_change( tree, last, NORMAL, TRUE );
		  strcpy( addr, LLGET( LLGET(OB_SPEC(FSELECTION)) ));
		  ob_change( tree, ret, SELECTED, TRUE );		  
		  ob_draw( tree, FSELECTION, MAX_DEPTH );
		  last = ret;
		  if ( bret & 0x8000 )		/* double click		*/ 
		  {
		    ob_change( tree, OK, SELECTED, TRUE );
		    goto fdone;			/* force to exit	*/
		  }
	        }

	      break;

	      default:
	        break;  
	  }					/* end of switch	*/

	  bret = fm_do( tree, FSELECTION );

	  gsx_mxmy( &mx, &my );

	  ret = bret & 0x7FFF;

	  if ( ret == CANCEL )
	    break;

	  if ( !strcmp( ad_fpath, pathcopy ) )/*  is dir changed ?	*/
	  {
	    ob_change( tree, ret, NORMAL, TRUE );
	    ret = FDIRECTORY;			/* force a read again	*/
	  }
	  else {  
		 if ( ret == OK )
	           break;
	       }
	     	
	}while ( ret != CANCEL );

fdone:

	dos_sdrv( savedrv );
	dos_free( ad_fsdta );
	dos_free( ad_fsnames );
	dos_free( savepath );
	strcpy( ad_fpath, pipath );
	unfmt_str( ad_select, pisel );

	if ( ( *pbutton = inf_what( tree, OK, CANCEL ) ) == -1 )
	  *pbutton = NULL;

        ob_change( tree, ret, NORMAL, FALSE );
	fm_dial( FMD_FINISH, &gl_rcenter, &gl_rfs );
	dos_sdta( savedta );
	gsx_sclip( &clip );
	gr_mouse( 259, 0x0L );
	return ( TRUE );
}



/*	read in a directory	*/

	WORD	
r_dir( path, select, count )
	BYTE	*path;
	BYTE	*select;
REG	UWORD	*count;
{
	LONG	tree,addr;
REG	WORD	status,i;
	LONG	h,h1;
	BYTE	filename[16];

	gsx_mfset( ad_hgmice );	  

	if ( ! r_files( path, select, count, filename ) )
	{				/* if failed	*/
	  fm_error( 2 );
	  status = FALSE;
	  goto r_exit;
	}

	fs_count = *count;
	fs_draw( FDIRECTORY, path, &addr, &addr ); 
	fs_draw( FTITLE, filename, &addr, &addr );
	fs_draw( FSELECTION, select, &ad_select, &addr ); 

	tree = ad_fstree;
	fs_topptr = 0;				/* reset top pointer	*/

	h = LWGET( OB_HEIGHT( FSVSLID ) );
	h += ADJ3DPIX << 1;
	if ( *count > NM_NAMES )
	{
	  h1 = *count;
	  h = ( h * NM_NAMES ) / h1;
	}

	if ( !h )				/* min size */
	  h = 1;
	else
	{
	  if ( h > ( ADJ3DPIX << 1 ) )
	    h -= (ADJ3DPIX << 1);	
	}
	LWSET( OB_Y(FSVELEV), 0 );		/* move it to the top	  */
	LWSET( OB_HEIGHT(FSVELEV), (UWORD)h );	/* height of the elevator */
	r_sfiles( 0, 0 );			/* show form the top	  */
	status = TRUE;

r_exit:
	gr_mouse( 260, 0x0L );
	return ( status );
}
	

/*	Read files into the buffer		           */
/*	The buffer size will always be NM_NAMES or more    */
/*	for easy coding and redraw the count will return   */
/*	the actual number of files		           */ 

	WORD
r_files( path, select, count, filename )
REG	BYTE	*path;/*5*/
	BYTE	*select;
	WORD	*count;
REG	BYTE	*filename;/*4*/
{
	REG	WORD	i;/*8*/
		LONG	j;/*2*/
	REG	LONG	k;/*4*/
		WORD	ret/*3*//*,len*/;
/*		LONG	temp,addr;*/
		BYTE	*chrptr;/*7*/
	REG	FSTRUCT	*fsnames;
	REG	WORD	drvid;/*4*/
/*		BYTE	save;*/

	fsnames = ad_fsnames;

	*filename = 0;		/* no file name		*/

				/* uppercase the drive path	*/
	if ( *( path + 1 ) == ':' )
	{
	  *path = toupper( *path );
	  drvid = (WORD)(*path - 'A');	
	}
	else
	  drvid = defdrv;

 				/* the drive present ? 	*/
	k = 1;
	k = k << drvid; 
	j = trap13( 0xa );	/* get the drive map	*/

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
	dos_sdta( ad_fsdta );					
					/* look for all sub dir	*/
	if ( ! ( ret = dos_sfirst( path, 0x37 ) ) )	
	{				/* error		*/
	  if ( DOS_AX != E_NOFILES )	/* it is not no files	*/
	  {				
	    strcpy( filename, chrptr );	/* then return		*/
	    return( FALSE );
	  }
	}

	if ( !fs_first )
	  *select = 0;			/* clean up selection filed */
	else
	  fs_first = FALSE;		/* don't clean up at this   */
					/* time			    */

	for ( i = 0; i < NM_NAMES; i++ )
	  strcpy( " ",  &fsnames[i].snames[0] );

	i = 0;
	  				/* look for directory	*/
	while ( ( ret ) && ( (UWORD)(i) < fs_fnum ) )	
	{
	  if( ad_fsdta[21] & (F_HIDDEN|F_SYSTEM) )
	    goto rfile2;

	  if( ad_fsdta[21] & F_SUBDIR ) /* if subdirectory	*/
	  {
	    if ( ad_fsdta[30] != '.' )
	      fsnames[i].snames[0] = 7;
	    else
	      goto rfile2; 
	  }
	  else
	  {
	    if ( wildcmp( filename, &ad_fsdta[30] ) )
	      fsnames[i].snames[0] = 0x20;
	    else
	      goto rfile2;
	  }

	  fmt_str( &ad_fsdta[30], &fsnames[i++].snames[1] );
rfile2:
	  ret = dos_snext();
	}

	if ( i )
	  r_sort( fsnames, i ); 

	strcpy( filename, chrptr );	/* restore file name	*/

	*count = i;

	return( TRUE );
}
		   

	WORD
r_sort( buffer, count )
REG	FSTRUCT	(*buffer)[];
	WORD	count;
{ 
REG	WORD	gap,i,j,k;
	BYTE	tmp[LEN_FSNAME];

	for( gap = count/2; gap > 0; gap /= 2 )
	{
	  for( i = gap; i < count; i++ )
	  {
	    for ( j = i - gap; j >= 0; j -= gap )
	    {
	      if ( strchk( buffer[j], buffer[j+gap] ) <= 0 )
	        break; 

	      LSTCPY( tmp, buffer[j] );
	      LSTCPY( buffer[j], buffer[j+gap] );
	      LSTCPY( buffer[j+gap], tmp );
	    }
	  }
	}
}


/*	show files and update the scroll bar	*/

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
	  fs_sset( ad_fstree, label, " ", &addr, &addr ); 
	  fs_draw( label++, &ad_fsnames[i], &addr, &addr ); 
	}

	h = LWGET( OB_HEIGHT( FSVSLID ) );
	h += ADJ3DPIX << 1;

	h1 = LWGET( OB_HEIGHT( FSVELEV ) );
	h1 += ADJ3DPIX << 1;

	h3 = index;

	if ( ratio == 1 || ratio == NM_NAMES )
	{
	  if ( fs_count > NM_NAMES )
	    h = ( (h - h1) * h3 ) / (LONG)(( fs_count - NM_NAMES ));
	  else
	    h = 0;
	}
	else
	  h = ( (h - h1) * ratio ) / 1000;	  

	LWSET( OB_Y(FSVELEV), h );

	ob_draw( tree, FSVSLID, MAX_DEPTH );	/* erase the old slide bar */
}



/*	do the fs_sset and ob_draw	*/

	VOID
fs_draw( index, path, addr1, addr2 )
	WORD	index;
	LONG	path,addr1,addr2;
{
	fs_sset( ad_fstree, index, path, addr1, addr2 ); 
	ob_draw( ad_fstree, index, MAX_DEPTH );
}


/*	Adjust all the drive boxes	*/

	VOID
ini_fsel()
{
	WORD		x,y,i,j,w,h;
	REG OBJECT	*obj;
	OBJECT		*tree;

	rs_gaddr(ad_sysglo, R_TREE, SELECTOR, &tree );
	obj = tree;

	y = x = 0;

	for ( i = 0, j = DRIVEA; i < 8; i++, j++ )
	{  
	   obj[j].ob_x = x;
	   obj[j++].ob_y = y;
	   obj[j].ob_x = obj[j].ob_width + (ADJ3DPIX << 1) + x + 1;
	   obj[j].ob_y = y;
	   y += obj[j].ob_height + (ADJ3DPIX << 1) + 1;
	} 	

	/* fix up the remaining of the file selector */

	obj[FUPAROW].ob_height -= 1;
	obj[FDNAROW].ob_height -= 1;
	ob_offset( tree, DRIVEA, &x, &y );
	y -= obj[FSDRIVE].ob_height + 2 + ADJ3DPIX;
	obj[FSDRIVE].ob_y = y;

	ob_offset( tree, FCLSBOX, &x, &y );

#if 0
	obj[FSVSLID].ob_type |= 0x0100;
#endif
 	obj[FILEBOX].ob_x = x - ADJ3DPIX - 1; 
	obj[FTITLE].ob_x = x + obj[FCLSBOX].ob_width + ADJ3DPIX; /* adjust FTITLE */	
	obj[FTITLE].ob_y = y - ADJ3DPIX;
	obj[FTITLE].ob_height = obj[FCLSBOX].ob_height + ( ADJ3DPIX << 1 );
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
	w -= obj[FUPAROW].ob_width + ( ADJ3DPIX << 1 );
	obj[FILEBOX].ob_width = w;
	obj[SCRLBAR].ob_x = obj[FILEBOX].ob_x + w;

	ob_offset( tree, FILEBOX, &x, &y );
	y = obj[FILEBOX].ob_height + y + 6 + ADJ3DPIX;
	obj[OK].ob_y = obj[CANCEL].ob_y = y;
	y += obj[OK].ob_height + ADJ3DPIX + 6;
	obj[0].ob_height = y;

        if (gl_ws.ws_ncolors > LWHITE)
	  return;

        obj[FCLSBOX].ob_spec = (obj[FCLSBOX].ob_spec & 0xfffffff0) | WHITE;
        obj[FUPAROW].ob_spec = (obj[FUPAROW].ob_spec & 0xfffffff0) | WHITE;
        obj[FDNAROW].ob_spec = (obj[FDNAROW].ob_spec & 0xfffffff0) | WHITE;
        obj[FSVELEV].ob_spec = (obj[FSVELEV].ob_spec & 0xfffffff0) | WHITE;

	for ( i = DRIVEA; i <= DRIVEP; i++ )
	   obj[i].ob_spec = (obj[i].ob_spec & 0xfffffff0) | WHITE;
}


WORD
FXWait()
{
    do
    {
	dsptch(); 
    }while( gl_button );
}


WORD
FXSelect( tree, obj )
OBJECT *tree;
WORD   obj;
{
    GRECT 	rect;
    WORD	dummy;
	
    tree[ obj ].ob_state |= SELECTED;
    rect = *(GRECT *)&tree[(obj)].ob_x;
    ob_gclip( tree, obj, &dummy, &dummy, &rect.g_x, &rect.g_y,
	      &rect.g_w, &rect.g_h );
    gsx_sclip( &rect );
    ob_draw( tree, obj, MAX_DEPTH );		/* draw the box		*/
}


WORD
FXDeselect( tree, obj )
OBJECT *tree;
WORD   obj;
{
    GRECT 	rect;
    WORD	dummy;
 	
    tree[ obj ].ob_state &= ~SELECTED;
    rect = *(GRECT *)&tree[(obj)].ob_x;
    ob_gclip( tree, obj, &dummy, &dummy, &rect.g_x, &rect.g_y,
	      &rect.g_w, &rect.g_h );
    gsx_sclip( &rect );
    ob_draw( tree, obj, MAX_DEPTH );		/* draw the box		*/
}
