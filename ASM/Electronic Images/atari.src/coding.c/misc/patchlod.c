/* patchlod.c   communications to/from synth module for patchlib.c */

#include <conio.h>
#include <stdio.h>
#include <ctype.h>

#include "standard.h"
#include "writscrn.h"
#include "patchlib.h"

#define EXCL	0xF0	/* midi hex codes */
#define ENDEXCL	0xF7
#define ROLID	0x41
#define AJUNOF  0x23
#define MIDWSF 	0x40
#define MIDRQF 	0x41
#define MIDDAT 	0x42
#define MIDACK 	0x43
#define MIDEOF 	0x45
#define MIDERR	0x4E
#define MIDRJC	0x4F
#define MIDAPR	0x35

				/* MPU-401 op codes */
#define UART	0x3F	/* uart mode (simple com through 401 to synth */
#define SYSRESET 0xFF	/* resets 401 out of uart mode */



download(param, name, tonebyte)		/* put patch data from synth->tonebyte */
int param[];
char name[];
unsigned char tonebyte[NPATCH][NCODPARAM];
{
    int n, m, i;

    clearsc();    
    puts("      Download - Send all patches in synths memory to computer.");
    puts(" ");
    puts(" ");
    puts("Make sure your synth has MIDI EXCL turned on.");
    puts("   (ESC to exit)");
    puts(" ");
        
    putcmd(UART);	/* tell MPU401 to go into simple UART mode */

    for (i = 0; i < 10; i++){	/* make ten attempts to get data */
	puts("Hold data transfer key down and press bulk dump key on synth.");
	
	sendexcl(MIDRQF);
	m = getexcl();
	if (m == MIDWSF){
	    clearsc();
	    puts("Sending acknowledge, proceding with load.");
	    sendexcl(MIDACK);
	    break;
	}
	else if (m == -2){	/* user hit ESC */
	    putcmd(SYSRESET);
	    return(-1);
	}
	else{
	    puts("*** Failed load attempt, try again. ****");
	}
    }
    if (m != MIDWSF){
	writerr("Failed ten attempts to load. Aborting load procedure.");
	putcmd(SYSRESET);
	return(-1);
    }
    
    n = gettones(tonebyte);			/* get all patches */
    putcmd(SYSRESET);			/* put MPU401 back to normal mode */
    
    if (n == 0)
	puts("Data integrety checked ok.");
    else if (n == -2)			/* user hit ESC key */
	return(-1);
    else{
	puts("Checksum did not match, may be data error.");
	puts("Check data before saving, or resend.");
    }    
    
    puts(" ");
    puts("Patches received:");
    for (n = 0; n < 16; n++){
	m = n * 4;
	decode(m, param, name, tonebyte);
	fputs(name,stdout); fputs("   ",stdout);
	decode(m+1, param, name, tonebyte);
	fputs(name,stdout); fputs("   ",stdout);
	decode(m+2, param, name, tonebyte);
	fputs(name,stdout); fputs("   ",stdout);
	decode(m+3, param, name, tonebyte);
	fputs(name,stdout); fputc('\n',stdout);
    }
    writerr("Download complete.   ");
    return(1);
}



gettones(tonebyte)	/* get all compressed patches */
unsigned char tonebyte[NPATCH][NCODPARAM];
{		/*  returns -1 if checksum error, -2 if user hits ESC */
		
    int set, checksum, sendcheck, tone, byte, lsnib, msnib, sum, n, errcheck;

    errcheck = 0;    
    for (set = 0; set < 16; set++){	/* for each set of 4 patches */
	checksum = 0;
	while ((n = getdata()) != EXCL){
	    if (kbhit()){
		if (getch() == ESC)	/* allow user to quit - ESC key */
		    return(0);
	    }
	}
        getdata();		/* manufacture id */
        n = getdata();		/* op code */
	
	if (n != MIDDAT){
	    puts("\nDid not get data message from synth as expected.");
	    return(-1);
	}
        getdata();		/* midi channel */
        getdata();		/* format */

	for (tone = set*4; tone < (set*4) + 4; tone++){
	    for (byte = 0; byte < NCODPARAM; byte++){
		lsnib = getdata();
		msnib = getdata();
		tonebyte[tone][byte] = (msnib << 4) + lsnib;
		checksum = lsnib + msnib + checksum;
	    }
	}
	sendcheck = getdata();
	sum = checksum + sendcheck;
	
	if (getbits(sum,6,7) != 0)
	    errcheck = -1;
	n = getdata();
	if (n != ENDEXCL)
	    puts("Did not get ENDEXCL from synth.");
	sendexcl(MIDACK);
    }
    getexcl();		/* pick up EOF message */
    sendexcl(MIDACK);
    return(errcheck);
}



upload(tonebyte)	/* send sets of patch data to synth */
unsigned char tonebyte[NPATCH][NCODPARAM];
{
    int n, i;

    clearsc();    
    puts("        Upload - Send 64 patches in memory to synth.\n\n");
    puts("Make sure your synth has MIDI EXCL turned on.\n");
    puts("Also set the protect switch in back to the OFF position.\n");
    puts("   (Hitting the ESC key will terminate transmission)\n");
        
    putcmd(UART);	/* tell MPU401 to go into simple UART mode */

    for (i = 0; i < 10; i++){	/* make ten attempts to send data */
	puts("Hold DATA TRANSFER key down and press BULK LOAD key on synth.");
	
	n = getexcl();
	if (n == MIDRQF){
	    clearsc();
	    puts("Received request for data message, proceding with load.");
	    break;
	}
	else if (n == -2){	/* user hit ESC */
	    putcmd(SYSRESET);
	    return(1);
	}
	else{
	    puts("*** Did not get request for data, try again. ****");
	}
    }
    if (n != MIDRQF){
	writerr("Failed ten attempts to send. Aborting transmission.");
	putcmd(SYSRESET);
	return(1);
    }
    
    sendexcl(MIDWSF);
    n = getexcl();
    if (n != MIDACK)
	puts("Did not get ACK message after sending WSF.");
    
    n = sendtones(tonebyte);			/* send all patches */
    putcmd(SYSRESET);			/* put MPU401 back to normal mode */
    
    if (n == MIDACK)
	puts("Synth acknowledged data receipt was ok.");
    else if (n == -1){			/* user hit ESC key */
	writerr("Upload terminated. ");
	return(-1);
    }
    else{
	puts("Synth did not acknowledge final data receipt.");
	puts("Check data before saving, or resend.");
    }    
    
    writerr(" ");
    return(1);
}



sendtones(tonebyte)	/* send all compressed patches */
unsigned char tonebyte[NPATCH][NCODPARAM];
{		/* returns -1 if checksum error, -2 if user hits ESC */
		
    int set, checksum, tone, byte, lsnib, msnib, n;

    puts("\nSending patch data .......");

    for (set = 0; set < 16; set++){	/* for each set of 4 patches */
	checksum = 0;
	if (kbhit()){
	    if (getch() == ESC)		/* allow user to quit - ESC key */
		return(-1);
	}

        putdata(EXCL);		/* send exclusive data message header */
	putdata(ROLID);
	putdata(MIDDAT);
	putdata(0);
	putdata(AJUNOF);

	for (tone = set*4; tone < (set*4) + 4; tone++){
	    for (byte = 0; byte < NCODPARAM; byte++){
		n = tonebyte[tone][byte];
		lsnib = (n & 0x0f);
		msnib = (n & 0xf0) >> 4;
		putdata(lsnib);		
		putdata(msnib);
		checksum = lsnib + msnib + checksum;
	    }
	}
	checksum = (0 - checksum) & 0x7f;	/* ajuno expects checksum */
	putdata(checksum);			/* added to this no == 0 */
	putdata(ENDEXCL);
	
	n = getexcl();
	if (n != MIDACK)
	    puts("\nDid not get ACK from synth, possible data error.");
    }
    sendexcl(MIDEOF);		/* send EOF message */
    n = getexcl();
    return(n);
}
	
    
    
getexcl()	/* get a system exclusive (6 byte) message, return op code */
		/* returns -1 if byte 6 is not ENDEXCL, -2 if user hits ESC  */
{
    int n, m;
    
    while ((n = getdata()) != EXCL){
	if (kbhit()){
	    if (getch() == ESC)		/* allow user to quit by hitting ESC key */
		return(-2);
	}
    }
    getdata();			/* manufacture id */
    n = getdata();		/* op code */
    getdata();			/* midi channel */
    getdata();			/* format */
    m = getdata();		/* should be ENDEXCL */

    if (m == ENDEXCL)
	return(n);
    else
	return(-1);
}



sendexcl(code)		/* send midi excluseive message */
unsigned int code;
{
    putdata(EXCL);
    putdata(ROLID);
    putdata(code);
    putdata(0);
    putdata(AJUNOF);
    putdata(ENDEXCL);
}



getbits(x,p,n)		/* get n bits right of p in x */
unsigned x;		/* K & R page 45, ls bit is pos 0 */
int p,n;
{
    if (n > p + 1)
	n = p + 1;
    return((x >> (p + 1 - n)) & ~(~0 << n));
}



roltoa(n)	/* convert ajuno's letter codes to ascii */
int n;
{
    if (n >= 0 && n <= 25) 	/* chars A = 0, Z = 25 */
	n += 65;
    else if (n <= 51)	 	/* chars a = 26, Z = 51 */
	n += 71;
    else if (n <=61)		/* numbers 0 = 52 */
    	n -= 4;
    else if (n == 63)
    	n = '-';		/* space = 62 */
    else
    	n = ' ';
    return(n);
}


atorol(n)	/* convert ascii to ajuno's letter codes */
int n;
{
    if (isdigit(n))
	n += 4;
    else if (islower(n))
	n -= 71;
    else if (isupper(n))
	n -= 65;
    else if (n == '-')
	n = 63;
    else
	n = 62;
    return(n);
}


decode(num, param, name, tonebyte) /* convert tonebyte to int params/ name */
int num, param[];		
char name[];			
unsigned char tonebyte[NPATCH][NCODPARAM];
{
    unsigned char a, b, c, d;
    int i;
    
    param[0] = (getbits(tonebyte[num][5], 7, 1) << 1) +
	getbits(tonebyte[num][6], 7, 1); 
    param[1] = (getbits(tonebyte[num][7], 7, 1) << 1) +
	getbits(tonebyte[num][8], 7, 1); 
    param[2] = (getbits(tonebyte[num][9], 7, 1) << 1) + 
	getbits(tonebyte[num][10], 7, 1);
    param[3] = (getbits(tonebyte[num][17], 7, 1) << 1) + 
	getbits(tonebyte[num][18], 7, 1);     
    a = getbits(tonebyte[num][14], 7, 1);
    b = getbits(tonebyte[num][15], 7, 1);
    c = getbits(tonebyte[num][16], 7, 1);
    param[4] = (a << 2) + (b << 1) + c;
    a = getbits(tonebyte[num][11], 7, 1);
    b = getbits(tonebyte[num][12], 7, 1);
    c = getbits(tonebyte[num][13], 7, 1);
    param[5] = (a << 2) + (b << 1) + c;
    param[6] = (getbits(tonebyte[num][21], 7, 1) << 1) + 
	getbits(tonebyte[num][22], 7, 1); 
    param[7] = (getbits(tonebyte[num][23], 7, 1) << 1) + 
	getbits(tonebyte[num][23], 7, 1);     
    param[8] = (getbits(tonebyte[num][25], 7, 1) << 1) + 
	getbits(tonebyte[num][26], 7, 1);     
    param[9] = (getbits(tonebyte[num][19], 7, 1) << 1) + 
	getbits(tonebyte[num][20], 7, 1); 
    param[10] = getbits(tonebyte[num][4], 7, 1); 
    param[11] = getbits(tonebyte[num][3], 6, 7);
    param[12] = getbits(tonebyte[num][4], 6, 7);
    param[13] = getbits(tonebyte[num][0], 7, 4);
    param[14] = getbits(tonebyte[num][5], 6, 7);
    param[15] = getbits(tonebyte[num][6], 6, 7);
    param[16] = getbits(tonebyte[num][7], 6, 7);
    param[17] = getbits(tonebyte[num][8], 6, 7);
    param[18] = getbits(tonebyte[num][10], 6, 7);
    param[19] = getbits(tonebyte[num][9], 6, 7);
    param[20] = getbits(tonebyte[num][0], 3, 4);
    param[21] = getbits(tonebyte[num][1], 7, 4);
    param[22] = getbits(tonebyte[num][11], 6, 7);
    param[23] = getbits(tonebyte[num][1], 3, 4);
    param[24] = getbits(tonebyte[num][12], 6, 7);
    param[25] = getbits(tonebyte[num][13], 6, 7);
    param[26] = getbits(tonebyte[num][14], 6, 7);
    param[27] = getbits(tonebyte[num][15], 6, 7);
    param[28] = getbits(tonebyte[num][16], 6, 7);
    param[29] = getbits(tonebyte[num][17], 6, 7);
    param[30] = getbits(tonebyte[num][18], 6, 7);
    param[31] = getbits(tonebyte[num][19], 6, 7);
    param[32] = getbits(tonebyte[num][20], 6, 7);
    param[33] = getbits(tonebyte[num][2], 7, 4);
    a = getbits(tonebyte[num][27], 7, 2);
    b = getbits(tonebyte[num][28], 7, 2);
    c = getbits(tonebyte[num][29], 7, 2);
    d = getbits(tonebyte[num][30], 7, 2);
    param[34] = (d << 6) + (c << 4) + (b << 2) + a;
    param[35] = getbits(tonebyte[num][2], 3, 4);

    for (i = 0; i < 10; i++){
	name[i] = roltoa(getbits(tonebyte[num][21+i], 5, 6));
    }
    name[++i] = '\0';
}


encode(num, param, name, tonebyte) /* convert params and name to tonebyte[n] */
int num, param[];		/* makes comp data for global array tonebyte */
char name[];
unsigned char tonebyte[NPATCH][NCODPARAM];
{
    tonebyte[num][0] = (param[13] << 4) + param[20];
    tonebyte[num][1] = (param[21] << 4) + param[23];
    tonebyte[num][2] = (param[33] << 4) + param[35];
    tonebyte[num][3] = param[11];
    tonebyte[num][4] = (param[10] << 7) + param[12];
    tonebyte[num][5] = (getbits(param[0], 1, 1) << 7) + param[14];
    tonebyte[num][6] = (getbits(param[0], 0, 1) << 7) + param[15];
    tonebyte[num][7] = (getbits(param[1], 1, 1) << 7) + param[16];
    tonebyte[num][8] = (getbits(param[1], 0, 1) << 7) + param[17];
    tonebyte[num][9] = (getbits(param[2], 1, 1) << 7) + param[19];
    tonebyte[num][10] = (getbits(param[2], 0, 1) << 7) + param[18];
    tonebyte[num][11] = (getbits(param[5], 2, 1) << 7) + param[22];
    tonebyte[num][12] = (getbits(param[5], 1, 1) << 7) + param[24];
    tonebyte[num][13] = (getbits(param[5], 0, 1) << 7) + param[25];
    tonebyte[num][14] = (getbits(param[4], 2, 1) << 7) + param[26];
    tonebyte[num][15] = (getbits(param[4], 1, 1) << 7) + param[27];
    tonebyte[num][16] = (getbits(param[4], 0, 1) << 7) + param[28];
    tonebyte[num][17] = (getbits(param[3], 1, 1) << 7) + param[29];
    tonebyte[num][18] = (getbits(param[3], 0, 1) << 7) + param[30];
    tonebyte[num][19] = (getbits(param[9], 1, 1) << 7) + param[31];
    tonebyte[num][20] = (getbits(param[9], 0, 1) << 7) + param[32];
    tonebyte[num][21] = (getbits(param[6], 1, 1) << 7) + atorol(name[0]);
    tonebyte[num][22] = (getbits(param[6], 0, 1) << 7) + atorol(name[1]);
    tonebyte[num][23] = (getbits(param[7], 1, 1) << 7) + atorol(name[2]);
    tonebyte[num][24] = (getbits(param[7], 0, 1) << 7) + atorol(name[3]);
    tonebyte[num][25] = (getbits(param[8], 1, 1) << 7) + atorol(name[4]);
    tonebyte[num][26] = (getbits(param[8], 0, 1) << 7) + atorol(name[5]);
    tonebyte[num][27] = (getbits(param[34], 1, 2) << 6) + atorol(name[6]);
    tonebyte[num][28] = (getbits(param[34], 3, 2) << 6) + atorol(name[7]);
    tonebyte[num][29] = (getbits(param[34], 5, 2) << 6) + atorol(name[8]);
    tonebyte[num][30] = (getbits(param[34], 7, 2) << 6) + atorol(name[9]);
    tonebyte[num][31] = 0;
}


