/* GUS.H gravis related stuff */




#define ERR_SEQUENCER    51
#define ERR_NOGUS        53
#define PAN_HARDWARE      1

extern int gus_dev;



extern int ticks_per_division;
extern double tick_duration;
extern double this_time,next_time;

void sync_time(void);


extern unsigned char _seqbuf[];
extern int _seqbuflen, _seqbufptr;
 
unsigned short base_freq_table[];

extern unsigned int gus_total_mem;

int gus_mem_free(int dev);
















