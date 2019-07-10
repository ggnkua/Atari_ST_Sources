#include <stdio.h>
#include <osbind.h>


/*
 * The dumbest shell in the world.  It doent even look in the PATH
 * and will only run files ending in .prg.
 */
main()
{
	char line[80], args[80], *p;
	int err;

	for (;;) {
		fflush(stdout);
		Fwrite(1, 2L, "$ ");
		Fread(0, 512L, line);
		for (p = line; *p != 0; p++)
			if (*p == '\r' || *p == '\n')
				break;
		*p = 0;
		for (p = line; *p > ' '; p++)
			;
		if (*p) {
			*p++ = 0;
			strcpy(args+1, p);
			args[0] = strlen(args+1);
		}
		else
			args[0] = 0;
		if (strcmp(line, "exit") == 0)
			break;
		strcat(line, ".prg");
		err = Pexec(0, line, args, 0L);
		if (err)
			printf("status %d\n", err);
	}
}
	
