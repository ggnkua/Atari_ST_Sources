#include <stdio.h>
#include <fcntl.h>
#include "bm.h"
#include "Extern.h"

int _mneed = 30000;

main(argc,argv)
int argc;
char *argv[];
{
	/* grep based on Boyer-Moore algorithm */
	char BigBuff[MAXBUFF+2];
	/*
	* We leave one extra character at the beginning and end of the buffer,
	* but don't tell Execute about it. This is so when someone is
	* scanning the buffer and scans past the end (or beginning)
	* we are still technically in the buffer (picky, but there ARE
	* machines which would complain)
	*/
	int ret = 1, /* return code from Execute */
		NotFound = 0,		/* non-zero if file not readable */
		NFiles,
		NPats; /* number of patterns to search for */
	char *FlagPtr,
		**OptPtr; /* used to scan command line */
	int TextFile /* file to search */;
	struct PattDesc *DescVec[MAXPATS];

	--argc;
	OptPtr = argv + 1;
	while ( argc && **OptPtr == '-') {
		FlagPtr = *OptPtr + 1;
		do { 
			switch (*FlagPtr) {
				case 'c': cFlag = 1; break;
				case 'e': eFlag = 1;
					/* get the patterns from next arg */
					NPats = MkDescVec(DescVec,*++OptPtr);
					--argc;
					break;
				case 'f': fFlag = 1; 
					/* read the patterns from a file */
					NPats = GetPatFile(*++OptPtr,DescVec);
					--argc;
					break;
				case 'l': lFlag = 1; break;
				case 'n': nFlag = 1; break;
				case 's': sFlag = 1; break;
				case 'x': xFlag = 1; break;
				case 'h': hFlag = 1; break;
				default:
					fprintf(stderr,
					"bm: invalid option: -%c \n",
					*FlagPtr);
					PutUsage();
					exit(2);
			} /* switch */
			++FlagPtr;
		} while (*FlagPtr);
		++OptPtr; --argc;
	} /* while */
	/* OptPtr now points to patterns */
	if (!fFlag && !eFlag) {
		if (!argc) {
			fprintf(stderr,"bm: no pattern specified\n");
			PutUsage();
			exit(2);
		} else
			NPats = MkDescVec(DescVec,*OptPtr);
		++OptPtr; --argc;
	}
	/* OptPtr now points to first file */
	NFiles = argc;
	if (!NFiles)
		ret &= Execute(DescVec,NPats,0,BigBuff+1);
	else while (argc--) {
		if ((NFiles > 1) || lFlag) FileName = *OptPtr;
		if ((TextFile = open(*OptPtr,O_RDONLY|O_RAW)) < 0) {
			fprintf(stderr,"bm: can't open %s\n",*OptPtr);
			NotFound++;
		}
		else {
			ret &= Execute(DescVec,NPats,TextFile,BigBuff+1);
			if (sFlag && !ret)
				exit(0);
			close(TextFile);
		} /* if */
		++OptPtr;
	} /* while */
	if (cFlag) printf("%d\n",MatchCount);
	exit(NotFound ? 2 : ret);
} /* main */
