{
  callPackage,
  makeSetupHook,
  redis,
}:

makeSetupHook {
  name = "redis-test-hook";
  propagatedBuildInputs = [ redis ];
  passthru.tests = {
    simple = callPackage ./test.nix { };
  };
} ./redis-test-hook.sh
