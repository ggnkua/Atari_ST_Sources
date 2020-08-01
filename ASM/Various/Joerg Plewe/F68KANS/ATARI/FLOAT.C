/*
 * main functions of double interface FLOT for F68KANS
 */
 
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <time.h>
#include "loader.h" 

long cdecl _sizeofdouble();

void cdecl to_float();
void cdecl d_to_f();
long cdecl f_to_d_low();
long cdecl f_to_d_high();
char* cdecl _ecvt();
char* cdecl _fcvt();
char* cdecl _sprintfdouble();
long cdecl _sscanfdouble();


void cdecl f_mul();
void cdecl f_plus();
void cdecl f_minus();
void cdecl f_div();
void cdecl f_floor();
void cdecl f_negate();
void cdecl f_round();

long cdecl f_depth();
void cdecl f_drop();
void cdecl f_dup();
void cdecl f_over();
void cdecl f_rot();
void cdecl f_swap();

void cdecl f_store();
void cdecl f_fetch();

long cdecl f_null_less();
long cdecl f_null_eq();
long cdecl f_less();
void cdecl f_max();
void cdecl f_min();

/* float extensions */
void cdecl f_pow();
void cdecl f_abs();
void cdecl f_acos();
void cdecl f_acosh();
void cdecl f_alog();
void cdecl f_asin();
void cdecl f_asinh();
void cdecl f_atan();
void cdecl f_atan2();
void cdecl f_atanh();
void cdecl f_cos();
void cdecl f_cosh();
void cdecl f_exp();
void cdecl f_expm1();
void cdecl f_ln();
void cdecl f_lnp1();
void cdecl f_log();
void cdecl f_sin();
void cdecl f_sincos();
void cdecl f_sinh();
void cdecl f_sqrt();
void cdecl f_tan();
void cdecl f_tanh();
long cdecl f_proximate();

/* one thing remaining from stdlib */
void cdecl _difftime();



SI_funcarr SI_FLOT_fa[] = {
	_sizeofdouble,
	
	to_float,
	d_to_f, f_to_d_low, f_to_d_high,
	_ecvt,
	_fcvt,
	_sprintfdouble, _sscanfdouble,
	
	f_mul, f_plus, f_minus, f_div,
	f_floor, f_negate, f_round,
	
	f_depth, f_drop, f_dup, f_over, f_rot, f_swap,
	
	f_store, f_fetch,
	
	f_null_less, f_null_eq, f_less, f_max, f_min,

	/* float extensions */
	f_pow,
 	f_abs,
	f_acos, f_acosh,
 	f_alog,
	f_asin, f_asinh,
 	f_atan,
 	f_atan2, f_atanh,
 	f_cos, f_cosh,
 	f_exp, f_expm1,
 	f_ln, f_lnp1, 
 	f_log,
 	f_sin, 
 	f_sincos, f_sinh,
 	f_sqrt,
 	f_tan, f_tanh,
 	f_proximate,
 	
 	_difftime
};



double floatstack[1100];			/* this is the stack + security */
double *fp = &floatstack[1000];		/* and this the stackpointer */


/************************************/
/* some things of general interest  */
/************************************/

long cdecl _sizeofdouble()
{ return sizeof(double); } 



/***************/
/* conversions */
/***************/

void cdecl to_float(char *nstr, long len)
{ 
char str[256];

	memcpy( str, nstr, (size_t)len );
	str[len] = '\0'; 

	*(--fp) = atof(str); 
}


void cdecl d_to_f( unsigned long nl, long nh)
{ *(--fp) = (double)nl + ((double)nh * 4.294967296e9); }


long cdecl f_to_d_low()
{
register float x;
	
	x = *fp;
	
	if(x >= 4.294967296e9) 
		x = x - (((long)(x/4.294967296e9)) * 4.294967296e9);  

	return (long)x; 
}

long cdecl f_to_d_high()
{
register float x;

	if( (x=(*(fp++))) < 0.0 )
		return ~(long)(x / 4.294967296e9); 
	else
		return (long)(x / 4.294967296e9); 
}

char* cdecl _ecvt( long ndig, long *dec, long *sign )
{  
char *ptr;
int d, s;

	ptr = ecvt( *(fp++), (int)ndig, &d, &s); 

	*dec = (long)d;
	*sign = (long)s;
	
	return ptr;
}


char* cdecl _fcvt( long ndig, long *dec, long *sign )
{ 
	*dec = 0L;		/* because they are long and */
	*sign = 0L; 	/* fcvt fills them 16 bit only */
 	return fcvt( *(fp++), (int)ndig, (int*)dec+1, (int*)sign+1); 
}




/************************/
/* most important: I/O	*/
/************************/

char* cdecl _sprintfdouble( char *fmt, long len, long places,
							char *outstr )
{
char str[256];

	memcpy( str, fmt, (size_t)len );
	str[len] = '\0'; 

	sprintf(outstr, str, (int)places, *(fp++));
	
	return outstr;	
}


int qnull(char*);

long cdecl _sscanfdouble( char *num, long len )
{ 
int i;
float x;
char b[100];
char str[256];

	memcpy( str, num, (size_t)len );
	str[len] = '\0'; 
	
	i = sscanf( str, "%g%s", &x, b ); 

	if( (x == 0.0 && qnull(num) == 0) || i != 1 ) return 0L;
	
	if( i == 1 )
		*(--fp) = x;
		
	return (long)i;
}


int qnull( char *s )
{
int l;
int i=0;

	l = (int)strlen(s);

	if( s[0] != '+' && s[0] != '-' && s[0] != '0' )
		return 0;

	if( s[0] != '0' ) i++;
			
	while( s[i++] == '0' );
	if( i == l )	return -1;
	
	if( s[i] != 'e' && s[i++] != 'E' )	return 0;
	
	return qnull( &s[i] );
}



/**************/
/* arithmetic */
/**************/

void cdecl f_mul()
{ 
register float x;
	x = *(fp++) * *fp;
	*fp = x;
}



void cdecl f_plus()
{ 
register float x;
	x = *(fp++) + *fp;
	*fp = x;
}


void cdecl f_minus()
{ 
register float x;
	x = *(fp+1) - *(fp++);
	*fp = x;
}


void cdecl f_div()
{ 
register float x;
	x = *(fp+1) / *(fp++);
	*fp = x;
}


void cdecl f_floor()
{ *fp = floor(*fp); }  


void cdecl f_negate()
{ *fp = -(*fp); }  


void cdecl f_round()
{ *fp = round(*fp); }  



/******************/
/* stack handling */
/******************/

long cdecl f_depth()
{ return (long)(&floatstack[1000] - fp); }


void cdecl f_drop()
{ fp++; }


void cdecl f_dup()
{ *(fp-1) = *(fp--); }


void cdecl f_over()
{ *(--fp) = *(fp+1); }


void cdecl f_rot()
{
register float x,y;

	x = *fp;
	y = *(fp+1);
	*fp = *(fp+2);
	*(fp+1) = x;
	*(fp+2) = y;
}


void cdecl f_swap()
{
register float x;

	x = *fp;
	*fp = *(fp+1);
	*(fp+1) = x;
}




/**********/
/* memory */
/**********/


void cdecl f_store( double *p )
{ *p = *(fp++); }


void cdecl f_fetch( double *p )
{ *(--fp) = *p; }



/***************/
/* comparisons */
/***************/


long cdecl f_null_less()
{ return (long)(*(fp++) < 0.0); }


long cdecl f_null_eq()
{ return (long)(*(fp++) == 0.0); }


long cdecl f_less()
{ 
	if(*(fp++) > *(fp++))
		{
		return -1L; 
		}
	else
		{
		return 0L;
		}
}


void cdecl f_max()
{ 
	if( *(fp++) > *fp )
		*fp = *(fp-1);		
}


void cdecl f_min()
{ 
	if( *(fp++) < *fp )
		*fp = *(fp-1);		
}





/************************************************************/
/*			float extensions								*/
/************************************************************/


void cdecl f_pow()
{ 
register float x;

	x = *(fp++);
	*fp = pow(*fp, x);
}


void cdecl f_abs()
{ *fp = abs(*fp); }


void cdecl f_acos()
{ *fp = acos(*fp); }


void cdecl f_acosh()
{ *fp = acosh(*fp); }


void cdecl f_alog()
{ *fp = pow(10.0, *fp); }


void cdecl f_asin()
{ *fp = asin(*fp); }


void cdecl f_asinh()
{ *fp = asinh(*fp); }


void cdecl f_atan()
{ *fp = atan(*fp); }


void cdecl f_atan2()
{ 
register float x;

	x = *(fp++);
	*fp = atan(*fp / x);
}


void cdecl f_atanh()
{ *fp = atanh(*fp); }



void cdecl f_cos()
{ *fp = cos(*fp); }

void cdecl f_cosh()
{ *fp = cosh(*fp); }


void cdecl f_exp()
{ *fp = exp(*fp); }


void cdecl f_expm1()
{ *fp = exp(*fp) - 1.0; }


void cdecl f_ln()
{ *fp = log(*fp); }


void cdecl f_lnp1()
{ *fp = log(*fp) + 1.0; }


void cdecl f_log()
{ *fp = log10(*fp); }


void cdecl f_sin()
{ *fp = sin(*fp); }


void cdecl f_sincos()
{ 
register float x;

	x = *fp;
	*fp = sin(x);
	*(--fp) = cos(x);
}


void cdecl f_sinh()
{ *fp = sinh(*fp); }



void cdecl f_sqrt()
{ *fp = sqrt(*fp); }


void cdecl f_tan()
{ *fp = tan(*fp); }

void cdecl f_tanh()
{ *fp = tanh(*fp); }


long cdecl f_proximate()
{
register float limit;
float x,y;
	limit = *(fp++);
	
	if( limit > 0.0 )
		return (long)( abs(*(fp++) - *(fp++)) < limit );
		
	if( limit == 0.0 )
		return (long)( *(fp++) == *(fp++) );

	/* limit < 0.0 */	
	x = *(fp++);
	y = *(fp++);
	return (long)( abs(*(fp++) - *(fp++)) < 
					abs( limit * ( abs(x) + abs(y) ) ) );
}





/*
 * one thing remaining from the stdlib:
 */
void cdecl _difftime( long t1, long t2 )
{ *(--fp) = difftime( t1, t2 ); }



