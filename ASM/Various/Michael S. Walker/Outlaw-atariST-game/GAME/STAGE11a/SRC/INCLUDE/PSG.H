/*
 * Michael S. Walker <mwalk762@mtroyal.ca>
 *	    _    _
 *       | |  | |	OUTLAW. 
 *      -| |  | |- 
 *  _    | |- | |
 *-| |   | |  | |- 	
 * |.|  -| ||/  |
 * | |-  |  ___/ 
 *-|.|   | | |
 * |  \_|| |
 *  \____  |
 *   |   | |- 
 *       | |
 *      -| |
 *       |_| Copyleft !(c) 2020 All Rights Unreserved in all Federations, including Alpha Centauris.
 */

#ifndef PSG_H
#define PSG_H
#include <TYPES.H> /* for type t */

#define CHANNEL_A 0
#define CHANNEL_B 1
#define CHANNEL_C 2

#define MAKE_TONE_12BIT(f, r) (((f) << 4) | (r))
#define ROUGH_MASK_12BIT(a) ((a)&0x000F)
#define FINE_MASK_12BIT(a) (((a)&0x0FF0) >> 4)

#define MAKE_TONE_16BIT(f, r) (((f) << 8) | (r))
#define ROUGH_MASK_16BIT(a) ((a)&0x00FF)
#define FINE_MASK_16BIT(a) (((a)&0xFF00) >> 8)

#define R0 0x0
#define R1 0x1
#define R2 0x2
#define R3 0x3
#define R4 0x4
#define R5 0x5
#define R6 0x6
#define R7 0x7
#define R8 0x8
#define R9 0x9
#define RA 0xA
#define RB 0xB
#define RC 0xC
#define RD 0xD
#define RE 0xE
#define RF 0xF

/* IOB IOC | C B A | C B A */
#define IO_A_NOISEON_TONEON 0x36  /*   0   0   1 1 0   1 1 0 */
#define IO_A_NOISEON_TONEOFF 0x37 /*   0   0   1 1 0   1 1 1 */
#define IO_A_NOISEOFF_TONEON 0x3E /*   0   0   1 1 1   1 1 0 */

#define IO_B_NOISEON_TONEON 0x2D  /*   0   0   1 0 1   1 0 1 */
#define IO_B_NOISEON_TONEOFF 0x2F /*   0   0   1 0 1   1 1 1 */
#define IO_B_NOISEOFF_TONEON 0x3D /*   0   0   1 1 1   1 0 1 */

#define IO_C_NOISEON_TONEON 0x1B  /*   0   0   0 1 1   0 1 1 */
#define IO_C_NOISEON_TONEOFF 0x1F /*   0   0   0 1 1   1 1 1 */
#define IO_C_NOISEOFF_TONEON 0x3B /*   0   0   1 1 1   0 1 1 */

#define IO_OFF 0x3F /*   0   0   1 1 1   1 1 1 */

/*
 *  Envelope control register
 *  shapes, and sustain register bit values
 *  
 *           B3  B2  B1   B0
 *          CONT ATT ALT HOLD
 * 
 *            0   0   x   x  \_______________________      0x00
 *            0   1   x   x  / |_____________________      0x04
 *            1   0   0   0  \ |\ |\ |\ |\ |\ |\ |\        0x08
 *            1   0   0   1  \_______________________      0x09
 *            1   0   1   0  \  /\  /\  /\  /\  /\  /      0x0A
 *            1   0   1   1  \ |--------------------       0x0B
 *            1   1   0   0  / | /| /| /| /| /| /| /       0x0C
 *            1   1   0   1  / ______________________      0x0D
 *            1   1   1   0  / \  /\  /\  /\  /\  /\       0x0E
 *            1   1   1   1  / |_____________________      0x0F
 */

#define ENV_CONT_OFF_ATT_OFF 0x00
#define ENV_CONT_OFF_ATT_ON 0x04
#define ENV_CONT_ON_ATT_OFF_ALT_OFF_HOLD_OFF 0x08
#define ENV_CONT_ON_ATT_OFF_ALT_OFF_HOLD_ON 0x09
#define ENV_CONT_ON_ATT_OFF_ALT_ON_HOLD_OFF 0x0A
#define ENV_CONT_ON_ATT_OFF_ALT_ON_HOLD_ON 0x0B
#define ENV_CONT_ON_ATT_ON_ALT_OFF_HOLD_OFF 0x0C
#define ENV_CONT_ON_ATT_ON_ALT_OFF_HOLD_ON 0x0D
#define ENV_CONT_ON_ATT_ON_ALT_ON_HOLD_OFF 0x0E
#define ENV_CONT_ON_ATT_ON_ALT_ON_HOLD_ON 0x0F

void SetEnvelope(int shape, unsigned int sustain);
void SetNoise(int tuning);
void StopSound(void);
void EnableChannel(int channel, int tone_on, int noise_on);
void SetVolume(int channel, int volume);
void SetTone(int channel, int tuning);
uint8_t ReadPsg(int reg);
void WritePsg(int reg, uint8_t val);

#endif /* PSG_H */
