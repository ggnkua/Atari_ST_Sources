/*
 * Helper functions and their variables for the VDI test-suite
 */

#ifdef __PUREC__	/* AHCC & Pure-C */
# include <vdi.h>
#else			/* GCC & VBCC GEMLIB */
# include <gem.h>
#endif

#define ARRAY_ITEMS(arr) (sizeof(arr)/sizeof(arr[0]))

typedef struct {
	short w, h;
	short colors;
	short planes;
	short multitos;
} screen_t;

extern screen_t screen;

extern short vdi_handle;

extern void work_open(void);
extern void work_clear(void);
extern void work_close(void);

extern void wait_key(void);
