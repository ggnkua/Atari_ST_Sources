#define DECSTATION

#include "tm-mips.h"

#undef CPP_PREDEFINES
#define CPP_PREDEFINES "-Dultrix -Dbsd4_2 -DMIPSEL -Dhost_mips -Dmips -Dunix -DR3000 -DLANGUAGE_C -DSYSTYPE_BSD"
