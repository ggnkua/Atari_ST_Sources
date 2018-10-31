#ifndef _SCORES_H_
#define _SCORES_H_

typedef struct score_entry
{
	char name[14];
	long  score;
} SCORE_ENTRY;

/* our high score list */
extern struct score_entry scores[10];

extern long read_highscore(void);
extern long write_score(void);
extern void get_high_name(int x);
extern void high_score(void);

#endif