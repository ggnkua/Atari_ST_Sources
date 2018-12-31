#ifndef EDIT_H
#define EDIT_H

#include "wind.h"	/* defs for windowptr */

	/* globals variables */
extern int	ins;
extern int	inhex;

	/* Functions */
extern void delete_one(windowptr thewin, long pos, int flag);
extern void cutit(windowptr thewin);
extern void copy(windowptr thewin);
extern void paste(windowptr thewin);
extern void insert_it(windowptr thewin, long incopy, char *addr2);

extern void start_mark(windowptr	thewin);
extern void end_mark(windowptr	thewin);
extern void clear_marks(windowptr	thewin);

#endif