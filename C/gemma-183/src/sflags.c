/* Configuration flags
 */

/*  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

# include "gemma.h"

extern const unsigned long ctrl_list[];

struct gemma_flags sflags =
{
	14,		/* number of fields below */
	MAX_PID,	/* self explaining */
	DEF_PAGE_SIZE,	/* default size of MMU pages */
	MIN_PAGE_SIZE,	/* minimum size of memory pages */
	1,		/* verify addresses before passing away to AES */
	0,		/* reserved */
	50,		/* button release delay in ms */
	200,		/* AV protocol buffer release delay in ms */
	MAX_AES_OP,	/* maximum AES function code */
	ctrl_list,	/* pointer to AES control list */
	1,		/* draw classic zoomboxes */
	0,		/* draw moveboxes for WM_MOVED */
	0,		/* enable desktop size compensation */
	1,		/* use form_alert() for displaying alerts */
	0 		/* alert handles redraws in windows below */
};

/* EOF */
