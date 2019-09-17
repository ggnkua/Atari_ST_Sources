/* 
** Example of a progress report dialog box that allows functions to
** run in the background.
**
** Compiler: Lattice C v5.52
** Load project file progress.prj and 'make all'.
** Requires FLDLIB.O/H in same directory.
**
** Extract from File Manager.
** By Peter Strath 
** Example completed- 14-18/01/95
** Fully copyrighted.
*/

/* Files to include */
#include <dos.h>
#include <osbind.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <aes.h>
#include <vdi.h>
#include "fldlib.h"
#include "progress.h"

/* References to dialog boxes. */
OBJECT *about, *newfold, *progress;
short form1handle, form2handle, form3handle;

/* Function prototypes */
void initialise_GEM(void);
void object_handle(short, short);
void quit(void);
void main(void);
void tasks_todo(void);

/* Status of current task. */
short task_in_progress=0;
#define STOPPED   3
#define CONTINUED 1

/*
** Declare the global variables...
*/
short ap_id;                            /* AES application identifier   */
short handle;                           /* VDI workstation handle       */
short char_width, char_height;          /* Dimensions of character cell */

/* GEM initialization variables. */
short physical_handle, dummy;
short work_out[57];
short work_in[11] = {1,1,1,1,1,1,1,1,1,1,2};

/* New folder function */
#include "function.c"

/* Start-up GEM */
void initialise_GEM(void)
{
    physical_handle = graf_handle(&char_width,&char_height,&dummy,&dummy);
    handle = physical_handle;
    v_opnvwk(work_in,&handle,work_out);
    graf_mouse(ARROW,NULL);
}

/* Handle dialog buttons */
void object_handle(short object, short type)
{
	switch(type)
	{
		case ABOUT:
			switch (object)
			{
				case EXITABO:
					fld_close(form3handle);
					about[EXITABO].ob_state &= ~SELECTED;
					break;
			}
		break;
	
		case NEWFOLD:
			switch (object)
			{
				case CREATE:
					if (task_in_progress == 0)
					{
						form2handle = fld_open(progress, FLDC_SCREEN, "Progress Report", PROGRESS);
						fld_draw(form2handle, PROGRESS_MAIN, MAX_DEPTH);
						task_in_progress++;
   					}
					newfold[CREATE].ob_state &= ~SELECTED;
					fld_draw(form1handle, CREATE, 0);
					break;
				case UPFOLD:
					do_up_fold();
					break;
				case DNFOLD:
					do_down_fold();
					break;
				case INFOFORM:
					form3handle = fld_open(about, FLDC_SCREEN, "About...", ABOUT);
					fld_draw(form3handle, ABOUT, MAX_DEPTH);
					newfold[INFOFORM].ob_state &= ~SELECTED;
					fld_draw(form1handle, INFOFORM, 0);
					break;
				case CANCEL:
					quit();
					break;
			}
		break;
	
		case PROGRESS:
			switch (object)
			{
				case STOP:
					if (task_in_progress == 1)
					{
						fold_name_progress = (TEDINFO *) progress[PROGRES3].ob_spec;
        				fold_name_progress -> te_ptext = "Progress stopped";
        				fld_draw(form2handle, PROGRES3, 0);
        				task_in_progress = STOPPED;
					}
					else
					{
						progress[STOP].ob_state &= ~SELECTED;
        				fld_draw(form2handle, STOP, 0);
					}
					break;
				case CONTINUE:
					progress[CONTINUE].ob_state &= ~SELECTED;
        			fld_draw(form2handle, CONTINUE, 0);	
					progress[STOP].ob_state &= ~SELECTED;
        			fld_draw(form2handle, STOP, 0);
        			if (task_in_progress == STOPPED)
					{
						fold_name_progress = (TEDINFO *) progress[PROGRES3].ob_spec;
        				fold_name_progress -> te_ptext = "Progress continued";
        				fld_draw(form2handle, PROGRES3, 0);
        				task_in_progress = CONTINUED;
        			}
        			break;
				case EXITBACK:
					task_in_progress = 0;
					progress[EXITBACK].ob_state &= ~SELECTED;
        			fld_draw(form2handle, EXITBACK, 0);
        			fld_close(form2handle);
					break;
					
			}
		break;
	break;
	}
}

/* Quit program; */
void quit(void)
{
	fld_exit();
	rsrc_free();
	appl_exit();
	exit(0);
}

/* 
** Program starts here
*/
void main(void)
{
	short ret, type, handle, msgbuf[8], mx, my, mb, mk, kc, numclicks, evnts;
    
	ap_id = appl_init();
	
	fld_ability(FLDA_CLOSE|FLDA_ICON);
	
	initialise_GEM();

	if (!rsrc_load("PROGRESS.RSC"))
	{
		form_alert(1,"[3][ Could not find | PROGRESS.RSC ][ Exit ]");
		quit();
	}
	
	rsrc_gaddr(R_TREE, ABOUT, &about);
	rsrc_gaddr(R_TREE, NEWFOLD, &newfold);
	rsrc_gaddr(R_TREE, PROGRESS, &progress);
	
	form1handle = fld_open(newfold, FLDC_SCREEN, "New Folder", NEWFOLD);
	
	graf_mouse(ARROW, NULL);

	while (1)
	{
		evnts = evnt_multi(MU_KEYBD|MU_BUTTON|MU_MESAG|MU_TIMER, 2, 1, 1,  /* Flags + clicks */
		                   0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  /* Rects to watch (none) */
		                   msgbuf, 0, 0, &mx, &my, &mb, &mk, /* Msg buffer + mouse click */
		                   &kc, &numclicks);

		if (evnts & MU_KEYBD)
			if ((ret = fld_key(kc, &type, &handle)) != FLDR_NONE)
				object_handle(ret, type);
		if (evnts & MU_BUTTON)
			if ((ret = fld_mouse(mx, my, numclicks, &type, &handle)) != FLDR_NONE)
				object_handle(ret, type);
		if (evnts & MU_MESAG)
			if ((ret = fld_mesag(msgbuf)) != FLDR_NONE)
			{
				if (ret == form1handle)
					quit();
				else   
					fld_close(ret);
			}
		tasks_todo();	/* Do any waiting tasks. */
	}
}

/* Tasks to do */
void tasks_todo(void)
{	
	if (task_in_progress == 1)
		new_folder();
}