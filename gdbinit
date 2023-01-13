set logging file ~/.local/state/gdb.log
set logging overwrite on
set logging enabled on

set print array on
set print array-indexes on
set print object on
set print pretty on

# save symbol index cache to ~/.cache/gdb
set index-cache enabled on

set history filename ~/.local/state/gdb.history
set history remove-duplicates unlimited
set history size 640
set history save on

set pagination off
set confirm off
set breakpoint pending on

set debuginfod enabled on
