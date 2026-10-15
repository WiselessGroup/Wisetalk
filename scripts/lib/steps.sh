# shellcheck shell=sh
# Sourced by the release scripts. Each step shows one line with a spinner,
# a running clock and how long it took last time; what it prints goes to
# dist/logs/<name>.log and only shows when it fails.
#
# Set before sourcing: `times`, the file that remembers durations, and
# `steps`, how many steps there are.

: "${times:?set times before sourcing steps.sh}" "${steps:?set steps before sourcing steps.sh}"
mkdir -p "$(dirname "$times")" dist/logs
touch "$times"
n=0
started=$(date +%s)
tty=false
[ -t 1 ] && tty=true

clock() { printf '%d:%02d' $(($1 / 60)) $(($1 % 60)); }
spinner() {
    case $(($1 % 10)) in
        0) printf '⠋' ;; 1) printf '⠙' ;; 2) printf '⠹' ;; 3) printf '⠸' ;; 4) printf '⠼' ;;
        5) printf '⠴' ;; 6) printf '⠦' ;; 7) printf '⠧' ;; 8) printf '⠇' ;; *) printf '⠏' ;;
    esac
}
last_time() { sed -n "s/^$1 //p" "$times" | tail -n 1; }

# The whole run's length last time, for the opening line; 0 the first time.
estimate() { awk '{ sum += $2 } END { print sum + 0 }' "$times"; }

# A step that needs nothing done, such as an image already built.
skip_step() {
    n=$((n + 1))
    printf '✓ [%d/%d] %s  %s\n' "$n" "$steps" "$1" "$2"
}

# step <name> <title> <command...>: runs the command with its output in
# dist/logs/<name>.log, a spinner and a clock meanwhile, and remembers how
# long it took for next time's estimate.
step() {
    name=$1 title=$2
    shift 2
    n=$((n + 1))
    log=dist/logs/$name.log
    was=$(last_time "$name")
    begin=$(date +%s)
    "$@" >"$log" 2>&1 &
    pid=$!
    i=0
    while kill -0 "$pid" 2>/dev/null; do
        if $tty; then
            took=$(($(date +%s) - begin))
            hint=
            [ -n "$was" ] && hint=" of ~$(clock "$was")"
            printf '\r\033[K%s [%d/%d] %s  %s%s' "$(spinner "$i")" "$n" "$steps" "$title" "$(clock "$took")" "$hint"
            i=$((i + 1))
        fi
        sleep 0.2
    done
    status=0
    wait "$pid" || status=$?
    took=$(($(date +%s) - begin))
    if [ "$status" -ne 0 ]; then
        $tty && printf '\r\033[K'
        printf '✗ [%d/%d] %s  failed after %s\n\n' "$n" "$steps" "$title" "$(clock "$took")"
        tail -n 30 "$log"
        printf '\nThe whole log: %s\n' "$log"
        exit 1
    fi
    { grep -v "^$name " "$times" || true; echo "$name $took"; } >"$times.new"
    mv "$times.new" "$times"
    $tty && printf '\r\033[K'
    printf '✓ [%d/%d] %s  %s\n' "$n" "$steps" "$title" "$(clock "$took")"
}

# The files sent, their sizes and the release page.
summary() {
    release_page=$1
    shift
    echo
    echo "Released in $(clock $(($(date +%s) - started))):"
    for file in "$@"; do
        printf '  %-44s %s\n' "$(basename "$file")" "$(du -h "$file" | cut -f1)"
    done
    echo "$release_page"
}
