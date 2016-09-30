(****************************************************************************)
(*
   Options V0.05a (Options.MOD)
   ==============
   
   Programmierer: Alexander Graf (Mat.Nr. 9355752)
                  Dietmar Schinnerl (Mat.Nr. 9355075)
   Projekt: Fallstudie Betriebssysteme: Windowsprogrammierung mit Oberon-2
   Compiler: POW! Oberon-2
   
                           (C) by Alexander Graf & Dietmar Schinnerl, 1996
                           
 ---------------------------------------------------------------------------
  Verwaltet die Einstellung des Dustbins, implementiert den Setup-Dialog
 und stellt Funktionen fuer das Ablegen der Einstellungen in der Registry
 zur Verfuegung.
 ---------------------------------------------------------------------------

 History:                          
 
  19.08.1996 / 0.05a : Dokumentation
  27.05.1996 / 0.04a : Grundgeruest fuer das Ablegen der Optionen in der
                        Registry
                       Setup-Dialog 
  26.05.1996 / 0.03a : neues Dialog mit Checkboxen
                       neues 'Attribut' oStartSymbol
  25.05.1996 / 0.02a : neues 'Attribut' oNotifyReadOnly
  17.05.1996 / 0.01a : ausgegliedert aus DUSTBINW.MOD
                                                                            *)
(****************************************************************************)

MODULE Options;

 (***************************************************************************)
 (* Benoetige Module importieren                                            *)
 
 IMPORT Windows,
        SYSTEM,
        Strings,
        Volume,
        Shell,
        Tools,
        WndTools;
 
 
 (***************************************************************************)
 (* globale Typen, Konstanten und Variablen                                 *)

 CONST IDC_NotifyFileDel  = 101;
       IDC_NotifyDirDel   = 102;
       IDC_NotifyReadOnly = 103;
       IDC_SoundSupport   = 104;
       IDC_StartSymbol    = 105;

       IDC_LISTBOX = 20501;
      
 
 VAR oStartSymbol-,
     oNotifyReadOnly-,
     oSoundSupport-,
     oNotifyFileDel-,
     oNotifyDirDel-  : BOOLEAN;
     
     DustBinDir- : ARRAY 128 OF CHAR; (* Verz. der geloeschten Dateien *)
     DustBinNFO- : ARRAY 13 OF CHAR;  (* Name der Info-Datei           *)


 (***************************************************************************)
     

 (*-------------------------------------------------------------------------
   <OptionsDlg> implementiert den Options-Dialog.
   -------------------------------------------------------------------------*)  

 PROCEDURE [WINDOWS] OptionsDlg* (hDlg : Windows.HWND;
                                  msg : Windows.WORD;
                                  wParam : Windows.WORD;
                                  lParam : LONGINT) : Windows.BOOL;
  VAR dummy : LONGINT;
  BEGIN
   IF (msg = Windows.WM_INITDIALOG )
    THEN
     IF oNotifyFileDel
      THEN 
       dummy := Windows.SendDlgItemMessage (
        hDlg, IDC_NotifyFileDel, Windows.BM_SETCHECK, Windows.true, 0);
      ELSE 
       dummy := Windows.SendDlgItemMessage (
        hDlg, IDC_NotifyFileDel, Windows.BM_SETCHECK, Windows.false, 0);
     END;
         
     IF oNotifyDirDel
      THEN 
       dummy := Windows.SendDlgItemMessage (
        hDlg, IDC_NotifyDirDel, Windows.BM_SETCHECK, Windows.true, 0);
      ELSE 
       dummy := Windows.SendDlgItemMessage (
        hDlg, IDC_NotifyDirDel, Windows.BM_SETCHECK, Windows.false, 0);
     END;

     IF oNotifyReadOnly
      THEN 
       dummy := Windows.SendDlgItemMessage (
        hDlg, IDC_NotifyReadOnly, Windows.BM_SETCHECK, Windows.true, 0);
      ELSE 
       dummy := Windows.SendDlgItemMessage (
        hDlg, IDC_NotifyReadOnly, Windows.BM_SETCHECK, Windows.false, 0);
     END;

     IF oSoundSupport
      THEN 
       dummy := Windows.SendDlgItemMessage (
        hDlg, IDC_SoundSupport, Windows.BM_SETCHECK, Windows.true, 0);
      ELSE 
       dummy := Windows.SendDlgItemMessage (
        hDlg, IDC_SoundSupport, Windows.BM_SETCHECK, Windows.false, 0);
     END;

     IF oStartSymbol
      THEN 
       dummy := Windows.SendDlgItemMessage (
        hDlg, IDC_StartSymbol, Windows.BM_SETCHECK, Windows.true, 0);
      ELSE 
       dummy := Windows.SendDlgItemMessage (
        hDlg, IDC_StartSymbol, Windows.BM_SETCHECK, Windows.false, 0);
     END;
         
     RETURN Windows.true;
   ELSIF (msg = Windows.WM_COMMAND)
    THEN
     IF (wParam = Windows.IDOK)
      THEN
       oNotifyFileDel := Windows.SendDlgItemMessage (
        hDlg, IDC_NotifyFileDel, Windows.BM_GETCHECK, 0, 0) = 1;
       oNotifyDirDel := Windows.SendDlgItemMessage (
        hDlg, IDC_NotifyDirDel, Windows.BM_GETCHECK, 0, 0) = 1;
       oNotifyReadOnly := Windows.SendDlgItemMessage (
        hDlg, IDC_NotifyReadOnly, Windows.BM_GETCHECK, 0, 0) = 1;
       oSoundSupport := Windows.SendDlgItemMessage (
        hDlg, IDC_SoundSupport, Windows.BM_GETCHECK, 0, 0) = 1;
       oStartSymbol := Windows.SendDlgItemMessage (
        hDlg, IDC_StartSymbol, Windows.BM_GETCHECK, 0, 0) = 1;
       
       Windows.EndDialog (hDlg, Windows.true);
       RETURN Windows.true
     ELSIF (wParam = Windows.IDCANCEL)
      THEN
       Windows.EndDialog (hDlg, Windows.true);
       RETURN Windows.true
     END;
   END;

   RETURN Windows.false;
  END OptionsDlg;
  

 (*-------------------------------------------------------------------------
   <CreateSettings> erstellt die Eintrage in der Registry mit den aktuellen
   Einstellungen.
   -------------------------------------------------------------------------*)  

 PROCEDURE CreateSettings*;
  VAR hKey : Shell.HKEY;
      dummy : LONGINT;
  BEGIN
   dummy := Shell.RegOpenKey (
             Shell.HKEY_CLASSES_ROOT,
             SYSTEM.ADR ("DUSTBIN"),
             SYSTEM.ADR (hKey));
   IF (dummy = Shell.ERROR_SUCCESS)
    THEN 
     dummy := Shell.RegCloseKey (hKey);
     RETURN;
   END;
             
   dummy := Shell.RegCreateKey (
             Shell.HKEY_CLASSES_ROOT,
             SYSTEM.ADR ("DUSTBIN"),
             SYSTEM.ADR (hKey));

   dummy := Shell.RegSetValue (
             hKey,
             SYSTEM.ADR ("OPTIONS\oNotifyFileDel"),
             Shell.REG_SZ,
             SYSTEM.ADR ("FALSE"),
             0);             

   dummy := Shell.RegSetValue (
             hKey,
             SYSTEM.ADR ("OPTIONS\oNotifyDirDel"),
             Shell.REG_SZ,
             SYSTEM.ADR ("FALSE"),
             0);             

   dummy := Shell.RegSetValue (
             hKey,
             SYSTEM.ADR ("OPTIONS\oNotifyReadOnly"),
             Shell.REG_SZ,
             SYSTEM.ADR ("FALSE"),
             0);             

   dummy := Shell.RegSetValue (
             hKey,
             SYSTEM.ADR ("OPTIONS\oSoundSupport"),
             Shell.REG_SZ,
             SYSTEM.ADR ("FALSE"),
             0);             

   dummy := Shell.RegSetValue (
             hKey,
             SYSTEM.ADR ("OPTIONS\oStartSymbol"),
             Shell.REG_SZ,
             SYSTEM.ADR ("FALSE"),
             0);             

   dummy := Shell.RegSetValue (
             hKey,
             SYSTEM.ADR ("DustBinDir"),
             Shell.REG_SZ,
             SYSTEM.ADR ("E:\DUSTBIN\"),
             0);             

   dummy := Shell.RegSetValue (
             hKey,
             SYSTEM.ADR ("DustBinNFO"),
             Shell.REG_SZ,
             SYSTEM.ADR ("DUSTBIN.NFO"),
             0);             

   dummy := Shell.RegCloseKey (hKey);
  END CreateSettings;


 (*-------------------------------------------------------------------------
   <GetSettings> holt die Einstellungen aus der Registry zurueck und legt
   sie in den definierten Variablen ab.
   -------------------------------------------------------------------------*)  

 PROCEDURE GetSettings*;
  VAR hKey : Shell.HKEY;
      dummy : LONGINT;
      buffer : ARRAY 128 OF CHAR;
      size : LONGINT;
  BEGIN
   dummy := Shell.RegOpenKey (
             Shell.HKEY_CLASSES_ROOT,
             SYSTEM.ADR ("DUSTBIN"),
             SYSTEM.ADR (hKey));

   size := 128;
   dummy := Shell.RegQueryValue (
             hKey,
             SYSTEM.ADR ("OPTIONS\oNotifyFileDel"),
             SYSTEM.ADR (buffer),
             SYSTEM.ADR (size));
   oNotifyFileDel := Tools.Compare (buffer, "TRUE");

   size := 128;
   dummy := Shell.RegQueryValue (
             hKey,
             SYSTEM.ADR ("OPTIONS\oNotifyDirDel"),
             SYSTEM.ADR (buffer),
             SYSTEM.ADR (size));             
   oNotifyDirDel := Tools.Compare (buffer, "TRUE");

   size := 128;
   dummy := Shell.RegQueryValue (
             hKey,
             SYSTEM.ADR ("OPTIONS\oNotifyReadOnly"),
             SYSTEM.ADR (buffer),
             SYSTEM.ADR (size));             
   oNotifyReadOnly := Tools.Compare (buffer, "TRUE");

   size := 128;
   dummy := Shell.RegQueryValue (
             hKey,
             SYSTEM.ADR ("OPTIONS\oSoundSupport"),
             SYSTEM.ADR (buffer),
             SYSTEM.ADR (size));             
   oSoundSupport := Tools.Compare (buffer, "TRUE");

   size := 128;
   dummy := Shell.RegQueryValue (
             hKey,
             SYSTEM.ADR ("OPTIONS\oStartSymbol"),
             SYSTEM.ADR (buffer),
             SYSTEM.ADR (size));             
   oStartSymbol := Tools.Compare (buffer, "TRUE");

   size := 128;
   dummy := Shell.RegQueryValue (
             hKey,
             SYSTEM.ADR ("DustBinDir"),
             SYSTEM.ADR (DustBinDir),
             SYSTEM.ADR (size));             

   size := 13;
   dummy := Shell.RegQueryValue (
             hKey,
             SYSTEM.ADR ("DustBinNFO"),
             SYSTEM.ADR (DustBinNFO),
             SYSTEM.ADR (size));             

   dummy := Shell.RegCloseKey (hKey);
  END GetSettings;


 (*-------------------------------------------------------------------------
   <SetSettings> legt die Einstellungen in der Registry ab.
   -------------------------------------------------------------------------*)  

 PROCEDURE SetSettings*;
  VAR hKey : Shell.HKEY;
      dummy : LONGINT;
      buffer : ARRAY 6 OF CHAR;
  BEGIN
   dummy := Shell.RegOpenKey (
             Shell.HKEY_CLASSES_ROOT,
             SYSTEM.ADR ("DUSTBIN"),
             SYSTEM.ADR (hKey));

   IF oNotifyFileDel
    THEN buffer := "TRUE";
    ELSE buffer := "FALSE";
   END;
   dummy := Shell.RegSetValue (
             hKey,
             SYSTEM.ADR ("OPTIONS\oNotifyFileDel"),
             Shell.REG_SZ,
             SYSTEM.ADR (buffer),
             0);

   IF oNotifyDirDel
    THEN buffer := "TRUE";
    ELSE buffer := "FALSE";
   END;
   dummy := Shell.RegSetValue (
             hKey,
             SYSTEM.ADR ("OPTIONS\oNotifyDirDel"),
             Shell.REG_SZ,
             SYSTEM.ADR (buffer),
             0);             

   IF oNotifyReadOnly
    THEN buffer := "TRUE";
    ELSE buffer := "FALSE";
   END;
   dummy := Shell.RegSetValue (
             hKey,
             SYSTEM.ADR ("OPTIONS\oNotifyReadOnly"),
             Shell.REG_SZ,
             SYSTEM.ADR (buffer),
             0);             

   IF oSoundSupport
    THEN buffer := "TRUE";
    ELSE buffer := "FALSE";
   END;
   dummy := Shell.RegSetValue (
             hKey,
             SYSTEM.ADR ("OPTIONS\oSoundSupport"),
             Shell.REG_SZ,
             SYSTEM.ADR (buffer),
             0);             

   IF oStartSymbol
    THEN buffer := "TRUE";
    ELSE buffer := "FALSE";
   END;
   dummy := Shell.RegSetValue (
             hKey,
             SYSTEM.ADR ("OPTIONS\oStartSymbol"),
             Shell.REG_SZ,
             SYSTEM.ADR (buffer),
             0);             

   dummy := Shell.RegSetValue (
             hKey,
             SYSTEM.ADR ("DustBinDir"),
             Shell.REG_SZ,
             SYSTEM.ADR (DustBinDir),
             0);             

   dummy := Shell.RegSetValue (
             hKey,
             SYSTEM.ADR ("DustBinNFO"),
             Shell.REG_SZ,
             (*SYSTEM.ADR (DustBinNFO),*)
             SYSTEM.ADR ("DUSTBIN.NFO"),
             0);             

   dummy := Shell.RegCloseKey (hKey);
  END SetSettings;


 (*-------------------------------------------------------------------------
   <SetupDlg> stellt den Setup-Dialog dar.
   -------------------------------------------------------------------------*)  

 PROCEDURE [WINDOWS] SetupDlg* (hDlg : Windows.HWND;
                                msg : Windows.WORD;
                                wParam : Windows.WORD;
                                lParam : LONGINT) : Windows.BOOL;
  VAR dummy : LONGINT;
      drive : ARRAY 4 OF CHAR;
      ctr,
      resCode : INTEGER;
  BEGIN
   IF (msg = Windows.WM_INITDIALOG )
    THEN
     FOR ctr := 0 TO 25 DO
      IF (Windows.GetDriveType (ctr) = Windows.DRIVE_FIXED)
       THEN
        drive[0] := CHR (ORD ('A') + ctr);
        drive[1] := CHR (0);
        Strings.Append (drive, ":\");
        Volume.ChangeDirectory (drive, resCode);
        
        IF (resCode = Volume.NOERROR)
         THEN
          dummy := Windows.SendDlgItemMessage (
                    hDlg,
                    IDC_LISTBOX,
                    Windows.LB_ADDSTRING,
                    0,
                    SYSTEM.ADR (drive));
        END;
      END;
     END;
         
     RETURN Windows.true;
   ELSIF (msg = Windows.WM_COMMAND)
    THEN
     IF (wParam = Windows.IDOK)
      THEN
       dummy := Windows.SendDlgItemMessage (
                 hDlg, IDC_LISTBOX, Windows.LB_GETCURSEL, 0, 0);

       IF (dummy = Windows.LB_ERR)
        THEN 
         WndTools.MessageBox (
          "Please select a drive from the list.", "Hint");
         RETURN Windows.true;
       END;
       
       dummy := Windows.SendDlgItemMessage (
                 hDlg, 
                 IDC_LISTBOX, 
                 Windows.LB_GETTEXT, 
                 SHORT (dummy), 
                 SYSTEM.ADR (drive));
                 
       DustBinDir := "";
       Strings.Append (DustBinDir, drive);
       Strings.Append (DustBinDir, "DUSTBIN");

       Volume.ChangeDirectory (DustBinDir, resCode);
       IF (resCode = Volume.PATHNOTFOUND)
        THEN
         Volume.CreateDirectory (DustBinDir, resCode);
         
         IF (resCode = Volume.NOERROR)
          THEN 
           Strings.AppendChar (DustBinDir, "\");
          ELSE 
           WndTools.Panic ("Couldn't create directory!");
           RETURN Windows.true;
         END;
        ELSIF (resCode = Volume.NOERROR)
         THEN
          WndTools.MessageBox ("Directory already exists!", "Notification");
          Strings.AppendChar (DustBinDir, "\");
        ELSE
         WndTools.Panic ("Couldn't create directory!");
         RETURN Windows.true;
       END;
       
       SetSettings;
       
       Windows.EndDialog (hDlg, Windows.true);
       RETURN Windows.true
     END;
   END;

   RETURN Windows.false;
  END SetupDlg;


(*----------------------*)
(* Modulinitialisierung *)

BEGIN
 oNotifyFileDel  := FALSE;
 oNotifyDirDel   := FALSE;
 oSoundSupport   := FALSE;
 oNotifyReadOnly := FALSE;
 oStartSymbol    := FALSE;

 DustBinDir := "";
 DustBinNFO := "";
 
 CreateSettings;
END Options.

(****************************************************************************)

