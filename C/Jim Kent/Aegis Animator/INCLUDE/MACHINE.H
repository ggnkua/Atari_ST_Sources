


extern struct RastPort *cur_pix;	/*pointer to current screen description*/
extern struct Screen    *Iscreen;
extern struct Window    *MainWindow;

extern struct ViewPort *vp0;
extern struct RastPort *rp0, *rp1;
extern struct BitMap *bm0, *bm1;
/*if all works well I share #0 of the above three lines with rj and
  intuition, and have to deal with initializing etc #1 myself for
  double buffering - at least until we figure out how to double
  buffer using screens.  -jk May17 '85   */


