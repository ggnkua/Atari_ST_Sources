/*
 * Multitos Library for Pure C 1.0. Copyright (c) 1994, 2002 W. Klaren.
 *
 * This file is part of Teradesk.
 *
 * Teradesk is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Teradesk is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Teradesk; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

void aes(void);

int appl_getinfo(int ap_gtype,
				 int *ap_gout1, int *ap_gout2,
				 int *ap_gout3, int *ap_gout4);
int objc_sysvar(int mo, int which, int ivall, int ival2,
                 int *pival1, int *pval2);
