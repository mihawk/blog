Install erlang from official github repo
========================================

### rational:

 sometime you dont have the luxury to download the whole tarbal 
 from erlang.org each time a new release is out,
 you may want also to install service pack, which are available only on the git repos, 
 install a patched version from a big player in the erlang ecosystem. 

 example: OTP 18.1.3
 

# Install [kerl](https://github.com/yrashk/kerl) in your $PATH. (ubuntu)


```bash
cd ~/bin
curl -O https://raw.githubusercontent.com/yrashk/kerl/master/kerl
chmod u+x kerl
```


# Clone erlang from official github repo.


```bash
cd ~
mkdir workspace
cd workspace
git clone http://github.com/erlang/otp.git
```

# Build & Install a given tag.

```bash
cd ~/workspace/otp
git tag
OTP-17.0
OTP-17.0.1
OTP-17.0.2
OTP-17.1
OTP-17.1.1
OTP-17.1.2
OTP-17.2
OTP-17.2.1
OTP-17.2.2
OTP-17.3
OTP-17.3.1
OTP-17.3.2
OTP-17.3.3
OTP-17.3.4
OTP-17.4
OTP-17.4.1
OTP-17.5
OTP-17.5.1
OTP-17.5.2
OTP-17.5.3
OTP-17.5.4
OTP-17.5.5
OTP-17.5.6
OTP-17.5.6.1
OTP-17.5.6.2
OTP-17.5.6.3
OTP-17.5.6.4
OTP-18.0
OTP-18.0-rc1
OTP-18.0-rc2
OTP-18.0.1
OTP-18.0.2
OTP-18.0.3
OTP-18.1
OTP-18.1.1
...

```
## build command:

```bash
kerl build git ~/workspace/otp OTP-18.1.1 OTP-18.1.1
Checking Erlang/OTP git repository from /home/mihawk/OTP/otp...
Building Erlang/OTP OTP-18.1.1 from git, please wait...
..
..
..
```

## Install your build:

```bash
kerl install OTP-18.1.1 ~/bin/lang/erlang/OTP-18.1.1
source ~/bin/lang/erlang/OTP-18.1.1/activate
erl
Erlang/OTP 18 [erts-7.1] [source] [64-bit] [smp:4:4] [async-threads:10] [hipe] [kernel-poll:false]

Eshell V7.1  (abort with ^G)
1> 
```

# Update

 in my current repos, my latest tag is OTP-18.1.1, OTP-18.1.3 is available.
 just update your repos to sync with the official repos.

```bash
cd ~/workspace/otp
git pull origin master
git fetch origin
remote: Counting objects: 2, done.
remote: Total 2 (delta 0), reused 0 (delta 0), pack-reused 1
Unpacking objects: 100% (2/2), done.
From http://github.com/erlang/otp
   4f99058..7eb292f  maint      -> origin/maint
   a2c538d..fe1df7f  maint-18   -> origin/maint-18
 * [new tag]         OTP-18.1.2 -> OTP-18.1.2
 * [new tag]         OTP-18.1.3 -> OTP-18.1.3

```

# Install klarna, mnesia_ext

```bash
cd ~/workspace/otp
git remote -v
origin	http://github.com/erlang/otp (fetch)
origin	http://github.com/erlang/otp (push)

```

## add klarna repo

```bash
cd ~/workspace
git clone https://github.com/klarna/otp.git klarna
git remote -v
klarna	https://github.com/klarna/otp.git (fetch)
klarna	https://github.com/klarna/otp.git (push)
origin	http://github.com/erlang/otp (fetch)
origin	http://github.com/erlang/otp (push)

git fetch klarna
receiving objects: 100% (180/180), 128.34 KiB | 151.00 KiB/s, done.
Resolving deltas: 100% (157/157), completed with 101 local objects.
From https://github.com/klarna/otp
 * [new branch]      OTP-17.5.6-mnesia_ext -> klarna/OTP-17.5.6-mnesia_ext
 * [new branch]      OTP-18.0-mnesia_ext -> klarna/OTP-18.0-mnesia_ext
 * [new branch]      OTP-18.1-mnesia_ext -> klarna/OTP-18.1-mnesia_ext
 * [new branch]      OTP_R15B03-1-mnesia_ext -> klarna/OTP_R15B03-1-mnesia_ext
 * [new branch]      OTP_R16B03-1-mnesia_ext -> klarna/OTP_R16B03-1-mnesia_ext
 * [new branch]      gh-pages   -> klarna/gh-pages
 * [new branch]      maint      -> klarna/maint
```

## build OTP-18.1-mnesia_ext

```bash
kerl git ~/workspace/otp OTP-18.1-mnesia_ext OTP-18.1-mnesia_ext
Checking Erlang/OTP git repository from /home/mihawk/OTP/otp...
Couldn't checkout specified version
```

 oops, doesn't work.

let's see where is the problem.
launch kerl in debug mode.
kerl is a bash script, you can add a `set -x` in the file to execute it in debug mode.

```bash

vi ~/bin/kerl
#! /bin/sh
set -x

# Copyright (c) 2011, 2012 Spawngrid, Inc
# Copyright (c) 2011 Evax Software <contact(at)evax(dot)org>
#

```

```bash
kerl git ~/workspace/otp OTP-18.1-mnesia_ext OTP-18.1-mnesia_ext
...
+ rm -Rf /home/mihawk/.kerl/builds/OTP-18.1-mnesia_ext
+ mkdir -p /home/mihawk/.kerl/builds/OTP-18.1-mnesia_ext
+ cd /home/mihawk/.kerl/builds/OTP-18.1-mnesia_ext
+ git clone -l /home/mihawk/.kerl/gits/d2bc9a527ddd5aa69e70c7065b56d0d6 otp_src_git
+ [ 0 -ne 0 ]
+ cd otp_src_git
+ git checkout klarna/OTP-18.1-mnesia_ext
+ [ 1 -ne 0 ]
+ git checkout -b klarna/OTP-18.1-mnesia_ext klarna/OTP-18.1-mnesia_ext
+ [ 128 -ne 0 ]
+ echo Couldn't checkout specified version
Couldn't checkout specified version
+ rm -Rf /home/mihawk/.kerl/builds/OTP-18.1-mnesia_ext
+ exit 1
```

it seem that the command `git checkout klarna/OTP-18.1-mnesia_ext` faild and return 1 instead of 0
but when i execute it on the shell commad, it s fine

```bash
cd ~/workspace/otp
git checkout klarna/OTP-18.1-mnesia_ext; echo $?
HEAD is now at d9e6c95... Correct get_initial_schema call in mnesia_bup
0
```

the problem is much deeper, i guess the culprit is about the tag name which contain a slash '/'
you have two choice, fix the bug if you can or clone to an other folder to avoid the slash.

 will choose to clone, simpler

 ```bash
cd ~/workspace
git clone https://github.com/klarna/otp.git klarna
git clone https://github.com/klarna/otp.git klarna
Cloning into 'klarna'...
remote: Counting objects: 178585, done.
...

cd klarna
kerl build git OTP-18.1-mnesia_ext OTP-18.1-mnesia_ext
kerl install OTP-18.1-mnesia_ext ~/bin/lang/erlang/OTP-18.1-mnesia_ext

```


