# CI/CD Scripts

Scripts for Jenkins server and local tests for [Linux p4tc](https://github.com/p4tc-dev/linux-p4tc-pub).


## Local Tests
### Installation

Docker scripts for local tests are found in the [docker/local-tests](https://github.com/expertisesolutions/jamalcicd-scripts/tree/master/docker/local-tests) folder. Just clone this repository and copy this folder wherever you want.

### Requirements

```bash
Docker
```

### Execution

The script to execute the tests are similar to the [vm.sh file](https://github.com/p4tc-dev/linux-p4tc-pub/blob/master-next/tools/testing/selftests/tc-testing/vm.sh).

There are two mandatory arguments: -l, that represents a path to your p4tc linux repository and -p that represents a path to your iproute2 repository. The others arguments are the same as the vm.sh file.

```bash
./vm-docker.sh -l <LINUX PATH> -p <IPROUTE2_PATH> [...] -a <ARCH>
```

Example (x86_64):

```bash
./vm-docker.sh -l /home/user/linux-p4tc-pub -p /home/user/iproute2-p4tc-pub -i /home/user/linux-p4tc-pub/arch/x86/boot/bzImage
```

Example (s390x):

```bash
./vm-docker.sh -l /home/user/linux-p4tc-pub -p /home/user/iproute2-p4tc-pub -a s390x
```