# magento-actions
Github deployment actions for Magento 2

# usage

```
jobs:
  magento2-build:
    runs-on: ubuntu-18.04
    name: 'build m2'
    services:
      mysql:
        image: docker://mysql:5.7
        env:
          MYSQL_ROOT_PASSWORD: magento
          MYSQL_DATABASE: magento
        ports:
          - 3106:3306
      elasticsearch:
        image: docker://madit512/magento2-elasticsearch:5.6 # optional to be use with elasticsuite
        ports:
          - 9200:9200
    steps:          
    - uses: actions/checkout@master  # pulls your repository, M2 src must be in a magento directory
    - name: 'launch magento2 build'
      uses: MAD-I-T/magento-actions@master
      env:
        COMPOSER_AUTH: ${{secrets.COMPOSER_AUTH}}
      with: 
        php: '7.1' # php version to use possible values (7.1, 7.2)
        process: 'build' # possible values (build, deploy, static-test, integration-test)
        elasticsuite: 1 # to use if you're using elasticsuite modules
```
