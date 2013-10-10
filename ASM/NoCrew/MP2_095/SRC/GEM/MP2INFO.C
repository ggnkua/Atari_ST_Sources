#include <tos.h>
#include <aes.h>
#include <stdio.h>

#define IS_MP2INFO_C
#include "mp2info.h"

/* Function in this module */
int getmp2info(int file);
void show_mp2_error(int error);

/* global variable from mp2audio.c */
extern int fd;

/* global variable from mp2file.c */
extern long filesize;

/* global variable from mp2event.c */
extern long total_time;

/* global variable */
MP2INFO mp2info;

int getmp2info(int file)
{
	FRAME_HEADER header;
/*	char tmp[128]; */
	
	Fread(file,sizeof(FRAME_HEADER),(void *)&header);
	Fseek(-(long)sizeof(FRAME_HEADER),file,1);
	
	if(header.sync!=0xfff)
		return -MP2ERR_SYNC;

	if(header.mode==MODE_MONO)
		return -MP2ERR_MONO;

/*
	if(header.protection==PROT_CRC)
		return -MP2ERR_CRC;
*/
	
	mp2info.bitrate=bitrates[header.id][header.layer][header.bitrate];
	mp2info.sample_frequency=frequencies[header.id][header.frequency];
	mp2info.filelength=filesize;
	
	if(mp2info.bitrate<=0)
		return -MP2ERR_OTHER;
	total_time=mp2info.timelength=(mp2info.filelength*8)/mp2info.bitrate;

/*
	sprintf(tmp,"[1][Bitrate: %ld|Frequency: %ld|Total time: %02ld:%02ld][Ok]",
		mp2info.bitrate,mp2info.sample_frequency,mp2info.timelength/60,mp2info.timelength%60);
	form_alert(1,tmp);
*/	
	return MP2_NOERR;
}


void show_mp2_error(int error)
{
	switch(error)
	{
		case -MP2ERR_SYNC:
			form_alert(1,"[3][Not a valid MPEG file!|No sync!][Ok]");
			break;
		case -MP2ERR_MONO:
			form_alert(1,"[3][No support for mono, yet!][Ok]");
			break;
		case -MP2ERR_CRC:
			form_alert(1,"[3][No support for CRC, yet!][Ok]");
			break;
		case -MP2ERR_OTHER:
			form_alert(1,"[3][Not a valid MPEG file!][Ok]");
			break;
		default:
			break;
	}
}

