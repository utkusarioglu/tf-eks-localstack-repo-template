aws-local() {
  aws --endpoint-url=http://localstack:4566 "$@"
}
