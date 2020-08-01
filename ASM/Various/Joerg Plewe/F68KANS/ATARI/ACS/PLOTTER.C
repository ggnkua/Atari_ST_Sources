
#include 	<stdlib.h>
#include 	<string.h> 
#include 	"..\loader.h"
#include    <acs.h>
#include	<acsplus.h>


extern Awindow *plotter;


void cdecl _w_arc();
void cdecl _w_bar();
void cdecl _w_circle();
void cdecl _w_clr();
void cdecl _w_contourfill();
void cdecl _w_draw();
void cdecl _w_ellarc();
void cdecl _w_ellipse();
void cdecl _w_ellpie();
void cdecl _w_fillarea();
void cdecl _w_gtext();
void cdecl _w_inv();
void cdecl _w_justified();
void cdecl _w_pieslice();
void cdecl _w_pline();
void cdecl _w_pmarker();
void cdecl _w_rbox();
void cdecl _w_rfbox();
void cdecl _w_update();
void cdecl _w_recfl();
void cdecl _w_plotsize();
void *cdecl _w_getMFDB();


SI_funcarr SI_PLOT_fa[] = {
	_w_arc,
	_w_bar,
	_w_circle,
	_w_clr,
	_w_contourfill,
	_w_draw,
	_w_ellarc,
	_w_ellipse,
	_w_ellpie,
	_w_fillarea,
	_w_gtext,
	_w_inv,
	_w_justified,
	_w_pieslice,
	_w_pline,
	_w_pmarker,
	_w_rbox,
	_w_rfbox,
	_w_update,
	_w_recfl,
	_w_plotsize,
	_w_getMFDB
	};


void cdecl _w_arc(x,y,rad,begang,endang)
long x,y,rad,begang,endang;
{
	w_arc(plotter, (INT16)x, (INT16)y, (INT16) rad, 
			(INT16)begang, (INT16)endang);
}


void cdecl _w_bar(x1,y1,x2,y2)
long x1,y1,x2,y2;
{
INT16 pxy[4];

	pxy[0] = (INT16)x1;
	pxy[1] = (INT16)y1;
	pxy[2] = (INT16)x2;
	pxy[3] = (INT16)y2;
	w_bar(plotter, pxy);
}


void cdecl _w_circle(x,y,rad)
long x,y,rad;
{ w_circle(plotter, (INT16)x, (INT16)y, (INT16) rad); }

void cdecl _w_clr()
{ w_clr(plotter); }


void cdecl _w_contourfill(x,y,index)
long x,y,index;
{ w_contourfill(plotter, (INT16)x, (INT16)y, (INT16)index); }


void cdecl _w_draw(x1,y1,x2,y2)
long x1,y1,x2,y2;
{ w_draw(plotter, (INT16)x1, (INT16)y1, (INT16)x2, (INT16)y2 ); }



void cdecl _w_ellarc(x,y,xrad,yrad,begang,endang)
long x,y,xrad,yrad,begang,endang;
{
	w_ellarc(plotter, (INT16)x, (INT16)y, (INT16)xrad, (INT16)yrad, 
			(INT16)begang, (INT16)endang);
}



void cdecl _w_ellipse(x,y,xrad,yrad)
long x,y,xrad,yrad;
{
	w_ellipse(plotter, (INT16)x, (INT16)y, 
			(INT16)xrad, (INT16)yrad);
}


void cdecl _w_ellpie(x,y,xrad,yrad,begang,endang)
long x,y,xrad,yrad,begang,endang;
{
	w_ellpie(plotter, (INT16)x, (INT16)y, (INT16)xrad, (INT16)yrad, 
			(INT16)begang, (INT16)endang);
}


void cdecl _w_fillarea(count, pxy)
long count;
INT16 *pxy;
{	w_fillarea(plotter, (INT16)count, pxy); }



void cdecl _w_gtext(x,y,string,len)
long x,y;
char *string;
long len;
{ 
char str[256];

	memcpy( str, string, (size_t)len );
	str[len] = '\0'; 


	w_gtext(plotter, (INT16)x, (INT16)y, str ); 
}



void cdecl _w_inv()
{	w_inv(plotter); }



void cdecl _w_justified(x,y,string,len,length,word_space,char_space)
long x,y;
char *string;
long len,length;
long word_space, char_space;
{ 
char str[256];

	memcpy( str, string, (size_t)len );
	str[len] = '\0'; 


	w_justified(plotter, (INT16)x, (INT16)y, str,(INT16)length,
			(INT16)word_space, (INT16)char_space ); 
}




void cdecl _w_pieslice(x,y,rad,begang,endang)
long x,y,rad,begang,endang;
{
	w_pieslice(plotter, (INT16)x, (INT16)y, (INT16)rad,  
			(INT16)begang, (INT16)endang);
}




void cdecl _w_pline(count, pxy)
long count;
INT16 *pxy;
{	w_pline(plotter, (INT16)count, pxy); }




void cdecl _w_pmarker(count, pxy)
long count;
INT16 *pxy;
{	w_pmarker(plotter, (INT16)count, pxy); }




void cdecl _w_rbox(x1,y1,x2,y2)
long x1,y1,x2,y2;
{
INT16 pxy[4];

	pxy[0] = (INT16)x1;
	pxy[1] = (INT16)y1;
	pxy[2] = (INT16)x2;
	pxy[3] = (INT16)y2;
	w_rbox(plotter, pxy);
}



void cdecl _w_rfbox(x1,y1,x2,y2)
long x1,y1,x2,y2;
{
INT16 pxy[4];

	pxy[0] = (INT16)x1;
	pxy[1] = (INT16)y1;
	pxy[2] = (INT16)x2;
	pxy[3] = (INT16)y2;
	w_rfbox(plotter, pxy);
}



void cdecl _w_update()
{ w_update(plotter); }



void cdecl _w_recfl(x1,y1,x2,y2)
long x1,y1,x2,y2;
{
INT16 pxy[4];

	pxy[0] = (INT16)x1;
	pxy[1] = (INT16)y1;
	pxy[2] = (INT16)x2;
	pxy[3] = (INT16)y2;
	wr_recfl(plotter, pxy);
}





void cdecl _w_plotsize(w,h)
long w,h;
{ 
INT16 size[2];

	size[0] = (INT16)w;
	size[1] = (INT16)h;
	plotter->service(plotter, AS_PLOTSIZE, size);
}


void* cdecl _w_getMFDB()
{
	MFDB *mfdb;

	plotter->service(plotter, AS_PLOTMFDB, &mfdb);

	return mfdb;
}
