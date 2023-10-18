/* PUN_INFO holen (Funktion zum Einbinden in eigene Programme)

typedef struct {
int             puns;
unsigned char   pun[16];
unsigned long   part_start[16];
long            P_cookie;
long            *P_cookptr;
unsigned int    P_version;
unsigned int    P_max_sector;
} PUN_INFO;

PUN_INFO *GetPunPtr(void)

{

  PUN_INFO *P;
  long oldsp;
        oldsp = Super(0l);
        P = *((PUN_INFO **)(0x516L));
        Super((void*)oldsp);

        if (P && (P->P_cookie == 0x41484449L) &&
                (P->P_cookptr == &(P->P_cookie)) &&
                (P->P_version >= 0x300))
                return P; /* punptr war gueltig */
        return 0L;
}


int getBCBSize()
{
  PUN_INFO *p;
        if ((p = GetPunPtr()) != 0l)
                return p->P_max_sector;
        return 512;
}
