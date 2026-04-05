

#ifndef	_NVDI_H
#define	_NVDI_H



typedef struct
{
     unsigned short  nvdi_version;
     unsigned long   nvdi_date;

     struct
     {
          unsigned res1   : 9;
          unsigned alert  : 1;
          unsigned res2   : 1;
          unsigned linea  : 1;
          unsigned mouse  : 1;
          unsigned gemdos : 1;
          unsigned error  : 1;
          unsigned gdos   : 1;

     } nvdi_config;

} NVDI_STRUCT;



#endif
