/* help for debugging, use special ttp.s */

#define super(stk) trap(1, 0x20, stk)

struct dump {
	long	magic;
	long	data[8];
	long	addr[8];
	long 	pc;
	long	usp;
	int	stk[4];
	int	status;
	long	upc;
	int	more[8];
} d;

struct header {
	short	magic;
	long	text;
	long	data;
	long	bss;
	long	sym;
	long	rsvd0;
	long	rsvd1;
	short	rsvd2;
} h;

struct sym {
	char 	name[8];
	short	type;
	long	value;
} s;

long	tpa, upc;

main(argc, argv) char *argv[]; {
	extern long *_estk;
	printf("tpa=%lx\n", tpa = *_estk);
	getdump();
	showdump();
	if (argc > 1)
		getfnc(argv[1], upc - (tpa + 0x100));
}

getdump() {
	long stk;
	char *src, *dst;
	int sz;
	stk = super(0L);
	mcopy(&d, 0x380L, sizeof d);
	super(stk);
}

showdump() {
	int i;
	long n;
	if (d.magic != 0x12345678) {
		printf("no dump available\n");
		return;
	}
	printf("exception #%d\n", (short)(d.pc >> 24));
	printf("   data     address\n");
	for (i = 0; i < 8; i++)
		printf("%d: %8lx %8lx\n", i, d.data[i], d.addr[i]);
	printf("pc=%lx usp=%lx upc=%lx\n", 
		d.pc & 0xFFFFFF, d.usp, upc = d.upc);
}

getfnc(name, pc) char *name; long pc; {
	int fd;
	long n, lseek();
	struct sym fnc;
	if ((fd = open(name, 0)) < 0)
		printf("can't open %s\n", name);
	else if (read(fd, &h, sizeof h) != sizeof h)
		printf("can't read header of %s\n", name);
	else if (h.sym == 0L)
		printf("no symbols in %s\n", name);
	else if (lseek(fd, h.text+h.data, 1) < 0L)
		printf("premature EOF on %s\n", name);
	else	{
		*fnc.name = 0;
		fnc.value = 0;
		for (n = h.sym; n > 0; n -= sizeof s) {
			read(fd, &s, sizeof s);
			if (s.value > fnc.value && s.value <= pc)
				mcopy(&fnc, &s, sizeof fnc);
		}
		printf("bug at %ld words after '%s'\n",
			pc - fnc.value, fnc.name);
	}
}

mcopy(dst, src, sz) char *dst, *src; {
	while (sz--) *dst++ = *src++;
}
