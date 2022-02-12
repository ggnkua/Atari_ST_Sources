/*
  (c) copyright 1988 by the Vrije Universiteit, Amsterdam, The Netherlands.
  See the copyright notice in the ACK home directory, in the file "Copyright".
*/

/*
  Module:	double abs function
  Author:	Ceriel J.H. Jacobs
  Version:	$Header: absd.c,v 1.3 88/03/23 17:53:57 ceriel Exp $
*/
#ifndef NOFLOAT
double
absd(i)
	double i;
{
	return i >= 0 ? i : -i;
}
#endif
