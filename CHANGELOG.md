# Change Log

All notable changes to this project will be documented in this file.
Format of this file follows [these](http://keepachangelog.com/) guidelines.
This project adheres to [Semantic Versioning](http://semver.org/).

## [%RELEASE_VERSION%] - [%RELEASE_DATE%]

### Added

- [CodeFactor](https://www.codefactor.io) badge to main README.md
- add [clair-cicd](https://github.com/simonsdave/clair-cicd) docker image vulnerability
  assessment to CircleCI pipeline
- [LGTM](https://lgtm.com/) badges to main README.md
- add CircleCI docker executor [authenticated pull](https://circleci.com/docs/2.0/private-images/)
- per [this](https://discuss.circleci.com/t/old-linux-machine-image-remote-docker-deprecation/37572) article, added
  explicit version to ```setup_remote_docker``` in CircleCI pipeline

### Changed

- dev-env v0.5.14 -> v0.6.11 (which include Python 2.7 -> Python 3.7)
- matplotlib 2.2.3 -> 3.3.4
- numpy 1.15.3 -> 1.19.5
- python-dateutil 2.8.0 -> 2.8.1
- added markdown and json linting to CircleCI pipeline
- added README.rst building to CircleCI pipeline

### Removed

- Travis CI
