#include "fiomod.h"
int load_file(void);
int show_file_info(char *file, int match, char *desript);
int open_as_main(int fh, FILE_DSCR *fd, FIO_LIST *fl);
char *file_fit(char *src, char *dst, long len);
int import_file(char *path, char *file, LAYER *l, MASK *ms, int mode);
int get_graf_size(char *path, char *file, int *w, int *h);
