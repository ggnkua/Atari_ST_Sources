/* Test various dialogue functions */

#include <prelude.h>
#include <tos_gem.h>
#include <stdio.h>
#include "tests.h"

#include <nkcc.h>

typedef enum
{ RSHIFT=NKF_RSH,LSHIFT=NKF_LSH,CONTRL=NKF_CTRL,
  ALTERNATE=NKF_ALT,DRAG=16,NO_DRAG=32
} KSTATE;

#define ping Cconout(7);

static int aform_cursor(OBJECT *db, int edob, int xob, int *idx)
{
	objc_edit(db,edob,0,idx,ED_END);
	objc_edit(db,xob, 0,idx,ED_INIT);
	return xob;
}

global
int first_edob(OBJECT *o)
{
	int i = 0;
	while ((o[++i].flags&EDITABLE) eq 0)
		if (o[i].flags&LASTOB)
			return 0;		/* No editable fields */
	return i;
}

/* HR: This code now works for edit objects that are TOUCHEXIT.
       It also uses right button as double click.
 */

int aform_do(OBJECT *db,int start, int *cured, int movob)
{
	int edob,nob,xob,mob,which,cont;
	int idx,mx,my,mb,ks,kr,br;

	if (start eq 0)
		edob = first_edob(db);
	else
		edob = start;

/*	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);
*/
	if (edob)
		objc_edit(db,edob,0,&idx,ED_INIT);

	do
	{
		which=evnt_multi(
			MU_KEYBD|MU_BUTTON, 0,1,1, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,
			&mx,&my,&mb, &ks,&kr,&br);

		if (which & MU_KEYBD)
		{
			cont = form_keybd(db,edob,0,kr,&xob,&kr);
			if (    xob ne 0
				and (db[xob].flags &  EDITABLE) ne 0
				and xob ne edob
			   )
				edob = aform_cursor(db,edob,xob,&idx);
			else
				nob = xob;

			if (kr)
				objc_edit(db,nob = edob,kr,&idx,ED_CHAR);
		}

		if (which & MU_BUTTON)
		{
			nob=objc_find(db,0,MAX_DEPTH,mx,my);
			/* ALTERNATE-left-button or right-button same as double click */
			if ( (ks&ALTERNATE) or (mb&2) )
				br=2;
			if (nob < 0)
			{	ping; cont = true; continue; }
			if (movob and nob eq movob)	/* special case for form_move() */
				break;
			cont = form_button(db,nob,br,&mob);
			xob  = mob&0x7fff;		/* double click on TOUCHEXIT b15 = 1 */
			if (edob and (db[xob].flags & EDITABLE))
			{
				if (xob ne edob)
					edob = aform_cursor(db,edob,xob,&idx);
				nob  = mob;
			}
			else
				nob |= (mob&0x8000);
		}		
	}
	while (cont);
	
	if (edob)
		objc_edit(db,edob,0,&idx,ED_END);

/*	wind_update(END_MCTRL);
	wind_update(END_UPDATE);
*/
	if (cured)
		*cured=edob;
	return nob;
}

static void putnum(OBJECT *o, int i, int v)
{
	TEDINFO *ted = o[i].spec.tedinfo;
	sprintf(ted->text,"%d",v);
}

OBJECT *icon;

char alert[] = "[1][ pid 000 | wants to quit! ][  Ok  ]";

int main(void)
{
	int x,y,w,h,edob = FT2, xa,version=0x666, apid, which;

	apid = appl_init();
	graf_mouse(0,0);

#if 0
	{
		int i,a1,a2,a3,a4;
wind_update(BEG_UPDATE);
		printf("\033E");
		for (i=0; i<=16; i++)
		{
			short ii;
			a1=a2=a3=a4=0;
			ii=i;
			if (i==15) ii=64;
			if (i==16) ii=65;
			appl_getinfo(ii,&a1,&a2,&a3,&a4);
			printf("%d:\t1=%04x,\t2=%04x,\t3=%04x,\t4=%04x\n",ii, a1, a2, a3, a4);
		}
		bios(2,2);
wind_update(END_UPDATE);
	}
#endif
	xa = wind_get(0,'XA',&version);				/* detect XaAES */
	if (rsrc_load("tests.rsc"))
	{
		char malert[128];
		int obno = -1,pap;
		OBJECT *db,*pop,*pops,*menu; TEDINFO *ted;
		ICONBLK *ib;

		int alert = form_alert(1,"[2][ Which kind of test ? ][ WF_TOOLBAR | form_dial/do | free ]");

		rsrc_gaddr(0, T, &db);
		rsrc_gaddr(0, POPS, &pops);
		rsrc_gaddr(0, POP, &pop);
		rsrc_gaddr(0, TMENU, &menu);

		ted = db[XA_VERSION].spec.tedinfo;

		menu_bar(menu, 1);
	
		if (xa)
			sprintf(ted->text,"%04x",version);
		else
			db[XA_VERSION].flags|=HIDETREE;

		form_center(db, &x, &y, &w, &h);
		putnum(db,DTX,x);
		putnum(db,DTY,y);
		putnum(db,DTW,w);
		putnum(db,DTH,h);
		putnum(db,OBX,db->x);
		putnum(db,OBY,db->y);
		putnum(db,OBW,db->w);
		putnum(db,OBH,db->h);

		switch( alert )
		{
		case 1:
		{
			int w1,w2,w3,w4;
			int m[8],event,s,b,kr,br,wi;
			int kind = INFO|NAME|MOVER|CLOSER|MENUBAR;

			bool cont = true;

			wi = wind_create(kind,0,0,640,400);
			wind_set(wi, WF_NAME, "dial_test");
			wind_set(wi, WF_INFO, " Example program for toolbars ");
			wind_set(wi, WF_TOOLBAR, db, 0, edob);
			wind_set(wi, WF_MENU, menu);
			wind_calc(WC_BORDER, kind,
							0, 0, db->w, db->h,
							&w1, &w2, &w3, &w4);
			wind_open(wi, 40, 40, w3, w4);

			do
			{
				event = evnt_multi(MU_BUTTON|MU_KEYBD|MU_MESAG,
								2,3,0,
								0,0,0,0,0,
								0,0,0,0,0,
								m,
								0,0,
								&x,&y,
								&b,&s,&kr,&br);
				if (event&MU_MESAG)
				{
					switch (m[0])
					{
					case WM_TOOLBAR:
						obno = m[4];
						edob = m[5];
						if (obno == OK)
							cont = false;
						if (obno == LARGE_POP)
						{
							int x, y;
							MENU mn = {0};
							
							mn.tree = pops;
							mn.menu = FORM_POPS;
							
							objc_offset(db, LARGE_POP, &x, &y);
							menu_popup(&mn, x, y, &mn);
						}

						db[obno].state &=~ SELECTED;
						wind_set(wi, WF_TOOLBAR, db, obno, edob);		/* redraw toolbar. */ 
						break;
					case WM_TOPPED:
						wind_set(wi, WF_TOP);
						break;
					case WM_CLOSED:
						cont = false;
						break;
					case WM_MOVED:
						wind_set(wi, WF_CURRXYWH, m[4],m[5],m[6],m[7]);
						break;
					case MN_SELECTED:
						if (m[3] == MDIAL and m[4] == QUIT)
							cont = false;
					case AP_TERM:
						cont = false;
					}
				}
				
			} while (cont);

			wind_close(wi);
			wind_delete(wi);
		}
		break;
		case 2:
			form_dial(FMD_START, 0,0,0,0,x,y,w,h);
			while (obno ne OK)
			{
				db[FORM_MODE].state|=SELECTED;		/* cross check! */
				if (xa != 'XA')
				{
					wind_update(BEG_UPDATE);
					objc_draw(db, 0, 10, x,y,w,h);
					wind_update(END_UPDATE);
				}

/* Standard AES builtin function. */

				obno = form_do(db, FT2);
				if (obno == LARGE_POP)
				{
					int x,y;
					objc_offset(db, LARGE_POP, &x, &y);
					form_popup(pop, x, y);
				}
			}
			form_dial(FMD_FINISH, 0,0,0,0,x,y,w,h);
		break;
		default:

			wind_update(BEG_MCTRL);
	
			while (obno ne OK)
			{
				db[FORM_MODE].state&=~SELECTED;
				wind_update(BEG_UPDATE);
				objc_draw(db, 0, 10, x,y,w,h);
				wind_update(END_UPDATE);

/* Emulation of form_do by using form_button, form_keybd and objc_edit. */
 
				obno = aform_do(db, edob, &edob, -1);
				if (obno == LARGE_POP)
				{
					int x,y;
					objc_offset(db, LARGE_POP, &x, &y);
					form_popup(pop, x, y);
				}
				if (obno < 0)
					form_alert(1,"[1][ Double click ][ Ok ]");
			}
			wind_update(END_MCTRL);
		}
		form_dial(FMD_FINISH, 0,0,0,0,x,y,w,h);
		rsrc_free();
	}
/*	sprintf(alert+9,"%03d",apid);
	*(alert+12) = ' ';
	form_alert(1,alert);
*/	appl_exit();
	return 0;
}
