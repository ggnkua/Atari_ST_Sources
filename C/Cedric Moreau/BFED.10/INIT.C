/*
	file: init.c
	utility:
	date: 1989
	author: Jim Charlton
	modifications:
		1996: C. Moreau: 
	comments: 
*/

#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#ifdef __PUREC__ 
#include <aes.h>
#include <tos.h>
#include <vdi.h>
#include <compend.h>
#else
#include <aesbind.h>
#include <osbind.h>
#include <vdibind.h>
#endif

#include "e:\proging\c\libs\malib\alert.h"
#include "e:\proging\c\libs\malib\appgpath.h"
#include "e:\proging\c\libs\malib\resource.h"

#include "config.h"
#include "dialog.h"
#include "edit.h"
#include "files.h"
#include "init.h"
#include "keys.h"
#include "main.h"
#include "menu.h"
#include "onepage.c"
#include "wind.h"

#include "bfed_rsc.h"

/*
	Globals variables
*/
int phys_handle;			/* vdi handle */
int gl_hchar, gl_wchar;	/* sizes of window font */
int xdesk, ydesk, wdesk, hdesk;	/* desktop sizes */
int ver_aes, ver_tos;	/* version of AES and TOS */
int pxyarray[8];	/* for vdi calls */

/*
	locals functions
*/
static void init_sys_vars(void);
static void init_argv(int *argc, char **argv[]);

/* 
	name: init
	utility: Make all initializations 
	comment: 
		called from main.c.
		Initialise the VDI, the system info vars (AES version,...),
		load the ressource, initialise the modules (globals vars string
		in the right language).
		Get the ARGV command and open associated windows.
	parameters: ARGV command
	return:
	date: 10 may 96
	author: C.Moreau
	modifications:
*/
void init(int *argc, char **argv[])
{
	MFDB	desk_mfdb;

	init_sys_vars();		/* init the system information vars */
	
	rsrc_lang_load(PRG_NAME);	/* load ressources */
	
		/* initialise VDI for the general programm */
	phys_handle = open_vwork(&desk_mfdb);
	
	if ( (desk_mfdb.fd_w < 640) || (desk_mfdb.fd_h < 200) )
	{
		rsc_alert(LOW_RES);
		shutdown(2);
	}
	else
	{
		init_menu();		/* initialise module menu.c */
		init_dialog();		/* initialise module dialog.c */
		init_files();		/* initialise module files.c */
		init_keys();		/* initialise module keys.c */
	
		set_table();	/*  makes two byte ascii hex table (onepage.c)  */	
	
		init_argv(argc, argv);	/* Load files given in ARGV */
		
		graf_mouse(ARROW, NULL);	/*	Initialize the mouse.	*/
	}
}

/*
	name: open_vwork
	utility: Open a virtual workstation.
	comment: a virtual workstation is associated with each window created.
		This means that each window's graphic attributes are independent
		of the other's.
		Called from wind.c
		Open a virtual workstation.
		A virtual workstation is associated with each window created.
		This means that each window's graphic attributes are independent
		of the other's.
	parameters: 
	return: none
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C.Moreau:
*/
int open_vwork(register MFDB *form)
{
	int	dummy;
	int vdi_handle = graf_handle(&gl_wchar, &gl_hchar, &dummy, &dummy);

	/*
		Initialize workstation variables.
	*/
	for(dummy=0; dummy<10; dummy++)
		_GemParBlk.intin[dummy] = 1;
	_GemParBlk.intin[10] = 2;

	v_opnvwk(_GemParBlk.intin, &vdi_handle, _GemParBlk.intout);

	form->fd_addr 	= Logbase();
	form->fd_w		= _GemParBlk.intout[0] + 1;
	form->fd_h		= _GemParBlk.intout[1] + 1;
	form->fd_wdwidth	= (form->fd_w + 15)/ 16;
	form->fd_stand	= 0;

		/* take more infos	*/
	vq_extnd(vdi_handle, 1, _GemParBlk.intout);
	form->fd_nplanes = _GemParBlk.intout[4];

		/* set default VDI param */
	vsf_perimeter(vdi_handle,PERIMETER_OFF);
	vsf_style(vdi_handle,1);
	vsf_interior(vdi_handle, FIS_SOLID);			/* set for solid fill */
	vst_alignment(vdi_handle,0,3,&dummy,&dummy);	/* set text alignment to bottom left */
	vsf_color(vdi_handle, (black_white?0:1) );	/* paint color */

	return vdi_handle;
}

/*
	name: init_sys_vars
	utility: Set TOS & AES version variables
	comment: 
	parameters: 
	return: none
	date: 1995
	author: C.Moreau
	modifications:
*/
static void init_sys_vars(void)
{
	char **sysbase=(char **)0x4f2;		/* pointeur vers le debut du
											systeme d'exploitation	*/
	char *systeme;												
	long old_stack;

		/* Get TOS version */
	if (!Super((void *)1L))	/* si on est en mode utilisateur	*/
		old_stack=Super(0L);	/* on passe en mode superviseur	*/
	systeme=*sysbase;			/* debut du systeme d'exploitation	*/

	if (old_stack)				/* si on etait en utilisateur au debut	*/
		Super((void *)old_stack);	/*  on y retourne */				

	ver_tos = *(int *)(systeme+2);
	
		/* Get AES version */
	ver_aes = _GemParBlk.global[0];

	app_get_path(app_path, PRG_NAME);	/* Get XXED.PRG path */

		/* Get size of screen */
	wind_get(0, WF_WORKXYWH, &xdesk, &ydesk, &wdesk, &hdesk);
}

/*
	name: init_argv
	utility:load all files given in the ARGV var
	comment: You can give several files
	parameters: 
	return: none
	date: 1995
	author: C.Moreau
	modifications:
*/
static void init_argv(int *argc, char **argv[])
{
	register int cpt = 1;
	const int thekind = UPARROW | DNARROW | VSLIDE | SIZER	\
						| MOVER | FULLER | CLOSER | NAME	\
						| INFO | SMALLER;
	windowptr	thewin;

	while ( ((*argv)[cpt] != NULL) || (cpt < *argc) )
	{
		thewin = window_new(thekind);	
		if (thewin)		/* Can open a new window */
		{
			strcpy(thewin->title, (*argv)[cpt++]); /* copy pathname to title */

			if	(read_file(thewin))
				window_open(thewin);
			else
				window_resources_dispose(thewin);
		}
	}
}
