/* This file changes the Linux defines to a form useable by ST */

#include <string.h>
#include "hdio.h"

int bit(void *map,long num);
void setbit(void *map,long num);
void clrbit(void *map,long num);
long set_size(long);

#define open new_open
#define close new_close 
#define read new_read
#define write new_write
#define lseek new_lseek
#define sync new_sync

#ifdef PORTST
int new_open(char *,int,unsigned);
#else
int new_open(char *,int,...);
#endif
int new_close(int);
long new_read(int,void *,long);
long new_write(int,void *,long);
long new_lseek(int,long,int);
void new_sync(void);

