#ifndef __mod_h__
#define __mod_h__

// Defines /*fold00*/
#define VOL_MAX 0x40
#define VOL_SILENCE 0
#define VOL_NOP -1

// freqtab /*fold00*/
int freqtab[]={
   856,808,762,720,
   678,640,604,570,
   538,508,480,453,
   428,404,381,360,
   339,320,302,285,
   269,254,240,226,
   214,202,190,180,
   170,160,151,143,
   135,127,120,113
};

// sturct mod_saminfo /*fold00*/
struct mod_saminfo{
   char name[20];
   short finetune;
   unsigned short len;
   unsigned short vol;
   unsigned short repstart;
   unsigned short replen;
};

// struct mod_header /*fold00*/
struct mod_header{
   char name[20];
   struct mod_saminfo saminfo[31];
   unsigned char num_pos;
   unsigned char repstartpos;
   unsigned char poslist[128];
   char magic[4];
};


#endif /*FOLD00*/
