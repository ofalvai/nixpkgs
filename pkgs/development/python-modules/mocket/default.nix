{
  lib,
  buildPythonPackage,
  fetchPypi,
  pythonOlder,

  # build-system
  hatchling,

  # dependencies
  decorator,
  httptools,
  python-magic,
  urllib3,

  # optional-dependencies
  xxhash,
  pook,

  # tests
  aiohttp,
  asgiref,
  fastapi,
  gevent,
  httpx,
  psutil,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  redis,
  redis-server,
  redisTestHook,
  requests,
  sure,

}:

buildPythonPackage rec {
  pname = "mocket";
  version = "3.13.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-GFzIDSE+09L4RC5w4h3fqgq9lkyOVjq5JN++ZNbHWc8=";
  };

  nativeBuildInputs = [ hatchling ];

  propagatedBuildInputs = [
    decorator
    httptools
    python-magic
    urllib3
  ];

  optional-dependencies = {
    pook = [ pook ];
    speedups = [ xxhash ];
  };

  nativeCheckInputs =
    [
      asgiref
      fastapi
      gevent
      httpx
      psutil
      pytest-asyncio
      pytest-cov-stub
      pytestCheckHook
      redis
      redisTestHook
      requests
      sure
    ]
    ++ lib.optionals (pythonOlder "3.12") [ aiohttp ]
    ++ lib.flatten (builtins.attrValues optional-dependencies);

  # Skip http tests, they require network access
  env.SKIP_TRUE_HTTP = true;

  _darwinAllowLocalNetworking = true;

  disabledTests = [
    # tests that require network access (like DNS lookups)
    "test_truesendall_with_dump_from_recording"
    "test_aiohttp"
    "test_asyncio_record_replay"
    "test_gethostbyname"
    # httpx read failure
    "test_no_dangling_fds"
  ];

  pythonImportsCheck = [ "mocket" ];

  meta = with lib; {
    changelog = "https://github.com/mindflayer/python-mocket/releases/tag/${version}";
    description = "Socket mock framework for all kinds of sockets including web-clients";
    homepage = "https://github.com/mindflayer/python-mocket";
    license = licenses.bsd3;
    maintainers = [ ];
  };
}
