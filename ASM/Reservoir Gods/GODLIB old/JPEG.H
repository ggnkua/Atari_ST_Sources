typedef struct
{
void * src_ptr;	  /*  0 */
U8 * file_name;   /*  4 */
U32 src_length;   /*  8 */
U32 dst_length;   /* 12 */
U16 internal1;    /* 16 */
U16 input_type;   /* 18 */
U16 output_type;  /* 20 */
U16 ready_flag;   /* 22 */
U16 internal2;    /* 24 */
U16 internal3;    /* 26 */
void * out_rout0; /* 28 */
void * out_rout1; /* 32 */
void * out_rout2; /* 36 */
void * del_rout;  /* 40 */
U8 i_buffer0[16]; /* 44 */
void * out_rout3; /* 60 */
void * block_ptr; /* 64 */
U16 internal4;    /* 68 */
S16 blocks;       /* 70 */
U16 del_flag;     /* 72 */
U8 i_buffer1[12]; /* 74 */
U16 width;        /* 86 */
U16 height;       /* 88 */
U16 row_size;     /* 90 */
U8 i_buffer2[5200];
} JPEGB_STRUCT;

S32 rljpeg_open();
void * rljpeg_decode(U32 len,void * j_ptr);
S32 rljpeg_close();
U16 rljpeg_get_width();
U16 rljpeg_get_height();

extern S32 rljpeg_command(U16 com, JPEGB_STRUCT * j_ptr);
extern void rljpeg_init_buffer(JPEGB_STRUCT * j_ptr);
extern U16 rljpeg_pixel_size;
extern void * rljpeg_output_addr;

JPEGB_STRUCT my_jpegb;

S32 rljpeg_open()
{
 rljpeg_command(1,&my_jpegb);
}

void * rljpeg_decode(U32 len,void * j_ptr)
{
 void * d_ptr;

 rljpeg_init_buffer(&my_jpegb);
 my_jpegb.input_type=3;
 my_jpegb.output_type=2;
 my_jpegb.src_length=len;
 my_jpegb.src_ptr=j_ptr;
 rljpeg_pixel_size=my_jpegb.output_type<<2;
 rljpeg_command(4,&my_jpegb);
 rljpeg_command(5,&my_jpegb);
 d_ptr=calloc(my_jpegb.dst_length,1);
 rljpeg_output_addr=d_ptr; 
 rljpeg_command(6,&my_jpegb);
 return(d_ptr);
}

U16 rljpeg_get_width()
{
 return(my_jpegb.width);
}

U16 rljpeg_get_height()
{
 return(my_jpegb.height);
}

S32 rljpeg_close()
{
 rljpeg_command(6,&my_jpegb);
}