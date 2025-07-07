#include <stdio.h>
#include <math.h>
#include <signal.h>
#ifndef LATTICE
#include <pwd.h>
#endif
#include <errno.h>
#include <sys/types.h>
#include <sys/time.h>
#include <sys/file.h>
#ifndef LATTICE
#include <sys/wait.h>
#endif
#ifndef ATARI
/* No X - so don't need these RMG 11/08/93 */
#include <X11/Xlib.h>
#include <X11/Xutil.h> 
#include <X11/Intrinsic.h>
#include <X11/StringDefs.h>
#include <X11/Shell.h>
#endif
#ifdef ATARI
#include "gem.h"
#endif
#include "c_config.h"
#include "c_colors.h"
#include "c_defs.h"
#include "c_structs.h"
#include "c_externs.h"
