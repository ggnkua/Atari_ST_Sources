/* ------------------------------------------------------------------- */

VOID PaintObject ( OBJECT *tree, INT obj )

{
  objc_draw ( tree, obj, 0, 0, 0, 1279, 959 );
}

/* ------------------------------------------------------------------- */

VOID DrawObject ( OBJECT *tree, INT head, INT tail, INT depth )

{
  PaintObject ( tree, head );
  if ( depth == 0 ) return;
  if ( tree [head].ob_flags & LASTOB ) return;
  if ( tree [head].ob_head >= 0 )
    {
      DrawObject ( tree, tree [head].ob_head, tree [head].ob_tail, depth );
    }
  if ( tree [head].ob_next >= 0 )
    {
      if ( head == tail ) return;
      forever
        {
          head = tree [head].ob_next;
          PaintObject ( tree, head );
          if ( tree [head].ob_head >= 0 )
            {
              DrawObject ( tree, tree [head].ob_head, tree [head].ob_tail, depth );
            }
          if ( head == tail ) break;
        }
    }
}

/* ------------------------------------------------------------------- */

VOID DrawTree ( OBJECT *tree, INT start, INT depth )

{
  DrawObject ( tree, start, 0, depth );
}
