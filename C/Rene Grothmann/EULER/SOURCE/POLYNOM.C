#include <stdio.h>
#include <math.h>
#include <limits.h>
#include <string.h>

#include "header.h"
#include "polynom.h"
#include "funcs.h"
#include "matheh.h"

#define wrong_arg() { error=26; output("Wrong argument\n"); return; }

#define max(x,y) ((x)>(y)?(x):(y))

double *polynom;
int degree,polreal;

double peval (double x)
{	int i;
	double *p=polynom+degree,res;
	res=*p--;
	for (i=degree-1; i>=0; i--) res=res*x+(*p--);
	return res;
}

void cpeval (double *x, double *xi, double *z, double *zi)
{	int i;
	double *p,h,hi;
	p=polynom+(polreal?degree:(2l*degree));
	*z=*p; *zi=(polreal)?0.0:*(p+1);
	if (polreal) p--;
	else p-=2;
	for (i=degree-1; i>=0; i--)
	{	complex_multiply(x,xi,z,zi,&h,&hi);
		*z= h + *p;
		if (!polreal) { *zi=hi+*(p+1); p--; }
		else { *zi=hi; }
		p--;
	}
}

void polyval (header *hd)
{	header *st=hd,*hd1;
	int r,c;
	hd1=next_param(hd);
	hd=getvalue(hd); if (error) return;
	if (hd->type==s_real || hd->type==s_matrix)
	{	getmatrix(hd,&r,&c,&polynom);
		if (r!=1) wrong_arg();
		degree=c-1;
		if (degree<0) wrong_arg();
		polreal=1;
	}
	else if (hd->type==s_complex || hd->type==s_cmatrix)
	{	make_complex(hd1);
		getmatrix(hd,&r,&c,&polynom);
		if (r!=1) wrong_arg();
		degree=c-1;
		if (degree<0) wrong_arg();
		polreal=0;
	}	
	else wrong_arg();
	spread1(peval,cpeval,hd1);
	moveresult(st,hd1);
}

int testparams (header **hd1, header **hd2)
{	header *h1=*hd1,*h2=*hd2;
	*hd1=getvalue(h1); if (error) return 0;
	*hd2=getvalue(h2); if (error) return 0;
	if ((*hd1)->type==s_complex || (*hd1)->type==s_cmatrix
		|| (*hd2)->type==s_complex || (*hd2)->type==s_cmatrix)
	{	if ((*hd1)->type!=s_complex && (*hd1)->type!=s_cmatrix)
		{	make_complex(h1); *hd1=h1; *hd2=nextof(h1);
			*hd2=getvalue(*hd2);
		}
		else if ((*hd2)->type!=s_complex && (*hd2)->type!=s_cmatrix)
		{	make_complex(h2); *hd2=h2;
		}
		return 1;
	}
	else return 0;
}

void polyadd (header *hd)
{	header *st=hd,*hd1,*result;
	int flag,c,c1,c2,i,r;
	double *m1,*m2,*mr;
	complex *mc1,*mc2,*mcr;
	hd1=next_param(st);
	flag=testparams(&hd,&hd1); if (error) return;
	getmatrix(hd,&r,&c1,&m1); if (r!=1) wrong_arg();
	getmatrix(hd1,&r,&c2,&m2); if (r!=1) wrong_arg();
	c=max(c1,c2);
	if (flag) /* complex values */
	{	mc1=(complex *)m1; mc2=(complex *)m2;
		result=new_cmatrix(1,c,""); if (error) return;
		mcr=(complex *)matrixof(result);
		for (i=0; i<c; i++)
		{	if (i>=c1) { c_copy(*mcr,*mc2); mcr++; mc2++; }
			else if (i>=c2) { c_copy(*mcr,*mc1); mcr++; mc1++; }
			else { c_add(*mc1,*mc2,*mcr); mc1++; mc2++; mcr++; }
		}
	}
	else
	{	result=new_matrix(1,c,""); if (error) return;
		mr=matrixof(result);
		for (i=0; i<c; i++)
		{	if (i>=c1) { *mr++ = *m2++; }
			else if (i>=c2) { *mr++ = *m1++; }
			else { *mr++ = *m1++ + *m2++; }
		}	
	}
	moveresult(st,result);
}

void polymult (header *hd)
{	header *st=hd,*hd1,*result;
	int flag,c,c1,c2,i,r,j,k;
	double *m1,*m2,*mr,x;
	complex *mc1,*mc2,*mcr,xc,hc;
	hd1=next_param(st);
	flag=testparams(&hd,&hd1); if (error) return;
	getmatrix(hd,&r,&c1,&m1); if (r!=1) wrong_arg();
	getmatrix(hd1,&r,&c2,&m2); if (r!=1) wrong_arg();
	if ((LONG)c1+c2-1>INT_MAX) wrong_arg();
	c=c1+c2-1;
	if (flag)
	{	mc1=(complex *)m1; mc2=(complex *)m2;
		result=new_cmatrix(1,c,""); if (error) return;
		mcr=(complex *)matrixof(result);
		c_copy(xc,*mc1); mc1++;
		for (i=0; i<c2; i++) c_mult(xc,mc2[i],mcr[i]);
		for (j=1; j<c1; j++)
		{	c_copy(xc,*mc1); mc1++;
			for (k=j,i=0; i<c2-1; i++,k++) 
			{	c_mult(xc,mc2[i],hc);
				c_add(hc,mcr[k],mcr[k]);
			}
			c_mult(xc,mc2[i],mcr[k]);
		}
	}
	else
	{	result=new_matrix(1,c,""); if (error) return;
		mr=matrixof(result);
		x=*m1++;
		for (i=0; i<c2; i++) mr[i]=x*m2[i];
		for (j=1; j<c1; j++)
		{	x=*m1++;
			for (k=j,i=0; i<c2-1; i++,k++) mr[k]+=x*m2[i];
			mr[k]=x*m2[i];
		}
	}
	moveresult(st,result);
}

void polydiv (header *hd)
{	header *st=hd,*hd1,*result,*rest;
	int flag,c1,c2,i,r,j;
	double *m1,*m2,*mr,*mh,x,l;
	complex *mc1,*mc2,*mcr,*mch,xc,lc,hc;
	hd1=next_param(st);
	flag=testparams(&hd,&hd1); if (error) return;
	getmatrix(hd,&r,&c1,&m1); if (r!=1) wrong_arg();
	getmatrix(hd1,&r,&c2,&m2); if (r!=1) wrong_arg();
	if (c1<c2)
	{	result=new_real(0.0,"");
		rest=(header *)newram;
		moveresult(rest,hd1);
	}
	else if (flag)
	{	mc1=(complex *)m1; mc2=(complex *)m2;
		result=new_cmatrix(1,c1-c2+1,""); if (error) return;
		mcr=(complex *)matrixof(result);
		rest=new_cmatrix(1,c2,""); if (error) return;
		mch=(complex *)newram;
		if (newram+c1*sizeof(complex)>ramend)
		{	output("Out of memory!\n"); error=190; return;
		}
		memmove((char *)mch,(char *)mc1,c1*sizeof(complex));
		c_copy(lc,mc2[c2-1]);
		if (lc[0]==0.0 && lc[1]==0.0) wrong_arg();
		for (i=c1-c2; i>=0; i--)
		{	c_div(mch[c2+i-1],lc,xc); c_copy(mcr[i],xc);
			for(j=0; j<c2; j++) 
			{	c_mult(mc2[j],xc,hc);
				c_sub(mch[i+j],hc,mch[i+j]);
			}
		}
		memmove((char *)matrixof(rest),(char *)mch,c2*sizeof(complex));
	}
	else
	{	result=new_matrix(1,c1-c2+1,""); if (error) return;
		mr=matrixof(result);
		rest=new_matrix(1,c2,""); if (error) return;
		mh=(double *)newram;
		if (newram+c1*sizeof(double)>ramend)
		{	output("Out of memory!\n"); error=190; return;
		}
		memmove((char *)mh,(char *)m1,c1*sizeof(double));
		l=m2[c2-1];
		if (l==0.0) wrong_arg();
		for (i=c1-c2; i>=0; i--)
		{	x=mh[c2+i-1]/l; mr[i]=x;
			for(j=0; j<c2; j++) mh[i+j]-=m2[j]*x;
		}
		memmove((char *)matrixof(rest),(char *)mh,c2*sizeof(double));
	}
	moveresult(st,result);
	moveresult(nextof(st),rest);
}

void dd (header *hd)
{	header *st=hd,*hd1,*result;
	int flag,c1,c2,i,j,r;
	double *m1,*m2,*mr;
	complex *mc1,*mc2,*mcr,hc1,hc2;
	hd1=next_param(st);
	flag=testparams(&hd,&hd1); if (error) return;
	getmatrix(hd,&r,&c1,&m1); if (r!=1) wrong_arg();
	getmatrix(hd1,&r,&c2,&m2); if (r!=1) wrong_arg();
	if (c1!=c2) wrong_arg();
	if (flag) /* complex values */
	{	mc1=(complex *)m1; mc2=(complex *)m2;
		result=new_cmatrix(1,c1,""); if (error) return;
		mcr=(complex *)matrixof(result);
		memmove((char *)mcr,(char *)mc2,c1*sizeof(complex));
		for (i=1; i<c1; i++)
		{	for (j=c1-1; j>=i; j--)
			{	if (mc1[j][0]==mc1[j-i][0] &&
					mc1[j][1]==mc1[j-i][1]) wrong_arg();
				c_sub(mcr[j],mcr[j-1],hc1);
				c_sub(mc1[j],mc1[j-i],hc2);
				c_div(hc1,hc2,mcr[j]);
			}
		}	
	}
	else
	{	result=new_matrix(1,c1,""); if (error) return;
		mr=matrixof(result);
		memmove((char *)mr,(char *)m2,c1*sizeof(double));
		for (i=1; i<c1; i++)
		{	for (j=c1-1; j>=i; j--)
			{	if (m1[j]==m1[j-i]) wrong_arg();
				mr[j]=(mr[j]-mr[j-1])/(m1[j]-m1[j-i]);
			}
		}	
	}
	moveresult(st,result);
}

double *divx,*divdif;
int degree,polreal;

double rddeval (double x)
{	int i;
	double *p=divdif+degree,res;
	res=*p--;
	for (i=degree-1; i>=0; i--) res=res*(x-divx[i])+(*p--);
	return res;
}

void cddeval (double *x, double *xi, double *z, double *zi)
{	int i;
	double *p,h,hi,*dd,xh,xhi;
	p=divdif+(polreal?degree:(2l*degree));
	dd=divx+(polreal?(degree-1):(2l*(degree-1)));
	*z=*p; *zi=(polreal)?0.0:*(p+1);
	if (polreal) p--;
	else p-=2;
	for (i=degree-1; i>=0; i--)
	{	xh=*x-*dd;
		if (!polreal) { xhi=*xi-*(dd+1); dd--; }
		else xhi=*xi;
		dd--;
		complex_multiply(&xh,&xhi,z,zi,&h,&hi);
		*z= h + *p;
		if (!polreal) { *zi=hi+*(p+1); p--; }
		else { *zi=hi; }
		p--;
	}
}

void ddval (header *hd)
{	header *st=hd,*hdd,*hd1;
	int r,c,c1;
	start: hdd=next_param(st);
	hd1=next_param(hdd);
	hd=getvalue(st); if (error) return;
	hdd=getvalue(hdd); if (error) return;
	if (hd->type==s_real || hd->type==s_matrix)
	{	getmatrix(hd,&r,&c,&divx);
		if (r!=1) wrong_arg();
		degree=c-1;
		if (degree<0) wrong_arg();
		polreal=1;
		if (hdd->type!=s_real && hdd->type!=s_matrix)
		{	if (hdd->type==s_complex || hdd->type==s_cmatrix)
			{	make_complex(st); goto start; }
			else wrong_arg();
		}
		getmatrix(hdd,&r,&c1,&divdif);
		if (r!=1 || c1!=c) wrong_arg();
	}
	else if (hd->type==s_complex || hd->type==s_cmatrix)
	{	make_complex(hd1);
		getmatrix(hd,&r,&c,&divx);
		if (r!=1) wrong_arg();
		degree=c-1;
		if (degree<0) wrong_arg();
		polreal=0;
		if (hdd->type!=s_complex && hdd->type!=s_cmatrix)
		{	if (hdd->type==s_real || hdd->type==s_matrix)
			{	make_complex(nextof(st)); goto start; }
			else wrong_arg();
		}
		getmatrix(hdd,&r,&c1,&divdif);
		if (r!=1 || c1!=c) wrong_arg();
	}
	else wrong_arg();
	spread1(rddeval,cddeval,hd1);
	moveresult(st,hd1);
}

void polyzeros (header *hd)
{	header *st=hd,*result;
	int i,j,r,c;
	double *m,*mr,x;
	complex *mc,*mcr,xc,hc;
	hd=getvalue(hd); if (error) return;
	if (hd->type==s_real || hd->type==s_matrix)
	{	getmatrix(hd,&r,&c,&m);
		if (r!=1) wrong_arg();
		result=new_matrix(1,c+1,""); if (error) return;
		mr=matrixof(result);
		mr[0]=-m[0]; mr[1]=1.0;
		for (i=1; i<c; i++)
		{	x=-m[i]; mr[i+1]=1.0;
			for (j=i; j>=1; j--) mr[j]=mr[j-1]+x*mr[j];
			mr[0]*=x;
		}
	}
	else if (hd->type==s_complex || hd->type==s_cmatrix)
	{	getmatrix(hd,&r,&c,&m); mc=(complex *)m;
		if (r!=1) wrong_arg();
		result=new_cmatrix(1,c+1,""); if (error) return;
		mcr=(complex *)matrixof(result);
		mcr[0][0]=-mc[0][0]; mcr[0][1]=-mc[0][1];
		mcr[1][0]=1.0; mcr[1][1]=0.0;
		for (i=1; i<c; i++)
		{	xc[0]=-mc[i][0]; xc[1]=-mc[i][1];
			mcr[i+1][0]=1.0; mcr[i+1][1]=0.0;
			for (j=i; j>=1; j--) 
			{	c_mult(xc,mcr[j],hc);
				c_add(hc,mcr[j-1],mcr[j]);
			}
			c_mult(xc,mcr[0],mcr[0]);
		}
	}
	else wrong_arg();
	moveresult(st,result);
}

void polydd (header *hd)
{	header *st=hd,*hd1,*result;
	int flag,c1,c2,i,j,r;
	double *m1,*m2,*mr,x;
	complex *mc1,*mc2,*mcr,hc,xc;
	hd1=next_param(st);
	flag=testparams(&hd,&hd1); if (error) return;
	getmatrix(hd,&r,&c1,&m1); if (r!=1) wrong_arg();
	getmatrix(hd1,&r,&c2,&m2); if (r!=1) wrong_arg();
	if (c1!=c2) wrong_arg();
	if (flag) /* complex values */
	{	mc1=(complex *)m1; mc2=(complex *)m2;
		result=new_cmatrix(1,c1,""); if (error) return;
		mcr=(complex *)matrixof(result);
		c_copy(mcr[c1-1],mc2[c1-1]);
		for (i=c1-2; i>=0; i--)
		{	c_copy(xc,mc1[i]);
			c_mult(xc,mcr[i+1],hc);
			c_sub(mc2[i],hc,mcr[i]);
			for (j=i+1; j<c1-1; j++) 
			{	c_mult(xc,mcr[j+1],hc);
				c_sub(mcr[j],hc,mcr[j]);
			}
		}
	}
	else
	{	result=new_matrix(1,c1,""); if (error) return;
		mr=matrixof(result);
		mr[c1-1]=m2[c1-1];
		for (i=c1-2; i>=0; i--)
		{	x=m1[i];
			mr[i]=m2[i]-x*mr[i+1];
			for (j=i+1; j<c1-1; j++) mr[j]=mr[j]-x*mr[j+1];
		}
	}
	moveresult(st,result);
}

void polytrunc (header *hd)
{	header *st=hd,*result;
	double *m;
	complex *mc;
	int i;
	hd=getvalue(hd); if (error) return;
	if (hd->type==s_matrix && dimsof(hd)->r==1)
	{	m=matrixof(hd);
		for (i=dimsof(hd)->c-1; i>=0; i--)
		{	if (fabs(m[i])>epsilon) break;
		}
		if (i<0) result=new_real(0.0,"");
		else 
		{	result=new_matrix(1,i+1,"");
			memmove((char *)matrixof(result),(char *)matrixof(hd),
				(i+1)*sizeof(double));
		}
	}
	else if (hd->type==s_complex && dimsof(hd)->r==1)
	{	mc=(complex *)matrixof(hd);
		for (i=dimsof(hd)->c-1; i>=0; i--)
		{	if (fabs(mc[i][0])>epsilon && fabs(mc[i][1])>epsilon) 
				break;
		}
		if (i<0) result=new_complex(0.0,0.0,"");
		else 
		{	result=new_cmatrix(1,i+1,"");
			memmove((char *)matrixof(result),(char *)matrixof(hd),
				(i+1)*sizeof(complex));
		}
	}
	else wrong_arg();
	moveresult(st,result);
}

void mzeros (header *hd)
{	header *st=hd,*result;
	int r,c;
	double *m;
	hd=getvalue(hd); if (error) return;
	if (hd->type==s_matrix) 
	{	make_complex(st); if (error) return;
		hd=getvalue(st); if (error) return; 
	}
	if (hd->type!=s_cmatrix || dimsof(hd)->r!=1 || dimsof(hd)->c<2)
	{	output("Need a complex polynomial\n"); error=300; return; }
	getmatrix(hd,&r,&c,&m);
	result=new_cmatrix(1,c-1,""); if (error) return;
	bauhuber(m,c-1,matrixof(result),1,0,0);
	moveresult(st,result);
}

void mzeros1 (header *hd)
{	header *st=hd,*hd1,*result;
	int r,c;
	double *m,xr,xi;
	hd1=nextof(hd);
	hd=getvalue(hd); if (error) return;
	if (hd->type==s_matrix)
	{	make_complex(st); if (error) return;
		hd=getvalue(st); if (error) return;
	}
	hd1=nextof(st);
	hd1=getvalue(hd1); if (error) return;
	if (hd1->type==s_real)
	{	xr=*realof(hd1); xi=0;
	}
	else if (hd1->type==s_complex)
	{	xr=*realof(hd1); xi=*(realof(hd1)+1);
	}
	else
	{	output("Need a starting value!\n"); error=300; return; }
	if (hd->type!=s_cmatrix || dimsof(hd)->r!=1 || dimsof(hd)->c<2)
	{	output("Need a complex polynomial\n"); error=300; return; }
	getmatrix(hd,&r,&c,&m);
	result=new_complex(0,0,""); if (error) return;
	bauhuber(m,c-1,realof(result),0,xr,xi);
	moveresult(st,result);
}
