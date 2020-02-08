# define BIT(i)	(1<<(i))

# define GIwrite(reg,data)	Giaccess(data,(reg)|0x80)
# define GIread(reg)		Giaccess(0,reg)

extern void gi_sequence ( int *tab ) ;
extern void GIset ( int reg, int value ) ;
extern void gi_tone ( int channel, int freq, int volume ) ;
extern void gi_on ( int channel ) ;
extern void gi_off ( int channel ) ;
