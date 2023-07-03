[TOC]

Role: auth
==========

auth role is created for deploy centralized authentication using openldap+MIT kerberos+sssd.

Copyright (C) 2023  Mikhail Shurutov

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

Requirements
------------

This role requires python v3 because python v2 is out of live.

Role Variables
--------------

Role has many variables. For details see defaults/main.yml

Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Using a Role
----------------

### Variables Used

* `ANSIBLE_ROOT_DIR` is path for static content: roles,configs,etc, for example: /data/ansible
* `ANSIBLE_ROOT_ROLE_DIR` is path in `roles_path` config variable, for example: /data/ansible/roles  
Content of my ~/.ansible.cfg:
```
...
# additional paths to search for roles in, colon separated
#roles_path    = /etc/ansible/roles
roles_path    = /data/ansible/roles
...
```

### Install role
#### GIT repo

    user@host ~ $ cd $ANSIBLE_ROOT_ROLE_DIR
    user@host roles $ git clone https://shurutov@git.code.sf.net/p/auth-role/code auth

#### Ansible galaxy
##### Installation from command

    user@host ~ $ cd $ANSIBLE_ROOT_DIR
    user@host ansible $ ansible-galaxy role install mshurutov.auth -p roles

##### Installation from requirements.yml

    user@host ~ $ cd $ANSIBLE_ROOT_DIR
    user@host ansible $ grep auth requirements.yml
    - name: mshurutov.auth
    user@host ansible $ ansible-galaxy role install -r requirements.yml -p roles

### Example Playbook

#### Role installed as git repo

    ...
    - hosts: all
      roles:
         - role: auth
           tags: auth
    ...

#### Role installed by ansible-galaxy

    ...
    - hosts: all
      roles:
         - role: mshurutov.auth
           tags: auth
    ...
### Deploy auth system using this role
#### Tags
* `auth_install` is used to install necessary soft;
* `auth_ssl_ca` is used to deploy stored in `{{ common_local_store }}` selfsigned CA cert on the system;
* `ldap_server_config` is used to deploy LDAP (OpenLDAP) server;
    * `ldap_service_config` is used to configure LDAP system service file (openrc, sysvinit, systemd etc);
    * `slapd_stop` is used to stop slapd (OpenLDAP server service);
    * `ldap_init` is used to initialization LDAP data and configuration; to perform this task, the `ldap_init_force` variable must be defined (see below);
    * `ldap_setup` is used to setup the ldap instance;
        * `ldap_schema_ldif` is used for create ldif files in schema directory;
        * `ldap_setup_overlays` is used to enable and setup overlays;
            * `ldap_setup_memberof` is used
            * `ldap_setup_ppolicy` is used
            * `ldap_setup_syncprov` is used
                * `ldap_config_syncprov` is used
        * `ldap_setup_add_modules` is used to enable any modules;
        * `ldap_setup_add_schemas` is used to add schemas;
        * `ldap_ssl` is used to setup SSL support;
            * `ldap_ssl_cert` is used to create any SSL-files;
            * `ldap_ssl_config` is used to configure LDAP instance for SSL connections;
    * `ldap_setup_tree` is used to create objetcs in LDAP DB;
        * `ldap_setup_o` is used to setup Organization;
        * `ldap_setup_bs_ous` is used to setup base OUs;
        * `ldap_setup_krb` is used to setup Kerberos support;
        * `ldap_setup_sudo` is used to setup LDAP to store sudo configuration;
        * `ldap_system_users` is used to add system users into LDAP DB;
        * `ldap_users` is used to add normal users into LDAP DB;
            * `ldap_users_pwd` is used to setup user password;
            * `ldap_users_cn` is used to setup user cn's;
            * `ldap_users_mail` is used to setup user mail;
            * `ldap_users_photo` is used to setup user photo;
            * `ldap_users_mobile` is used to setup user mobile;
            * `ldap_users_sshkeys` is used to setup user ssh keys;
            * `ldap_primary_group` is used to setup user primary group;
        * `ldap_groups` is used to add groups;
        * `ldap_hosts` is used to add hosts;
        * `ldap_services` is used to add services, for example, postgres;
* `ldap_client_config` is used to configure hosts as LDAP client;
* `auth_proto_setup` is used to make visible tags from `{{ auth_proto }}.yml`; default proto is krb5 (kerberos), so file has name krb5.yml;
    * `krb_config` is common tag for configure kerberos auth;
        * `krb_client_config` is used to configure kerberos client;
        * `krb_kdc_config` is used to configure kerberos daemons;
        * `krb_init_ldap` is used to use kerberos for use LDAP as principals DB;
    * `krb_add_principals` is used to add all principals from LDAP;
        * `krb_add_principals_users` is used to add users principals from LDAP;
        * `krb_add_principals_hosts` is used to add hosts principals from LDAP;
        * `krb_add_principals_services` is used to add services principals from LDAP;
        * `krb_idx_principals` is used is used to create indexes in LDAP DB for principals;
    * `krb_client_config` is used
        * `krb_client_kdc` is used
        * `krb_client_ldap` is used
        * `krb_client_kdc_ldap` is used
        * `krb_ktb4hosts` is used
        * `krb_ktb4services` is used
* `auth_daemon_setup` is used to make visible tags from `{{ auth_daemon }}.yml`; default daemon is sssd, so file has name sssd.yml;
    * `auth_daemon_config` is common tag for configure daemon;
        * `sssd_daemon_config` is used to configure sssd daemon;
        * `sssd_pam_config` is used to configure PAM;

#### deploying auth system

**Remark.** Example of `playbook.yml` see above. Inventory file is defined in ansible config file.

##### full deploy
```
user@host ansible $ ansible-playbook playbook.yml -t auth
```

##### partial deploy

There are any examples for any tags, not all.
`auth_servers_group` is group where auth services is installed, configured and started.

###### LDAP init

LDAP init process destroys all data and config parameters, so `ldap_init_force` is variable that must be defined if you want to init LDAP with new config parameters. By default this variable is not defined.
```
user@host ansible $ ansible-playbook playbook.yml -t ldap_server_config,ldap_init -e "ldap_init_force=yes" -l auth_servers_group
```

###### Add users

You must add user into LDAP DB and set any kerberos parameters in LDAP. You must use `auth_proto_setup` tag for using tags in krb5.yml.

```
user@host ansible $ ansible-playbook playbook.yml -t ldap_users,auth_proto_setup,krb_add_principals_users -l auth_servers_group
```

###### Configure sssd daemon

```
user@host ansible $ ansible-playbook playbook.yml -t auth_daemon_setup,sssd_daemon_config -l auth_servers_group
```

License
-------

[GPLv2](https://www.gnu.org/licenses/old-licenses/gpl-2.0.txt)

Author Information
------------------

My name is Mikhail Shurutov, I'm an operations engineer since 1997.
