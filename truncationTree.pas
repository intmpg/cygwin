Procedure truncationTree(t:ukaz);
VAR
  temp: ukaz;
  min, max, alim, lim, sumMin: integer;
  fatherType: STRING;
Begin
  if t <> nil
  then
    begin
      temp := t^.left;
      if (t^.TypeUzel = 'and')
      then
        begin
          sumMin := 0;
          while temp^.right <> nil
          do
            begin
              sumMin := sumMin + temp^.WeightUzelMin;
              temp := temp^.right;
            end;
          temp := t^.left;
          while temp^.right <> nil
          do
            begin
              temp^.limit := t^.limit - ( sumMin - temp^.WeightUzelMin );
              temp := temp^.right;
            end;  
        end;
      if (t^.TypeUzel = 'or')
      then
        begin
          while temp^.right <> nil
          do
            begin
              temp^.limit := t^.limit;
              temp := temp^.right;
            end;  
        end;
      temp := t^.left;
      while temp^.right <> nil
      do
        begin
          if temp^.limit > temp^.WeightUzelMin
          then
            temp^.Zapret := false
          else
            temp^.Zapret := true;
          temp := temp^.right;
        end;
    end;
  truncationTree(t^.left);
  truncationTree(t^.right);
end;

Procedure truncationTree(t:ukaz);
VAR
  son, father: ukaz;
  min, max, alim, lim, sumMin: integer;
  fatherType: STRING;
Begin
  if t <> nil
  then
    if t^.urov > 0
    then
      begin
        father := t^.fath;
        lim := father^.limit;
        fatherType := father^.TypeUzel;
        writeln('fatherName: ', father^.name, '   lim:', lim, '   fatherType:', fatherType);
        if fatherType = 'or'
        then 
          t^.limit := lim;
        if fatherType = 'and'
        then
          begin
            son := father^.left;
            sumMin := 0;
            while son^.right <> nil
            do
              begin
                sumMin := sumMin + son^.WeightUzelMin;
                son := son^.right;
              end;
            t^.limit := lim - ( sumMin - t^.WeightUzelMin );
          end;
        if t^.limit > t^.WeightUzelMin
        then
          t^.Zapret := false
        else
          t^.Zapret := true;
      end;
  truncationTree(t^.left);
  truncationTree(t^.right);
end;