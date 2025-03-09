

/* das ist meine Datenstruktur */
struct myrecord {
        struct myrecord *meinZeiger;
        long            meineZahl;
        int             meinIndex;
};

typedef struct myrecord    *MYrec;


MYrec 	mkrec(void);
void		freemem(long size, long *ptr);