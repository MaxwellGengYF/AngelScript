set_xmakever("2.9.8")
add_rules("mode.release", "mode.debug", "mode.releasedbg")
set_policy("build.ccache", false)
set_policy("check.auto_ignore_flags", false)

includes("xmake/xmake_func.lua", "angelscript/xmake.lua", "mimalloc/xmake.lua", 'test/xmake.lua')
