target('angel_helloworld')
add_rules('lc_basic_settings', {
    project_kind = 'binary'
})
add_files('hello_world.cpp')
add_deps('angelscript', 'mimalloc')
add_includedirs("../add_on")
target_end()