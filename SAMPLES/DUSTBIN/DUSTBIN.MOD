(****************************************************************************)
(*
   DustBin V0.01a (DustBin.MOD)
   ==============
   
   Ein Papierkorb fuer Windows 3.1x
   
   Programmierer: Alexander Graf (Mat.Nr. 9355752)
                  Dietmar Schinnerl (Mat.Nr. 9355075)
   Projekt: Fallstudie Betriebssysteme: Windowsprogrammierung mit Oberon-2
   Compiler: POW! Oberon-2
   
                           (C) by Alexander Graf & Dietmar Schinnerl, 1996
                           
 ---------------------------------------------------------------------------
 
 History:                          
 
  06.05.1996 / 0.01a : Warum stuerzt es ab?
  05.05.1996 / 0.00a : Grundgeruest
                                                                            *)
(****************************************************************************)

MODULE DustBin;


 (***************************************************************************)
 (* Benoetige Module importieren                                            *)
 
 IMPORT Utils,
        Windows,        (* Definition etc. fuer Windowsprogrammierung *)
        SYSTEM,
        WndTools,       (* Ein paar nuetzliche Tools fuer Windowsprogr. *)
        DustBinWnd,     (* DustBin-MainWindow *)
        Options;
 
 
 (***************************************************************************)
 
 (*-------------------------------------------------------------------------
   <InitApplication>
   -------------------------------------------------------------------------*)

 PROCEDURE InitApplication (hInstCurr: Windows.HINSTANCE) : BOOLEAN;
  VAR wndClass : Windows.WNDCLASS;
  BEGIN
   (* anwendungsspezfische Klassen registrieren *)
   DustBinWnd.GetWndInfo (wndClass, hInstCurr);
   
   IF Windows.RegisterClass (SYSTEM.ADR (wndClass)) = 0
    THEN RETURN FALSE;
    ELSE RETURN TRUE;
   END;
  END InitApplication;
  
 
 (*-------------------------------------------------------------------------
   <InitInstance>
   -------------------------------------------------------------------------*)

 PROCEDURE InitInstance (hInstCurr : Windows.HINSTANCE;
                         nCmdShow : INTEGER) : BOOLEAN;
  VAR hWnd : Windows.HWND;
      dummy : LONGINT;
  BEGIN
   (* Hauptfenster erzeugen *)
   hWnd := DustBinWnd.CreateWindow (hInstCurr);
   
   IF (hWnd = 0)
    THEN RETURN FALSE;
   END;
   
   dummy := Windows.ShowWindow (hWnd, nCmdShow);
   Windows.UpdateWindow (hWnd);

   RETURN TRUE;
  END InitInstance;                   


 (***************************************************************************)
 (* Windows-Eintrittspunkt                                                  *)

 PROCEDURE [WINDOWS] WinMain* (hInstCurr: Windows.HINSTANCE;
                               hInstPrev: Windows.HINSTANCE;                                   
                               lpCmdLine: Windows.LPSTR;
                               nCmdShow: INTEGER) : INTEGER;
  VAR msg : Windows.MSG;
      dummy : LONGINT;
  BEGIN
   Options.GetSettings;
   DustBinWnd.SetInstance (hInstCurr);
   
   (* erste Instanz? *)
   IF ( hInstPrev = Windows.NULL )
    THEN 
     IF ~InitApplication (hInstCurr)
      THEN 
       WndTools.MessageBox ("Could not register window class!",
                            "Dustbin - Error");
       RETURN Windows.false;
      ELSE
       IF ~InitInstance (hInstCurr, nCmdShow)
        THEN
         WndTools.MessageBox ("Could not create main window!",
                              "Dustbin - Error");
         RETURN Windows.false;
       END;  
     END;
    ELSE
     WndTools.MessageBox ("Dustbin can be runned only once!",
                          "Dustbin - Error");
               
     RETURN Windows.false;
   END;
   
   (* Message Loop *)
   WHILE Windows.GetMessage (SYSTEM.ADR (msg), 
                             Windows.NULL,
                             Windows.NULL,
                             Windows.NULL) # 0 DO
    dummy := Windows.TranslateMessage (SYSTEM.ADR (msg));
    dummy := Windows.DispatchMessage (SYSTEM.ADR (msg));
   END;

   Options.SetSettings;
   
   RETURN msg.wParam;
  END WinMain;
 
END DustBin.

(****************************************************************************)
