/* wingdemo.c : Demo of a 3D maze like Wolfenstein one */
/* author : Guillaume LAMONOCA                         */
/* E-mail : GL@gen4.pressimage.fr                      */
/* You need a GLCB module to compile this demo         */

#include <string.h>
#include "header.h"

/* if your computer is slow... */
#define NO_PROJECTION


/*#define WING_DIRECT_ACCESS*/
/* only for wing.c, wing_gdi.c and gem_wing.c GLCB modules */



#ifdef __WIN32__
#undef huge
#define huge /**/
#endif
         
/* for non PC computers (no segmentation)... */
#ifndef __BORLANDC__
#undef huge
#define huge /**/
#endif

#ifdef NO_PROJECTION
#define WHITE 15
#else
#define WHITE 255
#endif

#define WALL 0


/* screen size defined both here and in GLCB module */
#define WIDTH 320
#define HEIGHT 200
/* if you increase screen size, increase FACT also!!!          */
/* on PC, you will need 32 bits compiler if WIDTH*HEIGHT>65536 */


#define ROTATION_SPEED 2
#define SPEED 2

#define MARGE 256

#define K 8

#define FACT 128L

#define SCALE 4

#define WALL_HEIGHT 48
#define WALL_WIDTH 128

#define LABW 8
#define LABH 8
#define MAX_VERTICES 100



/* prototypes */
void affichage_palette(unsigned char rgbpalette[3*256]);
void presentation(void);
void playdemo(void);
void draw2D(void);
void draw3D(void);
void init_vars(void);
void add_vertice(int d,int x1,int y1,int x2,int y2);
void add_vertices(void);
void draw_line(int x1,int y1,int x2,int y2);
void draw_empty_wall(int x1,int y1,int x2,int y2);
void draw_light(int x1,int y1,int x2,int y2);
void draw_wall(int x1,int y1,int x2,int y2,int x3,int y3);
void clip(int *ntp,int *tp,int XC,int YC,int LX,int LY);
void projection(int *tp,unsigned char *image,int largeur,int hauteur);
void projection_huge(int *tp,unsigned char *image,int largeur,int hauteur);

unsigned char *image=NULL;
unsigned int  largeur,hauteur;
unsigned long taille_image;

static long x1_vl[MAX_VERTICES];
static long y1_vl[MAX_VERTICES];
static long x2_vl[MAX_VERTICES];
static long y2_vl[MAX_VERTICES];
static long x1_v[MAX_VERTICES][8];
static long y1_v[MAX_VERTICES][8];
static long x2_v[MAX_VERTICES][8];
static long y2_v[MAX_VERTICES][8];
static int nb_v[8];
static int nb_vl;

static int zoom=2;

unsigned char laby[LABH][LABW]=
{
	"########",
	"#    # #",
	"# ## # #",
	"#  #   #",
	"## ### #",
	"#    # #",
	"#      #",
	"########"
};


long x;
long y;

unsigned char an;

#define CENTREX (WIDTH/2)
#define CENTREY (HEIGHT/2)
#define DEMILARGEUR ((WIDTH/2)-32)
#define DEMIHAUTEUR ((HEIGHT/2)-32)

#define XMAX (CENTREX+DEMILARGEUR+1)
#define YMAX (CENTREY+DEMIHAUTEUR+1)
#define XMIN (CENTREX-DEMILARGEUR)
#define YMIN (CENTREY-DEMIHAUTEUR)


#ifdef WING_DIRECT_ACCESS
extern long Orientation;
extern unsigned char *ptr_work_screen;
extern unsigned char *ptr_view_screen;
#endif

/******************************************************************/


#undef sgn(x)
#undef abs(x)
#define sgn(x) ((x==0)?(0):((x<0)?(-1):(1)))
#define abs(x) ((x<0)?(-(x)):(x))






void projection(int *tp,unsigned char *image,int largeur,int hauteur)
{
	register int x,y;
	register long ab,ah,yb,yh;
	register long stepx,stepy,yt,xt;
	register unsigned char *p;
	register unsigned char *deb;
	register int ymin,ymax,xmin,xmax;
#ifdef WING_DIRECT_ACCESS
	register unsigned char *d;
	register long recal;
#endif

	int x1,x2,yb1,yb2,yh1,yh2;
	int x1p,y1p,x2p,y2p,x3p,y3p;
	long gamma,gamma2;
	int vlargeur;

	if (tp[0]==tp[2])
		return;

	/* x1<x2 always! */

	x1=tp[2];
	yb1=tp[3];
	x2=tp[0];
	yb2=tp[1];
	yh1=tp[5];
	yh2=tp[7];
	x2p=tp[8];
	y2p=tp[9];
	x1p=tp[10];
	y1p=tp[11];
	x3p=tp[12];
	y3p=tp[13];

	if ((y3p==y1p)&&(x3p==x1p))
		vlargeur=largeur;
	else
	{
		if (y1p==K)
		{
			if ((y2p-y3p)>abs(x3p-x2p))
				vlargeur=(((long)largeur)*(y1p-y2p))/(y3p-y2p);
			else       
				vlargeur=(((long)largeur)*(x1p-x2p))/(x3p-x2p);
			image+=largeur-vlargeur;
		}
		else
		{
			if ((y1p-y3p)>abs(x3p-x1p))
				vlargeur=(((long)largeur)*(y2p-y1p))/(y3p-y1p);
			else       
				vlargeur=(((long)largeur)*(x2p-x1p))/(x3p-x1p);
		}
	}


	if (y1p!=y2p)
	{
		gamma=(256L*FACT*(x2p-x1p))/(y2p-y1p);
		gamma2=(((long)-y1p)*(vlargeur)*256L)/(y2p-y1p);
	}
	else
		stepx=(((long)vlargeur)<<16L)/(x2-x1+1);

	deb=image;

	ab=((long)(yb2-yb1)<<16L)/(x2-x1);
	ah=((long)(yh2-yh1)<<16L)/(x2-x1);

	yb=32768L+((long)yb1<<16L);
	yh=32768L+((long)yh1<<16L);

#ifdef WING_DIRECT_ACCESS
	if (Orientation== -1)
		recal=WIDTH;
	else
		recal=-WIDTH;
#endif

	xmin=x1;
	if (xmin<XMIN)
	{
		yb+=ab*(XMIN-xmin);
		yh+=ah*(XMIN-xmin);
		if (y1p==y2p)
			xt=stepx*(XMIN-xmin);
		xmin=XMIN;
	}
	else
		xt=0;
	xmax=x2;
	if (xmax>XMAX)
		xmax=XMAX;
	for(x=xmin;x<xmax;x++,yb+=ab,yh+=ah)
	{
		if ((x>=XMIN)&&(x<=XMAX))
		{
			if (y1p!=y2p)
			{
				xt=(unsigned int)((gamma2*(x-x1))/((((long)(x-CENTREX))<<8L)-gamma));
				deb=image+xt;
			}
			else
			{
				deb=image+(xt>>16L);
				xt+=stepx;
			}


			stepy=(((long)hauteur)<<16L)/(((yb-yh)>>16L)+1);
			ymax=(int)(yb>>16);
			if (ymax>YMAX)
				ymax=YMAX;
			ymin=(int)(yh>>16);
			if (ymin<YMIN)
			{
				yt=stepy*(YMIN-ymin);
				ymin=YMIN;
			}
			else
				yt=0;

#ifdef WING_DIRECT_ACCESS
			if (Orientation== -1)
				d=ptr_work_screen+((long)WIDTH)*ymin+x;
			else
				d=ptr_work_screen+((long)WIDTH)*(HEIGHT-1-ymin)+x;
#endif

			for(y=ymin;y<ymax;y++,yt+=stepy)
			{
				p=deb+(yt>>16L)*((long)largeur);
#ifdef WING_DIRECT_ACCESS
				*d=*p;
				d+=recal;
#else
				plot(x,y,*p);
#endif
			}
		}
	}
}





void projection_huge(int *tp,unsigned char *image,int largeur,int hauteur)
{
	register int x,y;
	register long ab,ah,yb,yh;
	register long stepx,stepy,yt,xt;
	register unsigned char huge *p;
	register unsigned char *deb;
	register int ymin,ymax,xmin,xmax;  
#ifdef WING_DIRECT_ACCESS
	register unsigned char *d;
	register long recal;
#endif

	int x1,x2,yb1,yb2,yh1,yh2;
	int x1p,y1p,x2p,y2p,x3p,y3p;
	long gamma,gamma2;
	int vlargeur;

	if (tp[0]==tp[2])
		return;

	/* x1<x2 always! */

	x1=tp[2];
	yb1=tp[3];
	x2=tp[0];
	yb2=tp[1];
	yh1=tp[5];
	yh2=tp[7];
	x2p=tp[8];
	y2p=tp[9];
	x1p=tp[10];
	y1p=tp[11];
	x3p=tp[12];
	y3p=tp[13];

	if ((y3p==y1p)&&(x3p==x1p))
		vlargeur=largeur;
	else
	{
		if (y1p==K)
		{
			if ((y2p-y3p)>abs(x3p-x2p))
				vlargeur=(((long)largeur)*(y1p-y2p))/(y3p-y2p);
			else       
				vlargeur=(((long)largeur)*(x1p-x2p))/(x3p-x2p);
			image+=largeur-vlargeur;
		}
		else
		{
			if ((y1p-y3p)>abs(x3p-x1p))
				vlargeur=(((long)largeur)*(y2p-y1p))/(y3p-y1p);
			else       
				vlargeur=(((long)largeur)*(x2p-x1p))/(x3p-x1p);
		}
	}


	if (y1p!=y2p)
	{
		gamma=(256L*FACT*(x2p-x1p))/(y2p-y1p);
		gamma2=(((long)-y1p)*(vlargeur)*256L)/(y2p-y1p);
	}
	else
		stepx=(((long)vlargeur)<<16L)/(x2-x1+1);

	deb=image;

	ab=((long)(yb2-yb1)<<16L)/(x2-x1);
	ah=((long)(yh2-yh1)<<16L)/(x2-x1);

	yb=32768L+((long)yb1<<16L);
	yh=32768L+((long)yh1<<16L);

#ifdef WING_DIRECT_ACCESS
	if (Orientation== -1)
		recal=WIDTH;
	else
		recal=-WIDTH;
#endif
	xmin=x1;
	if (xmin<XMIN)
	{
		yb+=ab*(XMIN-xmin);
		yh+=ah*(XMIN-xmin);
		if (y1p==y2p)
			xt=stepx*(XMIN-xmin);
		xmin=XMIN;
	}
	else
		xt=0;
	xmax=x2;
	if (xmax>XMAX)
		xmax=XMAX;
	for(x=xmin;x<xmax;x++,yb+=ab,yh+=ah)
	{
		if ((x>=XMIN)&&(x<=XMAX))
		{
			if (y1p!=y2p)
			{
				xt=(unsigned int)((gamma2*(x-x1))/((((long)(x-CENTREX))<<8L)-gamma));
				deb=image+xt;
			}
			else
			{
				deb=image+(xt>>16L);
				xt+=stepx;
			}


			stepy=(((long)hauteur)<<16L)/(((yb-yh)>>16L)+1);
			ymax=(int)(yb>>16);
			if (ymax>YMAX)
				ymax=YMAX;
			ymin=(int)(yh>>16);
			if (ymin<YMIN)
			{
				yt=stepy*(YMIN-ymin);
				ymin=YMIN;
			}
			else
				yt=0;
#ifdef WING_DIRECT_ACCESS
			if (Orientation== -1)
				d=ptr_work_screen+((long)WIDTH)*ymin+x;
			else
				d=ptr_work_screen+((long)WIDTH)*(HEIGHT-1-ymin)+x;
#endif
			for(y=ymin;y<ymax;y++,yt+=stepy)
			{
				p=((unsigned char huge *)deb)+(yt>>16L)*((long)largeur);
#ifdef WING_DIRECT_ACCESS
				*d=*p;
				d+=recal;
#else
				plot(x,y,*p);
#endif
			}
		}
	}
}




void draw_wall(int x1,int y1,int x2,int y2,int x3,int y3)
{
	int xp1,xp2,yp1,yp2;
	int np;
	int tp[20];

	xp1=FACT*x1/(-y1);
	yp1=FACT*WALL_HEIGHT/(-y1);

	xp2=FACT*x2/(-y2);
	yp2=FACT*WALL_HEIGHT/(-y2);

	{

		tp[0]=xp1+CENTREX;
		tp[1]=yp1+CENTREY;
		tp[2]=xp2+CENTREX;
		tp[3]=yp2+CENTREY;
		tp[4]=xp2+CENTREX;
		tp[5]=-yp2+CENTREY;
		tp[6]=xp1+CENTREX;
		tp[7]=-yp1+CENTREY;
		tp[8]=x1;
		tp[9]=-y1;
		tp[10]=x2;
		tp[11]=-y2;
		tp[12]=x3;
		tp[13]=-y3;

		if (taille_image>65536L)
			projection_huge(tp,image,largeur,hauteur);
		else
			projection(tp,image,largeur,hauteur);

	}
}





void draw_empty_wall(int x1,int y1,int x2,int y2)
{
	int xp1,xp2,yp1,yp2;
	int np;
	int tp[20];

	xp1=FACT*x1/(-y1);
	yp1=FACT*WALL_HEIGHT/(-y1);
			
	xp2=FACT*x2/(-y2);
	yp2=FACT*WALL_HEIGHT/(-y2);

	tp[0]=xp1;
	tp[1]=yp1;
	tp[2]=xp2;
	tp[3]=yp2;
	tp[4]=xp2;
	tp[5]=-yp2;
	tp[6]=xp1;
	tp[7]=-yp1;
	tp[8]=xp1;
	tp[9]=yp1;

	np=10;

	clip(&np,tp,CENTREX,CENTREY,DEMILARGEUR,DEMIHAUTEUR);
	
	polyfill(np>>1,tp,WALL);
	polyline(np>>1,tp,WHITE);
}



void draw_light(int x1,int y1,int x2,int y2)
{
	int i;
	int xp1,xp2,yp1,yp2;
	int np;
	int tp[20];

	xp1=FACT*x1/(-y1);
	yp1=FACT*WALL_HEIGHT/(-y1);
			
	xp2=FACT*x2/(-y2);
	yp2=FACT*WALL_HEIGHT/(-y2);

	tp[0]=xp1;
	tp[1]=yp1;
	tp[2]=xp2;
	tp[3]=yp2;
	tp[4]=xp1;
	tp[5]=yp1;

	np=6;

	clip(&np,tp,CENTREX,CENTREY,DEMILARGEUR,DEMIHAUTEUR);
	
	polyline(np>>1,tp,WHITE);

	for(i=0;i<np;i++)
		tp[1+(i<<1)]=2*CENTREY-tp[1+(i<<1)];

	polyline(np>>1,tp,WHITE);

}






void draw3D(void)
{
	int i;
	long x1,y1,x2,y2,x3,y3;
	long ox,oy;
	long xt;
	int nb;
	unsigned int d;

	pbox(XMIN,YMIN,2*DEMILARGEUR+1,2*DEMIHAUTEUR+1,0);
	setcolor(WHITE);

	ox=(x>>SCALE);
	oy=(y>>SCALE);


	
	nb=nb_vl;
	for(i=0;i<nb;i++)
	{
		x1=(x1_vl[i]-ox);
		y1=(y1_vl[i]-oy);
		x2=(x2_vl[i]-ox);
		y2=(y2_vl[i]-oy);
		
		xt=((((long)x1)*sn[an])>>14L)+((((long)y1)*cs[an])>>14L);
		y1=((((long)y1)*sn[an])>>14L)-((((long)x1)*cs[an])>>14L);
		x1=xt;
		xt=((((long)x2)*sn[an])>>14L)+((((long)y2)*cs[an])>>14L);
		y2=((((long)y2)*sn[an])>>14L)-((((long)x2)*cs[an])>>14L);
		x2=xt;

		
		if ((y1<-K)&&(y2<-K))
		{
			draw_light(x1,y1,x2,y2);
		}
		else
			if (y1<-K)
			{
				x3=(((long)(-K-y1))*(x2-x1))/(y2-y1)+x1;
				y3=-K;
				draw_light(x1,y1,x3,y3);
			}	
			else
				if (y2<-K)
				{
					x3=(((long)(-K-y2))*(x1-x2))/(y1-y2)+x2;
					y3=-K;
					draw_light(x3,y3,x2,y2);
				}

	}


			
	d=((unsigned int)an>>5)&7;
	nb=nb_v[d];
		
	for(i=0;i<nb;i++)
	{
		x1=x1_v[i][d]-ox;
		y1=y1_v[i][d]-oy;
		x2=x2_v[i][d]-ox;
		y2=y2_v[i][d]-oy;
		
		xt=((((long)x1)*sn[an])>>14L)+((((long)y1)*cs[an])>>14L);
		y1=((((long)y1)*sn[an])>>14L)-((((long)x1)*cs[an])>>14L);
		x1=xt;
		xt=((((long)x2)*sn[an])>>14L)+((((long)y2)*cs[an])>>14L);
		y2=((((long)y2)*sn[an])>>14L)-((((long)x2)*cs[an])>>14L);
		x2=xt;

		if ((y1<-K)&&(y2<-K))
		{
			if (((long)x1)*(y2-y1)-((long)y1)*(x2-x1)<0)
#ifndef NO_PROJECTION
				draw_wall(x1,y1,x2,y2,x2,y2);
#else
				draw_empty_wall(x1,y1,x2,y2);
#endif
		}
		else
			if (y1<-K)
			{
				x3=(((long)(-K-y1))*(x2-x1))/(y2-y1)+x1;
				y3=-K;
				if (((long)x1)*(y3-y1)-((long)y1)*(x3-x1)<0)
#ifndef NO_PROJECTION
					draw_wall(x1,y1,x3,y3,x2,y2);
#else
					draw_empty_wall(x1,y1,x3,y3);
#endif
			}	
			else
				if (y2<-K)
				{
					x3=(((long)(-K-y2))*(x1-x2))/(y1-y2)+x2;
					y3=-K;
					if (((long)x3)*(y2-y3)-((long)y3)*(x2-x3)<0)
#ifndef NO_PROJECTION
						draw_wall(x3,y3,x2,y2,x1,y1);
#else
						draw_empty_wall(x3,y3,x2,y2);
#endif
				}

	}
	
	swap();
}






void draw2D(void)
{
	int i,j;
	long x1,y1,x2,y2;
	long ox,oy;
	long xt;
	int nb;

	cls();
	setcolor(WHITE);


	ox=(x>>SCALE);
	oy=(y>>SCALE);
	draw_line(0,0,-3,3);
	draw_line(0,0,3,3);

	

	nb=nb_v[0];
	for(i=0;i<nb;i++)
	{
		x1=(x1_v[i][0]-ox)>>zoom;
		y1=(y1_v[i][0]-oy)>>zoom;
		x2=(x2_v[i][0]-ox)>>zoom;
		y2=(y2_v[i][0]-oy)>>zoom;
		
		xt=((((long)x1)*sn[an])>>14L)+((((long)y1)*cs[an])>>14L);
		y1=((((long)y1)*sn[an])>>14L)-((((long)x1)*cs[an])>>14L);
		x1=xt;
		xt=((((long)x2)*sn[an])>>14L)+((((long)y2)*cs[an])>>14L);
		y2=((((long)y2)*sn[an])>>14L)-((((long)x2)*cs[an])>>14L);
		x2=xt;

		draw_line(x1,y1,x2,y2);
	}

	swap();
}



void draw_line(int xp1,int yp1,int xp2,int yp2)
{
	int np;
	int tp[20];
		
	tp[0]=xp1;
	tp[1]=yp1;
	tp[2]=xp2;
	tp[3]=yp2;
	tp[4]=xp1;
	tp[5]=yp1;

	np=6;

	clip(&np,tp,CENTREX,CENTREY,DEMILARGEUR,DEMIHAUTEUR);
	
	polyline(np>>1,tp,-1);
}




void init_vars(void)
{
	int i;

        image=NULL;

	for(i=0;i<8;i++)
		nb_v[i]=0;
	nb_vl=0;

        zoom=2;
	
	x=(WALL_WIDTH+WALL_WIDTH/2)<<SCALE;
	y=(WALL_WIDTH+WALL_WIDTH/2)<<SCALE;
	an=64; /* 90 degres */
}


void add_vertice(int d,int x1,int y1,int x2,int y2)
{
	long w;

	if (nb_v[d]<MAX_VERTICES)
	{
		x1_v[nb_v[d]][d]=x1*WALL_WIDTH;
		y1_v[nb_v[d]][d]=y1*WALL_WIDTH;
		x2_v[nb_v[d]][d]=x2*WALL_WIDTH;
		y2_v[nb_v[d]][d]=y2*WALL_WIDTH;
		nb_v[d]++;
	}	

	if ((!d)&&(nb_vl<MAX_VERTICES))
	{
		x1_vl[nb_vl]=x1*WALL_WIDTH;
		y1_vl[nb_vl]=y1*WALL_WIDTH;
		x2_vl[nb_vl]=x2*WALL_WIDTH;
		y2_vl[nb_vl]=y2*WALL_WIDTH;

		
		w=(x2_vl[nb_vl]-x1_vl[nb_vl])/3;
		x1_vl[nb_vl]+=w;
		x2_vl[nb_vl]-=w;

		w=(y2_vl[nb_vl]-y1_vl[nb_vl])/3;
		y1_vl[nb_vl]+=w;
		y2_vl[nb_vl]-=w;

		x1_vl[nb_vl]+=(y2_vl[nb_vl]-y1_vl[nb_vl])/4;
		x2_vl[nb_vl]+=(y2_vl[nb_vl]-y1_vl[nb_vl])/4;
		y1_vl[nb_vl]-=(x2_vl[nb_vl]-x1_vl[nb_vl])/4;
		y2_vl[nb_vl]-=(x2_vl[nb_vl]-x1_vl[nb_vl])/4;



		nb_vl++;
	}
}

	
void add_vertices(void)
{
	int i,j,d;

	d=0;
	for(j=LABW-2;j>=1;j--)
		for(i=1;i<LABH-1;i++)
		{
			if (laby[i][j]==' ')
			{
				if (laby[i-1][j]!=' ')
					add_vertice(d,j+1,i,j,i);
				if (laby[i+1][j]!=' ')
					add_vertice(d,j,i+1,j+1,i+1);
				if (laby[i][j-1]!=' ')
					add_vertice(d,j,i,j,i+1);
				if (laby[i][j+1]!=' ')
					add_vertice(d,j+1,i+1,j+1,i);
			}
		}
		
	d=1;
	for(i=1;i<LABH-1;i++)
		for(j=LABW-2;j>=1;j--)
		{
			if (laby[i][j]==' ')
			{
				if (laby[i-1][j]!=' ')
					add_vertice(d,j+1,i,j,i);
				if (laby[i+1][j]!=' ')
					add_vertice(d,j,i+1,j+1,i+1);
				if (laby[i][j-1]!=' ')
					add_vertice(d,j,i,j,i+1);
				if (laby[i][j+1]!=' ')
					add_vertice(d,j+1,i+1,j+1,i);
			}
		}
	
	d=2;
	for(i=1;i<LABH-1;i++)
		for(j=1;j<LABW-1;j++)
		{
			if (laby[i][j]==' ')
			{
				if (laby[i-1][j]!=' ')
					add_vertice(d,j+1,i,j,i);
				if (laby[i+1][j]!=' ')
					add_vertice(d,j,i+1,j+1,i+1);
				if (laby[i][j-1]!=' ')
					add_vertice(d,j,i,j,i+1);
				if (laby[i][j+1]!=' ')
					add_vertice(d,j+1,i+1,j+1,i);
			}
		}
		
	d=3;
	for(j=1;j<LABW-1;j++)
		for(i=1;i<LABH-1;i++)
		{
			if (laby[i][j]==' ')
			{
				if (laby[i-1][j]!=' ')
					add_vertice(d,j+1,i,j,i);
				if (laby[i+1][j]!=' ')
					add_vertice(d,j,i+1,j+1,i+1);
				if (laby[i][j-1]!=' ')
					add_vertice(d,j,i,j,i+1);
				if (laby[i][j+1]!=' ')
					add_vertice(d,j+1,i+1,j+1,i);
			}
		}
	
	d=4;
	for(j=1;j<LABW-1;j++)
		for(i=LABH-2;i>=1;i--)
		{
			if (laby[i][j]==' ')
			{
				if (laby[i-1][j]!=' ')
					add_vertice(d,j+1,i,j,i);
				if (laby[i+1][j]!=' ')
					add_vertice(d,j,i+1,j+1,i+1);
				if (laby[i][j-1]!=' ')
					add_vertice(d,j,i,j,i+1);
				if (laby[i][j+1]!=' ')
					add_vertice(d,j+1,i+1,j+1,i);
			}
		}
		
	d=5;
	for(i=LABH-2;i>=1;i--)
		for(j=1;j<LABW-1;j++)
		{
			if (laby[i][j]==' ')
			{
				if (laby[i-1][j]!=' ')
					add_vertice(d,j+1,i,j,i);
				if (laby[i+1][j]!=' ')
					add_vertice(d,j,i+1,j+1,i+1);
				if (laby[i][j-1]!=' ')
					add_vertice(d,j,i,j,i+1);
				if (laby[i][j+1]!=' ')
					add_vertice(d,j+1,i+1,j+1,i);
			}
		}
	
	d=6;
	for(i=LABH-2;i>=1;i--)
		for(j=LABW-2;j>=1;j--)
		{
			if (laby[i][j]==' ')
			{
				if (laby[i-1][j]!=' ')
					add_vertice(d,j+1,i,j,i);
				if (laby[i+1][j]!=' ')
					add_vertice(d,j,i+1,j+1,i+1);
				if (laby[i][j-1]!=' ')
					add_vertice(d,j,i,j,i+1);
				if (laby[i][j+1]!=' ')
					add_vertice(d,j+1,i+1,j+1,i);
			}
		}
		
	d=7;
	for(j=LABW-2;j>=1;j--)
		for(i=LABH-2;i>=1;i--)
		{
			if (laby[i][j]==' ')
			{
				if (laby[i-1][j]!=' ')
					add_vertice(d,j+1,i,j,i);
				if (laby[i+1][j]!=' ')
					add_vertice(d,j,i+1,j+1,i+1);
				if (laby[i][j-1]!=' ')
					add_vertice(d,j,i,j,i+1);
				if (laby[i][j+1]!=' ')
					add_vertice(d,j+1,i+1,j+1,i);
			}
		}
	
}




 

void affichage_palette(unsigned char rgbpalette[3*256])
{
	int i;
	unsigned int pal[3*256];
	
	for(i=0;i<3*256;i++)
		pal[i]=rgbpalette[i]*257;

#ifdef EXTENSION
	setbigpalette(0,256,pal);
#endif
}


		 

void free_all(void)
{
	memfree((void **)&image);
}


 

void clip(int *ntp,int *tp,int XC,int YC,int LX,int LY)
{	
	int tp2[80];
	int ntp2=0;
	int n,i;
	long xe,ye,xo,yo;
	
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
			ntp2++;
			tp2[ntp2++]=LY;
		}
	
		if (ye<=LY)
		{
			tp2[ntp2]=xe;
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


void playdemo(void)
{
	int dx,dy;
	long vx,vy;
	int xl,yl;

	presentation();


	add_vertices();	

	doublescreen();
	cls();
	swap();
	cls();

	do
	{
		dx=(mousex-WIDTH/2)/64;
		dy=(mousey-HEIGHT/2);
	
		/* rotation */
		an-=ROTATION_SPEED*dx;
		
		/* deplacement */		
		vx=-SPEED*((((long)dy)*cs[an])>>14L);
		vy=SPEED*((((long)dy)*sn[an])>>14L);
		     
		xl=((x)>>SCALE)/WALL_WIDTH;
		yl=((y+vy+sgn(vy)*MARGE)>>SCALE)/WALL_WIDTH;		
		while((vy)&&(laby[yl][xl]!=' '))
		{
			vy/=2;
			xl=((x)>>SCALE)/WALL_WIDTH;
			yl=((y+vy+sgn(vy)*MARGE)>>SCALE)/WALL_WIDTH;
		}

		   
		xl=((x+vx+sgn(vx)*MARGE)>>SCALE)/WALL_WIDTH;
		yl=((y)>>SCALE)/WALL_WIDTH;		
		while((vx)&&(laby[yl][xl]!=' '))
		{
			vx/=2;
			xl=((x+vx+sgn(vx)*MARGE)>>SCALE)/WALL_WIDTH;
			yl=((y)>>SCALE)/WALL_WIDTH;
		}
		    
		xl=((x+vx)>>SCALE)/WALL_WIDTH;
		yl=((y+vy)>>SCALE)/WALL_WIDTH;
		if (laby[yl][xl]==' ')
		{
			x+=vx;
			y+=vy;
		}

		if (mousek&1)
			draw2D();
		else
			draw3D();

		if (kbhit())
			zoom=(getch()-'0')&7;
	}
	while(getmouse()!=2);
}



int main(int argc,char *argv[])
{
	int fd;
	unsigned char hb,lb;
	unsigned char pal256[256*3];
	char nom[80];

	if (initsystem())
	{
		init_vars();

		hide();
		simplescreen();

		setcolor(WHITE);

#ifndef NO_PROJECTION
		if (argc!=2)
		{
			argc=2;
			strcpy(nom,"image2.mur");
			if (!bexist(nom))
				strcpy(nom,"image.mur");
			if (!bexist(nom))
					argc=1;
		}
		else
			strcpy(nom,argv[1]);

		if (argc==2)
		{
			if (bexist(nom))
			{

				bload(nom,&hb,0,1);
				bload(nom,&lb,1,1);

				largeur=hb*256+lb;

				bload(nom,&hb,2,1);
				bload(nom,&lb,3,1);

				hauteur=hb*256+lb;   

				bload(nom,pal256,4,3*256);

				image=memalloc(((long)largeur)*hauteur);

				if (image)
				{
					bload(nom,image,3*256+4,((long)largeur)*hauteur);

					taille_image=((long)largeur)*hauteur;

					affichage_palette(pal256);
					doublescreen();
					show();
					playdemo();

					memfree((void**)&image);
				}
				else
				{
					print("out of memory");
                                        refresh();
					getch();
				}
			}
			else
			{
				print("can't find file (?.mur)");
                                refresh();
				getch();
			}
		}
		else
		{
			print("usage: wingdemo [?.mur]");
                        refresh();
			getch();
		}
		
#else
		doublescreen();
		show();
		playdemo();
#endif
		killsystem();
	}
	
	return 0;
}


void presentation(void)
{
	cls();

	setcolor(WHITE);

	afftext(160-8*4,30,"wingdemo");
	afftext(160-2*4,40,"by");
	afftext(160-18*4,50,"guillaume lamonoca");
	afftext(160-19*4,80,"(created with glcb!)");

	dbox(160-30,100,30,30,-1);
	dbox(160,100,30,30,-1);
	dbox(160-30,130,60,60,-1);

	afftext(160-27,111,"map");
	afftext(160+3,111,"end");

	swap();

	empty();
	confirm();
}
