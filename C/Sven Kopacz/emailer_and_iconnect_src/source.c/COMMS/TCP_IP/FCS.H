#define PPPINITFCS16    0xffff  /* Initial FCS value */
#define PPPGOODFCS16    0xf0b8  /* Good final FCS value */

extern unsigned int pppfcs16(unsigned int fcs, unsigned char *cp, int len);
