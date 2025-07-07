/* ATOF function for Sozobon C.						*/
/* Copyright ½ David Brooks, 1989 All Rights Reserved			*/

/* Hack warning.  Hack warning.  Hack warning...			*/
/* Somehow I feel scanf should call atof, not the other way around.	*/
/* Guys???								*/

float atof(s)
char *s;
{	float	res;

	sscanf(s, "%g", &res);
	return res;
}

_scandum()
{
	_scanf();			/* Force floating version to load */
}
