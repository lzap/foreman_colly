# Foreman Colly

Foreman plugin brings integration with collectd providing live data and
notifications from smart proxies and managed hosts.

## Features

* Reading live probes for individual hosts from collectd daemon (via UNIX socket).
* Showing probes in Host detail page.
* Live plot as a dashboard widget.
* Listening to notification messages and writing them in the Rails log.

## Planned features

* Bootstraping collectd deamon on managed hosts (provisioning template snippet).
* Plot configurations via templating system (extensible).

## Installation

See
[How_to_Install_a_Plugin]
(http://projects.theforeman.org/projects/foreman/wiki/How_to_Install_a_Plugin)
for how to install Foreman plugins

## Usage

Install and configure a collectd deamon on the foreman server itself and
configure it to accept local connections via UNIX socket from Foreman:

    LoadPlugin unixsock
    <Plugin unixsock>
        SocketFile "/var/run/collectd-unixsock"
        SocketGroup "foreman"
        SocketPerms "0660"
        DeleteSocket false
    </Plugin>

If you want collectd daemons to reach out the Foreman instance via collectd
native network protocol (UDP based), configure:

    LoadPlugin network
    <Plugin "network">
        Listen "0.0.0.0"
    </Plugin>

Configuration of managed hosts is easy. Install and setup collectd instance
and configure it to send the data over the network:

    LoadPlugin network
    <Plugin "network">
        Server foreman.example.com
    </Plugin>

When Smart Proxy Colly plugin is in use, configure it
[accordingly](https://github.com/lzap/smart_proxy_colly).

## Copyright

Copyright (c) 2015 Lukas Zapletal, Red Hat

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

