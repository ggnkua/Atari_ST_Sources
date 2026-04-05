/*
 *      STVN Engine
 *      (c) 2022, 2023, 2026 Toyoyo
 *
 *      This library is free software; you can redistribute it and/or
 *      modify it under the terms of the GNU Lesser General Public
 *      License as published by the Free Software Foundation; either
 *      version 2.1 of the License, or (at your option) any later version.
 *
 *      This program is distributed in the hope that it will be useful,
 *      but WITHOUT ANY WARRANTY; without even the implied warranty of
 *      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *      Lesser General Public License for more details.
 *
 *      You should have received a copy of the GNU Lesser General Public
 *      License along with this library; if not, write to the Free Software
 *      Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
 */
#include <sys/types.h>
#include <stdio.h>
#include <mint/osbind.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <zlib.h>
#include <ext.h>
#include <ice.h>

// SNDH routines, adapted to m68k-atari-mintelf toolchain argument passing convention
#include "sndh.h"

// Misc macros, like Line-a and VT52 stuff
#include "misc.h"

// Things I kept from the original YM player
#define locate(x, y) printf("\033Y%c%c", (char)(32 + y), (char)(32 + x))
#define write_byte(value, address) (*address) = (__uint8_t)value
#define read_byte(address) (*address)

// Used to check a valid choice in Loading/Saving dialogs
#define NoValidSaveChoice (next != 2 && next != 9) && (next < 10 || next > 19)

// Screen backup/restore
#define RestoreScreen() memcpy(videoram, background, 25600)
#define SaveScreen() memcpy(background, videoram, 25600)

// Used to get the correct savestate filename in Loading/Saving dialogs
#define HandleSaveFilename() ({\
  if(next == 19) {\
    snprintf(savefile, 14, "data\\sav0.sav");\
  } else {\
    snprintf(savefile, 14, "data\\sav%d.sav", next-9);\
  }\
})

#define DispLoading() ({\
  memcpy(videoram+25600, textarea, 6400);\
  locate(0,21);\
  printf(" Loading...");\
  RedrawBorder();\
})

#define DispRollback() ({\
  memcpy(videoram+25600, textarea, 6400);\
  locate(0,21);\
  printf(" Rolling back...");\
  RedrawBorder();\
})

#define DispSaveError() ({\
  locate(0,0);\
  printf("Save failed! Press 'Space'...");\
  fflush(stdout);\
  while(readKeyBoardStatus() != 1);\
})

#define ResetEngine() ({\
  rewind(script);\
  lineNumber = 0;\
  savepointer = 0;\
  willplaying = 0;\
  spritecount = 0;\
  memset(musicfile, 0, sizeof(musicfile));\
  memset(oldmusicfile, 0, sizeof(oldmusicfile));\
  memset(picture, 0, sizeof(picture));\
  memset(oldpicture, 0, sizeof(oldpicture));\
  reset_cursprites();\
  reset_prevsprites();\
  if(isplaying == 1) SNDH_StopTune();\
  isplaying = 0;\
  savehistory_idx = 0;\
  memset(savehistory, 0, sizeof(savehistory));\
  memset(choicedata, 0, 11);\
  memset(sayername, 0, sizeof(sayername));\
  skipnexthistory = 0;\
  loadsave = 0;\
  charlines = 0;\
  memset(background, 0x00, 25600);\
  memset(videoram, 0x00, 25600);\
  memcpy(videoram+25600, textarea, 6400);\
  RedrawBorder();\
})

#define SaveMacro() ({\
  next=readKeyBoardStatus();\
  while(NoValidSaveChoice) {\
    next=readKeyBoardStatus();\
  }\
  if(next!=2 && next!=9) {\
    HandleSaveFilename();\
    RestoreScreen();\
    FILE* fd=fopen(savefile, "w");\
    if(fd != NULL) {\
      int _err = 0;\
      _err |= fprintf(fd, "%06d%d%d%d%d%d%d%d%d%d%d\n", savepointer, \
        choicedata[0],\
        choicedata[1],\
        choicedata[2],\
        choicedata[3],\
        choicedata[4],\
        choicedata[5],\
        choicedata[6],\
        choicedata[7],\
        choicedata[8],\
        choicedata[9]) < 0;\
      _err |= fprintf(fd, "%d\n", savehistory_idx) < 0;\
      for(int i=0; i<savehistory_idx; i++) {\
        _err |= fprintf(fd, "%d\n", savehistory[i]) < 0;\
      }\
      _err |= fclose(fd) != 0;\
      if(_err) {\
        DispSaveError();\
      }\
    } else {\
      DispSaveError();\
    }\
  }\
})

#define DeleteMacro() ({\
  next=readKeyBoardStatus();\
  while(NoValidSaveChoice) {\
    next=readKeyBoardStatus();\
  }\
  if(next!=2 && next!=9) {\
    HandleSaveFilename();\
    RestoreScreen();\
    if(fileexists(savefile) == 0) {\
      if(remove(savefile) != 0) {\
        locate(0,0);\
        printf("Delete failed! Press 'Space'...");\
        fflush(stdout);\
        while(readKeyBoardStatus() != 1);\
      }\
    }\
  }\
})

#define QuitMacro() ({\
  next = readKeyBoardStatus();\
  while (next != 9 && next != 10 && next != 11) {\
    next = readKeyBoardStatus();\
  }\
  if (next == 10) goto endprog;\
})

#define EscMacro() ({\
  next = readKeyBoardStatus();\
  while (next != 9 && next != 10 && next != 11) {\
    next = readKeyBoardStatus();\
  }\
  if (next == 10) {\
    ResetEngine();\
  }\
})

#define ParseVCommand() ({\
  if (strlen(line) == 3) {\
    char registername_s[2] = {0};\
    memcpy(registername_s, line+1, 1);\
    char registervalue_s[2] = {0};\
    memcpy(registervalue_s, line+2, 1);\
    int registername_i = atoi(registername_s);\
    int registervalue_i = atoi(registervalue_s);\
    if (registername_i >= 0 && registername_i < 10 && registervalue_i >= 0 && registervalue_i < 10) {\
      choicedata[registername_i] = (char)registervalue_i;\
    }\
  }\
})

// I definitely use this too much to not actually define it properly
#define LoadBackground(n) {\
  int pfd=open(picture, 0);\
  if(pfd > 0) {\
    gzFile gzf=gzdopen(pfd, "rb");\
    gzseek(gzf, 2, SEEK_CUR);\
    gzread(gzf, &bgpalette, 32);\
    gzread(gzf, background, 25600);\
    gzclose(gzf);\
    close(pfd);\
    if((n) == 0) {\
      memcpy(oldpicture, picture, 18);\
    }\
    RestoreScreen();\
  }\
}

// Handle optionally gzipped and/or ice-packed SNDH files
#define SNDHPlayMacro() ({\
  sndfile=gzopen(musicfile,"rb");\
  if(sndfile != NULL) {\
    char playready=0;\
    gzread(sndfile, tuneptr, sndhbuffersize);\
    gzclose(sndfile);\
    if (is_ice_data(tuneptr)) {\
      char *unicedsndh;\
      int unicedsize=ice_decrunched_length(tuneptr);\
      if(unicedsize <= sndhbuffersize) {\
        unicedsndh=malloc(ice_decrunched_length(tuneptr));\
        if(unicedsndh) {\
          ice_decrunch(tuneptr, unicedsndh);\
          memcpy(tuneptr, unicedsndh, unicedsize);\
          free(unicedsndh);\
          playready=1;\
        } else {\
          playready=0;\
        }\
      } else {\
        playready=0;\
      }\
    } else {\
      playready=1;\
    }\
    if(playready == 1) {\
      SNDH_GetTuneInfo(tuneptr,&mytune);\
      SNDH_PlayTune(&mytune,0);\
      isplaying=1;\
    } else {\
      isplaying=0;\
    }\
  } else {\
    isplaying=0;\
  }\
})

// Grad' again
#define DrawVLine(x1, y1, y2) ({\
  unsigned char* ptr = videoram + (y1 * 640 + x1) / 8;\
  unsigned char* ptr_end = videoram + (y2 * 640 + x1) / 8;\
  unsigned char mask = 1 << (7 - x1 % 8);\
  for(; ptr <= ptr_end; ptr += 640 / 8) {\
    *ptr |= mask;\
  }\
})

// Grad' again (bis)
#define DrawHLine(x1, y1, x2) ({\
  unsigned char *ptr;\
  unsigned char *ptr_end;\
  ptr = videoram + (y1 * 640 + x1) / 8;\
  ptr_end = videoram + (y1 * 640 + x2) / 8;\
  if (ptr == ptr_end) {\
    *ptr |= ((1 << (8 - x1 % 8)) - 1) & ~((1 << (7 - x2 % 8)) - 1);\
  } else {\
    *ptr++ |= (1 << (8 - x1 % 8)) - 1;\
    while (ptr < ptr_end) {\
      *ptr++ = 0xff;\
    }\
    *ptr |= ~((1 << (7 - x2 % 8)) - 1);\
  }\
})

#define RedrawBorder() ({\
  DrawHLine(0, 320, 640);\
  DrawHLine(0, 399, 640);\
  DrawVLine(0, 320, 399);\
  DrawVLine(639, 320, 399);\
})

char* get_line(FILE *fp) {
  static char newline[256] = {0};
  if (fp == NULL) {
    return NULL;
  }
  newline[255] = '\0';
  if (fgets(newline, 256, fp) == NULL) {
    return NULL;
  }
  size_t len = strlen(newline);
  if (len > 0 && newline[len - 1] == '\n') {
    newline[len - 1] = '\0';
  }
  if (len > 1 && newline[len - 2] == '\r') {
    newline[len - 2] = '\0';
  }
  return newline;
}

typedef struct {
  int x;
  int y;
  char file[18];
} sprite;

static sprite currentsprites[256];
static sprite previoussprites[256];
static void backup_spritearray() {
  int i;
  for(i=0; i<=255; i++) {
    previoussprites[i].x = currentsprites[i].x;
    previoussprites[i].y = currentsprites[i].y;
    if(strlen(currentsprites[i].file) > 0) {
      memcpy(previoussprites[i].file, currentsprites[i].file, 18);
    } else {
      memset(previoussprites[i].file, 0, 18);
    }
  }
}
static void reset_cursprites() {
  int i;
  for(i=0; i<=255; i++) {
    currentsprites[i].x = 0;
    currentsprites[i].y = 0;
    memset(currentsprites[i].file, 0, 18);
  }
}
static void reset_prevsprites() {
  int i;
  for(i=0; i<=255; i++) {
    previoussprites[i].x = 0;
    previoussprites[i].y = 0;
    memset(previoussprites[i].file, 0, 18);
  }
}
static int compare_sprites() {
  int i;
  for(i=0; i<=255; i++) {
    if(currentsprites[i].x != previoussprites[i].x) return 1;
    if(currentsprites[i].y != previoussprites[i].y) return 1;
    if(strncmp(currentsprites[i].file, previoussprites[i].file, 18) != 0) return 1;
  }
  return 0;
}

// non-blocking keyboard reading routine & handling
// Space -> read next script line
// 'q' -> jump to cleanup section & quit
// - Later -
// 'l' -> load state
// 's' -> save state
// Basically line bumber + 10 boolean registers
__uint32_t key;
static int readKeyBoardStatus() {
  if (Cconis() != 0L) {
    key = Crawcin();
    if ((char)key == ' ') {
      return 1;
    }
    if ((char)key == 'q') {
      return 2;
    }
    if ((char)key == 's') {
      return 3;
    }
    if ((char)key == 'l') {
      return 4;
    }
    if ((char)key == 'b') {
      return 5;
    }
    if ((char)key == 'h') {
      return 6;
    }
    if ((char)key == 'e') {
      return 8;
    }
    if ((char)key == 27) {
      return 9;
    }
    if ((char)key == '1') {
      return 10;
    }
    if ((char)key == '2') {
      return 11;
    }
    if ((char)key == '3') {
      return 12;
    }
    if ((char)key == '4') {
      return 13;
    }
    if ((char)key == '5') {
      return 14;
    }
    if ((char)key == '6') {
      return 15;
    }
    if ((char)key == '7') {
      return 16;
    }
    if ((char)key == '8') {
      return 17;
    }
    if ((char)key == '9') {
      return 18;
    }
    if ((char)key == '0') {
      return 19;
    }
  }
}

static void DispLoadSave(char mode) {
  char savepath[15] = {0};
  char* videoram = Logbase();

  // Fill dialog area with white (0x00)
  // Area: x=240-400 (bytes 30-50), y=112-240
  for(int y=112; y<=240; y++) {
    memset(videoram + y*80 + 30, 0x00, 20);
  }

  locate(35,7);
  if(mode == 0) printf("- Loading -");
  if(mode == 1) printf("- Saving -");
  if(mode == 2) printf("- Delete -");

  // Draw the border
  DrawHLine(240, 112, 400);
  DrawHLine(240, 240, 400);
  DrawVLine(240, 112, 240);
  DrawVLine(400, 112, 240);

  // Left column: 1-5
  for(int i=1; i<=5; i++) {
    locate(31, 7+i);
    snprintf(savepath, 15, "data\\sav%d.sav", i);
    if(fileexists(savepath) == 0) {
      printf("%d: USED ", i);
    } else {
      printf("%d: EMPTY", i);
    }
  }
  // Right column: 6-9, 0
  for(int i=6; i<=9; i++) {
    locate(41, 2+i);
    snprintf(savepath, 15, "data\\sav%d.sav", i);
    if(fileexists(savepath) == 0) {
      printf("%d: USED ", i);
    } else {
      printf("%d: EMPTY", i);
    }
  }
  locate(41, 12);
  if(fileexists("data\\sav0.sav") == 0) {
    printf("0: USED ");
  } else {
    printf("0: EMPTY");
  }
  locate(35,14);
  printf("[q] : quit");
  fflush(stdout);
}

static void DispHelp() {
  locate(32,6);
  printf("-     Usage    -");
  locate(32,7);
  printf("[q] Quit        ");
  locate(32,8);
  printf("[b] Back        ");
  locate(32,9);
  printf("[l] Load save   ");
  locate(32,10);
  printf("[s] Save state  ");
  locate(32,11);
  printf("[e] Erase state ");
  locate(32,12);
  printf("[ ] Advance     ");
  locate(32,13);
  printf("[esc] Restart   ");
  fflush(stdout);

  char* videoram = Logbase();
  DrawHLine(256, 96, 384);
  DrawHLine(256, 224, 384);
  DrawVLine(256, 96, 224);
  DrawVLine(384, 96, 224);
}

static void DispQuit(void) {
  locate(33,9);
  printf("-    Quit    -");
  locate(33,10);
  printf("[1] Yes [2] No");

  char* videoram = Logbase();
  DrawHLine(264, 144, 376);
  DrawHLine(264, 176, 376);
  DrawVLine(264, 144, 176);
  DrawVLine(376, 144, 176);
}

static void DispEsc(void) {
  char* videoram = Logbase();
  for(int y=144; y<=175; y++) {
    memset(videoram + y*80 + 32, 0x00, 17);
  }
  locate(32,9);
  printf("-    Restart    -");
  locate(32,10);
  printf(" [1] Yes  [2] No ");
  fflush(stdout);
  DrawHLine(256, 144, 392);
  DrawHLine(256, 176, 392);
  DrawVLine(256, 144, 176);
  DrawVLine(392, 144, 176);
}

// Wipe screen vertically
static void FxVWipeDown(char byte) {
  char* videoram = Logbase();
  char pattern[80];
  for(int i=0; i<320; i+=2) {
    memset(pattern, byte, 80);
    memcpy(videoram+i*80, &pattern, 80);
    memcpy(videoram+80+i*80, &pattern, 80);
    delay(5);
  }
}
static void FxVWipeUp(char byte) {
  char* videoram = Logbase();
  char pattern[80];
  for(int i=318; i>=0; i-=2) {
    memset(pattern, byte, 80);
    memcpy(videoram+80+i*80, &pattern, 80);
    memcpy(videoram+i*80, &pattern, 80);
    delay(5);
  }
}
static void FxVWipeMidIn(char byte) {
  char* videoram = Logbase();
  char pattern[80];
  for(int i=160; i>=0; i-=2) {
    memset(pattern, byte, 80);
    if(i<159) memcpy(videoram+12800+i*80, &pattern, 80);
    memcpy(videoram+12800+80+i*80, &pattern, 80);
    memcpy(videoram+12800-i*80, &pattern, 80);
    memcpy(videoram+12800-80-i*80, &pattern, 80);
    delay(5);
  }
}
static void FxVWipeMidOut(char byte) {
  char* videoram = Logbase();
  char pattern[80];
  for(int i=0; i<161; i+=2) {
    memset(pattern, byte, 80);
    if(i<160) memcpy(videoram+12800+i*80, &pattern, 80);
    if(i<160) memcpy(videoram+12800+80+i*80, &pattern, 80);
    memcpy(videoram+12800-i*80, &pattern, 80);
    memcpy(videoram+12800-80-i*80, &pattern, 80);
    delay(5);
  }
}

// Wipe screen horizontally
static void FxHWipeRight(char byte) {
  char* videoram = Logbase();
  for(int col=0; col<80; col++) {
    for(int line=0; line<320; line++) {
      videoram[line*80 + col] = byte;
    }
    delay(5);
  }
}
static void FxHWipeLeft(char byte) {
  char* videoram = Logbase();
  for(int col=79; col>=0; col--) {
    for(int line=0; line<320; line++) {
      videoram[line*80 + col] = byte;
    }
    delay(5);
  }
}
static void FxHWipeMidIn(char byte) {
  char* videoram = Logbase();
  for(int col=0; col<40; col++) {
    for(int line=0; line<320; line++) {
      videoram[line*80 + col] = byte;
      videoram[line*80 + (79 - col)] = byte;
    }
    delay(5);
  }
}
static void FxHWipeMidOut(char byte) {
  char* videoram = Logbase();
  for(int col=0; col<40; col++) {
    for(int line=0; line<320; line++) {
      videoram[line*80 + (39 - col)] = byte;
      videoram[line*80 + (40 + col)] = byte;
    }
    delay(5);
  }
}

// Draw expanding pseudo-circle from center using 16x32 pixel blocks
static void FxCircleOut(char byte) {
  char* videoram = Logbase();
  int bcx = 20;
  int bcy = 5;

  for(int r = 0; r <= 23; r++) {
    int r2 = r * r;
    int prev_r2 = (r > 0) ? (r - 1) * (r - 1) : -1;

    for(int by = 0; by < 10; by++) {
      int dy = by - bcy;
      int dy2 = 4 * dy * dy;
      if(dy2 > r2) continue;

      int dx = 0;
      int target = r2 - dy2;
      while((dx + 1) * (dx + 1) <= target) dx++;

      int prev_dx = -1;
      if(prev_r2 >= 0 && dy2 <= prev_r2) {
        prev_dx = 0;
        int prev_target = prev_r2 - dy2;
        while((prev_dx + 1) * (prev_dx + 1) <= prev_target) prev_dx++;
      }

      for(int line = 0; line < 32; line++) {
        int y = by * 32 + line;
        if(y >= 320) continue;

        for(int bx = bcx - dx; bx <= bcx - prev_dx - 1; bx++) {
          if(bx >= 0 && bx < 40) {
            videoram[y * 80 + bx * 2] = byte;
            videoram[y * 80 + bx * 2 + 1] = byte;
          }
        }

        for(int bx = bcx + prev_dx + 1; bx <= bcx + dx; bx++) {
          if(bx >= 0 && bx < 40) {
            videoram[y * 80 + bx * 2] = byte;
            videoram[y * 80 + bx * 2 + 1] = byte;
          }
        }
      }
    }
    delay(5);
  }
}

// Draw shrinking pseudo-circle from edges to center using 16x32 pixel blocks
static void FxCircleIn(char byte) {
  char* videoram = Logbase();
  int bcx = 20;
  int bcy = 5;

  for(int r = 23; r >= 0; r--) {
    int r2 = r * r;
    int next_r2 = (r > 0) ? (r - 1) * (r - 1) : -1;

    for(int by = 0; by < 10; by++) {
      int dy = by - bcy;
      int dy2 = 4 * dy * dy;
      if(dy2 > r2) continue;

      int dx = 0;
      int target = r2 - dy2;
      while((dx + 1) * (dx + 1) <= target) dx++;

      int next_dx = -1;
      if(next_r2 >= 0 && dy2 <= next_r2) {
        next_dx = 0;
        int next_target = next_r2 - dy2;
        while((next_dx + 1) * (next_dx + 1) <= next_target) next_dx++;
      }

      for(int line = 0; line < 32; line++) {
        int y = by * 32 + line;
        if(y >= 320) continue;

        for(int bx = bcx - dx; bx <= bcx - next_dx - 1; bx++) {
          if(bx >= 0 && bx < 40) {
            videoram[y * 80 + bx * 2] = byte;
            videoram[y * 80 + bx * 2 + 1] = byte;
          }
        }

        for(int bx = bcx + next_dx + 1; bx <= bcx + dx; bx++) {
          if(bx >= 0 && bx < 40) {
            videoram[y * 80 + bx * 2] = byte;
            videoram[y * 80 + bx * 2 + 1] = byte;
          }
        }
      }
    }
    delay(5);
  }
}

// 8x8 Bayer dither matrix (values 0-63) for fade effects
static const unsigned char bayer8x8[8][8] = {
  { 0, 32,  8, 40,  2, 34, 10, 42},
  {48, 16, 56, 24, 50, 18, 58, 26},
  {12, 44,  4, 36, 14, 46,  6, 38},
  {60, 28, 52, 20, 62, 30, 54, 22},
  { 3, 35, 11, 43,  1, 33,  9, 41},
  {51, 19, 59, 27, 49, 17, 57, 25},
  {15, 47,  7, 39, 13, 45,  5, 37},
  {63, 31, 55, 23, 61, 29, 53, 21}
};

// Fade current screen to black using ordered dithering (4 steps)
static void FxFadeOut(void) {
  char* videoram = Logbase();
  char* buffer = malloc(25600);
  if (!buffer) return;
  memcpy(buffer, videoram, 25600);

  for (int step = 1; step <= 4; step++) {
    int threshold = step * 16;
    unsigned long masks32[8];
    for (int r = 0; r < 8; r++) {
      unsigned char mask = 0;
      for (int bit = 0; bit < 8; bit++) {
        if (bayer8x8[r][bit] < threshold)
          mask |= (0x80 >> bit);
      }
      masks32[r] = mask * 0x01010101UL;
    }
    for (int y = 0; y < 320; y++) {
      unsigned long m32 = masks32[y & 7];
      unsigned long* dst = (unsigned long*)(buffer + y * 80);
      for (int i = 0; i < 20; i++) {
        dst[i] |= m32;
      }
    }
    memcpy(videoram, buffer, 25600);
    delay(5);
  }

  free(buffer);
  memset(videoram, 0xFF, 25600);
}

// Fade from black to a new image using ordered dithering (4 steps)
// Uses scratch as a double buffer to avoid extra allocation
static void FxFadeIn(const char *filepath, char *scratch) {
  char* videoram = Logbase();
  char* target = malloc(25600);
  if (!target) return;

  int pfd = open(filepath, 0);
  if (pfd <= 0) { free(target); return; }
  gzFile gzf = gzdopen(pfd, "rb");
  gzseek(gzf, 2, SEEK_CUR);
  gzseek(gzf, 32, SEEK_CUR);
  gzread(gzf, target, 25600);
  gzclose(gzf);

  memset(videoram, 0xFF, 25600);

  for (int step = 1; step <= 4; step++) {
    int threshold = step * 16;
    unsigned long masks32[8];
    for (int r = 0; r < 8; r++) {
      unsigned char mask = 0;
      for (int bit = 0; bit < 8; bit++) {
        if (bayer8x8[r][bit] < threshold)
          mask |= (0x80 >> bit);
      }
      masks32[r] = (unsigned char)(~mask) * 0x01010101UL;
    }
    for (int y = 0; y < 320; y++) {
      unsigned long m32 = masks32[y & 7];
      unsigned long* dst = (unsigned long*)(scratch + y * 80);
      unsigned long* src = (unsigned long*)(target + y * 80);
      for (int i = 0; i < 20; i++) {
        dst[i] = src[i] | m32;
      }
    }
    memcpy(videoram, scratch, 25600);
    delay(5);
  }

  memcpy(videoram, target, 25600);
  free(target);
}

static void run() {
  char *background;
  char textarea[6400] = {0};
  char bgpalette[32] = {0};
  FILE *script;
  FILE *config;
  long lineNumber = 0;
  char* line;
  char picture[18] = {0};
  char oldpicture[18] = {0};
  char musicfile[18] = {0};
  char oldmusicfile[18] = {0};
  char sayername[260] = {0};
  int charlines=0;
  void* tuneptr;
  gzFile sndfile;
  int isplaying=0;
  int willplaying=0;
  int next;
  char *choicedata;
  char jumplabel[7] = {0};
  char savefile[14] = {0};
  long savepointer = 0;
  int savehistory[1000] = {0};  // Track all savepointer assignments
  int savehistory_idx = 0;
  long save_linenb = 0;
  int skipnexthistory=0;
  int loadsave=0;

  // Sprite crap
  char spritefile[18] = {0};
  int posx=0;
  int posy=0;
  int isbackfunc=0;
  char linex[4] = {0};
  char liney[4] = {0};

  reset_cursprites();
  reset_prevsprites();

  // to track sprites during load/back
  int spritecount=0;

  // Defaults
  long sndhbuffersize=20000;
  char scriptfile[18] = "stvn.vns";

  // Get video RAM address
  char *videoram=Logbase();

  // Our choice registers
  choicedata=malloc(11);
  if(choicedata == NULL) return;
  memset(choicedata, 0, 11);

  // And screen buffers
  // The displayable area is 640x320, so 25600 bytes,
  background=malloc(25600);
  if(background == NULL) return;

  // Disable mouse
  lineaa();

  // Some VT52 setup
  printf(CLEAR_HOME);
  printf(WRAP_OFF);

  // Let's parse the config file
  if(fileexists("stvn.ini") == 0) {
    config=fopen("stvn.ini", "r");
    line = get_line(config);

    while(line) {
      if(strlen(line) > 0) {
        if(*line == 'S') {
          int filelength=strlen(line)-1;
          if(filelength > 12) filelength=12;
          memset(scriptfile, 0, 13);
          snprintf(scriptfile, 6, "DATA\\");
          memcpy(scriptfile+5, line+1, filelength);
        }
        if(*line == 'B') {
          sndhbuffersize=atoi(line+1);
        }
      }
      line = get_line(config);
    }
    fclose(config);
  } else {
    printf("STVN.INI not found, using defaults:.\r\n");
    printf("Script file: STVN.VNS\r\n");
    printf("Maximum SNDH Size: 20000 bytes\r\n");
    printf("Press any key to continue...\r\n");
    fflush(stdout);
    Crawcin();
  }

  // Alloc some buffer space for the SNDH file
  // 20k seems like a good enough default, but definitely not enough for DMA ones.
  // This is the size of the biggest SNDH file in the project
  tuneptr = malloc(sndhbuffersize);

  // Disable Keyboard clicks
  __uint8_t originalKeyClick = read_byte((__uint8_t *)0x00000484);
  write_byte(0b11111110 & originalKeyClick, (__uint8_t *)0x484);

  // Our script
  script=fopen(scriptfile, "r");

  if(script == NULL) {
    printf("Opening >%s< failed.\r\n", scriptfile);
    printf("Press any key to quit...\r\n");
    fflush(stdout);
    Crawcin();
    free(tuneptr);
    linea9();
    return;
  }

  // main loop
  while (1) {
    // Read the next line
    // If there isn't, let's quit
    line = get_line(script);
    if(line == NULL) goto endprog;
    lineNumber = lineNumber + 1;

    // Empty lines are simply ignored.
    // Feel free to make a readable script
    if(strlen(line) > 0) {
      // Our format is trivial.
      // First char is the command (T, P, etc..)
      // Then its arguments, starting at line+1
      // If the first character isn't a known operand, we'll do nothing.
      // So there's no "comment" operand, just use anything that's not a known operand.

      // 'W' : Wait for input.
      // This is where most interaction will happen.
      // Like saving/loading, waiting for 'space', quitting, etc...
      if(*line == 'W') {
        next=readKeyBoardStatus();
        while(next!=1) {
          // Our quit signal from 'q'
          if(next == 2) {
            SaveScreen();
            DispQuit();
            QuitMacro();
            next = 0;
            RestoreScreen();
          }

          // Save
          if(next == 3) {
            SaveScreen();
            DispLoadSave(1);
            SaveMacro();
            next = 0;
            RestoreScreen();
          }

          if(next == 8) {
            SaveScreen();
            DispLoadSave(2);
            DeleteMacro();
            next = 0;
            RestoreScreen();
          }

          if(next == 9) {
            SaveScreen();
            DispEsc();
            EscMacro();
            next = 0;
            if(lineNumber == 0) break;
            RestoreScreen();
          }

          // Don't go back if we can't
          if(next == 5 && savehistory_idx >= 2) {
            save_linenb = savehistory[savehistory_idx - 2];
            savehistory[savehistory_idx - 1] = 0;
            savehistory_idx--;
            skipnexthistory=1;
            DispRollback();
            goto seektoline;
          }

          if(next == 6) {
            SaveScreen();
            DispHelp();
            while(next!=2 && next!=9) {
                next=readKeyBoardStatus();
            }
            next = 0;
            RestoreScreen();
          }

          // Load
          if(next == 4) {
            SaveScreen();
            DispLoadSave(0);
            while(NoValidSaveChoice) {
                next=readKeyBoardStatus();
            }
            RestoreScreen();
            lblloadsave:
            // Effective loading.
            if(next!=2 && next!=9) {
              loadsave=1;
              HandleSaveFilename();
              if(fileexists(savefile) == 0) {
                DispLoading();
                FILE* savefp = fopen(savefile, "r");
                char savestate[17] = {0};
                char save_line[7] = {0};
                char save_register[2] = {0};
                char save_register_val=0;
                save_linenb = 0;
                fread(savestate, 1, 16, savefp);

                // First, get the target line number
                memcpy(save_line, savestate, 6);
                save_linenb=atoi(save_line);

                // Now we restore the choices register
                int i;
                for(i=0; i<10; i++) {
                  memcpy(save_register, savestate+6+i, 1);
                  save_register_val = atoi(save_register);
                  choicedata[i] = save_register_val;
                }

                // Restore savehistory
                char histline[255] = {0};
                // Skip newline after header and read savehistory_idx
                if(fgets(histline, 255, savefp) != NULL && fgets(histline, 255, savefp) != NULL) {
                  savehistory_idx = atoi(histline);
                  if(savehistory_idx > 999) savehistory_idx=999;
                  memset(savehistory, 0, sizeof(savehistory));
                  // Read savehistory entries
                  for(int j=0; j<savehistory_idx && j<1000; j++) {
                    if(fgets(histline, 255, savefp) == NULL) {
                      savehistory_idx = j;
                      break;
                    }
                    savehistory[j] = atoi(histline);
                  }
                }
                fclose(savefp);
                skipnexthistory=1;

                seektoline:
                // Now, we're going to parse the entire file...
                rewind(script);
                lineNumber=0;
                savepointer=0;
                willplaying=0;
                spritecount=0;
                int bgcolor=0;
                memset(picture, 0, sizeof(picture));

                /* On load: stop music and clear state - will restart if 'P' is encountered */
                if (loadsave == 1) {
                  if (isplaying) {
                    SNDH_StopTune();
                    isplaying = 0;
                  }
                  memset(musicfile, 0, sizeof(musicfile));
                  memset(oldmusicfile, 0, sizeof(oldmusicfile));
                }

                if(loadsave == 0) {
                  backup_spritearray();
                  reset_cursprites();
                }

                while(lineNumber < save_linenb) {
                  line = get_line(script);
                  if(line == NULL) goto endprog;
                  lineNumber = lineNumber + 1;

                  // So we'll get the last background picture to draw
                  // As this is supposed to refresh the screen, this invalidate previous sprites
                  if(*line == 'I') {
                    int filelen=strlen(line)-1;
                    if(filelen > 12) filelen=12;
                    memset(picture, 0, 18);
                    snprintf(picture, 6, "DATA\\");
                    memcpy(picture+5, line+1, filelen);
                    reset_cursprites();
                    spritecount=0;
                  }

                  // This redraw the background, so invalidates previous sprites too
                  if(*line == 'R') {
                    reset_cursprites();
                    spritecount=0;
                  }

                  // This wipes the screen, so also invalidates previous sprites
                  if(*line == 'X') {
                    reset_cursprites();
                    spritecount=0;
                    if(strlen(line) >= 3) {
                      char effect[3] = {0};
                      memcpy(effect, line+1, 2);
                      char effectnum = atoi(effect);
                      memset(picture, 0, 18);
                      // Track background color
                      if(effectnum == 1) bgcolor = 255;
                      if(effectnum == 2) bgcolor = 0;
                      if(effectnum == 3) bgcolor = 0;
                      if(effectnum == 4) bgcolor = 255;
                      if(effectnum == 5) bgcolor = 255;
                      if(effectnum == 6) bgcolor = 0;
                      if(effectnum == 7) bgcolor = 0;
                      if(effectnum == 8) bgcolor = 255;
                      if(effectnum == 9) bgcolor = 255;
                      if(effectnum == 10) bgcolor = 0;
                      if(effectnum == 11) bgcolor = 0;
                      if(effectnum == 12) bgcolor = 255;
                      if(effectnum == 13) bgcolor = 255;
                      if(effectnum == 14) bgcolor = 0;
                      if(effectnum == 15) bgcolor = 0;
                      if(effectnum == 16) bgcolor = 255;
                      if(effectnum == 17) bgcolor = 255;
                      if(effectnum == 18) bgcolor = 0;
                      if(effectnum == 19) bgcolor = 0;
                      if(effectnum == 20) bgcolor = 255;
                      if(effectnum == 21) bgcolor = 255;
                      if(effectnum == 22) bgcolor = 0;
                      if(effectnum == 23) bgcolor = 0;
                      if(effectnum == 24) bgcolor = 255;
                      if(effectnum == 25) bgcolor = 255;
                      if(effectnum == 26) bgcolor = 0;
                      if(effectnum == 27) bgcolor = 0;
                      if(effectnum == 28) bgcolor = 255;
                      if(effectnum == 29) bgcolor = 255;
                      if(effectnum == 30) bgcolor = 0;
                      if(effectnum == 31) bgcolor = 0;
                      if(effectnum == 32) bgcolor = 255;
                      if(effectnum == 33) bgcolor = 255;
                      if(effectnum == 34) bgcolor = 0;
                      if(effectnum == 35) bgcolor = 0;
                      if(effectnum == 36) bgcolor = 255;
                      if(effectnum == 37) bgcolor = 255;
                      if(effectnum == 38) bgcolor = 0;
                      if(effectnum == 39) bgcolor = 0;
                      if(effectnum == 40) bgcolor = 255;
                      if(effectnum == 98) bgcolor = 255;
                      // X99 loads a new background image, track it like 'I'
                      if(effectnum == 99 && strlen(line) >= 4) {
                        int filelen = strlen(line) - 3;
                        if(filelen > 12) filelen = 12;
                        snprintf(picture, 6, "DATA\\");
                        memcpy(picture + 5, line + 3, filelen);
                      }
                    }
                  }

                  // I didn't want to implement this
                  if(*line == 'A') {
                    if(strlen(line) < 8) goto endspriteload;
                    if(spritecount > 255) goto endspriteload;
                    int filelen=strlen(line)-7;
                    if(filelen > 12) filelen=12;
                    memset(currentsprites[spritecount].file, 0, 18);
                    memcpy(currentsprites[spritecount].file, line+7, filelen);
                    memset(linex, 0, 4);
                    memset(liney, 0, 4);
                    memcpy(linex, line+1, 3);
                    memcpy(liney, line+4, 3);
                    currentsprites[spritecount].x=atoi(linex);
                    currentsprites[spritecount].y=atoi(liney);
                    spritecount++;
                    endspriteload:
                    ;
                  }

                  // And the lastmusicfile
                  if(*line == 'P') {
                    if(strlen(line) == 2 && *(line+1) == 'S') {
                      memset(musicfile, 0, sizeof(musicfile));
                      willplaying=0;
                    } else {
                      int filelen=strlen(line)-1;
                      if(filelen > 0) {
                        if(filelen > 12) filelen=12;
                        memset(musicfile, 0, 18);
                        snprintf(musicfile, 6, "DATA\\");
                        memcpy(musicfile+5, line+1, filelen);
                        willplaying=1;
                      }
                    }
                  }

                  if(*line == 'S') {
                    savepointer=lineNumber;
                    strncpy(sayername, line + 1, sizeof(sayername) - 1);
                    sayername[sizeof(sayername) - 1] = '\0';
                  }

                  // We also need to replay the 'B' Lines
                  if(*line == 'B') {
                    if(strlen(line) == 8) {
                      char lineregister[2] = {0};
                      memcpy(lineregister, line+1, 1);
                      char selectedregister=atoi(lineregister);

                      char linechoice[2] = {0};
                      memcpy(linechoice, line+2, 1);
                      char selectedchoice=atoi(linechoice);
                      if(selectedchoice > 3) selectedchoice=3;
                      if(selectedchoice < 0) selectedchoice=0;

                      if(choicedata[selectedregister] == selectedchoice) {
                        memcpy(jumplabel, line+3, 6);
                        while(1) {
                          line = get_line(script);
                          if(line == NULL) goto endprog;
                          lineNumber = lineNumber + 1;
                          if(strlen(line) >= 5) {
                            if(strncmp(jumplabel, line, 5) == 0) {
                              goto btestend;
                            }
                          }
                        }
                        btestend:
                        ;
                      }
                    }
                  }

                  // And probably 'J' Lines too.
                  if(*line == 'J') {
                    if(strlen(line) >= 6) {
                      memcpy(jumplabel, line+1, 5);
                      while(1) {
                       line = get_line(script);
                       if(line == NULL) goto endprog;
                       lineNumber = lineNumber + 1;
                       if(strlen(line) >= 5) {
                         if(strncmp(jumplabel, line, 5) == 0) goto jend;
                        }
                      }
                    }
                    jend:
                   ;
                  }

                  // 'V' : Set a register to a value
                  if(*line == 'V') {
                    ParseVCommand();
                  }
                }
                // We should have everything we need, now let's restorethings

                // Let's explain things:
                // "background" is the last picture encoutered in the backlog
                // If we're loading a save, the're no way we don't neet to load it
                // If we're not, we're rolling back in-game.
                // In this case, reload on two cases:
                // * If the background changed, obviously
                // * If there's a difference in sprites to display
                int restored = 0;
                if (picture[0] == '\0') {
                  memset(background, bgcolor, 25600);
                  memset(oldpicture, 0, sizeof(oldpicture));
                  RestoreScreen();
                  restored = 1;
                } else if(loadsave == 0) {
                  if(strcmp(picture, oldpicture) != 0) {
                    LoadBackground(0);
                    restored = 1;
                  } else {
                    if(compare_sprites() != 0) {
                      LoadBackground(0);
                      restored = 1;
                    } else if(spritecount == 0) {
                      RestoreScreen();
                    }
                  }
                } else {
                  LoadBackground(0);
                  restored = 1;
                }

                charlines=0;

                // Then the music
                if(willplaying == 1) {
                  if(strncmp(musicfile, oldmusicfile, 12) != 0) {
                    if(isplaying == 1) {
                      SNDH_StopTune();
                      isplaying=0;
                    }

                    SNDHTune mytune;
                    memcpy(oldmusicfile, musicfile, 12);
                    SNDHPlayMacro();
                  }
                } else {
                  // No 'P' line encountered - stop music
                  if(isplaying == 1) {
                    SNDH_StopTune();
                    isplaying=0;
                  }
                  memset(musicfile, 0, sizeof(musicfile));
                  memset(oldmusicfile, 0, sizeof(oldmusicfile));
                }

                // Now to display required sprites;
                // Redraw if sprites changed, or if videoram was refreshed
                // (wiping any previously composited sprites)
                if(compare_sprites() != 0 || restored) {
                  int spritecounter=1;
                  if(spritecount > 0) {
                    for(spritecounter=1; spritecounter <= spritecount; spritecounter++) {
                      memset(spritefile, 0, sizeof(spritefile));
                      snprintf(spritefile, 6, "DATA\\");
                      memcpy(spritefile+5, currentsprites[spritecounter-1].file, strlen(currentsprites[spritecounter-1].file));
                      posx=currentsprites[spritecounter-1].x;
                      posy=currentsprites[spritecounter-1].y;
                      isbackfunc=1;

                      goto displaysprite;
                      spritedrawn:
                      ;
                    }
                  }
                }

                /* Show the 'S' Line */
                memcpy(videoram+25600, textarea, 6400);
                RedrawBorder();
                if (sayername[0]) {
                  locate(0,20);
                  printf(sayername);
                }

                // We're done, and the next action will be to display to current line.
                // Which sould be a 'S' since they're the only ones advancing the save pointer.
                loadsave=0;
                break;
              }
            }
            // In case we didn't load anything, restore the scene
            RestoreScreen();
          }
          next=readKeyBoardStatus();
        }
      }

      // 'I' : Change background image
      if(*line == 'I') {
        int filelen=strlen(line)-1;
        if(filelen > 0) {
          if(filelen > 12) filelen=12;
          memset(picture, 0, 18);
          snprintf(picture, 6, "DATA\\");
          memcpy(picture+5, line+1, filelen);

          LoadBackground(0);
          reset_cursprites();
          spritecount=0;
          charlines=0;
        }
      }

      if(*line == 'R') {
        LoadBackground(1);
        RestoreScreen();
        reset_cursprites();
        spritecount=0;
      }
      // 'S' : Sayer change
      // Obviously, this will reset character lines to 0
      // This is used as the save pointer and will also reset the text box
      if(*line == 'S') {
        charlines=0;
        memcpy(videoram+25600, textarea, 6400);
        RedrawBorder();

        // Display the character name at a fixed place
        locate(0,20);
        printf("%s", line+1);
        fflush(stdout);
        savepointer=lineNumber;
        if(skipnexthistory == 1) {
          skipnexthistory=0;
        } else {
          if(savehistory_idx >= 1000) {
            memmove(savehistory, savehistory + 1, 999 * sizeof(int));
            savehistory[999] = 0;
            savehistory_idx = 999;
          }
          savehistory[savehistory_idx++] = lineNumber;
        }
      }

      if(*line == 'E') {
        charlines=0;
        memcpy(videoram+25600, textarea, 6400);
        RedrawBorder();
      }

      // 'T' : Text line
      // We disabled line wrapping so make sure a line isn't more then 79 characters!
      if(*line == 'T' || *line == 'N') {
        // Skip already written lines
        // charlines being reset to 0 after each 'S' lines
        locate(0,21+charlines);
        printf(" %s", line+1);
        fflush(stdout);
        charlines++;
      }

      // 'P' : Change music
      // The SNDH routine MUST be stopped ONLY if there's already one playing.
      // 'PS' : Stop music
      if(*line == 'P') {
        if(strlen(line) == 2 && *(line+1) == 'S') {
          if(isplaying == 1) {
            SNDH_StopTune();
            isplaying=0;
          }
          memset(musicfile, 0, sizeof(musicfile));
          memset(oldmusicfile, 0, sizeof(oldmusicfile));
        } else {
          int filelen=strlen(line)-1;
          if(filelen > 0) {
            if(filelen > 12) filelen=12;
            memset(musicfile, 0, 18);
            snprintf(musicfile, 6, "DATA\\");
            memcpy(musicfile+5, line+1, filelen);
            if(strncmp(musicfile, oldmusicfile, 12) != 0) {
              SNDHTune mytune;
              memcpy(oldmusicfile, musicfile, 12);

              if(isplaying == 1) SNDH_StopTune();
              isplaying=0;
              SNDHPlayMacro();
            }
          }
        }
      }

      // 'J' : Jump to label
      // Mostly useful for 'B'+'J' combos, but 'B' and 'C' lines will jump here.
      if(*line == 'J') {
        if(strlen(line) >= 6) {
          memcpy(jumplabel, line+1, 5);
          jumptolabel:
          rewind(script);
          lineNumber=0;
          while(1) {
            line = get_line(script);
            if(line == NULL) goto endprog;
            lineNumber = lineNumber + 1;
            if(strlen(line) >= 5) {
              if(strncmp(jumplabel, line, 5) == 0) {
                break;
              }
            }
          }
        }
      }

      // Jump to start
      if(*line == 'F') {
        ResetEngine();
      }

      // 'B' : Jump to label if register is set
      if(*line == 'B') {
        if(strlen(line) == 8) {
          char lineregister[2] = {0};
          memcpy(lineregister, line+1, 1);
          char selectedregister=atoi(lineregister);

          char linechoice[2] = {0};
          memcpy(linechoice, line+2, 1);
          char selectedchoice=atoi(linechoice);
          if(selectedchoice > 3) selectedchoice=3;
          if(selectedchoice < 0) selectedchoice=0;

          if(choicedata[selectedregister] == selectedchoice) {
            memcpy(jumplabel, line+3, 6);
            goto jumptolabel;
          }
        }
      }

      // 'V' : Set a register to a value
      if(*line == 'V') {
        ParseVCommand();
      }

      // 'C': Offer a choice and store it in a register
      // We also want the same kind of interaction we have with 'W' lines
      // Users *will* want to save before making a choice
      if(*line == 'C') {
        if(strlen(line) == 3) {
          char lineregister[2] = {0};
          memcpy(lineregister, line+1, 1);
          char selectedregister=atoi(lineregister);

          char linechoice[2] = {0};
          memcpy(linechoice, line+2, 1);
          char maxchoice=atoi(linechoice);
          if(maxchoice > 4) maxchoice=4;
          if(maxchoice < 2) maxchoice=2;

          next=readKeyBoardStatus();
          while(!(next>=10 && next<=(9+maxchoice))) {
            next=readKeyBoardStatus();
            if(next == 2) {
              SaveScreen();
              DispQuit();
              QuitMacro();
              next=0;
              RestoreScreen();
            }
            if(next == 3) {
              SaveScreen();
              DispLoadSave(1);
              SaveMacro();
              next=0;
              RestoreScreen();
            }
            if(next == 8) {
              SaveScreen();
              DispLoadSave(2);
              DeleteMacro();
              next=0;
              RestoreScreen();
            }
            if(next == 4) {
              SaveScreen();
              DispLoadSave(0);
              while(NoValidSaveChoice) {
                next=readKeyBoardStatus();
              }
              if(next!=2 && next!=9) {
                HandleSaveFilename();
                RestoreScreen();
                if(fileexists(savefile) == 0) {
                  goto lblloadsave;
                }
              } else {
                RestoreScreen();
              }
              next=0;
            }

            // Don't go back if we can't
            if(next == 5 && savehistory_idx >= 2) {
                save_linenb = savehistory[savehistory_idx - 2];
                savehistory[savehistory_idx - 1] = 0;
                savehistory_idx--;
                skipnexthistory=1;
                DispRollback();
                goto seektoline;
            }

            if(next == 9) {
              SaveScreen();
              DispEsc();
              EscMacro();
              if(lineNumber == 0) break;
              next=0;
              RestoreScreen();
            }

            if(next == 6) {
              SaveScreen();
              DispHelp();
              while(next!=2 && next!=9) {
                  next=readKeyBoardStatus();
              }
              next = 0;
              RestoreScreen();
            }

          }
          if(lineNumber > 0)
            choicedata[selectedregister] = next - 9;
        }
      }

      if(*line == 'D') {
        if(strlen(line+1) < 6) {
          sleep(atoi(line+1));
        }
      }

      if(*line == 'X') {
        if(strlen(line) >= 3) {
          char effect[3] = {0};
          memcpy(effect, line+1, 2);
          char effectnum=atoi(effect);

          // Flush keyboard buffer before rendering effect
          while(Cconis()) Crawcin();

          // Effects 1-40 and 98 invalidate the current picture
          if(effectnum != 99) memset(picture, 0, 18);

          // FxVWipeDown set
          if(effectnum == 1) FxVWipeDown(255);
          if(effectnum == 2) FxVWipeDown(0);
          if(effectnum == 3) {
            FxVWipeDown(255);
            FxVWipeDown(0);
          }
          if(effectnum == 4) {
            FxVWipeDown(0);
            FxVWipeDown(255);
          }

          // FxVWipeUp set
          if(effectnum == 5) FxVWipeUp(255);
          if(effectnum == 6) FxVWipeUp(0);
          if(effectnum == 7) {
            FxVWipeUp(255);
            FxVWipeUp(0);
          }
          if(effectnum == 8) {
            FxVWipeUp(0);
            FxVWipeUp(255);
          }

          // FxVWipeMidIn set
          if(effectnum ==  9) FxVWipeMidIn(255);
          if(effectnum == 10) FxVWipeMidIn(0);
          if(effectnum == 11) {
            FxVWipeMidIn(255);
            FxVWipeMidIn(0);
          }
          if(effectnum == 12) {
            FxVWipeMidIn(0);
            FxVWipeMidIn(255);
          }

          // FxVWipeMidOut set
          if(effectnum == 13) FxVWipeMidOut(255);
          if(effectnum == 14) FxVWipeMidOut(0);
          if(effectnum == 15) {
            FxVWipeMidOut(255);
            FxVWipeMidOut(0);
          }
          if(effectnum == 16) {
            FxVWipeMidOut(0);
            FxVWipeMidOut(255);
          }

          // FxHWipeRight set (left to right)
          if(effectnum == 17) FxHWipeRight(255);
          if(effectnum == 18) FxHWipeRight(0);
          if(effectnum == 19) {
            FxHWipeRight(255);
            FxHWipeRight(0);
          }
          if(effectnum == 20) {
            FxHWipeRight(0);
            FxHWipeRight(255);
          }

          // FxHWipeLeft set (right to left)
          if(effectnum == 21) FxHWipeLeft(255);
          if(effectnum == 22) FxHWipeLeft(0);
          if(effectnum == 23) {
            FxHWipeLeft(255);
            FxHWipeLeft(0);
          }
          if(effectnum == 24) {
            FxHWipeLeft(0);
            FxHWipeLeft(255);
          }

          // FxHWipeMidIn set (edges to middle)
          if(effectnum == 25) FxHWipeMidIn(255);
          if(effectnum == 26) FxHWipeMidIn(0);
          if(effectnum == 27) {
            FxHWipeMidIn(255);
            FxHWipeMidIn(0);
          }
          if(effectnum == 28) {
            FxHWipeMidIn(0);
            FxHWipeMidIn(255);
          }

          // FxHWipeMidOut set (middle to edges)
          if(effectnum == 29) FxHWipeMidOut(255);
          if(effectnum == 30) FxHWipeMidOut(0);
          if(effectnum == 31) {
            FxHWipeMidOut(255);
            FxHWipeMidOut(0);
          }
          if(effectnum == 32) {
            FxHWipeMidOut(0);
            FxHWipeMidOut(255);
          }

          // FxCircleOut set (expanding circle from center)
          if(effectnum == 33) FxCircleOut(255);
          if(effectnum == 34) FxCircleOut(0);
          if(effectnum == 35) {
            FxCircleOut(255);
            FxCircleOut(0);
          }
          if(effectnum == 36) {
            FxCircleOut(0);
            FxCircleOut(255);
          }

          // FxCircleIn set (shrinking circle to center)
          if(effectnum == 37) FxCircleIn(255);
          if(effectnum == 38) FxCircleIn(0);
          if(effectnum == 39) {
            FxCircleIn(255);
            FxCircleIn(0);
          }
          if(effectnum == 40) {
            FxCircleIn(0);
            FxCircleIn(255);
          }

          // FxFadeOut (ordered dither fade to black)
          if(effectnum == 98) FxFadeOut();

          // FxFadeIn (ordered dither fade from black to new image)
          if(effectnum == 99) {
            if(strlen(line) >= 4) {
              int filelen = strlen(line) - 3;
              if(filelen > 12) filelen = 12;
              memset(picture, 0, 18);
              snprintf(picture, 6, "DATA\\");
              memcpy(picture + 5, line + 3, filelen);
              FxFadeIn(picture, background);
              memcpy(oldpicture, picture, 18);
              SaveScreen();
            }
          }

          reset_cursprites();
          spritecount=0;
          // Flush keyboard buffer after rendering effect
          while(Cconis()) Crawcin();
        }
      }

      if(*line == 'A') {
        posx=0;
        posy=0;
        memset(linex, 0, 4);
        memset(liney, 0, 4);
        gzFile sprite;

        // Minimum A + xxx + yyy + filename
        if(strlen(line) < 8) goto endsprite;

        int filelen=strlen(line)-7;
        if(filelen > 0 && spritecount < 256) {
          if(filelen > 12) filelen=12;
          memset(spritefile, 0, 18);
          snprintf(spritefile, 6, "DATA\\");
          memcpy(spritefile+5, line+7, filelen);
          memcpy(linex, line+1, 3);
          memcpy(liney, line+4, 3);
          posx=atoi(linex);
          posy=atoi(liney);
          currentsprites[spritecount].x=atoi(linex);
          currentsprites[spritecount].y=atoi(liney);
          memcpy(currentsprites[spritecount].file, line+7, filelen);
          spritecount++;

          displaysprite:
          sprite=gzopen(spritefile,"rb");
          if(sprite != NULL) {
            char* spritedata;
            char spritebuf[1];
            int x=0;
            int y=0;
            int ppos;
            unsigned int pctsize=0;
            unsigned int pctpos=0;
            char* pctmem;
            unsigned short header;
            unsigned char bytes[4] = {0};

            // We'll now get the uncompressed files size
            int sprfd=open(spritefile, O_RDONLY);
            read(sprfd, &header, 2);

            // gzip or not?
            if(header == 0x1f8b) {
              lseek(sprfd, -4, SEEK_END);
              read(sprfd, &bytes, 4);
              pctsize=bytes[3] << 24 | bytes[2] << 16 | bytes[1] << 8 | bytes[0];
            } else {
              pctsize=lseek(sprfd, -4, SEEK_END);
            }
            close(sprfd);

            pctmem=malloc(pctsize);
            if(pctmem == NULL) goto endsprite;

            gzread(sprite, pctmem, pctsize);
            gzclose(sprite);

            char *videobuffer=malloc(25600);
            if(videobuffer == NULL) goto abortdraw;

            memcpy(videobuffer, videoram, 25600);

            // Now for the drawing routine
            for(pctpos=0; pctpos < pctsize; pctpos++) {
              // Horizontal line change!
              if(pctmem[pctpos] == 10) {
               if(posy+y <= 400) {
                  y++;
                  x=0;
               } else {
                  goto abortdraw;
                }
              }

              // Transparency, don't draw anything
              if(pctmem[pctpos] == ' ') {
                if(x+posx < 639) x++;
              }

             // Actual writing.
             // Thanks, grad'
             if(pctmem[pctpos] == '0' || pctmem[pctpos] == '1') {
                if(x+posx < 639 && posy+y <= 320) {
                  ppos = (y + posy) * 640 + x + posx;
                  if(pctmem[pctpos] == '1') videobuffer[ppos / 8] |= 1 << 7 - (ppos % 8);
                  if(pctmem[pctpos] == '0') videobuffer[ppos / 8] &= ~(1 << 7 - (ppos % 8));
                  x++;
                };
              }
            }
            memcpy(videoram, videobuffer, 25600);

            free(videobuffer);
            abortdraw:
            free(pctmem);
          }
          endsprite:
          if(isbackfunc==1) {
            isbackfunc=0;
            goto spritedrawn;
          }
        }
      }
    }

    // Redraw our text-area border
    RedrawBorder();
    // Just wait a bit... until the next vertical sync.
    Vsync();
  }

  endprog:
  fclose(script);

  // Maybe there wasn't any sound ever? :'(
  if(isplaying == 1) SNDH_StopTune();

  // Restore our beloved(?) keyboard clicks
  write_byte(originalKeyClick, (__uint8_t *)0x484);

  // I Hope I didn't forget anything. This isn't win3 though.
  free(tuneptr);
  free(choicedata);
  free(background);

  // Finally, restore the mouse cursor
  linea9();
}

int main(int argc, char *argv[]) {
  // Disable console cursor
  Cursconf(0,0);

  // Execute our program in supervisor mode
  Supexec(&run);
}
