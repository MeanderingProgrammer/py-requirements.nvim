init := "tests/minimal_init.lua"

test:
  nvim --headless --noplugin -u {{init}} \
    -c "PlenaryBustedDirectory tests { minimal_init = '{{init}}', sequential=true, keep_going = false }"

demo:
  rm -f demo/demo.gif
  python demo/record.py \
    --cols "100" \
    --rows "40" \
    --file demo/requirements.txt \
    --cast demo.cast
  # https://github.com/MeanderingProgrammer/cli/tree/main/agg
  agg demo.cast demo/demo.gif
  rm demo.cast
