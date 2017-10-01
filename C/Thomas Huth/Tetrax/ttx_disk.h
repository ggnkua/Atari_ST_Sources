/* *** Prototypes for TTX_DISK.C *** */

#ifndef _TTX_DISK_H
#define _TTX_DISK_H

extern char pathname[];
extern char filename[];

void load_mod(void);
void accmfree(void *adr);
void dragdrop(short ddnum);
void getcommand(char *command);

#endif
