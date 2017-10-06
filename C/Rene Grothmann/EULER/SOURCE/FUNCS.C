#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <float.h>
#include <limits.h>

#include "header.h"
#include "sysdep.h"
#include "funcs.h"
#include "matheh.h"
#include "polynom.h"
#include "helpf.h"
#include "graphics.h"

#define wrong_arg() { error=26; output("Wrong argument\n"); return; }

char *argname[] =
	{ "arg1","arg2","arg3","arg4","arg5","arg6","arg7","arg8","arg9",
		"arg10" } ;
int xors[10];

double (*func) (double);

void funceval (double *x, double *y)
/* evaluates the function stored in func with pointers. */
{	*y=func(*x);
}

void spread1 (double f (double), 
	void fc (double *, double *, double *, double *),
	header *hd)
{	header *result,*st=hd;
	hd=getvalue(hd);
	if (error) return;
	func=f;
	result=map1(funceval,fc,hd);
	if (!error) moveresult(st,result);
}

void csin (double *x, double *xi, double *z, double *zi)
{	*z=cosh(*xi)*sin(*x);
	*zi=sinh(*xi)*cos(*x);
}

void msin (header *hd) 
{	spread1(sin,csin,hd);
}

void ccos (double *x, double *xi, double *z, double *zi)
{	*z=cosh(*xi)*cos(*x);
	*zi=-sinh(*xi)*sin(*x);
}

void mcos (header *hd)
{	spread1(cos,ccos,hd);
}

void ctan (double *x, double *xi, double *z, double *zi)
{	double s,si,c,ci;
	csin(x,xi,&s,&si); ccos(x,xi,&c,&ci);
	complex_divide(&s,&si,&c,&ci,z,zi);
}

double rtan (double x)
{	if (cos(x)==0.0) return 1e10;
	return tan(x);
}

void mtan (header *hd)
{	spread1(
#ifdef FLOAT_TEST
	rtan,
#else
	tan,
#endif
	ctan,hd);
}

double ratan (double x)
{	if (x<=-M_PI && x>=M_PI) return 1e10;
	else return atan(x);
}

void carg (double *x, double *xi, double *z)
{	
#ifdef FLOAT_TEST
	if (*x==0.0 && *xi==0.0) *z=0.0;
#endif
	*z = atan2(*xi,*x);
}

double rlog (double x)
{	if (x<=0) { error=1; return 0; }
	else return log(x);
}

void cclog (double *x, double *xi, double *z, double *zi)
{	
#ifdef FLOAT_TEST
	*z=rlog(sqrt(*x * *x + *xi * *xi));
#else
	*z=log(sqrt(*x * *x + *xi * *xi));
#endif
	carg(x,xi,zi);
}

double rsign (double x)
{	if (x<0) return -1;
	else if (x<=0) return 0;
	else return 1;
}

void msign (header *hd)
{	spread1(rsign,0,hd);
}

void catan (double *x, double *xi, double *y, double *yi)
{	double h,hi,g,gi,t,ti;
	h=1-*xi; hi=*x; g=1+*xi; gi=-*x;
	complex_divide(&h,&hi,&g,&gi,&t,&ti);
	cclog(&t,&ti,&h,&hi);
	*y=hi/2; *yi=-h/2;
}

void matan (header *hd)
{	spread1(
#ifdef FLOAT_TEST
	ratan,
#else
	atan,
#endif
	catan,hd);
}

double rasin (double x)
{	if (x<-1 || x>1) { error=1; return 0; }
	else return asin(x);
}

void csqrt (double *x, double *xi, double *z, double *zi)
{	double a,r;
	carg(x,xi,&a); a=a/2.0;
	r=sqrt(sqrt(*x * *x + *xi * *xi));
	*z=r*cos(a);
	*zi=r*sin(a);
}

void casin (double *x, double *xi, double *y, double *yi)
{	double h,hi,g,gi;
	complex_multiply(x,xi,x,xi,&h,&hi);
	h=1-h; hi=-hi;
	csqrt(&h,&hi,&g,&gi);
	h=-*xi+g; hi=*x+gi;
	cclog(&h,&hi,yi,y);
	*yi=-*yi;
}

void masin (header *hd)
{	spread1(
#ifdef FLOAT_TEST
	rasin,
#else
	asin,
#endif
	casin,hd);
}

double racos (double x)
{	if (x<-1 || x>1) { error=1; return 0; }
	else return acos(x);
}

void cacos (double *x, double *xi, double *y, double *yi)
{	double h,hi,g,gi;
	complex_multiply(x,xi,x,xi,&h,&hi);
	h=1-h; hi=-hi;
	csqrt(&h,&hi,&g,&gi);
	hi=*xi+g; h=*x-gi;
	cclog(&h,&hi,yi,y);
	*yi=-*yi;
}

void macos (header *hd)
{	spread1(
#ifdef FLOAT_TEST
	racos,
#else
	acos,
#endif
	cacos,hd);
}

void cexp (double *x, double *xi, double *z, double *zi)
{	double r=exp(*x);
	*z=cos(*xi)*r;
	*zi=sin(*xi)*r;
}

void mexp (header *hd)
{	spread1(exp,cexp,hd);
}

double rarg (double x)
{	if (x>=0) return 0.0;
	else return M_PI;
}

void mlog (header *hd)
{	spread1(log,cclog,hd);
}

double rsqrt (double x)
{	if (x<0.0) { error=1; return 1e10; }
	else return sqrt(x);
}

void msqrt (header *hd)
{	spread1(
#ifdef FLOAT_TEST
	rsqrt,
#else
	sqrt,
#endif
	csqrt,hd);
}

void mceil (header *hd)
{	spread1(ceil,0,hd);
}

void mfloor (header *hd)
{	spread1(floor,0,hd);
}

void cconj (double *x, double *xi, double *z, double *zi)
{	*zi=-*xi; *z=*x;
}

double ident (double x)
{	return x;
}

void mconj (header *hd)
{	spread1(ident,cconj,hd);
}

void spread1r (double f (double), 
	void fc (double *, double *, double *),
	header *hd)
{	header *result,*st=hd;
	hd=getvalue(hd);
	if (error) return;
	func=f;
	result=map1r(funceval,fc,hd);
	if (!error) moveresult(st,result);
}

double rnot (double x)
{	if (x!=0.0) return 0.0;
	else return 1.0;
}

void cnot (double *x, double *xi, double *r)
{	if (*x==0.0 && *xi==0.0) *r=1.0;
	else *r=0.0;
}

void mnot (header *hd)
{	spread1r(rnot,cnot,hd);
}

void crealpart (double *x, double *xi, double *z)
{	*z=*x;
}

void mre (header *hd)
{	spread1r(ident,crealpart,hd);
}

double zero (double x)
{	return 0.0;
}

void cimagpart (double *x, double *xi, double *z)
{	*z=*xi;
}

void mim (header *hd)
{	spread1r(zero,cimagpart,hd);
}

void marg (header *hd)
{	spread1r(rarg,carg,hd);
}

void cxabs (double *x, double *xi, double *z)
{	*z=sqrt(*x * *x + *xi * *xi);
}

void mabs (header *hd)
{	spread1r(fabs,cxabs,hd);
}

void mpi (header *hd)
{	new_real(M_PI,"");
}

void margn (header *hd)
{	new_real(actargn,"");
}

void mtime (header *hd)
{	hd=new_real(myclock(),"");
}

void mfree (header *hd)
{	new_real(ramend-endlocal,"");
}

void mshrink (header *hd)
{	header *st=hd,*result;
	size_t size;
	hd=getvalue(hd); if (error) return;
	if (*realof(hd)>LONG_MAX) wrong_arg();
	size=(size_t)*realof(hd);
	if (ramend-size<newram)
	{	output("Cannot shrink that much!\n");
		error=171; return;
	}
	if (size) 
		if (shrink(size)) ramend-=size;
		else
		{	output("Shrink failed!\n"); error=172; return;
		}
	result=new_real(ramend-ramstart,"");
	moveresult(st,result);
}

void mepsilon (header *hd)
{	new_real(epsilon,"");
}

void msetepsilon (header *hd)
{	header *stack=hd,*hd1,*result;
	hd1=getvalue(hd); if (error) return;
	if (hd1->type!=s_real) wrong_arg();
	result=new_real(epsilon,"");
	epsilon=*realof(hd1);
	moveresult(stack,result);
}	

void mindex (header *hd)
{	new_real((double)loopindex,"");
}

void spread2 (void f (double *, double *, double *),
	void fc (double *, double *, double *, double *, double *, double *),
	header *hd)
{	header *result,*st=hd,*hd1;
	hd=getvalue(hd); if (error) return;
	hd1=next_param(st); if (!hd1 || error) return;
	hd1=getvalue(hd1); if (error) return;
	result=map2(f,fc,hd,hd1);
	if (!error) moveresult(st,result);
}

void spread2r (void f (double *, double *, double *),
	void fc (double *, double *, double *, double *, double *, double *),
	header *hd)
{	header *result,*st=hd,*hd1;
	int complex;
	hd=getvalue(hd); if (error) return;
	hd1=next_param(st); if (!hd1 || error) return;
	hd1=getvalue(hd1); if (error) return;
	complex=(hd1->type==s_complex || hd1->type==s_cmatrix ||
		hd->type==s_complex || hd->type==s_cmatrix);
	result=map2(f,fc,hd,hd1);
	if (complex) mcomplex(result);
	if (!error) moveresult(st,result);
}

void rmod (double *x, double *n, double *y)
{	*y=fmod(*x,*n);
}

void mmod (header *hd)
{	spread2(rmod,0,hd);
}

void cpow (double *x, double *xi, double *y, double *yi,
	double *z, double *zi)
{	double l,li,w,wi;
	if (fabs(*x)<epsilon && fabs(*xi)<epsilon)
	{	*z=*zi=0.0; return;
	}
	cclog(x,xi,&l,&li);
	complex_multiply(y,yi,&l,&li,&w,&wi);
	cexp(&w,&wi,z,zi);
}

void rpow (double *x, double *y, double *z)
{	int n;
	if (*x>0.0) *z=pow(*x,*y);
	else if (*x==0.0) if (*y==0.0) *z=1.0; else *z=0.0;
	else
	{	n=(int)*y;
		if (n%2) *z=-pow(-*x,n);
		else *z=pow(-*x,n);
	}
}

void mpower (header *hd)
{	spread2(rpow,cpow,hd);
}

void rgreater (double *x, double *y, double *z)
{	if (*x>*y) *z=1.0;
	else *z=0.0;
}

void mgreater (header *hd)
{	spread2(rgreater,0,hd);
}

void rless (double *x, double *y, double *z)
{	if (*x<*y) *z=1.0;
	else *z=0.0;
}

void mless (header *hd)
{	spread2(rless,0,hd);
}

void rgreatereq (double *x, double *y, double *z)
{	if (*x>=*y) *z=1.0;
	else *z=0.0;
}

void mgreatereq (header *hd)
{	spread2(rgreatereq,0,hd);
}

void rlesseq (double *x, double *y, double *z)
{	if (*x<=*y) *z=1.0;
	else *z=0.0;
}

void mlesseq (header *hd)
{	spread2(rlesseq,0,hd);
}

void ror (double *x, double *y, double *z)
{	if (*x!=0.0 || *y!=0.0) *z=1.0;
	else *z=0.0;
}

void mor (header *hd)
{	spread2(ror,0,hd);
}

void rrand (double *x, double *y, double *z)
{	if (*x!=0.0 && *y!=0.0) *z=1.0;
	else *z=0.0;
}

void mand (header *hd)
{	spread2(rrand,0,hd);
}

void requal (double *x, double *y, double *z)
{	if (*x==*y) *z=1.0;
	else *z=0.0;
}

void cequal (double *x, double *xi, double *y, double *yi, double *z,
	double *zi)
{	if (*x==*xi && *y==*yi) *z=1.0;
	else *z=0.0;
	*zi=0.0;
}

void mequal (header *hd)
{	spread2r(requal,cequal,hd);
}

void runequal (double *x, double *y, double *z)
{	if (*x!=*y) *z=1.0;
	else *z=0.0;
}

void cunequal (double *x, double *xi, double *y, double *yi, double *z,
	double *zi)
{	if (*x!=*y || *xi!=*yi) *z=1.0;
	else *z=0.0;
	*zi=0.0;
}

void munequal (header *hd)
{	spread2(runequal,cunequal,hd);
}

void raboutequal (double *x, double *y, double *z)
{	if (fabs(*x-*y)<epsilon) *z=1.0;
	else *z=0.0;
}

void caboutequal 
	(double *x, double *xi, double *y, double *yi, double *z,
		double *zi)
{	if (fabs(*x-*y)<epsilon && fabs(*xi-*yi)<epsilon) *z=1.0;
	else *z=0.0;
	*zi=0.0;
}

void maboutequal (header *hd)
{	spread2r(raboutequal,caboutequal,hd);
}

void mlusolve (header *hd)
{	header *st=hd,*hd1,*result;
	double *m,*m1;
	int r,c,r1,c1;
	hd=getvalue(hd);
	hd1=next_param(st);
	if (hd1) hd1=getvalue(hd1);
	if (error) return;
	if (hd->type==s_matrix || hd->type==s_real)
	{	getmatrix(hd,&r,&c,&m);
		if (hd1->type==s_cmatrix)
		{	make_complex(st);
			mlusolve(st); return;	
		}
		if (hd1->type!=s_matrix && hd1->type!=s_real) wrong_arg();
		getmatrix(hd1,&r1,&c1,&m1);
		if (c!=r || c<1 || r!=r1) wrong_arg();
		result=new_matrix(r,c1,""); if (error) return;
		lu_solve(m,r,m1,c1,matrixof(result));
		if (error) return;
		moveresult(st,result);
	}
	else if (hd->type==s_cmatrix || hd->type==s_complex)
	{	getmatrix(hd,&r,&c,&m);
		if (hd1->type==s_matrix || hd1->type==s_real)
		{	make_complex(next_param(st));
			mlusolve(st); return;
		}
		if (hd1->type!=s_cmatrix && hd1->type!=s_complex) wrong_arg();
		getmatrix(hd1,&r1,&c1,&m1);
		if (c!=r || c<1 || r!=r1) wrong_arg();
		result=new_cmatrix(r,c1,""); if (error) return;
		clu_solve(m,r,m1,c1,matrixof(result));
		if (error) return;
		moveresult(st,result);
	}
	else wrong_arg();
}

void msolve (header *hd)
{	header *st=hd,*hd1,*result;
	double *m,*m1;
	int r,c,r1,c1;
	hd=getvalue(hd);
	hd1=next_param(st);
	if (hd1) hd1=getvalue(hd1);
	if (error) return;
	if (hd->type==s_matrix || hd->type==s_real)
	{	getmatrix(hd,&r,&c,&m);
		if (hd1->type==s_cmatrix)
		{	make_complex(st);
			msolve(st); return;	
		}
		if (hd1->type!=s_matrix && hd1->type!=s_real) wrong_arg();
		getmatrix(hd1,&r1,&c1,&m1);
		if (c!=r || c<1 || r!=r1) wrong_arg();
		result=new_matrix(r,c1,""); if (error) return;
		solvesim(m,r,m1,c1,matrixof(result));
		if (error) return;
		moveresult(st,result);
	}
	else if (hd->type==s_cmatrix || hd->type==s_complex)
	{	getmatrix(hd,&r,&c,&m);
		if (hd1->type==s_matrix || hd1->type==s_real)
		{	make_complex(next_param(st));
			msolve(st); return;
		}
		if (hd1->type!=s_cmatrix && hd1->type!=s_complex) wrong_arg();
		getmatrix(hd1,&r1,&c1,&m1);
		if (c!=r || c<1 || r!=r1) wrong_arg();
		result=new_cmatrix(r,c1,""); if (error) return;
		c_solvesim(m,r,m1,c1,matrixof(result));
		if (error) return;
		moveresult(st,result);
	}
	else wrong_arg();
}

void mcomplex (header *hd)
{	header *st=hd,*result;
	double *m,*mr;
	LONG i,n;
	int c,r;
	hd=getvalue(hd);
	if (hd->type==s_matrix)
	{	getmatrix(hd,&r,&c,&m);
		result=new_cmatrix(r,c,""); if (error) return;
		n=(LONG)r*c;
        mr=matrixof(result)+(LONG)2*(n-1);
		m+=n-1;
		for (i=0; i<n; i++)
		{	*mr=*m--; *(mr+1)=0.0; mr-=2;
		}
		moveresult(st,result);
	}
	else if (hd->type==s_real)
	{	result=new_complex(*realof(hd),0.0,""); if (error) return;
		moveresult(st,result);
	}
}

void msum (header *hd)
{	header *st=hd,*result;
	int c,r,i,j;
	double *m,*mr,s,si;
	hd=getvalue(hd); if (error) return;
	if (hd->type==s_real || hd->type==s_matrix)
	{	getmatrix(hd,&r,&c,&m);
		result=new_matrix(r,1,""); if (error) return;
		mr=matrixof(result);
		for (i=0; i<r; i++) 
		{	s=0.0;
			for (j=0; j<c; j++) s+=*m++;
			*mr++=s;
		}
	}
	else if (hd->type==s_complex || hd->type==s_cmatrix)
	{	getmatrix(hd,&r,&c,&m);
		result=new_cmatrix(r,1,""); if (error) return;
		mr=matrixof(result);
		for (i=0; i<r; i++) 
		{	s=0.0; si=0.0;
			for (j=0; j<c; j++) { s+=*m++; si+=*m++; }
			*mr++=s; *mr++=si;
		}
	}
	else wrong_arg();
	moveresult(st,result);
}

void mprod (header *hd)
{	header *st=hd,*result;
	int c,r,i,j;
	double *m,*mr,s,si,h,hi;
	hd=getvalue(hd); if (error) return;
	if (hd->type==s_real || hd->type==s_matrix)
	{	getmatrix(hd,&r,&c,&m);
		result=new_matrix(r,1,""); if (error) return;
		mr=matrixof(result);
		for (i=0; i<r; i++) 
		{	s=1.0;
			for (j=0; j<c; j++) s*=*m++;
			*mr++=s;
		}
	}
	else if (hd->type==s_complex || hd->type==s_cmatrix)
	{	getmatrix(hd,&r,&c,&m);
		result=new_cmatrix(r,1,""); if (error) return;
		mr=matrixof(result);
		for (i=0; i<r; i++) 
		{	s=1.0;
			for (j=0; j<c; j++) 
			{	complex_multiply(&s,&si,m,m+1,&h,&hi);
				s=h; si=hi; m+=2; 
			}
			*mr++=s; *mr++=si;
		}
	}
	else wrong_arg();
	moveresult(st,result);
}

void msize (header *hd)
{	header *result,*st=hd,*hd1=hd,*end=(header *)newram;
	int r,c,r0=0,c0=0;
	if (!hd) wrong_arg();
	result=new_matrix(1,2,""); if (error) return;
	while (end>hd)
	{	hd1=getvariable(hd); if (error) return;
		if (hd1->type==s_matrix || hd1->type==s_cmatrix)
		{	r=dimsof(hd1)->r;
			c=dimsof(hd1)->c;
		}
		else if (hd1->type==s_real || hd1->type==s_complex)
		{	r=c=1;
		}
		else if (hd1->type==s_submatrix || hd1->type==s_csubmatrix)
		{	r=submdimsof(hd1)->r;
			c=submdimsof(hd1)->c;
		}
		else wrong_arg();
		if ((r>1 || c>1) && (r0>1 || c0>1))
		{	if (r0!=r && c0!=c)
			{	output("Matrix dimensions must agree!\n");
				error=1021; return;
			}
		}
		else
		{	r0=(r0>r)?r0:r; c0=(c0>c)?c0:c;
		}
        hd=nextof(hd);
	}
	*matrixof(result)=r0;
	*(matrixof(result)+1)=c0;
	moveresult(st,result);
}

void mcols (header *hd)
{	header *st=hd,*res;
	int n;
	hd=getvalue(hd); if (error) return;
	switch (hd->type)
	{	case s_matrix :
		case s_cmatrix : n=dimsof(hd)->c; break;
		case s_submatrix :
		case s_csubmatrix : n=submdimsof(hd)->c; break;
		case s_real :
		case s_complex : n=1; break;
		case s_string : n=(int)strlen(stringof(hd)); break;
		default : wrong_arg();
	}
	res=new_real(n,""); if (error) return;
	moveresult(st,res);
}

void mrows (header *hd)
{	header *st=hd,*res;
	int n;
	hd=getvalue(hd); if (error) return;
	switch (hd->type)
	{	case s_matrix :
		case s_cmatrix : n=dimsof(hd)->r; break;
		case s_submatrix :
		case s_csubmatrix : n=submdimsof(hd)->r; break;
		case s_real :
		case s_complex : n=1; break;
		default : wrong_arg();
	}
	res=new_real(n,""); if (error) return;
	moveresult(st,res);
}

void mzerosmat (header *hd)
{	header *result,*st=hd;
	double rows,cols,*m;
	int r,c;
	LONG i,n;
	hd=getvalue(hd); if (error) return;
	if (hd->type!=s_matrix || dimsof(hd)->r!=1 || dimsof(hd)->c!=2)
		wrong_arg();
	rows=*matrixof(hd); cols=*(matrixof(hd)+1);
	if (rows<0 || rows>=INT_MAX || cols<0 || cols>=INT_MAX)
		wrong_arg();
	r=(int)rows; c=(int)cols;
	result=new_matrix(r,c,""); if (error) return;
	m=matrixof(result);
	n=c*r;
	for (i=0; i<n; i++) *m++=0.0;
	moveresult(st,result);
}

void mones (header *hd)
{	header *result,*st=hd;
	double rows,cols,*m;
	int r,c;
	LONG i,n;
	hd=getvalue(hd); if (error) return;
	if (hd->type!=s_matrix || dimsof(hd)->r!=1 || dimsof(hd)->c!=2)
		wrong_arg();
	rows=*matrixof(hd); cols=*(matrixof(hd)+1);
	if (rows<0 || rows>=INT_MAX || cols<0 || cols>=INT_MAX)
		wrong_arg();
	r=(int)rows; c=(int)cols;
	result=new_matrix(r,c,""); if (error) return;
	m=matrixof(result);
	n=c*r;
	for (i=0; i<n; i++) *m++=1.0;
	moveresult(st,result);
}

void mdiag (header *hd)
{	header *result,*st=hd,*hd1,*hd2=0;
	double rows,cols,*m,*md;
	int r,c,i,ik=0,k,rd,cd;
	LONG l,n;
	hd=getvalue(hd); if (error) return;
	if (hd->type!=s_matrix || dimsof(hd)->r!=1 || dimsof(hd)->c!=2)
		wrong_arg();
	rows=*matrixof(hd); cols=*(matrixof(hd)+1);
	if (rows<0 || rows>=INT_MAX || cols<0 || cols>=INT_MAX)
		wrong_arg();
	r=(int)rows; c=(int)cols;
	hd1=next_param(st); if (hd1) hd2=next_param(hd1);
	if (hd1) hd1=getvalue(hd1);
	if (hd2) hd2=getvalue(hd2);
	if (error) return;
	if	(hd1->type!=s_real) wrong_arg();
	k=(int)*realof(hd1);
	if (hd2->type==s_matrix || hd2->type==s_real)
	{	result=new_matrix(r,c,""); if (error) return;
		m=matrixof(result);
		n=(LONG)c*r;
		for (l=0; l<n; l++) *m++=0.0;
		getmatrix(hd2,&rd,&cd,&md);
		if (rd!=1 || cd<1) wrong_arg();
		m=matrixof(result);
		for (i=0; i<r; i++)
		{	if (i+k>=0 && i+k<c) 
			{	*mat(m,c,i,i+k)=*md;
				ik++; if (ik<cd) md++;
			}
		}
	}
	else if (hd2->type==s_cmatrix || hd2->type==s_complex)
	{	result=new_cmatrix(r,c,""); if (error) return;
		m=matrixof(result);
        n=(LONG)2*(LONG)c*r;
		for (l=0; l<n; l++) *m++=0.0;
		getmatrix(hd2,&rd,&cd,&md);
		if (rd!=1 || cd<1) wrong_arg();
		m=matrixof(result);
		for (i=0; i<r; i++)
		{	if (i+k>=0 && i+k<c) 
			{	*cmat(m,c,i,i+k)=*md;
				*(cmat(m,c,i,i+k)+1)=*(md+1);
				ik++; if (ik<cd) md+=2;
			}
		}
	}
	else wrong_arg();
	moveresult(st,result);
}

void msetdiag (header *hd)
{	header *result,*st=hd,*hd1,*hd2=0;
	double *m,*md,*mhd;
	int r,c,i,ik=0,k,rd,cd;
	hd=getvalue(st); if (error) return;
	if (hd->type!=s_matrix && hd->type!=s_cmatrix)
		wrong_arg();
	getmatrix(hd,&c,&r,&mhd);
	hd1=next_param(st); if (hd1) hd2=next_param(hd1);
	if (hd1) hd1=getvalue(hd1);
	if (hd2) hd2=getvalue(hd2);
	if (error) return;
	if	(hd1->type!=s_real) wrong_arg();
	k=(int)*realof(hd1);
	if (hd->type==s_matrix && 
			(hd2->type==s_complex || hd2->type==s_cmatrix))
		{	make_complex(st); msetdiag(st); return;
		}
	else if (hd->type==s_cmatrix &&
			(hd2->type==s_real || hd2->type==s_matrix))
		{	make_complex(nextof(nextof(st))); msetdiag(st); return;
		}
	if (hd->type==s_matrix)
	{	result=new_matrix(r,c,""); if (error) return;
		m=matrixof(result);
		memmove((char *)m,(char *)mhd,(LONG)c*r*sizeof(double));
		getmatrix(hd2,&rd,&cd,&md);
		if (rd!=1 || cd<1) wrong_arg();
		for (i=0; i<r; i++)
		{	if (i+k>=0 && i+k<c) 
			{	*mat(m,c,i,i+k)=*md;
				ik++; if (ik<cd) md++;
			}
		}
	}
	else if (hd->type==s_cmatrix)
	{	result=new_cmatrix(r,c,""); if (error) return;
		m=matrixof(result);
        memmove((char *)m,(char *)mhd,(LONG)c*r*(LONG)2*sizeof(double));
		getmatrix(hd2,&rd,&cd,&md);
		if (rd!=1 || cd<1) wrong_arg();
		m=matrixof(result);
		for (i=0; i<r; i++)
		{	if (i+k>=0 && i+k<c) 
			{	*cmat(m,c,i,i+k)=*md;
				*(cmat(m,c,i,i+k)+1)=*(md+1);
				ik++; if (ik<cd) md+=2;
			}
		}
	}
	else wrong_arg();
	moveresult(st,result);
}

void mextrema (header *hd)
{	header *result,*st=hd;
	double x,*m,*mr,min,max;
	int r,c,i,j,imin,imax;
	hd=getvalue(hd); if (error) return;
	if (hd->type==s_real || hd->type==s_matrix)
	{	getmatrix(hd,&r,&c,&m);
		result=new_matrix(r,4,""); if (error) return;
		mr=matrixof(result);
		for (i=0; i<r; i++) 
		{	min=max=*m; imin=imax=0; m++;
			for (j=1; j<c; j++) 
			{	x=*m++;
				if (x<min) { min=x; imin=j; }
				if (x>max) { max=x; imax=j; }
			}
			*mr++=min; *mr++=imin+1; *mr++=max; *mr++=imax+1;
		}
	}
	else wrong_arg();
	moveresult(st,result);
}

void mcumsum (header *hd)
{	header *result,*st=hd;
	double *m,*mr,sum=0,sumr=0,sumi=0;
	int r,c,i,j;
	hd=getvalue(hd); if (error) return;
	if (hd->type==s_real || hd->type==s_matrix)
	{	getmatrix(hd,&r,&c,&m);
		if (c<1) result=new_matrix(r,1,"");
		else result=new_matrix(r,c,"");
		if (error) return;
		mr=matrixof(result);
		for (i=0; i<r; i++) 
		{	if (c>=1) sum=*m++;
			*mr++=sum;
			for (j=1; j<c; j++) 
			{	sum+=*m++;
				*mr++=sum;
			}
		}
	}
	else if (hd->type==s_complex || hd->type==s_cmatrix)
	{	getmatrix(hd,&r,&c,&m);
		if (c<1) result=new_cmatrix(r,1,"");
		else result=new_cmatrix(r,c,"");
		if (error) return;
		mr=matrixof(result);
		for (i=0; i<r; i++) 
		{	if (c>=1) { sumr=*m++; sumi=*m++; }
			*mr++=sumr; *mr++=sumi;
			for (j=1; j<c; j++) 
			{	sumr+=*m++; *mr++=sumr;
				sumi+=*m++; *mr++=sumi;
			}
		}
	}
	else wrong_arg();
	moveresult(st,result);
}

void mcumprod (header *hd)
{	header *result,*st=hd;
	double *m,*mr,sum=1,sumi=1,sumr=0;
	int r,c,i,j;
	hd=getvalue(hd); if (error) return;
	if (hd->type==s_real || hd->type==s_matrix)
	{	getmatrix(hd,&r,&c,&m);
		if (c<1) result=new_matrix(r,1,"");
		else result=new_matrix(r,c,"");
		if (error) return;
		mr=matrixof(result);
		for (i=0; i<r; i++) 
		{	if (c>=1) sum=*m++; 
			*mr++=sum;
			for (j=1; j<c; j++) 
			{	sum*=*m++;
				*mr++=sum;
			}
		}
	}
	else if (hd->type==s_complex || hd->type==s_cmatrix)
	{	getmatrix(hd,&r,&c,&m);
		if (c<1) result=new_cmatrix(r,1,"");
		else result=new_cmatrix(r,c,"");
		if (error) return;
		mr=matrixof(result);
		for (i=0; i<r; i++) 
		{	if (c>=1) { sumr=*m++; sumi=*m++; }
			*mr++=sumr; *mr++=sumi;
			for (j=1; j<c; j++)
			{	sum=sumr*(*m)-sumi*(*(m+1));
				sumi=sumr*(*(m+1))+sumi*(*m);
				sumr=sum;
				m+=2;
				*mr++=sumr;
				*mr++=sumi;
			}
		}
	}
	else wrong_arg();
	moveresult(st,result);
}

void mwait (header *hd)
{	header *st=hd,*result;
	double now;
	int h;
	hd=getvalue(hd); if (error) return;
	if (hd->type!=s_real) wrong_arg();
	now=myclock();
	sys_wait(*realof(hd),&h);
	if (h==escape) { error=1; return; }
	result=new_real(myclock()-now,"");
	if (error) return;
	moveresult(st,result);
}

void mkey (header *hd)
{	int scan;
	wait_key(&scan);
	new_real(scan,"");
}

void mformat (header *hd)
{	header *st=hd,*result;
	static int l=10,d=5;
	int oldl=l,oldd=d;
	hd=getvalue(hd); if (error) return;
	if (hd->type!=s_matrix || dimsof(hd)->r!=1 || dimsof(hd)->c!=2)
		wrong_arg();
	l=(int)*matrixof(hd); d=(int)*(matrixof(hd)+1);
	if (l<2 || l>2*DBL_DIG || d<0 || d>DBL_DIG) wrong_arg();
	if (d>l-3) d=l-3;
	sprintf(fixedformat," %c%d.%df",'%',l,d);
	sprintf(expoformat," %c%d.%de",'%',l,(l>9)?l-9:0);
	minexpo=pow(10,-d);
	maxexpo=pow(10,(l-d-3>DBL_DIG-d-1)?DBL_DIG-d-1:l-d-3)-1;
	fieldw=l+2;
	linew=linelength/fieldw;
	result=new_matrix(1,2,""); if (error) return;
	*matrixof(result)=oldl;
	*(matrixof(result)+1)=oldd;
	moveresult(st,result);
}

void mrandom (header *hd)
{	header *st=hd,*result;
	double *m;
	int r,c;
	LONG k,n;
	hd=getvalue(hd); if (error) return;
	if (hd->type!=s_matrix || dimsof(hd)->r!=1 || dimsof(hd)->c!=2
		|| *(m=matrixof(hd))<0 || *m>=INT_MAX 
		|| *(m+1)<0 || *(m+1)>INT_MAX)
		wrong_arg();
	r=(int)*m;
	c=(int)*(m+1);
	result=new_matrix(r,c,""); if (error) return;
	m=matrixof(result);
	n=(LONG)c*r;
	for (k=0; k<n; k++) *m++=(double)rand()/(double)RAND_MAX;
	moveresult(st,result);
}

void mnormal (header *hd)
{	header *st=hd,*result;
	double *m,r1,r2;
	int r,c;
	LONG k,n;
	hd=getvalue(hd); if (error) return;
	if (hd->type!=s_matrix || dimsof(hd)->r!=1 || dimsof(hd)->c!=2
		|| *(m=matrixof(hd))<0 || *m>=INT_MAX 
		|| *(m+1)<0 || *(m+1)>INT_MAX)
		wrong_arg();
	r=(int)*m;
	c=(int)*(m+1);
	result=new_matrix(r,c,""); if (error) return;
	m=matrixof(result);
	n=(LONG)c*r;
	for (k=0; k<n; k++) 
	{	r1=(double)rand()/(double)RAND_MAX;
		if (r1==0.0) *m++=0.0;
		else
		{	r2=(double)rand()/(double)RAND_MAX;
			*m++=sqrt(-2*log(r1))*cos(2*M_PI*r2);
		}
	}
	moveresult(st,result);
}

double gauss (double z)
{	double x,w;
	x=1/(0.2316419*fabs(z)+1);
	w=x*(0.31938153+x*(-0.356556382+x*(1.781477937+x*(
		-1.821255978+x*1.330274429))));
	w=w*exp(-z*z/2)/sqrt(2*M_PI);
	if (z<0) return w;
	else return 1-w;
}

void mgauss (header *hd)
{	spread1(gauss,0,hd);
}

double invgauss (double a)
{	double t,c,d;
	int flag=0;
	if (a<0.5) { a=1-a; flag=1; }
	t=sqrt(-2*log(fabs(1-a)));
	c=2.515517+t*(0.802853+t*0.010328);
	d=1+t*(1.432788+t*(0.189269+t*0.001308));
	if (flag) return (c/d-t);
	else return t-c/d;
}

void minvgauss (header *hd)
{	spread1(invgauss,0,hd);
}

double rfak (double x)
{	int i,n;
	double res=1;
	if (x<2 || x>INT_MAX) return 1.0;
	n=(int)x;
	for (i=2; i<=n; i++) res=res*i;
	return res;
}

void mfak (header *hd)
{	spread1(rfak,0,hd);
}

void rbin (double *x, double *y, double *z)
{   long i,n,m,k;
	double res;
	n=(long)*x; m=(long)*y;
	if (m<=0) *z=1.0;
	else
	{	res=k=(n-m+1);
		for (i=2; i<=m; i++) { k++; res=(res*k)/i; }
		*z=res;
	}
}

void mbin (header *hd)
{	spread2(rbin,0,hd);
}

void rtd (double *xa, double *yf, double *zres)
{	double t,t1,a,b,h,z,p,y,x;
	int flag=0;
	if (fabs(*xa)<epsilon) { *zres=0.5; return; }
	if (*xa<0) flag=1;
	t=*xa * *xa;
	if (t>=1) { a=1; b=*yf; t1=t; }
	else { a=*yf; b=1; t1=1/t; }
	y=2/(9*a); z=2/(9*b);
	h=pow(t1,1.0/3);
	x=fabs((1-z)*h-1+y)/sqrt(z*h*h+y);
	if (b<4) x=x*(1+0.08*x*x*x*x/(b*b*b));
	h=1+x*(0.196854+x*(0.115194+x*(0.000344+x*0.019527)));
	p=0.5/(h*h*h*h);
	if (t<0.5) *zres=p/2+0.5;
	else *zres=1-p/2;
	if (flag) *zres=1-*zres;
}

void mtd (header *hd)
{	spread2(rtd,0,hd);
}

void invrtd (double *x, double *y, double *zres)
{	double z=*x,f=*y,g1,g2,g3,g4,z2;
	int flag=0;
	if (z<0.5) { flag=1; z=1-z; }
	z=invgauss(z);
	z2=z*z;
	g1=z*(1+z2)/4.0;
	g2=z*(3+z2*(16+5*z2))/96.0;
	g3=z*(-15+z2*(17+z2*(19+z2*3)))/384.0;
	g4=z*(-945+z2*(-1920+z2*(1482+z2*(776+z2*79))))/92160.0;
	*zres=(((g4/f+g3)/f+g2)/f+g1)/f+z;
	if (flag) *zres=-*zres;
}

void minvtd (header *hd)
{	spread2(invrtd,0,hd);
}

void chi (double *xa, double *yf, double *zres)
{	double ch=*xa,x,y,s,t,g,j=1;
	long i=1,p,f;
	f=(long)*yf;
	if (ch<epsilon) { *zres=0.0; return; }
	p=(f+1)/2;
	for (i=f; i>=2; i-=2) j=j*i;
	x=pow(ch,p)*exp(-(ch/2))/j;
	if (f%2==0) y=1;
	else y=sqrt(2/(ch*M_PI));
	s=1; t=1; g=f;
	while (t>1e-9)
	{	g=g+2;
		t=t*ch/g;
		s=s+t;
	}
	*zres=x*y*s;
}

void mchi (header *hd)
{	spread2(chi,0,hd);
}

double f1,f2;

double rfd (double F)
{	double f0,a,b,h,z,p,y,x;
	if (F<epsilon) return 0.0;
	if (F<1) { a=f2; b=f1; f0=1/F; }
	else { a=f1; b=f2; f0=F; }
	y=2/(9*a); z=2/(9*b);
	h=pow(f0,1.0/3);
	x=fabs((1-z)*h-1+y)/sqrt(z*h*h+y);
	if (b<4) x=x*(1+0.08*x*x*x*x/(b*b*b));
	h=1+x*(0.196854+x*(0.115194+x*(0.000344+x*0.019527)));
	p=0.5/(h*h*h*h);
	if (F>=1) return 1-p;
	else return p;
}

void mfdis (header *hd)
{	header *st=hd,*hd1,*hd2=0;
	hd1=next_param(st);
	if (hd1)
	{	hd2=next_param(hd1);
		hd1=getvalue(hd1);
	}
	if (hd2) hd2=getvalue(hd2);
	if (error) return;
	if (hd1->type!=s_real || hd2->type!=s_real) wrong_arg();
	f1=*realof(hd1);
	f2=*realof(hd2);
	spread1(rfd,0,hd);
}

void rmax (double *x, double *y, double *z)
{	if (*x>*y) *z=*x;
	else *z=*y;
}

void mmax (header *hd)
{	spread2(rmax,0,hd);
}

void rmin (double *x, double *y, double *z)
{	if (*x>*y) *z=*y;
	else *z=*x;
}

void mmin (header *hd)
{	spread2(rmin,0,hd);
}

typedef struct { double val; int ind; } sorttyp;

int sorttyp_compare (const sorttyp *x, const sorttyp *y)
{	if (x->val>y->val) return 1;
	else if (x->val==y->val) return 0;
	else return -1;
}

void msort (header *hd)
{	header *st=hd,*result,*result1;
	double *m,*m1;
	sorttyp *t;
	int r,c,i;
	hd=getvalue(hd); if (error) return;
	if (hd->type!=s_real && hd->type!=s_matrix) wrong_arg();
	getmatrix(hd,&r,&c,&m);
	if (c==1 || r==1) result=new_matrix(r,c,"");
	else wrong_arg();
	if (error) return;
	result1=new_matrix(r,c,"");
	if (error) return;
	if (c==1) c=r;
	if (c==0) wrong_arg();
	if (newram+c*sizeof(sorttyp)>ramend)
	{	output("Out of memory!\n"); error=600; return; 
	}
	t=(sorttyp *)newram;
	for (i=0; i<c; i++)
	{	t->val=*m++; t->ind=i; t++;
	}
	qsort(newram,c,sizeof(sorttyp),
		(int (*) (const void *, const void *))sorttyp_compare);
	m=matrixof(result); m1=matrixof(result1);
	t=(sorttyp *)newram;
	for (i=0; i<c; i++)
	{	*m++=t->val; *m1++=t->ind+1; t++;
	}
	moveresult(st,result);
	moveresult(nextof(st),result1);
}

void mnonzeros (header *hd)
{	header *st=hd,*result;
	double *m,*mr;
	int r,c,i,k;
	hd=getvalue(hd); if (error) return;
	if (hd->type!=s_real && hd->type!=s_matrix) wrong_arg();
	getmatrix(hd,&r,&c,&m);
	if (r!=1 && c!=1) wrong_arg();
	if (c==1) c=r;
	result=new_matrix(1,c,""); if (error) return;
	k=0; mr=matrixof(result);
	for (i=0; i<c; i++)
	{	if (*m++!=0.0)
		{	*mr++=i+1; k++;
		}
	}
	dimsof(result)->c=k;
	result->size=matrixsize(1,k);
	moveresult(st,result);
}

void mstatistics (header *hd)
{	header *st=hd,*hd1,*result;
	int i,n,r,c,k;
	double *m,*mr;
	hd=getvalue(hd);
	hd1=next_param(st);
	if (hd1) hd1=getvalue(hd1); if (error) return;
	if (hd1->type!=s_real || hd->type!=s_matrix) wrong_arg();
	if (*realof(hd1)>INT_MAX || *realof(hd1)<2) wrong_arg();
	n=(int)*realof(hd1);
	getmatrix(hd,&r,&c,&m);
	if (r!=1 && c!=1) wrong_arg();
	if (c==1) c=r;
	result=new_matrix(1,n,""); if (error) return;
	mr=matrixof(result); for (i=0; i<n; i++) *mr++=0.0;
	mr=matrixof(result);
	for (i=0; i<c; i++)
	{	if (*m>=0 && *m<n)
		{	k=floor(*m);
			mr[k]+=1.0;
		}
		m++;
	}
	moveresult(st,result);
}

void minput (header *hd)
{	header *st=hd,*result;
	char input[1024],*oldnext;
	hd=getvalue(hd); if (error) return;
	if (hd->type!=s_string) wrong_arg();
	retry: output(stringof(hd)); output("? ");
	edit(input);
	stringon=1;
	oldnext=next; next=input; result=scan_value(); next=oldnext;
	stringon=0;
	if (error) 
	{	output("Error in input!\n"); error=0; goto retry;
	}
	moveresult(st,result);
}

void mlineinput (header *hd)
{	header *st=hd,*result;
	char input[1024];
	hd=getvalue(hd); if (error) return;
	if (hd->type!=s_string) wrong_arg();
	output(stringof(hd)); output("? ");
	edit(input);
	result=new_string(input,strlen(input),"");
	moveresult(st,result);
}

void minterpret (header *hd)
{	header *st=hd,*result;
	char *oldnext;
	hd=getvalue(hd); if (error) return;
	if (hd->type!=s_string) wrong_arg();
	stringon=1;
	oldnext=next; next=stringof(hd); result=scan(); next=oldnext;
	stringon=0;
	if (error) { result=new_string("Syntax error!",5,""); error=0; }
	moveresult(st,result);
}

void mmax1 (header *hd)
{	header *result,*st=hd;
	double x,*m,*mr,max;
	int r,c,i,j;
	hd=getvalue(hd); if (error) return;
	if (hd->type==s_real || hd->type==s_matrix)
	{	getmatrix(hd,&r,&c,&m);
		result=new_matrix(r,1,""); if (error) return;
		mr=matrixof(result);
		for (i=0; i<r; i++) 
		{	max=*m; m++;
			for (j=1; j<c; j++) 
			{	x=*m++;
				if (x>max) max=x;
			}
			*mr++=max;
		}
	}
	else wrong_arg();
	moveresult(st,result);
}

void mmin1 (header *hd)
{	header *result,*st=hd;
	double x,*m,*mr,max;
	int r,c,i,j;
	hd=getvalue(hd); if (error) return;
	if (hd->type==s_real || hd->type==s_matrix)
	{	getmatrix(hd,&r,&c,&m);
		result=new_matrix(r,1,""); if (error) return;
		mr=matrixof(result);
		for (i=0; i<r; i++) 
		{	max=*m; m++;
			for (j=1; j<c; j++) 
			{	x=*m++;
				if (x<max) max=x;
			}
			*mr++=max;
		}
	}
	else wrong_arg();
	moveresult(st,result);
}

void make_xors (void)
{	int i;
	for (i=0; i<10; i++) xors[i]=xor(argname[i]);
}

void mdo (header *hd)
{	header *st=hd,*hd1,*result;
	int count=0;
	size_t size;
	if (!hd) wrong_arg();
	hd=getvalue(hd);
	result=hd1=next_param(st);
	if (hd->type!=s_string) wrong_arg();
	if (error) return;
	hd=searchudf(stringof(hd));
	if (!hd || hd->type!=s_udf) wrong_arg();
	while (hd1) 
	{	strcpy(hd1->name,argname[count]);
		hd1->xor=xors[count];
		hd1=next_param(hd1); count++; 
	}
	if (result)
	{	size=(char *)result-(char *)st;
		if (size>0 && newram!=(char *)result) 
			memmove((char *)st,(char *)result,newram-(char *)result);
		newram-=size;
	}
	interpret_udf(hd,st,count);
}

void mlu (header *hd)
{	header *st=hd,*result,*res1,*res2,*res3;
	double *m,*mr,*m1,*m2,det,deti;
	int r,c,*rows,*cols,rank,i;
	hd=getvalue(hd); if (error) return;
	if (hd->type==s_matrix || hd->type==s_real)
	{	getmatrix(hd,&r,&c,&m);
		if (r<1) wrong_arg();
		result=new_matrix(r,c,""); if (error) return;
		mr=matrixof(result);
		memmove((char *)mr,(char *)m,(LONG)r*c*sizeof(double));
		make_lu(mr,r,c,&rows,&cols,&rank,&det); if (error) return;
		res1=new_matrix(1,rank,""); if (error) return;
		res2=new_matrix(1,c,""); if (error) return;
		res3=new_real(det,""); if (error) return;
		m1=matrixof(res1);
		for (i=0; i<rank; i++)
		{	*m1++=*rows+1;
			rows++;
		}
		m2=matrixof(res2);
		for (i=0; i<c; i++)
		{	*m2++=*cols++;
		}
		moveresult(st,getvalue(result)); st=nextof(st);
		moveresult(st,getvalue(res1)); st=nextof(st);
		moveresult(st,getvalue(res2)); st=nextof(st);
		moveresult(st,getvalue(res3));
	}
	else if (hd->type==s_cmatrix || hd->type==s_complex)
	{	getmatrix(hd,&r,&c,&m);
		if (r<1) wrong_arg();
		result=new_cmatrix(r,c,""); if (error) return;
		mr=matrixof(result);
        memmove((char *)mr,(char *)m,(LONG)r*c*(LONG)2*sizeof(double));
		cmake_lu(mr,r,c,&rows,&cols,&rank,&det,&deti); 
			if (error) return;
		res1=new_matrix(1,rank,""); if (error) return;
		res2=new_matrix(1,c,""); if (error) return;
		res3=new_complex(det,deti,""); if (error) return;
		m1=matrixof(res1);
		for (i=0; i<rank; i++)
		{	*m1++=*rows+1;
			rows++;
		}
		m2=matrixof(res2);
		for (i=0; i<c; i++)
		{	*m2++=*cols++;
		}
		moveresult(st,getvalue(result)); st=nextof(st);
		moveresult(st,getvalue(res1)); st=nextof(st);
		moveresult(st,getvalue(res2)); st=nextof(st);
		moveresult(st,getvalue(res3));
	}
	else wrong_arg();
}

void miscomplex (header *hd)
{	header *st=hd,*result;
	hd=getvalue(hd);
	if (hd->type==s_complex || hd->type==s_cmatrix)
		result=new_real(1.0,"");
	else result=new_real(0.0,"");
	if (error) return;
	moveresult(st,result);
}

void misreal (header *hd)
{	header *st=hd,*result;
	hd=getvalue(hd); if (error) return;
	if (hd->type==s_real || hd->type==s_matrix)
		result=new_real(1.0,"");
	else result=new_real(0.0,"");
	if (error) return;
	moveresult(st,result);
}

double rounder;

double rround (double x)
{	x*=rounder;
	if (x>0) x=floor(x+0.5);
	else x=-floor(-x+0.5);
	return x/rounder;
}

void cround (double *x, double *xi, double *z, double *zi)
{	*z=rround(*x);
	*zi=rround(*xi);
}

double frounder[]={1.0,10.0,100.0,1000.0,10000.0,100000.0,1000000.0,
10000000.0,100000000.0,1000000000.0,10000000000.0};

void mround (header *hd)
{	header *hd1;
	int n;
	hd1=next_param(hd);
	if (hd1) hd1=getvalue(hd1); if (error) return;
	if (hd1->type!=s_real) wrong_arg();
	n=(int)(*realof(hd1));
	if (n>0 && n<11) rounder=frounder[n];
	else rounder=pow(10.0,n);
	spread1(rround,cround,hd);
}

void mchar (header *hd)
{	header *st=hd,*result;
	hd=getvalue(hd); if (error) return;
	if (hd->type!=s_real) wrong_arg();
	result=new_string("a",1,""); if (error) return;
	*stringof(result)=(char)*realof(hd);
	moveresult(st,result);
}

void merror (header *hd)
{	hd=getvalue(hd); if (error) return;
	if (hd->type!=s_string) wrong_arg();
	output1("Error : %s\n",stringof(hd));
	error=301;
}

void merrlevel (header *hd)
{	header *st=hd,*res;
	char *oldnext;
	int en;
	hd=getvalue(hd); if (error) return;
	if (hd->type!=s_string) wrong_arg();
	stringon=1;
	oldnext=next; next=stringof(hd); scan(); next=oldnext;
	stringon=0;
	en=error; error=0;
	res=new_real(en,""); if (error) return;
	moveresult(st,res);
}

void mprintf (header *hd)
{	header *st=hd,*hd1,*result;
	char string[1024];
	hd1=next_param(hd);
	hd=getvalue(hd);
	hd1=getvalue(hd1); if (error) return;
	if (hd->type!=s_string || hd1->type!=s_real)
		wrong_arg();
	sprintf(string,stringof(hd),*realof(hd1));
	result=new_string(string,strlen(string),""); if (error) return;
	moveresult(st,result);
}

void msetkey (header *hd)
/*****
	set a function key
*****/
{	header *st=hd,*hd1,*result;
	char *p;
	int n;
	hd=getvalue(hd); if (error) return;
	hd1=nextof(st); hd1=getvalue(hd1); if (error) return;
	if (hd->type!=s_real || hd1->type!=s_string) wrong_arg();
	n=(int)(*realof(hd))-1; p=stringof(hd1);
	if (n<0 || n>=10 || strlen(p)>63) wrong_arg();
	result=new_string(fktext[n],strlen(fktext[n]),"");
	if (error) return;
	strcpy(fktext[n],p);
	moveresult(st,result);
}

void many (header *hd)
{	header *st=hd,*result;
	int c,r,res=0;
	LONG i,n;
	double *m;
	hd=getvalue(hd); if (error) return;
	if (hd->type==s_real || hd->type==s_matrix)
	{	getmatrix(hd,&r,&c,&m);
		n=(LONG)(c)*r;
	}
	else if (hd->type==s_complex || hd->type==s_cmatrix)
	{	getmatrix(hd,&r,&c,&m);
        n=(LONG)2*(LONG)(c)*r;
	}
	else wrong_arg();
	for (i=0; i<n; i++)
		if (*m++!=0.0) { res=1; break; }
	result=new_real(res,""); if (error) return;
	moveresult(st,result);
}

void mcd (header *hd)
{	header *st=hd,*result;
	char *path;
	hd=getvalue(hd); if (error) return;
	if (hd->type!=s_string) wrong_arg();
	path=cd(stringof(hd));
	result=new_string(path,strlen(path),"");
	moveresult(st,result);
}

void mdir (header *hd)
{	header *st=hd,*result;
	char *name;
	hd=getvalue(hd); if (error) return;
	if (hd->type!=s_string) wrong_arg();
	name=dir(stringof(hd));
	if (name) result=new_string(name,strlen(name),"");
	else result=new_string("",0,"");
	if (error) return;
	moveresult(st,result);
}

void margs (header *hd)
/* return all args from realof(hd)-st argument on */
{	header *st=hd,*hd1,*result;
	int i,n;
	size_t size;
	hd=getvalue(hd);
	if (hd->type!=s_real) wrong_arg();
	n=(int)*realof(hd);
	if (n<1) wrong_arg();
	if (n>actargn)
	{	newram=(char *)st; return;
	}
	result=(header *)startlocal; i=1;
	while (i<n && result<(header *)endlocal)
	{	result=nextof(result); i++;
	}
	hd1=result;
	while (i<actargn+1 && hd1<(header *)endlocal)
	{	hd1=nextof(hd1); i++;
	}
	size=(char *)hd1-(char *)result;
	if (size<=0)
	{	output("Error in args!\n"); error=2021; return;
	}
	memmove((char *)st,(char *)result,size);
	newram=(char *)st+size;
}

void mname (header *hd)
{	header *st=hd,*result;
	hd=getvalue(hd); if (error) return;
	result=new_string(hd->name,strlen(hd->name),"");
	moveresult(st,result);
}

void mdir0 (header *hd)
{	char *name;
	name=dir(0);
	if (name) new_string(name,strlen(name),"");
	else new_string("",0,"");
}

void mflipx (header *hd)
{	header *st=hd,*result;
	double *m,*mr,*mr1;
	int i,j,c,r;
	hd=getvalue(hd); if (error) return;
	if (hd->type==s_real || hd->type==s_complex)
	{	moveresult(st,hd); return;
	}
	else if (hd->type==s_matrix)
	{	getmatrix(hd,&r,&c,&m);
		result=new_matrix(r,c,""); if (error) return;
		mr=matrixof(result);
		for (i=0; i<r; i++)
		{	mr1=mr+(c-1);
			for (j=0; j<c; j++) *mr1--=*m++;
			mr+=c;
		}
	}
	else if (hd->type==s_cmatrix)
	{	getmatrix(hd,&r,&c,&m);
		result=new_cmatrix(r,c,""); if (error) return;
		mr=matrixof(result);
		for (i=0; i<r; i++)
		{	mr1=mr+(2l*(c-1)+1);
			for (j=0; j<c; j++)
			{	*mr1--=*m++; *mr1--=*m++;
			}
			mr+=2l*c;
		}
	}
	else wrong_arg();
	moveresult(st,result);
}

void mflipy (header *hd)
{	header *st=hd,*result;
	double *m,*mr;
	int i,c,r;
	hd=getvalue(hd); if (error) return;
	if (hd->type==s_real || hd->type==s_complex)
	{	moveresult(st,hd); return;
	}
	else if (hd->type==s_matrix)
	{	getmatrix(hd,&r,&c,&m);
		result=new_matrix(r,c,""); if (error) return;
		mr=matrixof(result);
		mr+=(long)(r-1)*c;
		for (i=0; i<r; i++)
		{	memmove((char *)mr,(char *)m,c*sizeof(double));
			m+=c; mr-=c;
		}
	}
	else if (hd->type==s_cmatrix)
	{	getmatrix(hd,&r,&c,&m);
		result=new_cmatrix(r,c,""); if (error) return;
		mr=matrixof(result);
		mr+=2l*(long)(r-1)*c;
		for (i=0; i<r; i++)
		{	memmove((char *)mr,(char *)m,2l*c*sizeof(double));
			m+=2l*c; mr-=2l*c;
		}
	}
	else wrong_arg();
	moveresult(st,result);
}

void mmatrix (header *hd)
{	header *st=hd,*hd1,*result;
	long i,n;
	double x,xi;
	double *m,*mr;
	int c,r,c1,r1;
	hd1=nextof(hd);
	hd=getvalue(hd);
	if (error) return;
	hd1=getvalue(hd1);
	if (error) return;
	if (hd->type==s_matrix)
	{	getmatrix(hd,&r,&c,&m);
		if (*m<0 || *m>INT_MAX || *(m+1)<0 || *(m+1)>INT_MAX)
			wrong_arg();
		r1=(int)*m; c1=(int)*(m+1);
		if (hd1->type==s_real)
		{	result=new_matrix(r1,c1,"");
			mr=matrixof(result);
			x=*realof(hd1);
			n=(long)c1*r1;
			for (i=0; i<n; i++) *mr++=x;
		}
		else if (hd1->type==s_complex)
		{	result=new_cmatrix(r1,c1,"");
			mr=matrixof(result);
			x=*realof(hd1); xi=*(realof(hd1)+1);
			n=(long)c1*r1;
			for (i=0; i<n; i++) 
			{	*mr++=x; *mr++=xi;
			}
		}
		else wrong_arg();
	}
	else wrong_arg();
	moveresult(st,result);
}

/*************** execute builtin functions ***********/

int builtin_count;

extern builtintyp builtin_list[];

void print_builtin (void)
{	int linel=0,i;
	for (i=0; i<builtin_count; i++)
	{	if (linel+strlen(builtin_list[i].name)+2>linelength)
			{ output("\n"); linel=0; }
		output1("%s ",builtin_list[i].name);
		linel+=(int)strlen(builtin_list[i].name)+1;
	}
	output("\n");
}

int builtin_compare (const builtintyp *p1, const builtintyp *p2)
{	int h;
	h=strcmp(p1->name,p2->name);
	if (h) return h;
	else 
	{	if (p1->nargs==-1 || p2->nargs==-1) return 0;
		else if (p1->nargs<p2->nargs) return -1; 
		else if (p1->nargs>p2->nargs) return 1;
		else return 0;
	}
}

void sort_builtin (void)
{	builtin_count=0;
	while (builtin_list[builtin_count].name) builtin_count++;
	qsort(builtin_list,builtin_count,sizeof(builtintyp),
		(int (*) (const void *, const void *))builtin_compare);
}

int exec_builtin (char *name, int nargs, header *hd)
{	builtintyp *b=builtin_list,h;
	h.name=name; h.nargs=nargs;
	b=bsearch(&h,builtin_list,builtin_count,sizeof(builtintyp),
		(int (*) (const void *, const void *))builtin_compare);
	if (b)
	{	if (nargs==0) hd=0;
		b->f(hd); return 1;
	}
	else return 0;
}

#ifndef SPLIT_MEM

typedef struct { size_t udfend,startlocal,endlocal,newram; }
	ptyp;

void mstore (header *hd)
{	FILE *file;
	ptyp p;
	hd=getvalue(hd); if (error) return;
	if (hd->type!=s_string)
	{	output("Expect file name.\n");
		error=1100; return;
	}
	p.udfend=udfend-ramstart;
	p.startlocal=startlocal-ramstart;
	p.endlocal=endlocal-ramstart;
	p.newram=newram-ramstart;
	file=fopen(stringof(hd),"wb");
	if (!file)
	{	output1("Could not open %s.\n",stringof(hd));
		error=1101; return;
	}
	fwrite(&p,sizeof(ptyp),1,file);
	fwrite(ramstart,1,newram-ramstart,file);
	if (ferror(file))
	{	output("Write error.\n");
		error=1102; return;
	}
	fclose(file);
}
	
void mrestore (header *hd)
{	FILE *file;
	ptyp p;
	hd=getvalue(hd); if (error) return;
	if (hd->type!=s_string)
	{	output("Expect file name.\n");
		error=1100; return;
	}
	file=fopen(stringof(hd),"rb");
	if (!file)
	{	output1("Could not open %s.\n",stringof(hd));
		error=1103; return;
	}
	fread(&p,sizeof(ptyp),1,file);
	if (ferror(file))
	{	output("Read error.\n");
		error=1104; return;
	}
	fread(ramstart,1,p.newram,file);
	if (ferror(file))
	{	output("Read error (fatal for EULER).\n");
		error=1104; return;
	}
	fclose(file);
	udfend=ramstart+p.udfend;
	startlocal=ramstart+p.startlocal;
	endlocal=ramstart+p.endlocal;
	newram=ramstart+p.newram;
}
	
#endif