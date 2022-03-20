int init_dsp(void);
void init_mpeg_decoder(void);
void decode_mpeg_sequence(char *s);
void decode_mpeg(char *frame);
void get_numBitsAlowed_I(uchar alloc[32][2],char *frame);
void get_ScaleFactors(uchar scale[32][2],uchar alloc[32][2],char *frame);
void get_samples(int *dsp,uchar alloc[32][2],char *frame);


void My_Dsp_BlkBytes(void *adr,int size);
void My_Dsp_BlkWords(void *adr,int size);
