/* warzone.c
Guillaume LAMONOCA
E.S.E Promo 94
*/

#include "header.h"

/* definir REALCALC au lieu de INTEGERCALC lorsque on
	beneficie d'une grande puissance de calcul,
	ou si la resolution devient trop grande pour
	que les erreurs d'arrondies passent inapercues. */

#define REALCALC


#define ABS(x) ((x>0)?(x):(-(x)))

#define YELLOW 6
#define LIGHTRED 4
#define GREEN 12


int gamepal[16]=
{
	0x0000,0x1008,0x2080,0x3088,
	0x8800,0x3808,0x5880,0x4ccc,
	0x3888,0x000f,0x50f0,0x80ff,
	0x2080,0x5f0f,0x7ff0,0x8fff
};

#define VMAX 16
#define VTIR 32
#define HMIN -200
#define DMAX 12800
#define HMAX -12800
#define OMAX 16
#define DPALES 30
#define PA 2
#define pi 3.1416


int pales=0;

int co0[5]={160,100,120,60,1};
int co1[5]={160,50,80,40,2};
int co2[5]={160,150,80,40,2};

int distirh=0;
int distirt=0;
long scoreh=0;
long scoret=0;
int energieh=60;
int energiet=60;
int niveaut=0;
int niveauh=0;
long lscoreh=0;
long lscoret=0;
int lenergieh=60;
int lenergiet=60;
int lniveaut=0;
int lniveauh=0;
long tscoreh=0;
long tscoret=0;
int tenergieh=60;
int tenergiet=60;
int tniveaut=0;
int tniveauh=0;
int crash=0;

#define MAXNV 6

char *niveaux[2*MAXNV+1]={
"  LARVE ",
"CLOPORTE",
"IMBECILE",
" CRETIN ",
"   NUL  ",
" MAUVAIS",
"DEBUTANT",
" AMATEUR",
"   BON  ",
"   PRO  ",
"  MALIN ",
"SUPERBON",
"  DIEU  "
};


int titlek[7*5]={
0x07df,
0x0111,
0x011f,
0x0111,
0x0111,

0x4520,
0x6540,
0x5580,
0x4d40,
0x4520,

0x008b,
0x008a,
0x00fb,
0x008a,
0x008b,

0xe83e,
0x0808,
0xc808,
0x0808,
0xefbe,

0xfbef,
0x8228,
0x822f,
0x8228,
0xfbe8,

0xbefb,
0x8882,
0x88f3,
0x0882,
0x08fa,

0xef80,
0x2800,
0xef00,
0x4800,
0x2f80
};

long menuk[4*84]={

0xf8003ef8,0xebc00000,
0x08002288,0x4a400000,
0x08003e88,0x4bc00000,
0x08000288,0x4a800000,
0x08003ef8,0x4a400000,
0x00000000,0x00000000,
0x00000000,0x00000000,
0x0f01e000,0x00000000,
0x90101220,0xedb4dec0,
0xa0100a20,0xa9249280,
0xc01006f8,0xe934dec0,
0xf0101e20,0xa9249480,
0x00fe0020,0xadb6d2c0,
0x00820000,0x00000000,
0x00820000,0xcdb4dec0,
0x00820000,0xa9249280,
0x008200f8,0xad34dec0,
0x00820000,0xa9249480,
0x00fe0000,0xcdb6d2c0,
0x00000000,0x00000000,
0x000000dd,0xdbc0dddc,
0x00000094,0x92408954,
0x000000d4,0x9bc0c95c,
0x00000094,0x92804950,
0x88003ed4,0x9a40c9d0,
0x88002000,0x00000000,
0xf8003e00,0x00000000,
0x08002200,0x00000000,
0x08003ef8,0xf7677800,
0x00000008,0x95554800,
0x00000038,0xf7577800,
0x0f01e008,0xa5555000,
0x900012f8,0x95654800,
0xa0000a00,0x00000000,
0xc0000608,0xfbba25c0,
0xf0001e10,0x12ab6540,
0x03ff8020,0x22aaa540,
0x02008040,0x42aa2540,
0x02108080,0xfbba2540,
0x02108000,0x00000000,
0x02108050,0xfbba2757,
0x02108020,0x12ab6552,
0x02fe80f8,0x22aaa552,
0x02828020,0x42aa2552,
0x02828050,0xfbba2772,
0x02828000,0x00000000,
0x02828000,0x00000000,
0x02828000,0x00000000,
0x02fe8020,0xf6dbbbd8,
0x02008060,0x94929250,
0x02008020,0xf69a93d8,
0x02008020,0xa4929290,
0x03ff8070,0x96da9258,
0x00000000,0x00000000,
0x0000009c,0xeeaf6930,
0x00000094,0x4aa94920,
0x0000009c,0x4aaf6930,
0x00000094,0x4aaa4920,
0x000f00d4,0x4ee96db0,
0x000c0000,0x00000000,
0x07ca00ef,0x6db79f44,
0x004900a9,0x49248128,
0x07c080ef,0x6db79f10,
0x0400408a,0x44a51028,
0x07c04089,0x6db49f44,
0x00000000,0x00000000,
0x000060ae,0xceead580,
0x000190aa,0x84aa9500,
0xff8610aa,0xc4aa9d80,
0x805860aa,0x84aa9500,
0x802188ea,0xc4eed580,
0x80160800,0x00000000,
0x800804ee,0xea99bb80,
0x800404aa,0xaa912a80,
0x800204ea,0xaa99aa80,
0xffff04aa,0xaa90aa80,
0x000015aa,0xaed9ba80,
0x00000e00,0x00000000,
0x0007c4dd,0xdb800000,
0x00044091,0x11000000,
0x0007c0d9,0x99000000,
0x00044091,0x11000000,
0x0007c0d1,0x19000000,
0x00000000,0x00000000,

0x00000088,0xebc00000,
0x00000088,0x4a400000,
0x000000a8,0x4bc00000,
0x000000d8,0x4a800000,
0x00103e88,0x4a400000,
0x00382000,0x00000000,
0x00543c00,0x00000000,
0x00102000,0x00000000,
0x00102078,0xedb4dec0,
0x00100080,0xa9249280,
0x00100070,0xe934dec0,
0x00000008,0xa9249480,
0x07ffc0f0,0xadb6d2c0,
0x00000000,0x00000000,
0x08780088,0xcdb4dec0,
0x0c840050,0xa9249280,
0x0f820020,0xad34dec0,
0x007c0050,0xa9249480,
0x00000088,0xcdb6d2c0,
0x00100000,0x00000000,
0x001000f8,0xdddc0000,
0x00102288,0x89540000,
0x001022f8,0xc95c0000,
0x00542290,0x49500000,
0x00381488,0xc9d00000,
0x00100800,0x00000000,
0x00000000,0x00000000,
0x00000000,0x00000000,
0x000000f0,0xf7677800,
0x00000088,0x95554800,
0x000000f0,0xf7577800,
0x00000088,0xa5555000,
0xf8003ef0,0x95654800,
0x10002000,0x00000000,
0x20003cf0,0xfbba25c0,
0x40002088,0x12ab6540,
0xf8003e88,0x22aaa540,
0x00000088,0x42aa2540,
0x000000f0,0xfbba2540,
0x0f01e000,0x00000000,
0x900012f8,0xfbba2757,
0xa0000a80,0x12ab6552,
0xc0000680,0x22aaa552,
0xf0005e80,0x42aa2552,
0x001180f8,0xfbba2772,
0x003a0000,0x00000000,
0x004c0000,0x00000000,
0x00540000,0x00000000,
0x006400f8,0xf6eec978,
0x00b80080,0x944aa948,
0x031000b8,0xf64ec978,
0x04100088,0xa44aa950,
0x001000f8,0x964acd48,
0x00100000,0x00000000,
0x00100097,0x775bbb00,
0x00000095,0x44511200,
0x00000087,0x77591300,
0x00000085,0x11511200,
0x000f00c5,0x77591300,
0x000c0000,0x00000000,
0x07ca00ef,0x6db79f44,
0x044900a9,0x49248128,
0x044080ef,0x6db79f10,
0x04c0408a,0x44a51028,
0x07c04089,0x6db49f44,
0x00000000,0x00000000,
0x000c00ae,0xceead580,
0x003000aa,0x84aa9500,
0x00c000aa,0xc4aa9d80,
0x033000aa,0x84aa9500,
0x0ccc08ea,0xc4eed580,
0x31040800,0x00000000,
0x011804ee,0xea99bb80,
0x37e004aa,0xaa912a80,
0x3c0004ea,0xaa99aa80,
0x100004aa,0xaa90aa80,
0x000015aa,0xaed9ba80,
0x00000e00,0x00000000,
0x0007c4dd,0xdb800000,
0x00044091,0x11000000,
0x0007c0d9,0x99000000,
0x00044091,0x11000000,
0x000440d1,0x19000000,
0x00000000,0x00000000

};


int cube[5+1*1+3*8+5*12]={
8,12,1,1,

0,8,

-1, 1,-1, 1,-1, 1,-1, 1,
-1,-1,-1,-1, 1, 1, 1, 1,
 1, 1,-1,-1, 1, 1,-1,-1,

1,2,3,4,5,6,9,10,11,12,13,14,

0,1,3,2,
6,7,5,4,
1,0,4,5,
2,3,7,6,
0,2,6,4,
3,1,5,7,
2,3,1,0,
4,5,7,6,
5,4,0,1,
6,7,3,2,
4,6,2,0,
7,5,1,3
			 };



int tank[5+1*3+3*28+5*19]={
28,19,3,20,

0,12,24,28,

8,8,8,8,8,8,-8,-8,-8,-8,-8,-8,4,4,4,4,-4,-4,-4,-4,1,1,-1,-1,1,1,-1,-1,

4,2,2,4,10,10,4,2,2,4,10,10,-2,-2,2,2,-2,-2,2,2,1,-1,-1,1,1,-1,-1,1,

-16,-12,12,16,12,-12,-16,-12,12,16,12,-12,0,8,8,-4,0,8,8,-4,-3,-1,-1,-3,
-8,-8,-8,-8,

11,10,10,3,0,10,2,2,10,10,2,2,3,11,11,2,2,3,3,

7,8,2,1,
7,1,0,6,
2,8,9,3,
16,12,15,19,
27,26,25,24,
26,22,21,25,
27,23,22,26,
20,24,25,21,
24,20,23,27,
16,17,13,12,
19,18,17,16,
12,13,14,15,
13,17,18,14,
6,0,5,11,
3,9,10,4,
0,1,2,3,
9,8,7,6,
0,3,4,5,
11,10,9,6
			 };


int obus[5+1*1+3*4+5*1]={
4,1,1,1,

0,4,

 0,-1, 0, 1,
-1, 0, 1, 0,
 0, 0, 0, 0,

15,

3,2,1,0
			 };


int helico[5+2*1+3*24+5*24]={
24,24,2,12,

0,20,24,

-2,-2,-2,-2,2,2,2,2,-4,-4,4,4,-2,2,0,0,0,0,0,0,-12,-12,12,12,

2,4,-2,-2,2,4,-2,-2,2,2,2,2,4,4,2,2,-2,-2,0,0,-4,-4,-4,-4,

-6,-4,-2,2,-6,-4,-2,2,-2,2,-2,2,2,2,4,10,12,10,8,3,-1,1,-1,1,

15,2,10,2,10,2,10,2,10,2,10,3,11,3,10,2,10,10,2,10,2,10,2,15,

22,23,21,20,
3,9,14,14,
7,3,14,14,
11,7,14,14,
9,12,14,14,
12,13,14,14,
13,11,14,14,
14,15,18,19,
15,16,17,18,
19,18,15,14,
18,17,16,15,
8,2,0,0,
2,6,4,0,
4,6,10,10,
8,0,1,1,
0,4,5,1,
4,10,5,5,
3,2,8,9,
2,3,7,6,
6,7,11,10,
1,12,9,8,
5,13,12,1,
10,11,13,5,
20,21,23,22

};



int boom[5+1*1+3*10+5*6]={
10,6,1,20,

0,10,

-8,8,-4,4,-12,12,-8,8,0,0,
4,4,0,0,-8,-8,-16,-16,-20,-8,
0,0,0,0,0,0,0,0,0,0,

4,4,4,4,4,4,

0,2,3,3,
2,3,1,1,
2,4,5,3,
2,8,3,3,
2,6,9,3,
2,9,7,3
			 };


int zone[5+1*1+3*4+5*1]={
4,1,1,40,

0,4,

  40,   0,- 40,   0,
   0,   0,   0,   0,
   0,  40,   0, -40,

7,

3,2,1,0
				};




void affstats()
{
int i,x,y;
char *s="000000";

x=40;
y=102;

if (lscoret!=scoret)
{
	if (scoret>999999L) scoret=999999L;
	if (scoret<0L) scoret=0L;
	sprintf(s,"%06ld",lscoret);
	setcolor(0);
	afftext(x-(8*3),y+20,s);
	sprintf(s,"%06ld",scoret);
	setcolor(15);
	afftext(x-(8*3),y+20,s);
}

if (lniveaut!=niveaut)
{
	if (niveaut>MAXNV) niveaut=MAXNV;
	if (niveaut<-MAXNV) niveaut= -MAXNV;
	setcolor(0);
	afftext(x-(8*4),y+50,niveaux[lniveaut+MAXNV]);

	setcolor(15);
	afftext(x-(8*4),y+50,niveaux[niveaut+MAXNV]);
}


x=0;
if (lenergiet!=energiet)
{
	if (energiet<0) energiet=0;
	if (energiet>60) energiet=60;
	setcolor(0);
	for(i=0;i<4;i++) hline(x+10,y+83+i,x+70,-1);
	setcolor(LIGHTRED);
	if (energiet>0)
	for(i=0;i<4;i++) hline(x+10,y+83+i,x+(9+energiet),-1);
	setcolor(YELLOW);
	if (energiet>10)
	for(i=0;i<4;i++) hline(x+20,y+83+i,x+(9+energiet),-1);
	setcolor(GREEN);
	if (energiet>30)
	for(i=0;i<4;i++) hline(x+40,y+83+i,x+(9+energiet),-1);
}

x=280;
y=2;

if (lscoreh!=scoreh)
{
	if (scoreh>999999L) scoreh=999999L;
	if (scoreh<0L) scoreh=0L;
	sprintf(s,"%06ld",lscoreh);
	setcolor(0);
	afftext(x-(8*3),y+20,s);
	sprintf(s,"%06ld",scoreh);
	setcolor(15);
	afftext(x-(8*3),y+20,s);
}

if (lniveauh!=niveauh)
{
	if (niveauh>MAXNV) niveauh=MAXNV;
	if (niveauh<-MAXNV) niveauh= -MAXNV;

	setcolor(0);
	afftext(x-(8*4),y+50,niveaux[lniveauh+MAXNV]);

	setcolor(15);
	afftext(x-(8*4),y+50,niveaux[niveauh+MAXNV]);
}

x=240;
if (lenergieh!=energieh)
{
	if (energieh<0) energieh=0;
	if (energieh>60) energieh=60;
	setcolor(0);
	for(i=0;i<4;i++) hline(x+10,y+83+i,x+70,-1);
	setcolor(LIGHTRED);
	if (energieh>0)
		for(i=0;i<4;i++) hline(x+10,y+83+i,x+(9+energieh),-1);
	setcolor(YELLOW);
	if (energieh>10)
		for(i=0;i<4;i++) hline(x+20,y+83+i,x+(9+energieh),-1);
	setcolor(GREEN);
	if (energieh>30)
		for(i=0;i<4;i++) hline(x+40,y+83+i,x+(9+energieh),-1);
}


}



void affcol(x,y,ptr,n)
int x,y,n;
int *ptr;
{
int i,j;
unsigned int v;

for(i=0;i<n;i++)
{
	v= *(ptr++);
	for(j=15;j>=0;j--)
	{
		if (v&1) plot((x+j),y+i,15);
		v>>=1;
	}
}

}






void affkeys()
{
int i,x,y,v;

cls();

setcolor(15);

afftext(160-(8*6),0,"Y:FIL DE FER");

afftext(160-(8*7)-4,100,"+:, *:PF3 /:PF4");

afftext(160-(8*9),192,"K:QUITTER P:PAUSE");

x=(160+80+40);
y=2;

setcolor(15);
afftext(x-(int)(8*2.5),y+10,"SCORE");
afftext(x-(8*3),y+40,"NIVEAU");
afftext(x-(int)(8*3.5),y+70,"ENERGIE");
setcolor(15);
afftext(x-(8*3),y+20,"000000");
afftext(x-(int)(8*4),y+50,"DEBUTANT");
setcolor(LIGHTRED);
for(i=0;i<4;i++) hline(240+10,y+83+i,240+20,-1);
setcolor(YELLOW);
for(i=0;i<4;i++) hline(240+20,y+83+i,240+40,-1);
setcolor(GREEN);
for(i=0;i<4;i++) hline(240+40,y+83+i,240+70,-1);

x=40;
y=102;

setcolor(15);

afftext(x-(int)(8*2.5),y+10,"SCORE");
afftext(x-(8*3),y+40,"NIVEAU");
afftext(x-(int)(8*3.5),y+70,"ENERGIE");
setcolor(15);
afftext(x-(8*3),y+20,"000000");
afftext(x-(8*4),y+50,"DEBUTANT");
setcolor(LIGHTRED);
for(i=0;i<4;i++) hline(10,y+83+i,20,-1);
setcolor(YELLOW);
for(i=0;i<4;i++) hline(20,y+83+i,40,-1);
setcolor(GREEN);
for(i=0;i<4;i++) hline(40,y+83+i,70,-1);


affcol(160+80+24,104,&titlek[0],5);
affcol(160+80+24+16,104,&titlek[5],5);
affcol(0,4,&titlek[10],5);
affcol(16,4,&titlek[15],5);
affcol(32,4,&titlek[20],5);
affcol(48,4,&titlek[25],5);
affcol(64,4,&titlek[30],5);

x=160+80;
y=116;
for(i=0;i<84;i++)
{
	v=menuk[i*2]>>16;
	affcol(x+8,y+i,&v,1);
	v=menuk[i*2]&0xff00L;
	affcol(x+24,y+i,&v,1);
	v=menuk[i*2]&255L;
	affcol(x+32,y+i,&v,1);
	v=menuk[i*2+1]>>16;
	affcol(x+48,y+i,&v,1);
	v=menuk[i*2+1]&0xffffL;
	affcol(x+64,y+i,&v,1);
}

x=0;
y=16;
for(i=0;i<84;i++)
{
	v=menuk[i*2+2*84]>>16;
	affcol(x+8,y+i,&v,1);
	v=menuk[i*2+2*84]&0xff00L;
	affcol(x+24,y+i,&v,1);
	v=menuk[i*2+2*84]&255L;
	affcol(x+32,y+i,&v,1);
	v=menuk[i*2+2*84+1]>>16;
	affcol(x+48,y+i,&v,1);
	v=menuk[i*2+2*84+1]&0xffffL;
	affcol(x+64,y+i,&v,1);
}


}


int lettrew1[10]={-112,-96,-96,-96,-80,-16,-92,-16,-112,-96};
int lettrew2[10]={-72,-64,-52,-16,-64,-16,-72,-32,-72,-64};
int lettrew4[10]={-72,-64,-72,-32,-80,-16,-92,-16,-72,-64};
int lettrew3[10]={-48,-96,-32,-96,-52,-16,-64,-16,-48,-96};
int lettrea1[12]={-12,-96,12,-96,32,-16,16,-16,0,-80,-12,-96};
int lettrea2[12]={-12,-96,12,-96,0,-80,-16,-16,-32,-16,-12,-96};
int lettrer[10]={72,-50,87,-54,96,-16,80,-16,72,-50};
int lettrez[18]={-128,0,-72,0,-104,64,-88,64,-72,80,-128,80,-96,16,-112,16,-128,0};
int lettren[10]={8,0,24,0,64,80,48,80,8,0};
int lettree[18]={80,0,128,0,112,16,96,16,96,64,112,64,128,80,80,80,80,0};

void pbar(x1,y1,x2,y2)
int x1,y1,x2,y2;
{
	pbox(x1,y1,x2-x1,y2-y1,-1);
}

void ppellipse(x,y,lx,ly,c)
int x,y,lx,ly,c;
{
	pellipse(x-lx,y-ly,lx*2,ly*2,c);
}


void titre(xc,yc,lx,ly,c)
int xc,yc,c;
double lx,ly;
{
int i;

for(i=0;i<5;i++)
{
	lettrew1[i*2]=xc+(int)(lettrew1[i*2]*lx);
	lettrew1[i*2+1]=yc+(int)(lettrew1[i*2+1]*ly);
}
for(i=0;i<5;i++)
{
	lettrew4[i*2]=xc+(int)(lettrew4[i*2]*lx);
	lettrew4[i*2+1]=yc+(int)(lettrew4[i*2+1]*ly);
}
for(i=0;i<5;i++)
{
	lettrew2[i*2]=xc+(int)(lettrew2[i*2]*lx);
	lettrew2[i*2+1]=yc+(int)(lettrew2[i*2+1]*ly);
}
for(i=0;i<5;i++)
{
	lettrew3[i*2]=xc+(int)(lettrew3[i*2]*lx);
	lettrew3[i*2+1]=yc+(int)(lettrew3[i*2+1]*ly);
}
for(i=0;i<6;i++)
{
	lettrea1[i*2]=xc+(int)(lettrea1[i*2]*lx);
	lettrea1[i*2+1]=yc+(int)(lettrea1[i*2+1]*ly);
}
for(i=0;i<6;i++)
{
	lettrea2[i*2]=xc+(int)(lettrea2[i*2]*lx);
	lettrea2[i*2+1]=yc+(int)(lettrea2[i*2+1]*ly);
}
for(i=0;i<5;i++)
{
	lettrer[i*2]=xc+(int)(lettrer[i*2]*lx);
	lettrer[i*2+1]=yc+(int)(lettrer[i*2+1]*ly);
}
for(i=0;i<9;i++)
{
	lettrez[i*2]=xc+(int)(lettrez[i*2]*lx);
	lettrez[i*2+1]=yc+(int)(lettrez[i*2+1]*ly);
}
for(i=0;i<5;i++)
{
	lettren[i*2]=xc+(int)(lettren[i*2]*lx);
	lettren[i*2+1]=yc+(int)(lettren[i*2+1]*ly);
}
for(i=0;i<9;i++)
{
	lettree[i*2]=xc+(int)(lettree[i*2]*lx);
	lettree[i*2+1]=yc+(int)(lettree[i*2+1]*ly);
}

setcolor(c);
ppellipse(xc+(int)(lx*(72)),yc-(int)(ly*(72)),(int)(lx*24),(int)(ly*24),-1);
ppellipse(xc+(int)(lx*(-32)),yc-(int)(ly*(-24)),(int)(lx*24),(int)(ly*24),-1); 
ppellipse(xc+(int)(lx*(-32)),yc-(int)(ly*(-56)),(int)(lx*24),(int)(ly*24),-1);

setcolor(0);

ppellipse(xc+(int)(lx*(72)),yc-(int)(ly*(72)),(int)(lx*8),(int)(ly*8),-1);
ppellipse(xc+(int)(lx*(-32)),yc-(int)(ly*(-24)),(int)(lx*8),(int)(ly*8),-1);
ppellipse(xc+(int)(lx*(-32)),yc-(int)(ly*(-56)),(int)(lx*8),(int)(ly*8),-1);

setcolor(c);

pbar(xc+(int)(lx*(-56)),yc-(int)(ly*(-24)),xc+(int)(lx*(-8)),yc-(int)(ly*(-56)));
refresh();

setcolor(0);
pbar(xc+(int)(lx*(-40)),yc-(int)(ly*(-24)),xc+(int)(lx*(-24)),yc-(int)(ly*(-56)));
pbar(xc+(int)(lx*(64)),yc-(int)(ly*(80)),xc+(int)(lx*(72)),yc-(int)(ly*(64)));

setcolor(c);

pbar(xc+(int)(lx*(48)),yc-(int)(ly*(96)),xc+(int)(lx*(64)),yc-(int)(ly*(16)));
pbar(xc+(int)(lx*(-8)),yc-(int)(ly*(64)),xc+(int)(lx*(8)),yc-(int)(ly*(48)));
pbar(xc+(int)(lx*(8)),yc-(int)(ly*(0)),xc+(int)(lx*(24)),yc-(int)(ly*(-80)));
pbar(xc+(int)(lx*(48)),yc-(int)(ly*(0)),xc+(int)(lx*(64)),yc-(int)(ly*(-80)));
pbar(xc+(int)(lx*(80)),yc-(int)(ly*(0)),xc+(int)(lx*(96)),yc-(int)(ly*(-80)));
pbar(xc+(int)(lx*(96)),yc-(int)(ly*(-32)),xc+(int)(lx*(112)),yc-(int)(ly*(-48)));

polyfill(5,lettrew4,-1);
polyfill(5,lettrew1,-1);
polyfill(5,lettrew2,-1);
polyfill(5,lettrew3,-1);
polyfill(6,lettrea1,-1);
polyfill(6,lettrea2,-1);
polyfill(5,lettrer,-1);
polyfill(9,lettrez,-1);
polyfill(5,lettren,-1);
polyfill(9,lettree,-1);
}




void intro()
{
int xc,yc;
double lx,ly;


xc=160;
yc=100;
lx=1.0;
ly=0.75;
#ifdef CORRECT_RATIO
lx=lx*1.25;
#endif


titre(xc,yc,lx,ly,10);

setcolor(15);

swap();
while(!keyhit()) waitdelay(500);

affkeys();
swap();
affkeys();

}



void clip(ntp,tp,co)
int *tp;
int *ntp;
int *co;
{
int tp2[80];
int ntp2=0;
int n,i;
long xe,ye,xo,yo;
int XC,YC,LX,LY;

XC=co[0];
YC=co[1];
LX=co[2];
LY=co[3];

xe=ye=0L;

/* y=LY */

{
ntp2=0;
n= *ntp>>1;
for(i=0;i<n-1;i++)
{
	if (i)
	{
		xo=xe;
		yo=ye;
	}
	else
	{
		xo=tp[(n-2)<<1];
		yo=tp[((n-2)<<1)+1];
	}

	xe=tp[i<<1];
	ye=tp[(i<<1)+1];

	if (((ye>LY)&&(yo<LY))||((ye<LY)&&(yo>LY)))
	{
		tp2[ntp2]=xo+((xo-xe)*(LY-yo))/(yo-ye);
#ifdef CORRECT_RATIO
		tp2[ntp2]+=tp2[ntp2]>>2;
#endif
		ntp2++;
		tp2[ntp2++]=LY;
	}

	if (ye<=LY)
	{
		tp2[ntp2]=xe;
#ifdef CORRECT_RATIO
		tp2[ntp2]+=tp2[ntp2]>>2;
#endif
		ntp2++;
		tp2[ntp2++]=ye;
	}

}

	tp2[ntp2++]=tp2[0];
	tp2[ntp2++]=tp2[1];

}

/* y= -LY */

*ntp=0;
if (ntp2>=6)
{
	n=ntp2>>1;
	for(i=0;i<n-1;i++)
	{
		if (i)
		{
			xo=xe;
			yo=ye;
		}
		else
		{
			xo=tp2[(n-2)<<1];
			yo=tp2[((n-2)<<1)+1];
		}

		xe=tp2[i<<1];
		ye=tp2[(i<<1)+1];


		if (((ye<-LY)&&(yo>-LY))||((ye>-LY)&&(yo<-LY)))
		{
			tp[(*ntp)++]=xo+((xo-xe)*(-LY-yo))/(yo-ye);
			tp[(*ntp)++]= -LY;
		}

		if (ye>= -LY)
		{
			tp[(*ntp)++]=xe;
			tp[(*ntp)++]=ye;
		}

	}

	tp[(*ntp)++]=tp[0];
	tp[(*ntp)++]=tp[1];

}



/* x=LX */

ntp2=0;
if (*ntp>=6)
{
	n= *ntp>>1;
	for(i=0;i<n-1;i++)
	{
		if (i)
		{
			xo=xe;
			yo=ye;
		}
		else
		{
			xo=tp[(n-2)<<1];
			yo=tp[((n-2)<<1)+1];
		}

		xe=tp[i<<1];
		ye=tp[(i<<1)+1];

		if (((xe>LX)&&(xo<LX))||((xe<LX)&&(xo>LX)))
		{
			tp2[ntp2++]=LX;
			tp2[ntp2++]=yo+((yo-ye)*(LX-xo))/(xo-xe);
		}

		if (xe<=LX)
		{
			tp2[ntp2++]=xe;
			tp2[ntp2++]=ye;
		}

	}

	tp2[ntp2++]=tp2[0];
	tp2[ntp2++]=tp2[1];

}

/* x= -LX */

*ntp=0;
if (ntp2>=6)
{
	n=ntp2>>1;
	for(i=0;i<n-1;i++)
	{
		if (i)
		{
		xo=xe;
		yo=ye;
		}
		else
		{
			xo=tp2[(n-2)<<1];
			yo=tp2[((n-2)<<1)+1];
		}

		xe=tp2[i<<1];
		ye=tp2[(i<<1)+1];


		if (((xe<-LX)&&(xo>-LX))||((xe>-LX)&&(xo<-LX)))
		{
			tp[(*ntp)++]=XC-LX;
			tp[(*ntp)++]=YC+yo+((yo-ye)*(-LX-xo))/(xo-xe);
		}

		if (xe>= -LX)
		{
			tp[(*ntp)++]=xe+XC;
			tp[(*ntp)++]=ye+YC;
		}

	}

	tp[(*ntp)++]=tp[0];
	tp[(*ntp)++]=tp[1];

}


}







#ifdef REALCALC




void rpolyline(int n,double *tp,int c)
{
	int pts[256];
	int i;

	for(i=0;i<2*n;i++) pts[i]=(int)tp[i];

	polyline(n,pts,c);
}


void rpolyfill(int n,double *tp,int c)
{
	int pts[256];
	int i;

	for(i=0;i<2*n;i++) pts[i]=(int)tp[i];

	polyfill(n,pts,c);
}






void rclip(ntp,tp,co)
double *tp;
int *ntp;
int *co;
{
double tp2[80];
int ntp2=0;
int n,i;
double xe,ye,xo,yo;
double XC,YC,LX,LY;

XC=(double)co[0];
YC=(double)co[1];
LX=(double)co[2];
LY=(double)co[3];

xe=ye=0.0;

/* y=LY */

{
ntp2=0;
n= *ntp>>1;
for(i=0;i<n-1;i++)
{
	if (i)
	{
		xo=xe;
		yo=ye;
	}
	else
	{
		xo=tp[(n-2)<<1];
		yo=tp[((n-2)<<1)+1];
	}

	xe=tp[i<<1];
	ye=tp[(i<<1)+1];

	if (((ye>LY)&&(yo<LY))||((ye<LY)&&(yo>LY)))
	{
		tp2[ntp2]=xo+((xo-xe)*(LY-yo))/(yo-ye);
#ifdef CORRECT_RATIO
		tp2[ntp2]+=tp2[ntp2]/4.0;
#endif
		ntp2++;
		tp2[ntp2++]=LY;
	}

	if (ye<=LY)
	{
		tp2[ntp2]=xe;
#ifdef CORRECT_RATIO
		tp2[ntp2]+=tp2[ntp2]/4.0;
#endif
		ntp2++;
		tp2[ntp2++]=ye;
	}

}

	tp2[ntp2++]=tp2[0];
	tp2[ntp2++]=tp2[1];

}

/* y= -LY */

*ntp=0;
if (ntp2>=6)
{
	n=ntp2>>1;
	for(i=0;i<n-1;i++)
	{
		if (i)
		{
			xo=xe;
			yo=ye;
		}
		else
		{
			xo=tp2[(n-2)<<1];
			yo=tp2[((n-2)<<1)+1];
		}

		xe=tp2[i<<1];
		ye=tp2[(i<<1)+1];


		if (((ye<-LY)&&(yo>-LY))||((ye>-LY)&&(yo<-LY)))
		{
			tp[(*ntp)++]=xo+((xo-xe)*(-LY-yo))/(yo-ye);
			tp[(*ntp)++]= -LY;
		}

		if (ye>= -LY)
		{
			tp[(*ntp)++]=xe;
			tp[(*ntp)++]=ye;
		}

	}

	tp[(*ntp)++]=tp[0];
	tp[(*ntp)++]=tp[1];

}



/* x=LX */

ntp2=0;
if (*ntp>=6)
{
	n= *ntp>>1;
	for(i=0;i<n-1;i++)
	{
		if (i)
		{
			xo=xe;
			yo=ye;
		}
		else
		{
			xo=tp[(n-2)<<1];
			yo=tp[((n-2)<<1)+1];
		}

		xe=tp[i<<1];
		ye=tp[(i<<1)+1];

		if (((xe>LX)&&(xo<LX))||((xe<LX)&&(xo>LX)))
		{
			tp2[ntp2++]=LX;
			tp2[ntp2++]=yo+((yo-ye)*(LX-xo))/(xo-xe);
		}

		if (xe<=LX)
		{
			tp2[ntp2++]=xe;
			tp2[ntp2++]=ye;
		}

	}

	tp2[ntp2++]=tp2[0];
	tp2[ntp2++]=tp2[1];

}

/* x= -LX */

*ntp=0;
if (ntp2>=6)
{
	n=ntp2>>1;
	for(i=0;i<n-1;i++)
	{
		if (i)
		{
		xo=xe;
		yo=ye;
		}
		else
		{
			xo=tp2[(n-2)<<1];
			yo=tp2[((n-2)<<1)+1];
		}

		xe=tp2[i<<1];
		ye=tp2[(i<<1)+1];


		if (((xe<-LX)&&(xo>-LX))||((xe>-LX)&&(xo<-LX)))
		{
			tp[(*ntp)++]=XC-LX;
			tp[(*ntp)++]=YC+yo+((yo-ye)*(-LX-xo))/(xo-xe);
		}

		if (xe>= -LX)
		{
			tp[(*ntp)++]=xe+XC;
			tp[(*ntp)++]=ye+YC;
		}

	}

	tp[(*ntp)++]=tp[0];
	tp[(*ntp)++]=tp[1];

}


}


#endif






int pxe[40],pye[40],pze[40];
char p[40];



#ifdef REALCALC

int raff(t,re,co,fdf)
int *t;
int *re;
int *co;
int fdf;
{
long nn,xo,yo,zo,xe,ye,ze;
int n,ntp,nj,ni,i,j;
int K,KD,KR,np,nf,nr;
int *r,*c,*x,*y,*z,*l;
int *ix,*iy,*iz;
double px[40],py[40],tp[80];
int drew=0;
int contact=0;
int sz;
double FKR=1.0;

xe=ye=ze=0L;

np=t[0];
nf=t[1];
nr=t[2];
sz=t[3];
r=t+4;
x=r+nr+1;
y=x+np;
z=y+np;
c=z+np;
l=c+nf;

ix=re;
iy=re+4;
iz=re+8;

K=16;
KD=8-co[4];
KR=4-co[4];

for(i=0;i<KR;i++) FKR*=2.0;

sz=sz*((ABS(ix[2])+ABS(iy[2])+ABS(iz[2]))>>4);

if ((iz[0]+sz>ABS(ix[0]))&&(iz[0]+sz>ABS(iy[0])))
{
for(j=0;j<nr;j++)
{

	ni=r[j];
	nj=r[j+1];

	for(i=ni;i<nj;i++)
	{
		p[i]=0;
		pxe[i]=(ix[0]+((x[i]*ix[1]+y[i]*ix[2]+z[i]*ix[3])>>4));
		pye[i]=(iy[0]+((x[i]*iy[1]+y[i]*iy[2]+z[i]*iy[3])>>4));
		pze[i]=(iz[0]+((x[i]*iz[1]+y[i]*iz[2]+z[i]*iz[3])>>4));
	}

	ix+=12;
	iy+=12;
	iz+=12;

}

for(i=0;i<nf;i++)
{

	n=4;
	ni=l[(i<<2)+n-1];
	ntp=0;

	for(j=0;j<n;j++)
	{

		if (j)
		{
			xo=xe;
			yo=ye;
			zo=ze;
		}
		else
		{
			xo=pxe[ni];
			yo=pye[ni];
			zo=pze[ni];
		}

		nj=l[(i<<2)+j];

		xe=pxe[nj];
		ye=pye[nj];
		ze=pze[nj];

		if (((ze>K)&&(zo<K))||((ze<K)&&(zo>K)))
		{
			tp[ntp]=xo+((double)(xo-xe)*(K-zo))/(zo-ze);
			tp[ntp]=(tp[ntp])*FKR;
			ntp++;
			tp[ntp]=yo+((double)(yo-ye)*(K-zo))/(zo-ze);
			tp[ntp]=tp[ntp]*FKR;
			ntp++;
			contact=1;
		}

		if (ze>=K)
			if (p[nj])
			{
				tp[ntp++]=px[nj];
				tp[ntp++]=py[nj];
			}
			else
			{
				px[nj]=tp[ntp++]=((double)(xe<<KD))/ze;
				py[nj]=tp[ntp++]=((double)(ye<<KD))/ze;
				p[nj]=0;
			}

	}


	if (ntp>=6)
	{
		tp[ntp++]=tp[0];
		tp[ntp++]=tp[1];

		nn=(long)((tp[0]-tp[2])*(tp[5]-tp[3])-(tp[4]-tp[2])*(tp[1]-tp[3]));

		if (nn<0)
			if (fdf)
			{
				rclip(&ntp,tp,co);
				if (ntp>=6)
				{
					drew=1;
					rpolyline(ntp>>1,tp,15);
				}
			}
			else
			{
				rclip(&ntp,tp,co);
				if (ntp>=6)
				{
					rpolyfill(ntp>>1,tp,c[i]&15);
					drew=1;
				}
			}
	}

}

}

if (!drew) contact=0;
return(contact);
}

#endif


#ifdef INTEGERCALC

int aff(t,re,co,fdf)
int *t;
int *re;
int *co;
int fdf;
{
long nn,xo,yo,zo,xe,ye,ze;
int n,ntp,nj,ni,i,j;
int K,KD,KR,np,nf,nr;
int *r,*c,*x,*y,*z,*l;
int *ix,*iy,*iz;
int px[40],py[40],tp[40];
int drew=0;
int contact=0;
int sz;

xe=ye=ze=0L;

np=t[0];
nf=t[1];
nr=t[2];
sz=t[3];
r=t+4;
x=r+nr+1;
y=x+np;
z=y+np;
c=z+np;
l=c+nf;

ix=re;
iy=re+4;
iz=re+8;

K=16;
KD=8-co[4];
KR=4-co[4];



sz=sz*((ABS(ix[2])+ABS(iy[2])+ABS(iz[2]))>>4);

if ((iz[0]+sz>ABS(ix[0]))&&(iz[0]+sz>ABS(iy[0])))
{
for(j=0;j<nr;j++)
{

	ni=r[j];
	nj=r[j+1];

	for(i=ni;i<nj;i++)
	{
		p[i]=0;
		pxe[i]=(ix[0]+((x[i]*ix[1]+y[i]*ix[2]+z[i]*ix[3])>>4));
		pye[i]=(iy[0]+((x[i]*iy[1]+y[i]*iy[2]+z[i]*iy[3])>>4));
		pze[i]=(iz[0]+((x[i]*iz[1]+y[i]*iz[2]+z[i]*iz[3])>>4));
	}

	ix+=12;
	iy+=12;
	iz+=12;

}

for(i=0;i<nf;i++)
{

	n=4;
	ni=l[(i<<2)+n-1];
	ntp=0;

	for(j=0;j<n;j++)
	{

		if (j)
		{
			xo=xe;
			yo=ye;
			zo=ze;
		}
		else
		{
			xo=pxe[ni];
			yo=pye[ni];
			zo=pze[ni];
		}

		nj=l[(i<<2)+j];

		xe=pxe[nj];
		ye=pye[nj];
		ze=pze[nj];

		if (((ze>K)&&(zo<K))||((ze<K)&&(zo>K)))
		{
			tp[ntp]=xo+((xo-xe)*(K-zo))/(zo-ze);
			tp[ntp]=(tp[ntp])<<KR;
			ntp++;
			tp[ntp]=yo+((yo-ye)*(K-zo))/(zo-ze);
			tp[ntp]=tp[ntp]<<KR;
			ntp++;
			contact=1;
		}

		if (ze>=K)
			if (p[nj])
			{
				tp[ntp++]=px[nj];
				tp[ntp++]=py[nj];
			}
			else
			{
				px[nj]=tp[ntp++]=((xe<<KD))/ze;
				py[nj]=tp[ntp++]=(ye<<KD)/ze;
				p[nj]=0;
			}

	}


	if (ntp>=6)
	{
		tp[ntp++]=tp[0];
		tp[ntp++]=tp[1];

		xe=tp[0]-tp[2];
		xo=tp[4]-tp[2];
		ye=tp[1]-tp[3];
		yo=tp[5]-tp[3];
		nn=xe*yo-xo*ye;

		if (nn<0)
			if (fdf)
			{
				clip(&ntp,tp,co);
				if (ntp>=6)
				{
					drew=1;
					polyline(ntp>>1,tp,15);
				}
			}
			else
			{
				clip(&ntp,tp,co);
				if (ntp>=6)
				{
					polyfill(ntp>>1,tp,c[i]&15);
					drew=1;
				}
			}
	}

}

}

if (!drew) contact=0;
return contact;
}

#endif




void rot(xa,ya,xb,yb,n,a)
int *xa,*ya,*xb,*yb;
int n,a;
{
	long nn;

	nn=n;
	*xa=(nn*cs[a&255])>>14;
	*ya=(nn*sn[a&255])>>14;
	*xb= -(*ya);
	*yb= *xa;
}

void prot(xa,ya,xb,yb,a)
int *xa,*ya,*xb,*yb;
int a;
{
	int ax,ay;
	long ca,sa;

	ca=cs[a&255];
	sa=sn[a&255];

	ax= *xa;
	ay= *ya;

	*xa=(ca*ax-sa*ay)>>14;
	*ya=(ca*ay+sa*ax)>>14;
	*xb= -(*ya);
	*yb= *xa;

}


void pprot(xa,ya,za,xb,yb,zb,a)
int *xa,*ya,*za,*xb,*yb,*zb;
int a;
{
	int yi,zi;
	long ca,sa;

	ca=cs[a&255];
	sa=sn[a&255];

	yi= *xa;
	zi= *xb;
	*xa=(yi*ca-zi*sa)>>14;
	*xb=(yi*sa+zi*ca)>>14;
	yi= *ya;
	zi= *yb;
	*ya=(yi*ca-zi*sa)>>14;
	*yb=(yi*sa+zi*ca)>>14;
	yi= *za;
	zi= *zb;
	*za=(yi*ca-zi*sa)>>14;
	*zb=(yi*sa+zi*ca)>>14;

}




void vrot(xa,ya,a)
int *xa,*ya;
int a;
{
	int ax,ay;
	long ca,sa;

	ca=cs[a&255];
	sa=sn[a&255];

	ax= *xa;
	ay= *ya;

	*xa=(ca*ax-sa*ay)>>14;
	*ya=(ca*ay+sa*ax)>>14;

}







int tpz[30];

void scope(co,nrad,rad,z,or)
int *co,*or;
int rad[][2];
int nrad;
int z;
{
	int i,x,y,ni;
	int ntpz=10;

	tpz[0]=tpz[7]= -12800;
	tpz[1]=tpz[2]=tpz[5]=tpz[6]=0;
	tpz[3]=tpz[4]= 12800;

	z+=co[4];

	tpz[8]= -or[0];
	tpz[9]=or[2];
	for(i=0;i<4;i++)
	{
		ni=i<<1;
		tpz[ni]+=tpz[8];
		tpz[ni+1]+=tpz[9];
		vrot(&tpz[ni],&tpz[ni+1],128+or[5]+or[6]);
		tpz[ni]=(tpz[ni]>>z);
		tpz[ni+1]=tpz[ni+1]>>z;
	}
	tpz[8]=tpz[0];
	tpz[9]=tpz[1];
	clip(&ntpz,tpz,co);
	polyline(ntpz>>1,tpz,15);

	plot(co[0],co[1],15);

	for(i=0;i<nrad;i++)
	{
		x=(rad[i][0]>>z);
#ifdef CORRECT_RATIO
		x+=x>>2;
#endif
		y=rad[i][1]>>z;
		if ((x<co[2])&&(x>-co[2])&&(y<co[3])&&(y>-co[3]))
			plot(co[0]+x,co[1]-y,15);
	}

}


void mire(co)
int *co;
{
	setcolor(15);
	dline(co[0]-(co[2]>>2),co[1],co[0]-(co[2]>>3),co[1],-1);
	dline(co[0]+(co[2]>>3),co[1],co[0]+(co[2]>>2),co[1],-1);
	dline(co[0],co[1]-(co[3]>>2),co[0],co[1]-(co[3]>>3),-1);
	dline(co[0],co[1]+(co[3]>>3),co[0],co[1]+(co[3]>>2),-1);
}

void clear(co)
int *co;
{
	int LX,LY,XC,YC;

	XC=co[0];
	YC=co[1];
	LX=co[2];
	LY=co[3];

	pbox(XC-LX,YC-LY,2*LX+1,2*LY+1,0);
}

void sea(co,a,fdf)
int *co,a,fdf;
{
	int LX,LY,XC,YC;
	int d;
	long tang;

	XC=co[0];
	YC=co[1];
	LX=co[2];
	LY=co[3];

	tang=tg[a];
	d=tang>>(6+co[4]);

	if (fdf)
	{
		pbox(XC-LX,YC-LY,2*LX+1,2*LY+1,0);
		setcolor(15);
		dline(XC-LX,YC+d,XC+LX,YC+d,-1);
		dline(XC+LX,YC+d,XC+LX,YC+LY,-1);
		dline(XC-LX,YC+LY,XC+LX,YC+LY,-1);
		dline(XC-LX,YC+d,XC-LX,YC+LY,-1);
	}
	else
	{
		pbox(XC-LX,YC-LY,2*LX,LY+d,9);
		pbox(XC-LX,YC+d,2*LX,LY-d,1);
		hline(XC-LX,YC+LY,XC+LX,0);
		vline(XC+LX,YC-LY,YC+LY,0);
	}
}



void setob(o,ir,or,nr)
int *o,*or;
int nr;
int ir[][4];
{
	int i;

	o[5]&=255;
	if (or[14]==3) or[6]=0;

	ir[0][2]=ir[2][2]=ir[1][1]=ir[1][3]=0;
	ir[1][2]=o[3];

	if ((o[14]==1)||(o[14]>15))
	rot(&ir[0][1],&ir[2][1],&ir[0][3],&ir[2][3],o[3],0);
		else
	rot(&ir[0][1],&ir[2][1],&ir[0][3],&ir[2][3],o[3],128+o[5]-or[5]-or[6]);

	ir[0][0]=(o[0]-or[0])>>o[4];
	ir[1][0]=(o[1]-or[1])>>o[4];
	ir[2][0]=(o[2]-or[2])>>o[4];
	vrot(&ir[0][0],&ir[2][0],128-or[5]-or[6]);
	vrot(&ir[1][0],&ir[2][0],or[7]);


	if (nr>1)
		if (o[14]==3)
		{
			pprot(
				&ir[0][3],&ir[1][3],&ir[2][3],
				&ir[0][2],&ir[1][2],&ir[2][2],
				o[7]);
			for(i=0;i<4;i++)
			{
				ir[0+3][i]=ir[0][i];
				ir[1+3][i]=ir[1][i];
				ir[2+3][i]=ir[2][i];
			}
			pprot(
				&ir[0+3][3],&ir[1+3][3],&ir[2+3][3],
				&ir[0+3][1],&ir[1+3][1],&ir[2+3][1],
				pales);

			vrot(&ir[1+3][1],&ir[2+3][1],or[7]);
			vrot(&ir[1+3][2],&ir[2+3][2],or[7]);
			vrot(&ir[1+3][3],&ir[2+3][3],or[7]);
		}
		else
		{
			for(i=0;i<4;i++)
			{
				ir[0+3][i]=ir[0][i];
				ir[1+3][i]=ir[1][i];
				ir[2+3][i]=ir[2][i];
			}
			prot(&ir[0+3][1],&ir[2+3][1],&ir[0+3][3],&ir[2+3][3],o[6]);
			for(i=0;i<4;i++)
			{
				ir[0+6][i]=ir[0+3][i];
				ir[1+6][i]=ir[1+3][i];
				ir[2+6][i]=ir[2+3][i];
			}
			pprot(
				&ir[0+6][3],&ir[1+6][3],&ir[2+6][3],
				&ir[0+6][2],&ir[1+6][2],&ir[2+6][2],
				o[7]);

			vrot(&ir[1+6][1],&ir[2+6][1],or[7]);
			vrot(&ir[1+6][2],&ir[2+6][2],or[7]);
			vrot(&ir[1+6][3],&ir[2+6][3],or[7]);

			vrot(&ir[1+3][1],&ir[2+3][1],or[7]);
			vrot(&ir[1+3][2],&ir[2+3][2],or[7]);
			vrot(&ir[1+3][3],&ir[2+3][3],or[7]);

		}

	vrot(&ir[1][1],&ir[2][1],or[7]);
	vrot(&ir[1][2],&ir[2][2],or[7]);
	vrot(&ir[1][3],&ir[2][3],or[7]);
}

void load(nobj,o,to,tab,ctab)
int *nobj,*o,*to[],*tab,*ctab;
{
int i;

	for(i=0;i<16;i++) o[i]=ctab[i];
	to[*nobj]=tab;
	(*nobj)++;
}

void add(nlobj,loh,lot,n)
int *nlobj,*loh,*lot;
int n;
{
	loh[*nlobj]=n;
	lot[*nlobj]=n;
	(*nlobj)++;
}

void tri(n,t,v)
int n;
int *t,*v;
{
int f,i,tp;

	if (n>1)
		do
		{
			f=0;
			for(i=0;i<n-1;i++)
				if (v[i]<v[i+1])
				{
					f=1;
					tp=v[i];
					v[i]=v[i+1];
					v[i+1]=tp;
					tp=t[i];
					t[i]=t[i+1];
					t[i+1]=tp;
				}
		}
		while (f);

}







int affs(co1,nlobj,lo,nlo,o,to,or,fdf)
int *lo,*o,*nlo,*or,*co1,fdf;
int nlobj;
int *to[];
{
	int io,ilo;
	int ir[9][4];
	int nrad;
	int rad[20][2];
	int contact=0;
	int zoom=or[10];
	int radar=or[11];
	int *tb;

	sea(co1,-or[7],fdf);

	nrad=0;
	setob(o,ir,or,1);

#ifdef REALCALC
	raff(to[0],ir,co1,fdf);
#endif

#ifdef INTEGERCALC
	aff(to[0],ir,co1,fdf);
#endif


	for(ilo=0;ilo<nlobj;ilo++)
	{
		io=lo[ilo]<<4;
		nlo[ilo]=ABS(o[io]-or[0])+ABS(o[io+1]-or[1])+ABS(o[io+2]-or[2]);
	}

	tri(nlobj,lo,nlo);

	for(ilo=0;ilo<nlobj;ilo++)
	{
		io=lo[ilo];
		tb=to[io];
		io=io<<4;

		if ((o[io+15]&15)==0)
		{
			if (o[io+14]>15) tb=boom;
				setob(&o[io],ir,or,tb[2]);

#ifdef INTEGERCALC
			contact|=aff(tb,ir,co1,fdf);
#endif
#ifdef REALCALC
			contact|=raff(tb,ir,co1,fdf);
#endif


			if (radar)
			{
				rad[nrad][0]=ir[0][0];
				rad[nrad][1]=ir[2][0];
				nrad++;
			}
		}

	}

	mire(co1);
	if (radar) scope(co1,nrad,rad,zoom,or);

	return(contact);
}





void keybt(or,r)
int *or;
char r;
{

	if (
	(r=='7')||
	(r=='8')||
	(r=='9')||
	(r=='4')||
	(r=='6')||
	(r=='1')||
	(r=='2')||
	(r=='3')||
	(r=='0')||
	(r=='/')||
	(r=='*')||
	(r=='-')||
	(r=='+')||
	(r==',')||
	(r==13)||
	(r==' ')
	)
	{
		if (r==' ') r=or[8];
		else
		if (r==or[8]) r=' ';
	}
	else
		r=or[8];

	or[13]=0;
	if (or[14]!=1)
	{
		switch(r)
		{
			case 13:	or[12]=0; r=' '; break;
			case '0':	or[13]=1; r=' '; break;
			case '3':   or[11]=1-or[11]; r=' '; break;
			case '1':   or[6]=0; r=' '; r=' '; break;
		}

		if ((or[14]==2)||(or[14]==3))
		switch(r)
		{
			case '8':	or[7]+=PA; break;
			case '2':	or[7]-=PA; break;
		}

		switch(r)
		{
			case '4':	or[5]+=PA; break;
			case '6':	or[5]-=PA; break;
			case '7':	or[6]+=PA; break;
			case '9':	or[6]-=PA; break;
			case ',':
			case '+':	or[12]+=1;
 				if (or[12]>VMAX) or[12]=8;
			 	break;
			case '-':	or[12]-=1;
 				if (or[12]<-VMAX) or[12]= -8;
 				break;
			case '*':	or[10]+=1;
 				if (or[10]>16) or[10]=16;
 				break;
			case '/':	or[10]-=1;
 				if (or[10]<0) or[10]=0;
 				break;
		}
	}

	if (or[7]>0) or[7]=0;
	if (or[7]<-16) or[7]= -16;

	or[8]=r;
}


void keybh(or,r)
int *or;
char r;
{

	if (
	(r=='a')||
	(r=='z')||
	(r=='e')||
	(r=='q')||
	(r=='s')||
	(r=='d')||
	(r=='f')||
	(r=='w')||
	(r=='x')||
	(r=='c')||
	(r=='v')||
	(r=='b')||
	(r=='r')||
	(r=='g')||
	(r==' ')
	)
	{
		if (r==' ') r=or[8];
		else
		if (r==or[8]) r=' ';
	}
	else
		r=or[8];

	or[13]=0;
	if (or[14]!=1)
	{
		switch(r)
		{
			case 'r':	or[12]=0; r=' '; break;
			case 'w':	or[13]=1; r=' '; break;
			case 'b':   or[11]=1-or[11]; r=' '; break;
		}

		if ((or[14]==2)||(or[14]==3))
		switch(r)
		{
			case 'a':	or[7]+=PA; break;
			case 'q':	or[7]-=PA; break;
			case 'g':   or[7]=0; break;
		}

		or[6]=0;
		switch(r)
		{
			case 'z':	or[5]+=PA; break;
			case 'e':	or[5]-=PA; break;
			case 'v':	or[6]=PA; break;
			case 'f':	or[6]= -PA; break;
			case 's':	or[12]+=1;
 				if (or[12]>VMAX) or[12]=8;
			 	break;
			case 'x':	or[12]-=1;
 				if (or[12]<-VMAX) or[12]= -8;
 				break;
			case 'c':	or[10]+=1;
 				if (or[10]>16) or[10]=16;
 				break;
			case 'd':	or[10]-=1;
 				if (or[10]<0) or[10]=0;
 				break;
		}
	}

	if (or[7]>16) or[7]=16;
	if (or[7]<-16) or[7]= -16;

	or[8]=r;
}

int compteur=0;


void move(or)
int *or;
{
	int dn,v,d;
	int dv=0;

	or[0]+=(sn[or[5]&255]>>10)*or[12];
	or[2]-=(cs[or[5]&255]>>10)*or[12];
	if ((or[14]&15)!=2)
	{
		dv=(sn[or[7]&255]>>10)*or[12];
		or[1]+=dv;
		if ((or[1]+(or[6]<<4))<HMIN) or[1]+=or[6]<<4;
	}

	if (!or[15])
		if (ABS(or[0])+ABS(or[2])>DMAX)
	{
		or[5]=or[5]+128;
		or[0]-=or[0]>>8;
		or[2]-=or[2]>>8;
		if ((or[14]&15)==1)
		{
			or[15]=1;
			or[14]=or[14]&15;
			or[1]= HMIN;
		}
	}

	if (!or[15])
		if ((or[1]>HMIN)||(or[1]<HMAX))
		{
			or[7]= -or[7];
			if (or[1]<HMAX)
			{
				if ((or[14]&15)==1) or[15]=1;
				or[1]-=or[1]>>8;
			}
			else
			{
				v=or[12];

				v=v*(or[1]- (HMIN))/dv;

				or[0]-=(sn[or[5]&255]>>10)*v;
				or[2]+=(cs[or[5]&255]>>10)*v;

				or[1]= HMIN;

				if ((or[14]&15)==1)
				{
					or[14]=17;
					or[12]=0;
				}
			}
		}

	if (!or[15])
		if ((or[14]&15)==1)
		{
			if (or[14-32]==3) dn= -16; else dn= -48;
			d=ABS(or[0]-or[dn])+ABS(or[1]-or[dn+1])+ABS(or[2]-or[dn+2]);
			d>>=5;
			if (d<16)
			{
				if (or[14-32]==2)
				{
					energieh-=(16-d);
					if (energieh<0) energieh=0;
					if ((!energieh)&&(!compteur))
					{
						scoret+=100L+(long)energiet;
						niveauh--;
						niveaut++;
						or[dn]*= -1;
						or[dn+2]*= -1;
						if (ABS(or[dn])<5000)
							or[dn]=((or[dn]>0)?(5000):(-5000));
						compteur=20;
					}
				}
				else
				{
					energiet-=(16-d);
					if (energiet<0) energiet=0;
					if ((!energiet)&&(!compteur))
					{
						scoreh+=100L+(long)energieh;
						niveaut--;
						niveauh++;
						or[dn]*= -1;
						or[dn+2]*= -1;

						if (ABS(or[dn+2])<5000)
							or[dn+2]=((or[dn+2]>0)?(5000):(-5000));
						compteur=20;
					}
				}
				or[14]=17;
				or[12]=0;
			}
		}

}




char r=' ';
int fdf=0;
int nlobj=0;
int nobj=0;
int o[OMAX*16];
int lot[OMAX];
int nlot[OMAX];
int loh[OMAX];
int nloh[OMAX];
int *to[OMAX];
int i,j;
int LX,LY,XC,YC;
int contact=0;
int czone[16]={0,0,0,320,4,0,0,0, 0,0,0,0, 0,0,0,0};
int ctank[16]={0,-200,2000,320,0,0,0,0, 32,0,7,1, 4,0,2,0};
int chelico[16]={1000,-500,2000,320,0,60,0,0, 32,0,7,1, 4,0,3,0};
int cobus[16]={0,-200,0,320,0,128,0,0, 32,0,7,1, 16,0,1,1};
int alt;
int altmin;
unsigned long timelast,wdelay,delay;

/* 0,1,2,3,4,5,6, 7,     8,     9,  10,  11, 12, 13,   14,   15  */
/* x,y,z,n,k,a,ta,in,last char,fdf,zoom,radar,v,fire,carton,dead */
int *oh,*ot;

int main()
{

	if (initsystem())
	{
		hide();
		setpalette(gamepal);

		intro();


		altmin= HMIN*1.4;

		oh= &o[16];
		ot= &o[32];

		load(&nobj,&o[nobj<<4],to,zone,czone);

		load(&nobj,&o[nobj<<4],to,helico,chelico);
		load(&nobj,&o[nobj<<4],to,tank,ctank);

		load(&nobj,&o[nobj<<4],to,obus,cobus);
		load(&nobj,&o[nobj<<4],to,obus,cobus);

		add(&nlobj,loh,lot,1);
		add(&nlobj,loh,lot,2);

		add(&nlobj,loh,lot,3);
		add(&nlobj,loh,lot,4);

		timelast=systime();
		delay=100L;

		do
		{
			pales+=DPALES;

			affstats();
			lenergiet=tenergiet;
			tenergiet=energiet;
			lniveaut=tniveaut;
			tniveaut=niveaut;
			lscoret=tscoret;
			tscoret=scoret;
			lenergieh=tenergieh;
			tenergieh=energieh;
			lniveauh=tniveauh;
			tniveauh=niveauh;
			lscoreh=tscoreh;
			tscoreh=scoreh;


			if ((wdelay=systime()-timelast)<delay)
				waitdelay((int)(delay-wdelay));
			timelast=systime();

			swap();

			if (energieh)
			{
				affs(co1,nlobj,loh,nloh,o,to,oh,fdf);
				alt=(altmin-oh[1])/200;
				if (alt<8) setcolor(LIGHTRED); else setcolor(15);
				vline(co1[0]-co1[2]+4,co1[1]+co1[3]-4-alt,co1[1]+co1[3]-4,-1);

			}
			else
				clear(co1);

			if (energiet)
			{
				affs(co2,nlobj,lot,nlot,o,to,ot,fdf);
			}
			else
				clear(co2);

			if (compteur) compteur--;

			if (compteur==1)
			{
				if (crash) { energieh=1; crash=0; }
				if (!energiet) energiet=60;
				if (!energieh) energieh=60;
			}

			if (kbhit()) r=getch(); else r=' ';

			keybt(ot,r);
			keybh(oh,r);

			if (niveaut>MAXNV/2) ot[11]=0;
			if (niveauh>MAXNV/2) oh[11]=0;

			if (oh[1]>altmin)
			{
				energieh=0;
				compteur=20;
				oh[1]=altmin-10;
				crash=1;
			}

			if (!energieh) oh[8]='r';
			if (!energiet) ot[8]=13;

			for(i=1;i<nobj;i++)
			{
				j=i<<4;

				if (o[j+14]>15)
				{
					o[j+14]-=16;
					if ((o[j+14]&15)==1) o[j+15]=1;
				}

				if (!o[j+15])
				move(&o[j]);
			}

			if ((oh[13])&&(oh[2*16+15]))
			{
				oh[2*16]=oh[0];
				oh[2*16+1]=oh[1];
				oh[2*16+2]=oh[2];
				oh[2*16+5]=oh[5]+oh[6];
				oh[2*16+7]=oh[7];
				oh[2*16+15]=0;
				oh[2*16+12]=4;
				move(&oh[2*16]);
				oh[2*16+12]=VTIR;
			}

			if ((ot[13])&&(ot[2*16+15]))
			{
				ot[2*16]=ot[0];
				ot[2*16+1]=ot[1];
				ot[2*16+2]=ot[2];
				ot[2*16+5]=ot[5]+ot[6];
				ot[2*16+7]=ot[7];
				ot[2*16+15]=0;
				ot[2*16+12]=4;
				move(&ot[2*16]);
				ot[2*16+12]=VTIR;
			}

			switch(r)
			{
				case 'p': while(getch()!='p') waitdelay(1000); break;
				case 'y': fdf=1-fdf; break;
			};

		}
		while ((r!='k')&&(r!='K'));


		killsystem();

	}

	return 0;
}

