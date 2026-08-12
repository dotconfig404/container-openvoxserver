# Migrations

## GID 0 access model (upcoming release)

The container runs with **group 0** and works under **any UID**. 64604 is
only the default UID — file access is granted exclusively through group 0,
and the UID of files on mounted volumes does not matter. There is no
`puppet` service account in the image anymore.

For existing volumes, run once:

```bash
chgrp -R 0 [PATH TO THE VOLUME]
chmod -R g+rwX [PATH TO THE VOLUME]
```

On Kubernetes/OpenShift, `fsGroup: 0` in the pod securityContext achieves
the same without manual steps.

> **Important:** do NOT `chown` volumes to `64604:64604`. Files in *group*
> 64604 break certificate issuance (#192): the server runs with GID 0 and
> cannot restore group 64604 on the files it rewrites. Group 0 is the only
> group that matters; the owning UID is irrelevant.

This supersedes the V8.13.0 instructions below.

## V8.12.0 -> V8.13.0

UID is changed from 1001 on alpine and 999 on ubuntu to 64604.
If you already deployed the containers with mounted volume, you NEED to change the ownershop of these volumes and the files underneath.

```bash
chown -R 64604:64604 [PATH TO THE VOLUME]
```
