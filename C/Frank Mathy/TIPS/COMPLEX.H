/* Komplexe-Zahlen-Bibliothek von Frank Mathy 	*/
/* (C) 1991 TOS									*/
/* Einbinden mit #include <complex.h>			*/

#include <math.h>

typedef struct	/* Komplexe Werte in kartesischer Darstellung */
	{
	double re;	/* Realteil			*/
	double im;	/* Imagin„rteil		*/
	} komplex_kartes;

typedef struct	/* Komplexe Werte in Polardarstellung	*/
	{
	double r;	/* Radius	*/
	double phi;	/* Winkel	*/
	} komplex_polar;

/* Umwandeln von Polar- in kartesische Form */

komplex_kartes polar_to_kartes(komplex_polar z)
	{
	komplex_kartes hilf;
	hilf.re = z.r * cos(z.phi);
	hilf.im = z.r * sin(z.phi);
	return(hilf);
	}

/* Umwandeln von kartesischer in polare Form */

komplex_polar kartes_to_polar(komplex_kartes z)
	{
	komplex_polar hilf;
	hilf.r = sqrt(z.re * z.re + z.im * z.im);
	
	if(z.re == 0.0)	{ /* Wenn Nenner = Null -> rechter Winkel */
					if(z.im >= 0.0) hilf.phi = M_PI/2.0;
					else			hilf.phi = 3.0*M_PI/2.0;
					}
	else 	if(z.re < 0.0) /* 2. und 3. Quadrant */
				hilf.phi = atan(z.im / z.re) + M_PI;
			else 	if(z.im >= 0.0) /* 1. Quadrant */
						hilf.phi = atan(z.im / z.re);
					else /* 4. Quadrant */
						hilf.phi = atan(z.im / z.re) + 2.0 * M_PI;
	return(hilf);
	}

/* Addition zweier komplexer Zahlen in kartesischer Form */

komplex_kartes addcx(komplex_kartes z1,komplex_kartes z2)
	{
	z1.re += z2.re;
	z1.im += z2.im;
	return(z1);
	}

/* Subtraktion von z1 - z2 (kartesischer Form) */

komplex_kartes subcx(komplex_kartes z1,komplex_kartes z2)
	{
	z1.re -= z2.re;
	z1.im -= z2.im;
	return(z1);
	}

/* Multiplikation z1 * z2 (kartesische Form) */

komplex_kartes mulcx(komplex_kartes z1,komplex_kartes z2)
	{
	komplex_kartes res;
	res.re = z1.re * z2.re - z1.im * z2.im;
	res.im = z1.re * z2.im + z2.re * z1.im;
	return(res);
	}

/* Division z1 / z2 (kartesische Form) */

komplex_kartes divcx(komplex_kartes z1,komplex_kartes z2)
	{
	komplex_kartes res;
	res.re = (z1.re * z2.re + z1.im * z2.im) /
	        (z2.re * z2.re + z2.im * z2.im);
	res.im = (z2.re * z1.im - z1.re * z2.im) /
		    (z2.re * z2.re + z2.im * z2.im);
	return(res);
	}

/* Potenzierung z1 ^ z2 (Polarform !!!) */

komplex_polar potcx(komplex_polar z,double exponent)
	{
	z.r = pow(z.r,exponent);
	z.phi *= exponent;
	return(z);
	}
