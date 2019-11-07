# magento-actions
Magento 2 CI/CD using github actions
tests - build - deploy

# usage

To use this action your repository must respect similar scaffolding to the following:

```bash
├── .github
│   └── workflows # directory where the actions workflows are found, see below for an example of main.yml 
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
