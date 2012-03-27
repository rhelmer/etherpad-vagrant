class node-js {
    package { ["build-essential"]:
        ensure => latest,
        require => Exec["apt-get-update"];
    }

    exec { "/usr/bin/apt-get update":
        alias => "apt-get-update";
    }

    file { "install-base":
        path => "${install_base}",
        owner => "${install_user}",
        mode  => 775,
        ensure => directory;
    }

    file { "source-base":
        path => "${source_base}",
        owner => "${install_user}",
        mode  => 775,
        ensure => directory;
    }

    exec {
        "/usr/bin/wget -N http://nodejs.org/dist/${node_version}/node-${node_version}.tar.gz":
            alias => "download-node",
            user => "${install_user}",
            cwd => "${source_base}",
            require => File["install-base"],
            creates => "${source_base}/node-${node_version}.tar.gz";

        "/bin/tar zxf node-${node_version}.tar.gz":
            alias => "unpack-node",
            user => "${install_user}",
            cwd => "${source_base}",
            creates => "${source_base}/node-${node_version}",
            require => Exec["download-node"];

        "${source_base}/node-${node_version}/configure --prefix=${install_base}/node-${node_version} && /usr/bin/make install":
            alias => "install-node",
            environment => "HOME=${install_base}",
            user => "${install_user}",
            cwd => "${source_base}/node-${node_version}",
            creates => "${install_base}/node-${node_version}",
            timeout => 0,
            require => [Exec["unpack-node"], Package["build-essential"]];

        "/usr/bin/wget -N http://registry.npmjs.org/npm/-/npm-${npm_version}.tgz":
            alias => "download-npm",
            user => "${install_user}",
            cwd => "${source_base}",
            creates => "${source_base}/npm-${npm_version}.tgz",
            require => Exec["install-node"];

        "/bin/mkdir npm-${npm_version} && /bin/tar -C npm-${npm_version} -xf npm-${npm_version}.tgz":
            alias => "unpack-npm",
            user => "${install_user}",
            cwd => "${source_base}",
            creates => "${source_base}/npm-${npm_version}",
            require => Exec["download-npm"];

        "/usr/bin/make install":
            alias => "install-npm",
            environment => ["HOME=${install_base}"],
            user => "${install_user}",
            cwd => "${source_base}/npm-${npm_version}/package",
            creates => "${install_base}/node-${node_version}/lib/node_modules/npm/",
            require => Exec["unpack-npm"];
    }
}
