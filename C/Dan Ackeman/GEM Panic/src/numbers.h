#ifndef _NUMBERS_H_
#define _NUMBERS_H_

extern MFDB digitsource;

extern void convert_numbers(void);
extern void clear(int x,int y,int w,int h);
extern void prinl(register long num,int x,int y,int fill);
extern void show_score(void);
extern void show_time(void);
extern void show_ships(void);
extern void show_wave(void);
extern void show_debug(int test);

#endif