#include <stdio.h>

#define MAX_ROWS 2
#define DAT_SIZE MAX_ROWS*40*8

char pi1[32066], *pi1_ptr, dst[40*8*2];

int main(void) {
	FILE *fin, *fout;
	char bla[10];
	int r;

	/* i */
	fin=fopen("font882c.pi1", "r");
	fout=fopen("fnt882c.dat", "w");
	fread(pi1, 1, 32066, fin);

	/* p */
	pi1_ptr=pi1+34+2;	/* plane 1, not 0 */
	for (r=0; r<MAX_ROWS; r++) {
		int c;

		for (c=0; c<20; c++) {
			int i;

			/* left byte */
			for (i=0; i<8; i++)
				dst[r*320+c*16+8+i]=pi1_ptr[r*1280+c*8+i*160];
			/* right byte */
			for (i=0; i<8; i++)
				dst[r*320+c*16+i]=pi1_ptr[r*1280+c*8+1+i*160];
		}
	}

	/* o */
	fwrite(dst, 1, DAT_SIZE, fout);

	printf("output size=%d\n", DAT_SIZE);
	gets(bla);
	return 0;
}
