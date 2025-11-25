/*
**	TUCshell.prg	a gem shell for The Ultimate Converter
**	started by Geoff Wilson...Haven Software
**	on 12th January 1996
**	compiled with Lattice C 5.52
**	public domain....share and enjoy
*/
#include <gemlib.h>
#include <osbind.h>
#include <stdlib.h>
#include <stdio.h>
#include <dos.h>
#include <string.h>
#include "tucshell.h"	/*	resource file indices	*/

#define TRUE	1
#define FALSE	0

/*	GEM associated globals	*/
int ap_id;
int winhandle;
short x, y, w, h;	/* window coordinates, width and height */
int kind = (NAME|INFO); 	/* type of window to be opened	*/
short dx,dy,dw,dh,wchar,hchar,handle;	/* graf_handle parameters		*/
short screen_width, screen_height,screen_planes;
short ux, uy, uw, uh;		/* co-ords of desktop window	*/
const char title[] = " TUCshell v0.12 ... Haven Software 1996";
short VDI_active = FALSE;				/* TRUE if VDI workstation open */
short resource_active = FALSE;			/* TRUE if resource file loaded */
int window_open = FALSE;				/* TRUE if window is opened		*/
OBJECT *dialog;
/*----------------------------------------------------------------------*/
/* general global variables		*/
const char *filename = "";
char tempdir[FMSIZE] = "";
char commandline[FMSIZE] = "TUC.TTP ";
/*----------------------------------------------------------------------*/
/* Prototypes for functions defined in D:\TUC\TUCSHELL.C */
int main(void);
int initialise_GEM(void);
void shutdown_GEM(void);
int initialise_resource(unsigned char *filename);
void openwind(void);
void set_tedinfo(OBJECT *tree,
                 int obj,
                 unsigned char *source);
void get_tedinfo(OBJECT *tree,
                 int obj,
                 unsigned char *dest);
int getfile(unsigned char *fselstring);
int clear_window(int window);
void clip(int window);
int draw_dialog(void);
int get_commandline(void);
/*----------------------------------------------------------------------*/

int main(void)
{
	int button = 0,ret = 0;
	int finished = FALSE;
	
	if (initialise_GEM() == FALSE)
		return(0);
	openwind();
	if (screen_width < 640)
		{
		form_alert(1,"[3][| insufficient screenwidth | for TUCshell |][Abort]");
		shutdown_GEM();
		return(0);
		}
	if (initialise_resource("TUCSHELL.RSC") == FALSE)
		{
		form_alert(1,"[3][|TUCshell|cannot find .RSC file.|][Abort]");
		shutdown_GEM();
		return(0);
		}
	do
	{
	button = form_do(dialog,0) & 0x7FFF;
	switch (button)
		{
		case cancel:
			finished = TRUE;
			break;
		case fsel1:
			if (getfile("select source file"))
			{
				clear_window(winhandle);
				draw_dialog();
				set_tedinfo(dialog,sourcebox,filename);
				objc_draw(dialog,sourcebox,0,dx,dy,dw,dh);
				break;
			}
			break;
		case fsel2:
			if (getfile("select destination file"))
			{
				clear_window(winhandle);
				draw_dialog();
				set_tedinfo(dialog,destbox,filename);
				objc_draw(dialog,destbox,0,dx,dy,dw,dh);
				break;
			}
			break;
		case fsel3;
			if (getfile("select .TUC file"))
			{
				clear_window(winhandle);
				draw_dialog();
				set_tedinfo(dialog,tucbox,filename);
				objc_draw(dialog,tucbox,0,dx,dy,dw,dh);
				break;
			}
			break;
		case ok:
			get_commandline();
			graf_mouse(M_OFF,NULL);
			v_enter_cur(handle);
			ret = system(commandline);
			if (ret < 0)
			{
			v_exit_cur(handle);
			graf_mouse(M_ON,NULL);
			form_alert(1,"[3][| Cannot execute | TUC.TTP ][ abort ]");
			}
			else
			{
		    	v_exit_cur(handle);
		    	graf_mouse(M_ON,NULL);
   			    strcpy(commandline,"TUC.TTP ");
		    }
			dialog[button].ob_state ^= SELECTED	 /* XOR button state	*/
			objc_draw(dialog,button,0,dx,dy,dw,dh);
			draw_dialog();
			break;
		}
	}
	while(!finished)
	form_dial(FMD_FINISH,0,0,0,0,dx,dy,dw,dh);
	form_dial(FMD_SHRINK,dx+dw/2,dy+dh/2,20,20,dx,dy,dw,dh);
	shutdown_GEM();
	return(0);
}	/*	main	*/


int initialise_GEM(void)
{
	short physical_handle, dummy;
	short work_out[57];
	short work_in[11] = {1,1,1,1,1,1,1,1,1,1,2};

	if ((ap_id = appl_init()) == -1)
		return(FALSE);
	physical_handle = graf_handle(&wchar,&hchar,&dummy,&dummy);
	handle = physical_handle;
	v_opnvwk(work_in,&handle,work_out);
	if (handle == 0)
		{
		appl_exit();
		return(FALSE);
		}
	VDI_active = TRUE;
	screen_width = work_out[0] + 1;
	screen_height = work_out[1] + 1;

	vq_extnd(handle,1,work_out);
	screen_planes = work_out[4];
	wind_get(DESK,WF_FXYWH,&ux,&uy,&uw,&uh);
	graf_mouse(ARROW,NULL);
	return(TRUE);
}	/*	initialise_GEM	*/

void shutdown_GEM(void)
{	if (window_open == TRUE)
	{
		wind_close(winhandle);
		wind_delete(winhandle);
		window_open = FALSE;
	}
	if (VDI_active == TRUE)
		v_clsvwk(handle);
	appl_exit();
	return;
}	/*	shutdown_GEM	*/


int initialise_resource(char *filename)
{
	if (!rsrc_load(filename))
		return(FALSE);
	resource_active = TRUE;
	rsrc_gaddr(R_TREE,form1,&dialog);
	form_center(dialog,&dx,&dy,&dw,&dh);
	form_dial(FMD_START,0,0,0,0,dx,dy,dw,dh);
	form_dial(FMD_GROW,dx+dw/2,dy+dh/2,20,20,dx,dy,dw,dh);
	objc_draw(dialog,0,MAX_DEPTH,dx,dy,dw,dh);		
	return(TRUE);
}	/*	initialise_resource	*/

void openwind(void)
{
	wind_get(DESK, WF_WXYWH, &x, &y, &w, &h);   /* get desktop parameters */
	winhandle = wind_create(kind, x, y, w, h);  /* create a window to suit */
	wind_set(winhandle, WF_NAME, ADDR(title), 0, 0);	/* set window title */
	wind_open(winhandle, x, y, w, h);		   /* open the window */
	wind_get(winhandle, WF_WXYWH, &x, &y, &w, &h);/* get window parameters */
	wind_info(winhandle,"");	/* set info line to NULL string		*/
	window_open = TRUE;
	return;
}	/*	openwind	*/

/*
**	copy a string into a TEDINFO structure.
**	copy string "source" into tedinfo number "obj" in tree "tree"
*/
void set_tedinfo(OBJECT *tree,int obj,char *source)
{
        char *dest;

        dest=((TEDINFO *)tree[obj].ob_spec)->te_ptext;
        strcpy(dest,source);
}	/*	set_tedinfo		*/
/*
**	copy the string from a TEDINFO into another string
**	copy ted_info number "obj" into string "dest"
*/
void get_tedinfo(OBJECT *tree, int obj, char *dest)
{
        char *source;

        source=((TEDINFO *)tree[obj].ob_spec)->te_ptext;/* extract address */
        strcpy(dest,source);
}
/*
** get a file using extended file selector
** use: global char *filename and if(!getfile());
*/

int getfile(char *fselstring)
{   short button, len;
	static char select[FNSIZE];			/* name of file chosen	*/
	static char dirname[FMSIZE];		/* directory pathname	*/

	*select = 0;				/* start with an empty name */

	wind_update(BEG_UPDATE);
	graf_mouse(ARROW, 0);
	fsel_exinput(dirname, select, &button, fselstring);
	if (select[0] == '\0' || button == 0)
	{
		wind_update(END_UPDATE);
		return(FALSE);				/* no filename or Cancel pressed */
	}
	len = strlen(dirname);
	while (dirname[len-1] != '\\')   /* knock out *.* from path */
		--len;
	dirname[len] = '\0';		/* mark end of path */
	strcpy(tempdir,dirname);
	strcat(dirname, select);	/* concatenate strings */
	wind_update(END_UPDATE);
	strcpy(filename,dirname);	/* assign global filename */
	strcpy(dirname,tempdir);
	return(TRUE);				/* success */
}	/*	getfile	*/

/*----------------------*/
/*      clear_window    */
/*----------------------*/
int clear_window(window)
int window;
{
short temp[4];
		graf_mouse(M_OFF,NULL);
        clip(window);
        vsf_interior(handle,2);
        vsf_style(handle,4);
        temp[0]=x;
        temp[1]=y;
        temp[2]=x + w - 1;
        temp[3]=y + h - 1;
        vr_recfl(handle,temp);             /* blank the interior */
        vsf_color(handle,1);
        graf_mouse(M_ON,NULL);
        return(TRUE);
}	/*	clear_window	*/

/*----------------------*/
/*      clip            */
/*----------------------*/
void clip(window)     
int window;
{
short pxyarray[4];
short top_wind;
        wind_get(window,WF_TOP,&top_wind,&top_wind,&top_wind,&top_wind);
        if (top_wind == window)
                return;
        wind_set(window,WF_TOP,0,0,0,0);
        pxyarray[0] = x;
        pxyarray[1] = y;
        pxyarray[2] = x + w - 1;
        pxyarray[3] = y + h - 1;
        vs_clip(handle,TRUE,pxyarray);
}	/*	clip	*/

int draw_dialog(void)
{
	form_center(dialog,&dx,&dy,&dw,&dh);
	objc_draw(dialog,0,MAX_DEPTH,dx,dy,dw,dh);		
}	/*	draw_dialog		*/

int get_commandline(void)
{
	char sourcefile[FMSIZE],destfile[FMSIZE],tucfile[FMSIZE];
	
	get_tedinfo(dialog,sourcebox,sourcefile);
	strcat(commandline,sourcefile);
	strcat(commandline," ");
	get_tedinfo(dialog,destbox,destfile);
	strcat(commandline,destfile);
	strcat(commandline," =");
	get_tedinfo(dialog,tucbox,tucfile);
	strcat(commandline,tucfile);
	strcat(commandline," ");
	return(0);
}	/*	get_commandline	*/