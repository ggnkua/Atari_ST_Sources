
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include <ldg.h>
#include <libshare.h>
#include <gif_lib.h>

#define STRINGIFY(x) #x
#define VERSION_LIB(A,B,C) STRINGIFY(A) "." STRINGIFY(B) "." STRINGIFY(C)
#define VERSION_LDG(A,B,C) "GIF encoder from The GIFLib Project (" STRINGIFY(A) "." STRINGIFY(B) "." STRINGIFY(C) ")"

#define MIN(A, B) ((A) < (B) ? (A) : (B))
#define MAX(A, B) ((A) > (B) ? (A) : (B))

/* structures */

typedef struct GifLdgBuffer {
  uint8_t *data;
  int size;
  int offset;
} GifLdgBuffer;

/* global variables */

static GifLdgBuffer buffer;

/* functions */

const char * CDECL gifenc_get_lib_version() { return VERSION_LIB(GIFLIB_MAJOR, GIFLIB_MINOR, GIFLIB_RELEASE); }

int gifldg_write(GifFileType* gif, const GifByteType* data, int count)
{
  GifLdgBuffer *buf = (GifLdgBuffer *) gif->UserData;
    
  uint32_t new_size;
   
  if (buf->offset + count > buf->size)
  {
    new_size = 2 * buf->size;
      
    if (buf->offset + count > new_size) { new_size = (((buf->offset + count + 15) >> 4) << 4); }
      
    buf->data = realloc(buf->data, new_size);
      
    if (buf->data == NULL) { return 0; }
      
    buf->size = new_size;
  }
    
  memcpy(buf->data + buf->offset, data, count);
  buf->offset += count;
    
  return count;
}

GifFileType * CDECL gifenc_open(int width, int height, int bckgrnd, int colors, const uint8_t *palette)
{
  int size = (width * height) + 1024;
  
  buffer.data = malloc(size);
  buffer.size = size;
  buffer.offset = 0;

  if (buffer.data == NULL) { return NULL; }

  GifFileType *gif = EGifOpen(&buffer, &gifldg_write, NULL);
    
  if (gif)
  {
    gif->SWidth = width;
    gif->SHeight = height;
    gif->SColorResolution = 8;
    gif->SBackGroundColor = MAX(0, MIN(bckgrnd, 255));
    
    if ((colors > 0) && (palette != NULL))
    {
      gif->SColorMap = GifMakeMapObject(colors, NULL);
         
      if (gif->SColorMap)
      {
        for (int c = 0; c < colors; ++c)
        {
          gif->SColorMap->Colors[c].Red = *palette++;
          gif->SColorMap->Colors[c].Green = *palette++;
          gif->SColorMap->Colors[c].Blue = *palette++;
        }
      }
    }
  }
  
  return gif;
}

int32_t CDECL gifenc_set_loops(GifFileType *gif, int loops)
{
  if (loops >= 0 && loops <= 0xFFFF)
  {
    unsigned char netscape[12] = "NETSCAPE2.0";
            
    if (GifAddExtensionBlock(&gif->ExtensionBlockCount, &gif->ExtensionBlocks, APPLICATION_EXT_FUNC_CODE, 11, netscape) == GIF_OK)
    {
      unsigned char data[3];
      
      data[0] = 0x01;
      data[1] = loops & 0xFF;
      data[2] = (loops >> 8) & 0xFF;
            
      return GifAddExtensionBlock(&gif->ExtensionBlockCount, &gif->ExtensionBlocks, CONTINUE_EXT_FUNC_CODE, 3, data);
    }
  }
  
  return GIF_ERROR;
}

int32_t CDECL gifenc_add_image(GifFileType *gif, int left, int top, int width, int height, int colors, const uint8_t *palette, const uint8_t *chunky)
{
  SavedImage *frm = calloc(1, sizeof(SavedImage));
  SavedImage *ret = NULL;
  
  if (frm)
  {
    frm->ImageDesc.Left = MAX(0, MIN(left, gif->SWidth - 1));
    frm->ImageDesc.Top = MAX(0, MIN(top, gif->SHeight - 1));
    frm->ImageDesc.Width = ((frm->ImageDesc.Left + width) > gif->SWidth) ? (gif->SWidth - frm->ImageDesc.Left) : width;
    frm->ImageDesc.Height = ((frm->ImageDesc.Top + height) > gif->SHeight) ? (gif->SHeight - frm->ImageDesc.Top) : height;
    frm->ImageDesc.Interlace = false;
  
    if ((colors > 0) && (palette != NULL))
    {
      frm->ImageDesc.ColorMap = GifMakeMapObject(colors, NULL);

      if (frm->ImageDesc.ColorMap != NULL)
      {
        for (int c = 0; c < colors; ++c)
        {
          frm->ImageDesc.ColorMap->Colors[c].Red = *palette++;
          frm->ImageDesc.ColorMap->Colors[c].Green = *palette++;
          frm->ImageDesc.ColorMap->Colors[c].Blue = *palette++;
        }
      }
    }
  
    frm->RasterBits = (GifByteType*)chunky;
  
    ret = GifMakeSavedImage(gif, frm);
  
    free(frm);
  }
  
  return ret ? GIF_OK : GIF_ERROR;
}

int32_t CDECL gifenc_set_special(GifFileType *gif, int frame_idx, int trnsprnt, int disposal, int delay)
{
  int ret = GIF_OK;
  
  if (trnsprnt > -1 || disposal > 0 || delay > 0)
  {
    GraphicsControlBlock *gcb = calloc(1, sizeof(GraphicsControlBlock));

    gcb->DisposalMode = disposal;
    gcb->UserInputFlag = false;
    gcb->DelayTime = delay;
    gcb->TransparentColor = trnsprnt;

    ret = EGifGCBToSavedExtension(gcb, gif, frame_idx);
    
    free(gcb);
  }
  
  return ret;
}

int32_t CDECL gifenc_write(GifFileType *gif) { return EGifSpew(gif); }

uint8_t* CDECL gifenc_get_filedata() { return buffer.data; }
uint32_t CDECL gifenc_get_filesize() { return buffer.offset; }

int32_t CDECL gifenc_close(GifFileType *gif)
{
  EGifCloseFile(gif, NULL);

  free(buffer.data);

  buffer.data = NULL;
  buffer.size = 0;
  buffer.offset = 0;

   return GIF_OK;
}

const char * CDECL gifenc_get_last_error(GifFileType *gif) { return GifErrorString(gif->Error); }

/* populate functions list and info for the LDG */

PROC LibFunc[] =
{
  {"gifenc_get_lib_version", "const char* gifenc_get_lib_version();\n", gifenc_get_lib_version},
   
  {"gifenc_open", "GifFileType* gifenc_open(int width, int height, int bckgrnd, int colors, const uint8_t *palette);\n", gifenc_open},
  
  {"gifenc_set_loops", "int32_t gifenc_set_loops(GifFileType *gif, int loops);\n", gifenc_set_loops},

  {"gifenc_add_image", "int32_t gifenc_add_image(GifFileType *gif, int left, int top, int width, int height, int colors, const uint8_t *palette, const uint8_t *chunky);\n", gifenc_add_image},
  {"gifenc_set_special", "int32_t gifenc_set_special(GifFileType *gif, int frame_idx, int trnsprnt, int disposal, int delay);\n", gifenc_set_special},
  
  {"gifenc_write", "int32_t gifenc_write(GifFileType *gif);\n", gifenc_write},
  {"gifenc_get_filedata", "uint8_t* gifenc_get_filedata(GifFileType *gif);\n", gifenc_get_filedata},
  {"gifenc_get_filesize", "uint32_t gifenc_get_filesize(GifFileType *gif);\n", gifenc_get_filesize},
  {"gifenc_close", "int32_t gifenc_close(GifFileType *gif);\n", gifenc_close},

  {"gifenc_get_last_error", "const char* gifenc_get_last_error(GifFileType *gif);\n", gifenc_get_last_error},
};

LDGLIB LibLdg[] = { { 0x0002, 10, LibFunc, VERSION_LDG(GIFLIB_MAJOR, GIFLIB_MINOR, GIFLIB_RELEASE), 1} };

/*  */

int main(void)
{
  ldg_init(LibLdg);
  libshare_init();
  return 0;
}
