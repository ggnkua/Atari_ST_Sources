#include <stdio.h>
#include <osbind.h>
#include "Extern.h"
PrintLine(OffSet,LineStart,LineEnd)
int OffSet; /* offset of LineStart from beginning of file */
char *LineStart,
	*LineEnd;
{
	char OffStr[80];
        char save;

	if (lFlag) {
		if (strlen(FileName) > 76) {
			fprintf(stderr,"bm: filename too long\n");
			exit(2);
		} /* if */
		if (strlen(FileName)) {
			Cconws(FileName);
			Cconws("\r\n");
		} /* if */
		return 0; /* value ignored */
	} /* if */
	if (FileName && !hFlag) {
		if (strlen(FileName) > 76) {
			fprintf(stderr,"bm: filename too long\n");
			exit(2);
		} /* if */
		Cconws(FileName);
		Cconws(":");
	} /* if */
	if (nFlag) {
		sprintf(OffStr,"%d: ",OffSet);
		Cconws(OffStr);
	} /* if */
        save = LineEnd[1];
        LineEnd[1] = '\0';
	Cconws(LineStart);
        LineEnd[1] = save;
	if (*LineEnd != '\n') Cconws("\r\n");
 } /* PrintLine */
