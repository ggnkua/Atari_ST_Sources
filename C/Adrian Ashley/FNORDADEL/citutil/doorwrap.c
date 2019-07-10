/*
 * doorwrap.c -- wrapper for misbehaving door programs
 *
 * 91Sep01 AA	Hacked to stuff args in `tail' and pass to Pexec().
 * 90Oct23 AA	Created.
 */

#include <string.h>
#include <osbind.h>

main(int argc, char **argv)
{
	char tail[128], *p;
	int i = 0, r, rlen;

	if (argc < 2)
		return -1;

	/* Now parse args */
	p = &tail[1];
	rlen = 126;
	for (i = 2; i < argc; i++) {
		if ((r = strlen(argv[i])) > rlen)
			break;
		if (i != 2)
			strcat(p, " ");
		strcat(p, argv[i]);
		rlen -= r;
	}
	tail[0] = strlen(p);

	return (int)(Pexec(0, argv[1], tail, NULL));
}
