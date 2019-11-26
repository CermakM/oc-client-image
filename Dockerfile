FROM registry.access.redhat.com/ubi8/ubi-minimal

ENV APP_ROOT="/opt/app-root/src" \
	SUMMARY="OpenShift Origin OC Client ubi8-minimal image." \
	DESCRIPTION="Minimal OpenShift Origin OC Client UBI-based image. This image is meant to be used in Argo Workflows to inspect resources."

LABEL summary="$SUMMARY" \
	description="$DESCRIPTION" \
	io.k8s.description="$DESCRIPTION" \
	io.k8s.display-name="OpenShift Origin OC Client" \
	io.openshift.tags="argo,kubectl,oc" \
	name="cermakm/oc-client:latest" \
	vendor="AICoE at the Office of the CTO, Red Hat Inc." \
	version="0.1.0" \
	release="0" \
	maintainer="Marek Cermak <macermak@redhat.com>"

WORKDIR ${APP_ROOT}/src

USER 0

RUN microdnf install -y findutils gzip tar && \
	chown -R 1001:0 ${APP_ROOT} && \
	find -L ${APP_ROOT} \! -gid 0 -exec chgrp 0 {} + && \
	find -L ${APP_ROOT} \! -perm -g+rw -exec chmod g+rw {} + && \
	find -L ${APP_ROOT} -perm /u+x -a \! -perm /g+x -exec chmod g+x {} + && \
	find -L ${APP_ROOT} -type d \! -perm /g+x -exec chmod g+x {} +

# Install requirements
RUN curl -L https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz |\
	tar -xvz && \
	mv openshift-*/oc /usr/bin/oc && \
	rm -rf openshift-* && \
	curl \
	-L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 \
	-o /usr/bin/jq && \
	chmod +x /usr/bin/jq

USER 1001

ENTRYPOINT [ "oc" ]
CMD [ "--help" ]
