/*
 * Driver for the PSC of the Freescale MCF548X configured as AC97 interface
 *
 * Copyright (C) 2009 Didier Mequignon.
 *
 * This file is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#ifndef __MCF548X_AC97_H
#define __MCF548X_AC97_H

/* ioctl */
#define SOUND_MIXER_READ_VOLUME 0x80044D00
#define SOUND_MIXER_READ_BASS 0x80044D01
#define SOUND_MIXER_READ_TREBLE 0x80044D02
#define SOUND_MIXER_READ_SYNTH 0x80044D03
#define SOUND_MIXER_READ_PCM 0x80044D04
#define SOUND_MIXER_READ_SPEAKER 0x80044D05
#define SOUND_MIXER_READ_LINE 0x80044D06
#define SOUND_MIXER_READ_MIC 0x80044D07
#define SOUND_MIXER_READ_CD 0x80044D08
#define SOUND_MIXER_READ_IMIX 0x80044D09
#define SOUND_MIXER_READ_ALTPCM 0x80044D0A
#define SOUND_MIXER_READ_RECLEV 0x80044D0B
#define SOUND_MIXER_READ_IGAIN 0x80044D0C
#define SOUND_MIXER_READ_OGAIN 0x80044D0D
#define SOUND_MIXER_READ_LINE1 0x80044D0E
#define SOUND_MIXER_READ_LINE2 0x80044D0F
#define SOUND_MIXER_READ_LINE3 0x80044D10
#define SOUND_MIXER_READ_MUTE 0x80044D1C
#define SOUND_MIXER_READ_ENHANCE 0x80044D1D
#define SOUND_MIXER_READ_LOUD 0x80044D1E
#define SOUND_MIXER_READ_RECSRC 0x80044DFF
#define SOUND_MIXER_READ_DEVMASK 0x80044DFE
#define SOUND_MIXER_READ_RECMASK 0x80044DFD
#define SOUND_MIXER_READ_STEREODEVS 0x80044DFB
#define SOUND_MIXER_READ_CAPS 0x80044DFC
#define SOUND_MIXER_WRITE_VOLUME 0xC0044D00
#define SOUND_MIXER_WRITE_BASS 0xC0044D01
#define SOUND_MIXER_WRITE_TREBLE 0xC0044D02
#define SOUND_MIXER_WRITE_SYNTH 0xC0044D03
#define SOUND_MIXER_WRITE_PCM 0xC0044D04
#define SOUND_MIXER_WRITE_SPEAKER 0xC0044D05
#define SOUND_MIXER_WRITE_LINE 0xC0044D06
#define SOUND_MIXER_WRITE_MIC 0xC0044D07
#define SOUND_MIXER_WRITE_CD 0xC0044D08
#define SOUND_MIXER_WRITE_IMIX 0xC0044D09
#define SOUND_MIXER_WRITE_ALTPCM 0xC0044D0A
#define SOUND_MIXER_WRITE_RECLEV 0xC0044D0B
#define SOUND_MIXER_WRITE_IGAIN 0xC0044D0C
#define SOUND_MIXER_WRITE_OGAIN 0xC0044D0D
#define SOUND_MIXER_WRITE_LINE1 0xC0044D0E
#define SOUND_MIXER_WRITE_LINE2 0xC0044D0F
#define SOUND_MIXER_WRITE_LINE3 0xC0044D10
#define SOUND_MIXER_WRITE_MUTE 0xC0044D1C
#define SOUND_MIXER_WRITE_ENHANCE 0xC0044D1D
#define SOUND_MIXER_WRITE_LOUD 0xC0044D1E
#define SOUND_MIXER_WRITE_RECSRC 0xC0044DFF
#define SOUND_MIXER_WRITE_POWERDOWN 0xC004DF0

#define RECORD_SOURCE_MIC        0
#define RECORD_SOURCE_CD         1
#define RECORD_SOURCE_VIDEO      2
#define RECORD_SOURCE_AUX        3
#define RECORD_SOURCE_LINE       4
#define RECORD_SOURCE_STEREO_MIX 5
#define RECORD_SOURCE_MONO_MIX   6
#define RECORD_SOURCE_PHONE      7

#define MONO16          3      /* Set 16-bit mono playback */
#define RECORD_STEREO16 0x0000 /* Set 16-bit stereo capture */
#define RECORD_STEREO8  0x0100 /* Set 8-bit  stereo capture */
#define RECORD_MONO8    0x0200 /* Set 8-bit  mono capture */
#define RECORD_MONO16   0x0300 /* Set 16-bit mono capture */

#define LEFT_CHANNEL_VOLUME(v) ((v) & 0xff)
#define RIGHT_CHANNEL_VOLUME(v) ((v >> 8) & 0xff)

int mcf548x_ac97_playback_open(long psc_channel);
int mcf548x_ac97_playback_close(long psc_channel);
int mcf548x_ac97_playback_prepare(long psc_channel, long frequency, long res, long mode);
int mcf548x_ac97_playback_callback(long psc_channel, void (*callback)());
int mcf548x_ac97_playback_trigger(long psc_channel, long cmd);
int mcf548x_ac97_playback_pointer(long channel, void **ptr, long set);
int mcf548x_ac97_capture_open(long psc_channel);
int mcf548x_ac97_capture_close(long psc_channel);
int mcf548x_ac97_capture_prepare(long psc_channel, long frequency, long res, long mode);
int mcf548x_ac97_capture_callback(long psc_channel, void (*callback)());
int mcf548x_ac97_capture_trigger(long psc_channel, long cmd);
int mcf548x_ac97_capture_pointer(long channel, void **ptr, long set);
int mcf548x_ac97_ioctl(long psc_channel, unsigned int cmd, void *arg);
int mcf548x_ac97_debug_read(long psc_channel, long reg);
int mcf548x_ac97_debug_write(long psc_channel, long reg, long val);
int mcf548x_ac97_install(long psc_channel);
int mcf548x_ac97_uninstall(long psc_channel, int free);

#endif /* __MCF548X_AC97_H */
