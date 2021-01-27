/*  Copyright (c) 1993 - 2008 by Henk Robbers Amsterdam.
 *
 * This file is part of CALC.
 *
 * CALC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * CALC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with CALC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/*
 *		SHPARSE.H
 *
 */

typedef double PARSE_RANGE(Token o, Token l, Token r);
typedef double PARSE_DEREF(Token r, int *attr);

PARSE_NEXT shnext;
