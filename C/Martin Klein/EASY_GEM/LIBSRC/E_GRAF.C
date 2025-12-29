#include <vdi.h>
#include <easy_gem.h>

extern int handle,work_out[];
int _umr[10];
int _xo,_yo,_hide=0;

void box(int x1,int y1,int x2,int y2)
{
	_umr[0]=_umr[6]=_umr[8]=x1;
	_umr[1]=_umr[3]=_umr[9]=y1;
	_umr[2]=_umr[4]=x2;
	_umr[5]=_umr[7]=y2;
	maus_aus();
	v_pline(handle,5,_umr);
	maus_an();
}

void color(int color)
{
	vsl_color(handle,color);
}

void deffill(int farbe,int art,int muster)
{
	vsf_color(handle,farbe);	
	vsf_interior(handle,art);
	vsf_style(handle,muster);
}

void defline(int thick,int art,int start,int ende)
{
	vsl_width(handle,thick);
	vsl_type(handle,art);
	vsl_ends(handle,start,ende);
}

void defmarker(int color,int typ,int size)
{
	vsm_color(handle,color);
	vsm_type(handle,typ);
	vsm_height(handle,size);
}

void deftext(int color,int attribut,int rotation,int size)
{
	int dum;
	
	vst_color(handle,color);
	vst_effects(handle,attribut);
	vst_rotation(handle,rotation);
	vst_height(handle,size,&dum,&dum,&dum,&dum);
}

void drawto(int x,int y)
{
	_umr[0]=_xo;
	_umr[1]=_yo;
	_umr[2]=_xo=x;
	_umr[3]=_yo=y;
	maus_aus();
	v_pline(handle,2,_umr);
	maus_an();
}

void line(int x1,int y1,int x2,int y2)
{
	_umr[0]=x1;
	_umr[1]=y1;
	_umr[2]=x2;
	_umr[3]=y2;
	maus_aus();
	v_pline(handle,2,_umr);
	maus_an();
}

void maus_an(void)
{
	if(_hide)
		_hide--;
		
	if(_hide == 0)
		graf_mouse(M_ON,0L);
}

void maus_aus(void)
{
	if(_hide == 0)
		graf_mouse(M_OFF,0L);
	_hide++;
}

void pbox(int x1,int y1,int x2,int y2)
{
	_umr[0]=x1;
	_umr[1]=y1;
	_umr[2]=x2;
	_umr[3]=y2;
	maus_aus();
	v_bar(handle,_umr);
	maus_an();
}

void prbox(int x1,int y1,int x2,int y2)
{
	_umr[0]=x1;
	_umr[1]=y1;
	_umr[2]=x2;
	_umr[3]=y2;
	maus_aus();
	v_rfbox(handle,_umr);
	maus_an();
}

void polymarker(int anz,int *pkt)
{
	maus_aus();
	v_pmarker(handle,anz,pkt);
	maus_an();
}

void rbox(int x1,int y1,int x2,int y2)
{
	_umr[0]=x1;
	_umr[1]=y1;
	_umr[2]=x2;
	_umr[3]=y2;
	maus_aus();
	v_rbox(handle,_umr);
	maus_an();
}

void prect(int x1,int y1,int x2,int y2)
{
	_umr[0]=x1;
	_umr[1]=y1;
	_umr[2]=x2;
	_umr[3]=y2;
	maus_aus();
	vr_recfl(handle,_umr);
	maus_an();
}

void setstart(int x,int y)
{
	_xo=x;
	_yo=y;
}

void text(int x,int y,char *txt)
{
	maus_aus();
	v_gtext(handle,x,y,txt);
	maus_an();
}

void text_size(int size)
{
	int dum;
	
	vst_height(handle,size,&dum,&dum,&dum,&dum);
}

void user_fill(int *muster)
{
	vsf_interior(handle,FIS_USER);
	vsf_udpat(handle,muster,work_out[39]-1);
}
