/************* graphics.c ***************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "header.h"
#include "sysdep.h"
#include "funcs.h"
#include "graphics.h"

double x_min=-1,x_max=1,y_min=-1,y_max=1,meshfactor=1,dgrid=0;

int upperc=10,upperr=30,lowerc=1010,lowerr=1010;
int connected[4]={1,1,1,1};
int tconnected[3]={1,0,0};

int linetype=line_solid,linecolor=1,lines=1,holding=0,framecolor=3,
	wirecolor=2,textcolor=2,markertype=marker_cross,scaling=1,
	newframe,twosides=1,triangles=0,linewidth=1,densitycolor=1;

double distance=5,tele=1.5,a_left=0.5,a_up=0.5;

double scrcol (double x)
{	return (upperc+(x-x_min)/(x_max-x_min)*(lowerc-upperc));
}

double scrrow (double y)
{	return (lowerr-(y-y_min)/(y_max-y_min)*(lowerr-upperr));
}

void frame (void)
{	gline(upperc,upperr,upperc,lowerr,framecolor,line_solid,1);
	gline(upperc,lowerr,lowerc,lowerr,framecolor,line_solid,1);
	gline(lowerc,lowerr,lowerc,upperr,framecolor,line_solid,1);
	gline(lowerc,upperr,upperc,upperr,framecolor,line_solid,1);
	newframe=0;
}

void plot_vector (double *x, double *y, int n, int m)
/***** plot_vector
	plots n pairs (x,y).
*****/
{	double c0,r0,c1,r1;
	int i;
	if (n<=0) return;
	if (lines)
	{	c0=scrcol(*x); r0=scrrow(*y);
		if (m) gmarker(c0,r0,linecolor,markertype); 
		if (n==1) gline(c0,r0,c0,r0,linecolor,linetype,linewidth);
		for (i=1; i<n; i++)
		{	x++; y++;
			c1=scrcol(*x); r1=scrrow(*y);
			if (m) gmarker(c1,r1,linecolor,markertype);
			else gline(c0,r0,c1,r1,linecolor,linetype,linewidth);
			c0=c1; r0=r1;
		}
	}
}

void do_plot (header *hdx, header *hdy, int m)
{	int cx,rx,cy,ry,i,ix,iy;
	double *x,*y;
	getmatrix(hdx,&rx,&cx,&x); getmatrix(hdy,&ry,&cy,&y);
	if (cx!=cy || (rx>1 && ry!=rx))
	{	error=22; output("Plot columns must agree!\n");
		return;
	}
	if (scaling)
	{	minmax(x,(LONG)cx*rx,&x_min,&x_max,&ix,&iy);
		minmax(y,(LONG)cy*ry,&y_min,&y_max,&ix,&iy);
	}
	if (x_min==x_max) x_max=x_min+1;
	if (y_min==y_max) y_max=y_min+1;
	graphic_mode();
	if (!holding) { clear_graphics(); }
	if (!holding || newframe) frame();
	for (i=0; i<ry; i++)
	{	plot_vector(mat(x,cx,(i>=rx)?rx-1:i,0),mat(y,cy,i,0),cx,m);
		if (test_key()==27) break;
	}
	gflush();
}

void mplot (header *hd)
{	header *hd1=0,*st=hd,*result;
	double *x;
	hd=getvalue(hd); if (error) return;
	if (hd) /* parameters given */
	{	if (hd->type!=s_matrix && hd->type!=s_real)
		{	error=21;
			output("Plot needs a real vector or matrix!\n");
			return;
		}
		hd1=next_param(st);
		if (hd1) hd1=getvalue(hd1); if (error) return;
		if (hd1->type!=s_matrix && hd1->type!=s_real)
		{	error=11001; output("Wrong arguments for plot!\n");
			return;
		}
	}
	do_plot(hd,hd1,0);
	result=new_matrix(1,4,""); if (error) return;
	x=matrixof(result);
	*x++=x_min; *x++=x_max; *x++=y_min; *x++=y_max;
	moveresult(st,result);
}

void mplotarea (header *hd)
{	header *hd1=0,*st=hd,*result;
	double *x,*y;
	int cx,rx,cy,ry,ix,iy;
	hd=getvalue(hd); if (error) return;
	if (hd) /* parameters given */
	{	if (hd->type!=s_matrix && hd->type!=s_real)
		{	error=21;
			output("Plot needs a real vector or matrix!\n");
			return;
		}
		hd1=next_param(st);
		if (hd1) hd1=getvalue(hd1); if (error) return;
		if (hd1->type!=s_matrix && hd1->type!=s_real)
		{	error=11000; output("Wrong arguments for plotarea!\n"); return;
		}
	}
	getmatrix(hd,&rx,&cx,&x); getmatrix(hd1,&ry,&cy,&y);
	if (cx!=cy || (rx>1 && ry!=rx))
	{	error=22; output("Plot columns must agree!\n");
		return;
	}
	if (scaling)
	{	minmax(x,(LONG)cx*rx,&x_min,&x_max,&ix,&iy);
		minmax(y,(LONG)cy*ry,&y_min,&y_max,&ix,&iy);
		if (x_min==x_max) x_max=x_min+1;
		if (y_min==y_max) y_max=y_min+1;
		scaling=0;
	}
	result=new_matrix(1,4,""); if (error) return;
	x=matrixof(result);
	*x++=x_min; *x++=x_max; *x++=y_min; *x++=y_max;
	moveresult(st,result);
}

void mpixel (header *hd)
{	double x,y;
	hd=new_matrix(1,2,""); if (error) return;
	getpixel(&x,&y);
	x*=(x_max-x_min)/(lowerc-upperc);
	y*=(y_max-y_min)/(lowerr-upperr);
	*(matrixof(hd))=x; *(matrixof(hd)+1)=y;
}

void mmark (header *hd)
{	header *hd1=0,*st=hd,*result;
	double *x;
	hd=getvalue(hd); if (error) return;
	if (hd->type!=s_matrix && hd->type!=s_real)
	{	error=21; output("Mark needs a vector or matrix!\n");
		return;
	}
	hd1=next_param(st);
	if (hd1) hd1=getvalue(hd1); if (error) return;
	if (hd1->type!=s_matrix && hd->type!=s_real)
	{	error=-1; output("Not yet implemented!\n"); return;
	}
	do_plot(hd,hd1,1);
	result=new_matrix(1,4,""); if (error) return;
	x=matrixof(result);
	*x++=x_min; *x++=x_max; *x++=y_min; *x++=y_max;
	moveresult(st,result);
	gflush();
}

void ghold (void)
/**** hold
	toggles holding of the current plot.
****/
{	static oldhold=-1;
	scan_space();
	if (!strncmp(next,"off",3))
	{	oldhold=-1; holding=0; next+=3;
	}
	else if (!strncmp(next,"on",2))
	{	oldhold=-1; holding=1; next+=2;
	}
	else
	{	if (oldhold!=-1) {	holding=oldhold; oldhold=-1; }
		else { oldhold=holding; holding=1; }
	}
	scaling=!holding;
}

void show_graphics (void)
{	int scan;
	graphic_mode(); wait_key(&scan); text_mode();
}

void mmesh (header *hd)
{	double *screen_col,*screen_row;
	LONG col,size;
	double *m,ymin,ymax,xxscale,xyscale,yxscale,yyscale;
	int imin,imax,c,r,i,j;
	double cc[8];
	header *st=hd;
	hd=getvalue(hd); if (error) return;
	if (hd->type!=s_matrix || dimsof(hd)->c<2 || dimsof(hd)->r<2)
	{	output("Illegal parameter for mesh!\n"); error=80; return;
	}
	getmatrix(hd,&r,&c,&m); col=r;
	minmax(m,(LONG)c*r,&ymin,&ymax,&imin,&imax);
	if (ymin==ymax) ymax=ymin+1;
	size=(LONG)c*r*sizeof(double);
	screen_col=(double *)newram;
	screen_row=(double *)(newram+size);
	if (newram+2*size>ramend)
	{	output("Out of memory in mesh!\n");
		error=85; return;
	}

	xxscale=0.6*(lowerc-upperc)/c; xyscale=0.4*(lowerc-upperc)/r;
	yxscale=0.2*(lowerr-upperr)/r; 
	yyscale=0.8*meshfactor*(lowerr-upperr)/(ymax-ymin);
	for (i=0; i<c; i++)
		for (j=0; j<r; j++)
		{	screen_col[col*i+j]=upperc+(xxscale*i+xyscale*j);
			screen_row[col*i+j]=lowerr-(yxscale*j+
				yyscale*(*mat(m,c,j,i)-ymin));
			if (test_key()==escape) { error=1; return; }
		}
	graphic_mode();
	if (!holding) clear_graphics();
	for (i=0; i<c-1; i++)
		for (j=r-2; j>=0; j--)
		{	if (triangles)
			{
			cc[4]=( screen_col[col*i+j] + screen_col[col*(i+1)+j] +
			     screen_col[col*(i+1)+j+1] + screen_col[col*i+j+1])/4;
			cc[5]=( screen_row[col*i+j] + screen_row[col*(i+1)+j] +
			     screen_row[col*(i+1)+j+1] + screen_row[col*i+j+1])/4;
			cc[0]=screen_col[col*(i+1)+j+1]; cc[1]=screen_row[col*(i+1)+j+1];
			cc[2]=screen_col[col*i+j+1]; cc[3]=screen_row[col*i+1+j];
			if (twosides &&
				((cc[2]-cc[0])*(cc[5]-cc[1])-
					(cc[3]-cc[1])*(cc[4]-cc[0]))>0
				)
				gfill(cc,fill_filled,3,tconnected);
			else gfill(cc,fill_blank,3,tconnected);
			cc[0]=screen_col[col*i+j+1]; cc[1]=screen_row[col*i+j+1];
			cc[2]=screen_col[col*i+j]; cc[3]=screen_row[col*i+j];
			if (twosides &&
				((cc[2]-cc[0])*(cc[5]-cc[1])-
					(cc[3]-cc[1])*(cc[4]-cc[0]))>0
				)
				gfill(cc,fill_filled,3,tconnected);
			else gfill(cc,fill_blank,3,tconnected);
			cc[0]=screen_col[col*(i+1)+j]; cc[1]=screen_row[col*(i+1)+j];
			cc[2]=screen_col[col*(i+1)+j+1]; cc[3]=screen_row[col*(i+1)+j+1];
			if (twosides &&
				((cc[2]-cc[0])*(cc[5]-cc[1])-
					(cc[3]-cc[1])*(cc[4]-cc[0]))>0
				)
				gfill(cc,fill_filled,3,tconnected);
			else gfill(cc,fill_blank,3,tconnected);
			cc[0]=screen_col[col*i+j]; cc[1]=screen_row[col*i+j];
			cc[2]=screen_col[col*(i+1)+j]; cc[3]=screen_row[col*(i+1)+j];
			if (twosides &&
				((cc[2]-cc[0])*(cc[5]-cc[1])-
					(cc[3]-cc[1])*(cc[4]-cc[0]))>0
				)
				gfill(cc,fill_filled,3,tconnected);
			else gfill(cc,fill_blank,3,tconnected);
			}
			else
			{
			cc[0]=screen_col[col*i+j]; cc[1]=screen_row[col*i+j];
			cc[2]=screen_col[col*(i+1)+j]; cc[3]=screen_row[col*(i+1)+j];
			cc[4]=screen_col[col*(i+1)+j+1]; cc[5]=screen_row[col*(i+1)+(j+1)];
			cc[6]=screen_col[col*i+j+1]; cc[7]=screen_row[col*i+j+1];
			if (twosides &&
				((cc[2]-cc[0])*(cc[5]-cc[1])-
					(cc[3]-cc[1])*(cc[4]-cc[0]))>0
				)
				gfill(cc,fill_filled,4,connected);
			else gfill(cc,fill_blank,4,connected);
			}
			if (test_key()==escape) { error=1; gflush(); return; }
		}
	hd=new_matrix(1,2,"");
	*matrixof(hd)=ymin; *(matrixof(hd)+1)=ymax;
	moveresult(st,hd);
	gflush();
}

double cos_up,sin_up,cos_left,sin_left;

void turn (double *x, double *y, double cs, double sn)
{	double h;
	h=*x*cs-*y*sn;
	*y=*x*sn+*y*cs;
	*x=h;
}

double project (double x, double y, double z, double *c, double *r)
/***** project
	3D-projection onto the screen.
*****/
{	turn(&y,&x,cos_left,sin_left);
	turn(&y,&z,cos_up,sin_up);
	if (y<-0.9*distance) y=-0.9*distance;
	x/=(y+distance); z/=(y+distance);
	*c=((upperc+lowerc)/2+(lowerc-upperc)/2*x*tele);
	*r=lowerr-((upperr+lowerr)/2+(lowerr-upperr)/2*z*tele);
	return y;
}

void mwire (header *hd)
{	double *screen_col,*screen_row;
	LONG col,size;
	double *mx,*my,*mz;
	int c,r,i,j;
	header *st=hd,*hd1,*hd2;
	hd=getvalue(hd); if (error) return;
	if (hd->type!=s_matrix)
	{	output("Illegal parameter for wire!\n"); error=82; return;
	}
	getmatrix(hd,&r,&c,&mx); col=c;
	hd1=next_param(st); hd2=next_param(hd1);
	hd1=getvalue(hd1); hd2=getvalue(hd2);
	if (error) return;
	if (hd1->type!=s_matrix || hd2->type!=s_matrix ||
		dimsof(hd1)->r!=r || dimsof(hd2)->r!=r ||
		dimsof(hd1)->c!=c || dimsof(hd2)->c!=c)
	{	output("Matrix dimensions for wire must agree!\n");
		error=83; return;
	}
	my=matrixof(hd1); mz=matrixof(hd2);
	size=(LONG)c*r*sizeof(double);
	screen_col=(double *)newram;
	screen_row=(double *)(newram+size);
	if (newram+2*size>ramend)
	{	output("Out of memory in wire!\n");
		error=85; return;
	}
	
	cos_left=cos(a_left); sin_left=sin(a_left);
	cos_up=cos(a_up); sin_up=sin(a_up);
	for (i=0; i<r; i++)
		for (j=0; j<c; j++)
		{	project(*mat(mx,c,i,j),*mat(my,c,i,j),*mat(mz,c,i,j),
				&screen_col[col*i+j],&screen_row[col*i+j]);
			if (test_key()==escape) { error=1; return; }
		}
	graphic_mode();
	if (!holding) clear_graphics();
	if (c>1) for (i=0; i<r; i++)
	{	for (j=0; j<c-1; j++)
		{	gline(screen_col[col*i+j],screen_row[col*i+j],
				screen_col[col*i+j+1],screen_row[col*i+j+1],
				linecolor,line_solid,linewidth);
		}
	}
	if (r>2) for (j=0; j<c; j++)
	{	for (i=0; i<r-1; i++)
		{	gline(screen_col[col*i+j],screen_row[col*i+j],
				screen_col[col*(i+1)+j],screen_row[col*(i+1)+j],
				wirecolor,line_solid,linewidth);
		}
	}
	hd=new_real(0.0,"");
	moveresult(st,hd);
	gflush();
}

void mproject (header *hd)
{	LONG col;
	double *mx,*my,*mz,*screen_col,*screen_row;
	int c,r,i,j;
	header *st=hd,*hd1,*hd2,*result1,*result2;
	hd=getvalue(hd); if (error) return;
	if (hd->type!=s_matrix)
	{	output("Illegal parameter for project!\n"); error=82; return;
	}
	getmatrix(hd,&r,&c,&mx); col=c;
	hd1=next_param(st); hd2=next_param(hd1);
	hd1=getvalue(hd1); hd2=getvalue(hd2);
	if (error) return;
	if (hd1->type!=s_matrix || hd2->type!=s_matrix ||
		dimsof(hd1)->r!=r || dimsof(hd2)->r!=r ||
		dimsof(hd1)->c!=c || dimsof(hd2)->c!=c)
	{	output("Matrix dimensions for project must agree!\n");
		error=83; return;
	}
	my=matrixof(hd1); mz=matrixof(hd2);
	result1=new_matrix(r,c,""); if (error) return;
	result2=new_matrix(r,c,""); if (error) return;
	screen_col=matrixof(result1);
	screen_row=matrixof(result2);
	
	cos_left=cos(a_left); sin_left=sin(a_left);
	cos_up=cos(a_up); sin_up=sin(a_up);
	for (i=0; i<r; i++)
		for (j=0; j<c; j++)
		{	project(*mat(mx,c,i,j),*mat(my,c,i,j),*mat(mz,c,i,j),
				&screen_col[col*i+j],&screen_row[col*i+j]);
			screen_row[col*i+j]=upperr+lowerr-screen_row[col*i+j];
			if (test_key()==escape) { error=1; return; }
		}
	moveresult(st,result1);
	moveresult(nextof(st),result2);
}

typedef struct { int i,j; double z; } recttyp;

int compare (const recttyp **r1, const recttyp **r2)
{	if ((*r1)->z > (*r2)->z) return -1;
	else return 1;
}

void msolid (header *hd)
{	double *screen_col,*screen_row;
	size_t col,size,n,ind;
	double *mx,*my,*mz,z;
	int c,r,i,j;
	double cc[8];
	header *st=hd,*hd1,*hd2;
	recttyp *rectp;
	recttyp **rectpp,**rectps;
	hd=getvalue(hd); if (error) return;
	if (hd->type!=s_matrix || dimsof(hd)->r<2 || dimsof(hd)->c<2)
	{	output("Illegal parameter for solid!\n"); error=82; return;
	}
	getmatrix(hd,&r,&c,&mx); col=c;
	hd1=next_param(st); hd2=next_param(hd1);
	hd1=getvalue(hd1); hd2=getvalue(hd2);
	if (error) return;
	if (hd1->type!=s_matrix || hd2->type!=s_matrix ||
		dimsof(hd1)->r!=r || dimsof(hd2)->r!=r ||
		dimsof(hd1)->c!=c || dimsof(hd2)->c!=c)
	{	output("Matrix dimensions for solid must agree!\n");
		error=83; return;
	}
	my=matrixof(hd1); mz=matrixof(hd2);
	size=(LONG)c*r*sizeof(double);
	n=(LONG)(r-1)*(c-1);
	screen_col=(double *)newram;
	screen_row=(double *)(newram+size);
	rectp=(recttyp *)(newram+2*size);
	rectpp=rectps=(recttyp **)(newram+2*size+n*sizeof(recttyp));
	if (newram+2*size+(sizeof(recttyp)+sizeof(recttyp *))*n>ramend)
	{	output("Out of memory in solid!\n");
		error=85; return;
	}	
	cos_left=cos(a_left); sin_left=sin(a_left);
	cos_up=cos(a_up); sin_up=sin(a_up);
	for (i=0; i<r; i++)
		for (j=0; j<c; j++)
		{	z=project(*mat(mx,c,i,j),*mat(my,c,i,j),*mat(mz,c,i,j),
				&screen_col[col*i+j],&screen_row[col*i+j]);
			if (i<r-1 && j<c-1)
			{	rectp->i=i; rectp->j=j; rectp->z=z;
				*rectpp++=rectp; rectp++;
			}
			if (test_key()==escape) { error=1; return; }
		}
	qsort(rectps,n,sizeof(recttyp *),
		(int (*)(const void *, const void *))compare);
	graphic_mode();
	if (!holding) clear_graphics();
	rectpp=rectps;
	for (ind=0; ind<n; ind++)
	{	i=(*rectpp)->i; j=(*rectpp)->j;
		cc[0]=screen_col[col*i+j]; cc[1]=screen_row[col*i+j];
		cc[2]=screen_col[col*(i+1)+j]; cc[3]=screen_row[col*(i+1)+j];
		cc[4]=screen_col[col*(i+1)+j+1]; cc[5]=screen_row[col*(i+1)+(j+1)];
		cc[6]=screen_col[col*i+j+1]; cc[7]=screen_row[col*i+j+1];
		if (!twosides ||
			((cc[2]-cc[0])*(cc[5]-cc[1])-(cc[3]-cc[1])*(cc[4]-cc[0]))>0)
			gfill(cc,fill_blank,4,connected);
		else gfill(cc,fill_filled,4,connected);
		if (test_key()==escape) { error=1; gflush(); return; }
		rectpp++;
	}
	hd=new_real(0.0,"");
	moveresult(st,hd);
	gflush();
}

void msolidh (header *hd)
{	double *screen_col,*screen_row;
	size_t col,size,n,ind;
	double *mx,*my,*mz,*mh,z;
	int c,r,i,j;
	double cc[8];
	header *st=hd,*hd1,*hd2,*hd3;
	recttyp *rectp;
	recttyp **rectpp,**rectps;
	hd=getvalue(hd); if (error) return;
	if (hd->type!=s_matrix || dimsof(hd)->r<2 || dimsof(hd)->c<2)
	{	output("Illegal parameter for solid!\n"); error=82; return;
	}
	getmatrix(hd,&r,&c,&mx); col=c;
	hd1=next_param(st); hd2=next_param(hd1); hd3=next_param(hd2);
	hd1=getvalue(hd1); hd2=getvalue(hd2); hd3=getvalue(hd3);
	if (error) return;
	if (hd1->type!=s_matrix || hd2->type!=s_matrix || hd3->type!=s_matrix ||
		dimsof(hd1)->r!=r || dimsof(hd2)->r!=r ||
		dimsof(hd1)->c!=c || dimsof(hd2)->c!=c ||
		dimsof(hd3)->r!=r || dimsof(hd3)->c!=c)
	{	output("Matrix dimensions for solidhue must agree!\n");
		error=83; return;
	}
	my=matrixof(hd1); mz=matrixof(hd2); mh=matrixof(hd3);
	size=(LONG)c*r*sizeof(double);
	n=(LONG)(r-1)*(c-1);
	screen_col=(double *)newram;
	screen_row=(double *)(newram+size);
	rectp=(recttyp *)(newram+2*size);
	rectpp=rectps=(recttyp **)(newram+2*size+n*sizeof(recttyp));
	if (newram+2*size+(sizeof(recttyp)+sizeof(recttyp *))*n>ramend)
	{	output("Out of memory in solid!\n");
		error=85; return;
	}	
	cos_left=cos(a_left); sin_left=sin(a_left);
	cos_up=cos(a_up); sin_up=sin(a_up);
	for (i=0; i<r; i++)
		for (j=0; j<c; j++)
		{	z=project(*mat(mx,c,i,j),*mat(my,c,i,j),*mat(mz,c,i,j),
				&screen_col[col*i+j],&screen_row[col*i+j]);
			if (i<r-1 && j<c-1)
			{	rectp->i=i; rectp->j=j; rectp->z=z;
				*rectpp++=rectp; rectp++;
			}
			if (test_key()==escape) { error=1; return; }
		}
	qsort(rectps,n,sizeof(recttyp *),
		(int (*)(const void *,const void *))compare);
	graphic_mode();
	if (!holding) clear_graphics();
	rectpp=rectps;
	for (ind=0; ind<n; ind++)
	{	i=(*rectpp)->i; j=(*rectpp)->j;
		cc[0]=screen_col[col*i+j]; cc[1]=screen_row[col*i+j];
		cc[2]=screen_col[col*(i+1)+j]; cc[3]=screen_row[col*(i+1)+j];
		cc[4]=screen_col[col*(i+1)+j+1]; cc[5]=screen_row[col*(i+1)+(j+1)];
		cc[6]=screen_col[col*i+j+1]; cc[7]=screen_row[col*i+j+1];
		gfillh(cc,*mat(mh,c,i,j),densitycolor,dgrid);
		if (test_key()==escape) { error=1; gflush(); return; }
		rectpp++;
	}
	hd=new_real(0.0,"");
	moveresult(st,hd);
	gflush();
}

void msolid1 (header *hd)
{	double *screen_col,*screen_row;
	size_t col,size,n,ind;
	double *mx,*my,*mz,z,*mult;
	int c,r,i,j,multc,multr,multi,multn,norectp=0;
	double cc[8];
	header *st=hd,*hd1,*hd2,*hdmult;
	recttyp *rectp;
	recttyp **rectpp,**rectps;
	hd=getvalue(hd); if (error) return;
	if (hd->type!=s_matrix || dimsof(hd)->r<2 || dimsof(hd)->c<2)
	{	output("Illegal parameter for solid!\n"); error=82; return;
	}
	getmatrix(hd,&r,&c,&mx); col=c;
	hd1=next_param(st); hd2=next_param(hd1); hdmult=next_param(hd2);
	hd1=getvalue(hd1); hd2=getvalue(hd2); hdmult=getvalue(hdmult);
	if (error) return;
	if (hd1->type!=s_matrix || hd2->type!=s_matrix ||
		dimsof(hd1)->r!=r || dimsof(hd2)->r!=r ||
		dimsof(hd1)->c!=c || dimsof(hd2)->c!=c)
	{	output("Matrix dimensions for solid must agree!\n");
		error=83; return;
	}
	if (hdmult->type!=s_real &&
		(hdmult->type!=s_matrix || dimsof(hdmult)->r!=1
			|| dimsof(hdmult)->c<1)
		)
	{	output("4th parameter for solid must be a real vector!\n");
		error=83; return;
	}
	my=matrixof(hd1); mz=matrixof(hd2);
	getmatrix(hdmult,&multr,&multc,&mult);
	multn=0; multi=(int)(*mult)-1;
	size=(LONG)c*r*sizeof(double);
	n=(LONG)(r-1)*(c-1);
	screen_col=(double *)newram;
	screen_row=(double *)(newram+size);
	rectp=(recttyp *)(newram+2*size);
	rectpp=rectps=(recttyp **)(newram+2*size+n*sizeof(recttyp));
	if (newram+2*size+(sizeof(recttyp)+sizeof(recttyp *))*n>ramend)
	{	output("Out of memory in solid!\n");
		error=85; return;
	}	
	cos_left=cos(a_left); sin_left=sin(a_left);
	cos_up=cos(a_up); sin_up=sin(a_up);
	for (i=0; i<r; i++)
	{	if (multi==i)
		{	mult++; multn++;
			if (multn>=multc) multi=-1;
			else multi=(int)(*mult)-1;
			n-=c-1;
			norectp=1;
		}
		for (j=0; j<c; j++)
		{	z=project(*mat(mx,c,i,j),*mat(my,c,i,j),*mat(mz,c,i,j),
				&screen_col[col*i+j],&screen_row[col*i+j]);
			if (i<r-1 && j<c-1 && !norectp)
			{	rectp->i=i; rectp->j=j; rectp->z=z;
				*rectpp++=rectp; rectp++;
			}
			if (test_key()==escape) { error=1; return; }
		}
		norectp=0;
	}
	qsort(rectps,n,sizeof(recttyp *),
		(int (*)(const void *,const void *))compare);
	graphic_mode();
	if (!holding) clear_graphics();
	rectpp=rectps;
	for (ind=0; ind<n; ind++)
	{	i=(*rectpp)->i; j=(*rectpp)->j;
		cc[0]=screen_col[col*i+j]; cc[1]=screen_row[col*i+j];
		cc[2]=screen_col[col*(i+1)+j]; cc[3]=screen_row[col*(i+1)+j];
		cc[4]=screen_col[col*(i+1)+j+1]; cc[5]=screen_row[col*(i+1)+(j+1)];
		cc[6]=screen_col[col*i+j+1]; cc[7]=screen_row[col*i+j+1];
		if (!twosides ||
			((cc[2]-cc[0])*(cc[5]-cc[1])-(cc[3]-cc[1])*(cc[4]-cc[0]))>0)
			gfill(cc,fill_blank,4,connected);
		else gfill(cc,fill_filled,4,connected);
		if (test_key()==escape) { error=1; gflush(); return; }
		rectpp++;
	}
	hd=new_real(0.0,"");
	moveresult(st,hd);
	gflush();
}

void hcontour (double val, int n, int m, 
	double x[], double r[], double c[])
/**** hcontour
	helping function to contour.
****/
{	double f1,f2;
	if ((val>=x[n] && val<=x[n+1]) || (val>=x[n+1] && val<=x[n]))
	if ((val>=x[m] && val<=x[m+1]) || (val>=x[m+1] && val<=x[m]))
	{	if (x[n+1]==x[n]) f1=0;
		else f1=(val-x[n])/(x[n+1]-x[n]);
		if (x[m+1]==x[m]) f2=0;
		else f2=(val-x[m])/(x[m+1]-x[m]);
		gline((c[n]+f1*(c[n+1]-c[n])),
			(r[n]+f1*(r[n+1]-r[n])),
			(c[m]+f2*(c[m+1]-c[m])),
			(r[m]+f2*(r[m+1]-r[m])),
			linecolor,line_solid,linewidth);
	}
}

void contour (double x[], int i, int j, int rows, int cols, 
	double v[], int nv)
/***** contour
	x1 is lower left edge, x2 upper left, x3 upper right, x4 lower
	right value at a square. 
	does contour plot of the nv values in v.
	r and c is needed to compute the position of the square.
*****/
{	int k,n,m;
	double sr[5],sc[5];
	double val;
	sr[4]=sr[0]=sr[3]=(lowerr-((LONG)i*(lowerr-upperr))/cols);
	sr[1]=sr[2]=(lowerr-((LONG)(i+1)*(lowerr-upperr))/cols);
	sc[4]=sc[0]=sc[1]=(upperc+((LONG)j*(lowerc-upperc))/rows);
	sc[2]=sc[3]=(upperc+((LONG)(j+1)*(lowerc-upperc))/rows);
	for (k=0; k<nv; k++)
	{	val=v[k];
		for (n=0; n<3; n++)
			for (m=n+1; m<4; m++)
				hcontour(val,n,m,x,sr,sc);
	}
}

void mcontour (header *hd)
/***** mcontour
	contour plot with matrix and vector intput.
*****/
{	header *st=hd,*result,*hd1;
	double *m,*mv,x[5];
	int r,c,cv,dummy,i,j;
	hd=getvalue(hd); if (error) return;
	if (hd->type!=s_matrix || dimsof(hd)->c<2 || dimsof(hd)->r<2)
	{	output("Contour needs a real matrix!\n"); error=81; return;
	}
	hd1=next_param(st); if (error) return;
	hd1=getvalue(hd1); if (error) return;
	if (hd1->type!=s_real)
		if (hd1->type!=s_matrix || dimsof(hd1)->r!=1)
		{	output("Second parameter of contour must be a vector!\n");
			error=82; return;
		}
	getmatrix(hd,&r,&c,&m); getmatrix(hd1,&dummy,&cv,&mv);
	graphic_mode();
	if (!holding) clear_graphics();
	frame();
	for (i=0; i<r-1; i++)
	{	for (j=0; j<c-1; j++)
		{	x[0]=*mat(m,c,i,j); x[1]=*mat(m,c,i+1,j);
			x[2]=*mat(m,c,i+1,j+1); x[3]=*mat(m,c,i,j+1);
			x[4]=x[0];
			contour(x,i,j,c-1,r-1,mv,cv);
		}
		if (test_key()==escape) { error=1; gflush(); return; }
	}
	result=new_real(cv,"");
	moveresult(st,result);
	gflush();
}

void mdensity (header *hd)
/***** mcontour
	density plot with matrix input.
*****/
{	header *st=hd,*result;
	double *m,x[4],deltax,deltay;
	int r,c,i,j;
	hd=getvalue(hd); if (error) return;
	if (hd->type!=s_matrix || dimsof(hd)->c<2 || dimsof(hd)->r<2)
	{	output("Density needs a real matrix!\n"); error=81; return;
	}
	getmatrix(hd,&r,&c,&m);
	graphic_mode();
	if (!holding) clear_graphics();
	deltax=(double)(lowerc-upperc)/(c-1);
	deltay=(double)(lowerr-upperr)/(r-1);
	for (i=0; i<r-1; i++)
	{	for (j=0; j<c-1; j++)
		{	x[0]=*mat(m,c,i,j);
			x[1]=*mat(m,c,i+1,j);
			x[2]=*mat(m,c,i+1,j+1);
			x[3]=*mat(m,c,i,j+1);
			gbar(
				upperc+j*deltax,lowerr-(i+1)*deltay,
				upperc+(j+1)*deltax,lowerr-i*deltay,
				(x[0]+x[1]+x[2]+x[3])/4,densitycolor,dgrid);
		}
		if (test_key()==escape) { error=1; gflush(); return; }
	}
	result=new_real(0,"");
	moveresult(st,result);
	gflush();
}

void mview (header *hd)
{	double *m;
	hd=getvalue(hd);
	if (hd->type!=s_matrix || dimsof(hd)->r!=1 || dimsof(hd)->c!=4)
	{	output("Arguments for view are [dist tele alpha beta]!\n");
		error=90; return;
	}
	m=matrixof(hd);
	distance=*m++;
	tele=*m++;
	a_left=*m++;
	a_up=*m++;
}

void mwindow (header *hd)
{	double *m;
	hd=getvalue(hd);
	if (hd->type!=s_matrix || dimsof(hd)->r!=1 || dimsof(hd)->c!=4)
	{	output("Arguments for window are [c0 r0 c1 r1]!\n");
		error=90; return;
	}
	m=matrixof(hd);
	upperc=(int)(*m++);
	upperr=(int)(*m++);
	lowerc=(int)(*m++);
	lowerr=(int)(*m++);
	if (lowerr<upperr) lowerr=upperr+1;
	if (lowerc<upperc) lowerc=upperc+1;
	newframe=1; scaling=1;
}

void mcolor (header *hd)
{	int old=linecolor;
	hd=getvalue(hd);
	if (hd->type!=s_real)
	{	output("Argument for color must be real!\n");
		error=90; return;
	}
	linecolor=(int)*realof(hd);
	*realof(hd)=(double)old;
}

void mfcolor (header *hd)
{	int old=framecolor;
	hd=getvalue(hd);
	if (hd->type!=s_real)
	{	output("Argument for color must be real!\n");
		error=90; return;
	}
	framecolor=(int)*realof(hd);
	*realof(hd)=(double)old;
}

void mwcolor (header *hd)
{	int old=wirecolor;
	hd=getvalue(hd);
	if (hd->type!=s_real)
	{	output("Argument for color must be real!\n");
		error=90; return;
	}
	wirecolor=(int)*realof(hd);
	*realof(hd)=(double)old;
}

void mtcolor (header *hd)
{	int old=textcolor;
	hd=getvalue(hd);
	if (hd->type!=s_real)
	{	output("Argument for color must be real!\n");
		error=90; return;
	}
	textcolor=(int)*realof(hd);
	*realof(hd)=(double)old;
}

void mdcolor (header *hd)
{	int old=densitycolor;
	hd=getvalue(hd);
	if (hd->type!=s_real)
	{	output("Argument for color must be real!\n");
		error=90; return;
	}
	densitycolor=(int)*realof(hd);
	*realof(hd)=(double)old;
}

void mdgrid (header *hd)
{	int old=dgrid;
	hd=getvalue(hd);
	if (hd->type!=s_real)
	{	output("Argument for huegrid must be real!\n");
		error=90; return;
	}
	dgrid=(int)*realof(hd);
	*realof(hd)=(double)old;
}

void mstyle (header *hd)
{	hd=getvalue(hd); if (error) return;
	if (hd->type!=s_string)
	{	output("Argument style must be a string!\n");
		error=90; return;
	}
	if (!strcmp(stringof(hd),"i")) linetype=line_none;
	else if (!strcmp(stringof(hd),"-")) linetype=line_solid;
	else if (!strcmp(stringof(hd),".")) linetype=line_dotted;
	else if (!strcmp(stringof(hd),"--")) linetype=line_dashed;
	else if (!strcmp(stringof(hd),"mx")) markertype=marker_cross;
	else if (!strcmp(stringof(hd),"mo")) markertype=marker_circle;
	else if (!strcmp(stringof(hd),"m<>")) markertype=marker_diamond;
	else if (!strcmp(stringof(hd),"m.")) markertype=marker_dot;
	else if (!strcmp(stringof(hd),"m+")) markertype=marker_plus;
	else if (!strcmp(stringof(hd),"m[]")) markertype=marker_square;
	else if (!strcmp(stringof(hd),"m*")) markertype=marker_star;
	else { markertype=marker_cross; linetype=line_solid; }
}

void mmstyle (header *hd)
{	header *st=hd,*res;
	hd=getvalue(hd); if (error) return;
	if (hd->type!=s_string)
	{	output("Argument for style must be a string!\n");
		error=90; return;
	}
	switch (markertype)
	{	case marker_cross : res=new_string("mx",8,""); break;
		case marker_circle : res=new_string("mo",8,""); break;
		case marker_diamond : res=new_string("m<>",8,""); break;
		case marker_dot : res=new_string("m.",8,""); break;
		case marker_plus : res=new_string("m+",8,""); break;
		case marker_square : res=new_string("m[]",8,""); break;
		case marker_star : res=new_string("m*",8,""); break;
		default : res=new_string("",8,"");
	}
	if (!strcmp(stringof(hd),"mx")) markertype=marker_cross;
	else if (!strcmp(stringof(hd),"mo")) markertype=marker_circle;
	else if (!strcmp(stringof(hd),"m<>")) markertype=marker_diamond;
	else if (!strcmp(stringof(hd),"m.")) markertype=marker_dot;
	else if (!strcmp(stringof(hd),"m+")) markertype=marker_plus;
	else if (!strcmp(stringof(hd),"m[]")) markertype=marker_square;
	else if (!strcmp(stringof(hd),"m*")) markertype=marker_star;
	moveresult(st,res);
}

void mlstyle (header *hd)
{	header *st=hd,*res;
	hd=getvalue(hd); if (error) return;
	if (hd->type!=s_string)
	{	output("Argument for style must be string!\n");
		error=90; return;
	}
	switch (linetype)
	{	case line_none : res=new_string("i",8,""); break;
		case line_solid : res=new_string("-",8,""); break;
		case line_dotted : res=new_string(".",8,""); break;
		case line_dashed : res=new_string("--",8,""); break;
		default : res=new_string("",8,"");
	}
	if (!strcmp(stringof(hd),"i")) linetype=line_none;
	else if (!strcmp(stringof(hd),"-")) linetype=line_solid;
	else if (!strcmp(stringof(hd),".")) linetype=line_dotted;
	else if (!strcmp(stringof(hd),"--")) linetype=line_dashed;
	moveresult(st,res);
}

void mlinew (header *hd)
{	header *st=hd,*res;
	int h,old=linewidth;
	hd=getvalue(hd); if (error) return;
	if (hd->type!=s_real)
	{	output("Argument for linewidth must be a real!");
		error=90; return;
	}
	if ((h=(int)*realof(hd))!=0) linewidth=h;
	res=new_real(old,"");
	moveresult(st,res);
}

void mctext (header *hd)
{	header *hd1;
	hd1=next_param(hd);
	hd=getvalue(hd); if (error) return;
	if (hd1)  hd1=getvalue(hd1); if (error) return;
	if (hd->type!=s_string || hd1->type!=s_matrix || 
		dimsof(hd1)->r!=1 || dimsof(hd1)->c!=2)
	{	output("Ctext needs a string and a vector [x y]!\n");
		error=91; return;
	}
	graphic_mode();
	gtext((int)*matrixof(hd1),(int)*(matrixof(hd1)+1),
		stringof(hd),textcolor,1);
	gflush();
}

void mrtext (header *hd)
{	header *hd1;
	hd1=next_param(hd);
	hd=getvalue(hd); if (error) return;
	if (hd1)  hd1=getvalue(hd1); if (error) return;
	if (hd->type!=s_string || hd1->type!=s_matrix || 
		dimsof(hd1)->r!=1 || dimsof(hd1)->c!=2)
	{	output("Ctext needs a string and a vector [x y]!\n");
		error=91; return;
	}
	graphic_mode();
	gtext((int)*matrixof(hd1),(int)*(matrixof(hd1)+1),
		stringof(hd),textcolor,2);
	gflush();
}

void mtext (header *hd)
{	header *hd1;
	hd1=next_param(hd);
	hd=getvalue(hd); if (error) return;
	if (hd1)  hd1=getvalue(hd1); if (error) return;
	if (hd->type!=s_string || hd1->type!=s_matrix || 
		dimsof(hd1)->r!=1 || dimsof(hd1)->c!=2)
	{	output("Text needs a string and a vector [x y]!\n");
		error=91; return;
	}
	graphic_mode();
	gtext((int)*matrixof(hd1),(int)*(matrixof(hd1)+1),
		stringof(hd),textcolor,0);
	gflush();
}

void msetplot (header *hd)
{	header *st=hd,*result;
	double *m;
	hd=getvalue(hd); if (error) return;
	if (hd->type!=s_matrix || dimsof(hd)->r!=1 || dimsof(hd)->c!=4)
	{	output("Setplot needs a 1x4 vector!\n");
		error=2200; return;
	}
	result=new_matrix(1,4,""); if (error) return;
	m=matrixof(result);
	*m++=x_min; *m++=x_max; *m++=y_min; *m++=y_max;
	m=matrixof(hd);
	x_min=*m++; x_max=*m++; y_min=*m++; y_max=*m++;
	moveresult(st,result);
	scaling=0;
}

void mholding (header *hd)
{	header *st=hd,*result;
	hd=getvalue(hd); if (error) return;
	if (hd->type!=s_real)
	{	output("Holding needs a 1 or 0!\n");
		error=2201; return;
	}
	result=new_real(holding,"");
	holding=(*realof(hd)!=0.0); scaling=!holding;
	moveresult(st,result);
}

void mscaling (header *hd)
{	header *st=hd,*result;
	hd=getvalue(hd); if (error) return;
	if (hd->type!=s_real)
	{	output("Scaling needs a 1 or 0!\n");
		error=2201; return;
	}
	result=new_real(scaling,"");
	scaling=(*realof(hd)!=0.0);
	moveresult(st,result);
}

void mtwosides (header *hd)
{	header *st=hd,*result;
	hd=getvalue(hd); if (error) return;
	if (hd->type!=s_real)
	{	output("Twosides needs a 1 or 0!\n");
		error=2201; return;
	}
	result=new_real(twosides,"");
	twosides=(*realof(hd)!=0.0);
	moveresult(st,result);
}

void mtriangles (header *hd)
{	header *st=hd,*result;
	hd=getvalue(hd); if (error) return;
	if (hd->type!=s_real)
	{	output("Triangles needs a 1 or 0!\n");
		error=2201; return;
	}
	result=new_real(triangles,"");
	triangles=(*realof(hd)!=0.0);
	moveresult(st,result);
}

void mscale (header *hd)
{	hd=getvalue(hd);
	if (hd->type!=s_real)
	{	output("Scale needs a real!\n"); error=150; return;
	}
	scale(*realof(hd));
}

void mmeshfactor (header *hd)
{	double oldfactor=meshfactor;
	hd=getvalue(hd);
	if (hd->type!=s_real)
	{	output("Meshfactor needs a real!\n"); error=150; return;
	}
	meshfactor=*realof(hd);
	if (meshfactor<0) meshfactor=0;
	if (meshfactor>1) meshfactor=1;
	*realof(hd)=oldfactor;
}

#pragma warn -par

void mtextsize (header *hd)
{	header *result;
	result=new_matrix(1,2,""); if (error) return;
	*matrixof(result)=wchar;
	*(matrixof(result)+1)=hchar;
}

void mmouse (header *hd)
{	header *result;
	int c,r;
	double *m;
	result=new_matrix(1,2,""); if (error) return;
	graphic_mode();
	mouse(&c,&r);
	m=matrixof(result);
	*m++=x_min+(c-upperc)/(double)(lowerc-upperc)*(x_max-x_min);
	*m++=y_max-(r-upperr)/(double)(lowerr-upperr)*(y_max-y_min);
}

void mholding0 (header *hd)
{	new_real(holding,"");
}

void mplot1 (header *hd)
{	header *result;
	double *x;
	result=new_matrix(1,4,""); if (error) return;
	x=matrixof(result);
	*x++=x_min; *x++=x_max; *x++=y_min; *x++=y_max;
}

void mview0 (header *hd)
{	header *result;
	double *m;
	result=new_matrix(1,4,""); if (error) return;
	m=matrixof(result);
	*m++=distance;
	*m++=tele;
	*m++=a_left;
	*m++=a_up;
}

void mwindow0 (header *hd)
{	double *m;
	hd=new_matrix(1,4,""); if (error) return;
	m=matrixof(hd);
	*m++=upperc;
	*m++=upperr;
	*m++=lowerc;
	*m++=lowerr;
}

void mframe (header *hd)
{	graphic_mode();
	frame();
	new_real(0,"");
}
