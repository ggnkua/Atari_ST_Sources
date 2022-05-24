/*
 * Copyright (c) 1994 Michael Simmons
 * All rights reserved.
 * 
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement is
 * hereby granted, provided that the above copyright notice and the following
 * two paragraphs appear in all copies of this software.
 * 
 * IN NO EVENT SHALL MICHAEL SIMMONS BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
 * OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF MICHAEL SIMMONS
 * HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * THE MICHAEL SIMMONS SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND MICHAEL SIMMONS HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 *
 * I can be contacted via 
 * Email: michael@ecel.uwa.edu.au
 * Post: P.O. Box 506, NEDLANDS WA 6009, AUSTRALIA
 */

#include "main.h"

void dialog_msg(char *msg)
{
	printf("\n%s\n",msg);
}

void dialog_end()
{
	printf("\nProcessing Complete\n");
	printf("  Processed %d Packs",pack_cnt);
	printf(" , %d system headers",system_header_cnt);
	printf(" and %d Packets\n",packet_cnt);
}

void dialog_progress()
{
	static int state = 0;
	static char *progress_char = "\\|/-";

	printf("\b%c",progress_char[state++]);
	if( state== 4)
		state=0;
}

void dialog_pack_header(Pack_Header *pack_header, int pack_num)
{
	double SCR;

	if( quiet_flag )
		return;

	SCR = pack_header->SCR_hibit * pow(2.0,32.0); 
	SCR = SCR + pack_header->SCR;

	printf("\nPACK %d SCR=%g Mux date rate = %d bytes per second ",pack_num,SCR, pack_header->mux_rate *50);
}

void dialog_system_header(System_Header *system_header)
{
	int stream_id;
	
	if( quiet_flag )
		return;

	printf("\nSYSTEM HEADER\n");
	printf("-------------\n");

	printf("Maximum Multiplexed data rate =%d bytes per second\n", system_header->rate_bound * 50);
	printf("Max number of audio streams = %d\n",system_header->audio_bound);

	if( system_header->fixed_flag )
		printf("Bitrate is fixed\n");
	else
		printf("Bitrate is variable\n");

	if( system_header->CSPS_flag )
		printf("Multiplexed stream meets constrained parameters\n");
	else
		printf("Multiplexed stream does not meets constrained parameters\n");

	if( system_header->audio_lock_flag )
		printf("There is a ");
	else
		printf("There is no ");
	printf("constant rational relationship between the\n");
	printf("audio sampling rate and the system clock frequency in the system\n");
	printf("target decoder\n");

	if( system_header->video_lock_flag )
		printf("There is a ");
	else
		printf("There is no ");
	printf("constant rational relationship between the\n");
	printf("video picture rate and the system clock frequency in the system\n");
	printf("target decoder\n");

	printf("Max number of video streams = %d\n",system_header->video_bound);
	printf("Reserved_byte = %0x\n",system_header->reserved_byte);

	printf("Stream Information\n");
	for( stream_id =0; stream_id<MAX_NUM_STREAMS; stream_id++)
		if( system_header->STD_flag[stream_id] ){
			printf("    for stream %0x : ",stream_id + RESERVED_STREAM);
			if( system_header->STD_scale_bound[stream_id] )
				printf("        Buffer bound = %d bytes\n",system_header->STD_size_bound[stream_id] * 128);
			else
				printf("        Buffer bound = %d bytes\n",system_header->STD_size_bound[stream_id] * 1024);
		}
	printf("\n");
}

