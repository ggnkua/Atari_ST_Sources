| The header & some stuff

|  This program is free software; you can redistribute it and/or modify
|  it under the terms of the GNU General Public License as published by
|  the Free Software Foundation; either version 2 of the License, or
|  (at your option) any later version.
|
|  This program is distributed in the hope that it will be useful,
|  but WITHOUT ANY WARRANTY; without even the implied warranty of
|  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
|  GNU General Public License for more details.
|
|  You should have received a copy of the GNU General Public License
|  along with this program; if not, write to the Free Software
|  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

	.text

	.long	0x70004afc	| magic value (clr.l d0, illegal)
	.long	_slbname	| pointer to library's (file)name
	.long	0x00000100	| version number
	.long	0	| flags, currently 0L
	.long	nullret	| called when the library's been loaded
	.long	nullret	| called before the library is removed
	.long	nullret	| called when a process opens the library
	.long	nullret	| called when a process closes the library
	.long	0	| pointer to function names, optional
	.long	0,0,0,0,0,0,0,0	| unused, always 0L

	.long	1	| number of functions

	.long	__serror	| function table

_slbname:	.asciz	"error.slb"

nullret:	clr.l	d0
	rts

| EOF
