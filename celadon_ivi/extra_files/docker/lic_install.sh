#!/system/bin/sh

function msg() {
  echo ">> $@"
}

function build() {
  local ai_tools="false"

  local help=$(
    cat <<EOF
Usage: $SELF build [-a <ai-tools>]
  Build LIC for celadon ivi

  -a <ai-tools>:      enable ai tools, default: $ai_tools 
  -h:                 print the usage message
EOF
  )

  while getopts 'ah' opt; do
    case $opt in
    a)
      ai_tools="true"
      ;;
    h)
      echo "$help" && exit
      ;;
    esac
  done

  echo "Build LIC:"
  echo "ai_tools=$ai_tools"

  uninstall

  if [[ ! -z "$http_proxy" ]]; then
    msg "restart dockerd under proxy environment..."
    killall dockerd-dev
    while [[ ! -z "$(ps -A | awk '{print $NF}' | grep -w dockerd)" ]]; do
      msg "wait for dockerd to terminated..."
      sleep 1
    done
    dockerd --iptables=false &
    sleep 20
  fi

  msg "build devicemanager docker image"
  cat /vendor/etc/docker/dm.tar | docker build - --network=host --build-arg http_proxy=$http_proxy --build-arg https_proxy=$https_proxy --build-arg no_proxy=localhost -t dm

  if [ $ai_tools == "true" ]; then
    msg "building steam docker with Intel tensorflow extension for GPU"
    cat /vendor/etc/docker/weston-in-docker.tar | docker build - --network=host --build-arg SETUP_AI_TOOLS=true --build-arg http_proxy=$http_proxy --build-arg https_proxy=$https_proxy --build-arg no_proxy=localhost -t steam
  else
    msg "build steam docker"
    cat /vendor/etc/docker/weston-in-docker.tar | docker build - --network=host --build-arg http_proxy=$http_proxy --build-arg https_proxy=$https_proxy --build-arg no_proxy=localhost -t steam
  fi
  msg "Done!"
}

function cleanup_container() {
  if [[ ! -z "$(docker ps -a | tail -n +2 | awk '{print $NF}' | grep $1)" ]]; then
    msg "Stop and rm existed $1 container(Keep the image as it will be used in 'docker create')..."
    docker stop $(docker ps -a | awk '$NF~/^'$1'*/ {print $NF}')
    sync
    docker rm -f $(docker ps -a | awk '$NF~/^'$1'*/ {print $NF}')
    sync
  fi
}

function install() {
  local backend="drm"
  local device="/dev/dri/renderD128"
  local size="1920x1080"
  local privileged="false"
  local number=$(getprop persist.lic.number)
  local mem_total=$(expr $(cat /proc/meminfo | grep MemTotal | awk '{print $2}') / 1024 / 1024)
  memory_size=${mem_total}g

  if [ -z $number ]; then
    number=1
  fi

  local help=$(
    cat <<EOF
Usage: $SELF install [-b <backend>] [-c <container-id>] [-d <device>] [-s <size>] [-u]
  Install LIC for android ivi

  -b <backend>:       weston backend, default: $backend
  -d <device>:        gbm device for headless backend, default: $device
  -s <size>:          resolution of LIC in headless backend, default: $size
  -p:                 create container with privileged mode
  -n <number>:        LIC instance number, default: $number
  -m <memory_size>    Memory size(a positive integer, followed by a suffix of b, k, m, g, to indicate bytes, kilobytes, megabytes, or gigabytes). Maximum and default: $memory_size
  -h:                 print the usage message
EOF
  )

  while getopts 'b:d:s:hpn:m:' opt; do
    case $opt in
    b)
      backend=$OPTARG
      ;;
    d)
      device=$OPTARG
      ;;
    s)
      size=$OPTARG
      ;;
    p)
      privileged="true"
      ;;
    n)
      number=$OPTARG
      ;;
    m)
      memory_size=$OPTARG
      ;;
    h)
      echo "$help" && exit
      ;;
    esac
  done

  local width
  local height
  IFS="x" read width height <<<"$size"

  echo "Install LIC:"
  echo "number = $number"
  echo "backend = $backend"
  echo "memory_size = $memory_size"
  if [ $backend == "headless" ]; then
    echo "size = $size"
    echo "width = $width height = $height"
    echo "privileged = $privileged"
    echo "device = $device"
  fi

  cleanup_container dm
  cleanup_container steam

  msg "create dm container..."
  docker create --name dm --privileged -v /dev/binder:/dev/binder dm

  msg "create steam container with $backend backend..."

  create_opts="-ti --network=host -e http_proxy=$http_proxy -e https_proxy=$https_proxy -v /dev/binder:/dev/binder -v /data/docker/sys/class/power_supply:/sys/class/power_supply -v /data/docker/config/99-ignore-mouse.rules:/etc/udev/rules.d/99-ignore-mouse.rules -v /data/docker/config/99-ignore-keyboard.rules:/etc/udev/rules.d/99-ignore-keyboard.rules -v /data/vendor/neuralnetworks/:/home/wid/.ipc/ --shm-size 8G --user wid --memory=$memory_size"

  if [ $backend == "drm" ]; then
    create_opts="$create_opts --privileged -v /data/docker/steam:/home/wid/.steam --name steam --hostname steam"
    docker create $create_opts steam
  elif [ $backend == "headless" ]; then
    rm -rf -v /data/docker/image/workdir/ipc
    mkdir -p -v /data/docker/image/workdir/ipc
    create_opts="$create_opts -e BACKEND=$backend -e DEVICE=$device -e K8S_ENV_DISPLAY_RESOLUTION_X=$width -e K8S_ENV_DISPLAY_RESOLUTION_Y=$height -e HEADLESS=true -e CONTAINER_NUM=$number -v /data/docker/image/workdir/ipc:/workdir/ipc --ulimit nofile=524288:524288"

    if [ $number -gt 1 ]; then
      for i in $(seq 0 $(expr $number - 1)); do
        mkdir -p /data/docker/steam$i
        delta_opts="$create_opts -v /data/docker/steam$i:/home/wid/.steam -e CONTAINER_ID=$i --name steam$i --hostname steam$i"
        if [ $privileged == "true" ]; then
          docker create $delta_opts --privileged steam
        else
          docker create $delta_opts --security-opt seccomp=unconfined --security-opt apparmor=unconfined --device-cgroup-rule='a *:* rmw' -v /sys:/sys:rw --device /dev/dri --device /dev/snd --device /dev/tty0 --device /dev/tty1 --device /dev/tty2 --device /dev/tty3 --cap-add=NET_ADMIN --cap-add=SYS_ADMIN steam
        fi
      done
    else
      create_opts="$create_opts -v /data/docker/steam:/home/wid/.steam -e CONTAINER_ID=0 --name steam --hostname steam"
      if [ $privileged == "true" ]; then
        docker create $create_opts --privileged steam
      else
        docker create $create_opts --security-opt seccomp=unconfined --security-opt apparmor=unconfined --device-cgroup-rule='a *:* rmw' -v /sys:/sys:rw --device /dev/dri --device /dev/snd --device /dev/tty0 --device /dev/tty1 --device /dev/tty2 --device /dev/tty3 --cap-add=NET_ADMIN --cap-add=SYS_ADMIN steam
      fi
    fi
  fi

  msg "Done!"
}

function uninstall() {
  if [[ ! -z "$(docker ps -a | tail -n +2 | awk '{print $NF}' | grep steam)" ]]; then
    msg "Delete existed LIC container and image..."
    docker stop $(docker ps -a | awk '$NF~/^steam*/ {print $NF}')
    sync
    docker rm -f $(docker ps -a | awk '$NF~/^steam*/ {print $NF}')
    sync
    docker rmi $(docker image list | awk '$1~/^steam*/ {print $1}')
    sync
  fi
}

function start() {
  docker start dm
  sleep 1
  docker start $(docker ps -a | awk '$NF~/^steam*/ {print $NF}')
}

function stop() {
  docker stop -t 0 dm
  docker stop -t 0 $(docker ps -a | awk '$NF~/^steam*/ {print $NF}')
}

function main() {
  local help=$(
    cat <<EOF
Usage: $self COMMAND [OPTIONS] [ARG...]
  Install and start LIC

Commands:
  build      build
  install    install
  uninstall  uninstall
  start      start
  stop       stop

Options:
  -h:        print the usage message

Build with proxy:
  export http_proxy=<http_proxy>
  export https_proxy=<https_proxy>
  lic_install.sh <command>

Run with no command:
  lic_install.sh equivalent to lic_install.sh build && lic_install.sh install

Run "$SELF COMMAND -h" for more information of a command
EOF
  )

  local cmd=$1
  if [[ -n $cmd ]]; then
    shift
  else
    build
    install
    exit 0
  fi

  case $cmd in
  build | install | uninstall | start | stop)
    $cmd $@
    ;;
  help | -h) echo "$help" && exit ;;
  *) echo "no such command: $cmd" && exit 1 ;;
  esac

}

main "$@"
