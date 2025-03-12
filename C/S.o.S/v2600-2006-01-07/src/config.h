/* config.h.  Generated automatically by configure.  */
/* config.h.in.  Generated automatically from configure.in by autoheader.  */
/*****************************************************************************

   This file is part of x2600, the Atari 2600 Emulator
   ===================================================
   
   Copyright 1996 Alex Hornby. For contributions see the file CREDITS.

   This software is distributed under the terms of the GNU General Public
   License. This is free software with ABSOLUTELY NO WARRANTY.
   
   See the file COPYING for details.
   
   $Id: acconfig.h,v 1.1 1996/08/12 21:31:25 ahornby Exp $
******************************************************************************/

/* Define to empty if the keyword does not work.  */
/* #undef const */

/* Define as __inline if that's what the C compiler calls it.  */
/* #undef inline */

/* Define if you need to in order for stat and other things to work.  */
#define _POSIX_SOURCE

/* Define if you have the ANSI C header files.  */
#define STDC_HEADERS 1

/* Define if you can safely include both <sys/time.h> and <time.h>.  */
#define TIME_WITH_SYS_TIME 1

/* Define if your processor stores words with the most significant
   byte first (like Motorola and SPARC, unlike Intel and VAX).  */
#define WORDS_BIGENDIAN

/* Debugging Level */
#define Verbose 0

/* Xdebugger */
#undef XDEBUGGER 1

/* Define if you have the XShmAttach function.  */
//#define HAVE_XSHMATTACH 1

/* Define if you have the atexit function.  */
#define HAVE_ATEXIT 1

/* Define if you have the getopt_long function.  */
#define HAVE_GETOPT_LONG 1

/* Define if you have the gettimeofday function.  */
#define HAVE_GETTIMEOFDAY 1

/* Define if you have the on_exit function.  */
#define HAVE_ON_EXIT 0

/* Define if you have the usleep function.  */
#undef HAVE_USLEEP

/* Define if you have the <getopt.h> header file.  */
#define HAVE_GETOPT_H 1

/* Define if you have the <sys/time.h> header file.  */
#define HAVE_SYS_TIME_H 1

/* Define if you have the <unistd.h> header file.  */
#define HAVE_UNISTD_H 1

/* Define if you have the Dir library (-lDir).  */
#define HAVE_LIBDIR 1

/* Define if you have the X11 library (-lX11).  */
#undef HAVE_LIBX11 1

/* Define if you have the Xaw library (-lXaw).  */
#undef HAVE_LIBXAW 1

/* Define if you have the Xext library (-lXext).  */
#undef HAVE_LIBXEXT 1

/* Define if you have the Xmu library (-lXmu).  */
#undef HAVE_LIBXMU 1

/* Define if you have the Xt library (-lXt).  */
#undef HAVE_LIBXT 1

/* Define if you have the audio library (-laudio).  */
#undef HAVE_LIBAUDIO 1

/* Define if you have the fwf library (-lfwf).  */
#undef HAVE_LIBFWF

/* Define if you have the m library (-lm).  */
#define HAVE_LIBM 1

/* Define if you have the vga library (-lvga).  */
#undef HAVE_LIBVGA

/* Define if you have the Xm library (-lXm).  */
#undef HAVE_LIBXM 1

/* Define if you have the XFree86 vidmode library (-lXxf86vm).  */
#undef HAVE_LIBXXF86VM 1
