#include "SuJi_glo.h"

struct D_INFO dialog_maske={MASKE_DIALOG,0l,-1,-1,0,0,-1,NULL};

DIALOG *maske_dialog=0l;

XTED xted_maske={
	"__________________________________________________"
	"__________________________________________________",
	"\0_________________________________________________"
	"__________________________________________________",
	0,0};

XTED xted_inhalt={
	"__________________________________________________"
	"__________________________________________________",
	"\0_________________________________________________"
	"__________________________________________________",
	0,0};

EVNT events;

int slider_cntrl[9]={ENTRIES_BACK,VSL_UP,VSL_DOWN,VSL_BACK,VSL_SLIDER,HSL_LEFT,HSL_RIGHT,HSL_BACK,HSL_SLIDER};
int slider_objs[]={ENTRY_1,ENTRY_2,ENTRY_3,ENTRY_4};

	/* Workaround fÅr Probleme von Freedom mit den Fenster-Dialogen */
struct {
	int freedom_workaround;

	DIALOG *dialog;
	EVNT *events;
	int obj;
	int clicks;
	void *data;
} freedom_workaround={0};
int handle_freedom_workaround(DIALOG *dialog,EVNT *events,int obj,int clicks,void *data);


#pragma warn -par
int	cdecl set_str_item(void *box,OBJECT *tree,struct _lbox_item *item,int obj_index,void *user_data,GRECT *rect,int first)
{
	char *ptext;
	char *str;

	ptext=((TEDINFO *)tree[obj_index].ob_spec.userblk->ub_parm)->te_ptext;

	if(item)
	{
		if(((struct pfadkette *)item)->selected)
			tree[obj_index].ob_state |= SELECTED;
		else
			tree[obj_index].ob_state &= ~SELECTED;

		str=((struct pfadkette *)item)->pfad;

		if(first == 0)
		{
			if(*ptext)
				*ptext++ = ' ';											/* vorangestelltes Leerzeichen */
		}
		else
			first -= 1;

		if(first <= strlen(str))
		{
			str+=first;

			while(*ptext && *str)
				*ptext++ = *str++;
		}
	}
	else
		tree[obj_index].ob_state &= ~SELECTED;

	while(*ptext)
		*ptext++ = ' ';

	return(obj_index);
}

void cdecl slct_entry(void *box,OBJECT *tree,struct pfadkette *item,void *user_data,int obj_index,int last_state)
{
	if(mt_lbox_get_slct_idx(box,&global)==-1)
	{
		if(!(tree[LIST_KILL].ob_state & DISABLED))
		{
			tree[LIST_KILL].ob_state|=DISABLED;
			redraw_objc(maske_dialog,LIST_KILL);
		}
		if(!(tree[LIST_CHANGE].ob_state & DISABLED))
		{
			tree[LIST_CHANGE].ob_state|=DISABLED;
			redraw_objc(maske_dialog,LIST_CHANGE);
		}
	}
	else
	{
		struct pfadkette *help;
		int deselektierte,selektierte;

		help=(struct pfadkette *)mt_lbox_get_items(box,&global);

		if(help)
			deselektierte=count_deselected(help);
		else
			deselektierte=0;

		if((tree[LIST_KILL].ob_state & DISABLED) &&
			deselektierte)
		{
			tree[LIST_KILL].ob_state&=~DISABLED;
			redraw_objc(maske_dialog,LIST_KILL);
		}

		if(!(tree[LIST_KILL].ob_state & DISABLED) &&
			!deselektierte)
		{
			tree[LIST_KILL].ob_state |= DISABLED;
			redraw_objc(maske_dialog,LIST_KILL);
		}

		if(help)
			selektierte=count_selected(help);
		else
			selektierte=0;

		if((tree[LIST_CHANGE].ob_state & DISABLED) &&
			selektierte==1)
		{
			tree[LIST_CHANGE].ob_state&=~DISABLED;
			redraw_objc(maske_dialog,LIST_CHANGE);
		}

		if(!(tree[LIST_CHANGE].ob_state & DISABLED) &&
			selektierte!=1)
		{
			tree[LIST_CHANGE].ob_state |= DISABLED;
			redraw_objc(maske_dialog,LIST_CHANGE);
		}

	}

	return ;
}

int cdecl handle_exit(DIALOG *dialog,EVNT *events,int obj,int clicks,void *data)
{
	if(obj==HNDL_CLSD)
	{
		suji.maske=NULL;
		return 0;
	}

	if(obj==LIST_ADD ||
		obj==LIST_CHANGE ||
		obj==MASKE_INFO_SW ||
		obj==MASKE_INFO_FARBE ||
		obj==MASKE_HELP_SW ||
		obj==MASKE_HELP_FARBE ||
		obj==MASKE_BIGGER ||
		obj==MASKE_SMALLER ||
		obj==MASKE_JUNGER ||
		obj==MASKE_OLDER ||
		obj==OPEN_LIST ||
		obj==CLOSE_LIST ||
		obj==LIST_KILL ||
		obj==MASKE_OK ||
		obj==MASKE_ABB ||
		(dialog_maske.slider && obj>0))
	{ /* Workaround fÅr Probleme von Freedom mit den Fenster-Dialogen */
		freedom_workaround.freedom_workaround=1;

		freedom_workaround.dialog=dialog;
		freedom_workaround.events=events;
		freedom_workaround.obj=obj;
		freedom_workaround.clicks=clicks;
		freedom_workaround.data=data;
	}

	return 1;
}
#pragma warn .par

void redraw_objc(DIALOG *dialog,int obj)
{
	GRECT r;

	if(maske_dialog)
	{
		mt_wind_update(BEG_UPDATE,&global);
		mt_wdlg_get_tree(dialog,&dialog_maske.tree,&r,&global);

		mt_wdlg_redraw(dialog,&r,obj,MAX_DEPTH,&global);
		mt_wind_update(END_UPDATE,&global);
	}
	else
	{
		int x,y,x_dif,y_dif;

		x=dialog_maske.tree[0].ob_x;
		y=dialog_maske.tree[0].ob_y;

		mt_form_center_grect(dialog_maske.tree,&r,&global);

		x_dif=r.g_x-dialog_maske.tree[0].ob_x;
		y_dif=r.g_y-dialog_maske.tree[0].ob_y;

		dialog_maske.tree[0].ob_x=x;
		dialog_maske.tree[0].ob_y=y;

		r.g_x=x+x_dif;
		r.g_y=y+y_dif;

		mt_objc_draw_grect(dialog_maske.tree,obj,MAX_DEPTH,&r,&global);
	}
}

int passt_auf_den_bildschirm(int baum)
{
	int wx,wy,ww,wh;
	OBJECT *tree;

	mt_rsrc_gaddr(0,baum,&tree,&global);

	mt_wind_get(0,WF_WORKXYWH,&wx,&wy,&ww,&wh,&global);

	return (tree[0].ob_width<=ww && tree[0].ob_height<=wh);
}

void clr_or_set_dialog_titel(int clr_set,OBJECT *tree,int obj)
{
	register int i;
	register int y;
	register int z;

	y=tree[obj].ob_x+tree[obj].ob_height;

	z=tree[obj].ob_flags & HIDETREE;

	if((!clr_set && z) || (clr_set && !z))
		return ;

	if(z)
		tree[obj].ob_flags&=~HIDETREE;
	else
		tree[obj].ob_flags|=HIDETREE;

	i=tree[0].ob_head;
	do {
		if(i!=obj)
		{
			if(z)
				tree[i].ob_y+=y;
			else
				tree[i].ob_y-=y;
		}

		i=tree[i].ob_next;
	} while(i!=-1);

	if(z)
		tree[0].ob_height+=y;
	else
		tree[0].ob_height-=y;
}

int my_sscanf(char *woher,int *a,int *b,int *c)
{
	int ret=0,i;
	char teil[3][5];

	teil[0][0]=woher[0];
	teil[0][1]=woher[1];
	teil[0][2]='\0';

	teil[1][0]=woher[2];
	teil[1][1]=woher[3];
	teil[1][2]='\0';

	teil[2][0]=woher[4];
	teil[2][1]=woher[5];
	teil[2][2]=woher[6];
	teil[2][3]=woher[7];
	teil[2][4]='\0';

	if(teil[2][0]!='\0')
		ret=3;
	if(teil[1][1]=='\0' || teil[2][0]=='\0')
		ret=2;
	if(teil[0][1]=='\0' || teil[1][0]=='\0')
		ret=1;

	switch(ret)
	{
		case 3:
			i=0;
			while((teil[2][i]<'0' || teil[2][i]>'9') && teil[2][i]!='\0')
				i++;

			*c=0;
			while(teil[2][i]>='0' && teil[2][i]<='9')
			{
				(*c)*=10;
				(*c)+=teil[2][i]-'0';
				i++;
			}
		case 2:
			i=0;
			while((teil[1][i]<'0' || teil[1][i]>'9') && teil[1][i]!='\0')
				i++;

			*b=0;
			while(teil[1][i]>='0' && teil[1][i]<='9')
			{
				(*b)*=10;
				(*b)+=teil[1][i]-'0';
				i++;
			}
		case 1:
			i=0;
			while((teil[0][i]<'0' || teil[0][i]>'9') && teil[0][i]!='\0')
				i++;

			*a=0;
			while(teil[0][i]>='0' && teil[0][i]<='9')
			{
				(*a)*=10;
				(*a)+=teil[0][i]-'0';
				i++;
			}
	}

	return ret;
}

#pragma warn -par
int handle_freedom_workaround(DIALOG *dialog,EVNT *events,int obj,int clicks,void *data)
{
	if(dialog_maske.slider && obj>0)
		mt_lbox_do(dialog_maske.slider,obj & ~0x8000,&global);

	if(obj==LIST_ADD)
	{
		struct pfadkette *help;

		switch(add_a_new_path(&suji,NULL))
		{
			case 0: /* Alles OK */
				mt_lbox_set_items(dialog_maske.slider,suji.search_pfade,&global);
				mt_lbox_set_asldr(dialog_maske.slider,lbox_get_slct_idx(dialog_maske.slider),NULL,&global);
				redraw_objc(maske_dialog,VSL_BACK);

				mt_lbox_set_bentries(dialog_maske.slider,get_max_breite_pfade(suji.search_pfade)+2 /* Leerzeichen */,&global);
				mt_lbox_set_bsldr(dialog_maske.slider,lbox_get_bfirst(dialog_maske.slider),NULL,&global);
				redraw_objc(maske_dialog,HSL_BACK);

				mt_lbox_update(dialog_maske.slider,(GRECT *) &(dialog_maske.tree[0].ob_x),&global);

				help=(struct pfadkette *)mt_lbox_get_items(dialog_maske.slider,&global);
				if(help && count_deselected(help))
					dialog_maske.tree[LIST_KILL].ob_state &= ~DISABLED;
				redraw_objc(maske_dialog,LIST_KILL);

				dialog_maske.tree[LIST_CHANGE].ob_state |= DISABLED;
				if(help && count_selected(help)==1)
					dialog_maske.tree[LIST_CHANGE].ob_state &= ~DISABLED;
				redraw_objc(maske_dialog,LIST_CHANGE);
				break;
			case 1: /* Speichermangel */
				mt_rsrc_gaddr(5,ERR_NO_MEM,&alert,&global);
				mt_form_alert(1,alert,&global);
				break;
			case 2: /* fsel_(ex)input-Fehler */
				mt_rsrc_gaddr(5,ERR_FSEL_BOX,&alert,&global);
				mt_form_alert(1,alert,&global);
				break;
		}


		dialog_maske.tree[LIST_ADD].ob_state &= ~SELECTED;
		redraw_objc(maske_dialog,LIST_ADD);
	}

	if(obj==LIST_CHANGE)
	{
		struct pfadkette *help;

		help=(struct pfadkette *)mt_lbox_get_slct_item(dialog_maske.slider,&global);

		if(help)
		{
			switch(change_a_path(&suji,help))
			{
				case 0: /* Alles OK */
					mt_lbox_set_items(dialog_maske.slider,suji.search_pfade,&global);
					mt_lbox_set_asldr(dialog_maske.slider,lbox_get_slct_idx(dialog_maske.slider),NULL,&global);
					redraw_objc(maske_dialog,VSL_BACK);
	
					mt_lbox_set_bentries(dialog_maske.slider,get_max_breite_pfade(suji.search_pfade)+2 /* Leerzeichen */,&global);
					mt_lbox_set_bsldr(dialog_maske.slider,lbox_get_bfirst(dialog_maske.slider),NULL,&global);
					redraw_objc(maske_dialog,HSL_BACK);
	
					mt_lbox_update(dialog_maske.slider,(GRECT *) &(dialog_maske.tree[0].ob_x),&global);
	
					help=(struct pfadkette *)mt_lbox_get_items(dialog_maske.slider,&global);
					if(help && count_deselected(help))
						dialog_maske.tree[LIST_KILL].ob_state &= ~DISABLED;
					redraw_objc(maske_dialog,LIST_KILL);
	
					dialog_maske.tree[LIST_CHANGE].ob_state |= DISABLED;
					if(help && count_selected(help)==1)
						dialog_maske.tree[LIST_CHANGE].ob_state &= ~DISABLED;
					redraw_objc(maske_dialog,LIST_CHANGE);
					break;
				case 1: /* Speichermangel */
					mt_rsrc_gaddr(5,ERR_NO_MEM,&alert,&global);
					mt_form_alert(1,alert,&global);
					break;
				case 2: /* fsel_(ex)input-Fehler */
					mt_rsrc_gaddr(5,ERR_FSEL_BOX,&alert,&global);
					mt_form_alert(1,alert,&global);
					break;
			}
		}

		dialog_maske.tree[LIST_KILL].ob_state |= DISABLED;

		help=(struct pfadkette *)mt_lbox_get_items(dialog_maske.slider,&global);
		if(help && count_deselected(help))
			dialog_maske.tree[LIST_KILL].ob_state &= ~DISABLED;

		redraw_objc(maske_dialog,LIST_KILL);

		dialog_maske.tree[LIST_CHANGE].ob_state &= ~SELECTED;

		redraw_objc(maske_dialog,LIST_CHANGE);
	}

	if(obj==MASKE_INFO_SW || obj==MASKE_INFO_FARBE)
	{
		/* modalen Infodialog anzeigen */
		void *flydial;
		int button;
		OBJECT *tree;
		GRECT big;
		GRECT little;
		int diff_x,diff_y;

		mt_rsrc_gaddr(0,INFO_DIALOG,&tree,&global);

		tree[INFO_VERSION].ob_spec.tedinfo->te_ptext[0]=versionsnummernstring[1];
		tree[INFO_VERSION].ob_spec.tedinfo->te_ptext[1]=versionsnummernstring[3];
		tree[INFO_VERSION].ob_spec.tedinfo->te_ptext[2]=versionsnummernstring[4];

		mt_objc_offset(dialog_maske.tree,MASKE_INFO_SW,&little.g_x,&little.g_y,&global);
		little.g_w=dialog_maske.tree[MASKE_INFO_SW].ob_width;
		little.g_h=dialog_maske.tree[MASKE_INFO_SW].ob_height;

		mt_form_center_grect(tree,&big,&global);
		diff_x=tree[0].ob_x-big.g_x;
		diff_y=tree[0].ob_y-big.g_y;

		mt_wind_update(BEG_MCTRL,&global);
		mt_form_xdial_grect(FMD_START,&big,&big,&flydial,&global);
		mt_form_xdial_grect(FMD_GROW,&little,&big,&flydial,&global);

		mt_objc_draw_grect(tree,ROOT,MAX_DEPTH,&big,&global);

		do {
			button=mt_form_xdo(tree,0,&i,NULL,flydial,&global) & 0x7fff;
		} while(button!=INFO_OK);

		tree[button].ob_state&=~SELECTED;

		mt_objc_offset(tree,0,&big.g_x,&big.g_y,&global);
		big.g_x-=diff_x;
		big.g_y-=diff_y;

		mt_form_xdial_grect(FMD_SHRINK,&little,&big,&flydial,&global);
		mt_form_xdial_grect(FMD_FINISH,&big,&big,&flydial,&global);
		mt_wind_update(END_MCTRL,&global);

		redraw_objc(maske_dialog,0);
	}

	if(obj==MASKE_HELP_SW || obj==MASKE_HELP_FARBE)
	{
		int stg_id;

		stg_id=mt_appl_find("ST-GUIDE",&global);
		if(stg_id>=0)
		{
			int buffer[8];

			buffer[0]=VA_START;
			buffer[1]=ap_id;
			buffer[2]=0;
			buffer[3]=(int) ((((long) help_str_dialog) & 0xffff0000l)>>16);
			buffer[4]=(int) (((long) help_str_dialog) & 0xffff);
			mt_appl_write(stg_id,16,buffer,&global);
		}
		else
		{
			mt_rsrc_gaddr(5,ERR_NO_ST_GUIDE,&alert,&global);
			mt_form_alert(1,alert,&global);
		}
	}

	if(obj==MASKE_BIGGER)
	{
		if(dialog_maske.tree[MASKE_BIGGER].ob_state & SELECTED)
		{
			dialog_maske.tree[MB_EDIT].ob_state&=~DISABLED;
			dialog_maske.tree[MB_EDIT].ob_flags|=EDITABLE;
		}
		else
		{
			dialog_maske.tree[MB_EDIT].ob_state|=DISABLED;
			dialog_maske.tree[MB_EDIT].ob_flags&=~EDITABLE;

			if(maske_dialog)
			{
				i=mt_wdlg_get_edit(dialog,&i,&global);
				if(!i || i==MB_EDIT)
					mt_wdlg_set_edit(dialog,MASKE_EDIT,&global);
			}
		}

		redraw_objc(dialog,MB_EDIT);
		redraw_objc(dialog,MS_EDIT);
	}

	if(obj==MASKE_SMALLER)
	{
		if(dialog_maske.tree[MASKE_SMALLER].ob_state & SELECTED)
		{
			dialog_maske.tree[MS_EDIT].ob_state&=~DISABLED;
			dialog_maske.tree[MS_EDIT].ob_flags|=EDITABLE;
		}
		else
		{
			dialog_maske.tree[MS_EDIT].ob_state|=DISABLED;
			dialog_maske.tree[MS_EDIT].ob_flags&=~EDITABLE;

			if(maske_dialog)
			{
				i=mt_wdlg_get_edit(dialog,&i,&global);
				if(!i || i==MS_EDIT)
					mt_wdlg_set_edit(dialog,MASKE_EDIT,&global);
			}
		}

		redraw_objc(dialog,MB_EDIT);
		redraw_objc(dialog,MS_EDIT);
	}

	if(obj==MASKE_JUNGER)
	{
		if(dialog_maske.tree[MASKE_JUNGER].ob_state & SELECTED)
		{
			dialog_maske.tree[MJ_EDIT].ob_state&=~DISABLED;
			dialog_maske.tree[MJ_EDIT].ob_flags|=EDITABLE;
		}
		else
		{
			dialog_maske.tree[MJ_EDIT].ob_state|=DISABLED;
			dialog_maske.tree[MJ_EDIT].ob_flags&=~EDITABLE;

			if(maske_dialog)
			{
				i=mt_wdlg_get_edit(dialog,&i,&global);
				if(!i || i==MJ_EDIT)
					mt_wdlg_set_edit(dialog,MASKE_EDIT,&global);
			}
		}

		redraw_objc(dialog,MJ_EDIT);
		redraw_objc(dialog,MO_EDIT);
	}

	if(obj==MASKE_OLDER)
	{
		if(dialog_maske.tree[MASKE_OLDER].ob_state & SELECTED)
		{
			dialog_maske.tree[MO_EDIT].ob_state&=~DISABLED;
			dialog_maske.tree[MO_EDIT].ob_flags|=EDITABLE;
		}
		else
		{
			dialog_maske.tree[MO_EDIT].ob_state|=DISABLED;
			dialog_maske.tree[MO_EDIT].ob_flags&=~EDITABLE;

			if(maske_dialog)
			{
				i=mt_wdlg_get_edit(dialog,&i,&global);
				if(!i || i==MO_EDIT)
					mt_wdlg_set_edit(dialog,MASKE_EDIT,&global);
			}
		}

		redraw_objc(dialog,MJ_EDIT);
		redraw_objc(dialog,MO_EDIT);
	}

	if(obj==OPEN_LIST)
	{
		GRECT r;
		struct pfadkette *help;

		dialog_maske.tree[OPEN_LIST].ob_flags |= HIDETREE;
		dialog_maske.tree[CLOSE_LIST].ob_flags &= ~HIDETREE;

		dialog_maske.tree[LIST_ROOM].ob_flags &= ~HIDETREE;
		dialog_maske.tree[0].ob_height+=dialog_maske.tree[LIST_ROOM].ob_height;

		mt_wdlg_set_size(maske_dialog,(GRECT *)&(dialog_maske.tree[0].ob_x),&global);

		dialog_maske.tree[LIST_KILL].ob_state |= DISABLED;

		help=(struct pfadkette *)mt_lbox_get_items(dialog_maske.slider,&global);
		if(help && count_deselected(help) && mt_lbox_get_slct_item(dialog_maske.slider,&global))
			dialog_maske.tree[LIST_KILL].ob_state &= ~DISABLED;

		dialog_maske.tree[LIST_CHANGE].ob_state |= DISABLED;

		if(help && count_selected(help)==1)
			dialog_maske.tree[LIST_CHANGE].ob_state &= ~DISABLED;

		dialog_maske.tree[LIST_ADD].ob_state &= ~DISABLED;

			/* Bereich ab dem Dreieck neu zeichnen */
		mt_wind_update(BEG_UPDATE,&global);

		mt_wdlg_get_tree(dialog,&dialog_maske.tree,&r,&global);

		r.g_h -= dialog_maske.tree[CLOSE_LIST].ob_y;
		r.g_y += dialog_maske.tree[CLOSE_LIST].ob_y;

		mt_wdlg_redraw(dialog,&r,0,MAX_DEPTH,&global);
		mt_wind_update(END_UPDATE,&global);
	}

	if(obj==CLOSE_LIST)
	{
		GRECT r;

		dialog_maske.tree[OPEN_LIST].ob_flags &= ~HIDETREE;
		dialog_maske.tree[CLOSE_LIST].ob_flags |= HIDETREE;

		dialog_maske.tree[LIST_ROOM].ob_flags |= HIDETREE;
		dialog_maske.tree[0].ob_height-=dialog_maske.tree[LIST_ROOM].ob_height;

		dialog_maske.tree[LIST_KILL].ob_state |= DISABLED;
		dialog_maske.tree[LIST_CHANGE].ob_state |= DISABLED;
		dialog_maske.tree[LIST_ADD].ob_state |= DISABLED;

		mt_wdlg_set_size(maske_dialog,(GRECT *)&(dialog_maske.tree[0].ob_x),&global);

			/* Bereich ab dem Dreieck neu zeichnen */
		mt_wind_update(BEG_UPDATE,&global);

		mt_wdlg_get_tree(dialog,&dialog_maske.tree,&r,&global);

		r.g_h -= dialog_maske.tree[CLOSE_LIST].ob_y;
		r.g_y += dialog_maske.tree[CLOSE_LIST].ob_y;

		mt_wdlg_redraw(dialog,&r,0,MAX_DEPTH,&global);
		mt_wind_update(END_UPDATE,&global);
	}

	if(obj==LIST_KILL)
	{
		struct pfadkette *help;

		if(remove_selected_paths(&suji))
		{ /* Alle selectiert -> geht nicht */
			mt_rsrc_gaddr(5,ERR_MIN_ONE,&alert,&global);
			mt_form_alert(1,alert,&global);
		}
		else
		{ /* Alles ok */
			mt_lbox_set_items(dialog_maske.slider,suji.search_pfade,&global);
			mt_lbox_set_asldr(dialog_maske.slider,lbox_get_afirst(dialog_maske.slider),NULL,&global);
			redraw_objc(maske_dialog,VSL_BACK);
	
			mt_lbox_set_bentries(dialog_maske.slider,get_max_breite_pfade(suji.search_pfade)+2 /* Leerzeichen */,&global);
			mt_lbox_set_bsldr(dialog_maske.slider,lbox_get_bfirst(dialog_maske.slider),NULL,&global);
			redraw_objc(maske_dialog,HSL_BACK);
	
			mt_lbox_update(dialog_maske.slider,(GRECT *) &(dialog_maske.tree[0].ob_x),&global);
		}

		dialog_maske.tree[LIST_KILL].ob_state &= ~SELECTED;

		if(!mt_lbox_get_slct_item(dialog_maske.slider,&global))
			dialog_maske.tree[LIST_KILL].ob_state |= DISABLED;

		redraw_objc(maske_dialog,LIST_KILL);

		dialog_maske.tree[LIST_CHANGE].ob_state |= DISABLED;

		help=(struct pfadkette *)mt_lbox_get_items(dialog_maske.slider,&global);
		if(help && count_selected(help)==1)
			dialog_maske.tree[LIST_CHANGE].ob_state &= ~DISABLED;

		redraw_objc(maske_dialog,LIST_CHANGE);
	}

	if(obj==MASKE_OK || obj==MASKE_ABB)
	{
		dialog_maske.tree[obj].ob_state&=~SELECTED;

		if(obj==MASKE_OK)
		{
			suji.maske=dialog_maske.tree[MASKE_EDIT].ob_spec.tedinfo->te_ptext;
			suji.inhalt=dialog_maske.tree[INHALT_EDIT].ob_spec.tedinfo->te_ptext;

			if(suji.maske[0]=='\0')
				suji.maske="*";

			i=test_maske(suji.maske);
			if(i)
			{
				suji.maske=NULL;

				switch(i)
				{
					case 2:
					case 3:
					case 4:
					case 5:
					case 6:
					case 7:
					case 9:
					case 10:
						mt_rsrc_gaddr(5,ERR_MASK_ROOM,&alert,&global);
						break;
					case 11:
						mt_rsrc_gaddr(5,ERR_MASK_KOMMA,&alert,&global);
						break;
					case 8:
						mt_rsrc_gaddr(5,ERR_MASK_QUOTE,&alert,&global);
						break;
				}

				mt_form_alert(1,alert,&global);

				redraw_objc(dialog,obj);

				return 1;
			}

			i=test_maske(suji.inhalt);
			if(i>1)
			{
				suji.maske=NULL;

				switch(i)
				{
					case 2:
					case 3:
					case 4:
					case 5:
					case 6:
					case 7:
					case 9:
					case 10:
						mt_rsrc_gaddr(5,ERR_MASK_ROOM,&alert,&global);
						break;
					case 11:
						mt_rsrc_gaddr(5,ERR_MASK_KOMMA,&alert,&global);
						break;
					case 8:
						mt_rsrc_gaddr(5,ERR_MASK_QUOTE,&alert,&global);
						break;
				}

				mt_form_alert(1,alert,&global);

				redraw_objc(dialog,obj);

				return 1;
			}


			suji.big_is_small_maske=dialog_maske.tree[MASKE_BS].ob_state & SELECTED;
			suji.big_is_small_inhalt=dialog_maske.tree[INHALT_BS].ob_state & SELECTED;

			if(dialog_maske.tree[MASKE_BIGGER].ob_state & SELECTED)
			{
				char *str;
				double durch=0;
				double ms=0;

				str=dialog_maske.tree[MB_EDIT].ob_spec.tedinfo->te_ptext;

				while((*str>='0' && *str<='9') || *str=='.' || *str==',')
				{
					if(*str=='.' || *str==',')
					{
						durch=1;
						str++;
					}
					else
					{
						if(durch)
							durch*=10;
						ms*=10;
						ms+=(*str++)-'0';
					}
				}

				do {
					if(*str=='k' || *str=='K')
						ms*=0x00000400l;
					if(*str=='m' || *str=='M')
						ms*=0x00100000l;
					if(*str=='g' || *str=='G')
						ms*=0x40000000l;
				} while((*str=='k' || *str=='K' ||
						*str=='m' || *str=='M' ||
						*str=='g' || *str=='G' ||
						*str=='b' || *str=='B' || *str==' ') &&
							*(++str)!='\0');

				if(durch)
				{
					if(ms/durch>0xffffffffl)
						suji.min_size=0xffffffffl;
					else
						suji.min_size=(unsigned long) ms/durch;
				}
				else
					suji.min_size=(unsigned long) ms;

				if(*str!='\0')
				{
					suji.maske=NULL;

					mt_rsrc_gaddr(5,ERR_FORM_SIZE,&alert,&global);
					mt_form_alert(1,alert,&global);

					redraw_objc(dialog,obj);

					return 1;
				}
			}
			else
				suji.min_size=0l;

			if(dialog_maske.tree[MASKE_SMALLER].ob_state & SELECTED)
			{
				char *str;
				double durch=0;
				double ms=0;

				str=dialog_maske.tree[MS_EDIT].ob_spec.tedinfo->te_ptext;

				while((*str>='0' && *str<='9') || *str=='.' || *str==',')
				{
					if(*str=='.' || *str==',')
					{
						durch=1;
						str++;
					}
					else
					{
						if(durch)
							durch*=10;
						ms*=10;
						ms+=(*str++)-'0';
					}
				}

				do {
					if(*str=='k' || *str=='K')
						ms*=0x00000400l;
					if(*str=='m' || *str=='M')
						ms*=0x00100000l;
					if(*str=='g' || *str=='G')
						ms*=0x40000000l;
				} while((*str=='k' || *str=='K' ||
						*str=='m' || *str=='M' ||
						*str=='g' || *str=='G' ||
						*str=='b' || *str=='B' || *str==' ') &&
							*(++str)!='\0');

				if(durch)
				{
					if(ms/durch>0xffffffffl)
						suji.max_size=0xffffffffl;
					else
						suji.max_size=(unsigned long) ms/durch;
				}
				else
					suji.max_size=(unsigned long) ms;

				if(*str!='\0')
				{
					suji.maske=NULL;

					mt_rsrc_gaddr(5,ERR_FORM_SIZE,&alert,&global);
					mt_form_alert(1,alert,&global);

					redraw_objc(dialog,obj);

					return 1;
				}

				if(suji.max_size==0l)
				{
					mt_rsrc_gaddr(5,ASK_ONLY_ZERO,&alert,&global);
					if(mt_form_alert(1,alert,&global)==2)
					{
						suji.maske=NULL;

						redraw_objc(dialog,obj);

						return 1;
					}
				}
			}
			else
				suji.max_size=0xffffffffl;

			if(dialog_maske.tree[MASKE_OLDER].ob_state & SELECTED)
			{
				int i,u,v,w;
				OBJECT *tree;

				i=my_sscanf(dialog_maske.tree[MO_EDIT].ob_spec.tedinfo->te_ptext,&u,&v,&w);

				if(i<1)
					u=1;
				if(i<2)
					v=1;
				if(i<3)
					w=1980;

				mt_rsrc_gaddr(0,LANGUAGE_SETTING,&tree,&global);
				if(!(tree[LS_DAY_MONTH].ob_state & SELECTED))
				{
					int x;
					x=u;
					u=v;
					v=x;
				}

				while(w>2099)
					w-=100;

				while(w<1980)
					w+=100;

				while(v>12)
					v-=12;

				if(v<1)
					v=1;
		
				while(u>31)
					u-=31;
		
				if(u<1)
					u=1;

				suji.max_date=((w-1980)*0x0200) +
								v*0x0020+
								u;
			}
			else
				suji.max_date=0xffff;

			if(dialog_maske.tree[MASKE_JUNGER].ob_state & SELECTED)
			{
				int i,u,v,w;
				OBJECT *tree;

				i=my_sscanf(dialog_maske.tree[MJ_EDIT].ob_spec.tedinfo->te_ptext,&u,&v,&w);

				if(i<1)
					u=1;
				if(i<2)
					v=1;
				if(i<3)
					w=1980;

				mt_rsrc_gaddr(0,LANGUAGE_SETTING,&tree,&global);
				if(!(tree[LS_DAY_MONTH].ob_state & SELECTED))
				{
					int x;
					x=u;
					u=v;
					v=x;
				}

				while(w>2099)
					w-=100;

				while(w<1980)
					w+=100;

				while(v>12)
					v-=12;

				if(v<1)
					v=1;
		
				while(u>31)
					u-=31;
		
				if(u<1)
					u=1;

				suji.min_date=((w-1980)*0x0200) +
								v*0x0020+
								u;
			}
			else
				suji.min_date=0;
		}

		if(obj==MASKE_ABB)
			suji.maske=NULL;

		redraw_objc(dialog,obj);

		mt_wind_get_grect( dialog_maske.w_handle, WF_WORKXYWH, (GRECT *)(&dialog_maske.x), &global );

		return 0;
	}

	return 1;
}
#pragma warn .par

void handle_dialog(void *pfade, int *x, int *y)
{
	if(mt_appl_getinfo(7,&i,NULL,NULL,NULL,&global) && (i & 2))
	{ /* Gibt es Listboxen? */
		dialog_maske.slider=mt_lbox_create(dialog_maske.tree,(SLCT_ITEM) slct_entry,(SET_ITEM) set_str_item, (void *) pfade,
										 (int) (sizeof(slider_objs)/sizeof(int)), 0, slider_cntrl, slider_objs, 
										 LBOX_VERT + LBOX_AUTO + LBOX_AUTOSLCT + LBOX_REAL + LBOX_SHFT + LBOX_2SLDRS, 
										 40,maske_dialog,maske_dialog,
										 (int) strlen(((TEDINFO *)dialog_maske.tree[ENTRY_1].ob_spec.userblk->ub_parm)->te_ptext),
										 0,get_max_breite_pfade(pfade)+2,5,&global);
	}
	else
		dialog_maske.slider=NULL;

	if(!dialog_maske.slider)
	{
		dialog_maske.tree[OPEN_LIST].ob_flags |= HIDETREE;
		dialog_maske.tree[CLOSE_LIST].ob_flags |= HIDETREE;

		dialog_maske.tree[LIST_ROOM].ob_flags |= HIDETREE;
		dialog_maske.tree[0].ob_height-=dialog_maske.tree[LIST_ROOM].ob_height;
	}
	else
	{
		dialog_maske.tree[OPEN_LIST].ob_flags &= ~HIDETREE;
		dialog_maske.tree[CLOSE_LIST].ob_flags |= HIDETREE;

		dialog_maske.tree[LIST_ROOM].ob_flags |= HIDETREE;
		dialog_maske.tree[0].ob_height-=dialog_maske.tree[LIST_ROOM].ob_height;
	}

	dialog_maske.tree[LIST_KILL].ob_state |= DISABLED;
	dialog_maske.tree[LIST_CHANGE].ob_state |= DISABLED;

	dialog_maske.x = *x;
	dialog_maske.y = *y;
	
	if(!(mt_appl_getinfo(7,&i,NULL,NULL,NULL,&global) &&	(i & 1) &&
		(maske_dialog=mt_wdlg_create(handle_exit,dialog_maske.tree,&dialog_maske,0,0,0,&global))!=0 &&
		(dialog_maske.w_handle=mt_wdlg_open(maske_dialog,alert,NAME|CLOSER|MOVER|SMALLER,dialog_maske.x,dialog_maske.y,0,&dialog_maske,&global))!=0))
	{
		/* Dialog lÑuft modal ab */
		void *flydial;
		int button;
		GRECT big;

		clr_or_set_dialog_titel(1,dialog_maske.tree,MASKE_TITEL);

		if(maske_dialog)
			mt_wdlg_delete(maske_dialog,&global);

		if(dialog_maske.slider)
		{
			mt_lbox_delete(dialog_maske.slider,&global);
			dialog_maske.slider=NULL;
		}

		dialog_maske.tree[OPEN_LIST].ob_flags |= HIDETREE;
		dialog_maske.tree[CLOSE_LIST].ob_flags |= HIDETREE;

		dialog_maske.tree[MASKE_HELP2].ob_flags |= HIDETREE;
		dialog_maske.tree[MASKE_HELP3].ob_flags |= HIDETREE;
		dialog_maske.tree[MASKE_HELP4].ob_flags |= HIDETREE;
		dialog_maske.tree[MASKE_HELP_FARBE].ob_flags |= HIDETREE;
		dialog_maske.tree[MASKE_HELP_SW].ob_flags |= HIDETREE;

		mt_form_center_grect(dialog_maske.tree,&big,&global);
		mt_wind_update(BEG_MCTRL,&global);
		mt_form_xdial_grect(FMD_START,&big,&big,&flydial,&global);
		mt_objc_draw_grect(dialog_maske.tree,ROOT,MAX_DEPTH,&big,&global);

		do {
			if(freedom_workaround.freedom_workaround)
			{
				freedom_workaround.freedom_workaround=0;

				if(handle_freedom_workaround(
					freedom_workaround.dialog,
					freedom_workaround.events,
					freedom_workaround.obj,
					freedom_workaround.clicks,
					freedom_workaround.data) == 0)
				{
					if(dialog_maske.slider)
					{
						mt_lbox_delete(dialog_maske.slider,&global);
						dialog_maske.slider=NULL;
					}
					maske_dialog=0;
					break;
				}
			}

			button=mt_form_xdo(dialog_maske.tree,0,&i,NULL,flydial,&global) & 0x7fff;
		} while(handle_exit(0l,0l,button,1,&dialog_maske)!=0);

		mt_form_xdial_grect(FMD_FINISH,&big,&big,&flydial,&global);
		mt_wind_update(END_MCTRL,&global);
	}
	else
	{
		/* Fensterdialog */
		int shaded_or_iconified=0;

		do {
			MOBLK m1blk={0},m2blk={0};

			mt_EVNT_multi(MU_KEYBD|MU_BUTTON|MU_MESAG
					,0x102,3,0
					,&m1blk,&m2blk,
					2000l,
					&events,&global);

			if(events.mwhich & MU_MESAG)
			{
				switch(events.msg[0])
				{
					case AP_DRAGDROP:
					{
						char *dd;
						dd=dragdrop(events.msg);
						if(dd)
						{
							char *add;

							add=dd;

							while(*add)
							{
								char *this;
								int in_quote=0;

								if(add[0]=='\'')
								{
									in_quote=1;
									add++;
								}

								this=add;

								while(*this)
								{
									if(in_quote && this[0]=='\'' && this[1]=='\'')
									{ /* gequotetes '\'' gefunden */
										strcpy(this,&this[1]);
									}
									if(in_quote && this[0]=='\'' && (this[1]==' ' || this[1]=='\0'))
									{
										*this='\0';
										if(this[1])
											this+=2;
										else
											this++;
										break;
									}

									if(!in_quote && *this==' ')
									{
										*this='\0';
										this++;
										break;
									}

									this++;
								}

								switch(add_a_new_path(&suji,add))
								{
									case 0: /* Alles OK */
										if(dialog_maske.slider)
										{
											struct pfadkette *help;
		
											mt_lbox_set_items(dialog_maske.slider,suji.search_pfade,&global);
											mt_lbox_set_asldr(dialog_maske.slider,lbox_get_slct_idx(dialog_maske.slider),NULL,&global);
											if(dialog_maske.tree[OPEN_LIST].ob_flags & HIDETREE)
												redraw_objc(maske_dialog,VSL_BACK);
							
											mt_lbox_set_bentries(dialog_maske.slider,get_max_breite_pfade(suji.search_pfade)+2 /* Leerzeichen */,&global);
											mt_lbox_set_bsldr(dialog_maske.slider,lbox_get_bfirst(dialog_maske.slider),NULL,&global);
											if(dialog_maske.tree[OPEN_LIST].ob_flags & HIDETREE)
												redraw_objc(maske_dialog,HSL_BACK);
	
											mt_lbox_update(dialog_maske.slider,NULL,&global);
											if(dialog_maske.tree[OPEN_LIST].ob_flags & HIDETREE)
												redraw_objc(maske_dialog,ENTRIES_BACK);
							
											help=(struct pfadkette *)mt_lbox_get_items(dialog_maske.slider,&global);
											if(help && count_deselected(help))
												dialog_maske.tree[LIST_KILL].ob_state &= ~DISABLED;
	
											if(dialog_maske.tree[OPEN_LIST].ob_flags & HIDETREE)
												redraw_objc(maske_dialog,LIST_KILL);

											if(help && count_selected(help)==1)
												dialog_maske.tree[LIST_CHANGE].ob_state &= ~DISABLED;
	
											if(dialog_maske.tree[OPEN_LIST].ob_flags & HIDETREE)
												redraw_objc(maske_dialog,LIST_CHANGE);
										}
										break;
									case 1: /* Speichermangel */
										mt_rsrc_gaddr(5,ERR_NO_MEM,&alert,&global);
										mt_form_alert(1,alert,&global);
										break;
								}
								add=this;
							}
							free(dd);
						}
						break;
					}
					case WM_SHADED:
						shaded_or_iconified|=1;
						break;
					case WM_UNSHADED:
						shaded_or_iconified&=~1;
						break;
					case WM_ICONIFY:
					case WM_ALLICONIFY:
						mt_wind_set_grect(events.msg[3],WF_ICONIFY,(GRECT *)&events.msg[4],&global);
						shaded_or_iconified|=2;
						break;
					case WM_UNICONIFY:
						mt_wind_set_grect(events.msg[3],WF_UNICONIFY,(GRECT *)&events.msg[4],&global);

						events.msg[0]=WM_MOVED;
						events.msg[1]=ap_id;
						events.msg[2]=0;
						mt_appl_write(ap_id,16,events.msg,&global);

						shaded_or_iconified&=~2;
						break;
					case WM_REDRAW:
					{
						OBJECT *tree;
						GRECT r;

							/* prÅfen, ob 3D-Darstellung geÑndert */
						reform_3d();

						if(!(shaded_or_iconified & 2))
							break;

						events.mwhich&=~MU_MESAG;

						mt_wind_update(BEG_UPDATE,&global);
						mt_wind_get_grect(events.msg[3],WF_WORKXYWH,&r,&global);

						mt_rsrc_gaddr(0,MASKE_ICONIFY,&tree,&global);
						tree[0].ob_x=r.g_x;
						tree[0].ob_y=r.g_y;
						tree[0].ob_width=r.g_w;
						tree[0].ob_height=r.g_h;

						tree[SU_ICON].ob_x=r.g_w/2-tree[SU_ICON].ob_width/2;
						tree[SU_ICON].ob_y=r.g_h/2-tree[SU_ICON].ob_height/2;

						mt_wind_get_grect(events.msg[3],WF_FIRSTXYWH,&r,&global);
						while(r.g_w && r.g_h)
						{
							mt_objc_draw_grect(tree,0,8,&r,&global);
							mt_wind_get_grect(events.msg[3],WF_NEXTXYWH,&r,&global);
						}
						mt_wind_update(END_UPDATE,&global);

						break;
					}
					case AV_SENDKEY:
						if(events.mwhich & MU_KEYBD)
						{
							mt_appl_write(ap_id,16,events.msg,&global);
						}
						else
						{
							events.mwhich|=MU_KEYBD;
							events.kstate=events.msg[3];
							events.key=events.msg[4];
						}
						break;
					case AV_SENDCLICK:
						if(events.mwhich & MU_BUTTON)
						{
							mt_appl_write(ap_id,16,events.msg,&global);
						}
						else
						{
							events.mwhich|=MU_BUTTON;
							events.mx=events.msg[3];
							events.my=events.msg[4];
							events.mbutton=events.msg[5];
							events.kstate=events.msg[6];
							events.mclicks=events.msg[7];
						}
						break;
					case AP_TERM:
						events.msg[0]=WM_CLOSED;
						events.msg[1]=ap_id;
						events.msg[2]=0;
						events.msg[3]=dialog_maske.w_handle;
						events.msg[4]=0;
						events.msg[5]=0;
						events.msg[6]=0;
						events.msg[7]=0;
						break;
					case VA_PROTOSTATUS:
						av_server=mt_appl_find((char *)(((((long) events.msg[6])<<16) & 0xffff0000l)|(((long) events.msg[7]) & 0x0000ffffl)),&global);
						if(av_server<0)
							av_server=events.msg[1];
						av_server_kennt=(long) (((((long) events.msg[3])<<16) & 0xffff0000l)|(((long) events.msg[4]) & 0x0000ffffl));

						if(av_server_kennt & 0x00020000l)
						{
							int msg[8];

							msg[0]=AV_ASKFILEFONT;
							msg[1]=ap_id;
							msg[2]=0;
							msg[3]=0;
							msg[4]=0;
							msg[5]=0;
							msg[6]=0;
							msg[7]=0;
							mt_appl_write(av_server,16,msg,&global);
						}
						break;
					case VA_FILEFONT:
					case VA_FONTCHANGED:
						set_new_font(events.msg[3],events.msg[4]);
						break;
					case BUBBLEGEM_ACK:
						if((void *) *((long *)(&(events.msg[5])))!=NULL)
							Mfree((char *) *(long *)(&(events.msg[5])));
						break;
					case BUBBLEGEM_REQUEST:
						if(events.msg[6]==0)
							bubble_hilfen(events.msg[3],events.msg[4],events.msg[5]);
						break;
				}
			}

			if(shaded_or_iconified)	/* Keine TastendrÅcke durchlassen */
			{
				events.mwhich&=~MU_KEYBD;
				events.mwhich&=~MU_BUTTON;
			}

			if(events.mwhich & MU_BUTTON)
			{
				if(events.mbutton==2 && events.kstate==0)
					bubble_hilfen(dialog_maske.w_handle,events.mx,events.my);
			}

			if(events.mwhich & MU_KEYBD)
			{
				if((events.key == TAB) &&
					(events.kstate & (K_RSHIFT|K_LSHIFT)))
				{ /* WDIALOG wertet Shift-TAB nicht aus -> in CUR_UP Ñndern */
					events.key=CUR_UP;
					events.kstate &= ~(K_RSHIFT|K_LSHIFT);
				}
				if(events.key==HELP)
				{
					int stg_id;

					stg_id=mt_appl_find("ST-GUIDE",&global);
					if(stg_id>=0)
					{
						int buffer[8];

						buffer[0]=VA_START;
						buffer[1]=ap_id;
						buffer[2]=0;
						buffer[3]=(int) ((((long) help_str_dialog) & 0xffff0000l)>>16);
						buffer[4]=(int) (((long) help_str_dialog) & 0xffff);
						mt_appl_write(stg_id,16,buffer,&global);
					}
					else
					{
						mt_rsrc_gaddr(5,ERR_NO_ST_GUIDE,&alert,&global);
						mt_form_alert(1,alert,&global);
					}

					events.mwhich &= ~MU_KEYBD;
				}

				if((events.key == CNTRL_Q) ||
					(events.key == CNTRL_U))
				{
						/* Fenster schlieûen */
					events.msg[0]=WM_CLOSED;
					events.msg[1]=ap_id;
					events.msg[2]=0;
					events.msg[3]=dialog_maske.w_handle;
					events.msg[4]=0;
					events.msg[5]=0;
					events.msg[6]=0;
					events.msg[7]=0;

						/* Tastendruck -> Message */
					events.mwhich &= ~MU_KEYBD;
					events.mwhich |= MU_MESAG;
				}
			}

			if(mt_wdlg_evnt(maske_dialog,&events,&global)==0)
			{
				if(dialog_maske.slider)
				{
					mt_lbox_delete(dialog_maske.slider,&global);
					dialog_maske.slider=NULL;
				}
				mt_wdlg_close(maske_dialog,NULL,NULL,&global);
				mt_wdlg_delete(maske_dialog,&global);
				maske_dialog=0;
			}
			else if(freedom_workaround.freedom_workaround)
			{
				freedom_workaround.freedom_workaround=0;

				if(handle_freedom_workaround(
					freedom_workaround.dialog,
					freedom_workaround.events,
					freedom_workaround.obj,
					freedom_workaround.clicks,
					freedom_workaround.data) == 0)
				{
					if(dialog_maske.slider)
					{
						mt_lbox_delete(dialog_maske.slider,&global);
						dialog_maske.slider=NULL;
					}
					mt_wdlg_close(maske_dialog,NULL,NULL,&global);
					mt_wdlg_delete(maske_dialog,&global);
					maske_dialog=0;
				}
			}
		} while(maske_dialog);

		*x = dialog_maske.x;
		*y = dialog_maske.y;

		/* Set title back */
		clr_or_set_dialog_titel(1,dialog_maske.tree,MASKE_TITEL);
	}
}

void bubble_hilfen(int fenster,int x, int y)
{
	OBJECT *tree;
	int bubble_id;
	int *msg;
	char *bubble_text,*str=0l;

	mt_rsrc_gaddr(0,BUBBLE_HILFEN,&tree,&global);

	if(fenster==window_handle)
	{
		GRECT r;
		int www;

		www=6;
		for(i=0;i<6;i++)
		{
			if(show_row[i])
				www+=max_breite[i];
		}

		mt_wind_get_grect(window_handle,WF_WORKXYWH,&r,&global);
	
		if(x>=r.g_x && x<=r.g_x+r.g_w && y>=r.g_y && y<=r.g_y+r.g_h)
		{ /* Im Fenster */
			if(x<=r.g_x+www)
			{ /* In der Liste */
				if(y<=r.g_y+top_height)
				{ /* Im Listenkopf */
					str=tree[HF_SORT].ob_spec.free_string;
				}
			}
		}
	}
	else if(fenster==dialog_maske.w_handle)
	{
		switch(mt_objc_find(dialog_maske.tree,0,8,x,y,&global))
		{
			case OPEN_LIST:
				str=tree[HD_OPEN_LIST].ob_spec.free_string;
				break;
			case CLOSE_LIST:
				str=tree[HD_CLOSE_LIST].ob_spec.free_string;
				break;
			case LIST_ADD:
				str=tree[HD_LIST_ADD].ob_spec.free_string;
				break;
			case LIST_KILL:
				str=tree[HD_LIST_KILL].ob_spec.free_string;
				break;
			case LIST_CHANGE:
				str=tree[HD_LIST_CHANGE].ob_spec.free_string;
				break;
			case ENTRY_1:
			case ENTRY_2:
			case ENTRY_3:
			case ENTRY_4:
			case VSL_BACK:
			case VSL_SLIDER:
			case VSL_DOWN:
			case VSL_UP:
			case HSL_BACK:
			case HSL_SLIDER:
			case HSL_LEFT:
			case HSL_RIGHT:
				str=tree[HD_LIST].ob_spec.free_string;
				break;
			case MASKE_EDIT:
			case MASKE_LABEL:
				str=tree[HD_EDIT].ob_spec.free_string;
				break;
			case INHALT_EDIT:
			case INHALT_LABEL:
				str=tree[HD_INHALT].ob_spec.free_string;
				break;
			case MASKE_ABB:
				str=tree[HD_ABB].ob_spec.free_string;
				break;
			case MASKE_OK:
				str=tree[HD_OK].ob_spec.free_string;
				break;
			case MASKE_BIGGER:
			case MB_EDIT:
			case MB_BYTES:
				str=tree[HD_BIGGER].ob_spec.free_string;
				break;
			case MASKE_SMALLER:
			case MS_EDIT:
			case MS_BYTES:
				str=tree[HD_SMALLER].ob_spec.free_string;
				break;
			case MASKE_OLDER:
			case MO_EDIT:
				str=tree[HD_OLDER].ob_spec.free_string;
				break;
			case MASKE_JUNGER:
			case MJ_EDIT:
				str=tree[HD_JUNGER].ob_spec.free_string;
				break;
			case MASKE_BS:
				str=tree[HD_BIG_IS_SMALLM].ob_spec.free_string;
				break;
			case INHALT_BS:
				str=tree[HD_BIG_IS_SMALLI].ob_spec.free_string;
				break;
			case MASKE_INFO_SW:
			case MASKE_INFO_FARBE:
				str=versionsnummernstring;
				break;
			case MASKE_HELP_SW:
			case MASKE_HELP_FARBE:
				str=tree[HD_HELP_BUTTON].ob_spec.free_string;
				break;
		}
	}

	if(str && (bubble_id=mt_appl_find("BUBBLE  ",&global))>=0)
	{
		bubble_text=(char *)Mxalloc(256+16,0x22);
		if(bubble_text==(char *) (-32))
			bubble_text=(char *)Malloc(256+16);

		if(bubble_text)
		{
			msg=(int *)(&bubble_text[256]);

			bubble_text[255]='\0';

			for(i=0;i<255 && str[i]!='\0';i++)
				bubble_text[i]=str[i];

			bubble_text[i]='\0';

			msg[0]=BUBBLEGEM_SHOW;
			msg[1]=ap_id;
			msg[2]=0;
			msg[3]=x;
			msg[4]=y;
			*(long *)(&(msg[5]))=(long) bubble_text;
			msg[7]=0;
			if(mt_appl_write(bubble_id,16,msg,&global)==0)
				Mfree(bubble_text);
		}
	}
}
