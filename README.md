# magento-actions
Magento 2 CI/CD using github actions
tests - phpcs - build - deploy

# usage

To use this action your repository must respect similar scaffolding to the following:

```bash
├── .github
│   └── workflows # directory where the workflows are found, see below for an example of main.yml 
├── README.md 
└── magento # directory where you Magento source files should go
```

Full usage example using Magento official develop branch [here](https://github.com/seyuf/m2-dev-github-actions)

##### main.yml 
```
name: m2-actions-test
on: [push]

jobs:
  magento2-build:
    runs-on: ubuntu-18.04
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
    - uses: actions/checkout@master  # pulls your repository, M2 src must be in a magento directory
    - name: 'launch magento2 unit test step'
      if: always()
      uses: MAD-I-T/magento-actions@master
      env:
        COMPOSER_AUTH: ${{secrets.COMPOSER_AUTH}}
      with:
        php: '7.1'
        process: 'unit-test'
    - name: 'launch magento2 build step'
      if: always()
      uses: MAD-I-T/magento-actions@master
      env:
        COMPOSER_AUTH: ${{secrets.COMPOSER_AUTH}}
      with:
        php: '7.1'
        process: 'build'
```
##### options
- `php:` possible values (7.1, 7.2)
- `process:` option possible values ('unit-test','static-test', 'integration-test', 'build'...)
- others see inputs section in [actions.yml](https://github.com/MAD-I-T/magento-actions/blob/master/action.yml) 

Example with M2 project using elasticsuite & elasticsearch [here](https://github.com/seyuf/magento-actions)

![magento-actions-sample](https://user-images.githubusercontent.com/3765910/68416322-91bb9a00-0194-11ea-967d-9f139b901b9a.png)

# zero downtime deployment

```
uses: MAD-I-T/magento-actions@master
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
  
# Other processes

- [Magento build](#build)
- [Code quality check](#code-quality-check)
- [Unit testing](#unit-testing)
- [Integration tests](#integration-testing)
- [Static testing](#static-test)
- [Customize the module](#customize-the-action)
- [Setting the secrets](#)

## Code quality check  

To check some magento module, useful before marketplace submissions


```
uses: MAD-I-T/magento-actions@master
env:
  COMPOSER_AUTH: ${{secrets.COMPOSER_AUTH}}
with:
  php: '7.1'
  process: 'phpcs-test'
  extension: 'Magento/CatalogSearch'
  standard: 'Magento2'
```
- extension : the module to be tested
- standard : the standard for which the conformity must be checked 'Magento2, PSR2, PSR1, PSR12 etc...' see [magento-coding-standard](https://github.com/magento/magento-coding-standard)



## unit testing

```
uses: MAD-I-T/magento-actions@master
env:
  COMPOSER_AUTH: ${{secrets.COMPOSER_AUTH}}
with:
  php: '7.1'
  process: 'unit-test'
```

## integration testing

Full sample, the integration test will need rabbitmq (this test will take a while to complete ^^)
```
magento2-integration-test:
runs-on: ubuntu-18.04
name: 'm2 integration test'
services:
  mysql:
    image: docker://mysql:5.7
    env:
      MYSQL_ROOT_PASSWORD: magento
      MYSQL_DATABASE: magento
    ports:
      - 3106:3306
    options: --health-cmd="mysqladmin ping" --health-interval=10s --health-timeout=5s --health-retries=3
  rabbitmq:
    image: docker://rabbitmq:3.6.6-alpine
    env:
      RABBITMQ_DEFAULT_USER: "magento"
      RABBITMQ_DEFAULT_PASS: "magento"
      RABBITMQ_DEFAULT_VHOST: "/"
    ports:
      - 5672:5672

steps:
  - uses: actions/checkout@master
    with:
      submodules: recursive
  - name: 'launch magento2 integration test'
    uses: MAD-I-T/magento-actions@master
    env:
      COMPOSER_AUTH: ${{secrets.COMPOSER_AUTH}}
    with:
      php: '7.1'
      process: 'integration-test'
      elasticsuite: 0
```

## static-test

```
uses: MAD-I-T/magento-actions@master
env:
  COMPOSER_AUTH: ${{secrets.COMPOSER_AUTH}}
with:
  php: '7.1'
  process: 'static-test'
```

## build

```
uses: MAD-I-T/magento-actions@master
env:
  COMPOSER_AUTH: ${{secrets.COMPOSER_AUTH}}
with:
  php: '7.1'
  process: 'build'
```
- `php` : 7.1 or 7.2


## Customize the action

### To make all docker build on the runner (no dockerhub image)  
 For those cloning ...
 
 Replace in [action.yml](https://github.com/MAD-I-T/magento-actions/blob/2e31f0c3a49314070f808458a93fa325e4855ffa/action.yml#L25)
 
 ` image: 'docker://mad1t/magento-actions:latest'` 
   
   by
 
 ` image: 'Dockerfile'` 
 
 ### To override the files in default scripts and config directories without cloning
  use the [override-settings](https://github.com/MAD-I-T/magento-actions/blob/2e31f0c3a49314070f808458a93fa325e4855ffa/action.yml#L11)
  You will have to place the dirs in the root of your m2 project next to the magento directory.
 
## Set secrets
  It is a good practice not to set credentials like composer auth in the code source (see https://12factor.net).
  So it is advised to use github secret instead of fill the value in the main.yml of your workflow. 
  Example for `COMPOSER_AUTH`:
  1. Go to `Settings>Secrets`
  2. Create variable `COMPOSER_AUTH`
  3. Add you composer auth as value e.g :
     `{"http-basic":{"repo.magento.com": {"username": "xxxxxxxxxxxxxx", "password": "xxxxxxxxxxxxxx"}}}`
  4. Use as follows `COMPOSER_AUTH: ${{secrets.COMPOSER_AUTH}}` in the action definition.