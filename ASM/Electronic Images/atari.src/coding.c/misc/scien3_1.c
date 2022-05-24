/************************************************************************/
/* Scientific Computing Exercise 3                                      */
/* By Martin Griffiths (CST 714), 19/02/1993.                           */
/* Commandline  usage : int x0 x1 e                                     */
/*                e.g : int 0 100 10e-6                                 */
/************************************************************************/

#include <stdio.h>
#include <math.h>

#define MAX_INT (1048576)  /*  maximum number of points (2^20 points!)	*/

typedef double (* FN) (double);

/**************************************/
/* Some prototypes too keep Gcc happy */
/**************************************/

double thefunction(double x);
double integrate1(double x0,double x1,double abserr,FN fn);
int main(int argc, char *argv[]);

/*****************************/
/* The function to integrate */
/*****************************/

double thefunction(double x)
{	return( (double) cos(x));
}

/************************************************************************/
/* Function to compute the integral :-                                  */
/*                                                                      */
/*               __ x1                                                  */
/*               |                                                      */
/*               |  f(x) dx                                             */
/*               |                                                      */
/*              -- x0                                                   */ 
/*                                                                      */
/*  using Simpson's/trapezium rule to a desired absolute error 'e'      */
/************************************************************************/

double integrate1(double x0,double x1,double e,FN f)
{	double lastsum,sum,trapsum;
	double oddsum,evensum,endsum;
	int i,n = 2;			/* start off with 2 strips */
	double h = (x1-x0)/2;		/* initial width 	   */
 	endsum   = f(x0)+f(x1);  	/* end sums                */
	oddsum   = 4*f(x0+h);
	evensum  = 0;
	/* Firstly compute the simple 3 point Simpsons/trapezium rule.	*/
	sum      = (endsum + oddsum) * (h/3);
	trapsum  = (endsum + (oddsum/2)) * (h/2);
	do
	{	printf("Current Simpson's approximation: %le\n",sum);
		printf("Current Trapezium approximation: %le\n",trapsum);
		if (n >= MAX_INT) 	/* no. of sub-intervals very  */
		{	break;		/* large? exit if so.         */
		}
		n = n + n;	/* double the number of sub-intervals */
		h = h / 2;	/* (half the interval size) 	      */
		evensum += (oddsum/2);	/* new even sum */
		oddsum = 0;		
		for (i=1 ; i<=n-1 ; i+=2)  oddsum += f(x0+(h*i)); 
		oddsum *= 4;		/* new odd sum  */
		lastsum = sum;
		/* Compute new Simpson's/trapezium approximation      */
		sum = (h/3)*(endsum+oddsum+evensum);
		trapsum = (h/2) * (endsum + (oddsum/2) + evensum);
	/* Until the desired absolute accuracy is obtained.           */
	} while ( (dabs(lastsum-sum)) > e);
	printf("Final Simpson's approximation: %le\n",sum);
	printf("Final Trapezium approximation: %le\n",trapsum);
	printf("Number of subintervals       : %d\n",n);
}

/* Main - takes command line arguments and calls the integrate function */

int main(int argc, char *argv[])
{	double e,x0,x1;
	
	if (argc == 4) 
	{	sscanf(argv[1],"%le ",&x0);
		sscanf(argv[2],"%le ",&x1);
		sscanf(argv[3],"%le",&e);
		integrate1(x0,x1,e,thefunction);
	}
	else
	{	printf("Incorrect no. of arguments\n");
		return (-1);	
	}
	return (0);	
}