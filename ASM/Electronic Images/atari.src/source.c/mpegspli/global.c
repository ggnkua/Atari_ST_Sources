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

jmp_buf env;
int quiet_flag;
int verbose_flag;
int system_header_found;
int pack_cnt;
int packet_cnt;
int system_header_cnt;

FILE *BitStream;
int EOF_flag;
unsigned int curBits;
int bitOffset;
int bufLength;
int max_buf_length;
unsigned int *bitBuffer;
unsigned int *buf_start;

StreamInfo      streamInfo[MAX_NUM_STREAMS];

unsigned int nBitMask[] = { 0x00000000, 0x80000000, 0xc0000000, 0xe0000000, 
			    0xf0000000, 0xf8000000, 0xfc000000, 0xfe000000, 
			    0xff000000, 0xff800000, 0xffc00000, 0xffe00000, 
			    0xfff00000, 0xfff80000, 0xfffc0000, 0xfffe0000, 
			    0xffff0000, 0xffff8000, 0xffffc000, 0xffffe000, 
			    0xfffff000, 0xfffff800, 0xfffffc00, 0xfffffe00, 
			    0xffffff00, 0xffffff80, 0xffffffc0, 0xffffffe0, 
			    0xfffffff0, 0xfffffff8, 0xfffffffc, 0xfffffffe};

unsigned int bitMask[] = {  0xffffffff, 0x7fffffff, 0x3fffffff, 0x1fffffff, 
			    0x0fffffff, 0x07ffffff, 0x03ffffff, 0x01ffffff,
			    0x00ffffff, 0x007fffff, 0x003fffff, 0x001fffff,
			    0x000fffff, 0x0007ffff, 0x0003ffff, 0x0001ffff,
			    0x0000ffff, 0x00007fff, 0x00003fff, 0x00001fff,
			    0x00000fff, 0x000007ff, 0x000003ff, 0x000001ff,
			    0x000000ff, 0x0000007f, 0x0000003f, 0x0000001f,
			    0x0000000f, 0x00000007, 0x00000003, 0x00000001};

unsigned int rBitMask[] = { 0xffffffff, 0xfffffffe, 0xfffffffc, 0xfffffff8, 
			    0xfffffff0, 0xffffffe0, 0xffffffc0, 0xffffff80, 
			    0xffffff00, 0xfffffe00, 0xfffffc00, 0xfffff800, 
			    0xfffff000, 0xffffe000, 0xffffc000, 0xffff8000, 
			    0xffff0000, 0xfffe0000, 0xfffc0000, 0xfff80000, 
			    0xfff00000, 0xffe00000, 0xffc00000, 0xff800000, 
			    0xff000000, 0xfe000000, 0xfc000000, 0xf8000000, 
			    0xf0000000, 0xe0000000, 0xc0000000, 0x80000000};

unsigned int bitTest[] = {  0x80000000, 0x40000000, 0x20000000, 0x10000000, 
			    0x08000000, 0x04000000, 0x02000000, 0x01000000,
			    0x00800000, 0x00400000, 0x00200000, 0x00100000,
			    0x00080000, 0x00040000, 0x00020000, 0x00010000,
			    0x00008000, 0x00004000, 0x00002000, 0x00001000,
			    0x00000800, 0x00000400, 0x00000200, 0x00000100,
			    0x00000080, 0x00000040, 0x00000020, 0x00000010,
			    0x00000008, 0x00000004, 0x00000002, 0x00000001};

