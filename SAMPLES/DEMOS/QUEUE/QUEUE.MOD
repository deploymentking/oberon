MODULE Queue;


  CONST
    QLen = 5;

  TYPE
    Q* = POINTER TO QDesc;
    QDesc = RECORD
      elem: ARRAY QLen OF INTEGER;
      head: INTEGER; 
      tail: INTEGER;
    END;


PROCEDURE (q: Q) Init*();
BEGIN
  q.head := 0;
  q.tail := 0;
END Init;


PROCEDURE (q: Q) Add*(x: INTEGER): BOOLEAN;
BEGIN
  IF q.head # (q.tail + 1) MOD QLen THEN  (* not full *)
    q.elem[q.tail] := x;
    q.tail := (q.tail + 1) MOD QLen;
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END;
END Add;


PROCEDURE (q: Q) Del*(VAR x: INTEGER): BOOLEAN;
BEGIN
  IF q.head # q.tail THEN (* is not empty *)
    x := q.elem[q.head];
    q.head := (q.head + 1) MOD QLen;
    RETURN TRUE;
  ELSE
    x := 0;
    RETURN FALSE;
  END;
END Del;



(******************************************************************************
 *
 * FUNCTION:
 * LibMain is the initialization function of this dynamic link library. It is
 * automatically called by Windows when this DLL is loaded.
 *
 * PRECONDITIONS:  --
 *
 * POSTCONDITIONS: --
 *
 ******************************************************************************
 * PARAMETER      DESCRIPTION
 * -------------- -------------------------------------------------------------
 * hInstCurr      instance handle for this DLL
 * wDataSeg       data segment for this DLL
 * cbHeapSize     heap size 
 * lpszCmdLine    command line (pointer to a null terminated string)
 ******************************************************************************)
PROCEDURE [WINDOWS] LibMain* (hInstCurr:   INTEGER; 
                              wDataSeg:    INTEGER; 
                              cbHeapSize:  INTEGER; 
                              lpszCmdLine: LONGINT): INTEGER;

BEGIN
  RETURN 1;
END LibMain;


END Queue.