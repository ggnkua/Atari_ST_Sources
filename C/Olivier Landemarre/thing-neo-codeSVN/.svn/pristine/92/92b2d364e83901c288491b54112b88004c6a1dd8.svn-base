/**
 * Thing
 * Copyright (C) 2023 Olivier Landemarre
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
 * @copyright  Olivier Landemarre 2023
 * @author     Olivier Landemarre
 * @license    LGPL
 */


/* Very basic routine remplacement for devlock, don't expect replace devlock, just minimal use for Thing */
/* use only gemdos Dlock*/


#include <tos.h>
#include <syserr.h>
#include <devlock.h>

void init_device_locking(void) {

}

int lock_device(int drive) {
	long answer;
	answer = Dlock(1,drive);
	if(answer == EACCDN) return 3;
	if(answer == EDRIVE) return 1;
	if(answer == ELOCKED) return 2;
	return 0;
}

void unlock_device(int drive) {
	(void) Dlock(0,drive);
}