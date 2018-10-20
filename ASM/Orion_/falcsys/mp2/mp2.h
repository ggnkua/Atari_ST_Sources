//
// C Wrapper for MP2 Audio Player - by Orion_ [2013]
//
// DSP MPEG Audio Layer 2 player by Tomas Berndtsson, NoBrain/NoCrew
//
// Add these files to your compilation command: mp2.c mp2.s
//

#ifndef	_MP2_WRAPPER_H_
#define	_MP2_WRAPPER_H_

#define	MP2_INT_SPEED	32000	// 32khz max
#define	MP2_EXT_SPEED	0
#define	MP2_LOOP		0		// 0 = Single play, 1 = Loop

char	*MP2_Load(char *filename);	// Return NULL if everything is ok, else it will return a string describing the error.
void	MP2_Start(void);
void	MP2_Stop(void);

#endif
