#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <float.h>

#include "header.h"
#include "sysdep.h"
#include "matheh.h"

char *ram;
int *perm,*col,signdet,luflag=0;
double **lumat,*c,det;
complex **c_lumat,*c_c,c_det;
int rank;

#define outofram() { output("Out of Memory!\n"); error=120; return; }
#define wrong_arg() { output("Wrong arguments!\n"); error=1000; return; }

/***************** real linear systems *******************/

void lu (double *a, int n, int m)
/***** lu
	lu decomposition of a
*****/
{	int i,j,k,mm,j0,kh;
	double *d,piv,temp,*temp1,zmax,help;
	
	if (!luflag)
	{
		/* get place for result c and move a to c */
		c=(double *)ram;
		ram+=(LONG)n*m*sizeof(double);
		if (ram>ramend) outofram();
		memmove((char *)c,(char *)a,(LONG)n*m*sizeof(double));
	}
	else c=a;
		
	/* inititalize lumat */
	lumat=(double **)ram;
	ram+=(LONG)n*sizeof(double *);
	if (ram>ramend) outofram();
	d=c; 
	for (i=0; i<n; i++) { lumat[i]=d; d+=m; }
	
	/* get place for perm */
	perm=(int *)ram;
	ram+=(LONG)n*sizeof(int);
	if (ram>ramend) outofram();
	
	/* get place for col */
	col=(int *)ram;
	ram+=(LONG)m*sizeof(int);
	if (ram>ramend) outofram();
	
	/* d is a vector needed by the algorithm */
	d=(double *)ram;
	ram+=(LONG)n*sizeof(double);
	if (ram>ramend) outofram();
	
	/* gauss algorithm */
	if (!luflag)
		for (k=0; k<n; k++)
		{	perm[k]=k;
			for (zmax=0.0, j=0; j<m; j++)
				if ( (help=fabs(lumat[k][j])) >zmax) zmax=help;
			if (zmax==0.0) { error=130; return; }
			d[k]=zmax;
		}
	else
	{	for (k=0; k<n; k++) perm[k]=k;
	}
	signdet=1; rank=0; det=1.0; k=0;
	for (kh=0; kh<m; kh++)
	{	piv=luflag?fabs(lumat[k][kh]):(fabs(lumat[k][kh])/d[k]);
		j0=k;
		for (j=k+1; j<n; j++)
		{	temp=luflag?fabs(lumat[j][kh]):(fabs(lumat[j][kh])/d[j]);
			if (piv<temp)
			{	piv=temp; j0=j;
			}
		}
		if (piv<epsilon)
		{	signdet=0;
			if (luflag)
			{	col[kh]=0;
				continue;
			}
			else
			{	output("Determinant zero!\n"); 
				error=131; return;
			}
		}
		else
		{	col[kh]=1; rank++;
			det*=lumat[j0][kh];
		}
		if (j0!=k)
		{	signdet=-signdet;
			mm=perm[j0]; perm[j0]=perm[k]; perm[k]=mm;
			if (!luflag)
			{ temp=d[j0]; d[j0]=d[k]; d[k]=temp; }
			temp1=lumat[j0]; lumat[j0]=lumat[k]; lumat[k]=temp1;
		}
		for (j=k+1; j<n; j++)
			if (lumat[j][kh] != 0.0)
			{	lumat[j][kh] /= lumat[k][kh];
				for (temp=lumat[j][kh], mm=kh+1; mm<m; mm++)
					lumat[j][mm]-=temp*lumat[k][mm];
			}
		k++;
		if (k>=n) { kh++; break; }
	}
	if (k<n || kh<m)
	{	signdet=0;
		if (!luflag)
		{	error=131; output("Determinant zero!\n"); 
			return;
		}
	}
	for (j=kh; j<m; j++) col[j]=0;
	det=det*signdet;
}

void solvesim (double *a, int n, double *rs, int m, double *res)
/**** solvesim
	solve simultanuously a linear system.
****/
{	double **x,**b,*h,sum;
	int i,k,l,j;
	ram=newram; luflag=0;
	lu(a,n,n); if (error) return;
	
	/* initialize x and b */
	x=(double **)ram;
	ram+=(LONG)n*sizeof(double *);
	if (ram>ramend) outofram();
	h=res; for (i=0; i<n; i++) { x[i]=h; h+=m; }
	b=(double **)ram;
	ram+=(LONG)n*sizeof(double *);
	if (ram>ramend) outofram();
	h=rs; for (i=0; i<n; i++) { b[i]=h; h+=m; }
	
	for (l=0; l<m; l++)
	{	x[0][l]=b[perm[0]][l];
		for (k=1; k<n; k++)
		{	x[k][l]=b[perm[k]][l];
			for (j=0; j<k; j++)
				x[k][l] -= lumat[k][j]*x[j][l];
		}
		x[n-1][l] /= lumat[n-1][n-1];
		for (k=n-2; k>=0; k--)
		{	for (sum=0.0, j=k+1; j<n; j++)
				sum+=lumat[k][j]*x[j][l];
			x[k][l] = (x[k][l]-sum)/lumat[k][k];
		}
	}
}

void make_lu (double *a, int n, int m, 
	int **rows, int **cols, int *rankp,
	double *detp)
{	ram=newram;
	luflag=1; lu(a,n,m); newram=ram;
	if (error) return;
	*rows=perm; *cols=col; *rankp=rank; *detp=det;
}

void lu_solve (double *a, int n, double *rs, int m, double *res)
{	double **x,**b,*h,sum,*d;
	int i,k,l,j;
	ram=newram;
	
	/* initialize x and b */
	x=(double **)ram;
	ram+=(LONG)n*sizeof(double *);
	if (ram>ramend) outofram();
	h=res; for (i=0; i<n; i++) { x[i]=h; h+=m; }

	b=(double **)ram;
	ram+=(LONG)n*sizeof(double *);
	if (ram>ramend) outofram();
	h=rs; for (i=0; i<n; i++) { b[i]=h; h+=m; }
	
	/* inititalize lumat */
	lumat=(double **)ram;
	ram+=(LONG)n*sizeof(double *);
	if (ram>ramend) outofram();
	d=a; 
	for (i=0; i<n; i++) { lumat[i]=d; d+=n; }
	
	for (l=0; l<m; l++)
	{	x[0][l]=b[0][l];
		for (k=1; k<n; k++)
		{	x[k][l]=b[k][l];
			for (j=0; j<k; j++)
				x[k][l] -= lumat[k][j]*x[j][l];
		}
		x[n-1][l] /= lumat[n-1][n-1];
		for (k=n-2; k>=0; k--)
		{	for (sum=0.0, j=k+1; j<n; j++)
				sum+=lumat[k][j]*x[j][l];
			x[k][l] = (x[k][l]-sum)/lumat[k][k];
		}
	}
}

/******************* complex linear systems **************/

void c_add (complex x, complex y, complex z)
{	z[0]=x[0]+y[0];
	z[1]=x[1]+y[1];
}

void c_sub (complex x, complex y, complex z)
{	z[0]=x[0]-y[0];
	z[1]=x[1]-y[1];
}

void c_mult (complex x, complex y, complex z)
{	double h;
	h=x[0]*y[0]-x[1]*y[1];
	z[1]=x[0]*y[1]+x[1]*y[0];
	z[0]=h;
}

void c_div (complex x, complex y, complex z)
{	double r,h;
	r=y[0]*y[0]+y[1]*y[1];
	h=(x[0]*y[0]+x[1]*y[1])/r;
	z[1]=(x[1]*y[0]-x[0]*y[1])/r;
	z[0]=h;
}

double c_abs (complex x)
{	return sqrt(x[0]*x[0]+x[1]*x[1]);
}

void c_copy (complex x, complex y)
{	x[0]=y[0];
	x[1]=y[1];
}

void c_lu (double *a, int n, int m)
/***** clu
	lu decomposition of a
*****/
{	int i,j,k,mm,j0,kh;
	double *d,piv,temp,zmax,help;
	complex t,*h,*temp1;
	
	if (!luflag)
	{	/* get place for result c and move a to c */
		c_c=(complex *)ram;
		ram+=(LONG)n*m*sizeof(complex);
		if (ram>ramend) outofram();
		memmove((char *)c_c,(char *)a,(LONG)n*m*sizeof(complex));
	}
	else c_c=(complex *)a;
	
	/* inititalize c_lumat */
	c_lumat=(complex **)ram;
	ram+=(LONG)n*sizeof(complex *);
	if (ram>ramend) outofram();
	h=c_c; 
	for (i=0; i<n; i++) { c_lumat[i]=h; h+=m; }
	
	/* get place for perm */
	perm=(int *)ram;
	ram+=(LONG)n*sizeof(int);
	if (ram>ramend) outofram();
	
	/* get place for col */
	col=(int *)ram;
	ram+=(LONG)m*sizeof(int);
	if (ram>ramend) outofram();
	
	/* d is a vector needed by the algorithm */
	d=(double *)ram;
	ram+=(LONG)n*sizeof(double);
	if (ram>ramend) outofram();
	
	/* gauss algorithm */
	if (!luflag)
		for (k=0; k<n; k++)
		{	perm[k]=k;
			for (zmax=0.0, j=0; j<m; j++)
				if ( (help=c_abs(c_lumat[k][j])) >zmax) zmax=help;
			if (zmax==0.0) { error=130; return; }
			d[k]=zmax;
		}
	else
	{	for (k=0; k<n; k++) perm[k]=k;
	}
	signdet=1; rank=0; c_det[0]=1.0; c_det[1]=0.0; k=0;
	for (kh=0; kh<m; kh++)
	{	piv=luflag?c_abs(c_lumat[k][kh]):(c_abs(c_lumat[k][kh])/d[k]);
		j0=k;
		for (j=k+1; j<n; j++)
		{	temp=luflag?c_abs(c_lumat[j][kh]):(c_abs(c_lumat[j][kh])/d[j]);
			if (piv<temp)
			{	piv=temp; j0=j;
			}
		}
		if (piv<epsilon)
		{	signdet=0;
			if (luflag)
			{	col[kh]=0;
				continue;
			}
			else
			{	output("Determinant zero!\n"); 
				error=131; return;
			}
		}
		else
		{	col[kh]=1; rank++;
			c_mult(c_det,c_lumat[j0][kh],c_det);
		}
		if (j0!=k)
		{	signdet=-signdet;
			mm=perm[j0]; perm[j0]=perm[k]; perm[k]=mm;
			if (!luflag)
			{	temp=d[j0]; d[j0]=d[k]; d[k]=temp; }
			temp1=c_lumat[j0]; c_lumat[j0]=c_lumat[k]; 
				c_lumat[k]=temp1;
		}
		for (j=k+1; j<n; j++)
			if (c_lumat[j][kh][0] != 0.0 || c_lumat[j][kh][1]!=0.0)
			{	c_div(c_lumat[j][kh],c_lumat[k][kh],c_lumat[j][kh]);
				for (mm=kh+1; mm<m; mm++)
				{	c_mult(c_lumat[j][kh],c_lumat[k][mm],t);
					c_sub(c_lumat[j][mm],t,c_lumat[j][mm]);
				}
			}
		k++;
		if (k>=n) { kh++; break; }
	}
	if (k<n || kh<m)
	{	signdet=0;
		if (!luflag)
		{	error=131; output("Determinant zero!\n"); 
			return;
		}
	}
	for (j=kh; j<m; j++) col[j]=0;
	c_det[0]=c_det[0]*signdet; c_det[1]=c_det[1]*signdet;
}

void c_solvesim (double *a, int n, double *rs, int m, double *res)
/**** solvesim
	solve simultanuously a linear system.
****/
{	complex **x,**b,*h;
	complex sum,t;
	int i,k,l,j;
	ram=newram;
	luflag=0; c_lu(a,n,n); if (error) return;
	
	/* initialize x and b */
	x=(complex **)ram;
	ram+=(LONG)n*sizeof(complex *);
	if (ram>ramend) outofram();
	h=(complex *)res; for (i=0; i<n; i++) { x[i]=h; h+=m; }
	
	b=(complex **)ram;
	ram+=(LONG)n*sizeof(complex *);
	if (ram>ramend) outofram();
	h=(complex *)rs; for (i=0; i<n; i++) { b[i]=h; h+=m; }
	
	for (l=0; l<m; l++)
	{	c_copy(x[0][l],b[perm[0]][l]);
		for (k=1; k<n; k++)
		{	c_copy(x[k][l],b[perm[k]][l]);
			for (j=0; j<k; j++)
			{	c_mult(c_lumat[k][j],x[j][l],t);
				c_sub(x[k][l],t,x[k][l]);
			}
		}
		c_div(x[n-1][l],c_lumat[n-1][n-1],x[n-1][l]);
		for (k=n-2; k>=0; k--)
		{	sum[0]=0; sum[1]=0.0;
			for (j=k+1; j<n; j++)
			{	c_mult(c_lumat[k][j],x[j][l],t);
				c_add(sum,t,sum);
			}
			c_sub(x[k][l],sum,t);
			c_div(t,c_lumat[k][k],x[k][l]);
		}
	}
}

void cmake_lu (double *a, int n, int m,
	int **rows, int **cols, int *rankp,
	double *detp, double *detip)
{	ram=newram;
	luflag=1; c_lu(a,n,m); newram=ram;
	if (error) return;
	*rows=perm; *cols=col; *rankp=rank; 
	*detp=c_det[0]; *detip=c_det[1];
}

void clu_solve (double *a, int n, double *rs, int m, double *res)
/**** solvesim
	solve simultanuously a linear system.
****/
{	complex **x,**b,*h;
	complex sum,t;
	int i,k,l,j;
	ram=newram;
	
	/* initialize x and b */
	x=(complex **)ram;
	ram+=(LONG)n*sizeof(complex *);
	if (ram>ramend) outofram();
	h=(complex *)res; for (i=0; i<n; i++) { x[i]=h; h+=m; }
	
	b=(complex **)ram;
	ram+=(LONG)n*sizeof(complex *);
	if (ram>ramend) outofram();
	h=(complex *)rs; for (i=0; i<n; i++) { b[i]=h; h+=m; }
	
	/* inititalize c_lumat */
	c_lumat=(complex **)ram;
	ram+=(LONG)n*sizeof(complex *);
	if (ram>ramend) outofram();
	h=(complex *)a; 
	for (i=0; i<n; i++) { c_lumat[i]=h; h+=n; }
	
	for (l=0; l<m; l++)
	{	c_copy(x[0][l],b[0][l]);
		for (k=1; k<n; k++)
		{	c_copy(x[k][l],b[k][l]);
			for (j=0; j<k; j++)
			{	c_mult(c_lumat[k][j],x[j][l],t);
				c_sub(x[k][l],t,x[k][l]);
			}
		}
		c_div(x[n-1][l],c_lumat[n-1][n-1],x[n-1][l]);
		for (k=n-2; k>=0; k--)
		{	sum[0]=0; sum[1]=0.0;
			for (j=k+1; j<n; j++)
			{	c_mult(c_lumat[k][j],x[j][l],t);
				c_add(sum,t,sum);
			}
			c_sub(x[k][l],sum,t);
			c_div(t,c_lumat[k][k],x[k][l]);
		}
	}
}

/************** fft *****************/

int nn;
complex *ff,*zz,*fh;

void rfft (LONG m0, LONG p0, LONG q0, LONG n)
/***** rfft 
	make a fft on x[m],x[m+q0],...,x[m+(p0-1)*q0] (p points).
	one has xi_p0 = xi_n^n = zz[n] ; i.e., p0*n=nn.
*****/
{	LONG p,q,m,l;
	LONG mh,ml;
	int found=0;
	complex sum,h;
	if (p0==1) return;
	if (test_key()==escape) { error=301; return; }
	if (p0%2==0) { p=p0/2; q=2; }
	else
	{	q=3;
		while (q*q<=p0)
		{	if (p0%q==0) 
			{	found=1; break; }
			q+=2;
		}
		if (found) p=p0/q;
		else { q=p0; p=1; }
	}
	if (p>1) for (m=0; m<q; m++) 
		rfft((m0+m*q0)%nn,p,q*q0,nn/p);
	mh=m0;
	for (l=0; l<p0; l++)
	{	ml=l%p;
		c_copy(sum,ff[(m0+ml*q*q0)%nn]);
		for (m=1; m<q; m++)
		{	c_mult(ff[(m0+(m+ml*q)*q0)%nn],zz[(n*l*m)%nn],h);
			c_add(sum,h,sum);
		}
		sum[0]/=q; sum[1]/=q;
		c_copy(fh[mh],sum);
		mh+=q0; if (mh>=nn) mh-=nn;
	}
	for (l=0; l<p0; l++)
	{	c_copy(ff[m0],fh[m0]);
		m0+=q0; if (m0>=nn) mh-=nn;
	}
}

void fft (double *a, int n, int signum)
{	complex z;
	double h;
	int i;
	
	if (n==0) return;
	nn=n;

	ram=newram;
	ff=(complex *)a;
	zz=(complex *)ram;
	ram+=n*sizeof(complex);
	fh=(complex *)ram;
	ram+=n*sizeof(complex);
	if (ram>ramend) outofram();
	
	/* compute zz[k]=e^{-2*pi*i*k/n}, k=0,...,n-1 */
	h=2*M_PI/n; z[0]=cos(h); z[1]=signum*sin(h);
	zz[0][0]=1; zz[0][1]=0;
	for (i=1; i<n; i++)
	{	if (i%16) { zz[i][0]=cos(i*h); zz[i][1]=signum*sin(i*h); }
		else c_mult(zz[i-1],z,zz[i]);
	}
	rfft(0,n,1,1);
	if (signum==1)
		for (i=0; i<n; i++)
		{	ff[i][0]*=n; ff[i][1]*=n;
		}
}

/************** bauhuber algorithm ***************/

#define ITERMAX 200
#define EPS (64*DBL_EPSILON)
#define QR 0.1
#define QI 0.8
#define EPSROOT (64*epsilon)
#define BETA (2096*EPSROOT)

void quadloes (double ar, double ai, double br, double bi,
	double cr, double ci, double *treal, double *timag)
{	double pr,pi,qr,qi,h;
	pr=br*br-bi*bi; pi=2*br*bi;
	qr=ar*cr-ai*ci; qi=ar*ci+ai*cr;
	pr=pr-4*qr; pi=pi-4*qi;
	h=sqrt(pr*pr+pi*pi);
	qr=h+pr; if (qr<0.0) qr=0; 
	qr=sqrt(qr/2);
	qi=h-pr; if (qi<0.0) qi=0; 
	qi=sqrt(qi/2);
	if (pi<0.0) qi=-qi;
	h=qr*br+qi*bi;
	if (h>0.0) { qr=-qr; qi=-qi; }
	pr=qr-br; pi=qi-bi;
	h=pr*pr+pi*pi;
	*treal=2*(cr*pr+ci*pi)/h;
	*timag=2*(ci*pr-cr*pi)/h;
}

int cxdiv (double ar, double ai, double br, double bi,
	double *cr, double *ci)
{	double temp;
	if (br==0.0 && bi==0.0) return 1;
	if (fabs(br)>fabs(bi))
	{	temp=bi/br; br=temp*bi+br;
		*cr=(ar+temp*ai)/br;
		*ci=(ai-temp*ar)/br;
	}
	else
	{	temp=br/bi; bi=temp*br+bi;
		*cr=(temp*ar+ai)/bi;
		*ci=(temp*ai-ar)/bi;
	}
	return 0;
}

double cxxabs (double ar, double ai)
{	if (ar==0.0) return fabs(ai);
	if (ai==0.0) return fabs(ar);
	return sqrt(ai*ai+ar*ar);
}

void chorner (int n, int iu, double *ar, double *ai,
	double xr, double xi, double *pr, double *pi,
	double *p1r, double *p1i, double *p2r, double *p2i,
	double *rf1)
{	register int i,j;
	int i1;
	double temp,hh,tempr=0.0,tempi=0.0;
	*pr=ar[n]; *pi=ai[n];
	*p1r=*p2r=0.0; *p1i=*p2i=0.0;
	*rf1=cxxabs(*pr,*pi);
	i1=n-iu;
	for (j=n-iu,i=n-1; i>=iu; i--,j--)
	{	if (i<n-1)
		{	tempr=*p1r; tempi=*p1i;
			*p1r=*p1r * xr - *p1i * xi;
			*p1i=*p1i * xr + tempr * xi;
		}
		*p1r+=*pr; *p1i+=*pi;
		temp=*pr;
		*pr=*pr * xr - *pi * xi + ar[i];
		*pi=*pi * xr + temp * xi + ai[i];
		temp=cxxabs(*p1r,*p1i);
		hh=cxxabs(*pr,*pi); if (hh>temp) temp=hh;
		if (temp>*rf1)
		{	*rf1=temp; i1=j-1;
		}
		if (i<n-1)
		{	temp=*p2r;
			*p2r=*p2r * xr - *p2i * xi + tempr*2;
			*p2i=*p2i * xr + temp * xi + tempi*2;
		}
	}
	temp=cxxabs(xr,xi);
	if (temp!=0.0)
		*rf1=pow(temp,(double)i1)*(i1+1);
	else
		*rf1=cxxabs(*p1r,*p1i);
	*rf1*=EPS;
}

void scpoly (int n, double *ar, double *ai, double *scal)
{	double p,h;
	int i;
	*scal=0.0;
	p=cxxabs(ar[n],ai[n]);
	for (i=0; i<n; i++)
	{	ai[i]/=p; ar[i]/=p;
		h=pow(cxxabs(ar[i],ai[i]),1.0/(n-i));
		if (h>*scal) *scal=h;
	}
	ar[n]/=p; ai[n]/=p;
	if (*scal==0.0) *scal=1.0;
	for (p=1.0,i=n-1; i>=0; i--)
	{	p*= *scal;
		ar[i]/=p; ai[i]/=p;
	}
}

void bauroot (int n, int iu, double *ar, double *ai, double *x0r,
	double *x0i)
{	int iter=0,i=0,aborted=0;
	double xoldr,xoldi,xnewr,xnewi,h,h1,h2,h3,h4,dzmax,dzmin,
		dxr=1,dxi=0,tempr,tempi,abs_pold,abs_pnew,abs_p1new,
		temp,ss,u,v,
		pr,pi,p1r,p1i,p2r,p2i,abs_pnoted=-1;
		
	dxr=dxi=xoldr=xoldi=0.0;
	if (n-iu==1)
	{	quadloes(0.0,0.0,ar[n],ai[n],
			ar[n-1],ai[n-1],x0r,x0i);
		goto stop;
	}
	if (n-iu==2)
	{	quadloes(ar[n],ai[n],ar[n-1],ai[n-1],
			ar[n-2],ai[n-2],x0r,x0i);
		goto stop;
	}
	xnewr=*x0r; xnewi=*x0i;
	chorner(n,iu,ar,ai,xnewr,xnewi,&pr,&pi,&p1r,&p1i,&p2r,&p2i,&ss);
	iter++;
	abs_pnew=cxxabs(pr,pi);
	if (abs_pnew==0) goto stop;
	abs_pold=abs_pnew;
	dzmin=BETA*(1+cxxabs(xnewr,xnewi));
	while (!aborted)
	{	abs_p1new=cxxabs(p1r,p1i);
		iter++;
		if (abs_pnew>abs_pold) /* Spiraling */
		{	i=0;
			temp=dxr;
			dxr=QR*dxr-QI*dxi;
			dxi=QR*dxi+QI*temp;
		}
		else /* Newton step */
		{	
			dzmax=1.0+cxxabs(xnewr,xnewi);
			h1=p1r*p1r-p1i*p1i-pr*p2r+pi*p2i;
			h2=2*p1r*p1i-pr*p2i-pi*p2r;
			if (abs_p1new>10*ss && cxxabs(h1,h2)>100*ss*ss)
				/* do a Newton step */
			{	i++;
				if (i>2) i=2;
				tempr=pr*p1r-pi*p1i;
				tempi=pr*p1i+pi*p1r;
				cxdiv(-tempr,-tempi,h1,h2,&dxr,&dxi);
				if (cxxabs(dxr,dxi)>dzmax)
				{	temp=dzmax/cxxabs(dxr,dxi);
					dxr*=temp; dxi*=temp;
					i=0;
				}
				if (i==2 && cxxabs(dxr,dxi)<dzmin/EPSROOT &&
					cxxabs(dxr,dxi)>0)
				{	i=0;
					cxdiv(xnewr-xoldr,xnewi-xoldi,dxr,dxi,&h3,&h4);
					h3+=1;
					h1=h3*h3-h4*h4;
					h2=2*h3*h4;
					cxdiv(dxr,dxi,h1,h2,&h3,&h4);
					if (cxxabs(h3,h4)<50*dzmin)
					{	dxr+=h3; dxi+=h4;
					}
				}
				xoldr=xnewr; xoldi=xnewi;
				abs_pold=abs_pnew;
			}
			else /* saddle point, minimize into direction pr+i*pi */
			{	i=0;
				h=dzmax/abs_pnew;
				dxr=h*pr; dxi=h*pi;
				xoldr=xnewr; xoldi=xnewi;
				abs_pold=abs_pnew;
				do
				{	chorner(n,iu,ar,ai,xnewr+dxr,xnewi+dxi,&u,&v,
						&h,&h1,&h2,&h3,&h4);
					dxr*=2; dxi*=2;
				}
				while (fabs(cxxabs(u,v)/abs_pnew-1)<EPSROOT);
			}
		} /* end of Newton step */
		xnewr=xoldr+dxr;
		xnewi=xoldi+dxi;
		dzmin=BETA*(1+cxxabs(xoldr,xoldi));
		chorner(n,iu,ar,ai,xnewr,xnewi,&pr,&pi,
			&p1r,&p1i,&p2r,&p2i,&ss);
		abs_pnew=cxxabs(pr,pi);
		if (abs_pnew==0.0) break;
		if (cxxabs(dxr,dxi)<dzmin && abs_pnew<1e-5
			&& iter>5) break;
		if (iter>ITERMAX)
		{	iter=0;
			if (abs_pnew<=abs_pnoted) break;
			abs_pnoted=abs_pnew;
			if (test_key()==escape) { error=700; return; }
		}
	}
	*x0r=xnewr; *x0i=xnewi;
	stop: ;
/*
	chorner(n,iu,ar,ai,*x0r,*x0i,&pr,&pi,&p1r,&p1i,&p2r,&p2i,&ss);
	abs_pnew=cxxabs(pr,pi);
	printf("%20.5e +i* %20.5e, %20.5e\n",
		*x0r,*x0i,abs_pnew);
*/
}

static void polydiv (int n, int iu, double *ar, double *ai,
	double x0r, double x0i)
{	int i;
	for (i=n-1; i>iu; i--)
	{	ar[i]+=ar[i+1]*x0r-ai[i+1]*x0i;
		ai[i]+=ai[i+1]*x0r+ar[i+1]*x0i;
	}
}

void bauhuber (double *p, int n, double *result, int all,
	double startr, double starti)
{	double *ar,*ai,scalefak=1.0;
	int i;
	double x0r,x0i;
	ram=newram;
	if (ram+2*(n+1)*sizeof(double)>ramend) outofram();
	ar=(double *)ram;
	ai=ar+n+1;
	for (i=0; i<=n; i++)
	{	ar[i]=p[2*i];
		ai[i]=p[2*i+1];
	}
/*	scpoly(n,ar,ai,&scalefak); */
	/* scalefak=1; */
	x0r=startr; x0i=starti;
	for (i=0; i<(all?n:1); i++)
	{	bauroot(n,i,ar,ai,&x0r,&x0i);
		ar[i]=scalefak*x0r;
		ai[i]=scalefak*x0i;
		if (error) 
		{	output("Bauhuber-Iteration failed!\n"); 
			error=311; return;
		}
		polydiv(n,i,ar,ai,x0r,x0i);
		x0i=-x0i;
	}
	for (i=0; i<n; i++)
	{	result[2*i]=ar[i]; result[2*i+1]=ai[i];
	}
}

/**************** tridiagonalization *********************/

double **mg;

void tridiag ( double *a, int n, int **rows)
/***** tridiag
	tridiag. a with n rows and columns.
	r[] contains the new indices of the rows.
*****/
{	char *ram=newram,rh;
	double **m,maxi,*mh,lambda,h;
	int i,j,ipiv,ik,jk,k,*r;
	
	/* make a pointer array to the rows of m : */
	m=(double **)ram; ram+=n*sizeof(double *);
	if (ram>ramend) outofram();
	for (i=0; i<n; i++) { m[i]=a; a+=n; }
	r=(int *)ram; ram+=n*sizeof(double *);
	if (ram>ramend) outofram();
	for (i=0; i<n; i++) r[i]=i;
	
	/* start algorithm : */
	for (j=0; j<n-2; j++) /* need only go the (n-2)-th column */
	{	/* determine pivot */
		jk=r[j]; maxi=fabs(m[j+1][jk]); ipiv=j+1;
		for (i=j+2; i<n; i++)
		{	h=fabs(m[i][jk]);
			if (h>maxi) { maxi=h; ipiv=i; }
		}
		if (maxi<epsilon) continue;
		/* exchange with pivot : */
		if (ipiv!=j+1)
		{	mh=m[j+1]; m[j+1]=m[ipiv]; m[ipiv]=mh;
			rh=r[j+1]; r[j+1]=r[ipiv]; r[ipiv]=rh;
		}
		/* zero elements */
		for (i=j+2; i<n; i++)
		{	jk=r[j]; m[i][jk]=lambda=-m[i][jk]/m[j+1][jk];
			for (k=j+1; k<n; k++) 
			{	ik=r[k]; m[i][ik]+=lambda*m[j+1][ik];
			}
			/* same for columns */
			jk=r[j+1]; ik=r[i];
			for (k=0; k<n; k++) m[k][jk]-=lambda*m[k][ik];
		}
	}
	*rows=r; mg=m;
}

complex **cmg;

void ctridiag ( double *ca, int n, int **rows)
/***** tridiag
	tridiag. a with n rows and columns.
	r[] contains the new indices of the rows.
*****/
{	char *ram=newram,rh;
	complex **m,*mh,lambda,*a=(complex *)ca,help;
	double maxi,h;
	int i,j,ipiv,ik,jk,k,*r;
	
	/* make a pointer array to the rows of m : */
	m=(complex **)ram; ram+=n*sizeof(double *);
	if (ram>ramend) outofram();
	for (i=0; i<n; i++) { m[i]=a; a+=n; }
	r=(int *)ram; ram+=n*sizeof(complex *);
	if (ram>ramend) outofram();
	for (i=0; i<n; i++) r[i]=i;
	
	/* start algorithm : */
	for (j=0; j<n-2; j++) /* need only go the (n-2)-th column */
	{	/* determine pivot */
		jk=r[j]; maxi=c_abs(m[j+1][jk]); ipiv=j+1;
		for (i=j+2; i<n; i++)
		{	h=c_abs(m[i][jk]);
			if (h>maxi) { maxi=h; ipiv=i; }
		}
		if (maxi<epsilon) continue;
		/* exchange with pivot : */
		if (ipiv!=j+1)
		{	mh=m[j+1]; m[j+1]=m[ipiv]; m[ipiv]=mh;
			rh=r[j+1]; r[j+1]=r[ipiv]; r[ipiv]=rh;
		}
		/* zero elements */
		for (i=j+2; i<n; i++)
		{	jk=r[j];
			c_div(m[i][jk],m[j+1][jk],lambda);
			lambda[0]=-lambda[0]; lambda[1]=-lambda[1];
			c_copy(m[i][jk],lambda);
			for (k=j+1; k<n; k++) 
			{	ik=r[k];
				c_mult(lambda,m[j+1][ik],help);
				c_add(m[i][ik],help,m[i][ik]);
			}
			/* same for columns */
			jk=r[j+1]; ik=r[i];
			for (k=0; k<n; k++)
			{	c_mult(lambda,m[k][ik],help);
				c_sub(m[k][jk],help,m[k][jk]);
			}
		}
	}
	*rows=r; cmg=m;
}

void charpoly (double *m1, int n, double *p)
/***** charpoly
	compute the chracteristic polynomial of m.
*****/
{	int i,j,k,*r;
	double **m,h1,h2;
	tridiag(m1,n,&r); m=mg; /* unusual global variable handling */
	/* compute the p_n rekursively : */
	m[0][r[0]]=-m[0][r[0]]; /* first one is x-a(0,0). */
	for (j=1; j<n; j++)
	{	m[0][r[j]]=-m[0][r[j]];
		for (k=1; k<=j; k++)
		{	h1=-m[k][r[j]]; h2=m[k][r[k-1]]; 
			for (i=0; i<k; i++) 
				m[i][r[j]]=m[i][r[j]]*h2+m[i][r[k-1]]*h1;
			m[k][r[j]]=h1;
		}
		for (i=0; i<j; i++) m[i+1][r[j]]+=m[i][r[j-1]];
	}
	for (i=0; i<n; i++) p[i]=m[i][r[n-1]];
	p[n]=1.0;
}

void ccharpoly (double *m1, int n, double *p)
/***** charpoly
	compute the chracteristic polynomial of m.
*****/
{	int *r,i,j,k;
	complex **m,h1,h2,g1,g2,*pc=(complex *)p;
	ctridiag(m1,n,&r); m=cmg; /* unusual global variable handling */
	/* compute the p_n rekursively : */
	m[0][r[0]][0]=-m[0][r[0]][0];
	m[0][r[0]][1]=-m[0][r[0]][1]; /* first one is x-a(0,0). */
	for (j=1; j<n; j++)
	{	m[0][r[j]][0]=-m[0][r[j]][0];
		m[0][r[j]][1]=-m[0][r[j]][1];
		for (k=1; k<=j; k++)
		{	h1[0]=-m[k][r[j]][0]; h1[1]=-m[k][r[j]][1]; 
			c_copy(h2,m[k][r[k-1]]); 
			for (i=0; i<k; i++) 
			{	c_mult(h2,m[i][r[j]],g1);
				c_mult(h1,m[i][r[k-1]],g2);
				c_add(g1,g2,m[i][r[j]]);
			}
			c_copy(m[k][r[j]],h1);
		}
		for (i=0; i<j; i++) 
		{	c_add(m[i+1][r[j]],m[i][r[j-1]],m[i+1][r[j]]);
		}
	}
	for (i=0; i<n; i++) c_copy(pc[i],m[i][r[n-1]]);
	pc[n][0]=1.0; pc[n][1]=0.0;
}

/***************** jacobi-givens eigenvalues **************/

double rotate (double *m, int j, int k, int n)
{
	double theta,t,s,c,tau,h,pivot;
	int l;
	pivot=*mat(m,n,j,k);
	if (fabs(pivot)<epsilon) return 0;
	theta=(*mat(m,n,j,j)-*mat(m,n,k,k))/(2*pivot);
	t=1/(fabs(theta)+sqrt(1+theta*theta));
	if (theta<0) t=-t;
	c=1/sqrt(1+t*t); s=t*c;
	tau=s/(1+c);
	for (l=0; l<n; l++)
	{
		if (l==j || l==k) continue;
		h=*mat(m,n,l,j);
		*mat(m,n,j,l)=*mat(m,n,l,j)=h+s*(*mat(m,n,l,k)-tau*h);
		*mat(m,n,l,k)-=s*(h+tau* *mat(m,n,l,k));
		*mat(m,n,k,l)=*mat(m,n,l,k);
	}
	*mat(m,n,j,j)+=t*pivot;
	*mat(m,n,k,k)-=t*pivot;
	*mat(m,n,j,k)=*mat(m,n,k,j)=0;
	return fabs(pivot);
}

void mjacobi (header *hd)
{
	header *st=hd,*result,*hd1;
	double *m,max,neumax,*mr;
	int r,c,i,j;
	hd=getvalue(hd); if (error) return;
	if (hd->type!=s_matrix) wrong_arg();
	getmatrix(hd,&r,&c,&m);
	if (r!=c) wrong_arg();
	if (r<2) { moveresult(st,hd); return; }
	hd1=new_matrix(r,r,""); if (error) return;
	m=matrixof(hd1);
	memmove(m,matrixof(hd),(long)r*r*sizeof(double));
	while(1)
	{
		max=0.0;
		for (i=0; i<r-1; i++)
			for (j=i+1; j<r; j++)
				if ((neumax=rotate(m,i,j,r))>max)
					max=neumax;
		if (max<epsilon) break;
	}
	result=new_matrix(1,r,""); if (error) return;
	mr=matrixof(result);
	for (i=0; i<r; i++) *mr++=*mat(m,r,i,i);
	moveresult(st,result);
}
