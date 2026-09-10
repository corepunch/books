# Lua runtime for iPad

Unmodified C headers and sources from Lua 5.4.8, matching the desktop development
runtime. The iPad makefile compiles these into Book (excluding the `lua.c` and `luac.c` CLI
entry points). The desktop harness continues to use pkg-config's Lua 5.4.

Source: https://www.lua.org/ftp/lua-5.4.8.tar.gz
SHA-256: `4f18ddae154e793e46eeab727c59ef1c0c0c2b744e7b94219710d76f530629ae`

The iPad build uses upstream's `LUA_USE_IOS` configuration, which disables shell
execution on iOS. The only application Lua dependency remains `libs/zilscript/`.
