/*
 * Teradesk. Copyright (c) 1993, 1994, 2002 W. Klaren.
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

/* Slider type: 0 - elementen in window kunnen niet geselekteerd
                    worden.
                1 - elementen in window kunnen wel geselekteerd
                    worden.
*/

typedef struct sliderinfo
{
	int type;

	int up_arrow;				/* object nummers van pijltjes en sliders */
	int down_arrow;
	int slider;
	int sparent;

	int lines;					/* aantal regels in window */
	int n;						/* totaal aantal regels */
	int line;					/* nummer van de eerste regel in het window (0 - n-lines) */

	void (*set_selector) (struct sliderinfo *slider, boolean draw, XDINFO *info);

	int first;					/* index van eerste regel in objectboom */
	int (*findsel) (void);		/* funktie voor het vinden van het geselekteerde object */
} SLIDER;

void sl_init(OBJECT *tree, SLIDER *slider);
void sl_set_slider(OBJECT *tree, SLIDER *slider, XDINFO *info);
int sl_handle_button(int button, OBJECT *tree, SLIDER *sl, XDINFO *dialog);
int sl_form_do(OBJECT *tree, int start, SLIDER *slider, XDINFO *info);
int sl_dialog(OBJECT *tree, int start, SLIDER *slider);
