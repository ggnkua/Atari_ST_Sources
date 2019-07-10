/*
 * crypte.c -- citadel encrypter/decrypter
 *
 * 90Aug27 AA	Renamed from libcryp.c.
 * 87Mar28 orc	hacked up to not use 2.15 portability typedefs.
 * 85Nov15 HAW	Created.
 */

#include "ctdl.h"
#include "config.h"
#include "citlib.h"

#define CRYPTADD 117

void
crypte(register char *buf,
       register unsigned short count,
       register unsigned short seed
      )
{
    seed = (seed + cfg.cryptSeed) & 0xFF;
    for (; count; count--) {
	*buf++ ^= seed;
	seed = (seed + CRYPTADD) & 0xFF;
    }
}
