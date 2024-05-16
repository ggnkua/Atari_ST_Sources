#include <stdio.h>
#include <string.h>

int main(void) {
	FILE *fin, *fout;
	char line[42+1];

	fin=fopen("invit.txt", "r");
	fout=fopen("invit.40", "w");
	while(!feof(fin)) {
		char *pos, *lptr;

		fgets(line, 42, fin);
		pos=strchr(line,10);
		if (!pos)
			break;
		/* conversion to lowercase */
		for (lptr=line; lptr<pos; lptr++)
			if ((*lptr>='A') && (*lptr<'Z'))
				*lptr|=0x20;
		/* padding to 40 chars per line */
		for (lptr=pos; lptr<line+40; )
			*lptr++=' ';
		*lptr=0;
		/*printf("%s\n", line);*/
		fprintf(fout, "%s", line);
	}

	return 0;
}
