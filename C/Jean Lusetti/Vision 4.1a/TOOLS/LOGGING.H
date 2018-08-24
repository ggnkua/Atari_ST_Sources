#ifndef __LOGGING
#define __LOGGING

#include <stdarg.h>

#define BIT(x)      (1L << (x))
/* Bit#        24       16        8        0           */
/*      |--------|--------|--------|--------|          */
/*      |          | |  |  |  |   ||||| ||-----TMP1    */
/*      |          | |  |  |  |   ||||| |------TMP2    */
/*      |          | |  |  |  |   |||||--------KEYCODE */
/*      |          | |  |  |  |   ||||---------DEBUG   */
/*      |          | |  |  |  |   |||----------GW1     */
/*      |          | |  |  |  |   ||-----------GW2     */
/*      |          | |  |  |  |   |-----------MEM      */
/*      |          | |  |  |  |---------------PERF     */
/*      |          | |  |  |------------------INFO     */
/*      |          | |  |---------------------WARNING  */
/*      |          | |------------------------ERROR    */
/*      |          |--------------------------FATAL    */
/* Bit#           22   17    12   8   5  2             */
/* Bit#             20   15             3  0           */
/*                                                     */
#define LL_DISABLED 0x0
#define LL_FATAL    BIT(22)
#define LL_ERROR    BIT(20)
#define LL_WARNING  BIT(17)
#define LL_INFO     BIT(15)
#define LL_PERF     BIT(12)
#define LL_MEM      BIT(8)
#define LL_GW2      BIT(7)
#define LL_GW1      BIT(6)
#define LL_DEBUG    BIT(5)
#define LL_KEYCODE  BIT(4)
#define LL_TMP2     BIT(3)
#define LL_TMP1     BIT(2)

#define LF_CLRLOGSONSTART  0x0001

typedef struct __LOGGING_CONFIG
{
  unsigned long Level ;
  unsigned long MaxFileSize ;
  unsigned int  Flags ;
  unsigned int  MaxNbArchives ;
  unsigned int  FlushFreq ;
}
LOGGING_CONFIG, *PLOGGING_CONFIG ;

#if !defined(__NO_LOGGING)
extern void          LoggingGetDefaultConfig(LOGGING_CONFIG* config) ;
extern int           LoggingInit(char* filename, LOGGING_CONFIG* config);
extern unsigned long LoggingGetLevel(void);
extern int           LoggingDo(unsigned long level, char* format, ...);
extern int           LoggingvDo(unsigned long level, char* format, va_list argp);
extern char*         LoggingGetLabelLevels(unsigned long level_mask, char* labels, size_t labels_size) ;
extern void          LoggingClose(void);

#else
#define LoggingGetDefaultConfig
#define LoggingInit
#define LoggingClose()
#define LoggingGetLevel()       LL_DISABLED
#define LoggingDo
#define LoggingvDo
#define LoggingGetLabelLevels   ""
#endif

#endif
