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

#include <EFFECTS.H>
#include <PSG.H>

/*-------------------------------------------- EffectGunShoot -----
|  Function EffectGunShoot
|
|  Purpose:
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void EffectGunShoot(void)
{
	SetNoise(0x1F);
	EnableChannel(CHANNEL_B, 0, 1);
	SetVolume(CHANNEL_B, 0x10);
	SetEnvelope(ENV_CONT_OFF_ATT_OFF, (int)MAKE_TONE_16BIT(0x00, 0x38));
}

/*-------------------------------------------- EffectReload -----
|  Function EffectReload
|
|  Purpose:
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void EffectReload(void)
{
	SetNoise(0x12);
	EnableChannel(CHANNEL_B, 0, 1);
	SetVolume(CHANNEL_B, 0x10);
	SetEnvelope(ENV_CONT_OFF_ATT_OFF, (int)MAKE_TONE_16BIT(0x00, 0x05));
}
