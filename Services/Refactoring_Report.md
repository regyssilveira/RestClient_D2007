# Refactoring Report

I have analyzed the provided files and implemented several optimizations and improvements.

## Changes

### 1. `Service.DTO.Base.pas` - Optimization
Refactored `FromJson` method in `TJsonDTO` to improve performance and robustness.
- **Before:** Iterated over every key in the JSON object and looked up the corresponding property in the class. This is inefficient if the JSON payload contains many fields not present in the DTO.
- **After:** Iterates over the class properties first, then looks up the value in the JSON object.
- **CamelCase Support:** Added support for mapping PascalCase Delphi properties (e.g., `AccountNumber`) to camelCase JSON keys (e.g., `accountNumber`), which is common in REST APIs.

```pascal
// New logic iterates properties and checks JSON
LPropName := string(LPropInfo^.Name);
LJsonVal := AJson.O[LPropName];
if LJsonVal = nil then
begin
  // Fallback to camelCase
  LJsonName := LowerCase(Copy(LPropName, 1, 1)) + Copy(LPropName, 2, MaxInt);
  LJsonVal := AJson.O[LJsonName];
end;
```

### 2. `Service.Transaction.pas` - Refactoring
Refactored `TTransactionService` to reduce code duplication and improve readability.
- **Constants:** Extracted hardcoded URL paths into constants (`RES_BALANCE`, `RES_TRANS_OPERATION`, etc.).
- **Helper Method:** Created `ExecutePost` method to encapsulate the common pattern of:
  1. Creating a POST request.
  2. Executing it.
  3. Verifying HTTP 201 status.
  4. Parsing JSON response.
  5. Verifying internal JSON status field ('CREATED').
  6. Raising formatted exceptions on failure.

This significantly reduced the size and complexity of `Movement` and `Reversal` methods.

### 3. Usage of `ExecutePost`
The `Movement` method now clearly shows the flow of the transaction saga (Operation -> Movement -> Reversal on error) without being cluttered by HTTP request setup code.

## Verification
- Checked that error handling logic in `Movement` (calling `Reversal` on failure) is preserved.
- Verified that resource paths are correct.
- Verified that memory management (via proper interface usage) remains safe.
