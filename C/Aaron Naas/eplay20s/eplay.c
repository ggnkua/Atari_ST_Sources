/*

                     *********** Eplay ***********
                          Version 2.0 07/22/90
                             Public Domain

                      The STe audio sample player
                      (via the STe DMA soundchip)

                             By: AAron nAAs
                       AAron@sun.soe.clarkson.edu

                     *****************************


As stated previously, I am releasing this into the public domain, though I
reserve all rights to the executable and the sourcecode.  Copying and
distributing this package AS A WHOLE is not only permitted, but encouraged.
If profit can be made using this package, or ANY part of it, an agreement
must be made with me before any profit can be collected.  

Address:                       E-Mail:
         AAron nAAs                    AAron@sun.soe.clarkson.edu
         8 W. Elizabeth St.
         Skaneateles, NY (USA)
         13152


*/
#include <stdio.h>
#include <osbind.h>
#include <ctype.h>
#include <stat.h>
#include <basepage.h>

#define MAX 32000           /* Maximum size of block to file read */
#define YES 1
#define NO 0
#define DEFAULT_C 0x0081    /* Default control byte: Mono, 12kHz */
#define DEFAULT_E 0x0001    /* Default enable  byte: Play once   */

#define MASK_MICROWIRE 0xff8924L
#define DATA_MICROWIRE 0xff8922L

extern char *lmalloc();     /* needed to do dynamic memory stuff */

main(argc, argv)
int argc;
char *argv[];
{
char infile[80],            /* Name of sample file */
     conv_str[20],          /* To say what conversion is being done */
     conv_type = ' ',       /* For program to realize what conversion to do */
     mix_str[40],           /* To say what mix is being done */
     *start,                /* Sample start address */
     *end,                  /* Sample end address */
     *buffer;               /* Where to load sample to */

FILE *fp;                   /* Standard C file handle */

long fsize,                 /* File size */
     needed;                /* Amount needed to malloc */

int level,                  /* Used to get levels/volumes from command line */
    master_level,           /* Volume-Master from command line to display */
    left_level,             /* Volume-Left from command line to display */
    right_level,            /* Volume-right from command line to display */
    treble_level,           /* Treble level from command line to display */
    bass_level;             /* Bass level from command line to display */

unsigned gavememory = NO,   /* If memory locations are given in command line */
         gavefile = NO,     /* If a filename is given in command line */
         left = YES,        /* If wanted to play through left speaker */
         right = YES,       /* If wanted to play through right speaker */
         putaddress = NO,   /* If we have to give sound chip an address */
         putenable = NO,    /* If we have to give sound chip an enable byte */
         errored = NO,      /* If an error occured during sample loading */
         putcontrol = NO,   /* If we have to give sound chip a control byte */
         gavekill = YES,    /* If user DOESN'T want to protect the sample */
         gaveinfo = YES,    /* If user wants info */
         reserved_mem = NO, /* If we malloced any memory */
         master_volume = 0, /* Word to set master volume */
         left_volume = 0,   /* Word to set left volume */
         right_volume = 0,  /* Word to set right volume */
         treble = 0,        /* Word to set treble */
         bass = 0,          /* Word to set bass */
         mix = 0,           /* Word to set mix */
         playing_rate,      /* To display playing sample rate */
         counter,           /* For various loops */
         cur,               /* Used in uppercase conversion of command line */
         amount,            /* Number of bytes we end up loading from file */
         control_b,         /* Word to set Sound mode control of sound chip */
         enable_b,          /* Word to set sound chip playing */
         *s_enable,         /* Loc of enable register */
         *s_base,           /* Loc of frame base address register */
         *s_end,            /* Loc of frame end address register */
         *s_control;        /* Loc of Sound mode control register */


/* If passed no arguements */

if (argc < 2)
  {
  printf("Try: eplay -HELP\n");
  return;
  }


/* Setup register locations */

s_enable  = (unsigned *) 0xff8900L;
s_base    = (unsigned *) 0xff8902L;
s_end     = (unsigned *) 0xff890eL;
s_control = (unsigned *) 0xff8920L;


/* Zero addresses */

start     = (char *)0L;
end       = (char *)0L;

/* Find out what addresses are in the DMA soundchip, for default */

for (counter = 0; counter < 3; counter ++)
   {
   (long)start <<= 8;
   (long)end   <<= 8;
   (long)start |= (peekw(s_base+counter) & 0x00ff);
   (long)end   |= (peekw(s_end+counter)  & 0x00ff);
   }

infile[0]='\0';


/* Get what is in the DMA soundchip, for default */

control_b = peekw(s_control);
enable_b  = peekw(s_enable);


/* Make command line uppercase */

for (counter = 1; counter < argc; counter ++)
   for (cur = 0; cur < strlen(argv[counter]); cur ++)
      if (isalpha(argv[counter][cur]))
         if (islower(argv[counter][cur]))
            argv[counter][cur] = toupper(argv[counter][cur]);

            
/* Figure out what the user wants */

for (counter = 1; counter < argc;)
  {
  if (argv[counter][0] == '-')
     {
     if (strcmp(&argv[counter][1], "HELP") == 0)
        {
        printf("Usage:\n");
        printf("   [[-L[{R,L}][U]] <filename>] Load:   Load Sample [Right/Left] [Unsigned].\n");
        printf("   [-S <0xhhhhhh> <0xhhhhhh>]  Sample: Sample location.\n");
        printf("   [-M{S,M}]                   Mode:   Stereo/Mono.\n");
        printf("   [-R{0,1,2,3}]               Rate:   6.25/12.5/25/50kHz.\n");
        printf("   [-P{O,L,S}]                 Play:   Once/Loop/Stop.\n");
        printf("   [-V{M,L,R} dd]              Volume: Set Master/Left/Right to dd dB.\n");
        printf("   [-T dd]                     Treble: Set Treble to dd dB.\n");
        printf("   [-B dd]                     Bass:   Set Bass to dd dB.\n");
        printf("   [-X{0,1,2,3}]               Mix:    Set mix -12dB/GI/no GI/Reserved.\n");
        printf("   [-K]                        Keep:   Protect sample memory.\n");
        printf("   [-I]                        Info:   Suppress info listing.\n");
        printf("   [-HELP]                     Help:   This list.\n");
        printf("   [-REMOTEHELP]\n\n");
        printf("Key: Elements between [ and ] are optional,\n");
        printf("     An element between { and } must be selected.\n");
        printf("     Memory locations must be in hex and begin with '0x'\n");
        printf("If only <filename> is given, then it defaults to '-MM -R1 -PO'.\n");
        printf("If -L[{R,L}] or -S is used, NOTHING changes by default,\n");
        printf(" which means it must specifically be told to play, and how.\n");
        gaveinfo = NO;
        counter ++;
        }
     else
     if (strcmp(&argv[counter][1], "REMOTEHELP") == 0)
        {
        printf("Eplay version 2.0 07/22/90 (Public Domain, see Docs)\n\n");
        printf("Something really confusing ya huh?\n");
        printf("For REAL help, contact:\n");
        printf("  AAron@sun.soe.clarkson.edu\n");
        gaveinfo = NO;
        counter ++;
        }
     else
     if (argv[counter][1] == 'M')  /******* Get Mode */
        {
        if (argv[counter][2] == 'S')
           control_b &= 0xff7f;    /* clear mode bit (stereo mode)     */
        else
        if (argv[counter][2] == 'M')
           control_b |= 0x0080;    /* set   mode bit (monophonic mode) */
        else
           {
           printf("Mode '%c' not supported.\n", argv[counter][2]);
           return;
           }
        putcontrol = YES;
        counter ++;
        }
     else
     if (argv[counter][1] == 'V')  /******* Get Volume */
        {
        if ( ((counter + 1) < argc) && isnumber(counter + 1, argv))
           {
           level = 0;
           sscanf(argv[counter + 1], "%d", &level);
           if (level & 1)
              {
              printf("Volume must be even.\n");
              return;
              }
           else
              {
              if (argv[counter][2] == 'M')  /******* Get Master Volume */
                 {
                 if ((level > 0) || (level < -80))
                    {
                    printf("Master volume only -80 to 0\n");
                    return;
                    }
                 else
                    {
                    master_level = level;
                    master_volume = prefixed((80 + level) / 2, 3);
                    }
                 }
              else
              if (argv[counter][2] == 'L')  /******* Get Left Volume */
                 {
                 if ((level > 0) || (level < -40))
                    {
                    printf("Left volume only -40 to 0\n");
                    return;
                    }
                 else
                    {
                    left_level = level;
                    left_volume = prefixed((40 + level) / 2, 5);
                    }
                 }
              else
              if (argv[counter][2] == 'R')  /******* Get Right Volume */
                 {
                 if ((level > 0) || (level < -40))
                    {
                    printf("Right volume only -40 to 0\n");
                    return;
                    }
                 else
                    {
                    right_level = level;
                    right_volume = prefixed((40 + level) / 2, 4);
                    }
                 }
              else
                 {
                 printf("Volume '%c' not supported.\n", argv[counter][2]);
                 return;
                 }
              counter += 2;
              }
           }
        else
           {
           printf("Volume ex: eplay -VM -20\n");
           return;
           }
        }
     else
     if (argv[counter][1] == 'T')  /******* Get Treble */
        {
        if ( ((counter + 1) < argc) && isnumber(counter + 1, argv))
           {
           sscanf(argv[counter + 1], "%d", &level);
           if (level & 1)
              {
              printf("Treble must be even.\n");
              return;
              }
           else
              {
              if ((level > 12) || (level < -12))
                 {
                 printf("Treble only -12 to 12\n");
                 return;
                 }
              else
                 {
                 treble_level = level;
                 treble = prefixed((level / 2) + 6, 2);
                 }
              counter += 2;
              }
           }
        else
           {
           printf("Treble ex: eplay -T 4\n");
           return;
           }
        }
     else
     if (argv[counter][1] == 'B')  /******* Get bass */
        {
        if ( ((counter + 1) < argc) && isnumber(counter + 1, argv))
           {
           sscanf(argv[counter + 1], "%d", &level);
           if (level & 1)
              {
              printf("Bass must be even.\n");
              return;
              }
           else
              {
              if ((level > 12) || (level < -12))
                 {
                 printf("Bass only -12 to 12\n");
                 return;
                 }
              else
                 {
                 bass_level = level;
                 bass = prefixed((level / 2) + 6, 1);
                 }
              counter += 2;
              }
           }
        else
           {
           printf("Bass ex: eplay -B 4\n");
           return;
           }
        }
     else
     if (argv[counter][1] == 'X')  /******* Get Mix */
        {
        if (argv[counter][2] == '3')
           {
           strcpy(mix_str, "Reserved (Beware, unknown results)");
           mix = prefixed(3,0);
           }
        else
        if (argv[counter][2] == '2')
           {
           strcpy(mix_str, "Do not mix GI sound output");
           mix = prefixed(2,0);
           }
        else
        if (argv[counter][2] == '1')
           {
           strcpy(mix_str, "Mix GI sound output (ST sound chip)");
           mix = prefixed(1,0);
           }
        else
        if (argv[counter][2] == '0')
           {
           strcpy(mix_str, "-12 dB");
           mix = prefixed(0,0);
           }
        else
           {
           printf("Mix '%c' not supported.\n", argv[counter][2]);
           return;
           }

        counter ++;
        }
     else
     if (argv[counter][1] == 'R')  /******* Get Rate */
        {
        if (argv[counter][2] == '3')
           control_b |= 0x0003;
        else
        if (argv[counter][2] == '2')
           {
           control_b |= 0x0002;
           control_b &= 0xfffe;
           }
        else
        if (argv[counter][2] == '1')
           {
           control_b &= 0xfffd;
           control_b |= 0x0001;
           }
        else
        if (argv[counter][2] == '0')
           control_b &= 0xfffc;
        else
           {
           printf("Rate '%c' not supported.\n", argv[counter][2]);
           return;
           }

        putcontrol = YES;
        counter ++;
        }
     else
     if (argv[counter][1] == 'P')  /******* Get Play */
        {
        if (argv[counter][2] == 'L')
           enable_b |= 0x0003;
        else
        if (argv[counter][2] == 'S')
           enable_b &= 0xfffc;
        else
        if (argv[counter][2] == 'O')
           {
           enable_b &= 0xfffd;
           enable_b |= 0x0001;
           }
        else
           {
           printf("Play '%c' not supported.\n", argv[counter][2]);
           return;
           }
        counter ++;
        putenable = YES;
        }
     else
     if (argv[counter][1] == 'S')  /******* Get Sample location */
        {
        if ( ((counter + 2) < argc) &&
             (argv[counter + 1][0] == '0') &&
             (argv[counter + 2][0] == '0') &&
             (argv[counter + 1][1] == 'X') &&
             (argv[counter + 2][1] == 'X') )
           {
           sscanf(argv[counter + 1], "%*2c %X", &start);
           sscanf(argv[counter + 2], "%*2c %X", &end);

           /* Make sure we are on word boundaries */
           if ((long)start & 0x1L)
              {
              printf("-S start address must be even.\n");
              return;
              }
           if ((long)end & 0x1L)
              {
              printf("-S end address must be even.\n");
              return;
              }
           gavememory = YES;
           putaddress = YES;
           counter += 3;
           }
        else
           {
           printf("Sample ex: 'eplay -S 0x32f0 0x4a2c -MM -R1 -PO'\n");
           return;
           }
        }
     else
     if (argv[counter][1] == 'K')  /******* Get Keep sample */
        {
        gavekill = NO;
        counter ++;
        }
     else
     if (argv[counter][1] == 'I')  /******* Get Info suppression */
        {
        gaveinfo = NO;
        counter ++;
        }
     else
     if (argv[counter][1] == 'L')  /******* Get Load filename */
        {
        if ( ((counter + 1) < argc) && (isalpha(argv[counter + 1][0])) )
           {
           if (argv[counter][2] == 'R')  /******* Load right */
              {
              left  = NO;
              right = YES;
              }
           if (argv[counter][2] == 'L')  /******* Load left */
              {
              right = NO;
              left  = YES;
              }
           if ((left && right) == NO)   /* If loading stereo, do stereo */
              {
              control_b &= 0xff7f;
              putcontrol = YES;
              }


           /* Check if 'U' was included */

           if ( (left && right && argv[counter][2] == 'U') ||
                (((left && right) == NO) && (argv[counter][3] == 'U')) )
              {
              strcpy(conv_str, "Unsigned");  /* Name of conversion */
              conv_type = 'U';
              }


           /* Get filename */

           strcpy(infile, argv[counter + 1]);

           gavefile = YES;
           putaddress = YES;
           counter +=2;
           }
        else
           {
           printf("Load ex: eplay -LR ste.spl -R1 -MM -PO\n");
           return;
           }
        }
     else
        {
        printf("Unknown switch: %s\n", argv[counter]);
        return;
        }
     }
  else
     {


     /* If no switches then assume it's a filename */
     /* and assumes certain control and enable stuff */

     strcpy(infile, argv[counter]);
     control_b = DEFAULT_C;
     enable_b = DEFAULT_E;
     gavefile = YES;
     putcontrol = YES;
     putenable = YES;
     putaddress = YES;
     counter ++;
     }
  }


/* Decide what rate we are playing at */

if ((control_b & 0x0003) == 0x0003)
   playing_rate = (unsigned) 50066L;
else
if ((control_b & 0x0003) == 0x0002)
   playing_rate = (unsigned) 25033L;
else
if ((control_b & 0x0003) == 0x0001)
   playing_rate = (unsigned) 12517L;
else
if ((control_b & 0x0003) == 0x0000)
   playing_rate = (unsigned) 6258L;



/* Show user his selections */

if (gaveinfo)
   {
   if (gavefile)    /******* If gave a filename */
      {
      printf("File: %s\n",   infile);
      if ((left && right) == NO)    /* if loading into one ear */
         if (left)
            printf("Loading to left\n");
         else
            printf("Loading to right\n");
      if (conv_type != ' ')
         printf("Converting: %s\n", conv_str);
      }

   printf("Play Rate: %u Hz\n", playing_rate);

   if (putenable)    /******* If we are going to give an enable byte */
      {
      if ((enable_b & 0x0003) == 0x0000)
         printf("Play: stop\n");
      else
      if ((enable_b & 0x0003) == 0x0001)
         printf("Play: once\n");
      else
      if ((enable_b & 0x0003) == 0x0003)
         printf("Play: loop\n");
      }
   else
      printf("Play: continue\n"); /**** otherwise, we are just continueing */


   /* Figure what mode */

   if ((control_b | 0xff7f) == 0xffff)
      printf("Mode: monophonic\n");
   else
      printf("Mode: stereo\n");


   /* If we are doing a volume/tone/mix change say what we are doing */

   if (master_volume)
      printf("Master volume: %d dB\n", master_level);

   if (left_volume)
      printf("Left volume: %d dB\n", left_level);

   if (right_volume)
      printf("Right volume: %d dB\n", right_level);

   if (bass)
      printf("Bass: %d dB\n", bass_level);

   if (treble)
      printf("Treble: %d dB\n", treble_level);

   if (mix)
      printf("Mix: %s\n", mix_str);

   }



/* Act out user's requests */

if (gavefile)

   /* Try and open the file, and continue only if successful */

   if ((fp = fopen(infile, "rb")) == NULL)
      {
      printf("Couldn't open file\n");
      errored = YES;
      }
   else
      {


      /* find out file size */

      fseek(fp, 0L, 2);         /* Go to bottom */
      fsize = ftell(fp);
      fseek(fp, 0L, 0);         /* Go to top */


      /* If didn't give a memory location, get one */

      if (gavememory == NO)
         {
         needed = fsize;
         if ((left && right) == NO)   /* Need twice as much to load */
            needed *= 2;              /* whole thing into only one ear */


         /* Add one if "needed" is odd */

         needed += (needed & 0x1L);

         if ((start = lmalloc(needed)) == NULL)
            {
            printf("Couldn't allocate enough memory.\n");
            if (fclose(fp) == EOF)
               printf("Couldn't close file.\n");
            errored = YES;
            }
         else
            {
            end = start + needed;
            reserved_mem = YES;
            }
         }


      /* We have our memory location for loading sample */

      if (errored == NO)
         {
         counter = 0;
         buffer = start;
         while ( fsize > 0 )
            {
            /* If too big for one block, return maximum amount */
            amount = (fsize > MAX)   ? MAX : fsize;

            /* If chunk is too big to fit between "start" and "end" */
            amount = ((buffer + amount) > end) ?  (end - buffer) : amount;

            /* stereo, must load byte at time */
            amount = (right && left) ? amount : 1;

            /* Translating, must load byte at time */
            amount = (conv_type == ' ') ? amount : 1;

            /* if left ear only, must load into high bytes */
            if ((left == NO) && right)
               buffer++;

            if (fread(buffer, 1, amount, fp) != amount)
               {
               printf("Couldn't read whole file.\n");
               if (fclose(fp) == EOF)
                  printf("Couldn't close file.\n");
               free(start);
               fsize = 0;
               errored = YES;
               }
            else
               {
               if (conv_type == 'U')  /* If translating, from Unsigned */
                  *buffer -= 0x80;

               if (left && (right == NO))
                  buffer++;
               fsize -= amount;
               buffer += amount;

               /* If we are already finished, don't mention it,       */
               /* but if we hit the end of our mem space, abort load! */
               if ((fsize > 0) && (buffer >= end))
                  {
                  printf("Ran out of space, read %U (Dec) bytes.\n", ftell(fp));
                  fsize = 0;
                  }
               }
            }


         /* Try and close the file */

         if (fclose(fp) == EOF)
            {
            printf("Couldn't close file.\n");
            free(start);
            }
         }
      }


/* If no errors, give the soundchip the info we have prepared */

if (errored == NO)
   {

   if (master_volume)
      microwire(master_volume, 0x07ff);

   if (right_volume)
      microwire(right_volume, 0x07ff);

   if (left_volume)
      microwire(left_volume, 0x07ff);

   if (treble)
      microwire(treble, 0x07ff);
      
   if (bass)
      microwire(bass, 0x07ff);

   if (mix)
      microwire(mix, 0x07ff);


   /* If we want to change the address in the chip */

   if (putaddress)
      {
      for (counter = 0; counter < 3; counter++ )
         {
         pokew(s_end  + counter,(int)((long)end   >> ((2-counter)*8)) );
         pokew(s_base + counter,(int)((long)start >> ((2-counter)*8)) );
         }
      }


   /* If we changed the control byte */

   if (putcontrol)
      pokew(s_control, control_b);


   /* If we changed the enable byte */

   if (putenable)
      pokew(s_enable, enable_b);


   /* Report the sample we are playing */

   if (gaveinfo)
      printf("Sample location: 0x%lx  to  0x%lx\n", start, end);


   /* If we allocated some memory */

   if (reserved_mem)
      {
      if (gavekill)
         free(start);
      else
         {
         fsize = BP->p_hitpa - BP->p_lowtpa;
         printf("Protected %U (Dec) bytes\n", fsize);
         Ptermres(fsize, 0);
         }
      }
   }
}

/************************************************************************
   Receives a word(num1), and an octal number(num2).
   Returns a word that looks like: 0000 010 + num2 + num1
*/

prefixed(num1, num2)
unsigned num1, num2;
{
unsigned temp;


/* Two bit address field */
temp = 2;


temp <<= 3;

temp |= num2;
temp <<= 6;

temp |= num1;

return(temp);
}

/************************************************************************
  Accepts a number which references an arguement passed on the command line.
  If the arguement begins with a digit, OR if it begins with a sign and is
  followed by a digit, YES is returned, otherwise, NO is returned
*/

isnumber(counter, argv)
int counter;
char *argv[];
{
if (
     isdigit(argv[counter][0])       /* Starts with digit */
     ||
     (
       isdigit(argv[counter][1])     /* Second char is digit */
       &&
       (
         (argv[counter][0] == '-')   /* Starts with '-' */
         ||
         (argv[counter][0] == '+')   /* Starts with '+' */
       )
     )
   )

   return(YES);
else
   return(NO);
}   

/************************************************************************
   Receives data word to put in Microwire data register, and the
   mask word to put in Microwire mask register.
*/

microwire(data, mask)
int data, mask;
{
int old_data, old_mask;

/* Find the Mask and Data values that are already there */

old_data = peekw(DATA_MICROWIRE);
old_mask = peekw(MASK_MICROWIRE);

/* Insert our Mask and Data */

pokew(MASK_MICROWIRE, mask);
pokew(DATA_MICROWIRE, data);

/* Wait for data register to return to it's original value */

while (peekw(DATA_MICROWIRE) != old_data);

/* Put the mask we found back, just to be nice */

pokew(MASK_MICROWIRE, old_mask);
}
