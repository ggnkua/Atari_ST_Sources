
#ifndef __PROTECT_H
#define __PROTECT_H

#ifdef __cplusplus
extern "C" {
#endif

/* protect.c */

void pwrite( int reg, int data );
int pread( int reg );

#ifdef __cplusplus
}
#endif

#endif

