{ lib
, stdenv
, asn1crypto
, buildPythonPackage
, defusedxml
, dissect-cim
, dissect-clfs
, dissect-cstruct
, dissect-esedb
, dissect-etl
, dissect-eventlog
, dissect-evidence
, dissect-extfs
, dissect-fat
, dissect-ffs
, dissect-hypervisor
, dissect-ntfs
, dissect-regf
, dissect-sql
, dissect-shellitem
, dissect-thumbcache
, dissect-util
, dissect-volume
, dissect-xfs
, fetchFromGitHub
, flow-record
, fusepy
, ipython
, pycryptodome
, pytestCheckHook
, pythonOlder
, pyyaml
, setuptools
, setuptools-scm
, structlog
, yara-python
, zstandard
}:

buildPythonPackage rec {
  pname = "dissect-target";
  version = "3.17";
  pyproject = true;

  disabled = pythonOlder "3.9";

  src = fetchFromGitHub {
    owner = "fox-it";
    repo = "dissect.target";
    rev = "refs/tags/${version}";
    hash = "sha256-UIgHjSTHaxo8jCqe+R6rRxQXX8RUFKAI5+zscInAtgg=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "flow.record~=" "flow.record>="
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    defusedxml
    dissect-cstruct
    dissect-eventlog
    dissect-evidence
    dissect-hypervisor
    dissect-ntfs
    dissect-regf
    dissect-util
    dissect-volume
    flow-record
    structlog
  ];

  passthru.optional-dependencies = {
    full = [
      asn1crypto
      dissect-cim
      dissect-clfs
      dissect-esedb
      dissect-etl
      dissect-extfs
      dissect-fat
      dissect-ffs
      dissect-shellitem
      dissect-sql
      dissect-thumbcache
      dissect-xfs
      fusepy
      ipython
      pycryptodome
      pyyaml
      yara-python
      zstandard
    ];
  };

  nativeCheckInputs = [
    pytestCheckHook
  ] ++ passthru.optional-dependencies.full;

  pythonImportsCheck = [
    "dissect.target"
  ];

  disabledTests = [
    "test_cpio"
    # Test requires rdump
    "test_exec_target_command"
    # Issue with tar file
    "test_dpapi_decrypt_blob"
    "test_md"
    "test_nested_md_lvm"
    "test_notifications_appdb"
    "test_notifications_wpndatabase"
    "test_tar_anonymous_filesystems"
    "test_tar_sensitive_drive_letter"
    # Tests compare dates and times
    "yum"
    # Filesystem access, windows defender tests
    "test_defender_quarantine_recovery"
  ] ++
  # test is broken on Darwin
  lib.optional stdenv.hostPlatform.isDarwin "test_fs_attrs_no_os_listxattr";

  disabledTestPaths = [
    # Tests are using Windows paths
    "tests/plugins/apps/browser/"
    # ValueError: Invalid Locate file magic. Expected /x00LOCATE02/x00
    "tests/plugins/os/unix/locate/"
    # Missing plugin support
    "tests/tools/test_reg.py"
  ];

  meta = with lib; {
    description = "Dissect module that provides a programming API and command line tools";
    homepage = "https://github.com/fox-it/dissect.target";
    changelog = "https://github.com/fox-it/dissect.target/releases/tag/${version}";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ fab ];
  };
}
