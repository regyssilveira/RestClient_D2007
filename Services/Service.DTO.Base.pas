unit Service.DTO.Base;

interface

uses
  SysUtils, Classes, TypInfo, SuperObject;

type
  {$M+}
  TJsonDTO = class(TInterfacedObject)
  public
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
                SetFloatProp(Self, LPropInfo, StrToFloatDef(StringReplace(LJsonVal.AsString, '.', DecimalSeparator, [rfReplaceAll]), 0.0))
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
        end;
      end;
    finally
      FreeMem(LPropList);
    end;
  end;
end;

end.
