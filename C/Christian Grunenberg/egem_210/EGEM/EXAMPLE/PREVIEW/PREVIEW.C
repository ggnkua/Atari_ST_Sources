
/* Resource-Previewer fÅr EnhancedGEM-Dialoge, (c) 1994 C. Grunenberg
   (lÑuft als Programm und Accessory) */

#include <e_gem.h>
#include <stdio.h>

#define CICONBLK ICONBLK

#include "prev_rsc.c"
#include "prev_rsc.h"

char *entry = "  PreViewer",*name = "PREVIEW";
char *title = "ResourcePreViewer",*small_title = "PreView";
char rsrc_file[MAX_PATH];

DIAINFO rsrc_info;
OBJECT *rsrc_tree,**rsrc_trindex;

char *rsrc_mem;
int tree,tree_cnt;

void Exit(int);
void kill_resource(void);
void load_resource(void);
void Dialog(void);

void error(int icon,char *msg)
{
	xalert(1,1,icon,NULL,SYS_MODAL,BUTTONS_RIGHT,TRUE,title,msg,"[Got it!");
}

void val_2_str(char *dest,int val)
{
	if (val>=100)
	{
		*dest++ = val/100 + '0';
		val %= 100;
		*dest++ = val/10 + '0';
	}
	else if (val>=10)
		*dest++ = val/10 + '0';

	val %= 10;
	*dest++ = val + '0';
	*dest++ = '\0';
}

void set_tree_index(void)
{
	tree = min(max(tree,1),tree_cnt);
	val_2_str(ob_get_text(rsrc_tree,TREE,0),tree);
	ob_draw(&rsrc_info,TREE);

	val_2_str(ob_get_text(rsrc_tree,TREECNT,0),tree_cnt);
	ob_draw(&rsrc_info,TREECNT);
}

void set_dialog(void)
{
	ob_set_text(rsrc_tree,RESOURCE,GetFilename(rsrc_file));
	ob_draw(&rsrc_info,RESOURCE);
	ob_disable(&rsrc_info,rsrc_tree,TESTRSRC,tree_cnt==0,TRUE);
	set_tree_index();
}

void Exit(int back)
{
	kill_resource();

	if (_app)
		exit_gem(back);
	else
	{
		close_all_windows();
		GetPath(rsrc_file);
		set_dialog();
	}
}

int InitMsg(XEVENT *evt,int events_available)
{
	return ((MU_KEYBD|MU_MESAG) & events_available);
}

int Messag(XEVENT *event)
{
	reg int ev = event->ev_mwich;

	if (ev & MU_MESAG)
	{
		switch (event->ev_mmgpbuf[0])
		{
		case AC_CLOSE:
		case AP_TERM:
			Exit(0);
			break;
		case AC_OPEN:
			Dialog();
			break;
		}
	}

	if ((ev & MU_KEYBD) && event->ev_mmokstate==0)
	{
		switch (event->ev_mkreturn & 0xff)
		{
		case '+':
			tree++;
			set_tree_index();
			return (MU_KEYBD);
		case '-':
			tree--;
			set_tree_index();
			return (MU_KEYBD);
		}
	}

	return (0);
}

char test_title[256];

void Dialog(void)
{
	OBJECT *dial,*ob;
	char path[MAX_PATH],fname[MAX_PATH];
	int button,double_click,ex_ob;

	if (!open_dialog(rsrc_tree,&rsrc_info,title,small_title,NULL,TRUE,FALSE,WIN_DIAL,0,NULL))
	{
		error(X_ICN_ALERT,"No window available!");
		Exit(-1);
		return;
	}

	for (;;)
	{
		button = X_Form_Do(NULL);

		switch (button)
		{
		case W_CLOSED:
		case W_ABANDON:
			Exit(0);
			return;
		default:
			double_click = button & 0x8000;
			button &= 0x7fff;
			ob_select(&rsrc_info,rsrc_tree,button,FALSE,TRUE);

			switch (button)
			{
			case LOADRSRC:
				if (FileSelect("Load resource...",path,fname,"*.rsc",TRUE))
				{
					MakeFullpath(rsrc_file,path,fname);
					load_resource();
					set_dialog();
				}
				break;
			case TESTRSRC:
				dial = rsrc_trindex[tree-1];
				for (ob=dial,ex_ob=FALSE;;)
				{
					if (ob->ob_flags & (EXIT|TOUCHEXIT))
					{
						ex_ob = TRUE;
						break;
					}
					else if (ob->ob_flags & LASTOB)
						break;
					else
						ob++;
				}

				if (ex_ob)
				{
					ob_clear_edit(dial);
					sprintf(test_title,"%s: Tree %d",GetFilename(rsrc_file),tree);
					xdialog(dial,test_title,NULL,NULL,TRUE,FALSE,ob_isstate(rsrc_tree,WDIAL,SELECTED) ? AUTO_DIAL|MODAL : FLY_DIAL);
				}
				else
					error(X_ICN_ALERT,"No exit-object|or pull-down-menu!");
				break;
			case EXITRSRC:
				Exit(0);
				return;
			case TREEINC:
				if (double_click)
					tree = tree_cnt;
				else
					tree++;
				set_tree_index();
				break;
			case TREEDEC:
				if (double_click)
					tree = 0;
				else
					tree--;
				set_tree_index();
			}
		}
	}
}

void kill_resource(void)
{
	if (rsrc_mem)
	{
		Mfree(rsrc_mem),
		rsrc_mem = NULL;
		tree = tree_cnt = 0;
	}
}

void resource_init(int n_tree,int n_obs,OBJECT *rs_object,OBJECT **rs_trindex)
{
	reg TEDINFO *ted;
	reg ICONBLK *icon;
	reg BITBLK *bit;
	reg OBJECT *obj;
	reg char *mem = rsrc_mem;
	reg int tree,index = n_obs;

	for (obj=rs_object,index=n_obs; --index>=0; obj++)
	{
		switch((unsigned char) obj->ob_type)
		{
		case G_TEXT:
		case G_BOXTEXT:
		case G_FTEXT:
		case G_FBOXTEXT:
			ted = obj->ob_spec.tedinfo = (TEDINFO *) (mem + obj->ob_spec.index);
			ted->te_ptext = mem + (long) ted->te_ptext;
			ted->te_ptmplt = mem + (long) ted->te_ptmplt;
			ted->te_pvalid = mem + (long) ted->te_pvalid;
			break;
		case G_BUTTON:
		case G_STRING:
		case G_TITLE:
			obj->ob_spec.free_string = mem + obj->ob_spec.index;
			break;
		case G_IMAGE:
			bit = obj->ob_spec.bitblk = (BITBLK *) (mem + obj->ob_spec.index);
			bit->bi_pdata = (int *) (mem + (long) bit->bi_pdata);
			break;
		case G_ICON:
			icon = obj->ob_spec.iconblk = (ICONBLK *) (mem + obj->ob_spec.index);
			icon->ib_pmask = (int *) (mem + (long) icon->ib_pmask);
			icon->ib_pdata = (int *) (mem + (long) icon->ib_pdata);
			icon->ib_ptext = mem + (long) icon->ib_ptext;
			break;
		}
	}

	for (tree=0; tree<n_tree; tree++)
	{
		obj = (OBJECT *) (mem + (long) rs_trindex[tree]);
		rs_trindex[tree] = obj;

		for (;;)
		{
			rsrc_obfix(obj,0);
			if (obj->ob_x==0 && obj->ob_width>max_w)
				obj->ob_width = max_w;

			if (obj->ob_flags & LASTOB)
				break;
			else
				obj++;
		}

		if (ob_isstate(rsrc_tree,EGEMRSRC,SELECTED))
			fix_objects(rs_trindex[tree],TEST_SCALING|DARK_SCALING,FAIL,FAIL);
	}
}

void load_resource(void)
{
	reg RSHDR *rsc_hdr;
	reg char *buf,*mem;
	long len,handle;

	if ((handle=Fopen(rsrc_file,0))>0)
	{
		len = Fseek(0l,(int) handle,SEEK_END);
		Fseek(0l,(int) handle,SEEK_SET);

		if (len<=sizeof(RSHDR))
			error(X_ICN_ERROR,"No resource-file!");
		else if ((mem=Malloc(len+16))!=NULL)
		{
			buf = mem;
			if ((long) buf & 1)
				buf++;

			kill_resource();
			rsc_hdr = (RSHDR *) buf;

			if (Fread((int) handle,len,buf)==len && len==rsc_hdr->rsh_rssize)
			{
				rsrc_mem = mem;
				rsrc_trindex = (OBJECT **) (rsrc_mem+rsc_hdr->rsh_trindex);

				tree_cnt = rsc_hdr->rsh_ntree;
				tree = 1;

				resource_init(rsc_hdr->rsh_ntree,rsc_hdr->rsh_nobs,(OBJECT *) (buf+rsc_hdr->rsh_object),rsrc_trindex);

				return;
			}
			else
				error(X_ICN_DISC_ERR,"Couldn't read resource!");
			Mfree(mem);
		}
		else
			error(X_ICN_ERROR,"Not enough memory!");
		Fclose((int) handle);
	}
	else
		error(X_ICN_DISC_ERR,"Couldn't open resource!");
	GetPath(rsrc_file);
}

void main()
{
	if (init_gem(entry,title,name,0,0,0)==TRUE)
	{
		rsrc_init(NUM_TREE,NUM_OBS,NUM_FRSTR,NUM_FRIMG,NO_SCALING,rs_strings,rs_frstr,rs_bitblk,
				  rs_frimg,rs_iconblk,rs_tedinfo,rs_object,(OBJECT **) rs_trindex,(RS_IMDOPE *) rs_imdope,8,16);
		rsrc_tree = (OBJECT *) rs_trindex[PREVIEW];

		Event_Handler(InitMsg,Messag);
		CycleCloseWindows('W','U',FAIL,FAIL);
		title_options(FALSE,RED,FALSE);
		set_tree_index();

		if (_app)
			Dialog();
		Event_Multi(NULL);
	}
}
