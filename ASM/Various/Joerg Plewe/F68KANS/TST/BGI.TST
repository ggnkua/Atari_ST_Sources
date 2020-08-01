
( Variable )

VARIABLE GRAPHMODE
VARIABLE GRAPHDRIVER

VARIABLE GRAPH_IS_ON
0 GRAPH_IS_ON !

DETECT GRAPHDRIVER !

: PATHTODRIVER ( -- c-addr u )
	S" .\fonts" ;

viewporttype vp

0 	VALUE XRES 
0	VALUE YRES 


DECIMAL 

	
: INITGRAPH ( -- )
	GRAPH_IS_ON @ 0=
	IF
		GRAPHDRIVER GRAPHMODE PATHTODRIVER _initgraph
		_cleardevice
	
(	100 100 1200 900 1 _setviewport )
( 	_clearviewport )

		vp _getviewsettings
		vp >vp_left 	w@ .
		vp >vp_top 		w@ .
		vp >vp_right 	w@ .
		vp >vp_bottom 	w@ .
		vp >vp_clip 	w@ .
		vp >vp_right w@   vp >vp_left w@  - 	TO XRES
		vp >vp_bottom w@  vp >vp_top w@   -		TO YRES  

		_graphresult _grapherrormsg TYPE
	THEN
	1 GRAPH_IS_ON +!
;


: EXITGRAPH ( -- )
	-1 GRAPH_IS_ON +! 
	GRAPH_IS_ON @ 0=
	IF	_closegraph 	THEN ;


: putpixeltest ( -- )
	100 0 
	DO	I 6 * I 2 *  1 _putpixel  LOOP ; 


: PUTPIXELDEMO ( -- )
	INITGRAPH
	10000 0 
	DO
		XRES _random  YRES _random	1  _putpixel
	LOOP
	EXITGRAPH ;


6 CONSTANT MAXPTS
CREATE CORNERS  MAXPTS CELLS ALLOT	( 2*MAXPTS ints )

: RANDOM-CORNERS ( -- )
	MAXPTS 1- 0 
	DO
		XRES _random   	CORNERS I CELLS +  		w! 
		YRES _random	CORNERS I CELLS 2 + + 	w! 
	LOOP
	CORNERS @ 
	CORNERS MAXPTS 1- CELLS + !	( last point = first point )
;  


: FILLPOLYDEMO	( -- )
	INITGRAPH
	100 0  
	DO		
		RANDOM-CORNERS	
		12 _random  1 ( color )	_setfillstyle
		MAXPTS CORNERS _fillpoly	
	LOOP 
	EXITGRAPH ;
	
: DRAWPOLYDEMO	( -- )
	INITGRAPH
	500 0  
	DO		
		RANDOM-CORNERS	
		12 _random  1 ( color )	_setfillstyle
		MAXPTS CORNERS _drawpoly	
	LOOP 
	EXITGRAPH ;
	
	
: CIRCLEDEMO ( -- )	
	INITGRAPH
	2000 0 
	DO
		XRES _random 	YRES _random	150 _random 
		_circle
	LOOP
	EXITGRAPH ;
	

: ARCDEMO ( -- )	
	INITGRAPH
	2000 0 
	DO
		XRES _random 	YRES _random	
		360 _random		360	_random
		150 _random 
		_arc
	LOOP
	EXITGRAPH ;
	
	
: ELLIPSEDEMO ( -- )	
	INITGRAPH
	2000 0 
	DO
		XRES _random 	YRES _random	
		360 _random		360	_random
		150 _random 	150 _random
		_ellipse
	LOOP
	EXITGRAPH ;
	
	
: FILLELLIPSEDEMO ( -- )	
	INITGRAPH
	800 0 
	DO
		12 _random  1 ( color )	_setfillstyle
		XRES _random 	YRES _random	
		150 _random 	150 _random
		_fillellipse
	LOOP
	EXITGRAPH ;

: WAIT ( -- )
	3000000 0 DO LOOP ;
	
: BARDEMO ( -- )	
	INITGRAPH
	6 1 
	DO
		12 _random  1 ( color )	_setfillstyle
		XRES 7 / I * 	YRES 7 / I *	
		OVER XRES 8 / + 	YRES 10 - 
		_bar
	LOOP
	WAIT
	EXITGRAPH ;
	
	
: BAR3DDEMO ( -- )	
	INITGRAPH
	6 1 
	DO
		12 _random  1 ( color )	_setfillstyle
		XRES 7 / I * 	YRES 7 / I *	
		OVER XRES 10 / + 	YRES 10 -
		XRES 40 /			1  
		_bar3d
	LOOP
	WAIT
	EXITGRAPH ;
	
	
: LINEDEMO ( -- )	
	INITGRAPH
	5000 0 
	DO
		XRES _random 	YRES _random 
		XRES _random 	YRES _random 
		_line
	LOOP
	EXITGRAPH ;
	


( Textdemo )

2 VALUE MAXTH
	
: TESTSTRING ( -- c-addr u )
	S" F68KANS" ;	
	
: FIND_MAXTH ( -- )	
	100000 2
	DO
		TRIPLEX_FONT TEXT_HORIZ_DIR I _settextstyle
		XRES TESTSTRING _textwidth - 10 -
		0 < 
		IF 	I TO MAXTH  LEAVE  THEN
	LOOP ;
	
	
: DOBOTTEXT ( -- )	
	5 TESTSTRING _textheight
	YRES 10 - SWAP - TESTSTRING		_outtextxy ;
	
	
: DOTOPTEXT	
	XRES TESTSTRING _textwidth - 5 -
	10 TESTSTRING	_outtextxy ;



: DOMIDTEXT ( -- )
	TRIPLEX_FONT TEXT_HORIZ_DIR MAXTH _settextstyle
	5 YRES 3 / TESTSTRING _outtextxy ;


	
: TEXTDEMO ( -- )
	INITGRAPH
	FIND_MAXTH
	_clearviewport
(	2 0  )
(	DO	)
		MAXTH 1+ 1 
		DO
			TRIPLEX_FONT TEXT_HORIZ_DIR I _settextstyle
			DOTOPTEXT
			DOBOTTEXT
		LOOP
		_clearviewport
		DOMIDTEXT
		0 MAXTH  
		DO
			TRIPLEX_FONT TEXT_HORIZ_DIR I _settextstyle
			DOTOPTEXT
			DOBOTTEXT
		-1 +LOOP
		_clearviewport
(	LOOP	)
	EXITGRAPH ;


	
( PUTPIXELDEMO FILLPOLYDEMO DRAWPOLYDEMO CIRCLEDEMO ARCDEMO 
( ELLIPSEDEMO FILLELLIPSEDEMO
( BARDEMO BAR3DDEMO
( LINEDEMO



: FULLDEMO ( -- )
	INITGRAPH
	TEXTDEMO		
 	PUTPIXELDEMO 	TEXTDEMO
 	FILLPOLYDEMO 	TEXTDEMO
 	DRAWPOLYDEMO 	TEXTDEMO
 	CIRCLEDEMO 		TEXTDEMO
 	ARCDEMO 		TEXTDEMO
 	ELLIPSEDEMO 	TEXTDEMO
 	FILLELLIPSEDEMO	TEXTDEMO
 	BARDEMO 		TEXTDEMO
 	BAR3DDEMO		TEXTDEMO
 	LINEDEMO		TEXTDEMO
 	EXITGRAPH
;



: DAUERDEMO INITGRAPH BEGIN FULLDEMO AGAIN EXITGRAPH ; 



