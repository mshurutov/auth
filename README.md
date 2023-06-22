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
    ...

#### Role installed by ansible-galaxy

    ...
    - hosts: all
      roles:
         - role: mshurutov.auth
    ...

License
-------

[GPLv2](https://www.gnu.org/licenses/old-licenses/gpl-2.0.txt)

Author Information
------------------

My name is Mikhail Shurutov, I'm an operations engineer since 1997.
