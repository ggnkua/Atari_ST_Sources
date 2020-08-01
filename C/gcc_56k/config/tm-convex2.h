/* tm.h file for a Convex C2.  */

#include "tm-convex.h"

#undef TARGET_DEFAULT
#define TARGET_DEFAULT 2

#define CC1_SPEC "%{mc1:-mnoc2}"
