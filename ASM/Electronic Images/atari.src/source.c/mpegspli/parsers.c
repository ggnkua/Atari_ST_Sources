
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
 * Routines to parse the different parts of a pack 
 */

#include    "main.h"

#define check_marker                        \
{                                           \
	get_bits1(&data);                       \
	if ( data != 1)                         \
		return (err | ERR_INVALID_MARKER); \
}

/*
 * Parses the pack header
 * 
 */

int parse_pack_header(Pack_Header *pack_header)
{
    unsigned int data;
    unsigned int err = ERR_PARSE_PACK_HDR;

    flush_bits(32);	/* Flush PACK_START_CODE */
    
    get_bits4(&data);
    if( data != 2)
		return (err | ERR_INVALID_BITS);
	
    /* Get System Clock Reference*/  
    get_bits1(&data);
    pack_header->SCR_hibit = data;
    get_bits2(&data);
    pack_header->SCR = data << 30;
    check_marker;
    get_bits15(&data);
    pack_header->SCR |= data << 15;
    check_marker;
    get_bits15(&data);
    pack_header->SCR |= data;
    check_marker;
    check_marker;
    
	/* Get Mux Rate */
    get_bits22(&data);
    pack_header->mux_rate = data;
    check_marker;

    return NO_ERROR;
}

/*
 *	Parses the system header
 */

int parse_system_header( System_Header *system_header)
{
    unsigned int data;
	unsigned int stream_id;
	unsigned int err = ERR_PARSE_SYSTEM_HDR;

    flush_bits(32);	/* flush SYSTEM_HEADER_START_CODE */

	/* extract system header information */
    get_bits16(&data);
    system_header->header_length = data;
    check_marker;
    get_bits22(&data);
    system_header->rate_bound = data;
    check_marker;
    get_bits6(&data);
    system_header->audio_bound = data;
    get_bits1(&data);
    system_header->fixed_flag = data;
    get_bits1(&data);
    system_header->CSPS_flag = data;
    get_bits1(&data);
    system_header->audio_lock_flag = data;
    get_bits1(&data);
    system_header->video_lock_flag = data;
    check_marker;
    get_bits5(&data);
    system_header->video_bound = data;
    get_bits8(&data);
    system_header->reserved_byte = data;

	/* flag STD buffer bounds for each stream as invalid*/ 
	for( stream_id=0; stream_id< MAX_NUM_STREAMS; stream_id++)
		system_header->STD_flag[stream_id] = FALSE;

    while ( next_bits(1,1)){

		/* get stream number */
		get_bits8(&data);
		if( data < (RESERVED_STREAM & 0xff) || data > (RESERVED_DATA_STREAM_15 & 0xff))
			return (err | ERR_INVALID_STREAM_NUM );
	    stream_id = data - (RESERVED_STREAM & 0xff);
	
		get_bits2(&data);
		if( data != 3 )
	   		return (err | ERR_INVALID_BITS);

	 	/* Extract the STD buffer bounds for stream stream_id and flag it as valid */ 
		get_bits1(&data);
		system_header->STD_scale_bound[stream_id] = data;
		get_bits13(&data);
		system_header->STD_size_bound[stream_id] = data;
		system_header->STD_flag[stream_id] = TRUE;
    }

    return NO_ERROR;
}

/*
 * Reads in a packet from the stream
 * Updates the current stream info
 * Create a buffer and put the packet data in it
*/

int parse_packet(Packet *packet)
{
	unsigned int    data;
	unsigned int    byte_count;
    unsigned int err = ERR_PARSE_SYSTEM_HDR;
	int				i,stream_num;
	char			*bptr;

	get_bits24(&data);
	get_bits8(&data);

	if( data < (RESERVED_STREAM & 0xff) || data > (RESERVED_DATA_STREAM_15 & 0xff))
		return (err | ERR_INVALID_STREAM_NUM );

	packet->stream_id = data;

	stream_num = packet->stream_id - (RESERVED_STREAM & 0xff);
    
    get_bits16(&data);
    packet->packet_length = data;

    byte_count =0;

    packet->STD_flag=packet->PTS_Flag=packet->DTS_Flag = FALSE;
    
    if( packet->stream_id != PRIVATE_STREAM_2 ){

		/* flush stuffing bytes */
		while( next_bits(8,0xff)){
		    flush_bits(8);
		    byte_count++;
		}
	
		if( next_bits(2,1)){
		    flush_bits(2);

			/* Get STD buffer size and flag it as present in packet*/
		    get_bits1(&data);
		    streamInfo[stream_num].STD_scale=data;
		    get_bits13(&data);
		    streamInfo[stream_num].STD_size=data;
		    packet->STD_flag=TRUE;
		    byte_count +=2;
		}

		if( next_bits(4,2)){
		    flush_bits(4);

			/* Get presentation time stamp and flag it as present in packet*/
		    get_bits1(&data);
		    streamInfo[stream_num].PTS_hibit = data;
		    get_bits2(&data);
		    streamInfo[stream_num].PTS = data << 30;
		    check_marker;
		    get_bits15(&data);
		    streamInfo[stream_num].PTS |= data << 15;
		    check_marker;
		    get_bits15(&data);
		    streamInfo[stream_num].PTS |= data;
		    check_marker;
		    packet->PTS_Flag=TRUE;
		    byte_count +=5;
		    
		}else if (next_bits(4,3)){
		    flush_bits(4);

			/* Get presentation time stamp and decoding time stamp */
			/* and flag them as present in packet*/
		    get_bits1(&data);
		    streamInfo[stream_num].PTS_hibit = data;
		    get_bits2(&data);
		    streamInfo[stream_num].PTS = data << 30;
		    check_marker;
		    get_bits15(&data);
		    streamInfo[stream_num].PTS |= data << 15;
		    check_marker;
		    get_bits15(&data);
		    streamInfo[stream_num].PTS |= data;
		    check_marker;
		    packet->PTS_Flag=TRUE;
		    
		    if( !next_bits(4,1) )
				return (err | ERR_INVALID_BITS);
		    flush_bits(4);
	
		    get_bits1(&data);
		    streamInfo[stream_num].DTS_hibit = data;
		    get_bits2(&data);
		    streamInfo[stream_num].DTS = data << 30;
		    check_marker;
		    get_bits15(&data);
		    streamInfo[stream_num].DTS |= data << 15;
		    check_marker;
		    get_bits15(&data);
		    streamInfo[stream_num].DTS |= data;
		    check_marker;
		    packet->DTS_Flag=TRUE;
		    byte_count +=10;

		}else{
		    if( !next_bits(8,0x0f))
				return (err | ERR_INVALID_BITS);
		    flush_bits(8);
		    byte_count++;
		}
 	}

	/* create a buffer to contain the packet data and copy it in */
    packet->buffer_size = packet->packet_length - byte_count;

    packet->buffer = (char *) malloc(packet->buffer_size);
    if(packet->buffer == NULL){
        return (err | ERR_MALLOC);
    }

    bptr = packet->buffer;

    for( i=0; i < (packet->buffer_size); i++){
		get_bits8(&data);
		*bptr++=(char) data;
    }

    return NO_ERROR;
}

