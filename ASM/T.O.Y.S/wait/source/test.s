*
*	All effects in wait are synced using "curves" somewhat compatible to Ligthwave
*	envelopes. The main differenc is that only four types of control points are
*	allowed and that controls points must be spread evenly over time.
*
*	The main idea is to set up control points for vital parts in time for example
*	the start end and middel of a effect and then let CALC_CURVE calculate the
*	values for the moments of time betwen.
*
*	CALC_CURVE takes two parameters, in a0 the address of a curve definition and in d0
*	the current time to calculate for. The resulting value is returned in d0.
*
*	A curve definition is made up by first a word with the number of control points
*	in the curve followed by a word with how many steps there are between the control
*	points.
*	Assuming you calculate time in 100/th of a second, you have a curve that should
*	repeat every second and you need a top and a bottom of the curve you probably should
*	use something like this:
*	dc.w	2,50
*	Following the "header" are the control points consisting of two words each, first
*	the value and then the method to use to interpolate to the next control point.
*	if you have X controls points in the header you must define x+3 control points.
*	the first point is the control point BEFORE the curve start and is used by spline
*	curves. Then comes your control points and last two more control points used by
*	liniar and splines to define the behavior AFTER the curve. 
*	The method to use migth be one of the following:
*	0 - Stepped
*		The value is constant until the next control point
*	1 - Liniar
*		The value is interpolated liniar to the next control point
*	2 - Cubic interpolation
*		An aproximasation of a spline curve giving a somewhat S shaped curve
*	3 - Hermite spline
*		Hermite spline with tesnsion fixed at 0, gives a very accurate spline.	
*
*	Included bellow is a test of a curve, run it using 320*XXX truecolor, feel free
*	to experiment with the curve as it migth be easer to understand that way.
*
*	Oh and this source is totaly free to use.

	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp

	move.l	$44e.w,a6


	moveq.l	#0,d6
	move.l	#32*8-1,d7

loop:
	lea	curve,a0
	move.l	d6,d0
	jsr	CALC_CURVE
	mulu	#320,d0
	not.w	(a6,d0.l*2)
	
	addq.l	#1,d6
	addq.l	#2,a6

	dbra	d7,loop

	illegal

curve:
	dc.w	4,32		; four points with 32 steps between
	dc.w	0,0		; The point BEFORE the first point

	dc.w	25,0		; first point value 25 is stepped to next
	dc.w	75,1		; second point is 75 and slides liniar to next
	dc.w	25,2		; third point is 25 and interpolates with cubic-spline to next
	dc.w	75,3		; fourth point is 75 and interpolates with hermite spline to next

	dc.w	25,0		; dummy next point for splines and linier
	dc.w	75,0		; two dummies for splines

	include	'curve.s'

