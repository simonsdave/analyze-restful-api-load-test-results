# Development Environment

To increase predicability, it is recommended
that ```analyze-restful-api-load-test-results```
 development be done on a [Vagrant](http://www.vagrantup.com/) provisioned
[VirtualBox](https://www.virtualbox.org/)
VM running [Ubuntu 14.04](http://releases.ubuntu.com/14.04/).
Below are the instructions for spinning up such a VM.

Spin up a VM using [create_dev_env.sh](create_dev_env.sh)
(instead of using ```vagrant up```.

```bash
>./create_dev_env.sh simonsdave simonsdave@gmail.com ~/.ssh/id_rsa.pub ~/.ssh/id_rsa
.
.
.
>
```

SSH into the VM

```bash
>vagrant ssh
Welcome to Ubuntu 14.04 LTS (GNU/Linux 3.13.0-27-generic x86_64)

 * Documentation:  https://help.ubuntu.com/

 System information disabled due to load higher than 1.0

  Get cloud support with Ubuntu Advantage Cloud Guest:
    http://www.ubuntu.com/business/services/cloud

0 packages can be updated.
0 updates are security updates.

New release '16.04.3 LTS' available.
Run 'do-release-upgrade' to upgrade to it.


~>
```

Start the ssh-agent in the background.

```bash
~> eval "$(ssh-agent -s)"
Agent pid 25657
~>
```

Add SSH private key for github to the ssh-agent

```bash
~> ssh-add ~/.ssh/id_rsa_github
Enter passphrase for /home/vagrant/.ssh/id_rsa_github:
Identity added: /home/vagrant/.ssh/id_rsa_github (/home/vagrant/.ssh/id_rsa_github)
~>
```

Clone the repo.

```bash
~> git clone git@github.com:simonsdave/analyze-restful-api-load-test-results.git
Cloning into 'analyze-restful-api-load-test-results'...
remote: Counting objects: 227, done.
remote: Total 227 (delta 0), reused 0 (delta 0), pack-reused 227
Receiving objects: 100% (227/227), 1.16 MiB | 446.00 KiB/s, done.
Resolving deltas: 100% (120/120), done.
Checking connectivity... done.
~>
```

Install pre-reqs.

```bash
~> cd analyze-restful-api-load-test-results
~/analyze-restful-api-load-test-results> source cfg4dev
New python executable in env/bin/python
Installing setuptools, pip...done.
.
.
.
(env)~/analyze-restful-api-load-test-results>
```

Quick sanity check to make sure things are generally working.

```bash
(env)~/analyze-restful-api-load-test-results> analyze_restful_api_load_test_results.sh --graphs=./wow.pdf < samples/001-input.tsv
=====================================================================================
21,426 @ 25 from 2017-07-19 01:25:02.410082+00:00 to 2017-07-19 01:30:02.245437+00:00
=====================================================================================

Request Type                 Ok Error         m        b      Min       50       95       99      Max
-----------------------------------------------------------------------------------------------------
GET                       17017     0    0.0551      293      106      290      432      509      842
PUT                        4409     0    0.0351      531      257      508      765     1131     1748

=====================================================================================
(env)~/analyze-restful-api-load-test-results> ls -l ./wow.pdf
-rw-rw-r-- 1 vagrant vagrant 37717 Sep 18 04:48 ./wow.pdf
(env)~/analyze-restful-api-load-test-results>
```
