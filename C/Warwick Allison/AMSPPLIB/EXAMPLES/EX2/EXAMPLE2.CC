#include <Resolution.h>
#include <Screen.h>
#include <EasySprite.h>
#include <DoubleBuffer.h>
#include <Oscillator.h>
#include <MousePosition.h>

Resolution* Rez;


void Animate(Sprite* Example)
{
	Cycle EverySoOften(3);
	Oscillator Spikes(0,3);

	Mouse.Bound(10,10,Rez->Width()-20,Rez->Height()-20);

	while (!Mouse.LeftButton()) {
		Example->Wipe();
		Example->MoveTo(Mouse.X(),Mouse.Y());
		Example->Draw();

		if (EverySoOften()) Example->ShapeTo(Spikes.Oscillate());

		Pages->Flip();
	}
}

main()
{
	Resolution InitialRez;

	if (InitialRez!=STHigh) STLow.Use();

	Rez=new Resolution;

	Screen This;
	This.Load(*Rez==STHigh ? "example2.ca3" : "example2.ca1");
	Screen That(This);
	That.ShowPalette();

	Pages=new DoubleBuffer(This,That);

	Sprite* Example;

	if (*Rez==STHigh) {
		Example=GetSprite(This,48,50,16,SP_MONO|SP_HOTCENTRE,4,0,17);
	} else {
		Example=GetSprite(This,48,50,16,SP_COLOUR|SP_HOTCENTRE,4,0,17);
	}

	Animate(Example);
}
