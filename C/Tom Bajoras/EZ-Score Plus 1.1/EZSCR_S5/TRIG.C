overlay "megamax"

#include <math.h>
#include <osbind.h>

#define TRUE 	1
#define FALSE 	0

#define PI 		3.14159265358979324
#define LOGe2 	0.69314718055994531
#define LOGe10 	2.30258509299404568

double log(num)
double num;
{
	int i;
	double result, last_result;
	double temp, x;
	double top;

	x = putexp(num, 0);
	x = (x - 1)/(x + 1);
	top = x;
	x *= x;
	i = 1;
	result = top;
	do {
		last_result = result;
		top *= x;
		i += 2;
		result += top/i;
	} while (result != last_result);
	return result*2.0 + exponent(num)*LOGe2;
}

double log10(x)
double x;
{
	return log(x)/LOGe10;
}

double log2(x)
double x;
{
	return log(x)/LOGe2;
}

double exp2(x)
double x;
{
	double result, top, bot, last_result;
	double res2;
	int 	i;

	res2 = 1;
	i = x;
	if (i) 
		res2 = putexp(res2, i);
	x -= i;
	x *= LOGe2;
	result = x + 1;
	bot = 1;
	top = x;
	i = 1;
	do {
		last_result = result;
		top *= x;
		i++;
		bot *= i;
		result += top/bot;
	} while (result != last_result);
	return res2*result;
}

double exp(x)
double x;
{
	return exp2(x/LOGe2);
}

double exp10(x)
double x;
{
	return exp(x*LOGe10);
}

double sin(x)
double x;
{
	int i;
	double result;
	double last_result;
	double top, bot;
	int	   fac;
	int	  	negate = FALSE;

	if (x < 0) {
		x = -x;
		negate = TRUE;
	}
	fac = x/(2*PI);
	x -= fac*(PI*2);	/* modulo with 2PI */
	if (x > PI) {
		x -= PI;
		negate = !negate;
	}
	if (x > PI/2)
		x = PI - x;

	bot = 1;
	top = x;
	result = x;
	last_result = 0;
	fac = 0;
	i = 0;
	x *= x;
	while (last_result != result) {
		last_result = result;
		fac += 2;
		top *= x;
		bot *= fac*(fac+1);
		if (i & 1)
			result += top/bot;
		else
			result -= top/bot;
		i++;
	}
	if (negate)
		result = -result;
	return result;
}

double cos(x)
double x;
{
	return sin(x + (PI/2));
}

double tan(x)
double x;
{
	return sin(x)/cos(x);
}

double sqrt(x)
double x;
{
	double delta, old_delta, out;

	if (x <= 0) return 0;
	out = x*0.5;
	delta = 0;
	do {
		out += delta;
		old_delta = delta;
		delta = (x/out - out);
		delta = putexp(delta, exponent(delta)-1); /* delta /= 2 */
	} while (delta != 0 && delta != old_delta);
	return out;
}

double atan(x)
double x;
{
	int negative;
	double  result, top;
	double  last_result;
	int		bot;
	int		i;
	int		near1;
	int		big;


	negative = FALSE;
	big = FALSE;
	if (x < 0) {
		x = -x;
		negative = TRUE;
	}
	near1 = FALSE;
	if (x > 0.4 && x < 2.5) {
		near1 = TRUE;
		x = (1 - x)/(1 + x);
	}
	if (x > 1) {
		x = 1/x;
		big = TRUE;
	}
	bot = 1;
	result = top = x;
	x = x*x;
	i = 0;
	do {
		last_result = result;
		top *= x;
		bot += 2;
		if (++i & 1)
			result -= top/bot;
		else
			result += top/bot; 
	} while (result != last_result);
	if (near1) 
		result = PI/4 - result;
	if (big) {
		result = PI/2 - result;
	}
	if (negative)
		result = -result;
	return result;
}

double asin(x)
double x;
{
	return atan(x/sqrt(1 - x*x));
}

double acos(x)
double x;
{
	return PI/2 - asin(x);
}
