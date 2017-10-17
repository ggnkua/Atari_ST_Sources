/* CT60 / Coldfire board(s) binary genarator
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

#ifndef	_GENTOS_H
#define	_GENTOS_H

#define TOS4_SIZE	(512*1024)

extern int srec_read(const char *path);
extern unsigned long start_addr,end_addr;
void gentos_error(char*, char*);
unsigned long load_file(char*, unsigned char*, unsigned long);
void load_tos(char*, unsigned char*, unsigned long);
void save_tos(char*, unsigned char*, unsigned long);
int main(int, char**);

#endif
