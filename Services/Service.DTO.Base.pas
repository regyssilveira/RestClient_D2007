unit Service.DTO.Base;

interface

uses
  SysUtils, Classes, Contnrs, TypInfo, SuperObject;

type
  {$M+}
  TJsonDTO = class(TInterfacedObject)
  public
    function GetItemClass(const APropName: string): TClass; virtual;
    procedure FromJson(AJson: ISuperObject); virtual;
  end;
  {$M-}

implementation

{ TJsonDTO }

procedure TJsonDTO.FromJson(AJson: ISuperObject);
var
  LPropCount, I: Integer;
  LPropList: PPropList;
  LPropInfo: PPropInfo;
  LJsonVal: ISuperObject;
  LPropName, LJsonName: string;
  LObj: TObject;
  LList: TObjectList;
  LItemClass: TClass;
  LArray: ISuperArray;
  LItem: TJsonDTO;
  J: Integer;
begin
  if AJson = nil then
    Exit;

  LPropCount := GetPropList(Self.ClassInfo, tkProperties, nil);
  if LPropCount > 0 then
  begin
    GetMem(LPropList, LPropCount * SizeOf(PPropInfo));
    try
      GetPropList(Self.ClassInfo, tkProperties, LPropList);
      for I := 0 to LPropCount - 1 do
      begin
        LPropInfo := LPropList^[I];
        LPropName := string(LPropInfo^.Name);

        // Try exact match first
        LJsonVal := AJson.O[LPropName];
        
        // If not found, try camelCase (common convention: AccountNumber -> accountNumber)
        if LJsonVal = nil then
        begin
          if Length(LPropName) > 0 then
          begin
            LJsonName := LowerCase(Copy(LPropName, 1, 1)) + Copy(LPropName, 2, Length(LPropName));
            LJsonVal := AJson.O[LJsonName];
          end;
        end;

        if LJsonVal = nil then Continue;

        case LPropInfo^.PropType^.Kind of
          tkInteger, tkInt64:
            begin
              SetOrdProp(Self, LPropInfo, LJsonVal.AsInteger);
            end;

          tkFloat:
            begin
              if LJsonVal.DataType = stString then
              begin
                if (Length(LJsonVal.AsString) = 10) and (LJsonVal.AsString[5] = '-') then
                begin
                  try
                    SetFloatProp(Self, LPropInfo, EncodeDate(StrToInt(Copy(LJsonVal.AsString, 1, 4)), StrToInt(Copy(LJsonVal.AsString, 6, 2)), StrToInt(Copy(LJsonVal.AsString, 9, 2))));
                  except
                    SetFloatProp(Self, LPropInfo, 0.0);
                  end;
                end
                else
                  SetFloatProp(Self, LPropInfo, StrToFloatDef(StringReplace(LJsonVal.AsString, '.', DecimalSeparator, [rfReplaceAll]), 0.0));
              end
              else
                SetFloatProp(Self, LPropInfo, LJsonVal.AsDouble);
            end;

          tkString, tkLString, tkWString:
            begin
              SetStrProp(Self, LPropInfo, LJsonVal.AsString);
            end;

          tkEnumeration:
            begin
              if GetTypeData(LPropInfo^.PropType^)^.BaseType^ = TypeInfo(Boolean) then
                SetOrdProp(Self, LPropInfo, Integer(LJsonVal.AsBoolean));
            end;

          tkClass:
            begin
              LObj := GetObjectProp(Self, LPropInfo);
              if LObj <> nil then
              begin
                if (LObj is TObjectList) and (LJsonVal.DataType = stArray) then
                begin
                  LList := TObjectList(LObj);
                  LList.Clear;
                  LItemClass := GetItemClass(LPropName);
                  // DEBUG
                  // WriteLn('Property: ', LPropName, ', ItemClass: ', Pointer(LItemClass)); 
                  if (LItemClass <> nil) and LItemClass.InheritsFrom(TJsonDTO) then
                  begin
                    LArray := LJsonVal.AsArray;
                    for J := 0 to LArray.Length - 1 do
                    begin
                      LItem := TJsonDTO(LItemClass.Create);
                      LItem.FromJson(LArray.O[J]);
                      LList.Add(LItem);
                    end;
                  end;
                end
                else if LObj.InheritsFrom(TJsonDTO) then
                begin
                   TJsonDTO(LObj).FromJson(LJsonVal);
                end;
              end;
            end;
        end;
      end;
    finally
      FreeMem(LPropList);
    end;
  end;
end;

function TJsonDTO.GetItemClass(const APropName: string): TClass;
begin
  Result := nil;
end;

end.
