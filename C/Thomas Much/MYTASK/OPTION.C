#include "start.h"

/*#include <aes.h>
#include <vdi.h>*/
#include <tos.h>
#include <av.h>
#include <portab.h>
#include <string.h>
#include <stddef.h>
#include <stdlib.h>
#include <ctype.h>
#include <stdio.h>
#include <time.h>
#include <mytask.h>
#include "sounds.h"
#include "global.h"
#include "option.h"
#include "memdebug.h"

struct _options options;

OBJECT *lang_pop;
char *languages_text[] = {
"  Polnisch     ",
"  Deutsch      ",
"  Englisch     ",
"  Franz™sisch  ",
"  Swedisch     ",
"  Norwegisch   "};

int window_handlers[100];
short wx,wy,wh,ww;
int       system_,
            menu_id,
            ap_id,
            colors,
            extmagxmenu,
            helpid,
            avserver,
            gsapp,
            appline,
            applinepos,
            wmclosed,
            btnidx,
/*            extrsc,	*/
            broadcast,
            dobroadcast,
            shuttimeout,
            docmax,
            docmaxperapp,
            nowindow,
            applications,
            cpx,
            appmax,
            desktop,
            apterm,
            untop,
            quit,
            hidden,
            show_all_app, 
            transparent;
int language;
int deskcol;


void free_alias(void)
	{
	int i;
	if(alias_name==NULL)
		return;
	for(i=0; i<alias_name->no; i++)
		{
		if(alias_name[i].name)
			free(alias_name[i].name);
		if(alias_name[i].alias)
			free(alias_name[i].alias);
		}
	free(alias_name);
	}

void Load_options(void)
	{
	int ret, handle, i, n;
	char inf[1000]={0}, version[4]={0};
	STARTINF    si;

	strcpy(inf,home);
	strcat(inf,"defaults\\MyTask.inf");
	ret=(int)Fopen(inf,FO_READ);
	startinf.font_height = 15;

	if (ret<0L)
		{
		strcpy(inf,home);
		strcat(inf,"MyTask.inf");
		ret=(int)Fopen(inf,FO_READ);
		}	
	
	if (ret>=0L)
		{
		Fattrib(inf, 1, 0);
		handle = (int)ret;

		Fread(handle, 4, &version[0]);
		if(atoi(version)==atoi(INF_VERSION))
			{
			if (Fread(handle,sizeof(STARTINF),&si)==sizeof(STARTINF))
				{
				if (si.version==INFVER)
					startinf=si;
				}
			if (Fread(handle,sizeof(struct _options),&options)!=sizeof(struct _options))
				mt_form_alert(1, message[MSG_CNF_ERROR], (short*)&_GemParBlk.global[0]);

			read_texts();

/*			{
			int i, max=0;
			for(i=0; apppopup[i].ob_next!=0; i++)
				{
				if(apppopup[i].ob_width > max)
					max = apppopup[i].ob_width;
				}
			for(i=0; apppopup[i].ob_next!=0; i++)
				apppopup[i].ob_width = max;
			}
*/
			if(options.language>5)
				options.language = 1;

			Fread(handle, 2, &n);
			if(n!=0)
				{
				if(DoNotShow)
					{
					char tmp[10];
					for(i=0; i<n; i++)
						{
						Fread(handle, 9, tmp);
						Add_app_to_not_show(-1, tmp);
						}
					}
				else
					{
					DoNotShow = calloc(1,n*sizeof(struct _donotshow));
					DoNotShow->how_many = n;
					for(i=0; i<n; i++)
						Fread(handle, 9, DoNotShow[i].name);
					}
				}
			Fread(handle, 2, &n);
			if(n!=0)
				{
				FontsID = calloc(1,n*sizeof(struct _font_id_app));
				memset(FontsID, 0, n*sizeof(struct _font_id_app));
				FontsID->how_many = n;
				for(i=0; i<n; i++)
					{
					Fread(handle, 9, FontsID[i].name);
					Fread(handle, 2, &FontsID[i].id);
					Fread(handle, 2, &FontsID[i].color);
					Fread(handle, 2, &FontsID[i].effect);
					Fread(handle, 2, &FontsID[i].height);
					}
				}

			Fread(handle, 2, &n);
			if(n!=0)
				{
				alias_name = calloc(1,(n+1)*sizeof(struct _alias));
				memset(alias_name, 0, (n+1)*sizeof(struct _alias));
				alias_name->no = n;
				for(i=0; i<alias_name->no; i++)
					{
					Fread(handle, 2, &n);
					alias_name[i].name = calloc(1,n+1L);		memset(alias_name[i].name, 0, n+1);
					Fread(handle, n, alias_name[i].name);
					Fread(handle, 2, &n);
					alias_name[i].alias = calloc(1,n+1L);		memset(alias_name[i].alias, 0, n+1);
					Fread(handle, n, alias_name[i].alias);
					}
				}
			}
		else
			{
			Fclose(handle);
			mt_form_alert(1, message[MSG_ALT_KONF], (short*)&_GemParBlk.global[0]);
			if(Fdelete(inf)!=0)
				{
				Fattrib(inf, 1, 0);
				if(Fdelete(inf)!=0)
					mt_form_alert(1, message[MSG_FILE_PROBLEMS], (short*)&_GemParBlk.global[0]);
				}
			}
		Fclose(handle);
		}
	build_lang_popup();
	if(options.language>5)
		options.language = 1;
	}



void Save_options(void)
	{
	int ret, handle, i, n;
	char inf[1000]={0};


	if (startinf.workxabs <= desk.g_x)
		startinf.workxabs = -2000;
	if (startinf.workxabs+bigbutton[ROOT].ob_width >= desk.g_x+desk.g_w)
		startinf.workxabs = 30000;

	if (startinf.workyabs <= desk.g_y)
		startinf.workyabs = -2000;
	if (startinf.workyabs+bigbutton[ROOT].ob_height >= desk.g_y+desk.g_h)
		startinf.workyabs = 30000;
	
	strcpy(inf,home);
	strcat(inf,"defaults\\MyTask.inf");
	ret=(int)Fcreate(inf,0);

	if (ret<0L)
		{
		strcpy(inf,home);
		strcat(inf,"MyTask.inf");
		ret=(int)Fcreate(inf,0);
		}

	if (ret<0L)
		return;

	Fattrib(inf, 1, 0);
	handle = (int)ret;
	Fwrite(handle, 4, INF_VERSION);
	Fwrite(handle,sizeof(STARTINF),&startinf);
	Fwrite(handle,sizeof(struct _options),&options);

	n=0;
	if(DoNotShow)
		{
		n = DoNotShow->how_many;
		Fwrite(handle, 2, &n);
		for(i=0; i<n; i++)
			Fwrite(handle, 9, DoNotShow[i].name);
		}
	else
		Fwrite(handle, 2, &n);

	n = 0;
	if(FontsID)
		{
		n = FontsID->how_many;
		Fwrite(handle, 2, &n);
		for(i=0; i<n; i++)
			{
			Fwrite(handle, 9, FontsID[i].name);
			Fwrite(handle, 2, &FontsID[i].id);
			Fwrite(handle, 2, &FontsID[i].color);
			Fwrite(handle, 2, &FontsID[i].effect);
			Fwrite(handle, 2, &FontsID[i].height);
			}
		}
	else
		Fwrite(handle, 2, &n);


	n = 0;
	if(alias_name)
		{
		n = alias_name->no;
		Fwrite(handle, 2, &n);
		for(i=0; i<alias_name->no; i++)
			{
			n = (int)strlen(alias_name[i].name);
			Fwrite(handle, 2, &n);
			Fwrite(handle, n, alias_name[i].name);
			n = (int)strlen(alias_name[i].alias);
			Fwrite(handle, 2, &n);
			Fwrite(handle, n, alias_name[i].alias);
			}
		}
	else
		Fwrite(handle, 2, &n);
	
	Fclose(handle);

	}

void Default_options(void)
	{
	system_ = 0;
	language = ENGLISH;
	MyTask.whandle = 0;
	menu_id = -1;
	colors = 0;
	extmagxmenu = 0;
	helpid = -1;
	avserver = -1;
	gsapp = -1;
	appline = -1;
	applinepos = 0;
	wmclosed = 0;
	btnidx = START_BUTTON;
/*	extrsc = 0;	*/
	dobroadcast = 1;
	shuttimeout = 2000;
	docmax = 15;
	docmaxperapp = 5;
	nowindow = 0;
	applications = 0;
	appmax = 10;
	desktop = 0;
	apterm = 0;
	untop = 0;
	quit = 0;
	hidden = 0;

	options.savelinks = 1;
	options.noquitalert = 1;
	options.drives = 1;
	options.documents = 1;
	options.autotop = 2;
	options.language = GERMAN;			/* German				*/

	options.col_app = G_BLACK;
	options.col_acc = G_BLUE;
	options.col_sys = G_RED;
	options.col_shell = G_YELLOW;
	options.col_b_app = G_LWHITE;
	options.col_b_acc = G_LWHITE;
	options.col_b_sys = G_LWHITE;
	options.col_b_shell = G_LWHITE;
	options.col_caps_on = G_GREEN;
	options.col_caps_off = G_LWHITE;
	options.col_t_caps_on = G_BLACK;
	options.col_t_caps_off = G_BLACK;
	options.tex_app = 1;
	options.tex_acc = 1;
	options.tex_sys = 1;
	options.tex_shell = 1;
	options.tex_caps_on = 1;
	options.tex_caps_off = 1;
	options.loop_time = 1000;
	options.html_separat = 1;

	options.frezzy_effect = 0;
	options.frezzy_txt_color = G_LBLACK;
	options.frezzy_back_color = G_LWHITE;
	options.hidden_effect = 3;
	options.hidden_txt_color = G_LBLACK;
	options.hidden_back_color = G_LWHITE;
	options.acc_in_system_tray = 0;

	options.fenster_name_mit_handler = 1;

	options.start_rsc_obj = 1;		/* Obiekt nr 1 z pliku RSC	*/
	options.start_icon_text = 0;	/* Nie pokazuje tekstu ikonki w przycisku START	*/
	options.app_rsc_obj = -1;			/* Obiekt nr 1 z pliku RSC	*/
	options.app_icon_text = 1;		/* Nie pokazuje tekstu ikonki w przycisku START	*/

	options.stic = 1;
	options.stic_app_button = 1;
	MyTask.actual_app_on_top = MyTask.actual_menu_on_top = -2;

	options.draw_obj = 0;

	strcpy(options.time_mode_1, "%t  %D");
	strcpy(options.time_mode_2, "%t");
	strcpy(options.name, "MyTask");
	memset(options.myconf_path, 0, 1000);

	{
	int i;
	for(i=0; i<4; i++)
		{
		options.klicks[i][1] = DEF_BUTT_MENU;
		options.klicks[i][2] = DEF_BUTT_SHOW;
		}

	for(i=0; i<4; i++)
		{
		options.doppel_klicks[i][1] = DEF_BUTT_ICON;
		options.doppel_klicks[i][2] = DEF_BUTT_FREEZY;
		}
	}
	

	memset(options.doppelklick_time_path, 0, 1000);
	}



char com[100]={0};

void Set_options(int mx, int my)
	{
	int r, app_no;

	r = mt_appl_find("MYCONF  ", (short*)&_GemParBlk.global[0]);

	if(r!=-1)
		{
		app_no = find_app_by_id(r);
		if(app_no!=-1)
			{
			int com1, com2;
			sprintf(com, " m %Ld %d %Ld %s %d", (unsigned long)&options, (int)DoNotShow->how_many, (unsigned long)DoNotShow, INF_VERSION, ap_id);
			mt_wind_set(_applications_[app_no].window_handlers[0],WF_TOP,0,0,0,0, (short*)&_GemParBlk.global[0]);
			com1=(int)(((long)com >> 16) & 0x0000ffffL);
			com2=(int)((long)com & 0x0000ffffL);
			SendAV(r, MYTASK_SEND_OPTIONS, ap_id, com1, com2, 0, 0, 0, 0);
			}
		}
	else
		{
		if(DoNotShow)
			sprintf(com, " m %Ld %d %Ld %s %d", (unsigned long)&options, (int)DoNotShow->how_many, (unsigned long)DoNotShow, INF_VERSION, ap_id);
		else
			sprintf(com, " m %Ld 0 0 %s %d", (unsigned long)&options, INF_VERSION, ap_id);

		if(strlen(options.myconf_path)>1 && (strstr(options.myconf_path, "MYCONF.APP")!=NULL || strstr(options.myconf_path, "myconf.app")!=NULL))
			start_app(0,SHW_PARALLEL, "MyConf", options.myconf_path, com);
		else
			{
			char file[128],*c;
			short  btn=1;
				
			strcpy(options.myconf_path, "*.*");
			strcpy(file,"MYCONF.APP");

			if (mt_fsel_exinput(options.myconf_path, file, &btn, fseltitle, (short*)&_GemParBlk.global[0]))
				{
				if (btn==1)
					{
					if (strlen(file))
						{
						c=strrchr(options.myconf_path,'\\');
						if (c) *(++c) = 0;
							
						strcat(options.myconf_path,file);
						}
					}
				}
			Save_options();
			start_app(0, SHW_PARALLEL, "MyConf", options.myconf_path, com);
			}
		}
	}


void free_lang_pop(void)
	{
	if(lang_pop)
		{
		int i;
		for(i=0; i<(lang_pop->ob_tail+1); i++)
			{
			if(lang_pop[i].ob_type==G_FTEXT || lang_pop[i].ob_type==G_TEXT || lang_pop[i].ob_type==G_BOXTEXT || lang_pop[i].ob_type==G_STRING || lang_pop[i].ob_type==G_FBOXTEXT)
				{
				if(lang_pop[i].ob_spec.free_string)
					free(lang_pop[i].ob_spec.free_string);
				}
			}
		free(lang_pop);
		}
	}

void build_lang_popup(void)
	{
	int how_many=7, f_h=0, lmax=1, c=1;
	int languages=2;			/* German is always there!!	*/

	lang_pop = (OBJECT *)calloc(1,sizeof(OBJECT)*(long)(how_many+1));
	memset(lang_pop, 0, sizeof(OBJECT)*(long)(how_many+1));

	for (c=0; c<6; c++)
		lmax = (int)max(lmax, strlen(languages_text[c]));

	c=1;
	lang_pop->ob_next   = -1;
	lang_pop->ob_head   =  1;
	lang_pop->ob_tail   = 1;
	lang_pop->ob_type   = G_BOX;
	lang_pop->ob_flags  = FL3DBAK;
	lang_pop->ob_state  = OS_NORMAL;
	lang_pop->ob_spec.index = 0x00ff1100L;
	lang_pop->ob_x      =  0;
	lang_pop->ob_y      =  0;
	lang_pop->ob_width  = (int)lmax-1;
	lang_pop->ob_height = 0;

	if((f_h = open("polish.lan", O_RDONLY))>0)
		{
		languages |= 1;
		how_many++;
		close(f_h);

		lang_pop[c].ob_spec.free_string = (char *)calloc(1,lmax+2L);
		memset(lang_pop[c].ob_spec.free_string, 0, lmax+1);
		if (lang_pop[c].ob_spec.free_string)
			strcpy(lang_pop[c].ob_spec.free_string, languages_text[0]);
		lang_pop->ob_height++;
		lang_pop[c].ob_next   = c+1;
		lang_pop[c].ob_head   = -1;
		lang_pop[c].ob_tail   = -1;
		lang_pop[c].ob_type   = G_STRING;
		lang_pop[c].ob_flags  = FL3DBAK|OF_SELECTABLE;
		lang_pop[c].ob_state  = OS_NORMAL;
		lang_pop[c].ob_x      =  0;
		lang_pop[c].ob_y      = c-1;
		lang_pop[c].ob_width  = (int)lmax-1;
		lang_pop[c++].ob_height =  1;
		lang_pop->ob_tail++;
		}

		lang_pop[c].ob_spec.free_string = (char *)calloc(1,lmax+2L);
		memset(lang_pop[c].ob_spec.free_string, 0, lmax+1);
		if (lang_pop[c].ob_spec.free_string)
			strcpy(lang_pop[c].ob_spec.free_string, languages_text[1]);
		lang_pop->ob_height++;
		lang_pop[c].ob_next   = c+1;
		lang_pop[c].ob_head   = -1;
		lang_pop[c].ob_tail   = -1;
		lang_pop[c].ob_type   = G_STRING;
		lang_pop[c].ob_flags  = FL3DBAK|OF_SELECTABLE;
		lang_pop[c].ob_state  = OS_NORMAL;
		lang_pop[c].ob_x      =  0;
		lang_pop[c].ob_y      = c-1;
		lang_pop[c].ob_width  = (int)lmax-1;
		lang_pop[c++].ob_height =  1;
		lang_pop->ob_tail++;

	if((f_h = open("english.lan", O_RDONLY))>0)
		{
		languages |= 4;
		how_many++;
		close(f_h);

		lang_pop[c].ob_spec.free_string = (char *)calloc(1,lmax+2L);
		memset(lang_pop[c].ob_spec.free_string, 0, lmax+1);
		if (lang_pop[c].ob_spec.free_string)
			strcpy(lang_pop[c].ob_spec.free_string, languages_text[2]);
		lang_pop->ob_height++;
		lang_pop[c].ob_next   = c+1;
		lang_pop[c].ob_head   = -1;
		lang_pop[c].ob_tail   = -1;
		lang_pop[c].ob_type   = G_STRING;
		lang_pop[c].ob_flags  = FL3DBAK|OF_SELECTABLE;
		lang_pop[c].ob_state  = OS_NORMAL;
		lang_pop[c].ob_x      =  0;
		lang_pop[c].ob_y      = c-1;
		lang_pop[c].ob_width  = (int)lmax-1;
		lang_pop[c++].ob_height =  1;
		lang_pop->ob_tail++;
		}
	if((f_h = open("french.lan", O_RDONLY))>0)
		{
		languages |= 8;
		how_many++;
		close(f_h);

		lang_pop[c].ob_spec.free_string = (char *)calloc(1,lmax+2L);
		memset(lang_pop[c].ob_spec.free_string, 0, lmax+1);
		if (lang_pop[c].ob_spec.free_string)
			strcpy(lang_pop[c].ob_spec.free_string, languages_text[3]);
		lang_pop->ob_height++;
		lang_pop[c].ob_next   = c+1;
		lang_pop[c].ob_head   = -1;
		lang_pop[c].ob_tail   = -1;
		lang_pop[c].ob_type   = G_STRING;
		lang_pop[c].ob_flags  = FL3DBAK|OF_SELECTABLE;
		lang_pop[c].ob_state  = OS_NORMAL;
		lang_pop[c].ob_x      =  0;
		lang_pop[c].ob_y      = c-1;
		lang_pop[c].ob_width  = (int)lmax-1;
		lang_pop[c++].ob_height =  1;
		lang_pop->ob_tail++;
		}
	if((f_h = open("swedish.lan", O_RDONLY))>0)
		{
		languages |= 16;
		how_many++;
		close(f_h);

		lang_pop[c].ob_spec.free_string = (char *)calloc(1,lmax+2L);
		memset(lang_pop[c].ob_spec.free_string, 0, lmax+1);
		if (lang_pop[c].ob_spec.free_string)
			strcpy(lang_pop[c].ob_spec.free_string, languages_text[4]);
		lang_pop->ob_height++;
		lang_pop[c].ob_next   = c+1;
		lang_pop[c].ob_head   = -1;
		lang_pop[c].ob_tail   = -1;
		lang_pop[c].ob_type   = G_STRING;
		lang_pop[c].ob_flags  = FL3DBAK|OF_SELECTABLE;
		lang_pop[c].ob_state  = OS_NORMAL;
		lang_pop[c].ob_x      =  0;
		lang_pop[c].ob_y      = c-1;
		lang_pop[c].ob_width  = (int)lmax-1;
		lang_pop[c++].ob_height =  1;
		lang_pop->ob_tail++;
		}
	if((f_h = open("norweg.lan", O_RDONLY))>0)
		{
		languages |= 32;
		how_many++;
		close(f_h);

		lang_pop[c].ob_spec.free_string = (char *)calloc(1,lmax+2L);
		memset(lang_pop[c].ob_spec.free_string, 0, lmax+1);
		if (lang_pop[c].ob_spec.free_string)
			strcpy(lang_pop[c].ob_spec.free_string, languages_text[5]);
		lang_pop->ob_height++;
		lang_pop[c].ob_next   = c+1;
		lang_pop[c].ob_head   = -1;
		lang_pop[c].ob_tail   = -1;
		lang_pop[c].ob_type   = G_STRING;
		lang_pop[c].ob_flags  = FL3DBAK|OF_SELECTABLE;
		lang_pop[c].ob_state  = OS_NORMAL;
		lang_pop[c].ob_x      =  0;
		lang_pop[c].ob_y      = c-1;
		lang_pop[c].ob_width  = (int)lmax-1;
		lang_pop[c++].ob_height =  1;
		lang_pop->ob_tail++;
		}

	lang_pop[--c].ob_next = 0;
	lang_pop[c].ob_flags |= OF_LASTOB;
	lang_pop->ob_tail--;
	fix_tree(lang_pop);
	}