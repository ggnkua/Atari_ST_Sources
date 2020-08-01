/* tm.h file for a Convex C1.  */

#include "tm-convex.h"

#undef TARGET_DEFAULT
#define TARGET_DEFAULT 1

#define CC1_SPEC "%{mc2:-mnoc1}"
