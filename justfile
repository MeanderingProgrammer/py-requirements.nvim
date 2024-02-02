init := "tests/minimal.lua"

test:
    nvim --headless --noplugin -u {{init}} \
      -c "PlenaryBustedDirectory tests { minimal_init = '{{init}}' }"

demo:
    rm -f demo.gif
    python scripts/record_demo.py \
      --file "scripts/demo-requirements.txt" \
      --cast demo.cast
    agg --font-family "Hack Nerd Font Mono" demo.cast demo.gif
    rm demo.cast
