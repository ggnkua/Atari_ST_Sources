#include <osbind.h>
#include <rtxbind.h>

#ifndef SHELL
#define SHELL "\\bin\\csh.prg"
#endif

main(argc, argv)
int argc;
char *argv[];
{
	int fd, flags;

	if (argc < 2)
		exit(1);
	fd = Fopen(argv[1], 2);
	/* set terminal to ECHO and COOKED mode */
	flags = Fcntrl(fd, 0);
	/* check to make sure it was a TTY */
	if (flags < 0 || (flags & 1) == 0) {
		printf("%s is not a tty\n", argv[1]);
		exit(1);
	}
	/* redirect I/O */
	Fforce(0, fd);
	Fforce(1, fd);
	Fforce(2, fd);
	Fclose(fd);
	/* Spawn your favorite shell */
	Pexec(0, SHELL, "", "\0\0");

	exit(0);
}
