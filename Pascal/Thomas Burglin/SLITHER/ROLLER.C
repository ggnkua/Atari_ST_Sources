/*  routine to roll an applemuncher screen    */

#include "extern.h"

roll (fields,level,mode)

   unsigned char  fields[30][5][38];
   int     level;
   int     mode;
   
   {
   int j, k;
   int bit[38];
   
   if (mode == 3)
      {
      for (k = 0; k < 38; k++)
         {
         bit[k] = fields[level][4][k] & 2;
         fields[level][4][k] >>= 1;
         fields[level][4][k] |= 1;
         if (fields[level][3][k] & 1) fields[level][4][k] |= 128;
         }
      for (j = 3; j > 0; j--)
         {
         for (k = 0; k < 38; k++)
            { 
            fields[level][j][k] >>= 1;
            if (fields[level][j-1][k] & 1) fields[level][j][k] |= 128;
            }
         }   
      for (k = 0; k < 38; k++)
         {
         fields[level][0][k] >>= 1;
         fields[level][0][k] |= 128;
         if (bit[k] < 1) fields[level][0][k] &= (~64);
         }        
      }
   if (mode == 2)
      {
      for (k = 0; k < 38; k++)
         {
         bit[k] = fields[level][0][k] & 64;
         fields[level][0][k] <<= 1;
         fields[level][0][k] |= 128;
         if (fields[level][1][k] & 128) fields[level][0][k] |= 1;
         }
      for (j = 1; j < 4; j++)
         {
         for (k = 0; k < 38; k++)
            { 
            fields[level][j][k] <<= 1;
            if (fields[level][j+1][k] & 128) fields[level][j][k] |= 1;
            }
         }   
      for (k = 0; k < 38; k++)
         {
         fields[level][4][k] <<= 1;
         fields[level][4][k] |= 1;
         if (bit[k] < 1) fields[level][4][k] &= (~2);
         }        
      }
   if (mode == 0)
      {
      for (j = 0; j < 5; j++)
         bit[j] = fields[level][j][0];
      for (k = 0; k < 37; k++)
         {
         for (j = 0; j < 5; j++)
            fields[level][j][k] = fields[level][j][k+1];
         }
      for (j = 0; j < 5; j++)
         fields[level][j][37] = bit[j];
      }        
   if (mode == 1)
      {
      for (j = 0; j < 5; j++)
         bit[j] = fields[level][j][37];
      for (k = 36; k >= 0; k--)
         {
         for (j = 0; j < 5; j++)
            fields[level][j][k+1] = fields[level][j][k];
         }
      for (j = 0; j < 5; j++)
         fields[level][j][0] = bit[j];
      }        
   }   	   
