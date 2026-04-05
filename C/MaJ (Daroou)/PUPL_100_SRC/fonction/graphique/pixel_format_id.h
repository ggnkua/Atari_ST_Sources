/*******************************************************************/
/*                                                                 */
/*                        Pixel Format Code                        */
/*                                                                 */
/*                       Daroou / Renaissance                      */
/*                                                                 */
/* --------------------------------------------------------------- */
/*                                                                 */
/* Utilis‚ par:                                                    */
/* - TGA_SA.LDG & client                                           */
/* - Screen Emulation & client                                     */
/*                                                                 */
/* --------------------------------------------------------------- */
/* Cr‚e le: 01.07.2014                                             */
/* modification le: 16.02.2024                                     */
/*******************************************************************/


#ifndef		__PIXEL_FORMAT_ID_H__
 #define	__PIXEL_FORMAT_ID_H__


 #define PIXEL_FORMAT_INCONNU (-1)  
 #define PIXEL_15_FALCON       (1)   /* RRRRRVVV VV_BBBBB */
 #define PIXEL_15_MOTOROLA     (2)   /* _RRRRRVV VVVBBBBB */
 #define PIXEL_15_INTEL        (3)   /* VVVBBBBB _RRRRRVV */
 #define PIXEL_16_MOTOROLA     (4)   /* RRRRRVVV VVVBBBBB */
 #define PIXEL_16_INTEL        (5)   /* VVVBBBBB RRRRRVVV */
 #define PIXEL_24_MOTOROLA     (6)   /* RRRRRRRR VVVVVVVV BBBBBBBB */
 #define PIXEL_24_INTEL        (7)   /* BBBBBBBB VVVVVVVV RRRRRRRR */
 #define PIXEL_32_MOTOROLA     (8)   /* ________ RRRRRRRR VVVVVVVV BBBBBBBB */
 #define PIXEL_32_INTEL        (9)   /* BBBBBBBB VVVVVVVV RRRRRRRR ________ */
 #define PIXEL_8_PACKED       (10)
 #define PIXEL_8_PLAN         (11)
 #define PIXEL_4_PLAN         (12)
 #define PIXEL_1_PLAN         (13)

#endif  /*  __PIXEL_FORMAT_ID_H__  */

