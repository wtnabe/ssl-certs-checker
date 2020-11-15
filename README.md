## SSL Certs Checker

### features

 * fetch certs info with curl
 * check auto renew certs
 * output TSV with expire date

### requirements

 * Ruby
 * Curl

### preparation

 * settings.yaml

### Usage

```
$ ruby command.rb <settings.yaml>
```

### settings.yaml format

```yaml
sites: # sites for check
  - domain
  - domain
  - ...
auto_renew_certs:
  - issuer or subject name like `Let's Encrypt`
  - issuer or subject name like `Amazon`
```
