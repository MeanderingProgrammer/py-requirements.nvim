init := "tests/minimal.lua"

test:
    nvim --headless --noplugin -u {{init}} \
      -c "PlenaryBustedDirectory tests { minimal_init = '{{init}}' }"
