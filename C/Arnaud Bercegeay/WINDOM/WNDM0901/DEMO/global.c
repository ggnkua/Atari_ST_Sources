#include <stddef.h> /* for NULL definition */
#include <windom.h>

struct _param {
	OBJECT *desk;
	WINDOW *winuser;
	int setup;
	int	FrameWidth;
	int FrameColor;
} param = { NULL, NULL, 0, 0, LWHITE};
