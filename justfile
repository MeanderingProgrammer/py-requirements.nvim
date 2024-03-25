init := "tests/minimal.lua"

test:
    nvim --headless --noplugin -u {{init}} \
      -c "PlenaryBustedDirectory tests { minimal_init = '{{init}}', sequential=true }"

demo:
    rm -f doc/demo.gif
    python scripts/record_demo.py \
      --file "scripts/demo-requirements.txt" \
      --cast demo.cast
    # https://docs.asciinema.org/manual/agg/usage/
    agg demo.cast doc/demo.gif \
      --font-family "Hack Nerd Font Mono" \
      --last-frame-duration 1
    rm demo.cast
