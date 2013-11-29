#include "extern.h"
#include "global.h"
#include "dialogs.h"

extern int ug_ask;

/* ---------------------------- */
/* | Virtuelle Arbeitsstation | */
/* ---------------------------- */
void open_vwork(void)
{
register int i;
int dummy;

vdi_handle = graf_handle(&dummy, &dummy, &chr_wdth, &chr_hght);

for(i = 0; i < 10; work_in[i++] = 1);
work_in[10] = 2;

v_opnvwk(work_in, &vdi_handle, work_out);
}

/* -----------------------------
   | Menu entry enable/disable |
   ----------------------------- */
void set_options(void)
{
int i;

i = search_topsw();
if (i == -1)
	{
	i = 0;
	menu_ienable(menu_adr, DOSTATIS, 0);
	}
else
	{
	if (!statis_active)
		menu_ienable(menu_adr, DOSTATIS, 1);
	else
		menu_ienable(menu_adr, DOSTATIS, 0);

	if (flt_active == i)
		i = 0;
	else
		i = 1;
	}
	
menu_ienable(menu_adr, SMPSAVE, i);
menu_ienable(menu_adr, SAVE_AVR, i);

menu_ienable(menu_adr, CHGLOUD, i);
menu_ienable(menu_adr, DOOVSM, i);
menu_ienable(menu_adr, DOPACK, i);
menu_ienable(menu_adr, DOINVERT, i);
menu_ienable(menu_adr, DOPLAY, i);

if ((flt_ovsm || flt_bad || flt_pitch || flt_slice) && flt_active == -1)
	menu_ienable(menu_adr, DOFILT, i);
else
	menu_ienable(menu_adr, DOFILT, 0);
}

/* ---------------------------
	 | Menu point was selected |
	 --------------------------- */
int menu_action(void)
{
int m_title = msg[3];

switch(msg[4])
	{
  case WHATABOU:
		new_dialog(&about_dia);
  	break;

	case SMPLOAD:
		load_sample();
		break;
		
	case SMPSAVE:
		save_sample();
		break;

	case SAVE_AVR:
		save_avr();
		break;

	case DODIR:
		break;

	case DOSTATIS:
		sample_statistik();
		break;

	case CHGLOUD:
		change_volume();
		break;

	case DOFILT:
		filter();
		break;

	case DOOVSM:
		do_oversam();
		break;

	case DOPACK:
		kompakt(1);
		break;

	case DOINVERT:
		sample_convert();
		break;

	case DOPLAY:
		play_one();
		break;
		  	
	case PRGEXIT:
		return 1;

	case MN_ENV:
		new_dialog(&env_dia);
		break;
				
	case SETFILT:
		new_dialog(&fltopt_dia);
		break;
		
	case SETOVSM:
		new_dialog(&ovsmopt_dia);
		break;
		
	case SETPACK:
		new_dialog(&packopt_dia);
		break;

	case SETPLAY:
		new_dialog(&playopt_dia);
		break;
	
	case SETMWIRE:
		new_dialog(&setmw_dia);
		break;
		
	case SAVEOPT:
		save_options();
		break;
		
	case MBOARD:
		new_dialog(&mboard_dia);
		break;
	}

menu_tnormal(menu_adr, m_title, 1);
return 0;
}

/* ---------------------------
	 | Menu point was selected |
	 --------------------------- */
int action_key(int kr, int *ex)
{
int w_zw;

switch(kr)
	{
  case 0x1709:								/* ^I */
		new_dialog(&about_dia);
  	return 1;

	case 0x260c:								/* ^L */
		load_sample();
  	return 1;

	case 0x180F:								/* ^O */
		new_dialog(&mboard_dia);
		break;
		
	case 0x1f13:								/* ^S */
		save_sample();
  	return 1;

	case 0x1E01:								/* ^A */
		save_sample();
  	return 1;
  	
  case 0x1615:								/* ^U */
		wind_get(0, WF_TOP, &w_zw);
		if (w_zw)
			{
			if (dialog_close(w_zw))
				{
				wind_close(w_zw);
				wind_delete(w_zw);
				}
			else
				if (sample_close(w_zw))
					{
					wind_close(w_zw);
					wind_delete(w_zw);
					}
			set_options();
			}
  	return 1;

	case DODIR:									/* ^D */
  	return 1;

	case 0x1F00:						 		/* @S */
		if (!(menu_adr[DOSTATIS].ob_state & DISABLED))
			sample_statistik();
  	return 1;

	case 0x2600:								/* @L */
		change_volume();
  	return 1;

	case 0x2100:								/* @F */
		if (!(menu_adr[DOFILT].ob_state & DISABLED))
			filter();
  	return 1;

	case 0x1800:								/* @O */
		do_oversam();
  	return 1;

	case 0x1900:								/* @P */
		kompakt(1);
  	return 1;

	case 0x1700:								/* @I */
		sample_convert();
  	return 1;

	case 0x1E00:								/* @A */
		play_one();
  	return 1;
		  	
	case 0x1011:								/* ^Q */
		*ex = 1;
		return 1;
		
	case 0x211:								/* ^1 */
		new_dialog(&fltopt_dia);
  	return 1;
		
	case 0x300:								/* ^2 */
		new_dialog(&ovsmopt_dia);
  	return 1;
		
	case 0x413:								/* ^3 */
		new_dialog(&packopt_dia);
  	return 1;

	case 0x514:								/* ^4 */
		new_dialog(&playopt_dia);
  	return 1;

	case 0x1117:							/* ^M */
		new_dialog(&setmw_dia);
		break;
		
	case 0xB10:								/* ^0 */
		save_options();
  	return 1;
	}

return 0;
}

/* -------------------
   | Event listening |
   ------------------- */
int check_action(void)
{
int ex = 0;
int x, y, w, h;
int x1, y1, w1, h1;

which = evnt_multi(ev_action,
									 2, 1, 1,
									 0, 0, 0, 0, 0,
									 0, 0, 0, 0, 0,
									 msg,
									 75, 0,
									 &mx, &my, &mb, &ks, &kr, &br);

if (which & MU_TIMER)
	do_task();

if (which & MU_MESAG)
	switch(msg[0])
		{
		case MN_SELECTED:
			menu_bar(menu_adr, 0);
			ex = menu_action();
			menu_bar(menu_adr, 1);
			break;
	
		case WM_REDRAW:
			dialog_redraw(msg[3], ROOT, msg[4], msg[5], msg[6], msg[7]);
			sample_redraw(msg[3], msg[4], msg[5], msg[6], msg[7]);
			set_options();
			break;
	
		case WM_SIZED:
			wind_set(msg[3], WF_CURRXYWH, msg[4], msg[5], msg[6], msg[7]);
			form_dial(FMD_FINISH, 0, 0, 0, 0, msg[4], msg[5], msg[6], msg[7]);						
			break;

		case WM_FULLED:
			wind_get(msg[3], WF_CURRXYWH, &x1, &y1, &w1, &h1);
			wind_get(msg[3], WF_FULLXYWH, &x, &y, &w, &h);
			if (x == x1 && y == y1 && w == w1 && h == h1)
				wind_get(msg[3], WF_PREVXYWH, &x, &y, &w, &h);
				
			wind_set(msg[3], WF_CURRXYWH, x, y, w, h);
			form_dial(FMD_FINISH, 0, 0, 0, 0, x, y, w, h);						
			break;
			
		case WM_MOVED:
			dialog_move(msg[3], BEG_UPDATE);
			wind_set(msg[3], WF_CURRXYWH, msg[4], msg[5], msg[6], msg[7]);
			dialog_move(msg[3], END_UPDATE);
			break;

		case WM_CLOSED:
			if (dialog_close(msg[3]))
				{
				wind_close(msg[3]);
				wind_delete(msg[3]);
				}
			else
				if (sample_close(msg[3]))
					{
					wind_close(msg[3]);
					wind_delete(msg[3]);
					}
			set_options();
			break;
	
		case WM_TOPPED:
		case WM_NEWTOP:
			if (exclusive_wind)
				wind_set(exclusive_wind, WF_TOP);
			else
				{
				wind_set(msg[3], WF_TOP);
				set_options();
				}
			break;
 		}

if ((which & MU_BUTTON) && mb == 1)
  if (wind_find(mx, my))
		dialog_button();
	else
		if (br >= 1)
			{
			icon_use();
			set_options();
			}
		
if (which & MU_KEYBD)
 	if ((char)kr == 13)
  	dialog_default();
  else
  	if (!action_key(kr, &ex))
	  	dialog_edit(kr);
	  		
return ex;
}

/* -------------
	 | Main part |
	 ------------- */
void main(int argc, char *argv[])
{
int ex = 0, i;

appl_init();
open_vwork();

graf_mouse(HOURGLASS, 0L);

if (!rsrc_load("DSPROG.RSC"))
	exit(0);
	
rsrc_gaddr(R_TREE, MENUE, &menu_adr);
init_rsrc();
init_icons();
initialize();

cookie_chk();
menu_bar(menu_adr, 1);
set_options();

graf_mouse(ARROW, 0L);

path[0] = Dgetdrv() + 'A';
path[1] = ':';
Dgetpath(path + 2, 0);
strcat(path + 2, "\\*.*");
file[0] = 0;

load_sinus();
load_options();
check_play();
init_mwdia();

for (i = 1; i < argc; i++)
	{
	ug_ask = 1;
	load_in_sample(argv[i]);
	ug_ask = 0;
	}
	
do
	{
  ex = check_action();			
	}while(!ex);

wind_set(0, WF_NEWDESK, 0L, ROOT);
v_clsvwk(vdi_handle);
appl_exit();
}
