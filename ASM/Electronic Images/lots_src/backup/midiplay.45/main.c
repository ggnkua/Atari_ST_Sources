/*
 * 		The Digital Sound Module.
 *		(version 0.3)
 * 		(c) 1994 Martin Griffithis
 */ 

#include <stdio.h>
#include <stdlib.h>
#include <e_gem.h>
#include <ext.h>
#include <string.h>
#include "types.h"

void OpenDialog(DIAINFO *info,OBJECT *tree,int dial_mode,SLINFO **,boolean center);
void CloseDialog(DIAINFO *info);
void ExitExample(int all);

char *title = "The Digital Sound Module v"VERSION;
OBJECT *info_tree,*info_tree2,*info_tree3,*instlist_tree,*song_tree,*load_form,*menu;
DIAINFO info_win,instlist_win,song_win,load_win;
DIAINFO *wins[16],*ex_info;
int win_cnt;
long start_time, last_time;

/*
 *	Instrument List Related stuff.
 */

#define SCANUP		(72<<8)
#define SCANDOWN	(80<<8)
#define SCANLEFT	(75<<8)
#define SCANRIGHT	(77<<8)
#define CTRLLEFT	(115<<8)
#define CTRLRIGHT	(116<<8)
#define SCANHOME	(71<<8)

SLKEY sl_instlist_keys[] = {
{ SCANUP, 0, SL_UP },
{ SCANDOWN, 0, SL_DOWN },
{ SCANUP, K_RSHIFT|K_LSHIFT, SL_PG_UP },
{ SCANDOWN, K_RSHIFT|K_LSHIFT , SL_PG_DN },
{ SCANUP, K_CTRL, SL_START },
{ SCANDOWN, K_CTRL, SL_END },
{ SCANHOME, 0, SL_START },
{ SCANHOME, K_RSHIFT|K_LSHIFT, SL_END} };

extern int cdecl draw_instlist(PARMBLK *pb);
extern int cdecl draw_deflist(PARMBLK *pb);
extern void do_instlist(OBJECT *,int,int,int,int);
SLINFO sl_instlist ={&instlist_win,INSTLISTPAR,INSTLISTSLID,INSTLISTUP,INSTLISTDOWN,0,0,0,
					VERT_SLIDER,SL_LINEAR,100,0,do_instlist,&sl_instlist_keys[0],8};

SLINFO *sl_instlist_list[] = {&sl_instlist,NULL};
USERBLK	instlistblk = {draw_instlist,0};
USERBLK	deflistblk = {draw_deflist,0};

void init_resource(void)
{
	rsrc_gaddr(R_TREE, MENU, &menu);
	rsrc_gaddr(0,INFO_WIN,&info_tree);
	rsrc_gaddr(0,INFO_WI2,&info_tree2);
	rsrc_gaddr(0,INFO_WI3,&info_tree3);
	rsrc_gaddr(0,INST_WIN,&instlist_tree);
	rsrc_gaddr(0,LOADING,&load_form);
	
	fix_objects(menu,NO_SCALING,8,16);
	fix_objects(info_tree,TEST_SCALING|DARK_SCALING,8,16);	
	fix_objects(info_tree2,TEST_SCALING|DARK_SCALING,8,16);	
	fix_objects(info_tree3,TEST_SCALING|DARK_SCALING,8,16);	
	fix_objects(instlist_tree,NO_SCALING,8,16);	
	fix_objects(load_form,NO_SCALING,8,16);	

	ob_set_text(info_tree,DATEINFO,__DATE__);
	strcpy(ob_get_text(info_tree,VERSIONINFO,FALSE)+8,VERSION);
	{	reg OBJECT *obj = &(instlist_tree[INSTLISTVIEW]);
		obj->ob_type = G_USERDEF;
		obj->ob_spec.userblk = &instlistblk;	
	}
	{	reg OBJECT *obj = &(instlist_tree[DEFLISTVIEW]);
		obj->ob_type = G_USERDEF;
		obj->ob_spec.userblk = &deflistblk;	
	}	
}


void ExitExample(int all)
{
	while (--win_cnt>=0)
		close_dialog(wins[win_cnt],FALSE);
	if (all && _app)
	{	menu_install(menu,FALSE);
		DSP_DeInit();

		close_rsc();
		exit(0);
	}

	win_cnt=0;
}

void User_Quits(void)
{	if (xalert(	1,1,X_ICN_QUESTION,NULL,BUTTONS_CENTERED,TRUE,title,
				" Do you Really want to Quit? ","[Ok|[Cancel")==0)
		ExitExample(1);
}

int InitMsg(XEVENT *evt,int events_available)
{	if (instlist_win.di_flag>CLOSED && (events_available & MU_TIMER2))
	{	evt->ev_mt2hicount = 0;
		evt->ev_mt2locount = 1000;
		evt->ev_mt2last = last_time;
		return (MU_MESAG|MU_KEYBD|MU_TIMER2);
	}
	else
		return (MU_MESAG|MU_KEYBD);
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
			}
			break;
		case AP_TERM:
		case AC_CLOSE:
			ExitExample(0);
			break;
		case AC_OPEN:
			OpenDialog(&instlist_win,instlist_tree,WIN_DIAL,sl_instlist_list,TRUE);
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


static char *status_txt[] =
{ 	" No Midi Song Loaded.",
	" Playing : 12345678901234567890",
	" Stopped : 12345678901234567890",
	" Paused  : 12345678901234567890" 
};

enum Player_status curr_status = NOSONG;
Bool AutoLoadMapFlag = FALSE;
Bool AutoTestPatchFlag = FALSE;
Bool FilterFlag[16];
typedef enum { INSTRUMENT=0,PERCUSSION = 1 } VIEWING; 
VIEWING Current_View;
int viewinst_selected;
int viewperc_selected;
int selected_channel;
int def_channel_list[16];
static	char info_text[80];
int Patches_Loaded;


/*
 *
 */

void set_player_status(enum Player_status s)
{	curr_status = s;
	(&instlist_tree[STATUSTXT])->ob_spec.tedinfo->te_ptext=status_txt[s];
	if (instlist_win.di_flag>CLOSED)
		ob_draw_chg(&instlist_win,STATUSTXT,NULL,FAIL,FALSE);

}

/*
 *
 */

void set_player_status_filename(char *name)
{	strcpy((char *) status_txt[STOPPED]+11,name);
	strcpy((char *) status_txt[PLAYING]+11,name);
	strcpy((char *) status_txt[PAUSED]+11,name);
}


void Update_Main_Info_Bar()
{	sprintf	(info_text," Patches Resident : %03d.   Memory Free : %05ld Kb ",Patches_Loaded,coreleft()/1024l);
	(&instlist_tree[PLAYERINFO])->ob_spec.tedinfo->te_ptext=info_text;
	if (instlist_win.di_flag>CLOSED)
		ob_draw_chg(&instlist_win,PLAYERINFO,NULL,FAIL,FALSE);
}


void Update_Instrument_Info_Box()
{	char *patchname;
	char patchsizetxt[24];
	unsigned long patchsize;
	if (Current_View == INSTRUMENT)
		patchname = gm_instrument_fnames[viewinst_selected];
	else
		patchname = gm_percussion_fnames[viewperc_selected];
	patchsize = filesize(patchname);
	if (patchsize != -1l)
		ultoa(patchsize, patchsizetxt, 10 );
		
	patchname = strrchr(patchname,(int)'\\')+1;		
	strcpy((&instlist_tree[CPATCHFNAME])->ob_spec.tedinfo->te_ptext, patchname);
	strcpy((&instlist_tree[CPATCHSIZE])->ob_spec.tedinfo->te_ptext, patchsizetxt);
	if (instlist_win.di_flag>CLOSED)
	{	ob_draw_chg(&instlist_win,CPATCHFNAME,NULL,FAIL,FALSE);
		ob_draw_chg(&instlist_win,CPATCHSIZE,NULL,FAIL,FALSE);
	}

}
/*
 *
 */


void Set_ViewingList(VIEWING type)
{	if (type == INSTRUMENT)
	{	
		ob_dostate(instlist_tree,PERC_BUT,DISABLED);
		ob_undostate(instlist_tree,PERC_BUT,SELECTED);
		ob_undostate(instlist_tree,INST_BUT,DISABLED);
		ob_dostate(instlist_tree,INST_BUT,SELECTED);
		init_instlist(gm_instrument,NO_INSTRUMENT,&viewinst_selected);
	}
	else
	{
		ob_dostate(instlist_tree,INST_BUT,DISABLED);
		ob_undostate(instlist_tree,PERC_BUT,DISABLED);
		ob_undostate(instlist_tree,INST_BUT,SELECTED);
		ob_dostate(instlist_tree,PERC_BUT,SELECTED);
		init_instlist(gm_percussion,NO_PERCUSSION,&viewperc_selected);
	}
	if (instlist_win.di_flag>CLOSED)
	{	ob_draw_chg(&instlist_win,PERC_BUT,NULL,FAIL,FALSE);
		ob_draw_chg(&instlist_win,INST_BUT,NULL,FAIL,FALSE);	
		ob_draw_chg(&instlist_win,INSTLISTVIEW,NULL,FAIL,FALSE);
	}
	Current_View = type;
}

void Set_Deflist(void)
{
	init_deflist();
}

/*
 *
 */

void Set_AutoTestPatch(Bool flag)
{		
	if (flag == TRUE)
		ob_dostate(instlist_tree,AUTOTEST_BUT,SELECTED);
	else
		ob_undostate(instlist_tree,AUTOTEST_BUT,SELECTED);
	AutoTestPatchFlag = flag;
}

/*
 *
 */
 
void Set_AutoLoadMap(Bool flag)
{	if (flag == TRUE)
		ob_dostate(instlist_tree,AUTOLOAD_BUT,SELECTED);
	else
		ob_undostate(instlist_tree,AUTOLOAD_BUT,SELECTED);
	AutoLoadMapFlag = flag;
}

/*
 *
 */

void SetChannelFilterFlag(int n,Bool flag)
{	int obj_n = n + FLCH01;
	if (flag == TRUE)
		ob_dostate(instlist_tree,obj_n,CROSSED);
	else
		ob_undostate(instlist_tree,obj_n,CROSSED);
	FilterFlag[n]=flag;
	
}

/*
 *
 */

void SetChannelUsed(int n,Bool flag)
{	int obj_n = n + FLCH01;
	if (flag == TRUE)
		ob_dostate(instlist_tree,obj_n,SELECTED);
	else
		ob_undostate(instlist_tree,obj_n,SELECTED);
	if (instlist_win.di_flag>CLOSED)
		ob_draw_chg(&instlist_win,obj_n,NULL,FAIL,FALSE);
	
}


/*
 *
 */

void OpenDialog(DIAINFO *info,OBJECT *tree,int dial_mode,SLINFO **slider,boolean center)
{
	reg char *name = title;
	reg int double_click,right_click,exit = win_cnt;
 	int x,y,j,k;
	switch (info->di_flag)
	{
	case WINDOW:
	case WIN_MODAL:
		wind_set(info->di_win->handle,WF_TOP);
		break;
	case CLOSED:
		if (open_dialog(tree,info,name,center,FALSE,dial_mode,0,slider))
			wins[win_cnt++] = info;
		else
			xalert(1,1,X_ICN_ERROR,NULL,BUTTONS_CENTERED,TRUE,title,"Keine freien Fenster mehr!","[Ok");
	}

	if (exit>0)
		return;

	while (win_cnt>0)
	{	
kludge:
		exit = X_Form_Do(&ex_info);
		if (exit == W_CLOSED)
			CloseDialog(ex_info);
		else if (exit == W_ABANDON)
			ExitExample(0);
		else
		{	exit ^= (double_click = exit & 0x8000);
			exit ^= (right_click  = exit & 0x4000);
			if (ex_info==&instlist_win)
			{
				switch (exit)
				{	
					case AUTOLOAD_BUT:
						if (AutoLoadMapFlag == TRUE)
							Set_AutoLoadMap(FALSE);
						else
							Set_AutoLoadMap(TRUE);
						ob_draw_chg(ex_info,AUTOLOAD_BUT,NULL,FAIL,FALSE);
						wait_buttonup();
						
						break;
					case AUTOTEST_BUT:
						if (AutoTestPatchFlag == TRUE)
							Set_AutoTestPatch(FALSE);
						else					
							Set_AutoTestPatch(TRUE);
						ob_draw_chg(ex_info,AUTOTEST_BUT,NULL,FAIL,FALSE);
						wait_buttonup();
						break;
					case LOAD:		
						ob_dostate(ex_info->di_tree,LOAD,SELECTED);
						ob_draw_chg(ex_info,LOAD,NULL,FAIL,FALSE);
						wait_buttonup();
						if (go_load_song() == TRUE)	
						{	if (curr_status == NOSONG)
								set_player_status(STOPPED);
						}
						ob_undostate(ex_info->di_tree,LOAD,SELECTED);
						ob_draw_chg(ex_info,LOAD,NULL,FAIL,FALSE);
						break;
					case PLAY:	
						if (curr_status != NOSONG) 
						{	ob_dostate(ex_info->di_tree,PLAY,SELECTED);
							ob_draw_chg(ex_info,PLAY,NULL,FAIL,FALSE);
							wait_buttonup();
							set_player_status(PLAYING);
							DOPLAY();		
						}
						break;
					case PAUSE:			
						if (curr_status == PLAYING)
						{	ob_dostate(ex_info->di_tree,PAUSE,SELECTED);
							ob_draw_chg(ex_info,PAUSE,NULL,FAIL,FALSE);
							wait_buttonup();
							set_player_status(PAUSED);
						}	else if (curr_status == PAUSED)
						{
							ob_undostate(ex_info->di_tree,PAUSE,SELECTED);
							ob_draw_chg(ex_info,PAUSE,NULL,FAIL,FALSE);
							set_player_status(PLAYING);
						}
						break;
					case STOP:			
						if ((curr_status == PLAYING) || (curr_status == PAUSED))
						{	ob_dostate(ex_info->di_tree,STOP,SELECTED);
							ob_draw_chg(ex_info,STOP,NULL,FAIL,FALSE);
							wait_buttonup();
							DOSTOP();		
							if (curr_status == PAUSED)
							{	ob_undostate(ex_info->di_tree,PAUSE,SELECTED);
								ob_draw_chg(ex_info,PAUSE,NULL,FAIL,FALSE);
							}
							ob_undostate(ex_info->di_tree,PLAY,SELECTED);
							ob_draw_chg(ex_info,PLAY,NULL,FAIL,FALSE);
							ob_undostate(ex_info->di_tree,STOP,SELECTED);
							ob_draw_chg(ex_info,STOP,NULL,FAIL,FALSE);
							set_player_status(STOPPED);
						}
						break;
					case REWIND:
						ob_dostate(ex_info->di_tree,REWIND,SELECTED);
						ob_draw_chg(ex_info,REWIND,NULL,FAIL,FALSE);
						wait_buttonup();
						ob_undostate(ex_info->di_tree,REWIND,SELECTED);
						ob_draw_chg(ex_info,REWIND,NULL,FAIL,FALSE);
						break;
					case FORWARD:			
						ob_dostate(ex_info->di_tree,FORWARD,SELECTED);
						ob_draw_chg(ex_info,FORWARD,NULL,FAIL,FALSE);
						wait_buttonup();
						ob_undostate(ex_info->di_tree,FORWARD,SELECTED);
						ob_draw_chg(ex_info,FORWARD,NULL,FAIL,FALSE);
						break;
					case MIDIIN_BUT:
						ob_dostate(ex_info->di_tree,MIDIIN_BUT,SELECTED);
						ob_draw_chg(ex_info,MIDIIN_BUT,NULL,FAIL,FALSE);
						wait_buttonup();
						ob_undostate(ex_info->di_tree,MIDIIN_BUT,SELECTED);
						ob_draw_chg(ex_info,MIDIIN_BUT,NULL,FAIL,FALSE);
						break;
					case INSTLISTVIEW:
						graf_mkstate(&x,&y,&j,&k);
						j = selected_object_instlist(y);
						if (right_click)
						{	char curr_songpath[256];  
							char curr_songname[256];  
							char selected_song[256];
							strcpy(curr_songname,strrchr(gm_instrument_fnames[j],(int) '\\')+1);								
							if (select_file(selected_song,gm_instrument_fnames[j],curr_songname,"*.PAT","Select .PAT file"))
							{	strcpy(gm_instrument_fnames[j],selected_song);
							}
						}
						if (double_click)
						{	def_channel_list[selected_channel] = j;
							redraw_selected_def();
						}
						
						Update_Instrument_Info_Box();

						break;
					case DEFLISTVIEW:
						graf_mkstate(&x,&y,&j,&k);
						selected_object_deflist(y);
						if (selected_channel != 9)
						{ 	viewinst_selected = def_channel_list[selected_channel];
							Set_ViewingList(INSTRUMENT);
						} else
						{ 	viewinst_selected = def_channel_list[selected_channel];
							Set_ViewingList(PERCUSSION);
						}
						wait_buttonup();
						
						break;
					
					case FLCH01:
					case FLCH02:
					case FLCH03:
					case FLCH04:
					case FLCH05:
					case FLCH06:
					case FLCH07:
					case FLCH08:
					case FLCH09:
					case FLCH10:
					case FLCH11:
					case FLCH12:
					case FLCH13:
					case FLCH14:
					case FLCH15:
					case FLCH16:
						{	reg int i = exit-FLCH01;
							if (FilterFlag[i] == TRUE)
								SetChannelFilterFlag(i,FALSE);
							else
								SetChannelFilterFlag(i,TRUE);
							ob_draw_chg(ex_info,exit,NULL,FAIL,FALSE);
							wait_buttonup();
						}
						break;
					case PERC_BUT:
						if (Current_View != PERCUSSION)
						{	Set_ViewingList(PERCUSSION);
							wait_buttonup();
						}
						break;
					case INST_BUT:
						if (Current_View != PERCUSSION)
						{	Set_ViewingList(INSTRUMENT);
							wait_buttonup();
						}
	
						break;
					case LCFG_BUT:
						ob_dostate(ex_info->di_tree,LCFG_BUT,SELECTED);
						ob_draw_chg(ex_info,LCFG_BUT,NULL,FAIL,FALSE);
						wait_buttonup();
						load_map();
						ob_undostate(ex_info->di_tree,LCFG_BUT,SELECTED);
						ob_draw_chg(ex_info,LCFG_BUT,NULL,FAIL,FALSE);						
						break;
					case SCFG_BUT:
						ob_dostate(ex_info->di_tree,SCFG_BUT,SELECTED);
						ob_draw_chg(ex_info,SCFG_BUT,NULL,FAIL,FALSE);
						wait_buttonup();
						save_map();
						ob_undostate(ex_info->di_tree,SCFG_BUT,SELECTED);
						ob_draw_chg(ex_info,SCFG_BUT,NULL,FAIL,FALSE);						
						break;
						
				}
			} else if (ex_info==&info_win)
			{	
				ob_dostate(ex_info->di_tree,exit,SELECTED);
				ob_draw_chg(ex_info,exit,NULL,FAIL,FALSE);
				wait_buttonup();
				ob_undostate(ex_info->di_tree,exit,SELECTED);
				ob_draw_chg(ex_info,exit,NULL,FAIL,FALSE);						
				switch (exit)
				{	case ABOUTOK:
						CloseDialog(ex_info);
						break;
					case ABOUTMOREINFO:
					{	int msg[8];
						CloseDialog(ex_info);
						OpenDialog(&info_win,info_tree2,WIN_DIAL,NULL,FALSE);
/*						ex_info->di_tree = info_tree2;
						msg[0] = WM_TOPPED;
						msg[1] = ap_id;
						appl_write(ap_id,16,msg);
						msg[0] = WM_REDRAW;
						msg[1] = ap_id;
						msg[3] = 2;
						msg[4] = 0;
						msg[5] = 0;
						msg[6] = 1000;
						msg[7] = 1000;
						appl_write(ap_id,16,msg);*/						
					}
						break;
					case ABOUTCANCEL:
						CloseDialog(ex_info);
						break;
					case ABOUTCONTINUE:
						CloseDialog(ex_info);
						OpenDialog(&info_win,info_tree3,WIN_DIAL,NULL,FALSE);
						break;
					case ABOUTEND:
						CloseDialog(ex_info);
						break;								
				}
			}
			 else
				CloseDialog(ex_info);
		}
	}
}


void CloseDialog(DIAINFO *info)
{	if (info->di_flag>CLOSED)
	{
		int i;
		close_dialog(info,FALSE);
		for (i=0;i<win_cnt;i++)
			if (wins[i]==info)
				break;
		for (win_cnt--;i<win_cnt;i++)
			wins[i] = wins[i+1];
	}
}


/*
 *     Main... 
 */

void main()
{	last_time = start_time = clock()*5;

	switch (open_rsc(RESOURCENAME,"  T.D.S.M. v"VERSION,
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
			CycleCloseWindows('W','U',MCYCLE,MCLOSE);
            dial_colors(7,(colors>=16) ? YELLOW : LWHITE,BLACK,BLACK,BLACK,BLUE,CYAN);
			dial_options(TRUE,TRUE,FALSE,TRUE,FAIL,TRUE,FALSE,FALSE,TRUE);
			title_options(FALSE,BLACK,FALSE);
			check_image(5,NULL);
			menu_install(menu,TRUE);
			wind_update(END_UPDATE);
	
			if (DSP_Init() == FALSE)
				ExitExample(1);
			
			set_player_status(NOSONG);
			Set_AutoTestPatch(TRUE);
			Set_AutoLoadMap(TRUE);
			selected_channel = 0;
			def_channel_list[0]=0;
			def_channel_list[1]=8;
			def_channel_list[2]=16;
			def_channel_list[3]=24;
			def_channel_list[4]=32;
			def_channel_list[5]=40;
			def_channel_list[6]=48;
			def_channel_list[7]=56;
			def_channel_list[8]=64;
			def_channel_list[9]=0;			/* percussion */
			def_channel_list[10]=72;
			def_channel_list[11]=80;
			def_channel_list[12]=88;
			def_channel_list[13]=96;
			def_channel_list[14]=104;
			def_channel_list[15]=112;
			
			Set_Deflist();
			viewinst_selected=0;
			viewperc_selected=0;
			Set_ViewingList(INSTRUMENT);

			Update_Main_Info_Bar();
			Update_Instrument_Info_Box();


			if (_app)
				OpenDialog(&instlist_win,instlist_tree,WIN_DIAL,sl_instlist_list,TRUE);

			Event_Multi(NULL);	
		}
	}
}

	

