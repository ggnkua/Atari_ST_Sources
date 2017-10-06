#include <Screen.h>
#include <fnameext.h>
#include <stdio.h>
#include <string.h>

main(int argc, char* argv[])
{
	if (argc<2) {
		fprintf(stderr,"Usage:  %s file ...\n",argv[0]);
		fprintf(stderr,"   Convert each file between CrackArt and Degas formats\n");
	} else {
		Screen buffer;

		for (int arg=1; arg<argc; arg++) {
			char ext[16];
			char* curext=extension(ext,argv[arg]);

			if (buffer.Load(argv[arg])) {
				if (0==strncmp(ext,"pi",2) || 0==strncmp(ext,"PI",2)) {
					curext[0]='c';
					curext[1]='a';
					if (!buffer.Save(argv[arg])) perror(argv[arg]);
				} else if (0==strncmp(ext,"ca",2) || 0==strncmp(ext,"CA",2)) {
					curext[0]='p';
					curext[1]='i';
					if (!buffer.Save(argv[arg])) perror(argv[arg]);
				} else {
					fprintf(stderr,"Unrecognised format: %s\n",ext);
				}
			} else {
				perror(argv[arg]);
			}
		}
	}
}
