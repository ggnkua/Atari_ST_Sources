
typedef struct
{
	void *start, *pos ;
	int x, y, w, h ;
	int bpl ;
	int bpp ;
} WINDOW ;

# define VRAMdefault (void *)0xfe000000L
# define DXdefault	832
# define DYdefault	608
# define BPPdefault	 32
# define BPLdefault	DXdefault*(BPPdefault/8)

# define DEFAULTwindow { VRAMdefault, VRAMdefault, 0, 0, DXdefault, DYdefault, BPLdefault, BPPdefault }

