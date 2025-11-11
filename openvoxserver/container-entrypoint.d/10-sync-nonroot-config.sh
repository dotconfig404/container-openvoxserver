#!/bin/bash

set -e

if [ "$(id -u)" -ne 0 ]; then
    # jruby-puppet's master-conf-dir/server-conf-dir and master-code-dir/server-code-dir
    # need to be the same as confdir and codedir from puppet.conf in order to sync `puppetserver`
    # and `puppet` defaults.
    # See "Overriding Puppet settings in Puppet Server" in:
    # https://help.puppet.com/core//8/Content/PuppetCore/server/puppet_conf_setting_diffs.htm
    #
    # "Any changes made to the master-conf-dir and master-code-dir settings absolutely MUST be made
    # to the corresponding Puppet settings (confdir and codedir) as well to ensure that Puppet Server
    # and the Puppet CLI tools (such as `puppetserver ca` and `puppet module`) use the same directories."
    hocon -f /etc/puppetlabs/puppetserver/conf.d/puppetserver.conf set jruby-puppet.master-conf-dir $(puppet config print confdir)
    hocon -f /etc/puppetlabs/puppetserver/conf.d/puppetserver.conf set jruby-puppet.master-code-dir $(puppet config print codedir)


    # Despite setting the above, `puppet` and `puppetserver ca` still resolve to different CA directories when run as nonroot:
    # - `puppetserver ca`: defaults to ~/.puppetlabs/etc/puppetserver/ca if run as nonroot and cadir is not set in puppet.conf
    #    https://github.com/OpenVoxProject/openvoxserver-ca/blob/77957bd7c35741e7f627bd8b59adf4951338add3/lib/puppetserver/ca/config/puppetserver.rb#L51
    # - `puppet`: defaults to /etc/puppetlabs/puppetserver/ca, if $ssldir/ca does not exist and cadir is not set in puppet.conf
    #    https://github.com/OpenVoxProject/openvox/blob/7041ef464f3bb99363fe1a25c772328b915ca86d/lib/puppet/defaults.rb#L33
    #
    # To unify this, explicitly set cadir for nonroot users:
    puppet config set cadir ~/.puppetlabs/etc/puppetserver/ca
    # alternatively we could unify it according the dir that `puppet` tells us to use:
    #puppet config set cadir $(puppet config print cadir)
    # or another alternative is possbly to create a CA dir/ a link to CA in $ssldir or something more hacky like that
fi