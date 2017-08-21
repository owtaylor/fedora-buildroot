FROM fedora:26

LABEL name=owtaylor/fedora-buildroot
LABEL version=1.0
LABEL release=1
LABEL com.redhat.component=osbs-fedora-buildroot

RUN dnf -y update && \
    dnf -y install \
        desktop-file-utils \
        e2fsprogs \
        fedpkg \
        git \
        golang \
        koji \
        flatpak \
        gssproxy \
        nfs-utils \
        ostree \
        python-atomic-reactor-koji \
        python-atomic-reactor-metadata \
        python-atomic-reactor-rebuilds \
        python-backports-lzma \
        python-docker-py \
        python-docker-squash \
        python-pip \
        python-setuptools \
        python-simplejson \
        golang-github-cpuguy83-go-md2man && \
    dnf clean all

RUN dnf -y install btrfs-progs-devel device-mapper-devel glib2-devel gpgme-devel libassuan-devel ostree-devel

RUN mkdir -p /tmp/go/src/owtaylor && \
    git clone https://github.com/owtaylor/skopeo.git /tmp/go/src/github.com/projectatomic/skopeo && \
    ( cd /tmp/go/src/github.com/projectatomic/skopeo && \
         GOPATH=/tmp/go make binary-local && \
         cp skopeo /usr/local/bin && \
         install -D default-policy.json /etc/containers/policy.json )

RUN git clone -b flatpak-support https://github.com/owtaylor/atomic-reactor.git /tmp/atomic-reactor
RUN cd /tmp/atomic-reactor && python setup.py install

RUN git clone -b flatpak-support https://github.com/owtaylor/osbs-client.git /tmp/osbs-client
RUN cd /tmp/osbs-client && python setup.py install

CMD ["atomic-reactor", "--verbose", "inside-build", "--input", "osv3"]
