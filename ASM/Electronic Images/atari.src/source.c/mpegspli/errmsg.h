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

/* 1st Level Errors */
#define ERR_MASK1				0xf000
#define ERR_PARSE_PACK			0x1000

/* 2nd Level Errors */
#define ERR_MASK2				0x0f00
#define ERR_PARSE_PACK_HDR		0x0100
#define ERR_PARSE_SYSTEM_HDR	0x0200
#define ERR_PARSE_PACKET		0x0300
#define ERR_PROCESS_PACKET		0x0400
#define ERR_DIFF_SYSTEM_HDR		0x0500

/* 3rd Level Errors */
#define ERR_MASK3				0x00ff
#define NO_ERROR				0x0000
#define ERR_READ_BITSTREAM      0x0002
#define ERR_UNEXPECTED_EOF	 	0x0003
#define ERR_NO_BIT_STREAM 		0x0004
#define ERR_INVALID_MARKER		0x0005
#define ERR_MISSING_SYSTEM_HDR	0x0007
#define ERR_OPEN_ESTREAM		0x0008
#define ERR_NO_PACKET_BUFFER    0x0009
#define ERR_WRITE_ESTREAM		0x000a
#define ERR_MISSING_END_CODE	0x000b
#define ERR_NOT_SYSTEM_LAYER	0x000c
#define ERR_OPEN_BSTREAM		0x000d
#define ERR_MALLOC				0x000e
#define ERR_INVALID_BITS		0x000f
#define ERR_INVALID_STREAM_NUM	0x0010

#define OK  0
#define BUF_UNDERFLOW 1
#define FALSE 0
#define TRUE  1
