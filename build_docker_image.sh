docker build --build-arg BB_user=$BITBUCKET_USER \
			 --build-arg BB_password=$BITBUCKET_PASSWORD \
			 --build-arg DB_server=$DEFAULT_IOTC_LIBS_DB_SERVER \
			 --build-arg DB_user=$DEFAULT_IOTC_LIBS_DB_USER \
			 --build-arg DB_password=$DEFAULT_IOTC_LIBS_DB_PASSWORD \
			 -t iotc/validator:latest \
			 -f Dockerfile .