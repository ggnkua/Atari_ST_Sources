#include <math.h>
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <limits.h>

#include "header.h"
#include "sysdep.h"
#include "funcs.h"

void scan_summe (void);

extern int nosubmref,trace;
int udfon=0,actargn=0;
header *running;

/**************** builtin operators ****************/

header *getvalue (header *hd)
/***** getvalue
	get an actual value of a reference.
*****/
{	header *old=hd,*mhd,*result;
	dims *d;
	double *m,*mr,*m1,*m2,*m3;
	int r,c,*rind,*cind,*cind1,i,j;
	while (hd && hd->type==s_reference)
		hd=referenceof(hd);
	if (!hd)
	{	mhd=(header *)newram;
		if (exec_builtin(old->name,0,mhd)) return mhd;
		hd=searchudf(old->name);
		if (hd)
		{	interpret_udf(hd,mhd,0);
			return mhd;
		}
		output1("Variable %s not defined!\n",old->name);
		error=10; return new_string("Fehler",6,"");
	}
	if (hd->type==s_submatrix)
	{	mhd=submrefof(hd); d=submdimsof(hd);
		rind=rowsof(hd); cind=colsof(hd);
		getmatrix(mhd,&r,&c,&m);
		if (d->r==1 && d->c==1)
			return new_real(*mat(m,c,*rind,*cind),"");
		result=new_matrix(d->r,d->c,"");
		mr=matrixof(result);
		for (i=0; i<d->r; i++)
		{	cind1=cind;
			m1=mat(mr,d->c,i,0);
			m2=mat(m,c,*rind,0);
			for (j=0; j<d->c; j++)
			{	m1[j]=m2[*cind1];
				cind1++;
			}
			rind++;
		}
		return result;
	}
	if (hd->type==s_csubmatrix)
	{	mhd=submrefof(hd); d=submdimsof(hd);
		rind=rowsof(hd); cind=colsof(hd);
		getmatrix(mhd,&r,&c,&m);
		if (d->r==1 && d->c==1)
		{	m=cmat(m,c,*rind,*cind);
			return new_complex(*m,*(m+1),"");
		}
		result=new_cmatrix(d->r,d->c,"");
		mr=matrixof(result);
		for (i=0; i<d->r; i++)
		{	cind1=cind;
			m1=cmat(mr,d->c,i,0);
			m2=cmat(m,c,*rind,0);
			for (j=0; j<d->c; j++)
            {   m3=m2+(LONG)2*(*cind1);
				*m1++=*m3++; *m1++=*m3;
				cind1++;
			}
			rind++;
		}
		return result;
	}
	if (hd->type==s_matrix && dimsof(hd)->c==1 && dimsof(hd)->r==1)
	{	return new_real(*matrixof(hd),"");
	}
	if (hd->type==s_cmatrix && dimsof(hd)->c==1 && dimsof(hd)->r==1)
	{	return new_complex(*matrixof(hd),*(matrixof(hd)+1),"");
	}
	return hd;
}

header *getvariable (header *hd)
/***** getvariable
	get an actual variable of a reference.
*****/
{	header *old=hd;
	while (hd && hd->type==s_reference)
		hd=referenceof(hd);
	if (!hd)
	{	output1("Variable %s not defined!\n",old->name);
		error=10; return new_string("Fehler",6,"");
	}
	return hd;
}

void moveresult (header *stack, header *result)
/***** moveresult
	move the result to the start of stack.
*****/
{	if (stack==result) return;
	memmove((char *)stack,(char *)result,result->size);
	newram=(char *)stack+stack->size;
}

void moveresult1 (header *stack, header *result)
/***** moveresult
	move several results to the start of stack.
*****/
{	size_t size;
	if (stack==result) return;
	size=newram-(char *)result;
	memmove((char *)stack,(char *)result,size);
	newram=(char *)stack+size;
}

header *mapt2 (void f(double *,double *,double *),
	void fc(double *, double *, double *, double *, double *, double *),
	header *hd, header *hd1)
/***** map
	do the function elementwise to the two values.
	store the result hd2. the values may also be complex,
	then fc is used.
******/
{	dims *d,*d1;
	double x,y,*m,*m1,*m2,null=0.0;
	header *hd2;
	LONG i,n;
	if (hd->type==s_real)
	{	if (hd1->type==s_matrix)
		{	d1=dimsof(hd1);
			m1=matrixof(hd1);
			x=*(realof(hd));
			hd2=new_matrix(d1->r,d1->c,"");
			if (error) return new_string("Fehler",6,"");
			m2=matrixof(hd2);
			n=(d1->c)*(d1->r);
			for (i=0; i<n; i++)
				{	f(m1,&x,m2); m1++; m2++;
				}
			return hd2;
		}
		if (fc && hd1->type==s_cmatrix)
		{	d1=dimsof(hd1);
			m1=matrixof(hd1);
			x=*(realof(hd));
			hd2=new_cmatrix(d1->r,d1->c,"");
			if (error) return new_string("Fehler",6,"");
			m2=matrixof(hd2);
			n=(d1->c)*(d1->r);
			for (i=0; i<n; i++)
				{	fc(m1,m1+1,&x,&null,m2,m2+1); m1+=2; m2+=2;
				}
			return hd2;
		}
	}
	else if (hd->type==s_complex)
	{	if (hd1->type==s_matrix)
		{	d1=dimsof(hd1);
			m1=matrixof(hd1);
			x=*(realof(hd));
			y=*(imagof(hd));
			hd2=new_cmatrix(d1->r,d1->c,"");
			if (error) return new_string("Fehler",6,"");
			m2=matrixof(hd2);
			n=(d1->c)*(d1->r);
			for (i=0; i<n; i++)
				{	fc(m1,&null,&x,&y,m2,m2+1); m1++; m2+=2;
				}
			return hd2;
		}
		if (fc && hd1->type==s_cmatrix)
		{	d1=dimsof(hd1);
			m1=matrixof(hd1);
			x=*(realof(hd));
			y=*(imagof(hd));
			hd2=new_cmatrix(d1->r,d1->c,"");
			if (error) return new_string("Fehler",6,"");
			m2=matrixof(hd2);
			n=(d1->c)*(d1->r);
			for (i=0; i<n; i++)
				{	fc(m1,m1+1,&x,&y,m2,m2+1); m1+=2; m2+=2;
				}
			return hd2;
		}
	}
	else if (hd->type==s_matrix)
	{	if (fc && hd1->type==s_cmatrix)
		{	d=dimsof(hd);
			m=matrixof(hd);
			d1=dimsof(hd1);
			m1=matrixof(hd1);
			if (d->c!=d1->c || d->r!= d1->r)
			{	output("Matrix dimensions must agree!\n");
				error=4; return new_string("Fehler",6,"");
			}
			hd2=new_cmatrix(d->r,d->c,"");
			if (error) return new_string("Fehler",6,"");
			m2=matrixof(hd2);
			n=(d->c)*(d->r);
			for (i=0; i<n; i++)
				{	fc(m1,m1+1,m,&null,m2,m2+1); m++; m1+=2; m2+=2;
				}
			return hd2;
		}
	}
	output("Illegal operation\n"); error=3;
	return new_string("Fehler",6,"");
}

header *map2 (void f(double *,double *,double *),
	void fc(double *, double *, double *, double *, double *, double *),
	header *hd, header *hd1)
/***** map
	do the function elementwise to the two values.
	store the result hd2. the values may also be complex,
	then fc is used.
******/
{	dims *d,*d1;
	double x,y,*m,*m1,*m2,null=0.0;
	header *hd2;
	LONG i,n;
	if (hd->type==s_real)
	{	if (hd1->type==s_real)
		{	f(realof(hd),realof(hd1),&x);
			return new_real(x,"");
		}
		if (fc && hd1->type==s_complex)
		{	fc(realof(hd),&null,realof(hd1),imagof(hd1),&x,&y);
			return new_complex(x,y,"");
		}
		if (hd1->type==s_matrix)
		{	d1=dimsof(hd1);
			m1=matrixof(hd1);
			x=*(realof(hd));
			hd2=new_matrix(d1->r,d1->c,"");
			if (error) return new_string("Fehler",6,"");
			m2=matrixof(hd2);
			n=(d1->c)*(d1->r);
			for (i=0; i<n; i++)
				{	f(&x,m1,m2); m1++; m2++;
				}
			return hd2;
		}
		if (fc && hd1->type==s_cmatrix)
		{	d1=dimsof(hd1);
			m1=matrixof(hd1);
			x=*(realof(hd));
			hd2=new_cmatrix(d1->r,d1->c,"");
			if (error) return new_string("Fehler",6,"");
			m2=matrixof(hd2);
			n=(d1->c)*(d1->r);
			for (i=0; i<n; i++)
				{	fc(&x,&null,m1,m1+1,m2,m2+1); m1+=2; m2+=2;
				}
			return hd2;
		}
	}
	else if (fc && hd->type==s_complex)
	{	if (hd1->type==s_real)
		{	fc(realof(hd),imagof(hd),realof(hd1),&null,&x,&y);
			return new_complex(x,y,"");
		}
		if (hd1->type==s_complex)
		{	fc(realof(hd),imagof(hd),realof(hd1),imagof(hd1),&x,&y);
			return new_complex(x,y,"");
		}
		if (hd1->type==s_matrix)
		{	d1=dimsof(hd1);
			m1=matrixof(hd1);
			x=*(realof(hd));
			y=*(imagof(hd));
			hd2=new_cmatrix(d1->r,d1->c,"");
			if (error) return new_string("Fehler",6,"");
			m2=matrixof(hd2);
			n=(d1->c)*(d1->r);
			for (i=0; i<n; i++)
				{	fc(&x,&y,m1,&null,m2,m2+1); m1++; m2+=2;
				}
			return hd2;
		}
		if (hd1->type==s_cmatrix)
		{	d1=dimsof(hd1);
			m1=matrixof(hd1);
			x=*(realof(hd));
			y=*(imagof(hd));
			hd2=new_cmatrix(d1->r,d1->c,"");
			if (error) return new_string("Fehler",6,"");
			m2=matrixof(hd2);
			n=(d1->c)*(d1->r);
			for (i=0; i<n; i++)
				{	fc(&x,&y,m1,m1+1,m2,m2+1); m1+=2; m2+=2;
				}
			return hd2;
		}
	}
	else if (hd->type==s_matrix)
	{	if (hd1->type==s_matrix)
		{	d=dimsof(hd);
			m=matrixof(hd);
			d1=dimsof(hd1);
			m1=matrixof(hd1);
			if (d->c!=d1->c || d->r!= d1->r)
			{	output("Matrix dimensions must agree!\n");
				error=4;
				return new_string("Fehler",6,"");
			}
			hd2=new_matrix(d->r,d->c,"");
			if (error) return new_string("Fehler",6,"");
			m2=matrixof(hd2);
			n=(d->c)*(d->r);
			for (i=0; i<n; i++)
				{	f(m,m1,m2); m++; m1++; m2++;
				}
			return hd2;
		}
		if (fc && hd1->type==s_cmatrix)
		{	d=dimsof(hd);
			m=matrixof(hd);
			d1=dimsof(hd1);
			m1=matrixof(hd1);
			if (d->c!=d1->c || d->r!= d1->r)
			{	output("Matrix dimensions must agree!\n");
				error=4; return new_string("Fehler",6,"");
			}
			hd2=new_cmatrix(d->r,d->c,"");
			if (error) return new_string("Fehler",6,"");
			m2=matrixof(hd2);
			n=(d->c)*(d->r);
			for (i=0; i<n; i++)
				{	fc(m,&null,m1,m1+1,m2,m2+1); m++; m1+=2; m2+=2;
				}
			return hd2;
		}
		return mapt2(f,fc,hd1,hd);
	}
	else if (fc && hd->type==s_cmatrix)
	{	if (hd1->type==s_cmatrix)
		{	d=dimsof(hd);
			m=matrixof(hd);
			d1=dimsof(hd1);
			m1=matrixof(hd1);
			if (d->c!=d1->c || d->r!= d1->r)
			{	output("Matrix dimensions must agree!\n");
				error=4; return new_string("Fehler",6,"");
			}
			hd2=new_cmatrix(d->r,d->c,"");
			if (error) return new_string("Fehler",6,"");
			m2=matrixof(hd2);
			n=(d->c)*(d->r);
			for (i=0; i<n; i++)
				{	fc(m,m+1,m1,m1+1,m2,m2+1); m+=2; m1+=2; m2+=2;
				}
			return hd2;
		}
		return mapt2(f,fc,hd1,hd);
	}
	output("Illegal operation\n"); error=3;
	return new_string("Fehler",6,"");
}

header *map1 (void f(double *, double *), 
	void fc(double *, double *, double *, double *),
	header *hd)
/***** map
	do the function elementwise to the value.
	te value may be real or complex!
******/
{	double x,y;
	dims *d;
	header *hd1;
	double *m,*m1;
	int i,n;
	if (hd->type==s_real)
	{	f(realof(hd),&x);
		return new_real(x,"");
	}
	else if (hd->type==s_matrix)
	{	d=dimsof(hd);
		hd1=new_matrix(d->r,d->c,"");
		if (error) return new_string("Fehler",6,"");
		m=matrixof(hd);
		m1=matrixof(hd1);
		n=d->c*d->r;
		for (i=0; i<n; i++)
			{	f(m,m1); m++; m1++;
			}
		return hd1;
	}
	else if (fc && hd->type==s_complex)
	{	fc(realof(hd),imagof(hd),&x,&y);
		return new_complex(x,y,"");
	}
	else if (fc && hd->type==s_cmatrix)
	{	d=dimsof(hd);
		hd1=new_cmatrix(d->r,d->c,"");
		if (error) return new_string("Fehler",6,"");
		m=matrixof(hd);
		m1=matrixof(hd1);
		n=d->c*d->r;
		for (i=0; i<n; i++)
			{	fc(m,m+1,m1,m1+1); m+=2; m1+=2;
			}
		return hd1;
	}
	output("Illegal operation\n"); error=3;
	return new_string("Fehler",6,"");
}

header *map1r (void f(double *, double *), 
	void fc(double *, double *, double *),
	header *hd)
/***** map
	do the function elementwise to the value.
	te value may be real or complex! the result is always real.
******/
{	double x;
	dims *d;
	header *hd1;
	double *m,*m1;
	int i,n;
	if (hd->type==s_real)
	{	f(realof(hd),&x);
		return new_real(x,"");
	}
	else if (hd->type==s_matrix)
	{	d=dimsof(hd);
		hd1=new_matrix(d->r,d->c,"");
		if (error) return new_string("Fehler",6,"");
		m=matrixof(hd);
		m1=matrixof(hd1);
		n=d->c*d->r;
		for (i=0; i<n; i++)
			{	f(m,m1); m++; m1++;
			}
		return hd1;
	}
	else if (fc && hd->type==s_complex)
	{	fc(realof(hd),imagof(hd),&x);
		return new_real(x,"");
	}
	else if (fc && hd->type==s_cmatrix)
	{	d=dimsof(hd);
		hd1=new_matrix(d->r,d->c,"");
		if (error) return new_string("Fehler",6,"");
		m=matrixof(hd);
		m1=matrixof(hd1);
		n=d->c*d->r;
		for (i=0; i<n; i++)
			{	fc(m,m+1,m1); m+=2; m1++;
			}
		return hd1;
	}
	output("Illegal operation\n"); error=3;
	return new_string("Fehler",6,"");
}

void real_add (double *x, double *y, double *z)
{	*z=*x+*y;
}

void complex_add (double *x, double *xi, double *y, double *yi,
	double *z, double *zi)
{	*z=*x+*y;
	*zi=*xi+*yi;
}

void add (header *hd, header *hd1)
/***** add
	add the values.
*****/
{	header *result,*st=hd;
	hd=getvalue(hd); hd1=getvalue(hd1);
	if (error) return;
	result=map2(real_add,complex_add,hd,hd1);
	if (!error) moveresult(st,result);
}

void real_subtract (double *x, double *y, double *z)
{	*z=*x-*y;
}

void complex_subtract (double *x, double *xi, double *y, double *yi,
	double *z, double *zi)
{	*z=*x-*y;
	*zi=*xi-*yi;
}

void subtract (header *hd, header *hd1)
/***** add
	add the values.
*****/
{	header *result,*st=hd;
	hd=getvalue(hd); hd1=getvalue(hd1);
	if (error) return;
	result=map2(real_subtract,complex_subtract,hd,hd1);
	if (!error) moveresult(st,result);
}

void real_multiply (double *x, double *y, double *z)
{	*z=*x*(*y);
}

void complex_multiply (double *x, double *xi, double *y, double *yi,
	double *z, double *zi)
{	*z=*x * *y - *xi * *yi;
	*zi=*x * *yi + *xi * *y;
}

void dotmultiply (header *hd, header *hd1)
/***** add
	add the values.
*****/
{	header *result,*st=hd;
	hd=getvalue(hd); hd1=getvalue(hd1);
	if (error) return;
	result=map2(real_multiply,complex_multiply,hd,hd1);
	if (!error) moveresult(st,result);
}

void real_divide (double *x, double *y, double *z)
{	
#ifdef FLOAT_TEST
	if (*y==0.0) { *y=1e-10; error=1; }
#endif
	*z=*x/(*y);
}

void complex_divide (double *x, double *xi, double *y, double *yi,
	double *z, double *zi)
{	double r;
	r=*y * *y + *yi * *yi;
#ifdef FLOAT_TEST
	if (r==0) { r=1e-10; error=1; }
#endif
	*z=(*x * *y + *xi * *yi)/r;
	*zi=(*xi * *y - *x * *yi)/r;
}

void dotdivide (header *hd, header *hd1)
/***** add
	add the values.
*****/
{	header *result,*st=hd;
	hd=getvalue(hd); hd1=getvalue(hd1);
	if (error) return;
	result=map2(real_divide,complex_divide,hd,hd1);
	if (!error) moveresult(st,result);
}

void cscalp (double *s, double *si, double *x, double *xi,
	double *y, double *yi)
{	*s += *x * *y - *xi * *yi;
	*si += *x * *yi + *xi * *y;
}

void ccopy (double *y, double *x, double *xi)
{	*y++=*x; *y=*xi;
}

void multiply (header *hd, header *hd1)
/***** multiply
	matrix multiplication.
*****/
{	header *result,*st=hd;
	dims *d,*d1;
	double *m,*m1,*m2,*mm1,*mm2,x,y,null=0.0;
	int i,j,c,r,k;
	hd=getvalue(hd); hd1=getvalue(hd1);
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
				{	x+=(*mm1)*(*mm2);
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
				{	cscalp(&x,&y,mm1,&null,mm2,mm2+1);
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
				{	cscalp(&x,&y,mm1,mm1+1,mm2,&null);
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
				{	cscalp(&x,&y,mm1,mm1+1,mm2,mm2+1);
					mm1+=2; mm2+=2*d1->c;
				}
				ccopy(cmat(m,c,i,j),&x,&y);
			}
		moveresult(st,result);
		return;
	}
	else dotmultiply(st,nextof(st));
}

void divide (header *hd, header *hd1)
{	dotdivide(hd,hd1);
}

void real_invert (double *x, double *y)
{	*y= -*x;
}

void complex_invert (double *x, double *xi, double *y, double *yi)
{	*y= -*x;
	*yi= -*xi;
}

void invert (header *hd)
/***** invert
	compute -matrix.
*****/
{	header *result,*st=hd;
	hd=getvalue(hd);
	if (error) return;
	result=map1(real_invert,complex_invert,hd);
	if (!error) moveresult(st,result);
}

void get_element (int nargs, header *var, header *hd)
/***** get_elements
	get the element of the matrix.
*****/
{	header *st=hd,*result,*hd1;
	var=getvalue(var); if (error) return;
	if (var->type==s_string) /* interpret the string as a function */
	{	if (exec_builtin(stringof(var),nargs,hd));
		else
		{	hd1=searchudf(stringof(var));
			if (hd1) interpret_udf(hd1,hd,nargs);
			else
			{	output1("%s is not function name!\n",stringof(var));
				error=2020; return;
			}
		}
		return;
	}
	hd=getvalue(hd); if (error) return;
	if (nargs<1 || nargs>2) 
	{ 	error=30; output("Illegal matrix reference!\n"); return; }
	if (nargs==2) 
	{	hd1=getvalue(next_param(st)); if (error) return;
	}
	else 
	{	if (dimsof(var)->r==1) { hd1=hd; hd=new_real(1.0,""); }
		else hd1=new_command(c_allv);
		if (error) return;
	}
	if (var->type==s_matrix || var->type==s_real)
	{	result=new_submatrix(var,hd,hd1,"");
	}
	else if (var->type==s_cmatrix || var->type==s_complex)
	{	result=new_csubmatrix(var,hd,hd1,"");
	}
	else
	{	error=31; output1("Not a matrix %s!\n",var->name); return;
	}
	if (error) return;
	moveresult(st,result);
}

void get_element1 (char *name, header *hd)
/* get an element of a matrix, referenced by *realof(hd),
   where the matrix is dentified with a vector of same length
*/
{	header *st=hd,*result,*var;
	LONG n,l;
	int r,c;
	double *m;
	hd=getvalue(hd);
	var=searchvar(name);
	if (!var)
	{	output1("%s not a variable!\n",name);
		error=1012; return;
	}
	var=getvalue(var); if (error) return;
	if (hd->type!=s_real)
	{	output("Index must be a number!\n");
		error=1013; return;
	}
	if (error) return;
	if (var->type==s_real)
	{	result=new_reference(var,"");
	}
	else if (var->type==s_complex)
	{	result=new_reference(var,"");
	}
	else if (var->type==s_matrix)
	{	getmatrix(var,&r,&c,&m);
		l=(LONG)(*realof(hd));
		n=(LONG)r*c;
		if (l>n) l=n;
		if (l<1) l=1;
		if (nosubmref) result=new_real(*(m+l-1),"");
		else result=new_subm(var,l,"");
	}
	else if (var->type==s_cmatrix)
	{	getmatrix(var,&r,&c,&m);
		l=(LONG)(*realof(hd));
		n=(LONG)r*c;
		if (n==0)
		{	output("Matrix is empty!\n"); error=1030; return;
		}
		if (l>n) l=n;
		if (l<1) l=1;
		if (nosubmref)
        {   m+=(LONG)2*(l-1);
			result=new_complex(*m,*(m+1),"");
		}
		else result=new_csubm(var,l,"");
	}
	else
	{	output1("%s not a variable of proper type for {}!\n");
		error=1011; return;
	}
	moveresult(st,result);
}

/****************** udf ************************/

void interpret_udf (header *var, header *args, int argn)
/**** interpret_udf
	interpret a user defined function.
****/
{	int udfold,nargu,i,oldargn,defaults,oldtrace;
	char *oldnext=next,*oldstartlocal,*oldendlocal,*udflineold,*p;
	header *result,*st=args,*hd=args,*hd1,*oldrunning;
	p=helpof(var);
	nargu=*((int *)p); p+=sizeof(int);
	for (i=0; i<argn; i++)
	{	if (hd->type==s_reference && !referenceof(hd))
		{	if (i<nargu && hd->name[0]==0 && *(int *)p)
			{	p+=16+2*sizeof(int);
				moveresult((header *)newram,(header *)p);
				p=(char *)nextof((header *)p);
				hd=nextof(hd);
				continue;
			}
			else
			{	hd1=getvalue(hd); if (error) return;
			}
		}
		else hd1=hd;
		if (i<nargu) 
		{	defaults=*(int *)p; p+=sizeof(int);
			strcpy(hd1->name,p); hd1->xor=*((int *)(p+16));
			p+=16+sizeof(int);
			if (defaults) p=(char *)nextof((header *)p);
		}
		else
		{	strcpy(hd1->name,argname[i]);
			hd1->xor=xors[i];
		}
		hd=nextof(hd);
	}
	for (i=argn; i<nargu; i++)
	{	defaults=*(int *)p;
		p+=16+2*sizeof(int);
		if (defaults)
		{	moveresult((header *)newram,(header *)p);
			p=(char *)nextof((header *)p);
		}
	}
	udflineold=udfline;
	oldargn=actargn;
	actargn=argn;
	udfline=next=udfof(var); udfold=udfon; udfon=1;
	oldstartlocal=startlocal; oldendlocal=endlocal;
	startlocal=(char *)args; endlocal=newram;
	oldrunning=running; running=var;
	if ((oldtrace=trace)>0)
	{	if (trace==2) trace=0;
		if (trace>0) trace_udfline(next);
	}
	else if (var->flags&1)
	{	trace=1;
		if (trace>0) trace_udfline(next);
	}
	while (!error && udfon==1)
	{	command();
		if (udfon==2)
		{	result=scan_value(); 
			if (error) 
			{	output1("Error in function %s\n",var->name);
				print_error(udfline);
				break;
			}
			moveresult1(st,result);
			break;
		}
		if (test_key()==escape) 
		{	output("User interrupted!\n"); error=58; break; 
		}
	}
	endlocal=oldendlocal; startlocal=oldstartlocal;
	running=oldrunning;
	if (trace>=0) trace=oldtrace;
	if (error) output1("Error in function %s\n",var->name);
	if (udfon==0)
	{	output1("Return missing in %s!\n",var->name); error=55; }
	udfon=udfold; next=oldnext; udfline=udflineold;
	actargn=oldargn;
}

/***************** scanning ***************************/

void copy_complex (double *x, double *y)
{	*x++=*y++;
	*x=*y;
}

int scan_arguments (void)
/* look ahead for arguments */
{	int count=0,olds=nosubmref,nocount=0;
	header *hd,*hdold;
	nosubmref=1;
	while (1)
	{	scan_space();
		if (*next==')' || *next==']') break;
		if (*next==',')
			hd=new_reference(0,"");
		else
		{	hd=scan(); scan_space();
		}
		if (*next=='=')
		{	next++;
			hdold=(header *)newram;
			scan_value();
			if (!error)
			{	strcpy(hdold->name,hd->name);
				hdold->xor=hd->xor;
				moveresult(hd,hdold);
				nocount=1;
			}
		}
		else if (nocount)
		{	output("Illegal parameter after named parameter!\n");
			error=2700;
		}
		if (error)
		{	nosubmref=olds;
			return 0;
		}
		while (hd<(header *)newram)
		{	if (!nocount) count++;
			hd=nextof(hd);
		}
		if (count>=10)
		{	output("To many arguments!\n"); error=56; return 0; }
		if (*next!=',') break;
		next++;
	}
	if (*next!=')' && *next!=']')
	{	output("Error in arguments!\n"); error=19; return 0; }
	next++;
	nosubmref=olds;
	return count;
}

void scan_matrix (void)
/***** scan_matrix
	scan a matrix from input.
	form: [x y z ... ; v w u ...],
	where x,y,z,u,v,w are sums.
*****/
{	header *hd,*result;
	dims *d;
	int c,r,count,i,j,complex=0;
	LONG ic;
	size_t allcount;
	double *m,*ms,cnull[2]={0,0};
	hd=new_matrix(0,0,""); /* don't know how big it will be! */
	if (error) return;
	count=0;
	getmatrix(hd,&r,&c,&m); ms=m;
	r=0; c=0;
	scan_space();
	while (1)
	{	scan_space();
		if (*next==0) { next_line(); scan_space(); }
			/* matrix is allowed to pass line ends */
		if (*next==';' || *next==']') 
			/* new column starts */
		{	if (*next==';') next++;
			if ((char *)(ms+count*(r+1))>=ramend)
			{	output("Memory overflow!\n"); error=18; return;
			}
			if (count>c) /* this column is to long */
			{	if (r>0) /* expand matrix */
				{	for (j=count-1; j>=0; j--)
					{	if (complex) copy_complex(cmat(ms,count,r,j),
							cmat(ms,c,r,j));
						else *mat(ms,count,r,j)=*mat(ms,c,r,j);
					}
					for (i=r-1; i>=0; i--)
					{	if (i>0)
						for (j=c-1; j>=0; j--)
						{	if (complex) 
								copy_complex(cmat(ms,count,i,j),
									cmat(ms,c,i,j));
							else *mat(ms,count,i,j)=*mat(ms,c,i,j);
						}
						for (j=c; j<count; j++)
						if (complex) copy_complex(cmat(ms,count,i,j),
							cnull);
						else *mat(ms,count,i,j)=0.0;
					}
				}
				c=count;
			}
			else if (count<c)
			{	for (j=count; j<c; j++)
					if (complex) copy_complex(cmat(ms,c,r,j),
							cnull);
					else *mat(ms,c,r,j)=0.0;
			}
            r++; newram=(char *)(ms+(complex?2l:1l)*(LONG)c*r);
			m=(double *)newram;
			count=0;
		}
		if (*next==']') break;
		if (*next==',') next++;
		if (*next==0) next_line();
		result=scan_value(); if (error) return;
		newram=(char *)result;
		if (!complex && result->type==s_complex)
		{	complex=1;
			/* make matrix complex up to now (oh boy!) */
			allcount=((char *)m-(char *)ms)/sizeof(double);
			if (newram+allcount*sizeof(double)+result->size>ramend)
			{	output("Memory overflow!\n"); error=16; return;
			}
			if (allcount)
			{	memmove(newram+allcount*sizeof(double),newram,result->size);
				result=(header *)((char *)result+allcount*sizeof(double));
				for (ic=allcount-1; ic>0; ic--)
                {   *(ms+(LONG)2*ic)=*(ms+ic); 
                	*(ms+(LONG)2*ic+1)=0.0;
				}
				*(ms+1)=0.0;
            newram=(char *)(ms+(LONG)2*allcount); m=(double *)newram;
			}
			hd->type=s_cmatrix;
		}
		else if (result->type==s_real);
		else if (result->type==s_complex && complex);
		else
		{	error=-1; output("Illegal vector!\n"); return;
		}
		*m++=*realof(result); count++;
		if (complex)
		{	if (result->type==s_complex) *m++=*imagof(result);
			else *m++=0.0;
		}
		if (count>=INT_MAX)
		{	output1("Matrix has more than %d columns!\n",INT_MAX);
			error=17; return;
		}
		newram=(char *)m;
		if (newram>=ramend) 
		{	output("Memory overflow!\n"); error=16; return; 
		}
	}
	next++;
	d=(dims *)(hd+1);
	if (c==0) r=0;
	d->c=c; d->r=r;
	if (r>=INT_MAX)
	{	output1("Matrix has more than %d rows!\n",INT_MAX);
		error=18; return;
	}
	hd->size=complex?cmatrixsize(c,r):matrixsize(c,r);
	newram=(char *)hd+hd->size;
}

void scan_elementary (void)
/***** scan_elemtary
	scan an elementary expression, like a value or variable.
	scans also (...).
*****/
{	double x;
	int n,nargs=0,hadargs=0;
	header *hd=(header *)newram,*var;
	char name[16],*s;
	scan_space();
	if ((*next=='.' && isdigit(*(next+1))) || isdigit(*next))
	{	sscanf(next,"%lf%n",&x,&n);
		next+=n;
		if (*next=='i') /* complex number! */
		{	next++;
			new_complex(0,x,"");
		}
		else new_real(x,"");
	}
	else if (*next==2) /* a double stored in binary form */
	{	next++;
#ifdef SPECIAL_ALIGNMENT
		memmove((char *)(&x),next,sizeof(double));
#else
		x=*((double *)next);
#endif
		next+=sizeof(double);
		if (*next=='i') /* complex number! */
		{	next++;
			new_complex(0,x,"");
		}
		else new_real(x,"");
	}
	else if (*next==3)
	{	output("Command name used as variable!\n");
		error=4000; return;
	}
	else if (isalpha(*next))
	{	scan_name(name); if (error) return;
		scan_space(); nargs=0;
		if (*next=='{')
		{	next++; scan(); if (error) return; scan_space();
			if (*next!='}')
			{	output("} missing!\n"); error=1010; return;
			}
			next++;
			get_element1(name,hd);
			goto after;
		}
		if (*next=='(' || *next=='[') /* arguments or indices */
		{	hadargs=(*next=='[')?2:1;
			next++; nargs=scan_arguments();
			if (error) return;
		}
		if (hadargs==1 && exec_builtin(name,nargs,hd));
		else
		{	if (hadargs==2) var=searchvar(name);
			else if (hadargs==1)
			{	var=searchudf(name);
				if (!var) var=searchvar(name);
			}
			else var=searchvar(name);
			if (var && var->type==s_udf && hadargs==1)
			{	interpret_udf(var,hd,nargs); if (error) return;
			}
			else if (!var && hadargs)
			{	error=24;
				if (hadargs==2)
				output1("%s no variable!\n",name);
				else
				output1(
			"%s no function or variable, or wrong argument number!\n",
			name);
				return;
			}
			else if (var && hadargs)
			{	get_element(nargs,var,hd);
			}
			else hd=new_reference(var,name);
		}
	}
	else if (*next=='#' && *(next+1)!='#')
	{	next++; mindex(hd);
	}
	else if (*next=='+')
	{	next++; scan_elementary();
	}
	else if (*next=='-')
	{	next++; scan_elementary();
		if (!error) invert(hd);
	}
	else if (*next=='(')
	{	next++;
		scan(); if (error) return;
		scan_space();
		if (*next!=')')
		{	output("Closing bracket ) missing!\n");
			error=5; return;
		}
		newram=(char *)nextof(hd);
		next++;
	}
	else if (*next=='[')
	{	next++;
		scan_matrix();
	}
	else if (*next=='\"')
	{	next++; s=next; 
		while (*next!='\"' && *next!=0) next++;
		hd=new_string(s,next-s,"");
		if (*next=='\"') next++;
	}
	else error=1;
	after: if (error) return;
	/* for things, that come after an elementary expression */
	scan_space();
	if (*next=='\'') { next++; transpose(hd); }
	else if (*next=='^' || (*next=='*' && *(next+1)=='*'))
	{	if (*next=='^') next++; 
		else next+=2;
		newram=(char *)nextof(hd);
		scan_elementary();
		if (error) return;
		mpower(hd);
	}
}

void scan_factor (void)
{	scan_elementary();
}

void scan_summand (void)
{	header *hd=(header *)newram,*hd1;
	scan_space();
	scan_factor();
	if (error) return;
	while (1)
	{	hd1=(header *)newram;
		scan_space();
		if ((*next=='*' && *(next+1)!='*') 
				|| (*next=='.' && *(next+1)=='*'))
		{	if (*next=='*') next++;
			else next+=2;
			scan_factor();
			if (!error) dotmultiply(hd,hd1);
		}
		else if (*next=='/' || (*next=='.' && *(next+1)=='/'))
		{	if (*next=='/') next++;
			else next+=2;
			scan_factor();
			if (!error) dotdivide(hd,hd1);
		}
		else if (*next=='.') 
		{	next++;
			scan_factor();
			if (!error) multiply(hd,hd1);
		}
		else if (*next=='\\')
		{	next++;
			newram=(char *)nextof(hd);
			scan_factor();
			if (!error) msolve(hd);
		}
		else break;
		if (error) break;
	}
}

void scan_summe (void)
{	header *hd=(header *)newram,*hd1;
	scan_space();
	scan_summand();
	if (error) return;
	while (1)
	{	hd1=(header *)newram;
		scan_space();
		if (*next=='+')
		{	next++;
			scan_summand();
			if (!error) add(hd,hd1);
		}
		else if (*next=='-')
		{	next++;
			scan_summand();
			if (!error) subtract(hd,hd1);
		}
		else break;
		if (error) break;
	}
}

void scan_dp (void)
{	header *hd=(header *)newram,*hd1,*hd2;
	scan_space();
	if (*next==':')
	{	next++;
		new_command(c_allv);
		return;
	}
	scan_summe();
	if (*next==':') /* a vector a:b:c or a:c */
	{	next++;
		hd1=(header *)newram; scan_summe();
		if (error) return;
		scan_space();
		if (*next==':')
		{	next++; hd2=(header *)newram; 
			scan_summe(); if (error) return;
		}
		else
		{	hd2=hd1; hd1=new_real(1.0,"");
		}
		if (error) return;
		vectorize(hd,hd1,hd2);
	}
}

void scan_compare (void)
{	header *hd=(header *)newram;
	scan_space();
	if (*next=='!')
	{	next++; scan_compare(); mnot(hd); return;
	}
	scan_dp(); if (error) return;
	scan_space();
	if (*next=='<')
	{	next++;
		newram=(char *)nextof(hd);
		if (*next=='=')
		{	next++; scan_dp(); if (error) return; mlesseq(hd); return;
		}
		else if (*next=='>')
		{	next++; scan_dp(); if (error) return; munequal(hd); return;
		}
		scan_dp(); if (error) return;
		mless(hd);
	}
	else if (*next=='>')
	{	next++; 
		newram=(char *)nextof(hd);
		if (*next=='=')
		{	next++; scan_dp(); if (error) return; mgreatereq(hd); return;
		}
		scan_dp(); if (error) return;
		mgreater(hd);
	}
	else if (*next=='=' && *(next+1)=='=')
	{	next+=2;
		newram=(char *)nextof(hd);
		scan_dp(); if (error) return;
		mequal(hd);
	}
	else if (*next=='~' && *(next+1)=='=')
	{	next+=2; 
		newram=(char *)nextof(hd);
		scan_dp(); if (error) return;
		maboutequal(hd);
	}
	else if (*next=='!' && *(next+1)=='=')
	{	next+=2; 
		newram=(char *)nextof(hd);
		scan_dp(); if (error) return;
		munequal(hd);
	}
	else if (*next=='_')
	{	next++;
		newram=(char *)nextof(hd);
		scan_compare(); if (error) return;
		mvconcat(hd);
	}
	else if (*next=='|' && *(next+1)!='|')
	{	next++;
		newram=(char *)nextof(hd); 
		scan_compare(); if (error) return;
		mhconcat(hd);
	}
}

void scan_logical (void)
{	header *hd=(header *)newram;
	scan_compare(); if (error) return;
	scan_space();
	if (*next=='|' && *(next+1)=='|')
	{	next+=2; 
		newram=(char *)nextof(hd);
		scan_compare(); if (error) return;
		mor(hd);
	}
	else if (*next=='&' && *(next+1)=='&')
	{	next+=2; 
		newram=(char *)nextof(hd);
		scan_compare(); if (error) return;
		mand(hd);
	}
}

header *scan (void)
{	header *result=(header *)newram;
	scan_space();
	if (*next=='{')
	{	next++; scan_logical(); if (error) return result;
		while (1)
		{	scan_space();
			if (*next=='}') { next++; return result; }
			if (*next!=',')
			{	output("Error in {}!\n"); error=104; return result;
			}
			next++; scan_logical();
			if (error) return result;
		}
	}
	else
	{	scan_logical();
	}
	return result;
}

header *scan_value (void)
{	header *result=(header *)newram,*hd,*hd1,*marker,*nextresult,
		*endresults;
	int oldnosubmref;
	size_t size;
	scan_space();
	if (*next=='{')
	{	next++; 
		oldnosubmref=nosubmref; nosubmref=1; 
		scan_logical(); nosubmref=oldnosubmref;
		hd1=getvalue(result);
		if (error) return result;
		moveresult(result,hd1);
		while (1)
		{	scan_space();
			if (*next=='}') { next++; return result; }
			if (*next!=',')
			{	output("Error in {}!\n"); error=104; return result;
			}
			next++; hd=(header *)newram; scan_value();
			if (error) return result;
			hd1=getvalue(hd); if (error) return result;
			moveresult(hd,hd1);
		}
	}
	else
	{	scan_logical();
		marker=result;
		endresults=(header *)newram;
		while (marker<endresults)
		{	hd1=getvalue(marker);
			if (error) return result;
			nextresult=nextof(marker);
			if (hd1!=marker)
			{	if (nextresult==endresults)
				{	memmove((char *)marker,(char *)hd1,hd1->size);
					newram=(char *)nextof(marker);
					break;
				}
				size=hd1->size-marker->size;
				memmove((char *)nextresult+size,(char *)nextresult,
					newram-(char *)nextresult);
				if (hd1>nextresult) 
					hd1=(header *)((char *)hd1+size);
				nextresult=(header *)((char *)nextresult+size);
				endresults=(header *)((char *)endresults+size);
				memmove((char *)marker,(char *)hd1,hd1->size);
				newram=(char *)endresults;
			}
			marker=nextresult;
		}
	}
	return result;
}
