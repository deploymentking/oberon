(******************************************************************************
 * MODULE:        Editor
 * DESCRIPTION:   Demo for a small editor
 * LANGUAGE:      Oberon-2
 * COPYRIGHT BY:  Peter René Dietmüller, dietmueller@fim.uni-linz.ac.at (PDI)
 ******************************************************************************
 * DATE      AUTHOR  CHANGES
 * --------  ------  ----------------------------------------------------------
 * ??/??/??  PDI     Version 1
 * 97/03/11  PDI     minor changes for callback functions
 ******************************************************************************)
MODULE Editor;


  IMPORT CommDlg, EditWin, Error, Shell, SYSTEM, Windows;


  CONST
    MDIFrameClass = "MDI FRAME";
    WindowTitle   = "MDI Editor Sample";

    (* -- Menu ID -- *)
    IDM_FILENEW           = 20000;
    IDM_FILEOPEN          = 20001;
    IDM_FILESAVE          = 20002;
    IDM_FILESAVEAS        = 20003;
    IDM_FILECLOSE         = 20004;
    IDM_FILEPRINT         = 20005;
    IDM_FILEEXIT          = 20006;
    IDM_EDITCUT           = 20010;
    IDM_EDITCOPY          = 20011;
    IDM_EDITPASTE         = 20012;
    IDM_WINDOWTILEH       = 20020;
    IDM_WINDOWTILEV       = 20021;
    IDM_WINDOWCASCADE     = 20022;
    IDM_WINDOWICONARRANGE = 20023;


  VAR
    hInstance:  Windows.HANDLE;
    hWnd:       Windows.HWND;
    hWndBar:    Windows.HWND;
    hWndChild:  Windows.HWND;
    hWndClient: Windows.HWND;


PROCEDURE Replace(VAR str: ARRAY OF CHAR; search: CHAR; repl: CHAR);
  VAR i: INTEGER;
BEGIN
  FOR i := 0 TO LEN(str) - 1 DO 
    IF str[i] = search THEN str[i] := repl; END;
  END;
END Replace;


PROCEDURE FillWithZero(VAR a: ARRAY OF SYSTEM.BYTE);
  VAR i: INTEGER;
BEGIN
  FOR i := 0 TO LEN(a) - 1 DO a[i] := 0; END;
END FillWithZero;


PROCEDURE ProcessCommand(hWnd: Windows.HWND; id: INTEGER; lParam: LONGINT): LONGINT;

  VAR 
    file:     ARRAY 128 OF CHAR;
    filters:  ARRAY 60 OF CHAR;
    hWndEdit: Windows.HWND;
    ofn:      CommDlg.OPENFILENAME;
    pd:       CommDlg.PRINTDLG;
    r:        LONGINT;

BEGIN

  IF id = IDM_FILENEW THEN
    hWndEdit := EditWin.Create("New", hInstance, hWndClient);

  ELSIF id = IDM_FILEOPEN THEN

    file := "";
    filters := "Oberon-2$*.mod$Textdateien$*.txt;*.doc$Alle Dateien$*.*$$";
    Replace(filters, "$", 0X);

    FillWithZero(ofn);    
    ofn.lStructSize       := SIZE(CommDlg.OPENFILENAME);
    ofn.hwndOwner         := hWnd;
    ofn.hInstance         := Windows.NULL;
    ofn.lpstrFilter       := SYSTEM.ADR(filters);
(*    ofn.lpstrCustomFilter := SYSTEM.ADR(filters);*)
    ofn.nMaxCustFilter    := 100;
    ofn.nFilterIndex      := 1;
    ofn.lpstrFile         := SYSTEM.ADR(file);
    ofn.nMaxFile          := 200;
    ofn.Flags             := CommDlg.OFN_SHOWHELP + CommDlg.OFN_PATHMUSTEXIST + CommDlg.OFN_FILEMUSTEXIST;
    IF CommDlg.GetOpenFileName(SYSTEM.ADR(ofn)) > 0 THEN
      hWndEdit := EditWin.Create(file, hInstance, hWndClient);
      IF ~ EditWin.LoadFile(hWndEdit, file) THEN
        IF EditWin.Close(hWndEdit) THEN END;
      END;
    END;

  ELSIF id = IDM_FILECLOSE THEN
    hWndEdit := SHORT(Windows.SendMessage(hWndClient, Windows.WM_MDIGETACTIVE, 0, 0));
    IF hWndEdit # 0 THEN
      IF EditWin.Close(hWndEdit) THEN END;
    END;

  ELSIF id = IDM_FILEPRINT THEN
    hWndEdit := SHORT(Windows.SendMessage(hWndClient, Windows.WM_MDIGETACTIVE, 0, 0));
    IF hWndEdit # 0 THEN
      FillWithZero(pd);
      pd.lStructSize := SIZE(CommDlg.PRINTDLG);
      pd.hwndOwner   := hWnd;
      pd.Flags       := CommDlg.PD_RETURNDC;
      IF CommDlg.PrintDlg(SYSTEM.ADR(pd)) # 0 THEN
        IF EditWin.Print(hWndEdit, pd.hDC) THEN END;
      END;
    END;

  ELSIF id = IDM_FILEEXIT THEN
    r := Windows.DestroyWindow(hWnd);

  ELSIF id = IDM_EDITCUT THEN

  ELSIF id = IDM_EDITCOPY THEN
    hWndEdit := SHORT(Windows.SendMessage(hWndClient, Windows.WM_MDIGETACTIVE, 0, 0));
    IF hWndEdit # 0 THEN
      IF EditWin.Copy(hWndEdit) THEN END;
    END;

  ELSIF id = IDM_EDITPASTE THEN
  
  ELSIF id = IDM_WINDOWTILEH THEN
    r := Windows.SendMessage(hWndClient, Windows.WM_MDITILE, Windows.MDITILE_HORIZONTAL, 0);

  ELSIF id = IDM_WINDOWTILEV THEN
    r := Windows.SendMessage(hWndClient, Windows.WM_MDITILE, Windows.MDITILE_VERTICAL, 0);

  ELSIF id = IDM_WINDOWCASCADE THEN
    r := Windows.SendMessage(hWndClient, Windows.WM_MDICASCADE, 0, 0);

  ELSIF id = IDM_WINDOWICONARRANGE THEN
    r := Windows.SendMessage(hWndClient, Windows.WM_MDIICONARRANGE, 0, 0);

  ELSE
    RETURN Windows.DefFrameProc(hWnd, hWndClient, Windows.WM_COMMAND, id, lParam);

  END;
  RETURN 0;
  
END ProcessCommand;



PROCEDURE [WINDOWS] MDIFrameWndProc*(hWnd: Windows.HWND; message: Windows.WORD; wParam: Windows.WORD; lParam: LONGINT): LONGINT;

  VAR
    ccs:       Windows.CLIENTCREATESTRUCT;
    hDrop:     Shell.HDROP;
    hdc:       Windows.HDC;
    hMenu:     Windows.HMENU;
    hWndEdit:  Windows.HWND;
    ps:        Windows.PAINTSTRUCT;
    r:         LONGINT;
    wnd:       Windows.RECT;
    count:     INTEGER;
    i:         INTEGER;
    size:      INTEGER;
    fileName:  POINTER TO ARRAY OF CHAR;
    
BEGIN

  IF message = Windows.WM_CREATE THEN

    (* -- create client window -- *)
    hMenu := Windows.GetMenu(hWnd);
    IF hMenu = Windows.NULL THEN
    ELSE
      ccs.hWindowMenu  := Windows.GetSubMenu(hMenu, 2);
      ccs.idFirstChild := 30000;
      hWndClient := Windows.CreateWindow(SYSTEM.ADR("MDICLIENT"), Windows.NULL, 
                    Windows.WS_VISIBLE + Windows.WS_CLIPCHILDREN + Windows.WS_CHILD, 
                    0, 0, 0, 0, 
                    hWnd, Windows.NULL, hInstance, SYSTEM.ADR(ccs));
    END;

    Shell.DragAcceptFiles(hWnd, Windows.true);

  ELSIF message = Windows.WM_INITMENU THEN
    r := Windows.EnableMenuItem(Windows.GetMenu(hWnd), IDM_EDITCUT, Windows.MF_GRAYED);

  ELSIF message = Windows.WM_SIZE THEN
    Windows.GetClientRect(hWnd, SYSTEM.ADR(wnd));
    r := Windows.MoveWindow(hWndClient, wnd.left, wnd.top, wnd.right, wnd.bottom, Windows.true);

  ELSIF message = Windows.WM_DESTROY THEN
    Windows.PostQuitMessage(0);

  ELSIF message = Windows.WM_COMMAND THEN
    RETURN ProcessCommand(hWnd, wParam, lParam);

  ELSIF message = Windows.WM_DROPFILES THEN
    hDrop := wParam;
    count := Shell.DragQueryFile(hDrop, -1, Windows.NULL, 0);
    FOR i := 0 TO count - 1 DO
      size := Shell.DragQueryFile(hDrop, i, Windows.NULL, 0) + 1;
      NEW(fileName, size);
      IF fileName # NIL THEN
        r := Shell.DragQueryFile(hDrop, i, SYSTEM.ADR(fileName^), size);
        hWndEdit := EditWin.Create(fileName^, hInstance, hWndClient);
        IF ~EditWin.LoadFile(hWndEdit, fileName^) THEN
          IF EditWin.Close(hWndEdit) THEN END;
        END;
        DISPOSE(fileName);
      END;
    END;
    Shell.DragFinish(hDrop);
  
  ELSE
    RETURN Windows.DefFrameProc(hWnd, hWndClient, message, wParam, lParam)

  END;

  RETURN 0

END MDIFrameWndProc;



(******************************************************************************
 *
 * FUNCTION:
 * InitApplication registers all window classes.
 *
 * PRECONDITIONS:  --
 *
 * POSTCONDITIONS: --
 *
 ******************************************************************************
 * PARAMETER      DESCRIPTION
 * -------------- -------------------------------------------------------------
 * hInstCurr      instance handle of the current instance
 ******************************************************************************)
PROCEDURE InitApplication(hInstCurr: Windows.HINSTANCE): BOOLEAN;
  VAR wc: Windows.WNDCLASS;
BEGIN
  (* -- register MDI frame window class -- *)
  wc.style         := Windows.NULL;
  wc.lpfnWndProc   := MDIFrameWndProc;
  wc.cbClsExtra    := 0;
  wc.cbWndExtra    := 0;
  wc.hInstance     := hInstCurr;
  wc.hIcon         := Windows.NULL;
  wc.hCursor       := Windows.LoadCursor(Windows.NULL, Windows.IDC_ARROW);
  wc.hbrBackground := Windows.GetStockObject(Windows.WHITE_BRUSH);
  wc.lpszMenuName  := SYSTEM.ADR("Editor");
  wc.lpszClassName := SYSTEM.ADR(MDIFrameClass);
  RETURN (Windows.RegisterClass(SYSTEM.ADR(wc)) # 0) & EditWin.RegisterClass(hInstCurr);
END InitApplication;



(******************************************************************************
 *
 * FUNCTION:
 * InitInstance performs the initialisation for the current instance of this
 * program.
 *
 * PRECONDITIONS:
 * The window class used by this program should be registered. (InitApplication)
 *
 * POSTCONDITIONS: --
 *
 ******************************************************************************
 * PARAMETER      DESCRIPTION
 * -------------- -------------------------------------------------------------
 * hInstCurr      instance handle of the current instance
 * nCmdShow       ??
 ******************************************************************************)
PROCEDURE InitInstance(hInstCurr: Windows.HINSTANCE; nCmdShow: INTEGER): BOOLEAN;
  VAR r: LONGINT;
BEGIN

  (* -- create frame window -- *)
  hWnd := Windows.CreateWindow(
          SYSTEM.ADR(MDIFrameClass), SYSTEM.ADR(WindowTitle), 
          Windows.WS_OVERLAPPEDWINDOW, 
          Windows.CW_USEDEFAULT, Windows.CW_USEDEFAULT, 
          Windows.CW_USEDEFAULT, Windows.CW_USEDEFAULT, 
          Windows.NULL, Windows.NULL, 
          hInstCurr, Windows.NULL);
  IF hWnd # 0 THEN
    r := Windows.ShowWindow(hWnd, nCmdShow);
    Windows.UpdateWindow(hWnd);
    RETURN TRUE;
  END;
  RETURN FALSE

END InitInstance;



(******************************************************************************
 *
 * FUNCTION:
 * WinMain is the "main program". It is automartically called by Windows when
 * the user starts this application. 
 *
 * PRECONDITIONS:  --
 *
 * POSTCONDITIONS: --
 *
 ******************************************************************************
 * PARAMETER      DESCRIPTION
 * -------------- -------------------------------------------------------------
 * hInstCurr      instance handle for the current instance of this application
 * hInstPrev      instance handle for the previously loaded instance
 * lpCmdLine      command line (far pointer to a null terminated string)
 * nCmdShow       This parameter says how the main window should be displayed.
 ******************************************************************************)
PROCEDURE [WINDOWS] WinMain*(hInstCurr: Windows.HINSTANCE; 
                             hInstPrev: Windows.HINSTANCE;
                             lpCmdLine: Windows.LPSTR;
                             nCmdShow:  INTEGER): INTEGER;
  VAR
    msg: Windows.MSG;
    r:   LONGINT;
    
BEGIN

  (* -- save instance handle for further use -- *)
  hInstance := hInstCurr;

  (* -- initialize first instance -- *)
  IF (hInstPrev = Windows.NULL) & ~InitApplication(hInstCurr) THEN
    Error.DspMsg("Could not register window class");
    RETURN Windows.false;
  END;

  (* -- initialize the current instance -- *)
  IF ~InitInstance(hInstCurr, nCmdShow) THEN
    Error.DspMsg("Could not create main window");
    RETURN Windows.false;
  END; 

  (* -- message loop -- *)
  WHILE Windows.GetMessage(SYSTEM.ADR(msg), Windows.NULL, Windows.NULL, Windows.NULL) # 0 DO
    IF Windows.TranslateMDISysAccel(hWndClient, SYSTEM.ADR(msg)) = 0 THEN
      r := Windows.TranslateMessage(SYSTEM.ADR(msg)); 
      r := Windows.DispatchMessage(SYSTEM.ADR(msg));
    END;
  END;
  RETURN msg.wParam
  
END WinMain;


END Editor.
