@set RUBYOPT=-Isrc -Ku
@set PATH=%PATH%;etc\tools
@doskey e_u=echo :e_utf8
@doskey e_s=echo :e_sjis
@perl scripts/utf8_cmd.pm C:\WINDOWS\system32\cmd.exe /K ""C:\gnu\bin\set_gnuwin32.bat" -s gnuwin32 -l EN"