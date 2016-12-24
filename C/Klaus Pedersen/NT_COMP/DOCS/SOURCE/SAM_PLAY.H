/*	SAM_PLAY is written by Klaus Pedersen (micro@imada.dk), and
 *	distributed, together with "NT_COMP" - the NoiseTracker Compiler
 *	for Atari [MEGA] ST, STe and TT computers.
 *
 * The pointer 'samples' points to a list of segmentes, where
 *  each segment is a record/struct of :
 *       { signed char *samplestart;
 *         long        length_of_sample_segment;
 *       }
 *  'samplestart' == -1, ends the segment-list. When the player
 *  reaches the end, it will start at the segment number 'repeat',
 *  if 'repeat' != -1...
 *
 * Speed is one of the following :
 *    0 : 6.25 KHz,
 *    1 : 12.5 KHz,
 *    2 : 25.0 KHz,
 *    3 : 50.0 KHz (this is not working ST output)
 * On the STe these values needs to be ored with 0x80 (128),
 * to get mono output. 
 *
 * The routines to play on the ROM port and the printer port
 * have NOT been tested in any way (they don't bomb the computer
 * but that is about the amount of testing I have done).
 * Furthermore I have NO idea how they are implemented, I have
 * written the code to drive devices that is likely to exist!
 * I assume that that both use offset binary, and that the 
 * printerport don't need a strobe to latch the data. And that
 * the ROM port is mapped at 0xFFFB0000 and uses address lines
 * A1-A8 as datalines.
 * - I any of this is wrong -or right, PLEASE let me know!!
 */
  
extern void ST_sequence(long *samples, int speed, int repeat);

extern void ROM_sequence(long *samples, int speed, int repeat);

extern void PRN_sequence(long *samples, int speed, int repeat);

extern void STe_sequence(long *samples, int repeat, int speed);

extern void STe_end(void);
