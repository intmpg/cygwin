TYPE
  ukaz = ^uzel;
  uzel = RECORD
         name, TypeUzel: STRING;    
         left, right, fath: ukaz; 
         urov, WeightUzelMin, WeightUzelMax, limit: INTEGER;  
         Flag, zapret: BOOLEAN;  
         END;
VAR
  t, kon, root, p: ukaz;
  k, m, Len, PosSpace, LeafWeight, err, Limiter: INTEGER;
  S, R, STypeUzel, NameInputFile, NameOutFile: STRING;
  Fin, Fout: TEXT;
  
PROCEDURE calcWeightVertex(t:ukaz);  
VAR
  min, max: integer;
BEGIN
  IF NOT (t = nil)
  THEN
    BEGIN
      calcWeightVertex(t^.left);
      calcWeightVertex(t^.right);
      IF NOT (t^.left = nil)
      THEN 
        IF (t^.TypeUzel = 'and')
        THEN
          BEGIN
            kon:= t^.left;
            REPEAT
              t^.WeightUzelMax:= t^.WeightUzelMax + kon^.WeightUzelMax;
              t^.WeightUzelMin:= t^.WeightUzelMin + kon^.WeightUzelMin;
              kon:= kon^.right
            UNTIL kon = nil
          END
        ELSE 
          IF t^.TypeUzel = 'or' 
          THEN
          BEGIN
            t^.WeightUzelMin:= 0;
            t^.WeightUzelMax:= 0;
            kon:= t^.left;
            min:= 65000;  // сортировка
            max:= -1; 
            REPEAT 
              IF kon^.WeightUzelMin<min
              THEN
              BEGIN
                min:= kon^.WeightUzelMin;
              END;
              IF kon^.WeightUzelMax>max
              THEN
              BEGIN
                max:= kon^.WeightUzelMax;
              END;
                kon:= kon^.right  
            UNTIL kon = nil;
            t^.WeightUzelMin:= min;
            t^.WeightUzelMax:= max;
          END;
    END
END;

PROCEDURE truncationTree(t:ukaz);
VAR
  temp: ukaz;
  sumMin: integer;
BEGIN
  IF NOT (t = nil)
  THEN
  BEGIN
    IF (t^.TypeUzel = 'and')
    THEN
    BEGIN
      temp:= t^.left;
      sumMin:= 0;
      WHILE temp <> nil
      DO
        BEGIN
          sumMin:= sumMin + temp^.WeightUzelMin;
          temp:= temp^.right;
        END;
      temp:= t^.left;
      WHILE temp <> nil
      DO
        BEGIN
          temp^.limit:= t^.limit - ( sumMin - temp^.WeightUzelMin );
          temp:= temp^.right; 
        END;
    END;
    IF (t^.TypeUzel = 'or')
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
        IF temp^.limit >= temp^.WeightUzelMin
        THEN
          temp^.Zapret:= FALSE
        ELSE
          temp^.Zapret:= TRUE;
        temp := temp^.right;
      UNTIL temp = nil;
    END;
      truncationTree(t^.left);
      truncationTree(t^.right);
    END; 
END;
PROCEDURE ReadInputFile();
VAR i:INTEGER;
BEGIN
  WHILE NOT Eof(Fin) 
  DO
  BEGIN
    READLN(Fin, S);
    k:= 0;
    NEW(kon);
    Len:= LENGTH(S);
    BEGIN
      PosSpace:= POS(' ', S);
      STypeUzel:= S;
      DELETE(S, PosSpace, Len-PosSpace+1);
      DELETE(STypeUzel, 1, PosSpace);
      IF ((STypeUzel = 'and') OR (STypeUzel = 'or'))
      THEN
      BEGIN
        kon^.TypeUzel:= STypeUzel;
        kon^.WeightUzelMin:= 0;
        kon^.WeightUzelMax:= 0;
      END
      ELSE
      BEGIN
        kon^.TypeUzel:= 'leaf';
        Val(STypeUzel, LeafWeight, err);
        kon^.WeightUzelMin:= LeafWeight;
        kon^.WeightUzelMax:= LeafWeight;
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
      t^.right:=kon;
      kon^.fath:=t^.fath; 
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
PROCEDURE PechPr(t:ukaz);  
Var
  j: integer;
  St, str1: string;  
BEGIN
  IF NOT (t = nil)
  THEN
  BEGIN
    IF NOT t^.Zapret
    THEN
    BEGIN
      St:=t^.name;
      IF (t^.TypeUzel = 'leaf')
        THEN
        BEGIN
          Str(t^.WeightUzelMin, str1);
          St:= St+' - '+str1;
        END  
        ELSE
        BEGIN
          Str(t^.WeightUzelMin, str1);
          St:= St + ' - ' + t^.TypeUzel + '( '+ str1 + ','; //вывод соотношения
          Str(t^.WeightUzelMax, str1);
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
     WRITELN(Fout, St);
     WRITELN(St);
     END;
    IF NOT(t^.Zapret)
    THEN          
      PechPr(t^.left);
      PechPr(t^.right);
  END
END;  

BEGIN
    WRITE('Введите имя входного файла:');
    READLN(NameInputFile);
    IF NOT FileExists(NameInputFile) 
    THEN 
      WRITELN('Такого файла не существует')
    ELSE
      BEGIN
        WRITE('Введите имя выходного файла:');
        READLN(NameOutFile);
        ASSIGN(Fin, NameInputFile);  
        ASSIGN(Fout, NameOutFile);
        RESET(Fin);
        NEW(root);
        READLN(Fin, S);
        Len:= LENGTH(S);
        PosSpace:= POS(' ', S);
        STypeUzel:= S;
        DELETE(S, PosSpace, Len - PosSpace + 1);
        DELETE(STypeUzel, 1, PosSpace);
        IF (STypeUzel = 'and') OR (STypeUzel = 'or')
        THEN
        BEGIN
          root^.TypeUzel := STypeUzel;
          root^.WeightUzelMin:= 0;
          root^.WeightUzelMax:= 0;
        END
        ELSE
        BEGIN
          root^.TypeUzel:= 'leaf';
          Val(STypeUzel, LeafWeight, err);
          root^.WeightUzelMin:= LeafWeight;
          root^.WeightUzelMax:= LeafWeight;
        END;
      END;
  root^.name:= S;
  root^.urov:= 0;
  root^.Flag:= TRUE; 
  root^.fath:= nil; 
  m:= 0;             
  t:= root;          
    ReadInputFile;
    CLOSE(Fin);
    REWRITE(Fout);
    calcWeightVertex(root);
    PechPr(root);
    WRITELN('Введите вес');
    READLN(Limiter);
    IF ((Limiter < root^.WeightUzelMin) or (Limiter > root^.WeightUzelMax))
    THEN
      WRITELN('Вес превышает допустимое значение')
    ELSE
    BEGIN
      root^.limit:= Limiter;
      truncationTree(root);
      writeln('РЕЗУЛЬТАТ:');
      PechPr(root); 
    END;  
    CLOSE(Fout);
END.