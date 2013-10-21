#include <hr.h>
#include <tos_gem.h>
#include <math.h>
#include <stdlib.h>
/* #include <linea.h> */
#include "worms.h"

#define willekeur

int    Xcirc[20][50],Ycirc[20][50];
int    Tail[20];
int    Wastail[20];
int    Nx,Ny;
double Rich[20];
double Chg,D,Rnd(),
       Pi=3.1415926536,Hm=640,Vm=40,gr180=180;

int R=6;
int S=4;
int Hoek=10;
int Worm=15;
int Worms=3;
int vdivars;
int i,hl,J,I,inkey;
int xy[]={0,0,639,399};
OBJECT *db;
TEDINFO *wl,*wa,*wg,*wr,*ws;

extern V_WORKOUT scr;
extern RECT scr_grect;

double Rnd(void)
{
	double r;
	r=((double)Random())/(double)16777216;
	return r;
}

int main(void)
{
	static int eerste=0;
	int obno,x,y,w,h;
	char *dump;
	appl_init();
	if (rsrc_load("WORMS.RSC") false)
	{
		form_alert(1,"[1][Geen Resource!][ ACH ]");
		appl_exit();return 1;
	}
	instt_scr(&hl,0L);
	Hm=scr.w;
	Vm=scr.h;
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
		obno=form_move(db,hl,dump,TRUE,WORML,WMOVE,&scr_grect);
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
			Worm =atoi(wl->text);
			Worms=atoi(wa->text);
			Hoek =atoi(wg->text);
			R    =atoi(wr->text);
			S    =atoi(ws->text);
			D=Hoek*Pi/gr180;			/*  radialen */
			v_clrwk(hl);
			loop(J,20)
			{
				loop(I,50)
				{
					Xcirc[J][I]=0;
					Ycirc[J][I]=0;
				}
			}
			loop(J,Worms)
			{
				Xcirc[J][0]=(int)(Rnd()*Hm);
				Ycirc[J][0]=(int)(Rnd()*Vm);
				Rich[J]=Rnd()*2*Pi;
				Tail[J]=0;
			}
		}
		do
		{
			do
			{
#ifdef willekeur
				J=Rnd() * Worms;
#else
				loop(J,Worms)
#endif
				{
					Wastail[J]= Tail[J];
					Tail   [J]=(Tail[J] mod Worm)+1;
					xy[0]=xy[2]=Xcirc[J][Tail[J]];
					xy[1]=xy[3]=Ycirc[J][Tail[J]];
					if (not ( xy[0] eq 0 and xy[1] eq 0) )
					{
						v_circle(hl,xy[0],xy[1],R);
/*						put_pixel(xy[0],xy[1],1);	*/
						v_pline(hl,2,xy);
					}
					Chg=Rnd();
					if (Chg<0.5)
					{
						Rich[J]+=D;
					othw
						Rich[J]-=D;
					}
					Nx=(Xcirc[J][Wastail[J]]+(int)(S*cos(Rich[J])))
					   mod scr.w;
					Ny=(Ycirc[J][Wastail[J]]+(int)(S*sin(Rich[J])))
					   mod scr.h;

					if (Nx<0)
					{
						Nx=Nx+scr.w;
					}
					if (Ny<0)
					{
						Ny=Ny+scr.h;
					}
					Xcirc[J][Tail[J]]=Nx;
					Ycirc[J][Tail[J]]=Ny;
					v_circle(hl,Nx,Ny,R);
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

void dummy_voor_digger(void)
{
	main();
}
