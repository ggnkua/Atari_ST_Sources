/* $Id: hplay.h,v 1.5 1994/02/24 15:03:05 a904209 Exp a904209 $
*/
extern long samp_rate;
extern int audio_init PROTO((int argc, char *argv[]));
extern void audio_term PROTO((void));
extern void audio_play PROTO((int n, short *data));

