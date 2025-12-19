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
 *  This small program converts the a56.out file from the assembler
 *  into a file suitable for loading into 56001 memory via the
 *  SLOADER.ASM serial loader program provided on the Motorola
 *  Dr. Bubb BBS.
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
    int curseg = '\0';
    int startaddr = -1;

    while(gets(buf)) {
	char seg;
	int addr, data;
	line++;
	if(sscanf(buf, "%c%x%x", &seg, &addr, &data) == 3) {
	    if(seg != curseg || curaddr != addr) {
		printf("\n_DATA %c %04X\n", curseg = seg, curaddr = addr);
	    }   
	    if(startaddr == -1 && seg == 'P')
		startaddr = addr;
	    printf("%06X ", data & 0xFFFFFF);
	    curaddr++;
	}
    }
    printf("\n_END %04X\n", startaddr);
}
