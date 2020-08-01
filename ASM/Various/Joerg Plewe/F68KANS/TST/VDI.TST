\  3.09.93

DECIMAL

S" ..\APPFTH\AES.4" INCLUDED
S" ..\APPFTH\VDI.4" INCLUDED

0 VALUE VDI_HANDLE
0 VALUE xmax		0 VALUE ymax

: WAIT 200000 0 DO LOOP ;

: INITGRAPH		open_vwork TO VDI_HANDLE
				0 intout w@ TO xmax		1 intout w@ TO ymax
				v_clrwk
				0 0 xmax ymax 1 vs_clip ;

: EXITGRAPH		v_clsvwk ;

: LINEDEMO ( -- )
		INITGRAPH
		3 vswr_mode	
		xmax  0  	DO	I 0  xmax I - ymax 2 v_pline	LOOP
		ymax 0		DO 	xmax I  0 ymax I - 2 v_pline	LOOP
		EXITGRAPH ;

: PUTPIXELDEMO ( -- )
	INITGRAPH
	5000 0
	DO
		xmax _random  ymax _random	2DUP 2 v_pline
	LOOP
	EXITGRAPH ;

6 CONSTANT MAXPTS

: RANDOM-CORNERS ( -- )
	MAXPTS  0
	DO
		xmax _random   	ymax _random	
	LOOP ;


: FILLPOLYDEMO1	( -- )
	INITGRAPH
	3 vsf_interior	( Fuellmusterart = Schraffur )	
	100 0
	DO		
		RANDOM-CORNERS
		13 _random  vsf_style
		MAXPTS v_fillarea	
	LOOP
	EXITGRAPH ;

: FILLPOLYDEMO2	( -- )
	INITGRAPH
	100 0
	DO		
		RANDOM-CORNERS
		2 vsf_interior	( Fuellmusterart = Muster )	
		25  _random  vsf_style
		MAXPTS v_fillarea	
	LOOP
	EXITGRAPH ;

: DRAWPOLYDEMO	( -- )
	INITGRAPH
	200 0
	DO		
		RANDOM-CORNERS	
		MAXPTS v_pline	
	LOOP
	EXITGRAPH ;

: CIRCLEDEMO ( -- )	
	INITGRAPH
	3 vsf_interior	( Fuellmusterart = Schraffur )	
	100 0
	DO
		13 _random  vsf_style
		xmax _random 	ymax _random	150 _random
		v_circle
	LOOP
	EXITGRAPH ;

: ARCDEMO ( -- )	
	INITGRAPH
	200 0
	DO
		xmax _random 	ymax _random	
		150 _random
		3600 _random	3600	_random
		v_arc
	LOOP
	EXITGRAPH ;

: ELLIPSEDEMO ( -- )	
	INITGRAPH
	3 vsf_interior
	100 0
	DO
		13 _random vsf_style
		xmax _random 	ymax _random
		150 _random 	150 _random	
		v_ellipse
	LOOP
	EXITGRAPH ;

: ELLPIEDEMO ( -- )	
	INITGRAPH
	2 vsf_interior
	100 0
	DO
		25 _random vsf_style
		xmax _random 	ymax _random
		150 _random		150 _random
		3600 _random 	3600 _random
		0 0 xmax ymax 1 vs_clip
		v_ellpie
	LOOP
	EXITGRAPH ;

CREATE test$ ," F68KANS" 0 C,

: POLYMARKERDEMO ( -- )
	INITGRAPH
	100 0
	DO
		6 _random vsm_type
		21 _random vsm_height		
		RANDOM-CORNERS
		MAXPTS v_pmarker 	
	LOOP
	EXITGRAPH WAIT ;

: BARDEMO ( -- )
	INITGRAPH
	2 vsf_interior
	ymax 2/  0
	DO
		25 _random vsf_style
		I I   xmax I - ymax I - v_bar
	16 +LOOP
	EXITGRAPH WAIT ;

CREATE justified$ ," Dies ist justierter Text" 0 C,


: JUSTLINKSDEMO ( -- )
	INITGRAPH
	0 5 vst_alignment
	ymax 0 DO
		0 I  150 I +  1 1 justified$ v_justified
	16 +LOOP
	EXITGRAPH ;

: JUSTRECHTSDEMO ( -- )
	INITGRAPH
	2 5 vst_alignment
	ymax 0 DO
		xmax I  150 I +  1 1 justified$ v_justified
	16 +LOOP
	EXITGRAPH ;

: JUSTMITTEDEMO ( -- )
	INITGRAPH
	1 5 vst_alignment
	ymax 0 DO
		xmax 2/ I  150 I +  1 1 justified$ v_justified
	16 +LOOP
	EXITGRAPH ;

: JUSTIFIEDDEMO ( -- )
	JUSTRECHTSDEMO WAIT JUSTLINKSDEMO WAIT JUSTMITTEDEMO WAIT ;

: TEXTDEMO ( -- )
	INITGRAPH
	0 5 vst_alignment
	14 _random 6 + vst_point
	ymax 18 - 0 DO
		31 _random 27 AND vst_effects  \ KURSIV AUSBLENDEN
		50 I   	test$ v_gtext   200 I   test$ v_gtext
		350 I   test$ v_gtext 	500 I   test$ v_gtext
	20 +LOOP	
	( 3600 _random vst_rotation )
	EXITGRAPH WAIT ;

: FULLDEMO
	LINEDEMO		WAIT
	PUTPIXELDEMO	TEXTDEMO
	FILLPOLYDEMO1	TEXTDEMO
	FILLPOLYDEMO2	TEXTDEMO
	DRAWPOLYDEMO	TEXTDEMO
	CIRCLEDEMO		TEXTDEMO
	ARCDEMO			TEXTDEMO
	ELLIPSEDEMO		TEXTDEMO
	ELLPIEDEMO		TEXTDEMO
	POLYMARKERDEMO	TEXTDEMO
	BARDEMO			TEXTDEMO
	JUSTIFIEDDEMO	TEXTDEMO
;

\ FULLDEMO



