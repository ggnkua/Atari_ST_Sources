//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//					        FAT32 File IO Library
//								    V2.5
// 	  							 Rob Riglar
//						    Copyright 2003 - 2010
//
//   					  Email: rob@robriglar.com
//
//-----------------------------------------------------------------------------
//
// Copyright (c) 2003-2007, Rob Riglar - Robs-Projects.com
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY ROBS-PROJECTS.COM ''AS IS'' AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL ROBS-PROJECTS.COM BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <time.h>
#include "define.h"
#include "FAT\fat_access.h"
#include "FAT\fat_filelib.h"
#include "fat_disk.h"

extern void string_test(void);
int GetRandom(int max) { return rand() % (max + 1); }

#define fl_assert(a)	assert(a)

//-----------------------------------------------------------------
// Main: Test bench file to create 5 files with psuedo random
// sequences in of varying lengths - read them back and complete
// then remove them.
//-----------------------------------------------------------------
void main()
{
	int i,j,x;

	FL_FILE * files[5];
	FL_FILE *readFile;
	char filenames[5][260];
	BYTE fileData[5][10000];
	BYTE readBuffer[10000];
	int fileLengths[5];
	BYTE *massiveData;
	time_t timeStart, timeEnd;

#define TESTFILES 6
	char *testfile[] = { "X:\\1", "X:\\1.bin", "X:\\12345678.321",
						 "X:\\mylongfilename", "X:\\mylongfilename.bin",
						 "X:\\the Quick Brown Fox jumped over the lazy dog.elf.binfile.jar"	};

	srand(time(NULL));

	// Initialise
	FAT32_InitDrive();

	fl_init();

	if (fl_attach_media(FAT_ReadSector, FAT_WriteSector) != FAT_INIT_OK)
		return;

	// List directory
	fl_listdirectory("C:\\");
//	return ;

test_start:

	// Generate 5 random files
	memset(filenames, 0x00, 260*5);
	for (j=0;j<5;j++)
	{
		// Length
		fileLengths[j] = GetRandom(9999);

		// Data
		for (x=0;x<fileLengths[j];x++)
			fileData[j][x] = (BYTE)GetRandom(255);

		// Names
		sprintf(filenames[j], "X:\\Auto Generated Filename Number %d", j+1);
	}

	// Create some files
	for (j=0;j<5;j++)
	{
		printf("Creating File: %s [%d bytes]\n", filenames[j], fileLengths[j]);

		// Create File
		files[j] = fl_fopen(filenames[j], "w");
		if (files[j]!=NULL)
		{
			if (fl_fwrite(fileData[j], 1, fileLengths[j], files[j])!=fileLengths[j])
			{
				printf("ERROR: File Write Block Failed File %s Length %d\n", filenames[j], fileLengths[j]);
				fl_assert(0);
			}
		}
		else
		{
			printf("ERROR: Error Creating File %s\n", filenames[j]);
			fl_assert(0);
		}

		fl_fclose(files[j]);

		// Clear buffer
		for (i=0;i<sizeof(readBuffer);i++)
			readBuffer[i] = 0;

		// Verify File
		readFile = fl_fopen(filenames[j], "r");
		if (readFile!=NULL)
		{
			int failed = FALSE;

			printf("File %s Read Check (fread whole file) [%d bytes]\n", filenames[j], fileLengths[j]);

			if (fl_fread(readBuffer, 1, fileLengths[j], readFile)!=fileLengths[j])
			{
				printf("ERROR: File %s Read Length Error %d\n", filenames[j], fileLengths[j]);
				fl_assert(0);
			}

			for (i=0;i<fileLengths[j];i++)
				if ( fileData[j][i] != (BYTE)readBuffer[i] )
					failed = TRUE;

			if (failed)
			{
				printf("ERROR: File %s Data Verify Failed\n", filenames[j]);
				fl_assert(0);
			}
		}
		fl_fclose(readFile);

		// Clear buffer
		for (i=0;i<sizeof(readBuffer);i++)
			readBuffer[i] = 0;

		// Verify File using fgetc
		readFile = fl_fopen(filenames[j], "r");
		if (readFile!=NULL)
		{
			int failed = FALSE;

			printf("File %s Read Check (fgetc) [%d bytes]\n", filenames[j], fileLengths[j]);

			i = 0;
			while (i < fileLengths[j])
			{
				int res = fl_fgetc(readFile);
				if (res == -1)
					break;

				readBuffer[i++] = (BYTE)res;
			}

			if (i != fileLengths[j])
			{
				printf("ERROR: File %s Read Length Error %d\n", filenames[j], fileLengths[j]);
				fl_assert(0);
			}

			for (i=0;i<fileLengths[j];i++)
				if ( fileData[j][i] != (BYTE)readBuffer[i] )
					failed = TRUE;

			if (failed)
			{
				printf("ERROR: File %s Data Verify Failed\n", filenames[j]);
				fl_assert(0);
			}
		}
		fl_fclose(readFile);

		// Clear buffer
		for (i=0;i<sizeof(readBuffer);i++)
			readBuffer[i] = 0;

		// Verify File chunks
		readFile = fl_fopen(filenames[j], "r");
		if (readFile!=NULL)
		{
			int failed = FALSE;

			printf("File %s Read Check (fread chunks) [%d bytes]\n", filenames[j], fileLengths[j]);

			i = 0;
			while (i < fileLengths[j])
			{
				int read_length = GetRandom(1025);

				if (read_length > (fileLengths[j] - i))
					read_length = fileLengths[j] - i;

				if (fl_fread(readBuffer + i, 1, read_length, readFile) != read_length)
				{
					printf("ERROR: File %s fread error\n", filenames[j]);
					fl_assert(0);
					break;
				}

				i += read_length;
			}

			if (i != fileLengths[j])
			{
				printf("ERROR: File %s Read Length Error %d\n", filenames[j], fileLengths[j]);
				fl_assert(0);
			}

			for (i=0;i<fileLengths[j];i++)
				if ( fileData[j][i] != (BYTE)readBuffer[i] )
				{
					failed = TRUE;
					break;
				}

			if (failed)
			{
				printf("ERROR: File %s Data Verify Failed at %d\n", filenames[j], i);
				fl_assert(0);
			}
		}
		fl_fclose(readFile);

		// Delete File
		if (fl_remove(filenames[j])<0)
			printf("ERROR: Delete File %s Failed\n", filenames[j]);

		// Verify file is no longer present!
		readFile = fl_fopen(filenames[j], "r");
		if (readFile != NULL)
		{
			printf("ERROR: File %s still present after delete!\n", filenames[j]);
			fl_assert(0);
			fl_fclose(readFile);
		}
	}

	// Create folder
	fl_createdirectory("C:\\folder1");

#if 0

	// Create massive file
#define MASSIVE_FILE_LEN (1024 * 1024)
	printf("Creating Massive File [%d bytes]\n", MASSIVE_FILE_LEN);

	massiveData = malloc(MASSIVE_FILE_LEN);
	if (!massiveData)
	{
		printf("ERROR: Could not allocate memory for massive array!\n");
		fl_assert(0);
		fl_shutdown();
		return ;
	}

	// Create random data for file
	for (x=0;x<MASSIVE_FILE_LEN;x++)
		massiveData[x] = (BYTE)GetRandom(255);

	// Remove if it already exists!
	fl_remove("X:\\folder1\\massive file.bin");

	timeStart = time(NULL);

	// Create Large File
	readFile = fl_fopen("X:\\folder1\\massive file.bin", "w");
	if (readFile != NULL)
	{
		if (fl_fwrite(massiveData, 1, MASSIVE_FILE_LEN, readFile) != MASSIVE_FILE_LEN)
		{
			printf("ERROR: File Write Block Failed for massive file (Length %d)\n", MASSIVE_FILE_LEN);
			fl_assert(0);
		}
	}
	else
	{
		printf("ERROR: Error Creating massive file\n");
		fl_assert(0);
	}

	fl_fclose(readFile);

	// Verify Massive File
	readFile = fl_fopen("X:\\folder1\\massive file.bin", "r");
	if (readFile!=NULL)
	{
		int failed = FALSE;

		printf("File Massive File Read Check (fread whole file) [%d bytes]\n", MASSIVE_FILE_LEN);

		i = 0;
		while (i < MASSIVE_FILE_LEN)
		{
			int read_length = GetRandom(2048) + 128;

			if (read_length > (MASSIVE_FILE_LEN - i))
				read_length = MASSIVE_FILE_LEN - i;

			if (fl_fread(readBuffer, 1, read_length, readFile) != read_length)
			{
				printf("ERROR: File massive file fread error\n");
				fl_assert(0);
				break;
			}

			for (j=0;j<read_length;j++)
				if ( massiveData[i+j] != (BYTE)readBuffer[j] )
				{
					printf("ERROR: File Massive File Data Verify Failed at %d\n", i+j);
					fl_assert(0);
					break;
				}

			i += read_length;
		}

		if (i != MASSIVE_FILE_LEN)
		{
			printf("ERROR: File massive file Read Length Error %d\n", MASSIVE_FILE_LEN);
			fl_assert(0);
		}
	}
	fl_fclose(readFile);

	timeEnd = time(NULL);
	printf("Time taken %d seconds\n", (int)(timeEnd-timeStart));

	free(massiveData);
#endif

	// Filename test
	for (i=0;i<TESTFILES;i++)
	{
		// Create File
		readFile = fl_fopen(testfile[i], "w");
		if (readFile != NULL)
			;
		else
		{
			printf("ERROR: Error Creating File %s\n", testfile[i]);
			fl_assert(0);
		}

		fl_fputc(0, readFile);
		fl_fclose(readFile);

		readFile = fl_fopen(testfile[i], "r");
		assert(readFile);
		fl_fclose(readFile);
	}

	// List directory
	fl_listdirectory("C:\\");

	for (i=0;i<TESTFILES;i++)
	{
		// Delete File
		if (fl_remove(testfile[i])<0)
		{
			printf("ERROR: Delete File %s Failed\n", testfile[i]);
			fl_assert(0);
		}
	}

	fl_shutdown();

	printf("\r\nCompleted\r\n");

	// List directory
	fl_listdirectory("C:\\");
}
