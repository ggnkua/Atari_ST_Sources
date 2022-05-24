/*
 *        Protracker Replay V3.0
 *        By Martin Griffiths (C) July/August 1993
 *        (Gem User Interface and calling module)
 *
 */ 

#include <aes.h>
#include <vdi.h>
#include <portab.h>
#include <nkcc.h>
#include <mglobal.h>
#include <mydial.h> 
#include <string.h>
#include <tos.h>
#include "test4.h"

#define RESOURCENAME  "TEST4.RSC"
#define CONFIGNAME    "PROPLAY.CFG"
#define POWERPACK_HDR 0x50503230L

#define MAX_WINDOWS 3

/*
 *   Global Variables
 */

enum Window_name { MAIN_WIND=0,INFO_WIND=1,HELP_WIND=2 };


static int Window_handle[MAX_WINDOWS];
static int Window_in_use[MAX_WINDOWS] = {FALSE,FALSE,FALSE};
static char *Window_title[] = 	{ 	" Pro-Player v2.0\x9e ",
									" Pro-Player v2.0 InfoPage",
									" Pro-Player v2.0 HelpPage" 
							 	};
static int Window_type[MAX_WINDOWS] =	{ NAME | INFO | MOVER | CLOSER | FULLER,
										  NAME | MOVER | CLOSER,
										  NAME | MOVER | CLOSER
										};


		 

        	pro_flag = TRUE,		
	        fil_flag = FALSE,
    	    vol_flag = FALSE,
			tem_flag = TRUE;
static int window_id,win_mx,win_my,win_mw,win_mh,win_fullflag = TRUE;
static int mesg_buf[8];
static int autoload = FALSE;
static OBJECT *form1;
static OBJECT *form2;
static OBJECT *form3;

/*
 *    External Declarations
 */
 
/*
extern unsigned int resource_data[];
extern void fix_resource(unsigned int *);
extern OBJECT *get_treeaddr(unsigned int *,int);
*/

extern void start_music(void);
extern void stop_music(void);
extern void pause_music(void);
extern void forward_music(void);
extern void rewind_music(void);
extern void PP_Decrunch(long *Module_Ptr,void *pk_ptr,long Modlength);

long filesize(char *);
int select_file(char *,char *,char *);
void free_modmemory(void);
int load_module(void);
int save_module(void);
void do_load_module(void);
void set_player_status(enum Player_status,int wind_id);
void main_but_log(OBJECT *);

/*
 *    Return the size of a file
 */

long filesize(char *fpath)
{	DTA *cdta=Fgetdta();
	if (Fsfirst(fpath,0) >= 0)
		return ((long) cdta->d_length);
	return -1;
}



/*
 *        Free Module Memory.
 */

void free_modmemory(void)
{	if (Module_Ptr != NULL)
		Mfree(Module_Ptr);
}



/*
 *        Save a module.
 */

int save_module(void)
{	int handle;
	if ((handle = Fcreate(full_path,0))>= 0) 
	{	if (Fwrite(handle,Modlength,Module_Ptr) == Modlength)	
		{	Fclose(handle);
			return 0;
		}
		return 2; 		/* Write Error */
	}
	return 1;	  	/* Can't Create File */
}


/*
 *   Wait for the mouse button(s) to be released.
 */
 
void wait_buttonup(void)
{	int mx,my,mk,kk;
	do 
	{	graf_mkstate(&mx,&my,&mk,&kk);
	}	while (mk);
}


/*
 *    Logic for controlling main Sound Control Panel 
 */

void main_but_log(OBJECT *f)
{	if (pro_flag) 
	{	f[PROTRACKER].ob_state = SELECTED;
		tem_flag = TRUE;
	} else {
	    f[PROTRACKER].ob_state &= !SELECTED;
		tem_flag = FALSE;
	}
	if (fil_flag) f[FILTER].ob_state |= SELECTED;
		     else f[FILTER].ob_state &= !SELECTED;
	if (vol_flag) f[BOOST].ob_state  |= SELECTED;
		     else f[BOOST].ob_state  &= !SELECTED;
	if (ali_flag) f[ANTIALIAS].ob_state |= SELECTED;
		     else f[ANTIALIAS].ob_state &= !SELECTED;
}


/*
 *   Redraw a Form, clipped to the visible regions given by the rectangle
 *   list for that window.
 */
 
int intersect(int *x1,int *y1,int *w1,int *h1,int x2,int y2,int w2,int h2)
{	
	if ( (x2>(*x1)+(*w1)) || (x2+w2<(*x1)) || (y2>(*y1)+(*h1)) || (y2+h2<(*y1)) )
		return 0;   /* No intersection */
	else {
		int sx1,sy1,sx2,sy2;						
		sx1=max((*x1),x2);						
		sy1=max((*y1),y2);						
		sx2=min(((*x1)+(*w1)),x2+w2);
		sy2=min(((*y1)+(*h1)),y2+h2);	
		*x1=sx1;								
		*y1=sy1;
		*w1=sx2-sx1;
		*h1=sy2-sy1;
		if ((*w1 > 0) && (*h1 > 0))
			return 1;
		else
			return 0;
	}
}

void wind_redraw(int wind_handle,OBJECT *form,int x1,int y1,int w1,int h1)
{	int x,y,w,h;
	int sx,sy,sw,sh;
	wind_update(BEG_UPDATE);
	wind_get(wind_handle,WF_FIRSTXYWH,&x,&y,&w,&h);
	while (w && h)
	{		sx = x; sy = y; sw = w; sh = h;
			if (intersect(&sx,&sy,&sw,&sh,x1,y1,w1,h1))
			{	objc_draw(form,0,MAX_DEPTH,sx,sy,sw,sh); 
			}
			wind_get(wind_handle,WF_NEXTXYWH,&x,&y,&w,&h);
	}
	wind_update(END_UPDATE);
}

/*
 *
 */
 
void do_info_page(void)
{	DIALINFO di;
 	open_dial(form2,TRUE,NULL,&di);
 	dial_draw(&di);
 	dial_do(&di,0);
 	close_dial(TRUE,NULL,&di);
 	
}

/*
 *
 */
 
void do_help_page(void)
{	DIALINFO di;
 	open_dial(form3,TRUE,NULL,&di);
 	dial_draw(&di);
 	dial_do(&di,0);
 	close_dial(TRUE,NULL,&di);
 	
}

int create_window()
{	int window_id;
/*	window_id = wind_create(win_type,win_mx,win_my,win_mw,win_mh);
	if (window_id !=-1)
	{
	} else
		return -1;
*/

}

/* 
 *      Main Screen 
 */

void main_scrn(void)
{
	int fo_cx,fo_cy,fo_cw,fo_ch,rt,mx,my,du;
	int	win_x,win_y,win_w,win_h;
	int win_type = NAME | INFO | MOVER | CLOSER | FULLER;
	int gr_handle,quit_flag = 0;
	int work_in[11] = {1,1,1,1,1,1,1,1,1,1,2},
	    work_out[57];

	gr_handle = graf_handle(&du,&du,&du,&du);
	v_opnvwk(work_in,&gr_handle,work_out);
	wind_get(0,4,&win_mx,&win_my,&win_mw,&win_mh);	

	window_id = wind_create(win_type,win_mx,win_my,win_mw,win_mh);
	if (window_id !=-1)	
	{	
		main_but_log(form1);
		form_center(form1,&fo_cx,&fo_cy,&fo_cw,&fo_ch);
		wind_update(BEG_UPDATE);
		wind_calc(0,win_type,fo_cx,fo_cy,fo_cw,fo_ch,&win_x,&win_y,&win_w,&win_h);
		wind_set(window_id,WF_NAME,Window_title[MAIN_WIND],0,0);
		wind_open(window_id,win_x,win_y,win_w,win_h);
		wind_update(END_UPDATE);
		
		set_player_status(curr_status,window_id);
		
		do
		{	rt = evnt_multi (MU_BUTTON | MU_KEYBD | MU_MESAG,1,1,3,
				 			 	 0,-1,-1,-1,-1,
								 0,-1,-1,-1,-1,
								 &mesg_buf[0],0,0,
								 &du,&du,&du,&du,&du,&du);
			graf_mkstate(&mx,&my,&du,&du);
			if (rt & MU_MESAG)
			{	switch (mesg_buf[0])
				{	case WM_REDRAW:	{	wind_redraw(mesg_buf[3],form1,
													mesg_buf[4],mesg_buf[5],
													mesg_buf[6],mesg_buf[7]);
										break;
									}
					case WM_MOVED:	{	win_x = mesg_buf[4];
										win_y = mesg_buf[5];
										win_w = mesg_buf[6];
										win_h = mesg_buf[7];
										wind_update(BEG_UPDATE); /*needed?*/
										wind_set(mesg_buf[3],WF_CURRXYWH,win_x,win_y,win_w,win_h);	
										wind_calc(1,win_type,win_x,win_y,win_w,win_h,&fo_cx,&fo_cy,&fo_cw,&fo_ch);
										wind_update(END_UPDATE); /*needed?*/
										form1[FORM1].ob_x = fo_cx;	
										form1[FORM1].ob_y = fo_cy;
										break;			
									}
					case AC_CLOSE:
					case WM_CLOSED:	{	quit_flag = 1;
										break;
									}
					case WM_NEWTOP:
					case WM_TOPPED:	{	wind_set(mesg_buf[3],WF_TOP,0,0,0,0);
										break;
									}
					case WM_FULLED:	{
					
										break;
									}
				}
			}
			if (autoload == TRUE)
			{	do_load_module();
				autoload = FALSE;
			}
			if (rt & MU_BUTTON)
			{	rt = objc_find(form1,0,MAX_DEPTH,mx,my);
				switch(rt)
				{
					case PROTRACKER:{	pro_flag ^= 1;
										main_but_log(form1);
										objc_draw(form1,rt,MAX_DEPTH,win_mx,win_my,win_mw,win_mh);
										wait_buttonup();
										break;
									}
					case FILTER:	{	fil_flag ^= 1;
										main_but_log(form1);
										objc_draw(form1,FILTER,MAX_DEPTH,win_mx,win_my,win_mw,win_mh);
										wait_buttonup();
										break;
									}
					case BOOST:		{	vol_flag ^= 1;
										main_but_log(form1);
										objc_draw(form1,rt,MAX_DEPTH,win_mx,win_my,win_mw,win_mh);
										wait_buttonup();
										break;
									}
					case ANTIALIAS:	{	ali_flag ^= 1;
										main_but_log(form1);
										objc_draw(form1,rt,MAX_DEPTH,win_mx,win_my,win_mw,win_mh);
										wait_buttonup();
										break;
									}
					case LOAD:		{	objc_change(form1,LOAD,0,win_mx,win_my,win_mw,win_mh,SELECTED,1);
										wait_buttonup();
				
										objc_change(form1,LOAD,0,win_mx,win_my,win_mw,win_mh,0,1);
										break;			
									}						
/*					case RECORD:	{	objc_change(form1,RECORD,0,win_mx,win_my,win_mw,win_mh,SELECTED,1);
										wait_buttonup();
										if (Module_Ptr != NULL)
										{	if (select_file(curr_modpath,curr_modname,"Save MODfile") == 0)
											{	graf_mouse(BUSYBEE,NULL);
												switch (save_module())
												{	case 0 :{	form_alert(1,"[1][| |  Module Saved!  | |][ Ok ]");
																break;
															}
													case 1 :{	form_alert(1,"[1][| |  Can't Open file!  | |][ Damn! ]");
																break;
															}
													case 2 :{	form_alert(1,"[1][| |     Write Error!    | |][ Damn! ]");
																break;
															}
												}	
												graf_mouse(ARROW,NULL);
											}
										} else 
											form_alert(1,"[1][| |    No Module Loaded    | |][  Hmmmm...  ]");
										objc_change(form1,RECORD,0,win_mx,win_my,win_mw,win_mh,0,1);
										break;
									}
*/
					case PLAY:		{
										objc_change(form1,PLAY,0,win_mx,win_my,win_mw,win_mh,SELECTED,1);
										wait_buttonup();
										if (Module_Ptr != NULL) 
										{																				if (Module_Ptr != NULL) 
											set_player_status(PLAYING,window_id);
										}
										objc_change(form1,PLAY,0,win_mx,win_my,win_mw,win_mh,0,1);
										break;
										
									}	
					case STOP:		{
										objc_change(form1,STOP,0,win_mx,win_my,win_mw,win_mh,SELECTED,1);
										wait_buttonup();
										if (Module_Ptr != NULL)
										{								
											set_player_status(STOPPED,window_id);
										}
										objc_change(form1,STOP,0,win_mx,win_my,win_mw,win_mh,0,1);

										break;
									}																	
		/*			case PAUSE:		{	objc_change(form1,PAUSE,0,win_mx,win_my,win_mw,win_mh,SELECTED,1);
										wait_buttonup();
										if (Module_Ptr != NULL) 
										{	switch (curr_status)
											{	case PLAYING:	{
																	set_player_status(PAUSED,window_id);
																	break;
																}
												case PAUSED:	{
																	set_player_status(PLAYING,window_id);
																	break;
																}
											}
										}
										objc_change(form1,PAUSE,0,win_mx,win_my,win_mw,win_mh,0,1);

										break;
									}																
*/
					case REWIND:	{
										objc_change(form1,REWIND,0,win_mx,win_my,win_mw,win_mh,SELECTED,1);
										wait_buttonup();
										if (curr_status == PLAYING)
										{
										}

										objc_change(form1,REWIND,0,win_mx,win_my,win_mw,win_mh,0,1);

										break;
									}																
					case FORWARD:	{
										objc_change(form1,FORWARD,0,win_mx,win_my,win_mw,win_mh,SELECTED,1);
										wait_buttonup();
										if (curr_status == PLAYING)
										{
										}
										objc_change(form1,FORWARD,0,win_mx,win_my,win_mw,win_mh,0,1);

										break;
									}
					case INFOBUT:	{
										objc_change(form1,INFOBUT,0,win_mx,win_my,win_mw,win_mh,SELECTED,1);
										wait_buttonup();
										do_info_page();
										objc_change(form1,INFOBUT,0,win_mx,win_my,win_mw,win_mh,0,1);
										wait_buttonup();
										break;
									}	
					case HELP:		{
										objc_change(form1,HELP,0,win_mx,win_my,win_mw,win_mh,SELECTED,1);
										wait_buttonup();
										do_help_page();
										objc_change(form1,HELP,0,win_mx,win_my,win_mw,win_mh,0,1);
										wait_buttonup();
										break;
									}																					
				}
void
				
			}
			if (rt & MU_BUTTON)
			{
			}
							
		} while (quit_flag == 0); 

		wind_close(window_id);
		wind_delete(window_id);
	}
	else
		form_alert(1,"[0][|    Protracker Replay v3.0     | |     No window available   |][ Damn! ]");


	v_clsvwk(gr_handle);	
}

/*
 *     Main... sorts out whether run as an accessory,program or .ttp
 */

int main(int argc, char *argv[])
{	int ap_id,dm,rt;
	if (argc == 2)
	{	strcpy(full_path,argv[1]);
		autoload = TRUE;
	}
	
	ap_id = appl_init();
	graf_mouse(BUSYBEE,NULL);
	nkc_init(NKI_NO200HZ,0);
	nkc_set(0);
	
	dial_init(Malloc,Mfree, NULL,NULL,NULL);

	rsrc_load(RESOURCENAME);
	rsrc_gaddr(0,FORM1,&form1);
	rsrc_gaddr(0,FORM2,&form2);
	rsrc_gaddr(0,FORM3,&form3);

	dial_fix(form1,TRUE);	
	dial_fix(form2,TRUE);	
	dial_fix(form3,TRUE);

	graf_mouse(ARROW,NULL);
		
	if (_app == 0)	    
	{	if (menu_register(ap_id,"  ProReplay 3.0\x9e") == -1)
		{	form_alert(1,"[0][|    Protracker Replay v3.0    | | All accessory slots used!  |][ Damn! ]");
			rsrc_free();
			appl_exit();
			return -2;
		}
				
		do
		{	rt = evnt_multi(MU_MESAG|MU_BUTTON|MU_KEYBD,
						    1,1,1,
						    0,0,0,0,0,
						    0,0,0,0,0,
					    	mesg_buf,0,0,&dm,&dm,&dm,&dm,&dm,&dm);
	     	   if (rt & MU_MESAG)
	        	{	switch(mesg_buf[0])
            		{	case AC_OPEN:
	            	   	{		 main_scrn();
             	  	             break;
             	  	    }
           			}	
				}
		} while (1);

	} else

	{	main_scrn();
/*		stop_music(); */
		dial_exit();	
		nkc_exit();
		free_modmemory();
		rsrc_free();
		appl_exit();
		return 0;
	}
}	
