{
  stdenv,
  fetchurl,
  pkg-config,
  glibc,
  pam,
  openldap,
  krb5,
  dnsutils,
  cyrus_sasl,
  nss,
  popt,
  talloc,
  tdb,
  tevent,
  ldb,
  ding-libs,
  pcre,
  c-ares,
  glib,
  dbus,
}:

let
  version = "1.16.5";
in

stdenv.mkDerivation rec {
  name = "sssd-nss-client-${version}";

  src = fetchurl {
    url = "https://fedorahosted.org/released/sssd/sssd-${version}.tar.gz";
    sha256 = "sha256-Lhp78Da1g/aG01Fk8teb30hXuY9R/osNF6oPp1bk0MA=";
  };

  # libnss_sss.so does not in fact use any of these -- they're just needed for configure
  nativeBuildInputs = [
    pkg-config
    pam
    openldap
    krb5
    dnsutils
    cyrus_sasl
    nss
    popt
    talloc
    tdb
    tevent
    ldb
    ding-libs
    pcre
    c-ares
    glib
    dbus
  ];

  configureFlags = [
    # connect and use to system sssd:
    "--localstatedir=/var"
    "--sysconfdir=/etc"
    "--with-os=redhat"

    "--with-nscd=${glibc.bin}/sbin/nscd"
    "--with-ldb-lib-dir=$(out)/modules/ldb"
    "--disable-cifs-idmap-plugin"
    "--without-autofs"
    "--without-kcm"
    "--without-libnl"
    "--without-libwbclient"
    "--without-manpages"
    "--without-nfsv4-idmapd-plugin"
    "--without-python2-bindings"
    "--without-python3-bindings"
    "--without-samba"
    "--without-secrets"
    "--without-selinux"
    "--without-semanage"
    "--without-ssh"
    "--without-sudo"
  ];

  enableParallelBuilding = true;

  buildFlags = [ "libnss_sss.la" ];
  installTargets = [ "install-nsslibLTLIBRARIES" ];

}
