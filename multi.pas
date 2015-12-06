if t<>nil
  then
    Begin
      if t^.left<>nil
      then
        if t^.TypeUzel='and'
        then 
          begin
            kon:=t^.left;
            While kon<>nil
            doif 
              begin
                writeln(t^.TypeUzel,':', kon^.TypeUzel);
                if kon^.TypeUzel = 'leaf'
                then
                  begin
                    if Limit < t^.WeightUzelMin
                    then
                      begin
                        kon^.Zapret := True;
                        t^.Zapret := true;
                      end  
                    else  
                      kon^.Zapret := False;
                    writeln(kon^.name,':',kon^.Zapret);  
                  end
                else
                  begin
                    Limit := Limit - (t^.WeightUzelMin - kon^.WeightUzelMin);
                    writeln('test', Limit,':', kon^.name );
                    truncationTree(kon, Limit);
                    truncationTree(t^.right, Limit);
                  end;
                kon:=kon^.right
              end;
          end
        else 
          if t^.TypeUzel='or'
          then
            begin
              kon:=t^.left;
                While kon<>nil
                do
                  begin
                    writeln(kon^.TypeUzel);
                    if kon^.TypeUzel = 'leaf'
                    then
                      begin
                        if Limit < kon^.WeightUzelMin
                        then
                          kon^.Zapret := True
                        else  
                          kon^.Zapret := False;
                        writeln(kon^.name,':',kon^.Zapret);  
                      end
                    else
                      begin
                        writeln('test', Limit,':', kon^.name );
                        truncationTree(kon, Limit);
                      end;  
                    kon:=kon^.right
                  end;
            end;
    end