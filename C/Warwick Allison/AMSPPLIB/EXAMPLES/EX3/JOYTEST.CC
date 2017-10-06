#include <Termination.h>
#include <Joystick.h>

main()
{
	TrapExceptions(TRUE);

	Joystick Stick[2]={0,1};

	for (int x=0; x<100; x++) {
		for (int s=0; s<=1; s++) {
			printf("stick(%d): Way %d = (%d,%d) trigger %s\n",
					s,
					Stick[s].Way(),
					Stick[s].X(),Stick[0].Y(),
					Stick[s].Trigger() ? "on" : "off");
		}
		printf("\n");
	}
}
