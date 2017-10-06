typedef struct {
	 unsigned char *data;
	 long bytes_per_line;
} XImage;

typedef struct {
	long width;
	long height;
	long depth;	
} Display;

typedef struct {
	long width;
	long height;
	long depth;	
}  XWindowAttributes;


typedef struct {
	long xxx;
	
} GC;

typedef struct {
	long xxx;
	
} Colormap;

typedef struct {
	long xxx;
	
} XShmSegmentInfo;

typedef struct {
	long xxx;
	
} XErrorEvent;

typedef struct {
	long depth;
}XVisualInfo;

#define True 1
#define Bool long

#define Pixmap long
#define Drawable long
#define XID long

#define GLXDrawable Drawable
#define Font long
#define XColor long

#define malloc _malloc