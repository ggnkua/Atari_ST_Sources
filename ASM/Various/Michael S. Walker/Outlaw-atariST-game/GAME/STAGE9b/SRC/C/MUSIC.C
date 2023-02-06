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

#include <MUSIC.H>
#include <PSG.H>

uint8_t g_song[] = {
	0xd6,
	0xaa,
	0x8f,
	0x6b,
	0x55,
	0x47,
	0x35,
	0x2a,
	0x24,
	0x1b,
	0x15,
	0x12,
	0x00,
};

static int g_current_note = 0;

/*-------------------------------------------- StartMusic -----
|  Function StartMusic
|
|  Purpose: Begins the playing of the song by loading the data for the first note into the PSG.
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void StartMusic(void)
{
	EnableChannel(CHANNEL_A, 1, 0);
	SetVolume(CHANNEL_A, 0x0F);
	g_song[g_current_note++];
}

/*-------------------------------------------- UpdateMusic -----
|  Function UpdateMusic
|
|  Purpose:  Advances to the next note of the song if necessary, as determined by the amount of time elapsed
| 		since the previous call. The time elapsed is determined by the caller. It is intended that this value
| 		is equal to the current value of the vertical blank clock, minus its value when the function was last
| 		called.
|
|  Parameters: time_elapsed amount of time elapsed since the previous call
|
|  Returns:
*-------------------------------------------------------------------*/

void UpdateMusic(uint32_t time_elapsed)
{
	if (time_elapsed >= 10)
		SetVolume(CHANNEL_A, 0x00);

	if (time_elapsed >= 15)
	{
		SetTone(CHANNEL_A, g_song[g_current_note++]);
		SetVolume(CHANNEL_A, 0x0F);
		if (g_song[g_current_note] == 0x00)
			g_current_note = 0;
	}
}
