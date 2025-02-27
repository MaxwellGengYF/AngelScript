set_xmakever("2.9.8")
set_policy("build.ccache", false)
set_policy("check.auto_ignore_flags", false)

includes("xmake/xmake_func.lua", "angelscript/xmake.lua")