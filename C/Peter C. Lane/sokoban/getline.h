#if !defined(GETLINE_H)
#define GETLINE_H

#include <stdbool.h>
#include <stdio.h>

#define MAXLINE 1000 /* maximum permitted line length */

int getline (FILE * fp, char s[], int lim, bool keep_newline);

#endif