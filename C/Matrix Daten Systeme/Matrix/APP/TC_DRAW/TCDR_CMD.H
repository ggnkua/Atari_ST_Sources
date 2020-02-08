typedef enum CMDnum
{
	CMDillegal = 0,

	/* User Commands */
	
	CMDversion = FIRSTuser,

	CMDsave,
	
	CMDwritemode,
	CMDblitmode,
	CMDpattern,
	CMDcolor,
	CMDrgb,
	CMDpalette,
	CMDclosetools,
	CMDswitchtool,

	CMDload,

/*... special drawing .................................................*/

	CMD_ERASE,

/*... standard drawing .................................................*/

	CMD_CIRCL,
	CMD_DOT,
	CMD_LINE,
	CMD_FILL,
	CMD_MIRR,
	CMD_RECT,
	CMD_CUBE,
	CMD_HRECT,
	CMD_HLINE,
	CMD_FILTR,
	CMD_CALIB,
	CMD_INV,
	CMD_GRAY,
	CMD_BRIGH,
	CMD_3RUN,
	CMD_4RUN,
	CMD_FRUN,
	CMD_MRUN,
	CMD_CRUN,	
	CMD_STORE,
	CMD_FRECT,
	CMD_LUPE,
	CMD_VIDEO,
	CMDdemo,
	CMD_TOBOX,
	CMD_FRBOX,		
	CMD_COPY,
	CMD_DTOS,
	CMD_STOD,
	CMD_TEXT,
	CMD_RBOW,
	CMD_PSIM,
	CMD_FRACT
} ;

CMD user_cmd_table[] =
{
/*	shorts :	X Q H L C V	R A P G B */
{ "version",	"",		"print program version",	CMDversion		},


{ "save", 		"%i%i%i%i%e", 	"+/-save drawing switch, or save { rect }",				-CMDsave },
{ "writemode", 	"%i%e", 		"set writing mode [ 1..4 ]",	CMDwritemode },
{ "blitmode", 	"%i%e", 		"set blit mode [ 0..27 ]",		CMDblitmode },
{ "pattern", 	"%i%i%e", 		"pattern [ 0..38 ]",			CMDpattern },
{ "color", 		"%i",	 		"set color index [ 0..255 ]",	CMDcolor },
{ "rgb", 		"%i%i%i",		"set rgb [ r, g, b ]", 			CMDrgb },
{ "palette", 	"%i%i%i%i",		"set palette [ ix, r, g, b ]",	CMDpalette },

{ "closetools",	"",				"close tool boxes",	 			CMDclosetools },
{ "tool",		"%s",			"+/- switch tool box [ name ]",	-CMDswitchtool },

/*... special drawing .................................................*/

{ "erase", 		"%i%e", 	"erase canvas { color }",		CMD_ERASE },

/*... standard drawing .................................................*/

{ "load",		"%s%i%i%i%i", "", CMDload },

{ "circle", 	"%i%i%i%i%d", 	"circle", CMD_CIRCL },
{ "dot",		"%i%i%i%i", 	"dot", CMD_DOT },
{ "line",		"%i%i%i%i%e", 	"line", CMD_LINE },
{ "fill",		"%i%i%i%e", 	"seed fill [ point { stop-color } ]", CMD_FILL },
{ "mirror",		"%i%i%i%i%e", 	"mirror", CMD_MIRR },
{ "rectangle",	"%i%i%i%i%e", 	"rectangle", CMD_RECT },
{ "cube",		"%i%i%i%i%e", 	"color cube", CMD_CUBE },
{ "historect",	"%i%i%i%i", "", CMD_HRECT },
{ "histoline",	"%i%i%i%i", "", CMD_HLINE },
{ "filter",		"%i%i%i%i", "", CMD_FILTR },
{ "calib",		"%i%i%i%i", "", CMD_CALIB },
{ "invert",		"%i%i%i%i%e", 	"invert rectangle", CMD_INV },
{ "gray",		"%i%i%i%i%e", 	"gray rectangle", CMD_GRAY },
{ "bright",		"%i%i%i%i%c", 	"brighten rectangle", CMD_BRIGH },
{ "3run",		"%i%i%i%i", "", CMD_3RUN },
{ "4run",		"%i%i%i%i", "", CMD_4RUN },
{ "freerun",	"%i%i%i%i", "", CMD_FRUN },
{ "mrun",		"%i%i%i%i", "", CMD_MRUN },
{ "crun",		"%i%i%i%i", 	"corner color run", CMD_CRUN },	
{ "store",		"%i%i%i%i", "", CMD_STORE },
{ "frect",		"%i%i%i%i%e", 	"filled rectangle", CMD_FRECT },
{ "zoom",		"%i%i%i%i%e", 	"zoom [ rect ]", CMD_LUPE },
{ "video",		"%i%i%i%i%i%e",	"+/-video { ( x,y0, x,y1 | 0 0 0 0 ) { count }", -CMD_VIDEO },
{ "demo",		"%i%i%i%i%i%i%i%e",	"demo { x/y0 x/y1 #1..4 count erase }",	CMDdemo },
{ "tobox",		"%i%i%i%i", 	"copy to box",		CMD_TOBOX },
{ "frombox",	"%i%i%i%i", 	"copy from box",	CMD_FRBOX },		
{ "copyrect",	"%i%i%i%i%i%i%i%i", "copyrect [ srect drect ]", CMD_COPY },
{ "dtos",		"%i%i%i%i", "", CMD_DTOS },
{ "stod",		"%i%i%i%i", "", CMD_STOD },
{ "text",		"%i%i%i%i%s", 	"text [ rect string ]", CMD_TEXT },
{ "rainbow",	"%i%i%i%i%i%e", "rain bow [ rect { mode } ]", CMD_RBOW },
{ "simulate",	"%i%i%i%i%e", 	"simulate clut", CMD_PSIM },
{ "fractal",	"%i%i%i%i", 	"calc fractale", CMD_FRACT },

{ "",			"",	"",	0				}
} ;
