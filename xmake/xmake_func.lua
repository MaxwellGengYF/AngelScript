rule("lc_basic_settings")
on_config(function(target)
    local _, cc = target:tool("cxx")
    if is_plat("linux") then
        -- Linux should use -stdlib=libc++
        -- https://github.com/LuisaGroup/LuisaCompute/issues/58
        if (cc == "clang" or cc == "clangxx") then
            target:add("cxflags", "-stdlib=libc++", {
                force = true
            })
            target:add("syslinks", "c++")
        end
    end
    -- disable LTO
    -- if cc == "cl" then
    --     target:add("cxflags", "-GL")
    -- elseif cc == "clang" or cc == "clangxx" then
    --     target:add("cxflags", "-flto=thin")
    -- elseif cc == "gcc" or cc == "gxx" then
    --     target:add("cxflags", "-flto")
    -- end
    -- local _, ld = target:tool("ld")
    -- if ld == "link" then
    --     target:add("ldflags", "-LTCG")
    --     target:add("shflags", "-LTCG")
    -- elseif ld == "clang" or ld == "clangxx" then
    --     target:add("ldflags", "-flto=thin")
    --     target:add("shflags", "-flto=thin")
    -- elseif ld == "gcc" or ld == "gxx" then
    --     target:add("ldflags", "-flto")
    --     target:add("shflags", "-flto")
    -- end
end)
on_load(function(target)
    local _get_or = function(name, default_value)
        local v = target:extraconf("rules", "lc_basic_settings", name)
        if v == nil then
            return default_value
        end
        return v
    end
    local toolchain = _get_or("toolchain", get_config("lc_toolchain"))
    if toolchain then
        target:set("toolchains", toolchain)
    end
    local project_kind = _get_or("project_kind", nil)
    if project_kind then
        target:set("kind", project_kind)
    end
    if is_plat("linux") then
        if project_kind == "static" or project_kind == "object" then
            target:add("cxflags", "-fPIC", {
                tools = {"clang", "gcc"}
            })
        end
    end
    if is_plat("macosx") then
        target:add("cxflags", "-no-pie")
    end
    -- fma support
    if is_arch("x64", "x86_64") then
        target:add("cxflags", "-mfma", {
            tools = {"clang", "gcc"}
        })
    end
    local c_standard = _get_or("c_standard", nil)
    local cxx_standard = _get_or("cxx_standard", nil)
    if type(c_standard) == "string" and type(cxx_standard) == "string" then
        target:set("languages", c_standard, cxx_standard, {
            public = true
        })
    else
        target:set("languages", "clatest", "cxx20", {
            public = true
        })
    end

    local enable_exception = _get_or("enable_exception", nil)
    if enable_exception then
        target:set("exceptions", "cxx")
    else
        target:set("exceptions", "no-cxx")
    end

    local force_optimize = _get_or("force_optimize", nil)
    if is_mode("debug") then
        target:set("runtimes", _get_or("runtime", "MDd"), {
            public = true
        })
        if force_optimize then
            target:set("optimize", "aggressive")
        else
            target:set("optimize", "none")
        end
        target:set("warnings", "none")
        target:add("cxflags", "/GS", "/Gd", {
            tools = {"clang_cl", "cl"},
            public = true
        })
    elseif is_mode("releasedbg") then
        target:set("runtimes", _get_or("runtime", "MDd"), {
            public = true
        })
        if force_optimize then
            target:set("optimize", "aggressive")
        else
            target:set("optimize", "none")
        end
        target:set("warnings", "none")
        target:add("cxflags", "/GS-", "/Gd", {
            tools = {"clang_cl", "cl"},
            public = true
        })
    else
        target:set("runtimes", _get_or("runtime", "MD"), {
            public = true
        })
        target:set("optimize", "aggressive")
        target:set("warnings", "none")
        target:add("cxflags", "/GS-", "/Gd", {
            tools = {"clang_cl", "cl"},
            public = true
        })
    end
    target:set("fpmodels", "fast")
    target:add("cxflags", "/Zc:preprocessor", {
        tools = "cl",
        public = true
    });
    if is_arch("arm64") then
        target:add("vectorexts", "neon", {
            public = true
        })
    else
        target:add("vectorexts", "avx", "avx2", {
            public = true
        })
    end
    target:add("cxflags", "/GR-", {
        tools = {"clang_cl", "cl"},
        public = true
    })
    target:add("cxflags", "-fno-rtti", "-fno-rtti-data", {
        tools = {"clang"},
        public = true
    })
    target:add("cxflags", "-fno-rtti", {
        tools = {"gcc"},
        public = true
    })
end)
rule_end()

function enable_unity_build(batch_size)
    if type(batch_size) == "number" then
        add_rules("c.unity_build", {
            batchsize = batch_size
        })
        add_rules("c++.unity_build", {
            batchsize = batch_size
        })
    end
end
