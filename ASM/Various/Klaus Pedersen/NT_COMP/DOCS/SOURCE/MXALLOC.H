/*	MXALLOC is written by Klaus Pedersen (micro@imada.dk), and
 *	distributed, together with "NT_COMP" - the NoiseTracker Compiler
 *	for Atari [MEGA] ST, STe and TT computers.
 *
 *
 *Name           ¯extended memory allocation®
 *----
 *Gemdosnumber   0x44
 *-----------
 *Definition     void *Mxalloc(long amount, int type);
 *----------
 *Talk           The binding first try to allocate the memory with 
 *----           GEMDOS function Mxalloc,  if this fails ("unknown 
 *               Gemdos function"),  it then allocates  the memory 
 *               with the standard function Malloc.
 *               If amount == -1L the function returns the size of
 *               the largest block in the choosen type of ram... 
 *               (or ST ram if Mxalloc is unknown to GEMDOS). 
 *               The parameter type can be one of the following :
 *                  0 - ST ram needed (DMA sound/ACSI/VIDEO)
 *                  1 - TT ram needed...
 *                  2 - ST ram if possible else TT...
 *                  3 - TT ram if possible else ST (SCSI/LAN)
 *
 *Returns        The function returns the startaddress of the block.
 *-------        Mxalloc returns 0, if there was no memory of the 
 *               choosen type.
 */

enum {MX_STON, MX_TTON, MX_STPR, MX_TTPR};
 
void *Mxalloc(long amount, int type);
