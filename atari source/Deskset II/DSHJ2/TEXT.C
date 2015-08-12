#include "osbind.h"

typedef	struct	mfdb
	{
	long	data;
	int	width;
	int	height;
	int	wwidth;
	int	format;
	int	planes;
	int	res1;
	int	res2;
	int	res3;
	}MFDB;

extern int ptsin[];
extern int print_flag;
extern int mhandle;
extern int phandle;

int 	cellw;
int 	thandle;
int 	actualht;
int	rect1[4];
int	rwidth;
int	twidth;
int 	rpoint;
int 	rheight;
unsigned char	tempbuff[100];
int 	dummy;
int 	i;
unsigned char	ch;
int 	numfnt;
int     pnumfnt;
int     mnumfnt;

init_text(thandle)
int thandle;
{
   numfnt=vst_load_fonts(thandle,0);
   if(numfnt)
   {
     vst_alignment(thandle,0,5,&dummy,&dummy);
     vst_font(thandle,14);
     if(thandle == mhandle)
     		mnumfnt = numfnt;
     if(thandle == phandle)
		pnumfnt = numfnt;     
   }
}
