initPLOT

	100 100 90 100 3000 _w_arc

	10 20 100 150 _w_bar

	_w_update


: CIRCLETEST ( -- )
	500 0 
	DO
		500 400 I _w_circle
		_w_update
	LOOP ;
