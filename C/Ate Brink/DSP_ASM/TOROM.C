/*******************************************************
 *
 *  a56 - a DSP56001 assembler
 *
 *  Written by Quinn C. Jensen
 *  July 1990
 *  jensenq@npd.novell.com (or jensenq@qcj.icon.com)
 *
 *******************************************************\

/*
 * Copyright (C) 1990-1992 Quinn C. Jensen
 *
 * Permission to use, copy, modify, distribute, and sell this software
 * and its documentation for any purpose is hereby granted without fee,
 * provided that the above copyright notice appear in all copies and
 * that both that copyright notice and this permission notice appear
 * in supporting documentation.  The author makes no representations
 * about the suitability of this software for any purpose.  It is
 * provided "as is" without express or implied warranty.
 *
 */
static char *Copyright = "Copyright (C) 1990-1992 Quinn C. Jensen";

/*
 *  This program converts the a56.out assembler output file into
 *  raw binary, suitable for conversion to S-records for an EPROM burner.
 *
 */


#define MAX 256

main(argc,argv)
int argc;
char *argv[];
{
    char buf[MAX];
    int curaddr = 0;
    int line = 0;

    while(gets(buf)) {
	char seg;
	int addr, data;
	line++;
	if(sscanf(buf, "%c%x%x", &seg, &addr, &data) == 3) {
	    if(addr < curaddr) {
		fatal("%s: input line %d: can't go back\n", argv[0], line);
	    } else if(addr != curaddr) {
		while(curaddr < addr) {
		    putword(0);
		    curaddr++;
		}
	    }
	    putword(data);
	    curaddr++;
	}
    }
}

putword(data)
int data;
{
    putchar(data >>  0 & 0xFF);
    putchar(data >>  8 & 0xFF);
    putchar(data >> 16 & 0xFF);
}
