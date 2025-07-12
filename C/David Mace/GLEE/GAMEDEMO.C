#include <osbind.h>
#include <linea.h>
#include <bios.h>
#include <xbios.h>
#include <gamedemo.h>

/* Subroutine to get joystick packets from the keyboard processor */
unsigned int JOY0,JOY1;
unsigned char kc[4];
getpack(p)
	unsigned char *p;
{
	JOY0=kc[0]=*p++;
	JOY1=kc[1]=*p++;
	     kc[2]=*p++;
	     kc[3]=*p++;
}

#define JUP	0x01
#define JDOWN	0x02
#define JLEFT	0x04
#define JRIGHT	0x08
#define JFIRE	0x80


main()
{
int startpal[16],i;
register struct kbdvbase *kbp;
void (*old_joyvec)();

	/* Set up keyboard joystick vectors */
	kbp=Kbdvbase();
	old_joyvec=kbp->kb_joyvec;
	kbp->kb_joyvec=getpack;

	linea0();
	for(i=0;i<16;++i)
		startpal[i]=Setcolor(i,-1);
	Setpallete(palette);

	main_game();

	Setpallete(startpal);
	kbp->kb_joyvec=old_joyvec;
	exit(0);
}

struct DIR {int x,y;} dir[16]={
0,-2, 1,-2, 2,-2, 2,-1,  2,0,   2,1,   2,2,   1,2,
 0,2, -1,2, -2,2, -2,1, -2,0, -2,-1, -2,-2, -1,-2};

int sshp[16]={SSA,SSB,SSC,SSD,SSE,SSF,SSG,SSH,SSI,SSJ,SSK,SSL,SSM,SSN,SSO,SSP};

main_game()
{
int sx=160,sy=100,sdir=0,sa=0;
unsigned int tl;
int bonk;
char checkjoy=0x16;
     do {
	for(tl=0;tl<4096;++tl);
	Ikbdws(0,&checkjoy);
	if(JOY1&JLEFT)
		{
		bonk=blit(sshp[sdir],sx,sy,0);
		--sdir;
		if(sdir<0)
			sdir=15;
		bonk=blit(sshp[sdir],sx,sy,1);
		}
	if(JOY1&JRIGHT)
		{
		bonk=blit(sshp[sdir],sx,sy,0);
		sdir=++sdir%16;
		bonk=blit(sshp[sdir],sx,sy,1);
		}
	if(JOY1&JUP)
		{
		bonk=blit(sshp[sdir],sx,sy,0);
		sx+=dir[sdir].x;
		sy+=dir[sdir].y;
		bonk=blit(sshp[sdir],sx,sy,1);
		if(bonk)
			{
			sx-=dir[sdir].x;
			sy-=dir[sdir].y;
			}
		}
	if(JOY1&JDOWN)
		{
		bonk=blit(sshp[sdir],sx,sy,0);
		sx-=dir[sdir].x;
		sy-=dir[sdir].y;
		bonk=blit(sshp[sdir],sx,sy,1);
		if(bonk)
			{
			sx+=dir[sdir].x;
			sy+=dir[sdir].y;
			}
		}
	} while(!(Cconis()));
}

/* Blit object from source form to screen RAM */
blit(ob,dx,dy,sf)
	int ob,dx,dy,sf;
{
static struct la_blit blt; /* See Osbind.h for an explanation of this struct */

#define TOP	0
#define LEFT	0
#define RIGHT	319
#define BOTTOM	199

int bonk=0;

#define SX	blt.bb_s.bl_xmin
#define SY	blt.bb_s.bl_ymin
#define WWD	blt.bb_b_wd
#define HHT	blt.bb_b_ht
#define DX	blt.bb_d.bl_xmin
#define DY	blt.bb_d.bl_ymin
/* Calculate for clipping & return mask for border colisions */
/* 1=left, 2=right, 4=top, 8=bottom 16=off screen, 0=OK */
	SX=defs[ob].x;
	SY=defs[ob].y;
	WWD=defs[ob].w;
	HHT=defs[ob].h;
	DX=defs[ob].xo+dx;
	DY=defs[ob].yo+dy;
	if(DX<LEFT)
		{
		bonk|=1;
		if(DX+WWD<0)
			bonk|=16;
		SX=SX-DX;
		WWD-=LEFT-DX;
		DX=0;
		}
	else if((DX+WWD)>RIGHT)
		{
		bonk|=2;
		if(DX>RIGHT)
			bonk|=16;
		WWD=RIGHT-DX;
		}
	if(DY<TOP)
		{
		bonk|=4;
		if(DY+HHT<TOP)
			bonk|=16;
		SY=SY-DY;
		HHT-=TOP-DY;
		DY=0;
		}
	else if((DY+HHT)>BOTTOM)
		{
		bonk|=8;
		if(DY>BOTTOM)
			bonk|=16;
		HHT=BOTTOM-DY;
		}
	if(!(bonk & 16)) /* If sprite not undisplayable, display it */
		{
		blt.bb_plane_ct=VPLANES;
		if(sf)
			{
			blt.bb_fg_col=0;
			blt.bb_bg_col=0;
			blt.bb_op_tab[0]=7;
			blt.bb_op_tab[1]=7;
			blt.bb_op_tab[2]=7;
			blt.bb_op_tab[3]=7;
			}
		else
			{
			blt.bb_fg_col=0;
			blt.bb_bg_col=0;
			blt.bb_op_tab[0]=0;
			blt.bb_op_tab[1]=0;
			blt.bb_op_tab[2]=0;
			blt.bb_op_tab[3]=0;
			}

		blt.bb_s.bl_form=form;
		blt.bb_s.bl_nxwd=gnxwd;
		blt.bb_s.bl_nxln=gnxln;
		blt.bb_s.bl_nxpl=gnxpl;
		blt.bb_d.bl_form=Physbase();
		blt.bb_d.bl_nxwd=VPLANES*2;
		blt.bb_d.bl_nxln=VWRAP;
		if(VPLANES==1)
			blt.bb_d.bl_nxpl=0;
		else
			blt.bb_d.bl_nxpl=2;
		blt.bb_p_addr=0;
		linea7(&blt);
	}
	return(bonk);
}
