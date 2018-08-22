# danger-gitlab

Example `.gitlab-ci.yml` file:

```
stages:
  - check

danger:
  stage: check
  image: inloopx/danger-gitlab
  tags:
    - docker
  before_script:
    - export CI_MERGE_REQUEST_ID=$(git ls-remote -q origin merge-requests\*\head | grep $CI_COMMIT_SHA | sed 's/.*refs\/merge-requests\/\([0-9]*\)\/head/\1/g')
    - export CI_PROJECT_PATH=$CI_PROJECT_ID #some version of gitlab has problems with searching by project path
  script:
    - danger
```
