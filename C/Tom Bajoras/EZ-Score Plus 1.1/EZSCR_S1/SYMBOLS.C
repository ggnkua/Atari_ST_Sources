/* SYMBOLS.C - crd 870928, 880110 */

overlay "ezpdat"

#include "structs.h"

PSYM  staff,
      brackt, brackm, brackb;

extern   staffi(),
         brackit(), brackim(), brackib();

asm {
staffi:  dc.w  0xFFFF
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0xFFFF
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0xFFFF
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0xFFFF
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0x0000
         dc.w  0xFFFF

brackit: dc.w  0x0040
         dc.w  0x00C0
         dc.w  0x0180
         dc.w  0x0380
         dc.w  0x0700
         dc.w  0x0E00
         dc.w  0x1C00
         dc.w  0x3C00
         dc.w  0x7800
brackim: dc.w  0x7000
brackib: dc.w  0x7800
         dc.w  0x3C00
         dc.w  0x1C00
         dc.w  0x0E00
         dc.w  0x0700
         dc.w  0x0380
         dc.w  0x0180
         dc.w  0x00C0
         dc.w  0x0040
}

/* EOF */
