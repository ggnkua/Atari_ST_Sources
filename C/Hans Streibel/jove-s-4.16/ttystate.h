/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

#ifdef UNIX

/* Various tty state structures.
 * Each is an array, subscripted by one of "NO" or "YES".
 * YES is set suitably for JOVE.
 * NO is reset back to initial state.
 */

# ifdef SGTTY
#  include <sgtty.h>
extern struct sgttyb	sg[2];
#  ifdef TIOCSLTC
#   define USE_TIOCSLTC	1
#  endif
# endif

# ifdef TERMIO
#  include <termio.h>
extern struct termio	sg[2];
# endif

# ifdef TERMIOS
#  include <termios.h>
extern struct termios	sg[2];
# endif

# if defined(TERMIO) || defined(TERMIOS)
  /* JOVE needs to know about tab expansion to infer whether it should
   * use tabs to optimize output (jove.c).
   * It also must be able to turn tab expansion off for a pty (iproc.c).
   * The "normal" way of signifying tab expansion in a termio or termios
   * struct is to set the bits in c_oflag masked by TABDLY to TAB3.
   * Instead, some systems (eg. 386BSD) have a single bit named OXTABS,
   * from which we synthesize fake definitions of TABDLY and TAB3.
   * Some other systems have no bit, so we must presume that tabs don't
   * work and that we needn't change the setting.
   */
#  ifndef TABDLY
#   ifdef OXTABS
#    define TABDLY	OXTABS
#    define TAB3	TABDLY
#   else
#    define TABDLY	0	/* tab expansion is unknown and uncontrollable */
#   endif
#  endif
# endif

# ifdef USE_BSDTTYINCLUDE
#  include <bsdtty.h>
#  ifdef TIOCSLTC
#   define USE_TIOCSLTC	1
#  endif
# endif

# ifdef USE_TIOCSLTC
extern struct ltchars	ls[2];
# endif /* USE_TIOCSLTC */

# ifdef SGTTY

#  ifdef TIOCGETC
extern struct tchars	tc[2];
#  endif

#  ifdef LPASS8	/* use 4.3BSD's LPASS8 instead of raw for meta-key */
extern int	lmword[2];		/* local mode word */
#  endif

# endif /* SGTTY */

#  if !defined(TIOCGWINSZ) || defined(BSDPOSIX)
   /* In an attempt to get a definition for TIOCGWINSZ,
    * we include <sys/ioctl.h>.  In a perfect world, we could always
    * or never include it, but (1) at least SunOS 4.[01] <sys/ioctl.h>
    * conflicts seriously with <termios.h>, and yet (2) at least BSDI
    * requires <sys/ioctl.h> to define TIOCGWINSZ.  We hope that this
    * compromise will work on all systems.
    *
    * Another reason to include this file is to get a definition for
    * TIOCSCTTY under OSF and perhaps BSDPOSIX.
    */
#   include <sys/ioctl.h>
#  endif

#  ifdef BTL_BLIT
#   include <sys/jioctl.h>	/* get BTL window resizing definitions */
#  endif

#  ifdef SCO
#   undef TIOCGWINSZ	/* SCO ODT defines this but does not implement it!!! */
#  endif

/* Variables: */

extern bool	OKXonXoff;		/* VAR: XON/XOFF can be used as ordinary chars */
extern ZXchar	IntChar;		/* VAR: ttysetattr sets this to generate QUIT */

#endif /* UNIX */

#ifdef BIFF
extern bool	DisBiff;		/* VAR: turn off/on biff with entering/exiting jove */
#endif
