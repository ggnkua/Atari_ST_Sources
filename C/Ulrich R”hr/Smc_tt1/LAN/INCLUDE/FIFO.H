
typedef struct
  {
  short   protocol;
  lan_buffer_typ    *pkt;  
  } ff_entry_typ;

typedef struct
  {
  short   anz;
  short   read;
  short   write;
  short   count;
  ff_entry_typ *entry;  
  } ff_typ;

lan_buffer_typ *pkt_ff_get (ff_typ *ff );
int pkt_ff_put (ff_typ *ff, lan_buffer_typ *pkt );
void pkt_ff_init ( ff_typ *ff, short anz );
void pkt_ff_alloc ( ff_typ *ff, char *free_mem );

void    get_sema(unsigned char *);
void    clear_sema(unsigned char *);
