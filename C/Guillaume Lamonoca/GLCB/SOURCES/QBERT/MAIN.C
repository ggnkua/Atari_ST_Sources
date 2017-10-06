/* main.c */

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

extern int pal[];

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

extern int ii,jj,I,F,Lives,Lv,Rx,Ry,Ary,J,Z,Rd,W,OldI;
extern long Sc,Stl;
extern int Tm,Ft,X,Y,Ex,Ey,Cc,E;
extern int Dmx,Dmy,Nbec,Nc,Ncb,Npl,N,Xo,Yo;
extern int Pouf,Xpf,Ypf,Uggd,Uggg,Slick,Coily,Egg,Egg2,Cegg,Cegg2;
extern int Plt,Nt,Stand,Nm,Nom,Freeze,T,Dd,No,tmp,Nwtab;

extern char r;





int main()
{

	if (initsystem())
	{

		hide();
		get_username();
		
		setpalette(pal);

		initbloc(&Logo);
		initbloc(&Im);
		initbloc(&btmp);

		getbloc(&Im,0,0,320,200);
	
		Title(5);
		setcolor(15);
		afftext(160-11*4,200-64,"PLEASE WAIT");
		
		swap();

		initsprites();

		Lndemo=strlen(Demostr);
		for(ii=0;ii<Lndemo;ii++)
		{
			Demotab[ii][0]=Demotab[ii][1]=0;
			switch(Demostr[ii])
			{
				case '4':
					Demotab[ii][0]= -1;
					break;
				case '6':
					Demotab[ii][0]= 1;
					break;
				case '8':
					Demotab[ii][1]= -1;
					break;
				case '2':
					Demotab[ii][1]= 1;
					break;
	    	}
	    }

		while(!quit)
		{

			cls();
			putbloc(&Logo,0,0);
			setcolor(15);
			afftext8(19,11,"INFO");
			afftext8(16,13,"START GAME");
			afftext8(15,15,"HALL OF FAME");
			afftext8(19,17,"DEMO");
			afftext8(19,19,"QUIT");
			if (Cheat)
			  afftext8(11,21,"CHEAT MODE ACTIVATED");
			  
			Spr(9*8,15*8,1,1);
			Spr(29*8,15*8,0,7);
			
			Fadeout();

			setcolor(5);
			Rbox(15*8-4,12*8-4,(15+10)*8+3,13*8+3);
			setcolor(6);
			Rbox(15*8-5,12*8-5,(15+10)*8+4,13*8+4);

			View();
			Fadein();

			if (!kbhit()) waitdelay(100);
			if (!kbhit()) waitdelay(100);
			if (!kbhit()) waitdelay(100);
			if (!kbhit()) waitdelay(100);
			if (!kbhit()) waitdelay(100);

			I=1;
			Ary=0;
			OldI=1;

			do
			{
				if (!kbhit())
				{
					waitdelay(100);
					r=0;
				}
				else
					r=getch();
			
				if ((r=='q')||(r=='Q')) quit=1;
				else
				if (r==HAUT) Ry= -1;
				else
				if (r==BAS) Ry= 1;
				else
				Ry=0;


				if (Ry!=Ary)
				{
					Ary=Ry;

					I=(I+Ry+5)%5;

					if (OldI!=I)
					{
						setcolor(0);
										
					
						switch(OldI)
 						{
		 					case 0:
								Rbox(18*8-4,10*8-4,(18+4)*8+3,11*8+3);
								Rbox(18*8-5,10*8-5,(18+4)*8+4,11*8+4);
								break;
							case 1:
								Rbox(15*8-4,12*8-4,(15+10)*8+3,13*8+3);
								Rbox(15*8-5,12*8-5,(15+10)*8+4,13*8+4);
								break;
							case 2:
								Rbox(14*8-4,14*8-4,(14+12)*8+3,15*8+3);
								Rbox(14*8-5,14*8-5,(14+12)*8+4,15*8+4);
							break;
							case 3:
								Rbox(18*8-4,16*8-4,(18+4)*8+3,17*8+3);
								Rbox(18*8-5,16*8-5,(18+4)*8+4,17*8+4);
							break;
							case 4:
								Rbox(18*8-4,18*8-4,(18+4)*8+3,19*8+3);
								Rbox(18*8-5,18*8-5,(18+4)*8+4,19*8+4);
							break;
						}
					
					
						setcolor(5);
 
		 				switch(I)
		 				{
		 					case 0:
								Rbox(18*8-4,10*8-4,(18+4)*8+3,11*8+3);
								setcolor(6);
								Rbox(18*8-5,10*8-5,(18+4)*8+4,11*8+4);
								break;
							case 1:
								Rbox(15*8-4,12*8-4,(15+10)*8+3,13*8+3);
								setcolor(6);
								Rbox(15*8-5,12*8-5,(15+10)*8+4,13*8+4);
							break;
							case 2:
								Rbox(14*8-4,14*8-4,(14+12)*8+3,15*8+3);
								setcolor(6);
								Rbox(14*8-5,14*8-5,(14+12)*8+4,15*8+4);
								break;
							case 3:
								Rbox(18*8-4,16*8-4,(18+4)*8+3,17*8+3);
								setcolor(6);
								Rbox(18*8-5,16*8-5,(18+4)*8+4,17*8+4);
								break;
							case 4:
								Rbox(18*8-4,18*8-4,(18+4)*8+3,19*8+3);
								setcolor(6);
								Rbox(18*8-5,18*8-5,(18+4)*8+4,19*8+4);
								break;
						}
				
				
					}
					
					OldI=I;
					
					View();						
				}
				
			}while((r!=13)&&(r!=' ')&&(r!='q')&&(r!='Q'));

			empty();

			Fadeout();

			if (!quit)
			switch(I)
			{
				case 0:
					Info();
					break;
				case 1:
					Demo=0;
					game();
					break;
				case 2:
					podium();
					break;
				case 3:
					Demo= -1;
					game();
					break;
				case 4:
					quit=1;
					break;
			}
		}
		
		Quitf();

		freesprites();

		freebloc(&btmp);
		freebloc(&Im);
		freebloc(&Logo);
		killsystem();
	}

	return 0;
}


