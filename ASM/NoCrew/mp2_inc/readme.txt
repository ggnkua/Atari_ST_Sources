DSP MPEG Audio Layer 2 player, light version.

This is used to start playing an mp2 song in the background,
using only the DSP and the DMA. This means everything else
can be used freely, and without disturbance from the playing
music.

The included file MP2PLAY.S shows how to use the player.
The song has to be in the ST-RAM, and you have to fill in
the address of the song and its length and frequency in the 
buffers before starting the player.

Optional settings are:
 Set the external clock frequency, if such is available and 
 should be used. The player does not test if there is an 
 external clock available, but only uses the values given. 

 Make the song repeat.
 
I hope this will be useful. Thanks to Anders Eriksson for
the idea of making this.


This player is free to use by anyone. Use it well.


Tomas Berndtsson, <tomas@nocrew.org>
NoBrain/NoCrew
