#include <TYPES.H>
#include <SCREEN.H>
#include <UTIL.H>
#include <RASTER.H> /* for ClearScreen() */

#include <osbind.h> /* for Vsync(); */

uint8_t g_framebuffers[NUM_FRAME_BUFFERS][SCREEN_SIZE + FRAMEBUFFER_PADDING_LEN];

void ScrInit(Screen *screen)
{
    int i;

    screen->current_fb_index = 0;
    screen->orig_framebuffer = ScrGetScreenBuffer(); /* save orig screen */

    for (i = 0; i != NUM_FRAME_BUFFERS; i++)
    {
        screen->framebuffs[i] = (uint8_t *)addr_roundup(g_framebuffers[i], 8);
        ClearScreen(screen->framebuffs[i]);
    }

    screen->next_buffer = screen->framebuffs[screen->current_fb_index];
    ScrFlipBuffers(screen);
}

void ScrFlipBuffers(Screen *screen)
{
    ScrSetScreenBuffer(screen->next_buffer);
    screen->current_fb_index ^= (screen->current_fb_index + 1) % NUM_FRAME_BUFFERS; /* ... >:D */
    screen->next_buffer = screen->framebuffs[screen->current_fb_index];
}

uint8_t *ScrGetScreenBuffer(void)
{
    return GetBuffer();
}

void ScrSetScreenBuffer(uint8_t *scrbuf)
{
    Vsync();
    SetBuffer(scrbuf);
}

void ScrCleanup(Screen *screen)
{
    ScrSetScreenBuffer(screen->orig_framebuffer);
}
