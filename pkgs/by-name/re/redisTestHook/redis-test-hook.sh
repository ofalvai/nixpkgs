preCheckHooks+=('redisStart')
postCheckHooks+=('redisStop')


redisStart() {
  if [[ "${redisTestPort:-}" == "" ]]; then
    redisTestPort=6379
  fi

  echo 'starting redis'

  # Note about Darwin: unless the output is redirected, the parent process becomes launchd instead of bash.
  # This would leave the Redis process running in case of a test failure (the postCheckHook would not be executed),
  # hanging the Nix build forever.
  redis-server --port "$redisTestPort" >/dev/null 2>&1 &
  REDIS_PID=$!

  while ! redis-cli --scan -p "$redisTestPort" ; do
    echo 'waiting for redis to be ready'
    sleep 1
  done
}

redisStop() {
  echo 'stopping redis'
  kill "$REDIS_PID"
}
