#include "extern.h"

#define SDMACTL 	0 					 /* DMA-Sound Controlregister */
#define SDMASTAT	1						 /* DMA-Sound Statusregister	*/
#define SSTART	 	3						 /* Frame-Startadresse 			 */
#define SEND			0xf  				 /* Frame-Endadresse				  */
#define SDMAMOD 	0x20L  			 /* DMA-Sound Moderegister		*/

/* ----------------
	 | Play via DMA |
	 ---------------- */
void dma_play(char *from, char *to)
{
char *dma_chip;

dma_chip = (char *)0xff8900L;

while(dma_chip[SDMASTAT]);

dma_chip[SSTART] = from[1];
dma_chip[SSTART + 2] = from[2];
dma_chip[SSTART + 4] = from[3];

dma_chip[SEND] = to[1];
dma_chip[SEND + 2] = to[2];
dma_chip[SEND + 4] = to[3];

*(int *)(&dma_chip[SDMAMOD]) = 0x80 + play_spd + ovsm_ply;
*(int *)(&dma_chip[SDMACTL]) = 0x1;
}
