#ifndef DB_H
#define DB_H

#ifdef BERKELEY_DB
#include <db.h>
#endif

#include "pager.h"

#define GLOBAL_FUNCTION 'f'
#define STATIC_FUNCTION 's'
#define FUNCTION_CALL   'c'
#define IDENTIFIER      'i'
#define LITERAL         'l'
#define INCLUDE_HEADER  'n'

int writerec(
#if defined(BINARY_DB) || defined(ASCII_DB)
FILE *fp,
#endif
#ifdef BERKELEY_DB
const DB *db,
#endif
char tag, dev_t dev, ino_t inode, unsigned int line, const char *function, const char *str);
void findid(struct Lines *l, const char *id, const char *indexfile);
void findcallee(struct Lines *l, const char *id, const char *indexfile);
void findcaller(struct Lines *l, const char *id, const char *indexfile);
void findlit(struct Lines *l, const char *literal, const char *indexfile);
void findinclude(struct Lines *l, const char *file, const char *indexfile);
void findfile(struct Lines *l, const char *literal);
void findposix(struct Lines *l, const char *indexfile);
void update(const char *indexfile, const char * const *file, int files, int force);

#endif
