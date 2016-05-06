# Matthew Vaughn
# May 6, 2016

sdk_version := $(shell cat VERSION)
api_version := v2
api_release := 2.1.8

TENANT_NAME := 'Cyverse'
TENANT_KEY := 'iplantc.org'
PREFIX := $(HOME)

OBJ = cyverse-cli
SOURCES = customize

# Local installation
SED = ''

all: $(SOURCES)

.SILENT: cli
cli: git-test
	echo "Fetching agaveapi/cli source..."
	if [ ! -d "$(OBJ)" ]; then \
		git clone -q https://bitbucket.org/agaveapi/cli.git ;\
		rm -rf cli/.git ;\
		cp -R cli $(OBJ); \
	fi

.SILENT: customize
customize: cli
	echo "Customizing..."
	cp -fr src/templates $(OBJ)/
	cp -fr src/scripts/* $(OBJ)/bin/
	sed -e 's|$${TENANT_NAME}|$(TENANT_NAME)|g' \
		-e 's|$${TENANT_KEY}|$(TENANT_KEY)|g' \
		-e 's|$${api_version}|$(api_version)|g' \
		-e 's|$${api_release}|$(api_release)|g' \
		-e 's|$${sdk_version}|$(sdk_version)|g' \
		$(OBJ)/bin/cyverse-sdk-info > $(OBJ)/bin/cyverse-sdk-info.edited
	mv $(OBJ)/bin/cyverse-sdk-info.edited $(OBJ)/bin/cyverse-sdk-info
	find $(OBJ)/bin -type f ! -name '*.sh' -exec chmod a+rx {} \;


.SILENT: test
test:
	#echo "You should see a report from the cyverse-sdk-info command now...\n"
	#$(OBJ)/bin/cyverse-sdk-info
	echo "Not implemented"

.PHONY: clean
clean:
	rm -rf $(OBJ) cli

.SILENT: install
install: $(OBJ)
	cp -fr $(OBJ) $(PREFIX)
	rm -rf $(OBJ)
	echo "Installed in $(PREFIX)/$(OBJ)"
	echo "Ensure that $(PREFIX)/$(OBJ)/bin is in your PATH."

.SILENT: uninstall
uninstall:
	if [ -d $(PREFIX)/$(OBJ) ];then rm -rf $(PREFIX)/$(OBJ); echo "Uninstalled $(PREFIX)/$(OBJ)."; exit 0; fi

.SILENT: update
update: clean git-test
	git pull
	if [ $$? -eq 0 ] ; then echo "Now, run make && make install."; exit 0; fi

# Application tests
.SILENT: sed-test
sed-test:
	echo "Checking for BSD sed..."
	if [[ "`uname`" =~ "Darwin" ]]; then SED = " ''"; echo "Detected: Changing -i behavior."; fi

.SILENT: git-test
git-test:
	echo "Verifying that git is installed..."
	GIT_INFO=`git --version > /dev/null`
	if [ $$? -ne 0 ] ; then echo "Git not found or unable to be executed. Exiting." ; exit 1 ; fi
	git --version

.SILENT: docker-test
docker-test:
	echo "Verifying that docker is installed and reachable..."
	DOCKER_INFO=`docker info > /dev/null`
	if [ $$? -ne 0 ] ; then echo "Docker not found or unreachable. Exiting." ; exit 1 ; fi
	docker info

# Docker image
docker: docker-test customize
	docker build --rm=true -t iplantc/$(OBJ):$(sdk_version) .

docker-release: docker
	docker push iplantc/$(OBJ):$(sdk_version)

docker-clean:
	docker rmi iplantc/$(OBJ):$(sdk_version)

# Github release
.SILENT: dist
dist: all
	tar -czf "$(OBJ).tgz" $(OBJ)
	rm -rf $(OBJ)
	rm -rf cli
	echo "Ready for release. "

.SILENT: release
release:
	git diff-index --quiet HEAD
	if [ $$? -ne 0 ]; then echo "You have unstaged changes. Please commit or discard then re-run make clean && make release."; exit 0; fi
	git tag -a "v$(sdk_version)" -m "$(TENANT_NAME) SDK $(sdk_version). Requires Agave API $(api_version)/$(api_release)."
	git push origin "v$(sdk_version)"

