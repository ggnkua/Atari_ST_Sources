/* This file contains the driver for a DSP (Digital Sound Processor) on
 * a SoundBlaster 16 (ASP) soundcard.
 *
 * The driver supports the following operations (using message format m2):
 *
 *    m_type      DEVICE    PROC_NR     COUNT    POSITION  ADRRESS
 * ----------------------------------------------------------------
 * |  DEV_OPEN  | device  | proc nr |         |         |         |
 * |------------+---------+---------+---------+---------+---------|
 * |  DEV_CLOSE | device  | proc nr |         |         |         |
 * |------------+---------+---------+---------+---------+---------|
 * |  DEV_READ  | device  | proc nr |  bytes  |         | buf ptr |
 * |------------+---------+---------+---------+---------+---------|
 * |  DEV_WRITE | device  | proc nr |  bytes  |         | buf ptr |
 * |------------+---------+---------+---------+---------+---------|
 * |  DEV_IOCTL | device  | proc nr |func code|         | buf ptr |
 * ----------------------------------------------------------------
 *
 * The file contains one entry point:
 *
 *   sb16_task:	main entry when system is brought up
 *
 *  May 20 1995			Author: Michel R. Prevenier 
 */


#include "kernel.h"
#include <minix/com.h> 
#include <minix/callnr.h> 
#include <sys/ioc_sound.h>
#include "sb16.h"

#if ENABLE_SB16

/* prototypes */
FORWARD _PROTOTYPE( void init_buffer, (void));
FORWARD _PROTOTYPE( int dsp_init, (void)); 
FORWARD _PROTOTYPE( int dsp_handler, (int irq));
FORWARD _PROTOTYPE( int dsp_open, (message *m_ptr));
FORWARD _PROTOTYPE( int dsp_close, (message *m_ptr));
FORWARD _PROTOTYPE( int dsp_ioctl, (message *m_ptr));
FORWARD _PROTOTYPE( int dsp_write, (message *m_ptr));
FORWARD _PROTOTYPE( int dsp_read, (message *m_ptr));
FORWARD _PROTOTYPE( int dsp_reset, (void)); 
FORWARD _PROTOTYPE( int dsp_command, (int value));
FORWARD _PROTOTYPE( int dsp_set_speed, (unsigned int speed));
FORWARD _PROTOTYPE( int dsp_set_size, (unsigned int size));
FORWARD _PROTOTYPE( int dsp_set_stereo, (unsigned int stereo));
FORWARD _PROTOTYPE( int dsp_set_bits, (unsigned int bits));
FORWARD _PROTOTYPE( int dsp_set_sign, (unsigned int sign));
FORWARD _PROTOTYPE( void dsp_dma_setup, (phys_bytes address, int count));
FORWARD _PROTOTYPE( void dsp_setup, (void));

/* globals */
PRIVATE int DspVersion[2]; 
PRIVATE unsigned int DspStereo = DEFAULT_STEREO;
PRIVATE unsigned int DspSpeed = DEFAULT_SPEED; 
PRIVATE unsigned int DspBits = DEFAULT_BITS;
PRIVATE unsigned int DspSign = DEFAULT_SIGN;
PRIVATE unsigned int DspFragmentSize = DSP_MAX_FRAGMENT_SIZE;
PRIVATE int DspAvail = 0;
PRIVATE int DspBusy = 0;
PRIVATE int DmaBusy = 0;
PRIVATE int DmaDone = 1;
PRIVATE int DmaMode = 0;

PRIVATE char DmaBuffer[(long)2 * DMA_SIZE];
PRIVATE char *DmaPtr;
PRIVATE phys_bytes DmaPhys;


/*=========================================================================*
 *				sb16_task				   *
 *=========================================================================*/
PUBLIC void sb16_task()
{
  message mess;
  int err, caller, proc_nr;

  /* initialize the DMA buffer */
  init_buffer();

  /* Here is the main loop of the sound task. It waits for a message, carries
   * it out, and sends a reply.
   */
  while (TRUE) 
  {
	receive(ANY, &mess);

	caller = mess.m_source;
	proc_nr = mess.PROC_NR;

	switch (caller) 
        {
   	  case HARDWARE:
		/* Leftover interrupt. */
		continue;
	  case FS_PROC_NR:
		/* The only legitimate caller. */
		break;
	  default:
		printf("sb16: got message from %d\n", caller);
		continue;
	}

	/* Now carry out the work. */
	switch(mess.m_type) 
        {
	    case DEV_OPEN:      err = dsp_open(&mess);break;	
	    case DEV_CLOSE:     err = dsp_close(&mess);break; 
	    case DEV_IOCTL:     err = dsp_ioctl(&mess);break;
	    case DEV_READ:      err = dsp_read(&mess);break;  
	    case DEV_WRITE:     err = dsp_write(&mess);break;
	    default:		err = EINVAL;break;
	}

	/* Finally, prepare and send the reply message. */
	mess.m_type = TASK_REPLY;
	mess.REP_PROC_NR = proc_nr;

	mess.REP_STATUS = err;	/* #bytes transfered or error code */
	send(caller, &mess);	/* send reply to caller */
  }
}


/*===========================================================================*
 *				init_buffer				     *
 *===========================================================================*/
PRIVATE void init_buffer()
{
/* Select a buffer that can safely be used for dma transfers.  
 * Its absolute address is 'DmaPhys', the normal address is 'DmaPtr'.
 */

  DmaPtr = DmaBuffer;
  DmaPhys = vir2phys(DmaBuffer);

  if (dma_bytes_left(DmaPhys) < DMA_SIZE) {
	/* First half of buffer crosses a 64K boundary, can't DMA into that */
	DmaPtr += DMA_SIZE;
	DmaPhys += DMA_SIZE;
  }
}


/*=========================================================================*
 *				dsp_open				   *	
 *=========================================================================*/
PRIVATE int dsp_open(m_ptr)
message *m_ptr;
{

#if SB_DEBUG
  printf("sb16_open\n");
#endif

  /* try to detect SoundBlaster card */
  if (!DspAvail && dsp_init() != OK) return EIO;

  /* Only one open at a time with soundcards */
  if (DspBusy) return EBUSY;
 
  /* Start with a clean DSP */
  if (dsp_reset() != OK) return EIO;

  /* Setup default values */
  DspStereo = DEFAULT_STEREO;
  DspSpeed = DEFAULT_SPEED;
  DspBits = DEFAULT_BITS;
  DspSign = DEFAULT_SIGN;
  DspFragmentSize = DMA_SIZE;
  
  DspBusy = 1;
  DmaBusy = 0;

  return OK;
}


/*=========================================================================*
 *				dsp_close				   *	
 *=========================================================================*/
PRIVATE int dsp_close(m_ptr)
message *m_ptr;
{

#if SB_DEBUG
  printf("dsp_close\n");
#endif

  DspBusy = 0;                  /* soundcard available again */
  DmaBusy = 0;

  return OK;
}


/*=========================================================================*
 *				dsp_ioctl				   *	
 *=========================================================================*/
PRIVATE int dsp_ioctl(m_ptr)
message *m_ptr;
{
  int status;
  phys_bytes user_phys;
  unsigned int val;

  /* Cannot change parameters during play or recording */
  if (DmaBusy) return EBUSY;

  /* Get user data */
  if (m_ptr->REQUEST != DSPIORESET)
  {
    user_phys = numap(m_ptr->PROC_NR, (vir_bytes) m_ptr->ADDRESS, 
                                                   sizeof(unsigned int));
    if (user_phys == 0) return(EFAULT);
    phys_copy(user_phys, vir2phys(&val), (phys_bytes) sizeof(val));
  }

#if SB_DEBUG
  printf("dsp_ioctl: got ioctl %d, argument: %d\n", m_ptr->REQUEST, val);
#endif

  switch(m_ptr->REQUEST)
  {
    case DSPIORATE:	status = dsp_set_speed(val);break;
    case DSPIOSTEREO:	status = dsp_set_stereo(val);break;
    case DSPIOBITS:	status = dsp_set_bits(val);break;
    case DSPIOSIZE:	status = dsp_set_size(val);break;
    case DSPIOSIGN:	status = dsp_set_sign(val);break;
    case DSPIOMAX:	{ 
                           val = DMA_SIZE;
                           phys_copy(vir2phys(&val), user_phys, 
                                           (phys_bytes) sizeof(val));
                           status = OK;
                        };break;
    case DSPIORESET:    status = dsp_reset();break;
    default:            status = ENOTTY;break;
  }

  return status;
}


/*=========================================================================*
 *				dsp_init				   *
 *=========================================================================*/
PRIVATE int dsp_init()
{
  int i;

  if (dsp_reset () != OK) 
  { 
    printf("sb16: No SoundBlaster card detected\n");
    return -1;
  }

  DspVersion[0] = DspVersion[1] = 0;
  dsp_command(DSP_GET_VERSION);	/* Get DSP version bytes */

  for (i = 1000; i; i--)
  {
    if (inb (DSP_DATA_AVL) & 0x80)
    {		
      if (DspVersion[0] == 0)
        DspVersion[0] = inb (DSP_READ);
      else
      {
        DspVersion[1] = inb (DSP_READ);
        break;
      }
    }
  }

  if (DspVersion[0] < 4)
  {
    printf("sb16: No SoundBlaster 16 compatible card detected\n");
    return -1;
  }
  else
    printf ("sb16: SoundBlaster DSP version %d.%d detected\n", 
          DspVersion[0], DspVersion[1]);

  /* set IRQ and DMA channels */
  mixer_set(MIXER_SET_IRQ, (1 << (SB_IRQ / 2 - 1)));
  mixer_set(MIXER_SET_DMA, (1 << SB_DMA_8 | 1 << SB_DMA_16)); 

  /* register interrupt vector and enable irq */
  put_irq_handler(SB_IRQ, dsp_handler);
  enable_irq(SB_IRQ);

  DspAvail = 1;
  return OK;
}


/*=========================================================================*
 *				dsp_handler				   *
 *=========================================================================*/
PRIVATE int dsp_handler(irq)
int irq;
{

#if SB_DEBUG2
  printf("SoundBlaster interrupt %d\n", irq);
#endif 

  if (DmaDone)     /* Dma transfer is done */
  {
    /* Send DSP command to stop dma */
    dsp_command((DspBits == 8 ? DSP_CMD_DMA8HALT : DSP_CMD_DMA16HALT));

    DmaBusy = 0;  /* Dma available again */
  }

  /* Send interrupt to audio task and enable again */
  interrupt(SB16);

  /* Acknowledge the interrupt on the DSP */
  (void) inb((DspBits == 8 ? DSP_DATA_AVL : DSP_DATA16_AVL));

  return 1;
}


/*=========================================================================*
 *				dsp_command				   *
 *=========================================================================*/
PRIVATE int dsp_command(value)
int value;
{
  int             i;

  for (i = 0; i < SB_TIMEOUT; i++)
  {
    if ((inb (DSP_STATUS) & 0x80) == 0)
    {
      outb (DSP_COMMAND, value);
      return OK;
    }
  }

  printf ("sb16: SoundBlaster: DSP Command(%x) timeout\n", value);
  return -1;
}


/*=========================================================================*
 *				dsp_reset				   *
 *=========================================================================*/
PRIVATE int dsp_reset(void)
{
  int i;

  outb (DSP_RESET, 1);
  for(i =0; i<1000; i++); /* wait a while */
  outb (DSP_RESET, 0);

  for (i = 0; i < 1000 && !(inb (DSP_DATA_AVL) & 0x80); i++);	

  if (inb (DSP_READ) != 0xAA) return EIO; /* No SoundBlaster */			

  DmaBusy = 0;
  DmaDone = 1;

  return OK;
}


/*=========================================================================*
 *				dsp_set_speed				   *
 *=========================================================================*/
static int dsp_set_speed(speed)
unsigned int speed;
{
#if SB_DEBUG
  printf("sb16: setting speed to %u, stereo = %d\n", speed, DspStereo);
#endif

  if (speed < DSP_MIN_SPEED || speed > DSP_MAX_SPEED)
    return EPERM;

  /* Soundblaster 16 can be programmed with real sample rates
   * instead of time constants
   *
   * Since you cannot sample and play at the same time
   * we set in- and output rate to the same value 
   */

   lock();   		        		/* disable interrupts */
   dsp_command(DSP_INPUT_RATE);			/* set input rate */
   dsp_command(speed >> 8);			/* high byte of speed */
   dsp_command(speed);			 	/* low byte of speed */
   dsp_command(DSP_OUTPUT_RATE);		/* same for output rate */
   dsp_command(speed >> 8);	
   dsp_command(speed); 
   unlock();					/* enable interrupts */

   DspSpeed = speed;

   return OK;
}


/*=========================================================================*
 *				dsp_set_stereo				   *
 *=========================================================================*/
static int dsp_set_stereo(stereo)
unsigned int stereo;
{
  if (stereo) 
    DspStereo = 1;
  else 
    DspStereo = 0;

  return OK;
}


/*=========================================================================*
 *				dsp_set_bits				   *
 *=========================================================================*/
static int dsp_set_bits(bits)
unsigned int bits;
{
  /* Sanity checks */
  if (bits != 8 && bits != 16) return EINVAL;

  DspBits = bits; 

  return OK;
}


/*=========================================================================*
 *				dsp_set_size				   *
 *=========================================================================*/
static int dsp_set_size(size)
unsigned int size;
{

#if SB_DEBUG
  printf("sb16: set fragment size to %u\n", size);
#endif
 
  /* Sanity checks */
  if (size < DSP_MIN_FRAGMENT_SIZE || 
      size > DSP_MAX_FRAGMENT_SIZE || 
      size % 2 != 0)
    return EINVAL;

  DspFragmentSize = size; 

  return OK;
}


/*=========================================================================*
 *				dsp_set_sign				   *
 *=========================================================================*/
static int dsp_set_sign(sign)
unsigned int sign;
{

#if SB_DEBUG
  printf("sb16: set sign to %u\n", sign);
#endif
 
  DspSign = (sign > 0 ? 1 : 0); 

  return OK;
}


/*===========================================================================*
 *				dsp_dma_setup				     *
 *===========================================================================*/
PRIVATE void dsp_dma_setup(address, count)
phys_bytes address;
int count;

{
#if SB_DEBUG
  printf("Setting up %d bit DMA\n", DspBits);
#endif

  if (DspBits == 8)    /* 8 bit sound */
  {
    count--;     

    lock();
    outb(DMA8_MASK, SB_DMA_8 | 0x04);      /* Disable DMA channel */
    outb(DMA8_CLEAR, 0x00);		   /* Clear flip flop */

    /* set DMA mode */
    outb(DMA8_MODE, 
               (DmaMode == DEV_WRITE ? DMA8_AUTO_PLAY : DMA8_AUTO_REC)); 

    outb(DMA8_ADDR, address >>  0);        /* Low_byte of address */
    outb(DMA8_ADDR, address >>  8);        /* High byte of address */
    outb(DMA8_PAGE, address >> 16);        /* 64K page number */
    outb(DMA8_COUNT, count >> 0);          /* Low byte of count */
    outb(DMA8_COUNT, count >> 8);          /* High byte of count */
    outb(DMA8_MASK, SB_DMA_8);	           /* Enable DMA channel */
    unlock();
  }
  else  /* 16 bit sound */
  {
    count-= 2;

    lock();
    outb(DMA16_MASK, (SB_DMA_16 & 3) | 0x04); /* Disable DMA channel */
    outb(DMA16_CLEAR, 0x00);                  /* Clear flip flop */

    /* Set dma mode */
    outb(DMA16_MODE, 
               (DmaMode == DEV_WRITE ? DMA16_AUTO_PLAY : DMA16_AUTO_REC));        

    outb(DMA16_ADDR, (address >> 1) & 0xFF);  /* Low_byte of address */
    outb(DMA16_ADDR, (address >> 9) & 0xFF);  /* High byte of address */
    outb(DMA16_PAGE, (address >> 16) & 0xFE); /* 128K page number */
    outb(DMA16_COUNT, count >> 1);            /* Low byte of count */
    outb(DMA16_COUNT, count >> 9);            /* High byte of count */
    outb(DMA16_MASK, SB_DMA_16 & 3);          /* Enable DMA channel */
    unlock();
  }
}


/*===========================================================================*
 *				dsp_setup				     *
 *===========================================================================*/
PRIVATE void dsp_setup()
{ 
  /* Set current sample speed */
  dsp_set_speed(DspSpeed);

  /* Put the speaker on */
   if (DmaMode == DEV_WRITE)
   {
     dsp_command (DSP_CMD_SPKON); /* put speaker on */

      /* Program DSP with dma mode */
      dsp_command((DspBits == 8 ? DSP_CMD_8BITAUTO_OUT : DSP_CMD_16BITAUTO_OUT));     
   }
   else
   {
     dsp_command (DSP_CMD_SPKOFF); /* put speaker off */

     /* Program DSP with dma mode */
     dsp_command((DspBits == 8 ? DSP_CMD_8BITAUTO_IN : DSP_CMD_16BITAUTO_IN));     
   }

  /* Program DSP with transfer mode */
  if (!DspSign)
    dsp_command((DspStereo == 1 ? DSP_MODE_STEREO_US : DSP_MODE_MONO_US));
  else
    dsp_command((DspStereo == 1 ? DSP_MODE_STEREO_S : DSP_MODE_MONO_S));

  /* Give length of fragment to DSP */
  if (DspBits == 8) /* 8 bit transfer */
  {
    /* #bytes - 1 */
    dsp_command((DspFragmentSize - 1) >> 0); 
    dsp_command((DspFragmentSize - 1) >> 8);
  }
  else              /* 16 bit transfer */
  {
    /* #words - 1 */
    dsp_command((DspFragmentSize - 1) >> 1);
    dsp_command((DspFragmentSize - 1) >> 9);
  }
}
      

/*===========================================================================*
 *				dsp_write				     *
 *===========================================================================*/
PRIVATE int dsp_write(m_ptr)
message *m_ptr;
{
  phys_bytes user_phys;
  message mess;

  if (m_ptr->COUNT != DspFragmentSize) return EINVAL;

  /* From this user address */
  user_phys = numap(m_ptr->PROC_NR, (vir_bytes)m_ptr->ADDRESS, DspFragmentSize);
  if (user_phys == 0) return EINVAL;

  if (DmaBusy)    /* Dma already started */
  {
    if (DmaMode != m_ptr->m_type) return EBUSY;

    DmaDone = 0;  /* No, we're not done yet */

    /* Wait for next block to become free */
    receive(HARDWARE, &mess); 

    /* Copy first block to dma buffer */
    phys_copy(user_phys, DmaPhys, (phys_bytes) DspFragmentSize);

  }
  else /* A new dma transfer has started */    
  {
    DmaMode = DEV_WRITE;           /* Dma mode is writing */

    /* Copy fragment to dma buffer */    
    phys_copy(user_phys, DmaPhys, (phys_bytes) DspFragmentSize);

    /* Set up the dma chip */
    dsp_dma_setup(DmaPhys, DspFragmentSize);  

    /* Set up the DSP */
    dsp_setup();
      
    DmaBusy = 1;         /* Dma is busy */
  }

  DmaDone = 1;            /* dma done for now */

  return(DspFragmentSize);
}


/*===========================================================================*
 *				dsp_read				     *
 *===========================================================================*/
PRIVATE int dsp_read(m_ptr)
message *m_ptr;
{
  phys_bytes user_phys;
  message mess;
 
  if (m_ptr->COUNT != DspFragmentSize) return EINVAL;

  /* To this user address */
  user_phys = numap(m_ptr->PROC_NR, (vir_bytes)m_ptr->ADDRESS, DspFragmentSize);
  if (user_phys == 0) return EINVAL;

  if (DmaBusy)     /* Dma already started */
  {
    if (DmaMode != m_ptr->m_type) return EBUSY;

    DmaDone = 0;   /* No, we're not done yet */ 

    /* Wait for a full dma buffer */
    receive(HARDWARE, &mess); 

    /* Copy the buffer */
    phys_copy(DmaPhys, user_phys, (phys_bytes) DspFragmentSize);
  }
  else  /* A new dma transfer has started */
  {
    DmaMode = DEV_READ;                /* Dma mode is reading */

    /* Set up the dma chip */
    dsp_dma_setup(DmaPhys, DspFragmentSize);  
 
    /* Set up the DSP */
    dsp_setup();

    DmaBusy = 1;       /* Dma has started */
    DmaDone = 0;       /* Dma not done */

    /* Wait for dma to finish with first block */
    receive(HARDWARE, &mess);

    /* Copy dma buffer to user */
    phys_copy(DmaPhys, user_phys, (phys_bytes) DspFragmentSize);
  }

  DmaDone = 1;   /* dma done for now */

  return(DspFragmentSize);
}
#endif /* ENABLE_SB16 */
