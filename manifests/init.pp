# == Class: amazon_ses
#
# Manages postfix to fuly integrate with Amazon SES.
#
# === Parameters
#
# Document parameters here.
#
# [*domain*]
#   The domain of your web site.  In order to send email through SES servers, 
#   your domain must be verified.
#   SES Management Console -> Domains -> Verify a New Domain
#   See http://docs.aws.amazon.com/ses/latest/DeveloperGuide/verify-domains.html
#   for additional details
#
# [*smtp_port*]
#   The port used to connect to the Amazon SMTP server.
#   The default is 587 as there are no limits. If you use port 25, than you will
#   need to request that Amazon disables the rate limit (which is 1 email
#   per minute).
#
# [*smtp_username*] 
#   The username of the smtp user.  Note, this is not your IAM user.
#   You need to create a unique user for the SES service.
#   The new user can be created via:
#   SES -> smtp settings -> 'Create My SMTP Credentials' button.
#
# [*smtp_password*]
#   The password of the smtp user.
#
# [*ses_region*]
#   The region of the Amazon smtp server to relay to.  Valid options:
#   * 'US EAST' - The (N. Virginia) Region
#   * 'US WEST' - The (Oregon) Region
#   * 'EU' - The (Ireland) Region
#   The default region is 'US EAST'
#
# [*inet_interfaces*]
#   The interfaces to which postfix should bind
#   Default: 'all'
#
# [*inet_interfaces*]
#   The protocols postfix should use
#   Default: 'ipv4'
#
# === Variables
#
# [*region_url*] 
#   The full url based on the region for the SES smtp server
#
# [*region_url2*]
#   Through my testing, postfix would not authenticate without an additional
#   hash in the password file. The docs here specify this 2nd url:
#   http://docs.aws.amazon.com/ses/latest/DeveloperGuide/smtp-issues.html
#
# === Examples
#
#   # Sets up SES for the US EAST region
#   class { 'amazon_ses':
#     domain        => 'test.com', 
#     smtp_username => 'USERNAME',
#     smtp_password => 'PASSWORD',
#   }
#
#   # Sets up SES for the EU region
#   class { 'amazon_ses':
#     domain        => 'test.com', 
#     smtp_username => 'USERNAME',
#     smtp_password => 'PASSWORD',
#     ses_region    => 'EU',
#   }
#
# === Authors
#
# Michael Speth <spethm@landcareresearch.co.nz>
# Robin Bowes <robin.bowes@yo61.com>
#
# === Copyright
# GPLv3
#
class amazon_ses (
  $domain,
  $smtp_port = 587,
  $smtp_username,
  $smtp_password,
  $ses_region = 'US EAST',
  $inet_interfaces = 'all',
  $inet_protocols = 'all',
){

  anchor { 'amazon_ses::begin': }

  # check for OS Family
  case $::osfamily {
    'debian': {
      # debian (so ubuntu and debian are only supported)
    }
    default: {
      fail("${::osfamily} - Unsupported OS Family.\
 Debian is the only supported os family")
    }
  }

  # set the region specific details
  case $ses_region {
    'US EAST': {
      $region_url  = "email-smtp.us-east-1.amazonaws.com:${smtp_port}"
      $region_url2 = "ses-smtp-prod-335357831.us-east-1.elb.amazonaws.com:\
${smtp_port}"
    }
    'US WEST': {
      $region_url = "email-smtp.us-west-2.amazonaws.com:${smtp_port}"
      $region_url2 = "ses-smtp-us-west-2-prod-14896026.us-west-2.elb.\
amazonaws.com:${smtp_port}"
    }
    'EU':      {
      $region_url = "email-smtp.eu-west-1.amazonaws.com:${smtp_port}"
      $region_url2 = "ses-smtp-eu-west-1-prod-345515633.eu-west-1.elb.\
amazonaws.com:${smtp_port}"
    }
    default:   {
      # throw error 
      fail("Invalid ses_region - ${ses_region}")
    }
  }
  
  class {'amazon_ses::install':
    require => Anchor['amazon_ses::begin'],
  }
  class {'amazon_ses::config':
    require => Class['amazon_ses::install'],
  }
  class {'amazon_ses::service':
    subscribe => Class['amazon_ses::config'],
  }
  anchor { 'amazon_ses::end':
    require => Class['amazon_ses::service']
  }
}
