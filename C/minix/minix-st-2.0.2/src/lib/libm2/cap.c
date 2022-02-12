/*
  (c) copyright 1988 by the Vrije Universiteit, Amsterdam, The Netherlands.
  See the copyright notice in the ACK home directory, in the file "Copyright".
*/

/*
  Module:	cap; implementation of CAP
  Author:	Ceriel J.H. Jacobs
  Version:	$Header: cap.c,v 1.2 88/06/03 09:36:08 ceriel Exp $
*/

cap(u)
	unsigned u;
{
	register unsigned *p = &u;

	if (*p >= 'a' && *p <= 'z') *p += 'A'-'a';
}
