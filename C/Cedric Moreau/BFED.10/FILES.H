#ifndef FILES_H
#define FILES_H

#include "wind.h"	/* defs for windowptr */

	/* globals vars */
/*extern 	char 	lastpath[PATH_MAX];
extern	char	fs_insel[PATH_MAX];
extern	char	fs_inpath[PATH_MAX];
*/
extern	char	app_path[PATH_MAX];

	/* Functions */
extern int read_file(windowptr	thewin);
extern void write_file( windowptr thewin);
extern void save_file(windowptr	thewin);
extern int getfile(windowptr thewin, char *string);
extern int delfile(void);
extern void init_files(void);

#endif