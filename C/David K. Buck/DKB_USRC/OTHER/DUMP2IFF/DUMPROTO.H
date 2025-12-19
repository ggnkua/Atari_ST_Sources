/*****************************************************************************
*
*                                   dumproto.h
*
*   from DKBTrace (c) 1990  David Buck
*
*  This file contains prototypes for DumpToIFF
*
* This software is freely distributable. The source and/or object code may be
* copied or uploaded to communications services so long as this notice remains
* at the top of each file.  If any changes are made to the program, you must
* clearly indicate in the documentation and in the programs startup message
* who it was who made the changes. The documentation should also describe what
* those changes were. This software may not be included in whole or in
* part into any commercial package without the express written consent of the
* author.  It may, however, be included in other public domain or freely
* distributed software so long as the proper credit for the software is given.
*
* This software is provided as is without any guarantees or warranty. Although
* the author has attempted to find and correct any bugs in the software, he
* is not responsible for any damage caused by the use of the software.  The
* author is under no obligation to provide service, corrections, or upgrades
* to this package.
*
* Despite all the legal stuff above, if you do find bugs, I would like to hear
* about them.  Also, if you have any comments or questions, you may contact me
* at the following address:
*
*     David Buck
*     22C Sonnet Cres.
*     Nepean Ontario
*     Canada, K2H 8W7
*
*  I can also be reached on the following bulleton boards:
*
*     OMX              (613) 731-3419
*     Mystic           (613) 596-4249  or  (613) 596-4772
*
*  Fidonet:   1:163/109.9
*  Internet:  dbuck@ccs.carleton.ca
*  The "You Can Call Me RAY" BBS    (708) 358-5611
*
*
*****************************************************************************/

/* Prototypes from DumpToIFF.c */

void display_close (void);
void display_plot (LONG x, LONG y, LONG new_red, LONG new_green, LONG new_blue);
void process (LONG x, LONG y, LONG new_red, LONG new_green, LONG new_blue);
void ConvertToIFF(char *file_name);
int read_raw_byte(FILE *f);
int read_raw_word(FILE *f);
void read_raw_image (IMAGE *Image, char *filename);
void dither (IMAGE *Image);

/* Prototypes from palette.c */

void reset_colours (void);
int closeness(int x, int y);
void start_recording_colours (void);
void record_colours (int new_red, int new_green, int new_blue);
void choose_palette(void);
int best_colour (int new_red, int new_blue, int new_green);

/* Prototypes from showpriow.h */

struct prioq_struct *pq_new (int index_size, int value_size);
void pq_add (struct prioq *q, unsigned int index, unsigned int value);
int pq_find_value (struct prioq *q, unsigned int value);
void pq_balance(struct prioq *q, unsigned int entry_pos1);
int pq_get_highest_index(struct prioq *q);
int pq_get_highest_value(struct prioq *q);
void pq_delete_highest (struct prioq *q);
void pq_free (struct prioq *q);
