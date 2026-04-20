Secure Coding Lab exercise
==========================

**IMPORTANT: always check for the latest version prior to the lab/seminar. Changes may occur**

NOTICE: this repository also contains malware samples, it is possible your AV software may show alerts


Instructions & prerequisites:
-----------------------------

- Access to Stratus (stratus.fi.muni.cz)
  - make sure to configure your SSH key under Settings -> Auth -> Public SSH Key

![sshkey.png](sshkey.png)



Installation:
---

Create a Debian12 VM machine with the default options:

![vm_creation.png](vm_creation.png)


When the VM boots up, login via ssh and run the following command:

```shell
curl "https://raw.githubusercontent.com/SourceCode-AI/secure_coding/refs/heads/master/install_debian.sh"|bash
```

FAQ
===

How do I generate the SSH key?
---

On Linux/Mac, run the following commands:
```
bash$ ssh-keygen -t ed25519
Generating public/private ed25519 key pair.
Enter file in which to save the key (/Users/user/.ssh/id_ed25519)

```

Public key would be saved under `/Users/user/.ssh/id_ed25519.pub`


How do I convert multiline key to one liner?
---


`ssh-keygen -i -f /tmp/input_key` OR `puttygen -O public-openssh tmp/Public-Key`