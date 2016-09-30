(****************************************************************************)
(*
   DustBinWindow V0.16a (DustBinWnd.MOD)
   ====================
   
   Programmierer: Alexander Graf (Mat.Nr. 9355752)
                  Dietmar Schinnerl (Mat.Nr. 9355075)
   Projekt: Fallstudie Betriebssysteme: Windowsprogrammierung mit Oberon-2
   Compiler: POW! Oberon-2
   
                           (C) by Alexander Graf & Dietmar Schinnerl, 1996
                           
 ---------------------------------------------------------------------------
 
 History:                          
 
  02.09.1996 / 0.16a : Probleme mit der Icon-Darstellung (weisser Rand)
                       korrigieren
  20.08.1996 / 0.15a : Verbesserung der Programmstruktur (Aufgliederung in
                        mehr Routinen)
  19.08.1996 / 0.14a : Verbesserung der Programmstruktur
                       Meldung, wenn wiederherzustellende Datei schon 
                        existiert
  08.07.1996 / 0.13a : Loeschen von Unterverzeichnissen
  08.06.1996 / 0.12a : MoveFileEx durch MoveFileExDir ersetzen
  27.05.1996 / 0.11a : Systemmenue erweitert
                       kleine Aenderungen
  26.05.1996 / 0.10a : kleine Korrekturen
  25.05.1996 / 0.09a : MoveFileEx statt MoveFile beim Wiederherstellen 
                       verwenden
  22.05.1996 / 0.08a : Icon abhaengig vom Inhalt
  21.05.1996 / 0.07a : Inhalt speichern/wiederherstellen
                       Onlinehilfe (nur Menuauswahl [?/HELP])
  19.05.1996 / 0.06a : Restore implementieren (Grundgeruest)
                       Soundsupport on/off
                       Kopieren der Dateien ins Dustbin-Verz. implementiert
  18.05.1996 / 0.05a : Drag&Drop Support
                       Programm umstrukturieren
                       Teile auslagern
                       Sound Support
                       neuer Menueintraege (Restore all/file(s))
  16.05.1996 / 0.04a : Listbox gleiche Groesse wie Fenster, auch nach Resize
                       Menue ausbauen
  14.05.1996 / 0.03a : Listbox auswerten, 
                       neuer Menueintrag (Kill selected files)
                       Menuintraege enablen/disablen
                       CASE nach IF-ELSIF aendern
  10.05.1996 / 0.02a : Options-Dialog erweitert
  06.05.1996 / 0.01a : About-Dialog einbinden
  05.05.1996 / 0.00a : Grundgeruest
                                                                            *)
(****************************************************************************)

MODULE DustBinWnd;


 (***************************************************************************)
 (* Benoetige Module importieren                                            *)
 
 IMPORT Windows,        (* Definition etc. fuer Windowsprogrammierung *)
        Shell,          (* SHELL-API                                  *)
        MMSystem,       (* MMSystem-API                               *)
        SYSTEM,
        Strings,
        Utils,
        File,
        Volume,
        Options,        (* Options-Dialog                               *)
        About,          (* About-Dialog                                 *)
        FileInfo,       (* Datenstruktur fuer die Dateiinformationen    *)
        FileFunc,       (* Filefunktionen, wie Kopieren und Verschieben *)
        Tools,          (* verschiedene kleine Routinen                 *)
        WndTools;       (* Ein paar nuetzliche Tools fuer Windowsprogr. *)
 

 (***************************************************************************)
 (* globale Typen, Konstanten und Variablen                                 *)

 CONST WndClassName* = "DustBinWindow";

       IDM_DUSTBIN_QUIT    = 20001;
       IDM_DUSTBIN_OPTIONS = 20002;
       IDM_DUSTBIN_EMPTY   = 20003;
       IDM_DUSTBIN_KILL    = 20004;
       IDM_DUSTBIN_RESTORE = 20005;
       IDM_DUSTBIN_RESTORESEL = 20006;
       
       IDM_HELP       = 20200;
       IDM_HELP_HELP  = 20201;
       IDM_HELP_ABOUT = 20202; 
       
       IDM_LISTBOX = 20500;
       
 
 VAR hInstance : Windows.HINSTANCE;
     content : FileInfo.TFileInfoPtr;
     
     hIcon,
     hIconF : Windows.HICON;
 
 
 (***************************************************************************)


 (*-------------------------------------------------------------------------
   <Setup>
   -------------------------------------------------------------------------*)  

 PROCEDURE Setup (hWnd : Windows.HWND);
  VAR dialog : WndTools.DLGPROC;
      lpDialog : Windows.FARPROC;
      dummy : LONGINT;
  BEGIN
   dialog := Options.SetupDlg;
   lpDialog := Windows.MakeProcInstance (
                SYSTEM.VAL (Windows.FARPROC, dialog),
                hInstance);
   dummy := Windows.DialogBox (
             hInstance, 
             SYSTEM.ADR ("Setup"),
             hWnd,
             Options.SetupDlg (*lpDialog*));
  END Setup;

 
 (*-------------------------------------------------------------------------
   <SetWindowLabel>
   -------------------------------------------------------------------------*)  
   
 PROCEDURE SetWindowLabel (hWnd : Windows.HWND);
  VAR text : ARRAY (142) OF CHAR;
      helpText : ARRAY (12) OF CHAR;
      dummy : LONGINT;
  BEGIN
   text := "";
   
   IF (content.NoOfEntries() # 0)
    THEN
     Strings.Append (text, "Dustbin (holds ");
     Strings.Str (content.NoOfEntries(), helpText);
     Strings.Append (text, helpText);
     
     Strings.Append (text, " file");
     IF (content.NoOfEntries() > 1)
      THEN Strings.AppendChar (text, "s");
     END;
     Strings.AppendChar (text, ")");
     
     dummy := Windows.SetClassLong (
               hWnd, Windows.GCW_HICON, hIconF);
    ELSE
     Strings.Append (text, "Dustbin (is empty)");

     dummy := Windows.SetClassLong (
               hWnd, Windows.GCW_HICON, hIcon);
   END;

   Windows.SetWindowText (hWnd, SYSTEM.ADR (text));
  END SetWindowLabel;


 (*-------------------------------------------------------------------------
   <StartupDustbin>
   -------------------------------------------------------------------------*)  

 PROCEDURE StartupDustbin (hWnd : Windows.HWND);
  VAR file : File.Handle;
      resCode : INTEGER;
      entry : FileInfo.TFileInfoRec;
      missing : BOOLEAN;
      fullName : ARRAY 129 OF CHAR;
  BEGIN
   missing := FALSE;
   NEW (content);
   content.Init;

   (* Infofile einlesen *)
   FileFunc.MakeFullName (
    Options.DustBinDir, Options.DustBinNFO, fullName);
   File.Open (
    fullName, FALSE, File.DENYALL, File.READONLY, file, resCode);
   IF (resCode = File.NOERROR)
    THEN           
     content.ReadAll (file);
     File.Close (file);
    ELSE
     WndTools.Panic ("Upps! No info-file found. Setup required!");
     Setup (hWnd);
   END;
   
   (* ist physischer Inhalt noch vorhanden? *)
   content.InitIterate;
   WHILE content.IterateRec (entry) DO
    FileFunc.MakeFullName (Options.DustBinDir, entry.fileOther^, fullName);
    
    IF ~File.Exist (fullName)
     THEN 
      content.DeleteEntry (entry.fileName, entry.fileDate);
      missing := TRUE;
    END;
   END;
   
   IF missing 
    THEN WndTools.MessageBox ("Some or all files are missing.", 
                              "Dustbin - Attention");
   END;
   
   SetWindowLabel (hWnd);
  END StartupDustbin;
  

 (*-------------------------------------------------------------------------
   <ShutdownDustbin>
   -------------------------------------------------------------------------*)  

 PROCEDURE ShutdownDustbin;
  VAR file : File.Handle;
      resCode : INTEGER;
      fullName : ARRAY 129 OF CHAR;
  BEGIN  
   (* Infofile schreiben *)
   FileFunc.MakeFullName (
    Options.DustBinDir, Options.DustBinNFO, fullName);
   File.Open (fullName,
              TRUE, 
              File.DENYALL, 
              File.WRITEONLY,
              file,
              resCode);
              
   IF (resCode = File.NOERROR)
    THEN 
     File.Truncate (file, resCode);
     content.WriteAll (file);
     File.Close (file);
    ELSE 
     WndTools.Panic ("Couldn't write dustbin information.");
   END;
   
   content.Delete;
  END ShutdownDustbin;
  
   
 (*-------------------------------------------------------------------------
   <PlaySound>
   -------------------------------------------------------------------------*)  
   
 PROCEDURE PlaySound (sndName : ARRAY OF CHAR);
  BEGIN
   IF Options.oSoundSupport & 
      (MMSystem.sndPlaySound (
       SYSTEM.ADR (sndName), MMSystem.snd_Sync) = Windows.false)
    THEN WndTools.MessageBox ("Could not play sound.", "Notification");
   END;
  END PlaySound;

   
 (*-------------------------------------------------------------------------
   <YesNoQuery>
   -------------------------------------------------------------------------*)  
   
 PROCEDURE YesNoQuery (hWnd : Windows.HWND; 
                       msg : ARRAY OF CHAR;
                       label : ARRAY OF CHAR) : BOOLEAN;
  BEGIN
   RETURN (Windows.MessageBox (hWnd,
                               SYSTEM.ADR (msg),
                               SYSTEM.ADR (label),
                               Windows.MB_YESNO + Windows.MB_ICONQUESTION +
                               Windows.MB_APPLMODAL)
           = Windows.IDYES);
  END YesNoQuery;
 
 
 (*-------------------------------------------------------------------------
   <KillFile>
   -------------------------------------------------------------------------*)  
   
 PROCEDURE KillFile (file : FileInfo.TFileInfoRec);
  VAR fullName : ARRAY 129 OF CHAR;
      resCode : INTEGER;
  BEGIN
    FileFunc.MakeFullName (
     Options.DustBinDir, file.fileOther^, fullName);
    File.Delete (fullName, resCode);
    
    IF (resCode # File.NOERROR)
     THEN 
      fullName := "";
      Strings.Append (fullName, file.fileName^);
      Strings.Append (fullName, " couldn't be deleted.");
      WndTools.MessageBox (fullName, "Notification");
    END;
  END KillFile;
  
  
 (*-------------------------------------------------------------------------
   <KillSelectedFiles>
   -------------------------------------------------------------------------*)  
   
 PROCEDURE KillSelectedFiles (hWnd : Windows.HWND);
  VAR hWndLB : Windows.HWND;
      ctr : INTEGER;
      items : LONGINT;
      str : ARRAY (255) OF CHAR;
      dummy : LONGINT;
      fileName : FileInfo.TFileName;
      fileDate : FileInfo.TFileDate;
      file : FileInfo.TFileInfoRec;
  BEGIN
   hWndLB := Windows.GetDlgItem (hWnd, IDM_LISTBOX);
   items := Windows.SendMessage (hWndLB, 
                                 Windows.LB_GETCOUNT, 
                                 0,
                                 0);
                                
   FOR ctr := 0 TO (items-1) DO
    dummy := Windows.SendMessage (hWndLB, Windows.LB_GETSEL, ctr, 0);
    IF (dummy > 0)
     THEN
      dummy := Windows.SendMessage (hWndLB, 
                                    Windows.LB_GETTEXT, 
                                    ctr, 
                                    SYSTEM.ADR (str));
      NEW (fileName, Strings.Pos (" ", str, 0));
      Strings.Copy (str, 
                    fileName^, 
                    1, 
                    Strings.Pos (" ", str, 0)-1);
      fileDate := "";
      Strings.Copy (str, 
                    fileDate, 
                    Strings.Pos (" ", str, 0)+3, 
                    Strings.Pos (" ", str, Strings.Pos (" ", str, 0))-1);

      IF ~content.FindEntry (fileName, fileDate, file)
       THEN
        WndTools.MessageBox ("A internal error occured", "Notification");
        RETURN;
      END;
      
      content.DeleteEntry (fileName, fileDate);

      KillFile (file);

      DISPOSE (fileName);
      
     ELSIF (dummy = Windows.LB_ERR)
      THEN WndTools.MessageBox ("A internal error occured", "Notification");
    END;

    Windows.InvalidateRect (hWnd, Windows.NULL, Windows.true);
   END;

   PlaySound ("flush.wav");
  END KillSelectedFiles;

   
 (*-------------------------------------------------------------------------
   <EmptyDustbin>
   -------------------------------------------------------------------------*)  
   
 PROCEDURE EmptyDustbin;
  VAR file : FileInfo.TFileInfoRec;
      dummy : LONGINT;
  BEGIN
   content.InitIterate;
   
   WHILE content.IterateRec (file) DO
    KillFile (file);
   END;
   
   content.DeleteAllEntries;

   PlaySound ("flush.wav");
  END EmptyDustbin;


 (*-------------------------------------------------------------------------
   <RestoreAFile>
   -------------------------------------------------------------------------*)  

 PROCEDURE RestoreAFile (entry : FileInfo.TFileInfoRec) : BOOLEAN;
  VAR fullName : ARRAY 129 OF CHAR;
      str : ARRAY 255 OF CHAR;
  BEGIN
   FileFunc.MakeFullName (
    Options.DustBinDir, entry.fileOther^, fullName);

   IF File.Exist (entry.fileName^) 
    THEN 
     str := "File '";
     Strings.Append (str, entry.fileName^);
     Strings.Append (str, "' already exists. Overwrite?");
     IF (Windows.MessageBox (Windows.NULL,
                             SYSTEM.ADR (str),
                             SYSTEM.ADR ("Notification"),
                             Windows.MB_YESNO + Windows.MB_ICONQUESTION +
                             Windows.MB_TASKMODAL)
         ) = Windows.IDNO
      THEN 
       RETURN FALSE;
     END;
   END;
   
   IF (FileFunc.MoveFileExDir (
        fullName, 
        entry.fileName^, 
        entry.fileDate, 
        entry.fileAttr) # FileFunc.OK)
    THEN 
     str[0] := CHR (0);
     Strings.Append (str, "Couldn't restore ");
     Strings.Append (str, entry.fileName^);
     Strings.AppendChar (str, ".");
     WndTools.MessageBox (str, "Notification");
     RETURN FALSE;
    END;

   RETURN TRUE;
  END RestoreAFile;
   

 (*-------------------------------------------------------------------------
   <cmdIDM_DUSTBIN_RESTORE>
   -------------------------------------------------------------------------*)  
   
 PROCEDURE cmdIDM_DUSTBIN_RESTORE (hWnd : Windows.HWND);
  VAR entry : FileInfo.TFileInfoRec;
      dummy : LONGINT;
      fullName : ARRAY 129 OF CHAR;
      str : ARRAY 255 OF CHAR;
  BEGIN
   content.InitIterate;
   
   WHILE content.IterateRec (entry) DO
    IF RestoreAFile (entry)
     THEN 
      content.DeleteEntry (entry.fileName, entry.fileDate);
     ELSE
      WndTools.MessageBox ("Restore of a file failed.", "Notification");
    END;
   END;
   
   Windows.InvalidateRect (hWnd, Windows.NULL, Windows.true);

   PlaySound ("bloop.wav");
  END cmdIDM_DUSTBIN_RESTORE;

   
 (*-------------------------------------------------------------------------
   <cmdIDM_DUSTBIN_RESTORE_SEL>
   -------------------------------------------------------------------------*)  
   
 PROCEDURE cmdIDM_DUSTBIN_RESTORESEL (hWnd : Windows.HWND);
  VAR hWndLB : Windows.HWND;
      pos : LONGINT;
      ctr : INTEGER;
      items : LONGINT;
      str : ARRAY (255) OF CHAR;
      dummy : LONGINT;
      fileName : FileInfo.TFileName;
      fileDate : FileInfo.TFileDate;
      entry : FileInfo.TFileInfoRec;
  BEGIN
   hWndLB := Windows.GetDlgItem (hWnd, IDM_LISTBOX);
   items := Windows.SendMessage (hWndLB, 
                                 Windows.LB_GETCOUNT, 
                                 0,
                                 0);
                                
   FOR ctr := 0 TO (items-1) DO
    dummy := Windows.SendMessage (hWndLB, Windows.LB_GETSEL, ctr, 0);
    IF (dummy > 0)
     THEN
      dummy := Windows.SendMessage (hWndLB, 
                                    Windows.LB_GETTEXT, 
                                    ctr, 
                                    SYSTEM.ADR (str));
      NEW (fileName, Strings.Pos (" ", str, 0));
      pos := Strings.Pos (" ", str, 0);
      Strings.Copy (str, fileName^, 1, pos - 1);
      fileDate := "";
      Strings.Copy (str, fileDate, pos + 3, 17);
      
      IF ~content.FindEntry (fileName, fileDate, entry)
       THEN 
        WndTools.Panic (
         "DUSTBINW.MOD:cmdIDM_DUSTBIN_RESTORESEL - Entry not found");
       ELSE
        IF RestoreAFile (entry)
         THEN 
          content.DeleteEntry (fileName, fileDate);
         ELSE
          WndTools.MessageBox ("Restore of a file failed.", "Notification");
        END;
      END;
      
      DISPOSE (fileName);
      
     ELSIF (dummy = Windows.LB_ERR)
      THEN WndTools.MessageBox 
            ("cmdIDM_DUSTBIN_RESTORESEL: RestoreSelFiles - Listbox error", 
             "Notification");
    END;

    Windows.InvalidateRect (hWnd, Windows.NULL, Windows.true);
   END;

   PlaySound ("bloop.wav");
  END cmdIDM_DUSTBIN_RESTORESEL;

   
 (*-------------------------------------------------------------------------
   <DeleteDir>
   -------------------------------------------------------------------------*)  

 PROCEDURE DeleteDir (dir : FileInfo.TFileName);
  VAR searchName : FileInfo.TFileName;
      scanObj : Volume.ScanP;
      resCode : INTEGER;
      str : FileInfo.TFileName;
      newDir : FileInfo.TFileName;
  BEGIN
   NEW (searchName, Strings.Length (dir^) + 5);
   searchName^[0] := CHR (0);
   Strings.Append (searchName^, dir^);
   Strings.Append (searchName^, "\*.*");
   NEW (scanObj);
   NEW (str, 13);
   
   scanObj.First (searchName^, resCode);
   WHILE (resCode = Volume.NOERROR) DO
    scanObj.GetName (str^);
    
    IF ~(Tools.Compare (str^, ".") OR
         Tools.Compare (str^, ".."))
     THEN
      IF (Volume.ATTRDIR IN scanObj.GetAttr())
       THEN
        NEW (newDir, Strings.Length (str^) + Strings.Length (dir^) + 2);
        newDir^[0] := CHR (0);
        Strings.Append (newDir^, dir^);
        Strings.AppendChar (newDir^, "\");
        Strings.Append (newDir^, str^);

        DeleteDir (newDir);
        
        DISPOSE (newDir);
      END;
     END;
   
    scanObj.Next (resCode);
   END;
   
   Volume.RemoveDirectory (dir^, resCode);
    
   DISPOSE (str);
   DISPOSE (scanObj);
   DISPOSE (searchName);
  END DeleteDir;


 (*-------------------------------------------------------------------------
   <ScanDir>
   -------------------------------------------------------------------------*)  

 PROCEDURE ScanDir (VAR dropped : FileInfo.TFileInfoPtr;
                    dir : FileInfo.TFileName);
  VAR searchName : FileInfo.TFileName;
      scanObj : Volume.ScanP;
      resCode : INTEGER;
      str : FileInfo.TFileName;
      fileRec : FileInfo.TFileInfoRecPtr;
      newDir : FileInfo.TFileName;
  BEGIN
   NEW (searchName, Strings.Length (dir^) + 5);
   searchName^[0] := CHR (0);
   Strings.Append (searchName^, dir^);
   Strings.Append (searchName^, "\*.*");
   NEW (scanObj);
   NEW (fileRec);
   NEW (str, 13);
   
   scanObj.First (searchName^, resCode);
   WHILE (resCode = Volume.NOERROR) DO
    scanObj.GetName (str^);
    
    IF ~(Tools.Compare (str^, ".") OR
         Tools.Compare (str^, ".."))
     THEN
      IF ~(Volume.ATTRDIR IN scanObj.GetAttr())
       THEN
        NEW (fileRec.fileName, 
             Strings.Length (str^) + Strings.Length (dir^) + 2);
        fileRec.fileName^[0] := CHR (0);
        Strings.Append (fileRec.fileName^, dir^);
        Strings.AppendChar (fileRec.fileName^, "\");
        Strings.Append (fileRec.fileName^, str^);
        fileRec.fileAttr := scanObj.GetAttr();
        fileRec.fileLen := scanObj.GetSize();
        scanObj.GetModifyDate (fileRec.fileDate);
        Tools.FormatDate (fileRec.fileDate);
        
        dropped.AddRec (fileRec^);
       ELSE
        NEW (newDir, Strings.Length (str^) + Strings.Length (dir^) + 2);
        newDir^[0] := CHR (0);
        Strings.Append (newDir^, dir^);
        Strings.AppendChar (newDir^, "\");
        Strings.Append (newDir^, str^);

        ScanDir (dropped, newDir);
        
        DISPOSE (newDir);
      END;
     END;
   
    scanObj.Next (resCode);
   END;
   
   DISPOSE (str);
   DISPOSE (fileRec);
   DISPOSE (scanObj);
   DISPOSE (searchName);
  END ScanDir;


 (*-------------------------------------------------------------------------
   <WM_SYSCOMMAND>
   -------------------------------------------------------------------------*)  

 PROCEDURE WM_SYSCOMMAND (hWnd : Windows.HWND;
                          msg : Windows.WORD;
                          wParam : Windows.WORD;
                          lParam : LONGINT) : LONGINT;
  VAR dummy : LONGINT;
  BEGIN
   IF (wParam = IDM_DUSTBIN_EMPTY)
    THEN 
     dummy := Windows.PostMessage (
               hWnd, 
               Windows.WM_COMMAND, 
               IDM_DUSTBIN_EMPTY,
               0);
     RETURN 0;
    ELSE 
     RETURN Windows.DefWindowProc (hWnd, msg, wParam, lParam);
   END;
  END WM_SYSCOMMAND;
  
  
 (*-------------------------------------------------------------------------
   <WM_QUERYDRAGICON>
   -------------------------------------------------------------------------*)  

 PROCEDURE WM_QUERYDRAGICON (hWnd : Windows.HWND;
                             msg : Windows.WORD;
                             wParam : Windows.WORD;
                             lParam : LONGINT) : LONGINT;
  BEGIN
   IF content.NoOfEntries() # 0
    THEN RETURN hIconF;
    ELSE RETURN hIcon;
   END;
  END WM_QUERYDRAGICON;
  

 (*-------------------------------------------------------------------------
   <DisableMenues>
   -------------------------------------------------------------------------*)  
   
 PROCEDURE DisableMenues (hWnd : Windows.HWND; hMenu : Windows.HMENU);
  VAR dummy : LONGINT;  
  BEGIN
   dummy := Windows.EnableMenuItem (
             Windows.GetSystemMenu (hWnd, Windows.false), 
             IDM_DUSTBIN_EMPTY, 
             Windows.MF_GRAYED);

   dummy := Windows.EnableMenuItem (
             hMenu, IDM_DUSTBIN_EMPTY, Windows.MF_GRAYED);

   dummy := Windows.EnableMenuItem (
             hMenu, IDM_DUSTBIN_RESTORE, Windows.MF_GRAYED);
  END DisableMenues;


 (*-------------------------------------------------------------------------
   <EnableMenues>
   -------------------------------------------------------------------------*)  
   
 PROCEDURE EnableMenues (hWnd : Windows.HWND; hMenu : Windows.HMENU);
  VAR dummy : LONGINT;
      str : ARRAY (64) OF CHAR;
  BEGIN
   dummy := Windows.EnableMenuItem (
             Windows.GetSystemMenu (hWnd, Windows.false), 
             IDM_DUSTBIN_EMPTY, 
             Windows.MF_ENABLED);

   dummy := Windows.EnableMenuItem (
             hMenu, IDM_DUSTBIN_EMPTY, Windows.MF_ENABLED);

   str := "";
   IF content.NoOfEntries() = 1
    THEN Strings.Append (str, "&Restore file");
    ELSE Strings.Append (str, "&Restore all files");
   END;
   
   dummy := Windows.ModifyMenu (
             hMenu, 
             IDM_DUSTBIN_RESTORE,
             Windows.MF_STRING, 
             IDM_DUSTBIN_RESTORE, 
             SYSTEM.ADR (str));

   dummy := Windows.EnableMenuItem (
             hMenu, IDM_DUSTBIN_RESTORE, Windows.MF_ENABLED);
  END EnableMenues;
  

 (*-------------------------------------------------------------------------
   <ModifyMenues>
   -------------------------------------------------------------------------*)  
   
 PROCEDURE ModifyMenues (hWnd : Windows.HWND; hMenu : Windows.HMENU);
  VAR selItems,
      dummy : LONGINT;
      status : INTEGER;
      str : ARRAY (64) OF CHAR;
  BEGIN
   selItems := Windows.SendMessage (Windows.GetDlgItem (hWnd, IDM_LISTBOX), 
                                    Windows.LB_GETSELCOUNT, 
                                    0,
                                    0);
   str := "";
   Strings.Append (str, "&Kill selected file");
   IF (selItems > 1)              
    THEN Strings.AppendChar (str, "s");
   END;                        

   dummy := Windows.ModifyMenu (
             hMenu, 
             IDM_DUSTBIN_KILL,
             Windows.MF_STRING, 
             IDM_DUSTBIN_KILL, 
             SYSTEM.ADR (str));

   str := "";
   Strings.Append (str, "Restore &selected file");
   IF (selItems > 1)              
    THEN Strings.AppendChar (str, "s");
   END;                        

   dummy := Windows.ModifyMenu (
             hMenu, 
             IDM_DUSTBIN_RESTORESEL,
             Windows.MF_STRING, 
             IDM_DUSTBIN_RESTORESEL, 
             SYSTEM.ADR (str));

   IF (selItems = 0)
    THEN status := Windows.MF_GRAYED;
    ELSE status := Windows.MF_ENABLED;
   END;
     
   dummy := Windows.EnableMenuItem (
             hMenu, IDM_DUSTBIN_KILL, status);

   dummy := Windows.EnableMenuItem (
             hMenu, IDM_DUSTBIN_RESTORESEL, status);
  END ModifyMenues;
  
  
 (*-------------------------------------------------------------------------
   <WM_INITMENU>
   
   Bemerkung: wParam enthaelt Handle auf Menu
   -------------------------------------------------------------------------*)  

 PROCEDURE WM_INITMENU (hWnd : Windows.HWND;
                        msg : Windows.WORD;
                        wParam : Windows.WORD;
                        lParam : LONGINT) : LONGINT;
  BEGIN
   IF content.NoOfEntries() = 0
    THEN DisableMenues (hWnd, wParam);
    ELSE EnableMenues (hWnd, wParam);
   END; 
   
   ModifyMenues (hWnd, wParam);

   RETURN 0;
  END WM_INITMENU;
  
  
 (*-------------------------------------------------------------------------
   <WM_DESTROY>
   -------------------------------------------------------------------------*)  

 PROCEDURE WM_DESTROY (hWnd : Windows.HWND;
                       msg : Windows.WORD;
                       wParam : Windows.WORD;
                       lParam : LONGINT) : LONGINT;
  VAR dummy : LONGINT;
  BEGIN
   Windows.PostQuitMessage (0);

   RETURN 0;
  END WM_DESTROY;
  
  
 (*-------------------------------------------------------------------------
   <WM_CLOSE>
   -------------------------------------------------------------------------*)  

 PROCEDURE WM_CLOSE (hWnd : Windows.HWND;
                     msg : Windows.WORD;
                     wParam : Windows.WORD;
                     lParam : LONGINT) : LONGINT;
  VAR dummy : LONGINT;
  BEGIN
   IF (Windows.MessageBox (hWnd,
                           SYSTEM.ADR ("Are you sure?"),
                           SYSTEM.ADR ("Leave DustBin"),
                           Windows.MB_YESNO + Windows.MB_ICONQUESTION +
                           Windows.MB_APPLMODAL)
       ) = Windows.IDYES
    THEN 
     dummy := Windows.DestroyIcon (hIcon);
     dummy := Windows.DestroyIcon (hIconF);
     Shell.DragAcceptFiles (hWnd, Windows.false);
     ShutdownDustbin;
     dummy := Windows.DestroyWindow (hWnd);
   END;
   
   RETURN 1;
  END WM_CLOSE;

  
 (*-------------------------------------------------------------------------
   <WM_SIZE>
   -------------------------------------------------------------------------*)  

 PROCEDURE WM_SIZE (hWnd : Windows.HWND;
                    msg : Windows.WORD;
                    wParam : Windows.WORD;
                    lParam : LONGINT) : LONGINT;
  VAR hwndChild : Windows.HWND;
      rc : Windows.RECT;
      dummy : LONGINT;
  BEGIN
   hwndChild := Windows.GetDlgItem (hWnd, IDM_LISTBOX);
   Windows.GetClientRect (hWnd, SYSTEM.ADR (rc));
   dummy := Windows.MoveWindow (
             hwndChild, 
             0, 
             0, 
             rc.right, 
             rc.bottom, 
             Windows.true);

   RETURN 1;
  END WM_SIZE;

       
 (*-------------------------------------------------------------------------
   <WM_CREATE>
   -------------------------------------------------------------------------*)  

 PROCEDURE WM_CREATE (hWnd : Windows.HWND;
                      msg : Windows.WORD;
                      wParam : Windows.WORD;
                      lParam : LONGINT) : LONGINT;
  BEGIN
   Shell.DragAcceptFiles (hWnd, Windows.true);
   PlaySound ("tongue1.wav");
   StartupDustbin (hWnd);

   RETURN Windows.DefWindowProc (hWnd, msg, wParam, lParam);
  END WM_CREATE;
 
 
 (*-------------------------------------------------------------------------
   <CvtAttr2Str>
   -------------------------------------------------------------------------*)  
   
 PROCEDURE CvtAttr2Str (attr : FileInfo.TFileAttr ; VAR str : ARRAY OF CHAR);
  BEGIN
   str[0] := CHR (0);
   
   IF File.ATTRARCHIVE IN attr
    THEN Strings.AppendChar (str, "A");
    ELSE Strings.Append (str, " -");
   END;

   IF File.ATTRREADONLY IN attr
    THEN Strings.AppendChar (str, "R");
    ELSE Strings.Append (str, " -");
   END;
   IF File.ATTRHIDDEN IN attr
    THEN Strings.AppendChar (str, "H");
    ELSE Strings.Append (str, " -");
   END;

   IF File.ATTRSYSTEM IN attr
    THEN Strings.AppendChar (str, "S");
    ELSE Strings.Append (str, " -");
   END;
  END CvtAttr2Str;
  
   
 (*-------------------------------------------------------------------------
   <CvtFileInfo2Str>
   -------------------------------------------------------------------------*)  
   
 PROCEDURE CvtFileInfo2Str (file : FileInfo.TFileInfoRec; 
                            VAR str : ARRAY OF CHAR);
 VAR  helpText : ARRAY (12) OF CHAR;
      attrText : ARRAY (9) OF CHAR;
 BEGIN
  str[0] := CHR (0);
  Strings.Append (str, file.fileName^);

  Strings.Append (str, "   ");
  Strings.Append (str, file.fileDate);
  Strings.AppendChar (str, " ");
  
  Strings.Str (file.fileLen, helpText);
  Strings.Append (str, helpText);
  
  Strings.Append (str, " (");
  
  CvtAttr2Str (file.fileAttr, attrText);

  Strings.Append (str, attrText);

  Strings.Append (str, ") ");

  (*
  >> *** Nur fuer Debugging-Zwecke *** <<
  Strings.Append (str, " [");
  IF file.fileOther # NIL
   THEN Strings.Append (str, file.fileOther^);
  END;
  Strings.Append (str, "] ");
  *)
 END CvtFileInfo2Str;

   
 (*-------------------------------------------------------------------------
   <DrawWindowContent>
   -------------------------------------------------------------------------*)  
   
 PROCEDURE DrawWindowContent (hWnd : Windows.HWND);
  VAR hwndChild : Windows.HWND;
      hDC : Windows.HDC;
      ps : Windows.PAINTSTRUCT;
      text : ARRAY (142) OF CHAR;
      file : FileInfo.TFileInfoRec;
      dummy : LONGINT;
      maxExtent : Windows.DWORD;
  BEGIN
   hDC := Windows.BeginPaint (hWnd, SYSTEM.ADR (ps));

   maxExtent := 0;
   content.InitIterate;
   hwndChild := Windows.GetDlgItem (hWnd, IDM_LISTBOX);
   dummy := Windows.SendMessage (hwndChild, 
                                 Windows.LB_RESETCONTENT,
                                 0, 
                                 0);

   WHILE content.IterateRec (file) DO
    CvtFileInfo2Str (file, text);
        
    dummy := Windows.SendMessage (
              hwndChild, Windows.LB_ADDSTRING, 0, SYSTEM.ADR (text));
    
    IF (maxExtent < Windows.GetTextExtent (hDC, 
                                           SYSTEM.ADR (text), 
                                           SHORT (Strings.Length (text))))
     THEN 
      maxExtent := Windows.GetTextExtent (
                    hDC, SYSTEM.ADR (text), SHORT (Strings.Length (text)));
    END;
   END;

   dummy := Windows.SendMessage (
             hwndChild, 
             Windows.LB_SETHORIZONTALEXTENT,
             Utils.LoWord (maxExtent) + 5, 
             0);

   Windows.EndPaint (hWnd, SYSTEM.ADR (ps));
  END DrawWindowContent;
  

 (*-------------------------------------------------------------------------
   <WM_PAINT>
   -------------------------------------------------------------------------*)  

 PROCEDURE WM_PAINT (hWnd : Windows.HWND;
                     msg : Windows.WORD;
                     wParam : Windows.WORD;
                     lParam : LONGINT) : LONGINT;
  BEGIN
   SetWindowLabel (hWnd);

   (* Inhalt des Fensters zeichnen, wenn kein Symbol *)
   IF (Windows.IsIconic (hWnd) # Windows.true)
    THEN DrawWindowContent (hWnd);
   END;
   
   RETURN 1;
  END WM_PAINT;
  
 
 (*-------------------------------------------------------------------------
   <MoveDroppedFiles>
   -------------------------------------------------------------------------*)  
   
 PROCEDURE MoveDroppedFiles (hWnd : Windows.HWND;
                             dropped : FileInfo.TFileInfoPtr);
  VAR entry : FileInfo.TFileInfoRec;
      resCode : INTEGER;
      delFile,
      destFile,
      destFileTmp : ARRAY 128 OF CHAR;
  BEGIN
   (* gedroppte Dateien verschieben *)
   dropped.InitIterate;
   WHILE dropped.IterateRec (entry) DO
    Windows.SetWindowText (hWnd, SYSTEM.ADR (entry.fileName^));

    (* Dateiname fuer die geloeschte Datei erzeugen *)
    REPEAT
     FileFunc.TempFileName (destFile, "DBF");
     destFileTmp := destFile;
     Strings.Insert (Options.DustBinDir, destFile, 0);
    UNTIL ~File.Exist (destFile);

    (* Dateiname fuer die geloeschte Datei abspeichern *)
    NEW (entry.fileOther, Strings.Length (destFileTmp) + 1);
    SYSTEM.MOVE (SYSTEM.ADR (destFileTmp),
                 SYSTEM.ADR (entry.fileOther^),
                 Strings.Length (destFileTmp) + 1);

    (* Datei verschieben und Fehlerpruefung *)
    resCode := FileFunc.MoveFile (entry.fileName^, destFile);
    
    IF (resCode = FileFunc.OK)
     THEN 
      content.AddRec (entry);
     ELSE 
      delFile := "Couldn't delete file ";
      Strings.Append (delFile, entry.fileName^);
      Strings.AppendChar (delFile, ".");
      WndTools.MessageBox (delFile, "Notification");
    END;
   END;
   
   dropped.Delete;
  END MoveDroppedFiles;
  

 (*-------------------------------------------------------------------------
   <DelDroppedDirs>
   -------------------------------------------------------------------------*)  
   
 PROCEDURE DelDroppedDirs (hWnd : Windows.HWND;
                           droppedDir : FileInfo.TFileInfoPtr);
  VAR entry : FileInfo.TFileInfoRec;
  BEGIN
   droppedDir.InitIterate;
   WHILE droppedDir.IterateRec (entry) DO
    Windows.SetWindowText (hWnd, SYSTEM.ADR (entry.fileName^));
    DeleteDir (entry.fileName);
   END;
  END DelDroppedDirs;


 (*-------------------------------------------------------------------------
   <ProcessFileDropped>
   -------------------------------------------------------------------------*)  
 
 PROCEDURE ProcessFileDropped (hWnd : Windows.HWND;
                               dropped : FileInfo.TFileInfoPtr;
                               fHandle : File.Handle;
                               str : FileInfo.TFileName;
                               attr : SET);
  VAR dummy : LONGINT;
      delFile : ARRAY 128 OF CHAR;
      len : FileInfo.TFileLen;
      resCode : INTEGER;
      date : FileInfo.TFileDate;
      entry : FileInfo.TFileInfoRec;
  BEGIN
   File.Size (fHandle, len, resCode);
   File.GetModifyDate (fHandle, date, resCode);
   Tools.FormatDate (date);
  
   delFile := "Delete ";
   Strings.Append (delFile, str^);
   Strings.AppendChar (delFile, "?");

   IF (resCode = File.NOERROR) & 
      ~content.EntryExist (str, date) &
      (~Options.oNotifyFileDel OR
       YesNoQuery (hWnd, delFile, "Notification"))
    THEN 
     delFile := "";
     Strings.Append (delFile, str^);
     Strings.Append (delFile, " has attribute read-only, delete anyways?");
     
     IF ~Options.oNotifyReadOnly OR
        (Options.oNotifyReadOnly &
         ~(File.ATTRREADONLY IN attr) OR
         ((File.ATTRREADONLY IN attr) &
          YesNoQuery (hWnd, delFile, "Notification")))
      THEN  
       File.SetAttributes (str^, {}, resCode);
         
       IF (resCode = File.NOERROR)
        THEN
         (* gedroppte Files zwischenspeichern *)
         dropped.Add (str, attr, len, date, NIL);
        ELSE
         WndTools.MessageBox ("Couldn't reset attributes!",
                              "Notification");
         WndTools.ShowFileErrorMsg (resCode);
       END;
     END;
   END;
  END ProcessFileDropped;
  

 (*-------------------------------------------------------------------------
   <ProcessDirDropped>
   -------------------------------------------------------------------------*)  
   
 PROCEDURE ProcessDirDropped (hWnd : Windows.HWND;
                              dropped : FileInfo.TFileInfoPtr;
                              droppedDir : FileInfo.TFileInfoPtr;
                              str : FileInfo.TFileName);
  VAR dummy : LONGINT;
      delFile : ARRAY 128 OF CHAR;
      resCode : INTEGER;
      fHandle : File.Handle;
  BEGIN
   delFile := "Delete sub-directory ";
   Strings.Append (delFile, str^);
   Strings.Append (delFile, " and all its content?");

   IF ~Options.oNotifyDirDel OR
      (Options.oNotifyDirDel &
       YesNoQuery (hWnd, delFile, "Notification"))
    THEN
     droppedDir.Add (str, {}, 0, "", NIL);                     
     ScanDir (dropped, str);  
    END;
  END ProcessDirDropped;


 (*-------------------------------------------------------------------------
   <WM_DROPFILES>
   -------------------------------------------------------------------------*)  

 PROCEDURE WM_DROPFILES (hWnd : Windows.HWND;
                         msg : Windows.WORD;
                         wParam : Windows.WORD;
                         lParam : LONGINT) : LONGINT;
  VAR hDrop : Windows.WORD;
      dummy : LONGINT;
      size,
      ctr : INTEGER;
      noOfFiles : LONGINT;
      str : FileInfo.TFileName;
      attr : SET;
      len : FileInfo.TFileLen;
      resCode : INTEGER;
      fHandle : File.Handle;
      dropped : FileInfo.TFileInfoPtr;
      droppedDir : FileInfo.TFileInfoPtr;
  BEGIN
   NEW (dropped);
   dropped.Init;
   NEW (droppedDir);
   droppedDir.Init;
   
   hDrop := wParam;

   noOfFiles := Shell.DragQueryFile (hDrop, -1, 0, 0);
   
   FOR ctr := 0 TO (noOfFiles-1) DO
    size := Shell.DragQueryFile (hDrop, ctr, Windows.NULL, 0);
    NEW (str, size+1);
    dummy := Shell.DragQueryFile (hDrop, ctr, SYSTEM.ADR (str^), size+1);
    
    File.Open (str^, FALSE, File.DENYNONE, File.READONLY, fHandle, resCode);
    File.GetAttributes (str^, attr, resCode);
    
    IF ~(File.ATTRDIR IN attr)
     THEN ProcessFileDropped (hWnd, dropped, fHandle, str, attr);
     ELSE ProcessDirDropped (hWnd, dropped, droppedDir, str);
    END;
    
    DISPOSE (str);
    File.Close (fHandle);
   END;

   Shell.DragFinish (hDrop);
   
   MoveDroppedFiles (hWnd, dropped);  (* gedroppte Dateien verschieben *)
   DelDroppedDirs (hWnd, droppedDir); (* gedroppte Directories loeschen *)

   PlaySound ("robotzre.wav");
   
   IF (Windows.IsIconic (hWnd) = Windows.true)
    THEN dummy := WM_PAINT (hWnd, Windows.WM_PAINT, 0, 0);
         Windows.InvalidateRect (Windows.NULL, Windows.NULL, Windows.true);
    ELSE Windows.InvalidateRect (hWnd, Windows.NULL, Windows.true);
   END;

   RETURN 1;
  END WM_DROPFILES;


 (*-------------------------------------------------------------------------
   <cmdIDM_DUSTBIN_OPTIONS>
   -------------------------------------------------------------------------*)  

 PROCEDURE cmdIDM_DUSTBIN_OPTIONS (hWnd : Windows.HWND);
  VAR dummy : LONGINT;
      dialog : WndTools.DLGPROC;
      lpDialog : Windows.FARPROC;                                               
  BEGIN
   dialog := Options.OptionsDlg;
   lpDialog := Windows.MakeProcInstance (
                SYSTEM.VAL (Windows.FARPROC, dialog), hInstance);
   dummy := Windows.DialogBox (
             hInstance, SYSTEM.ADR ("Options"), hWnd, Options.OptionsDlg (*lpDialog*));
  END cmdIDM_DUSTBIN_OPTIONS;
   

 (*-------------------------------------------------------------------------
   <cmdIDM_DUSTBIN_EMPTY>
   -------------------------------------------------------------------------*)  
   
 PROCEDURE cmdIDM_DUSTBIN_EMPTY (hWnd : Windows.HWND);
  VAR dummy : LONGINT;
  BEGIN
   IF (Windows.MessageBox (hWnd,
                           SYSTEM.ADR ("Are you sure?"),
                           SYSTEM.ADR ("Empty DustBin"),
                           Windows.MB_YESNO + Windows.MB_ICONQUESTION +
                           Windows.MB_APPLMODAL)
       ) = Windows.IDYES
    THEN
     EmptyDustbin;
     SetWindowLabel (hWnd);
     Windows.InvalidateRect (Windows.NULL, Windows.NULL, Windows.true);
   END;
  END cmdIDM_DUSTBIN_EMPTY;


 (*-------------------------------------------------------------------------
   <cmdIDM_DUSTBIN_KILL>
   -------------------------------------------------------------------------*)  
   
 PROCEDURE cmdIDM_DUSTBIN_KILL (hWnd : Windows.HWND);
  BEGIN
   IF YesNoQuery (hWnd, "Kill selected file(s)?", "Are you sure?")
    THEN
     KillSelectedFiles (hWnd);
     Windows.InvalidateRect (hWnd, Windows.NULL, Windows.true);
   END;
  END cmdIDM_DUSTBIN_KILL;
  

 (*-------------------------------------------------------------------------
   <cmdIDM_HELP_HELP>
   -------------------------------------------------------------------------*)  

 PROCEDURE cmdIDM_HELP_HELP (hWnd : Windows.HWND);
  BEGIN
   IF (Windows.WinHelp (
        hWnd, 
        SYSTEM.ADR ("DUSTBIN.HLP"), 
        Windows.HELP_FORCEFILE, 
        0) = Windows.false)
    THEN
     WndTools.MessageBox ("Sorry, currently no help is available.", 
                          "Dustbin Help");
   END;
  END cmdIDM_HELP_HELP;
  

 (*-------------------------------------------------------------------------
   <cmdIDM_HELP_ABOUT>
   -------------------------------------------------------------------------*)  
   
 PROCEDURE cmdIDM_HELP_ABOUT (hWnd : Windows.HWND);
  VAR dummy : LONGINT;
      dialog : WndTools.DLGPROC;
      lpDialog : Windows.FARPROC;
  BEGIN
   dialog := About.AboutDlg;
   lpDialog := Windows.MakeProcInstance (
                SYSTEM.VAL (Windows.FARPROC, dialog),
                hInstance);
   dummy := Windows.DialogBox (
             hInstance, 
             SYSTEM.ADR ("About"),            
             hWnd,
             About.AboutDlg (*lpDialog*));
  END cmdIDM_HELP_ABOUT;
  

 (*-------------------------------------------------------------------------
   <WM_COMMAND>
   -------------------------------------------------------------------------*)  

 PROCEDURE WM_COMMAND (hWnd : Windows.HWND;
                       msg : Windows.WORD;
                       wParam : Windows.WORD;
                       lParam : LONGINT);
  VAR dummy : LONGINT;
  BEGIN
   IF (wParam = IDM_DUSTBIN_QUIT)
    THEN dummy := Windows.PostMessage (hWnd, Windows.WM_CLOSE, 0, 0);
   ELSIF (wParam = IDM_DUSTBIN_OPTIONS)
    THEN cmdIDM_DUSTBIN_OPTIONS (hWnd);
   ELSIF (wParam = IDM_DUSTBIN_EMPTY)
    THEN cmdIDM_DUSTBIN_EMPTY (hWnd);
   ELSIF (wParam = IDM_DUSTBIN_KILL)
    THEN cmdIDM_DUSTBIN_KILL (hWnd);
   ELSIF (wParam = IDM_DUSTBIN_RESTORE)
    THEN cmdIDM_DUSTBIN_RESTORE (hWnd);
   ELSIF (wParam = IDM_DUSTBIN_RESTORESEL)
    THEN cmdIDM_DUSTBIN_RESTORESEL (hWnd);
   ELSIF (wParam = IDM_HELP_HELP)
    THEN cmdIDM_HELP_HELP (hWnd);
   ELSIF (wParam = IDM_HELP_ABOUT)
    THEN cmdIDM_HELP_ABOUT (hWnd);
   ELSE
    dummy := Windows.DefWindowProc (hWnd, msg, wParam, lParam);
   END;
  END WM_COMMAND;
  
 
 (*-------------------------------------------------------------------------
   <WndProc>
   -------------------------------------------------------------------------*)  
 
 PROCEDURE [WINDOWS] WndProc* (hWnd : Windows.HWND;
                               msg : Windows.WORD;
                               wParam : Windows.WORD;
                               lParam : LONGINT) : LONGINT;
  BEGIN
   IF (msg = Windows.WM_DESTROY)
    THEN RETURN WM_DESTROY (hWnd, msg, wParam, lParam);
   ELSIF (msg = Windows.WM_CLOSE)
    THEN RETURN WM_CLOSE (hWnd, msg, wParam, lParam);
   ELSIF (msg = Windows.WM_CREATE)
    THEN RETURN WM_CREATE (hWnd, msg, wParam, lParam);
   ELSIF (msg = Windows.WM_PAINT)
    THEN RETURN WM_PAINT (hWnd, msg, wParam, lParam);
   ELSIF (msg = Windows.WM_COMMAND)
    THEN WM_COMMAND (hWnd, msg, wParam, lParam);
   ELSIF (msg = Windows.WM_SIZE)
    THEN RETURN WM_SIZE (hWnd, msg, wParam, lParam);
   ELSIF (msg = Windows.WM_DROPFILES)
    THEN RETURN WM_DROPFILES (hWnd, msg, wParam, lParam);
   ELSIF (msg = Windows.WM_INITMENU)
    THEN RETURN WM_INITMENU (hWnd, msg, wParam, lParam);
   ELSIF (msg = Windows.WM_QUERYDRAGICON)
    THEN RETURN WM_QUERYDRAGICON (hWnd, msg, wParam, lParam);
   ELSIF (msg = Windows.WM_SYSCOMMAND)
    THEN RETURN WM_SYSCOMMAND (hWnd, msg, wParam, lParam);
   ELSE
    RETURN Windows.DefWindowProc (hWnd, msg, wParam, lParam);
   END;
  
   RETURN 0;
  END WndProc;
 

 (*-------------------------------------------------------------------------
   <GetWndInfo>
   -------------------------------------------------------------------------*)  
 
 PROCEDURE GetWndInfo* (VAR wndClass : Windows.WNDCLASS;
                        hInstance : Windows.HINSTANCE);
  VAR wndProc : WndTools.WNDPROC;
  BEGIN
   hIcon := Windows.LoadIcon (hInstance, SYSTEM.ADR("DustbinIcon"));
   hIconF := Windows.LoadIcon (hInstance, SYSTEM.ADR("DustBinIconF"));

   wndProc := WndProc;
   
   wndClass.style         := Windows.NULL;
   wndClass.lpfnWndProc   := WndProc (*SYSTEM.VAL (Windows.FARPROC, wndProc)*);
   wndClass.cbClsExtra    := 0;
   wndClass.cbWndExtra    := 0;
   wndClass.hInstance     := hInstance;
   wndClass.hIcon         := hIcon;
   wndClass.hCursor       := Windows.LoadCursor (
                              Windows.NULL, Windows.IDC_ARROW);
   wndClass.hbrBackground := Windows.GetStockObject (Windows.WHITE_BRUSH);
   wndClass.lpszMenuName  := SYSTEM.ADR ("DustBinMenu");
   wndClass.lpszClassName := SYSTEM.ADR (WndClassName);
  END GetWndInfo;
  

 (*-------------------------------------------------------------------------
   <PrepareWindow>
   -------------------------------------------------------------------------*)  
   
 PROCEDURE PrepareWindow (hInstance : Windows.HINSTANCE) : Windows.HWND;
  VAR hWnd : Windows.HWND;
      hwndChild : Windows.HWND;
      hMenu : Windows.HMENU;
      dummy : LONGINT;
      rc : Windows.RECT;
  BEGIN
   Windows.GetClientRect (Windows.GetDesktopWindow(), SYSTEM.ADR (rc));
    
   dummy := Windows.WS_EX_TOPMOST + Windows.WS_THICKFRAME +
            Windows.WS_EX_ACCEPTFILES + Windows.WS_OVERLAPPED +
            Windows.WS_SYSMENU + Windows.WS_MINIMIZEBOX + 
            Windows.WS_MAXIMIZEBOX;
   IF Options.oStartSymbol
    THEN dummy := dummy + Windows.WS_ICONIC;
   END;
    
   (* Hauptfenster erzeugen *)
   hWnd := Windows.CreateWindow (
           SYSTEM.ADR (WndClassName),
           SYSTEM.ADR ("Dust Bin"),
           dummy,
           rc.right DIV 4,
           rc.bottom DIV 4,
           rc.right DIV 2,
           rc.bottom DIV 2,
           Windows.NULL,
           Windows.NULL,
           hInstance,
           Windows.NULL);

   Windows.GetClientRect (hWnd, SYSTEM.ADR (rc));
   
   (* Listbox im Hauptfenster erzeugen *)
   dummy := Windows.CreateWindow (
             SYSTEM.ADR ("LISTBOX"),
             SYSTEM.ADR ("ListBox"),
             Windows.WS_CHILD +
             Windows.WS_VSCROLL + Windows.WS_HSCROLL + Windows.WS_VISIBLE +
             Windows.LBS_DISABLENOSCROLL + Windows.LBS_HASSTRINGS + 
             Windows.LBS_MULTIPLESEL + Windows.LBS_NOTIFY +
             Windows.LBS_NOINTEGRALHEIGHT + Windows.LBS_SORT,
             0,
             0,
             rc.right,
             rc.bottom,
             hWnd,
             IDM_LISTBOX,
             hInstance,
             Windows.NULL);
   
   hwndChild := Windows.GetDlgItem (hWnd, IDM_LISTBOX);
   Windows.ShowScrollBar (hwndChild, Windows.SB_BOTH, Windows.true);

   RETURN hWnd;
  END PrepareWindow;
  
 
 (*-------------------------------------------------------------------------
   <PrepareMenu>
   -------------------------------------------------------------------------*)  
   
 PROCEDURE PrepareMenu (hWnd : Windows.HWND);
  VAR hMenu : Windows.HMENU;
      dummy : LONGINT;
  BEGIN
   hMenu := Windows.GetMenu (hWnd);
   dummy := Windows.EnableMenuItem (
             hMenu,
             IDM_DUSTBIN_KILL,
             Windows.MF_GRAYED);

   dummy := Windows.InsertMenu (
             hMenu, 
             IDM_DUSTBIN_EMPTY, 
             Windows.MF_SEPARATOR, 
             0, 
             0);           
           
   dummy := Windows.InsertMenu (
             hMenu, 
             IDM_DUSTBIN_RESTORE, 
             Windows.MF_SEPARATOR, 
             0, 
             0);           

   dummy := Windows.InsertMenu (
             hMenu, 
             IDM_DUSTBIN_QUIT, 
             Windows.MF_SEPARATOR, 
             0, 
             0);           
  END PrepareMenu;
  
 
 (*-------------------------------------------------------------------------
   <PrepareSystemMenu>
   -------------------------------------------------------------------------*)  
   
 PROCEDURE PrepareSystemMenu (hWnd : Windows.HWND);
  VAR hMenu,
      hSysMenu : Windows.HMENU;
      dummy : LONGINT;
      label : ARRAY 40 OF CHAR;
  BEGIN
   hMenu := Windows.GetMenu (hWnd);
   hSysMenu := Windows.GetSystemMenu (hWnd, Windows.false);

   dummy := Windows.AppendMenu (
             hSysMenu, 
             Windows.MF_SEPARATOR, 
             0, 
             0);           

   dummy := Windows.GetMenuString (
             hMenu,
             IDM_DUSTBIN_EMPTY,
             SYSTEM.ADR (label),
             LEN (label),
             Windows.MF_BYCOMMAND);

   dummy := Windows.AppendMenu (
             hSysMenu, 
             Windows.MF_STRING + Windows.MF_GRAYED,
             IDM_DUSTBIN_EMPTY, 
             SYSTEM.ADR (label));           
  END PrepareSystemMenu;

   
 (*-------------------------------------------------------------------------
   <CreateWindow>
   -------------------------------------------------------------------------*)  
 
 PROCEDURE CreateWindow* (hInstance : Windows.HINSTANCE) : Windows.HWND;
  VAR hWnd : Windows.HWND;
  BEGIN
   hWnd := PrepareWindow (hInstance);
   PrepareMenu (hWnd);
   PrepareSystemMenu (hWnd);

   RETURN hWnd;
  END CreateWindow; 


 (*-------------------------------------------------------------------------
   <SetInstance>
   -------------------------------------------------------------------------*)  
 
 PROCEDURE SetInstance* (hInst : Windows.HINSTANCE);
  VAR hFile : Windows.HFILE;
  BEGIN
   hInstance := hInst;
  END SetInstance;


(*----------------------*)
(* Modulinitialisierung *)

BEGIN  
 hInstance := 0;
 content := NIL;
END DustBinWnd.

(****************************************************************************)
