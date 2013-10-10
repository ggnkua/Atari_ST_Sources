/* gb11code.c - Special purpose GIF compressor routines (version 1.1). */

#include <stdio.h>
#include <string.h>

#include "uffile.h"
#include "arith.h"
#include "arithcon.h"
#include "gb11code.h"

int copy_if_larger=1;

static void
gb11_init(gb11)
GB11_CODER *gb11;
{
	int i;

	arcon_big_init(&gb11->ac_order_0_con);
	for (i=0; i<ARCON_NCODES; i++)
		arcon_small_init(&(gb11->ac_order_1_cons[i]));
	arcon_type_init(&gb11->ac_type_con);
	gb11->prev = 0;
}

int
gb11_start_encoding(gb11,ff)
GB11_CODER *gb11; FFILE *ff;
{
	gb11_init(gb11);
	return arith_start_encoding(&gb11->ac_struct,ff);
}

int
gb11_encode_c(c,gb11)
int c; GB11_CODER *gb11;
{
	int rstart,rend,rtot,t,trstart,trend,trtot;
	ARCON_BIG_CONTEXT *big_con;
	ARCON_SMALL_CONTEXT *small_con;
	ARCON_TYPE_CONTEXT *type_con;

	big_con = &gb11->ac_order_0_con;
	small_con = &(gb11->ac_order_1_cons[gb11->prev]);
	type_con = &gb11->ac_type_con;
	if (arcon_small_find_range(small_con,c,&rstart,&rend)) {
		t = 1;
		rtot = arcon_small_rtot(small_con);
	} else if (arcon_big_find_range(big_con,c,&rstart,&rend)) {
		t = 0;
		rtot = arcon_big_rtot(big_con);
	} else
		return -1;
	if (arcon_type_find_range(type_con,t,&trstart,&trend))
		trtot = arcon_type_rtot(type_con,1);
	else
		return -1;
	if (arith_encode(&gb11->ac_struct,trstart,trend,trtot)<0
		|| arith_encode(&gb11->ac_struct,rstart,rend,rtot)<0
		|| arcon_type_add(type_con,t)<0
		|| arcon_small_add(small_con,c)<0
		|| (t==0 && arcon_big_add(big_con,c)<0))
		return -1;
	gb11->prev = c;
	return 0;
}

int
gb11_end_encoding(gb11)
GB11_CODER *gb11;
{
	return arith_end_encoding(&gb11->ac_struct);
}

int
gb11_start_decoding(gb11,ff)
GB11_CODER *gb11; FFILE *ff;
{
	gb11_init(gb11);
	return arith_start_decoding(&gb11->ac_struct,ff);
}

int
gb11_decode_c(gb11)
GB11_CODER *gb11;
{
	int trstart,trend,trtot,trpos,t,rstart,rend,rtot,rpos,c;
	ARCON_BIG_CONTEXT *big_con;
	ARCON_SMALL_CONTEXT *small_con;
	ARCON_TYPE_CONTEXT *type_con;

	big_con = &gb11->ac_order_0_con;
	small_con = &(gb11->ac_order_1_cons[gb11->prev]);
	type_con = &gb11->ac_type_con;
	trtot = arcon_type_rtot(type_con,1);
	trpos = arith_decode_getrpos(&gb11->ac_struct,trtot);
	if ((t=arcon_type_find_c(type_con,trpos,&trstart,&trend))<0
		|| arith_decode_advance(&gb11->ac_struct,trstart,trend,trtot)<0
		|| arcon_type_add(type_con,t)<0)
		return -1;
	if (t == 0) {
		rtot = arcon_big_rtot(big_con);
		rpos = arith_decode_getrpos(&gb11->ac_struct,rtot);
		if ((c=arcon_big_find_c(big_con,rpos,&rstart,&rend))<0
			|| arith_decode_advance(&gb11->ac_struct,rstart,rend,rtot)<0
			|| arcon_big_add(big_con,c)<0
			|| arcon_small_add(small_con,c)<0)
			return -1;
	} else {
		rtot = arcon_small_rtot(small_con);
		rpos = arith_decode_getrpos(&gb11->ac_struct,rtot);
		if ((c=arcon_small_find_c(small_con,rpos,&rstart,&rend))<0
			|| arith_decode_advance(&gb11->ac_struct,rstart,rend,rtot)<0
			|| arcon_small_add(small_con,c)<0)
			return -1;
	}
	gb11->prev = c;
	return c;
}

int
gb11_end_decoding(gb11)
GB11_CODER *gb11;
{
	return arith_end_decoding(&gb11->ac_struct);
}
