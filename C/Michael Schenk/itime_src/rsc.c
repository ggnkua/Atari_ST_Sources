/*------------------------------------------------------------------------*/
/* Funktionen zu Verbindung mit den Sockets																*/

#include <cflib.h>

#include "itime.h"

/*------------------------------------------------------------------------*/
/* EXTERNE VARIABLE																												*/

/*------------------------------------------------------------------------*/
/* EXTPORTIERTE VARIABLE																									*/

OBJECT 	*Online;
OBJECT 	*Setup;

char		**alertmsg;

/*------------------------------------------------------------------------*/
/* DEFINES																																*/

/*------------------------------------------------------------------------*/
/* TYPES																																	*/

/*------------------------------------------------------------------------*/
/* FUNKTIONS																															*/

/*------------------------------------------------------------------------*/
/* LOCALE VARIABLES																												*/

static int	rsc_init = 0;

/*----------------------------------------------------------------------------*/

int init_resource(void)
{
	char rsc_path[300];
	int i;

	strcpy(rsc_path, "itime.rsc");
	shel_find(rsc_path);
	rsc_init = rsrc_load(rsc_path);
	if (!rsc_init)
	{
		strcpy(rsc_path, gl_appdir);
		strcat(rsc_path, "itme.rsc");
		rsc_init = rsrc_load(rsc_path);
	}

	if (rsc_init)
	{
		rsrc_gaddr(R_TREE,ONLINE,&Online);
		fix_dial(Online);

		rsrc_gaddr(R_TREE,MAIN,&Setup);
		fix_dial(Setup);
		
		i = rsrc_gaddr(R_FRSTR, WRONGINF,	&alertmsg);		/* _erster_ Alert */
		i = i;
		
	}
	else
		do_alert(1, 0, "[3][Resource-File|itime.rsc?][Exit]");
	return rsc_init;
}

/*----------------------------------------------------------------------------*/

void term_resource (void)
{
	if (rsc_init)
	{
		rsrc_free();
	}
}
