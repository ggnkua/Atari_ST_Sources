#include <stdio.h>
#include <stdlib.h>
#include <tos.h>
#include <ctype.h>
#include <string.h>
#include <portab.h>
#include "scsibios.h"

VOID status(VOID);
VOID check_units(VOID);
VOID show_sector(FILE *fp);

WORD err;
BYTE mbuf[1024];
SCSI_TIMEOUT scsi_timeout;

void main()
{
   BYTE c;
   WORD pdev, ldev, a, b;
   LONG sec;
   BYTE name[100];
   FILE *fp;
   BYTE *filemode;
	BYTE kind;

	scsi_timeout = *SetTimeout((SCSI_TIMEOUT *)-1L);

	scsi_timeout.BeforeCommand = 0UL;
	scsi_timeout.AfterCommand = 0UL;
	scsi_timeout.CommandDelay = 10UL;

	SetTimeout(&scsi_timeout);

   Cconws("\033E");
   do
   {
      Cconws("\033EY = Check,             T = Test,            Z = Status,\
               \r\nD = Display,           R = Read,            W = Write,\
               \r\nS = Request Sense,     L = Lock,            U = Unlock,\
               \r\nE = Erase,             M = Mode Sense       Q = Quit\
               \r\nA = Auxiliary Sense    V = Mode Select      I = Inquiry\
               \r\nO = On/Off             P = Prewind          B = Rewind\
               \r\nF = Format             G = Skip             H = WFM\
               \r\nJ = Buffer to File\
               \r\n\r\n");
      Cconws("Command (? = Help): ");

      c = toupper((WORD)Cconin());
      Cconws("\r\n");

      switch(c)
      {
         case 'V':
            Cconws("pdev ldev bytes : ");
            scanf("%d %d %d", &pdev, &ldev, &a);
            err = MSelect(pdev, ldev, a, mbuf);
            status();
            break;

         case 'J':
            Cconws("Filename : ");
            scanf("%s", name);
            filemode = "w";
            if (fp = fopen(name, "r"))
            {
               Cconws("File exists; append (y/n) : ");
               if (toupper((WORD)Cconin()) == 'Y')
                  filemode = "a";
               fclose(fp);
            }
            if (!(fp = fopen(name, filemode)))
            {
               fprintf(stderr, "Cannot create %s\n", name);
               break;
            }
            show_sector(fp);
            fclose(fp);
            break;

         case 'G':
            Cconws("pdev ldev kind count : ");
            scanf("%d %d %d %d", &pdev, &ldev, &a, &b);
            err = STSkip(pdev, ldev, a, b);
            status();
            break;

         case 'H':
            Cconws("pdev ldev count : ");
            scanf("%d %d %d", &pdev, &ldev, &b);
            err = STWFileM(pdev, ldev, b);
            status();
            break;

         case 'P':
            Cconws("pdev ldev async : ");
            scanf("%d %d %d", &pdev, &ldev, &b);
            err = STPrewind(pdev, ldev, b);
            status();
            break;

         case 'B':
            Cconws("pdev ldev async : ");
            scanf("%d %d %d", &pdev, &ldev, &b);
            err = STRewind(pdev, ldev, b);
            status();
            break;

         case 'F':
            Cconws("pdev ldev ilv : ");
            scanf("%d %d %d", &pdev, &ldev, &a);
            err = HDFormat(pdev, ldev, a);
            status();
            break;

         case 'O':
            Cconws("pdev ldev eject : ");
            scanf("%d %d %d", &pdev, &ldev, &a);
            if (a == 1)
               err = HDStart(pdev, ldev);
            else
               err = HDStop(pdev, ldev, a);
            status();
            break;

         case 'I':
            Cconws("pdev ldev : ");
            scanf("%d %d", &pdev, &ldev);
            memset(mbuf, 0xea, sizeof(mbuf));
            if (!(err = Inquiry(pdev, ldev, 36, mbuf)))
               show_sector(stdout);
            status();
            break;

         case 'A':
            Cconws("pdev ldev : ");
            scanf("%d %d", &pdev, &ldev);
            memset(mbuf, 0xea, sizeof(mbuf));
            if (!(err = STReqAux(pdev, ldev, 36, mbuf)))
               show_sector(stdout);
            status();
            break;

         case 'Y':
            check_units();
            break;

         case 'D':
            show_sector(stdout);
            break;

         case 'Z':
            status();
            break;

         case 'R':
            Cconws("(H)arddisk / (S)treamer : ");
            kind = Cconin();
            Cconws("\r\npdev ldev sec.lx : ");
            scanf("%d %d %lx", &pdev, &ldev, &sec);
            memset(mbuf, 0x40, sizeof(mbuf));
            if (toupper(kind) == 'S')
            {
               if (!(err = STRead(pdev, ldev, 1l, mbuf)))
                  show_sector(stdout);
            }
            else if (toupper(kind) == 'H')
            {
               if (!(err = HDRead(pdev, ldev, sec, 1l, mbuf)))
                  show_sector(stdout);
            }
            status();
            break;

         case 'W':
            Cconws("(H)arddisk / (S)treamer : ");
            kind = Cconin();
            Cconws("\r\npdev ldev sec.lx : ");
            scanf("%d %d %lx", &pdev, &ldev, &sec);
            if (toupper(kind) == 'S')
            {
               if (!(err = STWrite(pdev, ldev, 1l, mbuf)))
                  show_sector(stdout);
            }
            else if (toupper(kind) == 'H')
            {
               if (!(err = HDWrite(pdev, ldev, sec, 1l, mbuf)))
                  show_sector(stdout);
            }
            status();
            break;

         case 'T':
            Cconws("pdev ldev : ");
            scanf("%d %d", &pdev, &ldev);
            err = TestUnit(pdev, ldev);
            status();
            break;

         case 'S':
            Cconws("pdev ldev : ");
            scanf( "%d %d", &pdev, &ldev);
            memset(mbuf, 0xea, sizeof(mbuf));
            if (!(err = ReqSense(pdev, ldev, 127, mbuf)))
               show_sector(stdout);
            status();
            break;

         case 'M':
            Cconws("\r\npdev ldev bytes : ");
            scanf("%d %d %d", &pdev, &ldev, &a);
            memset(mbuf, 0xea, sizeof(mbuf));
            if (!(err = MSense(pdev, ldev, 0, a, mbuf)))
               show_sector(stdout);
            status();
            break;

         case 'L':
            Cconws("pdev ldev : ");
            scanf( "%d %d", &pdev, &ldev);
            err = STLock(pdev, ldev);
            status();
            break;

         case 'U':
            Cconws("pdev ldev : ");
            scanf( "%d %d", &pdev, &ldev);
            err = STUnlock(pdev, ldev);
            status();
            break;

         case 'E':
            Cconws("pdev ldev async : ");
            scanf( "%d %d %d", &pdev, &ldev, &a);
            err = STErase(pdev, ldev, a);
            status();
            break;

         case 'Q':
            Cconws("\033E");
            exit(0);
            break;

         case '?':
            printf("Schau im Source nach wennst Dich nicht auskennst\n");
            Cnecin();
            break;
            
         default:
            break;
      }
   } while (TRUE);
}

VOID status()
{
   if (!err)
   	return;

   printf("\nError = %04x\n",err);
   Cnecin();
}

VOID check_units()
{
   WORD a,b;

   printf("\033E");
   printf("       Sub-Devices\n");
   printf("Unit 0 1 2 3 4 5 6 7\n");
   for (a = 0; a < 16; a++)
   {
      printf(" %02d  ",a);
      for (b = 0; b < 8; b++)
         printf("%c ",(TestUnit(a, b)) ? '-' : 'X');
      printf("\n");
   }
   printf("Taste zum Weitermachen\n");
   Cnecin();
}

VOID show_sector(fp)
FILE *fp;
{
   REG UBYTE *p = mbuf;
   REG WORD a,b;

   if (fp == stdout)
      fprintf(fp, "\033ESector buffer : %08lx\n", p);
   for(b = 0;b < 32;b++)
   {
      fprintf(fp, "%04x: ",b * 16);
       for(a = 0; a < 16; a++)
         fprintf(fp, "%02x ",*p++);
      p -= 16;
      for(a = 0; a < 16; a++)
      {
         fprintf(fp, "%c",(*p >= ' ' && *p != 0x7f) ? *p : '.');
         p++;
      }
      fprintf(fp, "\n");
      if (fp == stdout && b == 15)
         Cnecin();
   }
   if (fp == stdout)
      Cnecin();
}
