# Crest

Deploy Docker container(s)

Works with both `docker run $thing` and `docker-compose up`, and should work with almost anything else you throw at it. 

Also performs basic server hardening steps:

- Updates all packages
- Installs an SSH public key
- Disables password authentication
- Disables root account logins
- Configures automatic updates
- Installs and configures fail2ban
- Configures NTP

### How are remote resources used?

You can specify a remote URL to pull in just before Docker is started. This should be a full URL to a `Dockerfile`, `docker-compose.yml`, or if you're more creative, something else entirely.

The resource is fetched using `wget $thing`, which is installed only if a resource is specified. 

### What command can I use?

Use can suppply any command, which is run as provided. This allows you to run `docker run` with your own parameters, `docker-compose up`, or anything else.

### Can I run this standalone / unattended / as part of something else?

Yes. This script contains `read` statements to prompt you for anything not already set in the environment. The only thing not prompted is `$RESOURCE`, because it's optional. If you want to specify `$RESOURCE`, set it in the environment or declare it on the command line and it will be used. 
