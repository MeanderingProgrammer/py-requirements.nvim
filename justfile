init := "tests/minimal.lua"

test:
    nvim --headless --noplugin -u {{init}} \
      -c "PlenaryBustedDirectory tests { minimal_init = '{{init}}' }"

demo:
    python scripts/record_demo.py

demo-clean:
    rm demo.*
