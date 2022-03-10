/*
 *  UUCODER
 *  A GEM-based program to uuencode and uudecode files, i.e.,
 *  transform binary files into mailable ASCII text and vice versa.
 *  This program was constructed by gutting Dumas' UUE and UUD
 *  to obtain the encoding routines, and constructing a GEM
 *  interface. It expects that you'll compile it with Sozobon C
 *  and GEMFAST; anything else may require some alterations.
 *
 *  This program is hereby placed in the public domain.
 * 
 *  -- Steve Yelvington <steve@thelake.mn.org> GEnie: S.YELVINGTO2 
 *  
 */

#include <stdio.h>
#include <obdefs.h>
#include <gemdefs.h>
#include <osbind.h>
#include <macros.h>

#include "uucoder.h" 

#define RESOURCE_FILE	"UUCODER.RSC"


OBJECT *menubar;

/*
 * Function: g_clrscr()
 * Returns: void
 * Description: Instructs GEM to redraw the Desktop workspace 
 */
void g_clrscr()
	{
	int x,y,w,h;
	wind_get(0,WF_FULLXYWH,&x,&y,&w,&h);
	form_dial(FMD_START,1,1,1,1,x,y,w,h);
	form_dial(FMD_FINISH,1,1,1,1,x,y,w,h);
	}


/*
 * Function: show_about()
 * Returns: void
 * Description: Shows the ABOUTBOX until timeout or mouse click
 */

void show_about()
	{
	OBJECT *aboutbox;
	int x,y,w,h,junk;
	static long delay;
	delay = 10*1000L;
	rsrc_gaddr(R_TREE,ABOUTBOX, &aboutbox);
	form_center(aboutbox, &x, &y, &w, &h);
	form_dial(FMD_START,1,1,1,1,x,y,w,h);
	form_dial(FMD_GROW,1,1,1,1,x,y,w,h);
	objc_draw(aboutbox, 0, 10, x, y, w, h);

       /* Thanks to ramaer@cs.utwente.nl (Mark Ramaer) */
	evnt_multi(MU_TIMER|MU_KEYBD|MU_BUTTON,
		1, 1, 1, 
		0,0,0,0,0,
		0,0,0,0,0,
		&junk,
		loword(delay),hiword(delay),
		&junk,&junk,		
		&junk,&junk,		
		&junk,
		&junk);
	form_dial(FMD_SHRINK,1,1,1,1,x,y,w,h);
	form_dial(FMD_FINISH,1,1,1,1,x,y,w,h);
	}


/*
 * function: main
 * returns:  0
 * description: Loads resource file, initializes GEM, calls 
 *          external main_event().
 */

main()
	{
	char *p; int i;
	void g_clrscr(), show_about();
	appl_init();
	i = rsrc_load(RESOURCE_FILE);
	if (!i)	/* try searching the path */
		{
		if (p=pfindfile(RESOURCE_FILE))
			i = rsrc_load(p);
		}
	if (!i)	/* still no luck; bail out */
		{
		form_alert(1,"[1][Unable to load|resource file!][EXIT]");
		appl_exit();
		exit(-1);
		}
	graf_mouse(ARROW,NULL);
	g_clrscr();
	rsrc_gaddr(0,MENUBAR, &menubar);
	menu_bar(menubar,TRUE);
	show_about();
	main_event();
	menu_bar(menubar,FALSE);
	g_clrscr();
	rsrc_free();
	appl_exit();
	return 0; 
	} 


/*
 * function: quit
 * returns:  0
 * description: quick exit in case of panic ... closes down GEM and exits. 
 */

quit()	
	{
	menu_bar(menubar,FALSE);
	g_clrscr();
	appl_exit();
	exit(0);
	}
