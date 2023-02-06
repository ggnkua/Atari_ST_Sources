/*
 * Michael S. Walker <mwalk762@mtroyal.ca>
 *         _    _
 *        | |  | |	OUTLAW. 
 *       -| |  | |- 
 *   _    | |- | |
 * -| |   | |  | |- 	
 *  |.|  -| ||/  |
 *  | |-  |  ___/ 
 * -|.|   | | |
 *  |  \_|| |
 *   \____  |
 *    |   | |- 
 *        | |
 *       -| |
 *        |_| Copyleft !(c) 2020 All Rights Unreserved in all Federations, including Alpha Centauris.
 */

#include <TYPES.H>
#include <SCREEN.H>
#include <UTIL.H>
#include <RASTER.H>

uint8_t g_framebuffers[NUM_FRAME_BUFFERS][SCREEN_SIZE + FRAMEBUFFER_PADDING_LEN];

/*-------------------------------------------- ScrInit -----
|  Function ScrInit
|
|  Purpose:
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void ScrInit(Screen *screen)
{
    int i;

    screen->current_fb_index = 0;
    screen->orig_framebuffer = GetVideoBase();

    for (i = 0; i != NUM_FRAME_BUFFERS; i++)
    {
        screen->framebuffs[i] = (uint8_t *)addr_roundup(g_framebuffers[i], 8);
        ClearScreen(screen->framebuffs[i]);
    }

    screen->next_buffer = screen->framebuffs[screen->current_fb_index];
    ScrFlipBuffers(screen);
}

/*-------------------------------------------- ScrFlipBuffers -----
|  Function ScrFlipBuffers
|
|  Purpose:
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void ScrFlipBuffers(Screen *screen)
{
    SetVideoBase(screen->next_buffer);
    screen->current_fb_index = (screen->current_fb_index + 1) % NUM_FRAME_BUFFERS;
    screen->next_buffer = screen->framebuffs[screen->current_fb_index];
}

/*-------------------------------------------- ScrCleanup -----
|  Function ScrCleanup
|
|  Purpose:
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void ScrCleanup(Screen *screen)
{
    SetVideoBase(screen->orig_framebuffer);
}
