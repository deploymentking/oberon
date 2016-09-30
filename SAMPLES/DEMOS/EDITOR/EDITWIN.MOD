(******************************************************************************
 * MODULE:        EditWin
 * DESCRIPTION:   demo editor using the edit control of windows
 * LANGUAGE:      Oberon-2
 * COPYRIGHT BY:  Peter René Dietmüller, dietmueller@fim.uni-linz.ac.at (PDI)
 ******************************************************************************
 * DATE      AUTHOR  CHANGES
 * --------  ------  ----------------------------------------------------------
 * ??/??/??  PDI     Version 1
 * 97/03/11  PDI     minor changes for callback functions
 ******************************************************************************)
MODULE EditWin;


  IMPORT Error, SYSTEM, Windows;


  CONST
    EditWinClass = "EDITOR";


  TYPE
    EditData = RECORD
      hWndEdit: Windows.HWND;
    END;
    EditDataP = POINTER TO EditData;



PROCEDURE [WINDOWS] EditWinProc*(hWnd: Windows.HWND; message: Windows.WORD; wParam: Windows.WORD; lParam: LONGINT): LONGINT;

  CONST
    IDEDIT = 1;

  VAR
    dp:        EditDataP;
    hdc:       Windows.HDC;
    hInstance: Windows.HINSTANCE;
    ps:        Windows.PAINTSTRUCT;
    r:         LONGINT;
    wnd:       Windows.RECT;
    
BEGIN

  (* -- set data pointer for window hWnd-- *)
  IF message = Windows.WM_CREATE THEN
    NEW(dp);
    r := Windows.SetWindowLong(hWnd, 0, SYSTEM.VAL(LONGINT, dp));
  ELSE
    dp := SYSTEM.VAL(EditDataP, Windows.GetWindowLong(hWnd, 0));
  END;

  (* -- process message -- *)
  IF message = Windows.WM_CREATE THEN
    Windows.GetClientRect(hWnd, SYSTEM.ADR(wnd));
    hInstance := Windows.GetWindowWord(hWnd, Windows.GWW_HINSTANCE);
    dp^.hWndEdit := Windows.CreateWindow(SYSTEM.ADR("EDIT"), Windows.NULL,
                    Windows.WS_HSCROLL + Windows.WS_VSCROLL + 
                    Windows.WS_VISIBLE + Windows.WS_CHILD + 
                    Windows.ES_MULTILINE + Windows.ES_AUTOHSCROLL + 
                    Windows.ES_AUTOVSCROLL + Windows.ES_WANTRETURN + Windows.DS_LOCALEDIT,
                    wnd.left, wnd.top, wnd.right, wnd.bottom,
                    hWnd, IDEDIT, hInstance, Windows.NULL);
    r := Windows.SendMessage(dp^.hWndEdit, Windows.WM_SETFONT, 
         Windows.GetStockObject(Windows.SYSTEM_FIXED_FONT), 0);
    r := Windows.SetFocus(dp^.hWndEdit);

  ELSIF message = Windows.WM_DESTROY THEN
    r := Windows.DestroyWindow(dp^.hWndEdit);

  ELSIF message = Windows.WM_CLOSE THEN
    IF (Windows.SendMessage(dp^.hWndEdit, Windows.EM_GETMODIFY, 0, 0) = 0) OR
       (Windows.MessageBox(hWnd, SYSTEM.ADR("Wollen Sie das Fenster wirklich schließen?"), SYSTEM.ADR("Editor"), 
                           Windows.MB_ICONQUESTION + Windows.MB_OKCANCEL) = Windows.IDOK) THEN
      r := Windows.SendMessage(Windows.GetParent(hWnd), Windows.WM_MDIDESTROY, hWnd, 0);
    END;
    RETURN 0;
    
  ELSIF message = Windows.WM_SIZE THEN
    Windows.GetClientRect(hWnd, SYSTEM.ADR(wnd));
    r := Windows.MoveWindow(dp^.hWndEdit, wnd.left, wnd.top, wnd.right, wnd.bottom, Windows.true);
    RETURN Windows.DefMDIChildProc(hWnd, message, wParam, lParam);

  ELSIF message = Windows.WM_SETFOCUS THEN
    r := Windows.SetFocus(dp^.hWndEdit);

  ELSE
    RETURN Windows.DefMDIChildProc(hWnd, message, wParam, lParam)

  END;

  (* -- deallocate data for window hWnd -- *)
  IF message = Windows.WM_DESTROY THEN
    DISPOSE(dp);
  END;

  RETURN 0

END EditWinProc;


PROCEDURE RegisterClass*(hInstance: Windows.HINSTANCE): BOOLEAN;
  VAR wc: Windows.WNDCLASS;
BEGIN

  (* -- register MDI child window class -- *)
  wc.style         := Windows.NULL;
  wc.lpfnWndProc   := EditWinProc;
  wc.cbClsExtra    := 0;
  wc.cbWndExtra    := 4;
  wc.hInstance     := hInstance;
  wc.hIcon         := Windows.LoadIcon(Windows.NULL, Windows.IDI_HAND);
  wc.hCursor       := Windows.LoadCursor(Windows.NULL, Windows.IDC_ARROW);
  wc.hbrBackground := Windows.GetStockObject(Windows.WHITE_BRUSH);
  wc.lpszMenuName  := Windows.NULL;
  wc.lpszClassName := SYSTEM.ADR(EditWinClass);
  IF Windows.RegisterClass(SYSTEM.ADR(wc)) = 0 THEN
    Error.DspMsg("Could not register MDI child window class");
    RETURN FALSE
  END;
  RETURN TRUE;

END RegisterClass;



PROCEDURE Create*(title: ARRAY OF CHAR; hInstance: Windows.HINSTANCE; hWndParent: Windows.HWND): Windows.HWND;

  VAR
    hWnd: Windows.HWND;
    mcs:  Windows.MDICREATESTRUCT;
    r:    LONGINT;

BEGIN

  (* -- create child window -- *)
  mcs.szClass := SYSTEM.ADR(EditWinClass);
  mcs.szTitle := SYSTEM.ADR(title);
  mcs.hOwner  := hInstance;
  mcs.x       := Windows.CW_USEDEFAULT;
  mcs.y       := Windows.CW_USEDEFAULT;
  mcs.cx      := Windows.CW_USEDEFAULT;
  mcs.cy      := Windows.CW_USEDEFAULT;
  mcs.style   := Windows.MDIS_ALLCHILDSTYLES;
  mcs.lParam  := 0;
  hWnd := SHORT(Windows.SendMessage(hWndParent, Windows.WM_MDICREATE, 0, SYSTEM.ADR(mcs)));
  IF hWnd = 0 THEN
    Error.DspMsg("Could not create window.");
  ELSE
    r := Windows.ShowWindow(hWnd, Windows.SW_SHOW);
    Windows.UpdateWindow(hWnd);
  END;
  RETURN hWnd;
  
END Create;



PROCEDURE Close*(hWnd: Windows.HWND): BOOLEAN;
BEGIN
  RETURN Windows.SendMessage(hWnd, Windows.WM_CLOSE, 0, 0) = 0;
END Close;


PROCEDURE LoadFile*(hWnd: Windows.HWND; fileName: ARRAY OF CHAR): BOOLEAN;

  VAR
    buffer:   POINTER TO ARRAY OF CHAR;
    dp:       EditDataP;
    fileSize: LONGINT;
    hFile:    Windows.HFILE;
    ok:       BOOLEAN;
    r:        LONGINT;

BEGIN

  ok := FALSE;
  dp := SYSTEM.VAL(EditDataP, Windows.GetWindowLong(hWnd, 0));
  hFile := Windows._lopen(SYSTEM.ADR(fileName), Windows.READ);
  IF hFile # Windows.HFILE_ERROR THEN
    fileSize := Windows._llseek(hFile, 0, 2);
    IF fileSize < 65536 THEN
      NEW(buffer, fileSize + 1);
      IF Windows._llseek(hFile, 0, 0) # Windows.HFILE_ERROR THEN
        IF Windows._lread(hFile, SYSTEM.ADR(buffer^), SHORT(fileSize + 1)) # 0 THEN
          buffer^[fileSize] := 0X;
          Windows.SetWindowText(hWnd, SYSTEM.ADR(fileName));
          IF Windows.SendMessage(dp^.hWndEdit, Windows.WM_SETTEXT, 0, SYSTEM.ADR(buffer^)) # 0 THEN
            ok := TRUE;
          ELSE
            Error.DspMsg("Could not load the desired file because of too less memory!");
          END;
        ELSE
          Error.DspMsg("Could not read the entire file.");
        END;
      ELSE
        Error.DspMsg("Could not get the file size of the file!");
      END;
      DISPOSE(buffer);
    ELSE
      Error.DspMsg("Could not allocate the requested block size!");
    END;
    r := Windows._lclose(hFile);
  ELSE
    Error.DspMsg("Could not open the file!");
  END;
  RETURN ok;

END LoadFile;


PROCEDURE SaveFile*(hWnd: Windows.HWND);
BEGIN
END SaveFile;


PROCEDURE SaveFileAs*(hWnd: Windows.HWND; fileName: ARRAY OF CHAR): BOOLEAN;
BEGIN
END SaveFileAs;


PROCEDURE Print*(hWnd: Windows.HWND; hdc: Windows.HDC): BOOLEAN;

  TYPE
    EDITLINE = RECORD [WINDOWS]
      size:  INTEGER;
      text:  ARRAY 128 OF CHAR;
    END;
    
  VAR
    di:            Windows.DOCINFO;
    dp:            EditDataP;
    fileName:      ARRAY 128 OF CHAR;
    i:             LONGINT;
    line:          EDITLINE;
    lineCount:     LONGINT;
    lineHeight:    INTEGER;
    lineLength:    INTEGER;
    linesPerPage:  INTEGER;
    r:             LONGINT;
    tm:            Windows.TEXTMETRIC;
    y:             INTEGER;

BEGIN

  (* -- get file name -- *)
  fileName := "";
  r := Windows.SendMessage(hWnd, Windows.WM_GETTEXT, LEN(fileName), SYSTEM.ADR(fileName));
  
  (* -- print content of edit control -- *)
  dp := SYSTEM.VAL(EditDataP, Windows.GetWindowLong(hWnd, 0));

  di.cbSize := SIZE(Windows.DOCINFO);
  di.lpszDocName := SYSTEM.ADR(fileName);
  di.lpszOutput  := SYSTEM.ADR("c:\t.mod");

  r := Windows.GetTextMetrics(hdc, SYSTEM.ADR(tm));
  lineHeight := tm.tmHeight + tm.tmExternalLeading;
  linesPerPage := Windows.GetDeviceCaps(hdc, Windows.VERTRES) DIV lineHeight;
  lineCount := Windows.SendMessage(dp^.hWndEdit, Windows.EM_GETLINECOUNT, 0, 0);

  r := Windows.StartDoc(hdc, SYSTEM.ADR(di));
  r := Windows.StartPage(hdc);
  y := 0;
  FOR i := 0 TO lineCount - 1 DO
    IF ((i + 1) MOD linesPerPage) = 0 THEN
      r := Windows.EndPage(hdc);
      r := Windows.StartPage(hdc);
      y := 0;
    END;
    line.size := LEN(line.text);
    lineLength := SYSTEM.VAL(INTEGER, Windows.SendMessage(dp^.hWndEdit, Windows.EM_GETLINE, SYSTEM.VAL(INTEGER, i), SYSTEM.ADR(line)));
    r := Windows.TextOut(hdc, 0, y, SYSTEM.ADR(line), lineLength);
    INC(y, lineHeight);
  END;

  r := Windows.EndPage(hdc);
  r := Windows.EndDoc(hdc);
  
  RETURN TRUE;

END Print;


PROCEDURE Copy*(hWnd: Windows.HWND): BOOLEAN;

  VAR
    dp:        EditDataP;
    ds:        INTEGER;
    end:       INTEGER;
    start:     INTEGER;
    hCopyData: Windows.HANDLE;
    hEditData: Windows.HANDLE;
    lpEdit:    LONGINT;
    lpCopy:    LONGINT;
    ok:        BOOLEAN;
    r:         LONGINT;
    
BEGIN

  ok := FALSE;

  dp := SYSTEM.VAL(EditDataP, Windows.GetWindowLong(hWnd, 0));

  r := Windows.SendMessage(dp^.hWndEdit, Windows.EM_GETSEL, 0, 0);
  start := SHORT(r MOD 10000H);
  end   := SHORT(r DIV 10000H);
  IF (end - start) > 0 THEN (* is something selected ? *)
    hEditData := SHORT(Windows.SendMessage(dp^.hWndEdit, Windows.EM_GETHANDLE, 0, 0));
    IF hEditData # 0 THEN
      hCopyData := Windows.GlobalAlloc(Windows.GMEM_MOVEABLE, end - start + 1);
      IF hCopyData # 0 THEN 
        lpEdit := Windows.LocalLock(hEditData);
        IF lpEdit # Windows.NULL THEN
          SYSTEM.GETREG(11, ds); (* get data segment register *)
          lpEdit := lpEdit + ds * 65536;
          lpCopy := Windows.GlobalLock(hCopyData);
          IF lpCopy # Windows.NULL THEN
            SYSTEM.MOVE(lpEdit + start, lpCopy, end - start);
            SYSTEM.PUT(lpCopy + end - start, 0X);
            ok := TRUE;
            r := Windows.GlobalUnlock(hCopyData);
          ELSE
            Error.DspMsg("Could not lock global memory (copy).");
          END;
          r := Windows.LocalUnlock(hEditData);
        ELSE
          Error.DspMsg("Could not lock global memory (edit).");
        END;
      ELSE
        Error.DspMsg("Could not allocate global memory.");
      END;
    ELSE
      Error.DspMsg("Could not get edit handle");
    END;
  END;
  
  IF ok THEN  
    IF Windows.OpenClipboard(hWnd) # 0 THEN
      r := Windows.EmptyClipboard();
      r := Windows.SetClipboardData(Windows.CF_TEXT, hCopyData);
      r := Windows.CloseClipboard();
    ELSE
      Error.DspMsg("Could not open the clipboard");
      ok := FALSE;
    END;
  END;

  RETURN ok;
  
END Copy;


END EditWin.
