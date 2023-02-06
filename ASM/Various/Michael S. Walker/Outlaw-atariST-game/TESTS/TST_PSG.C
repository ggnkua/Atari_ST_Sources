#include <PSG.H>
#include <osbind.h> /* For super */
#include <stdio.h>
#include <MUSIC.H>

uint32_t GetTime(void);

void TestMusic(void);
void TestTone(void);
void TestNoise(void);
void TestVolume(void);
void TestEnvelope(void);
void TestStopStound(void);
void TestEnableChannel(void);

void TestEffectGunShoot(void);

int main(int argc, char *argv[])
{
	long old_ssp = Super(0);
	TestEffectReload();
	Super(old_ssp);

	return 0;
}

void TestMusic(void)
{
	uint32_t music_time_then, music_time_now, music_time_elapsed;
	long *timer = 0x462;

	StopSound();
	StartMusic();
	music_time_now = GetTime();
	music_time_then = music_time_now;

	while (1)
	{
		music_time_now = GetTime();
		music_time_elapsed = music_time_now - music_time_then;

		UpdateMusic(music_time_elapsed);

		if (music_time_elapsed >= 20)
			music_time_then = music_time_now;
	}
}

uint32_t GetTime(void)
{
	long time_now;
	long *timer = (long *)0x462; /* address of longword auto-inc’ed 70 x per s */

	time_now = *timer;

	return time_now;
}

void TestEffectReload(void)
{
	SetNoise(0x12);
	EnableChannel(CHANNEL_C, 0, 1);
	SetVolume(CHANNEL_C, 0x10);
	SetEnvelope(ENV_CONT_OFF_ATT_OFF, (int)MAKE_TONE_16BIT(0x00, 0x05));
}
void TestEffectGunShoot(void)
{
	SetNoise(0x1F);
	EnableChannel(CHANNEL_C, 0, 1);
	SetVolume(CHANNEL_C, 0x10);
	SetEnvelope(ENV_CONT_OFF_ATT_OFF, (int)MAKE_TONE_16BIT(0x00, 0x38));
}

void TestStopStound(void)
{
	int count;

	StopSound();

	for (count = 0x1; count <= 0xf; count++)
	{
		printf("0x%x: %x\n", count, ReadPsg(count));
	}
}

void TestTone(void)
{
	int fine_tone = 0x11;
	int rough_tone = 0x02;
	int tone = MAKE_TONE_12BIT(fine_tone, rough_tone);
	SetTone(CHANNEL_A, tone);

	fine_tone = 0x33;
	rough_tone = 0x04;
	tone = MAKE_TONE_12BIT(fine_tone, rough_tone);
	SetTone(CHANNEL_B, tone);

	fine_tone = 0x55;
	rough_tone = 0x06;
	tone = MAKE_TONE_12BIT(fine_tone, rough_tone);
	SetTone(CHANNEL_C, tone);

	printf("FINE TONE RO: 0x%x\n", ReadPsg(R0));
	printf("ROUGH TONE R1: 0x%x\n", ReadPsg(R1));

	printf("FINE TONE R2: 0x%x\n", ReadPsg(R2));
	printf("ROUGH TONE R3: 0x%x\n", ReadPsg(R3));

	printf("FINE TONE R4: 0x%x\n", ReadPsg(R4));
	printf("ROUGH TONE R5: 0x%x\n", ReadPsg(R5));
}

void TestVolume(void)
{
	SetVolume(CHANNEL_A, 0xF);
	printf("VOLMUE OF R8: 0x%x\n", ReadPsg(R8));

	SetVolume(CHANNEL_B, 0xE);
	printf("VOLMUE OF R8: 0x%x\n", ReadPsg(R9));

	SetVolume(CHANNEL_C, 0xD);
	printf("VOLMUE OF R8: 0x%x\n", ReadPsg(RA));
}

void TestEnableChannel(void)
{
	EnableChannel(-1, 0, 0);
	printf("0x3F OFF: Value of R7: %x\n", ReadPsg(R7));

	EnableChannel(CHANNEL_A, 1, 1);
	printf("0x36 IO_A_NOISEON_TONEON Value of R7: %x\n", ReadPsg(R7));
	EnableChannel(-1, 0, 0);

	EnableChannel(CHANNEL_A, 1, 0);
	printf("0x37 IO_A_NOISEON_TONEOFF Value of R7: %x\n", ReadPsg(R7));
	EnableChannel(-1, 0, 0);

	EnableChannel(CHANNEL_A, 0, 1);
	printf("0x3E IO_A_NOISEOFF_TONEON Value of R7: %x\n", ReadPsg(R7));
	EnableChannel(-1, 0, 0);

	EnableChannel(CHANNEL_B, 1, 1);
	printf("0x2D IO_B_NOISEON_TONEON Value of R7: %x\n", ReadPsg(R7));
	EnableChannel(-1, 0, 0);

	EnableChannel(CHANNEL_B, 1, 0);
	printf("0x2F IO_B_NOISEON_TONEOFF Value of R7: %x\n", ReadPsg(R7));
	EnableChannel(-1, 0, 0);

	EnableChannel(CHANNEL_B, 0, 1);
	printf("0x3D IO_B_NOISEOFF_TONEON Value of R7: %x\n", ReadPsg(R7));
	EnableChannel(-1, 0, 0);

	EnableChannel(CHANNEL_C, 1, 1);
	printf("0x1B IO_C_NOISEON_TONEON Value of R7: %x\n", ReadPsg(R7));
	EnableChannel(-1, 0, 0);

	EnableChannel(CHANNEL_C, 1, 0);
	printf("0x1F IO_C_NOISEON_TONEOFF Value of R7: %x\n", ReadPsg(R7));
	EnableChannel(-1, 0, 0);

	EnableChannel(CHANNEL_C, 0, 1);
	printf("0x3B IO_C_NOISEOFF_TONEON Value of R7: %x\n", ReadPsg(R7));
	EnableChannel(-1, 0, 0);
}

void TestNoise(void)
{
	SetNoise(0x1f);
	printf("Value of R6: %x\n", ReadPsg(R6));
}

void TestEnvelope(void)
{
	int finetone = 0xaa;
	int roughtone = 0xbb;
	int sustain = MAKE_TONE_16BIT(finetone, roughtone);
	printf("sustain: %x\n", sustain);

	SetEnvelope(ENV_CONT_OFF_ATT_OFF, sustain);
	printf("(0xaa)RB fine tone: %x (0xbb)RC rough tone: %x (0x00)RD shape: %x\n", ReadPsg(RB), ReadPsg(RC), ReadPsg(RD));

	SetEnvelope(ENV_CONT_OFF_ATT_ON, sustain);
	printf("(0xaa)RB fine tone: %x (0xbb)RC rough tone: %x (0x04)RD shape: %x\n", ReadPsg(RB), ReadPsg(RC), ReadPsg(RD));

	SetEnvelope(ENV_CONT_ON_ATT_OFF_ALT_OFF_HOLD_OFF, sustain);
	printf("(0xaa)RB fine tone: %x (0xbb)RC rough tone: %x (0x08)RD shape: %x\n", ReadPsg(RB), ReadPsg(RC), ReadPsg(RD));

	SetEnvelope(ENV_CONT_ON_ATT_OFF_ALT_OFF_HOLD_ON, sustain);
	printf("(0xaa)RB fine tone: %x (0xbb)RC rough tone: %x (0x09)RD shape: %x\n", ReadPsg(RB), ReadPsg(RC), ReadPsg(RD));

	SetEnvelope(ENV_CONT_ON_ATT_OFF_ALT_ON_HOLD_OFF, sustain);
	printf("(0xaa)RB fine tone: %x (0xbb)RC rough tone: %x (0x0A)RD shape: %x\n", ReadPsg(RB), ReadPsg(RC), ReadPsg(RD));

	SetEnvelope(ENV_CONT_ON_ATT_OFF_ALT_ON_HOLD_ON, sustain);
	printf("(0xaa)RB fine tone: %x (0xbb)RC rough tone: %x (0x0B)RD shape: %x\n", ReadPsg(RB), ReadPsg(RC), ReadPsg(RD));

	SetEnvelope(ENV_CONT_ON_ATT_ON_ALT_OFF_HOLD_OFF, sustain);
	printf("(0xaa)RB fine tone: %x (0xbb)RC rough tone: %x (0x0C)RD shape: %x\n", ReadPsg(RB), ReadPsg(RC), ReadPsg(RD));

	SetEnvelope(ENV_CONT_ON_ATT_ON_ALT_OFF_HOLD_ON, sustain);
	printf("(0xaa)RB fine tone: %x (0xbb)RC rough tone: %x (0x0D)RD shape: %x\n", ReadPsg(RB), ReadPsg(RC), ReadPsg(RD));

	SetEnvelope(ENV_CONT_ON_ATT_ON_ALT_ON_HOLD_OFF, sustain);
	printf("(0xaa)RB fine tone: %x (0xbb)RC rough tone: %x (0x0E)RD shape: %x\n", ReadPsg(RB), ReadPsg(RC), ReadPsg(RD));

	SetEnvelope(ENV_CONT_ON_ATT_ON_ALT_ON_HOLD_ON, sustain);
	printf("(0xaa)RB fine tone: %x (0xbb)RC rough tone: %x (0x0F)RD shape: %x\n", ReadPsg(RB), ReadPsg(RC), ReadPsg(RD));
}
