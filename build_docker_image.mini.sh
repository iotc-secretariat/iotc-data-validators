docker build --build-arg BB_user=$BITBUCKET_USER \
			 --build-arg BB_password=$BITBUCKET_PASSWORD \
			 -t iotc/validator-ui-mini:0.1.0-interim \
			 -f Dockerfile.mini .
