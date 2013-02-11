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

## Usage

#### Project

```ruby
resource_control_project "postgres" do
  project_limit "max-shm-memory" => 12000000,
                "max-lwps"       => 6
  task_limits   "max-cpu-time"   => 3600
  action :create
end
```
