target('anglescript_assembly')
add_rules('lc_basic_settings', {
    project_kind = 'object',
    toolchain = 'msvc'
})
on_config(function(target)
    local _, cc = target:tool('cxx')
    -- Add assembly files
    local function _add_files(...)
        for k, v in ipairs({...}) do
            target:add('files', path.join(os.scriptdir(), 'source', v))
        end
    end
    local function raise_err(info)
        utils.error(info)
        target:set('enabled', false)
    end
    local function unsupported_compiler()
        raise_err('Unsupported compiler ' .. cc .. '.')
    end
    local function unsupported_arch()
        raise_err('Unsupported arch.')
    end

    if is_plat('windows') then
        if is_arch('x64') then
            if (cc == 'clang' or cc == 'clangxx' or cc == 'clang-cl' or cc == 'clang_cl' or cc == 'cl') then
                _add_files('as_callfunc_x64_msvc_asm.asm')
            elseif cc == 'gcc' or cc == 'gxx' then
                _add_files('as_callfunc_x64_gcc.asm')
            else
                unsupported_compiler()
            end
        elseif is_arch('x86') then
            if (cc == 'clang' or cc == 'clangxx' or cc == 'clang-cl' or cc == 'clang_cl' or cc == 'cl') then
            else
                unsupported_compiler()
            end
        elseif is_arch("arm") or is_arch('arm64') then
            if (cc == 'clang' or cc == 'clangxx' or cc == 'clang-cl' or cc == 'clang_cl' or cc == 'cl') then
                _add_files('as_callfunc_arm_msvc.asm')
            else
                unsupported_compiler()
            end
        else
            unsupported_arch()
        end
    elseif is_plat('linux') then
        if is_arch('x86_64') then

        elseif is_arch('i386') then

        elseif is_arch('riscv64') then
            _add_files('as_callfunc_riscv64_gcc.S')
        elseif is_arch('arm64') then
            _add_files('as_callfunc_arm64_gcc.S')
        elseif is_arch('arm') then
            _add_files('as_callfunc_arm_gcc.S')
        else
            unsupported_arch()
        end
    elseif is_plat('macosx') then
        if is_arch('arm64') then
            _add_files('as_callfunc_arm64_xcode.S')
        else
            unsupported_arch()
        end
    end
end)
target_end()

target('anglescript')
add_rules('lc_basic_settings', {
    project_kind = 'shared'
})
add_includedirs('include')
add_defines('AS_NO_EXCEPTIONS', 'ANGELSCRIPT_EXPORT')
add_defines('ANGELSCRIPT_DLL_LIBRARY_IMPORT', {
    public = true
})
add_files('source/**.cpp')
add_deps('anglescript_assembly')
on_load(function(target)
    local add_on_path = path.join(path.directory(os.scriptdir()), "add_on")
    print(add_on_path)
    target:add("files", 
        path.join(add_on_path, "datetime/*.cpp"),
        path.join(add_on_path, "scriptany/*.cpp"),
        path.join(add_on_path, "scriptarray/*.cpp"),
        path.join(add_on_path, "scriptbuilder/*.cpp"),
        path.join(add_on_path, "scriptdictionary/*.cpp"),
        path.join(add_on_path, "scriptfile/*.cpp"),
        path.join(add_on_path, "scriptgrid/*.cpp"),
        path.join(add_on_path, "scripthandle/*.cpp"),
        path.join(add_on_path, "scripthelper/*.cpp"),
        path.join(add_on_path, "scriptstdstring/*.cpp"),
        path.join(add_on_path, "scriptmath/*.cpp"),
        path.join(add_on_path, "serializer/*.cpp"),
        path.join(add_on_path, "weakref/*.cpp")
    )
end)
target_end()
