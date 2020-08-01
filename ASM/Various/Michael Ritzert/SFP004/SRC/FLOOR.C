/*
 * floor and ceil
 * 	from pete housels posting
 */

double	modf(double, double *);

double
floor(x)
double x;
{
 double fract;

 fract = modf(x, &x);

 if(fract < 0.0)
    return x - 1.0;
 else
    return x;
}

double
ceil(x)
double x;
{
	return(-floor(-x));
}
