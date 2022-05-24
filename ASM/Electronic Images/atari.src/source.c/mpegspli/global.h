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

extern int verbose_flag;
extern int quiet_flag;
extern jmp_buf env;
extern int system_header_found;
extern int pack_cnt;
extern int packet_cnt;
extern int system_header_cnt;

extern FILE *BitStream;
extern int EOF_flag;
extern unsigned int curBits;
extern int bitOffset;
extern int bufLength;
extern int max_buf_length;
extern unsigned int *bitBuffer;
extern unsigned int *buf_start;

extern StreamInfo  streamInfo[MAX_NUM_STREAMS];

extern unsigned int nBitMask[];
extern unsigned int bitMask[];
extern unsigned int rBitMask[];
extern unsigned int bitTest[];

