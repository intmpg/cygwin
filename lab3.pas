TYPE
  Pointer = ^Node;
  Node = RECORD
         name, N_Type: STRING;    
         left, right, fath: Pointer; 
         urov, MinVes, MaxVes, limit: INTEGER;  
         Flag, Flag2: BOOLEAN;  
         END;
VAR
  kon, key, t, p: Pointer;
  Value, VesV, Ending, k, m, Len, Limiter: INTEGER;
  S, R, NodeType: STRING;
  input_file, output_file: TEXT;
  
PROCEDURE Vershin(t:Pointer);  
VAR
  min, max: integer;
BEGIN
  IF NOT (t = nil)
  THEN
    BEGIN
      Vershin(t^.left);
      Vershin(t^.right);
      IF NOT (t^.left = nil)
      THEN 
        IF (t^.N_Type = 'and')
        THEN
          BEGIN
            kon:= t^.left;
            REPEAT
              t^.MaxVes:= t^.MaxVes + kon^.MaxVes;
              t^.MinVes:= t^.MinVes + kon^.MinVes;
              kon:= kon^.right
            UNTIL kon = nil
          END
        ELSE 
          IF t^.N_Type = 'or' 
          THEN
          BEGIN
            t^.MinVes:= 0;
            t^.MaxVes:= 0;
            kon:= t^.left;
            min:= 65000;  // сортировка
            max:= -1; 
            REPEAT 
              IF kon^.MinVes<min
              THEN
              BEGIN
                min:= kon^.MinVes;
              END;
              IF kon^.MaxVes>max
              THEN
              BEGIN
                max:= kon^.MaxVes;
              END;
                kon:= kon^.right  
            UNTIL kon = nil;
            t^.MinVes:= min;
            t^.MaxVes:= max;
          END;
    END
END;

PROCEDURE multiplications(t:Pointer);
VAR
  temp: Pointer;
  sumMin: integer;
BEGIN
  IF NOT (t = nil)
  THEN
  BEGIN
    IF (t^.N_Type = 'and')
    THEN
    BEGIN
      temp:= t^.left;
      sumMin:= 0;
      WHILE temp <> nil
      DO
        BEGIN
          sumMin:= sumMin + temp^.MinVes;
          temp:= temp^.right;
        END;
      temp:= t^.left;
      WHILE temp <> nil
      DO
        BEGIN
          temp^.limit:= t^.limit - ( sumMin - temp^.MinVes );
          temp:= temp^.right; 
        END;
    END;
    IF (t^.N_Type = 'or')
    THEN
    BEGIN
      temp:= t^.left;
      WHILE temp <> nil
      DO
        BEGIN 
          temp^.limit:= t^.limit;
          temp:= temp^.right;
        END;
    END;
    IF NOT (t^.left = nil)
    THEN 
    BEGIN 
      temp := t^.left;
      REPEAT
        IF temp^.limit >= temp^.MinVes
        THEN
          temp^.Flag2:= FALSE
        ELSE
          temp^.Flag2:= TRUE;
        temp := temp^.right;
      UNTIL temp = nil;
    END;
      multiplications(t^.left);
      multiplications(t^.right);
    END; 
END;

PROCEDURE ReadInputFile();
VAR i:INTEGER;
BEGIN
  WHILE NOT Eof(input_file) 
  DO
  BEGIN
    READLN(input_file, S);
    k:= 0;
    NEW(kon);
    Len:= LENGTH(S);
    BEGIN
      Value:= POS(' ', S);
      NodeType:= S;
      DELETE(S, Value, Len-Value+1);
      DELETE(NodeType, 1, Value);
      IF ((NodeType = 'and') OR (NodeType = 'or'))
      THEN
      BEGIN
        kon^.N_Type:= NodeType;
        kon^.MinVes:= 0;
        kon^.MaxVes:= 0;
      END
      ELSE
      BEGIN
        kon^.N_Type:= 'leaf';
        Val(NodeType, VesV, Ending);
        kon^.MinVes:= VesV;
        kon^.MaxVes:= VesV;
      END;
    END;    
    WHILE S[k + 1]= '.' 
    DO 
      k:= k + 1;
    R:= COPY(S, k + 1 ,Len - k);        
    kon^.name:= R;
    kon^.left:= nil;
    kon^.right:= nil;
    kon^.urov:= k;
    kon^.limit:= 0;
    IF k > m 
    THEN
    BEGIN
      t^.left:= kon;
      kon^.fath:= t;
      kon^.Flag:= TRUE;      
    END
    ELSE
    IF (k = m) 
    THEN
    BEGIN
      t^.right:= kon;
      kon^.fath:= t^.fath; 
      t^.Flag:= FALSE;     
      kon^.Flag:= TRUE;   
    END
    ELSE                   
    BEGIN
      p:= t;
      FOR i:= 1 TO m - k 
      DO
      BEGIN
        p:=p^.fath;
      END;
      kon^.fath:= p^.fath;
      p^.right:= kon;
      p^.Flag:= FALSE;    
      kon^.Flag:= TRUE;   
    END;
    m:= k;     
    t:= kon;    
  END;          
END;

PROCEDURE OutputVes(t:Pointer);  
Var
  j: integer;
  St, str1: string;  
BEGIN
  IF NOT (t = nil)
  THEN
  BEGIN
    IF NOT t^.Flag2
    THEN
    BEGIN
      St:=t^.name;
      IF (t^.N_Type = 'leaf')
        THEN
        BEGIN
          Str(t^.MinVes, str1);
          St:= St+' - '+str1;
        END  
        ELSE
        BEGIN
          Str(t^.MinVes, str1);
          St:= St + ' - ' + t^.N_Type + '( '+ str1 + ','; //вывод соотношения
          Str(t^.MaxVes, str1);
          St:= St + str1 + ') ';
        END;  
      p:=t;
      FOR j:= 0 TO t^.urov - 1 
      DO
      BEGIN
        IF t^.urov > 0
        THEN
          St:='.' + St;  
      END;
     WRITELN(output_file, St);
     WRITELN(St);
     END;
    IF NOT(t^.Flag2)
    THEN          
      OutputVes(t^.left);
      OutputVes(t^.right);
  END
END;  

BEGIN
    WRITE('Введите имя входного файла:');
    READLN(S);
    IF NOT FileExists(S) 
    THEN 
      WRITELN('Такого файла не существует')
    ELSE
      BEGIN
        ASSIGN(input_file, S);
        WRITE('Введите имя выходного файла:');
        READLN(S);  
        ASSIGN(output_file, S);
        RESET(input_file);
        NEW(key);
        READLN(input_file, S);
        Len:= LENGTH(S);
        Value:= POS(' ', S);
        NodeType:= S;
        DELETE(S, Value, Len - Value + 1);
        DELETE(NodeType, 1, Value);
        IF (NodeType = 'and') OR (NodeType = 'or')
        THEN
        BEGIN
          key^.N_Type := NodeType;
          key^.MinVes:= 0;
          key^.MaxVes:= 0;
        END
        ELSE
        BEGIN
          key^.N_Type:= 'leaf';
          Val(NodeType, VesV, Ending);
          key^.MinVes:= VesV;
          key^.MaxVes:= VesV;
        END;
      END;
    key^.name:= S;
    key^.urov:= 0;
    key^.Flag:= TRUE; 
    key^.fath:= nil; 
    m:= 0;             
    t:= key;          
    ReadInputFile;
    CLOSE(input_file);
    REWRITE(output_file);
    Vershin(key);
    OutputVes(key);
    WRITELN('Введите вес');
    READLN(Limiter);
    IF ((Limiter < key^.MinVes) or (Limiter > key^.MaxVes))
    THEN
      WRITELN('Вес не соответствует допустимым значениям')
    ELSE
    BEGIN
      key^.limit:= Limiter;
      multiplications(key);
      writeln('РЕЗУЛЬТАТ:');
      OutputVes(key); 
    END;  
    CLOSE(output_file);
END.