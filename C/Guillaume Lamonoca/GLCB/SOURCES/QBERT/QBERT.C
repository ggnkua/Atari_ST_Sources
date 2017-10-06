/* QBERT.C

Guillaume LAMONOCA
Supelec (94)

adaptation du jeu d'arcade Q*BERT
l'aspect etrange du source est du au fait que j'avais
ecrit ce programme en GFA basic il y a fort longtemps.
la traduction en C a ete fastidieuse, je n'ai pas eu le courage
de renommer les variables.

*/

#include "header.h"

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


#define ABS(x) ((x>0)?(x):(-(x)))
#define SGN(x) ((!(x))?(0):(  ((x>0)?(1):(-1))  ))
#define MAX(a,b) ((a>b)?(a):(b))
#define MIN(a,b) ((a<b)?(a):(b))

#define GAUCHE '<'
#define DROITE '>'
#define HAUT '^'
#define BAS 'v'

typedef void *bloc;

extern int slx[];
extern int sly[];

extern unsigned int pal[16];

char *Demostr="222222868686868686428442424268884248";

int Cheat=0;

bloc Logo,Im,btmp;
bloc sprites[36][2];

int freezetime=0;
int tmx,tmy,tmlx,tmly;
int P2[7][7];
int Ntt[7],Tt[7],C[4];
int Pp[14],G[7],D[7],P[14];
int Pl[7],Px[7],Py[7],Xt[7],Yt[7],M[7],Dx[7],Dy[7],Xd[7],Yd[7];
int Oldlv=1;
int Demotab[40][2];
int Lndemo;
int quit=0;
int Demo;
int Demon;

int tv,tv1,tv2,tv3,tv4;

int ii,jj,I,F,Lives,Lv,Rx,Ry,Ary,J,Z,Rd,W,OldI;
long Sc,Stl;
int Tm,Ft,X,Y,Ex,Ey,Cc,E;
int Dmx,Dmy,Nbec,Nc,Ncb,Npl,N,Xo,Yo;
int Pouf,Xpf,Ypf,Uggd,Uggg,Slick,Coily,Egg,Egg2,Cegg,Cegg2;
int Plt,Nt,Stand,Nm,Nom,Freeze,T,Dd,No,tmp,Nwtab;

char r;


void Spr(x,y,i,n)
int x,y,i,n;
{
	putbloc(&sprites[n][i],x,y-sly[n]);
}


void Sp(No,Xo,Yo,i,n)
int No,Xo,Yo,i,n;
{
	Spr(Px[No]+Xo,Py[No]+Yo,i,n);
}


void Life()
{
	pbox(8,48,56,24,0);
	Spr(20,60,0,14+C[Ncb-1]);
	if (Lives!=0)
		for(J=1;J<Lives+1;J++)
			Spr(8+20*(J-1),72,1,1);
	getbloc(&btmp,0,28,64,44);
	copybloc(&btmp,0,0,64,44,&Im,0,28);
}


void afftext8(x,y,s)
int x,y;
char *s;
{
	afftext((x-1)*8,(y-1)*8,s);
}


void View()
{
	swap();
	copyscreen();
}





void Score(Xo)
int Xo;
{
	char s[10];
	
	if (T==0)
	{
		if (Demo)
			afftext8(34,9," DEMO ");
		else
			pbox(32*8,8*8,8*8,8,0);
		T= -1;
	}

	getbloc(&btmp,32*8,8*8,8*8,8);
	copybloc(&btmp,0,0,8*8,8,&Im,32*8,8*8);

	pbox(0,2*8,10*8,8,0);
	sprintf(s,"%07ld0",Sc);
	setcolor(15);
	afftext(4,2*8,s);
	
	getbloc(&btmp,0,2*8,10*8,8);
	copybloc(&btmp,0,0,10*8,8,&Im,0,2*8);
	
	if (Sc/Stl<(Sc+(long)Xo)/Stl)
	{
		Stl=Stl+2000L;
		if (Lives<3)
		{
			setcolor(15);
			afftext8(34,9,"BONUS!");

			getbloc(&btmp,32*8,8*8,8*8,8);
			copybloc(&btmp,0,0,8*8,8,&Im,32*8,8*8);

			T=16;
			Lives++;
			Life();
		}
	}
	Sc=Sc+(long)Xo;
	if (Sc>9999999L)
		Sc=9999999L;
}




int aleatoire(n)
int n;
{
	return(randval(n));
}




void Rbox(x1,y1,x2,y2)
{
	dbox(x1,y1,x2-x1+1,y2-y1+1,-1);
}


			


void Qbert2()
{
	if (Dy[0]==0) tv1= 1; else tv1=0;
	if (Xt[0]+Yt[0]==3) tv= -1; else tv=0;
	if (M[0]<23-tv)
		Sp(0,-8+Xd[0],6+Yd[0],tv1,4);
}

void Sam2()
{
	if (Dy[3]==0) tv1= 1; else tv1=0;
	if (Xt[3]+Yt[3]==3) tv= -1; else tv=0;
	if (M[3]<23-tv)
		if (Slick)
			Sp(3,-8+Xd[3],6+Yd[3],tv1,31);
		else
			Sp(3,-8+Xd[3],4+Yd[3],tv1,8);
}

void Coily2_2()
{
	if (Dy[2]==0) tv1= 1; else tv1=0;
	if (Xt[2]+Yt[2]==3) tv= -1; else tv=0;
	if (Egg==0 && M[2]<23-2*tv)
		Sp(2,-8+Xd[2],4+Yd[2],tv1,21);
}

void Coily2_1()
{
	if (Dy[1]==0) tv1= 1; else tv1=0;
	if (Xt[1]+Yt[1]==3) tv= -1; else tv=0;
	if (Egg2==0 && M[1]<23-2*tv && Coily)
		Sp(1,-8+Xd[1],4+Yd[1],tv1,21);
}

void Pos(No)
int No;
{
	if (No==5 || No==6)
	{
		if (No==5)
		{
			Px[5]=264-Xt[5]*32-16*Yt[5];
			Py[5]=180-Yt[5]*24;
		}
		else
		{
			Px[6]=56+Yt[6]*32+16*Xt[6];
			Py[6]=180-Xt[6]*24;
		}
	}
	else
	{
		Px[No]=160+16*Xt[No]-16*Yt[No];
		Py[No]=24+24*Xt[No]+24*Yt[No];
	}
}

void Guide(No,Nk)
int No,Nk;
{
	Rx=SGN(Xt[Nk]-Xt[No]);
	Ry=SGN(Yt[Nk]-Yt[No]);
	if (Rx==0 && Ry==0)
	{
		Rx=Dx[Nk];
		Ry=Dy[Nk];
	}
	if (ABS(Xt[Nk]-Xt[No])<ABS(Yt[Nk]-Yt[No]) && Rx && Ry)
		Rx=0;
	if (ABS(Xt[Nk]-Xt[No])>ABS(Yt[Nk]-Yt[No]) && Rx && Ry)
		Ry=0;
	if (ABS(Xt[Nk]-Xt[No])==ABS(Yt[Nk]-Yt[No]) && Rx && Ry)
	{
	    if (Xt[No]+Yt[No]==6)
    	{
			if (Xt[No]+Yt[No]+Rx>6)
				Rx=0;
			else
				Ry=0;
		}
		else
		{
			if (Xt[No]<Yt[No])
				Rx=0;
			else
				Ry=0;
		}
	}
}

void Ugg_g()
{
	if (Uggg)
	{
		if (M[6]>0 && M[6]<6 || (M[6]==0 && Yd[6]==0))
		{
			if (Dy[6]==0)
				Sp(6,-25+Xd[6],12+Yd[6],1,28);
			else
				Sp(6,-24+Xd[6],10+Yd[6],1,34);
		}
		else
		{
			if (Dy[6]==0)
				Sp(6,-25+Xd[6],13+Yd[6],1,25);
			else
				Sp(6,-24+Xd[6],10+Yd[6],1,35);
		}
	}
	else
	{
		if (M[6]==0)
		{
			if (Dy[6]==0)
				Sp(6,-25+Xd[6],18+Yd[6],1,29);
			else
				Sp(6,-27+Xd[6],14+Yd[6],1,27);
		}
		else
		{
			if (Dy[6]==0)
				Sp(6,-25+Xd[6],20+Yd[6],1,26);
			else
				Sp(6,-27+Xd[6],15+Yd[6],1,24);
		}
	}
}

void Ugg_d()
{
	if (Uggd)
	{
		if (M[5]>0 && M[5]<6 || (M[5]==0 && Yd[5]==0))
		{
			if (Dx[5]==0)
				Sp(5,-7+Xd[5],12+Yd[5],0,28);
			else
				Sp(5,-8+Xd[5],10+Yd[5],0,34);
		}
		else
		{
			if (Dx[5]==0)
				Sp(5,-7+Xd[5],13+Yd[5],0,25);
			else
				Sp(5,-8+Xd[5],10+Yd[5],0,35);
		}
	}
	else
	{
		if (M[5]>0 && M[5]<6 || (M[5]==0 && Yd[5]==0))
		{
			if (Dx[5]==0)
				Sp(5,-7+Xd[5],18+Yd[5],0,29);
			else
				Sp(5,-5+Xd[5],14+Yd[5],0,27);
		}
		else
		{
			if (Dx[5]==0)
				Sp(5,-7+Xd[5],20+Yd[5],0,26);
			else
				Sp(5,-5+Xd[5],15+Yd[5],0,24);
		}
	}
}

void Balle_rouge()
{
	if (Coily)
	{
		if (Egg2)
			Sp(1,-8+Xd[1],3+Yd[1],0,11);
		else
		{
			if (M[1]<9 || Dx[1]+Dy[1]>-1)
			{
				if ((Dx[1]==1 || Dy[1]==1) && M[1]==0) tv1= 1; else tv1=0;
				if (M[1]>0) tv2= 1; else tv2=0;
				if (M[1]>0 && (Dx[1]==1 || Dy[1]==1)) tv3= 1; else tv3=0;
				if (Dy[1]==0) tv4= 1; else tv4=0;
				Sp(1,-8+Xd[1],4+Yd[1],tv4,6+tv1+15*tv2+tv3);
			}
		}
	}
	else
		Sp(1,-8+Xd[1],3+Yd[1],0,10);
}

void Sam()
{
	if (M[3]<9 || Dx[3]+Dy[3]>0)
	{
		if (Slick)
		{
			if ((Dx[3]== -1 || Dy[3]== -1) && M[3]==0) tv1= 1; else tv1=0;
			if (M[3]>0) tv2= 1; else tv2=0;
			if (M[3]>0 && (Dx[3]== -1 || Dy[3]== -1)) tv3= 1; else tv3=0;
			if (Dy[3]==0) tv4= 1; else tv4=0;
			Sp(3,-8+Xd[3],4-2*tv2+Yd[3],tv4,32+tv1-2*tv2+tv3);
		}
		else
		{
			if ((Dx[3]== 1 || Dy[3]== 1) && M[3]==0) tv1= 1; else tv1=0;
			if (M[3]>0) tv2= 1; else tv2=0;
			if (M[3]>0 && (Dx[3]== 1 || Dy[3]== 1)) tv3= 1; else tv3=0;
			if (Dy[3]==0) tv4= 1; else tv4=0;
			Sp(3,-8+Xd[3],4-2*tv2+Yd[3],tv4,2+tv1+6*tv2+tv3);
		}
	}
}

void Balle_verte()
{
	Sp(4,-8+Xd[4],3+Yd[4],0,12);
}

void Coilyf()
{
	if (Egg)
		Sp(2,-8+Xd[2],3+Yd[2],0,11);
	else
	{
		if (M[2]<9 || Dx[2]+Dy[2]>-1)
		{
			if ((Dx[2]==1 || Dy[2]==1) && M[2]==0) tv1= 1; else tv1=0;
			if (M[2]>0) tv2= 1; else tv2=0;
			if (M[2]>0 && (Dx[2]==1 || Dy[2]==1)) tv3= 1; else tv3=0;
			if (Dy[2]==0) tv4= 1; else tv4=0;
			Sp(2,-8+Xd[2],4+Yd[2],tv4,6+tv1+15*tv2+tv3);
		}
	}
}

void Qbert()
{
	if (M[0]<9 || Dx[0]+Dy[0]>0)
	{
		if ((Dx[0]==1 || Dy[0]==1) && M[0]==0) tv1= 1; else tv1=0;
		if (M[0]>0) tv2= 1; else tv2=0;
		if (M[0]>0 && (Dx[0]==1 || Dy[0]==1)) tv3= 1; else tv3=0;
		if (Dy[0]==0) tv4= 1; else tv4=0;
		Sp(0,-8+Xd[0],4-2*tv2+Yd[0],tv4,tv1+4*tv2+tv3);
	}
}

void Killed(Nk)
int Nk;
{
	if (Ntt[Nk]!=Nbec)
	{
		for(J=Ntt[Nk];J<Nbec;J++)
		{
			Tt[J]=Tt[J+1];
			Ntt[Tt[J]]--;
		}
	}
	Nbec--;
	Xpf=Px[Nk]+Xd[Nk]-8;
	Ypf=Py[Nk]+Yd[Nk]+4;
	Xt[Nk]=0;
	Yt[Nk]=0;
	M[Nk]= -1;
	if (Nk!=0) M[Nk]= -99;
	Xd[Nk]=0;
	Yd[Nk]= -40;
	if (Nk==5 || Nk==6)
	{
		if (Nk==5)
			Xd[5]=40;
		else
			Xd[6]= -40;
		Yd[Nk]=20;
	}
	Dy[Nk]=1;
	Dx[Nk]=0;
	Pouf=0;
	if (Nk==3 && M[0]>-1)
		Score(30);
	if (Nk==2)
		Cegg=48-Nt;
	if (Nk==1)
		Cegg2=48-Nt;
	if (((Nk==2 && Egg==0) || (Nk==1 && Egg2==0 && Coily)) && M[0]>-1)
		Score(50);
	if (Nk==0)
	{
		Stand=0;
		Freeze=0;
	}
	Pos(Nk);
}





void Flip()
{
	if ((I==0 && C[1+P2[Xt[I]][Yt[I]]]!=16) || 
		(I==3 && C[P2[Xt[I]][Yt[I]]]!=C[0]))
	{
		Z=P2[Xt[I]][Yt[I]];
		Z++;
		if (I==3)
		{
			if (C[Z]==17 || C[Z]==16)
				Nc--;
			Z=0;
		}
		if (C[Z]==17)
		{
			Z=0;
			Nc--;
		}
		if (C[Z+1]>15)
			Nc++;
		P2[Xt[I]][Yt[I]]=Z;
		
		putbloc(&sprites[14+C[Z]][0],Px[I]-16,Py[I]+24-32);
		getbloc(&btmp,Px[I]-16,Py[I]+24-32,32,32);
		copybloc(&btmp,0,0,32,32,&Im,Px[I]-16,Py[I]+24-32);

		if (Z!=0)
			Score(1);
		if (Nc==28)
			W=2;
	}
}


void Cf(C,Ox,Oy,Rx,Ry)
int C,Ox,Oy,Rx,Ry;
{
	pellipse(X+Ox*Ex-Rx*Ex,Y+Oy*Ey-Ry*Ey,2*Rx*Ex,2*Ry*Ey,C*Cc);
}


void Tf(C,X1,Y1,X2,Y2,X3,Y3)
int C,X1,Y1,X2,Y2,X3,Y3;
{
	int t[8];

	t[0]=X1*Ex/10+X;
	t[1]=Y1*Ey/10+Y;
	t[2]=X2*Ex/10+X;
	t[3]=Y2*Ey/10+Y;
	t[4]=X3*Ex/10+X;
	t[5]=Y3*Ey/10+Y;
	t[6]=X1*Ex/10+X;
	t[7]=Y1*Ey/10+Y;
	polyfill(4,t,C*Cc);
}

void Rf(C,X1,Y1,X2,Y2)
int C,X1,Y1,X2,Y2;
{
	pbox(X+X1*Ex,Y+Y1*Ey,X2*Ex-X1*Ex,Y2*Ey-Y1*Ey,C*Cc);
}


void Logod(Xx,Yy,Eex,Eey,Ccc)
int Xx,Yy,Eex,Eey,Ccc;
{
	int Pas;
	
	X=Xx;
	Y=Yy;
	Cc=Ccc;
	Ex=Eex;
	Ey=Eey;
	
	cls();
	Pas=9*Ex;

	Cf(1,4,5,4,5);
	Cf(0,4,5,2,3);
	Cf(1,7,9,1,1);
	Cf(1,5,7,1,1);
	X+=Pas;

	Cf(1,4,1,1,1);
	Cf(1,1,3,1,1);
	Cf(1,1,7,1,1);
	Cf(1,4,9,1,1);
	Cf(1,7,3,1,1);
	Cf(1,7,7,1,1);
	Tf(1,30,10,50,10,40,50);
	Tf(1,30,90,50,90,40,50);
	Tf(1,10,40,17,23,40,50);
	Tf(1,10,60,17,77,40,50);
	Tf(1,70,40,63,23,40,50);
	Tf(1,70,60,63,77,40,50);
	X+=Pas;

	Cf(1,4,3,4,3);
	Cf(1,4,7,4,3);
	Cf(0,4,3,2,1);
	Cf(0,4,7,2,1);
	Rf(1,0,0,4,10);
	Rf(0,2,2,4,4);
	Rf(0,2,6,4,8);
	X+=Pas;

	Rf(1,0,0,8,10);
	Rf(0,2,2,8,8);
	Rf(1,2,4,6,6);
	X+=Pas;

	Cf(1,4,3,4,3);
	Cf(0,4,3,2,1);
	Rf(1,0,0,4,6);
	Rf(1,0,0,2,10);
	Rf(0,2,2,4,4);
	Tf(1,38,60,58,100,80,100);
	Tf(1,38,60,80,100,50,40);
	X+=Pas;

	Rf(1,0,0,8,2);
	Rf(1,3,0,5,10);
	X+=Pas;
	
}


void Title(C1)
int C1;
{
	cls();
	Logod(1,62,6,5,C1);
	getbloc(&Logo,0,60,320,60);
}


void Afftime()
{
	char s[10];

	pbox(36*8,6*8,4*8,8,0);	
	sprintf(s,"%02d",Tm/10);
	setcolor(15);
	afftext8(39,7,s);
	
	getbloc(&btmp,36*8,6*8,4*8,8);
	copybloc(&btmp,0,0,4*8,8,&Im,36*8,6*8);
}

void Fadein()
{
}

void Fadeout()
{
}

void Info1()
{
	cls();
	setcolor(15);
	afftext8(14,1,"YOU ARE Q*BERT");
	setcolor(6);
	dline(13*8,1*8+1,(13+14)*8-1,1*8+1,-1);
	setcolor(5);
	dline(13*8,1*8+2,(13+14)*8-1,1*8+2,-1);
	setcolor(15);
	afftext8(4,3,"YOU ARE PRISONER OF THE PYRAMID");
	afftext8(4,4,"COMPLEX AND THE WAY TO FREEDOM IS");
	afftext8(4,5,"HEAVILY GUARDED BY STRANGE BEINGS...");
	afftext8(4,8,"IN ORDER TO QUIT A PYRAMID YOU  ");
	afftext8(4,9,"MUST TRANSFORM EACH ENERGY CUBE ");
	afftext8(4,10,"AND REACH THE CRITIC ENERGY LEVEL.");
	afftext8(4,13,"BLOWING UP A PYRAMID WILL TRANSPORT");
	afftext8(4,14,"YOU TO THE NEXT ONE...    ");
	afftext8(4,17,"OTHER PRISONERS SAID THAT THE ");
	afftext8(4,18,"ENERGY LEVEL OF THE LASTEST PYRAMID");
	afftext8(4,19,"CAN TRANSPORT YOU FAR AWAY...");
	afftext8(4,22,"BUT ITS MORTAL RADIATIONS WILL");
	afftext8(4,23,"QUICKLY DESTROY ANY CREATURE...");
}

void Info2()
{
	cls();
	afftext8(9,1,"HERE ARE YOUR FRIENDS");
	setcolor(6);
	dline(8*8,1*8+1,(8+21)*8-1,1*8+1,-1);
	setcolor(5);
	dline(8*8,1*8+2,(8+21)*8-1,1*8+2,-1);
	setcolor(15);
	afftext8(11,3,"THIS MAGENTA SNAKE IS THE");
	afftext8(11,4,"MOST POWERFUL GUARDIAN.HE'S");
	afftext8(11,5,"VERY FOND OF ORANGE FLESH...");
	afftext8(1,4,"COILY");
	afftext8(1,5,"(500)");
	afftext8(11,8,"THE GUARDIANS FOOD,IN YOUR");
	afftext8(11,9,"MOUTH IT MAY REVEAL SOME");
	afftext8(11,10,"STRANGE POWER...");
	afftext8(1,9,"FRUIT");
	afftext(4,9*8,"(50)");
	afftext8(11,13,"POISONED FRUIT.IT SEEMS");
	afftext8(11,14,"THAT SOME VERY INTELLIGENT");
	afftext8(11,15,"BEING LIVES INSIDE.");
	afftext8(1,14," RED"); afftext8(1,15,"FRUIT");
	afftext8(11,18,"IT LOOKS LIKE SOME EGG...");
	afftext8(11,19,"YOU SHOULD ALWAYS KEEP AN");
	afftext8(11,20,"EYE ON THEM...");
	afftext8(1,19," ODD"); afftext8(1,20,"FRUIT");
	afftext8(11,23,"STRANGE DEVICES DESIGNED TO");
	afftext8(11,24,"TRANSPORT GUARDIANS AWAY.");
	afftext8(11,25,"PERHAPS COULD YOU USE THEM.");
	afftext8(1,24,"LIFTS");
	Spr(6*8+4,5*8,1,7);
	Spr(6*8+4,9*8,0,12);
	Spr(6*8+4,14*8,0,10);
	Spr(6*8+4,19*8,0,11);
	Spr(6*8+5,24*8,0,13);
}

void Info3()
{
	int t[16];
	
	cls();
	afftext8(9,1,"MORE AND MORE FRIENDS");
	setcolor(6);
	dline(8*8,1*8+1,(8+21)*8-1,1*8+1,-1);
	setcolor(5);
	dline(8*8,1*8+2,(8+21)*8-1,1*8+2,-1);
	setcolor(15);
	afftext8(11,3,"THIS UGLY GREEN CYCLOP IS");
	afftext8(11,4,"VERY DANGEROUS.HE DOESN'T FALL");
	afftext8(11,5,"IN THE RIGHT DIRECTION! AVOID!");
	afftext8(1,4," UGG");
	afftext8(11,8,"LIKE UGG,THIS HEAVY MONSTER");
	afftext8(11,9,"FALLS UPWARDS.HE'S NOT VERY");
	afftext8(11,10,"INTELLIGENT BUT AVOID AGAIN!");
	afftext8(1,9,"WRONG"); afftext8(1,10," WAY");
	afftext8(11,13,"SAM IS VERY CUTE. HE RESETS");
	afftext8(11,14,"CUBES IN ORDER TO DECREASE");
	afftext8(11,15,"THE PYRAMID ENERGY LEVEL...");
	afftext8(1,14," SAM"); afftext8(1,15,"(300)");
	afftext8(11,18,"SLICK TRANSFORMS CUBES ALSO.");
	afftext8(11,19,"HE'S VERY FOND OF GREEN FRUITS");
	afftext8(11,20,"AND OFTEN WANTS TO CATCH THEM!");
	afftext8(1,19,"SLICK"); afftext8(1,20,"(300)");
	afftext8(11,23,"I TO ABORT. Q TO QUIT GAME.");
	afftext8(11,24,"PRESS P TO PAUSE THE GAME.");
	afftext8(11,25,"MOVING UP WILL LEAD UP-RIGHT.");
	Spr(5*8,5*8,1,34);
	Spr(5*8,10*8,1,27);
	Spr(6*8+4,15*8,1,3);
	Spr(6*8+4,20*8,1,32);
	E=10;
	X=40-(int)(E*1.5);
	Y=24*8-4-(int)(E*0.75);

	t[0]=X;
	t[1]=Y;
	t[2]=X+E*3;
	t[3]=Y;
	t[4]=X+3*E;
	t[5]=Y+(int)(1.5*E);
	t[6]=X+2*E;
	t[7]=Y+E;
	t[8]=X+E;
	t[9]=Y+(int)(1.5*E);
	t[10]=X;
	t[11]=Y+E;
	t[12]=X+E;
	t[13]=Y+(int)(0.5*E);
	t[14]=X;
	t[15]=Y;
	polyline(8,t,6);

	t[0]=X+(int)(1.5*E);
	t[1]=Y+(int)(0.5*E);
	t[2]=X+2*E;
	t[3]=Y+(int)(0.25*E);
	t[4]=X+2*E;
	t[5]=Y+(int)(0.75*E);
	t[6]=X+(int)(2.5*E);
	t[7]=Y+(int)(0.5*E);
	polyline(4,t,5);
}

void Wingame()
{
	cls();
	setcolor(15);
	afftext8(10,5,"CONGRATULATIONS Q*BERT!");
	afftext8(10,8,"   YOU HAVE ESCAPED   ");
	afftext8(10,10," THE TERRIFIC PYRAMID ");
	afftext8(10,12,"       COMPLEX!       ");
	afftext8(10,15,"     YOU ARE FREE     ");
	afftext8(10,18," SPECIAL BONUS 100000 ");
	afftext8(10,21,"   HAVE A NICE DAY!   ");
	Spr(4*8,108,1,5);
	Spr(34*8,108,0,5);
	Sc=Sc+10000L;
}


void Quitf()
{
	cls();
	setcolor(15);
	afftext8(13,12,"HAVE A NICE DAY!");
	Spr(6*8,13*8+4,1,22);
	Spr(31*8,13*8+4,0,22);
	View();	
	
	if (!kbhit()) waitdelay(100);
	if (!kbhit()) waitdelay(100);
	if (!kbhit()) waitdelay(100);
	if (!kbhit()) waitdelay(100);
	if (!kbhit()) waitdelay(100);

	empty();
}


void Info()
{
	Info1();
	View();
	Fadein();
	while (!kbhit()) waitdelay(500); empty();
	Fadeout();
	Info2();
	View();
	Fadein();

	while (!kbhit())
	{
		waitdelay(100);
	}
	empty();

	Fadeout();
	Info3();
	View();
	Fadein();
	while (!kbhit()) waitdelay(500);  empty();
}


