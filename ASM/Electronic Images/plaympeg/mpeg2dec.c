/*
 *		PLAYMPEG v0.75
 *		(c) 1994/95 Martin Griffiths
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <e_gem.h>
#include <ext.h>
#include "mpegstrm.h"
#include "plaympeg.h"

typedef enum { NOSONG=0,PLAYING=1,STOPPED=2,PAUSED=3,MIDI_IN=4} Player_status;

enum Player_status curr_status = NOSONG;


void OpenDialog(DIAINFO *info,OBJECT *tree,int dial_mode,SLINFO **,boolean center);
void ExitExample(int all);
#define BUFFERSIZE (8192)

#define RESOURCENAME "PLAYMPEG.RSC"
#define VERSION "0.75(Gem)"

extern long go();
static int already_handling = FALSE;
int ld_infile;
extern char *ld_rdptr;
void *Phy_base;
void *Log_base;

char *title = "PLAYMPEG v"VERSION;
char *small_title = "PLAYMPEG";

OBJECT *info_tree,*info_tree2,*info_tree3;
OBJECT *instlist_tree,*song_tree,*load_form,*menu,*chaninf_tree,*patchmap_tree;
DIAINFO info_win,instlist_win,song_win,load_win,chaninf_win,patchmap_win;
DIAINFO *ex_info;

static long start_time, last_time,last_timer2,last_timer3,last_timer4;

#define SCREENSIZE ( (256 + ( (long) 480*400*2)))

unsigned char SCREEN1[SCREENSIZE];
unsigned char SCREEN2[SCREENSIZE];

void exit_display()
{
}



void wait_key(void)
{
  Cconws(" Press any key.\x0a\x0d");
  while (Cconis() !=0)  Cnecin();
  Cnecin();
}


void do_exit(int n)
{	char *error[] =	{	" Could not open MPEG file\x0a\x0d",
							" NOT a valid MPEG file\x0a\x0d",
							" Sorry, PLAYMPEG does not run in Mono!\x0a\x0d",
							" Read error, reading MPEG file!\x0a\x0d"
						};
	exit_display();
	Cconws(error[n-1]);
	wait_key();
	exit(n);
}


void Init_Buffer(void)
{	long ret;
	Fseek(0l,ld_infile,0);
 	if ((ret = Fread(ld_infile,BUFFERSIZE+4,ld_rdptr)) != BUFFERSIZE+4)
  	{ 	if (ret < 0)
  		{	do_exit(4);
  		}
		while (ret <= BUFFERSIZE)
		{	ld_rdptr[ret++] = 0x00;	
			ld_rdptr[ret++] = 0x00;
			ld_rdptr[ret++] = 0x01;	/* seq end code */
			ld_rdptr[ret++] = 0xb7;
		}
  	}	
}

void Refill_Buffer(void)
{	long ret;
	ld_rdptr[0] = ld_rdptr[BUFFERSIZE];
	ld_rdptr[1] = ld_rdptr[BUFFERSIZE+1];
	ld_rdptr[2] = ld_rdptr[BUFFERSIZE+2];
	ld_rdptr[3] = ld_rdptr[BUFFERSIZE+3];
	if ((ret = Fread(ld_infile,BUFFERSIZE,ld_rdptr+4)) != BUFFERSIZE)
 	{ 	if (ret < 0)
  		{	do_exit(4);
  		}
  		while (ret <= BUFFERSIZE)
		{	ld_rdptr[ret++] = 0x00;	
			ld_rdptr[ret++] = 0x00;
			ld_rdptr[ret++] = 0x01;	/* seq end code */
			ld_rdptr[ret++] = 0xb7;
		}
		
  	}
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

void alloc_display(void)
{	register long i;
	register char *ptr1 = &SCREEN1[0], *ptr2 = &SCREEN2[0];
	for (i = 0; i < SCREENSIZE ; i++)
	{	*ptr1++ = 0;
		*ptr2++ = 0;
	}
	Phy_base = (void *) ( (long) (SCREEN1+256)  & 0xffffff00);
	Log_base = (void *) ( (long) (SCREEN2+256)  & 0xffffff00);
}


void init_resource(void)
{
	rsrc_gaddr(R_TREE, MENU, &menu);
	rsrc_gaddr(0,INFO_WIN,&info_tree);
	rsrc_gaddr(0,INFO_WI2,&info_tree2);
	rsrc_gaddr(0,INFO_WI3,&info_tree3);
	rsrc_gaddr(0,INST_WIN,&instlist_tree);
	
	fix_objects(menu,NO_SCALING,8,16);
	fix_objects(info_tree,TEST_SCALING|DARK_SCALING,8,16);	
	fix_objects(info_tree2,TEST_SCALING|DARK_SCALING,8,16);	
	fix_objects(info_tree3,TEST_SCALING|DARK_SCALING,8,16);	
	fix_objects(instlist_tree,TEST_SCALING|DARK_SCALING,8,16);	

	ob_set_text(info_tree,DATEINFO,__DATE__);
	strcpy(ob_get_text(info_tree,VERSIONINFO,FALSE)+8,VERSION);
}

void ExitExample(int all)
{
	close_all_dialogs();
	if (all)
	{	
		menu_install(menu,FALSE);
		close_rsc(TRUE,0);
		exit(0);
	}
}

void User_Quits(void)
{	if (xalert(	1,1,X_ICN_QUESTION,NULL,SYS_MODAL,BUTTONS_CENTERED,TRUE,title,
				" Do you Really want to Quit? ","[Ok|[Cancel")==0)
		ExitExample(1);
}
int InitMsg(XEVENT *evt,int events_available)
{
	reg int flags = MU_MESAG|MU_KEYBD;

	if ((instlist_win.di_flag>CLOSED) && (events_available & MU_TIMER2))
	{
		/*evt->ev_mt2count = 500;		
		evt->ev_mt2last = last_timer2;
		flags |= MU_TIMER2;		*/
	}

	return (flags & events_available);
}

int Messag(XEVENT *event)
{
	reg int ev = event->ev_mwich,*msg = event->ev_mmgpbuf;
	reg int used = 0;
	if (ev & MU_MESAG)
	{
		used |= MU_MESAG;
		switch (*msg)
		{
		case MN_SELECTED:
			menu_tnormal(menu,msg[3],1);
			switch (msg[4])
			{	case MABOUT:
					OpenDialog(&info_win,info_tree,WIN_DIAL,NULL,FALSE);
					break;
				case MQUIT:
					User_Quits();
					break;
				case MOPEN:
					OpenDialog(&instlist_win,instlist_tree,WIN_DIAL,NULL,TRUE);
					break;	 /* MCYCLE/MCLOSE handled internally */
				case MLOADCFG:
					/*if (load_cfg() == TRUE)
					{	
						Redraw_DefList();
						Set_ViewingList(Current_View);
					}*/
					break;
				case MSAVECFG:
					break;					
											
			}
			break;
		case AP_TERM:
		case AC_CLOSE:
			ExitExample(0);
			break;
		case AC_OPEN:
			OpenDialog(&instlist_win,instlist_tree,WIN_DIAL,NULL,TRUE);
			break;
		default:
			used &= ~MU_MESAG;
		}
	}

	if ((ev & MU_KEYBD) && (event->ev_mmokstate & K_CTRL))
	{
		switch (scan_2_ascii(event->ev_mkreturn,event->ev_mmokstate))
		{
		case 'I':
			OpenDialog(&info_win,info_tree,WIN_DIAL,NULL,FALSE);
			break;
		case 'O':
			OpenDialog(&instlist_win,instlist_tree,WIN_DIAL,NULL,TRUE);
			break;
		case 'Q':
			User_Quits();
			break;
		}
	}

	
	return (used);
}

/*
 *
 */

void set_player_status(Player_status s)
{	curr_status = s;
	/*(&instlist_tree[STATUSTXT])->ob_spec.tedinfo->te_ptext=status_txt[s]; 
	if (instlist_win.di_flag>CLOSED)
		ob_draw_chg(&instlist_win,STATUSTXT,NULL,FAIL,FALSE);
	*/
}


/*
 *
 */

void set_player_status_filename(char *name)
{	/*strcpy((char *) status_txt[STOPPED]+11,name);
	strcpy((char *) status_txt[PLAYING]+11,name);
	strcpy((char *) status_txt[PAUSED]+11,name);
	*/
}


/*
 *
 */

void OpenDialog(DIAINFO *info,OBJECT *tree,int dial_mode,SLINFO **slider,boolean center)
{
	reg char *name = title;
	reg char *icon_name = small_title;
	reg int double_click,exit;
 	int x,y,j,k;
	switch (info->di_flag)
	{
	case WINDOW:
	case WIN_MODAL:
		window_top(info->di_win);
		break;
	case CLOSED:
		if (info = open_dialog(tree,name,icon_name,NULL,center,FALSE,dial_mode,0,slider,NULL)==NULL)
				xalert(1,1,X_ICN_ERROR,NULL,SYS_MODAL,BUTTONS_CENTERED,TRUE,title,"Keine freien Fenster mehr!","[Ok");
	}

	if (already_handling)
		return;
	else
		already_handling = TRUE;

	for (;;)
	{	
		exit = X_Form_Do(&ex_info);
		if (exit==W_CLOSED)
			close_dialog(ex_info,FALSE);
		else if (exit == W_ABANDON)
			break;
		else
		{	exit ^= (double_click = exit & 0x8000);

			if (ex_info==&instlist_win)
			{
				switch (exit)
				{	
					
					case LOAD:		
						ob_dostate(ex_info->di_tree,LOAD,SELECTED);
						ob_draw_chg(ex_info,LOAD,NULL,FALSE);
						wait_buttonup();
						/*if (go_load_song() == TRUE)
						{	Def_Selected();
						}
						ob_undostate(ex_info->di_tree,LOAD,SELECTED);
						ob_draw_chg(ex_info,LOAD,NULL,FALSE);
						*/
						break;
					case PLAY:	
						if (curr_status != NOSONG) 
						{	int cn;
							ob_dostate(ex_info->di_tree,PLAY,SELECTED);
							ob_draw_chg(ex_info,PLAY,NULL,FALSE);
							wait_buttonup();
							
							if (curr_status == PAUSED)
							{	ob_undostate(ex_info->di_tree,PAUSE,SELECTED);
								ob_draw_chg(ex_info,PAUSE,NULL,FALSE);							
							}
							set_player_status(PLAYING);
						}
						break;
					case PAUSE:			
						if (curr_status == PLAYING)
						{	ob_dostate(ex_info->di_tree,PAUSE,SELECTED);
							ob_draw_chg(ex_info,PAUSE,NULL,FALSE);
							wait_buttonup();
							set_player_status(PAUSED);
						}	else if (curr_status == PAUSED)
						{
							ob_undostate(ex_info->di_tree,PAUSE,SELECTED);
							ob_draw_chg(ex_info,PAUSE,NULL,FALSE);
							set_player_status(PLAYING);
						}
						break;
					case STOP:			
						if ((curr_status == PLAYING) || (curr_status == PAUSED))
						{	ob_dostate(ex_info->di_tree,STOP,SELECTED);
							ob_draw_chg(ex_info,STOP,NULL,FALSE);
							wait_buttonup();
						}
						break;
					case REWIND:
						ob_dostate(ex_info->di_tree,REWIND,SELECTED);
						ob_draw_chg(ex_info,REWIND,NULL,FALSE);
						wait_buttonup();
						ob_undostate(ex_info->di_tree,REWIND,SELECTED);
						ob_draw_chg(ex_info,REWIND,NULL,FALSE);
						break;
					case FORWARD:			
						ob_dostate(ex_info->di_tree,FORWARD,SELECTED);
						ob_draw_chg(ex_info,FORWARD,NULL,FALSE);
						wait_buttonup();
						ob_undostate(ex_info->di_tree,FORWARD,SELECTED);
						ob_draw_chg(ex_info,FORWARD,NULL,FALSE);
						break;
				}
			} else
				close_dialog(ex_info,FALSE);
		}
	}
	already_handling = FALSE;
	
}

void  init_display(void)
{

	switch (open_rsc(RESOURCENAME,"  PLAYMPEG v"VERSION,
	                 "",
	                 "",
	                 "",0,0,0))
	{
		case FAIL:
			form_alert(1, "[3][Resource-File not found|or not enough memory!][Cancel]");
			break;
		case FALSE:
			form_alert(1, "[3][Couldn't open|workstation!][Cancel]");
			break;
		case TRUE:
		{
			
			wind_update(BEG_UPDATE);
			init_resource();
			Event_Handler(InitMsg,Messag);
			/*CycleCloseWindows('W','U',MCYCLE,MCLOSE); */
	        dial_colors(7,(colors>=16) ? LWHITE : WHITE,GREEN,RED,MAGENTA,BLUE,CYAN,RED,RED,BLUE,CYAN,MAGENTA,CYAN,RED,RED);
			dial_options(FALSE,FALSE,FALSE,FALSE,FALSE,FAIL,FALSE,FALSE,TRUE,16);

			title_options(FALSE,BLACK,FALSE);
			check_image(5,NULL);
			menu_install(menu,TRUE);
			wind_update(END_UPDATE);
	
			graf_mouse(BUSYBEE,NULL);
			if (_app)
				OpenDialog(&instlist_win,instlist_tree,WIN_DIAL,NULL,TRUE);

			Event_Multi(NULL);	
		}
	}
	
}


void show_fps(void)
{	static char num[] = "\33E\33f Average FPS:  .  \x0a\x0d";
	extern long start_time,end_time,frame_count;
 	long fps= (frame_count*200*100)/(end_time-start_time);
	num[17]=(fps/1000) + '0';
	fps %= 1000;	
	num[18]=(fps/100) + '0';
	fps %= 100;	
	num[20]=(fps/10) + '0';
	fps %= 10;	
	num[21]=fps + '0';
	Cconws(num);
	wait_key();
}

int registered = 1;

int main(int argc,char *argv[])
{ 
	void *old_stack;
  	Cconws("\33E\33f PLAYMPEG - version 0.70.\x0a\x0d");
  	if (registered)
  	 	Cconws(        " (Registered Colour Version).\x0a\x0d");
  	else
	  	Cconws(        " (Unregistered Grayscale ONLY Version.)\x0a\x0d");
  	Cconws(        " (c) 1994,95 Martin GRIFFiths\x0a\x0d");
  	if (!registered)
	  	delay(3000l);  

  	if ((ld_infile=Fopen(argv[1],FO_READ))<0)
  		do_exit(1);
  	ld_rdptr = malloc(BUFFERSIZE+16+4);
  	ld_rdptr = (unsigned char *) ((long) (ld_rdptr+15) & 0xfffffff0);
 
  	alloc_display();
	init_display();
	
  	go(); 
  	Fclose(ld_infile); 

  	exit_display();

  	show_fps();
  
  return 0;
}

