/* sokoban.c (version utilisant GLCbase:x11,mac,pc,atari,amiga)

original: xokoban3

  Joseph L. Traub
  (jt1o@andrew.cmu.edu)

   AUTHORS
     Joseph L. Traub - X windows interface.
     Kevin Solie - simultaneously developed X implementation (merged in).
     Mark Linderman, Christos Zoulas - Mouse code (added to Solie's version).
     Unknown Hacker - Original curses(1) implementation.

						Carnegie Mellon University

adaptation et ameliorations:

  Guillaume LAMONOCA
  E.S.E Promo 94

vms:
	cc x11.c
	cc sokoban.c
	cc sprites.c
	cc levels.c
	link sokoban.obj,sprites.obj,levels.obj,x11.obj,$users:[public.x11]xlib.opt/opt

unix: (makefile)

sokoban : sokoban.o levels.o x11.o sprites.o
        cc -o sokoban sokoban.o x11.o levels.o sprites.o -lX11 -s
sokoban.o : sokoban.c
        cc -c sokoban.c
levels.o : levels.c
        cc -c levels.c
sprites.o : sprites.c
        cc -c sprites.c
x11.o : x11.c
        cc -c x11.c

(rajouter -lbsd si ftime est non definie)
*/

#include "header.h"

#define HALLNAME "sokoban.hll"

#define GAUCHE '<'
#define DROITE '>'
#define HAUT '^'
#define BAS 'v'

#define AGEMAX 250
#define MAXTABLEAUX 100
#define XMAX 20
#define YMAX 20

#define ABS(x) ((x<0)?(-(x)):(x))

#ifndef VMS
#ifndef unix
#define cuserid(x) ""
#endif
#endif

#define   cman		'@'
#define   ctreasure	'*'
#define   cgoal		'.'
#define   cobject	'$'
#define   csaveman	'+'
#define   cfloor	' '
#define   cwall		'#'

#define centerwall		0
#define east_twall		1
#define eastwall		2
#define floor			3
#define goal			4
#define horizwall		5
#define llcornerwall	6
#define lonewall		7
#define lrcornerwall	8
#define man				9
#define north_twall		10
#define northwall		11
#define object			12
#define saveman			13
#define south_twall		14
#define southwall		15
#define treasure		16
#define ulcornerwall	17
#define urcornerwall	18
#define vertiwall		19
#define wall			20
#define west_twall		21
#define westwall		22

#define REMEMBER 10
#define ESSAIS 10

typedef void *bloc;

extern unsigned char blocs[23*120];
extern char *ecrans[];
extern char *ecrans2[];


int mur[16]={7,22,15,6,2,5,8,14,11,17,19,21,18,10,1,0};

int oldlost=1;
int lost=1;
int tri[60];
int classe=0;
int numero;
int ecx,ecy,epx,epy,emx,emy;
int ne=0;
int think=0;
int selected=0;
int targeted,targeted2;
int xdep,ydep,xobj,yobj,xpos,ypos,xdep2,ydep2,xview,yview,xcenter,ycenter;
char username[9];
unsigned char sprite[16][16];
unsigned char sprite2[8][8];
bloc sprites[23];
bloc sprites2[23];
bloc levelbloc;
unsigned char saved[YMAX][XMAX];
int vpage=0;
int vmap[2][YMAX][XMAX];
int mapinit[YMAX][XMAX];
int tableau[YMAX][XMAX];
int findinit[YMAX][XMAX];
int findmap[YMAX][XMAX];
int findmap2[YMAX][XMAX];
int objects;
int treasures;
unsigned int oldtab[REMEMBER][YMAX][XMAX];
int oldtreasures[REMEMBER];
int oldx[REMEMBER];
int oldy[REMEMBER];
int level=0;
int oldnumber;
int oldin;
int oldout;
int vmode=0;
int amode=1;
int memorise=1;

unsigned int palette[16]=
{
	0x0000,0x1111,0x1222,0x2333,
	0x2444,0x3555,0x3666,0x4777,
	0x4888,0x5999,0x5aaa,0x6bbb,
	0x6ccc,0x7ddd,0x7eee,0x8fff
};

typedef struct
		{
			char username[9];
			unsigned char level;
			unsigned char saved;
			unsigned char age;
		}
		player;

player hall[60]=
{
"BOISSEAU",86,0,0,
"LOUVEAU_",86,0,0,
"BUJEAUD_",62,0,0,
"ROY_GIL ",49,0,0,
"PANUEL_Y",41,0,0,
"CHATAIN_",72,0,0,
"ALBERTIN",30,0,0,
"LUCHINI_",30,0,0,
"LACHAUX_",29,0,0,
"GILLOT_J",27,0,0,
"ROCHIGNE",16,0,0,
"BUSSENAU",15,0,0,
"GUILLEMA",13,0,0,
"BILLAULT",13,0,0,
"MALIS_EZ",13,0,0,
"JOUIN_CH",13,0,0,
"BOERI_FR",13,0,0,
"HECKMANN",10,0,0,
"CORRE_SY",10,0,0,
"GRIGNOU_",10,0,0,
"KLAMMERS",9,0,0,
"HENOUX_C",7,0,0,
"LEFEBVRE",7,0,0,
"BERGERET",5,0,0
 };




void bcls()
{
	pbox(0,0,320,200,15);
}


void intro()
{
	char s[80];

	cls();

	setcolor(15);
	afftext(160-4*8,20-4,"sokoban!");

	print("");
	print("");
	print("");
	print("");
	print(" objectif: pousser les objets vers les");
	print("           zones prevues a cet effet !"); 
	print("      (cliquez un objet puis une zone)");
	print(" touches:");
	print("");
	print(" h : aide");
	print(" p : podium");
	print(" s : sauvegarder la partie");
	print(" c : charger la partie sauvegardee");
	print(" i : initialiser le tableau");
	print(" a : voir/ignorer tous les mouvements");
	print(" q : quitter le jeu");
	print(" +,: tableau suivant");
	print(" - : tableau precedent");
	print(" 0-9: deplacer fenetre de visualisation");
	print(" b1 : mouvements acceleres/selection");
	sprintf(s," b2 ou u : revenir en arriere (%d fois)",REMEMBER);
	print(s);
	print(" espace: vue d'ensemble/vue rapprochee");
	print(" return: choisir le personnage suivant");

	lost=1;
	swap();
}





void put_level()
{
	int i,j,c;
	int x,y;

	if (xview<0) xview=0;
	if (xview>=XMAX) xview=XMAX-1;
	if (yview<0) yview=0;
	if (yview>=YMAX) yview=YMAX-1;

	if ((oldlost)||(lost))
	{
		for(i=0;i<YMAX;i++)
			for(j=0;j<XMAX;j++)
				vmap[vpage][i][j]=floor;
		bcls();
	}
	

	if (!vmode)
		for(i=0;i<YMAX;i++)
			for(j=0;j<XMAX;j++)
			{
				x=10+j-xview;
				y=6+i-yview;

				if ((x<20)&&(y<12)&&(x>=0)&&(y>=0))
				{
					c=tableau[i][j];
					if (((c==object)||(c==treasure))&&
						((j==xobj)&&(i==yobj)))
					{
						putbloc(&sprites[c],x*16,y*16);
						dbox(x*16,y*16,15,15,think);
						vmap[vpage][i][j]= -1;
					}
					else
					if ((selected)&&(j==xpos)&&(i==ypos))
					{
						putbloc(&sprites[c],x*16,y*16);
						dbox(x*16,y*16,15,15,0);
						vmap[vpage][i][j]= -1;
					}
					else
					if (c!=vmap[vpage][i][j])
					{
						putbloc(&sprites[c],x*16,y*16);
						vmap[vpage][i][j]=c;
					}
				}
			}

	else
		for(i=0;i<YMAX;i++)
			for(j=0;j<XMAX;j++)
			{
				x=20+j-xcenter;
				y=12+i-ycenter;

				if ((x<40)&&(y<24)&&(x>=0)&&(y>=0))
				{
					c=tableau[i][j];
					if (((c==object)||(c==treasure))&&
						((j==xobj)&&(i==yobj)))
					{
						putbloc(&sprites2[c],x*8,y*8);
						dbox(x*8,y*8,8,8,think);
						vmap[vpage][i][j]= -1;
					}
					else
					if ((selected)&&(j==xpos)&&(i==ypos))
					{
						putbloc(&sprites2[c],x*8,y*8);
						dbox(x*8,y*8,8,8,0);
						vmap[vpage][i][j]= -1;
					}
					else
					if (c!=vmap[vpage][i][j])
					{
						putbloc(&sprites2[c],x*8,y*8);
						vmap[vpage][i][j]=c;
					}
				}
			}

	putbloc(&levelbloc,0,200-8);
	swap();

	vpage^=1;
	oldlost=lost;
	lost=0;
}


void restore()
{
	int i,j;

	if (oldnumber)
	{
		oldout=(oldin+REMEMBER-1)%REMEMBER;
		for(i=0;i<YMAX;i++)
			for(j=0;j<XMAX;j++)
				tableau[i][j]=oldtab[oldout][i][j];
		treasures=oldtreasures[oldout];
		xpos=oldx[oldout];
		ypos=oldy[oldout];
		oldin=oldout;
		oldnumber--;
	}
}

                    

void load_level(n)
int n;
{
	int i,j,m,max,l1,l2,c1,c2;
	char c;
	char **ecr;
	char s[40];

	max=MAXTABLEAUX;
	
	if (n>=max)
	{
		level=n=max-1;
		cls();
		setcolor(15);
		afftext(160-7*8,100-12,"felicitations!");
		afftext(160-13*8,100+4,"vous avez termine sokoban!");
		lost=1;
		swap();
		waitdelay(5000);
	}
	if (n<0) level=n=0;

	ecr=ecrans;
	if (n>49)
	{
		ecr=ecrans2;
		n-=50;
	}

	xobj= -1;
	treasures=0;
	objects=0;
	oldnumber=0;
	oldin=0;
	oldout=0;

	for(i=0;i<YMAX;i++)
		for(j=0;j<XMAX;j++)
			oldtab[0][i][j]=floor;

	l1=0;
	l2=1;
	c1=XMAX-1;
	c2=0;

	for(i=0;i<YMAX;i++)
		for(j=0;(c=ecr[YMAX*n+i][j]);j++)
		{
			switch(c)
			{
				case cman: c=man; xpos=j; ypos=i; break;
				case ctreasure: c=treasure; treasures++;
					objects++; break;
				case cgoal: c=goal; break;
				case cobject: c=object; objects++; break;
				case csaveman: c=saveman; xpos=j; ypos=i; break;
				case cfloor: c=floor; break;
				case cwall: c=wall; break;
			}
			if (c!=cfloor)
			{
				l2=i+1;
				if (j<c1) c1=j;
				if (j>c2) c2=j+1;
			}
			oldtab[0][i][j]=(unsigned int)c;
		}

	ycenter=(l2-l1)/2;
	xcenter=(c2-c1)/2;

	for(i=0;i<YMAX;i++)
		for(j=0;j<XMAX;j++)
			if (oldtab[0][i][j]==wall)
			{
				m=0;
				if (j!=XMAX-1) if (oldtab[0][i][j+1]==wall) m|=1;
				if (i!=0) if (oldtab[0][i-1][j]==wall) m|=2;
				if (j!=0) if (oldtab[0][i][j-1]==wall) m|=4;
				if (i!=YMAX-1) if (oldtab[0][i+1][j]==wall) m|=8;
				tableau[i][j]=mur[m];
				m=0;
				if (j!=XMAX-1) if (oldtab[0][i][j+1]==goal) m|=1;
				if (i!=0) if (oldtab[0][i-1][j]==goal) m|=2;
				if (j!=0) if (oldtab[0][i][j-1]==goal) m|=4;
				if (i!=YMAX-1) if (oldtab[0][i+1][j]==goal) m|=8;
				if (j!=XMAX-1) if (oldtab[0][i][j+1]==treasure) m|=1;
				if (i!=0) if (oldtab[0][i-1][j]==treasure) m|=2;
				if (j!=0) if (oldtab[0][i][j-1]==treasure) m|=4;
				if (i!=YMAX-1) if (oldtab[0][i+1][j]==treasure) m|=8;
				if (j!=XMAX-1) if (oldtab[0][i][j+1]==saveman) m|=1;
				if (i!=0) if (oldtab[0][i-1][j]==saveman) m|=2;
				if (j!=0) if (oldtab[0][i][j-1]==saveman) m|=4;
				if (i!=YMAX-1) if (oldtab[0][i+1][j]==saveman) m|=8;
				if (m==15) tableau[i][j]=wall;
			}
			else
				tableau[i][j]=oldtab[0][i][j];

	pbox(0,200-8,320,8,0);
	sprintf(s,"niveau %d",level+1);
	setcolor(15);
	afftext(160-5*8,200-8,s);
	getbloc(&levelbloc,0,200-8,320,8);

	xview=xcenter;
	yview=ycenter;
	lost=1;
}




void get_sprites()
{
	int i,j,k,l,m,sx,sy;

	pbox(0,0,320,200,FOND);

	initbloc(&levelbloc);

	for(i=0;i<23;i++)
	{

		sx=16*(i%20);
		sy=16*(i/20);


		for(j=0;j<16;j++)
			for(k=0;k<16;k++)
				sprite[j][k]=0;

		for(j=0;j<8;j++)
			for(k=0;k<8;k++)
				sprite2[j][k]=0;

		for(j=0;j<30;j++)
			for(k=0;k<4;k++)
				for(m=1,l=0;l<8;l++,m<<=1)
					if (blocs[i*120+j*4+k]&m)
						sprite[j>>1][(k*8+l)>>1]++;

		for(j=0;j<16;j++)
			sprite[15][j]=sprite[14][j];
		for(j=0;j<16;j++)
			sprite[j][15]=sprite[j][14];


		for(j=0;j<16;j++)
			for(k=0;k<16;k++)
				sprite2[j>>1][k>>1]+=sprite[j][k];

		for(j=0;j<16;j++)
			for(k=0;k<16;k++)
				plot(sx+k,sy+j,15-15*((int)sprite[j][k])/4);
		for(j=0;j<8;j++)
			for(k=0;k<8;k++)
				plot(sx+k,sy+100+j,15-15*((int)sprite2[j][k])/16);
	}

	refresh();

	for(i=0;i<23;i++)
	{

		sx=16*(i%20);
		sy=16*(i/20);

		initbloc(&sprites[i]);
		initbloc(&sprites2[i]);
		getbloc(&sprites[i],sx,sy,16,16);
		getbloc(&sprites2[i],sx,sy+100,16,8);
		pbox(sx,sy+100,8,8,MASK);
	}


	refresh();

	for(i=0;i<23;i++)
	{

		sx=16*(i%20);
		sy=16*(i/20);

		getmask(&sprites2[i],sx,sy+100);
	}


}






void free_all()
{
	int i;

	freebloc(&levelbloc);
	for(i=0;i<23;i++) freebloc(&sprites[i]);
	for(i=0;i<23;i++) freebloc(&sprites2[i]);
}



void store()
{
	int i,j;
	
	for(i=0;i<YMAX;i++)
		for(j=0;j<XMAX;j++)
			oldtab[oldin][i][j]=tableau[i][j];
	oldtreasures[oldin]=treasures;
	oldx[oldin]=xpos;
	oldy[oldin]=ypos;

	oldin=(oldin+1)%REMEMBER;

	if (oldnumber<REMEMBER)
		oldnumber++;
}




void move(dx,dy)
{
	int movement=1;

	if (tableau[ypos+dy][xpos+dx]==floor)
	{
	}
	else
	if (tableau[ypos+dy][xpos+dx]==goal)
	{
	}
	else
	if (tableau[ypos+dy][xpos+dx]==object)
	{
		if (tableau[ypos+dy+dy][xpos+dx+dx]==floor)
		{
		}
		else
		if (tableau[ypos+dy+dy][xpos+dx+dx]==goal)
		{
		}
		else
			movement=0;
	}
	else
	if (tableau[ypos+dy][xpos+dx]==treasure)
	{
		if (tableau[ypos+dy+dy][xpos+dx+dx]==floor)
		{
		}
		else
		if (tableau[ypos+dy+dy][xpos+dx+dx]==goal)
		{
		}
		else
			movement=0;
	}
	else
		movement=0;

	if ((movement)&&(memorise>0)) store();

	if (tableau[ypos+dy][xpos+dx]==floor)
	{
		if (tableau[ypos][xpos]==saveman)
			tableau[ypos][xpos]=goal;
		else
			tableau[ypos][xpos]=floor;
		ypos+=dy;
		xpos+=dx;
		tableau[ypos][xpos]=man;
	}
	else
	if (tableau[ypos+dy][xpos+dx]==goal)
	{
		if (tableau[ypos][xpos]==saveman)
			tableau[ypos][xpos]=goal;
		else
			tableau[ypos][xpos]=floor;
		ypos+=dy;
		xpos+=dx;
		tableau[ypos][xpos]=saveman;
	}
	else
	if (tableau[ypos+dy][xpos+dx]==object)
	{
		if (tableau[ypos+dy+dy][xpos+dx+dx]==floor)
		{
			tableau[ypos+dy+dy][xpos+dx+dx]=object;

			if (tableau[ypos][xpos]==saveman)
				tableau[ypos][xpos]=goal;
			else
				tableau[ypos][xpos]=floor;
			ypos+=dy;
			xpos+=dx;
			tableau[ypos][xpos]=man;
		}
		else
		if (tableau[ypos+dy+dy][xpos+dx+dx]==goal)
		{
			tableau[ypos+dy+dy][xpos+dx+dx]=treasure;
			treasures++;

			if (tableau[ypos][xpos]==saveman)
				tableau[ypos][xpos]=goal;
			else
				tableau[ypos][xpos]=floor;
			ypos+=dy;
			xpos+=dx;
			tableau[ypos][xpos]=man;
		}
	}
	else
	if (tableau[ypos+dy][xpos+dx]==treasure)
	{
		if (tableau[ypos+dy+dy][xpos+dx+dx]==floor)
		{
			tableau[ypos+dy+dy][xpos+dx+dx]=object;
			treasures--;

			if (tableau[ypos][xpos]==saveman)
				tableau[ypos][xpos]=goal;
			else
				tableau[ypos][xpos]=floor;
			ypos+=dy;
			xpos+=dx;
			tableau[ypos][xpos]=saveman;
		}
		else
		if (tableau[ypos+dy+dy][xpos+dx+dx]==goal)
		{
			tableau[ypos+dy+dy][xpos+dx+dx]=treasure;

			if (tableau[ypos][xpos]==saveman)
				tableau[ypos][xpos]=goal;
			else
				tableau[ypos][xpos]=floor;
			ypos+=dy;
			xpos+=dx;
			tableau[ypos][xpos]=saveman;
		}
	}

	if (!movement)
		if ((tableau[ypos+dy][xpos+dx]==man)||
			(tableau[ypos+dy][xpos+dx]==saveman))
		{
			xpos+=dx;
			ypos+=dy;
			selected=1;
		}

	if ((amode)&&(memorise<1)) put_level();
}



void select_next()
{
	int x;
	int y;

	x=xpos+1;
	y=ypos;

	while((x!=xpos)||(y!=ypos))
	{
		if ((tableau[y][x]==man)||(tableau[y][x]==saveman))
		{
			xpos=x;
			ypos=y;
		}
		else
		{
			x++;
			if (x>=XMAX)
			{
				x=0;
				y++;
				if (y>=YMAX) y=0;
			}
		}
	}

	selected=1;
}



void findtarget(px,py,pathlen)
int px,py,pathlen;
{
	if ((tableau[py][px]!=floor)&&(tableau[py][px]!=goal)) return;
	if (findmap[py][px]<=pathlen) return;

	findmap[py][px]=pathlen++;

	if((px==xdep)&&(py==ydep))
	{
		targeted=1;
		return;
	}

	findtarget(px-1,py,pathlen);
	findtarget(px+1,py,pathlen);
	findtarget(px,py-1,pathlen);
	findtarget(px,py+1,pathlen);
}


int searchtarget(x,y)
int x,y;
{

	if ((x==xdep)&&(y==ydep))
	{
		targeted=1;
		findmap[y][x]=0;
	}
	else
	{
		bmove(mapinit,findmap,(long)sizeof(mapinit));

		targeted=0;
		findtarget(x,y,0);
	}
	return(targeted);
}


int findpath(x,y)
int x,y;
{
	int cx,cy,oldman;

	oldman=tableau[ypos][xpos];
	tableau[ypos][xpos]=floor;

	xdep=xpos;
	ydep=ypos;
	searchtarget(x,y);

	tableau[ypos][xpos]=oldman;

	cx=xpos;
	cy=ypos;
	memorise--;
	while(findmap[cy][cx])
	{
		if (findmap[cy][cx-1]==(findmap[cy][cx]-1))
		{
			move(-1,0);
			cx--;
		}
		else
		if (findmap[cy][cx+1]==(findmap[cy][cx]-1))
		{
			move(1,0);
			cx++;
		}
		else
		if (findmap[cy-1][cx]==(findmap[cy][cx]-1))
		{
			move(0,-1);
			cy--;
		}
		else
		if (findmap[cy+1][cx]==(findmap[cy][cx]-1))
		{
			move(0,1);
			cy++;
		}
		else
		findmap[cy][cx]=0;
	}
	memorise++;

	return((x==xpos)&&(y==ypos));
}




void findtarget2(px,py,dx,dy,pathlen)
int px,py,dx,dy,pathlen;
{
	int oldc,gauche,droite;

	if ((tableau[py][px]!=floor)&&(tableau[py][px]!=goal)) return;
	if ((tableau[py+dy][px+dx]!=floor)&&(tableau[py+dy][px+dx]!=goal)) return;
	if (findmap2[py][px]<pathlen) return;

	findmap2[py][px]=pathlen++;

	if((px==xdep2)&&(py==ydep2))
	{
		targeted2=1;
		return;
	}

	findtarget2(px+dx,py+dy,dx,dy,pathlen);

	xdep=px+dx;
	ydep=py+dy;

	oldc=tableau[py][px];
	tableau[py][px]=wall;
	gauche=searchtarget(px+dy,py-dx);
	droite=searchtarget(px-dy,py+dx);
	tableau[py][px]=oldc;
	
	if (gauche)	findtarget2(px+dy,py-dx,dy,-dx,pathlen);
	if (droite) findtarget2(px-dy,py+dx,-dy,dx,pathlen);			
}




int findpath2(x,y)
int x,y;
{
	int cx,cy,oldobj,oldman,mx,my;
	int r=0;

	store();

	bmove(findinit,findmap2,(long)sizeof(findinit));

	oldobj=tableau[yobj][xobj];
	tableau[yobj][xobj]=floor;
	oldman=tableau[ypos][xpos];
	tableau[ypos][xpos]=floor;

	xdep2=xobj;
	ydep2=yobj;
	targeted2=0;
	findtarget2(x,y,0,1,0);
	findtarget2(x,y,0,-1,0);
	findtarget2(x,y,1,0,0);
	findtarget2(x,y,-1,0,0);

	if ((!targeted2)&&(ne)) r=1;

	tableau[ypos][xpos]=oldman;
	tableau[yobj][xobj]=oldobj;

	mx=cx=xobj;
	mx=cy=yobj;
	memorise--;
	while((findmap2[cy][cx])&&(!r))
	{
		mx=cx;
		my=cy;
		
		if (findmap2[cy][cx-1]==(findmap2[cy][cx]-1))
		{
			if (findpath(cx+1,cy))
				move(-1,0);
			if ((tableau[cy][cx]!=man)&&(tableau[cy][cx]!=saveman)) r=1;
			cx--;
		}
		else
		if (findmap2[cy][cx+1]==(findmap2[cy][cx]-1))
		{
			if (findpath(cx-1,cy))
				move(1,0);
			if ((tableau[cy][cx]!=man)&&(tableau[cy][cx]!=saveman)) r=1;
			cx++;
		}
		else
		if (findmap2[cy-1][cx]==(findmap2[cy][cx]-1))
		{
			if (findpath(cx,cy+1))
				move(0,-1);
			if ((tableau[cy][cx]!=man)&&(tableau[cy][cx]!=saveman)) r=1;
			cy--;
		}
		else
		if (findmap2[cy+1][cx]==(findmap2[cy][cx]-1))
		{
			if (findpath(cx,cy-1))
				move(0,1);
			if ((tableau[cy][cx]!=man)&&(tableau[cy][cx]!=saveman)) r=1;
			cy++;
		}
		else
		findmap2[cy][cx]=0;
		
	}

	memorise++;
	if (r)
	{
		if ((ne)&&(targeted2))
			if ((ABS(epx-xpos)>2)||(ABS(epy-ypos)>2)) ne=0;
	
		switch(ne)
		{
			case 0:
				epx=xpos;
				epy=ypos;
				emx=mx;
				emy=my;
				ecx=cx;
				ecy=cy;
				findinit[epy][epx]= -1;
				break;
			case 1:
				findinit[epy][epx]=XMAX*YMAX;
				findinit[ecy][ecx]= -1;
				break;
			case 2:
				findinit[epy][epx]= -1;
				ne= -1;
				break;
		}
		
		ne++;
	}

	if ((tableau[y][x]==floor)||(tableau[y][x]==goal)) restore();
	return(r);
}





void do_click(x,y)
int x,y;
{
	int n=0;

	if (((tableau[y][x]==man)||(tableau[y][x]==saveman))&&
		((xpos!=x)||(ypos!=y)))
	{
		xpos=x;
		ypos=y;
		selected=1;
		put_level();
	}
	else
		if ((tableau[y][x]==object)||(tableau[y][x]==treasure))
		{
			if ((xobj==x)&&(yobj==y))
				xobj= -1;
			else
			{
				xobj=x;
				yobj=y;
			}
		}
		else
			if (xobj== -1)
				findpath(x,y);
			else
			{
				bmove(mapinit,findinit,(long)sizeof(mapinit));
				think=8;
				put_level();
				ne=0;
				while((findpath2(x,y))&&(n<ESSAIS)) n++;
				think=0;
				xobj= -1;
			}
}


void mouse_click()
{
	int x,y;

	if (!vmode)
	{
		x=msex/16-10+xview;
		y=msey/16-6+yview;
		if ((x<XMAX)&&(y<YMAX)&&(x>=0)&&(y>=0))
			do_click(x,y);
	}
	else
	{
		x=msex/8-20+xcenter;
		y=msey/8-12+ycenter;
		if ((x<XMAX)&&(y<YMAX)&&(x>=0)&&(y>=0))
			do_click(x,y);
	}

}



void create_podium()
{
	int i;
	int f;

	for(i=25;i<60;i++)
	{
		hall[i].saved=hall[i].level=hall[i].username[0]=0;
		hall[i].age=AGEMAX;
	}

	f=bcreate(HALLNAME);
	if (f>0)
	{
		bwrite(f,hall,(long)sizeof(hall));
		for(i=0;i<60;i++)
			bwrite(f,saved,(long)sizeof(saved));
		bclose(f);
	}

}



void classement()
{
	int i,ok,t,min;

	classe=0;

	if (!bexist(HALLNAME)) create_podium();

	while(bload(HALLNAME,hall,0L,(long)sizeof(hall))) waitdelay(1000);

	numero= -1;
	for(i=0;i<60;i++)
		if (!strcmp(hall[i].username,username)) numero=i;
		
	if (numero!= -1) classe=1;

	if (classe) hall[numero].age=0;

	if (!classe)
	{
		min=MAXTABLEAUX+10;
		numero= -1;
		for(i=0;i<60;i++)
			if (((int)hall[i].level<min)&&
				((int)hall[i].age>=AGEMAX))
			{
				min=(int)hall[i].level;
				numero=i;
			}
			
		if (numero== -1)
		{		
			if (!bload(HALLNAME,hall,0L,
				(long)sizeof(hall)))
			{

				for(i=0;i<60;i++)
					if ((int)hall[i].age<AGEMAX)
						hall[i].age++;

				bsave(HALLNAME,hall,0L,
					(long)sizeof(hall));
			}

			min=MAXTABLEAUX+10;
			numero= -1;
			for(i=0;i<60;i++)
				if (((int)hall[i].level<min)&&
					((int)hall[i].age>=AGEMAX))
				{
					min=(int)hall[i].level;
					numero=i;
				}

		}

		
		if (numero!= -1)
		{
			classe=1;
			sprintf(hall[numero].username,username);
			hall[numero].level=level+1;
			hall[numero].age=hall[numero].saved=0;
			while(bsave(HALLNAME,&hall[numero],numero*(long)sizeof(player),
				(long)sizeof(player))) waitdelay(1000);
		}
	}	

	for(i=0;i<60;i++)
		tri[i]=i;
		
	ok=0;
	while(!ok)
	{
		ok=1;
		for(i=0;i<59;i++)
		if (hall[tri[i]].level<hall[tri[i+1]].level)
		{
			ok=0;
			t=tri[i];
			tri[i]=tri[i+1];
			tri[i+1]=t;
		}
	}

}



void podium()
{
	int i,j,n,k;
	char s[40];

	cls();

	setcolor(15);
	afftext(160-3*8,8,"podium");
	afftext(160-4*8+4,16,"sokoban!");

	classement();

	for(j=0;j<3;j++)
		for(i=0;i<20;i++)
		{
			n=tri[i+j*20];
			if (hall[n].username[0])
			{
				if ((int)hall[n].level>MAXTABLEAUX)
					sprintf(s," %s win",hall[n].username);
				else
					sprintf(s," %s %d",hall[n].username,hall[n].level);
				for(k=0;s[k];k++) if (s[k]=='_') s[k]=' ';
				afftext(j*8*13,(4+i)*8,s);
			}
		}

	lost=1;
	swap();

	while(!keyhit()) waitdelay(500);
	empty();
}


void save()
{
	int i,j;

	classement();
	
	if (classe)
	{
		for(i=0;i<YMAX;i++)
			for(j=0;j<XMAX;j++)
				saved[i][j]=(unsigned char)tableau[i][j];
	
		while(bsave(HALLNAME,saved,
			(long)sizeof(hall)+numero*(long)sizeof(saved),
			(long)sizeof(saved))) waitdelay(1000);
		hall[numero].saved=(unsigned char)level+1;
		while(bsave(HALLNAME,&hall[numero],numero*(long)sizeof(player),
			(long)sizeof(player))) waitdelay(1000);
	}
	else
	{
		cls();
		setcolor(15);
		afftext(8*5,100-4,"vous n'etes pas encore classe!");
		lost=1;
		swap();
		waitdelay(1000);
		put_level();
	}
}



void save_hall()
{
	classement();

	if ((classe)&&(level+1>(int)hall[numero].level))
	{
		hall[numero].level=(unsigned char)(level+1);
		while(bsave(HALLNAME,&hall[numero],numero*(long)sizeof(player),
			(long)sizeof(player))) waitdelay(1000);
	}
}


void load_saved()
{
	int i,j,l1,l2,c1,c2;
	char c;
	char s[40];

	level=(int)hall[numero].saved-1;

	xobj= -1;
	treasures=0;
	objects=0;
	oldnumber=0;
	oldin=0;
	oldout=0;

	l1=0;
	l2=1;
	c1=XMAX-1;
	c2=0;

	for(i=0;i<YMAX;i++)
		for(j=0;j<XMAX;j++)
		{
			c=saved[i][j];
			switch(c)
			{
				case man: xpos=j; ypos=i; break;
				case treasure: treasures++; objects++; break;
				case object: c=object; objects++; break;
				case saveman: xpos=j; ypos=i; break;
			}
			if (c!=floor)
			{
				l2=i+1;
				if (j<c1) c1=j;
				if (j>c2) c2=j+1;
			}
			tableau[i][j]=(unsigned int)c;
		}

	ycenter=(l2-l1)/2;
	xcenter=(c2-c1)/2;

	pbox(0,200-8,320,8,0);
	sprintf(s,"niveau %d",level+1);
	setcolor(15);
	afftext(160-5*8,200-8,s);
	getbloc(&levelbloc,0,200-8,320,8);

	xview=xcenter;
	yview=ycenter;
	lost=1;
}





void load()
{
	classement();

	if (classe)
	{
		if (hall[numero].saved)
		{
			while(bload(HALLNAME,saved,
				(long)sizeof(hall)+numero*(long)sizeof(saved),
				(long)sizeof(saved))) waitdelay(1000);
			load_saved();
		}
		else
		{
			cls();
			setcolor(15);
			afftext(8*7,100-4,"aucune partie sauvegardee!");
			lost=1;
			swap();
			waitdelay(1000);
			put_level();
		}
	}
	else
	{
		cls();
		setcolor(15);
		afftext(8*5,100-4,"vous n'etes pas encore classe!");
		lost=1;
		swap();
		waitdelay(1000);
		put_level();
	}
}




void game()
{
	char r='*';
	int dx,dy,nk;

	nk=1;
	select_next();

	while((r!='q')&&(r!='Q'))
	{
		if (r)
		{
			if (!vmode)
				if ((r==GAUCHE)||(r==DROITE)||(r==BAS)||
						(r==HAUT)||(r=='*')||(r==' '))
					if ((xpos-xview>8)||
						(xpos-xview<-9)||
						(ypos-yview>4)||
						(ypos-yview<-5))
					{					
						xview=xpos;
						yview=ypos;
						lost=1;
					}
			put_level();
			if (selected)
			{
				selected=0;
				put_level();
			}
		}

		r=0;

		if (!nk)
		{
			if (keymap[GAUCHE]) r=GAUCHE;
			if (keymap[DROITE]) r=DROITE;
			if (keymap[HAUT]) r=HAUT;
			if (keymap[BAS]) r=BAS;
			if (keymap['1']) r='1';
			if (keymap['2']) r='2';
			if (keymap['3']) r='3';
			if (keymap['4']) r='4';
			if (keymap['6']) r='6';
			if (keymap['7']) r='7';
			if (keymap['8']) r='8';
			if (keymap['9']) r='9';
		}

		dx=dy=0;


		if (!vmode)
		{		
			if (mousex>=319-4) dx=1;
			if (mousex<=4) dx= -1;
			if (mousey>=199-4) dy= 1;
			if (mousey<=4) dy= -1;
		}

		if (dx|dy) r='m';

		if (!r) waitdelay(100);

		if (kbhit())
		{
			r=getch();
			nk=1;
			if ((r==GAUCHE)||(r==DROITE)||(r==BAS)||(r==HAUT))
				waitdelay(50);
		}
		else if (nk) nk--;

		if (getmouse())
		{
			r='m';
			if (msek&4) r=0;
			if (msek==1) mouse_click();
			if (msek==2) r='u';
		}


		switch(r)
		{
			case 'p':
			case 'P': podium(); break;
			case 'c':
			case 'C': load(); select_next(); r='*'; break;
			case 's':
			case 'S': save(); break;
			case 'h':
			case 'H': intro(); while(!keyhit()) waitdelay(500);
						empty(); break;
			case 13: select_next(); r='*'; break;
			case 'i':
			case 'I': load_level(level); select_next(); r='*'; break;
			case ',':
			case '+': if ((classe)&&(hall[numero].level>level+1))
						load_level(++level); select_next(); r='*'; break;
			case '-': load_level(--level); select_next(); r='*'; break;
			case HAUT: move(0,-1); break;
			case GAUCHE: move(-1,0); break;
			case DROITE: move(1,0); break;
			case BAS: move(0,1); break;
			case ' ': vmode^=1; lost=1; break;
			case 'a':
			case 'A': amode^=1; break;
			case 'u':
			case 'U': restore(); break;
			case '0': xview=xpos; yview=ypos;
						lost=1; r='m'; break;
			case '1': dx= -1; dy=1; break;
			case '2': dx=0; dy=1; break;
			case '3': dx=1; dy=1; break;
			case '4': dx= -1; dy=0; break;
			case '5': xview=xcenter; yview=ycenter;
						lost=1; r='m'; break;
			case '6': dx=1; dy=0; break;
			case '7': dx= -1; dy= -1; break;
			case '8': dx=0; dy= -1; break;
			case '9': dx=1; dy= -1; break;
		}

		if ((dx|dy)&&(!vmode))
		{
			xview+=dx;
			yview+=dy;
			r='m';
			lost=1;
		}

		if (objects==treasures)
		{
			put_level();
			level++;
			save_hall();
			load_level(level);
			select_next();
			r='*';
		}

	}
	save_hall();
}




void get_username()
{
	int i,j;
	char r;
	char s[80];

	sprintf(username,"        ");
	sprintf(s,cuserid(0));

	if (s[0])	
	{
		i=0;
		while((s[i])&&(i<8))
		{
			username[i]=s[i];
			i++;
		}
	}
	else
	{
		i=0;
		r=0;
		while(r!=13)
		{
			cls();
			setcolor(15);
			afftext(160-6*8,100-4,"nom:");
			afftext(160-2*8,100-4,username);
			affchar(160-2*8+8*i,100-4,'_');
			lost=1;
			swap();
			
			while(!kbhit()) waitdelay(100);
			r=getch();
			if ((r==8)&&(i))
				username[--i]=' ';
			else
				if ((r>=' ')&&(i<8))
					username[i++]=r;			
		}
	
	}

	for(i=0;i<YMAX;i++)
		for(j=0;j<XMAX;j++)
			mapinit[i][j]=XMAX*YMAX;
	for(i=0;i<YMAX;i++)
		mapinit[i][XMAX-1]=mapinit[i][0]= -1;
	for(i=0;i<XMAX;i++)
		mapinit[YMAX-1][i]=mapinit[0][i]= -1;

	save_hall();
}


int main()
{
	if (initsystem())
	{
		setpalette(palette);
		get_username();
		
		if (classe) level=(unsigned int)hall[numero].level-1;
		
		intro();
		get_sprites();
		load_level(level);
		game();
		free_all();

		killsystem();
	}

	return 0;
}
