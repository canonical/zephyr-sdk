# Runs inside the workshop. Replays the tutorial's `west build -t run` and
# then presses Ctrl+A, X to stop QEMU once the sample has printed its
# greeting, as the tutorial instructs. `timeout` bounds a hung QEMU.
set -o pipefail
cd /project/zephyr || exit
log=$(mktemp)
# The feeder watches the log QEMU writes to decide when to press Ctrl+A, X.
# shellcheck disable=SC2094
{
  for _ in $(seq 240); do
    grep -q 'Hello World!' "$log" && break
    sleep 1
  done
  printf '\001x'
} | timeout --kill-after=10 300 west build -t run >"$log" 2>&1
status=$?
cat "$log"
rm -f "$log"
exit "$status"
