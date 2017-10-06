#include <SoundEnvelope.h>
#include <Sound.h>
#include <stdio.h>
#include <builtin.h>
#include <osbind.h>

main(int argc, char*argv[])
{
	if (argc!=6) {
		fprintf(stderr,"Usage:  %s Pitch PitchChange Volume VolumeChange NoisePeriod\n",argv[0]);
	} else {
		SoundEnvelope E(
			(short)atoi(argv[1]),(short)atoi(argv[2]),
			(short)atoi(argv[3]),(short)atoi(argv[4]),
			600,-1,
			(bool)(atoi(argv[5])>0)
		);
		SetNoisePeriod(atoi(argv[5]));
		E.Start();
		while (DoSounds()) Vsync();
	}
}
