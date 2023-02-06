#ifndef UTIL_H
#define UTIL_H

#include <TYPES.H>

#define alignto(p, bits) (((p) >> (bits)) << (bits))
#define aligntonext(p, bits) alignto(((p) + (1 << (bits)) - 1), (bits))
#define addr_roundup(addr, padding) ((((uint32_t)(addr) + (1 << padding) - 1) >> padding) << padding)

int WrapInteger(int x, int min, int range);
void TrimLine(int *x, int min, int max);
unsigned MyRand(void);

#endif /* UTIL_H */
