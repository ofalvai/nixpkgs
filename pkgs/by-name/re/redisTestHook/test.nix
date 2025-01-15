{
  redis,
  redisTestHook,
  stdenv,
}:

stdenv.mkDerivation {
  name = "redis-test-hook-test";

  nativeCheckInputs = [
    redis
    redisTestHook
  ];

  dontUnpack = true;
  doCheck = true;

  preCheck = ''
    redisTestPort=6380
  '';

  checkPhase = ''
    runHook preCheck

    echo "running test"
    if redis-cli --scan -p $redisTestPort; then
      echo "connected to redis"
      TEST_RAN=1
    fi

    runHook postCheck
  '';

  installPhase = ''
    [[ $TEST_RAN == 1 ]]
    echo "test passed"
    touch $out
  '';
}
