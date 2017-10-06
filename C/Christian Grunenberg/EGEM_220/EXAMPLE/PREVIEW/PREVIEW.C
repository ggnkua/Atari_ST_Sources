
/* Resource-Previewer (PRG/ACC), (c) 1994/95 C. Grunenberg */

#include <e_gem.h>
#include <stdio.h>
#include <string.h>

#include <rsc.h>
#include "prev_rsc.c"
#include "prev_rsc.h"

char entry[]="  Previewer",*title=&entry[2],rsrc_file[MAX_PATH],*rmem,path[MAX_PATH],
	 *info =
"_ ResourcePreviewer: |^|"\
"^\xBD""1995 C. Grunenberg, Version "E_GEM_VERSION", "__DATE__"||"\
"  Prev/Next tree:  \x04/\x03|"\
"  First/Last tree: CTRL-\x04/\x03";

DIAINFO *rinfo;
OBJECT *rtree,**rtrindex;

void load_resource(char *);

void do_tree(SLINFO *sl,OBJECT *tree,int pos,int prev,int max_pos,int crs,int prev_crs)
{
	char *text=ob_get_text(tree,sl->sl_slider,0);
	if (sl->sl_max>0)
		int2str(text,pos,0);
	else
		strcpy(text,"-");
}

SLKEY sl_keys[]={{key(SCANLEFT,0),0,SL_UP},{key(SCANRIGHT,0),0,SL_DOWN},{key(CTRLLEFT,0),K_CTRL,SL_START},{key(CTRLRIGHT,0),K_CTRL,SL_END}};
SLINFO sl_tree={NULL,0,0,PARENT,SLIDE,0,LEFT,RIGHT,0,1,0,FAIL,HOR_SLIDER,SL_LINEAR,0,50,do_tree,&sl_keys[0],4},*sl_list[] = {&sl_tree,NULL};

void alert(int icon,char *title,char *msg)
{
	xalert(1,1,icon,NULL,SYS_MODAL,BUTTONS_RIGHT,TRUE,title,msg,NULL);
}

void set_dialog(int new_max)
{
	ob_set_text(rtree,RESOURCE,GetFilename(rsrc_file));
	ob_draw(rinfo,RESOURCE);

	ob_disable(rinfo,rtree,TESTRSRC,new_max==0,rinfo!=NULL);

	sl_tree.sl_pos = 0;
	sl_tree.sl_max = new_max;
	sl_tree.sl_min_size = gr_cw*4;
	graf_set_slider(&sl_tree,rtree,GRAF_DRAW);
}

void kill_resource(void)
{
	if (rmem)
	{
		GetPath(rsrc_file);
		free(rmem);
		rmem = NULL;
		set_dialog(0);
	}
}

void Exit(int all,int back)
{
	close_all_dialogs();
	rinfo = NULL;
	if (all || _app)
		kill_resource();
	if (_app)
		exit_gem(TRUE,back);
}

void Dialog(void)
{
	OBJECT *dial,*ob;
	char fname[MAX_PATH],file[MAX_PATH];
	int ex_ob,mode;

	if ((rinfo=open_dialog(rtree,title,NULL,NULL,DIA_MOUSEPOS,FALSE,WIN_DIAL,0,sl_list,NULL))==NULL)
	{
		alert(X_ICN_ALERT,title,"No window available!");
		Exit(TRUE,-1);
	}

	while ((ex_ob=XFormObject(NULL,NULL))>=0)
	{
		ob_select(rinfo,rtree,ex_ob,FALSE,TRUE);
		switch (ex_ob)
		{
		case RESOURCE:
			if (FileSelect("Load resource...",path,file,"*.rsc",TRUE,0,NULL)>0)
				load_resource(MakeFullpath(fname,path,file));
			break;
		case TESTRSRC:
			dial = rtrindex[sl_tree.sl_pos];
			for (ob=dial;;)
			{
				if ((ob->ob_type&G_TYPE)==G_TITLE)
				{
					alert(X_ICN_ALERT,title,"Tree is a pull-down-menu!");
					goto no_preview;
				}
				else if (ob->ob_flags&(EXIT|TOUCHEXIT))
					break;

				if (ob->ob_flags&LASTOB)
				{
					for (ob=dial;((ob->ob_flags|=EXIT)&LASTOB)==0;ob++);
					break;
				}
				else
					ob++;
			}

			mode = ob_isstate(rtree,WDIAL,SELECTED) ? AUTO_DIAL|MODAL : FLY_DIAL;
			if (ob_isstate(rtree,WFRAME,SELECTED))
				mode |= FRAME;
			int2str(strlcpy(strlcpy(fname,GetFilename(rsrc_file)),": Tree "),sl_tree.sl_pos,0);
			ob_clear_edit(dial);
			xdialog(dial,fname,NULL,NULL,DIA_MOUSEPOS,FALSE,mode);
			no_preview:
			break;
		case HELP:
			alert(X_ICN_INFO,NULL,info);
		}
	}
	Exit(FALSE,0);
}

int Init(XEVENT *ev,int avail)
{
	return((MU_MESAG|MU_KEYBD)&avail);
}

int Event(XEVENT *ev)
{
	int wi=ev->ev_mwich,*msg=ev->ev_mmgpbuf,i;
	DRAG_DROP *dd;

	if (wi & MU_MESAG)
		switch (msg[0])
		{
		case AC_CLOSE:
		case AP_TERM:
			Exit(TRUE,0);break;
		case OBJC_DRAGGED:
			dd = *(DRAG_DROP **) &msg[4];
			if (dd->dd_args)
				load_resource(ParseArgs(dd->dd_args));
		case AC_OPEN:
			if (rinfo==NULL)
				Dialog();
			break;
		default:
			wi ^= MU_KEYBD;
		}

	if ((wi&MU_KEYBD) && ((i=ev->ev_mmokstate)&K_CTRL) && scan_2_ascii(ev->ev_mkreturn,i)=='Q')
		Exit(FALSE,0);
	else
		wi &= ~MU_KEYBD;

	return(wi);
}

void resource_init(int n_tree,int n_obs,OBJECT *rs_object,OBJECT **rs_trindex)
{
	TEDINFO *ted;
	ICONBLK *icon;
	BITBLK *bit;
	OBJECT *obj,*rstr;
	char *mem=rmem;
	int tree,index;

	for (obj=rs_object,index=n_obs;--index>=0;obj++)
	{
		switch((unsigned char) obj->ob_type)
		{
		case G_TEXT:
		case G_BOXTEXT:
		case G_FTEXT:
		case G_FBOXTEXT:
			ted = obj->ob_spec.tedinfo = (TEDINFO *) (mem+obj->ob_spec.index);
			ted->te_ptext += (long) mem;
			ted->te_ptmplt += (long) mem;
			ted->te_pvalid += (long) mem;
			break;
		case G_BUTTON:
		case G_STRING:
		case G_TITLE:
			obj->ob_spec.free_string += (long) mem;
			break;
		case G_IMAGE:
			bit = obj->ob_spec.bitblk = (BITBLK *) (mem+obj->ob_spec.index);
			bit->bi_pdata = (int *) (mem + (long) bit->bi_pdata);
			break;
		case G_ICON:
			icon = obj->ob_spec.iconblk = (ICONBLK *) (mem+obj->ob_spec.index);
			icon->ib_pmask = (int *) (mem + (long) icon->ib_pmask);
			icon->ib_pdata = (int *) (mem + (long) icon->ib_pdata);
			icon->ib_ptext += (long) mem;
		}
	}

	for (tree=n_tree;--tree>=0;)
	{
		rs_trindex[tree] = rstr = obj = (OBJECT *) (mem + (long) rs_trindex[tree]);

		for (;;)
		{
			rsrc_obfix(obj,0);
			if (obj->ob_flags & LASTOB)
				break;
			else
				obj++;
		}

		if (ob_isstate(rtree,EGEMRSRC,SELECTED))
			fix_objects(rstr,TEST_SCALING|DARK_SCALING,FAIL,FAIL);
	}
}

void load_resource(char *rsc)
{
	RSHDR *rsc_hdr;
	char *buf,*mem;
	long len,handle;
	int dsc=0;

	if (rsc && (handle=Fopen(rsc,0))>0)
	{
		len = Fseek(0l,(int) handle,SEEK_END);
		Fseek(0l,(int) handle,SEEK_SET);

		if (len<=sizeof(RSHDR))
			alert(X_ICN_ERROR,title,"No resource-file!");
		else
		{
			kill_resource();
			if ((mem=malloc(len+8))!=NULL)
			{
				buf = mem;
				if ((long) buf & 1)
					buf++;
	
				rsc_hdr = (RSHDR *) buf;
				if (Fread((int) handle,len,buf)==len && len==rsc_hdr->rsh_rssize)
				{
					rmem = mem;
					rtrindex = (OBJECT **) (rmem+rsc_hdr->rsh_trindex);
					resource_init(rsc_hdr->rsh_ntree,rsc_hdr->rsh_nobs,(OBJECT *) (buf+rsc_hdr->rsh_object),rtrindex);
					strcpy(rsrc_file,rsc);
					set_dialog(rsc_hdr->rsh_ntree);
				}
				else
				{
					free(mem);
					dsc++;
				}
			}
			else
				alert(X_ICN_ERROR,title,"Not enough memory!");
		}
		Fclose((int) handle);
	}
	else
		dsc++;

	if (dsc)
		alert(X_ICN_DISC_ERR,title,"Couldn't read resource!");
}

void main(int argc,char *argv[])
{
	if (init_gem(NULL,entry,title,"PREVIEW",0,0,0)==TRUE)
	{
		rsrc_init(NUM_TREE,NUM_OBS,NUM_FRSTR,NUM_FRIMG,NO_SCALING,rs_strings,rs_frstr,rs_bitblk,
				  rs_frimg,rs_iconblk,rs_tedinfo,rs_object,(OBJECT **) rs_trindex,(RS_IMDOPE *) rs_imdope,8,16);
		rtree = (OBJECT *) rs_trindex[PREVIEW];
		iconified = (OBJECT *) rs_trindex[ICON];

		Event_Handler(Init,Event);
		set_dialog(0);

		if (_app)
		{
			if (argc>1)
				load_resource(argv[1]);
			Dialog();
		}
		Event_Multi(NULL);
	}
	exit(-1);
}
