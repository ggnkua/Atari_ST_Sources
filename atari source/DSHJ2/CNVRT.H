#define		ALNUM	8	/* Atari Laser # of ranges	*/
#define		EPNUM	4	/* CG	 EP308 # of ranges	*/

/*
	unit_type value from UNIT4
	0 --	Inch.1/100 Inch			    X & Y
	1  --	Pica.Point	X,	Point.1/4 Point Y
	2  --	Millimeter.1/10 Millimeter	    X & Y
	3  --	Cicero.Didot	X,	Didot.1/4 Didot Y
*/

/*
	Counting Unit Qualifier tables
*/
unsigned hlq[UNIT4]= { 100  , 12  , 10		, 12		};
double	 hrq[UNIT4]= { 12.96, 18.0, 5.102362205	, 19.28571429	};

unsigned vlq[UNIT4]= { 100  , 4  , 10		, 4		};
double	 vrq[UNIT4]= { 11.52, 4.0, 4.535433071	, 4.285714286	};

/*
	Atari Laser Dimensions Tables

	pagetype (-PA4)	definitions	from ALNUM
	0 --	A4	(8.25x11.75)	Portrait
		46 Pc .8 Pt	X,	812 Pt .2 1/4Pt	Y
	1 --	B5	(7.25x10.25)	Portrait
		40 Pc .3 Pt	X,	699 Pt .1 1/4Pt	Y
	2 --	Letter	(8.5x11)	Portrait
		48 Pc		X,	763 Pt		Y
	3 --	Legal	(8.5x14)	Portrait
		48 Pc		X,	979 Pt		Y
	4 --	A4	(8.25x11.75)	Landscape
		67 Pc .8 Pt	X,	560 Pt .2 1/4Pt	Y
	5 --	B5	(7.25x10.25)	Landscape
		58 Pc .3 Pt	X,	483 Pt .3 1/4Pt	Y
	6 --	Letter	(8.5x11)	Landscape
		63 Pc .7 Pt	X,	576 Pt		Y
	7 --	Legal	(8.5x14)	Landscape
		81 Pc .7 Pt	X,	576 Pt		Y
*/
unsigned pvxmax[ALNUM]=		/* LASER MAX X	*/
/*{ 10092, 8709, 10368, 10368 }; Old values */
  { 10092, 8709, 10368, 10368, 14628, 12588, 13738, 17626 };

unsigned pvymax[ALNUM]=		/* LASER MAX Y	*/
/*{ 13002, 11190, 12096, 15552 }; Old values */
  { 13003, 11189, 12211, 15667, 8971, 7741, 9216, 9216 };


/*
	CG EP308 Laser Dimensions Tables

	pagetype (-PA4)	definitions	from EPNUM
	0 --	Letter	(8.5x11)	Portrait
		48 Pc .6 Pt	X,	785 Pt		Y
	1 --	Legal	(8.5x14)	Portrait
		48 Pc .6 Pt	X,	999 Pt .3 1/4Pt	Y
	2 --	Letter	(8.5x11)	Landscape
		65 Pc .5 Pt	X,	582 Pt		Y
	3 --	Legal	(8.5x14)	Landscape
		70 Pc		X,	582 Pt		Y
*/
unsigned epxmax[EPNUM]=		/* EP308 MAX X	*/
{ 10476, 10476, 14130, 15120 };

unsigned epymax[EPNUM]=		/* EP308 MAX Y	*/
{ 12560, 15996, 9312, 9312 };
