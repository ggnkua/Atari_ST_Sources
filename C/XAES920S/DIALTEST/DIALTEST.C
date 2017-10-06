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

	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);

	if (edob)
		objc_edit(db,edob,0,&idx,ED_INIT);

	do
	{
		which=evnt_multi(
			MU_KEYBD|MU_BUTTON, 2,1,1, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,
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
		}		
	}
	while (cont);
	
	if (edob)
		objc_edit(db,edob,0,&idx,ED_END);

	wind_update(END_MCTRL);
	wind_update(END_UPDATE);

	if (cured)
		*cured=edob;
	return nob;
}

static void putnum(OBJECT *o, int i, int v)
{
	TEDINFO *ted = o[i].spec.tedinfo;
	sprintf(ted->text,"%d",v);
}

char alert[] = "[1][ pid 000 | wants to quit! ][  Ok  ]";

int main(void)
{
	unsigned int w1,w2,w3,w4;
	int m[8],event,s,b,kr,br,wi;
	int x,y,w,h,edob = FT2, xa,version=0x666,

	apid = appl_init();
	graf_mouse(0,0);
	/* The wimdow is only there to get a focus */
	wi = wind_create(0,0,0,640,400);
	wind_open(wi, 40,40,160,100);
	/* catch mesag */
	evnt_mesag(m);

	x = wind_get(0,WF_SCREEN,&w1,&w2,&w3,&w4);
	printf("WF_SCREEN: %d, %ld(%lx), %ld\n",x,((unsigned long)w1<<16)|w2,((unsigned long)w1<<16)|w2,((unsigned long)w3<<16)|w4);
	bios(2,2);

	event = evnt_button(0x2,3,0,&x,&y,&b,&s);

	printf("event:%d, b%d, s%x\n",event,b,s);
	bios(2,2);

	event = evnt_multi(MU_BUTTON|MU_KEYBD|MU_MESAG|MU_TIMER,
					2,3,0,
					0,0,0,0,0,
					0,0,0,0,0,
					m,
					0,0,
					&x,&y,
					&b,&s,&kr,&br);

	printf("event_multi:0x%04x, b%d, s%x\n",event,b,s);
	bios(2,2);

	wind_close(wi);
	wind_delete(wi);
	xa = wind_get(0,'XA',&version);				/* detect XaAES */
	if (rsrc_load("tests.rsc"))
	{
		int obno = -1;
		OBJECT *db; TEDINFO *ted;
		rsrc_gaddr(0, T, &db);
		ted = db[XA_VERSION].spec.tedinfo;
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
		form_dial(FMD_START, 0,0,0,0,x,y,w,h);
		while (obno ne OK)
		{
			if (db[FORM_DO].state&SELECTED)
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
			othw
				db[FORM_MODE].state&=~SELECTED;
				wind_update(BEG_UPDATE);
				objc_draw(db, 0, 10, x,y,w,h);
				wind_update(END_UPDATE);

/* Emulation of form_do by using form_button, form_keybd and objc_edit. */
 
				obno = aform_do(db, edob, &edob, -1);
			}
		}
		form_dial(FMD_FINISH, 0,0,0,0,x,y,w,h);
		rsrc_free();
	}
	sprintf(alert+9,"%03d",apid);
	*(alert+12) = ' ';
	form_alert(1,alert);
	appl_exit();
	return 0;
}
