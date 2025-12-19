/*
 * cmp.h
 *
 * prototypes for cmp.c, file comparison and auxiliary memory allocation
 * functions.
 *
 * Roy Bixler
 * March 16, 1991
 */



/* cmp.c */
unsigned int alloc_file_buffers(char **buf1, char **buf2, long file_size);
int do_compare_files(int file1, int file2);
int compare_files(char *file1, char *file2);
