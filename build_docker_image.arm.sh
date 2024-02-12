docker build --build-arg BB_user=$BITBUCKET_USER \
			 --build-arg BB_password=$BITBUCKET_PASSWORD \
			 -t iotc/validators-ui-arm:0.1.0 \
			 -f Dockerfile.arm .
