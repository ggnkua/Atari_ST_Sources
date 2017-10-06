

/***************************************************************************************************************
*
*							BLOCKOUT				
*
*
*	Ce programme realise un tetris en 3D.
*	Il se joue avec les fleches pour deplacer les pieces et avec les touches Q S et D pour obtenir les
*	rotations suivant les trois axes et la touche RETURN pour faire tomber la piece
*
*		Realise par BOERI Franck avec la precieuse collaboration de Guillaume LAMONOCA
*
*
***************************************************************************************************************/

#include "header.h"

#define noir         0
#define bleu         1
#define vert         2
#define cyan         3
#define rouge        4
#define violet       5
#define kaki         6
#define gris_clair   7
#define gris         8
#define bleu_violet  9
#define vert_clair   10 
#define cyan_clair   11
#define marron       12
#define violet_clair 13
#define jaune        14
#define blanc        15

#define ni 6
#define nj 6
#define nk 15
#define etendue 8

	/* la fenetre correspond a une portion de R2
	 s'etendant de -etendue a +etendue pour les x 
	 et de -etendue a +etendue pour les y */
typedef int entier;

typedef int point[3+1];
typedef int tab3[25][4];
typedef int tab4[49][4];
typedef int tab5[49][4];
typedef int tab6[43][4];
typedef struct { int t[nk+1][ni+1][nj+1]; } puits;
typedef point *tab;
typedef struct
	{
		int n;
		tab tableau_des_points;
		puits matrice;
		int x0,y0,z0,nb_briques,boum;
	}
	piece;




#ifndef VMS
#ifndef unix
#define cuserid(x) ""
#endif
#endif




unsigned long score=0L;

int i,j,k,x,y,nb1,nb2,nb3,novar;
piece piece_courante,piece_a_plaque,piece_tampon,piece_tampon1,piece_tampon2,piece_vide,p1,p2,p3,p4,p5,p6,le_puits;
tab puits_vide,cuvette;
char thechar;
int realkey,nimp;
char chaine[20];
unsigned long DebutChute,TempsDeChute;
void *fond;


tab3 piece3= {{0,0,0,0},{0,0,0,0},{0,0,1,0},{0,0,0,0},{0,1,0,0},{0,0,0,0},{0,0,0,1},
			{1,1,1,1},{0,1,1,0},{1,1,1,1},{0,1,0,1},{1,1,1,1},{0,0,1,1},
			{1,1,0,0},{1,1,1,0},{1,1,0,0},{1,1,0,1},{1,0,1,0},{1,1,1,0},{1,0,1,0},{1,0,1,1},
			{1,0,0,1},{1,1,0,1},{1,0,0,1},{1,0,1,1}};

tab4 piece4= {{0,0,0,0},{0,0,0,0},{0,3,0,0},{0,0,0,0},{0,0,1,0},{0,0,0,0},{0,0,0,2},{0,2,1,0},{0,2,1,1},{0,2,1,0},{0,2,2,0},{0,2,1,0},{0,0,1,0},
		{0,3,2,0},{0,3,2,1},{0,3,2,0},{0,2,2,0},{0,3,2,0},{0,3,0,0},{0,2,2,1},{0,2,1,1},{0,2,2,1},{0,3,2,1},{0,2,2,1},{0,2,2,0},
		{0,0,1,2},{0,1,1,2},{0,0,1,2},{0,0,1,0},{0,0,1,2},{0,0,0,2},{0,1,0,2},{0,1,0,1},{0,1,0,2},{0,0,0,2},{0,1,0,2},{0,1,1,2},
		{0,3,0,1},{0,3,0,0},{0,3,0,1},{0,3,2,1},{0,3,0,1},{0,1,0,1},{0,1,1,1},{0,1,1,2},{0,1,1,1},{0,2,1,1},{0,1,1,1},{0,1,0,1}};

tab5 piece5= {{0,0,0,0},{0,0,0,0},{0,0,0,2},{0,0,0,0},{0,0,2,0},{0,0,0,0},{0,2,0,0},{0,1,0,1},{0,1,2,1},{0,1,0,1},{0,2,0,1},{0,1,0,1},{0,1,0,2},
{0,1,1,0},{0,2,1,0},{0,1,1,0},{0,1,2,0},{0,1,1,0},{0,1,1,2},{0,0,1,1},{0,0,1,2},{0,0,1,1},{0,0,2,1},{0,0,1,1},{0,2,1,1},
{0,0,0,2},{0,0,1,2},{0,0,0,2},{0,1,0,2},{0,2,0,0},{0,2,1,0},{0,2,0,0},{0,2,0,1},{0,0,2,0},{0,1,2,0},{0,0,2,0},{0,0,2,1},
{0,1,1,2},{0,0,1,2},{0,1,1,2},{0,1,0,2},{0,2,1,1},{0,2,1,0},{0,2,1,1},{0,2,0,1},{0,1,2,1},{0,1,2,0},{0,1,2,1},{0,0,2,1}};

tab6 piece6=
{{0,0,0,0},{0,0,0,0},{0,0,2,0},{0,0,0,0},{0,1,0,0},{0,0,0,0},{0,0,0,2},{0,0,0,2},{0,0,1,2},{0,0,0,2},{0,2,0,2},
{0,0,1,1},{0,0,1,2},{0,0,1,1},{0,0,2,1},{0,0,1,1},{0,2,1,1},{0,1,2,1},{0,0,2,1},{0,1,2,1},{0,1,2,0},{0,1,2,1},{0,1,0,1},
{0,2,1,2},{0,2,0,2},{0,2,1,2},{0,0,1,2},{0,2,1,2},{0,2,1,1},{0,2,0,1},{0,2,0,2},{0,2,0,1},{0,2,1,1},{0,2,0,1},{0,1,0,1},
{0,1,0,0},{0,1,2,0},{0,1,0,0},{0,1,0,1},{0,0,2,0},{0,0,2,1},{0,0,2,0},{0,1,2,0}};


unsigned int intropal[16]=
{
	0x0000,0x1200,0x2400,0x3600,0x4800,0x5a00,0x6d00,0x8f00
};

static unsigned int gamepal[16]=
{
	0x0000,0x300a,0x40a0,0x40aa,
	0x5a00,0x6a0a,0x7aa0,0x8aaa,
	0x0888,0x188f,0x28f8,0x38ff,
	0x4f88,0x6f8f,0x8ff8,0x8fff
};

/*  pour la palette  on a les donnees suivantes : 0x gris rouge vert bleu  */




/*****************************************************************************************************/

int tri[40];

#define HALLNAME "blockout.hll"

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


	setcolor(15);
	afftext(160-3*8,8,"podium");
	afftext(160-4*8,16,"BLOCKOUT");

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
				sprintf(s," %s  %07ld",hall[n].username,SCORE(n));
				for(k=0;s[k];k++) if (s[k]=='_') s[k]=' ';
				afftext(j*8*20,(4+i)*8,s);
			}
		}

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




/************************************************************************************************************/

void presentation()
{
	int abscisse;	

	cls();
	swap();
	cls();

	setpalette(intropal);

	empty();
	for(abscisse=1;abscisse<=80;abscisse+=2)
	{
		cls();
		if (kbhit())
			{
			abscisse = 90;
			};
		setcolor(abscisse/11);
		afftext(40+abscisse,96,"BLOCK");
		afftext(40+128+80-abscisse,96,"OUT");
		swap();
	};

	setpalette(gamepal);
	/*waitdelay(2000);*/
	setcolor(15);
	cls();
	afftext(40+80,96,"BLOCK OUT");
	afftext(10,140,"Adapte par Franck BOERI");
	swap();
	thechar = '"';

	empty();
	thechar = getch();
	
	cls();
	swap();


	cls();
	setcolor(15);
	afftext(10,10, "ATTENTION LES YEUX");
	afftext(10,40, "rotation x   : s");
	afftext(10,55, "rotation y   : d");
	afftext(10,70, "rotation z   : f");	
	afftext(10,85, "tranlations  : fleches");
	afftext(10,100,"faire tomber : return");
	afftext(10,115,"podium       : p");
	afftext(10,130,"quitter      : k");
	setcolor(14);
	afftext(10,150, "************************");
	afftext(10,160, "*                      *");
	afftext(10,170, "************************");
	setcolor(4);
	afftext(10,160, "   hit space to begin   ");
	swap();

	copyscreen();

	setcolor(0);
	afftext(10,160, "   hit space to begin   ");


	empty();

	while(!kbhit()) { swap(); waitdelay(400);};

	thechar = getch();
	
	cls();
	swap();
	cls();

}


/************************************************************************************************************/


int xecran(ii,jj,kk)
int ii,jj,kk;
{
	return(160+(ii-ni/2)*164/(kk+5));
}


int yecran(ii,jj,kk)
int ii,jj,kk;
{
	return(100+(jj-nj/2)*164/(kk+5));
}


/************************************************************************************************************/

void cree_cuvette()
{
	int nn,mm,zz;

	setcolor(cyan);
	for(nn=0;nn<=ni;nn++)
	{
		rline(xecran(nn,0,0),yecran(nn,0,0),xecran(nn,0,nk),yecran(nn,0,nk),-1);
		rline(xecran(nn,nj,0),yecran(nn,nj,0),xecran(nn,nj,nk),yecran(nn,nj,nk),-1);
	};
	for(mm=0;mm<=nj;mm++)
	{
		rline(xecran(0,mm,0),yecran(0,mm,0),xecran(0,mm,nk),yecran(0,mm,nk),-1);
		rline(xecran(ni,mm,0),yecran(ni,mm,0),xecran(ni,mm,nk),yecran(ni,mm,nk),-1);
	};
	for(zz=0;zz<=nk;zz++)
	{
		rline(xecran(0,0,zz),yecran(0,0,zz),xecran(0,nj,zz),yecran(0,nj,zz),-1);
		rline(xecran(0,0,zz),yecran(0,0,zz),xecran(ni,0,zz),yecran(ni,0,zz),-1);
		rline(xecran(ni,nj,zz),yecran(ni,nj,zz),xecran(ni,0,zz),yecran(ni,0,zz),-1);
		rline(xecran(ni,nj,zz),yecran(ni,nj,zz),xecran(0,nj,zz),yecran(0,nj,zz),-1);
	};

}


/************************************************************************************************************/


void cree_piece_a_plaque()
{
int i,j;

	for(i=1;i<=ni;i++)
	 for(j=1;j<=nj;j++)
		piece_a_plaque.matrice.t[1][i][j]=0;
	for(i=1;i<=ni;i++)
	 for(j=1;j<=nj;j++)
		piece_a_plaque.matrice.t[2][i][j]=1;
}


/************************************************************************************************************/
 

void affiche()
{
	int i;
	tab tabpts;

	setcolor(blanc);
	tabpts=piece_courante.tableau_des_points;

	for(i=1;i<=(piece_courante.n/2);i++)

		rline(
		xecran(tabpts[2*i-1][1],tabpts[2*i-1][2],tabpts[2*i-1][3]),
		yecran(tabpts[2*i-1][1],tabpts[2*i-1][2],tabpts[2*i-1][3]),
		xecran(tabpts[2*i][1],tabpts[2*i][2],tabpts[2*i][3]),
		yecran(tabpts[2*i][1],tabpts[2*i][2],tabpts[2*i][3]),-1);

}




/************************************************************************************************************/


void cree_piece_vide()
{
	int i,j,k;
	for(i=1;i<=ni;i++)
		for(j=1;j<=nj;j++)
			for(k=1;k<=nk;k++)
				piece_vide.matrice.t[k][i][j]=0;
}


/************************************************************************************************************/


void cree_le_puits()
{
	int i,j;

	cree_piece_vide();

	le_puits.matrice=piece_vide.matrice;
	for(i=1;i<=ni;i++)
		for(j=1;j<=nj;j++)
		le_puits.matrice.t[nk][i][j] = 1;
}



/************************************************************************************************************
*													    *
*				******		DEFINITION DES PIECES 		******			    *
*													    * 
*************************************************************************************************************/

		/*******************************************************
		*****			PIECE 1			   *****
		********************************************************/


void cree_piece1()
{
	tab tabpts;

	cree_piece_vide();

	tabpts=p1.tableau_des_points=(tab)memalloc((36+1)*sizeof(point));
	p1.n=36;

	
	tabpts[1][1] = 0;
	tabpts[2][1] = 2;
	tabpts[3][1] = 2;
	tabpts[4][1] = 2;
	tabpts[5][1] = 2;
	tabpts[6][1] = 1;
	tabpts[7][1] = 1;
	tabpts[8][1] = 1;
	tabpts[9][1] = 1;
	tabpts[10][1] =0;
	tabpts[11][1] = 0;
	tabpts[12][1] = 0;
	tabpts[13][1] = 0;
	tabpts[14][1] = 2;
	tabpts[15][1] = 2;
	tabpts[16][1] = 2;
	tabpts[17][1] = 2;
	tabpts[18][1] = 1;
	tabpts[19][1] = 1;
	tabpts[20][1] = 1;
	tabpts[21][1] = 1;
	tabpts[22][1] = 0;
	tabpts[23][1] = 0;
	tabpts[24][1] = 0;
	tabpts[25][1] = 0;
	tabpts[26][1] = 0;
	tabpts[27][1] = 2;
	tabpts[28][1] = 2;
	tabpts[29][1] = 2;
	tabpts[30][1] = 2;
	tabpts[31][1] = 1;
	tabpts[32][1] = 1;
	tabpts[33][1] = 1;
	tabpts[34][1] = 1;
	tabpts[35][1] = 0;
	tabpts[36][1] = 0;

	tabpts[1][2] = 0;
	tabpts[2][2] = 0;
	tabpts[3][2] = 0;
	tabpts[4][2] = 3;
	tabpts[5][2] = 3;
	tabpts[6][2] = 3;
	tabpts[7][2] = 3;
	tabpts[8][2] = 1;
	tabpts[9][2] = 1;
	tabpts[10][2] = 1;
	tabpts[11][2] = 1;
	tabpts[12][2] = 0;
	tabpts[13][2] = 0;
	tabpts[14][2] = 0;
	tabpts[15][2] = 0;
	tabpts[16][2] = 3;
	tabpts[17][2] = 3;
	tabpts[18][2] = 3;
	tabpts[19][2] = 3;
	tabpts[20][2] = 1;
	tabpts[21][2] = 1;
	tabpts[22][2] = 1;
	tabpts[23][2] = 1;
	tabpts[24][2] = 0;
	tabpts[25][2] = 0;
	tabpts[26][2] = 0;
	tabpts[27][2] = 0;
	tabpts[28][2] = 0;
	tabpts[29][2] = 3;
	tabpts[30][2] = 3;
	tabpts[31][2] = 3;
	tabpts[32][2] = 3;
	tabpts[33][2] = 1;
	tabpts[34][2] = 1;
	tabpts[35][2] = 1;
	tabpts[36][2] = 1;

	tabpts[1][3] = 0;
	tabpts[2][3] = 0;
	tabpts[3][3] = 0;
	tabpts[4][3] = 0;
	tabpts[5][3] = 0;
	tabpts[6][3] = 0;
	tabpts[7][3] = 0;
	tabpts[8][3] = 0;
	tabpts[9][3] = 0;
	tabpts[10][3] = 0;
	tabpts[11][3] = 0;
	tabpts[12][3] = 0;
	tabpts[13][3] = 1;
	tabpts[14][3] = 1;
	tabpts[15][3] = 1;
	tabpts[16][3] = 1;
	tabpts[17][3] = 1;
	tabpts[18][3] = 1;
	tabpts[19][3] = 1;
	tabpts[20][3] = 1;
	tabpts[21][3] = 1;
	tabpts[22][3] = 1;
	tabpts[23][3] = 1;
	tabpts[24][3] = 1;
	tabpts[25][3] = 0;
	tabpts[26][3] = 1;
	tabpts[27][3] = 0;
	tabpts[28][3] = 1;
	tabpts[29][3] = 0;
	tabpts[30][3] = 1;
	tabpts[31][3] = 0;
	tabpts[32][3] = 1;
	tabpts[33][3] = 0;
	tabpts[34][3] = 1;
	tabpts[35][3] = 0;
	tabpts[36][3] = 1;


	p1.matrice= piece_vide.matrice;
	p1.matrice.t[1][1][1] = 1;
	p1.matrice.t[1][2][1] = 1;
	p1.matrice.t[1][2][2] = 1;
	p1.matrice.t[1][2][3] = 1;

	p1.x0=2;
	p1.y0=2;
	p1.z0=1;

	p1.nb_briques = 4;
	p1.boum=1;
}

/************************************************************************************************************/
		/*******************************************************
		*****			PIECE 3			   *****
		********************************************************/

void cree_piece3()
{
	int i,j;

	tab tabpts;

	cree_piece_vide();
	tabpts=p3.tableau_des_points=(tab)memalloc((24+1)*sizeof(point));
	for(i=0;i<=24;i++)
		for(j=0;j<=3;j++)
			{
			tabpts[i][j] = piece3[i][j];
			};

	p3.n=24;
	p3.matrice= piece_vide.matrice;
	p3.matrice.t[1][1][1] = 1;
	p3.x0=1;
	p3.y0=1;
	p3.z0=1;

	p3.nb_briques = 1;
	p3.boum=0;
}
/************************************************************************************************************/

		/*******************************************************
		*****			PIECE 4			   *****
		********************************************************/

void cree_piece4()
{
	int i,j;

	tab tabpts;

	cree_piece_vide();
	tabpts=p4.tableau_des_points=(tab)memalloc((48+1)*sizeof(point));
	for(i=0;i<=48;i++)
		for(j=0;j<=3;j++)
			{
			tabpts[i][j] = piece4[i][j];
			};

	p4.n=48;
	p4.matrice= piece_vide.matrice;
	p4.matrice.t[1][1][1] = 1;
	p4.matrice.t[1][2][1] = 1;
	p4.matrice.t[1][3][1] = 1;
	p4.matrice.t[1][3][2] = 1;
	p4.matrice.t[2][1][1] = 1;
	p4.x0=2;
	p4.y0=1;
	p4.z0=1;

	p4.nb_briques = 5;
	p4.boum=0;
}
/************************************************************************************************************/

		/*******************************************************
		*****			PIECE 5			   *****
		********************************************************/

void cree_piece5()
{
	int i,j;

	tab tabpts;

	cree_piece_vide();
	tabpts=p5.tableau_des_points=(tab)memalloc((48+1)*sizeof(point));
	for(i=0;i<=48;i++)
		for(j=0;j<=3;j++)
			{
			tabpts[i][j] = piece5[i][j];
			};

	p5.n=48;
	p5.matrice= piece_vide.matrice;
	p5.matrice.t[1][1][1] = 1;
	p5.matrice.t[1][2][1] = 1;
	p5.matrice.t[1][1][2] = 1;
	p5.matrice.t[2][1][1] = 1;

	p5.x0=1;
	p5.y0=1;
	p5.z0=1;

	/*p5.x0=2;
	p5.y0=2;
	p5.z0=2;*/

	p5.nb_briques = 4;
	p5.boum=0;
}
/************************************************************************************************************/

		/*******************************************************
		*****			PIECE 6			   *****
		********************************************************/

void cree_piece6()
{
	int i,j;

	tab tabpts;

	cree_piece_vide();
	tabpts=p6.tableau_des_points=(tab)memalloc((42+1)*sizeof(point));
	for(i=0;i<=42;i++)
		for(j=0;j<=3;j++)
			{
			tabpts[i][j] = piece6[i][j];
			};

	p6.n=42;
	p6.matrice= piece_vide.matrice;
	p6.matrice.t[1][1][1] = 1;
	p6.matrice.t[1][1][2] = 1;
	p6.matrice.t[2][1][1] = 1;
	p6.matrice.t[2][2][1] = 1;

	p6.x0=1;
	p6.y0=1;
	p6.z0=1;

	/*p6.x0=2;
	p6.y0=2;
	p6.z0=2;*/

	p6.nb_briques = 4;
	p6.boum=0;
}

/************************************************************************************************************/

		/*******************************************************
		*****			PIECE 2			   *****
		********************************************************/

void cree_piece2()
{
	tab tabpts;

	cree_piece_vide();

	tabpts=p2.tableau_des_points=(tab)memalloc((48+1)*sizeof(point));
	p2.n=48;

	tabpts[1][1] = 2;
	tabpts[2][1] = 1;
	tabpts[3][1] = 1;
	tabpts[4][1] = 1;
	tabpts[5][1] = 1;
	tabpts[6][1] = 2;
	tabpts[7][1] = 1;
	tabpts[8][1] = 1;
	tabpts[9][1] = 1;
	tabpts[10][1] =1;
	tabpts[11][1] = 1;
	tabpts[12][1] = 1;
	tabpts[13][1] = 2;
	tabpts[14][1] = 2;
	tabpts[15][1] = 2;
	tabpts[16][1] = 2;
	tabpts[17][1] = 0;
	tabpts[18][1] = 1;
	tabpts[19][1] = 1;
	tabpts[20][1] = 1;
	tabpts[21][1] = 1;
	tabpts[22][1] = 2;
	tabpts[23][1] = 2;
	tabpts[24][1] = 2;
	tabpts[25][1] = 2;
	tabpts[26][1] = 0;
	tabpts[27][1] = 0;
	tabpts[28][1] = 1;
	tabpts[29][1] = 0;
	tabpts[30][1] = 2;
	tabpts[31][1] = 2;
	tabpts[32][1] = 2;
	tabpts[33][1] = 2;
	tabpts[34][1] = 1;
	tabpts[35][1] = 1;
	tabpts[36][1] = 1;
	tabpts[37][1] = 1;
	tabpts[38][1] = 0;
	tabpts[39][1] = 0;
	tabpts[40][1] = 0;
	tabpts[41][1] = 0;
	tabpts[42][1] = 0;
	tabpts[43][1] = 0;
	tabpts[44][1] = 0;
	tabpts[45][1] = 1;
	tabpts[46][1] = 1;
	tabpts[47][1] = 2;
	tabpts[48][1] = 2;

	tabpts[1][2] = 0;
	tabpts[2][2] = 0;
	tabpts[3][2] = 0;
	tabpts[4][2] = 1;
	tabpts[5][2] = 1;
	tabpts[6][2] = 1;
	tabpts[7][2] = 1;
	tabpts[8][2] = 0;
	tabpts[9][2] = 0;
	tabpts[10][2] =0;
	tabpts[11][2] = 1;
	tabpts[12][2] = 1;
	tabpts[13][2] = 0;
	tabpts[14][2] = 0;
	tabpts[15][2] = 1;
	tabpts[16][2] = 1;
	tabpts[17][2] = 0;
	tabpts[18][2] = 0;
	tabpts[19][2] = 0;
	tabpts[20][2] = 2;
	tabpts[21][2] = 2;
	tabpts[22][2] = 2;
	tabpts[23][2] = 2;
	tabpts[24][2] = 1;
	tabpts[25][2] = 1;
	tabpts[26][2] = 1;
	tabpts[27][2] = 1;
	tabpts[28][2] = 0;
	tabpts[29][2] = 0;
	tabpts[30][2] = 0;
	tabpts[31][2] = 0;
	tabpts[32][2] = 2;
	tabpts[33][2] = 2;
	tabpts[34][2] = 2;
	tabpts[35][2] = 2;
	tabpts[36][2] = 1;
	tabpts[37][2] = 1;
	tabpts[38][2] = 1;
	tabpts[39][2] = 1;
	tabpts[40][2] = 0;
	tabpts[41][2] = 0;
	tabpts[42][2] = 0;
	tabpts[43][2] = 1;
	tabpts[44][2] = 1;
	tabpts[45][2] = 2;
	tabpts[46][2] = 2;
	tabpts[47][2] = 2;
	tabpts[48][2] = 2;

	tabpts[1][3] = 0;
	tabpts[2][3] = 0;
	tabpts[3][3] = 0;
	tabpts[4][3] = 0;
	tabpts[5][3] = 0;
	tabpts[6][3] = 0;
	tabpts[7][3] = 0;
	tabpts[8][3] = 0;
	tabpts[9][3] = 0;
	tabpts[10][3] = 1;
	tabpts[11][3] = 0;
	tabpts[12][3] = 2;
	tabpts[13][3] = 0;
	tabpts[14][3] = 2;
	tabpts[15][3] = 0;
	tabpts[16][3] = 1;
	tabpts[17][3] = 1;
	tabpts[18][3] = 1;
	tabpts[19][3] = 1;
	tabpts[20][3] = 1;
	tabpts[21][3] = 1;
	tabpts[22][3] = 1;
	tabpts[23][3] = 1;
	tabpts[24][3] = 1;
	tabpts[25][3] = 1;
	tabpts[26][3] = 1;
	tabpts[27][3] = 1;
	tabpts[28][3] = 1;
	tabpts[29][3] = 2;
	tabpts[30][3] = 2;
	tabpts[31][3] = 2;
	tabpts[32][3] = 2;
	tabpts[33][3] = 2;
	tabpts[34][3] = 2;
	tabpts[35][3] = 2;
	tabpts[36][3] = 2;
	tabpts[37][3] = 2;
	tabpts[38][3] = 2;
	tabpts[39][3] = 2;
	tabpts[40][3] = 2;
	tabpts[41][3] = 1;
	tabpts[42][3] = 2;
	tabpts[43][3] = 1;
	tabpts[44][3] = 2;
	tabpts[45][3] = 1;
	tabpts[46][3] = 2;
	tabpts[47][3] = 1;
	tabpts[48][3] = 2;


	p2.matrice= piece_vide.matrice;
	p2.matrice.t[2][1][1] = 1;
	p2.matrice.t[2][2][1] = 1;
	p2.matrice.t[2][2][2] = 1;
	p2.matrice.t[1][2][1] = 1;

	p2.x0=2;
	p2.y0=2;
	p2.z0=2;

	p2.nb_briques = 4;
	p6.boum=0;
}


/************************************************************************************************************
*													    *
*				PROCEDURES DE ROTATION ET DE TRANSLATION DES MATRICES			    *
*													    *
*************************************************************************************************************/

void mrx()
{
	int i,j,k;

	cree_piece_vide();
	for(i=1;i<=ni;i++)
		for(j=1;j<=nj;j++)
			for(k=1;k<=nk;k++)
			{
				/*if ((-k+piece_courante.z0+piece_courante.y0-1 <= nj) && (-k+piece_courante.z0+piece_courante.y0-1 >= 1) 
				&& ( j+piece_courante.z0-piece_courante.y0 <= nk) && ( j+piece_courante.z0-piece_courante.y0 >= 1))
				piece_vide.matrice.t[j+piece_courante.z0-piece_courante.y0][i][-k+piece_courante.z0+piece_courante.y0-1 ] = piece_courante.matrice.t[k][i][j];*/

				if ((-k+piece_courante.z0+piece_courante.y0 <= nj) && (-k+piece_courante.z0+piece_courante.y0>= 1) 
				&& ( j+piece_courante.z0-piece_courante.y0 <= nk) && ( j+piece_courante.z0-piece_courante.y0 >= 1))
				piece_vide.matrice.t[j+piece_courante.z0-piece_courante.y0][i][-k+piece_courante.z0+piece_courante.y0 ] = piece_courante.matrice.t[k][i][j];
				
			};

	piece_courante.matrice = piece_vide.matrice;
}



/************************************************************************************************************/

void mry()
{
	int i,j,k;
	cree_piece_vide();
	for(i=1;i<=ni;i++)
		for(j=1;j<=nj;j++)
			for(k=1;k<=nk;k++)
			{
				/*if ((-i+piece_courante.x0+piece_courante.z0 <= nk) && (-i+piece_courante.x0+piece_courante.z0 >= 1) 
				&& ( k+piece_courante.x0-piece_courante.z0 <= ni) && ( k+piece_courante.x0-piece_courante.z0 >= 1))
				piece_vide.matrice.t[-i+piece_courante.x0+piece_courante.z0-1][k+piece_courante.x0-piece_courante.z0][j] = piece_courante.matrice.t[k][i][j];*/
				if ((-i+piece_courante.x0+piece_courante.z0 <= nk) && (-i+piece_courante.x0+piece_courante.z0 >= 1) 
				&& ( k+piece_courante.x0-piece_courante.z0 <= ni) && ( k+piece_courante.x0-piece_courante.z0 >= 1))
				piece_vide.matrice.t[-i+piece_courante.x0+piece_courante.z0][k+piece_courante.x0-piece_courante.z0][j] = piece_courante.matrice.t[k][i][j];
			};

	piece_courante.matrice = piece_vide.matrice;
}



/************************************************************************************************************/

void mrz()
{
	int i,j,k;
	cree_piece_vide();
	for(i=1;i<=ni;i++)
		for(j=1;j<=nj;j++)
			for(k=1;k<=nk;k++)
			{
				/*if ((-j+piece_courante.y0+piece_courante.x0-1 <= ni) && (-j+piece_courante.y0+piece_courante.x0-1 >= 1) 
				&& ( i+piece_courante.y0-piece_courante.x0 <= nj) && ( i+piece_courante.y0-piece_courante.x0 >= 1))
				piece_vide.matrice.t[k][-j+piece_courante.y0+piece_courante.x0-1][i+piece_courante.y0-piece_courante.x0] = piece_courante.matrice.t[k][i][j];*/
				if ((-j+piece_courante.y0+piece_courante.x0 <= ni) && (-j+piece_courante.y0+piece_courante.x0 >= 1) 
				&& ( i+piece_courante.y0-piece_courante.x0 <= nj) && ( i+piece_courante.y0-piece_courante.x0 >= 1))
				piece_vide.matrice.t[k][-j+piece_courante.y0+piece_courante.x0][i+piece_courante.y0-piece_courante.x0] = piece_courante.matrice.t[k][i][j];
			};

	piece_courante.matrice = piece_vide.matrice;
}




/************************************************************************************************************/


void mtxPlus()
{
	int i,j,k;
	cree_piece_vide();
	for(i=2;i<=ni;i++)
		for(j=1;j<=nj;j++)
			for(k=1;k<=nk;k++)
				piece_vide.matrice.t[k][i][j] = piece_courante.matrice.t[k][i-1][j];

	piece_courante.matrice = piece_vide.matrice;
}


/************************************************************************************************************/


void mtxMoins()
{
	int i,j,k;
	cree_piece_vide();
	for(i=1;i<=ni-1;i++)
		for(j=1;j<=nj;j++)
			for(k=1;k<=nk;k++)
				piece_vide.matrice.t[k][i][j] = piece_courante.matrice.t[k][i+1][j];

	piece_courante.matrice = piece_vide.matrice;
}

/************************************************************************************************************/


void mtyPlus()
{
	int i,j,k;
	cree_piece_vide();
	for(j=2;j<=nj;j++)
		for(i=1;i<=ni;i++)
			for(k=1;k<=nk;k++)
				piece_vide.matrice.t[k][i][j] = piece_courante.matrice.t[k][i][j-1];

	piece_courante.matrice = piece_vide.matrice;
}


/************************************************************************************************************/


void mtyMoins()
{
	int i,j,k;
	cree_piece_vide();
	for(j=1;j<=nj-1;j++)
		for(i=1;i<=ni;i++)
			for(k=1;k<=nk;k++)
				piece_vide.matrice.t[k][i][j] = piece_courante.matrice.t[k][i][j+1];

	piece_courante.matrice = piece_vide.matrice;
}

/************************************************************************************************************/


void mtz()
{
	int i,j,k;
	cree_piece_vide();
	for(i=1;i<=ni;i++)
		for(j=1;j<=nj;j++)
			for(k=2;k<=nk;k++)
				piece_vide.matrice.t[k][i][j] = piece_courante.matrice.t[k-1][i][j];

	piece_courante.matrice = piece_vide.matrice;
}



/************************************************************************************************************
*													    *
*			PROCEDURES DE ROTATION ET DE TRANSLATION DES IMAGES DES PIECES			    *
*													    * 
*************************************************************************************************************/


void tx(a)
int a;
{
	int i;
	tab tabpts;

	tabpts=piece_courante.tableau_des_points;

	for(i=1;i<=piece_courante.n;i++)
		tabpts[i][1] = tabpts[i][1] + a;

}


/************************************************************************************************************/

void ty(a)
int a;
{
	int i;
	tab tabpts;

	tabpts=piece_courante.tableau_des_points;

	for(i=1;i<=piece_courante.n;i++)
		tabpts[i][2] = tabpts[i][2] + a;
}

/************************************************************************************************************/

void tz(a)
int a;
{
	int i;
	tab tabpts;

	tabpts=piece_courante.tableau_des_points;

	for(i=1;i<=piece_courante.n;i++)
		tabpts[i][3] = tabpts[i][3] + a;

}


/************************************************************************************************************/

void rx(a)
int a;
{
	int tampon;
	int i;
	tab tabpts;

	tabpts=piece_courante.tableau_des_points;

	for(i=1;i<=piece_courante.n;i++)
	{
		/*tampon = tabpts[i][2];
		tabpts[i][2] 
		= - tabpts[i][3] + piece_courante.z0 + piece_courante.y0 - 2;
		tabpts[i][3]
		= tampon - piece_courante.y0 + piece_courante.z0;*/
	tampon = tabpts[i][2];
		tabpts[i][2] 
		= - tabpts[i][3] + piece_courante.z0 + piece_courante.y0 - 1;
		tabpts[i][3]
		= tampon - piece_courante.y0 + piece_courante.z0;
	}
}



/************************************************************************************************************/
void ry(a)
int a;
{
	int tampon;
	int i;
	tab tabpts;

	tabpts=piece_courante.tableau_des_points;

	for(i=1;i<=piece_courante.n;i++)
	{
		/*tampon = tabpts[i][1];
		tabpts[i][1] 
		= tabpts[i][3] - piece_courante.z0 +1+ piece_courante.x0 -1;
		tabpts[i][3]
		= -tampon + piece_courante.x0-1 + piece_courante.z0-1;*/
	tampon = tabpts[i][1];
		tabpts[i][1] 
		= tabpts[i][3] - piece_courante.z0 +1+ piece_courante.x0 -1;
		tabpts[i][3]
		= -tampon + piece_courante.x0 + piece_courante.z0-1;
	};
}



/************************************************************************************************************/
void rz(a)
int a;
{
	int tampon;
	int i;
	tab tabpts;

	tabpts=piece_courante.tableau_des_points;

	for(i=1;i<=piece_courante.n;i++)
	{
		/*tampon = tabpts[i][1];
		tabpts[i][1] 
		= - tabpts[i][2] + piece_courante.y0 + piece_courante.x0 - 2;
		tabpts[i][2]
		= tampon - piece_courante.x0 + piece_courante.y0;*/
	tampon = tabpts[i][1];
		tabpts[i][1] 
		= - tabpts[i][2] + piece_courante.y0 + piece_courante.x0 - 1;
		tabpts[i][2]
		= tampon - piece_courante.x0 + piece_courante.y0;
	};
}




/************************************************************************************************************/


int nb_brique(piece_a_mesurer)
piece *piece_a_mesurer;
{
	int i,j,k,resultat;

	resultat = 0; 
	for(i=1;i<=ni;i++)
		for(j=1;j<=nj;j++)
			for(k=1;k<=nk;k++)
				resultat = resultat + piece_a_mesurer->matrice.t[k][i][j];
	return(resultat);
}


/************************************************************************************************************/


int intersection(piece1,piece2)
piece *piece1,*piece2;
{
	int i,j,k,resultat;

	resultat = 0;
	for(i=1;i<=ni;i++)
		for(j=1;j<=nj;j++)
			for(k=1;k<=nk;k++)
				if (piece1->matrice.t[k][i][j] + piece2->matrice.t[k][i][j] >= 2) resultat = 1;
	return(resultat);
}



/************************************************************************************************************/


void add(piece1,piece2)
piece *piece1,*piece2;
{
	int i,j,k;

	if (piece2->boum)
{
   for(i=1;i<=ni;i++)
		for(j=1;j<=nj;j++)
			for(k=1;k<=nk;k++)
				piece1->matrice.t[k][i][j] += piece2->matrice.t[k][i][j];
}
else
{
   for(i=1;i<=ni;i++)
		for(j=1;j<=nj;j++)
			for(k=1;k<=nk;k++)
				piece1->matrice.t[k][i][j] += piece2->matrice.t[k][i][j];
}

}


/************************************************************************************************************/

#undef abs
#undef min
#undef max
#define abs(x) ((x<0)?(-(x)):(x))
#define min(a,b) ((a<b)?(a):(b))
#define max(a,b) ((a>b)?(a):(b))

void drawrectbas(xi1,xj1,xk1,xi2,xj2,xk2)
int xi1,xj1,xk1,xi2,xj2,xk2;
{


	xk2 = xk2+1;xk1 = xk1+1;

	rline(xecran(xi1,xj1,xk1),
		yecran(xi1,xj1,xk1),
		xecran(xi1,xj1,xk1),
		yecran(xi1,xj1+1,xk1),-1);

	rline(xecran(xi1,xj1,xk1),
		yecran(xi1,xj1,xk1),
		xecran(xi1+1,xj1,xk1),
		yecran(xi1,xj1,xk1),-1);


	rline(xecran(xi1+1,xj1,xk1),
		yecran(xi1,xj1+1,xk1),
		xecran(xi1,xj1,xk1),
		yecran(xi1,xj1+1,xk1),-1);

	rline(xecran(xi1+1,xj1,xk1),
		yecran(xi1,xj1+1,xk1),
		xecran(xi1+1,xj1,xk1),
		yecran(xi1,xj1,xk1),-1);


}


void drawrect(xi1,xj1,xk1,xi2,xj2,xk2)
int xi1,xj1,xk1,xi2,xj2,xk2;
{

	rline(xecran(xi1,xj1,xk1),
		yecran(xi1,xj1,xk1),
		xecran(xi1,xj1,xk1),
		yecran(xi1,xj1+1,xk1),-1);

	rline(xecran(xi1,xj1,xk1),
		yecran(xi1,xj1,xk1),
		xecran(xi1+1,xj1,xk1),
		yecran(xi1,xj1,xk1),-1);


	rline(xecran(xi1+1,xj1,xk1),
		yecran(xi1,xj1+1,xk1),
		xecran(xi1,xj1,xk1),
		yecran(xi1,xj1+1,xk1),-1);

	rline(xecran(xi1+1,xj1,xk1),
		yecran(xi1,xj1+1,xk1),
		xecran(xi1+1,xj1,xk1),
		yecran(xi1,xj1,xk1),-1);


	/*rline(min(xecran(xi1,xj1,xk1),xecran(xi2,xj2,xk2)),
		min(yecran(xi1,xj1,xk1),yecran(xi2,xj2,xk2)),
		min(xecran(xi1,xj1,xk1),xecran(xi2,xj2,xk2)),
		min(yecran(xi1,xj1,xk1),yecran(xi2,xj2,xk2))+1,-1);

	rline(min(xecran(xi1,xj1,xk1),xecran(xi2,xj2,xk2)),
		min(yecran(xi1,xj1,xk1),yecran(xi2,xj2,xk2)),
		min(xecran(xi1,xj1,xk1),xecran(xi2,xj2,xk2))+1,
		min(yecran(xi1,xj1,xk1),yecran(xi2,xj2,xk2)),-1);

	rline(min(xecran(xi1,xj1,xk1),xecran(xi2,xj2,xk2))+1,
		min(yecran(xi1,xj1,xk1),yecran(xi2,xj2,xk2))+1,
		min(xecran(xi1,xj1,xk1),xecran(xi2,xj2,xk2)),
		min(yecran(xi1,xj1,xk1),yecran(xi2,xj2,xk2))+1,-1);

	rline(min(xecran(xi1,xj1,xk1),xecran(xi2,xj2,xk2))+1,
		min(yecran(xi1,xj1,xk1),yecran(xi2,xj2,xk2))+1,
		min(xecran(xi1,xj1,xk1),xecran(xi2,xj2,xk2))+1,
		min(yecran(xi1,xj1,xk1),yecran(xi2,xj2,xk2)),-1);*/


}

void fillrectbas(xi1,xj1,xk1,xi2,xj2,xk2)
int xi1,xj1,xk1,xi2,xj2,xk2;
{


	xk2 = xk2+1;xk1 = xk1+1;

	pbox(
		min(xecran(xi1,xj1,xk1),xecran(xi2,xj2,xk2)),
		min(yecran(xi1,xj1,xk1),yecran(xi2,xj2,xk2)),
		abs(xecran(xi1,xj1,xk1)-xecran(xi2,xj2,xk2)),
		abs(yecran(xi1,xj1,xk1)-yecran(xi2,xj2,xk2)),-1);

}


void fillrect(xi1,xj1,xk1,xi2,xj2,xk2)
int xi1,xj1,xk1,xi2,xj2,xk2;
{

	pbox(
		min(xecran(xi1,xj1,xk1),xecran(xi2,xj2,xk2)),
		min(yecran(xi1,xj1,xk1),yecran(xi2,xj2,xk2)),
		abs(xecran(xi1,xj1,xk1)-xecran(xi2,xj2,xk2)),
		abs(yecran(xi1,xj1,xk1)-yecran(xi2,xj2,xk2)),-1);


}



void fillverticaux(xi1,xj1,xk1,xi2,xj2,xk2)
int xi1,xj1,xk1,xi2,xj2,xk2;
{

	xk2 = xk2+1;xk1 = xk1+1;

	rline(
		xecran(xi1,xj1,xk1),
		yecran(xi1,xj1,xk1),
		xecran(xi1,xj1,xk1-1),
		yecran(xi1,xj1,xk1-1),-1);
		
	rline(
		xecran(xi1,xj1,xk1),
		yecran(xi2,xj2,xk1),
		xecran(xi1,xj1,xk1-1),
		yecran(xi2,xj2,xk1-1),-1);

	rline(
		xecran(xi2,xj2,xk1),
		yecran(xi1,xj1,xk1),
		xecran(xi2,xj2,xk1-1),
		yecran(xi1,xj1,xk1-1),-1);

	rline(
		xecran(xi2,xj2,xk1),
		yecran(xi2,xj2,xk1),
		xecran(xi2,xj2,xk1-1),
		yecran(xi2,xj2,xk1-1),-1);
}

int couleur(ff)
int ff;
{
	int c=(ff%15)+1;


	switch(ff)
	{
	case 1:  c = vert; break;
	case 2:  c = rouge; break;
	case 3:  c = bleu; break;
	case 4:  c = jaune; break;
	case 5:  c = marron; break;
	case 6:  c = violet; break;

	case 7:  c = vert; break;
	case 8:  c = rouge; break;
	case 9:  c = bleu; break;
	case 10: c = jaune; break;
	case 11: c = marron; break;
	case 12: c = violet; break;

	case 13: c = vert; break;
	case 14: c = rouge; break;
	case 15: c = noir; break;
	case 16: c = jaune; break;
	case 17: c = marron; break;
	case 18: c = violet; break;
	};

	return(c);
}


void affiche_matrice(mat)
puits *mat;
{
	int i,j,k;

	cls();
	cree_cuvette();

	for(k=nk;k>=2;k--)
	{ 

	setcolor(couleur(k));

	  for(j=1;j<=nj;j++)
	   for(i=1;i<=ni;i++)
		if (mat->t[k][i][j]==1)
			fillrectbas(i-1,j-1,k-1,i,j,k-1);
	setcolor(noir);
	  for(j=1;j<=nj;j++)
	   for(i=1;i<=ni;i++)
		if (mat->t[k][i][j]==1)
		drawrectbas(i-1,j-1,k-1,i,j,k-1);

	  for(j=1;j<=nj;j++)
	   for(i=1;i<=ni;i++)
		if (mat->t[k][i][j]==1)
			fillverticaux(i-1,j-1,k-1,i,j,k-1);

	setcolor(couleur(k));
	  for(j=1;j<=nj;j++)
	   for(i=1;i<=ni;i++)
		if (mat->t[k][i][j]==1)
			fillrect(i-1,j-1,k-1,i,j,k-1);
	if (k == nk)
	{
	setcolor(cyan);
	}
	else
	setcolor(noir);
	  for(j=1;j<=nj;j++)
	   for(i=1;i<=ni;i++)
		if (mat->t[k][i][j]==1)
			drawrect(i-1,j-1,k-1,i,j,k-1);
			
	};
	
}
/************************************************************************************************************/


int enleve_plaque()
{
	int i,j;
	int kk,kprime,xp,yp,compteur;
	int r = 0;

	for(kk=nk-1;kk>=1;kk--)
	{
		compteur = 0 ;
		for(xp=1;xp<=ni;xp++)
		  for(yp=1;yp<=nj;yp++)
		    compteur = compteur + le_puits.matrice.t[kk][xp][yp];
		if (compteur == ni*nj)	/* si la plaque est pleine */
		{
		  for(kprime=kk;kprime>=2;kprime--)	/* on fait descendre d'un cran */
	  for(j=1;j<=nj;j++)
	   for(i=1;i<=ni;i++)
		    le_puits.matrice.t[kprime][i][j] = le_puits.matrice.t[kprime-1][i][j];
		  r = 1;
		};
	};
	return(r);
}


/***********************************************************************************************************/

#define PmtxPlus  0
#define PmtxMoins 1
#define PmtyMoins 2
#define PmtyPlus  3
#define Pmrx      4
#define Pmry      5
#define Pmrz      6
#define Ptx       7
#define Pty       8
#define Prx       9
#define Pry       10
#define Prz       11


void action(Mtran_ou_rot,trans_ou_rot,la_valeur,inc,centre)
int Mtran_ou_rot,trans_ou_rot,la_valeur,inc;
int *centre;
{
	piece_tampon = piece_courante;

	switch(Mtran_ou_rot)
	{
	case PmtxPlus: mtxPlus(); break;
	case PmtxMoins: mtxMoins(); break;
	case PmtyMoins: mtyMoins(); break;
	case PmtyPlus: mtyPlus(); break;
	case Pmrx: mrx(); break;
	case Pmry: mry(); break;
	case Pmrz: mrz(); break;
	}


	if ((nb_brique(&piece_courante) == piece_courante.nb_briques)
	&& (!intersection(&piece_courante,&le_puits)))
						
	{
		switch(trans_ou_rot)
		{
		case Ptx: tx(la_valeur); break;
		case Pty: ty(la_valeur); break;
		case Prx: rx(la_valeur); break;
		case Pry: ry(la_valeur); break;
		case Prz: rz(la_valeur); break;
		}

		affiche();
		swap();
		putbloc(&fond,0,0);			

		*centre = *centre+inc;
	}
	else
	piece_courante = piece_tampon;
}

/***********************************************************************************************************/

void choisit_une_piece()
{
int nb;
	nb = randval(5);
	if ( nb == 0)
	{
		cree_piece1();
		piece_courante = p1;
	}
	if ( nb == 1)
	{
		cree_piece5();
		piece_courante = p5;
	}
	if ( nb == 2)
	{
		cree_piece3();
		piece_courante = p3;
	}
	if ( nb == 3)
	{
		cree_piece4();
		piece_courante = p4;
	}
	if ( nb == 4)
	{
		cree_piece6();
		piece_courante = p6;
	}
	
}

/***********************************************************************************************************/

int saturation()
{
int i,j,nb;

	nb = 0;
	for (i=1;i<=ni;i++)
	  for (j=1;j<=nj;j++)
	    nb = nb + le_puits.matrice.t[1][i][j];
	return (nb);
}



/***********************************************************************************************************/

void actualise_temoin_etage()
{int k,i,j,nb_briques;

	for(k=nk-1;k>=1;k--)
	{
		nb_briques = 0;
		for(i=1;i<=ni;i++)
		  for(j=1;j<=nj;j++)
		    nb_briques =  nb_briques + le_puits.matrice.t[k][i][j];
		if (!(nb_briques == 0 ))
		{
			setcolor(couleur(k));
			pbox(20,10*k,10,9,-1);
		}

		if (nb_briques == 0 )
		{
			setcolor(noir);
			pbox(20,10*k,10,9,-1);
		}
	}
}		
/***********************************************************************************************************

*						PROGRAMME PRINCIPAL					   *

************************************************************************************************************/

int main()
{
int quit=0;

if (initsystem())
{
   hide();
   
	initbloc(&fond);

	presentation();

	get_username();


  do
  {

	empty();
	cls();
	swap();
	cls();
	




	setcolor(blanc);
	afftext(0,0,"0000000");

	cree_piece_a_plaque();
	cree_cuvette();
	cree_le_puits();
	
	getbloc(&fond,0,0,320,200);



	TempsDeChute = 1000;
	score = 0;
	
	do
	{	
		choisit_une_piece();
		affiche();
		swap();
		putbloc(&fond,0,0);

		do
		{

			DebutChute=systime();

			do{	
				if (kbhit())
				{
					thechar=getch();


					if (thechar == '<')	
					action(PmtxMoins,Ptx,-1,-1,&piece_courante.x0);

					if (thechar == '^')	
					action(PmtyMoins,Pty,-1,-1,&piece_courante.y0);

					if (thechar == '>')	
					action(PmtxPlus,Ptx,1,1,&piece_courante.x0);

					if (thechar == 'v')	
					action(PmtyPlus,Pty,1,1,&piece_courante.y0);


					if (thechar == 's')
					action(Pmrx,Prx,1,1,&novar);

					if (thechar == 'd')
					action(Pmry,Pry,1,1,&novar);

					if (thechar =='f')
					action(Pmrz,Prz,1,1,&novar);

					if (thechar == 13 || thechar ==' ')
					{
						do{
							piece_tampon = piece_courante;
							mtz();
							if (!intersection(&piece_courante,&le_puits))
							{
								tz(1);
							
								affiche();
								swap();
								putbloc(&fond,0,0);
								piece_courante.z0 = piece_courante.z0+1;
							};
						}while(!intersection(&piece_courante,&le_puits));
						piece_courante = piece_tampon;		
					}
					if (thechar == 'p')
					{
					swap();
					empty();
					podium();
					swap();
					getch();
					empty();
					
					}

					if (thechar == 'k')
					{
					copyscreen();
					empty();
					afftext(90,90,"       BYE     ");
					swap();
					waitdelay(1000);
					
					quit=1;
					}

				}
			}while (((systime() - DebutChute) <= TempsDeChute)&&(!quit));

			piece_tampon = piece_courante;
			mtz();

			if (!quit)
			if (!intersection(&piece_courante,&le_puits))
			{
				tz(1);
				affiche();
				swap();
				putbloc(&fond,0,0);
				piece_courante.z0 = piece_courante.z0+1;
			}
			else
				{
					add(&le_puits, &piece_tampon);
					affiche_matrice(&le_puits.matrice);
					actualise_temoin_etage();

					if (enleve_plaque())
					{
						affiche_matrice(&le_puits.matrice);
						actualise_temoin_etage();
						score = score +200;
						
						if (score<7500) TempsDeChute=250;
						if (score<5000) TempsDeChute=500;
						if (score<2500) TempsDeChute=750;
						if (score<1000) TempsDeChute=1000;
					};
					score = score + 50;

					sprintf(chaine,"%07ld",score);
					pbox(0,0,7*8,8,0);
					setcolor(blanc);
					afftext(0,0,chaine);
					
					getbloc(&fond,0,0,320,200);
				};


		}while ((!quit)&&(!intersection(&piece_courante,&le_puits)));
		memfree((void **)&piece_courante.tableau_des_points);
	}
	while ((!quit)&&(!saturation()));

	save_hall();
  }
  while(!quit);

	freebloc(&fond);

	killsystem();
}
}


