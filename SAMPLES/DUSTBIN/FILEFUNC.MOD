(****************************************************************************)
(*
   FileFunctions V0.05a (FileFunc.MOD)
   ====================
   
   Programmierer: Alexander Graf (Mat.Nr. 9355752)
                  Dietmar Schinnerl (Mat.Nr. 9355075)
   Projekt: Fallstudie Betriebssysteme: Windowsprogrammierung mit Oberon-2
   Compiler: POW! Oberon-2
   
                           (C) by Alexander Graf & Dietmar Schinnerl, 1996
                           
 ---------------------------------------------------------------------------
  Stellt verschiedenste Dateifunktionen, wie Kopieren und Verschieben, zur
 Verfuegung.
 ---------------------------------------------------------------------------
 
 History:                          
 
  19.08.1996 / 0.05a : Dokumentation
  08.07.1996 / 0.04a : SplitFullName
  08.06.1996 / 0.03a : CreateDir
  25.05.1996 / 0.02a : SetFileInfo, CopyFileEx, MoveFileEx
  21.05.1996 / 0.01a : FullName
  19.05.1996 / 0.00a : Grundgeruest
                       CopyFile, _CopyFile, MoveFile, TempFileName
                                                                            *)
(****************************************************************************)

MODULE FileFunctions;

 
 (***************************************************************************)
 (* Benoetige Module importieren                                            *)
 
 IMPORT SYSTEM,
        File,
        Volume,
        Utils,
        Strings,
        WndTools,
        Windows;
 

 (***************************************************************************)
 (* globale Typen, Konstanten und Variablen                                 *)

 CONST OK* = 0;
       ERROR* = 1;


 (***************************************************************************)


 (*-------------------------------------------------------------------------
   <CreateDir> erzeugt ein oder mehrere (verschachtelte) Verzeichnisse. Ist
   das letzte Zeichen im Uebergabeparameter 'dir' kein Backslash ('\'), dann 
   wird angenommen, dass der letzte Teil ein Filename und kein Verzeichnis 
   ist.
   -------------------------------------------------------------------------*)  

 PROCEDURE CreateDir* (dir : ARRAY OF CHAR) : BOOLEAN;
  VAR ctr : LONGINT;
      resCode : INTEGER;
      dirName : ARRAY 128 OF CHAR;
  BEGIN
   dirName := "";
   Strings.Append (dirName, dir);
   ctr := Strings.Length (dir) - 1;
   WHILE (ctr > 0) & (dirName[ctr] # "\") DO
    DEC (ctr);
   END;
   dirName[ctr] := CHR (0);
   Volume.ChangeDirectory (dirName, resCode);
   IF (resCode = Volume.NOERROR)
    THEN RETURN TRUE;
   END;

   (* Laufwerksangabe? *)
   dirName := "";
   IF (dir[1] = ':')
    THEN 
     Strings.Copy (dir, dirName, 1, 2);
     ctr := 2;
    ELSE
     ctr := 0;
   END;
   
   WHILE (dir[ctr] # CHR(0)) DO
    REPEAT
     Strings.AppendChar (dirName, dir[ctr]);
     INC (ctr);
    UNTIL (dir[ctr] = CHR(0)) OR (dir[ctr] = '\');
    
    IF (dir[ctr] = '\')
     THEN Volume.CreateDirectory (dirName, resCode);
    END;
   END;
   
   (* Nur wenn das letzte Verzeichnis nicht erzeugt werden koennte *)
   (* Fehler zurueckliefern.                                       *)
   RETURN (resCode = Volume.NOERROR);
  END CreateDir;
  

 (*-------------------------------------------------------------------------
   <MakeFullName> erzeugt aus Verzeichnisname und Dateiname einen Dateinamen
   mit Pfadangabe. (Der Verzeichnisname muss mit einem '\' abgeschlossen
   sein.
   -------------------------------------------------------------------------*)  

 PROCEDURE MakeFullName* (dir, name : ARRAY OF CHAR;
                          VAR fullName : ARRAY OF CHAR);
  BEGIN
   fullName[0] := CHR (0);
   Strings.Append (fullName, dir);
   Strings.Append (fullName, name);
  END MakeFullName;


 (*-------------------------------------------------------------------------
   <TempFileName> erzeugt einen Dateinamen fuer eine temporaere Datei.
   -------------------------------------------------------------------------*)  

 PROCEDURE TempFileName* (VAR fileName : ARRAY OF CHAR;
                          ext : ARRAY OF CHAR);
  VAR day, month, year, dayOfWeek, sec, min, hour : INTEGER;
      sum : LONGINT;
  BEGIN
   Utils.GetDate (day, month, year, dayOfWeek);
   Utils.GetTime (sec, min, hour);
   
   sum := (month + day) * 86400 + (hour + min) * 60 + sec;
 
   Strings.HexStr (sum, fileName);
   
   IF Strings.Length (fileName) > 9
    THEN fileName[8] := CHR (0);
    ELSE fileName[Strings.Length (fileName)-1] := CHR (0);
   END;
   
   Strings.AppendChar (fileName, ".");
   Strings.Append (fileName, ext);
  END TempFileName;


 (*-------------------------------------------------------------------------
   <SetFileInfo> dient dazu die Zeit-/Datumsinformationen einer Datei zu
   setzen.
   
   Bemerkung: timeStamp = "dd.mm.yyyy  hh:mm"
   -------------------------------------------------------------------------*)  

 PROCEDURE SetFileInfo* (fileName : ARRAY OF CHAR;
                         timeStamp : ARRAY OF CHAR;
                         attr : SET) : BOOLEAN;
  VAR resCode : INTEGER;
      hFile : File.Handle;
      time : ARRAY 21 OF CHAR;
  BEGIN
   time := "";
   Strings.Append (time, timeStamp);
   Strings.Append (time, ":00");
   
   File.Open (fileName, 
              FALSE, 
              File.DENYREAD, 
              File.READWRITE, 
              hFile, resCode);
     
   IF (resCode = File.NOERROR)
    THEN 
     File.SetModifyDate (hFile, time, resCode);
     File.Close (hFile);

     IF (resCode = File.NOERROR)
      THEN
       File.SetAttributes (fileName, attr, resCode);
       
       RETURN (resCode = File.NOERROR);
     END;  
   END;
   
   RETURN FALSE;
  END SetFileInfo;
  
   
 (*-------------------------------------------------------------------------
   <_CopyFile> kopiert eine Datei in eine andere Datei.
   -------------------------------------------------------------------------*)  

 PROCEDURE _CopyFile (src, dest : File.Handle);
  VAR buffer : POINTER TO ARRAY 16384 OF CHAR;
      resCode : INTEGER;
      read : LONGINT;
  BEGIN
   NEW (buffer);

   REPEAT 
    File.ReadBlock (src, buffer^, 16384, read, resCode);
    
    IF (read > 0)
     THEN File.WriteBlock (dest, buffer^, read, resCode);
    END;
   UNTIL (read = 0) OR (resCode # File.NOERROR);

   DISPOSE (buffer);
  END _CopyFile;

   
 (*-------------------------------------------------------------------------
   <CopyFile> kopiert Datei 'source' nach Datei 'dest'.
   -------------------------------------------------------------------------*)  
   
 PROCEDURE CopyFile* (source, dest : ARRAY OF CHAR) : INTEGER;
  VAR hSrc,
      hDest : File.Handle;
      resCode : INTEGER;
  BEGIN
   File.Open (source, FALSE, File.DENYWRITE, File.READONLY, hSrc, resCode);

   IF (resCode = File.NOERROR)
    THEN
     File.Open (dest, TRUE, File.DENYWRITE, File.WRITEONLY, hDest, resCode);

     IF (resCode = File.NOERROR)
      THEN
       _CopyFile (hSrc, hDest);
       
       File.Close (hSrc);
       File.Close (hDest);
       
       RETURN OK;
      ELSE
       File.Close (hSrc);
       RETURN ERROR;
     END;
    ELSE
     RETURN ERROR;
   END;
  END CopyFile;


 (*-------------------------------------------------------------------------
   <CopyFileEx> kopiert Datei 'source' nach Datei 'dest', wobei auch das
   Dateidatum und die Attribute der Datei 'dest' geaendert werden.
   -------------------------------------------------------------------------*)  
   
 PROCEDURE CopyFileEx* (source, dest : ARRAY OF CHAR;
                        timeStamp : ARRAY OF CHAR;
                        attr : SET) : INTEGER;
  BEGIN
   IF (CopyFile (source, dest) = OK)
    THEN 
     IF SetFileInfo (dest, timeStamp, attr)
      THEN RETURN OK;
      ELSE RETURN ERROR;
     END;
   END;
  END CopyFileEx;
                        
                         
 (*-------------------------------------------------------------------------
   <CopyFileExDir> kopiert Datei 'source' nach Datei 'dest', wobei auch das
   Dateidatum und die Dateiattribute der Datei 'dest' festgelegt werden 
   koennen. Weiters werden auch eventuelle Verzeichnisse von 'dest' erzeugt.
   -------------------------------------------------------------------------*)  
   
 PROCEDURE CopyFileExDir* (source, dest : ARRAY OF CHAR;
                           timeStamp : ARRAY OF CHAR;
                           attr : SET) : INTEGER;
  BEGIN
   IF CreateDir (dest)
    THEN RETURN CopyFileEx (source, dest, timeStamp, attr);
   END;
  END CopyFileExDir;
                        
                         
 (*-------------------------------------------------------------------------
   <MoveFile> dient zum Verschieben einer Datei 'source' nach 'dest'.
   -------------------------------------------------------------------------*)  
   
 PROCEDURE MoveFile* (source, dest : ARRAY OF CHAR) : INTEGER;
  VAR resCode : INTEGER;
  BEGIN
   IF (CopyFile (source, dest) = OK)
    THEN 
     File.Delete (source, resCode);

     IF (resCode = File.NOERROR)
      THEN RETURN OK;
     END;
   END;
   
   RETURN ERROR;
  END MoveFile;
  
  
 (*-------------------------------------------------------------------------
   <MoveFileEx> verschiebt die Datei 'source' nach 'dest', wobei das Datei-
   datum und Dateiattribute der Datei 'dest' festgelegt werden koennen.
   -------------------------------------------------------------------------*)  
   
 PROCEDURE MoveFileEx* (source, dest : ARRAY OF CHAR;
                        timeStamp : ARRAY OF CHAR;
                        attr : SET) : INTEGER;
  BEGIN
   IF (MoveFile (source, dest) = OK)
    THEN 
     IF SetFileInfo (dest, timeStamp, attr)
      THEN RETURN OK;
     END;
   END;
   
   RETURN ERROR;
  END MoveFileEx;
                        
                         
 (*-------------------------------------------------------------------------
   <MoveFileExDir> verschiebt die Datei 'source' nach 'dest', wobei das
   Dateidatum und Dateiattribute der Datei 'dest' festgelegt werden koennen.
   Zusaetzlich werden eventuelle Verzeichnisse von 'dest' erzeugt.
   -------------------------------------------------------------------------*)  
   
 PROCEDURE MoveFileExDir* (source, dest : ARRAY OF CHAR;
                           timeStamp : ARRAY OF CHAR;
                           attr : SET) : INTEGER;
  BEGIN
   IF CreateDir (dest) & (MoveFile (source, dest) = OK)
    THEN 
     IF SetFileInfo (dest, timeStamp, attr)
      THEN RETURN OK;
     END;
   END;
   
   RETURN ERROR;
  END MoveFileExDir;
                        
                         
 (*-------------------------------------------------------------------------
   <SplitFullName> spaltet einen Dateinamen mit absoluter Pfadangabe in 
   Laufwerk, Pfad und Dateiname auf.
   -------------------------------------------------------------------------*)  
   
 PROCEDURE SplitFullName* (fullName : ARRAY OF CHAR;
                           VAR fileName : ARRAY OF CHAR;
                           VAR drive : CHAR;
                           VAR path : ARRAY OF CHAR);
  VAR ctr : LONGINT;
  BEGIN
   fileName[0] := CHR (0);
   drive := " ";
   path[0] := CHR (0);
   
   ctr := Strings.Length (fullName);
   WHILE (ctr > 0) & (fullName[ctr] # "\") DO
    DEC (ctr);
   END;
   
   Strings.Copy (fullName, fileName, ctr+1, 11);
   
   IF (fullName[1] = ":")
    THEN 
     drive := fullName[1];
     Strings.Copy (fullName, path, 2, 255);
    ELSE
     Strings.Copy (fullName, path, 0, 255);
   END;
  END SplitFullName;
 
 
(*----------------------*)
(* Modulinitialisierung *)

BEGIN  
END FileFunctions.

(****************************************************************************)
