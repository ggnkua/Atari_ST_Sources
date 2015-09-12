
/* Basic -> 'C' šbersetzung */

#include <b_nach_c.h>

/* Globale Variablen */

int CHAR;

double	h_doub;
double	w_doub;
double	x_doub;
double	y_doub;
double	h_doub;

void	main()
	{
	r_ein(1);
	CHAR = C_HAR;

	box( 100,100,400,300);
	x_doub=200;
	y_doub=200;
	w_doub=300;
	h_doub=150;
	box( x_doub,y_doub,x_doub+w_doub,y_doub+h_doub);
	/*  */
	HVA = rc_intersect(100,100,300,200,x_doub,y_doub,w_doub,h_doub);
	if(HVA)
		{
		pbox( x_doub,y_doub,x_doub+w_doub,y_doub+h_doub);
		}
	r_aus(0);
	}