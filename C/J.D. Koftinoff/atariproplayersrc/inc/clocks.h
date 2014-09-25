#ifndef __CLOCKS_H
#define __CLOCKS_H



/* clocks.c */

void 	set_timer( long freq);
extern	void	unset_timer(void);
void	clock_midi_out( short d );

#undef midi_out
#define midi_out(a) clock_midi_out(a)

#endif

