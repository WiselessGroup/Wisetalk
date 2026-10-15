#!/bin/sh
# What the running app costs the machine (ADR-0019, WLK-24): CPU, memory and
# wakeups of one process over a stretch of time, without root.
#
# Usage: scripts/measure.sh [seconds] [pid]
#   seconds  how long to watch, 60 by default
#   pid      the app's process; by default the newest one named wisetalk
#
# Measure a release build (flutter build linux --release, or the AppImage),
# never a debug one: debug runs the Dart VM in JIT mode and costs far more.
# Take each state separately and let it settle for a minute first: window
# open and idle, minimized, in a voice call, watching video.
#
# CPU is user plus system time of all threads, in percent of one core.
# Memory is PSS (shared libraries counted once across processes) and RSS.
# Wakeups are voluntary plus involuntary context switches of all threads per
# second: every time a thread wakes up to run, it counts. powertop shows the
# same thing as "Events/s" but needs root.
set -eu

seconds=${1:-60}
pid=${2:-$(pgrep -n -x wisetalk || true)}
[ -n "$pid" ] && [ -d "/proc/$pid" ] || {
    echo "measure: no wisetalk process; pass its pid" >&2
    exit 1
}
ticks=$(getconf CLK_TCK)

# Prints "cpu_ticks context_switches threads" for the whole process.
sample() {
    cpu=0
    switches=0
    threads=0
    for task in /proc/"$pid"/task/*; do
        # Fields 14 and 15 of stat are utime and stime; the command name in
        # field 2 may hold spaces, so cut after its closing parenthesis.
        set -- $(sed 's/^.*) //' "$task/stat" 2>/dev/null || echo)
        [ $# -ge 13 ] || continue
        cpu=$((cpu + ${12} + ${13}))
        s=$(awk '/ctxt_switches/ { n += $2 } END { print n + 0 }' "$task/status" 2>/dev/null || echo 0)
        switches=$((switches + s))
        threads=$((threads + 1))
    done
    echo "$cpu $switches $threads"
}

kib() { awk '/^'"$1"':/ { print $2 }' /proc/"$pid"/smaps_rollup; }

set -- $(sample)
cpu0=$1 sw0=$2
start=$(date +%s.%N)
sleep "$seconds"
set -- $(sample)
cpu1=$1 sw1=$2 threads=$3
end=$(date +%s.%N)

awk -v c0="$cpu0" -v c1="$cpu1" -v s0="$sw0" -v s1="$sw1" -v t0="$start" -v t1="$end" \
    -v hz="$ticks" -v threads="$threads" -v pss="$(kib Pss)" -v rss="$(kib Rss)" \
    -v cmd="$(tr '\0' ' ' < /proc/"$pid"/cmdline)" 'BEGIN {
    span = t1 - t0
    printf "process   %s\n", cmd
    printf "watched   %.0f s\n", span
    printf "cpu       %.2f %% of one core\n", (c1 - c0) / hz / span * 100
    printf "wakeups   %.0f per second (context switches, %d threads)\n", (s1 - s0) / span, threads
    printf "memory    PSS %.0f MiB, RSS %.0f MiB\n", pss / 1024, rss / 1024
}'
