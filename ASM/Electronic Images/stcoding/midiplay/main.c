/*
 * 		The Digital Sound Module.
 *		(version 0.67)
 * 		(c) 1994 Martin Griffiths
 *		December 7th 1994.
 */ 

#include <stdio.h>
#include <stdlib.h>
#include <e_gem.h>
#include <string.h>
#include <ext.h>
#include "midiplay.h"
#include "types.h"
char gm_instrument[NO_INSTRUMENT][PNAME_LEN];
char gm_percussion[NO_PERCUSSION][PNAME_LEN];
char gm_instrument_fnames[NO_INSTRUMENT][FNAME_LEN];
char gm_percussion_fnames[NO_PERCUSSION][FNAME_LEN];

static char *Channel_Type_Text[] = { "I","P" };
void OpenDialog(DIAINFO *info,OBJECT *tree,int dial_mode,SLINFO **,boolean center);
void ExitExample(int all);

char *title = "The Digital Sound Module v"VERSION;
char *small_title = "T.D.S.M";

OBJECT *info_tree,*info_tree2,*info_tree3;
OBJECT *instlist_tree,*song_tree,*load_form,*menu,*chaninf_tree,*patchmap_tree;
DIAINFO info_win,instlist_win,song_win,load_win,chaninf_win,patchmap_win;
DIAINFO *ex_info;

static long start_time, last_time,last_timer2,last_timer3,last_timer4;
static char *status_txt[] =
{ 	" No Midi Song Loaded.",
	" Playing : 12345678901234567890",
	" Stopped : 12345678901234567890",
	" Paused  : 12345678901234567890" 
	" Midi Input Mode."
};

enum Player_status curr_status = NOSONG;

static int already_handling = FALSE;
static char curr_selppath[256];  
static char curr_selpname[256];  
static char selected_pat[256];
static char selected_newpat[256];
static Bool selected_good = FALSE;

/*
 *	Instrument List Related stuff.
 */


SLKEY sl_instlist_keys[] = {
{ sl_key(SCANUP,0), 0, SL_UP },
{ sl_key(SCANDOWN,0), 0, SL_DOWN },
{ sl_key(SCANUP,0), K_RSHIFT|K_LSHIFT, SL_PG_UP },
{ sl_key(SCANDOWN,0), K_RSHIFT|K_LSHIFT , SL_PG_DN },
{ sl_key(SCANUP,0), K_CTRL, SL_START },
{ sl_key(SCANDOWN,0), K_CTRL, SL_END },
{ sl_key(SCANHOME,0), 0, SL_START },
{ sl_key(SCANHOME,0), K_RSHIFT|K_LSHIFT, SL_END} };

extern void do_instlist(OBJECT *,int,int,int,int);
extern void do_mastervol(OBJECT *,int,int,int,int);
extern void do_masterbal(OBJECT *,int,int,int,int);
extern void do_chan_vol(OBJECT *,int,int,int,int);
extern void do_chan_bal(OBJECT *,int,int,int,int);

SLINFO 	sl_instlist =
					{&instlist_win,INSTLISTPAR,INSTLISTSLID,INSTLISTUP,INSTLISTDOWN,0,0,0,
					VERT_SLIDER,SL_LINEAR,100,0,do_instlist,&sl_instlist_keys[0],8},
		sl_mastrvol =
 					{&instlist_win,MVOL_PAR,MVOL_SLID,-1,-1,0,0,0,
					HOR_SLIDER,SL_LINEAR,128,0,do_mastervol,NULL,0},
		sl_mastrbal =
 					{&instlist_win,MBAL_PAR,MBAL_SLID,-1,-1,0,0,0,
					HOR_SLIDER,SL_LINEAR,128,0,do_masterbal,NULL,0},
		sl_chan_vol =
					{&chaninf_win,CHNVOL_PAR,CHNVOL_SLID,-1,-1,0,0,0,
					HOR_SLIDER,SL_LINEAR,128,0,do_chan_vol,NULL,0},
		sl_chan_bal =
 					{&chaninf_win,CHNPAN_PAR,CHNPAN_SLID,-1,-1,0,0,0,
					HOR_SLIDER,SL_LINEAR,128,0,do_chan_bal,NULL,0},

		*sl_instlist_list[] = {&sl_instlist,&sl_mastrbal,&sl_mastrvol,NULL,NULL},

		*sl_chan_inf_list[] = {&sl_chan_vol,&sl_chan_bal,NULL};

void init_mastervol(long volume)
{	
 	sl_mastrvol.sl_page = 2;
	sl_mastrvol.sl_max = 128+2;
	sl_mastrvol.sl_pos = volume;
	master_vol = volume;
	graf_set_slider(&sl_mastrvol,instlist_tree,GRAF_SET);
	if (instlist_win.di_flag>CLOSED)
		graf_set_slider(&sl_mastrvol,instlist_tree,GRAF_DRAW);
}

void init_masterbal(long balance)
{	
 	sl_mastrbal.sl_page = 2;
	sl_mastrbal.sl_max = 128+2;
	sl_mastrbal.sl_pos = balance;
	master_bal = balance;
	graf_set_slider(&sl_mastrbal,instlist_tree,GRAF_SET);
	if (instlist_win.di_flag>CLOSED)
		graf_set_slider(&sl_mastrbal,instlist_tree,GRAF_DRAW);
}

void do_mastervol(OBJECT *obj,int pos,int prev,int max_pos,int top)
{		master_vol = pos;
}

void do_masterbal(OBJECT *obj,int pos,int prev,int max_pos,int top)
{		master_bal = pos;
}

void init_chan_vol(int chnvol)
{	sl_chan_vol.sl_page = 2;
	sl_chan_vol.sl_max = 128+2;
	sl_chan_vol.sl_pos = chnvol;
	graf_set_slider(&sl_chan_vol,chaninf_tree,GRAF_SET);
	if (chaninf_win.di_flag>CLOSED)
		graf_set_slider(&sl_chan_vol,chaninf_tree,GRAF_DRAW);
}

void init_chan_bal(int chnbal)
{	sl_chan_bal.sl_page = 2;
	sl_chan_bal.sl_max = 128+2;
	sl_chan_bal.sl_pos = chnbal;
	graf_set_slider(&sl_chan_bal,chaninf_tree,GRAF_SET);
	if (chaninf_win.di_flag>CLOSED)
		graf_set_slider(&sl_chan_bal,chaninf_tree,GRAF_DRAW);
}


void do_chan_vol(OBJECT *obj,int pos,int prev,int max_pos,int top)
{	channels_info[selected_channel].channel_volume = pos;

}

void do_chan_bal(OBJECT *obj,int pos,int prev,int max_pos,int top)
{	channels_info[selected_channel].channel_pan = pos;
}

/* 
 *	Various Channel Filters.
 */

void SetChannel_NoteOn_Ef(Bool f)
{	
	if (f == TRUE)
		ob_dostate(chaninf_tree,CHN_NOTEON,SELECTED);
	else
		ob_undostate(chaninf_tree,CHN_NOTEON,SELECTED);
	channels_info[selected_channel].noteon_ef = f;
	if (chaninf_win.di_flag>CLOSED)
	{		
			ob_draw_chg(&chaninf_win,CHN_NOTEON,NULL,FAIL,FALSE);
	}
}
void SetChannel_PolyPres_Ef(Bool f)
{
	if (f == TRUE)
		ob_dostate(chaninf_tree,CHN_POLYPRES,SELECTED);
	else
		ob_undostate(chaninf_tree,CHN_POLYPRES,SELECTED);
	channels_info[selected_channel].polypres_ef = f;
	if (chaninf_win.di_flag>CLOSED)
	{		
			ob_draw_chg(&chaninf_win,CHN_POLYPRES,NULL,FAIL,FALSE);
	}
}

void SetChannel_Controller_Ef(Bool f)
{
	if (f == TRUE)
		ob_dostate(chaninf_tree,CHN_CONTROLLER,SELECTED);
	else
		ob_undostate(chaninf_tree,CHN_CONTROLLER,SELECTED);
	channels_info[selected_channel].controller_ef = f;
	if (chaninf_win.di_flag>CLOSED)
	{		
			ob_draw_chg(&chaninf_win,CHN_CONTROLLER,NULL,FAIL,FALSE);
	}
}
void SetChannel_ProgChange_Ef(Bool f)
{
	if (f == TRUE)
		ob_dostate(chaninf_tree,CHN_PROGCHANGE,SELECTED);
	else
		ob_undostate(chaninf_tree,CHN_PROGCHANGE,SELECTED);
	channels_info[selected_channel].progchange_ef = f;
	if (chaninf_win.di_flag>CLOSED)
	{		
			ob_draw_chg(&chaninf_win,CHN_PROGCHANGE,NULL,FAIL,FALSE);
	}
}

void SetChannel_AfterTouch_Ef(Bool f)
{
	if (f == TRUE)
		ob_dostate(chaninf_tree,CHN_AFTERTOUCH,SELECTED);
	else
		ob_undostate(chaninf_tree,CHN_AFTERTOUCH,SELECTED);
	channels_info[selected_channel].aftertouch_ef = f;

	if (chaninf_win.di_flag>CLOSED)
	{		
			ob_draw_chg(&chaninf_win,CHN_AFTERTOUCH,NULL,FAIL,FALSE);
	}
}

void SetChannel_PitchBend_Ef(Bool f)
{
	if (f == TRUE)
		ob_dostate(chaninf_tree,CHN_PITCHBEND,SELECTED);
	else
		ob_undostate(chaninf_tree,CHN_PITCHBEND,SELECTED);
	channels_info[selected_channel].pitchbend_ef = f;
	if (chaninf_win.di_flag>CLOSED)
	{		
			ob_draw_chg(&chaninf_win,CHN_PITCHBEND,NULL,FAIL,FALSE);
	}
}

/*
 *
 */

void Set_ViewingList(VIEWING type)
{	if (type == INSTRUMENT)
	{	
		init_instlist(gm_instrument,NO_INSTRUMENT,&viewinst_selected);
	}
	else
	{
		init_instlist(gm_percussion,NO_PERCUSSION,&viewperc_selected);
	}
	if (instlist_win.di_flag>CLOSED)
	{	ob_draw_chg(&instlist_win,INSTLISTVIEW,NULL,FAIL,FALSE);
	}
	Current_View = type;
}

extern USERBLK	instlistblk;
extern USERBLK	deflistblk;

void init_resource(void)
{
	rsrc_gaddr(R_TREE, MENU, &menu);
	rsrc_gaddr(0,INFO_WIN,&info_tree);
	rsrc_gaddr(0,INFO_WI2,&info_tree2);
	rsrc_gaddr(0,INFO_WI3,&info_tree3);
	rsrc_gaddr(0,INST_WIN,&instlist_tree);
	rsrc_gaddr(0,LOADING,&load_form);
	rsrc_gaddr(0,CHANINF,&chaninf_tree);
	rsrc_gaddr(0,PATCHMAP,&patchmap_tree);
	
	fix_objects(menu,NO_SCALING,8,16);
	fix_objects(info_tree,TEST_SCALING|DARK_SCALING,8,16);	
	fix_objects(info_tree2,TEST_SCALING|DARK_SCALING,8,16);	
	fix_objects(info_tree3,TEST_SCALING|DARK_SCALING,8,16);	
	fix_objects(instlist_tree,NO_SCALING,8,16);	
	fix_objects(load_form,NO_SCALING,8,16);	
	fix_objects(chaninf_tree,NO_SCALING,8,16 );
	fix_objects(patchmap_tree,NO_SCALING,8,16 );

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
	close_all_dialogs();
	if (all)
	{	DSP_DeInit();
		menu_install(menu,FALSE);
		close_rsc(0);
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
		evt->ev_mt2count = 500;		
		evt->ev_mt2last = last_timer2;
		flags |= MU_TIMER2;		
	}

	return (flags & events_available);
}

int Messag(XEVENT *event)
{
	reg int ev = event->ev_mwich,*msg = event->ev_mmgpbuf;
	reg int used = 0;
	if (ev & MU_TIMER2)
	{	extern long tmr_count;
		OBJECT *ob1 = &instlist_tree[CPUBOX1];
		OBJECT *ob2 = &instlist_tree[CPUBOX2];
		ob1->ob_width = tmr_count;
		if (ob1->ob_width > 100)
			ob1->ob_width = 100;
		ob2->ob_width = 100-ob1->ob_width;
		if (ob2->ob_width < 0)
			ob2->ob_width = 0;
		ob2->ob_x = ob1->ob_x+ob1->ob_width;
		last_timer2 = event->ev_mt2last;
		if (instlist_win.di_flag>CLOSED)
		{	ob_draw_chg(&instlist_win,CPUBOX1,NULL,FAIL,FALSE);
			ob_draw_chg(&instlist_win,CPUBOX2,NULL,FAIL,FALSE);
		}

		used |= MU_TIMER2;

		tmr_count = 0;

	}

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
					OpenDialog(&instlist_win,instlist_tree,WIN_DIAL,sl_instlist_list,TRUE);
					break;	 /* MCYCLE/MCLOSE handled internally */
				case MHQ_MODE:
					 if (HQModeFlag == TRUE)
						Set_HQ_Mode(FALSE);
					else
						Set_HQ_Mode(TRUE);
					break;
				case MAUTO_LOAD:
					if (AutoLoadMapFlag == TRUE)
						Set_AutoLoadMap(FALSE);
					else
						Set_AutoLoadMap(TRUE);
					break;
				case MAUTO_TEST:
					if (AutoTestPatchFlag == TRUE)
						Set_AutoTestPatch(FALSE);
					else					
						Set_AutoTestPatch(TRUE);
					break;
				case MLOADCFG:
					if (load_cfg() == TRUE)
					{	
						Redraw_DefList();
						Set_ViewingList(Current_View);
					}
					break;
				case MSAVECFG:
					save_cfg();
					break;					
											
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
			OpenDialog(&instlist_win,instlist_tree,WIN_DIAL,sl_instlist_list,TRUE);
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


void Update_Instrument_Info_Box()
{	char *patchname;
	char patchsizetxt[24];
	unsigned long patchsize;
	if (Current_View == INSTRUMENT)
		patchname = &gm_instrument_fnames[viewinst_selected][0];
	else
		patchname = &gm_percussion_fnames[viewperc_selected][0];
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


void Def_Selected(void)
{		if (def_channel_type[selected_channel] == INSTRUMENT_CHANNEL)
		{ 	viewinst_selected = def_channel_list[selected_channel];
			Set_ViewingList(INSTRUMENT);
		} else
		{ 	viewperc_selected = def_channel_list[selected_channel];
			Set_ViewingList(PERCUSSION);
		}
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
	if (instlist_win.di_flag>CLOSED)
		ob_draw_chg(&instlist_win,obj_n,NULL,FAIL,FALSE);
}

void Set_InstOrPerc(int n,Channel_Type t)
{	int obj_n = INSTPERC01+n;
	OBJECT *obj = &(instlist_tree[obj_n]);
	def_channel_type[n] = t;
	strcpy(obj->ob_spec.tedinfo->te_ptext, Channel_Type_Text[t]);
	if (instlist_win.di_flag>CLOSED)
	{	ob_draw_chg(&instlist_win,obj_n,NULL,FAIL,FALSE);
	}
	
	
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


void PlayMusic(void)
{		DOPLAY();
}

void StopMusic(void)
{		extern Bool Song_Loaded;
		DOSTOP();
		if (Song_Loaded == TRUE)
		{	ResetMidiTracks();
			ob_undostate(ex_info->di_tree,PAUSE,SELECTED);
			ob_draw_chg(ex_info,PAUSE,NULL,FAIL,FALSE);
			ob_undostate(ex_info->di_tree,PLAY,SELECTED);
			ob_draw_chg(ex_info,PLAY,NULL,FAIL,FALSE);
			ob_undostate(ex_info->di_tree,STOP,SELECTED);
			ob_draw_chg(ex_info,STOP,NULL,FAIL,FALSE);
			set_player_status(STOPPED);		
		}
}

void PauseMusic(void)
{		DOPAUSE();
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
		if (open_dialog(tree,info,name,icon_name,NULL,center,FALSE,dial_mode,0,slider)==FALSE)
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
						ob_draw_chg(ex_info,LOAD,NULL,FAIL,FALSE);
						wait_buttonup();
						if (go_load_song() == TRUE)
						{	Def_Selected();
						}
						ob_undostate(ex_info->di_tree,LOAD,SELECTED);
						ob_draw_chg(ex_info,LOAD,NULL,FAIL,FALSE);
						break;
					case PLAY:	
						if (curr_status != NOSONG) 
						{	int cn;
							ob_dostate(ex_info->di_tree,PLAY,SELECTED);
							ob_draw_chg(ex_info,PLAY,NULL,FAIL,FALSE);
							wait_buttonup();
							
							if (curr_status == PAUSED)
							{	ob_undostate(ex_info->di_tree,PAUSE,SELECTED);
								ob_draw_chg(ex_info,PAUSE,NULL,FAIL,FALSE);							
							}
							set_player_status(PLAYING);
							for (cn = 0 ; cn < 16 ; cn++)
								channels_info[cn].channel_inst = def_channel_list[cn];
							
							PlayMusic();		
						}
						break;
					case PAUSE:			
						if (curr_status == PLAYING)
						{	ob_dostate(ex_info->di_tree,PAUSE,SELECTED);
							ob_draw_chg(ex_info,PAUSE,NULL,FAIL,FALSE);
							wait_buttonup();
							set_player_status(PAUSED);
							PauseMusic();
						}	else if (curr_status == PAUSED)
						{
							ob_undostate(ex_info->di_tree,PAUSE,SELECTED);
							ob_draw_chg(ex_info,PAUSE,NULL,FAIL,FALSE);
							set_player_status(PLAYING);
							PauseMusic();
						}
						break;
					case STOP:			
						if ((curr_status == PLAYING) || (curr_status == PAUSED))
						{	ob_dostate(ex_info->di_tree,STOP,SELECTED);
							ob_draw_chg(ex_info,STOP,NULL,FAIL,FALSE);
							wait_buttonup();
							StopMusic();		
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
						StopMusic();		
						DOMIDIIN();
						ob_undostate(ex_info->di_tree,MIDIIN_BUT,SELECTED);
						ob_draw_chg(ex_info,MIDIIN_BUT,NULL,FAIL,FALSE);
						break;
					case INSTLISTVIEW:
						graf_mkstate(&x,&y,&j,&k);
						j = selected_object_instlist(y);
						strcpy((&patchmap_tree[PNAME])->ob_spec.tedinfo->te_ptext,&gm_instrument[j][0]);
						selected_good = FALSE;
						if (patchmap_win.di_flag>CLOSED)
						{		ob_draw_chg(&patchmap_win,PNAME,NULL,FAIL,FALSE);
						}
						if (double_click)
						{	OpenDialog(&patchmap_win,patchmap_tree,WIN_DIAL,NULL,FALSE);
						} else
						{	char this_used[NO_INSTRUMENT];
							int i;
							for (i = 0 ; i < NO_INSTRUMENT ; i++)
								this_used[i] = 0;
							def_channel_list[selected_channel] = j;
							this_used[j] = -1;
							if (curr_status == PLAYING)
								DOPAUSE();
							Do_Load_Patches(&this_used[0],&gm_instrument_fnames[0][0],NO_INSTRUMENT);
							Redraw_DefList();
							channels_info[selected_channel].channel_inst = j;
							if (curr_status == PLAYING)
								DOPAUSE(); 
						}
						Update_Instrument_Info_Box();

						break;
					case DEFLISTVIEW:
					{	char *numb_txt = (&chaninf_tree[CHN_NUMBERTXT])->ob_spec.tedinfo->te_ptext + 8;
						int s;
						graf_mkstate(&x,&y,&j,&k);
						selected_object_deflist(y);
						s = selected_channel +1;
						*numb_txt++ = (s / 10) +'0';
						*numb_txt =   (s % 10) +'0';
						
						Def_Selected();
						Update_Instrument_Info_Box();
				
						if (chaninf_win.di_flag>CLOSED)
						{		ob_draw_chg(&chaninf_win,CHN_NUMBERTXT,NULL,FAIL,FALSE);
								SetChannel_NoteOn_Ef((Bool)channels_info[selected_channel].noteon_ef);
								SetChannel_PolyPres_Ef((Bool)channels_info[selected_channel].polypres_ef);
								SetChannel_Controller_Ef((Bool)channels_info[selected_channel].controller_ef);
								SetChannel_ProgChange_Ef((Bool)channels_info[selected_channel].progchange_ef);
								SetChannel_AfterTouch_Ef((Bool)channels_info[selected_channel].aftertouch_ef);
								SetChannel_PitchBend_Ef((Bool)channels_info[selected_channel].pitchbend_ef);
								init_chan_vol(channels_info[selected_channel].channel_volume);
								init_chan_bal(channels_info[selected_channel].channel_pan);	
						}
						if (double_click)
						{		
								OpenDialog(&chaninf_win,chaninf_tree,WIN_DIAL,sl_chan_inf_list,TRUE);
								init_chan_vol(channels_info[selected_channel].channel_volume);
								init_chan_bal(channels_info[selected_channel].channel_pan);	
						}						
						wait_buttonup();
						
						break;
					}
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
							wait_buttonup();
						}
						break;
					case INSTPERC01:
					case INSTPERC02:
					case INSTPERC03:
					case INSTPERC04:
					case INSTPERC05:
					case INSTPERC06:
					case INSTPERC07:
					case INSTPERC08:
					case INSTPERC09:
					case INSTPERC10:
					case INSTPERC11:
					case INSTPERC12:
					case INSTPERC13:
					case INSTPERC14:
					case INSTPERC15:
					case INSTPERC16:
						{	reg int i = exit-INSTPERC01;
							if (def_channel_type[i]  == INSTRUMENT_CHANNEL)
								Set_InstOrPerc(i,PERCUSSION_CHANNEL);
							else
								Set_InstOrPerc(i,INSTRUMENT_CHANNEL);
							Redraw_DefList();
							wait_buttonup();	
							break;
						}
					
					case LCFG_BUT:
						ob_dostate(ex_info->di_tree,LCFG_BUT,SELECTED);
						ob_draw_chg(ex_info,LCFG_BUT,NULL,FAIL,FALSE);
						wait_buttonup();
						if (load_map() == TRUE)
						{	Redraw_InstList();
							Redraw_DefList();
						}						
						ob_undostate(ex_info->di_tree,LCFG_BUT,SELECTED);
						ob_draw_chg(ex_info,LCFG_BUT,NULL,FAIL,FALSE);						
						break;
					case SCFG_BUT:
						ob_dostate(ex_info->di_tree,SCFG_BUT,SELECTED);
						ob_draw_chg(ex_info,SCFG_BUT,NULL,FAIL,FALSE);
						wait_buttonup();
						if (save_map() == TRUE)
						{	Redraw_InstList();
							Redraw_DefList();
						}							
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
						close_dialog(ex_info,FALSE);
						break;
					case ABOUTMOREINFO:
					{	int msg[8];
						close_dialog(ex_info,FALSE);
						OpenDialog(&info_win,info_tree2,WIN_DIAL,NULL,FALSE);
					}
						break;
					case ABOUTCANCEL:
						close_dialog(ex_info,FALSE);
						break;
					case ABOUTCONTINUE:
						close_dialog(ex_info,FALSE);
						OpenDialog(&info_win,info_tree3,WIN_DIAL,NULL,FALSE);
						break;
					case ABOUTEND:
						close_dialog(ex_info,FALSE);
						break;								
				}
			} else if (ex_info == &chaninf_win)
			{	switch (exit)
				{
					case CHN_NOTEON:
						if (channels_info[selected_channel].noteon_ef == TRUE)
								SetChannel_NoteOn_Ef(FALSE);
							else
								SetChannel_NoteOn_Ef(TRUE);					
						break;
					case CHN_POLYPRES:
						if (channels_info[selected_channel].polypres_ef == TRUE)
								SetChannel_PolyPres_Ef(FALSE);
							else
								SetChannel_PolyPres_Ef(TRUE);					
						break;					
					case CHN_CONTROLLER:
						if (channels_info[selected_channel].controller_ef == TRUE)
								SetChannel_Controller_Ef(FALSE);
							else
								SetChannel_Controller_Ef(TRUE);					
						break;
					case CHN_PROGCHANGE:
						if (channels_info[selected_channel].progchange_ef == TRUE)
								SetChannel_ProgChange_Ef(FALSE);
							else
								SetChannel_ProgChange_Ef(TRUE);					
						break;					
					case CHN_AFTERTOUCH:
						if (channels_info[selected_channel].aftertouch_ef == TRUE)
								SetChannel_AfterTouch_Ef(FALSE);
							else
								SetChannel_AfterTouch_Ef(TRUE);					
						break;					
					case CHN_PITCHBEND:
						if (channels_info[selected_channel].pitchbend_ef == TRUE)
								SetChannel_PitchBend_Ef(FALSE);
							else
								SetChannel_PitchBend_Ef(TRUE);					
						break;				
				}
			} else if (ex_info == &patchmap_win)
			{	switch(exit)
				{	case PFMAP:
					{
						ob_dostate(ex_info->di_tree,PFMAP,SELECTED);
						ob_draw_chg(ex_info,PFMAP,NULL,FAIL,FALSE);
						wait_buttonup();
						ob_undostate(ex_info->di_tree,PFMAP,SELECTED);
						ob_draw_chg(ex_info,PFMAP,NULL,FAIL,FALSE);						
						strcpy(curr_selpname,strrchr(&gm_instrument_fnames[j][0],(int) '\\')+1);								
						if (select_file(selected_pat,&gm_instrument_fnames[j][0],curr_selpname,"*.PAT","Select .PAT file"))
						{	strcpy(selected_newpat,selected_pat);
							selected_good = TRUE;
						}
						break;
					}
					case PFOK:
					{	ob_dostate(ex_info->di_tree,PFOK,SELECTED);
						ob_draw_chg(ex_info,PFOK,NULL,FAIL,FALSE);
						wait_buttonup();
						ob_undostate(ex_info->di_tree,PFOK,SELECTED);
						ob_draw_chg(ex_info,PFOK,NULL,FAIL,FALSE);						
						close_dialog(ex_info,FALSE);
						if (selected_good == TRUE)
						{	strcpy(&gm_instrument_fnames[j][0],selected_newpat);
							Update_Instrument_Info_Box();
						}
						if (strcmp(&gm_instrument[viewinst_selected][0],(&patchmap_tree[PNAME])->ob_spec.tedinfo->te_ptext) != 0)
						{	strcpy(&gm_instrument[viewinst_selected][0],(&patchmap_tree[PNAME])->ob_spec.tedinfo->te_ptext);
							Redraw_InstList();
							Redraw_DefList();
						}
						selected_good = FALSE;
						break;
					}
					case PFCANCEL:
					{	ob_dostate(ex_info->di_tree,PFCANCEL,SELECTED);
						ob_draw_chg(ex_info,PFCANCEL,NULL,FAIL,FALSE);
						wait_buttonup();
						ob_undostate(ex_info->di_tree,PFCANCEL,SELECTED);
						ob_draw_chg(ex_info,PFCANCEL,NULL,FAIL,FALSE);						
						close_dialog(ex_info,FALSE);
						selected_good = FALSE;
						break;
					}
					
				}
			} else
				close_dialog(ex_info,FALSE);
		}
	}
	already_handling = FALSE;
	
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
	        dial_colors(7,(colors>=16) ? LWHITE : WHITE,GREEN,RED,MAGENTA,BLUE,CYAN,RED);

			dial_options(TRUE,TRUE,FALSE,TRUE,FAIL,TRUE,FALSE,FALSE,TRUE);
			title_options(FALSE,BLACK,FALSE);
			check_image(5,NULL);
			menu_install(menu,TRUE);
			wind_update(END_UPDATE);
	
			if (DSP_Init() == FALSE)
				ExitExample(1);
			graf_mouse(BUSYBEE,NULL);
			Init_InstPerc_Lists();
			set_player_status(NOSONG);
			if (do_load_map(MAP_NAME) == FALSE)
			{	xalert(1,1,X_ICN_ERROR,NULL,SYS_MODAL,BUTTONS_CENTERED,TRUE,title," Failed to load MAP File. ","[Exit");
				ExitExample(1);
			}
			if (do_load_cfg(CFG_NAME) == FALSE)
			{	xalert(1,1,X_ICN_ERROR,NULL,SYS_MODAL,BUTTONS_CENTERED,TRUE,title," Failed to load CFG File. ","[Exit");
				ExitExample(1);
			}
			Set_ViewingList(Current_View);
			Update_Main_Info_Bar();
			Update_Instrument_Info_Box();
			init_mastervol(master_vol);
			init_masterbal(master_bal);

			LoadDefListPatches();

			if (_app)
				OpenDialog(&instlist_win,instlist_tree,WIN_DIAL,sl_instlist_list,TRUE);

			Event_Multi(NULL);	
		}
	}
}

	

