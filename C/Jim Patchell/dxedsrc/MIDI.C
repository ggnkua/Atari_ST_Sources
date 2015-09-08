/*
	these are the midi routines that are used to communicate with the
	DX-7, TX2/8-16

	These routines are specific to the TX-2/8-16

	Copyright (c) 1987 by EMC

*/

#include "dx.h"
#include <osbind.h>
#include <stdio.h>

/*
	global variables
*/
static char midibuf[5000];
IOREC old,*midi;
int midi_ch;

char *cprt = "Copyright (c) 1987 by EMC";

setup_midi()
{
	/*
		this routine sets up a big buffer for the midi port
		otherwise, C just ain't fast enough to get the data
	*/
	midi = (IOREC *)(Iorec(2));
	old.ibuf = midi->ibuf;
	old.ibufsiz = midi ->ibufsiz;
	old.ibuflow = midi ->ibuflow;
	old.ibufhigh = midi ->ibufhigh;
	midi->ibuf = midibuf;
	midi->ibufsiz = 5000;
	midi->ibuflow = 128;
	midi->ibufhigh = 5000 - 128;
	midi->ibufhd = 0;
	midi->ibuftl = 0;
	/*
		also init any global midi variables
	*/
	midi_ch = 0;	/*	 set up to midi chan 1	*/
}
undo_midi()
{
	/*
		undoes setup_midi.  Must be called before exiting of system
		may crash if something outputs on MIDI
	*/
	midi->ibuf = old.ibuf;
	midi ->ibufsiz = old.ibufsiz;
	midi ->ibuflow = old.ibuflow;
	midi ->ibufhigh = old.ibufhigh;
	old.ibufhd = 0;
	old.ibuftl = 0;
}

flush_midi()
{
	while(Bconstat(MIDI) == -1)
		Bconin(MIDI);		/*	Get any extra garbage	*/
}

long get_ed(buff)
char buff[];
{
	/*
		get system exclusive data from the midi port
	*/
	int a,count,ck_sum,end;
	char cmd_frm[6],temp[128];
	register long i;
	register int checksum,time;

	i = 0l;
	time = 100;
	while(Bconstat(MIDI) == 0) 	/*	wait for first character	*/
	{
		--time;
		if(time == 0)
		{
			form_alert(1,"[2][Time out error on MIDI][OK]");
			return(0L);
		}
	}
	/*	get command frame	*/
	time = 100;
	for(i=0;i<6;++i)
	{
		loop: if(Bconstat(MIDI) == 0)
		{
			--time;
			if(time == 0)
			{
				form_alert(1,"[2][Time out error on MIDI][OK]");
				return(0);	/*	timeout error	*/
			}
			goto loop;
		}
		cmd_frm[i] = Bconin(MIDI);
		time = 100;
	}
	time = 100;
	count = (cmd_frm[5] & 0x7f) + ((cmd_frm[4] & 0x7f) * 128);
	checksum = 0;
	for(i=0;i < (long)count;++i)
	{
		do
		{
			--time;
			if (time == 0)
			{
				form_alert(1,"[2][Time out error on MIDI][OK]");
				return(0L);
			}
		} while(Bconstat(MIDI) == 0);	/*	wait until char in midi	*/
		buff[i] = (char)Bconin(MIDI);
		time = 100;
		checksum = (checksum + (int)buff[i]) & 0x07f;
	}
	time = 100;
	do
	{
		if(Bconstat(MIDI) == -1)
		{
			ck_sum = Bconin(MIDI);
			break;
		}
		--time;
	}while (time != 0);
	time = 10;
	do
	{
		if(Bconstat(MIDI) == -1)
		{
			end = Bconin(MIDI) & 0x0ff;
			break;
		}
		--time;
	}while (time != 0);
	if (end != EOX)
		form_alert(1,"[2][Midi did not send EOX][OK]");
	if (((ck_sum + checksum) & 0x7f) != 0)
		form_alert(1,"[2][Checksum was BAD][OK]");
	return(i);
}

send_cmd(chan,format)
int chan,format;
{
	/*
		Sends a command fram to the DX-7 to get it to spit forth
		some data we can munch on
	*/
	flush_midi();			/*	clean out midi input chan	*/
	Bconout(MIDI,0x0f0);	/*	Status	*/
	Bconout(MIDI,0x43);		/*	I.D.	*/
	Bconout(MIDI,(0x20 | chan));	/*	channel	*/
	Bconout(MIDI,format);
	Bconout(MIDI,0x0f7);	/*	EOX		*/
}

chg_param(ch,group,sub,param,data)
int ch,group,param,data,sub;
{

	/*
		group -> g in TX manual
		sub   -> h in TX manual
	*/

	Bconout(MIDI,0xf0);		/*	status	*/
	Bconout(MIDI,0x43);		/*	I.D.	*/
	Bconout(MIDI,(0x10 | ch));	/*	sub status,channel	*/
	Bconout(MIDI,(group << 2) | sub);	/*	group number	*/
	Bconout(MIDI,param);	/*	parameter	*/
	Bconout(MIDI,data);
	Bconout(MIDI,EOX);
}

bulk_send(buff,ch,func)
char *buff;
int ch,func;
{
	/*
		send buffer in 32 voice bulk data format
		buffer must be 4096 bytes long
	*/
	register int checksum,i;
	register char *b;

	checksum = 0;
	b = buff;
	Bconout(MIDI,0x0f0);	/*	Status	*/
	Bconout(MIDI,0x43);		/*	ID	*/
	Bconout(MIDI,ch);		/*	sub status, channel	*/
	Bconout(MIDI,func);		/*	format number	*/
	Bconout(MIDI,0x20);		/*	byte count of 4096	*/
	Bconout(MIDI,0x0);
	for(i=0;i<4096;++i)
	{
		Bconout(MIDI,b[i]);
		checksum = (checksum + b[i]) & 0x7f;
	}
	checksum = (0 - checksum) & 0x7f;	/*	complement checksum	*/
	Bconout(MIDI,checksum);
	Bconout(MIDI,EOX);
}

perf_send(ch,buff)
int ch;
char buff[];
{
	/*
		this function send the performance edit buffer to the
		tx2/8-16
	*/
	register int checksum,i;
	register char *b;

	checksum = 0;
	b = buff;
	Bconout(MIDI,0x0f0);	/*	Status	*/
	Bconout(MIDI,0x43);		/*	ID	*/
	Bconout(MIDI,ch);		/*	sub status, channel	*/
	Bconout(MIDI,1);		/*	format number	*/
	Bconout(MIDI,0x00);		/*	byte count of 94	*/
	Bconout(MIDI,0x5e);
	for(i=0;i<94;++i)
	{
		Bconout(MIDI,b[i]);
		checksum = (checksum + b[i]) & 0x7f;
	}
	checksum = (0 - checksum) & 0x7f;	/*	complement checksum	*/
	Bconout(MIDI,checksum);
	Bconout(MIDI,EOX);
}

edit_send(ch,buff)
int ch;
char buff[];
{
	register int checksum,i;
	register char *b;

	checksum = 0;
	b = buff;
	Bconout(MIDI,0x0f0);	/*	Status	*/
	Bconout(MIDI,0x43);		/*	ID	*/
	Bconout(MIDI,ch);		/*	sub status, channel	*/
	Bconout(MIDI,0);		/*	format number	*/
	Bconout(MIDI,0x01);		/*	byte count of 4096	*/
	Bconout(MIDI,0x1b);
	for(i=0;i<155;++i)
	{
		Bconout(MIDI,b[i]);
		checksum = (checksum + b[i]) & 0x7f;
	}
	checksum = (0 - checksum) & 0x7f;	/*	complement checksum	*/
	Bconout(MIDI,checksum);
	Bconout(MIDI,EOX);
}

bulk2ed(bulk,edit)
char bulk[],edit[];
{
	/*
		this routine will convert data in bulk voice format to
		that used by the edit buffer
	
		bulk[] points to the start of the voice in the bulk data
		buffer (this contains 4096 bytes, voices are on 128 byte
		bounderies

		edit[] points to the edit buffer to be sent

	*/
	int b,e;	/*	indexes for bulk and edit buffers	*/
	int i;

	/*
		move envelope generator parameters
	*/
	for(b=0,e=0,i=0;i<11;++i,++b,++e)	/*	operator 6	*/
		edit[e] = bulk[b];
	for(b=17,e=21,i=0;i<11;++i,++b,++e)	/*	operator 5	*/
		edit[e] = bulk[b];
	for(b=34,e=42,i=0;i<11;++i,++b,++e)	/*	operator 4	*/
		edit[e] = bulk[b];
	for(b=51,e=63,i=0;i<11;++i,++b,++e)	/*	operator 3	*/
		edit[e] = bulk[b];
	for(b=68,e=84,i=0;i<11;++i,++b,++e)	/*	operator 2	*/
		edit[e] = bulk[b];
	for(b=85,e=105,i=0;i<11;++i,++b,++e)	/*	operator 1	*/
		edit[e] = bulk[b];
	for(i=0,b=11,e=11;i<6;b +=17,e += 21,++i)
	{
		edit[e] = bulk[b] & 0x03;
		edit[e + 1] = (bulk[b] >> 2) & 0x03;
	}
	for(i=0,b=12,e=13;i<6;b +=17,e += 21,++i)
	{
		edit[e] = bulk[b] & 0x07;
		edit[e + 7] = (bulk[b] >> 3) & 0x0f;
	}
	for(i=0,b=13,e=14;i<6;b +=17,e += 21,++i)
	{
		edit[e] = bulk[b] & 0x03;
		edit[e + 1] = (bulk[b] >> 2) & 0x07;
	}
	for(i=0,b=14,e=16;i<6;++i,b += 17,e += 21)
		edit[e] = bulk[b];
	for(i=0,b=15,e=17;i<6;b +=17,e += 21,++i)
	{
		edit[e] = bulk[b] & 0x01;
		edit[e + 1] = (bulk[b] >> 1) & 0x3f;
	}
	for(i=0,b=16,e=19;i<6;b +=17,e += 21,++i)
		edit[e] = bulk[b];
	for(i=0,b=102,e=126;i<9;++i,++e,++b)
		edit[e] = bulk[b];
	for(i=0,b=117,e=144;i<11;++i,++e,++b)
		edit[e] = bulk[b];
	for(i=0,b=112,e=137;i<4;++i,++e,++b)
		edit[e] = bulk[b];
	edit[135] = bulk[111] & 0x07;
	edit[136] = (bulk[111] >> 3) & 0x01;
	edit[141] = bulk[116] & 0x01;
	edit[142] = (bulk[116] >> 1) & 0x07;
	edit[143] = (bulk[116] >> 4) & 0x07;
}

ed2bulk(bulk,edit)
char bulk[],edit[];
{
	/*
		this routine takes the edit format and puts it into
		bulk format i.e., undoes the last function
	*/
	register int e,b,i;	/*	lets be speedy	*/

	for(b=0,e=0,i=0;i<11;++i,++b,++e)	/*	operator 6	*/
		bulk[b] = edit[e];
	for(b=17,e=21,i=0;i<11;++i,++b,++e)	/*	operator 5	*/
		bulk[b] = edit[e];
	for(b=34,e=42,i=0;i<11;++i,++b,++e)	/*	operator 4	*/
		bulk[b] = edit[e];
	for(b=51,e=63,i=0;i<11;++i,++b,++e)	/*	operator 3	*/
		bulk[b] = edit[e];
	for(b=68,e=84,i=0;i<11;++i,++b,++e)	/*	operator 2	*/
		bulk[b] = edit[e];
	for(b=85,e=105,i=0;i<11;++i,++b,++e)	/*	operator 1	*/
		bulk[b] = edit[e];
	for(i=0,b=11,e=11;i<6;b +=17,e += 21,++i)
	{
		bulk[b] = edit[e] | (edit[e+1] << 2);
	}
	for(i=0,b=12,e=13;i<6;b +=17,e += 21,++i)
	{
		bulk[b] = edit[e] | (edit[e + 7] << 3);
	}
	for(i=0,b=13,e=14;i<6;b +=17,e += 21,++i)
	{
		bulk[b] = edit[e] | (edit[e + 1] << 2);
	}
	for(i=0,b=14,e=16;i<6;++i,b += 17,e += 21)
		bulk[b] = edit[e];
	for(i=0,b=15,e=17;i<6;b +=17,e += 21,++i)
	{
		bulk[b] = edit[e] | (edit[e + 1] << 1);
	}
	for(i=0,b=16,e=19;i<6;b +=17,e += 21,++i)
		bulk[b] = edit[e];
	for(i=0,b=102,e=126;i<9;++i,++e,++b)
		bulk[b] = edit[e];
	for(i=0,b=117,e=144;i<11;++i,++e,++b)
		bulk[b] = edit[e];
	for(i=0,b=112,e=137;i<4;++i,++e,++b)
		bulk[b] = edit[e];
	bulk[111] = edit[135] | (edit[136] <<3);
	bulk[116] = edit[141] | (edit[142] << 1) | (edit[143] << 4);
}

swap_bulk(v1,v2,bulkb,bulkp)
int v1,v2;
char *bulkb,*bulkp;
{
	char temp,*p1,*p2;	/*	temporary buffer	*/
	register int i;

	/*
		exchanges voices v1 and v2 in bulk buffer
	*/
	p1 = (char *)(&bulkb[v1 * 128]);
	p2 = (char *)(&bulkb[v2 * 128]);
	for(i=0;i<128;++i)
	{
		temp = p1[i];
		p1[i] = p2[i];
		p2[i] = temp;
	}
	p1 = (char *)(&bulkp[v1 * 64]);
	p2 = (char *)(&bulkp[v2 * 64]);
	for(i=0;i<64;++i)
	{
		temp = p1[i];
		p1[i] = p2[i];
		p2[i] = temp;
	}
}

pblk2ped(bulk,edit)
char bulk[],edit[];
{
	register int i,e,b;

	for(i=0,e=64,b=34;i<30;++i,++e,++b)	/*	performance name	*/
		edit[e] = bulk[b];

	for(i=0,e=3,b=1;i<2;++i,e += 30,b += 16)
	{
		edit[e] = bulk[b] & 0x0f;
		edit[e + 1] = (bulk[b] >> 4) + (bulk[b + 14] >> 3);	/* pitch bend range	*/
	}
	for(i=0,e=5,b=2;i<2;++i,e += 30,b += 16)
	{
		edit[e] = bulk[b];
	}
	for(i=0,e=2,b=0;i<2;++i,e += 30,b += 16)
	{
		edit[e] = bulk[b] >> 6;
	}
	for(i=0,e=6,b=3;i<2;++i,e += 30,b += 16)
	{
		edit[e] = bulk[b] & 0x01;
		edit[e + 1] = bulk[b] >> 1;
	}
	for(i=0,e=9,b=4;i<2;++i,e += 30,b += 16)
	{
		edit[e] = bulk[b] & 0x0f;
		edit[e + 1] = bulk[b] >> 4;
		edit[e+2] = bulk[b] & 0x0f;
		edit[e + 3] = bulk[b] >> 4;
		edit[e + 4] = bulk[b] & 0x0f;
		edit[e + 5] = bulk[b] >> 4;
		edit[e + 6] = bulk[b] & 0x0f;
		edit[e + 7] = bulk[b] >> 4;
	}
	for(i=0,e=26,b=14;i<2;++i,e += 30,b += 16)
	{
		edit[e] = bulk[b] & 0x07;
	}
	edit[61] = bulk[32] >> 2;
}

ped2pblk(bulk,edit)
char bulk[],edit[];
{
	/*
		converts a performance edit buffer to performance bulk buffer
		format
	*/
	register int e,b,i,t;

	for(i=0,e=0,b=0;i<2;++i,e+=30,b+=16)
	{
		bulk[0 + b] = edit[e + 2] << 6;
		t = ((edit[e + 4] << 4) & 0x80) >> 1;
		bulk[b + 1] = (edit[e + 3] & 0x0f) | ((edit[e + 4] << 4) & 0x7f);
		bulk[b + 15] = t;
		bulk[b + 2] = edit[e + 5];
		bulk[b + 3] = edit[e + 6] | (edit[e + 7] << 1);
		bulk[b + 4] = edit[e + 9] | (edit[e + 10] << 4);
		bulk[b + 5] = edit[e + 11] | (edit[e + 12] << 4);
		bulk[b + 6] = edit[e + 13] | (edit[e + 14] << 4);
		bulk[b + 7] = edit[e + 15] | (edit[e + 16] << 4);
		bulk[b + 14] = edit[e + 26];
	}
	bulk[32] = edit[61] << 2;
	for(e=64,b=34;e<94;++e,++b)
		bulk[b] = edit[e];
}

change_patch(ch,patch)
int ch,patch;
{
	Bconout(MIDI,0xc0 | (ch & 0x0f));
	Bconout(MIDI,patch & 0x7f);
}

new_voice(buff,p_buff,patch,v_name)
char buff[],p_buff[],v_name[];
int patch;
{
	/*
		this routine will make a 128 byte section of a bulk buffer
		be a new voice
	*/

	register int i,j;
	char s[33];

	for(i=0,j=0;i<6;++i,j = j + 17)	/*	operator data	*/
	{
		buff[j] = 99;	/*	envelope rates	*/
		buff[j+1] = 50;
		buff[j+2] = 50;
		buff[j+3] = 50;
		buff[j+4] = 99;	/* envelope levels	*/
		buff[j+5] = 80;
		buff[j+6] = 50;
		buff[j+7] = 0;
		buff[j+8] = 0;	/*	break point	*/
		buff[j+9] = 0;	/*	left depth	*/
		buff[j+10] = 0;	/*	right depth	*/
		buff[j+11] = 0;
		buff[j+12] = 0;
		buff[j+13] = 0;
		if (i == 5)	/*	operator 1	*/
			buff[j+14] = 99;
		else
			buff[j+14] = 0;	/*	all others	*/
		buff[j+15] = 2;	/*	ratio mode, ratio = 1	*/
		buff[j+16] = 0;
	}
	buff[102] = 99;	/*	pitch envelope rates	*/
	buff[103] = 99;
	buff[104] = 99;
	buff[105] = 99;
	buff[106] = 50;	/*	pitch envelope levels	*/
	buff[107] = 50;
	buff[108] = 50;
	buff[109] = 50;
	buff[110] = 0;	/*	algorithm 1	*/
	buff[111] = 0;
	buff[112] = 0;
	buff[113] = 0;
	buff[114] = 0;
	buff[115] = 0;
	buff[116] = 0;
	buff[117] = 24;
	for(i=118,j=0;i<128;++i,++j)
		buff[i] = v_name[j];
	/*
		this part makes the performance part of the buffer
		be new, 64 byte segment.
	*/
	new_perf(buff,p_buff,patch,v_name);
}

new_perf(buff,p_buff,patch,v_name)
char buff[],p_buff[],v_name[];
int patch;
{
	register int i,j;
	char s[33];

	for(i=0;i<33;++i)
		p_buff[i] = 0;
	p_buff[34] = 0x27;
	p_buff[12] = 0x63;
	p_buff[13] = 0x63;
	p_buff[28] = 0x63;
	p_buff[29] = 0x63;
	p_buff[14] = 0x17;
	p_buff[30] = 0x17;
	p_buff[15] = 0x18;
	p_buff[31] = 0x18;
	sprintf(s,"%2d %s  Lo:C -2 Hi:G 8 ",patch + 1,v_name);
	for(i=34,j=0;i<64;++i,++j)
		p_buff[i] = s[j];
}


fix_perf(b,p,patch)
char b[],p[];
int patch;
{
	int i,j;
	char s[34],name[11];

	for(i=0,j=118;i<10;++i,++j)
	{
		name[i] = b[j];
	}
	name[i] = '\0';	/*	make a real string	*/
	sprintf(s,"%2d %s  Lo:C -2 Hi:G 8 ",patch+1,name);
	for(i=34,j=0;i<64;++i,++j)
		p[i] = s[j];
}
