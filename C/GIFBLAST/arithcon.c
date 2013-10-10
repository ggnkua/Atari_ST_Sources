/* arithcon.c - Arithmetic coding context routines. */

#include <stdio.h>
#include <string.h>

#include "arithcon.h"

static void
join_big_freqs(freqs)
int *freqs;
{
	int n,i;

	n = ARCON_NCODES;
	do {
		for (i=0; i<n/2; i++)
			freqs[n+i] = freqs[2*i]+freqs[2*i+1];
		freqs += n;
		n /= 2;
	} while (n > 1);
}

static void
add_to_big_freqs(c,freqs)
int c; int *freqs;
{
	int n;

	n = ARCON_NCODES;
	do {
		(freqs[c])++;
		freqs += n;
		n /= 2;
		c /= 2;
	} while (n > 0);
}

static void
del_from_big_freqs(c,freqs)
int c; int *freqs;
{
	int n;

	n = ARCON_NCODES;
	do {
		(freqs[c])--;
		freqs += n;
		n /= 2;
		c /= 2;
	} while (n > 0);
}

static int
find_code_in_big_freqs(c,freqs)
int c; int *freqs;
{
	int start,n;

	start = 0;
	n = ARCON_NCODES;
	do {
		if ((c&1) != 0)
			start += freqs[(c&~1)];
		freqs += n;
		n /= 2;
		c /= 2;
	} while (c != 0);
	return start;
}

static int
find_freq_in_big_freqs(f,freqs,prstart)
int f; int *freqs; int *prstart;
{
	int c,n,pos;

	(*prstart) = 0;
	c = 0;
	n = 2;
	pos = 2*ARCON_NCODES-4;
	do {
		c <<= 1;
		if (freqs[pos+c] <= f) {
			(*prstart) += freqs[pos+c];
			f -= freqs[pos+c];
			c++;
		}
		n <<= 1;
		pos -= n;
	} while (pos >= 0);
	return c;
}

void
arcon_big_init(ac)
ARCON_BIG_CONTEXT *ac;
{
	int i;

	ac->count = ac->tail = 0;
	for (i=0; i<ARCON_NCODES; i++)
		ac->freqs[i] = 1;
	join_big_freqs(ac->freqs);
}

int
arcon_big_add(ac,c)
ARCON_BIG_CONTEXT *ac; int c;
{
	if (c<0 || ARCON_NCODES<=c)
		return -1;
	if (ac->count == ARCON_BIG_RBSIZE)
		del_from_big_freqs(ac->rb[ac->tail],ac->freqs);
	else
		ac->count++;
	ac->rb[ac->tail] = c;
	ac->tail = ((ac->tail+1)%ARCON_BIG_RBSIZE);
	add_to_big_freqs(c,ac->freqs);
	return 0;
}

int
arcon_big_find_range(ac,c,prstart,prend)
ARCON_BIG_CONTEXT *ac; int c; int *prstart; int *prend;
{
	int f;

	if (c<0 || ARCON_NCODES<=c)
		return 0;
	if ((f=ac->freqs[c]) > 0) {
		(*prstart) = find_code_in_big_freqs(c,ac->freqs);
		(*prend) = (*prstart) + f;
	}
	return f;
}

int
arcon_big_find_c(ac,rpos,prstart,prend)
ARCON_BIG_CONTEXT *ac;  int rpos; int *prstart; int *prend;
{
	int c;

	if (rpos<0 || arcon_big_rtot(ac)<=rpos)
		return -1;
	c = find_freq_in_big_freqs(rpos,ac->freqs,prstart);
	(*prend) = (*prstart) + ac->freqs[c];
	return c;
}

void
arcon_small_init(ac)
ARCON_SMALL_CONTEXT *ac;
{
	ac->count = ac->tail = 0;
	ac->nhits = 0;
}

int
arcon_small_add(ac,c)
ARCON_SMALL_CONTEXT *ac; int c;
{
	ARCON_CODETYPE *p;
	char *q;

	if (c<0 || ARCON_NCODES<=c)
		return -1;
	if (ac->count == ARCON_SMALL_RBSIZE) {
		p = (ARCON_CODETYPE *)memchr(ac->hits,ac->rb[ac->tail],ac->nhits);
		q = ac->hitfreqs + (p-ac->hits);
		if ((*q) > 1)
			(*q)--;
		else {
			(*p) = ac->hits[--(ac->nhits)];
			(*q) = ac->hitfreqs[ac->nhits];
		}
	} else
		ac->count++;
	ac->rb[ac->tail] = c;
	ac->tail = ((ac->tail+1)%ARCON_SMALL_RBSIZE);
	p = (ARCON_CODETYPE *)memchr(ac->hits,c,ac->nhits);
	if (p == NULL) {
		ac->hits[ac->nhits] = c;
		ac->hitfreqs[ac->nhits++] = 1;
	} else
		ac->hitfreqs[(p-ac->hits)]++;
	return 0;
}

int
arcon_small_find_range(ac,c,prstart,prend)
ARCON_SMALL_CONTEXT *ac; int c; int *prstart; int *prend;
{
	ARCON_CODETYPE *p;
	char *q;
	int f;

	if (c<0 || ARCON_NCODES<=c || ac->nhits==0
		|| (p=(ARCON_CODETYPE *)memchr(ac->hits,c,ac->nhits))==NULL)
		return 0;
	q = ac->hitfreqs + (p-ac->hits);
	(*prstart) = 0;
	f = *q;
	while (q != ac->hitfreqs)
		(*prstart) += *--q;
	(*prend) = (*prstart) + f;
	return f;
}

int
arcon_small_find_c(ac,rpos,prstart,prend)
ARCON_SMALL_CONTEXT *ac; int rpos; int *prstart; int *prend;
{
	char *q;

	if (rpos<0 || ac->count<=rpos)
		return -1;
	(*prstart) = 0;
	q = ac->hitfreqs;
	while ((*prstart)+(*q) <= rpos)
		(*prstart) += (*(q++));
	(*prend) = (*prstart)+(*q);
	return ac->hits[(q-ac->hitfreqs)];
}

void
arcon_type_init(ac)
ARCON_TYPE_CONTEXT *ac;
{
	int i;

	for (i=0; i<ARCON_NTYPES; i++)
		ac->freqs[i] = 1;
	ac->totfreq = ARCON_NTYPES;
}

int
arcon_type_add(ac,c)
ARCON_TYPE_CONTEXT *ac; int c;
{
	int i;

	if (c<0 || ARCON_NTYPES<=c)
		return -1;
	(ac->freqs[c])++;
	ac->totfreq++;
	if (ac->totfreq > ARCON_MAXTYPEFREQ) {
		for (i=0; i<ARCON_NTYPES; i++)
			ac->freqs[i] = (ac->freqs[i]+1)/2;
		ac->totfreq = 0;
		for (i=0; i<ARCON_NTYPES; i++)
			ac->totfreq += ac->freqs[i];
	}
	return 0;
}

int
arcon_type_rtot(ac,t)
ARCON_TYPE_CONTEXT *ac; int t;
{
	int i,res;

	res = 0;
	for (i=0; i<=t; i++)
		res += ac->freqs[i];
	return res;
}

int
arcon_type_find_range(ac,c,prstart,prend)
ARCON_TYPE_CONTEXT *ac; int c; int *prstart; int *prend;
{
	int i;

	if (c<0 || ARCON_NTYPES<=c)
		return 0;
	(*prstart) = 0;
	for (i=0; i<c; i++)
		(*prstart) += ac->freqs[i];
	(*prend) = (*prstart)+ac->freqs[c];
	return ac->freqs[c];
}

int
arcon_type_find_c(ac,rpos,prstart,prend)
ARCON_TYPE_CONTEXT *ac; int rpos; int *prstart; int *prend;
{
	int i;

	if (rpos<0 || ac->totfreq<=rpos)
		return -1;
	(*prstart) = i = 0;
	while ((*prstart)+ac->freqs[i] <= rpos)
		(*prstart) += ac->freqs[i++];
	(*prend) = (*prstart)+ac->freqs[i];
	return i;
}
