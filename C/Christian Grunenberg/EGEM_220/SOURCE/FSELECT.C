
#include "proto.h"

#ifndef SMALL_NO_FONT
#include <stdio.h>
#include <string.h>

static FONTINFO *SetFontInfo(FONTINFO *);

#ifdef __MINT_LIB__
typedef int (*COMPARE)(const void *,const void *);
#else
typedef int (*COMPARE)(void *,void *);
#endif

static FONTINFO *font;
#define MIN_SIZE	3
#define MAX_SIZE	999
#define MAX_SIZES	16

static int vec_sizes[] = {72,48,36,28,24,20,18,14,12,10,9,8,6};
#define VEC_SIZES	13

#ifndef SMALL_NO_FSEL

#include <rsc.h>
#include "fontsel.c"
#include "fontsel.h"

DIAINFO *FSelDialog;

typedef struct
{
	FONTINFO **faces;
	char name[34];
	int face_offset,face_cnt,name_len;
} FAMILY;

typedef struct
{
	FONTINFO *ptr;
	int id,size,effect,color,skew;
} FONT;

static int cdecl draw(PARMBLK *);
static int cdecl draw_ex(PARMBLK *);
static void do_skew(SLINFO *,OBJECT *,int,int,int,int,int);

static int ob_action[] = {WNONE,WICON,WBACK,WCLOSE};

static int effects[] = {FNTFAT,FNTLIGHT,FNTITAL,FNTUNDER,FNTOUTLN,FNTSHDOW,FNTINV};
#define EFFECTS		7

static SLKEY sl_fontkeys[] = 
{{key(SCANUP,0),0,SL_CRS_UP},{key(SCANDOWN,0),0,SL_CRS_DN},
 {key(SCANUP,0),K_SHIFT,SL_PG_UP},{key(SCANDOWN,0),K_SHIFT,SL_PG_DN},
 {key(SCANHOME,0),0,SL_START},{key(SCANHOME,0),K_SHIFT,SL_END}};

static SLKEY sl_facekeys[] = 
{{key(SCANUP,0),K_CTRL,SL_CRS_UP},{key(SCANDOWN,0),K_CTRL,SL_CRS_DN},
 {key(SCANUP,0),K_CTRL|K_SHIFT,SL_PG_UP},{key(SCANDOWN,0),K_CTRL|K_SHIFT,SL_PG_DN},
 {key(SCANHOME,0),K_CTRL,SL_START},{key(SCANHOME,0),K_CTRL|K_SHIFT,SL_END}};

static XPOPUP pcolor = {{NULL,NULL,FAIL,COLOR,COLORTXT,FALSE,TRUE,0l},0,POPUP_BTN_CHK,POPUP_BTN_CHK,OBJPOS,0,0,0,0,0},*plist[]={&pcolor,NULL};
static POPUP options = {NULL,NULL,FAIL,OPTIONS,FAIL,FALSE,FALSE,0l};
static OBJECT *options_tree;
static SLINFO sl_family = {NULL,FONTVIEW,0,FONTPAR,FONTSLD,0,FONTUP,FONTDOWN,0,0,0,0,VERT_SLIDER,SL_LOG,0,100,NULL,&sl_fontkeys[0],6};
static SLINFO sl_size = {NULL,SIZEVIEW,FAIL,SIZEPAR,SIZESLD,0,SIZEUP,SIZEDOWN,0,0,0,FAIL,VERT_SLIDER,SL_LOG,0,333,NULL,0l,0};
static SLINFO sl_face = {NULL,FACEVIEW,0,FACEPAR,FACESLD,0,FACEUP,FACEDOWN,0,0,0,FAIL,VERT_SLIDER,SL_LOG,0,200,NULL,&sl_facekeys[0],6};
static SLINFO sl_skew = {NULL,FAIL,FAIL,SKEWPAR,SKEWSLID,0,SKEWDOWN,SKEWUP,0,10,100,FAIL,HOR_SLIDER,SL_LOG,0,333,do_skew,0l,0};
static SLINFO *sl_list[] = {&sl_family,&sl_size,&sl_face,NULL,NULL};
static USERBLK slideblk = {draw,0},exblk = {draw_ex,0};

static OBJECT *font_tree;
static FONTSEL *fsel;
static FONTINFO **font_list,**face_list;
static FAMILY *family_list,*family_ptr;
static FONT act_font,ex_font;
static int act_family,act_face,sizes[MAX_SIZES],preview,sort,redraw;
static int fnt_mins,fnt_maxs,fnt_def,fsm,ex_height,families,action;
static char *edit_size,*example,info[50];
static char *fsel_info = E_GEM"-Fontselector|>^Version "E_GEM_VERSION", "__DATE__"|^|>\xBD""1995 C. Grunenberg";

#ifndef SMALL_NO_DD_FSEL
static int drag;
#endif

static int SizePos(int *cursor)
{
	reg int *sz,size,lines,pos=0;
	*cursor = FAIL;
	for (lines=0,sz=sizes;lines<sl_size.sl_max;lines++)
		if ((size=*sz++)==act_font.size)
		{
			*cursor = pos = lines;
			break;
		}
		else if (size<act_font.size)
			pos = lines;
	return (pos>0 ? max(min(pos-(sl_size.sl_page>>1),sl_size.sl_max-sl_size.sl_page),0) : 0);
}

#ifndef SMALL_NO_DD_FSEL
static void set_font_app(int app,int win,int draw)
{
	if (fsel && drag)
	{
		XAcc *set;
		char *caller = ob_get_text(font_tree,FONTOK,0);

		if (fsel->drag.app_only)
			app = (win<0 || get_window(win)) ? ap_id : -1;
		else if ((set=find_id(app))==NULL)
		{
			strcpy(caller,"No caller");
			app = -1;
		}
		else
			strncpy(caller,set->xname ? set->xname : set->name,12);
		fsel->win = win;
		ob_disable(FSelDialog,font_tree,FONTOK,(fsel->app=app)<0,draw);
	}
}
#endif

static void set_info(void)
{
	char *p;
	int type;

	SetFontInfo(act_font.ptr);
	type = act_font.ptr->type;

	if (type & FNT_TRUETYPE)
		p = info,"TrueType";
	else if (type & FNT_TYPE1)
		p = "Type-1";
	else if (type & FNT_CFN)
		p = "Calamus";
	else if (type & FNT_SPEEDO)
		p = "Speedo";
	else if (type & FNT_VECTOR)
		p = "Vector";
	else
		p = "Bitmap";

	int2str(strlcpy(info,"ID: "),act_font.id,5);
	strcat(strcat(strcat(strcat(info,", Type: "),(type & FNT_PROP) ? "proportional " : "monospaced "),p)," - Font");
}

#endif

int _InitFont(void)
{
	reg char *p;
	reg FONTINFO *fnt;
	reg int i,type;

#ifndef SMALL_NO_FSEL
	if ((font=(FONTINFO *) calloc(fonts_loaded,sizeof(FONTINFO)+4+sizeof(FAMILY)+4))==NULL)
		return (FALSE);
	else
	{
		font_list = (FONTINFO **) &font[fonts_loaded];
		family_list = (FAMILY *) &font_list[fonts_loaded];
		face_list = (FONTINFO **) &family_list[fonts_loaded];
	}
#else
	if ((font=(FONTINFO *) calloc(fonts_loaded,sizeof(FONTINFO)))==NULL)
		return (FALSE);
#endif

	for (i=1,fnt=font;i<=fonts_loaded;i++,fnt++)
	{
		fnt->id = vqt_name(x_handle,fnt->index=i,fnt->name);

		if (speedo && fnt->name[32])
		{
			type = fnt->name[33];
			if (type & 0x10)
				type = FNT_CFN|FNT_VECTOR;
			else if (type & 0x08)
				type = FNT_TYPE1|FNT_VECTOR;
			else if (type & 0x04)
				type = FNT_TRUETYPE|FNT_VECTOR;
			else if (type & 0x02)
				type = FNT_SPEEDO|FNT_VECTOR;
			else
				type = FNT_VECTOR;
		}
		else
			type = 0;

		fnt->name[32] = '\0';
		while ((p=strstr(fnt->name,"  "))!=NULL)
			strcpy(p,p+1);

		fnt->type = (fnt->id==1) ? (type|FNT_SYSTEM) : type;
	}
	return (TRUE);
}

FONTINFO *FastFontInfo(int id)
{
	reg FONTINFO *fnt;
	reg int i;

	for (;;)
	{
		for (fnt=font,i=fonts_loaded;--i>=0 && fnt->id!=id;fnt++);
		if (i>=0)
			break;
		id = v_set_font(id);
	}
	return (fnt);
}

FONTINFO *FontInfo(int id)
{
	return (SetFontInfo(FastFontInfo(id)));
}

static FONTINFO *SetFontInfo(FONTINFO *fnt)
{
	if (fnt->valid==FALSE)
	{
		int j1,j2,w,type = fnt->type,min_ascii,max_ascii,cw1,cw2,d[8];

		fnt->valid = TRUE;

		v_set_font(fnt->id);
		fnt->max_size = vst_point(x_handle,MAX_SIZE,d,d,d,d);
		fnt->min_size = vst_point(x_handle,MIN_SIZE,d,d,d,d);
		_theight = -MIN_SIZE;

		vqt_fontinfo(x_handle,&min_ascii,&max_ascii,d,&w,d);
		fnt->min_ascii = min_ascii = min(max(min_ascii,0),255);
		fnt->max_ascii = max_ascii = min(max(max_ascii,min_ascii),255);
		if (min_ascii>0 || max_ascii<255)
			type |= FNT_ASCII;

		if (min_ascii<='W' && max_ascii>='i')
		{
			j1 = 'i';
			j2 = 'W';
		}
		else
		{
			j1 = min_ascii;
			j2 = max_ascii;
		}

		if (vqt_width(x_handle,j1,&cw1,d,d)!=j1 || vqt_width(x_handle,j2,&cw2,d,d)!=j2)
			type = (type & ~FNT_PROP)|FNT_ASCII;
		else if (cw1>=w && cw1==cw2)
			type &= ~FNT_PROP;

		for (j1=max(min_ascii,1);j1<=max_ascii && (type&(FNT_ASCII|FNT_PROP))!=(FNT_ASCII|FNT_PROP);j1++)
		{
			if (vqt_width(x_handle,j1,&cw1,d,d)!=j1)
				type |= FNT_ASCII;
			else if (cw1<w)
				type |= cw1<=0 ? (FNT_PROP|FNT_ASCII) : FNT_PROP;
		}
		fnt->type = type;
	}
	return (fnt);
}

static int FontTest(FONTINFO *fnt,int h,int (*font_test)(FONTINFO*,int))
{
	if (font_test)
	{
		SetFontInfo(fnt);
		return (font_test(fnt,h));
	}
	return(TRUE);
}

int FontList(int type,int min_size,int max_size,int max_fonts,FONTINFO *fonts[],int (*font_test)(FONTINFO *,int))
{
	reg FONTINFO *fnt = font;
	reg int i,cnt,h,prop=-1,all;

	switch (type & (FS_FNT_MONO|FS_FNT_PROP))
	{
	case FS_FNT_MONO:
		prop = 0;break;
	case FS_FNT_PROP:
		prop = FNT_PROP;break;
	}

	type = -1;
	switch (type & (FS_FNT_BITMAP|FS_FNT_VECTOR))
	{
	case FS_FNT_BITMAP:
		type = 0;break;
	case FS_FNT_VECTOR:
		type = FNT_VECTOR;break;
	}

	min_size = max(min_size,MIN_SIZE);
	max_size = max_size>0 ? min(max_size,MAX_SIZE) : MAX_SIZE;
	all = (min_size==MIN_SIZE && max_size>=MAX_SIZE);

	for (cnt=0,i=1;i<=fonts_loaded && cnt<max_fonts;i++,fnt++)
		if (type<0 || (fnt->type & FNT_VECTOR)==type)
		{
			if (prop>=0)
				SetFontInfo(fnt);
			if (prop<0 || (fnt->type & FNT_PROP)==prop)
			{
				if (!all)
					h = v_set_point(FALSE,max_size);
				if ((all || (h>=min_size && h<=max_size)) && FontTest(fnt,-1,font_test))
					fonts[cnt++] = fnt;
			}
		}
	return (cnt);
}

static int compare_size(int *s1,int *s2)
{
	return (*s1-*s2);
}

int FontSizes(int id,int fsm,int min_size,int max_size,int max_cnt,reg int *sizes,int (*font_test)(FONTINFO*,int))
{
	reg FONTINFO *fnt=FastFontInfo(id);
	reg int i,j,h,last_h,cnt = 0,*s;
	int list;

	if (max_size<=0)
		max_size = MAX_SIZE;

	if ((list=(fsm && speedo && (fnt->type & FNT_VECTOR)))!=0)
		for (s=vec_sizes,i=VEC_SIZES;--i>=0 && cnt<max_cnt;)
			if ((h=*s++)>=min_size && h<=max_size && FontTest(fnt,h,font_test))
				sizes[cnt++] = h;

	v_set_font(id);
	for (last_h=-1,h=max_size;cnt<max_cnt && h>0;)
	{
		h = v_set_point(FALSE,h);
		if (h!=last_h && h>=min_size && h<=max_size)
		{
			if (list)
				for (j=cnt,s=sizes;--j>=0 && *s++!=h;);
			else
				j = -1;
			if (j<0 && FontTest(fnt,h,font_test))
				sizes[cnt++] = h;
			last_h = h;
		}
		else
			break;
		h--;
	}

	qsort(sizes,cnt,sizeof(int),(COMPARE) compare_size);
	return (cnt);
}

#ifndef SMALL_NO_FSEL

static void do_skew(SLINFO *sl,OBJECT *tree,int pos,int prev,int max_pos,int crs,int prev_crs)
{
	reg char *text = ob_get_text(tree,SKEWSLID,0);

	text += int2str(text,-(act_font.skew=45-pos),0);
	*text++ = 0xf8;
	*text = 0;

	act_font.skew *= 10;
}

static int cdecl draw(PARMBLK *pb)
{
	GRECT work = *(GRECT *) &pb->pb_x,area;

	if (rc_intersect((GRECT *) &pb->pb_xc,&work))
	{
		reg char text[40],*p,c;
		FAMILY *act;
		FONTINFO **faces,*fnt;
		reg SLINFO *sl;
		reg int *sz,out[4],font,x = pb->pb_x,y = pb->pb_y,start_line,lines,offset;
		int new[4],old[4];

		save_clipping(old);
		rc_grect_to_array(&work,new);
		restore_clipping(new);

		v_set_mode(MD_TRANS);
		v_set_text(ibm_font_id,ibm_font,BLACK,0,0,NULL);
		rc_sc_clear(&work);

		start_line = (work.g_y-y)/gr_ch;
		y += start_line*gr_ch;

		switch (pb->pb_obj)
		{
		case FONTVIEW:
			font = TRUE;sl = &sl_family;
			act = &family_list[start_line+=sl->sl_pos];
			break;
		case SIZEVIEW:
			font = FALSE;sl = &sl_size;
			sz = &sizes[start_line+=sl->sl_pos];
			break;
		default:
			font = FAIL;sl = &sl_face;
			offset = family_ptr->name_len;
			faces = &family_ptr->faces[start_line+=sl->sl_pos];
		}

		lines = min((work.g_y-y+work.g_h+gr_ch-1)/gr_ch,sl->sl_max-start_line);
		for (;--lines>=0;y+=gr_ch,start_line++)
		{
			if (font)
			{
				if (font==TRUE)
				{
					fnt = act->faces[0];
					strcpy(text,act->name);
					act++;
				}
				else
				{
					p = (fnt=*faces++)->name+offset;
					while ((c=*p++)==' ' || c==',' || c=='-');
					if (*--p!='\0')
						strcpy(text,p);
					else
						strcpy(text,"Standard");
				}

				if (preview)
				{
					v_set_text(fnt->id,(fnt->type & FNT_VECTOR) ? ibm_font : -1,FAIL,FAIL,FAIL,out);
					if (out[1]>gr_ch)
						v_set_text(FAIL,ibm_font,FAIL,FAIL,FAIL,out);
					v_gtext(x_handle,x,y+((gr_ch-out[1])>>1),text);
				}
				else
					v_gtext(x_handle,x,y,text);
			}
			else
			{
				int2str(text,*sz++,3);
				v_gtext(x_handle,x+(gr_cw>>1),y,text);
			}

			if (sl->sl_cursor==start_line)
			{
				area.g_x = x;
				area.g_y = y;
				area.g_w = pb->pb_w;
				area.g_h = gr_ch;
				if (rc_intersect(&work,&area))
					rc_sc_invert(&area);
			}
		}
		restore_clipping(old);
	}
	return (0);
}

static int cdecl draw_ex(PARMBLK *pb)
{
	GRECT work = *(GRECT *) &pb->pb_x;

	if (rc_intersect((GRECT *) &pb->pb_xc,&work))
	{
		reg int old[4],new[4],extent[8],x = pb->pb_x,y = pb->pb_y+pb->pb_h,xo,yo;
		int effect = ex_font.effect & 31,skew;

		save_clipping(old);
		rc_grect_to_array(&work,new);
		restore_clipping(new);
		rc_sc_clear(&work);

		v_set_mode(MD_TRANS);
		v_set_font(ex_font.id);
		if ((skew=(ex_font.skew && (ex_font.ptr->type & FNT_VECTOR)))!=0)
			vst_skew(x_handle,ex_font.skew);
		v_set_text(FAIL,-ex_font.size,ex_font.color,effect,0,extent);
		xo = max(extent[0]>>3,2);
		yo = max(extent[1]>>3,2);

		vqt_extent(x_handle,example,extent);
		y -= extent[5];

		if (ex_font.effect & X_SHADOWED)
		{
			v_set_text(FAIL,FALSE,FAIL,effect|2,FAIL,NULL);
			v_gtext(x_handle,x+xo,y,example);
			v_set_text(FAIL,FALSE,FAIL,effect,FAIL,NULL);
			y -= yo;
		}
		else
			xo = yo = 0;
		ex_height = min(extent[5]+yo,pb->pb_h);

		v_gtext(x_handle,x,y,example);

		if (ex_font.effect & X_INVERS)
		{
			work.g_x = pb->pb_x;
			work.g_y = max(y,pb->pb_y);
			work.g_w = min(extent[4]+xo,pb->pb_w);
			work.g_h = ex_height;
			if (rc_intersect((GRECT *) &pb->pb_xc,&work))
				rc_sc_invert(&work);
		}

		if (skew)
			vst_skew(x_handle,0);

		restore_clipping(old);
	}
	return (0);
}

static void init_pointer(int id)
{
	reg FAMILY *act;
	reg FONTINFO **faces,*fnt;
	reg int i,j,cnt;

	family_ptr = act = family_list;
	act_font.ptr = *family_ptr->faces;
	act_family = act_face = 0;

	for (i=0;i<families;i++,act++)
		for (j=0,cnt=act->face_cnt,faces=act->faces;j<cnt;j++)
		{
			fnt = *faces++;
			if (fnt->id==id)
			{
				family_ptr = act;
				act_family = i;
				act_font.ptr = fnt;
				act_face = j;
			}
		}

	act_font.id = act_font.ptr->id;
	sl_family.sl_max = families;
	sl_family.sl_cursor = act_family;
	sl_face.sl_cursor = act_face;
	sl_face.sl_max = family_ptr->face_cnt;
}

static void set_size(void)
{
	int2str(edit_size,act_font.size,0);
	ob_draw(FSelDialog,FONTSIZE);
	ob_set_cursor(FSelDialog,FONTSIZE,0x1000,FAIL);
}

static void new_size(int size,int set)
{
	int old_size = act_font.size;

	v_set_font(act_font.id);
	act_font.size = v_set_point(fsm,size);
	if (act_font.size!=old_size || set);
		set_size();

	sl_size.sl_max = FontSizes(act_font.id,fsm,fnt_mins,fnt_maxs,MAX_SIZES,sizes,fsel->font_test);
	sl_size.sl_pos = SizePos(&sl_size.sl_cursor);

	set_info();
}

static void UpdateExample(int set)
{
	if (redraw || set)
	{
		ex_font = act_font;
		ob_draw(FSelDialog,EXAMPLE);
	}
}

static void new_font(int id,int face_set)
{
	reg int list[5],*p=list;

	beg_update(FALSE,FALSE);
	init_pointer(id);

	if (face_set)
	{
		sl_face.sl_pos = 0;
		graf_set_slider(&sl_face,font_tree,GRAF_DRAW);
		*p++ = FACEVIEW;
	}

	new_size(face_set ? fnt_def : act_font.size,FALSE);
	graf_set_slider(&sl_size,font_tree,GRAF_DRAW);

	*p++ = FONTIDSZ;
	*p++ = SIZEVIEW;

	if (redraw)
	{
		ex_font = act_font;
		*p++ = EXAMPLE;
	}
	*p++ = 0;

	ob_draw_list(FSelDialog,list,NULL);
	end_update(FALSE);
}

int _FselEvent(int events,int *msg,XEVENT *event)
{
	SLINFO *slider;
	int old_size = act_font.size,i,bit,*eff;

	if ((events & MU_KEYBD) && event->ev_mmokstate==K_CTRL && scan_2_ascii(event->ev_mkreturn,K_CTRL)=='E')
		UpdateExample(TRUE);
	else
		events &= ~MU_KEYBD;

	if (events & MU_MESAG)
	{
		events ^= MU_MESAG;

		switch (msg[0])
		{
	#ifndef SMALL_NO_DD_FSEL
		case XACC_AV_EXIT:
		case CH_EXIT:
			if (msg[3]!=fsel->app)
				break;
		case XACC_AV_CLOSE:
			set_font_app(-1,-1,TRUE);
			break;
	#endif
	#ifndef SMALL_NO_EDIT
		case OBJC_EDITED:
			if (*(DIAINFO **) &msg[4]==FSelDialog)
			{
				v_set_font(act_font.id);
				act_font.size = v_set_point(fsm,max(min(atoi(edit_size),fnt_maxs),fnt_mins));
				if (act_font.size!=old_size)
				{
					i = SizePos(&bit);
					graf_rt_slidebox(&sl_size,SL_SET,FALSE,i,bit);
					UpdateExample(FALSE);
				}
				events ^= MU_MESAG;
			}
			break;
	#endif
		case POPUP_CHANGED:
			if (*(XPOPUP **) &msg[4]==&pcolor)
			{
				act_font.color = pcolor.index;
				UpdateExample(FALSE);
				events ^= MU_MESAG;
			}
			break;
		case OBJC_CHANGED:
			if (*(DIAINFO **) &msg[4]==FSelDialog)
			{
				for (act_font.effect=0,i=EFFECTS,bit=1,eff=effects;--i>=0;bit<<=1)
					if (ob_isstate(font_tree,*eff++,SELECTED))
						act_font.effect |= bit;
				UpdateExample(FALSE);
				events ^= MU_MESAG;
			}
			break;
		case SLIDER_CHANGED:
			slider = *(SLINFO **) &msg[4];
			if (slider==&sl_family)
			{
				if ((i=sl_family.sl_cursor)!=act_family)
					new_font(family_list[i].faces[0]->id,TRUE);
				events ^= MU_MESAG;
			}
			else if (slider==&sl_face)
			{
				if ((i=sl_face.sl_cursor)!=act_face)
					new_font(family_ptr->faces[i]->id,FALSE);
				events ^= MU_MESAG;
			}
			else if (slider==&sl_size)
			{
				if (sl_size.sl_cursor>=0 && (i=sizes[sl_size.sl_cursor])!=act_font.size)
				{
					act_font.size = i;
					set_size();
					UpdateExample(FALSE);
				}
				events ^= MU_MESAG;
			}
			else if (slider==&sl_skew)
			{
				UpdateExample(FALSE);
				events ^= MU_MESAG;
			}
		}
	}
	return (events);
}

static void InitSlider(int object,int parent,int *lines)
{
	reg OBJECT *obj = &font_tree[object];

	obj->ob_type = G_USERDEF;
	obj->ob_spec.userblk = &slideblk;

	*lines = obj->ob_height/gr_ch;
	obj->ob_width--;

	obj += parent-object;
	obj->ob_y++;
	obj->ob_height -= 2;
}

static void set_option(int obj,int set)
{
	reg int *state = (int *) &options_tree[obj].ob_state;
	if (set)
		*state |= CHECKED;
	else
		*state &= ~CHECKED;
}

#ifndef SMALL_NO_DD_FSEL
static int FontWait(int app)
{
	if (find_xacc_xdsc(app,"XFontAck"))
		return (_Wait(app,2000,FONT_WAIT,NULL));
	else
		Event_Timer(app<0 ? 500 : 250,0,TRUE);
	return (app<0);
}

static void set_font(int app,int win,int state)
{
	FontChanged(app,win,ex_font.id,ex_font.size,ex_font.effect,ex_font.color);
	if ((state & K_CTRL)==0 && action>FS_ACT_NONE && FontWait(app))
	{
		if (action==FS_ACT_ICON)
		{
			set_font_app(-1,-1,FALSE);
			WindowHandler(W_ICONIFY,FSelDialog->di_win,NULL);
		}

		if (win>0)
		{
			int msg[8];
			msg[3] = win;
			AvSendMsg(app,app!=ap_id ? WM_TOPPED : WIN_TOPPED,msg);
			Event_Timer(250,0,TRUE);
		}

		if (action==FS_ACT_CLOSE)
		{
			close_dialog(FSelDialog,fsel->options.boxes);
			FSelDialog = NULL;
		}
		else if (action==FS_ACT_BACK)
			window_bottom(FSelDialog->di_win);
	}
}
#endif

static int compare_face(FONTINFO **f1,FONTINFO **f2)
{
	if (sort)
		return (stricmp((*f1)->name,(*f2)->name));
	else
		return ((*f1)->index-(*f2)->index);
}

static int compare_family(FAMILY *f1,FAMILY *f2)
{
	return (compare_face(f1->faces,f2->faces));
}

static int create_list(int create)
{
	reg char c,*p,*q,*sep=" ,-";
	reg FONTINFO **list,*fnt,**face=face_list;
	reg FAMILY *act=family_list;
	reg int i,j,cnt,type;

	if (create)
	{
		if ((cnt=FontList(fsel->fsel_type,fnt_mins,fnt_maxs,fonts_loaded,font_list,fsel->font_test))==0)
			return (0);
	
		for (families=0;;act++)
		{
			for (list=font_list,i=cnt;--i>=0 && (fnt=*list++)==NULL;);
			if (i<0)
				break;

			*face = fnt;
			type = fnt->type;
			act->faces = face++;
			act->face_cnt = 1;
			act->name_len = (int) strlen(strtok(strcpy(act->name,fnt->name),sep));
			list[-1] = NULL;
			families++;

			while (--i>=0)
				if ((fnt=*list++)!=NULL && ((type^fnt->type)&(FNT_VECTOR|FNT_TRUETYPE|FNT_SPEEDO|FNT_TYPE1|FNT_CFN))==0 && !strnicmp(p=act->name,q=fnt->name,act->name_len))
				{
					if (act->face_cnt==1)
					{
						q += act->name_len;
						p += act->name_len;
						while (*p!='\0' && *p++==*q++)
							act->name_len++;
					}
					*face++ = fnt;
					act->face_cnt++;
					list[-1] = NULL;
				}
		}
	}

	qsort(family_list,families,sizeof(FAMILY),(COMPARE) compare_family);
	for (act=family_list,i=families;--i>=0;act++)
	{
		p = act->faces[0]->name;
		if ((cnt=act->face_cnt)==1)
		{
			for (type=0,q=strtok(p=strcpy(act->name,p),sep);q!=NULL;q=strtok(NULL,sep))
			{
				type += (int) (q-p);
				p = q;
			}
			if (type==0)
				type = act->name_len;
		}
		else
			for (p+=(type=act->name_len);(c=*p++)!='\0';type++)
			{
				list = &act->faces[1];
				j = cnt-1;
				while (--j>=0)
				{
					fnt = *list++;
					if (c!=fnt->name[type])
						break;
				}
				if (j>=0)
					break;
			}
		strcpy(act->name,act->faces[0]->name);
		act->name[act->name_len=type] = '\0';
		qsort(act->faces,cnt,sizeof(FONTINFO *),(COMPARE) compare_face);
	}

	init_pointer(create ? fsel->id : act_font.id);

	return (1);
}

static void set_output(int back)
{
	fsel->options.action = action;
	fsel->options.sort = sort;
	fsel->options.redraw = redraw;
	fsel->options.preview = preview;

	fsel->x = font_tree->ob_x;
	fsel->y = font_tree->ob_y;

	if (back==FS_OK)
	{
		fsel->id = act_font.id;
		fsel->size = act_font.size;
		fsel->fnt = act_font.ptr;

		if (fsel->gadgets & FS_GADGETS_SKEW)
			fsel->skew = act_font.skew;
		if (fsel->gadgets & FS_GADGETS_EFFECT)
			fsel->effect = act_font.effect;
		if (fsel->gadgets & FS_GADGETS_COLOR)
			fsel->color = act_font.color;
	}
}

boolean UpdateFsel(boolean all,boolean example)
{
	if (fsel)
	{
		set_output(all ? FS_OK : FS_ABANDON);
		if (example)
			UpdateExample(TRUE);
		return (TRUE);
	}
	else
		return (FALSE);
}

boolean FontSelect(int mode,FONTSEL *fs)
{
	static boolean fixed = FALSE;
	static TEDINFO *help = NULL;
	reg OBJECT *obj;
	reg int i,hide,*eff;
	int exob,exit,back = FS_ERROR,x,k,diamode;
	SLINFO *sl;
#ifndef SMALL_NO_DD_FSEL
	GRECT start;
	int app,d,y;
#endif

	if (FSelDialog && fs!=fsel)
		return (FS_ACTIVE);
	else if (_no_output)
		return (FS_ERROR);

	if (fixed==FALSE)
	{
		rsrc_init(NUM_TREE,NUM_OBS,NUM_FRSTR,NUM_FRIMG,NO_SCALING,rs_strings,rs_frstr,rs_bitblk,
				  rs_frimg,rs_iconblk,rs_tedinfo,rs_object,(OBJECT **) rs_trindex,(RS_IMDOPE *) rs_imdope,8,16);
		font_tree = (OBJECT *) rs_trindex[FONTSLCT];
		pcolor.popup.p_menu = obj = (OBJECT *) rs_trindex[PCOLOR];
		options.p_menu = options_tree = (OBJECT *) rs_trindex[POPTIONS];

		obj->ob_height -= max(16-colors,0)*gr_ch;
		for (i=colors+1,obj+=i;i<=16;i++,obj++)
			obj->ob_flags |= HIDETREE;

		InitSlider(SIZEVIEW,SIZEPAR,&sl_size.sl_page);
		InitSlider(FONTVIEW,FONTPAR,&sl_family.sl_page);
		InitSlider(FACEVIEW,FACEPAR,&sl_face.sl_page);

		font_tree[FONTOK].ob_y = font_tree[FONTCAN].ob_y;
		font_tree[FONTOK].ob_height = font_tree[FONTCAN].ob_height;

		obj = &font_tree[SKEWPAR];
		obj->ob_x++;
		obj->ob_width -= 2;

		obj = &font_tree[FONTIDSZ];
		obj->ob_y++;
		obj->ob_height -= 2;
		ob_set_text(font_tree,FONTIDSZ,info);

		obj = &font_tree[FNTFAT];
		obj->ob_x--;
		obj->ob_width++;

		obj = &font_tree[EXAMPLE];
		obj->ob_type = G_USERDEF;
		obj->ob_spec.userblk = &exblk;

		help = font_tree[HELP].ob_spec.tedinfo;

		edit_size = ob_get_text(font_tree,FONTSIZE,0);

		sl_skew.sl_min_size = gr_cw*5;
		fixed = TRUE;
	}

	fsel = fs;

	obj = &font_tree[MOVEBOX];
	obj->ob_y = font_tree[FNTTITLE].ob_y - gr_ch;

	if ((hide=(fs->title==NULL))==0)
	{
		obj->ob_y += gr_ch<<1;
		ob_set_text(font_tree,FNTTITLE,fs->title);
		font_tree[TITELSUB].ob_width = ((int) strlen(fs->title)+2)*gr_cw;
	}
	else
		obj->ob_y += gr_ch>>2;

	i = obj->ob_y + obj->ob_height + gr_ch;
	obj = font_tree;

	if (i>desk.g_h || obj->ob_width>desk.g_w)
		return (FS_RES_ERROR);
	obj->ob_height = i;

	ob_hide(font_tree,FNTTITLE,hide);
	ob_hide(font_tree,TITELSUB,hide);

	example = (fs->example!=NULL) ? fs->example : "The quick brown fox jumps over the lazy dog's back";

	obj = &font_tree[HELP];
	if (fs->info)
	{
		obj->ob_spec.tedinfo = fs->info;
		obj->ob_type = (HELP_BTN<<8)|(fs->info_type&0xff);
		obj->ob_state = fs->info_state & (~SELECTED);
	}
	else
	{
		obj->ob_spec.tedinfo = help;
		obj->ob_type = (HELP_BTN<<8)|G_BOXTEXT;
		obj->ob_state = OUTLINED|SHADOWED;
	}

#ifndef SMALL_NO_DD_FSEL
	drag = (mode==FSEL_DRAG);
	ob_hide(options_tree,NICE,!drag);
#else
	ob_doflag(options_tree,NICE,HIDETREE);
#endif

	action = fs->options.action;
#ifndef SMALL_NO_ICONIFY
	if ((_icfs==NULL && action==FS_ACT_ICON) || (!bottom && action==FS_ACT_BACK))
#else
	if (action==FS_ACT_ICON || (!bottom && action==FS_ACT_BACK))
#endif
		action = FS_ACT_NONE;

#ifndef SMALL_NO_DD_FSEL
	ob_undostate(font_tree,FONTCAN,DISABLED);
#endif

	obj = &font_tree[FONTOK];
	obj->ob_x = font_tree[MOVEBOX].ob_width - (obj->ob_width=gr_cw*7) - gr_cw;
	obj->ob_spec.tedinfo->te_font = IBM;

	strcpy(ob_get_text(obj,0,0),"Ok");
	ob_set_hotkey(font_tree,FONTOK,'O');

#ifndef SMALL_NO_DD_FSEL
	if (drag)
	{
		if (_dia_len)
			return (FS_NO_WINDOW);

		if (!fs->drag.app_only)
		{
			obj->ob_x -= gr_cw*3;
			obj->ob_width += gr_cw*3;
			obj->ob_spec.tedinfo->te_font = SMALL;
			ob_set_hotkey(font_tree,FONTOK,'\0');
		}

		obj = options_tree;		
		obj->ob_height = gr_ch*8;
	#ifndef SMALL_NO_ICONIFY
		ob_disable(NULL,obj,WICON,_icfs==NULL,FALSE);
	#else
		ob_dostate(obj,WICON,DISABLED);
	#endif
		ob_disable(NULL,obj,WBACK,!bottom,FALSE);

		for (i=0;i<4;i++)
		{
			ob_undoflag(obj,k=ob_action[i],HIDETREE);
			set_option(k,i==action);
		}

		diamode = WIN_DIAL|MODAL|WD_CLOSER;

		ob_set_text(font_tree,FONTCAN,"All");
		ob_set_hotkey(font_tree,FONTCAN,'A');

		set_font_app(fs->app,fs->win,FALSE);

		hide = (fs->drag.buttons==0);
	}
	else
#endif
	{
		diamode = (mode==FSEL_WIN) ? WIN_DIAL|MODAL|WD_CLOSER : FLY_DIAL;

		obj = options_tree;
		obj->ob_height = gr_ch*3;
		for (i=0;i<4;i++)
			ob_doflag(obj,ob_action[i],HIDETREE);

		ob_set_text(font_tree,FONTCAN,"Cancel");
		ob_set_hotkey(font_tree,FONTCAN,'C');
		hide = FALSE;
	}

	obj = &font_tree[FONTCAN];
	obj->ob_x = font_tree[FONTOK].ob_x - obj->ob_width - (gr_cw<<1);

	ob_hide(font_tree,FONTCAN,hide);
	ob_hide(font_tree,FONTOK,hide);

	ob_hide(font_tree,COLORBOX,hide=!(fs->gadgets & FS_GADGETS_COLOR));
	if (hide)
		act_font.color = BLACK;
	else
	{
		pcolor.current = (act_font.color=max(min(min(fs->color,colors-1),15),0))+1;
		ob_set_text(font_tree,COLOR,ob_get_text(pcolor.popup.p_menu,pcolor.current,0));
	}

	ob_hide(font_tree,EFFECTBX,hide=!(fs->gadgets & FS_GADGETS_EFFECT));
	font_tree[EXAMPLE].ob_height = gr_ch*4;

	if (hide)
	{
		act_font.effect = 0;
		font_tree[EXAMPLE].ob_height += gr_ch;
	}
	else
	{
		hide = !(fs->gadgets & FS_GADGETS_INVERS);
		if (hide)
			act_font.effect = fs->effect & 63;
		else
			act_font.effect = fs->effect & 127;
		ob_disable(NULL,font_tree,FNTINV,hide,FALSE);

		for (i=EFFECTS,x=1,eff=effects;--i>=0;x<<=1)
			ob_select(NULL,font_tree,*eff++,act_font.effect&x,FALSE);
	}

	font_tree[EXAMPBOX].ob_height = font_tree[EXAMPLE].ob_height;

	obj = &font_tree[COLORBOX];
	obj->ob_x = font_tree[SKEWBOX].ob_x + gr_cw;

	ob_hide(font_tree,SKEWBOX,hide=(!speedo || !(fs->gadgets & FS_GADGETS_SKEW) || !(fs->fsel_type & FS_FNT_VECTOR)));
	if (hide)
	{
		sl_list[3] = NULL;
		act_font.skew = 0;
	}
	else
	{
		obj->ob_x += font_tree[SKEWBOX].ob_width;
		sl_list[3] = &sl_skew;
		sl_skew.sl_pos = 45-(act_font.skew=min(max(fs->skew,-450),450))/10;
	}

	set_option(PREVIEW,preview=fs->options.preview);
	set_option(SORT,sort=fs->options.sort);
	set_option(REDRAW,redraw=fs->options.redraw);

	fnt_mins = max(fs->min_pts_size,MIN_SIZE);
	fnt_maxs = fs->max_pts_size>0 ? min(fs->max_pts_size,MAX_SIZE) : MAX_SIZE;

	ob_disable(NULL,font_tree,FONTSIZE,fnt_mins==fnt_maxs,FALSE);

	if (create_list(TRUE)==0)
		return (FS_NO_FONTS);

	fsm = (fs->gadgets & FS_GADGETS_SPEEDO);

	sl_family.sl_line = sl_size.sl_line = sl_face.sl_line = gr_ch;
	sl_family.sl_pos = max(min(act_family-(sl_family.sl_page>>1),sl_family.sl_max-sl_family.sl_page),0);
	sl_face.sl_pos = max(min(act_face-(sl_face.sl_page>>1),sl_face.sl_max-sl_face.sl_page),0);

	new_size(min(max(fs->size,fnt_mins),fnt_maxs),TRUE);
	fnt_def = act_font.size;

	font_tree->ob_x = fs->x;
	font_tree->ob_y = fs->y;
	
	ex_font = act_font;

	if (FSelDialog)
	{
		graf_set_slider(&sl_family,font_tree,GRAF_SET);
		graf_set_slider(&sl_face,font_tree,GRAF_SET);
		graf_set_slider(&sl_size,font_tree,GRAF_SET);
		ob_draw(FSelDialog,0);
		return (FS_SET);
	}
	else if ((FSelDialog=open_dialog(font_tree,(fs->win_title) ? fs->win_title : "FontSelector",NULL,NULL,fs->options.center,fs->options.boxes,diamode,0,sl_list,plist))!=NULL)
	{
		options.p_info = FSelDialog;
		for (;FSelDialog!=NULL && back==FS_ERROR;)
		{
			switch (exit=X_Form_Do(NULL))
			{
			case W_ABANDON:
			#ifndef SMALL_NO_DD_FSEL
				fs->app = -1;
			#endif
				FSelDialog = NULL;
				back = FS_ABANDON;
				break;
			case W_CLOSED:
			#ifndef SMALL_NO_DD_FSEL
				fs->app = -1;
			#endif
				back = FS_OK;
				break;
			default:
				switch (exob=exit&NO_CLICK)
				{
				case FONTOK:
				case FONTCAN:
					ob_select(FSelDialog,font_tree,exob,FALSE,TRUE);
				#ifndef SMALL_NO_DD_FSEL
					if (drag)
					{
						fsel_button:
						graf_mkstate(&d,&d,&d,&k);
						if (exob==FONTCAN)
							set_font(fs->drag.app_only ? ap_id : -1,-1,k);
						else
							set_font(fs->drag.app_only ? ap_id : fs->app,fs->win,k);
					}
					else
				#endif
						back = exob==FONTCAN ? FS_CANCEL : FS_OK;
					break;
				case OPTIONS:
					switch (i=(Popup(&options,POPUP_BTN,XYPOS,0,0,&k,FALSE)&NO_CLICK))
					{
					case PREVIEW:
					case SORT:
					case REDRAW:
						if (i==PREVIEW)
							set_option(PREVIEW,preview=!preview);
						else if (i==REDRAW)
						{
							set_option(REDRAW,redraw=!redraw);
							UpdateExample(FALSE);
							continue;
						}
						else
						{
							set_option(SORT,sort=!sort);
							create_list(FALSE);
						}
						ob_draw(FSelDialog,FACEVIEW);
						ob_draw(FSelDialog,FONTVIEW);
						break;
					default:
						if (i>0)
							for (action=k-3,i=4;--i>=0;)
								set_option(ob_action[i],i==action);
					}
					break;
				case HELP:
					if (fs->help_func!=NULL)
						fs->help_func();
					else
						xalert(1,1,X_ICN_INFO,NULL,SYS_MODAL,BUTTONS_RIGHT,TRUE,"Information",fsel_info,NULL);
					ob_select(FSelDialog,font_tree,exob,FALSE,TRUE);
					break;
				case EXAMPLE:
					if (exit & DOUBLE_CLICK)
						UpdateExample(TRUE);
				#ifndef SMALL_NO_DD_FSEL
					else if (drag && mouse(NULL,NULL))
					{
						ob_pos(font_tree,EXAMPLE,&start);
						start.g_y += start.g_h - ex_height;
						start.g_h = ex_height;
						graf_rt_dragbox(FALSE,&start,&desk,&d,&d,0l);
						graf_mkstate(&x,&y,&d,&k);

						if (get_window(i=wind_find(x,y)))
						{
							if (i==FSelDialog->di_win->handle)
								break;
							app = ap_id;
						}
						else if (!fs->drag.app_only)
						{
							if (owner && (i>0 || !_app) && wind_xget(i,WF_OWNER,&x,&d,&d,&d))
								app = x;
							else if (!multi && !_app)
								app = 0;
							else
								break;
						}
						else if (k & (K_SHIFT|K_ALT))
							app = ap_id;
						else
							break;
						set_font(app,(k & (K_SHIFT|K_ALT)) ? -1 : i,k);
					}
				#endif
					break;
				case FONTVIEW:
					sl = &sl_family;goto fsel_slider;
				case FACEVIEW:
					sl = &sl_face;goto fsel_slider;
				case SIZEVIEW:
					sl = &sl_size;
					fsel_slider:
					graf_rt_slidecursor(sl,exit & DOUBLE_CLICK);
					if ((exit & DOUBLE_CLICK) && !ob_isstate(font_tree,FONTOK,DISABLED))
					{
						ob_select(FSelDialog,font_tree,FONTOK,TRUE,TRUE);
						Event_Timer(50,0,TRUE);
						ob_select(FSelDialog,font_tree,FONTOK,FALSE,TRUE);
					#ifndef SMALL_NO_DD_FSEL
						if (drag)
							goto fsel_button;
						else
					#endif
							back = FS_OK;
					}
				}
			}
		}

		if (FSelDialog)
			close_dialog(FSelDialog,fs->options.boxes);
		FSelDialog = NULL;

		set_output(back);
	}
	else if (diamode & WIN_DIAL)
		back = FS_NO_WINDOW;

	fsel = NULL;
	return (back);
}

#endif
#endif

#ifndef SMALL_NO_XACC_AV
int FontChanged(int app,int win,int id,int size,int effect,int color)
{
	int mbuf[8],*msg = &mbuf[3];

	mbuf[0] = FONT_CHANGED;
	*msg++ = (win<=0 || app<0) ? -1 : win;
	*msg++ = id;
	*msg++ = size;
	*msg++ = color;
	*msg = effect;

	if (app<0)
	{
		XAccBroadCast(mbuf);
		return (TRUE);
	}

	return (AvSendMsg(app,FONT_CHANGED,mbuf));
}

int CallFontSelector(int win,int id,int size,int color,int effects)
{
	XAcc *fsel;
	if ((fsel=find_xacc_xdsc(-1,"XFontSelect"))!=NULL)
	{
		int mbuf[8],*msg = &mbuf[3];
		*msg++ = win>0 ? win : -1;
		*msg++ = id;
		*msg++ = size;
		*msg++ = color;
		*msg = effects;
		return (AvSendMsg(fsel->id,FONT_SELECT,mbuf));
	}
	return (FALSE);
}

int FontAck(int app,boolean ack)
{
	if (find_xacc_xdsc(app,"XFontSelect"))
	{
		int mbuf[8],*msg = &mbuf[3];
		*msg++ = ack ? TRUE : FALSE;
		*((long *) msg)++ = 0;
		*((long *) msg)++ = 0;
		return (AvSendMsg(app,FONT_ACK,mbuf));
	}
	return (FALSE);
}
#endif
