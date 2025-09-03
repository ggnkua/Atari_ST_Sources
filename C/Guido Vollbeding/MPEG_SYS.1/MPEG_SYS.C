/* MPEG_SYS - Adaption of READFILE.C from MPEG_STAT 2.1 (see below)
 * 	      for analyzing and converting MPEG System Layer Streams.
 *	      (c) 1995 by Guido Vollbeding.
 *	      Ported for Pure-C on Atari TOS.
 *
 * Use with following project file:
 *
 * mpeg_sys.ttp
 * =
 * pcxstart.o
 * mpeg_sys
 * pcfltlib.lib
 * pcstdlib.lib
 * pctoslib.lib
 *
 * ---------------------------
 *
 * MPEGSTAT - analyzing tool for MPEG-I video streams
 *
 * Technical University of Berlin, Germany, Dept. of Computer Science
 * Tom Pfeifer - Multimedia systems project - pfeifer@fokus.gmd.de
 *
 * Jens Brettin, Harald Masche, Alexander Schulze, Dirk Schubert
 *
 * This program uses parts of the source code of the Berkeley MPEG player
 *
 * Copyright (c) 1993 Technical University of Berlin, Germany
 *
 * for the parts of the Berkeley player used:
 *
 * ---------------------------
 *
 * Copyright (c) 1994 The Regents of the University of California.
 * All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement is
 * hereby granted, provided that the above copyright notice and the following
 * two paragraphs appear in all copies of this software.
 *
 * IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
 * OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY OF
 * CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */

/* Change 0 to 1 if using tos.h */
#if 0
#include <tos.h>
#else
#include <osbind.h>
#endif

#include <stdio.h>

long ReadStartCode(void);

int read_sys(long startCode);

void print_stats(void);

void ReadPackHeader(double *systemClockTime, unsigned long *muxRate);

void ReadSystemHeader(void);

int ReadPacket(int packetID);

void ReadTimeStamp(
   unsigned char *inputBuffer,
   unsigned char *hiBit,
   unsigned long *low4Bytes);

void ReadSTD(
   unsigned char *inputBuffer,
   unsigned char *stdBufferScale,
   unsigned long *stdBufferSize);

void ReadRate(
   unsigned char *inputBuffer,
   unsigned long *rate);

void MakeFloatClockTime(
   unsigned char hiBit,
   unsigned long low4Bytes,
   double *floatClockTime);

/* Silly Constants.... */
#define START_CODE_PREFIX        0x00000100L
#define ISO_11172_END_CODE       0x000001b9L
#define PACK_START_CODE          0x000001baL
#define SYSTEM_HEADER_START_CODE 0x000001bbL

#define PACK_HEADER_SIZE   8
#define SYSTEM_HEADER_SIZE 6

#define STD_AUDIO_STREAM_ID 0xb8
#define STD_VIDEO_STREAM_ID 0xb9
#define MIN_STREAM_ID_ID    0xbc
#define RESERVED_STREAM_ID  0xbc
#define PRIVATE_STREAM_1_ID 0xbd
#define PADDING_STREAM_ID   0xbe
#define PRIVATE_STREAM_2_ID 0xbf

#define STD_SYSTEM_CLOCK_FREQ 90000L
#define MUX_RATE_SCALE_FACTOR 50
#define MAX_STREAMS 8


/*  GV: The following stuff is for much more efficient file i/o
 *	than the standard library functions...
 */

#define BUF_LENGTH 80L*1024

typedef struct
{
  unsigned char *pbuf;
  long          bytes_left, length;
  int		handle, EOF_flag;
  unsigned char fbuf[BUF_LENGTH];
}
FBUF;

void Fbufread(FBUF *fp)
{
  long count;

  if (fp->EOF_flag) goto eof;

  if ((count = Fread(fp->handle, BUF_LENGTH, fp->fbuf)) > 0)
    fp->length += count;
  else
  {
    fp->EOF_flag++;
    /*
       Make 32 bits equal to sys end code
       in order to prevent messy data
       from infinite recursion.
    */
    *(long *)fp->fbuf = ISO_11172_END_CODE;
    eof:
    count = 4;
  }
  fp->bytes_left += count;
  fp->pbuf = fp->fbuf;
}

void Fbufwrite(FBUF *fp)
{
  long count;

  count = BUF_LENGTH;
  if (count -= fp->bytes_left)
  {
    fp->pbuf = fp->fbuf;
    fp->bytes_left += count;
    if (fp->EOF_flag) return;
    fp->length += count;
    if (Fwrite(fp->handle, count, fp->fbuf) != count)
      fp->EOF_flag++;
} }

#define MAKESTMT(stuff)	  do { stuff } while (0)

#define FGETC(fp, dest)   \
  MAKESTMT( if (--(fp)->bytes_left < 0) Fbufread(fp); \
	    dest = *(fp)->pbuf++; )

#define FSKIPC(fp)   \
  MAKESTMT( if (--(fp)->bytes_left < 0) Fbufread(fp); \
	    (fp)->pbuf++; )

#define FCOPYC(src, des)   \
  MAKESTMT( if (--(src)->bytes_left < 0) Fbufread(src); \
	    *(des)->pbuf++ = *(src)->pbuf++; \
	    if (--(des)->bytes_left == 0) Fbufwrite(des); )


/* Global file struct to incoming data. */
FBUF input;

FILE *syslogOutput = 0;

FBUF output;

void Usage(void)
{
  fprintf(stderr, "Usage:  mpeg_sys [-l] [input] [output]\n");
  fprintf(stderr, "option -l:\n");
  fprintf(stderr, "\tPut logging of system layer parsing to stdout.\n");
  fprintf(stderr, "input:\n");
  fprintf(stderr, "\tMPEG System Layer Stream.\n");
  fprintf(stderr, "output:\n");
  fprintf(stderr, "\tMPEG Video Stream extracted from input.\n");
}

int main(int argc, char **argv)
{
  long data;

  fprintf(stdout,
    "\nMPEG_SYS " __DATE__ " -- Tool for MPEG-1 System Layer Streams.\n\n");

  if (--argc <= 0) {
    Usage(); return 0;
  }
  ++argv;
  if (argv[0][0] == '-') {
    if (argv[0][1] == 'l' || argv[0][1] == 'L')
      syslogOutput = stdout;
    else
      fprintf(stderr, "Ignoring invalid option %s\n", argv[0]);
    if (--argc <= 0) {
      Usage(); return 0;
    }
    ++argv;
  }

  if ((input.handle = Fopen(argv[0], 0)) < 0) {
    fprintf(stderr, "Can't open input file %s\n", argv[0]);
    return 1;
  }
  input.bytes_left = 0; input.length = 0; input.EOF_flag = 0;

  data = ReadStartCode();
  if (data != PACK_START_CODE && data != SYSTEM_HEADER_START_CODE) {
    fprintf(stderr, "This is not an MPEG System Layer Stream!\n");
    return 0;
  }
  /* Yow, a System Layer Stream.  Much harder to parse.  Call in the
     specialist.... */
  fprintf(stderr, "This is an MPEG System Layer Stream.  "
		  "Audio is not analyzed.\n");

  output.handle = -1;
  if (--argc > 0) {
    if ((output.handle = Fcreate(argv[1], 0)) < 0) {
      fprintf(stderr, "Can't create output file %s\n", argv[1]);
      return 1;
    }
    output.bytes_left = sizeof(output.fbuf);
    output.pbuf = output.fbuf;
    output.length = 0;
    output.EOF_flag = 0;
  }

  /* OK, here's the real work... */
  while (read_sys(data))
    data = ReadStartCode();

  /* Done. Check for errors... */
  data = 0;
  if (input.EOF_flag) {
    data = 1;
    fprintf(stderr,
      "Warning: Read Error or Premature EOF encountered in input stream!\n");
  }
  if (output.handle >= 0) {
    Fbufwrite(&output); /* Flush out last bytes from buffer. */
    if (output.EOF_flag) {
      data = 1;
      fprintf(stderr, "Warning: Write Error occured in output file!\n");
    }
    if (Fclose(output.handle)) {
      data = 1;
      fprintf(stderr, "Warning: Error in closing output file!\n");
    }
  }
  if (data == 0) fprintf(stderr, "Successful parse of MPEG system level.\n");

  /* Print statistics and bye... */
  print_stats(); return 0;
}


/*
  Here is the specialist....
  Code is adapted from our program demux....
  */


/* Statistics */
static long gNumAudioPackets;
static long gNumVideoPackets;
static long gNumPaddingPackets;
static long gNumReservedPackets;
static long gNumPrivate_1_Packets;
static long gNumPrivate_2_Packets;

static long numPacks;
static long numPackets;
static long numSystemHeaders;

static long audBytes;
static long vidBytes;
static long sysBytes;

/* Stream IDs */
static int gAudioStreamID;
static int gVideoStreamID;
static int gReservedStreamID;


/*
 *-----------------------------------------------------------
 *
 *  ReadStartCode
 *
 *      Parses a start code out of the stream
 *
 *  Results:  start code
 *
 *  GV: I hacked this code for searching the next REAL
 *	start code (0x000001xx) in the same manner like
 *	next_start_code() does it in the video decoder.
 *	This seems more reliable (avoids hang-ups in read_sys)
 *	and more flexible (skipping stuffing bytes).
 *
 *-----------------------------------------------------------
 */
long ReadStartCode(void)
{
  long startCode;

  FGETC(&input, (char)startCode); startCode <<= 8;
  FGETC(&input, (char)startCode); startCode <<= 8;
  FGETC(&input, (char)startCode); startCode <<= 8;
  while (startCode != START_CODE_PREFIX) {
    FGETC(&input, (char)startCode); startCode <<= 8;
    sysBytes++;
  }
  FGETC(&input, (char)startCode); sysBytes += 4;
  if (syslogOutput) {
    fprintf(syslogOutput, "Read start code: %08lx\n", startCode);
  }
  return startCode;
}

/*
 *----------------------------------------------------------
 *
 *  read_sys
 *
 *      Parse out a packet of the system layer MPEG file.
 *
 *  Results:  Returns 0 if error or EOF
 *            Returns 1 if more data read
 *
 *----------------------------------------------------------
 */
int read_sys(long startCode)
{
  double systemClockTime;
  unsigned long muxRate;

  while (startCode != ISO_11172_END_CODE) {
    if (startCode == PACK_START_CODE) {
      ++numPacks;
      if (syslogOutput) {
	fprintf(syslogOutput, "PACK #%ld:\n", numPacks);
      }
      ReadPackHeader(&systemClockTime, &muxRate);
    }
    else if (startCode == SYSTEM_HEADER_START_CODE) {
      ++numSystemHeaders;
      if (syslogOutput) {
	fprintf(syslogOutput, "SYSTEM HEADER #%ld:\n", numSystemHeaders);
      }
      ReadSystemHeader();
    }
    else {
      ++numPackets;
      if (syslogOutput) {
	fprintf(syslogOutput, "PACKET #%ld:\n", numPackets);
      }
      if (ReadPacket((int)startCode & 0xff)) return 1;
    }
    startCode = ReadStartCode();
  }
  return 0;
}

void print_stats(void)
{
  fprintf(stdout, "%ld system headers, %ld packs, %ld packets\n",
	  numSystemHeaders, numPacks, numPackets);
  fprintf(stdout, "%ld audio packets, %ld video packets, %ld padding packets\n",
	  gNumAudioPackets, gNumVideoPackets, gNumPaddingPackets);
  fprintf(stdout, "%ld reserved packets, %ld/%ld private type 1/2 packets\n",
	  gNumReservedPackets, gNumPrivate_1_Packets, gNumPrivate_2_Packets);
  fprintf(stdout, "%ld audio bytes, %ld video bytes, %ld system bytes\n",
	  audBytes, vidBytes, sysBytes);
}

/*
 *-----------------------------------------------------------------
 *
 *  ReadPackHeader
 *
 *      Parses out the PACK header
 *
 *-------------------------------------------------------------------
 */
void ReadPackHeader(double *systemClockTime, unsigned long *muxRate)
{
  long numRead;
  unsigned char inputBuffer[PACK_HEADER_SIZE];
  unsigned long systemClockRef;
  unsigned char systemClockRefHiBit;

  for (numRead = 0; numRead < PACK_HEADER_SIZE; numRead++)
    FGETC(&input, inputBuffer[numRead]);
  sysBytes += numRead;
  ReadTimeStamp(inputBuffer, &systemClockRefHiBit, &systemClockRef);
  MakeFloatClockTime(systemClockRefHiBit, systemClockRef, systemClockTime);
  ReadRate(&inputBuffer[5], muxRate);
  *muxRate *= MUX_RATE_SCALE_FACTOR;
  if (syslogOutput) {
    fprintf(syslogOutput, "System clock reference: %d, %lu (0x%x%08lx)\n",
	    (int)systemClockRefHiBit, systemClockRef,
	    (int)systemClockRefHiBit, systemClockRef);
    fprintf(syslogOutput, "System clock time: %1.4lf\n", *systemClockTime);
    fprintf(syslogOutput, "muxRate: %lu (0x%08lx)\n", *muxRate, *muxRate);
  }
}

/*
 *------------------------------------------------------------------
 *
 *   ReadSystemHeader
 *
 *      Parse out the system header, setup out stream IDs for parsing packets
 *
 *   Results:  Sets gAudioStreamID and gVideoStreamID
 *
 *------------------------------------------------------------------
 */
void ReadSystemHeader(void)
{
  unsigned char inputBuffer[SYSTEM_HEADER_SIZE];
  long pos, i, headerSize;
  int streamID;
  /* Only needed for system log file */
  unsigned long rateBound;
  unsigned long audioBound;
  unsigned char fixedFlag;
  unsigned char cspsFlag;
  unsigned long videoBound;
  unsigned char sysAudioLockFlag;
  unsigned char sysVideoLockFlag;
  unsigned char stdBufferScale;
  unsigned long stdBufferSize;

  FGETC(&input, headerSize); headerSize <<= 8;
  FGETC(&input, (char)headerSize);
  sysBytes += headerSize;
  pos = SYSTEM_HEADER_SIZE; if (headerSize < pos) pos = headerSize;
  for (i = 0; i < pos; i++)
    FGETC(&input, inputBuffer[i]);
  if (syslogOutput) {
    for(i = 0; i < pos; i++)
      fprintf(syslogOutput, "%x ", inputBuffer[i]);
    fprintf(syslogOutput,"\n");

    if (headerSize > 4) {
      ReadRate(&inputBuffer[0], &rateBound);
      rateBound *= MUX_RATE_SCALE_FACTOR;
      fprintf(syslogOutput, "rate_bound: %lu (0x%08lx)\n", rateBound, rateBound);
      audioBound = (unsigned long)inputBuffer[3] >> 2;
      fprintf(syslogOutput, "audio_bound: %lu (0x%08lx)\n", audioBound, audioBound);
      fixedFlag = (inputBuffer[3] >> 1) & 0x01;
      fprintf(syslogOutput, "fixed_flag: %d\n", fixedFlag);
      cspsFlag = inputBuffer[3] & 0x01;
      fprintf(syslogOutput, "CSPS_flag: %d\n", cspsFlag);
      videoBound = (unsigned long)inputBuffer[4] & 0x1f;
      fprintf(syslogOutput, "video_bound: %lu (0x%08lx)\n", videoBound, videoBound);
      sysAudioLockFlag = (inputBuffer[4] & 0x80) >> 7;
      fprintf(syslogOutput, "system_audio_lock_flag: %d\n", sysAudioLockFlag);
      sysVideoLockFlag = (inputBuffer[4] & 0x40) >> 6;
      fprintf(syslogOutput, "system_video_lock_flag: %d\n", sysVideoLockFlag);
    }
  }
  headerSize -= pos;
  while (--headerSize >= 0) {
    FGETC(&input, streamID);
    if ((char)streamID >= 0) break;
    if (--headerSize >= 0) FGETC(&input, inputBuffer[1]);
    if (--headerSize >= 0) FGETC(&input, inputBuffer[2]);
    if (syslogOutput) {
      ReadSTD(&inputBuffer[1], &stdBufferScale, &stdBufferSize);
      fprintf(syslogOutput,
              "Read STD_buffer_scale = %d, STD_buffer_size = %lu (0x%0lx)\n",
              (int)stdBufferScale, stdBufferSize, stdBufferSize);
      fprintf(syslogOutput, "System Header: stream with ID 0x%x\n", streamID);
    }
    switch (streamID) {
    case STD_VIDEO_STREAM_ID:
      if (syslogOutput) {
	fprintf(syslogOutput, "System Header: Std video stream\n");
      }
      break;
    case STD_AUDIO_STREAM_ID:
      if (syslogOutput) {
	fprintf(syslogOutput, "System Header: Std audio stream\n");
      }
      break;
    case RESERVED_STREAM_ID:
      if (syslogOutput) {
	fprintf(syslogOutput, "System Header: Reserved stream\n");
      }
      break;
    case PADDING_STREAM_ID:
      if (syslogOutput) {
	fprintf(syslogOutput, "System Header: Padding stream\n");
      }
      break;
    case PRIVATE_STREAM_1_ID:
      if (syslogOutput) {
	fprintf(syslogOutput, "System Header: Private (1) stream\n");
      }
      break;
    case PRIVATE_STREAM_2_ID:
      if (syslogOutput) {
	fprintf(syslogOutput, "System Header: Private (2) stream\n");
      }
      break;
    default:
      if (streamID < MIN_STREAM_ID_ID) {
	if (syslogOutput) {
	  fprintf(syslogOutput, "System Header: Illegal stream ID\n");
	}
	break;
      }
      switch (streamID >> 4) {
      case 0xc:
      case 0xd:
	if (syslogOutput) {
	  fprintf(syslogOutput, "System Header: audio stream #%d\n",
		  (streamID & 0x1f));
	}
	gAudioStreamID = streamID;
	break;
      case 0xe:
	if (syslogOutput) {
	  fprintf(syslogOutput, "System Header: video stream #%d\n",
		  (streamID & 0xf));
	}
	if (gVideoStreamID != 0 && gVideoStreamID != streamID) {
	  fprintf(stderr, "This program can only handle a single video stream\n");
	  break;
	}
	gVideoStreamID = streamID;
	break;
      case 0xf:
	gReservedStreamID = streamID;
	if (syslogOutput) {
	  fprintf(syslogOutput, "System Header: reserved stream #%d\n",
		  (streamID & 0xf));
	}
	break;
      }
      break;
    }
  }
  while (--headerSize >= 0) FSKIPC(&input);
}

/*
 *-----------------------------------------------------------------
 *
 *  ReadPacket
 *
 *      Reads a single packet out of the stream, and puts it in the
 *      buffer if it is video.
 *
 *  Results:  Returns: 0 - not video packet we want
 *		       1 - got video packet into buffer
 *
 *  GV: In difference to the original code, received audio packets
 *      are not signalled to the caller.
 *      But the code for checking of audio is left here, so it can
 *      be simply extended for audio support. At the moment, audio
 *      is skipped over.
 *
 *-----------------------------------------------------------------
 */
int ReadPacket(int packetID)
{
  unsigned char nextByte;
  unsigned short packetLength;
  int pos, i;

  FGETC(&input, (char)packetLength); packetLength <<= 8;
  FGETC(&input, (char)packetLength);
  if (syslogOutput) {
    fprintf(syslogOutput,
	    "input packet with ID %02x has length = %u at file offset %ld\n",
	    packetID, packetLength, input.length - input.bytes_left);
  }
  if (packetID == gAudioStreamID) {
    ++gNumAudioPackets;
  }
  else if (packetID == gVideoStreamID) {
    ++gNumVideoPackets;
  }
  else {
    switch (packetID) {
    case PADDING_STREAM_ID:
      if (syslogOutput) {
	fprintf(syslogOutput, "Padding packet.\n");
      }
      ++gNumPaddingPackets;
      break;
    case RESERVED_STREAM_ID:
      if (syslogOutput) {
	fprintf(syslogOutput, "Reserved packet.\n");
      }
      ++gNumReservedPackets;
      break;
    case PRIVATE_STREAM_1_ID:
      if (syslogOutput) {
	fprintf(syslogOutput, "Private packet type 1.\n");
      }
      ++gNumPrivate_1_Packets;
      break;
    case PRIVATE_STREAM_2_ID:
      if (syslogOutput) {
	fprintf(syslogOutput, "Private packet type 2.\n");
      }
      ++gNumPrivate_2_Packets;
      break;
    default:
      fprintf(stderr, "Unknown packet type encountered. P'bly audio.\n");
    }
    if (syslogOutput) {
      fprintf(syslogOutput, "Skipping over this packet.\n");
    }
    sysBytes += packetLength;
    do FSKIPC(&input);
    while (--packetLength);
    return 0;
  }
  FGETC(&input, nextByte);
  pos = 0;
  while ((char)nextByte < 0) {
    if (syslogOutput) {
      if (nextByte != 0xff)
	fprintf(syslogOutput, "Warning: stuffing byte = 0x%x not 0xff\n",
		(int)nextByte);
    }
    pos++;
    FGETC(&input, nextByte);
  }
  if (pos > 0)
    if (syslogOutput) {
      fprintf(syslogOutput, "Skipped %d stuffing bytes\n", pos);
    }
  if ((nextByte >> 6) == 0x01) {
    pos += 2;
    FSKIPC(&input);
    FGETC(&input, nextByte);
  }
  if ((nextByte >> 4) == 0x02) {
    pos += 5;
    i = 4; do FSKIPC(&input); while (--i);
  }
  else if ((nextByte >> 4) == 0x03) {
    pos += 10;
    i = 9; do FSKIPC(&input); while (--i);
  }
  else {
    pos++;
    if (syslogOutput) {
      fprintf(syslogOutput, "Read 0x%02x (s.b. 0x0f)\n", nextByte);
    }
  }
  sysBytes += pos; packetLength -= pos;
  if (packetID == gVideoStreamID) {
    vidBytes += packetLength;
    if (syslogOutput) {
      fprintf(syslogOutput, "Keeping Video packet of length %u\n",
              packetLength);
    }
    if (output.handle >= 0) {
      do FCOPYC(&input, &output);
      while (--packetLength);
    }
    else {
      do FSKIPC(&input);
      while (--packetLength);
    }
    return 1;
  }
  if (packetID == gAudioStreamID) {
    audBytes += packetLength;
    if (syslogOutput) {
      fprintf(syslogOutput, "Receiving Audio packet of length %u\n",
	      packetLength);
    }
    do FSKIPC(&input);
    while (--packetLength);
  }
  return 0;
}


/*
 * The remaining procedures are formatting utility procedures.
 */
void ReadTimeStamp(
     unsigned char *inputBuffer,
     unsigned char *hiBit,
     unsigned long *low4Bytes)
{
  *hiBit = ((unsigned long)inputBuffer[0] >> 3) & 0x01;
  *low4Bytes = (((unsigned long)inputBuffer[0] >> 1) & 0x03) << 30;
  *low4Bytes |= (unsigned long)inputBuffer[1] << 22;
  *low4Bytes |= ((unsigned long)inputBuffer[2] >> 1) << 15;
  *low4Bytes |= (unsigned long)inputBuffer[3] << 7;
  *low4Bytes |= ((unsigned long)inputBuffer[4]) >> 1;
}

void ReadSTD(
     unsigned char *inputBuffer,
     unsigned char *stdBufferScale,
     unsigned long *stdBufferSize)
{
  *stdBufferScale = ((inputBuffer[0] & 0x20) >> 5);
  *stdBufferSize = ((unsigned long)inputBuffer[0] & 0x1f) << 8;
  *stdBufferSize |= (unsigned long)inputBuffer[1];
}


void ReadRate(
     unsigned char *inputBuffer,
     unsigned long *rate)
{
  *rate = (inputBuffer[0] & 0x7f) << 15;
  *rate |= inputBuffer[1] << 7;
  *rate |= (inputBuffer[2] & 0xfe) >> 1;
}

#define FLOAT_0x10000 (double)((unsigned long)1 << 16)

void MakeFloatClockTime(
     unsigned char hiBit,
     unsigned long low4Bytes,
     double *floatClockTime)
{
  if (hiBit != 0 && hiBit != 1) {
    *floatClockTime = 0.0;
  }
  else {
    *floatClockTime
      = (double)hiBit*FLOAT_0x10000*FLOAT_0x10000 + (double)low4Bytes;
    *floatClockTime /= (double)STD_SYSTEM_CLOCK_FREQ;
  }
}
