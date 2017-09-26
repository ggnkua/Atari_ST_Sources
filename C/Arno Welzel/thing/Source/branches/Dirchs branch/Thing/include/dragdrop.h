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

/*=========================================================================
  DRAGDROP.H
  
  Prototypen zu DRAGDROP.C
========================================================================*/

#define DD_OK         0    /* Ok, - weitermachen                */
#define DD_NAK        1    /* Drag&Drop abbrechen               */
#define DD_EXT        2    /* Datenformat wird nicht akzeptiert */
#define DD_LEN        3    /* Wunsch nach weniger Daten         */
#define DD_TRASH      4    /* Ziel ist ein Papierkorb-Icon      */
#define DD_PRINTER    5    /* Ziel ist ein Drucker-Icon         */
#define DD_CLIPBOARD  6    /* Ziel ist ein Klemmbrett-Icon      */

int ddcreate(int myid, int apid, int winid, int msx, int msy, int kstate, void *ext, void **oldpipesig);
int ddstry(int handle, unsigned long ext, char *name, long size);
void ddclose(int handle, void *oldpipesig);
