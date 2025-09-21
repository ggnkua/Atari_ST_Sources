/* Konvertiert Bilddaten in DIF-File, von J”rg Ramb */

#include	<stdio.h>
#include	<stdlib.h>
#include	<aes.h>
#include	<vdi.h>
#include	<tos.h>
#include	<string.h>
#include	<homemade.h>

#define	hide_mouse()	v_hide_c(vdihandle)
#define	show_mouse()	v_show_c(vdihandle,1)

int vdihandle;
int	x,y,b,h;

char	save[32000L];

void read_pic(void)
{
	FILE *fil;
	static char name[16]="",pfad[64]="X:\*.PIC",fn[80]="";
	long xb;

	pfad[0]=Dgetdrv()+'A';
	xb=get_in_file(pfad,name,fn);
	if(xb)	return;

	hide_mouse();
	fil=fopen(fn,"rb");
	if(!fil)	return;
	fread(Physbase(),32000L,1L,fil);
	memcpy(save,Physbase(),32000L);
	fclose(fil);
	show_mouse();
}

void drawaxis(int x,int y)
{
	int pxyarray[4];
	pxyarray[0]=0;		pxyarray[1]=y;
	pxyarray[2]=639;	pxyarray[3]=y;
	vs_clip(vdihandle,0,pxyarray);
	vswr_mode(vdihandle,MD_XOR);
	v_pline(vdihandle,2,pxyarray);
	pxyarray[0]=x;		pxyarray[1]=0;
	pxyarray[2]=x;		pxyarray[3]=399;
	v_pline(vdihandle,2,pxyarray);
}

void get_range(void)
{
	int	ms,mx,my,mx2,my2;
	hide_mouse();
	memcpy(Physbase(),save,32000L);
	do	vq_mouse(vdihandle,&ms,&mx,&my);	while(ms!=0);
	drawaxis(mx,my);
	do	{
		drawaxis(mx,my);
		vq_mouse(vdihandle,&ms,&mx,&my);
		drawaxis(mx,my);
	}	while(ms==0);
	do	vq_mouse(vdihandle,&ms,&mx2,&my2);	while(ms!=0);
	drawaxis(mx2,my2);
	do	{
		drawaxis(mx2,my2);
		vq_mouse(vdihandle,&ms,&mx2,&my2);
		if((mx2-mx)>100)	mx2=mx+100;
		if((my2-my)>100)	my2=my+100;
		drawaxis(mx2,my2);
	}	while(ms==0 || mx2<=mx || my2<=my);
	drawaxis(mx2,my2);
	show_mouse();
	x=mx;	y=my;	b=mx2-mx;	h=my2-my;
}

void write_dif(void)
{
	FILE *fil;
	static char name[16]="",pfad[64]="X:\*.DIF",fn[80]="";
	int xx,yy;

	pfad[0]=Dgetdrv()+'A';

	xx=get_in_file(pfad,name,fn);
	if(xx)	return;

	fil=fopen(fn,"w");
	if(!fil)	return;

	hide_mouse();
	memcpy(Physbase(),save,32000L);
	fprintf(fil,"TABLE\n0,1\n\"PIC2DIF\"\n"
		"TUPLES\n0,%d\n\"\"\nVECTORS\n0,%d\n"
		"\"\"\nDATA\n0,0\n\"\"\n-1,0\n",
		h,b);
	for(yy=h-1;yy>=0;yy--)	{
		fprintf(fil,"BOT\n");
		for(xx=0;xx<b;xx++)	{
			int pel,index;
			v_get_pixel(vdihandle,x+xx,y+yy,&pel,&index );
			fprintf(fil,"0,%d\nV\n",pel);
		}
		fprintf(fil,"-1,0\n");
	}
	fprintf(fil,"EOD\n");
	fclose(fil);
	show_mouse();
}

void main(void)
{
	if(Getrez()!=2)	return;
	if(appl_init()>=0)	{
		int		dummy;
		vdihandle=graf_handle(&dummy,&dummy,&dummy,&dummy);

		printf("\033E"
"DIF-Generator von J”rg Ramb - Bestandteil von DDD-Plot - Public Domain!\n\n"
"Wandelt einen Grafikausschnitt (Screen-Format) in ein DIF-File um:");

		read_pic();
		get_range();
		write_dif();
		appl_exit();
	}
}
