'---------------------------------------------------------------'
' DecompressPAK.vbs                                             '
' Version 1.0 - July 23, 2008                                   '
' Written by Christophe Fontanel                                '
'                                                               '
' Please visit the Dungeon Master Encyclopaedia                 '
' at http://dmweb.free.fr/ for more information                 '
'---------------------------------------------------------------'




Option Explicit

Const ForReading = 1, ForWriting = 2

Dim strCompressedData, intCompressedDataPosition, intBufferBitCount, intBitBuffer

Function GetBits(pintRequestedBitCount)
        If intBufferBitCount < pintRequestedBitCount Then
                intBitBuffer = intBitBuffer * 2^8 + (Asc(Mid(strCompressedData, intCompressedDataPosition + 1, 1)))
                intBufferBitCount = intBufferBitCount + 8
                intCompressedDataPosition = intCompressedDataPosition + 1
        End If
        GetBits = intBitBuffer \ 2^(intBufferBitCount - pintRequestedBitCount)
        intBitBuffer = intBitBuffer And (2^(intBufferBitCount - pintRequestedBitCount) - 1)
        intBufferBitCount = intBufferBitCount - pintRequestedBitCount
End Function


Dim objScriptArguments
Set objScriptArguments = WScript.Arguments
If objScriptArguments.Count = 0 Then
        MsgBox "This tool decompresses a START.PAK compressed executable file from Dungeon Master and Chaos Strikes Back for Atari ST versions." & vbCrLf & vbCrLf & _
        "Usage example: at a command prompt, type the following command line:" & vbCrLf & _
        "   DecompressPAK.vbs START.PAK" & vbCrLf & _
        "You can also drag and drop a START.PAK file on DecompressPAK.vbs in Windows Explorer." & vbCrLf & vbCrLf &  _
        "The decompressed file will be saved in the same folder as the compressed file.", vbOKOnly + vbInformation, "Usage"
Else
        Dim objFileSystemObject
        Set objFileSystemObject = CreateObject("Scripting.FileSystemObject")
        
        Dim strSourceFileName
        strSourceFileName = objScriptArguments(0)
        Dim objSourceFile
        Set objSourceFile = objFileSystemObject.GetFile(strSourceFileName)
        Dim intSourceFileSize
        intSourceFileSize = objSourceFile.Size
        Set objSourceFile = objFileSystemObject.OpenTextFile(strSourceFileName, ForReading)

        Dim arrMostFrequentWords(1919)

        Dim intWordCount
        intWordCount = (Asc(objSourceFile.Read(1)) * 256 + Asc(objSourceFile.Read(1))) * 65536 + (Asc(objSourceFile.Read(1)) * 256 + Asc(objSourceFile.Read(1))) - 14

        Dim strDestinationFileHeader
        strDestinationFileHeader = objSourceFile.Read(28)

        Dim intIndex
        For intIndex = 0 To 1919
                arrMostFrequentWords(intIndex) = Asc(objSourceFile.Read(1)) * 256 + Asc(objSourceFile.Read(1))
        Next

        strCompressedData = objSourceFile.Read(intSourceFileSize - 28)

        intBitBuffer = 0      ' The intBitBuffer is empty
        intBufferBitCount = 0 ' So there are no bits stored in the buffer
        intCompressedDataPosition = 0

        Dim intControlValue, intFrequentWordIndex
        Dim arrDestinationFileCharacters()
        ReDim arrDestinationFileCharacters(intWordCount * 2 - 1)
        For intIndex = 0 To intWordCount - 1
                intControlValue = GetBits(4)
                If intControlValue = &H0F Then ' Get word directly from compressed input
                        arrDestinationFileCharacters(2 * intIndex) = Chr(GetBits(8))
                        arrDestinationFileCharacters(2 * intIndex + 1) = Chr(GetBits(8))
                Else ' Get word from array of most frequent words
                        If intControlValue >= &H08 Then
                                intFrequentWordIndex = (intControlValue * 256 + GetBits(8)) - 1920 ' 12 bit index value, range 128 to 1919
                        Else
                                intFrequentWordIndex = (intControlValue * 16 + GetBits(4)) ' 8 bit index value, range 0 to 127
                        End If
                        arrDestinationFileCharacters(2 * intIndex) = Chr(arrMostFrequentWords(intFrequentWordIndex) \ 256)
                        arrDestinationFileCharacters(2 * intIndex + 1) = Chr(arrMostFrequentWords(intFrequentWordIndex) And &HFF)
                End If
        Next

        objSourceFile.Close

        Dim strDestinationFileName
        ' Build destination file name with full path
        strDestinationFileName = strSourceFileName & " DECOMPRESSED.PRG"

        Dim objDestinationFile
        Err.Clear
        Set objDestinationFile = objFileSystemObject.OpenTextFile(strDestinationFileName, ForWriting, True)
        If Err.Number <> 0 Then
                MsgBox "Unable to create the destination file: " & strDestinationFileName & vbCrLf & Err.Description, vbOKOnly + vbCritical, "Error"
        Else
                Err.Clear
                objDestinationFile.Write(strDestinationFileHeader)
                objDestinationFile.Write(Join(arrDestinationFileCharacters, ""))
                If Err.Number <> 0 Then
                        MsgBox "Unable to write the destination file." & vbCrLf & Err.Description, vbOKOnly + vbCritical, "Error"
                Else
                        MsgBox "The file " & vbCrLf & vbCrLf & strDestinationFileName & vbCrLf & vbCrLf & " was successfully created.", vbOKOnly + vbInformation, "Information"
                End If
                objDestinationFile.Close
        End If
End If
