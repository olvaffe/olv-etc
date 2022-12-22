set logging file ~/.local/state/gdb.log
set logging overwrite on
set logging enabled on

set history filename ~/.local/state/gdb.history
set history save on
set history size 640
set history remove-duplicates unlimited

set print pretty on
set print array on

set pagination off
set confirm off

set debuginfod enabled on

# save symbol index cache to ~/.cache/gdb
set index-cache enabled on
