/*	vt52.h	/	MATRIX	/	WA	/	13.9.91	*/

# define CLEARscreen	"\033E"
# define CLEARline		"\033K"
# define REVERSvideo	"\033p"
# define NORMALvideo	"\033q"

# define REV(s)	REVERSvideo s NORMALvideo

# define CURSORon		"\033e"
# define CURSORoff		"\033f"
# define CURSORsave		"\033j"
# define CURSORrestore	"\033k"

# define CURSORhome		"\033H"
# define CURSORup		"\033A"
# define CURSORdown		"\033B"
# define CURSORright	"\033C"
# define CURSORleft		"\033D"
# define CURSORset		"\033Y"
# define ERASEeol		"\033K"

# define WRAPeol		"\033v"
# define DISCARDeol		"\033w"

