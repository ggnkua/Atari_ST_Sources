
#ifndef __PROTECT1_H
#define __PROTECT1_H

/* protect1.c */

#ifdef __cplusplus
extern "C" {
#endif

void pwrite1( int reg, int data );
int pread1( int reg );

#ifdef __cplusplus
}
#endif

#endif

