(* ======================================================================== *)
(* Projekt Minifrac                                                         *)
(*                                                                          *)
(* Fallstudie Betriebssysteme (Windowsprogrammierung unter Oberon-2         *)
(*                                                                          *)
(* Autoren:                                                                 *)
(*          Richard Beitelmair   Matr.Nr.: 9155387 /880   SS1995            *)
(*          Michael Trauner      Matr.Nr.  9356714 /881   SS1996            *)
(*          Peter   Winter       Matr.Nr.: 9355148 /881   SS1996            *)
(*                                                                          *)
(* LVA-Leiter:                                                              *)
(*          Peter René Dietmüller, dietmueller@fim.uni-linz.ac.at           *)
(*                                                                          *)
(* Sprache:                                                                 *)
(*          Pow! 3.0 beta                                                   *)
(*          Oberon-2 Compiler Version 1.18 Beta5                            *)
(*                                                                          *)
(* Datum der letzten Aenderung: 30.10.1996                                  *)
(* ------------------------------------------------------------------------ *)
(* Fraktalgenerator für Windows zum Zeichnen von Mandelbrot- und            *)
(*                                                  Julia-Mengen            *)
(*    Idee:        Richard Beitelmair                                       *)
(*    Erweiterung: Michael Trauner und Peter Winter                         *)
(*                                                                          *)
(* Anmerkung: Das Programm wurde fuer den Einsatz unter Win 3.x konzipiert  *)
(* Fuer diverse Anomalitaeten unter Windows 95 bzw. NT wird keine Garantie  *)
(* uebernommen, da das Windows-API fuer Win 3.x verwendet wurde             *)
(* ======================================================================== *)

MODULE Minifrac;

(* 
 * notwendige Module importieren
 *) 
IMPORT Win  := Windows, 
       Sys  := SYSTEM,
       Bitm := Bitmap,
       Fra  := Fractal,
       Glo  := Global,
       Abo  := About,
       Uti  := Utils,
       T    := Tools,
       Z    := Zoom,
       Fl   := Float;

 (*
 * globale Konstanten, Variablen
 *)
CONST
  MDIFrameClass = "CFrame";
  MDIChildClass = "CClient";

  IDM_NEW       = 101;
  IDM_EXIT      = 102;
  IDM_CASCADE   = 201;
  IDM_TILE_H    = 202;
  IDM_TILE_V    = 203;
  IDM_HELP      = 301;  
  IDM_ABOUT     = 302;
  IDM_PARAMETER = 401;
  IDM_STOPALL   = 402;
  IDM_EDIT      = 501;

  ID_MENGE      = 2001;
  ID_MANDEL     = 2002;
  ID_JULIA      = 2003;
  ID_XMIN       = 2005;
  ID_XMAX       = 2006;
  ID_YMED       = 2007; 
  ID_KONSTANTE  = 2008;           
  ID_REAL       = 2009;      
  ID_IMAG       = 2010;
  ID_RTXT       = 2011;
  ID_ITXT       = 2012;      


(*
 * globale Variablen
 *)
VAR  
  hInst         : Win.HANDLE;  (* application´s instance handle *)
  hWndChild     : Win.HWND;
  hWndClient    : Win.HWND;
  hWnd          : Win.HWND;    (* Handle Main Window *)
  hDlg          : Win.HWND;  
  hWndChildLast : Win.HWND;
  cr            : Win.RECT;    (* Abmessungen eines Childfensters *)
  realData      : Glo.FracRealData; (* Parameter fuer Fraktal *)
  nrOfChilds    : INTEGER;     (* Anzahl existierender Childwindows *)
  nrOfNewChild  : INTEGER;
  cancel        : BOOLEAN;     (* Parameteraenderungen akzeptieren? *)
  lpProc        : Win.FARPROC; (* Adresse einer Prozedur *)
  titleStr      : ARRAY 20 OF CHAR;  (* Titelzeile eines Fraktalfensters *)
 
(* ********** *)


(* 
 * setzt den Status eines durch hWnd spezifizierten Childfensters auf 
 * BREAK, sodass eine allfaellige Berechnung eines Fraktals abgebrochen 
 * wird  (Callback)
 *)
PROCEDURE [WINDOWS] StopFracCalc(hWnd   : Win.HWND; 
                                 lParam : LONGINT) : Win.BOOL;
BEGIN
  IF (Fra.GetStatus(hWnd) = Glo.DEMANDCALC) OR
     (Fra.GetStatus(hWnd) = Glo.CALCULATING) THEN
    Fra.SetStatus(hWnd, Glo.BREAK);
  END; 
  
  RETURN Win.true;
END StopFracCalc;


(* ***** *)


(* 
 * iteriert ueber alle Childwindows und veranlasst diese, eine allfaellige 
 * Fraktalberechnung eines Childwindows abzubrechen 
 *)
PROCEDURE StopAllFracCalc();
VAR
  dummy : LONGINT;
BEGIN
  dummy := Win.EnumChildWindows(hWnd, lpProc, 0);
  ASSERT (dummy # 0);
END StopAllFracCalc;

 
(* ***** *)
 
 
(* 
 * Adresse einer Callback-Prozedur ermitteln
 * Rueckgabewert in lpProc
 *) 
PROCEDURE [WINDOWS] MakeCallbackProc(cbProc     : Glo.CALLBACKPROC;
                                     VAR lpProc : Win.FARPROC);
BEGIN
   lpProc := Win.MakeProcInstance (Sys.VAL(Win.FARPROC, cbProc), hWnd);
   ASSERT (lpProc # Win.NULL);
END MakeCallbackProc;

 
(* ***** *)
 
 
(*
 * Dialog fuer Eingabefenster
 * Editiermoeglichkeit fuer die Parameter eines Fraktals
 *)
PROCEDURE [WINDOWS] DlgEditParam (hDlg    : Win.HWND; 
                                  message : INTEGER;
                                  wParam  : INTEGER; 
                                  lParam  : LONGINT
                                  ): Win.BOOL;
VAR rc         : Win.HANDLE;
    r          : LONGINT;
    stringData : Glo.FracStrData;
    dummy      : INTEGER;
    error      : BOOLEAN;  (* ungueltiger Wert fuer Parameter *)
BEGIN
  T.ConvertToStr(realData, stringData);

  CASE message OF
  |Win.WM_INITDIALOG:
    IF (stringData.set = "M") THEN     (* Mandelbaum *)
      Win.CheckRadioButton (hDlg, ID_MANDEL, ID_JULIA, ID_MANDEL);
      dummy:=Win.EnableWindow(Win.GetDlgItem(hDlg, ID_KONSTANTE), Win.false);
      dummy:=Win.EnableWindow(Win.GetDlgItem(hDlg, ID_REAL), Win.false);      
      dummy:=Win.EnableWindow(Win.GetDlgItem(hDlg, ID_IMAG), Win.false);
      
    ELSE                               (* Juliamenge *)
      Win.CheckRadioButton (hDlg, ID_MANDEL, ID_JULIA, ID_JULIA);
      dummy:=Win.EnableWindow(Win.GetDlgItem(hDlg, ID_KONSTANTE), Win.true);
      dummy:=Win.EnableWindow(Win.GetDlgItem(hDlg, ID_REAL), Win.true);
      dummy:=Win.EnableWindow(Win.GetDlgItem(hDlg, ID_IMAG), Win.true);
      Win.SetDlgItemText (hDlg, ID_REAL,Sys.ADR(stringData.k_real));
      Win.SetDlgItemText (hDlg, ID_IMAG,Sys.ADR(stringData.k_imag));
    END;
    
    Win.SetDlgItemText (hDlg, ID_XMIN,Sys.ADR(stringData.xmin));
    Win.SetDlgItemText (hDlg, ID_XMAX,Sys.ADR(stringData.xmax));
    Win.SetDlgItemText (hDlg, ID_YMED,Sys.ADR(stringData.ymed));
    RETURN Win.true;
    
  |Win.WM_COMMAND:
    IF (wParam = Win.IDOK) THEN
      error := FALSE;
      rc:=Win.GetDlgItemText (hDlg, ID_XMIN, Sys.ADR(stringData.xmin), 10);
      IF (Fl.ValResult(stringData.xmin) # Fl.STRINGILLEGAL) THEN
        realData.xmin := Fl.Val(stringData.xmin);
      ELSE
        error := TRUE;
        T.StopMessageBox("ungültiger Wert!", "Xmin neu eingeben");
      END;

      rc:=Win.GetDlgItemText (hDlg, ID_XMAX, Sys.ADR(stringData.xmax), 10);
      IF (Fl.ValResult(stringData.xmax) # Fl.STRINGILLEGAL) THEN
        realData.xmax := Fl.Val(stringData.xmax);
      ELSE
        error := TRUE;
        T.StopMessageBox("ungültiger Wert!", "Xmax neu eingeben");
      END;

      rc:=Win.GetDlgItemText (hDlg, ID_YMED, Sys.ADR(stringData.ymed), 10);
      IF (Fl.ValResult(stringData.ymed) # Fl.STRINGILLEGAL) THEN
        realData.ymed:= Fl.Val(stringData.ymed); 
      ELSE
        error := TRUE;
        T.StopMessageBox("ungültiger Wert!", "Ymitt neu eingeben");
      END;

      IF (realData.set = "J") THEN  (* Parameter fuer Julia abfragen *)
        rc:=Win.GetDlgItemText (hDlg, ID_REAL, Sys.ADR(stringData.k_real), 10);
        IF (Fl.ValResult(stringData.k_real) # Fl.STRINGILLEGAL) THEN
          realData.k_real := Fl.Val(stringData.k_real);
        ELSE
          error := TRUE;
          T.StopMessageBox("ungültiger Wert!", "Real neu eingeben");
        END;

        rc:=Win.GetDlgItemText (hDlg, ID_IMAG, Sys.ADR(stringData.k_imag), 10);
        IF (Fl.ValResult(stringData.k_imag) # Fl.STRINGILLEGAL) THEN
          realData.k_imag := Fl.Val(stringData.k_imag);
        ELSE
          error := TRUE;
          T.StopMessageBox("ungültiger Wert!", "Imag neu eingeben");
        END;
      END;
      
      IF (~error) THEN   (* Parameter gueltig? *)
        Win.EndDialog (hDlg, Win.true); 
        cancel := TRUE;
      END;
      cancel := FALSE;   (* Parameteraenderungen akzeptieren *)

    ELSIF (wParam = Win.IDCANCEL) THEN
      Win.EndDialog (hDlg, Win.true); 
        cancel := TRUE;  (* Veraenderungen der Parameter nicht uebernehmen *)

    ELSIF (wParam = ID_MANDEL) THEN
      stringData.set := "M";
      realData.set   := "M";
      Win.CheckRadioButton(hDlg, ID_MANDEL, ID_JULIA, ID_MANDEL);
      dummy:=Win.EnableWindow(Win.GetDlgItem(hDlg, ID_KONSTANTE), Win.false);
      dummy:=Win.EnableWindow(Win.GetDlgItem(hDlg, ID_REAL), Win.false);      
      dummy:=Win.EnableWindow(Win.GetDlgItem(hDlg, ID_IMAG), Win.false);
      dummy:=Win.EnableWindow(Win.GetDlgItem(hDlg, ID_RTXT), Win.false);      
      dummy:=Win.EnableWindow(Win.GetDlgItem(hDlg, ID_ITXT), Win.false);
      Win.SetDlgItemText (hDlg, ID_REAL, Sys.ADR("          "));
      Win.SetDlgItemText (hDlg, ID_IMAG, Sys.ADR("          "));
    
    ELSIF (wParam = ID_JULIA) THEN
      stringData.set := "J";
      realData.set   := "J";
      Win.CheckRadioButton(hDlg, ID_MANDEL, ID_JULIA, ID_JULIA);
      dummy:=Win.EnableWindow(Win.GetDlgItem(hDlg, ID_KONSTANTE), Win.true);
      dummy:=Win.EnableWindow(Win.GetDlgItem(hDlg, ID_REAL), Win.true);
      dummy:=Win.EnableWindow(Win.GetDlgItem(hDlg, ID_IMAG), Win.true);
      dummy:=Win.EnableWindow(Win.GetDlgItem(hDlg, ID_RTXT), Win.true);      
      dummy:=Win.EnableWindow(Win.GetDlgItem(hDlg, ID_ITXT), Win.true);
      Win.SetDlgItemText (hDlg, ID_REAL,Sys.ADR(stringData.k_real));
      Win.SetDlgItemText (hDlg, ID_IMAG,Sys.ADR(stringData.k_imag));
    
    ELSE
      RETURN Win.false;
    END;
  ELSE
    RETURN Win.false;
  END;
  RETURN Win.true;    
END DlgEditParam;                              


(* ***** *)


(* 
 * MiniFrac Dialog Eingabefenster aufrufen
 *)
PROCEDURE FracParamDlg(hWnd : Win.HWND);
VAR
  dlgProc  : Glo.DLGPROC;
  lpDialog : Win.FARPROC;
BEGIN
  hInst    := hInst;
  dlgProc  := DlgEditParam;
  lpDialog := Win.MakeProcInstance (Sys.VAL(Win.FARPROC, dlgProc),hInst); 
  hDlg     := Win.DialogBox(hInst, Sys.ADR("Param"), hWnd, DlgEditParam(*lpDialog*));
END FracParamDlg;


(* ***** *)


(*
 * Aufruf des About-Dialogs
 *)
PROCEDURE DlgAbout (hWnd : Win.HWND);
VAR 
  dummy    : LONGINT;
  dlgProc  : Glo.DLGPROC;
  lpDialog : Win.FARPROC;
BEGIN
  dlgProc  := Abo.AboutDlg;
  lpDialog := Win.MakeProcInstance (Sys.VAL(Win.FARPROC, dlgProc), hInst);
  IF (Win.DialogBox(hInst, Sys.ADR("About"), hWnd, Abo.AboutDlg (*lpDialog*)) = -1) THEN
     T.DisplayError("Kann Dialogbox nicht anlegen!"); 
  END;
END DlgAbout;


(* ***** *)


(*
 * erzeugt ein Child-Window
 *)
PROCEDURE CreateChildWindow(title      : ARRAY OF CHAR;
                            hInstCurr  : Win.HINSTANCE;
                            hWndClient : Win.HWND) : Win.HWND;
VAR
  hWnd  : Win.HWND;
  mcs   : Win.MDICREATESTRUCT;
  dummy : LONGINT;
BEGIN
  mcs.szClass := Sys.ADR(MDIChildClass);
  mcs.szTitle := Sys.ADR(title);
  mcs.hOwner  := hInstCurr;
  mcs.x       := Win.CW_USEDEFAULT;
  mcs.y       := Win.CW_USEDEFAULT;
  mcs.cx      := cr.right + 2;
  mcs.cy      := cr.bottom + 22;
  mcs.style   := Win.MDIS_ALLCHILDSTYLES;
  mcs.lParam  := 0;
  hWnd := SHORT(Win.SendMessage(hWndClient, Win.WM_MDICREATE, 0, 
                                Sys.ADR(mcs)));
  IF hWnd = 0 THEN
    T.DisplayError("Kann Childwindow nicht anlegen!");
    RETURN 0;
  END;
  dummy := Win.ShowWindow(hWnd, Win.SW_SHOW);

  RETURN hWnd;
END CreateChildWindow;


(* ***** *)


(*
 * prueft, ob ein Menue mit dem Text "menu" existiert und 
 * uebergibt die Position dieses Menues.
 *)
PROCEDURE GetWindowPos(hMenu : Win.HMENU;
                       menu  : ARRAY OF CHAR) : INTEGER;
VAR
  i     : INTEGER;
  mt    : ARRAY 20 OF CHAR;
  dummy : LONGINT;
BEGIN
  i := 0;
  dummy := Win.GetMenuString(hMenu, i, Sys.ADR(mt), LEN(mt), 
                             Win.MF_BYPOSITION);
  WHILE (i < Win.GetMenuItemCount(hMenu)) & (mt # menu) DO
    INC(i);
    dummy := Win.GetMenuString(hMenu, i, Sys.ADR(mt), LEN(mt), 
                               Win.MF_BYPOSITION);
  END;
  RETURN i;
END GetWindowPos;


(* ***** *)


(* 
 * Window Prozedur fuer Frame Windows
 *)
PROCEDURE [WINDOWS] MDIFrameWndProc*(hWnd    : Win.HWND;
                                     message : Win.WORD;
                                     wParam  : Win.WORD;
                                     lParam  : LONGINT) : LONGINT;
VAR
  ccs   : Win.CLIENTCREATESTRUCT;
  hdc   : Win.HDC;
  hMenu : Win.HMENU;
  ps    : Win.PAINTSTRUCT;
  dummy : LONGINT;
  rf    : Win.RECT;  (* Rechteck des Clientbereichs des Frame Window *)
BEGIN 
  IF message = Win.WM_CREATE THEN
    (* create client window *)
    hMenu := Win.GetMenu(hWnd);
    ccs.hWindowMenu  := Win.GetSubMenu(hMenu, GetWindowPos(hMenu, "&Window"));
    ccs.idFirstChild := 30000;
    Win.GetClientRect(hWnd, Sys.ADR(rf));
    hWndClient := Win.CreateWindow(
                  Sys.ADR("MDICLIENT"), Win.NULL,
                  Win.WS_CLIPCHILDREN + Win.WS_CHILD,
                  rf.left, rf.top, rf.right, rf.bottom,
                  hWnd, Win.NULL, hInst, Sys.ADR(ccs));
    IF hWndClient = 0 THEN
      RETURN 1;
    END;
    dummy := Win.ShowWindow(hWndClient, Win.SW_SHOW);
  
  ELSIF message = Win.WM_CLOSE THEN
    IF (Fra.IsFracCalcActive()) THEN
      T.StopMessageBox("STOP!", "Berechnung läuft - Schließen nicht möglich");
    ELSE
      T.ExitBox(hWnd);  (* Bestaetigung, ob Anwendung geschlossen werden soll *)
    END;
  ELSIF message = Win.WM_DESTROY THEN
    Win.PostQuitMessage(0);

  ELSIF message = Win.WM_COMMAND THEN
    IF wParam = IDM_NEW THEN
      Fra.InitParam(realData);
      Fra.InitChildSize(cr);
      FracParamDlg(hWndClient);
      IF (~cancel) THEN
        T.GetTitleOfWindow(nrOfNewChild, titleStr); (* Titelzeile eruieren *)
        hWndChild := CreateChildWindow(titleStr, hInst, hWndClient);
        T.SetNrOfWindow(hWndChild, nrOfNewChild);
        Fra.SetFracParam(hWndChild, realData, TRUE); (* Parameter abspeichern *)
        Fra.SetStatus(hWndChild, Glo.DEMANDCALC); 
        T.SetStatMinimized(hWndChild, Glo.NOTMINIMIZED);
        INC (nrOfNewChild);
      END;
      
    ELSIF wParam = IDM_EXIT THEN
      IF (Fra.IsFracCalcActive()) THEN
        T.StopMessageBox("STOP!", 
        "Berechnung läuft - Schließen nicht möglich");
      ELSE
        T.ExitBox(hWnd);  (* Bestaetigung, ob Anwendung geschlossen werden soll *)
      END;

    ELSIF wParam = IDM_TILE_H THEN
      dummy := Win.SendMessage(hWndClient, Win.WM_MDITILE, 
                               Win.MDITILE_HORIZONTAL, 0);

    ELSIF wParam = IDM_TILE_V THEN
      dummy := Win.SendMessage(hWndClient, Win.WM_MDITILE, 
                               Win.MDITILE_VERTICAL, 0);

    ELSIF wParam = IDM_CASCADE THEN
      dummy := Win.SendMessage(hWndClient, Win.WM_MDICASCADE, 0, 0);

    ELSIF (wParam = IDM_ABOUT) THEN
      DlgAbout(hWndClient);

    ELSIF (wParam = IDM_HELP) THEN
      IF (Win.WinHelp (hWndClient, Sys.ADR ("MINIFRAC.HLP"), 
          Win.HELP_FORCEFILE, 0) = 0) THEN
            T.InfoMessageBox ("Minifrac Hilfe", "Sorry, Hilfe nicht verfügbar.");
      END;

    ELSIF (wParam = IDM_PARAMETER) THEN
      IF (nrOfChilds = 0) THEN  (* Bezug auf Childwindow vorhanden? *)
        T.StopMessageBox("STOP", 
          "Es muß zuerst ein Fraktalfenster angefordert werden -> Verwenden Sie hierzu den Menüpunkt: Fraktale/Neues Fenster");
      ELSE  
        hWndChildLast := Win.GetFocus();  (*  Handle retten *)
        Win.GetClientRect(hWndChildLast, Sys.ADR(cr)); 
        Fra.GetFracParam(hWndChildLast, realData);
        FracParamDlg(hWndClient);
        IF (~cancel) THEN
          Fra.SetFracParam(hWndChildLast, realData, 
                           FALSE); (* Parameter abspeichern *)
          Fra.SetStatus(hWndChildLast, Glo.DEMANDCALC); (* *** *)
          Win.InvalidateRect (hWndChildLast, Win.NULL, Win.true);  
        END;
      END;

    ELSIF (wParam = IDM_STOPALL) THEN
      StopAllFracCalc();         (* alle Fraktalberechnungen abbrechen *)
    
    ELSE
      RETURN Win.DefFrameProc(hWnd, hWndClient, message, wParam, lParam);    
    END;
    
  ELSE
    RETURN Win.DefFrameProc(hWnd, hWndClient, message, wParam, lParam);    
  END;
  
  RETURN 0;
END MDIFrameWndProc;


(* ***** *)


(*
 * Window Prozedur fuer Child Windows 
 *)
PROCEDURE [WINDOWS] MDIChildWndProc*(hWnd    : Win.HWND;
                                     message : Win.WORD;
                                     wParam  : Win.WORD;
                                     lParam  : LONGINT) : LONGINT;
VAR
  hdc    : Win.HDC;
  ps     : Win.PAINTSTRUCT;
  hdcmem : Win.HDC;
  rc     : INTEGER;
  dummy  : LONGINT; 
  pMmi   : Glo.PMmi;
  
BEGIN
  IF message = Win.WM_CREATE THEN
     (* Bitmap fuer Fensterupdate *)
     Bitm.CreateBitmap(hWnd);
     Fra.InitNoOfCalculations(hWnd); 
     INC (nrOfChilds);
     IF (nrOfChilds = 1) THEN
       dummy := Win.SetFocus(hWnd);
     END;
  
  ELSIF (message = Win.WM_PAINT) THEN
    IF (Fra.GetStatus(hWnd) = Glo.DEMANDCALC) THEN   (* Neuberechnung anstossen *)
      T.SetTitleOfWindowToCalc(hWnd);
      
      Fra.GetFracParam(hWnd, realData); (* Parameter fuer Berechnung holen *)
      Fra.IncNoOfCalculations(hWnd);
      hdc := Win.BeginPaint(hWnd, Sys.ADR(ps));                    
      Fra.PaintSet(hdc, hWnd);
      Win.EndPaint(hWnd, Sys.ADR(ps));      
      Fra.DecNoOfCalculations(hWnd);
      IF (Fra.GetNoOfCalculations(hWnd) > 0) THEN
        Fra.SetStatus(hWnd, Glo.BREAK);
      ELSE  
        Fra.SetStatus(hWnd, Glo.READY);
        T.SetTitleOfWindowToReady(hWnd);
    END;
    ELSE (* Bitmap auf Fenster kopieren *)
      Win.GetWindowRect(hWnd, Sys.ADR(cr));
      hdc := Win.BeginPaint(hWnd, Sys.ADR(ps));
      hdcmem := Sys.VAL(Win.HDC, Win.GetWindowLong(hWnd, 0));
      dummy := Win.BitBlt(hdc, 0, 0, cr.right, cr.bottom, hdcmem, 0, 0, 
                          Win.SRCCOPY);
      Win.EndPaint(hWnd, Sys.ADR(ps));        
    END;
    
  ELSIF (message = Win.WM_SIZE) THEN
    IF (wParam = Win.SIZE_MINIMIZED) THEN
      T.SetStatMinimized(hWnd, Glo.MINIMIZED);
    ELSIF (wParam = Win.SIZE_RESTORED) THEN
      IF (T.IsMinimized(hWnd) = Glo.MINIMIZED) THEN  
        T.SetStatMinimized(hWnd, Glo.NOTMINIMIZED);
      ELSE  (* Fenster war nicht minimiert *)
        T.SetStatMinimized(hWnd, Glo.NOTMINIMIZED);
        (* alte Bitmap entfernen *)
        Bitm.KillBitmap(hWnd);
        (* Bitmap neu anlegen *)
        Bitm.CreateBitmap(hWnd);
        Fra.SetStatus(hWnd, Glo.DEMANDCALC); (* Neuberechnung anstossen *)
        Win.InvalidateRect (hWnd, Win.NULL, Win.true); (* Bitmap anzeigen *)
      END;
    ELSE (* Fenster war maximiert *)
      T.SetStatMinimized(hWnd, Glo.NOTMINIMIZED);
      (* alte Bitmap entfernen *)
      Bitm.KillBitmap(hWnd);
      (* Bitmap neu anlegen *)
      Bitm.CreateBitmap(hWnd);
      Fra.SetStatus(hWnd, Glo.DEMANDCALC); (* Neuberechnung anstossen *)
      Win.InvalidateRect (hWnd, Win.NULL, Win.true); (* Bitmap anzeigen *)
    END;
  
  ELSIF (message = Win.WM_RBUTTONDOWN) THEN
    IF (Fra.GetStatus(hWnd) = Glo.READY) THEN
      Z.ZoomStart(hWnd, lParam); (* setze Anfangskoordinaten fuer Zoomfenster *)
    END;
    
  ELSIF (message = Win.WM_RBUTTONUP) THEN
    IF (Fra.GetStatus(hWnd) = Glo.READY) THEN
      IF (Z.ZoomEnd(hWnd)) THEN  (* Zoomvorgang beendet und gueltig *)
        Fra.SetStatus(hWnd, Glo.DEMANDCALC);  (* Neuberechnung des Fraktals anstossen *)
        Win.InvalidateRect (hWnd, Win.NULL, Win.true);  
      END;
    END;
    
  ELSIF (message = Win.WM_MOUSEMOVE) THEN
    Z.DrawZoomRect(hWnd, lParam);  (* Zoomfenster zeichnen *)

  ELSIF (message = Win.WM_GETMINMAXINFO) THEN  (* Bug ausbessern *)
    pMmi := Sys.VAL(Glo.PMmi, lParam);
    pMmi.ptMaxSize.x := pMmi.ptMaxSize.x - 1;
    pMmi.ptMaxSize.y := pMmi.ptMaxSize.y - 1;

  ELSIF (message = Win.WM_DESTROY) THEN  
    Bitm.KillBitmap(hWnd);
    DEC (nrOfChilds);
    Fra.CleanParam(hWnd); (* Speicherbereinigung *)
  
  ELSIF ((message = Win.WM_CLOSE) & (Fra.GetStatus(hWnd) # Glo.READY)) THEN
    T.StopMessageBox("STOP!", "Nein, nicht während der Berechnung!");
  ELSE
    RETURN Win.DefMDIChildProc(hWnd, message, wParam, lParam);
  END;
  RETURN 0;
END MDIChildWndProc; 
 

(* ***** *)


(*
 * InitApplication
 *)
PROCEDURE InitApplication (hInstCurr: Win.HINSTANCE): BOOLEAN;
VAR
  wc : Win.WNDCLASS;
  wp : Glo.WNDPROC;
BEGIN
  (* registriere MDI Frame Window Klasse *)
  wp := MDIFrameWndProc;
  wc.style         := Win.NULL;
  wc.lpfnWndProc   := MDIFrameWndProc(*Sys.VAL(Win.FARPROC, wp)*);
  wc.cbClsExtra    := 0;
  wc.cbWndExtra    := 0;
  wc.hInstance     := hInstCurr;
  wc.hIcon         := Win.LoadIcon (hInst, Sys.ADR("MinifracIcon"));
  wc.hCursor       := Win.LoadCursor (Win.NULL, Win.IDC_ARROW);
  wc.hbrBackground := Win.GetStockObject(Win.WHITE_BRUSH);
  wc.lpszMenuName  := Sys.ADR("MainMenu");
  wc.lpszClassName := Sys.ADR (MDIFrameClass);
  IF Win.RegisterClass(Sys.ADR(wc)) = 0 THEN
    T.DisplayError("Kann Frame Window Class nicht anlegen!");
    RETURN FALSE;
  END;
  
  (* registriere MDI Child Window Klasse *)
  wp := MDIChildWndProc;
  wc.style         := Win.CS_DBLCLKS;
  wc.lpfnWndProc   := MDIChildWndProc (*Sys.VAL(Win.FARPROC, wp)*);
  wc.cbClsExtra    := 0;
  wc.cbWndExtra    := 28; (* diverse notwendige Info *)
  wc.hInstance     := hInstCurr;
  wc.hIcon         := Win.LoadIcon (hInst, Sys.ADR("MinifracIcon"));
  wc.hCursor       := Win.LoadCursor (Win.NULL, Win.IDC_ARROW);
  wc.hbrBackground := Win.GetStockObject(Win.WHITE_BRUSH);
  wc.lpszMenuName  := Sys.ADR("ChildMenu");
  wc.lpszClassName := Sys.ADR (MDIChildClass);

  IF Win.RegisterClass(Sys.ADR(wc)) = 0 THEN
    T.DisplayError("Kann Child Window Class nicht anlegen!");
    RETURN FALSE;
  END;
  
  RETURN TRUE;
END InitApplication;


(* ***** *)


(*
 * InitInstance 
 *)
PROCEDURE InitInstance (hInstCurr : Win.HINSTANCE;
                        nCmdShow  : INTEGER): BOOLEAN;
VAR
  dummy : LONGINT;
BEGIN
  (* erzeuge Frame Window *)
  hWnd := Win.CreateWindow(
          Sys.ADR(MDIFrameClass), Sys.ADR("Minifrac"),
          Win.WS_OVERLAPPEDWINDOW + Win.WS_MAXIMIZE,
          Win.CW_USEDEFAULT, Win.CW_USEDEFAULT,
          Win.CW_USEDEFAULT, Win.CW_USEDEFAULT,
          Win.NULL, Win.NULL,
          hInstCurr, Win.NULL);
  IF hWnd = 0 THEN
    T.DisplayError("Kann Hauptfenster nicht anlegen!");
    RETURN FALSE;
  END;
  
  dummy := Win.ShowWindow(hWnd, nCmdShow);

  RETURN TRUE;
END InitInstance;



(* ***** *)

 
(*
 * Eintrittspunkt Winmain
 *)
PROCEDURE [WINDOWS] WinMain*(hInstCurr : Win.HANDLE;
                             hInstPrev : Win.HANDLE;
                             lpCmdLine : Win.LPSTR; 
                             nCmdShow  : INTEGER): INTEGER;
VAR
  dummy : LONGINT;
  msg   : Win.MSG;
BEGIN
  (* Handle sichern *)
  hInst := hInstCurr;
  
  (* initialisiere erste Instanz *)
  IF (hInstPrev = Win.NULL) & ~InitApplication(hInstCurr) THEN
    T.DisplayError("Globale Inizialisation funktioniert nicht!");
    RETURN Win.false;
  END;

  (* initialisiere aktuelle Instanz *)
  IF ~InitInstance(hInstCurr, nCmdShow) THEN
    RETURN Win.false;
  END;
  
  (* Message Loop *)
  WHILE Win.GetMessage (Sys.ADR(msg), Win.NULL, Win.NULL, Win.NULL)#0 DO
    IF Win.TranslateMDISysAccel(hWndClient, Sys.ADR(msg))=0 THEN
      dummy:=Win.TranslateMessage (Sys.ADR(msg));
      dummy:=Win.DispatchMessage (Sys.ADR(msg));
    END;
  END;

  RETURN msg.wParam;
END WinMain;


(* ***** *)


(*
 * Modulinitialisierung 
 *)
BEGIN
  Fra.InitParam(realData);  (* Parameter im Fraktal-Eingabedialog festlegen *)
  Fra.InitChildSize(cr);    (* Anfangsgroesse eines Childwindows festlegen *)
  nrOfChilds := 0;          (* Anzahl existierender Child-Fraktalwindows *)
  nrOfNewChild := 1;        (* Nummer fuer neues Childwindow *)
  cancel := FALSE;          (* Parameteraenderungen akzeptieren *) 
  MakeCallbackProc(StopFracCalc, lpProc);       (* Adresse bestimmen *)
END Minifrac.
