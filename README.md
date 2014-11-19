# ETCD: A highly-available key value store for shared configuration and service discovery

This is a Radial Wheel repository for [etcd][etcd]. It is a copy of the official
[coreos/etcd][etcd-image] image modified only to
work within the Radial topology.

It is also configured to run [etcdctl][etcdctl] directly from the command line, using the
same image as a wrapper:

`docker run -it --rm -e "ETCDCTL_PEERS=http://192.168.1.1:4001" radial/etcd set foo
bar`

**Note:** Make sure the IP you pass to `ETCDCTL_PEERS` is routable from the _inside_ of
your container to wherever one of your etcd cluster nodes is. 

[etcd]: https://github.com/coreos/etcd
[etcdctl]: https://github.com/coreos/etcdctl
[etcd-image]: https://registry.hub.docker.com/u/coreos/etcd

## Tunables

Tunable environment variables; modify at runtime. Italics are defaults. All
environment variables names used here are the same as the default
[coreos/etcd][etcd-image] container. These are mentioned here for sake of
displaying default values specific to Radial.

  - **$SPOKE_CMD**: [_"etcdctl"_] This variable sets the command to run, like an
    entrypoint, when passing arguments to `docker run` as demonstrated
    above. You could technically change it to anything, but you'll most likely
    just change it to `etcd` (if at all) if you like to use command line flags
    instead of environment variables or configuration for the etcd binary.
  - **$ETCD_DATA_DIR**: [_"/data/backup"_] Location to store etcd backup
    snapshots and log files
  - **$ETCD_NAME**: [_container_id_] Name for this etcd node.

## Radial

[Radial][radial] is a [Docker][docker] container topology strategy that
seeks to put the cannon of Docker best-practices into simple, re-usable, and
scalable images, dockerfiles, and repositories. Radial categorizes containers
into 3 types: Axles, Hubs, and Spokes. A Wheel is a repository used to recreate
an application stack consisting of any combination of all three types of
containers. Check out the [Radial documentation][radialdocs] for more.

One of the main design goals of Radial containers is simple and painless
modularity. All Spoke (application/binary) containers are designed to be run by
themselves as a service (a Wheel consisting of a Hub container for configuration
and a Spoke container for the running binary) or as part of a larger stack as a
Wheel of many Spokes all joined by the Hub container (database, application
code, web server, backend services etc.). Check out the [Wheel
tutorial][wheel-template] for some more details on how this works.

Note also that for now, Radial makes use of [Fig][fig] for all orchestration,
demonstration, and testing. Radial is just a collection of images and
strategies, so technically, any orchestration tool can work. But Fig was the
leanest and most logical to use for now. 

[wheel-template]: https://github.com/radial/template-wheel
[fig]: http://www.fig.sh
[docker]: http://docker.io/
[radial]: https://github.com/radial
[radialdocs]: http://radial.viewdocs.io/docs

## How to Use
### Static Build

In case you need to modify the entrypoint script, the Dockerfile itself, create
your "config" branch for dynamic building, or just prefer to build your own from
scratch, then you can do the following:

1. Clone this repository
2. Make whatever changes needed to configuration and add whatever files
3. `fig up`

### Dynamic Build

A standard feature of all Radial images is their ability to be used dynamically.
This means that since great care is made to separate the application code from
it's configuration, as long as you make your application configuration available
as a git repository, and in it's own "config" branch as per the guidelines in
the [Wheel template][wheel-template], no building of any images will be
necessary at deploy time. This has many benefits as it allows rapid deployment
and configuration without any wait time in the building process. However:

**Dynamic builds will not commit your configuration files into any
resulting images like static builds.**

Static builds do a "COPY" of files into the image before exposing the
directories as volumes. Dynamic builds do a `git fetch` at run time and the
resulting data is downloaded to an already existing volume location, which is
now free from Docker versioning. Both methods have their advantages and
disadvantages. Deploying the same exact configuration might benefit from a
single image built statically whereas deploying many different disposable 
configurations rapidly are best done dynamically with no building.

To run dynamically:

1. Modify the `fig-dynamic.yml` file to point at your own Wheel repository
   location by setting the `$WHEEL_REPO` variable. When run, the Hub container
   will pull the "config" branch of that repository and use it to run the Spoke
   container with your own configuration.
3. `fig -f fig-dynamic.yml up`
