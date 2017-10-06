/* graphics.c */

#include "header.h"

typedef void *bloc;

#define ABS(x) ((x>0)?(x):(-(x)))
#define SGN(x) ((!(x))?(0):(  ((x>0)?(1):(-1))  ))
#define MAX(a,b) ((a>b)?(a):(b))
#define MIN(a,b) ((a<b)?(a):(b))

#define GAUCHE '<'
#define DROITE '>'
#define HAUT '^'
#define BAS 'v'


extern char *Demostr;

extern int Cheat;

extern bloc Logo,Im,btmp;
extern bloc sprites[36][2];

extern int freezetime;
extern int tmx,tmy,tmlx,tmly;
extern int P2[7][7];
extern int Ntt[7],Tt[7],C[4];
extern int Pp[14],G[7],D[7],P[14];
extern int Pl[7],Px[7],Py[7],Xt[7],Yt[7],M[7],Dx[7],Dy[7],Xd[7],Yd[7];
extern int Oldlv;
extern int Demotab[40][2];
extern int Lndemo;
extern int quit;
extern int Demo;
extern int Demon;

extern int tv,tv1,tv2,tv3,tv4;

extern int I,F,Lives,Lv,Rx,Ry,Ary,J,Z,Rd,W,OldI;
extern long Sc,Stl;
extern int Tm,Ft,X,Y,Ex,Ey,Cc,E;
extern int Dmx,Dmy,Nbec,Nc,Ncb,Npl,N,Xo,Yo;
extern int Pouf,Xpf,Ypf,Uggd,Uggg,Slick,Coily,Egg,Egg2,Cegg,Cegg2;
extern int Plt,Nt,Stand,Nm,Nom,Freeze,T,Dd,No,tmp,Nwtab;

extern char r;


extern char *blocaa[];
extern char *blocab[];
extern char *blocac[];
extern char *blocad[];
extern char *blocba[];
extern char *blocbb[];
extern char *blocbc[];
extern char *blocbd[];
extern char *blocbe[];
extern char *blocbf[];
extern char *blocca[];
extern char *bloccb[];
extern char *bloccc[];
extern char *bloccd[];
extern char *blocda[];
extern char *blocdb[];
extern char *blocdc[];
extern char *blocea[];
extern char *bloceb[];
extern char *blocec[];
extern char *bloced[];
extern char *blocfa[];
extern char *blocfb[];
extern char *blocga[];
extern char *blokaa[];
extern char *blokab[];
extern char *blokba[];
extern char *blokca[];
extern char *blokcb[];
extern char *blokda[];
extern char *blokea[];
extern char *blokeb[];
extern char *blokfa[];
extern char *blokfb[];
extern char *blokga[];
extern char *blokgb[];


int slx[36]=
{
	16,16,16,16,16,16,16,16,16,16,16,16,16,16,32,32,32,
	16,16,16,16,16,16,96,
	32,32,32,32,32,32,16,16,16,16,32,32
};

int sly[36]=
{
	21,21,21,21,24,24,24,24,24,24,10,10,10,10,32,32,32,
	16,16,16,16,34,34,46,
	23,23,26,22,22,24,34,34,31,31,20,20
};

unsigned int Levcl[50]=
{
	0x2f00,0x50f0,0x6ff0,0x8fff,0x4ccc,
	0x1a06,0x30a6,0x5aa6,0x8fff,0x4ccc,
	0x3f84,0x58f4,0x7ff4,0x8fff,0x4ccc,
	0x30ff,0x500f,0x8fff,0x6ccc,0x4888,
	0x1f80,0x38f0,0x5ff8,0x6ccc,0x4888,
	0x208f,0x68ff,0x488f,0x50ff,0x3088,
	0x6f88,0x4f08,0x8ff8,0x5f0f,0x3808,
	0x2800,0x4840,0x3620,0x8cc0,0x6880,
	0x3246,0x4624,0x5482,0x1222,0x0000,
	0x4ff8,0x6f8f,0x88ff,0x3444,0x1222
};

extern unsigned int pal[16];



void loadsprite(n,s)
int n;
char *s[];
{
	int i,j,c,lx,ly,v;
	
	lx=slx[n];
	ly=sly[n];
    pbox(0,0,lx*2,ly*2,FOND);


	for(i=0;i<sly[n];i++)
		for(j=0;j<slx[n];j++)
		{
			v=slx[n]-j-1;
			c=(int)s[i][j];
			if (c!=' ')
			{
				if (c<'A') c-='0';
				else
					if (c<'a') c-='A'-10;
					else
						c-='a'-10;
						
				plot(j,i,c);
				plot(v,i+ly,c);
				plot(j+lx,i,MASK);
				plot(v+lx,i+ly,MASK);
			}
		}

	refresh();
	getbloc(&sprites[n][0],0,0,lx,ly);
	getmask(&sprites[n][0],lx,0);

	if ((n<10)||(n>20))
	{
		getbloc(&sprites[n][1],0,ly,lx,ly);
		getmask(&sprites[n][1],lx,ly);
	}
}


void Cubecolor()
{

	getpalette(pal);
	pal[1]=Levcl[(Lv-1)*5];
	pal[2]=Levcl[(Lv-1)*5+1];
	pal[3]=Levcl[(Lv-1)*5+2];
	pal[7]=Levcl[(Lv-1)*5+3];
	pal[8]=Levcl[(Lv-1)*5+4];
	if (Rd==4)
	{
		pal[3]=0;
		pal[7]=0;
		pal[8]=0;
	}
	setpalette(pal);
	loadsprite(14,blocda);
	loadsprite(15,blocdb);
	loadsprite(16,blocdc);
}


void initsprites()
{
	int i,n;
	
	for(i=0;i<36;i++)
	{
		initbloc(&sprites[i][0]);
		initbloc(&sprites[i][1]);
	}

	n=0;
	
	loadsprite(n++,blocaa);
	loadsprite(n++,blocab);
	loadsprite(n++,blocac);
	loadsprite(n++,blocad);
	loadsprite(n++,blocba);
	loadsprite(n++,blocbb);
	loadsprite(n++,blocbc);
	loadsprite(n++,blocbd);
	loadsprite(n++,blocbe);
	loadsprite(n++,blocbf);
	loadsprite(n++,blocca);
	loadsprite(n++,bloccb);
	loadsprite(n++,bloccc);
	loadsprite(n++,bloccd);
	loadsprite(n++,blocda);
	loadsprite(n++,blocdb);
	loadsprite(n++,blocdc);
	loadsprite(n++,blocea);
	loadsprite(n++,bloceb);
	loadsprite(n++,blocec);
	loadsprite(n++,bloced);
	loadsprite(n++,blocfa);
	loadsprite(n++,blocfb);
	loadsprite(n++,blocga);
	loadsprite(n++,blokaa);
	loadsprite(n++,blokab);
	loadsprite(n++,blokba);
	loadsprite(n++,blokca);
	loadsprite(n++,blokcb);
	loadsprite(n++,blokda);
	loadsprite(n++,blokea);
	loadsprite(n++,blokeb);
	loadsprite(n++,blokfa);
	loadsprite(n++,blokfb);
	loadsprite(n++,blokga);
	loadsprite(n++,blokgb);
		
}

void freesprites()
{
	int i;
	
	for(i=0;i<36;i++)
	{
		freebloc(&sprites[i][0]);
		freebloc(&sprites[i][1]);
	}
}
