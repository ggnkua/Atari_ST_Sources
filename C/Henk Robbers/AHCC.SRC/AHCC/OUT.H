/* Copyright (c) 1988,1989 by Sozobon, Limited.  Author: Johann Ruegg
 *           (c) 1990 - present by H. Robbers.   ANSI upgrade.
 *
 * This file is part of AHCC.
 *
 * AHCC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * AHCC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with AHCC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/*
 *	out.h
 */

#define char_out(c) *out_goes++=c

typedef struct real64
{
	ulong u1, u2;
} R64;

#if FLOAT
typedef union real96
{
	double r;
	struct
	{
		ushort e1, filler;
		ulong m1, m2;
	} u;
} R96;
#endif

extern AREA_STACK *std_areas, *start_areas, *end_areas;
extern short in_class, area_id;
extern Cstr class_names[];

void set_class(void *xp, short class);

VpV		out_gp,
		out_tsw,
		end_C,
		end_S,
		write_literals,
		new_areas,
		destroy_areas;

BpV		create_areas;

VpF		out_pbegin;
void	out_fbegin(FP, TP),
		out_fret  (FP, TP),
		out_pret  (FP, TP),
		out_force_class(short class, Cstr comment);

VpN		outcode_list;

short	new_lbl(void), new_albl(short);

VpCa	add_out;

void	out_branch(bool, short);	/* 05'16 HR C goto statement */

VpI		def_lbl,
		out_anx,		/* 03'11 HR Coldfire */
		out_br,
		add_br_2_1,
		add_br_1_2,
		add_br_1_3,
		out_tlbl;

VpII	def_albl;

IpI		loop_lbl;

VpuL	out_cmp,
		out_sbx;

void	out_b		(short key, short l),
		o_nz		(long sz, short area, short aln),
		change_class(short area),
		out_arr_cmp	(Cstr name, short l),
		out_arr_end	(TP),
		out_arr_add	(TP tp),
		out_loop_clear(Cstr name),
		out_loop_inc(Cstr name),
		out_loop_rtn(void),
		out_comment	(char *s),
		send_out	(char *f, ...);

bool	out_setup	(Cstr inname),
		o_aln		(short x, short class),
		can_3q		(long val);

Cstr	mask_to_s	(RMASK m),
		regnm		(short r);
ulong	ones		(short n);


#if FLOAT
void	d80tod64(R64 *r, double v);
#endif

