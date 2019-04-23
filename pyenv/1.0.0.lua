-- this is adapated for a virtualenv activate script
local root="/opt/pyenv"
setenv("VIRTUALENV", root)
prepend_path("PATH", pathJoin(root, "bin"))
unsetenv("PYTHONHOME")  -- shouldn't be set anyways
set_alias("pydoc", "python -m pydoc")
execute({cmd="hash -r 2> /dev/null", modeA={"load", "unload"}})
