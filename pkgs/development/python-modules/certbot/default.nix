{ lib
, buildPythonPackage
, python, runCommand
, fetchFromGitHub
, ConfigArgParse, acme, configobj, cryptography, distro, josepy, parsedatetime, pyRFC3339, pyopenssl, pytz, requests, six, zope_component, zope_interface
, dialog, gnureadline
, pytest_xdist, pytestCheckHook, python-dateutil
}:

buildPythonPackage rec {
  pname = "certbot";
  version = "1.17.0";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-07UfTIZUbRD19BQ0xlZXlZo/oiVLDFNq+N2pDnWwbwI=";
  };

  sourceRoot = "source/${pname}";

  propagatedBuildInputs = [
    ConfigArgParse
    acme
    configobj
    cryptography
    distro
    josepy
    parsedatetime
    pyRFC3339
    pyopenssl
    pytz
    requests
    six
    zope_component
    zope_interface
  ];

  buildInputs = [ dialog gnureadline ];

  checkInputs = [
    python-dateutil
    pytestCheckHook
    pytest_xdist
  ];

  pytestFlagsArray = [
    "-o cache_dir=$(mktemp -d)"
    # See https://github.com/certbot/certbot/issues/8746
    "-W ignore::ResourceWarning"
  ];

  doCheck = true;

  makeWrapperArgs = [ "--prefix PATH : ${dialog}/bin" ];

  # certbot.withPlugins has a similar calling convention as python*.withPackages
  # it gets invoked with a lambda, and invokes that lambda with the python package set matching certbot's:
  # certbot.withPlugins (cp: [ cp.certbot-dns-foo ])
  passthru.withPlugins = f: let
    pythonEnv = python.withPackages f;

  in runCommand "certbot-with-plugins" {
  } ''
    mkdir -p $out/bin
    cd $out/bin
    ln -s ${pythonEnv}/bin/certbot
  '';

  meta = with lib; {
    homepage = src.meta.homepage;
    description = "ACME client that can obtain certs and extensibly update server configurations";
    platforms = platforms.unix;
    maintainers = with maintainers; [ domenkozar ];
    license = with licenses; [ asl20 ];
  };
}
