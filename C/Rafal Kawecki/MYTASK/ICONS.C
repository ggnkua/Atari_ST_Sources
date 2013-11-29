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
#include "sounds.h"
#include "global.h"
#include "option.h"
#include "memdebug.h"

struct _icons icons_sys, icons_app;
struct _icons_spec_app *icons_spec_app;
int first_added_button, first_added_app, first_added_tray;


int wh_icons;

void free_icons(void)
	{
	int i;
	for(i=APP_ICON_1; i<APP_ICON_LAST; i++)
		{
		if(bigbutton[i].ob_type&G_CICON)
			{
			CICONBLK *icon=(CICONBLK*)bigbutton[i].ob_spec.iconblk;
			free(icon->mainlist->col_data);
			free(icon->mainlist->col_mask);
			free(icon->mainlist);
			free(icon->monoblk.ib_pdata);
			free(icon->monoblk.ib_pmask);
			free(icon);
			}
		}
	for(i=SYS_ICON_1; i<SYS_ICON_LAST; i++)
		{
		if(bigbutton[i].ob_type&G_CICON)
			{
			CICONBLK *icon=(CICONBLK*)bigbutton[i].ob_spec.iconblk;
			free(icon->mainlist->col_data);
			free(icon->mainlist->col_mask);
			free(icon->mainlist);
			free(icon->monoblk.ib_pdata);
			free(icon->monoblk.ib_pmask);
			free(icon);
			}
		}
	}

int add_icon(void *tmp, int mode, int icon_nr, char *mono_data, char *mono_mask, char  *col_data, char *col_mask)
	{
	struct _ikonki *ikon_tmp=NULL;
	struct _applications *app = (struct _applications *)tmp;
	struct _icons_spec_app *icons_tmp = (struct _icons_spec_app *)tmp;
	int objc;
	CICONBLK *icon=NULL;

	if(mode==SYS_TRAY && app!=NULL)
		app->il_ikonek++;

	if(mode==SYS_TRAY && app!=NULL)
		{
		ikon_tmp = calloc(1,app->il_ikonek*sizeof(struct _ikonki));
		if(app->ikonki)
			{
			memcpy(ikon_tmp, app->ikonki, (app->il_ikonek-1)*sizeof(struct _ikonki));
			free(app->ikonki);
			}
		ikon_tmp[app->il_ikonek-1].no = icon_nr;
		ikon_tmp[app->il_ikonek-1].pos_x = 0;
		memset(ikon_tmp[app->il_ikonek-1].data, 0, 512);
		app->ikonki = ikon_tmp;
		}
	else if(icons_tmp)
		icons_tmp->no++;

	if(mode==APP_TRAY)
		objc = APP_ICON_1 + icons_app.how_many - 1;
	else
		objc = SYS_ICON_1 + icons_sys.how_many - 1;

	if(last_added_tray!=0 && mode==SYS_TRAY)
		bigbutton[last_added_tray].ob_next = objc;
	else if(last_added_app!=0 && mode==APP_TRAY)
		bigbutton[last_added_app].ob_next = objc;
	else
		bigbutton[last_added_button].ob_next = objc;

	bigbutton[objc].ob_next = 0;																/* Nastepny				*/
	bigbutton[objc].ob_type = G_CICON;													/* Typ						*/
	bigbutton[objc].ob_flags = OF_LASTOB;													/* Flagi					*/
	bigbutton[objc].ob_head = bigbutton[objc].ob_tail = -1;			/* 								*/
	bigbutton[objc].ob_state = OS_NORMAL;													/* Stan przycisku	*/
	bigbutton[objc].ob_width = ICON_SMALL;
	bigbutton[objc].ob_height = ICON_SMALL;

	if(mode==APP_TRAY)						/* APP_TRAY			*/
		{
		if(icons_app.last_pos_x==0)
			icons_app.last_pos_x = bigbutton[SEPARATOR_1].ob_x + ICON_DISTANCE + 2;			/* Pierwsza ikonka w APP_TRAY	*/
		else
			icons_app.last_pos_x += 0;
		icons_app.first_obj = objc;
		if(icons_app.first_pos_x==0 || icons_app.last_pos_x>icons_app.first_pos_x)
			icons_app.first_pos_x = icons_app.last_pos_x;
		bigbutton[objc].ob_x = icons_app.last_pos_x;
		icons_app.last_pos_x += ICON_FULL_WIDTH;
		icons_tmp[icons_tmp->no-1].pos_x = icons_app.last_pos_x;
		icons_tmp->pos_x = icons_app.last_pos_x;
		}
	else if(mode==SYS_TRAY)				/* SYSTEM_TRAY	*/
		{
		if(icons_sys.last_pos_x==0)
			icons_sys.last_pos_x = bigbutton[TIME_SEPARATOR].ob_x - icons_sys.how_many*ICON_FULL_WIDTH;
		icons_sys.first_obj = objc;
		if(icons_sys.first_pos_x==0 || icons_sys.last_pos_x<icons_sys.first_pos_x)
			icons_sys.first_pos_x = icons_sys.last_pos_x;
		bigbutton[objc].ob_x = icons_sys.last_pos_x;
		icons_sys.last_pos_x -= ICON_FULL_WIDTH;
		}

	bigbutton[objc].ob_y = bigbutton[START_BUTTON].ob_y;
	if(bigbutton[objc].ob_y <= 0)
		bigbutton[objc].ob_y = 4;

	bigbutton[last_added_tray].ob_flags &= ~OF_LASTOB;
	bigbutton[last_added_app].ob_flags &= ~OF_LASTOB;
	bigbutton[last_added_obj].ob_flags &= ~OF_LASTOB;
	bigbutton[last_added_button].ob_flags &= ~OF_LASTOB;
	bigbutton[objc].ob_flags |= OF_LASTOB;


	icon = calloc(1,sizeof(CICONBLK));
	icon->monoblk = rs_ciconblk->monoblk;
	icon->mainlist = calloc(1,sizeof(CICON));
	memcpy(icon->mainlist, rs_ciconblk->mainlist, sizeof(CICON));
	icon->monoblk.ib_pdata = calloc(1,32L); memcpy(icon->monoblk.ib_pdata, mono_data, 32);
	icon->monoblk.ib_pmask = calloc(1,32L); memcpy(icon->monoblk.ib_pmask, mono_mask, 32);
	icon->mainlist->col_data = calloc(1,128L); memcpy(icon->mainlist->col_data, col_data, 128);
	icon->mainlist->col_mask = calloc(1,32L); memcpy(icon->mainlist->col_mask, col_mask, 32);

	(CICONBLK*)bigbutton[objc].ob_spec.iconblk = icon;
	if(mode==SYS_TRAY)
		{
		ikon_tmp[app->il_ikonek-1].icon_no = objc;
		ikon_tmp[app->il_ikonek-1].icon = icon;
		}

	last_added_obj = objc;
	if(mode==SYS_TRAY)
		{
		last_added_tray	= objc;
		if(first_added_tray==0)
			first_added_tray = objc;
		}
	else
		{
		last_added_app	= objc;
		if(first_added_app==0)
			first_added_app = objc;
		}
	bigbutton->ob_tail = max(last_added_tray, last_added_app);

	if(last_added_app!=0 && mode==SYS_TRAY)
		{
		bigbutton[last_added_button].ob_next = first_added_app;
		if(last_added_tray==first_added_tray && last_added_app!=0)
			bigbutton[last_added_app].ob_next = first_added_tray;
		else
			bigbutton[last_added_tray-1].ob_next = last_added_tray;
		}
	else if(last_added_app==0 && mode==SYS_TRAY)
		bigbutton[last_added_button].ob_next = last_added_tray;
	else if(last_added_app!=0 && mode==APP_TRAY)
		{
		bigbutton[last_added_button].ob_next = first_added_app;
		bigbutton[last_added_app-1].ob_next = last_added_app;
		}
	else if(mode==APP_TRAY)
		bigbutton[last_added_button].ob_next = last_added_app;

	if(mode==APP_TRAY)					/* Application tray	*/
		icons_tmp[icons_tmp->no-1].rsc_no = objc;
	else
		ikon_tmp[app->il_ikonek-1].rsc_no = objc;

	if(mode==SYS_TRAY)
		return(app->il_ikonek);
	else
		return(icons_tmp->no);
	}


int delete_icon(struct _applications *app, int icon_nr)
	{
	struct _ikonki *tmp_icon=NULL, *tmp=app->ikonki;
	int i=0, j=0, ic_obj=0;

	for(ic_obj=0; ic_obj<app->il_ikonek; ic_obj++)
		{
		if(tmp[ic_obj].no==icon_nr)
			{
			ic_obj = tmp[ic_obj].rsc_no;
			break;
			}
		}

	if(ic_obj>=SYS_ICON_1 && ic_obj<=SYS_ICON_LAST)			/* System Tray	*/
		{
		if(ic_obj==SYS_ICON_1)
			{
			if(last_added_app!=0)
				{
				bigbutton[last_added_app].ob_next = 0;
				bigbutton[last_added_app].ob_flags |= OF_LASTOB;
				bigbutton->ob_tail = last_added_app;
				}
			else
				{
				bigbutton[last_added_button].ob_next = 0;
				bigbutton[last_added_button].ob_flags |= OF_LASTOB;
				bigbutton->ob_tail = last_added_button;
				}
			memset(&bigbutton[ic_obj], 0, sizeof(OBJECT));
			}
		else if(ic_obj<last_added_tray)
			{
			bigbutton[ic_obj-1].ob_next = ic_obj+1;
			icons_sys.how_many--;
			for(i=SYS_ICON_1; i<=ic_obj; i++)
				bigbutton[i].ob_x -= ICON_FULL_WIDTH;
			}
		else if(ic_obj==last_added_tray)
			{
			bigbutton[ic_obj-1].ob_next = 0;
			bigbutton->ob_tail--;
			}
		}
	else																									/* Application tray	*/
		{
		}


	if(app->il_ikonek==1)
		free(app->ikonki);
	else
		{
		tmp_icon = calloc(1,(app->il_ikonek-1)*sizeof(struct _ikonki));
		for(i=0; i<app->il_ikonek; i++)
			{
			if(tmp[i].no!=icon_nr)
				memcpy(&tmp_icon[j++], &tmp[i], sizeof(struct _ikonki));
			}
		free(app->ikonki);
		app->ikonki = tmp_icon;
		}
	app->il_ikonek--;
	icons_sys.how_many--;
	return(1);
	}


int replace_icon(struct _applications *app, int obj_nr, int icon_nr, char *mono_data, char *mono_mask, char  *col_data, char *col_mask)
	{
	CICONBLK *icon=NULL;

	if(app->ikonki[obj_nr-1].no == icon_nr)
		{
		icon = app->ikonki[obj_nr-1].icon;

		if(icon!=NULL)
			{
			memcpy(icon->monoblk.ib_pdata, mono_data, 32);
			memcpy(icon->monoblk.ib_pmask, mono_mask, 32);
			memcpy(icon->mainlist->col_data, col_data, 128);
			memcpy(icon->mainlist->col_mask, col_mask, 32);
			}
		return(1);
		}
	else
		return(-1);
	}

int find_icon(struct _applications *app, int icon_nr)
	{
	int i;

	for(i=0; i<app->il_ikonek; i++)
		{
		if(app->ikonki[i].no == icon_nr)
			return(i+1);
		}
	return(-1);
	}


static int app_icon_mode;

void load_app_icon(void)
	{
	unsigned long tmp;
	int i, fh, n, len;
	char inf[256]={0};
	char *mono_mask, *mono_data, *col_mask, *col_data;
	CICONBLK *icon=NULL;

	if(	app_icon_mode==1)
		return;
	app_icon_mode = 1;

	strcpy(inf,home);
	strcat(inf,"defaults\\MyTask.ico");
	fh=(int)Fopen(inf,FO_READ);

	if (fh<0L)
		{
		strcpy(inf,home);
		strcat(inf,"MyTask.ico");
		fh=(int)Fopen(inf,FO_READ);
		}

	if (fh>=0L)
		{
		read(fh, &tmp, 4);		n = (int)tmp;
		icons_spec_app = calloc(1,n*sizeof(struct _icons_spec_app));
		memset(icons_spec_app, 0, n*sizeof(struct _icons_spec_app));
		for(i=0; i<n; i++)
			{
			read(fh, &icons_spec_app[i].obj_no, 4);
			read(fh, &tmp, 4);			len = (int)tmp;
			icons_spec_app[i].name = calloc(1,len+1L);
			memset(icons_spec_app[i].name, 0, len+1);
			read(fh, icons_spec_app[i].name, len);
			icons_app.how_many++;

			if(mini_icons!=NULL)
				{
				if(icons_spec_app[i].obj_no<=0)
					{
/*
					OBJECT *tmp=NULL;
					int j=(int)strlen(icons_spec_app[i].name);
					for(; j>0, icons_spec_app[i].name[j]!='\\'; j--)
						;
					if(stic)
						{
						tmp = stic->str_icon(&icons_spec_app[i].name[++j], 2);
						if(tmp)
							icon = (CICONBLK*)(tmp->ob_spec.ciconblk);
						}
					else	*/
						icon = (CICONBLK*)(mini_icons[abs(icons_spec_app[i].obj_no+1)].ob_spec.ciconblk);
					}
				else
					icon = (CICONBLK*)(mini_icons[icons_spec_app[i].obj_no].ob_spec.ciconblk);
				}
			if(stic)				/* Ikonka wzieta ze StIc					*/
				{
				OBJECT *tmp=NULL;
				int j=(int)strlen(icons_spec_app[i].name);
				for(; j>0, icons_spec_app[i].name[j]!='\\'; j--)
					;
				tmp = stic->str_icon(&icons_spec_app[i].name[++j], 2);
				if(tmp)
					icon = (CICONBLK*)(tmp->ob_spec.ciconblk);
				}
			if(icon)				/* Czy mamy jakas ikonke wogole?	*/
				{
				mono_data = (char*)icon->monoblk.ib_pdata;
				mono_mask = (char*)icon->monoblk.ib_pmask;
				col_data = (char*)icon->mainlist->col_data;
				col_mask = (char*)icon->mainlist->col_mask;
				}
			if(icon)
				add_icon((void *)icons_spec_app, APP_TRAY, icons_app.how_many, mono_data, mono_mask, col_data, col_mask);
			}
		if(icon)
			{
			bigbutton->ob_next = -1;
			fix_width();
			move_applications(1);
			icons_spec_app->no = n;
			}
		close(fh);
		}
	}


void save_app_icon(void)
	{
	int i, fh;
	unsigned long len=0;
	char inf[256]={0};

	strcpy(inf,home);
	strcat(inf,"defaults\\MyTask.ico");
	fh=(int)Fcreate(inf,0);

	if (fh<0L)
		{
		strcpy(inf,home);
		strcat(inf,"MyTask.ico");
		fh=(int)Fcreate(inf,0);
		}

	if (fh>=0L)
		{
		len = icons_spec_app->no;
		write(fh, &len, 4);
		for(i=0; i<icons_spec_app->no; i++)
			{
			write(fh, &icons_spec_app[i].obj_no, 4);
			len = strlen(icons_spec_app[i].name);
			write(fh, &len, 4);
			write(fh, icons_spec_app[i].name, len);
			}
		close(fh);
		}
	}

void delete_app_icon(int objc)
	{
	struct _icons_spec_app *tmp_icon=NULL;
	CICONBLK *icon=NULL;
	int i, j, pos_x = bigbutton[SEPARATOR_1].ob_x + ICON_DISTANCE + 2;;

	objc -= APP_ICON_1;				/* Prawdziwy nr ikonki	*/

	if(icons_spec_app)
		{
		if(icons_spec_app->no>1)
			{
			tmp_icon = calloc(1,(icons_spec_app->no-1)*sizeof(struct _icons_spec_app));
			memset(tmp_icon, 0, (icons_spec_app->no-1)*sizeof(struct _icons_spec_app));
			}

		if(icons_spec_app->no>1)
			{
			for(i=0, j=0; i<icons_spec_app->no; i++)				/* Kopiujemy ikonki te ktore musza zostac	*/
				{
				if(i!=objc)
					{
					memcpy(&tmp_icon[j], &icons_spec_app[i], sizeof(struct _icons_spec_app));
					tmp_icon[j].rsc_no = APP_ICON_1+j;
					j++;
					}
				}
			free(icons_spec_app);
			icons_spec_app = NULL;
			icons_spec_app = tmp_icon;
			icons_spec_app->no--;
			}
		else
			free(icons_spec_app);
		/* A teraz kasowanie obiektu RSC	*/
		objc += APP_ICON_1;

		icon = (CICONBLK*)bigbutton[objc].ob_spec.iconblk;
		free(icon->monoblk.ib_pdata);
		free(icon->monoblk.ib_pmask);
		free(icon->mainlist->col_data);
		free(icon->mainlist->col_mask);
		free(icon->mainlist);
		free(icon);
		bigbutton[objc].ob_spec.iconblk = 0L;
		
		if(objc==APP_ICON_1)						/* Pierwsza ikonka	*/
			{
			if(last_added_app==APP_ICON_1)
				memcpy(&bigbutton[APP_ICON_1], &bigbutton[APP_ICON_1+1], sizeof(OBJECT));
			else
				memcpy(&bigbutton[APP_ICON_1], &bigbutton[APP_ICON_1+1], sizeof(OBJECT)*(last_added_app-APP_ICON_1));
			}
		else if(objc==APP_ICON_LAST)		/* Ostatnia ikonka	*/
			{
			}
		else if(objc>=APP_ICON_1 && objc<=APP_ICON_LAST)		/* Dowolna inna ikonka	*/
			{
			if(last_added_app==objc)
				memcpy(&bigbutton[objc], &bigbutton[objc+1], sizeof(OBJECT));
			else
				memcpy(&bigbutton[objc], &bigbutton[objc+1], sizeof(OBJECT)*(last_added_app-objc));
			}
		for(i=APP_ICON_1; i<=last_added_app;i++)
			{
			if(bigbutton[i].ob_spec.iconblk!=0L)
				{
				icons_spec_app[i-APP_ICON_1].pos_x = pos_x+ICON_FULL_WIDTH;
				bigbutton[i].ob_x = pos_x;			pos_x += ICON_FULL_WIDTH;
				bigbutton[i].ob_next = i+1;
				}
			}
		i--;
		memset(&bigbutton[i], 0, sizeof(OBJECT));
		bigbutton[i-1].ob_next = 0;
		if(first_added_tray==0)
			bigbutton->ob_tail--;
		else
			bigbutton[i-1].ob_next = first_added_tray;
		last_added_app--;
		icons_app.how_many--;
		icons_app.last_pos_x = bigbutton[i-1].ob_x;
		}
	save_app_icon();
	fix_width();
	move_applications(-1);
	}


void swap_icon_app(struct _icons_spec_app *tmp1, struct _icons_spec_app *tmp2)
	{
	struct _icons_spec_app tmp;
	OBJECT tmp_rsc;
	int tmp_next, tmp_pos_x;

	memcpy(&tmp, tmp1, sizeof(struct _icons_spec_app));
	memcpy(tmp1, tmp2, sizeof(struct _icons_spec_app));
	memcpy(tmp2, &tmp, sizeof(struct _icons_spec_app));

	tmp_next = bigbutton[tmp1->rsc_no].ob_next;
	tmp_pos_x = bigbutton[tmp1->rsc_no].ob_x;
	memcpy(&tmp_rsc, &bigbutton[tmp1->rsc_no], sizeof(OBJECT));
	memcpy(&bigbutton[tmp1->rsc_no], &bigbutton[tmp2->rsc_no], sizeof(OBJECT));
	memcpy(&bigbutton[tmp2->rsc_no], &tmp_rsc, sizeof(OBJECT));

	bigbutton[tmp1->rsc_no].ob_next = bigbutton[tmp2->rsc_no].ob_next;
	bigbutton[tmp1->rsc_no].ob_x = bigbutton[tmp2->rsc_no].ob_x;
	bigbutton[tmp2->rsc_no].ob_next = tmp_next;
	bigbutton[tmp2->rsc_no].ob_x = tmp_pos_x;
	}


int add_icon_app(char *name, int save)
	{
	struct _icons_spec_app *tmp_icon=NULL;
	char *mono_mask, *mono_data, *col_mask, *col_data;
	CICONBLK *icon=NULL;

	if(icons_spec_app==NULL)
		tmp_icon = icons_spec_app = calloc(1,sizeof(struct _icons_spec_app));
	else
		{
		tmp_icon = calloc(1,sizeof(struct _icons_spec_app)*(icons_spec_app->no+1L));
		memcpy(tmp_icon, icons_spec_app, sizeof(struct _icons_spec_app) * icons_spec_app->no);
		free(icons_spec_app);
		icons_spec_app = tmp_icon;
		tmp_icon = &icons_spec_app[icons_spec_app->no];
		}

	memset(tmp_icon, 0, sizeof(struct _icons_spec_app));
	tmp_icon->name = calloc(1,strlen(name)+1L);
	memset(tmp_icon->name, 0, strlen(name)+1);
	strcpy(tmp_icon->name, name);
	icons_app.how_many++;

	if(options.stic && stic)
		{
		OBJECT *tmp=NULL;
		int i=(int)strlen(name);
		for(; i>0, name[i]!='\\'; i--)
			;
		tmp = stic->str_icon(&name[++i], STIC_SMALL);
		if(tmp)
			icon = (CICONBLK*)(tmp->ob_spec.ciconblk);
		else
			{
			tmp = stic->str_icon("*.APP", STIC_SMALL|DEFAULT_APP);
			if(tmp)
				icon = (CICONBLK*)(tmp->ob_spec.ciconblk);
			else
				{
				tmp_icon->obj_no = dialog(mini_icons, 1);
				icon = (CICONBLK*)(mini_icons[tmp_icon->obj_no].ob_spec.ciconblk);
				}
			}
		}
	else if(mini_icons!=NULL)
		{
		tmp_icon->obj_no = dialog(mini_icons, 1);
		icon = (CICONBLK*)(mini_icons[tmp_icon->obj_no].ob_spec.ciconblk);
		}
	mono_data = (char*)icon->monoblk.ib_pdata;
	mono_mask = (char*)icon->monoblk.ib_pmask;
	col_data = (char*)icon->mainlist->col_data;
	col_mask = (char*)icon->mainlist->col_mask;

	if(add_icon((void *)icons_spec_app, APP_TRAY, icons_app.how_many, mono_data, mono_mask, col_data, col_mask)==0)
		return(0);
	fix_width();
	move_applications(1);

	_redraw_.type |= RED_ICON_APP;
	_redraw_.x = min0(_redraw_.x, bigbutton[SEPARATOR_1].ob_x);
	_redraw_.y = min0(_redraw_.y, bigbutton->ob_y);
	_redraw_.w = min0(_redraw_.w, bigbutton[SEPARATOR_2].ob_x+10);
	_redraw_.h = min0(_redraw_.h, bigbutton->ob_height);
	SendAV(ap_id, WM_REDRAW, ap_id, RED_ICON, MyTask.whandle, bigbutton[SEPARATOR_1].ob_x, bigbutton->ob_y, bigbutton[SEPARATOR_2].ob_x+10, bigbutton->ob_height);

	if(save==1)
		save_app_icon();

	return(1);
	}


void info_app_icon(int objc, int button, int mx, int my)
	{
	struct _icons_spec_app *tmp_icon=NULL;
	MENU menu,msel;
	int  ret, i;
	CICONBLK *icon=NULL, *icon1=NULL;
	char *title=NULL;

	for(i=0; i<icons_spec_app->no; i++)
		{
		if(icons_spec_app[i].rsc_no == objc)
			{
			tmp_icon = &icons_spec_app[i];
			break;
			}
		}

	if(icons_spec_app[i].name[strlen(icons_spec_app[i].name)-1]!='\\')
		{
		title = &icons_spec_app[i].name[strlen(icons_spec_app[i].name)-1];
		while((*title)!='\\')
			title--;
		title++;
		}
	else
		title = icons_spec_app[i].name;
	popup_app_icon[1].ob_spec.free_string = (char*)title;
	menu.mn_tree     = popup_app_icon;
	menu.mn_menu     = ROOT;
	menu.mn_item     = 1;
	menu.mn_scroll   = 0;
	menu.mn_keystate = 0;

/*	if (stic)
		ret=stic->menu_popup(&menu,mx,my,&msel);
	else	*/
		ret = mt_menu_popup(&menu, mx, my, &msel, (short*)&_GemParBlk.global[0]);

	if(ret==0)
		return;

	if(msel.mn_item==2)				/* Skasowac ikonke	*/
		delete_app_icon(objc);
	else if(msel.mn_item==3)				/* Nowa ikonka	*/
		{
		tmp_icon->obj_no = dialog(mini_icons, 1);
		save_app_icon();
		icon1 = (CICONBLK*)(bigbutton[objc].ob_spec.ciconblk);

		icon = (CICONBLK*)(mini_icons[tmp_icon->obj_no].ob_spec.ciconblk);
		memcpy(icon1, icon, sizeof(CICONBLK));
		}
	else if(msel.mn_item==4)				/* Nowa lokalizacja	*/
		{
		short but;
		char cos[1000], file[1000]="*.*";
		strcpy(cos, icons_spec_app[objc-APP_ICON_1].name);
		while(cos[strlen(cos)-1]!='\\')
			cos[strlen(cos)-1] = 0;
		mt_fsel_exinput(cos, file, &but, fseltitle, (short*)&_GemParBlk.global[0]);
		if(but==1)
			{
			if(strcmp(&cos[strlen(cos)-4], "*.*"))
				cos[strlen(cos)-3] = 0;
			strcat(cos, file);
			free(icons_spec_app[objc-APP_ICON_1].name);
			icons_spec_app[objc-APP_ICON_1].name = calloc(1,strlen(cos)+1L);
			strcpy(icons_spec_app[objc-APP_ICON_1].name, cos);
			}
		}

	SendAV(ap_id, WM_REDRAW, ap_id, RED_ICON_INFO, MyTask.whandle, bigbutton->ob_x, bigbutton->ob_y, bigbutton->ob_width, bigbutton->ob_height);
	}


void move_icon(int icon_no)
	{
	short dummy,bstate,mx,my,i;
	short cx,cy,cw,ch,fx,fy;
	
	mt_evnt_timer(10,0);
	mt_graf_mkstate(&mx,&my,&bstate,&dummy, (short*)&_GemParBlk.global[0]);
	mt_graf_mouse(FLAT_HAND,NULL, (short*)&_GemParBlk.global[0]);

	mt_wind_get(MyTask.whandle,WF_WORKXYWH,&cx,&cy,&cw,&ch, (short*)&_GemParBlk.global[0]);
	cx=bigbutton[icon_no].ob_x; cy=bigbutton[icon_no].ob_y;
	cw=4; ch= bigbutton->ob_height;
		
	if (mt_graf_dragbox(cw,ch,cx,cy, bigbutton[APP_ICON_1].ob_x, bigbutton->ob_y, abs(bigbutton[SEPARATOR_2].ob_x-bigbutton[APP_ICON_1].ob_x), bigbutton->ob_height, &fx,&fy, (short*)&_GemParBlk.global[0]))
		{
		for(i=0; i<(APP_ICON_LAST-APP_ICON_1); i++)
			{
			if(fx>bigbutton[i+APP_ICON_1].ob_x && fx<=bigbutton[i+1+APP_ICON_1].ob_x)
				{
				struct _icons_spec_app tmp;
				int ile = (icon_no-APP_ICON_1) - (i+1), j;
				long tmp_obspec=bigbutton[icon_no].ob_spec.index;
				memcpy(&tmp, &icons_spec_app[icon_no-APP_ICON_1], sizeof(struct _icons_spec_app));
				memcpy(&icons_spec_app[i+2], &icons_spec_app[i+1], ile*sizeof(struct _icons_spec_app));
				memcpy(&icons_spec_app[i+1], &tmp, sizeof(struct _icons_spec_app));
				printf("Ikonka %s bedzie umieszczona miedzy: %s a %s (%d)\r\n", tmp.name, icons_spec_app[i].name, icons_spec_app[i+1].name, ile);
				tmp.rsc_no = icons_spec_app[i].rsc_no+1;
				for(j=0; j<icons_spec_app->no; j++)
					{
					icons_spec_app[j].rsc_no = APP_ICON_1 + j;
					}
				/* Teraz tutaj trzeba przesunac przyciski w odpowiednie miejsca!	*/
				for(j=icon_no; j>(i+APP_ICON_1+1); j--)
					{
					memcpy(&bigbutton[j].ob_spec, &bigbutton[j-1].ob_spec, sizeof(OBSPEC));
					}
				bigbutton[APP_ICON_1+i+1].ob_spec.index = tmp_obspec;
				redraw(0, bigbutton->ob_x + bigbutton[APP_ICON_1+i+1].ob_x, bigbutton->ob_y, 40*ile, bigbutton->ob_height, "move icon");

				break;
				}
			}
		}
	mt_graf_mouse(ARROW,NULL, (short*)&_GemParBlk.global[0]);
	}