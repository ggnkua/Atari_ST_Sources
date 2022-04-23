/**
 * Thing
 * Copyright (C) 1994-2012 Arno Welzel, Thomas Binder
 *
 * This program is free software: you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this program. If not, see
 * <http://www.gnu.org/licenses/>.
 *
 * @copyright  Arno Welzel, Thomas Binder 1994-2012
 * @author     Arno Welzel, Thomas Binder
 * @license    LGPL
 */

#if 0
/**
 * long2int
 *
 * Wandelt einen long in zwei ints
 *
 * Eingabe:
 * lword: Zu wandelnder 32-Bit-Wert
 * hi: Zeiger auf die Adresse fuer die oberen 16 Bit
 * lo: Zeiger auf die Adresse fuer die unteren 16 Bit
 */
void long2int(long lword, int *hi, int *lo) {
	*hi = (int) (lword >> 16L);
	*lo = (int) (lword & 0xffffL);
}

/**
 * int2long
 *
 * Wandelt zwei unsigned ints in ein unsigned long.
 *
 * Eingabe:
 * hi: Obere 16 Bit fuer den unsigned long.
 * lo: Untere 16 Bit fuer den unsigned long.
 *
 * Rueckgabe:
 * lo + hi * 65536UL
 */
unsigned long int2long(unsigned int hi, unsigned int lo) {
	return ((unsigned long) lo + ((unsigned long) hi << 16UL));
}
#endif

/**
 * Rechnet Desktop-Koordinaten in ein relatives System (0-32767) um und
 umgekehrt.
 -------------------------------------------------------------------------*/
int abs2rel(int rel, int abs, int value) {
	double res;

	res = (double) rel * (double) value / (double) abs;
	return (int) (res + 0.5);
}
