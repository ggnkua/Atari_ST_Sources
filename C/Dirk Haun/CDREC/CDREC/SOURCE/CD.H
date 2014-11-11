/*  CD-Defines
 */

#ifndef BYTE
# define BYTE unsigned char
#endif

struct cdrom_msf
{
 BYTE cdmsf_min0;
 BYTE cdmsf_sec0;
 BYTE cdmsf_frame0;
 BYTE cdmsf_min1;
 BYTE cdmsf_sec1;
 BYTE cdmsf_frame1;
};

struct cdrom_tochdr
{
 BYTE cdth_trk0;
 BYTE cdth_trk1;
};

typedef union
{
 struct
 {
  BYTE reserved, minute, second, frame;
 } msf;
 long lba;
} cd_ad;

#define CDROM_LBA  0x01
#define CDROM_MSF  0x02

#define CDROM_LEADOUT 0xaa

struct cdrom_tocentry
{
 BYTE cdte_track;  /* input */
 BYTE cdte_format;
 unsigned cdte_adr : 4; /* output */
 unsigned cdte_ctrl: 4;
 BYTE cdte_datamode;
 cd_ad dte_addr;
};

struct cdrom_read
{
 long cdread_lba;
 char *cdread_bufaddr;
 long cdread_buflen;
};

struct cdrom_subchnl
{
 BYTE cdsc_format; /* input */
 BYTE cdsc_audiostatus; /* output */
 unsigned cdsc_resvd : 8;
 unsigned cdsc_adr   : 4;
 unsigned cdsc_ctrl  : 4;
 BYTE cdsc_trk;
 BYTE cdsc_ind;
 cd_ad cdsc_absaddr;
 cd_ad cdsc_reladdr;
};

#define CDROMREADOFFSET      (('C'<<8)|0x00)
#define CDROMPAUSE           (('C'<<8)|0x01)
#define CDROMRESUME          (('C'<<8)|0x02)
#define CDROMPLAYMSF         (('C'<<8)|0x03)
#define CDROMPLAYTRKIND      (('C'<<8)|0x04)
#define CDROMREADTOCHDR      (('C'<<8)|0x05)
#define CDROMREADTOCENTRY    (('C'<<8)|0x06)
#define CDROMSTOP            (('C'<<8)|0x07)
#define CDROMSTART           (('C'<<8)|0x08)
#define CDROMEJECT           (('C'<<8)|0x09)
#define CDROMVOLCTRL         (('C'<<8)|0x0A)
#define CDROMSUBCHNL         (('C'<<8)|0x0B)
#define CDROMREADMODE2       (('C'<<8)|0x0C)
#define CDROMREADMODE1       (('C'<<8)|0x0D)
#define CDROMPREVENTREMOVAL  (('C'<<8)|0x0E)
#define CDROMALLOWRMOVAL     (('C'<<8)|0x0F)
#define CDROMAUDIOCTRL       (('C'<<8)|0x10)
#define CDROMREADDA          (('C'<<8)|0x11)
#define CDROMGETMCN          (('C'<<8)|0x13)
#define CDROMGETTISRC        (('C'<<8)|0x14)

typedef struct
{
 unsigned short  mi_version;
 long            mi_magic;
 const char     *mi_log2phys;
} META_INFO_2;

typedef struct
{
 unsigned long  mi_drivemap;
 const char    *mi_version_string;
 long           reserved;
 META_INFO_2   *mi_info;
} META_INFO_1;

typedef struct
{
 char *mdr_name;
 long  res[3];
} META_DRVINFO;

typedef struct
{
 unsigned char disctype;
 unsigned char firsttrack, lasttrack, curtrack;
 unsigned char relposz, relposm, relposs, relposf;
 unsigned char absposz, absposm, absposs, absposf;
 unsigned char endposz, endposm, endposs, endposf;
 unsigned char index, res[3];
 unsigned long reserved[123];
} CD_DISC_INFO;

void Metainit(META_INFO_1 *buffer)
{
 xbios(0x30,buffer);
}

long Metaopen(short drive,META_DRVINFO *buffer)
{
 return(xbios(0x31,drive,buffer));
}

long Metaclose(short drive)
{
 return(xbios(0x32,drive));
}

long Metaioctl(short drive,long magic,short opcode,void *buffer)
{
 return(xbios(0x37,drive,magic,opcode,buffer));
}

long Metadiscinfo(short drive,CD_DISC_INFO *p)
{
 return(xbios(0x3f,drive,p));
}
