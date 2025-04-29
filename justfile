init := "tests/minimal_init.lua"
settings := "{ minimal_init = " + quote(init) + ", sequential = true, keep_going = false }"

test:
  nvim --headless --noplugin -u {{init}} -c "PlenaryBustedDirectory tests {{settings}}"

demo:
  rm -rf demo/demo.mp4
  vhs demo/demo.tape
