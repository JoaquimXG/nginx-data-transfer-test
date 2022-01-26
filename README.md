# NGINX DataTransfer Testing in AWS

A collection of scripts and cloud-init files for testing DataTransfer costs in AWS using NGINX.

## Test Architecture

### Names and Symbols

- Client outside of AWS: client
- NGINX proxy: NGINX
- Web server: server
- eu-west-1 region: r1
- eu-west-2 region: r2
- eu-west-1 - availability zone 1: r1:az1
- public IP transfer: - 
- private IP transfer: -- 
- etc.

1. client - NGINX(r1:az1) -- server(r1:az1)
    - Testing transfer within az using private IP
2. client - NGINX(r1:az1) -- server(r1:az2)
    - Testing transfer between AZs using private IP
3. client - NGINX(r1:az1) - server(r1:az1)
    - Testing transfer within AZ using public IP
4. client - NGINX(r1:az1) - server(r1:az2)
    - Testing tranfer between AZ using public IP
5. client - NGINX(r1) -- server(r2)
    - Testing transfer between regions using private IP 
    - **NOT PLANNING TO TEST THIS**
6. client - NGINX(r1) - server(r2)
    - Testing transfer between regions using public IP