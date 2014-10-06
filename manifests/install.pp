# == Class: amazon_ses::install
#
# Installs postfix
#
# === Parameters
#
# === Variables
#
# === Authors
#
# Michael Speth <spethm@landcareresearch.co.nz>
#
# === Copyright
# GPLv3
#
class amazon_ses::install {
  package { ['libsasl2-modules', 'postfix' ]:
      ensure => installed,
  }
}
