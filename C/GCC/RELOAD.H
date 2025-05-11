/* Communication between reload.c and reload1.c.
   Copyright (C) 1987 Free Software Foundation, Inc.

This file is part of GNU CC.

GNU CC is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY.  No author or distributor
accepts responsibility to anyone for the consequences of using it
or for whether it serves any particular purpose or works at all,
unless he says so in writing.  Refer to the GNU CC General Public
License for full details.

Everyone is granted permission to copy, modify and redistribute
GNU CC, but only under the conditions described in the
GNU CC General Public License.   A copy of this license is
supposed to have been given to you along with GNU CC so you
can know your rights and responsibilities.  It should be in a
file named COPYING.  Among other things, the copyright notice
and this notice must be preserved on all copies.  */


/* See reload.c and reload1.c for comments on these variables.  */

extern rtx reload_in[FIRST_PSEUDO_REGISTER];
extern rtx reload_out[FIRST_PSEUDO_REGISTER];
extern enum reg_class reload_reg_class[FIRST_PSEUDO_REGISTER];
extern enum machine_mode reload_inmode[FIRST_PSEUDO_REGISTER];
extern enum machine_mode reload_outmode[FIRST_PSEUDO_REGISTER];
extern char reload_strict_low[FIRST_PSEUDO_REGISTER];
extern char reload_optional[FIRST_PSEUDO_REGISTER];
extern int reload_inc[FIRST_PSEUDO_REGISTER];
extern int n_reloads;

extern rtx reload_reg_rtx[FIRST_PSEUDO_REGISTER];

extern rtx *reg_equiv_constant;
extern rtx *reg_equiv_address;

/* First uid used by insns created by reload in this function.
   Used in find_equiv_reg.  */
extern int reload_first_uid;

void init_reload ();
void find_reloads ();
void subst_reloads ();
