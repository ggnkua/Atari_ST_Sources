#include <EFFECTS.H>
#include <PSG.H>

void EffectGunShoot(void)
{
	SetNoise(0x1F);
	EnableChannel(CHANNEL_B, 0, 1);
	SetVolume(CHANNEL_B, 0x10);
	SetEnvelope(ENV_CONT_OFF_ATT_OFF, (int)MAKE_TONE_16BIT(0x00, 0x38));
}

void EffectReload(void)
{
	SetNoise(0x12);
	EnableChannel(CHANNEL_B, 0, 1);
	SetVolume(CHANNEL_B, 0x10);
	SetEnvelope(ENV_CONT_OFF_ATT_OFF, (int)MAKE_TONE_16BIT(0x00, 0x05));
}
