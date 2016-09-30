(**************************************************************************)
(*                                                                        *)
(*  Fallstudien Betriebssysteme: Windowsprogrammierung mit Oberon-2       *)
(*  Abschlußprojekt:    Black Jack                                        *)
(*  Aufgabe:            Kartenspiel unter Verwendung von cardList.DLL     *)
(*                                                                        *)
(*  Modulname:          BJ.MOD                                            *)
(*  Aufgabe:            Hauptprogramm                                     *)
(*                                                                        *)
(*  Autoren:            Gschnell Christian, 9155609, 880                  *)
(*                      Jungwirth Josef,    9155355, 880                  *)
(*                      Köttstorfer Marco,  9155255, 880                  *)
(*                                                                        *)
(*  Erstellt am:        02.05.1995                                        *)
(*  Änderungen:         12.03.1997 - Änderungen an windows callback       *)
(*                                   functions                            *)
(*                                                                        *)
(*                                                                        *)
(**************************************************************************)
MODULE Bj;

IMPORT
  W := Windows, SYSTEM, WU := WinUtils, Utils, Strings,
  G := General, C := Cards, P := Players, D := Dialogs,
  Ctl3D, I := Ini, S := Sound;

CONST
  IDM_ABOUT = 400;
  IDM_START = 100;
  IDM_PLAYER1 = 201;
  IDM_PLAYER7 = 207;
  IDM_NAMES = 208;
  IDM_SOUND = 209;

  txt1 = "Menu";
  txt2 = "GenericWClass";
  txt3 = "AboutBox";
  txt4 = "Black Jack";
  txt5 = "Bet";
  txt6 = "Choice";
  WaitTime = 1000;
  AboutName = "About.exe";


TYPE PBJWindow = POINTER TO TBJWindow;
     TBJWindow = RECORD(G.TWindow)
       hInst     : W.HANDLE;
       cDLL      : W.HANDLE;
       table     : P.PTable;
       font      : W.HFONT;
       closeAble : BOOLEAN;
     END;

VAR
  hWindow : PBJWindow;
  hInst   : W.HANDLE;

(***********************************************************************************)

PROCEDURE KeepWindowsAlive();
  VAR  message: W.MSG;
       r:       LONGINT;
  BEGIN
    WHILE W.PeekMessage(SYSTEM.ADR(message), 0, 0, 0, W.PM_REMOVE) # 0 DO
      r := W.TranslateMessage(SYSTEM.ADR(message));
      r := W.DispatchMessage(SYSTEM.ADR(message));
    END;
  END KeepWindowsAlive;

(***********************************************************************************)

PROCEDURE InitBJWindow(w : PBJWindow; aInst : W.HANDLE; aWnd : W.HWND);
BEGIN
  G.InitWindow(w, aWnd);
  w.hInst := aInst;
  w.closeAble := TRUE;
END InitBJWindow;

(***********************************************************************************)

PROCEDURE (VAR w : TBJWindow) WMCreate*() : LONGINT;
VAR ret : LONGINT;
    i : INTEGER;
    ok : BOOLEAN;
BEGIN
  ret := w.WMCreate^();

  I.ReadIni(w.wnd);
  w.cDLL := W.LoadLibrary(SYSTEM.ADR(I.CardDLL));
  IF (w.cDLL < 32) THEN
    I.WriteIni(w.wnd);
    ASSERT(w.cDLL>=32);
  END;
  C.LoadCards(w.cDLL);

  NEW(w.table); P.InitTable(w.table, w.wnd,I.noOfPlayers, C.cardList.invisibleShape, I.minBet, I.maxBet);

  ASSERT(W.CheckMenuItem(W.GetMenu(w.wnd),IDM_PLAYER1+w.table.noOfPlayers-1, W.MF_CHECKED) >= 0);
  w.font := W.CreateFont(-15, 0, 0, 0, W.FW_BOLD, 0, 0, 0, W.ANSI_CHARSET,
                         W.OUT_DEFAULT_PRECIS, W.CLIP_DEFAULT_PRECIS, W.DEFAULT_QUALITY,
                         W.VARIABLE_PITCH + W.FF_ROMAN, SYSTEM.ADR("Times New Roman"));
  IF (I.SoundOn) THEN
    ASSERT(W.CheckMenuItem(W.GetMenu(w.wnd),IDM_SOUND, W.MF_CHECKED) >= 0);
  ELSE
    ASSERT(W.CheckMenuItem(W.GetMenu(w.wnd),IDM_SOUND, W.MF_UNCHECKED) >= 0);
  END;

  RETURN ret;
END WMCreate;

(***********************************************************************************)

PROCEDURE (VAR w : TBJWindow) WMDestroy*() : LONGINT;
VAR i : INTEGER;
BEGIN
  I.WriteIni(w.wnd);
  S.PlaySound(1);
  w.table.Destroy(); DISPOSE(w.table);
  i := W.DeleteObject(w.font);
  C.DeleteCards();
  W.FreeLibrary(w.cDLL);
  RETURN w.WMDestroy^();
END WMDestroy;

(***********************************************************************************)

PROCEDURE (VAR w: TBJWindow) Draw3DRect(dc: W.HDC; aX1, aY1, aX2, aY2 : INTEGER;
                      aFillColor, aTopColor, aBottomColor : LONGINT;
                      aThickDraw : BOOLEAN);
  VAR  rect     : G.P3DRect;
  BEGIN
    NEW(rect); G.Init3DRect(rect, aX1, aY1, aX2, aY2, aFillColor, aTopColor, aBottomColor, aThickDraw);
    rect.Draw(dc);
    rect.Destroy(); DISPOSE(rect);
  END Draw3DRect;

(***********************************************************************************)

PROCEDURE (VAR w: TBJWindow) WriteLine(dc: W.HDC; txt: ARRAY OF CHAR; line, col: INTEGER;
                                       format: W.WORD);
  VAR  r       : W.RECT;
       brush   : W.HBRUSH;
       dummy   : LONGINT;
       oldFont : W.HFONT;
  BEGIN
    CASE col OF
        1 : r.left := 20; r.right := 220;
      | 2 : r.left := 230; r.right := 310;
      | 3 : r.left := 320; r.right := 400;
      | 4 : r.left := 410; r.right := 490;
      | 5 : r.left := 500; r.right := 580;
    END;

    r.top := line * 25 + 150;
    IF (line > 0) THEN
      r.top := r.top + 10;
    END;
    r.bottom := r.top + 20;

    brush := W.CreateSolidBrush(WU.RGB(0, 128, 0));
    dummy := W.FillRect(dc, SYSTEM.ADR(r), brush);
    dummy := W.DeleteObject(brush);

    dummy := W.SetBkMode(dc, W.TRANSPARENT);
    IF line = 0 THEN
      dummy := W.SetTextColor(dc, WU.RGB(255, 0, 0))
    ELSE
      IF w.table.playerList[line-1].HasEnoughMoney() THEN
        dummy := W.SetTextColor(dc, WU.RGB(255, 255, 255))
      ELSE
        dummy := W.SetTextColor(dc, WU.RGB(0, 0, 0))
      END;
    END;
    oldFont := W.SelectObject(dc, w.font);
    dummy := W.DrawText(dc, SYSTEM.ADR(txt), -1, SYSTEM.ADR(r), W.DT_SINGLELINE + W.DT_VCENTER + format);
    oldFont := W.SelectObject(dc, oldFont);
  END WriteLine;

(***********************************************************************************)

PROCEDURE (VAR w: TBJWindow) DrawPlayerInfo(aDC: W.HDC; aPlayer: INTEGER);
  VAR  dc       : W.HDC;
       zStr     : ARRAY 20 OF CHAR;

  BEGIN
    IF aDC = 0 THEN dc := w.GetDC() ELSE dc := aDC END;

    w.WriteLine(dc, w.table.playerList[aPlayer-1].name, aPlayer, 1, W.DT_LEFT);
    IF w.table.playerList[aPlayer-1].HasEnoughMoney() THEN
      Strings.Str(w.table.playerList[aPlayer-1].GetBet(), zStr);
    ELSE
      G.StringCopy(zStr, "-");
    END;
    w.WriteLine(dc, zStr, aPlayer, 2, W.DT_CENTER);

    IF w.table.playerList[aPlayer-1].HasEnoughMoney() THEN
      w.table.playerList[aPlayer-1].GetHandsString(zStr);
    ELSE
      G.StringCopy(zStr, "-");
    END;
    w.WriteLine(dc, zStr, aPlayer, 3, W.DT_CENTER);

    IF w.table.playerList[aPlayer-1].HasEnoughMoney() THEN
      Strings.Str(w.table.playerList[aPlayer-1].lastProfit, zStr);
    ELSE
      G.StringCopy(zStr, "-");
    END;
    w.WriteLine(dc, zStr, aPlayer, 4, W.DT_CENTER);

    Strings.Str(w.table.playerList[aPlayer-1].credit, zStr);
    w.WriteLine(dc, zStr, aPlayer, 5, W.DT_CENTER);

    IF aDC = 0 THEN ASSERT(w.ReleaseDC(dc)=1); END;
  END DrawPlayerInfo;

(***********************************************************************************)

PROCEDURE (VAR w: TBJWindow) DrawCardWindow(aDC: W.HDC);
  VAR  dc       : W.HDC;
       rect     : G.P3DRect;

  BEGIN
    IF aDC = 0 THEN dc := w.GetDC() ELSE dc := aDC END;
    w.Draw3DRect(dc, 10, 10, 250, 130, WU.RGB(0, 0, 128),
                 WU.RGB(128, 128, 128), WU.RGB(255, 255, 255), TRUE);

    w.table.croupier.hand.DrawOffs(dc, 20, 20);
    IF aDC = 0 THEN ASSERT(w.ReleaseDC(dc)=1); END;
  END DrawCardWindow;

(***********************************************************************************)

PROCEDURE (VAR w: TBJWindow) DrawPlayerStatus(aDC: W.HDC);
  VAR  dc       : W.HDC;
       rect     : G.P3DRect;
       i        : INTEGER;
       pen,
       oldPen   : W.HPEN;
       dummy    : W.DWORD;

  BEGIN
    IF aDC = 0 THEN dc := w.GetDC() ELSE dc := aDC END;

    w.Draw3DRect(dc, 10, 140, 590, 370, WU.RGB(0, 128, 0),
                 WU.RGB(128, 128, 128), WU.RGB(255, 255, 255), TRUE);

    w.WriteLine(dc, "Spieler", 0, 1, W.DT_LEFT);
    w.WriteLine(dc, "Einsatz", 0, 2, W.DT_CENTER);
    w.WriteLine(dc, "Blatt", 0, 3, W.DT_CENTER);
    w.WriteLine(dc, "Gewinn", 0, 4, W.DT_CENTER);
    w.WriteLine(dc, "Stand", 0, 5, W.DT_CENTER);

    FOR i := 1 TO w.table.noOfPlayers DO
      w.DrawPlayerInfo(dc, i);
    END;

    pen := W.CreatePen(W.PS_SOLID, 2, WU.RGB(192, 192, 192));
    oldPen := W.SelectObject(dc, pen);
    dummy := W.MoveTo(dc, 20, 177);
    dummy := W.LineTo(dc, 580, 177);
    oldPen := W.SelectObject(dc, oldPen);
    i := W.DeleteObject(oldPen);

    IF aDC = 0 THEN ASSERT(w.ReleaseDC(dc)=1); END;
  END DrawPlayerStatus;

(***********************************************************************************)

PROCEDURE (VAR w : TBJWindow) WMPaint*() : LONGINT;
VAR ps        : W.PAINTSTRUCT;
    r         : W.RECT;
    dc        : W.HDC;
    i         : INTEGER;
    dummy     : LONGINT;
BEGIN
  dc := W.BeginPaint(w.wnd, SYSTEM.ADR(ps));
  W.GetClientRect(w.wnd, SYSTEM.ADR(r));
  dummy := W.FillRect(dc, SYSTEM.ADR(r), W.GetStockObject(W.LTGRAY_BRUSH));

  w.DrawCardWindow(dc);
  w.DrawPlayerStatus(dc);
  W.EndPaint(w.wnd, SYSTEM.ADR(ps));

  RETURN 0;
END WMPaint;

(***********************************************************************************)

PROCEDURE (VAR w : TBJWindow) WMLButtonUp*() : LONGINT;
BEGIN
  RETURN w.DefWindowProc();
END WMLButtonUp;

(***********************************************************************************)

PROCEDURE (VAR w : TBJWindow) WMCommand*() : LONGINT;
VAR ok    : BOOLEAN;
    i     : SHORTINT;
    until : W.DWORD;
    dummy : W.WORD;
    AboutExe : ARRAY 255 OF CHAR;
    
BEGIN
  IF w.wParam = IDM_ABOUT THEN
(*    G.StringCopy(AboutExe,I.path);
    Strings.Append(AboutExe,AboutName);
    dummy := W.WinExec(SYSTEM.ADR(AboutExe),W.SW_NORMAL); *)
    D.ExecuteAboutDlg(w.hInst, w.wnd);
  ELSIF ((w.wParam >= IDM_PLAYER1) & ( w.wParam <= IDM_PLAYER7)) THEN
    ASSERT(W.CheckMenuItem(W.GetMenu(w.wnd),IDM_PLAYER1+w.table.noOfPlayers-1, W.MF_UNCHECKED) >= 0);
    w.table.SetNoOfPlayers(SHORT(w.wParam-IDM_PLAYER1+1));
    ASSERT(W.CheckMenuItem(W.GetMenu(w.wnd),IDM_PLAYER1+w.table.noOfPlayers-1, W.MF_CHECKED) >= 0);
    I.noOfPlayers := w.table.noOfPlayers;
    w.DrawPlayerStatus(0);
  ELSIF w.wParam = IDM_SOUND THEN
    I.SoundOn := ~I.SoundOn;
    IF (I.SoundOn) THEN
      ASSERT(W.CheckMenuItem(W.GetMenu(w.wnd),IDM_SOUND, W.MF_CHECKED) >= 0);
    ELSE
      ASSERT(W.CheckMenuItem(W.GetMenu(w.wnd),IDM_SOUND, W.MF_UNCHECKED) >= 0);
    END;
  ELSIF w.wParam = IDM_START THEN
    w.closeAble := FALSE;

    (* Keinen weiteren Aufruf während des Spieles zulassen *)
    dummy := W.EnableMenuItem(W.GetMenu(w.wnd), IDM_START, W.MF_GRAYED);
    W.DrawMenuBar(w.wnd);

    FOR i := 0 TO w.table.noOfPlayers-1 DO          (* Spieler initialsieren   *)
      w.table.playerList[i].Reset();
    END;
    w.table.croupier.Reset();                       (* Groupier initialisieren *)

    w.table.stack.Shuffle();
    w.DrawCardWindow(0);

    FOR i := 0 TO w.table.noOfPlayers-1 DO
      IF w.table.playerList[i].HasEnoughMoney() THEN
        D.ExecuteBetDlg(w.hInst, w.wnd, w.table.playerList[i]);
        w.DrawPlayerInfo(0, i+1);
      END;
    END;

    FOR i := 0 TO w.table.noOfPlayers-1 DO
      IF w.table.playerList[i].HasEnoughMoney() THEN
        w.table.playerList[i].hand[0].Insert(w.table.croupier.GiveCard());
      END;
      w.DrawPlayerInfo(0, i+1);
    END;

    w.table.croupier.hand.Insert(w.table.croupier.GiveCard());
    w.DrawCardWindow(0);

    FOR i := 0 TO w.table.noOfPlayers-1 DO
      IF w.table.playerList[i].HasEnoughMoney() THEN
        w.table.playerList[i].hand[0].Insert(w.table.croupier.GiveCard());
        w.DrawPlayerInfo(0, i+1);
      END;
    END;

    D.gPlay := FALSE;
    FOR i := 0 TO w.table.noOfPlayers-1 DO
      IF w.table.playerList[i].HasEnoughMoney() THEN
        D.ExecutePlayerDlg(w.hInst, w.wnd, w.table.playerList[i]);
        w.DrawPlayerInfo(0, i+1);
      END;
    END;

    (* Wenn sich alle Spieler abgebrannt sind, braucht der Groupier seine *)
    (* Kartenkünste nicht mehr zeigen. Er kann den Zasta gleich eincashen *)
    IF D.gPlay THEN
      WHILE (w.table.croupier.hand.GetBestCardSum() <= 16) DO
        S.PlaySound(w.table.croupier.hand.GetBestCardSum());
        until := W.GetTickCount() + WaitTime;
        WHILE (W.GetTickCount() < until) DO
          KeepWindowsAlive();
        END;
        w.table.croupier.hand.Insert(w.table.croupier.GiveCard());
        w.DrawCardWindow(0);
      END;
      IF (w.table.croupier.HasBlackJack()) THEN
        S.PlaySound(-1);
      ELSE
        S.PlaySound(w.table.croupier.hand.GetBestCardSum());
      END;
    END;

    FOR i := 0 TO w.table.noOfPlayers-1 DO
      IF w.table.playerList[i].HasEnoughMoney() THEN
        w.table.playerList[i].ExecPayOut();
      END;
    END;

    w.DrawPlayerStatus(0);

    dummy := W.EnableMenuItem(W.GetMenu(w.wnd), IDM_START, W.MF_BYCOMMAND);
    W.DrawMenuBar(w.wnd);

    w.closeAble := TRUE;

  ELSIF (w.wParam = IDM_NAMES) THEN
    D.ExecuteNameDlg(w.hInst, w.wnd, w.table);
    w.DrawPlayerStatus(0);
  ELSE
    RETURN w.WMCommand^();
  END;
  RETURN 0;
END WMCommand;

(***********************************************************************************)

PROCEDURE (VAR w : TBJWindow) MainWndProc*() : LONGINT;
BEGIN
  IF    (w.message = W.WM_LBUTTONUP) THEN RETURN w.WMLButtonUp();
  ELSIF (w.message = W.WM_COMMAND)   THEN RETURN w.WMCommand();
  ELSIF ((w.message = W.WM_CLOSE) & ~w.closeAble) THEN
    W.MessageBeep(0);
    RETURN 0;
  ELSE
    RETURN w.MainWndProc^();
  END;
END MainWndProc;

(***********************************************************************************)

PROCEDURE [WINDOWS] MainWndProc*(hWnd: W.HWND;   (* window handle             *)
                                 message: W.WORD;(* type of message           *)
                                 wParam: W.WORD; (* additional information    *)
                                 lParam: LONGINT (* additional information    *)
                                ): LONGINT;
VAR ret : LONGINT;
BEGIN
  IF (hWindow # NIL) THEN hWindow.SetParams(message, wParam, lParam) END;

  IF message = W.WM_CREATE THEN
    ASSERT(hWindow = NIL);
    NEW(hWindow); InitBJWindow(hWindow, hInst, hWnd);
    hWindow.SetParams(message, wParam, lParam);
    RETURN hWindow.WMCreate();

  ELSIF (hWindow = NIL) OR (message = W.WM_QUIT) THEN
    RETURN W.DefWindowProc(hWnd, message, wParam, lParam);
  ELSE
    ret := hWindow.MainWndProc();
    IF (message = W.WM_DESTROY) THEN
      DISPOSE(hWindow); hWindow := NIL;
      W.PostQuitMessage(0);
      RETURN ret;
    END;
    RETURN ret;
  END;
  RETURN 0;
END MainWndProc;

(***********************************************************************************)

PROCEDURE InitApplication(hInstance: W.HANDLE): BOOLEAN;
  VAR wc: W.WNDCLASS;
BEGIN                                     (* Fill in window class structure   *)
                                          (* with parameters that describe    *)
                                          (* the main window.                 *)
  wc.style := W.NULL;                     (* Class style(s).                  *)
  wc.lpfnWndProc := MainWndProc;          (* Function to retrieve messages for*)
                                          (* windows of this class.           *)
  wc.cbClsExtra := 0;                     (* No per-class extra data.         *)
  wc.cbWndExtra := 0;                     (* No per-window extra data.        *)
  wc.hInstance := hInstance;              (* Application that owns the class. *)
  wc.hIcon := W.LoadIcon(hInstance, SYSTEM.ADR("ICON"));
  wc.hCursor := W.LoadCursor(W.NULL, W.IDC_ARROW);
  wc.hbrBackground := W.GetStockObject(W.WHITE_BRUSH);
  wc.lpszMenuName := SYSTEM.ADR(txt1);    (* Name of menu resource in .RC file*)
  wc.lpszClassName := SYSTEM.ADR(txt2);   (* Name used in call to CreateWindow*)
                                          (* Register the window class and    *)
                                          (*  return success/failure code.    *)
  RETURN W.RegisterClass(SYSTEM.ADR(wc)) # 0
END InitApplication;

(***********************************************************************************)

PROCEDURE InitInstance(hInstance:W.HANDLE;(* Current instance identifier.     *)
                       nCmdShow: INTEGER  (* Param for first ShowWindow() call*)
                      ): BOOLEAN;

  VAR r: INTEGER; hWnd: W.HWND;           (* Main window handle.              *)
BEGIN                                     (* Save the instance handle in      *)
                                          (* static variable, which will be   *)
                                          (* used in many subsequence calls   *)
                                          (* from this application to Windows.*)
  hWindow := NIL;
  hInst := hInstance;
                                          (* Create a main window for this    *)
                                          (*  application instance.           *)
  hWnd := W.CreateWindow(SYSTEM.ADR(txt2),(* See RegisterClass() call.        *)
                         SYSTEM.ADR(txt4),(* Text for window title bar.       *)
                         W.WS_OVERLAPPEDWINDOW, (* Window style.              *)
                         10,              
                         10,              
                         620,             
                         440,             
                         W.NULL,          (* Overlapped windows have no parent*)
                         W.NULL,          (* Use the window class menu.       *)
                         hInstance,       (* This instance owns this window.  *)
                         W.NULL);         (* Pointer not needed.              *)

                                          (* If window could not be created,  *)
                                          (* return "failure"                 *)
  IF hWnd = 0 THEN RETURN FALSE END;
                                          (* Make the window visible; update  *)
                                          (* its client area; and return      *)
                                          (* "success"                        *)
  r := W.ShowWindow(hWnd, nCmdShow);      (* Show the window                  *)
  W.UpdateWindow(hWnd);                   (* Sends WM_PAINT message           *)
  RETURN TRUE
END InitInstance;

(***********************************************************************************)

PROCEDURE [WINDOWS] WinMain*(hInstance: W.HANDLE;    (* current instance      *)
                             hPrevInstance: W.HANDLE;(* previous instance     *)
                             lpCmdLine: W.LPSTR;     (* command line          *)
                             nCmdShow: INTEGER       (* show-window type      *)
                            ): INTEGER;              (*   (open/icon)         *)
  VAR r: LONGINT; msg: W.MSG;             (* message                          *)
      s: ARRAY 80 OF CHAR;
BEGIN
  IF hPrevInstance = 0 THEN               (* Other instances of app running?  *)
    IF ~InitApplication(hInstance) THEN   (* Initialize shared things         *)
      RETURN W.false;                     (* Exits if unable to initialize    *)
    END;
  END;

  ASSERT(Ctl3D.Ctl3DRegister(hInstance) # 0);
  ASSERT(Ctl3D.Ctl3DAutoSubclass(hInstance) # 0);

                                          (* Perform initializations that     *)
                                          (* apply to a specific instance     *)
  IF ~InitInstance(hInstance, nCmdShow) THEN RETURN W.false END;
                                          (* Acquire and dispatch messages    *)
                                          (* until a WM_QUIT message is       *)
                                          (* received.                        *)
                                          
  WHILE W.GetMessage(SYSTEM.ADR(msg),     (* message structure                *)
                     W.NULL,              (* handle of window receiving the ms*)
                     W.NULL,              (* lowest message to examine        *)
                     W.NULL) # 0 DO       (* highest message to examine       *)

    r := W.TranslateMessage(SYSTEM.ADR(msg)); (* Translates virtual key codes *)
    r := W.DispatchMessage(SYSTEM.ADR(msg))   (* Dispatches message to window *)
  END;
  
  ASSERT(Ctl3D.Ctl3DUnregister(hInstance) # 0);  
  RETURN msg.wParam
END WinMain;

BEGIN
END Bj.
