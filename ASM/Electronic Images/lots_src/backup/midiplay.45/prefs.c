/*
 * 	The Digital Sound Module.
 * 	(c) 1994 Martin Griffithis
 */ 

#include <stdio.h>
#include <e_gem.h>
#include "types.h"

static char curr_cfgpath[256];  /* Current Song Path */
static char curr_cfgname[256];  /* Current Song Filename */
static char selected_cfg[256];		

void cfgfile_is_bad(void)
{
	xalert(1,1,X_ICN_DISC_ERR,NULL,BUTTONS_CENTERED,TRUE,title,
	" This does not seem to be a Config file, |"
	" Either the file may have become corrupted,    |"
	" OR you have selected the wrong file. "," [Ok ");
}

/*
 *
 */

Bool do_load_cfg(char *name)
{	long handle;
	reg int i,c;
	if ((handle = Fopen(name,FO_READ)) >=0 ) 
	{	long ID;
		Fread(handle,sizeof(long),&ID);
		if (ID != 0x12345678)
		{	cfgfile_is_bad();
			return FALSE;
		}	
		Fclose(handle);
		return TRUE;
	} else
	{	xalert(	1,1,X_ICN_DISC_ERR,NULL,BUTTONS_CENTERED,TRUE,title,
				" Could not Open CFG file for Reading. "," [Ok ");
		return FALSE;
	}
}

void load_cfg(void)
{	if (select_file(selected_cfg,curr_cfgpath,curr_cfgname,"*.CFG","Load .CFG file"))
	{	graf_mouse(BUSYBEE,NULL);
		do_load_cfg(selected_cfg);
		graf_mouse(ARROW,NULL);
	}
}

/*
 *
 */
 
Bool do_save_cfg(char *name)
{	reg int i,c;
	long handle;
	if ((handle = Fcreate(name,0)) >=0 ) 
	{	long ID = 0x12345678;
		Fwrite(handle,sizeof(long),&ID);
		Fclose(handle);
		return TRUE;
	} else
	{	xalert(	1,1,X_ICN_DISC_ERR,NULL,BUTTONS_CENTERED,TRUE,title,
				" Could not Open CFG file for Writing. "," [Ok ");
		return FALSE;
	}
}

void save_cfg(void)
{	if (select_file(selected_cfg,curr_cfgpath,curr_cfgname,"*.CFG","Save .CFG file"))
	{	graf_mouse(BUSYBEE,NULL);
		do_save_cfg(selected_cfg);
		graf_mouse(ARROW,NULL);
	}
}