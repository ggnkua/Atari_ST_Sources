#ifndef VIDELDIRECT_H
#define VIDELDIRECT_H

// ------------------------------------------------------------------------------------------------

extern "C"{

void FalconLV_SaveVideo();
void FalconLV_RestoreVideo();
void FalconLV_SetFramebufferPointer(void* p_FalconScreenBuffer);
void FalconLV_EnableLineDubling();
void FalconLV_SetPallette(unsigned int* p_FalconPalette, unsigned long numEntries );
void FalconLV_SetPalletteRGBA(unsigned int* p_FalconPalette, unsigned long numEntries );
void FalconLV_SetVideoMode(void* p_VidelRegsDump);
void FalconLV_ChunkyToPlanes( unsigned char* pSrc, unsigned char* pDst, u32 numPixels );

extern unsigned char dump_320x200x16bpp_vga[];
extern unsigned char dump_320x200x8bpp_vga[];
extern unsigned char dump_320x240x16bpp_vga[];
extern unsigned char dump_320x240x8bpp_vga[];	

extern unsigned char dump_320x200x8bpp_tv[];
extern unsigned char dump_320x240x8bpp_tv[];	

}

// ------------------------------------------------------------------------------------------------

#endif //VIDELDIRECT_H