{
  flake.aspects.cacerts.nixos =
    # https://discourse.nixos.org/t/custom-ssl-certificates-for-jdk/18297/16
    # add custom ca certs
    {
      config,
      pkgs,
      lib,
      ...
    }:

    let
      caBundle = config.environment.etc."ssl/certs/ca-certificates.crt".source;
      p11kit = pkgs.p11-kit.overrideAttrs (oldAttrs: {
        mesonFlags = [
          "--sysconfdir=/etc"
          (lib.mesonEnable "systemd" false)
          (lib.mesonOption "bashcompdir" "${placeholder "bin"}/share/bash-completion/completions")
          (lib.mesonOption "trust_paths" (
            lib.concatStringsSep ":" [
              "${caBundle}"
            ]
          ))
        ];
      });
      javaCaCerts = pkgs.stdenvNoCC.mkDerivation {
        name = "java-cacerts";
        dontUnpack = true;
        nativeBuildInputs = [ p11kit ];
        installPhase = ''
          trust \
            extract \
            --format=java-cacerts \
            --purpose=server-auth \
            $out
        '';
      };
    in
    {
      security = {
        pki = {
          installCACerts = true;

          # append trusted certificate authorities
          certificates = [
            #''
            #  NixOS.org
            #  =========
            #  -----BEGIN CERTIFICATE-----
            #  MIIGUDCCBTigAwIBAgIDD8KWMA0GCSqGSIb3DQEBBQUAMIGMMQswCQYDVQQGEwJJ
            #  TDEWMBQGA1UEChMNU3RhcnRDb20gTHRkLjErMCkGA1UECxMiU2VjdXJlIERpZ2l0
            # ...
            #  -----END CERTIFICATE-----
            #''
            ''
              Certificate chain
               0 [...]
                 v:NotBefore: Feb  6 10:30:56 2025 GMT; NotAfter: Feb  6 10:30:55 2026 GMT
              -----BEGIN CERTIFICATE-----
              MIIHeDCCBmCgAwIBAgIMPtsobF3mFcGqmkY6MA0GCSqGSIb3DQEBCwUAMEYxKDAm
              BgNVBAMMH0F0b3MgVHJ1c3RlZFJvb3QgU2VydmVyLUNBIDIwMTkxDTALBgNVBAoM
              BEF0b3MxCzAJBgNVBAYTAkRFMB4XDTI1MDIwNjEwMzA1NloXDTI2MDIwNjEwMzA1
              NVowYTELMAkGA1UEBhMCRlIxDzANBgNVBAcMBkJlem9uczEoMCYGA1UECgwfRXZp
              ZGVuIEludGVybmF0aW9uYWwgRnJhbmNlIFNBUzEXMBUGA1UEAwwOKi5teWV2aWRl
              bi5jb20wggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCw3Wej9oO1p7WB
              7wplf1ZLyXyueQ+LN9hfvgww2rTu1hP2k8rkY4Yo34Rda3slgb6L/SQVqBnbw0e1
              LTsGsF5Mja2NLCkDmPgQs8xoJL/mIfT//SrKj5XpBTyfGIvEkdxtt9dgDvaTXl8J
              S1shDmPo8dqwkaPMYvh8CX4QRN4Hsrl2vzuCUP6egYAyVRwCTMfqhEX79Nxo9E4q
              R1wW8O3SQp3+FMkqRnUYFzyrQwcZcoXlN1c0PtlgpVWLf6xmC9rWCsKhw1sHwczF
              UAB+Dt8rQiy7uTdFIDMZBdqvYX1ml44RtTI7UTu+pxUj+S86SK5mhBHXd/2NWUz6
              Sb02UnITLyYyvVgfw8sl3LBadMZ7HVGBEnmgocyoo1U5VAERl5U7wxsAPieHXxuq
              N8Y7mpWLl9oKLhb3xNitpFmyyrYjxA/d4028ebCbE/5EoGU9tc8ojNSTkgm7Fe0g
              yevkuv7hFanPbHt2MNXOzQy/gufBz9UNm1lHv8a6DuMpLhH85fo/V2QKTskG682z
              ycIdC7CD1E3IcKDXcDEWE9n/BVqytcpzsa1CJCMwpvZDvVL+HLTWFF7f4pHQHsdA
              HVkQlSrw2ZezId1OyxAIZqMhO3KrEozmOK7tHxCv4vZyjDrLuhO7326i216EiuL7
              +uLpuzGMNBTugezpX4aSvbkj0kPRwQIDAQABo4IDSTCCA0UwDAYDVR0TAQH/BAIw
              ADAfBgNVHSMEGDAWgBT7Y80WIWpz31rO9Cup/aom/qtJozB+BggrBgEFBQcBAQRy
              MHAwSAYIKwYBBQUHMAKGPGh0dHA6Ly9wa2kuYXRvcy5uZXQvRG93bmxvYWQvQXRv
              c1RydXN0ZWRSb290U2VydmVyQ0EyMDE5LmNlcjAkBggrBgEFBQcwAYYYaHR0cDov
              L3BraS1vY3NwLmF0b3MubmV0MCcGA1UdEQQgMB6CDioubXlldmlkZW4uY29tggxt
              eWV2aWRlbi5jb20wSgYDVR0gBEMwQTAIBgZngQwBAgIwNQYMKwYBBAGwLQUBAQED
              MCUwIwYIKwYBBQUHAgEWF2h0dHA6Ly9wa2kuYXRvcy5uZXQvQ1BTMB0GA1UdJQQW
              MBQGCCsGAQUFBwMCBggrBgEFBQcDATBQBgNVHR8ESTBHMEWgQ6BBhj9odHRwOi8v
              cGtpLWNybC5hdG9zLm5ldC9jcmwvQXRvc19UcnVzdGVkUm9vdF9TZXJ2ZXJfQ0Ff
              MjAxOS5jcmwwHQYDVR0OBBYEFNDYU9zz86uunvxcNPPAz/dH0enwMA4GA1UdDwEB
              /wQEAwIFoDCCAX0GCisGAQQB1nkCBAIEggFtBIIBaQFnAHUADleUvPOuqT4zGyyZ
              B7P3kN+bwj1xMiXdIaklrGHFTiEAAAGU2tlBnwAABAMARjBEAiBNsc7059z0Svjw
              mbs5cuo+GS+c5nA9Bq24mxX92C+8bgIgJCpEXLAEH7VYn8fW5nlu921De6tfZamc
              boC3qflcfVgAdQAlt+/eoRMBk+2TB5dwqjIqJmIN41rIqnx1GX3gsangZQAAAZTa
              2UGWAAAEAwBGMEQCIEfvBgYoBH6ijA4vEoksEWR8uWyKcjJ0jjgnmuI3r7LLAiAv
              xICZ2fYdqmTR3bissHA6TN7tz82FcI02+fYKqLt32wB3AEmcm2neHXzs/DbezYdk
              prhbrwqHgBnRVVL76esp3fjDAAABlNrZQZoAAAQDAEgwRgIhAOKH+kBdiLjQCwp7
              tuVSdwTAyM43pYrC/8WW7j8GxK+pAiEAi6+IPDqZswEtVqAhbpNNVhSuU3XRPXv6
              Mlk7aoVs8o0wDQYJKoZIhvcNAQELBQADggEBAGY3EaQMdxK5UFvhl+9tFT3cwc9n
              UY4mwG/8zgp6EbcjoAYiTj7wNlzeLuDGBkZ5yYsHwzMnYrsroDQRKR9ux7WwU87S
              eDrAN9/bYbUQEdtdkoHbMLdVM/0VFBNuVcDfa21bwfolJQUnPjyhEE+JtXnOxRTl
              6PEqHFJDCote1MsDwGt6XloPIJhWw6Pte4XSS/dUsSYqc8DofcBQx4MWPMb7IQEC
              iyEyOW2FtDz6ubcZFFVqiTLstWi5ULu4WXL6aNZmRUkAjoBosWzCl5NOlbE+iTv+
              PSWqF9pV/vf1yncOIna0Y/cJCSM8yB1SKizKhM9U6DuVrBcRm5X2LFrkHsE=
              -----END CERTIFICATE-----
               1 [...]
                 v:NotBefore: Mar 28 11:24:11 2019 GMT; NotAfter: Mar 25 11:24:11 2029 GMT
              -----BEGIN CERTIFICATE-----
              MIIFYDCCBEigAwIBAgIJPZ+eG7IbOqovMA0GCSqGSIb3DQEBCwUAMDwxHjAcBgNV
              BAMMFUF0b3MgVHJ1c3RlZFJvb3QgMjAxMTENMAsGA1UECgwEQXRvczELMAkGA1UE
              BhMCREUwHhcNMTkwMzI4MTEyNDExWhcNMjkwMzI1MTEyNDExWjBGMSgwJgYDVQQD
              DB9BdG9zIFRydXN0ZWRSb290IFNlcnZlci1DQSAyMDE5MQ0wCwYDVQQKDARBdG9z
              MQswCQYDVQQGEwJERTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKYv
              WizVegVZyhz5Ah4q5hHgpIvfTt1Kq5uydMxplt9n4x5NQmY6L+cSuEoOmkLIKSzI
              or0mLfa3Fpaqjcm7ZCe+3HmEw8q4S9VHMDKhgpfeYVcR446C0vpgM+4dWBwDkVzJ
              sxMBmpbco3pqhoJtSZZJ9X+71RNtOiz5TMJ1c957vJCIEYwXakL7USnIcsyfoGpP
              C5vNtCpZzbwI89Katke1r90uBxmnVTckgHmHoheolFFQGqVbGNQV7mhOoS6auKv0
              7d2qA+5CQHaEYUfa0t6qDqPPNx+3P+o1X5oZyKE6agRUQRevS4L8+UT/MF3O8ZoH
              rDxXUgmR5IeGY9wbz3ECAwEAAaOCAlkwggJVMBIGA1UdEwEB/wQIMAYBAf8CAQAw
              HwYDVR0jBBgwFoAUp6UGsSymCWDu0ZfpcK68Oxls2yEwdgYIKwYBBQUHAQEEajBo
              MEAGCCsGAQUFBzAChjRodHRwOi8vcGtpLmF0b3MubmV0L0Rvd25sb2FkL0F0b3NU
              cnVzdGVkUm9vdDIwMTEuY2VyMCQGCCsGAQUFBzABhhhodHRwOi8vcGtpLW9jc3Au
              YXRvcy5uZXQwRAYDVR0gBD0wOzA5BgsrBgEEAbAtBQEBATAqMCgGCCsGAQUFBwIB
              FhxodHRwOi8vcGtpLmF0b3MubmV0L0Rvd25sb2FkMB0GA1UdJQQWMBQGCCsGAQUF
              BwMCBggrBgEFBQcDATCCARAGA1UdHwSCAQcwggEDMIHAoHygeoZ4bGRhcDovL3Br
              aS1sZGFwLmF0b3MubmV0L2NuPUF0b3MlMjBUcnVzdGVkUm9vdCUyMDIwMTEsb3U9
              Q0Esb3U9QXRvcyUyMFRDLG89QXRvcyxkYz1hdG9zLGRjPW5ldD9jZXJ0aWZpY2F0
              ZVJldm9jYXRpb25MaXN0okCkPjA8MR4wHAYDVQQDDBVBdG9zIFRydXN0ZWRSb290
              IDIwMTExDTALBgNVBAoMBEF0b3MxCzAJBgNVBAYTAkRFMD6gPKA6hjhodHRwOi8v
              cGtpLWNybC5hdG9zLm5ldC9jcmwvQXRvc19UcnVzdGVkUm9vdF9DQV8yMDExLmNy
              bDAdBgNVHQ4EFgQU+2PNFiFqc99azvQrqf2qJv6rSaMwDgYDVR0PAQH/BAQDAgEG
              MA0GCSqGSIb3DQEBCwUAA4IBAQB0oStqRU0DSDKF79wtjcEZK6jchvZLhyVYX8i0
              8oUeDHGqGn8v2GMLnK97aeVNx1/7RcZbgay57WJ8SpuPHWRRiDL3Ec71HIGsc+N5
              VPkScYlkxHVamBWkicxrJ7oTgZkH6uDMNjXTXXzRgKS4luy2FYJMH18Yb5XdEJ3S
              QRU91Lq40p9Px4DcTkSccffJd3ZLWfbNpRF4PKIIo6VK9N023RThjVqe8BHpv+UC
              lfe5MOjZlfCmJAFl372i0ElNb9qf51ZVKakP29Va/zx45iUMDwKxjFVlZKS84ciC
              t9EwI6Fld/+formkXgesy8SlRSBTSZ9ljytlnL4EjXS9N9Wg
              -----END CERTIFICATE-----
               2 [...]
                 v:NotBefore: Jul  7 14:58:30 2011 GMT; NotAfter: Dec 31 23:59:59 2030 GMT
              -----BEGIN CERTIFICATE-----
              MIIDdzCCAl+gAwIBAgIIXDPLYixfszIwDQYJKoZIhvcNAQELBQAwPDEeMBwGA1UE
              AwwVQXRvcyBUcnVzdGVkUm9vdCAyMDExMQ0wCwYDVQQKDARBdG9zMQswCQYDVQQG
              EwJERTAeFw0xMTA3MDcxNDU4MzBaFw0zMDEyMzEyMzU5NTlaMDwxHjAcBgNVBAMM
              FUF0b3MgVHJ1c3RlZFJvb3QgMjAxMTENMAsGA1UECgwEQXRvczELMAkGA1UEBhMC
              REUwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCVhTuXbyo7LjvPpvMp
              Nb7PGKw+qtn4TaA+Gke5vJrf8v7MPkfoepbCJI419KkM/IL9bcFyYie96mvr54rM
              VD6QUM+A1JX76LWC1BTFtqlVJVfbsVD2sGBkWXppzwO3bw2+yj5vdHLqqjAqc2K+
              SZFhyBH+DgMq92og3AIVDV4VavzjgsG1xZ1kCWyjWZgHJ8cblithdHFsQ/H3NYkQ
              4J7sVaE3IqKHBAUsR320HLliKWYoyrfhk/WklAOZuXCFteZI6o1Q/NnezG8HDt0L
              cp2AMBYHlT8oDv3FdU9T1nSatCQujgKRz3bFmx5VdJx4IbHwLfELn8LVlhgf8FQi
              eowHAgMBAAGjfTB7MB0GA1UdDgQWBBSnpQaxLKYJYO7Rl+lwrrw7GWzbITAPBgNV
              HRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFKelBrEspglg7tGX6XCuvDsZbNshMBgG
              A1UdIAQRMA8wDQYLKwYBBAGwLQMEAQEwDgYDVR0PAQH/BAQDAgGGMA0GCSqGSIb3
              DQEBCwUAA4IBAQAmdzTblEiGKkGdLD4GkGDEjKwLVLgfuXvTBznk+j57sj1O7Z8j
              vZfza1zv7v1Apt+hk6EKhqzvINB5Ab149xnYJDE0BAGmuhWawyfc2E8PzBhj/5kP
              DpFrdRbhIfzYJsdHt6bPWHJxfrrhTZVHO8mvbaG0weyJ9rQPOLXiZNwlz6bb65pc
              maHFCN795trV1lpFDMS3wrUU77QR/w4VtfX128a961qn8FYiqTxlVMYVqL2Gns2D
              lmh6cYGJ4Qvh6hEbaAjMaZ7snkGeRDImeuKHCnE96+RapNLbxc3G3mB/ufNPRJLv
              KrcYPqcZ2Qt9sTdBQrC6YB3y/gkRsPCHe6ed
              -----END CERTIFICATE-----
            ''
          ];
        };
      };

      environment.variables = {
        JAVAX_NET_SSL_TRUSTSTORE = javaCaCerts.outPath; # requires a patched version of openjdk (openjdk is already patched, see https://github.com/NixOS/nixpkgs/blob/1b64fc1287991a9cce717a01c1973ef86cb1af0b/pkgs/development/compilers/openjdk/read-truststore-from-env-jdk10.patch)
      };
    };
}
