/*  (c) 1987 - 1991 by Han  Driesen Leiden.
 *  (c) 1996 - 2008 by Henk Robbers Amsterdam.
 *
 * This file is part of Atari Digger.
 *
 * Digger is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Digger is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Digger; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/*
 * GROUP.H
 *
 */


typedef struct
{
	uint opcode, grp;
	short r1, m1, mr, r, m;
	PC  pc;
} inst;

typedef short group(DW *dw, inst i);

#define ddir    000
#define adir    010
#define indir   020
#define postincrement  030
#define predecrement 040
#define Dind    050
#define DindX   060
#define wabs    070
#define labs    071
#define PCrel   072
#define DPCrel  073
#define Imm     074

#define d_all(mr) (mr <= Imm)

short ea  (DW *dw, short mr);
short ea2 (DW *dw, short mr);
short ea2d(DW *dw, short mr);

void  oc0 (DW *dw, char *mnem, short l);
short oc1 (DW *dw, char *mnem, short l, short mr);
short oc1l(DW *dw, char *mnem, short l, short mr);
short oc2 (DW *dw, char *mnem, short l, short m1, short m2);
short oc2l(DW *dw, char *mnem, short l, short m1, short m2);

void	reglist		(DW *dw, uint rl, short m);
short	relo		(DW *dw, PC pc);
bool	chk_pcrel	(DW *dw, short l, PC pc, BD bd);
SYMBOLIC_REL pcrel;

bool c_alt(short mr);
bool c_add(short mr);
bool m_alt(short mr);
bool d_alt(short mr);
bool d_add(short mr);
bool m_add(short mr);
bool alterable
          (short mr);

void trap_id(DW *dw, uint *pc, uint i);

short general_coprocessor(DW *dw, uint opcode, PC pc, short n, char *ccn[], char *prf);
short ea_t(DW *dw, short mr);

extern char cct[][4];
