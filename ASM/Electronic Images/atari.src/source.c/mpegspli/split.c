/*
 * Copyright (c) 1994 Michael Simmons.
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
/*
 * System layer spliter routines
 */

#include    "main.h"

static Pack_Header 	   pack_header;
static System_Header   system_header,system_header2;
static Packet          packet;

/*
 *
 *
 */
void split_stream(char *szFileName)
{
	int BufLength;
	unsigned int data;
	int i, ret;
	unsigned int err;

	if ((BitStream = fopen(szFileName,"rb")) == NULL){
		errmsg(ERR_OPEN_BSTREAM);
		return;
    }

/*    rewind(BitStream); */ /* Could be Socket ? later on */

    BufLength = ( BUF_LENGTH + 3) >> 2;
    buf_start = (unsigned int *) malloc(BufLength * 4);
    if( buf_start == NULL){
		fclose(BitStream);
		errmsg(ERR_MALLOC);
		return;
    }
    max_buf_length = BufLength - 1;

/* initialize bit io */
    EOF_flag = 0;
    bitOffset = 0;
    bufLength = 0;
    bitBuffer = buf_start;
    curBits = *bitBuffer;

/* initialize info on elementary streams */
    for( i=0; i<MAX_NUM_STREAMS; i++){
		streamInfo[i].stream = NULL;
		streamInfo[i].STD_scale =0;
		streamInfo[i].STD_size =0;
		streamInfo[i].PTS_hibit = 0;
		streamInfo[i].PTS = 0;
		streamInfo[i].DTS_hibit = 0;
		streamInfo[i].DTS = 0;
    }

    ret = setjmp(env);      /* in case a fatal low level error occurs */
    if (ret != 0 ) {
		errmsg(ret);
    }else{
		system_header_found = FALSE;
		pack_cnt = packet_cnt = system_header_cnt = 0;

		next_start_code();
		show_bits32(&data);
		if( data != PACK_START_CODE){
			errmsg(ERR_NOT_SYSTEM_LAYER);
		}else{
			do{
				if( err = parse_pack()){
					errmsg(err);
					break;
				}
				next_start_code();
			}while (next_bits(32,PACK_START_CODE));

			if( (err == NO_ERROR) && !next_bits(32,ISO_11172_END_CODE))
				errmsg(ERR_MISSING_END_CODE);
		}
	}

	dialog_end();

	for( i=0; i<MAX_NUM_STREAMS; i++)
		if( streamInfo[i].stream != NULL ){
			fclose(streamInfo[i].stream);
			streamInfo[i].stream = NULL;
		}

 	if( BitStream != NULL){
		fclose(BitStream);
		BitStream = NULL;
	}
}


/*
 * Parse a system layer pack
 * each packet extracted is pass to process_packet for processing
 */

int parse_pack()
{
	unsigned int data;
	unsigned int err;

	if( err = parse_pack_header(&pack_header) )
		return (err | ERR_PARSE_PACK);

	pack_cnt++;
	if( verbose_flag && !quiet_flag )
		dialog_pack_header(&pack_header , pack_cnt);

    if( next_bits(32,SYSTEM_HEADER_START_CODE)){
		system_header_cnt++;
		if( system_header_found ){
			if( err = parse_system_header( &system_header2 ) )
				return (err | ERR_PARSE_PACK);
			if( err = compare_system_headers(&system_header,&system_header2) )
				return (err | ERR_PARSE_PACK);
		}else{
			system_header_found = TRUE;
			if( err = parse_system_header( &system_header ))
				return (err | ERR_PARSE_PACK);
			dialog_system_header(&system_header);
		}
	}

    show_bits32(&data);
    while( (RESERVED_STREAM <= data) && (data <= RESERVED_DATA_STREAM_15) ){
		if( system_header_found == FALSE )
			return (ERR_PARSE_PACK | ERR_MISSING_SYSTEM_HDR);
		if( err = parse_packet(&packet) ){
			cleanup_packet(&packet);
	    	return (err | ERR_PARSE_PACK);
		}
		if( err = process_packet(&packet) ){
			cleanup_packet(&packet);
			return (err | ERR_PARSE_PACK);
		}
		cleanup_packet(&packet);
		show_bits32(&data);
   	}
	
    return NO_ERROR;
}

/*
 * Processes a packet of stream data
 * At the moment it appends the packet to a file
 * created for each elemental stream.
 */
int process_packet(Packet *packet)
{
	unsigned int byteswritten;
	unsigned int stream_num;

	packet_cnt++;

    stream_num = packet->stream_id - (RESERVED_STREAM & 0xff);

    if ( streamInfo[stream_num].stream == NULL ){ 
		char szBuf[32];
		sprintf(szBuf,"stm%d.mpg\0",packet->stream_id);
		streamInfo[stream_num].stream = fopen(szBuf,"wb");
		if( streamInfo[stream_num].stream == NULL ){
	    	return (ERR_OPEN_ESTREAM | ERR_PROCESS_PACKET);
		}
		if( verbose_flag && !quiet_flag ){
			char szMsgBuf[100];
			sprintf(szMsgBuf,"Opening stream file %s\0",szBuf);
			dialog_msg(szMsgBuf);
		}
    }

	if( packet->buffer == NULL )
		return (ERR_NO_PACKET_BUFFER | ERR_PROCESS_PACKET);

    byteswritten = fwrite( (char *)packet->buffer, 1, packet->buffer_size, streamInfo[stream_num].stream);

    if( byteswritten != packet->buffer_size )
		return (ERR_WRITE_ESTREAM | ERR_PROCESS_PACKET);

    return NO_ERROR;
}

/*
 * Cleans up a packet after it has been processed
 */
void cleanup_packet(Packet *packet)
{
	if( packet->buffer != NULL){
		free(packet->buffer);
		packet->buffer = NULL;
	}
}

/*
 * This routine compares two system headers and returns and error
 * if they are different
 * Only a stub at the moment
 */
int compare_system_headers(System_Header *system_header,System_Header *system_header2)
{
	if (FALSE )
		return ERR_DIFF_SYSTEM_HDR;

	return NO_ERROR;
}
 
