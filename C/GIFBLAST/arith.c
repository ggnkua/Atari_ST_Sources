/* arith.c - Arithmetic coding routines. */

#include <stdio.h>
#include <string.h>

#include "uffile.h"
#include "arith.h"

#define CODE_VALUE_BITS 16
#define FIRST_QUARTER (1L << (CODE_VALUE_BITS-2))
#define HALF (2*FIRST_QUARTER)
#define THIRD_QUARTER (3*FIRST_QUARTER)
#define TOP_VALUE ((1L<<CODE_VALUE_BITS) - 1)

int
arith_start_encoding(ac,ff)
ARITH_CODER *ac; FFILE *ff;
{
	if (ff == NULL)
		return -1;
	ac->ff = ff;
	ff_start1bit(ac->ff);
	ac->low = 0L;
	ac->high = TOP_VALUE;
	ac->u.e.bits_to_follow = 0L;
	return 0;
}

static int
f_bit_plus_follow(ac,bit)
ARITH_CODER *ac; int bit;
{
	if (ff_put1bit(ac->ff,bit) < 0)
		return -1;
	bit = !bit;
	for (; ac->u.e.bits_to_follow>0; ac->u.e.bits_to_follow--)
		if (ff_put1bit(ac->ff,bit) < 0)
			return -1;
	return 0;
}

#define bit_plus_follow(ac,bit) ((ac)->u.e.bits_to_follow==0 \
	? ff_put1bit((ac)->ff,(bit)) : f_bit_plus_follow(ac,bit))

int
arith_encode(ac,rstart,rend,rtot)
ARITH_CODER *ac; int rstart; int rend; int rtot;
{
	long iwidth;
	register unsigned int high,low;

	iwidth = ac->high+1-ac->low;
	high = (unsigned int)(ac->low + (iwidth*rend)/rtot - 1);
	low = (unsigned int)(ac->low + (iwidth*rstart)/rtot);
	for (;;) {
		if (high < HALF) {
			if (bit_plus_follow(ac,0) < 0)
				return -1;
		} else if (HALF <= low) {
			if (bit_plus_follow(ac,1) < 0)
				return -1;
			low -= HALF;
			high -= HALF;
		} else if (FIRST_QUARTER<=low && high<THIRD_QUARTER) {
			ac->u.e.bits_to_follow++;
			low -= FIRST_QUARTER;
			high -= FIRST_QUARTER;
		} else {
			ac->high = high;
			ac->low = low;
			return 0;
		}
		low <<= 1;
		high <<= 1;
		high++;
	}
}

int
arith_end_encoding(ac)
ARITH_CODER *ac;
{
	int bit,i;

	ac->u.e.bits_to_follow++;
	bit = (ac->low >= FIRST_QUARTER);
	if (bit_plus_follow(ac,bit) < 0)
		return -1;
	for (i=0; i<CODE_VALUE_BITS-2; i++)
		if (ff_put1bit(ac->ff,0) < 0)
			return -1;
	return ff_end1bit(ac->ff);
}

int
arith_start_decoding(ac,ff)
ARITH_CODER *ac; FFILE *ff;
{
	int i,bit;

	if (ff == NULL)
		return -1;
	ac->ff = ff;
	ff_start1bit(ac->ff);
	ac->low = 0L;
	ac->high = TOP_VALUE;
	ac->u.d.value = 0L;
	for (i=0; i<CODE_VALUE_BITS; i++) {
		if ((bit=ff_get1bit(ac->ff)) < 0)
			return -1;
		ac->u.d.value <<= 1;
		ac->u.d.value |= bit;
	}
	return 0;
}

int
arith_decode_getrpos(ac,rtot)
ARITH_CODER *ac; int rtot;
{
	return ((ac->u.d.value+1-ac->low)*rtot - 1) / (ac->high+1-ac->low);
}

int
arith_decode_advance(ac,rstart,rend,rtot)
ARITH_CODER *ac; int rstart; int rend; int rtot;
{
	long iwidth;
	int bit;
	register unsigned int high,low,value;

	iwidth = ac->high+1-ac->low;
	high = (unsigned int)(ac->low + (iwidth*rend)/rtot - 1);
	low = (unsigned int)(ac->low + (iwidth*rstart)/rtot);
	value = (unsigned int)ac->u.d.value;
	for (;;) {
		if (high < HALF)
			/* NOTHING */;
		else if (HALF <= low) {
			value -= HALF;
			low -= HALF;
			high -= HALF;
		} else if (FIRST_QUARTER<=low && high<THIRD_QUARTER) {
			value -= FIRST_QUARTER;
			low -= FIRST_QUARTER;
			high -= FIRST_QUARTER;
		} else {
			ac->high = high;
			ac->low = low;
			ac->u.d.value = value;
			return 0;
		}
		low <<= 1;
		high <<= 1;
		high++;
		value <<= 1;
		if ((bit=ff_get1bit(ac->ff)) < 0)
			return -1;
		value |= bit;
	}
}

int
arith_end_decoding(ac)
ARITH_CODER *ac;
{
	return ff_end1bit(ac->ff);
}
