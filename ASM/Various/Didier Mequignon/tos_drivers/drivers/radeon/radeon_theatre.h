#ifndef __THEATRE_H__
#define __THEATRE_H__

#define DEFAULT_MICROC_PATH "c:\ativcm20.cod"

#define MODE_UNINITIALIZED		1
#define MODE_INITIALIZATION_IN_PROGRESS 2
#define MODE_INITIALIZED_FOR_TV_IN	3

typedef struct
{
	struct radeonfb_info *rinfo;
	int theatre_num;
	unsigned long theatre_id;
	int  mode;
	unsigned short video_decoder_type;
	unsigned long wStandard;
	unsigned long wConnector;
	int iHue;
	int iSaturation;
	unsigned long wSaturation_U;
	unsigned long wSaturation_V;
	int iBrightness;
	int dbBrightnessRatio;
	unsigned long wSharpness;
	int iContrast;
	int dbContrast;
	unsigned long wInterlaced;
	unsigned long wTunerConnector;
	unsigned long wComp0Connector;
	unsigned long wSVideo0Connector;
	unsigned long dwHorzScalingRatio;
	unsigned long dwVertScalingRatio;
} TheatreRec, * TheatrePtr;

TheatrePtr DetectTheatre(struct radeonfb_info *rinfo);

/* DO NOT FORGET to setup constants before calling InitTheatre */
void InitTheatre(TheatrePtr t);

void RT_SetTint(TheatrePtr t, int hue);
void RT_SetSaturation(TheatrePtr t, int Saturation);
void RT_SetBrightness(TheatrePtr t, int Brightness);
void RT_SetSharpness(TheatrePtr t, unsigned short wSharpness);
void RT_SetContrast(TheatrePtr t, int Contrast);
void RT_SetInterlace(TheatrePtr t, unsigned char bInterlace);
void RT_SetStandard(TheatrePtr t, unsigned short wStandard);
void RT_SetCombFilter(TheatrePtr t, unsigned short wStandard, unsigned short wConnector);
void RT_SetOutputVideoSize(TheatrePtr t, unsigned short wHorzSize, unsigned short wVertSize, unsigned char fCC_On, unsigned char fVBICap_On);
void CalculateCrCbGain(TheatrePtr t, double *CrGain, double *CbGain, unsigned short wStandard);
void RT_SetConnector(TheatrePtr t, unsigned short wConnector, int tunerFlag);

void ShutdownTheatre(TheatrePtr t);
void ResetTheatreRegsForTVout(TheatrePtr t);

/* RT200 */

#define DSP_OK						0x21
#define DSP_INVALID_PARAMETER		0x22
#define DSP_MISSING_PARAMETER		0x23
#define DSP_UNKNOWN_COMMAND			0x24
#define DSP_UNSUCCESS				0x25
#define DSP_BUSY					0x26
#define DSP_RESET_REQUIRED			0x27
#define DSP_UNKNOWN_RESULT			0x28
#define DSP_CRC_ERROR				0x29
#define DSP_AUDIO_GAIN_ADJ_FAIL		0x2a
#define DSP_AUDIO_GAIN_CHK_ERROR	0x2b
#define DSP_WARNING					0x2c
#define DSP_POWERDOWN_MODE			0x2d

#define RT200_NTSC_M				0x01
#define RT200_NTSC_433				0x03
#define RT200_NTSC_J				0x04
#define RT200_PAL_B					0x05
#define RT200_PAL_D					0x06
#define RT200_PAL_G					0x07
#define RT200_PAL_H					0x08
#define RT200_PAL_I					0x09
#define RT200_PAL_N					0x0a
#define RT200_PAL_Ncomb				0x0b
#define RT200_PAL_M					0x0c
#define RT200_PAL_60				0x0d
#define RT200_SECAM					0x0e
#define RT200_SECAM_B				0x0f
#define RT200_SECAM_D				0x10
#define RT200_SECAM_G				0x11
#define RT200_SECAM_H				0x12
#define RT200_SECAM_K				0x13
#define RT200_SECAM_K1				0x14
#define RT200_SECAM_L				0x15
#define RT200_SECAM_L1				0x16
#define RT200_480i					0x17
#define RT200_480p					0x18
#define RT200_576i					0x19
#define RT200_720p					0x1a
#define RT200_1080i					0x1b

struct rt200_microc_head
{
	unsigned int device_id;
	unsigned int vendor_id;
	unsigned int revision_id;
	unsigned int num_seg;
};

struct rt200_microc_seg
{
	unsigned int num_bytes;
	unsigned int download_dst;
	unsigned int crc_val;
	unsigned char* data;
	struct rt200_microc_seg* next;
};

struct rt200_microc_data
{
	struct rt200_microc_head		microc_head;
	struct rt200_microc_seg*		microc_seg_list;
};

#endif
