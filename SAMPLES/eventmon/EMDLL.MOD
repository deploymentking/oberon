(******************************************************************************)
(* MODULE:      EmDll                                        ME - 24.06.96    *)
(* DESCRIPTION: Dll to spy windows messages                                   *)
(* LANGUAGE:    Oberon-2                                                      *)
(* COMPILER:    Robinson Associates Oberon-2 V1.18 beta6                      *)
(* WORKBENCH    POW 3.0 beta3                                                 *)
(* AUTHOR:      Martin Erdpresser, k3075e2@c210.edvz.uni-linz.ac.at (ME)      *)
(******************************************************************************)
(* DATE      AUTHOR  CHANGES                                                  *)
(* --------  ------  ---------------------------------------------------------*)
(* 24.06.96  ME      Final release V.1.0                                      *)
(******************************************************************************)

MODULE EmDll;

IMPORT W := Windows, F := FiltHnd, D := Decoder, File, SYSTEM, Strings, Utils;

CONST
  ClassName = "WC_EM_Viewer";
  CACHE_SIZE = 255;
  LINE_LENGTH = 255;

TYPE 
  WhProcT = PROCEDURE [WINDOWS] (nCode : INTEGER;       (* Procedure type for *)
                                 wParam : W.WORD;       (* filter functions   *)
                                 lParam : W.DWORD) : W.LRESULT;
                                 
  FileDesc = RECORD                        (* Describes properties of         *)
               name : ARRAY 140 OF CHAR;   (* logfile                         *)
               fHnd : File.Handle;
               overwrite,
               active : BOOLEAN;
               startIndex : LONGINT;
             END;                               
                                 
                                 
VAR
  hInstance   : W.HINSTANCE;                  
  hLogWnd,                                 (* Handle where text output goes to*)
  hTargetWnd  : W.HWND;                    (* Window handle to spy on         *)
  hFont       : W.HFONT;                   (* Font for text output            *)
  nLine,                                   (* Disables 1st page scrolling     *)
  bottomSpace,                             (* Space from bottom of parent wnd.*)
  cxChar,                                  (* Char width                      *)
  cyChar,                                  (* Char height                     *)
  cxClient,                                (* Width of output screen          *)
  cyClient,                                (* Height of output screen         *)
  vScrollMax,                              (* Upper bound vert. scroll range  *)
  vScrollPos,                              (* Curr. vert. scroll position     *)
  hScrollMax,                              (* Upper bound horiz. scroll range *)
  hScrollPos,                              (* Curr. horiz. scroll position    *)
  cacheIndex,                              (* Curr. cache index               *)
  lineCount : INTEGER;                     (* Curr. amount of lines occured   *)
  currMsgFlag : LONGINT;                   (* Holds msg. selection flag       *)

  cache : POINTER TO ARRAY OF              (* Message cache                   *)
            ARRAY LINE_LENGTH OF CHAR;
  logFile : FileDesc;                      (* The log-file to use             *)

  
(*============================================================================*)
(* PURPOSE:  Opens a message box                                              *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* msg            Message to display in box                                   *)
(* title          Title of messagebox                                         *)
(*============================================================================*)
PROCEDURE MsgBox(msg, title : ARRAY OF CHAR);
VAR 
  r : INTEGER;

BEGIN
  W.MessageBeep(-1);
  r := W.MessageBox(W.NULL, 
                    SYSTEM.ADR(msg), 
                    SYSTEM.ADR(title), 
                    W.MB_OK+W.MB_ICONEXCLAMATION);
END MsgBox;  
  
  
(*============================================================================*)
(* PURPOSE:  Sets output of filter results to textual representation          *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(*                                                                            *)
(*============================================================================*) 
PROCEDURE SetText*(); 
BEGIN 
  D.SetTextMode();
END SetText;


(*============================================================================*)
(* PURPOSE:  Sets output of filter results to textual representation          *)
(*           with additional hexadecimal information                          *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(*                                                                            *)
(*============================================================================*) 
PROCEDURE SetTextHex*(); 
BEGIN 
  D.SetTextAndHexMode();
END SetTextHex;


(*============================================================================*)
(* PURPOSE:  Sets output of filter results to hexadecimal representation      *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(*                                                                            *)
(*============================================================================*) 
PROCEDURE SetHex*(); 
BEGIN 
  D.SetHexMode();
END SetHex;


(*============================================================================*)
(* PURPOSE:  Register message group selection of user                         *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* flag           Indicates message group selection of user                   *)
(*============================================================================*) 
PROCEDURE RegisterSelection*(flag : LONGINT); 
BEGIN 
  currMsgFlag := flag;
END RegisterSelection;


(*============================================================================*)
(* PURPOSE:  Sets the window handle, which should be spyed on                 *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* hWnd           Window handle of interest                                   *)
(*============================================================================*) 
PROCEDURE SetTargetWnd*(hWnd : W.HWND); 
BEGIN 
  hTargetWnd := hWnd;
END SetTargetWnd;


(*============================================================================*)
(* PURPOSE:  Sets space between bottom of viewer and bottom of parent window. *)
(*                                                                            *)
(* COMMENTS: So you can modify viewer height.                                 *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* dist           Space to leave (log. screen units)                          *)
(*============================================================================*)
PROCEDURE SetBottomSpace*(space: INTEGER); 
BEGIN
  ASSERT(space > 0); 
  bottomSpace := space;
END SetBottomSpace;


(*============================================================================*)
(* PURPOSE:  Compares "x" and "y" and return their maximum                    *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* x              Integer values                                              *)
(* y              to compare                                                  *)
(*============================================================================*)
PROCEDURE MaxInt(x, y : INTEGER) : INTEGER;
BEGIN
  IF x >= y THEN RETURN x ELSE RETURN y END;
END MaxInt;


(*============================================================================*)
(* PURPOSE:  Compares "x" and "y" and return their minimum                    *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* x              Integer values                                              *)
(* y              to compare                                                  *)
(*============================================================================*)
PROCEDURE MinInt(x, y : INTEGER) : INTEGER;
BEGIN
  IF x <= y THEN RETURN x ELSE RETURN y END;
END MinInt;


(*============================================================================*)
(* PURPOSE:  Appends date and time to given string                            *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* str            String receiving result                                     *)
(*============================================================================*)
PROCEDURE GetDateTime(VAR str : ARRAY OF CHAR);
VAR
  date, time : ARRAY 16 OF CHAR;
BEGIN
  date := ""; time := ""; 
  Utils.GetDateStr(date); Utils.GetTimeStr(time);
  Strings.Append(str,date); Strings.Append(str,", "); Strings.Append(str,time); 
END GetDateTime;


(*============================================================================*)
(* PURPOSE:  Write a line of text to screen, if the last line of screen is    *)
(*           reached, the contents will be scrolled.                          *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* hWnd           Window handle                                               *)
(* txt            Text to display                                             *)
(* nLine          Indicates, if screen must be scrolled                       *)
(*============================================================================*)
PROCEDURE WriteScreen(hWnd : W.HWND; txt : ARRAY OF CHAR; VAR nLine : INTEGER);
VAR
  hWndParent : W.HWND;
  hDC, hDCMem : W.HDC;
  hBmp, hBmpOld : W.HBITMAP;
  hFontOld, done : W.HGDIOBJ;
  rect : W.RECT;
  r : INTEGER; 
  i : INTEGER;
  s : ARRAY LINE_LENGTH OF CHAR;
  
BEGIN
  s := "";
  hDC := W.GetDC(hWnd);
  
  hWndParent := W.GetParent(hWnd);         (* Get size of viewer window       *)
  W.GetClientRect(hWnd, SYSTEM.ADR(rect));  

  (*-- Prepare bitmap --*)
  hDCMem := W.CreateCompatibleDC(hDC);
  hBmp := W.CreateCompatibleBitmap(hDC,rect.right,rect.bottom);
  
  (*-- Bitmap was successfully created, put output to screen --*)
  IF (hDCMem # W.NULL) & (hBmp # W.NULL) & (rect.bottom DIV cyChar > 0) THEN
    hBmpOld := W.SelectObject(hDCMem, hBmp);
    hFontOld := W.SelectObject(hDCMem, hFont);
    r := W.FillRect(hDCMem, SYSTEM.ADR(rect), W.GetStockObject(W.WHITE_BRUSH));

    (*-- Bottom of screen reached, scroll window one line up --*)
    IF nLine >= rect.bottom DIV cyChar THEN
      vScrollPos := MaxInt(0,lineCount - (cyClient DIV cyChar)+1);

      FOR i := 0 TO ((rect.bottom DIV cyChar) -1) DO
        Strings.Copy(cache[(cacheIndex-((rect.bottom DIV cyChar)-1)+i) MOD CACHE_SIZE],
                     s, 
                     hScrollPos+1, 
                     Strings.Length(cache[(cacheIndex-((rect.bottom DIV cyChar)-1)+i) MOD CACHE_SIZE]));
        r := W.TextOut(hDCMem,rect.left+cxChar, i * cyChar,
                       SYSTEM.ADR(s),
                       SHORT(Strings.Length(s)));
      END;                
      r := W.BitBlt(hDC,    rect.left,  rect.top,
                            rect.right, (rect.bottom DIV cyChar) * cyChar,
                    hDCMem, rect.left,  rect.top, W.SRCCOPY); 

    (*-- Still lines fitting on screen --*)                       
    ELSE
      Strings.Copy(txt, s, hScrollPos+1, Strings.Length(txt));
      r := W.TextOut(hDCMem,rect.left+cxChar,
                    ((rect.bottom DIV cyChar) -1) * cyChar ,
                     SYSTEM.ADR(s),
                     SHORT(Strings.Length(s))); 
  
      r := W.BitBlt(hDC,    rect.left,  nLine * cyChar,
                            rect.right, cyChar,
                    hDCMem, rect.left,  ((rect.bottom DIV cyChar) -1) * cyChar, W.SRCCOPY);
 
      INC(nLine);
    END;
  END;
  
  (*-- Do some cleanup --*) 
  done := W.SelectObject(hDCMem, hFontOld);
  IF W.SelectObject(hDCMem,hBmpOld) # W.NULL THEN r := W.DeleteObject(hBmp) END;
  IF (hDCMem # W.NULL) THEN r := W.DeleteDC(hDCMem) END;
  
  r := W.ReleaseDC(hWnd, hDC); 
END WriteScreen;


(*============================================================================*)
(* PURPOSE:  Saves a subset of the message cache, identified by "start"       *)
(*           and "end"-index to a logfile. The logfile have to be registered  *)
(*           previously.                                                      *)
(*                                                                            *)
(* COMMENTS: Returns true on success                                          *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* start          Start index of cache to save                                *)
(* end            End index of cache to save                                  *)
(*============================================================================*)
PROCEDURE FlushCache(start, end : LONGINT) : BOOLEAN;
VAR
  i,
  pos : LONGINT;
  res : INTEGER;
  
BEGIN
  (*-- Check index bounds --*)
  IF ((start >= 0) & (start <= end) & (end < CACHE_SIZE)) THEN 

    (*-- Open logfile, set filepointer to eof --*)
    File.Open(logFile.name,
              TRUE, 
              File.DENYALL, 
              File.READWRITE,
              logFile.fHnd, 
              res); 
    File.Size(logFile.fHnd, pos, res); 
    File.Seek(logFile.fHnd, pos, res);
 
    (*-- Write current content of message cache to logfile --*)
    IF res = File.NOERROR THEN
      i := start;
      File.WriteLn(logFile.fHnd,cache[i],res); INC(i);
      WHILE ((i <= end) & (res = File.NOERROR)) DO
        File.WriteLn(logFile.fHnd, cache[i], res); INC(i)
      END;
      File.Close(logFile.fHnd);
      RETURN i > end;
    ELSE
      RETURN FALSE;
    END;
    
  (*-- Index bounds out of range --*) 
  ELSE
    RETURN FALSE
  END
END FlushCache;


(*============================================================================*)
(* PURPOSE:  Register filename and replacement mode of logfile.               *)
(*                                                                            *)
(* COMMENTS: Returns true, if valid filename was passed.                      *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* fileName       Name of logfile                                             *)
(* overwrite      Replacenemt mode: TRUE = overwrite                          *)
(*                                  FALSE = append                            *)
(*============================================================================*)
PROCEDURE RegisterLogFile*(fileName : ARRAY OF CHAR; overwrite : BOOLEAN) : BOOLEAN;
VAR
  r,
  res : INTEGER;                           (* Error code of file operations   *)
  str : ARRAY LINE_LENGTH OF CHAR;         (* Auxiliary string                *)

BEGIN 
  res := File.NOERROR;

  (*-- Try to open specified file --*)
  IF ~File.Exist(fileName) THEN
    File.Open(fileName,
              TRUE, 
              File.DENYALL, 
              File.READWRITE, logFile.fHnd, res);
    File.Close(logFile.fHnd);
    File.Delete(fileName,res);
  END;

  (*-- Valid filename passed, store file description --*)
  IF res = File.NOERROR THEN
    logFile.name := "";  
    Strings.Copy(fileName, logFile.name, 1, Strings.Length(fileName));
    logFile.overwrite := overwrite;
    logFile.active := FALSE;
    RETURN res = File.NOERROR
  
  (*-- Open attempt with specified filename failed --*) 
  ELSE
    str := "";    
    File.GetErrorMessage(res,str);
    MsgBox(str,"ERROR: EmDll.RegisterLogFile");
    RETURN FALSE
  END
END RegisterLogFile;


(*============================================================================*)
(* PURPOSE:  Prepare logfile and enable logging                               *)
(*                                                                            *)
(* COMMENTS: Returns true on success                                          *)
(*                                                                            *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(*                                                                            *)
(*============================================================================*)
PROCEDURE StartFileLog*() : BOOLEAN;
VAR
  r, 
  res : INTEGER;                           (* Holds error code of file op.    *)
  pos : LONGINT;                           (* Filepointer                     *)
  str : ARRAY LINE_LENGTH OF CHAR;         (* Auxiliary string                *)
  
BEGIN 
  str := "";

  (*-- Logging was already enabled --*) 
  IF logFile.active THEN RETURN TRUE END;
  
  (*-- Delete old logfile --*)           
  IF logFile.overwrite & File.Exist(logFile.name) THEN
    File.Close(logFile.fHnd); 
    File.Delete(logFile.name, res);
    IF (res # File.NOERROR) THEN RETURN FALSE END;
  END;
  
  (*-- Open logfile, if it doesn't exists, it will be created --*) 
  File.Open(logFile.name,
            TRUE, 
            File.DENYALL, 
            File.READWRITE, logFile.fHnd, res);
          
  (*-- Open attempt successfully, prepare headline for logfile --*)
  IF res = File.NOERROR THEN
    File.Size(logFile.fHnd, pos, res);     (* Set filepointer to end of file  *)
    File.Seek(logFile.fHnd, pos, res);
    Strings.Append(str,">>>======== Event Monitor started : "); GetDateTime(str);
    File.WriteLn(logFile.fHnd, str, res);  (* Write headline to file          *)
    logFile.active := (res = File.NOERROR); 
    logFile.startIndex := cacheIndex;
    File.Close(logFile.fHnd);
    RETURN res = File.NOERROR

  (*-- Open attempt failed --*)
  ELSE
    File.GetErrorMessage(res,str);
    MsgBox(str,"ERROR: EmDll.StartFileLog");
    RETURN FALSE
  END
END StartFileLog;


(*============================================================================*)
(* PURPOSE:  Write back results and disable logging                           *)
(*                                                                            *)
(* COMMENTS: Returns true on success                                          *)
(*                                                                            *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(*                                                                            *)
(*============================================================================*)
PROCEDURE StopFileLog*() : BOOLEAN;
VAR
  r,
  res : INTEGER;                           (* Holds error code of file op.    *)
  pos : LONGINT;                           (* Filepointer                     *)
  str : ARRAY LINE_LENGTH OF CHAR;         (* Auxiliary string                *)
  rb : BOOLEAN;                            (* Boolean return value            *)

BEGIN
  str := "";
    
  (*-- Nothing to do, file logging wasn't enables previously --*)
  IF ~logFile.active THEN
    RETURN TRUE
    
  (*-- Logging was enabled, write back results --*) 
  ELSE
    rb := TRUE;
    IF cacheIndex > logFile.startIndex THEN  (* Some new events occured       *)
      rb := FlushCache(logFile.startIndex, cacheIndex-1);
      logFile.startIndex := cacheIndex;
    END;
 
    File.Open(logFile.name,
              TRUE, 
              File.DENYALL, 
              File.READWRITE, logFile.fHnd, res);
    
    (*-- Open attempt successfully, prepare footline for logfile --*) 
    IF res = File.NOERROR THEN
      File.Size(logFile.fHnd, pos, res);     (* Set filepointer to end of file*)
      File.Seek(logFile.fHnd, pos, res); 
      Strings.Append(str,"<<<======== Event Monitor stopped : "); GetDateTime(str);
      File.WriteLn(logFile.fHnd, str, res);  (* Write footline to file        *)
      File.Close(logFile.fHnd);
      logFile.active := FALSE;
    ELSE
      File.GetErrorMessage(res,str);
      MsgBox(str,"ERROR: EmDll.StopFileLog");
    END;
    RETURN rb & (res = File.NOERROR);
  END
END StopFileLog;


(*============================================================================*)
(* PURPOSE:  Clears whole content of message cache                            *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(*                                                                            *)
(*============================================================================*)
PROCEDURE ClearAll*();
VAR
  i,r : INTEGER;
  
BEGIN
  nLine := 0;       
  cacheIndex := 0; 
  lineCount := 0;
 
  FOR i := 0 TO CACHE_SIZE-1 DO
    cache[i] := "";
  END;
  
  (*-- Re-init scroll bars --*)                                              
  vScrollMax := 0; vScrollPos := 0;
  W.SetScrollRange(hLogWnd, W.SB_VERT, 0, MaxInt(1,vScrollMax), W.false);
  r := W.SetScrollPos(hLogWnd, W.SB_VERT, vScrollPos, W.true);   

  hScrollMax := 0; hScrollPos := 0;
  W.SetScrollRange(hLogWnd, W.SB_HORZ, 0, MaxInt(1,hScrollMax), W.false);
  r := W.SetScrollPos(hLogWnd, W.SB_HORZ, hScrollPos, W.true);   
 
  W.InvalidateRect(hLogWnd, W.NULL, W.true);
  W.UpdateWindow(hLogWnd);
END ClearAll;


(*============================================================================*)
(* PURPOSE:  User defined Hook-function fitting to WH_CALLWNDPROC             *)
(*                                                                            *)
(* COMMENTS: The CallWndProc function is a library-defined callback function  *)
(*           that the system calls whenever SendMessage function is called.   *)
(*           The system passes the message to the callback function before    *)
(*           passing the message to the destination window procedure.         *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* nCode          Process code                                                *)
(* wParam         Current task-flag                                           *)
(* lParam         Address of structure with message data                      *)
(*============================================================================*)
PROCEDURE [WINDOWS] WhCallWndProc*(nCode  : INTEGER; 
                                   wParam : W.WORD; 
                                   lParam : W.DWORD
                                  ) : W.LRESULT;
VAR 
  rl       : W.LRESULT;                    (* Some auxiliary                  *)
  rb       : BOOLEAN;                      (* return values                   *)
  lpfhHook : W.FARPROC;                    (* Proc instance of hook function  *)
  str      : ARRAY LINE_LENGTH OF CHAR;    (* String to hold output           *)
 
BEGIN
  str := "";
  
  (*-- Skip this message -----------------*)
  IF nCode < 0 THEN                        
    lpfhHook := F.GetHandle(W.WH_CALLWNDPROC);
    rl := W.DefHookProc(nCode, wParam, lParam, SYSTEM.ADR(lpfhHook))
    
  (*-- Decode and print this message -----*) 
  ELSIF ((nCode = W.HC_ACTION) & 
    (D.CallWndProc(hTargetWnd,wParam,lParam,currMsgFlag,str))) THEN
    rl := W.lstrcpyn(SYSTEM.ADR(cache[cacheIndex]),
                     SYSTEM.ADR(str),
                     W.lstrlen(SYSTEM.ADR(str))+1);
    WriteScreen(hLogWnd,str,nLine);
    
    IF (cacheIndex = CACHE_SIZE-1) & logFile.active THEN
      rb := FlushCache(logFile.startIndex, CACHE_SIZE-1);
      logFile.startIndex := 0;
    END; 
    
    cacheIndex := (cacheIndex + 1) MOD CACHE_SIZE; INC(lineCount);
    IF lineCount = MAX(INTEGER) THEN ClearAll() END;
  END;
  
  RETURN 0;
END WhCallWndProc;


(*============================================================================*)
(* PURPOSE:  User defined Hook-function fitting to WH_GETMESSAGE              *)
(*                                                                            *)
(* COMMENTS: The WhGetMsgProc function is a library-defined callback function *)
(*           that the system calls whenever the GetMessage function has       *)
(*           retrieved a message from an application queue. The system passes *)
(*           the retrieved message to the callback function before passing    *)
(*           the message to the destination.                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* nCode          Process code                                                *)
(* wParam         Undefined (not used)                                        *)
(* lParam         Address of structure with message data                      *)
(*============================================================================*)
PROCEDURE [WINDOWS] WhGetMessageProc*(nCode  : INTEGER; 
                                      wParam : W.WORD; 
                                      lParam : W.DWORD) : W.LRESULT;
VAR
  rl       : W.LRESULT;                    (* Some auxiliary                  *)
  rb       : BOOLEAN;                      (* return values                   *)
  lpfhHook : W.FARPROC;                    (* Proc instance of hook function  *)
  str      : ARRAY LINE_LENGTH OF CHAR;    (* String to hold output           *)
   
BEGIN
  str := "";
  
  (*-- Skip this message -----------------*)
  IF nCode < 0 THEN                        
    lpfhHook := F.GetHandle(W.WH_GETMESSAGE);
    rl := W.DefHookProc(nCode, wParam, lParam, SYSTEM.ADR(lpfhHook))

  (*-- Decode and print this message -----*) 
  ELSIF D.GetMsgProc(hTargetWnd,wParam,lParam,currMsgFlag,str) THEN
    rl := W.lstrcpyn(SYSTEM.ADR(cache[cacheIndex]),
                    SYSTEM.ADR(str),
                    W.lstrlen(SYSTEM.ADR(str))+1); 
    WriteScreen(hLogWnd,str,nLine);

    IF (cacheIndex = CACHE_SIZE-1) & logFile.active THEN
      rb := FlushCache(logFile.startIndex, CACHE_SIZE-1);
      logFile.startIndex := 0;
    END;

    cacheIndex := (cacheIndex + 1) MOD CACHE_SIZE; INC(lineCount);
    IF lineCount = MAX(INTEGER) THEN ClearAll() END;
  END;
  
  RETURN 0;
END WhGetMessageProc;


(*============================================================================*)
(* PURPOSE:  Install or removes Hook-filters depending on param "bInstall",   *)
(*           returns TRUE on success (or on no changes)                       *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* type           Type of windows hook                                        *)
(* bInstall       install (=TRUE) / remove (=FALSE) - switch                  *)
(*============================================================================*)
PROCEDURE InstallFilter*(type : INTEGER; bInstall : BOOLEAN) : BOOLEAN; 

BEGIN
  ASSERT((type >= W.WH_JOURNALRECORD) & (type <= W.WH_SHELL)); 
  IF ~F.GetState(type) & bInstall THEN     (* Install filter                  *) 
    RETURN F.InsertFilter(type)
  ELSIF F.GetState(type) & ~bInstall THEN 
    RETURN F.RemoveFilter(type);           (* Remove filter                   *)
  ELSE
    RETURN TRUE                            (* No changes to do                *)
  END
END InstallFilter;


(*============================================================================*)
(* PURPOSE:  Moves viewer according to current size of client area.           *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* hWnd           Window handle                                               *)
(*============================================================================*)
PROCEDURE MoveViewer(hWnd : W.HWND);
VAR
  hWndParent : W.HWND;                     (* Handle to parent window         *)
  rect       : W.RECT;                     (* Windows rectangle structure     *)
  rb         : W.BOOL;                     (* Aux. return value               *)
  
BEGIN
  hWndParent := W.GetParent(hWnd);
  W.GetClientRect(hWndParent, SYSTEM.ADR(rect));
  rb := W.MoveWindow(hWnd, 
                     rect.left, 
                     rect.top, 
                     rect.right - rect.left, 
                     rect.bottom - bottomSpace, 
                     W.true);
END MoveViewer;  


(*============================================================================*)
(* PURPOSE:  Handles WM_PAINT message                                         *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* hWnd           Window handle                                               *)
(*============================================================================*)
PROCEDURE PaintWndProc(hWnd : W.HWND);
VAR
  hDC,                                     (* handle to device context        *)
  hDCMem : W.HDC;                          (* handle to mem. device context   *)
  hBmp,                                    (* current bitmap handle           *)
  hBmpOld, hFontOld : W.HBITMAP;           (* previous bitmap handle          *)
  done   : W.HGDIOBJ;
  ps     : W.PAINTSTRUCT;
  rect   : W.RECT;                         (* windows rectangle structure     *)
  startPos,
  endPos,
  i, r,
  x, y     : INTEGER;                      (* screen position of text output  *)
  s : ARRAY LINE_LENGTH OF CHAR;
   

BEGIN
  hDC := W.BeginPaint(hWnd, SYSTEM.ADR(ps));
  rect.top := 0; rect.left := 0; rect.bottom := cyClient; rect.right := cxClient;

  (*-- Prepare bitmap --*)
  hDCMem := W.CreateCompatibleDC(hDC);
  hBmp := W.CreateCompatibleBitmap(hDC,rect.right,rect.bottom);

  (*-- Redraw screen --*) 
  IF (hDCMem # W.NULL) & (hBmp # W.NULL) & (rect.bottom DIV cyChar > 0) THEN 
    hBmpOld := W.SelectObject(hDCMem, hBmp);
    hFontOld := W.SelectObject(hDCMem, hFont);
    r := W.FillRect(hDCMem, SYSTEM.ADR(rect), W.GetStockObject(W.WHITE_BRUSH));
   
    startPos := MaxInt(0, vScrollPos + rect.top DIV cyChar);
    endPos :=   MinInt(MaxInt(0,lineCount-1), vScrollPos + (rect.bottom DIV cyChar) -1);
    FOR i := startPos TO endPos DO
      x := rect.left+cxChar; y := (i - startPos) * cyChar; s := ""; 
      Strings.Copy(cache[i MOD CACHE_SIZE], s, hScrollPos+1, Strings.Length(cache[i MOD CACHE_SIZE]));
      r := W.TextOut(hDCMem, x, y, SYSTEM.ADR(s), SHORT(Strings.Length(s)));
    END;
  
    r := W.BitBlt(hDC,    rect.left,  rect.top,
                          rect.right, (rect.bottom DIV cyChar) * cyChar,
                  hDCMem, rect.left,  rect.top, W.SRCCOPY); 
  END;
  
  (*-- Cleanup --*) 
  done := W.SelectObject(hDCMem, hFontOld);
  IF (W.SelectObject(hDCMem,hBmpOld) # W.NULL) THEN r := W.DeleteObject(hBmp) END;
  IF (hDCMem # W.NULL) THEN r := W.DeleteDC(hDCMem) END;
  r := W.ReleaseDC(hWnd, hDC); 

  W.EndPaint(hWnd, SYSTEM.ADR(ps));
END PaintWndProc;


(*============================================================================*)
(* PURPOSE:  WinMsgProc is the window function for this viewer.               *)
(*           It handles all messages sent to this class.                      *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* hWnd           window handle                                               *)
(* msg            message sent to the window                                  *)
(* wParam         first parameter of the message                              *)
(* lParam         second parameter                                            *)
(*============================================================================*) 
PROCEDURE [WINDOWS] MonitorProc*(hWnd: W.HWND; 
                                 msg: W.WORD; 
                                 wParam: W.WPARAM; 
                                 lParam: W.LPARAM): LONGINT;

VAR
  hDC        : W.HDC;
  hObj,
  hFontOld, 
  done       : W.HGDIOBJ;
  hPen       : W.HPEN; 
  ps         : W.PAINTSTRUCT;
  tm         : W.TEXTMETRIC;
  prevBkMode,
  r,
  i,
  vScrollInc,
  hScrollInc : INTEGER;
 
BEGIN
  (*-- Message: create attempt, init common values ---------------------------*)
  IF msg = W.WM_CREATE THEN
    hLogWnd := W.NULL; hTargetWnd := W.NULL;
    nLine := 0;       
    bottomSpace := 25; 
    currMsgFlag := 0; 
    cacheIndex := 0; 
    lineCount := 0;
    logFile.active := FALSE;

    vScrollMax := 0; vScrollPos := 0;
    hScrollMax := 0; hScrollPos := 0;
  
    NEW(cache,CACHE_SIZE); ASSERT(cache # NIL);
    FOR i := 0 TO CACHE_SIZE-1 DO
      cache[i] := "";
    END;
 
    
    hDC := W.GetDC(hWnd); ASSERT(hDC # W.NULL); 
      prevBkMode := W.SetBkMode(hDC, W.TRANSPARENT);
      hFontOld := W.SelectObject(hDC, hFont); 
        r := W.GetTextMetrics(hDC, SYSTEM.ADR(tm)); 
        cxChar := tm.tmAveCharWidth; ASSERT(cxChar # 0);    
        cyChar := tm.tmHeight + tm.tmExternalLeading; ASSERT(cyChar # 0);
      done := W.SelectObject(hDC, hFontOld);  
    r := W.ReleaseDC(hWnd, hDC); 
    
    RETURN 0;

  (*-- Destroy attempt from parent window ------------------------------------*)
  ELSIF msg = W.WM_DESTROY THEN
    DISPOSE(cache); cache := NIL;
    RETURN 0;

  (*-- Handle resize message -------------------------------------------------*) 
  ELSIF (msg = W.WM_SIZE) THEN
    cxClient := Utils.LoWord(lParam);
    cyClient := Utils.HiWord(lParam);
    
    (*-- Calc upper bound of vert. scrolling range, fitting in window --*)
    vScrollMax := MaxInt(0,lineCount - (cyClient DIV cyChar));
    vScrollPos := MinInt(vScrollPos, vScrollMax);

    (*-- Set vert. scrollbar to current position --*) 
    W.SetScrollRange(hWnd, W.SB_VERT, 0, MaxInt(1,vScrollMax), W.false);
    r := W.SetScrollPos(hWnd, W.SB_VERT, vScrollPos, W.false);   

    (*-- Calc upper bound of horiz. scrolling range, fitting in window --*)
    hScrollMax := MaxInt(0, LINE_LENGTH - (cxClient DIV cxChar));
    hScrollPos := MinInt(hScrollPos, hScrollMax);

    (*-- Set horiz. scrollbar to current position --*) 
    W.SetScrollRange(hWnd, W.SB_HORZ, 0, MaxInt(1,hScrollMax), W.false);
    r := W.SetScrollPos(hWnd, W.SB_HORZ, hScrollPos, W.false);   

    (*-- Move viewer to new position --*)
    MoveViewer(hWnd);
    W.InvalidateRect(hWnd, W.NULL, W.false);
    RETURN 0;

  (*-- Vertical scrollbar hit ------------------------------------------------*)
  ELSIF msg = W.WM_VSCROLL THEN
  
    (*-- Recalc vert. scrollbar properties --*)
    vScrollMax := MaxInt(0,lineCount - (cyClient DIV cyChar));
    vScrollPos := MinInt(vScrollPos, vScrollMax);
    W.SetScrollRange(hWnd, W.SB_VERT, 0, MaxInt(1,vScrollMax), W.false);
  
    IF wParam = W.SB_TOP THEN
      vScrollInc := -vScrollPos; 

    ELSIF wParam = W.SB_BOTTOM THEN
      vScrollInc := vScrollMax - vScrollPos; 
      
    ELSIF wParam = W.SB_LINEUP THEN
      vScrollInc := -1; 
      
    ELSIF wParam = W.SB_LINEDOWN THEN
      r := W.SetScrollPos(hWnd, W.SB_VERT, vScrollPos, W.true);
      vScrollInc := 1; 
      
    ELSIF wParam = W.SB_PAGEUP THEN
      vScrollInc := MinInt(-1, -cyClient DIV cyChar);

    ELSIF wParam = W.SB_PAGEDOWN THEN
      vScrollInc := MaxInt(1, cyClient DIV cyChar);
       
    ELSIF wParam = W.SB_THUMBTRACK THEN
      vScrollInc := Utils.LoWord(lParam) - vScrollPos;
      
    ELSE   
      vScrollInc := 0;
    END;
    
    (*-- Calc scrolling amount --*)
    vScrollInc := MaxInt(-vScrollPos, MinInt(vScrollInc, vScrollMax - vScrollPos));
    
    (*-- Set scrollbar to new position --*)
    IF (vScrollInc # 0) THEN
      vScrollPos := vScrollPos + vScrollInc;
      r := W.SetScrollPos(hWnd, W.SB_VERT, MaxInt(0,vScrollPos), W.true);
      W.InvalidateRect(hWnd, W.NULL, W.false);
      W.UpdateWindow(hWnd);
    END;
    RETURN 0;


  (*-- Horizontal scrollbar hit ----------------------------------------------*)
  ELSIF msg = W.WM_HSCROLL THEN
    hScrollMax := MaxInt(0, LINE_LENGTH - (cxClient DIV cxChar));
    W.SetScrollRange(hWnd, W.SB_HORZ, 0, MaxInt(1,hScrollMax), W.false);

    IF wParam = W.SB_LINEUP THEN
      hScrollInc := -1; 
      
    ELSIF wParam = W.SB_LINEDOWN THEN
      hScrollInc := 1; 
      
    ELSIF wParam = W.SB_PAGEUP THEN
      hScrollInc := -10;

    ELSIF wParam = W.SB_PAGEDOWN THEN
      hScrollInc := 10;
       
    ELSIF wParam = W.SB_THUMBTRACK THEN
      hScrollInc := Utils.LoWord(lParam) - hScrollPos;
      
    ELSE   
      hScrollInc := 0;
    END;
    
    (*-- Calc scrolling amount --*)
    hScrollInc := MaxInt(-hScrollPos, MinInt(hScrollInc, hScrollMax - hScrollPos));
    
    (*-- Set scrollbar to new position --*)
    IF (hScrollInc # 0) THEN
      hScrollPos := hScrollPos + hScrollInc;
      r := W.SetScrollPos(hWnd, W.SB_HORZ, MaxInt(0,hScrollPos), W.true);
      W.InvalidateRect(hWnd, W.NULL, W.false);
      W.UpdateWindow(hWnd);
    END;
    RETURN 0;
 
  (*-- Handle paint message --------------------------------------------------*) 
  ELSIF msg = W.WM_PAINT THEN
    PaintWndProc(hWnd);
    RETURN 0;

  (*-- Didn't process message ------------------------------------------------*)
  ELSE
    RETURN W.DefWindowProc(hWnd, msg, wParam, lParam) 
  END;
END MonitorProc;


(*============================================================================*)
(* PURPOSE:  Creates a viewer, where the output goes to.                      *)
(*           It handles all messages sent to this class.                      *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* hWndParent     window handle of parent window                              *)
(* hInstance      handle of the module which wants to create the viewer       *)
(*============================================================================*) 
PROCEDURE [WINDOWS] CreateViewer*(hWndParent: W.HWND; 
                                  hInstance:  W.HINSTANCE): W.HWND;

VAR
  hWnd: W.HWND;
    
BEGIN
  (*-- Create window --*)
  hWnd := W.CreateWindow(SYSTEM.ADR(ClassName), 
                         W.NULL,
                         W.WS_CHILDWINDOW + W.WS_CAPTION + W.WS_BORDER + 
                         W.WS_VISIBLE + W.WS_VSCROLL + W.WS_HSCROLL,
                         0,
                         0,
                         0,
                         0,
                         hWndParent, 
                         W.NULL, 
                         hInstance, 
                         W.NULL);
  hLogWnd := hWnd;
  RETURN hWnd;
END CreateViewer;


(*============================================================================*)
(* PURPOSE:  LibMain is the initialization function of this dynamic link      *)
(*           library. It's automatically called by Windows when DLL is loaded.*)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* hInstCurr      instance handle for this DLL                                *)
(* wDataSeg       data segment for this DLL                                   *)
(* cbHeapSize     heap size                                                   *)
(* lpszCmdLine    command line (pointer to a null terminated string)          *)
(*============================================================================*)
PROCEDURE [WINDOWS] LibMain* (hInstCurr:   W.HANDLE; 
                              wDataSeg:    INTEGER; 
                              cbHeapSize:  INTEGER; 
                              lpszCmdLine: LONGINT): INTEGER;
VAR
  wc:  W.WNDCLASS; 
  WhProc : WhProcT;
  ok : BOOLEAN;
  r : INTEGER;
  
BEGIN
  hInstance := hInstCurr; 

  (*-- Fill window class structure --*)
  wc.style         := W.CS_GLOBALCLASS + W.CS_CLASSDC;
  wc.lpfnWndProc   := MonitorProc; 
  wc.cbClsExtra    := 0;                     
  wc.cbWndExtra    := 4;                     
  wc.hInstance     := hInstCurr;
  wc.hIcon         := W.NULL;
  wc.hCursor       := W.LoadCursor(W.NULL, W.IDC_ARROW);
  wc.hbrBackground := W.GetStockObject(W.WHITE_BRUSH);
  
  wc.lpszMenuName  := W.NULL;
  wc.lpszClassName := SYSTEM.ADR(ClassName);

  (*-- Register this viewer class --*)
  IF W.RegisterClass(SYSTEM.ADR(wc)) = 0 THEN
    MsgBox("Could not register viewer class !","ERROR: EmDll.WEP");
    RETURN 0;
  END;     
  
  (*-- Create font output --*)
  hFont := W.CreateFont
           (-12, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, SYSTEM.ADR("MS Sans Serif")); 
  IF hFont = W.NULL THEN
    MsgBox("Could not create font !","ERROR: EmDll.LibMain");          
    RETURN 0;
  END;     
 
  (*-- Register all available filter functions --*)
  WhProc := WhCallWndProc; 
  ok := F.RegisterFilter(W.WH_CALLWNDPROC,SYSTEM.VAL(W.FARPROC, WhProc));
  IF ~ok THEN
    MsgBox("Init filter WH_CALLWNDPROC failed !","ERROR: EmDll.LibMain");
  END;      

  WhProc := WhGetMessageProc; 
  ok := F.RegisterFilter(W.WH_GETMESSAGE,SYSTEM.VAL(W.FARPROC, WhProc)); 
  IF ~ok THEN
    MsgBox("Init filter WH_GETMESSAGE failed !","ERROR: EmDll.LibMain");
  END;      

  RETURN 1;
END LibMain;

 
(*============================================================================*)
(* PURPOSE:  WEP is the exit function of this DLL, which is automatically     *)
(*           called by Windows when this DLL is unloaded.                     *)
(* COMMENTS:                                                                  *)
(*============================================================================*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* nSystemExit    type of exit                                                *)
(*============================================================================*)
PROCEDURE [WINDOWS] WEP*(nSystemExit : INTEGER) : INTEGER;
VAR 
  r : W.BOOL;                              (* return value                    *)

BEGIN
  (*-- Unregister window class --*)
  IF W.UnregisterClass(SYSTEM.ADR(ClassName), hInstance) = 0 THEN
    MsgBox("Could not unregister class !","ERROR: EmDll.WEP");
  END;
 
  (*-- Delete font --*)
  IF W.DeleteObject(hFont) = 0 THEN
    MsgBox("Could not delete font !","ERROR: EmDll.WEP");
  END; 
  
  RETURN 1;
END WEP;

END EmDll.
