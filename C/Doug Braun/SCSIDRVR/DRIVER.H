
/* This is the driver header. It must be at the very beginning */
struct bheader {
    int link1;
	int link2;
	int attribute;
	void (*strat_func)();
	void (*intr_func)();
	char nunits;
	char reserved[7];
};

struct cheader {
    int link1;
	int link2;
	int attribute;
	void (*strat_func)();
	void (*intr_func)();
	char name[8];
};

/* A BIOS parameter block */
struct bpb {
    unsigned secsiz;
	char clustersize;
	unsigned nreserved;
	char nfats;
	unsigned nrootdirs;
	unsigned nsectors;
	char mdescriptor;
	unsigned secsperfat;
	char scratch[512];
};


struct boot_sector {
	char filler1[3];
	char disk_name[8];
	struct bpb disk_bpb;
	unsigned spt;
	unsigned nheads;
	unsigned nhidden;
	char filler2[512-30];
};


/* The request header */
struct reqhdr {
    char rlength;
	char unit;
	char command;
	int status;
	char reserve[8];
	char media;
	char far *address;
	unsigned count;
	unsigned sector;
	char padding[4];
};

