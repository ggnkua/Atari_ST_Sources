#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ(2.59)
AC_INIT(pmdoom, 0.44, pmandin@caramail.com)
AC_CONFIG_SRCDIR([src/i_main.c])
AC_CONFIG_HEADER([config.h])
AC_CONFIG_AUX_DIR([autotools])
AC_CANONICAL_SYSTEM
AM_INIT_AUTOMAKE($PACKAGE_NAME, $PACKAGE_VERSION)

# Checks for programs.
AC_PROG_CC

# Checks for header files.
AC_HEADER_STDC
AC_CHECK_HEADERS([arpa/inet.h fcntl.h netdb.h netinet/in.h stdlib.h string.h \
sys/ioctl.h sys/socket.h sys/time.h unistd.h values.h])

# Checks for typedefs, structures, and compiler characteristics.
AC_HEADER_STDBOOL
AC_C_CONST
AC_C_INLINE
AC_C_RESTRICT
AC_C_VOLATILE

# Checks for library functions.
AC_PROG_GCC_TRADITIONAL
#AC_FUNC_MALLOC
AC_FUNC_VPRINTF
AC_CHECK_FUNCS([atexit gethostbyname isascii gethostname memset mkdir pow \
socket strcasecmp strerror strncasecmp strupr])

# More library stuff

# Math
if test "x$ac_cv_func_pow" = "xno"; then
	LIBS="$LIBS -lm"
fi

# Socket
if test "x$ac_cv_func_socket" = "xno"; then
	LIBS="$LIBS -lsocket"
fi

# SDL
AM_PATH_SDL( 1.2.0 , :, AC_MSG_ERROR([*** SDL version $SDL_VERSION not found!]))

# SDL_mixer
AC_CHECK_LIB(SDL_mixer, Mix_OpenAudio,
	have_sdlmixer_lib=yes, have_sdlmixer_lib=no, $SDL_LIBS)
AC_CHECK_HEADER(SDL/SDL_mixer.h, have_sdlmixer_hdr=yes)
if test "x$have_sdlmixer_lib" = "xyes" -a "x$have_sdlmixer_hdr" = "xyes"; then
	AC_DEFINE(ENABLE_SDLMIXER, 1, [Define if you have SDL_mixer])
	LIBS="$LIBS -lSDL_mixer"
fi

# Output files.
CFLAGS="$CFLAGS \$(SDL_CFLAGS)"
LIBS="$LIBS \$(SDL_LIBS)"

AC_CONFIG_FILES([Makefile doc/Makefile src/Makefile src/sting/Makefile])
AC_OUTPUT
