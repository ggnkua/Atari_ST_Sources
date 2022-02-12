/*
 * (c) copyright 1988 by the Vrije Universiteit, Amsterdam, The Netherlands.
 * See the copyright notice in the ACK home directory, in the file "Copyright".
 *
 *
 * Module:	range checks for LONGCARD
 * Author:	Ceriel J.H. Jacobs
 * Version:	$Header: rckul.c,v 1.2 91/03/06 10:20:09 ceriel Exp $
*/

#include <em_abs.h>

extern TRP();

struct range_descr {
  unsigned long	low, high;
};

rckul(descr, val)
  struct range_descr *descr;
  unsigned long val;
{
  if (val < descr->low || val > descr->high) TRP(ERANGE);
}
