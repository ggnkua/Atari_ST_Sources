/* jewel.c

inspire de XJEWEL

Guillaume LAMONOCA
E.S.E Promotion 94

*/

#include "header.h"

unsigned int gamepal[16]=
{
	0x0000,0x200f,0x404f,0x64ff,
	0x4a00,0x2500,0x6f00,0x40a0,
	0x5050,0x6070,0x5540,0x8ff0,
	0x2888,0x4aaa,0x6ccc,0x8fff
};

char *bijoux[8][16]=
{
"0000011111000000",
"0001100000110000",
"0010000000001000",
"0100000000000100",
"0100021000000100",
"1000210000000010",
"1000100000000010",
"1000000000000010",
"1000000000000010",
"1000000000000010",
"0100000000000100",
"0100000000000100",
"0010000000001000",
"0001100000110000",
"0000011111000000",
"0000000000000000",

"0000000000000000",
"0000000000000000",
"0003232323220000",
"0033323232322000",
"0333232323222200",
"3333323232322220",
"2323222222221210",
"3232222222212120",
"2323222222221210",
"2222212121211110",
"0222121212111100",
"0022212121211000",
"0002121212110000",
"0000000000000000",
"0000000000000000",
"0000000000000000",

"0000009980000000",
"0000099988000000",
"0000999988800000",
"0009999988880000",
"0099999878888000",
"0999998887888800",
"9999988888788880",
"9999888888877770",
"8888988888777770",
"0888898887777700",
"0088889877777000",
"0008888777770000",
"0000888777700000",
"0000088777000000",
"0000008770000000",
"0000000000000000",

"0000000000000000",
"0000000000000000",
"000fffeeeddd0000",
"00fffdeeeeddd000",
"0ffffeeeeedddd00",
"ffffeeeeeeedddd0",
"0eeeedddddcccc00",
"00eeedddddccc000",
"000eeedddccc0000",
"0000eedddcc00000",
"00000eedcc000000",
"000000edc0000000",
"0000000d00000000",
"0000000000000000",
"0000000000000000",
"0000000000000000",

"0000065655000000",
"0000666565500000",
"0006665655550000",
"0066666565555000",
"0056565555454000",
"0065655554545000",
"0056565555454000",
"0065655554545000",
"0056565555454000",
"0065655554545000",
"0056565555454000",
"0055555454444000",
"0005554544440000",
"0000555454400000",
"0000054544000000",
"0000000000000000",

"0000000f00000000",
"000000fbd0000000",
"000000fbd0000000",
"0000f0fbd0e00000",
"00000ffbde000000",
"00ffffbbadddd000",
"0fbbbbbfaaaaac00",
"00ddddaaacccc000",
"00000edacd000000",
"0000e0dac0d00000",
"000000dac0000000",
"000000dac0000000",
"000000dac0000000",
"000000dac0000000",
"000000dac0000000",
"0000000c00000000",

"0000000000000000",
"0000000000000000",
"0000bbbbabbb0000",
"000baaabbabbb000",
"00baabbababbba00",
"00babbbbbaaaba00",
"00babbbbb00baa00",
"00bbabbba00bba00",
"00abbbba00bba000",
"00baaa000bbba000",
"00bbba00bbba0000",
"00bbbabbbba00000",
"000bbbabaa000000",
"0000aaaa00000000",
"0000000000000000",
"0000000000000000",

"0000011111000000",
"0001123332110000",
"00123fffff321000",
"0123fffffff32100",
"013fffffffff3100",
"12fffffffffff210",
"13fffffffffff310",
"13fffffffffff310",
"13ffffffff3ff310",
"12fffffff32ff210",
"013fffff32ff3100",
"0123fffffff32100",
"00123fffff321000",
"0001123332110000",
"0000011111000000",
"0000000000000000"
};

#define perle_noire 0
#define saphir		1
#define emeraude	2
#define diamant		3
#define rubis		4
#define croix		5
#define bague		6
#define perle_joker 7

#define rien		8
#define bord		9

#define GAUCHE '<'
#define DROITE '>'
#define HAUT '^'
#define BAS 'v'

#define DELAIMAX 500L
#define DELAIPAS 5L

#define DEC(c) (int)((c<'A')?(c-'0'):(  (c<'a')?(c-'A'+10):(  c-'a'+10  )  ))

typedef void *bloc;

bloc sprites[9];
bloc masques[8];
bloc backup;

unsigned long score=0L;

int pts[8];

int tab[16][16];
int old[16][16];

int next[3];
int piece[3];
int xpos;
int ypos;
unsigned long delai;


#ifndef VMS
#ifndef unix
#define cuserid(x) ""
#endif
#endif

int tri[40];

#define HALLNAME "jewel.hll"

char username[9];

typedef struct
		{
			char username[9];
			unsigned char parts[3];
		}
		player;

player hall[40];

#define HALL(a,b) hall[a].parts[b]
#define SCORE(i) HALL(i,0)*65536L+HALL(i,1)*256L+(long)HALL(i,2)



void create_podium()
{
	int i;

	for(i=0;i<40;i++)
	{
		hall[i].username[0]=hall[i].username[0]=0;
		hall[i].parts[0]=hall[i].parts[0]=0;
		hall[i].parts[1]=hall[i].parts[1]=0;
		hall[i].parts[2]=hall[i].parts[2]=0;
	}

	bmake(HALLNAME,hall,(long)sizeof(hall));
}



void podium()
{
	int i,j,n,ok,t,k;
	char s[40];

	cls();

	setcolor(15);
	afftext(160-3*8,8,"podium");
	afftext(160-3*8,16,"jewel!");

	if (!bexist(HALLNAME)) create_podium();

	while(bload(HALLNAME,hall,0L,(long)sizeof(hall))) waitdelay(1000);

	for(i=0;i<40;i++)
		tri[i]=i;
		
	ok=0;
	while(!ok)
	{
		ok=1;
		for(i=0;i<39;i++)
		if (SCORE(tri[i])<SCORE(tri[i+1]))
		{
			ok=0;
			t=tri[i];
			tri[i]=tri[i+1];
			tri[i+1]=t;
		}
	}


	for(j=0;j<2;j++)
		for(i=0;i<20;i++)
		{
			n=tri[i+j*20];
			if (hall[n].username[0])
			{
				sprintf(s," %s  %07ld0",hall[n].username,SCORE(n));
				for(k=0;s[k];k++) if (s[k]=='_') s[k]=' ';
				afftext(j*8*20,(4+i)*8,s);
			}
		}

	swap();

	while(!keyhit()) waitdelay(500);
	empty();
}



void save_hall()
{
	int numero,i;
	unsigned long min;

	if (!bexist(HALLNAME)) create_podium();

	while(bload(HALLNAME,hall,0L,(long)sizeof(hall))) waitdelay(1000);

	numero= -1;
	for(i=0;i<40;i++)
		if (!strcmp(hall[i].username,username)) numero=i;

	if (numero!= -1)
	{
		if (score<=SCORE(numero)) numero= -1;
	}
	else
	{
		min=score;
		for(i=0;i<40;i++)
			if (SCORE(i)<min)
			{
				min=SCORE(i);
				numero=i;
			}
	}

	if (numero!= -1)
	{
		sprintf(hall[numero].username,username);
		hall[numero].parts[0]=(unsigned char)(score/65536L);
		hall[numero].parts[1]=(unsigned char)((score%65536L)/256L);
		hall[numero].parts[2]=(unsigned char)(score%256L);
		while(bsave(HALLNAME,&hall[numero],numero*(long)sizeof(player),
			(long)sizeof(player))) waitdelay(1000);
	}


}



void get_username()
{
	int i;
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

}



int aleatoire(n)
int n;
{
	return ((randint()^(unsigned int)systime())%n);
}



void getbackup()
{
	getbloc(&backup,0,0,320,200);	
}

void putbackup()
{
	putbloc(&backup,0,0);
}


void putscore()
{
	char s[10];
	
	pbox(208+16+2*8,32,8*8,8,0);
	setcolor(15);
	sprintf(s,"%07ld0",score);
	afftext(208+16+2*8,32,s);
}


void change_next()
{
	piece[0]=next[0];
	piece[1]=next[1];
	piece[2]=next[2];
	
	next[0]=aleatoire(5)+1;
	next[1]=aleatoire(5)+1;
	next[2]=aleatoire(5)+1;

	if (next[0]==3) next[0]=6;
	if (next[1]==3) next[1]=6;
	if (next[2]==3) next[2]=6;

	if (aleatoire(1000)<10) next[aleatoire(3)]=perle_noire;
	else
	if (aleatoire(200)<10) next[0]=next[1]=next[2]=perle_joker;
	else
	if (aleatoire(50)<10) next[aleatoire(3)]=diamant;
	
	putbloc(&sprites[next[0]],208,0);
	putbloc(&sprites[next[1]],208,16);
	putbloc(&sprites[next[2]],208,32);

	getbackup();
	swap();
	putbackup();
	
	if (delai) delai-=DELAIPAS;
}


void decor()
{
	cls();
	dbox(6,0,12*16+3,12*16+1,12);		
	dbox(5,0,12*16+5,12*16+2,13);		
	dbox(4,0,12*16+7,12*16+3,14);		
	dbox(3,0,12*16+9,12*16+4,15);		
	dbox(2,0,12*16+11,12*16+5,14);		
	dbox(1,0,12*16+13,12*16+6,13);		
	dbox(0,0,12*16+15,12*16+7,12);		
	hline(0,0,14*16,0);

	setcolor(15);
		
	afftext(208+16+3*8,8,"jewel!");

	afftext(208+16+3*8+4,24,"score");
	putscore();

	afftext(208+4,200-16,"p:voir podium");
	afftext(208+4,200-8, "q:quitter jeu");

	putbloc(&sprites[croix],208+4,52+0*16);
	afftext(208+24,56+0*16,"croix");
	afftext(208+20+9*8,56+0*16,"10");
	putbloc(&sprites[bague],208+4,52+1*16);
	afftext(208+24,56+1*16,"bague");
	afftext(208+20+9*8,56+1*16,"20");
	putbloc(&sprites[saphir],208+4,52+2*16);
	afftext(208+24,56+2*16,"saphir");
	afftext(208+20+9*8,56+2*16,"30");
	putbloc(&sprites[emeraude],208+4,52+3*16);
	afftext(208+24,56+3*16,"emeraude");
	afftext(208+20+9*8,56+3*16,"40");
	putbloc(&sprites[rubis],208+4,52+4*16);
	afftext(208+24,56+4*16,"rubis");
	afftext(208+20+9*8,56+4*16,"50");
	putbloc(&sprites[diamant],208+4,52+5*16);
	afftext(208+24,56+5*16,"diamant");
	afftext(208+20+8*8,56+5*16,"100");
	putbloc(&sprites[perle_noire],208+4,52+6*16);
	afftext(208+24,56+6*16,"perle");
	afftext(208+20+6*8,56+6*16,"noire");
	putbloc(&sprites[perle_joker],208+4,52+7*16);
	afftext(208+24,56+7*16,"perle");
	afftext(208+20+6*8,56+7*16,"joker");

	pts[croix]=1;
	pts[bague]=2;
	pts[saphir]=3;
	pts[emeraude]=4;
	pts[rubis]=5;
	pts[diamant]=10;
	pts[perle_noire]=0;
	pts[perle_joker]=0;
}


void putjewels()
{
	int i,j;
	
	for(i=2;i<14;i++)
		for(j=2;j<14;j++)
			if (old[i][j]!=tab[i][j])
			{
				putbloc(&sprites[tab[i][j]],8+(j-2)*16,(i-2)*16);
				old[i][j]=tab[i][j];
			}
	getbackup();
	swap();
	putbackup();
}


void verifie()
{
	int i,j,b,dx,dy,f,n;
	unsigned long points;
	
	f=0;
	
	for(i=2;i<14;i++)
		for(j=2;j<14;j++)
			if ((b=(tab[i][j]&63))!=rien)
			{
				dx= -1; dy= -1;
				if ((((tab[i+dy][j+dx]&63)==b)||((tab[i+dy][j+dx]&63)==perle_joker))&&
					(((tab[i+dy+dy][j+dx+dx]&63)==b)||((tab[i+dy+dy][j+dx+dx]&63)==perle_joker)))
				{
					f=1;
					tab[i][j]|=64;
					tab[i+dy][j+dx]|=64;
					tab[i+dy+dy][j+dx+dx]|=64;
				}

				dx=  0; dy= -1;
				if ((((tab[i+dy][j+dx]&63)==b)||((tab[i+dy][j+dx]&63)==perle_joker))&&
					(((tab[i+dy+dy][j+dx+dx]&63)==b)||((tab[i+dy+dy][j+dx+dx]&63)==perle_joker)))
				{
					f=1;
					tab[i][j]|=64;
					tab[i+dy][j+dx]|=64;
					tab[i+dy+dy][j+dx+dx]|=64;
				}

				dx=  1; dy= -1;
				if ((((tab[i+dy][j+dx]&63)==b)||((tab[i+dy][j+dx]&63)==perle_joker))&&
					(((tab[i+dy+dy][j+dx+dx]&63)==b)||((tab[i+dy+dy][j+dx+dx]&63)==perle_joker)))
				{
					f=1;
					tab[i][j]|=64;
					tab[i+dy][j+dx]|=64;
					tab[i+dy+dy][j+dx+dx]|=64;
				}

				dx= -1; dy=  0;
				if ((((tab[i+dy][j+dx]&63)==b)||((tab[i+dy][j+dx]&63)==perle_joker))&&
					(((tab[i+dy+dy][j+dx+dx]&63)==b)||((tab[i+dy+dy][j+dx+dx]&63)==perle_joker)))
				{
					f=1;
					tab[i][j]|=64;
					tab[i+dy][j+dx]|=64;
					tab[i+dy+dy][j+dx+dx]|=64;
				}

				dx=  1; dy=  0;
				if ((((tab[i+dy][j+dx]&63)==b)||((tab[i+dy][j+dx]&63)==perle_joker))&&
					(((tab[i+dy+dy][j+dx+dx]&63)==b)||((tab[i+dy+dy][j+dx+dx]&63)==perle_joker)))
				{
					f=1;
					tab[i][j]|=64;
					tab[i+dy][j+dx]|=64;
					tab[i+dy+dy][j+dx+dx]|=64;
				}

				dx= -1; dy=  1;
				if ((((tab[i+dy][j+dx]&63)==b)||((tab[i+dy][j+dx]&63)==perle_joker))&&
					(((tab[i+dy+dy][j+dx+dx]&63)==b)||((tab[i+dy+dy][j+dx+dx]&63)==perle_joker)))
				{
					f=1;
					tab[i][j]|=64;
					tab[i+dy][j+dx]|=64;
					tab[i+dy+dy][j+dx+dx]|=64;
				}

				dx=  0; dy=  1;
				if ((((tab[i+dy][j+dx]&63)==b)||((tab[i+dy][j+dx]&63)==perle_joker))&&
					(((tab[i+dy+dy][j+dx+dx]&63)==b)||((tab[i+dy+dy][j+dx+dx]&63)==perle_joker)))
				{
					f=1;
					tab[i][j]|=64;
					tab[i+dy][j+dx]|=64;
					tab[i+dy+dy][j+dx+dx]|=64;
				}

				dx=  1; dy=  1;
				if ((((tab[i+dy][j+dx]&63)==b)||((tab[i+dy][j+dx]&63)==perle_joker))&&
					(((tab[i+dy+dy][j+dx+dx]&63)==b)||((tab[i+dy+dy][j+dx+dx]&63)==perle_joker)))
				{
					f=1;
					tab[i][j]|=64;
					tab[i+dy][j+dx]|=64;
					tab[i+dy+dy][j+dx+dx]|=64;
				}

			}

	if (!f) return;
	
	points=0L;
	f=0;
	
	for(i=0;i<14;i++)
		for(j=2;j<14;j++)
			if (tab[i][j]&64)
			{
				b=tab[i][j]&63;
				if (b==perle_noire) f++;
				if (i>1) putbloc(&masques[b],8+(j-2)*16,(i-2)*16);
				points+=(long)pts[b];
				tab[i][j]=rien;
			}

	if (f>=3)
	{
		for(i=0;i<14;i++)
			for(j=2;j<14;j++)
				if (tab[i][j]!=rien)
				{
					b=tab[i][j]&63;
					if (i>1) putbloc(&masques[b],8+(j-2)*16,(i-2)*16);
					points+=(long)pts[b];
					tab[i][j]=rien;
				}
	}


	score+=points;
	if (score>9999999L) score=9999999L;

	for(i=0;i<6;i++)
	{	
		swap();
		waitdelay(50);
	}
	
	putscore();
	putjewels();
		
	for(j=2;j<14;j++)
	{
		n=13;
		for(i=13;i>=0;i--)
			if ((b=tab[i][j])!=rien)
				tab[n--][j]=b;
		while(n!= -1) tab[n--][j]=rien;
	}
	
	putjewels();

	verifie();
}


void move(dx,dy,p)
int dx,dy,p;
{
	int i,j;
	int v=1;

	while((dy|dx|p)&&(tab[ypos][xpos]==rien)&&
		(tab[ypos+1][xpos]==rien)&&(tab[ypos+2][xpos]==rien))
	{
		p=0;
	
		tab[ypos][xpos]=piece[0];
		tab[ypos+1][xpos]=piece[1];
		tab[ypos+2][xpos]=piece[2];

		if (v) putjewels();

		tab[ypos][xpos]=tab[ypos+1][xpos]=tab[ypos+2][xpos]=rien;
	
		if (dx)
		{
			if ((tab[ypos][xpos+dx]==rien)&&(tab[ypos+1][xpos+dx]==rien)
				&&(tab[ypos+2][xpos+dx]==rien)) xpos+=dx;
			dx=0;
		}
		else
		if (dy) { ypos++; dy--; v^=1; }
	}
	
	if ((dy)&&(!ypos))
	{
		setcolor(15);
		afftext(12*8+8-4*8-4,100-8,"game over");
		swap();
		while(!kbhit()) waitdelay(500);

		save_hall();

		for(i=0;i<14;i++)
			for(j=0;j<12;j++)
				tab[i][j+2]=rien;

		score=0L;
		delai=DELAIMAX;

		ypos=0;
		xpos=8;
		putscore();
		putjewels();
		change_next();	
		change_next();
		
	}
	else
	if (dy)
	{
		tab[ypos-1][xpos]=piece[0];
		tab[ypos][xpos]=piece[1];
		tab[ypos+1][xpos]=piece[2];
		ypos=0;
		xpos=8;
		putjewels();
		verifie();
		waitdelay((int)delai);
		change_next();
	}
	
}


void game()
{
	int i,j,dx,dy,t,p,nk;
	char r=0;
	unsigned long start;

	decor();
	swap();
	copyscreen();
	getbackup();

	for(i=0;i<16;i++)
		for(j=0;j<16;j++)
			old[i][j]=tab[i][j]=bord;

	for(i=0;i<14;i++)
		for(j=0;j<12;j++)
			old[i][j+2]=tab[i][j+2]=rien;

	score=0L;
	delai=DELAIMAX;
	ypos=0;
	xpos=8;
	change_next();	
	change_next();
	dx=0;
	dy=1;
	p=0;
	nk=1;
	
	start=systime();

	while((r!='q')&&(r!='Q'))
	{
		move(dx,dy,p);
		dx=0;
		dy=0;
		p=0;

		waitdelay(100);

		if (systime()-start>delai)
		{
			start=systime();
			dy=1;
		}
	
		r=0;
		buthit();

		if (!nk)
		{
			if (keymap[GAUCHE]) r=GAUCHE;
			if (keymap[DROITE]) r=DROITE;
		}
		if (kbhit()) { nk=1; r=getch(); } else if (nk) nk--;

		switch(r)
		{
			case 'p':
			case 'P':
				podium();
				break;
			case GAUCHE:
			case '4':
				dx= -1;
				break;
			case DROITE:
			case '6':
				dx=1;
				break;
			case HAUT:
			case '7':
			case '8':
			case '9':
				t=piece[0];
				piece[0]=piece[1];
				piece[1]=piece[2];
				piece[2]=t;
				p=1;
				break;
			case BAS:
			case '5':
				t=piece[2];
				piece[2]=piece[1];
				piece[1]=piece[0];
				piece[0]=t;
				p=1;
				break;
			case ' ':
			case '1':
			case '2':
			case '3':
				empty();
				dy=50;
				break;		
		}
	
	}

	save_hall();
}








int main()
{
	unsigned int i,j,k,c;

	if (initsystem())
	{
		hide();
	
		setpalette(gamepal);

		get_username();

		initbloc(&backup);
		initbloc(&sprites[8]);

		for(i=0;i<8;i++)
		{
			initbloc(&sprites[i]);
			initbloc(&masques[i]);
			for(j=0;j<16;j++)
				for(k=0;k<16;k++)
				{
					plot(i*16+k,j,c=DEC(bijoux[i][j][k]));
					if (c) plot(i*16+k,j+16,15);
				}
			refresh();
			getbloc(&sprites[i],i*16,0,16,16);
			getbloc(&masques[i],i*16,16,16,16);
		}

		getbloc(&sprites[8],8*16,0,16,16);
		getbloc(&masques[0],7*16,16,16,16);

		game();

		for(i=0;i<8;i++)
		{
			freebloc(&sprites[i]);
			freebloc(&masques[i]);
		}		
		freebloc(&sprites[8]);
		
		freebloc(&backup);

		killsystem();	
	}

	return 0;
}
