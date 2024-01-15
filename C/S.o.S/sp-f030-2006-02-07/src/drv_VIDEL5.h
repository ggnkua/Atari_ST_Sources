#ifndef _DRV_VIDEL5_H
#define _DRV_VIDEL5_H

extern void OpenVIDEL5(unsigned long int mode,  unsigned char* bm_structure);
extern void CloseVIDEL5();
extern int UpdateVIDEL5(unsigned long int skip);
extern void PaletteVIDEL5(unsigned char* source_pal);

#endif /* _DRV_VIDEL5_H */