/* CT60 / Coldfire board(s) Flash size
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

#ifndef	_MAIN_H
#define	_MAIN_H	1

#ifdef COLDFIRE

#ifdef MCF5445X /* M54455EVB */

#define PARAM_SIZE  (128*1024)
#define FLASH_SIZE  0x00120000

#else

#ifdef MCF5474X /* FIREBEE */

#define PARAM_SIZE  (64*1024)
#define FLASH_SIZE  0x00100000

#else /* MCF548X - M5484LITE */

#define PARAM_SIZE  (64*1024)
#define FLASH_SIZE  0x00100000

#endif /* MCF547X */

#endif /* M5445X */

#else /* ATARI -CT60 */

#define PARAM_SIZE  (64*1024)
#define FLASH_SIZE  0x00100000

#endif /* COLDFIRE */

#define FLASH_ADR   0x00E00000
#define TESTS_SIZE  0x00020000
#define FLASH_ADR2  0x00FC0000
#define FLASH_SIZE2 0x00030000

#define	MAX_ERROR_LENGTH	256

#endif
