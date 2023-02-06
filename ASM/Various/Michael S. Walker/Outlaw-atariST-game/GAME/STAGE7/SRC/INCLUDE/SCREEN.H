#ifndef SCREEN_H
#define SCREEN_H

#include <TYPES.H> /* for struct Screen */

#define SCREEN_SIZE 32000 /*  (640 * 400 / 8) Note:   Buffers are the same size for all resolutions  */
#define NUM_FRAME_BUFFERS 2
#define FRAMEBUFFER_PADDING_LEN 0x100

typedef struct _Screen
{
    int current_fb_index;

    uint8_t *next_buffer;
    uint8_t *framebuffs[NUM_FRAME_BUFFERS];
    uint8_t *orig_framebuffer;
} Screen;

void ScrCleanup(Screen *screen);
void ScrSetScreenBuffer(uint8_t *scrbuf);
uint8_t *ScrGetScreenBuffer(void);
void ScrFlipBuffers(Screen *screen);
void ScrInit(Screen *screen);

extern void *GetBuffer(void);
extern void SetBuffer(void *scrbuf);

#endif /* SCREEN_H */
