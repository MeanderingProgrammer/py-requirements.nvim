init := "tests/minimal.lua"
default_zoom := "10"

test:
  nvim --headless --noplugin -u {{init}} \
    -c "PlenaryBustedDirectory tests { minimal_init = '{{init}}', sequential=true }"

demo zoom=default_zoom:
  rm -f demo/demo.gif
  python demo/record.py \
    --zoom {{zoom}} \
    --file demo/requirements.txt \
    --cast demo.cast
  # https://docs.asciinema.org/manual/agg/usage/
  agg demo.cast demo/demo.gif \
    --font-family "Monaspace Neon,Hack Nerd Font Mono" \
    --last-frame-duration 1
  rm demo.cast
