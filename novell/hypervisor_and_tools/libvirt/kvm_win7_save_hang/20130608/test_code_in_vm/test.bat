
:loop
    start main.exe
    ping 127.0.0.1 -n 8 > null
    goto :loop