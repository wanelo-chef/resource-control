Resource Control
================

Resource Control is a chef cookbook for managing Solaris projects, tasks and resource
limits using the Resource Control Facility.

* http://docs.oracle.com/cd/E19683-01/817-1592/rmctrls-1/index.html

## Provides

Providers:
* project

Recipes:
* default - does nothing

## Requirements

* Solaris or Illumos-based operating system
* Tested on SmartOS

## Providers

### Project

#### Attributes

* project_limits
* task_limits
* process_limits
* comment

#### Actions

* `:create` - default
* `:nothing`

#### Overview

```ruby
resource_control_project "postgres" do
  comment "PostgreSQL 9.2"

  project_limits "max-shm-memory" => 12000000,
                 "max-lwps"       => 6
  task_limits    "max-cpu-time"   => 3600
  process_limits "max-cpu-time" => [
                     {"value" => 3600, "signal" => "TERM"},
                     {"value" => 3660, "deny" => true}
                 ]
  action :create
end
```

See the documentation of resource controls in the References section below for available
resource limits.

#### Local actions and signalling

By default limits will not be enforced (local action set to `none`). This may seem
counter-intuitive, but can be useful for monitoring purposes when overages are logged
to syslog.

The local action can be set to either `deny` or `signal` through the following syntax:

```ruby
resource_control_project "redis" do
  process_limits "max-cpu-time" => {
          "value" => 3600,
          "deny"  => true
      }
end
```

```ruby
resource_control_project "sidekiq" do
  process_limits "max-cpu-time" => {
          "value" => 7200,
          "signal"  => "TERM"
      }
end
```

Available signals are:

* ABRT - Terminate the process
* HUP - Send a hangup signal. Occurs when carrier drops on an open line. Signal sent to the process group that controls the terminal.
* TERM - Terminate the process. Termination signal sent by software.
* KILL - Terminate the process and kill the program
* STOP - Stop the process. Job control signal.
* XRES - Resource control limit exceeded. Generated by resource control facility.
* XFSZ - Terminate the process. File size limit exceeded.
* XCPU - Terminate the process. CPU time limit exceeded.

Note that in a lot of documentation, signals take the form "SIGTERM" whereas we just
use "TERM". This is to avoid complicating the provider code, as the text actually set in
the projects database is the short version.

Also note that not every signal or action can be set for every resource limit. Please read the documentation
and man pages for more information.

#### Cascading limits

In some cases, multiple limits may be desirable for a key. In this case, use an Array for the value
of the key:

```ruby
resource_control_project "sidekiq" do
  process_limits "max-cpu-time" => [
          { "value" => 7200, "signal" => "TERM" },
          { "value" => 7260, "signal" => "KILL" }
      ]
end
```

#### Privilege level

By default, the limits set by the project provider can only be modified by superusers. Assuming
that the chef run is executed by root, this should never need to be changed.

## References

* http://docs.oracle.com/cd/E19683-01/817-1592/rmctrls-1/index.html
* `man rctladm`
* `man prctl`
* `man resource_controls`
