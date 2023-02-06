#ifndef TYPES_H
#define TYPES_H

#ifdef uint8_t
#undef uint8_t
#endif
#ifdef uint16_t
#undef uint16_t
#endif
#ifdef uint32_t
#undef uint32_t
#endif

typedef unsigned char uint8_t;
typedef unsigned int uint16_t;
typedef unsigned long uint32_t;

#endif /* TYPES_H */
