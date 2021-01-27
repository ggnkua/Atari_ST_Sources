/* This file is part of the AHCC C Library.

   The AHCC C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public License as
   published by the Free Software Foundation; either version 2 of the
   License, or (at your option) any later version.

   The AHCC C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with the GNU C Library; see the file COPYING.LIB.  If not,
   write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
   Boston, MA 02111-1307, USA.
*/

/* from dLibs, by Dale Schumacher */

/* Modified by Guido Flohr <guido@freemint.de>:
 * - Characters > 128 are control characters.
 * - iscntrl(EOF) should return false, argh, stupid but that's the
 *   the opinion of the majority.
 */

/* Modified for AHCC by Henk Robbers <h.robbers@chello.nl> */

#include <ctype.h>
#include <limits.h>

static int _ctype[UCHAR_MAX + 1] =
{
	0,						/* EOF */
	_CTc, _CTc, _CTc, _CTc,				/* 0x00..0x03 */
	_CTc, _CTc, _CTc, _CTc,				/* 0x04..0x07 */
	_CTc, _CTc|_CTs|_CTb, _CTc|_CTs, _CTc|_CTs,	/* 0x08..0x0B */
	_CTc|_CTs, _CTc|_CTs, _CTc, _CTc,		/* 0x0C..0x0F */

	_CTc, _CTc, _CTc, _CTc,				/* 0x10..0x13 */
	_CTc, _CTc, _CTc, _CTc,				/* 0x14..0x17 */
	_CTc, _CTc, _CTc, _CTc,				/* 0x18..0x1B */
	_CTc, _CTc, _CTc, _CTc,				/* 0x1C..0x1F */

	_CTs|_CTb|_CTP, _CTp|_CTg|_CTP, _CTp|_CTg|_CTP, _CTp|_CTg|_CTP,			/* 0x20..0x23 */
	_CTp|_CTg|_CTP, _CTp|_CTg|_CTP, _CTp|_CTg|_CTP, _CTp|_CTg|_CTP,				/* 0x24..0x27 */
	_CTp|_CTg|_CTP, _CTp|_CTg|_CTP, _CTp|_CTg|_CTP, _CTp|_CTg|_CTP,				/* 0x28..0x2B */
	_CTp|_CTg|_CTP, _CTp|_CTg|_CTP, _CTp|_CTg|_CTP, _CTp|_CTg|_CTP,				/* 0x2C..0x2F */

	_CTd|_CTx|_CTg|_CTP, _CTd|_CTx|_CTg|_CTP,
	_CTd|_CTx|_CTg|_CTP, _CTd|_CTx|_CTg|_CTP,	/* 0x30..0x33 */
	_CTd|_CTx|_CTg|_CTP, _CTd|_CTx|_CTg|_CTP,
	_CTd|_CTx|_CTg|_CTP, _CTd|_CTx|_CTg|_CTP,	/* 0x34..0x37 */
	_CTd|_CTx|_CTg|_CTP, _CTd|_CTx|_CTg|_CTP,
	_CTp|_CTg|_CTP, _CTp|_CTg|_CTP,			/* 0x38..0x3B */
	_CTp|_CTg|_CTP, _CTp|_CTg|_CTP,
	_CTp|_CTg|_CTP, _CTp|_CTg|_CTP,			/* 0x3C..0x3F */

	_CTp|_CTg|_CTP, _CTu|_CTx|_CTg|_CTP,
	_CTu|_CTx|_CTg|_CTP, _CTu|_CTx|_CTg|_CTP,	/* 0x40..0x43 */
	_CTu|_CTx|_CTg|_CTP, _CTu|_CTx|_CTg|_CTP,
	_CTu|_CTx|_CTg|_CTP, _CTu|_CTg|_CTP,		/* 0x44..0x47 */
	_CTu|_CTg|_CTP, _CTu|_CTg|_CTP,
	_CTu|_CTg|_CTP, _CTu|_CTg|_CTP,			/* 0x48..0x4B */
	_CTu|_CTg|_CTP, _CTu|_CTg|_CTP,
	_CTu|_CTg|_CTP, _CTu|_CTg|_CTP,			/* 0x4C..0x4F */

	_CTu|_CTg|_CTP, _CTu|_CTg|_CTP,
	_CTu|_CTg|_CTP, _CTu|_CTg|_CTP,			/* 0x50..0x53 */
	_CTu|_CTg|_CTP, _CTu|_CTg|_CTP,
	_CTu|_CTg|_CTP, _CTu|_CTg|_CTP,			/* 0x54..0x57 */
	_CTu|_CTg|_CTP, _CTu|_CTg|_CTP,
	_CTu|_CTg|_CTP, _CTp|_CTg|_CTP,			/* 0x58..0x5B */
	_CTp|_CTg|_CTP, _CTp|_CTg|_CTP,
	_CTp|_CTg|_CTP, _CTp|_CTg|_CTP,			/* 0x5C..0x5F */

	_CTp|_CTg|_CTP, _CTl|_CTx|_CTg|_CTP,
	_CTl|_CTx|_CTg|_CTP, _CTl|_CTx|_CTg|_CTP,	/* 0x60..0x63 */
	_CTl|_CTx|_CTg|_CTP, _CTl|_CTx|_CTg|_CTP,
	_CTl|_CTx|_CTg|_CTP, _CTl|_CTg|_CTP,		/* 0x64..0x67 */
	_CTl|_CTg|_CTP, _CTl|_CTg|_CTP,
	_CTl|_CTg|_CTP, _CTl|_CTg|_CTP,			/* 0x68..0x6B */
	_CTl|_CTg|_CTP, _CTl|_CTg|_CTP,
	_CTl|_CTg|_CTP, _CTl|_CTg|_CTP,			/* 0x6C..0x6F */

	_CTl|_CTg|_CTP, _CTl|_CTg|_CTP,
	_CTl|_CTg|_CTP, _CTl|_CTg|_CTP,			/* 0x70..0x73 */
	_CTl|_CTg|_CTP, _CTl|_CTg|_CTP,
	_CTl|_CTg|_CTP, _CTl|_CTg|_CTP,			/* 0x74..0x77 */
	_CTl|_CTg|_CTP, _CTl|_CTg|_CTP,
	_CTl|_CTg|_CTP, _CTp|_CTg|_CTP,			/* 0x78..0x7B */
	_CTp|_CTg|_CTP, _CTp|_CTg|_CTP,
	_CTp|_CTg|_CTP, _CTc,				/* 0x7C..0x7F */

	_CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, /* 0x80..0x87 */
	_CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, /* 0x80..0x8F */
	_CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, /* 0x80..0x97 */
	_CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, /* 0x80..0x9F */
	_CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, /* 0x80..0xA7 */
	_CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, /* 0x80..0xAF */
	_CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, /* 0x80..0xB7 */
	_CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, /* 0x80..0xBF */
	_CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, /* 0x80..0xC7 */
	_CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, /* 0x80..0xCF */
	_CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, /* 0x80..0xD7 */
	_CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, /* 0x80..0xDF */
	_CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, /* 0x80..0xE7 */
	_CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, /* 0x80..0xEF */
	_CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, /* 0x80..0xF7 */
	_CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, /* _CTc, */ /* 0x80..0xFF */
};

int isalnum(int c)
{
 return (int) (_ctype[(unsigned char) (c + 1)] & (_CTu|_CTl|_CTd));
}

int isalpha (int c)
{
  return (int) (_ctype[(unsigned char) (c + 1)] & (_CTu|_CTl));
}

int isascii(int c)
{
  return (int) !((c) & ~0x7F);
}

int toascii(int c)
{
  return (int) ((c) & 0x7F);
}

int iscntrl(int c)	#warn foute preprocessor
{
  return    c == -1
          ? 0
          : (unsigned char) (c) == 255
            ? 1
            : (int) (_ctype[(unsigned char) (c + 1)] & _CTc);
}

int isdigit(int c)
{
  return (int) (_ctype[(unsigned char) (c + 1)] & _CTd);
}

int isgraph(int c)
{
  return (int) (_ctype[(unsigned char) (c + 1)] & _CTg);
}

int islower(int c)
{
  return (int) (_ctype[(unsigned char) (c + 1)] & _CTg);
}

int isprint(int c)
{
  return (int) (_ctype[(unsigned char) (c + 1)] & _CTP);
}

int ispunct(int c)
{
  return (int) (_ctype[(unsigned char) (c + 1)] & _CTp);
}

int isspace(int c)
{
  return (int) (_ctype[(unsigned char) (c + 1)] & _CTs);
}

int isupper(int c)
{
  return (int) (_ctype[(unsigned char) (c + 1)] & _CTu);
}

int isxdigit(int c)
{
  return (int) (_ctype[(unsigned char) (c + 1)] & _CTx);
}

int __isblank(int c)
{
  return (int) (_ctype[(unsigned char) (c + 1)] & _CTb);
}

int tolower(int c)
{
	unsigned char x = c;
	if (x >= 'A' && x <= 'Z') c &= ~0x20;
	return c;
}

int toupper(int c)
{
	unsigned char x = c;
	if (x >= 'a' && x <= 'z') c |= 0x20;
	return c;
}
