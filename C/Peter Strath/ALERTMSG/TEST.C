/************************************************************************
  Test program for AlertMessage() routine.
  
  18/12/95, Peter Strath.
 ************************************************************************/

#include "alertmsg.c"


void main
	(
	void
	)
{
	int a=1, b=2, c=3;
	
	/* Basic test. */
	AlertMessage("Testing...|%d, %d, %d", a, b, c);
}