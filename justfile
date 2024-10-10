init := "tests/minimal_init.lua"

test:
  nvim --headless --noplugin -u {{init}} \
    -c "PlenaryBustedDirectory tests { minimal_init = '{{init}}', sequential=true, keep_going = false }"

demo:
  rm -f demo/demo.mp4
  vhs demo/demo.tape
