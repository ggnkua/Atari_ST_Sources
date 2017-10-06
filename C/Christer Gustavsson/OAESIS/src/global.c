/****************************************************************************

 Module
  global.c
  
 Description
  Variables of global interest in oAESis.
  
 Author(s)
 	cg (Christer Gustavsson <d2cg@dtek.chalmers.se>)
  jps (Jan Paul Schmidt <Jan.P.Schmidt@mni.fh-giessen.de>)

 Revision history
 
  960103 cg
   Added standard header. 

  960507 jps
   Added globals.realslide initialisation.

 Copyright notice
  The copyright to the program code herein belongs to the authors. It may
  be freely duplicated and distributed without fee, but not charged for.
 
 ****************************************************************************/

/****************************************************************************
 * Used interfaces                                                          *
 ****************************************************************************/

#include <mintbind.h>
#include <osbind.h>
#include <stdio.h>
#include <unistd.h>

#include "boot.h"
#include "debug.h"
#include "gemdefs.h"
#include "global.h"
#include "lxgemdos.h"
#include "resource.h"
#include "rsrc.h"
#include "types.h"
#include "vdi.h"
#include "version.h"

WORD appl_init(void);
WORD appl_exit(void);
WORD graf_handle(WORD *,WORD *,WORD *,WORD *);

/****************************************************************************
 * Global variables                                                         *
 ****************************************************************************/

GLOBALVARS	globals;

/****************************************************************************
 * Module global variables                                                  *
 ****************************************************************************/

static WORD	open_physical_ws = 0; /* Set this to 1 if you want to
                                     start oAESis without running
                                     GEM. */

static BYTE versionstring[50];

/****************************************************************************
 * Public functions                                                         *
 ****************************************************************************/

void	init_global(WORD physical) {
	WORD work_in[] = {1,1,1,1,1,1,1,1,1,1,2};
	WORD work_out[57];
	WORD dum;

	globals.rez = 1;
	globals.realmove = 0;
	globals.realsize = 0;
  globals.realslide = 0;
 	globals.fnt_regul_id = -1;
	globals.fnt_regul_sz = -1;
	globals.icon_width = 48;
	globals.icon_height = 56;
	globals.wind_appl = 1;

	Boot_parse_cnf();

	open_physical_ws = physical;

	if(open_physical_ws) {	
		/* open up a vdi workstation to use in the process */

		work_in[0] = globals.rez;
		globals.vid = 0;
	
		Vdi_v_opnwk(work_in,&globals.vid,work_out);
	}
	else {
		WORD	dum;
		
		appl_init();
		globals.vid = graf_handle(&dum,&dum,&dum,&dum);
		
		Vdi_v_clrwk(globals.vid);
	};
	
	Vdi_vq_extnd(globals.vid,0,work_out);
	
	globals.screen.x = 0;
	globals.screen.y = 0;
	globals.screen.width = work_out[0] + 1;
	globals.screen.height = work_out[1] + 1;

	globals.num_pens = work_out[13];
	
  /* setup systemfont information */
  
  if(globals.screen.height >= 400) {
	 	if(globals.fnt_regul_id == -1) {
		 	globals.fnt_regul_id = 1;
		};

	 	if(globals.fnt_regul_sz == -1) {
		 	globals.fnt_regul_sz = 13;
		};
 	}
 	else {
	 	if(globals.fnt_regul_id == -1) {
		 	globals.fnt_regul_id = 1;
		};

	 	if(globals.fnt_regul_sz == -1) {
		 	globals.fnt_regul_sz = 9;
		};
 	};

	globals.fnt_small_id = globals.fnt_regul_id;
	globals.fnt_small_sz = globals.fnt_regul_sz / 2;

 	Vdi_vst_font(globals.vid, globals.fnt_regul_id);
 	Vdi_vst_point(globals.vid,globals.fnt_regul_sz,&dum,&dum,&dum,&dum);

	globals.ap_pri = NULL;
	globals.applmenu = NULL;
	globals.accmenu = NULL;

  globals.win_vis = NULL;
	
	globals.mouse_x = 0;
	globals.mouse_y = 0;
	globals.mouse_button = 0;
	
	globals.arrowrepeat = 100;
	
	Vdi_vqt_attributes(globals.vid,work_out);
	
	globals.blwidth = work_out[8] + 3;
	globals.blheight = work_out[9] + 3;
	globals.clwidth = work_out[8];
	globals.clheight = work_out[9];

	globals.bswidth = work_out[8] / 2 + 3;
	globals.bsheight = work_out[9] / 2 + 3;
	globals.cswidth = work_out[8] / 2;
	globals.csheight = work_out[9] / 2;

	globals.time = 0L;
	
	sprintf(globals.mousename,"u:\\dev\\aesmouse.%03d",Pgetpid());

	Rsrc_do_rcfix(globals.vid,(RSHDR *)RESOURCE);
	
	Rsrc_do_gaddr((RSHDR *)RESOURCE,R_TREE,AICONS,&globals.aiconstad);
	Rsrc_do_gaddr((RSHDR *)RESOURCE,R_TREE,ALERT,&globals.alerttad);
	Rsrc_do_gaddr((RSHDR *)RESOURCE,R_TREE,DESKBG,&globals.deskbgtad);
	Rsrc_do_gaddr((RSHDR *)RESOURCE,R_TREE,FISEL,&globals.fiseltad);
	Rsrc_do_gaddr((RSHDR *)RESOURCE,R_TREE,INFORM,&globals.informtad);
	Rsrc_do_gaddr((RSHDR *)RESOURCE,R_TREE,MENU,&globals.menutad);
	Rsrc_do_gaddr((RSHDR *)RESOURCE,R_TREE,MOUSEFORMS,&globals.mouseformstad);
	Rsrc_do_gaddr((RSHDR *)RESOURCE,R_TREE,PMENU,&globals.pmenutad);
	Rsrc_do_gaddr((RSHDR *)RESOURCE,R_TREE,WINDOW,&globals.windowtad);
	Rsrc_do_gaddr((RSHDR *)RESOURCE,R_FRSTR,0,(OBJECT **)&globals.fr_string);

	sprintf(versionstring,"Version %s",VERSIONTEXT);
	globals.informtad[INFOVERSION].ob_spec.tedinfo->te_ptext = versionstring;
}

void	exit_global(void) {
	if(open_physical_ws) {
		Vdi_v_clswk(globals.vid);
		appl_exit();
	};
}
