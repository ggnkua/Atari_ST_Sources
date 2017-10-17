/* CT60 / Coldfire board(s) Flash commands
*
*  This program is free software; you can redistribute it and/or modify
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
*  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#ifndef	_COMMAND_H
#define	_COMMAND_H

#ifdef COLDFIRE

#ifdef MCF547X /* FIREBEE */

/* amd - mx devices */
#define CMD_UNLOCK1	0xAA
#define CMD_UNLOCK2	0x55
#define CMD_SECTOR_ERASE1	0x80
#define CMD_SECTOR_ERASE2	0x30
#define CMD_SECTOR_ERASE_SUSPEND 0xB0
#define CMD_SECTOR_ERASE_RESUME 0x30
#define CMD_PROGRAM	0xA0
#define CMD_AUTOSELECT 0x90
#define CMD_READ 0xF0

#else /* MCF548X - MCF5445X */

/* intel devices */
#define CMD_UNLOCK1	0x60
#define CMD_UNLOCK2	0xD0
#define CMD_LOCK1	0x60
#define CMD_LOCK2	0x01
#define CMD_SECTOR_ERASE1	0x20
#define CMD_SECTOR_ERASE2	0xD0
#define CMD_PROGRAM	0x40
#define CMD_STATUS 0x70
#define CMD_READ 0xFF

#endif /* MCF547X */

#else /* ATARI - CT60 */

/* fujitsu - amd - st devices */
#define CMD_UNLOCK1	0xAA
#define CMD_UNLOCK2	0x55
#define CMD_SECTOR_ERASE1	0x80
#define CMD_SECTOR_ERASE2	0x30
#define CMD_SECTOR_ERASE_SUSPEND 0xB0
#define CMD_SECTOR_ERASE_RESUME 0x30
#define CMD_PROGRAM	0xA0
#define CMD_AUTOSELECT 0x90
#define CMD_READ 0xF0

#endif /* COLDFIRE */

#endif /* _COMMAND_H */
