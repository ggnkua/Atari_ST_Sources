short  DrawPoint   (Window *,Pen *,Point);
short  DrawPoints  (Window *,Pen *,Point *,short);

short  DrawLine    (Window *,Pen *,Point *);
short  DrawLines   (Window *,Pen *,Point *,short);
short  DrawPolyline(Window *,Pen *,Point *,short);

short  DrawBox     (Window *,Pen *,Point *);
short  DrawBoxes   (Window *,Pen *,Point *,short);

short  DrawCircle  (Window *,Pen *,Point,short);
short  DrawCircles (Window *,Pen *,Point *, short *, short);

short  DrawFilled_Polyline(Window *,Pen *,Point , short);

short  DrawFilled_Box     (Window *,Pen *,Point *);
short  DrawFilled_Boxes   (Window *,Pen *,Point *,short);

short  DrawFilled_Circle  (Window *,Pen *,Point,short);
short  DrawFilled_Circles (Window *,Pen *,Point *, short *, short);

Pen   *PenCreate ( ??? );
short  PenDelete ( ??? );
short  PenSet    ( ??? );
short  PenGet    ( ??? );
short  PenCopy   ( ??? );