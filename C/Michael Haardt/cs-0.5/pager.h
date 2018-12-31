#ifndef PAGER_H
#define PAGER_H

#include <curses.h>

#define PROMPTS       8

struct Lines
{
  int lines;
  int linesz;
  struct
  {
    char *filename;
    int line;
    char *function;
    char *source;
  } *s;
};

extern int linemode;

void freelines(struct Lines *l);
void printline(struct Lines *l, const char *file, int line, const char *function, char *s);
chtype pagelines(struct Lines *lines);

#endif
