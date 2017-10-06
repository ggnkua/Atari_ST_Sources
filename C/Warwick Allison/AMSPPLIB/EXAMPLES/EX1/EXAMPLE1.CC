#include <Resolution.h>
#include <Screen.h>
#include <ScanCode.h>


main()
{
	Resolution NowRez;

	if (NowRez!=STHigh)
		STLow.Use();

	Screen S;

	if (NowRez==STHigh) {
		S.Load("example1.ca3");
	} else {
		S.Load("example1.ca1");
	}

	S.Show();
	S.ShowPalette();

	Key();
}
