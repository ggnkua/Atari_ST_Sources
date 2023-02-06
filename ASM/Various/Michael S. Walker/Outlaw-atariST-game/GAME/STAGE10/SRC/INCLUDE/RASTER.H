/*
 * Michael S. Walker <mwalk762@mtroyal.ca>
 *	    _    _
 *       | |  | |	OUTLAW. 
 *      -| |  | |- 
 *  _    | |- | |
 *-| |   | |  | |- 	
 * |.|  -| ||/  |
 * | |-  |  ___/ 
 *-|.|   | | |
 * |  \_|| |
 *  \____  |
 *   |   | |- 
 *       | |
 *      -| |
 *       |_| Copyleft !(c) 2020 All Rights Unreserved in all Federations, including Alpha Centauris.
 */

#ifndef RASTER_H
#define RASTER_H

#include <MODEL.H> /* for struct Sprite */
#include <TYPES.H> /* for PrintScreen */

#define SCREEN_WIDTH_NBITS 640
#define SCREEN_HEIGHT_NBITS 400
#define N_BITS_IN_WORD 8 /* for PlotHline */

#define UINT8_N_COL 80
#define UINT16_N_COL 40
#define UINT32_N_COL 20
#define N_UINT64_IN_WIDTH 10

#define UINT8_ROW_OFFSET(y) ((y)*UINT8_N_COL)
#define UINT8_OFFSET(row, col) (UINT8_ROW_OFFSET(row) + (col))

#define UINT16_ROW_OFFSET(y) ((y)*UINT16_N_COL)
#define UINT16_OFFSET(row, col) (UINT16_ROW_OFFSET(row) + (col))

#define UINT32_ROW_OFFSET(y) ((y)*UINT32_N_COL)
#define UINT32_OFFSET(row, col) (UINT32_ROW_OFFSET(row) + (col))

uint8_t *GetVideoBase(void);
void SetVideoBase(uint8_t *scrbuf);
extern void *GetBuffer(void);
extern void SetBuffer(void *scrbuf);

void PLotRectangle(const void *base, int length, int width, int x_pos, int y_pos);
void PlotHline(const void *base, int y0, int x0, int xf);
void PlotVline(const void *base, int x0, int y0, int yf);
void Plot8Pixels(unsigned char *base, int x, int y);
void PlotPoint(unsigned char *base, int x, int y);

void PlotChar(const void *base, int x0, int y0, uint8_t bm);

void PrintScreen(const void *base, Sprite *sprite);
extern void ClearScreen(void *screen);

void Rast8Alpha(const void *base, Sprite *sprite);
void Rast8Draw(const void *base, Sprite *sprite);
void Rast8Clear(const void *base, Sprite *sprite);

void Rast16Alpha(const void *base, Sprite *sprite);
void Rast16Clear(const void *base, Sprite *sprite);
void Rast16Draw(const void *base, Sprite *sprite);

void Rast32Alpha(const void *base, Sprite *sprite);
void Rast32Clear(const void *base, Sprite *sprite);
void Rast32Draw(const void *base, Sprite *sprite);

#endif /* BITMAP_H */
