# define MAIN 1
# define TEST 0

# include <stdio.h>
# include <stdlib.h>
# include <ctype.h>
# include <math.h>

# include "3d.h"

# if MAIN
extern void print_trans ( Transform *t ) ;
extern void print_tmat ( Tmatrix *m ) ;
# endif


# if 0
/*-------------------------------------- transform ----------------*/
void transform ( Point *out, Tmatrix *m, Point *in )
{
	int	  i, j ;
	Value h ;
	
	for(j=0;j<N;j++)
	{
		for(i=0;i<N;i++)
		h = 0.0 ;
			h += (*in)[i] * (*m)[i][j] ;
		(*out)[j] = h ;
	}
}
# endif

/*-------------------------------------------------- transform -----*/
void transform ( Tmatrix *m, Point *in, Point *out )
{
	(*out)[X] = (*in)[X] * (*m)[X][X] + (*in)[Y] * (*m)[X][Y] + (*in)[Z] * (*m)[X][Z] + (*m)[X][D] ;
	(*out)[Y] = (*in)[X] * (*m)[Y][X] + (*in)[Y] * (*m)[Y][Y] + (*in)[Z] * (*m)[Y][Z] + (*m)[Y][D] ;
	(*out)[Z] = (*in)[X] * (*m)[Z][X] + (*in)[Y] * (*m)[Z][Y] + (*in)[Z] * (*m)[Z][Z] + (*m)[Z][D] ;
}

/*------------------------------------------------- calc_tmat ------*/
void calc_tmat ( Transform *t, Tmatrix *m )
{
	register Value	cost, sint ;
	Value			coso, sino, cosp, sinp ;
	
	cost	= cos(t->theta) ;
	sint	= sin(t->theta) ;
	coso	= cos(t->omega) ;
	sino	= sin(t->omega) ;
	cosp	= cos(t->phi) ;
	sinp	= sin(t->phi) ;
	
	(*m)[X][X]	=	t->sx * cost * coso ;
	(*m)[X][Y]	= - t->sy * sint * coso ;
	(*m)[X][Z]	=	t->sz * sino ;
	(*m)[X][D]	= ( t->dx * cost - t->dy * sint ) * coso + t->dz * sino ;
	
	(*m)[Y][X]	=	t->sx * ( sint * cosp + cost * sino * sinp ) ;
	(*m)[Y][Y]	=	t->sy * ( cost * cosp - sint * sino * sinp ) ;
	(*m)[Y][Z]	= -	t->sz * coso * sinp ;
	(*m)[Y][D]	= ((t->dx * cost - t->dy * sint) * sino - t->dz * coso ) * sinp
					+ ( t->dx * sint + t->dy * cost ) * cosp ;
	
	(*m)[Z][X]	=	t->sx * ( sint * sinp - cost * sino * cosp ) ;
	(*m)[Z][Y]	=	t->sy * ( cost * sinp + sint * sino * cosp ) ;
	(*m)[Z][Z]	=	t->sz * coso * cosp ;
	(*m)[Z][D]	= ((- t->dx * cost + t->dy * sint) * sino + t->dz * coso ) * cosp
					+ ( t->dx * sint + t->dy * cost ) * sinp ;
}

/*-------------------------------------- multiply_tmat ----------------*/
void multiply_tmat ( Tmatrix *out, Tmatrix *a, Tmatrix *b )
/* out = a * b	*/
{
	int	  i, j ;
	
# if MAIN && TEST == 1
	printf ( "+ multiply_tmat\n" ) ;
	printf ( "a:\n" ) ;
	print_tmat ( a ) ;
	printf ( "b:\n" ) ;
	print_tmat ( a ) ;
# endif
	
	for(i=X;i<=Z;i++)
	{
		for(j=X;j<=D;j++)
			(*out)[i][j] =  (*a)[0][j] * (*b)[i][0]
						  + (*a)[1][j] * (*b)[i][1]
						  + (*a)[2][j] * (*b)[i][2] ;
		(*out)[i][D] += (*b)[i][D] ; 
	}
# if MAIN && TEST == 1
	printf ( "out:\n" ) ;
	print_tmat ( a ) ;
	printf ( "- multiply_tmat\n" ) ;
# endif
}


/*-------------------------------------- asg_tmat ----------------*/
void asg_tmat ( Tmatrix *out, Tmatrix *in )
/* out = a * b	*/
{
	int	  i ;
	Value *vpin, *vpout ;
	
	vpin  = &(*in)[0][0] ;
	vpout = &(*out)[0][0] ;
	for ( i=X*X; i<=(Z+1)*(D+1)-1; i++ )	*vpout++ = *vpin++ ;
}

/*-------------------------------------- equal_tmat ----------------*/
bool equal_tmat ( Tmatrix *a, Tmatrix *b )
/* out = a * b	*/
{
	int	  i ;
	Value *vpa, *vpb ;
	
	vpa = &(*a)[0][0] ;
	vpb = &(*b)[0][0] ;
	for ( i=X*X; i<=(Z+1)*(D+1)-1; i++ )
		if ( *vpa++ != *vpb++ ) return ( FALSE ) ;
	return ( TRUE ) ;
}



Point Zero = { 0.0, 0.0, 0.0 } ;
Point One  = { 1.0, 1.0, 1.0 } ;


/*-------------------------------------------------- trans_ident -----*/
void trans_ident ( Transform *t )
{
	int dim ;
	
	for ( dim=X; dim<=Z; dim++)
	{
		t->rotate[dim]	  = 0.0 ;	
		t->scale[dim]	  = 1.0 ;	
		t->translate[dim] = 0.0 ;	
	}
}


/*-------------------------------------------------- value_to_int -----*/
int value_to_int ( Value v )
{
	if ( v < MIN_2D_X || v > MIN_2D_X ) return ( UNDEF_XY ) ;
	else return ( (int)v ) ;
}

/*-------------------------------------------------- point_to_2d -----*/
void point_to_2d ( Point *p3, Ipoint2 *p2 )
{
	p2->x = value_to_int ( (*p3)[X] ) ;
	p2->y = value_to_int ( (*p3)[Y] ) ;
}



/*-------------------------------------------------- asg_point -----*/
void asg_point ( Point *d, Point *s )
{
	(*d)[X] = (*s)[X] ;
	(*d)[Y] = (*s)[Y] ;
	(*d)[Z] = (*s)[Z] ;
}


/*-------------------------------------------------- set_point -----*/
void set_point ( Point *d, Value x, Value y, Value z )
{
	(*d)[X] = x ;
	(*d)[Y] = y ;
	(*d)[Z] = z ;
}


/*-------------------------------------------------- ident_trans -----*/
void ident_trans ( Transform *t )
{
	asg_point ( &t->translate, &Zero ) ;
	asg_point ( &t->scale,	   &One ) ;
	asg_point ( &t->rotate,	   &Zero ) ;
}

/*-------------------------------------------------- translate_trans -*/
void translate_trans ( Transform *t, Value x, Value y, Value z )
{
	set_point ( &t->translate, x, y, z ) ;
	asg_point ( &t->scale,	   &One ) ;
	asg_point ( &t->rotate,	   &Zero ) ;
}

/*-------------------------------------------------- scale_trans -----*/
void scale_trans ( Transform *t, Value x, Value y, Value z )
{
	asg_point ( &t->translate, &Zero ) ;
	set_point ( &t->scale,	   x, y, z ) ;
	asg_point ( &t->rotate,	   &Zero ) ;
}

/*-------------------------------------------------- rotate_trans ----*/
void rotate_trans ( Transform *t, Value th, Value om, Value ph )
{
	asg_point ( &t->translate, &Zero ) ;
	asg_point ( &t->scale,	   &One ) ;
	set_point ( &t->rotate,	   th, om, ph ) ;
}

/*------------------------------------------------- multiply_trans ---*/
void multiply_trans ( Tmatrix *m, Transform *t )
{
	Tmatrix a,b ;

# if MAIN && TEST == 2
	printf ( "- multiply_trans\n" ) ;
	printf ( "m-in:\n" ) ;
	print_tmat ( m ) ;
	printf ( "t:\n" ) ;
	print_trans ( t ) ;
# endif

	calc_tmat ( t, &a ) ;
	asg_tmat ( &b, m ) ;
# if MAIN && TEST == 2
	printf ( "after b := m\n" ) ;
	print_tmat ( &b ) ;
# endif
	multiply_tmat ( m, &a, &b ) ;
# if MAIN && TEST == 2
	printf ( "m-out:\n" ) ;
	print_tmat ( m ) ;
	printf ( "- multiply_trans\n" ) ;
# endif
}

/*-------------------------------------------------- translate_tmat -*/
void translate_tmat ( Tmatrix *m, Value x, Value y, Value z )
{
	Transform t ;
	
	translate_trans ( &t, x, y, z ) ;
	multiply_trans ( m, &t ) ;
}

/*-------------------------------------------------- scale_tmat -----*/
void scale_tmat ( Tmatrix *m, Value x, Value y, Value z )
{
	Transform t ;
	
	scale_trans ( &t, x, y, z ) ;
	multiply_trans ( m, &t ) ;
}

/*-------------------------------------------------- rotate_tmat ----*/
void rotate_tmat ( Tmatrix *m, Value th, Value om, Value ph )
{
	Transform t ;
	
	rotate_trans ( &t, th, om, ph ) ;
	multiply_trans ( m, &t ) ;
}




# if MAIN
/*-------------------------------------------------- print_trans -----*/
void print_trans ( Transform *t )
{
	printf ( "rotate    : [ %#8f %#8f %#8f ]\n",
				 t->rotate[X], t->rotate[Y], t->rotate[Z] ) ;
	printf ( "scale     : [ %#8f %#8f %#8f ]\n",
				 t->scale[X], t->scale[Y], t->scale[Z] ) ;
	printf ( "translate : [ %#8f %#8f %#8f ]\n",
				 t->translate[X], t->translate[Y], t->translate[Z] ) ;
}

/*-------------------------------------------------- print_tmat -----*/
void print_tmat ( Tmatrix *m )
{
	int dim ;
	
	for ( dim=X; dim<=D; dim++)
	{
		printf ( "[ %#8f %#8f %#8f ]\n",
					 (*m)[X][dim], (*m)[Y][dim], (*m)[Z][dim] ) ;
	}
}

Transform t0, t1 ;
Tmatrix	  m0, m1 ;

/*------------------------------------------------- main ---------*/
int main(void)
{
	printf ( "\033H\033E+ 3D - Test\n\n" ) ;

	
	set_point ( &t0.translate,  2,  3,  4 ) ;
	set_point ( &t0.scale,	    10, 100, 1000 ) ;
	set_point ( &t0.rotate,     0,  0,  0 ) ;
	print_trans ( &t0 ) ;
	calc_tmat ( &t0, &m0 ) ;
	print_tmat ( &m0 ) ;

	printf ("------------\n" ) ;

	ident_trans ( &t1 ) ;
	print_trans ( &t1 ) ;
	calc_tmat ( &t1, &m1 ) ;
	print_tmat ( &m1 ) ;
	translate_tmat ( &m1,  2,  3,  4 ) ;
	print_tmat ( &m1 ) ;
	scale_tmat ( &m1,	    10, 100, 1000 ) ;
	print_tmat ( &m1 ) ;

	printf ( "\n- 3D - Test\nPress RETURN !\n" ) ;
	getchar();
	return ( 0 ) ;
}
# endif