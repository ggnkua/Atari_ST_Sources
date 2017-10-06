
#ifndef _BO_SOUND_H
#define _BO_SOUND_H


#define S_APPEAR          0
#define S_MAGICBELL       1
#define S_BRICKSOUND      2
#define S_PERMBRICKSOUND  3
#define S_DEATH           4
#define S_LOSTBALL        5
#define S_PSOUND          6
#define S_BONUS           7
#define S_SIDE            8
#define S_TOP             9
#define S_BOTTOM         10

int sound_init();
int sound_play(int num);
int sound_exit();


#endif /* _BO_SOUND_H */

