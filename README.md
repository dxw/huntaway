# Huntaway

![Huntaway dog](huntaway.jpg)

A Ruby script that checks [Opsgenie](https://opsgenie.com) for the currently
on-call team members, and assigns them a group in [Zendesk](https://zendesk.com).

## Usage

### Clone the repo

```bash
git clone git@github.com:dxw/huntaway.git
```

### Install the dependencies

```bash
bundle install
```

### Add the relevant environment variables

Copy `.env.example` to a file called `.env` and fill in the variables with some real info.

### Run the task

This will do the following:

* Remove all current users from the group specified in `Huntaway::GROUP_ID`
* Check who is on call for the schedule specified in `Huntaway::OPSGENIE_SCHEDULE_ID`
* Add those users to the Zendesk group specified in `Huntaway::GROUP_ID`

```bash
bundle exec rake huntaway:run
```

This runs as a [Github actions task](https://github.com/dxw/huntaway/actions?query=workflow%3ARun)
every morning at 6am.

-----------------------

(Huntaway photo by <a href="//commons.wikimedia.org/wiki/User:Cgoodwin" title="User:Cgoodwin">Cgoodwin</a> - <span class="int-own-work" lang="en">Own work</span>, <a href="https://creativecommons.org/licenses/by/3.0" title="Creative Commons Attribution 3.0">CC BY 3.0</a>, <a href="https://commons.wikimedia.org/w/index.php?curid=3712682">Link</a>)
