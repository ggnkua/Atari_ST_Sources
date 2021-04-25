/* dump the contents of a file in hex words */

#include <stdio.h>

main(argc, argv) int argc; char *argv[]; {
	int i;
	FILE *f;
	if (argc == 1) {
		hd(stdin);
	}
	else	{
		for (i = 1; i < argc; i++) {
			printf("%s\n", argv[i]);
			if ((f = fopen(argv[i], "r")) != NULL) {
				hd(f);
				fclose(f);
			}
		}
	}
	return 0;
}

hd(f) FILE *f; {
	int offset, cnt, hi, lo, i, word[8];
	offset = 0;
	cnt = 8;
	while (cnt == 8) {
		puthex(offset, 4);
		putchar(':');
		putchar(' ');
		for (cnt = 0; cnt < 8; ) {
			if ((hi = getc(f)) == EOF) break;
			offset++;
			if ((lo = getc(f)) == EOF) {
				word[cnt++] = (hi << 8);
				break;
			}
			else	{
				word[cnt++] = (hi << 8) + lo;
				offset++;
			}
		}
		for (i = 0; i < cnt; i++) {
			puthex(word[i], 4);
			putchar(' ');
		}
		for ( ; i < 8; i++) printf("     ");
		printf(" | ");
		for (i = 0; i < cnt; i++) {
			putcx(word[i] >> 8);
			putcx(word[i]);
		}
		putchar('\n');
	}
	if (cnt != 0) {
		puthex(offset, 4);
		putchar('\n');
	}
}

puthex(n, size) {
	if (size > 1) puthex(n >> 4, size - 1);
	putchar("0123456789ABCDEF"[n & 15]);
}

putcx(c) {
	c = c & 255;
	if (c >= 32 && c <= 127) putchar(c);
	else putchar('.');
}

