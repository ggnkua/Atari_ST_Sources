/*
 * Modified for the FreeMiNT USB subsystem by David Galvez. 2010 - 2011
 *
 * XaAES - XaAES Ain't the AES (c) 1992 - 1998 C.Graham
 *                                 1999 - 2003 H.Robbers
 *                                        2004 F.Naumann & O.Skancke
 *
 * This file is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with XaAES; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#ifndef _usb_version_h
#define _usb_version_h

#define DSMASM 0x00ff

/* Version numbers */
#define VER_MAJOR	0
#define VER_MINOR	999
#define ARCH_TARGET	USB_ARCH_M68K
/*#define DEV_STATUS	(USB_DEVSTATUS_ALPHA|USB_FDEVSTATUS_STABLE)*/
#define DEV_STATUS	USB_DEVSTATUS_BETA
//#define DEV_STATUS	USB_DEVSTATUS_RELEASE

#define SHORT_NAME		"usb"
#define USB_ID		"   " SHORT_NAME

#define LONG_NAME	"usb, a free usb stack for FreeMiNT"

#if ((DEV_STATUS & 0x000f) == USB_DEVSTATUS_ALPHA)
# define ASCII_DEV_STATUS	"Alpha"
#endif

#if ((DEV_STATUS & 0x000f) == USB_DEVSTATUS_BETA)
# ifdef USB_RELEASE
# undef USB_RELEASE
# endif
# define USB_RELEASE		0
# define ASCII_DEV_STATUS	"Beta"
#endif

#if ((DEV_STATUS & 0x000f) == USB_DEVSTATUS_RELEASE)
# ifdef USB_RELEASE
# undef USB_RELEASE
#endif
# define USB_RELEASE 		1
# define ASCII_DEV_STATUS	"Release"
#endif

#ifndef ASCII_DEV_STATUS
# define ASCII_DEV_STATUS	"Undefined"
#endif

#if (ARCH_TARGET == USB_ARCH_M68K)
# define ASCII_ARCH_TARGET	"m68k"
#endif
#ifndef ASCII_ARCH_TARGET
# define ASCII_ARCH_TARGET	"Undefined"
#endif


#define BDATE		__DATE__
#define BTIME		__TIME__
#define BC_MAJ		str (__GNUC__)
#define BC_MIN 		str (__GNUC_MINOR__)
#define BCOMPILER	str (__GNUC__) "." str (__GNUC_MINOR__)
//"gcc 2.95.3"

// const char BCOMPILER [] = str (__GNUC__) "." str (__GNUC_MINOR__);

#endif /* _usb_version_h */
