#!/bin/sh

CMD="$1"

if [ -z $CMD ]; then
  echo "No command specified"
  exit 1
fi

if [[ -n "${NODE_NAME}" ]]; then
  # if NODE_NAME is present it means worker runs inside k8s cluster
  echo "NODE_NAME is set to ${NODE_NAME}"

  if [[ -z "${PAPERMERGE__MAIN__S3_QUEUE_NAME}" ]]; then
    echo "PAPERMERGE__MAIN__S3_QUEUE_NAME not set yet"
    echo "Will set now PAPERMERGE__MAIN__S3_QUEUE_NAME to a value based on"
    echo " PAPERMERGE__MAIN__PREFIX and node name."
    export PAPERMERGE__MAIN__S3_QUEUE_NAME="s3_${PAPERMERGE__MAIN__PREFIX}_${NODE_NAME}"
  fi

  if [[ -z "${PAPERMERGE__MAIN__S3_PREVIEW_QUEUE_NAME}" ]]; then
    echo "PAPERMERGE__MAIN__S3_PREVIEW_QUEUE_NAME not set yet"
    echo "$NODE_NAME is non-empty"
    echo "Will set now PAPERMERGE__MAIN__S3_PREVIEW_QUEUE_NAME to a value based on"
    echo " PAPERMERGE__MAIN__PREFIX and node name."
    export PAPERMERGE__MAIN__S3_PREVIEW_QUEUE_NAME="s3preview_${PAPERMERGE__MAIN__PREFIX}_${NODE_NAME}"
  fi
  echo "PAPERMERGE__MAIN__S3_QUEUE_NAME queue name set to: $PAPERMERGE__MAIN__S3_QUEUE_NAME"
  echo "PAPERMERGE__MAIN__S3_PREVIEW_QUEUE_NAME queue name set to: $PAPERMERGE__MAIN__S3_PREVIEW_QUEUE_NAME"
fi

exec_worker() {
  if [[ -z "${S3_WORKER_ARGS}" ]]; then
    echo "S3_WORKER_ARGS is empty"
    echo "setting it to new value"
    export S3_WORKER_ARGS="-Q ${PAPERMERGE__MAIN__S3_PREVIEW_QUEUE_NAME},${PAPERMERGE__MAIN__S3_QUEUE_NAME}"
    echo "S3_WORKER_ARGS was set to $S3_WORKER_ARGS"
  fi
  echo "Starting worker with S3_WORKER_ARGS was set to $S3_WORKER_ARGS"
  exec poetry run celery -A s3worker.celery_app worker ${S3_WORKER_ARGS}
}

case $CMD in
  worker)
    exec_worker
    ;;
  *)
    exec "$@"
    ;;
esac
