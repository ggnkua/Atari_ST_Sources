#ifndef _DRV_VIDEL16_H
#define _DRV_VIDEL16_H

extern void OpenVIDEL16(unsigned long int gamegear,  unsigned char* bm_structure);
extern void CloseVIDEL16();
extern int UpdateVIDEL16(unsigned long int skip);
extern void PaletteVIDEL16(unsigned char* source_pal);

#endif /* _DRV_VIDEL16_H */