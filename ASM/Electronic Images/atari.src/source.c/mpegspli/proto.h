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

/* from parsers.c */
int parse_pack_header(Pack_Header *pack_header);
int parse_system_header( System_Header *system_header);
int parse_packet(Packet *packet);

/* from split.c */
void split_stream(char *szFileName);
int parse_pack();
int process_packet(Packet *packet);
void cleanup_packet(Packet *packet);
int compare_system_headers(System_Header *system_header,System_Header *system_header2);

/* from dialog.c */
void dialog_msg(char *msg);
void dialog_end();
void dialog_progress();
void dialog_pack_header(Pack_Header *pack_header, int pack_num);
void dialog_system_header(System_Header *system_header);

/* from util.c */
void correct_underflow();
int next_bits(int num, unsigned int mask);
int next_start_code();

/* from fileio.c */
int get_more_data(unsigned int *buf_start, int max_length, int *length_ptr, unsigned int **buf_ptr);

/* from errmsg.c */
void errmsg(unsigned int err);
