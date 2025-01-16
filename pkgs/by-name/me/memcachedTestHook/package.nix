{
  callPackage,
  makeSetupHook,
  memcached,
  netcat,
}:

makeSetupHook {
  name = "memcached-test-hook";
  propagatedBuildInputs = [
    memcached
    netcat
  ];
  passthru.tests = {
    simple = callPackage ./test.nix { };
  };
} ./memcached-test-hook.sh
