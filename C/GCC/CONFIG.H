
/* we use an extra file, as we don't do links */

/* generic m68k config file */

#include "config-m.h"

/* exc that we don't want the funny alloca... */

#undef alloca

#include "stddef.h"

/* specs for start file and link specs */

#define STARTFILE_SPEC  \
  "%{pg:$GNULIB$\\gcrt0.o%s}%{!pg:%{p:$GNULIB$\\mcrt0.o%s}%{!p:$GNULIB$\\crt0.o%s}}"

#define LIB_SPEC \
  "%{!p:%{!pg:-lgnu.olb}}%{p:-lgnu-p.olb}%{pg:gnu-p.olb}"

