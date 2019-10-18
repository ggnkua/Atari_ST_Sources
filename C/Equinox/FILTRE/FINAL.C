/**************/
/* librairies */
/**************/

#include	<stdio.h>
#include	<math.h>
#include	<alloc.h>
#include	<string.h>
#include	<stdlib.h>
#include	<conio.h>
#include	<graphics.h>
#include	"svga256.h"

/******************************/
/* d‚finitions des constantes */
/******************************/

#define	PI		3.14159265359
#define	RAIDEUR		0.2
#define	RESO		1
#define	VID		3

/**************/
/* prototypes */
/**************/

void	convolution(int);
int	passe_bas(double);
int	passe_bande(double);
int	passe_haut(double);
int	coupe_bande(double);

/************/
/* globales */
/************/

double	*h;

/***********************/
/* programme principal */
/***********************/

main()
{
double		fe;
int		n,k,c;
FILE		*conv;
char		g;

if((conv=fopen("filter.flt","wb"))==NULL)
	{
	printf("erreur lors de l'ouverture du fichier\n");
	exit(1);
	}

printf("\nentrez la frequence d'echantillonage en kHz :");
scanf("%lf",&fe);

printf("\nchoisissez le type de filtre :\n");
printf("1 passe bas\n");
printf("2 passe bande\n");
printf("3 passe haut\n");
printf("4 coupe bande\n");

g=getch();
switch(g)
	{
	case	'1':	n=passe_bas(fe);
			break;
	case	'2':	n=passe_bande(fe);
			break;
	case	'3':	n=passe_haut(fe);
			break;
	case	'4':	n=coupe_bande(fe);
			break;
	default:	break;
	}

for(k=0;k<n;k++)
	{
	c=(int)	ceil(h[k]*32767);
	fwrite(&c,sizeof(int),1,conv);
	}
fclose(conv);
convolution(n);
affich2();
return;
}


/***********************/
/* calcul du passe bas */
/***********************/

passe_bas(fe)
double	fe;
{
double	f1,p;
int	n,k;

do{
	printf("\nentrez la frequence maximum en kHz :");
	scanf("%lf",&f1);
}while(f1>=fe/2);
p=f1/fe;
n=(int) ceil(2*fe/(RAIDEUR));
if(n%2==0)	n++;
printf("\nnombre de termes %d",n);

h=(double *) malloc(sizeof(double)*(n));

for(k=0;k<n;k++)
	{
	if(k==(n-1)/2)	h[k]=(double) 2*p;
	else		h[k]=(double) 2*p*sin(2*(k-n/2)*PI*p)/(2*(k-n/2)*PI*p);
	}
return(n);
}

/*************************/
/* calcul du passe bande */
/*************************/

passe_bande(fe)
double	fe;
{
double	f1,f2,p,fg;
int	n,k;
do{
	printf("\nentrez la frequence 1 en kHz :");
	scanf("%lf",&f1);
}while(f1>=fe/2);
do{
	printf("\nentrez la frequence 2 en kHz :");
	scanf("%lf",&f2);
}while(f2>=fe/2);

p=(f2-f1)/(2*fe);
fg=f1+(f2-f1)/2;
n=(int) ceil(2*fe/(RAIDEUR));
if(n%2==0)	n++;
printf("\nnombre de termes %d",n);
h=(double *) malloc(sizeof(double)*(n));
for(k=0;k<n;k++)
	{
	if(k==(n-1)/2)	h[k]=(double) 4*p;
	else		h[k]=(double) 2*cos(2*PI*(k-n/2)*fg/fe)*sin(2*(k-n/2)*PI*p)/((k-n/2)*PI);
	}
return(n);
}

/************************/
/* calcul du passe haut */
/************************/

passe_haut(fe)
double	fe;
{
double	f1,p;
int	n,k;
do{
	printf("\nentrez la frequence minimum en kHz :");
	scanf("%lf",&f1);
}while(f1>=fe/2);

p=f1/fe;
n=(int) ceil(2*fe/(RAIDEUR));
if(n%2==0)	n++;
printf("\nnombre de termes %d",n);
h=(double *) malloc(sizeof(double)*(n));
for(k=0;k<n;k++)
	{
	if(k==(n-1)/2)	h[k]=(double) 1-2*p;
	else		h[k]=(double) -2*p*sin(2*(k-n/2)*PI*p)/(2*(k-n/2)*PI*p);
	}
return(n);
}

/*************************/
/* calcul du coupe bande */
/*************************/


coupe_bande(fe)
double	fe;
{
double	f1,f2,p,fg;
int	n,k;
do{
	printf("\nentrez la frequence 1 en kHz :");
	scanf("%lf",&f1);
}while(f1>=fe/2);
do{
	printf("\nentrez la frequence 2 en kHz :");
	scanf("%lf",&f2);
}while(f2>=fe/2);
p=(f2-f1)/(2*fe);
fg=f1+(f2-f1)/2;
n=(int) ceil(2*fe/(RAIDEUR));
if(n%2==0)	n++;
printf("\nnombre de termes %d",n);
h=(double *) malloc(sizeof(double)*(n));
for(k=0;k<n;k++)
	{
	if(k==(n-1)/2)	h[k]=(double) 1-4*p;
	else		h[k]=(double) -2*cos(2*PI*(k-n/2)*fg/fe)*sin(2*(k-n/2)*PI*p)/((k-n/2)*PI);
	}
return(n);
}


/**************************/
/* produit de convolution */
/**************************/

void	convolution(n)
int	n;
{
FILE	*spl,*flt;
double	y,*x,p;
int	k,i;
unsigned char	b,sc;


if((spl=fopen("laugh.spl","rb"))==NULL)
	{
	printf("erreur lors de l'ouverture du fichier\n");
	exit(1);
	}
if((flt=fopen("1.spl","wb"))==NULL)
	{
	printf("erreur lors de l'ouverture du fichier\n");
	exit(1);
	}

x=(double *) malloc(sizeof(double)*(n+1));
for(k=0;k<n;k++)
	{
	fread(&b,1,1,spl);
	x[k]=(double) (b/128.)-1;
	}
p=1.10;
do{
	y=0;
	for(k=0;k<n;k++)
		{
		y+=x[k]*h[n-1-k];
		}
	if(y>p)	printf("\nerror");
	sc=(char) ceil((y/p+1)*127);
	fprintf(flt,"%c",sc);
	for(k=0;k<n-1;k++)	x[k]=x[k+1];
	fread(&b,1,1,spl);
	x[n-1]=(double) (b/128.)-1;
}while(!feof(spl));

for(i=1;i<=n;i++)
	{
	y=0;
	for(k=0;k<n;k++)
		{
		y+=x[k]*h[n-1-k];
		}
	if(y>p)	printf("\nerror");
	sc=(char) ceil((y/p+1)*127);
	fprintf(flt,"%c",sc);
	for(k=0;k<n-1;k++)	x[k]=x[k+1];
	x[n]=(double) 0;
	}

fclose(spl);
fclose(flt);
}


affich(n)
int	n;
{
int	k;
hires();
putpixel(0,128,1);
for(k=0;k<n;k++)
	{
	lineto(k,h[k]*128+128);
	}
getch();
closegraph();
return;
}

affich2(n)
int	n;
{
FILE	*fp,*ft;
int	k;
int	j;
unsigned char	b;
fp=fopen("laugh.spl","rb");
ft=fopen("1.spl","rb");
/*for(k=1;k<=10;k++)	fread(&b,1,1,fp);*/
hires();
do{
	cleardevice();
	setcolor(2);
	line(0,0,640,0);
	line(640,0,640,256);
	line(640,256,0,256);
	line(0,256,0,0);
	setcolor(1);
	putpixel(0,0,1);
	lineto(0,128);
	lineto(640,128);
	lineto(0,128);
		for(k=0;k<=640;k++)
		{
		fread(&b,1,1,fp);
		j=(int) b;
		lineto(k,j);
		}
		setcolor(3);
		for(k=0;k<=640;k++)
		{
		fread(&b,1,1,ft);
		j=(int) b;
		lineto(k,j+256);
		}
	getch();
}while(!feof(fp));
closegraph();
fclose(fp);
fclose(ft);
return;
}




hires()
{
vgadetect();
}




int huge DetectVGA256()
{
  return VID;
}


int huge DetectVGA16()
{
/*
  printf("  0) 320x200x16\n");
  printf("  1) 640x200x16\n");
  printf("  2) 640x350x16\n");
  printf("  3) 640x480x256\n");
  printf("  4) 800x600x16\n");
  printf("  5) 1024x768x16\n\n>");
*/
  return VID;
}


int huge DetectTwk16()
{
/*
  printf("Which video mode would you like to use? \n");
  printf("  0) 704x528x16\n");
  printf("  1) 720x540x16\n");
  printf("  2) 736x552x16\n");
  printf("  3) 752x564x16\n");
  printf("  4) 768x576x16\n");
  printf("  5) 784x588x16\n");
  printf("  6) 800x600x16\n\n>");
*/
  return VID;
};

int huge DetectTwk256()
{
/*
  printf("  0) 320x400x256\n");
  printf("  1) 320x480x256\n");
  printf("  2) 360x480x256\n");
  printf("  3) 376x564x256\n");
  printf("  4) 400x564x256\n");
  printf("  5) 400x600x256\n");
*/
  return VID;
};
vgadetect()
{
  int Gd = DETECT, Gm;
  int	Rvd=RESO;
  switch(Rvd)
  {
    case 0: installuserdriver("Svga256",DetectVGA256);
	    break;
    case 1: installuserdriver("Svga16",DetectVGA16);
	    break;
    case 2: installuserdriver("Twk16",DetectTwk16);
	    break;
    case 3: installuserdriver("Twk256",DetectTwk256);
		break;
  }
  initgraph(&Gd,&Gm,"");
}
