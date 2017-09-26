/*------------------------------------------------------------------------*/
/* Globale Funktionen 																										*/

#include <cflib.h>

#include "types.h"
#include "event.h"
#include "rsc.h"

/*------------------------------------------------------------------------*/
/* EXTERNE VARIABLE																												*/

/*------------------------------------------------------------------------*/
/* EXTPORTIERTE VARIABLE																									*/

int vdi_handle;
int w_max;
int quick_draw;
bool hintergrund;

/*------------------------------------------------------------------------*/
/* DEFINES																																*/

/*------------------------------------------------------------------------*/
/* TYPES																																	*/

/*------------------------------------------------------------------------*/
/* FUNKTIONS																															*/

static int do_note(int def, int undo, char *s);

/*------------------------------------------------------------------------*/
/* LOCALE VARIABLES																												*/

static bool 	msleep = FALSE;

/*------------------------------------------------------------------------*/
/* Maus-Routinen																													*/

bool mouse_sleeps(void)
{
	return msleep;
}

void sleep_mouse(void)
{
	if (!msleep)
	{
		msleep = TRUE;
		hide_mouse();
	}
}

void wake_mouse(void)
{
	if (msleep)
	{
		msleep = FALSE;
		show_mouse();
	}
}

/*------------------------------------------------------------------------*/

int do_note(int def, int undo, char *s)
{
	wake_mouse();
	return do_walert(def, undo, s, " qed ");
}

int note(int def, int undo, int index)
{
	return do_note(def, undo, (char *)alertmsg[index]);
}

int snote(int def, int undo, int index, char *val)
{
	char	buf[128];
	
	sprintf(buf, (char *)alertmsg[index], val);
	return do_note(def, undo, buf);
}

/*------------------------------------------------------------------------*/

bool path_from_env(char *env, char *path)
{
	char	*p;
	bool ret = FALSE;
		
	p = getenv(env);
	if (p != NULL)
	{
		strcpy(path, p);
		ret = make_normalpath(path);
	}
	return ret;
}

/*------------------------------------------------------------------------*/
/* Setzt die Hintergrundfarbe																							*/

void set_hintergrund(void)
{
	if(hintergrund && gl_planes>=4)
	{
		quick_draw=FALSE;
		vswr_mode(vdi_handle,MD_TRANS);
		vsf_color(vdi_handle,LWHITE);
	}
	else
	{
		quick_draw=TRUE;
		vswr_mode(vdi_handle,MD_REPLACE);
	}
}

/*------------------------------------------------------------------------*/
/* Init Global																														*/

int init_global(void)
{
	int ret;
	int work_out[57];

	vdi_handle = open_vwork(work_out);
	vst_alignment(vdi_handle, TA_LEFT, TA_TOP, &ret, &ret);
	vsf_perimeter(vdi_handle,FALSE);
	w_max = work_out[0];
	set_hintergrund();

	return TRUE;
}

/*------------------------------------------------------------------------*/

void term_global(void)
{
	v_clsvwk(vdi_handle);
}
