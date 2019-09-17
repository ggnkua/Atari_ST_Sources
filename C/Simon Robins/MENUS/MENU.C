/*	$Id: MENU.C,v 1.23 1994/06/12 22:00:00 SCR Exp SCR $ */

/*
 *	override the default Lattice version that
 *	will not let you do this: ELTS(&xywh)
 */
#define ELTS(r)	r.g_x,r.g_y,r.g_w,r.g_h

#include <aes.h>
#include <vdi.h>
#include <cookie.h>
#include <linea.h>
#include <taddr.h>
#include <string.h>

#include "menu.h"
#include "general.h"
#include "get_put.h"

#define MENUTREE ((((MENUBLK *)pb->pb_parm)->mb_data).mn_tree)

typedef struct _menublk
{
	int		(*mb_code)(PARMBLK *);
	struct	_menublk *mb_parm;
	MENU	mb_data;
	void	*mb_spec;
} MENUBLK;

__regargs int _AESif(long);

static short Menu_Item;
static short Menu_Parent;
static OBJECT *Menu_Tree;
static OBJECT *Menu_Bar;

static short mb;
static short mx;
static short my;

static GRECT Menu_Desk;
static short Menu_In[11] = {1,1,1,1,1,1,1,1,1,1,2};
static short Menu_Out[57];
static short Menu_Ext[57];

static short Menu_Vid = 0;
static short Charw, Charh, Boxw, Boxh;

#define MagX	(0x4D616758)
static short Legal;

static void legal_method(void)
{
	long cookie;

	if(getcookie(MagX, &cookie))
		Legal = 1;
	else if(_AESglobal[0] < 0x0200)
		Legal = 1;
	else
		Legal = 0;
}

static menu_init(void)
{
	legal_method();
	if(!Menu_Vid)
	{
		if(!Legal)
			linea0();
		Menu_Vid = graf_handle(&Charw, &Charh, &Boxw, &Boxh);
		if(Menu_Vid)
		{
			v_opnvwk(Menu_In, &Menu_Vid, Menu_Out);
			vq_extnd(Menu_Vid, 1, Menu_Ext);
			wind_get(DESK, WF_WXYWH, ELTS(&Menu_Desk));
			
		}
	}
	return Menu_Vid;
}

#define MENUBLK_SIZE	(64)

MENUBLK menublk[MENUBLK_SIZE];

static int menu_entry(void)
{
	int x;

	for(x = 0; x < MENUBLK_SIZE; x++)
		if(menublk[x].mb_code == NULL)
			return x;
	return -1;
}

static void menu_xywh(OBJECT *tree, int this, GRECT *r)
{
	int that = this;

	*r = *(GRECT *)&OB_X(this);

	while(this > NIL)
	{
		if(OB_TAIL(this) == that)
		{
			r->g_x += OB_X(this);
			r->g_y += OB_Y(this);
		}
		that = this;
		this = OB_NEXT(that);
	}
}

static void menu_draw(OBJECT *tree, int obj)
{
	GRECT xywh;
	short pxy[4];
	short border;

	menu_xywh(tree, obj, &xywh);
	switch(OB_TYPE(obj))
	{
	case G_STRING:
		vswr_mode(Menu_Vid, MD_TRANS);
		if(OB_STATE(obj) & DISABLED)
			vst_effects(Menu_Vid, SHADED);
		else
			vst_effects(Menu_Vid, 0);
		v_gtext(Menu_Vid, xywh.g_x, xywh.g_y, OB_SPEC(obj));
		break;
	case G_BOX:
		if((border = OB_BORDER(obj)) < 0)
			rc_adjust(&xywh, border);
		gtovrect(&xywh, pxy);
		vswr_mode(Menu_Vid, MD_REPLACE);
		vsf_interior(Menu_Vid, FIS_HOLLOW);
		v_bar(Menu_Vid, pxy);
		break;
	}
	if(OB_STATE(obj) & CHECKED)
		v_gtext(Menu_Vid, xywh.g_x, xywh.g_y, "");
}

static void menu_walk(OBJECT *tree, int this, void (*proc)(OBJECT *, int))
{
	int start = this;
	int that = this;

	while(this > NIL)
	{
		if(OB_TAIL(this) != that)
		{
			that = this;
			this = NIL;
			proc(tree, that);
			this = OB_HEAD(that);
			if(this <= NIL)
				this = OB_NEXT(that);
		}else{
			that = this;
			this = OB_NEXT(that);
		}
		if(this == start)
			return;
	}
}
	
static void menu_toggle(OBJECT *tree, int obj)
{
	GRECT xywh;
	short pxy[4];

	if(obj <= NIL)
		return;
	if(OB_STATE(obj) & DISABLED)
		return;
	menu_xywh(tree, obj, &xywh);
	gtovrect(&xywh, pxy);
	vswr_mode(Menu_Vid, MD_XOR);
	vsf_interior(Menu_Vid, FIS_SOLID);
	v_hide_c(Menu_Vid);
	vr_recfl(Menu_Vid, pxy);
	v_show_c(Menu_Vid, 1);
}

static short XPos, YPos, Status, Keystate;

static int menu_pause(int time, GRECT *xywh)
{
	volatile long *start	= (long *)0x4ba;
			 long end		= *start + time;
	int inside;

	v_show_c(Menu_Vid, 1);

	do {
		vq_mouse(Menu_Vid, &Status, &XPos, &YPos);
		if(xywh != NULL)
			if(!(inside = rc_inside(XPos, YPos, xywh)))
				break;
	} while(*start < end);

	v_hide_c(Menu_Vid);
	return inside;
}

#if 0
static short fill_attr[5];
static short text_attr[10];
#endif
static short junk;

static void menu_beg(void)
{
	if(Menu_Vid)
	{
#if 0
		vqf_attributes(Menu_Vid,fill_attr);
		vqt_attributes(Menu_Vid,text_attr);
#endif
		vsf_color(Menu_Vid, BLACK);
		vsf_perimeter(Menu_Vid, 1);
		vst_alignment(Menu_Vid, 0, 5, &junk, &junk);
		vst_color(Menu_Vid, BLACK);
		vst_effects(Menu_Vid, 0);
	}
}

#if 0
static void menu_end(void)
{
	if(Menu_Vid)
	{
		vsf_interior(Menu_Vid, fill_attr[0]);
		vsf_color(Menu_Vid, fill_attr[1]);
		vsf_style(Menu_Vid, fill_attr[2]);
		vswr_mode(Menu_Vid, fill_attr[3]);
		vsf_perimeter(Menu_Vid, fill_attr[4]);

		vst_alignment(Menu_Vid, text_attr[3], text_attr[4], &junk, &junk);
		vst_color(Menu_Vid, text_attr[1]);
		vst_effects(Menu_Vid, 0);
	}
}
#endif

static void menu_find(OBJECT *tree, int obj)
{
	GRECT xywh;

	menu_xywh(tree, obj, &xywh);	

	if(rc_inside(XPos, YPos, &xywh))
		Menu_Item = obj;
}

static void menu_do(OBJECT *tree, int item)
{
	int prev;

	prev = -3;
	do{
		vq_mouse(Menu_Vid, &Status, &XPos, &YPos);
		vq_key_s(Menu_Vid, &Keystate);
		Menu_Item = -3;
		menu_walk(tree, item, menu_find);
		if(prev != Menu_Item)
			menu_toggle(tree, prev);
		if(Menu_Item == -3)
			break;
		if(prev != Menu_Item)
			menu_toggle(tree, Menu_Item);
		prev = Menu_Item;
	}while(!(Status & 1));
	if(OB_STATE(Menu_Item) & DISABLED)
		Menu_Item = -3;
}

static int __stdargs __saveds _menu_draw(PARMBLK *pb)
{
	MENUBLK *menublk = (MENUBLK *)pb->pb_parm;

	menu_beg();
	if(pb->pb_currstate == pb->pb_prevstate)
	{
		vswr_mode(Menu_Vid, MD_TRANS);
		v_gtext(Menu_Vid, pb->pb_x, pb->pb_y, menublk->mb_spec);
	}else{
		GRECT parent;
		short bar[4];
		int pobj;

		gtovrect((GRECT *)&pb->pb_x, bar);
		vswr_mode(Menu_Vid, MD_XOR);
		vsf_interior(Menu_Vid, FIS_SOLID);
		vr_recfl(Menu_Vid, bar);
		pobj = objc_parent(pb->pb_tree, pb->pb_obj);
		menu_xywh(pb->pb_tree, pobj, &parent);
		if(menu_pause(50, (GRECT *)&pb->pb_x) && pb->pb_currstate & SELECTED)
		{
			OBJECT *tree = MENUTREE;
			GRECT xywh;
			int menu, item;

			menu = (((MENUBLK *)pb->pb_parm)->mb_data).mn_menu;
			item = (((MENUBLK *)pb->pb_parm)->mb_data).mn_item;
			OB_X(menu) = pb->pb_x + pb->pb_w - Charw - 1;
			OB_Y(menu) = pb->pb_y - OB_Y(item);
			if((OB_X(menu) + OB_WIDTH(menu)) >= (Menu_Desk.g_x + Menu_Desk.g_w))
				OB_X(menu) = pb->pb_x - OB_WIDTH(menu) + Charw - 1;
			rc_constrain(&Menu_Desk, (GRECT *)&OB_X(menu));
			xywh = *(GRECT *)&OB_X(menu);
			if(menu_get(Menu_Vid, &xywh, Menu_Ext[4]))
			{
				menu_walk(MENUTREE, menu, menu_draw);
				v_show_c(Menu_Vid, 1);
				do{
					do{
						menu_do(MENUTREE, menu);
						if(Status &= 1)
							goto button;
					}while(rc_inside(XPos, YPos, (GRECT *)&pb->pb_x));
				}while(rc_inside(XPos, YPos, &Menu_Desk) && !rc_inside(XPos, YPos, &parent));
button:
				menublk->mb_data.mn_keystate = Keystate;
				if((Status) && rc_inside(XPos, YPos, &xywh))
				{
					if(Menu_Item != -3)
					{
						if(!Legal)
						{
#if 0
							gcurx = V_GCURX;
							gcury = V_GCURY;
							V_GCURX = pb->pb_x;
							V_GCURY = pb->pb_y;
							v_hide_c(Menu_Vid);
#else
							vq_mouse(Menu_Vid, &mb, &mx, &my);
							v_dspcur(Menu_Vid, pb->pb_x, pb->pb_y);
#endif
						}
						Menu_Parent = menublk->mb_data.mn_menu;
						Menu_Tree = menublk->mb_data.mn_tree;
					}
				}
				else if(Status && rc_inside(XPos, YPos, (GRECT *)&pb->pb_x))
				{
					Menu_Item = -1;
					Menu_Parent = pobj;
					Menu_Tree = Menu_Bar;
				}
				else if(Status)
					Menu_Item = -3;
				else
					Menu_Item = -2;

				v_hide_c(Menu_Vid);
				menu_put(Menu_Vid);
			}
		}
	}
#if 0
	menu_end();
#endif
	return pb->pb_currstate;
}

static MENUBLK *find_menublk(OBJECT *tree, int menu)
{
	int x;

	for(x = 0; x < MENUBLK_SIZE; x++)
		if(menublk[x].mb_data.mn_tree == tree)
			if(menublk[x].mb_data.mn_menu == menu)
				return &menublk[x];
	return NULL;
}

static int _menu_istart(int flag, OBJECT *tree, int imenu, int item)
{
	_AESintin[0] = flag;
	_AESintin[1] = imenu;
	_AESintin[2] = item;

	_AESaddrin[0] = tree;

	return _AESif(0x26030101);
}

/*
 * flag		0/1 - get/set
 * tree 	pointer to submenu object tree
 * imenu	parent of submenu items
 * item		item to align to menu entry
 */
int menu_istart(int flag, OBJECT *tree, int imenu, int item)
{
	MENUBLK *menublk;

#ifndef TESTING
	if((_AESglobal[0] >= 0x0330) && (_AESglobal[0] != 0x0399))
		return _menu_istart(flag, tree, imenu, item);
#endif

	if((menublk = find_menublk(tree, imenu)) == NULL)
		return 0;

	switch(flag)
	{
	case 0:
		return menublk->mb_data.mn_item;
	case 1:
		if(item < OB_HEAD(imenu))
			item = OB_HEAD(imenu);
		if(item > OB_TAIL(imenu))
			item = OB_TAIL(imenu);

		if(imenu != ROOT)
		{
			OB_X(ROOT) = 0;
			OB_WIDTH(ROOT) = Menu_Out[0] + 1;
			OB_Y(ROOT) = 0;
			OB_HEIGHT(ROOT) = Menu_Out[1] + 1;
		}

		return (menublk->mb_data.mn_item = item);
	}
	return 0;
}

static int _menu_attach(int flag, OBJECT *tree, int item, MENU *data)
{
	_AESintin[0] = flag;
	_AESintin[1] = item;

	_AESaddrin[0] = tree;
	_AESaddrin[1] = data;

	return _AESif(0x25020102);
}

int menu_attach(int flag, OBJECT *tree, int item, MENU *data)
{
	unsigned int x;

	data->mn_tree->ob_x = 0;	/*	AES 3.40 bug fix	*/
	data->mn_tree->ob_y = 0;		

#ifndef TESTING
	if((_AESglobal[0] >= 0x0330) && (_AESglobal[0] != 0x0399))
		return _menu_attach(flag, tree, item, data);
#endif

#if 0
	if(!Menu_Vid)
		if(!menu_init())
			return 0;
#endif
	if(Menu_Bar == NULL)
		Menu_Bar = tree;
	else
		if(tree != Menu_Bar)
			return 0;

	switch(flag)
	{
	case ME_ATTACH:
		if(OB_TYPE(item) != G_STRING)
			return 0;
		if((x = menu_entry()) == -1)
			return 0;
		((char *)OB_SPEC(item))[strlen(OB_SPEC(item)) - 2] = 0x3;
		menublk[x].mb_code = _menu_draw;
		menublk[x].mb_parm = &menublk[x];
		menublk[x].mb_data = *data;
		menublk[x].mb_spec = OB_SPEC(item);
		OB_FLAGS(item) |= SUBMENU;
		OB_SPEC(item) = &menublk[x];
		OB_TYPE(item) = ((x + 128) << 8) + G_PROGDEF;
		menu_istart(1, data->mn_tree, data->mn_menu, data->mn_item);
		return 0;
	case ME_INQUIRE:
		return 1;
	case ME_REMOVE:
		x = (OB_TYPE(item) >> 8) - 128;
		OB_TYPE(item) = G_STRING;
		OB_FLAGS(item) &= ~SUBMENU;
		OB_SPEC(item) = menublk[x].mb_spec;
		menublk[x].mb_code = NULL;
		return 0;
	}
	return 1;
}

static int _evnt_multi(int flags,
				int bclicks, int bmask, int bstate,
				int m1flag, int m1x, int m1y, int m1w, int m1h,
				int m2flag, int m2x, int m2y, int m2w, int m2h,
				short *msg,
				int locount, int hicount,
				short *mx, short *my, short *mb, short *ks,
				short *kc, short *mc)
{
	_AESintin[0] = flags;
	_AESintin[1] = bclicks;
	_AESintin[2] = bmask;
	_AESintin[3] = bstate;
	_AESintin[4] = m1flag;
	_AESintin[5] = m1x;
	_AESintin[6] = m1y;
	_AESintin[7] = m1w;
	_AESintin[8] = m1h;
	_AESintin[9] = m2flag;
	_AESintin[10]= m2x;
	_AESintin[11]= m2y;
	_AESintin[12]= m2w;
	_AESintin[13]= m2h;
	_AESintin[14]= locount;
	_AESintin[15]= hicount;

	_AESaddrin[0] = msg;

	_AESif(0x19100701);

	*mx = _AESintout[1];
	*my = _AESintout[2];
	*mb = _AESintout[3];
	*ks = _AESintout[4];
	*kc = _AESintout[5];
	*mc = _AESintout[6];

	return _AESintout[0];
}

int evnt_multi(	int flags,
				int bclicks, int bmask, int bstate,
				int m1flag, int m1x, int m1y, int m1w, int m1h,
				int m2flag, int m2x, int m2y, int m2w, int m2h,
				short *msg,
				int locount, int hicount,
				short *x, short *y, short *button, short *kstate,
				short *kreturn, short *breturn)
{
	int events;

	do
	{
		Menu_Item = -2;
		events = _evnt_multi(flags,
						bclicks, bmask, bstate,
						m1flag, m1x, m1y, m1w, m1h,
						m2flag, m2x, m2y, m2w, m2h,
						msg,
						locount, hicount,
						x, y, button, kstate,
						kreturn, breturn);
#ifndef TESTING
		if((_AESglobal[0] < 0x0330) || (_AESglobal[0] == 0x0399))
#endif
		if((events & MU_MESAG) && (msg != NULL) && (msg[0] == MN_SELECTED))
		{
			switch(Menu_Item)
			{
			default:
				msg[4] = Menu_Item;
				if(!Legal)
#if 1
					v_dspcur(Menu_Vid, mx, my);
#else
				{
					V_GCURX = gcurx;
					V_GCURY = gcury;
					v_show_c(Menu_Vid, 1);
				}
#endif
			case -1:
				msg[5] = (short)((long)Menu_Tree) >> 16;
				msg[6] = (short)((long)Menu_Tree) & 0xFFFF;
				msg[7] = Menu_Parent;
				break;
			case -2:
				msg[5] = (short)((long)Menu_Bar) >> 16;
				msg[6] = (short)((long)Menu_Bar) & 0xFFFF;
				msg[7] = objc_parent(Menu_Bar, msg[4]);
				break;
			case -3:
				events &= ~MU_MESAG;
				menu_tnormal(Menu_Bar, msg[3], 1);
				break;
			}
		}
	}
	while(!events);

	return events;
}

int evnt_mesag(short *msg)
{
	short j;

	evnt_multi(MU_MESAG,
				1,1,1,
				0,0,0,0,0,
				0,0,0,0,0,
				msg,
				0,0,
				&j, &j, &j, &j,
				&j, &j);
	return 1;
}

int menu_bar(OBJECT *tree, int mode)
{
#ifndef TESTING
	if((_AESglobal[0] < 0x0330) || (_AESglobal[0] == 0x0399))
#endif
	{
		switch(mode)
		{
		case 0:
			if(Menu_Vid)
				v_clsvwk(Menu_Vid);
			Menu_Vid = 0;
			break;
		case 1:
			if(!menu_init())
				return 0;
			break;
		}
	}

	_AESintin[0] = mode;
	_AESaddrin[0] = tree;
	return _AESif(0x1E010101);
}

