// --------------------------------------------------------------------
//	platform stuff - todo: OSX/Linux porting!
// --------------------------------------------------------------------

#define _CRT_SECURE_NO_WARNINGS
#include <windows.h>
#include "stdio.h"
#include <iostream>

// --------------------------------------------------------------------
//	STL
// --------------------------------------------------------------------

#include <list>
#include <vector>

// --------------------------------------------------------------------
//	stb_image! nice :)
// --------------------------------------------------------------------

#define STB_IMAGE_IMPLEMENTATION
#include "3rdparty\stb_image.h"

// --------------------------------------------------------------------
//	local types
// --------------------------------------------------------------------

typedef unsigned int datasize_t;

typedef int long_t;
typedef short word_t;
typedef signed char byte_t;

typedef unsigned int ulong_t;
typedef unsigned short uword_t;
typedef unsigned char ubyte_t;

// alternates, for working with engine types
typedef int s32;
typedef short s16;
typedef signed char s8;

typedef unsigned int u32;
typedef unsigned short u16;
typedef unsigned char u8;

// meh: this arrived with BMP and lingers on...
typedef struct RGB
{
    ubyte_t blue;
    ubyte_t green;
    ubyte_t red;
} RGB;

// --------------------------------------------------------------------
//	constants
// --------------------------------------------------------------------

// tool version
static const char* const g_version_string = "v0.17";

// SPS file format version
static const int SPS_VERSION = 0x100;

// --------------------------------------------------------------------
//	some ...globals (?!)
// --------------------------------------------------------------------

static int s_progress = 0;
static int g_maxplanes = 4;

// --------------------------------------------------------------------
// SimpleOpt... because life is too short
// --------------------------------------------------------------------

#if defined(_MSC_VER)
# include <windows.h>
# include <tchar.h>
#else
# define TCHAR		char		// yuck
# define _T(x)		x
#endif

#include "3rdparty\SimpleOpt.h"
#include "3rdparty\SimpleGlob.h"

// --------------------------------------------------------------------
//	misc. small helper functions
// --------------------------------------------------------------------

static inline uword_t endianswap16(const uword_t _v)
{
	return ((_v & 0xFF00) >> 8) | ((_v & 0x00FF) << 8);
}

static inline ulong_t endianswap32(const ulong_t _v)
{
	return  ((_v & 0xFF000000) >> 24) |
			((_v & 0x00FF0000) >> 8) |
			((_v & 0x0000FF00) << 8) |
			((_v & 0x000000FF) << 24);
}

static inline int xmin(int _x, int _y)
{
	return (_x < _y) ? _x : _y;
}

static inline int xmax(int _x, int _y)
{
	return (_x > _y) ? _x : _y;
}

// --------------------------------------------------------------------
//	interface to engine tileset reader, for access to palettes
// --------------------------------------------------------------------

// todo: move reader/writer out of tool generally!
//#include "tileset.h"

// --------------------------------------------------------------------
//	commandline handling
// --------------------------------------------------------------------

// define the ID values to indentify the option
enum
{ 
	OPT_HELP, 
	OPT_VERBOSE, 
	OPT_QUIET, 
	OPT_WAIT_KEY, 
	// general
	OPT_BITPLANES,
	OPT_KEYCOL,
	OPT_KEYGUARD,
	OPT_KEYTOL,
	OPT_SOURCE,
	OPT_PALETTE,
	OPT_CUTMODE,
	// sprites
//	OPT_SPRITEGUIDE, // may not bother with this - command switches cover it
	OPT_PREVIEW,
	OPT_GENMASK,
	OPT_MASKLAYOUT,
	OPT_SPROPT,
	OPT_SPRXP,
	OPT_SPRYP,
	OPT_SPRXS,
	OPT_SPRYS,
	OPT_SPRXI,
	OPT_SPRYI,
	OPT_SPRXC,
	OPT_SPRYC,
	OPT_SPRCOUNT,
	// tiles
	OPT_TOLERANCE, 
	OPT_OUTMODE
	//
};

CSimpleOpt::SOption g_Options[] = 
{
	{ OPT_HELP, 		_T("-?"),     			SO_NONE		},
	{ OPT_HELP, 		_T("-h"),     			SO_NONE		},
	{ OPT_HELP, 		_T("--help"), 			SO_NONE		},
	//
	{ OPT_VERBOSE, 		_T("-v"),     			SO_NONE		},
	{ OPT_VERBOSE,		_T("--verbose"), 		SO_NONE		},
	//
	{ OPT_QUIET, 		_T("-q"),     			SO_NONE		},
	{ OPT_QUIET,		_T("--quiet"), 			SO_NONE		},
	//
	{ OPT_WAIT_KEY,		_T("-wk"),    			SO_NONE		},
	{ OPT_WAIT_KEY,		_T("--wait-key"), 		SO_NONE		},
	//
	{ OPT_PREVIEW,		_T("-prv"),     		SO_NONE		},
	{ OPT_PREVIEW,		_T("--preview"), 		SO_NONE		},
	//
	{ OPT_GENMASK,		_T("-gm"),	 			SO_NONE		},
	{ OPT_GENMASK,		_T("--gen-mask"),		SO_NONE		},
	//
	{ OPT_MASKLAYOUT,	_T("-ml"),	 			SO_REQ_SEP	},
	{ OPT_MASKLAYOUT,	_T("--mask-layout"),	SO_REQ_SEP	},
	//
	{ OPT_KEYCOL,		_T("-key"),	 			SO_REQ_SEP	},
	{ OPT_KEYCOL,		_T("--key-colour"),		SO_REQ_SEP	},
	//
	{ OPT_KEYGUARD,		_T("-kg"),	 			SO_NONE		},
	{ OPT_KEYGUARD,		_T("--key-guard"),		SO_NONE		},
	//
	{ OPT_KEYGUARD,		_T("-kt"),	 			SO_REQ_SEP	},
	{ OPT_KEYGUARD,		_T("--key-tol"),		SO_REQ_SEP	},
	//
	{ OPT_SOURCE,		_T("-s"),	 			SO_REQ_SEP	},
	{ OPT_SOURCE,		_T("--src"), 			SO_REQ_SEP	},
	//
	{ OPT_CUTMODE,		_T("-cm"),	 			SO_REQ_SEP	},
	{ OPT_CUTMODE,		_T("--cutmode"), 		SO_REQ_SEP	},
	//
//	{ OPT_SPRITEGUIDE,	_T("-sg"),	 			SO_REQ_SEP	},
//	{ OPT_SPRITEGUIDE,	_T("--sprguide"), 		SO_REQ_SEP	},
	//
	{ OPT_SPROPT,		_T("-sopt"), 			SO_REQ_SEP	},
	{ OPT_SPROPT,		_T("--soptimize"),		SO_REQ_SEP	},
	{ OPT_SPROPT,		_T("--soptimise"),		SO_REQ_SEP	},
	//
	{ OPT_SPRXP,		_T("-sxp"),	 			SO_REQ_SEP	},
	{ OPT_SPRXP,		_T("--sprxpos"),		SO_REQ_SEP	},
	//
	{ OPT_SPRYP,		_T("-syp"),	 			SO_REQ_SEP	},
	{ OPT_SPRYP,		_T("--sprypos"),		SO_REQ_SEP	},
	//
	{ OPT_SPRXS,		_T("-sxs"),	 			SO_REQ_SEP	},
	{ OPT_SPRXS,		_T("--sprxsize"),		SO_REQ_SEP	},
	//
	{ OPT_SPRYS,		_T("-sys"),	 			SO_REQ_SEP	},
	{ OPT_SPRYS,		_T("--sprysize"),		SO_REQ_SEP	},
	//
	{ OPT_SPRXI,		_T("-sxi"),	 			SO_REQ_SEP	},
	{ OPT_SPRXI,		_T("--sprxinc"),		SO_REQ_SEP	},
	//
	{ OPT_SPRYI,		_T("-syi"),	 			SO_REQ_SEP	},
	{ OPT_SPRYI,		_T("--spryinc"),		SO_REQ_SEP	},
	//
	{ OPT_SPRXC,		_T("-sxc"),	 			SO_REQ_SEP	},
	{ OPT_SPRXC,		_T("--sprxcount"),		SO_REQ_SEP	},
	//
	{ OPT_SPRYC,		_T("-syc"),	 			SO_REQ_SEP	},
	{ OPT_SPRYC,		_T("--sprycount"),		SO_REQ_SEP	},
	//
	{ OPT_SPRCOUNT,		_T("-sc"),	 			SO_REQ_SEP	},
	{ OPT_SPRCOUNT,		_T("--sprcount"),		SO_REQ_SEP	},
	//
	{ OPT_TOLERANCE,	_T("-t"),	 			SO_REQ_SEP	},
	{ OPT_TOLERANCE,	_T("--tol"), 			SO_REQ_SEP	},
	//
	{ OPT_OUTMODE,		_T("-om"),	 			SO_REQ_SEP	},
	{ OPT_OUTMODE,		_T("--outmode"), 		SO_REQ_SEP	},
	//
	{ OPT_PALETTE,		_T("-p"),	 			SO_REQ_SEP	},
	{ OPT_PALETTE,		_T("--pal"),	 		SO_REQ_SEP	},
	//
	{ OPT_BITPLANES,	_T("-bp"),	 			SO_REQ_SEP	},
	{ OPT_BITPLANES,	_T("--bitplanes"), 		SO_REQ_SEP	},
	//
	SO_END_OF_OPTIONS
};

static void usage(int level)
{
	if (level >= 1) 
	{
		//std::cout << g_version_string << std::endl;
		std::cout << "built on " << __DATE__ << std::endl;
	}
		
	std::cout << "usage:" << std::endl;
	std::cout << " atgcut [opts] [infile]" << std::endl;
	std::cout << std::endl;
	std::cout << " -?, -h, --help       > show help/usage" << std::endl;
	std::cout << " -v, --verbose        > more output" << std::endl;
	std::cout << " -q, --quiet          > less output" << std::endl;
	std::cout << " -wk, --wait-key      > wait key on exit" << std::endl;
	std::cout << std::endl;
	std::cout << "general:" << std::endl;
	std::cout << " -s, --src            > source image containing tiles/sprites:" << std::endl;
	std::cout << "                      > pre-mapped: png,bmp (i.e. use indexed 4/8bit colour w/no remapping)" << std::endl;
	std::cout << "                      > unmapped:   png,bmp,jpg,psd,tga,gif,hdr,pic,ppm/pgm/pnm" << std::endl;
	std::cout << " -cm, --cutmode       > cutting mode: tiles,sprites" << std::endl;
	std::cout << " -p, --pal            > fixed palette to use: pi1,pal(riff),bmp,png" << std::endl;
	std::cout << " -bp, --bitplanes     > #bitplanes to generate: 1-8" << std::endl;
	std::cout << " -key, --key-colour   > colour index assumed to be transarent: 0-255" << std::endl;
	std::cout << " -kg, --key-guard     > guard against reducing colours to key colour" << std::endl;
	std::cout << " -kt, --key-tol       > key guard tolerance: 0.0+ (default: 0.01)" << std::endl;
	std::cout << std::endl;
	std::cout << "sprite cutting mode:" << std::endl;
	std::cout << " -sxp, --sprxpos      > first frame xpos: 0+" << std::endl;
	std::cout << " -syp, --sprypos      > first frame ypos: 0+" << std::endl;
	std::cout << " -sxs, --sprxsize     > all frames xsize: 1+" << std::endl;
	std::cout << " -sys, --sprysize     > all frames ysize: 1+" << std::endl;
	std::cout << " -sxi, --sprxinc      > x step for next frame in row: 0+" << std::endl;
	std::cout << " -syi, --spryinc      > y step for next row: 0+" << std::endl;
	std::cout << " -sxc, --sprxcount    > frames per row: 1+" << std::endl;
	std::cout << " -syc, --sprycount    > frames per column: 1+" << std::endl;
	std::cout << " -sc, --sprcount      > total frames to cut, if stopping early: 0+, where 0=ignore" << std::endl;
	std::cout << " -gm, --gen-mask      > generate 1bpl mask data along with colour data" << std::endl;
	std::cout << " -ml, --mask-layout   > mask layout strategy: interleaved,planar" << std::endl;
	std::cout << " -sopt, --soptimize   > optimize away unused pixels: on/off (compensated w/offsets)" << std::endl;
	std::cout << " -prv, --preview      > show ASCII preview of extracted colours + masking" << std::endl;
//	std::cout << " -sg, --sprguide      > sprite guide file (ASCII)" << std::endl;	// todo: maybe - only if its useful
	std::cout << std::endl;
	std::cout << "map & tile cutting mode:" << std::endl;
	std::cout << " -t, --tol            > tile matching tolerance: 0.0+" << std::endl;
	std::cout << " -om, --outmode       > tile library output mode: direct,degas" << std::endl;
	std::cout << std::endl;
	std::cout << "press any key..." << std::endl;
		
	getchar();	
	exit(1);
}

// --------------------------------------------------------------------
//	general argument handling
// --------------------------------------------------------------------

enum Outmode
{
	Outmode_DIRECT,
	Outmode_DEGAS
};

enum Cutmode
{
	Cutmode_TILES,
	Cutmode_SPRITES
};

enum Masklayout
{
	Masklayout_INTERLEAVED,
	Masklayout_PLANAR
};

class Arguments
{
public:

	Arguments()
		: verbose(false),
		  quiet(false),
		  waitkey(false),
		  spriteoptimize(true),
		  preview(false),
		  genmask(false),
		  keyguard(false),
		  tolerance(0.0f),
		  keytol(0.01f),
		  sourcefile("source.bmp"),
		  palettefile("palette.pi1"),
		  spriteguidefile("sprites.sgd"),
		  masklayout(Masklayout_INTERLEAVED),
		  cutmode(Cutmode_TILES),
		  outmode(Outmode_DEGAS),
		  planes(4),
		  keycol(0),
		  cut_xpos(0),
		  cut_ypos(0),
		  cut_xsize(16),
		  cut_ysize(16),
		  cut_xinc(16),
		  cut_yinc(16),
		  cut_xcount(1),
		  cut_ycount(1),
		  cut_count(0)
	{
	}

	bool verbose;
	bool quiet;
	bool waitkey;
	bool spriteoptimize;
	bool preview;
	bool genmask;
	bool keyguard;

	ubyte_t keycol;
	int cut_xpos;
	int cut_ypos;
	int cut_xsize;
	int cut_ysize;
	int cut_xinc;
	int cut_yinc;
	int cut_xcount;
	int cut_ycount;
	int cut_count;

	float tolerance;
	float keytol;
	std::string sourcefile;
	std::string spriteguidefile;
	Cutmode cutmode;
	Outmode outmode;
	Masklayout masklayout;
	std::string palettefile;
	int planes;
};

Arguments g_allargs;

static void GetArguments(int _argc, char **_argv, Arguments& _args)
{
    CSimpleOpt args(_argc, _argv, g_Options);
    std::string s_outfile;

    // while there are arguments left to process
    while (args.Next()) 
    {
		if (args.LastError() == SO_SUCCESS) 
		{
			if (args.OptionId() == OPT_HELP) 
			{
				usage(1);
			}
			else if (args.OptionId() == OPT_VERBOSE) 
			{
				_args.verbose = true;
			}
			else if (args.OptionId() == OPT_QUIET) 
			{
				_args.quiet = true;
			}
			else if (args.OptionId() == OPT_WAIT_KEY) 
			{
				_args.waitkey = true;
			}			
			else if (args.OptionId() == OPT_PREVIEW) 
			{
				_args.preview = true;
			}
			else if (args.OptionId() == OPT_GENMASK) 
			{
				_args.genmask = true;
			}	
			else if (args.OptionId() == OPT_KEYGUARD) 
			{
				_args.keyguard = true;
			}	
			//
			else if (args.OptionId() == OPT_SOURCE)
			{
				_args.sourcefile = args.OptionArg();
			}
			else if (args.OptionId() == OPT_TOLERANCE)
			{
				std::string s_arg = args.OptionArg();
				float farg = (float)atof(s_arg.c_str());
				if (farg < 0.0f || farg > 1e4f)
				{
					printf("error - invalid arg for tile matching tolerance: %s\n", s_arg.c_str());
					exit(1);
				}
				_args.tolerance = farg;	
			}
			else if (args.OptionId() == OPT_KEYTOL)
			{
				std::string s_arg = args.OptionArg();
				float farg = (float)atof(s_arg.c_str());
				if (farg < 0.0f || farg > 1e4f)
				{
					printf("error - invalid arg for key guard tolerance: %s\n", s_arg.c_str());
					exit(1);
				}
				_args.keytol = farg;	
			}
			else if (args.OptionId() == OPT_CUTMODE)
			{
				std::string s_arg = args.OptionArg();

				if (s_arg.find("tiles") != std::string::npos)
				{
					_args.cutmode = Cutmode_TILES;
				}
				else
				if (s_arg.find("sprites") != std::string::npos)
				{
					_args.cutmode = Cutmode_SPRITES;
				}
				else
				{
					printf("error - invalid arg for cutmode: %s\n", s_arg.c_str());
					exit(1);
				}
			}
			else if (args.OptionId() == OPT_OUTMODE)
			{
				std::string s_arg = args.OptionArg();

				if (s_arg.find("degas") != std::string::npos)
				{
					_args.outmode = Outmode_DEGAS;
					g_maxplanes = 4;
				}
				else
				if (s_arg.find("direct") != std::string::npos)
				{
					_args.outmode = Outmode_DIRECT;
					g_maxplanes = 8;
				}
				else
				{
					printf("error - invalid arg for outmode: %s\n", s_arg.c_str());
					exit(1);
				}
			}
			else if (args.OptionId() == OPT_MASKLAYOUT)
			{
				std::string s_arg = args.OptionArg();

				if (s_arg.find("planar") != std::string::npos)
				{
					_args.masklayout = Masklayout_PLANAR;
				}
				else
				if (s_arg.find("interleaved") != std::string::npos)
				{
					_args.masklayout = Masklayout_INTERLEAVED;
				}
				else
				{
					printf("error - invalid arg for masklayout: %s\n", s_arg.c_str());
					exit(1);
				}
			}
			else if (args.OptionId() == OPT_SPROPT)
			{
				std::string s_arg = args.OptionArg();

				if (s_arg.find("on") != std::string::npos)
				{
					_args.spriteoptimize = true;
				}
				else
				if (s_arg.find("off") != std::string::npos)
				{
					_args.spriteoptimize = false;
				}
				else
				{
					printf("error - invalid arg for sprite-optimize: %s\n", s_arg.c_str());
					exit(1);
				}
			}
			else if (args.OptionId() == OPT_PALETTE)
			{
				_args.palettefile = args.OptionArg();
			}
			//else if (args.OptionId() == OPT_SPRITEGUIDE)
			//{
			//	_args.spriteguidefile = args.OptionArg();
			//}
			else if (args.OptionId() == OPT_KEYCOL)
			{
				std::string s_arg = args.OptionArg();
				int iarg = atoi(s_arg.c_str());
				if (iarg < 0 || iarg > 255)
				{
					printf("error - invalid arg for key colour: %s\n", s_arg.c_str());
					exit(1);
				}
				_args.keycol = iarg;	
			}
			else if (args.OptionId() == OPT_BITPLANES)
			{
				std::string s_arg = args.OptionArg();
				int iarg = atoi(s_arg.c_str());
				if (iarg < 0 || iarg > g_maxplanes)
				{
					printf("error - invalid arg for tile matching tolerance: %s\n", s_arg.c_str());
					exit(1);
				}
				_args.planes = iarg;	
			}
			else if (args.OptionId() == OPT_SPRXP)
			{
				std::string s_arg = args.OptionArg();
				int iarg = atoi(s_arg.c_str());
				if (iarg < 0 || iarg > 4096)
				{
					printf("error - invalid arg for sprite cutting position: %s\n", s_arg.c_str());
					exit(1);
				}
				_args.cut_xpos = iarg;	
			}
			else if (args.OptionId() == OPT_SPRYP)
			{
				std::string s_arg = args.OptionArg();
				int iarg = atoi(s_arg.c_str());
				if (iarg < 0 || iarg > 4096)
				{
					printf("error - invalid arg for sprite cutting position: %s\n", s_arg.c_str());
					exit(1);
				}
				_args.cut_ypos = iarg;	
			}
			else if (args.OptionId() == OPT_SPRXS)
			{
				std::string s_arg = args.OptionArg();
				int iarg = atoi(s_arg.c_str());
				if (iarg < 1 || iarg > 4096)
				{
					printf("error - invalid arg for sprite cutting size: %s\n", s_arg.c_str());
					exit(1);
				}
				if (iarg > 128)
				{
					printf("warning - sprite cutting width %s exceeds max. of 128 for AGT spritesystem!\n", s_arg.c_str());
				}
				_args.cut_xsize = iarg;	
			}
			else if (args.OptionId() == OPT_SPRYS)
			{
				std::string s_arg = args.OptionArg();
				int iarg = atoi(s_arg.c_str());
				if (iarg < 1 || iarg > 4096)
				{
					printf("error - invalid arg for sprite cutting size: %s\n", s_arg.c_str());
					exit(1);
				}
				_args.cut_ysize = iarg;	
			}
			else if (args.OptionId() == OPT_SPRXI)
			{
				std::string s_arg = args.OptionArg();
				int iarg = atoi(s_arg.c_str());
				if (iarg < 0 || iarg > 4096)
				{
					printf("error - invalid arg for sprite cutting increment/step: %s\n", s_arg.c_str());
					exit(1);
				}
				_args.cut_xinc = iarg;	
			}
			else if (args.OptionId() == OPT_SPRYI)
			{
				std::string s_arg = args.OptionArg();
				int iarg = atoi(s_arg.c_str());
				if (iarg < 0 || iarg > 4096)
				{
					printf("error - invalid arg for sprite cutting increment/step: %s\n", s_arg.c_str());
					exit(1);
				}
				_args.cut_yinc = iarg;	
			}
			else if (args.OptionId() == OPT_SPRXC)
			{
				std::string s_arg = args.OptionArg();
				int iarg = atoi(s_arg.c_str());
				if (iarg < 1 || iarg > 1024)
				{
					printf("error - invalid arg for sprite cutting x-count: %s\n", s_arg.c_str());
					exit(1);
				}
				_args.cut_xcount = iarg;	
			}
			else if (args.OptionId() == OPT_SPRYC)
			{
				std::string s_arg = args.OptionArg();
				int iarg = atoi(s_arg.c_str());
				if (iarg < 1 || iarg > 1024)
				{
					printf("error - invalid arg for sprite cutting y-count: %s\n", s_arg.c_str());
					exit(1);
				}
				_args.cut_ycount = iarg;	
			}
		}
		else 
		{
			printf("error - invalid argument: %s\n", args.OptionText());
			exit(1);
		}
    }	 	
}


// --------------------------------------------------------------------
//	chunky (8bit) to N-planar conversion
// --------------------------------------------------------------------

static void c2p
(
	ubyte_t* _csrc, uword_t* _pdst, 
	signed short _w, signed short _h,
	signed short _sstride, signed short _dstride,
	signed short _nplanes
)
{	
	// v line loop
	for (signed short yc = 0; yc < _h; ++yc)
	{
		ubyte_t* src = &_csrc[yc * _sstride];
		uword_t* dst = &_pdst[yc * _dstride];
		
		// h word loop
		for (signed short xc = (_w >> 4) - 1; xc >= 0; --xc)
		{
			// h pixel loop				
			for (signed short xbc = 16-1; xbc >= 0; --xbc)
			{
				ubyte_t val = *(src++);
					
				// plane loop
				uword_t* o = dst;
				for (signed short p = _nplanes - 1; p >= 0; --p)
				{
					*(o) = (*(o) << 1) | (val & 1); val >>= 1; o++;
				}
			}
				
			// advance per word
			dst += _nplanes;
		}
	}
}	

// --------------------------------------------------------------------
//	palette reading: 24bit .PAL
// --------------------------------------------------------------------

static bool read_pal24(const char* _fname, RGB *&r_ppal, unsigned short& r_numcolours, unsigned short& r_numuniquecolors)
{
	// we only need this here, so why pollute?
	typedef struct bgra_s
	{
		ubyte_t red;
		ubyte_t green;
		ubyte_t blue;
		ubyte_t alpha;
	} bgra_t;

	FILE *hpal = fopen(_fname, "rb");
	if (hpal)
	{
		std::cout << "reading fixed palette source [" << _fname << "]" << std::endl;

		// yeah, i know...
		fseek(hpal, 4 + 4 + 4 + 4 + 4 + 2, 0);

		short numcolors = 0;
		fread(&numcolors, 2, 1, hpal);

		r_numcolours = numcolors;
		if (r_numcolours == 0)
		{
			fclose(hpal);
			return false;
		}

		{
			// read in the colors
			bgra_t *temp = new bgra_t[numcolors];
			fread(temp, 1, 4 * numcolors, hpal);
			fclose(hpal);

			// convert whatever colours we were able to read into local format
			r_ppal = new RGB[numcolors];
			for (int i = 0; i < numcolors; i++)
			{
				r_ppal[i].blue = temp[i].blue;
				r_ppal[i].green = temp[i].green;
				r_ppal[i].red = temp[i].red;
			}

			delete[] temp;
		}

		// count distinct colours (in case of duplicates)
		int u = r_numcolours;
		for (int o = 0; o < r_numcolours; o++)
		{
			for (int i = o + 1; i < r_numcolours; i++)
			{
				if ((r_ppal[o].red == r_ppal[i].red) &&
					(r_ppal[o].green == r_ppal[i].green) &&
					(r_ppal[o].blue == r_ppal[i].blue))
					{
						u--; break;
					}
			}
		}
		r_numuniquecolors = u;

		return true;
	}

	// not recognized/not found
	std::cerr << "error: can't open this palette file: " << _fname << std::endl;
	return false;
}

// --------------------------------------------------------------------
//	palette reading: 12bit .cct tileset files
// --------------------------------------------------------------------

static bool read_pal_cct(const char* _fname, RGB *&r_ppal, unsigned short& r_numcolours, unsigned short& r_numuniquecolours)
{
	FILE *hpal = fopen(_fname, "rb");
	if (hpal)
	{
		std::cout << "reading fixed palette source [" << _fname << "]" << std::endl;

		r_numcolours = 16;

		// read in the colors
		uword_t palette[16];
		//fread(palette, 1, 2, hpal);
		fread(palette, 1, 32, hpal);
		fclose(hpal);

		// convert whatever colours we were able to read into local format
		r_ppal = new RGB[16];

		for (int i = 0; i < 16; i++)
		{
			// reformat from bigendian for motorola->intel
			uword_t ste_col = endianswap16(palette[i]);

			word_t ste_r = (ste_col >> 8) & 0xF;
			word_t ste_g = (ste_col >> 4) & 0xF;
			word_t ste_b = (ste_col >> 0) & 0xF;

			// reformat STE swizzled 4:4:4 format into 24bit 8:8:8
			word_t r = ((ste_r & 0x7) << 1) | ((ste_r >> 3) & 1);
			word_t g = ((ste_g & 0x7) << 1) | ((ste_g >> 3) & 1);
			word_t b = ((ste_b & 0x7) << 1) | ((ste_b >> 3) & 1);

			r_ppal[i].red   = r << 4;
			r_ppal[i].green = g << 4;
			r_ppal[i].blue  = b << 4;
		}

		// count distinct colours (in case of duplicates)
		int u = r_numcolours;
		for (int o = 0; o < r_numcolours; o++)
		{
			for (int i = o + 1; i < r_numcolours; i++)
			{
				if ((r_ppal[o].red == r_ppal[i].red) &&
					(r_ppal[o].green == r_ppal[i].green) &&
					(r_ppal[o].blue == r_ppal[i].blue))
					{
						u--; break;
					}
			}
		}
		r_numuniquecolours = u;

		return true;
	}

	// not recognized/not found
	std::cerr << "error: can't open this image: " << _fname << std::endl;
	return false;
}

// --------------------------------------------------------------------
//	palette reading: 12bit .PI1
// --------------------------------------------------------------------

static bool read_pal_pi1(const char* _fname, RGB *&r_ppal, unsigned short& r_numcolours, unsigned short& r_numuniquecolours)
{
	FILE *hpal = fopen(_fname, "rb");
	if (hpal)
	{
		std::cout << "reading fixed palette source [" << _fname << "]" << std::endl;

		r_numcolours = 16;

		// read in the colors
		uword_t palette[16];
		fread(palette, 1, 2, hpal);
		fread(palette, 1, 32, hpal);
		fclose(hpal);

		// convert whatever colours we were able to read into local format
		r_ppal = new RGB[16];

		for (int i = 0; i < 16; i++)
		{
			// reformat from bigendian for motorola->intel
			uword_t ste_col = endianswap16(palette[i]);

			word_t ste_r = (ste_col >> 8) & 0xF;
			word_t ste_g = (ste_col >> 4) & 0xF;
			word_t ste_b = (ste_col >> 0) & 0xF;

			// reformat STE swizzled 4:4:4 format into 24bit 8:8:8
			word_t r = ((ste_r & 0x7) << 1) | ((ste_r >> 3) & 1);
			word_t g = ((ste_g & 0x7) << 1) | ((ste_g >> 3) & 1);
			word_t b = ((ste_b & 0x7) << 1) | ((ste_b >> 3) & 1);

			r_ppal[i].red   = r << 4;
			r_ppal[i].green = g << 4;
			r_ppal[i].blue  = b << 4;
		}

		// count distinct colours (in case of duplicates)
		int u = r_numcolours;
		for (int o = 0; o < r_numcolours; o++)
		{
			for (int i = o + 1; i < r_numcolours; i++)
			{
				if ((r_ppal[o].red == r_ppal[i].red) &&
					(r_ppal[o].green == r_ppal[i].green) &&
					(r_ppal[o].blue == r_ppal[i].blue))
					{
						u--; break;
					}
			}
		}
		r_numuniquecolours = u;

		return true;
	}

	// not recognized/not found
	std::cerr << "error: can't open this image: " << _fname << std::endl;
	return false;
}

// --------------------------------------------------------------------
//	wrappers for stb_image loader
// --------------------------------------------------------------------


// --------------------------------------------------------------------
//	load image, recovering indexed colour & palette if available
// --------------------------------------------------------------------

bool image_load(const char* filename, RGB *&r_psourcergb, unsigned char *&r_psourcecol, RGB *&r_ppalettergb, ulong_t &r_w, ulong_t &r_h, ulong_t &r_d)
{
	int stbx,stby,stbn;
	unsigned char *stbdata = stbi_load(filename, &stbx, &stby, &stbn, 3);

	if (stbdata)
	{
		int imagesize = stbx*stby;
		r_psourcergb = new RGB[imagesize];
		unsigned char* data = stbdata;
		for (int p = 0; p < imagesize; p++)
		{
			r_psourcergb[p].red = *data++;
			r_psourcergb[p].green = *data++;
			r_psourcergb[p].blue = *data++;
		}
		STBI_FREE(stbdata);

		if (g_stbi_colours)
		{
			r_ppalettergb = new RGB[256];
			for (int p = 0; p < g_stbi_colours; p++)
			{
				r_ppalettergb[p].red = g_stbi_palette[p][0];
				r_ppalettergb[p].green = g_stbi_palette[p][1];
				r_ppalettergb[p].blue = g_stbi_palette[p][2];
			}
		}

		r_psourcecol = g_stbi_colourmap;
		r_w = stbx;
		r_h = stby;
		r_d = g_stbi_bits;

		return true;
	}

	// not recognized/not found
	std::cerr << "error: can't open this image" << std::endl;
	return false;
}

// --------------------------------------------------------------------
//	load image, recovering ONLY the palette if available
// --------------------------------------------------------------------

bool palette_load(const char* filename, RGB *&r_ppal, unsigned short &r_numcolours, unsigned short &r_numuniquecolours)
{
	int stbx,stby,stbn;
	unsigned char *stbdata = stbi_load(filename, &stbx, &stby, &stbn, 3);

	if (stbdata)
	{
		// don't need pixel data
		STBI_FREE(stbdata);

		if (g_stbi_colours)
		{
			r_ppal = new RGB[256];
			for (int p = 0; p < g_stbi_colours; p++)
			{
				r_ppal[p].red = g_stbi_palette[p][0];
				r_ppal[p].green = g_stbi_palette[p][1];
				r_ppal[p].blue = g_stbi_palette[p][2];
			}

			r_numcolours = g_stbi_colours;

			// count distinct colours (in case of duplicates)
			int u = r_numcolours;
			for (int o = 0; o < r_numcolours; o++)
			{
				for (int i = o + 1; i < r_numcolours; i++)
				{
					if ((r_ppal[o].red == r_ppal[i].red) &&
						(r_ppal[o].green == r_ppal[i].green) &&
						(r_ppal[o].blue == r_ppal[i].blue))
					{
						u--; break;
					}
				}
			}
			r_numuniquecolours = u;

			return true;
		}

		// not indexed colour - no palette
		std::cerr << "error: non-indexed colour image or unsupported image type - no palette available" << std::endl;
		return false;
	}

	// not recognized/not found
	std::cerr << "error: can't open this image" << std::endl;
	return false;
}

// --------------------------------------------------------------------
//	tile dictionary stuff
// --------------------------------------------------------------------

typedef std::list<RGB*> tile24dictionary_t;
typedef std::list<ubyte_t*> tile8dictionary_t;
typedef std::list<uword_t*> tileplanardictionary_t;

tile24dictionary_t s_tile24dictionary;
tile8dictionary_t s_tile8dictionary;
tileplanardictionary_t s_tileplanardictionary;

// extract pixels from 8bit indexed tile data
static inline void extract_tile8(ubyte_t *_pdsttile, ubyte_t *_psrctile, ulong_t _sourcew)
{
	for (int py = 0; py < 16; py++)
	{
		for (int px = 0; px < 16; px++)
		{
			_pdsttile[(py << 4) + px] = _psrctile[(py * _sourcew) + px];
		}
	}
}

// extract pixels from 24bit TC tile data (for error comparison)
static inline void extract_tile24(RGB *_pdsttile, RGB *_psrctile, ulong_t _sourcew)
{
	for (int py = 0; py < 16; py++)
	{
		for (int px = 0; px < 16; px++)
		{
			_pdsttile[(py << 4) + px] = _psrctile[(py * _sourcew) + px];
		}
	}
}

// compare two 24bit tiles for similarity
static inline float compare_tile24(RGB *_pdsttile, RGB *_psrctile, ulong_t _sourcew)
{
	static const float c_n = 1.0f / 255.0f;

	float errsum = 0.0f;

	for (int py = 0; py < 16; py++)
	{
		for (int px = 0; px < 16; px++)
		{
			const RGB &spix = _psrctile[(py * _sourcew) + px];
			const RGB &dpix = _pdsttile[(py << 4) + px];

			float dr = float(spix.red   - dpix.red) * c_n;
			float dg = float(spix.green - dpix.green) * c_n;
			float db = float(spix.blue  - dpix.blue) * c_n;

			float err = (dr * dr) + (dg * dg) + (db * db);

			errsum += err;
		}
	}

	return errsum;
}

// --------------------------------------------------------------------
//	add tile to dictionary if it appears to be unique
// --------------------------------------------------------------------

static int process_tile(RGB *_psourcergb, ubyte_t *_psourcecol, ulong_t _sourcew, int _tx, int _ty)
{
	int mapindex = -1;

	// compare this tile with all tiles already in dictionary

	// address source tile in terms of tile coords
	RGB *psrctile24 = &_psourcergb[(_sourcew * (_ty << 4)) + (_tx << 4)];

	// configure nearest match to worst case before search
	tile24dictionary_t::iterator best_it24 = s_tile24dictionary.end();
	tile8dictionary_t::iterator best_it8 = s_tile8dictionary.end();
	float best_error = g_allargs.tolerance+(1e-7f);
	int best_index = -1;
	bool match = false;

	// run comparison against all tiles
	tile24dictionary_t::iterator it24 = s_tile24dictionary.begin();
	tile8dictionary_t::iterator it8 = s_tile8dictionary.begin();
	int index = 0;
	for (; it24 != s_tile24dictionary.end(); it24++, it8++, index++)
	{
		RGB *pdict24 = *it24;
		float match_error = compare_tile24(pdict24, psrctile24, _sourcew);

		// if this dictionary tile yields a closer match, track it
		if (match_error < best_error)
		{
			match = true;
			best_error = match_error;
			best_it24 = it24;
			best_it8 = it8;
			best_index = index;
		}
	}

	if (match)
	{
		// if match was found, consider it reused
		//		std::cout << "reused tile with match error @ " << best_error << std::endl;
		mapindex = best_index;
	}
	else
	{
		mapindex = s_tile8dictionary.size();

		// if no match was found, store tile as unique
		RGB *pnewtile24 = new RGB[16 * 16];
		ubyte_t *pnewtile8 = new ubyte_t[16 * 16];
		ubyte_t *psrctile8 = &_psourcecol[(_sourcew * (_ty << 4)) + (_tx << 4)];

		extract_tile24(pnewtile24, psrctile24, _sourcew);
		extract_tile8(pnewtile8, psrctile8, _sourcew);

		//		std::cout << "recorded unique tile " << s_tile8dictionary.size() << " @ " << _tx << "x" << _ty << " with match error > " << best_error << std::endl;
		s_tile24dictionary.push_back(pnewtile24);
		s_tile8dictionary.push_back(pnewtile8);
	}

	return mapindex;
}

// --------------------------------------------------------------------
//	process all map tiles from source image
// --------------------------------------------------------------------

static void process_image
(
	long_t *&r_ptilemap, int &r_tilemapw, int &r_tilemaph, 
	RGB *_psourcergb, ubyte_t *_psourcecol, ulong_t _sourcew, ulong_t _sourceh
)
{
	// find source dimensions in terms of tiles
	int tilew = _sourcew >> 4;
	int tileh = _sourceh >> 4;

	r_tilemapw = tilew;
	r_tilemaph = tileh;
	r_ptilemap = new long_t[tilew*tileh];

	long_t *ptilemap = r_ptilemap;

	// iterate over source tiles, left-to-right, top-to-bottom
	for (int ty = 0; ty < tileh; ty++)
	{
		for (int tx = 0; tx < tilew; tx++)
		{
			int tilemapindex = process_tile(_psourcergb, _psourcecol, _sourcew, tx, ty);
			*ptilemap++ = tilemapindex;

			if ((s_progress & 0x1F) == 0)
			{
				switch ((s_progress >> 5) & 3)
				{
					case 0: printf("|\r"); break;
					case 1: printf("/\r"); break;
					case 2: printf("-\r"); break;
					case 3: printf("\\\r"); break;
				}
			}
			s_progress++;
		}
	}

	int uniquetiles = s_tile8dictionary.size();
}

// --------------------------------------------------------------------
//	convert 8bit tiles to 8-plane for export (later chop to N planes)
// --------------------------------------------------------------------

static void remap_dictionary_tiles()
{
	std::cout << "converting " << s_tile8dictionary.size() << " 8-bit tiles into planar format..." << std::endl;

	tile8dictionary_t::iterator it8 = s_tile8dictionary.begin();
	for (; it8 != s_tile8dictionary.end(); it8++)
	{
		ubyte_t *ptile8 = *it8;

		uword_t *ptileplanar = new uword_t[16*8];

		// convert chunk 8-bit tiles into 8-planar format
		c2p
		(
			/*src=*/ptile8, /*dst*/ptileplanar,
			/*w=*/16, /*h=*/16,
			/*bytes_per_src_line=*/16, /*words_per_dst_line=*/8,
			/*planes=*/8
		);

		s_tileplanardictionary.push_back(ptileplanar);
	}

	std::cout << "...done" << std::endl;
}

// --------------------------------------------------------------------
//	emit .PI1 from 4-plane buffer & palette data
// --------------------------------------------------------------------

static void emit_pi1(uword_t *buffer4plane, RGB *_ppal24, int pi1_index)
{
	std::string fname("tiles");
	fname += ('0' + pi1_index);
	fname.append(".pi1");

	FILE *hout = fopen(fname.c_str(), "wb");
	if (hout)
	{
		uword_t palette4bit[16] = { 0x000, 0xfff, 0x111, 0x222, 0x333, 0x444, 0x555, 0x666, 0x777, 0x888, 0x999, 0xaaa, 0xbbb, 0xccc, 0xddd, 0xeee };

		for (int i = 0; i < 16; i++)
		{
			word_t r = word_t(_ppal24[i].red);
			word_t g = word_t(_ppal24[i].green);
			word_t b = word_t(_ppal24[i].blue);

			// reformat 24bit 8:8:8 into STE swizzled 4:4:4 format
			word_t ste_r = (r >> 5) | (((r >> 4) & 1) << 3);
			word_t ste_g = (g >> 5) | (((g >> 4) & 1) << 3);
			word_t ste_b = (b >> 5) | (((b >> 4) & 1) << 3);

			uword_t ste_col = uword_t((ste_r << 8) | (ste_g << 4) | ste_b);

			// reformat to bigendian for intel->motorola
			palette4bit[i] = endianswap16(ste_col);
		}

		// reformat image to bigendian for intel->motorola
		for (int i = 0; i < 16000; i++)
		{
			buffer4plane[i] = endianswap16(buffer4plane[i]);
		}

		// write header
		unsigned short v = 0;
		fwrite(&v, 1, 2, hout);

		// write palette
		fwrite(palette4bit, 1, 32, hout);

		// write buffer
		fwrite(buffer4plane, 1, 32000, hout);
		fclose(hout);

		std::cout << "emitted tilegroup [" << fname.c_str() << "]" << std::endl;
	}
}

// --------------------------------------------------------------------
//	colour reduction (fixed palette)
// --------------------------------------------------------------------

static ubyte_t s_colours_matched[256];
int s_num_colours_matched = 0;

static bool s_reducer_keycol_exact = true;

static inline ubyte_t match_colour(const RGB &rgb, RGB *_ppal, int _ncols)
{
	static const float c_n = 1.0f / 255.0f;

	float fr = float(rgb.red);
	float fg = float(rgb.green);
	float fb = float(rgb.blue);

	float best_err = 1e7;
	int best_hit = -1;
	for (int i = 0; i < _ncols; i++)
	{
		const RGB &pal = _ppal[i];

		float pr = float(pal.red /*+ 8*/);
		float pg = float(pal.green /*+ 8*/);
		float pb = float(pal.blue /*+ 8*/);

		// YUV error - meh
		//float dr = (fr - pr) * c_n * 0.299;
		//float dg = (fg - pg) * c_n * 0.587;
		//float db = (fb - pb) * c_n * 0.114;

		float dr = (fr - pr) * c_n;
		float dg = (fg - pg) * c_n;
		float db = (fb - pb) * c_n;

		float err = (dr * dr) + (dg * dg) + (db * db);

		// in exact mode, don't remap anything to keycol index unless its an exact colour match
		if (!g_allargs.keyguard ||
			(i != g_allargs.keycol) ||
			(err < g_allargs.keytol))
		{
			if (err < best_err)
			{
				best_err = err;
				best_hit = i;
			}
		}
	}

	if (s_colours_matched[best_hit] == 0)
	{
		s_colours_matched[best_hit] = 1;
		s_num_colours_matched++;
	}

	return (ubyte_t)best_hit;
}

// --------------------------------------------------------------------
//	reduce TC image to indexed colour using fixed palette
// --------------------------------------------------------------------

static void reduce_image24(RGB *_psourcergb, ubyte_t *_psrccol, ubyte_t *_pdstcol, ulong_t _sourcew, ulong_t _sourceh, RGB *&r_ppal)
{
	unsigned short r_numcolours = 0;
	unsigned short r_numuniquecolours = 0;
	bool success = false;

	if (g_allargs.palettefile.find(".pi1") != std::string::npos)
		success = read_pal_pi1(g_allargs.palettefile.c_str(), r_ppal, r_numcolours, r_numuniquecolours);
	else
	if (g_allargs.palettefile.find(".pal") != std::string::npos)
		success = read_pal24(g_allargs.palettefile.c_str(), r_ppal, r_numcolours, r_numuniquecolours);
	else
	if (g_allargs.palettefile.find(".cct") != std::string::npos)
		success = read_pal_cct(g_allargs.palettefile.c_str(), r_ppal, r_numcolours, r_numuniquecolours);
	else
	{
		std::cerr << " unrecognized palette format [" << g_allargs.palettefile.c_str() << "] so trying image handlers..." << std::endl;
		success = palette_load(g_allargs.palettefile.c_str(), r_ppal, r_numcolours, r_numuniquecolours);
		if (!success)
			std::cerr << "error: this image format can't be used to supply palettes currently" << std::endl;
	}

	if (success)
	{
		std::cout << " size of palette: " << r_numcolours << std::endl;
		std::cout << " unique 24bit colours available in palette: " << r_numuniquecolours << std::endl;
		if (r_numuniquecolours > (1 << g_allargs.planes))
			std::cout << " warning: target palette contains more colours than " << g_allargs.planes << " bitplanes can encode!" << std::endl;

		memset(s_colours_matched, 0, 256);

		{
			RGB *psrc = _psourcergb;
			ubyte_t *pdst = _pdstcol;
			for (int py = 0; py < (int)_sourceh; py++)
			{
				for (int px = 0; px < (int)_sourcew; px++)
				{
					*pdst++ = match_colour(*psrc++, r_ppal, r_numcolours);
				}
			}
		}

		std::cout << " indexed colours used in final image: " << s_num_colours_matched << std::endl;	
	}
	else
	{
		std::cerr << "error: could not read input palette from palette file or image" << std::endl;
		exit(1);
	}
	std::cout << "...done" << std::endl;
}

// --------------------------------------------------------------------
//	emit map data file indicating where tiles go in original image
// --------------------------------------------------------------------

static void emit_tilemap_ccm(const char* _fname, long_t *_ptilemap, int _tilemapw, int _tilemaph)
{
	long_t v;

	int mapentries = _tilemapw * _tilemaph;
	for (int i = 0; i < mapentries; i++)
		_ptilemap[i] = endianswap32(_ptilemap[i]);

	FILE *hmap = fopen(_fname, "wb");

	v = endianswap32(_tilemapw);
	fwrite(&v, 1, sizeof(v), hmap);
	v = endianswap32(_tilemaph);
	fwrite(&v, 1, sizeof(v), hmap);

	fwrite(_ptilemap, sizeof(long_t), mapentries, hmap);

	fclose(hmap);

	std::cout << "emitted tilemap [" << _fname << "]" << std::endl;
}

// --------------------------------------------------------------------
//	emit tile library as sequence of Degas .PI1 images
// --------------------------------------------------------------------

// emit tiles to a series of 320x200 .PI1 images
static void emit_tiles_degas(RGB *_ppalettergb)
{
	uword_t *buffer4plane = new uword_t[16000];
	memset(buffer4plane, 0, 32000);

	int pi1_index = 0;
	int otx = 0;
	int oty = 0;
	// emit PI1 images representing dictionary
	while (!s_tileplanardictionary.empty())
	{
		// copy 4 least significant planes to PI1 buffer
		uword_t *pin = s_tileplanardictionary.front();
		// find output tile address in 4-plane output buffer
		uword_t *pout = &buffer4plane[(otx<<2) + ((oty<<4) * (320>>(4-2)))];

		for (int ty = 0; ty < 16; ty++)
		{
			// record 4 planes
			*pout++ = *pin++;
			*pout++ = *pin++;
			*pout++ = *pin++;
			*pout++ = *pin++;
			// next line of PI1
			pout += (320>>(4-2)) - 4;
			// skip 4 planes of 8-plane tile
			pin += 4;
		}

		otx++;
		if (otx >= (320 / 16))
		{
			otx = 0;
			oty++;
			if (oty >= (200 / 16))
			{
				oty = 0;

				// flush image
				emit_pi1(buffer4plane, _ppalettergb, pi1_index++);
				memset(buffer4plane, 0, 32000);
			}
		}

		s_tileplanardictionary.pop_front();
	}

	// if some tiles are still pending, flush remainder
	if (otx > 0 || oty > 0)
		emit_pi1(buffer4plane, _ppalettergb, pi1_index++);

	delete[] buffer4plane;
}

// --------------------------------------------------------------------
//	emit tile library data file
// --------------------------------------------------------------------

static void emit_tiles_cct(RGB *_ppal24)
{
//	std::string filename("tiles.cct");

	// construct output filename: [infile.ccm]
	std::string outfile(g_allargs.sourcefile);
	size_t dot = outfile.find_last_of(".");
	if (dot != std::string::npos)
	{
		outfile = outfile.substr(0, dot);
		outfile.append(".cct");
	}

	FILE* h = fopen(outfile.c_str(), "wb");
	if (h)
	{
		// write palette (16*2)
		{
			uword_t palette4bit[16];

			for (int i = 0; i < 16; i++)
			{
				word_t r = word_t(_ppal24[i].red);
				word_t g = word_t(_ppal24[i].green);
				word_t b = word_t(_ppal24[i].blue);

				// reformat 24bit 8:8:8 into STE swizzled 4:4:4 format
				word_t ste_r = (r >> 5) | (((r >> 4) & 1) << 3);
				word_t ste_g = (g >> 5) | (((g >> 4) & 1) << 3);
				word_t ste_b = (b >> 5) | (((b >> 4) & 1) << 3);

				uword_t ste_col = uword_t((ste_r << 8) | (ste_g << 4) | ste_b);

				// reformat to bigendian for intel->motorola
				palette4bit[i] = endianswap16(ste_col);
			}

			fwrite(palette4bit, 1, sizeof(palette4bit), h);
		}

		// write flags (1)
		{
			byte_t flags = 0;
			fwrite(&flags, 1, sizeof(flags), h);
		}
		// write #bitplanes (1)
		{
			byte_t count = g_allargs.planes;
			fwrite(&count, 1, sizeof(count), h);
		}

		// write tile count (2)
		{
			word_t count = s_tileplanardictionary.size();
			count = endianswap16(count);
			fwrite(&count, 1, sizeof(count), h);
		}

		// write tiles (n)
		{
			uword_t tilespace[16*8];

			int tileplanes = g_allargs.planes;
			const int tilewords = tileplanes * 1 * 16;

			for (tileplanardictionary_t::iterator it = s_tileplanardictionary.begin(); it != s_tileplanardictionary.end(); it++)
			{
				uword_t *tile = *it;

				// extract planes
				uword_t *ptilespace = tilespace;
				for (int y = 0; y < 16; y++)
				{
					for (int p = 0; p < tileplanes; p++)
						*ptilespace++ = *tile++;
					tile += (8 - tileplanes);
				}

				// reformat image to bigendian for intel->motorola
				for (int i = 0; i < tilewords; i++)
					tilespace[i] = endianswap16(tilespace[i]);

				fwrite(tilespace, 1, (tilewords * 2), h);
			}
		}

		std::cout << "emitted tiles [" << outfile.c_str() << "]" << std::endl;

		fclose(h);
	}
}

// --------------------------------------------------------------------
//	map & tile cutting mode
// --------------------------------------------------------------------

bool do_tiles()
{
	ulong_t sourcew = 0;
	ulong_t sourceh = 0;
	ulong_t sourced = 0;
	RGB *m_psourcergb = 0;
	RGB *m_ppalettergb = 0;
	ubyte_t *m_psourcecol = 0;

	long_t *ptilemap = 0;
	int tilemapw = 0;
	int tilemaph = 0;

	std::cout << "map / tile cutting mode..." << std::endl;

	if (image_load(g_allargs.sourcefile.c_str(), m_psourcergb, m_psourcecol, m_ppalettergb, sourcew, sourceh, sourced))
	{
		if (1)
		{
			std::cout << "read [" << g_allargs.sourcefile.c_str() << "] with colour depth " << sourced << " and dimensions " << sourcew << " x " << sourceh << std::endl;

			if ((sourcew & (16 - 1)) || (sourceh & (16 - 1)))
			{
				std::cerr << "error: source image is not a multiple of 16 pixels on both axes - check the map!" << std::endl;
				exit(1);
			}

			if (m_psourcecol)
			{
				std::cout << "adopting palette and colourmap provided by source image..." << std::endl;
			}
			else
			{
				std::cout << "reducing 24bit image to external fixed palette..." << std::endl;
				m_psourcecol = new ubyte_t[sourcew * sourceh]; // (ubyte_t*)malloc(sourcew * sourceh);
				// reduce source image to indexed colour with fixed palette
				reduce_image24(m_psourcergb, 0, m_psourcecol, sourcew, sourceh, m_ppalettergb);
			}

			std::cout << "extracting unique tiles..." << std::endl;
			// generate tile dictionary from image
			process_image(ptilemap, tilemapw, tilemaph, m_psourcergb, m_psourcecol, sourcew, sourceh);
			std::cout << "...done" << std::endl;
			// calculate compressed footprint
			float footprint = (float)s_tile8dictionary.size() / float(tilemapw*tilemaph);
			std::cout << "final dictionary contains " << s_tile8dictionary.size() << " unique tiles with footprint @ " << footprint  << " of original image." << std::endl;

			if (footprint > 0.5f)
				std::cout << " tile reuse is terrible - source image was rendered in crayon by a womble" << std::endl;
			if (footprint > 0.3f)
				std::cout << " tile reuse is poor - check tile alignment at top left and lower right of source image" << std::endl;
			else
			if (footprint > 0.2f)
				std::cout << " tile reuse is fair - but carefully recheck tile alignment to be sure?" << std::endl;
			else
			if (footprint > 0.1f)
				std::cout << " tile reuse seems ok but keep an eye on things..." << std::endl;
			else
				std::cout << " tile reuse is good! > l33t mapping 5ki11z <" << std::endl;

			// convert 8bit indexed tiles into 4-plane graphics
			remap_dictionary_tiles();

			if (g_allargs.outmode == Outmode_DEGAS)
			{
				// emit tiles to a series of 320x200 .PI1 images
				emit_tiles_degas(m_ppalettergb);
			}
			else
			if (g_allargs.outmode == Outmode_DIRECT)
			{
				emit_tiles_cct(m_ppalettergb);
			}

			if (m_psourcergb)
				delete[] m_psourcergb;
			if (m_psourcecol)
				delete[] m_psourcecol;
			if (m_ppalettergb)
				delete[] m_ppalettergb;

			if (ptilemap)
			{
				// construct output filename: [infile.ccm]
				std::string outfile(g_allargs.sourcefile);
				size_t dot = outfile.find_last_of(".");
				if (dot != std::string::npos)
				{
					outfile = outfile.substr(0, dot);
					outfile.append(".ccm");
				}

				emit_tilemap_ccm(outfile.c_str(), ptilemap, tilemapw, tilemaph);
			}
		}
		else
		{
			std::cerr << "error: could not decode [" << g_allargs.sourcefile.c_str() << "] source image" << std::endl;
		}
	}
	else
	{
		std::cerr << "error: could not open [" << g_allargs.sourcefile.c_str() << "] source file" << std::endl;
	}

	return true;
}

// --------------------------------------------------------------------
//	sprite cutting storage
// --------------------------------------------------------------------

// todo: tidy this up!

static ubyte_t *g_colrbuffer8 = 0;
static uword_t *g_colrbufferbpl = 0;

static ubyte_t *g_maskbuffer8 = 0;
static uword_t *g_maskbufferbpl = 0;

static int g_sprite_bpwidth = 0;
static int g_sprite_width = 0;
static int g_sprite_height = 0;
static int g_spritesource_w = 0;
static int g_spritesource_h = 0;


class spriteframe_t
{
public:

	word_t w_, h_;
	word_t xo_, yo_;
	uword_t *mask_;
	uword_t *colr_;

	spriteframe_t(int _w, int _h, int _xo, int _yo, uword_t *_mask, uword_t *_colr)
		: w_(_w),
		  h_(_h),
		  xo_(_xo),
		  yo_(_yo),
		  mask_(_mask),
		  colr_(_colr)
	{
	}

	~spriteframe_t()
	{
		// do not delete here - no refcounting on allocations happening within STL container
	}

	void release()
	{
		delete[] mask_; mask_ = 0;
		delete[] colr_; colr_ = 0;
	}
};

typedef std::list<spriteframe_t> spritelist_t;

// todo: tidy this up!

spritelist_t g_spriteframes;

int g_sprite_framewidth;
int g_sprite_frameheight;
int g_sprite_framebpwidth;

// --------------------------------------------------------------------
//	prepare sprite cutting sequence
// --------------------------------------------------------------------

void init_sprite_sequence(int _xs, int _ys, int _sw, int _sh)
{
	for (spritelist_t::iterator it = g_spriteframes.begin(); it != g_spriteframes.end(); it++)
		it->release();

	g_spriteframes.clear();

	g_spritesource_w = _sw;
	g_spritesource_h = _sh;

	// sprite width in bitplane words
	g_sprite_bpwidth = (_xs + (16-1)) & -16;
	g_sprite_width = _xs;
	g_sprite_height = _ys;


	// allocate sprite buffer for chunky processing (default to keycol)
	delete[] g_colrbuffer8;
	g_colrbuffer8 = new ubyte_t[g_sprite_bpwidth * g_sprite_height];
	memset(g_colrbuffer8, g_allargs.keycol, g_sprite_bpwidth * g_sprite_height);

	// allocate sprite buffer for bitplane processing
	delete[] g_colrbufferbpl;
	g_colrbufferbpl = new uword_t[(g_sprite_bpwidth * g_sprite_height) >> 1];
	memset(g_colrbufferbpl, 0, g_sprite_bpwidth * g_sprite_height);


	// allocate mask buffer for chunky processing (default to transparency)
	delete[] g_maskbuffer8;
	g_maskbuffer8 = new ubyte_t[g_sprite_bpwidth * g_sprite_height];
	memset(g_maskbuffer8, 0xFF, g_sprite_bpwidth * g_sprite_height);

	// allocate mask buffer for bitplane processing
	delete[] g_maskbufferbpl;
	g_maskbufferbpl = new uword_t[(g_sprite_bpwidth * g_sprite_height) >> 1];
	memset(g_maskbufferbpl, 0, g_sprite_bpwidth * g_sprite_height);
}

// --------------------------------------------------------------------
//	cut a single frame from source image
// --------------------------------------------------------------------

void add_sprite_frame(ubyte_t* _psource8, int _x, int _y)
{
	memset(g_colrbuffer8, g_allargs.keycol, g_sprite_bpwidth * g_sprite_height);
	memset(g_maskbuffer8, 0xFF, g_sprite_bpwidth * g_sprite_height);

	int cxmin = 0;
	int cymin = 0;
	int cxmax = g_sprite_width;
	int cymax = g_sprite_height;

	if (g_allargs.preview)
	{
		printf("\n");
		for (int py = 0; py < g_sprite_height; py++)
		{
			printf("\t");
			for (int px = 0; px < g_sprite_width; px++)
			{
				ubyte_t c = _psource8[((py + _y) * g_spritesource_w) + (px + _x)];

				if (c == g_allargs.keycol)
					printf("   ");
				else
					printf("%02x ", (int)c);
			}
			printf("\n");
		}
		printf("\n");
	}

	if (g_allargs.spriteoptimize)
	{
		cxmin = g_sprite_width;
		cymin = g_sprite_height;
		cxmax = 0;
		cymax = 0;

		// optimize cutting area

		for (int py = 0; py < g_sprite_height; py++)
		{
			for (int px = 0; px < g_sprite_width; px++)
			{
				ubyte_t c = _psource8[((py + _y) * g_spritesource_w) + (px + _x)];

				if (c != g_allargs.keycol)
				{
					// opaque pixel - adjust bounds
					cxmin = xmin(cxmin, px);
					cxmax = xmax(cxmax, px + 1);
					cymin = xmin(cymin, py);
					cymax = xmax(cymax, py + 1);
				}
			}
		}
	}

	// capture at least one pixel per frame
	if ((cxmax < cxmin) || (cymax < cymin))
	{
		cxmin = 0;
		cxmax = 1;
		cymin = 0;
		cymax = 1;
	}

	g_sprite_framewidth = cxmax - cxmin;
	g_sprite_frameheight = cymax - cymin;
	g_sprite_framebpwidth = (g_sprite_framewidth + (16-1)) & -16;

	// cut chunky sprite to chunky colrbuffer & maskbuffer

	for (int psy = cymin, py = 0; psy < cymax; psy++, py++)
	{
		for (int psx = cxmin, px = 0; psx < cxmax; psx++, px++)
		{
			ubyte_t c = _psource8[((psy + _y) * g_spritesource_w) + (psx + _x)];

			// colour buffer receives actual colour, or 0 for keycol (so two colours can potentially map to 0)
			g_colrbuffer8[(py * g_sprite_framebpwidth) + px] = (c == g_allargs.keycol) ? 0x00 : c;
			// mask buffer receives 0 for colour, or 1 for keycol
			g_maskbuffer8[(py * g_sprite_framebpwidth) + px] = (c == g_allargs.keycol) ? 0xFF : 0x00;
		}
	}

	// chunky buffer -> planar buffer

	// colour component
	c2p
	(
		/*src=*/g_colrbuffer8, /*dst*/g_colrbufferbpl,
		/*w=*/g_sprite_framebpwidth, /*h=*/g_sprite_frameheight,
		/*bytes_per_src_line=*/g_sprite_framebpwidth, /*words_per_dst_line=*/g_sprite_framebpwidth>>1,
		/*planes=*/8	//g_allargs.planes
	);

	// mask component
	c2p
	(
		/*src=*/g_maskbuffer8, /*dst*/g_maskbufferbpl,
		/*w=*/g_sprite_framebpwidth, /*h=*/g_sprite_frameheight,
		/*bytes_per_src_line=*/g_sprite_framebpwidth, /*words_per_dst_line=*/g_sprite_framebpwidth>>1,
		/*planes=*/8	//g_allargs.planes
	);

	// generate the sprite data

	size_t spriteplane_wordsize = (g_sprite_framebpwidth >> 4) * g_sprite_frameheight;

	uword_t *maskdata = new uword_t[spriteplane_wordsize * 1];
	uword_t *colrdata = new uword_t[spriteplane_wordsize * g_allargs.planes];

	// copy mask data - just need one plane of the 8 we converted!
	for (size_t v = 0; v < spriteplane_wordsize; v++)
	{
		maskdata[v] = g_maskbufferbpl[v << 3];
	}

	// copy plane data - need N planes of the 8 we converted
	{
		int s = 0;
		int d = 0;
		for (size_t v = 0; v < spriteplane_wordsize; v++, s += 8, d += g_allargs.planes)
		{
			for (int p = 0; p < g_allargs.planes; p++)
				colrdata[d + p] = g_colrbufferbpl[s + p];
		}
	}

	std::cout << "created sprite frame " << g_spriteframes.size() << " from offset [" << cxmin << ", " << cymin << "] size [" << g_sprite_framewidth << " x " << g_sprite_frameheight << "]" << std::endl;
	g_spriteframes.push_back(spriteframe_t(g_sprite_framewidth, g_sprite_frameheight, cxmin, cymin, maskdata, colrdata));
}

// --------------------------------------------------------------------
//	emit .sps spritesheet sequence file
// --------------------------------------------------------------------

bool emit_spritesequence()
{
	std::string fname("sprites");
	fname.append(".sps");

	FILE *hout = fopen(fname.c_str(), "wb");
	if (hout)
	{
		word_t wb;
		word_t wv;
		long_t lv;
		int tracked_filesize = 0;

		std::vector<int> sprite_index;

		// 4: size of file remaining (patched before closing)
		lv = 0;
		fwrite(&lv, 1, 4, hout);

		// 2: version info
		wv = endianswap16(SPS_VERSION);
		fwrite(&wv, 1, 2, hout); tracked_filesize += 2;

		// 2: number of sprite frames in sequence
		wv = endianswap16((uword_t)g_spriteframes.size());
		fwrite(&wv, 1, 2, hout); tracked_filesize += 2;

		// 2: number of bitplanes in sprite data
		wv = endianswap16(g_allargs.planes);
		fwrite(&wv, 1, 2, hout); tracked_filesize += 2;

		// 2: flags
		// 0 0 0 0 0 0 0 0 0 0 0 0 0 L L M
		// M	mask present (1bpl mask data before colour data)
		// LL	mask layout mode (00=interleaved, 01=planar)
		wv = 0;
		wv |= (g_allargs.genmask) ? 1 : 0;
		wv |= (g_allargs.genmask && (g_allargs.masklayout == Masklayout_PLANAR)) ? 2 : 0;
		wv = endianswap16((uword_t)wv);
		fwrite(&wv, 1, 2, hout); tracked_filesize += 2;

		// 1: preshift range
		wb = 0;
		fwrite(&wb, 1, 1, hout); tracked_filesize += 1;
		// 1: preshift step
		wb = 0;
		fwrite(&wb, 1, 1, hout); tracked_filesize += 1;

		// 2: source width
		wv = endianswap16((uword_t)g_sprite_width);
		fwrite(&wv, 1, 2, hout); tracked_filesize += 2;
		// 2: source height
		wv = endianswap16((uword_t)g_sprite_height);
		fwrite(&wv, 1, 2, hout); tracked_filesize += 2;

		// create sprite index (patched before closing)
		int sprite_index_fpos = tracked_filesize;
		lv = 0xBBBBBBBB;
		for (spritelist_t::iterator it = g_spriteframes.begin(); it != g_spriteframes.end(); it++)
		{
			fwrite(&lv, 1, 4, hout); tracked_filesize += 4;
		}

		// individual sprites follow
		for (spritelist_t::iterator it = g_spriteframes.begin(); it != g_spriteframes.end(); it++)
		{
			// record file-offset to sprite in sprite index, for patching later
			sprite_index.push_back(tracked_filesize);

			// 2: sprite frame pixel width
			wv = endianswap16(it->w_);
			fwrite(&wv, 1, 2, hout); tracked_filesize += 2;
			// 2: sprite frame pixel height
			wv = endianswap16(it->h_);
			fwrite(&wv, 1, 2, hout); tracked_filesize += 2;

			// 2: sprite frame xoff
			wv = endianswap16(it->xo_);
			fwrite(&wv, 1, 2, hout); tracked_filesize += 2;
			// 2: sprite frame yoff
			wv = endianswap16(it->yo_);
			fwrite(&wv, 1, 2, hout); tracked_filesize += 2;

			// width of plane in words
			int wordwidth = (it->w_ + (16 - 1)) >> 4;
			// size of plane in words
			int planewords = wordwidth * it->h_;

			// write mask,colr[n] words

			// in planar-mask mode, we emit the entire mask before the colour data planes
			if (g_allargs.genmask && (g_allargs.masklayout == Masklayout_PLANAR))
			{
				for (int o = 0; o < planewords; o++)
				{
					// write mask plane data
					wv = endianswap16(it->mask_[o]);
					fwrite(&wv, 1, 2, hout); tracked_filesize += 2;
				}
			}

			for (int o = 0; o < planewords; o++)
			{
				if (g_allargs.genmask && (g_allargs.masklayout == Masklayout_INTERLEAVED))
				{
					// write interleaved mask word BEFORE each group of colour plane words
					wv = endianswap16(it->mask_[o]);
					fwrite(&wv, 1, 2, hout); tracked_filesize += 2;
				}

				// write colour words for N planes
				for (int p = 0; p < g_allargs.planes; p++)
				{
					wv = endianswap16(it->colr_[(o*g_allargs.planes)+p]);
					fwrite(&wv, 1, 2, hout); tracked_filesize += 2;
				}
			}
		}

		// patch sprite index
		lv = 0;
		fseek(hout, sprite_index_fpos+4, 0);
		for (std::vector<int>::iterator it = sprite_index.begin(); it != sprite_index.end(); it++)
		{
			lv = (*it) - sprite_index_fpos;
			lv = endianswap32(lv);
			fwrite(&lv, 1, 4, hout);
		}

		// patch filesize
		fseek(hout, 0, 0);
		lv = endianswap32(tracked_filesize);
		fwrite(&lv, 1, 4, hout);
	}

	std::cout << "emitted sprite sequence [" << fname.c_str() << "]" << std::endl;

	return true;
}

// --------------------------------------------------------------------
//	spritesheet mode
// --------------------------------------------------------------------

bool do_spritesheet()
{
	ulong_t sourcew = 0;
	ulong_t sourceh = 0;
	ulong_t sourced = 0;
	RGB *m_psourcergb = 0;
	RGB *m_ppalettergb = 0;
	ubyte_t *m_psourcecol = 0;
	ubyte_t *m_poriginalsrccol = 0;

	std::cout << "spritesheet cutting mode..." << std::endl;
	{
		if (image_load(g_allargs.sourcefile.c_str(), m_psourcergb, m_psourcecol, m_ppalettergb, sourcew, sourceh, sourced))
		{
			std::cout << "read [" << g_allargs.sourcefile.c_str() << "] with colour depth " << sourced << " and dimensions " << sourcew << " x " << sourceh << std::endl;

			if (m_psourcecol)
			{
				int maxcolidx = 1 << g_allargs.planes;
				// check that indexed colours are in range for bitplanes specified
				for (size_t p = 0; p < sourcew*sourceh; p++)
				{
					if (m_psourcecol[p] >= maxcolidx)
					{
						std::cout << "warning: source image is indexed, but values exceed target bitplane count: remapping..." << std::endl;
						// ignore colourmap
						m_poriginalsrccol = m_psourcecol;
						m_psourcecol = 0;
						break;
					}
				}

				std::cout << "adopting palette and colourmap provided by source image..." << std::endl;
			}

			if (!m_psourcecol)
			{
				std::cout << "reducing 24bit image to external fixed palette..." << std::endl;
				m_psourcecol = new ubyte_t[sourcew * sourceh]; //(ubyte_t*)malloc(sourcew * sourceh);
				// reduce source image to indexed colour with fixed palette
				reduce_image24(m_psourcergb, m_poriginalsrccol, m_psourcecol, sourcew, sourceh, m_ppalettergb);
			}

			// sprite cutting loop
			{
				// either cut a rectangular grid of frames based on ycount,xcount
				// or, if specified, stop cutting when a total count is reached instead
				int cuts;
				if (g_allargs.cut_count)
					cuts = g_allargs.cut_count;
				else
					cuts = g_allargs.cut_xcount * g_allargs.cut_ycount;

				int cutting_source_xs = g_allargs.cut_xsize;
				int cutting_source_ys = g_allargs.cut_ysize;

				std::cout << "sprite dimensions [" << cutting_source_xs << ", " << cutting_source_ys << "]" << std::endl;

				init_sprite_sequence(cutting_source_xs, cutting_source_ys, sourcew, sourceh);

				int cutting_source_x = g_allargs.cut_xpos;
				int cutting_source_y = g_allargs.cut_ypos;

				for (int s = 0, xc = 0; s < cuts; s++, xc++)
				{
					std::cout << "cutting sprite frame " << s << " from position [" << cutting_source_x << ", " << cutting_source_y << "]" << std::endl;

					add_sprite_frame(m_psourcecol, cutting_source_x, cutting_source_y);

					cutting_source_x += g_allargs.cut_xinc;

					if (xc >= g_allargs.cut_xcount)
					{
						// reset row when cut_xcount expires
						xc = 0;
						cutting_source_x = g_allargs.cut_xpos;
						cutting_source_y += g_allargs.cut_yinc;
					}
				}

				std::cout << "...done" << std::endl;
			}

			// create sprite datafile

			emit_spritesequence();
		}
	}

	return true;
}

// --------------------------------------------------------------------
//	main program entrypoint
// --------------------------------------------------------------------

int main(int argc, char* argv[])
{
	std::cout << "Atari GameTools: map, tile & sprite cutter " << g_version_string << " / dml" << std::endl;

	GetArguments(argc, argv, g_allargs);

	if (g_allargs.cutmode == Cutmode_TILES)
		do_tiles();
	else
	if (g_allargs.cutmode == Cutmode_SPRITES)
		do_spritesheet();
}

