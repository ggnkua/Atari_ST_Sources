( Drache.fth: for recursive dragons)
( St. George, PA Shipping)
( Note: this is a recursive program and makes
  massive use of the stacks. If you get carried
  away and try '28 dragon' or some such,
  the system will crash.)
decimal
: Drag RECURSIVE { x1 y1 x2 y2 x3 y3 k  |  x4 y4 x5 y5 }
	PAUSE
	k 0= 				( if k=0, just draw and return)
	IF				( else continue breaking lines down)
		x2 y2 LineTo
		x3 y3 LineTo 
	ELSE
		k 1- -> k
		x1 x2 + 2/  y2 y1 - 2/  -  -> x4
		y1 y2 + 2/  x2 x1 - 2/  +  -> y4
		x2 x3 + 2/  y3 y2 - 2/  +  -> x5
		y2 y3 + 2/  x3 x2 - 2/  -  -> y5
		x1 y1 x4 y4 x2 y2 k Drag
		x2 y2 x5 y5 x3 y3 k Drag
	THEN  ;
	
	
: Dragon { iters -- }	( '12 dragon' gives good results)
	CLS
	50 94  MoveTo			( place pen at beginning)
	50 94  114 30  178 94  iters Drag	( start w/ initial seed)
	;

cr .( type '12 dragon') cr