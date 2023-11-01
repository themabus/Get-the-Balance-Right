# Get-the-Balance-Right
This is 256 line C++ [tinyraytracer](https://github.com/ssloy/tinyraytracer) by Mr. Dmitry V. Sokolov ([ssloy](https://github.com/ssloy)) ported to several higher level game engines.<br>
Some older ones (but still quite popular) and some more recent ones.<br>
![original](original.png)<br>
All projects are made to display execution time in milliseconds, so that performance could be measured.<br>
Operations include: trigonometry, vector math and data structure handling.<br>
It is unoptimized - no lookup tables, no fixed-point, inlining, etc.,<br>
which presents more life-like model and evens out the playing field.<br>
Shaders are not used.<br>
Drawing routines are not timed.<br>
<br>
|engine|time(ms)|size(kb)|open source|
|:---|---:|---:|:---:|
|C++ (original - file output)|350|61|🌝|
|<b>GML|
|Game Maker 6.1 (patched)|251400|1933|🌑|
|Game Maker 7.0|256000|2316|🌑|
|Game Maker 8.0|109000|2341|🌑|
|Game Maker 8.1|113100|4143|🌑|
|Enigma 0.0.5.0|65500|2859|🌝|
|`OpenGMK`|64000|+6709|🌝|
|GameMaker Studio 1.4 (VM)|40900|6409|🌑|
|GameMaker Studio 1.4 (YYC)|7900|6139|🌑|
|GameMaker Studio 1.4 (HTML5)|2600|1127|🌑|
|GameMaker Studio 2.2.5 (VM)|38800|4939|🌑|
|<b>DIV|
|BennuGD r348|15100|4366|🌝|
|PixTudio 2016.12.16|15800|22346|🌝|
|<b>Basic / Basiclike|
|AppGameKit 2023.01.26 (Tier 1)|47900|7632|🌑|
|Blitz3D	1.110|1200|1510|🌝|
|BlitzMax 1.50|600|1571|🌝|
|BlitzMax NG 0.136|980|3794|🌝|
|Monkey-X 87a (GCC)|1800|1636|🌝|
|Monkey-X 87a (HTML5)|750|104|🌝|
|Cerberus-X 2023-05-26 (GCC)|1800|2840|🌝|
|Cerberus-X 2023-05-26 (HTML5)|780|488|🌝|
|Monkey 2 2018.09|740|14622|🌝|
|Wonkey 2022.04|800|16886|🌝|
|<b>Pascal / Delphi|
|ZenGL 0.3.12 (FPC 3.2.2)|690|315|🌝|
|Castle Game Engine 7.0 (FPC 3.2.2)|200|16816|🌝|
|<b>Ruby|
|RPG Maker XP (Ruby 1.8.1)|108000|841|🌑|
|RPG Maker VX (Ruby 1.8.1)|84000|162|🌑|
|RPG Maker VX Ace (Ruby 1.9.2)|18200|1256|🌑|
|`RGDirect 1.5.4`|61500|+1268|🌑|
|`MKXP-Z`|40000|+26849|🌝|
|<b>JavaScript|
|RPG Maker MV 1.6.3 (clean)|2200|165968|🌑|
|<b>Lua|
|Defold 1.6.0 (LuaJIT 2.1.0-b3)|5500|7484|🌔|
|LÖVE 11.4 (LuaJIT 2.1.0-b3)|3700|+love2d|🌝|
|<b>Python / Pythonlike|
|Godot 3.5.3 (GDScript)|5700|38105|🌝|
|Godot 4.1.2 (GDScript)|4700|68727|🌝|
|Pygame 2.5.2 (Python 3.7.2)|4300|+python|🌝|
|<b>C#|
|Godot 3.5.3 (C#)|660|74623|🌝|
|Godot 4.1.2 (C#)|230|144297|🌝|
* OpenGMK, RGDirect and MKXP are runtime replacements for already assembled binaries.
* Execution times below 1 sec. reported with higher precision.
<br>
These projects could also be useful as a 'Hello World!' programs, when moving from engine to engine<br>
and you want to familiarize yourself by jumping right in, instead of going through tutorials.<br>
<br>
Enjoy!<br>
