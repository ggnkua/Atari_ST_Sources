/*
 * Read and Write routines for files that are basically Character type.
 */

# include       "../include/file.h"
# include       "../include/dev.h"

# define	VOID		char

c_read(file, buffer, nbytes)
struct file *file;
char *buffer;
{
	int (*fnc)();

	if (fnc = file->f_handler->rd_fnc)
		return (*fnc)(file->f_dev, buffer, nbytes);

	return -1;
}

c_write(file, buffer, nbytes)
struct file *file;
char *buffer;
{
	int (*fnc)();

	if (fnc = file->f_handler->wr_fnc)
		return (*fnc)(file->f_dev, buffer, nbytes);

	return -1;
}

c_ioctl(file, request, argp)
struct file *file;
VOID *argp;
{
	int (*fnc)();

	if (fnc = file->f_handler->ioctlfnc)
		return (*fnc)(file->f_dev, request, argp);

	/* ioctl inapplicable */
	return -1;
}
