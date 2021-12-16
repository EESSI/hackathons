# Client

1. ansible-galaxy install -r requirements.yaml
2. Edit inventory.yaml
3. ansible-playbook install_prometheus_amd_grafana.yaml -i inventory -r 

# Wut?

````
TASK [cloudalchemy.prometheus : Get checksum list] ********************************************************************************************
objc[17187]: +[__NSCFConstantString initialize] may have been in progress in another thread when fork() was called.
objc[17187]: +[__NSCFConstantString initialize] may have been in progress in another thread when fork() was called. We cannot safely call it or ignore it in the fork() child process. Crashing instead. Set a breakpoint on objc_initializeAfterForkError to debug.
ERROR! A worker was found in a dead state
````

https://github.com/rails/rails/issues/38560

OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
