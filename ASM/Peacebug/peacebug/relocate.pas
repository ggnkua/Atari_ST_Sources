program Relocate;

USES	TOS;

CONST	flags:LONGINT=4+2+1;

VAR handle,a,length:LONGINT;
	p:ARRAY[1..256*3] OF LONGINT;
BEGIN		
	IF (Fsfirst('PEACEBUG.PRG',0)=0) THEN
	BEGIN
		handle:=FOPEN('PEACEBUG.PRG',FO_RW);
		IF handle>=0 THEN
		BEGIN
			Fseek(2,handle,0);
			Fread(handle,16,@p[1]);						{ Header lesen						}
			Fseek(28+2+7*4,handle,0);					{ zu TEXT-/DATA-/BSS_Length seeken	}
			Fwrite(handle,12,@p[1]);					{ TEXT-/DATA-/BSS_Length schreiben	}
			Fseek(28+p[1]+p[2]+p[4],handle,0);			{ zur Reloziertabelle seeken		}
			length:=Fgetdta^.d_length-28-p[1]-p[2]-p[4];{L„nge Reloziertabelle				}
			Fread(handle,length,@p[1]);					{ Reloziertabelle lesen				}
			Fseek(54,handle,0);							{ Zeiger auf RELOC_TABELLE			}
			Fread(handle,4,@a);							{ lesen								}
			Fseek(a,handle,0);							{ zu RELOC_TABELLE seeken			}
			Fwrite(handle,length,@p[1]);				{ Reloziertabelle schreiben			}
			Fseek(22,handle,0);							{ zu den Flags seeken				}
			Fwrite(handle,4,@flags);					{ Flags schreiben					}
		END;
		Fclose(handle);
	END;
END.