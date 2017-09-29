/*----------------------------------------------------------------------------------------*
 * MControl                                                                               *
 *----------------------------------------------------------------------------------------*
 * Copyright (c) 2000 - 2002 Joachim Fornallaz                                            *
 *----------------------------------------------------------------------------------------*
 * This source file is subject to the BSD license.                                        *
 *----------------------------------------------------------------------------------------*
 * Authors: Joachim Fornallaz <jf@omnis.ch>                                               *
 *----------------------------------------------------------------------------------------*/

#ifndef _rsrc_h_
#define _rsrc_h_

#include	<types2b.h>

#define	GAI_WDLG		0x0001											/* wdlg_xx()-Funktionen vorhanden */
#define	GAI_LBOX		0x0002											/* lbox_xx()-Funktionen vorhanden */
#define	GAI_FNTS		0x0004											/* fnts_xx()-Funktionen vorhanden */
#define	GAI_FSEL		0x0008											/* neue Dateiauswahl vorhanden */

#define	GAI_MAGIC	0x0100											/* MagiC-AES vorhanden */
#define	GAI_INFO		0x0200											/* appl_getinfo() vorhanden */
#define	GAI_3D		0x0400											/* 3D-Look vorhanden */
#define	GAI_CICN		0x0800											/* Color-Icons vorhanden */
#define	GAI_APTERM	0x1000											/* AP_TERM wird unterstÅtzt */
#define	GAI_GSHORTCUT 0x2000											/* Objekttyp G_SHORTCUT wird unterstÅtzt */

/*----------------------------------------------------------------------------------------*/
/* global variables																								*/
/*----------------------------------------------------------------------------------------*/

#define	ALERT_TITLE	" MControl "
#define	gl_appname	"MControl"

extern	OBJECT	*menu, *wicon, *about, *maindial, *tools, *icons;
extern	WDIALOG	*wdial;
extern	uint8		**alertmsg;
extern	uint8		**fstring_addr;

extern	int16		vdi_handle;
extern	int16		aes_flags;
extern	int16		menu_id;
extern	int16		h3d, v3d;

/*----------------------------------------------------------------------------------------*/
/* function prototypes																							*/
/*----------------------------------------------------------------------------------------*/

void	init_rsrc( void );
void	exit_rsrc( void );

int16	objc_count( OBJECT *tree );
int16	obj_copy( OBJECT *dtree, int16 di, OBJECT *stree, int16 si );
int16	obj_dcopy( OBJECT *dtree, int16 di, OBJECT *stree, int16 si );
int16	tree_copy( OBJECT *dest, OBJECT *src );
void fix_special(OBJECT *tree);

#endif
