# ChromaCoin, Secret-Tribble Edition

Greetings, and welcome to the ChromaCoin prototype. The current build and test status of the `master` branch is:

<img src="https://codeship.io/projects/f46bbfb0-4025-0132-6d50-0eb8b0f9040c/status?branch=master">

## Setup

You will need a few things installed on your workstation:

- VirtualBox
- vagrant
- git

The first thing to do is grab a copy of the project, and get into it.

```bash
$ git clone git@github.com:ChromaPDX/secret-tribble.git
$ cd secret-tribble
```

Next up, initialize the vagrant machine.

*Wait, vagrant? Yes, vagrant. This is a really nice way to isolate all of the tools and environment needed to run secret-tribble, so that we're not scribbling all over your workstation is a horrible fashion. Vagrant requires VirtualBox.*

```bash
$ vagrant up
```

This downloads an Ubuntu 14.04 image, boots it up in a virtual machine, and runs the `provision.sh` script on it to install Ruby 2.1.4, PostgreSQL 9.3, and their dependencies.

When that's done, connect to the VM:

```bash
$ vagrant ssh
```

By default, your local `secret-tribble` directory has been mounted at `/vagrant` on the virtual machine. Go ahead and look around.

```bash
$ cd /vagrant
$ ls
...
```

Now, let's get to the source and initialize the application's environment.

```bash
$ cd src/
$ bundle install
$ bundle exec rake db:migrate
$ bundle exec rake db:migrate CHROMA_ENV=test
```

What happened there?

- `bundle` installs all the gem dependencies for the app.
- `rake db:migrate` gets the database schema up to date for the `vagrant` environment. Curious about what environments are available? Check out the `config/` files.
- `rake db:migrate CHROMA_ENV=test` updates the schema for the test database. *Please note: this will get emptied every time tests are run.*

Cool. Now, lets run our tests to make sure the environment is sane ...

```bash
$ bundle exec rake test
```

This should run several tests, and there should be zero failures. *RIGHT?*

## Coding and Testing

When you edit changes on your local system (using your favorite editor, whatever it might be) the changes are immediately available in your vagrant box. Leave a shell open on the vagrant machine to run tests, muck about in the database, etc.

When you push your code back up to GitHub, it will automatically be built by CodeShip.io.


