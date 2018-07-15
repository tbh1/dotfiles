set -x GCLOUD_HOME /opt/google/cloud/sdk

test -d $GCLOUD_HOME/bin ; and set PATH /opt/google/cloud/sdk/bin $PATH
test -d $GCLOUD_HOME/bin ; and set MANPATH $GCLOUD_HOME/help/man $MANPATH

# bass source "$GCLOUD_HOME/path.fish.inc"
# bass source "$GCLOUD_HOME/completion.bash.inc"
