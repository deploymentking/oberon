(****************************************************************************)
(*
   WindowTools V0.03a (WndTools.MOD)
   ==================
   
   Programmierer: Alexander Graf (Mat.Nr. 9355752)
                  Dietmar Schinnerl (Mat.Nr. 9355075)
   Projekt: Fallstudie Betriebssysteme: Windowsprogrammierung mit Oberon-2
   Compiler: POW! Oberon-2
   
                           (C) by Alexander Graf & Dietmar Schinnerl, 1996
                           
 ---------------------------------------------------------------------------

  Sammlung nuetzlicher kleiner Routinen bzw. Typdefinitionen fuer die 
 Programmierung unter Windows.
 
 ---------------------------------------------------------------------------
 
 History:                          
 
  20.08.1996 / 0.03a : hinzufuegen von 'ShowFileErrorMsg'
  19.08.1996 / 0.02a : hinzufuegen von 'Windows.MB_TASKMODAL'
  06.05.1996 / 0.01a : MessageBox hinzugefuegt
  05.05.1996 / 0.00a : Grundgeruest
                                                                            *)
(****************************************************************************)

MODULE WndTools;

 (***************************************************************************)
 (* Benoetige Module importieren                                            *)
 
 IMPORT Windows, 
        SYSTEM,
        File;
 

 (***************************************************************************)
 (* globale Typen, Konstanten und Variablen                                 *)
 
 TYPE WNDPROC* = PROCEDURE [WINDOWS] (hWnd : Windows.HWND;
                                      msg : Windows.WORD;
                                      wParam : Windows.WORD;
                                      lParam : LONGINT) : LONGINT;
                                      
      DLGPROC* = PROCEDURE [WINDOWS] (hDlg : Windows.HWND;
                                      msg : Windows.WORD;
                                      wParam : Windows.WORD;
                                      lParam : LONGINT) : Windows.BOOL;
                                      
      TIMERPROC* = PROCEDURE [WINDOWS] (hWnd : Windows.HWND;
                                        msg : Windows.WORD;
                                        idTimer : Windows.WORD;
                                        dwTime : LONGINT);


 (***************************************************************************)

 (*-------------------------------------------------------------------------
   <MessageBox> gibt ein Windows-MessageBox aus, wobei der Message- und
   Header-Text frei bestimmt werden koennen. Die MessageBox besitzt nur
   einen OK-Button.
   -------------------------------------------------------------------------*)

 PROCEDURE MessageBox* (msg : ARRAY OF CHAR; header : ARRAY OF CHAR);
  VAR dummy : LONGINT;
  BEGIN
   dummy := Windows.MessageBox (
             Windows.NULL,
             SYSTEM.ADR (msg),
             SYSTEM.ADR (header),
             Windows.MB_OK + Windows.MB_ICONINFORMATION +
             Windows.MB_TASKMODAL);
  END MessageBox;
 

 (*-------------------------------------------------------------------------
   <Panic> gibt eine Windows-MessageBox aus, wobei nur der Message-Text frei
   bestimmt werden kann. Der Header-Text ist immer "PANIC". Zusaetzlich wird
   auch noch ein Beep (am PC-Lautsprecher) ausgegeben.
   -------------------------------------------------------------------------*)

 PROCEDURE Panic* (msg : ARRAY OF CHAR);
  VAR dummy : LONGINT;
  BEGIN
   Windows.MessageBeep (-1);
   dummy := Windows.MessageBox (
             Windows.NULL,
             SYSTEM.ADR (msg),
             SYSTEM.ADR ("PANIC"),
             Windows.MB_OK + Windows.MB_ICONEXCLAMATION +
             Windows.MB_TASKMODAL);
  END Panic;
 

 (*-------------------------------------------------------------------------
   <Assert> implementiert eine einfache Pruefung von Zusicherungen, faellt
   dieses Zusicherung negativ aus, so wird das Programm mit einer 
   definierbaren Fehlermeldung abgebrochen, wobei auch der Modulname aus-
   gegeben werden kann.
   -------------------------------------------------------------------------*)

 PROCEDURE Assert* (bool : BOOLEAN; 
                    modul : ARRAY OF CHAR; 
                    msg : ARRAY OF CHAR);
  BEGIN
   IF ~bool
    THEN
     MessageBox (msg, modul);
     HALT (0);
   END;
  END Assert;


 (*-------------------------------------------------------------------------
   <ShowFileErrorMsg> 
   -------------------------------------------------------------------------*)
   
 PROCEDURE ShowFileErrorMsg* (resCode : INTEGER);
  BEGIN
   CASE resCode OF 
      File.NOERROR          : 
       MessageBox ("No error.", "File error status");
    | File.FILENOTFOUND     : 
       MessageBox ("File not found.", "File error status");
    | File.SHORTBUFFER      : 
       MessageBox ("Short buffer.", "File error status");
    | File.ACCESSDENIED     : 
       MessageBox ("Access denied.", "File error status");
    | File.WRITEPROTECTED  : 
       MessageBox ("Write protected.", "File error status");
    | File.SHARINGVIOLATION : 
       MessageBox ("Sharing violation.", "File error status");
   ELSE
    MessageBox ("Unknown file error.", "File error status"); 
   END;
  END ShowFileErrorMsg;


END WndTools.

(****************************************************************************)
