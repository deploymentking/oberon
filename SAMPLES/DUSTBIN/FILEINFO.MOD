(****************************************************************************)
(*
   FileInfo V0.05a (FileInfo.MOD)
   ===============
   
   Programmierer: Alexander Graf (Mat.Nr. 9355752)
                  Dietmar Schinnerl (Mat.Nr. 9355075)
   Projekt: Fallstudie Betriebssysteme: Windowsprogrammierung mit Oberon-2
   Compiler: POW! Oberon-2
   
                           (C) by Alexander Graf & Dietmar Schinnerl, 1996

 ---------------------------------------------------------------------------

   Verwaltet Informationen ueber Dateien, wobei die Informationen _immer_
  kopiert werden, d.h. es werden keine Referenzen auf die Daten gespeichert.
                           
 ---------------------------------------------------------------------------
 
 History:                          

  19.08.1996 / 0.05a : Dokumentation
  22.05.1996 / 0.04a : in Klasse umwandeln
  21.05.1996 / 0.03a : Read/Write der Daten
  19.05.1996 / 0.02a : Strukturaenderung
  10.05.1996 / 0.01a : Grundgeruest
                                                                            *)
(****************************************************************************)

MODULE FileInfo;


 (***************************************************************************)
 (* Benoetige Module importieren                                            *)
 
 IMPORT SYSTEM, 
        Strings,
        File,
        WndTools,
        Tools;
 

 (***************************************************************************)
 (* globale Typen, Konstanten und Variablen                                 *)

 TYPE TCharPtr = POINTER TO ARRAY OF CHAR;
      TFileName* = TCharPtr;
      TFileAttr* = SET;
      TFileLen*  = LONGINT;
      TFileDate* = ARRAY (18) OF CHAR;
      TFileOther* = TCharPtr;
     
      TFileInfoRecPtr* = POINTER TO TFileInfoRec;
  
      TFileInfoRec* = RECORD
                       fileName* : TFileName;
                       fileAttr* : TFileAttr;
                       fileLen*  : TFileLen;
                       fileDate* : TFileDate;
                       fileOther* : TFileOther;
                       nextPtr   : TFileInfoRecPtr;
                      END;

      TFileInfoPtr* = POINTER TO TFileInfo;
      
      TFileInfo = RECORD
                   root : TFileInfoRecPtr;
                   curPos : TFileInfoRecPtr;
                   items : LONGINT;
                  END;
      
 
 (***************************************************************************)

 
 (*-------------------------------------------------------------------------
   <CopyItem> kopiert eine Variable des Typs 'TCharPtr' in eine Variable
   des selben Typs, fuer die der Speicherplatz jedoch automatisch reserviert
   wird.
   -------------------------------------------------------------------------*)

 PROCEDURE (root : TFileInfoPtr) CopyItem* 
                                  (src : TCharPtr;
                                   VAR dest : TCharPtr);
  VAR len : LONGINT;
  BEGIN
   IF (src # NIL)
    THEN
     len := Strings.Length (src^) + 1;
     NEW (dest, len);
     SYSTEM.MOVE (SYSTEM.ADR (src^), 
                  SYSTEM.ADR (dest^),
                  len);
    ELSE
     dest := NIL;
   END;
  END CopyItem;
  
  
 (*-------------------------------------------------------------------------
   <FindEntry> sucht in den gespeicherten Daten nach einem Eintrag, der durch
   'fileName' und 'fileDate' spezifiziert wird. Zurueckgeliefert wird der
   gesamte spezifizierte Eintrag (falls vorhanden). 

   Rueckgabewert: Eintrag (nicht) wurde gefunden
   -------------------------------------------------------------------------*)

 PROCEDURE (root : TFileInfoPtr) FindEntry* 
                                  (fileName : TFileName;
                                   fileDate : TFileDate;
                                   VAR entry : TFileInfoRec) : BOOLEAN;
  VAR helpPtr,
      curPtr : TFileInfoRecPtr;
      found : BOOLEAN;
  BEGIN
   WndTools.Assert (root # NIL, "FileInfo.MOD", "FindEntry: root = NIL");
   found := FALSE;

   curPtr := root^.root;
   
   IF curPtr # NIL
    THEN
     REPEAT
      helpPtr := curPtr^.nextPtr;

      IF Tools.Compare (fileName^, curPtr^.fileName^) &
         Tools.Compare (fileDate, curPtr^.fileDate)
       THEN 
        root.CopyItem (curPtr^.fileName, entry.fileName);
        entry.fileAttr  := curPtr^.fileAttr;
        entry.fileDate  := curPtr^.fileDate;
        entry.fileLen   := curPtr^.fileLen;
        root.CopyItem (curPtr^.fileOther, entry.fileOther);
        found := TRUE;
      END;

      curPtr := helpPtr;
     UNTIL (curPtr = NIL) OR found;
   END;
   
   RETURN found;
  END FindEntry;                    


 (*-------------------------------------------------------------------------
   <DeleteRecord> loescht das durch den uebergebenen Zeiger referenzierte 
   Objekt, der reservierte Speicher der Datenelemente wird freigegeben.
   -------------------------------------------------------------------------*)

 PROCEDURE (root : TFileInfoPtr) DeleteRecord 
                                  (ptr : TFileInfoRecPtr);
  BEGIN
   IF ptr^.fileName # NIL
    THEN DISPOSE (ptr^.fileName);
   END;
   
   IF ptr^.fileOther # NIL
    THEN DISPOSE (ptr^.fileOther);
   END;

   DISPOSE (ptr);

   ptr := NIL;
  END DeleteRecord;

   
 (*-------------------------------------------------------------------------
   <EntryExist> liefert 'true' falls der gesuchte Eintrag existiert, 'false'
   wenn er nicht existiert.
   -------------------------------------------------------------------------*)

 PROCEDURE (root : TFileInfoPtr) EntryExist* 
                                  (fileName : TFileName;
                                   fileDate : TFileDate) : BOOLEAN;
  VAR entry : TFileInfoRecPtr;
      found : BOOLEAN;
  BEGIN
   NEW (entry);
   found := root.FindEntry (fileName, fileDate, entry^);
   root.DeleteRecord (entry);

   RETURN found;
  END EntryExist;
  

 (*-------------------------------------------------------------------------
   <Create> erzeugt bzw. initialisiert die Datenstruktur fuer die Speicherung
   der Daten.
   -------------------------------------------------------------------------*)
   
 PROCEDURE (root : TFileInfoPtr) Init*;
  BEGIN
   root.root   := NIL;
   root.curPos := NIL;
   root.items  := 0;
  END Init;
  

 (*-------------------------------------------------------------------------
   <DeleteAllEntries> loescht die gesamten gespeicherten Daten. Die Wurzel
   bleibt erhalten.
   -------------------------------------------------------------------------*)
   
 PROCEDURE (root : TFileInfoPtr) DeleteAllEntries*;
  VAR curPtr,
      helpPtr : TFileInfoRecPtr;
  BEGIN
   WndTools.Assert (root # NIL, 
                    "FileInfo.MOD", 
                    "DisposeAllEntries: root = NIL");

   curPtr := root^.root;
   
   IF curPtr # NIL
    THEN
     REPEAT
      helpPtr := curPtr^.nextPtr;

      root.DeleteRecord (curPtr);

      curPtr := helpPtr;
     UNTIL curPtr = NIL;
   END;
   
   root^.root := NIL;
   root^.items := 0;
  END DeleteAllEntries;

   
 (*-------------------------------------------------------------------------
   <Delete> loest die gesamte Datenhaltung auf, d.h. auch die Wurzel wird
   geloescht. (s.a. 'DeleteAllEntries')
   -------------------------------------------------------------------------*)
   
 PROCEDURE (root : TFileInfoPtr) Delete*;
  VAR curPtr,
      helpPtr : TFileInfoRecPtr;
  BEGIN
   WndTools.Assert (root # NIL, "FileInfo.MOD", "Dispose: root = NIL");

   root.DeleteAllEntries;
   
   DISPOSE (root);
   root := NIL;
  END Delete;


 (*-------------------------------------------------------------------------
   <Add> fuegt einen neuen Eintrag hinzu.
   -------------------------------------------------------------------------*)
   
 PROCEDURE (root : TFileInfoPtr) Add* 
                                  (fileName: TFileName;
                                   fileAttr : TFileAttr;
                                   fileLen : TFileLen;
                                   fileDate : TFileDate;
                                   fileOther : TFileOther);
  VAR helpPtr : TFileInfoRecPtr;
      len : LONGINT;
  BEGIN
   WndTools.Assert (fileName # NIL, "FileInfo.MOD", "Insert: fileName = NIL");

   IF root.EntryExist (fileName, fileDate)
    THEN RETURN;
   END;

   NEW (helpPtr);
   
   helpPtr^.nextPtr := root^.root;
   root^.root := helpPtr;

   root.CopyItem (fileName, helpPtr^.fileName);
   helpPtr^.fileAttr  := fileAttr;
   helpPtr^.fileLen   := fileLen;
   helpPtr^.fileDate  := fileDate;
   root.CopyItem (fileOther, helpPtr^.fileOther);
   
   INC (root^.items);
  END Add;                   


 PROCEDURE (root : TFileInfoPtr) AddRec* (rec : TFileInfoRec);
  BEGIN
   root.Add (rec.fileName, rec.fileAttr, rec.fileLen, rec.fileDate,
             rec.fileOther);
  END AddRec;
 
 
 (*-------------------------------------------------------------------------
   <InitIterate> initialisiert den passiven Iterator.
   -------------------------------------------------------------------------*)
   
 PROCEDURE (root : TFileInfoPtr) InitIterate*;
  BEGIN
   WndTools.Assert (root # NIL, "FileInfo.MOD", "InitIterate: root = NIL");
   
   root^.curPos := root^.root;
  END InitIterate;


 (*-------------------------------------------------------------------------
   <Iterate> stellt den passiven Iterator dar.
   -------------------------------------------------------------------------*)

  PROCEDURE (root : TFileInfoPtr) Iterate* (VAR fileName: TFileName;
                                            VAR fileAttr : TFileAttr;
                                            VAR fileLen : TFileLen;
                                            VAR fileDate : TFileDate;
                                            VAR fileOther : TFileOther) : BOOLEAN;
   BEGIN
    IF root^.curPos # NIL
     THEN
      root.CopyItem (root^.curPos^.fileName, fileName);
      fileAttr := root^.curPos^.fileAttr;
      fileLen  := root^.curPos^.fileLen;
      fileDate := root^.curPos^.fileDate;
      IF (root^.curPos^.fileOther # NIL)
       THEN
        root.CopyItem (root^.curPos^.fileOther, fileOther);
       ELSE
        fileOther := NIL;
      END;

      root^.curPos := root^.curPos^.nextPtr;
      RETURN TRUE;
     ELSE
      RETURN FALSE;
    END;
   END Iterate;
   

 PROCEDURE (root : TFileInfoPtr) IterateRec* (VAR rec : TFileInfoRec):BOOLEAN;
  BEGIN
   RETURN root.Iterate (rec.fileName, rec.fileAttr, rec.fileLen, 
                        rec.fileDate, rec.fileOther);
  END IterateRec;


 (*-------------------------------------------------------------------------
   <NoOfEntries> liefert die Anzahl der Eintrag zurueck.
   -------------------------------------------------------------------------*)

 PROCEDURE (root : TFileInfoPtr) NoOfEntries* () : LONGINT;
  BEGIN
   RETURN root^.items;
  END NoOfEntries;


 (*-------------------------------------------------------------------------
   <DeleteEntry> loescht einen Eintrag aus der Tabelle.
   -------------------------------------------------------------------------*)

 PROCEDURE (root : TFileInfoPtr) DeleteEntry* (fileName : TFileName;
                                               fileDate : TFileDate);
  VAR prevPtr,
      curPtr : TFileInfoRecPtr;
  BEGIN
   prevPtr := NIL;
   curPtr := root^.root;
   
   IF curPtr # NIL
    THEN
     REPEAT
      IF Tools.Compare (fileName^, curPtr^.fileName^)
       THEN
        IF prevPtr = NIL
         THEN root^.root := curPtr^.nextPtr;
         ELSE prevPtr^.nextPtr := curPtr^.nextPtr;
        END;
        
        root.DeleteRecord (curPtr);

        DEC (root^.items);
        
        RETURN;
      END;

      prevPtr := curPtr;
      curPtr := curPtr^.nextPtr;
     UNTIL (curPtr = NIL);
   END;
  END DeleteEntry;                    


 (*-------------------------------------------------------------------------
   <WriteEntry> schreibt einen Eintrag in das Info-Datei.
   -------------------------------------------------------------------------*)

 PROCEDURE (root : TFileInfoPtr) WriteEntry 
                                  (file : File.Handle; 
                                   entry : TFileInfoRec);
  VAR resCode : INTEGER;
      tempStr : ARRAY 16 OF CHAR;
  BEGIN
   (* fileName schreiben *)
   File.WriteBlock (file, 
                    entry.fileName^,
                    Strings.Length (entry.fileName^) + 1, 
                    resCode);

   (* fileAttr schreiben *)
   IF File.ATTRARCHIVE IN entry.fileAttr
    THEN File.WriteChar (file, "A", resCode);
    ELSE File.WriteChar (file, "-", resCode);
   END;
   IF File.ATTRREADONLY IN entry.fileAttr
    THEN File.WriteChar (file, "R", resCode);
    ELSE File.WriteChar (file, "-", resCode);
   END;
   IF File.ATTRHIDDEN IN entry.fileAttr
    THEN File.WriteChar (file, "H", resCode);
    ELSE File.WriteChar (file, "-", resCode);
   END;
   IF File.ATTRSYSTEM IN entry.fileAttr
    THEN File.WriteChar (file, "S", resCode);
    ELSE File.WriteChar (file, "-", resCode);
   END;

   (* fileLen schreiben *)
   Strings.Str (entry.fileLen, tempStr);
   File.WriteBlock (file,
                    tempStr,
                    Strings.Length (tempStr) + 1,
                    resCode);
                       
   (* fileDate schreiben *)                    
   File.WriteBlock (file, 
                    entry.fileDate,
                    Strings.Length (entry.fileDate) + 1,
                    resCode);
                       
   (* fileOther schreiben *)                    
   File.WriteBlock (file, 
                    entry.fileOther^,
                    LEN (entry.fileOther^),
                    resCode);
  END WriteEntry;


 (*-------------------------------------------------------------------------
   <WriteAll> schreibt alle Eintraege in eine Info-Datei.
   -------------------------------------------------------------------------*)

 PROCEDURE (root : TFileInfoPtr) WriteAll* (file : File.Handle);
  VAR entry : TFileInfoRec;
  BEGIN
   root.InitIterate;

   WHILE root.IterateRec (entry) DO
    root.WriteEntry (file, entry);
   END;
  END WriteAll;


 (*-------------------------------------------------------------------------
   <Read> liest ein Element aus der Info-Datei.
   -------------------------------------------------------------------------*)

 PROCEDURE (root : TFileInfoPtr) Read
                                  (file : File.Handle; 
                                   VAR str : ARRAY OF CHAR);
  VAR resCode : INTEGER;
      ch : CHAR;
  BEGIN
   str[0] := CHR (0);
   
   REPEAT
    File.ReadChar (file, ch, resCode);

    IF (resCode = File.NOERROR) & (ch # CHR (0))
     THEN Strings.AppendChar (str, ch);
    END;
   UNTIL (ch = CHR (0)) OR (resCode # File.NOERROR);
  END Read;


 (*-------------------------------------------------------------------------
   <ReadEntry> liest den gesamten Eintrag aus der Info-Datei.
   -------------------------------------------------------------------------*)

 PROCEDURE (root : TFileInfoPtr) ReadEntry
                                  (file : File.Handle; 
                                   VAR entry : TFileInfoRec);
  VAR ch : CHAR;
      tempStr : TCharPtr;
      resCode : INTEGER;
  BEGIN
   NEW (tempStr, 256);
   
   (* fileName einlesen *)
   root.Read (file, tempStr^);
   root.CopyItem (tempStr, entry.fileName);
   
   (* fileAttr einlesen *)
   entry.fileAttr := {};
   File.ReadChar (file, ch, resCode);
   IF (ch = "A")
    THEN entry.fileAttr := entry.fileAttr + {File.ATTRARCHIVE};
   END;
   File.ReadChar (file, ch, resCode);
   IF (ch = "R")
    THEN entry.fileAttr := entry.fileAttr + {File.ATTRREADONLY};
   END;
   File.ReadChar (file, ch, resCode);
   IF (ch = "H")
    THEN entry.fileAttr := entry.fileAttr + {File.ATTRHIDDEN};
   END;
   File.ReadChar (file, ch, resCode);
   IF (ch = "S")
    THEN entry.fileAttr := entry.fileAttr + {File.ATTRSYSTEM};
   END;
   
   (* fileLen einlesen *)
   root.Read (file, tempStr^);
   entry.fileLen := Strings.Val (tempStr^);
   
   (* fileDate einlesen *)
   root.Read (file, entry.fileDate);
   
   (* fileOther einlesen *)
   root.Read (file, tempStr^);
   root.CopyItem (tempStr, entry.fileOther);
   
   DISPOSE (tempStr);
  END ReadEntry;


 (*-------------------------------------------------------------------------
   <ReadAll> liest alle Eintrage aus der Info-Datei.
   -------------------------------------------------------------------------*)

 PROCEDURE (root : TFileInfoPtr) ReadAll* (file : File.Handle);
  VAR entry : TFileInfoRec;
  BEGIN
   WHILE ~File.AtEnd (file) DO
    root.ReadEntry (file, entry);
    root.AddRec (entry);
   END;
  END ReadAll;


END FileInfo.

(****************************************************************************)
