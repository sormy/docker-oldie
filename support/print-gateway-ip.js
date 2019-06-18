// Outputs current gateway ip address.
// Usage: cscript.exe /nologo print-gateway-ip.js

var wmiService = GetObject("winmgmts:\\\\.\\root\\cimv2");

// https://docs.microsoft.com/en-us/windows/desktop/cimwin32prov/win32-networkadapterconfiguration
var items = wmiService.ExecQuery(
  "select * from Win32_NetworkAdapterConfiguration where IPEnabled=1"
);

var enumItems = new Enumerator(items);

var item = enumItems.item();

try {
  WScript.Echo(item.DefaultIPGateway.toArray()[0]);
} catch (e) {}
