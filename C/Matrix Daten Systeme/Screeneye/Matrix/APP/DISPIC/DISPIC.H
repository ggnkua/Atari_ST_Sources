/* flags	*/

# define CLEARscreen	0x0001
# define LOADpalette	0x0002
# define BLITrect		0x0004
# define MASKcolor		0x0008
# define REPLcolor		0x0010
# define ROTATEblit		0x0020

/* error numbers	*/

# define DISPIerrBase	700

# define GETpathError	701
# define SETpathError	702
# if 0
# define ???			703
# endif
# define FORvarUndef	704
# define CALLstackOver	705
# define CALLstackUnder	706
# define EXECerror		707

# define ILLfontPath	708
# define NOfontPath		709
# define NOTimplFtype	710
# define ILLzoom		711
# define ILLcxxVersion	712
# define ILLt16Format	713
# define ILLrgb16Format	714

# define MAXdispiError	715
