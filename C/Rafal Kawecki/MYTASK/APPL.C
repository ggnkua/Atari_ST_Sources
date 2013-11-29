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
#include <ext.h>
#include <mytask.h>
#include <mt_gem.h>
#include "sounds.h"
#include "global.h"
#include "option.h"
#include "memdebug.h"


/* **********************************
1. krok:
 ustawienie czasu / pamieci
 znalezienie aktualnie dzialajacych aplikacji
 przygotowanie przyciskow
 przygotowanie ikonek (system tray)
 przygotowanie ikonek (app tray)
2. krok:
 ew. zmiana czasu / pamieci (ew. przerysowanie)
 szukanie _nowych_ aplikacji:
 				- przygotowanie przyciskow aplikacji, ew. przerysowanie
 czy jest mniej aplikacji:
 				- przygotowanie nowych przyciskow aplikacji, ew. przerysowanie
3. krok:
 nowa ikonka (system tray, app tray):
 	
 				- dodanie ikonki do tray, przerysowanie
	********************************** */
 				
/*
short	mt_wind_get 	(short WindowHandle, short What, short *W1, short *W2, short *W3, short *W4, short *global_aes);*/

extern int screen_manager_id;
extern char text_time_line1[50], text_time_line2[50];

static int tylko_lista;

struct _acc acc[10];
int no_acc, how_many_acc;

int delete_window_to_app(int app, int wh)
	{
	int i=0;
	for(i=0; i<_applications_[app].no_windows; i++)
		{
		if(_applications_[app].window_handlers[i]==wh)			/* Najpierw szukamy okienka z odpowiednim handlerem	*/
			break;
		}
	_applications_[app].window_handlers[i] = 0;
	if(_applications_[app].no_windows>i)
		{
		for(; i<_applications_[app].no_windows; i++)				/* Teraz przesuwamy nazwy wszystkich "nastepnych" okienek w "dol"	*/
			memcpy(&_applications_[app].window_name[i], &_applications_[app].window_name[i+1], 128);
		memset(_applications_[app].window_name[_applications_[app].no_windows], 0, 128);		/* Zerowanie nazwy ostatniego nie uzywanego juz okienka	*/
		memcpy(&_applications_[app].window_handlers[i], &_applications_[app].window_handlers[i+1], sizeof(int)*(_applications_[app].no_windows-i));	/* Przesuniecie handlerow okienek */
		}
	_applications_[app].no_windows--;
	return(_applications_[app].no_windows);	
	}


int add_window_to_app(int app, int h, char *name)
	{
	short wid=0,wid1,wid2,wid3;
	mt_wind_get(h, WF_KIND, &wid, &wid1,&wid2,&wid3, (short*)&_GemParBlk.global[0]);

	wid &= ~NAME;
	wid &= ~MOVER;
	if(wid==0 || _applications_==NULL || h==0 || name==NULL)
		return(-1);
	if(strlen(name)<1)			/* h=0 - desktop	*/
		return(-1);
	_applications_[app].window_handlers[_applications_[app].no_windows] = h;
	memset(_applications_[app].window_name[_applications_[app].no_windows], 0 ,128);
	if(options.fenster_name_mit_handler==1)
		{
		itoa(h, _applications_[app].window_name[_applications_[app].no_windows], 10);
		strcat(	_applications_[app].window_name[_applications_[app].no_windows], "-> ");
		}
	else
		strcat(	_applications_[app].window_name[_applications_[app].no_windows], "  ");
	strcat(	_applications_[app].window_name[_applications_[app].no_windows], name);
	_applications_[app].no_windows ++;

	return(_applications_[app].no_windows);	
	}

int find_app_by_window(int h)
	{
	int i, j;

	if(_applications_==NULL)
		return(-1);
	for(i=0; i<_applications_->no; i++)
		{
		for(j=0; j<_applications_[i].no_windows; j++)
			{
			if(_applications_[i].window_handlers[j]==h)
				return(i);
			}
		}
	return(-1);
	}

int find_app_by_icon_no(int icon)
	{
	int i, j;

	if(_applications_==NULL)
		return(-1);

	for(i=0; i<_applications_->no; i++)
		{
		for(j=0; j<_applications_[i].il_ikonek; j++)
			{
			if(_applications_[i].ikonki)
				{
				if(_applications_[i].ikonki[j].icon_no==icon)
					return(i);
				}
			}
		}
	return(APPLICATION_1);
	}

int find_icon_no_by_app(int icon, int app)
	{
	int i;

	if(app<0)
		return(-1);
	if(_applications_==NULL)
		return(-1);

	for(i=0; i<_applications_[app].il_ikonek; i++)
		{
		if(_applications_[app].ikonki[i].icon_no==icon)
			return(i);
		}
	return(-1);
	}

int find_app_by_button_no(int button)
	{
	int i;

	for(i=0; i<_applications_->no; i++)
		{
		if(_applications_[i].button_no==button)
			return(i);
		}
	return(APPLICATION_1);
	}



/* **********************************	*/
/* find_app_by_id											*/
/* n - if the application is saved		*/
/* -1 - if it's a new application			*/

int find_app_by_id(int id)
	{
	int i=0;
	if(_applications_==NULL)
		return(-1);
	if(_applications_->no==0)
		return(-1);
	while(i<_applications_->no)
		{
		if(_applications_[i].id==id)		/* && id!=0 && i!=0)*/
			return(i);
		else
			i++;
		}
	return(-1);
	}

int find_app_by_button(int obj, int mx)
	{
	int i=0;

	if(_applications_==NULL)
		return(-1);

	while(i<_applications_->no)
		{
		if(obj!=0)
			{
			if(bigbutton[obj].ob_type == G_CICON)
				{
				int j;
				for(j=0; j<_applications_[i].il_ikonek; j++)
					{
					if(_applications_[i].ikonki[j].icon_no == obj)
						return(i);
					}
				}
			else if(bigbutton[obj].ob_type == G_BOXTEXT || bigbutton[obj].ob_type == G_USERDEF)
				{
				if(_applications_[i].button_no == obj && _applications_[i].show_button!=0)
					return(i);
				}
			}
		else if(mx!=-1)
			{
			if(_applications_[i].pos_x<mx && mx<(_applications_[i].pos_x+_applications_[i].width) && _applications_[i].show_button!=0)
				return(i);
			}
		i++;
		}
	return(-1);
	}



int find_app_font(char *name)
	{
	int i;
	if(FontsID)
		{
		for(i=0; i<FontsID->how_many; i++)
			{
			if(stricmp(name, FontsID[i].name)==0)
				return(i);
			}
		}
	return(-1);
	}

int find_app_to_not_show(char *name)
	{
	int i;
	if(DoNotShow)
		{
		for(i=0; i<DoNotShow->how_many; i++)
			{
			if(strcmp(name, DoNotShow[i].name)==0)
				return(1);
			}
		}
	return(0);
	}



void _add_app(char *_name, int id, int pid, int type)
	{
	int i, font_appl;
	char name[36]={0};
	DTA *dta;
	struct _applications *app=NULL;
DEBUG
	if(_applications_==NULL)
		{
DEBUG
		_applications_ = calloc(1,sizeof(struct _applications));
		_applications_->no = 1;
		app = _applications_;
		}
	else
		{
		struct _applications *tmp=NULL;
		int j=0;

		for(i=0; i<_applications_->no; i++)
			{
			if(_applications_[i].id==-1 && _applications_[i].pid==-1 && _applications_[i].type==-1)
				{
				app = &_applications_[i];
				j=1;
				break;
				}
			}
		if(j==0)
			{
DEBUG
			tmp = calloc((_applications_->no+1), sizeof(struct _applications));
			_applications_->no++;
			memset(tmp, 0, _applications_->no*sizeof(struct _applications));
			memcpy(tmp, _applications_, (_applications_->no-1)*sizeof(struct _applications));
			free(_applications_);
DEBUG
			_applications_ = tmp;
			app = &_applications_[_applications_->no-1];
			app->no = _applications_->no;
			i = _applications_->no-1;
			}
		}
DEBUG
	if(app==NULL)
		return;
	memset(app->name, 0, 24);
	memset(app->bubble, 0, 255);
	strncpy(app->name, _name, min(24, strlen(_name)));
	app->button_color = -1;

	app->type = type;
	app->id = id;

/*	app->il_ikonek = 0;		app->ikonki = NULL;
	app->no_windows = 0;
	app->acc_icon = 0;
*/
	app->active = 1;
	if(_applications_[MyTask.prev_app_on_top].show_button!=0 && _applications_[MyTask.prev_app_on_top].active==1)
		{
		_applications_[MyTask.prev_app_on_top].active = 0;
		redraw(0, bigbutton->ob_x+bigbutton[_applications_[MyTask.prev_app_on_top].button_no].ob_x,
							bigbutton->ob_y+bigbutton[_applications_[MyTask.prev_app_on_top].button_no].ob_y,
							bigbutton[_applications_[MyTask.prev_app_on_top].button_no].ob_width,
							bigbutton[_applications_[MyTask.prev_app_on_top].button_no].ob_height, "_add_app");
		}
	MyTask.actual_app_on_top = app->no;
	MyTask.prev_app_on_top = app->no;

	memset(app->alias, 0, 24);
	find_alias(app->name, app->alias);
	if(stic)
		app->icon = stic->str_icon(app->name, STIC_SMALL);
	memset(app->window_handlers, 0, 100);
	if(system_!=SYS_MINT)
		app->name[strcspn(app->name, " ")] = 0;
	app->show_button = 1;
	if(strcmp(app->name, "SCRENMGR")==0)			/* Nie zapamietujemy ScreenManager'a */
		{
		screen_manager_id = id;									/* ID potrzebne do operacji na aplikacjach	*/
		app->show_button = 0;
		}
	if(id==ap_id || find_app_to_not_show(_name)==1)
		app->show_button = 0;

	{
	int i_n;
	for(i_n=0; i_n<128; i_n++)
		strcpy(app->window_name[i_n], "");
	}

	_name[strcspn(_name, " ")] = 0;
	if((font_appl=find_app_font(_name))!=-1)
		{
		app->font_id = FontsID[font_appl].id;
		app->font_color = FontsID[font_appl].color;
		app->font_effect = FontsID[font_appl].effect;
		app->font_height = FontsID[font_appl].height;
		}
	else
		{
		if(startinf.default_font_id!=0)
			app->font_id = startinf.default_font_id;
		else
			app->font_id = 1;
		app->font_color = -1;
		app->font_effect = -1;
		app->font_height = startinf.font_height;
		}

	if(system_!=SYS_MINT)
		{
	/* Sprawdzamy teraz PID procesu	*/
		app->pid = -1;
		sprintf(name, "u:\\proc\\%s.*", _name);
		dta = Fgetdta();
		if(dta)
			{
			Fsfirst(name, 0);
			if(strlen(dta->d_fname)>=strlen(_name) && strncmp(dta->d_fname, _name, strlen(_name))==0)
				{
				app->pid = atoi(&dta->d_fname[strlen(_name)+1]);			/* Process ID	!= AES ID		*/
				app->used_memory = (int)(dta->d_length/1000L);				/* Memory usage in kB			*/
				}
			}
		}
	else
		app->pid = pid;

	if (gsi)
		{
		gsi->len     = sizeof(GS_INFO);
		gsi->version = 0x0120;
		gsi->msgs    = GSM_COMMAND;
		gsi->ext     = 0L;
		app->gs_id = 1;
		app->gs = 0;
		SendAV(id, GS_REQUEST, ap_id, 0, (int)(((long)gsi >> 16) & 0x0000ffffL), (int)((long)gsi & 0x0000ffffL), 0, 0, app->gs_id);
		}
	SendAV(id, MYTASK_START, ap_id, 0, 0, 0, 0, 0, 0);
	app->mytask_send = 1;
	app->check = 1;
	}


long long_appl_search(short mode, char *name, int *type, int *id, int *pid)
	{
	long r;
	char temp[128];
	short type1=0, id1=0, pid1=0;

	if(name==NULL)
		return(-1);

	memset(name, 0, 126);
	/* AES 4.0 */
	r = mt_appl_search(mode, name, &type1, &id1, (short*)&_GemParBlk.global[0]);

DEBUG

	if (aes_avail.lange_namen && r==1 && id1 && system_==SYS_MINT)
		{
		/* N.AES */
		r = mt_appl_search(-id1, temp, &type1, &pid1, (short*)&_GemParBlk.global[0]);
		if (r == 1 && strlen(temp)>1)
			memcpy(name, temp, strlen(temp));
		trim_start(name);
		*type = type1;	*id = id1;	*pid=pid1;
		return 1;
		}

DEBUG

	*type = type1;	*id = id1;	*pid=pid1;
	return r;
	}


void _delete_app(int no)
	{
	struct _applications *tmp = calloc(1,(_applications_->no-1)*sizeof(struct _applications));
	_applications_[no].show_button = 0;

	if(no==_applications_->no)
		{
		memcpy(tmp, _applications_, sizeof(struct _applications)*(_applications_->no-1));
		free(_applications_);
		_applications_ = tmp;
		}
	else
		{
		memcpy(tmp, _applications_, sizeof(struct _applications)*no);
		memcpy(&tmp[no], &_applications_[no+1], sizeof(struct _applications)*(_applications_->no-no));
		}
	_applications_->no--;
	}



void find_applications(void)
	{
	char name[126];
	int type, id, pid, i=0, new=0, app_no, how_many, butt, butt_x, butt_y, butt_w;

DEBUG

	if (!gsi)
		gsi = (GS_INFO *)calloc(1, sizeof(GS_INFO));

DEBUG

	if(_applications_)
		{
		how_many = _applications_->no;									/* Zapamietanie ilosci aplikacji	*/
		for(i=0; i<_applications_->no; i++)
			{
			if(_applications_[i].check!=2)
				_applications_[i].check = 0;								/* Wyzerowanie stanu aktywnosci aplikacji
																											 jest to niezbedne do sprawdzenia szukana aplikacja
																											 jest ciagle w pamieci.
																											 Stan 2 oznacza "frezzy"	*/
			}
		}

DEBUG

	long_appl_search(0, name, &type, &id, &pid);			/* Odszukanie pierwszej aplikacji	*/
	if((app_no = find_app_by_id(id))==-1)							/* Czy jest juz w pamieci MyTask?	*/
		{																								/* Nie														*/
		_add_app(name, id, pid, type);									/* Dodanie aplikacji							*/
		new = 1;																				/* Przerysowac przyciski					*/
		}
	else																							/* Tak														*/
		{
		if(_applications_[i].check==2)									/* Czy aplikacja zamrozona?				*/
			new = 1;																			/* Przerysowac przyciski, jezeli aplikacja
																											 zostala odmrozona							*/
		_applications_[app_no].check = 1;								/* Zmiana stanu na "dziala"				*/
		}

DEBUG

	while(long_appl_search(1, name, &type, &id, &pid)!=0)		/* Szukanie kolejnych aplikacji	*/
		{
		if((app_no = find_app_by_id(id))==-1)						/* Czy jest juz w pamieci MyTask	*/
			{																							/* Nie														*/
DEBUG
			_add_app(name, id, pid, type);								/* Dodanie aplikacji							*/
DEBUG
			new = 1;																			/* Przerysowac przyciski					*/
			}
		else																						/* Tak														*/
			{
			if(_applications_[i].check==2)								/* Czy aplikacja zamrozona?				*/
				new = 1;																		/* Przerysowac przyciski, jezeli aplikacja
																											 zostala odmrozona							*/
			_applications_[app_no].check = 1;							/* Zmiana stanu na "dziala"				*/
			}
		}

DEBUG

	for(i=0; i<_applications_->no; i++)					/* Sprawdzenie czy niektore aplikacje rzeczywiscie nie dzialaja	*/
		{
		if(_applications_[i].check == 0)					/* Czy ta aplikacja nie zostala odnaleziona?										*/
			{
			char name[24]={0};
			int h;
			if(strlen(_applications_[i].name)>1)
				sprintf(name, "U:\\PROC\\%s.%03d", _applications_[i].name, _applications_[i].pid);
DEBUG
			if((h=open(name, O_RDONLY))>0)
				{
				_applications_[i].check = 2;					/* Aplikacja zamrozona																					*/
				close(h);
				break;
				}
DEBUG
			if(_applications_[i].id!=-1 && _applications_[i].pid!=-1 && _applications_[i].type!=-1)
				{
				if(_applications_[i].il_ikonek>0)
					{
					icons_sys.how_many--;
					if(_applications_[i].ikonki)
						{
						int ii;
						for(ii=0; ii<_applications_[i].il_ikonek; ii++)
							delete_icon(&_applications_[i], _applications_[i].ikonki[ii].rsc_no);
						free(_applications_[i].ikonki);
						}
					_applications_[i].ikonki = NULL;
					}
DEBUG
				new = 2;
				butt = _applications_[i].button_no;
				butt_x = bigbutton[butt].ob_x;
				butt_y = bigbutton[butt].ob_y;
				butt_w = bigbutton[butt].ob_width;
				memset(&_applications_[i], 0, sizeof(struct _applications));
				_applications_[i].id = -1;
				_applications_[i].pid = -1;
				_applications_[i].type = -1;
DEBUG
				}
			}
		}

DEBUG

	if(new>0 || how_many!=_applications_->no)
		{
		int ww=0;
		if(fix_width()==1)					/* Korekcja Traya ze wzgledu na ikonki	*/
			{
			build_applications(-1);
DEBUG
			}
		else
			{
			for(i=butt; i<APPLICATION_LAST; i++)
				ww += (bigbutton[i].ob_width+2);
DEBUG
			build_applications(butt);
DEBUG
			}
		if(new==2)
			{
			_redraw_.x = bigbutton->ob_x + butt_x;
			_redraw_.y = bigbutton->ob_y + butt_y;
			_redraw_.w = ww;
			}
		}
	if(gsi)
		free(gsi);
DEBUG
	}


void make_appl_list(void)			/* Robimy pierwszy raz liste wszystkich obecnie dzialajacych aplikacji	*/
	{
	tylko_lista = 1;
DEBUG
	find_applications();
DEBUG
	tylko_lista = 0;
	}


void move_applications(signed int dir)
	{
	int i=0, objc=0;
	int delta_x, start_x;

	bigbutton->ob_height = MyTask.org_h;
	bigbutton->ob_y = MyTask.org_y;
	MyTask.lines = 0;

	mt_wind_set(MyTask.whandle,WF_CURRXYWH,MyTask.cur_x,MyTask.cur_y,MyTask.cur_w,MyTask.cur_h, (short*)&_GemParBlk.global[0]);

	objc = _applications_[0].button_no;
	start_x = bigbutton[SEPARATOR_2].ob_x;
	delta_x = dir*abs(bigbutton[SEPARATOR_2].ob_x + 10 - bigbutton[objc].ob_x);
	while(i<_applications_->no)
		{
		objc = _applications_[i].button_no;
		if(objc!=0)
			bigbutton[objc].ob_x += delta_x;
		i++;					/* Kolejna aplikacja											*/
		}
	}


void hide_button(int app, int button)
	{
	if(button==APPLICATION_1)
		{
		if(first_added_app!=0)
			bigbutton[button-1].ob_next = first_added_app;
		else if(first_added_tray!=0)
			bigbutton[button-1].ob_next = first_added_tray;
		else
			bigbutton[button-1].ob_next = 0;
		}
	else if(button==APPLICATION_LAST)
		{
		if(first_added_app!=0)
			bigbutton[button-1].ob_next = first_added_app;
		else if(first_added_tray!=0)
			bigbutton[button-1].ob_next = first_added_tray;
		else
			bigbutton[button-1].ob_next = 0;
		}
	else if(button>APPLICATION_1 && button<APPLICATION_LAST)
		{
		int ww = bigbutton[button].ob_width+ICON_DISTANCE, i, j;

		memcpy(&bigbutton[button], &bigbutton[button+1], (APPLICATION_LAST-button)*sizeof(OBJECT));
		for(i=button; i<=APPLICATION_LAST, i<last_added_button; i++)
			{
			j = find_app_by_button(0, bigbutton[i].ob_x+1);
			_applications_[j].button_no = i;
			if(bigbutton[i].ob_next<APP_ICON_1 && bigbutton[i].ob_next>APPLICATION_1)
				bigbutton[i].ob_next = i+1;
			bigbutton[i].ob_x -= ww;
			if(bigbutton[i].ob_x<bigbutton[SEPARATOR_2].ob_x)
				{
				bigbutton[i].ob_y -= (bigbutton[i].ob_height + 2);	
				bigbutton[i].ob_x = bigbutton[i-1].ob_x	+ bigbutton[i-1].ob_width + ICON_DISTANCE;
				}
			_applications_[j].pos_x = bigbutton[i].ob_x;
			/* xxx
				Tutaj trzeba sprawdzic, czy przyciski mieszcza sie jeszcze w danej linijce!!	*/
			}
		last_added_button--;
		}
	else
		mt_form_alert(1, "[1][Zly nr przycisku!!][Hmm]", (short*)&_GemParBlk.global[0]);
	}


void show_button(int app, int button)
	{
	}


void delete_button(int app_no)
	{
	}

void add_button(int app_no)
	{
	}


void build_applications(int mode)
	{
	int i=0, objc=0, j=APPLICATION_1, str_len, start_x=0, end_x=0;
	int pos_x, pos_y=bigbutton[START_BUTTON].ob_y-2;
	int old_tail, new_obj=-1;
	char name[50]={0};
	OBJECT *_icons=NULL;

	if(pos_y <=0 )
		pos_y = 2;

DEBUG

	bigbutton[MYTASK_HIDE].ob_flags &= ~OF_LASTOB;
	start_x = pos_x = bigbutton[SEPARATOR_2].ob_x + 10;
	old_tail = bigbutton->ob_tail;
	bigbutton->ob_tail = 7;

	bigbutton->ob_height = MyTask.org_h;
	bigbutton->ob_y = MyTask.org_y;
	MyTask.lines = 0;

	if(MyTask.whandle>=1)
		mt_wind_set(MyTask.whandle,WF_CURRXYWH,MyTask.cur_x,MyTask.cur_y,MyTask.cur_w,MyTask.cur_h, (short*)&_GemParBlk.global[0]);

DEBUG
	while(i<_applications_->no)
		{
		if(_applications_[i].show_button==1)
			{
DEBUG
			str_len = 0;
			bigbutton->ob_tail++;
			bigbutton->ob_next = -1;
			if(objc!=0)
				bigbutton[objc].ob_flags &= ~OF_LASTOB;
			if((objc=mt_objc_add(bigbutton, j, j-1, (short*)&_GemParBlk.global[0]))!=0)											/* Dodajemy przycisk	*/
				objc=j;

DEBUG
			if(bigbutton[objc].ob_spec.userblk)
				free(bigbutton[objc].ob_spec.userblk);
			usrdef_button = calloc(1,sizeof(USERBLK));
			usrdef_button->ub_code = draw_button;
			usrdef_button->ub_parm = (unsigned long)i;
			bigbutton[objc].ob_type = G_USERDEF;													/* Typ								*/
			bigbutton[objc].ob_spec.userblk = usrdef_button;

DEBUG
			if(bigbutton[objc].ob_next==0)
				{
				start_x = pos_x;
				new_obj = objc;
				}
			bigbutton[objc].ob_next = 0;																	/* Nastepny						*/
			bigbutton[objc].ob_flags = (OF_LASTOB|OF_SELECTABLE|OF_EXIT|FLAGS10);	/* Flagi							*/
			bigbutton[objc].ob_head = bigbutton[objc].ob_tail = -1;				/* 										*/
			bigbutton[objc].ob_state = OS_NORMAL;														/* Stan przycisku			*/
			if((bigbutton[START_BUTTON].ob_height+4) < bigbutton[ROOT].ob_height)
				bigbutton[objc].ob_height = bigbutton[START_BUTTON].ob_height+4;
			else
				bigbutton[objc].ob_height = bigbutton[ROOT].ob_height-2;
			bigbutton[objc].ob_x = _applications_[i].pos_x = pos_x;
			bigbutton[objc].ob_y = pos_y-1;
			_applications_[i].button_no = objc;

DEBUG
			strcpy(name, _applications_[i].name);
			trim_end(name);

DEBUG
			str_len = get_text_width(name, i, _applications_[i].font_id, &_applications_[i].font_height);

DEBUG
			bigbutton[objc].ob_width = _applications_[i].width = str_len;

			memset(name, 0, 50);

DEBUG
			fix_width();
			if((pos_x+str_len)>=bigbutton[SEPARATOR_3].ob_x)
				{																															/* Podwyzszenie MyTask	*/
				MyTask.lines++;
				bigbutton->ob_y -= (bigbutton[objc].ob_height+3);
				MyTask.new_y = bigbutton->ob_y;
				MyTask.new_h = (MyTask.lines+1) * (bigbutton[objc].ob_height + 3) + 2;
				bigbutton->ob_height = MyTask.new_h;
				pos_y += bigbutton[objc].ob_height + 2;
				pos_x = bigbutton[SEPARATOR_2].ob_x + 10;
				bigbutton[objc].ob_x = _applications_[i].pos_x = pos_x;
				bigbutton[objc].ob_y = pos_y-1;
				if(MyTask.whandle>=1)
					mt_wind_set(MyTask.whandle, WF_CURRXYWH, 0, bigbutton->ob_y, bigbutton->ob_width, bigbutton->ob_height, (short*)&_GemParBlk.global[0]);
DEBUG
				}
			else
				{
				if(MyTask.lines==0 && objc>=mode)
					end_x += (bigbutton[objc].ob_width+2);
DEBUG
				}

			pos_x += (str_len+1);

			j++;				/* Kolejny przycisk												*/
			}						/* if(_applications_[i].show_button==1)		*/
		i++;					/* Kolejna aplikacja											*/
		}


DEBUG

	last_added_obj = objc;
	last_added_button = objc;

	if(icons_sys.first_obj>0 || icons_app.first_obj>0)
		{
		bigbutton[objc].ob_flags &= ~OF_LASTOB;
		if(last_added_app!=0)
			bigbutton[objc].ob_next = APP_ICON_1;
		else if(last_added_tray!=0)
			bigbutton[objc].ob_next = SYS_ICON_1;
		bigbutton->ob_tail = old_tail;
		}

	/*
	end_x - powinno uwzgledniac wszystkie przyciski - glownie te "za" chowanym!!
	*/
	i = objc = APPLICATION_1;
	while(i<APPLICATION_LAST)
		{
		if(bigbutton[i].ob_x>bigbutton[objc].ob_x && objc>mode)
			{
			end_x = bigbutton[objc].ob_x - bigbutton[SEPARATOR_2].ob_x;
			objc = i;
			}
		i++;
		}
	if(mode==0)
		end_x += bigbutton[SEPARATOR_2].ob_x;

	if(new_obj!=-1)
		{
		_redraw_.x = start_x = bigbutton->ob_x + bigbutton[new_obj].ob_x;
		end_x = bigbutton[new_obj].ob_width;
		if(bigbutton[new_obj+1].ob_width>0)
			{
			i = new_obj+1;
			while(i<APPLICATION_LAST)
				{
				if(bigbutton[i].ob_width>0)
					{
					end_x = (bigbutton[objc].ob_width+2);
					}
				i++;
				}
			}
		}

/* Add System Tray Icons */

	for(no_acc=0, i=0; i<_applications_->no ; i++)
		{
		struct _applications *app = &_applications_[i];
		if(app->type==APP_ACCESSORY && options.acc_in_system_tray)
			{
			OBJECT *tmp=NULL;
			if(stic)
				tmp = stic->str_icon(app->name, 2);
			acc[no_acc].app_no = i;
			acc[no_acc++].icon = tmp;
			how_many_acc++;
			}
		}

/* ********************* */

	if(mode!=-1)
		{
		fix_width();
		_redraw_.type |= RED_APP;
		_redraw_.x = min0(_redraw_.x, start_x);
		_redraw_.y = min0(_redraw_.y, bigbutton->ob_y);
		_redraw_.w = max(_redraw_.w, abs(end_x+2));
		_redraw_.h = max(_redraw_.h, bigbutton->ob_height+2);
		}

DEBUG
	}


void SendACCIcon(void)
	{
/*
	int i;
	OBJECT *tmp=NULL;
DEBUG
	if(options.acc_in_system_tray!=TRUE)
		return;
DEBUG
	for(i=0; i<how_many_acc; i++)
		{
		if((tmp=acc[i].icon)!=NULL)
			{
			if(!pipe)
				{
				pipe = calloc(1, 16);
				memset(pipe, 0, 16);
				}
			pipe[0] = (int)(((long)tmp >> 16) & 0x0000ffffL);
			pipe[1] = (int)((long)tmp & 0x0000ffffL);
			SendAV(ap_id, MYTASK_NEW_ICON, _applications_[acc[i].app_no].id, 1, (int)pipe[0], (int)pipe[1], 0, 0, 0);
			}
		}
DEBUG
/*	how_many_acc = 0;	*/
*/
	}


void DeleteACCicon(void)
	{
	int i;

	for(i=0; i<how_many_acc; i++)
		SendAV(ap_id, MYTASK_DELETE_ICON, _applications_[acc[i].app_no].id, 1, 0, 0, 0, 0, 0);
	how_many_acc = 0;
	}


void check_window_name(int app, int h, char *text)
	{
	int i;
	for(i=0; i<_applications_[app].no_windows ; i++)
		{
		if(_applications_[app].window_handlers[i]==h && strstr((const char*)_applications_[app].window_name, text)==NULL)
			{
			memset(_applications_[app].window_name[i], 0 ,128);
			if(options.fenster_name_mit_handler==1)
				{
				itoa(h, _applications_[app].window_name[i], 10);
				strcat(	_applications_[app].window_name[i], "-> ");
				}
			else
				strcat(	_applications_[app].window_name[i], "  ");
			strcat(	_applications_[app].window_name[i], text);
			}			
		}
	}



static short prev_top_window, prev_top_menu;

int Find_top_window(void)
	{
	short ww_id, aa_id, www_id;
	short aa2,aa3,aa4,app_win_on_top;
	mt_wind_get(0,     WF_TOP,   &ww_id,      &aa_id, &www_id, &aa4, (short*)&_GemParBlk.global[0]);
	mt_wind_get(ww_id, WF_OWNER, &MyTask.actual_win_on_top, &aa2,   &aa3,    &aa4, (short*)&_GemParBlk.global[0]);
	app_win_on_top = find_app_by_window(ww_id);
	if(app_win_on_top<0)
		app_win_on_top = find_app_by_id(MyTask.actual_win_on_top);
	return(app_win_on_top);
	}

int Find_top_menu(void)
	{
	int menu_on_top = mt_menu_bar(NULL, -1, (short*)&_GemParBlk.global[0]);

	return(find_app_by_id(menu_on_top));				/* -1 lub ID aplikacji	*/
	}

void Change_top_application(void)
	{
	int menu_id = Find_top_menu();							/* ID aplikacji, ktorej menu jest na wierzchu			*/
	int window_id = Find_top_window();					/* ID aplikacji, ktorej okienko jest na wierzchu	*/
	short i=0,aa4=1;
	short prev_b_x, prev_b_w;

	if(prev_top_menu!=menu_id || prev_top_window!=window_id)				/* Nowe okienko lub menu na wierzchu	*/
		{
		int butt_no = _applications_[MyTask.prev_app_on_top].button_no;
		if(MyTask.prev_app_on_top!=-1)
			{
			prev_b_x = bigbutton[butt_no].ob_x;
			prev_b_w = bigbutton[butt_no].ob_width;
			_applications_[MyTask.prev_app_on_top].active = 0;

			if(_applications_[MyTask.prev_app_on_top].show_button)
				redraw(0, bigbutton->ob_x+bigbutton[butt_no].ob_x, bigbutton->ob_y+bigbutton[butt_no].ob_y,bigbutton[butt_no].ob_width,bigbutton[butt_no].ob_height, "Change_top_application 1");
			}

		if(prev_top_window!=window_id)		/* Nowe okienko	*/
			MyTask.actual_app_on_top = window_id;
		else															/* Nowe MENU		*/
			MyTask.actual_app_on_top = menu_id;

		prev_top_window = window_id;
		prev_top_menu = menu_id;
		MyTask.prev_app_on_top = MyTask.actual_app_on_top;
		_applications_[MyTask.actual_app_on_top].active = 1;

		butt_no = _applications_[MyTask.actual_app_on_top].button_no;
		if(_applications_[MyTask.actual_app_on_top].show_button)
			redraw(0, bigbutton->ob_x+bigbutton[butt_no].ob_x, bigbutton->ob_y+bigbutton[butt_no].ob_y,bigbutton[butt_no].ob_width,bigbutton[butt_no].ob_height, "Change_top_application 1");
		}


	for(i=0; aa4!=0; i++)
		{
		int found_app=0;
		short aa2,aa3,pxy[8];
		if(aes_avail.get_window_owner)
			{
			char *text=NULL;
			aa4 = mt_wind_get(i, WF_OWNER, &MyTask.actual_win_on_top, &aa2, &aa3, &aa3, (short*)&_GemParBlk.global[0]);
			mt_wind_get(i, WF_NAME, (short*)&pxy[0], (short*)&pxy[1], (short*)&pxy[2], (short*)&pxy[3], (short*)&_GemParBlk.global[0]);
			text = *(char **)&pxy[0];
			found_app = find_app_by_window(i);
			if(found_app!=-1)
				check_window_name(found_app, i, text);
			if(found_app==-1 || found_app!=MyTask.actual_win_on_top)
				add_window_to_app(MyTask.actual_win_on_top, i, text);
			}
		}

	if(_redraw_.type!=0 && tylko_lista==0)
		{
		if(_redraw_.type&RED_BUTTONS && !(_redraw_.type&RED_APP))
			{
			if(prev_b_x!=bigbutton->ob_x)
				{
DEBUG
				prev_b_w = min0(_redraw_.w, prev_b_w);
				SendAV(ap_id, WM_REDRAW, ap_id, -1, MyTask.whandle, prev_b_x, _redraw_.y, prev_b_w, _redraw_.h);
				}
			}
		else
			{
DEBUG
			SendAV(ap_id, WM_REDRAW, ap_id, RED_INFO_APP, MyTask.whandle, _redraw_.x, _redraw_.y, _redraw_.w, _redraw_.h);
			}

DEBUG
		_redraw_.type = 0;
		_redraw_.x = _redraw_.y = _redraw_.w = _redraw_.h = 0;
		}
	}



void Change_time(int mx, int my)
	{
	static int prev_key;
	static int w_id;
	static unsigned long timer_prev, prev_min;
	long timer, key;
	short obj, prev_x = bigbutton[SEPARATOR_3].ob_x, amer=0;
	struct _tm *tim;
	short ww_id=0, aa_id=0, www_id=0;
	short aa2=0, aa3=0, aa4=0;
	short font_pos[10]={0}	/*, repeat=0*/	;
	short chw,chh,cw,ch,str_len=0;
	char time_mode_tmp[20]={0};

	time(&timer);
	if(timer==timer_prev)
		timer++;
	tim = (struct _tm*)localtime(&timer);
	
	if(mx!=-1 && my!=-1)
		Change_top_application();


	if(my!=-1)
		{
		if(my<bigbutton->ob_y && options.autohide!=0 && hidden==0)															/* Autohide	*/
			hide_mytask();
		if(my>=(bigbutton->ob_y-bigbutton->ob_height) && options.autohide!=0 && hidden==1)			/* Autoshow	*/
			show_mytask();
		}

	obj = mt_objc_find(bigbutton, 0, MAX_DEPTH, mx, my, (short*)&_GemParBlk.global[0]);
	if(my>=(bigbutton->ob_y-bigbutton->ob_height) && ((obj==1 && options.autotop==2) || options.autotop==1) && MyTask.whandle>=1)
		mt_wind_set(MyTask.whandle,WF_TOP,0,0,0,0, (short*)&_GemParBlk.global[0]);

DEBUG
	/* Pamiec wyznaczamy tylko wtedy kiedy jest taka potrzeba naprawde!!	*/
	if(strstr(options.time_mode_1, "%r")!=NULL || strstr(options.time_mode_2, "%r")!=NULL)
		MyTask.actual_memory = ((unsigned long)Malloc(-1))/1000L;							/* Ilosc wolnej pamieci w [kB]	*/

	key = Kbshift(-1);
	key = key&16;
	if(key!=prev_key)
		redraw(0, bigbutton->ob_x+bigbutton[TIME_OBJECT].ob_x, bigbutton->ob_y, bigbutton[TIME_OBJECT].ob_width, bigbutton->ob_height, "change_time key");
	if((prev_min!=tim->tm_min || MyTask.prev_memory!=MyTask.actual_memory || MyTask.prev_app_on_top!=MyTask.actual_app_on_top) && hidden==0)
		{
DEBUG

		amer = modify_time_format(options.time_mode_1, time_mode_tmp, tim);
		strftime(text_time_line1, 20, time_mode_tmp, (struct tm*)tim);
		if(strstr(text_time_line1, "%r")!=NULL)
			sprintf(strstr(text_time_line1, "%r")-2, "%Ld kB", MyTask.actual_memory);

DEBUG

		memset(time_mode_tmp, 0, 20);
		amer = modify_time_format(options.time_mode_2, time_mode_tmp, tim) | amer;
		strftime(text_time_line2, 20, time_mode_tmp, (struct tm*)tim);
		if(strstr(time_mode_tmp, "%r")!=NULL)
			sprintf(&text_time_line2[(strstr(time_mode_tmp, "%r")-time_mode_tmp)], "%Ld kB", MyTask.actual_memory);

DEBUG

		if(amer>0)
			strftime(_calendar.today, 20, "%m/%d/%Y, ", (struct tm*)tim);
		else
			strftime(_calendar.today, 20, "%d.%m.%Y, ", (struct tm*)tim);
		sprintf(_calendar.today, "%s%s", _calendar.today, dni[tim->tm_wday+1]);

DEBUG

		vst_load_fonts(MyTask.v_handle, 0);
		if((chh=vst_font(MyTask.v_handle, startinf.timer_font_id))==startinf.timer_font_id)
			{
			if(startinf.timer_font_id==0 || startinf.timer_font_id==1)
				vst_height(MyTask.v_handle, 6, &chw, &chh, &cw, &ch);
			else
				vst_height(MyTask.v_handle, 10, &chw, &chh, &cw, &ch);
			if(strlen(text_time_line1)>strlen(text_time_line2))
				vqt_extent( MyTask.v_handle, text_time_line1, font_pos );
			else
				vqt_extent( MyTask.v_handle, text_time_line2, font_pos );
			str_len = font_pos[2] + 16;
			vst_font(MyTask.v_handle, 1);
			}
		if(str_len<1)
			str_len = max((int)strlen(text_time_line1), (int)strlen(text_time_line2))*10;
		vst_unload_fonts(MyTask.v_handle, 0);

		bigbutton[TIME_OBJECT].ob_width = str_len;

		MyTask.prev_memory = MyTask.actual_memory;
		prev_min = tim->tm_min;

		}
	timer_prev=timer;
	find_applications();
	prev_key = (int)key;
DEBUG
	}


/**	Pierwsze przygotowanie listy z aplikacjami.
	- wyszukanie nowych aplikacji
	- dodanie przyciskow (sprawdzic najpierw czy przycisk wogole pokazywac)
	- NIE PRZERYSOWYWAC NICZEGO!!!
*/
void prepare_applications_list(void)
	{
	char name[126];
	int type, id, pid, i=0, app_no;

DEBUG

	if (!gsi)
		gsi = (GS_INFO *)calloc(1,sizeof(GS_INFO));


	long_appl_search(0, name, &type, &id, &pid);			/* Odszukanie pierwszej aplikacji	*/
	if((app_no = find_app_by_id(id))==-1)							/* Czy jest juz w pamieci MyTask?	*/
		{																								/* Nie														*/
		_add_app(name, id, pid, type);									/* Dodanie aplikacji							*/
		}
	else																							/* Tak														*/
		{
		if(_applications_[i].check==2)									/* Czy aplikacja zamrozona?				*/
		_applications_[app_no].check = 1;								/* Zmiana stanu na "dziala"				*/
		}

	while(long_appl_search(1, name, &type, &id, &pid)!=0)		/* Szukanie kolejnych aplikacji	*/
		{
		if((app_no = find_app_by_id(id))==-1)						/* Czy jest juz w pamieci MyTask	*/
			{																							/* Nie														*/
			_add_app(name, id, pid, type);								/* Dodanie aplikacji							*/
			}
		else																						/* Tak														*/
			{
			if(_applications_[i].check==2)								/* Czy aplikacja zamrozona?				*/
			_applications_[app_no].check = 1;							/* Zmiana stanu na "dziala"				*/
			}
		}
	}