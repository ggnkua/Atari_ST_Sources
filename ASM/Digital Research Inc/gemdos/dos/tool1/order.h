/*
	Copyright 1983
	Alcyon Corporation
	8716 Production Ave.
	San Diego, CA  92121

	@(#)order.h	2.1    7/5/84  REGULUS 4.2
*/

#ifdef MC68000
	struct { char b1; char b2; char b3; char b4; };
	struct { char wb1; char wb2; };

	union WORDPTR {
		long	longwd;
		struct {
			int hiword;
			int loword;
		} WORDSTR;
	};

	union BYTEPTR {
		short	shortwd;
		struct {
			char hibyte;
			char lobyte;
		} BYTESTR;
	};
#endif

#ifdef VAX11
	struct { char b4; char b3; char b2; char b1; };
	struct { char wb2; char wb1; };

	union WORDPTR {
		long	longwd;
		struct {
			short loword;
			short hiword;
		} WORDSTR;
	};

	union BYTEPTR {
		short	shortwd;
		struct {
			char lobyte;
			char hibyte;
		} BYTESTR;
	};
#endif

#ifdef PDP11
	struct { char b2; char b1; char b4; char b3; };
	struct { char wb2; char wb1; };

	union WORDPTR {
		long	longwd;
		struct {
			int hiword;
			int loword;
		} WORDSTR;
	};
	union BYTEPTR {
		int		shortwd;
		struct {
			char lobyte;
			char hibyte;
		} BYTESTR;
	};
#endif

#define _FAILURE -1
#define _SUCCESS 0
