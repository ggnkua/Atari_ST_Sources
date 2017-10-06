//////////////////////////////////////////////////////////////////////////////
//
//  This file is part of the Atari Machine Specific Library,
//  and is Copyright 1992 by Warwick W. Allison.
//
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.
//
//////////////////////////////////////////////////////////////////////////////

// Generates TrueColour Draw() and Wipe() source-code

// TrueColour incarnations are drawn using a series of "commands"
// from the Data.  The commands are:
//
//	0	Quit
//	1..22	n sequential pixels
//
//	24	5x1-pixel
//	25	5x2-pixel
//	26	3x2;2x4-pixel
//
//	32	5x1-pixel 'AND'
//	33	5x2-pixel 'AND'
//	34	3x2;2x4-pixel 'AND'
//
//	40	5x1-pixel 'ADD'
//	41	5x2-pixel 'ADD'
//	42	3x2;2x4-pixel 'ADD'
//
//	48	5x1-pixel 'OR'
//	49	5x2-pixel 'OR'
//	50	3x2;2x4-pixel 'OR'
//

#include <stdio.h>
#include <string.h>

static int arch;

static void WriteDraw()
{
	char* nextcmd="movel\t#TCDraw,a2\n\t\tmovew\t%0@+,d0\n\t\taslw\t#2,d0\n\t\tmovel\t\ta2@(d0:w),a0\n\t\tjmp\t\ta0@";
	char* nextrecmd="movew\t%0@+,d0\n\t\taslw\t#2,d0\n\t\tmovel\ta2@(d0:w),a0\n\t\tjmp\t\ta0@";

	if (arch >= 68020) {
		nextcmd="movel\t#TCDraw,a2\n\t\tmovew\t%0@+,d0\n\t\tjmp\t\ta2@(d0:w:4)@0";
		nextrecmd="movew\t%0@+,d0\n\t\tjmp\t\ta2@(d0:w:4)@0";
	}

	FILE* fd=fopen("tcd.icc","w");

	if (!fd) return -1;

	fprintf(fd,"	asm(\"
		.data
	TCDraw:
		.long TCDQ,TCD1,TCD2,TCD3,TCD4,TCD5,TCD6,TCD7
		.long TCD8,TCD9,TCD10,TCD11,TCD12,TCD13,TCD14,TCD15
		.long TCD16,TCD17,TCD18,TCD19,TCD20,TCD21,TCD22,TCDCMD
		.long TCD24,TCD25,TCD26,TCDCMD,TCDCMD,TCDCMD,TCDCMD,TCDCMD
		.long TCD32,TCD33,TCD34,TCDCMD,TCDCMD,TCDCMD,TCDCMD,TCDCMD
		.long TCD40,TCD41,TCD42,TCDCMD,TCDCMD,TCDCMD,TCDCMD,TCDCMD
		.long TCD48,TCD49,TCD50,TCDCMD,TCDCMD,TCDCMD,TCDCMD,TCDCMD
		.long TCDCMD,TCDCMD,TCDCMD,TCDCMD,TCDCMD,TCDCMD,TCDCMD,TCDCMD

		.text

		moveml	d2-d7/a2-a6,sp@-
		movel	%%2,%%1@+

	TCDCMD:
		%s

	TCD1:
		movel	%%0@+,a6
		movew	%%0@+,d0
		movew	a6@(%%2:l),%%1@+
		movew	d0,a6@(%%2:l)
		%s

	TCD2:
		movel	%%0@+,a6
		movel	%%0@+,d0
		movel	a6@(%%2:l),%%1@+
		movel	d0,a6@(%%2:l)
		%s

	TCD3:
		movel	%%0@+,a6
		movel	%%0@+,d0
		movew	%%0@+,d1
		movel	a6@(%%2:l),%%1@+
		movew	a6@(4,%%2:l),%%1@+
		movel	d0,a6@(%%2:l)
		movew	d1,a6@(4,%%2:l)
		%s

	TCD4:
		movel	%%0@+,a6
		movel	%%0@+,d0
		movel	%%0@+,d1
		movel	a6@(%%2:l),%%1@+
		movel	a6@(4,%%2:l),%%1@+
		movel	d0,a6@(%%2:l)
		movel	d1,a6@(4,%%2:l)
		%s

	TCD5:
		movel	%%0@+,a6
		movel	%%0@+,d0
		movel	%%0@+,d1
		movew	%%0@+,d2
		movel	a6@(%%2:l),%%1@+
		movel	a6@(4,%%2:l),%%1@+
		movew	a6@(8,%%2:l),%%1@+
		movel	d0,a6@(%%2:l)
		movel	d1,a6@(4,%%2:l)
		movew	d2,a6@(8,%%2:l)
		%s
	",nextcmd,nextrecmd,nextrecmd,nextrecmd,nextrecmd,nextrecmd);

	char r[128]="d0-d1";
	for (int i=6; i<=22; i+=2) {
		char newr[10];
		int reg=(i-6)/2;
		sprintf(newr,"/%c%d",(reg<5 ? 'd' : 'a'),(reg<5 ? reg+2 : reg-5));
		strcat(r,newr);

		fprintf(fd,"
	TCD%d:
		movel	%%0@+,a6
		moveml	a6@(%%2:l),%s
		moveml	%s,%%1@
		addl	#%d,%%1
		moveml	%%0@+,%s
		moveml	%s,a6@(%%2:l)
		%s

	",i,r,r,i*2,r,r,(i<20 ? nextrecmd : nextcmd));

		if (i<22) {
			fprintf(fd,"
	TCD%d:
		movel	%%0@+,a6
		movew	a6@(%%2:l),a3
		movew	a3,%%1@+
		moveml	a6@(2,%%2:l),%s
		moveml	%s,%%1@
		addl	#%d,%%1
		movew	%%0@+,a3
		movew	a3,a6@(%%2:l)
		moveml	%%0@+,%s
		moveml	%s,a6@(2,%%2:l)
		%s

	",i+1,r,r,i*2,r,r,(i<20 ? nextrecmd : nextcmd));
		}
	}

	fprintf(fd,"
	TCD24:
	TCD25:
	TCD26:
	TCD32:
	TCD33:
	TCD34:
	TCD40:
	TCD41:
	TCD42:
	TCD48:
	TCD49:
	TCD50:
	TCDQ:
		moveml	sp@+,d2-d7/a2-a6
	\" : // No outputs
		: // Inputs
		\"a\" (Data),
		\"a\" (Store),
		\"d\" (At)
		: \"d0\",\"d1\",\"d2\",\"d3\",\"d4\",\"d5\",\"d6\",
			\"a0\",\"a1\",\"a2\",\"a3\",\"a6\"
	);
	");

	fclose(fd);
}


static void WriteWipe()
{
	char* nextcmd="movel\t#TCWipe,a2\n\t\tmovew\t%0@+,d0\n\t\taslw\t#2,d0\n\t\tmovel\t\ta2@(d0:w),a0\n\t\tjmp\t\ta0@";
	char* nextrecmd="movew\t%0@+,d0\n\t\taslw\t#2,d0\n\t\tmovel\ta2@(d0:w),a0\n\t\tjmp\t\ta0@";

	if (arch >= 68020) {
		nextcmd="movel\t#TCWipe,a2\n\t\tmovew\t%0@+,d0\n\t\tjmp\t\ta2@(d0:w:4)@0";
		nextrecmd="movew\t%0@+,d0\n\t\tjmp\t\ta2@(d0:w:4)@0";
	}

	FILE* fd=fopen("tcw.icc","w");

	if (!fd) return -1;

	fprintf(fd,"	asm(\"
		.data
	TCWipe:
		.long TCWQ,TCW1,TCW2,TCW3,TCW4,TCW5,TCW6,TCW7
		.long TCW8,TCW9,TCW10,TCW11,TCW12,TCW13,TCW14,TCW15
		.long TCW16,TCW17,TCW18,TCW19,TCW20,TCW21,TCW22,TCWCMD
		.long TCW24,TCW25,TCW26,TCWCMD,TCWCMD,TCWCMD,TCWCMD,TCWCMD
		.long TCW32,TCW33,TCW34,TCWCMD,TCWCMD,TCWCMD,TCWCMD,TCWCMD
		.long TCW40,TCW41,TCW42,TCWCMD,TCWCMD,TCWCMD,TCWCMD,TCWCMD
		.long TCW48,TCW49,TCW50,TCWCMD,TCWCMD,TCWCMD,TCWCMD,TCWCMD
		.long TCWCMD,TCWCMD,TCWCMD,TCWCMD,TCWCMD,TCWCMD,TCWCMD,TCWCMD

		.text

		moveml	d2-d7/a2-a6,sp@-
		movel	%%1@+,d7

	TCWCMD:
		%s

	TCW1:
		movel	%%0@+,a6
		movew	%%1@+,d0
		movew	d0,a6@(d7:l)
		addl	#2,%%0
		%s

	TCW2:
		movel	%%0@+,a6
		movel	%%1@+,d0
		movel	d0,a6@(d7:l)
		addl	#4,%%0
		%s

	TCW3:
		movel	%%0@+,a6
		movel	%%1@+,d0
		movel	d0,a6@(d7:l)
		movew	%%1@+,d0
		movew	d0,a6@(4,d7:l)
		addl	#6,%%0
		%s

	TCW4:
		movel	%%0@+,a6
		movel	%%1@+,d0
		movel	d0,a6@(d7:l)
		movel	%%1@+,d0
		movel	d0,a6@(4,d7:l)
		addl	#8,%%0
		%s

	TCW5:
		movel	%%0@+,a6
		movel	%%1@+,d0
		movel	%%1@+,d1
		movew	%%1@+,d2
		movel	d0,a6@(d7:l)
		movel	d1,a6@(4,d7:l)
		movew	d2,a6@(8,d7:l)
		addl	#10,%%0
		%s
	",nextcmd,nextrecmd,nextrecmd,nextrecmd,nextrecmd,nextrecmd);

	char r[128]="d0-d1";
	for (int i=6; i<=22; i+=2) {
		char newr[10];
		int reg=(i-6)/2;
		sprintf(newr,"/%c%d",(reg<5 ? 'd' : 'a'),(reg<5 ? reg+2 : reg-5));
		strcat(r,newr);

		fprintf(fd,"
	TCW%d:
		movel	%%0@+,a6
		moveml	%%1@+,%s
		moveml	%s,a6@(d7:l)
		addl	#%d,%%0
		%s

	",i,r,r,i*2,(i<20 ? nextrecmd : nextcmd));

		if (i<22) {
			fprintf(fd,"
	TCW%d:
		movel	%%0@+,a6
		movew	%%1@+,d0
		movew	d0,a6@(d7:l)
		moveml	%%1@+,%s
		moveml	%s,a6@(2,d7:l)
		addl	#%d,%%0
		%s

	",i+1,r,r,i*2+2,(i<20 ? nextrecmd : nextcmd));
		}
	}

	fprintf(fd,"
	TCW24:
	TCW25:
	TCW26:
	TCW32:
	TCW33:
	TCW34:
	TCW40:
	TCW41:
	TCW42:
	TCW48:
	TCW49:
	TCW50:
	TCWQ:
		moveml	sp@+,d2-d7/a2-a6
	\" : // No outputs
		: // Inputs
		\"a\" (Data),
		\"a\" (Store)
		: \"d0\",\"d1\",\"d2\",\"d3\",\"d4\",\"d5\",\"d6\", \"d7\",
			\"a0\",\"a1\",\"a2\",\"a3\",\"a6\"
	);
	");

	fclose(fd);
}

main(int argc, char* argv[])
{
	if (argc>1) {
		arch=68020;
	} else {
		arch=68000;
	}

	WriteDraw();
	WriteWipe();
}
