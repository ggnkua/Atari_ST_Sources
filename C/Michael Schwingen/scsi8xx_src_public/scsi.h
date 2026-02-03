#ifndef _SCSI_H
#define _SCSI_H

#define STAT_GOOD            0x00
#define STAT_CHECK_COND      0x02
#define STAT_COND_MET        0x04
#define STAT_BUSY            0x08
#define STAT_INTERM          0x10
#define STAT_INTERM_COND_MET 0x14
#define STAT_RESERV_CONFLICT 0x18
#define STAT_CMD_TERMINATED  0x22
#define STAT_QUEUE_FULL      0x28

#endif