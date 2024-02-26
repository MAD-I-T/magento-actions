# magento-actions
Magento | Mage-os | PWA-Studio CI/CD using github actions: 

- tests 
- coding standard checks
- build 
- security checks
- [zero-downtime deploy](#zero-downtime-deployment) 
- [Gitlab-CI deployer](https://github.com/MAD-I-T/gitlab-ci-magento/)
- [Standalone third party module e.g](https://github.com/MAD-I-T/magento-worldline-sips2/blob/master/.github/workflows/main.yml)

<div align="center">
  <a href="https://www.youtube.com/watch?v=C-P-vA6aw34"><img src="https://user-images.githubusercontent.com/3765910/128611467-7fd3aa5a-6df1-4fe5-bfa3-23f01355999d.jpeg" alt="magento zero downtime in video"></a>
</div>

# usage

To use this action your git repository must respect similar scaffolding to the following (its best to use our  [install action](#install-magento-action) (s) ):

```bash
├── .github
│   └── workflows # directory where the workflows are found, see below for an example of main.yml 
├── README.md 
├── magento # directory where you Magento source files should go 
└── pwa-studio # optional pwa-studio directory for pwa src code
```
Links to full usage samples using Magento official [latest release](https://github.com/seyuf/magento-actions-sample/blob/master/.github/workflows/main.yml) or  the current [develop branch here](https://github.com/seyuf/m2-dev-github-actions).

##### main.yml

Choose elastic search or opensearch depending on your magento version:

Config sample when using magento v2.4.X
 ```
 name: m2-actions-test
 on: [push]
 
 jobs:
   magento2-build:
     runs-on: ubuntu-latest
     name: 'm2 unit tests & build'
     services:
       mysql:
         image: docker://mysql:8.0
         env:
           MYSQL_ROOT_PASSWORD: magento
           MYSQL_DATABASE: magento
         ports:
           - 3306:3306
         options: --health-cmd="mysqladmin ping" --health-interval=10s --health-timeout=5s --health-retries=3
       opensearch:
         image: opensearchproject/opensearch:1.2.1
         ports:
           - 9200:9200
         options: -e="discovery.type=single-node" -e "plugins.security.disabled=true"  -e "plugins.security.ssl.http.enabled=false" --health-cmd="curl http://localhost:9200/_cluster/health" --health-interval=10s --health-timeout=5s --health-retries=10
      
     steps:
     - uses: actions/checkout@v4
     - name: 'this step will build an magento artifact'
       if: always()
       uses: MAD-I-T/magento-actions@v3.26
       env:
         COMPOSER_AUTH: ${{secrets.COMPOSER_AUTH}}
       with:
         process: 'build'
 ```

 Config Example when under magento 2.3 & lower
 
```
name: m2-actions-test
on: [push]

jobs:
  magento2-build:
    runs-on: ubuntu-latest
    name: 'm2 unit tests & build'
    services:
      mysql:
        image: docker://mysql:5.7
        env:
          MYSQL_ROOT_PASSWORD: magento
          MYSQL_DATABASE: magento
        ports:
          - 3106:3306
        options: --health-cmd="mysqladmin ping" --health-interval=10s --health-timeout=5s --health-retries=3
    steps:
    - uses: actions/checkout@v2  
    - name: 'this step will build an magento artifact'
      if: always()
      uses: MAD-I-T/magento-actions@v3.19
      env:
        COMPOSER_AUTH: ${{secrets.COMPOSER_AUTH}}
      with:
        process: 'build'
```

To use the latest experimental version of the module set the following : (`uses: MAD-I-T/magento-actions@master`)

If some issues are encountered on 2.3.X version, please use the **v2.0** of the action in place of **v3.26** 

Also, in some custom cases it may be needed to force/specify the php version to use in the step. 
This can be done by adding php input (after **with:** option).

##### options
- `php:` [Optional] possible values (7.1, 7.2, 7.3, 7.4, 8.1, 8.2)
- `composer_version:` [Optional] possible values (1, 2)
- `process:` option [possible values](#other-processes) ('security-scan-files','static-test', 'integration-test', 'build'...)
- see all available args in the inputs section in [actions.yml](https://github.com/MAD-I-T/magento-actions/blob/master/action.yml) 

To use opensearch in place of elasticsearch [see following](https://forum.madit.fr/t/use-magento-actions-with-opensearch/63).

Example with M2 project using elasticsuite & elasticsearch [here](https://github.com/seyuf/magento-actions)

![magento-actions-sample](https://user-images.githubusercontent.com/3765910/68416322-91bb9a00-0194-11ea-967d-9f139b901b9a.png)

# Available processes

- [install magento from github actions (also supports mage-os)](#install-magento-action)
- [install pwa-studio from github actions](#install-pwa-studio-action)
- [deploy pwa-studio to prod](#deploy-pwa-studio-action)
- [Coding standard check](#coding-standard-check)
- [Magento build](#build-an-artifact)
- [Magento security scanners](#magento-security-scanners)
- [Unit testing](#unit-testing)
- [Test your magento custom marketplace extensions](https://www.madit.fr/r/test-magento-extensions)
- [Integration tests](#integration-testing)
- [Phpstan](#phpstan)
- [Mess detector](#mess-detector)
- [Static testing](#static-test)
- [Zero-downtime deployment](#zero-downtime-deployment)
- [For local docker devbox](https://github.com/MAD-I-T/magento-devbox)
- [Customize the action](#customize-the-action)
- [Setting the secrets](#set-secrets)
- [Typical issues](#typical-issues)
- [Use gitlab instead of github](https://github.com/MAD-I-T/gitlab-ci-magento/)
- [see more on the forum](https://forum.madit.fr/)



# zero downtime deployment
To migrate from standard to zero-downtime deployment using this action.
One can follow this [tutorial](https://www.madit.fr/r/1PP).

**This step must come after a mandatory build step.**

For magento 2.4 & 2.3

```
- name: 'this step will deploy your build to deployment server - zero downtime'
  uses: MAD-I-T/magento-actions@v3.26
  env:
    COMPOSER_AUTH: ${{secrets.COMPOSER_AUTH}}
    BUCKET_COMMIT: bucket-commit-${{github.sha}}.tar.gz
    MYSQL_ROOT_PASSWORD: magento
    MYSQL_DATABASE: magento
    HOST_DEPLOY_PATH: ${{secrets.STAGE_HOST_DEPLOY_PATH}}
    HOST_DEPLOY_PATH_BUCKET: ${{secrets.STAGE_HOST_DEPLOY_PATH}}/bucket
    SSH_PRIVATE_KEY: ${{secrets.STAGE_SSH_PRIVATE_KEY}}
    SSH_CONFIG: ${{secrets.STAGE_SSH_CONFIG}}
    WRITE_USE_SUDO: false
    with:
      process: 'deploy-staging'
      deployer: 'no-permission-check'

- name: 'unlock php deployer if the deployment fails'
  if: failure() || cancelled()
  uses: MAD-I-T/magento-actions@v3.26
  env:
    COMPOSER_AUTH: ${{secrets.COMPOSER_AUTH}}
    BUCKET_COMMIT: bucket-commit-${{github.sha}}.tar.gz
    MYSQL_ROOT_PASSWORD: magento
    MYSQL_DATABASE: magento
    HOST_DEPLOY_PATH: ${{secrets.STAGE_HOST_DEPLOY_PATH}}
    HOST_DEPLOY_PATH_BUCKET: ${{secrets.STAGE_HOST_DEPLOY_PATH}}/bucket
    SSH_PRIVATE_KEY: ${{secrets.STAGE_SSH_PRIVATE_KEY}}
    SSH_CONFIG: ${{secrets.STAGE_SSH_CONFIG}}
    WRITE_USE_SUDO: false
  with:
    process: 'cleanup-staging'
    deployer: 'no-permission-check'
```
Also to keep X number of build artifacts on the server after consecutive deployments. One can use ```keep_releases``` [see here](https://forum.madit.fr/t/magento-actions-limit-the-number-of-kept-releases-on-the-server/60).

For magento 2.3 and lower if  issues with the preceding sample
```
- name: 'this step will deploy your build to deployment server - zero downtime'
  uses: MAD-I-T/magento-actions@v2.0
  env:
    COMPOSER_AUTH: ${{secrets.COMPOSER_AUTH}}
    BUCKET_COMMIT: bucket-commit-${{github.sha}}.tar.gz
    MYSQL_ROOT_PASSWORD: magento
    MYSQL_DATABASE: magento
    HOST_DEPLOY_PATH: ${{secrets.STAGE_HOST_DEPLOY_PATH}}
    HOST_DEPLOY_PATH_BUCKET: ${{secrets.STAGE_HOST_DEPLOY_PATH}}/bucket
    SSH_PRIVATE_KEY: ${{secrets.STAGE_SSH_PRIVATE_KEY}}
    SSH_CONFIG: ${{secrets.STAGE_SSH_CONFIG}}
    WRITE_USE_SUDO: false
  with:
    php: '7.1'
    process: 'deploy-staging'

- name: 'unlock php deployer if the deployment fails'
  if: failure() || cancelled()
  uses: MAD-I-T/magento-actions@v2.0
  env:
    COMPOSER_AUTH: ${{secrets.COMPOSER_AUTH}}
    BUCKET_COMMIT: bucket-commit-${{github.sha}}.tar.gz
    MYSQL_ROOT_PASSWORD: magento
    MYSQL_DATABASE: magento
    HOST_DEPLOY_PATH: ${{secrets.STAGE_HOST_DEPLOY_PATH}}
    HOST_DEPLOY_PATH_BUCKET: ${{secrets.STAGE_HOST_DEPLOY_PATH}}/bucket
    SSH_PRIVATE_KEY: ${{secrets.STAGE_SSH_PRIVATE_KEY}}
    SSH_CONFIG: ${{secrets.STAGE_SSH_CONFIG}}
    WRITE_USE_SUDO: false
  with:
    php: '7.1'
    process: 'cleanup-staging'

```
**The env section and values are mandatory** :
- `COMPOSER_AUTH`: `{"http-basic":{"repo.magento.com": {"username": "xxxxxxxxxxxxxx", "password": "xxxxxxxxxxxxxx"}}}
- `HOST_DEPLOY_PATH`: `/var/www/myeshop/`
- `HOST_DEPLOY_PATH_BUCKET` : `${{secrets.STAGE_HOST_DEPLOY_PATH}}/bucket` or `/var/www/myeshop/bucket/`
- `SSH_PRIVATE_KEY` : `your ssh key`
- `SSH_CONFIG` : [see more](https://github.com/MAD-I-T/magento-actions/blob/master/config/php-deployer/sshd_config_example)  adjust the values to match your server (Host must be staging or production)
     ```
       Host staging  //this must be staging or production
        User magento 
        IdentityFile ~/.ssh/id_rsa 
        HostName staging.server
        Port 12022
     ``` 
 - `WRITE_USE_SUDO`: true or false, the deployer will exec commands as sudo on remote server
 
 The first deploy will fail, unless/then you must place a valid env.php under dir HOST_DEPLOY_PATH/shared/magento/app/etc/ on the deployment endpoint.
 
 A cleanup task must be launched if the deployment fails ([see here](https://github.com/seyuf/m2-dev-github-actions/blob/b711485a721ca07926140c7cdcfb79e2183cefee/.github/workflows/main.yml#L74))

 Also one can limit the release history by limiting or increasing the max number of tracked releases on the server ([with the keep_releases input arg](https://forum.madit.fr/t/magento-actions-limit-the-number-of-kept-releases-on-the-server/60))   

 **To achieve the deployment using gitlab-ci  ([follow this tutorial](https://github.com/MAD-I-T/gitlab-ci-magento/))**



## Install magento action
One can install magento using github actions. This action will download magento source code and copy it into the github repository calling it.
Make sure the repository does not contain the magento directory at the root.
You will also need to specify the version. Supported versions 2.2.X, 2.3.X and 2.4.X
Or you can simply clone or fork this [repository](https://github.com/seyuf/magento-create-project) and use it as a template.

```
name: m2-install-actions
on: [push]
jobs:
  magento2-install:
    runs-on: ubuntu-latest
    name: 'magento install & push'      
    steps:
    - uses: actions/checkout@v4
    - name: 'install fresh magento and copy to repo'
      uses: MAD-I-T/magento-actions@v3.26
      env:
        COMPOSER_AUTH: ${{secrets.COMPOSER_AUTH}}
      with:
        process: 'install-magento'
        magento_version: 2.3.0
#       no_push: 1 //uncomment this to prevent files from getting pushed to repo
```


<div align="center">
  <a href="https://www.youtube.com/watch?v=cqI79AKN7Gk"><img src="https://user-images.githubusercontent.com/3765910/154555377-2ab4d165-9bbb-42a4-b6cf-22586156477d.png" alt="install magento 2 using github actions"></a>
  <span>Install process in video</span>
</div>

One can use our **[magento-devbox](https://github.com/MAD-I-T/magento-devbox)** as local dev env. Linux and mac os supported.

To set `${{secrets.COMPOSER_AUTH}}` :

1. Go to `Settings>Secrets>Repository secrets`
2. Create variable `COMPOSER_AUTH`
3. Add you composer auth as value e.g :
   `{"http-basic":{"repo.magento.com": {"username": "xxxxxxxxxxxxxx", "password": "xxxxxxxxxxxxxx"}}}`

One can also download magento code source from the [mage-os](https://mage-os.org/) repo the advantage of this reside in the absence of the authentification requirement. No need for magento credentials.
See [this repository](https://github.com/seyuf/mage-os-actions.git).
```
    - name: 'install fresh magento from mage-os'
      #if: ${{false}}
      uses: MAD-I-T/magento-actions@v3.26
      with:
        process: 'install-mage-os'
        magento_version: 2.4.5  #e.g: 2.4.0, 2.4.3, 2.4.4 nightly
```



## Install pwa-studio action
One can install magento using github actions. This action will download the latest release of the magento [pwa-studio project](https://github.com/magento/pwa-studio/releases) source code and copy it into the github repository calling it.
Or you can simply clone/fork and push the content of this [repository](https://github.com/seyuf/pwa-studio-installer) to bootstrap a new pwa-studio project. **actions/checkout@v2** is mandatory (v2 and up), there is also a [video tutorial](https://www.youtube.com/watch?v=Q0o-NLM_rto).

```
name: pwa-studio-install-actions
on: [push]
jobs:
  magento2-install:
    runs-on: ubuntu-latest
    name: 'install & push pwa-studio project'      
    steps:
    - uses: actions/checkout@v2
    - name: 'install fresh  pwa studio code and copy to repo'
      uses: MAD-I-T/magento-actions@v3.26
      with:
        process: 'pwa-studio-install'
        #no_push: 1 //uncomment this to prevent files from getting pushed to repo
```
## Deploy pwa-studio action
One can also **install and deploy** a standalone PWA-studio website see the video below:
```
      - name: 'install fresh pwa-studio project'
        uses: MAD-I-T/magento-actions@v3.12
        if: ${{false}}
        with:
          process: 'pwa-studio-install'
          #no_push: 1
      - name: 'launch magento2 build'
        if: ${{false}}
        #if: always()
        id: build
        uses: MAD-I-T/magento-actions@v3.26
        env:
          COMPOSER_AUTH: ${{secrets.COMPOSER_AUTH}}
        with:
          process: 'build'
      - name: 'launch magento2 zero downtime deploy'
        if: ${{false}}
        #if: always()
        uses: MAD-I-T/magento-actions@v3.26
        env:
          BUCKET_COMMIT: bucket-commit-${{github.sha}}.tar.gz
          HOST_DEPLOY_PATH: ${{secrets.STAGE_HOST_DEPLOY_PATH}}
          HOST_DEPLOY_PATH_BUCKET: ${{secrets.STAGE_HOST_DEPLOY_PATH}}/bucket
          SSH_PRIVATE_KEY: ${{secrets.STAGE_SSH_PRIVATE_KEY}}
          SSH_CONFIG: ${{secrets.STAGE_SSH_CONFIG}}
          WRITE_USE_SUDO: false
        with:
         deployer: 'no-permission-check'
         process: 'deploy-staging'
        
      - name: 'unlock deployer if failure'
        if: ${{false}}
        #if: failure()
        uses: MAD-I-T/magento-actions@v3.26
        env:
          BUCKET_COMMIT: bucket-commit-${{github.sha}}.tar.gz
          HOST_DEPLOY_PATH: ${{secrets.STAGE_HOST_DEPLOY_PATH}}
          HOST_DEPLOY_PATH_BUCKET: ${{secrets.STAGE_HOST_DEPLOY_PATH}}/bucket
          SSH_PRIVATE_KEY: ${{secrets.STAGE_SSH_PRIVATE_KEY}}
          SSH_CONFIG: ${{secrets.STAGE_SSH_CONFIG}}
          WRITE_USE_SUDO: false
        with:
          process: 'cleanup-staging'
```
<div align="center">
  <a href="https://www.youtube.com/watch?v=psEBF5lohLo"><img src="https://user-images.githubusercontent.com/3765910/196008518-dc4cafb9-ce59-44fb-8b2e-9348688cc932.png" alt="check code against magento coding standard using github actions"></a>
  <span>deploy a pwa-studio website</span>
</div>


## Coding standard check

To check some magento module or some code against Magento conding Standard, useful before marketplace submissions
<div align="center">
  <a href="https://www.youtube.com/watch?v=4kyj4Rerm9s"><img src="https://user-images.githubusercontent.com/3765910/132560118-50110b43-57a5-4fb2-9725-7994e79451d8.png" alt="check code against magento coding standard using github actions"></a>
</div>

For magento 2.4 and 2.3

```
- name: 'test some specific module code quality'
  uses: MAD-I-T/magento-actions@v3.26
  env:
    COMPOSER_AUTH: ${{secrets.COMPOSER_AUTH}}
  with:
    process: 'phpcs-test'
    extension: 'Magento/CatalogSearch'
    standard: 'Magento2'
    severity: 10
```
- extension : the module to be tested (Vendor/Name) or Path using repository scaffolding (i.e from see example [here](https://github.com/MAD-I-T/Magento2-AtosSips-Sherlock-LCL/blob/master/.github/workflows/main.yml))
- standard : the standard for which the conformity must be checked 'Magento2, PSR2, PSR1, PSR12 etc...' see [magento-coding-standard](https://github.com/magento/magento-coding-standard)

Also see standalone third party module use case [here](https://github.com/MAD-I-T/magento-worldline-sips2/blob/master/.github/workflows/main.yml).

## build an artifact

For magento 2.4.x (**remove elasticsearch: 1 when building with 2.3.X**)

```
- name: 'This step will build an magento artifact'
  uses: MAD-I-T/magento-actions@v3.26
  env:
    COMPOSER_AUTH: ${{secrets.COMPOSER_AUTH}}
  with:
    process: 'build'
```

For magento <= 2.3  ***if issues with preceding sample***

```
- name: 'This step will build an magento artifact'
  uses: MAD-I-T/magento-actions@v2.0
  env:
    COMPOSER_AUTH: ${{secrets.COMPOSER_AUTH}}
  with:
    php: '7.1'
    process: 'build'
```

- `php` : 7.1, 7.2, 7.3, 7.4, 8.1 or 8.2

Use langs input to build static content for languages other than en_US or for [multi-lang support see](https://forum.madit.fr/t/build-magento-from-github-actions-static-deploy-with-multiple-languages/25/2?u=madit).

Use themes input to build static content for specific theme(s) only instead of all by default [more on multi-theme and hyva support](https://www.madit.fr/r/theme-builder-hyva).

## Magento security scanners

***Security scan actions must*** (in case of the modules scanner) be launched ***after a build*** step see example [here](https://github.com/seyuf/m2-dev-github-actions/blob/49c3d996d65f93fe438c5a245e4dd798e4c7d422/.github/workflows/main.yml#L37) as the magerun module needs the ```app/etc/config.php``` file to be present.

To scan the magento 2 files for common vulnerabilities using mwscan, the job's step can be set up as follows
 
For magento 2.4.x

```
- name: 'This step will scan the files for security breach'
  if: always()
  uses: MAD-I-T/magento-actions@v3.26
  env:
    COMPOSER_AUTH: ${{secrets.COMPOSER_AUTH}}
  with:
    process: 'security-scan-files'
```

For magento 2.3 or lower

```
- name: 'This step will scan the files for security breach'
  if: always()
  uses: MAD-I-T/magento-actions@v2.0
  env:
    COMPOSER_AUTH: ${{secrets.COMPOSER_AUTH}}
  with:
    php: '7.1'
    process: 'security-scan-files'
```

To scan the magento2 installed third parties modules for known vulnerabilities using [sansecio/magevulndb](https://github.com/sansecio/magevulndb), the job's step can be set up as follows:

For magento 2.4.x 

```
- name: 'This step will check all modules for security vulnerabilities'
      if: always()
      uses: MAD-I-T/magento-actions@v3.26
      env:
        COMPOSER_AUTH: ${{secrets.COMPOSER_AUTH}}
      with:
        process: 'security-scan-modules'
```

For magento 2.3 or lower

```
- name: 'This step will check all modules for security vulnerabilities'
      if: always()
      uses: MAD-I-T/magento-actions@v2.0
      env:
        COMPOSER_AUTH: ${{secrets.COMPOSER_AUTH}}
      with:
        php: '7.1'
        process: 'security-scan-modules'
```


Example of an output:

![security-risk-amasty](https://user-images.githubusercontent.com/3765910/117654360-f0047700-b195-11eb-8aff-ef05c2c3c231.png)



## unit testing
See code sample of testing your magento project [here](https://github.com/seyuf/m2-dev-github-actions/blob/49c3d996d65f93fe438c5a245e4dd798e4c7d422/.github/workflows/main.yml#L64)

See code sample to unit test your custom or a thrid party magento2 module [here](https://www.madit.fr/r/test-magento-extensions)

[See more](https://forum.madit.fr/t/unit-testing-in-magento-2/16) about unit testing in magento2

For magento 2.4.x  
```
- name: 'This step will execute all the unit tests available'
  uses: MAD-I-T/magento-actions@v3.26
  env:
    COMPOSER_AUTH: ${{secrets.COMPOSER_AUTH}}
  with:
    process: 'unit-test'
```

Run all unit test of the magento email module
```
- name: 'This step will execute specific unit tests in the path dir'
  uses: MAD-I-T/magento-actions@v3.26
  env:
    COMPOSER_AUTH: ${{secrets.COMPOSER_AUTH}}
  with:
    process: 'unit-test'
    unit_test_subset_path: 'vendor/magento/module-email/Test/Unit'
```
[See more](https://forum.madit.fr/t/unit-testing-in-magento-2/16) about unit testing in magento2


<div align="center">
  <a href="https://www.youtube.com/watch?v=kRIzj2Vv5zE"><img src="https://user-images.githubusercontent.com/3765910/171204520-c2a87d86-4c83-44d3-896d-1d59174d1a2e.jpeg" alt="install magento 2 using github actions"></a>
  <span>Video tutorial</span>
</div>

For magento 2.3 or lower if issues with the preceding sample
```
- name: 'This step will execute all the unit tests available'
  uses: MAD-I-T/magento-actions@v2.0
  env:
    COMPOSER_AUTH: ${{secrets.COMPOSER_AUTH}}
  with:
    php: '7.1'
    process: 'unit-test'
```

Also see standalone third party module use case [here](https://github.com/MAD-I-T/magento-worldline-sips2/blob/master/.github/workflows/main.yml).

## integration testing

Full sample, the integration test will need rabbitmq see below 
By default all tests in **phpunit.xml** will be run if the file exists. If not tests in **phpunit.xml.dist** will be run instead (the later should take hours to complete ^^).

Uncomment and replace elasticsearch by opensearch when magento version is >= 2.4.6

```
magento2-integration-test:
runs-on: ubuntu-latest
name: 'm2 integration test'
services:
  mysql:
    image: docker://mysql:8
    env:
      MYSQL_ROOT_PASSWORD: magento
      MYSQL_DATABASE: magento
    options: --health-cmd="mysqladmin ping" --health-interval=10s --health-timeout=5s --health-retries=5 -e MYSQL_ROOT_PASSWORD=magento -e MYSQL_USER=magento -e MYSQL_PASSWORD=magento -e MYSQL_DATABASE=magento --entrypoint sh mysql:8 -c "exec docker-entrypoint.sh mysqld --default-authentication-plugin=mysql_native_password"
  elasticsearch:
    image: docker://elasticsearch:7.1.0
    ports:
      - 9200:9200
    options: -e="discovery.type=single-node" --health-cmd="curl http://localhost:9200/_cluster/health" --health-interval=10s --health-timeout=5s --health-retries=10
  #opensearch:
  #   image: ghcr.io/mad-i-t/magento-opensearch:2.5.0
  #   ports:
  #     - 9200:9200
  #   options: -e="discovery.type=single-node" -e "plugins.security.disabled=true" --health-cmd="curl http://localhost:9200/_cluster/health" --health-interval=10s --health-timeout=5s --health-retries=10
  rabbitmq:
    image: docker://rabbitmq:3.8-alpine
    env:
      RABBITMQ_DEFAULT_USER: "magento"
      RABBITMQ_DEFAULT_PASS: "magento"
      RABBITMQ_DEFAULT_VHOST: "/"
    ports:
      - 5672:5672

steps:
  - uses: actions/checkout@v4
  - name: 'launch magento2 integration test'
    if: ${{false}}
    uses: MAD-I-T/magento-actions@v3.26
    env:
      COMPOSER_AUTH: ${{secrets.COMPOSER_AUTH}}
    with:
      process: 'integration-test'
```

See all the other integration test [features here](https://forum.madit.fr/t/magento-integration-test/66).

## Phpstan

Run phpstan on magento2 using github actions.

`exec_path` variable represents the analyze execution path the default is the RUNNER_WORKSPACE/magento/.

This feature utilizes the popular [bitExpert/phpstan-magento](https://github.com/bitExpert/phpstan-magento) module.

```
  - name: 'phpstan analyzer'
    uses: MAD-I-T/magento-actions@v3.26
    with:
      process: 'phpstan'
      exec_path: 'vendor/magento/module-email/' # i.e when standalone third party module github repo ../Madit/Module
```
You can place a **.neon** file (e.g: phpstan.neon) in the root of the project or in the magento dir with complementary phpstan configs.

See the following [sample](https://www.madit.fr/r/test-magento-extensions), if you just want to analyze a standalone magento module.


## Mess detector

Mess detection on magento2 using github actions.

`ruleset` variable can be used to specify a custom rulset other than the default magento version.

```
  - name: 'mess detector'
    uses: MAD-I-T/magento-actions@v3.26
    with:
      process: 'mess-detector'
      md_src_path: 'app/code/Madit/Sips2/'
```
Checkout [this sample](https://www.madit.fr/r/mess-detector-magento) to lean how to mess detected your magento module code.


Also see standalone third party module use case [here](https://github.com/MAD-I-T/magento-worldline-sips2/blob/master/.github/workflows/main.yml).

## static-test

For magento 2.3 & 2.4 
```
- name: 'This step starts static testing the code'
  uses: MAD-I-T/magento-actions@v3.26
  env:
    COMPOSER_AUTH: ${{secrets.COMPOSER_AUTH}}
  with:
    php: '7.2'
    process: 'static-test'
```

## Customize the action

### To make all docker build on the runner (no usage of an external image)  
 For those cloning ...
 
 Replace in [action.yml](https://github.com/MAD-I-T/magento-actions/blob/2e31f0c3a49314070f808458a93fa325e4855ffa/action.yml#L25)
 
 ` image: 'docker://mad1t/magento-actions:latest'` 
   
   by
 
 ` image: 'Dockerfile'` 
 
 ### To override the files in default scripts and config directories without forking
  use the [override_settings](https://github.com/MAD-I-T/magento-actions/blob/2e31f0c3a49314070f808458a93fa325e4855ffa/action.yml#L11) set it to 1
  You'll also have to create scripts or config dirs in the root of your m2 project.
  [Example](https://github.com/seyuf/m2-dev-github-actions) of project scafolding to override the action's default configs
  ```bash
  ├── .github
  │   └── workflows # directory where the workflows are found, see below for an example of main.yml 
  ├── README.md 
  └── magento # directory where you Magento source files should go
  └── config # the filenames must be similar to thoses of the action ex: config/integration-test-config.php 
  └── scripts #  ex: scripts/build.sh to override the build behaviour 
  ```
 

<div align="center">
  <a href="https://youtu.be/kRIzj2Vv5zE"><img src="https://user-images.githubusercontent.com/3765910/166113686-4dfd2482-ff96-48d3-8dda-fb769e891458.png" alt="check code against magento coding standard using github actions"></a> <h6>Video tutorial about overriding</h6>
</div>


  [See more](https://forum.madit.fr/t/magento-actions-override-default-scripts/19) about overriding
  

## Typical issues
   - To not have to constantly restart php-fpm after zero-downtime deployments please configure your http servers correctly [see here](https://forum.madit.fr/t/avoid-reloading-php-fpm-after-zero-downtime-deployments/56).
   - If you're using a self-hosted runner please run it as root user using `sudo ./svc.sh install root`
   - Composer install may override files outside `vendor` directory to prevent this please [adjust you deploy-strategy](https://forum.madit.fr/t/prevent-composer-install-from-overriding-files-outside-vendor-dir/102)
   - Do not forget to set or replace the `env.php` file in the `shared` directory
   - Adding the ssh user to the `http-user` group ex. `www-data` , also check php pool user and group setting rights
   - Set `WRITE_USE_SUDO` env if you want to launch the deployment script in sudo mode (not necessary in most cases)
   - integration test when using magento 2.4
     - you will need to set mysql 8 docker with the options arg as such `        options: --health-cmd="mysqladmin ping" --health-interval=10s --health-timeout=5s --health-retries=5 -e MYSQL_ROOT_PASSWORD=magento -e MYSQL_USER=magento -e MYSQL_PASSWORD=magento -e MYSQL_DATABASE=magento --entrypoint sh mysql:8 -c "exec docker-entrypoint.sh mysqld --default-authentication-plugin=mysql_native_password"
`
     - [see example here](https://github.com/seyuf/m2-dev-github-actions/blob/master/.github/workflows/main.yml#L104)
 

## Force composer version
   Although the action automatically detects and set the appropriate composer version according to the user's codebase (magento version).
   One can still force the composer version to be used through the *composer_version* argument. Possible values (1 or 2)

## Set secrets
  It is a good practice not to set credentials like composer auth in the code source (see https://12factor.net).
  So it is advised to use github secret instead of fill the value in the main.yml of your workflow. 
  Example for `COMPOSER_AUTH`:
  1. Go to `Settings>Secrets>Repository secrets`
  2. Create variable `COMPOSER_AUTH`
  3. Add you composer auth as value e.g :
     `{"http-basic":{"repo.magento.com": {"username": "xxxxxxxxxxxxxx", "password": "xxxxxxxxxxxxxx"}}}`
  4. Use as follows `COMPOSER_AUTH: ${{secrets.COMPOSER_AUTH}}` in the action definition.

## Use opensearch
  Issues with opensearch ? One may need to use opensearch instead of elasticsearch. By adding or replacing elasticsearch service by the following.

      opensearch:
        image: opensearchproject/opensearch:1.2.1
        ports:
          - 9200:9200
        options: -e="discovery.type=single-node" -e "plugins.security.disabled=true"  -e "plugins.security.ssl.http.enabled=false" --health-cmd="curl http://localhost:9200/_cluster/health" --health-interval=10s --health-timeout=5s --health-retries=10

### Issues with elasticsearch and opensearch compatibilities
Since v3.20 the search engine detection is automatic and depends on your [magento version](https://experienceleague.adobe.com/docs/commerce-operations/installation-guide/system-requirements.html).
Nonetheless, a service with an alias`opensearch` or `elasticsearch` must be set. 

In many cases, it is recommended to remove inputs such as `elasticsearch: 1` or `opensearch: 1` from steps unless you want to force these params.

Also, `elasticsearch: 0` or `opensearch: 0`  can be used to forcefully to disable search engine detecting/usage (Not recommended).
