#include <stdio.h>
#include <string.h>
#include <math.h>
#include <limits.h>

#include "header.h"
#include "funcs.h"
#include "helpf.h"
#include "matheh.h"

#define wrong_arg() { error=26; output("Wrong argument\n"); return; }

void minmax (double *x, LONG n, double *min, double *max, 
	int *imin, int *imax)
/***** minmax
	compute the total minimum and maximum of n double numbers.
*****/
{	LONG i;
	if (n==0)
	{	*min=0; *max=0; *imin=0; *imax=0; return; }
	*min=*x; *max=*x; *imin=0; *imax=0; x++;
	for (i=1; i<n; i++)
	{	if (*x<*min) { *min=*x; *imin=(int)i; }
		else if (*x>*max) { *max=*x; *imax=(int)i; }
		x++;
	}
}

void transpose (header *hd)
/***** transpose 
	transpose a matrix
*****/
{	header *hd1,*st=hd;
	double *m,*m1,*mh;
	int c,r,i,j;
	hd=getvalue(hd); if (error) return;
	if (hd->type==s_matrix)
	{	getmatrix(hd,&r,&c,&m);
		hd1=new_matrix(c,r,""); if (error) return;
		m1=matrixof(hd1);
		for (i=0; i<r; i++)
		{	mh=m1+i;
			for (j=0; j<c; j++)
			{	*mh=*m++; mh+=r;
			}
		}
	}
	else if (hd->type==s_cmatrix)
	{	getmatrix(hd,&r,&c,&m);
		hd1=new_cmatrix(c,r,""); if (error) return;
		m1=matrixof(hd1);
		for (i=0; i<r; i++)
        {   mh=m1+(LONG)2*i;
			for (j=0; j<c; j++)
			{	*mh=*m++; *(mh+1)=*m++;
                mh+=(LONG)2*r;
			}
		}
	}
	else if (hd->type==s_real || hd->type==s_complex)
	{	hd1=hd;
	}
	else
	{	error=24; output("\' not defined for this value!\n");
		return;
	}
	moveresult(st,hd1);
}

void vectorize (header *init, header *step, header *end)
{	double vinit,vstep,vend,*m;
	int count;
	header *result,*st=init;
	init=getvalue(init); step=getvalue(step); end=getvalue(end);
	if (error) return;
	if (init->type!=s_real || step->type!=s_real || end->type!=s_real)
	{	output("The : allows only real arguments!\n");
		error=15; return;
	}
	vinit=*realof(init); vstep=*realof(step); vend=*realof(end);
	if (vstep==0)
	{	output("A step size of 0 is not allowed in : ");
		error=401; return;
	}
	if (fabs(vend-vinit)/fabs(vstep)+1+epsilon>INT_MAX)
	{	output1("A vector can only have %d elements",INT_MAX);
		error=402; return;
	}
	count=(int)(floor(fabs(vend-vinit)/fabs(vstep)+1+epsilon));
	if ((vend>vinit && vstep<0) || (vend<vinit && vstep>0))
		count=0;
	result=new_matrix(1,count,""); if (error) return;
	m=matrixof(result);
	while (count>=0)
	{	*m++=vinit;
		vinit+=vstep;
		count--;
	}
	moveresult(st,result);
}

void mfft (header *hd)
{	header *st=hd,*result;
	double *m,*mr;
	int r,c;
	hd=getvalue(hd);
	if (error) return;
	if (hd->type==s_real || hd->type==s_matrix)
	{	make_complex(st); hd=st; }
	getmatrix(hd,&r,&c,&m);
	if (r!=1) wrong_arg();
	result=new_cmatrix(1,c,"");
	mr=matrixof(result);
    memmove((char *)mr,(char *)m,(LONG)2*c*sizeof(double));
	fft(mr,c,-1);
	moveresult(st,result);
}

void mifft (header *hd)
{	header *st=hd,*result;
	double *m,*mr;
	int r,c;
	hd=getvalue(hd);
	if (error) return;
	if (hd->type==s_real || hd->type==s_matrix)
	{	make_complex(st); hd=st; }
	getmatrix(hd,&r,&c,&m);
	if (r!=1) wrong_arg();
	result=new_cmatrix(1,c,"");
	mr=matrixof(result);
    memmove((char *)mr,(char *)m,(LONG)2*c*sizeof(double));
	fft(mr,c,1);
	moveresult(st,result);
}

void mtridiag (header *hd)
{	header *result,*st=hd,*result1;
	double *m,*mr;
	int r,c,*rows,i;
	hd=getvalue(hd); if (error) return;
	if (hd->type==s_matrix)
	{	getmatrix(hd,&c,&r,&m);
		if (c!=r || c==0) wrong_arg();
		result=new_matrix(c,c,""); if (error) return;
		result1=new_matrix(1,c,""); if (error) return;
		mr=matrixof(result);
		memmove(mr,m,(LONG)c*c*sizeof(double));
		tridiag(mr,c,&rows);
		mr=matrixof(result1);
		for (i=0; i<c; i++) *mr++=rows[i]+1;
	}
	else if (hd->type==s_cmatrix)
	{	getmatrix(hd,&c,&r,&m);
		if (c!=r || c==0) wrong_arg();
		result=new_cmatrix(c,c,""); if (error) return;
		result1=new_matrix(1,c,""); if (error) return;
		mr=matrixof(result);
        memmove(mr,m,(LONG)c*c*(LONG)2*sizeof(double));
		ctridiag(mr,c,&rows);
		mr=matrixof(result1);
		for (i=0; i<c; i++) *mr++=rows[i]+1;
	}
	else wrong_arg();
	moveresult(st,result);
	moveresult((header *)newram,result1);
}

void mcharpoly (header *hd)
{	header *result,*st=hd,*result1;
	double *m,*mr;
	int r,c;
	hd=getvalue(hd); if (error) return;
	if (hd->type==s_matrix)
	{	getmatrix(hd,&c,&r,&m);
		if (c!=r || c==0) wrong_arg();
		result=new_matrix(c,c,""); if (error) return;
		result1=new_matrix(1,c+1,""); if (error) return;
		mr=matrixof(result);
		memmove(mr,m,(LONG)c*c*sizeof(double));
		charpoly(mr,c,matrixof(result1));
	}
	else if (hd->type==s_cmatrix)
	{	getmatrix(hd,&c,&r,&m);
		if (c!=r || c==0) wrong_arg();
		result=new_cmatrix(c,c,""); if (error) return;
		result1=new_cmatrix(1,c+1,""); if (error) return;
		mr=matrixof(result);
        memmove(mr,m,(LONG)c*c*(LONG)2*sizeof(double));
		ccharpoly(mr,c,matrixof(result1));
	}
	else wrong_arg();
	moveresult(st,result1);
}

void mscompare (header *hd)
{	header *st=hd,*hd1,*result;
	hd=getvalue(hd);
	hd1=getvalue(nextof(st));
	if (error) return;
	if (hd->type==s_string && hd1->type==s_string)
	{	result=new_real(strcmp(stringof(hd),stringof(hd1)),"");
		if (error) return;
	}
	else wrong_arg();
	moveresult(st,result);
}

void mfind (header *hd)
{	header *st=hd,*hd1,*result;
	double *m,*m1,*mr;
	int i,j,k,c,r,c1,r1;
	hd=getvalue(hd);
	hd1=getvalue(nextof(st));
	if (error) return;
	if ((hd->type!=s_matrix && hd->type!=s_real) || 
	    (hd1->type!=s_matrix && hd1->type!=s_real)) wrong_arg();
	getmatrix(hd,&c,&r,&m);
	getmatrix(hd1,&c1,&r1,&m1);
	if (c!=1 && r!=1) wrong_arg();
	if (r!=1) c=r;
	result=new_matrix(c1,r1,""); if (error) return;
	mr=matrixof(result);
	for (i=0; i<r1; i++)
		for (j=0; j<c1; j++)
		{	k=0;
			while (k<c && m[k]<=*m1) k++;
			if (k==c && *m1<=m[c-1]) k=c-1;
			*mr++=k; m1++;
		}
	moveresult(st,result);
}

void mdiag2 (header *hd)
{	header *st=hd,*hd1,*result;
	int c,r,i,n,l;
	double *m,*mh,*mr;
	hd1=next_param(hd);
	hd=getvalue(hd); if (hd1) hd1=getvalue(hd1);
	if (error) return;
	if (hd1->type!=s_real) wrong_arg();
	n=(int)*realof(hd1);
	if (hd->type==s_matrix || hd->type==s_real)
	{	getmatrix(hd,&r,&c,&m);
		result=new_matrix(1,r,""); if (error) return;
		mr=matrixof(result); l=0;
		for (i=0; i<r; i++)
		{	if (i+n>=c) break;
			if (i+n>=0) { l++; *mr++=*mat(m,c,i,i+n); }
		}
		dimsof(result)->c=l;
		result->size=matrixsize(1,c);
	}
	else if (hd->type==s_cmatrix || hd->type==s_complex)
	{	getmatrix(hd,&r,&c,&m);
		result=new_cmatrix(1,r,""); if (error) return;
		mr=matrixof(result); l=0;
		for (i=0; i<r; i++)
		{	if (i+n>=c) break;
			if (i+n>=0) 
			{	l++;
				mh=cmat(m,c,i,i+n);
				*mr++=*mh++;
				*mr++=*mh;
			}
		}
		dimsof(result)->c=l;
		result->size=cmatrixsize(1,c);
	}
	else wrong_arg();
	moveresult(st,result);
}

void mband (header *hd)
{	header *st=hd,*hd1,*hd2,*result;
	int i,j,c,r,n1,n2;
	double *m,*mr;
	hd1=next_param(hd);
	hd2=next_param(hd1);
	hd=getvalue(hd); hd1=getvalue(hd1); hd2=getvalue(hd2);
	if (error) return;
	if (hd1->type!=s_real || hd2->type!=s_real) wrong_arg();
	n1=(int)*realof(hd1); n2=(int)*realof(hd2);
	if (hd->type==s_matrix || hd->type==s_real)
	{	getmatrix(hd,&r,&c,&m);
		result=new_matrix(r,c,""); if (error) return;
		mr=matrixof(result);
		for (i=0; i<r; i++)
			for (j=0; j<c; j++)
			{	if (j-i>=n1 && j-i<=n2) *mr++=*m++;
				else { *mr++=0.0; m++; }
			}
	}
	else if (hd->type==s_cmatrix || hd->type==s_complex)
	{	getmatrix(hd,&r,&c,&m);
		result=new_cmatrix(r,c,""); if (error) return;
		mr=matrixof(result);
		for (i=0; i<r; i++)
			for (j=0; j<c; j++)
			{	if (j-i>=n1 && j-i<=n2) { *mr++=*m++; *mr++=*m++; }
				else { *mr++=0.0; *mr++=0.0; m+=2; }
			}
	}
	else wrong_arg();
	moveresult(st,result);
}

void mdup (header *hd)
{	header *result,*st=hd,*hd1;
	double x,*m,*m1,*m2;
	int c,i,n,j,r;
	hd=getvalue(hd);
	hd1=next_param(st);
	if (!hd1) wrong_arg();
	hd1=getvalue(hd1); if (error) return;
	if (hd1->type!=s_real) wrong_arg();
	x=*realof(hd1); n=(int)x;
	if (n<1 || x>=INT_MAX) wrong_arg();
	if (hd->type==s_matrix && dimsof(hd)->r==1)
	{	c=dimsof(hd)->c;
		result=new_matrix(n,c,"");
		if (error) return;
		m1=matrixof(hd); m2=matrixof(result);
		for (i=0; i<n; i++)
		{	m=mat(m2,c,i,0);
			memmove((char *)m,(char *)m1,c*sizeof(double));
		}
	}
	else if (hd->type==s_matrix && dimsof(hd)->c==1)
	{	r=dimsof(hd)->r;
		result=new_matrix(r,n,"");
		if (error) return;
		m1=matrixof(hd); m2=matrixof(result);
		for (i=0; i<r; i++)
		{	m=mat(m2,c,i,0);
			for (j=0; j<n; j++)
				*mat(m2,n,i,j)=*mat(m1,1,i,0);
		}
	}
	else if (hd->type==s_real)
	{	result=new_matrix(n,1,""); if (error) return;
		m1=matrixof(result);
		for (i=0; i<n; i++) *m1++=*realof(hd);
	}
	else if (hd->type==s_cmatrix && dimsof(hd)->r==1)
	{	c=dimsof(hd)->c;
		result=new_cmatrix(n,c,"");
		if (error) return;
		m1=matrixof(hd); m2=matrixof(result);
		for (i=0; i<n; i++)
		{	m=cmat(m2,c,i,0);
            memmove((char *)m,(char *)m1,(LONG)2*c*sizeof(double));
		}
	}
	else if (hd->type==s_cmatrix && dimsof(hd)->c==1)
	{	r=dimsof(hd)->r;
		result=new_cmatrix(r,n,"");
		if (error) return;
		m1=matrixof(hd); m2=matrixof(result);
		for (i=0; i<r; i++)
		{	m=mat(m2,c,i,0);
			for (j=0; j<n; j++)
				copy_complex(cmat(m2,n,i,j),cmat(m1,1,i,0));
		}
	}
	else if (hd->type==s_complex)
	{	result=new_cmatrix(n,1,""); if (error) return;
		m1=matrixof(result);
		for (i=0; i<n; i++) { *m1++=*realof(hd); *m1++=*imagof(hd); }
	}
	else wrong_arg();
	moveresult(st,result);
}

void make_complex (header *hd)
/**** make_complex
	make a function argument complex.
****/
{	header *old=hd,*nextarg;
	size_t size;
	int r,c,i,j;
	double *m,*m1;
	hd=getvalue(hd);
	if (hd->type==s_real)
	{	size=sizeof(header)+2*sizeof(double);
		nextarg=nextof(old);
		if (newram+(size-old->size)>ramend)
		{	output("Memory overflow!\n"); error=180; return; }
		if (newram>(char *)nextarg)
			memmove((char *)old+size,(char *)nextarg,
				newram-(char *)nextarg);
		newram+=size-old->size;
		*(old->name)=0; old->size=size;
		old->type=s_complex;
		*realof(old)=*realof(hd);
		*imagof(old)=0.0;
	}
	else if (hd->type==s_matrix)
	{	getmatrix(hd,&r,&c,&m);
		size=cmatrixsize(r,c);
		nextarg=nextof(old);
		if (newram+(size-old->size)>ramend)
		{	output("Memory overflow!\n"); error=180; return; }
		if (newram>(char *)nextarg)
			memmove((char *)old+size,(char *)nextarg,
				newram-(char *)nextarg);
		newram+=size-old->size;
		*(old->name)=0; old->size=size;
		old->type=s_cmatrix;
		dimsof(old)->r=r; dimsof(old)->c=c;
		m1=matrixof(old);
		for (i=r-1; i>=0; i--)
			for (j=c-1; j>=0; j--)
			{	*cmat(m1,c,i,j)=*mat(m,c,i,j);
				*(cmat(m1,c,i,j)+1)=0.0;
			}
	}
}

void mvconcat (header *hd)
{	header *st=hd,*hd1,*result;
	double *m,*m1;
	int r,c,r1,c1;
	size_t size=0;
	hd=getvalue(hd);
	hd1=next_param(st);
	if (!hd1) wrong_arg();
	hd1=getvalue(hd1); if (error) return;
	if (hd->type==s_real || hd->type==s_matrix)
	{	if (hd1->type==s_real || hd1->type==s_matrix)
		{	getmatrix(hd,&r,&c,&m);
			getmatrix(hd1,&r1,&c1,&m1);
			if (r!=0 && (c!=c1 || (LONG)r+r1>INT_MAX)) wrong_arg();
			result=new_matrix(r+r1,c1,"");
			if (r!=0)
			{	size=(LONG)r*c*sizeof(double);
				memmove((char *)matrixof(result),(char *)m,
					size);
			}
			memmove((char *)matrixof(result)+size,
				(char *)m1,(LONG)r1*c1*sizeof(double));
		}
		else if (hd1->type==s_complex || hd1->type==s_cmatrix)
		{	make_complex(st);
			mvconcat(st);
			return;
		}
		else wrong_arg();
	}
	else if (hd->type==s_complex || hd->type==s_cmatrix)
	{	if (hd1->type==s_complex || hd1->type==s_cmatrix)
		{	getmatrix(hd,&r,&c,&m);
			getmatrix(hd1,&r1,&c1,&m1);
			if (r!=0 && (c!=c1 || (LONG)r+r1>INT_MAX)) wrong_arg();
			result=new_cmatrix(r+r1,c1,"");
			if (r!=0)
			{	size=(LONG)r*(LONG)2*c*sizeof(double);
				memmove((char *)matrixof(result),(char *)m,
					size);
			}
			memmove((char *)matrixof(result)+size,
                (char *)m1,(LONG)r1*(LONG)2*c1*sizeof(double));
		} 
		else if (hd1->type==s_real || hd1->type==s_matrix)
		{	make_complex(next_param(st));
			mvconcat(st);
			return;
		}
		else wrong_arg();
	}	
	else wrong_arg();
	moveresult(st,result);
}

void mhconcat (header *hd)
{	header *st=hd,*hd1,*result;
	double *m,*m1,*mr;
	int r,c,r1,c1,i;
	hd=getvalue(hd);
	hd1=next_param(st);
	if (!hd1) wrong_arg();
	hd1=getvalue(hd1); if (error) return;
	if (hd->type==s_string && hd1->type==s_string)
	{	result=new_string(stringof(hd),
			strlen(stringof(hd))+strlen(stringof(hd1))+1,"");
		strcat(stringof(result),stringof(hd1));
	}
	else if (hd->type==s_real || hd->type==s_matrix)
	{	if (hd1->type==s_real || hd1->type==s_matrix)
		{	getmatrix(hd,&r,&c,&m);
			getmatrix(hd1,&r1,&c1,&m1);
			if (c!=0 && (r!=r1 || (LONG)c+c1>INT_MAX)) wrong_arg();
			result=new_matrix(r1,c+c1,"");
			mr=matrixof(result);
			for (i=0; i<r1; i++)
			{	if (c!=0) memmove((char *)mat(mr,c+c1,i,0),
					(char *)mat(m,c,i,0),c*sizeof(double));
				memmove((char *)mat(mr,c+c1,i,c),
					(char *)mat(m1,c1,i,0),c1*sizeof(double));
			}
		}
		else if (hd1->type==s_complex || hd1->type==s_cmatrix)
		{	make_complex(st);
			mhconcat(st);
			return;
		}
		else wrong_arg();
	}
	else if (hd->type==s_complex || hd->type==s_cmatrix)
	{	if (hd1->type==s_complex || hd1->type==s_cmatrix)
		{	getmatrix(hd,&r,&c,&m);
			getmatrix(hd1,&r1,&c1,&m1);
			if (c!=0 && (r!=r1 || (LONG)c+c1>INT_MAX)) wrong_arg();
			result=new_cmatrix(r1,c+c1,"");
			mr=matrixof(result);
			for (i=0; i<r1; i++)
			{	if (c!=0) memmove((char *)cmat(mr,c+c1,i,0),
                    (char *)cmat(m,c,i,0),c*(LONG)2*sizeof(double));
				memmove((char *)cmat(mr,c+c1,i,c),
                    (char *)cmat(m1,c1,i,0),c1*(LONG)2*sizeof(double));
			}
		}
		else if (hd1->type==s_real || hd1->type==s_matrix)
		{	make_complex(next_param(st)); if (error) return;
			mhconcat(st);
			return;
		}
		else wrong_arg();
	}	
	else wrong_arg();
	moveresult(st,result);
}

void cscalp (double *s, double *si, double *x, double *xi,
	double *y, double *yi);
void ccopy (double *y, double *x, double *xi);

void wmultiply (header *hd)
/***** multiply
	matrix multiplication for weakly nonzero matrices.
*****/
{	header *result,*st=hd,*hd1;
	dims *d,*d1;
	double *m,*m1,*m2,*mm1,*mm2,x,y,null=0.0;
	int i,j,c,r,k;
	hd=getvalue(hd); hd1=getvalue(nextof(st));
	if (error) return;
	if (hd->type==s_matrix && hd1->type==s_matrix)
	{	d=dimsof(hd);
		d1=dimsof(hd1);
		if (d->c != d1->r)
		{	error=8; output("Cannot multiply these!\n");
			return;
		}
		r=d->r; c=d1->c;
		result=new_matrix(r,c,"");
		if (error) return;
		m=matrixof(result);
		m1=matrixof(hd);
		m2=matrixof(hd1);
		for (i=0; i<r; i++)
			for (j=0; j<c; j++)
			{	mm1=mat(m1,d->c,i,0); mm2=m2+j;
				x=0.0;
				for (k=0; k<d->c; k++)
				{	if ((*mm1!=0.0)&&(*mm2!=0.0)) x+=(*mm1)*(*mm2);
					mm1++; mm2+=d1->c;
				}
				*mat(m,c,i,j)=x;
			}
		moveresult(st,result);
		return;
	}
	if (hd->type==s_matrix && hd1->type==s_cmatrix)
	{	d=dimsof(hd);
		d1=dimsof(hd1);
		if (d->c != d1->r)
		{	error=8; output("Cannot multiply these!\n");
			return;
		}
		r=d->r; c=d1->c;
		result=new_cmatrix(r,c,"");
		if (error) return;
		m=matrixof(result);
		m1=matrixof(hd);
		m2=matrixof(hd1);
		for (i=0; i<r; i++)
			for (j=0; j<c; j++)
            {   mm1=mat(m1,d->c,i,0); mm2=m2+(LONG)2*j;
				x=0.0; y=0.0;
				for (k=0; k<d->c; k++)
				{	if ((*mm2!=0.0 || *(mm2+1)!=0.0) &&
							(*mm1!=0.0))
					cscalp(&x,&y,mm1,&null,mm2,mm2+1);
					mm1++; mm2+=2*d1->c;
				}
				ccopy(cmat(m,c,i,j),&x,&y);
			}
		moveresult(st,result);
		return;
	}
	if (hd->type==s_cmatrix && hd1->type==s_matrix)
	{	d=dimsof(hd);
		d1=dimsof(hd1);
		if (d->c != d1->r)
		{	error=8; output("Cannot multiply these!\n");
			return;
		}
		r=d->r; c=d1->c;
		result=new_cmatrix(r,c,"");
		if (error) return;
		m=matrixof(result);
		m1=matrixof(hd);
		m2=matrixof(hd1);
		for (i=0; i<r; i++)
			for (j=0; j<c; j++)
			{	mm1=cmat(m1,d->c,i,0); mm2=m2+j;
				x=0.0; y=0.0;
				for (k=0; k<d->c; k++)
				{	if ((*mm2!=0.0) &&
							(*mm1!=0.0 ||  *(mm1+1)!=0.0))
					cscalp(&x,&y,mm1,mm1+1,mm2,&null);
					mm1+=2; mm2+=d1->c;
				}
				ccopy(cmat(m,c,i,j),&x,&y);
			}
		moveresult(st,result);
		return;
	}
	if (hd->type==s_cmatrix && hd1->type==s_cmatrix)
	{	d=dimsof(hd);
		d1=dimsof(hd1);
		if (d->c != d1->r)
		{	error=8; output("Cannot multiply these!\n");
			return;
		}
		r=d->r; c=d1->c;
		result=new_cmatrix(r,c,"");
		if (error) return;
		m=matrixof(result);
		m1=matrixof(hd);
		m2=matrixof(hd1);
		for (i=0; i<r; i++)
			for (j=0; j<c; j++)
            {   mm1=cmat(m1,d->c,i,0); mm2=m2+(LONG)2*j;
				x=0.0; y=0.0;
				for (k=0; k<d->c; k++)
				{	if ((*mm2!=0.0 || *(mm2+1)!=0.0) &&
							(*mm1!=0.0 || *(mm1+1)!=0.0))
					cscalp(&x,&y,mm1,mm1+1,mm2,mm2+1);
					mm1+=2; mm2+=2*d1->c;
				}
				ccopy(cmat(m,c,i,j),&x,&y);
			}
		moveresult(st,result);
		return;
	}
	else wrong_arg();
}

void smultiply (header *hd)
/***** multiply
	matrix multiplication for weakly nonzero symmetric matrices.
*****/
{	header *result,*st=hd,*hd1;
	dims *d,*d1;
	double *m,*m1,*m2,*mm1,*mm2,x,y,null=0.0;
	int i,j,c,r,k;
	hd=getvalue(hd); hd1=getvalue(nextof(st));
	if (error) return;
	if (hd->type==s_matrix && hd1->type==s_matrix)
	{	d=dimsof(hd);
		d1=dimsof(hd1);
		if (d->c != d1->r)
		{	error=8; output("Cannot multiply these!\n");
			return;
		}
		r=d->r; c=d1->c;
		result=new_matrix(r,c,"");
		if (error) return;
		m=matrixof(result);
		m1=matrixof(hd);
		m2=matrixof(hd1);
		for (i=0; i<r; i++)
			for (j=i; j<c; j++)
			{	mm1=mat(m1,d->c,i,0); mm2=m2+j;
				x=0.0;
				for (k=0; k<d->c; k++)
				{	if ((*mm1!=0.0)&&(*mm2!=0.0)) x+=(*mm1)*(*mm2);
					mm1++; mm2+=d1->c;
				}
				*mat(m,c,i,j)=x;
				*mat(m,c,j,i)=x;
			}
		moveresult(st,result);
		return;
	}
	if (hd->type==s_matrix && hd1->type==s_cmatrix)
	{	d=dimsof(hd);
		d1=dimsof(hd1);
		if (d->c != d1->r)
		{	error=8; output("Cannot multiply these!\n");
			return;
		}
		r=d->r; c=d1->c;
		result=new_cmatrix(r,c,"");
		if (error) return;
		m=matrixof(result);
		m1=matrixof(hd);
		m2=matrixof(hd1);
		for (i=0; i<r; i++)
			for (j=i; j<c; j++)
            {   mm1=mat(m1,d->c,i,0); mm2=m2+(LONG)2*j;
				x=0.0; y=0.0;
				for (k=0; k<d->c; k++)
				{	if ((*mm2!=0.0 || *(mm2+1)!=0.0) &&
							(*mm1!=0.0))
					cscalp(&x,&y,mm1,&null,mm2,mm2+1);
					mm1++; mm2+=2*d1->c;
				}
				ccopy(cmat(m,c,i,j),&x,&y); y=-y;
				ccopy(cmat(m,c,j,i),&x,&y);
			}
		moveresult(st,result);
		return;
	}
	if (hd->type==s_cmatrix && hd1->type==s_matrix)
	{	d=dimsof(hd);
		d1=dimsof(hd1);
		if (d->c != d1->r)
		{	error=8; output("Cannot multiply these!\n");
			return;
		}
		r=d->r; c=d1->c;
		result=new_cmatrix(r,c,"");
		if (error) return;
		m=matrixof(result);
		m1=matrixof(hd);
		m2=matrixof(hd1);
		for (i=0; i<r; i++)
			for (j=i; j<c; j++)
			{	mm1=cmat(m1,d->c,i,0); mm2=m2+j;
				x=0.0; y=0.0;
				for (k=0; k<d->c; k++)
				{	if ((*mm2!=0.0) &&
							(*mm1!=0.0 ||  *(mm1+1)!=0.0))
					cscalp(&x,&y,mm1,mm1+1,mm2,&null);
					mm1+=2; mm2+=d1->c;
				}
				ccopy(cmat(m,c,i,j),&x,&y); y=-y;
				ccopy(cmat(m,c,j,i),&x,&y);
			}
		moveresult(st,result);
		return;
	}
	if (hd->type==s_cmatrix && hd1->type==s_cmatrix)
	{	d=dimsof(hd);
		d1=dimsof(hd1);
		if (d->c != d1->r)
		{	error=8; output("Cannot multiply these!\n");
			return;
		}
		r=d->r; c=d1->c;
		result=new_cmatrix(r,c,"");
		if (error) return;
		m=matrixof(result);
		m1=matrixof(hd);
		m2=matrixof(hd1);
		for (i=0; i<r; i++)
			for (j=i; j<c; j++)
            {   mm1=cmat(m1,d->c,i,0); mm2=m2+(LONG)2*j;
				x=0.0; y=0.0;
				for (k=0; k<d->c; k++)
				{	if ((*mm2!=0.0 || *(mm2+1)!=0.0) &&
							(*mm1!=0.0 || *(mm1+1)!=0.0))
					cscalp(&x,&y,mm1,mm1+1,mm2,mm2+1);
					mm1+=2; mm2+=2*d1->c;
				}
				ccopy(cmat(m,c,i,j),&x,&y); 
				y=-y;
				ccopy(cmat(m,c,j,i),&x,&y);
			}
		moveresult(st,result);
		return;
	}
	else wrong_arg();
}

