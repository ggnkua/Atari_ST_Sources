
#include <prelude.h>
#include <stdlib.h>
#include <np_aes.h>
#include "common\aaaa_lib.h"
#include "worms.h"

#include <math.h>

#define willekeur
#define WMS 20
#define WML 50

int    xc[WMS][WML],yc[WMS][WML];
int    tail[WMS];
int    wastail[WMS];
int    nx,ny;
double rich[WMS];
double chg,d,
       pi=3.1415926536, hm=640, vm=400, gr180=180;

int r=6;
int s=4;
int hoek=10;
int worm=15;
int worms=3;
int vdivars;
int hl,i,j,inkey;
OBJECT *db;
TEDINFO *wl,*wa,*wg,*wr,*ws;

extern V_WORKOUT scr;
extern RECT scr_grect;

#if 0
int testswitch(int s)
{
	int j = 0,i;
	/* geen block; triviaal maar NIET betekenisloos. */
	switch(s) case 6: case 5: case 3: s=0;

/* iets voor de eerste case; alleen zinvol voor declarations zonder initialization code */
	switch(s)
	{
		int k = 100;

		case 3: j = k+3; break;
		case 5: j = 4; break;
		case 8: j = k+5; break;
		case 13:j = 6;
		default:
			return j;
	}
	return j;
}
#endif

long Rondom(void);

double rond(int seed, int sood, int saad)
{
	long rand;
	rand = Rondom()+seed-sood+saad;
	rand = Random()+seed-sood+saad;
	return rand/16777216F;
}

double rnd(void)
{
	return Random()/16777216F;
}

int main(void)
{
	static int eerste=0;
	short xy[]={0,0,639,399};
	short obno,x,y,w,h;
	char *dump;
	appl_init();
	if (rsrc_load("WORMS.RSC") eq 0)
	{
		form_alert(1,"[1][Geen Resource!][ ACH ]");
		appl_exit();return 1;
	}
	hl = instt_scr();
	hm=scr.w;
	vm=scr.h;
	xy[2]=scr.w;
	xy[3]=scr.h;
	vs_clip(hl,TRUE,xy);
	rsrc_gaddr(0,DB,&db);
	wl=db[WORML].spec.tedinfo;
	wa=db[WORMEN].spec.tedinfo;
	wg=db[WORMK].spec.tedinfo;
	wr=db[WORMR].spec.tedinfo;
	ws=db[WORMS].spec.tedinfo;
	form_center(db,&x,&y,&w,&h);
	do
	{
		mpijl;
		keusaf(db[OK]);
		keusaf(db[QUIT]);
		keusaf(db[CONT]);
		dump=form_save(db,0,hl);
		obno=form_move(db,hl,dump,TRUE,WORML,WMOVE,0,&scr_grect);
		form_rest(db,0,hl,dump);
		if (obno eq QUIT) break;
		hidem;
		deffill(hl,1,1,0,0);
/*				   color
					 interior
					   style
					     prerimeter	*/
		vswr_mode(hl,3);
		if (    obno eq OK
			or (obno eq CONT and eerste eq 0)  )
		{
			eerste=1;
			worm =atoi(wl->text);
			if (worm > WML)
				worm = WML;
			worms=atoi(wa->text);
			if (worms > WMS)
				worms = WMS;
			hoek =atoi(wg->text);
			r    =atoi(wr->text);
			s    =atoi(ws->text);
			d=hoek*pi/gr180;			/*  radialen */
			v_clrwk(hl);
			loop(j,WMS)
			{
				loop(i,WML)
				{
					xc[j][i]=0;
					yc[j][i]=0;
				}
			}
			loop(j,worms)
			{
				xc[j][0]=(int)(rnd()*hm);	 /* fintrz! */
				yc[j][0]=(int)(rnd()*vm); 	 /* fintrz! */
				rich[j]=rnd()*2*pi;
				tail[j]=0;
			}
		}
		do
		{
			do
			{
#ifdef willekeur
				j=rnd() * worms;
#else
				loop(j,worms)
#endif
				{
					wastail[j]= tail[j];
					tail   [j]=(tail[j] mod worm)+1;
					xy[0]=xy[2]=xc[j][tail[j]];
					xy[1]=xy[3]=yc[j][tail[j]];
					if (not ( xy[0] eq 0 and xy[1] eq 0) )
					{
						v_circle(hl,xy[0],xy[1],r);
/*						put_pixel(xy[0],xy[1],1);	*/
						v_pline(hl,2,xy);
					}
					chg=rnd();
					if (chg<0.5)
						rich[j]+=d;
					else
						rich[j]-=d;

					nx=(xc[j][wastail[j]]+(int)(s*cos(rich[j])))%scr.w;
					ny=(yc[j][wastail[j]]+(int)(s*sin(rich[j])))%scr.h;

					if (nx<0)
						nx=nx+scr.w;

					if (ny<0)
						ny=ny+scr.h;

					xc[j][tail[j]]=nx;
					yc[j][tail[j]]=ny;
					v_circle(hl,nx,ny,r);
				}
				inkey=Crawio(0xFF);
			}
			while(inkey eq 0);
			inkey&=0xFF;
			if (inkey eq ' ') inkey=Bconin(2)&0xFF;
		}
		while(inkey eq 'c');
		showm;
	}
	while(inkey ne 'q');
	v_clsvwk(hl);
	appl_exit();
	return 0;
}
