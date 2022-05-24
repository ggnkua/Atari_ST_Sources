#include <stdio.h>
#include <string.h>

#pragma pack(0);

struct Fmt {
    char    fID[4];
    int     fLen;
    short   wFormatTag;
    short   nChannels;
    short   nSamplesPerSec;
    short   nAvgBytesPerSec;
    short   nBlockAlign;
    short   FormatSpecific1;
    short   FormatSpecific2;
    short   SampleBits;
};


struct DataChk {
    char    dId[4];
    int     dLen;
};


struct rData    {
    char    wID[4];
    struct  Fmt Format;
    struct  DataChk Data;
};

struct WavHdr {
    char    rID[4];
    int     rLen;
    struct  rData Data;
};


int main(int argc, char *argv[])
{
    FILE *fp;
    struct WavHdr   Wave;

    memcpy(&(Wave.rID), "RIFF", 4);
    Wave.rLen = sizeof(struct rData);
    memcpy(&(Wave.Data.wID), "WAVE", 4);
    memcpy(&(Wave.Data.Format.fID), "fmt ", 4);
    Wave.Data.Format.fLen = 16;
    Wave.Data.Format.wFormatTag = 1;
    Wave.Data.Format.nChannels = 1;
    Wave.Data.Format.nSamplesPerSec = 8000;
    Wave.Data.Format.nAvgBytesPerSec = 0;
    Wave.Data.Format.nBlockAlign = 8000;
    Wave.Data.Format.FormatSpecific1 = 0;
    Wave.Data.Format.FormatSpecific2 = 1;
    Wave.Data.Format.SampleBits = 8;
    memcpy(&(Wave.Data.Data.dId), "data", 4);
    Wave.Data.Data.dLen = 1;

    fp = fopen("mywav.wav", "wb");
    if(fp != NULL) {
        fwrite(&Wave, sizeof(struct WavHdr)+1, 1, fp);
        printf("Written\n");
        printf("Header Size: %d\n", sizeof(struct WavHdr)+10);
        fclose(fp);
    }
    return 0;
}
