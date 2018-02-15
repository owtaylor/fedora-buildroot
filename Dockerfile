FROM fedora:27

LABEL name=owtaylor/fedora-buildroot
LABEL version=1.0
LABEL release=1
LABEL com.redhat.component=osbs-fedora-buildroot

# https://bugzilla.redhat.com/show_bug.cgi?id=1483553
RUN ( dnf -y update glibc || true ) && \
    dnf -y update && \
    dnf -y install \
        btrfs-progs-devel \
        desktop-file-utils \
        device-mapper-devel \
        e2fsprogs \
        fedpkg \
        git \
        glib2-devel \
        golang \
        gpgme-devel \
        koji \
        flatpak \
        gssproxy \
        libassuan-devel \
        nfs-utils \
        ostree \
        ostree-devel \
        python-backports-lzma \
        python-docker-py \
        python-docker-squash \
        python-pip \
        python-setuptools \
        python-simplejson \
        golang-github-cpuguy83-go-md2man && \
    dnf clean all

RUN dnf -y --enablerepo=updates-testing install skopeo atomic-reactor python3-atomic-reactor-koji python3-atomic-reactor-metadata python3-atomic-reactor-rebuilds osbs-client python3-modulemd python3-pdc-client && dnf clean all

RUN sed -i "s@r'\^(.*)-(\[\^-\]+)-@r'^(.*):([^-]+):@" /usr/lib/python3.6/site-packages/atomic_reactor/plugins/pre_resolve_module_compose.py
RUN sed -i "s@subprocess.check_output(cmd, cwd=target_dir)@subprocess.check_output(cmd, cwd=target_dir, universal_newlines=True)@" /usr/lib/python3.6/site-packages/atomic_reactor/util.py
RUN sed -i "s@if self.spec.imagestream_name is None or self.spec.imagestream_url is None@if self.spec.imagestream_name.value is None or self.spec.imagestream_url.value is None@" /usr/lib/python3.6/site-packages/osbs/build/build_request.py

#RUN mkdir -p /tmp/go/src/owtaylor && \
#    git clone https://github.com/projectatomic/skopeo.git /tmp/go/src/github.com/projectatomic/skopeo && \
#    ( cd /tmp/go/src/github.com/projectatomic/skopeo && \
#         GOPATH=/tmp/go make binary-local && \
#         cp skopeo /usr/local/bin && \
#         install -D default-policy.json /etc/containers/policy.json )

#RUN git clone -b flatpak-support2 https://github.com/owtaylor/atomic-reactor.git /tmp/atomic-reactor && \
#    cd /tmp/atomic-reactor && \
#    python setup.py install
#
#RUN git clone -b master https://github.com/projectatomic/osbs-client.git /tmp/osbs-client && \
#    cd /tmp/osbs-client && \
#    python setup.py install && \
#    install -D -t /usr/share/osbs inputs/*.json

ADD entrypoint.sh osbs-box-update-hosts /usr/local/bin/

CMD ["entrypoint.sh"]
