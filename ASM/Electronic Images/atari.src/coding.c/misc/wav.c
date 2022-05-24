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

    if(argc < 2) {
        fprintf(stderr, "Syntax: wav filename\n");
        return -1;
    }
    fp = fopen(argv[1], "rb");
    if(fp == NULL) {
        fprintf(stderr, "Cant open %s\n", argv[1]);
        return -1;
    }
    fread(&Wave, sizeof(struct WavHdr), 1, fp);
    printf("Header size %d\n", sizeof(struct WavHdr));
    fclose(fp);

    printf("\nWave File: %s\n", argv[1]);
    if(strncmp(Wave.rID, "RIFF", 4) == 0)
        printf("Got Valid RIFF ID\n");
    else
        return -1;

    printf("Length of data chunk: %d\n", Wave.rLen);
    if(strncmp(Wave.Data.wID, "WAVE", 4) == 0)
        printf("Got Valid WAVE ID\n");
    else
        return -1;

    if(strncmp(Wave.Data.Format.fID, "fmt ", 4) == 0)
        printf("Got Valid fmt ID\n");
    else
        return -1;

    printf("Length of format chunk: %d\n", Wave.Data.Format.fLen);
    printf("Wave Format: %d\n", Wave.Data.Format.wFormatTag);
    printf("Number of channels: %d\n", Wave.Data.Format.nChannels);
    printf("Samples Per Second: %d\n", Wave.Data.Format.nSamplesPerSec);
    printf("Average Bytes Per Sec: %d\n", Wave.Data.Format.nAvgBytesPerSec);
    printf("Block Align: %d\n", Wave.Data.Format.nBlockAlign);
    printf("Format Specific1: %d\n", Wave.Data.Format.FormatSpecific1);
    printf("Format Specific2: %d\n", Wave.Data.Format.FormatSpecific2);
    printf("Sample Bits: %d\n", Wave.Data.Format.SampleBits);
    if(strncmp(Wave.Data.Data.dId, "data", 4) == 0)
        printf("Got Valid data ID\n");
    else
        return -1;

    printf("Length Of Data Block: %d\n", Wave.Data.Data.dLen);

    return 0;
}
