
struct driver {
	long address;
	short planes;
	short bytesperline;
	short width;			/* in pixels */
	short height;			/* in pixels */
	short font;				/* MUST BE -1 for now */
	short (*init)(void);	/* function pointer */
	char gem,tos;			/* 0 means not in use, 1 means in use */
	long start;				/* start of r/w RAM */
	long end;				/* last adress+1 */
};
