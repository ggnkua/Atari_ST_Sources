/*
 * (c) copyright 1988 by the Vrije Universiteit, Amsterdam, The Netherlands.
 * See the copyright notice in the ACK home directory, in the file "Copyright".
 *
 * Author: Ceriel J.H. Jacobs
 */
/* $Header: fabs.c,v 1.1 89/05/10 16:01:17 eck Exp $ */

double
fabs(double x)
{
	return  x < 0 ? -x : x;
}
