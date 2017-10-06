#include <Resolution.h>
#include <Screen.h>
#include <BlockMap.h>
#include <DoubleBuffer.h>
#include <Joystick.h>
#include <Shape.h>

const int MAPSIZE=64;
const int NUMBLOCKS=32;

void Animate(BlockMap& Map, BlockImages& Images)
{
	BlockMapView View(Map,Images,0,0,9,9);
	Joystick Stick;
	Rectangle Range(0,0,MAPSIZE-9+1,MAPSIZE-9+1);
	Point P(3,3);

	while (!Stick.Trigger()) {
		P.x+=Stick.X();
		P.y+=Stick.Y();
		P.Bound(Range);

		View.Views(P);

		View.Draw();
		Pages->Flip();
	}
}

main()
{
	Resolution InitialRez;

	if (InitialRez!=STHigh && InitialRez!=TTMedium)
		STLow.Use();

	Pages=new DoubleBuffer;

	Pages->Current().Clear();
	Pages->NowShowing().Clear();

	Screen ImageBank(STLow);
	BlockMap Map(MAPSIZE,MAPSIZE);
	BlockImages* Images;

	for (int x=0; x<MAPSIZE; x++)
		for (int y=0; y<MAPSIZE; y++) {
			Map.Set(x,y,(x+y)%NUMBLOCKS);
		}

	if (InitialRez==STHigh) {
		ImageBank.Load("example3.ca3");
		Images=new WideMonochromeBlockImages(NUMBLOCKS,30);
	} else {
		ImageBank.Load("example3.ca1");
		Images=new ColourBlockImages(NUMBLOCKS,15);
	}

	Images->GetImages(0,NUMBLOCKS,ImageBank);
	ImageBank.ShowPalette();

	Animate(Map,*Images);
}
