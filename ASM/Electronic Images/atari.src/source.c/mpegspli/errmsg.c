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

#include "main.h"

void errmsg( unsigned int err )
{
	printf("\n");
	fprintf(stderr,"\nBlast it an ERROR %0X has occured!\n",err);

	fprintf(stderr,"I was ");
	switch( err & ERR_MASK2){
	case NO_ERROR:				fprintf(stderr,"doing something");break;
	case ERR_PARSE_PACK_HDR:	fprintf(stderr,"parsing a Pack Header");break;
	case ERR_PARSE_SYSTEM_HDR:	fprintf(stderr,"parsing a System Header");break;
	case ERR_PARSE_PACKET:		fprintf(stderr,"parsing a Packet");break;
	case ERR_PROCESS_PACKET:	fprintf(stderr,"parsing a Processing a Packet");break;
	case ERR_DIFF_SYSTEM_HDR:	fprintf(stderr,"comparing two System Headers");break;
	default:					fprintf(stderr,"a bit confused");break;
	}

	fprintf(stderr," while I was ");
	switch( err & ERR_MASK1){
	case NO_ERROR:				fprintf(stderr,"doing something");break;
	case ERR_PARSE_PACK:		fprintf(stderr,"parsing a Pack");break;
	default:					fprintf(stderr,"confused");break;
	} 

	fprintf(stderr," and \nI ");
	switch( err & ERR_MASK3){
	case NO_ERROR:				fprintf(stderr,"had an error"); break;
	case ERR_READ_BITSTREAM:	fprintf(stderr,"had trouble reading the BitStream");break;
	case ERR_UNEXPECTED_EOF:	fprintf(stderr,"had an Unexpected EOF pop up");break;
	case ERR_NO_BIT_STREAM:	    fprintf(stderr,"discovered that the BitStream was not open");break;
	case ERR_INVALID_MARKER:	fprintf(stderr,"came across an Invaild Marker");break;
	case ERR_MISSING_SYSTEM_HDR: fprintf(stderr,"couldn't find a starting System Header");break;
	case ERR_OPEN_ESTREAM:	    fprintf(stderr,"trouble opening an Elemental Stream");break;
	case ERR_NO_PACKET_BUFFER:	fprintf(stderr,"discovered that there was no packet buffer");break;
	case ERR_WRITE_ESTREAM:	    fprintf(stderr,"trouble writing to an Elemental System");break;
	case ERR_MISSING_END_CODE:	fprintf(stderr,"found the BitStream was missing an End Code");break;
	case ERR_NOT_SYSTEM_LAYER:	fprintf(stderr,"was not a System Layer Stream");break;
	case ERR_OPEN_BSTREAM:	    fprintf(stderr,"the BitStream Could not be opened");break;
	case ERR_MALLOC:		    fprintf(stderr,"had trouble Allocating some memory");break;
	case ERR_INVALID_BITS:	    fprintf(stderr,"had a invalid bit sequence");break;
	case ERR_INVALID_STREAM_NUM:fprintf(stderr,"had a invalid stream number turn up");break;
	default:					fprintf(stderr,"had a Programmer Error");break;
	}

	fprintf(stderr,".\n");
}

