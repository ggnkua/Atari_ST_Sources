
/* more kludgery

ldexp(value, exp) apparently returns value * 2 ^ exp.

there's some wierdness that happens for overflows or underflows,
but I'm not dealing with that now.
*/

double ldexp(value, exp)
double value;
int exp;
{
  long factor = 1;

  if (exp == 0) return(value);
  if (exp > 0)
	{
	for ( ; exp > 0 ; exp--)
		factor = factor * 2;
	return(value * factor);
	}
    else
	{
	exp = -exp;
	for ( ; exp > 0 ; exp--)
		factor = factor * 2;
	return(value / factor);
	}
}
