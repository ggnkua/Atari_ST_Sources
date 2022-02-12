/* Constants used by the Memory Manager. */

#define ZEROBUF_SIZE	1024	/* buffer size for erasing memory */

/* Size of MM's stack depends mostly on do_exec(). */
#if (ZEROBUF_SIZE > MAX_PATH)
#define MM_STACK_BYTES	(ARG_MAX + ZEROBUF_SIZE + 192 *sizeof (char *))
#else
#define MM_STACK_BYTES	(ARG_MAX + MAX_PATH + 192 * sizeof (char *))
#endif

#define NO_MEM (phys_clicks)0	/* returned by alloc_mem() with mem is up */

/*DEBUG*/
/* PAGE_SIZE should be SEGMENT_GRANULARITY and MAX_PAGES MAX_SEGMENTS.
 * The 386 segment granularity is 1 for segments smaller than 1M and 4096
 * above that.  This is not handled properly yet - assume small programs.
 */
#if (CHIP == INTEL && !INTEL_32BITS)
#define PAGE_SIZE	  16	/* how many bytes in a page (s.b.HCLICK_SIZE)*/
#define MAX_PAGES       4096	/* how many pages in the virtual addr space */
#endif

#define HDR_SIZE	  32	/* # bytes in the exec file header */
#define printf        printk

#define INIT_PID	   1	/* init's process id number */
