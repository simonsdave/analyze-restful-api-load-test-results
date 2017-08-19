# Development Environment

To increase predicability, it is recommended
that ```analyze-restful-api-load-test-results``
 development be done on a [Vagrant](http://www.vagrantup.com/) provisioned
[VirtualBox](https://www.virtualbox.org/)
VM running [Ubuntu 14.04](http://releases.ubuntu.com/14.04/).
Below are the instructions for spinning up such a VM.

Spin up a VM using [create_dev_env.sh](create_dev_env.sh)
(instead of using ```vagrant up```.

```bash
>./create_dev_env.sh simonsdave simonsdave@gmail.com ~/.ssh/id_rsa.pub ~/.ssh/id_rsa
>
```

Clone the ```analyze-restful-api-load-test-results``` repo.
Note use of SSH url when cloning the repo.

```bash
vagrant@vagrant-ubuntu-trusty-64:~$ git clone git@github.com:simonsdave/analyze-restful-api-load-test-results.git
vagrant@vagrant-ubuntu-trusty-64:~$
```

Install pre-reqs.

```bash
vagrant@vagrant-ubuntu-trusty-64:~$ cd analyze-restful-api-load-test-results
vagrant@vagrant-ubuntu-trusty-64:~/analyze-restful-api-load-test-results$ source cfg4dev
New python executable in env/bin/python
Installing setuptools, pip...done.
.
.
.
```
