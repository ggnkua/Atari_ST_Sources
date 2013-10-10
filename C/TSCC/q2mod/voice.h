#ifndef __voice_h__
#define __voice_h__

// struct sam_descr /*fold00*/
struct sam_descr{
   unsigned short replen;
   unsigned short dummy2;
   unsigned short len;
   unsigned short dummy3;
};

// struct sample /*fold00*/
struct sample{
   char name[8];
   struct sam_descr *descr;
   char *start;
   unsigned short len;
   unsigned short repstart;
   unsigned short replen;
};

// setheader /*fold00*/
struct setheader{
   char dummy[2];
   char name[20][7];
   char offset[20*4];
   char unknown[4];
};

#endif /*FOLD00*/
