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

#include <PSG.H>

volatile char *PSG_reg_select = 0xFF8800;
volatile char *PSG_reg_write = 0xFF8802;

/*-------------------------------------------- InitCylinder -----
|  Function InitCylinder
|
|  Purpose: Writes the given byte value (0-255) to the given PSG register (0-15). This is a helper routine to be
|   used by the other functions in this module.
|
|  Parameters: reg PSG register, val byte value for PSG register
|
|  Returns:
*-------------------------------------------------------------------*/

void WritePsg(int reg, uint8_t val)
{
    *PSG_reg_select = reg;
    *PSG_reg_write = val;
}

/*-------------------------------------------- ReadPsg -----
|  Function ReadPsg
|
|  Purpose: useful for testing purposes.
|
|  Parameters: reg PSG register
|
|  Returns: Value of register
*-------------------------------------------------------------------*/

uint8_t ReadPsg(int reg)
{
    *PSG_reg_select = reg;
    return *PSG_reg_select;
}

/*-------------------------------------------- SetTone -----
|  Function SetTone
|
|  Purpose: Loads the tone registers (coarse and fine) for the given channel (0=A, 1=B, 2=C) with the given
|   12-bit tuning.
|
|  Parameters: channel, tuning
|
|  Returns:
*-------------------------------------------------------------------*/

void SetTone(int channel, int tuning)
{
    uint8_t rough_tone = ROUGH_MASK_12BIT(tuning);
    uint8_t fine_tone = FINE_MASK_12BIT(tuning);

    switch (channel)
    {
    case CHANNEL_A:
        WritePsg(R0, fine_tone);
        WritePsg(R1, rough_tone);
        break;
    case CHANNEL_B:
        WritePsg(R2, fine_tone);
        WritePsg(R3, rough_tone);
        break;
    case CHANNEL_C:
        WritePsg(R4, fine_tone);
        WritePsg(R5, rough_tone);
        break;
    default:
        break;
    }
}

/*-------------------------------------------- SetVolume -----
|  Function SetVolume
|  Bit 4 (mode): When M = 0 level is determined by b3, b2, b1, b0,
|                When M = 1 level is determined by the 5 bit outpuit of e4, e3, e2, e1, and e0 of the envelope generator of the SSG
|
|  Purpose: Loads the volume register for the given channel.
|
|  Parameters: channel, volume
|
|  Returns:
*-------------------------------------------------------------------*/

void SetVolume(int channel, int volume)
{
    switch (channel)
    {
    case CHANNEL_A:
        WritePsg(R8, volume);
        break;
    case CHANNEL_B:
        WritePsg(R9, volume);
        break;
    case CHANNEL_C:
        WritePsg(RA, volume);
        break;
    default:
        break;
    }
}

/*-------------------------------------------- EnableChannel -----
|  Function EnableChannel
|
|  Purpose: Turns the given channel’s tone/noise signals on/off (0=off, 1=on).
|
|  Parameters: channel, tone_on, noise_on
|
|  Returns:
*-------------------------------------------------------------------*/

void EnableChannel(int channel, int tone_on, int noise_on)
{
    uint8_t psg_value = ReadPsg(R7);
    if (!tone_on && !noise_on)
    {
        WritePsg(R7, IO_OFF);
        return;
    }

    switch (channel)
    {
    case CHANNEL_A:
        if (tone_on && noise_on)
            WritePsg(R7, IO_A_NOISEON_TONEON & psg_value);
        else if (noise_on)
            WritePsg(R7, IO_A_NOISEON_TONEOFF & psg_value);
        else /* noise off */
            WritePsg(R7, IO_A_NOISEOFF_TONEON & psg_value);
        break;
    case CHANNEL_B:
        if (noise_on && noise_on)
            WritePsg(R7, IO_B_NOISEON_TONEON & psg_value);
        else if (noise_on)
            WritePsg(R7, IO_B_NOISEON_TONEOFF & psg_value);
        else /* noise off */
            WritePsg(R7, IO_B_NOISEOFF_TONEON & psg_value);
        break;
    case CHANNEL_C:
        if (tone_on && noise_on)
            WritePsg(R7, IO_C_NOISEON_TONEON & psg_value);
        else if (noise_on)
            WritePsg(R7, IO_C_NOISEON_TONEOFF & psg_value);
        else /* noise off */
            WritePsg(R7, IO_C_NOISEOFF_TONEON & psg_value);
        break;
    default:
        break;
    }
}

/*-------------------------------------------- StopSound -----
|  Function StopSound
|
|  Purpose: Silences all PSG sound production.
|
|  Parameters: 
|
|  Returns:
*-------------------------------------------------------------------*/

void StopSound(void)
{
    int count;
    for (count = 0x1; count <= 0xd; count++)
        WritePsg(count, 0);
}

/*-------------------------------------------- SetNoise -----
|  Function SetNoise
|
|  Purpose: Loads the noise register with the given tuning.
|
|  Parameters: tuning
|
|  Returns:
*-------------------------------------------------------------------*/

void SetNoise(int tuning)
{
    WritePsg(R6, tuning);
}

/*-------------------------------------------- SetEnvelope -----
|  Function SetEnvelope
|
|  Purpose: Loads the PSG envelope control registers with the given envelope shape and 16-bit sustain.
|
|  Parameters: shape, sustain
|
|  Returns:
*-------------------------------------------------------------------*/

void SetEnvelope(int shape, unsigned int sustain)
{
    uint8_t fine = FINE_MASK_16BIT(sustain);
    uint8_t rough = ROUGH_MASK_16BIT(sustain);

    WritePsg(RB, fine);
    WritePsg(RC, rough);
    WritePsg(RD, shape);
}
